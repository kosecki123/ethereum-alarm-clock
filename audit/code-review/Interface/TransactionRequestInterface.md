# TransactionRequestInterface

Source file [../../../contracts/Interface/TransactionRequestInterface.sol](../../../contracts/Interface/TransactionRequestInterface.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Ok
contract TransactionRequestInterface {
    
    // Primary actions
    // BK Ok - Matches TransactionRequestCore.execute()
    function execute() public returns (bool);
    // BK Ok - Matches TransactionRequestCore.cancel()
    function cancel() public returns (bool);
    // BK Ok - Matches TransactionRequestCore.claim()
    function claim() public payable returns (bool);

    // Proxy function
    // BK Ok - Matches TransactionRequestCore.proxy(...), where recipient = _to
    function proxy(address recipient, bytes callData) public payable returns (bool);

    // Data accessors
    // BK Ok - Matches TransactionRequestCore.requestData()
    function requestData() public view returns (address[6], bool[3], uint[15], uint8[1]);
    // BK Ok - Matches TransactionRequestCore.callData()
    function callData() public view returns (bytes);

    // Pull mechanisms for payments.
    // BK Ok - Matches TransactionRequestCore.refundClaimDeposit()
    function refundClaimDeposit() public returns (bool);
    // BK Ok - Matches TransactionRequestCore.sendFee()
    function sendFee() public returns (bool);
    // BK Ok - Matches TransactionRequestCore.sendBounty()
    function sendBounty() public returns (bool);
    // BK Ok - Matches TransactionRequestCore.sendOwnerEther()
    function sendOwnerEther() public returns (bool);
    // BK Ok - Matches TransactionRequestCore.sendOwnerEther(...)
    function sendOwnerEther(address recipient) public returns (bool);
}

```
