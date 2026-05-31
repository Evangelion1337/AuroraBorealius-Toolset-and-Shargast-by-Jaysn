//::///////////////////////////////////////////////
//:: Psionics include: Powers known
//:: psi_inc_powknown
//::///////////////////////////////////////////////
/** @file
    Defines functions for adding & removing
    powers known.

    Data stored:

    - For each power list
    -- Total number of powers known
    -- A modifier value to maximum powers known on this list to account for stuff like
       Apopsi, Expanded Knowledge and Psychic Chirurgery that add or remove powers
    -- An array related to powers the knowledge of which is not dependent on character level
    --- Each array entry specifies the spells.2da row of the known power's class-specific entry
    -- For each character level on which powers have been gained from this list
    --- An array of powers gained on this level
    ---- Each array entry specifies the spells.2da row of the known power's class-specific entry

    @author Ornedan
    @date   Created - 2006.01.06
    @date   Modified - 2006.04.21
            Changed the stored value from cls_psipw_*.2da row to spells.2da row of the
            class-specific entry because the adding policy to cls_psipw_*.2da means that the rows
            after the added entry are moved. Which would break compatibility with old characters.
            On the other hand, if the spells.2da entries are moved, the result would likely be a
            backwards-compatibility loss anyway.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
#include "prc_inc_spells"
//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// Constants are provided via psi_inc_core

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Gives the creature the control feats for the given power and marks the power
 * in a powers known array.
 * If the power's data is already stored in one of the powers known arrays for
 * the list or adding the power's data to the array fails, the function aborts.
 *
 * @param oCreature       The creature to gain the power
 * @param nList           The list the power comes from. One of POWER_LIST_*
 * @param n2daRow         The 2da row in the lists's 2da file that specifies the power.
 * @param bLevelDependent If this is TRUE, the power is tied to a certain level and can
 *                        be lost via level loss. If FALSE, the power is not dependent
 *                        of a level and cannot be lost via level loss.
 * @param nLevelToTieTo   If bLevelDependent is TRUE, this specifies the level the power
 *                        is gained on. Otherwise, it's ignored.
 *                        The default value (-1) means that the current level of oCreature
 *                        will be used.
 * 
 * @return                TRUE if the power was successfully stored and control feats added.
 *                        FALSE otherwise.
 */
int AddPowerKnown(object oCreature, int nList, int n2daRow, int bLevelDependent = FALSE, int nLevelToTieTo = -1, int nExpandedKnowledge = 0);

/**
 *
 */
//int RemoveSpecificPowerKnown(object oCreature, int nList, int n2daRow);

/**
 * Removes all powers gained from each list on the given level.
 *
 * @param oCreature The creature whose powers to remove
 * @param nLevel    The level to clear
 */
void RemovePowersKnownOnLevel(object oCreature, int nLevel);

/**
 * Gets the value of the powers known modifier, which is a value that is added
 * to the 2da-specified maximum powers known to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to get
 * @param nList     The list the maximum powers known from which the modifier
 *                  modifies. One of POWER_LIST_*
 */
int GetKnownPowersModifier(object oCreature, int nList);

/**
 * Sets the value of the powers known modifier, which is a value that is added
 * to the 2da-specified maximum powers known to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to set
 * @param nList     The list the maximum powers known from which the modifier
 *                  modifies. One of POWER_LIST_*
 */
void SetKnownPowersModifier(object oCreature, int nList, int nNewValue);

/**
 * Gets the number of powers a character character possesses from a
 * specific list.
 *
 * @param oCreature The creature whose powers to check
 * @param nList     The list to check. One of POWER_LIST_*
 * @return          The number of powers known oCreature has from nList
 */
int GetPowerCount(object oCreature, int nList);

/**
 * Gets the maximum number of powers a character may posses from a given list
 * at this time. Calculated based on class levels, feats and a misceallenous
 * modifier.
 *
 * @param oCreature Character to determine maximum powers for
 * @param nList     POWER_LIST_* of the list to determine maximum powers for
 * @return          Maximum number of powers that oCreature may know from the given list.
 */
int GetMaxPowerCount(object oCreature, int nList);

