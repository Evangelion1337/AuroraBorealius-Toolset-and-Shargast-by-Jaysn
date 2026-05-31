//::///////////////////////////////////////////////
//:: Name        Lich
//:: FileName    pnp_lich_inc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*  Functions needed to handle the amulet, soul gem, and hide

*/
//:://////////////////////////////////////////////
//:: Created By: Shane Hennessy
//:: Created On:
//:://////////////////////////////////////////////

// Returns the lich amulet level
int GetAmuletLevel(object oAmulet);
// Sets the passed in amulet to nLevel
void LevelUpAmulet(object oAmulet,int nLevel);
// Returns the lich power level
int GetPowerLevel(object oHide);
// Sets the passed in hide on the PC to nLevel
void LevelUpHide(object oPC, object oHide, int nLevel);
// Creates some VFX on the object when crafting
void CraftVFX(object oObject);

#include "inc_utility"
#include "pnp_shft_main"

void LichSkills(object oHide, int iLevel)
{
    SetCompositeBonus(oHide, "LichSkillHide", iLevel, ITEM_PROPERTY_SKILL_BONUS, SKILL_HIDE);
    SetCompositeBonus(oHide, "LichSkillListen", iLevel, ITEM_PROPERTY_SKILL_BONUS, SKILL_LISTEN);
    SetCompositeBonus(oHide, "LichSkillPersuade", iLevel, ITEM_PROPERTY_SKILL_BONUS, SKILL_PERSUADE);
    SetCompositeBonus(oHide, "LichSkillSilent", iLevel, ITEM_PROPERTY_SKILL_BONUS, SKILL_MOVE_SILENTLY);
    SetCompositeBonus(oHide, "LichSkillSearch", iLevel, ITEM_PROPERTY_SKILL_BONUS, SKILL_SEARCH);
    SetCompositeBonus(oHide, "LichSkillSpot", iLevel, ITEM_PROPERTY_SKILL_BONUS, SKILL_SPOT);
}

int GetAmuletLevel(object oAmulet)
{
    object oPC = GetFirstPC();
    //SendMessageToPC(oPC,"Amulet level func");
    itemproperty iProp = GetFirstItemProperty(oAmulet);
    int nLevel = 0;

    while (GetIsItemPropertyValid(iProp))
    {
        if (GetItemPropertyType(iProp) == ITEM_PROPERTY_AC_BONUS)
        {
            //SendMessageToPC(oPC," AC found");
            int nAC = GetItemPropertyCostTableValue(iProp);
            //SendMessageToPC(oPC, "AC = " + IntToString(nAC));
            switch (nAC)
            {
            case 2:
                return 1;
            case 3:
                return 2;
            case 4:
                return 3;
            case 5:
                // cant return because anything above has this AC 5 bonus
                nLevel = 4;
                break;
            default:
                return 0;
            }
        }
        // for levels above 4 use a junk item like weight reduction
        if (GetItemPropertyType(iProp) == ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION)
        {
            int nWt = GetItemPropertyCostTableValue(iProp);
            //SendMessageToPC(oPC, "wt = " + IntToString(nWt));
            switch(nWt)
            {
            case IP_CONST_REDUCEDWEIGHT_10_PERCENT:
                return 5;
            case IP_CONST_REDUCEDWEIGHT_20_PERCENT:
                return 6;
            case IP_CONST_REDUCEDWEIGHT_40_PERCENT:
                return 7;
            case IP_CONST_REDUCEDWEIGHT_60_PERCENT:
                return 8;
            case IP_CONST_REDUCEDWEIGHT_80_PERCENT:
                return 9;
            default:
                return 0;
            }
        }
        // level 10 gets something special (we ran out of weight reduction)
        if (GetItemPropertyType(iProp) == ITEM_PROPERTY_CAST_SPELL)
        {
            int nSpell = GetItemPropertySubType(iProp);

            if (nSpell == IP_CONST_CASTSPELL_CREATE_GREATER_UNDEAD_18)
                return 10;
        }

        iProp = GetNextItemProperty(oAmulet);
    }
    return nLevel;
}

int GetPowerLevel(object oPC)
{
    return GetLocalInt(oPC, "PNP_LichPowerLevel");
}

