//::///////////////////////////////////////////////
//:: Default: On Rested
//:: NW_C2_DEFAULTA
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    after having just rested.
*/
//:://////////////////////////////////////////////
//:: Created By: Don Moar
//:: Created On: April 28, 2002
//:: Modified by Zarathstra217
//:://////////////////////////////////////////////
void main()
{
    // enter desired behaviour here
	ExecuteScript("prc_npc_rested", OBJECT_SELF);
	
    return;
}