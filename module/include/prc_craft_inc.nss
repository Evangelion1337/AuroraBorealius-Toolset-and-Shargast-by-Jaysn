/*
    prc_craft_include

    Include file for forge scripts, currently restricted to equipable items

    By: Flaming_Sword
    Created: Jul 12, 2006
    Modified: Nov 5, 2007

    GetItemPropertySubType() returns 0 or 65535, not -1
        on no subtype as in Lexicon

    Some hardcoded functions for itemprops to avoid looping through
        the 2das multiple times:

        Get2DALineFromItemprop()
        DisallowType()
        PrereqSpecialHandling()
        PropSpecialHandling()

*/

itemproperty ConstructIP(int nType, int nSubTypeValue = 0, int nCostTableValue = 0, int nParam1Value = 0);

//Partly ripped off the lexicon :P
int GetItemBaseAC(object oItem);

int GetItemArmourCheckPenalty(object oItem);

int GetCraftingFeat(object oItem);

string GetItemPropertyString(itemproperty ip);

struct ipstruct GetIpStructFromString(string sIp);

#include "psi_inc_psifunc"

//#include "prc_inc_spells"		//Most core functions are
								//accessd through psi_inc_core
//#include "prc_inc_listener"
#include "prc_inc_chat"
#include "prc_x2_craft"
#include "prc_inc_material"

const int NUM_MAX_PROPERTIES            = 200;
const int NUM_MAX_SUBTYPES              = 256;
//const int NUM_MAX_FEAT_SUBTYPES         = 16384;    //because iprp_feats is frickin' huge
const int NUM_MAX_FEAT_SUBTYPES         = 397;      //because the above screwed the game

//const int NUM_MAX_SPELL_SUBTYPES        = 540;      //restricted to bioware spells
                                                    //  to avoid crashes
const int NUM_MAX_SPELL_SUBTYPES        = 1172;     //new value for list skipping

const int PRC_CRAFT_SIMPLE_WEAPON       = 1;
const int PRC_CRAFT_MARTIAL_WEAPON      = 2;
const int PRC_CRAFT_EXOTIC_WEAPON       = 3;

const int PRC_CRAFT_MATERIAL_METAL      = 1;
const int PRC_CRAFT_MATERIAL_WOOD       = 2;
const int PRC_CRAFT_MATERIAL_LEATHER    = 3;
const int PRC_CRAFT_MATERIAL_CLOTH      = 4;

const string PRC_CRAFT_UID_SUFFIX       = "_UID_PRC";
const string PRC_CRAFT_STORAGE_CHEST    = "PRC_CRAFT_STORAGE_CHEST";
const string PRC_CRAFT_TEMPORARY_CHEST  = "PRC_CRAFT_TEMPORARY_CHEST";
const string PRC_CRAFT_ITEMPROP_ARRAY   = "PRC_CRAFT_ITEMPROP_ARRAY";

const int PRC_CRAFT_FLAG_NONE               = 0;
const int PRC_CRAFT_FLAG_MASTERWORK         = 1;
const int PRC_CRAFT_FLAG_ADAMANTINE         = 2;
const int PRC_CRAFT_FLAG_DARKWOOD           = 4;
const int PRC_CRAFT_FLAG_DRAGONHIDE         = 8;
const int PRC_CRAFT_FLAG_MITHRAL            = 16;
const int PRC_CRAFT_FLAG_COLD_IRON          = 32;   //not implemented
const int PRC_CRAFT_FLAG_ALCHEMICAL_SILVER  = 64;   //not implemented
const int PRC_CRAFT_FLAG_MUNDANE_CRYSTAL    = 128;
const int PRC_CRAFT_FLAG_DEEP_CRYSTAL       = 256;

const int PRC_CRAFT_ITEM_TYPE_WEAPON        = 1;
const int PRC_CRAFT_ITEM_TYPE_ARMOUR        = 2;
const int PRC_CRAFT_ITEM_TYPE_SHIELD        = 3;
const int PRC_CRAFT_ITEM_TYPE_AMMO          = 4;
const int PRC_CRAFT_ITEM_TYPE_MISC          = 5;
const int PRC_CRAFT_ITEM_TYPE_CASTSPELL     = 6;
const int PRC_CRAFT_ITEM_TYPE_SPECIAL       = 7;

const string PRC_CRAFT_SPECIAL_BANE         = "PRC_CRAFT_SPECIAL_BANE";
const string PRC_CRAFT_SPECIAL_BANE_RACE    = "PRC_CRAFT_SPECIAL_BANE_RACE";

const string PRC_CRAFT_LISTEN               = "PRC_CRAFT_LISTEN";

const string PRC_CRAFT_APPEARANCE_ARRAY     = "PRC_CRAFT_APPEARANCE_ARRAY";
const string PRC_IP_ARRAY                   = "PRC_IP_ARRAY";

const int PRC_CRAFT_LISTEN_SETNAME          = 1;
const int PRC_CRAFT_LISTEN_SETAPPEARANCE    = 2;
/*
const int PRC_CRAFT_LISTEN_SETNAME          = 1;
const int PRC_CRAFT_LISTEN_SETNAME          = 1;
const int PRC_CRAFT_LISTEN_SETNAME          = 1;
const int PRC_CRAFT_LISTEN_SETNAME          = 1;
const int PRC_CRAFT_LISTEN_SETNAME          = 1;
*/

const string PRC_CRAFT_TOKEN                = "PRC_CRAFT_TOKEN";

const int CRAFT_COST_TYPE_INVALID           = 0;
const int CRAFT_COST_TYPE_MARKET            = 1;
const int CRAFT_COST_TYPE_CRAFTING          = 2;
const int CRAFT_COST_TYPE_XP                = 3;

struct itemvars
{
    object item;
    int enhancement;
    int additionalcost;
    int epic;
};

struct ipstruct
{
    int type;
    int subtype;
    int costtablevalue;
    int param1value;
};

struct golemhds
{
    int base;
    int max1;
    int max2;
};

object GetCraftChest()
{
    return GetObjectByTag(PRC_CRAFT_STORAGE_CHEST);
}

object GetTempCraftChest()
{
    return GetObjectByTag(PRC_CRAFT_TEMPORARY_CHEST);
}

int GetCraftingSkill(object oItem)
{
    int nType = StringToInt(Get2DACache("prc_craft_gen_it", "Type", GetBaseItemType(oItem)));
    if((nType == PRC_CRAFT_ITEM_TYPE_WEAPON) ||
        (nType == PRC_CRAFT_ITEM_TYPE_AMMO)
        )
        return SKILL_CRAFT_WEAPON;
    if((nType == PRC_CRAFT_ITEM_TYPE_ARMOUR) ||
        (nType == PRC_CRAFT_ITEM_TYPE_SHIELD)
        )
        return SKILL_CRAFT_ARMOR;
    return SKILL_CRAFT_GENERAL;
}

string GetMaterialString(int nType)
{
    string sType = IntToString(nType);
    int nLen = GetStringLength(sType);
    switch(nLen)
    {
        case 1: sType = "0" + sType;
        case 2: sType = "0" + sType; break;
    }
    return sType;
}

//Will replace first 3 chars of item's tag with material flags
string GetNewItemTag(object oItem, int nType)
{
    string sTag = GetTag(oItem);
    return GetMaterialString(nType) + GetStringRight(sTag, GetStringLength(sTag) - 3);
}

int GetArmourCheckPenaltyReduction(object oItem)
{
    int nBase = GetBaseItemType(oItem);
    int nBonus = 0;
    if(((nBase == BASE_ITEM_ARMOR) ||
        (nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD))
        )
    {
        int nMaterial = StringToInt(GetStringLeft(GetTag(oItem), 3));
        int nACPenalty = GetItemArmourCheckPenalty(oItem);
        if(nMaterial & PRC_CRAFT_FLAG_MASTERWORK)
        {
            nBonus = PRCMin(1, nACPenalty);
        }
        if(nMaterial & PRC_CRAFT_FLAG_DARKWOOD)
        {
            nBonus = PRCMin(2, nACPenalty);
        }
        if(nMaterial & PRC_CRAFT_FLAG_MITHRAL)
        {
            nBonus = PRCMin(3, nACPenalty);
        }
    }
    return nBonus;
}

int SkillHasACPenalty(int nSkill)
{
    return StringToInt(Get2DACache("skills", "ArmorCheckPenalty", nSkill));
}

//Returns -1 if itemprop is not in the list, -2 if similar and should disallow type,
//  hardcoded to avoid looping through 2das
int Get2DALineFromItemprop(string sFile, itemproperty ip, object oItem)
{   //it's either hardcoding or large numbers of 2da reads
    int nType = GetItemPropertyType(ip);
    int nSubType = GetItemPropertySubType(ip);
    int nCostTableValue = GetItemPropertyCostTableValue(ip);
    int nParam1Value = GetItemPropertyParam1Value(ip);
    int nBase = GetBaseItemType(oItem);
    if(sFile == "craft_armour")
    {
        switch(nType)
        {
            case ITEM_PROPERTY_AC_BONUS:
            {
                return (nCostTableValue - 1);
                break;
            }
            case ITEM_PROPERTY_BONUS_FEAT:
            {
                if(nSubType == 201) return 24;
                break;
            }
            case ITEM_PROPERTY_CAST_SPELL:
            {
                switch(nSubType)
                {
                    case IP_CONST_CASTSPELL_CONTROL_UNDEAD_13: return 63; break;
                    case IP_CONST_CASTSPELL_ETHEREALNESS_18: return 33; break;
                    case 928: return (GetItemPropertyCostTableValue(ip) == IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY) ? 43 : 44; break; //spell turning
                }
                break;
            }
            case ITEM_PROPERTY_DAMAGE_REDUCTION:
            {
                if(nSubType == IP_CONST_DAMAGEREDUCTION_1)
                {
                    switch(nCostTableValue)
                    {
                        case IP_CONST_DAMAGESOAK_5_HP: return 38; break;
                        case IP_CONST_DAMAGESOAK_10_HP: return 39; break;
                        case IP_CONST_DAMAGESOAK_15_HP: return 40; break;
                        default: return -2; break;
                    }
                }
                else if(nSubType == IP_CONST_DAMAGEREDUCTION_6)
                {
                    switch(nCostTableValue)
                    {
                        case IP_CONST_DAMAGESOAK_5_HP: return 41; break;
                        case IP_CONST_DAMAGESOAK_10_HP: return 42; break;
                        default: return -2; break;
                    }
                }
                else return -2;
                break;
            }
            case ITEM_PROPERTY_DAMAGE_RESISTANCE:
            {
                int nBaseValue = -1;
                switch(nSubType)
                {
                    case IP_CONST_DAMAGETYPE_ACID: nBaseValue = 20; break;
                    case IP_CONST_DAMAGETYPE_COLD: nBaseValue = 25; break;
                    case IP_CONST_DAMAGETYPE_ELECTRICAL: nBaseValue = 29; break;
                    case IP_CONST_DAMAGETYPE_FIRE: nBaseValue = 34; break;
                    case IP_CONST_DAMAGETYPE_SONIC: nBaseValue = 51; break;
                }
                if(nBaseValue != -1)
                {
                    switch(nCostTableValue)
                    {
                        case IP_CONST_DAMAGERESIST_10: return nBaseValue; break;
                        case IP_CONST_DAMAGERESIST_20: return nBaseValue + 1; break;
                        case IP_CONST_DAMAGERESIST_30: return nBaseValue + 2; break;
                        case IP_CONST_DAMAGERESIST_50: return nBaseValue + 3; break;
                        default: return -2; break;
                    }
                }
                else return -2;
                break;
            }
            case ITEM_PROPERTY_SPELL_RESISTANCE:
            {
                if((nCostTableValue >= 27) && (nCostTableValue <= 34)) return (nCostTableValue + 28);
                else return -2;
                break;
            }
            case ITEM_PROPERTY_SKILL_BONUS:
            {
                if(nSubType == SKILL_HIDE)
                {
                    nCostTableValue -= GetArmourCheckPenaltyReduction(oItem);
                    switch(nCostTableValue)
                    {
                        case 5: return 49; break;
                        case 10: return 50; break;
                        case 15: return 51; break;
                        default: return -1; break;
                    }
                }
                else if(nSubType == SKILL_MOVE_SILENTLY)
                {
                    nCostTableValue -= GetArmourCheckPenaltyReduction(oItem);
                    switch(nCostTableValue)
                    {
                        case 5: return 52; break;
                        case 10: return 53; break;
                        case 15: return 54; break;
                        default: return -1; break;
                    }
                }
                else
                    return -2;
                break;
            }
        }
    }
    else if(sFile == "craft_weapon")
    {
        switch(nType)
        {
            case ITEM_PROPERTY_ENHANCEMENT_BONUS:
            {
                return (nCostTableValue - 1);
                break;
            }
            case ITEM_PROPERTY_DAMAGE_BONUS:
            {
                int bAmmo = StringToInt(Get2DACache("prc_craft_gen_it", "Type", GetBaseItemType(oItem))) == PRC_CRAFT_ITEM_TYPE_AMMO;
                if(bAmmo && nSubType == ((nBase == BASE_ITEM_BULLET) ? DAMAGE_TYPE_BLUDGEONING : DAMAGE_TYPE_PIERCING))
                    return (nCostTableValue - 1);
                if(nSubType == IP_CONST_DAMAGETYPE_ACID)
                {
                    if(nCostTableValue == IP_CONST_DAMAGEBONUS_1d6) return 20; //Corrosive
					else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 21; //Acidic blast
					else return -2;
                }
                else if(nSubType == IP_CONST_DAMAGETYPE_FIRE)
                {
                    if(nCostTableValue == IP_CONST_DAMAGEBONUS_1d6) return 30;  //Flaming
                    else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 31;  //Flaming blast
                    else return -2;
                }
                else if(nSubType == IP_CONST_DAMAGETYPE_COLD)
                {
                    if(nCostTableValue == IP_CONST_DAMAGEBONUS_1d6) return 32; //Frost
                    else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 33; //Icy Blast
                    else return -2;
                }
                else if(nSubType == IP_CONST_DAMAGETYPE_ELECTRICAL)
                {
                    if(nCostTableValue == IP_CONST_DAMAGEBONUS_1d6) return 37; //Shock
                    else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 38; // Lightning Blast
                    else return -2;
                }
                else if(nSubType == IP_CONST_DAMAGETYPE_SONIC)
                {
					if(nCostTableValue == IP_CONST_DAMAGEBONUS_1d4) return 39; //Screaming
                    else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 40; //Sonic Blast
                    else return -2;
                }
				else if(nSubType == IP_CONST_DAMAGETYPE_MAGICAL)
                {
					if(nCostTableValue == IP_CONST_DAMAGEBONUS_1d4) return 45; //Psychokinetic
                    else return -2;
                }
				
                else return -2;
                break;
            }
            case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP:
            {
                switch(nSubType)
                {
                    case IP_CONST_ALIGNMENTGROUP_LAWFUL:
                    {
                        if(nCostTableValue == IP_CONST_DAMAGEBONUS_2d6) return 22; // Anarchic
                        else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 23; // Anarchic Power
                        else return -2;
                        break;
                    }
                    case IP_CONST_ALIGNMENTGROUP_CHAOTIC:
                    {
                        if(nCostTableValue == IP_CONST_DAMAGEBONUS_2d6) return 24; // Axiomatic
                        else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 25; // Axiomatic Power
                        else return -2;
                        break;
                    }
                    case IP_CONST_ALIGNMENTGROUP_EVIL:
                    {
                        if(nCostTableValue == IP_CONST_DAMAGEBONUS_2d6) return 34; //Holy
                        else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 35; // Holy Power
                        else return -2;
                        break;
                    }
                    case IP_CONST_ALIGNMENTGROUP_GOOD:
                    {
                        if(nCostTableValue == IP_CONST_DAMAGEBONUS_2d6) return 41; //Unholy
                        else if(nCostTableValue == IP_CONST_DAMAGEBONUS_3d6) return 42; //Unholy Power
                        else return -2;
                        break;
                    }
                    default: return -2; break;
                }
                break;
            }
            case ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP:
            {
                switch(nCostTableValue)
                {
                    case IP_CONST_DAMAGEBONUS_2d6: return 26; break; //Bane 
                    case IP_CONST_DAMAGEBONUS_4d6: return 27; break; //Dread
                    default: return -2; break;
                }
                break;
            }
            case ITEM_PROPERTY_KEEN: return 36; break; //Keen
            case ITEM_PROPERTY_ON_HIT_PROPERTIES: 
            {
                switch(nSubType)
                {
                    case IP_CONST_ONHIT_SLAYRACE:
                    {
                        if(nParam1Value == IP_CONST_RACIALTYPE_UNDEAD)
                        {
                            if(nCostTableValue == IP_CONST_ONHIT_SAVEDC_14) return 28; //Disruption
                            else if(nCostTableValue == 21) return 29;  //Mighty Disruption
                            else return -2;
                        }
                        break;
                    }
                    case IP_CONST_ONHIT_VORPAL: return 43; break; //Vorpal
                    case IP_CONST_ONHIT_WOUNDING: return 44; break; //Wounding
                }
                break;
            }
			case ITEM_PROPERTY_ECHOBLADE: return 46; break;
        }
    }
    return -1;
}

