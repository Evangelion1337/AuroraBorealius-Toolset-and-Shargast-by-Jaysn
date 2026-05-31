

/* Steps for adding a new spellbook

Prepared:
Make cls_spgn_*.2da
Make cls_spcr_*.2da
Make blank cls_spell_*.2da
Add cls_spgn_*.2da to classes.2da
Add class entry in prc_classes.2da
Add the spellbook feat (#1999) to cls_feat_*.2da at the appropriate level (not needed for NWN:EE)
Add class to PRCGetSpellSaveDC() in prc_add_spell_dc
Add class to GetSpellbookTypeForClass() below
Add class to GetAbilityScoreForClass() below
Add class to bKnowsAllClassSpells() below if necessary
Add class to GetIsArcaneClass() or GetIsDivineClass() in prc_inc_castlvl as appropriate
Add class to GetCasterLevelModifier() in prc_inc_castlvl if necessary
Add class to SetupLookupStage() in inc_lookups
Add class to GetCasterLvl() in prc_inc_spells
Add Practiced Spellcaster feat to feat.2da and to PracticedSpellcasting() in prc_inc_castlvl
Run the assemble_spellbooks.bat file
Make the prc_* scripts in newspellbook. The filenames can be found under the spell entries for the class in spells.2da.
Update the fileends for all relevant files in inc_switch_setup
Delete prc_data in the \database\ folder before testing new spells.

Spont:
Make cls_spgn_*.2da
Make cls_spkn_*.2da
Make cls_spcr_*.2da
Make blank cls_spell_*.2da
Add cls_spkn_*.2da and cls_spgn_*.2da to classes.2da
Add class entry in prc_classes.2da
Add class to PRCGetSpellSaveDC() in prc_add_spell_dc
Add class to GetSpellbookTypeForClass() below
Add class to GetAbilityScoreForClass() below
Add class to bKnowsAllClassSpells() below if necessary
Add class to GetIsArcaneClass() or GetIsDivineClass() in prc_inc_castlvl as appropriate
Add class to GetCasterLevelModifier() in prc_inc_castlvl if necessary
Add class to SetupLookupStage() in inc_lookups
Add class to GetCasterLvl() in prc_inc_spells
Add Practiced Spellcaster feat to feat.2da and to PracticedSpellcasting() in prc_inc_castlvl
Add class to prc_amagsys_gain if(CheckMissingSpells(oPC, CLASS_TYPE_SORCERER, MinimumSpellLevel, MaximumSpellLevel))
Add class to ExecuteScript("prc_amagsys_gain", oPC) list in EvalPRCFeats in prc_inc_function
Run the assemble_spellbooks.bat file
Make the prc_* scripts in newspellbook
Update the fileends for all relevant files in inc_switch_setup
Delete prc_data in the \database\ folder before testing new spells.

prc_classes.2da entry:
Label       - name for the class
Name        - tlk file strref
SpellCaster - does the class cast spells? 0 = No, 1 = Yes (used for bonus spellslot item properties)
SBType      - S = spontaneous, P = prepared
AL          - does the class use Advanced Learning of any type? 0 = No, 1 = Yes
*/

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

int GetSpellbookTypeForClass(int nClass);
int GetAbilityScoreForClass(int nClass, object oPC);

/**
 * Determines the given character's DC-modifying ability modifier for
 * the given class' spells. Handles split-score casters.
 *
 * @param nClass The spellcasting class for whose spells to determine ability mod to DC for
 * @param oPC    The character whose abilities to examine
 * @return       The DC-modifying ability score's ability modifier value
 */
int GetDCAbilityModForClass(int nClass, object oPC);

string GetFileForClass(int nClass);
int GetSpellslotLevel(int nClass, object oPC);
int GetItemBonusSlotCount(object oPC, int nClass, int nSpellLevel);
int GetSlotCount(int nLevel, int nSpellLevel, int nAbilityScore, int nClass, object oItemPosessor = OBJECT_INVALID);
int bKnowsAllClassSpells(int nClass);
int GetSpellKnownMaxCount(int nLevel, int nSpellLevel, int nClass, object oPC);
int GetSpellKnownCurrentCount(object oPC, int nSpellLevel, int nClass);
int GetSpellUnknownCurrentCount(object oPC, int nSpellLevel, int nClass);
void AddSpellUse(object oPC, int nSpellbookID, int nClass, string sFile, string sArrayName, int nSpellbookType, object oSkin, int nFeatID, int nIPFeatID, string sIDX = "");
void RemoveSpellUse(object oPC, int nSpellID, int nClass);
// int GetSpellUses(object oPC, int nSpellID, int nClass);
int GetSpellLevel(int nSpellID, int nClass);
void SetupSpells(object oPC, int nClass);
void CheckAndRemoveFeat(object oHide, itemproperty ipFeat);
void WipeSpellbookHideFeats(object oPC);
void CheckNewSpellbooks(object oPC);
void NewSpellbookSpell(int nClass, int nSpellbookType, int nMetamagic = METAMAGIC_NONE, int bInstantSpell = FALSE);
void CastSpontaneousSpell(int nClass, int bInstantSpell = FALSE);
void CastPreparedSpell(int nClass, int nMetamagic = METAMAGIC_NONE, int bInstantSpell = FALSE);
void ProcessPreparedSpellLevel(object oPC, int nClass, int nSpellLevel, int nLevel, int nAbility, string sClass, string sFile, string sArrayName, int nSpellbookType, object oSkin);

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

/*     stored in "prc_inc_sb_const"
    Accessed via "prc_inc_core"    */

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

// ** THIS ORDER IS IMPORTANT **

//#include "prc_effect_inc"         //access via prc_inc_core
//#include "inc_lookups"            //access via prc_inc_core
#include "prc_inc_core"
#include "inc_sp_gain_mem"
//#include "prc_inc_castlvl"        //access via prc_inc_core
//#include "prc_inc_descrptr"       //access via prc_inc_core
#include "inc_item_props"

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetSpellbookTypeForClass(int nClass)
{
    switch(nClass)
    {
        case CLASS_TYPE_ARCHIVIST:
		case CLASS_TYPE_ASSASSIN:
        case CLASS_TYPE_BLACKGUARD:
        case CLASS_TYPE_BLIGHTER:
        case CLASS_TYPE_CLERIC:
        case CLASS_TYPE_CULTIST_SHATTERED_PEAK:
        case CLASS_TYPE_DRUID:
        case CLASS_TYPE_HEALER:
        case CLASS_TYPE_KNIGHT_CHALICE:
        case CLASS_TYPE_KNIGHT_MIDDLECIRCLE:
        case CLASS_TYPE_NENTYAR_HUNTER:
        case CLASS_TYPE_OCULAR:
        case CLASS_TYPE_PALADIN:
        case CLASS_TYPE_RANGER:
        case CLASS_TYPE_SHADOWLORD:
        case CLASS_TYPE_SHAMAN:
        case CLASS_TYPE_SLAYER_OF_DOMIEL:
        case CLASS_TYPE_SOHEI:
        case CLASS_TYPE_SOLDIER_OF_LIGHT:
        case CLASS_TYPE_UR_PRIEST:
        case CLASS_TYPE_VASSAL:
        case CLASS_TYPE_VIGILANT:
        case CLASS_TYPE_WIZARD:
            return SPELLBOOK_TYPE_PREPARED;
        case CLASS_TYPE_BARD:
        case CLASS_TYPE_BEGUILER:
        case CLASS_TYPE_CELEBRANT_SHARESS:
        case CLASS_TYPE_DREAD_NECROMANCER:
        case CLASS_TYPE_DUSKBLADE:
        case CLASS_TYPE_FAVOURED_SOUL:
        case CLASS_TYPE_HARPER:
        case CLASS_TYPE_HEXBLADE:
        case CLASS_TYPE_JUSTICEWW:
        case CLASS_TYPE_KNIGHT_WEAVE:
        case CLASS_TYPE_SORCERER:
        case CLASS_TYPE_SUBLIME_CHORD:
        case CLASS_TYPE_SUEL_ARCHANAMACH:
        case CLASS_TYPE_WARMAGE:
            return SPELLBOOK_TYPE_SPONTANEOUS;
		// shapechanger HD count as sorcerer for aranea.	
		case CLASS_TYPE_SHAPECHANGER: 
			return SPELLBOOK_TYPE_SPONTANEOUS;
		// Multiple races	
		case CLASS_TYPE_MONSTROUS: 
			return SPELLBOOK_TYPE_SPONTANEOUS;			
		// Gloura as Bard	
		case CLASS_TYPE_FEY: 
			return SPELLBOOK_TYPE_SPONTANEOUS;			
		// Drider as Sorc	
		case CLASS_TYPE_ABERRATION: 
			return SPELLBOOK_TYPE_SPONTANEOUS;			
        //outsider HD count as sorc for raks
        case CLASS_TYPE_OUTSIDER: {
            /// @todo Will eventually need to add a check here to differentiate between races. Not all are sorcerers, just most
            return SPELLBOOK_TYPE_SPONTANEOUS;
        }
    }
    return SPELLBOOK_TYPE_INVALID;
}

