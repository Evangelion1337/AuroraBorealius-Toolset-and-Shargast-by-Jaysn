//::///////////////////////////////////////////////
//:: FileName bk_chk_aligne
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 14.05.2007 10:49:21
//:://////////////////////////////////////////////
#include "prc_class_const"

int StartingConditional()
{
	object oPC = GetPCSpeaker();
	
	int iEvil = GetLevelByClass(CLASS_TYPE_ASSASSIN, oPC)
				+ GetLevelByClass(CLASS_TYPE_BLACKGUARD, oPC)
				+ GetLevelByClass(CLASS_TYPE_UR_PRIEST, oPC)
				+ GetLevelByClass(CLASS_TYPE_OCULAR, oPC)
				+ GetLevelByClass(CLASS_TYPE_JUDICATOR, oPC)
				+ GetLevelByClass(CLASS_TYPE_NIGHTSHADE, oPC)
				+ GetLevelByClass(CLASS_TYPE_DISC_BAALZEBUL, oPC)
				+ GetLevelByClass(CLASS_TYPE_DISPATER, oPC)
				+ GetLevelByClass(CLASS_TYPE_BLIGHTLORD, oPC)
				+ GetLevelByClass(CLASS_TYPE_ORCUS, oPC)
				+ GetLevelByClass(CLASS_TYPE_MASTER_OF_SHROUDS, oPC)				
				+ GetLevelByClass(CLASS_TYPE_THRALL_OF_GRAZZT_A, oPC)
				+ GetLevelByClass(CLASS_TYPE_GHOST_FACED_KILLER, oPC)
				+ GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_MEPH, oPC)
				+ GetLevelByClass(CLASS_TYPE_SOUL_EATER, oPC)
				+ GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oPC)
				+ GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oPC)				
				+ GetLevelByClass(CLASS_TYPE_NECROCARNATE, oPC); 
				
	int iDivine	= GetLevelByClass(CLASS_TYPE_CLERIC, oPC) 	
				+ GetLevelByClass(CLASS_TYPE_ARCHIVIST, oPC)
				+ GetLevelByClass(CLASS_TYPE_FAVOURED_SOUL, oPC)
				+ GetLevelByClass(CLASS_TYPE_HEALER, oPC);	

	int iWarrior	= GetLevelByClass(CLASS_TYPE_FIGHTER, oPC)		
					+ GetLevelByClass(CLASS_TYPE_CW_SAMURAI, oPC)
					+ GetLevelByClass(CLASS_TYPE_KNIGHT, oPC)
					+ GetLevelByClass(CLASS_TYPE_MARSHAL, oPC)
					+ GetLevelByClass(CLASS_TYPE_SAMURAI, oPC)
					+ GetLevelByClass(CLASS_TYPE_SOULKNIFE, oPC)
					+ GetLevelByClass(CLASS_TYPE_SWASHBUCKLER, oPC);	

	int iUndead	= GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oPC)
				+ GetLevelByClass(CLASS_TYPE_TRUENECRO, oPC)
				+ GetLevelByClass(CLASS_TYPE_PALEMASTER, oPC)
				+ GetLevelByClass(CLASS_TYPE_SKULLCLAN_HUNTER, oPC)
				+ GetLevelByClass(CLASS_TYPE_MASTER_OF_SHROUDS, oPC)
				+ GetLevelByClass(CLASS_TYPE_LICH, oPC)
				+ GetLevelByClass(CLASS_TYPE_NECROCARNATE, oPC)
				+ GetLevelByClass(CLASS_TYPE_TENEBROUS_APOSTATE, oPC)
				+ GetLevelByClass(CLASS_TYPE_ORCUS, oPC)
				+ GetLevelByClass(CLASS_TYPE_BLIGHTER, oPC);
	
	//::  Restrict based on the player's class
	int iPassed = 0;
	if(iEvil >= 1)
		iPassed = 1;
	
	if((iPassed == 0) && (iDivine >= 1))
		iPassed = 1;
	
	if((iPassed == 0) && (iWarrior >= 1))
		iPassed = 1;
	
	if((iPassed == 0) && (iUndead >= 1))
		iPassed = 1;
	
	if(iPassed == 0)
		return FALSE;

	// Restrict based on the player's alignment
	if(GetAlignmentGoodEvil(oPC) != ALIGNMENT_EVIL)
		return FALSE;

	return TRUE;
}