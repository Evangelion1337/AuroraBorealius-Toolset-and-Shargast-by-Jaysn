//::///////////////////////////////////////////////
//:: Combat Maneuver include: 
//:: prc_inc_combmove
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to the combat maneuvers

    Things:
    Grapple
    Trip
    Bullrush
    Charge
    Overrun
    Disarm

    @author Stratovarius
    @date   Created - 2008.4.20
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int    GRAPPLE_ATTACK          = 1;
const int    GRAPPLE_OPPONENT_WEAPON = 2;
const int    GRAPPLE_ESCAPE          = 3;
const int    GRAPPLE_TOB_CRUSHING    = 4;
const int    GRAPPLE_DAMAGE          = 5;
const int    GRAPPLE_PIN             = 6;

const int    DEBUG_COMBAT_MOVE       = FALSE;

const int    COMBAT_MOVE_GRAPPLE     = 1;
const int    COMBAT_MOVE_BULLRUSH    = 2;
const int    COMBAT_MOVE_OVERRUN     = 3;
const int    COMBAT_MOVE_TRIP        = 4;
const int    COMBAT_MOVE_DISARM      = 5;
const int    COMBAT_MOVE_SHIELD_BASH = 6;

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Returns the total bonus to checks for chosen combat move
 *
 * @param oPC        The PC
 * @param CombatMove The combat move to check
 * @param nDefender  Do the benefits apply when defending only?
 * @param nAttacker  Do the benefits apply when attacking only?
 * @return           Total bonus
 */
int GetCombatMoveCheckBonus(object oPC, int nCombatMove, int nDefender = FALSE, int nAttacker = FALSE);

/**
 * Marks a PC is charging for a round
 *
 * @param oPC      The PC
 */
void SetIsCharging(object oPC);

/**
 * Get whether a PC is charging for a round
 *
 * @param oPC      The PC
 * @return           TRUE or FALSE
 */
int GetIsCharging(object oPC);

/**
 * This will do a complete PnP charge attack
 * Only call EITHER Attack OR Bull Rush
 *
 * @param oPC           The PC
 * @param oTarget       The Target
 * @param nDoAttack     Do an attack at the end of a charge or not
 * @param nGenerateAoO  Does the movement generate an AoO
 * @param nDamage       A damage bonus on the charge
 * @param nDamageType   Damage type of the bonus.
 * @param nBullRush     Do a Bull Rush at the end of a charge
 * @param nExtraBonus   An extra bonus to grant the PC on the Bull rush
 * @param nBullAoO      Does the bull rush attempt generate an AoO
 * @param nMustFollow   Does the Bull rush require the pushing PC to follow the target
 * @param nAttack       Bonus to the attack roll // I forgot to add it before, I'm an idiot ok?
 * @param nPounce       FALSE for normal behaviour, TRUE to do a full attack at the end of a charge // Same comment as above
 *
 * @return              TRUE if the attack or Bull rush hits, else FALSE
 */
void DoCharge(object oPC, object oTarget, int nDoAttack = TRUE, int nGenerateAoO = TRUE, int nDamage = 0, int nDamageType = -1, int nBullRush = FALSE, int nExtraBonus = 0, int nBullAoO = TRUE, int nMustFollow = TRUE, int nAttack = 0, int nPounce = FALSE);

/**
 * This will do a complete PnP Bull rush
 *
 * @param oPC           The PC
 * @param oTarget       The Target
 * @param nExtraBonus   An extra bonus to grant the PC
 * @param nGenerateAoO  Does the Bull rush attempt generate an AoO
 * @param nMustFollow   Does the Bull rush require the pushing PC to follow the target
 * @param nNoMove       PC does not need to move to the target, used for spells
 * @param nAbility      Override the PC's Strength score with something else
 *
 * @return              TRUE if the Bull rush succeeds, else FALSE
 */
void DoBullRush(object oPC, object oTarget, int nExtraBonus, int nGenerateAoO = TRUE, int nMustFollow = TRUE, int nNoMove = FALSE, int nAbility = 0);

/**
 * This will do a complete PnP Trip
 *
 * @param oPC           The PC
 * @param oTarget       The Target
 * @param nExtraBonus   An extra bonus to grant the PC
 * @param nGenerateAoO  Does the Trip attempt generate an AoO
 * @param nCounterTrip  Can the target attempt a counter trip if you fail
 * @param nSkipTouch    Skip the melee touch attack or not
 * @param nAbi          This overrides the PC's ability modifier with the input value
 *
 * @return              TRUE if the Trip succeeds, else FALSE
 *                      It sets a local int known as TripDifference that is the amount you succeeded or failed by.
 */
int DoTrip(object oPC, object oTarget, int nExtraBonus, int nGenerateAoO = TRUE, int nCounterTrip = TRUE, int nSkipTouch = FALSE, int nAbi = 0);

/**
 * Will take an int and transform it into one of the DAMAGE_BONUS constants (From 1 to 50).
 *
 * @param nCheck     Int to convert
 * @return           DAMAGE_BONUS_1 to DAMAGE_BONUS_50
 */
int GetIntToDamage(int nCheck);

/**
 * This will do a complete PnP Grapple
 *
 * @param oPC           The PC
 * @param oTarget       The Target
 * @param nExtraBonus   An extra bonus to grant the PC
 * @param nGenerateAoO  Does the Grapple attempt generate an AoO
 * @param nSkipTouch    Skip the melee touch attack or not
 *
 * @return              TRUE if the Grapple succeeds, else FALSE
 */
int DoGrapple(object oPC, object oTarget, int nExtraBonus, int nGenerateAoO = TRUE, int nSkipTouch = FALSE);

/**
 * Marks a target as grappled.
 *
 * @param oTarget           The Target
 */
void SetGrapple(object oTarget);

/**
 * Returns true or false if the creature is grappled.
 *
 * @param oTarget       Person to check
 *
 * @return              TRUE or FALSE
 */
int GetGrapple(object oTarget);

/**
 * Saves the grapple target for the PC
 *
 * @param oPC               The PC
 * @param oTarget           The Target
 */
void SetGrappleTarget(object oPC, object oTarget);

/**
 * Returns the grapple target for the PC
 *
 * @param oPC               The PC
 */
object GetGrappleTarget(object oPC);

/**
 * Marks a target as pinned.
 *
 * @param oTarget           The Target
 */
void SetIsPinned(object oTarget);

/**
 * Returns true or false if the creature is pinned.
 *
 * @param oTarget       Person to check
 *
 * @return              TRUE or FALSE
 */
int GetIsPinned(object oTarget);

/**
 * Removes the Pinned condition
 *
 * @param oTarget           The Target
 */
void BreakPin(object oTarget);

/**
 * Ends a grapple between the two creatures
 *
 * @param oPC               The PC
 * @param oTarget           The Target
 */
void EndGrapple(object oPC, object oTarget);

/**
 * The options that can be performed during a grapple. Returns success or fail of the grapple check.
 *
 * @param oPC           The PC
 * @param oTarget       The Target
 * @param nExtraBonus   An extra bonus to grant the PC
 * @param nSwitch       The options to use. One of:  GRAPPLE_ATTACK, GRAPPLE_OPPONENT_WEAPON, GRAPPLE_ESCAPE, GRAPPLE_TOB_CRUSHING
 * 
 * To-Do - Add Grapple to Move, add Pin Target, add Pin options
 */
int DoGrappleOptions(object oPC, object oTarget, int nExtraBonus, int nSwitch = -1);

/**
 * Returns true or false if the creature's right hand weapon is light
 *
 * @param oPC           Person to check
 *
 * @return              TRUE or FALSE
 */
int GetIsLightWeapon(object oPC);

/**
 * This will do a complete PnP Overrun. See tob_stdr_bldrrll for an example of how to use.
 * Overrun is part of a move action.
 *
 * @param oPC           The PC
 * @param oTarget       The Target
 * @param nExtraBonus   An extra bonus to grant the PC
 * @param nGenerateAoO  Does the Overrun attempt generate an AoO
 * @param nAvoid        Can the target avoid you
 * @param nCounterTrip  Can the target attempt a counter if you fail
 *
 * @return              TRUE if the Overrun succeeds, else FALSE
 *                      It sets a local int known as OverrunDifference that is the amount you succeeded or failed by.
 */
void DoOverrun(object oPC, object oTarget, location lTarget, int nGenerateAoO = TRUE, int nExtraBonus = 0, int nAvoid = TRUE, int nCounter = TRUE);

/**
 * This will do a complete PnP Disarm
 *
 * @param oPC           The PC
 * @param oTarget       The Target
 * @param nExtraBonus   An extra bonus to grant the PC
 * @param nGenerateAoO  Does the attempt generate an AoO
 * @param nCounter      Can the target attempt a counter disarm if you fail
 *
 * @return              TRUE if the Disarm succeeds, else FALSE
*/
int DoDisarm(object oPC, object oTarget, int nExtraBonus = 0, int nGenerateAoO = TRUE, int nCounter = TRUE);

// * returns the size modifier for grappling
int PRCGetSizeModifier(object oCreature);

/**
 * Does the knockback for the Tiger Blooded Tome of Battle feat.
 * Is here because it uses Bull Rush code.
 *
 * @param oInitiator    Hitter
 * @param oTarget       Guess what
 */
void TigerBlooded(object oInitiator, object oTarget);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_combat"
#include "prc_inc_sp_tch"
#include "prc_feat_const"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _DoBullRushKnockBack(object oTarget, object oPC, float fFeet)
{
            // Calculate how far the creature gets pushed
            float fDistance = FeetToMeters(fFeet);
            // Determine if they hit a wall on the way
            location lPC           = GetLocation(oPC);
            location lTargetOrigin = GetLocation(oTarget);
            vector vAngle          = AngleToVector(GetRelativeAngleBetweenLocations(lPC, lTargetOrigin));
            vector vTargetOrigin   = GetPosition(oTarget);
            vector vTarget         = vTargetOrigin + (vAngle * fDistance);
            if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("Initialized _DoBullRushKnockBack", oPC, FALSE);
            if(!LineOfSightVector(vTargetOrigin, vTarget))
            {
                // Hit a wall, binary search for the wall
                float fEpsilon    = 1.0f;          // Search precision
                float fLowerBound = 0.0f;          // The lower search bound, initialise to 0
                float fUpperBound = fDistance;     // The upper search bound, initialise to the initial distance
                fDistance         = fDistance / 2; // The search position, set to middle of the range
                if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoBullRushKnockBack: If Statement", oPC, FALSE);

                do{
                    // Create test vector for this iteration
                    vTarget = vTargetOrigin + (vAngle * fDistance);
                    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoBullRushKnockBack: DO Loop", oPC, FALSE);
                    // Determine which bound to move.
                    if(LineOfSightVector(vTargetOrigin, vTarget))
                        fLowerBound = fDistance;
                    else
                        fUpperBound = fDistance;

                    // Get the new middle point
                    fDistance = (fUpperBound + fLowerBound) / 2;
                }while(fabs(fUpperBound - fLowerBound) > fEpsilon);
            }

            // Create the final target vector
            vTarget = vTargetOrigin + (vAngle * fDistance);
            if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoBullRushKnockBack: Final Vector", oPC, FALSE);
            // Move the target
            location lTargetDestination = Location(GetArea(oTarget), vTarget, GetFacing(oTarget));
            AssignCommand(oTarget, ClearAllActions(TRUE));
            AssignCommand(oTarget, JumpToLocation(lTargetDestination));
            if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoBullRushKnockBack: Jumped", oPC, FALSE);
}

int _DoGrappleCheck(object oPC, object oTarget, int nExtraBonus, int nSwitch = -1)
{
        // The basic modifiers
        int nPCBAB = GetBaseAttackBonus(oPC);
        int nTargetBAB = GetBaseAttackBonus(oTarget);
        int nPCStr = GetAbilityModifier(ABILITY_STRENGTH, oPC);
        int nTargetStr = GetAbilityModifier(ABILITY_STRENGTH, oTarget);
        int nPCBonus = PRCGetSizeModifier(oPC);
        int nTargetBonus = PRCGetSizeModifier(oTarget);
        // Other ability bonuses
        nPCBonus += GetCombatMoveCheckBonus(oPC, COMBAT_MOVE_GRAPPLE, FALSE, TRUE);
        nTargetBonus += GetCombatMoveCheckBonus(oTarget, COMBAT_MOVE_GRAPPLE, TRUE);
        // Extra bonus
        nPCBonus += nExtraBonus;
        
        if (GetHasFeat(FEAT_IMPROVED_GRAPPLE, oPC)) nPCBonus += 4;
        if (GetHasFeat(FEAT_IMPROVED_GRAPPLE, oTarget)) nTargetBonus += 4;
        nTargetBonus += GetLevelByClass(CLASS_TYPE_SANCTIFIED_MIND, oTarget); //Only applies on defense
        if (nSwitch == GRAPPLE_ESCAPE)
            nPCBonus += GetLevelByClass(CLASS_TYPE_SANCTIFIED_MIND, oPC); // And when escaping

        //cant grapple incorporeal or ethereal things
        if((GetIsEthereal(oTarget) && !GetIsEthereal(oPC))
                || GetIsIncorporeal(oTarget))
        {
                FloatingTextStringOnCreature("You cannot grapple an Ethereal or Incorporeal creature",oPC, FALSE);
                return FALSE;
        }

        int nPCCheck = nPCBAB + nPCStr + nPCBonus + d20();
        int nTargetCheck = nTargetBAB + nTargetStr + nTargetBonus + d20();
        // Now roll the ability check
        SendMessageToPC(oPC, "PC Grapple Check: "+IntToString(nPCCheck)+" vs "+IntToString(nTargetCheck));
        if (GetIsPC(oTarget))
            SendMessageToPC(oTarget, "Enemy Grapple Check: "+IntToString(nPCCheck)+" vs "+IntToString(nTargetCheck));
        if (nPCCheck >= nTargetCheck)
        {
                return TRUE;
        }
        
        // Didn't grapple successfully
        return FALSE;
}

void _DoCurlingWaveStrike(object oPC, object oTarget)
{
    if (GetLocalInt(oPC, "CurlingWaveStrike")) return; // Escape if this has already happened
    location lTarget = GetLocation(oPC);
    int nContinue = TRUE;
    // Use the function to get the closest creature as a target
    object oAreaTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oAreaTarget) && nContinue)
    {
        // All enemies in range get a free AoO shot
        if(oAreaTarget != oPC && // Don't hit yourself
           GetIsInMeleeRange(oPC, oAreaTarget) && // They must be in melee range
           GetIsEnemy(oAreaTarget, oPC) && // Only enemies are valid targets
           oAreaTarget != oTarget) // Can't hit the same guy twice
        {
            // Once we're here, perform the second trip
            DoTrip(oPC, oAreaTarget, 0);
            nContinue = FALSE; // Break the loop
        }

    //Select the next target within the spell shape.
    oAreaTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }
    
    // Stop this being an eternal loop
    SetLocalInt(oPC, "CurlingWaveStrikeLoop", TRUE);
    DelayCommand(0.5, DeleteLocalInt(oPC, "CurlingWaveStrikeLoop"));
    
    // Once a round
    SetLocalInt(oPC, "CurlingWaveStrikeRound", TRUE);
    DelayCommand(6.0, DeleteLocalInt(oPC, "CurlingWaveStrikeRound"));    
}    

