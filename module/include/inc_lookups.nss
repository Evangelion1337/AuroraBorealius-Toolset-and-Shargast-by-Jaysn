/*

    This file is used for lookup functions for psionics and newspellbooks
    It is supposed to reduce the need for large loops that may result in
    TMI errors.
    It does this by creating arrays in advance and the using those as direct
    lookups.
*/

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////


void MakeLookupLoop(int nClass, string sFile, int nMin, int nMax, int nLoopSize = 100, string sTemp = "");
void SetupLookupStage(object oMod, int n);


//this returns the real SpellID of "wrapper" spells cast by psionic or the new spellbooks
int GetPowerFromSpellID(int nSpellID);

/**
 * Maps spells.2da rows of the class-specific entries to corresponding cls_psipw_*.2da rows.
 *
 * @param nSpellID Spells.2da row to determine cls_psipw_*.2da row for
 * @return         The mapped value
 */
int GetPowerfileIndexFromSpellID(int nSpellID);

/**
 * Maps spells.2da rows of the real entries to corresponding cls_psipw_*.2da rows.
 *
 * @param nSpellID Spells.2da row to determine cls_psipw_*.2da row for
 * @return         The mapped value
 */
int GetPowerfileIndexFromRealSpellID(int nRealSpellID);

//this retuns the featID of the class-specific feat for a spellID
//useful for psionics GetHasPower function
int GetClassFeatFromPower(int nPowerID, int nClass);

/**
 * Determines cls_spell_*.2da index from a given new spellbook class-specific
 * spell spells.2da index.
 *
 * @param nSpell The class-specific spell to find cls_spell_*.2da index for
 * @return       The cls_spell_*.2da index in whichever class's file that the
 *               given spell belongs to.
 *               If the spell at nSpell isn't a newspellbook class-specific spell,
 *               returns -1 instead.
 */
int SpellToSpellbookID(int nSpell);

/**
 * Determines cls_spell_*.2da index from a given spells.2da index.
 *
 * @param nClass The class in whose spellbook to search in
 * @param nSpell The spell to search for
 * @return       The cls_spell_*.2da index in whichever class's file that the
 *               given spell belongs to.
 *               If nSpell does not exist within the spellbook,
 *               returns -1 instead.
 */
int RealSpellToSpellbookID(int nClass, int nSpell);

/**
 * Determines number of metamagics from a given spells.2da index.
 *
 * @param nClass The class in whose spellbook to search in
 * @param nSpell The spell to search for
 * @return       The number of metamagics in cls_spell_*.2da
 *               for a particular spell.
 */
int RealSpellToSpellbookIDCount(int nClass, int nSpell);

/**
 * Determines the name of the 2da file that defines the number of alternate magic
 * system powers/spells/whathaveyou known, maximum level of such known and
 * number of uses at each level of the given class. And possibly related things
 * that apply to that specific system.
 *
 * @param nClass CLASS_TYPE_* of the class to determine the powers known 2da name of
 * @return       The name of the given class's powers known 2da
 */
string GetAMSKnownFileName(int nClass);

/**
 * Determines the name of the 2da file that lists the powers/spells/whathaveyou
 * on the given class's list of such.
 *
 * @param nClass CLASS_TYPE_* of the class to determine the power list 2da name of
 * @return       The name of the given class's power list 2da
 */
string GetAMSDefinitionFileName(int nClass);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_2dacache"
#include "prc_inc_array"
#include "prc_class_const"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

