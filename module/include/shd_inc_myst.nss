//::///////////////////////////////////////////////
//:: Shadowcasting include: Shadowcasting
//:: shd_inc_myst
//::///////////////////////////////////////////////
/** @file
    Defines structures and functions for handling
    shadowcasting a mystery

    @author Stratovarius
    @date   Created - 2019.2.7
    @thanks to Ornedan for his work on Psionics upon which this is based.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const string PRC_SHADOWCASTING_CLASS       = "PRC_CurrentMystery_ShadowcastingClass";
const string PRC_MYSTERY_LEVEL             = "PRC_CurrentMystery_Level";
const string MYST_DEBUG_IGNORE_CONSTRAINTS = "MYST_DEBUG_IGNORE_CONSTRAINTS";

/**
 * The variable in which the mystery token is stored. If no token exists,
 * the variable is set to point at the shadowcaster itself. That way OBJECT_INVALID
 * means the variable is unitialised.
 */
//const string PRC_MYSTERY_TOKEN_VAR  = "PRC_MysteryToken";
//const string PRC_MYSTERY_TOKEN_NAME = "PRC_MYSTTOKEN";
//const float  PRC_MYSTERY_HB_DELAY   = 0.5f;


//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

// struct mystery moved to shd_inc_metashd

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines if the mystery that is currently being attempted to be TrueSpoken
 * can in fact be truespoken. Determines metashadows used.
 *
 * @param oShadow       A creature attempting to shadowcast a mystery at this moment.
 * @param oTarget       The target of the mystery, if any. For pure Area of Effect
 *                      mysteries, this should be OBJECT_INVALID. Otherwise the main
 *                      target of the mystery as returned by PRCGetSpellTargetObject().
 * @param nMetaShadFlags The metashadows that may be used to modify this mystery. Any number
 *                      of METASHADOW_* constants ORd together using the | operator.
 *                      For example (METASHADOW_EMPOWER | METASHADOW_EXTEND)
 *
 * @return              A mystery structure that contains the data about whether
 *                      the mystery was successfully shadowcast, what metashadows
 *                      were used and some other commonly used data, like the 
 *                      creator's shadowcaster level for this mystery.
 */
struct mystery EvaluateMystery(object oShadow, object oTarget, int nMetaShadFlags);

/**
 * Causes OBJECT_SELF to use the given mystery.
 *
 * @param nMyst          The index of the mystery to use in spells.2da or a MYST_*
 * @param nClass         The index of the class to use the mystery as in classes.2da or a CLASS_TYPE_*
 * @param nLevelOverride An optional override to normal shadowcaster level. 
 *                       Default: 0, which means the parameter is ignored.
 */
void UseMystery(int nMyst, int nClass, int nLevelOverride = 0);

/**
 * A debugging function. Takes a mystery structure and
 * makes a string describing the contents.
 *
 * @param myst A set of mystery data
 * @return      A string describing the contents of myst
 */
string DebugMystery2Str(struct mystery myst);

/**
 * Sets the evaluation functions to ignore constraints on shadowcasting.
 * Call this just prior to EvaluateMystery() in a mystery script.
 * That evaluation will then ignore lacking mystery ability score,
 * and other restrictions
 *
 * @param oShadow A creature attempting to shadowcast a mystery at this moment.
 */
void ShadowcastDebugIgnoreConstraints(object oShadow);

/**
 * Returns the uses per day already used
 *
 * @param oShadow    Caster of the Mystery
 * @param nMystId    SpellId of the Mystery
 * @return           Number of uses per day already used
 */
int GetMysteryUses(object oShadow, int nMystId);

/**
 * Returns the bonus uses per day already used
 *
 * @param oShadow    Caster of the Mystery
 * @param nMystLevel Level of the Mystery
 * @return           Number of uses per day already used
 */
int GetBonusUses(object oShadow, int nMystLevel);

/**
 * Adds a use per day
 *
 * @param oShadow    Caster of the Mystery
 * @param nMystId    SpellId of the Mystery
 */
void SetMysteryUses(object oShadow, int nMystId);

/**
 * Adds a bonus use per day
 *
 * @param oShadow    Caster of the Mystery
 * @param nMystLevel Level of the Mystery
 */
void SetBonusUses(object oShadow, int nMystLevel);

/**
 * Deletes all of the Local Ints stored by uses per day.
 * Called OnRest and OnEnter
 *
 * @param oShadow    Caster of the Mystery
 */
void ClearMystLocalVars(object oShadow);

/**
 * Returns total uses per day for the shadowcaster for a given mystery
 *
 * @param oShadow    Caster of the Mystery
 * @param nMystId    SpellId of the Mystery
 * @param nClass     Class to check against
 */
int MysteriesPerDay(object oShadow, int nMystId, int nClass);

