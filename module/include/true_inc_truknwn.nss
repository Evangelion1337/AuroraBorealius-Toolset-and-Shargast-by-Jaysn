//::///////////////////////////////////////////////
//:: Truenaming include: utterances known
//:: true_inc_truknwn
//::///////////////////////////////////////////////
/** @file
    Defines functions for adding & removing
    utterances known.

    Data stored:

    - For each Utterance list
    -- Total number of utterances known
    -- A modifier value to maximum utterances known on this list to account for feats and classes that add utterances
    -- An array related to utterances the knowledge of which is not dependent on character level
    --- Each array entry specifies the spells.2da row of the known utterance's class-specific entry
    -- For each character level on which utterances have been gained from this list
    --- An array of utterances gained on this level
    ---- Each array entry specifies the spells.2da row of the known utterance's class-specific entry

    @author Stratovarius
    @date   Created - 2006.07.18
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

// Included here to provide the values for the constants below
#include "prc_class_const"
#include "true_utter_const"

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int UTTERANCE_LIST_TRUENAMER     = CLASS_TYPE_TRUENAMER;

/// Special Utterance list. utterances gained via Expanded Knowledge, Psychic Chirurgery and similar sources
const int UTTERANCE_LIST_MISC          = CLASS_TYPE_INVALID;//-1;

const string _UTTERANCE_LIST_NAME_BASE     = "PRC_UtteranceList_";
const string _UTTERANCE_LIST_TOTAL_KNOWN   = "_TotalKnown";
const string _UTTERANCE_LIST_MODIFIER      = "_KnownModifier";
const string _UTTERANCE_LIST_MISC_ARRAY    = "_UtterancesKnownMiscArray";
const string _UTTERANCE_LIST_LEVEL_ARRAY   = "_UtterancesKnownLevelArray_";
const string _UTTERANCE_LIST_GENERAL_ARRAY = "_UtterancesKnownGeneralArray";


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Gives the creature the control feats for the given Utterance and marks the utterance
 * in a utterances known array.
 * If the utterance's data is already stored in one of the utterances known arrays for
 * the list or adding the utterance's data to the array fails, the function aborts.
 *
 * @param oCreature       The creature to gain the utterance
 * @param nList           The list the Utterance comes from. One of UTTERANCE_LIST_*
 * @param n2daRow         The 2da row in the lists's 2da file that specifies the utterance.
 * @param bLevelDependent If this is TRUE, the Utterance is tied to a certain level and can
 *                        be lost via level loss. If FALSE, the Utterance is not dependent
 *                        of a level and cannot be lost via level loss.
 * @param nLevelToTieTo   If bLevelDependent is TRUE, this specifies the level the utterance
 *                        is gained on. Otherwise, it's ignored.
 *                        The default value (-1) means that the current level of oCreature
 *                        will be used.
 * @param nLexicon           Type of the Utterance: Evolving Mind, Crafted Tool, or Perfected Map
 *
 * @return                TRUE if the Utterance was successfully stored and control feats added.
 *                        FALSE otherwise.
 */
int AddUtteranceKnown(object oCreature, int nList, int n2daRow, int nLexicon, int bLevelDependent = FALSE, int nLevelToTieTo = -1);

/**
 * Removes all utterances gained from each list on the given level.
 *
 * @param oCreature The creature whose utterances to remove
 * @param nLevel    The level to clear
 */
void RemoveUtterancesKnownOnLevel(object oCreature, int nLevel);

/**
 * Gets the value of the utterances known modifier, which is a value that is added
 * to the 2da-specified maximum utterances known to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to get
 * @param nList     The list the maximum utterances known from which the modifier
 *                  modifies. One of UTTERANCE_LIST_*
 * @param nLexicon     Type of the Utterance: Evolving Mind, Crafted Tool, or Perfected Map
 */
int GetKnownUtterancesModifier(object oCreature, int nList, int nLexicon);

/**
 * Sets the value of the utterances known modifier, which is a value that is added
 * to the 2da-specified maximum utterances known to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to set
 * @param nList     The list the maximum utterances known from which the modifier
 *                  modifies. One of UTTERANCE_LIST_*
 * @param nLexicon     Type of the Utterance: Evolving Mind, Crafted Tool, or Perfected Map
 */
