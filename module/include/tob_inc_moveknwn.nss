//::///////////////////////////////////////////////
//:: Tome of Battle include: Maneuvers Known
//:: tob_inc_moveknwn
//::///////////////////////////////////////////////
/** @file
    Defines functions for adding & removing
    Maneuvers known.

    Data stored:

    - For each Discipline list
    -- Total number of Maneuvers known
    -- A modifier value to maximum Maneuvers known on this list to account for feats and classes that add Maneuvers
    -- An array related to Maneuvers the knowledge of which is not dependent on character level
    --- Each array entry specifies the spells.2da row of the known Maneuvers's class-specific entry
    -- For each character level on which Maneuvers have been gained from this list
    --- An array of Maneuvers gained on this level
    ---- Each array entry specifies the spells.2da row of the known Maneuvers's class-specific entry

    @author Stratovarius
    @date   Created - 2007.03.19
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

// Included here to provide the values for the constants below
#include "prc_inc_spells"

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int MANEUVER_LIST_CRUSADER          = CLASS_TYPE_CRUSADER;
const int MANEUVER_LIST_SWORDSAGE         = CLASS_TYPE_SWORDSAGE;
const int MANEUVER_LIST_WARBLADE          = CLASS_TYPE_WARBLADE;
const int MANEUVER_LIST_RETH_DEKALA       = RACIAL_TYPE_RETH_DEKALA; // 67, so well away from the classes

/// Special Maneuver list. Maneuvers gained via Martial Study or other sources.
const int MANEUVER_LIST_MISC          = CLASS_TYPE_INVALID;//-1;

const string _MANEUVER_LIST_NAME_BASE     = "PRC_ManeuverList_";
const string _MANEUVER_LIST_DISCIPLINE    = "PRC_DisciplineTotal_";
const string _MANEUVER_LIST_TOTAL_KNOWN   = "_TotalKnown";
const string _MANEUVER_LIST_MODIFIER      = "_KnownModifier";
const string _MANEUVER_LIST_MISC_ARRAY    = "_ManeuversKnownMiscArray";
const string _MANEUVER_LIST_LEVEL_ARRAY   = "_ManeuversKnownLevelArray_";
const string _MANEUVER_LIST_GENERAL_ARRAY = "_ManeuversKnownGeneralArray";


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Gives the creature the control feats for the given Maneuver and marks the Maneuver
 * in a Maneuvers known array.
 * If the Maneuver's data is already stored in one of the Maneuvers known arrays for
 * the list or adding the Maneuver's data to the array fails, the function aborts.
 *
 * @param oCreature       The creature to gain the Maneuver
 * @param nList           The list the Maneuver comes from. One of MANEUVER_LIST_*
 * @param n2daRow         The 2da row in the lists's 2da file that specifies the Maneuver.
 * @param bLevelDependent If this is TRUE, the Maneuver is tied to a certain level and can
 *                        be lost via level loss. If FALSE, the Maneuver is not dependent
 *                        of a level and cannot be lost via level loss.
 * @param nLevelToTieTo   If bLevelDependent is TRUE, this specifies the level the Maneuver
 *                        is gained on. Otherwise, it's ignored.
 *                        The default value (-1) means that the current level of oCreature
 *                        will be used.
 * @param nDiscipline           Type of the Maneuver: Evolving Mind, Crafted Tool, or Perfected Map
 *
 * @return                TRUE if the Maneuver was successfully stored and control feats added.
 *                        FALSE otherwise.
 */
int AddManeuverKnown(object oCreature, int nList, int n2daRow, int nType, int bLevelDependent = FALSE, int nLevelToTieTo = -1);

/**
 * Removes all Maneuvers gained from each list on the given level.
 *
 * @param oCreature The creature whose Maneuvers to remove
 * @param nLevel    The level to clear
 */
void RemoveManeuversKnownOnLevel(object oCreature, int nLevel);

