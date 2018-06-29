# SchedulerInterface

Source file [../../../contracts/Interface/SchedulerInterface.sol](../../../contracts/Interface/SchedulerInterface.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

/**
 * @title SchedulerInterface
 * @dev The base contract that the higher contracts: BaseScheduler, BlockScheduler and TimestampScheduler all inherit from.
 */
// BK Ok
contract SchedulerInterface {
    // BK Ok - Matches BaseScheduler.schedule(...)
    function schedule(address _toAddress, bytes _callData, uint[8] _uintArgs)
        public payable returns (address);
    // BK Ok - Matches BaseScheduler.computeEndowment(...)
    function computeEndowment(uint _bounty, uint _fee, uint _callGas, uint _callValue, uint _gasPrice)
        public view returns (uint);
}

```
