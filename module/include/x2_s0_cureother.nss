//::///////////////////////////////////////////////
//:: x2_s0_cureother
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Cure Critical Wounds on Others - causes 5 points
    of damage to the spell caster as well.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Jan 2/03
//:://////////////////////////////////////////////
/*
Patch 1.71

- missing saving throw added
- the healing domain power doesn't work anymore when the spell is cast from an item
- corrected maximized spell damage
- undeads are now damaged by positive (was negative)
- target type changed from standard hostile to the single target
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

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDice = 8;
    int nNumDice = 4;
    int nMaxExtraDamage = 20;
    int vfx_impactHurt = VFX_IMP_SUNSTRIKE;
    int vfx_impactHeal = VFX_IMP_SUPER_HEROISM;

    int nExtraDamage = spell.Level; // * figure out the bonus damage
    if (nExtraDamage > nMaxExtraDamage)
    {
        nExtraDamage = nMaxExtraDamage;
    }

    if(spell.Meta == METAMAGIC_MAXIMIZE && GetIsPC(spell.Target) && GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
    {   // * if low or normal difficulty then MAXMIZED is doubled.
        nExtraDamage = nExtraDamage*2;
    }

    //Calculate damage
    int nDamage = MaximizeOrEmpower(nDice,nNumDice,spell.Meta,nExtraDamage);

    if(spell.Meta != METAMAGIC_EMPOWER && spell.Item == OBJECT_INVALID && GetHasFeat(FEAT_HEALING_DOMAIN_POWER, spell.Caster))
    {   // * if the caster has healing domain, the spell is empowered
        nDamage = nDamage + (nDamage/2);
    }

    if (GetRacialType(spell.Target) != RACIAL_TYPE_UNDEAD)
    {
        if (spell.Target != spell.Caster)
        {
            //Set the heal effect
            effect eHeal = EffectHeal(nDamage);
            //Apply heal effect and VFX impact
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
            effect eVis2 = EffectVisualEffect(vfx_impactHeal);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);

            //Apply Damage Effect to the Caster
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(5), spell.Caster);
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_CURE_CRITICAL_WOUNDS, FALSE));
        }
    }
    //Check that the target is undead
    else
    {
        int nTouch = TouchAttackMelee(spell.Target);
        if (nTouch > 0)
        {
            if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_CURE_CRITICAL_WOUNDS));
                if (!MyResistSpell(spell.Caster, spell.Target))
                {
                    if(MySavingThrow(SAVING_THROW_WILL,spell.Target,spell.DC,SAVING_THROW_TYPE_POSITIVE,spell.Caster))
                    {
                        nDamage/= 2;
                    }
                    effect eDam = EffectDamage(nDamage,DAMAGE_TYPE_POSITIVE);
                    //Apply the VFX impact and effects
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                    effect eVis = EffectVisualEffect(vfx_impactHurt);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                }
            }
            //Apply Damage Effect to the Caster
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(5), spell.Caster);
        }
    }
}
