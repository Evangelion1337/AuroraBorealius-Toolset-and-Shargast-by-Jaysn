//:: prc_inc_nat_hb
//::
//:: void main(){}


void DoNaturalWeaponHB(object oPC = OBJECT_SELF);

#include "prc_inc_combat"
#include "prc_inc_template"
/**  
 * Finds a valid enemy target in melee range when the original target is invalid.  
 * Now includes input validation, LOS checks, configurable radius, and target priority.  
 *   
 * @param oPC        The creature seeking a new target  
 * @param oTarget    The original (invalid) target  
 * @param fRadius    Search radius in meters (optional, defaults to melee range)  
 * @return           A valid enemy target or OBJECT_INVALID if none found  
 */  
object GetProperTarget(object oPC, object oTarget, float fRadius = MELEE_RANGE_METERS)  
{  
    // Input validation  
    if(!GetIsObjectValid(oPC))  
    {  
        DoDebug("GetProperTarget(): Invalid oPC parameter");  
        return OBJECT_INVALID;  
    }  
      
    // Use target list system for better target selection  
    PurgeTargetList(oPC);  
      
    location lPC = GetLocation(oPC);  
    object oTest = MyFirstObjectInShape(SHAPE_SPHERE, fRadius, lPC, TRUE, OBJECT_TYPE_CREATURE);  
      
    while(GetIsObjectValid(oTest))  
    {  
        // Basic validation checks  
        if(oTest != oPC &&                                    // Not self  
           GetIsEnemy(oPC, oTest) &&                          // Is enemy  
           GetIsInMeleeRange(oPC, oTest) &&                   // In melee range  
           !GetIsDead(oTest) &&                               // Is alive  
           LineOfSightObject(oPC, oTest))                     // Has line of sight  
        {  
            // Add to target list with priority based on distance (nearest first)  
            AddToTargetList(oTest, oPC, INSERTION_BIAS_DISTANCE, FALSE);  
        }  
          
        oTest = MyNextObjectInShape(SHAPE_SPHERE, fRadius, lPC, TRUE, OBJECT_TYPE_CREATURE);  
    }  
      
    // Get the highest priority target (nearest enemy)  
    object oBestTarget = GetTargetListHead(oPC);  
    PurgeTargetList(oPC);  
      
    if(GetIsObjectValid(oBestTarget))  
    {  
        DoDebug("GetProperTarget(): Selected target " + GetName(oBestTarget) +   
                " for " + GetName(oPC));  
        return oBestTarget;  
    }  
      
    // No valid target found  
    DoDebug("GetProperTarget(): No valid target found for " + GetName(oPC));  
    return OBJECT_INVALID;  
}
/* object GetProperTarget(object oPC, object oTarget)
{
    location lTarget = GetLocation(oPC);
    // Use the function to get the closest creature as a target
    object oAreaTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oAreaTarget))
    {
        if(oAreaTarget != oPC && // Not you. 
           GetIsEnemy(oPC, oAreaTarget) && // Enemies only, please
           GetIsInMeleeRange(oPC, oAreaTarget)) // They must be in melee range
        {
			return oAreaTarget;
        }
    //Select the next target within the spell shape.
    oAreaTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }
    
    return oTarget;
} */

