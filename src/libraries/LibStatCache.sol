// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibUnicornDNA} from "../libraries/LibUnicornDNA.sol";
import {IUnicornStatCache, IUnicornStatCacheAdvanced} from "../interfaces/IUnicornStats.sol";
import {LibEvents} from "../libraries/LibEvents.sol";
import {EquippedItem} from "../../lib/web3/contracts/interfaces/IInventory.sol";
import {LibInventory} from "../../lib/web3/contracts/inventory/InventoryFacet.sol";
import {IGem} from "../interfaces/IGem.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibGenes} from "../libraries/LibGenes.sol";
import {LibUnicorn} from "../libraries/LibUnicorn.sol";

//  NOTE: This Library does a lot of work with structs. Be extremely careful using
//  these instances - some pass by reference/pointer and others by copying/value:
//          * Storage variables are pointers (to chain storage) - changing one affects all pointers to the same data
//          * Assigning a struct from storage to a memory variable clones the data - changing one does not affect the other
//          * Assigning a struct from memory to another memory variable makes a pointer - both point to the same memory data
//          * Structs passed into a function are pointers - changes inside the function affect memory in the parent scope
/// @custom:storage-location erc7201:games.laguna.LibStatCache
library LibStatCache {
    //  @dev Storage slot for Stat Cache
    bytes32 internal constant STORAGE_POSITION =
        keccak256(
            abi.encode(uint256(keccak256("games.laguna.LibStatCache")) - 1)
        ) & ~bytes32(uint256(0xff));

    function statCacheStorage()
        private
        pure
        returns (LibStatCacheStorage storage lcs)
    {
        bytes32 position = STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            lcs.slot := position
        }
    }

    /// @notice DO NOT REORDER THIS STRUCT
    struct LibStatCacheStorage {
        mapping(uint256 tokenId => IUnicornStatCache.Stats stats) naturalStats;
        mapping(uint256 tokenId => IUnicornStatCache.Stats stats) enhancedStats;
    }

    //  Returns cache status in both caches
    function getStatsCached(
        uint256 tokenId
    )
        internal
        view
        returns (bool naturalStatsCached, bool enhancedStatsCached)
    {
        LibStatCacheStorage storage lcs = statCacheStorage();
        naturalStatsCached = lcs.naturalStats[tokenId].persistedToCache;
        enhancedStatsCached = lcs.enhancedStats[tokenId].persistedToCache;
    }

    //  Returns cache status in both caches for a list of tokens
    function getStatsCachedBatch(
        uint256[] calldata tokenIds
    )
        internal
        view
        returns (
            bool[] memory naturalStatsCached,
            bool[] memory enhancedStatsCached
        )
    {
        LibStatCacheStorage storage lcs = statCacheStorage();
        naturalStatsCached = new bool[](tokenIds.length);
        enhancedStatsCached = new bool[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; ++i) {
            naturalStatsCached[i] = lcs
                .naturalStats[tokenIds[i]]
                .persistedToCache;
            enhancedStatsCached[i] = lcs
                .enhancedStats[tokenIds[i]]
                .persistedToCache;
        }
    }

    //  This is probably the function you want for "current" stats of a unicorn (ignoring its gems)
    function getNaturalStatsFromCacheOrFallthrough(
        uint256 tokenId
    ) internal view returns (IUnicornStatCache.Stats memory naturalStats) {
        LibStatCacheStorage storage lcs = statCacheStorage();
        if (lcs.naturalStats[tokenId].persistedToCache) {
            return lcs.naturalStats[tokenId];
        } else {
            return getNaturalStatsFromTokenId(tokenId);
        }
    }

    //  This is probably the function you want for "current" stats of a unicorn with gems equipped
    function getEnhancedStatsFromCacheOrFallthrough(
        uint256 tokenId
    ) internal view returns (IUnicornStatCache.Stats memory enhancedStats) {
        if (tokenId > 0) {
            LibStatCacheStorage storage lcs = statCacheStorage();
            if (lcs.enhancedStats[tokenId].persistedToCache) {
                return lcs.enhancedStats[tokenId];
            } else {
                enhancedStats = enhanceUnicornStats(
                    tokenId,
                    getNaturalStatsFromCacheOrFallthrough(tokenId)
                );
                enhancedStats.dataTimestamp = uint40(block.timestamp);
                enhancedStats.persistedToCache = false;
                return enhancedStats;
            }
        } else {
            enhancedStats.dataTimestamp = uint40(block.timestamp);
            //  Everything else in the struct will default to 0
        }
    }

    //  This MUTATES the Stats struct passed in!!
    //  naturalStats => enhancedStats
    //  All other memory pointers to the Stats object passed in will be affected!
    function enhanceUnicornStats(
        uint256 tokenId,
        IUnicornStatCache.Stats memory stats
    ) private view returns (IUnicornStatCache.Stats memory) {
        uint256[16] memory totalBonuses = aggregateGemBoost(tokenId);
        stats.attack = uint16(
            ((uint256(stats.attack) + totalBonuses[0]) * totalBonuses[1]) / 100
        );
        stats.defense = uint16(
            ((uint256(stats.defense) + totalBonuses[2]) * totalBonuses[3]) / 100
        );
        stats.vitality = uint16(
            ((uint256(stats.vitality) + totalBonuses[4]) * totalBonuses[5]) /
                100
        );
        stats.accuracy = uint16(
            ((uint256(stats.accuracy) + totalBonuses[6]) * totalBonuses[7]) /
                100
        );
        stats.magic = uint16(
            ((uint256(stats.magic) + totalBonuses[8]) * totalBonuses[9]) / 100
        );
        stats.resistance = uint16(
            ((uint256(stats.resistance) + totalBonuses[10]) *
                totalBonuses[11]) / 100
        );
        stats.attackSpeed = uint16(
            ((uint256(stats.attackSpeed) + totalBonuses[12]) *
                totalBonuses[13]) / 100
        );
        stats.moveSpeed = uint16(
            ((uint256(stats.moveSpeed) + totalBonuses[14]) * totalBonuses[15]) /
                100
        );
        return stats;
    }

    function enhanceUnicornStatsEquipPreview(
        uint256 tokenId,
        uint256[] calldata slots,
        uint256[] calldata gemIds
    ) internal view returns (IUnicornStatCache.Stats memory) {
        uint256[16] memory totalBonuses = aggregateGemBoostEquipPreview(
            slots,
            gemIds
        );
        IUnicornStatCache.Stats memory stats = getNaturalStatsFromTokenId(
            tokenId
        );
        stats.attack = uint16(
            ((uint256(stats.attack) + totalBonuses[0]) * totalBonuses[1]) / 100
        );
        stats.defense = uint16(
            ((uint256(stats.defense) + totalBonuses[2]) * totalBonuses[3]) / 100
        );
        stats.vitality = uint16(
            ((uint256(stats.vitality) + totalBonuses[4]) * totalBonuses[5]) /
                100
        );
        stats.accuracy = uint16(
            ((uint256(stats.accuracy) + totalBonuses[6]) * totalBonuses[7]) /
                100
        );
        stats.magic = uint16(
            ((uint256(stats.magic) + totalBonuses[8]) * totalBonuses[9]) / 100
        );
        stats.resistance = uint16(
            ((uint256(stats.resistance) + totalBonuses[10]) *
                totalBonuses[11]) / 100
        );
        stats.attackSpeed = uint16(
            ((uint256(stats.attackSpeed) + totalBonuses[12]) *
                totalBonuses[13]) / 100
        );
        stats.moveSpeed = uint16(
            ((uint256(stats.moveSpeed) + totalBonuses[14]) * totalBonuses[15]) /
                100
        );
        return stats;
    }

    function aggregateGemBoost(
        uint256 _tokenId
    ) internal view returns (uint256[16] memory) {
        LibInventory.InventoryStorage storage istore = LibInventory
            .inventoryStorage();

        // It is assumed that 8 gem slots will be equippable.
        uint256[16][8] memory bonusList;
        for (uint i = 1; i <= 8; i++) {
            EquippedItem memory equippedItem = istore.EquippedItems[
                istore.ContractERC721Address
            ][_tokenId][i];
            if (equippedItem.ItemAddress != address(0)) {
                IGem gem = IGem(equippedItem.ItemAddress);
                bonusList[i - 1] = gem.bonuses(equippedItem.ItemTokenId);
            }
        }
        uint256[16] memory totalBonuses = aggregateBonuses(bonusList);
        for (uint i = 0; i < 8; i++) {
            totalBonuses[2 * i + 1] = totalBonuses[2 * i + 1] + 100;
        }

        return totalBonuses;
    }

    function aggregateGemBoostEquipPreview(
        uint256[] calldata slots,
        uint256[] calldata gemIds
    ) internal view returns (uint256[16] memory) {
        // It is assumed that 8 gem slots will be equippable.
        uint256[16][8] memory bonusList;
        uint256[16] memory emptyBonusList = [
            uint256(0),
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ];
        IGem gemContract = IGem(LibResourceLocator.gemNFT());
        for (uint i = 1; i <= 8; i++) {
            if (slots.length >= i) {
                bonusList[i - 1] = gemContract.bonuses(gemIds[i - 1]);
            } else {
                bonusList[i - 1] = emptyBonusList;
            }
        }
        uint256[16] memory totalBonuses = aggregateBonuses(bonusList);
        for (uint i = 0; i < 8; i++) {
            totalBonuses[2 * i + 1] = totalBonuses[2 * i + 1] + 100;
        }

        return totalBonuses;
    }

    // Assumes an 8 slot inventory
    function aggregateBonuses(
        uint256[16][8] memory bonusList
    ) internal pure returns (uint256[16] memory) {
        uint256[16] memory finalStats;
        for (uint i = 0; i < bonusList.length; i++) {
            for (uint j = 0; j < 16; j++) {
                finalStats[j] = finalStats[j] + bonusList[i][j];
            }
        }
        return finalStats;
    }

    function getNaturalStatsFromCacheWriteOnFallthrough(
        uint256 tokenId
    ) internal returns (IUnicornStatCache.Stats memory naturalStats) {
        LibStatCacheStorage storage lcs = statCacheStorage();
        if (lcs.naturalStats[tokenId].persistedToCache) {
            naturalStats = lcs.naturalStats[tokenId];
        } else {
            naturalStats = cacheNaturalStats(tokenId);
        }
    }

    function getEnhancedStatsFromCacheWriteOnFallthrough(
        uint256 tokenId
    ) internal returns (IUnicornStatCache.Stats memory enhancedStats) {
        LibStatCacheStorage storage lcs = statCacheStorage();
        if (lcs.enhancedStats[tokenId].persistedToCache) {
            enhancedStats = lcs.enhancedStats[tokenId];
        } else {
            enhancedStats = cacheEnhancedStats(tokenId);
        }
    }

    function cacheNaturalStats(
        uint256 tokenId
    ) internal returns (IUnicornStatCache.Stats memory naturalStats) {
        naturalStats = getNaturalStatsFromTokenId(tokenId);
        naturalStats.persistedToCache = true;
        statCacheStorage().naturalStats[tokenId] = naturalStats; // copy into storage
        emit LibEvents.UnicornNaturalStatsChanged(tokenId, naturalStats);
    }

    function cacheEnhancedStats(
        uint256 tokenId
    ) internal returns (IUnicornStatCache.Stats memory enhancedStats) {
        enhancedStats = enhanceUnicornStats(
            tokenId,
            getNaturalStatsFromCacheWriteOnFallthrough(tokenId)
        );
        enhancedStats.persistedToCache = true;
        statCacheStorage().enhancedStats[tokenId] = enhancedStats; //  copy into storage
        emit LibEvents.UnicornEnhancedStatsChanged(tokenId, enhancedStats);
    }

    function getNaturalStatsFromTokenId(
        uint256 tokenId
    ) internal view returns (IUnicornStatCache.Stats memory naturalStats) {
        return getNaturalStatsFromDNA(LibUnicornDNA._getDNA(tokenId));
    }

    function getNaturalStatsFromDNA(
        uint256 dna
    ) internal view returns (IUnicornStatCache.Stats memory naturalStats) {
        LibUnicornDNA.enforceDNAVersionMatch(dna);

        uint8 class = LibUnicornDNA._getClass(dna);
        uint256 age = LibUnicornDNA._getLifecycleStage(dna);

        IUnicornStatCache.Stats memory stats;

        stats.dataTimestamp = uint40(block.timestamp);
        stats.firstName = uint16(LibUnicornDNA._getFirstNameIndex(dna));
        stats.lastName = uint16(LibUnicornDNA._getLastNameIndex(dna));
        stats.class = class;
        stats.lifecycleStage = uint8(age);
        stats.breedingPoints = uint8(LibUnicornDNA._getBreedingPoints(dna));
        stats.origin = LibUnicornDNA._getOrigin(dna);
        stats.gameLocked = LibUnicornDNA._getGameLocked(dna);
        stats.limitedEdition = LibUnicornDNA._getLimitedEdition(dna);
        // stats.persistedToCache = true;

        if (
            age == LibUnicornDNA.LIFECYCLE_BABY ||
            age == LibUnicornDNA.LIFECYCLE_ADULT
        ) {
            //  no stats for eggs
            LibGenes.GeneStorage storage gs = LibGenes.geneStorage();
            LibUnicorn.UnicornStorage storage us = LibUnicorn.unicornStorage();

            if (
                gs.bodyPartIsMythic[
                    gs.bodyPartGlobalIdFromLocalId[class][1][
                        LibUnicornDNA._getBodyPart(dna)
                    ]
                ]
            ) ++stats.mythicCount;
            if (
                gs.bodyPartIsMythic[
                    gs.bodyPartGlobalIdFromLocalId[class][2][
                        LibUnicornDNA._getFacePart(dna)
                    ]
                ]
            ) ++stats.mythicCount;
            if (
                gs.bodyPartIsMythic[
                    gs.bodyPartGlobalIdFromLocalId[class][3][
                        LibUnicornDNA._getHornPart(dna)
                    ]
                ]
            ) ++stats.mythicCount;
            if (
                gs.bodyPartIsMythic[
                    gs.bodyPartGlobalIdFromLocalId[class][4][
                        LibUnicornDNA._getHoovesPart(dna)
                    ]
                ]
            ) ++stats.mythicCount;
            if (
                gs.bodyPartIsMythic[
                    gs.bodyPartGlobalIdFromLocalId[class][5][
                        LibUnicornDNA._getManePart(dna)
                    ]
                ]
            ) ++stats.mythicCount;
            if (
                gs.bodyPartIsMythic[
                    gs.bodyPartGlobalIdFromLocalId[class][6][
                        LibUnicornDNA._getTailPart(dna)
                    ]
                ]
            ) ++stats.mythicCount;

            uint256[18] memory geneId = [
                LibUnicornDNA._getBodyMajorGene(dna),
                LibUnicornDNA._getBodyMidGene(dna),
                LibUnicornDNA._getBodyMinorGene(dna),
                LibUnicornDNA._getFaceMajorGene(dna),
                LibUnicornDNA._getFaceMidGene(dna),
                LibUnicornDNA._getFaceMinorGene(dna),
                LibUnicornDNA._getHoovesMajorGene(dna),
                LibUnicornDNA._getHoovesMidGene(dna),
                LibUnicornDNA._getHoovesMinorGene(dna),
                LibUnicornDNA._getHornMajorGene(dna),
                LibUnicornDNA._getHornMidGene(dna),
                LibUnicornDNA._getHornMinorGene(dna),
                LibUnicornDNA._getManeMajorGene(dna),
                LibUnicornDNA._getManeMidGene(dna),
                LibUnicornDNA._getManeMinorGene(dna),
                LibUnicornDNA._getTailMajorGene(dna),
                LibUnicornDNA._getTailMidGene(dna),
                LibUnicornDNA._getTailMinorGene(dna)
            ];

            uint256[] memory addition = new uint256[](9);
            uint256[] memory multiplier = new uint256[](9);

            for (uint i = 0; i < 18; ++i) {
                //  loop through each gene
                if (gs.geneApplicationById[geneId[i]] == 1) {
                    //  if the gene is a multiplier...
                    multiplier[gs.geneBonusStatByGeneId[geneId[i]][1]] += gs
                        .geneBonusValueByGeneId[geneId[i]][1]; //  Add bonus 1 to corresponding stat in the multiplier array
                    multiplier[gs.geneBonusStatByGeneId[geneId[i]][2]] += gs
                        .geneBonusValueByGeneId[geneId[i]][2]; //  Add bonus 2 to corresponding stat in the multiplier array
                    multiplier[gs.geneBonusStatByGeneId[geneId[i]][3]] += gs
                        .geneBonusValueByGeneId[geneId[i]][3]; //  Add bonus 3 to corresponding stat in the multiplier array
                } else if (gs.geneApplicationById[geneId[i]] == 2) {
                    //  if the gene is an adder...
                    addition[gs.geneBonusStatByGeneId[geneId[i]][1]] += gs
                        .geneBonusValueByGeneId[geneId[i]][1]; //  Add bonus 1 to corresponding stat in the adder array
                    addition[gs.geneBonusStatByGeneId[geneId[i]][2]] += gs
                        .geneBonusValueByGeneId[geneId[i]][2]; //  Add bonus 2 to corresponding stat in the adder array
                    addition[gs.geneBonusStatByGeneId[geneId[i]][3]] += gs
                        .geneBonusValueByGeneId[geneId[i]][3]; //  Add bonus 3 to corresponding stat in the adder array
                }
            }

            stats.attack = uint16(
                us.baseStats[class][LibUnicornDNA.STAT_ATTACK]
            );
            stats.accuracy = uint16(
                us.baseStats[class][LibUnicornDNA.STAT_ACCURACY]
            );
            stats.moveSpeed = uint16(
                us.baseStats[class][LibUnicornDNA.STAT_MOVE_SPEED]
            );
            stats.attackSpeed = uint16(
                us.baseStats[class][LibUnicornDNA.STAT_ATTACK_SPEED]
            );
            stats.defense = uint16(
                us.baseStats[class][LibUnicornDNA.STAT_DEFENSE]
            );
            stats.vitality = uint16(
                us.baseStats[class][LibUnicornDNA.STAT_VITALITY]
            );
            stats.resistance = uint16(
                us.baseStats[class][LibUnicornDNA.STAT_RESISTANCE]
            );
            stats.magic = uint16(us.baseStats[class][LibUnicornDNA.STAT_MAGIC]);

            if (age == LibUnicornDNA.LIFECYCLE_ADULT) {
                //  add 20% to adults
                stats.attack += stats.attack / 5;
                stats.accuracy += stats.accuracy / 5;
                stats.moveSpeed += stats.moveSpeed / 5;
                stats.attackSpeed += stats.attackSpeed / 5;
                stats.defense += stats.defense / 5;
                stats.vitality += stats.vitality / 5;
                stats.resistance += stats.resistance / 5;
                stats.magic += stats.magic / 5;
            }

            //  compute each stat
            stats.attack += uint16(addition[LibUnicornDNA.STAT_ATTACK]);
            stats.attack += uint16(
                (stats.attack * multiplier[LibUnicornDNA.STAT_ATTACK]) / 100
            );
            if (stats.attack > 1000) stats.attack = 1000;

            stats.accuracy += uint16(addition[LibUnicornDNA.STAT_ACCURACY]);
            stats.accuracy += uint16(
                (stats.accuracy * multiplier[LibUnicornDNA.STAT_ACCURACY]) / 100
            );
            if (stats.accuracy > 1000) stats.accuracy = 1000;

            stats.moveSpeed += uint16(addition[LibUnicornDNA.STAT_MOVE_SPEED]);
            stats.moveSpeed += uint16(
                (stats.moveSpeed * multiplier[LibUnicornDNA.STAT_MOVE_SPEED]) /
                    100
            );
            if (stats.moveSpeed > 1000) stats.moveSpeed = 1000;

            stats.attackSpeed += uint16(
                addition[LibUnicornDNA.STAT_ATTACK_SPEED]
            );
            stats.attackSpeed += uint16(
                (stats.attackSpeed *
                    multiplier[LibUnicornDNA.STAT_ATTACK_SPEED]) / 100
            );
            if (stats.attackSpeed > 1000) stats.attackSpeed = 1000;

            stats.defense += uint16(addition[LibUnicornDNA.STAT_DEFENSE]);
            stats.defense += uint16(
                (stats.defense * multiplier[LibUnicornDNA.STAT_DEFENSE]) / 100
            );
            if (stats.defense > 1000) stats.defense = 1000;

            stats.vitality += uint16(addition[LibUnicornDNA.STAT_VITALITY]);
            stats.vitality += uint16(
                (stats.vitality * multiplier[LibUnicornDNA.STAT_VITALITY]) / 100
            );
            if (stats.vitality > 1000) stats.vitality = 1000;

            stats.resistance += uint16(addition[LibUnicornDNA.STAT_RESISTANCE]);
            stats.resistance += uint16(
                (stats.resistance * multiplier[LibUnicornDNA.STAT_RESISTANCE]) /
                    100
            );
            if (stats.resistance > 1000) stats.resistance = 1000;

            stats.magic += uint16(addition[LibUnicornDNA.STAT_MAGIC]);
            stats.magic += uint16(
                (stats.magic * multiplier[LibUnicornDNA.STAT_MAGIC]) / 100
            );
            if (stats.magic > 1000) stats.magic = 1000;
        }
        return stats;
    }

    function deleteCache(uint256 tokenId) internal {
        delete statCacheStorage().naturalStats[tokenId];
        delete statCacheStorage().enhancedStats[tokenId];
    }

    function updateLock(uint256 tokenId, bool lockState) internal {
        LibStatCacheStorage storage lcs = statCacheStorage();
        if (!lcs.naturalStats[tokenId].persistedToCache)
            cacheNaturalStats(tokenId);
        lcs.naturalStats[tokenId].gameLocked = lockState; //  Note: This should already be set via the DNA - setting just in case here
        lcs.naturalStats[tokenId].dataTimestamp = uint40(block.timestamp);
        emit LibEvents.UnicornNaturalStatsChanged(
            tokenId,
            lcs.naturalStats[tokenId]
        );

        if (!lcs.enhancedStats[tokenId].persistedToCache)
            cacheEnhancedStats(tokenId);
        lcs.enhancedStats[tokenId].gameLocked = lockState;
        lcs.enhancedStats[tokenId].dataTimestamp = uint40(block.timestamp);
        emit LibEvents.UnicornEnhancedStatsChanged(
            tokenId,
            lcs.enhancedStats[tokenId]
        );
    }

    function updateBreedingPoints(
        uint256 tokenId,
        uint256 breedingPoints
    ) internal {
        LibStatCacheStorage storage lcs = statCacheStorage();
        if (!lcs.naturalStats[tokenId].persistedToCache)
            cacheNaturalStats(tokenId);
        lcs.naturalStats[tokenId].breedingPoints = uint8(breedingPoints);
        lcs.naturalStats[tokenId].dataTimestamp = uint40(block.timestamp);
        emit LibEvents.UnicornNaturalStatsChanged(
            tokenId,
            lcs.naturalStats[tokenId]
        );

        if (!lcs.enhancedStats[tokenId].persistedToCache)
            cacheEnhancedStats(tokenId);
        lcs.enhancedStats[tokenId].breedingPoints = uint8(breedingPoints);
        lcs.enhancedStats[tokenId].dataTimestamp = uint40(block.timestamp);
        emit LibEvents.UnicornEnhancedStatsChanged(
            tokenId,
            lcs.enhancedStats[tokenId]
        );
    }
}
