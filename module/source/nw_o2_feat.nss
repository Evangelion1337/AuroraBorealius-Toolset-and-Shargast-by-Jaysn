//::///////////////////////////////////////////////
//:: Weapon Spawn Script for Martial Classes
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Spawns in a magical SPECIFIC weapon suited for that class.
    Will spawn in either a generic or specific, depending on the
    value.

    NOTE: Only works on containers
*/
//:://////////////////////////////////////////////
//:: Created By:   Andrew, Brent
//:: Created On:   February 2002
//:://////////////////////////////////////////////

void main()
{
    ExecuteScript("nw_o2_classweap", OBJECT_SELF);
}
