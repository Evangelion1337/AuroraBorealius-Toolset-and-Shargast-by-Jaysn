//::///////////////////////////////////////////////
//:: Vampiric Touch
//:: NW_S0_VampTch
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    drain 1d6
    HP per 2 caster levels from the target.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 29, 2001
//:://////////////////////////////////////////////
/*
bugfix by Kovi 2002.07.22
- did double damage with maximize
- temporary hp was stacked
2002.08.25
- got temporary hp some immune creatures (Negative Energy Protection), lost
temporary hp against other resistant (SR, Shadow Shield)

Georg 2003-09-11
- Put in melee touch attack check, as the fixed attack bonus is now calculated correctly

Patch 1.70
- all temp hitpoints was removed even from other sources
- temp hitpoints were removed even in case that target was dead
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{

    //--------------------------------------------------------------------------
    /*  Spellcast Hook Code
       Added 2003-06-20 by Georg
       If you want to make changes to all spells,
       check x2_inc_spellhook.nss to find out more
    */
    //--------------------------------------------------------------------------

    if (!X2PreSpellCastCode())
    {
        return;
    }
    //--------------------------------------------------------------------------
    // End of Spell Cast Hook
    //--------------------------------------------------------------------------

    spellsDeclareMajorVariables();

    int nDDice = spell.Level /2;
    if (nDDice < 1)
    {
        nDDice = 1;
    }
    //--------------------------------------------------------------------------
    // GZ: Cap according to the book
    //--------------------------------------------------------------------------
    else if (nDDice>10)
    {
        nDDice = 10;
    }

    //--------------------------------------------------------------------------
    //Enter Metamagic conditions
    //--------------------------------------------------------------------------

    int nDamage = MaximizeOrEmpower(6,nDDice,spell.Meta);
    int nDuration = spell.Level/2;

    if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }

    //--------------------------------------------------------------------------
    //Limit damage to max hp + 10
    //--------------------------------------------------------------------------
    int nMax = GetCurrentHitPoints(spell.Target) + 10;
    if(nMax < nDamage)
    {
        nDamage = nMax;
    }

    effect eHeal = EffectTemporaryHitpoints(nDamage);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eHeal, eDur);

    effect eDamage = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eVisHeal = EffectVisualEffect(VFX_IMP_HEALING_M);
    if(GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE)
    {
        // GZ: * GetSpellCastItem() == OBJECT_INVALID is used to prevent feedback from showing up when used as OnHitCastSpell property
        if (TouchAttackMelee(spell.Target)>0)//first touch, then ask
        {
         if(GetRacialType(spell.Target) != RACIAL_TYPE_UNDEAD && //not an undead
            GetRacialType(spell.Target) != RACIAL_TYPE_CONSTRUCT && //not an construct
            !GetHasSpellEffect(SPELL_NEGATIVE_ENERGY_PROTECTION, spell.Target) && //not protected against neg energy (this is however not versatile, spell still works on targets with 100% damage immunity or 60+ negative damage resistance from item, see below)
            spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
            {
            SignalEvent(spell.Caster, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));
                if(MyResistSpell(spell.Caster, spell.Target) == 0)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    /*
                    if we really would want this spell not to work on targets immune to negative energy
                    we should do this:
                    int previousHP = GetCurrentHitPoints(spell.Target);
                    */
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spell.Target);
                    /*
                    if(GetCurrentHitPoints(spell.Target) != previousHP)//the target wasn't 100% immune
                    {
                        //do spell effects
                    }
                    */
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisHeal, spell.Caster);
                    RemoveTempHP(spell.Id, spell.Caster);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Caster, HoursToSeconds(nDuration));
                 }
            }
        }
    }
}
