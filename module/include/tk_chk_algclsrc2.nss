//:://///////////////////////////////////////////////////////
//:: FileName tk_chk_algclsrc2 (LG male humans & half-elves)
//:://///////////////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 14.05.2007 13:45:14
//:://////////////////////////////////////////////
#include "prc_inc_racial"

int StartingConditional()
{
	object oPC	= GetPCSpeaker();	
	int iRace	= MyPRCGetRacialType(oPC);

//:: Add the gender restrictions
	if(GetGender(oPC) != GENDER_MALE)
		return FALSE;		

//:: Restrict based on the player's alignment
	if(GetAlignmentGoodEvil(oPC) != ALIGNMENT_GOOD)
		return FALSE;
	if(GetAlignmentLawChaos(oPC) != ALIGNMENT_LAWFUL)
		return FALSE;

//:: Restrict based on the player's race
	if (iRace == RACIAL_TYPE_HUMAN || iRace == RACIAL_TYPE_HALFELF)
		return TRUE;
	
	else
	{
		return FALSE;
	}	
	
	
}	
/* int StartingConditional()
{

	// Add the gender restrictions
	if(GetGender(GetPCSpeaker()) != GENDER_MALE)
		return FALSE;

	// Reject player races
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_DWARF)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_ELF)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_GNOME)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_HALFLING)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_HALFORC)
		return FALSE;

	// Reject other races
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_ABERRATION)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_ANIMAL)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_BEAST)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_CONSTRUCT)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_DRAGON)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_ELEMENTAL)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_FEY)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_GIANT)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_HUMANOID_GOBLINOID)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_MAGICAL_BEAST)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_HUMANOID_MONSTROUS)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_OOZE)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_HUMANOID_ORC)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_OUTSIDER)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_HUMANOID_REPTILIAN)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_SHAPECHANGER)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_UNDEAD)
		return FALSE;
	if(GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_VERMIN)
		return FALSE;

	// Restrict based on the player's alignment
	if(GetAlignmentGoodEvil(GetPCSpeaker()) != ALIGNMENT_GOOD)
		return FALSE;
	if(GetAlignmentLawChaos(GetPCSpeaker()) != ALIGNMENT_LAWFUL)
		return FALSE;

	return TRUE;
} */
