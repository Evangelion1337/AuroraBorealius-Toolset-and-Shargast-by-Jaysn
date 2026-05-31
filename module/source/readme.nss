// ****************************************************************************
// Readme for Leveling Weapons
// By RiffRaff
// ****************************************************************************

// The Concept:
// These items actually increase in power as they are used more.
// They gain XP and levels like a character does

// Installation:
// Import the erf provided.

// Usage:
// 1) Create an item and make note of its TAG.
// 2) Create a script and name it the same name as the items TAG.
// 3) The script needs to look like this:
//     #include "rr_level_weapons"
//     void main() { Level(); }
// 4) Put the item where players can get it.

// ****************************************************************************

// Customization:

// This system is highly customizable. The file rr_level_weapons contains all
// of the important functions.

// void AddPowersByLevel(object oItem)
// This function lets you decide at what levels the items will gain certain powers

// void AddLevelMegaDamage(object oItem)
// Megadamage is a 1d100 roll of elemental damage added to every attack.
// Here you can control how devastating the weapon truly becomes.
// Be careful with megadamage, it can easily throw balance off unless
// Everyone has the same capability.

// void AddLevelDamage(object oItem)
// This function adds normal elemental damage to the weapon. (1d6, 2d12, etc)

// int GetDamageBonusValue(int iLevel)
// This function decides how much massive critial damage is added at what level

// int GetBonusValue(int iLevel)
// Allows you to change what levels people get +1, +2, etc.

// Damage Values:
// 1 = 1      // 2 = 2
// 3 = 3      // 4 = 1d6
// 5 = 1d8    // 6 = 1d10
// 7 = 1d12   // 8 = 2d8
// 9 = 2d12
// int GetArrowDamage(int iDamage)
// Allows you to change the elemental damage
// constants set in void AddLevelDamage(object oItem)

