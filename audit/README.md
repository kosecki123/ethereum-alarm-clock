# Ethereum Alarm Clock Smart Contract Audit

Status: Work in progress

## Summary

The Ethereum Alarm Clock (EAC) was originally created by Piper Merriam in 2015. [Chronologic](http://chronologic.network/) have been [working with Piper Merriam to enhance EAC](https://blog.chronologic.network/announcing-the-ethereum-alarm-clock-chronologic-partnership-b3d7545bea3b).

Bok Consulting Pty Ltd was commissioned to perform an audit on the Ethereum smart contracts built for the Ethereum Alarm Clock.

This audit has been conducted on the EAC source code in commits [252a7a9](https://github.com/ethereum-alarm-clock/ethereum-alarm-clock/commit/252a7a92bee984ff25bdb75189b3a4cc9748fadb) and [c3f26bc](https://github.com/ethereum-alarm-clock/ethereum-alarm-clock/commit/c3f26bc20eb902bf8da581df2cfaa21c122ea7a3).

The user interface for testing the EAC smart contracts on the Kovan testnet is at [http://chronologic-dev.s3-website-us-east-1.amazonaws.com/](http://chronologic-dev.s3-website-us-east-1.amazonaws.com/).

The documentation for the EAC is at [https://ethereum-alarm-clock.readthedocs.io/en/latest/index.html](https://ethereum-alarm-clock.readthedocs.io/en/latest/index.html).

No potential vulnerabilities have been identified in the EAC smart contracts.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Issues](#issues)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

* [ ] **LOW IMPORTANCE** *scheduler/BlockScheduler.sol* and *scheduler/TimestampScheduler.sol* both have a comment `// Sets the factoryAddress variable found in SchedulerInterface contract.` but `factoryAddress` is defined in *scheduler/BaseScheduler.sol* and not in the *Interface/SchedulerInterface*. These comments should be updated
* [ ] **LOW IMPORTANCE** The constructors for *RequestFactory.sol*, *Scheduler/BlockScheduler.sol*, *Scheduler/TimestampScheduler.sol* and *_examples/DelayedPayment.sol* should be updated to use the `constructor(...)` keyword introduced in [Solidity 0.4.21](https://github.com/ethereum/solidity/releases/tag/v0.4.22), if any source code is updated
* [ ] **LOW IMPORTANCE** `RequestLib.getEXECUTION_GAS_OVERHEAD()` should be using the `pure` modifier instead of the `view` modifier, if any source code is updated
* [ ] **LOW IMPORTANCE** Events in libraries are not automatically included in the ABI for contracts that call the library. The current workaround is to duplicate the events in the contracts that call the library. One [reference](https://ethereum.stackexchange.com/questions/11137/watching-events-defined-in-libraries). In EAC for example, RequestLib's `Aborted(...)`, `Cancelled(...)`, `Claimed()` and `Executed(...)` events are not available in the ABI for *TransactionRequestCore* - [test/TransactionRequestCore.js#L46](https://github.com/bokkypoobah/EthereumAlarmClockAudit/blob/acd8eeafc2006d7d9cdeb03c9c17d1a43b9a4994/audit/test/TransactionRequestCore.js#L46)
* [ ] **LOW IMPORTANCE** The comments for `PaymentLib.validateEndowment(...)` referring to *maxMultiplier* may be out of date
* [ ] **LOW IMPORTANCE** ClaimLib.claim(...) has a `bool` return status that is not set, and is not used in `RequestLib.claim(...)`
* [ ] **LOW IMPORTANCE** The comment for `RequestScheduleLib.isBeforeClaimWindow(...)` refers to *freeze period* but should refer to *claim period*
* [ ] **LOW IMPORTANCE** *SafeMath* is not used in *ClaimLib*
* [ ] **LOW IMPORTANCE** Note that if there is a input parameter validation error, the `ValidationError(...)` events from *RequestFactory* will never get generated because `BaseScheduler.schedule(...)` will throw an error if the validation fails, and the event logs will not be persisted on the blockchain
* [ ] **LOW IMPORTANCE** The index number for *uintArgs[7]* should be swapped with *uintArgs[6]* in the comment above `TransactionRequestCore.initialize(...)`
* [ ] **MEDIUM IMPORTANCE** Please review the issue below on a residual amount remaining in the *DelayedPayment* contract

<br />

<hr />

## Issues

### Residual Amount Remaining In The DelayedPayment Contract

In my testing [script](test/01_test1.sh) (and the corresponding [results](test/test1results.txt), I have deployed the EAC contracts and used the *DelayedPayment.sol* example with the following parameters:

* The *Schedule Creator* account deploys *DelayedPayment.sol* with `numBlocks` = 20, sending 10 ETH with the payment scheduled to be sent to *Payment Recipient*
* The *Executor* account claims the request, sending 0.1 ETH with the transaction
* The *Executor* account waits the 20 blocks and executes the request

This results in the following table:

```
 # Account                                             EtherBalanceChange                 (Token A) WETH                  (Token B) DAI Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        0.017037202000000000           0.000000000000000000           0.000000000000000000 Account #0 - Miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.011958348000000000           0.000000000000000000           0.000000000000000000 Account #1 - Contract Owner
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976        0.000000020000000000           0.000000000000000000           0.000000000000000000 Account #2 - Fee Recipient
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0      -10.001596498000000000           0.000000000000000000           0.000000000000000000 Account #3 - Schedule Creator
 4 0xa44a08d3f6933c69212114bb66e2df1813651844        9.900000000000000000           0.000000000000000000           0.000000000000000000 Account #4 - Payment Recipient
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea        0.001063783200000000           0.000000000000000000           0.000000000000000000 Account #5 - Executor
...
12 0x8244333e424f27d9992f55be2ab362de4203ef61        0.000000000000000000           0.000000000000000000           0.000000000000000000 MathLib
13 0x60c8e00dafb889136ebd2dc558d0d00a69b7a84b        0.000000000000000000           0.000000000000000000           0.000000000000000000 PaymentLib
14 0x3529089fbacf865e6771ddb8a76ac997963a5393        0.000000000000000000           0.000000000000000000           0.000000000000000000 RequestScheduleLib
15 0xee0ec07598ed3d84fc4ff0ad4a6d70300f79d812        0.000000000000000000           0.000000000000000000           0.000000000000000000 IterTools
16 0xcba3446221eaad5f03a413e070be7978bcf5beb9        0.000000000000000000           0.000000000000000000           0.000000000000000000 RequestLib
17 0xe17585e1e925353038159ca920ff19f47207d0a0        0.000000000000000000           0.000000000000000000           0.000000000000000000 TransactionRequestCore
18 0x44f3bfeccc26c26313d1b5d4448a0b84e45a391b        0.000000000000000000           0.000000000000000000           0.000000000000000000 RequestFactory
19 0xcc8461036413b0fb03a632e408781b40dcd630b4        0.000000000000000000           0.000000000000000000           0.000000000000000000 BlockScheduler
20 0x9f1406f34716517d86b8ba237501a97c19699c39        0.000000000000000000           0.000000000000000000           0.000000000000000000 TimestampScheduler
21 0xb34c33eaf9d9c3c959f095edeb5a247634c98639        0.095453840800000000           0.000000000000000000           0.000000000000000000 DelayedPayment
22 0xa2aa7dfbfcba85660634acfcb39167a7304f7fad        0.000000000000000000           0.000000000000000000           0.000000000000000000 DelayedPaymentRequest
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                                    0.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
```

Note that there is a residual 0.095453840800000000 ETH balance in the DelayedPayment contract.

I've added additional debugging information to *RequestLib* to produce the following output::

```
txRequest.address=0xa2aa7dfbfcba85660634acfcb39167a7304f7fad
  claimData.claimedBy=0xa55a151eb00fded1634d27d1127b4be4627079ea
  meta.createdBy=0xcc8461036413b0fb03a632e408781b40dcd630b4
  meta.owner=0xb34c33eaf9d9c3c959f095edeb5a247634c98639
  paymentData.feeRecipient=0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976
  paymentData.bountyBenefactor=0xa55a151eb00fded1634d27d1127b4be4627079ea
  txnData.toAddress=0xb34c33eaf9d9c3c959f095edeb5a247634c98639
  meta.isCancelled=false
  meta.wasCalled=true
  meta.wasSuccessful=true
  claimData.claimDeposit=0.000000000000000000 0
  paymentData.fee=0.000000020000000000 20000000000
  paymentData.feeOwed=0.000000000000000000 0
  paymentData.bounty=0.000000020000000000 20000000000
  paymentData.bountyOwed=0.000000000000000000 0
  schedule.claimWindowSize=255
  (schedule.firstClaimBlock=18560 = freezeStart-claimWindowSize)
  schedule.freezePeriod=10
  (schedule.freezeStart=18815) = windowStart - freezePeriod
  schedule.reservedWindowSize=16
  (schedule.reservedWindowEnd=18841) = windowStart + reserveWindowSize
  schedule.temporalUnit=1
  schedule.windowSize=255
  schedule.windowStart=18825
  (schedule.windowEnd=19080) = windowStart + windowSize
  txnData.callGas=200000
  txnData.callValue=0
  txnData.gasPrice=0.000000020000000000 20000000000
  claimData.requiredDeposit=0.000000030000000000 30000000000
  claimData.paymentModifier=96
  txnData.callData=0x
txRequest.Executed 0 #18829 {"bounty":"104546139200000000","fee":"20000000000","measuredGasConsumption":"227306"}
txRequest.LogUint 0 #18829 source=execute text=Before sendTransaction - request.balance value=200000000000000000 0.2
txRequest.LogUint 1 #18829 source=execute text=Before sendTransaction - self.txnData.toAddress.balance value=9900000000000000000 9.9
txRequest.LogUint 2 #18829 source=execute text=After sendTransaction - request.balance value=200000000000000000 0.2
txRequest.LogUint 3 #18829 source=execute text=After sendTransaction - self.txnData.toAddress.balance value=0 0
txRequest.LogUint 4 #18829 source=execute text=feeOwed before value=0 0
txRequest.LogUint 5 #18829 source=execute text=getFee() value=20000000000 2e-8
txRequest.LogUint 6 #18829 source=execute text=feeOwed after value=20000000000 2e-8
txRequest.LogUint 7 #18829 source=execute text=bountyOwed before value=100000019200000000 0.1000000192
txRequest.LogUint 8 #18829 source=execute text=bountyOwed after value=104546139200000000 0.1045461392
txRequest.LogUint 9 #18829 source=execute text=Before sendBounty - request.balance value=199999980000000000 0.19999998
txRequest.LogUint 10 #18829 source=execute text=Before sendBounty - self.txnData.toAddress.balance value=0 0
txRequest.LogUint 11 #18829 source=execute text=After sendBounty - request.balance value=95453840800000000 0.0954538408
txRequest.LogUint 12 #18829 source=execute text=After sendBounty - self.txnData.toAddress.balance value=0 0
txRequest.LogUint 13 #18829 source=execute text=After _sendOwnerEther - self.txnData.toAddress.balance value=95453840800000000 0.0954538408
```

This 0.095453840800000000 ETH amount comes from `RequestLib.execute(...)` section:

```javascript
        // Attempt to send the bounty. as with `.sendFee()` it may fail and need to be caled after execution.
        emit LogUint("execute", "Before sendBounty - request.balance", address(this).balance);
        emit LogUint("execute", "Before sendBounty - self.txnData.toAddress.balance", self.txnData.toAddress.balance);
        self.paymentData.sendBounty();
        emit LogUint("execute", "After sendBounty - request.balance", address(this).balance);
        emit LogUint("execute", "After sendBounty - self.txnData.toAddress.balance", self.txnData.toAddress.balance);
```

This residual can only be sent to the *Payment Recipient* by executing `DelayedPayment.payout()` after the execution period.

### ChronoLogic comment

The residual value on the `DelayedPayment` contract is the remaining value send back by the scheduler afer execution. To improve the UX we've modified the example to:
* use `computeEndowment` function to estimate the required amount of ETH - note that we are assuming 200k gas for execution, while any lower actual value will ends up with remaining ETH on the scheduled tx contract which then is send back again to `DelayedPayment`
* added `collectRemaining` to transfer back the remaining amount of ETH to owner
* added `value` to indicate the exact amount of ETH to be sent to the receipient

All changes available in PR https://github.com/ethereum-alarm-clock/ethereum-alarm-clock/pull/148
<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the EAC smart contracts.

<br />

<hr />

## Scope

This audit is into the technical aspects of the EAC smart contracts. The primary aim of this audit is to ensure that funds
stored in these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is to
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Risks

<br />

<hr />

## Testing

Details of the testing environment can be found in [test](test).

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy Libraries #1
  * [x] Deploy MathLib
  * [x] Deploy PaymentLib
  * [x] Deploy RequestScheduleLib
  * [x] Deploy IterTools
* [x] Deploy Libraries #2
  * [x] Deploy RequestLib
  * [x] Deploy TransactionRequestCore
* [x] Deploy RequestFactory
* [x] Deploy Schedulers
  * [x] Deploy BlockScheduler
  * [x] Deploy TimestampScheduler
* [x] Execute Delayed Payment
  * [x] Schedule Delayed Payment
  * [x] Claim Delayed Payment
  * [x] Execute Delayed Payment

<br />

<hr />

## Notes

### Periods

The following fields are from the DelayedPayment testing results. Items in brackets are calculated on the fly. Items are rearranged into their order:

```
schedule.claimWindowSize=255
schedule.freezePeriod=10
schedule.reservedWindowSize=16
schedule.windowSize=255
schedule.temporalUnit=1

(schedule.firstClaimBlock=99 = freezeStart-claimWindowSize)
(schedule.freezeStart=354) = windowStart - freezePeriod
schedule.windowStart=364
(schedule.reservedWindowEnd=380) = windowStart + reserveWindowSize
(schedule.windowEnd=619) = windowStart + windowSize
```

<br />

<hr />

## Code Review

### Exit Points For Ethers

Check exit points for ethers:

#### Core
* [ ] RequestFactory.sol: msg.sender.transfer(msg.value);
* [ ] Library/ClaimLib.sol: return self.claimedBy.send(depositAmount);
* [x] Library/PaymentLib.sol: return self.feeRecipient.send(feeAmount);
* [x] Library/PaymentLib.sol: return self.bountyBenefactor.send(bountyAmount);
* [ ] Library/RequestLib.sol: rewardBenefactor.transfer(rewardOwed);
* [ ] Library/RequestLib.sol: return recipient.send(ownerRefund);

#### Test And Examples
* [ ] _examples/DelayedPayment.sol: recipient.transfer(address(this).balance);
* [ ] _examples/RecurringPayment.sol: recipient.transfer(paymentValue);
* [ ] _test/Proxy.sol: receipient.transfer(msg.value);

<br />

### contract

* [x] [code-review/CloneFactory.md](code-review/CloneFactory.md)
  * [x] contract CloneFactory
* [x] [code-review/IterTools.md](code-review/IterTools.md)
  * [x] library IterTools
* [x] [code-review/RequestFactory.md](code-review/RequestFactory.md)
  * [x] contract RequestFactory is RequestFactoryInterface, CloneFactory
    * [x] using IterTools for bool[6];
* [x] [code-review/TransactionRequestCore.md](code-review/TransactionRequestCore.md)
  * [x] contract TransactionRequestCore is TransactionRequestInterface
    * [x] using RequestLib for RequestLib.Request;
    * [x] using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;

<br />

### contract/_examples

* [x] [code-review/_examples/DelayedPayment.md](code-review/_examples/DelayedPayment.md)
  * [x] contract DelayedPayment
* [ ] [code-review/_examples/RecurringPayment.md](code-review/_examples/RecurringPayment.md)
  * [ ] contract RecurringPayment

<br />

### contract/Interface

* [x] [code-review/Interface/RequestFactoryInterface.md](code-review/Interface/RequestFactoryInterface.md)
  * [x] contract RequestFactoryInterface
* [x] [code-review/Interface/SchedulerInterface.md](code-review/Interface/SchedulerInterface.md)
  * [x] contract SchedulerInterface
* [x] [code-review/Interface/TransactionRequestInterface.md](code-review/Interface/TransactionRequestInterface.md)
  * [x] contract TransactionRequestInterface

<br />

### contract/Library

* [x] [code-review/Library/ClaimLib.md](code-review/Library/ClaimLib.md)
  * [x] library ClaimLib
    * [x] using SafeMath for uint;
* [x] [code-review/Library/ExecutionLib.md](code-review/Library/ExecutionLib.md)
  * [x] library ExecutionLib
* [x] [code-review/Library/MathLib.md](code-review/Library/MathLib.md)
  * [x] library MathLib
* [x] [code-review/Library/PaymentLib.md](code-review/Library/PaymentLib.md)
  * [x] library PaymentLib
    * [x] using SafeMath for uint;
* [x] [code-review/Library/RequestLib.md](code-review/Library/RequestLib.md)
  * [x] library RequestLib
    * [x] using ClaimLib for ClaimLib.ClaimData;
    * [x] using ExecutionLib for ExecutionLib.ExecutionData;
    * [x] using PaymentLib for PaymentLib.PaymentData;
    * [x] using RequestMetaLib for RequestMetaLib.RequestMeta;
    * [x] using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;
    * [x] using SafeMath for uint;
* [x] [code-review/Library/RequestMetaLib.md](code-review/Library/RequestMetaLib.md)
  * [x] library RequestMetaLib
* [x] [code-review/Library/RequestScheduleLib.md](code-review/Library/RequestScheduleLib.md)
  * [x] library RequestScheduleLib
    * [x] using SafeMath for uint;

<br />

### contract/Scheduler

* [x] [code-review/Scheduler/BaseScheduler.md](code-review/Scheduler/BaseScheduler.md)
  * [x] contract BaseScheduler is SchedulerInterface
* [x] [code-review/Scheduler/BlockScheduler.md](code-review/Scheduler/BlockScheduler.md)
  * [x] contract BlockScheduler is BaseScheduler
* [x] [code-review/Scheduler/TimestampScheduler.md](code-review/Scheduler/TimestampScheduler.md)
  * [x] contract TimestampScheduler is BaseScheduler

<br />

### contract/zeppelin

* [x] [code-review/zeppelin/SafeMath.md](code-review/zeppelin/SafeMath.md)
  * [x] library SafeMath

<br />

### Excluded - Only Used For Testing

* [../contracts/Migrations.sol](../contracts/Migrations.sol)
* [../contracts/_test/Proxy.sol](../contracts/_test/Proxy.sol)
* [../contracts/_test/SimpleToken.sol](../contracts/_test/SimpleToken.sol)
* [../contracts/_test/TransactionRecorder.sol](../contracts/_test/TransactionRecorder.sol)

<br />

### Compiler Warnings

The first and the third compiler warnings are due to the new `constructor(...)` keyword available from [Solidity 0.4.21](https://github.com/ethereum/solidity/releases/tag/v0.4.22) onwards.

```
RequestFactory.sol:22:5: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
    function RequestFactory(
    ^ (Relevant source part starts here and spans across multiple lines).
Library/RequestLib.sol:412:5: Warning: Function state mutability can be restricted to pure
    function getEXECUTION_GAS_OVERHEAD()
    ^ (Relevant source part starts here and spans across multiple lines).
./_examples/DelayedPayment.sol:14:5: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
    function DelayedPayment(
    ^ (Relevant source part starts here and spans across multiple lines).
```

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Caspian Tech - Jul 24 2018. The MIT Licence.