// Returns 0 on a fail
// Returns 1 on a successful overrun
// Returns 2 on an avoid
void _DoOverrunCheck(object oPC, object oTarget, location lTarget, int nGenerateAoO = TRUE, int nExtraBonus = 0, int nAvoid = TRUE, int nCounter = TRUE)
{
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoOverrunCheck: Initialized", oPC, FALSE);
    // Stops loops
    if (GetLocalInt(oPC, "Overrun") != 2 && !GetLocalInt(oPC, "BoulderRoll")) return;
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoOverrunCheck: Loop Protect", oPC, FALSE);
    
    if(!nGenerateAoO)
    {
        // Huge bonus to tumble to prevent AoOs from movement
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_TUMBLE, 50), oPC, 6.0);
    }
    // The basic modifiers
    int nSucceed = FALSE;
    int nPCStat, nTargetStat;
    // Use the higher of the two mods
    if (GetAbilityModifier(ABILITY_STRENGTH, oPC) > GetAbilityModifier(ABILITY_DEXTERITY, oPC))
        nPCStat = GetAbilityModifier(ABILITY_STRENGTH, oPC) + GetCombatMoveCheckBonus(oPC, COMBAT_MOVE_OVERRUN, FALSE, TRUE);
    else
        nPCStat = GetAbilityModifier(ABILITY_DEXTERITY, oPC) + GetCombatMoveCheckBonus(oPC, COMBAT_MOVE_OVERRUN, FALSE, TRUE);
    // Use the higher of the two mods       
    if (GetAbilityModifier(ABILITY_STRENGTH, oTarget) > GetAbilityModifier(ABILITY_DEXTERITY, oTarget))
        nTargetStat = GetAbilityModifier(ABILITY_STRENGTH, oTarget) + GetCombatMoveCheckBonus(oTarget, COMBAT_MOVE_OVERRUN, TRUE);
    else
        nTargetStat = GetAbilityModifier(ABILITY_DEXTERITY, oTarget) + GetCombatMoveCheckBonus(oTarget, COMBAT_MOVE_OVERRUN, TRUE);
    // Get mods for size
    int nPCBonus = PRCGetSizeModifier(oPC);
    int nTargetBonus = PRCGetSizeModifier(oTarget);
    //Warblade Battle Skill bonus
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oPC) >= 11) 
    {
        nPCBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
        if (DEBUG_COMBAT_MOVE) DoDebug("Warblade Battle Skill Overrun bonus (attacker)");
    }
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oTarget) >= 11)
    {
        nTargetBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oTarget);
        if (DEBUG_COMBAT_MOVE) DoDebug("Warblade Battle Skill Overrun bonus (defender)");
    }
    if (GetHasFeat(FEAT_IMPROVED_OVERRUN, oPC)) //Can't avoid an overrun now
    {
        nPCBonus += 4;
        nAvoid = FALSE;
    }
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoOverrunCheck: Modifiers Complete", oPC, FALSE);
    // Do the AoO for an overrun attempt
    if (nGenerateAoO)
    {
        // Perform the Attack
        effect eNone;
        DelayCommand(0.0, PerformAttack(oPC, oTarget, eNone, 0.0, 0, 0, 0, "Attack of Opportunity Hit", "Attack of Opportunity Miss"));  
        FloatingTextStringOnCreature(GetName(oTarget)+" Overrun Attack of Opportunity", oPC, FALSE);
    }
    int nPCCheck = nPCStat + nPCBonus + nExtraBonus + d20();
    int nTargetCheck = nTargetStat + nTargetBonus + d20();

    // The target has the option to avoid. Smaller targets will avoid if allowed.
    if (nPCBonus > nTargetBonus && nAvoid)
    {
        FloatingTextStringOnCreature(GetName(oTarget) + " has successfully avoided you", oPC, FALSE);
        // You didn't knock down the target, but neither did it stop you. Keep on chugging.
        SetLocalInt(oPC, "Overrun", 2);
        AssignCommand(oPC, ActionForceMoveToLocation(lTarget, TRUE));
        return;
    }
    // Now roll the ability check
    SendMessageToPC(oPC, "Overrun Check: "+IntToString(nPCCheck)+" vs "+IntToString(nTargetCheck));
    if (nPCCheck >= nTargetCheck)
    {
        FloatingTextStringOnCreature("You have succeeded on your Overrun attempt",oPC, FALSE);
        // Knock em down
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectKnockdown()), oTarget, 6.0);
        nSucceed = TRUE;
        SetLocalInt(oPC, "OverrunDifference", nPCCheck - nTargetCheck);
        DeleteLocalInt(oPC, "OverrunDifference");
        effect eNone;
        if (GetHasFeat(FEAT_CENTAUR_TRAMPLE, oPC)) PerformAttack(oPC, oTarget, eNone, 0.0, 0, 0, 0, "Centaur Trample Hit", "Centaur Trample Miss", FALSE, GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oPC));
        AssignCommand(oPC, ActionForceMoveToLocation(lTarget, TRUE));
        DelayCommand(7.05, AssignCommand(oTarget, ClearAllActions(TRUE)));
        DelayCommand(7.05, AssignCommand(oTarget, ActionAttack(oPC)));
        if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoOverrunCheck: oTarget Assign Command "+GetName(oTarget), oPC, FALSE);
    }
    else // If you fail, enemy gets a counter Overrun attempt, using Strength
    {
        nTargetStat = GetAbilityModifier(ABILITY_STRENGTH, oTarget) + GetCombatMoveCheckBonus(oTarget, COMBAT_MOVE_OVERRUN, FALSE, TRUE);
        FloatingTextStringOnCreature("You have failed on your Overrun attempt",oPC, FALSE);
        AssignCommand(oPC, ClearAllActions(TRUE));
        AssignCommand(oPC, JumpToLocation(GetLocation(oTarget)));
        // Roll counter Overrun attempt
        nTargetCheck = nTargetStat + nTargetBonus + d20();
        nPCCheck = nPCStat + nPCBonus + d20();
        // If counters aren't allowed, don't knock em down
        // Its down here to allow the text message to go through
        SendMessageToPC(oPC, "Enemy Overrun Counter Check: "+IntToString(nPCCheck)+" vs "+IntToString(nTargetCheck));
        if (nTargetCheck >= nPCCheck && nCounter)
        {
            // Knock em down
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectKnockdown()), oPC, 6.0);
        }
        SetLocalInt(oPC, "OverrunDifference", nTargetCheck - nPCCheck);
        DelayCommand(2.0, DeleteLocalInt(oPC, "OverrunDifference"));
    }
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("_DoOverrunCheck: Ending, nSucceed "+IntToString(nSucceed), oPC, FALSE);
    SetLocalInt(oPC, "Overrun", nSucceed);
}

int _ChargeDamage(object oPC)
{
    int nDam;
    int nSize = PRCGetSizeModifier(oPC);
    
    if (GetHasFeat(FEAT_GREATER_POWERFUL_CHARGE, oPC)) nSize += 4;
    
    if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 0) nDam += d8();
    else if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 4) nDam += d6(2);
    else if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 8) nDam += d6(3);
    else if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 12) nDam += d6(4);
    else if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 16) nDam += d6(6);
    
    if (GetHasFeat(FEAT_RHINO_TRIBE_CHARGE, oPC)) nDam += d6(2);
    // Using a natural attack only
    if (GetHasSpellEffect(VESTIGE_AMON, oPC) && GetLocalInt(oPC, "AmonRam") && !GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC))) nDam += d8();
    
    nDam += GetEssentiaInvestedFeat(oPC, FEAT_COBALT_CHARGE);
    
    // Doesn't appear to be added to charging normally, so brute forcing it here
    nDam += GetEssentiaInvested(oPC, MELD_INCANDESCENT_STRIKE);
    
    return nDam;
}

int _ChargeAttack(object oPC, object oTarget, int nAtk)
{
    nAtk    += 2; // Add to whatever the bonus was before
    int nAC  = 2;
    
    if(GetHasFeat(FEAT_FURIOUS_CHARGE, oPC)) nAtk += 2;
    if(GetHasFeat(FEAT_RECKLESS_CHARGE, oPC))
    {
        nAtk += 2;
        nAC  += 2;
    }
    if(GetHasFeat(FEAT_GREAT_STAG_BERSERKER, oPC)) // Yes, it's the same feat as Reckless Charge
    {
        nAtk += 2;
        nAC  += 2;
    }    
    if(GetHasFeat(FEAT_SIDESTEP_CHARGE, oTarget)) nAtk -= 4;
    if(GetLevelByClass(CLASS_TYPE_WARFORGED_JUGGERNAUT, oPC) >= 2) nAtk += 1;
    if(GetLevelByClass(CLASS_TYPE_WARFORGED_JUGGERNAUT, oPC) >= 4) nAtk += 1;
    
    effect eCharge = EffectLinkEffects(EffectACDecrease(nAC), EffectMovementSpeedIncrease(99));
    eCharge = ExtraordinaryEffect(eCharge);
    SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCharge, oPC, 6.0);
    
    nAtk += GetEssentiaInvestedFeat(oPC, FEAT_COBALT_CHARGE);
    
    // Done this way because otherwise the attack bonus isn't used properly
    return nAtk;
}

void _SuperiorBullRush(object oPC, object oTarget)
{
    int nDam = d6();
    if(GetLevelByClass(CLASS_TYPE_WARFORGED_JUGGERNAUT, oPC) >= 4) nDam = d8();    
    nDam += GetAbilityModifier(ABILITY_STRENGTH, oPC);
    
    if (GetIsCharging(oPC))
    {
        int nSize = PRCGetSizeModifier(oPC);
    
        if (GetHasFeat(FEAT_GREATER_POWERFUL_CHARGE, oPC)) nSize += 4;
    
        if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 0) nDam += d8();
        else if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 4) nDam += d6(2);
        else if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 8) nDam += d6(3);
        else if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 12) nDam += d6(4);
        else if(GetHasFeat(FEAT_POWERFUL_CHARGE, oPC) && nSize == 16) nDam += d6(6);    
    } 
    
    effect eDeath = EffectDamage(nDam, DAMAGE_TYPE_PIERCING);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget);
    FloatingTextStringOnCreature("Superior Bull Rush Hit", oPC, FALSE);
}

void _DoBullrushCheck(object oPC, object oTarget, int nExtraBonus, int nMustFollow = TRUE, int nAbility = 0)
{
    // The basic modifiers
    int nPCStr = GetAbilityModifier(ABILITY_STRENGTH, oPC);
    int nTargetStr = GetAbilityModifier(ABILITY_STRENGTH, oTarget);
    if (nAbility > 0) nPCStr = nAbility; // Use the override if it exists
    int nPCBonus = PRCGetSizeModifier(oPC);
    int nTargetBonus = PRCGetSizeModifier(oTarget);
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullRush: Initialized", oPC, FALSE);
    //Warblade Battle Skill bonus
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oPC) >= 11) 
    {
        nPCBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
        if (DEBUG_COMBAT_MOVE) DoDebug("Warblade Battle Skill Bull Rush bonus (attacker)");
    }
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oTarget) >= 11)
    {
        nTargetBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oTarget);
        if (DEBUG_COMBAT_MOVE) DoDebug("Warblade Battle Skill Bull Rush bonus (defender)");
    }
    if (GetHasFeat(FEAT_IMPROVED_BULLRUSH, oPC)) nPCBonus += 4;
    effect eNone;
    // Get a +2 bonus for charging during a bullrush
    if (GetIsCharging(oPC)) nPCBonus += 2;
    // Other ability bonuses
    nPCBonus += GetCombatMoveCheckBonus(oPC, COMBAT_MOVE_BULLRUSH, FALSE, TRUE);
    nTargetBonus += GetCombatMoveCheckBonus(oPC, COMBAT_MOVE_BULLRUSH, TRUE);
    // Extra bonus
    nPCBonus += nExtraBonus;
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullRush: End of Bonuses", oPC, FALSE);
    
    if (GetLocalInt(oPC, "SlingDireWind_BullRush")) //Special roll
    {
        nPCStr = 15;
        nPCBonus = 0;
        nMustFollow = FALSE;
    }
    else if (GetLocalInt(oPC, "RonoveBullRush")) //Special roll
    {
        nPCStr = GetLocalInt(oPC, "RonoveBullRush");
        nPCBonus = 0;
        nMustFollow = FALSE;
    }    
    
    // Ability check
    int nPCCheck = nPCStr + nPCBonus + d20();
    int nTargetCheck = nTargetStr + nTargetBonus + d20();
    SendMessageToPC(oPC, "Bull Rush Check: "+IntToString(nPCCheck)+" vs "+IntToString(nTargetCheck));    
    
    // Now roll the ability check
    if (nPCCheck >= nTargetCheck)
    {
        if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullRush: Successful Hit", oPC, FALSE);
        // Knock them back 5 feet
        float fFeet = 5.0;
        // For every 5 points greater, knock back an additional 5 feet.
        fFeet += 5.0 * ((nPCCheck - nTargetCheck) / 5);
        // This weapon of legacy adds 5 feet to a successful bull rush
        if(GetLocalInt(oPC, "Caladbolg_Bullrush")) fFeet += 5.0;
        // Max pushback from this one is 5.0
        if (GetLocalInt(oPC, "SlingDireWind_BullRush")) fFeet = 5.0;
        SetLocalInt(oPC, "Bullrush", TRUE);
        DelayCommand(3.0, DeleteLocalInt(oPC, "Bullrush"));
        // Shedu Crown negates the knockback
        if (GetHasSpellEffect(18767, oTarget)) fFeet = 0.0;
        _DoBullRushKnockBack(oTarget, oPC, fFeet);
        if(GetLevelByClass(CLASS_TYPE_WARFORGED_JUGGERNAUT, oPC)) _SuperiorBullRush(oPC, oTarget);
        // If the PC has to keep pushing to knock back, move the PC along
        if (nMustFollow)
        {
            if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullRush: Following", oPC, FALSE);
            AssignCommand(oPC, ClearAllActions(TRUE));
            AssignCommand(oPC, JumpToLocation(GetLocation(oTarget)));
        }
        if(GetHasFeat(FEAT_RAMPAGING_BULL_RUSH, oPC) && GetHasSpellEffect(SPELLABILITY_BARBARIAN_RAGE, oPC))
        	DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oTarget, RoundsToSeconds(1)));
    }
    else
        FloatingTextStringOnCreature("You have failed your Bull Rush Attempt",oPC, FALSE);

    // Let people know if we made the hit or not
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullRush: Exit", oPC, FALSE);
}

int _CountPinRounds(object oTarget)
{
    int nPin = GetLocalInt(oTarget, "PinnedRounds");
    SetLocalInt(oTarget, "PinnedRounds", nPin+1); 
    
    return nPin+1;
}

void _DoReapingMauler(object oPC, object oTarget, int nRounds)
{
    int nClass = GetLevelByClass(CLASS_TYPE_REAPING_MAULER, oPC);
    if (3 > nClass) return;

    if (!GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT))
    {
        if (nRounds >= 3 && nClass >= 5) // Devastating Grapple
        {
            int nDC = 15 + GetAbilityModifier(ABILITY_WISDOM, oPC);
            if(!FortitudeSave(oTarget, nDC, SAVING_THROW_TYPE_NONE, oPC))
            {
                FloatingTextStringOnCreature("Devastating Grapple Success", oPC, FALSE);
                effect eDeath = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget);
            }  
        }    
        else
        {
            int nDC = 10 + nClass + GetAbilityModifier(ABILITY_WISDOM, oPC);
            if(!FortitudeSave(oTarget, nDC, SAVING_THROW_TYPE_NONE, oPC))
            {            
                SetLocalInt(oTarget, "UnconsciousGrapple", TRUE);
                // Unconscious effects
                effect eUncon = EffectLinkEffects(EffectStunned(), EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED));
                eUncon = EffectLinkEffects(eUncon, EffectKnockdown());
                float fDur = d3() * 6.0;
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eUncon), oTarget, fDur);
                FloatingTextStringOnCreature("Sleeper Lock Success", oPC, FALSE);
                DelayCommand(fDur, DeleteLocalInt(oTarget, "UnconsciousGrapple"));
            }    
        }    
    }  
}
 
