//::///////////////////////////////////////////////
//:: Invocation include: Invocations Known
//:: inv_inc_invknown
//::///////////////////////////////////////////////
/** @file
    Defines functions for adding & removing
    Invocations known.

    Data stored:

    - For each Class list
    -- Total number of Invocations known
    -- A modifier value to maximum Invocations known on this list to account for feats and classes that add Invocations
    -- An array related to Invocations the knowledge of which is not dependent on character level
    --- Each array entry specifies the spells.2da row of the known Invocations's class-specific entry
    -- For each character level on which Invocations have been gained from this list
    --- An array of Invocations gained on this level
    ---- Each array entry specifies the spells.2da row of the known Invocations's class-specific entry

    @author Fox
    @date   Created - 2008.01.25
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

// Included here to provide the values for the constants below
#include "prc_class_const"

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int INVOCATION_LIST_DRAGONFIRE_ADEPT = CLASS_TYPE_DRAGONFIRE_ADEPT;
const int INVOCATION_LIST_WARLOCK          = CLASS_TYPE_WARLOCK;
const int INVOCATION_LIST_DRAGON_SHAMAN    = CLASS_TYPE_DRAGON_SHAMAN;

/// Special Maneuver list. Maneuvers gained via Extra Invocation or other sources.
const int INVOCATION_LIST_EXTRA          = CLASS_TYPE_INVALID;//-1;
const int INVOCATION_LIST_EXTRA_EPIC     = /*CLASS_TYPE_INVALID - 1;*/-2;   //needs a constant in there to compile properly

const string _INVOCATION_LIST_NAME_BASE     = "PRC_InvocationList_";
const string _INVOCATION_LIST_TOTAL_KNOWN   = "_TotalKnown";
const string _INVOCATION_LIST_MODIFIER      = "_KnownModifier";
const string _INVOCATION_LIST_EXTRA_ARRAY    = "_InvocationsKnownExtraArray";
const string _INVOCATION_LIST_EXTRA_EPIC_ARRAY    = "_InvocationsKnownExtraEpicArray";
const string _INVOCATION_LIST_LEVEL_ARRAY   = "_InvocationsKnownLevelArray_";
const string _INVOCATION_LIST_GENERAL_ARRAY = "_InvocationsKnownGeneralArray";


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Gives the creature the control feats for the given Invocation and marks the Invocation
 * in a Invocations known array.
 * If the Invocation's data is already stored in one of the Invocations known arrays for
 * the list or adding the Invocation's data to the array fails, the function aborts.
 *
 * @param oCreature       The creature to gain the Invocation
 * @param nList           The list the Invocation comes from. One of INVOCATION_LIST_*
 * @param n2daRow         The 2da row in the lists's 2da file that specifies the Invocation.
 * @param bLevelDependent If this is TRUE, the Invocation is tied to a certain level and can
 *                        be lost via level loss. If FALSE, the Invocation is not dependent
 *                        of a level and cannot be lost via level loss.
 * @param nLevelToTieTo   If bLevelDependent is TRUE, this specifies the level the Invocation
 *                        is gained on. Otherwise, it's ignored.
 *                        The default value (-1) means that the current level of oCreature
 *                        will be used.
 *
 * @return                TRUE if the Invocation was successfully stored and control feats added.
 *                        FALSE otherwise.
 */
int AddInvocationKnown(object oCreature, int nList, int n2daRow, int bLevelDependent = FALSE, int nLevelToTieTo = -1);

/**
 * Removes all Invocations gained from each list on the given level.
 *
 * @param oCreature The creature whose Invocations to remove
 * @param nLevel    The level to clear
 */
void RemoveInvocationsKnownOnLevel(object oCreature, int nLevel);

/**
 * Gets the value of the Invocations known modifier, which is a value that is added
 * to the 2da-specified maximum Invocations known to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to get
 * @param nList     The list the maximum Invocations known from which the modifier
 *                  modifies. One of INVOCATION_LIST_*
 */
int GetKnownInvocationsModifier(object oCreature, int nList);

/**
 * Sets the value of the Invocations known modifier, which is a value that is added
 * to the 2da-specified maximum Invocations known to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to set
 * @param nList     The list the maximum Invocations known from which the modifier
 *                  modifies. One of INVOCATION_LIST_*
 */
void SetKnownInvocationsModifier(object oCreature, int nList, int nNewValue);

