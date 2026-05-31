//::///////////////////////////////////////////////
//:: Psionics include: Augmentation
//:: psi_inc_augment
//::///////////////////////////////////////////////
/** @file
    Defines structs and functions for handling
    psionic power augmentation.

    @author Ornedan
    @date   Created - 2005.11.04
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// Constants are provided via psi_inc_core

/// Prefix of the local variable names used for storing an user's profiles
const string PRC_AUGMENT_PROFILE         = "PRC_Augment_Profile_";
/// Index of the currently used profile.
const string PRC_CURRENT_AUGMENT_PROFILE = "PRC_Current_Augment_Profile_Index";
/// Name of local variable where override is stored
const string PRC_AUGMENT_OVERRIDE        = "PRC_Augment_Override";
/// Name of local variable where the value of maximal augmentation switch is stored
const string PRC_AUGMENT_MAXAUGMENT      = "PRC_Augment_MaxAugment";

/// The lowest valid value of PRC_CURRENT_AUGMENT_PROFILE
const int PRC_AUGMENT_PROFILE_INDEX_MIN  = 1;
/// The highest valid value of PRC_CURRENT_AUGMENT_PROFILE
const int PRC_AUGMENT_PROFILE_INDEX_MAX  = 49;
/// Prefix of the local variable names used for storing quickselections
const string PRC_AUGMENT_QUICKSELECTION  = "PRC_Augment_Quickselection_";
/// The lowest value the quickslot index can have
const int PRC_AUGMENT_QUICKSELECTION_MIN = 1;
/// The highest value the quickslot index can have
const int PRC_AUGMENT_QUICKSELECTION_MAX = 7;
/// An index that should never contain a profile
const int PRC_AUGMENT_PROFILE_NONE = 0;

/// The value of an empty profile. Also known as zero
const int PRC_AUGMENT_NULL_PROFILE = 0x00000000;

/// The special value for nGenericAugCost in power augmentation profile that means the power has no generic augmentation.
const int PRC_NO_GENERIC_AUGMENTS    = -1;
/// The special value for nMaxAugs_* that means there is no limit to the times that option may be used.
const int PRC_UNLIMITED_AUGMENTATION = -1;

//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

/**
 * A structure used for defining how a particular power may be augmented.
 * Use PowerAugmentationProfile() to create.
 */
struct power_augment_profile{
    /**
     * Many powers specify several augmentation options and in addition a
     * "for each N PP spent augmenting this power, something happens".
     * This value is that N.
     */
    int nGenericAugCost;

    /**
     * How many PP the first augmentation option of the power will cost per
     * times used.
     */
    int nAugCost_1;
    /**
     * How many times, at most, can the first augmentation option be used.
     */
    int nMaxAugs_1;

    /**
     * How many PP the second augmentation option of the power will cost per
     * times used.
     */
    int nAugCost_2;
    /**
     * How many times, at most, can the second augmentation option be used.
     */
    int nMaxAugs_2;

    /**
     * How many PP the third augmentation option of the power will cost per
     * times used.
     */
    int nAugCost_3;
    /**
     * How many times, at most, can the third augmentation option be used.
     */
    int nMaxAugs_3;

    /**
     * How many PP the fourth augmentation option of the power will cost per
     * times used.
     */
    int nAugCost_4;
    /**
     * How many times, at most, can the fourth augmentation option be used.
     */
    int nMaxAugs_4;

    /**
     * How many PP the fifth augmentation option of the power will cost per
     * times used.
     */
    int nAugCost_5;
    /**
     * How many times, at most, can the fifth augmentation option be used.
     */
    int nMaxAugs_5;
};

/**
 * Users define how much PP they want to use for each augmentation option or
 * how many times they want to use each option. This structure is for transferring
 * that data.
 */
struct user_augment_profile{
    int nOption_1;
    int nOption_2;
    int nOption_3;
    int nOption_4;
    int nOption_5;

