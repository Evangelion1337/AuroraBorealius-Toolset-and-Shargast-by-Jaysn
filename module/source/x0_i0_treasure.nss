//:://////////////////////////////////////////////////
//:: X0_I0_TREASURE
//:: Modified by Shayan on Jan/05/2005
//Include library for XP1 treasure generation system.

//--------------------------------------------------

//MODIFICATIONS
//:: Modifications: When asked to generate treasure for a creature, the script
//:: now takes into account the creature's Challenge rating and then rolls for
//:: either an item from unique or high or medium or low or even the junk chest. The percentage
//:: chance of getting items from each of these chests can be varied by adjusting
//:: the constant ints below.


//:: SETTING UP THIS SCRIPT
//
// Step 1: Import in and override (If you can read this then you've done it *Duh!*).
//
//
// Step 2: Create an area -inaccessible to players- with 5 chests.
//         Change the tags of the chests to: X0_MOD_TREASURE_JUNK, X0_MOD_TREASURE_LOW, X0_MOD_TREASURE_MEDIUM
//         X0_MOD_TREASURE_HIGH, and X0_MOD_TREASURE_UNIQUE.
//
// Step 3: Give all the chests an inventory, and fill them up with items that you want generated in random treasure
//         generation. Make sure that you put appropriate items in appropriate chests. IE: Put items of little value in
//         the junk chest, and items of great significance in the Unique chest.
//
// Step 4: Test out the treasure system. If you don't like the percentage of generation you can always change the values below.
//
//


//::
//:: Steps in treasure generation for a monster (with this script):
//::
//:: Step 1:
//::        Rolls a dice with 100 faces to see if a value of greater than BK_CHANCE_OF_N0_MONSTERTREASURE (refer to below)
//::        comes up. If not then it stops and no random treasure is generated.
//::
//:: Step 2:
//::       Checks for any area specific chest, if there is one then treasure is generated from there (Note: This is generated
//::       using BioWare's random treasure script). If there is no area specific chest, then it will look in the module for a
//::       Module wide monster chest (Note: This is generated using BioWare's random treasure script).
//::
//:: Step 3:
//::       Now if there aren't any monster specific or base area chest, then the treasure system looks for any general Module wide chests.
//::       HERE is where this script modification comes into work.
//::              - Assuming you have setup the system appropriately, there are 5 chests: Junk, Low, Medium, High and Unique.
//::              - Now the script takes into account the creature's challenge rating and rolls against the values as explained by
//::                Probablity of generation (see below).
//::              - In a nutshell, Creatures with high Challenge Rating (or CR) will have a better chance of spawning Unique item(s).
//::                Creatures with low CR will most likely spawn items from the junk,low or medium chest (it all depends on the dice rolls)
//::              - Essentially the higher the CR the better the items.
//::

//:: NOTE: Items in the "Unique" chest will/may spawn again. Unique does not mean once only. There is no database use in this script
//         hence nothing is ever persistent. Unique chest is simply a chest that should ideally contain items of higher 'value' than
//         the junk, low, medium, or high chests.



//:: Formula used for generation is explained in the appropriate method.
//:: Never fear... all other functions of the treasure script works as per normal
//:: IE: Generating a specific treasure from a chest, etc.


//
//:: Probability of Generation for Item from chest (Unique, High, Medium, or Low)


//             XXXXX_SPAWN_MAX_PERCENTAGE
// = ---------------------------------------------   X  (Creature's challenge rating)^2
//   (XXXXX_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR)^2)


//::NOTE: XXXX_SPAWN_MAX_PERCENTAGE and XXXX_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR refers to the constants below.


const int BK_CHANCE_OF_N0_MONSTERTREASURE = 65;

const float LOW_SPAWN_MAX_PERCENTAGE = 100.0;
const float LOW_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR = 60.0;

const float MEDIUM_SPAWN_MAX_PERCENTAGE = 100.0;
const float MEDIUM_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR = 80.0;


const float HIGH_SPAWN_MAX_PERCENTAGE = 100.0;
const float HIGH_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR = 100.0;

const float UNIQUE_SPAWN_MAX_PERCENTAGE = 100.0;
const float UNIQUE_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR = 200.0;


//NOTE: There is no adjustable value for the Junk chest. If all else fails, an item from the junk chest will be generated atleast.



// Example: Take a creature with CR 20. Given that it passes the Step 1 of the treasure generation phase,
//          and there are no area specfic and base area chests, then:
//                                                                       100
// The chances of it spawning with item(s) from the 'Low' chest is:    ------- X 20^2 = 11.1%
//                                                                       60^2
//
//                                                                       100
// The chances of it spawning with item(s) from the 'Medium' chest is:  ------- X 20^2 = 6.25%
//                                                                       80^2
//
//                                                                       100
// The chances of it spawning with item(s) from the 'High' chest is:  ------- X 20^2 = 4%
//                                                                       100^2
//
//                                                                       100
// The chances of it spawning with item(s) from the 'Unique' chest is:  ------- X 20^2 = 0.05%
//                                                                       100^2


//So in this case the creature is most likely to spawn with an item from the Junk chest as the chances of it getting any item from the other
//chests are very low.


// Example 2: Take a creature with CR 40. Given that it passes the Step 1 of the treasure generation phase,
//          and there are no area specfic and base area chests, then:
//                                                                       100
// The chances of it spawning with item(s) from the 'Low' chest is:    ------- X 40^2 = 44.4%
//                                                                       60^2
//
//                                                                       100
// The chances of it spawning with item(s) from the 'Medium' chest is:  ------- X 40^2 = 25%
//                                                                       80^2
//
//                                                                       100
// The chances of it spawning with item(s) from the 'High' chest is:  ------- X 40^2 = 16%
//                                                                       100^2
//
//                                                                       100
// The chances of it spawning with item(s) from the 'Unique' chest is:  ------- X 40^2 = 4%
//                                                                       100^2

//So in this case the creature is most likely to spawn with an item from the Low, or Medium chests as the chances of it getting any item from the other
//chests are less.


//Note: Depending on the the amount of treasure you want distributed adjust the above values. If you are running a low treasure module
//      then lower the percentage the better. If you are running a module with valuable loot given by all monsters then, of course higher the
//      percentage the better.


// Tags for the module-wide containers
string sModContJunk =     "X0_MOD_TREASURE_JUNK";
string sModContLow  =     "X0_MOD_TREASURE_LOW";
string sModContMed  =     "X0_MOD_TREASURE_MEDIUM";
string sModContHigh =     "X0_MOD_TREASURE_HIGH";
string sModContUniq =     "X0_MOD_TREASURE_UNIQUE";




