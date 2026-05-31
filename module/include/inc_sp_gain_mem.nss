//:://////////////////////////////////////////////
//:: Name:    new spellbook spellgain / spell memorization include
//:: File:    inc_sp_gain_mem.nss
//:://////////////////////////////////////////////
/**
contains helper functions for the two dynamic conversation scripts
- prc_s_spellb.nss
- prc_s_spellgain.nss
that handle learning / gaining new spells at level up (prc_s_spellgain) 
or preparing what spells to learn at next rest (prc_s_spellb)

Author:    motu99
Created:   May 1, 2008
*/

//#include "prc_inc_core"	//granted access via parent (inc_newspellbook)

//:: Updated for .35 by Jaysyn 2023/03/11

//:://////////////////////////////////////////////
//:: Constants
//:://////////////////////////////////////////////

// max. number of classes a PC (or creature) can take (8 for NWN, 4 for NWN2)
const int MAX_CLASSES = 8;

//////////////////////////////////////////////////
/* Aid functions                                */
//////////////////////////////////////////////////

string GetNSBDefinitionFileName(int nClass);
int GetCasterLevelByClass(int nClass, object oPC);

int GetSpellsKnown_MaxCount(int nCasterLevel, int nClass, int nSpellLevel, object oPC);
int GetSpellsInClassSpellbook_Count(int nClass, int nSpellLevel);
string GetClassString(int nClass);
int GetMaxSpellLevelForCasterLevel(int nClass, int nCasterLevel);
int GetMinSpellLevelForCasterLevel(int nClass, int nCasterLevel);

void WipeSpellFromHide(int nIPFeatID, object oPC);

string GetSpellsKnown_Array(int nClass, int nSpellLevel = -1);
object GetSpellsOfClass_Token(int nClass, int nSpellLevel);
string GetSpellsOfClass_Array();
string GetSpellsMemorized_Array(int nClass);
string GetSpellsToBeMemorized_Array(int nClass, int nSpellSlotLevel);

void array_set_size(object oPC, string sArrayName, int nSize);
int array_has_string(object oPC, string sArrayName, string sValue, int nFirst = 0, int nSize = 0);
int array_has_int(object oPC, string sArrayName, int nValue, int nFirst = 0, int nSize = 0);
int persistant_array_has_string(object oPC, string sArrayName, string sValue, int nFirst = 0, int nSize = 0);
int persistant_array_has_int(object oPC, string sArrayName, int nValue, int nFirst = 0, int nSize = 0);
int array_extract_string(object oPC, string sArrayName, string sValue, int nFirst = 0);
int array_extract_int(object oPC, string sArrayName, int nValue, int nFirst = 0);
int persistant_array_extract_string(object oPC, string sArrayName, string sValue, int nFirst = 0);
int persistant_array_extract_int(object oPC, string sArrayName, int nValue, int nFirst = 0);

string GetMetaMagicString_Short(int nMetaMagic);
string GetMetaMagicString(int nMetaMagic);
int GetMetaMagicFromFeat(int nFeat);
int GetMetaMagicOfCaster(object oPC = OBJECT_SELF);

string GetFileForClass(int nClass);
int GetSpellslotLevel(int nClass, object oPC);
int GetSpellKnownMaxCount(int nLevel, int nSpellLevel, int nClass, object oPC);
int GetSpellbookTypeForClass(int nClass);

#include "inc_pers_array"
#include "inc_2dacache"

// name of the new spellbook file (cls_spell_*)
string GetNSBDefinitionFileName(int nClass)
{
    return GetFileForClass(nClass);
}

// gets the caster level (without special modifications due to feats), by which the max spell slot level is determined
int GetCasterLevelByClass(int nClass, object oPC)
{
    return GetSpellslotLevel(nClass, oPC);
    // return GetPrCAdjustedCasterLevel(nClass, oPC, TRUE);
}

// gets the maximum nr of spells that oPC can know with a given nCasterLevel, nClass and nSpellLevel
int GetSpellsKnown_MaxCount(int nCasterLevel, int nClass, int nSpellLevel, object oPC)
{
    return GetSpellKnownMaxCount(nCasterLevel, nSpellLevel, nClass, oPC);
}


// gets the total nr of spells available at nSpellLevel for nClass 
int GetSpellsInClassSpellbook_Count(int nClass, int nSpellLevel)
{
    return persistant_array_get_size(GetSpellsOfClass_Token(nClass, nSpellLevel), GetSpellsOfClass_Array());
}

