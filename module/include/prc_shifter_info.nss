
//:: Updated for .35 by Jaysyn 2023/03/10

#include "prc_inc_function"
#include "inc_nwnx_funcs"

//:: Test Void
//void main (){}


const int DEBUG_NATURAL_AC_CALCULATION = FALSE;
int MAX_BONUS = GetPRCSwitch(PRC_PNP_SHIFTER_BONUS);
const int MAX_PENALTY = 10;
int NWNX_STR_LIMIT = 100 - MAX_BONUS;

struct _prc_inc_ability_info_struct{
    int nTemplateSTR;
    int nTemplateDEX;
    int nTemplateCON;

    int nShifterSTR;
    int nShifterDEX;
    int nShifterCON;

    int nDeltaSTR;
    int nDeltaDEX;
    int nDeltaCON;

    int nItemSTR;
    int nItemDEX;
    int nItemCON;

    int nExtraSTR;
    int nExtraDEX;
    int nExtraCON;
    
    int nItemDeltaSTR;
    int nItemDeltaDEX;
    int nItemDeltaCON;
};

//TODO: also count item penalties?
struct _prc_inc_ability_info_struct _prc_inc_CountItemAbilities(object oCreature)
{
    struct _prc_inc_ability_info_struct rInfoStruct;
    rInfoStruct.nItemSTR = 0;
    rInfoStruct.nItemDEX = 0;
    rInfoStruct.nItemCON = 0;
    
    object oItem;
    itemproperty iProperty;
    int nSlot;
    for(nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; nSlot++)
    {
        switch (nSlot)
        {
            case INVENTORY_SLOT_CARMOUR:
            case INVENTORY_SLOT_CWEAPON_R:
            case INVENTORY_SLOT_CWEAPON_L:
            case INVENTORY_SLOT_CWEAPON_B:
                break;
            
            default:
            {
                oItem = GetItemInSlot(nSlot, oCreature);
                if (GetIsObjectValid(oItem))
                {
                    iProperty = GetFirstItemProperty(oItem);
                    while (GetIsItemPropertyValid(iProperty))
                    {
                        if (GetItemPropertyType(iProperty) == ITEM_PROPERTY_ABILITY_BONUS &&
                            GetItemPropertyDurationType(iProperty) == DURATION_TYPE_PERMANENT 
                           )
                        {
                            int nSubType = GetItemPropertySubType(iProperty);
                            int nCostTableValue = GetItemPropertyCostTableValue(iProperty);
                            if (nSubType == IP_CONST_ABILITY_STR)
                                rInfoStruct.nItemSTR += nCostTableValue;
                            else if (nSubType == IP_CONST_ABILITY_DEX)
                                rInfoStruct.nItemDEX += nCostTableValue;
                            else if (nSubType == IP_CONST_ABILITY_CON)
                                rInfoStruct.nItemCON += nCostTableValue;
                        }
                        // Next item property.
                        iProperty = GetNextItemProperty(oItem);
                    }
                }
            }
        }
    }
    return rInfoStruct;
}

struct _prc_inc_ability_info_struct _prc_inc_shifter_GetAbilityInfo(object oTemplate, object oShifter)
{
	int nNWNxEE = GetPRCSwitch(PRC_NWNXEE_ENABLED);
	int nPRCx	= GetPRCSwitch(PRC_PRCX_ENABLED);
    int bFuncs = (nNWNxEE && nPRCx);

    //Initialize with item ability bonuses

    struct _prc_inc_ability_info_struct rInfoStruct = _prc_inc_CountItemAbilities(oShifter);
    
    //Get template creature abilities
    
    rInfoStruct.nTemplateSTR = GetAbilityScore(oTemplate, ABILITY_STRENGTH, TRUE);
    rInfoStruct.nTemplateDEX = GetAbilityScore(oTemplate, ABILITY_DEXTERITY, TRUE);
    rInfoStruct.nTemplateCON = GetAbilityScore(oTemplate, ABILITY_CONSTITUTION, TRUE);
    //TODO: merge in "Ability Bonus: Strength" from item property from template hide here (not too important, as not many templates use this)
    //TODO: merge in "Ability Bonus: Dexterity" from item property from template hide here (not too important, as not many templates use this)
    //TODO: merge in "Ability Bonus: Constitution" from item property from template hide here (not too important, as not many templates use this)
    
    //Calculate how they compare to the shifter's abilities

    rInfoStruct.nShifterSTR = GetAbilityScore(oShifter, ABILITY_STRENGTH, TRUE);
    rInfoStruct.nShifterDEX = GetAbilityScore(oShifter, ABILITY_DEXTERITY, TRUE);
    rInfoStruct.nShifterCON = GetAbilityScore(oShifter, ABILITY_CONSTITUTION, TRUE);

    rInfoStruct.nDeltaSTR = rInfoStruct.nTemplateSTR - rInfoStruct.nShifterSTR;
    rInfoStruct.nDeltaDEX = rInfoStruct.nTemplateDEX - rInfoStruct.nShifterDEX;
    rInfoStruct.nDeltaCON = rInfoStruct.nTemplateCON - rInfoStruct.nShifterCON;
    
    //Handle stat boosting items
    if (rInfoStruct.nItemSTR > MAX_BONUS)
        rInfoStruct.nItemSTR = MAX_BONUS;
    else if (rInfoStruct.nItemSTR < -MAX_PENALTY)
        rInfoStruct.nItemSTR = -MAX_PENALTY;

    if (rInfoStruct.nItemDEX > MAX_BONUS)
        rInfoStruct.nItemDEX = MAX_BONUS;
    else if (rInfoStruct.nItemDEX < -MAX_PENALTY)
        rInfoStruct.nItemDEX = -MAX_PENALTY;

    if (rInfoStruct.nItemCON > MAX_BONUS)
        rInfoStruct.nItemCON = MAX_BONUS;
    else if (rInfoStruct.nItemCON < -MAX_PENALTY)
        rInfoStruct.nItemCON = -MAX_PENALTY;
        
    //Handle changes that exceed bonus or penalty caps

    rInfoStruct.nItemDeltaSTR = rInfoStruct.nDeltaSTR + rInfoStruct.nItemSTR;
    if (bFuncs)
    {
        //NWNX boosts aren't capped, so we don't need to handle caps, generally speaking. 
        rInfoStruct.nExtraSTR = 0; 

        //However, due to a Bioware issue, if STR, including bonuses, goes greater than 100,
        //the amount of weight the PC can carry drops to 0. So, cap STR to make sure this doesn't happen.

        if (rInfoStruct.nTemplateSTR > NWNX_STR_LIMIT)
        {
            rInfoStruct.nExtraSTR = rInfoStruct.nTemplateSTR - NWNX_STR_LIMIT;
            rInfoStruct.nTemplateSTR = NWNX_STR_LIMIT;
            rInfoStruct.nDeltaSTR = rInfoStruct.nTemplateSTR - rInfoStruct.nShifterSTR;
        }
    }
    else if (rInfoStruct.nItemDeltaSTR > MAX_BONUS)
        rInfoStruct.nExtraSTR = rInfoStruct.nItemDeltaSTR - MAX_BONUS;
    else if(rInfoStruct.nItemDeltaSTR < -MAX_PENALTY)
        rInfoStruct.nExtraSTR = rInfoStruct.nItemDeltaSTR + MAX_PENALTY;
        
    rInfoStruct.nItemDeltaDEX = rInfoStruct.nDeltaDEX + rInfoStruct.nItemDEX;
    if (bFuncs)
        rInfoStruct.nExtraDEX = 0; //NWNX boosts aren't capped, so we don't need to handle caps
    else if (rInfoStruct.nItemDeltaDEX > MAX_BONUS)
        rInfoStruct.nExtraDEX = rInfoStruct.nItemDeltaDEX - MAX_BONUS;
    else if(rInfoStruct.nItemDeltaDEX < -MAX_PENALTY)
        rInfoStruct.nExtraDEX = rInfoStruct.nItemDeltaDEX + MAX_PENALTY;
        
    rInfoStruct.nItemDeltaCON = rInfoStruct.nDeltaCON + rInfoStruct.nItemCON;
    if (bFuncs)
        rInfoStruct.nExtraCON = 0; //NWNX boosts aren't capped, so we don't need to handle caps
    else if (rInfoStruct.nItemDeltaCON > MAX_BONUS)
        rInfoStruct.nExtraCON = rInfoStruct.nItemDeltaCON - MAX_BONUS;
    else if(rInfoStruct.nItemDeltaCON < -MAX_PENALTY)
        rInfoStruct.nExtraCON = rInfoStruct.nItemDeltaCON + MAX_PENALTY;

    return rInfoStruct;
}

int _prc_inc_GetItemACBonus(object oItem)
{
    int nArmorBonus = 0;
    itemproperty iProp = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(iProp))
    {
        if(GetItemPropertyType(iProp) == ITEM_PROPERTY_AC_BONUS && GetItemPropertyDurationType(iProp) == DURATION_TYPE_PERMANENT)
            nArmorBonus = PRCMax(nArmorBonus, GetItemPropertyCostTableValue(iProp)); //TODO: pick the biggest? the first? stack them?
        iProp = GetNextItemProperty(oItem);
    }    
    return nArmorBonus;
}

int _prc_inc_GetArmorMaxDEXBonus(object oArmor, int nMaxDexACBonus = 100)
{
    if (GetIsObjectValid(oArmor))
    {
        int nArmorAC = GetItemACValue(oArmor) - _prc_inc_GetItemACBonus(oArmor); //Exclude magical AC bonus to figure out armor type
        switch(nArmorAC)
        {
            //TODO: CAN THESE BE LOOKED UP IN A 2DA OR SOMEWHERE?
            case 8: case 7: case 6:
                nMaxDexACBonus = 1; break;
            case 5:
                nMaxDexACBonus = 2; break;
            case 4: case 3:
                nMaxDexACBonus = 4; break;
            case 2:
                nMaxDexACBonus = 6; break;
            case 1:
                nMaxDexACBonus = 8; break;
        }
    }
    return nMaxDexACBonus;
}

