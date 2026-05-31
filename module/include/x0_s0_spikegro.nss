//::///////////////////////////////////////////////
//:: Spike Growth
//:: x0_s0_spikegro.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 1d4 points of damage
    every round.
    If you are in the area of the effect, you also get a 24 hour slow
    effect on you (will only add one)

    Lasts 1 hour/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- aoe did set up wrong exit script
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"

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
    // * passing dirge script for exit because it is an empty script (i.e., there is no special exit effects)
    effect eAOE = EffectAreaOfEffect(AOE_PER_ENTANGLE, "x0_s0_spikegroEN", "x0_s0_spikegroHB", "****");
    int nDuration = spell.Level;
//    effect eImpact = EffectVisualEffect(257);
//    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lTarget);

    //Check Extend metamagic feat.
    if(spell.Meta == METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }
    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, HoursToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_ENTANGLE","x0_s0_spikegrohb");
}
