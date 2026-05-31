//::///////////////////////////////////////////////
//:: Stonehold
//:: X2_S0_StneholdC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates an area of effect that will cover the
    creature with a stone shell holding them in
    place.
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: May 04, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();

    //--------------------------------------------------------------------------
    // GZ 2003-Oct-15
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail.
    //--------------------------------------------------------------------------
    if(!GetIsObjectValid(aoe.Creator))
    {
        DestroyObject(aoe.AOE);
        return;
    }

    int nRounds,nSaveType;
    effect eHold = EffectParalyze();
    effect eDur = EffectVisualEffect(VFX_DUR_STONEHOLD);
    eHold = EffectLinkEffects(eDur, eHold);
    eHold = ExtraordinaryEffect(eHold);
    float fDelay;

    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(!GetHasSpellEffect(spell.Id,oTarget) && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
        {
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            fDelay = GetRandomDelay(0.75, 1.75);
            if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
            {
                //engine workaround to ensure no-roll behavior if immune to paralysis
                nSaveType = GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, aoe.Creator) ? SAVING_THROW_TYPE_PARALYSE : SAVING_THROW_TYPE_MIND_SPELLS;
                if(!MySavingThrow(SAVING_THROW_WILL, oTarget, spell.DC, nSaveType, aoe.Creator, fDelay))
                {
                    nRounds = MaximizeOrEmpower(6, 1, spell.Meta);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHold, oTarget, RoundsToSeconds(nRounds)));
                }
            }
        }
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}
