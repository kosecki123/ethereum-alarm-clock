#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`
LIBDIR=`grep ^LIBDIR= settings.txt | sed "s/^.*=//"`
SCHEDULERDIR=`grep ^SCHEDULERDIR= settings.txt | sed "s/^.*=//"`
TESTDIR=`grep ^TESTDIR= settings.txt | sed "s/^.*=//"`

MATHLIBSOL=`grep ^MATHLIBSOL= settings.txt | sed "s/^.*=//"`
MATHLIBJS=`grep ^MATHLIBJS= settings.txt | sed "s/^.*=//"`
PAYMENTLIBSOL=`grep ^PAYMENTLIBSOL= settings.txt | sed "s/^.*=//"`
PAYMENTLIBJS=`grep ^PAYMENTLIBJS= settings.txt | sed "s/^.*=//"`
REQUESTSCHEDULELIBSOL=`grep ^REQUESTSCHEDULELIBSOL= settings.txt | sed "s/^.*=//"`
REQUESTSCHEDULELIBJS=`grep ^REQUESTSCHEDULELIBJS= settings.txt | sed "s/^.*=//"`
ITERTOOLSSOL=`grep ^ITERTOOLSSOL= settings.txt | sed "s/^.*=//"`
ITERTOOLSJS=`grep ^ITERTOOLSJS= settings.txt | sed "s/^.*=//"`
REQUESTLIBSOL=`grep ^REQUESTLIBSOL= settings.txt | sed "s/^.*=//"`
REQUESTLIBJS=`grep ^REQUESTLIBJS= settings.txt | sed "s/^.*=//"`
TRANSACTIONREQUESTCORESOL=`grep ^TRANSACTIONREQUESTCORESOL= settings.txt | sed "s/^.*=//"`
TRANSACTIONREQUESTCOREJS=`grep ^TRANSACTIONREQUESTCOREJS= settings.txt | sed "s/^.*=//"`
REQUESTFACTORYSOL=`grep ^REQUESTFACTORYSOL= settings.txt | sed "s/^.*=//"`
REQUESTFACTORYJS=`grep ^REQUESTFACTORYJS= settings.txt | sed "s/^.*=//"`
BLOCKSCHEDULERSOL=`grep ^BLOCKSCHEDULERSOL= settings.txt | sed "s/^.*=//"`
BLOCKSCHEDULERJS=`grep ^BLOCKSCHEDULERJS= settings.txt | sed "s/^.*=//"`
TIMESTAMPSCHEDULERSOL=`grep ^TIMESTAMPSCHEDULERSOL= settings.txt | sed "s/^.*=//"`
TIMESTAMPSCHEDULERJS=`grep ^TIMESTAMPSCHEDULERJS= settings.txt | sed "s/^.*=//"`
TESTCONTRACT1SOL=`grep ^TESTCONTRACT1SOL= settings.txt | sed "s/^.*=//"`
TESTCONTRACT1JS=`grep ^TESTCONTRACT1JS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`perl -le "print scalar localtime $CURRENTTIME"`
START_DATE=`echo "$CURRENTTIME+45" | bc`
START_DATE_S=`perl -le "print scalar localtime $START_DATE"`
END_DATE=`echo "$CURRENTTIME+60*2" | bc`
END_DATE_S=`perl -le "print scalar localtime $END_DATE"`

printf "MODE                      = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT           = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD                  = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR                 = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "LIBDIR                    = '$LIBDIR'\n" | tee -a $TEST1OUTPUT
printf "TESTDIR                   = '$TESTDIR'\n" | tee -a $TEST1OUTPUT
printf "SCHEDULERDIR              = '$SCHEDULERDIR'\n" | tee -a $TEST1OUTPUT
printf "MATHLIBSOL                = '$MATHLIBSOL'\n" | tee -a $TEST1OUTPUT
printf "MATHLIBJS                 = '$MATHLIBJS'\n" | tee -a $TEST1OUTPUT
printf "PAYMENTLIBSOL             = '$PAYMENTLIBSOL'\n" | tee -a $TEST1OUTPUT
printf "PAYMENTLIBJS              = '$PAYMENTLIBJS'\n" | tee -a $TEST1OUTPUT
printf "REQUESTSCHEDULELIBSOL     = '$REQUESTSCHEDULELIBSOL'\n" | tee -a $TEST1OUTPUT
printf "REQUESTSCHEDULELIBJS      = '$REQUESTSCHEDULELIBJS'\n" | tee -a $TEST1OUTPUT
printf "ITERTOOLSSOL              = '$ITERTOOLSSOL'\n" | tee -a $TEST1OUTPUT
printf "ITERTOOLSJS               = '$ITERTOOLSJS'\n" | tee -a $TEST1OUTPUT
printf "REQUESTLIBSOL             = '$REQUESTLIBSOL'\n" | tee -a $TEST1OUTPUT
printf "REQUESTLIBJS              = '$REQUESTLIBJS'\n" | tee -a $TEST1OUTPUT
printf "TRANSACTIONREQUESTCORESOL = '$TRANSACTIONREQUESTCORESOL'\n" | tee -a $TEST1OUTPUT
printf "TRANSACTIONREQUESTCOREJS  = '$TRANSACTIONREQUESTCOREJS'\n" | tee -a $TEST1OUTPUT
printf "REQUESTFACTORYSOL         = '$REQUESTFACTORYSOL'\n" | tee -a $TEST1OUTPUT
printf "REQUESTFACTORYJS          = '$REQUESTFACTORYJS'\n" | tee -a $TEST1OUTPUT
printf "BLOCKSCHEDULERSOL         = '$BLOCKSCHEDULERSOL'\n" | tee -a $TEST1OUTPUT
printf "BLOCKSCHEDULERJS          = '$BLOCKSCHEDULERJS'\n" | tee -a $TEST1OUTPUT
printf "TIMESTAMPSCHEDULERSOL     = '$TIMESTAMPSCHEDULERSOL'\n" | tee -a $TEST1OUTPUT
printf "TIMESTAMPSCHEDULERJS      = '$TIMESTAMPSCHEDULERJS'\n" | tee -a $TEST1OUTPUT
printf "TESTCONTRACT1SOL          = '$TESTCONTRACT1SOL'\n" | tee -a $TEST1OUTPUT
printf "TESTCONTRACT1JS           = '$TESTCONTRACT1JS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA            = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS                 = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT               = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS              = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME               = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE                = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE                  = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp -rp $SOURCEDIR/* .`

