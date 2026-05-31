//::///////////////////////////////////////////////
//:: FileName bk_chk_signet
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 13.05.2007 21:19:22
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

	// Make sure the PC speaker has these items in their inventory
	if(!HasItem(GetPCSpeaker(), "BlackKnightSignet"))
		return FALSE;

	return TRUE;
}