//Hardcoded properties to disallow, avoids many loops through 2das
void DisallowType(object oItem, string sFile, itemproperty ip)
{
    int i;
    int nType = GetItemPropertyType(ip);
    int nSubType = GetItemPropertySubType(ip);
    int nCostTableValue = GetItemPropertyCostTableValue(ip);
    int nParam1Value = GetItemPropertyParam1Value(ip);
    if(sFile == "craft_armour")
    {
        switch(nType)
        {
            /*
            case ITEM_PROPERTY_AC_BONUS:
            {
            }
            case ITEM_PROPERTY_BONUS_FEAT:
            {
            }
            case ITEM_PROPERTY_CAST_SPELL:
            {
            }
            */
            case ITEM_PROPERTY_DAMAGE_REDUCTION:
            {
                for(i = 38; i <= 42; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                break;
            }
            case ITEM_PROPERTY_DAMAGE_RESISTANCE:
            {
                for(i = 20; i <= 23; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                for(i = 25; i <= 32; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                for(i = 34; i <= 37; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                for(i = 51; i <= 54; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                break;
            }
            case ITEM_PROPERTY_SPELL_RESISTANCE:
            {
                for(i = 55; i <= 62; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                break;
            }
            case ITEM_PROPERTY_SKILL_BONUS:
            {
                for(i = 45; i <= 50; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                break;
            }
        }
    }
    else if(sFile == "craft_weapon")
    {
        switch(nType)
        {
            /*
            case ITEM_PROPERTY_ENHANCEMENT_BONUS:
            {
            }
            */
            case ITEM_PROPERTY_DAMAGE_BONUS:
            {
                array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 20, 0);
                for(i = 29; i <= 32; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                for(i = 36; i <= 38; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                break;
            }
            case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP:
            {
                for(i = 22; i <= 25; i++)
                    array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
                array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 34, 0);
                array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 35, 0);
                array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 41, 0);
                array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 42, 0);
                break;
            }
            case ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP:
            {
                array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 25, 0);
                array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 26, 0);
                break;
            }
            //case ITEM_PROPERTY_KEEN: array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 36, 0); break;
            case ITEM_PROPERTY_ON_HIT_PROPERTIES:
            {
                switch(nSubType)
                {
                    case IP_CONST_ONHIT_SLAYRACE:
                    {
                        if(nParam1Value == IP_CONST_RACIALTYPE_UNDEAD)
                        {
                            array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 28, 0);
                            array_set_int(oItem, PRC_CRAFT_ITEMPROP_ARRAY, 29, 0);
                        }
                        break;
                    }
                    /*
                    case IP_CONST_ONHIT_VORPAL: return 43; break;
                    case IP_CONST_ONHIT_WOUNDING: return 44; break;
                    */
                }
                break;
            }
        }
    }
}

//hardcoding of some prereqs
int PrereqSpecialHandling(string sFile, object oItem, int nLine)
{
    int nTemp;
    int nBase = GetBaseItemType(oItem);
    if(StringToInt(Get2DACache(sFile, "Special", nLine)))
    {
        if(sFile == "craft_armour")
        {   //nothing here yet
        }
        else if(sFile == "craft_weapon")
        {
            int nDamageType = StringToInt(Get2DACache("baseitems", "WeaponType", nBase));
            int bRangedType = StringToInt(Get2DACache("baseitems", "RangedWeapon", nBase));
            int bRanged = bRangedType;// && (bRangedType != nBase);
            switch(nLine)
            {
                case 28:
                case 29:
                {
                    return (!bRanged && ((nDamageType == 2) || (nDamageType == 5)));
                    break;
                }
                case 36:
                {
                    return (!bRanged && (nDamageType != 2));
                    break;
                }
                case 43:
                {
                    return (!bRanged && ((nDamageType == 3) || (nDamageType == 4)));
                    break;
                }
            }
        }
        else if(sFile == "craft_wondrous")
        {
        }
        else if(sFile == "craft_golem")
        {
        }
    }
    if(sFile == "craft_wondrous")
        return nBase == StringToInt(Get2DACache(sFile, "BaseItem", nLine));
    return TRUE;
}

//Checks and decrements spells based on property to add
int CheckCraftingSpells(object oPC, string sFile, int nLine, int bDecrement = FALSE)
{
    if(GetLevelByClass(CLASS_TYPE_ARTIFICER, oPC)) return TRUE;      //artificers roll UMD checks during crafting time
    //if(GetLevelByClass(CLASS_TYPE_BATTLESMITH, oPC)) return TRUE;
    if(nLine == -1) return FALSE;
    string sTemp = Get2DACache(sFile, "Spells", nLine);
    if(sTemp == "")
        return TRUE;    //no prereqs, always true
    int nSpellPattern = 0;
    int nSpell1, nSpell2, nSpell3, nSpellOR1, nSpellOR2, nSpellOR3;
    int bOR = FALSE;
    string sSub;
    int nLength = GetStringLength(sTemp);
    int nPosition;
    int nTemp;
    int i;

    for(i = 0; i < 7; i++)
    {
        nPosition = FindSubString(sTemp, "_");
        sSub = (nPosition == -1) ? sTemp : GetStringLeft(sTemp, nPosition);
        nLength -= (nPosition + 1);
        if(sSub != "*")
        {
            nTemp = StringToInt(sSub);
            nSpellPattern += FloatToInt(pow(2.0, IntToFloat(i)));
            switch(i)
            {
                case 0:
                {
                    nSpell1 = nTemp;
                    break;
                }
                case 1:
                {
                    nSpell2 = nTemp;
                    break;
                }
                case 2:
                {
                    nSpell3 = nTemp;
                    break;
                }
                case 3:
                {
                    nSpellOR1 = nTemp;
                    break;
                }
                case 4:
                {
                    nSpellOR2 = nTemp;
                    break;
                }
				case 6:
                {
                    nSpellOR3 = nTemp;
                    break;
                }
            }
        }
        sTemp = GetSubString(sTemp, nPosition + 1, nLength);
    }

    if (nSpellPattern)
    {
        // ... Existing code for nSpellPattern & 1
        
        if (nSpellPattern & 2)
        {
            if (!PRCGetHasSpell(nSpell2, oPC))
            {
                if (!CheckImbueItem(oPC, nSpell2))
                    return FALSE;
            }
        }
        
        if (nSpellPattern & 4)
        {
            if (!PRCGetHasSpell(nSpell3, oPC))
            {
                if (!CheckImbueItem(oPC, nSpell3))
                    return FALSE;
            }
        }
        
        if (nSpellPattern & 8)
        {
            if (!PRCGetHasSpell(nSpellOR1, oPC))
            {
                if (!CheckImbueItem(oPC, nSpellOR1))
                {
                    if (nSpellPattern & 16)
                    {
                        if (!PRCGetHasSpell(nSpellOR2, oPC))
                        {
                            // Warlocks don't get two bites at things.
                            // if (!CheckImbueItem(oPC, nSpellOR2))
                            return FALSE;
                        }
                    }
                    else if (nSpellPattern & 32)  // Check for nSpellOR3
                    {
                        if (!PRCGetHasSpell(nSpellOR3, oPC))
                        {
                            // Handle nSpellOR3 missing
                            return FALSE;
                        }
                    }
                    else
                        return FALSE;
                }
            }
        }
        else if (nSpellPattern & 16)
        {
            if (!PRCGetHasSpell(nSpellOR2, oPC))
            {
                if (!CheckImbueItem(oPC, nSpellOR2))
                    return FALSE;
            }
            // Check for nSpellOR3
            else if (nSpellPattern & 32)
            {
                if (!PRCGetHasSpell(nSpellOR3, oPC))
                {
                    // Handle nSpellOR3 missing
                    return FALSE;
                }
            }
        }
        else if (nSpellPattern & 32)  // Check for nSpellOR3 alone
        {
            if (!PRCGetHasSpell(nSpellOR3, oPC))
            {
                // Handle nSpellOR3 missing
                return FALSE;
            }
        }
        
        // ... Existing code for decrementing spells
        
    }
    
    return TRUE;
}
/*     if(nSpellPattern)
    {
        if(nSpellPattern & 1)
        {
            if(sFile == "craft_wondrous")
            {
                switch(nLine)
                {
                    case 85:
                    {
                        bOR = (PRCGetHasSpell(SPELL_DETECT_UNDEAD, oPC) &&
                                PRCGetHasSpell(SPELL_FIREBALL, oPC) &&
                                PRCGetHasSpell(SPELL_FLAME_WEAPON, oPC) &&
                                PRCGetHasSpell(SPELL_LIGHT, oPC) &&
                                PRCGetHasSpell(SPELL_PRISMATIC_SPRAY, oPC) &&
                                PRCGetHasSpell(SPELL_PROTECTION_FROM_ELEMENTS, oPC) &&
                                PRCGetHasSpell(SPELL_WALL_OF_FIRE, oPC));
                        if(GetHasFeat(FEAT_IMBUE_ITEM) && bOR == FALSE)
                            bOR = GetIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 16) &&
                                  GetIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 18) &&
                                  GetIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 17) &&
                                  GetIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 16) &&
                                  GetIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 22) &&
                                  GetIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 18) &&
                                  GetIsSkillSuccessful(oPC, SKILL_USE_MAGIC_DEVICE, 19);
                        if(bDecrement)
                        {
                            PRCDecrementRemainingSpellUses(oPC, SPELL_DETECT_UNDEAD);
                            PRCDecrementRemainingSpellUses(oPC, SPELL_FIREBALL);
                            PRCDecrementRemainingSpellUses(oPC, SPELL_FLAME_WEAPON);
                            PRCDecrementRemainingSpellUses(oPC, SPELL_LIGHT);
                            PRCDecrementRemainingSpellUses(oPC, SPELL_PRISMATIC_SPRAY);
                            PRCDecrementRemainingSpellUses(oPC, SPELL_PROTECTION_FROM_ELEMENTS);
                            PRCDecrementRemainingSpellUses(oPC, SPELL_WALL_OF_FIRE);
                        }
                        return bOR;
                        break;
                    }
                }
            }
            if(!PRCGetHasSpell(nSpell1, oPC))
            {
                if(!CheckImbueItem(oPC, nSpell1))
                    return FALSE;
            }
        }
        if(nSpellPattern & 2)
        {
            if(!PRCGetHasSpell(nSpell2, oPC))
            {
                if(!CheckImbueItem(oPC, nSpell2))
                    return FALSE;
            }
        }
        if(nSpellPattern & 4)
        {
            if(!PRCGetHasSpell(nSpell3, oPC))
            {
                if(!CheckImbueItem(oPC, nSpell3))
                    return FALSE;
            }
        }
        if(nSpellPattern & 8)
        {
            if(!PRCGetHasSpell(nSpellOR1, oPC))
            {
                if(!CheckImbueItem(oPC, nSpellOR1))
                {
                    if(nSpellPattern & 16)
                    {
                        if(!PRCGetHasSpell(nSpellOR2, oPC))
                        {
                        	// Warlocks don't get two bites at things.
                            //if(!CheckImbueItem(oPC, nSpellOR2))
                                return FALSE;
                        }
                    }
                    else
                        return FALSE;
                }
            }
        }
        else if(nSpellPattern & 16)
        {
            if(!PRCGetHasSpell(nSpellOR2, oPC))
            {
                if(!CheckImbueItem(oPC, nSpellOR2))
                    return FALSE;
            }
        }
        if(bDecrement)
        {
            if(nSpellPattern & 1)
                PRCDecrementRemainingSpellUses(oPC, nSpell1);
            if(nSpellPattern & 2)
                PRCDecrementRemainingSpellUses(oPC, nSpell2);
            if(nSpellPattern & 4)
                PRCDecrementRemainingSpellUses(oPC, nSpell3);
            if(nSpellPattern & 8)
                PRCDecrementRemainingSpellUses(oPC, (bOR) ? nSpellOR2 : nSpellOR1);
            else if(nSpellPattern & 16)
                PRCDecrementRemainingSpellUses(oPC, nSpellOR2);
        }
    }
    return TRUE;
} */

//Checks and decrements power points based on property to add
int CheckCraftingPowerPoints(object oPC, string sFile, int nLine, int bDecrement = FALSE)
{
    if(nLine == -1) return FALSE;
    string sTemp = Get2DACache(sFile, "Spells", nLine);
    if(sTemp == "")
        return TRUE;    //no prereqs, always true
    int nSpellPattern = 0;
    int nSpell1, nSpell2, nSpell3, nSpellOR1, nSpellOR2, nSpellOR3;
    int bOR = FALSE;
    string sSub;
    int nLength = GetStringLength(sTemp);
    int nPosition;
    int nTemp;
    int i;
    int nLoss = 0;

    for(i = 0; i < 6; i++)
    {
        nPosition = FindSubString(sTemp, "_");
        sSub = (nPosition == -1) ? sTemp : GetStringLeft(sTemp, nPosition);
        nLength -= (nPosition + 1);
        if(sSub != "*")
        {
            nTemp = StringToInt(sSub);
            nSpellPattern += FloatToInt(pow(2.0, IntToFloat(i)));
            switch(i)
            {
                case 0:
                {
                    nSpell1 = nTemp;
                    break;
                }
                case 1:
                {
                    nSpell2 = nTemp;
                    break;
                }
                case 2:
                {
                    nSpell3 = nTemp;
                    break;
                }
                case 3:
                {
                    nSpellOR1 = nTemp;
                    break;
                }
                case 4:
                {
                    nSpellOR2 = nTemp;
                    break;
                }
                case 6:
                {
                    nSpellOR3 = nTemp;
                    break;
                }				
            }
        }
        sTemp = GetSubString(sTemp, nPosition + 1, nLength);
    }
    if(nSpellPattern)
    {
        if(nSpellPattern & 1)
        {
            if(GetHasPower(nSpell1, oPC))
                nLoss += (StringToInt(lookup_spell_innate(nSpell1)) * 2 - 1);
            else
                return FALSE;
        }
        if(nSpellPattern & 2)
        {
            if(GetHasPower(nSpell2, oPC))
                nLoss += (StringToInt(lookup_spell_innate(nSpell2)) * 2 - 1);
            else
                return FALSE;
        }
        if(nSpellPattern & 4)
        {
            if(GetHasPower(nSpell3, oPC))
                nLoss += (StringToInt(lookup_spell_innate(nSpell3)) * 2 - 1);
            else
                return FALSE;
        }
        if(nSpellPattern & 8)
        {
            if(GetHasPower(nSpellOR1, oPC))
                nLoss += (StringToInt(lookup_spell_innate(nSpellOR1)) * 2 - 1);
            else if(nSpellPattern & 16)
            {
                if(GetHasPower(nSpellOR2, oPC))
                    nLoss += (StringToInt(lookup_spell_innate(nSpellOR2)) * 2 - 1);
                else
                    return FALSE;
            }
            else
                return FALSE;
        }
        else if(nSpellPattern & 16)
        {
            if(GetHasPower(nSpellOR2, oPC))
                nLoss += (StringToInt(lookup_spell_innate(nSpellOR2)) * 2 - 1);
            else
                return FALSE;
        }
    }
    if(GetCurrentPowerPoints(oPC) < nLoss)
        return FALSE;

    if(bDecrement) LosePowerPoints(oPC, nLoss, TRUE);

    return TRUE;
}

int CheckGolemPrereq(object oPC, int nLine, int bEpic)
{
    if(GetLocalInt(oPC, PRC_CRAFT_TOKEN))
        return TRUE;
    int bBreak = FALSE;
    int nLevel;
    int j = 0;
    //replace the arti level check later when PrCs are added
    int nCasterLevel = PRCMax(PRCMax(PRCMax(GetLevelByTypeArcane(oPC), GetLevelByTypeDivine(oPC)), GetLevelByClass(CLASS_TYPE_ARTIFICER, oPC) + 2), GetLocalInt(oPC, "InvokerLevel"));
    int nManifesterLevel = GetManifesterLevel(oPC);
    int nTemp, nLength, nPosition;
    int bArtificer = (GetLevelByClass(CLASS_TYPE_ARTIFICER, oPC) > 0);
    string sFile = "craft_golem";
    string sPropertyType = Get2DACache(sFile, "CasterType", nLine);
    string sTemp, sSub;
    int nDC = StringToInt(Get2DACache(sFile, "DC", nLine));
    if(sPropertyType == "M")
        nLevel = nCasterLevel;
    else if(sPropertyType == "P")
        nLevel = nManifesterLevel;
    else
        nLevel = PRCMax(nCasterLevel, nManifesterLevel);
    if(!bEpic && Get2DACache(sFile, "Epic", nLine) == "1")
        return FALSE;
    else if(nLevel < StringToInt(Get2DACache(sFile, "Level", nLine)))
        return FALSE;
    else
    {
        if(
            (sPropertyType == "M") &&
            !CheckCraftingSpells(oPC, sFile, nLine)
            )
            return FALSE;
        if(
            (sPropertyType == "P") &&
            !CheckCraftingPowerPoints(oPC, sFile, nLine)
            )
            return FALSE;
        sTemp = Get2DACache(sFile, "Skills", nLine);
        if(sTemp == "")
            bBreak = TRUE;
        nLength = GetStringLength(sTemp);
        for(j = 0; j < 2; j++)
        {
            if(bBreak)
                break;
            nPosition = FindSubString(sTemp, "_");
            sSub = (nPosition == -1) ? sTemp : GetStringLeft(sTemp, nPosition);
            nLength -= (nPosition + 1);
            if(sSub == "*")
                nTemp = -1;
            else
                nTemp = StringToInt(sSub);
            if(nTemp != -1 && !bArtificer)
            {
                if(!GetPRCIsSkillSuccessful(oPC, nTemp, nDC))
                    return FALSE;
            }
            sTemp = GetSubString(sTemp, nPosition + 1, nLength);
        }
        sTemp = Get2DACache(sFile, "Skills", nLine);
    }
    return TRUE;
}

int CheckPrereq(object oPC, int nLine, int bEpic, string sFile, struct itemvars strTemp)
{
    if(GetLocalInt(oPC, PRC_CRAFT_TOKEN))
        return TRUE;
    int bBreak = FALSE;
    int nLevel;
    int j = 0;
    //replace the arti level check later when PrCs are added
    int nCasterLevel = PRCMax(PRCMax(PRCMax(GetLevelByTypeArcane(oPC), GetLevelByTypeDivine(oPC)), GetLevelByClass(CLASS_TYPE_ARTIFICER, oPC) + 2), GetLocalInt(oPC, "InvokerLevel"));
    nCasterLevel += GetLevelByClass(CLASS_TYPE_BATTLESMITH) * 3;
    nCasterLevel += GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER) * 3;
    int nManifesterLevel = GetManifesterLevel(oPC);
    int nTemp, nLength, nPosition;
    int bArtificer = (GetLevelByClass(CLASS_TYPE_ARTIFICER, oPC) > 0);
    string sPropertyType = Get2DACache(sFile, "PropertyType", nLine);
    string sTemp, sSub;
    if(sPropertyType == "M")
        nLevel = nCasterLevel;
    else if(sPropertyType == "P")
        nLevel = nManifesterLevel;
    else
        nLevel = PRCMax(nCasterLevel, nManifesterLevel);
        
	if (DEBUG) DoDebug("CheckPrereq: "+GetName(oPC)+" nLevel "+IntToString(nLevel)+" PropType "+sPropertyType+" Epic "+IntToString(bEpic)+" sFile "+sFile);
        
    if(!bEpic && Get2DACache(sFile, "Epic", nLine) == "1")
    {
    	if (DEBUG) DoDebug("CheckPrereq Failed Epic");
        return FALSE;
    }    
    else if(nLevel < StringToInt(Get2DACache(sFile, "Level", nLine)))
    {
    	if (DEBUG) DoDebug("CheckPrereq Failed Level");
        return FALSE;
    }    
    else if(!bEpic && ((StringToInt(Get2DACache(sFile, "Enhancement", nLine)) + strTemp.enhancement) > 10))
    {
    	if (DEBUG) DoDebug("CheckPrereq Failed Enhancement");
        return FALSE;
    }    
    else
    {
        if(
            (sPropertyType == "M") && !CheckCraftingSpells(oPC, sFile, nLine))
            {
            	if (DEBUG) DoDebug("CheckPrereq Failed Crafting Spells");
            	return FALSE;
            }	
        if((sPropertyType == "P") && !CheckCraftingPowerPoints(oPC, sFile, nLine))
        {
        	if (DEBUG) DoDebug("CheckPrereq Failed Crafting Powers");
            return FALSE;
        }    

        sTemp = Get2DACache(sFile, "PrereqMisc", nLine);
        if(sTemp == "")
            bBreak = TRUE;
        nLength = GetStringLength(sTemp);
        for(j = 0; j < 5; j++)
        {
            if(bBreak)
                break;
            nPosition = FindSubString(sTemp, "_");
            sSub = (nPosition == -1) ? sTemp : GetStringLeft(sTemp, nPosition);
            nLength -= (nPosition + 1);
            if(sSub == "*")
                nTemp = -1;
            else
                nTemp = StringToInt(sSub);
            switch(j)
            {
                case 0:
                {
                    if(nTemp != -1 && MyPRCGetRacialType(oPC) != nTemp && !bArtificer)
                    {
                    	if (DEBUG) DoDebug("CheckPrereq Failed Racial Type");
                        return FALSE;
                    }    
                    break;
                }
                case 1:
                {
                    if(nTemp != -1 && !GetHasFeat(nTemp, oPC))  //artificer can't emulate feat requirements
                    {
                    	if (DEBUG) DoDebug("CheckPrereq Failed Feat");
                        return FALSE;
                    }    
                    break;
                }
                case 2:
                {
                    if(((sSub == "G" && GetAlignmentGoodEvil(oPC) != ALIGNMENT_GOOD) ||
                        (sSub == "E" && GetAlignmentGoodEvil(oPC) != ALIGNMENT_EVIL) ||
                        (sSub == "N" && GetAlignmentGoodEvil(oPC) != ALIGNMENT_NEUTRAL)) &&
                        !bArtificer)
                        {
                        	if (DEBUG) DoDebug("CheckPrereq Failed Alignment G/E");
                            return FALSE;
                        }    
                    break;
                }
                case 3:
                {
                    if(((sSub == "L" && GetAlignmentLawChaos(oPC) != ALIGNMENT_LAWFUL) ||
                        (sSub == "C" && GetAlignmentLawChaos(oPC) != ALIGNMENT_CHAOTIC) ||
                        (sSub == "N" && GetAlignmentLawChaos(oPC) != ALIGNMENT_NEUTRAL)) &&
                        !bArtificer)
                        {
                        	if (DEBUG) DoDebug("CheckPrereq Failed Alignment L/C");
                            return FALSE;
                        }    
                    break;
                }
                case 4:
                {
                    if(nTemp != -1 && !GetLevelByClass(nTemp, oPC) && !bArtificer)
                    {
                    	if (DEBUG) DoDebug("CheckPrereq Failed Class");
                        return FALSE;
                    }    
                    break;
                }
            }
            sTemp = GetSubString(sTemp, nPosition + 1, nLength);
        }
        sTemp = Get2DACache(sFile, "Skill", nLine);
        if(sTemp != "" && (GetSkillRank(StringToInt(sTemp), oPC) < StringToInt(Get2DACache(sFile, "SkillRanks", nLine))))
        {
        	if (DEBUG) DoDebug("CheckPrereq Failed Skill");
            return FALSE;
        }
    }
    return TRUE;
}

