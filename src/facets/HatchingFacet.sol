// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibHatching} from "../libraries/LibHatching.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibCheck} from "../libraries/LibCheck.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";

//non genesis unicorns
contract HatchingFacet {
    //Begin hatching
    function beginHatchingWithSignature(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 inheritanceChance,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        uint256 availableGas = gasleft();
        bytes32 hash = beginHatchingGenerateMessageHash(
            roundTripId,
            tokenId,
            inheritanceChance,
            bundleId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "HatchingFacet: : beginHatching -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "HatchingFacet: : beginHatching -- Request has already been fulfilled"
        );
        LibCheck.enforceBlockDeadlineIsValid(blockDeadline);
        LibServerSideSigning._completeRequest(bundleId);
        beginHatching(roundTripId, tokenId, inheritanceChance, blockDeadline);
        LibGasReturner.returnGasToUser(
            "beginHatchingWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function beginHatchingGenerateMessageHash(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 inheritanceChance,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "BeginHatchingingPayload(uint256 roundTripId, uint256 tokenId, uint256 inheritanceChance, uint256 bundleId, uint256 blockDeadline)"
                ),
                roundTripId,
                tokenId,
                inheritanceChance,
                bundleId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    //Retry hatching

    function retryHatchingWithSignature(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        bytes32 hash = retryHatchingGenerateMessageHash(
            roundTripId,
            bundleId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "HatchingFacet: : retryHatching-- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "HatchingFacet: : retryHatching -- Request has already been fulfilled"
        );
        LibCheck.enforceBlockDeadlineIsValid(blockDeadline);
        LibServerSideSigning._completeRequest(bundleId);
        retryHatching(roundTripId);
    }

    function retryHatchingGenerateMessageHash(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "retryHatchingPayload(uint256 roundTripId, uint256 bundleId, uint256 blockDeadline)"
                ),
                roundTripId,
                bundleId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    //Finish hatching

    function finishHatchingGenerateMessageHash(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "finishHatchingPayload(uint256 roundTripId, string calldata tokenURI, uint256 bundleId, uint256 blockDeadline)"
                ),
                roundTripId,
                tokenURI,
                bundleId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    function finishHatchingWithSignature(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes calldata signature
    ) public {
        uint256 availableGas = gasleft();
        bytes32 hash = finishHatchingGenerateMessageHash(
            roundTripId,
            tokenURI,
            bundleId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "HatchingFacet: : finishHatching -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "HatchingFacet: : finishHatching -- Request has already been fulfilled"
        );
        LibCheck.enforceBlockDeadlineIsValid(blockDeadline);
        LibServerSideSigning._completeRequest(bundleId);
        finishHatching(roundTripId, tokenURI);
        LibGasReturner.returnGasToUser(
            "finishHatchingWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function beginHatching(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 inheritanceChance,
        uint256 blockDeadline
    ) internal {
        LibHatching.beginHatching(
            roundTripId,
            blockDeadline,
            tokenId,
            inheritanceChance
        );
    }

    function retryHatching(uint256 roundTripId) internal {
        LibHatching.retryHatching(roundTripId);
    }

    function finishHatching(
        uint256 roundTripId,
        string calldata tokenURI
    ) internal {
        uint256 vrfRequestId = LibHatching.getVRFRequestId(roundTripId);
        uint256 tokenId = LibHatching.getTokenId(vrfRequestId);
        LibHatching.finishHatching(
            roundTripId,
            tokenId,
            vrfRequestId,
            tokenURI
        );
    }
}