void DoNaturalAttack(object oWeapon)
{
    //if weapon is not valid, abort
    if(!GetIsObjectValid(oWeapon))
        return;

    //    object oTarget = GetAttackTarget();
    object oTarget = GetAttemptedAttackTarget();

    // motu99: The following checks should be made by PerformAttack(), so they are somewhat redundant

    /*
        //no point attacking plot
        if(GetPlotFlag(oTarget))
            return;
    */
	if (DEBUG) DoDebug("DoNaturalAttack oTarget1 "+GetName(oTarget));
    object oPC = OBJECT_SELF;
    
    // Make sure you don't hit yourself. Some idiot didn't check that.
    if (GetIsFriend(oPC, oTarget) || oPC == oTarget)
    	oTarget = GetProperTarget(oPC, oTarget);
    	
    if (DEBUG) DoDebug("DoNaturalAttack oTarget2 "+GetName(oTarget));	
    	
    // if not melee/ranged fighting, abort
    if (!GetIsObjectValid(oTarget))
        return;    	

    // natural attacks are (usually) not ranged attacks, so PerformAttack() will move to a target, if it is out of melee range
    // However, we do not want to run to the target if we are in the midst of doing ranged attacks, e.g. if we have a ranged
    // weapon equipped (and are still out of melee range, so we can effectively do ranged attacks)
    // so check for a ranged weapon in the right hand slot and abort if we have one and are out of melee range
    object oWeaponR = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if(GetIsObjectValid(oWeaponR)
    && GetIsRangedWeaponType(GetBaseItemType(oWeaponR))
    && !GetIsInMeleeRange(oTarget, oPC))
        return;
    /*
        //if not fighting, abort 
        // motu99: PRCGetIsFighting() not only checks. whether GetAttemptedAttackTarget() (relevant for melee attacks) returns a valid object
        // it also checks whether we have attempted to attack a valid target with a spell
        // but spell attacks don't make sense for natural attacks (which are pure melee), so commented out
        if(!PRCGetIsFighting(oPC))
        { 
     DoDebug(COLOR_WHITE + "DoNaturalAttack(): not fighting any more - aborting");
            return;
        }
    */
    
    //null effect
    effect eInvalid;
    string sMessageSuccess;
    string sMessageFailure;
    if(DEBUG)
    {
        sMessageSuccess += GetName(oWeapon);
        //add attack
        sMessageSuccess += " natural attack";
        //copy it to failure
        sMessageFailure = sMessageSuccess;
        //add hit/miss
        sMessageSuccess += " hit";
        sMessageFailure += " miss";
        //add stars around messages
        sMessageSuccess = "*"+sMessageSuccess+"*";
        sMessageFailure = "*"+sMessageFailure+"*";
    }

    //secondary attacks are -5 to hit
    int nAttackMod = -5;
    if (GetHasTemplate(TEMPLATE_GRAVETOUCHED_GHOUL, oPC)) nAttackMod = -2; // This is a standin for multiattack
    /*
        //check for (Improved) Multiattack
        if(GetHasFeat(FEAT_IMPROVED_MULTIATTACK, oPC))
            nAttackMod = 0;
        else if(GetHasFeat(FEAT_MULTIATTACK, oPC))
            nAttackMod = -2;
    */
    //secondary attacks are half strength (we use offhand for this)

    // set the prc combat mode
    int bCombatMode = PRC_COMBATMODE_HB & PRC_COMBATMODE_ALLOW_TARGETSWITCH & PRC_COMBATMODE_ABORT_WHEN_OUT_OF_RANGE;
    
    int nEssentia = GetEssentiaInvested(oPC, MELD_GIRALLON_ARMS);
    if (nEssentia) IPSafeAddItemProperty(oWeapon, ItemPropertyEnhancementBonus(nEssentia), 9999.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);	
    int nStrHalf = GetAbilityModifier(ABILITY_STRENGTH, oPC)/2;
    nStrHalf = nStrHalf * -1;
    
	if(DEBUG) DoDebug(PRC_TEXT_WHITE + "initiating a secondary natural attack with "+GetName(oWeapon)+", attack mod " + IntToString(nAttackMod) + ", nStrHalf " + IntToString(nStrHalf));     

    PerformAttack(oTarget, 
        oPC,                //
        eInvalid,           //effect eSpecialEffect,
        0.0,                //float eDuration = 0.0
        nAttackMod,         //int iAttackBonusMod = 0
        nStrHalf,                  //int iDamageModifier = Half strength
        DAMAGE_TYPE_SLASHING,    //int iDamageType = DAMAGE_TYPE_SLASHING, otherwise it uses magical damage.
        sMessageSuccess,    //sMessageSuccess
        sMessageFailure,    //sMessageFailure
        FALSE,              //int iTouchAttackType = FALSE
        oWeaponR,      // we should have something in the right hand (might need it for some calculations)
        oWeapon,      // we put the creature weapon in the left hand slot 
        FALSE,             //offhand override (for half strength)
        bCombatMode // prc scripted combat mode
        );
}

