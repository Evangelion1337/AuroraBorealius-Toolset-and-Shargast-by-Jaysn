// Get the DC to save against for a spell (10 + spell level + relevant ability
// bonus).  This can be called by a creature or by an Area of Effect object.
// Takes into account PRC classes
int PRCGetSpellSaveDC(int nSpellID = -1, int nSchool = -1, object oCaster = OBJECT_SELF);

// Use this function to get the adjustments to a spell or SLAs saving throw
// from the various class effects
// Update this function if any new classes change saving throws
int PRCGetSaveDC(object oTarget, object oCaster, int nSpellID = -1);

//called just from above and from inc_epicspells
int GetChangesToSaveDC(object oTarget, object oCaster, int nSpellID, int nSchool);
#include "prc_inc_factotum"
#include "prc_add_spl_pen"

// #include "prc_inc_spells"
// #include "prc_class_const"
// #include "prc_feat_const"
// #include "lookup_2da_spell"
// #include "prcsp_archmaginc"
// #include "prc_alterations"
// #include "prc_inc_racial"
#include "inc_newspellbook"

int GetCorruptSpellFocus(int nSpellID, object oCaster)
{
    int nCorrupt = FALSE;
    if(nSpellID == SPELL_ABSORB_STRENGTH
    || nSpellID == SPELL_APOCALYPSE_FROM_THE_SKY
    || nSpellID == SPELL_CLAWS_OF_THE_BEBILITH
    || nSpellID == SPELL_DEATH_BY_THORNS
    || nSpellID == SPELL_EVIL_WEATHER
    || nSpellID == SPELL_FANGS_OF_THE_VAMPIRE_KING
    || nSpellID == SPELL_LAHMS_FINGER_DARTS
    || nSpellID == SPELL_POWER_LEECH
    || nSpellID == SPELL_RAPTURE_OF_RUPTURE
    || nSpellID == SPELL_RED_FESTER
    || nSpellID == SPELL_ROTTING_CURSE_OF_URFESTRA
    || nSpellID == SPELL_SEETHING_EYEBANE
    || nSpellID == SPELL_TOUCH_OF_JUIBLEX)
        nCorrupt = TRUE;

    if (GetHasFeat(FEAT_GREATER_CORRUPT_SPELL_FOCUS, oCaster) && nCorrupt) return 2;
    else if (GetHasFeat(FEAT_CORRUPT_SPELL_FOCUS, oCaster) && nCorrupt) return 1;
    
    return 0;
}        

int GetHeartWarderDC(int spell_id, int nSchool, object oCaster)
{
    // Check the curent school
    if(nSchool != SPELL_SCHOOL_ENCHANTMENT)
        return 0;

    if(!GetHasFeat(FEAT_VOICE_SIREN, oCaster))
        return 0;

    // Bonus Requires Verbal Spells
    string VS = GetStringLowerCase(Get2DACache("spells", "VS",spell_id));
    if(FindSubString(VS, "v") == -1)
        return 0;

    // These feats provide greater bonuses or remove the Verbal requirement
    if(PRCGetMetaMagicFeat(oCaster, FALSE) & METAMAGIC_SILENT
    || GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT, oCaster)
    || GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT, oCaster))
        return 0;

    return 2;
}

//Elemental Savant DC boost based on elemental spell type.
int ElementalSavantDC(int spell_id, int nElement, object oCaster)
{
    int nDC = 0;

    // All Elemental Savants will have this feat
    // when they first gain a DC bonus.
    if(GetHasFeat(FEAT_ES_FOCUS_1, oCaster))
    {
        // Any value that does not match one of the enumerated feats
        int feat, nES;
        nES = GetLevelByClass(CLASS_TYPE_ELEMENTAL_SAVANT, oCaster);

        // Specify the elemental type rather than lookup by class?
        if(nElement & DESCRIPTOR_FIRE)
        {
            feat = FEAT_ES_FIRE;
        }
        else if(nElement & DESCRIPTOR_COLD)
        {
            feat = FEAT_ES_COLD;
        }
        else if(nElement & DESCRIPTOR_ELECTRICITY)
        {
            feat = FEAT_ES_ELEC;
        }
        else if(nElement & DESCRIPTOR_ACID)
        {
            feat = FEAT_ES_ACID;
        }

        // Now determine the bonus
        if(feat && GetHasFeat(feat, oCaster))
            nDC = (nES + 1) / 3;
    }
//  SendMessageToPC(GetFirstPC(), "Your Elemental Focus modifier is " + IntToString(nDC));
    return nDC;
}

