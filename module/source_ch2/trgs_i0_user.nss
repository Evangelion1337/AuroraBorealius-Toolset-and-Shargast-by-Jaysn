//::///////////////////////////////////////////////
//:: (T)reasure (R)espawn and (G)eneration (S)ystem
//:: trgs_i0_respawn
//:://////////////////////////////////////////////
/*
    This script is intended to manage the respawn
    aspect of treasure generation while being
    compatible with any existing method of actual
    treasure generation. By default, the system is
    tied to the HOTU treasure generation scripts.
*/
//:://////////////////////////////////////////////
//:: Created By: Mister_Leebo AKA Bent_Spear
//:: Created On: June 14th, 2005
//:://////////////////////////////////////////////
// This file is safe to modify.

#include "x2_inc_treasure"

// ROOM FOR ADJUSTMENTS
// You can easily adjust the values of the
// following variables here.

// Which method to use (see RESPAWNMETHODS)
const int DEFAULT_RESPAWN_METHOD = 3;
// How long to wait for returning treasure methods (in minutes)
const int DEFAULT_RESPAWN_DELAY  = 15;
// Determines multiplier for unlock xp. In testing, I've found that 5
// produces a reasonable value for a module using an Official Campaign
// rate of advancement. If you want it to take much longer to level,
// reduce this value.
const int DEFAULT_UNLOCK_XP      = 5;

// TREASURECLASS and TREASURETYPE:
// Same as default HOTU constants with
// memory-friendly labels.
//
// NOTE: If you modify the TRGS to use a system
// other than the BioWare default HOTU
// scripts, you may need to change these
// constants.
const int LOW    = 0;
const int MEDIUM = 1;
const int HIGH   = 2;

const int NONE        = 0;
const int DISPOSABLES = 1;
const int AMMUNITION  = 2;
const int GOLD        = 4;
const int EQUIPMENT   = 8;

// RESPAWN_METHODS
// Explains the different ways a chest might determine if it
// can respawn its treasure. Use the numeric value to the right
// when selecting which method will become your default.

// BioWare Default script effect: First User only, no respawn
const int RESPAWNMETHOD_ONE_SHOT_NO_RETURN    = 0;
// First User only, will respawn
const int RESPAWNMETHOD_ONE_SHOT_AND_RETURN   = 1;
// All users, no respawn
const int RESPAWNMETHOD_CONTINUOUS_NO_RETURN  = 2;
// All users, will respawn
const int RESPAWNMETHOD_CONTINUOUS_AND_RETURN = 3;

// STRING CONSTANTS
// These are all used to construct the names of
// various local variables used by the system.
// They're all listed here so that you may
// find them easily and change them in the rare
// instance that they match something you use.
//
// You do not have to modify these, and it is
// not recommended that you do.
const string ONE_SHOT      = "TREASURE_DO_ONCE";
const string CONTINUOUS    = "ONCE_FOR_";
const string AND_RETURN = "_UNTIL_LATER";
const string MINUTE_KEY    = "TREASURE_RESPAWN_MINUTE";



// Wrapper function to call HOTU default treasure generation script.
// To quickly and easily affix the Treasure Respawn System to ANY
// treasure generation script, just modify this function, but leave
// its name the same.
void GenerateMyTreasure( object oCont, object oOpener, int CLASS, int TYPE );

void GenerateMyTreasure( object oCont, object oOpener, int CLASS, int TYPE )
{
    DTSGenerateTreasureOnContainer( oCont, oOpener, CLASS, TYPE );
}