/**
 * Determines whether a character has a given power, gained via some power list.
 * Psi-like abilities do not count.
 *
 * @param nPower    POWER_* of the power to test
 * @param oCreature Character to test for the possession of the power
 * @return          TRUE if the character has the power, FALSE otherwise
 */
int GetHasPower(int nPower, object oCreature = OBJECT_SELF);

/**
 * Converts a CLASS_TYPE_* constant to a corresponding POWER_LIST_* constant.
 * Special: CLASS_TYPE_INVALID corresponds to POWER_LIST_EXP_KNOWLEDGE.
 *
 * @param nClassType CLASS_TYPE_* to determine POWER_LIST_* for
 * @return           POWER_LIST_* constant for nClassType. 0 if there is no
 *                   power list for the given CLASS_TYPE_*
 */
//int ClassTypeToPowerList(int nClassType);

/**
 * Converts a POWER_LIST_* constant to a corresponding CLASS_TYPE_* constant.
 * Special: POWER_LIST_EXP_KNOWLEDGE corresponds to CLASS_TYPE_INVALID.
 *
 * @param nPowerList POWER_LIST_* to determine CLASS_TYPE_* for
 * @return           CLASS_TYPE_* constant for nPowerList. 0 if there is no
 *                   class type for the given POWER_LIST_*
 */
//int PowerListToClassType(int nPowerList);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "psi_inc_core"
//#include "prc_inc_spells" // Access to lookup and 2da