void DoOffhandAttack(int nAttackMod)
{
    object oPC = OBJECT_SELF;
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);


    // check for offhand or double sided weapon, if not - return
    if (!GetIsOffhandWeapon(oWeapon))
    {
        object oWeaponR = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
        if (!GetIsDoubleSidedWeapon(oWeaponR))
            return;
        oWeapon = oWeaponR;
    }

    //    object oTarget = GetAttackTarget(); 
    object oTarget = GetAttemptedAttackTarget(); 

    // motu99: The following checks should be made by PerformAttack(), so they are somewhat redundant
    /*
        //no point attacking plot
        if(GetPlotFlag(oTarget))
            return;
    */
    // Make sure you don't hit yourself. Some idiot didn't check that.
    if (GetIsFriend(oPC, oTarget) || oPC == oTarget)
    	oTarget = GetProperTarget(oPC, oTarget);     
    
    // if not melee fighting, abort
    if (!GetIsObjectValid(oTarget))
        return;
              
    /*
        //if not fighting, abort 
        if(!PRCGetIsFighting(oPC))
        {
            DoDebug(COLOR_WHITE + "DoOffhandAttack(): not fighting any more - aborting");
            return;
        }
    */
    string sMessageSuccess;
    string sMessageFailure;
    if (DEBUG)
    {
        sMessageSuccess += GetName(oWeapon);
        //add attack
        sMessageSuccess += " scripted offhand";
        //copy it to failure
        sMessageFailure = sMessageSuccess;
        //add hit/miss
        sMessageSuccess += " hit";
        sMessageFailure += " miss";
        //add stars around messages
        sMessageSuccess = "*"+sMessageSuccess+"*";
        sMessageFailure = "*"+sMessageFailure+"*";
    }
    
    //null effect
    effect eInvalid;

    // set the prc combat mode
    int bCombatMode = PRC_COMBATMODE_HB & PRC_COMBATMODE_ALLOW_TARGETSWITCH & PRC_COMBATMODE_ABORT_WHEN_OUT_OF_RANGE;

    if (DEBUG) DoDebug(PRC_TEXT_WHITE + "initiating an overflow offhand attack with "+GetName(oWeapon)+" and attack mod "+IntToString(nAttackMod));     

    PerformAttack(oTarget, 
        oPC,                //
        eInvalid,           //effect eSpecialEffect,
        0.0,                //float eDuration = 0.0
        nAttackMod,         //int iAttackBonusMod = 0
        0,                  //int iDamageModifier = 0
        DAMAGE_TYPE_SLASHING,    //int iDamageType = DAMAGE_TYPE_SLASHING, otherwise it uses magical damage.
        sMessageSuccess,    //sMessageSuccess,    //string sMessageSuccess = ""   
        sMessageFailure,    //sMessageFailure,    //string sMessageFailure = ""
        FALSE,              //int iTouchAttackType = FALSE
        oWeapon,      //object oRightHandOverride = OBJECT_INVALID,
        oWeapon,      //object oLeftHandOverride = OBJECT_INVALID,
        1,                  // offhand attack 
        bCombatMode     // prc combat mode
        );
}

