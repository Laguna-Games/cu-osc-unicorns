// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {LibBreeding} from "../libraries/LibBreeding.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";

contract BreedingBeginFacet {
    //Begin breeding
    function beginBreedingWithSignature(
        uint256 roundTripId,
        uint256 firstParentId,
        uint256 secondParentId,
        uint256[3] memory possibleClasses,
        uint256[3] memory classProbabilities,
        uint256 owedRBW,
        uint256 owedUNIM,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        uint256 availableGas = gasleft();
        require(
            SignatureChecker.isValidSignatureNow(
                LibResourceLocator.gameServerSSS(),
                LibBreeding.beginBreedingGenerateMessageHash(
                    roundTripId,
                    firstParentId,
                    secondParentId,
                    possibleClasses,
                    classProbabilities,
                    owedRBW,
                    owedUNIM,
                    bundleId,
                    blockDeadline
                ),
                signature
            ),
            "Breeding: beginBreeding -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "Breeding: beginBreeding -- Request has already been fulfilled"
        );
        LibServerSideSigning._completeRequest(bundleId);
        LibBreeding.enforceBeginBreedingIsValid(
            firstParentId,
            secondParentId,
            possibleClasses,
            classProbabilities,
            blockDeadline
        );
        LibBreeding.beginBreeding(
            roundTripId,
            possibleClasses,
            classProbabilities,
            blockDeadline,
            LibBreeding.createEggWithBasicDNA(),
            firstParentId,
            secondParentId,
            owedRBW,
            owedUNIM
        );
        LibGasReturner.returnGasToUser(
            "beginBreedingWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }
}
