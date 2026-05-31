//::///////////////////////////////////////////////
//:: Psionics include: Metapsionics
//:: psi_inc_metapsi
//::///////////////////////////////////////////////
/** @file
    Defines functions for handling metapsionics.

    @author Ornedan
    @date   Created - 2005.11.18
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// Constants are provided via psi_inc_core

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines the metapsionics used in this manifestation of a power
 * and the cost added by their use.
 *
 * @param manif         The manifestation data related to this particular manifesation
 * @param nMetaPsiFlags An integer containing a set of bitflags that determine
 *                      which metapsionic powers may be used with the power being manifested
 *
 * @return              The manifestation data, modified to account for the metapsionics
 */
struct manifestation EvaluateMetapsionics(struct manifestation manif, int nMetaPsiFlags);

/**
 * Calls UsePsionicFocus() on the manifester to pay for psionics focus
 * expenditure caused by metapsionics use in the power being currently
 * manifested.
 * Also informs the manifester which metapsionics were actually used
 * if the manifestation was successfull.
 *
 * @param manif The manifestation data related to this particular manifesation
 * @return      The manifestation data, modified to turn off those metapsionics
 *              the manifester could not pay focus for
 */
struct manifestation PayMetapsionicsFocuses(struct manifestation manif);

/**
 * Calculates a power's damage based on the given dice and metapsionics.
 *
 * @param nDieSize            Size of the dice to use
 * @param nNumberOfDice       Amount of dice to roll
 * @param manif               The manifestation data related to this particular manifesation
 * @param nBonus              A bonus amount of damage to add into the total once
 * @param nBonusPerDie        A bonus amount of damage to add into the total for each die rolled
 * @param bDoesHPDamage       Whether the power deals hit point damage, or some other form of point damage
 * @param bIsRayOrRangedTouch Whether the power's use involves a ranged touch attack roll or not
 * @return                    The amount of damage the power should deal
 */
int MetaPsionicsDamage(struct manifestation manif, int nDieSize, int nNumberOfDice, int nBonus = 0,
                       int nBonusPerDie = 0, int bDoesHPDamage = FALSE, int bIsRayOrRangedTouch = FALSE);

/**
 * Accounts for the effects of Widen Power on the area size variables
 * of a power, if it is active.
 *
 * @param fBase The base value of the power's area size variable
 * @param manif The manifestation data related to this particular manifesation
 * @return      The base modified by whether Widen Power was active.
 *              If it was, the returned value is twice fBase, otherwise
 *              it's fBase
 */
float EvaluateWidenPower(struct manifestation manif, float fBase);

/**
 * Builds the list of a power's secondary targets for Chain Power.
 * The list will be empty if Chain Power is not active.
 * The list is stored in a local array on the manifester named
 * PRC_CHAIN_POWER_ARRAY. It will be automatically deleted at the end of
 * current script unless otherwise specified.
 *
 * NOTE: This only builds the list of targets, all effects have to be
 * applied by the powerscript.
 *
 * @param manif          The manifestation data related to this particular manifesation
 * @param oPrimaryTarget The main target of the power
 * @param bAutoDelete    Whether the targets array should be automatically cleared via a
 *                       DelayCommand(0.0f) call.
 */
void EvaluateChainPower(struct manifestation manif, object oPrimaryTarget, int bAutoDelete = TRUE);

/**
 * Determines the target the second ray fired by a split psionic ray strikes.
 * The target is the one with the highest HD among eligible targets, ie, ones
 * withing 30' of the main target.
 *
 * @param manif          The manifestation data related to this particular manifesation
 * @param oPrimaryTarget The target of the main ray
 *
 * @return               The secondary target the power should affect. OBJECT_INVALID, if
 *                       none were found, or if Split Psionic Ray was not active.
 */
object GetSplitPsionicRayTarget(struct manifestation manif, object oPrimaryTarget);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "psi_inc_core"
#include "psi_inc_psifunc"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * @param nCost     The base cost of the metapsionic power to calculate the actual cost for
 * @param nIMPsiRed The amount the PP cost might be reduced by due to Improved Metapsionics feats
 * @param bUseSum   Whether to account for Improved Metapsionics here or not
 * @return          Either nCost or the greater of nCost - nIMPsiRed and 1
 */