int GetAbilityScoreForClass(int nClass, object oPC)
{
    switch(nClass)
    {
        case CLASS_TYPE_BLACKGUARD:
        case CLASS_TYPE_BLIGHTER:
        case CLASS_TYPE_CLERIC:
        case CLASS_TYPE_DRUID:
        case CLASS_TYPE_FIST_OF_ZUOKEN:
        case CLASS_TYPE_HEALER:
        case CLASS_TYPE_JUSTICEWW:
        case CLASS_TYPE_KNIGHT_CHALICE:
        case CLASS_TYPE_KNIGHT_MIDDLECIRCLE:
        case CLASS_TYPE_NENTYAR_HUNTER:
        case CLASS_TYPE_OCULAR:
        case CLASS_TYPE_PALADIN:
        case CLASS_TYPE_PSYWAR:
        case CLASS_TYPE_RANGER:
        case CLASS_TYPE_SHAMAN:
        case CLASS_TYPE_SLAYER_OF_DOMIEL:
        case CLASS_TYPE_SOHEI:
        case CLASS_TYPE_SOLDIER_OF_LIGHT:
        case CLASS_TYPE_UR_PRIEST:
        case CLASS_TYPE_VASSAL:
        case CLASS_TYPE_VIGILANT:
        case CLASS_TYPE_WARMIND:
            return GetAbilityScore(oPC, ABILITY_WISDOM);
        case CLASS_TYPE_ARCHIVIST:
        case CLASS_TYPE_ASSASSIN:
        case CLASS_TYPE_BEGUILER:
        case CLASS_TYPE_CULTIST_SHATTERED_PEAK:
        case CLASS_TYPE_DUSKBLADE:
        case CLASS_TYPE_PSION:
        case CLASS_TYPE_PSYCHIC_ROGUE:
        case CLASS_TYPE_SHADOWCASTER:
        case CLASS_TYPE_SHADOWLORD:
        case CLASS_TYPE_WIZARD:
            return GetAbilityScore(oPC, ABILITY_INTELLIGENCE);
        case CLASS_TYPE_BARD:
        case CLASS_TYPE_CELEBRANT_SHARESS:
        case CLASS_TYPE_DREAD_NECROMANCER:
        case CLASS_TYPE_FAVOURED_SOUL:
        case CLASS_TYPE_HARPER:
        case CLASS_TYPE_HEXBLADE:
        case CLASS_TYPE_KNIGHT_WEAVE:
        case CLASS_TYPE_SORCERER:
        case CLASS_TYPE_SUBLIME_CHORD:
        case CLASS_TYPE_SUEL_ARCHANAMACH:
        case CLASS_TYPE_WARMAGE:
        case CLASS_TYPE_WILDER:
            return GetAbilityScore(oPC, ABILITY_CHARISMA);
        //shapeshifter HD count as sorc for aranea
        case CLASS_TYPE_SHAPECHANGER: 
        	return GetAbilityScore(oPC, ABILITY_CHARISMA);
		// Multiple races	
		case CLASS_TYPE_MONSTROUS: 
			return GetAbilityScore(oPC, ABILITY_CHARISMA);
		// Gloura as Bard	
		case CLASS_TYPE_FEY: 
			return GetAbilityScore(oPC, ABILITY_CHARISMA);
		// Drider as Sorc	
		case CLASS_TYPE_ABERRATION: 
			return GetAbilityScore(oPC, ABILITY_CHARISMA);
        //outsider HD count as sorc for raks
        case CLASS_TYPE_OUTSIDER: {
            /// @todo Will eventually need to add a check here to differentiate between races. Not all are sorcerers, just most
            return GetAbilityScore(oPC, ABILITY_CHARISMA);
        }
    }
    return GetAbilityScore(oPC, ABILITY_CHARISMA);    //default for SLAs?
}

int GetDCAbilityModForClass(int nClass, object oPC)
{
    switch(nClass)
    {
        case CLASS_TYPE_BLACKGUARD:
        case CLASS_TYPE_BLIGHTER:
        case CLASS_TYPE_CLERIC:
        case CLASS_TYPE_DRUID:
        case CLASS_TYPE_FAVOURED_SOUL:
        case CLASS_TYPE_FIST_OF_ZUOKEN:
        case CLASS_TYPE_JUSTICEWW:
        case CLASS_TYPE_KNIGHT_CHALICE:
        case CLASS_TYPE_KNIGHT_MIDDLECIRCLE:
        case CLASS_TYPE_OCULAR:
        case CLASS_TYPE_NENTYAR_HUNTER:
        case CLASS_TYPE_PALADIN:
        case CLASS_TYPE_PSYWAR:
        case CLASS_TYPE_RANGER:
        case CLASS_TYPE_SHAMAN:
        case CLASS_TYPE_SLAYER_OF_DOMIEL:
        case CLASS_TYPE_SOHEI:
        case CLASS_TYPE_SOLDIER_OF_LIGHT:
        case CLASS_TYPE_UR_PRIEST:
        case CLASS_TYPE_VASSAL:
        case CLASS_TYPE_VIGILANT:
        case CLASS_TYPE_WARMIND:
            return GetAbilityModifier(ABILITY_WISDOM, oPC);
        case CLASS_TYPE_ARCHIVIST:
        case CLASS_TYPE_ASSASSIN:
        case CLASS_TYPE_BEGUILER:
        case CLASS_TYPE_CULTIST_SHATTERED_PEAK:
        case CLASS_TYPE_DUSKBLADE:        
        case CLASS_TYPE_PSION:
        case CLASS_TYPE_PSYCHIC_ROGUE:
        case CLASS_TYPE_SHADOWLORD:
        case CLASS_TYPE_WIZARD:
            return GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
        case CLASS_TYPE_BARD:
        case CLASS_TYPE_CELEBRANT_SHARESS:
        case CLASS_TYPE_DREAD_NECROMANCER:
        case CLASS_TYPE_HARPER:
        case CLASS_TYPE_HEALER:
        case CLASS_TYPE_HEXBLADE:
        case CLASS_TYPE_SHADOWCASTER:
        case CLASS_TYPE_SORCERER:
        case CLASS_TYPE_SUBLIME_CHORD:
        case CLASS_TYPE_SUEL_ARCHANAMACH:
        case CLASS_TYPE_WARMAGE:
        case CLASS_TYPE_WILDER:
            return GetAbilityModifier(ABILITY_CHARISMA, oPC);
        //shapechanger HD count as sorc for aranea
        case CLASS_TYPE_SHAPECHANGER: 
        	return GetAbilityScore(oPC, ABILITY_CHARISMA);
		// Multiple races	
		case CLASS_TYPE_MONSTROUS: 
			return GetAbilityScore(oPC, ABILITY_CHARISMA);
		// Gloura as Bard	
		case CLASS_TYPE_FEY: 
			return GetAbilityScore(oPC, ABILITY_CHARISMA);
		// Drider as Sorc	
		case CLASS_TYPE_ABERRATION: 
			return GetAbilityScore(oPC, ABILITY_CHARISMA);		
        //outsider HD count as sorc for raks
        case CLASS_TYPE_OUTSIDER: {
            // @todo Will eventually need to add a check here to differentiate between races. Not all are sorcerers, just most
            return GetAbilityModifier(ABILITY_CHARISMA, oPC);
        }
    }
    return GetAbilityModifier(ABILITY_CHARISMA, oPC);    //default for SLAs?
}

string GetFileForClass(int nClass)
{
    string sFile = Get2DACache("classes", "FeatsTable", nClass);
    sFile = "cls_spell" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061231
    //if(DEBUG) DoDebug("GetFileForClass(" + IntToString(nClass) + ") = " + sFile);
    return sFile;
}

int GetSpellslotLevel(int nClass, object oPC)
{
    int nBaseLevel = GetLevelByClass(nClass, oPC);

    // Custom racial casting
    int nRacialLevel = 0;
    int nRace = GetRacialType(oPC);

    if (nClass == CLASS_TYPE_SORCERER)
    {
        if(nRace == RACIAL_TYPE_RAKSHASA)
            nRacialLevel = GetLevelByClass(CLASS_TYPE_OUTSIDER, oPC);
        else if(nRace == RACIAL_TYPE_ARKAMOI)
            nRacialLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC);
        else if(nRace == RACIAL_TYPE_DRIDER)
            nRacialLevel = GetLevelByClass(CLASS_TYPE_ABERRATION, oPC); 
        else if(nRace == RACIAL_TYPE_REDSPAWN_ARCANISS)
            nRacialLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC) * 3 / 4;
        else if(nRace == RACIAL_TYPE_MARRUTACT)
            nRacialLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC) * 6 / 7;
        else if(nRace == RACIAL_TYPE_HOBGOBLIN_WARSOUL)
            nRacialLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC);
        else if(nRace == RACIAL_TYPE_ARANEA)
            nRacialLevel = GetLevelByClass(CLASS_TYPE_SHAPECHANGER, oPC);
    }
    else if (nClass == CLASS_TYPE_BARD && nRace == RACIAL_TYPE_GLOURA)
    {
        nRacialLevel = GetLevelByClass(CLASS_TYPE_FEY, oPC);
    }

    // Add base and racial class levels
    int nLevel = nBaseLevel + nRacialLevel;

    // Spellcasting PRC progression
    int nArcSpellslotLevel = 0;
    int nDivSpellslotLevel = 0;
    int i;
    for(i = 1; i <= 8; i++)
    {
        int nTempClass = GetClassByPosition(i, oPC);
        int nArcSpellMod = StringToInt(Get2DACache("classes", "ArcSpellLvlMod", nTempClass));
        int nDivSpellMod = StringToInt(Get2DACache("classes", "DivSpellLvlMod", nTempClass));

        if(nArcSpellMod > 0)
            nArcSpellslotLevel += (GetLevelByClass(nTempClass, oPC) + (nArcSpellMod - 1)) / nArcSpellMod;

        if(nDivSpellMod > 0)
            nDivSpellslotLevel += (GetLevelByClass(nTempClass, oPC) + (nDivSpellMod - 1)) / nDivSpellMod;
    }

    // Add PRC spellcasting progression
    if(GetPrimaryArcaneClass(oPC) == nClass)
        nLevel += nArcSpellslotLevel;
    if(GetPrimaryDivineClass(oPC) == nClass)
        nLevel += nDivSpellslotLevel;

    // Ultimate Magus override (only include Sorcerer + UM)
    if (nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_ULTIMATE_MAGUS, oPC))
    {
        nLevel = GetLevelByClass(CLASS_TYPE_ULTIMATE_MAGUS, oPC) + GetLevelByClass(CLASS_TYPE_SORCERER, oPC);
    }

    if(DEBUG) DoDebug("GetSpellslotLevel(" + IntToString(nClass) + ", " + GetName(oPC) + ") = " + IntToString(nLevel));
    return nLevel;
}