string GetClassString(int nClass)
{
    // get the name of the feats table 2da
    string sClass = Get2DACache("classes", "FeatsTable", nClass);
    // truncate the first 8 characters (the "cls_feat"   part), leaving the "_<class>" part
    sClass = GetStringRight(sClass, GetStringLength(sClass) - 8);
    return sClass;
}

int GetMaxSpellLevelForCasterLevel_NewSB(int nClass, int nCasterLevel, object oPC)  
{  
    // Use the existing GetSpellslotLevel which properly handles new spellbook  
    int nEffectiveLevel = GetSpellslotLevel(nClass, oPC);  
      
    // Get the spell known table for this class  
    string sFile = Get2DACache("classes", "SpellKnownTable", nClass);  
      
    // Find the highest spell level available at this effective caster level  
    int nSpellLevel;  
    for(nSpellLevel = 9; nSpellLevel >= 0; nSpellLevel--)  
    {  
        string sTemp = Get2DACache(sFile, "SpellLevel" + IntToString(nSpellLevel), nEffectiveLevel - 1);  
        if(sTemp != "" && StringToInt(sTemp) > 0)  
        {  
            break;  
        }  
    }  
      
    return nSpellLevel;  
}

// gets the maximum spell level that nClass can cast at nCasterLevel
int GetMaxSpellLevelForCasterLevel(int nClass, int nCasterLevel)  
{  
    // Check if this character is using the new spellbook system  
    object oPC = OBJECT_SELF; // You may need to pass oPC as a parameter  
    if(GetLocalInt(oPC, "NSB_Class") == nClass)  
    {  
        // Use new spellbook calculation  
        return GetMaxSpellLevelForCasterLevel_NewSB(nClass, nCasterLevel, oPC);  
    }  
      
    // Original Bioware calculation  
    string sFile = Get2DACache("classes", "SpellGainTable", nClass);  
    nCasterLevel--;  
    int nSpellLevel;  
  
    if (Get2DACache(sFile, "NumSpellLevels", 9) != "")  
    {  
        string sTemp = Get2DACache(sFile, "NumSpellLevels", nCasterLevel);  
        if (sTemp != "")  
        {  
            nSpellLevel = StringToInt(sTemp)-1;  
            if (nSpellLevel <= 0) nSpellLevel = 0;  
        }  
    }  
    else  
    {  
        for (nSpellLevel=9; nSpellLevel >= 0; nSpellLevel--)  
        {  
            string sTemp = Get2DACache(sFile, "SpellLevel" + IntToString(nSpellLevel), nCasterLevel);  
            if (sTemp != "")  
            {  
                break;  
            }  
        }  
    }  
    return nSpellLevel;  
}


/* int GetMaxSpellLevelForCasterLevel(int nClass, int nCasterLevel)
{
    string sFile;
    // Bioware casters use their classes.2da-specified tables
    //if(GetIsBioSpellCastClass(nClass))
    //{
        sFile = Get2DACache("classes", "SpellGainTable", nClass);
    //}
    //else
    //{
    //    sFile = "cls_spbk" + GetClassString(nClass);
    //}

    // row nr in the files is nCasterLevel minus 1
    nCasterLevel--;
    int nSpellLevel;

    if (Get2DACache(sFile, "NumSpellLevels", 9) != "")
    {
        string sTemp = Get2DACache(sFile, "NumSpellLevels", nCasterLevel);
        if (sTemp != "")
        {
            nSpellLevel = StringToInt(sTemp)-1;
            if (nSpellLevel <= 0) nSpellLevel = 0;
        }
    }
    else
    {
        for (nSpellLevel=9; nSpellLevel >= 0; nSpellLevel--)
        {
            string sTemp = Get2DACache(sFile, "SpellLevel" + IntToString(nSpellLevel), nCasterLevel);
            if (sTemp != "")
            {
                break;
            }
        }
    }
    return nSpellLevel;
}
 */
 
