# RequestFactory

Source file [../../contracts/RequestFactory.sol](../../contracts/RequestFactory.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Next 6 Ok
import "contracts/Interface/RequestFactoryInterface.sol";
import "contracts/TransactionRequestCore.sol";
import "contracts/Library/RequestLib.sol";
import "contracts/IterTools.sol";
import "contracts/CloneFactory.sol";
import "contracts/Library/RequestScheduleLib.sol";

/**
 * @title RequestFactory
 * @dev Contract which will produce new TransactionRequests.
 */
// BK Ok
contract RequestFactory is RequestFactoryInterface, CloneFactory {
    // BK Ok
    using IterTools for bool[6];

    // BK Ok
    TransactionRequestCore public transactionRequestCore;

    // BK Next 2 Ok
    uint constant public BLOCKS_BUCKET_SIZE = 240; //~1h
    uint constant public TIMESTAMP_BUCKET_SIZE = 3600; //1h

    // BK Ok - Constructor
    function RequestFactory(
        address _transactionRequestCore
    ) 
        public 
    {
        // BK Ok
        require(_transactionRequestCore != 0x0);

        // BK Ok
        transactionRequestCore = TransactionRequestCore(_transactionRequestCore);
    }

    /**
     * @dev The lowest level interface for creating a transaction request.
     *
     * @param _addressArgs [0] -  meta.owner
     * @param _addressArgs [1] -  paymentData.feeRecipient
     * @param _addressArgs [2] -  txnData.toAddress
     * @param _uintArgs [0]    -  paymentData.fee
     * @param _uintArgs [1]    -  paymentData.bounty
     * @param _uintArgs [2]    -  schedule.claimWindowSize
     * @param _uintArgs [3]    -  schedule.freezePeriod
     * @param _uintArgs [4]    -  schedule.reservedWindowSize
     * @param _uintArgs [5]    -  schedule.temporalUnit
     * @param _uintArgs [6]    -  schedule.windowSize
     * @param _uintArgs [7]    -  schedule.windowStart
     * @param _uintArgs [8]    -  txnData.callGas
     * @param _uintArgs [9]    -  txnData.callValue
     * @param _uintArgs [10]   -  txnData.gasPrice
     * @param _uintArgs [11]   -  claimData.requiredDeposit
     * @param _callData        -  The call data
     */
    // BK Ok - Only called by createValidatedRequest(...) below
    function createRequest(
        address[3]  _addressArgs,
        uint[12]    _uintArgs,
        bytes       _callData
    )
        public payable returns (address)
    {
        // Create a new transaction request clone from transactionRequestCore.
        // BK Ok
        address transactionRequest = createClone(transactionRequestCore);

        // Call initialize on the transaction request clone.
        // BK Ok - Parameters match TransactionRequestCore.initialize(...)
        TransactionRequestCore(transactionRequest).initialize.value(msg.value)(
            [
                msg.sender,       // Created by
                _addressArgs[0],  // meta.owner
                _addressArgs[1],  // paymentData.feeRecipient
                _addressArgs[2]   // txnData.toAddress
            ],
            _uintArgs,            //uint[12]
            _callData
        );

        // Track the address locally
        // BK Ok
        requests[transactionRequest] = true;

        // Log the creation.
        // BK NOTE - event RequestCreated(address request, address indexed owner, int indexed bucket, uint[12] params);
        // BK Ok
        emit RequestCreated(
            // BK Ok
            transactionRequest,
            // BK Ok - owner = meta.owner
            _addressArgs[0],
            // BK Ok - int bucket = uint windowStart => schedule.windowStart, RequestScheduleLib.TemporalUnit unit => schedule.temporalUnit
            getBucket(_uintArgs[7], RequestScheduleLib.TemporalUnit(_uintArgs[5])),
            // BK Ok
            _uintArgs
        );

        // BK Ok
        return transactionRequest;
    }

    /**
     *  The same as createRequest except that it requires validation prior to
     *  creation.
     *
     *  Parameters are the same as `createRequest`
     */
    // BK Ok - Only called by BaseScheduler.schedule(...)
    function createValidatedRequest(
        address[3]  _addressArgs,
        uint[12]    _uintArgs,
        bytes       _callData
    )
        public payable returns (address)
    {
        // BK Ok
        bool[6] memory isValid = validateRequestParams(
            _addressArgs,
            _uintArgs,
            msg.value
        );

        // BK Ok
        if (!isValid.all()) {
            // BK TODO - Below
            if (!isValid[0]) {
                emit ValidationError(uint8(Errors.InsufficientEndowment));
            }
            if (!isValid[1]) {
                emit ValidationError(uint8(Errors.ReservedWindowBiggerThanExecutionWindow));
            }
            if (!isValid[2]) {
                emit ValidationError(uint8(Errors.InvalidTemporalUnit));
            }
            if (!isValid[3]) {
                emit ValidationError(uint8(Errors.ExecutionWindowTooSoon));
            }
            if (!isValid[4]) {
                emit ValidationError(uint8(Errors.CallGasTooHigh));
            }
            if (!isValid[5]) {
                emit ValidationError(uint8(Errors.EmptyToAddress));
            }

            // Try to return the ether sent with the message
            // BK NOTE - Return of 0x0 to BaseScheduler.schedule(...) will throw an error there, so the following transfer will be rolled back anyway
            // BK Ok - Limited to 2,300 gas, false return status throws an error
            msg.sender.transfer(msg.value);
            
            // BK Ok
            return 0x0;
        }

        // BK Ok
        return createRequest(_addressArgs, _uintArgs, _callData);
    }

    /// ----------------------------
    /// Internal
    /// ----------------------------

    /*
     *  @dev The enum for launching `ValidationError` events and mapping them to an error.
     */
    // BK Next block Ok
    enum Errors {
        InsufficientEndowment,
        ReservedWindowBiggerThanExecutionWindow,
        InvalidTemporalUnit,
        ExecutionWindowTooSoon,
        CallGasTooHigh,
        EmptyToAddress
    }

    // BK Ok - Event
    event ValidationError(uint8 error);

    /*
     * @dev Validate the constructor arguments for either `createRequest` or `createValidatedRequest`.
     */
    // BK Ok - View function, called by createValidatedRequest(...) above
    function validateRequestParams(
        address[3]  _addressArgs,
        uint[12]    _uintArgs,
        uint        _endowment
    )
        public view returns (bool[6])
    {
        // BK TODO - Check
        return RequestLib.validate(
            [
                msg.sender,      // meta.createdBy
                _addressArgs[0],  // meta.owner
                _addressArgs[1],  // paymentData.feeRecipient
                _addressArgs[2]   // txnData.toAddress
            ],
            _uintArgs,
            _endowment
        );
    }

    /// Mapping to hold known requests.
    // BK Ok
    mapping (address => bool) requests;

    // BK Ok - View function
    function isKnownRequest(address _address)
        public view returns (bool isKnown)
    {
        // BK Ok
        return requests[_address];
    }

    // BK Ok - Pure function returning int. Only called for generating `RequestCreated` event log
    function getBucket(uint windowStart, RequestScheduleLib.TemporalUnit unit)
        public pure returns(int)
    {
        // BK Ok
        uint bucketSize;
        /* since we want to handle both blocks and timestamps
            and do not want to get into case where buckets overlaps
            block buckets are going to be negative ints
            timestamp buckets are going to be positive ints
            we'll overflow after 2**255-1 blocks instead of 2**256-1 since we encoding this on int256
        */
        // BK Ok
        int sign;

        // BK Ok
        if (unit == RequestScheduleLib.TemporalUnit.Blocks) {
            // BK Ok
            bucketSize = BLOCKS_BUCKET_SIZE;
            // BK Ok
            sign = -1;
        // BK Ok
        } else if (unit == RequestScheduleLib.TemporalUnit.Timestamp) {
            // BK Ok
            bucketSize = TIMESTAMP_BUCKET_SIZE;
            // BK Ok
            sign = 1;
        // BK Ok
        } else {
            // BK Ok
            revert();
        }
        // BK Ok
        return sign * int(windowStart - (windowStart % bucketSize));
    }
}

```