int _GetMetaPsiPPCost(int nCost, int nIMPsiRed, int bUseSum)
{
    return nCost <= 2 ? // Metapsionic powers costing 2 or less are not affected by Improved Metapsionics
            nCost :
             bUseSum ? nCost :
             // When calculating Improved Metapsionics separately, it cannot make the cost of a single metapsionic use go below 1
             PRCMax(nCost - nIMPsiRed, 1);
}

/** Internal function.
 * A void wrapper for array_delete.
 *
 * @param oManifester A creature that just manifested a power that determined
 *                    it's targets using EvaluateChainPower
 */
void _DeleteChainArray(object oManifester)
{
    array_delete(oManifester, PRC_CHAIN_POWER_ARRAY);
}

/** Internal function.
 * Calculates whether adding a metapsi with the given cost would cause ML cap to be exceeded.
 */
int _GetWillExceedCap(struct manifestation manif, int nTotal, int nCost, int nIMPsiRed, int bUseSum)
{
    return (manif.nManifesterLevel
             - (manif.nPPCost
              + (bUseSum ? (_GetMetaPsiPPCost(nTotal + nCost, nIMPsiRed, FALSE)) : (nTotal + _GetMetaPsiPPCost(nCost, nIMPsiRed, FALSE)))
                )
            )
            >= 0;
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct manifestation EvaluateMetapsionics(struct manifestation manif, int nMetaPsiFlags)
{
    // Total PP cost of metapsionics used
    int nMetaPsiPP = 0;
    // A debug variable to make a power ignore normal use constraints
    int bIgnoreConstr = (DEBUG) ? GetLocalInt(manif.oManifester, PRC_DEBUG_IGNORE_CONSTRAINTS) : FALSE;
    // A switch value that governs how Improved Metapsionics epic feat works
    int bUseSum = GetPRCSwitch(PRC_PSI_IMP_METAPSIONICS_USE_SUM);
    // A personal switch values that determines whether we should make an effort to attempt not to exceed PP cap
    int bAvoidCap = GetPersistantLocalInt(manif.oManifester, PRC_PLAYER_SWITCH_AUTOMETAPSI) && !bIgnoreConstr;
    // Epic feat Improved Metapsionics - 2 PP per.
    int nImpMetapsiReduction, i = FEAT_IMPROVED_METAPSIONICS_1;
    while(i <= FEAT_IMPROVED_METAPSIONICS_10 && GetHasFeat(i, manif.oManifester))
    {
        nImpMetapsiReduction += 2;
        i++;
    }

    /* Calculate the added cost from metapsionics and set the use markers for the powers used */

    // Quicken Power - special handling
    if(GetLocalInt(manif.oManifester, PRC_POWER_IS_QUICKENED))
    {
        // If Quicken could not have been used, the manifestation fails
        if(!(manif.nPsiFocUsesRemain > 0 || bIgnoreConstr))
            manif.bCanManifest = FALSE;

        nMetaPsiPP += _GetMetaPsiPPCost(METAPSIONIC_QUICKEN_COST, nImpMetapsiReduction, bUseSum);
        manif.bQuicken = TRUE;
        manif.nPsiFocUsesRemain--;

        // Delete the marker var
        DeleteLocalInt(manif.oManifester, PRC_POWER_IS_QUICKENED);
    }

    if((nMetaPsiFlags & METAPSIONIC_CHAIN)                   && // The power allows this metapsionic to apply
       GetLocalInt(manif.oManifester, METAPSIONIC_CHAIN_VAR) && // The manifester is using the metapsionic
       (manif.nPsiFocUsesRemain > 0 || bIgnoreConstr)        && // The manifester can pay the psionic focus expenditure
       (!bAvoidCap || _GetWillExceedCap(manif, nMetaPsiPP, METAPSIONIC_CHAIN_COST, nImpMetapsiReduction, bUseSum)) // ML cap won't be exceeded. Or we don't care about exceeding it
       )
    {
        nMetaPsiPP += _GetMetaPsiPPCost(METAPSIONIC_CHAIN_COST, nImpMetapsiReduction, bUseSum);
        manif.bChain = TRUE;
        manif.nPsiFocUsesRemain--;
    }
    if((nMetaPsiFlags & METAPSIONIC_EMPOWER)                    &&
        GetLocalInt(manif.oManifester, METAPSIONIC_EMPOWER_VAR) &&
        (manif.nPsiFocUsesRemain > 0 || bIgnoreConstr)          &&
        (!bAvoidCap || _GetWillExceedCap(manif, nMetaPsiPP, METAPSIONIC_EMPOWER_COST, nImpMetapsiReduction, bUseSum))
        )
    {
        nMetaPsiPP += _GetMetaPsiPPCost(METAPSIONIC_EMPOWER_COST, nImpMetapsiReduction, bUseSum);
        manif.bEmpower = TRUE;
        manif.nPsiFocUsesRemain--;
    }
    if((nMetaPsiFlags & METAPSIONIC_EXTEND)                   &&
       GetLocalInt(manif.oManifester, METAPSIONIC_EXTEND_VAR) &&
       (manif.nPsiFocUsesRemain > 0 || bIgnoreConstr)         &&
       (!bAvoidCap || _GetWillExceedCap(manif, nMetaPsiPP, METAPSIONIC_EXTEND_COST, nImpMetapsiReduction, bUseSum))
       )
    {
        nMetaPsiPP += _GetMetaPsiPPCost(METAPSIONIC_EXTEND_COST, nImpMetapsiReduction, bUseSum);
        manif.bExtend = TRUE;
        manif.nPsiFocUsesRemain--;
    }
    if((nMetaPsiFlags & METAPSIONIC_MAXIMIZE)                   &&
       GetLocalInt(manif.oManifester, METAPSIONIC_MAXIMIZE_VAR) &&
       (manif.nPsiFocUsesRemain > 0 || bIgnoreConstr)           &&
       (!bAvoidCap || _GetWillExceedCap(manif, nMetaPsiPP, METAPSIONIC_MAXIMIZE_COST, nImpMetapsiReduction, bUseSum))
       )
    {
        nMetaPsiPP += _GetMetaPsiPPCost(METAPSIONIC_MAXIMIZE_COST, nImpMetapsiReduction, bUseSum);
        manif.bMaximize = TRUE;
        manif.nPsiFocUsesRemain--;
    }
    if((nMetaPsiFlags & METAPSIONIC_SPLIT)                   &&
       GetLocalInt(manif.oManifester, METAPSIONIC_SPLIT_VAR) &&
       (manif.nPsiFocUsesRemain > 0 || bIgnoreConstr)        &&
       (!bAvoidCap || _GetWillExceedCap(manif, nMetaPsiPP, METAPSIONIC_SPLIT_COST, nImpMetapsiReduction, bUseSum))
       )
    {
        nMetaPsiPP += _GetMetaPsiPPCost(METAPSIONIC_SPLIT_COST, nImpMetapsiReduction, bUseSum);
        manif.bSplit = TRUE;
        manif.nPsiFocUsesRemain--;
    }
    if((nMetaPsiFlags & METAPSIONIC_TWIN)                   &&
       GetLocalInt(manif.oManifester, METAPSIONIC_TWIN_VAR) &&
       (manif.nPsiFocUsesRemain > 0 || bIgnoreConstr)       &&
       (!bAvoidCap || _GetWillExceedCap(manif, nMetaPsiPP, METAPSIONIC_TWIN_COST, nImpMetapsiReduction, bUseSum))
       )
    {
        nMetaPsiPP += _GetMetaPsiPPCost(METAPSIONIC_TWIN_COST, nImpMetapsiReduction, bUseSum);
        manif.bTwin = TRUE;
        manif.nPsiFocUsesRemain--;
    }
    if((nMetaPsiFlags & METAPSIONIC_WIDEN)                   &&
       GetLocalInt(manif.oManifester, METAPSIONIC_WIDEN_VAR) &&
       (manif.nPsiFocUsesRemain > 0 || bIgnoreConstr)        &&
       (!bAvoidCap || _GetWillExceedCap(manif, nMetaPsiPP, METAPSIONIC_WIDEN_COST, nImpMetapsiReduction, bUseSum))
       )
    {
        nMetaPsiPP += _GetMetaPsiPPCost(METAPSIONIC_WIDEN_COST, nImpMetapsiReduction, bUseSum);
        manif.bWiden = TRUE;
        manif.nPsiFocUsesRemain--;
    }

    // Add in the cost of the metapsionics uses
    manif.nPPCost += _GetMetaPsiPPCost(nMetaPsiPP, nImpMetapsiReduction, !bUseSum); // A somewhat hacky use of the function, but eh, it works

    return manif;
}


struct manifestation PayMetapsionicsFocuses(struct manifestation manif)
{
    // A debug variable to make a power ignore normal use constraints
    int bIgnoreConstraints = (DEBUG) ? GetLocalInt(manif.oManifester, PRC_DEBUG_IGNORE_CONSTRAINTS) : FALSE;

    // The string to send to the user
    string sInform = "";

    /* Check each of the metapsionics and pay focus for each active one. If for some reason the
     * manifester cannot pay focus, deactivate the metapsionic. No PP refunds, though, since
     * the system attempts to keep track of how many focuses the user has available
     * and shouldn't allow them to exceed that count. It happening is therefore a bug.
     */

    // Quicken Power, special handling
    if(manif.bQuicken)
    {
        if(!UsePsionicFocus(manif.oManifester) && !bIgnoreConstraints)
        {
            if(DEBUG) DoDebug(DebugObject2Str(manif.oManifester) + " unable to pay psionic focus for Quicken Power!");
            // If Quicken could not have been used, the manifestation fails
            manif.bCanManifest = FALSE;
        }
        else
            sInform += (sInform == "" ? "": ", ") + GetStringByStrRef(16826650); // "Quickened"
    }
    if(manif.bChain)
    {
        if(!UsePsionicFocus(manif.oManifester) && !bIgnoreConstraints)
        {
            if(DEBUG) DoDebug(DebugObject2Str(manif.oManifester) + " unable to pay psionic focus for Chain Power!");
            manif.bChain = FALSE;
        }
        else
            sInform += (sInform == "" ? "": ", ") + GetStringByStrRef(16826631); // "Chained"
    }
    if(manif.bEmpower)
    {
        if(!UsePsionicFocus(manif.oManifester) && !bIgnoreConstraints)
        {
            if(DEBUG) DoDebug(DebugObject2Str(manif.oManifester) + " unable to pay psionic focus for Empower Power!");
            manif.bEmpower = FALSE;
        }
        else
            sInform += (sInform == "" ? "": ", ") + GetStringByStrRef(16826632); // "Empowered"
    }
    if(manif.bExtend)
    {
        if(!UsePsionicFocus(manif.oManifester) && !bIgnoreConstraints)
        {
            if(DEBUG) DoDebug(DebugObject2Str(manif.oManifester) + " unable to pay psionic focus for Extend Power!");
            manif.bExtend = FALSE;
        }
        else
            sInform += (sInform == "" ? "": ", ") + GetStringByStrRef(16826633); // "Extended"
    }
    if(manif.bMaximize)
    {
        if(!UsePsionicFocus(manif.oManifester) && !bIgnoreConstraints)
        {
            if(DEBUG) DoDebug(DebugObject2Str(manif.oManifester) + " unable to pay psionic focus for Maximize Power!");
            manif.bMaximize = FALSE;
        }
        else
            sInform += (sInform == "" ? "": ", ") + GetStringByStrRef(16826634); // "Maximized"
    }
    if(manif.bSplit)
    {
        if(!UsePsionicFocus(manif.oManifester) && !bIgnoreConstraints)
        {
            if(DEBUG) DoDebug(DebugObject2Str(manif.oManifester) + " unable to pay psionic focus for Split Psionic Ray!");
            manif.bSplit = FALSE;
        }
        else
            sInform += (sInform == "" ? "": ", ") + GetStringByStrRef(16826635); // "Split"
    }
    if(manif.bTwin)
    {
        if(!UsePsionicFocus(manif.oManifester) && !bIgnoreConstraints)
        {
            if(DEBUG) DoDebug(DebugObject2Str(manif.oManifester) + " unable to pay psionic focus for Twin Power!");
            manif.bTwin = FALSE;
        }
        else
            sInform += (sInform == "" ? "": ", ") + GetStringByStrRef(16826636); // "Twinned"
    }
    if(manif.bWiden)
    {
        if(!UsePsionicFocus(manif.oManifester) && !bIgnoreConstraints)
        {
            if(DEBUG) DoDebug(DebugObject2Str(manif.oManifester) + " unable to pay psionic focus for Widen Power!");
            manif.bWiden = FALSE;
        }
        else
            sInform += (sInform == "" ? "": ", ") + GetStringByStrRef(16826637); // "Widened"
    }

    // Finalise and display the information string if the manifestation was successfull
    if(manif.bCanManifest && sInform != "")
    {
        // Determine the index of the last comma
        /// @todo This is badly structured, rewrite
        string sTemp = sInform;
        int nComma,
            nTemp = FindSubString(sTemp, ", ");
        if(nTemp != -1)
        {
            sTemp = GetSubString(sTemp,
                                 nTemp + 2, // Crop off the comma and the following space
                                 GetStringLength(sTemp) // I'm lazy
                                 );
            nComma += nTemp +2;
            while((nTemp = FindSubString(sTemp, ", ")) != -1)
            {
                nComma += nTemp + 2;
                sTemp = GetSubString(sTemp, nTemp + 2, GetStringLength(sTemp));
            }

            // Replace the last comma with an "and"
            sInform = GetStringLeft(sInform, nComma - 2)
                    + " " + GetStringByStrRef(16826638) + " " // " and "
                    + GetSubString(sInform, nComma, GetStringLength(sInform) - nComma);
        }


        // Finish the information string
        sInform += " " + GetStringByStrRef(16826639); // "Power"

        FloatingTextStringOnCreature(sInform, manif.oManifester, FALSE);
    }

    return manif;
}


int MetaPsionicsDamage(struct manifestation manif, int nDieSize, int nNumberOfDice, int nBonus = 0,
                       int nBonusPerDie = 0, int bDoesHPDamage = FALSE, int bIsRayOrRangedTouch = FALSE)
{
    int nBaseDamage  = 0,
        nBonusDamage = nBonus + (nNumberOfDice * nBonusPerDie);

    // Calculate the base damage
    int i;
    for (i = 0; i < nNumberOfDice; i++)
        nBaseDamage += Random(nDieSize) + 1;


    // Apply general modifying effects
    if(bDoesHPDamage)
    {
        if(bIsRayOrRangedTouch &&
           GetHasFeat(FEAT_POWER_SPECIALIZATION, manif.oManifester))
        {
            if(GetLocalInt(manif.oManifester, "PowerSpecializationActive") && UsePsionicFocus(manif.oManifester))
                nBonusDamage += GetAbilityModifier(GetAbilityOfClass(GetManifestingClass(manif.oManifester)));
            else
                nBonusDamage += 2;
       }
       if(GetHasSpellEffect(MELD_PSYCHIC_FOCUS, manif.oManifester)) nBonusDamage += GetEssentiaInvested(manif.oManifester, MELD_PSYCHIC_FOCUS) + 1;
    }

    // Apply metapsionics
    // Both empower & maximize
    if(manif.bEmpower && manif.bMaximize)
        nBaseDamage = nBaseDamage / 2 + nDieSize * nNumberOfDice;
    // Just empower
    else if(manif.bEmpower)
        nBaseDamage += nBaseDamage / 2;
    // Just maximize
    else if(manif.bMaximize)
        nBaseDamage = nDieSize * nNumberOfDice;


    return nBaseDamage + nBonusDamage;
}


float EvaluateWidenPower(struct manifestation manif, float fBase)
{
    return manif.bWiden ? // Is Widen Power active
            fBase * 2 :   // Yes
            fBase;        // No
}


void EvaluateChainPower(struct manifestation manif, object oPrimaryTarget, int bAutoDelete = TRUE)
{
    // Delete the array if, for some reason, one exists already
    if(array_exists(manif.oManifester, PRC_CHAIN_POWER_ARRAY))
        array_delete(manif.oManifester, PRC_CHAIN_POWER_ARRAY);
    // Create the array
    if(!array_create(manif.oManifester, PRC_CHAIN_POWER_ARRAY))
        if(DEBUG) DoDebug("EvaluateChainPower(): ERROR: Cannot create target array!\n"
                        + "manif = " + DebugManifestation2Str(manif) + "\n"
                        + "oPrimaryTarget = " + DebugObject2Str(oPrimaryTarget) + "\n"
                        + "bAutoDelete = " + DebugBool2String(bAutoDelete) + "\n"
                          );

	// Add the primary target to the array
	//array_set_object(manif.oManifester, PRC_CHAIN_POWER_ARRAY, 0, oPrimaryTarget);  Bad idea, on a second though - Ornedan

	// Determine if Chain Power is active at all
	if(manif.bChain)
	{
	    // It is, determine amount of secondary targets and range to look for the over
	    int nMaxTargets = PRCMin(manif.nManifesterLevel, 20); // Chain Power maxes out at 20 secondary targets
	    float fRange = FeetToMeters(30.0f);
	    location lTarget = GetLocation(oPrimaryTarget);
	    object oSecondaryTarget;

	    // Build the target list as a linked list
	    oSecondaryTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRange, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oSecondaryTarget))
    	{
    		if(oSecondaryTarget != manif.oManifester &&     // Not the manifester
               oSecondaryTarget != oPrimaryTarget    &&     // Not the main target
               spellsIsTarget(oSecondaryTarget,             // Chain Power allows one to avoid hitting friendlies
                              SPELL_TARGET_SELECTIVEHOSTILE, // and we assume the manifester does so
                              manif.oManifester))
    		{
                AddToTargetList(oSecondaryTarget, manif.oManifester, INSERTION_BIAS_HD, TRUE);
    		}// end if - target is valid for this

            oSecondaryTarget = GetNextObjectInShape(SHAPE_SPHERE, fRange, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    	}// end while - loop through all potential targets

    	// Extract the linked list into the array
    	while(GetIsObjectValid(oSecondaryTarget = GetTargetListHead(manif.oManifester)))
    	    array_set_object(manif.oManifester, PRC_CHAIN_POWER_ARRAY,
    	                     array_get_size(manif.oManifester, PRC_CHAIN_POWER_ARRAY),
    	                     oSecondaryTarget
    	                     );
	}// end if - is Chain Power active in this manifestation

	// Schedule array deletion if so specified
	if(bAutoDelete)
	    DelayCommand(0.0f, _DeleteChainArray(manif.oManifester));
}