// This does other spell focus feats, starting with Spell Focus: Cold
int SpellFocus(int nSpellId, int nElement, object oCaster)
{
    int nDC = 0;

    // Specify the elemental type 
    if(nElement & DESCRIPTOR_COLD)
    {
        if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_COLD, oCaster))
            nDC += 2;
        else if(GetHasFeat(FEAT_SPELL_FOCUS_COLD, oCaster))
            nDC += 1;
    }
    if (GetHasDescriptor(nSpellId, DESCRIPTOR_CHAOTIC) && GetHasFeat(FEAT_SPELL_FOCUS_CHAOS, oCaster)) nDC += 1;
    if (GetHasDescriptor(nSpellId, DESCRIPTOR_EVIL) && GetHasFeat(FEAT_SPELL_FOCUS_EVIL, oCaster)) nDC += 1;
    if (GetHasDescriptor(nSpellId, DESCRIPTOR_GOOD) && GetHasFeat(FEAT_SPELL_FOCUS_GOOD, oCaster)) nDC += 1;
    if (GetHasDescriptor(nSpellId, DESCRIPTOR_LAWFUL) && GetHasFeat(FEAT_SPELL_FOCUS_LAWFUL, oCaster)) nDC += 1;

    return nDC;
}

//Red Wizard DC boost based on spell school specialization
int RedWizardDC(int spell_id, int nSchool, object oCaster)
{
    int iRedWizard = GetLevelByClass(CLASS_TYPE_RED_WIZARD, oCaster);
    int nDC;

    if(iRedWizard)
    {
        int iRWSpec;
        switch(nSchool)
        {
            case SPELL_SCHOOL_ABJURATION:    iRWSpec = FEAT_RW_TF_ABJ; break;
            case SPELL_SCHOOL_CONJURATION:   iRWSpec = FEAT_RW_TF_CON; break;
            case SPELL_SCHOOL_DIVINATION:    iRWSpec = FEAT_RW_TF_DIV; break;
            case SPELL_SCHOOL_ENCHANTMENT:   iRWSpec = FEAT_RW_TF_ENC; break;
            case SPELL_SCHOOL_EVOCATION:     iRWSpec = FEAT_RW_TF_EVO; break;
            case SPELL_SCHOOL_ILLUSION:      iRWSpec = FEAT_RW_TF_ILL; break;
            case SPELL_SCHOOL_NECROMANCY:    iRWSpec = FEAT_RW_TF_NEC; break;
            case SPELL_SCHOOL_TRANSMUTATION: iRWSpec = FEAT_RW_TF_TRS; break;
        }

        if(iRWSpec && GetHasFeat(iRWSpec, oCaster))
            nDC = iRedWizard / 2;
    }
//  SendMessageToPC(GetFirstPC(), "Your Spell Power modifier is " + IntToString(nDC));
    return nDC;
}

//Red Wizards recieve a bonus against their specialist schools
// this is done by lowering the DC of spells cast against them
int RedWizardDCPenalty(int spell_id, int nSchool, object oTarget)
{
    int nDC;
    int iRW = GetLevelByClass(CLASS_TYPE_RED_WIZARD, oTarget);
    if(iRW)
    {
        int iRWSpec;
        switch(nSchool)
        {
            case SPELL_SCHOOL_ABJURATION:    iRWSpec = FEAT_RW_TF_ABJ; break;
            case SPELL_SCHOOL_CONJURATION:   iRWSpec = FEAT_RW_TF_CON; break;
            case SPELL_SCHOOL_DIVINATION:    iRWSpec = FEAT_RW_TF_DIV; break;
            case SPELL_SCHOOL_ENCHANTMENT:   iRWSpec = FEAT_RW_TF_ENC; break;
            case SPELL_SCHOOL_EVOCATION:     iRWSpec = FEAT_RW_TF_EVO; break;
            case SPELL_SCHOOL_ILLUSION:      iRWSpec = FEAT_RW_TF_ILL; break;
            case SPELL_SCHOOL_NECROMANCY:    iRWSpec = FEAT_RW_TF_NEC; break;
            case SPELL_SCHOOL_TRANSMUTATION: iRWSpec = FEAT_RW_TF_TRS; break;
        }

        if(iRWSpec && GetHasFeat(iRWSpec, oTarget))
           nDC -= iRW > 4 ? (iRW - 1) / 2 : (iRW + 1) / 2;
    }
    return nDC;
}