//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _RecurseRemoveArray(object oCreature, string sArrayName, string sPowerFile, int nArraySize, int nCurIndex)
{
    if(DEBUG) DoDebug("_RecurseRemoveArray():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "sArrayName = '" + sArrayName + "'\n"
                    + "sPowerFile = '" + sPowerFile + "'\n"
                    + "nArraySize = " + IntToString(nArraySize) + "\n"
                    + "nCurIndex = " + IntToString(nCurIndex) + "\n"
                      );

    // Determine whether we've already parsed the whole array or not
    if(nCurIndex >= nArraySize)
    {
        if(DEBUG) DoDebug("_RecurseRemoveArray(): Running itemproperty removal loop.");
        // Loop over itemproperties on the skin and remove each match
        object oSkin = GetPCSkin(oCreature);
        itemproperty ipTest = GetFirstItemProperty(oSkin);
        while(GetIsItemPropertyValid(ipTest))
        {
            // Check if the itemproperty is a bonus feat that has been marked for removal
            if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_FEAT                                            &&
               GetLocalInt(oCreature, "PRC_PowerFeatRemovalMarker_" + IntToString(GetItemPropertySubType(ipTest)))
               )
            {
                if(DEBUG) DoDebug("_RecurseRemoveArray(): Removing bonus feat itemproperty:\n" + DebugIProp2Str(ipTest));
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
        string sName = "PRC_PowerFeatRemovalMarker_" + Get2DACache(sPowerFile, "IPFeatID",
                                                                   GetPowerfileIndexFromSpellID(persistant_array_get_int(oCreature, sArrayName, nCurIndex))
                                                                   );
        if(DEBUG) DoDebug("_RecurseRemoveArray(): Recursing through array, marker set:\n" + sName);

        SetLocalInt(oCreature, sName, TRUE);
        // Recurse to next array index
        _RecurseRemoveArray(oCreature, sArrayName, sPowerFile, nArraySize, nCurIndex + 1);
        // After returning, delete the local
        DeleteLocalInt(oCreature, sName);
    }
}

void _RemovePowerArray(object oCreature, int nList, int nLevel)
{
    if(DEBUG) DoDebug("_RemovePowerArray():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "nList = " + IntToString(nList) + "\n"
                      );

    string sBase  = _POWER_LIST_NAME_BASE + IntToString(nList);
    string sArray = sBase + _POWER_LIST_LEVEL_ARRAY + IntToString(nLevel);
    int nSize = persistant_array_get_size(oCreature, sArray);

    // Reduce the total by the array size
    SetPersistantLocalInt(oCreature, sBase + _POWER_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oCreature, sBase + _POWER_LIST_TOTAL_KNOWN) - nSize
                          );

    // Remove each power in the array
    _RecurseRemoveArray(oCreature, sArray, GetAMSDefinitionFileName(/*PowerListToClassType(*/nList/*)*/), nSize, 0);

    // Remove the array itself
    persistant_array_delete(oCreature, sArray);
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int AddPowerKnown(object oCreature, int nList, int n2daRow, int bLevelDependent = FALSE, int nLevelToTieTo = -1, int nExpandedKnowledge = 0)
{
    string sBase      = nExpandedKnowledge < 0 ? _POWER_LIST_NAME_BASE + IntToString(nExpandedKnowledge):
                                                 _POWER_LIST_NAME_BASE + IntToString(nList);
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

        sArray += _POWER_LIST_LEVEL_ARRAY + IntToString(nLevelToTieTo);
    }
    else
    {
        sArray += _POWER_LIST_GENERAL_ARRAY;
    }

    // Make sure the power isn't already in an array. If it is, abort and return FALSE
    // Loop over each level array and check that it isn't there.
    for(i = 1; i <= GetHitDice(oCreature); i++)
    {
        sTestArray = sBase + _POWER_LIST_LEVEL_ARRAY + IntToString(i);
        if(persistant_array_exists(oCreature, sTestArray))
        {
            nSize = persistant_array_get_size(oCreature, sTestArray);
            for(j = 0; j < nSize; j++)
                if(persistant_array_get_int(oCreature, sArray, j) == nSpells2daRow)
                    return FALSE;
        }
    }
    // Check the non-level-dependent array
    sTestArray = sBase + _POWER_LIST_GENERAL_ARRAY;
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
        if(DEBUG) DoDebug("psi_inc_powknown: AddPowerKnown(): ERROR: Unable to add power to known array\n"
                        + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                        + "nList = " + IntToString(nList) + "\n"
                        + "n2daRow = " + IntToString(n2daRow) + "\n"
                        + "bLevelDependent = " + DebugBool2String(bLevelDependent) + "\n"
                        + "nLevelToTieTo = " + IntToString(nLevelToTieTo) + "\n"
                        + "nSpells2daRow = " + IntToString(nSpells2daRow) + "\n"
                        + "nExpandedKnowledge = " + IntToString(nExpandedKnowledge) + "\n"
                          );
        return FALSE;
    }

    // Increment powers known total
    SetPersistantLocalInt(oCreature, sBase + _POWER_LIST_TOTAL_KNOWN,
                          GetPersistantLocalInt(oCreature, sBase + _POWER_LIST_TOTAL_KNOWN) + 1
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

/** @todo If ever required
int RemoveSpecificPowerKnown(object oCreature, int nList, int n2daRow)
{
}
*/
void RemovePowersKnownOnLevel(object oCreature, int nLevel)
{
    if(DEBUG) DoDebug("psi_inc_powknown: RemovePowersKnownOnLevel():\n"
                    + "oCreature = " + DebugObject2Str(oCreature) + "\n"
                    + "nLevel = " + IntToString(nLevel) + "\n"
                      );

    string sPostFix = _POWER_LIST_LEVEL_ARRAY + IntToString(nLevel);
    // For each power list, determine if an array exists for this level.
    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_PSION) + sPostFix))
        // If one does exist, clear it
        _RemovePowerArray(oCreature, POWER_LIST_PSION, nLevel);

    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_WILDER) + sPostFix))
        _RemovePowerArray(oCreature, POWER_LIST_WILDER, nLevel);

    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_PSYWAR) + sPostFix))
        _RemovePowerArray(oCreature, POWER_LIST_PSYWAR, nLevel);
        
    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_PSYROG) + sPostFix))
        _RemovePowerArray(oCreature, POWER_LIST_PSYROG, nLevel);        

    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_FIST_OF_ZUOKEN) + sPostFix))
        _RemovePowerArray(oCreature, POWER_LIST_FIST_OF_ZUOKEN, nLevel);

    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_WARMIND) + sPostFix))
        _RemovePowerArray(oCreature, POWER_LIST_WARMIND, nLevel);

    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_EXP_KNOWLEDGE) + sPostFix))
        _RemovePowerArray(oCreature, POWER_LIST_EXP_KNOWLEDGE, nLevel);

    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_EPIC_EXP_KNOWLEDGE) + sPostFix))
        _RemovePowerArray(oCreature, POWER_LIST_EPIC_EXP_KNOWLEDGE, nLevel);

    if(persistant_array_exists(oCreature, _POWER_LIST_NAME_BASE + IntToString(POWER_LIST_MISC) + sPostFix))
        _RemovePowerArray(oCreature, POWER_LIST_MISC, nLevel);
}

