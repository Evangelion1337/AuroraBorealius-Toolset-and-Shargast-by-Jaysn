//::///////////////////////////////////////////////
//:: FileName tk_chk_clsalgnrc
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 14.05.2007 16:07:55
//:://////////////////////////////////////////////
int StartingConditional()
{

	// Restrict based on the player's alignment
	if(GetAlignmentGoodEvil(GetPCSpeaker()) == ALIGNMENT_GOOD)
		return FALSE;
	if(GetAlignmentLawChaos(GetPCSpeaker()) == ALIGNMENT_LAWFUL)
		return FALSE;

	return TRUE;
}
