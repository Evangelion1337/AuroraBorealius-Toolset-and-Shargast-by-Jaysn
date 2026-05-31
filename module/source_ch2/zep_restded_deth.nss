//:://////////////////////////////////////////////////
//:: zep_restded_deth
/*
  Modified Default OnDeath event handler for NPCs.
(modified by Loki Hakanin of the CEP team)
  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
**************************************
NOTE FROM LOKI
**************************************
Since this is designed to be used with the Restless Dead
Creature in the CEP, it is designed to randomly respawn a new
Restless Dead a random % of the time (this is defined in the
constant ZEP_RESTLESS_DEAD_RESPAWN_CHANCE in the zep_inc_monster
file).
   */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Modified by: Loki Hakanin
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////

#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "zep_inc_monster"

void main()
{
    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();

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

    //**************************************************
    //************** Begin code block by Loki **********
    //**************************************************

    //Generate a percentile roll (0-99) and check if it
    //is strictly les than the respawn chance.
    int nRandomChance=Random(100);
    //If our random number is less than the respawn chance,
    //we have a respawn.  Respawn is handled by the
    //restless dead respawn placable, so we'll just drop one
    //here.
    if (nRandomChance < ZEP_RESTLESS_DEAD_RESPAWN_CHANCE)
        {
        CreateObject(OBJECT_TYPE_PLACEABLE,"zep_restded_resp",GetLocation(OBJECT_SELF));
		}
	ExecuteScript("prc_npc_death", OBJECT_SELF);
	ExecuteScript("prc_pwondeath", OBJECT_SELF);

}