//:: Throw dices to determine whether the PC is eligable for an Item Spawn
//:: creatureCR is the spawned creature's (IE: OBJECT_SELF) challenge rating.
//:: pMax is the Maximum percentage chance of item generation at cMax.
//:: cMax is the Highest creature's challenge rating.
//:: IE: If the pMax == 100, and cMax == 40, then the chance of an item
//:: spawn on a creature with challenge rating of 40 is 100%.
//::
//:: For all values above @threshold, returns TRUE. IE: Will spawn item.
//:: The chance of item generation is determined using a quardratic formula:
//:: Probability of Generation = (pMax/(cMax)^2)*(creatureCR)^2
//::
//:: Using the above example, this means that the chance of a unique item spawn
//:: on a creature with CR 20 is: 25%
//::
//:: WARNING: cMax squared must be greater than pMax AND creatureCR must be less than cMax
//::          for this to function properly... other wise it will always return true. (Calculate the
//::          probability for yourself and see ;)!!
int RollForItemSpawn(float creatureCR, float pMax = 100.0, float cMax = 40.0);

//return the chest appropriate to reward the PC
string GetAppropriateChest(float fRating);

/*
MAIN CONCEPT:
The module builder creates some base containers and fills them
with instances of the treasure items that s/he wants to appear
randomly. The actual treasure containers then randomly pick from
the contents of these base containers to generate their own
contents.

--------------------------------------------------

SETUP:

Create four module-wide base containers (for low, medium, high,
and unique treasure items) and place them anywhere in your
module. Make sure that they are in locations inaccessible to the
players, though!

Give these module-wide base containers these tags (or just use the
blueprints):

    X0_MOD_TREASURE_LOW       - low-level treasure
    X0_MOD_TREASURE_MED       - medium-level treasure
    X0_MOD_TREASURE_HIGH      - high-level treasure
    X0_MOD_TREASURE_UNIQ      - unique treasure items

Fill the instances of these base containers with appropriate treasure
for your module.

For any areas where you want finer control over the treasure,
simply create additional base containers (you don't need all four
-- any one that you skip will fall back to the module-wide version)
and place them in the area. Give them these tags (same just without
the "MOD"):

    X0_TREASURE_LOW       - low-level treasure
    X0_TREASURE_MED       - medium-level treasure
    X0_TREASURE_HIGH      - high-level treasure
    X0_TREASURE_UNIQ      - unique treasure items

For any treasure container, use one of the following scripts
as BOTH the OnOpen/OnDeath handler:

Any Treasure: x0_o2_any{low,med,high,uniq}
Books (book, scroll): x0_o2_book{low,med,high,uniq}
Potions: x0_o2_potn{low,med,high,uniq}
Armor (armor, shield, helm, boots, etc): x0_o2_arm{low,med,high,uniq}
Weapon: x0_o2_weap{low,med,high,uniq}
Gold: x0_o2_gold{low,med,high,uniq}

Others may also be added.

MONSTER/NPC TREASURE
--------------------
If you would like to have special monster treasure (monster treasure
defaults to low treasure otherwise), you can also add any of these
base chests:

X0_TREASURE_MONSTER_<monster tag> - treasure found on monsters with
                                    the given tag. This will strip off
                                    any trailing digits, so for instance,
                                    NW_KOBOLD1, NW_KOBOLD2, NW_KOBOLD005
                                    would all end up checking the chest
                                    X0_TREASURE_MONSTER_NW_KOBOLD.

X0_TREASURE_MONSTER_<racialtype> - treasure found on monsters of the given
                                   racialtype. Ex:
                                   X0_TREASURE_MONSTER_ELF
                                   X0_TREASURE_MONSTER_UNDEAD
                                   The spelling matches that used in the
                                   RACIALTYPE_* constants.

X0_TREASURE_MONSTER       - generic treasure found on all monsters/NPCs
                            in the module.

To use monster treasure, use the default OnSpawn script nw_c2_default9
or modify the OnSpawn script as follows:

- Replace #include "nw_o2_coninclude" with #include "x0_i0_treasure"
- Replace GenerateNPCTreasure(); with CTG_GenerateNPCTreasure();
- If you prefer to generate monster treasure from the general chests,
  you can also add a parameter to CTG_GenerateNPCTreasure(); to
  specify whether the treasure generated should be low/medium/high/uniq.
  See the comments to that function for details.

--------------------------------------------------

DETAILS:

Each treasure container has a script that looks for the
nearest object with the tag matching the type of
treasure.

When the treasure-generating scripts look for a container,
they will take the nearest container in the local, then
fall back to the module-wide container. If no container can
be found, they will fall back on the standard random treasure
generation system.

The treasure generation system will randomly select from
1-3 items from whatever items are in the nearest container.
Each item has a 50/50 chance of being replaced by a random
amount of coin based on the standard treasure generation
system.

IMPORTANT NOTE ON PROBABILITY:
Each item in the chest has an equal probability of being
selected. To control the probability of any given item
appearing, simply place multiple copies of it in the container.

Because of the stacking rules, there is a slight modification
to this. Ammunition/throwing weapons will have a probability
equal to the number of stacks in the chest, since the max stack
size is the default stack size. Potions, scrolls, and gems, however,
will be counted individually to determine the probability even if
they are stacked, since their default stack size is 1.

To control the size of the stack that actually gets created, you
should create a blueprint that has the appropriate stack size.
You can adjust the stack size of the instance you stuff into the
base container to whatever you want afterwards; the blueprint's
stack size will control what

There are scripts that will cause only specific types of items
to be selected from the container of the specified level --
eg, only books/scrolls, or only weapons or armor, etc -- useful
for bookcases or for weapon racks, & so on.

The unique treasure chest will only place each item in the
chest once, will never place more than one item, and will
never replace the item with coin.

Advantages of this system:
- Complete control over which items can appear in a
  module or in an area.

- Thematically-appropriate treasure can be placed in each
  area.

- Easy for module builders to set up.

- Trivial to add new items to the treasure distribution.

- Trivial to adjust probabilities of items appearing.

- Easy to have unique treasure items showing up randomly.

Disadvantages of this system:
- No level-specific treasure generation. This system is thus
  NOT appropriate for an area that is intended to scale to
  radically-different levels. Rather, it is appropriate for
  use where the levels of the characters are roughly known
  to the module designer and the treasure can be designed to
  match.

- No class-specific treasure generation planned for now.
  (However, I may add something to increase probability of
  certain items popping up, optionally. TBD.)

For XP1, we feel this is a good tradeoff, but this should
be kept in mind when deciding whether to use this system or
the original treasure generation system in user-made modules.

-- NN

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/16/2002
//:://////////////////////////////////////////////////

// For legacy treasure generation
#include "nw_o2_coninclude"
/**********************************************************************
 * CONSTANTS
 **********************************************************************/

// * this is the percent chance that no treasure will be spawned by a creature dying



// Tags for the area-specific containers
string sContJunk  =     "X0_TREASURE_JUNK";
string sContLow  =     "X0_TREASURE_LOW";
string sContMed  =     "X0_TREASURE_MED";
string sContHigh =     "X0_TREASURE_HIGH";
string sContUniq =     "X0_TREASURE_UNIQ";

// Tag for the monster-specific containers
string sContMonster =     "X0_TREASURE_MONSTER";

// Gold item ResRef
string sGoldResRef = "NW_IT_GOLD001";

// Varname holding the number of treasure items
string sNumTreasureItemsVarname = "X0_NUM_TREASURE_ITEMS";