/* int GetSpellslotLevel(int nClass, object oPC)
{
    int nLevel = GetLevelByClass(nClass, oPC);
    
//:: Rakshasa cast as sorcerers
    if(nClass == CLASS_TYPE_SORCERER && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_RAKSHASA)
        nLevel = GetLevelByClass(CLASS_TYPE_OUTSIDER, oPC);
	
	if(nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_RAKSHASA)
        nLevel = GetLevelByClass(CLASS_TYPE_OUTSIDER, oPC) + GetLevelByClass(CLASS_TYPE_SORCERER, oPC);

//:: Arkamoi cast as sorcerers	
    else if(nClass == CLASS_TYPE_SORCERER && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_ARKAMOI) 
        nLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC);

	if(nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_ARKAMOI)
        nLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC) + GetLevelByClass(CLASS_TYPE_SORCERER, oPC);
	
//:: Driders cast as sorcerers	
    else if(nClass == CLASS_TYPE_SORCERER && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_DRIDER) 
        nLevel = GetLevelByClass(CLASS_TYPE_ABERRATION, oPC);   

	if(nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_DRIDER)
        nLevel = GetLevelByClass(CLASS_TYPE_ABERRATION, oPC) + GetLevelByClass(CLASS_TYPE_SORCERER, oPC);	

//:: Redspawn Arcaniss cast as 3/4 sorcerers	
    else if(nClass == CLASS_TYPE_SORCERER && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_REDSPAWN_ARCANISS) 
        nLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC)*3/4;  
    
	else if(nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_REDSPAWN_ARCANISS) 
        nLevel = GetLevelByClass(CLASS_TYPE_SORCERER, oPC) + (GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC)*3/4);  
	
//:: Marrutact cast as 6/7 sorcerers		
    else if(nClass == CLASS_TYPE_SORCERER && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_MARRUTACT) 
        nLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC)*6/7;  
	
    else if(nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_MARRUTACT) 
        nLevel = GetLevelByClass(CLASS_TYPE_SORCERER, oPC) + (GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC)*6/7);
	
//:: Hobgoblin Warsouls cast as sorcerers		
    else if(nClass == CLASS_TYPE_SORCERER && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_HOBGOBLIN_WARSOUL) 
        nLevel = GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC); 	

    else if(nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_HOBGOBLIN_WARSOUL) 
        nLevel = GetLevelByClass(CLASS_TYPE_SORCERER, oPC) + GetLevelByClass(CLASS_TYPE_MONSTROUS, oPC); 	
	
//:: Aranea cast as sorcerers		
    else if(nClass == CLASS_TYPE_SORCERER && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_ARANEA)
        nLevel = GetLevelByClass(CLASS_TYPE_SHAPECHANGER, oPC);  
	
    else if(nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_SORCERER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_ARANEA)
        nLevel = GetLevelByClass(CLASS_TYPE_SHAPECHANGER, oPC) + GetLevelByClass(CLASS_TYPE_SORCERER, oPC);
	
//:: Gloura cast as bards        
    else if(nClass == CLASS_TYPE_BARD && !GetLevelByClass(CLASS_TYPE_BARD, oPC) && GetRacialType(oPC) == RACIAL_TYPE_GLOURA) 
        nLevel = GetLevelByClass(CLASS_TYPE_FEY, oPC);    

    else if(nClass == CLASS_TYPE_BARD && GetLevelByClass(CLASS_TYPE_BARD, oPC) && GetRacialType(oPC) == RACIAL_TYPE_GLOURA) 
	{
		nLevel = GetLevelByClass(CLASS_TYPE_FEY, oPC) + GetLevelByClass(CLASS_TYPE_BARD, oPC); 		
	}
    
    int nArcSpellslotLevel;
    int nDivSpellslotLevel;
    int i;
    for(i = 1; i <= 8; i++)
    {
        int nTempClass = GetClassByPosition(i, oPC);
        //spellcasting prc
        int nArcSpellMod = StringToInt(Get2DACache("classes", "ArcSpellLvlMod", nTempClass));
        int nDivSpellMod = StringToInt(Get2DACache("classes", "DivSpellLvlMod", nTempClass));
        //special case for combat medic class
        //if(nTempClass == CLASS_TYPE_COMBAT_MEDIC && (nClass == CLASS_TYPE_BARD || nClass == CLASS_TYPE_WITCH))
        //    nArcSpellMod = 1;

        if(nArcSpellMod == 1)
            nArcSpellslotLevel += GetLevelByClass(nTempClass, oPC);
        else if(nArcSpellMod > 1)
            nArcSpellslotLevel += (GetLevelByClass(nTempClass, oPC) + 1) / nArcSpellMod;
        if(nDivSpellMod == 1)
            nDivSpellslotLevel += GetLevelByClass(nTempClass, oPC);
        else if(nDivSpellMod > 1)
            nDivSpellslotLevel += (GetLevelByClass(nTempClass, oPC) + 1) / nDivSpellMod;
    }
    
    if(GetPrimaryArcaneClass(oPC) == nClass)
        nLevel += nArcSpellslotLevel;
    if(GetPrimaryDivineClass(oPC) == nClass)
        nLevel += nDivSpellslotLevel;
        
    // For this special instance, we know that this is the only prestige class
    if (nClass == CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_ULTIMATE_MAGUS, oPC))
    	nLevel = GetLevelByClass(CLASS_TYPE_ULTIMATE_MAGUS, oPC) + GetLevelByClass(CLASS_TYPE_SORCERER, oPC);
    	
    if(DEBUG) DoDebug("GetSpellslotLevel(" + IntToString(nClass) + ", " + GetName(oPC) + ") = " + IntToString(nLevel));
    return nLevel;
}
 */

int GetItemBonusSlotCount(object oPC, int nClass, int nSpellLevel)
{
    // Value maintained by CheckPRCLimitations()
    return GetLocalInt(oPC, "PRC_IPRPBonSpellSlots_" + IntToString(nClass) + "_" + IntToString(nSpellLevel));
}

int GetSlotCount(int nLevel, int nSpellLevel, int nAbilityScore, int nClass, object oItemPosessor = OBJECT_INVALID)
{
    // Ability score limit rule: Must have casting ability score of at least 10 + spel level to be able to cast spells of that level at all
    if(nAbilityScore < nSpellLevel + 10)
        return 0;
    int nSlots;
    string sFile;
    /*// Bioware casters use their classes.2da-specified tables
    if(    nClass == CLASS_TYPE_WIZARD
        || nClass == CLASS_TYPE_SORCERER
        || nClass == CLASS_TYPE_BARD
        || nClass == CLASS_TYPE_CLERIC
        || nClass == CLASS_TYPE_DRUID
        || nClass == CLASS_TYPE_PALADIN
        || nClass == CLASS_TYPE_RANGER)
    {*/
        sFile = Get2DACache("classes", "SpellGainTable", nClass);
    /*}
    // New spellbook casters use the cls_spbk_* tables
    else
    {
        sFile = Get2DACache("classes", "FeatsTable", nClass);
        sFile = "cls_spbk" + GetStringRight(sFile, GetStringLength(sFile) - 8); // Hardcoded the cls_ part. It's not as if any class uses some other prefix - Ornedan, 20061231
    }*/

    string sSlots = Get2DACache(sFile, "SpellLevel" + IntToString(nSpellLevel), nLevel - 1);
    if(sSlots == "")
    {
        nSlots = -1;
        //if(DEBUG) DoDebug("GetSlotCount: Problem getting slot numbers for " + IntToString(nSpellLevel) + " " + IntToString(nLevel) + " " + sFile);
    }
    else
        nSlots = StringToInt(sSlots);
    if(nSlots == -1)
        return 0;

    // Add spell slots from items
    if(GetIsObjectValid(oItemPosessor))
        nSlots += GetItemBonusSlotCount(oItemPosessor, nClass, nSpellLevel);

    // Add spell slots from high ability score. Level 0 spells are exempt
    if(nSpellLevel == 0)
        return nSlots;
    else 
    {
        int nAbilityMod = nClass == CLASS_TYPE_ARCHIVIST ? GetAbilityModifier(ABILITY_WISDOM, oItemPosessor) : (nAbilityScore - 10) / 2;
        if(nAbilityMod >= nSpellLevel) // Need an ability modifier at least equal to the spell level to gain bonus slots
            nSlots += ((nAbilityMod - nSpellLevel) / 4) + 1;
        return nSlots;
    }
}

//if the class doesn't learn all available spells on level-up add it here
int bKnowsAllClassSpells(int nClass)
{
    switch(nClass)
    {
        //case CLASS_TYPE_WIZARD:
        case CLASS_TYPE_ARCHIVIST:
        //case CLASS_TYPE_ASSASSIN:
        case CLASS_TYPE_BARD:
        case CLASS_TYPE_CELEBRANT_SHARESS:
        case CLASS_TYPE_CULTIST_SHATTERED_PEAK:
        case CLASS_TYPE_DUSKBLADE:
        case CLASS_TYPE_FAVOURED_SOUL:
        case CLASS_TYPE_HEXBLADE:
        case CLASS_TYPE_JUSTICEWW:
        case CLASS_TYPE_KNIGHT_WEAVE:
        case CLASS_TYPE_SORCERER:
        case CLASS_TYPE_SUBLIME_CHORD:
        case CLASS_TYPE_SUEL_ARCHANAMACH:
            return FALSE;

        // Everyone else
        default:
            return TRUE;
    }
    return TRUE;
}