int ShadowAdeptDCPenalty(int spell_id, int nSchool, object oTarget)
{
    int nDC;
    int iShadow = GetLevelByClass(CLASS_TYPE_SHADOW_ADEPT, oTarget);
    if(iShadow)
    {
        if(nSchool == SPELL_SCHOOL_ENCHANTMENT
        || nSchool == SPELL_SCHOOL_NECROMANCY
        || nSchool == SPELL_SCHOOL_ILLUSION)
        {
            nDC -= (iShadow + 1) / 3;
        }
        //SendMessageToPC(GetFirstPC(), "Your Spell Save modifier is " + IntToString(nDC));
    }
    return nDC;
}

//Tattoo Focus DC boost based on spell school specialization
int TattooFocus(int spell_id, int nSchool, object oCaster)
{
    int nDC;
    int iRWSpec;
    switch(nSchool)
    {
        case SPELL_SCHOOL_ABJURATION:    iRWSpec = FEAT_RW_TF_ABJ; break;
        case SPELL_SCHOOL_CONJURATION:   iRWSpec = FEAT_RW_TF_CON; break;
        case SPELL_SCHOOL_DIVINATION:    iRWSpec = FEAT_RW_TF_DIV; break;
        case SPELL_SCHOOL_ENCHANTMENT:   iRWSpec = FEAT_RW_TF_ENC; break;
        case SPELL_SCHOOL_EVOCATION:     iRWSpec = FEAT_RW_TF_EVO; break;
        case SPELL_SCHOOL_ILLUSION:      iRWSpec = FEAT_RW_TF_ILL; break;
        case SPELL_SCHOOL_NECROMANCY:    iRWSpec = FEAT_RW_TF_NEC; break;
        case SPELL_SCHOOL_TRANSMUTATION: iRWSpec = FEAT_RW_TF_TRS; break;
    }

    if(iRWSpec && GetHasFeat(iRWSpec, oCaster))
       nDC = 1;

    return nDC;
}

//:: Jaebrins get a +1 to Enchantment spells.
int JaebrinEnchant(int nSchool, object oCaster)
{
    int nDC;

    if(nSchool == SPELL_SCHOOL_ENCHANTMENT && GetRacialType(oCaster) == RACIAL_TYPE_JAEBRIN)
       nDC = 1;

    return nDC;
}

int ShadowWeaveDC(int spell_id, int nSchool, object oCaster)
{
    // Account for the Shadow Weave feat
    int nDC = ShadowWeave(oCaster, spell_id, nSchool) == 1;

    // Account for Shadow Adept levels
    int iShadow = GetLevelByClass(CLASS_TYPE_SHADOW_ADEPT, oCaster);
    if(iShadow && nDC)
        // Shadow Spell Power
        nDC += iShadow / 3;

    return nDC;
}

int KOTCSpellFocusVsDemons(object oTarget, object oCaster)
{
    if(GetLevelByClass(CLASS_TYPE_KNIGHT_CHALICE, oCaster) >= 1)
    {
        if(MyPRCGetRacialType(oTarget) == RACIAL_TYPE_OUTSIDER)
        {
            if(GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL)
            {
                return 2;
            }
        }
    }
    return 0;
}

int BloodMagusBloodComponent(object oCaster)
{
    int nDC = 0;
    if (GetLevelByClass(CLASS_TYPE_BLOOD_MAGUS, oCaster) > 0 && GetLocalInt(oCaster, "BloodComponent") == TRUE)
    {
        nDC = 1;
        effect eSelfDamage = EffectDamage(1, DAMAGE_TYPE_MAGICAL);
        // To make sure it doesn't cause a conc check
            DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eSelfDamage, oCaster));
        }
        return nDC;
}

int RunecasterRunePowerDC(object oCaster)
{
    int nDC;

    if(GetHasSpellEffect(SPELL_RUNE_CHANT))
    {
        int nClass = GetLevelByClass(CLASS_TYPE_RUNECASTER, oCaster);

        if (nClass >= 30)        nDC = 10;
        else if (nClass >= 27)   nDC = 9;
        else if (nClass >= 24)   nDC = 8;
        else if (nClass >= 21)   nDC = 7;
        else if (nClass >= 18)   nDC = 6;
        else if (nClass >= 15)   nDC = 5;
        else if (nClass >= 12)   nDC = 4;
        else if (nClass >= 9)    nDC = 3;
        else if (nClass >= 5)    nDC = 2;
        else if (nClass >= 2)    nDC = 1;
    }
    return nDC;
}

 //Unheavened spell