// Varname holding the base type of each treasure item
string sBaseTypeVarname = "X0_BASE_TYPE_TREASURE";
// Varname holding a reference to each treasure item
string sTreasureItemVarname = "X0_TREASURE_ITEM";

// Varname indicating that the treasure container has been filled
string sTreasureGeneratedVarname = "X0_TREASURE_HAS_BEEN_GENERATED";


// Major treasure categories

int TREASURE_TYPE_LOW    = 1;
int TREASURE_TYPE_MED    = 2;
int TREASURE_TYPE_HIGH   = 3;
int TREASURE_TYPE_UNIQUE = 4;
int TREASURE_TYPE_MONSTER = 5;
int TREASURE_TYPE_JUNK = 6;

// Special generalized base types.
// Giving these large values to make sure they never
// conflict with the actual base type values -- that
// would cause those base types to be non-specifiable.
int TREASURE_BASE_TYPE_WEAPON = 13000;
int TREASURE_BASE_TYPE_WEAPON_NOAMMO = 13001;
int TREASURE_BASE_TYPE_WEAPON_RANGED = 13002;
int TREASURE_BASE_TYPE_WEAPON_MELEE = 13003;
int TREASURE_BASE_TYPE_ARMOR = 13004;
int TREASURE_BASE_TYPE_CLOTHING = 13005;

// Probability of a single item being generated,
// in percentage
int TREASURE_PROBABILITY_1 = 70;

// Probability of two items being generated,
// in percentage
int TREASURE_PROBABILITY_2 = 20;

// Probability of an item being converted to gold
int TREASURE_GOLD_PROBABILITY = 35;

// Multiplier to use on the value of an item to convert it to gold
float X0_GOLD_MODIFIER = 0.50;

/**********************************************************************
 * FUNCTION PROTOTYPES
 *
 * All functions prefixed with CTG for "container treasure generation".
 **********************************************************************/
// Get the number of items to generate
// Returns an integer from 1-3, probabilities
// determined by the values of the constants
// TREASURE_PROBABILITY_1 & _2.
int CTG_GetNumItems();

// Get the number of items in a base container.
int CTG_GetNumItemsInBaseContainer(object oBaseCont);

// Determine whether an item should actually just be gold.
// Returns TRUE or FALSE.
// Probability controlled by constant TREASURE_GOLD_PROBABILITY
int CTG_IsItemGold();

// Find and return the right monster container, if
// available.
object CTG_GetMonsterBaseContainer(object oSource=OBJECT_SELF);

// Locate the base container of the appropriate type closest to
// oSource.
// Possible values for nTreasureType:
//     TREASURE_TYPE_LOW
//     TREASURE_TYPE_MED
//     TREASURE_TYPE_HIGH
//     TREASURE_TYPE_UNIQUE
object CTG_GetNearestBaseContainer(int nTreasureType, object oSource=OBJECT_SELF);

// Get the module-wide base container of the appropriate type.
// Possible values for nTreasureType:
//     TREASURE_TYPE_LOW
//     TREASURE_TYPE_MED
//     TREASURE_TYPE_HIGH
//     TREASURE_TYPE_UNIQUE
object CTG_GetModuleBaseContainer(int nTreasureType);

// Get the specified item out of the given base container's inventory
object CTG_GetTreasureItem(object oBaseCont, int nItemNum);

// Test if treasure has been generated in the given object
int CTG_GetIsTreasureGenerated(object oCont);

// Set whether treasure has been generated
void CTG_SetIsTreasureGenerated(object oCont, int bGenerated=TRUE);

// Create random treasure items of the appropriate type
// in the specified container. Will typically be called
// by a script on a treasure container.
//
// Possible values for nTreasureType:
//     TREASURE_TYPE_LOW
//     TREASURE_TYPE_MED
//     TREASURE_TYPE_HIGH
//     TREASURE_TYPE_UNIQUE
void CTG_CreateTreasure(int nTreasureType, object oAdventurer, object oCont=OBJECT_SELF);

// Starting from the specified item position, return the first
// item that matches one of the three base types.
//
// nBaseType1 may also be passed in as a special custom type,
// which will OVERRIDE any other specified base types:
//
//  TREASURE_BASE_TYPE_WEAPON (for any weapon type)
//  TREASURE_BASE_TYPE_WEAPON_NOAMMO (for any weapon but ammunition)
//  TREASURE_BASE_TYPE_WEAPON_RANGED (for any ranged weapon)
//  TREASURE_BASE_TYPE_WEAPON_MELEE (for any melee weapon)
//  TREASURE_BASE_TYPE_ARMOR (for armor, shields)
//  TREASURE_BASE_TYPE_CLOTHING (for belts, boots, bracers,
//                              cloaks, helms, gloves)
object CTG_GetSpecificBaseTypeTreasureItem(object oBaseCont, int nItemNum, int nBaseType1=BASE_ITEM_INVALID, int nBaseType2=BASE_ITEM_INVALID, int nBaseType3=BASE_ITEM_INVALID);


// Create treasure of the appropriate treasure level and matching one
// of up to three different base types in the specified container.
//
// Possible values for nTreasureType:
//     TREASURE_TYPE_LOW
//     TREASURE_TYPE_MED
//     TREASURE_TYPE_HIGH
//     TREASURE_TYPE_UNIQUE
//
// Possible values for nBaseType1/2/3: any BASE_ITEM_* constant.
//
// If nBaseType1 is passed in as invalid, NO TYPE CHECKING WILL BE DONE.
//
// nBaseType1 may also be passed in as a special custom type,
// which will OVERRIDE any other specified base types:
//
//  TREASURE_BASE_TYPE_WEAPON (for any weapon type)
//  TREASURE_BASE_TYPE_WEAPON_NOAMMO (for any weapon but ammunition)
//  TREASURE_BASE_TYPE_WEAPON_RANGED (for any ranged weapon)
//  TREASURE_BASE_TYPE_WEAPON_MELEE (for any melee weapon)
//  TREASURE_BASE_TYPE_ARMOR (for armor, shields)
//  TREASURE_BASE_TYPE_CLOTHING (for belts, boots, bracers,
//                              cloaks, helms, gloves)
//
void CTG_CreateSpecificBaseTypeTreasure(int nTreasureType, object oAdventurer, object oCont, int nBaseType1=BASE_ITEM_INVALID, int nBaseType2=BASE_ITEM_INVALID, int nBaseType3=BASE_ITEM_INVALID);

// Create gold treasure in the specified container.
void CTG_CreateGoldTreasure(int nTreasureType, object oAdventurer, object oCont=OBJECT_SELF);

// Create treasure on an NPC.
// This function will typically be called from within the
// NPC's OnSpawn handler.
// Note that this defaults to TREASURE_TYPE_MONSTER, which uses
// the monster-specific treasure chests and falls back to low-
// level treasure if none exist.
void CTG_GenerateNPCTreasure(int nTreasureType=5, object oNPC=OBJECT_SELF);

// Check if the item's base type is of the given base type
int CTG_GetIsBaseType(int nItemBaseType, int nBaseType1=BASE_ITEM_INVALID, int nBaseType2=BASE_ITEM_INVALID, int nBaseType3=BASE_ITEM_INVALID);