//Returns a struct containing enhancement and additional cost values, don't bother with array when bSet == 0
struct itemvars GetItemVars(object oPC, object oItem, string sFile, int bEpic = 0, int bSet = 0)
{
    struct itemvars strTemp;
    int i, bBreak, nTemp;
    int j, k, bEnhanced, count;
    int nEnhancement;
    int nSpellPattern;
    int nSpell1, nSpell2, nSpell3, nSpellOR1, nSpellOR2;
    int nCasterLevel = PRCMax(GetLevelByTypeArcane(oPC), GetLevelByTypeDivine(oPC));
    int nManifesterLevel = GetManifesterLevel(oPC);
    int nLevel;
    int nFileEnd = PRCGetFileEnd(sFile);
    int nRace = MyPRCGetRacialType(oPC);
    int nFeat = GetCraftingFeat(oItem);
    int bArmsArmour = nFeat == FEAT_CRAFT_ARMS_ARMOR;
    string sPropertyType;
    strTemp.item = oItem;
    string sSub;
    int nLength;
    int nPosition;
    if(bSet)
    {
        if(array_exists(oPC, PRC_CRAFT_ITEMPROP_ARRAY))
            array_delete(oPC, PRC_CRAFT_ITEMPROP_ARRAY);
        array_create(oPC, PRC_CRAFT_ITEMPROP_ARRAY);
        //Setup
        for(i = 0; i <= nFileEnd; i++)
        {
            if(!GetPRCSwitch("PRC_CRAFT_DISABLE_" + sFile + "_" + IntToString(i)) && PrereqSpecialHandling(sFile, oItem, i))
                array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, i, 1);
        }
        if(bArmsArmour)
        {
            int nBase = GetBaseItemType(oItem);
            int bRangedType = StringToInt(Get2DACache("baseitems", "RangedWeapon", nBase));
            if(bRangedType && (bRangedType != nBase))
            {   //disallowed because ranged weapons can't have onhit
                array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, 22, 0);
                array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, 24, 0);
                array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, 26, 0);
                array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, 34, 0);
                array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, 40, 0);
                array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, 42, 0);
            }
        }
    }
    if(bArmsArmour)
    {
        itemproperty ip = GetFirstItemProperty(oItem);
        if(DEBUG) DoDebug("GetItemVars: " + GetName(oItem) + ", before itemprop loop");
        //Checking itemprops
        count = 0;
        while(GetIsItemPropertyValid(ip))
        {   //assumes no duplicated enhancement itemprops
            k = Get2DALineFromItemprop(sFile, ip, oItem);   //is causing TMI with armour with skill props
            count++;
            if(DEBUG) DoDebug("GetItemVars: itemprop number " + IntToString(count) +
                                " " + IntToString(GetItemPropertyType(ip)) +
                                " " + IntToString(GetItemPropertySubType(ip)) +
                                " " + IntToString(GetItemPropertyCostTableValue(ip)) +
                                " " + IntToString(GetItemPropertyParam1Value(ip))
                                );

            if(k >= 0)
            {
                if(k < 20) bEnhanced = TRUE;
                if(bSet)
                {
                    for(j = StringToInt(Get2DACache(sFile, "ReplaceLast", k)); j >= 0; j--)
                    {
                        array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, k - j, 0);
                    }
                }
                nEnhancement = StringToInt(Get2DACache(sFile, "Enhancement", k));
                strTemp.enhancement += nEnhancement;
                if(nEnhancement > 5) strTemp.epic = TRUE;
                strTemp.additionalcost += StringToInt(Get2DACache(sFile, "AdditionalCost", k));

                if(DEBUG)
                {
                    sPropertyType = GetStringByStrRef(StringToInt(Get2DACache(sFile, "Name", k)));
                    if(sPropertyType != "")
                        DoDebug("GetItemVars: " + sPropertyType);
                }
            }
            else if(bSet && k == -2)
            {
                DisallowType(oPC, sFile, ip);
            }

            ip = GetNextItemProperty(oItem);
        }
        if(strTemp.enhancement > 10) strTemp.epic = TRUE;
        if(DEBUG) DoDebug("GetItemVars: " + GetName(oItem) + ", after itemprop loop");
    }
    else
    {
        strTemp.enhancement = 0;
        strTemp.additionalcost = 0;
        strTemp.epic = FALSE;
    }

    if(DEBUG)
    {
        DoDebug("GetItemVars: " + GetName(oItem) +
                ", Enhancement: " + IntToString(strTemp.enhancement) +
                ", AdditionalCost: " + IntToString(strTemp.additionalcost));
    }
    if(!bSet) return strTemp;   //don't bother with array

    if(!bEpic && strTemp.epic)
    {   //attempting to craft epic item without epic crafting feat, fails
        for(i = 0; i <= nFileEnd; i++)
            array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
        return strTemp;
    }
    if(!bEnhanced && bArmsArmour)
    {   //no enhancement value, cannot add more itemprops, stop right there
        array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, 0, 1);
        for(i = 1; i <= nFileEnd; i++)
            array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
        return strTemp;
    }
    string sTemp;
    //Checking available spells, epic flag, caster level
    if(!GetLocalInt(oPC, PRC_CRAFT_TOKEN))
    {
        //moved check to confirmation stage
    }
    else if(GetPRCSwitch(PRC_DISABLE_CRAFT_EPIC))
    {   //disabling epic crafting at npc facilities
        for(i = 0; i <= nFileEnd; i++)
        {   //will skip over properties already disallowed
            if(array_get_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, i) && Get2DACache(sFile, "Epic", i) == "1")
            {
                array_set_int(oPC, PRC_CRAFT_ITEMPROP_ARRAY, i, 0);
            }
        }
    }
    return strTemp;
}