int UnheavenedAdjustment(object oTarget, object oCaster)
{
    if(GetHasSpellEffect(SPELL_UNHEAVENED, oTarget))
    {
        if((MyPRCGetRacialType(oCaster) == RACIAL_TYPE_OUTSIDER) && (GetAlignmentGoodEvil(oCaster) == ALIGNMENT_GOOD))
        {
            return -4;
        }
    }
    return 0;
}

// Soul Eater's 10th level Soul Power ability. If they've drained in the last 24h, they get +2 to DCs
int SoulEaterSoulPower(object oCaster)
{
    return (GetLocalInt(oCaster, "PRC_SoulEater_HasDrained") && GetLevelByClass(CLASS_TYPE_SOUL_EATER, oCaster) >= 10) ? 2 : 0;
}

//:: Saint Template gets a +2 DC on all spells, powers & abilites.
int SaintHolySpellPower(object oCaster)
{
	if(GetHasFeat(FEAT_TEMPLATE_SAINT_HOLY_POWER, oCaster))
		{
			if (GetAlignmentGoodEvil(oCaster) == ALIGNMENT_GOOD)
			{
				return 2;
			}
			else
			{
				return 0;
			}
		}
//:: If it gets here, the caster does not have the feat
    return 0;
}		

//Draconic Power's elemental boost to spell DCs
int DraconicPowerDC(int spell_id, int nElement, object oCaster)
{
    if(GetHasFeat(FEAT_DRACONIC_POWER, oCaster))
    {
        // Compare heritage type and elemental type
        if(nElement & DESCRIPTOR_FIRE)
        {
            if(GetHasFeat(FEAT_DRACONIC_HERITAGE_BS, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_GD, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_RD, oCaster))
                return 1;
        }
        else if(nElement & DESCRIPTOR_COLD)
        {
            if(GetHasFeat(FEAT_DRACONIC_HERITAGE_CR, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_SR, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_TP, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_WH, oCaster))
                return 1;
        }
        else if(nElement & DESCRIPTOR_ELECTRICITY)
        {
            if(GetHasFeat(FEAT_DRACONIC_HERITAGE_BL, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_BZ, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_SA, oCaster))
                return 1;
        }
        else if(nElement & DESCRIPTOR_ACID)
        {
            if(GetHasFeat(FEAT_DRACONIC_HERITAGE_BK, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_CP, oCaster)
            || GetHasFeat(FEAT_DRACONIC_HERITAGE_GR, oCaster))
                return 1;
        }
        else if(nElement & DESCRIPTOR_SONIC)
        {
            if(GetHasFeat(FEAT_DRACONIC_HERITAGE_EM, oCaster))
                return 1;
        }
    }

    //if it gets here, the caster does not have the feat, or is a heritage type without a NWN element (e.g. Amethyst)
    return 0;
}

//Energy Draconc Aura's elemental boost to spell DCs
int EnergyAuraDC(int spell_id, int nElement, object oCaster)
{
    // Compare aura type and elemental type
    if(nElement & DESCRIPTOR_FIRE)
        return GetLocalInt(oCaster, "FireEnergyAura");

    else if(nElement & DESCRIPTOR_COLD)
        return GetLocalInt(oCaster, "ColdEnergyAura");

    else if(nElement & DESCRIPTOR_ELECTRICITY)
        return GetLocalInt(oCaster, "ElecEnergyAura");

    else if(nElement & DESCRIPTOR_ACID)
        return GetLocalInt(oCaster, "AcidEnergyAura");

    //if it gets here, the caster is not in this type of Draconic Aura
    return 0;
}

//Spirit Folk get a better save vs elemental stuff
int SpiritFolkAdjustment(int spell_id, int nElement, object oTarget)
{
    if(nElement & DESCRIPTOR_FIRE && GetHasFeat(FEAT_BONUS_SEA, oTarget))
    {
        return -2;
    }
    else if(nElement & DESCRIPTOR_COLD && GetHasFeat(FEAT_BONUS_RIVER, oTarget))
    {
        return -2;
    }
    else if(nElement & DESCRIPTOR_ACID && GetHasFeat(FEAT_BONUS_BAMBOO, oTarget))
    {
        return -2;
    }

    //if it gets here, the target is not a Spirit Folk
    return 0;
}

