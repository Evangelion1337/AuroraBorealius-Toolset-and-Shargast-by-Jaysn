//Kinghts of the White Rose check clan items
//bk_chk_clitems

#include "nw_i0_tool"

int StartingConditional()
{

    // Make sure the PC speaker has these items in their inventory
    if(!HasItem(GetPCSpeaker(), "BlackKnightSignet"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "schippersig"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "dwarfsig"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "SignetoftheTemplars"))
        return FALSE;
    if(!HasItem(GetPCSpeaker(), "BlackClawSignet"))
        return FALSE;

    return TRUE;
}

