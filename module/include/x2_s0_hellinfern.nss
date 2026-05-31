//::///////////////////////////////////////////////
//:: Hellish Inferno
//:: x0_s0_inferno.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    NPC only spell for yaron

    like normal inferno but lasts only 5 rounds,
    ticks twice per round, adds attack and damage
    penalty.

*/
//:://////////////////////////////////////////////
// Georg Z, 19-10-2003
//:://////////////////////////////////////////////
/*
Patch 1.71

- damage decrease type changed to slashing so it affects any physical damage
- was missing target check and could affect friendly tarets at no-pvp area
- was missing delay in SR VFX
- incorrect VFX when spell was resisted
> now does at least initial damage instead of nothing
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void RunImpact();

void main()
{
    //--------------------------------------------------------------------------
    // Spellcast Hook Code
    // Added 2003-06-20 by Georg
    // If you want to make changes to all spells, check x2_inc_spellhook.nss to
    // find out more
    //--------------------------------------------------------------------------
    if (!X2PreSpellCastCode())
    {
        return;
    }
    // End of Spell Cast Hook

    spellsDeclareMajorVariables();
    //--------------------------------------------------------------------------
    // Calculate the duration
    //--------------------------------------------------------------------------
    int nDuration = spell.Level/2;

    if (nDuration < 1)
    {
        nDuration = 1;
    }
    else if (nDuration > 6)
    {
        nDuration = 6;
    }
    if (spell.Meta == METAMAGIC_EXTEND)
    {
       nDuration = nDuration * 2;
    }
    //workaround for already existing effect check because of ray effect
    int bHasSpellEffects = GetHasSpellEffect(spell.Id,spell.Target);
    //--------------------------------------------------------------------------
    // Flamethrower VFX, thanks to Alex
    //--------------------------------------------------------------------------
    effect eRay = EffectBeam(444,spell.Caster,BODY_NODE_CHEST);
    //----------------------------------------------------------------------
    // Engulf the target in flame
    //----------------------------------------------------------------------
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 3.0);

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        float fDelay = GetDistanceBetween(spell.Target, spell.Caster)/13;

        if(!MyResistSpell(spell.Caster, spell.Target, fDelay))
        {
            effect eDam  = EffectDamage(d6(2), DAMAGE_TYPE_FIRE);
            effect eDam2 = EffectDamage(d6(1), DAMAGE_TYPE_DIVINE);
            effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
            eDam = EffectLinkEffects(eVis,eDam); // flare up
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam2, spell.Target));

            //--------------------------------------------------------------------------
            // This spell no longer stacks. If there is one hand, that's enough
            //--------------------------------------------------------------------------
            if (bHasSpellEffects)
            {
                FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
                return;
            }

            effect eAttackDec = EffectAttackDecrease(4);
            effect eDamageDec = EffectDamageDecrease(4,DAMAGE_TYPE_SLASHING);
            effect eLink = EffectLinkEffects(eAttackDec, eDamageDec);
            effect eDur = EffectVisualEffect(VFX_DUR_INFERNO_CHEST);

            DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(nDuration)));

            DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDur,spell.Target,RoundsToSeconds(nDuration)));
            DelayCommand(fDelay+3.0,RunImpact());
        }
    }
}

void RunImpact()
{
    //--------------------------------------------------------------------------
    // Check if the spell has expired (check also removes effects)
    //--------------------------------------------------------------------------
    if (GZGetDelayedSpellEffectsExpired(spell.Id,spell.Target,spell.Caster))
    {
        return;
    }

    if (GetIsDead(spell.Target) == FALSE)
    {
        //* GZ: Removed Meta magic, does not work in delayed functions
        effect eDam  = EffectDamage(d6(2), DAMAGE_TYPE_FIRE);//could be added again, but this is not a player spell anymore
        effect eDam2 = EffectDamage(d6(1), DAMAGE_TYPE_DIVINE);
        effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
        eDam = EffectLinkEffects(eVis,eDam); // flare up
        ApplyEffectToObject (DURATION_TYPE_INSTANT,eDam,spell.Target);
        ApplyEffectToObject (DURATION_TYPE_INSTANT,eDam2,spell.Target);
        DelayCommand(3.0, RunImpact());
    }
}