/**
 * Gets the value of the Maneuvers known modifier, which is a value that is added
 * to the 2da-specified maximum Maneuvers known to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to get
 * @param nList     The list the maximum Maneuvers known from which the modifier
 *                  modifies. One of MANEUVER_LIST_*
 * @param nType     MANEUVER_TYPE_
 */
int GetKnownManeuversModifier(object oCreature, int nList, int nType);

/**
 * Sets the value of the Maneuvers known modifier, which is a value that is added
 * to the 2da-specified maximum Maneuvers known to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to set
 * @param nList     The list the maximum Maneuvers known from which the modifier
 *                  modifies. One of MANEUVER_LIST_*
 * @param nType     MANEUVER_TYPE_
 */
void SetKnownManeuversModifier(object oCreature, int nList, int nNewValue, int nType);

/**
 * Gets the number of Maneuvers a character character possesses from a
 * specific list and lexicon
 *
 * @param oCreature The creature whose Maneuvers to check
 * @param nList     The list to check. One of MANEUVER_LIST_*
 * @param nType     MANEUVER_TYPE_
 * @return          The number of Maneuvers known oCreature has from nList
 */
int GetManeuverCount(object oCreature, int nList, int nType);

/**
 * Gets the number of Maneuvers a character character possesses from a
 * specific discipline
 *
 * @param oCreature   The creature whose Maneuvers to check
 * @param nDiscipline The discipline to check. One of DISCIPLINE_*
 * @param nType       MANEUVER_TYPE_
 * @return            The number of Maneuvers known oCreature has from nDiscipline
 */
int GetManeuverCountByDiscipline(object oCreature, int nDiscipline, int nType);

/**
 * Gets the maximum number of Maneuvers a character may posses from a given list
 * at this time. Calculated based on class levels, feats and a misceallenous
 * modifier. There are three Types of Maneuvers, so it checks each seperately.
 *
 * @param oCreature Character to determine maximum Maneuvers for
 * @param nList     MANEUVER_LIST_* of the list to determine maximum Maneuvers for
 * @param nType     MANEUVER_TYPE_ 
 * @return          Maximum number of Maneuvers that oCreature may know from the given list.
 */
int GetMaxManeuverCount(object oCreature, int nList, int nType);

/**
 * Determines whether a character has a given Maneuver, gained via some Maneuver list.
 *
 * @param nManeuver    MANEUVER_* of the Maneuver to test
 * @param nClass    Class to check for 
 * @param oCreature Character to test for the possession of the Maneuver
 * @return          TRUE if the character has the Maneuver, FALSE otherwise
 */
int GetHasManeuver(int nManeuver, int nClass, object oCreature = OBJECT_SELF);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

