// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from "./LibUnicornDNA.sol";
import {LibAirlock} from "./LibAirlock.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";

/// @custom:storage-location erc7201:games.laguna.LibUnicorn
library LibUnicorn {
    //  @dev Storage slot for general Unicorn Storage
    bytes32 internal constant STORAGE_SLOT_POSITION =
        keccak256(
            abi.encode(uint256(keccak256("games.laguna.LibUnicorn")) - 1)
        ) & ~bytes32(uint256(0xff));

    struct UnicornStorage {
        mapping(uint256 tokenId => uint256[2] parents) unicornParents;
        // Unicorn token -> Timestamp (in seconds) when Egg hatched
        mapping(uint256 tokenId => uint256 timestamp) hatchBirthday;
        // Unicorn token -> Timestamp (in seconds) when Unicorn last bred/hatched/evolved
        mapping(uint256 tokenId => uint256 timestamp) bioClock;
        // [classId][statId] => base stat value
        mapping(uint256 classId => mapping(uint256 statId => uint256 value)) baseStats;
    }

    function unicornStorage()
        internal
        pure
        returns (UnicornStorage storage us)
    {
        bytes32 position = STORAGE_SLOT_POSITION;
        // solhint-disable-next-line
        assembly {
            us.slot := position
        }
    }

    function burnFrom(uint256 tokenId, address owner) internal {
        require(
            LibERC721.ownerOf(tokenId) == owner,
            "ERC721: Cannot burn a unicorn you don't own."
        );
        require(
            LibERC721.isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: allowance required to burn"
        );
        LibAirlock.enforceUnicornIsTransferable(tokenId);
        LibERC721.burn(tokenId);
    }

    function batchBurnFrom(uint256[] memory tokenIds, address owner) internal {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            burnFrom(tokenIds[i], owner);
        }
    }

    function batchSacrificeUnicorns(
        uint256[] memory tokenIds,
        address owner
    ) internal {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                LibUnicornDNA._getLifecycleStage(
                    LibUnicornDNA._getDNA(tokenIds[i])
                ) == LibUnicornDNA.LIFECYCLE_ADULT,
                "LibERC721: Unicorn must be an adult to be sacrificed"
            );
            burnFrom(tokenIds[i], owner);
        }
    }
}
