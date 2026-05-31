//::///////////////////////////////////////////////
//:: Shadowcasting include: Mysteries Known
//:: shd_inc_mystknwn
//::///////////////////////////////////////////////
/** @file
    Defines functions for adding & removing
    Mysteries known.

    Data stored:

    - For each Path list
    -- Total number of Mysteries known
    -- A modifier value to maximum Mysteries known on this list to account for feats and classes that add Mysteries
    -- An array related to Mysteries the knowledge of which is not dependent on character level
    --- Each array entry specifies the spells.2da row of the known Mysteries's class-specific entry
    -- For each character level on which Mysteries have been gained from this list
    --- An array of Mysteries gained on this level
    ---- Each array entry specifies the spells.2da row of the known Mysteries's class-specific entry

    @author Stratovarius
    @date   Created - 2019.02.06
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int MYSTERY_LIST_SHADOWCASTER      = 136;
const int MYSTERY_LIST_SHADOWSMITH       = 98;

/// Special Mystery list. Mysteries gained via other sources.
const int MYSTERY_LIST_MISC              = CLASS_TYPE_INVALID;//-1;

const string _MYSTERY_LIST_NAME_BASE     = "PRC_MysteryList_";
const string _MYSTERY_LIST_PATH          = "PRC_PathTotal_";
const string _MYSTERY_LIST_TOTAL_KNOWN   = "_TotalKnown";
const string _MYSTERY_LIST_MODIFIER      = "_KnownModifier";
const string _MYSTERY_LIST_MISC_ARRAY    = "_MysteriesKnownMiscArray";
const string _MYSTERY_LIST_LEVEL_ARRAY   = "_MysteriesKnownLevelArray_";
const string _MYSTERY_LIST_GENERAL_ARRAY = "_MysteriesKnownGeneralArray";

#include "shd_inc_shdfunc"

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Gives the creature the control feats for the given Mystery and marks the Mystery
 * in a Mysteries known array.
 * If the Mystery's data is already stored in one of the Mysteries known arrays for
 * the list or adding the Mystery's data to the array fails, the function aborts.
 *
 * @param oShadow       The creature to gain the Mystery
 * @param nList           The list the Mystery comes from. One of MYSTERY_LIST_*
 * @param n2daRow         The 2da row in the lists's 2da file that specifies the Mystery.
 * @param bLevelDependent If this is TRUE, the Mystery is tied to a certain level and can
 *                        be lost via level loss. If FALSE, the Mystery is not dependent
 *                        of a level and cannot be lost via level loss.
 * @param nLevelToTieTo   If bLevelDependent is TRUE, this specifies the level the Mystery
 *                        is gained on. Otherwise, it's ignored.
 *                        The default value (-1) means that the current level of oShadow
 *                        will be used.
 *
 * @return                TRUE if the Mystery was successfully stored and control feats added.
 *                        FALSE otherwise.
 */
int AddMysteryKnown(object oShadow, int nList, int n2daRow, int bLevelDependent = FALSE, int nLevelToTieTo = -1);

/**
 * Removes all Mysteries gained from each list on the given level.
 *
 * @param oShadow The creature whose Mysteries to remove
 * @param nLevel    The level to clear
 */
void RemoveMysteriesKnownOnLevel(object oShadow, int nLevel);

/**
 * Gets the value of the Mysteries known modifier, which is a value that is added
 * to the 2da-specified maximum Mysteries known to determine the actual maximum.
 *
 * @param oShadow The creature whose modifier to get
 * @param nList     The list the maximum Mysteries known from which the modifier
 *                  modifies. One of MYSTERY_LIST_*
 */
int GetKnownMysteriesModifier(object oShadow, int nList);

/**
 * Sets the value of the Mysteries known modifier, which is a value that is added
 * to the 2da-specified maximum Mysteries known to determine the actual maximum.
 *
 * @param oShadow The creature whose modifier to set
 * @param nList     The list the maximum Mysteries known from which the modifier
 *                  modifies. One of MYSTERY_LIST_*
 */
void SetKnownMysteriesModifier(object oShadow, int nList, int nNewValue);

/**
 * Gets the number of Mysteries a character possesses
 *
 * @param oShadow The creature whose Mysteries to check
 * @param nList     The list to check. One of MYSTERY_LIST_*
 *
 * @return          The number of Mysteries known oShadow has from nList
 */
int GetMysteryCount(object oShadow, int nList);

/**
 * Gets the number of Mysteries a character character possesses from a
 * specific path
 *
 * @param oShadow   The creature whose Mysteries to check
 * @param nPath       The path to check. One of PATH_*
 * 
 * @return            The number of Mysteries known oShadow has from nPath
 */
int GetMysteryCountByPath(object oShadow, int nPath);

/**
 * Gets the maximum number of Mysteries a character may possess from a given list
 * at this time. Calculated based on class levels, feats and a misceallenous
 * modifier. 
 *
 * @param oShadow Character to determine maximum Mysteries for
 * @param nList     MYSTERY_LIST_* of the list to determine maximum Mysteries for
 * 
 * @return          Maximum number of Mysteries that oShadow may know from the given list.
 */
int GetMaxMysteryCount(object oShadow, int nList);

/**
 * Determines whether a character has a given Mystery, gained via some Mystery list.
 *
 * @param nMystery    Mystery_* of the Mystery to test
 * @param oShadow Character to test for the possession of the Mystery
 * @return          TRUE if the character has the Mystery, FALSE otherwise
 */
int GetHasMystery(int nMystery, object oShadow = OBJECT_SELF);

/**
 * Gets the highest Mystery level a character may learn at this time.  
 *
 * @param oShadow   Character to determine maximum Mystery level for
 * @param nClass    Class to check against
 * @param nType     1 = apprentice, 2 = initiate, 3 = master
 * 
 * @return          Maxmimum mystery level
 */
int GetMaxMysteryLevelLearnable(object oShadow, int nClass, int nType);

