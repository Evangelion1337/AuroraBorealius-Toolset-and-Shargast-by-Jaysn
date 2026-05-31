//::///////////////////////////////////////////////
//:: Storm of Vengeance: Heartbeat
//:: NW_S0_StormVenC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates an AOE that decimates the enemies of
    the cleric over a 30ft radius around the caster
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 8, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- damage is now different target by target
- aoe will vanish with caster
- AOE effects made undispellable
- duration of the stunning effect shortened to 1 round as per spells description
- fixed rare case when AOE could last more than 10rounds
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();

    //--------------------------------------------------------------------------
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the barrier then
    //--------------------------------------------------------------------------
    if(!GetIsObjectValid(aoe.Creator) || GetLocalInt(aoe.AOE,"AOE_NUM_HEARTBEATS") >= 10)
    {
        DestroyObject(aoe.AOE);
        return;
    }
    SetLocalInt(aoe.AOE,"AOE_NUM_HEARTBEATS",GetLocalInt(aoe.AOE,"AOE_NUM_HEARTBEATS")+1);//1.71: protection against bug that increase AOE duration

    effect eAcid, eElec;
    effect eStun = EffectStunned();
    effect eVisAcid = EffectVisualEffect(VFX_IMP_ACID_S);
    effect eVisElec = EffectVisualEffect(VFX_IMP_LIGHTNING_M);
    effect eVisStun = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eStun, eVisStun);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = ExtraordinaryEffect(eLink);

    float fDelay;
    //Get first target in spell area
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, aoe.Creator))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            //Make an SR Check
            fDelay = GetRandomDelay(0.5, 2.0);
            if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
            {
                // * if the saving throw is made they still suffer acid damage.
                eAcid = EffectDamage(d6(3), DAMAGE_TYPE_ACID);
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisAcid, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eAcid, oTarget));

                //Make a saving throw check
                if(MySavingThrow(SAVING_THROW_REFLEX, oTarget, spell.DC, SAVING_THROW_TYPE_ELECTRICITY, aoe.Creator, fDelay))
                {
                    if (d2()==1)
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisElec, oTarget));
                    }
                }
                else
                {
                    // * if they fail the saving throw, they suffer Electrical damage too
                    eElec = EffectDamage(d6(6), DAMAGE_TYPE_ELECTRICAL);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisElec, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eElec, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(1)));
                }
            }
         }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}