void SetKnownUtterancesModifier(object oCreature, int nList, int nNewValue, int nLexicon);

/**
 * Gets the number of utterances a character character possesses from a
 * specific list and lexicon
 *
 * @param oCreature The creature whose utterances to check
 * @param nList     The list to check. One of UTTERANCE_LIST_*
 * @param nLexicon     Type of the Utterance: Evolving Mind, Crafted Tool, or Perfected Map
 * @return          The number of utterances known oCreature has from nList
 */
int GetUtteranceCount(object oCreature, int nList, int nLexicon);

/**
 * Gets the maximum number of utterances a character may posses from a given list
 * at this time. Calculated based on class levels, feats and a misceallenous
 * modifier. There are three Types of utterances, so it checks each seperately.
 *
 * @param oCreature Character to determine maximum utterances for
 * @param nList     UTTERANCE_LIST_* of the list to determine maximum utterances for
 * @param nLexicon     Type of the Utterance: Evolving Mind, Crafted Tool, or Perfected Map
 * @return          Maximum number of utterances that oCreature may know from the given list.
 */
int GetMaxUtteranceCount(object oCreature, int nList, int nLexicon);

/**
 * Determines whether a character has a given utterance, gained via some Utterance list.
 *
 * @param nUtter    utterance_* of the Utterance to test
 * @param oCreature Character to test for the possession of the utterance
 * @return          TRUE if the character has the utterance, FALSE otherwise
 */
int GetHasUtterance(int nUtter, object oCreature = OBJECT_SELF);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_item_props"
#include "inc_pers_array"
#include "prc_inc_nwscript"
#include "inc_lookups"
#include "prc_x2_itemprop"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _TruenameRecurseRemoveArray(object oCreature, string sArrayName, string sUtterFile, int nArraySize, int nCurIndex)
{
    if(DEBUG) DoDebug("_TruenameRecurseRemoveArray():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "sArrayName = '" + sArrayName + "'\n"
                    + "sUtterFile = '" + sUtterFile + "'\n"
                    + "nArraySize = " + IntToString(nArraySize) + "\n"
                    + "nCurIndex = " + IntToString(nCurIndex) + "\n"
                      );

    // Determine whether we've already parsed the whole array or not
    if(nCurIndex >= nArraySize)
    {
        if(DEBUG) DoDebug("_TruenameRecurseRemoveArray(): Running itemproperty removal loop.");
        // Loop over itemproperties on the skin and remove each match
        object oSkin = GetPCSkin(oCreature);
        itemproperty ipTest = GetFirstItemProperty(oSkin);
        while(GetIsItemPropertyValid(ipTest))
        {
            // Check if the itemproperty is a bonus feat that has been marked for removal
            if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_FEAT                                            &&
               GetLocalInt(oCreature, "PRC_UtterFeatRemovalMarker_" + IntToString(GetItemPropertySubType(ipTest)))
               )
            {
                if(DEBUG) DoDebug("_TruenameRecurseRemoveArray(): Removing bonus feat itemproperty:\n" + DebugIProp2Str(ipTest));
                // If so, remove it
                RemoveItemProperty(oSkin, ipTest);
            }

            ipTest = GetNextItemProperty(oSkin);
        }
    }
    // Still parsing the array
    else
    {
        // Set the marker
        string sName = "PRC_UtterFeatRemovalMarker_" + Get2DACache(sUtterFile, "IPFeatID",
                                                                   GetPowerfileIndexFromSpellID(persistant_array_get_int(oCreature, sArrayName, nCurIndex))
                                                                   );
        if(DEBUG) DoDebug("_TruenameRecurseRemoveArray(): Recursing through array, marker set:\n" + sName);

        SetLocalInt(oCreature, sName, TRUE);
        // Recurse to next array index
        _TruenameRecurseRemoveArray(oCreature, sArrayName, sUtterFile, nArraySize, nCurIndex + 1);
        // After returning, delete the local
        DeleteLocalInt(oCreature, sName);
    }
}