//Returns an int depending on the weapon type
//  returns 0 if not a weapon
int GetWeaponType(int nBaseItem)
{
    switch(nBaseItem)
    {
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_TWOBLADEDSWORD:
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_KAMA:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_SHURIKEN:
        case BASE_ITEM_DWARVENWARAXE:
        case BASE_ITEM_WHIP:
        case BASE_ITEM_ELVEN_LIGHTBLADE:
        case BASE_ITEM_ELVEN_THINBLADE:
        case BASE_ITEM_ELVEN_COURTBLADE:
		case BASE_ITEM_DOUBLE_SCIMITAR:
		case BASE_ITEM_NUNCHAKU:
		case BASE_ITEM_SAI:
		case BASE_ITEM_EAGLE_CLAW:
            return PRC_CRAFT_EXOTIC_WEAPON;
            break;

        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_WARHAMMER:
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_THROWINGAXE:
		case BASE_ITEM_TRIDENT:
		case BASE_ITEM_HEAVY_PICK:
		case BASE_ITEM_LIGHT_PICK:
		case BASE_ITEM_FALCHION:
		case BASE_ITEM_SAP:
		case BASE_ITEM_MAUL:
            return PRC_CRAFT_MARTIAL_WEAPON;
            break;

        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_DART:
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_SLING:
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_HEAVYCROSSBOW:
        case BASE_ITEM_CLUB:
        case BASE_ITEM_QUARTERSTAFF:
		case BASE_ITEM_KATAR:
		case BASE_ITEM_HEAVY_MACE:
		case BASE_ITEM_GOAD:		
            return PRC_CRAFT_SIMPLE_WEAPON;
            break;

        default: return 0; break;
    }
    return 0;
}

void ApplyBonusToStatBasedChecks(object oItem, int nStat, int nBonus)
{
    int i;
    string sSkills = "skills";
    string sFilter;
    switch(nStat)
    {
        case ABILITY_STRENGTH: sFilter = "STR"; break;
        case ABILITY_DEXTERITY: sFilter = "DEX"; break;
        case ABILITY_CONSTITUTION: sFilter = "CON"; break;
        case ABILITY_INTELLIGENCE: sFilter = "INT"; break;
        case ABILITY_WISDOM: sFilter = "WIS"; break;
        case ABILITY_CHARISMA: sFilter = "CHA"; break;
    }
    for(i = 0; i <= PRCGetFileEnd(sSkills); i++)
    {
        if(Get2DACache(sSkills, "KeyAbility", i) == sFilter)
            IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(i, nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
}

//Hardcoding of some adjustments
itemproperty PropSpecialHandling(object oItem, string sFile, int nLine, int nIndex)
{
    itemproperty ip;
    int nTemp;
    string sEntry = Get2DACache(sFile, "IP" + IntToString(nIndex), nLine);
    if(DEBUG) DoDebug("PropSpecialHandling(object, " + sFile + ", " + IntToString(nLine) + ", " + IntToString(nIndex) + ")");
    if(DEBUG) DoDebug("Get2DACache: IP" + IntToString(nIndex) + ", " + sEntry);
    struct ipstruct iptemp = GetIpStructFromString(sEntry);
    string sTemp;

    int nBase = GetBaseItemType(oItem);
    if(StringToInt(Get2DACache(sFile, "Special", nLine)))
    {
        if(sFile == "craft_armour")
        {
            if(iptemp.type == ITEM_PROPERTY_SKILL_BONUS && SkillHasACPenalty(iptemp.subtype))
                iptemp.costtablevalue += GetArmourCheckPenaltyReduction(oItem);
        }
        else if(sFile == "craft_weapon")
        {
            switch(nLine)
            {
                case 26:
                case 27:
                {
                    nTemp = GetLocalInt(GetItemPossessor(oItem), PRC_CRAFT_SPECIAL_BANE_RACE);
                    if(nIndex == 1)
                    {
                        iptemp.subtype = nTemp;
                        nTemp = StringToInt(Get2DACache("baseitems", "WeaponType", nBase));
                        switch(nTemp)
                        {
                            case 1: iptemp.param1value = IP_CONST_DAMAGETYPE_PIERCING; break;
                            case 2:
                            case 5: iptemp.param1value = IP_CONST_DAMAGETYPE_BLUDGEONING; break;
                            case 3:
                            case 4: iptemp.param1value = IP_CONST_DAMAGETYPE_SLASHING; break;
                        }
                    }
                    else if(nIndex == 2)
                    {
                        iptemp.subtype = nTemp;
                        iptemp.costtablevalue += IPGetWeaponEnhancementBonus(oItem);
                        if(iptemp.costtablevalue > 20)
                            iptemp.costtablevalue = 20;
                    }
                    else if(nIndex == 3)
                        iptemp.param1value = nTemp;
                    break;
                }
            }
            if(iptemp.type == ITEM_PROPERTY_ENHANCEMENT_BONUS &&
                StringToInt(Get2DACache("prc_craft_gen_it", "Type", nBase)) == PRC_CRAFT_ITEM_TYPE_AMMO)
            {
                iptemp.type = ITEM_PROPERTY_DAMAGE_BONUS;
                iptemp.subtype = (nBase == BASE_ITEM_BULLET) ? DAMAGE_TYPE_BLUDGEONING : DAMAGE_TYPE_PIERCING;
            }
        }
    }
    if(DEBUG) DoDebug("Reconstructed: IP" + IntToString(nIndex) + ", " + IntToString(iptemp.type)+"_"+IntToString(iptemp.subtype)+"_"+IntToString(iptemp.costtablevalue)+"_"+IntToString(iptemp.param1value));
    return ConstructIP(iptemp.type, iptemp.subtype, iptemp.costtablevalue, iptemp.param1value);
}

void ApplyItemProps(object oItem, string sFile, int nLine)
{
    int i;
    itemproperty ip;
    if(StringToInt(Get2DACache(sFile, "Special", nLine)))
    {
        if(sFile == "craft_wondrous")
        {
            switch(nLine)
            {
                case 43:
                {
                    ApplyBonusToStatBasedChecks(oItem, ABILITY_CHARISMA, 3);
                    SetName(oItem, GetStringByStrRef(StringToInt(Get2DACache(sFile, "Name", nLine))));
                    return;
                    break;
                }
                case 85:    //helm of brilliance
                case 91:    //necklace of fireballs
                case 92:
                case 93:
                case 94:
                case 95:
                case 96:
                case 97: SetItemCharges(oItem, 50); break;
                case 108: IPSafeAddItemProperty(oItem, ItemPropertyLimitUseBySAlign(IP_CONST_ALIGNMENT_TN), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING); break;
                case 116:
                {
                    object oCopy = CopyObject(oItem, GetLocation(oItem), GetItemPossessor(oItem), "prc_turnphyl");
                    DestroyObject(oItem);
                    oItem = oCopy;
                }
            }
        }
    }
    i = 1;  //FUGLY HACK: i doesn't initialise properly in for loop
    for(i = 1; i <= 6; i++)
    {
        if(DEBUG) DoDebug("ApplyItemProps: i = " + IntToString(i));
        ip = PropSpecialHandling(oItem, sFile, nLine, i);
        if(GetIsItemPropertyValid(ip))
        {
            if(DEBUG) DoDebug(GetItemPropertyString(ip));
            IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        }
        else
            break;  //no more itemprops, no gaps, assuming no errors
    }
    if(sFile != "craft_weapon" && sFile != "craft_armour")
    {    
		SetName(oItem, GetStringByStrRef(StringToInt(Get2DACache(sFile, "Name", nLine))));	
		string sDescRef = Get2DACache(sFile, "CraftedDescription", nLine);  
		if(sDescRef != "")  
		SetDescription(oItem, GetStringByStrRef(StringToInt(sDescRef)));
	}
}

//Partly ripped off the lexicon :P
int GetItemBaseAC(object oItem)
{
    int nAC = -1;
    int nBase = GetBaseItemType(oItem);
    int bID = GetIdentified(oItem);
    if(bID) SetIdentified(oItem, FALSE);

    if(nBase == BASE_ITEM_ARMOR)
    {
        switch(GetGoldPieceValue(oItem))
        {
            case    1: nAC = 0; break; // None
            case    5: nAC = 1; break; // Padded
            case   10: nAC = 2; break; // Leather
            case   15: nAC = 3; break; // Studded Leather / Hide
            case  100: nAC = 4; break; // Chain Shirt / Scale Mail
            case  150: nAC = 5; break; // Chainmail / Breastplate
            case  200: nAC = 6; break; // Splint Mail / Banded Mail
            case  600: nAC = 7; break; // Half-Plate
            case 1500: nAC = 8; break; // Full Plate
        }
    }
    else if(nBase == BASE_ITEM_SMALLSHIELD)
        nAC = 1;
    else if(nBase == BASE_ITEM_LARGESHIELD)
        nAC = 2;
    else if(nBase == BASE_ITEM_TOWERSHIELD)
        nAC = 3;

    if(bID) SetIdentified(oItem, TRUE);
    return nAC;
}

int GetItemArmourCheckPenalty(object oItem)
{
    int nBase = GetBaseItemType(oItem);
    int nPenalty = 0;
    if(nBase == BASE_ITEM_SMALLSHIELD)
        nPenalty = 1;
    else if(nBase == BASE_ITEM_LARGESHIELD)
        nPenalty = 2;
    else if(nBase == BASE_ITEM_TOWERSHIELD)
        nPenalty = 10;
    else if(nBase == BASE_ITEM_ARMOR)
    {
        switch(GetItemBaseAC(oItem))
        {
            case 3: nPenalty = 1; break;
            case 4: nPenalty = 2; break;
            case 5: nPenalty = 5; break;
            case 6: nPenalty = 7; break;
            case 7: nPenalty = 7; break;
            case 8: nPenalty = 8; break;
        }
    }
    return nPenalty;
}

string GetCrafting2DA(object oItem)
{
    int nBase = GetBaseItemType(oItem);
    int nMaterial = StringToInt(GetStringLeft(GetTag(oItem), 3));
    if(((nBase == BASE_ITEM_ARMOR) ||
        (nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD))
        )
    {
        if((GetItemBaseAC(oItem) == 0) && !(nMaterial & PRC_CRAFT_FLAG_MASTERWORK)) return "craft_wondrous";
        return "craft_armour";
    }

    if(GetWeaponType(nBase) ||
        (nBase == BASE_ITEM_ARROW) ||
        (nBase == BASE_ITEM_BOLT) ||
        (nBase == BASE_ITEM_BULLET)
        )
        return "craft_weapon";
		
    if(nBase == BASE_ITEM_RING) return "craft_ring";
	
    if(((nBase == BASE_ITEM_HELMET) ||
        (nBase == BASE_ITEM_AMULET) ||
        (nBase == BASE_ITEM_BELT) ||
        (nBase == BASE_ITEM_BOOTS) ||
        (nBase == BASE_ITEM_GLOVES) ||
        (nBase == BASE_ITEM_BRACER) ||
        (nBase == BASE_ITEM_CLOAK)	||
        (nBase == BASE_ITEM_CRAFTED_VIAL))
        )
        return "craft_wondrous";

    //restrict to castspell itemprops?
    /*
    if(nBase == BASE_ITEM_MAGICROD) return FEAT_CRAFT_ROD;
    if(nBase == BASE_ITEM_MAGICSTAFF) return FEAT_CRAFT_STAFF;
    if(nBase == BASE_ITEM_MAGICWAND) return FEAT_CRAFT_WAND;
    */

    //bioware crafting, castspell itemprops only
    return "";
}

int GetCraftingFeat(object oItem)
{
    int nBase = GetBaseItemType(oItem);
    int nMaterial = StringToInt(GetStringLeft(GetTag(oItem), 3));
    if(((nBase == BASE_ITEM_ARMOR) ||
        (nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD)) ||
        (GetWeaponType(nBase) ||
        (nBase == BASE_ITEM_ARROW) ||
        (nBase == BASE_ITEM_BOLT) ||
        (nBase == BASE_ITEM_BULLET)
        )
        )
    {
        if((GetItemBaseAC(oItem) == 0) && !(nMaterial & PRC_CRAFT_FLAG_MASTERWORK)) return FEAT_CRAFT_WONDROUS;
        return FEAT_CRAFT_ARMS_ARMOR;
    }

    if(nBase == BASE_ITEM_RING) return FEAT_FORGE_RING;

    //routing bioware feats through this convo
	if((nBase == BASE_ITEM_CRAFTED_SCEPTER) ||
		(nBase == BASE_ITEM_CRAFTED_SCEPTER)
		)
		return FEAT_CRAFT_SCEPTER;
		
    if((nBase == BASE_ITEM_MAGICROD) ||
        (nBase == BASE_ITEM_CRAFTED_ROD)
        )
        return FEAT_CRAFT_ROD;
		
    if((nBase == BASE_ITEM_MAGICSTAFF) ||
        (nBase == BASE_ITEM_CRAFTED_STAFF)
        )
        return FEAT_CRAFT_STAFF;
		
    if((nBase == BASE_ITEM_MAGICWAND) ||
        (nBase == BASE_ITEM_BLANK_WAND)
        )
        return FEAT_CRAFT_WAND;
		
    if(nBase == BASE_ITEM_BLANK_POTION) return FEAT_BREW_POTION;
	
    if(nBase == BASE_ITEM_BLANK_SCROLL) return FEAT_SCRIBE_SCROLL;

    if(((nBase == BASE_ITEM_HELMET) ||
        (nBase == BASE_ITEM_AMULET) ||
        (nBase == BASE_ITEM_BELT) ||
        (nBase == BASE_ITEM_BOOTS) ||
        (nBase == BASE_ITEM_GLOVES) ||
        (nBase == BASE_ITEM_BRACER) ||
        (nBase == BASE_ITEM_CLOAK)	||
        (nBase == BASE_ITEM_CRAFTED_VIAL))
        )
    return FEAT_CRAFT_WONDROUS;

    return -1;
}

int GetEpicCraftingFeat(int nFeat)
{
    switch(nFeat)
    {
        case FEAT_CRAFT_WONDROUS: return FEAT_CRAFT_EPIC_WONDROUS_ITEM;
        case FEAT_CRAFT_CONSTRUCT:
        case FEAT_CRAFT_ARMS_ARMOR: return FEAT_CRAFT_EPIC_MAGIC_ARMS_ARMOR;
        case FEAT_CRAFT_ROD: return FEAT_CRAFT_EPIC_ROD;
        case FEAT_CRAFT_STAFF: return FEAT_CRAFT_EPIC_STAFF;
        case FEAT_FORGE_RING: return FEAT_FORGE_EPIC_RING;
    }
    return -1;
}

//Returns whether the item can be made of a material
int CheckCraftingMaterial(int nBaseItem, int nMaterial, int nBaseAC = -1)
{
    if(nBaseItem == BASE_ITEM_WHIP || nBaseItem == BASE_ITEM_SAP) return (nMaterial == PRC_CRAFT_MATERIAL_LEATHER);

    if((nBaseItem == BASE_ITEM_SMALLSHIELD) ||
        (nBaseItem == BASE_ITEM_LARGESHIELD) ||
        (nBaseItem == BASE_ITEM_TOWERSHIELD)
        )
        return ((nMaterial == PRC_CRAFT_MATERIAL_METAL) || (nMaterial == PRC_CRAFT_MATERIAL_WOOD));

    if(nBaseItem == BASE_ITEM_ARMOR)
    {
        /*
        if(nBaseAC >= 0 && nBaseAC <= 1) return (nMaterial == PRC_CRAFT_MATERIAL_CLOTH);
        if(nBaseAC >= 2 && nBaseAC <= 3) return (nMaterial == PRC_CRAFT_MATERIAL_LEATHER);
        else return (nMaterial == PRC_CRAFT_MATERIAL_METAL);
        */
        return ((nMaterial == PRC_CRAFT_MATERIAL_METAL) || (nMaterial == PRC_CRAFT_MATERIAL_LEATHER));
    }
    //since you can't make adamantine weapons at the moment
    if((nBaseItem == BASE_ITEM_HEAVYCROSSBOW) ||
        (nBaseItem == BASE_ITEM_LIGHTCROSSBOW) ||
        (nBaseItem == BASE_ITEM_LONGBOW) ||
        (nBaseItem == BASE_ITEM_SHORTBOW) ||
        (nBaseItem == BASE_ITEM_QUARTERSTAFF) ||
        (nBaseItem == BASE_ITEM_CLUB) ||
        (nBaseItem == BASE_ITEM_NUNCHAKU) ||   //nunchaku
        (nBaseItem == BASE_ITEM_SCYTHE) ||
        (nBaseItem == BASE_ITEM_SHORTSPEAR) ||
        (nBaseItem == BASE_ITEM_TRIDENT) ||
        (nBaseItem == BASE_ITEM_HALBERD) ||
        (nBaseItem == BASE_ITEM_GOAD) ||   //goad
        (nBaseItem == BASE_ITEM_CLUB)
        )
    {
        return (nMaterial == PRC_CRAFT_MATERIAL_WOOD);
    }
    //assume stuff is made of metal (most of it is)
    return (nMaterial == PRC_CRAFT_MATERIAL_METAL);
}

//Returns the DC for crafting a particular item
int GetCraftingDC(object oItem)
{
    int nDC = 0;
    int nBase = GetBaseItemType(oItem);
    int nType = GetWeaponType(nBase);
    if(((nBase == BASE_ITEM_ARMOR) ||
        (nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD))
        )
    {
        nDC = 10 + GetItemBaseAC(oItem);
    }
    else if(((nBase == BASE_ITEM_HEAVYCROSSBOW) ||
        (nBase == BASE_ITEM_LIGHTCROSSBOW))
        )
    {
        nDC = 15;
    }
    else if(((nBase == BASE_ITEM_LONGBOW) ||
        (nBase == BASE_ITEM_SHORTBOW))
        )
    {
        nDC = 12;
        itemproperty ip = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ip))
        {
            if(GetItemPropertyType(ip) == ITEM_PROPERTY_MIGHTY)
            {
                nDC = 15 + 2 * GetItemPropertyCostTableValue(ip);
                break;
            }
            ip = GetNextItemProperty(oItem);
        }
    }
    else if(nType == PRC_CRAFT_SIMPLE_WEAPON)
        nDC = 12;
    else if(nType == PRC_CRAFT_MARTIAL_WEAPON)
        nDC = 15;
    else if(nType == PRC_CRAFT_EXOTIC_WEAPON)
        nDC = 18;
    return nDC;
}