// Check if the item's base type is a weapon
int CTG_GetIsWeapon(int nItemBaseType);

// Check if the item's base type is a weapon but not ammunition
int CTG_GetIsWeaponNoammo(int nItemBaseType);

// Check if the item's base type is a ranged weapon
int CTG_GetIsRangedWeapon(int nItemBaseType);

// Check if the item's base type is a melee weapon
int CTG_GetIsMeleeWeapon(int nItemBaseType);

// Check if the item's base type is armor
int CTG_GetIsArmor(int nItemBaseType);

// Check if the item's base type is clothing
int CTG_GetIsClothing(int nItemBaseType);

// Tack on the appropriate racialtype suffix
string CTG_GetRacialtypeChestTag(string sBaseTag, object oSource);

/**********************************************************************
 * PRIVATE FUNCTION DEFINITIONS
 * These functions are deliberately not prototyped and not intended
 * for use outside this library.
 **********************************************************************/

//:: Throw dices to determine whether the PC is eligable for an Item Spawn
//:: creatureCR is the spawned creature's (IE: OBJECT_SELF) challenge rating.
//:: pMax is the Maximum percentage chance of item generation at cMax.
//:: cMax is the Highest creature's challenge rating.
//:: IE: If the pMax == 100, and cMax == 40, then the chance of an item
//:: spawn on a creature with challenge rating of 40 is 100%.
//::
//:: For all values above @threshold, returns TRUE. IE: Will spawn item.
//:: The chance of item generation is determined using a quardratic formula:
//:: Probability of Generation = (pMax/(cMax)^2)*(creatureCR)^2
//::
//:: Using the above example, this means that the chance of a unique item spawn
//:: on a creature with CR 20 is: 25%
//::
//:: WARNING: cMax squared must be greater than pMax AND creatureCR must be less than cMax
//::          for this to function properly... other wise it will always return true. (Calculate the
//::          probability for yourself and see ;)!!

int RollForItemSpawn(float creatureCR, float pMax = 40.0, float cMax = 100.0)
{
       cMax = cMax*cMax;
       creatureCR = creatureCR*creatureCR;
       float oMax = pMax/cMax;
       float detPercentage = oMax*creatureCR;

       //to make detPercentage a whole number
       detPercentage = detPercentage*1000.0;
       if(detPercentage < 0.5)
       {
         detPercentage = 0.0;
       }
       int detChance = FloatToInt(detPercentage);


       //returns TRUE if the dice roll
       int nDiceRoll = Random(100000) + 1;
       return (nDiceRoll <= detChance);
}

string GetAppropriateChest(float fRating)
{
    int UniqueRoll = RollForItemSpawn(fRating, UNIQUE_SPAWN_MAX_PERCENTAGE, UNIQUE_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR);
    int HighRoll = RollForItemSpawn(fRating, HIGH_SPAWN_MAX_PERCENTAGE, HIGH_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR);
    int MediumRoll = RollForItemSpawn(fRating, MEDIUM_SPAWN_MAX_PERCENTAGE, MEDIUM_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR);
    int LowRoll = RollForItemSpawn(fRating,LOW_SPAWN_MAX_PERCENTAGE, LOW_SPAWN_MAX_PERCENTAGE_AT_CREATURE_CR);

    if(UniqueRoll)
    {
        return sModContUniq;
    }
    else if (HighRoll)
    {
        return sModContHigh;
    }
    else if (MediumRoll)
    {
        return sModContMed;
    }
    else if (LowRoll)
    {
        return sModContLow;
    }
    else
    {   //or junk
        return sModContJunk;
    }

}
// This function deliberately not prototyped. Should not be used
// outside this library.
// Test whether a treasure container has been initialized for
// specific base treasure type use.
int CTG_GetIsContainerInitialized(object oBaseCont)
{
    return GetLocalInt(oBaseCont, "X0_CONTAINER_INITIALIZED");
}

// This function deliberately not prototyped. Should not be used
// outside this library.
// Set whether a treasure container has been initialized for
// specific base treasure type use.
void CTG_SetIsContainerInitialized(object oBaseCont, int bInit=TRUE)
{
    SetLocalInt(oBaseCont, "X0_CONTAINER_INITIALIZED", bInit);
}

// This function deliberately not prototyped. Should not be used
// outside this library.
// Initialize a treasure container to store the items contained
// inside as local variables on the container.
void CTG_InitContainer(object oBaseCont)
{
    // don't do this twice
    if (CTG_GetIsContainerInitialized(oBaseCont)) {return;}
    // initialize
    int nItems = CTG_GetNumItemsInBaseContainer(oBaseCont);
    int i;
        object oTmp = OBJECT_INVALID;
        oTmp = GetFirstItemInInventory(oBaseCont);
        for (i=0; i < nItems && GetIsObjectValid(oTmp); i++)
        {
            // Store the item and its base type as local vars on
            // the container object itself.
            string sIndex = IntToString(i);
            string sVar = sBaseTypeVarname + sIndex;
            SetLocalInt(oBaseCont, sVar, GetBaseItemType(oTmp));
            sVar = sTreasureItemVarname + sIndex;
            SetLocalObject(oBaseCont, sVar, oTmp);

            oTmp = GetNextItemInInventory(oBaseCont);
         }

    // mark as initialized
    CTG_SetIsContainerInitialized(oBaseCont);
}


/**********************************************************************
 * FUNCTION DEFINITIONS
 **********************************************************************/
 // Get the number of items to generate
// Returns an integer from 1-3, probabilities
// determined by the values of the constants
// TREASURE_PROBABILITY_1 & _2.
int CTG_GetNumItems()
{
    int nRoll = d100();

    if (nRoll < TREASURE_PROBABILITY_1) {
        return 1;
    } else if (nRoll < (TREASURE_PROBABILITY_1 + TREASURE_PROBABILITY_2)) {
        return 2;
    }
    return 3;
}


// Get the number of items in a base container
int CTG_GetNumItemsInBaseContainer(object oBaseCont)
{
    int nItems = GetLocalInt(oBaseCont, sNumTreasureItemsVarname);
    if (nItems != 0) {
        return nItems;
    }

    // Haven't initialized the number of items yet
    object oTmp = GetFirstItemInInventory(oBaseCont);
    while (GetIsObjectValid(oTmp)) {
        nItems++;
        oTmp = GetNextItemInInventory(oBaseCont);
    }
    SetLocalInt(oBaseCont, sNumTreasureItemsVarname, nItems);
    return nItems;
}


// Determine whether an item should actually just be gold.
// Returns TRUE or FALSE.
// Probability controlled by constant TREASURE_GOLD_PROBABILITY
int CTG_IsItemGold()
{
    int nRoll = d100();
    if (nRoll < TREASURE_GOLD_PROBABILITY)
        return TRUE;
    return FALSE;
}

int GetIsInteger(string sChar)
{
    return (sChar == "0"
            || sChar == "1"
            || sChar == "2"
            || sChar == "3"
            || sChar == "4"
            || sChar == "5"
            || sChar == "6"
            || sChar == "7"
            || sChar == "8"
            || sChar == "9");
}