void _DoChokeHold(object oPC, object oTarget)  
{  
    // Size immunity: more than one size larger blocks effect  
    int nAttackerSize = GetCreatureSize(oPC);  
    int nTargetSize   = GetCreatureSize(oTarget);  
    if (nTargetSize > nAttackerSize + 1) return;  
  
    // Stunning immunity blocks Choke Hold  
    if (GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT)) return;  
  
    int nDC = 10 + (GetHitDice(oPC) / 2) + GetAbilityModifier(ABILITY_WISDOM, oPC);  
    if (!FortitudeSave(oTarget, nDC, SAVING_THROW_TYPE_NONE, oPC))  
    {  
        SetLocalInt(oTarget, "UnconsciousGrapple", TRUE);  
		effect eUncon = EffectLinkEffects(EffectSleep(), EffectVisualEffect(VFX_IMP_SLEEP)); 
		eUncon = EffectLinkEffects(eUncon, EffectKnockdown());
        float fDur = RoundsToSeconds(d3());  
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eUncon), oTarget, fDur);  
        FloatingTextStringOnCreature("Choke Hold Success", oPC, FALSE);  
        DelayCommand(fDur, DeleteLocalInt(oTarget, "UnconsciousGrapple"));  
  
        // End the grapple after knocking the target out  
        EndGrapple(oPC, oTarget);  
        if (GetLocalInt(oPC, "GrappleOriginator"))  
            RemoveEventScript(oPC, EVENT_ONHEARTBEAT, "prc_grapple", TRUE, FALSE);  
    }  
}

void _PostCharge(object oPC, object oTarget) 
{
    int nSpellId = PRCGetSpellId();
    if (DEBUG) DoDebug("_PostCharge nSpellId: "+IntToString(nSpellId));
    effect eNone;
    int nSucceed = GetLocalInt(oTarget, "PRCCombat_StruckByAttack");
    if(GetHasFeat(FEAT_SIDESTEP_CHARGE, oTarget) && nSucceed == FALSE)
        DelayCommand(0.0, PerformAttack(oPC, oTarget, eNone, 0.0, 0, 0, -1, "Sidestep Charge Hit", "Sidestep Charge Miss"));
        
    //Gorebrute Elite Knockdown
    if(GetLocalInt(oPC, "ShifterGore") && GetHasFeat(FEAT_GOREBRUTE_ELITE, oPC) && nSucceed)
    {
        //Knockdown check
        int nEnemyStr = d20() + GetAbilityModifier(ABILITY_STRENGTH, oTarget);
        int nYourStr = d20() + GetAbilityModifier(ABILITY_STRENGTH, oPC);
        SendMessageToPC(oPC, "Opposed Knockdown Check: Rolled " + IntToString(nYourStr) + " vs " + IntToString(nEnemyStr));
        SendMessageToPC(oTarget, "Opposed Knockdown Check: Rolled " + IntToString(nEnemyStr) + " vs " + IntToString(nYourStr));
        if(nYourStr > nEnemyStr) 
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oTarget, 6.0);
    }        
        
    if (nSpellId == MOVE_DS_DOOM_CHARGE && nSucceed)
    {
        effect eLink = EffectVisualEffect(VFX_DUR_ROOTED_TO_SPOT);
        eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_BLUDGEONING, 10));
        eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_PIERCING,    10));
        eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_SLASHING,    10));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, 6.0);    
    }
    else if (nSpellId == MOVE_DS_LAW_BEARER && nSucceed)
    {
        effect eLink = EffectVisualEffect(VFX_DUR_ROOTED_TO_SPOT);
        eLink = EffectLinkEffects(eLink, EffectACIncrease(5));
        eLink = EffectLinkEffects(eLink, EffectSavingThrowIncrease(SAVING_THROW_ALL, 5));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, 6.0);  
    }  
    else if (nSpellId == MOVE_DS_RADIANT_CHARGE && nSucceed)
    {
        effect eLink = EffectVisualEffect(VFX_DUR_ROOTED_TO_SPOT);
        eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_BLUDGEONING, 10));
        eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_PIERCING,    10));
        eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_SLASHING,    10));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, 6.0);    
    }   
    else if (nSpellId == MOVE_DS_TIDE_CHAOS && nSucceed)
    {
        effect eLink = EffectLinkEffects(EffectVisualEffect(VFX_DUR_BLUR), EffectConcealment(50));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, 6.0);   
    }   
    else if (nSpellId == MOVE_WR_WAR_MASTERS_CHARGE && nSucceed)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectStunned()), oTarget, 6.0);   
    }
	
    // Applies to all charges, Thunderstep Boots meld  
    if (GetHasSpellEffect(MELD_THUNDERSTEP_BOOTS, oPC) && nSucceed)  
    {  
    	int nDice = GetEssentiaInvested(oPC, MELD_THUNDERSTEP_BOOTS) + 1;  
        ApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDamage(d4(nDice), DAMAGE_TYPE_SONIC)), oTarget);     
    	// Check Feet bind (regular or double)  
    	int nBoundToFeet = FALSE;  
    	if (GetIsMeldBound(oTarget, MELD_THUNDERSTEP_BOOTS) == CHAKRA_FEET ||  
    	    GetIsMeldBound(oTarget, MELD_THUNDERSTEP_BOOTS) == CHAKRA_DOUBLE_FEET)  
    	    nBoundToFeet = TRUE;  
    	  
    	if (nBoundToFeet)  
    	{  
    		int nDC = GetMeldshaperDC(oPC, CLASS_TYPE_SOULBORN, MELD_THUNDERSTEP_BOOTS);  
			if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NONE))  
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectStunned(), oTarget, 6.0);  
    	}          
    }
	
/*   if (GetHasSpellEffect(MELD_THUNDERSTEP_BOOTS, oPC) && nSucceed)
    {
    	int nDice = GetEssentiaInvested(oPC, MELD_STRONGHEART_VEST) + 1;
        ApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDamage(d4(nDice), DAMAGE_TYPE_SONIC)), oTarget);   
    	if (GetIsMeldBound(oTarget, MELD_THUNDERSTEP_BOOTS) == CHAKRA_FEET)
    	{
    		int nDC = GetMeldshaperDC(oPC, CLASS_TYPE_SOULBORN, MELD_STRONGHEART_VEST);
			if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NONE))
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectStunned(), oTarget, 6.0);
    	}        
    }  */
    // Applies to all charges, Urskan Greaves meld
    if (GetHasSpellEffect(MELD_URSKAN_GREAVES, oPC) && nSucceed)
    {
    	int nDice = GetEssentiaInvested(oPC, MELD_URSKAN_GREAVES);  
    	if (GetIsMeldBound(oTarget, MELD_URSKAN_GREAVES) == CHAKRA_FEET || GetIsMeldBound(oTarget, MELD_URSKAN_GREAVES) == CHAKRA_DOUBLE_FEET)
        	ApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDamage(d4(nDice), DAMAGE_TYPE_BLUDGEONING)), oTarget);        
    }     
} 

void _DoTrampleDamage(object oPC, object oTarget)
{
	int nPCSize = PRCGetSizeModifier(oPC);
	int nTargetSize = PRCGetSizeModifier(oTarget);
	
	// Have to be equal to your size or smaller
	if (nPCSize >= nTargetSize)
	{
		int nDamage = d8();
		if (nPCSize == 4) nDamage = d6(2); // Large
		else if (nPCSize == -4) nDamage = d6(); // Small	
		int nDC = GetMeldshaperDC(oPC, CLASS_TYPE_SOULBORN, PRCGetSpellId());
		
		nDamage += FloatToInt(GetAbilityModifier(ABILITY_STRENGTH, oPC) * 1.5);
		nDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_TYPE_NONE);
		if (nDamage > 0)
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING), oTarget);
	}
}

void _HeartOfFireGrapple(object oPC, object oTarget)
{  
    if (GetIsMeldBound(oTarget, MELD_HEART_OF_FIRE) == CHAKRA_WAIST || GetIsMeldBound(oTarget, MELD_HEART_OF_FIRE) == CHAKRA_DOUBLE_WAIST)
    {
    	int nEssentia = GetEssentiaInvested(oPC, MELD_HEART_OF_FIRE);
    	ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(nEssentia), DAMAGE_TYPE_FIRE), oTarget);
    }
}

int _TotemAvatar(object oPC, int nCombatMove)
{
	int nReturn;
      	
    if (GetIsMeldBound(oPC, MELD_HEART_OF_FIRE) == CHAKRA_FEET || GetIsMeldBound(oPC, MELD_HEART_OF_FIRE) == CHAKRA_DOUBLE_FEET && nCombatMove != COMBAT_MOVE_GRAPPLE)
		nReturn = 4;
    
    if (nCombatMove == COMBAT_MOVE_GRAPPLE ||
        nCombatMove == COMBAT_MOVE_BULLRUSH ||
        nCombatMove == COMBAT_MOVE_OVERRUN ||
        nCombatMove == COMBAT_MOVE_TRIP)
        nReturn += 4;
    
    return nReturn;
}

int _UrskanGreaves(object oPC)
{
	int nReturn;
	
    if (GetIsMeldBound(oPC, MELD_URSKAN_GREAVES) == CHAKRA_TOTEM || GetIsMeldBound(oPC, MELD_URSKAN_GREAVES) == CHAKRA_DOUBLE_TOTEM)
		nReturn = 2 + GetEssentiaInvested(oPC, MELD_URSKAN_GREAVES);
    
    return nReturn;
}

void _ShieldBashDamage(object oPC, object oTarget, int nRoll, int nHand, int nDamage, int nDamageType, int nType)
{				
	int nDam = d3();
	if (nType == BASE_ITEM_LARGESHIELD) nDam = d4();
	int nStr = GetAbilityModifier(ABILITY_STRENGTH, oPC)/2;	// Default to offhand
	if (nHand) nStr = GetAbilityModifier(ABILITY_STRENGTH, oPC); // Onhand attack
	int nBash = GetLocalInt(oPC, "BashingEnchant");
	if (nBash && nType == BASE_ITEM_LARGESHIELD) nDam = d8();
	else if (nBash && nType == BASE_ITEM_SMALLSHIELD) nDam = d6();
	
	nDam += nStr;	
	nDam += nBash;	
	// Critical hit
	if (nRoll == 2)
	{
		if (nType == BASE_ITEM_LARGESHIELD) nDam += d4();
		else                                nDam += d3();
		nDam += nStr;
		nDam += nBash;	
		nDamage *= 2;
	}
	effect eLink = EffectDamage(nDam, DAMAGE_TYPE_BLUDGEONING);
	if (nDamage) eLink = EffectLinkEffects(eLink, EffectDamage(nDamage, nDamageType));
	ApplyEffectToObject(DURATION_TYPE_INSTANT, ExtraordinaryEffect(eLink), oTarget);
	
	//Extra damage from Energized Shield and Lesser Energized Shield
	int nType = GetLocalInt(oPC, "EnShieldType");
	int nD6 = GetLocalInt(oPC, "EnShieldD6");
	SPApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nType, d6(nD6)), oTarget);	
}