object GetSplitPsionicRayTarget(struct manifestation manif, object oPrimaryTarget)
{
    object oReturn = OBJECT_INVALID;

    // Determine if Split Psionic Ray is active at all
    if(manif.bSplit)
    {
        // It is, determine amount of secondary targets and range to look for the over
        float fRange = FeetToMeters(30.0f);
        location lTarget = GetLocation(oPrimaryTarget);
        object oPotentialTarget;

        // Build the target list as a linked list
        oPotentialTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRange, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oPotentialTarget))
        {
            if(oPotentialTarget != manif.oManifester &&     // Not the manifester
               oPotentialTarget != oPrimaryTarget    &&     // Not the main target
               spellsIsTarget(oPotentialTarget,             // Split Psionic Ray allows one to avoid hitting friendlies
                              SPELL_TARGET_SELECTIVEHOSTILE, // and we assume the manifester does so
                              manif.oManifester))
            {
                AddToTargetList(oPotentialTarget, manif.oManifester, INSERTION_BIAS_HD, TRUE);
            }// end if - target is valid for this

            oPotentialTarget = GetNextObjectInShape(SHAPE_SPHERE, fRange, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        }// end while - loop through all potential targets

        // The chosen target is the first in the list
        oReturn = GetTargetListHead(manif.oManifester);
    }// end if - is Split Psionic Ray active in this manifestation

    return oReturn;
}

// Test main
//void main(){}
