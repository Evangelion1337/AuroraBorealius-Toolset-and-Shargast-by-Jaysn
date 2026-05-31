//::///////////////////////////////////////////////
//:: Poison System includes
//:: inc_poison
//::///////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 12.12.2004
//:: Updated On: 09.01.2005
//:://////////////////////////////////////////////


const int POISONED_WEAPON_CASTERLEVEL = 1;

const int STRREF_POISON_WORN_OFF             = 16826227;
const int STRREF_POISON_APPLY_SUCCESS        = 16826228;
const int STRREF_POISON_APPLY_FAILURE        = 16826230;
const int STRREF_POISON_CLEAN_OFF_WEAPON     = 16826229;
const int STRREF_POISON_NOT_VALID_FOR_WEAPON = 16826231;
const int STRREF_SHATTER_HARMLESS            = 16826234;
const int STRREF_POISON_ITEM_USE_1           = 16826236;
const int STRREF_POISON_ITEM_USE_2           = 16826237;
const int STRREF_POISON_FOOD_USE_1           = 16826239;
const int STRREF_POISON_FOOD_USE_2           = 16826240;
const int STRREF_CLEAN_ITEM_SUCCESS          = 16826242;
const int STRREF_CLEAN_ITEM_FAIL_1           = 16826243;
const int STRREF_CLEAN_ITEM_FAIL_2           = 16826244;
const int STRREF_INVALID_TARGET              = 16826245;
const int STRREF_NOT_CONTACT_POISON          = 16826246;
const int STRREF_TARGET_ALREADY_POISONED     = 16826247;
const int STRREF_NOT_INGESTED_POISON         = 16826251;
const int STRREF_TARGET_NOT_FOOD             = 16826252;
const int STRREF_ACQUIRE_SPOT_SUCCESS1       = 16826253;
const int STRREF_ACQUIRE_SPOT_SUCCESS2       = 16826254;
const int STRREF_ONEQUIP_CLEAN_ITEM          = 16826255;

const int POISON_TYPE_CONTACT  = 0;
const int POISON_TYPE_INGESTED = 1;
const int POISON_TYPE_INHALED  = 2;
const int POISON_TYPE_INJURY   = 3;

/**
 * Gets the type of the given poison.
 *
 * @param nPoison POISON_* constant
 * @return        POISON_TYPE_* constant
 */
int GetPoisonType(int nPoison);


// Poison removal handlers
void DoPoisonRemovalFromWeapon(object oWeapon);
void DoPoisonRemovalFromItem(object oItem);


//#include "inc_utility"
//#include "inc_poison_const"
#include "prc_inc_spells"
#include "prc_ipfeat_const"

/****************************************************
************** The implementations ******************
****************************************************/

int GetPoisonType(int nPoison)
{
    return StringToInt(Get2DACache("poison", "Poison_Type", nPoison));
}

// Handles removing of itemproperties and locals on a poisoned weapon
void DoPoisonRemovalFromWeapon(object oWeapon)
{
    DeleteLocalInt(oWeapon, "pois_wpn_idx");
    DeleteLocalInt(oWeapon, "pois_wpn_uses");
    RemoveEventScript(oWeapon, EVENT_ITEM_ONHIT, "poison_wpn_onhit", TRUE, TRUE);

    // Remove the UniquePower only if poisoning the weapon added it.
    if(GetLocalInt(oWeapon, "PoisonedWeapon_DoDelete"))
        RemoveSpecificProperty(oWeapon,
                               ITEM_PROPERTY_ONHITCASTSPELL,
                               IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER,
                               0,
                               1,
                               "",
                               -1,
                               DURATION_TYPE_PERMANENT);
}

// Handles removing of itemproperties and locals on a poisoned item
void DoPoisonRemovalFromItem(object oItem)
{
    DeleteLocalInt(oItem, "pois_itm_idx");
    DeleteLocalInt(oItem, "pois_itm_uses");
    DeleteLocalInt(oItem, "pois_itm_trap_dc");
    DeleteLocalObject(oItem, "pois_itm_poisoner");

    int nSafeCount = GetLocalInt(oItem, "pois_itm_safecount");
    DeleteLocalInt(oItem, "pois_itm_safecount");
    int i;
    for(i = 1; i <= nSafeCount; i++)
        DeleteLocalObject(oItem, "pois_itm_safe_" + IntToString(i));

    RemoveSpecificProperty(oItem,
                           ITEM_PROPERTY_CAST_SPELL,
                           IP_CONST_CASTSPELL_CLEAN_POISON_OFF,
                           IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE,
                           1,
                           "",
                           -1,
                           DURATION_TYPE_PERMANENT);

    RemoveEventScript(oItem, EVENT_ITEM_ONACQUIREITEM, "poison_onaquire", TRUE, TRUE);
    RemoveEventScript(oItem, EVENT_ITEM_ONPLAYEREQUIPITEM, "poison_onequip", TRUE, TRUE);
}
