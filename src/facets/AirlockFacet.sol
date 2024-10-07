// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {LibAirlock} from "../libraries/LibAirlock.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";
import {LibPermissions} from "../libraries/LibPermissions.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibCheck} from "../libraries/LibCheck.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";

contract AirlockFacet {
    function lockUnicornIntoGame(uint256 tokenId) external {
        uint256 availableGas = gasleft();
        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            tokenId,
            IPermissionProvider.Permission.UNICORN_AIRLOCK_IN_ALLOWED
        );
        LibAirlock.lockUnicornIntoGame(tokenId);
        LibGasReturner.returnGasToUser(
            "lockUnicornIntoGame",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function unlockUnicornOutOfGameGenerateMessageHash(
        uint256 tokenId,
        string calldata tokenURI,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        return
            LibAirlock.unlockUnicornOutOfGameGenerateMessageHash(
                tokenId,
                tokenURI,
                requestId,
                blockDeadline
            );
    }

    /// @notice Generate multiple message hashes for multiple airlock unlocks
    /// @param tokenIds The ids of the unicorns to unlock
    /// @param tokenURIs The token URIs for the unlocked unicorns
    /// @param requestIds The request ids for each unlock
    /// @param blockDeadlines The block deadlines for each unlock
    /// @return signatures The generated message hashes
    function multiUnlockUnicornsOutOfGameGenerateMessageHash(
        uint256[] memory tokenIds,
        string[] calldata tokenURIs,
        uint256[] memory requestIds,
        uint256[] memory blockDeadlines
    ) external view returns (bytes32[] memory signatures) {
        LibCheck.enforceEqualArrayLength(tokenIds, requestIds);
        LibCheck.enforceEqualArrayLength(tokenIds, tokenURIs);
        LibCheck.enforceEqualArrayLength(tokenIds, tokenURIs);

        signatures = new bytes32[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            signatures[i] = LibAirlock
                .unlockUnicornOutOfGameGenerateMessageHash(
                    tokenIds[i],
                    tokenURIs[i],
                    requestIds[i],
                    blockDeadlines[i]
                );
        }
    }

    function unlockUnicornOutOfGameWithSignature(
        uint256 tokenId,
        string calldata tokenURI,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        uint256 availableGas = gasleft();
        bytes32 hash = unlockUnicornOutOfGameGenerateMessageHash(
            tokenId,
            tokenURI,
            requestId,
            blockDeadline
        );
        require(
            SignatureChecker.isValidSignatureNow(
                LibResourceLocator.gameServerSSS(),
                hash,
                signature
            ),
            "ERC721Facet: unlockUnicornOutOfGameWithSignature -- Payload must be signed by game server"
        );
        require(
            LibServerSideSigning._checkRequest(requestId) == false,
            "ERC721Facet: unlockUnicornOutOfGameWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "ERC721Facet: unlockUnicornOutOfGameWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(requestId);
        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            tokenId,
            IPermissionProvider.Permission.UNICORN_AIRLOCK_OUT_ALLOWED
        );
        LibAirlock.unlockUnicornOutOfGame(tokenId, tokenURI);
        LibGasReturner.returnGasToUser(
            "unlockUnicornOutOfGameWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    /// @notice Execute multiple airlock unlocks with signatures at once
    /// @param tokenIds The ids of the unicorns to unlock
    /// @param tokenURIs The token URIs for the unlocked unicorns
    /// @param requestIds The request ids for each unlock
    /// @param blockDeadlines The block deadlines for each unlock
    /// @custom:emits UnicornUnlockedOutOfGame
    /// @custom:emits UnicornUnlockedOutOfGameV2
    function multiUnlockUnicornsOutOfGameWithSignatures(
        uint256[] memory tokenIds,
        string[] calldata tokenURIs,
        uint256[] memory requestIds,
        uint256[] memory blockDeadlines,
        bytes[] memory signatures
    ) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            unlockUnicornOutOfGameWithSignature(
                tokenIds[i],
                tokenURIs[i],
                requestIds[i],
                blockDeadlines[i],
                signatures[i]
            );
        }
    }

    // function forceUnlockUnicornOutOfGame(uint256 tokenId) external pure {
    // revert('AirlockFacet: forceUnlockUnicornOutOfGame currently disabled');
    // // LibERC721.enforceCallerOwnsNFT(tokenId);
    // // LibAirlock.forceUnlockUnicornOutOfGame(tokenId);
    // }

    // function setForceUnlockUnicornCooldown(uint256 cooldownSeconds) external {
    //     LibCheck.enforceIsOwnerOrGameServer();
    //     LibAirlock.airlockStorage().erc721_forceUnlockUnicornCooldown = cooldownSeconds;
    // }

    // function getForceUnlockUnicornCooldown() external view returns (uint256) {
    //     return LibAirlock.airlockStorage().erc721_forceUnlockUnicornCooldown;
    // }

    // function unicornLastForceUnlock(uint256 tokenId) external view returns (uint256) {
    //     return LibAirlock.airlockStorage().unicornLastForceUnlock[tokenId];
    // }

    // function unicornIsCoolingDown(uint256 tokenId) external view returns (bool) {
    //     return LibAirlock.unicornIsCoolingDown(tokenId);
    // }

    function unicornIsTransferable(
        uint256 tokenId
    ) external view returns (bool) {
        return LibAirlock.unicornIsTransferable(tokenId);
    }
}