//Angry Spell for Rage Mage class
int AngrySpell(int spell_id, int nSchool, object oCaster)
{
    int nDC;

    if(GetHasSpellEffect(SPELL_SPELL_RAGE, oCaster))
    {
        if(nSchool == SPELL_SCHOOL_ABJURATION
        || nSchool == SPELL_SCHOOL_CONJURATION
        || nSchool == SPELL_SCHOOL_EVOCATION
        || nSchool == SPELL_SCHOOL_NECROMANCY
        || nSchool == SPELL_SCHOOL_TRANSMUTATION)
        {
            if(GetLevelByClass(CLASS_TYPE_RAGE_MAGE, oCaster) >= 10)
                nDC = 4;
            else if(GetLevelByClass(CLASS_TYPE_RAGE_MAGE, oCaster) >= 5)
                nDC = 2;
        }
    }

    return nDC;
}

int CloakedCastingDC(int spell_id, object oTarget, object oCaster)  
{  
    int nDC;  
    int iBeguiler = GetLevelByClass(CLASS_TYPE_BEGUILER, oCaster);  
    int iFactotum = GetLevelByClass(CLASS_TYPE_FACTOTUM, oCaster);  
    int iEffectiveLevel = 0;  
  
    // Check if character has Beguiler levels OR has learned Cloaked Casting via Cunning Brilliance  
    if(iBeguiler || (iFactotum && GetIsAbilitySaved(oCaster, FEAT_CLOAKED_CASTING)))  
    {  
        if(GetIsDeniedDexBonusToAC(oTarget, oCaster, TRUE))  
        {  
            // Use Beguiler level if available, otherwise use Factotum level  
            iEffectiveLevel = iBeguiler ? iBeguiler : iFactotum;  
              
            if(iEffectiveLevel >= 14)  
                nDC = 2;  
            else if(iEffectiveLevel >= 2)  
                nDC = 1;  
        }  
    }  
  
    return nDC;  
}

/* int CloakedCastingDC(int spell_id, object oTarget, object oCaster)
{
    int nDC;
    int iBeguiler = GetLevelByClass(CLASS_TYPE_BEGUILER, oCaster);

    if(iBeguiler)
    {
        if(GetIsDeniedDexBonusToAC(oTarget, oCaster, TRUE))
        {
            if(iBeguiler >= 14)
                nDC = 2;
            else if(iBeguiler >= 2)
                nDC = 1;
        }
    }

    return nDC;
} */

 // Wyrmbane Helm
int WyrmbaneHelmDC(object oTarget, object oCaster)
{
	// You get nothing if you aren't wielding the legacy item
    object oWOL = GetItemPossessedBy(oCaster, "WOL_Wyrmbane");
    if(oWOL != GetItemInSlot(INVENTORY_SLOT_HEAD, oCaster)) return 0;
    
    if((MyPRCGetRacialType(oTarget) == RACIAL_TYPE_DRAGON))
    {
        return 2;
    }
    return 0;
}

// Arkamoi Strength From Magic
int StrengthFromMagic(object oCaster)
{
	if (GetRacialType(oCaster) != RACIAL_TYPE_ARKAMOI)
		return 0;
		
	if (GetIsArcaneClass(PRCGetLastSpellCastClass(oCaster)))		
		return GetLocalInt(oCaster, "StrengthFromMagic");	
		
	return 0;		
}

// Hobgoblin Warsoul Soul Tyrant
int SoulTyrant(object oCaster)
{
	if (GetRacialType(oCaster) != RACIAL_TYPE_HOBGOBLIN_WARSOUL)
		return 0;
		
	if (GetIsArcaneClass(PRCGetLastSpellCastClass(oCaster)))		
		return GetLocalInt(oCaster, "WarsoulTyrant");	
		
	return 0;		
}

