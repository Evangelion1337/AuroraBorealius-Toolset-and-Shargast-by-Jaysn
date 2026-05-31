//::///////////////////////////////////////////////
//:: Destruction
//:: NW_S0_Destruc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature is destroyed if it fails a
    Fort save, otherwise it takes 10d6 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 13, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- saving throw subtype changed to death
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
    effect eDeath = EffectDeath();
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_DESTRUCTION);
    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make SR check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //Make a fortitude saving throw check
            switch(MySavingThrow(SAVING_THROW_FORT, spell.Target, spell.DC, SAVING_THROW_TYPE_DEATH, spell.Caster))
            {
            case 0: //failed in save
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spell.Target);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                break;
            case 1: //succeded in save
                nDamage = MaximizeOrEmpower(6,10,spell.Meta);
                //Set damage effect
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_DIVINE);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
                //Apply VFX impact
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                break;
            case 2: //immune to the death
                // Target shouldn't take damage if they are immune to death magic.
                break;
            }
        }
    }
}