int GetKnownPowersModifier(object oCreature, int nList)
{
    return GetPersistantLocalInt(oCreature, _POWER_LIST_NAME_BASE + IntToString(nList) + _POWER_LIST_MODIFIER);
}

void SetKnownPowersModifier(object oCreature, int nList, int nNewValue)
{
    SetPersistantLocalInt(oCreature, _POWER_LIST_NAME_BASE + IntToString(nList) + _POWER_LIST_MODIFIER, nNewValue);
}

int GetPowerCount(object oCreature, int nList)
{
    return GetPersistantLocalInt(oCreature, _POWER_LIST_NAME_BASE + IntToString(nList) + _POWER_LIST_TOTAL_KNOWN);
}

int GetMaxPowerCount(object oCreature, int nList)
{
    int nMaxPowers = 0;

    switch(nList)
    {
        case POWER_LIST_PSION:{
            // Determine base powers known
            int nLevel = GetLevelByClass(CLASS_TYPE_PSION, oCreature);				
				nLevel += GetPsionicPRCLevels(oCreature, CLASS_TYPE_PSION);
                //nLevel += GetPrimaryPsionicClass(oCreature) == CLASS_TYPE_PSION ? GetPsionicPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxPowers = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_PSION), "PowersKnown", nLevel - 1));

            // Calculate feats
            // Apply the epic feat Power Knowledge - +2 powers known per
            int nFeat = FEAT_POWER_KNOWLEDGE_PSION_1;
            while(nFeat <= FEAT_POWER_KNOWLEDGE_PSION_10 &&
                  GetHasFeat(nFeat, oCreature))
            {
                nMaxPowers += 2;
                nFeat++;
            }

            // Add in the custom modifier
            nMaxPowers += GetKnownPowersModifier(oCreature, nList);
            break;
        }
        case POWER_LIST_WILDER:{
            // Determine base powers known
            int nLevel = GetLevelByClass(CLASS_TYPE_WILDER, oCreature);
				nLevel += GetPsionicPRCLevels(oCreature, CLASS_TYPE_WILDER);
                //nLevel += GetPrimaryPsionicClass(oCreature) == CLASS_TYPE_WILDER ? GetPsionicPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxPowers = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_WILDER), "PowersKnown", nLevel - 1));

            // Calculate feats
            // Apply the epic feat Power Knowledge - +2 powers known per
            int nFeat = FEAT_POWER_KNOWLEDGE_WILDER_1;
            while(nFeat <= FEAT_POWER_KNOWLEDGE_WILDER_10 &&
                  GetHasFeat(nFeat, oCreature))
            {
                nMaxPowers += 2;
                nFeat++;
            }

            // Add in the custom modifier
            nMaxPowers += GetKnownPowersModifier(oCreature, nList);
            break;
        }
        case POWER_LIST_PSYWAR:{
            // Determine base powers known
            int nLevel = GetLevelByClass(CLASS_TYPE_PSYWAR, oCreature);
				nLevel += GetPsionicPRCLevels(oCreature, CLASS_TYPE_PSYWAR);
                //nLevel += GetPrimaryPsionicClass(oCreature) == CLASS_TYPE_PSYWAR ? GetPsionicPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxPowers = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_PSYWAR), "PowersKnown", nLevel - 1));

            // Calculate feats
            // Apply the epic feat Power Knowledge - +2 powers known per
            int nFeat = FEAT_POWER_KNOWLEDGE_PSYWAR_1;
            while(nFeat <= FEAT_POWER_KNOWLEDGE_PSYWAR_10 &&
                  GetHasFeat(nFeat, oCreature))
            {
                nMaxPowers += 2;
                nFeat++;
            }

            // Add in the custom modifier
            nMaxPowers += GetKnownPowersModifier(oCreature, nList);
            break;
        }
        case POWER_LIST_PSYROG:{
            // Determine base powers known
            int nLevel = GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE, oCreature);
				nLevel += GetPsionicPRCLevels(oCreature, CLASS_TYPE_PSYCHIC_ROGUE);
                //nLevel += GetPrimaryPsionicClass(oCreature) == CLASS_TYPE_PSYCHIC_ROGUE ? GetPsionicPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxPowers = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_PSYCHIC_ROGUE), "PowersKnown", nLevel - 1));

            // Calculate feats
            // Apply the epic feat Power Knowledge - +2 powers known per
            int nFeat = FEAT_POWER_KNOWLEDGE_PSYROG_1;
            while(nFeat <= FEAT_POWER_KNOWLEDGE_PSYROG_10 &&
                  GetHasFeat(nFeat, oCreature))
            {
                nMaxPowers += 2;
                nFeat++;
            }

            // Add in the custom modifier
            nMaxPowers += GetKnownPowersModifier(oCreature, nList);
            break;
        }        
        case POWER_LIST_FIST_OF_ZUOKEN:{
            // Determine base powers known
            int nLevel = GetLevelByClass(CLASS_TYPE_FIST_OF_ZUOKEN, oCreature);
				nLevel += GetPsionicPRCLevels(oCreature, CLASS_TYPE_FIST_OF_ZUOKEN);
                //nLevel += GetPrimaryPsionicClass(oCreature) == CLASS_TYPE_FIST_OF_ZUOKEN ? GetPsionicPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxPowers = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_FIST_OF_ZUOKEN), "PowersKnown", nLevel - 1));

            // Calculate feats
            // Apply the epic feat Power Knowledge - +2 powers known per
            int nFeat = FEAT_POWER_KNOWLEDGE_FIST_OF_ZUOKEN_1;
            while(nFeat <= FEAT_POWER_KNOWLEDGE_FIST_OF_ZUOKEN_10 &&
                  GetHasFeat(nFeat, oCreature))
            {
                nMaxPowers += 2;
                nFeat++;
            }

            // Add in the custom modifier
            nMaxPowers += GetKnownPowersModifier(oCreature, nList);
            break;
        }
        case POWER_LIST_WARMIND:{
            // Determine base powers known
            int nLevel = GetLevelByClass(CLASS_TYPE_WARMIND, oCreature);
				nLevel += GetPsionicPRCLevels(oCreature, CLASS_TYPE_WARMIND);
                //nLevel += GetPrimaryPsionicClass(oCreature) == CLASS_TYPE_WARMIND ? GetPsionicPRCLevels(oCreature) : 0;
            if(nLevel == 0)
                break;
            nMaxPowers = StringToInt(Get2DACache(GetAMSKnownFileName(CLASS_TYPE_WARMIND), "PowersKnown", nLevel - 1));

            // Calculate feats
            // Apply the epic feat Power Knowledge - +2 powers known per
            int nFeat = FEAT_POWER_KNOWLEDGE_WARMIND_1;
            while(nFeat <= FEAT_POWER_KNOWLEDGE_WARMIND_10 &&
                  GetHasFeat(nFeat, oCreature))
            {
                nMaxPowers += 2;
                nFeat++;
            }

            // Add in the custom modifier
            nMaxPowers += GetKnownPowersModifier(oCreature, nList);
            break;
        }
        case POWER_LIST_EXP_KNOWLEDGE:{
            // Calculate feats
            // Apply the feat Expanded Knowledge - +1 powers known per feat
            int nFeat = FEAT_EXPANDED_KNOWLEDGE_1;
            while(nFeat <= FEAT_EXPANDED_KNOWLEDGE_10 &&
                  GetHasFeat(nFeat, oCreature))
            {
                nMaxPowers += 1;
                nFeat++;
            }

            // Add in the custom modifier
            nMaxPowers += GetKnownPowersModifier(oCreature, nList);
            break;
        }
        case POWER_LIST_EPIC_EXP_KNOWLEDGE:{
            int nFeat = FEAT_EPIC_EXPANDED_KNOWLEDGE_1;
            while(nFeat <= FEAT_EPIC_EXPANDED_KNOWLEDGE_10 &&
                  GetHasFeat(nFeat, oCreature))
            {
                nMaxPowers += 1;
                nFeat++;
            }

            // Add in the custom modifier
            nMaxPowers += GetKnownPowersModifier(oCreature, nList);
            break;
        }
        case POWER_LIST_MISC:{
            //no limits here, should not be checked
        }

        default:{
            string sErr = "GetMaxPowerCount(): ERROR: Unknown power list value: " + IntToString(nList);
            if(DEBUG) DoDebug(sErr);
            else      WriteTimestampedLogEntry(sErr);
        }
    }

    return nMaxPowers;
}

