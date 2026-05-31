//::///////////////////////////////////////////////
//:: Have Not Master
//:: NW_CH_MASTER
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If I do not have a master then enter
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamanuik
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
//   Modified by Proleric 25-Feb-2008
//   Don't enter if I am a PC


int StartingConditional()
{
    if (GetIsPC(OBJECT_SELF)) return FALSE;

    if(!GetIsObjectValid(GetMaster()))
    {
        return TRUE;
    }
    return FALSE;
}
