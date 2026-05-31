//:://////////////////////////////////////////////
//::	;-.  ,-.   ,-.  ,-. 
//::	|  ) |  ) /    (   )
//::	|-'  |-<  |     ;-: 
//::	|    |  \ \    (   )
//::	'    '  '  `-'  `-' 
//::///////////////////////////////////////////////
//::  
/*
	Script:     inc_infusion
	Author:     Jaysyn
	Created:    2025-08-11 17:01:26

	Description:
	Contains most functions related to the Create
	Infusion feat.
	
*/
//::  
//::////////////////////////////////////////////// 
#include "prc_inc_spells"

int GetMaxDivineSpellLevel(object oCaster, int nClass);
int GetCastSpellCasterLevelFromItem(object oItem, int nSpellID);
int GetIsClassSpell(object oCaster, int nSpellID, int nClass);
int GetHasSpellOnClassList(object oCaster, int nSpellID);
void InfusionSecondSave(object oUser, int nDC);

/**
 * @brief Finds the class index for which the given spell is available to the specified caster.
 *
 * This function iterates through all possible classes and returns the first class
 * index for which the specified spell is on the caster's spell list.
 *
 * @param oCaster The creature object to check.
 * @param nSpellID The spell ID to find the class for.
 * 
 * @return The class index that has the spell on its class spell list for the caster,
 *         or -1 if no matching class is found.
 */
int FindSpellCastingClass(object oCaster, int nSpellID)
{
    int i = 0;
    int nClassFound = -1;
    int nClass;

    // Only loop through caster's classes
    for (i = 0; i <= 8; i++)
    {
        nClass = GetClassByPosition(i, oCaster);
        if (nClass == CLASS_TYPE_INVALID) continue;

        if (GetIsClassSpell(oCaster, nSpellID, nClass))
        {
            nClassFound = nClass;
            break;
        }
    }

    return nClassFound;
}


/**
 * @brief Performs validation checks to determine if the caster can use a spell infusion from the specified item.
 * 
 * This function verifies that the item is a valid infused herb, checks the caster's relevant class and ability scores,
 * confirms the caster is a divine spellcaster with the necessary caster level, and ensures the spell is on the caster's class spell list.
 *
 * @param oCaster The creature attempting to use the infusion.
 * @param oItem The infused herb item containing the spell.
 * @param nSpellID The spell ID of the infusion spell being cast.
 * 
 * @return TRUE if all infusion use checks pass and the caster can use the infusion; FALSE otherwise.
 */
 int DoInfusionUseChecks(object oCaster, object oItem, int nSpellID)
{
    int bPnPHerbs = GetPRCSwitch(PRC_CREATE_INFUSION_OPTIONAL_HERBS);

    if(GetBaseItemType(oItem) != BASE_ITEM_INFUSED_HERB)
    {
        FloatingTextStringOnCreature("Not casting from an Infused Herb", oCaster);
        return FALSE;
    }

    int nItemSpellLvl = GetCastSpellCasterLevelFromItem(oItem, nSpellID);
    if (bPnPHerbs && nItemSpellLvl == -1)
    {
        FloatingTextStringOnCreature("Item has no spellcaster level.", oCaster);
        return FALSE;
    }

    // **CRITICAL: Find the correct class that actually has the spell on its list**
    int nClassCaster = FindSpellCastingClass(oCaster, nSpellID);

    if(DEBUG) DoDebug("nClassCaster is: " + IntToString(nClassCaster) + ".");
    
    // Check for valid class
    if (nClassCaster == -1)
    {
        FloatingTextStringOnCreature("No valid class found for this spell.", oCaster);
        return FALSE;
    }
    
    if(GetMaxDivineSpellLevel(oCaster, nClassCaster) < 1 )
    {
        FloatingTextStringOnCreature("You must be a divine spellcaster to activate an infusion.", oCaster);
        return FALSE;       
    }
    
    // Must have spell on class list - (This will also double-check via the class)
    if (!GetHasSpellOnClassList(oCaster, nSpellID))
    {
        FloatingTextStringOnCreature("You must have a spell on one of your class spell lists to cast it from an infusion.", oCaster);
        return FALSE;       
    }   

    // Must meet ability requirement: Ability score >= 10 + spell level
    int nSpellLevel = PRCGetSpellLevelForClass(nSpellID, nClassCaster);
    int nClassAbility = GetAbilityScoreForClass(nClassCaster, oCaster);

    if(DEBUG) DoDebug("inc_infusion >> DoInfusionUseChecks: nClassCaster is "+IntToString(nClassCaster)+".");
    if(DEBUG) DoDebug("inc_infusion >> DoInfusionUseChecks: Class nSpellLevel is "+IntToString(nSpellLevel)+".");
    if(DEBUG) DoDebug("inc_infusion >> DoInfusionUseChecks: nClassAbility is "+IntToString(nClassAbility)+".");   

    if (nClassAbility < 10 + nSpellLevel)
    {
        FloatingTextStringOnCreature("You must meet ability score requirement to cast spell from infusion.", oCaster);
        return FALSE;       
    }   

    // Must have a divine caster level at least equal to infusion's caster level
    int nDivineLvl =  GetPrCAdjustedCasterLevelByType(TYPE_DIVINE, oCaster);
    
    if(DEBUG) DoDebug("inc_infusion >> DoInfusionUseChecks: nDivineLvl is "+IntToString(nDivineLvl)+".");   
    
    if (nDivineLvl < nItemSpellLvl)
    {
        FloatingTextStringOnCreature("Your divine caster level is too low to cast this spell from an infusion.", oCaster);
        return FALSE;       
    }   

    return TRUE;
}