/**
 * Gets the total number of completed paths for the character
 *
 * @param oShadow   Character to check
 */
int GetCompletedPaths(object oShadow);

/**
 * Adds the feat as a bonus feat gained from having completed a path. Aborts if the feat
 * was one the character already had
 *
 * @param oShadow   Character to check
 * @param nFeat     Feat to add
 */
void AddPathBonusFeat(object oShadow, int nFeat);

/**
 * Returns how many Path Bonus feats the character has
 *
 * @param oShadow   Character to check
 */
int GetPathBonusFeats(object oShadow);

/**
 * Reapplies any missing Path Bonus feats the character has chosen and doesn't have
 *
 * @param oShadow   Character to check
 */
void ReapplyPathBonusFeat(object oShadow);

/**
 * Returns the IP_CONST version of the feat. 
 * Only works on Bonus Path feats
 *
 * @param nFeat   Feat to itemproperty
 */
int PathFeatToIPFeat(int nFeat);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_lookups"
#include "inc_pers_array"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _MysteryRecurseRemoveArray(object oShadow, string sArrayName, string sMystFile, int nArraySize, int nCurIndex)
{
    if(DEBUG) DoDebug("_MysteryRecurseRemoveArray():\n"
                    + "oShadow = " + DebugObject2Str(oShadow) + "\n"
                    + "sArrayName = '" + sArrayName + "'\n"
                    + "sMystFile = '" + sMystFile + "'\n"
                    + "nArraySize = " + IntToString(nArraySize) + "\n"
                    + "nCurIndex = " + IntToString(nCurIndex) + "\n"
                      );

    // Determine whether we've already parsed the whole array or not
    if(nCurIndex >= nArraySize)
    {
        if(DEBUG) DoDebug("_MysteryRecurseRemoveArray(): Running itemproperty removal loop.");
        // Loop over itemproperties on the skin and remove each match
        object oSkin = GetPCSkin(oShadow);
        itemproperty ipTest = GetFirstItemProperty(oSkin);
        while(GetIsItemPropertyValid(ipTest))
        {
            // Check if the itemproperty is a bonus feat that has been marked for removal
            if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_FEAT                                            &&
               GetLocalInt(oShadow, "PRC_MystFeatRemovalMarker_" + IntToString(GetItemPropertySubType(ipTest)))
               )
            {
                if(DEBUG) DoDebug("_MysteryRecurseRemoveArray(): Removing bonus feat itemproperty:\n" + DebugIProp2Str(ipTest));
                // If so, remove it
                RemoveItemProperty(oSkin, ipTest);
                DeleteLocalInt(oShadow, "PRC_MystFeatRemovalMarker_" + IntToString(GetItemPropertySubType(ipTest)));
            }

            ipTest = GetNextItemProperty(oSkin);
        }
    }
    // Still parsing the array
    else
    {
        int nMystID = GetPowerfileIndexFromSpellID(persistant_array_get_int(oShadow, sArrayName, nCurIndex));
        // Set the marker
        string sName = "PRC_MystFeatRemovalMarker_" + Get2DACache(sMystFile, "IPFeatID", nMystID);
        if(DEBUG) DoDebug("_MysteryRecurseRemoveArray(): Recursing through array, marker set:\n" + sName);
        SetLocalInt(oShadow, sName, TRUE);

        string sPathArray = _MYSTERY_LIST_PATH + "_" + Get2DACache(sMystFile, "Path", nMystID);
        SetPersistantLocalInt(oShadow, sPathArray,
                              GetPersistantLocalInt(oShadow, sPathArray) - 1);

        // Recurse to next array index
        _MysteryRecurseRemoveArray(oShadow, sArrayName, sMystFile, nArraySize, nCurIndex + 1);
    }
}

