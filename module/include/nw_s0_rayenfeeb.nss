//::///////////////////////////////////////////////
//:: Ray of EnFeeblement
//:: [NW_S0_rayEnfeeb.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Target must make a Fort save or take ability
//:: damage to Strength equaling 1d6 +1 per 2 levels,
//:: to a maximum of +5.  Duration of 1 round per
//:: caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 2, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- ray VFX didn't appeared at friendly targets on low difficulty
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{

/*
  Spellcast Hook Code
  Added 2003-06-23 by GeorgZ
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    int nBonus = spell.Level / 2;
    //Limit bonus ability damage
    if (nBonus > 5)
    {
        nBonus = 5;
    }
    if(nBonus < 1)
    {
        nBonus = 1;
    }
    int nLoss = MaximizeOrEmpower(6,1,spell.Meta,nBonus);
    effect eFeeb;
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eRay = EffectBeam(VFX_BEAM_ODD, spell.Caster, BODY_NODE_HAND);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make SR check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //Make a Fort save to negate
            if (!MySavingThrow(SAVING_THROW_FORT, spell.Target, spell.DC, SAVING_THROW_TYPE_NEGATIVE, spell.Caster))
            {
                if (spell.Meta == METAMAGIC_EXTEND)
                {
                    nDuration = nDuration * 2;
                }
                //Set ability damage effect
                eFeeb = EffectAbilityDecrease(ABILITY_STRENGTH, nLoss);
                effect eLink = EffectLinkEffects(eFeeb, eDur);
               //Apply the ability damage effect and VFX impact
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spell.Target);
             }
         }
    }
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 1.0);
}
