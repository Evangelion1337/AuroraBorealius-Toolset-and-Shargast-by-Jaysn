//::///////////////////////////////////////////////
//:: Default On Blocked
//:: NW_C2_DEFAULTE
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This will cause blocked creatures to open
    or smash down doors depending on int and
    str.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 23, 2001
//:: Modified by Zarathstra217
//:://////////////////////////////////////////////
#include "z217_behold"
object oBeholder=GetAreaOfEffectCreator();
void main()
{
    object oDoor = GetBlockingDoor();
	
	ExecuteScript("prc_npc_blocked", OBJECT_SELF);

    if(GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 5)
    {
        if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN) && GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 7 )
        {
            DoDoorAction(oDoor, DOOR_ACTION_OPEN);
        }
        else if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_BASH))
        {
            Disintegrate(oDoor);   //DoDoorAction(oDoor, DOOR_ACTION_BASH);
        }
    }
}