void _BariaurChargeDamage(object oPC, object oTarget, int nRoll, int nDamBonus)
{				
	int nDam = d6(2) + GetAbilityModifier(ABILITY_STRENGTH, oPC) + nDamBonus; // Onhand attack
	if (nRoll == 2) nDam += d6(2) + GetAbilityModifier(ABILITY_STRENGTH, oPC) + nDamBonus; 
	
	ApplyEffectToObject(DURATION_TYPE_INSTANT, ExtraordinaryEffect(EffectDamage(nDam, DAMAGE_TYPE_BLUDGEONING)), oTarget);
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetCombatMoveCheckBonus(object oPC, int nCombatMove, int nDefender = FALSE, int nAttacker = FALSE)
{
    int nBonus = 0;
    if(nCombatMove == COMBAT_MOVE_GRAPPLE)
    {
        if(GetHasSpellEffect(MOVE_SD_STONEFOOT_STANCE, oPC)) nBonus += 2;
        if(GetLevelByClass(CLASS_TYPE_REAPING_MAULER, oPC) >= 2) nBonus += 1;
        if(GetLevelByClass(CLASS_TYPE_REAPING_MAULER, oPC) >= 4) nBonus += 1;
        if(GetHasFeat(FEAT_LEGENDARY_WRESTLER, oPC)) nBonus += 10;
        if(GetRacialType(oPC) == RACIAL_TYPE_CHITINE) nBonus += 4;
        if(GetHasSpellEffect(MELD_GIRALLON_ARMS, oPC)) nBonus += (2 + GetEssentiaInvested(oPC, MELD_GIRALLON_ARMS)); // MELD_GIRALLON_ARMS
        if(GetLocalInt(oPC, "BullybashersGrapple")) nBonus += 4;
        if(GetLocalInt(oPC, "BullybashersGiant")) nBonus += 4;
        if(GetHasFeat(FEAT_OPEN_LESSER_CHAKRA_ARMS, oPC)) nBonus += 2;
        if(GetHasFeat(FEAT_ABERRANT_DEEPSPAWN, oPC)) nBonus += 2;
        if(GetHasFeat(FEAT_ABERRANT_LIMBS, oPC)) nBonus += 2;
        if(GetHasSpellEffect(POWER_GRIP_IRON, oPC)) nBonus += GetLocalInt(oPC, "Psi_GripOfIron");
    }
    else if(nCombatMove == COMBAT_MOVE_BULLRUSH)
    {
        if(GetHasSpellEffect(MOVE_SD_STONEFOOT_STANCE, oPC)) nBonus += 2;
        if(GetHasSpellEffect(MOVE_SS_STEP_WIND,        oPC)) nBonus += 4;
        if(GetLevelByClass(CLASS_TYPE_WARFORGED_JUGGERNAUT, oPC)) nBonus += GetAbilityModifier(ABILITY_STRENGTH, oPC);
        if(GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC) >= 3) nBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
        if(GetLocalInt(oPC, "LuckyDiceAbility")) nBonus += 1;
        if(GetHasSpellEffect(MELD_MAULING_GAUNTLETS, oPC)) nBonus += (2 + (2 * GetEssentiaInvested(oPC, MELD_MAULING_GAUNTLETS))); // MELD_MAULING_GAUNTLETS
        if(GetHasSpellEffect(MELD_SPHINX_CLAWS, oPC)) nBonus += (1 + GetEssentiaInvested(oPC, MELD_SPHINX_CLAWS)); // MELD_SPHINX_CLAWS
        if(GetLocalInt(oPC, "EventideCrux")) nBonus += 4;
    }
    else if(nCombatMove == COMBAT_MOVE_OVERRUN)
    {
        if(GetHasSpellEffect(MOVE_SD_STONEFOOT_STANCE, oPC)) nBonus += 2;
        if(GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC) >= 3) nBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
        if(GetLocalInt(oPC, "LuckyDiceAbility")) nBonus += 1;
        if(GetHasSpellEffect(MELD_MAULING_GAUNTLETS, oPC)) nBonus += (2 + (2 * GetEssentiaInvested(oPC, MELD_MAULING_GAUNTLETS))); // MELD_MAULING_GAUNTLETS
        if(GetHasSpellEffect(MELD_SPHINX_CLAWS, oPC)) nBonus += (1 + GetEssentiaInvested(oPC, MELD_SPHINX_CLAWS)); // MELD_SPHINX_CLAWS
        if(GetLocalInt(oPC, "EventideCrux")) nBonus += 4;
    }
    else if(nCombatMove == COMBAT_MOVE_TRIP)
    {
        if(GetHasSpellEffect(MOVE_SD_STONEFOOT_STANCE, oPC)) nBonus += 2;
        if(GetHasSpellEffect(MOVE_SS_STEP_WIND,        oPC)) nBonus += 4;
        if(GetHasFeat(FEAT_WOLF_BERSERKER, oPC)) nBonus += 4;
        if(GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC) >= 3) nBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
        if(GetLocalInt(oPC, "LuckyDiceAbility")) nBonus += 1;
        if(GetHasSpellEffect(MELD_MAULING_GAUNTLETS, oPC)) nBonus += (2 + (2 * GetEssentiaInvested(oPC, MELD_MAULING_GAUNTLETS))); // MELD_MAULING_GAUNTLETS
        if(GetHasSpellEffect(MELD_SPHINX_CLAWS, oPC)) nBonus += (1 + GetEssentiaInvested(oPC, MELD_SPHINX_CLAWS)); // MELD_SPHINX_CLAWS
        if(GetLocalInt(oPC, "EventideCrux")) nBonus += 4;
    }  
    else if(nCombatMove == COMBAT_MOVE_DISARM)
    {
    	if(GetHasSpellEffect(MELD_BLADEMELD_CROWN, oPC)) nBonus += 4;
    }
    
    if (nAttacker)
    {
        if(nCombatMove == COMBAT_MOVE_GRAPPLE)
        {
            if(GetLocalInt(oPC, "Flay_Grapple")) nBonus += 4;
        }
        else if(nCombatMove == COMBAT_MOVE_BULLRUSH)
        {
            if(GetLocalInt(oPC, "Caladbolg_Bullrush")) nBonus += 4;  
            if (GetLocalInt(oPC, "Marshal_ArtWar")) nBonus += GetLocalInt(oPC, "Marshal_ArtWar");
            if (GetEssentiaInvestedFeat(oPC, FEAT_COBALT_POWER)) nBonus += GetEssentiaInvestedFeat(oPC, FEAT_COBALT_POWER);
        	if(GetHasFeat(FEAT_RAMPAGING_BULL_RUSH, oPC) && GetHasSpellEffect(SPELLABILITY_BARBARIAN_RAGE, oPC)) nBonus -= 4; // Yes, minus is correct           
        }  
        else if(nCombatMove == COMBAT_MOVE_OVERRUN)
        {
            nBonus += _UrskanGreaves(oPC);
            if (GetEssentiaInvestedFeat(oPC, FEAT_COBALT_POWER)) nBonus += GetEssentiaInvestedFeat(oPC, FEAT_COBALT_POWER);
        } 
        else if(nCombatMove == COMBAT_MOVE_TRIP)
        {
        	if (GetEssentiaInvestedFeat(oPC, FEAT_COBALT_EXPERTISE)) nBonus += GetEssentiaInvestedFeat(oPC, FEAT_COBALT_EXPERTISE);
        	if (GetLocalInt(oPC, "Marshal_ArtWar")) nBonus += GetLocalInt(oPC, "Marshal_ArtWar");
        }        
        else if(nCombatMove == COMBAT_MOVE_DISARM)
        {
            if(GetLocalInt(oPC, "Caladbolg_Disarm")) nBonus += 4;    
            if (GetLocalInt(oPC, "Marshal_ArtWar")) nBonus += GetLocalInt(oPC, "Marshal_ArtWar");
            if (GetEssentiaInvestedFeat(oPC, FEAT_COBALT_EXPERTISE)) nBonus += GetEssentiaInvestedFeat(oPC, FEAT_COBALT_EXPERTISE);
            int IsDisarmWeap = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC));
            if (IsDisarmWeap == BASE_ITEM_HEAVYFLAIL || IsDisarmWeap == BASE_ITEM_LIGHTFLAIL || IsDisarmWeap == BASE_ITEM_DIREMACE || IsDisarmWeap == BASE_ITEM_WHIP || IsDisarmWeap == BASE_ITEM_NUNCHAKU) nBonus += 2;  
            if (GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC)) == BASE_ITEM_SAI) nBonus += 4;
        }         
    }    
    else if (nDefender)
    {
		if(GetHasFeat(FEAT_MOUNTAIN_STANCE, oPC)) nBonus += 2;
		
		int nStabBonus = GetLocalInt(oPC, "CombatStability_Bonus");  
        if (nStabBonus > 0) nBonus += nStabBonus;  
		
        if(GetHasSpellEffect(SPELL_UNMOVABLE, oPC)) nBonus += 20;
        if(GetHasFeat(FEAT_SHIELD_WARD, oPC)) 
        {
    		int nBase = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC));
    		if (nBase == BASE_ITEM_SMALLSHIELD || nBase == BASE_ITEM_LARGESHIELD || nBase == BASE_ITEM_TOWERSHIELD)        
    			nBonus += GetItemACValue(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC));
        }		
        
        if(nCombatMove == COMBAT_MOVE_GRAPPLE)
        {
            if(GetHasSpellEffect(MOVE_SD_ROOT_MOUNTAIN, oPC)) nBonus += 10;
            nBonus += _TotemAvatar(oPC, nCombatMove);
            if(GetHasSpellEffect(MELD_BLADEMELD_WAIST, oPC)) nBonus += 4;
        }
        else if(nCombatMove == COMBAT_MOVE_BULLRUSH)
        {
            if(GetLocalInt(oPC, "Steadfast_Rooted")) nBonus += 4;       
            if(GetHasSpellEffect(MOVE_SD_ROOT_MOUNTAIN,    oPC)) nBonus += 10;
            if(GetHasSpellEffect(MELD_BEHIR_GORGET, oPC)) nBonus += 4; // MELD_BEHIR_GORGET
            if(GetHasSpellEffect(MELD_GORGON_MASK, oPC)) nBonus += (2 + GetEssentiaInvested(oPC, MELD_GORGON_MASK)); // MELD_GORGON_MASK
            nBonus += _TotemAvatar(oPC, nCombatMove);
            if(GetHasSpellEffect(MELD_BLADEMELD_WAIST, oPC)) nBonus += 4;
            if(GetRacialType(oPC) == RACIAL_TYPE_BARIAUR) nBonus += 4;
            if(GetRacialType(oPC) == RACIAL_TYPE_WILDREN) nBonus += 4;
        }
        else if(nCombatMove == COMBAT_MOVE_OVERRUN)
        {
            if(GetHasSpellEffect(MOVE_SD_ROOT_MOUNTAIN,    oPC)) nBonus += 10;
            if(GetHasSpellEffect(MELD_GORGON_MASK, oPC)) nBonus += (2 + GetEssentiaInvested(oPC, MELD_GORGON_MASK)); // MELD_GORGON_MASK
            nBonus += _TotemAvatar(oPC, nCombatMove);
            if(GetHasSpellEffect(MELD_BLADEMELD_WAIST, oPC)) nBonus += 4;
        }
        else if(nCombatMove == COMBAT_MOVE_TRIP)
        {
            if(GetLocalInt(oPC, "Steadfast_Rooted")) nBonus += 4;               
            if(GetHasSpellEffect(MOVE_SD_ROOT_MOUNTAIN,    oPC)) nBonus += 10;
            if(GetHasSpellEffect(MELD_BEHIR_GORGET, oPC)) nBonus += 4; // MELD_BEHIR_GORGET
            if(GetHasSpellEffect(MELD_GORGON_MASK, oPC)) nBonus += (2 + GetEssentiaInvested(oPC, MELD_GORGON_MASK)); // MELD_GORGON_MASK
            nBonus += _TotemAvatar(oPC, nCombatMove);
            if(GetHasSpellEffect(MELD_BLADEMELD_WAIST, oPC)) nBonus += 4;
            if(GetRacialType(oPC) == RACIAL_TYPE_BARIAUR) nBonus += 4;
            if(GetRacialType(oPC) == RACIAL_TYPE_WILDREN) nBonus += 4;
        }   
        else if(nCombatMove == COMBAT_MOVE_DISARM)
        {
            if(GetRacialType(oPC) == RACIAL_TYPE_CHITINE) nBonus += 4;
        }        
    }
    if(DEBUG) DoDebug("GetCombatMoveCheckBonus: nBonus " + IntToString(nBonus));
    return nBonus;
}

void SetIsCharging(object oPC)
{
    SetLocalInt(oPC, "PCIsCharging", TRUE);
    // You count as having charged for the entire round
    DelayCommand(6.0, DeleteLocalInt(oPC, "PCIsCharging"));
}

int GetIsCharging(object oPC)
{
    return GetLocalInt(oPC, "PCIsCharging");
}

/** 
 * @brief Initiates a charge action by the player character (PC) toward a target.
 *
 * This function handles movement, potential attack resolution, damage calculations,
 * bull rush attempts, and special feat/ability conditions such as Pounce or Flying Kick.
 *
 * @param oPC The creature performing the charge (usually the player character).
 
 * @param oTarget The target of the charge.
 
 * @param nDoAttack If TRUE (default), the PC will perform an attack after charging.
 
 * @param nGenerateAoO If TRUE (default), movement may provoke attacks of opportunity (AoOs).
 *                     If FALSE, a high temporary Tumble bonus is applied to prevent AoOs.
 
 * @param nDamage Initial base damage to apply on a successful hit. Modified by feats or abilities.
 
 * @param nDamageType The type of damage to apply. Set to -1 (default) to use weapon damage type.
 
 * @param nBullRush If TRUE, attempt to initiate a Bull Rush after the attack.
 
 * @param nExtraBonus Additional bonus damage or attack modifiers. Defaults to 0.
 
 * @param nBullAoO If TRUE (default), allows AoOs triggered during Bull Rush resolution.
 
 * @param nMustFollow If TRUE (default), the PC will always move toward the target even if it's invalid later.
 
 * @param nAttack Attack bonus override for the charge attack. 0 = use default or calculate.
 
 * @param nPounce If TRUE, the PC can perform a full attack on the charge. Determined automatically if not set.
 */
void DoCharge(object oPC, object oTarget, int nDoAttack = TRUE, int nGenerateAoO = TRUE, int nDamage = 0, int nDamageType = -1, int nBullRush = FALSE, int nExtraBonus = 0, int nBullAoO = TRUE, int nMustFollow = TRUE, int nAttack = 0, int nPounce = FALSE)
{
    if(!nGenerateAoO)
    {
        // Huge bonus to tumble to prevent AoOs from movement
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_TUMBLE, 50), oPC, 6.0);
    }
    // Return value
    int nSucceed = FALSE;
    // PnP rules use feet, might as well convert it now.
    float fDistance = MetersToFeet(GetDistanceBetweenLocations(GetLocation(oPC), GetLocation(oTarget)));
    if(fDistance >= 10.0)
    {
        // Mark the PC as charging
        SetIsCharging(oPC);
        
        nDamage += _ChargeDamage(oPC);
        nAttack = _ChargeAttack(oPC, oTarget, nAttack); // This now takes into account charge feats
        effect eNone;

        // Move to the target
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionMoveToObject(oTarget, TRUE));
        if(nDoAttack) // Perform the Attack
        {
		    // Dread Carapace Totem Bind
		    if(GetIsIncarnumUser(oPC))
		    {
				if (GetIsMeldBound(oPC, MELD_DREAD_CARAPACE) == CHAKRA_TOTEM || GetIsMeldBound(oPC, MELD_DREAD_CARAPACE) == CHAKRA_DOUBLE_TOTEM) // CHAKRA_TOTEM
		    	{
			     	location lTargetLocation = GetLocation(oPC);
			     	int nSaveDC = GetMeldshaperDC(oPC, CLASS_TYPE_TOTEMIST, MELD_DREAD_CARAPACE); // MELD_DREAD_CARAPACE
	        
			     	object oDreadTarget = MyFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(60.0), lTargetLocation, FALSE, OBJECT_TYPE_CREATURE);
			     	while(GetIsObjectValid(oDreadTarget))
			     	{
			          	if(GetIsEnemy(oPC, oDreadTarget))
			          	{
			          		if(!PRCMySavingThrow(SAVING_THROW_WILL, oDreadTarget, nSaveDC, SAVING_THROW_TYPE_FEAR))
			          			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectShaken(), oDreadTarget, 6.0);

			          	}
			          	//Select the next target within the spell shape.
			          	oDreadTarget = MyNextObjectInShape(SHAPE_SPHERE, FeetToMeters(60.0), lTargetLocation, FALSE, OBJECT_TYPE_CREATURE);
			        } 
		        }
				   
		    	if (GetIsMeldBound(oPC, MELD_SPHINX_CLAWS) == CHAKRA_HANDS || GetIsMeldBound(oPC, MELD_SPHINX_CLAWS) == CHAKRA_DOUBLE_HANDS && 
					!GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC))) // CHAKRA_HANDS, empty hand
		    		nPounce = TRUE;		        
		    }         	
        
            // Flying Kick feat
            if(GetHasFeat(FEAT_FLYING_KICK, oPC) && (GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC) == OBJECT_INVALID)) 
                nDamage += d12();
            if(GetHasFeat(FEAT_LION_TRIBE_WARRIOR, oPC) && GetIsLightWeapon(oPC) && !IPGetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC))) // No melee weapon in your off hand
                nPounce = TRUE;
            if(GetHasFeat(FEAT_SNOW_TIGER_BERSERKER, oPC) && GetIsLightWeapon(oPC)) 
                nPounce = TRUE;                
            if(GetHasFeat(FEAT_CATFOLK_POUNCE, oPC) && GetIsDeniedDexBonusToAC(oTarget, oPC, TRUE)) 
                nPounce = TRUE;    
            if(GetItemPossessedBy(oPC, "WOL_Shishio") == GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC) && GetLocalInt(oPC, "Shishio_Pounce"))    
                nPounce = TRUE;
            if(GetLevelByClass(CLASS_TYPE_CELEBRANT_SHARESS, oPC) >= 5)
            	nPounce = TRUE;
            if(GetRacialType(oPC) == RACIAL_TYPE_MARRUSAULT)
            	nPounce = TRUE;       
            if (GetHasSpellEffect(VESTIGE_CHUPOCLOPS, oPC) && GetLocalInt(oPC, "ExploitVestige") != VESTIGE_CHUPOCLOPS_POUNCE)	
            	nPounce = TRUE;
			//:: Lion of Talisid
            if(GetHasFeat(FEAT_LOT_LIONS_POUNCE, oPC))
                nPounce = TRUE;			
            
            // Checks for a White Raven Stance
            // If it exists, +1 damage/initiator level
            if(GetLocalInt(oPC, "LeadingTheCharge"))
                nDamage += GetLocalInt(oPC, "LeadingTheCharge");
            if(nDamageType == -1) // If the damage type isn't set
            {
                object oWeap = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
                nDamageType = GetWeaponDamageType(oWeap);
            }
            
            float fDelay = FeetToMeters(fDistance)/10;
            
            if(nPounce) // Uses instant attack in order to make sure they all go off in the alloted period of time.
                DelayCommand(fDelay, PerformAttackRound(oTarget, oPC, eNone, 0.0, nAttack, nDamage, nDamageType, FALSE, "Charge Hit", "Charge Miss", FALSE, FALSE, TRUE));
            else if(GetLocalInt(oPC, "BariaurCharge")) // Bariaur Charge 
            {
            	int nRoll = GetAttackRoll(oTarget, oPC, OBJECT_INVALID, 0, 0, nAttack);
            	_BariaurChargeDamage(oPC, oTarget, nRoll, nDamage);
            	DeleteLocalInt(oPC, "BariaurCharge");
            }
            else if(GetLocalInt(oPC, "ShifterGore")) //Gorebrute shifter option
            {
                string sResRef = "prc_shftr_gore_";
                int nSize = PRCGetCreatureSize(oPC);
                if(GetHasFeat(FEAT_SHIFTER_SAVAGERY) && GetHasFeatEffect(FEAT_FRENZY, oTarget))
                    nSize += 2;
                if(nSize > CREATURE_SIZE_COLOSSAL)
                    nSize = CREATURE_SIZE_COLOSSAL;
                sResRef += GetAffixForSize(nSize);
                object oHorns = CreateItemOnObject(sResRef, oPC);
                DelayCommand(fDelay, PerformAttack(oTarget, oPC, eNone, 0.0, nAttack, nDamage + (GetHitDice(oPC) / 4), DAMAGE_TYPE_PIERCING, "Horns Hit", "Horns Miss", FALSE, oHorns));
                DestroyObject(oHorns);
            }
            else if(GetLocalInt(oPC, "ShifterClaw")) //Razorclaw Elite shifted option
            {
                object oWeaponL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oPC);
                object oWeaponR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oPC);
                DelayCommand(fDelay, PerformAttack(oTarget, oPC, eNone, 0.0, nAttack, nDamage, DAMAGE_TYPE_SLASHING, "Claw Hit", "Claw Miss", FALSE, oWeaponR, oWeaponL));
                DelayCommand(fDelay, PerformAttack(oTarget, oPC, eNone, 0.0, nAttack, nDamage, DAMAGE_TYPE_SLASHING, "Claw Hit", "Claw Miss", FALSE, oWeaponR, oWeaponL, 1));
            }
            else
            {
                if(GetHasFeat(FEAT_TWO_WEAPON_POUNCE, oPC) && IPGetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC)))
                {
                    nAttack -= 2;
                    DelayCommand(fDelay, PerformAttack(oTarget, oPC, eNone, 0.0, nAttack, nDamage, nDamageType, "Two Weapon Pounce Hit", "Two Weapon Pounce Miss", FALSE, OBJECT_INVALID, OBJECT_INVALID, TRUE));
                }    
                else if (GetLocalInt(oPC, "TigerFangCharge")) // Grants one extra attack at the end of a charge
                	DelayCommand(fDelay, PerformAttack(oTarget, oPC, eNone, 0.0, nAttack, nDamage, nDamageType, "Frenzied Charge Hit", "Frenzied Charge Miss", FALSE, OBJECT_INVALID, OBJECT_INVALID, TRUE));
                DelayCommand(fDelay, PerformAttack(oTarget, oPC, eNone, 0.0, nAttack, nDamage, nDamageType, "Charge Hit", "Charge Miss"));
            }
            DelayCommand(fDelay, _PostCharge(oPC, oTarget));
        }
        if(nBullRush)
        {
            DoBullRush(oPC, oTarget, nExtraBonus, nBullAoO, nMustFollow);
            FloatingTextStringOnCreature("You are bull rushing " + GetName(oTarget), oPC);
        }
    }
    else
    {
        FloatingTextStringOnCreature("You are too close to charge " + GetName(oTarget), oPC);
    }
}

