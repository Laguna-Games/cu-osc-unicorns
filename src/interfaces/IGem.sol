//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/* is ERC165 */
interface IGem {
    /// @notice Get the bonuses applied by the gem
    /// @return bonuses_ The gem bonuses
    function bonuses(uint256 tokenId) external view returns (uint256[16] memory bonuses_);

    /// @notice Burns the specified token
    function burn(uint256 tokenId) external;

    // ### Note on multiplicative bonuses
    // Gems can have 1 - 3 affixes which provide multiplicative bonuses. All of these could apply
    // to the same stat.
    // The Gems contract only allows for the registration of a single multiplicative bonus.
    //
    // Suppose that a gem has three affixes, the first of which improves attack by x_1%, the second
    // of which improves attack by x_2%, and the third of which improves attack by x_3%.
    //
    // Then the attackMultiplicativeBonusPercent for that gem can is:
    // 100 * [(1 + x_1/100)*(1 + x_2/100)*(1 + x_3/100) - 1]
    //
    //  Multiplicative bonuses max out at 255%
    //  Additive bonuses max out at 65,535
    struct GemBonuses {
        uint16 attackAdditive;
        uint8 attackMultiplicativePercent;
        uint16 defenseAdditive;
        uint8 defenseMultiplicativePercent;
        uint16 vitalityAdditive;
        uint8 vitalityMultiplicativePercent;
        uint16 accuracyAdditive;
        uint8 accuracyMultiplicativePercent;
        uint16 magicAdditive;
        uint8 magicMultiplicativePercent;
        uint16 resistanceAdditive;
        uint8 resistanceMultiplicativePercent;
        uint16 attackSpeedAdditive;
        uint8 attackSpeedMultiplicativePercent;
        uint16 moveSpeedAdditive;
        uint8 moveSpeedMultiplicativePercent;
        uint8 numBonuses;
    }
}
