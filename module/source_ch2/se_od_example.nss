//::///////////////////////////////////////////////
//:: Name On Death Example script
//:: FileName se_od_example
//:: Copyright (c) 2005 Melnibone Corp.
//:://////////////////////////////////////////////
/*
   On Death of NPC example script
*/
//:://////////////////////////////////////////////
//:: Created By: Sir Elric
//:: Created On: 26th June, 2005
//:://////////////////////////////////////////////
#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "se_drop_weapons"
void main()
{
    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();
    //Simple Drop Weapons v1.2 - OnDeath script example
    SE_DropHandSlot(OBJECT_SELF, INVENTORY_SLOT_LEFTHAND, 180.0, TRUE);
    SE_DropHandSlot(OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND, 180.0, TRUE);
    // If we're a good/neutral commoner,
    // adjust the killer's alignment evil
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }

    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    // NOTE: the OnDeath user-defined event does not
    // trigger reliably and should probably be removed
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
         SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }
    craft_drop_items(oKiller);
	
	ExecuteScript("prc_npc_death", OBJECT_SELF);
	ExecuteScript("prc_pwondeath", OBJECT_SELF);
}