//Applies Masterwork properties to oItem
void MakeMasterwork(object oItem)
{
    if(GetPlotFlag(oItem)) return;  //sanity check
	
	itemproperty ip = ItemPropertyQuality(IP_CONST_QUALITY_MASTERWORK);  
	ip = TagItemProperty(ip, "Quality_Masterwork");  
	IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);	
	
    int nBase = GetBaseItemType(oItem);
    if((nBase == BASE_ITEM_ARMOR) ||
        (nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD)
        )
    {
        //no armour check penalty here
        if(GetItemArmourCheckPenalty(oItem) == 0) return;

		ip = ItemPropertySkillBonus(SKILL_BALANCE, 1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_CLIMB, 1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		ip = ItemPropertySkillBonus(SKILL_HIDE, 1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_MOVE_SILENTLY, 1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_PICK_POCKET, 1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_SET_TRAP, 1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_TUMBLE, 1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_JUMP, 1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);		

    }
    else if(GetWeaponType(nBase))
    {
        ip = ItemPropertyAttackBonus(1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    else if(StringToInt(Get2DACache("prc_craft_gen_it", "Type", nBase)) == PRC_CRAFT_ITEM_TYPE_AMMO)
    {
        ip = ItemPropertyAttackBonus(1);  
		ip = TagItemProperty(ip, "Quality_Masterwork");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);		
    }
    else
        return;
}

/* void MakeMasterwork(object oItem)
{
    if(GetPlotFlag(oItem)) return;  //sanity check
	
    int nBase = GetBaseItemType(oItem);
    if((nBase == BASE_ITEM_ARMOR) ||
        (nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD)
        )
    {
        //no armour check penalty here
        if(GetItemArmourCheckPenalty(oItem) == 0) return;
		
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_HIDE, 1)         , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_MOVE_SILENTLY, 1), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_PICK_POCKET, 1)  , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_SET_TRAP, 1)     , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_TUMBLE, 1)       , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_JUMP, 1)         , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
    else if(GetWeaponType(nBase))
    {
        IPSafeAddItemProperty(oItem, ItemPropertyAttackBonus(1), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    else if(StringToInt(Get2DACache("prc_craft_gen_it", "Type", nBase)) == PRC_CRAFT_ITEM_TYPE_AMMO)
    {
        
        //int nDamageType = (nBase == BASE_ITEM_BULLET) ? DAMAGE_TYPE_BLUDGEONING : DAMAGE_TYPE_PIERCING;
        //itemproperty ip1 = ItemPropertyDamageBonus(nDamageType, IP_CONST_DAMAGEBONUS_1);
        
        IPSafeAddItemProperty(oItem, ItemPropertyAttackBonus(1), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    else
        return;
}
 */

void MakeAdamantine(object oItem)  
{  
    if(GetPlotFlag(oItem)) return;  //sanity check

	itemproperty ip;
 
    if(GetBaseItemType(oItem) == BASE_ITEM_ARMOR)  
    {  
        int nBonus = 0;  
        switch(GetItemBaseAC(oItem))  
        {  
            case 1:  
            case 2:  
            case 3: nBonus = IP_CONST_DAMAGERESIST_1; break;  
            case 4:  
            case 5: nBonus = IP_CONST_DAMAGERESIST_2; break;  
            case 6:  
            case 7:  
            case 8: nBonus = IP_CONST_DAMAGERESIST_3; break;  
        }  
        if(nBonus)  
        {  
            ip = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_BLUDGEONING, nBonus);  
            ip = TagItemProperty(ip, "Material_Adamantine");  
            IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);  
              
            ip = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_PIERCING, nBonus);  
            ip = TagItemProperty(ip, "Material_Adamantine");  
            IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);  
              
            ip = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SLASHING, nBonus);  
            ip = TagItemProperty(ip, "Material_Adamantine");  
            IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);    
        }  
    } 

	ip = ItemPropertyMaterial(IP_MATERIAL_ADAMANTINE);  
	ip = TagItemProperty(ip, "Material_Adamantine");  
	IPSafeAddItemProperty(oItem, ip, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);	
}

void MakeDarkwood(object oItem)
{
    if(GetPlotFlag(oItem)) return;  //sanity check
  
	itemproperty ip = ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_50_PERCENT);
	ip = TagItemProperty(ip, "Material_Darkwood");	
	IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);	

    int nBase = GetBaseItemType(oItem);
    if(((nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD))
        )
    {
        int nBonus = 2;
        if(nBase == BASE_ITEM_SMALLSHIELD) nBonus = 1;

		ip = ItemPropertySkillBonus(SKILL_BALANCE, nBonus);  
		ip = TagItemProperty(ip, "Material_Darkwood");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		ip = ItemPropertySkillBonus(SKILL_CLIMB, nBonus);  
		ip = TagItemProperty(ip, "Material_Darkwood");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);		
		
		ip = ItemPropertySkillBonus(SKILL_HIDE, nBonus);  
		ip = TagItemProperty(ip, "Material_Darkwood");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		ip = ItemPropertySkillBonus(SKILL_MOVE_SILENTLY, nBonus);  
		ip = TagItemProperty(ip, "Material_Darkwood");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);	

		ip = ItemPropertySkillBonus(SKILL_PICK_POCKET, nBonus);  
		ip = TagItemProperty(ip, "Material_Darkwood");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_SET_TRAP, nBonus);  
		ip = TagItemProperty(ip, "Material_Darkwood");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_TUMBLE, nBonus);  
		ip = TagItemProperty(ip, "Material_Darkwood");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_JUMP, nBonus);  
		ip = TagItemProperty(ip, "Material_Darkwood");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
	
	ip = ItemPropertyMaterial(IP_MATERIAL_WOOD_DARKWOOD_ZALANTAR);  
	ip = TagItemProperty(ip, "Material_Darkwood");  
	IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);	
}

void MakeDragonhide(object oItem)
{
    //Does nothing so far
}

void MakeMithral(object oItem)
{
    if(GetPlotFlag(oItem)) return;  //sanity check
	
	itemproperty ip = ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_50_PERCENT);  
	ip = TagItemProperty(ip, "Material_Mithral");  
	IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);	
	
    int nBase = GetBaseItemType(oItem);
	
	if(GetWeaponType(nBase))
    {
		ip = ItemPropertyMaterial(IP_MATERIAL_MITHRAL);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }	
    else if(((nBase == BASE_ITEM_ARMOR) ||
        (nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD))
        )
    {
        int nBonus = 3;
        int nPenalty = GetItemArmourCheckPenalty(oItem);
        if(nBonus > nPenalty) nBonus = nPenalty;

		ip = ItemPropertySkillBonus(SKILL_BALANCE, nBonus);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		ip = ItemPropertySkillBonus(SKILL_CLIMB, nBonus);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		ip = ItemPropertySkillBonus(SKILL_HIDE, nBonus);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		ip = ItemPropertySkillBonus(SKILL_MOVE_SILENTLY, nBonus);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);	

		ip = ItemPropertySkillBonus(SKILL_PICK_POCKET, nBonus);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_SET_TRAP, nBonus);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_TUMBLE, nBonus);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

		ip = ItemPropertySkillBonus(SKILL_JUMP, nBonus);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		ip = ItemPropertyMaterial(IP_MATERIAL_MITHRAL);  
		ip = TagItemProperty(ip, "Material_Mithral");  
		IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
        if(GetItemBaseAC(oItem) == 1)
		{
			ip = ItemPropertyArcaneSpellFailure(IP_CONST_ARCANE_SPELL_FAILURE_MINUS_5_PERCENT);  
			ip = TagItemProperty(ip, "Material_Mithral");  
			IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		}
		else
		{
			ip = ItemPropertyArcaneSpellFailure(IP_CONST_ARCANE_SPELL_FAILURE_MINUS_10_PERCENT);  
			ip = TagItemProperty(ip, "Material_Mithral");  
			IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		}
		
    }
}