void LevelUpHide(object oPC, object oHide, int nLevel)
{
    itemproperty iprop;

    // Clean the hide of all things that dont stack
    // remember to put everything for every level back on!
    // - Now the event scripts give us a new hide.
    //RemoveAllNonComposite(oHide);

    // Common things for being undead and a lich
    if (nLevel >= 4)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichCon", 12, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_CON);
        IPSafeAddItemProperty(oHide, PRCItemPropertyBonusFeat(IP_CONST_FEAT_UNDEAD_HD), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);    

        // Undead abilities
        iprop = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_CRITICAL_HITS);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        iprop = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_BACKSTAB);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        iprop = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_DEATH_MAGIC);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        iprop = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_DISEASE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        iprop = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        iprop = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_MINDSPELLS);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        iprop = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_PARALYSIS);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        iprop = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_POISON);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        // 100 % immune to cold
        iprop = ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_COLD,IP_CONST_DAMAGEIMMUNITY_100_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        // 100 % immune to electric
        iprop = ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_ELECTRICAL,IP_CONST_DAMAGEIMMUNITY_100_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        // Bugfix
        iprop = ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_NEGATIVE, IP_CONST_DAMAGEIMMUNITY_100_PERCENT);
        IPSafeAddItemProperty(oHide, iprop, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);        
    }

    // Level 1 hide
    if (nLevel == 1)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 2, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 1, ITEM_PROPERTY_TURN_RESISTANCE);

        //Lich skills +2
        LichSkills(oHide, 2);

        //Damage reduction 5/- cold
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_COLD,IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 5/- electric
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ELECTRICAL,IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    // Level 2
    else if (nLevel == 2)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 2, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 2, ITEM_PROPERTY_TURN_RESISTANCE);

        //Lich skills +4
        LichSkills(oHide, 4);

        //Damage reduction 5/+1
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_1,IP_CONST_DAMAGESOAK_5_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 10/- cold
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_COLD,IP_CONST_DAMAGERESIST_10);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 10/- electric
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ELECTRICAL,IP_CONST_DAMAGERESIST_10);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    else if (nLevel == 3)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 2, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        //SetCompositeBonus(oHide, "LichWis", 2, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_WIS);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 3, ITEM_PROPERTY_TURN_RESISTANCE);
        //Lich skills +6
        LichSkills(oHide, 6);


        //Damage reduction 10/1
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_1,IP_CONST_DAMAGESOAK_10_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 20/- cold
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_COLD,IP_CONST_DAMAGERESIST_20);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 20/- electric
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ELECTRICAL,IP_CONST_DAMAGERESIST_20);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    else if (nLevel == 4)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 2, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        //SetCompositeBonus(oHide, "LichWis", 2, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_WIS);
        //SetCompositeBonus(oHide, "LichCha", 2, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_CHA);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 4, ITEM_PROPERTY_TURN_RESISTANCE);
        //Lich skills +8
        LichSkills(oHide, 8);

        //Damage reduction 15/1
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_1,IP_CONST_DAMAGESOAK_15_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    else if (nLevel == 5)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 3, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        //SetCompositeBonus(oHide, "LichWis", 3, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_WIS);
        //SetCompositeBonus(oHide, "LichCha", 3, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_CHA);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 5, ITEM_PROPERTY_TURN_RESISTANCE);
        //Lich skills +10
        LichSkills(oHide, 10);


        //Damage reduction 5/+5
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_5,IP_CONST_DAMAGESOAK_5_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 5/- ACID
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ACID,IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 5/- fire
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_FIRE,IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 5/- sonic
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SONIC,IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        // Spell level immune to 1 and lower
        iprop = ItemPropertyImmunityToSpellLevel(1);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    else if (nLevel == 6)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 4, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        //SetCompositeBonus(oHide, "LichWis", 4, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_WIS);
        //SetCompositeBonus(oHide, "LichCha", 4, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_CHA);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 8, ITEM_PROPERTY_TURN_RESISTANCE);
        //Lich skills +12
        LichSkills(oHide, 12);

        //Damage reduction 10/+8
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_8,IP_CONST_DAMAGESOAK_10_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 10/- ACID
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ACID,IP_CONST_DAMAGERESIST_10);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 10/- fire
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_FIRE,IP_CONST_DAMAGERESIST_10);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 10/- sonic
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SONIC,IP_CONST_DAMAGERESIST_10);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        // Spell level immune to 3 and lower
        iprop = ItemPropertyImmunityToSpellLevel(3);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    else if (nLevel == 7)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 6, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        //SetCompositeBonus(oHide, "LichWis", 6, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_WIS);
        //SetCompositeBonus(oHide, "LichCha", 6, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_CHA);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 11, ITEM_PROPERTY_TURN_RESISTANCE);
        //Lich skills +14
        LichSkills(oHide, 14);

        //Damage reduction 15/+11
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_11,IP_CONST_DAMAGESOAK_15_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 10/- ACID
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ACID,IP_CONST_DAMAGERESIST_10);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 10/- fire
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_FIRE,IP_CONST_DAMAGERESIST_10);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 10/- sonic
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SONIC,IP_CONST_DAMAGERESIST_10);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        // Spell level immune to 5 and lower
        iprop = ItemPropertyImmunityToSpellLevel(5);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    else if (nLevel == 8)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 7, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        //SetCompositeBonus(oHide, "LichWis", 7, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_WIS);
        //SetCompositeBonus(oHide, "LichCha", 7, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_CHA);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 14, ITEM_PROPERTY_TURN_RESISTANCE);
        //Lich skills +16
        LichSkills(oHide, 16);

        //Damage reduction 20/+14
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_14,IP_CONST_DAMAGESOAK_20_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 15/- ACID
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ACID,IP_CONST_DAMAGERESIST_15);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 15/- fire
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_FIRE,IP_CONST_DAMAGERESIST_15);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 15/- sonic
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SONIC,IP_CONST_DAMAGERESIST_15);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);

        // Spell level immune to 7 and lower
        iprop = ItemPropertyImmunityToSpellLevel(7);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    else if (nLevel == 9)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 8, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        //SetCompositeBonus(oHide, "LichWis", 8, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_WIS);
        //SetCompositeBonus(oHide, "LichCha", 8, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_CHA);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 17, ITEM_PROPERTY_TURN_RESISTANCE);
        //Lich skills +18
        LichSkills(oHide, 18);

        //Damage reduction 25/+17
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_17,IP_CONST_DAMAGESOAK_25_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 15/- ACID
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ACID,IP_CONST_DAMAGERESIST_15);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 15/- fire
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_FIRE,IP_CONST_DAMAGERESIST_15);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 15/- sonic
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SONIC,IP_CONST_DAMAGERESIST_15);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);

        // Spell level immune to 8 and lower
        iprop = ItemPropertyImmunityToSpellLevel(8);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }
    else if (nLevel == 10)
    {
        // Ability bonus
        //SetCompositeBonus(oHide, "LichInt", 10, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_INT);
        //SetCompositeBonus(oHide, "LichWis", 10, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_WIS);
        //SetCompositeBonus(oHide, "LichCha", 10, ITEM_PROPERTY_ABILITY_BONUS, IP_CONST_ABILITY_CHA);
        // Turn resistance
        SetCompositeBonus(oHide, "LichTurn", 20, ITEM_PROPERTY_TURN_RESISTANCE);
        //Lich skills +20
        LichSkills(oHide, 20);

        //Damage reduction 30/+20
        iprop = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_20,IP_CONST_DAMAGESOAK_30_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 20/- ACID
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ACID,IP_CONST_DAMAGERESIST_20);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 20/- fire
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_FIRE,IP_CONST_DAMAGERESIST_20);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        //Damage reduction 20/- sonic
        iprop = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SONIC,IP_CONST_DAMAGERESIST_20);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
        // Spell level immune to 9 and lower
        iprop = ItemPropertyImmunityToSpellLevel(9);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oHide);
    }

    SetLocalInt(oPC, "PNP_LichPowerLevel", nLevel);
}

