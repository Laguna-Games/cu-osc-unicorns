// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibUnicornDNA} from "./LibUnicornDNA.sol";
import {LibStatCache} from "./LibStatCache.sol";

/// @custom:storage-location erc7201:games.laguna.cryptounicorns.LibAirlock
library LibAirlock {
    event UnicornLockedIntoGame(uint256 tokenId, address locker);
    event UnicornLockedIntoGameV2(
        uint256 indexed tokenId,
        address indexed owner,
        address indexed locker
    );
    event UnicornUnlockedOutOfGame(uint256 tokenId, address locker);
    event UnicornUnlockedOutOfGameV2(
        uint256 indexed tokenId,
        address indexed owner,
        address indexed locker
    );
    event UnicornUnlockedOutOfGameForcefully(
        uint256 timestamp,
        uint256 tokenId,
        address locker
    );
    event BatchUnlockUnicornsOutOfGame(
        uint256[] tokenIds,
        uint256 indexed requestId,
        address indexed owner,
        address indexed locker
    );

    bytes32 internal constant STORAGE_SLOT_POSITION =
        keccak256(
            abi.encode(
                uint256(keccak256("games.laguna.cryptounicorns.LibAirlock")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    struct AirlockStorage {
        // Unicorn token -> Last timestamp when it was unlocked forcefully
        mapping(uint256 => uint256) unicornLastForceUnlock;
        // After unlocking forcefully, user has to wait erc721_forceUnlockUnicornCooldown seconds to be able to transfer
        uint256 erc721_forceUnlockUnicornCooldown;
    }

    function airlockStorage()
        internal
        pure
        returns (AirlockStorage storage ss)
    {
        bytes32 position = STORAGE_SLOT_POSITION;
        // solhint-disable-next-line
        assembly {
            ss.slot := position
        }
    }

    function enforceDNAIsLocked(uint256 dna) internal pure {
        require(
            LibUnicornDNA._getGameLocked(dna),
            "LibAirlock: DNA must be locked"
        );
    }

    function enforceUnicornIsLocked(uint256 tokenId) internal view {
        require(
            LibUnicornDNA._getGameLocked(LibUnicornDNA._getDNA(tokenId)),
            "LibAirlock: Uni must be locked"
        );
    }

    function enforceDNAIsUnlocked(uint256 dna) internal pure {
        require(
            LibUnicornDNA._getGameLocked(dna) == false,
            "LibAirlock: DNA must be unlocked"
        );
    }

    function enforceUnicornIsUnlocked(uint256 tokenId) internal view {
        require(
            LibUnicornDNA._getGameLocked(LibUnicornDNA._getDNA(tokenId)) ==
                false,
            "LibAirlock: Uni must be unlocked"
        );
    }

    function enforceUnicornIsNotCoolingDown(uint256 tokenId) internal view {
        require(
            !unicornIsCoolingDown(tokenId),
            "LibAirlock: forceUnlock cooldown"
        );
    }

    function unicornIsLocked(uint256 tokenId) internal view returns (bool) {
        return LibUnicornDNA._getGameLocked(LibUnicornDNA._getDNA(tokenId));
    }

    function dnaIsLocked(uint256 dna) internal pure returns (bool) {
        return LibUnicornDNA._getGameLocked(dna);
    }

    function unicornIsCoolingDown(
        uint256 tokenId
    ) internal view returns (bool) {
        AirlockStorage storage ss = airlockStorage();
        return
            ss.unicornLastForceUnlock[tokenId] != 0 &&
            (ss.unicornLastForceUnlock[tokenId] +
                ss.erc721_forceUnlockUnicornCooldown) >=
            block.timestamp;
    }

    function enforceUnicornIsTransferable(uint256 tokenId) internal view {
        require(
            unicornIsTransferable(tokenId),
            "LibERC721: Unicorn must be unlocked from game before transfering"
        );
    }

    function unicornIsTransferable(
        uint256 tokenId
    ) internal view returns (bool) {
        return (LibAirlock.unicornIsLocked(tokenId) == false &&
            LibAirlock.unicornIsCoolingDown(tokenId) == false);
        //  TODO: add idempotence checks here
    }

    function lockUnicornIntoGame(uint256 tokenId) internal {
        lockUnicornIntoGame(tokenId, true);
    }

    function lockUnicornIntoGame(
        uint256 tokenId,
        bool emitLockedEvent
    ) internal {
        enforceUnicornIsNotCoolingDown(tokenId);
        uint256 dna = LibUnicornDNA._getDNA(tokenId);
        LibUnicornDNA.enforceDNAVersionMatch(dna);
        enforceDNAIsUnlocked(dna);
        dna = LibUnicornDNA._setGameLocked(dna, true);
        LibUnicornDNA._setDNA(tokenId, dna);
        LibStatCache.updateLock(tokenId, true);
        if (emitLockedEvent) {
            emit UnicornLockedIntoGame(tokenId, msg.sender);
            emit UnicornLockedIntoGameV2(
                tokenId,
                LibERC721.erc721Storage().owners[tokenId],
                msg.sender
            );
        }
    }

    function unlockUnicornOutOfGameGenerateMessageHash(
        uint256 tokenId,
        string calldata tokenURI,
        uint256 requestId,
        uint256 blockDeadline
    ) internal view returns (bytes32) {
        /* solhint-disable max-line-length */
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "UnlockUnicornOutOfGamePayload(uint256 tokenId, string calldata tokenURI, uint256 requestId, uint256 blockDeadline)"
                ),
                tokenId,
                tokenURI,
                requestId,
                blockDeadline
            )
        );
        return LibServerSideSigning._hashTypedDataV4(structHash);
        /* solhint-enable max-line-length */
    }

    function batchUnlockUnicornOutOfGameGenerateMessageHash(
        uint256[] memory tokenIds,
        string[] memory tokenURIs,
        uint256 requestId,
        uint256 blockDeadline
    ) internal view returns (bytes32) {
        /* solhint-disable max-line-length */
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "BatchUnlockUnicornOutOfGamePayload(uint256[] memory tokenIds, string[] memory tokenURIs, uint256 requestId, uint256 blockDeadline)"
                ),
                tokenIds,
                tokenURIs,
                requestId,
                blockDeadline
            )
        );
        return LibServerSideSigning._hashTypedDataV4(structHash);
        /* solhint-enable max-line-length */
    }

    function unlockUnicornOutOfGame(
        uint256 tokenId,
        string calldata tokenURI
    ) internal {
        unlockUnicornOutOfGame(tokenId, tokenURI, true);
    }

    function unlockUnicornOutOfGame(
        uint256 tokenId,
        string calldata tokenURI,
        bool emitUnlockEvent
    ) internal {
        _unlockUnicorn(tokenId);
        LibERC721.setTokenURI(tokenId, tokenURI);
        if (emitUnlockEvent) {
            emit UnicornUnlockedOutOfGame(tokenId, msg.sender);
            emit UnicornUnlockedOutOfGameV2(
                tokenId,
                LibERC721.erc721Storage().owners[tokenId],
                msg.sender
            );
        }
    }

    function forceUnlockUnicornOutOfGame(uint256 tokenId) internal {
        _unlockUnicorn(tokenId);
        airlockStorage().unicornLastForceUnlock[tokenId] = block.timestamp;
        emit UnicornUnlockedOutOfGameForcefully(
            block.timestamp,
            tokenId,
            msg.sender
        );
    }

    function _unlockUnicorn(uint256 tokenId) private {
        uint256 dna = LibUnicornDNA._getDNA(tokenId);
        LibUnicornDNA.enforceDNAVersionMatch(dna);
        enforceDNAIsLocked(dna);
        enforceUnicornIsNotCoolingDown(tokenId);
        dna = LibUnicornDNA._setGameLocked(dna, false);
        LibUnicornDNA._setDNA(tokenId, dna);
        LibStatCache.updateLock(tokenId, false);
    }
}
