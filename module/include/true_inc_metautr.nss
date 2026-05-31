//::///////////////////////////////////////////////
//:: Truenaming include: Metautterances
//:: true_inc_metautr
//::///////////////////////////////////////////////
/** @file
    Defines functions for handling metautterances

    @author Stratovarius
    @date   Created - 2006.7.17
    @thanks to Ornedan for his work on Psionics upon which this is based.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

/// No metautterances
const int METAUTTERANCE_NONE          = 0x0;
/// Quicken utterance
const int METAUTTERANCE_QUICKEN       = 0x2;
/// Empower utterance
const int METAUTTERANCE_EMPOWER       = 0x4;
/// Extend utterance
const int METAUTTERANCE_EXTEND        = 0x8;

/// Internal constant. Value is equal to the lowest metautterance constant. Used when looping over metautterance flag variables
const int METAUTTERANCE_MIN           = 0x2;
/// Internal constant. Value is equal to the highest metautterance constant. Used when looping over metautterance flag variables
const int METAUTTERANCE_MAX           = 0x8;

/// Empower Utterance variable name
const string METAUTTERANCE_EMPOWER_VAR   = "PRC_TrueMeta_Empower";
/// Extend Utterance variable name
const string METAUTTERANCE_EXTEND_VAR    = "PRC_TrueMeta_Extend";
/// Quicken Utterance variable name
const string METAUTTERANCE_QUICKEN_VAR   = "PRC_TrueMeta_Quicken";


/// The name of a marker variable that tells that the Utterance being truespoken had Quicken Utterance used on it
const string PRC_UTTERANCE_IS_QUICKENED = "PRC_UtteranceIsQuickened";

//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

/**
 * A structure that contains common data used during utterance.
 */
struct utterance{
    /* Generic stuff */
    /// The creature Truespeaking the Utterance
    object oTrueSpeaker;
    /// Whether the utterance is successful or not
    int bCanUtter;
    /// The creature's truespeaker level in regards to this utterance
    int nTruespeakerLevel;
    /// The utterance's spell ID
    int nSpellId;
    /// The DC for speaking the utterance
    int nUtterDC;
    //  Used to mark friendly utterances
    int bIgnoreSR;

    /* Metautterances */
    /// Whether Empower utterance was used with this utterance
    int bEmpower;
    /// Whether Extend utterance was used with this utterance
    int bExtend;
    /// Whether Quicken utterance was used with this utterance
    int bQuicken;

    /* Speak Unto the Masses */
    // Check if the target is a friend of not
    int bFriend;
    // Saving Throw DC
    int nSaveDC;
    // Saving Throw
    int nSaveThrow;
    // Saving Throw Type
    int nSaveType;
    // Spell Pen
    int nPen;
    // Duration Effects
    effect eLink;
    // Impact Effects
    effect eLink2;
    // Any Item Property
    itemproperty ipIProp1;
    // Any Item Property
    itemproperty ipIProp2;
    // Any Item Property
    itemproperty ipIProp3;
    // Duration
    float fDur;
};

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines the metautterances used in this utterance of a utterance
 * and the cost added by their use.
 *
 * @param utter         The utterance data related to this particular utterance
 * @param nMetaUtterFlags An integer containing a set of bitflags that determine
 *                      which metautterance utterances may be used with the Utterance being truespoken
 *
 * @return              The utterance data, modified to account for the metautterances
 */
struct utterance EvaluateMetautterances(struct utterance utter, int nMetaUtterFlags);

/**
 * Calculates a utterance's damage based on the given dice and metautterances.
 *
 * @param nDieSize            Size of the dice to use
 * @param nNumberOfDice       Amount of dice to roll
 * @param manif               The utterance data related to this particular utterance
 * @param nBonus              A bonus amount of damage to add into the total once
 * @param nBonusPerDie        A bonus amount of damage to add into the total for each die rolled
 * @param bDoesHPDamage       Whether the Utterance deals hit point damage, or some other form of point damage
 * @param bIsRayOrRangedTouch Whether the utterance's use involves a ranged touch attack roll or not
 * @return                    The amount of damage the Utterance should deal
 */
int MetautterancesDamage(struct utterance utter, int nDieSize, int nNumberOfDice, int nBonus = 0,
                       int nBonusPerDie = 0, int bDoesHPDamage = FALSE, int bIsRayOrRangedTouch = FALSE);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_utility"
//#include "true_inc_utter"


//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct utterance EvaluateMetautterances(struct utterance utter, int nMetaUtterFlags)
{
    // Total PP cost of metautterances used
    int nUtterDC = 0;
    // A debug variable to make a Utterance ignore normal use constraints
    int bIgnoreConstr = (DEBUG) ? GetLocalInt(utter.oTrueSpeaker, TRUE_DEBUG_IGNORE_CONSTRAINTS) : FALSE;

    /* Calculate the added DC from metautterances and set the use markers for the utterances used */

    // Quicken Utterance - special handling
    if(GetLocalInt(utter.oTrueSpeaker, PRC_UTTERANCE_IS_QUICKENED))
    {
        // Add the DC Boost and mark the utterance as quickened here
        nUtterDC += 20;
        utter.bQuicken = TRUE;

        // Delete the marker var
        DeleteLocalInt(utter.oTrueSpeaker, PRC_UTTERANCE_IS_QUICKENED);
    }

    if((nMetaUtterFlags & METAUTTERANCE_EMPOWER) && GetLocalInt(utter.oTrueSpeaker, METAUTTERANCE_EMPOWER_VAR))
    {
        // Add the DC Boost and mark the utterance as empowered here
        nUtterDC += 10;
        utter.bEmpower = TRUE;
    }
    if((nMetaUtterFlags & METAUTTERANCE_EXTEND) && GetLocalInt(utter.oTrueSpeaker, METAUTTERANCE_EXTEND_VAR))
    {
        // Add the DC Boost and mark the utterance as extended here
        nUtterDC += 5;
        utter.bExtend = TRUE;
    }

    // Add in the DC boost of the metautterances
    utter.nUtterDC += nUtterDC;

    return utter;
}

int MetautterancesDamage(struct utterance utter, int nDieSize, int nNumberOfDice, int nBonus = 0,
                       int nBonusPerDie = 0, int bDoesHPDamage = FALSE, int bIsRayOrRangedTouch = FALSE)
{
    int nBaseDamage = 0,
        nBonusDamage = nBonus + (nNumberOfDice * nBonusPerDie);

    // Calculate the base damage
    int i;
    for (i = 0; i < nNumberOfDice; i++)
        nBaseDamage += Random(nDieSize) + 1;


    // Apply general modifying effects
    if(bDoesHPDamage)
    {
        if(bIsRayOrRangedTouch)
       {
           // Anything that affects Ray Utterances goes here
       }
    }

    // Apply metautterances
    // Empower
   if(utter.bEmpower)
        nBaseDamage += nBaseDamage / 2;

    return nBaseDamage + nBonusDamage;
}

// Test main
//void main(){}
