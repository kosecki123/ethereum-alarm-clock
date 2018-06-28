# SafeMath

Source file [../../../contracts/zeppelin/SafeMath.sol](../../../contracts/zeppelin/SafeMath.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.21;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
// BK Ok
library SafeMath {
    // BK Ok - Internal pure function
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // BK Ok
        uint256 c = a * b;
        // BK Ok
        require(a == 0 || c / a == b);
        // BK Ok
        return c;
  }

  // BK Ok - Internal pure function
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
  // require(b > 0); // Solidity automatically throws when dividing by 0
  // BK Ok
  uint256 c = a / b;
  // require(a == b * c + a % b); // There is no case in which this doesn't hold
  // BK Ok
  return c;
  }

  // BK Ok - Internal pure function
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
  // BK Ok
  require(b <= a);
  // BK Ok
  return a - b;
  }

  // BK Ok - Internal pure function
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
  // BK Ok
  uint256 c = a + b;
  // BK Ok
  require(c >= a);
  // BK Ok
  return c;
  }
}

```
