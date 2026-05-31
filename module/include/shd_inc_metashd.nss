//::///////////////////////////////////////////////
//:: Shadowcasting include: Metashadow
//:: shd_inc_metashd
//::///////////////////////////////////////////////
/** @file
    Defines functions for handling metashadows

    @author Stratovarius
    @date   Created - 2019.2.7
    @thanks to Ornedan for his work on Psionics upon which this is based.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

#include "shd_myst_const"

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

/// No metashadows
const int METASHADOW_NONE          = 0x0;
/// Quicken mystery
const int METASHADOW_QUICKEN       = 0x2;
/// Empower mystery
const int METASHADOW_EMPOWER       = 0x4;
/// Extend mystery
const int METASHADOW_EXTEND        = 0x8;
/// Maximize mystery
const int METASHADOW_MAXIMIZE      = 0x16;
/// Maximize mystery
const int METASHADOW_STILL         = 0x32;

/// Internal constant. Value is equal to the lowest metashadow constant. Used when looping over metashadow flag variables
const int METASHADOW_MIN           = 0x2;
/// Internal constant. Value is equal to the highest metashadow constant. Used when looping over metashadow flag variables
const int METASHADOW_MAX           = 0x32;

/// Empower Mystery variable name
const string METASHADOW_EMPOWER_VAR   = "PRC_ShadMeta_Empower";
/// Extend Mystery variable name
const string METASHADOW_EXTEND_VAR    = "PRC_ShadMeta_Extend";
/// Quicken Mystery variable name
const string METASHADOW_QUICKEN_VAR   = "PRC_ShadMeta_Quicken";
/// Maximize Mystery variable name
const string METASHADOW_MAXIMIZE_VAR  = "PRC_ShadMeta_Maximize";
/// Still Mystery variable name
const string METASHADOW_STILL_VAR     = "PRC_ShadMeta_Still";

/// The name of a marker variable that tells that the Mystery being shadowcast had Quicken Mystery used on it
const string PRC_MYSTERY_IS_QUICKENED = "PRC_MysteryIsQuickened";

//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

/**
 * A structure that contains common data used during mystery.
 */
struct mystery{
    /* Generic stuff */
    /// The creature Shadowcasting the Mystery
    object oShadow;
    /// Whether the mystery is successful or not
    int bCanMyst;
    /// The creature's shadowcaster level in regards to this mystery
    int nShadowcasterLevel;
    /// The mystery's spell ID
    int nMystId;
    /// Used to mark mysteries that have gone supernatural
    int bIgnoreSR;

    /* Metashadows */
    /// Whether Empower mystery was used with this mystery
    int bEmpower;
    /// Whether Extend mystery was used with this mystery
    int bExtend;
    /// Whether Quicken mystery was used with this mystery
    int bQuicken;
    /// Whether Maximize mystery was used with this mystery
    int bMaximize;   
    /// Whether Still mystery was used with this mystery
    int bStill;   

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
 * Determines the metashadows used in this mystery of a mystery
 * and the cost added by their use.
 *
 * @param myst         The mystery data related to this particular mystery
 * @param nMetaMystFlags An integer containing a set of bitflags that determine
 *                      which metashadow mysterys may be used with the Mystery being shadowcast
 *
 * @return              The mystery data, modified to account for the metashadows
 */
struct mystery EvaluateMetashadows(struct mystery myst, int nMetaMystFlags);

/**
 * Calculates a mystery's damage based on the given dice and metashadows.
 *
 * @param nDieSize            Size of the dice to use
 * @param nNumberOfDice       Amount of dice to roll
 * @param nBonus              A bonus amount of damage to add into the total once
 * @param nBonusPerDie        A bonus amount of damage to add into the total for each die rolled
 * @param bDoesHPDamage       Whether the Mystery deals hit point damage, or some other form of point damage
 * @param bIsRayOrRangedTouch Whether the mystery's use involves a ranged touch attack roll or not
 * @return                    The amount of damage the Mystery should deal
 */
int MetashadowsDamage(struct mystery myst, int nDieSize, int nNumberOfDice, int nBonus = 0,
                       int nBonusPerDie = 0, int bDoesHPDamage = FALSE, int bIsRayOrRangedTouch = FALSE);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_utility"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct mystery EvaluateMetashadows(struct mystery myst, int nMetaMystFlags)
{
    // Quicken Mystery - special handling
    if(GetLocalInt(myst.oShadow, PRC_MYSTERY_IS_QUICKENED))
    {
        // Mark the mystery as quickened here
        myst.bQuicken = TRUE;

        // Delete the marker var
        DeleteLocalInt(myst.oShadow, PRC_MYSTERY_IS_QUICKENED);
    }

    if((nMetaMystFlags & METASHADOW_EMPOWER) && (GetLocalInt(myst.oShadow, METASHADOW_EMPOWER_VAR) || GetLocalInt(myst.oShadow, "FloodShadow")))
    {
        // Mark the mystery as empowered here
        myst.bEmpower = TRUE;
        // Then clear the variable
        DeleteLocalInt(myst.oShadow, METASHADOW_EMPOWER_VAR);
    }
    if((nMetaMystFlags & METASHADOW_EXTEND) && GetLocalInt(myst.oShadow, METASHADOW_EXTEND_VAR))
    {
        // Mark the mystery as extended here
        myst.bExtend = TRUE;
        // Then clear the variable
        DeleteLocalInt(myst.oShadow, METASHADOW_EXTEND_VAR);        
    }
    if((nMetaMystFlags & METASHADOW_MAXIMIZE) && GetLocalInt(myst.oShadow, METASHADOW_MAXIMIZE_VAR))
    {
        // Mark the mystery as maximized here
        myst.bMaximize = TRUE;
        // Then clear the variable
        DeleteLocalInt(myst.oShadow, METASHADOW_MAXIMIZE_VAR);          
    }

    return myst;
}

int MetashadowsDamage(struct mystery myst, int nDieSize, int nNumberOfDice, int nBonus = 0,
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
           // Anything that affects Ray Mysterys goes here
       }
    }

    // Apply metashadows
    // Both empower & maximize
    if(myst.bEmpower && myst.bMaximize)
    {
        nBaseDamage = nBaseDamage / 2 + nDieSize * nNumberOfDice;
        if(DEBUG) DoDebug("MetashadowsDamage(): Empower + Max");
    }    
    // Just empower
    else if(myst.bEmpower)
    {    
        nBaseDamage += nBaseDamage / 2;
        if(DEBUG) DoDebug("MetashadowsDamage(): Empower only");
    }         
    // Just maximize
    else if(myst.bMaximize)
    {
        nBaseDamage = nDieSize * nNumberOfDice;
        if(DEBUG) DoDebug("MetashadowsDamage(): Max only");
    }         

    return nBaseDamage + nBonusDamage;
}

// Test main
//void main(){}
