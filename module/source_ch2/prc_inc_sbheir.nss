//::///////////////////////////////////////////////
//:: Shining Blade of Heironeous include
//:: prc_inc_sbheir
//::///////////////////////////////////////////////

#include "prc_inc_util"
#include "inc_item_props"

const int SHINING_BLADE_LEVEL_SHOCK = 1;
const int SHINING_BLADE_LEVEL_HOLY = 2;
const int SHINING_BLADE_LEVEL_BRILLIANT = 3;

const string PRC_ShiningBlade_Generation = "PRC_ShiningBlade_Generation";
const string PRC_ShiningBlade_Level = "PRC_ShiningBladeLevel";
const string PRC_ShiningBlade_Duration = "PRC_ShiningBladeDuration";

void ShiningBlade_RemoveProperties(object oWeapon, int nLevel)
{
    itemproperty iTest = GetFirstItemProperty(oWeapon);
    while(GetIsItemPropertyValid(iTest))
    {
        int bRemove = FALSE;
        if (GetItemPropertyDurationType(iTest) == DURATION_TYPE_TEMPORARY)
        {
            switch(GetItemPropertyType(iTest))
            {
                case ITEM_PROPERTY_DAMAGE_BONUS:
                    if (nLevel >= SHINING_BLADE_LEVEL_SHOCK)
                        bRemove = (GetItemPropertySubType(iTest) == IP_CONST_DAMAGETYPE_ELECTRICAL) && (GetItemPropertyCostTableValue(iTest) == DAMAGE_BONUS_1d6);
                    break;
                case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP:
                    if (nLevel >= SHINING_BLADE_LEVEL_HOLY)
                        bRemove = (GetItemPropertySubType(iTest) == IP_CONST_ALIGNMENTGROUP_EVIL) && (GetItemPropertyParam1Value(iTest) == IP_CONST_DAMAGETYPE_DIVINE) && (GetItemPropertyCostTableValue(iTest) == DAMAGE_BONUS_2d6);
                    break;
                case ITEM_PROPERTY_LIGHT:
                    if (nLevel >= SHINING_BLADE_LEVEL_BRILLIANT)
                        bRemove = TRUE;
                    break;
            }
        }
        if (bRemove)
            RemoveItemProperty(oWeapon, iTest);
        iTest = GetNextItemProperty(oWeapon);
    }
}

void ShockBlade_ApplyProperties(object oWeapon, int nDuration)
{
    //Remove any old properties
    
    ShiningBlade_RemoveProperties(oWeapon, SHINING_BLADE_LEVEL_SHOCK);

    //Add the new properties

    if (nDuration)
        AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_ELECTRICAL, DAMAGE_BONUS_1d6), oWeapon, RoundsToSeconds(nDuration));
}

void HolyBlade_ApplyProperties(object oWeapon, int nDuration)
{
    //Remove any old properties
    
    ShiningBlade_RemoveProperties(oWeapon, SHINING_BLADE_LEVEL_HOLY);

    //Add the new properties

    if (nDuration)
    {
        AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_ELECTRICAL, DAMAGE_BONUS_1d6), oWeapon, RoundsToSeconds(nDuration));
        AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyDamageBonusVsAlign(IP_CONST_ALIGNMENTGROUP_EVIL, IP_CONST_DAMAGETYPE_DIVINE, DAMAGE_BONUS_2d6), oWeapon, RoundsToSeconds(nDuration));
    }
}

void BrilliantBlade_ApplyProperties(object oWeapon, int nDuration)
{
    //Remove any old properies
    
    ShiningBlade_RemoveProperties(oWeapon, SHINING_BLADE_LEVEL_BRILLIANT);

    //Add the new properties

    if (nDuration)
    {
        AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_ELECTRICAL, DAMAGE_BONUS_1d6), oWeapon, RoundsToSeconds(nDuration));
        AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyDamageBonusVsAlign(IP_CONST_ALIGNMENTGROUP_EVIL, IP_CONST_DAMAGETYPE_DIVINE, DAMAGE_BONUS_2d6), oWeapon, RoundsToSeconds(nDuration));
        AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyLight(IP_CONST_LIGHTBRIGHTNESS_BRIGHT, IP_CONST_LIGHTCOLOR_WHITE), oWeapon, RoundsToSeconds(nDuration));
    }
}

