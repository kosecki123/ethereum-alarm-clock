# RequestFactoryInterface

Source file [../../../contracts/Interface/RequestFactoryInterface.sol](../../../contracts/Interface/RequestFactoryInterface.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Ok
contract RequestFactoryInterface {
    // BK Ok - Event
    event RequestCreated(address request, address indexed owner, int indexed bucket, uint[12] params);

    // BK Ok - Matches RequestFactory.createRequest(...)
    function createRequest(address[3] addressArgs, uint[12] uintArgs, bytes callData) public payable returns (address);
    // BK Ok - Matches RequestFactory.createValidatedRequest(...)
    function createValidatedRequest(address[3] addressArgs, uint[12] uintArgs, bytes callData) public payable returns (address);
    // BK Ok - Matches RequestFactory.validateRequestParams(...)
    function validateRequestParams(address[3] addressArgs, uint[12] uintArgs, uint endowment) public view returns (bool[6]);
    // BK Ok - Matches RequestFactory.isKnownRequest(...)
    function isKnownRequest(address _address) public view returns (bool);
}

```
