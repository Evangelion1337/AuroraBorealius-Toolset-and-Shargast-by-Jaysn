//::///////////////////////////////////////////////
//:: End of Combat Round - Manticore
//:: CODI_OCRE_MANTIC.NSS
//:://////////////////////////////////////////////
/*
    Manticore's on combat round end script. Launches tail spike attack.
*/
//:://////////////////////////////////////////////
//:: Created By: Shkuey
//:: Created On: December 14, 2002
//:://////////////////////////////////////////////

#include "NW_I0_GENERIC"
void SpikeAttack(object oTarget);
void main()
{
    int iSpikes = GetLocalInt(OBJECT_SELF,"CODI_MANT_SPIKE");
    int iDay = GetLocalInt(OBJECT_SELF,"CODI_MANT_SPIKE_DAY");
    if (GetCalendarDay() != iDay)
    {
        iSpikes = 0;
        iDay = GetCalendarDay();
    }
    if (iSpikes < 4 && (Random(3) == 2 || GetDistanceBetween(GetNearestSeenOrHeardEnemy(),OBJECT_SELF)>9.9))
    {
        iSpikes++;
        object oTarget = FindSingleRangedTarget();
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
    SetLocalInt(OBJECT_SELF,"CODI_MANT_SPIKE",iSpikes);
    SetLocalInt(OBJECT_SELF,"CODI_MANT_SPIKE_DAY",GetCalendarDay());
    if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
    {
        DetermineSpecialBehavior();
    }
    else if(!GetSpawnInCondition(NW_FLAG_SET_WARNINGS))
    {
       DetermineCombatRound();
    }
    if(GetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1003));
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
}