/**
 * Calculates bonus mysteries from a high intelligence
 *
 * @param oShadow    Caster of the Mystery
 * @param nMystLevel Mystery level to check
 */
int BonusMysteriesPerDay(object oShadow, int nMystLevel);

/**
 * Returns the name of the mystery
 *
 * @param nMystId        SpellId of the mystery
 */
string GetMysteryName(int nMystId);

/**
 * Checks whether the mystery is supernatural or not
 *
 * @param nMystId The Mystery to Check
 * @return        TRUE if Mystery is (Su), else FALSE
 */
int GetIsMysterySupernatural(object oShadow, int nMystId, int nClass);

/**
 * Checks whether the mystery is a SLA or not
 *
 * @param nMystId The Mystery to Check
 * @return        TRUE if Mystery is (Su), else FALSE
 */
int GetIsMysterySLA(object oShadow, int nMystId, int nClass);

/**
 * Checks whether the mystery is a Fundamental or not
 *
 * @param nMystId The Mystery to Check
 * @return        TRUE if Mystery is a Fundamental, else FALSE
 */
int GetIsFundamental(int nMystId);

/**
 * Checks whether caster has Favored Mystery in the cast mystery
 *
 * @param oShadow The Shadowcaster
 * @param nMyst   The Mystery to Check
 * @return        TRUE if he has the feat, else FALSE
 */
int GetHasFavoredMystery(object oShadow, int nMyst);

/**
 * Checks whether caster has Shadow Cast feat
 *
 * @param oShadow The Shadowcaster
 * @return        TRUE if he has the feat, else FALSE
 */
int GetShadowCast(object oShadow);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "shd_inc_metashd"
#include "shd_inc_shdfunc"
#include "prc_inc_combat"
#include "inc_newspellbook"
#include "inc_lookups"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * Handles Spellfire absorption when a mystery is used on a friendly spellfire
 * user.
 */
struct mystery _DoShadowcastSpellfireFriendlyAbsorption(struct mystery myst, object oTarget)
{
    if(GetLocalInt(oTarget, "SpellfireAbsorbFriendly") &&
       GetIsFriend(oTarget, myst.oShadow)
       )
    {
        if(CheckSpellfire(myst.oShadow, oTarget, TRUE))
        {
            PRCShowSpellResist(myst.oShadow, oTarget, SPELL_RESIST_MANTLE);
            myst.bCanMyst = FALSE;
        }
    }

    return myst;
}

/** Internal function.
 * Deletes mystery-related local variables.
 *
 * @param oShadow The creature currently shadowcasting a mystery
 */
void _CleanMysteryVariables(object oShadow)
{
    DeleteLocalInt(oShadow, PRC_SHADOWCASTING_CLASS);
    DeleteLocalInt(oShadow, PRC_MYSTERY_LEVEL);
}

/** Internal function.
 * Sets mystery-related local variables.
 *
 * @param oShadow      The creature currently shadowcasting a mystery
 * @param nClass       Mystery casting class constant
 * @param nLevel       Mystery level
 * @param bQuicken     If the mystery was quickened 1, else 0
 */
void _SetMysteryVariables(object oShadow, int nClass, int nLevel, int bQuicken)
{
    if (DEBUG) FloatingTextStringOnCreature(GetName(oShadow)+" is a "+IntToString(nClass)+" at "+IntToString(nLevel)+" level", oShadow);
    SetLocalInt(oShadow, PRC_SHADOWCASTING_CLASS, nClass + 1);
    SetLocalInt(oShadow, PRC_MYSTERY_LEVEL, nLevel);
    SetLocalInt(oShadow, PRC_MYSTERY_IS_QUICKENED, bQuicken);
}