// Find and return the right monster container, if
// available.
object CTG_GetMonsterBaseContainer(object oSource=OBJECT_SELF)
{
    object oCont = OBJECT_INVALID;
    string sContTag = "";

    // For monster treasure, we first check for
    // a chest with a tag matching the specific
    // monster.
    // We strip numbers off the end of the tag first
    string sCreatureTag = GetTag(oSource);
    while ( GetIsInteger(GetStringRight(sCreatureTag, 1)) ) {
        sCreatureTag = GetStringLeft(sCreatureTag,
                                     GetStringLength(sCreatureTag)-1);
    }

    sContTag = sContMonster + "_" + sCreatureTag;
    oCont = GetObjectByTag(sContTag);
    if (GetIsObjectValid(oCont)) {
        return oCont;
    }

    // Didn't find that -- check for a chest for the
    // appropriate racialtype.
    sContTag = CTG_GetRacialtypeChestTag(sContMonster, oSource);
    oCont = GetObjectByTag(sContTag);
    if (GetIsObjectValid(oCont)) {
        return oCont;
    }

    // Didn't find that -- check for a module-wide
    // monster chest
    oCont = GetObjectByTag(sContMonster);
    return oCont;
}


// Locate the nearest base container of the appropriate type.
// Possible values for nTreasureType:
//     TREASURE_TYPE_MONSTER
//     TREASURE_TYPE_LOW
//     TREASURE_TYPE_MED
//     TREASURE_TYPE_HIGH
//     TREASURE_TYPE_UNIQUE
object CTG_GetNearestBaseContainer(int nTreasureType,
                                   object oSource=OBJECT_SELF)
{
    object oCont = OBJECT_INVALID;
    int nType = nTreasureType;
    string sContTag = "";

    if (nType == TREASURE_TYPE_MONSTER)
    {
        oCont = CTG_GetMonsterBaseContainer(oSource);
        if (GetIsObjectValid(oCont))
        {
            return oCont;
        }
        //if there are no areas specific chests then roll module wide chest based
        //on challenge rating.
        else
        {
           float creatureCR = GetChallengeRating(oSource);
           string ChestChosen = GetAppropriateChest(creatureCR);
           oCont = GetObjectByTag(ChestChosen);
           if(GetIsObjectValid(oCont))
           {
                return oCont;
           }
        }

        // no monster-specific treasure set up or the module wide chests are missing
        nType = TREASURE_TYPE_LOW;
    }
    if (nType == TREASURE_TYPE_JUNK) {
        sContTag = sContJunk;
    } else if (nType == TREASURE_TYPE_LOW) {
        sContTag = sContLow;
    } else if (nType == TREASURE_TYPE_MED) {
        sContTag = sContMed;
    } else if (nType == TREASURE_TYPE_HIGH) {
        sContTag = sContHigh;
    } else if (nType == TREASURE_TYPE_UNIQUE) {
        sContTag = sContUniq;
    } else {
        // Invalid treasure type
        return oCont;
    }

    oCont = GetNearestObjectByTag(sContTag);
    if (!GetIsObjectValid(oCont)) {
        // No area chest -- return the module-wide one
        return CTG_GetModuleBaseContainer(nType);
    }
    return oCont;
}

// Get the module-wide base container of the appropriate type.
// Possible values for nTreasureType:
//     TREASURE_TYPE_LOW
//     TREASURE_TYPE_MED
//     TREASURE_TYPE_HIGH
//     TREASURE_TYPE_UNIQUE
object CTG_GetModuleBaseContainer(int nTreasureType)
{
    object oCont = OBJECT_INVALID;
    string sContTag = "";

    if (nTreasureType == TREASURE_TYPE_LOW) {
        sContTag = sModContLow;
    } else if (nTreasureType == TREASURE_TYPE_MED) {
        sContTag = sModContMed;
    } else if (nTreasureType == TREASURE_TYPE_HIGH) {
        sContTag = sModContHigh;
    } else if (nTreasureType == TREASURE_TYPE_UNIQUE) {
        sContTag = sModContUniq;
    }
    else {
        // Invalid treasure type
        return oCont;
    }

    oCont = GetObjectByTag(sContTag);
    return oCont;
}


// Generate treasure using default method.
// Not prototyped -- this function should not be used outside
// this library.
void CTG_CreateDefaultTreasure(int nTreasureType, object oAdventurer, object oCont)
{
    // generate treasure using default method from nw_o2_coninclude
    if (nTreasureType == TREASURE_TYPE_LOW) {
        GenerateLowTreasure(oAdventurer, oCont);
    } else if (nTreasureType == TREASURE_TYPE_MED) {
        GenerateMediumTreasure(oAdventurer, oCont);
    } else if (nTreasureType == TREASURE_TYPE_HIGH) {
        GenerateHighTreasure(oAdventurer, oCont);
    } else if (nTreasureType == TREASURE_TYPE_UNIQUE) {
        GenerateBossTreasure(oAdventurer, oCont);
    }
}

// Get the specified item out of the given base container's inventory
object CTG_GetTreasureItem(object oBaseCont, int nItemNum)
{
    if (!GetIsObjectValid(oBaseCont)) {return OBJECT_INVALID;}

    // initialize the container -- this will automatically
    // only happen once.
    CTG_InitContainer(oBaseCont);

    // Refs to the items are stored on the container itself
    string sVar = sTreasureItemVarname + IntToString(nItemNum);
    object oItem = GetLocalObject(oBaseCont, sVar);
    return oItem;
}

