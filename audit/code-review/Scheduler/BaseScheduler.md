# BaseScheduler

Source file [../../../contracts/Scheduler/BaseScheduler.sol](../../../contracts/Scheduler/BaseScheduler.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Next 2 Ok
import "contracts/Interface/RequestFactoryInterface.sol";
import "contracts/Interface/SchedulerInterface.sol";

// BK Next 3 Ok
import "contracts/Library/PaymentLib.sol";
import "contracts/Library/RequestLib.sol";
import "contracts/Library/RequestScheduleLib.sol";

/**
 * @title BaseScheduler
 * @dev The foundational contract which provides the API for scheduling future transactions on the Alarm Client.
 */
// BK Ok
contract BaseScheduler is SchedulerInterface {
    // The RequestFactory which produces requests for this scheduler.
    // BK Ok
    address public factoryAddress;

    // The TemporalUnit (Block or Timestamp) for this scheduler.
    // BK Ok
    RequestScheduleLib.TemporalUnit public temporalUnit;

    // The address which will be sent the fee payments.
    // BK Ok
    address public feeRecipient;

    /*
     * @dev Fallback function to be able to receive ether. This can occur
     *  legitimately when scheduling fails due to a validation error.
     */
    // BK Ok - Accept ETH payment
    function() public payable {}

    /// Event that bubbles up the address of new requests made with this scheduler.
    // BK Ok - Event
    event NewRequest(address request);

    /**
     * @dev Schedules a new TransactionRequest using the 'full' parameters.
     * @param _toAddress The address destination of the transaction.
     * @param _callData The bytecode that will be included with the transaction.
     * @param _uintArgs [0] The callGas of the transaction.
     * @param _uintArgs [1] The value of ether to be sent with the transaction.
     * @param _uintArgs [2] The size of the execution window of the transaction.
     * @param _uintArgs [3] The (block or timestamp) of when the execution window starts.
     * @param _uintArgs [4] The gasPrice which will be used to execute this transaction.
     * @param _uintArgs [5] The fee attached to this transaction.
     * @param _uintArgs [6] The bounty attached to this transaction.
     * @param _uintArgs [7] The deposit required to claim this transaction.
     * @return The address of the new TransactionRequest.   
     */ 
    // BK Ok - Called by _examples/DelayedPayment.DelayedPayment(...) and _examples/DelayedPayment.schedule()
    function schedule (
        address   _toAddress,
        bytes     _callData,
        uint[8]   _uintArgs
    )
        public payable returns (address newRequest)
    {
        // BK Ok
        RequestFactoryInterface factory = RequestFactoryInterface(factoryAddress);

        // BK NOTE - The `computeEndowment(...)` and `require(msg.value >= endowment)` check is a duplicate of
        // BK NOTE - factory.createValidatedRequest(...) -> factory.validateRequestParams(...) -> RequestLib.validate(...) ->
        // BK NOTE - PaymentLib.validateEndowment(...)
        // BK Ok
        uint endowment = computeEndowment(
            _uintArgs[6], //bounty
            _uintArgs[5], //fee
            _uintArgs[0], //callGas
            _uintArgs[1], //callValue
            _uintArgs[4]  //gasPrice
        );

        // BK Ok
        require(msg.value >= endowment);

        if (temporalUnit == RequestScheduleLib.TemporalUnit.Blocks) {
            // BK NOTE - From RequestFactory.createValidatedRequest(...):
            // BK NOTE - _addressArgs [0] -  meta.owner
            // BK NOTE - _addressArgs [1] -  paymentData.feeRecipient
            // BK NOTE - _addressArgs [2] -  txnData.toAddress
            // BK NOTE - _uintArgs [0]    -  paymentData.fee
            // BK NOTE - _uintArgs [1]    -  paymentData.bounty
            // BK NOTE - _uintArgs [2]    -  schedule.claimWindowSize
            // BK NOTE - _uintArgs [3]    -  schedule.freezePeriod
            // BK NOTE - _uintArgs [4]    -  schedule.reservedWindowSize
            // BK NOTE - _uintArgs [5]    -  schedule.temporalUnit
            // BK NOTE - _uintArgs [6]    -  schedule.windowSize
            // BK NOTE - _uintArgs [7]    -  schedule.windowStart
            // BK NOTE - _uintArgs [8]    -  txnData.callGas
            // BK NOTE - _uintArgs [9]    -  txnData.callValue
            // BK NOTE - _uintArgs [10]   -  txnData.gasPrice
            // BK NOTE - _uintArgs [11]   -  claimData.requiredDeposit
            // BK NOTE - _callData        -  The call data
            newRequest = factory.createValidatedRequest.value(msg.value)(
                [
                    // BK Ok - Dest _addressArgs [0] -  meta.owner
                    msg.sender,                 // meta.owner
                    // BK Ok - Dest _addressArgs [1] -  paymentData.feeRecipient
                    feeRecipient,               // paymentData.feeRecipient
                    // BK Ok - Dest _addressArgs [2] -  txnData.toAddress
                    _toAddress                  // txnData.toAddress
                ],
                [
                    // BK Ok - Source _uintArgs [5] The fee attached to this transaction.
                    // BK Ok - Dest _uintArgs [0]    -  paymentData.fee
                    _uintArgs[5],               // paymentData.fee
                    // BK Ok - Source _uintArgs [6] The bounty attached to this transaction.
                    // BK Ok - Dest _uintArgs [1]    -  paymentData.bounty
                    _uintArgs[6],               // paymentData.bounty
                    // BK Ok - Dest _uintArgs [2]    -  schedule.claimWindowSize
                    255,                        // scheduler.claimWindowSize
                    // BK Ok - Dest _uintArgs [3]    -  schedule.freezePeriod
                    10,                         // scheduler.freezePeriod
                    // BK Ok - Dest _uintArgs [4]    -  schedule.reservedWindowSize
                    16,                         // scheduler.reservedWindowSize
                    // BK Ok - Dest _uintArgs [5]    -  schedule.temporalUnit
                    uint(temporalUnit),         // scheduler.temporalUnit (1: block, 2: timestamp)
                    // BK Ok - Source _uintArgs [2] The size of the execution window of the transaction.
                    // BK Ok - Dest _uintArgs [6]    -  schedule.windowSize
                    _uintArgs[2],               // scheduler.windowSize
                    // BK Ok - Source _uintArgs [3] The (block or timestamp) of when the execution window starts.
                    // BK Ok - Dest _uintArgs [7]    -  schedule.windowStart
                    _uintArgs[3],               // scheduler.windowStart
                    // BK Ok - Source _uintArgs [0] The callGas of the transaction.
                    // BK Ok - Dest _uintArgs [8]    -  txnData.callGas
                    _uintArgs[0],               // txnData.callGas
                    // BK Ok - Source _uintArgs [1] The value of ether to be sent with the transaction.
                    // BK Ok - Dest _uintArgs [9]    -  txnData.callValue
                    _uintArgs[1],               // txnData.callValue
                    // BK Ok - Source _uintArgs [4] The gasPrice which will be used to execute this transaction.
                    // BK Ok - Dest _uintArgs [10]   -  txnData.gasPrice
                    _uintArgs[4],               // txnData.gasPrice
                    // BK Ok - Source _uintArgs [7] The deposit required to claim this transaction.
                    // BK Ok - Dest _uintArgs [11]   -  claimData.requiredDeposit
                    _uintArgs[7]                // claimData.requiredDeposit
                ],
                _callData
            );
        } else if (temporalUnit == RequestScheduleLib.TemporalUnit.Timestamp) {
            newRequest = factory.createValidatedRequest.value(msg.value)(
                [
                    // BK Ok - Dest _addressArgs [0] -  meta.owner
                    msg.sender,                 // meta.owner
                    // BK Ok - Dest _addressArgs [1] -  paymentData.feeRecipient
                    feeRecipient,               // paymentData.feeRecipient
                    // BK Ok - Dest _addressArgs [2] -  txnData.toAddress
                    _toAddress                  // txnData.toAddress
                ],
                [
                    // BK Ok - Source _uintArgs [5] The fee attached to this transaction.
                    // BK Ok - Dest _uintArgs [0]    -  paymentData.fee
                    _uintArgs[5],               // paymentData.fee
                    // BK Ok - Source _uintArgs [6] The bounty attached to this transaction.
                    // BK Ok - Dest _uintArgs [1]    -  paymentData.bounty
                    _uintArgs[6],               // paymentData.bounty
                    // BK Ok - Dest _uintArgs [2]    -  schedule.claimWindowSize
                    60 minutes,                 // scheduler.claimWindowSize
                    // BK Ok - Dest _uintArgs [3]    -  schedule.freezePeriod
                    3 minutes,                  // scheduler.freezePeriod
                    // BK Ok - Dest _uintArgs [4]    -  schedule.reservedWindowSize
                    5 minutes,                  // scheduler.reservedWindowSize
                    // BK Ok - Dest _uintArgs [5]    -  schedule.temporalUnit
                    uint(temporalUnit),         // scheduler.temporalUnit (1: block, 2: timestamp)
                    // BK Ok - Source _uintArgs [2] The size of the execution window of the transaction.
                    // BK Ok - Dest _uintArgs [6]    -  schedule.windowSize
                    _uintArgs[2],               // scheduler.windowSize
                    // BK Ok - Source _uintArgs [3] The (block or timestamp) of when the execution window starts.
                    // BK Ok - Dest _uintArgs [7]    -  schedule.windowStart
                    _uintArgs[3],               // scheduler.windowStart
                    // BK Ok - Source _uintArgs [0] The callGas of the transaction.
                    // BK Ok - Dest _uintArgs [8]    -  txnData.callGas
                    _uintArgs[0],               // txnData.callGas
                    // BK Ok - Source _uintArgs [1] The value of ether to be sent with the transaction.
                    // BK Ok - Dest _uintArgs [9]    -  txnData.callValue
                    _uintArgs[1],               // txnData.callValue
                    // BK Ok - Source _uintArgs [4] The gasPrice which will be used to execute this transaction.
                    // BK Ok - Dest _uintArgs [10]   -  txnData.gasPrice
                    _uintArgs[4],               // txnData.gasPrice
                    // BK Ok - Source _uintArgs [7] The deposit required to claim this transaction.
                    // BK Ok - Dest _uintArgs [11]   -  claimData.requiredDeposit
                    _uintArgs[7]                // claimData.requiredDeposit
                ],
                // BK Ok
                _callData
            );
        // BK Ok
        } else {
            // unsupported temporal unit
            // BK Ok
            revert();
        }

        // BK Ok
        require(newRequest != 0x0);
        // BK Ok
        emit NewRequest(newRequest);
        // BK Ok
        return newRequest;
    }

    // BK Ok - View function, called by schedule(...) above
    function computeEndowment(
        uint _bounty,
        uint _fee,
        uint _callGas,
        uint _callValue,
        uint _gasPrice
    )
        public view returns (uint)
    {
        // BK Ok
        return PaymentLib.computeEndowment(
            _bounty,
            _fee,
            _callGas,
            _callValue,
            _gasPrice,
            RequestLib.getEXECUTION_GAS_OVERHEAD()
        );
    }
}

```