//#include "tob_inc_tobfunc"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _ManeuverRecurseRemoveArray(object oCreature, string sArrayName, string sUtterFile, int nArraySize, int nCurIndex)
{
    if(DEBUG) DoDebug("_ManeuverRecurseRemoveArray():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "sArrayName = '" + sArrayName + "'\n"
                    + "sUtterFile = '" + sUtterFile + "'\n"
                    + "nArraySize = " + IntToString(nArraySize) + "\n"
                    + "nCurIndex = " + IntToString(nCurIndex) + "\n"
                      );

    // Determine whether we've already parsed the whole array or not
    if(nCurIndex >= nArraySize)
    {
        if(DEBUG) DoDebug("_ManeuverRecurseRemoveArray(): Running itemproperty removal loop.");
        // Loop over itemproperties on the skin and remove each match
        object oSkin = GetPCSkin(oCreature);
        itemproperty ipTest = GetFirstItemProperty(oSkin);
        while(GetIsItemPropertyValid(ipTest))
        {
            // Check if the itemproperty is a bonus feat that has been marked for removal
            if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_FEAT                                            &&
               GetLocalInt(oCreature, "PRC_MoveFeatRemovalMarker_" + IntToString(GetItemPropertySubType(ipTest)))
               )
            {
                if(DEBUG) DoDebug("_ManeuverRecurseRemoveArray(): Removing bonus feat itemproperty:\n" + DebugIProp2Str(ipTest));
                // If so, remove it
                RemoveItemProperty(oSkin, ipTest);
                DeleteLocalInt(oCreature, "PRC_MoveFeatRemovalMarker_" + IntToString(GetItemPropertySubType(ipTest)));
            }

            ipTest = GetNextItemProperty(oSkin);
        }
    }
    // Still parsing the array
    else
    {
        int nMoveID = GetPowerfileIndexFromSpellID(persistant_array_get_int(oCreature, sArrayName, nCurIndex));
        // Set the marker
        string sName = "PRC_MoveFeatRemovalMarker_" + Get2DACache(sUtterFile, "IPFeatID", nMoveID);
        if(DEBUG) DoDebug("_ManeuverRecurseRemoveArray(): Recursing through array, marker set:\n" + sName);
        SetLocalInt(oCreature, sName, TRUE);

        string sType = Get2DACache(sUtterFile, "Type", nMoveID);
        if(sType != "1") sType = "2";//if not MANEUVER_TYPE_STANCE use MANEUVER_TYPE_MANEUVER
        string sDisciplineArray = _MANEUVER_LIST_DISCIPLINE + sType + "_" + Get2DACache(sUtterFile, "Discipline", nMoveID);
        SetPersistantLocalInt(oCreature, sDisciplineArray,
                              GetPersistantLocalInt(oCreature, sDisciplineArray) - 1);

        // Recurse to next array index
        _ManeuverRecurseRemoveArray(oCreature, sArrayName, sUtterFile, nArraySize, nCurIndex + 1);
    }
}

void _RemoveManeuverArray(object oCreature, int nList, int nLevel, int nType)
{
    if(DEBUG) DoDebug("_RemoveManeuverArray():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "nList = " + IntToString(nList) + "\n"
                      );

    string sBase  = _MANEUVER_LIST_NAME_BASE + IntToString(nList) + IntToString(nType);
    string sArray = sBase + _MANEUVER_LIST_LEVEL_ARRAY + IntToString(nLevel);
    int nSize = persistant_array_get_size(oCreature, sArray);

    // Reduce the total by the array size
    SetPersistantLocalInt(oCreature, sBase + _MANEUVER_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oCreature, sBase + _MANEUVER_LIST_TOTAL_KNOWN) - nSize
                          );

    // Remove each Maneuver in the array
    _ManeuverRecurseRemoveArray(oCreature, sArray, GetAMSDefinitionFileName(nList), nSize, 0);

    // Remove the array itself
    persistant_array_delete(oCreature, sArray);
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int AddManeuverKnown(object oCreature, int nList, int n2daRow, int nType, int bLevelDependent = FALSE, int nLevelToTieTo = -1)
{
    string sBase      = _MANEUVER_LIST_NAME_BASE + IntToString(nList) + IntToString(nType);
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
            nLevelToTieTo = GetHitDice(oCreature);

        sArray += _MANEUVER_LIST_LEVEL_ARRAY + IntToString(nLevelToTieTo);
    }
    else
    {
        sArray += _MANEUVER_LIST_GENERAL_ARRAY;
    }

    // Make sure the power isn't already in an array. If it is, abort and return FALSE
    // Loop over each level array and check that it isn't there.
    for(i = 1; i <= GetHitDice(oCreature); i++)
    {
        sTestArray = sBase + _MANEUVER_LIST_LEVEL_ARRAY + IntToString(i);
        if(persistant_array_exists(oCreature, sTestArray))
        {
            nSize = persistant_array_get_size(oCreature, sTestArray);
            for(j = 0; j < nSize; j++)
                if(persistant_array_get_int(oCreature, sArray, j) == nSpells2daRow)
                    return FALSE;
        }
    }
    // Check the non-level-dependent array
    sTestArray = sBase + _MANEUVER_LIST_GENERAL_ARRAY;
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
    if(persistant_array_set_int(oCreature, sArray, persistant_array_get_size(oCreature, sArray), nSpells2daRow) != SDL_SUCCESS)
    {
        if(DEBUG) DoDebug("tob_inc_moveknwn: AddPowerKnown(): ERROR: Unable to add power to known array\n"
                        + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                        + "nList = " + IntToString(nList) + "\n"
                        + "n2daRow = " + IntToString(n2daRow) + "\n"
                        + "bLevelDependent = " + DebugBool2String(bLevelDependent) + "\n"
                        + "nLevelToTieTo = " + IntToString(nLevelToTieTo) + "\n"
                        + "nSpells2daRow = " + IntToString(nSpells2daRow) + "\n"
                          );
        return FALSE;
    }

    // Increment Maneuvers known total
    SetPersistantLocalInt(oCreature, sBase + _MANEUVER_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oCreature, sBase + _MANEUVER_LIST_TOTAL_KNOWN) + 1
                          );

    // Increment Maneuvers known by discipline
    string sDisciplineArray = _MANEUVER_LIST_DISCIPLINE + IntToString(nType) + "_" + Get2DACache(sPowerFile, "Discipline", n2daRow);
    SetPersistantLocalInt(oCreature, sDisciplineArray,
                          GetPersistantLocalInt(oCreature, sDisciplineArray) + 1);

    // Give the power's control feats
    object oSkin        = GetPCSkin(oCreature);
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

