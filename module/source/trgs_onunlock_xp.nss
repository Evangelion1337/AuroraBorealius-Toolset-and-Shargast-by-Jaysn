// Handles unlocking of a chest or door to give the player experience for
// unlocking it. The formula by default is 5xp * the DC (minus 10) of the chest minus
// 5 * the number of Rogue levels the PC has. Low-levels and non-rogues are
// rewarded more for excelling in lock-picking because it is easier for real
// rogues, who don't need to use potions or lockpicks to succeed.
#include "trgs_i0_respawn"
#include "prc_class_const"

void main()
{
    object oPicked = OBJECT_SELF;
    object oPicker = GetLastUnlocked();
    string sOnce = "UNLOCK_DO_ONCE";
	
	int nThief	= GetLevelByClass(CLASS_TYPE_ROGUE, oPicker)
				+ GetLevelByClass(CLASS_TYPE_SCOUT, oPicker)
				+ GetLevelByClass(CLASS_TYPE_BEGUILER, oPicker)
				+ GetLevelByClass(CLASS_TYPE_NINJA, oPicker)
				+ GetLevelByClass(CLASS_TYPE_FACTOTUM, oPicker)				
				+ GetLevelByClass(CLASS_TYPE_ASSASSIN, oPicker)
				+ GetLevelByClass(CLASS_TYPE_ARCTRICK, oPicker)
				+ GetLevelByClass(CLASS_TYPE_HANDOTWM, oPicker)
				+ GetLevelByClass(CLASS_TYPE_NIGHTSHADE, oPicker)
				+ GetLevelByClass(CLASS_TYPE_NINJA_SPY, oPicker)
				+ GetLevelByClass(CLASS_TYPE_SHADOWLORD, oPicker)
				+ GetLevelByClass(CLASS_TYPE_SHADOW_SUN_NINJA, oPicker)
				+ GetLevelByClass(CLASS_TYPE_SHADOW_THIEF_AMN, oPicker)
				+ GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oPicker)
				+ GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE, oPicker);
				
    if ( !GetLocalInt( oPicked, sOnce ) )
    {
        object oPC = GetLastUnlocked();

        int nDC = ( GetLockUnlockDC( oPicked ) - 10 );

        if ( nDC < 10 )
            nDC = 10;

        int nXP = ( nDC * DEFAULT_UNLOCK_XP ) - ( nThief * DEFAULT_UNLOCK_XP );

        if ( nXP < DEFAULT_UNLOCK_XP )
            nXP = DEFAULT_UNLOCK_XP;

        GiveXPToCreature( oPicker, nXP );
        SetLocalInt( oPicked, sOnce, TRUE );
    }
}