/* int DoInfusionUseChecks(object oCaster, object oItem, int nSpellID)
{
	int bPnPHerbs = GetPRCSwitch(PRC_CREATE_INFUSION_OPTIONAL_HERBS);
	
    if(GetBaseItemType(oItem) != BASE_ITEM_INFUSED_HERB)
	{
		FloatingTextStringOnCreature("Not casting from an Infused Herb", oCaster);
		return FALSE;
		
	}
		
    int nItemSpellLvl = GetCastSpellCasterLevelFromItem(oItem, nSpellID);
    if (bPnPHerbs && nItemSpellLvl == -1)
	{
		FloatingTextStringOnCreature("Item has no spellcaster level.", oCaster);
		return FALSE;		
	}

    // Find relevant class for the spell
    int nClassCaster = FindSpellCastingClass(oCaster, nSpellID);

	if(DEBUG) DoDebug("nClassCaster is: "+IntToString(nClassCaster)+".");
	
	if(GetMaxDivineSpellLevel(oCaster, nClassCaster) < 1 )
	{
		FloatingTextStringOnCreature("You must be a divine spellcaster to activate an infusion.", oCaster);
		return FALSE;		
	}
	
    // Must have spell on class list
    if (!GetHasSpellOnClassList(oCaster, nSpellID))
	{
		FloatingTextStringOnCreature("You must have a spell on one of your class spell lists to cast it from an infusion.", oCaster);
		return FALSE;		
	}	

    // Must meet ability requirement: Ability score >= 10 + spell level
    int nSpellLevel = PRCGetSpellLevelForClass(nSpellID, nClassCaster);
	int nClassAbility = GetAbilityScoreForClass(nClassCaster, oCaster);

	if(DEBUG) DoDebug("inc_infusion >> DoInfusionUseChecks: nClassCaster is "+IntToString(nClassCaster)+".");
	if(DEBUG) DoDebug("inc_infusion >> DoInfusionUseChecks: Class nSpellLevel is "+IntToString(nSpellLevel)+".");
	if(DEBUG) DoDebug("inc_infusion >> DoInfusionUseChecks: nClassAbility is "+IntToString(nClassAbility)+".");	

    if (nClassAbility < 10 + nSpellLevel)
	{
		FloatingTextStringOnCreature("You must meet ability score requirement to cast spell from infusion.", oCaster);
		return FALSE;		
	}	

    // Must have a divine caster level at least equal to infusion's caster level
	int nDivineLvl =  GetPrCAdjustedCasterLevelByType(TYPE_DIVINE, oCaster);
	
	if(DEBUG) DoDebug("inc_infusion >> DoInfusionUseChecks: nDivineLvl is "+IntToString(nDivineLvl)+".");	
	
    if (nDivineLvl < nItemSpellLvl)
	{
		FloatingTextStringOnCreature("Your divine caster level is too low to cast this spell from an infusion.", oCaster);
		return FALSE;		
	}	

    return TRUE;
}
 */
/**
 * @brief Retrieves the maximum divine spell level known by the caster for a given class.
 * 
 * This function checks the caster's local integers named "PRC_DivSpell1" through "PRC_DivSpell9"
 * in descending order to determine the highest divine spell level available.
 * It returns the highest spell level for which the corresponding local int is false (zero).
 *
 * @param oCaster The creature whose divine spell levels are being checked.
 * @param nClass The class index for which to check the divine spell level (currently unused).
 * 
 * @return The highest divine spell level known by the caster (1 to 9).
 */
int GetMaxDivineSpellLevel(object oCaster, int nClass)
{
    int i = 9;
    for (i; i > 0; i--)
    {
        if(!GetLocalInt(oCaster, "PRC_DivSpell"+IntToString(i)))
            return i;
    }
    return 1;
}