int GetSpellKnownMaxCount(int nLevel, int nSpellLevel, int nClass, object oPC)
{
    // If the character doesn't have any spell slots available on for this level, it can't know any spells of that level either
    if(!GetSlotCount(nLevel, nSpellLevel, GetAbilityScoreForClass(nClass, oPC), nClass))
    {
        if(DEBUG) DoDebug("GetSpellKnownMaxCount: No slots available for " + IntToString(nClass) + " level " + IntToString(nLevel) + " circle " + IntToString(nSpellLevel));
        return 0;
    }
    
    int nKnown;
    string sFile = Get2DACache("classes", "SpellKnownTable", nClass);
    string sKnown = Get2DACache(sFile, "SpellLevel" + IntToString(nSpellLevel), nLevel - 1);
    
    if(DEBUG) 
    {
        DoDebug("GetSpellKnownMaxCount Details:");
        DoDebug("- Class: " + IntToString(nClass));
        DoDebug("- Passed Level: " + IntToString(nLevel));
        DoDebug("- Base Class Level: " + IntToString(GetLevelByClass(nClass, oPC)));
        DoDebug("- Effective Level: " + IntToString(GetSpellslotLevel(nClass, oPC)));
        DoDebug("- Spell Level: " + IntToString(nSpellLevel));
        DoDebug("- SpellKnownTable: " + sFile);
        DoDebug("- MaxKnown from 2DA: " + sKnown);
    }
    
    if(sKnown == "")
    {
        nKnown = -1;
        if(DEBUG) DoDebug("GetSpellKnownMaxCount: Problem getting known numbers");
    }
    else
        nKnown = StringToInt(sKnown);
    
    if(nKnown == -1)
        return 0;

    // COMPLETELY REWROTE THIS SECTION
    // Bard and Sorcerer logic for prestige class advancement
    if(nClass == CLASS_TYPE_SORCERER || nClass == CLASS_TYPE_BARD)
    {
        int baseClassLevel = GetLevelByClass(nClass, oPC);
        int effectiveLevel = GetSpellslotLevel(nClass, oPC);
        
        // Debug the values we're checking
        if(DEBUG)
        {
            DoDebug("Spont caster check - Base level: " + IntToString(baseClassLevel) + 
                   ", Effective level: " + IntToString(effectiveLevel));
        }
        
        // If they have prestige class advancement OR special feats, they should get spells
        if(effectiveLevel > baseClassLevel || 
           GetHasFeat(FEAT_DRACONIC_GRACE, oPC) || 
           GetHasFeat(FEAT_DRACONIC_BREATH, oPC))
        {
            // Allow them to get spells - do nothing here, return nKnown at the end
            if(DEBUG) DoDebug("Spontaneous caster eligible for new spells");
        }
        else
        {
            // No advancement, no special feats - no new spells
            if(DEBUG) DoDebug("Spontaneous caster NOT eligible for new spells");
            return 0;
        }
    }
    
    if(DEBUG) DoDebug("Final spell known count: " + IntToString(nKnown));
    return nKnown;
}


/* int GetSpellKnownMaxCount(int nLevel, int nSpellLevel, int nClass, object oPC)
{
    // If the character doesn't have any spell slots available on for this level, it can't know any spells of that level either
    // @todo Check rules. There might be cases where this doesn't hold
    if(!GetSlotCount(nLevel, nSpellLevel, GetAbilityScoreForClass(nClass, oPC), nClass))
        return 0;
    int nKnown;
    string sFile;

	sFile = Get2DACache("classes", "SpellKnownTable", nClass);


    string sKnown = Get2DACache(sFile, "SpellLevel" + IntToString(nSpellLevel), nLevel - 1);
    if(DEBUG) DoDebug("GetSpellKnownMaxCount(" + IntToString(nLevel) + ", " + IntToString(nSpellLevel) + ", " + IntToString(nClass) + ", " + GetName(oPC) + ") = " + sKnown);
    if(sKnown == "")
    {
        nKnown = -1;
        //if(DEBUG) DoDebug("GetSpellKnownMaxCount: Problem getting known numbers for " + IntToString(nSpellLevel) + " " + IntToString(nLevel) + " " + sFile);
    }
    else
        nKnown = StringToInt(sKnown);
    if(nKnown == -1)
        return 0;

    // Bard and Sorcerer only have new spellbook spells known if they have taken prestige classes that increase spellcasting
    if(nClass == CLASS_TYPE_SORCERER || nClass == CLASS_TYPE_BARD)
    {
        if((GetLevelByClass(nClass) == nLevel) //no PrC
          && !(GetHasFeat(FEAT_DRACONIC_GRACE, oPC) || GetHasFeat(FEAT_DRACONIC_BREATH, oPC))) //no Draconic feats that apply
            return 0;
    }
    return nKnown;
}
 */

int GetSpellKnownCurrentCount(object oPC, int nSpellLevel, int nClass)
{
    // Check short-term cache
    string sClassNum = IntToString(nClass);
    if(GetLocalInt(oPC, "GetSKCCCache_" + IntToString(nSpellLevel) + "_" + sClassNum))
        return GetLocalInt(oPC, "GetSKCCCache_" + IntToString(nSpellLevel) + "_" + sClassNum) - 1;

    // Loop over all spells known and count the number of spells of each level known
    int i;
    int nKnown;
    int nKnown0, nKnown1, nKnown2, nKnown3, nKnown4;
    int nKnown5, nKnown6, nKnown7, nKnown8, nKnown9;
    string sFile = GetFileForClass(nClass);
    for(i = 0; i < persistant_array_get_size(oPC, "Spellbook" + sClassNum); i++)
    {
        int nNewSpellbookID = persistant_array_get_int(oPC, "Spellbook" + sClassNum, i);
        int nLevel = StringToInt(Get2DACache(sFile, "Level", nNewSpellbookID));
        switch(nLevel)
        {
            case 0: nKnown0++; break; case 1: nKnown1++; break;
            case 2: nKnown2++; break; case 3: nKnown3++; break;
            case 4: nKnown4++; break; case 5: nKnown5++; break;
            case 6: nKnown6++; break; case 7: nKnown7++; break;
            case 8: nKnown8++; break; case 9: nKnown9++; break;
        }
    }

    // Pick the level requested for returning
    switch(nSpellLevel)
    {
        case 0: nKnown = nKnown0; break; case 1: nKnown = nKnown1; break;
        case 2: nKnown = nKnown2; break; case 3: nKnown = nKnown3; break;
        case 4: nKnown = nKnown4; break; case 5: nKnown = nKnown5; break;
        case 6: nKnown = nKnown6; break; case 7: nKnown = nKnown7; break;
        case 8: nKnown = nKnown8; break; case 9: nKnown = nKnown9; break;
    }
    if(DEBUG) DoDebug("GetSpellKnownCurrentCount(" + GetName(oPC) + ", " + IntToString(nSpellLevel) + ", " + sClassNum + ") = " + IntToString(nKnown));
    if(DEBUG) DoDebug("GetSpellKnownCurrentCount(i " + IntToString(i) + ", nKnown0 " + IntToString(nKnown0) + ", nKnown1 " + IntToString(nKnown1) + ", nKnown2 " + IntToString(nKnown2) + ", nKnown3 " + IntToString(nKnown3) + ", nKnown4 " + IntToString(nKnown4) + ", nKnown5 " + IntToString(nKnown5) + ", nKnown6 " + IntToString(nKnown6) + ", nKnown7 " + IntToString(nKnown7) + ", nKnown8 " + IntToString(nKnown8) + ", nKnown9 " + IntToString(nKnown9));
    if(DEBUG) DoDebug("GetSpellKnownCurrentCount(persistant_array_get_size "+IntToString(persistant_array_get_size(oPC, "Spellbook" + sClassNum)));

    // Cache the values for 1 second
    SetLocalInt(oPC, "GetSKCCCache_0_" + sClassNum, nKnown0 + 1);
    SetLocalInt(oPC, "GetSKCCCache_1_" + sClassNum, nKnown1 + 1);
    SetLocalInt(oPC, "GetSKCCCache_2_" + sClassNum, nKnown2 + 1);
    SetLocalInt(oPC, "GetSKCCCache_3_" + sClassNum, nKnown3 + 1);
    SetLocalInt(oPC, "GetSKCCCache_4_" + sClassNum, nKnown4 + 1);
    SetLocalInt(oPC, "GetSKCCCache_5_" + sClassNum, nKnown5 + 1);
    SetLocalInt(oPC, "GetSKCCCache_6_" + sClassNum, nKnown6 + 1);
    SetLocalInt(oPC, "GetSKCCCache_7_" + sClassNum, nKnown7 + 1);
    SetLocalInt(oPC, "GetSKCCCache_8_" + sClassNum, nKnown8 + 1);
    SetLocalInt(oPC, "GetSKCCCache_9_" + sClassNum, nKnown9 + 1);
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_0_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_1_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_2_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_3_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_4_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_5_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_6_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_7_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_8_" + sClassNum));
    DelayCommand(1.0, DeleteLocalInt(oPC, "GetSKCCCache_9_" + sClassNum));

    return nKnown;
}

int GetSpellUnknownCurrentCount(object oPC, int nSpellLevel, int nClass)
{
    // Get the lookup token created by MakeSpellbookLevelLoop()
    string sTag = "SpellLvl_" + IntToString(nClass) + "_Level_" + IntToString(nSpellLevel);
    object oCache = GetObjectByTag(sTag);
    if(!GetIsObjectValid(oCache))
    {
        if(DEBUG) DoDebug("GetSpellUnknownCurrentCount: " + sTag + " is not valid");
        
        // Add code to create the missing lookup object
        if(DEBUG) DoDebug("Attempting to create missing spell lookup token");
        ExecuteScript("prc_create_spellb", oPC);
        
        // Try again after creating it
        oCache = GetObjectByTag(sTag);
        if(!GetIsObjectValid(oCache))
        {
            if(DEBUG) DoDebug("Still couldn't create spell lookup token");
            return 0;
        }
        else
        {
            if(DEBUG) DoDebug("Successfully created spell lookup token");
        }
    }
    
    // Read the total number of spells on the given level and determine how many are already known
    int nTotal = array_get_size(oCache, "Lkup");
    int nKnown = GetSpellKnownCurrentCount(oPC, nSpellLevel, nClass);
    int nUnknown = nTotal - nKnown;

    if(DEBUG) DoDebug("GetSpellUnknownCurrentCount(" + GetName(oPC) + ", " + IntToString(nSpellLevel) + ", " + IntToString(nClass) + ") = " + IntToString(nUnknown));
    if(DEBUG) DoDebug("  Total spells in lookup: " + IntToString(nTotal) + ", Known spells: " + IntToString(nKnown));
    
    return nUnknown;
}


