// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibBreeding} from "../libraries/LibBreeding.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibCheck} from "../libraries/LibCheck.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";

contract BreedingFinishFacet {
    //finish breeding
    function finishBreedingWithSignature(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        uint256 availableGas = gasleft();
        require(
            SignatureChecker.isValidSignatureNow(
                LibResourceLocator.gameServerSSS(),
                finishBreedingGenerateMessageHash(
                    roundTripId,
                    tokenURI,
                    bundleId,
                    blockDeadline
                ),
                signature
            ),
            "Must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "Roundtrip already fulfilled"
        );
        LibCheck.enforceBlockDeadlineIsValid(blockDeadline);
        LibServerSideSigning._completeRequest(bundleId);

        (
            uint256 eggId,
            uint256 firstParentId,
            uint256 secondParentId
        ) = LibBreeding.getEggAndParentsIdByRoundTripId(roundTripId);

        LibBreeding.finishBreeding(
            roundTripId,
            eggId,
            firstParentId,
            secondParentId,
            tokenURI
        );
        LibGasReturner.returnGasToUser(
            "finishBreedingWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function finishBreedingGenerateMessageHash(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32 digest) {
        return
            LibServerSideSigning._hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "finishBreedingPayload(uint256 roundTripId, string calldata tokenURI, uint256 bundleId, uint256 blockDeadline)"
                        ),
                        roundTripId,
                        tokenURI,
                        bundleId,
                        blockDeadline
                    )
                )
            );
    }
}
