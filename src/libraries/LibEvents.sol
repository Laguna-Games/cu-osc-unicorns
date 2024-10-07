// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IUnicornStatCache} from '../interfaces/IUnicornStats.sol';

library LibEvents {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /// @notice Emitted when Unicorn statCache stats change due to hatching and evolution
    /// @param tokenId The Unicorn modified
    /// @param naturalStats The newly cached stat data
    event UnicornNaturalStatsChanged(uint256 indexed tokenId, IUnicornStatCache.Stats naturalStats);

    /// @notice Emitted when Unicorn StatCache stats change due to equipment or modifiers
    /// @param tokenId The Unicorn modified
    /// @param enhancedStats The newly cached stat data
    event UnicornEnhancedStatsChanged(uint256 indexed tokenId, IUnicornStatCache.Stats enhancedStats);

    /// ERC-4906: Metadata Update
    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    /// ERC-4906: Metadata Update
    /// @dev This event emits when the metadata of a range of tokens is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    /// @dev Emitted when a Unicorn's Gems are changed
    ///  @param requestId The request ID
    ///  @param unicornTokenId The Unicorn modified
    ///  @param owner The owner of the Unicorn
    ///  @param playerWallet The player who executed the transaction (either owner or delegate)
    event GemsEquipped(
        uint256 indexed requestId,
        uint256 indexed unicornTokenId,
        address indexed owner,
        address playerWallet
    );
}
