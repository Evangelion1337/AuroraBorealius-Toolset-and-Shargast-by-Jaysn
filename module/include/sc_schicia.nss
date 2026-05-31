//::///////////////////////////////////////////////
//:: FileName sc_schicia
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 4/18/2005 8:20:44 AM
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "schippsig"))
        return TRUE;

    return FALSE;
}