void DoBullRush(object oPC, object oTarget, int nExtraBonus, int nGenerateAoO = TRUE, int nMustFollow = TRUE, int nNoMove = FALSE, int nAbility = 0)
{
	if (!nNoMove)
	{
    	// Move to the target
    	AssignCommand(oPC, ClearAllActions());
    	AssignCommand(oPC, ActionMoveToObject(oTarget, TRUE)); 
    }	
    effect eNone;

    // Do the AoO for moving into the enemy square
    if (nGenerateAoO)
    {
        if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullRush: AoO Start", oPC, FALSE);
        location lTarget = GetLocation(oPC);
        // Use the function to get the closest creature as a target
        object oAreaTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oAreaTarget))
        {
            // All enemies in range get a free AoO shot
            if(oAreaTarget != oPC && // Don't hit yourself
               GetIsInMeleeRange(oPC, oAreaTarget) && // They must be in melee range
               GetIsEnemy(oAreaTarget, oPC)) // Only enemies are going to take AoOs
            {
                if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullRush: AoO Part 1", oPC, FALSE);
                if (!GetHasFeat(FEAT_IMPROVED_BULLRUSH, oPC) || oAreaTarget != oTarget) //Improved Bullrush means the defender can't take the AoO
                {
                    // Perform the Attack
                    DelayCommand(0.0, PerformAttack(oPC, oAreaTarget, eNone, 0.0, 0, 0, 0, "Attack of Opportunity Hit", "Attack of Opportunity Miss"));  
                    FloatingTextStringOnCreature(GetName(oAreaTarget)+" Bull Rush Attack of Opportunity", oPC, FALSE);
                    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullRush: AoO Part 2", oPC, FALSE);
                }
            }

        //Select the next target within the spell shape.
        oAreaTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        }
    }
    float fDelay = PRCGetSpellEffectDelay(GetLocation(oPC), oTarget) * 2.5;
    if (nNoMove) fDelay = 0.1; // No need for a delay if it's a spell
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoBullrush: Delay: "+FloatToString(fDelay), oPC, FALSE);
    DelayCommand(fDelay,_DoBullrushCheck(oPC, oTarget, nExtraBonus, nMustFollow, nAbility));     
}

int DoTrip(object oPC, object oTarget, int nExtraBonus, int nGenerateAoO = TRUE, int nCounterTrip = TRUE, int nSkipTouch = FALSE, int nAbi = 0)
{
    // The basic modifiers
    int nSucceed = FALSE;
    effect eNone;
    int nPCStat, nTargetStat;
    // Use the higher of the two mods
    if (GetAbilityModifier(ABILITY_STRENGTH, oPC) > GetAbilityModifier(ABILITY_DEXTERITY, oPC))
            nPCStat = GetAbilityModifier(ABILITY_STRENGTH, oPC);
    else
            nPCStat = GetAbilityModifier(ABILITY_DEXTERITY, oPC);
    // Use the higher of the two mods       
    if (GetAbilityModifier(ABILITY_STRENGTH, oTarget) > GetAbilityModifier(ABILITY_DEXTERITY, oTarget))
            nTargetStat = GetAbilityModifier(ABILITY_STRENGTH, oTarget);
    else
            nTargetStat = GetAbilityModifier(ABILITY_DEXTERITY, oTarget);
    // Override        
    if (nAbi > 0) nPCStat = nAbi;        
    // Get mods for size
    int nPCBonus = PRCGetSizeModifier(oPC) + GetCombatMoveCheckBonus(oPC, COMBAT_MOVE_TRIP, FALSE, TRUE);
    int nTargetBonus = PRCGetSizeModifier(oTarget) + GetCombatMoveCheckBonus(oTarget, COMBAT_MOVE_TRIP, TRUE);
    //Warblade Battle Skill bonus
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oPC) >= 11) 
    {
        nPCBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
        if (DEBUG_COMBAT_MOVE) DoDebug("Warblade Battle Skill Trip bonus (attacker)");
    }
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oTarget) >= 11)
    {
        nTargetBonus += GetAbilityModifier(ABILITY_INTELLIGENCE, oTarget);
        if (DEBUG_COMBAT_MOVE) DoDebug("Warblade Battle Skill Trip bonus (defender)");
    }
    if (GetHasFeat(FEAT_IMPROVED_TRIP, oPC)) nPCBonus += 4;
    // Do the AoO for a trip attempt
    if (nGenerateAoO && !GetHasFeat(FEAT_IMPROVED_TRIP, oPC))
    {
        // Perform the Attack
        effect eNone;
        DelayCommand(0.0, PerformAttack(oPC, oTarget, eNone, 0.0, 0, 0, 0, "Attack of Opportunity Hit", "Attack of Opportunity Miss"));     
    }
    int nPCCheck = nPCStat + nPCBonus + nExtraBonus + d20();
    int nTargetCheck = nTargetStat + nTargetBonus + d20();
    
    int nTouch;
    if (nSkipTouch == TRUE) nTouch = TRUE;
    else nTouch = PRCDoMeleeTouchAttack(oTarget, TRUE, oPC);
    
    // Gotta touch them
    if (nTouch)
    {
        SendMessageToPC(oPC, "Trip Check: "+IntToString(nPCCheck)+" vs "+IntToString(nTargetCheck));
        // Now roll the ability check
        if (nPCCheck >= nTargetCheck)
        {
            // Knock em down
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectKnockdown()), oTarget, 6.0);
            nSucceed = TRUE;
            SetLocalInt(oPC, "TripDifference", nPCCheck - nTargetCheck);
            DelayCommand(2.0, DeleteLocalInt(oPC, "TripDifference"));
            
            if (!GetLocalInt(oPC, "CurlingWaveStrikeLoop")) // Neither of these trigger when Curling Wave Strike Loop protection is active
            {                
                if (GetHasFeat(FEAT_CURLING_WAVE_STRIKE, oPC) && !GetLocalInt(oPC, "CurlingWaveStrikeRound")) // Once a round
                    _DoCurlingWaveStrike(oPC, oTarget);
                else if (GetHasFeat(FEAT_IMPROVED_TRIP, oPC)) // Do the free Improved Trip attack
                    DelayCommand(0.0, PerformAttack(oTarget, oPC, eNone, 0.0, 0, 0, 0, "Improved Trip Free Attack Hit", "Improved Trip Free Attack Miss"));     
            }        
        }
		else // If you fail, enemy gets a counter trip attempt, using Strength  
		{  
			if(nCounterTrip)   
			{  
				nTargetStat = GetAbilityModifier(ABILITY_STRENGTH, oTarget) + GetCombatMoveCheckBonus(oTarget, COMBAT_MOVE_TRIP, FALSE, TRUE);  
				FloatingTextStringOnCreature("You have failed on your Trip attempt",oPC, FALSE);  
				// Roll counter trip attempt  
				nTargetCheck = nTargetStat + nTargetBonus + d20();  
				nPCCheck = nPCStat + nPCBonus + d20();  
				// If counters aren't allowed, don't knock em down  
				// Its down here to allow the text message to go through  
				SendMessageToPC(oPC, "Enemy Counter Trip Check: "+IntToString(nPCCheck)+" vs "+IntToString(nTargetCheck));  
				  
				SetLocalInt(oPC, "TripDifference", nTargetCheck - nPCCheck);  
				DelayCommand(2.0, DeleteLocalInt(oPC, "TripDifference"));  
			}  
			if (nTargetCheck >= nPCCheck && nCounterTrip)  
			{  
					// Knock em down  
					ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectKnockdown()), oPC, 6.0);  
			}  
		}		
/*         else // If you fail, enemy gets a counter trip attempt, using Strength
        {
            nTargetStat = GetAbilityModifier(ABILITY_STRENGTH, oTarget) + GetCombatMoveCheckBonus(oTarget, COMBAT_MOVE_TRIP, FALSE, TRUE);
            FloatingTextStringOnCreature("You have failed on your Trip attempt",oPC, FALSE);
            // Roll counter trip attempt
            nTargetCheck = nTargetStat + nTargetBonus + d20();
            nPCCheck = nPCStat + nPCBonus + d20();
            // If counters aren't allowed, don't knock em down
            // Its down here to allow the text message to go through
            SendMessageToPC(oPC, "Enemy Counter Trip Check: "+IntToString(nPCCheck)+" vs "+IntToString(nTargetCheck));
            if (nTargetCheck >= nPCCheck && nCounterTrip)
            {
                    // Knock em down
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectKnockdown()), oPC, 6.0);
            }
            SetLocalInt(oPC, "TripDifference", nTargetCheck - nPCCheck);
            DelayCommand(2.0, DeleteLocalInt(oPC, "TripDifference"));
        } */
    }
    else
        FloatingTextStringOnCreature("You have failed on your Trip attempt",oPC, FALSE);
        
    // Now we do the rest of the attacks in the round, regardless, remembering to bump down the iteratives
    SetLocalInt(oPC, "CombatMoveAttack", TRUE);
    DelayCommand(5.5, DeleteLocalInt(oPC, "CombatMoveAttack"));
    if (GetBaseAttackBonus(oPC) >= 6) PerformAttackRound(oTarget, oPC, eNone, 0.0, -5); 
    DelayCommand(0.25, AssignCommand(oPC, ActionAttack(oTarget)));
        
    // Let people know if we made the hit or not
    return nSucceed;
}

int GetIntToDamage(int nCheck)
{
    switch(nCheck)
    {
        case  1: return DAMAGE_BONUS_1;
        case  2: return DAMAGE_BONUS_2;
        case  3: return DAMAGE_BONUS_3;
        case  4: return DAMAGE_BONUS_4;
        case  5: return DAMAGE_BONUS_5;
        case  6: return DAMAGE_BONUS_6;
        case  7: return DAMAGE_BONUS_7;
        case  8: return DAMAGE_BONUS_8;
        case  9: return DAMAGE_BONUS_9;
        case 10: return DAMAGE_BONUS_10;
        case 11: return DAMAGE_BONUS_11;
        case 12: return DAMAGE_BONUS_12;
        case 13: return DAMAGE_BONUS_13;
        case 14: return DAMAGE_BONUS_14;
        case 15: return DAMAGE_BONUS_15;
        case 16: return DAMAGE_BONUS_16;
        case 17: return DAMAGE_BONUS_17;
        case 18: return DAMAGE_BONUS_18;
        case 19: return DAMAGE_BONUS_19;
        case 20: return DAMAGE_BONUS_20;
		case 21: return DAMAGE_BONUS_21;
		case 22: return DAMAGE_BONUS_22;
		case 23: return DAMAGE_BONUS_23;
		case 24: return DAMAGE_BONUS_24;
		case 25: return DAMAGE_BONUS_25;
		case 26: return DAMAGE_BONUS_26;
		case 27: return DAMAGE_BONUS_27;
		case 28: return DAMAGE_BONUS_28;
		case 29: return DAMAGE_BONUS_29;
		case 30: return DAMAGE_BONUS_30;
		case 31: return DAMAGE_BONUS_31;
		case 32: return DAMAGE_BONUS_32;
		case 33: return DAMAGE_BONUS_33;
		case 34: return DAMAGE_BONUS_34;
		case 35: return DAMAGE_BONUS_35;
		case 36: return DAMAGE_BONUS_36;
		case 37: return DAMAGE_BONUS_37;
		case 38: return DAMAGE_BONUS_38;
		case 39: return DAMAGE_BONUS_39;
		case 40: return DAMAGE_BONUS_40;
		case 41: return DAMAGE_BONUS_41;
		case 42: return DAMAGE_BONUS_42;
		case 43: return DAMAGE_BONUS_43;
		case 44: return DAMAGE_BONUS_44;
		case 45: return DAMAGE_BONUS_45;
		case 46: return DAMAGE_BONUS_46;
		case 47: return DAMAGE_BONUS_47;
		case 48: return DAMAGE_BONUS_48;
		case 49: return DAMAGE_BONUS_49;
		case 50: return DAMAGE_BONUS_50;		
    }
    return -1;
}

/**
 * @brief Attempts to initiate a grapple between the PC and the target creature.
 *
 * @param oPC               The player character initiating the grapple attempt.
 * @param oTarget           The target creature to be grappled.
 * @param nExtraBonus       Additional bonus added to the grapple check (e.g., from feats, spells, items).
 * @param nGenerateAoO      If TRUE, the target is allowed an Attack of Opportunity unless the PC has Improved Grapple.
 *                          Defaults to TRUE.
 * @param nSkipTouch        If TRUE, the melee touch attack step is skipped (assumes auto-hit).
 *                          Useful when a touch attack was already resolved elsewhere.
 *
 * @return                  TRUE if the grapple attempt succeeds, FALSE otherwise.
 */
