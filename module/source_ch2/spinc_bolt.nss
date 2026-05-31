/////////////////////////////////////////////////////////////////////////
//
// DoBolt - Function to apply an elemental bolt damage effect given
// the following arguments:
//
//        nDieSize - die size to roll (d4, d6, or d8)
//        nBonusDam - bonus damage per die, or 0 for none
//        nDice = number of dice to roll.
//        nBoltEffect - visual effect to use for bolt(s)
//        nVictimEffect - visual effect to apply to target(s)
//        nDamageType - elemental damage type of the cone (DAMAGE_TYPE_xxx)
//        nSaveType - save type used for cone (SAVING_THROW_TYPE_xxx)
//        nSchool - spell school, defaults to SPELL_SCHOOL_EVOCATION.
//        fDoKnockdown - flag indicating whether spell does knockdown, defaults to FALSE.
//        nSpellID - spell ID to use for events
//
/////////////////////////////////////////////////////////////////////////

#include "prc_inc_spells"
#include "prc_add_spell_dc"

//* fires a storm of nCap missiles at targets in area
void PRCDoMissileStorm(int nD6Dice, int nCap, int nSpell, int nMIRV = VFX_IMP_MIRV, int nVIS = VFX_IMP_MAGBLUE, int nDAMAGETYPE = DAMAGE_TYPE_MAGICAL, int nONEHIT = FALSE, int nReflexSave = FALSE);

float GetVFXLength(location lCaster, float fLength, float fAngle);