void _RemoveMysteryArray(object oShadow, int nList, int nLevel)
{
    if(DEBUG) DoDebug("_RemoveMysteryArray():\n"
                    + "oShadow = " + DebugObject2Str(oShadow) + "\n"
                    + "nList = " + IntToString(nList) + "\n"
                      );

    string sBase  = _MYSTERY_LIST_NAME_BASE + IntToString(nList);
    string sArray = sBase + _MYSTERY_LIST_LEVEL_ARRAY + IntToString(nLevel);
    int nSize = persistant_array_get_size(oShadow, sArray);

    // Reduce the total by the array size
    SetPersistantLocalInt(oShadow, sBase + _MYSTERY_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oShadow, sBase + _MYSTERY_LIST_TOTAL_KNOWN) - nSize
                          );

    // Remove each Mystery in the array
    _MysteryRecurseRemoveArray(oShadow, sArray, GetAMSDefinitionFileName(nList), nSize, 0);

    // Remove the array itself
    persistant_array_delete(oShadow, sArray);
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int AddMysteryKnown(object oShadow, int nList, int n2daRow, int bLevelDependent = FALSE, int nLevelToTieTo = -1)
{
    string sBase      = _MYSTERY_LIST_NAME_BASE + IntToString(nList);
    string sArray     = sBase;
    string sPowerFile = GetAMSDefinitionFileName(/*PowerListToClassType(*/nList/*)*/);
    string sTestArray;
    int i, j, nSize, bReturn;

    // Get the spells.2da row corresponding to the cls_psipw_*.2da row
    int nSpells2daRow = StringToInt(Get2DACache(sPowerFile, "SpellID", n2daRow));

    // Determine the array name.
    if(bLevelDependent)
    {
        // If no level is specified, default to the creature's current level
        if(nLevelToTieTo == -1)
            nLevelToTieTo = GetHitDice(oShadow);

        sArray += _MYSTERY_LIST_LEVEL_ARRAY + IntToString(nLevelToTieTo);
    }
    else
    {
        sArray += _MYSTERY_LIST_GENERAL_ARRAY;
    }

    // Make sure the power isn't already in an array. If it is, abort and return FALSE
    // Loop over each level array and check that it isn't there.
    for(i = 1; i <= GetHitDice(oShadow); i++)
    {
        sTestArray = sBase + _MYSTERY_LIST_LEVEL_ARRAY + IntToString(i);
        if(persistant_array_exists(oShadow, sTestArray))
        {
            nSize = persistant_array_get_size(oShadow, sTestArray);
            for(j = 0; j < nSize; j++)
                if(persistant_array_get_int(oShadow, sArray, j) == nSpells2daRow)
                    return FALSE;
        }
    }
    // Check the non-level-dependent array
    sTestArray = sBase + _MYSTERY_LIST_GENERAL_ARRAY;
    if(persistant_array_exists(oShadow, sTestArray))
    {
        nSize = persistant_array_get_size(oShadow, sTestArray);
        for(j = 0; j < nSize; j++)
            if(persistant_array_get_int(oShadow, sArray, j) == nSpells2daRow)
                return FALSE;
    }

    // All checks are made, now start adding the new power
    // Create the array if it doesn't exist yet
    if(!persistant_array_exists(oShadow, sArray))
        persistant_array_create(oShadow, sArray);

    // Store the power in the array
    if(persistant_array_set_int(oShadow, sArray, persistant_array_get_size(oShadow, sArray), nSpells2daRow) != SDL_SUCCESS)
    {
        if(DEBUG) DoDebug("shd_inc_mystknwn: AddPowerKnown(): ERROR: Unable to add power to known array\n"
                        + "oShadow = " + DebugObject2Str(oShadow) + "\n"
                        + "nList = " + IntToString(nList) + "\n"
                        + "n2daRow = " + IntToString(n2daRow) + "\n"
                        + "bLevelDependent = " + DebugBool2String(bLevelDependent) + "\n"
                        + "nLevelToTieTo = " + IntToString(nLevelToTieTo) + "\n"
                        + "nSpells2daRow = " + IntToString(nSpells2daRow) + "\n"
                          );
        return FALSE;
    }

    // Increment Mysteries known total
    SetPersistantLocalInt(oShadow, sBase + _MYSTERY_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oShadow, sBase + _MYSTERY_LIST_TOTAL_KNOWN) + 1
                          );

    // Increment Mysteries known by path
    string sPathArray = _MYSTERY_LIST_PATH + "_" + Get2DACache(sPowerFile, "Path", n2daRow);
    SetPersistantLocalInt(oShadow, sPathArray,
                          GetPersistantLocalInt(oShadow, sPathArray) + 1);

    // Give the power's control feats
    object oSkin        = GetPCSkin(oShadow);
    string sPowerFeatIP = Get2DACache(sPowerFile, "IPFeatID", n2daRow);
    itemproperty ipFeat = PRCItemPropertyBonusFeat(StringToInt(sPowerFeatIP));
    IPSafeAddItemProperty(oSkin, ipFeat, 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    // Second power feat, if any
    /*sPowerFeatIP = Get2DACache(sPowerFile, "IPFeatID2", n2daRow);
    if(sPowerFeatIP != "")
    {
        ipFeat = PRCItemPropertyBonusFeat(StringToInt(sPowerFeatIP));
        IPSafeAddItemProperty(oSkin, ipFeat, 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    }*/

    return TRUE;
}

void RemoveMysteriesKnownOnLevel(object oShadow, int nLevel)
{
    if(DEBUG) DoDebug("shd_inc_mystknwn: RemoveMysteryKnownOnLevel():\n"
                    + "oShadow = " + DebugObject2Str(oShadow) + "\n"
                    + "nLevel = " + IntToString(nLevel) + "\n"
                      );

    string sPostFix = _MYSTERY_LIST_LEVEL_ARRAY + IntToString(nLevel);
    // For each Mystery list, determine if an array exists for this level.
    if(persistant_array_exists(oShadow, _MYSTERY_LIST_NAME_BASE + IntToString(MYSTERY_LIST_SHADOWCASTER) + sPostFix))
        // If one does exist, clear it
        _RemoveMysteryArray(oShadow, MYSTERY_LIST_SHADOWCASTER, nLevel);

    if(persistant_array_exists(oShadow, _MYSTERY_LIST_NAME_BASE + IntToString(MYSTERY_LIST_SHADOWSMITH) + sPostFix))
        _RemoveMysteryArray(oShadow, MYSTERY_LIST_SHADOWSMITH, nLevel);

    if(persistant_array_exists(oShadow, _MYSTERY_LIST_NAME_BASE + IntToString(MYSTERY_LIST_MISC) + sPostFix))
        _RemoveMysteryArray(oShadow, MYSTERY_LIST_MISC, nLevel);
    
}

int GetKnownMysteriesModifier(object oShadow, int nList)
{
    return GetPersistantLocalInt(oShadow, _MYSTERY_LIST_NAME_BASE + IntToString(nList) + _MYSTERY_LIST_MODIFIER);
}

void SetKnownMysteriesModifier(object oShadow, int nList, int nNewValue)
{
    SetPersistantLocalInt(oShadow, _MYSTERY_LIST_NAME_BASE + IntToString(nList) + _MYSTERY_LIST_MODIFIER, nNewValue);
}

int GetMysteryCount(object oShadow, int nList)
{
    return GetPersistantLocalInt(oShadow, _MYSTERY_LIST_NAME_BASE + IntToString(nList) + _MYSTERY_LIST_TOTAL_KNOWN);
}

int GetMysteryCountByPath(object oShadow, int nPath)
{
    return GetPersistantLocalInt(oShadow, _MYSTERY_LIST_PATH + "_" + IntToString(nPath));
}