// gets the minimum spell level that nClass can cast at nCasterLevel
int GetMinSpellLevelForCasterLevel(int nClass, int nCasterLevel)
{
    string sFile;
    // Bioware casters use their classes.2da-specified tables
    //if(GetIsBioSpellCastClass(nClass))
    //{
        sFile = Get2DACache("classes", "SpellGainTable", nClass);
    //}
    //else
    //{
    //    sFile = "cls_spbk" + GetClassString(nClass);
    //}

    // row nr in the files is nCasterLevel minus 1
    nCasterLevel--;

    int bFound = 0;

    int nSpellLevel;
    for (nSpellLevel=0; nSpellLevel <= 9; nSpellLevel++)
    {
        string sTemp = Get2DACache(sFile, "SpellLevel" + IntToString(nSpellLevel), nCasterLevel);
        if (sTemp != "")
        {
            bFound = TRUE;
            break;
        }
    }

    if (!bFound) nSpellLevel = -1;
    return nSpellLevel;
}

// wipes the IPbonusfeat from the hide
void WipeSpellFromHide(int nIPFeatID, object oPC)
{
    // go through all item properties on the hide
    object oHide = GetPCSkin(oPC);
    itemproperty ipTest = GetFirstItemProperty(oHide);
    while(GetIsItemPropertyValid(ipTest))
    {
        // is it a bonus feat?
        if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_FEAT)
        {
            // get the row nr of the bonus feat in iprp_feat.2da
            // is it the ipfeat to delete?
            if (GetItemPropertySubType(ipTest) == nIPFeatID)
            {
                RemoveItemProperty(oHide, ipTest);
                if(DEBUG) DoDebug("WipeSpellFromHide: Removing item property " + DebugIProp2Str(ipTest));
            }
        }
        ipTest = GetNextItemProperty(oHide);
    }
}

// one array for each class (array holds all spell levels, but only non-metamagicked masterspells)
string GetSpellsKnown_Array(int nClass, int nSpellLevel = -1)
{
    int nSpellbookType = GetSpellbookTypeForClass(nClass);
    if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
        return "Spellbook_Known_" + IntToString(nClass) + "_" + IntToString(nSpellLevel);
    return "Spellbook" + IntToString(nClass);
}

// class spellbook (one storage token for each spell level and class)
object GetSpellsOfClass_Token(int nClass, int nSpellLevel)
{
    return GetObjectByTag("SpellLvl_" + IntToString(nClass) + "_Level_" + IntToString(nSpellLevel));
}

string GetSpellsOfClass_Array()
{
    return "Lkup";
}

string GetSpellsMemorized_Array(int nClass)
{
    return "NewSpellbookMem_" + IntToString(nClass);
}

string GetSpellsToBeMemorized_Array(int nClass, int nSpellSlotLevel)
{
    return "Spellbook" + IntToString(nSpellSlotLevel) + "_" + IntToString(nClass);
}


void array_set_size(object oPC, string sArrayName, int nSize)
{
    SetPersistantLocalInt(oPC, sArrayName, nSize+1);
}

int array_has_string(object oPC, string sArrayName, string sValue, int nFirst = 0, int nSize = 0)
{
    // get array size, if size not already supplied
    if (nSize == 0) nSize = GetPersistantLocalInt(oPC, sArrayName) -1;
    int i;

    for (i = nFirst; i < nSize; i++)
    {
        if (sValue == GetPersistantLocalString(oPC, sArrayName + "_" + IntToString(i)))
            return i;
    }
    return -1;
}

int array_has_int(object oPC, string sArrayName, int nValue, int nFirst = 0, int nSize = 0)
{
    // array values are stored as strings, so convert nValue to a string
    return array_has_string(oPC, sArrayName, IntToString(nValue), nFirst, nSize);
}

int persistant_array_has_string(object oPC, string sArrayName, string sValue, int nFirst = 0, int nSize = 0)
{
    return array_has_string(oPC, sArrayName, sValue, nFirst, nSize);
}

int persistant_array_has_int(object oPC, string sArrayName, int nValue, int nFirst = 0, int nSize = 0)
{
    return array_has_string(oPC, sArrayName, IntToString(nValue), nFirst, nSize);
}

int array_extract_string(object oPC, string sArrayName, string sValue, int nFirst = 0)
{
    // get array size
    int nSize = GetPersistantLocalInt(oPC, sArrayName)-1;
    if (nSize <= nFirst) return -1;

    // position of the first found; -1 if not found
    int nPos = array_has_string(oPC, sArrayName, sValue, nFirst, nSize);
    if (nPos < 0) return -1;

    // Is is not the last element?
    if (nPos < nSize-1)
    {
        // then swap nPos (or rather nPos-1) with the last element (nSize-1)
        string sTemp = GetPersistantLocalString(oPC, sArrayName + "_" + IntToString(nSize-1));
        SetPersistantLocalString(oPC, sArrayName + "_" + IntToString(nPos), sTemp);
    }

    // now decrement the array size (note that we already subtracted one in the beginning)
    SetPersistantLocalInt(oPC, sArrayName, nSize);

    return nPos;
}