void MakeColdIron(object oItem)
{
	//Does nothing so far
	itemproperty ip = ItemPropertyMaterial(IP_MATERIAL_COLD_IRON);  
	ip = TagItemProperty(ip, "Material_ColdIron");  
	IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
}

void MakeSilver(object oItem)
{
	//Does nothing so far
	itemproperty ip = ItemPropertyMaterial(IP_MATERIAL_SILVER);  
	ip = TagItemProperty(ip, "Material_ColdIron");  
	IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);    
}

void MakeMundaneCrystal(object oItem)
{
	//Does nothing so far
	itemproperty ip = ItemPropertyMaterial(IP_MATERIAL_GEM_CRYSTAL_MUNDANE);  
	ip = TagItemProperty(ip, "Material_MundaneCrystal");  
	IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING); 
}

void MakeDeepCrystal(object oItem)
{
	//Does nothing so far
	itemproperty ip = ItemPropertyMaterial(IP_MATERIAL_GEM_CRYSTAL_DEEP);  
	ip = TagItemProperty(ip, "Material_DeepCrystal");  
	IPSafeAddItemProperty(oItem, ip, 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
}

/* void MakeAdamantine(object oItem)
{
    if(GetPlotFlag(oItem)) return;  //sanity check
    if(GetBaseItemType(oItem) == BASE_ITEM_ARMOR)
    {
        int nBonus = 0;
        switch(GetItemBaseAC(oItem))
        {
            case 1:
            case 2:
            case 3: nBonus = IP_CONST_DAMAGERESIST_1; break;
            case 4:
            case 5: nBonus = IP_CONST_DAMAGERESIST_2; break;
            case 6:
            case 7:
            case 8: nBonus = IP_CONST_DAMAGERESIST_3; break;
        }
        if(nBonus)
        {
            IPSafeAddItemProperty(oItem, ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_BLUDGEONING, nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            IPSafeAddItemProperty(oItem, ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_PIERCING, nBonus)   , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            IPSafeAddItemProperty(oItem, ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SLASHING, nBonus)   , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
			
			itemproperty ipAdamantine = ItemPropertyMaterial(IP_MATERIAL_ADAMANTINE); 
			IPSafeAddItemProperty(oItem, ipAdamantine, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        }
    }
} */

/* void MakeDarkwood(object oItem)
{
    if(GetPlotFlag(oItem)) return;  //sanity check
    IPSafeAddItemProperty(oItem, ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_50_PERCENT), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    int nBase = GetBaseItemType(oItem);
    if(((nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD))
        )
    {
        int nBonus = 2;
        if(nBase == BASE_ITEM_SMALLSHIELD) nBonus = 1;
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_HIDE, nBonus)         , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_MOVE_SILENTLY, nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_PICK_POCKET, nBonus)  , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_SET_TRAP, nBonus)     , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_TUMBLE, nBonus)       , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_JUMP, nBonus)         , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		itemproperty ipDarkwood = ItemPropertyMaterial(IP_MATERIAL_WOOD_DARKWOOD_ZALANTAR); 
		IPSafeAddItemProperty(oItem, ipDarkwood, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
}
 */

/* void MakeDragonhide(object oItem)
{
    //Does nothing so far
}

void MakeMithral(object oItem)
{
    if(GetPlotFlag(oItem)) return;  //sanity check
    IPSafeAddItemProperty(oItem, ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_50_PERCENT), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    int nBase = GetBaseItemType(oItem);
    if(((nBase == BASE_ITEM_ARMOR) ||
        (nBase == BASE_ITEM_SMALLSHIELD) ||
        (nBase == BASE_ITEM_LARGESHIELD) ||
        (nBase == BASE_ITEM_TOWERSHIELD))
        )
    {
        int nBonus = 3;
        int nPenalty = GetItemArmourCheckPenalty(oItem);
        if(nBonus > nPenalty) nBonus = nPenalty;
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_HIDE, nBonus)         , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_MOVE_SILENTLY, nBonus), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_PICK_POCKET, nBonus)  , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_SET_TRAP, nBonus)     , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_TUMBLE, nBonus)       , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_JUMP, nBonus)         , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_BALANCE, nBonus)      , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oItem, ItemPropertySkillBonus(SKILL_CLIMB, nBonus)        , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        if(GetItemBaseAC(oItem) == 1)
            IPSafeAddItemProperty(oItem, ItemPropertyArcaneSpellFailure(IP_CONST_ARCANE_SPELL_FAILURE_MINUS_5_PERCENT), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        else
            IPSafeAddItemProperty(oItem, ItemPropertyArcaneSpellFailure(IP_CONST_ARCANE_SPELL_FAILURE_MINUS_10_PERCENT), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
		
		itemproperty ipMithral = ItemPropertyMaterial(IP_MATERIAL_MITHRAL); 
		IPSafeAddItemProperty(oItem, ipMithral, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);		
    }
}
 */

/* void MakeColdIron(object oItem)
{
	//Does nothing so far
	itemproperty ipColdIron = ItemPropertyMaterial(IP_MATERIAL_COLD_IRON); 
	IPSafeAddItemProperty(oItem, ipColdIron, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING); 
}
 */

/* void MakeSilver(object oItem)
{
	//Does nothing so far
	itemproperty ipSilver = ItemPropertyMaterial(IP_MATERIAL_SILVER); 
	IPSafeAddItemProperty(oItem, ipSilver, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);    
}
 */
 
/* void MakeMundaneCrystal(object oItem)
{
	//Does nothing so far
	itemproperty ipCrystal = ItemPropertyMaterial(IP_MATERIAL_GEM_CRYSTAL_MUNDANE); 
	IPSafeAddItemProperty(oItem, ipCrystal, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING); 
}
 */

/* void MakeDeepCrystal(object oItem)
{
	//Does nothing so far
	itemproperty ipDeepCrystal = ItemPropertyMaterial(IP_MATERIAL_GEM_CRYSTAL_DEEP); 
	IPSafeAddItemProperty(oItem, ipDeepCrystal, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING); 
}
 */
 
//Creates an item on oOwner, from the baseitemtype and base AC (for armour)
object CreateStandardItem(object oOwner, int nBaseItemType, int nBaseAC = -1)
{
    string sResRef = Get2DACache("prc_craft_gen_it", "Blueprint", nBaseItemType);
    int nStackSize = StringToInt(Get2DACache("baseitems", "ILRStackSize", nBaseItemType));
    if(nBaseItemType == BASE_ITEM_ARMOR)
    {
        switch(nBaseAC)
        {
            case 0: sResRef = "x2_cloth008"; break;
            case 1: sResRef = "nw_aarcl009"; break;
            case 2: sResRef = "nw_aarcl001"; break;
            case 3: sResRef = "nw_aarcl002"; break;
            case 4: sResRef = "nw_aarcl012"; break;
            case 5: sResRef = "nw_aarcl004"; break;
            case 6: sResRef = "nw_aarcl005"; break;
            case 7: sResRef = "nw_aarcl006"; break;
            case 8: sResRef = "nw_aarcl007"; break;
        }
    }
    string sTag;
    if (GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oOwner)) sTag = GetName(oOwner);    

    return CreateItemOnObject(sResRef, oOwner, nStackSize, sTag);
}

int GetEnhancementBaseCost(object oItem)
{
    string sFile = GetCrafting2DA(oItem);
    if(sFile == "craft_armour") return 1000;
    if(sFile == "craft_weapon") return 2000;

    return 0;
}

//returns pnp market price of an item
int GetPnPItemCost(struct itemvars strTemp, int bIncludeBaseCost = TRUE)
{
    int nMaterial, nEnhancement;
    int nAdd = 0, nTemp = 0;
    int nType = GetBaseItemType(strTemp.item);
	
	if(DEBUG) 
	{
		DoDebug("nType: " + IntToString(nType));
		FloatingTextStringOnCreature( "nType = " + IntToString(nType), GetFirstPC());
	}
    if(bIncludeBaseCost)
    {
        SetIdentified(strTemp.item, FALSE);
        int nMultiplyer = StringToInt(Get2DACache("baseitems", "ItemMultiplier", nType));
        if(nMultiplyer < 1) nMultiplyer = 1;
		if(DEBUG) 
		{
			DoDebug("nMultiplyer: " + IntToString(nMultiplyer));
			FloatingTextStringOnCreature( "nMultiplyer = " + IntToString(nMultiplyer), GetFirstPC());
		}
		
        nTemp = GetGoldPieceValue(strTemp.item) / nMultiplyer;
		if(DEBUG) 
		{
			DoDebug("nTemp: " + IntToString(nTemp));
			FloatingTextStringOnCreature( "nTemp = " + IntToString(nTemp), GetFirstPC());
		}
		
        SetIdentified(strTemp.item, TRUE);
        int nFlag = StringToInt(Get2DACache("prc_craft_gen_it", "Type", nType));
        string sMaterial = GetStringLeft(GetTag(strTemp.item), 3);
        nMaterial = StringToInt(sMaterial);
        if(GetMaterialString(nMaterial) != sMaterial)
            nMaterial = 0;
        if(nMaterial & PRC_CRAFT_FLAG_MASTERWORK)
        {
            switch(nFlag)
            {
                case PRC_CRAFT_ITEM_TYPE_WEAPON: nAdd += 300; break;
                case PRC_CRAFT_ITEM_TYPE_ARMOUR: nAdd += 150; break;
                case PRC_CRAFT_ITEM_TYPE_SHIELD: nAdd += 150; break;
                case PRC_CRAFT_ITEM_TYPE_AMMO: nAdd += 594; break;
            }
        }
        if(nMaterial & PRC_CRAFT_FLAG_ADAMANTINE)
        {
            switch(GetItemBaseAC(strTemp.item))
            {
                case 1:
                case 2:
                case 3: nAdd += 5000; break;
                case 4:
                case 5: nAdd += 10000; break;
                case 6:
                case 7:
                case 8: nAdd += 15000; break;
            }
        }
        if(nMaterial & PRC_CRAFT_FLAG_DARKWOOD)
        {
            nAdd += StringToInt(Get2DACache("baseitems", "TenthLBS", nType));
        }
        if(nMaterial & PRC_CRAFT_FLAG_DRAGONHIDE)
        {
            nAdd += nAdd + nTemp;
        }
        if(nMaterial & PRC_CRAFT_FLAG_MITHRAL)
        {
            if(nType == BASE_ITEM_ARMOR)
            {
                switch(GetItemBaseAC(strTemp.item))
                {
                    case 1:
                    case 2:
                    case 3: nAdd += 1000; break;
                    case 4:
                    case 5: nAdd += 4000; break;
                    case 6:
                    case 7:
                    case 8: nAdd += 9000; break;
                }
            }
            else
            {
                switch(nFlag)
                {
                    case PRC_CRAFT_ITEM_TYPE_WEAPON: nAdd += 50 * StringToInt(Get2DACache("baseitems", "TenthLBS", nType)); break;
                    case PRC_CRAFT_ITEM_TYPE_SHIELD: nAdd += 1000; break;
                }
            }
        }
        if(nMaterial & PRC_CRAFT_FLAG_COLD_IRON)
        {
            //not implemented
        }
        if(nMaterial & PRC_CRAFT_FLAG_ALCHEMICAL_SILVER)
        {
            //not implemented
        }
        if(nMaterial & PRC_CRAFT_FLAG_MUNDANE_CRYSTAL)
        {
            //not implemented
        }
        if(nMaterial & PRC_CRAFT_FLAG_DEEP_CRYSTAL)
        {
            //not implemented
        }
        if(((nType == BASE_ITEM_LONGBOW) ||
            (nType == BASE_ITEM_SHORTBOW))
            )
        {
            int nCompMult = (nType == BASE_ITEM_LONGBOW) ? 100 : 75;
            itemproperty ip = GetFirstItemProperty(strTemp.item);
            while(GetIsItemPropertyValid(ip))
            {
                if(GetItemPropertyType(ip) == ITEM_PROPERTY_MIGHTY)
                {
                    nAdd += GetItemPropertyCostTableValue(ip) * nCompMult;
                    break;
                }
                ip = GetNextItemProperty(strTemp.item);
            }
        }
    }
	if(DEBUG) 
	{
		DoDebug("nAdd: " + IntToString(nAdd));
		FloatingTextStringOnCreature( "nAdd = " + IntToString(nAdd), GetFirstPC());
	}
    nTemp += nAdd;
    nEnhancement = GetEnhancementBaseCost(strTemp.item) * strTemp.enhancement * strTemp.enhancement;
    if(strTemp.epic) nEnhancement *= 10;
    nTemp += nEnhancement + strTemp.additionalcost;

    if(StringToInt(Get2DACache("baseitems", "Stacking", nType)) > 1)
        nTemp = FloatToInt(IntToFloat(nTemp) * IntToFloat(GetItemStackSize(strTemp.item))/ 50.0);
    if(nTemp < 1) nTemp = 1;

    return nTemp;
}

struct golemhds GetGolemHDsFromString(string sHD)
{
    struct golemhds hds;
    //initialise variables
    string sTemp = sHD;
    string sSub;
    int nLength = GetStringLength(sTemp);
    int nPosition;
    int nTemp;
    int i;

    for(i = 0; i < 3; i++)
    {
        nPosition = FindSubString(sTemp, "_");
        sSub = (nPosition == -1) ? sTemp : GetStringLeft(sTemp, nPosition);
        nLength -= (nPosition + 1);
        if(sSub == "*")
            nTemp = -1;
        else
            nTemp = StringToInt(sSub);
        switch(i)
        {
            case 0: hds.base = nTemp; break;
            case 1: hds.max1 = nTemp; break;
            case 2: hds.max2 = nTemp; break;
        }
        sTemp = GetSubString(sTemp, nPosition + 1, nLength);
    }
    return hds;
}