struct _prc_inc_ac_info_struct{
    int nArmorBase;
    int nArmorBonus;

    int nShieldBase;
    int nShieldBonus;
    
    int nDodgeBonus;
    int nNaturalBonus;
    int nDeflectionBonus;
    
    int nDEXBonus;
};

struct _prc_inc_ac_info_struct _prc_inc_ACInfo(object oTemplate)
{
    struct _prc_inc_ac_info_struct ac_info;
    
    object oArmorItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oTemplate);
    ac_info.nArmorBonus = _prc_inc_GetItemACBonus(oArmorItem);
    ac_info.nArmorBase = GetItemACValue(oArmorItem) - ac_info.nArmorBonus;
    
    ac_info.nDodgeBonus = GetItemACValue(GetItemInSlot(INVENTORY_SLOT_BOOTS, oTemplate));
    ac_info.nNaturalBonus = GetItemACValue(GetItemInSlot(INVENTORY_SLOT_NECK, oTemplate));

    ac_info.nDeflectionBonus = GetItemACValue(GetItemInSlot(INVENTORY_SLOT_HEAD, oTemplate));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_CLOAK, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_LEFTRING, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_BELT, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_ARROWS, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_BULLETS, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_BOLTS, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTemplate)));
    ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTemplate)));

    object oOffHandItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTemplate);
    ac_info.nShieldBase = 0;
    ac_info.nShieldBonus = 0;
    switch (GetBaseItemType(oOffHandItem))
    {
        case BASE_ITEM_SMALLSHIELD:
            ac_info.nShieldBase = 1;
            ac_info.nShieldBonus = GetItemACValue(oOffHandItem) - ac_info.nShieldBase;
            break;
        case BASE_ITEM_LARGESHIELD:
            ac_info.nShieldBase = 2;
            ac_info.nShieldBonus = GetItemACValue(oOffHandItem) - ac_info.nShieldBase;
            break;
        case BASE_ITEM_TOWERSHIELD:
            ac_info.nShieldBase = 3;
            ac_info.nShieldBonus = GetItemACValue(oOffHandItem) - ac_info.nShieldBase;
            break;
        default: //A weapon
            ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(oOffHandItem));
            break;
    }
    
    object oArmsItem = GetItemInSlot(INVENTORY_SLOT_ARMS, oTemplate);
    switch (GetBaseItemType(oArmsItem))
    {
        case BASE_ITEM_BRACER:
            ac_info.nShieldBonus = PRCMax(ac_info.nShieldBonus, GetItemACValue(oArmsItem));
            break;
        case BASE_ITEM_GLOVES:
        default:
            ac_info.nDeflectionBonus = PRCMax(ac_info.nDeflectionBonus, GetItemACValue(oArmsItem));
            break;
    }
    
    if (ac_info.nArmorBonus > 20)
        ac_info.nArmorBonus = 20;
    if (ac_info.nDodgeBonus > 20)
        ac_info.nDodgeBonus = 20;
    if (ac_info.nNaturalBonus > 20)
        ac_info.nNaturalBonus = 20;
    if (ac_info.nDeflectionBonus > 20)
        ac_info.nDeflectionBonus = 20;
    if (ac_info.nShieldBonus > 20)
        ac_info.nShieldBonus = 20;
        
    ac_info.nDEXBonus = PRCMin(GetAbilityModifier(ABILITY_DEXTERITY, oTemplate), _prc_inc_GetArmorMaxDEXBonus(oArmorItem));
    //TODO: make sure this isn't < 0?
    
    return ac_info;
}

//Estimate natural AC of the creature oTemplate
int _prc_inc_CreatureNaturalAC(object oTemplate)
{
    struct _prc_inc_ac_info_struct ac_info = _prc_inc_ACInfo(oTemplate);

    //TODO: GetAC(oTemplate) often returns an AC different (usually higher) than the combat debugging log indicates it should be.
        //Note that combat debugging doesn't report DEX bonus, Monk WIS bonus, etc.; where does this come in?
    int nNaturalAC = GetAC(oTemplate)
                   - 10                           // Adjust for base AC
                   - ac_info.nDEXBonus               // And Dex bonus
                   - ac_info.nArmorBase           // Etc...
                   - ac_info.nArmorBonus
                   - ac_info.nDodgeBonus
                   - ac_info.nNaturalBonus
                   - ac_info.nDeflectionBonus
                   - ac_info.nShieldBase
                   - ac_info.nShieldBonus;
    
    //TODO:
        //Subtract +4 Dodge bonus if template has Haste?
        //Subtract +1 AC / each 5 points of the Tumble skill?
        //Subtract Monk AC from level progression?
        //Subtract WIS AC if Monk/Ninja, etc.?
        //Make sure nNaturalAC is not < 0 (it was for me once using the old method of calculation, which is why I created this new one)
    
    if (DEBUG_NATURAL_AC_CALCULATION || DEBUG)
    {
        DoDebug("_prc_inc_CreatureNaturalAC: total ac: " + IntToString(GetAC(oTemplate)));
        DoDebug("_prc_inc_CreatureNaturalAC: base ac: " + IntToString(10));
        DoDebug("_prc_inc_CreatureNaturalAC: armor base ac: " + IntToString(ac_info.nArmorBase));
        DoDebug("_prc_inc_CreatureNaturalAC: armor bonus ac: " + IntToString(ac_info.nArmorBonus));
        DoDebug("_prc_inc_CreatureNaturalAC: shield base ac: " + IntToString(ac_info.nShieldBase));
        DoDebug("_prc_inc_CreatureNaturalAC: shield bonus ac: " + IntToString(ac_info.nShieldBonus));
        DoDebug("_prc_inc_CreatureNaturalAC: dodge bonus ac: " + IntToString(ac_info.nDodgeBonus));
        DoDebug("_prc_inc_CreatureNaturalAC: natural bonus ac: " + IntToString(ac_info.nNaturalBonus));
        DoDebug("_prc_inc_CreatureNaturalAC: deflection bonus ac: " + IntToString(ac_info.nDeflectionBonus));
        DoDebug("_prc_inc_CreatureNaturalAC: dex ac: " + IntToString(ac_info.nDEXBonus));
        DoDebug("_prc_inc_CreatureNaturalAC: calculated natural ac: " + IntToString(nNaturalAC));
    }
        
    //TODO: combat debugging shows actual natural AC (as well as other type); compare with that to debug.
    
    return nNaturalAC;
}

int _prc_inc_GetFeatDeathAttackLevel(int nFeat)
{
    switch(nFeat)
    {
        case FEAT_PRESTIGE_DEATH_ATTACK_1: return 1;
        case FEAT_PRESTIGE_DEATH_ATTACK_2: return 2;
        case FEAT_PRESTIGE_DEATH_ATTACK_3: return 3;
        case FEAT_PRESTIGE_DEATH_ATTACK_4: return 4;
        case FEAT_PRESTIGE_DEATH_ATTACK_5: return 5;
        case FEAT_PRESTIGE_DEATH_ATTACK_6: return 6;
        case FEAT_PRESTIGE_DEATH_ATTACK_7: return 7;
        case FEAT_PRESTIGE_DEATH_ATTACK_8: return 8;
        case FEAT_PRESTIGE_DEATH_ATTACK_9: return 9;
        case FEAT_PRESTIGE_DEATH_ATTACK_10: return 10;
        case FEAT_PRESTIGE_DEATH_ATTACK_11: return 11;
        case FEAT_PRESTIGE_DEATH_ATTACK_12: return 12;
        case FEAT_PRESTIGE_DEATH_ATTACK_13: return 13;
        case FEAT_PRESTIGE_DEATH_ATTACK_14: return 14;
        case FEAT_PRESTIGE_DEATH_ATTACK_15: return 15;
        case FEAT_PRESTIGE_DEATH_ATTACK_16: return 16;
        case FEAT_PRESTIGE_DEATH_ATTACK_17: return 17;
        case FEAT_PRESTIGE_DEATH_ATTACK_18: return 18;
        case FEAT_PRESTIGE_DEATH_ATTACK_19: return 19;
        case FEAT_PRESTIGE_DEATH_ATTACK_20: return 20;
    }
    return 0;
}

int _prc_inc_GetHasFeat(object oTemplate, int nFeat)
{
    //If oTemplate has the feat FEAT_SNEAK_ATTACK_10, GetHasFeat() always says
    //it has FEAT_PRESTIGE_DEATH_ATTACK_1 through FEAT_PRESTIGE_DEATH_ATTACK_20,
    //whether it actually does or not. Work around this as follows:
    int nSuppress=0;
    int FEAT_SNEAK_ATTACK_10 = 353;    
    if(GetHasFeat(FEAT_SNEAK_ATTACK_10, oTemplate))
    {
        int nFeatDeathAttackLevel = _prc_inc_GetFeatDeathAttackLevel(nFeat);
        if(nFeatDeathAttackLevel)
        {
            int nActualDeathAttackLevel = 0;
            nActualDeathAttackLevel += (GetLevelByClass(CLASS_TYPE_ASSASSIN, oTemplate) + 1) / 2;
            //TODO: Add other classes here? OR use GetTotalSneakAttackDice(), etc. from prc_inc_sneak instead?
            if(nFeatDeathAttackLevel > nActualDeathAttackLevel)
                nSuppress = 1;
        }
    }

    return GetHasFeat(nFeat, oTemplate) && !nSuppress;
}

int _prc_inc_shifting_GetIsCreatureHarmless(object oTemplate)
{
    return GetChallengeRating(oTemplate) < 1.0;
}

int _prc_inc_shifting_CharacterLevelRequirement(object oTemplate)
{
    return GetPRCSwitch(PNP_SHFT_USECR) ? FloatToInt(GetChallengeRating(oTemplate)) : GetHitDice(oTemplate);
}

