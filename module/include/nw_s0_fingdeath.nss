//::///////////////////////////////////////////////
//:: Finger of Death
//:: NW_S0_FingDeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// You can slay any one living creature within range.
// The victim is entitled to a Fortitude saving throw to
// survive the attack. If he succeeds, he instead
// sustains 3d6 points of damage +1 point per caster
// level.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 17, 2000
//:://////////////////////////////////////////////
//:: Updated By: Georg Z, On: Aug 21, 2003 - no longer affects placeables
/*
Patch 1.71

- target selection scheme changed from selective to singe-target to allow target neutral creatures
- corrected immunity check (now handled in engine)
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
    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH_L);
    effect eVis2 = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //GZ: I still signal this event for scripting purposes, even if a placeable
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        if(GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE)
        {

            //Make SR check
            if(!MyResistSpell(spell.Caster, spell.Target))
            {
                //Make Fortitude save
                switch(MySavingThrow(SAVING_THROW_FORT, spell.Target, spell.DC, SAVING_THROW_TYPE_DEATH, spell.Caster))
                {
                case 0: //failed in save
                    //Apply the death effect and VFX impact
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), spell.Target);
                    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    break;
                case 1: //succeded in save
                    //Roll damage
                    nDamage = MaximizeOrEmpower(6,3,spell.Meta,spell.Level);
                    //Set damage effect
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
                    //Apply damage effect and VFX impact
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
                    break;
                case 2: //immune to the death
                    // Target shouldn't take damage if they are immune to death magic.
                    break;
                }
            }
        }
    }
}