void BrilliantBlade_ApplyAttackBonuses(object oPC, int bOnHand, int bOffHand)
{
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectAttackIncrease(20, nAttackBonusHand)), oPC, RoundsToSeconds(nDuration));
        //This applies the attack bonus only to hands currently containing longsword, 
        //but incorrectly the bonus is still active if the longsword is exchanged for another weapon.

    //AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyAttackBonus(20), oWeapon, RoundsToSeconds(nDuration));
        //This adds the bonus only to the correct wielded weapon(s), but won't increase AB with
        //a longsword that one is not wielding at the time the bonus is applied.
        //Note: theoretically, we should increase the AB of the weapon by 20, not set it to 20; however, since the AB
        //cap is 20, and the AB of a weapon is included in the cap, it makes little practical difference.
        //NOTE: this provide +20 DR penetration, so it's a no-go (see http://nwn.wikia.com/wiki/Damage_reduction)            

    SetCompositeAttackBonus(oPC, "SB_BrilliantBlade_R", bOnHand?20:0, ATTACK_BONUS_ONHAND);
    SetCompositeAttackBonus(oPC, "SB_BrilliantBlade_L", bOffHand?20:0, ATTACK_BONUS_OFFHAND);
}

void ShiningBlade_ApplyProperties(object oWeapon, int nDuration, int nLevel)
{
    switch(nLevel)
    {
        case SHINING_BLADE_LEVEL_SHOCK:
            ShockBlade_ApplyProperties(oWeapon, nDuration);
            break;

        case SHINING_BLADE_LEVEL_HOLY:
            HolyBlade_ApplyProperties(oWeapon, nDuration);
            break;

        case SHINING_BLADE_LEVEL_BRILLIANT:
            BrilliantBlade_ApplyProperties(oWeapon, nDuration);
            break;
    }
}

void ShiningBlade_ApplyAttackBonuses(object oPC, int bOnHand, int bOffHand, int nLevel)
{
    if (nLevel >= SHINING_BLADE_LEVEL_BRILLIANT)
        BrilliantBlade_ApplyAttackBonuses(oPC, bOnHand, bOffHand);
    else
        BrilliantBlade_ApplyAttackBonuses(oPC, FALSE, FALSE);
}

void ShiningBlade_ExpireBonuses(object oPC, int nGeneration, int nLevel)
{
    int nShiningBladeGeneration = GetLocalInt(oPC, PRC_ShiningBlade_Generation);
    if (nGeneration == nShiningBladeGeneration)
    {
        if (DEBUG) DoDebug("Expiring Shining Blade bonuses");

        //Zero out variables so that equipping a weapon doesn't reapply the expired bonuses
        SetLocalInt(oPC, PRC_ShiningBlade_Duration, 0);
        SetLocalInt(oPC, PRC_ShiningBlade_Level, 0);

        //Expire bonsues on wielded weapons
        object oOnHandWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
        object oOffHandWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
        if (GetBaseItemType(oOnHandWeapon) == BASE_ITEM_LONGSWORD)
            ShiningBlade_RemoveProperties(oOnHandWeapon, nLevel);
        if (GetBaseItemType(oOffHandWeapon) == BASE_ITEM_LONGSWORD)
            ShiningBlade_RemoveProperties(oOffHandWeapon, nLevel);

        //Expire attack bonuses
        ShiningBlade_ApplyAttackBonuses(oPC, FALSE, FALSE, nLevel);
    }
    else
    {
        //The Brilliant/Holy/Shock Blade feat has been used again since this removal was scheduled, 
        //so don't expire--the next application of the feat will expire them
        //when *it's* time runs out.
        if (DEBUG) DoDebug("Not expiring Shining Blade bonuses: " + IntToString(nGeneration) + ", " + IntToString(nShiningBladeGeneration));
    }
}

void ShiningBlade_ScheduleBonusExpiration(object oPC, int nDuration, int nLevel)
{
    int nGeneration = PRC_NextGeneration(GetLocalInt(oPC, PRC_ShiningBlade_Generation));
    SetLocalInt(oPC, PRC_ShiningBlade_Generation, nGeneration);
    DelayCommand(RoundsToSeconds(nDuration), ShiningBlade_ExpireBonuses(oPC, nGeneration, nLevel));
}