    /// Whether the values in this structure are to be interpreted as augmentation levels
    /// or as amounts of PP.
    int bValueIsPP;
};


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Constructs an augmentation profile for a power.
 * The default values for each parameter specify that the power in question
 * does not have that augmentation feature.
 *
 * @param nGenericAugCost Many powers have an augmentation clause saying "for
 *                        each N power points used to augment this power,
 *                        X happens". This parameter is used to define the
 *                        value N.
 *                        Valid values: {x = -1 OR x > 0}
 *                        Default: -1, which means that there is no generic
 *                        augmentation for this power.
 *
 * @param nAugCost_1      Cost to use the first augmentation option of this
 *                        power.
 *                        Valid values: {x >= 0}
 *                        Default: 0
 * @param nMaxAugs_1      Number of times the first augmentation option may at
 *                        most be used. Value of -1 means the option may be used
 *                        an unlimited number of times.
 *                        Valid values: {x >= -1}
 *                        Default: 0
 *
 * @param nAugCost_2      Cost to use the second augmentation option of this
 *                        power.
 *                        Valid values: {x >= 0}
 *                        Default: 0
 * @param nMaxAugs_2      Number of times the second augmentation option may at
 *                        most be used. Value of -1 means the option may be used
 *                        an unlimited number of times.
 *                        Valid values: {x >= -1}
 *                        Default: 0 *
 *
 * @param nAugCost_3      Cost to use the third augmentation option of this
 *                        power.
 *                        Valid values: {x >= 0}
 *                        Default: 0
 * @param nMaxAugs_3      Number of times the third augmentation option may at
 *                        most be used. Value of -1 means the option may be used
 *                        an unlimited number of times.
 *                        Valid values: {x >= -1}
 *                        Default: 0
 *
 * @param nAugCost_4      Cost to use the fourth augmentation option of this
 *                        power.
 *                        Valid values: {x >= 0}
 *                        Default: 0
 * @param nMaxAugs_4      Number of times the fourth augmentation option may at
 *                        most be used. Value of -1 means the option may be used
 *                        an unlimited number of times.
 *                        Valid values: {x >= -1}
 *                        Default: 0
 *
 * @param nAugCost_5      Cost to use the fifth augmentation option of this
 *                        power.
 *                        Valid values: {x >= 0}
 *                        Default: 0
 * @param nMaxAugs_5      Number of times the fifth augmentation option may at
 *                        most be used. Value of -1 means the option may be used
 *                        an unlimited number of times.
 *                        Valid values: {x >= -1}
 *                        Default: 0
 *
 * @return                The parameters compiled into a power_augment_profile
 *                        structure.
 */
struct power_augment_profile PowerAugmentationProfile(int nGenericAugCost = PRC_NO_GENERIC_AUGMENTS,
                                                      int nAugCost_1 = 0, int nMaxAugs_1 = 0,
                                                      int nAugCost_2 = 0, int nMaxAugs_2 = 0,
                                                      int nAugCost_3 = 0, int nMaxAugs_3 = 0,
                                                      int nAugCost_4 = 0, int nMaxAugs_4 = 0,
                                                      int nAugCost_5 = 0, int nMaxAugs_5 = 0
                                                      );

/**
 * Reads an augmentation profile from a user and compiles it into
 * a structure.
 *
 * @param oUser           A creature that has power augmentation profiles set up.
 * @param nIndex          The number of the profile to retrieve.
 * @param bQuickSelection Whether the index is a quickselection or a normal profile.
 * @return                The retrieved profile, compiled into a structure
 */
struct user_augment_profile GetUserAugmentationProfile(object oUser, int nIndex, int bQuickSelection = FALSE);

/**
 * Gets the user's current augmentation profile.
 *
 * @param oUser A creature that has power augmentation profiles set up.
 * @return      The retrieved profile, compiled into a structure
 */
struct user_augment_profile GetCurrentUserAugmentationProfile(object oUser);

/**
 * Stores a user-specified augmentation profile.
 *
 * @param oUser           The user for whose use to store the profile for.
 * @param nIndex          The index number to store the profile under.
 * @param bQuickSelection Whether the index is a quickselection or a normal profile.
 * @param uap             A structure containing the profile to store.
 */
void StoreUserAugmentationProfile(object oUser, int nIndex, struct user_augment_profile uap, int bQuickSelection = FALSE);

/**
 * Converts the given augmentation profile into a string.
 *
 * @param uap   The augmentation profile to convert to a string.
 * @return      A string of format:
 *              Option 1: N [times|PP], Option 2: N [times|PP], Option 2: N [times|PP], Option 4: N [times|PP], Option 5: N [times|PP]
 */
string UserAugmentationProfileToString(struct user_augment_profile uap);

/**
 * Calculates how many times each augmentation option of a power is used and
 * the increased PP cost caused by augmentation.
 * In addition to basic augmentation, currently accounts for:
 * - Wild Surge
 *
 *
 * @param manif The manifestation data related to an ongoing manifestation attempt.
 * @param pap   The power's augmentation profile.
 * @return      The manifestation data with augmentation's effects added in.
 */
