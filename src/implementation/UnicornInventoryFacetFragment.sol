// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Slot, EquippedItem} from '../../lib/web3/contracts/interfaces/IInventory.sol';

// NOTE: This interface has the public commands from InventoryFacet...
//  The admin methods of InventoryFacet are exposed on UnicornInventoryAdminFacetFragment

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract UnicornInventoryFacetFragment {
    struct UnicornInventoryStorage {
        uint256 version;
        address signerTerminusAddress;
        uint256 signerTerminusPoolID;
        uint256[8] gemSlots;
    }

    event ItemEquipped(
        uint256 indexed subjectTokenId,
        uint256 indexed slot,
        uint256 itemType,
        address indexed itemAddress,
        uint256 itemTokenId,
        uint256 amount,
        address equippedBy
    );

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

    function adminTerminusInfo() external view returns (address, uint256) {}

    function subject() external view returns (address) {}

    function numSlots() external view returns (uint256) {}

    function getSlotById(uint256 slotId) external view returns (Slot memory slot) {}

    function getSlotURI(uint256 slotId) external view returns (string memory) {}

    function slotIsPersistent(uint256 slotId) external view returns (bool) {}

    function maxAmountOfItemInSlot(
        uint256 slot,
        uint256 itemType,
        address itemAddress,
        uint256 itemPoolId
    ) external view returns (uint256) {}

    //  Disabled on Unicorn Diamond
    // function equip(
    //     uint256 subjectTokenId,
    //     uint256 slot,
    //     uint256 itemType,
    //     address itemAddress,
    //     uint256 itemTokenId,
    //     uint256 amount
    // ) public {}

    //  Disabled on Unicorn Diamond
    // function unequip(uint256 subjectTokenId, uint256 slot, bool unequipAll, uint256 amount) public {}

    function getEquippedItem(uint256 subjectTokenId, uint256 slot) external view returns (EquippedItem memory item) {}
}