int GetHasPower(int nPower, object oCreature = OBJECT_SELF)
{
    // Debug output  
    if (DEBUG) DoDebug("GetHasPower: Checking power " + IntToString(nPower));  
      
    // Check if it's a subradial spell first  
    if (GetIsSubradialSpell(nPower))  
    {  
        if(DEBUG) DoDebug("GetHasPower: " + IntToString(nPower) + " is a subradial");  
        int nMasterSpell = GetMasterSpellFromSubradial(nPower);  
        if (nMasterSpell != -1)  
        {  
            if(DEBUG) DoDebug("GetHasPower: Master spell is " + IntToString(nMasterSpell));  
            nPower = nMasterSpell;  
        }  
    }  
      
	
	// Check MISC list first (for Hidden Talent and similar feats)  
	if(GetHasFeat(GetClassFeatFromPower(nPower, CLASS_TYPE_INVALID), oCreature))  
		return TRUE;

	if((GetLevelByClass(CLASS_TYPE_PSION, oCreature)
	&& GetHasFeat(GetClassFeatFromPower(nPower, CLASS_TYPE_PSION), oCreature)
	) ||
	(GetLevelByClass(CLASS_TYPE_PSYWAR, oCreature)
	&& GetHasFeat(GetClassFeatFromPower(nPower, CLASS_TYPE_PSYWAR), oCreature)
	) ||
	(GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE, oCreature)
	&& GetHasFeat(GetClassFeatFromPower(nPower, CLASS_TYPE_PSYCHIC_ROGUE), oCreature)
	) ||        
	(GetLevelByClass(CLASS_TYPE_WILDER, oCreature)
	&& GetHasFeat(GetClassFeatFromPower(nPower, CLASS_TYPE_WILDER), oCreature)
	) ||
	(GetLevelByClass(CLASS_TYPE_FIST_OF_ZUOKEN, oCreature)
	&& GetHasFeat(GetClassFeatFromPower(nPower, CLASS_TYPE_FIST_OF_ZUOKEN), oCreature)
	) ||
	(GetLevelByClass(CLASS_TYPE_WARMIND, oCreature)
	&& GetHasFeat(GetClassFeatFromPower(nPower, CLASS_TYPE_WARMIND), oCreature)
	)
	// add new psionic classes here
	)
		return TRUE;
		
	return FALSE;
}