/* int GetSpellUnknownCurrentCount(object oPC, int nSpellLevel, int nClass)
{
    // Get the lookup token created by MakeSpellbookLevelLoop()
    string sTag = "SpellLvl_" + IntToString(nClass) + "_Level_" + IntToString(nSpellLevel);
    object oCache = GetObjectByTag(sTag);
    if(!GetIsObjectValid(oCache))
    {
        if(DEBUG) DoDebug("GetSpellUnknownCurrentCount: " + sTag + " is not valid");
        return 0;
    }
    // Read the total number of spells on the given level and determine how many are already known
    int nTotal = array_get_size(oCache, "Lkup");
    int nKnown = GetSpellKnownCurrentCount(oPC, nSpellLevel, nClass);
    int nUnknown = nTotal - nKnown;

    if(DEBUG) DoDebug("GetSpellUnknownCurrentCount(" + GetName(oPC) + ", " + IntToString(nSpellLevel) + ", " + IntToString(nClass) + ") = " + IntToString(nUnknown));
    return nUnknown;
} */

void AddSpellUse(object oPC, int nSpellbookID, int nClass, string sFile, string sArrayName, int nSpellbookType, object oSkin, int nFeatID, int nIPFeatID, string sIDX = "")
{
    /*
    string sFile = GetFileForClass(nClass);
    string sArrayName = "NewSpellbookMem_"+IntToString(nClass);
    int nSpellbookType = GetSpellbookTypeForClass(nClass);
    object oSkin = GetPCSkin(oPC);
    int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));
    //add the feat only if they dont already have it
    int nIPFeatID = StringToInt(Get2DACache(sFile, "IPFeatID", nSpellbookID));
    */
    object oToken = GetHideToken(oPC);

    // Add the spell use feats and set a marker local that tells for CheckAndRemoveFeat() to skip removing this feat
    string sIPFeatID = IntToString(nIPFeatID);
    SetLocalInt(oSkin, "NewSpellbookTemp_" + sIPFeatID, TRUE);
    AddSkinFeat(nFeatID, nIPFeatID, oSkin, oPC);

    // Increase the current number of uses
    if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
    {
        //sanity test
        if(!persistant_array_exists(oPC, sArrayName))
        {
            if(DEBUG) DoDebug("ERROR: AddSpellUse: " + sArrayName + " array does not exist, creating");
            persistant_array_create(oPC, sArrayName);
        }

        int nUses = persistant_array_get_int(oPC, sArrayName, nSpellbookID);
        nUses++;
        persistant_array_set_int(oPC, sArrayName, nSpellbookID, nUses);
        if(DEBUG) DoDebug("AddSpellUse: " + sArrayName + "[" + IntToString(nSpellbookID) + "] = " + IntToString(array_get_int(oPC, sArrayName, nSpellbookID)));

        //Create index array - to avoid duplicates mark only 1st use of nSpellbookID
        if(nUses == 1)
        {
            if(!persistant_array_exists(oPC, sIDX))
                persistant_array_create(oPC, sIDX);

            persistant_array_set_int(oPC, sIDX, array_get_size(oPC, sIDX), nSpellbookID);
        }
    }
    else if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
    {
        //sanity test
        if(!persistant_array_exists(oPC, sArrayName))
        {
            if(DEBUG) DoDebug("ERROR: AddSpellUse: " + sArrayName + " array does not exist, creating");
            persistant_array_create(oPC, sArrayName);
        }
        /*int nSpellLevel = StringToInt(Get2DACache(sFile, "Level", nSpellbookID));
        int nCount = persistant_array_get_int(oPC, sArrayName, nSpellLevel);
        if(nCount < 1)
        {
            int nLevel = GetSpellslotLevel(nClass, oPC);
            int nAbility = GetAbilityScoreForClass(nClass, oPC);
            nCount = GetSlotCount(nLevel, nSpellLevel, nAbility, nClass, oPC);
            array_set_int(oPC, sArrayName, nSpellLevel, nCount);
        }*/
        if(DEBUG) DoDebug("AddSpellUse() called on spontaneous spellbook. nIPFeatID = " + sIPFeatID);
    }
}

void RemoveSpellUse(object oPC, int nSpellID, int nClass)
{
    string sFile = GetFileForClass(nClass);
    int nSpellbookID = SpellToSpellbookID(nSpellID);
    if(nSpellbookID == -1)
    {
        if(DEBUG) DoDebug("ERROR: RemoveSpellUse: Unable to resolve spell to spellbookID: " + IntToString(nSpellID) + " in file " + sFile);
        return;
    }
    if(!persistant_array_exists(oPC, "NewSpellbookMem_"+IntToString(nClass)))
    {
        if(DEBUG) DoDebug("RemoveSpellUse: NewSpellbookMem_" + IntToString(nClass) + " does not exist, creating.");
        persistant_array_create(oPC, "NewSpellbookMem_"+IntToString(nClass));
    }

    // Reduce the remaining uses of the given spell by 1 (except never reduce uses below 0).
    // Spontaneous spellbooks reduce the number of spells of the spell's level remaining
    int nSpellbookType = GetSpellbookTypeForClass(nClass);
    if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
    {
        int nCount = persistant_array_get_int(oPC, "NewSpellbookMem_" + IntToString(nClass), nSpellbookID);
        if(nCount > 0)
            persistant_array_set_int(oPC, "NewSpellbookMem_" + IntToString(nClass), nSpellbookID, nCount - 1);
    }
    else if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
    {
        int nSpellLevel = StringToInt(Get2DACache(sFile, "Level", nSpellbookID));
        int nCount = persistant_array_get_int(oPC, "NewSpellbookMem_" + IntToString(nClass), nSpellLevel);
        if(nCount > 0)
            persistant_array_set_int(oPC, "NewSpellbookMem_" + IntToString(nClass), nSpellLevel, nCount - 1);
    }
}

int GetSpellLevel(int nSpellID, int nClass)
{
    string sFile = GetFileForClass(nClass);
    int nSpellbookID = SpellToSpellbookID(nSpellID);
    if(nSpellbookID == -1)
    {
        if(DEBUG) DoDebug("ERROR: GetSpellLevel: Unable to resolve spell to spellbookID: "+IntToString(nSpellID)+" "+sFile);
        return -1;
    }

    // get spell level
    int nSpellLevel = -1;
    string sSpellLevel = Get2DACache(sFile, "Level", nSpellbookID);

    if (sSpellLevel != "")
        nSpellLevel = StringToInt(sSpellLevel);

    return nSpellLevel;
}

//called inside for loop in SetupSpells(), delayed to prevent TMI
void SpontaneousSpellSetupLoop(object oPC, int nClass, string sFile, object oSkin, int i)
{
    int nSpellbookID = persistant_array_get_int(oPC, "Spellbook" + IntToString(nClass), i);
    string sIPFeatID = Get2DACache(sFile, "IPFeatID", nSpellbookID);
    int nIPFeatID = StringToInt(sIPFeatID);
    int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));
    //int nRealSpellID = StringToInt(Get2DACache(sFile, "RealSpellID", nSpellbookID));
    SetLocalInt(oSkin, "NewSpellbookTemp_" + sIPFeatID, TRUE);

    AddSkinFeat(nFeatID, nIPFeatID, oSkin, oPC);
}

void SetupSpells(object oPC, int nClass)
{
    string sFile = GetFileForClass(nClass);
    string sClass = IntToString(nClass);
    string sArrayName = "NewSpellbookMem_" + sClass;
    object oSkin = GetPCSkin(oPC);
    int nLevel = GetSpellslotLevel(nClass, oPC);
    int nAbility = GetAbilityScoreForClass(nClass, oPC);
    int nSpellbookType = GetSpellbookTypeForClass(nClass);
    
        if(DEBUG) DoDebug("SetupSpells()\n"
                        + "nClass = " + IntToString(nClass) + "\n"
                        + "nSpellslotLevel = " + IntToString(nLevel) + "\n"
                        + "nAbility = " + IntToString(nAbility) + "\n"
                        + "nSpellbookType = " + IntToString(nSpellbookType) + "\n"
                        + "sFile = " + sFile + "\n"
                          );    

    // For spontaneous spellbooks, set up an array that tells how many spells of each level they can cast
    // And add casting feats for each spell known to the caster's hide
    if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)  //:: Fixed by TiredByFirelight
    {
        // Spell slots
        int nSpellLevel, nSlots;
        for(nSpellLevel = 0; nSpellLevel <= 9; nSpellLevel++)
        {
            nSlots = GetSlotCount(nLevel, nSpellLevel, nAbility, nClass, oPC);
            persistant_array_set_int(oPC, sArrayName, nSpellLevel, nSlots);
        }

        int i;
        for(i = 0; i < persistant_array_get_size(oPC, "Spellbook" + sClass); i++)
        {   //adding feats
            SpontaneousSpellSetupLoop(oPC, nClass, sFile, oSkin, i);
        }
    }// end if - Spontaneous spellbook

    // For prepared spellbooks, add spell uses and use feats according to spells memorised list
    else if(nSpellbookType == SPELLBOOK_TYPE_PREPARED && !GetIsBioSpellCastClass(nClass))
    {
        int nSpellLevel, nSlot, nSlots, nSpellbookID;
        string sArrayName2, sIDX;

        // clearing existing spells 
		persistant_array_delete(oPC, sArrayName);

        for(nSpellLevel = 0; nSpellLevel <= 9; nSpellLevel++)
        {
			//Delay of 0.01, to ensure it runs after persistant_array_delete() which is a lot of 0.0 delay commands, but before other spellbook stuff
			DelayCommand(0.01, ProcessPreparedSpellLevel(oPC, nClass, nSpellLevel, nLevel, nAbility, sClass, sFile, sArrayName, nSpellbookType, oSkin));
        }		
    }
}

