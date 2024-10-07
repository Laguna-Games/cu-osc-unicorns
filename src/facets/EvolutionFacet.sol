// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibEvolution} from "../libraries/LibEvolution.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibCheck} from "../libraries/LibCheck.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";

contract EvolutionFacet {
    // SSS functionality
    function beginEvolutionGenerateMessageHash(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 owedRBW,
        uint256 owedUNIM,
        uint256 upgradeBooster,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "beginEvolutionPayload(uint256 roundTripId, uint256 tokenId, uint256 owedRBW, uint256 owedUNIM, uint256 upgradeBooster, uint256 bundleId, uint256 blockDeadline)"
                ),
                roundTripId,
                tokenId,
                owedRBW,
                owedUNIM,
                upgradeBooster,
                bundleId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    function beginEvolutionWithSignature(
        uint256 roundTripId,
        uint256 tokenId,
        uint256 owedRBW,
        uint256 owedUNIM,
        uint256 upgradeBooster,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        uint256 availableGas = gasleft();
        bytes32 hash = beginEvolutionGenerateMessageHash(
            roundTripId,
            tokenId,
            owedRBW,
            owedUNIM,
            upgradeBooster,
            bundleId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "Evolution: beginEvolution -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "Evolution: beginEvolution -- Request has already been fulfilled"
        );
        LibServerSideSigning._completeRequest(bundleId);
        // enforcePhasedRollout(tokenId);  //  This can be deprecated any time after 1 June 2022
        LibEvolution.beginEvolution(
            roundTripId,
            tokenId,
            blockDeadline,
            upgradeBooster
        );
        address nftOwner = LibERC721.ownerOf(tokenId);
        IERC20(LibResourceLocator.cuToken()).transferFrom(
            nftOwner,
            LibResourceLocator.gameBank(),
            owedRBW
        );
        IERC20(LibResourceLocator.unimToken()).transferFrom(
            nftOwner,
            LibResourceLocator.gameBank(),
            owedUNIM
        );
        LibGasReturner.returnGasToUser(
            "beginEvolutionWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function retryEvolutionGenerateMessageHash(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "retryEvolutionPayload(uint256 roundTripId, uint256 bundleId, uint256 blockDeadline)"
                ),
                roundTripId,
                bundleId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    function retryEvolutionWithSignature(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        bytes32 hash = retryEvolutionGenerateMessageHash(
            roundTripId,
            bundleId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "Evolution: retryEvolution -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "Evolution: retryEvolution -- Request has already been fulfilled"
        );
        LibCheck.enforceBlockDeadlineIsValid(blockDeadline);
        LibServerSideSigning._completeRequest(bundleId);
        LibEvolution.retryEvolution(roundTripId);
    }

    function finishEvolutionGenerateMessageHash(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "finishEvolutionPayload(uint256 roundTripId, string calldata tokenURI, uint256 bundleId, uint256 blockDeadline)"
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

    function finishEvolutionWithSignature(
        uint256 roundTripId,
        string calldata tokenURI,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        uint256 availableGas = gasleft();
        bytes32 hash = finishEvolutionGenerateMessageHash(
            roundTripId,
            tokenURI,
            bundleId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "Evolution: finishEvolution -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "Evolution: finishEvolution -- Request has already been fulfilled"
        );
        LibCheck.enforceBlockDeadlineIsValid(blockDeadline);
        LibServerSideSigning._completeRequest(bundleId);

        uint256 vrfRequestId = LibEvolution.getVRFRequestId(roundTripId);
        uint256 tokenId = LibEvolution.getTokenId(vrfRequestId);
        LibEvolution.finishEvolution(
            roundTripId,
            tokenURI,
            vrfRequestId,
            tokenId
        );
        LibGasReturner.returnGasToUser(
            "finishEvolutionWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }
}