/**
 * Gets the number of Invocations a character character possesses from a
 * specific list and lexicon
 *
 * @param oCreature The creature whose Invocations to check
 * @param nList     The list to check. One of INVOCATION_LIST_*
 * @return          The number of Invocations known oCreature has from nList
 */
int GetInvocationCount(object oCreature, int nList);

/**
 * Gets the maximum number of Invocations a character may posses from a given list
 * at this time. Calculated based on class levels, feats and a misceallenous
 * modifier. There are three Types of Invocations, so it checks each seperately.
 *
 * @param oCreature Character to determine maximum Invocations for
 * @param nList     INVOCATION_LIST_* of the list to determine maximum Invocations for
 * @return          Maximum number of Invocations that oCreature may know from the given list.
 */
int GetMaxInvocationCount(object oCreature, int nList);

/**
 * Determines whether a character has a given Invocation, gained via some Invocation list.
 *
 * @param nInvocation INVOKE_* of the Invocation to test
 * @param oCreature   Character to test for the possession of the Invocation
 * @return            TRUE if the character has the Invocation, FALSE otherwise
 */
int GetHasInvocation(int nInvocation, object oCreature = OBJECT_SELF);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

int GetPrimaryInvocationClass(object oCreature = OBJECT_SELF);
int GetInvocationPRCLevels(object oCaster);