object _inc_lookups_GetCacheObject(string sTag)
{
    object oWP = GetObjectByTag(sTag);
    if(!GetIsObjectValid(oWP))
    {
        object oChest = GetObjectByTag("Bioware2DACache");
        if(!GetIsObjectValid(oChest))
        {
            //has to be an object, placeables cant go through the DB
            oChest = CreateObject(OBJECT_TYPE_CREATURE, "prc_2da_cache",
                                  GetLocation(GetObjectByTag("HEARTOFCHAOS")), FALSE, "Bioware2DACache");
			SetPlotFlag(oChest, TRUE);
			SetCreatureAppearanceType(oChest, APPEARANCE_TYPE_INVISIBLE_HUMAN_MALE);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY), oChest);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(), oChest);
			AssignCommand(oWP, ActionUseSkill(SKILL_HIDE, oChest));								  
        }
        if(!GetIsObjectValid(oChest))
        {
            //has to be an object, placeables cant go through the DB
            oChest = CreateObject(OBJECT_TYPE_CREATURE, "prc_2da_cache",
                                  GetStartingLocation(), FALSE, "Bioware2DACache");
			SetPlotFlag(oChest, TRUE);
			SetCreatureAppearanceType(oChest, APPEARANCE_TYPE_INVISIBLE_HUMAN_MALE);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY), oChest);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(), oChest);
			AssignCommand(oWP, ActionUseSkill(SKILL_HIDE, oChest));								  
        }

        int nContainer = 0;
        string sContainerName = "Bio2DACacheTokenContainer_Lkup_";
        object oContainer = GetObjectByTag(sContainerName + IntToString(nContainer));

        // Find last existing container
        if(GetIsObjectValid(oContainer))
        {
            nContainer = GetLocalInt(oContainer, "ContainerCount");
            oContainer = GetObjectByTag(sContainerName + IntToString(nContainer));

            // Make sure it's not full
            if(GetLocalInt(oContainer, "NumTokensInside") >= 34) // Container has 35 slots. Attempt to not use them all, just in case
            {
                oContainer = OBJECT_INVALID;
                ++nContainer; // new container is 1 higher than last one
            }
        }

        // We need to create a container
        if(!GetIsObjectValid(oContainer))
        {
            oContainer = CreateObject(OBJECT_TYPE_ITEM, "nw_it_contain001", GetLocation(oChest), FALSE, sContainerName + IntToString(nContainer));
            DestroyObject(oContainer);
            oContainer = CopyObject(oContainer, GetLocation(oChest), oChest, sContainerName + IntToString(nContainer));
            // store the new number of containers in this series
            if(nContainer)
                SetLocalInt(GetObjectByTag(sContainerName + "0"), "ContainerCount", nContainer);
            // else this is the first container - do nothing as this is the same as storing 0 on it.
            // Also here we still have 2 objects with the same tag so above code may get
            // the object destroyed at the end of the function if this is the first container.
        }

        // Create the new token
        oWP = CreateItemOnObject("hidetoken", oContainer, 1, sTag);

        // Increment token count tracking variable
        SetLocalInt(oContainer, "NumTokensInside", GetLocalInt(oContainer, "NumTokensInside") + 1);
    }

    if(!GetIsObjectValid(oWP))
    {
        DoDebug("ERROR: Failed to create lookup storage token for " + sTag);
        return OBJECT_INVALID;
    }

    return oWP;
}