void _RemoveUtteranceArray(object oCreature, int nList, int nLevel, int nLexicon)
{
    if(DEBUG) DoDebug("_RemoveUtteranceArray():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "nList = " + IntToString(nList) + "\n"
                    + "nLexicon = " + IntToString(nLexicon) + "\n"
                      );

    string sBase  = _UTTERANCE_LIST_NAME_BASE + IntToString(nList) + IntToString(nLexicon);
    string sArray = sBase + _UTTERANCE_LIST_LEVEL_ARRAY + IntToString(nLevel);
    int nSize = persistant_array_get_size(oCreature, sArray);

    // Reduce the total by the array size
    SetPersistantLocalInt(oCreature, sBase + _UTTERANCE_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oCreature, sBase + _UTTERANCE_LIST_TOTAL_KNOWN) - nSize
                          );

    // Remove each Utterance in the array
    _TruenameRecurseRemoveArray(oCreature, sArray, GetAMSDefinitionFileName(nList), nSize, 0);

    // Remove the array itself
    persistant_array_delete(oCreature, sArray);
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int AddUtteranceKnown(object oCreature, int nList, int n2daRow, int nLexicon, int bLevelDependent = FALSE, int nLevelToTieTo = -1)
{
    string sBase      = _UTTERANCE_LIST_NAME_BASE + IntToString(nList) + IntToString(nLexicon);
    string sArray     = sBase;
    string sUtterFile = GetAMSDefinitionFileName(nList);
    string sTestArray;
    int i, j, nSize, bReturn;

    // Get the spells.2da row corresponding to the cls_psipw_*.2da row
    int nSpells2daRow = StringToInt(Get2DACache(sUtterFile, "SpellID", n2daRow));

    // Determine the array name.
    if(bLevelDependent)
    {
        // If no level is specified, default to the creature's current level
        if(nLevelToTieTo == -1)
            nLevelToTieTo = GetHitDice(oCreature);

        sArray += _UTTERANCE_LIST_LEVEL_ARRAY + IntToString(nLevelToTieTo);
    }
    else
    {
        sArray += _UTTERANCE_LIST_GENERAL_ARRAY;
    }

    // Make sure the Utterance isn't already in an array. If it is, abort and return FALSE
    // Loop over each level array and check that it isn't there.
    for(i = 1; i <= GetHitDice(oCreature); i++)
    {
        sTestArray = sBase + _UTTERANCE_LIST_LEVEL_ARRAY + IntToString(i);
        if(persistant_array_exists(oCreature, sTestArray))
        {
            nSize = persistant_array_get_size(oCreature, sTestArray);
            for(j = 0; j < nSize; j++)
                if(persistant_array_get_int(oCreature, sArray, j) == nSpells2daRow)
                    return FALSE;
        }
    }
    // Check the non-level-dependent array
    sTestArray = sBase + _UTTERANCE_LIST_GENERAL_ARRAY;
    if(persistant_array_exists(oCreature, sTestArray))
    {
        nSize = persistant_array_get_size(oCreature, sTestArray);
        for(j = 0; j < nSize; j++)
            if(persistant_array_get_int(oCreature, sArray, j) == nSpells2daRow)
                return FALSE;
    }

    // All checks are made, now start adding the new utterance
    // Create the array if it doesn't exist yet
    if(!persistant_array_exists(oCreature, sArray))
        persistant_array_create(oCreature, sArray);

    // Store the Utterance in the array
    if(persistant_array_set_int(oCreature, sArray, persistant_array_get_size(oCreature, sArray), nSpells2daRow) != SDL_SUCCESS)
    {
        if(DEBUG) DoDebug("true_inc_truknwn: AddUtteranceKnown(): ERROR: Unable to add Utterance to known array\n"
                        + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                        + "nList = " + IntToString(nList) + "\n"
                        + "nLexicon = " + IntToString(nLexicon) + "\n"
                        + "n2daRow = " + IntToString(n2daRow) + "\n"
                        + "bLevelDependent = " + DebugBool2String(bLevelDependent) + "\n"
                        + "nLevelToTieTo = " + IntToString(nLevelToTieTo) + "\n"
                        + "nSpells2daRow = " + IntToString(nSpells2daRow) + "\n"
                          );
        return FALSE;
    }

    // Increment utterances known total
    SetPersistantLocalInt(oCreature, sBase + _UTTERANCE_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oCreature, sBase + _UTTERANCE_LIST_TOTAL_KNOWN) + 1
                          );

    // Give the utterance's control feats
    object oSkin        = GetPCSkin(oCreature);
    string sUtterFeatIP = Get2DACache(sUtterFile, "IPFeatID", n2daRow);
    itemproperty ipFeat = PRCItemPropertyBonusFeat(StringToInt(sUtterFeatIP));
    IPSafeAddItemProperty(oSkin, ipFeat, 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    // Second Utterance feat, if any
    sUtterFeatIP = Get2DACache(sUtterFile, "IPFeatID2", n2daRow);
    if(sUtterFeatIP != "")
    {
        ipFeat = PRCItemPropertyBonusFeat(StringToInt(sUtterFeatIP));
        IPSafeAddItemProperty(oSkin, ipFeat, 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    }

    return TRUE;
}

void RemoveUtterancesKnownOnLevel(object oCreature, int nLevel)
{
    if(DEBUG) DoDebug("true_inc_truknwn: RemoveUtterancesKnownOnLevel():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "nLevel = " + IntToString(nLevel) + "\n"
                      );

    string sPostFix = _UTTERANCE_LIST_LEVEL_ARRAY + IntToString(nLevel);
    // For each Utterance list and lexicon, determine if an array exists for this level.
    int nLexicon;
    for(nLexicon = LEXICON_MIN_VALUE;  nLexicon <= LEXICON_MAX_VALUE; nLexicon++)
    {
        if(persistant_array_exists(oCreature, _UTTERANCE_LIST_NAME_BASE + IntToString(UTTERANCE_LIST_TRUENAMER) + IntToString(nLexicon) + sPostFix))
            _RemoveUtteranceArray(oCreature, UTTERANCE_LIST_TRUENAMER, nLevel, nLexicon);

        if(persistant_array_exists(oCreature, _UTTERANCE_LIST_NAME_BASE + IntToString(UTTERANCE_LIST_MISC) + IntToString(nLexicon) + sPostFix))
            _RemoveUtteranceArray(oCreature, UTTERANCE_LIST_MISC, nLevel, nLexicon);
    }
}

int GetKnownUtterancesModifier(object oCreature, int nList, int nLexicon)
{
    return GetPersistantLocalInt(oCreature, _UTTERANCE_LIST_NAME_BASE + IntToString(nList) + IntToString(nLexicon) + _UTTERANCE_LIST_MODIFIER);
}

void SetKnownUtterancesModifier(object oCreature, int nList, int nNewValue, int nLexicon)
{
    SetPersistantLocalInt(oCreature, _UTTERANCE_LIST_NAME_BASE + IntToString(nList) + IntToString(nLexicon) + _UTTERANCE_LIST_MODIFIER, nNewValue);
}

int GetUtteranceCount(object oCreature, int nList, int nLexicon)
{
    return GetPersistantLocalInt(oCreature, _UTTERANCE_LIST_NAME_BASE + IntToString(nList) + IntToString(nLexicon) + _UTTERANCE_LIST_TOTAL_KNOWN);
}

int GetMaxUtteranceCount(object oCreature, int nList, int nLexicon)
{
    int nMaxUtterances = 0;
    if(DEBUG) DoDebug("GetMaxUtteranceCount(" + IntToString(nList) + ", " + IntToString(nLexicon) + ", " + GetName(oCreature) + ")");
    switch(nList)
    {
        case UTTERANCE_LIST_TRUENAMER:{
            // Determine base utterances known
            int nLevel = GetLevelByClass(CLASS_TYPE_TRUENAMER, oCreature);
            if(nLevel == 0)
                break;
                if      (LEXICON_EVOLVING_MIND == nLexicon)
                    nMaxUtterances = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_TRUENAMER), "EvolvingMind", nLevel - 1));
                else if (LEXICON_CRAFTED_TOOL  == nLexicon)
                    nMaxUtterances = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_TRUENAMER), "CraftedTool",  nLevel - 1));
                else if (LEXICON_PERFECTED_MAP == nLexicon)
                    nMaxUtterances = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_TRUENAMER), "PerfectedMap", nLevel - 1));

            // Calculate feats
	    if(DEBUG) DoDebug("case UTTERANCE_LIST_TRUENAMER:{" + IntToString(nMaxUtterances));
            // Add in the custom modifier
            nMaxUtterances += GetKnownUtterancesModifier(oCreature, nList, nLexicon);
            break;
        }
        case UTTERANCE_LIST_MISC:
            if(DEBUG) DoDebug("GetMaxUtteranceCount(): ERROR: Using unfinished Utterance list!");
            break;

        default:{
            string sErr = "GetMaxUtteranceCount(): ERROR: Unknown Utterance list value: " + IntToString(nList) + IntToString(nLexicon);
            if(DEBUG) DoDebug(sErr);
            else      WriteTimestampedLogEntry(sErr);
        }
    }

    return nMaxUtterances;
}