#include "inc_item_props"
#include "prc_x2_itemprop"
#include "inc_lookups"
#include "prc_inc_nwscript"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _InvocationRecurseRemoveArray(object oCreature, string sArrayName, string sInvocFile, int nArraySize, int nCurIndex)
{
    if(DEBUG) DoDebug("_InvocationRecurseRemoveArray():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "sArrayName = '" + sArrayName + "'\n"
                    + "sInvocFile = '" + sInvocFile + "'\n"
                    + "nArraySize = " + IntToString(nArraySize) + "\n"
                    + "nCurIndex = " + IntToString(nCurIndex) + "\n"
                      );

    // Determine whether we've already parsed the whole array or not
    if(nCurIndex >= nArraySize)
    {
        if(DEBUG) DoDebug("_InvocationRecurseRemoveArray(): Running itemproperty removal loop.");
        // Loop over itemproperties on the skin and remove each match
        object oSkin = GetPCSkin(oCreature);
        itemproperty ipTest = GetFirstItemProperty(oSkin);
        while(GetIsItemPropertyValid(ipTest))
        {
            // Check if the itemproperty is a bonus feat that has been marked for removal
            if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_FEAT                                            &&
               GetLocalInt(oCreature, "PRC_InvocFeatRemovalMarker_" + IntToString(GetItemPropertySubType(ipTest)))
               )
            {
                if(DEBUG) DoDebug("_InvocationRecurseRemoveArray(): Removing bonus feat itemproperty:\n" + DebugIProp2Str(ipTest));
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
        string sName = "PRC_InvocFeatRemovalMarker_" + Get2DACache(sInvocFile, "IPFeatID",
                                                                   GetPowerfileIndexFromSpellID(persistant_array_get_int(oCreature, sArrayName, nCurIndex))
                                                                   );
        if(DEBUG) DoDebug("_InvocationRecurseRemoveArray(): Recursing through array, marker set:\n" + sName);

        SetLocalInt(oCreature, sName, TRUE);
        // Recurse to next array index
        _InvocationRecurseRemoveArray(oCreature, sArrayName, sInvocFile, nArraySize, nCurIndex + 1);
        // After returning, delete the local
        DeleteLocalInt(oCreature, sName);
    }
}

void _RemoveInvocationArray(object oCreature, int nList, int nLevel)
{
    if(DEBUG) DoDebug("_RemoveInvocationArray():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "nList = " + IntToString(nList) + "\n"
                      );

    string sBase  = _INVOCATION_LIST_NAME_BASE + IntToString(nList);
    string sArray = sBase + _INVOCATION_LIST_LEVEL_ARRAY + IntToString(nLevel);
    int nSize = persistant_array_get_size(oCreature, sArray);

    // Reduce the total by the array size
    SetPersistantLocalInt(oCreature, sBase + _INVOCATION_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oCreature, sBase + _INVOCATION_LIST_TOTAL_KNOWN) - nSize
                          );

    // Remove each Invocation in the array
    _InvocationRecurseRemoveArray(oCreature, sArray, GetAMSDefinitionFileName(nList), nSize, 0);

    // Remove the array itself
    persistant_array_delete(oCreature, sArray);
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int AddInvocationKnown(object oCreature, int nList, int n2daRow, int bLevelDependent = FALSE, int nLevelToTieTo = -1)
{
    string sBase      = _INVOCATION_LIST_NAME_BASE + IntToString(nList);
    string sArray     = sBase;
    string sPowerFile = GetAMSDefinitionFileName(/*PowerListToClassType(*/nList/*)*/);
    if(nList == -2 || nList == CLASS_TYPE_INVALID)
    {
        sPowerFile = GetAMSDefinitionFileName(GetPrimaryInvocationClass(oCreature));
    }
    string sTestArray;
    int i, j, nSize, bReturn;

    // Get the spells.2da row corresponding to the cls_psipw_*.2da row
    int nSpells2daRow = StringToInt(Get2DACache(sPowerFile, "SpellID", n2daRow));

    // Determine the array name.
    if(bLevelDependent)
    {
        // If no level is specified, default to the creature's current level
        if(nLevelToTieTo == -1)
            nLevelToTieTo = GetHitDice(oCreature);

        sArray += _INVOCATION_LIST_LEVEL_ARRAY + IntToString(nLevelToTieTo);
    }
    else
    {
        sArray += _INVOCATION_LIST_GENERAL_ARRAY;
    }

    // Make sure the power isn't already in an array. If it is, abort and return FALSE
    // Loop over each level array and check that it isn't there.
    if(DEBUG) DoDebug("inv_inc_invknown: Checking first array set for duplicates.");
    for(i = 1; i <= GetHitDice(oCreature); i++)
    {
        sTestArray = sBase + _INVOCATION_LIST_LEVEL_ARRAY + IntToString(i);
        if(persistant_array_exists(oCreature, sTestArray))
        {
            nSize = persistant_array_get_size(oCreature, sTestArray);
            for(j = 0; j < nSize; j++)
                if(persistant_array_get_int(oCreature, sArray, j) == nSpells2daRow)
                    return FALSE;
        }
    }
    // Check the non-level-dependent array
    if(DEBUG) DoDebug("inv_inc_invknown: Checking second array set for duplicates.");
    sTestArray = sBase + _INVOCATION_LIST_GENERAL_ARRAY;
    if(persistant_array_exists(oCreature, sTestArray))
    {
        nSize = persistant_array_get_size(oCreature, sTestArray);
        for(j = 0; j < nSize; j++)
            if(persistant_array_get_int(oCreature, sArray, j) == nSpells2daRow)
                return FALSE;
    }

    // All checks are made, now start adding the new power
    // Create the array if it doesn't exist yet
    if(!persistant_array_exists(oCreature, sArray))
        persistant_array_create(oCreature, sArray);

    // Store the power in the array
    if(DEBUG) DoDebug("inv_inc_invknown: Adding to invocation array.");
    if(persistant_array_set_int(oCreature, sArray, persistant_array_get_size(oCreature, sArray), nSpells2daRow) != SDL_SUCCESS)
    {
        if(DEBUG) DoDebug("inv_inc_invknown: AddPowerKnown(): ERROR: Unable to add power to known array\n"
                        + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                        + "nList = " + IntToString(nList) + "\n"
                        + "n2daRow = " + IntToString(n2daRow) + "\n"
                        + "bLevelDependent = " + DebugBool2String(bLevelDependent) + "\n"
                        + "nLevelToTieTo = " + IntToString(nLevelToTieTo) + "\n"
                        + "nSpells2daRow = " + IntToString(nSpells2daRow) + "\n"
                          );
        return FALSE;
    }

    // Increment Invocations known total
    SetPersistantLocalInt(oCreature, sBase + _INVOCATION_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oCreature, sBase + _INVOCATION_LIST_TOTAL_KNOWN) + 1
                          );

    // Give the power's control feats
    object oSkin        = GetPCSkin(oCreature);
    string sPowerFeatIP = Get2DACache(sPowerFile, "IPFeatID", n2daRow);
    itemproperty ipFeat = PRCItemPropertyBonusFeat(StringToInt(sPowerFeatIP));
    IPSafeAddItemProperty(oSkin, ipFeat, 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    // Second power feat, if any
    sPowerFeatIP = Get2DACache(sPowerFile, "IPFeatID2", n2daRow);
    if(sPowerFeatIP != "")
    {
        ipFeat = PRCItemPropertyBonusFeat(StringToInt(sPowerFeatIP));
        IPSafeAddItemProperty(oSkin, ipFeat, 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    }

    return TRUE;
}

void RemoveInvocationsKnownOnLevel(object oCreature, int nLevel)
{
    if(DEBUG) DoDebug("inv_inc_invknown: RemoveInvocationKnownOnLevel():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "nLevel = " + IntToString(nLevel) + "\n"
                      );

    string sPostFix = _INVOCATION_LIST_LEVEL_ARRAY + IntToString(nLevel);
    // For each Invocation list, determine if an array exists for this level.
    if(persistant_array_exists(oCreature, _INVOCATION_LIST_NAME_BASE + IntToString(INVOCATION_LIST_DRAGONFIRE_ADEPT) + sPostFix))
        // If one does exist, clear it
        _RemoveInvocationArray(oCreature, INVOCATION_LIST_DRAGONFIRE_ADEPT, nLevel);

    if(persistant_array_exists(oCreature, _INVOCATION_LIST_NAME_BASE + IntToString(INVOCATION_LIST_WARLOCK) + sPostFix))
        _RemoveInvocationArray(oCreature, INVOCATION_LIST_WARLOCK, nLevel);

    if(persistant_array_exists(oCreature, _INVOCATION_LIST_NAME_BASE + IntToString(INVOCATION_LIST_DRAGON_SHAMAN) + sPostFix))
        _RemoveInvocationArray(oCreature, INVOCATION_LIST_DRAGON_SHAMAN, nLevel);

    if(persistant_array_exists(oCreature, _INVOCATION_LIST_NAME_BASE + IntToString(INVOCATION_LIST_EXTRA) + sPostFix))
        _RemoveInvocationArray(oCreature, INVOCATION_LIST_EXTRA, nLevel);

    if(persistant_array_exists(oCreature, _INVOCATION_LIST_NAME_BASE + IntToString(INVOCATION_LIST_EXTRA_EPIC) + sPostFix))
        _RemoveInvocationArray(oCreature, INVOCATION_LIST_EXTRA_EPIC, nLevel);
}

int GetKnownInvocationsModifier(object oCreature, int nList)
{
    return GetPersistantLocalInt(oCreature, _INVOCATION_LIST_NAME_BASE + IntToString(nList) + _INVOCATION_LIST_MODIFIER);
}

void SetKnownInvocationsModifier(object oCreature, int nList, int nNewValue)
{
    SetPersistantLocalInt(oCreature, _INVOCATION_LIST_NAME_BASE + IntToString(nList) + _INVOCATION_LIST_MODIFIER, nNewValue);
}

int GetInvocationCount(object oCreature, int nList)
{
    return GetPersistantLocalInt(oCreature, _INVOCATION_LIST_NAME_BASE + IntToString(nList) + _INVOCATION_LIST_TOTAL_KNOWN);
}

int GetMaxInvocationCount(object oCreature, int nList)
{
    int nMaxInvocations = 0;

    switch(nList)
    {
        case INVOCATION_LIST_DRAGONFIRE_ADEPT:{
            // Determine base Invocations known
            int nLevel = GetLevelByClass(CLASS_TYPE_DRAGONFIRE_ADEPT, oCreature);
                nLevel += GetPrimaryInvocationClass(oCreature) == CLASS_TYPE_DRAGONFIRE_ADEPT ? GetInvocationPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxInvocations = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_DRAGONFIRE_ADEPT), "InvocationKnown", nLevel - 1));

            // Calculate feats

            // Add in the custom modifier
            nMaxInvocations += GetKnownInvocationsModifier(oCreature, nList);
            break;
        }

        case INVOCATION_LIST_WARLOCK:{
            // Determine base Invocations known
            int nLevel = GetLevelByClass(CLASS_TYPE_WARLOCK, oCreature);
                nLevel += GetPrimaryInvocationClass(oCreature) == CLASS_TYPE_WARLOCK ? GetInvocationPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxInvocations = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_WARLOCK), "InvocationKnown", nLevel - 1));

            // Calculate feats

            // Add in the custom modifier
            nMaxInvocations += GetKnownInvocationsModifier(oCreature, nList);
            break;
        }
 
        case INVOCATION_LIST_DRAGON_SHAMAN:{
            // Determine base Invocations known
            int nLevel = GetLevelByClass(CLASS_TYPE_DRAGON_SHAMAN, oCreature);
                nLevel += GetPrimaryInvocationClass(oCreature) == CLASS_TYPE_DRAGON_SHAMAN ? GetInvocationPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxInvocations = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_DRAGON_SHAMAN), "InvocationKnown", nLevel - 1));

            // Calculate feats

            // Add in the custom modifier
            nMaxInvocations += GetKnownInvocationsModifier(oCreature, nList);
            break;
        }

        case INVOCATION_LIST_EXTRA:
            nMaxInvocations = GetHasFeat(FEAT_EXTRA_INVOCATION_I, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_II, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_III, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_IV, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_V, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_VI, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_VII, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_VIII, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_IX, oCreature) +
                               GetHasFeat(FEAT_EXTRA_INVOCATION_X, oCreature);
            break;

        case INVOCATION_LIST_EXTRA_EPIC:
            nMaxInvocations = GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_I, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_II, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_III, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_IV, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_V, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_VI, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_VII, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_VIII, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_IX, oCreature) +
                               GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_X, oCreature);
            break;

        default:{
            string sErr = "GetMaxInvocationCount(): ERROR: Unknown power list value: " + IntToString(nList);
            if(DEBUG) DoDebug(sErr);
            else      WriteTimestampedLogEntry(sErr);
        }
    }

    return nMaxInvocations;
}

