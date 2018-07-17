# RequestScheduleLib

Source file [../../../contracts/Library/RequestScheduleLib.sol](../../../contracts/Library/RequestScheduleLib.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.21;

// BK Ok
import "contracts/zeppelin/SafeMath.sol";

/**
 * @title RequestScheduleLib
 * @dev Library containing the logic for request scheduling.
 */
// BK Ok
library RequestScheduleLib {
    // BK Ok
    using SafeMath for uint;

    /**
     * The manner in which this schedule specifies time.
     *
     * Null: present to require this value be explicitely specified
     * Blocks: execution schedule determined by block.number
     * Timestamp: execution schedule determined by block.timestamp
     */
    // BK Next block Ok
    enum TemporalUnit {
        Null,           // 0
        Blocks,         // 1
        Timestamp       // 2
    }

    // BK Next block Ok
    struct ExecutionWindow {

        TemporalUnit temporalUnit;      /// The type of unit used to measure time.

        uint windowStart;               /// The starting point in temporal units from which the transaction can be executed.

        uint windowSize;                /// The length in temporal units of the execution time period.

        uint freezePeriod;              /// The length in temporal units before the windowStart where no activity is allowed.

        uint reservedWindowSize;        /// The length in temporal units at the beginning of the executionWindow in which only the claim address can execute.

        uint claimWindowSize;           /// The length in temporal units before the freezeperiod in which an address can claim the execution.
    }

    /**
     * @dev Get the `now` represented in the temporal units assigned to this request.
     * @param self The ExecutionWindow object.
     * @return The unsigned integer representation of `now` in appropiate temporal units.
     */
    // BK Ok - Public view function
    function getNow(ExecutionWindow storage self) 
        public view returns (uint)
    {
        // BK Ok
        return _getNow(self.temporalUnit);
    }

    /**
     * @dev Internal function to return the `now` based on the appropiate temporal units.
     * @param _temporalUnit The assigned TemporalUnit to this transaction.
     */
    // BK Ok - View function
    function _getNow(TemporalUnit _temporalUnit) 
        internal view returns (uint)
    {
        // BK Ok
        if (_temporalUnit == TemporalUnit.Timestamp) {
            // BK Ok
            return block.timestamp;
        } 
        // BK Ok
        if (_temporalUnit == TemporalUnit.Blocks) {
            // BK Ok
            return block.number;
        }
        /// Only reaches here if the unit is unset, unspecified or unsupported.
        // BK Ok
        revert();
    }

    /**
     * @dev The modifier that will be applied to the bounty value depending
     * on when a call was claimed.
     */
    // BK NOTE - paymentModifier = (now - firstClaimBlock) x 100 / claimWindowSize
    // BK NOTE - 0 = 0% when claimed at the firstClaimBlock, 100 = 100% when claimed just before the freeze period
    // BK Ok - View function
    function computePaymentModifier(ExecutionWindow storage self) 
        internal view returns (uint8)
    {        
        // BK Ok
        uint paymentModifier = (getNow(self).sub(firstClaimBlock(self)))
            .mul(100)
            .div(self.claimWindowSize);
        // BK NOTE - Called from RequestLib.claim(...) where there is a check to RequestLib.isClaimable(...)
        // BK NOTE - which checks RequestScheduleLib.inClaimWindow(...) below
        // BK Ok 
        assert(paymentModifier <= 100); 

        // BK Ok
        return uint8(paymentModifier);
    }

    /*
     *  Helper: computes the end of the execution window.
     */
    // BK NOTE - windowEnd = windowStart + windowSize
    // BK Ok - View function
    function windowEnd(ExecutionWindow storage self)
        internal view returns (uint)
    {
        // BK Ok
        return self.windowStart.add(self.windowSize);
    }

    /*
     *  Helper: computes the end of the reserved portion of the execution
     *  window.
     */
    // BK NOTE - reserveWindowEnd = windowStart + reserveWindowSize
    // BK Ok - View function
    function reservedWindowEnd(ExecutionWindow storage self)
        internal view returns (uint)
    {
        // BK Ok
        return self.windowStart.add(self.reservedWindowSize);
    }

    /*
     *  Helper: computes the time when the request will be frozen until execution.
     */
    // BK NOTE - freezeStart = windowStart - freezePeriod
    // BK Ok - View function
    function freezeStart(ExecutionWindow storage self) 
        internal view returns (uint)
    {
        // BK Ok
        return self.windowStart.sub(self.freezePeriod);
    }

    /*
     *  Helper: computes the time when the request will be frozen until execution.
     */
    // BK NOTE - firstClaimBlock = freezeStart - claimWindowSize
    // BK NOTE - firstClaimBlock = windowStart - freezePeriod - claimWindowSize
    // BK Ok - View function
    function firstClaimBlock(ExecutionWindow storage self) 
        internal view returns (uint)
    {
        // BK Ok
        return freezeStart(self).sub(self.claimWindowSize);
    }

    /*
     *  Helper: Returns boolean if we are before the execution window.
     */
    // BK NOTE - isBeforeWindow = now < windowStart
    // BK Ok - View function
    function isBeforeWindow(ExecutionWindow storage self)
        internal view returns (bool)
    {
        // BK Ok
        return getNow(self) < self.windowStart;
    }

    /*
     *  Helper: Returns boolean if we are after the execution window.
     */
    // BK NOTE - isAfterWindow = now > windowEnd
    // BK NOTE - isAfterWindow = now > windowStart + windowSize
    // BK Ok - View function
    function isAfterWindow(ExecutionWindow storage self) 
        internal view returns (bool)
    {
        // BK Ok
        return getNow(self) > windowEnd(self);
    }

    /*
     *  Helper: Returns boolean if we are inside the execution window.
     */
    // BK NOTE - inWindow = windowStart <= now <= windowEnd
    // BK NOTE - inWindow = windowStart <= now <= windowStart + windowSize
    // BK Ok - View function
    function inWindow(ExecutionWindow storage self)
        internal view returns (bool)
    {
        // BK Ok
        return self.windowStart <= getNow(self) && getNow(self) < windowEnd(self);
    }

    /*
     *  Helper: Returns boolean if we are inside the reserved portion of the
     *  execution window.
     */
    // BK NOTE - inReservedWindow = windowStart <= now <= reserveWindowEnd
    // BK NOTE - inReservedWindow = windowStart <= now <= windowStart + reserveWindowSize
    // BK Ok - View function
    function inReservedWindow(ExecutionWindow storage self)
        internal view returns (bool)
    {
        // BK Ok
        return self.windowStart <= getNow(self) && getNow(self) < reservedWindowEnd(self);
    }

    /*
     * @dev Helper: Returns boolean if we are inside the claim window.
     */
    // BK NOTE - inClaimWindow = firstClaimBlock <= now <= freezeStart
    // BK NOTE - inClaimWindow = windowStart - freezePeriod - claimWindowSize <= now <= windowStart - freezePeriod
    // BK Ok - View function
    function inClaimWindow(ExecutionWindow storage self) 
        internal view returns (bool)
    {
        /// Checks that the firstClaimBlock is in the past or now.
        /// Checks that now is before the start of the freezePeriod.
        // BK Ok
        return firstClaimBlock(self) <= getNow(self) && getNow(self) < freezeStart(self);
    }

    /*
     *  Helper: Returns boolean if we are before the freeze period.
     */
    // BK NOTE - isBeforeFreeze = now < freezeStart
    // BK NOTE - isBeforeFreeze = now < windowStart - freezePeriod
    // BK Ok - View function
    function isBeforeFreeze(ExecutionWindow storage self) 
        internal view returns (bool)
    {
        // BK Ok
        return getNow(self) < freezeStart(self);
    }

    // BK NOTE - Comment incorrect
    /*
     *  Helper: Returns boolean if we are before the freeze period.
     */
    // BK NOTE - isBeforeClaimWindow = now < firstClaimBlock
    // BK NOTE - isBeforeClaimWindow = now < windowStart - freezePeriod - claimWindowSize
    // BK Ok - View function
    function isBeforeClaimWindow(ExecutionWindow storage self)
        internal view returns (bool)
    {
        // BK Ok
        return getNow(self) < firstClaimBlock(self);
    }

    ///---------------
    /// VALIDATION
    ///---------------

    /**
     * @dev Validation: Ensure that the reservedWindowSize is less than or equal to the windowSize.
     * @param _reservedWindowSize The size of the reserved window.
     * @param _windowSize The size of the execution window.
     * @return True if the reservedWindowSize is within the windowSize.
     */
    // BK Ok - Pure function
    function validateReservedWindowSize(uint _reservedWindowSize, uint _windowSize)
        public pure returns (bool)
    {
        // BK Ok
        return _reservedWindowSize <= _windowSize;
    }

    /**
     * @dev Validation: Ensure that the startWindow is at least freezePeriod amount of time in the future.
     * @param _temporalUnit The temporalUnit of this request.
     * @param _freezePeriod The freezePeriod in temporal units.
     * @param _windowStart The time in the future which represents the start of the execution window.
     * @return True if the windowStart is at least freezePeriod amount of time in the future.
     */
    // BK NOTE - If now + freezePeriod == windowStart, the claim period will have ended
    // BK Ok - View function
    function validateWindowStart(TemporalUnit _temporalUnit, uint _freezePeriod, uint _windowStart) 
        public view returns (bool)
    {
        // BK Ok
        return _getNow(_temporalUnit).add(_freezePeriod) <= _windowStart;
    }

    /*
     *  Validation: ensure that the temporal unit passed in is constrained to 0 or 1
     */
    // BK Ok - Pure function
    function validateTemporalUnit(uint _temporalUnitAsUInt) 
        public pure returns (bool)
    {
        // BK NOTE - First part of the expression is redundant
        // BK Ok
        return (_temporalUnitAsUInt != uint(TemporalUnit.Null) &&
            (_temporalUnitAsUInt == uint(TemporalUnit.Blocks) ||
            _temporalUnitAsUInt == uint(TemporalUnit.Timestamp))
        );
    }
}

```