// Makes sure radial spells are stored on the correct row number
string _GetMysterySpellId(int nMystId)
{
    string nReturn = Get2DACache("spells", "Master", nMystId);
    if (1 > StringToInt(nReturn)) nReturn = IntToString(nMystId); // SpellId invalid for the Master column
    
    return nReturn;
}    

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct mystery EvaluateMystery(object oShadow, object oTarget, int nMetaShadFlags)
{
    /* Get some data */
    int bIgnoreConstraints = (DEBUG) ? GetLocalInt(oShadow, MYST_DEBUG_IGNORE_CONSTRAINTS) : FALSE;
    // shadowcaster-related stuff
    int nShadowcasterLevel = GetShadowcasterLevel(oShadow);
    int nMystLevel         = GetMysteryLevel(oShadow);
    int nClass             = GetShadowcastingClass(oShadow);

    if (DEBUG) FloatingTextStringOnCreature(GetName(oShadow)+" is a "+IntToString(nClass)+" casting a "+IntToString(nMystLevel)+" level mystery at "+IntToString(nShadowcasterLevel)+" shadowcaster level", oShadow);

    /* Initialise the mystery structure */
    struct mystery myst;
    myst.oShadow            = oShadow;
    myst.bCanMyst           = TRUE;                                   // Assume successful mystery by default
    myst.nShadowcasterLevel = nShadowcasterLevel;
    myst.nMystId            = PRCGetSpellId();
    myst.bIgnoreSR          = GetIsMysterySupernatural(oShadow, myst.nMystId, nClass);

    // Account for metashadows. This includes adding the appropriate DC boosts.
    myst = EvaluateMetashadows(myst, nMetaShadFlags);
    
    // Skip paying anything if something has prevented a successful cast already by this point
    // Fundamentals track their uses per day differently. 
    if(myst.bCanMyst && !GetIsFundamental(myst.nMystId))
    {
        if (GetMysteryUses(oShadow, myst.nMystId) >= MysteriesPerDay(oShadow, myst.nMystId, nClass)) // Used up all regular uses
        {
            SetBonusUses(myst.oShadow, nMystLevel);
            FloatingTextStringOnCreature("You have "+IntToString(BonusMysteriesPerDay(oShadow, nMystLevel)-GetBonusUses(oShadow, nMystLevel))+" bonus uses of level "+IntToString(nMystLevel)+" remaining", oShadow, FALSE);
        }    
        else
        {
            SetMysteryUses(myst.oShadow, myst.nMystId);
            FloatingTextStringOnCreature("You have "+IntToString(MysteriesPerDay(myst.oShadow, myst.nMystId, nClass)-GetMysteryUses(myst.oShadow, myst.nMystId))+" uses of " + GetMysteryName(myst.nMystId) + " remaining", oShadow, FALSE);
            FloatingTextStringOnCreature("You have "+IntToString(BonusMysteriesPerDay(oShadow, nMystLevel)-GetBonusUses(oShadow, nMystLevel))+" bonus uses of level "+IntToString(nMystLevel)+" remaining", oShadow, FALSE);
        }    
    }//end if

    if(DEBUG) DoDebug("EvaluateMystery(): Final result:\n" + DebugMystery2Str(myst));

    // Initiate mystery-related variable CleanUp
    //DelayCommand(0.5f, _CleanMysteryVariables(oShadow));

    return myst;
}

