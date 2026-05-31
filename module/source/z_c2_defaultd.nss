//::///////////////////////////////////////////////
//:: Default: On User Defined
//:: NW_C2_DEFAULTD
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    on a user defined event.
*/
//:://////////////////////////////////////////////
//:: Created By: Don Moar
//:: Created On: April 28, 2002
//:: Modified by Zarathstra217
//:://////////////////////////////////////////////
void main()
{
    // enter desired behaviour here
	ExecuteScript("prc_npc_userdef", OBJECT_SELF);

    return;
}