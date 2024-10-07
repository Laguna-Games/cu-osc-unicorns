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

contract BatchAirlockFacet {
    /// @notice Lock multiple unicorns into game
    /// @param tokenIds The ids of the unicorns to lock
    /// @custom:emits UnicornLockedIntoGame
    /// @custom:emits UnicornLockedIntoGameV2
    function batchLockUnicornsIntoGame(uint256[] memory tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            LibPermissions.enforceCallerOwnsNFTOrHasPermission(
                tokenIds[i],
                IPermissionProvider.Permission.UNICORN_AIRLOCK_IN_ALLOWED
            );
            LibAirlock.lockUnicornIntoGame(tokenIds[i]);
        }
    }

    /// @notice Generate one hash to unlock a batch of unicorns at once
    /// @param tokenIds The ids of the unicorns to unlock
    /// @param tokenURIs The token URIs for the unlocked unicorns
    /// @param requestId The requestId for the batch unlock
    /// @param blockDeadline The block deadline for the batch unlock
    /// @return signature The generated message hash
    function batchUnlockUnicornsOutOfGameGenerateMessageHash(
        uint256[] memory tokenIds,
        string[] calldata tokenURIs,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32 signature) {
        LibCheck.enforceEqualArrayLength(tokenIds, tokenURIs);
        return
            LibAirlock.batchUnlockUnicornOutOfGameGenerateMessageHash(
                tokenIds,
                tokenURIs,
                requestId,
                blockDeadline
            );
    }

    /// @notice Airlock unlock multiple unicorns at once, with one signature
    /// @param tokenIds The ids of the unicorns to unlock
    /// @param tokenURIs The token URIs for the unlocked unicorns
    /// @param requestId The requestId for the batch unlock
    /// @param blockDeadline The block deadline for the batch unlock
    /// @param signature The signature for the batch unlock
    /// @custom:emits UnicornUnlockedOutOfGame
    /// @custom:emits UnicornUnlockedOutOfGameV2
    /// @custom:emits BatchUnlockUnicornsOutOfGame
    function batchUnlockUnicornsOutOfGameWithSignature(
        uint256[] memory tokenIds,
        string[] calldata tokenURIs,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        bytes32 hash = batchUnlockUnicornsOutOfGameGenerateMessageHash(
            tokenIds,
            tokenURIs,
            requestId,
            blockDeadline
        );

        require(
            SignatureChecker.isValidSignatureNow(
                LibResourceLocator.gameServerSSS(),
                hash,
                signature
            ),
            "ERC721Facet: batchUnlockUnicornsOutOfGameWithSignature -- Payload must be signed by game server"
        );
        require(
            LibServerSideSigning._checkRequest(requestId) == false,
            "ERC721Facet: batchUnlockUnicornsOutOfGameWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "ERC721Facet: batchUnlockUnicornsOutOfGameWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(requestId);

        address nftOwner = LibERC721.ownerOf(tokenIds[0]);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                nftOwner == LibERC721.ownerOf(tokenIds[i]),
                "ERC721Facet: batchUnlockUnicornsOutOfGameWithSignature -- Owner mismatch"
            );
            LibPermissions.enforceCallerOwnsNFTOrHasPermission(
                tokenIds[i],
                IPermissionProvider.Permission.UNICORN_AIRLOCK_OUT_ALLOWED
            );
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            LibAirlock.unlockUnicornOutOfGame(tokenIds[i], tokenURIs[i]);
        }

        emit LibAirlock.BatchUnlockUnicornsOutOfGame(
            tokenIds,
            requestId,
            nftOwner,
            msg.sender
        );
    }
}