void DoBolt(int nCasterLevel, int nDieSize, int nBonusDam, int nDice, int nBoltEffect,
     int nVictimEffect, int nDamageType, int nSaveType,
     int nSchool = SPELL_SCHOOL_EVOCATION, int nDoKnockdown = FALSE, int nSpellID = -1, float fRangeFt = 120.0f)
{
     // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
     //if (!X2PreSpellCastCode()) return;

     PRCSetSchool(nSchool);
     
     object oCaster = OBJECT_SELF;

     // Get the spell ID if it was not given.
     if (-1 == nSpellID) nSpellID = PRCGetSpellId();

     // Adjust the damage type if necessary.
     nDamageType = PRCGetElementalDamageType(nDamageType, OBJECT_SELF);

    int nDamage;
    int nSaveDC;
    int bKnockdownTarget;
    float fDelay;

    int nPenetr = nCasterLevel + SPGetPenetr();

    // individual effect
    effect eVis  = EffectVisualEffect(nVictimEffect);
    effect eKnockdown = EffectKnockdown();
    effect eDamage;
    
    // where is the caster?
    location lCaster = GetLocation(oCaster);

    // where is the target?
    location lTarget = PRCGetSpellTargetLocation();
    vector vOrigin = GetPosition(oCaster);
    float fLength = FeetToMeters(fRangeFt);
    
    // run away! Vector maths coming up...
    // VFX length
    //float fAngle             = GetRelativeAngleBetweenLocations(lCaster, lTarget);
    //float fVFXLength         = GetVFXLength(lCaster, fLength, fAngle);
    //float fDuration          = 3.0f;
    

    /*BeamLineFromCenter(DURATION_TYPE_TEMPORARY, nBoltEffect, lCaster, fVFXLength, fAngle, fDuration, "prc_invisobj", 0.0f, "z", 0.0f, 0.0f,
                      -1, -1, 0.0f, 1.0f, // no secondary VFX
                      fDuration);
    */
        // Do VFX. This is moderately heavy, so it isn't duplicated by Twin Power
        float fAngle             = GetRelativeAngleBetweenLocations(lCaster, lTarget);
        float fSpiralStartRadius = FeetToMeters(1.0f);
        float fRadius            = FeetToMeters(5.0f);
        float fDuration          = 4.5f;
        float fVFXLength         = GetVFXLength(lCaster, fLength, GetRelativeAngleBetweenLocations(lCaster, lTarget));
        // A tube of beams, radius 5ft, starting 1m from manifester and running for the length of the line
        BeamGengon(DURATION_TYPE_TEMPORARY, nBoltEffect, lCaster, fRadius, fRadius,
                   1.0f, fVFXLength, // Start 1m from the manifester, end at LOS end
                   8, // 8 sides
                   fDuration, "prc_invisobj",
                   0.0f, // Drawn instantly
                   0.0f, 0.0f, 45.0f, "y", fAngle, 0.0f,
                   -1, -1, 0.0f, 1.0f, // No secondary VFX
                   fDuration
                   );    
    // spell damage effects
    // Loop over targets in the spell shape
    object oTarget = MyFirstObjectInShape(SHAPE_SPELLCYLINDER, fLength, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, vOrigin);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != oCaster && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster))
        {
            // Let the AI know
            PRCSignalSpellEvent(oTarget, TRUE, nSpellID, oCaster);
            // Reset the knockdown target flag.
            bKnockdownTarget = FALSE;
            // Make an SR check
            if(!PRCDoResistSpell(oCaster, oTarget, nPenetr))
            {
                // Roll damage
                nDamage = PRCGetMetaMagicDamage(nDamageType, nDice, nDieSize, nBonusDam);
                // Acid Sheath adds +1 damage per die to acid descriptor spells
                if (GetHasDescriptor(nSpellID, DESCRIPTOR_ACID) && GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH, oCaster))
                	nDamage += nDice;  
				// Adds damage per dice
				nDamage += SpellDamagePerDice(oCaster, nDice);
                int nFullDamage = nDamage;
                
                // Do save
                nSaveDC = PRCGetSaveDC(oTarget,OBJECT_SELF);
                if(nSaveType == SAVING_THROW_TYPE_COLD)
                {
                    // Cold has a fort save for half
                    if(PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nSaveDC, nSaveType))
                    {
                        if (GetHasMettle(oTarget, SAVING_THROW_FORT))
                            nDamage = 0;
                        nDamage /= 2;
                    }
                }
                else
                    // Adjust damage according to Reflex Save, Evasion or Improved Evasion
                    nDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget, nSaveDC, nSaveType);

                if(nDamage > 0)
                {
                    fDelay = GetDistanceBetweenLocations(lCaster, GetLocation(oTarget)) / 20.0f;
                    eDamage = PRCEffectDamage(oTarget, nDamage, nDamageType);
                    DelayCommand(1.0f + fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget));
                    DelayCommand(1.0f + fDelay, PRCBonusDamage(oTarget));
                    DelayCommand(1.0f + fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }// end if - There was still damage remaining to be dealt after adjustments
                                        
                // Determine if the target needs to be knocked down.  The target is knocked down
                // if all of the following criteria are met:
                //    - Knockdown is enabled.
                //    - The damage from the spell didn't kill the creature
                //    - The creature is large or smaller
                //    - The creature failed it's reflex save.
                // If the spell does knockdown we need to figure out whether the target made or failed
                // the reflex save.  If the target doesn't have improved evasion this is easy, if the
                // damage is the same as the original damage then the target failed it's save.  If the
                // target has improved evasion then it's harder as the damage is halved even on a failed
                // save, so we have to catch that case.
                bKnockdownTarget = nDoKnockdown && !GetIsDead(oTarget) &&
                           PRCGetCreatureSize(oTarget) <= CREATURE_SIZE_LARGE &&
                           (nFullDamage == nDamage || (0 != nDamage && GetHasFeat(FEAT_IMPROVED_EVASION, oTarget)));
                // If we're supposed to apply knockdown then do so for 1 round.
                 if (bKnockdownTarget)
                      SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oTarget, RoundsToSeconds(1),TRUE,-1,nCasterLevel);
                
            }// end if - SR check
        }// end if - Target validity check

       // Get next target
        oTarget = MyNextObjectInShape(SHAPE_SPELLCYLINDER, fLength, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, vOrigin);
    }// end while - Target loop

     PRCSetSchool();
}

// taken with minor modification from  psi_power_enbolt

