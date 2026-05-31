//::///////////////////////////////////////////////
//:: FileName sc_004
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 9/5/2004 1:51:32 PM
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "dwarvencorpse"))
        return FALSE;

    return TRUE;
}