# --- Modify parameters ---
# `perl -pi -e "s/START_DATE \= 1525132800.*$/START_DATE \= $START_DATE; \/\/ $START_DATE_S/" $CROWDSALESOL`
# `perl -pi -e "s/endDate \= 1527811200;.*$/endDate \= $END_DATE; \/\/ $END_DATE_S/" $CROWDSALESOL`
`perl -pi -e "s/contracts\///" *.sol`
`perl -pi -e "s/contracts\///" _examples/*.sol`
`perl -pi -e "s/contracts\///" Library/*.sol`
`perl -pi -e "s/contracts\///" Scheduler/*.sol`

DIFFS1=`diff -r -x '*.js' -x '*.json' -x '*.txt' -x 'testchain' -x '*.md' $SOURCEDIR .`
echo "--- Differences $SOURCEDIR/$REQUESTFACTORYSOL $REQUESTFACTORYSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.4.24 --version | tee -a $TEST1OUTPUT

echo "var mathLibOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $LIBDIR/$MATHLIBSOL`;" > $MATHLIBJS
echo "var paymentLibOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $LIBDIR/$PAYMENTLIBSOL`;" > $PAYMENTLIBJS
echo "var requestScheduleLibOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $LIBDIR/$REQUESTSCHEDULELIBSOL`;" > $REQUESTSCHEDULELIBJS
echo "var iterToolsOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $ITERTOOLSSOL`;" > $ITERTOOLSJS
echo "var requestLibOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $LIBDIR/$REQUESTLIBSOL`;" > $REQUESTLIBJS
echo "var transactionRequestCoreOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TRANSACTIONREQUESTCORESOL`;" > $TRANSACTIONREQUESTCOREJS
echo "var requestFactoryOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $REQUESTFACTORYSOL`;" > $REQUESTFACTORYJS
echo "var blockSchedulerOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $SCHEDULERDIR/$BLOCKSCHEDULERSOL`;" > $BLOCKSCHEDULERJS
echo "var timestampSchedulerOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $SCHEDULERDIR/$TIMESTAMPSCHEDULERSOL`;" > $TIMESTAMPSCHEDULERJS
echo "var testOutput=`solc_0.4.24 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TESTDIR/$TESTCONTRACT1SOL`;" > $TESTCONTRACT1JS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$MATHLIBJS");
loadScript("$PAYMENTLIBJS");
loadScript("$REQUESTSCHEDULELIBJS");
loadScript("$ITERTOOLSJS");
loadScript("$REQUESTLIBJS");
loadScript("$TRANSACTIONREQUESTCOREJS");
loadScript("$REQUESTFACTORYJS");
loadScript("$BLOCKSCHEDULERJS");
loadScript("$TIMESTAMPSCHEDULERJS");
loadScript("$TESTCONTRACT1JS");
loadScript("functions.js");