//returns market price in gp,
int GetPnPGolemCost(int nLine, int nHD, int nCosttype)
{
    int nCost = StringToInt(Get2DACache("craft_golem", "MarketPrice", nLine));
    struct golemhds ghds = GetGolemHDsFromString(Get2DACache("craft_golem", "HD", nLine));


    //sanity checking
    if(nHD < ghds.base) nHD = ghds.base;
    if(nHD > ghds.max2) nHD = ghds.max2;

    if(nHD > ghds.base)
    {
        nCost += (ghds.base - nHD) * 5000;
        if(nHD > ghds.max1)
            nCost += 50000;
    }

    if(nCosttype == CRAFT_COST_TYPE_XP)
    {
        if(StringToInt(Get2DACache("craft_golem", "Epic", nLine)))
        {
            nCost /= 100;
        }
        else
        {
            nCost /= 25;
        }
    }
    else if(nCosttype == CRAFT_COST_TYPE_CRAFTING)
    {
        nCost /= 2;
    }

    if(nCosttype != CRAFT_COST_TYPE_XP)
        nCost += StringToInt(Get2DACache("craft_golem", "SpecialCost", nLine));

    return nCost;
}

//Creates an item for oPC of nBaseItemType, made of nMaterial
object MakeMyItem(object oPC, int nBaseItemType, int nBaseAC = -1, int nMaterial = 0, int nMighty = -1)
{
    object oTemp = CreateStandardItem(GetTempCraftChest(), nBaseItemType, nBaseAC);
    string sMaterial = GetMaterialString(nMaterial);
    string sTag = sMaterial + GetUniqueID() + PRC_CRAFT_UID_SUFFIX;
    object oChest = GetCraftChest();
    while(GetIsObjectValid(GetItemPossessedBy(oChest, sTag)))//make sure there aren't any tag conflicts
        sTag = sMaterial + GetUniqueID() + PRC_CRAFT_UID_SUFFIX;
    if (GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oPC)) sTag = GetName(oPC);     
    object oNew = CopyObject(oTemp, GetLocation(oChest), oChest, sTag);
    string sPrefix = "";
    if(nMighty > 0)
    {
        if(nMighty > 20) nMighty = 20;
        IPSafeAddItemProperty(oNew, ItemPropertyMaxRangeStrengthMod(nMighty), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        IPSafeAddItemProperty(oNew, ItemPropertyLimitUseByAbility(ABILITY_STRENGTH, ((nMighty * 2) + 10)), 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
    DestroyObject(oTemp, 0.1);
    if(nMaterial & PRC_CRAFT_FLAG_MASTERWORK)   //name prefix will be overridden by materials
    {
        sPrefix = "Masterwork ";
        MakeMasterwork(oNew);
    }
    if(nMaterial & PRC_CRAFT_FLAG_ADAMANTINE)   //assumes only 1 material at a time
    {
        sPrefix = "Adamantine ";
        MakeAdamantine(oNew);
    }
    if(nMaterial & PRC_CRAFT_FLAG_DARKWOOD)
    {
        sPrefix = "Darkwood ";
        MakeDarkwood(oNew);
    }
    if(nMaterial & PRC_CRAFT_FLAG_DRAGONHIDE)
    {
        sPrefix = "Dragonhide ";
        MakeDragonhide(oNew);
    }
    if(nMaterial & PRC_CRAFT_FLAG_MITHRAL)
    {
        sPrefix = "Mithral ";
        MakeMithral(oNew);
    }
    if(nMaterial & PRC_CRAFT_FLAG_COLD_IRON)
    {
        sPrefix = "Cold Iron ";
        MakeColdIron(oNew);
    }
    if(nMaterial & PRC_CRAFT_FLAG_ALCHEMICAL_SILVER)
    {
        sPrefix = "Silver ";
        MakeSilver(oNew);
    }
    if(nMaterial & PRC_CRAFT_FLAG_MUNDANE_CRYSTAL)
    {
        sPrefix = "Crystal ";
        MakeMundaneCrystal(oNew);
    }
    if(nMaterial & PRC_CRAFT_FLAG_DEEP_CRYSTAL)
    {
        sPrefix = "Deep Crystal ";
        MakeDeepCrystal(oNew);
    }
    if(nMighty > 0) sPrefix += "Composite ";

    if((nBaseItemType == BASE_ITEM_ARMOR) && (nBaseAC == 0))
        SetName(oNew, "Robe");
    SetName(oNew, sPrefix + GetName(oNew));

    return oNew;
}

//Adds action highlight to a conversation string
string ActionString(string sString)
{
    return "<cþ>" + sString + "</c>";
}

//Inserts a space at the end of a string if the string
//  is not empty
string InsertSpaceAfterString(string sString)
{
    if(sString != "")
        return sString + " ";
    else return "";
}

string GetItemPropertyString(itemproperty ip)
{
    int nType = GetItemPropertyType(ip);
    if(nType == -1) return "";
    int nSubType = GetItemPropertySubType(ip);
    int nCostTable = GetItemPropertyCostTable(ip);
    int nCostTableValue = GetItemPropertyCostTableValue(ip);
    int nParam1 = GetItemPropertyParam1(ip);
    int nParam1Value = GetItemPropertyParam1Value(ip);
    string sDesc = InsertSpaceAfterString(
                GetStringByStrRef(StringToInt(Get2DACache("itempropdef", "GameStrRef", nType)))
                );
    string sSubType = Get2DACache("itempropdef", "SubTypeResRef", nType);
    sSubType = Get2DACache(sSubType, "Name", nSubType);
    if(sSubType != "")
        sDesc += InsertSpaceAfterString(GetStringByStrRef(StringToInt(sSubType)));
    string sCostTable = Get2DACache("itempropdef", "CostTableResRef", nType);
    sCostTable = Get2DACache("iprp_costtable", "Name", StringToInt(sCostTable));
    sCostTable = Get2DACache(sCostTable, "Name", nCostTableValue);
    if(sCostTable != "")
        sDesc += InsertSpaceAfterString(GetStringByStrRef(StringToInt(sCostTable)));
    string sParam1;
    if(nType == ITEM_PROPERTY_ON_HIT_PROPERTIES)    //Param1 depends on subtype
    {
        sParam1 = Get2DACache(Get2DACache("itempropdef", "SubTypeResRef", nType), "Param1ResRef", nSubType);
    }
    else
    {
        sParam1 = Get2DACache("itempropdef", "Param1ResRef", nType);
    }
    if(sParam1 != "")
    {
        sDesc += InsertSpaceAfterString(GetStringByStrRef(StringToInt(Get2DACache("iprp_paramtable", "Name", StringToInt(sParam1)))));
        sParam1 = Get2DACache("iprp_paramtable", "TableResRef", StringToInt(sParam1));
        sParam1 = Get2DACache(sParam1, "Name", nParam1Value);
        if(sParam1 != "")
            sDesc += InsertSpaceAfterString(GetStringByStrRef(StringToInt(sParam1)));
    }
    sDesc += "\n";

    return sDesc;
}

//Returns a string describing the item
string ItemStats(object oItem)
{
    string sDesc = GetName(oItem) +
                    "\n\n" +
                    GetStringByStrRef(StringToInt(Get2DACache("baseitems", "Name", GetBaseItemType(oItem)))) +
                    "\n\n";

    itemproperty ip = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip))
    {
        if(GetItemPropertyDurationType(ip) == DURATION_TYPE_PERMANENT)
        {
            sDesc += GetItemPropertyString(ip);
        }
        ip = GetNextItemProperty(oItem);
    }
    return sDesc;
}

//Returns TRUE if nBaseItem can have nItemProp
int ValidProperty(object oItem, int nItemProp)
{
    int nPropColumn = StringToInt(Get2DACache("baseitems", "PropColumn", GetBaseItemType(oItem)));
    string sPropCloumn = "";
    switch(nPropColumn)
    {
        case 0: sPropCloumn = "0_Melee"; break;
        case 1: sPropCloumn = "1_Ranged"; break;
        case 2: sPropCloumn = "2_Thrown"; break;
        case 3: sPropCloumn = "3_Staves"; break;
        case 4: sPropCloumn = "4_Rods"; break;
        case 5: sPropCloumn = "5_Ammo"; break;
        case 6: sPropCloumn = "6_Arm_Shld"; break;
        case 7: sPropCloumn = "7_Helm"; break;
        case 8: sPropCloumn = "8_Potions"; break;
        case 9: sPropCloumn = "9_Scrolls"; break;
        case 10: sPropCloumn = "10_Wands"; break;
        case 11: sPropCloumn = "11_Thieves"; break;
        case 12: sPropCloumn = "12_TrapKits"; break;
        case 13: sPropCloumn = "13_Hide"; break;
        case 14: sPropCloumn = "14_Claw"; break;
        case 15: sPropCloumn = "15_Misc_Uneq"; break;
        case 16: sPropCloumn = "16_Misc"; break;
        case 17: sPropCloumn = "17_No_Props"; break;
        case 18: sPropCloumn = "18_Containers"; break;
        case 19: sPropCloumn = "19_HealerKit"; break;
        case 20: sPropCloumn = "20_Torch"; break;
        case 21: sPropCloumn = "21_Glove"; break;
    }
    return(Get2DACache("itemprops", sPropCloumn, nItemProp) == "1");
}