void LevelUpAmulet(object oAmulet,int nLevel)
{
    RemoveAllItemProperties(oAmulet);
    itemproperty iprop;

    // Common level 4 and above things
    if (nLevel >= 4)
    {
        // Ac bonus
        iprop = ItemPropertyACBonus(5);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
        // Extra so the amulet is useful til 20th level
        iprop = ItemPropertyRegeneration(1);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
        iprop = ItemPropertyCastSpell(IP_CONST_CASTSPELL_ANIMATE_DEAD_15,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
        iprop = PRCItemPropertyBonusFeat(IP_CONST_FEAT_SPELLFOCUSNEC);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }

    // Level 2
    if (nLevel == 2)
    {
        // Ac bonus
        iprop = ItemPropertyACBonus(3);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }
    else if (nLevel == 3)
    {
        // Ac bonus
        iprop = ItemPropertyACBonus(4);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }
    else if (nLevel == 4)
    {
        // nothing
    }
    else if (nLevel == 5)
    {
        // reduction is used to permenantly track how much the PC has paid for level ups
        // because reduction of 1/2 lb is nothing usefull
        iprop = ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_10_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }
    else if (nLevel == 6)
    {
        iprop = ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_20_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }
    else if (nLevel == 7)
    {
        iprop = ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_40_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }
    else if (nLevel == 8)
    {
        iprop = ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_60_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }
    else if (nLevel == 9)
    {
        iprop = ItemPropertyWeightReduction(IP_CONST_REDUCEDWEIGHT_80_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }
    else if (nLevel == 10)
    {
        iprop = ItemPropertyCastSpell(IP_CONST_CASTSPELL_CREATE_GREATER_UNDEAD_18,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iprop,oAmulet);
    }
}

void CraftVFX(object oObject)
{
    effect eFx = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_EVIL);
    ApplyEffectToObject(DURATION_TYPE_INSTANT,eFx,oObject,3.0);
    eFx = EffectVisualEffect(VFX_FNF_LOS_EVIL_30);
    ApplyEffectToObject(DURATION_TYPE_INSTANT,eFx,oObject, 4.0);
}


