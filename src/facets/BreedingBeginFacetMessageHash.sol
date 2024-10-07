// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibBreeding} from '../libraries/LibBreeding.sol';

contract BreedingBeginFacetMessageHash {

    function beginBreedingGenerateMessageHash(
        uint256 roundTripId,
        uint256 firstParentId,
        uint256 secondParentId,
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities,
        uint256 owedRBW,
        uint256 owedUNIM,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        return LibBreeding.beginBreedingGenerateMessageHash(
            roundTripId,
            firstParentId,
            secondParentId,
            possibleClasses,
            classProbabilities,
            owedRBW,
            owedUNIM,
            bundleId,
            blockDeadline
        );
    }
}