/*     if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
    {
        // Spell slots
        int nSpellLevel, nSlots;
        for(nSpellLevel = 0; nSpellLevel <= 9; nSpellLevel++)
        {
            nSlots = GetSlotCount(nLevel, nSpellLevel, nAbility, nClass, oPC);
            persistant_array_set_int(oPC, sArrayName, nSpellLevel, nSlots);
        }

        int i;
        for(i = 0; i < persistant_array_get_size(oPC, "Spellbook" + sClass); i++)
        {   //adding feats
            SpontaneousSpellSetupLoop(oPC, nClass, sFile, oSkin, i);
        }
    }// end if - Spontaneous spellbook

    // For prepared spellbooks, add spell uses and use feats according to spells memorised list
    else if(nSpellbookType == SPELLBOOK_TYPE_PREPARED && !GetIsBioSpellCastClass(nClass))
    {
        int nSpellLevel, nSlot, nSlots, nSpellbookID;
        string sArrayName2, sIDX;

        // clearing existing spells 
        int i;
        for(i = 0; i < persistant_array_get_size(oPC, sArrayName); i++)
        {
            persistant_array_set_int(oPC, sArrayName, i, 0);
        }

        for(nSpellLevel = 0; nSpellLevel <= 9; nSpellLevel++)
        {
            sArrayName2 = "Spellbook" + IntToString(nSpellLevel) + "_" + sClass; // Minor optimisation: cache the array name string for multiple uses
            sIDX = "SpellbookIDX" + IntToString(nSpellLevel) + "_" + sClass;
            nSlots = GetSlotCount(nLevel, nSpellLevel, nAbility, nClass, oPC);
            nSlot;
            for(nSlot = 0; nSlot < nSlots; nSlot++)
            {
                //done when spells are added to it
                nSpellbookID = persistant_array_get_int(oPC, sArrayName2, nSlot);
                if(nSpellbookID != 0)
                {
                    AddSpellUse(oPC, nSpellbookID, nClass, sFile, sArrayName, nSpellbookType, oSkin,
                        StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID)),
                        StringToInt(Get2DACache(sFile, "IPFeatID", nSpellbookID)),
                        sIDX);
                }
            }
        }
    }
} */

void ProcessPreparedSpellLevel(object oPC, int nClass, int nSpellLevel, int nLevel, int nAbility, string sClass, string sFile, string sArrayName, int nSpellbookType, object oSkin)
{
    string sArrayName2 = "Spellbook" + IntToString(nSpellLevel) + "_" + sClass;
    string sIDX = "SpellbookIDX" + IntToString(nSpellLevel) + "_" + sClass;
    int nSlots = GetSlotCount(nLevel, nSpellLevel, nAbility, nClass, oPC);
    int nSlot;
    for(nSlot = 0; nSlot < nSlots; nSlot++)
    {
        int nSpellbookID = persistant_array_get_int(oPC, sArrayName2, nSlot);
        if(nSpellbookID != 0)
        {
            AddSpellUse(oPC, nSpellbookID, nClass, sFile, sArrayName, nSpellbookType, oSkin,
                        StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID)),
                        StringToInt(Get2DACache(sFile, "IPFeatID", nSpellbookID)),
                        sIDX);
        }
    }
}


void CheckAndRemoveFeat(object oHide, itemproperty ipFeat)
{
    int nSubType = GetItemPropertySubType(ipFeat);
    if(!GetLocalInt(oHide, "NewSpellbookTemp_" + IntToString(nSubType)))
    {
        RemoveItemProperty(oHide, ipFeat);
        DeleteLocalInt(oHide, "NewSpellbookTemp_" + IntToString(nSubType));
        if(DEBUG) DoDebug("CheckAndRemoveFeat: DeleteLocalInt(oHide, NewSpellbookTemp_" + IntToString(nSubType) + ");");
        if(DEBUG) DoDebug("CheckAndRemoveFeat: Removing item property");
    }
    else
    {
        DeleteLocalInt(oHide, "NewSpellbookTemp_" + IntToString(nSubType));
        if(DEBUG) DoDebug("CheckAndRemoveFeat: DeleteLocalInt(oHide, NewSpellbookTemp_" + IntToString(nSubType) + ");");
    }
}

void WipeSpellbookHideFeats(object oPC)
{
    object oHide = GetPCSkin(oPC);
    itemproperty ipTest = GetFirstItemProperty(oHide);
    while(GetIsItemPropertyValid(ipTest))
    {
        int nSubType = GetItemPropertySubType(ipTest);
        if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_FEAT &&
              ((nSubType > SPELLBOOK_IPRP_FEATS_START && nSubType < SPELLBOOK_IPRP_FEATS_END) ||
               (nSubType > SPELLBOOK_IPRP_FEATS_START2 && nSubType < SPELLBOOK_IPRP_FEATS_END2))
          )
        {
            DelayCommand(1.0f, CheckAndRemoveFeat(oHide, ipTest));
        }
        ipTest = GetNextItemProperty(oHide);
    }
}

void CheckNewSpellbooks(object oPC)
{
    WipeSpellbookHideFeats(oPC);
    int i;
    for(i = 1; i <= 8; i++)
    {
        int nClass = GetClassByPosition(i, oPC);
        int nLevel = GetLevelByClass(nClass, oPC);

        if(DEBUG) DoDebug("CheckNewSpellbooks\n"
                        + "nClass = " + IntToString(nClass) + "\n"
                        + "nLevel = " + IntToString(nLevel) + "\n"
                          );
        //if bard/sorc newspellbook is disabled after selecting
        //remove those from radial
        if(   (GetPRCSwitch(PRC_BARD_DISALLOW_NEWSPELLBOOK) && nClass == CLASS_TYPE_BARD)
            ||(GetPRCSwitch(PRC_SORC_DISALLOW_NEWSPELLBOOK) && nClass == CLASS_TYPE_SORCERER))
        {
            //do nothing
        }
        else if(nLevel)
        {
			//Aranea cast as sorcs
            if(nClass == CLASS_TYPE_SHAPECHANGER
                && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
                && GetRacialType(oPC) == RACIAL_TYPE_ARANEA)
                nClass = CLASS_TYPE_SORCERER;
            //raks cast as sorcs
            if(nClass == CLASS_TYPE_OUTSIDER
                && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
                && GetRacialType(oPC) == RACIAL_TYPE_RAKSHASA)
                nClass = CLASS_TYPE_SORCERER;
                
            //Arkamoi cast as sorcs
            if(nClass == CLASS_TYPE_MONSTROUS
                && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
                && GetRacialType(oPC) == RACIAL_TYPE_ARKAMOI)                
                nClass = CLASS_TYPE_SORCERER;
                
            //Hobgoblin Warsouls cast as sorcs
            if(nClass == CLASS_TYPE_MONSTROUS
                && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
                && GetRacialType(oPC) == RACIAL_TYPE_HOBGOBLIN_WARSOUL)                
                nClass = CLASS_TYPE_SORCERER;                
                
            //Redspawn cast as sorcs
            if(nClass == CLASS_TYPE_MONSTROUS
                && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
                && GetRacialType(oPC) == RACIAL_TYPE_REDSPAWN_ARCANISS)                
                nClass = CLASS_TYPE_SORCERER;    
                
            //Marrutact cast as sorcs
            if(nClass == CLASS_TYPE_MONSTROUS
                && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
                && GetRacialType(oPC) == RACIAL_TYPE_MARRUTACT)                
                nClass = CLASS_TYPE_SORCERER;                 
                
            //Driders cast as sorcs
            if(nClass == CLASS_TYPE_ABERRATION
                && !GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
                && GetRacialType(oPC) == RACIAL_TYPE_DRIDER)                
                nClass = CLASS_TYPE_SORCERER;    
                
            //Gloura cast as bards
            if(nClass == CLASS_TYPE_FEY
                && !GetLevelByClass(CLASS_TYPE_BARD, oPC)
                && GetRacialType(oPC) == RACIAL_TYPE_GLOURA)                
                nClass = CLASS_TYPE_BARD;                  
            //remove persistant locals used to track when all spells cast
            string sArrayName = "NewSpellbookMem_"+IntToString(nClass);
            if(persistant_array_exists(oPC, sArrayName))
            {
                if(GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_PREPARED)
                {
                    int nSpellLevel, i, Max;
                    string sIDX, sSpellbookID, sClass = IntToString(nClass);
                    for(nSpellLevel = 0; nSpellLevel <= 9; nSpellLevel++)
                    {
                        sIDX = "SpellbookIDX" + IntToString(nSpellLevel) + "_" + sClass;
                        Max = persistant_array_get_size(oPC, sIDX);
                        for(i = 0; i < Max; i++)
                        {
                            sSpellbookID = persistant_array_get_string(oPC, sIDX, i);
                            if(sSpellbookID != "")
                            {
                                DeletePersistantLocalString(oPC, sArrayName+"_"+sSpellbookID);
                            }
                        }
                        persistant_array_delete(oPC, sIDX);
                    }
                }
                else
                {
                    persistant_array_delete(oPC, sArrayName);
                    persistant_array_create(oPC, sArrayName);
                }
            }
            //delay it so wipespellbookhidefeats has time to start to run
            //but before the deletes actually happen
            DelayCommand(0.1, SetupSpells(oPC, nClass));
        }
    }
}

//NewSpellbookSpell() helper functions
int bTargetingAllowed(int nSpellID);
void CheckPrepSlots(int nClass, int nSpellID, int nSpellbookID, int bIsAction = FALSE);
void CheckSpontSlots(int nClass, int nSpellID, int nSpellSlotLevel, int bIsAction = FALSE);
void DoCleanUp(int nMetamagic);

