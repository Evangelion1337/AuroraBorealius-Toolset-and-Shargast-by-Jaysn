//::///////////////////////////////////////////////
//:: FileName tk_chk_signetmem
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 14.05.2007 13:09:50
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "SignetoftheTemplars"))
        return FALSE;

    return TRUE;
}