string DebugListKnownPowers(object oCreature)
{
    string sReturn = "Powers known by " + DebugObject2Str(oCreature) + ":\n";
    int i, j, k, numPowerLists = 8;
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
            case 1: nPowerList = POWER_LIST_PSION;          sReturn += "Psion";           break;
            case 2: nPowerList = POWER_LIST_WILDER;         sReturn += "Wilder";          break;
            case 3: nPowerList = POWER_LIST_PSYWAR;         sReturn += "Psychic Warrior"; break;
            case 4: nPowerList = POWER_LIST_PSYROG;         sReturn += "Psychic Rogue";   break;
            case 5: nPowerList = POWER_LIST_FIST_OF_ZUOKEN; sReturn += "Fist of Zuoken";  break;
            case 6: nPowerList = POWER_LIST_WARMIND;        sReturn += "Warmind";         break;

            // This should always be last
            case 7: nPowerList = POWER_LIST_EXP_KNOWLEDGE;   sReturn += "Expanded Knowledge"; break;
            case 8: nPowerList = POWER_LIST_EPIC_EXP_KNOWLEDGE; sReturn += "Epic Expanded Knowledge"; break;
            case 9: nPowerList = POWER_LIST_MISC;           sReturn += "Misceallenous";   break;
        }
        sReturn += " powers known:\n";

        // Determine if the character has any powers from this list
        sPowerFile = GetAMSDefinitionFileName(nPowerList);
        sArrayBase = _POWER_LIST_NAME_BASE + IntToString(nPowerList);

        // Loop over levels
        for(j = 1; j <= GetHitDice(oCreature); j++)
        {
            sArray = sArrayBase + _POWER_LIST_LEVEL_ARRAY + IntToString(j);
            if(persistant_array_exists(oCreature, sArray))
            {
                sReturn += "   Gained on level " + IntToString(j) + ":\n";
                nSize = persistant_array_get_size(oCreature, sArray);
                for(k = 0; k < nSize; k++)
                    sReturn += "    " + GetStringByStrRef(StringToInt(Get2DACache("spells", "Name",
                                                                                  GetPowerFromSpellID(persistant_array_get_int(oCreature, sArray, k))
                                                                                  )
                                                                      )
                                                          )
                            + "\n";
            }
        }

        // Non-leveldependent powers
        sArray = sArrayBase + _POWER_LIST_GENERAL_ARRAY;
        if(persistant_array_exists(oCreature, sArray))
        {
            sReturn += "   Non-leveldependent:\n";
            nSize = persistant_array_get_size(oCreature, sArray);
            for(k = 0; k < nSize; k++)
                sReturn += "    " + GetStringByStrRef(StringToInt(Get2DACache("spells", "Name",
                                                                                  GetPowerFromSpellID(persistant_array_get_int(oCreature, sArray, k))
                                                                                  )
                                                                      )
                                                          )
                        + "\n";
        }
    }

    return sReturn;
}

