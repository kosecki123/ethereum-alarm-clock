# MathLib

Source file [../../../contracts/Library/MathLib.sol](../../../contracts/Library/MathLib.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Ok
library MathLib {
    // BK Ok - new BigNumber("57896044618658097711785492504343953926634992332820282019728792003956564819967").add(1).toString(16) => "8000000000000000000000000000000000000000000000000000000000000000"
    uint constant INT_MAX = 57896044618658097711785492504343953926634992332820282019728792003956564819967;  // 2**255 - 1
    /*
     * Subtracts b from a in a manner such that zero is returned when an
     * underflow condition is met.
     */
    // function flooredSub(uint a, uint b) returns (uint) {
    //     if (b >= a) {
    //         return 0;
    //     } else {
    //         return a - b;
    //     }
    // }

    // /*
    //  * Adds b to a in a manner that throws an exception when overflow
    //  * conditions are met.
    //  */
    // function safeAdd(uint a, uint b) returns (uint) {
    //     if (a + b >= a) {
    //         return a + b;
    //     } else {
    //         throw;
    //     }
    // }

    // /*
    //  * Multiplies a by b in a manner that throws an exception when overflow
    //  * conditions are met.
    //  */
    // function safeMultiply(uint a, uint b) returns (uint) {
    //     var result = a * b;
    //     if (b == 0 || result / b == a) {
    //         return a * b;
    //     } else {
    //         throw;
    //     }
    // }

    /*
     * Return the larger of a or b.  Returns a if a == b.
     */
    // BK Ok - Pure function. Not used by other contracts in this repo currently
    function max(uint a, uint b) 
        public pure returns (uint)
    {
        // BK Ok
        if (a >= b) {
            // BK Ok
            return a;
        // BK Ok
        } else {
            // BK Ok
            return b;
        }
    }

    /*
     * Return the larger of a or b.  Returns a if a == b.
     */
    // BK Ok - Pure function
    function min(uint a, uint b) 
        public pure returns (uint)
    {
        // BK Ok
        if (a <= b) {
            // BK Ok
            return a;
        // BK Ok
        } else {
            // BK Ok
            return b;
        }
    }

    /*
     * Returns a represented as a signed integer in a manner that throw an
     * exception if casting to signed integer would result in a negative
     * number.
     */
    // BK Ok - Pure function. Not used by other contracts in this repo currently
    function safeCastSigned(uint a) 
        public pure returns (int)
    {
        // BK Ok
        assert(a <= INT_MAX);
        // BK Ok
        return int(a);
    }
    
}

```
