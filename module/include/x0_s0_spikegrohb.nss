//::///////////////////////////////////////////////
//:: Spike Growth: On Heartbeat
//:: x0_s0_spikegroHB.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 1d4 acid damage
    per round
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- aoe will vanish with caster
- flying and incorporeal creatures are immune
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    aoesDeclareMajorVariables();
    //--------------------------------------------------------------------------
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the barrier then
    //--------------------------------------------------------------------------
    if(!GetIsObjectValid(aoe.Creator))
    {
        DestroyObject(aoe.AOE);
        return;
    }

    spellsDeclareMajorVariables();
    effect eSpeed = EffectMovementSpeedDecrease(30);
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);
    effect eDam;
    float fDelay;
    int nDamage;

    //Start cycling through the AOE Object for viable targets including doors and placable objects.
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
        {
            //Fire cast spell at event for the target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            fDelay = GetRandomDelay(1.0, 2.2);
            //Spell resistance check
            if(!spellsIsFlying(oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL) && !MyResistSpell(aoe.Creator, oTarget, fDelay))
            {
                nDamage = MaximizeOrEmpower(4, 1, spell.Meta);
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_PIERCING);

                //Apply damage and visuals
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));

                // * only apply a slow effect from this spell once
                if (!GetHasSpellEffect(spell.Id, oTarget))
                {
                    //Make a Reflex Save to avoid the effects of the movement hit.
                    if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, aoe.Creator, fDelay))
                    {
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSpeed, oTarget, HoursToSeconds(24));
                    }
                }
            }
        }
    //Get next target.
    oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}