int _prc_inc_shifting_ShifterLevelRequirement(object oTemplate)
{
    int nRacialType = MyPRCGetRacialType(oTemplate);
    int nSize = PRCGetCreatureSize(oTemplate);
    int nLevelRequired = 0;

    // Size tests
    if(nSize >= CREATURE_SIZE_HUGE)
        nLevelRequired = PRCMax(nLevelRequired, 7);
    if(nSize == CREATURE_SIZE_LARGE)
        nLevelRequired = PRCMax(nLevelRequired, 3);
    if(nSize == CREATURE_SIZE_MEDIUM)
        nLevelRequired = PRCMax(nLevelRequired, 1);
    if(nSize == CREATURE_SIZE_SMALL)
        nLevelRequired = PRCMax(nLevelRequired, 1);
    if(nSize <= CREATURE_SIZE_TINY)
        nLevelRequired = PRCMax(nLevelRequired, 3);

    // Type tests
    if(nRacialType == RACIAL_TYPE_OUTSIDER)
        nLevelRequired = PRCMax(nLevelRequired, 9);
    if(nRacialType == RACIAL_TYPE_ELEMENTAL)
        nLevelRequired = PRCMax(nLevelRequired, 9);
    if(nRacialType == RACIAL_TYPE_CONSTRUCT)
        nLevelRequired = PRCMax(nLevelRequired, 8);
    if(nRacialType == RACIAL_TYPE_UNDEAD)
        nLevelRequired = PRCMax(nLevelRequired, 8);
    if(nRacialType == RACIAL_TYPE_DRAGON)
        nLevelRequired = PRCMax(nLevelRequired, 7);
    if(nRacialType == RACIAL_TYPE_ABERRATION)
        nLevelRequired = PRCMax(nLevelRequired, 6);
    if(nRacialType == RACIAL_TYPE_OOZE)
        nLevelRequired = PRCMax(nLevelRequired, 6);
    if(nRacialType == RACIAL_TYPE_MAGICAL_BEAST)
        nLevelRequired = PRCMax(nLevelRequired, 5);
    if(nRacialType == RACIAL_TYPE_GIANT)
        nLevelRequired = PRCMax(nLevelRequired, 4);
    if(nRacialType == RACIAL_TYPE_VERMIN)
        nLevelRequired = PRCMax(nLevelRequired, 4);
    if(nRacialType == RACIAL_TYPE_BEAST)
        nLevelRequired = PRCMax(nLevelRequired, 3);
    if(nRacialType == RACIAL_TYPE_ANIMAL)
        nLevelRequired = PRCMax(nLevelRequired, 2);
    if(nRacialType == RACIAL_TYPE_HUMANOID_MONSTROUS)
        nLevelRequired = PRCMax(nLevelRequired, 2);
    if(nRacialType == RACIAL_TYPE_DWARF              ||
       nRacialType == RACIAL_TYPE_ELF                ||
       nRacialType == RACIAL_TYPE_GNOME              ||
       nRacialType == RACIAL_TYPE_HUMAN              ||
       nRacialType == RACIAL_TYPE_HALFORC            ||
       nRacialType == RACIAL_TYPE_HALFELF            ||
       nRacialType == RACIAL_TYPE_HALFLING           ||
       nRacialType == RACIAL_TYPE_HUMANOID_ORC       ||
       nRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN
       )
        nLevelRequired = PRCMax(nLevelRequired, 1);
        
    return nLevelRequired;
}

int _prc_inc_shifting_GetCanFormCast(object oTemplate)
{
    int nRacialType = MyPRCGetRacialType(oTemplate);

    // Need to have hands, and the ability to speak

    switch (nRacialType)
    {
        case RACIAL_TYPE_ABERRATION:
        case RACIAL_TYPE_ANIMAL:
        case RACIAL_TYPE_BEAST:
        case RACIAL_TYPE_MAGICAL_BEAST:
        case RACIAL_TYPE_VERMIN:
        case RACIAL_TYPE_OOZE:
//        case RACIAL_TYPE_PLANT:
            // These forms can't cast spells
            return FALSE;
        case RACIAL_TYPE_DWARF:
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING:
        case RACIAL_TYPE_HALFELF:
        case RACIAL_TYPE_HALFORC:
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_DRAGON:
        case RACIAL_TYPE_HUMANOID_GOBLINOID:
        case RACIAL_TYPE_HUMANOID_MONSTROUS:
        case RACIAL_TYPE_HUMANOID_ORC:
        case RACIAL_TYPE_HUMANOID_REPTILIAN:
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_FEY:
        case RACIAL_TYPE_GIANT:
        case RACIAL_TYPE_OUTSIDER:
        case RACIAL_TYPE_SHAPECHANGER:
        case RACIAL_TYPE_UNDEAD:
            // Break and go return TRUE at the end of the function
            break;

        default:{
            if(DEBUG) DoDebug("prc_inc_shifting: _GetCanFormCast(): Unknown racial type: " + IntToString(nRacialType));
        }
    }

    return TRUE;
}

string _prc_inc_AbilityTypeString(int nAbilityType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_abilities", "Name", nAbilityType)));
}

string _prc_inc_AlignmentGroupString(int nAlignmentGroup)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_aligngrp", "Name", nAlignmentGroup)));
}

string _prc_inc_BonusFeatTypeString(int nBonusFeatType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_feats", "Name", nBonusFeatType)));
}

string _prc_inc_ClassTypeString(int nClassType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("classes", "Name", nClassType)));
}

string _prc_inc_CostTableEntryString(int nCostTable, int nCostTableValue)
{
    string sCostTableName = Get2DACache("iprp_costtable", "Name", nCostTable);
    if(sCostTableName == "" || sCostTableName == "****")
        return "??? (" + IntToString(nCostTable) + " / " + IntToString(nCostTableValue) + ")";
    string sCostTableEntry = Get2DACache(sCostTableName, "Name", nCostTableValue);
    if(sCostTableEntry == "" || sCostTableEntry == "****")
        return "??? (" + sCostTableName + " / " + IntToString(nCostTableValue) + ")";
    return GetStringByStrRef(StringToInt(sCostTableEntry));
}

string _prc_inc_DamageTypeString(int nDamageType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_damagetype", "Name", nDamageType)));
}

string _prc_inc_ImmunityTypeString(int nImmunityType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_immunity", "Name", nImmunityType)));
}

string _prc_inc_OnHitSpellTypeString(int nOnHitSpellType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_onhitspell", "Name", nOnHitSpellType)));
}

string _prc_inc_OnHitTypeString(int nOnHitSpellType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_onhit", "Name", nOnHitSpellType)));
}

string _prc_inc_OnMonsterHitTypeString(int nOnMonsterHitType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_monsterhit", "Name", nOnMonsterHitType)));
}

string _prc_inc_SavingThrowElementTypeString(int nSavingThrowType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_saveelement", "Name", nSavingThrowType)));
}

string _prc_inc_SavingThrowTypeString(int nSavingThrowType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_savingthrow", "Name", nSavingThrowType)));
}

string _prc_inc_SkillTypeString(int nSkillType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("skills", "Name", nSkillType)));
}

string _prc_inc_SpecialWalkTypeString(int nWalkType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_walk", "Name", nWalkType)));
}

string _prc_inc_SpellSchoolTypeString(int nSpellSchoolType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_spellshl", "Name", nSpellSchoolType)));
}

string _prc_inc_SpellTypeString(int nOnHitSpellType)
{
    return GetStringByStrRef(StringToInt(Get2DACache("iprp_spells", "Name", nOnHitSpellType)));
}

string _prc_inc_VisualEffectString(int nVisualEffect)
{
    //TODO: Look up in 2da (which one?)
    switch(nVisualEffect)
    {
        case ITEM_VISUAL_ACID:
            return "Acid";
        case ITEM_VISUAL_COLD:
            return "Cold";
        case ITEM_VISUAL_ELECTRICAL:
            return "Electrical";
        case ITEM_VISUAL_FIRE:
            return "Fire";
        case ITEM_VISUAL_SONIC:
            return "Sonic";
        case ITEM_VISUAL_HOLY:
            return "Holy";
        case ITEM_VISUAL_EVIL:
            return "Evil";
    }
    return "???";
}

