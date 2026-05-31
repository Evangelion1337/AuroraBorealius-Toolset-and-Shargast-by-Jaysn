//::///////////////////////////////////////////////
//:: Default: On Spell Cast At
//:: demilich_onspell
//   Place in the OnSpellCastAt of the Demilich creature
//   Demilich add on by Demigog
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This determines if the spell just cast at the
    target is harmful or not.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 6, 2001
//:://////////////////////////////////////////////
#include "prc_inc_spells"
#include "NW_I0_GENERIC"
#include "zep_inc_scrptdlg"

void main()
{
    object oCaster = GetLastSpellCaster();
    if(GetLastSpellHarmful())
    {
        if(
         !GetIsObjectValid(GetAttackTarget()) &&
         !GetIsObjectValid(GetAttemptedSpellTarget()) &&
         !GetIsObjectValid(GetAttemptedAttackTarget()) &&
         GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN))
        )
        {
            if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                DetermineSpecialBehavior(oCaster);
            }
            else
            {
                DetermineCombatRound(oCaster);
            }
            //Shout Attack my target, only works with the On Spawn In setup
            SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
            //Shout that I was attacked
            SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
        }
    }
    if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1011));
    {
////////////////////////Demi Lich add on begins here/////////////////////////
     object oWaypoint = GetWaypointByTag("Gem_Tooth");
     object oPC = GetLastSpellCaster();
     object oUser = OBJECT_SELF;
       ClearAllActions();
     if (GetIsPC(oPC) && (PRCGetCasterLevel(oPC) >= 15))
       {
     if (FortitudeSave(oPC,13)==0)
       {
        if (GetIsObjectValid(oPC))
         {
         string sMessageToPC = GetStringByStrRef(nZEPDemiHavePower ,GENDER_MALE);
         SpeakString(sMessageToPC);
         effect oVisual = EffectBeam(VFX_BEAM_HOLY,oUser,BODY_NODE_HAND);
         ApplyEffectToObject(DURATION_TYPE_TEMPORARY,oVisual,oPC,1.5f);
         effect oDeath = EffectDeath();
         ApplyEffectToObject(DURATION_TYPE_PERMANENT,oDeath,oPC,1.0f);
          SetLocalInt(oPC,"trappedsoul",1);
          {
           SetLocalInt(oPC,"trappedsoul",1);
    }

}
}
}
}
}
}