void CastSpontaneousSpell(int nClass, int bInstantSpell = FALSE)
{
    //get the spellbook ID
    int nFakeSpellID = GetSpellId();
    int nSpellID = GetPowerFromSpellID(nFakeSpellID);
    if(nSpellID == -1) nSpellID = 0;

    //Check the target first
    if(!bTargetingAllowed(nSpellID))
        return;

    // if OBJECT_SELF is fighting - stop fighting and cast spell
    if(GetCurrentAction() == ACTION_ATTACKOBJECT)
        ClearAllActions();

    //if its a subradial spell, get the master
    int nMasterFakeSpellID = StringToInt(Get2DACache("spells", "Master", nFakeSpellID));
    if(!nMasterFakeSpellID)
        nMasterFakeSpellID = nFakeSpellID;

    int nSpellbookID = SpellToSpellbookID(nMasterFakeSpellID);

    // Paranoia - It should not be possible to get here without having the spells available array existing
    if(!persistant_array_exists(OBJECT_SELF, "NewSpellbookMem_" + IntToString(nClass)))
    {
        if(DEBUG) DoDebug("ERROR: NewSpellbookSpell: NewSpellbookMem_" + IntToString(nClass) + " array does not exist");
        persistant_array_create(OBJECT_SELF, "NewSpellbookMem_" + IntToString(nClass));
    }

    int nSpellLevel = StringToInt(Get2DACache(GetFileForClass(nClass), "Level", nSpellbookID));

    // Make sure the caster has uses of this spell remaining
    // 2009-9-20: Add metamagic feat abilities. -N-S
    int nMetamagic = GetLocalInt(OBJECT_SELF, "MetamagicFeatAdjust");
    if(nMetamagic)
    {
        //Need to check if metamagic can be applied to a spell
        int nMetaTest;
        int nMetaType = HexToInt(Get2DACache("spells", "MetaMagic", nSpellID));

        int nSpellSlotLevel = nSpellLevel;
        switch(nMetamagic)
        {
            case METAMAGIC_NONE:     nMetaTest = 1; break; //no need to change anything
            case METAMAGIC_EMPOWER:  nMetaTest = nMetaType &  1; nSpellLevel += 2; break;
            case METAMAGIC_EXTEND:   nMetaTest = nMetaType &  2; nSpellLevel += 1; break;
            case METAMAGIC_MAXIMIZE: nMetaTest = nMetaType &  4; nSpellLevel += 3; break;
            case METAMAGIC_QUICKEN:  nMetaTest = nMetaType &  8; nSpellLevel += 4; break;
            case METAMAGIC_SILENT:   nMetaTest = nMetaType & 16; nSpellLevel += 1; break;
            case METAMAGIC_STILL:    nMetaTest = nMetaType & 32; nSpellLevel += 1; break;
        }

        if(!nMetaTest)//can't use selected metamagic with this spell
        {
            nMetamagic = METAMAGIC_NONE;
            ActionDoCommand(SendMessageToPC(OBJECT_SELF, "You can't use "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellID)))+"with selected metamagic."));
            nSpellLevel = nSpellSlotLevel;
        }
        else if(nSpellLevel > 9)//now test the spell level
        {
            nMetamagic = METAMAGIC_NONE;
            ActionDoCommand(SendMessageToPC(OBJECT_SELF, "Modified spell level is to high! Casting spell without metamagic"));
            nSpellLevel = nSpellSlotLevel;
        }
        else if(GetLocalInt(OBJECT_SELF, "PRC_metamagic_state") == 1)
            SetLocalInt(OBJECT_SELF, "MetamagicFeatAdjust", 0);
    }
	if (DEBUG) DoDebug("CastSpontaneousSpell(): nSpellLevel is: "+IntToString(nSpellLevel)+".");
    CheckSpontSlots(nClass, nSpellID, nSpellLevel);
    if(GetLocalInt(OBJECT_SELF, "NSB_Cast"))
        ActionDoCommand(CheckSpontSlots(nClass, nSpellID, nSpellLevel, TRUE));
    else
        return;

    // Calculate DC. 10 + spell level on the casting class's list + DC increasing ability mod
    //int nDC = 10 + nSpellLevel + GetDCAbilityModForClass(nClass, OBJECT_SELF);
    // This is wrong and is breaking things, and is already calculated in the function it calls anyway - Strat

    //remove any old effects
    //seems cheat-casting breaks hardcoded removal
    //and cant remove effects because I dont know all the targets!
    if(!bInstantSpell)
    {
        //Handle quicken metamagic and Duskblade's Quick Cast
        if((nMetamagic & METAMAGIC_QUICKEN) || GetLocalInt(OBJECT_SELF, "QuickCast"))
        {
            //Adding Auto-Quicken III - deleted after casting has finished.
            object oSkin = GetPCSkin(OBJECT_SELF);
            int nCastDur = StringToInt(Get2DACache("spells", "ConjTime", nSpellID)) + StringToInt(Get2DACache("spells", "CastTime", nSpellID));
            itemproperty ipAutoQuicken = ItemPropertyBonusFeat(IP_CONST_NSB_AUTO_QUICKEN);
            ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoQuicken, oSkin, nCastDur/1000.0f));
            DeleteLocalInt(OBJECT_SELF, "QuickCast");
        }
    }

    //cast the spell
    //dont need to override level, the spellscript will calculate it
    //class is read from "NSB_Class"
    ActionCastSpell(nSpellID, 0, -1, 0, nMetamagic, CLASS_TYPE_INVALID, 0, 0, OBJECT_INVALID, bInstantSpell);

    //Clean up
    ActionDoCommand(DoCleanUp(nMetamagic));
}

void CastPreparedSpell(int nClass, int nMetamagic = METAMAGIC_NONE, int bInstantSpell = FALSE)
{
    object oPC = OBJECT_SELF;

    //get the spellbook ID
    int nFakeSpellID = GetSpellId();
    int nSpellID = GetPowerFromSpellID(nFakeSpellID);
    if(nSpellID == -1) nSpellID = 0;

    //Check the target first
    if(!bTargetingAllowed(nSpellID))
        return;

    // if OBJECT_SELF is fighting - stop fighting and cast spell
    if(GetCurrentAction() == ACTION_ATTACKOBJECT)
        ClearAllActions();

    //if its a subradial spell, get the master
    int nMasterFakeSpellID = StringToInt(Get2DACache("spells", "Master", nFakeSpellID));
    if(!nMasterFakeSpellID)
        nMasterFakeSpellID = nFakeSpellID;

    int nSpellbookID = SpellToSpellbookID(nMasterFakeSpellID);

    // Paranoia - It should not be possible to get here without having the spells available array existing
    if(!persistant_array_exists(OBJECT_SELF, "NewSpellbookMem_" + IntToString(nClass)))
    {
        if(DEBUG) DoDebug("ERROR: NewSpellbookSpell: NewSpellbookMem_" + IntToString(nClass) + " array does not exist");
        persistant_array_create(OBJECT_SELF, "NewSpellbookMem_" + IntToString(nClass));
    }

    int nSpellLevel = StringToInt(Get2DACache(GetFileForClass(nClass), "Level", nSpellbookID));

    // Make sure the caster has uses of this spell remaining
    CheckPrepSlots(nClass, nSpellID, nSpellbookID);
    if(GetLocalInt(OBJECT_SELF, "NSB_Cast"))
        ActionDoCommand(CheckPrepSlots(nClass, nSpellID, nSpellbookID, TRUE));
    else
        return;

    // Calculate DC. 10 + spell level on the casting class's list + DC increasing ability mod
    //int nDC = 10 + nSpellLevel + GetDCAbilityModForClass(nClass, OBJECT_SELF);
    // This is wrong and is breaking things, and is already calculated in the function it calls anyway - Strat

    //remove any old effects
    //seems cheat-casting breaks hardcoded removal
    //and cant remove effects because I dont know all the targets!
    if(!bInstantSpell)
    {
        //Handle quicken metamagic and Duskblade's Quick Cast
        if((nMetamagic & METAMAGIC_QUICKEN) || GetLocalInt(OBJECT_SELF, "QuickCast"))
        {
            //Adding Auto-Quicken III - deleted after casting has finished.
            object oSkin = GetPCSkin(OBJECT_SELF);
            int nCastDur = StringToInt(Get2DACache("spells", "ConjTime", nSpellID)) + StringToInt(Get2DACache("spells", "CastTime", nSpellID));
            itemproperty ipAutoQuicken = ItemPropertyBonusFeat(IP_CONST_NSB_AUTO_QUICKEN);
            ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoQuicken, oSkin, nCastDur/1000.0f));
            DeleteLocalInt(OBJECT_SELF, "QuickCast");
        }
        else if(nClass == CLASS_TYPE_HEALER)
        {
            if(GetHasFeat(FEAT_EFFORTLESS_HEALING)
            && GetIsOfSubschool(nSpellID, SUBSCHOOL_HEALING))
            {
                object oSkin = GetPCSkin(OBJECT_SELF);
                //all spells from healing subschool except Close Wounds have casting time of 2.5s
                float fCastDur = nSpellID == SPELL_CLOSE_WOUNDS ? 1.0f : 2.5f;
                itemproperty ipImpCombatCast = ItemPropertyBonusFeat(IP_CONST_NSB_IMP_COMBAT_CAST);
                ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipImpCombatCast, oSkin, fCastDur));
            }
        }
    }

    //cast the spell
    //dont need to override level, the spellscript will calculate it
    //class is read from "NSB_Class"
    ActionCastSpell(nSpellID, 0, -1, 0, nMetamagic, CLASS_TYPE_INVALID, 0, 0, OBJECT_INVALID, bInstantSpell);

    //Clean up
    ActionDoCommand(DoCleanUp(nMetamagic));
}