string _prc_inc_ItemPropertyString(itemproperty iprop)
{
    int nType = GetItemPropertyType(iprop);
    int nSubType = GetItemPropertySubType(iprop);
    int nDurationType = GetItemPropertyDurationType(iprop);
    int nParam1 = GetItemPropertyParam1(iprop);
    int nParam1Value = GetItemPropertyParam1Value(iprop);
    int nCostTable = GetItemPropertyCostTable(iprop);
    int nCostTableValue = GetItemPropertyCostTableValue(iprop);
    string sType = IntToString(nType);
    string sSubType = IntToString(nSubType);
    string sDurationType = IntToString(nDurationType);
    string sParam1 = IntToString(nParam1);
    string sParam1Value = IntToString(nParam1Value);
    string sCostTable = IntToString(nCostTable);
    string sCostTableValue = IntToString(nCostTableValue);
    string sResult = 
        "Typ: " + sType + "; " 
        + "SubTyp: " + sSubType + "; "
        + "DurTyp: " + sDurationType + "; "
        + "Parm: " + sParam1 + "; "
        + "ParmVal: " + sParam1Value + "; "
        + "CTab: " + sCostTable + "; "
        + "CVal: " + sCostTableValue;
    string sTypeName = GetStringByStrRef(StringToInt(Get2DACache("itempropdef", "Name", nType)));
    switch (nType)
    {
        //TODO: these are all the possible cases; need to handle more of them.
        //DONE case ITEM_PROPERTY_ABILITY_BONUS:
        //DONE case ITEM_PROPERTY_AC_BONUS:
        // case ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP:
        // case ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE:
        // case ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP:
        // case ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT:
        //DONE case ITEM_PROPERTY_ENHANCEMENT_BONUS:
        //DONE case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP:
        // case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP:
        // case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT: 
        // case ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER
        //DONE case ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION
        //DONE case ITEM_PROPERTY_BONUS_FEAT:
        // case ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N:
        //DONE case ITEM_PROPERTY_CAST_SPELL:
        //DONE case ITEM_PROPERTY_DAMAGE_BONUS:
        //DONE case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP:
        //case ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP:
        //case ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT:
        //DONE case ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE:
        // case ITEM_PROPERTY_DECREASED_DAMAGE:
        //DONE case ITEM_PROPERTY_DAMAGE_REDUCTION:
        //DONE case ITEM_PROPERTY_DAMAGE_RESISTANCE:
        //DONE case ITEM_PROPERTY_DAMAGE_VULNERABILITY:
        //DONE case ITEM_PROPERTY_DARKVISION:
        //DONE case ITEM_PROPERTY_DECREASED_ABILITY_SCORE:
        // case ITEM_PROPERTY_DECREASED_AC:
        // case ITEM_PROPERTY_DECREASED_SKILL_MODIFIER: //TODO: e.g. S1-Tomb of Horrors: DesertDragon
        // case ITEM_PROPERTY_ENHANCED_CONTAINER_REDUCED_WEIGHT:
        //DONE case ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE:
        // case ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE:
        //DONE case ITEM_PROPERTY_HASTE:
        // case ITEM_PROPERTY_HOLY_AVENGER:
        //DONE case ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS:
        //DONE case ITEM_PROPERTY_IMPROVED_EVASION:
        //DONE case ITEM_PROPERTY_SPELL_RESISTANCE:
        //DONE case ITEM_PROPERTY_SAVING_THROW_BONUS:
        //DONE case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC:
        //DONE case ITEM_PROPERTY_KEEN:
        //DONE case ITEM_PROPERTY_LIGHT:
        // case ITEM_PROPERTY_MIGHTY:
        // case ITEM_PROPERTY_MIND_BLANK:
        // case ITEM_PROPERTY_NO_DAMAGE:
        //DONE case ITEM_PROPERTY_ON_HIT_PROPERTIES:
        //DONE case ITEM_PROPERTY_DECREASED_SAVING_THROWS:
        //DONE case ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC:
        //DONE case ITEM_PROPERTY_REGENERATION:
        //DONE case ITEM_PROPERTY_SKILL_BONUS:
        //DONE case ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL:
        //DONE case ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL:
        // case ITEM_PROPERTY_THIEVES_TOOLS:
        //DONE case ITEM_PROPERTY_ATTACK_BONUS:
        //DONE case ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP:
        // case ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP:
        // case ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT:
        // case ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER:
        // case ITEM_PROPERTY_UNLIMITED_AMMUNITION:
        // case ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP:
        // case ITEM_PROPERTY_USE_LIMITATION_CLASS:
        // case ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE:
        // case ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT:
        // case ITEM_PROPERTY_USE_LIMITATION_TILESET:
        //DONE case ITEM_PROPERTY_REGENERATION_VAMPIRIC:
        // case ITEM_PROPERTY_TRAP:
        //DONE case ITEM_PROPERTY_TRUE_SEEING:
        //DONE case ITEM_PROPERTY_ON_MONSTER_HIT:
        //DONE case ITEM_PROPERTY_TURN_RESISTANCE:
        //DONE case ITEM_PROPERTY_MASSIVE_CRITICALS:
        //DONE case ITEM_PROPERTY_FREEDOM_OF_MOVEMENT:
        //DONE case ITEM_PROPERTY_MONSTER_DAMAGE:
        //DONE case ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL:
        //DONE case ITEM_PROPERTY_SPECIAL_WALK:
        // case ITEM_PROPERTY_HEALERS_KIT:
        // case ITEM_PROPERTY_WEIGHT_INCREASE:
        //DONE case ITEM_PROPERTY_ONHITCASTSPELL:
        //DONE case ITEM_PROPERTY_VISUALEFFECT:
        // case ITEM_PROPERTY_ARCANE_SPELL_FAILURE:
        
        //Completely ignore
        case ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION:
            return "";

        //Property name only
        case ITEM_PROPERTY_DARKVISION:
        case ITEM_PROPERTY_FREEDOM_OF_MOVEMENT:
        case ITEM_PROPERTY_HASTE:
        case ITEM_PROPERTY_IMPROVED_EVASION:
        case ITEM_PROPERTY_KEEN:
        case ITEM_PROPERTY_TRUE_SEEING:
            return sTypeName;

        //Interpret cost table information
        case ITEM_PROPERTY_AC_BONUS:
        case ITEM_PROPERTY_ATTACK_BONUS:
        case ITEM_PROPERTY_ENHANCEMENT_BONUS:
        case ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL:
        case ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL:
        case ITEM_PROPERTY_LIGHT:
        case ITEM_PROPERTY_MASSIVE_CRITICALS:
        case ITEM_PROPERTY_MONSTER_DAMAGE:
        case ITEM_PROPERTY_REGENERATION:
        case ITEM_PROPERTY_SPELL_RESISTANCE:
        case ITEM_PROPERTY_TURN_RESISTANCE:
            return sTypeName + ": " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);
        
        //Interpret cost table information; interpret subtype as damage type
        case ITEM_PROPERTY_DAMAGE_BONUS:
        case ITEM_PROPERTY_DAMAGE_RESISTANCE:
        case ITEM_PROPERTY_DAMAGE_VULNERABILITY:
        case ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE:
            return sTypeName + ": " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue) + " " + _prc_inc_DamageTypeString(nSubType);

        //Interpret cost table information; interpret subtype as racial group
        case ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP:
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP:
            return sTypeName + ": " + _prc_inc_AlignmentGroupString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);

        //Special handling
        case ITEM_PROPERTY_ABILITY_BONUS:
        case ITEM_PROPERTY_DECREASED_ABILITY_SCORE:
            return sTypeName + ": " + _prc_inc_AbilityTypeString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);
        case ITEM_PROPERTY_BONUS_FEAT:
            return sTypeName + ": " + _prc_inc_BonusFeatTypeString(nSubType);
        case ITEM_PROPERTY_CAST_SPELL:
            return sTypeName + ": " + _prc_inc_SpellTypeString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);
        case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP:
            return sTypeName + ": " + _prc_inc_AlignmentGroupString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue) + " " + _prc_inc_DamageTypeString(nParam1Value);
        case ITEM_PROPERTY_DAMAGE_REDUCTION:
            return sTypeName + ": " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue) + " / " + IntToString(StringToInt(sSubType)+1);
        case ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE:
        case ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE:
            return sTypeName + ": " + _prc_inc_DamageTypeString(nSubType);
        case ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS:
            return sTypeName + ": " + _prc_inc_ImmunityTypeString(nSubType);
        case ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL:
            return sTypeName + ": " + _prc_inc_SpellSchoolTypeString(nSubType);
        case ITEM_PROPERTY_ON_HIT_PROPERTIES:
            return sTypeName + ": " + _prc_inc_OnHitTypeString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);
        case ITEM_PROPERTY_ONHITCASTSPELL:
            return sTypeName + ": " + _prc_inc_OnHitSpellTypeString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);
        case ITEM_PROPERTY_ON_MONSTER_HIT:
            return sTypeName + ": " + _prc_inc_OnMonsterHitTypeString(nSubType) + " " + IntToString(nCostTableValue+1);
        case ITEM_PROPERTY_SKILL_BONUS:
            return sTypeName + ": " + _prc_inc_SkillTypeString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);
        case ITEM_PROPERTY_SPECIAL_WALK:
            return sTypeName + ": " + _prc_inc_SpecialWalkTypeString(nSubType);            
        case ITEM_PROPERTY_REGENERATION_VAMPIRIC:
            return sTypeName + ": " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);
        case ITEM_PROPERTY_VISUALEFFECT:
            return sTypeName + ": " + _prc_inc_VisualEffectString(nSubType);

        case ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC:
        case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC:
            return sTypeName + ": " + _prc_inc_SavingThrowTypeString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);

        case ITEM_PROPERTY_DECREASED_SAVING_THROWS:
        case ITEM_PROPERTY_SAVING_THROW_BONUS:
            return sTypeName + ": " + _prc_inc_SavingThrowElementTypeString(nSubType) + " " + _prc_inc_CostTableEntryString(nCostTable, nCostTableValue);
    }
    return sTypeName + " (" + sResult + ")";
}