int GetMaxMysteryCount(object oShadow, int nList)
{
    int nMaxMysteries = 0;

    if(nList == MYSTERY_LIST_MISC)
    {
        if(DEBUG) DoDebug("GetMaxMysteryCount(): ERROR: Using unfinished power list!");
    }
    else
    {
        int nLevel = GetLevelByClass(nList, oShadow);
        if (nList == GetPrimaryShadowMagicClass(oShadow))
            nLevel += GetShadowMagicPRCLevels(oShadow);
        string sFile = GetAMSKnownFileName(nList);
        nMaxMysteries = StringToInt(Get2DACache(sFile, "Mysteries", nLevel - 1));

        // Calculate feats

        // Add in the custom modifier
        nMaxMysteries += GetKnownMysteriesModifier(oShadow, nList);
        if(DEBUG) DoDebug("GetMaxMysteryCount(): " + IntToString(nList) + " Mysteries: " + IntToString(nMaxMysteries));
    }

    return nMaxMysteries;
}

int GetHasMystery(int nMystery, object oShadow = OBJECT_SELF)
{
    if((GetLevelByClass(CLASS_TYPE_SHADOWCASTER, oShadow)
        && GetHasFeat(GetClassFeatFromPower(nMystery, CLASS_TYPE_SHADOWCASTER), oShadow)
        ) ||
       (GetLevelByClass(CLASS_TYPE_SHADOWSMITH, oShadow)
        && GetHasFeat(GetClassFeatFromPower(nMystery, CLASS_TYPE_SHADOWSMITH), oShadow)
        )
        // add new classes here
       )
        return TRUE;
    return FALSE;
}

string DebugListKnownMysteries(object oShadow)
{
    string sReturn = "Mysteries known by " + DebugObject2Str(oShadow) + ":\n";
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
            case 1: nPowerList = MYSTERY_LIST_SHADOWCASTER;        sReturn += "SHADOWCASTER";  break;
            case 2: nPowerList = MYSTERY_LIST_SHADOWSMITH;         sReturn += "SHADOWSMITH"; break;

            // This should always be last
            case 6: nPowerList = MYSTERY_LIST_MISC;           sReturn += "Misceallenous";   break;
        }
        sReturn += " Mysteries known:\n";

        // Determine if the character has any Mysteries from this list
        sPowerFile = GetAMSDefinitionFileName(nPowerList);
        sArrayBase = _MYSTERY_LIST_NAME_BASE + IntToString(nPowerList);

        // Loop over levels
        for(j = 1; j <= GetHitDice(oShadow); j++)
        {
            sArray = sArrayBase + _MYSTERY_LIST_LEVEL_ARRAY + IntToString(j);
            if(persistant_array_exists(oShadow, sArray))
            {
                sReturn += "   Gained on level " + IntToString(j) + ":\n";
                nSize = persistant_array_get_size(oShadow, sArray);
                for(k = 0; k < nSize; k++)
                    sReturn += "    " + GetStringByStrRef(StringToInt(Get2DACache(sPowerFile, "Name",
                                                                                  GetPowerfileIndexFromSpellID(persistant_array_get_int(oShadow, sArray, k))
                                                                                  )
                                                                      )
                                                          )
                            + "\n";
            }
        }

        // Non-leveldependent Mysteries
        sArray = sArrayBase + _MYSTERY_LIST_GENERAL_ARRAY;
        if(persistant_array_exists(oShadow, sArray))
        {
            sReturn += "   Non-leveldependent:\n";
            nSize = persistant_array_get_size(oShadow, sArray);
            for(k = 0; k < nSize; k++)
                sReturn += "    " + GetStringByStrRef(StringToInt(Get2DACache(sPowerFile, "Name",
                                                                                  GetPowerfileIndexFromSpellID(persistant_array_get_int(oShadow, sArray, k))
                                                                                  )
                                                                      )
                                                          )
                        + "\n";
        }
    }

    return sReturn;
}

int GetMaxMysteryLevelLearnable(object oShadow, int nClass, int nType)
{
    if(DEBUG) DoDebug("GetMaxMysteryLevelLearnable nType: " + IntToString(nType));

    // Rules Quote:
    // Within a category -Apprentice, Initiate, Master- you must have at least two mysteries of any given level 
    // before you can take any mysteries of the next higher level. For instance, you must have two 1st-level 
    // mysteries before you can take any 2nds, and at least two 2nds before you can take any 3rds.
    int nMaxLrn, i, nMystLevel, nCount1, nCount2;
    string sFeatID;  
    int nLevel = GetLevelByClass(nClass, oShadow);
    if (nClass == GetPrimaryShadowMagicClass(oShadow))
        nLevel += GetShadowMagicPRCLevels(oShadow);    
    if(DEBUG) DoDebug("GetMaxMysteryLevelLearnable nClass: " + IntToString(nClass));
    string sPowerFile = GetAMSDefinitionFileName(nClass);
    if(DEBUG) DoDebug("GetMaxMysteryLevelLearnable sPowerFile: " + sPowerFile);
    
    if (nType == 3 && nLevel >= 13 && nClass == CLASS_TYPE_SHADOWCASTER) // Master mysteries, must be minimum 13th level
    {
        for(i = 0; i < GetPRCSwitch(FILE_END_CLASS_POWER) ; i++)
        {
            sFeatID = Get2DACache(sPowerFile, "FeatID", i);
            if(sFeatID != "" && GetHasFeat(StringToInt(sFeatID), oShadow)) // Make sure it's not a blank mystery and that the PC has it
            {
                nMystLevel = StringToInt(Get2DACache(sPowerFile, "Level", i));
                if (nMystLevel == 7) nCount1++;
                else if (nMystLevel == 8) nCount2++; // Don't need to check for 9th because 10th don't exist
            }
        }
        //DoDebug("GetMaxMysteryLevelLearnable nCount1: " + IntToString(nCount1));
        //DoDebug("GetMaxMysteryLevelLearnable nCount2: " + IntToString(nCount2));
        if (nCount2 > 1) // Need to know at least two
            nMaxLrn = 9;
        else if (nCount1 > 1) // Need to know at least two
            nMaxLrn = 8; 
        else  // At 13th level you get access to 7ths regardless
            nMaxLrn = 7;             
    }
    else if (nType == 2 && nLevel >= 7 && nClass == CLASS_TYPE_SHADOWCASTER) // Initiate mysteries
    {
        for(i = 0; i < GetPRCSwitch(FILE_END_CLASS_POWER) ; i++)
        {
            sFeatID = Get2DACache(sPowerFile, "FeatID", i);
            if(sFeatID != "" && GetHasFeat(StringToInt(sFeatID), oShadow)) // Make sure it's not a blank mystery and that the PC has it
            {
                nMystLevel = StringToInt(Get2DACache(sPowerFile, "Level", i));
                if (nMystLevel == 4) nCount1++;
                else if (nMystLevel == 5) nCount2++; // Don't need to check for 6th because 7th is triggered by level
            }
        }
        //DoDebug("GetMaxMysteryLevelLearnable nCount1: " + IntToString(nCount1));
        //DoDebug("GetMaxMysteryLevelLearnable nCount2: " + IntToString(nCount2));        
        if (nCount2 > 1) // Need to know at least two
            nMaxLrn = 6;
        else if (nCount1 > 1) // Need to know at least two
            nMaxLrn = 5; 
        else  // At 7th level you get access to 4ths regardless
            nMaxLrn = 4;     
    }
    else // Apprentice mysteries
    {
        for(i = 0; i < GetPRCSwitch(FILE_END_CLASS_POWER) ; i++)
        {
            sFeatID = Get2DACache(sPowerFile, "FeatID", i);
            if(sFeatID != "" && GetHasFeat(StringToInt(sFeatID), oShadow)) // Make sure it's not a blank mystery and that the PC has it
            {
                nMystLevel = StringToInt(Get2DACache(sPowerFile, "Level", i));
                if (nMystLevel == 1) nCount1++;
                else if (nMystLevel == 2) nCount2++; // Don't need to check for 3rd because 4th is triggered by level
            }
        }
        //DoDebug("GetMaxMysteryLevelLearnable nCount1: " + IntToString(nCount1));
        //DoDebug("GetMaxMysteryLevelLearnable nCount2: " + IntToString(nCount2));        
        if (nCount2 > 1) // Need to know at least two
            nMaxLrn = 3;
        else if (nCount1 > 1) // Need to know at least two
            nMaxLrn = 2; 
        else  // At 1st level you get access to 1st regardless
            nMaxLrn = 1;     
    }
    
    //DoDebug("GetMaxMysteryLevelLearnable nMaxLrn: " + IntToString(nMaxLrn));
    
    return nMaxLrn;
}