int PRCGetSpellSaveDC(int nSpellID = -1, int nSchool = -1, object oCaster = OBJECT_SELF)
{
    if(nSpellID == -1)
        nSpellID = PRCGetSpellId();
    if(nSchool == -1)
        nSchool = GetSpellSchool(nSpellID);

    int nClass = PRCGetLastSpellCastClass(oCaster);
    int nDC = 10;
 
    if(nClass == CLASS_TYPE_BARD)
        nDC += StringToInt(Get2DACache("Spells", "Bard", nSpellID));
	else if(nClass == CLASS_TYPE_ASSASSIN)
        nDC += StringToInt(Get2DACache("Spells", "Assassin", nSpellID));
    else if(nClass == CLASS_TYPE_CLERIC || nClass == CLASS_TYPE_UR_PRIEST || nClass == CLASS_TYPE_OCULAR)
        nDC += StringToInt(Get2DACache("Spells", "Cleric", nSpellID));
    else if(nClass == CLASS_TYPE_DRUID)
        nDC += StringToInt(Get2DACache("Spells", "Druid", nSpellID));
    else if(nClass == CLASS_TYPE_RANGER)
        nDC += StringToInt(Get2DACache("Spells", "Ranger", nSpellID));
    else if(nClass == CLASS_TYPE_PALADIN)
        nDC += StringToInt(Get2DACache("Spells", "Paladin", nSpellID));
    else if (nClass == CLASS_TYPE_CULTIST_SHATTERED_PEAK)
        nDC += StringToInt(Get2DACache("spells", "Cultist", nSpellID));  
    else if (nClass == CLASS_TYPE_NENTYAR_HUNTER)
        nDC += StringToInt(Get2DACache("spells", "Nentyar", nSpellID));        
    else if (nClass == CLASS_TYPE_SHADOWLORD)
        nDC += StringToInt(Get2DACache("spells", "Telflammar", nSpellID));                
    else if (nClass == CLASS_TYPE_SLAYER_OF_DOMIEL)
        nDC += StringToInt(Get2DACache("spells", "Domiel", nSpellID));    
    else if (nClass == CLASS_TYPE_SOHEI)
        nDC += StringToInt(Get2DACache("spells", "Sohei", nSpellID));        
    else if (nClass == CLASS_TYPE_VASSAL)
        nDC += StringToInt(Get2DACache("spells", "Bahamut", nSpellID));  
    else if (nClass == CLASS_TYPE_BLACKGUARD)
        nDC += StringToInt(Get2DACache("spells", "Blackguard", nSpellID));        
    else if (nClass == CLASS_TYPE_KNIGHT_CHALICE)
        nDC += StringToInt(Get2DACache("spells", "Chalice", nSpellID));   
    else if (nClass == CLASS_TYPE_KNIGHT_MIDDLECIRCLE)
        nDC += StringToInt(Get2DACache("spells", "MiddleCircle", nSpellID));           
    else if (nClass == CLASS_TYPE_SOLDIER_OF_LIGHT)
        nDC += StringToInt(Get2DACache("spells", "SoLight", nSpellID));        
    else if (nClass == CLASS_TYPE_BLIGHTER)
        nDC += StringToInt(Get2DACache("spells", "Blighter", nSpellID));         
    else if (nClass == CLASS_TYPE_HEALER)
        nDC += StringToInt(Get2DACache("spells", "Healer", nSpellID));           
    else if (nClass == CLASS_TYPE_SHAMAN)
        nDC += StringToInt(Get2DACache("spells", "Shaman", nSpellID));         
    else if(nClass == CLASS_TYPE_WIZARD
        || nClass == CLASS_TYPE_SORCERER)
        nDC += StringToInt(Get2DACache("Spells", "Wiz_Sorc", nSpellID));
    else if(nClass != CLASS_TYPE_INVALID)
    {
        int nSpellbookID = RealSpellToSpellbookID(nClass, nSpellID);
        string sFile = GetFileForClass(nClass);
        nDC += StringToInt(Get2DACache(sFile, "Level", nSpellbookID));
    }
    else
        nDC += StringToInt(Get2DACache("Spells", "Innate", nSpellID));

    // This is here because a Cleric casting a domain spell like Chain Lightning has a 0 in the cleric column, resulting in a DC of 10        
    if (nDC == 10 && nClass == CLASS_TYPE_CLERIC)
        nDC += StringToInt(Get2DACache("Spells", "Innate", nSpellID));

    nDC += GetDCAbilityModForClass(nClass, oCaster);

    object oItem = GetSpellCastItem();
    
    int nEpic  = 6;
    int nGreat = 4;
    int nSF    = 2;
    
    if (GetPRCSwitch(PRC_35_SPELL_FOCUS))
    {
        nEpic  = 3;
        nGreat = 2;
        nSF    = 1;    
    }
    
    if(DEBUG && !GetIsObjectValid(oItem)) DoDebug("PRCGetSpellSaveDC oItem is OBJECT_INVALID");
    if(DEBUG) DoDebug("PRCGetSpellSaveDC oCaster "+GetName(oCaster)+", nSpell "+IntToString(nSpellID)+", nSchool "+IntToString(nSchool)+", nClass "+IntToString(nClass)+", oItem "+GetName(oItem));
    
    if(!GetIsObjectValid(oItem) || (GetBaseItemType(oItem) == BASE_ITEM_MAGICSTAFF && GetPRCSwitch(PRC_STAFF_CASTER_LEVEL)))
    {
        if(nSchool == SPELL_SCHOOL_EVOCATION)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_EVOCATION, oCaster))
                nDC+=nEpic;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_EVOCATION, oCaster))
                nDC+=nGreat;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_EVOCATION, oCaster))
                nDC+=nSF;
        }
        else if(nSchool == SPELL_SCHOOL_TRANSMUTATION)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_TRANSMUTATION, oCaster))
                nDC+=nEpic;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_TRANSMUTATION, oCaster))
                nDC+=nGreat;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_TRANSMUTATION, oCaster))
                nDC+=nSF;
        }
        else if(nSchool == SPELL_SCHOOL_NECROMANCY)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_NECROMANCY, oCaster))
                nDC+=nEpic;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_NECROMANCY, oCaster))
                nDC+=nGreat;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_NECROMANCY, oCaster))
                nDC+=nSF;
        }
        else if(nSchool == SPELL_SCHOOL_ILLUSION)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ILLUSION, oCaster))
                nDC+=nEpic;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ILLUSION, oCaster))
                nDC+=nGreat;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_ILLUSION, oCaster))
                nDC+=nSF;
        }
        else if(nSchool == SPELL_SCHOOL_ABJURATION)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ABJURATION, oCaster))
                nDC+=nEpic;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ABJURATION, oCaster))
                nDC+=nGreat;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_ABJURATION, oCaster))
                nDC+=nSF;
        }
        else if(nSchool == SPELL_SCHOOL_CONJURATION)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION, oCaster))
                nDC+=nEpic;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION, oCaster))
                nDC+=nGreat;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION, oCaster))
                nDC+=nSF;
        }
        else if(nSchool == SPELL_SCHOOL_DIVINATION)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, oCaster))
                nDC+=nEpic;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, oCaster))
                nDC+=nGreat;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, oCaster))
                nDC+=nSF;
        }
        else if(nSchool == SPELL_SCHOOL_ENCHANTMENT)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT, oCaster))
                nDC+=nEpic;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT, oCaster))
                nDC+=nGreat;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT, oCaster))
                nDC+=nSF;
        }
    }

    return nDC;
}