int GetHasUtterance(int nUtter, object oCreature = OBJECT_SELF)
{
    if((GetLevelByClass(CLASS_TYPE_TRUENAMER, oCreature)
        && GetHasFeat(GetClassFeatFromPower(nUtter, CLASS_TYPE_TRUENAMER), oCreature)
        )
        // add new truenaming classes here
       )
        return TRUE;
    return FALSE;
}

string DebugListKnownUtterances(object oCreature)
{
    string sReturn = "Utterances known by " + DebugObject2Str(oCreature) + ":\n";
    int i, j, k, numUtterLists = 6;
    int nUtterList, nSize;
    string sTemp, sArray, sArrayBase, sUtterFile;
    // Loop over all Utterance lists
    for(i = 1; i <= numUtterLists; i++)
    {
        // Some padding
        sReturn += "  ";
        // Get the Utterance list for this loop
        switch(i)
        {
            case 1: nUtterList = UTTERANCE_LIST_TRUENAMER;      sReturn += "Truenamer";       break;

            // This should always be last
            case 2: nUtterList = UTTERANCE_LIST_MISC;           sReturn += "Misceallenous";   break;
        }
        sReturn += " utterances known:\n";

        // Determine if the character has any utterances from this list
        sUtterFile = GetAMSDefinitionFileName(nUtterList);
        sArrayBase = _UTTERANCE_LIST_NAME_BASE + IntToString(nUtterList);

        // Loop over levels
        for(j = 1; j <= GetHitDice(oCreature); j++)
        {
            sArray = sArrayBase + _UTTERANCE_LIST_LEVEL_ARRAY + IntToString(j);
            if(persistant_array_exists(oCreature, sArray))
            {
                sReturn += "   Gained on level " + IntToString(j) + ":\n";
                nSize = persistant_array_get_size(oCreature, sArray);
                for(k = 0; k < nSize; k++)
                    sReturn += "    " + GetStringByStrRef(StringToInt(Get2DACache(sUtterFile, "Name",
                                                                                  GetPowerfileIndexFromSpellID(persistant_array_get_int(oCreature, sArray, k))
                                                                                  )
                                                                      )
                                                          )
                            + "\n";
            }
        }

        // Non-leveldependent utterances
        sArray = sArrayBase + _UTTERANCE_LIST_GENERAL_ARRAY;
        if(persistant_array_exists(oCreature, sArray))
        {
            sReturn += "   Non-leveldependent:\n";
            nSize = persistant_array_get_size(oCreature, sArray);
            for(k = 0; k < nSize; k++)
                sReturn += "    " + GetStringByStrRef(StringToInt(Get2DACache(sUtterFile, "Name",
                                                                                  GetPowerfileIndexFromSpellID(persistant_array_get_int(oCreature, sArray, k))
                                                                                  )
                                                                      )
                                                          )
                        + "\n";
        }
    }

    return sReturn;
}
// Test main
//void main(){}