// Starting from the specified item position, return the first
// item that matches one of the three base types.
// If nBaseType1 is passed in as invalid, NO TYPE CHECKING WILL BE DONE.
// nBaseType1 may also be passed in as a special custom type:
// TREASURE_BASE_TYPE_WEAPON (for any weapon type)
// TREASURE_BASE_TYPE_WEAPON_NOAMMO (for any weapon but ammunition)
// TREASURE_BASE_TYPE_WEAPON_RANGED (for any ranged weapon)
// TREASURE_BASE_TYPE_WEAPON_MELEE (for any melee weapon)
// TREASURE_BASE_TYPE_ARMOR (for armor, shields)
// TREASURE_BASE_TYPE_CLOTHING (for belts, boots, bracers,
//                              cloaks, helms, gloves)
object CTG_GetSpecificBaseTypeTreasureItem(object oBaseCont,
                                           int nItemNum,
                                           int nBaseType1=BASE_ITEM_INVALID,
                                           int nBaseType2=BASE_ITEM_INVALID,
                                           int nBaseType3=BASE_ITEM_INVALID)
{
    if (!GetIsObjectValid(oBaseCont)) {return OBJECT_INVALID;}

    // initialize the container -- this will automatically
    // only happen once.
    CTG_InitContainer(oBaseCont);

    int nRollOverNum = CTG_GetNumItemsInBaseContainer(oBaseCont);

    // If there are no items in the container, no chance of finding a matching one!
    if (nRollOverNum == 0) return OBJECT_INVALID;

    int i;
    string sVar;
    int nItemBaseType;
    int nLooped = 0;
    for (i=nItemNum; i != nItemNum || !nLooped ; i++) {

        // The base type of each item is stored on the container itself
        sVar = sBaseTypeVarname + IntToString(i);
        nItemBaseType = GetLocalInt(oBaseCont, sVar);

        // Check to see if the type matches our desired type.
        if (
            // Check for a weapon
            (nBaseType1 == TREASURE_BASE_TYPE_WEAPON
             &&
             CTG_GetIsWeapon(nItemBaseType))
            ||
            // non-ammo weapon
            (nBaseType1 == TREASURE_BASE_TYPE_WEAPON_NOAMMO
             &&
             CTG_GetIsWeaponNoammo(nItemBaseType))
            ||
            // ranged weapon
            (nBaseType1 == TREASURE_BASE_TYPE_WEAPON_RANGED
             &&
             CTG_GetIsRangedWeapon(nItemBaseType))
            ||
            // melee weapon
            (nBaseType1 == TREASURE_BASE_TYPE_WEAPON_MELEE
             &&
             CTG_GetIsMeleeWeapon(nItemBaseType))
            ||
            // armor
            (nBaseType1 == TREASURE_BASE_TYPE_ARMOR
             &&
             CTG_GetIsArmor(nItemBaseType))
            ||
            // clothing
            (nBaseType1 == TREASURE_BASE_TYPE_CLOTHING
             &&
             CTG_GetIsClothing(nItemBaseType))
            ||
            // other specific item type
            ( CTG_GetIsBaseType(nItemBaseType,
                                nBaseType1,
                                nBaseType2,
                                nBaseType3))
            ) // end of if statement
        {
            // we found a matching item -- return it
            return CTG_GetTreasureItem(oBaseCont, i);
        }

        // Handle the wrap-around case
        if ( (i+1) == nRollOverNum ) {
            // set i back to 0
            i = -1;
            nLooped = 1;
        }
    }

    // No matching item was found -- return null
    return OBJECT_INVALID;
}

// Test if treasure has been generated in the given object
int CTG_GetIsTreasureGenerated(object oCont)
{
    return GetLocalInt(oCont, sTreasureGeneratedVarname);
}

// Set whether treasure has been generated
void CTG_SetIsTreasureGenerated(object oCont, int bGenerated=TRUE)
{
    SetLocalInt(oCont, sTreasureGeneratedVarname, bGenerated);
}

// Create random treasure items of the appropriate type
// in the specified container. Should be called
// by a script on a treasure container.
//
// Possible values for nTreasureType:
//     TREASURE_TYPE_LOW
//     TREASURE_TYPE_MED
//     TREASURE_TYPE_HIGH
//     TREASURE_TYPE_UNIQUE
void CTG_CreateTreasure(int nTreasureType,
                        object oAdventurer,
                        object oCont=OBJECT_SELF)
{
    // To avoid code duplication, this actually just uses the specific
    // version and passes an invalid item type
    CTG_CreateSpecificBaseTypeTreasure(nTreasureType, oAdventurer, oCont);
}



// Create treasure of the appropriate treasure level and matching one
// of up to three different base types in the specified container.
//
// Possible values for nTreasureType:
//     TREASURE_TYPE_LOW
//     TREASURE_TYPE_MED
//     TREASURE_TYPE_HIGH
//     TREASURE_TYPE_UNIQUE
//
// Possible values for nBaseType1/2/3: any BASE_ITEM_* constant.
// Can also use these special values:
//  TREASURE_BASE_TYPE_WEAPON (for any weapon type)
//  TREASURE_BASE_TYPE_WEAPON_NOAMMO (for any weapon but ammunition)
//  TREASURE_BASE_TYPE_WEAPON_RANGED (for any ranged weapon)
//  TREASURE_BASE_TYPE_WEAPON_MELEE (for any melee weapon)
//  TREASURE_BASE_TYPE_ARMOR (for armor, shields)
//  TREASURE_BASE_TYPE_CLOTHING (for belts, boots, bracers,
//                              cloaks, helms, gloves)
//
void CTG_CreateSpecificBaseTypeTreasure(int nTreasureType,
                                        object oAdventurer,
                                        object oCont,
                                        int nBaseType1=BASE_ITEM_INVALID,
                                        int nBaseType2=BASE_ITEM_INVALID,
                                        int nBaseType3=BASE_ITEM_INVALID)
{
    // Prevent duplicate treasure generation
    if (CTG_GetIsTreasureGenerated(oCont)) {return;}
    CTG_SetIsTreasureGenerated(oCont);

    // Locate the base container
    object oBaseCont = CTG_GetNearestBaseContainer(nTreasureType,
                                                   oCont);
    string oTag = GetTag(oBaseCont);
    // Make sure we have a valid base container
    if (!GetIsObjectValid(oBaseCont)) {
        // if not, generate treasure using default method
        if (nBaseType1 == BASE_ITEM_BOOK
            || nBaseType1 == BASE_ITEM_SPELLSCROLL)
        {
            // Make book treasure
            GenerateBookTreasure(oAdventurer, oCont);
        } else {
            // Generate default treasure
            CTG_CreateDefaultTreasure(nTreasureType, oAdventurer, oCont);
        }
        return;
    }

    // Get the number of available items
    int nItemsInBaseCont = CTG_GetNumItemsInBaseContainer(oBaseCont);

    // Special case: unique treasure or artifact items
    if (nTreasureType == TREASURE_TYPE_UNIQUE)
    {
        // only give one item and only give it once
        int nRandom = Random(nItemsInBaseCont);

        object oItem;
        if (nBaseType1 == BASE_ITEM_INVALID) {
            // we're not checking base types
            oItem = CTG_GetTreasureItem(oBaseCont, nRandom);
        } else {
            oItem = CTG_GetSpecificBaseTypeTreasureItem(oBaseCont,
                                                        nRandom,
                                                        nBaseType1,
                                                        nBaseType2,
                                                        nBaseType3);
        }


        if (!GetIsObjectValid(oItem))
        {
            CTG_CreateDefaultTreasure(nTreasureType, oAdventurer, oCont);
        }
        else
        {

            // Copy the item
//            CreateItemOnObject(GetResRef(oItem), oCont);
            // * do an actual copy BK Feb 2003. Less chance of resref errors
            CopyItem(oItem, oCont, TRUE);
            SetPlotFlag(oItem, FALSE);
            // Destroy the original
            DestroyObject(oItem, 1.0);
        }

        return;
    }

    // Otherwise, we generate 1-3 items, possibly convert some
    // to gold.
    int nItems = CTG_GetNumItems();
    int nItemsCreated = 0;
    object oItem = OBJECT_INVALID;

    // Keep track of items handed out to avoid dupes
    object oItem1 = OBJECT_INVALID;
    object oItem2 = OBJECT_INVALID;

    // Random number -- position of item to hand out
    int nRandom = 0;

    while (nItemsCreated < nItems) {
        nItemsCreated++;
        if (nBaseType1 == BASE_ITEM_INVALID &&  CTG_IsItemGold() )
        {
            CTG_CreateGoldTreasure(nTreasureType, oAdventurer, oCont);
        }
        else
        {
            nRandom = Random(nItemsInBaseCont);

            if (nBaseType1 == BASE_ITEM_INVALID)
            {
                // we're not checking base types
                oItem = CTG_GetTreasureItem(oBaseCont, nRandom);
            }
            else
            {
                oItem = CTG_GetSpecificBaseTypeTreasureItem(oBaseCont,
                                                            nRandom,
                                                            nBaseType1,
                                                            nBaseType2,
                                                            nBaseType3);
            }

            if (!GetIsObjectValid(oItem))
            {
                // Ugh, no matching item found!
                // Bad module designer, no cookie.
                CTG_CreateDefaultTreasure(nTreasureType, oAdventurer, oCont);
            }
            else if ( nItemsCreated > 1 &&
                        (GetTag(oItem) == GetTag(oItem1) || GetTag(oItem) == GetTag(oItem2)) )
            {
                // Ugh, duplicate item. Make gold instead.
                CTG_CreateGoldTreasure(nTreasureType, oAdventurer, oCont);
            }
            else
            {
                // Make the item
                CopyItem(oItem, oCont, TRUE);
                if (nItemsCreated == 1) {
                    oItem1 = oItem;
                } else {
                    // if this is the third item, it doesn't matter
                    // anyway, so we might as well save the conditional.
                    oItem2 = oItem;
                }
            }
        }
        //Re-roll for the the next item. IE: If the above item was one from the high
        //chest the next one might not be ;)
        if (nTreasureType == TREASURE_TYPE_MONSTER)
        {
            oBaseCont = CTG_GetNearestBaseContainer(nTreasureType, oCont);
            nItemsInBaseCont = CTG_GetNumItemsInBaseContainer(oBaseCont);
        }
    }
}