/**
 * @brief Retrieves the spell school of an herb based on its resref by looking it up in the craft_infusion.2da file.
 * 
 * This function searches the "craft_infusion" 2DA for a row matching the herb's resref.
 * If found, it returns the corresponding spell school as an integer constant.
 * If not found or the SpellSchool column is missing/invalid, it returns -1.
 *
 * @param oHerb The herb object to check.
 * 
 * @return The spell school constant corresponding to the herb's infusion spell school,
 *         or -1 if the herb is invalid, not found, or the data is missing.
 */
int GetHerbsSpellSchool(object oHerb)
{
    if (!GetIsObjectValid(oHerb)) return -1;

    string sResref = GetResRef(oHerb);
    int nRow = 0;
    string sRowResref;

    while (nRow < 200)
    {
        sRowResref = Get2DACache("craft_infusion", "Resref", nRow);
        if (sRowResref == "") break; 
        if (sRowResref == sResref)
        {
            string sHerbSpellSchool = Get2DAString("craft_infusion", "SpellSchool", nRow);
			
			if (sHerbSpellSchool == "A") return SPELL_SCHOOL_ABJURATION;
			else if (sHerbSpellSchool == "C") return SPELL_SCHOOL_CONJURATION;
			else if (sHerbSpellSchool == "D") return SPELL_SCHOOL_DIVINATION;
			else if (sHerbSpellSchool == "E") return SPELL_SCHOOL_ENCHANTMENT;
			else if (sHerbSpellSchool == "V") return SPELL_SCHOOL_EVOCATION;
			else if (sHerbSpellSchool == "I") return SPELL_SCHOOL_ILLUSION;
			else if (sHerbSpellSchool == "N") return SPELL_SCHOOL_NECROMANCY;
			else if (sHerbSpellSchool == "T") return SPELL_SCHOOL_TRANSMUTATION;
			else return SPELL_SCHOOL_GENERAL;

			return -1;
        }
        nRow++;
    }
    return -1; // Not found
}

/**
 * @brief Retrieves the infusion spell level of an herb by matching its resref in the craft_infusion.2da file.
 * 
 * This function searches the "craft_infusion" 2DA for a row matching the herb's resref.
 * If found, it returns the spell level from the SpellLevel column as an integer.
 * If not found or the column is missing, it returns -1.
 *
 * @param oHerb The herb object whose infusion spell level is to be retrieved.
 * 
 * @return The spell level as an integer if found, or -1 if the herb is invalid, not found, or the column is missing.
 */
int GetHerbsInfusionSpellLevel(object oHerb)
{
    if (!GetIsObjectValid(oHerb)) return -1;

    string sResref = GetResRef(oHerb);
    int nRow = 0;
    string sRowResref;

    // Brute-force loop — adjust limit if your 2DA has more than 500 rows
    while (nRow < 200)
    {
        sRowResref = Get2DACache("craft_infusion", "Resref", nRow);
        if (sRowResref == "") break; // End of valid rows
        if (sRowResref == sResref)
        {
            string sSpellLevelStr = Get2DAString("craft_infusion", "SpellLevel", nRow);
            return StringToInt(sSpellLevelStr);
        }
        nRow++;
    }
    return -1; // Not found
}

/**
 * @brief Retrieves the caster level of a specific cast-spell item property from an item.
 * 
 * This function iterates through the item properties of the given item, searching for an
 * ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL property that matches the specified spell ID.
 * If found, it returns the caster level value stored in the item property.
 *
 * @param oItem The item object to check.
 * @param nSpellID The spell ID to match against the item property.
 * 
 * @return The caster level associated with the matching cast-spell item property,
 *         or -1 if no matching property is found.
 */
int GetCastSpellCasterLevelFromItem(object oItem, int nSpellID)
{
    int nFoundCL = -1;

    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip))
    {
        int nType = GetItemPropertyType(ip);

        // First preference: PRC's CASTER_LEVEL itemprop
        if (nType == ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL)
        {
            int nSubType = GetItemPropertySubType(ip);
            string sSpellIDStr = Get2DAString("iprp_spells", "SpellIndex", nSubType);
            int nSubSpellID = StringToInt(sSpellIDStr);

            if (nSubSpellID == nSpellID)
            {
                return GetItemPropertyCostTableValue(ip); // Found exact CL
            }
        }

        // Fallback: vanilla CAST_SPELL property
        if (nType == ITEM_PROPERTY_CAST_SPELL && nFoundCL == -1)
        {
            int nSubType = GetItemPropertySubType(ip);
            string sSpellIDStr = Get2DAString("iprp_spells", "SpellIndex", nSubType);
            int nSubSpellID = StringToInt(sSpellIDStr);

            if (nSubSpellID == nSpellID)
            {
                // Vanilla uses CostTableValue for *number of uses*, not CL,
                // so we’ll assume default caster level = spell level * 2 - 1
                int nSpellLevel = StringToInt(Get2DAString("spells", "Innate", nSubSpellID));
                nFoundCL = nSpellLevel * 2 - 1; // default NWN caster level rule
            }
        }

        ip = GetNextItemProperty(oItem);
    }

    return nFoundCL; // -1 if not found
}


