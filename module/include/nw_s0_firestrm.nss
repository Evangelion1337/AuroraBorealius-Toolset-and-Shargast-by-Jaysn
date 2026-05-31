//::///////////////////////////////////////////////
//:: Fire Storm
//:: NW_S0_FireStm
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a zone of destruction around the caster
    within which all living creatures are pummeled
    with fire.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 21, 2001
/*
Patch 1.70

- capped at lvl 20
- damage values were always even
- fixed special case where target wasn't damaged at all
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
    int bOdd;
    int nDamage;
    int nDamage2;
    int nCasterLevel = spell.Level;
    if(nCasterLevel > 20)
    {
        nCasterLevel = 20;
    }
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eFireStorm = EffectVisualEffect(VFX_FNF_FIRESTORM);
    float fDelay;
    //Apply Fire and Forget Visual in the area;
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFireStorm, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while(GetIsObjectValid(oTarget))
    {
        //This spell smites everyone who is more than 2 meters away from the caster.
        //if (GetDistanceBetween(oTarget, OBJECT_SELF) > 2.0)
        //{
            if (spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster) && oTarget != spell.Caster)
            {
                fDelay = GetRandomDelay(1.5, 2.5);
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //Make SR check, and appropriate saving throw(s).
                if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    //Roll Damage
                    nDamage = MaximizeOrEmpower(6,nCasterLevel,spell.Meta);
                    bOdd = nDamage/2*2 != nDamage;//is the value odd?
                    nDamage = nDamage/2;
                    nDamage2 = nDamage;
                    if(bOdd)//odd value divided by 2 is always rounded down
                    {       //so I will raise one of the values by 1
                        if(d2() == 1)//50% chance
                        {
                        nDamage++;//fire damage will be odd
                        }
                        else
                        {
                        nDamage2++;//divine damage will be odd
                        }
                    }
                    //first save for the divine part of the damage
                    nDamage2 = GetReflexAdjustedDamage(nDamage2, oTarget, spell.DC, SAVING_THROW_TYPE_DIVINE, spell.Caster);
                    if(nDamage2 > 0)
                    {   //if failed in saving throw, apply divine damage
                        effect eDivine = EffectDamage(nDamage2, DAMAGE_TYPE_DIVINE);
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDivine, oTarget));
                    }
                    //second save for the fire part of the damage
                    nDamage = GetReflexAdjustedDamage(nDamage, oTarget, spell.DC, SAVING_THROW_TYPE_FIRE, spell.Caster);
                    if(nDamage > 0)
                    {   //if failed in saving throw, apply fire damage
                        effect eFire = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, oTarget));
                    }
                    //if at least one of the save failed, apply fire visual effect, but only once
                    if(nDamage+nDamage2 > 0)
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    }
                }
            //}
        }
        //Select the next target within the spell shape.
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spell.Loc, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
