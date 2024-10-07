// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IUnicornStatCache} from '../interfaces/IUnicornStats.sol';

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract StatCacheFacetFragment {
    /// @notice Emitted when Unicorn statCache stats change due to hatching and evolution
    /// @param tokenId The Unicorn modified
    /// @param naturalStats The newly cached stat data
    event UnicornNaturalStatsChanged(uint256 indexed tokenId, IUnicornStatCache.Stats naturalStats);

    /// @notice Emitted when Unicorn StatCache stats change due to equipment or modifiers
    /// @param tokenId The Unicorn modified
    /// @param enhancedStats The newly cached stat data
    event UnicornEnhancedStatsChanged(uint256 indexed tokenId, IUnicornStatCache.Stats enhancedStats);

    /// @notice Returns true if the StatCache has data for the target token
    /// @param tokenId The id of a Unicorn
    /// @return naturalStatsCached True if cached, otherwise false
    /// @return enhancedStatsCached True if cached, otherwise false
    function checkUnicornStatsCached(
        uint256 tokenId
    ) external view returns (bool naturalStatsCached, bool enhancedStatsCached) {}

    /// @notice Returns indexed arrays matching the input argument, with true
    ///     if the corresponding token has cached data, otherwise false.
    /// @param tokenIds Array of Unicorn tokenId's to check
    /// @return naturalStatsCached True if natural stats are cached, for each index in tokenIds
    /// @return enhancedStatsCached True if enhanced stats are cached, for each index in tokenIds
    function checkUnicornStatsCachedBatch(
        uint256[] calldata tokenIds
    ) external view returns (bool[] memory naturalStatsCached, bool[] memory enhancedStatsCached) {}

    /// @notice Returns a Unicorn's enhanced stats, from the cache if available,
    ///     otherwise by (expensive) direct lookup.
    /// @dev This is an alias of getUnicornEnhancedStats
    /// @param tokenId The id of a Unicorn
    /// @return enhancedStats The Stats of the unicorn
    function getUnicornStats(uint256 tokenId) external view returns (IUnicornStatCache.Stats memory enhancedStats) {}

    /// @notice Returns a group of Unicorns' enhanced stats
    /// @dev This is an alias of getEnhancedUnicornStatsBatch
    /// @param tokenIds, An array of Unicorn ids
    /// @return enhancedStats Corresponding stats for the unicorns specified in tokenIds
    function getUnicornStatsBatch(
        uint256[] calldata tokenIds
    ) external view returns (IUnicornStatCache.Stats[] memory enhancedStats) {}

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
        returns (IUnicornStatCache.Stats memory naturalStats, IUnicornStatCache.Stats memory enhancedStats)
    {}

    /// @notice Returns a Unicorn's natural stats, from the cache if available,
    ///     otherwise by (expensive) direct lookup.
    /// @param tokenId The id of a Unicorn
    /// @return naturalStats The Stats of the unicorn
    function getUnicornNaturalStats(
        uint256 tokenId
    ) external view returns (IUnicornStatCache.Stats memory naturalStats) {}

    /// @notice Returns a Unicorn's enhanced stats, from the cache if available,
    ///     otherwise by (expensive) direct lookup.
    /// @param tokenId The id of a Unicorn
    /// @return enhancedStats The Stats of the unicorn
    function getUnicornEnhancedStats(
        uint256 tokenId
    ) external view returns (IUnicornStatCache.Stats memory enhancedStats) {}

    /// @notice Returns a group of Unicorns' enhanced stats
    /// @dev This is an alias of getEnhancedUnicornStatsBatch
    /// @param tokenIds, An array of Unicorn ids
    /// @return naturalStats Corresponding stats for the unicorns specified in tokenIds
    function getUnicornNaturalStatsBatch(
        uint256[] calldata tokenIds
    ) external view returns (IUnicornStatCache.Stats[] memory naturalStats) {}

    /// @notice Returns a group of Unicorns' enhanced stats
    /// @param tokenIds, An array of Unicorn ids
    /// @return enhancedStats Corresponding stats for the unicorns specified in tokenIds
    function getUnicornEnhancedStatsBatch(
        uint256[] calldata tokenIds
    ) external view returns (IUnicornStatCache.Stats[] memory enhancedStats) {}

    /// @notice Returns a Unicorn's natural stats - from the cache if possible,
    ///     otherwise the cache will be updated.
    /// @dev May be expensive!
    /// @param tokenId The id of a Unicorn
    /// @return naturalStats The Stats of the unicorn
    function getAndCacheUnicornNaturalStats(
        uint256 tokenId
    ) external returns (IUnicornStatCache.Stats memory naturalStats) {}

    /// @notice Returns a Unicorn's enhanced stats - from the cache if possible,
    ///     otherwise the cache will be updated.
    /// @dev This could hit BOTH caches - may be very expensive!
    /// @param tokenId The id of a Unicorn
    /// @return enhancedStats The Stats of the unicorn
    function getAndCacheUnicornEnhancedStats(
        uint256 tokenId
    ) external returns (IUnicornStatCache.Stats memory enhancedStats) {}

    /// @notice Returns a collection of Unicorns' enhanced stats - from the cache if possible,
    ///     otherwise the cache will be updated
    /// @dev This could hit BOTH caches - may be VERY EXPENSIVE!
    /// @param tokenIds The id of a Unicorn
    /// @return enhancedStats The Stats of the unicorn
    function getAndCacheUnicornEnhancedStatsBatch(
        uint256[] calldata tokenIds
    ) external returns (IUnicornStatCache.Stats[] memory enhancedStats) {}

    /// @notice Writes a Unicorn's data to the StatCache, overwriting any previous data.
    /// @param tokenId, The id of a Unicorn
    /// @return naturalStats The Stats struct in the cache (dataTimestamp will match the current block if freshly written)
    /// @custom:emits UnicornNaturalStatsChanged
    function cacheUnicornNaturalStats(uint256 tokenId) external returns (IUnicornStatCache.Stats memory naturalStats) {}

    /// @notice Writes a Unicorn's data to the StatCache, overwriting any previous data.
    /// @param tokenId, The id of a Unicorn
    /// @return enhancedStats The Stats struct in the cache (dataTimestamp will match the current block if freshly written)
    /// @custom:emits UnicornEnhancedStatsChanged
    function cacheUnicornEnhancedStats(
        uint256 tokenId
    ) external returns (IUnicornStatCache.Stats memory enhancedStats) {}

    /// @notice Writes a collection of Unicorns' data to the StatCache, overwriting any previous data.
    /// @param tokenIds, An array of Unicorn ids
    /// @return naturalStats The Stats structs written to cache
    /// @custom:emits UnicornNaturalStatsChanged for each unicorn
    function cacheUnicornNaturalStatsBatch(
        uint256[] calldata tokenIds
    ) external returns (IUnicornStatCache.Stats[] memory naturalStats) {}

    /// @notice Writes a collection of Unicorns' data to the StatCache, overwriting any previous data.
    /// @param tokenIds, An array of Unicorn ids
    /// @return enhancedStats The Stats structs written to cache
    /// @custom:emits UnicornEnhancedStatsChanged for each unicorn
    function cacheUnicornEnhancedStatsBatch(
        uint256[] calldata tokenIds
    ) external returns (IUnicornStatCache.Stats[] memory enhancedStats) {}
}

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract StatCacheFacetFragmentTestnet is StatCacheFacetFragment {
    function deleteCache(uint256 tokenId) external {}

    function deleteCacheBatch(uint256[] calldata tokenIds) external {}
}
