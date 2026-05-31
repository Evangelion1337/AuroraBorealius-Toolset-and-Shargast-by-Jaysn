//::///////////////////////////////////////////////
//:: FileName mm_chk_vrak
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 26.05.2007 15:52:29
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "sig_vrakkas"))
        return FALSE;

    return TRUE;
}
