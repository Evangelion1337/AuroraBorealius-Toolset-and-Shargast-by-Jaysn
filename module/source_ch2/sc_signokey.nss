//::///////////////////////////////////////////////
//:: FileName sc_signokey
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 5/8/2005 12:51:29 PM
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory

    if(!HasItem(GetPCSpeaker(), "dwarfsig"))
        return FALSE;

    return TRUE;
}