void DoOverflowOnhandAttack(int nAttackMod)
{
    object oPC = OBJECT_SELF;
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);

    //if weapon is not valid, abort    
    if(!GetIsObjectValid(oWeapon))
        return;

 //      object oTarget = GetAttackTarget(); 
    object oTarget = GetAttemptedAttackTarget(); 

    // motu99: The following checks should be made by PerformAttack(), so they are somewhat redundant
    /*
        //no point attacking plot
        if(GetPlotFlag(oTarget))
            return;
    */
    // Make sure you don't hit yourself. Some idiot didn't check that.
    if (GetIsFriend(oPC, oTarget) || oPC == oTarget)
    	oTarget = GetProperTarget(oPC, oTarget);    
    
    // if not melee fighting, abort
    if (!GetIsObjectValid(oTarget))
        return;
        
    /*
        //if not fighting, abort 
        if(!PRCGetIsFighting(oPC))
        {
            DoDebug(COLOR_WHITE + "DoOverflowOnhandAttack(): not fighting any more - aborting");
            return;
        }
    */
    string sMessageSuccess;
    string sMessageFailure;
    if (DEBUG)
    {
        sMessageSuccess += GetName(oWeapon);
        //add attack
        sMessageSuccess += " scripted overflow";
        //copy it to failure
        sMessageFailure = sMessageSuccess;
        //add hit/miss
        sMessageSuccess += " hit";
        sMessageFailure += " miss";
        //add stars around messages
        sMessageSuccess = "*"+sMessageSuccess+"*";
        sMessageFailure = "*"+sMessageFailure+"*";
    }
    
    //null effect
    effect eInvalid;

    // set the prc combat mode
    int bCombatMode = PRC_COMBATMODE_HB & PRC_COMBATMODE_ALLOW_TARGETSWITCH & PRC_COMBATMODE_ABORT_WHEN_OUT_OF_RANGE;

    if (DEBUG) DoDebug(PRC_TEXT_WHITE+"initiating an overflow onhand attack with "+GetName(oWeapon)+" and attack mod "+IntToString(nAttackMod));     

    PerformAttack(oTarget, 
        oPC,                //
        eInvalid,           //effect eSpecialEffect,
        0.0,                //float eDuration = 0.0
        nAttackMod,         //int iAttackBonusMod = 0
        0,                 //int iDamageModifier = 0
        DAMAGE_TYPE_SLASHING,    //int iDamageType = DAMAGE_TYPE_SLASHING, otherwise it uses magical damage.
        sMessageSuccess,//sMessageSuccess,    //string sMessageSuccess = ""   
        sMessageFailure,//sMessageFailure,    //string sMessageFailure = ""
        FALSE,              //int iTouchAttackType = FALSE
        oWeapon,            //object oRightHandOverride = OBJECT_INVALID,
        OBJECT_INVALID,      //object oLeftHandOverride = OBJECT_INVALID
        0,
        bCombatMode
        );
}