void NewSpellbookSpell(int nClass, int nSpellbookType, int nMetamagic = METAMAGIC_NONE, int bInstantSpell = FALSE)
{
    object oPC = OBJECT_SELF;

    // if oPC is fighting - stop fighting and cast spell
    if(GetCurrentAction(oPC) == ACTION_ATTACKOBJECT)
        ClearAllActions();

    //get the spellbook ID
    int nFakeSpellID = GetSpellId();
    int nSpellID = GetPowerFromSpellID(nFakeSpellID);
    if(nSpellID == -1) nSpellID = 0;

    //Check the target first
    if(!bTargetingAllowed(nSpellID))
        return;

    //if its a subradial spell, get the master
    int nMasterFakeSpellID = StringToInt(Get2DACache("spells", "Master", nFakeSpellID));
    if(!nMasterFakeSpellID)
        nMasterFakeSpellID = nFakeSpellID;

    int nSpellbookID = SpellToSpellbookID(nMasterFakeSpellID);

    // Paranoia - It should not be possible to get here without having the spells available array existing
    if(!persistant_array_exists(oPC, "NewSpellbookMem_" + IntToString(nClass)))
    {
        if(DEBUG) DoDebug("ERROR: NewSpellbookSpell: NewSpellbookMem_" + IntToString(nClass) + " array does not exist");
        persistant_array_create(oPC, "NewSpellbookMem_" + IntToString(nClass));
    }

    string sFile = GetFileForClass(nClass);
    int nSpellLevel = StringToInt(Get2DACache(sFile, "Level", nSpellbookID));
	
	if (DEBUG) DoDebug("inc_newspellbook >> NewSpellbookSpell(): nSpellbookType is: "+IntToString(nSpellbookType)+".");

    // Make sure the caster has uses of this spell remaining
    // 2009-9-20: Add metamagic feat abilities. -N-S
    if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
    {
        CheckPrepSlots(nClass, nSpellID, nSpellbookID);
        if(GetLocalInt(oPC, "NSB_Cast"))
            ActionDoCommand(CheckPrepSlots(nClass, nSpellID, nSpellbookID, TRUE));
        else
            return;
    }
    else if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
    {
        nMetamagic = GetLocalInt(oPC, "MetamagicFeatAdjust");
        if(nMetamagic)
        {
            //Need to check if metamagic can be applied to a spell
            int nMetaTest;
            int nMetaType = HexToInt(Get2DACache("spells", "MetaMagic", nSpellID));

            int nSpellSlotLevel = nSpellLevel;
            switch(nMetamagic)
            {
                case METAMAGIC_NONE:     nMetaTest = 1; break; //no need to change anything
                case METAMAGIC_EMPOWER:  nMetaTest = nMetaType &  1; nSpellLevel += 2; break;
                case METAMAGIC_EXTEND:   nMetaTest = nMetaType &  2; nSpellLevel += 1; break;
                case METAMAGIC_MAXIMIZE: nMetaTest = nMetaType &  4; nSpellLevel += 3; break;
                case METAMAGIC_QUICKEN:  nMetaTest = nMetaType &  8; nSpellLevel += 4; break;
                case METAMAGIC_SILENT:   nMetaTest = nMetaType & 16; nSpellLevel += 1; break;
                case METAMAGIC_STILL:    nMetaTest = nMetaType & 32; nSpellLevel += 1; break;
            }

            if(!nMetaTest)//can't use selected metamagic with this spell
            {
                nMetamagic = METAMAGIC_NONE;
                ActionDoCommand(SendMessageToPC(oPC, "You can't use "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellID)))+"with selected metamagic."));
                nSpellLevel = nSpellSlotLevel;
            }
            else if(nSpellLevel > 9)//now test the spell level
            {
                nMetamagic = METAMAGIC_NONE;
                ActionDoCommand(SendMessageToPC(oPC, "Modified spell level is too high! Casting spell without metamagic"));
                nSpellLevel = nSpellSlotLevel;
            }
            else if(GetLocalInt(oPC, "PRC_metamagic_state") == 1)
                SetLocalInt(oPC, "MetamagicFeatAdjust", 0);
        }
		
		if (DEBUG) DoDebug("inc_newspellbook >> NewSpellbookSpell(): nSpellLevel is: "+IntToString(nSpellLevel)+".");
        CheckSpontSlots(nClass, nSpellID, nSpellLevel);
        if(GetLocalInt(oPC, "NSB_Cast"))
            ActionDoCommand(CheckSpontSlots(nClass, nSpellID, nSpellLevel, TRUE));
        else
            return;
    }

    // Calculate DC. 10 + spell level on the casting class's list + DC increasing ability mod
    //int nDC = 10 + nSpellLevel + GetDCAbilityModForClass(nClass, OBJECT_SELF);
    // This is wrong and is breaking things, and is already calculated in the function it calls anyway - Strat

    //remove any old effects
    //seems cheat-casting breaks hardcoded removal
    //and cant remove effects because I dont know all the targets!
    if(!bInstantSpell)
    {
        //Handle quicken metamagic and Duskblade's Quick Cast
        if((nMetamagic & METAMAGIC_QUICKEN) || GetLocalInt(oPC, "QuickCast"))
        {
            //Adding Auto-Quicken III - deleted after casting has finished.
            object oSkin = GetPCSkin(oPC);
            int nCastDur = StringToInt(Get2DACache("spells", "ConjTime", nSpellID)) + StringToInt(Get2DACache("spells", "CastTime", nSpellID));
            itemproperty ipAutoQuicken = ItemPropertyBonusFeat(IP_CONST_NSB_AUTO_QUICKEN);
            ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoQuicken, oSkin, nCastDur/1000.0f));
            DeleteLocalInt(oPC, "QuickCast");
        }
        else if(nClass == CLASS_TYPE_HEALER)
        {
            if(GetHasFeat(FEAT_EFFORTLESS_HEALING)
            && GetIsOfSubschool(nSpellID, SUBSCHOOL_HEALING))
            {
                object oSkin = GetPCSkin(oPC);
                //all spells from healing subschool except Close Wounds have casting time of 2.5s
                float fCastDur = nSpellID == SPELL_CLOSE_WOUNDS ? 1.0f : 2.5f;
                itemproperty ipImpCombatCast = ItemPropertyBonusFeat(IP_CONST_NSB_IMP_COMBAT_CAST);
                ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipImpCombatCast, oSkin, fCastDur));
            }
        }
    }

    //cast the spell
    //dont need to override level, the spellscript will calculate it
    //class is read from "NSB_Class"
    ActionCastSpell(nSpellID, 0, -1, 0, nMetamagic, CLASS_TYPE_INVALID, 0, 0, OBJECT_INVALID, bInstantSpell);

    //Clean up
    ActionDoCommand(DoCleanUp(nMetamagic));
}

int bTargetingAllowed(int nSpellID)
{
    object oTarget = GetSpellTargetObject();
    if(GetIsObjectValid(oTarget))
    {
        int nTargetType = ~(HexToInt(Get2DACache("spells", "TargetType", nSpellID)));

        //test targetting self
        if(oTarget == OBJECT_SELF)
        {
            if(nTargetType & 1)
            {
                if(DEBUG) DoDebug("bTargetingAllowed: You cannot target yourself.");
                return FALSE;
            }
        }
        //test targetting others
        else if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
        {
            if(nTargetType & 2)
            {
                if(DEBUG) DoDebug("bTargetingAllowed: You cannot target creatures.");
                return FALSE;
            }
        }
    }
    return TRUE;
}

void CheckPrepSlots(int nClass, int nSpellID, int nSpellbookID, int bIsAction = FALSE)
{
    DeleteLocalInt(OBJECT_SELF, "NSB_Cast");
    int nCount = persistant_array_get_int(OBJECT_SELF, "NewSpellbookMem_" + IntToString(nClass), nSpellbookID);
    if(DEBUG) DoDebug("NewSpellbookSpell >> CheckPrepSlots: NewSpellbookMem_" + IntToString(nClass) + "[SpellbookID: " + IntToString(nSpellbookID) + "] = " + IntToString(nCount));
    if(nCount < 1)
    {
        string sSpellName = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellID)));
        // "You have no castings of " + sSpellName + " remaining"
        string sMessage   = ReplaceChars(GetStringByStrRef(16828411), "<spellname>", sSpellName);

        FloatingTextStringOnCreature(sMessage, OBJECT_SELF, FALSE);
        if(bIsAction)
            ClearAllActions();
    }
    else
    {
        SetLocalInt(OBJECT_SELF, "NSB_Cast", 1);
        if(bIsAction)
        {
            SetLocalInt(OBJECT_SELF, "NSB_Class", nClass);
            SetLocalInt(OBJECT_SELF, "NSB_SpellbookID", nSpellbookID);
        }
    }
}

void CheckSpontSlots(int nClass, int nSpellID, int nSpellSlotLevel, int bIsAction = FALSE)
{
    DeleteLocalInt(OBJECT_SELF, "NSB_Cast");
    int nCount = persistant_array_get_int(OBJECT_SELF, "NewSpellbookMem_" + IntToString(nClass), nSpellSlotLevel);
    if(DEBUG) DoDebug("NewSpellbookSpell >> CheckSpontSlots: NewSpellbookMem_" + IntToString(nClass) + "[SpellSlotLevel: " + IntToString(nSpellSlotLevel) + "] = " + IntToString(nCount));
    if(nCount < 1)
    {
        // "You have no castings of spells of level " + IntToString(nSpellLevel) + " remaining"
        string sMessage   = ReplaceChars(GetStringByStrRef(16828409), "<spelllevel>", IntToString(nSpellSlotLevel));
        FloatingTextStringOnCreature(sMessage, OBJECT_SELF, FALSE);
        if(bIsAction)
            ClearAllActions();
    }
    else
    {
        SetLocalInt(OBJECT_SELF, "NSB_Cast", 1);
        if(bIsAction)
        {
            SetLocalInt(OBJECT_SELF, "NSB_Class", nClass);
            SetLocalInt(OBJECT_SELF, "NSB_SpellLevel", nSpellSlotLevel);
        }
    }
}

void DoCleanUp(int nMetamagic)
{
    if(nMetamagic & METAMAGIC_QUICKEN)
    {
        object oSkin = GetPCSkin(OBJECT_SELF);
        RemoveItemProperty(oSkin, ItemPropertyBonusFeat(IP_CONST_NSB_AUTO_QUICKEN));
    }
    DeleteLocalInt(OBJECT_SELF, "NSB_Class");
    DeleteLocalInt(OBJECT_SELF, "NSB_SpellLevel");
    DeleteLocalInt(OBJECT_SELF, "NSB_SpellbookID");
}

//:: Test Void
//:: void main (){}