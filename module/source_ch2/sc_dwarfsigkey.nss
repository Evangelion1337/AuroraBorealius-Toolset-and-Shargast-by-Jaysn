//::///////////////////////////////////////////////
//:: FileName sc_dwarfsigkey
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 5/8/2005 12:48:06 PM
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

	// Make sure the PC speaker has these items in their inventory
	if(!HasItem(GetPCSpeaker(), "dwarfkey"))
		return FALSE;
	if(!HasItem(GetPCSpeaker(), "dwarfsig"))
		return FALSE;

	return TRUE;
}