string _prc_inc_EffectString(effect eEffect)
{
    int nType = GetEffectType(eEffect);
    int nSubType = GetEffectSubType(eEffect);
    int nDurationType = GetEffectDurationType(eEffect);
    int nSpellId = GetEffectSpellId(eEffect);
    string sType = IntToString(nType);
    string sSubType = IntToString(nSubType);
    string sDurationType = IntToString(nDurationType);
    string sSpellId = IntToString(nSpellId);

    //Decode type if possible
    //TODO: look up in 2da (which one?) instead of having a big switch statement
    switch (nType)
    {
        case EFFECT_TYPE_INVALIDEFFECT               : sType = "EFFECT_TYPE_INVALIDEFFECT"; break;
        case EFFECT_TYPE_DAMAGE_RESISTANCE           : sType = "EFFECT_TYPE_DAMAGE_RESISTANCE"; break;
        //case EFFECT_TYPE_ABILITY_BONUS             : sType = "EFFECT_TYPE_ABILITY_BONUS"; break;
        case EFFECT_TYPE_REGENERATE                  : sType = "EFFECT_TYPE_REGENERATE"; break;
        //case EFFECT_TYPE_SAVING_THROW_BONUS        : sType = "EFFECT_TYPE_SAVING_THROW_BONUS"; break;
        //case EFFECT_TYPE_MODIFY_AC                 : sType = "EFFECT_TYPE_MODIFY_AC"; break;
        //case EFFECT_TYPE_ATTACK_BONUS              : sType = "EFFECT_TYPE_ATTACK_BONUS"; break;
        case EFFECT_TYPE_DAMAGE_REDUCTION            : sType = "EFFECT_TYPE_DAMAGE_REDUCTION"; break;
        //case EFFECT_TYPE_DAMAGE_BONUS              : sType = "EFFECT_TYPE_DAMAGE_BONUS"; break;
        case EFFECT_TYPE_TEMPORARY_HITPOINTS         : sType = "EFFECT_TYPE_TEMPORARY_HITPOINTS"; break;
        //case EFFECT_TYPE_DAMAGE_IMMUNITY           : sType = "EFFECT_TYPE_DAMAGE_IMMUNITY"; break;
        case EFFECT_TYPE_ENTANGLE                    : sType = "EFFECT_TYPE_ENTANGLE"; break;
        case EFFECT_TYPE_INVULNERABLE                : sType = "EFFECT_TYPE_INVULNERABLE"; break;
        case EFFECT_TYPE_DEAF                        : sType = "EFFECT_TYPE_DEAF"; break;
        case EFFECT_TYPE_RESURRECTION                : sType = "EFFECT_TYPE_RESURRECTION"; break;
        case EFFECT_TYPE_IMMUNITY                    : sType = "EFFECT_TYPE_IMMUNITY"; break;
        //case EFFECT_TYPE_BLIND                     : sType = "EFFECT_TYPE_BLIND"; break;
        case EFFECT_TYPE_ENEMY_ATTACK_BONUS          : sType = "EFFECT_TYPE_ENEMY_ATTACK_BONUS"; break;
        case EFFECT_TYPE_ARCANE_SPELL_FAILURE        : sType = "EFFECT_TYPE_ARCANE_SPELL_FAILURE"; break;
        //case EFFECT_TYPE_MOVEMENT_SPEED            : sType = "EFFECT_TYPE_MOVEMENT_SPEED"; break;
        case EFFECT_TYPE_AREA_OF_EFFECT              : sType = "EFFECT_TYPE_AREA_OF_EFFECT"; break;
        case EFFECT_TYPE_BEAM                        : sType = "EFFECT_TYPE_BEAM"; break;
        //case EFFECT_TYPE_SPELL_RESISTANCE          : sType = "EFFECT_TYPE_SPELL_RESISTANCE"; break;
        case EFFECT_TYPE_CHARMED                     : sType = "EFFECT_TYPE_CHARMED"; break;
        case EFFECT_TYPE_CONFUSED                    : sType = "EFFECT_TYPE_CONFUSED"; break;
        case EFFECT_TYPE_FRIGHTENED                  : sType = "EFFECT_TYPE_FRIGHTENED"; break;
        case EFFECT_TYPE_DOMINATED                   : sType = "EFFECT_TYPE_DOMINATED"; break;
        case EFFECT_TYPE_PARALYZE                    : sType = "EFFECT_TYPE_PARALYZE"; break;
        case EFFECT_TYPE_DAZED                       : sType = "EFFECT_TYPE_DAZED"; break;
        case EFFECT_TYPE_STUNNED                     : sType = "EFFECT_TYPE_STUNNED"; break;
        case EFFECT_TYPE_SLEEP                       : sType = "EFFECT_TYPE_SLEEP"; break;
        case EFFECT_TYPE_POISON                      : sType = "EFFECT_TYPE_POISON"; break;
        case EFFECT_TYPE_DISEASE                     : sType = "EFFECT_TYPE_DISEASE"; break;
        case EFFECT_TYPE_CURSE                       : sType = "EFFECT_TYPE_CURSE"; break;
        case EFFECT_TYPE_SILENCE                     : sType = "EFFECT_TYPE_SILENCE"; break;
        case EFFECT_TYPE_TURNED                      : sType = "EFFECT_TYPE_TURNED"; break;
        case EFFECT_TYPE_HASTE                       : sType = "EFFECT_TYPE_HASTE"; break;
        case EFFECT_TYPE_SLOW                        : sType = "EFFECT_TYPE_SLOW"; break;
        case EFFECT_TYPE_ABILITY_INCREASE            : sType = "EFFECT_TYPE_ABILITY_INCREASE"; break;
        case EFFECT_TYPE_ABILITY_DECREASE            : sType = "EFFECT_TYPE_ABILITY_DECREASE"; break;
        case EFFECT_TYPE_ATTACK_INCREASE             : sType = "EFFECT_TYPE_ATTACK_INCREASE"; break;
        case EFFECT_TYPE_ATTACK_DECREASE             : sType = "EFFECT_TYPE_ATTACK_DECREASE"; break;
        case EFFECT_TYPE_DAMAGE_INCREASE             : sType = "EFFECT_TYPE_DAMAGE_INCREASE"; break;
        case EFFECT_TYPE_DAMAGE_DECREASE             : sType = "EFFECT_TYPE_DAMAGE_DECREASE"; break;
        case EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE    : sType = "EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE"; break;
        case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE    : sType = "EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE"; break;
        case EFFECT_TYPE_AC_INCREASE                 : sType = "EFFECT_TYPE_AC_INCREASE"; break;
        case EFFECT_TYPE_AC_DECREASE                 : sType = "EFFECT_TYPE_AC_DECREASE"; break;
        case EFFECT_TYPE_MOVEMENT_SPEED_INCREASE     : sType = "EFFECT_TYPE_MOVEMENT_SPEED_INCREASE"; break;
        case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE     : sType = "EFFECT_TYPE_MOVEMENT_SPEED_DECREASE"; break;
        case EFFECT_TYPE_SAVING_THROW_INCREASE       : sType = "EFFECT_TYPE_SAVING_THROW_INCREASE"; break;
        case EFFECT_TYPE_SAVING_THROW_DECREASE       : sType = "EFFECT_TYPE_SAVING_THROW_DECREASE"; break;
        case EFFECT_TYPE_SPELL_RESISTANCE_INCREASE   : sType = "EFFECT_TYPE_SPELL_RESISTANCE_INCREASE"; break;
        case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE   : sType = "EFFECT_TYPE_SPELL_RESISTANCE_DECREASE"; break;
        case EFFECT_TYPE_SKILL_INCREASE              : sType = "EFFECT_TYPE_SKILL_INCREASE"; break;
        case EFFECT_TYPE_SKILL_DECREASE              : sType = "EFFECT_TYPE_SKILL_DECREASE"; break;
        case EFFECT_TYPE_INVISIBILITY                : sType = "EFFECT_TYPE_INVISIBILITY"; break;
        case EFFECT_TYPE_IMPROVEDINVISIBILITY        : sType = "EFFECT_TYPE_IMPROVEDINVISIBILITY"; break;
        case EFFECT_TYPE_DARKNESS                    : sType = "EFFECT_TYPE_DARKNESS"; break;
        case EFFECT_TYPE_DISPELMAGICALL              : sType = "EFFECT_TYPE_DISPELMAGICALL"; break;
        case EFFECT_TYPE_ELEMENTALSHIELD             : sType = "EFFECT_TYPE_ELEMENTALSHIELD"; break;
        case EFFECT_TYPE_NEGATIVELEVEL               : sType = "EFFECT_TYPE_NEGATIVELEVEL"; break;
        case EFFECT_TYPE_POLYMORPH                   : sType = "EFFECT_TYPE_POLYMORPH"; break;
        case EFFECT_TYPE_SANCTUARY                   : sType = "EFFECT_TYPE_SANCTUARY"; break;
        case EFFECT_TYPE_TRUESEEING                  : sType = "EFFECT_TYPE_TRUESEEING"; break;
        case EFFECT_TYPE_SEEINVISIBLE                : sType = "EFFECT_TYPE_SEEINVISIBLE"; break;
        case EFFECT_TYPE_TIMESTOP                    : sType = "EFFECT_TYPE_TIMESTOP"; break;
        case EFFECT_TYPE_BLINDNESS                   : sType = "EFFECT_TYPE_BLINDNESS"; break;
        case EFFECT_TYPE_SPELLLEVELABSORPTION        : sType = "EFFECT_TYPE_SPELLLEVELABSORPTION"; break;
        case EFFECT_TYPE_DISPELMAGICBEST             : sType = "EFFECT_TYPE_DISPELMAGICBEST"; break;
        case EFFECT_TYPE_ULTRAVISION                 : sType = "EFFECT_TYPE_ULTRAVISION"; break;
        case EFFECT_TYPE_MISS_CHANCE                 : sType = "EFFECT_TYPE_MISS_CHANCE"; break;
        case EFFECT_TYPE_CONCEALMENT                 : sType = "EFFECT_TYPE_CONCEALMENT"; break;
        case EFFECT_TYPE_SPELL_IMMUNITY              : sType = "EFFECT_TYPE_SPELL_IMMUNITY"; break;
        case EFFECT_TYPE_VISUALEFFECT                : sType = "EFFECT_TYPE_VISUALEFFECT"; break;
        case EFFECT_TYPE_DISAPPEARAPPEAR             : sType = "EFFECT_TYPE_DISAPPEARAPPEAR"; break;
        case EFFECT_TYPE_SWARM                       : sType = "EFFECT_TYPE_SWARM"; break;
        case EFFECT_TYPE_TURN_RESISTANCE_DECREASE    : sType = "EFFECT_TYPE_TURN_RESISTANCE_DECREASE"; break;
        case EFFECT_TYPE_TURN_RESISTANCE_INCREASE    : sType = "EFFECT_TYPE_TURN_RESISTANCE_INCREASE"; break;
        case EFFECT_TYPE_PETRIFY                     : sType = "EFFECT_TYPE_PETRIFY"; break;
        case EFFECT_TYPE_CUTSCENE_PARALYZE           : sType = "EFFECT_TYPE_CUTSCENE_PARALYZE"; break;
        case EFFECT_TYPE_ETHEREAL                    : sType = "EFFECT_TYPE_ETHEREAL"; break;
        case EFFECT_TYPE_SPELL_FAILURE               : sType = "EFFECT_TYPE_SPELL_FAILURE"; break;
        case EFFECT_TYPE_CUTSCENEGHOST               : sType = "EFFECT_TYPE_CUTSCENEGHOST"; break;
        case EFFECT_TYPE_CUTSCENEIMMOBILIZE          : sType = "EFFECT_TYPE_CUTSCENEIMMOBILIZE"; break;
    }

    //Decode subtype if possible
    //TODO: look up in 2da (which one?) instead of having a switch statement
    switch (nSubType)
    {
        case SUBTYPE_MAGICAL                         : sSubType = "SUBTYPE_MAGICAL"; break;
        case SUBTYPE_SUPERNATURAL                    : sSubType = "SUBTYPE_SUPERNATURAL"; break;
        case SUBTYPE_EXTRAORDINARY                   : sSubType = "SUBTYPE_EXTRAORDINARY"; break;
    }

    //Decode duration type if possible
    //TODO: look up in 2da (which one?) instead of having a switch statement
    switch (nDurationType)
    {
        case DURATION_TYPE_INSTANT                   : sDurationType = "DURATION_TYPE_INSTANT"; break;
        case DURATION_TYPE_TEMPORARY                 : sDurationType = "DURATION_TYPE_TEMPORARY"; break;
        case DURATION_TYPE_PERMANENT                 : sDurationType = "DURATION_TYPE_PERMANENT"; break;
    }
    
    string sResult = 
        "EFFECT Type: " + sType + "; " 
        + "SubType: " + sSubType + "; "
        + "DurationType: " + sDurationType + "; "
        + "SpellId: " + sSpellId;

    return sResult;
}