/* void DoNaturalWeaponHB(object oPC = OBJECT_SELF)
{
    //not in combat, abort
    if(!GetIsInCombat(oPC))
        return;

	if(DEBUG) DoDebug("prc_inc_nat_hb: entered DoNaturalWeaponHB");

    float fDelay = 0.1 + IntToFloat(Random(10))/100.0;

    //no natural weapons, abort
    //in a different form, abort for now fix it later
if(array_exists(oPC, ARRAY_NAT_SEC_WEAP_RESREF)
    && !GetIsPolyMorphedOrShifted(oPC))
{
    DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: creature has natural secondary weapons");
    UpdateSecondaryWeaponSizes(oPC);
    int i;
    while(i < array_get_size(oPC, ARRAY_NAT_SEC_WEAP_RESREF))
    {
        string sResRef = array_get_string(oPC, ARRAY_NAT_SEC_WEAP_RESREF, i);
        if(sResRef != "")
        {
            // Get stored weapon object, or create if doesn't exist
            object oWeapon = GetLocalObject(oPC, "NAT_SEC_WEAP_" + sResRef);
            
            if(!GetIsObjectValid(oWeapon))
            {
                DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: creating and storing creature weapon " + sResRef);
                oWeapon = CreateItemOnObject(sResRef, oPC);
                
                if(!GetIsObjectValid(oWeapon))
                {
                    DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: ERROR - CreateItemOnObject FAILED for " + sResRef);
                }
                else
                {
                    DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: SUCCESS - weapon created, tag=" + GetTag(oWeapon) + ", name=" + GetName(oWeapon));
                    SetIdentified(oWeapon, TRUE);
                    SetLocalObject(oPC, "NAT_SEC_WEAP_" + sResRef, oWeapon);
                }
            }
            else
            {
                DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: using stored creature weapon object");
            }

            // Double-check validity before scheduling
            if(GetIsObjectValid(oWeapon))
            {
                DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: scheduling a secondary natural attack with "+GetName(oWeapon)+" at delay "+FloatToString(fDelay)); 
                DelayCommand(fDelay, DoNaturalAttack(oWeapon));

                fDelay += 2.05;
                if(fDelay > 6.0)
                    fDelay -= 6.0;
            }
            else
            {
                DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: ERROR - weapon object is INVALID, cannot schedule attack");
            }
        }
        i++;
    }
}


    int iMod = 5;   // motu99: added check for monk weapon
    if(GetHasMonkWeaponEquipped(oPC)) iMod = 3;

    // check for overflow (main hand) attacks
    int nOverflowAttackCount = GetLocalInt(oPC, "OverflowBaseAttackCount");
    if(nOverflowAttackCount)
    {
        int i;
        // the first overflow attack would be the seventh main hand attack, at an AB of -30
        int nAttackPenalty = -6 * iMod; // -30 for normal bab, -18 for monks
        // DoDebug("DoNaturalWeaponHB(): number of scripted overflow attacks: "+IntToString(nOverflowAttackCount));
        for(i = 0; i < nOverflowAttackCount; i++)
        {
            // DoDebug(COLOR_WHITE + "DoNaturalWeaponHB(): scheduling a scripted overflow attack with attack mod "+IntToString(nAttackPenalty)+" at delay "+FloatToString(fDelay)); 
            
            // motu99: see comment above why this is commented out
                //AssignCommand(oPC, DelayCommand(fDelay, DoOverflowOnhandAttack(nAttackPenalty)));
           
            DelayCommand(fDelay, DoOverflowOnhandAttack(nAttackPenalty));

            //calculate the delay to use
            fDelay += 2.05;
            if(fDelay > 6.0)
                fDelay -= 6.0;
            //calculate new attack penalty
            nAttackPenalty -= iMod; // motu99: usually -5, for monks -3 (unarmed or kama)
        }
    }

    // motu99: this is only here for debugging in order to  test PerformAttackRound()
    // must be deleted after debugging!!!
    //if (GetPRCSwitch(PRC_PNP_TRUESEEING)) DelayCommand(0.01, DoOffhandAttackRound());


    // check for overflow offhand attacks
    int nOffhandAttackCount = GetLocalInt(oPC, "OffhandOverflowAttackCount");
//    if (DEBUG) DoDebug("DoNaturalWeaponHB: number of scripted offhand attacks = "+IntToString(nOffhandAttackCount));
    if(nOffhandAttackCount)
    {
        int i;
        int nAttackPenalty = -2 * iMod;  // offhand attacks always come at -5 per additional attack (but for monks we assume -3) 
        for(i = 0; i < nOffhandAttackCount; i++)
        {
            // DoDebug(COLOR_WHITE + "DoNaturalWeaponHB(): scheduling a scripted offhand attack with attack mod "+IntToString(nAttackPenalty)+" at delay "+FloatToString(fDelay)); 

            DelayCommand(fDelay, DoOffhandAttack(nAttackPenalty));

            //calculate the delay to use
            fDelay += 2.05;
            if(fDelay > 6.0)
                fDelay -= 6.0;
            //calculate new attack penalty
            nAttackPenalty -= iMod;
        }
    }
}
 */