void SetLkupStage(int nStage, object oModule, int nClass, string sFile)
{
    SetLocalInt(oModule, "PRCLookup_Stage", nStage + 1);
    SetLocalInt(oModule, "PRCLookup_Class", nClass);
    SetLocalString(oModule, "PRCLookup_File", sFile);
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void RunLookupLoop()
{
    // check if we run lookup before
    if(GetXP(GetObjectByTag("Bioware2DACache")) & 0x01)
    {
        if (DEBUG) DoDebug("RunLookupLoop() - marker found - exiting");
        return;
    }

    object oModule = GetModule();
    SetupLookupStage(oModule, 1);
    int nClass = GetLocalInt(oModule, "PRCLookup_Class");
    string sFile = GetLocalString(oModule, "PRCLookup_File");
    if (DEBUG) DoDebug("RunLookupLoop(): Looking in "+sFile+" for nClass "+IntToString(nClass));
    MakeLookupLoop(nClass, sFile, 1, PRCGetDynamicFileEnd(sFile));
}

void RunNextLoop()
{
    object oModule = GetModule();
    int nStage = GetLocalInt(oModule, "PRCLookup_Stage");
    SetupLookupStage(oModule, nStage);
    int nClass = GetLocalInt(oModule, "PRCLookup_Class");
    if(nClass)
    {
        string sFile = GetLocalString(oModule, "PRCLookup_File");
        if (DEBUG) DoDebug("RunNextLoop(): Looking in "+sFile+" for nClass "+IntToString(nClass));
        MakeLookupLoop(nClass, sFile, 1, PRCGetDynamicFileEnd(sFile));
    }
    else
    {
        DeleteLocalInt(oModule, "PRCLookup_Stage");
        DeleteLocalInt(oModule, "PRCLookup_Class");
        DeleteLocalString(oModule, "PRCLookup_File");

        //mark lookup as done, tell hb to save the DB
        object oCache = GetObjectByTag("Bioware2DACache");
        SetXP(oCache, GetXP(oCache) | 0x01);
        SetLocalInt(oModule, "Bioware2dacacheCount", GetPRCSwitch(PRC_USE_BIOWARE_DATABASE) - 5);
    }
}

void SetupLookupStage(object oMod, int n)
{
    switch(n)
    {
        case  1: SetLkupStage(n, oMod, CLASS_TYPE_PSION,               "cls_psipw_psion");  break;
        case  2: SetLkupStage(n, oMod, CLASS_TYPE_PSYWAR,              "cls_psipw_psywar"); break;
        case  3: SetLkupStage(n, oMod, CLASS_TYPE_WILDER,              "cls_psipw_wilder"); break;
        case  4: SetLkupStage(n, oMod, CLASS_TYPE_FIST_OF_ZUOKEN,      "cls_psipw_foz");    break;
        case  5: SetLkupStage(n, oMod, CLASS_TYPE_WARMIND,             "cls_psipw_warmnd"); break;
        case  6: SetLkupStage(n, oMod, CLASS_TYPE_TRUENAMER,           "cls_true_utter");   break;
        case  7: SetLkupStage(n, oMod, CLASS_TYPE_CRUSADER,            "cls_move_crusdr");  break;
        case  8: SetLkupStage(n, oMod, CLASS_TYPE_SWORDSAGE,           "cls_move_swdsge");  break;
        case  9: SetLkupStage(n, oMod, CLASS_TYPE_WARBLADE,            "cls_move_warbld");  break;
        case 10: SetLkupStage(n, oMod, CLASS_TYPE_DRAGONFIRE_ADEPT,    "cls_inv_dfa");      break;
        case 11: SetLkupStage(n, oMod, CLASS_TYPE_DRAGON_SHAMAN,       "cls_inv_drgshm");   break;
        case 12: SetLkupStage(n, oMod, CLASS_TYPE_WARLOCK,             "cls_inv_warlok");   break;
        case 13: SetLkupStage(n, oMod, CLASS_TYPE_ARCHIVIST,           "cls_spell_archv");  break;
        case 14: SetLkupStage(n, oMod, CLASS_TYPE_BARD,                "cls_spell_bard");   break;
        case 15: SetLkupStage(n, oMod, CLASS_TYPE_BEGUILER,            "cls_spell_beguil"); break;
        case 16: SetLkupStage(n, oMod, CLASS_TYPE_DREAD_NECROMANCER,   "cls_spell_dnecro"); break;
        case 17: SetLkupStage(n, oMod, CLASS_TYPE_DUSKBLADE,           "cls_spell_duskbl"); break;
        case 18: SetLkupStage(n, oMod, CLASS_TYPE_FAVOURED_SOUL,       "cls_spell_favsol"); break;
        case 19: SetLkupStage(n, oMod, CLASS_TYPE_HARPER,              "cls_spell_harper"); break;
        case 20: SetLkupStage(n, oMod, CLASS_TYPE_HEXBLADE,            "cls_spell_hexbl");  break;
        case 21: SetLkupStage(n, oMod, CLASS_TYPE_JUSTICEWW,           "cls_spell_justww"); break;
        case 22: SetLkupStage(n, oMod, CLASS_TYPE_SORCERER,            "cls_spell_sorc");   break;
        case 23: SetLkupStage(n, oMod, CLASS_TYPE_SUBLIME_CHORD,       "cls_spell_schord"); break;
        case 24: SetLkupStage(n, oMod, CLASS_TYPE_SUEL_ARCHANAMACH,    "cls_spell_suel");   break;
        case 25: SetLkupStage(n, oMod, CLASS_TYPE_VIGILANT,            "cls_spell_vigil");  break;
        case 26: SetLkupStage(n, oMod, CLASS_TYPE_WARMAGE,             "cls_spell_wrmage"); break;
        case 27: SetLkupStage(n, oMod, CLASS_TYPE_KNIGHT_WEAVE,        "cls_spell_kngtwv"); break;
        case 28: SetLkupStage(n, oMod, CLASS_TYPE_PSYCHIC_ROGUE,       "cls_psipw_psyrog"); break;        
        case 29: SetLkupStage(n, oMod, CLASS_TYPE_SHADOWCASTER,        "cls_myst_shdcst");  break;  
        case 30: SetLkupStage(n, oMod, CLASS_TYPE_SHADOWSMITH,         "cls_myst_shdsmt");  break; 
        case 31: SetLkupStage(n, oMod, CLASS_TYPE_CELEBRANT_SHARESS,   "cls_spell_sharss"); break; 
		
		//:: These were all moved to the Bioware spellbooks -Jaysyn
		//case 14: SetLkupStage(n, oMod, CLASS_TYPE_ASSASSIN,            "cls_spell_asasin"); break;
        //case 46: SetLkupStage(n, oMod, CLASS_TYPE_CULTIST_SHATTERED_PEAK, "cls_spell_cultst"); break; 
        //case 40: SetLkupStage(n, oMod, CLASS_TYPE_NENTYAR_HUNTER,      "cls_spell_hunter"); break;
        //case 28: SetLkupStage(n, oMod, CLASS_TYPE_SHADOWLORD,          "cls_spell_tfshad"); break;
        //case 29: SetLkupStage(n, oMod, CLASS_TYPE_SLAYER_OF_DOMIEL,    "cls_spell_sod");    break;
        //case 29: SetLkupStage(n, oMod, CLASS_TYPE_SOHEI,               "cls_spell_sohei");  break;
        //case 33: SetLkupStage(n, oMod, CLASS_TYPE_VASSAL,              "cls_spell_vassal"); break;
        //case 17: SetLkupStage(n, oMod, CLASS_TYPE_BLACKGUARD,          "cls_spell_blkgrd"); break;
        //case 24: SetLkupStage(n, oMod, CLASS_TYPE_KNIGHT_CHALICE,      "cls_spell_kchal");  break;
        //case 25: SetLkupStage(n, oMod, CLASS_TYPE_KNIGHT_MIDDLECIRCLE, "cls_spell_kotmc");  break;        
        //case 26: SetLkupStage(n, oMod, CLASS_TYPE_SOLDIER_OF_LIGHT,    "cls_spell_sol");    break;
        //case 24: SetLkupStage(n, oMod, CLASS_TYPE_OCULAR,              "cls_spell_ocu");    break;
        //case 30: SetLkupStage(n, oMod, CLASS_TYPE_BLIGHTER,            "cls_spell_blight"); break;
        //case 21: SetLkupStage(n, oMod, CLASS_TYPE_HEALER,              "cls_spell_healer"); break;
        //case 23: SetLkupStage(n, oMod, CLASS_TYPE_SHAMAN,              "cls_spell_shaman"); break;
        
        default: SetLkupStage(n, oMod, 0, ""); break;
    }
}
/*
void LookupSpells(int nRealSpellID, string sClass, string sLevel);
{
    int nDescriptor = Get2DACache("prc_spells", "Descriptor", nRealSpellID);//should already be in cache, just read the value

DESCRIPTOR_ACID
DESCRIPTOR_AIR
DESCRIPTOR_COLD
DESCRIPTOR_LIGHT
DESCRIPTOR_ELECTRICITY
DESCRIPTOR_DARKNESS
DESCRIPTOR_FIRE
DESCRIPTOR_SONIC


SUBSCHOOL_HEALING
SUBSCHOOL_SUMMONING
SUBSCHOOL_POLYMORPH

SPELL_SCHOOL_ENCHANTMENT
SPELL_SCHOOL_NECROMANCY
SPELL_SCHOOL_ABJURATION

    string sLevel = Get2DACache("spells", "Cleric", nRealSpellID);
    if(sLevel != "")
    {
        oLevelToken = _inc_lookups_GetCacheObject("SpellLvl_2_Level_"+sLevel);
        // check if array exist, if not create one
        if(!array_exists(oLevelToken, "Lkup"))
            array_create(oLevelToken, "Lkup");
        array_set_int(oLevelToken, "Lkup", array_get_size(oLevelToken, "Lkup"), i);
    }
    sLevel = Get2DACache("spells", "Druid", nRealSpellID);
    if(sLevel != "")
    {
        oLevelToken = _inc_lookups_GetCacheObject("SpellLvl_3_Level_"+sLevel);
        // check if array exist, if not create one
        if(!array_exists(oLevelToken, "Lkup"))
            array_create(oLevelToken, "Lkup");
        array_set_int(oLevelToken, "Lkup", array_get_size(oLevelToken, "Lkup"), i);
    }
    sLevel = Get2DACache("spells", "Paladin", nRealSpellID);
    if(sLevel != "")
    {
        oLevelToken = _inc_lookups_GetCacheObject("SpellLvl_6_Level_"+sLevel);
        // check if array exist, if not create one
        if(!array_exists(oLevelToken, "Lkup"))
            array_create(oLevelToken, "Lkup");
        array_set_int(oLevelToken, "Lkup", array_get_size(oLevelToken, "Lkup"), i);
    }
    sLevel = Get2DACache("spells", "Ranger", nRealSpellID);
    if(sLevel != "")
    {
        oLevelToken = _inc_lookups_GetCacheObject("SpellLvl_7_Level_"+sLevel);
        // check if array exist, if not create one
        if(!array_exists(oLevelToken, "Lkup"))
            array_create(oLevelToken, "Lkup");
        array_set_int(oLevelToken, "Lkup", array_get_size(oLevelToken, "Lkup"), i);
    }
    sLevel = Get2DACache("spells", "Wiz_Sorc", nRealSpellID);
    if(sLevel != "")
    {
        oLevelToken = _inc_lookups_GetCacheObject("SpellLvl_10_Level_"+sLevel);
        // check if array exist, if not create one
        if(!array_exists(oLevelToken, "Lkup"))
            array_create(oLevelToken, "Lkup");
        array_set_int(oLevelToken, "Lkup", array_get_size(oLevelToken, "Lkup"), i);
    }

*/


void MakeLookupLoop(int nClass, string sFile, int nMin, int nMax, int nLoopSize = 100, string sTemp = "")
{
    // Tell the function to skip before reaching nMax
    int bSkipLoop = FALSE;
    int i;

    if(DEBUG) DoDebug("MakeLookupLoop("
                 +IntToString(nClass)+", "
                 +sFile+", "
                 +IntToString(nMin)+", "
                 +IntToString(nMax)+", "
                 +IntToString(nLoopSize)+", "
                 +") : sTemp = "+sTemp);

    // psionic, tob, truenameing and ivocation using classes have slightly different handling
    // new AMS classes should be added here
    int bAMS = FALSE;

    if(nClass == CLASS_TYPE_PSION
    || nClass == CLASS_TYPE_PSYWAR
    || nClass == CLASS_TYPE_PSYCHIC_ROGUE
    || nClass == CLASS_TYPE_WILDER
    || nClass == CLASS_TYPE_FIST_OF_ZUOKEN
    || nClass == CLASS_TYPE_WARMIND
    || nClass == CLASS_TYPE_CRUSADER
    || nClass == CLASS_TYPE_SWORDSAGE
    || nClass == CLASS_TYPE_WARBLADE
    || nClass == CLASS_TYPE_TRUENAMER
    || nClass == CLASS_TYPE_SHADOWCASTER
    || nClass == CLASS_TYPE_SHADOWSMITH
    || nClass == CLASS_TYPE_DRAGONFIRE_ADEPT
    || nClass == CLASS_TYPE_DRAGON_SHAMAN
    || nClass == CLASS_TYPE_WARLOCK)
        bAMS = TRUE;

    object oSpellIDToken = bAMS ? _inc_lookups_GetCacheObject("PRC_SpellIDToClsPsipw"):
                                  _inc_lookups_GetCacheObject("PRC_GetRowFromSpellID");

    // Failed to obtain a valid token - nothing to store on
    if(!GetIsObjectValid(oSpellIDToken))
        bSkipLoop = TRUE;

    // Starting a new run and the data is present already. Assume the whole thing is present and abort
    if(nMin == 1
    && GetLocalInt(oSpellIDToken, Get2DACache(sFile, "SpellID", 1)))
    {
        if(DEBUG) DoDebug("MakeLookupLoop("+sFile+") restored from database");
        bSkipLoop = TRUE;
    }

    if(!bSkipLoop)
    {
        string sClass = IntToString(nClass);

        object oLevelToken;
        object oPowerToken = _inc_lookups_GetCacheObject("PRC_GetPowerFromSpellID");
        object oRealSpellIDToken = bAMS ? _inc_lookups_GetCacheObject("PRC_GetClassFeatFromPower_"+sClass):
                                      _inc_lookups_GetCacheObject("PRC_GetRowFromRealSpellID");

        int nRealSpellID, nFeatID, nCount;
        string sSpellID, sRealSID;
        for(i = nMin; i < nMin + nLoopSize; i++)
        {
            // None of the relevant 2da files have blank Label entries on rows other than 0. We can assume i is greater than 0 at this point
            if(Get2DAString(sFile, "Label", i) == "") // Using Get2DAString() instead of Get2DACache() to avoid caching useless data
            {
                bSkipLoop = TRUE;
                break;// exit the loop
            }

            sSpellID = Get2DACache(sFile, "SpellID", i);
            sRealSID = Get2DACache(sFile, "RealSpellID", i);
            nRealSpellID = StringToInt(sRealSID);

            //GetPowerfileIndexFromSpellID
            //SpellToSpellbookID
            SetLocalInt(oSpellIDToken, sSpellID, i);
            
            //GetPowerfileIndexFromRealSpellID
            SetLocalInt(oSpellIDToken, sRealSID, i);

            //GetPowerFromSpellID
            SetLocalInt(oPowerToken, sSpellID, nRealSpellID);

            //Spell level lookup
            if(!bAMS || nClass == CLASS_TYPE_WARLOCK)
            {
                string sReqFt = bAMS ? "" : Get2DACache(sFile, "ReqFeat", i);// Only new spellbooks have the ReqFeat column. No sense in caching it for other stuff
                if(sReqFt == "")
                {
                    string sLevel = Get2DACache(sFile, "Level", i);
                    oLevelToken = _inc_lookups_GetCacheObject("SpellLvl_"+sClass+"_Level_"+sLevel);
                    // check if array exist, if not create one
                    if(!array_exists(oLevelToken, "Lkup"))
                        array_create(oLevelToken, "Lkup");

                    array_set_int(oLevelToken, "Lkup", array_get_size(oLevelToken, "Lkup"), i);

                    //LookupSpellDescriptor(nRealSpellID, sClass, sLevel);
                }
            }

            //GetClassFeatFromPower
            if(bAMS)
            {
                nFeatID = StringToInt(Get2DACache(sFile, "FeatID", i));
                if(nFeatID != 0)
                {
                    SetLocalInt(oRealSpellIDToken, sRealSID, nFeatID);
                }
            }
            //RealSpellToSpellbookID
            //RealSpellToSpellbookIDCount
            else
            {
                if(sRealSID == sTemp)
                {
                    nCount += 1;
                    continue;
                }
                else
                {
                    SetLocalInt(oRealSpellIDToken, sClass+"_"+sTemp+"_Count", nCount);
                    SetLocalInt(oRealSpellIDToken, sClass+"_"+sRealSID+"_Start", i);
                    sTemp = sRealSID;
                    nCount = 0;
                }
            }
        }
    }

    // And delay continuation to avoid TMI
    if(i < nMax && !bSkipLoop)
        DelayCommand(0.0, MakeLookupLoop(nClass, sFile, i, nMax, nLoopSize, sTemp));
    else
        DelayCommand(0.0, RunNextLoop());
}

int GetPowerFromSpellID(int nSpellID)
{
    object oWP = GetObjectByTag("PRC_GetPowerFromSpellID");
    int nPower = GetLocalInt(oWP, /*"PRC_GetPowerFromSpellID_" + */IntToString(nSpellID));
    if(nPower == 0)
        nPower = -1;
    return nPower;
}

int GetPowerfileIndexFromSpellID(int nSpellID)
{
    object oWP = GetObjectByTag("PRC_SpellIDToClsPsipw");
    int nIndex = GetLocalInt(oWP, /*"PRC_SpellIDToClsPsipw_" + */IntToString(nSpellID));
    return nIndex;
}

int GetPowerfileIndexFromRealSpellID(int nRealSpellID)
{
    object oWP = GetObjectByTag("PRC_SpellIDToClsPsipw");
    int nIndex = GetLocalInt(oWP, /*"PRC_SpellIDToClsPsipw_" + */IntToString(nRealSpellID));
    return nIndex;
}

int GetClassFeatFromPower(int nPowerID, int nClass)
{
    string sLabel = "PRC_GetClassFeatFromPower_" + IntToString(nClass);
    object oWP = GetObjectByTag(sLabel);
    int nPower = GetLocalInt(oWP, /*sLabel+"_" + */IntToString(nPowerID));
    if(nPower == 0)
        nPower = -1;
    return nPower;
}

int SpellToSpellbookID(int nSpell)
{
    object oWP = GetObjectByTag("PRC_GetRowFromSpellID");
    int nOutSpellID = GetLocalInt(oWP, /*"PRC_GetRowFromSpellID_" + */IntToString(nSpell));
    if(nOutSpellID == 0)
        nOutSpellID = -1;
    if(DEBUG) DoDebug("inc_lookup >> SpellToSpellbookID: (nSpell: " + IntToString(nSpell) + ") = nOutSpellID: " + IntToString(nOutSpellID));
    return nOutSpellID;
}

int RealSpellToSpellbookID(int nClass, int nSpell)
{
    object oWP = GetObjectByTag("PRC_GetRowFromRealSpellID");
    int nOutSpellID = GetLocalInt(oWP, IntToString(nClass) + "_" + IntToString(nSpell) + "_Start");
    if(nOutSpellID == 0)
        nOutSpellID = -1;
    return nOutSpellID;
}

int RealSpellToSpellbookIDCount(int nClass, int nSpell)
{
    return GetLocalInt(GetObjectByTag("PRC_GetRowFromRealSpellID"), IntToString(nClass) + "_" + IntToString(nSpell) + "_Count");
}

string GetAMSKnownFileName(int nClass)
{
    // Get the class-specific base
    string sFile = Get2DACache("classes", "FeatsTable", nClass);

    // Various naming schemes based on system
    if(nClass == CLASS_TYPE_TRUENAMER)
        sFile = "cls_true_known";
    // ToB
    else if(nClass == CLASS_TYPE_CRUSADER || nClass == CLASS_TYPE_SWORDSAGE || nClass == CLASS_TYPE_WARBLADE)
        sFile = "cls_mvkn" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061210
    // Shadowcasting
    else if(nClass == CLASS_TYPE_SHADOWCASTER || nClass == CLASS_TYPE_SHADOWSMITH)
        sFile = "cls_mykn" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061210          
    // Invocations
    else if(nClass == CLASS_TYPE_DRAGONFIRE_ADEPT || nClass == CLASS_TYPE_WARLOCK || nClass == CLASS_TYPE_DRAGON_SHAMAN)
        sFile = "cls_invkn" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061210
    // Assume psionics if no other match
    else
        sFile = "cls_psbk" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061210

    return sFile;
}

string GetAMSDefinitionFileName(int nClass)
{
    // Get the class-specific base
    string sFile = Get2DACache("classes", "FeatsTable", nClass);

    // Various naming schemes based on system
    if(nClass == CLASS_TYPE_TRUENAMER)
        sFile = "cls_true_utter";
    // ToB
    else if(nClass == CLASS_TYPE_CRUSADER || nClass == CLASS_TYPE_SWORDSAGE || nClass == CLASS_TYPE_WARBLADE)
        sFile = "cls_move" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061210
    // Shadowcasting
    else if(nClass == CLASS_TYPE_SHADOWCASTER || nClass == CLASS_TYPE_SHADOWSMITH)
        sFile = "cls_myst" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061210        
    // Invoc
    else if(nClass == CLASS_TYPE_DRAGONFIRE_ADEPT || nClass == CLASS_TYPE_WARLOCK || nClass == CLASS_TYPE_DRAGON_SHAMAN)
        sFile = "cls_inv" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061210
    // Assume psionics if no other match
    else
        sFile = "cls_psipw" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061210

    return sFile;
}

// Test main
//void main(){}