/**
 * @brief Checks if a given spell ID is present on the specified class's spell list for the caster.
 * 
 * This function determines the spell level of the spell for the given class using PRCGetSpellLevelForClass.
 * If the spell level is -1, the spell is not on the class's spell list.
 * Otherwise, the spell is considered to be on the class spell list.
 *
 * @param oCaster The creature object casting or querying the spell.
 * @param nSpellID The spell ID to check.
 * @param nClass The class index to check the spell list against.
 * 
 * @return TRUE if the spell is on the class's spell list; FALSE otherwise.
 */
int GetIsClassSpell(object oCaster, int nSpellID, int nClass)
{
    if(DEBUG) DoDebug("inc_infusion >> GetIsClassSpell: nSpellID is: "+IntToString(nSpellID)+".");
	if(DEBUG) DoDebug("inc_infusion >> GetIsClassSpell: nClass is: "+IntToString(nClass)+".");
	
	int nSpellLevel = PRCGetSpellLevelForClass(nSpellID, nClass);
    if (nSpellLevel == -1)
    {
        if(DEBUG) DoDebug("inc_infusion >> GetIsClassSpell: SpellLevel is "+IntToString(nSpellLevel)+".");
		if(DEBUG) DoDebug("inc_infusion >> GetIsClassSpell: Spell "+IntToString(nSpellID)+" is not in spelllist of "+IntToString(nClass)+".");
		return FALSE;
    }
    return TRUE;
}

/**
 * @brief Checks if the caster has the specified spell on any of their class spell lists.
 * 
 * This function iterates through all classes the caster has (up to position 8),
 * and returns TRUE if the spell is found on any class's spell list.
 *
 * @param oCaster The creature object to check.
 * @param nSpellID The spell ID to search for.
 * 
 * @return TRUE if the spell is present on at least one of the caster's class spell lists;
 *         FALSE otherwise.
 */
int GetHasSpellOnClassList(object oCaster, int nSpellID)
{
    int i;
    for (i = 0; i <= 8; i++)
    {
        int nClass = GetClassByPosition(i, oCaster);
        if (nClass == CLASS_TYPE_INVALID) continue;

        if (GetIsClassSpell(oCaster, nSpellID, nClass))
        {
            if(DEBUG) DoDebug("inc_infusion >> GetHasSpellOnClassList: Class spell found.");
			return TRUE;
        }
    }
	if(DEBUG) DoDebug("inc_infusion >> GetHasSpellOnClassList: Class spell not found.");
    return FALSE;
}

/**
 * @brief Applies a poison nausea effect to the user when infusion use fails.
 * 
 * This function performs an immediate Fortitude saving throw against poison DC based on infusion caster level.
 * If the user fails and is not immune to poison, an infusion nausea effect is applied, replacing any existing one.
 * A second saving throw is scheduled after 1 minute to attempt to remove the effect.
 *
 * @param oUser The creature who used the infusion and may be poisoned.
 * @param nInfusionCL The caster level of the infusion used, affecting the DC of the saving throw.
 */
void ApplyInfusionPoison(object oUser, int nInfusionCL)
{
    int nDC = 10 + (nInfusionCL / 2);
	int bImmune = GetIsImmune(oUser, IMMUNITY_TYPE_POISON);

    // First save immediately
    if (!bImmune && !PRCMySavingThrow(SAVING_THROW_FORT, oUser, nDC, SAVING_THROW_TYPE_POISON))
    {
        // Remove existing infusion poison nausea effect before applying new
        effect eOld = GetFirstEffect(oUser);
        while (GetIsEffectValid(eOld))
        {
            if (GetEffectTag(eOld) == "INFUSION_POISON_TAG")
            {
                RemoveEffect(oUser, eOld);
                break;  // Assuming only one effect with this tag
            }
            eOld = GetNextEffect(oUser);
        }

        effect eNausea = EffectNausea(oUser, 60.0f);
		
        TagEffect(eNausea, "INFUSION_POISON_TAG");
		FloatingTextStringOnCreature("The infusion has made you nauseous.", oUser);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNausea, oUser, RoundsToSeconds(10));
    }

    // Second save 1 minute later
    if (!bImmune)
	{
		DelayCommand(60.0, InfusionSecondSave(oUser, nDC));
	}
}

void InfusionSecondSave(object oUser, int nDC)
{
    if (!PRCMySavingThrow(SAVING_THROW_FORT, oUser, nDC, SAVING_THROW_TYPE_POISON))
    {
        FloatingTextStringOnCreature("The infusion has made you nauseous.", oUser);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNausea(oUser, 60.0f), oUser, RoundsToSeconds(10));
    }
}

//:: void main (){}