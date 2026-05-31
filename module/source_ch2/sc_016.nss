//::///////////////////////////////////////////////
//:: FileName sc_016
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 4/24/2005 12:52:28 PM
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "dwarfsig"))
        return TRUE;

    return FALSE;
}
