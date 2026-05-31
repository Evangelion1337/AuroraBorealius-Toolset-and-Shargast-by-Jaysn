//::///////////////////////////////////////////////
//:: FileName signetofthetempl
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 01.08.2006 19:15:06
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

	// Make sure the PC speaker has these items in their inventory
	if(!HasItem(GetPCSpeaker(), "SignetoftheTemplars"))
		return FALSE;

	return TRUE;
}