void _prc_inc_PrintShapeInfo(object oPC, string sMessage)
{
    if(!GetLocalInt(oPC, "PRC_SuppressChatPrint"))
        SendMessageToPC(oPC, sMessage); //Send to chat window in game
    if(GetLocalInt(oPC, "PRC_EnableLogPrint"))
        PrintString(sMessage); //Write to log file for reference
}

void _prc_inc_PrintClassInfo(string sPrefix, object oPC, object oTemplate, int nClassType)
{
    if (nClassType != CLASS_TYPE_INVALID)
    {
        int nLevel = GetLevelByClass(nClassType, oTemplate);
        string sClassName = _prc_inc_ClassTypeString(nClassType);
        _prc_inc_PrintShapeInfo(oPC, sPrefix + sClassName + " (" + IntToString(nLevel) + ")");
    }
}

void _prc_inc_PrintItemProperty(string sPrefix, object oPC, itemproperty iProp, int bIncludeTemp = FALSE)
{
    int nDurationType = GetItemPropertyDurationType(iProp);
    if(nDurationType == DURATION_TYPE_PERMANENT || (bIncludeTemp && nDurationType == DURATION_TYPE_TEMPORARY))
    {
        string sPropString = _prc_inc_ItemPropertyString(iProp);
        if(sPropString != "")
        {
            if (nDurationType == DURATION_TYPE_TEMPORARY)
                sPropString = GetStringByStrRef(57473+0x01000000) + sPropString; //"TEMPORARY: "
            _prc_inc_PrintShapeInfo(oPC, sPrefix + sPropString);
        }
    }    
}

void _prc_inc_PrintAllItemProperties(string sPrefix, object oPC, object oItem, int bIncludeTemp = FALSE)
{
    itemproperty iProp = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(iProp))
    {
        _prc_inc_PrintItemProperty(sPrefix, oPC, iProp, bIncludeTemp);
        iProp = GetNextItemProperty(oItem);
    }
}

void _prc_inc_PrintEffect(string sPrefix, object oPC, effect eEffect)
{
    if (GetEffectType(eEffect) == EFFECT_TYPE_INVALIDEFFECT)
    {
        //An effect with type EFFECT_TYPE_INVALID is added for each item property
        //They are also added for a couple of other things (Knockdown, summons, etc.)
        //Just skip these
    }
    else
    {
        string sEffectString = _prc_inc_EffectString(eEffect);
        if(sEffectString != "")
            _prc_inc_PrintShapeInfo(oPC, sPrefix + sEffectString);
    }    
}

void _prc_inc_PrintAllEffects(string sPrefix, object oPC, object oItem)
{
    effect eEffect = GetFirstEffect(oItem);
    while(GetIsEffectValid(eEffect))
    {
        _prc_inc_PrintEffect(sPrefix, oPC, eEffect);
        eEffect = GetNextEffect(oItem);
    }
}

