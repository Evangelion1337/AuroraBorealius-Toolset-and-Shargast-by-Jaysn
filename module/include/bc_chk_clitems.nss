//Black Claw check clan items
//bc_chk_clitems

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
    if(!HasItem(GetPCSpeaker(), "SignetoftheTemplars"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "BlackKnightSignet"))
        return FALSE;

    return TRUE;
}

