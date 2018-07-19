# ClaimLib

Source file [../../../contracts/Library/ClaimLib.sol](../../../contracts/Library/ClaimLib.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK NOTE - SafeMath is not used in this library
// BK Ok
import "contracts/zeppelin/SafeMath.sol";

// BK Ok
library ClaimLib {
    // BK NOTE - SafeMath is not used in this library
    // BK Ok
    using SafeMath for uint;

    // BK Next block Ok
    struct ClaimData {
        address claimedBy;          // The address that has claimed the txRequest.
        uint claimDeposit;          // The deposit amount that was put down by the claimer.
        uint requiredDeposit;       // The required deposit to claim the txRequest.
        uint8 paymentModifier;      // An integer constrained between 0-100 that will be applied to the
                                    // request payment as a percentage.
    }

    /*
     * @dev Mark the request as being claimed.
     * @param self The ClaimData that is being accessed.
     * @param paymentModifier The payment modifier.
     */
    // BK Ok - Internal function, only called by RequestLib.claim(...)
    // BK NOTE - `bool` return status is not set, and is not used in RequestLib.claim(...)
    function claim(
        ClaimData storage self, 
        uint8 _paymentModifier
    ) 
        internal returns (bool)
    {
        // BK Ok
        self.claimedBy = msg.sender;
        // BK Ok
        self.claimDeposit = msg.value;
        // BK Ok
        self.paymentModifier = _paymentModifier;
    }

    /*
     * Helper: returns whether this request is claimed.
     */
    // BK Ok - View function, called in RequestLib
    function isClaimed(ClaimData storage self) 
        internal view returns (bool)
    {
        // BK Ok
        return self.claimedBy != 0x0;
    }


    /*
     * @dev Refund the claim deposit to claimer.
     * @param self The Request.ClaimData
     * Called in RequestLib's `cancel()` and `refundClaimDeposit()`
     */
    // BK Ok
    function refundDeposit(ClaimData storage self) 
        internal returns (bool)
    {
        // Check that the claim deposit is non-zero.
        // BK Ok
        if (self.claimDeposit > 0) {
            // BK Ok
            uint depositAmount;
            // BK Ok
            depositAmount = self.claimDeposit;
            // BK Ok
            self.claimDeposit = 0;
            /* solium-disable security/no-send */
            // BK Ok - Limited to 2,300 gas
            return self.claimedBy.send(depositAmount);
        }
        // BK Ok
        return true;
    }
}
```