// Create gold treasure in the specified container.
void CTG_CreateGoldTreasure(int nTreasureType,
                            object oAdventurer,
                            object oCont=OBJECT_SELF)
{
    // Just use the default generation scripts
    CreateGold(oCont, oAdventurer, nTreasureType);
}


// Create treasure on an NPC.
// This function will typically be called from within the
// NPC's OnSpawn handler.
// Note that this defaults to TREASURE_TYPE_MONSTER, which uses
// the monster-specific treasure chests and falls back to low-
// level treasure if none exist.
void CTG_GenerateNPCTreasure(int nTreasureType=5, object oNPC=OBJECT_SELF)
{

    // Locate the base container
    object oBaseCont = CTG_GetNearestBaseContainer(nTreasureType,
                                                   oNPC);

    // Make sure we have a valid base container
    if (!GetIsObjectValid(oBaseCont)) {
        // if not, generate treasure using default method from
        // nw_o2_coninclude.
        if (nTreasureType == TREASURE_TYPE_MONSTER)
            GenerateNPCTreasure(TREASURE_TYPE_MED, oNPC);
        else
            GenerateNPCTreasure(nTreasureType, oNPC);
        return;
    }

    // Now we determine whether we put treasure on the NPC
    int nRacialType = GetRacialType(oNPC);
    switch (nRacialType) {
    case RACIAL_TYPE_ANIMAL:
    case RACIAL_TYPE_BEAST:
    case RACIAL_TYPE_MAGICAL_BEAST:
    case RACIAL_TYPE_VERMIN:
        // No treasure, sorry.
        return;
    }

    if (nTreasureType == TREASURE_TYPE_MONSTER) {

        if (d100() < BK_CHANCE_OF_N0_MONSTERTREASURE) {
            return;
        }
    }

    // Otherwise, generate as usual
    CTG_CreateTreasure(nTreasureType, oNPC, oNPC);
}



/**********************************************************************
 * Boring type-checking functions.
 **********************************************************************/


// Check if the item's base type is of the given base type
int CTG_GetIsBaseType(int nItemBaseType,
                            int nBaseType1=BASE_ITEM_INVALID,
                            int nBaseType2=BASE_ITEM_INVALID,
                            int nBaseType3=BASE_ITEM_INVALID)
{
    return ( (nItemBaseType != BASE_ITEM_INVALID)
             && (
                 nItemBaseType == nBaseType1
                 || nItemBaseType == nBaseType2
                 || nItemBaseType == nBaseType3) );
}

// Check if the item's base type is a weapon
int CTG_GetIsWeapon(int nItemBaseType)
{
    return (
            nItemBaseType == BASE_ITEM_ARROW
            || nItemBaseType == BASE_ITEM_BASTARDSWORD
            || nItemBaseType == BASE_ITEM_BATTLEAXE
            || nItemBaseType == BASE_ITEM_BOLT
            || nItemBaseType == BASE_ITEM_BULLET
            || nItemBaseType == BASE_ITEM_CBLUDGWEAPON
            || nItemBaseType == BASE_ITEM_CLUB
            || nItemBaseType == BASE_ITEM_CPIERCWEAPON
            || nItemBaseType == BASE_ITEM_CSLASHWEAPON
            || nItemBaseType == BASE_ITEM_CSLSHPRCWEAP
            || nItemBaseType == BASE_ITEM_DAGGER
            || nItemBaseType == BASE_ITEM_DART
            || nItemBaseType == BASE_ITEM_DIREMACE
            || nItemBaseType == BASE_ITEM_DOUBLEAXE
            || nItemBaseType == BASE_ITEM_GREATAXE
            || nItemBaseType == BASE_ITEM_GREATSWORD
            || nItemBaseType == BASE_ITEM_GRENADE
            || nItemBaseType == BASE_ITEM_HALBERD
            || nItemBaseType == BASE_ITEM_HANDAXE
            || nItemBaseType == BASE_ITEM_HEAVYCROSSBOW
            || nItemBaseType == BASE_ITEM_HEAVYFLAIL
            || nItemBaseType == BASE_ITEM_KAMA
            || nItemBaseType == BASE_ITEM_KATANA
            || nItemBaseType == BASE_ITEM_KUKRI
            || nItemBaseType == BASE_ITEM_LIGHTCROSSBOW
            || nItemBaseType == BASE_ITEM_LIGHTFLAIL
            || nItemBaseType == BASE_ITEM_LIGHTHAMMER
            || nItemBaseType == BASE_ITEM_LIGHTMACE
            || nItemBaseType == BASE_ITEM_LONGBOW
            || nItemBaseType == BASE_ITEM_LONGSWORD
            || nItemBaseType == BASE_ITEM_MORNINGSTAR
            || nItemBaseType == BASE_ITEM_QUARTERSTAFF
            || nItemBaseType == BASE_ITEM_RAPIER
            || nItemBaseType == BASE_ITEM_SCIMITAR
            || nItemBaseType == BASE_ITEM_SCYTHE
            || nItemBaseType == BASE_ITEM_SHORTBOW
            || nItemBaseType == BASE_ITEM_SHORTSPEAR
            || nItemBaseType == BASE_ITEM_SHORTSWORD
            || nItemBaseType == BASE_ITEM_SHURIKEN
            || nItemBaseType == BASE_ITEM_SICKLE
            || nItemBaseType == BASE_ITEM_SLING
            || nItemBaseType == BASE_ITEM_THROWINGAXE
            || nItemBaseType == BASE_ITEM_TWOBLADEDSWORD
            || nItemBaseType == BASE_ITEM_WARHAMMER);
}