int GetHasInvocation(int nInvocation, object oCreature = OBJECT_SELF)
{
    if((GetLevelByClass(CLASS_TYPE_DRAGONFIRE_ADEPT, oCreature)
        && GetHasFeat(GetClassFeatFromPower(nInvocation, CLASS_TYPE_DRAGONFIRE_ADEPT), oCreature)
        ) ||
        (GetLevelByClass(CLASS_TYPE_WARLOCK, oCreature)
        && GetHasFeat(GetClassFeatFromPower(nInvocation, CLASS_TYPE_WARLOCK), oCreature)
        ) ||
         (GetLevelByClass(CLASS_TYPE_DRAGON_SHAMAN, oCreature)
        && GetHasFeat(GetClassFeatFromPower(nInvocation, CLASS_TYPE_DRAGON_SHAMAN), oCreature)
        )
       // add new Invocation classes here
       )
        return TRUE;
    return FALSE;
}

string DebugListKnownInvocations(object oCreature)
{
    string sReturn = "Invocations known by " + DebugObject2Str(oCreature) + ":\n";
    int i, j, k, numPowerLists = 6;
    int nPowerList, nSize;
    string sTemp, sArray, sArrayBase, sPowerFile;
    // Loop over all power lists
    for(i = 1; i <= numPowerLists; i++)
    {
        // Some padding
        sReturn += "  ";
        // Get the power list for this loop
        switch(i)
        {
            case 1: nPowerList = INVOCATION_LIST_DRAGONFIRE_ADEPT;          sReturn += "Dragonfire Adept";  break;

            case 2: nPowerList = INVOCATION_LIST_WARLOCK;                   sReturn += "Warlock";  break;
            case 3: nPowerList = INVOCATION_LIST_DRAGON_SHAMAN;             sReturn += "Dragon Shaman";  break;

            // This should always be last
            case 5: nPowerList = INVOCATION_LIST_EXTRA;                     sReturn += "Extra";   break;
            case 6: nPowerList = INVOCATION_LIST_EXTRA_EPIC;                sReturn += "Epic Extra";   break;
        }
        sReturn += " Invocations known:\n";

        // Determine if the character has any Invocations from this list
        sPowerFile = GetAMSDefinitionFileName(nPowerList);
        sArrayBase = _INVOCATION_LIST_NAME_BASE + IntToString(nPowerList);

        // Loop over levels
        for(j = 1; j <= GetHitDice(oCreature); j++)
        {
            sArray = sArrayBase + _INVOCATION_LIST_LEVEL_ARRAY + IntToString(j);
            if(persistant_array_exists(oCreature, sArray))
            {
                sReturn += "   Gained on level " + IntToString(j) + ":\n";
                nSize = persistant_array_get_size(oCreature, sArray);
                for(k = 0; k < nSize; k++)
                    sReturn += "    " + GetStringByStrRef(StringToInt(Get2DACache(sPowerFile, "Name",
                                                                                  GetPowerfileIndexFromSpellID(persistant_array_get_int(oCreature, sArray, k))
                                                                                  )
                                                                      )
                                                          )
                            + "\n";
            }
        }

        // Non-leveldependent Invocations
        sArray = sArrayBase + _INVOCATION_LIST_GENERAL_ARRAY;
        if(persistant_array_exists(oCreature, sArray))
        {
            sReturn += "   Non-leveldependent:\n";
            nSize = persistant_array_get_size(oCreature, sArray);
            for(k = 0; k < nSize; k++)
                sReturn += "    " + GetStringByStrRef(StringToInt(Get2DACache(sPowerFile, "Name",
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
