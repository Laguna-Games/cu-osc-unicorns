// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibBreeding} from "../libraries/LibBreeding.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibCheck} from "../libraries/LibCheck.sol";

contract BreedingRetryFacet {
    //retry breeding
    function retryBreedingWithSignature(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        require(
            SignatureChecker.isValidSignatureNow(
                LibResourceLocator.gameServerSSS(),
                retryBreedingGenerateMessageHash(
                    roundTripId,
                    bundleId,
                    blockDeadline
                ),
                signature
            ),
            "Must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "Roundtrip already fulfilled"
        );
        LibCheck.enforceBlockDeadlineIsValid(blockDeadline);
        LibServerSideSigning._completeRequest(bundleId);
        LibBreeding.retryBreeding(roundTripId);
    }

    function retryBreedingGenerateMessageHash(
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        return
            LibServerSideSigning._hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "retryBreedingPayload(uint256 roundTripId, uint256 bundleId, uint256 blockDeadline)"
                        ),
                        roundTripId,
                        bundleId,
                        blockDeadline
                    )
                )
            );
    }
}
