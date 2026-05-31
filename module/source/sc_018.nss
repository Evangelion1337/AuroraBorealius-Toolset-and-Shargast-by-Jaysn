//::///////////////////////////////////////////////
//:: FileName sc_018
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 11.04.2007 20:06:43
//:://////////////////////////////////////////////
#include "prc_class_const"

int StartingConditional()
{
	object oPC = GetPCSpeaker();
	
	int iArcane	= GetLevelByClass(CLASS_TYPE_WIZARD, oPC)
				+ GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
				+ GetLevelByClass(CLASS_TYPE_DRAGONFIRE_ADEPT, oPC)
				+ GetLevelByClass(CLASS_TYPE_DRAGON_SHAMAN, oPC)			
				+ GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oPC)
				+ GetLevelByClass(CLASS_TYPE_BEGUILER, oPC)
				+ GetLevelByClass(CLASS_TYPE_SHADOWCASTER, oPC)
				+ GetLevelByClass(CLASS_TYPE_WARMAGE, oPC)
				+ GetLevelByClass(CLASS_TYPE_BINDER, oPC)
				+ GetLevelByClass(CLASS_TYPE_TRUENAMER, oPC)			
				+ GetLevelByClass(CLASS_TYPE_WARLOCK, oPC);	
			
	// Restrict based on the player's class
	int iPassed = 0;
	if(iArcane >= 1)
		iPassed = 1;
	
	if(iPassed == 0)
		return FALSE;

	return TRUE;
}