void DoNaturalWeaponHB(object oPC = OBJECT_SELF)
{
    //not in combat, abort
    if(!GetIsInCombat(oPC))
        return;

	if(DEBUG) DoDebug("prc_inc_nat_hb: entered DoNaturalWeaponHB");

    float fDelay = 0.1 + IntToFloat(Random(10))/100.0;

    //no natural weapons, abort
    //in a different form, abort for now fix it later
    if(array_exists(oPC, ARRAY_NAT_SEC_WEAP_RESREF)
        && !GetIsPolyMorphedOrShifted(oPC))
    {
        if(DEBUG) DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: creature has natural secondary weapons");
        UpdateSecondaryWeaponSizes(oPC);
        int i;
        while(i < array_get_size(oPC, ARRAY_NAT_SEC_WEAP_RESREF))
        {
            //get the resref to use
            string sResRef = array_get_string(oPC, ARRAY_NAT_SEC_WEAP_RESREF, i);
            //if null, move to next
            if(sResRef != "")
            {
                //get the created item
                object oWeapon = GetObjectByTag(sResRef);
                if(!GetIsObjectValid(oWeapon))
                {
                    object oLimbo = GetObjectByTag("HEARTOFCHAOS");
                    location lLimbo = GetLocation(oLimbo);
                    if(!GetIsObjectValid(oLimbo))
                        lLimbo = GetStartingLocation();
                    oWeapon = CreateObject(OBJECT_TYPE_ITEM, sResRef, lLimbo);
					if(DEBUG) DoDebug(PRC_TEXT_WHITE + "prc_inc_nat_hb >> DoNaturalWeaponHB: creature weapon object found!!!");
                }
				
				// Check for enhancements after creating the weapon object 
				int nEnhance = GetLocalInt(oPC, "PRC_NAT_WEAPON_ENHANCE");  
				if(nEnhance > 0)  
				{  
					
					DoDebug(PRC_TEXT_WHITE + "prc_inc_nat_hb >> DoNaturalWeaponHB: Applying enhancement.");
					float fDuration = GetLocalFloat(oPC, "PRC_NAT_WEAPON_ENH_DUR");  
					IPSafeAddItemProperty(oWeapon, ItemPropertyEnhancementBonus(nEnhance), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);  
				}
	
				if(DEBUG) DoDebug("prc_inc_nat_hb >> DoNaturalWeaponHB: scheduling a secondary natural attack with "+GetName(oWeapon)+" at delay "+FloatToString(fDelay)); 
                //do the attack within a delay                
                // motu99: commented this out; AssignCommand ist not needed, because OBJECT_SELF is oPC - using AssignCommand will only degrade performance
                //AssignCommand(oPC, DelayCommand(fDelay, DoNaturalAttack(oWeapon)));               

                DelayCommand(fDelay, DoNaturalAttack(oWeapon));

                //calculate the delay to use next time
                fDelay += 2.05;
                if(fDelay > 6.0)
                fDelay -= 6.0;
            }
            i++;
        }
    }

    int iMod = 5;   // motu99: added check for monk weapon
    if(GetHasMonkWeaponEquipped(oPC)) iMod = 3;

    // check for overflow (main hand) attacks
    int nOverflowAttackCount = GetLocalInt(oPC, "OverflowBaseAttackCount");
    if(nOverflowAttackCount)
    {
        int i;
        // the first overflow attack would be the seventh main hand attack, at an AB of -30
        int nAttackPenalty = -6 * iMod; // -30 for normal bab, -18 for monks
        // DoDebug("DoNaturalWeaponHB(): number of scripted overflow attacks: "+IntToString(nOverflowAttackCount));
        for(i = 0; i < nOverflowAttackCount; i++)
        {
            // DoDebug(COLOR_WHITE + "DoNaturalWeaponHB(): scheduling a scripted overflow attack with attack mod "+IntToString(nAttackPenalty)+" at delay "+FloatToString(fDelay)); 
            
			// motu99: see comment above why this is commented out
            //    AssignCommand(oPC, DelayCommand(fDelay, DoOverflowOnhandAttack(nAttackPenalty)));
            
            DelayCommand(fDelay, DoOverflowOnhandAttack(nAttackPenalty));

            //calculate the delay to use
            fDelay += 2.05;
            if(fDelay > 6.0)
                fDelay -= 6.0;
            //calculate new attack penalty
            nAttackPenalty -= iMod; // motu99: usually -5, for monks -3 (unarmed or kama)
        }
    }

    // motu99: this is only here for debugging in order to  test PerformAttackRound()
    // must be deleted after debugging!!!
    //if (GetPRCSwitch(PRC_PNP_TRUESEEING)) DelayCommand(0.01, DoOffhandAttackRound());


    // check for overflow offhand attacks
    int nOffhandAttackCount = GetLocalInt(oPC, "OffhandOverflowAttackCount");
//    if (DEBUG) DoDebug("DoNaturalWeaponHB: number of scripted offhand attacks = "+IntToString(nOffhandAttackCount));
    if(nOffhandAttackCount)
    {
        int i;
        int nAttackPenalty = -2 * iMod;  // offhand attacks always come at -5 per additional attack (but for monks we assume -3) 
        for(i = 0; i < nOffhandAttackCount; i++)
        {
            // DoDebug(COLOR_WHITE + "DoNaturalWeaponHB(): scheduling a scripted offhand attack with attack mod "+IntToString(nAttackPenalty)+" at delay "+FloatToString(fDelay)); 

            DelayCommand(fDelay, DoOffhandAttack(nAttackPenalty));

            //calculate the delay to use
            fDelay += 2.05;
            if(fDelay > 6.0)
                fDelay -= 6.0;
            //calculate new attack penalty
            nAttackPenalty -= iMod;
        }
    }
}


