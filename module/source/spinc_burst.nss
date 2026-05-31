////////////////////////////////////////////////////////////////////////////////////
//
// DoBurst() - Do a damaging burst at the spell's target location.
//        nDieSize - size of die to roll.
//        nBonusDam - bonus damage per die.
//        nDice - number of dice to roll
//        nBurstEffect - VFX_xxx or AOE_xxx of burst vfx.
//        nVictimEffect - VFX_xxx of target impact.
//        nDamageType - DAMAGE_TYPE_xxx of the type of damage dealt
//        nSaveType - SAVING_THROW_xxx of type of save to use
//        bCasterImmune - Indicates whether the caster is immune to the spell
//        nSchool - SPELL_SCHOOL_xxx of the spell's school
//        nSpellID - ID # of the spell, if -1 PRCGetSpellId() is used
//        fAOEDuration - if > 0, then nBurstEffect should be an AOE_xxx vfx, it
//             will be played at the target location for this duration.  If this is
//             0 then nBurstEffect should be a VFX_xxx vfx.
//
////////////////////////////////////////////////////////////////////////////////////

#include "prc_inc_spells"
#include "prc_add_spell_dc"

void DoBurst (int nCasterLvl, int nDieSize, int nBonusDam, int nDice, int nBurstEffect,
     int nVictimEffect, float fRadius, int nDamageType, int nBonusDamageType, int nSaveType,
     int bCasterImmune = FALSE,
     int nSchool = SPELL_SCHOOL_EVOCATION, int nSpellID = -1,
     float fAOEDuration = 0.0f)
{
     PRCSetSchool(nSchool);

     // Get the spell ID if it was not given.
     if (-1 == nSpellID) nSpellID = PRCGetSpellId();

     // Get the spell target location as opposed to the spell target.
     location lTarget = PRCGetSpellTargetLocation();

        int nPenetr = nCasterLvl + SPGetPenetr();
     // Get the effective caster level and hand it to the SR engine.


     // Adjust the damage type of necessary, if the damage & bonus damage types are the
     // same we need to copy the adjusted damage type to the bonus damage type.
     int nSameDamageType = nDamageType == nBonusDamageType;
     nDamageType = PRCGetElementalDamageType(nDamageType, OBJECT_SELF);
     if (nSameDamageType) nBonusDamageType = nDamageType;

     // Apply the specified vfx to the location.  If we were given an aoe vfx then
     // fAOEDuration will be > 0.
     if (fAOEDuration > 0.0)
          ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,
               EffectAreaOfEffect(nBurstEffect, "****", "****", "****"), lTarget, fAOEDuration);
     else
          ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(nBurstEffect), lTarget);

     effect eVis = EffectVisualEffect(nVictimEffect);
     effect eDamage, eBonusDamage;
     float fDelay;

     // Declare the spell shape, size and the location.  Capture the first target object in the shape.
     // Cycle through the targets within the spell shape until an invalid object is captured.
     object oTarget = MyFirstObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
     while (GetIsObjectValid(oTarget))
     {
          // Filter out the caster if he is supposed to be immune to the burst.
          if (!(bCasterImmune && OBJECT_SELF == oTarget))
          {
               if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
               {
                    //Fire cast spell at event for the specified target
                    PRCSignalSpellEvent(oTarget, TRUE, nSpellID);

                    fDelay = PRCGetSpellEffectDelay(lTarget, oTarget);
                    if (!PRCDoResistSpell(OBJECT_SELF, oTarget,nPenetr, fDelay))
                    {
                         int nSaveDC = PRCGetSaveDC(oTarget, OBJECT_SELF);

                         int nDam = 0;
                         int nDam2 = 0;
                         if (nSameDamageType)
                         {
                              // Damage damage type is the simple case, just get the total damage
                              // of the spell's type, apply metamagic and roll the save.

                              // Roll damage for each target
                              nDam = PRCGetMetaMagicDamage(nDamageType, nDice, nDieSize, nBonusDam);
                			// Acid Sheath adds +1 damage per die to acid descriptor spells
                			if (GetHasDescriptor(nSpellID, DESCRIPTOR_ACID) && GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF))
                				nDam += nDice;  
                			nDam += SpellDamagePerDice(OBJECT_SELF, nDice);	

                              // Adjust damage for reflex save / evasion / imp evasion
                              nDam = PRCGetReflexAdjustedDamage(nDam, oTarget, nSaveDC, nSaveType);
                         }
                         else
                         {
                              // Damage of different types is a bit more complicated, we need to
                              // calculate the bonus damage ourselves, figure out if the save was
                              // 1/2 or no damage, and apply appropriately to the secondary damage
                              // type.

                              // Calculate base and bonus damage.
                              nDam = PRCGetMetaMagicDamage(nDamageType, nDice, nDieSize, 0);
                			// Acid Sheath adds +1 damage per die to acid descriptor spells
                			if (GetHasDescriptor(nSpellID, DESCRIPTOR_ACID) && GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF))
                				nDam += nDice;  
                			nDam += SpellDamagePerDice(OBJECT_SELF, nDice);	
                              nDam2 = nDice * nBonusDam;

                              // Adjust damage for reflex save / evasion / imp evasion.  We need to
                              // deal with damage being constant, damage being 0, and damage being
                              // some percentage of the total (should be 1/2).
                              int nAdjustedDam = PRCGetReflexAdjustedDamage(nDam, oTarget, nSaveDC, nSaveType);
                              if (0 == nAdjustedDam)
                              {
                                   // Evasion zero'ed out the damage, clear both damage values.
                                   nDam = 0;
                                   nDam2 = 0;
                              }
                              else if (nAdjustedDam < nDam)
                              {
                                   // Assume 1/2 damage, and half the bonus damage.
                                   nDam = nAdjustedDam;
                                   nDam2 /= 2;
                              }
                         }

                         //Set the damage effect
                         if (nDam > 0)
                         {
                              eDamage = PRCEffectDamage(oTarget, nDam, nDamageType);

                              // Apply effects to the currently selected target.
                              DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget));
                              PRCBonusDamage(oTarget);

                              // This visual effect is applied to the target object not the location as above.
                              DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                         }

                         // Apply bonus damage if it is a different type.
                         if (nDam2 > 0)
                         {
                              DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT,
                                   PRCEffectDamage(oTarget, nDam2, nBonusDamageType), oTarget));
                         }
                    }
               }
          }

          oTarget = MyNextObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
     }

     // Let the SR engine know that we are done and clear out school local var.

     PRCSetSchool();
}

// Test main
//void main(){}