int DoGrapple(object oPC, object oTarget, int nExtraBonus, int nGenerateAoO = TRUE, int nSkipTouch = FALSE)
{
    if (GetGrapple(oTarget))
    {
        FloatingTextStringOnCreature("You cannot grapple a creature that is already grappled.", oPC, FALSE);
        return FALSE;    
    }
    if(GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, oTarget))
    {
        FloatingTextStringOnCreature("You cannot grapple a creature under the effect of Freedom of Movement", oPC, FALSE);
        return FALSE;    
    }

	if (IPGetHasItemPropertyOnCharacter(oTarget, ITEM_PROPERTY_FREEDOM_OF_MOVEMENT))
	{
        FloatingTextStringOnCreature("You cannot grapple a creature under the effect of Freedom of Movement.", oPC, FALSE);
        return FALSE;    
    }
	if (GetIsImmune(oTarget, IMMUNITY_TYPE_ENTANGLE))
	{
        FloatingTextStringOnCreature("This creature is immune to grappling.", oPC, FALSE);
        return FALSE;    
    }	
	
    object oGlaive = GetItemPossessedBy(oPC, "prc_eldrtch_glv");
    if(GetIsObjectValid(oGlaive))
    	DestroyObject(oGlaive);
    
    int nSucceed = FALSE;
    effect eNone;
    // Do the AoO for trying a grapple
    if (nGenerateAoO && !GetHasFeat(FEAT_IMPROVED_GRAPPLE, oPC))
    {
        // Perform the Attack
        DelayCommand(0.0, PerformAttack(oPC, oTarget, eNone, 0.0, 0, 0, 0, "Attack of Opportunity Hit", "Attack of Opportunity Miss"));     

        if (GetLocalInt(oPC, "PRCCombat_StruckByAttack"))
        {
            FloatingTextStringOnCreature("You have failed at your Grapple Attempt.", oPC, FALSE);
            return FALSE;
        }
    }
    
    int nTouch;
    if (nSkipTouch == TRUE) nTouch = TRUE;
    else nTouch = PRCDoMeleeTouchAttack(oTarget, TRUE, oPC);
    
    // Gotta touch them
    if (nTouch)
    {    
        // Now roll the ability check
        if (_DoGrappleCheck(oPC, oTarget, nExtraBonus))
        {
            FloatingTextStringOnCreature("You have successfully grappled " + GetName(oTarget), oPC, FALSE);
            int nBearFang = GetLocalInt(oPC, "BearFangGrapple");
			 
			SetGrapple(oPC);
			SetGrapple(oTarget);
			SetLocalInt(oPC, "GrappleOriginator", TRUE);
			SetGrappleTarget(oPC, oTarget);  // Move this up from line 1544
			 
			effect eHold = EffectCutsceneParalyze();
			effect eEntangle = EffectVisualEffect(VFX_DUR_SPELLTURNING_R);
			effect eLink = EffectLinkEffects(eHold, eEntangle);
			 
			if (!GetLocalInt(oPC, "Flay_Grapple")) 
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eLink), oPC, 9999.0);
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eLink), oTarget, 9999.0);
			 
			nSucceed = TRUE;
			 
			if (nBearFang) 
			{
				DelayCommand(0.1, PerformAttack(oTarget, oPC, eNone, 0.0, -4, 0, 0, "Bear Fang Attack Hit", "Bear Fang Attack Miss")); 
				DeleteLocalInt(oPC, "BearFangGrapple");
			}
			else
			{
				object oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oPC);
				effect eDam = GetAttackDamage(oTarget, oPC, oWeap, GetWeaponBonusDamage(oWeap, oTarget), GetMagicalBonusDamage(oPC, oTarget));
				DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));  // Delay damage
			} 
			
/*             SetGrapple(oPC);
            SetGrapple(oTarget);
            SetLocalInt(oPC, "GrappleOriginator", TRUE);
            effect eHold = EffectCutsceneParalyze();
            effect eEntangle = EffectVisualEffect(VFX_DUR_SPELLTURNING_R);
            effect eLink = EffectLinkEffects(eHold, eEntangle);
            //apply the effect
            if (!GetLocalInt(oPC, "Flay_Grapple")) ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eLink), oPC, 9999.0);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eLink), oTarget, 9999.0);
            nSucceed = TRUE;
            
            if (nBearFang) // Grants a bonus attack on hit
            {
                // Attack with a -4 penalty
                DelayCommand(0.0, PerformAttack(oTarget, oPC, eNone, 0.0, -4, 0, 0, "Bear Fang Attack Hit", "Bear Fang Attack Miss")); 
                DeleteLocalInt(oPC, "BearFangGrapple");
            }
            else
            {
                // Now hit them with an unarmed strike
                object oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oPC);
                effect eDam = GetAttackDamage(oTarget, oPC, oWeap, GetWeaponBonusDamage(oWeap, oTarget), GetMagicalBonusDamage(oPC, oTarget));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
            } 
 */			_HeartOfFireGrapple(oPC, oTarget);
            
            // If you kill them with this, best to clean up right away
            if (GetIsDead(oTarget) || !GetIsObjectValid(oTarget)) 
            {
                EndGrapple(oPC, oTarget);
                // Remove the hooks
                if(DEBUG) DoDebug("prc_grapple: Removing eventhooks");
                RemoveEventScript(oPC, EVENT_ONHEARTBEAT,         "prc_grapple", TRUE, FALSE);  
                FloatingTextStringOnCreature("Your target is dead, ending grapple", oPC, FALSE);            
            }
            else
            {
                // Hook in the events and save the target for an ongoing grapple
                if(DEBUG) DoDebug("prc_grapple: Adding eventhooks");
                SetGrappleTarget(oPC, oTarget);
                AddEventScript(oPC, EVENT_ONHEARTBEAT,         "prc_grapple", TRUE, FALSE);   
            }
        }
        else
            FloatingTextStringOnCreature("You have failed your Grapple Attempt", oPC, FALSE);
    }        

    // Let people know if we made the hit or not
    return nSucceed;
}

void SetGrapple(object oTarget)
{
    SetLocalInt(oTarget, "IsGrappled", TRUE);
}

int GetGrapple(object oTarget)
{
    return GetLocalInt(oTarget, "IsGrappled");
}

void SetGrappleTarget(object oPC, object oTarget)
{
    SetLocalObject(oPC, "GrappleTarget", oTarget);
}

object GetGrappleTarget(object oPC)
{
    return GetLocalObject(oPC, "GrappleTarget");
}

void SetIsPinned(object oTarget)
{
    SetLocalInt(oTarget, "IsPinned", TRUE);
}

int GetIsPinned(object oTarget)
{
    return GetLocalInt(oTarget, "IsPinned");
}

void BreakPin(object oTarget)
{
    DeleteLocalInt(oTarget, "IsPinned");
    DeleteLocalInt(oTarget, "PinnedRounds");
}

void EndGrapple(object oPC, object oTarget)
{
    DeleteLocalInt(oPC, "IsGrappled");
    DeleteLocalInt(oTarget, "IsGrappled");
    DeleteLocalInt(oTarget, "PinnedRounds");
    DeleteLocalObject(oPC, "GrappleTarget");
    DeleteLocalInt(oTarget, "UnconsciousGrapple");
    DeleteLocalInt(oPC, "GrappleOriginator");
    DeleteLocalInt(oPC, "ScorpionLight");
    DeleteLocalInt(oPC, "Flay_Grapple");
    RemoveEventScript(oPC, EVENT_ITEM_ONHIT, "wol_m_flay", TRUE, FALSE);    
    BreakPin(oTarget);
    effect eBad = GetFirstEffect(oTarget);
    //Search for negative effects
    while(GetIsEffectValid(eBad))
    {
        int nInt = GetEffectSpellId(eBad);
        if (GetEffectType(eBad) == EFFECT_TYPE_CUTSCENE_PARALYZE)
        {
            RemoveEffect(oTarget, eBad);
        }
        eBad = GetNextEffect(oTarget);
    }
    eBad = GetFirstEffect(oPC);
    //Search for negative effects
    while(GetIsEffectValid(eBad))
    {
        int nInt = GetEffectSpellId(eBad);
        if (GetEffectType(eBad) == EFFECT_TYPE_CUTSCENE_PARALYZE)
        {
            RemoveEffect(oPC, eBad);
        }
        eBad = GetNextEffect(oPC);
    }
}

int DoGrappleOptions(object oPC, object oTarget, int nExtraBonus, int nSwitch = -1)
{
    effect eNone;
    
    int nSuccess = _DoGrappleCheck(oPC, oTarget, nExtraBonus, nSwitch);
    // This applies on all grapples regardless of success or failure
    _HeartOfFireGrapple(oPC, oTarget);
    if(GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, oTarget))
    {
    	nSuccess = TRUE;
    	nSwitch = GRAPPLE_ESCAPE;
    }

    if (nSwitch == GRAPPLE_ATTACK)
    {
        // Must be a light weapon, and succeed at the grapple check
        if (nSuccess && (GetIsLightWeapon(oPC) || GetLevelByClass(CLASS_TYPE_WARFORGED_JUGGERNAUT, oPC) || GetHasFeat(FEAT_SPIKED_BODY, oPC)||GetHasFeat(FEAT_NATURAL_SPIKES)))
        {
    		if (GetIsMeldBound(oTarget, MELD_RAGECLAWS) == CHAKRA_TOTEM && !GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC))) // CHAKRA_TOTEM
    		{
				DelayCommand(0.0, PerformAttack(oTarget, oPC, eNone, 0.0, 0, 0, 0, "Rageclaws Hit", "Rageclas Miss"));
				DelayCommand(0.0, PerformAttack(oTarget, oPC, eNone, 0.0, 0, 0, 0, "Rageclaws Hit", "Rageclas Miss"));
			}	
            else if (GetHasSpellEffect(MOVE_TC_WOLVERINE_STANCE, oPC))
            {
                int nDam = 0;
                if (PRCGetCreatureSize(oTarget) > PRCGetCreatureSize(oPC)) nDam = 4;
                DelayCommand(0.0, PerformAttack(oTarget, oPC, eNone, 0.0, 0, nDam, 0, "Wolverine Stance Hit", "Wolverine Stance Miss"));    
            }
            else if(GetLevelByClass(CLASS_TYPE_WARFORGED_JUGGERNAUT, oPC))
            {
                int nDam = d6();
                if(GetLevelByClass(CLASS_TYPE_WARFORGED_JUGGERNAUT, oPC) >= 4) nDam = d8();    
            
                effect eDeath = EffectDamage(nDam, DAMAGE_TYPE_PIERCING);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget); 
                FloatingTextStringOnCreature("Warforged Juggernaut Armor Spikes Hit", oPC, FALSE);
            }
            else if(GetHasFeat(FEAT_SPIKED_BODY, oPC))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(), DAMAGE_TYPE_PIERCING), oTarget); 
                FloatingTextStringOnCreature("Spiked Body Hit", oPC, FALSE);
            }            
            else if(GetHasFeat(FEAT_NATURAL_SPIKES, oPC))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(), DAMAGE_TYPE_PIERCING), oTarget); 
                FloatingTextStringOnCreature("Natural Spikes Hit", oPC, FALSE);
            }    
			else
            {
                // Attack with a -4 penalty
                int nPen = -4;
                if (GetLocalInt(oPC, "ScorpionLight")) nPen = 0;
                DelayCommand(0.0, PerformAttack(oTarget, oPC, eNone, 0.0, nPen, 0, 0, "Grapple Light Weapon Attack Hit", "Grapple Light Weapon Attack Miss"));  
            }
        }
        else
            FloatingTextStringOnCreature("You have failed your Grapple Light Weapon Attack Attempt",oPC, FALSE);
    }
    else if (nSwitch == GRAPPLE_OPPONENT_WEAPON)
    {
        // Must be a light weapon, and succeed at the grapple check
        if (nSuccess && GetIsLightWeapon(oTarget))
        {
            // Attack with a -4 penalty
            object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
            DelayCommand(0.0, PerformAttack(oTarget, oPC, eNone, 0.0, -4, 0, 0, "Grapple Opponent's Weapon Hit", "Grapple Opponent's Weapon Miss", FALSE, oWeapon));  
        }
        else
            FloatingTextStringOnCreature("You have failed your Grapple Opponent's Weapon Attempt",oPC, FALSE);
    }
    else if (nSwitch == GRAPPLE_DAMAGE)
    {
        // Must be a light weapon, and succeed at the grapple check
        if (GetLocalInt(oPC, "Flay_Grapple"))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d3()+5), oTarget);
            FloatingTextStringOnCreature("Flay Constrict", oPC, FALSE);        
        }   
        else if (GetLevelByClass(CLASS_TYPE_BLACK_BLOOD_CULTIST, oPC) >= 8)
        {
            // Now hit them with a lot of unarmed strikes
            object oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oPC);
            effect eDam = GetAttackDamage(oTarget, oPC, oWeap, GetWeaponBonusDamage(oWeap, oTarget), GetMagicalBonusDamage(oPC, oTarget));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
            oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oPC);
            eDam = GetAttackDamage(oTarget, oPC, oWeap, GetWeaponBonusDamage(oWeap, oTarget), GetMagicalBonusDamage(oPC, oTarget));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget); 
            oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oPC);
            eDam = GetAttackDamage(oTarget, oPC, oWeap, GetWeaponBonusDamage(oWeap, oTarget), GetMagicalBonusDamage(oPC, oTarget));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);            
            // Rend damage is double claw damage
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d8(2) + (2 * GetAbilityModifier(ABILITY_STRENGTH, oPC)), DAMAGE_TYPE_SLASHING), oTarget);  
            FloatingTextStringOnCreature("Savage Grapple Hit",oPC, FALSE);        
        }        
        else if (GetHasFeat(FEAT_OWLBEAR_BERSERKER, oPC))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6()), oTarget);
            FloatingTextStringOnCreature("Owlbear Berserker Hit",oPC, FALSE);        
        }
        else if (nSuccess)
        {
            // Now hit them with an unarmed strike
            object oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oPC);
            effect eDam = GetAttackDamage(oTarget, oPC, oWeap, GetWeaponBonusDamage(oWeap, oTarget), GetMagicalBonusDamage(oPC, oTarget));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
            FloatingTextStringOnCreature("Grapple Unarmed Damage Hit",oPC, FALSE);
        }
        else
            FloatingTextStringOnCreature("You have failed your Grapple Unarmed Damage Attempt",oPC, FALSE);

		// This is bonus damage that applies to successful grappling of any of the above            
		if (GetHasSpellEffect(VESTIGE_ZAGAN, oPC) && GetLocalInt(oPC, "ExploitVestige") != VESTIGE_ZAGAN_CONSTRICT && nSuccess)            
		{
			int nDam = d8() + GetAbilityModifier(ABILITY_STRENGTH, oPC) + GetAbilityModifier(ABILITY_STRENGTH, oPC)/2;
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDam), oTarget);
            FloatingTextStringOnCreature("Zagan Constrict Hit",oPC, FALSE); 			
		}
    }    
    else if (nSwitch == GRAPPLE_ESCAPE)
    {
        // Must be a light weapon, and succeed at the grapple check
        if (nSuccess)
        {
            if (GetIsPinned(oPC))
            {
                BreakPin(oPC);
                if (GetIsPC(oPC)) 
                    FloatingTextStringOnCreature("You have escaped the pin", oPC, FALSE);
                else             
                    FloatingTextStringOnCreature("Your target has escaped your pin", oTarget, FALSE);
            }
            else
            {
                EndGrapple(oPC, oTarget);
                
                if (GetIsPC(oPC))
                {
                    // Remove the hooks
                    if(DEBUG) DoDebug("prc_grapple: Removing eventhooks");
                    RemoveEventScript(oPC, EVENT_ONHEARTBEAT,         "prc_grapple", TRUE, FALSE);  
                    FloatingTextStringOnCreature("You have escaped the grapple", oPC, FALSE);
                }
                else
                {
                    // Remove the hooks
                    if(DEBUG) DoDebug("prc_grapple: Removing eventhooks");
                    RemoveEventScript(oTarget, EVENT_ONHEARTBEAT,         "prc_grapple", TRUE, FALSE);  
                    FloatingTextStringOnCreature("Your target has escaped your grapple", oTarget, FALSE);
                    // Target is valid and we know it's an enemy and we're in combat
                    DelayCommand(0.25, AssignCommand(oTarget, ActionAttack(oPC)));
                }                
            }
        }
        else
            FloatingTextStringOnCreature("You have failed your Grapple Escape Attempt",oPC, FALSE);
    }
    else if (nSwitch == GRAPPLE_TOB_CRUSHING && GetHasSpellEffect(MOVE_SD_CRUSHING_WEIGHT, oPC))
    {
        // Constrict for 2d6 + 1.5 Strength
        if (nSuccess)
        {
            int nDam = FloatToInt(d6(2) + (GetAbilityModifier(ABILITY_STRENGTH, oPC) * 1.5));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDam), oTarget);
            FloatingTextStringOnCreature("Crushing Weight Success",oPC, FALSE);
        }
        else
            FloatingTextStringOnCreature("You have failed your Crushing Weight Attempt",oPC, FALSE);
    }
    else if (nSwitch == GRAPPLE_PIN)  
    {  
        // Pins the target  
        if (nSuccess)  
        {  
            FloatingTextStringOnCreature("You have pinned your target", oPC, FALSE);  
            SetIsPinned(oTarget);  
            int nRounds = _CountPinRounds(oTarget); // always increment  
            int nClass = GetLevelByClass(CLASS_TYPE_REAPING_MAULER, oPC);  
            if (nClass)  
            {  
                _DoReapingMauler(oPC, oTarget, nRounds);  
            }  
            else if (GetHasFeat(FEAT_CHOKE_HOLD, oPC))  
            {  
                DelayCommand(6.0, _DoChokeHold(oPC, oTarget));  
            }  
            if (GetHasFeat(FEAT_EARTHS_EMBRACE, oPC))  
            {  
                // Add in unarmed damage  
                int nDamageSize = FindUnarmedDamage(oPC);  
  
                int nDie = StringToInt(Get2DACache("iprp_monstcost", "Die", nDamageSize));  
                int nNum  = StringToInt(Get2DACache("iprp_monstcost", "NumDice", nDamageSize));  
                int nRoll;  
  
                //Potential die options  
                if(nDie == 4) nRoll = d4(nNum);  
                else if(nDie == 6) nRoll = d6(nNum);  
                else if(nDie == 8) nRoll = d8(nNum);  
                else if(nDie == 10) nRoll = d10(nNum);  
                else if(nDie == 12) nRoll = d12(nNum);  
                else if(nDie == 20) nRoll = d20(nNum);  
  
                FloatingTextStringOnCreature("Earth's Embrace chokes the life from your foe", oPC, FALSE);  
  
                int nDam = d12() + nRoll;  
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDam, DAMAGE_TYPE_BLUDGEONING), oTarget);  
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectACDecrease(4)), oPC, 6.0);  
            }  
        }  
        else  
            FloatingTextStringOnCreature("You have failed your Grapple Pin Attempt",oPC, FALSE);  
    }
