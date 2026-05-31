//::///////////////////////////////////////////////
//:: Drown
//:: [X0_S0_Drown.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    if the creature fails a FORT throw.
    Does not work against Undead, Constructs, or Elementals.

January 2003:
 - Changed to instant kill the target.
May 2003:
 - Changed damage to 90% of current HP, instead of instant kill.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 26 2002
//:://////////////////////////////////////////////
//:: Last Update By: Andrew Nobbs May 01, 2003
/*
Patch 1.70

- won't affect wrong target at all (previously could still took spell mantle)
- added additional creatures being immune: oozes and various creatures of water
or aquatic subtype
- added immunity feedback to caster in case the target is immune
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
    int nDam = GetCurrentHitPoints(spell.Target);
    //Set visual effect
    effect eVis = EffectVisualEffect(VFX_IMP_FROST_S);
    effect eDam;
    //Check faction of target
    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Handle immune creatures
        if(spellsIsImmuneToDrown(spell.Target))
        {
            //engine workaround to get immunity feedback
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSpellImmunity(spell.Id), spell.Target, 0.01);
        }
        //Make SR Check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //Make a fortitude save
            if(!MySavingThrow(SAVING_THROW_FORT, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
            {
                nDam = FloatToInt(nDam * 0.9);
                eDam = EffectDamage(nDam, DAMAGE_TYPE_BLUDGEONING);
                //Apply the VFX impact and damage effect
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            }
        }
    }
}
