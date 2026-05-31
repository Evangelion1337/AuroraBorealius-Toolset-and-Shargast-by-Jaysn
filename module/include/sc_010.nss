//::///////////////////////////////////////////////
//:: FileName sc_010
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 01.08.2006 19:36:57
//:://////////////////////////////////////////////
int StartingConditional()
{

	// Restrict based on the player's alignment
	if(GetAlignmentGoodEvil(GetPCSpeaker()) != ALIGNMENT_GOOD)
		return FALSE;
	if(GetAlignmentLawChaos(GetPCSpeaker()) != ALIGNMENT_LAWFUL)
		return FALSE;

	return TRUE;
}
