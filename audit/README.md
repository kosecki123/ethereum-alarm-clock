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

* [ ] [code-review/CloneFactory.md](code-review/CloneFactory.md)
  * [ ] contract CloneFactory
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

### contract/_test

* [ ] [code-review/_test/Proxy.md](code-review/_test/Proxy.md)
  * [ ] contract Proxy
* [ ] [code-review/_test/SimpleToken.md](code-review/_test/SimpleToken.md)
  * [ ] contract SimpleToken
* [ ] [code-review/_test/TransactionRecorder.md](code-review/_test/TransactionRecorder.md)
  * [ ] contract TransactionRecorder

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