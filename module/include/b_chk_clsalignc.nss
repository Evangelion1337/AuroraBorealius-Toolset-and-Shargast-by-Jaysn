//::///////////////////////////////////////////////
//:: FileName b_chk_clsalignc
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 14.05.2007 13:17:31
//:://////////////////////////////////////////////
#include "prc_class_const"

int StartingConditional()
{
	object oPC = GetPCSpeaker();
	
	int iRogue	= GetLevelByClass(CLASS_TYPE_ROGUE, oPC)
				+ GetLevelByClass(CLASS_TYPE_SCOUT, oPC)
				+ GetLevelByClass(CLASS_TYPE_BEGUILER, oPC)
				+ GetLevelByClass(CLASS_TYPE_NINJA, oPC)
				+ GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC)				
				+ GetLevelByClass(CLASS_TYPE_ASSASSIN, oPC)
				+ GetLevelByClass(CLASS_TYPE_ARCTRICK, oPC)
				+ GetLevelByClass(CLASS_TYPE_HANDOTWM, oPC)
				+ GetLevelByClass(CLASS_TYPE_NIGHTSHADE, oPC)
				+ GetLevelByClass(CLASS_TYPE_NINJA_SPY, oPC)
				+ GetLevelByClass(CLASS_TYPE_SHADOWLORD, oPC)
				+ GetLevelByClass(CLASS_TYPE_SHADOW_SUN_NINJA, oPC)
				+ GetLevelByClass(CLASS_TYPE_SHADOW_THIEF_AMN, oPC)
				+ GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oPC)
				+ GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE, oPC);

	// Restrict based on the player's class
	int iPassed = 0;
	if(iRogue >= 1)
		iPassed = 1;
	
	if(iPassed == 0)
		return FALSE;

	return TRUE;
}