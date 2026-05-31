//::///////////////////////////////////////////////
//:: Community Patch 1.70 New Spell Engine specific functions include
//:: 70_inc_spellfunc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
I had to create new include in order to change specific spells functions with retaining
compatibility with old spell scripts/library and without punging down another includes.

Note: to be able to compile script with this library, the "x0_i0_spells" include and
"70_inc_spells" must be above this include like this:
#include "70_inc_spells"
#include "x0_i0_spells"
#include "70_inc_spellfunc"
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: ?-11-2010
//:://////////////////////////////////////////////

void DoMissileStormSpell(int nD6Dice, int nCap, int nMIRV = VFX_IMP_MIRV, int nVIS = VFX_IMP_MAGBLUE, int nDAMAGETYPE = DAMAGE_TYPE_MAGICAL, int nONEHIT = FALSE, int nReflexSave = FALSE);

void DoGrenadeBomb(int nDice, int nNumDice, int nSplashDamage, int vSmallHit, int vRingHit, int nDamageType, float fExplosionRadius, int nObjectFilter, int nRacialType=RACIAL_TYPE_ALL);

void DoMissileStormSpell(int nD6Dice, int nCap, int nMIRV = VFX_IMP_MIRV, int nVIS = VFX_IMP_MAGBLUE, int nDAMAGETYPE = DAMAGE_TYPE_MAGICAL, int nONEHIT = FALSE, int nReflexSave = FALSE)
{
    int nCasterLvl = spell.Level;
    int i,nCnt = 1;
    effect eMissile = EffectVisualEffect(nMIRV);
    effect eVis = EffectVisualEffect(nVIS);
    float fDist = 0.0;
    float fDelay = 0.0;
    float fDelay2, fTime;
    int nMissiles = nCasterLvl;

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

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        // * caster cannot be harmed by this spell
        if (oTarget != spell.Caster && spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster))
        {
            // GZ: You can only fire missiles on visible targets
            // If the firing object is a placeable (such as a projectile trap),
            // we skip the line of sight check as placeables can't "see" things.
            if ( ( GetObjectType(spell.Caster) == OBJECT_TYPE_PLACEABLE ) ||
                   GetObjectSeen(oTarget,spell.Caster))
            {
                nEnemies++;
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
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

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    if (spell.Id == SPELL_BALL_LIGHTNING)//ball lightning has a single target area of effect
    {
        oTarget = spell.Target;
        nEnemies = 1;
        nExtraMissiles = nMissiles;
        nRemainder = 0;
    }
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget) && nCnt <= nEnemies)
    {
        // * caster cannot be harmed by this spell
        if (oTarget != spell.Caster && spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster) &&
           (GetObjectType(spell.Caster) == OBJECT_TYPE_PLACEABLE || GetObjectSeen(oTarget,spell.Caster)))
        {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));

                // * recalculate appropriate distances
                fDist = GetDistanceBetween(spell.Caster, oTarget);
                fDelay = fDist/(3.0 * log(fDist) + 2.0);

                // Firebrand.
                // It means that once the target has taken damage this round from the
                // spell it won't take subsequent damage
                if (nONEHIT)
                {
                    nExtraMissiles = 1;
                    nRemainder = 0;
                }

                //--------------------------------------------------------------
                // GZ: Moved SR check out of loop to have 1 check per target
                //     not one check per missile, which would rip spell mantels
                //     apart
                //--------------------------------------------------------------
                if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    nCap = nExtraMissiles + (nRemainder > 0);//this will distribute remainder missiles evenly
                    for (i=1; i <= nCap; i++)
                    {
                        //Roll damage
                        int nDam = MaximizeOrEmpower(6,nD6Dice,spell.Meta);
                        // if reflexsave allowed, make evasion check
                        if(nReflexSave)
                        {
                            if(nDAMAGETYPE == DAMAGE_TYPE_ELECTRICAL)
                            {
                                nDam = GetReflexAdjustedDamage(nDam, oTarget, spell.DC, SAVING_THROW_TYPE_ELECTRICITY, spell.Caster);
                            }
                            else if(nDAMAGETYPE == DAMAGE_TYPE_FIRE)
                            {
                                nDam = GetReflexAdjustedDamage(nDam, oTarget, spell.DC, SAVING_THROW_TYPE_FIRE, spell.Caster);
                            }
                        }

                        fDelay2 += 0.1;
                        fTime = fDelay + fDelay2;

                        //Set damage effect
                        effect eDam = EffectDamage(nDam, nDAMAGETYPE);
                        //Apply the MIRV and damage effect
                        DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget));
                        DelayCommand(fDelay2, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget));
                        //do not bother when no damage should happen anyway
                        if(nDam > 0)
                        {
                            DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                        }
                    }
                } // for
                else
                {   // * apply a dummy visual effect
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget);
                }
                nCnt++;// * increment count of missiles fired
                nRemainder--;
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    }
}


void DoGrenadeBomb(int nDice, int nNumDice, int nSplashDamage, int vSmallHit, int vRingHit, int nDamageType, float fExplosionRadius, int nObjectFilter, int nRacialType=RACIAL_TYPE_ALL)
{
    //Declare major variables  ( fDist / (3.0f * log( fDist ) + 2.0f) )
    object oTarget = GetSpellTargetObject();
    int nDamage;
    int nCnt;
    effect eMissile;
    effect eVis = EffectVisualEffect(vSmallHit);
    location lTarget = GetSpellTargetLocation();

    float fDist = GetDistanceBetween(OBJECT_SELF, oTarget);
    int nTouch;


    if (GetIsObjectValid(oTarget))
    {
        nTouch = TouchAttackRanged(oTarget);

    }
    else
    {
        nTouch = -1; // * this means that target was the ground, so the user
                    // * intended to splash
    }
    if (nTouch > 0 && spellsIsTarget(oTarget,SPELL_TARGET_SINGLETARGET,OBJECT_SELF))
    {
        if(nTouch == 2)//critical hit!, double the num dice
        {
            nNumDice *= 2;
        }
        //Roll damage
        while(nNumDice-- > 0)
        {
            nDamage+= Random(nDice)+1;
        }

        //Set damage effect
        effect eDam = EffectDamage(nDamage, nDamageType);
        //Apply the MIRV and damage effect
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
        // * must be the correct racial type (only used with Holy Water)
        if (nRacialType == RACIAL_TYPE_ALL || nRacialType == GetRacialType(oTarget))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
            //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget); VISUALS outrace the grenade, looks bad
        }

    //    ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget);
    }

    if(nSplashDamage < 1)// * Splash damage doesn't happen if the builder do not wish so
    {              //
    return;
    }

    //Set the damage effect
    effect eDam = EffectDamage(nSplashDamage, nDamageType);
    effect eExplode = EffectVisualEffect(vRingHit);

    //Apply the fireball explosion at the location captured above.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fExplosionRadius, lTarget, TRUE, nObjectFilter);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget,SPELL_TARGET_STANDARDHOSTILE,OBJECT_SELF))
        {
            float fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20;
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            if (nRacialType == RACIAL_TYPE_ALL || nRacialType == GetRacialType(oTarget))
            {                                     // * must be the correct racial type (only used with Holy Water)
                // Apply effects to the currently selected target.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                //This visual effect is applied to the target object not the location as above.  This visual effect
                //represents the flame that erupts on the target not on the ground.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, fExplosionRadius, lTarget, TRUE, nObjectFilter);
    }
}
