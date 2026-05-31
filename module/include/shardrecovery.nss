//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT7
/*
  Default OnDeath event handler for NPCs.
  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "se_respawn_inc"

void main()
{
    ///////////////////////////////////////
    /*      Scarface's XP/GP System      */
    ///////////////////////////////////////
    /*        Fire SFXPS Script          */
       ExecuteScript("sf_xp", OBJECT_SELF);
    /*                                   */
    ///////////////////////////////////////

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
     // Do not respawn creature if tagged with _NSP eg. NW_GOBLINA_NSP
    if (FindSubString(GetTag(OBJECT_SELF), "NSP") > -1)
    return;
    { SE_DoCreatureRespawn(); }
    if (!GetIsPC(oKiller)) return;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SCREEN_SHAKE), oKiller);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DESTRUCTION), OBJECT_SELF);
    SpeakString(GetName(OBJECT_SELF) + " was killed and a Zethnite shard was recovered by " + GetName(oKiller) +
                " in " + GetName(GetArea(OBJECT_SELF)), TALKVOLUME_SHOUT);
				
	ExecuteScript("prc_npc_death", OBJECT_SELF);
	ExecuteScript("prc_pwondeath", OBJECT_SELF);
				
}


