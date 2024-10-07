//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IUnicornStatCache, IUnicornStatCacheAdvanced} from "../interfaces/IUnicornStats.sol";
import {LibStatCache} from "../libraries/LibStatCache.sol";
import {LibContractOwner} from "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";

/// @title Unicorn StatCache
contract StatCacheFacet is IUnicornStatCacheAdvanced {
    /// @notice Returns true if the StatCache has data for the target token
    /// @param tokenId The id of a Unicorn
    /// @return naturalStatsCached True if cached, otherwise false
    /// @return enhancedStatsCached True if cached, otherwise false
    function checkUnicornStatsCached(
        uint256 tokenId
    )
        external
        view
        returns (bool naturalStatsCached, bool enhancedStatsCached)
    {
        (naturalStatsCached, enhancedStatsCached) = LibStatCache.getStatsCached(
            tokenId
        );
    }

    /// @notice Returns indexed arrays matching the input argument, with true
    ///     if the corresponding token has cached data, otherwise false.
    /// @param tokenIds Array of Unicorn tokenId's to check
    /// @return naturalStatsCached True if natural stats are cached, for each index in tokenIds
    /// @return enhancedStatsCached True if enhanced stats are cached, for each index in tokenIds
    function checkUnicornStatsCachedBatch(
        uint256[] calldata tokenIds
    )
        external
        view
        returns (
            bool[] memory naturalStatsCached,
            bool[] memory enhancedStatsCached
        )
    {
        (naturalStatsCached, enhancedStatsCached) = LibStatCache
            .getStatsCachedBatch(tokenIds);
    }

    /// @notice Returns a Unicorn's enhanced stats, from the cache if available,
    ///     otherwise by (expensive) direct lookup.
    /// @dev This is an alias of getUnicornEnhancedStats
    /// @param tokenId The id of a Unicorn
    /// @return enhancedStats The Stats of the unicorn
    function getUnicornStats(
        uint256 tokenId
    ) external view returns (IUnicornStatCache.Stats memory enhancedStats) {
        return LibStatCache.getEnhancedStatsFromCacheOrFallthrough(tokenId);
    }

    /// @notice Returns a group of Unicorns' enhanced stats
    /// @dev This is an alias of getEnhancedUnicornStatsBatch
    /// @param tokenIds, An array of Unicorn ids
    /// @return enhancedStats Corresponding stats for the unicorns specified in tokenIds
    function getUnicornStatsBatch(
        uint256[] calldata tokenIds
    ) external view returns (IUnicornStatCache.Stats[] memory enhancedStats) {
        enhancedStats = new IUnicornStatCache.Stats[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; ++i) {
            enhancedStats[i] = LibStatCache
                .getEnhancedStatsFromCacheOrFallthrough(tokenIds[i]);
        }
    }

    /// @notice Returns a Unicorn's enhanced stats AND underlying natural stats,
    ///     from the cache if available, otherwise by (expensive) direct lookups.
    /// @dev This is an alias of getUnicornEnhancedStats
    /// @param tokenId The id of a Unicorn
    /// @return naturalStats The Stats of the unicorn without Gems or enhancements
    /// @return enhancedStats The Stats of the unicorn with Gems and enhancements
    function getUnicornFullStats(
        uint256 tokenId
    )
        external
        view
        returns (
            IUnicornStatCache.Stats memory naturalStats,
            IUnicornStatCache.Stats memory enhancedStats
        )
    {
        naturalStats = LibStatCache.getNaturalStatsFromCacheOrFallthrough(
            tokenId
        );
        enhancedStats = LibStatCache.getEnhancedStatsFromCacheOrFallthrough(
            tokenId
        );
    }

    /// @notice Returns a Unicorn's natural stats, from the cache if available,
    ///     otherwise by (expensive) direct lookup.
    /// @param tokenId The id of a Unicorn
    /// @return naturalStats The Stats of the unicorn
    function getUnicornNaturalStats(
        uint256 tokenId
    ) external view returns (IUnicornStatCache.Stats memory naturalStats) {
        return LibStatCache.getNaturalStatsFromCacheOrFallthrough(tokenId);
    }

    /// @notice Returns a Unicorn's enhanced stats, from the cache if available,
    ///     otherwise by (expensive) direct lookup.
    /// @param tokenId The id of a Unicorn
    /// @return enhancedStats The Stats of the unicorn
    function getUnicornEnhancedStats(
        uint256 tokenId
    ) external view returns (IUnicornStatCache.Stats memory enhancedStats) {
        return LibStatCache.getEnhancedStatsFromCacheOrFallthrough(tokenId);
    }

    /// @notice Returns a group of Unicorns' enhanced stats
    /// @dev This is an alias of getEnhancedUnicornStatsBatch
    /// @param tokenIds, An array of Unicorn ids
    /// @return naturalStats Corresponding stats for the unicorns specified in tokenIds
    function getUnicornNaturalStatsBatch(
        uint256[] calldata tokenIds
    ) external view returns (IUnicornStatCache.Stats[] memory naturalStats) {
        naturalStats = new IUnicornStatCache.Stats[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; ++i) {
            naturalStats[i] = LibStatCache
                .getNaturalStatsFromCacheOrFallthrough(tokenIds[i]);
        }
    }

    /// @notice Returns a group of Unicorns' enhanced stats
    /// @param tokenIds, An array of Unicorn ids
    /// @return enhancedStats Corresponding stats for the unicorns specified in tokenIds
    function getUnicornEnhancedStatsBatch(
        uint256[] calldata tokenIds
    ) external view returns (IUnicornStatCache.Stats[] memory enhancedStats) {
        enhancedStats = new IUnicornStatCache.Stats[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; ++i) {
            enhancedStats[i] = LibStatCache
                .getEnhancedStatsFromCacheOrFallthrough(tokenIds[i]);
        }
    }

    /// @notice Returns a Unicorn's natural stats - from the cache if possible,
    ///     otherwise the cache will be updated.
    /// @dev May be expensive!
    /// @param tokenId The id of a Unicorn
    /// @return naturalStats The Stats of the unicorn
    function getAndCacheUnicornNaturalStats(
        uint256 tokenId
    ) external returns (IUnicornStatCache.Stats memory naturalStats) {
        return LibStatCache.getNaturalStatsFromCacheWriteOnFallthrough(tokenId);
    }

    /// @notice Returns a Unicorn's enhanced stats - from the cache if possible,
    ///     otherwise the cache will be updated.
    /// @dev This could hit BOTH caches - may be very expensive!
    /// @param tokenId The id of a Unicorn
    /// @return enhancedStats The Stats of the unicorn
    function getAndCacheUnicornEnhancedStats(
        uint256 tokenId
    ) external returns (IUnicornStatCache.Stats memory enhancedStats) {
        return
            LibStatCache.getEnhancedStatsFromCacheWriteOnFallthrough(tokenId);
    }

    /// @notice Returns a collection of Unicorns' enhanced stats - from the cache if possible,
    ///     otherwise the cache will be updated
    /// @dev This could hit BOTH caches - may be VERY EXPENSIVE!
    /// @param tokenIds The id of a Unicorn
    /// @return enhancedStats The Stats of the unicorn
    function getAndCacheUnicornEnhancedStatsBatch(
        uint256[] calldata tokenIds
    ) external returns (IUnicornStatCache.Stats[] memory enhancedStats) {
        enhancedStats = new IUnicornStatCache.Stats[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; ++i) {
            enhancedStats[i] = LibStatCache
                .getEnhancedStatsFromCacheWriteOnFallthrough(tokenIds[i]);
        }
    }

    /// @notice Writes a Unicorn's data to the StatCache, overwriting any previous data.
    /// @param tokenId, The id of a Unicorn
    /// @return naturalStats The Stats struct in the cache (dataTimestamp will match the current block if freshly written)
    /// @custom:emits UnicornNaturalStatsChanged
    function cacheUnicornNaturalStats(
        uint256 tokenId
    ) external returns (IUnicornStatCache.Stats memory naturalStats) {
        naturalStats = LibStatCache.cacheNaturalStats(tokenId);
    }

    /// @notice Writes a Unicorn's data to the StatCache, overwriting any previous data.
    /// @param tokenId, The id of a Unicorn
    /// @return enhancedStats The Stats struct in the cache (dataTimestamp will match the current block if freshly written)
    /// @custom:emits UnicornEnhancedStatsChanged
    function cacheUnicornEnhancedStats(
        uint256 tokenId
    ) external returns (IUnicornStatCache.Stats memory enhancedStats) {
        enhancedStats = LibStatCache.cacheEnhancedStats(tokenId);
    }

    /// @notice Writes a collection of Unicorns' data to the StatCache, overwriting any previous data.
    /// @param tokenIds, An array of Unicorn ids
    /// @return naturalStats The Stats structs written to cache
    /// @custom:emits UnicornNaturalStatsChanged for each unicorn
    function cacheUnicornNaturalStatsBatch(
        uint256[] calldata tokenIds
    ) external returns (IUnicornStatCache.Stats[] memory naturalStats) {
        naturalStats = new IUnicornStatCache.Stats[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; ++i) {
            naturalStats[i] = LibStatCache.cacheNaturalStats(tokenIds[i]);
        }
    }

    /// @notice Writes a collection of Unicorns' data to the StatCache, overwriting any previous data.
    /// @param tokenIds, An array of Unicorn ids
    /// @return enhancedStats The Stats structs written to cache
    /// @custom:emits UnicornEnhancedStatsChanged for each unicorn
    function cacheUnicornEnhancedStatsBatch(
        uint256[] calldata tokenIds
    ) external returns (IUnicornStatCache.Stats[] memory enhancedStats) {
        enhancedStats = new IUnicornStatCache.Stats[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; ++i) {
            enhancedStats[i] = LibStatCache.cacheEnhancedStats(tokenIds[i]);
        }
    }

    function deleteCache(uint256 tokenId) external {
        LibContractOwner.enforceIsContractOwner();
        LibStatCache.deleteCache(tokenId);
    }

    function deleteCacheBatch(uint256[] calldata tokenIds) external {
        LibContractOwner.enforceIsContractOwner();
        for (uint i = 0; i < tokenIds.length; ++i) {
            LibStatCache.deleteCache(tokenIds[i]);
        }
    }
}
