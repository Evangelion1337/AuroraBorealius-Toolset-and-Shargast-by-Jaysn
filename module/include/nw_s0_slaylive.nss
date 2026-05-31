//::///////////////////////////////////////////////
//:: [Slay Living]
//:: [NW_S0_SlayLive.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Caster makes a touch attack and if the target
//:: fails a Fortitude save they die.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: January 22nd / 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.71

- added missing impact damage visual effect
- touch attack occured too late
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
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eVis2 = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);

    //Make melee touch attack       
    if(TouchAttackMelee(spell.Target))//touch attack first as its usual in other similar spells
    {
        if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Make SR check
            if(!MyResistSpell(spell.Caster, spell.Target))
            {
                //Make Fort save
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
                    //Apply damage effect and VFX impact
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
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
