// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IDelegatePermissions} from "../../lib/cu-osc-common/src/interfaces/IDelegatePermissions.sol";
import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";

library LibPermissions {
    function getPermissionProvider()
        internal
        view
        returns (IDelegatePermissions)
    {
        return IDelegatePermissions(LibResourceLocator.playerProfile());
    }

    function allTrue(bool[] memory booleans) private pure returns (bool) {
        uint256 i = 0;
        while (i < booleans.length && booleans[i] == true) {
            i++;
        }
        return (i == booleans.length);
    }

    // pros: we reuse this function in every previous enforceCallerOwnsNFT.
    // cons: it's not generic
    function enforceCallerOwnsNFTOrHasPermissions(
        uint256 tokenId,
        IPermissionProvider.Permission[] calldata permissions
    ) internal view {
        IDelegatePermissions pp = getPermissionProvider();
        address ownerOfNFT = LibERC721.ownerOf(tokenId);

        // Warning: this can be address(0) if the msg.sender is the delegator
        address delegator = pp.getDelegator(msg.sender);

        //Sender owns the NFT or sender's owner owns the NFT and sender has specific permission for this action.
        require(
            ownerOfNFT == msg.sender ||
                (ownerOfNFT == delegator &&
                    pp.checkDelegatePermissions(delegator, permissions)),
            "LibPermissions: Must own the NFT or have permission from owner"
        );
    }

    function enforceCallerOwnsNFTOrHasPermission(
        uint256 tokenId,
        IPermissionProvider.Permission permission
    ) internal view {
        IDelegatePermissions pp = getPermissionProvider();
        address ownerOfNFT = LibERC721.ownerOf(tokenId);

        // Warning: this can be address(0) if the msg.sender is the delegator
        address delegator = pp.getDelegator(msg.sender);

        //Sender owns the NFT or sender's owner owns the NFT and sender has specific permission for this action.
        require(
            ownerOfNFT == msg.sender ||
                (ownerOfNFT == delegator &&
                    pp.checkDelegatePermission(delegator, permission)),
            "LibPermissions: Must own the NFT or have permission from owner"
        );
    }
}
