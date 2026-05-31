//::///////////////////////////////////////////////
//:: FileName blk_kn_chkfof
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 13.05.2007 19:45:34
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "BlackKnightSignet"))
        return FALSE;

    return TRUE;
}