//Makes an item property from values - total pain in the arse, need 1 per itemprop
itemproperty ConstructIP(int nType, int nSubTypeValue = 0, int nCostTableValue = 0, int nParam1Value = 0)
{
    itemproperty ip;
    switch(nType)
    {
        case ITEM_PROPERTY_ABILITY_BONUS:                            return ItemPropertyAbilityBonus(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_AC_BONUS:                                 return ItemPropertyACBonus(nCostTableValue);
        case ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP:              return ItemPropertyACBonusVsAlign(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE:                  return ItemPropertyACBonusVsDmgType(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP:                 return ItemPropertyACBonusVsRace(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT:           return ItemPropertyACBonusVsSAlign(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_ENHANCEMENT_BONUS:                        return ItemPropertyEnhancementBonus(nCostTableValue);
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP:     return ItemPropertyEnhancementBonusVsAlign(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP:        return ItemPropertyEnhancementBonusVsRace(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT: return ItemPropertyEnhancementBonusVsSAlign(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER:           return ItemPropertyEnhancementPenalty(nCostTableValue);
        case ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION:               return ItemPropertyWeightReduction(nCostTableValue);
        case ITEM_PROPERTY_BONUS_FEAT:                               return ItemPropertyBonusFeat(nSubTypeValue);
        case ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N:              return ItemPropertyBonusLevelSpell(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_CAST_SPELL:                               return ItemPropertyCastSpell(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DAMAGE_BONUS: return ItemPropertyDamageBonus(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP: return ItemPropertyDamageBonusVsAlign(nSubTypeValue, nParam1Value, nCostTableValue);
        case ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP: return ItemPropertyDamageBonusVsRace(nSubTypeValue, nParam1Value, nCostTableValue);
        case ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT: return ItemPropertyDamageBonusVsSAlign(nSubTypeValue, nCostTableValue, nParam1Value);
        case ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE: return ItemPropertyDamageImmunity(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DECREASED_DAMAGE: return ItemPropertyDamagePenalty(nCostTableValue);
        case ITEM_PROPERTY_DAMAGE_REDUCTION: return ItemPropertyDamageReduction(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DAMAGE_RESISTANCE: return ItemPropertyDamageResistance(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DAMAGE_VULNERABILITY: return ItemPropertyDamageVulnerability(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DARKVISION: return ItemPropertyDarkvision();
        case ITEM_PROPERTY_DECREASED_ABILITY_SCORE: return ItemPropertyDecreaseAbility(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DECREASED_AC: return ItemPropertyDecreaseAC(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DECREASED_SKILL_MODIFIER: return ItemPropertyDecreaseSkill(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_ENHANCED_CONTAINER_REDUCED_WEIGHT: return ItemPropertyContainerReducedWeight(nCostTableValue);
        case ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE: return ItemPropertyExtraMeleeDamageType(nSubTypeValue);
        case ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE: return ItemPropertyExtraRangeDamageType(nSubTypeValue);
        case ITEM_PROPERTY_HASTE: return ItemPropertyHaste();
        case ITEM_PROPERTY_HOLY_AVENGER: return ItemPropertyHolyAvenger();
        case ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS: return ItemPropertyImmunityMisc(nSubTypeValue);
        case ITEM_PROPERTY_IMPROVED_EVASION: return ItemPropertyImprovedEvasion();
        case ITEM_PROPERTY_SPELL_RESISTANCE: return ItemPropertyBonusSpellResistance(nCostTableValue);
        case ITEM_PROPERTY_SAVING_THROW_BONUS: return ItemPropertyBonusSavingThrowVsX(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC: return ItemPropertyBonusSavingThrow(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_KEEN: return ItemPropertyKeen();
        case ITEM_PROPERTY_LIGHT: return ItemPropertyLight(nCostTableValue, nParam1Value);
        case ITEM_PROPERTY_MIGHTY: return ItemPropertyMaxRangeStrengthMod(nCostTableValue);
        case ITEM_PROPERTY_NO_DAMAGE: return ItemPropertyNoDamage();
        case ITEM_PROPERTY_ON_HIT_PROPERTIES:{
        if(nParam1Value == -1)
              return ItemPropertyOnHitProps(nSubTypeValue, nCostTableValue);
        else
              return ItemPropertyOnHitProps(nSubTypeValue, nCostTableValue, nParam1Value);}
        case ITEM_PROPERTY_DECREASED_SAVING_THROWS: return ItemPropertyReducedSavingThrowVsX(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC: return ItemPropertyReducedSavingThrow(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_REGENERATION: return ItemPropertyRegeneration(nCostTableValue);
        case ITEM_PROPERTY_SKILL_BONUS: return ItemPropertySkillBonus(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL: return ItemPropertySpellImmunitySpecific(nCostTableValue);
        case ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL: return ItemPropertySpellImmunitySchool(nSubTypeValue);
        case ITEM_PROPERTY_THIEVES_TOOLS: return ItemPropertyThievesTools(nCostTableValue);
        case ITEM_PROPERTY_ATTACK_BONUS: return ItemPropertyAttackBonus(nCostTableValue);
        case ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP: return ItemPropertyAttackBonusVsAlign(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP: return ItemPropertyAttackBonusVsRace(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT: return ItemPropertyAttackBonusVsSAlign(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER: return ItemPropertyAttackPenalty(nCostTableValue);
        //IP_CONST_UNLIMITEDAMMO_* is costtablevalue, not subtype
        case ITEM_PROPERTY_UNLIMITED_AMMUNITION: return ItemPropertyUnlimitedAmmo(nCostTableValue);
        case ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP: return ItemPropertyLimitUseByAlign(nSubTypeValue);
        case ITEM_PROPERTY_USE_LIMITATION_CLASS: return ItemPropertyLimitUseByClass(nSubTypeValue);
        case ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE: return ItemPropertyLimitUseByRace(nSubTypeValue);
        case ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT: return ItemPropertyLimitUseBySAlign(nSubTypeValue);
        case ITEM_PROPERTY_REGENERATION_VAMPIRIC: return ItemPropertyVampiricRegeneration(nCostTableValue);
        case ITEM_PROPERTY_TRAP: return ItemPropertyTrap(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_TRUE_SEEING: return ItemPropertyTrueSeeing();
        case ITEM_PROPERTY_ON_MONSTER_HIT: return ItemPropertyOnMonsterHitProperties(nSubTypeValue);
        case ITEM_PROPERTY_TURN_RESISTANCE: return ItemPropertyTurnResistance(nCostTableValue);
        case ITEM_PROPERTY_MASSIVE_CRITICALS: return ItemPropertyMassiveCritical(nCostTableValue);
        case ITEM_PROPERTY_FREEDOM_OF_MOVEMENT: return ItemPropertyFreeAction();
        case ITEM_PROPERTY_MONSTER_DAMAGE: return ItemPropertyMonsterDamage(nCostTableValue);
        case ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL: return ItemPropertyImmunityToSpellLevel(nCostTableValue);
        case ITEM_PROPERTY_SPECIAL_WALK: return ItemPropertySpecialWalk(nSubTypeValue);
        case ITEM_PROPERTY_HEALERS_KIT: return ItemPropertyHealersKit(nCostTableValue);
        case ITEM_PROPERTY_WEIGHT_INCREASE: return ItemPropertyWeightIncrease(nParam1Value);
        case ITEM_PROPERTY_ONHITCASTSPELL: return ItemPropertyOnHitCastSpell(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_VISUALEFFECT: return ItemPropertyVisualEffect(nSubTypeValue);
        case ITEM_PROPERTY_ARCANE_SPELL_FAILURE: return ItemPropertyArcaneSpellFailure(nCostTableValue);
        case ITEM_PROPERTY_USE_LIMITATION_ABILITY_SCORE: return ItemPropertyLimitUseByAbility(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_USE_LIMITATION_SKILL_RANKS: return ItemPropertyLimitUseBySkill(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_USE_LIMITATION_SPELL_LEVEL: return ItemPropertyLimitUseBySpellcasting(nCostTableValue);
        case ITEM_PROPERTY_USE_LIMITATION_ARCANE_SPELL_LEVEL: return ItemPropertyLimitUseByArcaneSpellcasting(nCostTableValue);
        case ITEM_PROPERTY_USE_LIMITATION_DIVINE_SPELL_LEVEL: return ItemPropertyLimitUseByDivineSpellcasting(nCostTableValue);
        case ITEM_PROPERTY_USE_LIMITATION_SNEAK_ATTACK: return ItemPropertyLimitUseBySneakAttackDice(nCostTableValue);
        case ITEM_PROPERTY_USE_LIMITATION_GENDER:
        {   //no Use Limitation: Gender function entry
            //return ItemPropertyAbilityBonus(nSubTypeValue);
            break;
        }
        case ITEM_PROPERTY_SPEED_INCREASE:
        {   //no Speed Increase function entry
            //return ItemPropertyAbilityBonus(nCostTableValue);
            break;
        }
        case ITEM_PROPERTY_SPEED_DECREASE:
            //no Speed Decrease function entry
            //return ItemPropertyAbilityBonus(nCostTableValue);
        case ITEM_PROPERTY_AREA_OF_EFFECT: return ItemPropertyAreaOfEffect(nSubTypeValue, nCostTableValue);
        //requires spellid passed as subtype instead of actual subtype
        case ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL: return ItemPropertyCastSpellCasterLevel(nSubTypeValue, nCostTableValue);
        //requires spellid passed as subtype instead of actual subtype
        case ITEM_PROPERTY_CAST_SPELL_METAMAGIC: return ItemPropertyCastSpellMetamagic(nSubTypeValue, nCostTableValue);
        //requires spellid passed as subtype instead of actual subtype
        case ITEM_PROPERTY_CAST_SPELL_DC: return ItemPropertyCastSpellDC(nSubTypeValue, nCostTableValue);
        case ITEM_PROPERTY_PNP_HOLY_AVENGER: return ItemPropertyPnPHolyAvenger();
        case ITEM_PROPERTY_WIZARDRY: return ItemPropertyWizardry(nCostTableValue);
        case ITEM_PROPERTY_DIVINITY: return ItemPropertyDivinity(nCostTableValue);
        case ITEM_PROPERTY_MATERIAL: return ItemPropertyMaterial(nCostTableValue);
        case ITEM_PROPERTY_QUALITY: return ItemPropertyQuality(nCostTableValue);
        case ITEM_PROPERTY_ADDITIONAL: return ItemPropertyAdditional(nCostTableValue);
		case ITEM_PROPERTY_ECHOBLADE: return ItemPropertyEchoblade();


        //ROOM FOR MORE - 89 so far, need increase/decrease cost
        /*
        case ITEM_PROPERTY_ABILITY_BONUS:
        {
            return ItemPropertyAbilityBonus(nSubTypeValue, nCostTableValue);
            break;
        }
        */
    }
    return ip;
}

struct ipstruct GetIpStructFromString(string sIp)
{
    struct ipstruct iptemp;
    //initialise variables
    string sTemp = sIp;
    string sSub;
    int nLength = GetStringLength(sTemp);
    int nPosition;
    int nTemp;
    int i;

    for(i = 0; i < 4; i++)
    {
        nPosition = FindSubString(sTemp, "_");
        sSub = (nPosition == -1) ? sTemp : GetStringLeft(sTemp, nPosition);
        nLength -= (nPosition + 1);
        if(sSub == "*")
            nTemp = -1;
        else
            nTemp = StringToInt(sSub);
        switch(i)
        {
            case 0: iptemp.type = nTemp; break;
            case 1: iptemp.subtype = nTemp; break;
            case 2: iptemp.costtablevalue = nTemp; break;
            case 3: iptemp.param1value = nTemp; break;
        }
        sTemp = GetSubString(sTemp, nPosition + 1, nLength);
    }
    return iptemp;
}

string PRCGetItemAppearanceString(object oPC, object oItem)
{
    int nBase = GetBaseItemType(oItem);
    int nModelType = StringToInt(Get2DACache("baseitems", "ModelType", nBase));
    //PRCSetAppearanceArray(oPC, sString);
    string sReturn = "";

    switch(nModelType)
    {
        case 0:
        {   //simple model, 1 value
            sReturn = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0));
            break;
        }
        case 1:
        {   //helmet, cloak, model + 6 colours, 7 values
            sReturn = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2))
                        ;
            break;
        }
        case 2:
        {   //weapon, 3 sections + 3 colours, 6 values
            sReturn = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP))
                        ;
            break;
        }
        case 3:
        {   //armour, 19 sections + 6 colours, 25 values
            sReturn = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_PELVIS)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_BELT)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_NECK)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOREARM)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOREARM)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RBICEP)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LBICEP)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHOULDER)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHOULDER)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_ROBE)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1)) + "-" +
                        IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2))
                        ;
            break;
        }
    }
    return sReturn;
}

//reads a string with ints delimited by "-", then set the appearance
//  of an item accordingly
object PRCSetItemAppearance(object oPC, object oItem, string sArray, string sName = PRC_CRAFT_APPEARANCE_ARRAY)
{
    //initialise array
    if(array_exists(oPC, sName))
        array_delete(oPC, sName);
    array_create(oPC, sName);
    //initialise variables
    string sTemp = sArray;
    string sSub;
    int nLength = GetStringLength(sTemp);
    int nPosition;
    int nTemp;
    int nIndex = 0;
    object oChest = GetTempCraftChest();
    object oTemp;
    while(nLength > 0)
    {
        nPosition = FindSubString(sTemp, "-");
        if(nPosition == -1)
        {   //last value
            sSub = sTemp;
            nLength = 0;
        }
        else
        {
            sSub = GetStringLeft(sTemp, nPosition);
            nLength -= (nPosition + 1);
        }
        if(sSub == "*")
            nTemp = -1;
        else
            nTemp = StringToInt(sSub);
        array_set_int(oPC, sName, nIndex, nTemp);
        nIndex++;
        if(nPosition == -1) break;  //last value
        if(nLength < 0)
        {
            if(DEBUG) DoDebug("PRCSetItemAppearanceString: Error processing string");
            return oItem;   //something went wrong
        }
        sTemp = GetSubString(sTemp, nPosition + 1, nLength);
    }
    int nBase = GetBaseItemType(oItem);
    int nModelType = StringToInt(Get2DACache("baseitems", "ModelType", nBase));
    DestroyObject(oItem);
    oItem = CopyItem(oItem, oChest, TRUE);
    switch(nModelType)
    {
        case 0:
        {   //simple model, 1 value
            nTemp = array_get_int(oPC, sName, 0);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nTemp, TRUE);
            }
            break;
        }
        case 1:
        {   //helmet, cloak, model + 6 colours, 7 values, cloak model change doesn't work in 1.68
            nTemp = array_get_int(oPC, sName, 0);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 1);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 2);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 3);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 4);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 5);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 6);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, nTemp, TRUE);
            }
            break;
        }
        case 2:
        {   //weapon, 3 sections + 3 colours, 6 values
            nTemp = array_get_int(oPC, sName, 0);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 1);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 2);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 3);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 4);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 5);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP, nTemp, TRUE);
            }
            break;
        }
        case 3:
        {   //armour, 19 sections + 6 colours, 25 values
            nTemp = array_get_int(oPC, sName, 0);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 1);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 2);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 3);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 4);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 5);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 6);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_PELVIS, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 7);
            if(nTemp != -1)
            {
                if(FloatToInt(StringToFloat(Get2DACache("parts_chest", "ACBONUS", GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO)))) == FloatToInt(StringToFloat(Get2DACache("parts_chest", "ACBONUS", nTemp))))
                {   //won't allow change to armour with different AC
                    DestroyObject(oItem);
                    oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO, nTemp, TRUE);
                }
                else
                {
                    SendMessageToPC(oPC, "This torso appearance has a different AC value to the current appearance, aborting torso change.");
                }
            }
            nTemp = array_get_int(oPC, sName, 8);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_BELT, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 9);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_NECK, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 10);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOREARM, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 11);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOREARM, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 12);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RBICEP, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 13);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LBICEP, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 14);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHOULDER, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 15);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHOULDER, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 16);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 17);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 18);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_ROBE, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 19);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 20);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 21);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 22);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 23);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, nTemp, TRUE);
            }
            nTemp = array_get_int(oPC, sName, 24);
            if(nTemp != -1)
            {
                DestroyObject(oItem);
                oItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, nTemp, TRUE);
            }
            break;
        }
    }
    DestroyObject(oItem);
    oItem = CopyItem(oItem, oPC, TRUE);
    return oItem;
}
/*
int ITEM_APPR_TYPE_SIMPLE_MODEL         = 0;
int ITEM_APPR_TYPE_WEAPON_COLOR         = 1;
int ITEM_APPR_TYPE_WEAPON_MODEL         = 2;
int ITEM_APPR_TYPE_ARMOR_MODEL          = 3;
int ITEM_APPR_TYPE_ARMOR_COLOR          = 4;
int ITEM_APPR_NUM_TYPES                 = 5;

int ITEM_APPR_ARMOR_COLOR_LEATHER1      = 0;
int ITEM_APPR_ARMOR_COLOR_LEATHER2      = 1;
int ITEM_APPR_ARMOR_COLOR_CLOTH1        = 2;
int ITEM_APPR_ARMOR_COLOR_CLOTH2        = 3;
int ITEM_APPR_ARMOR_COLOR_METAL1        = 4;
int ITEM_APPR_ARMOR_COLOR_METAL2        = 5;
int ITEM_APPR_ARMOR_NUM_COLORS          = 6;

int ITEM_APPR_ARMOR_MODEL_RFOOT         = 0;
int ITEM_APPR_ARMOR_MODEL_LFOOT         = 1;
int ITEM_APPR_ARMOR_MODEL_RSHIN         = 2;
int ITEM_APPR_ARMOR_MODEL_LSHIN         = 3;
int ITEM_APPR_ARMOR_MODEL_LTHIGH        = 4;
int ITEM_APPR_ARMOR_MODEL_RTHIGH        = 5;
int ITEM_APPR_ARMOR_MODEL_PELVIS        = 6;
int ITEM_APPR_ARMOR_MODEL_TORSO         = 7;
int ITEM_APPR_ARMOR_MODEL_BELT          = 8;
int ITEM_APPR_ARMOR_MODEL_NECK          = 9;
int ITEM_APPR_ARMOR_MODEL_RFOREARM      = 10;
int ITEM_APPR_ARMOR_MODEL_LFOREARM      = 11;
int ITEM_APPR_ARMOR_MODEL_RBICEP        = 12;
int ITEM_APPR_ARMOR_MODEL_LBICEP        = 13;
int ITEM_APPR_ARMOR_MODEL_RSHOULDER     = 14;
int ITEM_APPR_ARMOR_MODEL_LSHOULDER     = 15;
int ITEM_APPR_ARMOR_MODEL_RHAND         = 16;
int ITEM_APPR_ARMOR_MODEL_LHAND         = 17;
int ITEM_APPR_ARMOR_MODEL_ROBE          = 18;
int ITEM_APPR_ARMOR_NUM_MODELS          = 19;

int ITEM_APPR_WEAPON_MODEL_BOTTOM       = 0;
int ITEM_APPR_WEAPON_MODEL_MIDDLE       = 1;
int ITEM_APPR_WEAPON_MODEL_TOP          = 2;

int ITEM_APPR_WEAPON_COLOR_BOTTOM       = 0;
int ITEM_APPR_WEAPON_COLOR_MIDDLE       = 1;
int ITEM_APPR_WEAPON_COLOR_TOP          = 2;
*/

//:: void main () {}