var mathLibAbi = JSON.parse(mathLibOutput.contracts["$LIBDIR/$MATHLIBSOL:MathLib"].abi);
var mathLibBin = "0x" + mathLibOutput.contracts["$LIBDIR/$MATHLIBSOL:MathLib"].bin;
var paymentLibAbi = JSON.parse(paymentLibOutput.contracts["$LIBDIR/$PAYMENTLIBSOL:PaymentLib"].abi);
var paymentLibBin = "0x" + paymentLibOutput.contracts["$LIBDIR/$PAYMENTLIBSOL:PaymentLib"].bin;
var requestScheduleLibAbi = JSON.parse(requestScheduleLibOutput.contracts["$LIBDIR/$REQUESTSCHEDULELIBSOL:RequestScheduleLib"].abi);
var requestScheduleLibBin = "0x" + requestScheduleLibOutput.contracts["$LIBDIR/$REQUESTSCHEDULELIBSOL:RequestScheduleLib"].bin;
var iterToolsAbi = JSON.parse(requestFactoryOutput.contracts["$ITERTOOLSSOL:IterTools"].abi);
var iterToolsBin = "0x" + requestFactoryOutput.contracts["$ITERTOOLSSOL:IterTools"].bin;
var requestLibAbi = JSON.parse(requestLibOutput.contracts["$LIBDIR/$REQUESTLIBSOL:RequestLib"].abi);
var requestLibBin = "0x" + requestLibOutput.contracts["$LIBDIR/$REQUESTLIBSOL:RequestLib"].bin;
var transactionRequestCoreAbi = JSON.parse(transactionRequestCoreOutput.contracts["$TRANSACTIONREQUESTCORESOL:TransactionRequestCore"].abi);
var transactionRequestCoreBin = "0x" + transactionRequestCoreOutput.contracts["$TRANSACTIONREQUESTCORESOL:TransactionRequestCore"].bin;
var requestFactoryAbi = JSON.parse(requestFactoryOutput.contracts["$REQUESTFACTORYSOL:RequestFactory"].abi);
var requestFactoryBin = "0x" + requestFactoryOutput.contracts["$REQUESTFACTORYSOL:RequestFactory"].bin;
var blockSchedulerAbi = JSON.parse(blockSchedulerOutput.contracts["$SCHEDULERDIR/$BLOCKSCHEDULERSOL:BlockScheduler"].abi);
var blockSchedulerBin = "0x" + blockSchedulerOutput.contracts["$SCHEDULERDIR/$BLOCKSCHEDULERSOL:BlockScheduler"].bin;
var timestampSchedulerAbi = JSON.parse(timestampSchedulerOutput.contracts["$SCHEDULERDIR/$TIMESTAMPSCHEDULERSOL:TimestampScheduler"].abi);
var timestampSchedulerBin = "0x" + timestampSchedulerOutput.contracts["$SCHEDULERDIR/$TIMESTAMPSCHEDULERSOL:TimestampScheduler"].bin;
var delayedPaymentAbi = JSON.parse(testOutput.contracts["$TESTDIR/$TESTCONTRACT1SOL:DelayedPayment"].abi);
var delayedPaymentBin = "0x" + testOutput.contracts["$TESTDIR/$TESTCONTRACT1SOL:DelayedPayment"].bin;

