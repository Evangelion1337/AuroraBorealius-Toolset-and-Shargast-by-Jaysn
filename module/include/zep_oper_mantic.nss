//::///////////////////////////////////////////////
//:: On Percieve - Manticore
//:: CODI_OPER_MANTIC.NSS
//:://////////////////////////////////////////////
/*
    Checks to see if the perceived target is an
    enemy and if so will start combat by launching
    a volley of spikes.
*/
//:://////////////////////////////////////////////
//:: Created By: Shkuey
//:: Created On: Dec 14, 2002
//:://////////////////////////////////////////////
#include "inc_utility"	
#include "NW_I0_GENERIC"
void SpikeAttack(object oTarget);
void main()
{
    //This is the equivalent of a force conversation bubble, should only be used if you want an NPC
    //to say something while he is already engaged in combat.
    if(GetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION) && GetIsPC(GetLastPerceived()) && GetLastPerceptionSeen())
    {
        SpeakOneLinerConversation();
    }
    //If the last perception event was hearing based or if someone vanished then go to search mode
    if ((GetLastPerceptionVanished()) && GetIsEnemy(GetLastPerceived()))
    {
        object oGone = GetLastPerceived();
        if((GetAttemptedAttackTarget() == GetLastPerceived() ||
           GetAttemptedSpellTarget() == GetLastPerceived() ||
           GetAttackTarget() == GetLastPerceived()) && GetArea(GetLastPerceived()) != GetArea(OBJECT_SELF))
        {
           ClearAllActions();
           DetermineCombatRound();
        }
    }
    //Do not bother checking the last target seen if already fighting
    else if(!GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
    {
        //Check if the last percieved creature was actually seen
        if(GetLastPerceptionSeen())
        {
            if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                DetermineSpecialBehavior();
            }
            else if(GetIsEnemy(GetLastPerceived()))
            {
                if(!PRCGetHasEffect(EFFECT_TYPE_SLEEP))
                {
                    SetFacingPoint(GetPosition(GetLastPerceived()));
                    SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
                    int iSpikes = GetLocalInt(OBJECT_SELF,"CODI_MANT_SPIKE");
                    int iDay = GetLocalInt(OBJECT_SELF,"CODI_MANT_SPIKE_DAY");
                    if (GetCalendarDay() != iDay)
                    {
                        iSpikes = 0;
                        iDay = GetCalendarDay();
                    }
                    if (iSpikes < 4 && GetDistanceBetween(GetLastPerceived(),OBJECT_SELF)>5.0)
                    {
                        iSpikes++;
                        object oTarget = GetLastPerceived();
                        ClearAllActions();
                        SetFacingPoint(GetPosition(oTarget));
                        ActionCastFakeSpellAtObject(SPELL_MAGIC_MISSILE,oTarget);
                        SetCommandable(0,OBJECT_SELF);
                        DelayCommand(1.0,SetCommandable(1,OBJECT_SELF));
                        DelayCommand(1.05,ActionDoCommand(SpikeAttack(oTarget)));
                        DelayCommand(1.1,SetCommandable(0,OBJECT_SELF));
                        DelayCommand(1.2,SetCommandable(1,OBJECT_SELF));
                        DelayCommand(1.25,ActionDoCommand(SpikeAttack(oTarget)));
                        DelayCommand(1.3,SetCommandable(0,OBJECT_SELF));
                        DelayCommand(1.4,SetCommandable(1,OBJECT_SELF));
                        DelayCommand(1.45,ActionDoCommand(SpikeAttack(oTarget)));
                        DelayCommand(1.5,SetCommandable(0,OBJECT_SELF));
                        DelayCommand(1.6,SetCommandable(1,OBJECT_SELF));
                        DelayCommand(1.65,ActionDoCommand(SpikeAttack(oTarget)));
                        DelayCommand(1.7,SetCommandable(0,OBJECT_SELF));
                        DelayCommand(1.8,SetCommandable(1,OBJECT_SELF));
                        DelayCommand(1.85,ActionDoCommand(SpikeAttack(oTarget)));
                        DelayCommand(1.9,SetCommandable(0,OBJECT_SELF));
                        DelayCommand(2.0,SetCommandable(1,OBJECT_SELF));
                        DelayCommand(2.05,ActionDoCommand(SpikeAttack(oTarget)));
                    }
                    else
                    {
                        DetermineCombatRound();
                    }
                    SetLocalInt(OBJECT_SELF,"CODI_MANT_SPIKE",iSpikes);
                    SetLocalInt(OBJECT_SELF,"CODI_MANT_SPIKE_DAY",GetCalendarDay());
                }
            }
            //Linked up to the special conversation check to initiate a special one-off conversation
            //to get the PCs attention
            else if(GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION) && GetIsPC(GetLastPerceived()))
            {
                ActionStartConversation(OBJECT_SELF);
            }
        }
    }
    if(GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT) && GetLastPerceptionSeen())
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1002));
    }
}
void SpikeAttack(object oTarget)
{
    int iAttack = TouchAttackRanged(oTarget);
    effect eHit = EffectVisualEffect(VFX_COM_BLOOD_CRT_RED);
    effect eDmg;
    switch(iAttack)
    {
    case 0:
        eHit = EffectVisualEffect(VFX_COM_BLOOD_SPARK_MEDIUM,TRUE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,eHit,oTarget);
        break;
    case 1:
        eDmg = EffectDamage(d8() + 2,DAMAGE_TYPE_PIERCING,DAMAGE_POWER_PLUS_TWO);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,eHit,oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,eDmg,oTarget);
        break;
    case 2:
        eDmg = EffectDamage(d8(2) + 4,DAMAGE_TYPE_PIERCING,DAMAGE_POWER_PLUS_TWO);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,eHit,oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,eDmg,oTarget);
        break;
    }
	
	ExecuteScript("prc_npc_percep", OBJECT_SELF);
}
