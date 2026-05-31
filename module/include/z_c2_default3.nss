//::///////////////////////////////////////////////
//:: Default: End of Combat Round
//:: NW_C2_DEFAULT3
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Calls the end of combat script every round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:: Modified by Zarathstra217
//:://////////////////////////////////////////////

#include "NW_I0_GENERIC"
void main()
{
	ExecuteScript("prc_npc_combat", OBJECT_SELF);
}


