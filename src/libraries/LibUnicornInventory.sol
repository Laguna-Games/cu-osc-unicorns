// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

/**
 * Authors: Moonstream Engineering (engineering@moonstream.to)
 * GitHub: https://github.com/moonstream-to/moonbound
 */

import {IERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {EquippedItem} from "../../lib/web3/contracts/interfaces/IInventory.sol";
import {IDelegatePermissions} from "../../lib/cu-osc-common/src/interfaces/IDelegatePermissions.sol";
import {IERC1155} from "../../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";
import {LibInventory} from "../../lib/web3/contracts/inventory/InventoryFacet.sol";
import {IInventory} from "../../lib/web3/contracts/interfaces/IInventory.sol";
import {IGem} from "../interfaces/IGem.sol";
import {IUnicornStatCache} from "../interfaces/IUnicornStats.sol";

import {LibAirlock} from "./LibAirlock.sol";
import {LibPermissions} from "./LibPermissions.sol";
import {LibUnicornDNA} from "./LibUnicornDNA.sol";
import {LibStatCache} from "./LibStatCache.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";

interface IGemsFacet {
    function transferToUnicornContract(uint256[] calldata tokenIds) external;
}

/// @custom:storage-location erc7201:games.laguna.LibUnicornInventory
library LibUnicornInventory {
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

    //  @dev Storage slot for Unicorn Inventory Storage
    bytes32 internal constant STORAGE_SLOT_POSITION =
        keccak256(
            abi.encode(
                uint256(keccak256("games.laguna.LibUnicornInventory")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function unicornInventoryStorage()
        internal
        pure
        returns (UnicornInventoryStorage storage uis)
    {
        bytes32 position = STORAGE_SLOT_POSITION;
        // solhint-disable-next-line
        assembly {
            uis.slot := position
        }
    }

    function isSigner(address account) internal view returns (bool) {
        UnicornInventoryStorage storage uis = unicornInventoryStorage();
        IERC1155 signerTerminus = IERC1155(uis.signerTerminusAddress);
        return (signerTerminus.balanceOf(account, uis.signerTerminusPoolID) >
            0);
    }

    function setSignerPool(
        address signerTerminusAddress,
        uint256 signerTerminusPoolID
    ) internal {
        UnicornInventoryStorage storage uis = unicornInventoryStorage();
        uis.signerTerminusAddress = signerTerminusAddress;
        uis.signerTerminusPoolID = signerTerminusPoolID;
    }

    function equip(
        uint256 unicornTokenId,
        uint256[] calldata slots,
        address itemAddress,
        uint256[] calldata itemTokenIds
    ) internal {
        LibInventory.InventoryStorage storage istore = LibInventory
            .inventoryStorage();

        IDelegatePermissions pp = LibPermissions.getPermissionProvider();
        address delegator = pp.getDelegator(msg.sender);
        address ownerOfNFT = LibERC721.ownerOf(unicornTokenId);

        //  caller is owner or delegate-with-permission of the Unicorn NFT
        LibPermissions.enforceCallerOwnsNFTOrHasPermission(
            unicornTokenId,
            IPermissionProvider.Permission.GEM_EQUIP_ALLOWED
        );

        require(
            LibUnicornDNA._getLifecycleStage(
                LibUnicornDNA._getDNA(unicornTokenId)
            ) == LibUnicornDNA.LIFECYCLE_ADULT,
            "equip:adult corns only"
        );
        LibAirlock.enforceUnicornIsLocked(unicornTokenId);

        for (uint8 i = 0; i < slots.length; ++i) {
            require(slots[i] <= 8, "Only 8 slots are equippable");

            //  caller is owner or delegate-with-permission of the Gem NFT
            address ownerOfGem = IERC721(itemAddress).ownerOf(itemTokenIds[i]);
            require(
                msg.sender == ownerOfGem ||
                    (ownerOfGem == delegator &&
                        pp.checkDelegatePermission(
                            delegator,
                            IPermissionProvider.Permission.GEM_EQUIP_ALLOWED
                        )),
                "equip: must own Gem"
            );
            require(
                ownerOfGem == ownerOfNFT,
                "equip: cant equip delegator gem on delegate unicorn"
            );

            //  slot is whitelisted for gems to be equipped into it
            require(
                istore.SlotEligibleItems[slots[i]][721][itemAddress][0] == 1,
                "equip:cant equip that slot"
            );

            //  Remove and burn old item in the slot
            EquippedItem memory equippedItem = istore.EquippedItems[
                istore.ContractERC721Address
            ][unicornTokenId][slots[i]];
            if (equippedItem.ItemType != 0) {
                IGem(equippedItem.ItemAddress).burn(equippedItem.ItemTokenId);
            }

            //  Make an inventory record
            istore.EquippedItems[istore.ContractERC721Address][unicornTokenId][
                slots[i]
            ] = EquippedItem({
                ItemType: 721,
                ItemAddress: itemAddress,
                ItemTokenId: itemTokenIds[i],
                Amount: 1
            });

            emit ItemEquipped(
                unicornTokenId,
                slots[i],
                721,
                itemAddress,
                itemTokenIds[i],
                1,
                msg.sender
            ); //  Is this event needed?
        }

        //  Transfer all of the gems out of owner's inventory, to the Unicorn contract
        IGemsFacet(itemAddress).transferToUnicornContract(itemTokenIds);

        //  Refresh the cache
        LibStatCache.cacheEnhancedStats(unicornTokenId);
    }

    function getEquipPreview(
        uint256 unicornTokenId,
        uint256[] calldata slots,
        uint256[] calldata gemIds
    ) internal view returns (IUnicornStatCache.Stats memory enhancedStats) {
        enhancedStats = LibStatCache.enhanceUnicornStatsEquipPreview(
            unicornTokenId,
            slots,
            gemIds
        );
    }

    function getUnicornInventory(
        uint256 unicornTokenId
    ) internal view returns (uint256[8] memory gemSlots) {
        LibInventory.InventoryStorage storage istore = LibInventory
            .inventoryStorage();

        for (uint8 i = 1; i <= 8; ++i) {
            EquippedItem memory equippedItem = istore.EquippedItems[
                istore.ContractERC721Address
            ][unicornTokenId][i];
            if (equippedItem.ItemType == 721) {
                gemSlots[i - 1] = equippedItem.ItemTokenId;
            }
        }
    }
}
