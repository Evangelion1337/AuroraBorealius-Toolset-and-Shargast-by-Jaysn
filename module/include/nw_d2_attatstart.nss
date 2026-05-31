//::///////////////////////////////////////////////
//:: NW_D2_ATTATASTART
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Always returns True and makes the NPC go hostile

*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////

#include "nw_i0_generic"

int StartingConditional()
{
    int iResult;
    AdjustReputation(GetPCSpeaker(), OBJECT_SELF, -100);

    DetermineCombatRound();
    iResult = TRUE;
    return iResult;
}