int PRCGetSaveDC(object oTarget, object oCaster, int nSpellID = -1)
{
    object oItem = PRCGetSpellCastItem();
    if(nSpellID == -1)
        nSpellID = PRCGetSpellId();
    int nSchool = GetSpellSchool(nSpellID);        
    int nDC;
    // at this point, if it's still -1 then this is running on an AoE
    if (nSpellID == -1)
    {
        // get the needed values off the AoE
        nSpellID = GetLocalInt(OBJECT_SELF, "X2_AoE_SpellID");
        nDC = GetLocalInt(OBJECT_SELF, "X2_AoE_BaseSaveDC");
        nSchool = GetSpellSchool(nSpellID);
    }
    else // not persistent AoE script
    {
        //10+spelllevel+stat(cha default)
        nDC = PRCGetSpellSaveDC(nSpellID, nSchool, oCaster);
    }

    // For when you want to assign the caster DC
    //this does not take feat/race/class into account, it is an absolute override
    if (GetLocalInt(oCaster, PRC_DC_TOTAL_OVERRIDE) != 0)
    {
        nDC = GetLocalInt(oCaster, PRC_DC_TOTAL_OVERRIDE);
        if(DEBUG) DoDebug("Forced-DC PRC_DC_TOTAL_OVERRIDE casting at DC " + IntToString(nDC));
    }
    // For when you want to assign the caster DC
    //this does take feat/race/class into account, it only overrides the baseDC
    else if (GetLocalInt(oCaster, PRC_DC_BASE_OVERRIDE) != 0)
    {
        nDC = GetLocalInt(oCaster, PRC_DC_BASE_OVERRIDE);
        if(nDC == -1)
            nDC = PRCGetSpellSaveDC(nSpellID, nSchool, oCaster);

        if(DEBUG) DoDebug("Forced Base-DC casting at DC " + IntToString(nDC));
        nDC += GetChangesToSaveDC(oTarget, oCaster, nSpellID, nSchool);
    }
    else if(GetIsObjectValid(oItem) && !(GetBaseItemType(oItem) == BASE_ITEM_MAGICSTAFF && GetPRCSwitch(PRC_STAFF_CASTER_LEVEL)))
    {
        //code for getting new ip type
        itemproperty ipTest = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ipTest))
        {
            if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_CAST_SPELL_DC)
            {
                int nSubType = GetItemPropertySubType(ipTest);
                nSubType = StringToInt(Get2DACache("iprp_spells", "SpellIndex", nSubType));
                if(nSubType == nSpellID)
                {
                    nDC = GetItemPropertyCostTableValue (ipTest);
                    break;//end while
                }
            }
            ipTest = GetNextItemProperty(oItem);
        }
        int nType = GetBaseItemType(oItem);
        if(nType == BASE_ITEM_MAGICWAND || nType == BASE_ITEM_ENCHANTED_WAND)
        {               
            if (GetHasFeat(FEAT_WAND_MASTERY, oCaster))
                nDC += 2;
        }         
    }
    else
        nDC += GetChangesToSaveDC(oTarget, oCaster, nSpellID, nSchool);
        
    // Karsus's Heavy Magic ability
    if(GetIsObjectValid(oItem) && GetHasSpellEffect(VESTIGE_KARSUS, oCaster) && GetLocalInt(oCaster, "ExploitVestige") != VESTIGE_KARSUS_HEAVY_MAGIC && (GetLevelByClass(CLASS_TYPE_BINDER, oCaster) || GetHasFeat(FEAT_PRACTICED_BINDER, oCaster)))
    	nDC += 2;

    //target-based adjustments go here
    nDC += RedWizardDCPenalty(nSpellID, nSchool, oTarget);
    nDC += ShadowAdeptDCPenalty(nSpellID, nSchool, oTarget);

    if (GetPRCSwitch(PRC_ACTIVATE_MAX_SPELL_DC_CAP))
       {
         if (nDC > GetPRCSwitch(PRC_SET_MAX_SPELL_DC_CAP))
           {
            nDC = GetPRCSwitch(PRC_SET_MAX_SPELL_DC_CAP);   
           }
       }
    
    return nDC;

}

