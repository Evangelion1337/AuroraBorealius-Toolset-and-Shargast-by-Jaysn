//::///////////////////////////////////////////////
//:: Sunbeam
//:: s_Sunbeam.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: All creatures in the beam are struck blind and suffer 4d6 points of damage. (A successful
//:: Reflex save negates the blindness and reduces the damage by half.) Creatures to whom sunlight
//:: is harmful or unnatural suffer double damage.
//::
//:: Undead creatures caught within the ray are dealt 1d6 points of damage per caster level
//:: (maximum 20d6), or half damage if a Reflex save is successful. In addition, the ray results in
//:: the total destruction of undead creatures specifically affected by sunlight if they fail their saves.
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Feb 22, 2001
//:://////////////////////////////////////////////
//:: Last Modified By: Keith Soleski, On: March 21, 2001
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.71

- second save at DC 0 removed
- damage wasn't properly calculated in case that there would be both undead and
non-undead creatures in AoE
- oozes and plants takes full damage as if they were undead
*/

#include "70_inc_spells"
#include "x0_i0_spells"
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

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eVis2 = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eStrike = EffectVisualEffect(VFX_FNF_SUNBEAM);
    effect eDam;
    effect eBlind = EffectBlindness();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eBlind, eDur);

    int nCasterLevel = spell.Level;
    int nRace;
    int nDamage;
    int nOrgDam;
    int nNumDice;
    float fDelay;
    int nBlindLength = 3;
    //Limit caster level
    if (nCasterLevel > 20)
    {
        nCasterLevel = 20;
    }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spell.Loc);
    //Get the first target in the spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc);
    while(GetIsObjectValid(oTarget))
    {
        // Make a faction check
        if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, spell.Caster))
        {
            fDelay = GetRandomDelay(1.0, 2.0);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make an SR check
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                nRace = GetRacialType(oTarget);
                //Check if the target is an undead, ooze or plant
                if(nRace == RACIAL_TYPE_UNDEAD || nRace == RACIAL_TYPE_OOZE || FindSubString(GetStringLowerCase(GetSubRace(oTarget)),"plant") > -1)
                {
                    nNumDice = nCasterLevel;
                }
                else if(spellsIsLightVulnerable(oTarget))
                {
                    nNumDice = 6;
                }
                else
                {
                    nNumDice = 3;
                }
                //Do metamagic checks
                nOrgDam = MaximizeOrEmpower(6,nNumDice,spell.Meta);

                //Get the adjusted damage due to Reflex Save, Evasion or Improved Evasion
                nDamage = GetReflexAdjustedDamage(nOrgDam, oTarget, spell.DC, SAVING_THROW_TYPE_DIVINE, spell.Caster);
                //saving throw wasn't successful
                if(nDamage > 0 && (nDamage == nOrgDam || GetHasFeat(FEAT_IMPROVED_EVASION,oTarget)))
                {
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nBlindLength)));
                }
                if(nDamage > 0)
                {
                    //Set damage effect
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_DIVINE);
                    //Apply the damage effect and VFX impact
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                }
            }
        }
        //Get the next target in the spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc);
    }
}