void UseMystery(int nMyst, int nClass, int nLevelOverride = 0)
{
    object oShadow = OBJECT_SELF;
    int bQuickened = FALSE;
    object oSkin   = GetPCSkin(oShadow);    
    int nMystDur   = StringToInt(Get2DACache("spells", "ConjTime", nMyst)) + StringToInt(Get2DACache("spells", "CastTime", nMyst));
    int nMystLevel = GetMysteryLevel(oShadow, nMyst);
    
    if(GetAbilityScore(oShadow, ABILITY_INTELLIGENCE, TRUE) < nMystLevel + 10)    
    {
        FloatingTextStringOnCreature("Your Intelligence score is too low to shadowcast this mystery", oShadow, FALSE);
        return;
    }      
    
    // Check uses per day. This is done here so that players don't waste an action on it
    if ((GetMysteryUses(oShadow, nMyst) >= MysteriesPerDay(oShadow, nMyst, nClass)) && (GetBonusUses(oShadow, nMystLevel) >= BonusMysteriesPerDay(oShadow, nMystLevel)))
    {
        FloatingTextStringOnCreature("You have used " + GetMysteryName(nMyst) + " the maximum amount of times today.", oShadow, FALSE);
        return;
    }      

    // Quicken mystery check
    if(nMystDur <= 6000                                 && // If the mystery could be quickened by having shadowcasting time of 1 round or less
       GetLocalInt(oShadow, METASHADOW_QUICKEN_VAR) &&     // And the shadowcaster has Quicken active
       TakeSwiftAction(oShadow))                           // And the shadowcaster can take a swift action
    {
        //Adding Auto-Quicken III for one round - deleted after casting is finished.
        itemproperty ipAutoQuicken = ItemPropertyBonusFeat(IP_CONST_NSB_AUTO_QUICKEN);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoQuicken, oSkin, nMystDur/1000.0f));
        bQuickened = TRUE;
        // Then clear the variable
        DeleteLocalInt(oShadow, METASHADOW_QUICKEN_VAR);          
    }

    if (nMyst == MYST_SHADOW_SKIN || nMyst == MYST_SHADOW_EVOCATION_CONV || nMyst == MYST_GREATER_SHADOW_EVO_CONV ||
        nMyst == MYST_GREATER_SHADOW_EVO || nMyst == MYST_SHADOW_EVOCATION || (nMyst == MYST_ECHO_SPELL && GetLocalInt(oShadow, "EchoedSpell"))) // These are immediate actions
    {
        //Adding Auto-Quicken III for one round - deleted after casting is finished.
        itemproperty ipAutoQuicken = ItemPropertyBonusFeat(IP_CONST_NSB_AUTO_QUICKEN);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoQuicken, oSkin, nMystDur/1000.0f));
        bQuickened = TRUE;
    }
    
    // SLAs and Supernaturals both ignore the Somatic component
    if(GetIsMysterySupernatural(oShadow, nMyst, nClass) || GetIsMysterySLA(oShadow, nMyst, nClass))
    {
        //Adding Auto-Still for one round - deleted after casting is finished. 7-9th level mysteries don't become SLA, hence lack of Still III
        itemproperty ipAutoStill = ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_AUTO_STILL_II);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoStill, oSkin, nMystDur/1000.0f));
        ipAutoStill = ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_AUTO_STILL_I);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoStill, oSkin, nMystDur/1000.0f));        
    }    
    // Supernaturals don't generate AoO, nor do casters with the Shadowcast feat in the right situation
    if(GetIsMysterySupernatural(oShadow, nMyst, nClass) || GetShadowCast(oShadow))
    {
        //Adding Improved Combat Casting for one round - deleted after casting is finished.
        itemproperty ipICC = ItemPropertyBonusFeat(IP_CONST_IMP_CC);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipICC, oSkin, nMystDur/1000.0f));        
    } 
    // Still mystery check. Both SLA and Su are automatically stilled.
    if(!GetIsMysterySupernatural(oShadow, nMyst, nClass) && !GetIsMysterySLA(oShadow, nMyst, nClass) && GetLocalInt(oShadow, METASHADOW_STILL_VAR))
    {
        //Adding Auto-Still for one round - deleted after casting is finished. 
        itemproperty ipAutoStill = ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_AUTO_STILL_II);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoStill, oSkin, nMystDur/1000.0f)); 
        ipAutoStill = ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_AUTO_STILL_I);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoStill, oSkin, nMystDur/1000.0f));    
        ipAutoStill = ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_AUTO_STILL_III);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoStill, oSkin, nMystDur/1000.0f));    
        // Then clear the variable
        DeleteLocalInt(oShadow, METASHADOW_STILL_VAR);          
    }    

    // Setup mystery-related variables
    ActionDoCommand(_SetMysteryVariables(oShadow, nClass, StringToInt(lookup_spell_innate(nMyst)), bQuickened));

    // cast the actual mystery
    ActionCastSpell(nMyst, nLevelOverride, 0, 0, METAMAGIC_NONE, CLASS_TYPE_INVALID, 0, 0, OBJECT_INVALID, FALSE);

    // Initiate mystery-related variable CleanUp
    ActionDoCommand(_CleanMysteryVariables(oShadow));
}

string DebugMystery2Str(struct mystery myst)
{
    string sRet;

    sRet += "oShadow = " + DebugObject2Str(myst.oShadow) + "\n";
    sRet += "bCanMyst = " + DebugBool2String(myst.bCanMyst) + "\n";
    sRet += "nShadowcasterLevel = "  + IntToString(myst.nShadowcasterLevel) + "\n";

    sRet += "bEmpower  = " + DebugBool2String(myst.bEmpower)  + "\n";
    sRet += "bExtend   = " + DebugBool2String(myst.bExtend)   + "\n";
    sRet += "bQuicken  = " + DebugBool2String(myst.bQuicken);//    + "\n";

    return sRet;
}

void ShadowcastDebugIgnoreConstraints(object oShadow)
{
    SetLocalInt(oShadow, MYST_DEBUG_IGNORE_CONSTRAINTS, TRUE);
    DelayCommand(0.0f, DeleteLocalInt(oShadow, MYST_DEBUG_IGNORE_CONSTRAINTS));
}

int GetMysteryUses(object oShadow, int nMystId)
{
    // This makes sure everything is stored using the proper number
    return GetLocalInt(oShadow, MYSTERY_USES + _GetMysterySpellId(nMystId));
}

int GetBonusUses(object oShadow, int nMystLevel)
{
    // This makes sure everything is stored using the proper number
    return GetLocalInt(oShadow, MYSTERY_BONUS_USES + IntToString(nMystLevel));
}