void RemoveManeuversKnownOnLevel(object oCreature, int nLevel)
{
    if(DEBUG) DoDebug("tob_inc_moveknwn: RemoveManeuverKnownOnLevel():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "nLevel = " + IntToString(nLevel) + "\n"
                      );

    string sPostFix = _MANEUVER_LIST_LEVEL_ARRAY + IntToString(nLevel);
    // For each Maneuver list and type, determine if an array exists for this level.
    // There's only 2 types
    int nType;
    for(nType = 1;  nType <= 2; nType++)
    {
        if(persistant_array_exists(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(MANEUVER_LIST_CRUSADER) + sPostFix))
            // If one does exist, clear it
            _RemoveManeuverArray(oCreature, MANEUVER_LIST_CRUSADER, nLevel, nType);

        if(persistant_array_exists(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(MANEUVER_LIST_SWORDSAGE) + sPostFix))
            _RemoveManeuverArray(oCreature, MANEUVER_LIST_SWORDSAGE, nLevel, nType);

        if(persistant_array_exists(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(MANEUVER_LIST_WARBLADE) + sPostFix))
            _RemoveManeuverArray(oCreature, MANEUVER_LIST_WARBLADE, nLevel, nType);

        if(persistant_array_exists(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(MANEUVER_LIST_MISC) + sPostFix))
            _RemoveManeuverArray(oCreature, MANEUVER_LIST_MISC, nLevel, nType);
    }
}

int GetKnownManeuversModifier(object oCreature, int nList, int nType)
{
    return GetPersistantLocalInt(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(nList) + IntToString(nType) + _MANEUVER_LIST_MODIFIER);
}

void SetKnownManeuversModifier(object oCreature, int nList, int nNewValue, int nType)
{
    SetPersistantLocalInt(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(nList) + IntToString(nType) + _MANEUVER_LIST_MODIFIER, nNewValue);
}

int GetManeuverCount(object oCreature, int nList, int nType)
{
    return GetPersistantLocalInt(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(nList) + IntToString(nType) + _MANEUVER_LIST_TOTAL_KNOWN);
}