/* 
 * motu99's test functions. Not actually used by PRC scripts 
 */

// motu99: This is only for test purposes (in order to test PerformAttackRound())
void DoOffhandAttackRound(object oPC = OBJECT_SELF)
{
 //    object oTarget = GetAttackTarget(); 
    object oTarget = GetAttemptedAttackTarget(); 

    // motu99: The following checks should be made by PerformAttack(), so they are somewhat redundant
/*
    //no point attacking plot
    if(GetPlotFlag(oTarget))
        return;
*/
    // if not melee fighting, abort
    if (!GetIsObjectValid(oTarget))
        return;
/*
    //if not fighting, abort 
    if(!PRCGetIsFighting(oPC))
    {
        DoDebug(COLOR_WHITE + "DoOffhandAttack(): not fighting any more - aborting");
        return;
    }
*/
    string sMessageSuccess;
    string sMessageFailure;
    if (DEBUG)
    {
//      sMessageSuccess += GetName(oWeapon);
        //add attack
//      sMessageSuccess += " scripted offhand";
        //copy it to failure
//      sMessageFailure = sMessageSuccess;
        //add hit/miss
        sMessageSuccess += "s hit";
        sMessageFailure += "s miss";
        //add stars around messages
        sMessageSuccess = "*"+sMessageSuccess+"*";
        sMessageFailure = "*"+sMessageFailure+"*";
    }
    
    //null effect
    effect eInvalid;

    // set the prc combat mode
    int bCombatMode = PRC_COMBATMODE_HB & PRC_COMBATMODE_ALLOW_TARGETSWITCH & PRC_COMBATMODE_ABORT_WHEN_OUT_OF_RANGE;

    DoDebug(PRC_TEXT_WHITE + "initiating an overflow offhand attack round");    

    PerformAttackRound(oTarget, // object oDefender
        oPC, // object oAttacker,
        eInvalid, // effect eSpecialEffect,
        0.0, // float eDuration = 0.0,
        0, // int iAttackBonusMod = 0,
        0, // int iDamageModifier = 0,
        0, //    int iDamageType = 0,
        TRUE, // int bEffectAllAttacks = FALSE,
        sMessageSuccess, // string sMessageSuccess = "",
        sMessageFailure, // string sMessageFailure = "",
        0, // int bApplyTouchToAll = FALSE,
        0, // int iTouchAttackType = FALSE,
        0, //int bInstantAttack = FALSE);
        bCombatMode // CombatMode
        );  
}
