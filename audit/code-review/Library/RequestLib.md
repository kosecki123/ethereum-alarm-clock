# RequestLib

Source file [../../../contracts/Library/RequestLib.sol](../../../contracts/Library/RequestLib.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Next 5 Ok
import "contracts/Library/ClaimLib.sol";
import "contracts/Library/ExecutionLib.sol";
import "contracts/Library/PaymentLib.sol";
import "contracts/Library/RequestMetaLib.sol";
import "contracts/Library/RequestScheduleLib.sol";

// BK Next 2 Ok
import "contracts/Library/MathLib.sol";
import "contracts/zeppelin/SafeMath.sol";

// BK Ok
library RequestLib {
    // BK Next 6 Ok
    using ClaimLib for ClaimLib.ClaimData;
    using ExecutionLib for ExecutionLib.ExecutionData;
    using PaymentLib for PaymentLib.PaymentData;
    using RequestMetaLib for RequestMetaLib.RequestMeta;
    using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;
    using SafeMath for uint;

    // BK Next block Ok
    struct Request {
        ExecutionLib.ExecutionData txnData;
        RequestMetaLib.RequestMeta meta;
        PaymentLib.PaymentData paymentData;
        ClaimLib.ClaimData claimData;
        RequestScheduleLib.ExecutionWindow schedule;
    }

    // BK Next block Ok
    enum AbortReason {
        WasCancelled,       //0
        AlreadyCalled,      //1
        BeforeCallWindow,   //2
        AfterCallWindow,    //3
        ReservedForClaimer, //4
        InsufficientGas,    //5
        MismatchGasPrice    //6
    }

    // BK Next 4 Ok - Events
    event Aborted(uint8 reason);
    event Cancelled(uint rewardPayment, uint measuredGasConsumption);
    event Claimed();
    event Executed(uint bounty, uint fee, uint measuredGasConsumption);

    /**
     * @dev Validate the initialization parameters of a transaction request.
     */
    // BK Ok - Called by RequestFactory.validateRequestParams(...)
    function validate(
        address[4]  _addressArgs,
        uint[12]    _uintArgs,
        uint        _endowment
    ) 
        public view returns (bool[6] isValid)
    {
        // The order of these errors matters as it determines which
        // ValidationError event codes are logged when validation fails.
        // BK NOTE - _uintArgs [1]    -  paymentData.bounty
        // BK NOTE - _uintArgs [0]    -  paymentData.fee
        // BK NOTE - _uintArgs [8]    -  txnData.callGas
        // BK NOTE - _uintArgs [9]    -  txnData.callValue
        // BK NOTE - _uintArgs [10]   -  txnData.gasPrice
        // BK NOTE - Validate _endowment >= (_bounty + _fee + (_callGas x _gasPrice) + (_gasOverhead x _gasPrice) + _callValue)
        // BK NOTE - Validate _endowment >= (paymentData.bounty + paymentData.fee + (txnData.callGas x txnData.gasPrice)
        // BK NOTE -                        + (EXECUTION_GAS_OVERHEAD x txnData.gasPrice) + txnData.callValue)
        // BK Ok
        isValid[0] = PaymentLib.validateEndowment(
            _endowment,
            _uintArgs[1],               //bounty
            _uintArgs[0],               //fee
            _uintArgs[8],               //callGas
            _uintArgs[9],               //callValue
            _uintArgs[10],              //gasPrice
            EXECUTION_GAS_OVERHEAD
        );
        // BK NOTE - _uintArgs [4]    -  schedule.reservedWindowSize
        // BK NOTE - _uintArgs [6]    -  schedule.windowSize
        // BK Ok - Validate schedule.reservedWindowSize <= schedule.windowSize
        isValid[1] = RequestScheduleLib.validateReservedWindowSize(
            _uintArgs[4],               //reservedWindowSize
            _uintArgs[6]                //windowSize
        );
        // BK NOTE - TemporalUnit 0=Null, 1=Blocks, 2=Timestamp
        // BK NOTE - _uintArgs [5]    -  schedule.temporalUnit
        // BK Ok - Validate that schedule.temporalUnit == 1 or 2
        isValid[2] = RequestScheduleLib.validateTemporalUnit(_uintArgs[5]);
        // BK NOTE - TemporalUnit 0=Null, 1=Blocks, 2=Timestamp
        // BK NOTE - _uintArgs [5]    -  schedule.temporalUnit
        // BK NOTE - _uintArgs [3]    -  schedule.freezePeriod
        // BK NOTE - _uintArgs [7]    -  schedule.windowStart
        // BK Ok - Validate that now + schedule.freezePeriod <= schedule.windowStart
        isValid[3] = RequestScheduleLib.validateWindowStart(
            RequestScheduleLib.TemporalUnit(MathLib.min(_uintArgs[5], 2)),
            _uintArgs[3],               //freezePeriod
            _uintArgs[7]                //windowStart
        );
        // BK NOTE - _uintArgs [8]    -  txnData.callGas
        // BK Ok - Validate that txnData.callGas is < blockGasLimit - EXECUTION_GAS_OVERHEAD
        isValid[4] = ExecutionLib.validateCallGas(
            _uintArgs[8],               //callGas
            EXECUTION_GAS_OVERHEAD
        );
        // BK Ok - Validate that txnData.toAddress != 0x0
        isValid[5] = ExecutionLib.validateToAddress(_addressArgs[3]);

        // BK Ok
        return isValid;
    }

    /**
     * @dev Initialize a new Request.
     */
    // BK NOTE - From TransactionRequestCore.initialize(...):
    // BK NOTE - addressArgs[0] - meta.createdBy
    // BK NOTE - addressArgs[1] - meta.owner
    // BK NOTE - addressArgs[2] - paymentData.feeRecipient
    // BK NOTE - addressArgs[3] - txnData.toAddress
    // BK NOTE - 
    // BK NOTE - uintArgs[0]  - paymentData.fee
    // BK NOTE - uintArgs[1]  - paymentData.bounty
    // BK NOTE - uintArgs[2]  - schedule.claimWindowSize
    // BK NOTE - uintArgs[3]  - schedule.freezePeriod
    // BK NOTE - uintArgs[4]  - schedule.reservedWindowSize
    // BK NOTE - uintArgs[5]  - schedule.temporalUnit
    // BK NOTE - uintArgs[7]  - schedule.executionWindowSize
    // BK NOTE - uintArgs[6]  - schedule.windowStart
    // BK NOTE - uintArgs[8]  - txnData.callGas
    // BK NOTE - uintArgs[9]  - txnData.callValue
    // BK NOTE - uintArgs[10] - txnData.gasPrice
    // BK NOTE - uintArgs[11] - claimData.requiredDeposit
    // BK NOTE -
    // BK Ok - Only called by TransactionRequestCore.initialize(...)
    function initialize(
        Request storage self,
        address[4]      _addressArgs,
        uint[12]        _uintArgs,
        bytes           _callData
    ) 
        public returns (bool)
    {
        address[6] memory addressValues = [
            // BK Ok - claimData.claimedBy is set in ClaimLib.claim(...)
            0x0,                // self.claimData.claimedBy
            // BK Ok - addressArgs[0] - meta.createdBy
            _addressArgs[0],    // self.meta.createdBy
            // BK Ok - addressArgs[1] - meta.owner
            _addressArgs[1],    // self.meta.owner
            // BK Ok - addressArgs[2] - paymentData.feeRecipient
            _addressArgs[2],    // self.paymentData.feeRecipient
            // BK Ok - paymentData.bountyBenefactor is set in execute(...) below
            0x0,                // self.paymentData.bountyBenefactor
            // BK Ok - addressArgs[3] - txnData.toAddress
            _addressArgs[3]     // self.txnData.toAddress
        ];

        // BK NOTE - From deserialize(...) below:
        // BK NOTE - self.meta.isCancelled = _boolValues[0];
        // BK NOTE - self.meta.wasCalled = _boolValues[1];
        // BK NOTE - self.meta.wasSuccessful = _boolValues[2];
        bool[3] memory boolValues = [false, false, false];

        // BK NOTE - From deserialize(...) below:
        // BK NOTE - self.claimData.claimDeposit = _uintValues[0];
        // BK NOTE - self.paymentData.fee = _uintValues[1];
        // BK NOTE - self.paymentData.feeOwed = _uintValues[2];
        // BK NOTE - self.paymentData.bounty = _uintValues[3];
        // BK NOTE - self.paymentData.bountyOwed = _uintValues[4];
        // BK NOTE - self.schedule.claimWindowSize = _uintValues[5];
        // BK NOTE - self.schedule.freezePeriod = _uintValues[6];
        // BK NOTE - self.schedule.reservedWindowSize = _uintValues[7];
        // BK NOTE - self.schedule.temporalUnit = RequestScheduleLib.TemporalUnit(_uintValues[8]);
        // BK NOTE - self.schedule.windowSize = _uintValues[9];
        // BK NOTE - self.schedule.windowStart = _uintValues[10];
        // BK NOTE - self.txnData.callGas = _uintValues[11];
        // BK NOTE - self.txnData.callValue = _uintValues[12];
        // BK NOTE - self.txnData.gasPrice = _uintValues[13];
        // BK NOTE - self.claimData.requiredDeposit = _uintValues[14];
        uint[15] memory uintValues = [
            // BK Ok - claimData.claimDeposit is set in ClaimLib.claim(...)
            // BK Ok - Dest self.claimData.claimDeposit = _uintValues[0];
            0,                  // self.claimData.claimDeposit
            // BK Ok - Source uintArgs[0]  - paymentData.fee
            // BK Ok - Dest self.paymentData.fee = _uintValues[1];
            _uintArgs[0],       // self.paymentData.fee
            // BK Ok - paymentData.feeOwed set in deserialize(...) and execute(...) below
            // BK Ok - Dest self.paymentData.feeOwed = _uintValues[2];
            0,                  // self.paymentData.feeOwed
            // BK Ok - Source uintArgs[1]  - paymentData.bounty
            // BK Ok - Dest self.paymentData.bounty = _uintValues[3];
            _uintArgs[1],       // self.paymentData.bounty
            // BK Ok - paymentData.bountyOwed set in deserialize(...) and execute(...) below
            // BK Ok - Dest self.paymentData.bountyOwed = _uintValues[4];
            0,                  // self.paymentData.bountyOwed
            // BK Ok - Source uintArgs[2]  - schedule.claimWindowSize
            // BK Ok - Dest self.schedule.claimWindowSize = _uintValues[5];
            _uintArgs[2],       // self.schedule.claimWindowSize
            // BK Ok - Source uintArgs[3]  - schedule.freezePeriod
            // BK Ok - Dest self.schedule.freezePeriod = _uintValues[6];
            _uintArgs[3],       // self.schedule.freezePeriod
            // BK Ok - Source uintArgs[4]  - schedule.reservedWindowSize
            // BK Ok - Dest self.schedule.reservedWindowSize = _uintValues[7];
            _uintArgs[4],       // self.schedule.reservedWindowSize
            // BK Ok - Source uintArgs[5]  - schedule.temporalUnit
            // BK Ok - Dest self.schedule.temporalUnit = RequestScheduleLib.TemporalUnit(_uintValues[8]);
            _uintArgs[5],       // self.schedule.temporalUnit
            // BK Ok - Source uintArgs[7]  - schedule.executionWindowSize
            // BK NOTE - uintArgs[7] in the previous line should be uintArgs[6]
            // BK Ok - Dest self.schedule.windowSize = _uintValues[9];
            _uintArgs[6],       // self.schedule.windowSize
            // BK Ok - Source uintArgs[6]  - schedule.windowStart
            // BK NOTE - uintArgs[6] in the previous line should be uintArgs[7]
            // BK Ok - Dest self.schedule.windowStart = _uintValues[10];
            _uintArgs[7],       // self.schedule.windowStart
            // BK Ok - Source uintArgs[8]  - txnData.callGas
            // BK Ok - Dest self.txnData.callGas = _uintValues[11];
            _uintArgs[8],       // self.txnData.callGas
            // BK Ok - Source uintArgs[9]  - txnData.callValue
            // BK Ok - Dest self.txnData.callValue = _uintValues[12];
            _uintArgs[9],       // self.txnData.callValue
            // BK Ok - Source uintArgs[10] - txnData.gasPrice
            // BK Ok - Dest self.txnData.gasPrice = _uintValues[13];
            _uintArgs[10],      // self.txnData.gasPrice
            // BK Ok - Source uintArgs[11] - claimData.requiredDeposit
            // BK Ok - Dest self.claimData.requiredDeposit = _uintValues[14];
            _uintArgs[11]       // self.claimData.requiredDeposit
        ];

        // BK Ok - paymentModifier
        uint8[1] memory uint8Values = [
            0
        ];

        // BK Ok
        require(deserialize(self, addressValues, boolValues, uintValues, uint8Values, _callData));

        // BK Ok
        return true;
    }
 
    // BK Ok - View function
    function serialize(Request storage self)
        internal view returns(address[6], bool[3], uint[15], uint8[1])
    {
        // BK Next block Ok
        address[6] memory addressValues = [
            self.claimData.claimedBy,
            self.meta.createdBy,
            self.meta.owner,
            self.paymentData.feeRecipient,
            self.paymentData.bountyBenefactor,
            self.txnData.toAddress
        ];

        // BK Next block Ok
        bool[3] memory boolValues = [
            self.meta.isCancelled,
            self.meta.wasCalled,
            self.meta.wasSuccessful
        ];

        // BK Next block Ok
        uint[15] memory uintValues = [
            self.claimData.claimDeposit,
            self.paymentData.fee,
            self.paymentData.feeOwed,
            self.paymentData.bounty,
            self.paymentData.bountyOwed,
            self.schedule.claimWindowSize,
            self.schedule.freezePeriod,
            self.schedule.reservedWindowSize,
            uint(self.schedule.temporalUnit),
            self.schedule.windowSize,
            self.schedule.windowStart,
            self.txnData.callGas,
            self.txnData.callValue,
            self.txnData.gasPrice,
            self.claimData.requiredDeposit
        ];

        // BK Next block Ok
        uint8[1] memory uint8Values = [
            self.claimData.paymentModifier
        ];

        // BK Ok
        return (addressValues, boolValues, uintValues, uint8Values);
    }

    /**
     * @dev Populates a Request object from the full output of `serialize`.
     *
     *  Parameter order is alphabetical by type, then namespace, then name.
     */
    // BK Ok - Internal function
    function deserialize(
        Request storage self,
        address[6]  _addressValues,
        bool[3]     _boolValues,
        uint[15]    _uintValues,
        uint8[1]    _uint8Values,
        bytes       _callData
    )
        internal returns (bool)
    {
        // callData is special.
        // BK Ok
        self.txnData.callData = _callData;

        // Address values
        // BK Next block Ok
        self.claimData.claimedBy = _addressValues[0];
        self.meta.createdBy = _addressValues[1];
        self.meta.owner = _addressValues[2];
        self.paymentData.feeRecipient = _addressValues[3];
        self.paymentData.bountyBenefactor = _addressValues[4];
        self.txnData.toAddress = _addressValues[5];

        // Boolean values
        // BK Next block Ok
        self.meta.isCancelled = _boolValues[0];
        self.meta.wasCalled = _boolValues[1];
        self.meta.wasSuccessful = _boolValues[2];

        // UInt values
        // BK Next block Ok
        self.claimData.claimDeposit = _uintValues[0];
        self.paymentData.fee = _uintValues[1];
        self.paymentData.feeOwed = _uintValues[2];
        self.paymentData.bounty = _uintValues[3];
        self.paymentData.bountyOwed = _uintValues[4];
        self.schedule.claimWindowSize = _uintValues[5];
        self.schedule.freezePeriod = _uintValues[6];
        self.schedule.reservedWindowSize = _uintValues[7];
        self.schedule.temporalUnit = RequestScheduleLib.TemporalUnit(_uintValues[8]);
        self.schedule.windowSize = _uintValues[9];
        self.schedule.windowStart = _uintValues[10];
        self.txnData.callGas = _uintValues[11];
        self.txnData.callValue = _uintValues[12];
        self.txnData.gasPrice = _uintValues[13];
        self.claimData.requiredDeposit = _uintValues[14];

        // Uint8 values
        // BK Ok
        self.claimData.paymentModifier = _uint8Values[0];

        // BK Ok
        return true;
    }

    // BK Ok
    function execute(Request storage self) 
        internal returns (bool)
    {
        /*
         *  Execute the TransactionRequest
         *
         *  +---------------------+
         *  | Phase 1: Validation |
         *  +---------------------+
         *
         *  Must pass all of the following checks:
         *
         *  1. Not already called.
         *  2. Not cancelled.
         *  3. Not before the execution window.
         *  4. Not after the execution window.
         *  5. if (claimedBy == 0x0 or msg.sender == claimedBy):
         *         - windowStart <= block.number
         *         - block.number <= windowStart + windowSize
         *     else if (msg.sender != claimedBy):
         *         - windowStart + reservedWindowSize <= block.number
         *         - block.number <= windowStart + windowSize
         *     else:
         *         - throw (should be impossible)
         *  
         *  6. gasleft() == callGas
         *
         *  +--------------------+
         *  | Phase 2: Execution |
         *  +--------------------+
         *
         *  1. Mark as called (must be before actual execution to prevent
         *     re-entrance)
         *  2. Send Transaction and record success or failure.
         *
         *  +---------------------+
         *  | Phase 3: Accounting |
         *  +---------------------+
         *
         *  1. Calculate and send fee amount.
         *  2. Calculate and send bounty amount.
         *  3. Send remaining ether back to owner.
         *
         */

        // Record the gas at the beginning of the transaction so we can
        // calculate how much has been used later.
        // BK Ok
        uint startGas = gasleft();

        // +----------------------+
        // | Begin: Authorization |
        // +----------------------+

        // BK Ok - Tx has sufficient gas
        if (gasleft() < requiredExecutionGas(self).sub(PRE_EXECUTION_GAS)) {
            // BK Ok - Log event
            emit Aborted(uint8(AbortReason.InsufficientGas));
            // BK Ok
            return false;
        // BK Ok - Not already called
        } else if (self.meta.wasCalled) {
            // BK Ok - Log event
            emit Aborted(uint8(AbortReason.AlreadyCalled));
            // BK Ok
            return false;
        // BK Ok - Not cancelled
        } else if (self.meta.isCancelled) {
            // BK Ok - Log event
            emit Aborted(uint8(AbortReason.WasCancelled));
            // BK Ok
            return false;
        // BK Ok - Must be in execution window
        } else if (self.schedule.isBeforeWindow()) {
            // BK Ok - Log event
            emit Aborted(uint8(AbortReason.BeforeCallWindow));
            // BK Ok
            return false;
        // BK Ok - Must be in execution window
        } else if (self.schedule.isAfterWindow()) {
            // BK Ok - Log event
            emit Aborted(uint8(AbortReason.AfterCallWindow));
            // BK Ok
            return false;
        // BK Ok - If claimed, tx must be from claimant and execution must be in the reserve window 
        } else if (self.claimData.isClaimed() && msg.sender != self.claimData.claimedBy && self.schedule.inReservedWindow()) {
            // BK Ok - Log event
            emit Aborted(uint8(AbortReason.ReservedForClaimer));
            // BK Ok
            return false;
        // BK Ok - Tx gasPrice must match scheduled gasPrice 
        } else if (self.txnData.gasPrice != tx.gasprice) {
            // BK Ok - Log event
            emit Aborted(uint8(AbortReason.MismatchGasPrice));
            // BK Ok
            return false;
        }

        // +--------------------+
        // | End: Authorization |
        // +--------------------+
        // +------------------+
        // | Begin: Execution |
        // +------------------+

        // Mark as being called before sending transaction to prevent re-entrance.
        // BK Ok
        self.meta.wasCalled = true;

        // Send the transaction...
        // The transaction is allowed to fail and the executing agent will still get the bounty.
        // `.sendTransaction()` will return false on a failed exeuction.
        // BK Ok 
        self.meta.wasSuccessful = self.txnData.sendTransaction();

        // +----------------+
        // | End: Execution |
        // +----------------+
        // +-------------------+
        // | Begin: Accounting |
        // +-------------------+

        // Compute the fee amount
        // BK Ok - self.feeRecipient != 0x0
        if (self.paymentData.hasFeeRecipient()) {
            // BK Ok
            self.paymentData.feeOwed = self.paymentData.getFee()
                .add(self.paymentData.feeOwed);
        }

        // Record this locally so that we can log it later.
        // `.sendFee()` below will change `self.paymentData.feeOwed` to 0 to prevent re-entrance.
        // BK Ok
        uint totalFeePayment = self.paymentData.feeOwed;

        // Send the fee. This transaction may also fail but can be called again after
        // execution.
        // BK Ok - feeRecipient <> 0x0 for feeOwed > 0 from logic above
        self.paymentData.sendFee();

        // Compute the bounty amount.
        // BK Ok
        self.paymentData.bountyBenefactor = msg.sender;
        // BK Ok
        if (self.claimData.isClaimed()) {
            // If the transaction request was claimed, we add the deposit to the bounty whether
            // or not the same agent who claimed is executing.
            // BK Ok
            self.paymentData.bountyOwed = self.claimData.claimDeposit
                .add(self.paymentData.bountyOwed);
            // To prevent re-entrance we zero out the claim deposit since it is now accounted for
            // in the bounty value.
            // BK Ok
            self.claimData.claimDeposit = 0;
            // Depending on when the transaction request was claimed, we apply the modifier to the
            // bounty payment and add it to the bounty already owed.
            // BK Ok
            self.paymentData.bountyOwed = self.paymentData.getBountyWithModifier(self.claimData.paymentModifier)
                .add(self.paymentData.bountyOwed);
        // BK Ok
        } else {
            // Not claimed. Just add the full bounty.
            // BK Ok
            self.paymentData.bountyOwed = self.paymentData.getBounty().add(self.paymentData.bountyOwed);
        }

        // Take down the amount of gas used so far in execution to compensate the executing agent.
        // BK Ok
        uint measuredGasConsumption = startGas.sub(gasleft()).add(EXECUTE_EXTRA_GAS);

        // // +----------------------------------------------------------------------+
        // // | NOTE: All code after this must be accounted for by EXECUTE_EXTRA_GAS |
        // // +----------------------------------------------------------------------+

        // Add the gas reimbursment amount to the bounty.
        // BK Ok
        self.paymentData.bountyOwed = measuredGasConsumption
            .mul(tx.gasprice)
            .add(self.paymentData.bountyOwed);

        // Log the bounty and fee. Otherwise it is non-trivial to figure
        // out how much was payed.
        // BK Ok - Log event
        emit Executed(self.paymentData.bountyOwed, totalFeePayment, measuredGasConsumption);
    
        // Attempt to send the bounty. as with `.sendFee()` it may fail and need to be caled after execution.
        // BK Ok
        self.paymentData.sendBounty();

        // If any ether is left, send it back to the owner of the transaction request.
        // BK Ok
        _sendOwnerEther(self, self.meta.owner);

        // +-----------------+
        // | End: Accounting |
        // +-----------------+
        // Successful
        // BK Ok
        return true;
    }


    // This is the amount of gas that it takes to enter from the
    // `TransactionRequest.execute()` contract into the `RequestLib.execute()`
    // method at the point where the gas check happens.
    // BK Ok
    uint public constant PRE_EXECUTION_GAS = 25000;   // TODO is this number still accurate?
    
    /*
     * The amount of gas needed to complete the execute method after
     * the transaction has been sent.
     */
    // BK Ok
    uint public constant EXECUTION_GAS_OVERHEAD = 180000; // TODO check accuracy of this number
    /*
     *  The amount of gas used by the portion of the `execute` function
     *  that cannot be accounted for via gas tracking.
     */
    // BK Ok
    uint public constant  EXECUTE_EXTRA_GAS = 90000; // again, check for accuracy... Doubled this from Piper's original - Logan

    /*
     *  Constant value to account for the gas usage that cannot be accounted
     *  for using gas-tracking within the `cancel` function.
     */
    // BK Ok
    uint public constant CANCEL_EXTRA_GAS = 85000; // Check accuracy

    // BK Ok - View function
    function getEXECUTION_GAS_OVERHEAD()
        public view returns (uint)
    {
        // BK Ok
        return EXECUTION_GAS_OVERHEAD;
    }
    
    // BK Ok - View function
    function requiredExecutionGas(Request storage self) 
        public view returns (uint requiredGas)
    {
        // BK Ok
        requiredGas = self.txnData.callGas.add(EXECUTION_GAS_OVERHEAD);
    }

    /*
     * @dev Performs the checks to see if a request can be cancelled.
     *  Must satisfy the following conditions.
     *
     *  1. Not Cancelled
     *  2. either:
     *    * not wasCalled && afterExecutionWindow
     *    * not claimed && beforeFreezeWindow && msg.sender == owner
     */
    // BK NOTE - True if not cancelled AND has not been called and after the execution window AND not claimed before the freeze period and owner executing
    // BK Ok - View function 
    function isCancellable(Request storage self) 
        public view returns (bool)
    {
        // BK Ok
        if (self.meta.isCancelled) {
            // already cancelled!
            // BK Ok
            return false;
        // BK Ok
        } else if (!self.meta.wasCalled && self.schedule.isAfterWindow()) {
            // not called but after the window
            // BK Ok
            return true;
        // BK Ok
        } else if (!self.claimData.isClaimed() && self.schedule.isBeforeFreeze() && msg.sender == self.meta.owner) {
            // not claimed and before freezePeriod and owner is cancelling
            // BK Ok
            return true;
        // BK Ok
        } else {
            // otherwise cannot cancel
            // BK Ok
            return false;
        }
    }

    /*
     *  Cancel the transaction request, attempting to send all appropriate
     *  refunds.  To incentivise cancellation by other parties, a small reward
     *  payment is issued to the party that cancels the request if they are not
     *  the owner.
     */
    // BK Ok
    function cancel(Request storage self) 
        public returns (bool)
    {
        // BK Ok
        uint startGas = gasleft();
        // BK Next 2 Ok
        uint rewardPayment;
        uint measuredGasConsumption;

        // Checks if this transactionRequest can be cancelled.
        // BK Ok
        require(isCancellable(self));

        // Set here to prevent re-entrance attacks.
        // BK Ok
        self.meta.isCancelled = true;

        // Refund the claim deposit (if there is one)
        // BK Ok
        require(self.claimData.refundDeposit());

        // Send a reward to the cancelling agent if they are not the owner.
        // This is to incentivize the cancelling of expired transaction requests.
        // This also guarantees that it is being cancelled after the call window
        // since the `isCancellable()` function checks this.
        // BK Ok
        if (msg.sender != self.meta.owner) {
            // Create the rewardBenefactor
            // BK Ok
            address rewardBenefactor = msg.sender;
            // Create the rewardOwed variable, it is one-hundredth
            // of the bounty.
            // BK Ok
            uint rewardOwed = self.paymentData.bountyOwed
                .add(self.paymentData.bounty.div(100));

            // Calculate the amount of gas cancelling agent used in this transaction.
            // BK Ok
            measuredGasConsumption = startGas
                .sub(gasleft())
                .add(CANCEL_EXTRA_GAS);
            // Add their gas fees to the reward.W
            // BK Ok
            rewardOwed = measuredGasConsumption
                .mul(tx.gasprice)
                .add(rewardOwed);

            // Take note of the rewardPayment to log it.
            // BK Ok
            rewardPayment = rewardOwed;

            // Transfers the rewardPayment.
            // BK Ok
            if (rewardOwed > 0) {
                // BK Ok
                self.paymentData.bountyOwed = 0;
                // BK Ok - Limited to 2,300 gas, false return status throws an error
                rewardBenefactor.transfer(rewardOwed);
            }
        }

        // Log it!
        // BK Ok - Log event
        emit Cancelled(rewardPayment, measuredGasConsumption);

        // Send the remaining ether to the owner.
        // BK Ok
        return sendOwnerEther(self);
    }

    /*
     * @dev Performs some checks to verify that a transaction request is claimable.
     * @param self The Request object.
     */
    // BK Ok - View function
    function isClaimable(Request storage self) 
        internal view returns (bool)
    {
        // Require not claimed and not cancelled.
        // BK Ok - Not claimed yet
        require(!self.claimData.isClaimed());
        // BK Ok - Not cancelled
        require(!self.meta.isCancelled);

        // Require that it's in the claim window and the value sent is over the required deposit.
        // BK Ok - In claim window
        require(self.schedule.inClaimWindow());
        // BK Ok - ETH sent > required deposit
        require(msg.value >= self.claimData.requiredDeposit);
        // BK Ok
        return true;
    }

    /*
     * @dev Claims the request.
     * @param self The Request object.
     * Payable because it requires the sender to send enough ether to cover the claimDeposit.
     */
    // BK Ok - Any account can execute if not claimed yet, not cancelled, in claim window and minimum ETH sent
    function claim(Request storage self) 
        internal returns (bool claimed)
    {
        // BK Ok
        require(isClaimable(self));

        // BK Ok
        self.claimData.claim(self.schedule.computePaymentModifier());
        // BK Ok - Log event
        emit Claimed();
        // BK Ok
        claimed = true;
    }

    /*
     * @dev Refund claimer deposit.
     */
    // BK Ok - Any account can execute if cancelled or after the execution window, but refund only paid to claimData.claimedBy account
    function refundClaimDeposit(Request storage self)
        public returns (bool)
    {
        // BK Ok
        require(self.meta.isCancelled || self.schedule.isAfterWindow());
        // BK Ok
        return self.claimData.refundDeposit();
    }

    /*
     * Send fee. Wrapper over the real function that perform an extra
     * check to see if it's after the execution window (and thus the first transaction failed)
     */
    // BK Ok - Any account can execute after the execution window, but fee will only be paid to feeRecipient
    function sendFee(Request storage self) 
        public returns (bool)
    {
        // BK Ok
        if (self.schedule.isAfterWindow()) {
            // BK Ok
            return self.paymentData.sendFee();
        }
        // BK Ok
        return false;
    }

    /*
     * Send bounty. Wrapper over the real function that performs an extra
     * check to see if it's after execution window (and thus the first transaction failed)
     */
    // BK Ok - Any account can execute after the execution window, but bounty will only be paid to bountyBenefactor
    function sendBounty(Request storage self) 
        public returns (bool)
    {
        /// check wasCalled
        // BK Ok
        if (self.schedule.isAfterWindow()) {
            // BK Ok
            return self.paymentData.sendBounty();
        }
        // BK Ok
        return false;
    }

    // BK Ok - Public view function, check if cancelled, is after execution window or was called
    function canSendOwnerEther(Request storage self) 
        public view returns(bool) 
    {
        // BK Ok
        return self.meta.isCancelled || self.schedule.isAfterWindow() || self.meta.wasCalled;
    }

    /**
     * Send owner ether. Wrapper over the real function that performs an extra 
     * check to see if it's after execution window (and thus the first transaction failed)
     */
    // BK Ok - Only owner can execute, if (cancelled or after execution window or has been called)
    function sendOwnerEther(Request storage self, address recipient)
        public returns (bool)
    {
        // BK Ok
        require(recipient != 0x0);
        // BK Ok
        if(canSendOwnerEther(self) && msg.sender == self.meta.owner) {
            // BK Ok
            return _sendOwnerEther(self, recipient);
        }
        // BK Ok
        return false;
    }

    /**
     * Send owner ether. Wrapper over the real function that performs an extra 
     * check to see if it's after execution window (and thus the first transaction failed)
     */
    // BK Ok - Only owner can execute, if (cancelled or after execution window or has been called)
    function sendOwnerEther(Request storage self)
        public returns (bool)
    {
        // BK Ok
        if(canSendOwnerEther(self)) {
            // BK Ok
            return _sendOwnerEther(self, self.meta.owner);
        }
        // BK Ok
        return false;
    }

    // BK Ok - Private function, called by 2 x sendOwnerEther(...) above and execute(...) above
    function _sendOwnerEther(Request storage self, address recipient) 
        private returns (bool)
    {
        // Note! This does not do any checks since it is used in the execute function.
        // The public version of the function should be used for checks and in the cancel function.
        // BK NOTE - ownerRefund = contract ETH balance - claimDeposit - bountyOwed - feeOwed 
        // BK Ok
        uint ownerRefund = address(this).balance
            .sub(self.claimData.claimDeposit)
            .sub(self.paymentData.bountyOwed)
            .sub(self.paymentData.feeOwed);
        /* solium-disable security/no-send */
        // BK Ok
        return recipient.send(ownerRefund);
    }
}
```