int GetManeuverCountByDiscipline(object oCreature, int nDiscipline, int nType)
{
	int nReturn = GetPersistantLocalInt(oCreature, _MANEUVER_LIST_DISCIPLINE + IntToString(nType) + "_" + IntToString(nDiscipline));
	
	// Doesn't use the normal method, so is added here for the purpose of prereqs
	if (GetRacialType(oCreature) == RACIAL_TYPE_RETH_DEKALA && nDiscipline == DISCIPLINE_DEVOTED_SPIRIT && nType == MANEUVER_TYPE_MANEUVER) nReturn += 2; 
	else if (GetRacialType(oCreature) == RACIAL_TYPE_RETH_DEKALA && nDiscipline == DISCIPLINE_DEVOTED_SPIRIT && nType == MANEUVER_TYPE_STANCE) nReturn += 2; 
	else if (GetRacialType(oCreature) == RACIAL_TYPE_RETH_DEKALA && nDiscipline == DISCIPLINE_IRON_HEART) nReturn += 2; 
	else if (GetRacialType(oCreature) == RACIAL_TYPE_RETH_DEKALA && nDiscipline == DISCIPLINE_TIGER_CLAW) nReturn += 1; 
    return nReturn;
}

int GetMaxManeuverCount(object oCreature, int nList, int nType)
{
    if(DEBUG) DoDebug("tob_moveconv: MaxManeuver nType: " + IntToString(nType));
    int nMaxManeuvers = 0;

    if(nList == MANEUVER_LIST_MISC)
    {
        if(DEBUG) DoDebug("GetMaxManeuverCount(): ERROR: Using unfinished power list!");
    }
    else
    {
        int nLevel = GetLevelByClass(nList, oCreature);
        string sFile = GetAMSKnownFileName(nList);
        if(nType == MANEUVER_TYPE_MANEUVER)
            nMaxManeuvers = StringToInt(Get2DACache(sFile, "ManeuverKnown", nLevel - 1));
        else if(nType == MANEUVER_TYPE_STANCE)
            nMaxManeuvers = StringToInt(Get2DACache(sFile, "StancesKnown", nLevel - 1));

        // Calculate feats

        // Add in the custom modifier
        nMaxManeuvers += GetKnownManeuversModifier(oCreature, nList, nType);
        if(DEBUG) DoDebug("GetMaxManeuverCount(): " + IntToString(nList) + " Maneuvers: " + IntToString(nMaxManeuvers));
    }

    return nMaxManeuvers;
}

int GetHasManeuver(int nManeuver, int nClass, object oCreature = OBJECT_SELF)
{
    if(GetLevelByClass(nClass, oCreature) && GetHasFeat(GetClassFeatFromPower(nManeuver, nClass), oCreature)) 
        return TRUE;
        
    return FALSE;
}

string DebugListKnownManeuvers(object oCreature)
{
    string sReturn = "Maneuvers known by " + DebugObject2Str(oCreature) + ":\n";
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
            case 1: nPowerList = MANEUVER_LIST_CRUSADER;          sReturn += "Crusader";  break;
            case 2: nPowerList = MANEUVER_LIST_SWORDSAGE;         sReturn += "Swordsage"; break;
            case 3: nPowerList = MANEUVER_LIST_WARBLADE;          sReturn += "Warblade";  break;
            case 4: nPowerList = MANEUVER_LIST_RETH_DEKALA;       sReturn += "Reth Dekala";  break;

            // This should always be last
            case 6: nPowerList = MANEUVER_LIST_MISC;           sReturn += "Misceallenous";   break;
        }
        sReturn += " Maneuvers known:\n";

        // Determine if the character has any Maneuvers from this list
        sPowerFile = GetAMSDefinitionFileName(nPowerList);
        sArrayBase = _MANEUVER_LIST_NAME_BASE + IntToString(nPowerList);

        // Loop over levels
        for(j = 1; j <= GetHitDice(oCreature); j++)
        {
            sArray = sArrayBase + _MANEUVER_LIST_LEVEL_ARRAY + IntToString(j);
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

        // Non-leveldependent Maneuvers
        sArray = sArrayBase + _MANEUVER_LIST_GENERAL_ARRAY;
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