// Check if the item's base type is a weapon but not ammunition
int CTG_GetIsWeaponNoammo(int nItemBaseType)
{
    return ( CTG_GetIsWeapon(nItemBaseType)
             && (nItemBaseType != BASE_ITEM_ARROW
                 || nItemBaseType != BASE_ITEM_BOLT
                 || nItemBaseType != BASE_ITEM_BULLET)
             );
}

// Check if the item's base type is a ranged weapon
int CTG_GetIsRangedWeapon(int nItemBaseType)
{
    return (nItemBaseType == BASE_ITEM_DART
            || nItemBaseType == BASE_ITEM_GRENADE
            || nItemBaseType == BASE_ITEM_HEAVYCROSSBOW
            || nItemBaseType == BASE_ITEM_LIGHTCROSSBOW
            || nItemBaseType == BASE_ITEM_LONGBOW
            || nItemBaseType == BASE_ITEM_SHORTBOW
            || nItemBaseType == BASE_ITEM_SHURIKEN
            || nItemBaseType == BASE_ITEM_SLING
            || nItemBaseType == BASE_ITEM_THROWINGAXE);
}

// Check if the item's base type is a melee weapon
int CTG_GetIsMeleeWeapon(int nItemBaseType)
{
    return (
            nItemBaseType == BASE_ITEM_BASTARDSWORD
            || nItemBaseType == BASE_ITEM_BATTLEAXE
            || nItemBaseType == BASE_ITEM_CLUB
            || nItemBaseType == BASE_ITEM_DAGGER
            || nItemBaseType == BASE_ITEM_DIREMACE
            || nItemBaseType == BASE_ITEM_DOUBLEAXE
            || nItemBaseType == BASE_ITEM_GREATAXE
            || nItemBaseType == BASE_ITEM_GREATSWORD
            || nItemBaseType == BASE_ITEM_HALBERD
            || nItemBaseType == BASE_ITEM_HANDAXE
            || nItemBaseType == BASE_ITEM_HEAVYFLAIL
            || nItemBaseType == BASE_ITEM_KAMA
            || nItemBaseType == BASE_ITEM_KATANA
            || nItemBaseType == BASE_ITEM_KUKRI
            || nItemBaseType == BASE_ITEM_LIGHTFLAIL
            || nItemBaseType == BASE_ITEM_LIGHTHAMMER
            || nItemBaseType == BASE_ITEM_LIGHTMACE
            || nItemBaseType == BASE_ITEM_LONGSWORD
            || nItemBaseType == BASE_ITEM_MORNINGSTAR
            || nItemBaseType == BASE_ITEM_QUARTERSTAFF
            || nItemBaseType == BASE_ITEM_RAPIER
            || nItemBaseType == BASE_ITEM_SCIMITAR
            || nItemBaseType == BASE_ITEM_SCYTHE
            || nItemBaseType == BASE_ITEM_SHORTSPEAR
            || nItemBaseType == BASE_ITEM_SHORTSWORD
            || nItemBaseType == BASE_ITEM_SICKLE
            || nItemBaseType == BASE_ITEM_TWOBLADEDSWORD
            || nItemBaseType == BASE_ITEM_WARHAMMER);
}

// Check if the item's base type is armor
int CTG_GetIsArmor(int nItemBaseType)
{
    return (nItemBaseType == BASE_ITEM_ARMOR
            || nItemBaseType == BASE_ITEM_LARGESHIELD
            || nItemBaseType == BASE_ITEM_SMALLSHIELD
            || nItemBaseType == BASE_ITEM_TOWERSHIELD);
}

// Check if the item's base type is clothing
int CTG_GetIsClothing(int nItemBaseType)
{
        return (nItemBaseType == BASE_ITEM_BELT
            || nItemBaseType == BASE_ITEM_BOOTS
            || nItemBaseType == BASE_ITEM_BRACER
            || nItemBaseType == BASE_ITEM_CLOAK
            || nItemBaseType == BASE_ITEM_GLOVES);
}

// Tack on the appropriate racialtype suffix
string CTG_GetRacialtypeChestTag(string sBaseTag, object oSource)
{
    string sCont = sBaseTag + "_";
    switch (GetRacialType(oSource))
    {
    case RACIAL_TYPE_INVALID: return "";
    case RACIAL_TYPE_ABERRATION: sCont = sCont + "ABERRATION"; break;
    case RACIAL_TYPE_ANIMAL: sCont = sCont + "ANIMAL"; break;
    case RACIAL_TYPE_BEAST: sCont = sCont + "BEAST"; break;
    case RACIAL_TYPE_CONSTRUCT: sCont = sCont + "CONSTRUCT"; break;
    case RACIAL_TYPE_DRAGON: sCont = sCont + "DRAGON"; break;
    case RACIAL_TYPE_DWARF: sCont = sCont + "DWARF"; break;
    case RACIAL_TYPE_ELEMENTAL: sCont = sCont + "ELEMENTAL"; break;
    case RACIAL_TYPE_ELF: sCont = sCont + "ELF"; break;
    case RACIAL_TYPE_FEY: sCont = sCont + "FEY"; break;
    case RACIAL_TYPE_GIANT: sCont = sCont + "GIANT"; break;
    case RACIAL_TYPE_GNOME: sCont = sCont + "GNOME"; break;
    case RACIAL_TYPE_HALFELF: sCont = sCont + "HALFELF"; break;
    case RACIAL_TYPE_HALFLING: sCont = sCont + "HALFLING"; break;
    case RACIAL_TYPE_HALFORC: sCont = sCont + "HALFORC"; break;
    case RACIAL_TYPE_HUMAN: sCont = sCont + "HUMAN"; break;
    case RACIAL_TYPE_HUMANOID_GOBLINOID: sCont = sCont + "GOBLINOID"; break;
    case RACIAL_TYPE_HUMANOID_MONSTROUS: sCont = sCont + "MONSTROUS"; break;
    case RACIAL_TYPE_HUMANOID_ORC: sCont = sCont + "ORC"; break;
    case RACIAL_TYPE_HUMANOID_REPTILIAN: sCont = sCont + "REPTILIAN"; break;
    case RACIAL_TYPE_MAGICAL_BEAST: sCont = sCont + "MAGICAL_BEAST"; break;
    case RACIAL_TYPE_OUTSIDER: sCont = sCont + "OUTSIDER"; break;
    case RACIAL_TYPE_SHAPECHANGER: sCont = sCont + "SHAPECHANGER"; break;
    case RACIAL_TYPE_UNDEAD: sCont = sCont + "UNDEAD"; break;
    case RACIAL_TYPE_VERMIN: sCont = sCont + "VERMIN"; break;
    }

    return sCont;
}


//void main() {}