//NOTE: THIS FUNCTION HAS A LOT OF CODE IN COMMON WITH _prc_inc_shifting_CreateShifterActiveAbilitiesItem
//TODO: PUT SOME OF IT IN A SHARED FUNCTION THAT THEY BOTH CALL
void _prc_inc_shifting_PrintShifterActiveAbilities(object oPC, object oTemplate)
{
    string sPrefix = GetStringByStrRef(57437+0x01000000); //"Epic Wildshape Spell-Like Abilities:"
    _prc_inc_PrintShapeInfo(oPC, "=== " + sPrefix);
    
    int bPrinted = FALSE;

    object oTemplateHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTemplate);
    itemproperty iProp = GetFirstItemProperty(oTemplateHide);
    while(GetIsItemPropertyValid(iProp))
    {
        if(GetItemPropertyDurationType(iProp) == DURATION_TYPE_PERMANENT && GetItemPropertyType(iProp) == ITEM_PROPERTY_CAST_SPELL)
        {
            _prc_inc_PrintItemProperty("===    ", oPC, iProp);
            bPrinted = TRUE;
        }
        iProp = GetNextItemProperty(oTemplateHide);
    }

    // Loop over shifter_abilitie.2da
    string sNumUses;
    int nSpell, nNumUses, nProps;
    int i = 0;
    while(nSpell = StringToInt(Get2DACache("shifter_abilitie", "Spell", i)))
    {
        // See if the template has this spell
        if(GetHasSpell(nSpell, oTemplate))
        {
            // Determine the number of uses from the 2da
            sNumUses = Get2DACache("shifter_abilitie", "IPCSpellNumUses", i);
            if(sNumUses == "1_USE_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY;
            else if(sNumUses == "2_USES_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY;
            else if(sNumUses == "3_USES_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY;
            else if(sNumUses == "4_USES_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_4_USES_PER_DAY;
            else if(sNumUses == "5_USES_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_5_USES_PER_DAY;
            else if(sNumUses == "UNLIMITED_USE")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE;
            else{
                if(DEBUG) DoDebug("prc_inc_shifting: _prc_inc_shifting_PrintShifterActiveAbilities(): Unknown IPCSpellNumUses in shifter_abilitie.2da line " + IntToString(i) + ": " + sNumUses);
                nNumUses = -1;
            }

            // Create the itemproperty and print it
            iProp = ItemPropertyCastSpell(StringToInt(Get2DACache("shifter_abilitie", "IPSpell", i)), nNumUses);
            _prc_inc_PrintItemProperty("===    ", oPC, iProp);
            bPrinted = TRUE;
            //TODO: DESTROY iProp?

            // Increment property counter
            nProps += 1;
        }

        // Increment loop counter
        i += 1;
    }
    
    if(!bPrinted)
        _prc_inc_PrintShapeInfo(oPC, "===   " + GetStringByStrRef(57481+0x01000000)); //"None"
}

void _prc_inc_shifting_PrintFeats(object oPC, object oTemplate, int nStartIndex, int nLimitIndex)
{
    //Loop over shifter_feats.2da
    string sFeat;
    int i = nStartIndex;
    while((i < nLimitIndex) && (sFeat = Get2DACache("shifter_feats", "Feat", i)) != "")
    {
        if (_prc_inc_GetHasFeat(oTemplate, StringToInt(sFeat)))
        {
            string sFeatName = GetStringByStrRef(StringToInt(Get2DACache("feat", "Feat", StringToInt(sFeat))));
            _prc_inc_PrintShapeInfo(oPC, "=== " + sFeatName);
        }
        i += 1;
    }
}

void _prc_inc_PrintNaturalAC(object oPC, object oTemplate)
{
    _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(57435+0x01000000) + " " + IntToString(_prc_inc_CreatureNaturalAC(oTemplate))); //Natural AC of form
}

//TODO: TLK Entries
void _prc_inc_PrintDebugItem(object oPC, string oItemType, object oItem)
{
    if (GetIsObjectValid(oItem))
    {
        _prc_inc_PrintShapeInfo(oPC, "====================================");
        _prc_inc_PrintShapeInfo(oPC, "====== " + oItemType);
        _prc_inc_PrintShapeInfo(oPC, "======  NAME: " + GetName(oItem));
        _prc_inc_PrintShapeInfo(oPC, "======  RESREF: " + GetResRef(oItem));
        _prc_inc_PrintShapeInfo(oPC, "======  ITEM PROPERTIES ======");
        _prc_inc_PrintAllItemProperties("=== ", oPC, oItem, TRUE);
        _prc_inc_PrintShapeInfo(oPC, "======  EFFECTS ======");
        _prc_inc_PrintAllEffects("=== ", oPC, oItem);
        _prc_inc_PrintShapeInfo(oPC, "======  OTHER ======");
        if (GetObjectType(oItem) == OBJECT_TYPE_CREATURE)
        {
            _prc_inc_PrintClassInfo("=== ", oPC, oItem, GetClassByPosition(1, oItem));
            _prc_inc_PrintClassInfo("=== ", oPC, oItem, GetClassByPosition(2, oItem));
            _prc_inc_PrintClassInfo("=== ", oPC, oItem, GetClassByPosition(3, oItem));
            _prc_inc_PrintClassInfo("=== ", oPC, oItem, GetClassByPosition(4, oItem));
            _prc_inc_PrintClassInfo("=== ", oPC, oItem, GetClassByPosition(5, oItem));
            _prc_inc_PrintClassInfo("=== ", oPC, oItem, GetClassByPosition(6, oItem));
            _prc_inc_PrintClassInfo("=== ", oPC, oItem, GetClassByPosition(7, oItem));
            _prc_inc_PrintClassInfo("=== ", oPC, oItem, GetClassByPosition(8, oItem));
			
            _prc_inc_PrintShapeInfo(oPC, "------");

            _prc_inc_PrintShapeInfo(oPC, "======  Main hand weapon: " + (GetIsWeaponEffective(oItem, FALSE) ? "Effective" : "Ineffective"));
            _prc_inc_PrintShapeInfo(oPC, "======  Off hand weapon: " + (GetIsWeaponEffective(oItem, TRUE) ? "Effective" : "Ineffective"));
            _prc_inc_PrintShapeInfo(oPC, "======  Immortal: " + (GetImmortal(oItem) ? "Yes" : "No"));
            _prc_inc_PrintShapeInfo(oPC, "------");
                
            _prc_inc_PrintShapeInfo(oPC, "======  Level: " + IntToString(GetHitDice(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "======  CR: " + FloatToString(GetChallengeRating(oItem), 4, 1));
            _prc_inc_PrintShapeInfo(oPC, "======  Caster Level: " + IntToString(GetCasterLevel(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "======  XP: " + IntToString(GetXP(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "======  Alignment: " + IntToString(GetLawChaosValue(oItem)) + " / " + IntToString(GetGoodEvilValue(oItem)));
                //TODO:
                // int GetAlignmentLawChaos(object oCreature);
                // int GetAlignmentGoodEvil(object oCreature);
            _prc_inc_PrintShapeInfo(oPC, "------");

            _prc_inc_PrintShapeInfo(oPC, "======  BAB: " + IntToString(GetBaseAttackBonus(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "======  HP: " + IntToString(GetCurrentHitPoints(oItem)) + " / " + IntToString(GetMaxHitPoints(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "======  AC: " + IntToString(GetAC(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "======  SR: " + IntToString(GetSpellResistance(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "------");

            //TODO: look up names in 2da/TLK?
            _prc_inc_PrintShapeInfo(oPC, "======  STR: " + IntToString(GetAbilityScore(oItem, ABILITY_STRENGTH)) + " (" + IntToString(GetAbilityModifier(ABILITY_STRENGTH, oItem)) + ")");
            _prc_inc_PrintShapeInfo(oPC, "======  DEX: " + IntToString(GetAbilityScore(oItem, ABILITY_DEXTERITY)) + " (" + IntToString(GetAbilityModifier(ABILITY_DEXTERITY, oItem)) + ")");
            _prc_inc_PrintShapeInfo(oPC, "======  CON: " + IntToString(GetAbilityScore(oItem, ABILITY_CONSTITUTION)) + " (" + IntToString(GetAbilityModifier(ABILITY_CONSTITUTION, oItem)) + ")");
            _prc_inc_PrintShapeInfo(oPC, "======  INT: " + IntToString(GetAbilityScore(oItem, ABILITY_INTELLIGENCE)) + " (" + IntToString(GetAbilityModifier(ABILITY_INTELLIGENCE, oItem)) + ")");
            _prc_inc_PrintShapeInfo(oPC, "======  WIS: " + IntToString(GetAbilityScore(oItem, ABILITY_WISDOM)) + " (" + IntToString(GetAbilityModifier(ABILITY_WISDOM, oItem)) + ")");
            _prc_inc_PrintShapeInfo(oPC, "======  CHA: " + IntToString(GetAbilityScore(oItem, ABILITY_CHARISMA)) + " (" + IntToString(GetAbilityModifier(ABILITY_CHARISMA, oItem)) + ")");
            _prc_inc_PrintShapeInfo(oPC, "------");

            //TODO: look up names in 2da/TLK?
            _prc_inc_PrintShapeInfo(oPC, "======  Fortitude: " + IntToString(GetFortitudeSavingThrow(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "======  Will: " + IntToString(GetWillSavingThrow(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "======  Reflex: " + IntToString(GetReflexSavingThrow(oItem)));
            _prc_inc_PrintShapeInfo(oPC, "------");

            int i = 0;
            string sSkillName;
            while((sSkillName = Get2DACache("skills", "Name", i)) != "")
            {
                sSkillName = GetStringByStrRef(StringToInt(sSkillName));
                _prc_inc_PrintShapeInfo(oPC, "======  " + sSkillName + ": " + IntToString(GetSkillRank(i, oItem)));
                i += 1;
            }
            _prc_inc_PrintShapeInfo(oPC, "------");

            _prc_inc_PrintShapeInfo(oPC, "======  Gender: " + IntToString(GetGender(oItem))); //TODO: look up values in 2da?
            _prc_inc_PrintShapeInfo(oPC, "======  Size: " + IntToString(GetCreatureSize(oItem))); //TODO: look up values in 2da?
            _prc_inc_PrintShapeInfo(oPC, "======  Race: " + IntToString(GetRacialType(oItem))); //TODO: look up values in 2da?
            _prc_inc_PrintShapeInfo(oPC, "======  Speed: " + IntToString(GetMovementRate(oItem))); //TODO: look up values in 2da?
            _prc_inc_PrintShapeInfo(oPC, "======  Dead: " + (GetIsDead(oItem) ? "Yes" : "No"));
            _prc_inc_PrintShapeInfo(oPC, "======  Tag: " + GetTag(oItem));
            _prc_inc_PrintShapeInfo(oPC, "======  Object Type: " + IntToString(GetObjectType(oItem))); //TODO: look up values in 2da?

            //TODO?:
                //int GetGold(object oTarget=OBJECT_SELF);
                //location GetLocalLocation(object oObject, string sVarName);
                    // vector GetPositionFromLocation(location lLocation);
                    // object GetAreaFromLocation(location lLocation);
                    // float GetFacingFromLocation(location lLocation);
                //int GetCommandable(object oTarget=OBJECT_SELF);
                //int GetIsListening(object oObject);
                //int GetReputation(object oSource, object oTarget);
                //location GetLocation(object oObject);
                //int GetIsPC(object oCreature);
                // int GetIsEnemy(object oTarget, object oSource=OBJECT_SELF);
                // int GetIsFriend(object oTarget, object oSource=OBJECT_SELF);
                // int GetIsNeutral(object oTarget, object oSource=OBJECT_SELF);
                // int GetStealthMode(object oCreature);
                // int GetDetectMode(object oCreature);
                // int GetDefensiveCastingMode(object oCreature);
                // int GetAppearanceType(object oCreature);
                // int GetWeight(object oTarget=OBJECT_SELF); //Gets the weight of an item, or the total carried weight of a creature in tenths of pounds (as per the baseitems.2da).
                // int GetAILevel(object oTarget=OBJECT_SELF);
                // int GetActionMode(object oCreature, int nMode); 
                // int GetArcaneSpellFailure(object oCreature); 
                // int GetLootable( object oCreature );
                // int GetIsCreatureDisarmable(object oCreature);
                // string GetDeity(object oCreature);
                // string GetSubRace(object oTarget);
                // int GetAge(object oCreature);
                //int GetPlotFlag(object oTarget=OBJECT_SELF);
        }
        else
            _prc_inc_PrintShapeInfo(oPC, "======  AC: " + IntToString(GetItemACValue(oItem)));
        _prc_inc_PrintShapeInfo(oPC, "====================================");
    }    
}

//TODO: TLK Entries
void _prc_inc_ShapePrintDebug(object oPC, object oTarget, int bForceLogPrint)
{
    int nSaveValue = GetLocalInt(oPC, "PRC_EnableLogPrint");
    if (bForceLogPrint)
        SetLocalInt(oPC, "PRC_EnableLogPrint", TRUE);
    
    DelayCommand(0.0, _prc_inc_PrintDebugItem(oPC, "CREATURE", oTarget));
    DelayCommand(0.0, _prc_inc_PrintDebugItem(oPC, "CREATURE SKIN", GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTarget)));
    DelayCommand(0.0, _prc_inc_PrintDebugItem(oPC, "RIGHT CREATURE WEAPON", GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTarget)));
    DelayCommand(0.0, _prc_inc_PrintDebugItem(oPC, "LEFT CREATURE WEAPON", GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTarget)));
    DelayCommand(0.0, _prc_inc_PrintDebugItem(oPC, "SPECIAL CREATURE WEAPON", GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTarget)));

    int nSlot;
    for(nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; nSlot++)
    {
        switch (nSlot)
        {
            case INVENTORY_SLOT_CARMOUR:
            case INVENTORY_SLOT_CWEAPON_R:
            case INVENTORY_SLOT_CWEAPON_L:
            case INVENTORY_SLOT_CWEAPON_B:
                break;
            
            default:
                DelayCommand(0.0, _prc_inc_PrintDebugItem(oPC, "INVENTORY ITEM " + IntToString(nSlot) + ": ", GetItemInSlot(nSlot, oTarget)));
        }
    }

    if (bForceLogPrint)
        DelayCommand(0.1, SetLocalInt(oPC, "PRC_EnableLogPrint", nSaveValue));
}

//TODO: Add nShifterType parameter so that only applicable information is printed?
void _prc_inc_PrintShape(object oPC, object oTemplate, int bForceLogPrint)
{
    int nSaveValue = GetLocalInt(oPC, "PRC_EnableLogPrint");
    if (bForceLogPrint)
        SetLocalInt(oPC, "PRC_EnableLogPrint", TRUE);
    
    _prc_inc_PrintShapeInfo(oPC, "=================================================");
    
    //Basic information
    
    _prc_inc_PrintShapeInfo(oPC, "=== " + GetName(oTemplate));
    _prc_inc_PrintShapeInfo(oPC, "=== " + GetResRef(oTemplate));
    _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef((StringToInt(Get2DACache("racialtypes", "Name", MyPRCGetRacialType(oTemplate))))));
    _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(57420+0x01000000) + IntToString(_prc_inc_shifting_ShifterLevelRequirement(oTemplate))); //"Required Shifter Level: "
    _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(57421+0x01000000) + IntToString(_prc_inc_shifting_CharacterLevelRequirement(oTemplate))); //"Required Character Level: "
    _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(57436+0x01000000) + FloatToString(GetChallengeRating(oTemplate), 4, 1)); //"Challenge Rating: "

    _prc_inc_PrintShapeInfo(oPC, "==========");

    _prc_inc_PrintClassInfo("=== ", oPC, oTemplate, GetClassByPosition(1, oTemplate));
    _prc_inc_PrintClassInfo("=== ", oPC, oTemplate, GetClassByPosition(2, oTemplate));
    _prc_inc_PrintClassInfo("=== ", oPC, oTemplate, GetClassByPosition(3, oTemplate));
    _prc_inc_PrintClassInfo("=== ", oPC, oTemplate, GetClassByPosition(4, oTemplate));
    _prc_inc_PrintClassInfo("=== ", oPC, oTemplate, GetClassByPosition(5, oTemplate));
    _prc_inc_PrintClassInfo("=== ", oPC, oTemplate, GetClassByPosition(6, oTemplate));
    _prc_inc_PrintClassInfo("=== ", oPC, oTemplate, GetClassByPosition(7, oTemplate));
    _prc_inc_PrintClassInfo("=== ", oPC, oTemplate, GetClassByPosition(8, oTemplate));
	
    _prc_inc_PrintShapeInfo(oPC, "==========");

    //Harmlessly invisible?

    if(_prc_inc_shifting_GetIsCreatureHarmless(oTemplate))
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(57424+0x01000000)); //"Harmlessly Invisible"
        
    //Able to cast spells without Natural Spell?

    if(!_prc_inc_shifting_GetCanFormCast(oTemplate) && !GetHasFeat(FEAT_PRESTIGE_SHIFTER_NATURALSPELL, oTemplate))
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(57477+0x01000000)); //"Cannot cast spells"
    else
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(57476+0x01000000)); //"Can cast spells"

    //Natural AC

    _prc_inc_PrintNaturalAC(oPC, oTemplate);

    //STR, DEX, CON
    
    struct _prc_inc_ability_info_struct rInfoStruct = _prc_inc_shifter_GetAbilityInfo(oTemplate, oPC);

    //Extra information related to STR, DEX, CON

    string sExtra, sBonusOrPenalty = GetStringByStrRef(57427+0x01000000);
    sExtra = " (" + sBonusOrPenalty + (rInfoStruct.nDeltaSTR>=0?"+":"") + IntToString(rInfoStruct.nDeltaSTR) + ")";
    _prc_inc_PrintShapeInfo(oPC, "=== " + _prc_inc_AbilityTypeString(0) + " " + IntToString(rInfoStruct.nTemplateSTR) + sExtra);
    sExtra = " (" + sBonusOrPenalty + (rInfoStruct.nDeltaDEX>=0?"+":"") + IntToString(rInfoStruct.nDeltaDEX) + ")";
    _prc_inc_PrintShapeInfo(oPC, "=== " + _prc_inc_AbilityTypeString(1) + " " + IntToString(rInfoStruct.nTemplateDEX) + sExtra);
    sExtra = " (" + sBonusOrPenalty + (rInfoStruct.nDeltaCON>=0?"+":"") + IntToString(rInfoStruct.nDeltaCON) + ")";
    _prc_inc_PrintShapeInfo(oPC, "=== " + _prc_inc_AbilityTypeString(2) + " " + IntToString(rInfoStruct.nTemplateCON) + sExtra);    

    _prc_inc_PrintShapeInfo(oPC, "------");

    int i = 0;
    string sSkillName;
    string sSTRBasedSkills, sDEXBasedSkills, sCONBasedSkills;
    while((sSkillName = Get2DACache("skills", "Name", i)) != "")
    {
        sSkillName = GetStringByStrRef(StringToInt(sSkillName));
        string sSkillKeyAbility = Get2DACache("skills", "KeyAbility", i);
        if (sSkillKeyAbility == "STR")
            sSTRBasedSkills += sSkillName + ", ";
        else if (sSkillKeyAbility == "DEX")
            sDEXBasedSkills += sSkillName + ", ";
        else if (sSkillKeyAbility == "CON")
            sCONBasedSkills += sSkillName + ", ";
        i += 1;
    }
    if (GetStringLength(sSTRBasedSkills))
        sSTRBasedSkills = GetStringLeft(sSTRBasedSkills, GetStringLength(sSTRBasedSkills) - 2); //Remove the final ", "
    if (GetStringLength(sDEXBasedSkills))
        sDEXBasedSkills = GetStringLeft(sDEXBasedSkills, GetStringLength(sDEXBasedSkills) - 2); //Remove the final ", "
    if (GetStringLength(sCONBasedSkills))
        sCONBasedSkills = GetStringLeft(sCONBasedSkills, GetStringLength(sCONBasedSkills) - 2); //Remove the final ", "

    int nSTRBonus = rInfoStruct.nExtraSTR / 2;
    if (nSTRBonus > 0)
    {
        //TODO: cap AB bonus
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60544+0x01000000) + " +" + IntToString(nSTRBonus)); //Attack increase from STR increase
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60546+0x01000000) + " +" + IntToString(nSTRBonus)); //Damage increase from STR increase
        _prc_inc_PrintShapeInfo(oPC, "=== " + ReplaceString(GetStringByStrRef(60528+0x01000000), "%(SKILLS)", sSTRBasedSkills) + " +" + IntToString(nSTRBonus)); //Skill bonus from STR increase
    }
    else if (nSTRBonus < 0)
    {
        //TODO: cap AB penalty--at what?
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60545+0x01000000) + " " + IntToString(nSTRBonus)); //Attack decrease from STR decrease
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60547+0x01000000) + " " + IntToString(nSTRBonus)); //Damage decrease from STR decrease
        _prc_inc_PrintShapeInfo(oPC, "=== " + ReplaceString(GetStringByStrRef(60529+0x01000000), "%(SKILLS)", sSTRBasedSkills) + " " + IntToString(nSTRBonus)); //Skill penalty from STR decrease
    }

    int nDEXBonus = rInfoStruct.nExtraDEX / 2;
    if (nDEXBonus > 0)
    {
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60548+0x01000000) + " +" + IntToString(nDEXBonus)); //AC increase from DEX increase
        _prc_inc_PrintShapeInfo(oPC, "=== " + ReplaceString(GetStringByStrRef(60530+0x01000000), "%(SKILLS)", sDEXBasedSkills) + " +" + IntToString(nDEXBonus)); //Skill bonus from DEX increase
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60531+0x01000000) + " +" + IntToString(nDEXBonus)); //Saving throw bonus from DEX increase
    }
    else if (nDEXBonus < 0)
    {
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60549+0x01000000) + " " + IntToString(nDEXBonus)); //AC decrease from DEX increase
        _prc_inc_PrintShapeInfo(oPC, "=== " + ReplaceString(GetStringByStrRef(60532+0x01000000), "%(SKILLS)", sDEXBasedSkills) + " " + IntToString(nDEXBonus)); //Skill penalty from DEX decrease
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60533+0x01000000) + " " + IntToString(nDEXBonus)); //Saving throw penalty from DEX decrease
    }

    int nCONBonus = rInfoStruct.nExtraCON / 2;
    if (nCONBonus > 0)
    {
        _prc_inc_PrintShapeInfo(oPC, "=== " + ReplaceString(GetStringByStrRef(60534+0x01000000), "%(SKILLS)", sCONBasedSkills) + " +" + IntToString(nCONBonus)); //Skill bonus from CON increase
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60535+0x01000000) + " +" + IntToString(nCONBonus)); //Saving throw bonus from CON increase
        int tempHP = rInfoStruct.nExtraCON * GetHitDice(oPC);
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(57431+0x01000000) + " " + IntToString(tempHP)); //Temporary HP from CON increase
    }
    else if (nCONBonus < 0)
    {
        _prc_inc_PrintShapeInfo(oPC, "=== " + ReplaceString(GetStringByStrRef(60536+0x01000000), "%(SKILLS)", sCONBasedSkills) + " " + IntToString(nCONBonus)); //Skill penalty from CON decrease
        _prc_inc_PrintShapeInfo(oPC, "=== " + GetStringByStrRef(60537+0x01000000) + " " + IntToString(nCONBonus)); //Saving throw penalty from CON decrease
    }

    _prc_inc_PrintShapeInfo(oPC, "==========");
        
    //Hide and creature weapon properties

    object oTemplateCWpR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTemplate);
    object oTemplateCWpL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTemplate);
    object oTemplateCWpB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTemplate);
    object oTemplateHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTemplate);

    if(GetIsObjectValid(oTemplateCWpR))
    {
        string sPrefix = GetStringByStrRef(57432+0x01000000); //"Right Creature Weapon:"
        _prc_inc_PrintShapeInfo(oPC, "=== " + sPrefix);
        _prc_inc_PrintAllItemProperties("===    ", oPC, oTemplateCWpR);
    }

    if(GetIsObjectValid(oTemplateCWpL))
    {
        string sPrefix = GetStringByStrRef(57433+0x01000000); //"Left Creature Weapon:"
        _prc_inc_PrintShapeInfo(oPC, "=== " + sPrefix);
        _prc_inc_PrintAllItemProperties("===    ", oPC, oTemplateCWpL);
    }

    if(GetIsObjectValid(oTemplateCWpB))
    {
        string sPrefix = GetStringByStrRef(57434+0x01000000); //"Special Attack Creature Weapon:"
        _prc_inc_PrintShapeInfo(oPC, "=== " + sPrefix);
        _prc_inc_PrintAllItemProperties("===    ", oPC, oTemplateCWpB);
    }

    if(GetIsObjectValid(oTemplateHide))
        _prc_inc_PrintAllItemProperties("=== ", oPC, oTemplateHide);
        
    //Spell-like abilities
        
    _prc_inc_shifting_PrintShifterActiveAbilities(oPC, oTemplate);
    
    //Feats

    i = 0;
    string sFeat;
    int CHUNK_SIZE = 25; //50 was too big, so use 25

    while((sFeat = Get2DACache("shifter_feats", "Feat", i)) != "")
    {
        DelayCommand(0.0f, _prc_inc_shifting_PrintFeats(oPC, oTemplate, i, i+CHUNK_SIZE));
        i += CHUNK_SIZE;
    }
    DelayCommand(0.0f, _prc_inc_PrintShapeInfo(oPC, "================================================="));

    if (bForceLogPrint)
        DelayCommand(0.1, SetLocalInt(oPC, "PRC_EnableLogPrint", nSaveValue));

    if (GetLocalInt(oPC, "prc_shift_debug"))
        DelayCommand(0.2f, _prc_inc_ShapePrintDebug(oPC, oTemplate, bForceLogPrint));
}
