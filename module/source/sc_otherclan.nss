//::///////////////////////////////////////////////
//:: FileName sc_otherclan
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 4/24/2005 10:45:54 AM
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "WhiteRoseSignet"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "schippersig"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "dwarfsig"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "BlackClawSignet"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "SignetoftheTemplars"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "BlackKnightSignet"))
        return FALSE;

    return TRUE;
}
