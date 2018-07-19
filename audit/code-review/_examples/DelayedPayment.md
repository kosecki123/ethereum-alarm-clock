# DelayedPayment

Source file [../../../contracts/_examples/DelayedPayment.sol](../../../contracts/_examples/DelayedPayment.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Ok
import "contracts/Interface/SchedulerInterface.sol";

/// Example of using the Scheduler from a smart contract to delay a payment.
// BK Ok
contract DelayedPayment {

    // BK Ok
    SchedulerInterface public scheduler;
    
    // BK Next 3 Ok
    uint lockedUntil;
    address recipient;
    address public scheduledTransaction;

    // BK Ok
    function DelayedPayment(
        address _scheduler,
        uint    _numBlocks,
        address _recipient
    )  public payable {
        // BK Next 3 Ok
        scheduler = SchedulerInterface(_scheduler);
        lockedUntil = block.number + _numBlocks;
        recipient = _recipient;

        // BK Ok
        scheduledTransaction = scheduler.schedule.value(0.1 ether)( // 0.1 ether is to pay for gas, bounty and fee
            this,                   // send to self
            "",                     // and trigger fallback function
            [
                200000,             // The amount of gas to be sent with the transaction.
                0,                  // The amount of wei to be sent.
                255,                // The size of the execution window.
                lockedUntil,        // The start of the execution window.
                20000000000 wei,    // The gasprice for the transaction (aka 20 gwei)
                20000000000 wei,    // The fee included in the transaction.
                20000000000 wei,         // The bounty that awards the executor of the transaction.
                30000000000 wei     // The required amount of wei the claimer must send as deposit.
            ]
        );
    }

    // BK Ok
    function () public payable {
        // BK Ok
        if (msg.value > 0) { //this handles recieving remaining funds sent while scheduling (0.1 ether)
            // BK Ok
            return;
        // BK Ok
        } else if (address(this).balance > 0) {
            // BK Ok
            payout();
        // BK Ok
        } else {
            // BK Ok
            revert();
        }
    }

    // BK Ok
    function payout()
        public returns (bool)
    {
        // BK Ok
        require(block.number >= lockedUntil);
        
        // BK Ok
        recipient.transfer(address(this).balance);
        // BK Ok
        return true;
    }
}
```