struct manifestation EvaluateAugmentation(struct manifestation manif, struct power_augment_profile pap);

/**
 * Overrides the given creature's augmentation settings during it's next
 * manifestation with the given settings.
 *
 * NOTE: These values are assumed to be augmentation levels.
 *
 * @param oCreature Creature whose augmentation to override
 * @param uap       The profile to use as override
 */
void SetAugmentationOverride(object oCreature, struct user_augment_profile uap);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "psi_inc_core"


//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * @param nToDecode Integer from which to extract an user augmentation profile
 * @return          An user augmentation profile created based on nToDecode
 */
struct user_augment_profile _DecodeProfile(int nToDecode)
{
    struct user_augment_profile uap;

    // The augmentation profile is stored in one integer, with 6 bits per option.
    // MSB -> [xx555555444444333333222222111111] <- LSB
    int nMask = 0x3F; // 6 LSB
    uap.nOption_1 = nToDecode          & nMask;
    uap.nOption_2 = (nToDecode >>> 6)  & nMask;
    uap.nOption_3 = (nToDecode >>> 12) & nMask;
    uap.nOption_4 = (nToDecode >>> 18) & nMask;
    uap.nOption_5 = (nToDecode >>> 24) & nMask;

    return uap;
}

/** Internal function.
 * @param uapToEncode An user augmentation profile to encode into a single integer
 * @return            Integer built from values in uapToEncode
 */
