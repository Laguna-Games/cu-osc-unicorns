// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IConstraintFacet} from "../../lib/cu-osc-common/src/interfaces/IConstraintFacet.sol";
import {LibConstraintOperator} from "../../lib/cu-osc-common/src/libraries/LibConstraintOperator.sol";
import {LibConstraints} from "../../lib/cu-osc-common/src//libraries/LibConstraints.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";

contract UnicornConstraintFacet is IConstraintFacet {
    function checkConstraint(
        address owner,
        LibConstraints.Constraint memory constraint
    ) external view returns (bool) {
        require(
            LibConstraints.ConstraintType(constraint.constraintType) ==
                LibConstraints.ConstraintType.BALANCE_UNICORN,
            "UnicornConstraintFacet: cannot check given constraint."
        );
        return
            LibConstraintOperator.checkOperator(
                LibERC721.balanceOf(owner),
                constraint.operator,
                constraint.value
            );
    }

    function checkConstraintForUserAndExtraTokens(
        address owner,
        LibConstraints.Constraint memory constraint,
        uint256[] memory extraTokensToCheck
    ) external view returns (bool) {
        require(
            LibConstraints.ConstraintType(constraint.constraintType) ==
                LibConstraints.ConstraintType.BALANCE_UNICORN,
            "UnicornConstraintFacet: cannot check given constraint."
        );
        return
            LibConstraintOperator.checkOperator(
                (LibERC721.balanceOf(owner) + extraTokensToCheck.length),
                constraint.operator,
                constraint.value
            );
    }
}