void SetMysteryUses(object oShadow, int nMystId)
{
    // Apprentice mysteries only for Warp Spell
    if(4 > GetMysteryLevel(oShadow, nMystId) && GetLocalInt(oShadow, "WarpSpellSuccess"))
    {
        DeleteLocalInt(oShadow, "WarpSpellSuccess");
        FloatingTextStringOnCreature("Warped Spell used", oShadow, FALSE);
        return;
    }
    if (nMystId == MYST_ECHO_SPELL && GetLocalInt(oShadow, "EchoedSpell")) 
        return; //This is a free use and doesn't count. 
        
    if (GetLocalInt(oShadow, "MysteryFreeUse")) 
        return; 
      
    if (GetLocalInt(oShadow, "InnateCounterSuccess") == GetMysteryLevel(oShadow, nMystId))
    {
        DeleteLocalInt(oShadow, "InnateCounterSuccess");
        FloatingTextStringOnCreature("Innate Counterspell used", oShadow, FALSE);
        return;
    }
        
    // This makes sure everything is stored using the proper number
    string sSpellId = _GetMysterySpellId(nMystId);
    // Uses are stored for each Mystery by SpellId
    int nNum = GetLocalInt(oShadow, MYSTERY_USES + sSpellId);
    // Store the number of times per day its been cast succesfully
    SetLocalInt(oShadow, MYSTERY_USES + sSpellId, (nNum + 1));
}

void SetBonusUses(object oShadow, int nMystLevel)
{
    // Uses are stored by level
    int nNum = GetLocalInt(oShadow, MYSTERY_BONUS_USES + IntToString(nMystLevel));
    // Store the number of times per day its been cast succesfully
    SetLocalInt(oShadow, MYSTERY_BONUS_USES + IntToString(nMystLevel), (nNum + 1));
}

void ClearMystLocalVars(object oShadow)
{
    // Uses are stored for each Mystery by SpellId
    // So we loop em all and blow em away
    // Because there are only 60, this should not TMI
    // i is the SpellId
    int i;
    for(i = 18352; i < 18429; i++)
    {
        DeleteLocalInt(oShadow, MYSTERY_USES + IntToString(i));
    }
    // Web Enhancement Mysteries
    for(i = 18579; i < 18590; i++)
    {
        DeleteLocalInt(oShadow, MYSTERY_USES + IntToString(i));
    }    
    for(i = 0; i < 10; i++)
    {
        DeleteLocalInt(oShadow, MYSTERY_BONUS_USES + IntToString(i));
    }        
}

int MysteriesPerDay(object oShadow, int nMystId, int nClass)
{
    if (nClass == CLASS_TYPE_SHADOWSMITH) return 1; // They never get more than this.

    int nUses = 1; //always get at least 1
    int nLevel = GetMysteryLevel(oShadow, nMystId);
    // Done this way so it doesn't count for feats or other misc boosts
    int nShadow = GetLevelByClass(nClass, oShadow) + GetShadowMagicPRCLevels(oShadow);
    
    //if(DEBUG) DoDebug("MysteriesPerDay(): GetMysteryLevel "+IntToString(nLevel));
    //if(DEBUG) DoDebug("MysteriesPerDay(): GetShadowcasterLevel "+IntToString(nShadow));
    
    if (nMystId == MYST_ECHO_SPELL && GetLocalInt(oShadow, "EchoedSpell")) 
        return 99; //This is a free use and doesn't count.
        
    if (GetLocalInt(oShadow, "MysteryFreeUse")) 
        return 99;            
    
    if (nShadow >= 13 && 4 > nLevel)
        nUses = 3;
    else if (nShadow >= 13 && 7 > nLevel && nLevel > 3)
        nUses = 2;    
    else if (nShadow >= 7 && 4 > nLevel)
        nUses = 2;     
        
    if (nShadow >= 13 && 4 > nLevel && GetHasFavoredMystery(oShadow, nMystId)) // Favored mystery can grant +1 use per day to Apprentice 
        nUses += 1;
    
    return nUses;
}

int BonusMysteriesPerDay(object oShadow, int nMystLevel)
{
    if(GetAbilityScore(oShadow, ABILITY_CHARISMA, TRUE) < nMystLevel + 10)
        return 0;
    int nSlots;

    // Both Mystery classes use Int for this
    int nAbilityMod = GetAbilityModifier(ABILITY_CHARISMA, oShadow);
    if (nAbilityMod >= nMystLevel) // Need an ability modifier at least equal to the spell level to gain bonus slots
        nSlots += ((nAbilityMod - nMystLevel) / 4) + 1;
    if(DEBUG) DoDebug("BonusMysteriesPerDay(): nSlots "+IntToString(nSlots));
    return nSlots;
}

string GetMysteryName(int nMystId)
{
    return GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nMystId)));
}

int GetIsMysterySupernatural(object oShadow, int nMystId, int nClass)
{
    if (nClass == CLASS_TYPE_SHADOWSMITH) return FALSE;
    int nLevel = GetMysteryLevel(oShadow, nMystId);
    int nShadow = GetShadowcasterLevel(oShadow);
    
    if (nShadow >= 13 && 4 > nLevel)
        return TRUE;
    if (nShadow >= 13 && 7 > nLevel && nLevel > 3 && GetHasFavoredMystery(oShadow, nMystId)) // Bump up Initiate
        return TRUE;        

    // If nothing returns TRUE, fail
    return FALSE;
}

