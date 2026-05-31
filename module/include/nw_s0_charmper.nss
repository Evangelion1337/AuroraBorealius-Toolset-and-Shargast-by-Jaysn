//::///////////////////////////////////////////////
//:: [Charm Person]
//:: [NW_S0_CharmPer.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is charmed for 1 round
//:: per caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 5, 2001
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 20, 2001
/*
Patch 1.70

- wont affect wrong target at all (previously could still took spell mantle)
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
    effect eVis = EffectVisualEffect(VFX_IMP_CHARM);
    effect eCharm = EffectCharmed();
    eCharm = GetScaledEffect(eCharm, spell.Target);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    //Link persistant effects
    effect eLink = EffectLinkEffects(eMind, eCharm);
    eLink = EffectLinkEffects(eLink, eDur);


    int nCasterLevel = spell.Level;
    int nDuration = 2 + nCasterLevel/3;
    nDuration = GetScaledDuration(nDuration, spell.Target);

    //Make Metamagic check for extend
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }
    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
      //Fire cast spell at event for the specified target
      SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
      if(AmIAHumanoid(spell.Target))
      {
        //Make SR Check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
             //Make a Will Save check
             if (!MySavingThrow(SAVING_THROW_WILL, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
             {
                 //Apply impact and linked effects
                 ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(nDuration));
                 ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
             }
        }
      }
    }
}