int _EncodeProfile(struct user_augment_profile uapToEncode)
{
    // The augmentation profile is stored in one integer, with 6 bits per option.
    // MSB -> [xx555555444444333333222222111111] <- LSB
    int nProfile = PRC_AUGMENT_NULL_PROFILE;
    int nMask = 0x3F; // 6 LSB

    nProfile |= (uapToEncode.nOption_1 & nMask);
    nProfile |= (uapToEncode.nOption_2 & nMask) << 6;
    nProfile |= (uapToEncode.nOption_3 & nMask) << 12;
    nProfile |= (uapToEncode.nOption_4 & nMask) << 18;
    nProfile |= (uapToEncode.nOption_5 & nMask) << 24;

    return nProfile;
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////


struct power_augment_profile PowerAugmentationProfile(int nGenericAugCost = PRC_NO_GENERIC_AUGMENTS,
                                                      int nAugCost_1 = 0, int nMaxAugs_1 = 0,
                                                      int nAugCost_2 = 0, int nMaxAugs_2 = 0,
                                                      int nAugCost_3 = 0, int nMaxAugs_3 = 0,
                                                      int nAugCost_4 = 0, int nMaxAugs_4 = 0,
                                                      int nAugCost_5 = 0, int nMaxAugs_5 = 0
                                                      )
{
    struct power_augment_profile pap;

    pap.nGenericAugCost = nGenericAugCost;
    pap.nAugCost_1 = nAugCost_1;
    pap.nMaxAugs_1 = nMaxAugs_1;
    pap.nAugCost_2 = nAugCost_2;
    pap.nMaxAugs_2 = nMaxAugs_2;
    pap.nAugCost_3 = nAugCost_3;
    pap.nMaxAugs_3 = nMaxAugs_3;
    pap.nAugCost_4 = nAugCost_4;
    pap.nMaxAugs_4 = nMaxAugs_4;
    pap.nAugCost_5 = nAugCost_5;
    pap.nMaxAugs_5 = nMaxAugs_5;

    return pap;
}

struct user_augment_profile GetUserAugmentationProfile(object oUser, int nIndex, int bQuickSelection = FALSE)
{
    int nProfile = GetPersistantLocalInt(oUser, (bQuickSelection ? PRC_AUGMENT_QUICKSELECTION : PRC_AUGMENT_PROFILE) + IntToString(nIndex));
    struct user_augment_profile uap = _DecodeProfile(nProfile);

    // Get the augmentation levels / PP switch
    uap.bValueIsPP = GetPersistantLocalInt(oUser, PRC_PLAYER_SWITCH_AUGMENT_IS_PP);

    // Validity check on the index
    if(bQuickSelection ?
       (nIndex < PRC_AUGMENT_QUICKSELECTION_MIN ||
        nIndex > PRC_AUGMENT_QUICKSELECTION_MAX
        ):
       (nIndex < PRC_AUGMENT_PROFILE_INDEX_MIN ||
        nIndex > PRC_AUGMENT_PROFILE_INDEX_MAX
        )
       )
    {
        // Null the profile, just in case
        uap.nOption_1 = 0;
        uap.nOption_2 = 0;
        uap.nOption_3 = 0;
        uap.nOption_4 = 0;
        uap.nOption_5 = 0;
    }

    return uap;
}

/**
 * Gets the user's current augmentation profile.
 *
 * @param oUser A creature that has power augmentation profiles set up.
 * @return      The retrieved profile, compiled into a structure
 */
struct user_augment_profile GetCurrentUserAugmentationProfile(object oUser)
{
    struct user_augment_profile uap_ret;

    // Is augmentation override in effect?
    if(GetLocalInt(oUser, PRC_AUGMENT_OVERRIDE))
    {
        uap_ret = _DecodeProfile(GetLocalInt(oUser, PRC_AUGMENT_OVERRIDE) - 1);
        uap_ret.bValueIsPP = FALSE; // Override is always considered to be augmentation levels
    }
    // It wasn't, so get normally
    else
    {
        int nIndex = GetLocalInt(oUser, PRC_CURRENT_AUGMENT_PROFILE);
        int bQuick = nIndex < 0 ? TRUE : FALSE;

        if(bQuick) nIndex = -nIndex;

        uap_ret = GetUserAugmentationProfile(oUser, nIndex, bQuick);
    }

    return uap_ret;
}

void StoreUserAugmentationProfile(object oUser, int nIndex, struct user_augment_profile uap, int bQuickSelection = FALSE)
{
    // Validity check on the index
    if(bQuickSelection ?
       (nIndex < PRC_AUGMENT_QUICKSELECTION_MIN ||
        nIndex > PRC_AUGMENT_QUICKSELECTION_MAX
        ):
       (nIndex < PRC_AUGMENT_PROFILE_INDEX_MIN ||
        nIndex > PRC_AUGMENT_PROFILE_INDEX_MAX
        )
       )
    {
        if(DEBUG) DoDebug("StoreUserAugmentationProfile(): Attempt to store outside valid range: " + IntToString(nIndex));
        return;
    }

    SetPersistantLocalInt(oUser, (bQuickSelection ? PRC_AUGMENT_QUICKSELECTION : PRC_AUGMENT_PROFILE) + IntToString(nIndex), _EncodeProfile(uap));
}

string UserAugmentationProfileToString(struct user_augment_profile uap)
{
    string sBegin = GetStringByStrRef(16823498) + " "; // "Option"
    string sEnd   = " " + (uap.bValueIsPP ? "PP" : GetStringByStrRef(16823499)); // "times"

    return sBegin + "1: " + IntToString(uap.nOption_1) + sEnd + "; "
         + sBegin + "2: " + IntToString(uap.nOption_2) + sEnd + "; "
         + sBegin + "3: " + IntToString(uap.nOption_3) + sEnd + "; "
         + sBegin + "4: " + IntToString(uap.nOption_4) + sEnd + "; "
         + sBegin + "5: " + IntToString(uap.nOption_5) + sEnd;
}

struct manifestation EvaluateAugmentation(struct manifestation manif, struct power_augment_profile pap)
{
    // Get the user's augmentation profile - will be all zeroes if no profile is active
    struct user_augment_profile uap = GetCurrentUserAugmentationProfile(manif.oManifester);
    int nSurge               = GetWildSurge(manif.oManifester);
    int nAugPPCost           = 0;
    int nAugPPCostReductions = 0;
    int bMaxAugment          = GetLocalInt(manif.oManifester, PRC_AUGMENT_MAXAUGMENT) &&
                               !GetLocalInt(manif.oManifester, PRC_AUGMENT_OVERRIDE); // Override profile also overrides max augment
							   
    // Initialise the augmentation data in the manifestation structure to zero
    /* Probably unnecessary due to auto-init
    manif.nTimesAugOptUsed_1   = 0;
    manif.nTimesAugOptUsed_2   = 0;
    manif.nTimesAugOptUsed_3   = 0;
    manif.nTimesAugOptUsed_4   = 0;
    manif.nTimesAugOptUsed_5   = 0;
    manif.nTimesGenericAugUsed = 0;
    */

    /* Bloody duplication follows. Real arrays would be nice */
    // Make sure the option is available for use and the user wants to do something with it
    if(pap.nMaxAugs_1 && uap.nOption_1)
    {
        // Determine how many times the augmentation option has been used
        manif.nTimesAugOptUsed_1 = uap.bValueIsPP ?                  // The user can determine whether their settings are interpreted
                                    uap.nOption_1 / pap.nAugCost_1 : // as static PP costs
                                    uap.nOption_1;                   // or as number of times to use
        // Make sure the number of times the option is used does not exceed the maximum
        if(pap.nMaxAugs_1 != PRC_UNLIMITED_AUGMENTATION && manif.nTimesAugOptUsed_1 > pap.nMaxAugs_1)
            manif.nTimesAugOptUsed_1 = pap.nMaxAugs_1;
        // Calculate the amount of PP the augmentation will cost
        nAugPPCost += manif.nTimesAugOptUsed_1 * pap.nAugCost_1;
    }
    // Make sure the option is available for use and the user wants to do something with it
    if(pap.nMaxAugs_2 && uap.nOption_2)
    {
        // Determine how many times the augmentation option has been used
        manif.nTimesAugOptUsed_2 = uap.bValueIsPP ?                  // The user can determine whether their settings are interpreted
                                    uap.nOption_2 / pap.nAugCost_2 : // as static PP costs
                                    uap.nOption_2;                   // or as number of times to use
        // Make sure the number of times the option is used does not exceed the maximum
        if(pap.nMaxAugs_2 != PRC_UNLIMITED_AUGMENTATION && manif.nTimesAugOptUsed_2 > pap.nMaxAugs_2)
            manif.nTimesAugOptUsed_2 = pap.nMaxAugs_2;
        // Calculate the amount of PP the augmentation will cost
        nAugPPCost += manif.nTimesAugOptUsed_2 * pap.nAugCost_2;
    }
    // Make sure the option is available for use and the user wants to do something with it
    if(pap.nMaxAugs_3 && uap.nOption_3)
    {
        // Determine how many times the augmentation option has been used
        manif.nTimesAugOptUsed_3 = uap.bValueIsPP ?                  // The user can determine whether their settings are interpreted
                                    uap.nOption_3 / pap.nAugCost_3 : // as static PP costs
                                    uap.nOption_3;                   // or as number of times to use
        // Make sure the number of times the option is used does not exceed the maximum
        if(pap.nMaxAugs_3 != PRC_UNLIMITED_AUGMENTATION && manif.nTimesAugOptUsed_3 > pap.nMaxAugs_3)
            manif.nTimesAugOptUsed_3 = pap.nMaxAugs_3;
        // Calculate the amount of PP the augmentation will cost
        nAugPPCost += manif.nTimesAugOptUsed_3 * pap.nAugCost_3;
    }
    // Make sure the option is available for use and the user wants to do something with it
    if(pap.nMaxAugs_4 && uap.nOption_4)
    {
        // Determine how many times the augmentation option has been used
        manif.nTimesAugOptUsed_4 = uap.bValueIsPP ?                  // The user can determine whether their settings are interpreted
                                    uap.nOption_4 / pap.nAugCost_4 : // as static PP costs
                                    uap.nOption_4;                   // or as number of times to use
        // Make sure the number of times the option is used does not exceed the maximum
        if(pap.nMaxAugs_4 != PRC_UNLIMITED_AUGMENTATION && manif.nTimesAugOptUsed_4 > pap.nMaxAugs_4)
            manif.nTimesAugOptUsed_4 = pap.nMaxAugs_4;
        // Calculate the amount of PP the augmentation will cost
        nAugPPCost += manif.nTimesAugOptUsed_4 * pap.nAugCost_4;
    }
    // Make sure the option is available for use and the user wants to do something with it
    if(pap.nMaxAugs_5 && uap.nOption_5)
    {
        // Determine how many times the augmentation option has been used
        manif.nTimesAugOptUsed_5 = uap.bValueIsPP ?                  // The user can determine whether their settings are interpreted
                                    uap.nOption_5 / pap.nAugCost_5 : // as static PP costs
                                    uap.nOption_5;                   // or as number of times to use
        // Make sure the number of times the option is used does not exceed the maximum
        if(pap.nMaxAugs_5 != PRC_UNLIMITED_AUGMENTATION && manif.nTimesAugOptUsed_5 > pap.nMaxAugs_5)
            manif.nTimesAugOptUsed_5 = pap.nMaxAugs_5;
        // Calculate the amount of PP the augmentation will cost
        nAugPPCost += manif.nTimesAugOptUsed_5 * pap.nAugCost_5;
    }

    // Calculate number of times a generic augmentation happens with this number of PP
    if(pap.nGenericAugCost != PRC_NO_GENERIC_AUGMENTS)
        manif.nTimesGenericAugUsed = nAugPPCost / pap.nGenericAugCost;


    /*/ Various effects modifying the augmentation go below /*/

    // Account for wild surge
    nAugPPCostReductions += nSurge;
    
	// Midnight Augmentation feat from incarnum
	int bMidAug	= GetLocalInt(manif.oManifester, "MidnightAugPower");
	int nMidnightAugReduction = 0;
	//if (GetHasFeat(FEAT_MIDNIGHT_AUGMENTATION, manif.oManifester))
	if(bMidAug > 0)
    {
    	if(DEBUG) DoDebug("Checking Midnight Augumentation");
		int bMidAugInvestment = GetLocalInt(manif.oManifester, "MidnightAugPowerInvestment");
		
		// Make sure the power is the correct one, and that you can expend your psionic focus
    	if (manif.nSpellID == GetLocalInt(manif.oManifester, "MidnightAugPower") && UsePsionicFocus(manif.oManifester))
		{
    		if(DEBUG) DoDebug("Midnight Augumentation power invested Essentia is: "+IntToString(bMidAugInvestment)+".");
			//nAugPPCostReductions = nAugPPCostReductions + bMidAugInvestment;
			nMidnightAugReduction = bMidAugInvestment;
			
			if(DEBUG) DoDebug("Final Midnight Augumentation power adjustment "+IntToString(nMidnightAugReduction)+".");
		}
    }		
	
    /*/ Various effects modifying the augmentation go above /*/

    // Auto-distribution, if modifying effects provided more PP than has been used so far or
    // the maximal augmentation switch is active
    if((nAugPPCost - nAugPPCostReductions) < 0 || bMaxAugment)
    {
        int nToAutodistribute = 0, nAutodistributed;

        // Calculate autodistribution amount
        if(bMaxAugment)
        {
            // Maximal augmentation ignores PP cost reductions here. They are instead handled at the end
            if(((manif.nManifesterLevel - manif.nPPCost) - nAugPPCost) > 0)
                nToAutodistribute = manif.nManifesterLevel // Maximum usable
                                  - manif.nPPCost          // Reduced by what's already been used for other things
                                  - nAugPPCost;            // Reduced by what's already been used for augmentation
        }
        // No maximal augmentation, instead more PP cost reduction provided than PP has been used
        else if((nAugPPCost - nAugPPCostReductions) < 0)
            nToAutodistribute = -(nAugPPCost - nAugPPCostReductions); // The amount of PP cost reduction that's in excess of what's already been used for augmentation

        // Store the value for use in cost calculations
        nAutodistributed = nToAutodistribute;

        // Start the distribution
        int nTimesCanAug;
        int nTimesAugd;
        if(nToAutodistribute > 0 && pap.nMaxAugs_1)
        {
            // Determine how many times this option could be used
            if(pap.nMaxAugs_1 == PRC_UNLIMITED_AUGMENTATION)
                nTimesCanAug = PRC_UNLIMITED_AUGMENTATION;
            else
                nTimesCanAug = pap.nMaxAugs_1 - manif.nTimesAugOptUsed_1;

            if(nTimesCanAug)
            {
                // Determine how many times it can be used and how much it costs
                nTimesAugd = nTimesCanAug == PRC_UNLIMITED_AUGMENTATION ?
                              nToAutodistribute / pap.nAugCost_1 :
                              PRCMin(nToAutodistribute / pap.nAugCost_1, nTimesCanAug);
                nToAutodistribute -= nTimesAugd * pap.nAugCost_1;

                manif.nTimesAugOptUsed_1 += nTimesAugd;
            }
        }
        if(nToAutodistribute > 0 && pap.nMaxAugs_2)
        {
            // Determine how many times this option can be used
            if(pap.nMaxAugs_2 == PRC_UNLIMITED_AUGMENTATION)
                nTimesCanAug = PRC_UNLIMITED_AUGMENTATION;
            else
                nTimesCanAug = pap.nMaxAugs_2 - manif.nTimesAugOptUsed_2;

            if(nTimesCanAug)
            {
                // Determine how many times it can be used and how much it costs
                nTimesAugd = nTimesCanAug == PRC_UNLIMITED_AUGMENTATION ?
                              nToAutodistribute / pap.nAugCost_2 :
                              PRCMin(nToAutodistribute / pap.nAugCost_2, nTimesCanAug);
                nToAutodistribute -= nTimesAugd * pap.nAugCost_2;

                manif.nTimesAugOptUsed_2 += nTimesAugd;
            }
        }
        if(nToAutodistribute > 0 && pap.nMaxAugs_3)
        {
            // Determine how many times this option can be used
            if(pap.nMaxAugs_3 == PRC_UNLIMITED_AUGMENTATION)
                nTimesCanAug = PRC_UNLIMITED_AUGMENTATION;
            else
                nTimesCanAug = pap.nMaxAugs_3 - manif.nTimesAugOptUsed_3;

            if(nTimesCanAug)
            {
                // Determine how many times it can be used and how much it costs
                nTimesAugd = nTimesCanAug == PRC_UNLIMITED_AUGMENTATION ?
                              nToAutodistribute / pap.nAugCost_3 :
                              PRCMin(nToAutodistribute / pap.nAugCost_3, nTimesCanAug);
                nToAutodistribute -= nTimesAugd * pap.nAugCost_3;

                manif.nTimesAugOptUsed_3 += nTimesAugd;
            }
        }
        if(nToAutodistribute > 0 && pap.nMaxAugs_4)
        {
            // Determine how many times this option can be used
            if(pap.nMaxAugs_4 == PRC_UNLIMITED_AUGMENTATION)
                nTimesCanAug = PRC_UNLIMITED_AUGMENTATION;
            else
                nTimesCanAug = pap.nMaxAugs_4 - manif.nTimesAugOptUsed_4;

            if(nTimesCanAug)
            {
                // Determine how many times it can be used and how much it costs
                nTimesAugd = nTimesCanAug == PRC_UNLIMITED_AUGMENTATION ?
                              nToAutodistribute / pap.nAugCost_4 :
                              PRCMin(nToAutodistribute / pap.nAugCost_4, nTimesCanAug);
                nToAutodistribute -= nTimesAugd * pap.nAugCost_4;

                manif.nTimesAugOptUsed_4 += nTimesAugd;
            }
        }
        if(nToAutodistribute > 0 && pap.nMaxAugs_5)
        {
            // Determine how many times this option can be used
            if(pap.nMaxAugs_5 == PRC_UNLIMITED_AUGMENTATION)
                nTimesCanAug = PRC_UNLIMITED_AUGMENTATION;
            else
                nTimesCanAug = pap.nMaxAugs_5 - manif.nTimesAugOptUsed_5;

            if(nTimesCanAug)
            {
                // Determine how many times it can be used and how much it costs
                nTimesAugd = nTimesCanAug == PRC_UNLIMITED_AUGMENTATION ?
                              nToAutodistribute / pap.nAugCost_5 :
                              PRCMin(nToAutodistribute / pap.nAugCost_5, nTimesCanAug);
                nToAutodistribute -= nTimesAugd * pap.nAugCost_5;

                manif.nTimesAugOptUsed_5 += nTimesAugd;
            }
        }

        // Calculate amount actually autodistributed. nToAutoDistribute now contains the amount of PP that could not be auto-distributed
        nAutodistributed = (nAutodistributed - nToAutodistribute);

        // Calculate increase to generic augmentation
        if(pap.nGenericAugCost != PRC_NO_GENERIC_AUGMENTS)
            manif.nTimesGenericAugUsed += nAutodistributed / pap.nGenericAugCost;

        // Determine new augmentation PP cost
        nAugPPCost += nAutodistributed;
    }

    // Add in cost reduction
    //nAugPPCost = PRCMax(0, nAugPPCost - nAugPPCostReductions);
	nAugPPCost = nAugPPCost - nAugPPCostReductions;
    // Store the PP cost increase
    manif.nPPCost += nAugPPCost;
	manif.nPPCost -= nMidnightAugReduction;  //:: Had to apply this directly, wouldn't work otherwise. -Jaysyn

    return manif;
}

void SetAugmentationOverride(object oCreature, struct user_augment_profile uap)
{
    SetLocalInt(oCreature, PRC_AUGMENT_OVERRIDE, _EncodeProfile(uap) + 1);
}

// Test main
//void main(){}