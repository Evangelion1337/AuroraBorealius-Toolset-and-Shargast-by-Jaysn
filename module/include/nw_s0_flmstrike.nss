//::///////////////////////////////////////////////
//:: Flame Strike
//:: NW_S0_FlmStrike
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// A flame strike is a vertical column of divine fire
// roaring downward. The spell deals 1d6 points of
// damage per level, to a maximum of 15d6. Half the
// damage is fire damage, but the rest of the damage
// results directly from divine power and is therefore
// not subject to protection from elements (fire),
// fire shield (chill shield), etc.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 19, 2000
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001
/*
Patch 1.70

- fixed special case when damage wasn't applied
- damage values were always even
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
  object oTarget;
  int nCasterLvl = spell.Level;
  int nDamage, nDamage2;

  effect eStrike = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_FIRE);
  effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
  effect eHoly;
  effect eFire;
  //Limit caster level for the purposes of determining damage.
  if (nCasterLvl > 15)
  {
    nCasterLvl = 15;
  }
  int bOdd;

  //Declare the spell shape, size and the location.  Capture the first target object in the shape.
  oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, spell.Loc, FALSE, OBJECT_TYPE_CREATURE|OBJECT_TYPE_PLACEABLE|OBJECT_TYPE_DOOR);
  //Apply the location impact visual to the caster location instead of caster target creature.
  ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spell.Loc);
  //Cycle through the targets within the spell shape until an invalid object is captured.
  while ( GetIsObjectValid(oTarget) )
  {
       if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, spell.Caster))
       {
           //Fire cast spell at event for the specified target
           SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
           //Make SR check, and appropriate saving throw(s).
           if (!MyResistSpell(spell.Caster, oTarget, 0.6))
           {
                nDamage =  MaximizeOrEmpower(6,nCasterLvl,spell.Meta);
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
                //Adjust the damage based on Reflex Save, Evasion and Improved Evasion
                nDamage2 = GetReflexAdjustedDamage(nDamage2, oTarget, spell.DC, SAVING_THROW_TYPE_DIVINE,spell.Caster);
                nDamage = GetReflexAdjustedDamage(nDamage, oTarget, spell.DC, SAVING_THROW_TYPE_FIRE, spell.Caster);
                //Make a faction check so that only enemies receieve the full brunt of the damage.
                if(nDamage2 > 0 && !GetIsFriend(oTarget))//1.70 additional check in order not to waste delay
                {
                    eHoly =  EffectDamage(nDamage2,DAMAGE_TYPE_DIVINE);
                    DelayCommand(0.6, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHoly, oTarget));
                }
                if(nDamage > 0)
                {
                    eFire =  EffectDamage(nDamage,DAMAGE_TYPE_FIRE);
                    DelayCommand(0.6, ApplyEffectToObject(DURATION_TYPE_INSTANT, eFire, oTarget));
                }
                //if at least one of the save failed, apply fire visual effect, but only once
                if(nDamage+nDamage2 > 0)
                {
                    DelayCommand(0.6, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        //Select the next target within the spell shape.
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, spell.Loc, FALSE, OBJECT_TYPE_CREATURE|OBJECT_TYPE_PLACEABLE|OBJECT_TYPE_DOOR);
    }
}
