

## Code Review

### contract

* [ ] [code-review/CloneFactory.md](code-review/CloneFactory.md)
  * [ ] contract CloneFactory
* [ ] [code-review/IterTools.md](code-review/IterTools.md)
  * [ ] library IterTools
* [ ] [code-review/RequestFactory.md](code-review/RequestFactory.md)
  * [ ] contract RequestFactory is RequestFactoryInterface, CloneFactory
    * [ ] using IterTools for bool[6];
* [ ] [code-review/TransactionRequestCore.md](code-review/TransactionRequestCore.md)
  * [ ] contract TransactionRequestCore is TransactionRequestInterface
    * [ ] using RequestLib for RequestLib.Request;
    * [ ] using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;

<br />

### contract/_examples

* [ ] [code-review/_examples/DelayedPayment.md](code-review/_examples/DelayedPayment.md)
  * [ ] contract DelayedPayment
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

* [ ] [code-review/Interface/RequestFactoryInterface.md](code-review/Interface/RequestFactoryInterface.md)
  * [ ] contract RequestFactoryInterface
* [ ] [code-review/Interface/SchedulerInterface.md](code-review/Interface/SchedulerInterface.md)
  * [ ] contract SchedulerInterface
* [ ] [code-review/Interface/TransactionRequestInterface.md](code-review/Interface/TransactionRequestInterface.md)
  * [ ] contract TransactionRequestInterface

<br />

### contract/Library

* [ ] [code-review/Library/ClaimLib.md](code-review/Library/ClaimLib.md)
  * [ ] library ClaimLib
    * [ ] using SafeMath for uint;
* [ ] [code-review/Library/ExecutionLib.md](code-review/Library/ExecutionLib.md)
  * [ ] library ExecutionLib
* [ ] [code-review/Library/MathLib.md](code-review/Library/MathLib.md)
  * [ ] library MathLib
* [ ] [code-review/Library/PaymentLib.md](code-review/Library/PaymentLib.md)
  * [ ] library PaymentLib
    * [ ] using SafeMath for uint;
* [ ] [code-review/Library/RequestLib.md](code-review/Library/RequestLib.md)
  * [ ] library RequestLib
    * [ ] using ClaimLib for ClaimLib.ClaimData;
    * [ ] using ExecutionLib for ExecutionLib.ExecutionData;
    * [ ] using PaymentLib for PaymentLib.PaymentData;
    * [ ] using RequestMetaLib for RequestMetaLib.RequestMeta;
    * [ ] using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;
    * [ ] using SafeMath for uint;
* [ ] [code-review/Library/RequestMetaLib.md](code-review/Library/RequestMetaLib.md)
  * [ ] library RequestMetaLib
* [ ] [code-review/Library/RequestScheduleLib.md](code-review/Library/RequestScheduleLib.md)
  * [ ] library RequestScheduleLib
    * [ ] using SafeMath for uint;

<br />

### contract/Scheduler

* [ ] [code-review/Scheduler/BaseScheduler.md](code-review/Scheduler/BaseScheduler.md)
  * [ ] contract BaseScheduler is SchedulerInterface
* [ ] [code-review/Scheduler/BlockScheduler.md](code-review/Scheduler/BlockScheduler.md)
  * [ ] contract BlockScheduler is BaseScheduler
* [ ] [code-review/Scheduler/TimestampScheduler.md](code-review/Scheduler/TimestampScheduler.md)
  * [ ] contract TimestampScheduler is BaseScheduler

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