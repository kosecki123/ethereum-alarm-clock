# IterTools

Source file [../../contracts/IterTools.sol](../../contracts/IterTools.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

/**
 * @title IterTools
 * @dev Utility library that iterates through a boolean array of length 6.
 */
// BK Ok
library IterTools {
    /*
     * @dev Return true if all of the values in the boolean array are true.
     * @param _values A boolean array of length 6.
     * @return True if all values are true, False if _any_ are false.
     */
    // BK Ok - Pure function
    function all(bool[6] _values) 
        public pure returns (bool)
    {
        // BK Ok
        for (uint i = 0; i < _values.length; i++) {
            // BK Ok
            if (!_values[i]) {
                return false;
            }
        }
        // BK Ok
        return true;
    }
}

```
