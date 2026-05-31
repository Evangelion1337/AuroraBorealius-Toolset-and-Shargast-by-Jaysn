//::///////////////////////////////////////////////
//:: Horizikaul's Boom
//:: X2_S0_HoriBoom
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// You blast the target with loud and high-pitched
// sounds. The target takes 1d4 points of sonic
// damage per two caster levels (maximum 5d4) and
// must make a Will save or be deafened for 1d4
// rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 22, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
/*
Patch 1.71

- saving throw subtype corrected to sonic as per spell's descriptor (this will
make a mind immune creature force to take their save against the deafness here)
- silenced creatures will be immune to the deafness effect
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-07-07 by Georg Zoeller
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook

    //Declare major variables  ( fDist / (3.0f * log( fDist ) + 2.0f) )
    spellsDeclareMajorVariables();
    int nCasterLvl = spell.Level/2;
    int nRounds = d4(1);
    effect eVis = EffectVisualEffect(VFX_IMP_SONIC);
    effect eDeaf = EffectDeaf();
    //Minimum caster level of 1, maximum of 15.
    if(nCasterLvl < 1)
    {
        nCasterLvl = 1;
    }
    else if (nCasterLvl > 5)
    {
        nCasterLvl = 5;
    }
    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Roll damage
            int nDam = MaximizeOrEmpower(4,nCasterLvl,spell.Meta);
            //Set damage effect
            effect eDam = EffectDamage(nDam, DAMAGE_TYPE_SONIC);
            //Apply the MIRV and damage effect
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);

            if(!GetHasEffect(EFFECT_TYPE_SILENCE,spell.Target) && !MySavingThrow(SAVING_THROW_WILL, spell.Target, spell.DC, SAVING_THROW_TYPE_SONIC, spell.Caster))
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, spell.Target, RoundsToSeconds(nRounds));
            }
        }
    }
}