int GetCompletedPaths(object oShadow)
{
    int i, nReturn, nPath;
    for(i = 0; i < 24; i++)
    {
        //if(DEBUG) DoDebug("GetCompletedPaths(): i " + IntToString(i));
        nPath = GetMysteryCountByPath(oShadow, i);
        //if(DEBUG) DoDebug("GetCompletedPaths(): nPath " + IntToString(nPath));
        if(nPath == 3) // Completed Path
            nReturn++; //Number of completed paths
    }

    //if(DEBUG) DoDebug("GetCompletedPaths(): nReturn " + IntToString(nReturn));
    // Return the total
    return nReturn;
}

void AddPathBonusFeat(object oShadow, int nFeat)
{
    if (GetHasFeat(nFeat, oShadow)) return; // No point adding something they've got
    
    int nCount, i;    
    for(i = 1; i < 7 ; i++)
    {
        if (GetPersistantLocalInt(oShadow, "PathBonus"+IntToString(i)) > 0) // Make sure to only fill empty ones
            nCount++;
    }    

    SetPersistantLocalInt(oShadow, "PathBonus"+IntToString(nCount + 1), nFeat);

    // Give the power's control feats
    object oSkin        = GetPCSkin(oShadow);
    int nIPFeat         = PathFeatToIPFeat(nFeat);
    itemproperty ipFeat = PRCItemPropertyBonusFeat(nIPFeat);
    IPSafeAddItemProperty(oSkin, ipFeat, 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
}

int GetPathBonusFeats(object oShadow)
{
    int nCount, i;    
    for(i = 1; i < 7 ; i++)
    {
        if (GetPersistantLocalInt(oShadow, "PathBonus"+IntToString(i)) > 0) // Count filled ones
            nCount++;
    }    

    return nCount;
}

void ReapplyPathBonusFeat(object oShadow)
{
    int nFeat, i;
    object oSkin = GetPCSkin(oShadow);
    for(i = 1; i < 7 ; i++)
    {
        nFeat = GetPersistantLocalInt(oShadow, "PathBonus"+IntToString(i));
        if (nFeat > 0 && !GetHasFeat(nFeat, oShadow))// Only apply if it's a valid feat they don't have
        {
            int nIPFeat         = PathFeatToIPFeat(nFeat);
            itemproperty ipFeat = PRCItemPropertyBonusFeat(nIPFeat);
            IPSafeAddItemProperty(oSkin, ipFeat, 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
        }    
    }    
}

int PathFeatToIPFeat(int nFeat)
{
    int nIPFeat = -1;
    switch(nFeat)
    {
        case FEAT_PATH_FOCUS_CLOAK_SHADOWS             : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_CLOAK_SHADOWS             ; break;
        case FEAT_PATH_FOCUS_DARK_TERRAIN              : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_DARK_TERRAIN              ; break;
        case FEAT_PATH_FOCUS_EBON_WHISPERS             : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_EBON_WHISPERS             ; break;
        case FEAT_PATH_FOCUS_EYES_DARKNESS             : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_EYES_DARKNESS             ; break;
        case FEAT_PATH_FOCUS_SHUTTERS_CLOUDS           : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_SHUTTERS_CLOUDS           ; break;
        case FEAT_PATH_FOCUS_TOUCH_TWILIGHT            : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_TOUCH_TWILIGHT            ; break;
        case FEAT_PATH_FOCUS_UMBRAL_MIND               : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_UMBRAL_MIND               ; break;
        case FEAT_PATH_FOCUS_BLACK_MAGIC               : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_BLACK_MAGIC               ; break;
        case FEAT_PATH_FOCUS_BODY_SOUL                 : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_BODY_SOUL                 ; break;
        case FEAT_PATH_FOCUS_DARK_REFLECTIONS          : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_DARK_REFLECTIONS          ; break;
        case FEAT_PATH_FOCUS_EBON_ROADS                : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_EBON_ROADS                ; break;
        case FEAT_PATH_FOCUS_ELEMENTAL_SHADOWS         : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_ELEMENTAL_SHADOWS         ; break;
        case FEAT_PATH_FOCUS_UNBINDING_SHADE           : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_UNBINDING_SHADE           ; break;
        case FEAT_PATH_FOCUS_VEIL_SHADOWS              : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_VEIL_SHADOWS              ; break;
        case FEAT_PATH_FOCUS_BREATH_TWILIGHT           : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_BREATH_TWILIGHT           ; break;
        case FEAT_PATH_FOCUS_DARK_METAMORPHOSIS        : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_DARK_METAMORPHOSIS        ; break;
        case FEAT_PATH_FOCUS_EBON_WALLS                : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_EBON_WALLS                ; break;
        case FEAT_PATH_FOCUS_EYES_NIGHT_SKY            : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_EYES_NIGHT_SKY            ; break;
        case FEAT_PATH_FOCUS_HEART_SOUL                : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_HEART_SOUL                ; break;
        case FEAT_PATH_FOCUS_SHADOW_CALLING            : nIPFeat = IP_CONST_FEAT_PATH_FOCUS_SHADOW_CALLING            ; break;   
        case FEAT_GREATER_PATH_FOCUS_CLOAK_SHADOWS     : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_CLOAK_SHADOWS     ; break;
        case FEAT_GREATER_PATH_FOCUS_DARK_TERRAIN      : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_DARK_TERRAIN      ; break;
        case FEAT_GREATER_PATH_FOCUS_EBON_WHISPERS     : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_EBON_WHISPERS     ; break;
        case FEAT_GREATER_PATH_FOCUS_EYES_DARKNESS     : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_EYES_DARKNESS     ; break;
        case FEAT_GREATER_PATH_FOCUS_SHUTTERS_CLOUDS   : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_SHUTTERS_CLOUDS   ; break;
        case FEAT_GREATER_PATH_FOCUS_TOUCH_TWILIGHT    : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_TOUCH_TWILIGHT    ; break;
        case FEAT_GREATER_PATH_FOCUS_UMBRAL_MIND       : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_UMBRAL_MIND       ; break;
        case FEAT_GREATER_PATH_FOCUS_BLACK_MAGIC       : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_BLACK_MAGIC       ; break;
        case FEAT_GREATER_PATH_FOCUS_BODY_SOUL         : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_BODY_SOUL         ; break;
        case FEAT_GREATER_PATH_FOCUS_DARK_REFLECTIONS  : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_DARK_REFLECTIONS  ; break;
        case FEAT_GREATER_PATH_FOCUS_EBON_ROADS        : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_EBON_ROADS        ; break;
        case FEAT_GREATER_PATH_FOCUS_ELEMENTAL_SHADOWS : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_ELEMENTAL_SHADOWS ; break;
        case FEAT_GREATER_PATH_FOCUS_UNBINDING_SHADE   : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_UNBINDING_SHADE   ; break;
        case FEAT_GREATER_PATH_FOCUS_VEIL_SHADOWS      : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_VEIL_SHADOWS      ; break;
        case FEAT_GREATER_PATH_FOCUS_BREATH_TWILIGHT   : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_BREATH_TWILIGHT   ; break;
        case FEAT_GREATER_PATH_FOCUS_DARK_METAMORPHOSIS: nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_DARK_METAMORPHOSIS; break;
        case FEAT_GREATER_PATH_FOCUS_EBON_WALLS        : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_EBON_WALLS        ; break;
        case FEAT_GREATER_PATH_FOCUS_EYES_NIGHT_SKY    : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_EYES_NIGHT_SKY    ; break;
        case FEAT_GREATER_PATH_FOCUS_HEART_SOUL        : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_HEART_SOUL        ; break;
        case FEAT_GREATER_PATH_FOCUS_SHADOW_CALLING    : nIPFeat = IP_CONST_FEAT_GREATER_PATH_FOCUS_SHADOW_CALLING    ; break; 
        case FEAT_NOCTURNAL_CASTER_CLOAK_SHADOWS       : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_CLOAK_SHADOWS       ; break;
        case FEAT_NOCTURNAL_CASTER_DARK_TERRAIN        : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_DARK_TERRAIN        ; break;
        case FEAT_NOCTURNAL_CASTER_EBON_WHISPERS       : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_EBON_WHISPERS       ; break;
        case FEAT_NOCTURNAL_CASTER_EYES_DARKNESS       : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_EYES_DARKNESS       ; break;
        case FEAT_NOCTURNAL_CASTER_SHUTTERS_CLOUDS     : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_SHUTTERS_CLOUDS     ; break;
        case FEAT_NOCTURNAL_CASTER_TOUCH_TWILIGHT      : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_TOUCH_TWILIGHT      ; break;
        case FEAT_NOCTURNAL_CASTER_UMBRAL_MIND         : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_UMBRAL_MIND         ; break;
        case FEAT_NOCTURNAL_CASTER_BLACK_MAGIC         : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_BLACK_MAGIC         ; break;
        case FEAT_NOCTURNAL_CASTER_BODY_SOUL           : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_BODY_SOUL           ; break;
        case FEAT_NOCTURNAL_CASTER_DARK_REFLECTIONS    : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_DARK_REFLECTIONS    ; break;
        case FEAT_NOCTURNAL_CASTER_EBON_ROADS          : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_EBON_ROADS          ; break;
        case FEAT_NOCTURNAL_CASTER_ELEMENTAL_SHADOWS   : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_ELEMENTAL_SHADOWS   ; break;
        case FEAT_NOCTURNAL_CASTER_UNBINDING_SHADE     : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_UNBINDING_SHADE     ; break;
        case FEAT_NOCTURNAL_CASTER_VEIL_SHADOWS        : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_VEIL_SHADOWS        ; break;
        case FEAT_NOCTURNAL_CASTER_BREATH_TWILIGHT     : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_BREATH_TWILIGHT     ; break;
        case FEAT_NOCTURNAL_CASTER_DARK_METAMORPHOSIS  : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_DARK_METAMORPHOSIS  ; break;
        case FEAT_NOCTURNAL_CASTER_EBON_WALLS          : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_EBON_WALLS          ; break;
        case FEAT_NOCTURNAL_CASTER_EYES_NIGHT_SKY      : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_EYES_NIGHT_SKY      ; break;
        case FEAT_NOCTURNAL_CASTER_HEART_SOUL          : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_HEART_SOUL          ; break;
        case FEAT_NOCTURNAL_CASTER_SHADOW_CALLING      : nIPFeat = IP_CONST_FEAT_NOCTURNAL_CASTER_SHADOW_CALLING      ; break; 
        case FEAT_FAV_MYST_BENDPERSPECTIVE             : nIPFeat = IP_CONST_FEAT_FAV_MYST_BENDPERSPECTIVE             ; break;
        case FEAT_FAV_MYST_CARPETSHADOW                : nIPFeat = IP_CONST_FEAT_FAV_MYST_CARPETSHADOW                ; break;
        case FEAT_FAV_MYST_DUSKANDDAWN                 : nIPFeat = IP_CONST_FEAT_FAV_MYST_DUSKANDDAWN                 ; break;
        case FEAT_FAV_MYST_LIFEFADES                   : nIPFeat = IP_CONST_FEAT_FAV_MYST_LIFEFADES                   ; break;
        case FEAT_FAV_MYST_MESMERIZINGSHADE            : nIPFeat = IP_CONST_FEAT_FAV_MYST_MESMERIZINGSHADE            ; break;
        case FEAT_FAV_MYST_STEELSHADOWS                : nIPFeat = IP_CONST_FEAT_FAV_MYST_STEELSHADOWS                ; break;
        case FEAT_FAV_MYST_VOICEOFSHADOW               : nIPFeat = IP_CONST_FEAT_FAV_MYST_VOICEOFSHADOW               ; break;
        case FEAT_FAV_MYST_BLACKFIRE                   : nIPFeat = IP_CONST_FEAT_FAV_MYST_BLACKFIRE                   ; break;
        case FEAT_FAV_MYST_CONGRESSSHADOWS             : nIPFeat = IP_CONST_FEAT_FAV_MYST_CONGRESSSHADOWS             ; break;
        case FEAT_FAV_MYST_FLESHFAILS                  : nIPFeat = IP_CONST_FEAT_FAV_MYST_FLESHFAILS                  ; break;
        case FEAT_FAV_MYST_PIERCINGSIGHT               : nIPFeat = IP_CONST_FEAT_FAV_MYST_PIERCINGSIGHT               ; break;
        case FEAT_FAV_MYST_SHADOWSKIN                  : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWSKIN                  ; break;
        case FEAT_FAV_MYST_SIGHTECLIPSED               : nIPFeat = IP_CONST_FEAT_FAV_MYST_SIGHTECLIPSED               ; break;
        case FEAT_FAV_MYST_THOUGHTSSHADOW              : nIPFeat = IP_CONST_FEAT_FAV_MYST_THOUGHTSSHADOW              ; break;
        case FEAT_FAV_MYST_AFRAIDOFTHEDARK             : nIPFeat = IP_CONST_FEAT_FAV_MYST_AFRAIDOFTHEDARK             ; break;
        case FEAT_FAV_MYST_CLINGINGDARKNESS            : nIPFeat = IP_CONST_FEAT_FAV_MYST_CLINGINGDARKNESS            ; break;
        case FEAT_FAV_MYST_DANCINGSHADOWS              : nIPFeat = IP_CONST_FEAT_FAV_MYST_DANCINGSHADOWS              ; break;
        case FEAT_FAV_MYST_FLICKER                     : nIPFeat = IP_CONST_FEAT_FAV_MYST_FLICKER                     ; break;
        case FEAT_FAV_MYST_KILLINGSHADOWS              : nIPFeat = IP_CONST_FEAT_FAV_MYST_KILLINGSHADOWS              ; break;
        case FEAT_FAV_MYST_SHARPSHADOWS                : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHARPSHADOWS                ; break; 
        case FEAT_FAV_MYST_UMBRALTOUCH                 : nIPFeat = IP_CONST_FEAT_FAV_MYST_UMBRALTOUCH                 ; break;
        case FEAT_FAV_MYST_AURAOFSHADE                 : nIPFeat = IP_CONST_FEAT_FAV_MYST_AURAOFSHADE                 ; break;
        case FEAT_FAV_MYST_BOLSTER                     : nIPFeat = IP_CONST_FEAT_FAV_MYST_BOLSTER                     ; break;
        case FEAT_FAV_MYST_SHADOWEVOCATION             : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWEVOCATION             ; break;
        case FEAT_FAV_MYST_SHADOWVISION                : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWVISION                ; break;
        case FEAT_FAV_MYST_SHADOWSFADE                 : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWSFADE                 ; break;
        case FEAT_FAV_MYST_STEPINTOSHADOW              : nIPFeat = IP_CONST_FEAT_FAV_MYST_STEPINTOSHADOW              ; break;
        case FEAT_FAV_MYST_WARPSPELL                   : nIPFeat = IP_CONST_FEAT_FAV_MYST_WARPSPELL                   ; break;
        case FEAT_FAV_MYST_CURTAINSHADOWS              : nIPFeat = IP_CONST_FEAT_FAV_MYST_CURTAINSHADOWS              ; break;
        case FEAT_FAV_MYST_DARKAIR                     : nIPFeat = IP_CONST_FEAT_FAV_MYST_DARKAIR                     ; break;
        case FEAT_FAV_MYST_ECHOSPELL                   : nIPFeat = IP_CONST_FEAT_FAV_MYST_ECHOSPELL                   ; break;
        case FEAT_FAV_MYST_FEIGNLIFE                   : nIPFeat = IP_CONST_FEAT_FAV_MYST_FEIGNLIFE                   ; break;
        case FEAT_FAV_MYST_LANGUOR                     : nIPFeat = IP_CONST_FEAT_FAV_MYST_LANGUOR                     ; break;
        case FEAT_FAV_MYST_PASSINTOSHADOW              : nIPFeat = IP_CONST_FEAT_FAV_MYST_PASSINTOSHADOW              ; break;
        case FEAT_FAV_MYST_UNRAVELDWEOMER              : nIPFeat = IP_CONST_FEAT_FAV_MYST_UNRAVELDWEOMER              ; break;
        case FEAT_FAV_MYST_FLOODSHADOWS                : nIPFeat = IP_CONST_FEAT_FAV_MYST_FLOODSHADOWS                ; break;
        case FEAT_FAV_MYST_GREATERSHADOWEVOCATION      : nIPFeat = IP_CONST_FEAT_FAV_MYST_GREATERSHADOWEVOCATION      ; break;
        case FEAT_FAV_MYST_SHADOWINVESTITURE           : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWINVESTITURE           ; break;
        case FEAT_FAV_MYST_SHADOWSTORM                 : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWSTORM                 ; break;
        case FEAT_FAV_MYST_SHADOWSFADE_GREATER         : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWSFADE_GREATER         ; break; 
        case FEAT_FAV_MYST_UNVEIL                      : nIPFeat = IP_CONST_FEAT_FAV_MYST_UNVEIL                      ; break;
        case FEAT_FAV_MYST_VOYAGESHADOW                : nIPFeat = IP_CONST_FEAT_FAV_MYST_VOYAGESHADOW                ; break;
        case FEAT_FAV_MYST_DARKSOUL                    : nIPFeat = IP_CONST_FEAT_FAV_MYST_DARKSOUL                    ; break;
        case FEAT_FAV_MYST_EPHEMERALIMAGE              : nIPFeat = IP_CONST_FEAT_FAV_MYST_EPHEMERALIMAGE              ; break;
        case FEAT_FAV_MYST_LIFEFADESGREATER            : nIPFeat = IP_CONST_FEAT_FAV_MYST_LIFEFADESGREATER            ; break;
        case FEAT_FAV_MYST_PRISONNIGHT                 : nIPFeat = IP_CONST_FEAT_FAV_MYST_PRISONNIGHT                 ; break;
        case FEAT_FAV_MYST_UMBRALSERVANT               : nIPFeat = IP_CONST_FEAT_FAV_MYST_UMBRALSERVANT               ; break;
        case FEAT_FAV_MYST_TRUTHREVEALED               : nIPFeat = IP_CONST_FEAT_FAV_MYST_TRUTHREVEALED               ; break;
        case FEAT_FAV_MYST_FARSIGHT                    : nIPFeat = IP_CONST_FEAT_FAV_MYST_FARSIGHT                    ; break;
        case FEAT_FAV_MYST_GRFLESHFAILS                : nIPFeat = IP_CONST_FEAT_FAV_MYST_GRFLESHFAILS                ; break;
        case FEAT_FAV_MYST_SHADOWPLAGUE                : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWPLAGUE                ; break;
        case FEAT_FAV_MYST_SOULPUPPET                  : nIPFeat = IP_CONST_FEAT_FAV_MYST_SOULPUPPET                  ; break;
        case FEAT_FAV_MYST_TOMBNIGHT                   : nIPFeat = IP_CONST_FEAT_FAV_MYST_TOMBNIGHT                   ; break;
        case FEAT_FAV_MYST_UMBRALBODY                  : nIPFeat = IP_CONST_FEAT_FAV_MYST_UMBRALBODY                  ; break;
        case FEAT_FAV_MYST_ARMYSHADOW                  : nIPFeat = IP_CONST_FEAT_FAV_MYST_ARMYSHADOW                  ; break;
        case FEAT_FAV_MYST_CONSUMEESSENCE              : nIPFeat = IP_CONST_FEAT_FAV_MYST_CONSUMEESSENCE              ; break;
        case FEAT_FAV_MYST_EPHEMERALSTORM              : nIPFeat = IP_CONST_FEAT_FAV_MYST_EPHEMERALSTORM              ; break;
        case FEAT_FAV_MYST_REFLECTIONS                 : nIPFeat = IP_CONST_FEAT_FAV_MYST_REFLECTIONS                 ; break;
        case FEAT_FAV_MYST_SHADOWSURGE                 : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWSURGE                 ; break;
        case FEAT_FAV_MYST_SHADOWTIME                  : nIPFeat = IP_CONST_FEAT_FAV_MYST_SHADOWTIME                  ; break; 
        case FEAT_SHADOW_CAST                          : nIPFeat = IP_CONST_FEAT_SHADOW_CAST                          ; break;
        case FEAT_EMPOWER_MYSTERY                      : nIPFeat = IP_CONST_FEAT_EMPOWER_MYSTERY                      ; break;
        case FEAT_EXTEND_MYSTERY                       : nIPFeat = IP_CONST_FEAT_EXTEND_MYSTERY                       ; break;
        case FEAT_MAXIMIZE_MYSTERY                     : nIPFeat = IP_CONST_FEAT_MAXIMIZE_MYSTERY                     ; break;
        case FEAT_QUICKEN_MYSTERY                      : nIPFeat = IP_CONST_FEAT_QUICKEN_MYSTERY                      ; break;
        case FEAT_STILL_MYSTERY                        : nIPFeat = IP_CONST_FEAT_STILL_MYSTERY                        ; break;
    }

    return nIPFeat;
}