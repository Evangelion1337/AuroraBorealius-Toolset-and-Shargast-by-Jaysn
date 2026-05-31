//::///////////////////////////////////////////////
//:: Dirge
//:: x0_s0_dirge.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 2 points of Strength
    and Dexterity ability score damage.
    Lasts 1 round/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- disabled aura stacking
- aoe signalized wrong spell ID
- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "nw_i0_spells"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-06-20 by Georg
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook


    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    //change from AOE_PER_FOGMIND to AOE_MOB_CIRCGOOD
    effect eAOE = EffectAreaOfEffect(AOE_MOB_CIRCGOOD, "x0_s0_dirgeEN", "x0_s0_dirgeHB", "x0_s0_dirgeEX");
    effect eVis = EffectVisualEffect(VFX_DUR_AURA_ODD);
    eAOE = EffectLinkEffects(eAOE, eVis);
    int nDuration = spell.Level;

//    effect eCaster = EffectVisualEffect(VFX_DUR_BARD_SONG); //unused

    effect eFNF = EffectVisualEffect(VFX_FNF_SOUND_BURST);
    //Apply the FNF to the spell location
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, spell.Loc);

    effect eImpact = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_ACID);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    //Check Extend metamagic feat.
    if(spell.Meta == METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }
    //Create an instance of the AOE Object using the Apply Effect function

    //prevent stacking
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spell.Target, RoundsToSeconds(nDuration));
    spellsSetupNewAOE("VFX_MOB_CIRCGOOD","x0_s0_dirgehb");
}