// console.log("DATA: mathLibAbi=" + JSON.stringify(mathLibAbi));
// console.log("DATA: mathLibBin=" + JSON.stringify(mathLibBin));
// console.log("DATA: paymentLibAbi=" + JSON.stringify(paymentLibAbi));
// console.log("DATA: paymentLibBin=" + JSON.stringify(paymentLibBin));
// console.log("DATA: requestScheduleLibAbi=" + JSON.stringify(requestScheduleLibAbi));
// console.log("DATA: requestScheduleLibBin=" + JSON.stringify(requestScheduleLibBin));
// console.log("DATA: iterToolsAbi=" + JSON.stringify(iterToolsAbi));
// console.log("DATA: iterToolsBin=" + JSON.stringify(iterToolsBin));
// console.log("DATA: requestLibAbi=" + JSON.stringify(requestLibAbi));
// console.log("DATA: requestLibBin=" + JSON.stringify(requestLibBin));
// console.log("DATA: transactionRequestCoreAbi=" + JSON.stringify(transactionRequestCoreAbi));
// console.log("DATA: transactionRequestCoreBin=" + JSON.stringify(transactionRequestCoreBin));
// console.log("DATA: requestFactoryAbi=" + JSON.stringify(requestFactoryAbi));
// console.log("DATA: requestFactoryBin=" + JSON.stringify(requestFactoryBin));
// console.log("DATA: blockSchedulerAbi=" + JSON.stringify(blockSchedulerAbi));
// console.log("DATA: blockSchedulerBin=" + JSON.stringify(blockSchedulerBin));
// console.log("DATA: timestampSchedulerAbi=" + JSON.stringify(timestampSchedulerAbi));
// console.log("DATA: timestampSchedulerBin=" + JSON.stringify(timestampSchedulerBin));
// console.log("DATA: delayedPaymentAbi=" + JSON.stringify(delayedPaymentAbi));
// console.log("DATA: delayedPaymentBin=" + JSON.stringify(delayedPaymentBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployLibs1Message = "Deploy Libraries #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployLibs1Message + " ----------");
var mathLibContract = web3.eth.contract(mathLibAbi);
// console.log(JSON.stringify(mathLibContract));
var mathLibTx = null;
var mathLibAddress = null;
var mathLib = mathLibContract.new({from: contractOwnerAccount, data: mathLibBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mathLibTx = contract.transactionHash;
      } else {
        mathLibAddress = contract.address;
        addAccount(mathLibAddress, "MathLib");
        console.log("DATA: mathLibAddress=" + mathLibAddress);
      }
    }
  }
);
var paymentLibContract = web3.eth.contract(paymentLibAbi);
// console.log(JSON.stringify(paymentLibContract));
var paymentLibTx = null;
var paymentLibAddress = null;
var paymentLib = paymentLibContract.new({from: contractOwnerAccount, data: paymentLibBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        paymentLibTx = contract.transactionHash;
      } else {
        paymentLibAddress = contract.address;
        addAccount(paymentLibAddress, "PaymentLib");
        console.log("DATA: paymentLibAddress=" + paymentLibAddress);
      }
    }
  }
);
var requestScheduleLibContract = web3.eth.contract(requestScheduleLibAbi);
// console.log(JSON.stringify(requestScheduleLibContract));
var requestScheduleLibTx = null;
var requestScheduleLibAddress = null;
var requestScheduleLib = requestScheduleLibContract.new({from: contractOwnerAccount, data: requestScheduleLibBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        requestScheduleLibTx = contract.transactionHash;
      } else {
        requestScheduleLibAddress = contract.address;
        addAccount(requestScheduleLibAddress, "RequestScheduleLib");
        console.log("DATA: requestScheduleLibAddress=" + requestScheduleLibAddress);
      }
    }
  }
);
var iterToolsContract = web3.eth.contract(iterToolsAbi);
// console.log(JSON.stringify(iterToolsContract));
var iterToolsTx = null;
var iterToolsAddress = null;
var iterTools = iterToolsContract.new({from: contractOwnerAccount, data: iterToolsBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        iterToolsTx = contract.transactionHash;
      } else {
        iterToolsAddress = contract.address;
        addAccount(iterToolsAddress, "IterTools");
        console.log("DATA: iterToolsAddress=" + iterToolsAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(mathLibTx, deployLibs1Message + " - MathLib");
failIfTxStatusError(paymentLibTx, deployLibs1Message + " - PaymentLib");
failIfTxStatusError(requestScheduleLibTx, deployLibs1Message + " - RequestScheduleLib");
failIfTxStatusError(iterToolsTx, deployLibs1Message + " - IterTools");
printTxData("mathLibTx", mathLibTx);
printTxData("paymentLibTx", paymentLibTx);
printTxData("requestScheduleLibTx", requestScheduleLibTx);
printTxData("iterToolsTx", iterToolsTx);
// printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployLibs2Message = "Deploy Libraries #2";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployLibs2Message + " ----------");
var requestLibContract = web3.eth.contract(requestLibAbi);
// console.log(JSON.stringify(requestLibContract));
// console.log("RESULT: old='" + requestLibBin + "'");
var newRequestLibBin = requestLibBin.replace(/__Library\/MathLib.sol:MathLib___________/g, mathLibAddress.substring(2, 42)).replace(/__Library\/PaymentLib.sol:PaymentLib_____/g, paymentLibAddress.substring(2, 42)).replace(/__Library\/RequestScheduleLib.sol:Reque__/g, requestScheduleLibAddress.substring(2, 42));
// console.log("RESULT: new='" + newRequestLibBin + "'");
var requestLibTx = null;
var requestLibAddress = null;
var requestLib = requestLibContract.new({from: contractOwnerAccount, data: newRequestLibBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        requestLibTx = contract.transactionHash;
      } else {
        requestLibAddress = contract.address;
        addAccount(requestLibAddress, "RequestLib");
        console.log("DATA: requestLibAddress=" + requestLibAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(requestLibTx, deployLibs2Message + " - RequestLib");
printTxData("requestLibTx", requestLibTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployTransactionRequestCoreMessage = "Deploy TransactionRequestCore";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployTransactionRequestCoreMessage + " ----------");
var transactionRequestCoreContract = web3.eth.contract(transactionRequestCoreAbi);
// console.log(JSON.stringify(transactionRequestCoreContract));
// console.log("RESULT: old='" + transactionRequestCoreBin + "'");
var newTransactionRequestCoreBin = transactionRequestCoreBin.replace(/__Library\/RequestLib.sol:RequestLib_____/g, requestLibAddress.substring(2, 42));
// console.log("RESULT: new='" + newTransactionRequestCoreBin + "'");
var transactionRequestCoreTx = null;
var transactionRequestCoreAddress = null;
var transactionRequestCore = transactionRequestCoreContract.new({from: contractOwnerAccount, data: newTransactionRequestCoreBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        transactionRequestCoreTx = contract.transactionHash;
      } else {
        transactionRequestCoreAddress = contract.address;
        addAccount(transactionRequestCoreAddress, "TransactionRequestCore");
        console.log("DATA: transactionRequestCoreAddress=" + transactionRequestCoreAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(transactionRequestCoreTx, deployTransactionRequestCoreMessage + " - TransactionRequestCore");
printTxData("transactionRequestCoreTx", transactionRequestCoreTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployRequestFactoryMessage = "Deploy RequestFactory";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployRequestFactoryMessage + " ----------");
var requestFactoryContract = web3.eth.contract(requestFactoryAbi);
// console.log(JSON.stringify(requestFactoryContract));
// console.log("RESULT: old='" + requestFactoryBin + "'");
var newRequestFactoryBin = requestFactoryBin.replace(/__Library\/RequestLib.sol:RequestLib_____/g, requestLibAddress.substring(2, 42)).replace(/__IterTools.sol:IterTools_______________/g, iterToolsAddress.substring(2, 42));
// console.log("RESULT: new='" + newRequestFactoryBin + "'");
var requestFactoryTx = null;
var requestFactoryAddress = null;
var requestFactory = requestFactoryContract.new(transactionRequestCoreAddress, {from: contractOwnerAccount, data: newRequestFactoryBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        requestFactoryTx = contract.transactionHash;
      } else {
        requestFactoryAddress = contract.address;
        addAccount(requestFactoryAddress, "RequestFactory");
        addRequestFactoryContractAddressAndAbi(requestFactoryAddress, requestFactoryAbi);
        console.log("DATA: requestFactoryAddress=" + requestFactoryAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(requestFactoryTx, deployRequestFactoryMessage + " - RequestFactory");
printTxData("requestFactoryTx", requestFactoryTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deploySchedulersMessage = "Deploy Schedulers";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deploySchedulersMessage + " ----------");
var blockSchedulerContract = web3.eth.contract(blockSchedulerAbi);
// console.log(JSON.stringify(blockSchedulerContract));
// console.log("RESULT: old='" + blockSchedulerBin + "'");
var newBlockSchedulerBin = blockSchedulerBin.replace(/__Library\/RequestLib.sol:RequestLib_____/g, requestLibAddress.substring(2, 42)).replace(/__Library\/PaymentLib.sol:PaymentLib_____/g, paymentLibAddress.substring(2, 42));
// console.log("RESULT: new='" + newBlockSchedulerBin + "'");
var blockSchedulerTx = null;
var blockSchedulerAddress = null;
var blockScheduler = blockSchedulerContract.new(requestFactoryAddress, feeRecipient, {from: contractOwnerAccount, data: newBlockSchedulerBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        blockSchedulerTx = contract.transactionHash;
      } else {
        blockSchedulerAddress = contract.address;
        addAccount(blockSchedulerAddress, "BlockScheduler");
        console.log("DATA: blockSchedulerAddress=" + blockSchedulerAddress);
      }
    }
  }
);
var timestampSchedulerContract = web3.eth.contract(timestampSchedulerAbi);
// console.log(JSON.stringify(timestampSchedulerContract));
// console.log("RESULT: old='" + timestampSchedulerBin + "'");
var newTimestampSchedulerBin = timestampSchedulerBin.replace(/__Library\/RequestLib.sol:RequestLib_____/g, requestLibAddress.substring(2, 42)).replace(/__Library\/PaymentLib.sol:PaymentLib_____/g, paymentLibAddress.substring(2, 42));
// console.log("RESULT: new='" + newTimestampSchedulerBin + "'");
var timestampSchedulerTx = null;
var timestampSchedulerAddress = null;
var timestampScheduler = timestampSchedulerContract.new(requestFactoryAddress, feeRecipient, {from: contractOwnerAccount, data: newTimestampSchedulerBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        timestampSchedulerTx = contract.transactionHash;
      } else {
        timestampSchedulerAddress = contract.address;
        addAccount(timestampSchedulerAddress, "TimestampScheduler");
        console.log("DATA: timestampSchedulerAddress=" + timestampSchedulerAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(blockSchedulerTx, deploySchedulersMessage + " - BlockScheduler");
failIfTxStatusError(timestampSchedulerTx, deploySchedulersMessage + " - TimestampScheduler");
printTxData("blockSchedulerTx", blockSchedulerTx);
printTxData("timestampSchedulerTx", timestampSchedulerTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var delayedPaymentMessage = "Schedule Delayed Payment";
var numBlocks = 10;
var value = new BigNumber(10).shift(18);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + delayedPaymentMessage + " ----------");
var delayedPaymentContract = web3.eth.contract(delayedPaymentAbi);
// console.log(JSON.stringify(delayedPaymentContract));
var delayedPaymentTx = null;
var delayedPaymentAddress = null;
var delayedPayment = delayedPaymentContract.new(blockSchedulerAddress, numBlocks, paymentRecipient, {from: scheduleCreator, data: delayedPaymentBin, value: value, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        delayedPaymentTx = contract.transactionHash;
      } else {
        delayedPaymentAddress = contract.address;
        addAccount(delayedPaymentAddress, "DelayedPayment");
        console.log("DATA: delayedPaymentAddress=" + delayedPaymentAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
console.log("RESULT: delayedPayment.scheduledTransaction=" + delayedPayment.scheduledTransaction());
var newRequestAddress = getRequestFactoryListing();
console.log("RESULT: newRequestAddress=" + newRequestAddress);
addAccount(newRequestAddress, "DelayedPaymentRequest");
printBalances();
failIfTxStatusError(delayedPaymentTx, delayedPaymentMessage);
printTxData("delayedPaymentTx", delayedPaymentTx);
printRequestFactoryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var claim1Message = "Claim Delayed Payment";
var stake = new BigNumber(0.1).shift(18);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + claim1Message + " ----------");
var delayedPaymentTxRequest = eth.contract(transactionRequestCoreAbi).at(delayedPayment.scheduledTransaction());
// console.log("RESULT: delayedPaymentTxRequest.requestData=" + JSON.stringify(delayedPaymentTxRequest.requestData()));
displayTxRequestData(claim1Message, delayedPaymentTxRequest.requestData());
var claim1_1Tx = delayedPaymentTxRequest.claim({from: executor, value: stake, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(claim1_1Tx, claim1Message);
printTxData("claim1_1Tx", claim1_1Tx);
console.log("RESULT: ");


waitUntilBlock("Wait to execute", eth.getTransaction(delayedPaymentTx).blockNumber, numBlocks);


// -----------------------------------------------------------------------------
var execute1Message = "Execute Delayed Payment";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + execute1Message + " ----------");
var delayedPaymentTxRequest = eth.contract(transactionRequestCoreAbi).at(delayedPayment.scheduledTransaction());
// console.log("RESULT: delayedPaymentTxRequest.requestData=" + JSON.stringify(delayedPaymentTxRequest.requestData()));
displayTxRequestData(claim1Message, delayedPaymentTxRequest.requestData());
// NO var execute1_1Tx = eth.sendTransaction({from: executor, to: delayedPayment.scheduledTransaction(), gas: 400000, gasPrice: defaultGasPrice});
// PART var execute1_1Tx = eth.sendTransaction({from: executor, to: delayedPaymentAddress, gas: 400000, gasPrice: defaultGasPrice});
var execute1_1Tx = delayedPaymentTxRequest.execute({from: executor, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(execute1_1Tx, execute1Message);
printTxData("execute1_1Tx", execute1_1Tx);
console.log("RESULT: ");



exit;



// -----------------------------------------------------------------------------
var deployTokenMessage = "Deploy Token Contract";
var symbol = "ORIGINAL";
var name = "Original";
var decimals = 18;
var initialSupply = new BigNumber("1000000").shift(18);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployTokenMessage + " ----------");
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
var deployToken_1Tx = token.init(symbol, name, decimals, contractOwnerAccount, initialSupply, {from: contractOwnerAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
addTokenAContractAddressAndAbi(tokenAddress, tokenAbi);
console.log("DATA: var tokenAddress=\"" + tokenAddress + "\";");
console.log("DATA: var tokenAbi=" + JSON.stringify(tokenAbi) + ";");
console.log("DATA: var token=eth.contract(tokenAbi).at(tokenAddress);");
printBalances();
failIfTxStatusError(tokenTx, deployTokenMessage + " - deploy");
failIfTxStatusError(deployToken_1Tx, deployTokenMessage + " - init");
printTxData("tokenTx", tokenTx);
printTxData("deployToken_1Tx", deployToken_1Tx);
printTokenAContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployProxyContractMessage = "Deploy Proxy Contract";
// var originalData = "00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000012000000000000000000000000a11aae29840fbb5c86e6fd4cf809eba183aef43300000000000000000000000000000000000000000000d3c21bcecceda100000000000000000000000000000000000000000000000000000000000000000000074f5247494e414c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000084f726967696e616c000000000000000000000000000000000000000000000000";
// console.log("RESULT: originalData=" + originalData);
// var tokenContract=eth.contract(tokenAbi);
// var data="0x" + tokenContract.new.getData(symbol, name, decimals, contractOwnerAccount, initialSupply.toFixed(0)).substring(9);
var data="";
// console.log("RESULT: data=" + data);
// -----------------------------------------------------------------------------
console.log("RESULT: ----- " + deployProxyContractMessage + " -----");
var deployProxyContractTx = proxyFactory.createProxy(tokenAddress, data, {from: aliceAccount, gas: 4000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var newContractAddress = getProxyFactoryListing();
console.log("RESULT: newContractAddress=" + newContractAddress);
var newToken = web3.eth.contract(tokenAbi).at(newContractAddress);
var symbol = "NEWTOKEN";
var name = "New Token";
var decimals = 18;
var initialSupply = new BigNumber("2000000").shift(18);
var deployNewToken_1Tx = newToken.init(symbol, name, decimals, aliceAccount, initialSupply, {from: aliceAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
addAccount(newContractAddress, "New Token '" + newToken.symbol() + "' '" + newToken.name() + "'");
addTokenBContractAddressAndAbi(newContractAddress, tokenAbi);
printBalances();
failIfTxStatusError(deployProxyContractTx, deployProxyContractMessage + " - Deploy New Token Contract");
failIfTxStatusError(deployNewToken_1Tx, deployProxyContractMessage + " - New Token Contract Init");
printTxData("deployProxyContractTx", deployProxyContractTx);
printTxData("deployNewToken_1Tx", deployNewToken_1Tx);
printProxyFactoryContractDetails();
printTokenAContractDetails();
printTokenBContractDetails();
console.log("RESULT: ");


console.log("RESULT: oldAddr=" + tokenAddress);
console.log("RESULT: newAddr=" + newContractAddress);
console.log("RESULT: oldCode=" + eth.getCode(tokenAddress));
console.log("RESULT: newCode=" + eth.getCode(newContractAddress));

for (var i = 0; i < 10; i++) {
  var older = eth.getStorageAt(tokenAddress, i);
  var newer = eth.getStorageAt(newContractAddress, i);
  var olderText;
  var newerText;
  if (i == 2 || i == 3) {
    olderText = web3.toAscii(older.replace(/00.*$/g,""));
    newerText = web3.toAscii(newer.replace(/00.*$/g,""));
  } else {
    olderText = "";
    newerText = "";
  }
  console.log("RESULT: old data[" + i + "]=" + older + " " + new BigNumber(older.substring(2), 16) + " " + olderText);
  console.log("RESULT: new data[" + i + "]=" + newer + " " + new BigNumber(newer.substring(2), 16) + " " + newerText);
}

var oldBalanceKey = web3.sha3("000000000000000000000000" + contractOwnerAccount.substring(2) + "0000000000000000000000000000000000000000000000000000000000000007", {"encoding":"hex"});
var older = eth.getStorageAt(tokenAddress, oldBalanceKey);
console.log("RESULT: mapping(olderKey,7)=" + older + " " + new BigNumber(older.substring(2), 16));

var newBalanceKey = web3.sha3("000000000000000000000000" + aliceAccount.substring(2) + "0000000000000000000000000000000000000000000000000000000000000007", {"encoding":"hex"});
var newer = eth.getStorageAt(newContractAddress, newBalanceKey);
console.log("RESULT: mapping(newerKey,7)=" + newer + " " + new BigNumber(newer.substring(2), 16));

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS