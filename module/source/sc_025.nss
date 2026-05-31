//::///////////////////////////////////////////////
//:: FileName sc_025
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 4/24/2005 2:38:29 PM
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "dwarfsig"))
        return FALSE;

    return TRUE;
}

