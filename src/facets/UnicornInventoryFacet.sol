// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

/**
 * Authors: Moonstream Engineering (engineering@moonstream.to)
 * GitHub: https://github.com/moonstream-to/moonbound
 */

// import {SignatureChecker} from '../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol';
// import {LibSignatures} from '../../lib/web3/contracts/diamond/libraries/LibSignatures.sol';
import {InventoryFacet} from '../../lib/web3/contracts/inventory/InventoryFacet.sol';

// import {LibEvents} from '../libraries/LibEvents.sol';
import {LibUnicornInventory} from '../libraries/LibUnicornInventory.sol';

contract UnicornInventoryFacet is InventoryFacet {
    function equip(uint256, uint256, uint256, address, uint256, uint256) public override {
        revert('This method is disabled');
    }

    function unequip(uint256, uint256, bool, uint256) public override {
        revert('This method is disabled');
    }

    //  This facet provides the Moonstream superclass
    //  https://github.com/moonstream-to/web3/blob/main/contracts/inventory/InventoryFacet.sol
    //  Unicorn implementation is handled in GemsInventoryFacet.sol
}
