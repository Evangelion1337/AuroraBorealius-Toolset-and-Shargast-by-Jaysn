//::///////////////////////////////////////////////
//:: Silence: On Enter
//:: NW_S0_SilenceA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target is surrounded by a zone of silence
    that allows them to move without sound.  Spell
    casters caught in this area will be unable to cast
    spells.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
- AOE effects made undispellable
- allies will be correctly affected by the silence effect no matter of game difficulty/pvp setting
and without need to make SR checks
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables including Area of Effect Object
    aoesDeclareMajorVariables();

    //effect eDur1 = EffectVisualEffect(VFX_IMP_SILENCE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eSilence = EffectSilence();
    effect eImmune = EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, 100);

    effect eLink = EffectLinkEffects(eDur2, eSilence);
    eLink = EffectLinkEffects(eLink, eImmune);
    eLink = ExtraordinaryEffect(eLink);

    object oTarget = GetEnteringObject();

    if(!GetHasSpellEffect(spell.Id,oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, GetIsEnemy(oTarget, aoe.Creator)));

        if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, aoe.Creator) && MyResistSpell(aoe.Creator,oTarget))
        {
            return;
        }

        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
    }
}
