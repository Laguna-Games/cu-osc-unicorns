// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibConstraints} from "../../lib/cu-osc-common/src/libraries/LibConstraints.sol";

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract UnicornConstraintFacetFragment {
    function checkConstraint(
        address owner,
        LibConstraints.Constraint memory constraint
    ) external view returns (bool) {}

    function checkConstraintForUserAndExtraTokens(
        address owner,
        LibConstraints.Constraint memory constraint,
        uint256[] memory extraTokensToCheck
    ) external view returns (bool) {}
}