float GetVFXLength(location lCaster, float fLength, float fAngle)
{
    float fLowerBound = 0.0f;
    float fUpperBound = fLength;
    float fVFXLength  = fLength / 2;
    vector vVFXOrigin = GetPositionFromLocation(lCaster);
    vector vAngle     = AngleToVector(fAngle);
    vector vVFXEnd;
    int bConverged    = FALSE;
    while(!bConverged)
    {
        // Create the test vector for this loop
        vVFXEnd = vVFXOrigin + (fVFXLength * vAngle);

        // Determine which bound to move.
        if(LineOfSightVector(vVFXOrigin, vVFXEnd))
            fLowerBound = fVFXLength;
        else
            fUpperBound = fVFXLength;

        // Get the new middle point
        fVFXLength = (fUpperBound + fLowerBound) / 2;

        // Check if the locations have converged
        if(fabs(fUpperBound - fLowerBound) < 2.5f)
            bConverged = TRUE;
    }

    return fVFXLength;
}

//::///////////////////////////////////////////////
//:: PRCDoMissileStorm
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Fires a volley of missiles around the area
    of the object selected.

    Each missiles (nD6Dice)d6 damage.
    There are casterlevel missiles (to a cap as specified)
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 31, 2002
//:://////////////////////////////////////////////
//:: Modified March 14 2003: Removed the option to hurt chests/doors
//::  was potentially causing bugs when no creature targets available.
void PRCDoMissileStorm(int nD6Dice, int nCap, int nSpell, int nMIRV = VFX_IMP_MIRV, int nVIS = VFX_IMP_MAGBLUE, int nDAMAGETYPE = DAMAGE_TYPE_MAGICAL, int nONEHIT = FALSE, int nReflexSave = FALSE)
{
    object oTarget = OBJECT_INVALID;
    int nCasterLvl = PRCGetCasterLevel(OBJECT_SELF);
//    int nDamage = 0;
    int nMetaMagic = PRCGetMetaMagicFeat();
    int nCnt = 1;
    effect eMissile = EffectVisualEffect(nMIRV);
    effect eVis = EffectVisualEffect(nVIS);
    float fDist = 0.0;
    float fDelay = 0.0;
    float fDelay2, fTime;
    location lTarget = PRCGetSpellTargetLocation(); // missile spread centered around caster
    int nMissiles = nCasterLvl;

    nCasterLvl +=SPGetPenetr();

    if (nMissiles > nCap)
    {
        nMissiles = nCap;
    }

        /* New Algorithm
            1. Count # of targets
            2. Determine number of missiles
            3. First target gets a missile and all Excess missiles
            4. Rest of targets (max nMissiles) get one missile
       */
    int nEnemies = 0;

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget) )
    {
        // * caster cannot be harmed by this spell
        if (spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, OBJECT_SELF) && (oTarget != OBJECT_SELF))
        {
            // GZ: You can only fire missiles on visible targets
            // 1.69 change
            // If the firing object is a placeable (such as a projectile trap),
            // we skip the line of sight check as placeables can't "see" things.
            if ( ( GetObjectType(OBJECT_SELF) == OBJECT_TYPE_PLACEABLE ) ||
                GetObjectSeen(oTarget,OBJECT_SELF))
            {
                nEnemies++;
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lTarget, TRUE, OBJECT_TYPE_CREATURE);
     }

     if (nEnemies == 0) return; // * Exit if no enemies to hit
     int nExtraMissiles = nMissiles / nEnemies;

     // April 2003
     // * if more enemies than missiles, need to make sure that at least
     // * one missile will hit each of the enemies
     if (nExtraMissiles <= 0)
     {
        nExtraMissiles = 1;
     }

     // by default the Remainder will be 0 (if more than enough enemies for all the missiles)
     int nRemainder = 0;

     if (nExtraMissiles >0)
        nRemainder = nMissiles % nEnemies;

     if (nEnemies > nMissiles)
        nEnemies = nMissiles;

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget) && nCnt <= nEnemies)
    {
        // * caster cannot be harmed by this spell
        if (spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, OBJECT_SELF) && (oTarget != OBJECT_SELF) && 
            (( GetObjectType(OBJECT_SELF) == OBJECT_TYPE_PLACEABLE ) || 
            (GetObjectSeen(oTarget,OBJECT_SELF))))
        {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpell));

                // * recalculate appropriate distances
                fDist = GetDistanceBetween(OBJECT_SELF, oTarget);
                fDelay = fDist/(3.0 * log(fDist) + 2.0);

                // Firebrand.
                // It means that once the target has taken damage this round from the
                // spell it won't take subsequent damage
                if (nONEHIT == TRUE)
                {
                    nExtraMissiles = 1;
                    nRemainder = 0;
                }

                int i = 0;
                //--------------------------------------------------------------
                // GZ: Moved SR check out of loop to have 1 check per target
                //     not one check per missile, which would rip spell mantels
                //     apart
                //--------------------------------------------------------------
                if (!PRCDoResistSpell(OBJECT_SELF, oTarget,nCasterLvl, fDelay))
                {
                    for (i=1; i <= nExtraMissiles + nRemainder; i++)
                    {
                        //Roll damage
                        int nDam = d6(nD6Dice);
                        //Enter Metamagic conditions
                        if ((nMetaMagic & METAMAGIC_MAXIMIZE))
                        {
                             nDam = nD6Dice*6;//Damage is at max
                        }
                        if ((nMetaMagic & METAMAGIC_EMPOWER))
                        {
                              nDam = nDam + nDam/2; //Damage/Healing is +50%
                        }
                        
                        // Acid Sheath adds +1 damage per die to acid descriptor spells
                        if (GetHasDescriptor(nSpell, DESCRIPTOR_ACID) && GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF))
                        	nDam += nD6Dice;
                        nDam += SpellDamagePerDice(OBJECT_SELF, nD6Dice);	

                        if(i == 1)
                        {
                            //nDam += ApplySpellBetrayalStrikeDamage(oTarget, OBJECT_SELF);
                            DelayCommand(fDelay, PRCBonusDamage(oTarget));
                        }

                        // Jan. 29, 2004 - Jonathan Epp
                        // Reflex save was not being calculated for Firebrand
                        if(nReflexSave)
                        {
                            if(nDAMAGETYPE == DAMAGE_TYPE_FIRE)
                                nDam = PRCGetReflexAdjustedDamage(nDam, oTarget, PRCGetSaveDC(oTarget, OBJECT_SELF), SAVING_THROW_TYPE_FIRE);
                            else if(nDAMAGETYPE == DAMAGE_TYPE_ELECTRICAL)
                                nDam = PRCGetReflexAdjustedDamage(nDam, oTarget, PRCGetSaveDC(oTarget, OBJECT_SELF), SAVING_THROW_TYPE_ELECTRICITY);
                            else if(nDAMAGETYPE == DAMAGE_TYPE_COLD)
                                nDam = PRCGetReflexAdjustedDamage(nDam, oTarget, PRCGetSaveDC(oTarget, OBJECT_SELF), SAVING_THROW_TYPE_COLD);
                            else if(nDAMAGETYPE == DAMAGE_TYPE_ACID)
                                nDam = PRCGetReflexAdjustedDamage(nDam, oTarget, PRCGetSaveDC(oTarget, OBJECT_SELF), SAVING_THROW_TYPE_ACID);
                            else if(nDAMAGETYPE == DAMAGE_TYPE_SONIC)
                                nDam = PRCGetReflexAdjustedDamage(nDam, oTarget, PRCGetSaveDC(oTarget, OBJECT_SELF), SAVING_THROW_TYPE_SONIC);
                        }

                        fTime = fDelay;
                        fDelay2 += 0.1;
                        fTime += fDelay2;

                        //Set damage effect
                        effect eDam = PRCEffectDamage(oTarget, nDam, nDAMAGETYPE);
                        //Apply the MIRV and damage effect
                        DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget));
                        DelayCommand(fDelay2, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget));
                        DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    }
                } // for
                else
                {  // * apply a dummy visual effect
                 ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget);
                }
                nCnt++;// * increment count of missiles fired
                nRemainder = 0;
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }

}

// Test main
//void main(){}
