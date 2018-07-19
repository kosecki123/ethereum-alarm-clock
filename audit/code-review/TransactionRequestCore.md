# TransactionRequestCore

Source file [../../contracts/TransactionRequestCore.sol](../../contracts/TransactionRequestCore.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Next 3 Ok
import "contracts/Library/RequestLib.sol";
import "contracts/Library/RequestScheduleLib.sol";
import "contracts/Interface/TransactionRequestInterface.sol";

// BK Ok
contract TransactionRequestCore is TransactionRequestInterface {
    // BK Ok
    using RequestLib for RequestLib.Request;
    // BK Ok
    using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;

    // BK Ok
    RequestLib.Request txnRequest;
    // BK Ok
    bool private initialized = false;

    /*
     *  addressArgs[0] - meta.createdBy
     *  addressArgs[1] - meta.owner
     *  addressArgs[2] - paymentData.feeRecipient
     *  addressArgs[3] - txnData.toAddress
     *
     *  uintArgs[0]  - paymentData.fee
     *  uintArgs[1]  - paymentData.bounty
     *  uintArgs[2]  - schedule.claimWindowSize
     *  uintArgs[3]  - schedule.freezePeriod
     *  uintArgs[4]  - schedule.reservedWindowSize
     *  uintArgs[5]  - schedule.temporalUnit
     *  uintArgs[7]  - schedule.executionWindowSize
     *  uintArgs[6]  - schedule.windowStart
     *  uintArgs[8]  - txnData.callGas
     *  uintArgs[9]  - txnData.callValue
     *  uintArgs[10] - txnData.gasPrice
     *  uintArgs[11] - claimData.requiredDeposit
     */
    // BK NOTE - The index number for uintArgs[7] should be swapped with uintArgs[6] in the comment above
    // BK Ok - Called by RequestFactory.createRequest(...) that is called by RequestFactory.createValidatedRequest(...) that is called by BaseScheduler.schedule(...)
    function initialize(
        address[4]  addressArgs,
        uint[12]    uintArgs,
        bytes       callData
    )
        public payable
    {
        // BK Ok
        require(!initialized);

        txnRequest.initialize(addressArgs, uintArgs, callData);
        // BK Ok
        initialized = true;
    }

    /*
     *  Allow receiving ether.  This is needed if there is a large increase in
     *  network gas prices.
     */
    // BK Ok - Accept ETH
    function() public payable {}

    /*
     *  Actions
     */
    // BK Ok - Permissioning in RequestLib.execute(...)
    function execute() public returns (bool) {
        // BK Ok
        return txnRequest.execute();
    }

    // BK Ok - Permissioning in RequestLib.cancel(...)
    function cancel() public returns (bool) {
        // BK Ok
        return txnRequest.cancel();
    }

    // BK Ok - Permissioning in RequestLib.claim(...)
    function claim() public payable returns (bool) {
        // BK Ok
        return txnRequest.claim();
    }

    /*
     *  Data accessor functions.
     */

    // Declaring this function `view`, although it creates a compiler warning, is
    // necessary to return values from it.
    // BK Ok - View function
    function requestData()
        public view returns (address[6], bool[3], uint[15], uint8[1])
    {
        // BK Ok
        return txnRequest.serialize();
    }

    // BK Ok - View function
    function callData()
        public view returns (bytes data)
    {
        // BK Ok
        data = txnRequest.txnData.callData;
    }

    /**
     * @dev Proxy a call from this contract to another contract.
     * This function is only callable by the scheduler and can only
     * be called after the execution window ends. One purpose is to
     * provide a way to transfer assets held by this contract somewhere else.
     * For example, if this request was used to buy tokens during an ICO,
     * it would become the owner of the tokens and this function would need
     * to be called with the encoded data to the token contract to transfer
     * the assets somewhere else. */
    // BK Ok - Only owner account can execute after execution window
    function proxy(address _to, bytes _data)
        public payable returns (bool success)
    {
        // BK Ok
        require(txnRequest.meta.owner == msg.sender && txnRequest.schedule.isAfterWindow());
        
        /* solium-disable-next-line */
        // BK Ok
        return _to.call.value(msg.value)(_data);
    }

    /*
     *  Pull based payment functions.
     */
    // BK Ok - Permissioning in RequestLib.refundClaimDeposit(...), can be executed if cancelled or after the execution window
    function refundClaimDeposit() public returns (bool) {
        // BK Ok
        txnRequest.refundClaimDeposit();
    }

    // BK Ok - Permissioning in RequestLib.sendFee(...), can only be executed after the execution window
    function sendFee() public returns (bool) {
        // BK Ok
        return txnRequest.sendFee();
    }

    // BK Ok - Permissioning in RequestLib.sendBounty(...), can only be executed after the execution window
    function sendBounty() public returns (bool) {
        // BK Ok
        return txnRequest.sendBounty();
    }

    // BK Ok - Permissioning in RequestLib.sendOwnerEther(...), can only be executed by owner if cancelled, after execution window or has been called
    function sendOwnerEther() public returns (bool) {
        // BK Ok
        return txnRequest.sendOwnerEther();
    }

    // BK Ok - Permissioning in RequestLib.sendOwnerEther(...), can only be executed by owner if cancelled, after execution window or has been called
    function sendOwnerEther(address recipient) public returns (bool) {
        // BK Ok
        return txnRequest.sendOwnerEther(recipient);
    }
}

```
