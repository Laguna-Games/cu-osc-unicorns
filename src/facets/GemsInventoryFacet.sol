// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {LibSignatures} from "../../lib/web3/contracts/diamond/libraries/LibSignatures.sol";
import {LibEvents} from "../libraries/LibEvents.sol";
import {LibUnicornInventory} from "../libraries/LibUnicornInventory.sol";
import {LibERC721} from "../../lib/cu-osc-common-tokens/src/libraries/LibERC721.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {DiamondReentrancyGuard} from "../../lib/web3/contracts/diamond/security/DiamondReentrancyGuard.sol";
import {IUnicornStatCache} from "../interfaces/IUnicornStats.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";

contract GemsInventoryFacet is DiamondReentrancyGuard {
    function equipGemsMessageHash(
        uint256 unicornTokenId,
        uint256[] calldata slots,
        uint256[] calldata gemIds,
        uint256 requestId,
        uint256 blockDeadline
    ) public view virtual returns (bytes32) {
        return
            LibSignatures._hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "EquipGemsPayload(uint256 unicornTokenId,uint256[] slots,uint256[] gemIds,uint256 requestId,uint256 blockDeadline)"
                        ),
                        unicornTokenId,
                        keccak256(abi.encodePacked(slots)),
                        keccak256(abi.encodePacked(gemIds)),
                        requestId,
                        blockDeadline
                    )
                )
            );
    }

    function equipGems(
        uint256 unicornTokenId,
        uint256[] calldata slots,
        uint256[] calldata gemIds,
        address signer,
        uint256 requestId,
        uint256 blockDeadline,
        bytes calldata signature
    ) public diamondNonReentrant {
        uint256 availableGas = gasleft();
        require(slots.length == gemIds.length, "equipGems: array mismatch");
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "equipGems: signature expired"
        );
        require(
            LibUnicornInventory.isSigner(signer),
            "equipGems: signer is not admin" //  SSS wallet must have a Terminus badge
        );

        bytes32 hash = equipGemsMessageHash(
            unicornTokenId,
            slots,
            gemIds,
            requestId,
            blockDeadline
        );
        require(
            SignatureChecker.isValidSignatureNow(signer, hash, signature),
            "equipGems: invalid signature"
        );

        LibUnicornInventory.equip(
            unicornTokenId,
            slots,
            LibResourceLocator.gemNFT(),
            gemIds
        );

        emit LibEvents.GemsEquipped(
            requestId,
            unicornTokenId,
            LibERC721.ownerOf(unicornTokenId),
            msg.sender
        );
        LibGasReturner.returnGasToUser(
            "equipGems",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function getUnicornInventory(
        uint256 unicornTokenId
    ) external view returns (uint256[8] memory gemSlots) {
        return LibUnicornInventory.getUnicornInventory(unicornTokenId);
    }

    function getEquipPreview(
        uint256 unicornTokenId,
        uint256[] calldata slots,
        uint256[] calldata gemIds
    ) external view returns (IUnicornStatCache.Stats memory enhancedStats) {
        require(
            slots.length == gemIds.length,
            "getEquipPreview: array mismatch"
        );
        require(
            slots.length <= 8,
            "getEquipPreview: only 8 slots are equippable"
        );
        return
            LibUnicornInventory.getEquipPreview(unicornTokenId, slots, gemIds);
    }
}
