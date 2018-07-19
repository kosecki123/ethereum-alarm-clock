# BlockScheduler

Source file [../../../contracts/Scheduler/BlockScheduler.sol](../../../contracts/Scheduler/BlockScheduler.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Next 2 Ok
import "contracts/Library/RequestScheduleLib.sol";
import "contracts/Scheduler/BaseScheduler.sol";

/**
 * @title BlockScheduler
 * @dev Top-level contract that exposes the API to the Ethereum Alarm Clock service and passes in blocks as temporal unit.
 */
// BK Ok
contract BlockScheduler is BaseScheduler {

    /**
     * @dev Constructor
     * @param _factoryAddress Address of the RequestFactory which creates requests for this scheduler.
     */
    // BK Ok
    function BlockScheduler(address _factoryAddress, address _feeRecipient) public {
        // BK Ok
        require(_factoryAddress != 0x0);

        // Default temporal unit is block number.
        // BK Ok
        temporalUnit = RequestScheduleLib.TemporalUnit.Blocks;

        // Sets the factoryAddress variable found in SchedulerInterface contract.
        // BK NOTE: factoryAddress is defined in BaseScheduler and not SchedulerInterface
        // BK Ok
        factoryAddress = _factoryAddress;

        // Sets the fee recipient for these schedulers.
        // BK Ok
        feeRecipient = _feeRecipient;
    }
}

```
