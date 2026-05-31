//::///////////////////////////////////////////////
//:: Sunburst
//:: X0_S0_Sunburst
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Brilliant globe of heat
// All creatures in the globe are blinded and
// take 6d6 damage
// Undead creatures take 1d6 damage (max 25d6)
// The blindness is permanent unless cast to remove it
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 23 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 14, 2003
//:: Notes: Changed damage to non-undead to 6d6
//:: 2003-10-09: GZ Added Subrace check for vampire special case, bugfix
/*
Patch 1.71

- was missing delay in few effect applications
- was missing VFXs in few cases
- killing method could fail in special case (magic damage immune/resistant vampire)
- removed second and third save - all effects are now tied with first save
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
    int nCasterLvl = spell.Level;
    int nRace;
    int nDamage;
    int nOrgDam;
    int nNumDice;
    float fDelay;
    effect eDeath = SupernaturalEffect(EffectDeath(FALSE,FALSE));
    effect eBlindness = EffectBlindness();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eBlindness, eDur);
    effect eExplode = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    effect eHitVis = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_FIRE);
    effect eLOS = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);
    effect eDam;
    //Limit Caster level for the purposes of damage
    if (nCasterLvl > 25)
    {
        nCasterLvl = 25;
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Caster);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eLOS, spell.Loc);

    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster))
        {
            fDelay = GetRandomDelay();//random delay so each target gets hit in different moment
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //This visual effect is applied to the target object not the location as above.  This visual effect
            //represents the flame that erupts on the target not on the ground.
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHitVis, oTarget);

            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                nRace = GetRacialType(oTarget);
                //Check if the target is an undead, ooze or plant
                if (nRace == RACIAL_TYPE_UNDEAD || nRace == RACIAL_TYPE_OOZE || FindSubString(GetStringLowerCase(GetSubRace(oTarget)),"plant") > -1)
                {
                    nNumDice = nCasterLvl;
                }
                else if(spellsIsLightVulnerable(oTarget))
                {
                    nNumDice = 12;
                }
                else
                {
                    nNumDice = 6;
                }
                //Roll damage for each target
                nOrgDam = MaximizeOrEmpower(6,nNumDice,spell.Meta);
                //Get the adjusted damage due to Reflex Save, Evasion or Improved Evasion
                nDamage = GetReflexAdjustedDamage(nOrgDam, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster);
                //saving throw wasn't successful
                if(nDamage > 0 && (nDamage == nOrgDam || GetHasFeat(FEAT_IMPROVED_EVASION,oTarget)))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget));
                    if(nRace == RACIAL_TYPE_UNDEAD && spellsIsLightVulnerable(oTarget))
                    {   //vampires are destroyed
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                    }
                }
                if(nDamage > 0)
                {
                    //Set the damage effect
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_MAGICAL);
                    // Apply effects to the currently selected target.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eExplode, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                }
           }
       }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    }
}
