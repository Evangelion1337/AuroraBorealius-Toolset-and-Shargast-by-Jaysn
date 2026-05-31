//::///////////////////////////////////////////////
//:: Flare
//:: [X0_S0_Flare.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature hit by ray loses 1 to attack rolls.

    DURATION: 10 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 17 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- spell no longer works on sightless creatures
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-06-20 by Georg
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
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        // * Apply the hit effect so player knows something happened
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
        if(!spellsIsSightless(spell.Target))
        {
            //Make SR Check
            if (!MyResistSpell(spell.Caster, spell.Target) && !MySavingThrow(SAVING_THROW_FORT, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
            {
                //Set damage effect
                effect eBad = EffectAttackDecrease(1);
                //Apply the VFX impact and damage effect
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBad, spell.Target, RoundsToSeconds(10));
            }
        }
    }
}