int GetIsMysterySLA(object oShadow, int nMystId, int nClass)
{
    if (nClass == CLASS_TYPE_SHADOWSMITH) return FALSE;
    int nLevel = GetMysteryLevel(oShadow, nMystId);
    int nShadow = GetShadowcasterLevel(oShadow);
    
    if (nShadow >= 13 && 7 > nLevel && nLevel > 3)
        return TRUE;
    else if (nShadow >= 7 && 4 > nLevel)
        return TRUE;   
    else if (nShadow < 7 && 4 > nLevel && GetHasFavoredMystery(oShadow, nMystId)) // Bump up Apprentice
        return TRUE;
    if (nShadow < 13 && nShadow >= 7 && 7 > nLevel && nLevel > 3 && GetHasFavoredMystery(oShadow, nMystId)) // Bump up Initiate
        return TRUE; 
    if (nShadow >= 13 && nLevel >= 7 && GetHasFavoredMystery(oShadow, nMystId)) // Bump up Master
        return TRUE;        

    // If nothing returns TRUE, fail
    return FALSE;
}

int GetIsFundamental(int nMystId)
{
    if(nMystId == FUND_ARROW_DUSK ||
       nMystId == FUND_BLACK_CANDLE_LIGHT ||
       nMystId == FUND_BLACK_CANDLE_DARK  ||
       nMystId == FUND_CAUL_SHADOW        ||
       nMystId == FUND_MYSTIC_REFLECTIONS ||
       nMystId == FUND_SHADOW_HOOD        ||
       nMystId == FUND_SIGHT_OBSCURED     ||
       nMystId == FUND_UMBRAL_HAND        ||
       nMystId == FUND_WIDENED_EYES)
        return TRUE;

    return FALSE;
}