/*     else if (nSwitch == GRAPPLE_PIN)
    {
        // Pins the target
        if (nSuccess)
        {
            FloatingTextStringOnCreature("You have pinned your target", oPC, FALSE);
            SetIsPinned(oTarget);
            int nClass = GetLevelByClass(CLASS_TYPE_REAPING_MAULER, oPC);
            if (nClass)
            {
                int nRounds = _CountPinRounds(oTarget);
                _DoReapingMauler(oPC, oTarget, nRounds);
            }
			if (GetHasFeat(FEAT_CHOKE_HOLD, oPC))  
			{  
				int nRounds = GetLocalInt(oTarget, "PinnedRounds");  
				if (nRounds >= 1)  
				{  
					int nDC = 10 + (GetHitDice(oPC) / 2) + GetAbilityModifier(ABILITY_WISDOM, oPC);  
					if(!FortitudeSave(oTarget, nDC, SAVING_THROW_TYPE_NONE, oPC))  
					{  
						SetLocalInt(oTarget, "UnconsciousGrapple", TRUE);  
						effect eUncon = EffectLinkEffects(EffectStunned(), EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED));  
						eUncon = EffectLinkEffects(eUncon, EffectKnockdown());  
						float fDur = RoundsToSeconds(d3());  
						ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eUncon), oTarget, fDur);  
						FloatingTextStringOnCreature("Choke Hold Success", oPC, FALSE);  
						DelayCommand(fDur, DeleteLocalInt(oTarget, "UnconsciousGrapple"));  
					}  
				}  
			}			
            if (GetHasFeat(FEAT_EARTHS_EMBRACE, oPC))
            {
            	// Add in unarmed damage
				int nDamageSize = FindUnarmedDamage(oPC);
				
				int nDie = StringToInt(Get2DACache("iprp_monstcost", "Die", nDamageSize));
				int nNum  = StringToInt(Get2DACache("iprp_monstcost", "NumDice", nDamageSize));
				int nRoll;

				//Potential die options
				if(nDie == 4) nRoll = d4(nNum);
				else if(nDie == 6) nRoll = d6(nNum);
				else if(nDie == 8) nRoll = d8(nNum);
				else if(nDie == 10) nRoll = d10(nNum);
				else if(nDie == 12) nRoll = d12(nNum);
				else if(nDie == 20) nRoll = d20(nNum);	
				
				FloatingTextStringOnCreature("Earth's Embrace chokes the life from your foe", oPC, FALSE);
				
                int nDam = d12() + nRoll;
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDam, DAMAGE_TYPE_BLUDGEONING), oTarget);  
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectACDecrease(4)), oPC, 6.0); 
            }    
        }
        else
            FloatingTextStringOnCreature("You have failed your Grapple Pin Attempt",oPC, FALSE);
    }  
   */  else
    {
        FloatingTextStringOnCreature("DoGrappleOptions: Error, invalid option "+IntToString(nSwitch)+" passed to function by "+GetName(oPC),oPC, FALSE);
        FloatingTextStringOnCreature("DoGrappleOptions: Error, GetGrapple(oPC) "+IntToString(GetGrapple(oPC))+" GetGrapple(oTarget) "+IntToString(GetGrapple(oTarget)),oPC, FALSE);
        return FALSE;
    }
    
    return nSuccess;
}

int GetIsLightWeapon(object oPC)
{
    // You may use any weapon in a grapple with this stance.
    if (GetHasSpellEffect(MOVE_TC_WOLVERINE_STANCE, oPC)) return TRUE;
    int nSize   = PRCGetCreatureSize(oPC);
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    int nWeaponSize = GetWeaponSize(oItem);
    // is the size appropriate for a light weapon?
    return (nWeaponSize < nSize);
}

void DoOverrun(object oPC, object oTarget, location lTarget, int nGenerateAoO = TRUE, int nExtraBonus = 0, int nAvoid = TRUE, int nCounter = TRUE)
{
    effect eCharge = SupernaturalEffect(EffectMovementSpeedIncrease(99)); // Just to speed things up a bit
    SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCharge, oPC, 5.0);
    SetLocalInt(oPC, "Overrun", 2); // This tells _DoOverrunCheck it's a valid call
    float fLength = GetDistanceBetweenLocations(GetLocation(oPC), lTarget);
    vector vOrigin = GetPosition(oPC);
       
    if (GetIsMeldBound(oPC, MELD_URSKAN_GREAVES) == CHAKRA_TOTEM || GetIsMeldBound(oPC, MELD_URSKAN_GREAVES) == CHAKRA_DOUBLE_TOTEM) 
		nAvoid = FALSE; 
	if (GetHasFeat(FEAT_CENTAUR_TRAMPLE, oPC))	
		nAvoid = FALSE; 

    // Step one is check to see if we're using oTarget or not
    if (GetIsObjectValid(oTarget))
    {
        lTarget = GetLocation(oTarget);
        fLength = GetDistanceBetweenLocations(GetLocation(oPC), lTarget);
        if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoOverrun: Valid Target", oPC, FALSE);
    }
    else
        oTarget = MyFirstObjectInShape(SHAPE_SPELLCYLINDER, fLength, lTarget, TRUE, OBJECT_TYPE_CREATURE, vOrigin); // Only change targets if invalid

    // Move the PC to the location
    AssignCommand(oPC, ClearAllActions(TRUE));
    AssignCommand(oPC, ActionForceMoveToLocation(lTarget, TRUE));
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoOverrun: Distance: "+FloatToString(fLength), oPC, FALSE);
    
    // Loop over targets in the line shape
    if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoOverrun: First Target: "+GetName(oTarget), oPC, FALSE);
    while(GetIsObjectValid(oTarget)) // Find the targets
    {
        if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoOverrun: Loop 1, Target: "+GetName(oTarget), oPC, FALSE);
        if(oTarget != oPC && GetIsEnemy(oTarget, oPC)) // Don't overrun friends or yourself
        {
            float fDelay = PRCGetSpellEffectDelay(GetLocation(oPC), oTarget) * 2.5;
            if (DEBUG_COMBAT_MOVE) FloatingTextStringOnCreature("DoOverrun: Loop 2, Delay: "+FloatToString(fDelay), oPC, FALSE);
            DelayCommand(fDelay,_DoOverrunCheck(oPC, oTarget, lTarget, nGenerateAoO, nExtraBonus, nAvoid, nCounter)); 
        }// end if - Target validity check
    // Get next target
    oTarget = MyNextObjectInShape(SHAPE_SPELLCYLINDER, fLength, lTarget, TRUE, OBJECT_TYPE_CREATURE, vOrigin);
    }// end while - Target loop  
   
    // Clean up
    DelayCommand(3.0,DeleteLocalInt(oPC, "Overrun"));
}

int PRCGetSizeModifier(object oCreature)
{
    int nSize = PRCGetCreatureSize(oCreature);

    //Powerful Build bonus
    if(GetHasFeat(FEAT_RACE_POWERFUL_BUILD, oCreature))
        nSize++;
    //Make sure it doesn't overflow
    if(nSize > CREATURE_SIZE_COLOSSAL) nSize = CREATURE_SIZE_COLOSSAL;
    int nModifier = 0;
    
    // Jotunbrud
    if(GetHasFeat(FEAT_JOTUNBRUD, oCreature) && nSize == CREATURE_SIZE_MEDIUM)
        nSize++;    
	
	// Oddly, this overrides everything else and just sets your size as large
    if (GetHasSpellEffect(VESTIGE_ZAGAN, oCreature) && GetLocalInt(oCreature, "ExploitVestige") != VESTIGE_ZAGAN_GRAPPLE)	    
    	nSize = CREATURE_SIZE_LARGE;

    switch (nSize)
    {
        case CREATURE_SIZE_TINY:       nModifier = -8; break;
        case CREATURE_SIZE_SMALL:      nModifier = -4; break;
        case CREATURE_SIZE_MEDIUM:     nModifier =  0; break;
        case CREATURE_SIZE_LARGE:      nModifier =  4; break;
        case CREATURE_SIZE_HUGE:       nModifier =  8; break;
        case CREATURE_SIZE_GARGANTUAN: nModifier = 12; break;
        case CREATURE_SIZE_COLOSSAL:   nModifier = 16; break;
    }
    return nModifier;
}

void TigerBlooded(object oInitiator, object oTarget)
{
    // Got to have the feat first and hit the opponent
    if (!GetHasFeat(FEAT_TIGER_BLOODED, oInitiator)) return;
    if (!GetLocalInt(oTarget, "PRCCombat_StruckByAttack")) return;
    
    if(GetHasSpellEffect(SPELLABILITY_BARBARIAN_RAGE, oInitiator) || 
       GetIsPolyMorphedOrShifted(oInitiator) ||
       GetHasSpellEffect(SPELL_SPELL_RAGE, oInitiator) || 
       GetHasSpellEffect(SPELL_BLOOD_FRENZY, oInitiator) || 
       GetHasSpellEffect(SPELL_FRENZY, oInitiator) || 
       GetHasSpellEffect(SPELL_INSPIRE_FRENZY, oInitiator) || 
       GetHasSpellEffect(SPELL_TRIBAL_FRENZY , oInitiator) || 
       GetHasSpellEffect(INVOKE_WILD_FRENZY, oInitiator))        
    {
        int nHD = GetHitDice(oInitiator)/2;
        int nStr = GetAbilityModifier(ABILITY_STRENGTH, oInitiator);
        int nDC = 10 + nHD + nStr;
        
        if (PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC) && PRCGetSizeModifier(oInitiator) >= PRCGetSizeModifier(oTarget))
        {
            _DoBullRushKnockBack(oTarget, oInitiator, 5.0);
            FloatingTextStringOnCreature("Tiger Blooded Knockback", oInitiator, FALSE);
        }    
    }        
}

int DoDisarm(object oPC, object oTarget, int nExtraBonus = 0, int nGenerateAoO = TRUE, int nCounter = TRUE)
{
    object oTargetWep = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
	
	int bNoDisarm = GetHasFeat(FEAT_INTRINSIC_WEAPON, oTarget);
	
	string sName = GetName(oTarget);
	
	if(bNoDisarm)
	{
		FloatingTextStringOnCreature(sName+" is wielding an intrinsic weapon", oPC, FALSE);
		AssignCommand(oPC, ActionAttack(oTarget));
		return FALSE;
	}
    
    if (!GetIsObjectValid(oTargetWep) || GetPlotFlag(oTargetWep) || (!GetIsCreatureDisarmable(oTarget) && !GetPRCSwitch(PRC_PNP_DISARM)) || GetLocalInt(oTarget, "TigerFangDisarm")) 
    {    
        FloatingTextStringOnCreature(sName+" is not a legal target", oPC, FALSE);
        AssignCommand(oPC, ActionAttack(oTarget));
        return FALSE;
    }    
    
    // The basic modifiers
    int nSucceed = FALSE;
    object oPCWep = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    effect eNone;
    GetAttackRoll(oTarget, oPC, oPCWep, 0, 0, 0, FALSE);
    GetAttackRoll(oPC, oTarget, oTargetWep, 0, 0, 0, FALSE);
    int nPCAttack = GetLocalInt(oPC, "PRCAttackBonus");
    int nTargetAttack = GetLocalInt(oTarget, "PRCAttackBonus");
    
    nPCAttack += GetCombatMoveCheckBonus(oPC, COMBAT_MOVE_DISARM, FALSE, TRUE);
    nTargetAttack += GetCombatMoveCheckBonus(oTarget, COMBAT_MOVE_DISARM, TRUE);
    
    int nPCSize   = PRCGetCreatureSize(oPC);
    int nPCWeaponSize = GetWeaponSize(oPCWep);
    int nTGSize   = PRCGetCreatureSize(oTarget);
    int nTGWeaponSize = GetWeaponSize(oTargetWep);   
    
    // Two-handed weapon
    if (nPCWeaponSize >= nPCSize + 1)
        nPCAttack += 4;
    if (nTGWeaponSize >= nTGSize + 1)
        nTargetAttack += 4;       
    // Light weapon or unarmed 
    if ((nPCSize > nPCWeaponSize) || !GetIsObjectValid(oPCWep))
        nPCAttack -= 4;
    if (nTGSize > nTGWeaponSize)
        nTargetAttack -= 4;

    //Larger combatant gets a +4 bonus per size difference, applied as a bonus or penalty to the PCAttack
    nPCAttack += (nPCSize - nTGSize) * 4;

    //Warblade Battle Skill bonus
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oPC) >= 11) 
    {
        nPCAttack += GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
        if (DEBUG_COMBAT_MOVE) DoDebug("Warblade Battle Skill Disarm bonus (attacker)");
    }
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oTarget) >= 11)
    {
        nTargetAttack += GetAbilityModifier(ABILITY_INTELLIGENCE, oTarget);
        if (DEBUG_COMBAT_MOVE) DoDebug("Warblade Battle Skill Disarm bonus (defender)");
    }
    if (GetHasFeat(FEAT_PRC_IMP_DISARM, oPC)) 
	// Check if oPC is the same as oTarget and return immediately
	if (oPC == oTarget)
	{
		FloatingTextStringOnCreature("You can't Disarm yourself.", oPC, FALSE);
		return FALSE;
	}

	if (GetHasFeat(FEAT_PRC_IMP_DISARM, oPC)) 
	{
		nPCAttack += 4;
		nGenerateAoO = FALSE;
		nCounter = FALSE;
	}    

	// Do the AoO for a trip attempt
	if (nGenerateAoO)
	{
		// Perform the Attack
		effect eNone;
		DelayCommand(0.0, PerformAttack(oPC, oTarget, eNone, 0.0, 0, 0, 0, "Attack of Opportunity Hit", "Attack of Opportunity Miss"));    
		if (GetLocalInt(oPC, "PRCCombat_StruckByAttack"))
		{
			FloatingTextStringOnCreature("You have failed at your Disarm Attempt.", oPC, FALSE);
			return FALSE;
		}            
	}

    
    SendMessageToPC(oPC, "Disarm Check: "+IntToString(nPCAttack)+" vs "+IntToString(nTargetAttack));
    // Now the outcome
    if (nPCAttack >= nTargetAttack)
    {
        // Disarm em
        nSucceed = TRUE;
        
        // Unarmed
        if (!GetIsObjectValid(oPCWep))
        {
            object oCopy = CopyObject(oTargetWep, GetLocation(oPC), oPC);
            DestroyObject(oTargetWep);
            SetDroppableFlag(oCopy, TRUE);
            SetStolenFlag(oCopy, FALSE);
        }
        else
        {
            AssignCommand(oTarget, ClearAllActions(TRUE));
			SetDroppableFlag(oTargetWep, TRUE);
            SetStolenFlag(oTargetWep, FALSE);              
            //AssignCommand(oTarget, ActionPutDownItem(oTargetWep));
            ForcePutDown(oTarget, oTargetWep, INVENTORY_SLOT_RIGHTHAND);
        }
        if (GetHasFeat(FEAT_STEAL_AND_STRIKE, oPC))
        {
            int nRight = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC));
            int nLeft  = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC));
            if (nLeft == BASE_ITEM_KUKRI && nRight == BASE_ITEM_RAPIER)      
                PerformAttack(oPC, oTarget, eNone, 0.0, 0, 0, 0, "Steal and Strike Hit", "Steal and Strike Miss", FALSE, OBJECT_INVALID, GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC), TRUE);
        }
    }    
    else if (nCounter) // If you fail, enemy gets a counter attempt
    {
        FloatingTextStringOnCreature("You have failed on your disarm attempt",oPC, FALSE);
        DoDisarm(oTarget, oPC, 0, FALSE, FALSE);
    }
    else
        FloatingTextStringOnCreature("You have failed on your disarm attempt",oPC, FALSE);
        
    // Keep Attacking
    //AssignCommand(oPC, ActionAttack(oTarget));
    // Now we do the rest of the attacks in the round, regardless, remembering to bump down the iteratives
    SetLocalInt(oPC, "CombatMoveAttack", TRUE);
    DelayCommand(5.5, DeleteLocalInt(oPC, "CombatMoveAttack"));
    if (GetBaseAttackBonus(oPC) >= 6) PerformAttackRound(oTarget, oPC, eNone, 0.0, -5);  
    DelayCommand(0.25, AssignCommand(oPC, ActionAttack(oTarget)));

    // Let people know if we made the hit or not
    return nSucceed;
}

