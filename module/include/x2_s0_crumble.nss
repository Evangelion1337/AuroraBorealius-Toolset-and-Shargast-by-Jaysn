//::///////////////////////////////////////////////
//:: Crumble
//:: X2_S0_Crumble
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// This spell inflicts 1d6 points of damage per
// caster level to Constructs to a maximum of 15d6.
// This spell does not affect living creatures.
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: Oct 2003/
//:: 2004-01-02: GZ: Removed Spell resistance check
//:://////////////////////////////////////////////
/*
Patch 1.71

- due to the bug, it couldn't affect neither placeables or doors
- was missing target check and could affect friendly tarets at no-pvp area
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void DoCrumble (int nDam, object oCaster, object oTarget);

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

    spellsDeclareMajorVariables();
    int  nCasterLvl = spell.Level;
    int  nType      = GetObjectType(spell.Target);
    int  nRacial    = GetRacialType(spell.Target);

    //Maximum caster level of 15. //minimum safety check is handled in new engine
    if (nCasterLvl > 15)
    {
        nCasterLvl = 15;
    }

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster) &&
    ((nType == OBJECT_TYPE_PLACEABLE || nType == OBJECT_TYPE_DOOR) ||
    (nType == OBJECT_TYPE_CREATURE && (nRacial == RACIAL_TYPE_CONSTRUCT || GetLevelByClass(CLASS_TYPE_CONSTRUCT,spell.Target)))))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        effect eCrumb = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eCrumb, spell.Target);

        int nDam = MaximizeOrEmpower(6,nCasterLvl,spell.Meta);

        if (nDam>0)//can't happen anyway
        {
            //----------------------------------------------------------------------
            // * Sever the tie between spellId and effect, allowing it to
            // * bypass any magic resistance
            //----------------------------------------------------------------------
            /*DelayCommand(0.1,*/DoCrumble(nDam, spell.Caster, spell.Target);//);
        }
    }
}

//------------------------------------------------------------------------------
// This part is moved into a delayed function in order to alllow it to bypass
// Golem Spell Immunity. Magic works by rendering all effects applied
// from within a spellscript useless. Delaying the creation and application of
// an effect causes it to loose it's SpellId, making it possible to ignore
// Magic Immunity. Hacktastic!  //shadooow: BS, useless, it does work without delay
//------------------------------------------------------------------------------
void DoCrumble (int nDam, object oCaster, object oTarget)
{
    float  fDist = GetDistanceBetween(oCaster, oTarget);
    float  fDelay = fDist/(3.0 * log(fDist) + 2.0);
    effect eDam = EffectDamage(nDam, DAMAGE_TYPE_SONIC);
    effect eMissile = EffectVisualEffect(VFX_FNF_MYSTICAL_EXPLOSION);
    effect eCrumb = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
    effect eVis = EffectVisualEffect(135);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eCrumb, oTarget);
    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget));
    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
    DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget));
}