// extracts the integer value nValue from a persistant sArray on oPC
// extracts the first instance of nValue that it finds
// extracts it by swapping the last array element to the position of the extracted element and reducing the array size by one
// returns the position where the extracted element was found
int array_extract_int(object oPC, string sArrayName, int nValue, int nFirst = 0)
{
    // array values are stored as strings, so convert nValue to a string
    return array_extract_string(oPC, sArrayName, IntToString(nValue), nFirst);
}

int persistant_array_extract_string(object oPC, string sArrayName, string sValue, int nFirst = 0)
{
    return array_extract_string(oPC, sArrayName, sValue, nFirst);
}

int persistant_array_extract_int(object oPC, string sArrayName, int nValue, int nFirst = 0)
{
    // array values are stored as strings, so convert nValue to a string
    return array_extract_string(oPC, sArrayName, IntToString(nValue), nFirst);
}

string GetMetaMagicString_Short(int nMetaMagic)
{
    string s;
    if (nMetaMagic == 0) return s;

    if (nMetaMagic & METAMAGIC_EXTEND)   s += "ext ";
    if (nMetaMagic & METAMAGIC_SILENT)   s += "sil ";
    if (nMetaMagic & METAMAGIC_STILL)    s += "sti ";
    if (nMetaMagic & METAMAGIC_EMPOWER)  s += "emp ";
    if (nMetaMagic & METAMAGIC_MAXIMIZE) s += "max ";
    if (nMetaMagic & METAMAGIC_QUICKEN)  s += "qui ";

    return GetStringLeft(s, GetStringLength(s)-1);
}

string GetMetaMagicString(int nMetaMagic)
{
    string s;
    if (nMetaMagic == 0) return s;

    if (nMetaMagic & METAMAGIC_EXTEND)   s += "extend ";
    if (nMetaMagic & METAMAGIC_SILENT)   s += "silent ";
    if (nMetaMagic & METAMAGIC_STILL)    s += "still ";
    if (nMetaMagic & METAMAGIC_EMPOWER)  s += "empower ";
    if (nMetaMagic & METAMAGIC_MAXIMIZE) s += "maximize ";
    if (nMetaMagic & METAMAGIC_QUICKEN)  s += "quicken ";

    return GetStringLeft(s, GetStringLength(s)-1);
}

int GetMetaMagicFromFeat(int nFeat)
{
    switch(nFeat)
    {
        case FEAT_EMPOWER_SPELL:  return METAMAGIC_EMPOWER;
        case FEAT_EXTEND_SPELL:   return METAMAGIC_EXTEND;
        case FEAT_MAXIMIZE_SPELL: return METAMAGIC_MAXIMIZE;
        case FEAT_QUICKEN_SPELL:  return METAMAGIC_QUICKEN;
        case FEAT_SILENCE_SPELL:  return METAMAGIC_SILENT;
        case FEAT_STILL_SPELL:    return METAMAGIC_STILL;
    }
    return METAMAGIC_NONE;
}

int GetMetaMagicOfCaster(object oPC = OBJECT_SELF)
{
    int nMetaMagic;

    if (GetHasFeat(FEAT_EMPOWER_SPELL, oPC))  nMetaMagic |= METAMAGIC_EMPOWER;
    if (GetHasFeat(FEAT_EXTEND_SPELL, oPC))   nMetaMagic |= METAMAGIC_EXTEND;
    if (GetHasFeat(FEAT_MAXIMIZE_SPELL, oPC)) nMetaMagic |= METAMAGIC_MAXIMIZE;
    if (GetHasFeat(FEAT_QUICKEN_SPELL, oPC))  nMetaMagic |= METAMAGIC_QUICKEN;
    if (GetHasFeat(FEAT_SILENCE_SPELL, oPC))  nMetaMagic |= METAMAGIC_SILENT;
    if (GetHasFeat(FEAT_STILL_SPELL, oPC))    nMetaMagic |= METAMAGIC_STILL;

    return nMetaMagic;
}