/* Probably unnecessary
int ClassTypeToPowerList(int nClassType)
{
    int nReturn = 0;
    switch(nClassType)
    {
        case CLASS_TYPE_PSION:          nReturn = POWER_LIST_PSION;          break;
        case CLASS_TYPE_WILDER:         nReturn = POWER_LIST_WILDER;         break;
        case CLASS_TYPE_PSYWAR:         nReturn = POWER_LIST_PSYWAR;         break;
        case CLASS_TYPE_FIST_OF_ZUOKEN: nReturn = POWER_LIST_FIST_OF_ZUOKEN; break;

        case CLASS_TYPE_INVALID:        nReturn = POWER_LIST_EXP_KNOWLEDGE;  break;
        case -2:                        nReturn = POWER_LIST_EPIC_EXP_KNOWLEDGE; break;
        case -3:                        nReturn = POWER_LIST_MISC;           break;

        default:{
            string sErr = "ClassTypeToPowerList(): ERROR: Unknown class type value: " + IntToString(nClassType);
            if(DEBUG) DoDebug(sErr);
            else      WriteTimestampedLogEntry(sErr);
        }
    }

    return nReturn;
}

int PowerListToClassType(int nPowerList)
{
    int nReturn = 0;
    switch(nPowerList)
    {
        case POWER_LIST_PSION:          nReturn = CLASS_TYPE_PSION;          break;
        case POWER_LIST_WILDER:         nReturn = CLASS_TYPE_WILDER;         break;
        case POWER_LIST_PSYWAR:         nReturn = CLASS_TYPE_PSYWAR;         break;
        case POWER_LIST_FIST_OF_ZUOKEN: nReturn = CLASS_TYPE_FIST_OF_ZUOKEN; break;

        case POWER_LIST_EXP_KNOWLEDGE:  nReturn = CLASS_TYPE_INVALID;        break;
        case POWER_LIST_EPIC_EXP_KNOWLEDGE: nReturn = -2;                    break;
        case POWER_LIST_MISC:           nReturn = -3;                        break;

        default:{
            string sErr = "PowerListToClassType(): ERROR: Unknown power list value: " + IntToString(nPowerList);
            if(DEBUG) DoDebug(sErr);
            else      WriteTimestampedLogEntry(sErr);
        }
    }

    return nReturn;
}
*/
// Test main
//void main(){}