//called just from above and from inc_epicspells
int GetChangesToSaveDC(object oTarget, object oCaster, int nSpellID, int nSchool)
{
    int nDC;
    int nElement = GetIsElementalSpell(nSpellID);

    if(nElement)
    {
        nDC += ElementalSavantDC(nSpellID, nElement, oCaster);
        nDC += SpiritFolkAdjustment(nSpellID, nElement, oTarget);
        nDC += SpellFocus(nSpellID, nElement, oCaster);
        nDC += DraconicPowerDC(nSpellID, nElement, oCaster);
        nDC += EnergyAuraDC(nSpellID, nElement, oCaster);
    }
    nDC += GetHeartWarderDC(nSpellID, nSchool, oCaster);
    nDC += GetSpellPowerBonus(oCaster);
    nDC += ShadowWeaveDC(nSpellID, nSchool, oCaster);
    nDC += RedWizardDC(nSpellID, nSchool, oCaster);
    nDC += TattooFocus(nSpellID, nSchool, oCaster);
    nDC += KOTCSpellFocusVsDemons(oTarget, oCaster);
    //nDC += BloodMagusBloodComponent(oCaster);
    nDC += RunecasterRunePowerDC(oCaster);
    nDC += UnheavenedAdjustment(oTarget, oCaster);
    nDC += SoulEaterSoulPower(oCaster);
    nDC += AngrySpell(nSpellID, nSchool, oCaster);
    nDC += CloakedCastingDC(nSpellID, oTarget, oCaster);
    nDC += GetCorruptSpellFocus(nSpellID, oCaster);
    nDC += Soulcaster(oCaster, nSpellID);
    nDC += WyrmbaneHelmDC(oTarget, oCaster);
    nDC += StrengthFromMagic(oCaster);
    nDC += SoulTyrant(oCaster);
	nDC += SaintHolySpellPower(oCaster);
    nDC += GetLocalInt(oCaster, PRC_DC_ADJUSTMENT);//this is for builder use
    nDC += JaebrinEnchant(nSchool, oCaster);
    return nDC;
}

// Test main
//:: void main(){}
