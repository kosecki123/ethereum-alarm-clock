# PaymentLib

Source file [../../../contracts/Library/PaymentLib.sol](../../../contracts/Library/PaymentLib.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Ok
import "contracts/zeppelin/SafeMath.sol";

/**
 * Library containing the functionality for the bounty and fee payments.
 * - Bounty payments are the reward paid to the executing agent of transaction
 * requests.
 * - Fee payments are the cost of using a Scheduler to make transactions. It is 
 * a way for developers to monetize their work on the EAC.
 */
// BK Ok
library PaymentLib {
    // BK Ok
    using SafeMath for uint;

    // BK Next block Ok
    struct PaymentData {
        uint bounty;                /// The amount in wei to be paid to the executing agent of the TransactionRequest.

        address bountyBenefactor;   /// The address that the bounty will be sent to.

        uint bountyOwed;            /// The amount that is owed to the bountyBenefactor.

        uint fee;                   /// The amount in wei that will be paid to the FEE_RECIPIENT address.

        address feeRecipient;       /// The address that the fee will be sent to.

        uint feeOwed;               /// The amount that is owed to the feeRecipient.
    }

    ///---------------
    /// GETTERS
    ///---------------

    /**
     * @dev Getter function that returns true if a request has a benefactor.
     */
    // BK Ok - Internal view function
    function hasFeeRecipient(PaymentData storage self)
        internal view returns (bool)
    {
        // BK Ok
        return self.feeRecipient != 0x0;
    }

    /**
     * @dev Computes the amount to send to the feeRecipient. 
     */
    // BK Ok - Internal view function
    function getFee(PaymentData storage self) 
        internal view returns (uint)
    {
        // BK Ok
        return self.fee;
    }

    /**
     * @dev Computes the amount to send to the agent that executed the request.
     */
    // BK Ok - Internal view function
    function getBounty(PaymentData storage self)
        internal view returns (uint)
    {
        // BK Ok
        return self.bounty;
    }
 
    /**
     * @dev Computes the amount to send to the address that fulfilled the request
     *       with an additional modifier. This is used when the call was claimed.
     */
    // BK Ok - Internal view function
    function getBountyWithModifier(PaymentData storage self, uint8 _paymentModifier)
        internal view returns (uint)
    {
        // BK Ok
        return getBounty(self).mul(_paymentModifier).div(100);
    }

    ///---------------
    /// SENDERS
    ///---------------

    /**
     * @dev Send the feeOwed amount to the feeRecipient.
     * Note: The send is allowed to fail.
     */
    // BK Ok - Internal function, sends fee and has reentrancy protection, called by RequestLib.execute(...) and RequestLib.sendFee(...)
    function sendFee(PaymentData storage self) 
        internal returns (bool)
    {
        // BK Ok
        uint feeAmount = self.feeOwed;
        // BK Ok
        if (feeAmount > 0) {
            // re-entrance protection.
            // BK Ok
            self.feeOwed = 0;
            /* solium-disable security/no-send */
            // BK Ok - Limited to 2,300 gas
            return self.feeRecipient.send(feeAmount);
        }
        // BK Ok
        return true;
    }

    /**
     * @dev Send the bountyOwed amount to the bountyBenefactor.
     * Note: The send is allowed to fail.
     */
    // BK Ok - Internal function, sends bounty and has reentrancy protection, called by RequestLib.execute(...) and RequestLib.sendBounty(...)
    function sendBounty(PaymentData storage self)
        internal returns (bool)
    {
        // BK Ok
        uint bountyAmount = self.bountyOwed;
        // BK Ok
        if (bountyAmount > 0) {
            // re-entrance protection.
            // BK Ok
            self.bountyOwed = 0;
            // BK Ok - Limited to 2,300 gas
            return self.bountyBenefactor.send(bountyAmount);
        }
        // BK Ok
        return true;
    }

    ///---------------
    /// Endowment
    ///---------------

    /**
     * @dev Compute the endowment value for the given TransactionRequest parameters.
     * See request_factory.rst in docs folder under Check #1 for more information about
     * this calculation.
     */
    // BK Ok - Pure function
    function computeEndowment(
        uint _bounty,
        uint _fee,
        uint _callGas,
        uint _callValue,
        uint _gasPrice,
        uint _gasOverhead
    ) 
        public pure returns (uint)
    {
        // BK Ok - endowment = _bounty + _fee + (_callGas x _gasPrice) + (_gasOverhead x _gasPrice) + _callValue
        return _bounty
            .add(_fee)
            .add(_callGas.mul(_gasPrice))
            .add(_gasOverhead.mul(_gasPrice))
            .add(_callValue);
    }

    // BK NOTE - Comment with `maxMultiplier` may be outdated
    /*
     * Validation: ensure that the request endowment is sufficient to cover.
     * - bounty * maxMultiplier
     * - fee * maxMultiplier
     * - gasReimbursment
     * - callValue
     */
    // BK Ok - Pure function
    function validateEndowment(uint _endowment, uint _bounty, uint _fee, uint _callGas, uint _callValue, uint _gasPrice, uint _gasOverhead)
        public pure returns (bool)
    {
        // BK Ok - return _endowment >= (_bounty + _fee + (_callGas x _gasPrice) + (_gasOverhead x _gasPrice) + _callValue)
        return _endowment >= computeEndowment(
            _bounty,
            _fee,
            _callGas,
            _callValue,
            _gasPrice,
            _gasOverhead
        );
    }
}

```