void DoTrample(object oPC, object oTarget, location lTarget)
{
    effect eCharge = SupernaturalEffect(EffectMovementSpeedIncrease(99)); // Just to speed things up a bit
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCharge, oPC, 5.5);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_TUMBLE, 50), oPC, 5.5);
    float fLength = GetDistanceBetweenLocations(GetLocation(oPC), lTarget);
    vector vOrigin = GetPosition(oPC);

    // Step one is check to see if we're using oTarget or not
    if (GetIsObjectValid(oTarget))
    {
        lTarget = GetLocation(oTarget);
        fLength = GetDistanceBetweenLocations(GetLocation(oPC), lTarget);
    }
    else
        oTarget = MyFirstObjectInShape(SHAPE_SPELLCYLINDER, fLength, lTarget, TRUE, OBJECT_TYPE_CREATURE, vOrigin); // Only change targets if invalid

    // Move the PC to the location
    AssignCommand(oPC, ClearAllActions(TRUE));
    AssignCommand(oPC, ActionForceMoveToLocation(lTarget, TRUE));
    
    // Loop over targets in the line shape
    while(GetIsObjectValid(oTarget)) // Find the targets
    {
        if(oTarget != oPC && GetIsEnemy(oTarget, oPC)) // Don't overrun friends or yourself
        {
            float fDelay = PRCGetSpellEffectDelay(GetLocation(oPC), oTarget) * 2.5;
            DelayCommand(fDelay, _DoTrampleDamage(oPC, oTarget)); 
        }// end if - Target validity check
    // Get next target
    oTarget = MyNextObjectInShape(SHAPE_SPELLCYLINDER, fLength, lTarget, TRUE, OBJECT_TYPE_CREATURE, vOrigin);
    }// end while - Target loop  
}

void DoShieldBash(object oPC, object oTarget, int nAtk = 0, int nDamage = 0, int nDamageType = 0, int nCharge = FALSE, int nPounce = FALSE, int nSlam = FALSE, int nInstant = FALSE)
{
	object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
	int nType = GetBaseItemType(oShield);
	effect eNone;
	// Can only bash with small or large shields, not tower
	if (nType != BASE_ITEM_LARGESHIELD && nType != BASE_ITEM_SMALLSHIELD) 
	{
		FloatingTextStringOnCreature("You do not have a legal shield equipped!", oPC, FALSE);
		PerformAttackRound(oTarget, oPC, eNone);
		return;
	}	

	int nTWFeat, nPenOn, nPenOff;
	// Check for TWF feats that matter for this
	if(GetHasFeat(FEAT_SUPREME_TWO_WEAPON_FIGHTING, oPC))        nTWFeat = 4;
	else if(GetHasFeat(FEAT_GREATER_TWO_WEAPON_FIGHTING, oPC))   nTWFeat = 3;
	else if(GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oPC))	 nTWFeat = 2;
	else if(GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oPC))	         nTWFeat = 1;
	
	// Number of attacks with the shield. You always get at least one.
	int nAttacks = 1;
    if (nTWFeat == 4) nAttacks = 4;
    else if (nTWFeat == 3) nAttacks = 3;
    else if (nTWFeat == 2) nAttacks = 2;
    
    // Attack penalty for two weapon fighting. Small shields count as light weapons. Large shields as one-handed weapons.
    if(GetHasFeat(FEAT_AGILE_SHIELD_FIGHTER, oPC))
    {
    	nPenOn  = -2;
    	nPenOff = -2;    
    }
    else if (nTWFeat && (nType == BASE_ITEM_SMALLSHIELD || (nType == BASE_ITEM_LARGESHIELD && GetHasFeat(FEAT_OTWF, oPC))))
    {
    	nPenOn  = -2;
    	nPenOff = -2;
    }	
    else if (nTWFeat && nType == BASE_ITEM_LARGESHIELD) // TWF with a One-handed weapon
    {
    	nPenOn  = -4;
    	nPenOff = -4;
    }	    
    else if (nType == BASE_ITEM_SMALLSHIELD) // Light weapon, no TWF
    {
    	nPenOn  = -4;
    	nPenOff = -8;
    }	
    else // One-handed weapon, no TWF
    {
    	nPenOn  = -6;
    	nPenOff = -10;
    }	    
    // Add bashing to attack rolls. _ShieldBashDamage gets it for damage
    nAtk += GetLocalInt(oPC, "BashingEnchant");
    
    // Add in any passed along bonuses
   	nPenOn  += nAtk;
   	nPenOff += nAtk;  
    
	// Do the attacks, including main hand
	//Pouncing Charge
	if (nCharge && nPounce)
	{
		PerformAttackRound(oTarget, oPC, eNone, 0.0, nPenOn, nDamage, nDamageType, FALSE, "Pouncing Charge Hit", "Pouncing Charge Miss", FALSE, FALSE, TRUE);
		int i;
		for(i = 1; i <= nAttacks; i++)    
		{
			// Account for iteratives on TWF
			int nIter = 5-(5*i);
			int nRoll = GetAttackRoll(oTarget, oPC, oShield, 1, 0, nPenOff-nIter);
			if (nRoll)
			{
				_ShieldBashDamage(oPC, oTarget, nRoll, FALSE, nDamage, nDamageType, nType);
				
				// The only way to get here is Shield Charge, so we know they have this effect
				DoTrip(oPC, oTarget, 0, FALSE, FALSE);
			}
		}
	}	
	else if (nCharge && !nPounce) // Charging without pounce, so only one attack
	{
		PerformAttack(oTarget, oPC, eNone, 0.0, nPenOn, nDamage, nDamageType, "Charge Hit", "Charge Miss");

		int nRoll = GetAttackRoll(oTarget, oPC, oShield, 1, 0, nPenOff);
		if (nRoll)
		{
			_ShieldBashDamage(oPC, oTarget, nRoll, FALSE, nDamage, nDamageType, nType);
			// The only way to get here is Shield Charge, so we know they have this effect
			DoTrip(oPC, oTarget, 0, FALSE, FALSE);			
		}
	}
	else if (nSlam) // Shield Slam only
	{
		int nRoll = GetAttackRoll(oTarget, oPC, oShield, 1, 0, nPenOff);
		if (nRoll)
		{
			// GetAttackRoll doesn't set this, so we set it manually
		    SetLocalInt(oTarget, "PRCCombat_StruckByAttack", TRUE);
            DelayCommand(1.0, DeleteLocalInt(oTarget, "PRCCombat_StruckByAttack"));
			_ShieldBashDamage(oPC, oTarget, nRoll, TRUE, nDamage, nDamageType, nType);
			// Shield slam stun
			int nDC = 10 + GetHitDice(oPC)/2 + GetAbilityModifier(ABILITY_STRENGTH, oPC);
			if (!GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT))
			{
				if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NONE))
				{
					ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDazed(), oTarget, 6.0);
				}
			}	
			FloatingTextStringOnCreature("Shield Slam Hit!", oPC, FALSE);
			// If it's a charge and we're here, we've hit with the attack
			if (nCharge) DoTrip(oPC, oTarget, 0, FALSE, FALSE); 
		}
		else
			FloatingTextStringOnCreature("Shield Slam Missed!", oPC, FALSE);
	}	
	else if (nInstant) // Shield Counter only, currently
	{
		int nRoll = GetAttackRoll(oTarget, oPC, oShield, 1, 0, nPenOff);
		if (nRoll)
		{
			// GetAttackRoll doesn't set this, so we set it manually
		    SetLocalInt(oTarget, "PRCCombat_StruckByAttack", TRUE);
            DelayCommand(1.0, DeleteLocalInt(oTarget, "PRCCombat_StruckByAttack"));		
			_ShieldBashDamage(oPC, oTarget, nRoll, TRUE, nDamage, nDamageType, nType);
			// Enemy misses their next attack
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(PSI_IMP_CONCUSSION_BLAST), oTarget);
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectAttackDecrease(20)), oTarget, 3.0);
			FloatingTextStringOnCreature("Shield Counter Hit!", oPC, FALSE);
		}
		else
			FloatingTextStringOnCreature("Shield Counter Missed!", oPC, FALSE);
	}	
	else // No charge, no pounce, so regular combat
	{
		PerformAttackRound(oTarget, oPC, eNone, 0.0, nPenOn, nDamage, nDamageType);
		int i;
		for(i = 1; i <= nAttacks; i++)    
		{
			// Account for iteratives on TWF
			int nIter = 5-(5*i);
			int nRoll = GetAttackRoll(oTarget, oPC, oShield, 1, 0, nPenOff-nIter);
			if (nRoll)
			{
				_ShieldBashDamage(oPC, oTarget, nRoll, FALSE, nDamage, nDamageType, nType);
			}
		}
	}	
	
	// No shield benefit for the next round, unless you have Improved Shield Bash
	if(!GetHasFeat(FEAT_IMPROVED_SHIELD_BASH, oPC)) ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectACDecrease(GetItemACValue(oShield)), oPC, 6.0);
	
    // Target is valid and we know it's an enemy and we're in combat
    DelayCommand(0.25, AssignCommand(oPC, ActionAttack(oTarget)));	
}

void DoShieldCharge(object oPC, object oTarget, int nSlam = FALSE)
{
    // PnP rules use feet, might as well convert it now.
    float fDistance = MetersToFeet(GetDistanceBetweenLocations(GetLocation(oPC), GetLocation(oTarget)));
    if(fDistance >= 10.0)
    {
        // Mark the PC as charging
        SetIsCharging(oPC);
        
        int nPounce = FALSE;
        int nDamageType = DAMAGE_TYPE_BASE_WEAPON;
        int nDamage = _ChargeDamage(oPC);
        int nAttack = _ChargeAttack(oPC, oTarget, nAttack); // This now takes into account charge feats
        effect eNone;

        // Move to the target
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionMoveToObject(oTarget, TRUE));

		// Dread Carapace Totem Bind
		if(GetIsIncarnumUser(oPC))
		{
			if (GetIsMeldBound(oPC, MELD_DREAD_CARAPACE) == CHAKRA_TOTEM || GetIsMeldBound(oPC, MELD_DREAD_CARAPACE) == CHAKRA_DOUBLE_TOTEM) // CHAKRA_TOTEM
			{
		     	location lTargetLocation = GetLocation(oPC);
		     	int nSaveDC = GetMeldshaperDC(oPC, CLASS_TYPE_TOTEMIST, MELD_DREAD_CARAPACE); // MELD_DREAD_CARAPACE
	    
		     	object oDreadTarget = MyFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(60.0), lTargetLocation, FALSE, OBJECT_TYPE_CREATURE);
		     	while(GetIsObjectValid(oDreadTarget))
		     	{
		          	if(GetIsEnemy(oPC, oDreadTarget))
		          	{
		          		if(!PRCMySavingThrow(SAVING_THROW_WILL, oDreadTarget, nSaveDC, SAVING_THROW_TYPE_FEAR))
		          			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectShaken(), oDreadTarget, 6.0);

		          	}
		          	//Select the next target within the spell shape.
		          	oDreadTarget = MyNextObjectInShape(SHAPE_SPHERE, FeetToMeters(60.0), lTargetLocation, FALSE, OBJECT_TYPE_CREATURE);
		        } 
		    }
		}         	
        
        // Flying Kick feat
        if(GetHasFeat(FEAT_FLYING_KICK, oPC) && (GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC) == OBJECT_INVALID)) 
            nDamage += d12();
        if(GetHasFeat(FEAT_SNOW_TIGER_BERSERKER, oPC) && GetIsLightWeapon(oPC)) 
            nPounce = TRUE;                
        if(GetHasFeat(FEAT_CATFOLK_POUNCE, oPC) && GetIsDeniedDexBonusToAC(oTarget, oPC, TRUE)) 
            nPounce = TRUE;    
        if(GetItemPossessedBy(oPC, "WOL_Shishio") == GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC) && GetLocalInt(oPC, "Shishio_Pounce"))    
            nPounce = TRUE;
        if(GetLevelByClass(CLASS_TYPE_CELEBRANT_SHARESS, oPC) >= 5)
        	nPounce = TRUE;
        if(GetRacialType(oPC) == RACIAL_TYPE_MARRUSAULT)
        	nPounce = TRUE;
		//:: Lion of Talisid
		if(GetHasFeat(FEAT_LOT_LIONS_POUNCE, oPC))
			nPounce = TRUE;			
        
        // Checks for a White Raven Stance
        // If it exists, +1 damage/initiator level
        if(GetLocalInt(oPC, "LeadingTheCharge"))
            nDamage += GetLocalInt(oPC, "LeadingTheCharge");
        if(nDamageType == -1) // If the damage type isn't set
        {
            object oWeap = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
            nDamageType = GetWeaponDamageType(oWeap);
        }
        
        float fDelay = FeetToMeters(fDistance)/10;        
		DelayCommand(fDelay, DoShieldBash(oPC, oTarget, nAttack, nDamage, nDamageType, TRUE, nPounce, nSlam));
        DelayCommand(fDelay, _PostCharge(oPC, oTarget));
    }
    else
    {
        FloatingTextStringOnCreature("You are too close to charge " + GetName(oTarget), oPC);
    }
}

//:: Test void
//:: void main (){}