int GetHasFavoredMystery(object oShadow, int nMyst)
{
    if (DEBUG) DoDebug("GetHasFavoredMystery(): Mystery "+IntToString(nMyst));
    int nFavored, nReturn;
    switch(nMyst)
    {
        case MYST_BEND_PERSPECTIVE     : nFavored = FEAT_FAV_MYST_BENDPERSPECTIVE        ; break;
        case MYST_CARPET_SHADOW        : nFavored = FEAT_FAV_MYST_CARPETSHADOW           ; break;
        case MYST_DUSK_AND_DAWN_DUSK   : nFavored = FEAT_FAV_MYST_DUSKANDDAWN            ; break;
        case MYST_DUSK_AND_DAWN_DAWN   : nFavored = FEAT_FAV_MYST_DUSKANDDAWN            ; break;
        case MYST_LIFE_FADES           : nFavored = FEAT_FAV_MYST_LIFEFADES              ; break;
        case MYST_MESMERIZING_SHADE    : nFavored = FEAT_FAV_MYST_MESMERIZINGSHADE       ; break;
        case MYST_STEEL_SHADOWS        : nFavored = FEAT_FAV_MYST_STEELSHADOWS           ; break;
        case MYST_VOICE_SHADOW_APPROACH: nFavored = FEAT_FAV_MYST_VOICEOFSHADOW          ; break;
        case MYST_VOICE_SHADOW_DROP    : nFavored = FEAT_FAV_MYST_VOICEOFSHADOW          ; break;
        case MYST_VOICE_SHADOW_FALL    : nFavored = FEAT_FAV_MYST_VOICEOFSHADOW          ; break;
        case MYST_VOICE_SHADOW_FLEE    : nFavored = FEAT_FAV_MYST_VOICEOFSHADOW          ; break;
        case MYST_VOICE_SHADOW_HALT    : nFavored = FEAT_FAV_MYST_VOICEOFSHADOW          ; break;
        case MYST_BLACK_FIRE           : nFavored = FEAT_FAV_MYST_BLACKFIRE              ; break;
        case MYST_CONGRESS_SHADOWS     : nFavored = FEAT_FAV_MYST_CONGRESSSHADOWS        ; break;
        case MYST_FLESH_FAILS_STR      : nFavored = FEAT_FAV_MYST_FLESHFAILS             ; break;
        case MYST_FLESH_FAILS_DEX      : nFavored = FEAT_FAV_MYST_FLESHFAILS             ; break;
        case MYST_FLESH_FAILS_CON      : nFavored = FEAT_FAV_MYST_FLESHFAILS             ; break;
        case MYST_PIERCING_SIGHT       : nFavored = FEAT_FAV_MYST_PIERCINGSIGHT          ; break;
        case MYST_SHADOW_SKIN          : nFavored = FEAT_FAV_MYST_SHADOWSKIN             ; break;
        case MYST_SIGHT_ECLIPSED       : nFavored = FEAT_FAV_MYST_SIGHTECLIPSED          ; break;   
        case MYST_THOUGHTS_SHADOW_INT  : nFavored = FEAT_FAV_MYST_THOUGHTSSHADOW         ; break;
        case MYST_THOUGHTS_SHADOW_WIS  : nFavored = FEAT_FAV_MYST_THOUGHTSSHADOW         ; break;
        case MYST_THOUGHTS_SHADOW_CHA  : nFavored = FEAT_FAV_MYST_THOUGHTSSHADOW         ; break;
        case MYST_AFRAID_DARK          : nFavored = FEAT_FAV_MYST_AFRAIDOFTHEDARK        ; break;
        case MYST_CLINGING_DARKNESS    : nFavored = FEAT_FAV_MYST_CLINGINGDARKNESS       ; break;
        case MYST_DANCING_SHADOWS      : nFavored = FEAT_FAV_MYST_DANCINGSHADOWS         ; break;
        case MYST_FLICKER              : nFavored = FEAT_FAV_MYST_FLICKER                ; break;
        case MYST_KILLING_SHADOWS      : nFavored = FEAT_FAV_MYST_KILLINGSHADOWS         ; break;
        case MYST_SHARP_SHADOWS        : nFavored = FEAT_FAV_MYST_SHARPSHADOWS           ; break;
        case MYST_UMBRAL_TOUCH         : nFavored = FEAT_FAV_MYST_UMBRALTOUCH            ; break;
        case MYST_AURA_OF_SHADE        : nFavored = FEAT_FAV_MYST_AURAOFSHADE            ; break;
        case MYST_BOLSTER              : nFavored = FEAT_FAV_MYST_BOLSTER                ; break;
        case MYST_SHADOW_EVOCATION     : nFavored = FEAT_FAV_MYST_SHADOWEVOCATION        ; break;
        case MYST_SHADOW_VISION        : nFavored = FEAT_FAV_MYST_SHADOWVISION           ; break;
        case MYST_SHADOWS_FADE         : nFavored = FEAT_FAV_MYST_SHADOWSFADE            ; break;
        case MYST_STEP_SHADOW_SELF     : nFavored = FEAT_FAV_MYST_STEPINTOSHADOW         ; break;
        case MYST_STEP_SHADOW_PARTY    : nFavored = FEAT_FAV_MYST_STEPINTOSHADOW         ; break;
        case MYST_WARP_SPELL           : nFavored = FEAT_FAV_MYST_WARPSPELL              ; break;
        case MYST_CURTAIN_SHADOWS      : nFavored = FEAT_FAV_MYST_CURTAINSHADOWS         ; break;  
        case MYST_DARK_AIR             : nFavored = FEAT_FAV_MYST_DARKAIR                ; break;
        case MYST_ECHO_SPELL           : nFavored = FEAT_FAV_MYST_FEIGNLIFE              ; break;
        case MYST_FEIGN_LIFE           : nFavored = FEAT_FAV_MYST_DARKSOUL               ; break;
        case MYST_LANGUOR_SLOW         : nFavored = FEAT_FAV_MYST_LANGUOR                ; break;
        case MYST_LANGUOR_HOLD         : nFavored = FEAT_FAV_MYST_LANGUOR                ; break;
        case MYST_PASS_SHADOW_SELF     : nFavored = FEAT_FAV_MYST_PASSINTOSHADOW         ; break;
        case MYST_PASS_SHADOW_PARTY    : nFavored = FEAT_FAV_MYST_PASSINTOSHADOW         ; break;
        case MYST_UNRAVEL_DWEOMER      : nFavored = FEAT_FAV_MYST_UNRAVELDWEOMER         ; break;
        case MYST_FLOOD_SHADOW         : nFavored = FEAT_FAV_MYST_FLOODSHADOWS           ; break;
        case MYST_GREATER_SHADOW_EVO   : nFavored = FEAT_FAV_MYST_GREATERSHADOWEVOCATION ; break;
        case MYST_SHADOW_INVESTITURE   : nFavored = FEAT_FAV_MYST_SHADOWINVESTITURE      ; break;
        case MYST_SHADOW_STORM         : nFavored = FEAT_FAV_MYST_SHADOWSTORM            ; break;
        case MYST_SHADOWS_FADE_GREATER : nFavored = FEAT_FAV_MYST_SHADOWSFADE_GREATER    ; break;
        case MYST_UNVEIL               : nFavored = FEAT_FAV_MYST_UNVEIL                 ; break;
        case MYST_VOYAGE_SHADOW_SELF   : nFavored = FEAT_FAV_MYST_VOYAGESHADOW           ; break;
        case MYST_VOYAGE_SHADOW_PARTY  : nFavored = FEAT_FAV_MYST_VOYAGESHADOW           ; break;
        case MYST_DARK_SOUL            : nFavored = FEAT_FAV_MYST_DARKSOUL               ; break;
        case MYST_EPHEMERAL_IMAGE      : nFavored = FEAT_FAV_MYST_EPHEMERALIMAGE         ; break;
        case MYST_LIFE_FADES_GREATER   : nFavored = FEAT_FAV_MYST_LIFEFADESGREATER       ; break;   
        case MYST_PRISON_NIGHT         : nFavored = FEAT_FAV_MYST_PRISONNIGHT            ; break;
        case MYST_UMBRAL_SERVANT       : nFavored = FEAT_FAV_MYST_UMBRALSERVANT          ; break;
        case MYST_TRUTH_REVEALED       : nFavored = FEAT_FAV_MYST_TRUTHREVEALED          ; break;
        case MYST_FAR_SIGHT            : nFavored = FEAT_FAV_MYST_FARSIGHT               ; break;  
        case MYST_GR_FLESH_FAILS_STR   : nFavored = FEAT_FAV_MYST_GRFLESHFAILS           ; break;
        case MYST_GR_FLESH_FAILS_DEX   : nFavored = FEAT_FAV_MYST_GRFLESHFAILS           ; break;
        case MYST_GR_FLESH_FAILS_CON   : nFavored = FEAT_FAV_MYST_GRFLESHFAILS           ; break;
        case MYST_SHADOW_PLAGUE        : nFavored = FEAT_FAV_MYST_SHADOWPLAGUE           ; break;
        case MYST_SOUL_PUPPET          : nFavored = FEAT_FAV_MYST_SOULPUPPET             ; break;
        case MYST_TOMB_NIGHT           : nFavored = FEAT_FAV_MYST_TOMBNIGHT              ; break;
        case MYST_UMBRAL_BODY          : nFavored = FEAT_FAV_MYST_UMBRALBODY             ; break;
        case MYST_ARMY_SHADOW          : nFavored = FEAT_FAV_MYST_ARMYSHADOW             ; break;
        case MYST_CONSUME_ESSENCE      : nFavored = FEAT_FAV_MYST_CONSUMEESSENCE         ; break;
        case MYST_EPHEMERAL_STORM      : nFavored = FEAT_FAV_MYST_EPHEMERALSTORM         ; break;
        case MYST_REFLECTIONS          : nFavored = FEAT_FAV_MYST_REFLECTIONS            ; break;
        case MYST_SHADOW_SURGE         : nFavored = FEAT_FAV_MYST_SHADOWSURGE            ; break;
        case MYST_SHADOW_TIME          : nFavored = FEAT_FAV_MYST_SHADOWTIME             ; break;    
        case MYST_QUICKER_THAN_THE_EYE : nFavored = FEAT_FAV_MYST_QUICKERTHANTHEEYE      ; break;
        case MYST_TRAIL_OF_HAZE        : nFavored = FEAT_FAV_MYST_TRAILHAZE              ; break;
        case MYST_UMBRAL_FIST          : nFavored = FEAT_FAV_MYST_UMBRALFIST             ; break;
        case MYST_FEARFUL_GLOOM        : nFavored = FEAT_FAV_MYST_FEARFULGLOOM           ; break;
        case MYST_SICKENING_SHADOW     : nFavored = FEAT_FAV_MYST_SICKENINGSHADOW        ; break;
        case MYST_DEADLY_SHADE_DR      : nFavored = FEAT_FAV_MYST_DEADLYSHADE            ; break;
        case MYST_DEADLY_SHADE_NEG     : nFavored = FEAT_FAV_MYST_DEADLYSHADE            ; break;
        case MYST_GRASPING_SHADOWS     : nFavored = FEAT_FAV_MYST_GRASPINGSHADOWS        ; break;
        case MYST_MENAGERIE_OF_DARKNESS: nFavored = FEAT_FAV_MYST_MENAGERIEDARKNESS      ; break;
        case MYST_BLACK_LABYRINTH      : nFavored = FEAT_FAV_MYST_BLACKLABYRINTH         ; break;           
    }
    if(GetHasFeat(nFavored, oShadow))
        nReturn = 1;

    // If none of those trigger.
    return nReturn;
}

int GetShadowCast(object oShadow)
{
    if (DEBUG) DoDebug("GetShadowCast() enter");
    if (!GetHasFeat(FEAT_SHADOW_CAST, oShadow)) return FALSE; // Need the feat
    
    location lTarget = GetLocation(oShadow);
    int nCount, nReturn;

    // Use the function to get the closest creature as a target
    object oCount = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oCount))
    {
        if(GetIsEnemy(oCount, oShadow) && GetIsInMeleeRange(oShadow, oCount)) // Must be an enemy in melee range
        {
            nCount++;
            if (DEBUG) DoDebug("GetShadowCast() nCount "+IntToString(nCount));
        }
    //Select the next target within the spell shape.
    oCount = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    } 
    
    if (nCount > 1) return FALSE;

    return TRUE;
}