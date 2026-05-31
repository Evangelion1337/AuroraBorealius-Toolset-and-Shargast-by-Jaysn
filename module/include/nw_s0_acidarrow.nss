//::///////////////////////////////////////////////
//:: Melf's Acid Arrow
//:: MelfsAcidArrow.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    An acidic arrow springs from the caster's hands
    and does 3d6 acid damage to the target.  For
    every 3 levels the caster has the target takes an
    additional 1d6 per round.
*/
/////////////////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Aidan Scanlan
//:: Created On: 01/09/01
//:://////////////////////////////////////////////
//:: Rewritten: Georg Zoeller, Oct 29, 2003
//:: Now uses VFX to track its own duration, cutting
//:: down the impact on the CPU to 1/6th
//:://////////////////////////////////////////////
/*
Patch 1.70

- spell did nothing if target suffers with secondary effect from this spell
- SR VFX wasn't delayed
- incorrect VFX when spell was resisted
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x2_i0_spells"

void RunImpact();

void main()
{
    spellsDeclareMajorVariables();

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

    //--------------------------------------------------------------------------
    // Calculate the duration
    //--------------------------------------------------------------------------
    int nDuration = (spell.Level/3);

    if (nDuration < 1)
    {
        nDuration = 1;
    }

    if (spell.Meta == METAMAGIC_EXTEND)
    {
       nDuration = nDuration * 2;
    }

    //--------------------------------------------------------------------------
    // Setup VFX
    //--------------------------------------------------------------------------
    effect eVis      = EffectVisualEffect(VFX_IMP_ACID_L);
    effect eDur      = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eArrow = EffectVisualEffect(VFX_DUR_MIRV_ACID);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eArrow, spell.Target);
    //--------------------------------------------------------------------------
    // Set the VFX to be non dispelable, because the acid is not magic
    //--------------------------------------------------------------------------
    eDur = ExtraordinaryEffect(eDur);
     // * Dec 2003- added the reaction check back i
    if (spellsIsTarget(spell.Target,SPELL_TARGET_SINGLETARGET,spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        float fDist = GetDistanceToObject(spell.Target);
        float fDelay = (fDist/25.0);//(3.0 * log(fDist) + 2.0);


        if(!MyResistSpell(spell.Caster, spell.Target,fDelay))
        {
            //----------------------------------------------------------------------
            // Do the initial 3d6 points of damage
            //----------------------------------------------------------------------
            int nDamage = MaximizeOrEmpower(6,3,spell.Meta);
            effect eDam = EffectDamage(nDamage, DAMAGE_TYPE_ACID);

            DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
            DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
            //--------------------------------------------------------------------------
            // This spell no longer stacks. If there is one of that type, thats ok
            //--------------------------------------------------------------------------
            if (GetHasSpellEffect(spell.Id, spell.Target))
            {
                FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
                return;
            }
            //----------------------------------------------------------------------
            // Apply the VFX that is used to track the spells duration
            //----------------------------------------------------------------------
            DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDur,spell.Target,RoundsToSeconds(nDuration)));
            DelayCommand(6.0,RunImpact());
        }
//        else //removed, handled in MyResistSpell function
//        {
            //----------------------------------------------------------------------
            // Indicate Failure
            //----------------------------------------------------------------------
//            effect eSmoke = EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE);
//            DelayCommand(fDelay+0.1,ApplyEffectToObject(DURATION_TYPE_INSTANT,eSmoke,spell.Target));
//        }
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

    if (!GetIsDead(spell.Target))
    {
        //----------------------------------------------------------------------
        // Calculate Damage
        //----------------------------------------------------------------------
        int nDamage = MaximizeOrEmpower(6,1,spell.Meta);
        effect eDam = EffectDamage(nDamage, DAMAGE_TYPE_ACID);
        effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);
        eDam = EffectLinkEffects(eVis,eDam); // flare up
        ApplyEffectToObject (DURATION_TYPE_INSTANT,eDam,spell.Target);
        DelayCommand(6.0,RunImpact());
    }
}
