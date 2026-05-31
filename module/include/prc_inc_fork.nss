/**
 * @file
 *
 * Functions used to get weapon data.
 * 
 * Mostly functions moved from prc_inc_combat. Used to get weapon data and weapon-related feats based on weapon type.
 * Used by the combat system, weapon restriction/proficiency system and for deity weapons (eg. favoured soul)
 */

//:: Test void
//void main (){}

//////////////////////////////////////////////////
/* Constant definitions                         */
//////////////////////////////////////////////////

// used to select certain types of feats associated with a weapon.
const int FEAT_TYPE_FOCUS                 = 1;
const int FEAT_TYPE_SPECIALIZATION        = 2;
const int FEAT_TYPE_EPIC_FOCUS            = 3;
const int FEAT_TYPE_EPIC_SPECIALIZATION   = 4;
const int FEAT_TYPE_IMPROVED_CRITICAL     = 5;
const int FEAT_TYPE_OVERWHELMING_CRITICAL = 6;
const int FEAT_TYPE_DEVASTATING_CRITICAL  = 7;
const int FEAT_TYPE_WEAPON_OF_CHOICE      = 8;
const int FEAT_TYPE_WEAPON_PROFICIENCY	  = 9;

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////
 
 int GetProficiencyFeatOfWeaponType(int iWeaponType);
 
/**
 * Returns the appropriate weapon feat given a weapon type.
 *
 * Similar to GetFeatByWeaponType(), but should be a bit faster, because it does not use strings
 *
 * @param iWeaponType       BASE_ITEM_* constant for the weapon
 * @param iFeatType         One of:
 *                          FEAT_TYPE_FOCUS,
 *                          FEAT_TYPE_EPIC_FOCUS,
 *                          FEAT_TYPE_SPECIALIZATION,
 *                          FEAT_TYPE_EPIC_SPECIALIZATION,
 *                          FEAT_TYPE_OVERWHELMING_CRITICAL,
 *                          FEAT_TYPE_DEVASTATING_CRITICAL,
 *                          FEAT_TYPE_WEAPON_OF_CHOICE.
 *
 * @return                  Appropriate weapon feat number based on arguments.
 */
int GetFeatOfWeaponType(int iWeaponType, int iFeatType);

/**
 * Returns the weapon focus feat associated with the basetype of the weapon.
 *
 * Creature weapon types count as unarmed for this function. Will return unarmed strike weapon focus 
 * feat if base item is invalid.
 *
 * @param iWeaponType       The BASE_TYPE_* of the weapon.
 * @return                  The weapon focus feat associated with the weapon or unarmed if either a 
 *                          creature weapon or BASE_ITEM_INVALID is passed as argument.
 */
int GetFocusFeatOfWeaponType(int iWeaponType);

/**
 * Returns the weapon specialization feat associated with the basetype of the weapon
 *
 * Creature weapon types count as unarmed for this function. Will return unarmed strike weapon specialization 
 * feat if base item is invalid.
 *
 * @param iWeaponType       The BASE_TYPE_* of the weapon.
 * @return                  The weapon specialization feat associated with the weapon or unarmed if either a 
 *                          creature weapon or BASE_ITEM_INVALID is passed as argument.
 */
int GetSpecializationFeatOfWeaponType(int iWeaponType);

/**
 * Returns the epic weapon focus feat associated with the basetype of the weapon
 *
 * Creature weapon types count as unarmed for this function. Will return unarmed strike epic weapon focus 
 * feat if base item is invalid.
 *
 * @param iWeaponType       The BASE_TYPE_* of the weapon.
 * @return                  The epic weapon focus feat associated with the weapon or unarmed if either a 
 *                          creature weapon or BASE_ITEM_INVALID is passed as argument.
 */
int GetEpicFocusFeatOfWeaponType(int iWeaponType);

/**
 * Returns the epic weapon specialization feat associated with the basetype of the weapon
 *
 * Creature weapon types count as unarmed for this function. Will return unarmed strike epic weapon 
 * specialization feat if base item is invalid.
 *
 * @param iWeaponType       The BASE_TYPE_* of the weapon.
 * @return                  The epic weapon specialization feat associated with the weapon or unarmed
 *                          if either a creature weapon or BASE_ITEM_INVALID is passed as argument.
 */
int GetEpicSpecializationFeatOfWeaponType(int iWeaponType);

/**
 * Returns the improved critical feat associated with the basetype of the weapon
 *
 * Creature weapon types count as unarmed for this function. Will return unarmed strike improved 
 * critical feat if base item is invalid.
 *
 * @param iWeaponType       The BASE_TYPE_* of the weapon.
 * @return                  The improved critical feat associated with the weapon or unarmed
 *                          if either a creature weapon or BASE_ITEM_INVALID is passed as argument.
 */
int GetImprovedCriticalFeatOfWeaponType(int iWeaponType);

/**
 * Returns the overwhelming critical feat associated with the basetype of the weapon
 *
 * Creature weapon types count as unarmed for this function. Will return unarmed strike overwhelming 
 * critical feat if base item is invalid.
 *
 * @param iWeaponType       The BASE_TYPE_* of the weapon.
 * @return                  The overwhelming critical feat associated with the weapon or unarmed
 *                          if either a creature weapon or BASE_ITEM_INVALID is passed as argument.
 */
int GetOverwhelmingCriticalFeatOfWeaponType(int iWeaponType);

/**
 * Returns the devastating critical feat associated with the basetype of the weapon
 *
 * Creature weapon types count as unarmed for this function. Will return unarmed strike devastating 
 * critical feat if base item is invalid.
 *
 * @param iWeaponType       The BASE_TYPE_* of the weapon.
 * @return                  The devastating critical feat associated with the weapon or unarmed
 *                          if either a creature weapon or BASE_ITEM_INVALID is passed as argument.
 */
int GetDevastatingCriticalFeatOfWeaponType(int iWeaponType);

/**
 * Returns the weapon of choice feat associated with the basetype of the weapon
 *
 * Only melee weapons can be weapons of choice. Creature weapon types count as unarmed for this function, so
 * will return -1 along with ranged weapons and invalid base items.
 *
 * @param iWeaponType       The BASE_TYPE_* of the weapon.
 * @return                  The devastating critical feat associated with a melee weapon or -1 if
 *                          ranged or creature weapons, or BASE_ITEM_INVALID is passed as argument.
 */
int GetWeaponOfChoiceFeatOfWeaponType(int iWeaponType);

/**
 * Returns the value of the WeaponType column in baseitem.2da.
 *
 * The number returned will be zero for any Base Item type that is not a weapon,
 * it will have different (positive) numbers for different weapon types
 *
 * @param iBaseType     The BASE_TYPE_* of the weapon.
 * @return              the weapon type of the weapon or 0 if not a weapon
 */
int GetIsWeaponType(int iBaseType);

/**
 * Returns the value of the WeaponType column in baseitem.2da.
 *
 * The number returned will be zero for any item that is not a weapon,
 * it will have different (positive) numbers for different weapon types
 *
 * @param oItem         The item to test.
 * @return              the weapon type of the weapon or 0 if not a weapon
 */
int GetIsWeapon(object oItem);

/**
 * Gets the size of the weapon. Hard-coded some weapon types to allow large
 * races double-wield two-handed weapons (imagine Ogre with two greatswords ;) )
 *
 * @param oItem         The item to test.
 * @return              The size of the weapon, -1 if oItem is not a weapon.
 */
int GetWeaponSize(object oWeapon);

/**
 * Returns TRUE if item is a shield
 *
 * @param oItem     The item to test.
 * @return          TRUE if a shield, otherwise FALSE
 */
int GetIsShield(object oItem);

//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

#include "prc_misc_const"
#include "prc_feat_const"
#include "inc_2dacache"

//////////////////////////////////////////////////
/* Internal functions                           */
//////////////////////////////////////////////////

//////////////////////////////////////////////////
/* Function Definitions                         */
//////////////////////////////////////////////////

int GetFeatOfWeaponType(int iWeaponType, int iFeatType)
{
    switch(iFeatType)
    {
        case FEAT_TYPE_FOCUS:                   return GetFocusFeatOfWeaponType(iWeaponType);
        case FEAT_TYPE_SPECIALIZATION:          return GetSpecializationFeatOfWeaponType(iWeaponType);
        case FEAT_TYPE_EPIC_FOCUS:              return GetEpicFocusFeatOfWeaponType(iWeaponType);
        case FEAT_TYPE_EPIC_SPECIALIZATION:     return GetEpicSpecializationFeatOfWeaponType(iWeaponType);
        case FEAT_TYPE_IMPROVED_CRITICAL:       return GetImprovedCriticalFeatOfWeaponType(iWeaponType);
        case FEAT_TYPE_OVERWHELMING_CRITICAL:   return GetOverwhelmingCriticalFeatOfWeaponType(iWeaponType);
        case FEAT_TYPE_DEVASTATING_CRITICAL:    return GetDevastatingCriticalFeatOfWeaponType(iWeaponType);
        case FEAT_TYPE_WEAPON_OF_CHOICE:        return GetWeaponOfChoiceFeatOfWeaponType(iWeaponType);
		case FEAT_TYPE_WEAPON_PROFICIENCY:		return GetProficiencyFeatOfWeaponType(iWeaponType);
    }
    return -1;
}

int GetProficiencyFeatOfWeaponType(int iWeaponType)
{
	switch(iWeaponType)
	{
		case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:	return FEAT_WEAPON_PROFICIENCY_CREATURE;
        case BASE_ITEM_INVALID:         return FEAT_IMPROVED_UNARMED_STRIKE;

        case BASE_ITEM_BASTARDSWORD:    return FEAT_WEAPON_PROFICIENCY_BASTARD_SWORD;
        case BASE_ITEM_BATTLEAXE:       return FEAT_WEAPON_PROFICIENCY_BATTLEAXE;
        case BASE_ITEM_CLUB:            return FEAT_WEAPON_PROFICIENCY_CLUB;
		case BASE_ITEM_CRAFTED_SCEPTER:	return FEAT_WEAPON_PROFICIENCY_CLUB;		
        case BASE_ITEM_DAGGER:          return FEAT_WEAPON_PROFICIENCY_DAGGER;
        case BASE_ITEM_DART:            return FEAT_WEAPON_PROFICIENCY_DART;
        case BASE_ITEM_DIREMACE:        return FEAT_WEAPON_PROFICIENCY_DIRE_MACE;
        case BASE_ITEM_DOUBLEAXE:       return FEAT_WEAPON_PROFICIENCY_DOUBLE_AXE;
        case BASE_ITEM_DWARVENWARAXE:   return FEAT_WEAPON_PROFICIENCY_DWARVEN_WARAXE;
        case BASE_ITEM_GREATAXE:        return FEAT_WEAPON_PROFICIENCY_GREATAXE;
        case BASE_ITEM_GREATSWORD:      return FEAT_WEAPON_PROFICIENCY_GREATSWORD;
        case BASE_ITEM_HALBERD:         return FEAT_WEAPON_PROFICIENCY_HALBERD;
        case BASE_ITEM_HANDAXE:         return FEAT_WEAPON_PROFICIENCY_HANDAXE;
        case BASE_ITEM_HEAVYCROSSBOW:   return FEAT_WEAPON_PROFICIENCY_HEAVY_XBOW;
        case BASE_ITEM_HEAVYFLAIL:      return FEAT_WEAPON_PROFICIENCY_HEAVY_FLAIL;
        case BASE_ITEM_KAMA:            return FEAT_WEAPON_PROFICIENCY_KAMA;
        case BASE_ITEM_KATANA:          return FEAT_WEAPON_PROFICIENCY_KATANA;
        case BASE_ITEM_KUKRI:           return FEAT_WEAPON_PROFICIENCY_KUKRI;
        case BASE_ITEM_LIGHTCROSSBOW:   return FEAT_WEAPON_PROFICIENCY_LIGHT_XBOW;
        case BASE_ITEM_LIGHTFLAIL:      return FEAT_WEAPON_PROFICIENCY_LIGHT_FLAIL;
        case BASE_ITEM_LIGHTHAMMER:     return FEAT_WEAPON_PROFICIENCY_LIGHT_HAMMER;
        case BASE_ITEM_LIGHTMACE:       return FEAT_WEAPON_PROFICIENCY_LIGHT_MACE;
        case BASE_ITEM_LONGBOW:         return FEAT_WEAPON_PROFICIENCY_LONGBOW;
        case BASE_ITEM_LONGSWORD:       return FEAT_WEAPON_PROFICIENCY_LONGSWORD;
        case BASE_ITEM_MORNINGSTAR:     return FEAT_WEAPON_PROFICIENCY_MORNINGSTAR;
        case BASE_ITEM_QUARTERSTAFF:    return FEAT_WEAPON_PROFICIENCY_QUARTERSTAFF;
		case BASE_ITEM_MAGICSTAFF:	    return FEAT_WEAPON_PROFICIENCY_QUARTERSTAFF;		
        case BASE_ITEM_RAPIER:          return FEAT_WEAPON_PROFICIENCY_RAPIER;
        case BASE_ITEM_SCIMITAR:        return FEAT_WEAPON_PROFICIENCY_SCIMITAR;
        case BASE_ITEM_SCYTHE:          return FEAT_WEAPON_PROFICIENCY_SCYTHE;
        case BASE_ITEM_SHORTBOW:        return FEAT_WEAPON_PROFICIENCY_SHORTBOW;
        case BASE_ITEM_SHORTSPEAR:      return FEAT_WEAPON_PROFICIENCY_SHORTSPEAR;
        case BASE_ITEM_SHORTSWORD:      return FEAT_WEAPON_PROFICIENCY_SHORTSWORD;
        case BASE_ITEM_SHURIKEN:        return FEAT_WEAPON_PROFICIENCY_SHURIKEN;
        case BASE_ITEM_SICKLE:          return FEAT_WEAPON_PROFICIENCY_SICKLE;
        case BASE_ITEM_SLING:           return FEAT_WEAPON_PROFICIENCY_SLING;
        case BASE_ITEM_THROWINGAXE:     return FEAT_WEAPON_PROFICIENCY_THROWING_AXE;
		case BASE_ITEM_TRIDENT:			return FEAT_WEAPON_PROFICIENCY_TRIDENT;
        case BASE_ITEM_TWOBLADEDSWORD:  return FEAT_WEAPON_PROFICIENCY_TWO_BLADED_SWORD;
        case BASE_ITEM_WARHAMMER:       return FEAT_WEAPON_PROFICIENCY_WARHAMMER;
        case BASE_ITEM_WHIP:            return FEAT_WEAPON_PROFICIENCY_WHIP;

	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_WEAPON_PROFICIENCY_DOUBLE_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_WEAPON_PROFICIENCY_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_WEAPON_PROFICIENCY_ELVEN_COURTBLADE;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_WEAPON_PROFICIENCY_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_WEAPON_PROFICIENCY_ELVEN_THINBLADE;		
		case BASE_ITEM_FALCHION:			return FEAT_WEAPON_PROFICIENCY_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_WEAPON_PROFICIENCY_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_WEAPON_PROFICIENCY_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_WEAPON_PROFICIENCY_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_WEAPON_PROFICIENCY_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_WEAPON_PROFICIENCY_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_WEAPON_PROFICIENCY_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_WEAPON_PROFICIENCY_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_WEAPON_PROFICIENCY_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_WEAPON_PROFICIENCY_SAI;
		case BASE_ITEM_SAP:					return FEAT_WEAPON_PROFICIENCY_SAP;	
	}
	
    return -1;	
}
		

int GetFocusFeatOfWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_INVALID:         return FEAT_WEAPON_FOCUS_UNARMED_STRIKE;
        case BASE_ITEM_BASTARDSWORD:    return FEAT_WEAPON_FOCUS_BASTARD_SWORD;
        case BASE_ITEM_BATTLEAXE:       return FEAT_WEAPON_FOCUS_BATTLE_AXE;
        case BASE_ITEM_CLUB:            return FEAT_WEAPON_FOCUS_CLUB;
		case BASE_ITEM_CRAFTED_SCEPTER:    return FEAT_WEAPON_FOCUS_CLUB;		
        case BASE_ITEM_DAGGER:          return FEAT_WEAPON_FOCUS_DAGGER;
        case BASE_ITEM_DART:            return FEAT_WEAPON_FOCUS_DART;
        case BASE_ITEM_DIREMACE:        return FEAT_WEAPON_FOCUS_DIRE_MACE;
        case BASE_ITEM_DOUBLEAXE:       return FEAT_WEAPON_FOCUS_DOUBLE_AXE;
        case BASE_ITEM_DWARVENWARAXE:   return FEAT_WEAPON_FOCUS_DWAXE;
        case BASE_ITEM_GREATAXE:        return FEAT_WEAPON_FOCUS_GREAT_AXE;
        case BASE_ITEM_GREATSWORD:      return FEAT_WEAPON_FOCUS_GREAT_SWORD;
        case BASE_ITEM_HALBERD:         return FEAT_WEAPON_FOCUS_HALBERD;
        case BASE_ITEM_HANDAXE:         return FEAT_WEAPON_FOCUS_HAND_AXE;
        case BASE_ITEM_HEAVYCROSSBOW:   return FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW;
        case BASE_ITEM_HEAVYFLAIL:      return FEAT_WEAPON_FOCUS_HEAVY_FLAIL;
        case BASE_ITEM_KAMA:            return FEAT_WEAPON_FOCUS_KAMA;
        case BASE_ITEM_KATANA:          return FEAT_WEAPON_FOCUS_KATANA;
        case BASE_ITEM_KUKRI:           return FEAT_WEAPON_FOCUS_KUKRI;
        case BASE_ITEM_LIGHTCROSSBOW:   return FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW;
        case BASE_ITEM_LIGHTFLAIL:      return FEAT_WEAPON_FOCUS_LIGHT_FLAIL;
        case BASE_ITEM_LIGHTHAMMER:     return FEAT_WEAPON_FOCUS_LIGHT_HAMMER;
        case BASE_ITEM_LIGHTMACE:       return FEAT_WEAPON_FOCUS_LIGHT_MACE;
        case BASE_ITEM_LONGBOW:         return FEAT_WEAPON_FOCUS_LONGBOW;
        case BASE_ITEM_LONGSWORD:       return FEAT_WEAPON_FOCUS_LONG_SWORD;
        case BASE_ITEM_MORNINGSTAR:     return FEAT_WEAPON_FOCUS_MORNING_STAR;
        case BASE_ITEM_QUARTERSTAFF:    return FEAT_WEAPON_FOCUS_STAFF;
		case BASE_ITEM_MAGICSTAFF:	    return FEAT_WEAPON_FOCUS_STAFF;		
        case BASE_ITEM_RAPIER:          return FEAT_WEAPON_FOCUS_RAPIER;
        case BASE_ITEM_SCIMITAR:        return FEAT_WEAPON_FOCUS_SCIMITAR;
        case BASE_ITEM_SCYTHE:          return FEAT_WEAPON_FOCUS_SCYTHE;
        case BASE_ITEM_SHORTBOW:        return FEAT_WEAPON_FOCUS_SHORTBOW;
        case BASE_ITEM_SHORTSPEAR:      return FEAT_WEAPON_FOCUS_SPEAR;
        case BASE_ITEM_SHORTSWORD:      return FEAT_WEAPON_FOCUS_SHORT_SWORD;
        case BASE_ITEM_SHURIKEN:        return FEAT_WEAPON_FOCUS_SHURIKEN;
        case BASE_ITEM_SICKLE:          return FEAT_WEAPON_FOCUS_SICKLE;
        case BASE_ITEM_SLING:           return FEAT_WEAPON_FOCUS_SLING;
        case BASE_ITEM_THROWINGAXE:     return FEAT_WEAPON_FOCUS_THROWING_AXE;
		case BASE_ITEM_TRIDENT:			return FEAT_WEAPON_FOCUS_TRIDENT;
        case BASE_ITEM_TWOBLADEDSWORD:  return FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD;
        case BASE_ITEM_WARHAMMER:       return FEAT_WEAPON_FOCUS_WAR_HAMMER;
        case BASE_ITEM_WHIP:            return FEAT_WEAPON_FOCUS_WHIP;

	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_WEAPON_FOCUS_DOUBLE_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_WEAPON_FOCUS_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_WEAPON_FOCUS_ELVEN_COURTBLADE;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_WEAPON_FOCUS_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_WEAPON_FOCUS_ELVEN_THINBLADE;		
		case BASE_ITEM_FALCHION:			return FEAT_WEAPON_FOCUS_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_WEAPON_FOCUS_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_WEAPON_FOCUS_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_WEAPON_FOCUS_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_WEAPON_FOCUS_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_WEAPON_FOCUS_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_WEAPON_FOCUS_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_WEAPON_FOCUS_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_WEAPON_FOCUS_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_WEAPON_FOCUS_SAI;
		case BASE_ITEM_SAP:					return FEAT_WEAPON_FOCUS_SAP;
    }
    return -1;
}

int GetSpecializationFeatOfWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_INVALID:        return FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE;
        case BASE_ITEM_BASTARDSWORD:   return FEAT_WEAPON_SPECIALIZATION_BASTARD_SWORD;
        case BASE_ITEM_BATTLEAXE:      return FEAT_WEAPON_SPECIALIZATION_BATTLE_AXE;
        case BASE_ITEM_CLUB:           return FEAT_WEAPON_SPECIALIZATION_CLUB;
        case BASE_ITEM_CRAFTED_SCEPTER:   return FEAT_WEAPON_SPECIALIZATION_CLUB;		
        case BASE_ITEM_DAGGER:         return FEAT_WEAPON_SPECIALIZATION_DAGGER;
        case BASE_ITEM_DART:           return FEAT_WEAPON_SPECIALIZATION_DART;
        case BASE_ITEM_DIREMACE:       return FEAT_WEAPON_SPECIALIZATION_DIRE_MACE;
        case BASE_ITEM_DOUBLEAXE:      return FEAT_WEAPON_SPECIALIZATION_DOUBLE_AXE;
        case BASE_ITEM_DWARVENWARAXE:  return FEAT_WEAPON_SPECIALIZATION_DWAXE ;
        case BASE_ITEM_GREATAXE:       return FEAT_WEAPON_SPECIALIZATION_GREAT_AXE;
        case BASE_ITEM_GREATSWORD:     return FEAT_WEAPON_SPECIALIZATION_GREAT_SWORD;
        case BASE_ITEM_HALBERD:        return FEAT_WEAPON_SPECIALIZATION_HALBERD;
        case BASE_ITEM_HANDAXE:        return FEAT_WEAPON_SPECIALIZATION_HAND_AXE;
        case BASE_ITEM_HEAVYCROSSBOW:  return FEAT_WEAPON_SPECIALIZATION_HEAVY_CROSSBOW;
        case BASE_ITEM_HEAVYFLAIL:     return FEAT_WEAPON_SPECIALIZATION_HEAVY_FLAIL;
        case BASE_ITEM_KAMA:           return FEAT_WEAPON_SPECIALIZATION_KAMA;
        case BASE_ITEM_KATANA:         return FEAT_WEAPON_SPECIALIZATION_KATANA;
        case BASE_ITEM_KUKRI:          return FEAT_WEAPON_SPECIALIZATION_KUKRI;
        case BASE_ITEM_LIGHTCROSSBOW:  return FEAT_WEAPON_SPECIALIZATION_LIGHT_CROSSBOW;
        case BASE_ITEM_LIGHTFLAIL:     return FEAT_WEAPON_SPECIALIZATION_LIGHT_FLAIL;
        case BASE_ITEM_LIGHTHAMMER:    return FEAT_WEAPON_SPECIALIZATION_LIGHT_HAMMER;
        case BASE_ITEM_LIGHTMACE:      return FEAT_WEAPON_SPECIALIZATION_LIGHT_MACE;
        case BASE_ITEM_LONGBOW:        return FEAT_WEAPON_SPECIALIZATION_LONGBOW;
        case BASE_ITEM_LONGSWORD:      return FEAT_WEAPON_SPECIALIZATION_LONG_SWORD;
        case BASE_ITEM_MORNINGSTAR:    return FEAT_WEAPON_SPECIALIZATION_MORNING_STAR;
        case BASE_ITEM_QUARTERSTAFF:   return FEAT_WEAPON_SPECIALIZATION_STAFF;
        case BASE_ITEM_MAGICSTAFF:	   return FEAT_WEAPON_SPECIALIZATION_STAFF;		
        case BASE_ITEM_RAPIER:         return FEAT_WEAPON_SPECIALIZATION_RAPIER;
        case BASE_ITEM_SCIMITAR:       return FEAT_WEAPON_SPECIALIZATION_SCIMITAR;
        case BASE_ITEM_SCYTHE:         return FEAT_WEAPON_SPECIALIZATION_SCYTHE;
        case BASE_ITEM_SHORTBOW:       return FEAT_WEAPON_SPECIALIZATION_SHORTBOW;
        case BASE_ITEM_SHORTSPEAR:     return FEAT_WEAPON_SPECIALIZATION_SPEAR;
        case BASE_ITEM_SHORTSWORD:     return FEAT_WEAPON_SPECIALIZATION_SHORT_SWORD;
        case BASE_ITEM_SHURIKEN:       return FEAT_WEAPON_SPECIALIZATION_SHURIKEN;
        case BASE_ITEM_SICKLE:         return FEAT_WEAPON_SPECIALIZATION_SICKLE;
        case BASE_ITEM_SLING:          return FEAT_WEAPON_SPECIALIZATION_SLING;
        case BASE_ITEM_THROWINGAXE:    return FEAT_WEAPON_SPECIALIZATION_THROWING_AXE;
        case BASE_ITEM_TRIDENT:			return FEAT_WEAPON_SPECIALIZATION_TRIDENT;		
        case BASE_ITEM_TWOBLADEDSWORD: return FEAT_WEAPON_SPECIALIZATION_TWO_BLADED_SWORD;
        case BASE_ITEM_WARHAMMER:      return FEAT_WEAPON_SPECIALIZATION_WAR_HAMMER;
        case BASE_ITEM_WHIP:           return FEAT_WEAPON_SPECIALIZATION_WHIP;

	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_WEAPON_SPECIALIZATION_DBL_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_WEAPON_SPECIALIZATION_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_WEAPON_SPECIALIZATION_ELVEN_THINBLADE;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE;
		case BASE_ITEM_FALCHION:			return FEAT_WEAPON_SPECIALIZATION_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_WEAPON_SPECIALIZATION_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_WEAPON_SPECIALIZATION_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_WEAPON_SPECIALIZATION_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_WEAPON_SPECIALIZATION_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_WEAPON_SPECIALIZATION_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_WEAPON_SPECIALIZATION_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_WEAPON_SPECIALIZATION_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_WEAPON_SPECIALIZATION_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_WEAPON_SPECIALIZATION_SAI;
		case BASE_ITEM_SAP:					return FEAT_WEAPON_SPECIALIZATION_SAP;		
    }
    return -1;
}

int GetEpicFocusFeatOfWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_INVALID:        return FEAT_EPIC_WEAPON_FOCUS_UNARMED;
        case BASE_ITEM_BASTARDSWORD:   return FEAT_EPIC_WEAPON_FOCUS_BASTARDSWORD;
        case BASE_ITEM_BATTLEAXE:      return FEAT_EPIC_WEAPON_FOCUS_BATTLEAXE;
        case BASE_ITEM_CLUB:           return FEAT_EPIC_WEAPON_FOCUS_CLUB;
		case BASE_ITEM_CRAFTED_SCEPTER:   return FEAT_EPIC_WEAPON_FOCUS_CLUB;		
        case BASE_ITEM_DAGGER:         return FEAT_EPIC_WEAPON_FOCUS_DAGGER;
        case BASE_ITEM_DART:           return FEAT_EPIC_WEAPON_FOCUS_DART;
        case BASE_ITEM_DIREMACE:       return FEAT_EPIC_WEAPON_FOCUS_DIREMACE;
        case BASE_ITEM_DOUBLEAXE:      return FEAT_EPIC_WEAPON_FOCUS_DOUBLEAXE;
        case BASE_ITEM_DWARVENWARAXE:  return FEAT_EPIC_WEAPON_FOCUS_DWAXE;
        case BASE_ITEM_GREATAXE:       return FEAT_EPIC_WEAPON_FOCUS_GREATAXE;
        case BASE_ITEM_GREATSWORD:     return FEAT_EPIC_WEAPON_FOCUS_GREATSWORD;
        case BASE_ITEM_HALBERD:        return FEAT_EPIC_WEAPON_FOCUS_HALBERD;
        case BASE_ITEM_HANDAXE:        return FEAT_EPIC_WEAPON_FOCUS_HANDAXE;
        case BASE_ITEM_HEAVYCROSSBOW:  return FEAT_EPIC_WEAPON_FOCUS_HEAVYCROSSBOW;
        case BASE_ITEM_HEAVYFLAIL:     return FEAT_EPIC_WEAPON_FOCUS_HEAVYFLAIL;
        case BASE_ITEM_KAMA:           return FEAT_EPIC_WEAPON_FOCUS_KAMA;
        case BASE_ITEM_KATANA:         return FEAT_EPIC_WEAPON_FOCUS_KATANA;
        case BASE_ITEM_KUKRI:          return FEAT_EPIC_WEAPON_FOCUS_KUKRI;
        case BASE_ITEM_LIGHTCROSSBOW:  return FEAT_EPIC_WEAPON_FOCUS_LIGHTCROSSBOW;
        case BASE_ITEM_LIGHTFLAIL:     return FEAT_EPIC_WEAPON_FOCUS_LIGHTFLAIL;
        case BASE_ITEM_LIGHTHAMMER:    return FEAT_EPIC_WEAPON_FOCUS_LIGHTHAMMER;
        case BASE_ITEM_LIGHTMACE:      return FEAT_EPIC_WEAPON_FOCUS_LIGHTMACE;
        case BASE_ITEM_LONGBOW:        return FEAT_EPIC_WEAPON_FOCUS_LONGBOW;
        case BASE_ITEM_LONGSWORD:      return FEAT_EPIC_WEAPON_FOCUS_LONGSWORD;
        case BASE_ITEM_MORNINGSTAR:    return FEAT_EPIC_WEAPON_FOCUS_MORNINGSTAR;
        case BASE_ITEM_QUARTERSTAFF:   return FEAT_EPIC_WEAPON_FOCUS_QUARTERSTAFF;
        case BASE_ITEM_MAGICSTAFF:	   return FEAT_EPIC_WEAPON_FOCUS_QUARTERSTAFF;		
        case BASE_ITEM_RAPIER:         return FEAT_EPIC_WEAPON_FOCUS_RAPIER;
        case BASE_ITEM_SCIMITAR:       return FEAT_EPIC_WEAPON_FOCUS_SCIMITAR;
        case BASE_ITEM_SCYTHE:         return FEAT_EPIC_WEAPON_FOCUS_SCYTHE;
        case BASE_ITEM_SHORTBOW:       return FEAT_EPIC_WEAPON_FOCUS_SHORTBOW;
        case BASE_ITEM_SHORTSPEAR:     return FEAT_EPIC_WEAPON_FOCUS_SHORTSPEAR;
        case BASE_ITEM_SHORTSWORD:     return FEAT_EPIC_WEAPON_FOCUS_SHORTSWORD;
        case BASE_ITEM_SHURIKEN:       return FEAT_EPIC_WEAPON_FOCUS_SHURIKEN;
        case BASE_ITEM_SICKLE:         return FEAT_EPIC_WEAPON_FOCUS_SICKLE;
        case BASE_ITEM_SLING:          return FEAT_EPIC_WEAPON_FOCUS_SLING;
        case BASE_ITEM_THROWINGAXE:    return FEAT_EPIC_WEAPON_FOCUS_THROWINGAXE;
        case BASE_ITEM_TRIDENT:			return FEAT_EPIC_WEAPON_FOCUS_TRIDENT;		
        case BASE_ITEM_TWOBLADEDSWORD: return FEAT_EPIC_WEAPON_FOCUS_TWOBLADEDSWORD;
        case BASE_ITEM_WARHAMMER:      return FEAT_EPIC_WEAPON_FOCUS_WARHAMMER;
        case BASE_ITEM_WHIP:           return FEAT_EPIC_WEAPON_FOCUS_WHIP;

	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_EPIC_WEAPON_FOCUS_DBL_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_EPIC_WEAPON_FOCUS_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_EPIC_WEAPON_FOCUS_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_EPIC_WEAPON_FOCUS_ELVEN_THINBLADE;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_EPIC_WEAPON_FOCUS_ELVEN_COURTBLADE;
		case BASE_ITEM_FALCHION:			return FEAT_EPIC_WEAPON_FOCUS_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_EPIC_WEAPON_FOCUS_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_EPIC_WEAPON_FOCUS_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_EPIC_WEAPON_FOCUS_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_EPIC_WEAPON_FOCUS_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_EPIC_WEAPON_FOCUS_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_EPIC_WEAPON_FOCUS_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_EPIC_WEAPON_FOCUS_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_EPIC_WEAPON_FOCUS_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_EPIC_WEAPON_FOCUS_SAI;
		case BASE_ITEM_SAP:					return FEAT_EPIC_WEAPON_FOCUS_SAP;	
    }
    return -1;
}

int GetEpicSpecializationFeatOfWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_INVALID:        return FEAT_EPIC_WEAPON_SPECIALIZATION_UNARMED;
        case BASE_ITEM_BASTARDSWORD:   return FEAT_EPIC_WEAPON_SPECIALIZATION_BASTARDSWORD;
        case BASE_ITEM_BATTLEAXE:      return FEAT_EPIC_WEAPON_SPECIALIZATION_BATTLEAXE;
        case BASE_ITEM_CLUB:           return FEAT_EPIC_WEAPON_SPECIALIZATION_CLUB;
		case BASE_ITEM_CRAFTED_SCEPTER:   return FEAT_EPIC_WEAPON_SPECIALIZATION_CLUB;		
        case BASE_ITEM_DAGGER:         return FEAT_EPIC_WEAPON_SPECIALIZATION_DAGGER;
        case BASE_ITEM_DART:           return FEAT_EPIC_WEAPON_SPECIALIZATION_DART;
        case BASE_ITEM_DIREMACE:       return FEAT_EPIC_WEAPON_SPECIALIZATION_DIREMACE;
        case BASE_ITEM_DOUBLEAXE:      return FEAT_EPIC_WEAPON_SPECIALIZATION_DOUBLEAXE;
        case BASE_ITEM_DWARVENWARAXE:  return FEAT_EPIC_WEAPON_SPECIALIZATION_DWAXE;
        case BASE_ITEM_GREATAXE:       return FEAT_EPIC_WEAPON_SPECIALIZATION_GREATAXE;
        case BASE_ITEM_GREATSWORD:     return FEAT_EPIC_WEAPON_SPECIALIZATION_GREATSWORD;
        case BASE_ITEM_HALBERD:        return FEAT_EPIC_WEAPON_SPECIALIZATION_HALBERD;
        case BASE_ITEM_HANDAXE:        return FEAT_EPIC_WEAPON_SPECIALIZATION_HANDAXE;
        case BASE_ITEM_HEAVYCROSSBOW:  return FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVYCROSSBOW;
        case BASE_ITEM_HEAVYFLAIL:     return FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVYFLAIL;
        case BASE_ITEM_KAMA:           return FEAT_EPIC_WEAPON_SPECIALIZATION_KAMA;
        case BASE_ITEM_KATANA:         return FEAT_EPIC_WEAPON_SPECIALIZATION_KATANA;
        case BASE_ITEM_KUKRI:          return FEAT_EPIC_WEAPON_SPECIALIZATION_KUKRI;
        case BASE_ITEM_LIGHTCROSSBOW:  return FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTCROSSBOW;
        case BASE_ITEM_LIGHTFLAIL:     return FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTFLAIL;
        case BASE_ITEM_LIGHTHAMMER:    return FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTHAMMER;
        case BASE_ITEM_LIGHTMACE:      return FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTMACE;
        case BASE_ITEM_LONGBOW:        return FEAT_EPIC_WEAPON_SPECIALIZATION_LONGBOW; // motu99: Longbow and Longsword were interchanged. Corrected that
        case BASE_ITEM_LONGSWORD:      return FEAT_EPIC_WEAPON_SPECIALIZATION_LONGSWORD;
        case BASE_ITEM_MORNINGSTAR:    return FEAT_EPIC_WEAPON_SPECIALIZATION_MORNINGSTAR;
        case BASE_ITEM_QUARTERSTAFF:   return FEAT_EPIC_WEAPON_SPECIALIZATION_QUARTERSTAFF;
        case BASE_ITEM_MAGICSTAFF:		return FEAT_EPIC_WEAPON_SPECIALIZATION_QUARTERSTAFF;
		case BASE_ITEM_RAPIER:         return FEAT_EPIC_WEAPON_SPECIALIZATION_RAPIER;
        case BASE_ITEM_SCIMITAR:       return FEAT_EPIC_WEAPON_SPECIALIZATION_SCIMITAR;
        case BASE_ITEM_SCYTHE:         return FEAT_EPIC_WEAPON_SPECIALIZATION_SCYTHE;
        case BASE_ITEM_SHORTBOW:       return FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTBOW;
        case BASE_ITEM_SHORTSPEAR:     return FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTSPEAR;
        case BASE_ITEM_SHORTSWORD:     return FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTSWORD;
        case BASE_ITEM_SHURIKEN:       return FEAT_EPIC_WEAPON_SPECIALIZATION_SHURIKEN;
        case BASE_ITEM_SICKLE:         return FEAT_EPIC_WEAPON_SPECIALIZATION_SICKLE;
        case BASE_ITEM_SLING:          return FEAT_EPIC_WEAPON_SPECIALIZATION_SLING;
        case BASE_ITEM_THROWINGAXE:    return FEAT_EPIC_WEAPON_SPECIALIZATION_THROWINGAXE;
        case BASE_ITEM_TRIDENT:			return FEAT_EPIC_WEAPON_SPECIALIZATION_TRIDENT;		
        case BASE_ITEM_TWOBLADEDSWORD: return FEAT_EPIC_WEAPON_SPECIALIZATION_TWOBLADEDSWORD;
        case BASE_ITEM_WARHAMMER:      return FEAT_EPIC_WEAPON_SPECIALIZATION_WARHAMMER;
        case BASE_ITEM_WHIP:           return FEAT_EPIC_WEAPON_SPECIALIZATION_WHIP;

	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_EPIC_WEAPON_SPECIALIZATION_DBL_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_EPIC_WEAPON_SPECIALIZATION_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_THINBLADE;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE;
		case BASE_ITEM_FALCHION:			return FEAT_EPIC_WEAPON_SPECIALIZATION_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_EPIC_WEAPON_SPECIALIZATION_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_EPIC_WEAPON_SPECIALIZATION_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_EPIC_WEAPON_SPECIALIZATION_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_EPIC_WEAPON_SPECIALIZATION_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_EPIC_WEAPON_SPECIALIZATION_SAI;
		case BASE_ITEM_SAP:					return FEAT_EPIC_WEAPON_SPECIALIZATION_SAP;	
    }
    return -1;
}

int GetImprovedCriticalFeatOfWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_INVALID:        return FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE;
        case BASE_ITEM_BASTARDSWORD:   return FEAT_IMPROVED_CRITICAL_BASTARD_SWORD;
        case BASE_ITEM_BATTLEAXE:      return FEAT_IMPROVED_CRITICAL_BATTLE_AXE;
        case BASE_ITEM_CLUB:           return FEAT_IMPROVED_CRITICAL_CLUB;
		case BASE_ITEM_CRAFTED_SCEPTER:   return FEAT_IMPROVED_CRITICAL_CLUB;
        case BASE_ITEM_DAGGER:         return FEAT_IMPROVED_CRITICAL_DAGGER;
        case BASE_ITEM_DART:           return FEAT_IMPROVED_CRITICAL_DART;
        case BASE_ITEM_DIREMACE:       return FEAT_IMPROVED_CRITICAL_DIRE_MACE;
        case BASE_ITEM_DOUBLEAXE:      return FEAT_IMPROVED_CRITICAL_DOUBLE_AXE;
        case BASE_ITEM_DWARVENWARAXE:  return FEAT_IMPROVED_CRITICAL_DWAXE ;
        case BASE_ITEM_GREATAXE:       return FEAT_IMPROVED_CRITICAL_GREAT_AXE;
        case BASE_ITEM_GREATSWORD:     return FEAT_IMPROVED_CRITICAL_GREAT_SWORD;
        case BASE_ITEM_HALBERD:        return FEAT_IMPROVED_CRITICAL_HALBERD;
        case BASE_ITEM_HANDAXE:        return FEAT_IMPROVED_CRITICAL_HAND_AXE;
        case BASE_ITEM_HEAVYCROSSBOW:  return FEAT_IMPROVED_CRITICAL_HEAVY_CROSSBOW;
        case BASE_ITEM_HEAVYFLAIL:     return FEAT_IMPROVED_CRITICAL_HEAVY_FLAIL;
        case BASE_ITEM_KAMA:           return FEAT_IMPROVED_CRITICAL_KAMA;
        case BASE_ITEM_KATANA:         return FEAT_IMPROVED_CRITICAL_KATANA;
        case BASE_ITEM_KUKRI:          return FEAT_IMPROVED_CRITICAL_KUKRI;
        case BASE_ITEM_LIGHTCROSSBOW:  return FEAT_IMPROVED_CRITICAL_LIGHT_CROSSBOW;
        case BASE_ITEM_LIGHTFLAIL:     return FEAT_IMPROVED_CRITICAL_LIGHT_FLAIL;
        case BASE_ITEM_LIGHTHAMMER:    return FEAT_IMPROVED_CRITICAL_LIGHT_HAMMER;
        case BASE_ITEM_LIGHTMACE:      return FEAT_IMPROVED_CRITICAL_LIGHT_MACE;
        case BASE_ITEM_LONGBOW:        return FEAT_IMPROVED_CRITICAL_LONGBOW;
        case BASE_ITEM_LONGSWORD:      return FEAT_IMPROVED_CRITICAL_LONG_SWORD;
        case BASE_ITEM_MORNINGSTAR:    return FEAT_IMPROVED_CRITICAL_MORNING_STAR;
        case BASE_ITEM_QUARTERSTAFF:   return FEAT_IMPROVED_CRITICAL_STAFF;
        case BASE_ITEM_MAGICSTAFF:	   return FEAT_IMPROVED_CRITICAL_STAFF;		
        case BASE_ITEM_RAPIER:         return FEAT_IMPROVED_CRITICAL_RAPIER;
        case BASE_ITEM_SCIMITAR:       return FEAT_IMPROVED_CRITICAL_SCIMITAR;
        case BASE_ITEM_SCYTHE:         return FEAT_IMPROVED_CRITICAL_SCYTHE;
        case BASE_ITEM_SHORTBOW:       return FEAT_IMPROVED_CRITICAL_SHORTBOW;
        case BASE_ITEM_SHORTSPEAR:     return FEAT_IMPROVED_CRITICAL_SPEAR;
        case BASE_ITEM_SHORTSWORD:     return FEAT_IMPROVED_CRITICAL_SHORT_SWORD;
        case BASE_ITEM_SHURIKEN:       return FEAT_IMPROVED_CRITICAL_SHURIKEN;
        case BASE_ITEM_SICKLE:         return FEAT_IMPROVED_CRITICAL_SICKLE;
        case BASE_ITEM_SLING:          return FEAT_IMPROVED_CRITICAL_SLING;
        case BASE_ITEM_THROWINGAXE:    return FEAT_IMPROVED_CRITICAL_THROWING_AXE;
        case BASE_ITEM_TRIDENT:			return FEAT_IMPROVED_CRITICAL_TRIDENT;		
        case BASE_ITEM_TWOBLADEDSWORD: return FEAT_IMPROVED_CRITICAL_TWO_BLADED_SWORD;
        case BASE_ITEM_WARHAMMER:      return FEAT_IMPROVED_CRITICAL_WAR_HAMMER;
        case BASE_ITEM_WHIP:           return FEAT_IMPROVED_CRITICAL_WHIP;

	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_IMPROVED_CRITICAL_DBL_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_IMPROVED_CRITICAL_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_IMPROVED_CRITICAL_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_IMPROVED_CRITICAL_ELVEN_THINBLADE;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_IMPROVED_CRITICAL_ELVEN_COURTBLADE;
		case BASE_ITEM_FALCHION:			return FEAT_IMPROVED_CRITICAL_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_IMPROVED_CRITICAL_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_IMPROVED_CRITICAL_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_IMPROVED_CRITICAL_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_IMPROVED_CRITICAL_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_IMPROVED_CRITICAL_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_IMPROVED_CRITICAL_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_IMPROVED_CRITICAL_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_IMPROVED_CRITICAL_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_IMPROVED_CRITICAL_SAI;
		case BASE_ITEM_SAP:					return FEAT_IMPROVED_CRITICAL_SAP;	
    }
    return -1;
}

int GetOverwhelmingCriticalFeatOfWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_INVALID:        return FEAT_EPIC_OVERWHELMING_CRITICAL_UNARMED;
        case BASE_ITEM_BASTARDSWORD:   return FEAT_EPIC_OVERWHELMING_CRITICAL_BASTARDSWORD;
        case BASE_ITEM_BATTLEAXE:      return FEAT_EPIC_OVERWHELMING_CRITICAL_BATTLEAXE;
        case BASE_ITEM_CLUB:           return FEAT_EPIC_OVERWHELMING_CRITICAL_CLUB;
		case BASE_ITEM_CRAFTED_SCEPTER:   return FEAT_EPIC_OVERWHELMING_CRITICAL_CLUB;		
        case BASE_ITEM_DAGGER:         return FEAT_EPIC_OVERWHELMING_CRITICAL_DAGGER;
        case BASE_ITEM_DART:           return FEAT_EPIC_OVERWHELMING_CRITICAL_DART;
        case BASE_ITEM_DIREMACE:       return FEAT_EPIC_OVERWHELMING_CRITICAL_DIREMACE;
        case BASE_ITEM_DOUBLEAXE:      return FEAT_EPIC_OVERWHELMING_CRITICAL_DOUBLEAXE;
        case BASE_ITEM_DWARVENWARAXE:  return FEAT_EPIC_OVERWHELMING_CRITICAL_DWAXE ;
        case BASE_ITEM_GREATAXE:       return FEAT_EPIC_OVERWHELMING_CRITICAL_GREATAXE;
        case BASE_ITEM_GREATSWORD:     return FEAT_EPIC_OVERWHELMING_CRITICAL_GREATSWORD;
        case BASE_ITEM_HALBERD:        return FEAT_EPIC_OVERWHELMING_CRITICAL_HALBERD;
        case BASE_ITEM_HANDAXE:        return FEAT_EPIC_OVERWHELMING_CRITICAL_HANDAXE;
        case BASE_ITEM_HEAVYCROSSBOW:  return FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVYCROSSBOW;
        case BASE_ITEM_HEAVYFLAIL:     return FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVYFLAIL;
        case BASE_ITEM_KAMA:           return FEAT_EPIC_OVERWHELMING_CRITICAL_KAMA;
        case BASE_ITEM_KATANA:         return FEAT_EPIC_OVERWHELMING_CRITICAL_KATANA;
        case BASE_ITEM_KUKRI:          return FEAT_EPIC_OVERWHELMING_CRITICAL_KUKRI;
        case BASE_ITEM_LIGHTCROSSBOW:  return FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTCROSSBOW;
        case BASE_ITEM_LIGHTFLAIL:     return FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTFLAIL;
        case BASE_ITEM_LIGHTHAMMER:    return FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTHAMMER;
        case BASE_ITEM_LIGHTMACE:      return FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTMACE;
        case BASE_ITEM_LONGBOW:        return FEAT_EPIC_OVERWHELMING_CRITICAL_LONGBOW;
        case BASE_ITEM_LONGSWORD:      return FEAT_EPIC_OVERWHELMING_CRITICAL_LONGSWORD;
        case BASE_ITEM_MORNINGSTAR:    return FEAT_EPIC_OVERWHELMING_CRITICAL_MORNINGSTAR;
        case BASE_ITEM_QUARTERSTAFF:   return FEAT_EPIC_OVERWHELMING_CRITICAL_QUARTERSTAFF;
        case BASE_ITEM_MAGICSTAFF:		return FEAT_EPIC_OVERWHELMING_CRITICAL_QUARTERSTAFF;		
        case BASE_ITEM_RAPIER:         return FEAT_EPIC_OVERWHELMING_CRITICAL_RAPIER;
        case BASE_ITEM_SCIMITAR:       return FEAT_EPIC_OVERWHELMING_CRITICAL_SCIMITAR;
        case BASE_ITEM_SCYTHE:         return FEAT_EPIC_OVERWHELMING_CRITICAL_SCYTHE;
        case BASE_ITEM_SHORTBOW:       return FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTBOW;
        case BASE_ITEM_SHORTSPEAR:     return FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTSPEAR;
        case BASE_ITEM_SHORTSWORD:     return FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTSWORD;
        case BASE_ITEM_SHURIKEN:       return FEAT_EPIC_OVERWHELMING_CRITICAL_SHURIKEN;
        case BASE_ITEM_SICKLE:         return FEAT_EPIC_OVERWHELMING_CRITICAL_SICKLE;
        case BASE_ITEM_SLING:          return FEAT_EPIC_OVERWHELMING_CRITICAL_SLING;
        case BASE_ITEM_THROWINGAXE:    return FEAT_EPIC_OVERWHELMING_CRITICAL_THROWINGAXE;
        case BASE_ITEM_TRIDENT:			return FEAT_EPIC_OVERWHELMING_CRITICAL_TRIDENT;		
        case BASE_ITEM_TWOBLADEDSWORD: return FEAT_EPIC_OVERWHELMING_CRITICAL_TWOBLADEDSWORD;
        case BASE_ITEM_WARHAMMER:      return FEAT_EPIC_OVERWHELMING_CRITICAL_WARHAMMER;
        case BASE_ITEM_WHIP:           return FEAT_EPIC_OVERWHELMING_CRITICAL_WHIP;
		
	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_EPIC_OVERWHELMING_CRITICAL_DBL_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_EPIC_OVERWHELMING_CRITICAL_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_THINBLADE;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_COURTBLADE;
		case BASE_ITEM_FALCHION:			return FEAT_EPIC_OVERWHELMING_CRITICAL_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_EPIC_OVERWHELMING_CRITICAL_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_EPIC_OVERWHELMING_CRITICAL_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_EPIC_OVERWHELMING_CRITICAL_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_EPIC_OVERWHELMING_CRITICAL_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_EPIC_OVERWHELMING_CRITICAL_SAI;
		case BASE_ITEM_SAP:					return FEAT_EPIC_OVERWHELMING_CRITICAL_SAP;		
    }
    return -1;
}

int GetDevastatingCriticalFeatOfWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_INVALID:        return FEAT_EPIC_DEVASTATING_CRITICAL_UNARMED;
        case BASE_ITEM_BASTARDSWORD:   return FEAT_EPIC_DEVASTATING_CRITICAL_BASTARDSWORD;
        case BASE_ITEM_BATTLEAXE:      return FEAT_EPIC_DEVASTATING_CRITICAL_BATTLEAXE;
        case BASE_ITEM_CLUB:           return FEAT_EPIC_DEVASTATING_CRITICAL_CLUB;
		case BASE_ITEM_CRAFTED_SCEPTER:   return FEAT_EPIC_DEVASTATING_CRITICAL_CLUB;
        case BASE_ITEM_DAGGER:         return FEAT_EPIC_DEVASTATING_CRITICAL_DAGGER;
        case BASE_ITEM_DART:           return FEAT_EPIC_DEVASTATING_CRITICAL_DART;
        case BASE_ITEM_DIREMACE:       return FEAT_EPIC_DEVASTATING_CRITICAL_DIREMACE;
        case BASE_ITEM_DOUBLEAXE:      return FEAT_EPIC_DEVASTATING_CRITICAL_DOUBLEAXE;
        case BASE_ITEM_DWARVENWARAXE:  return FEAT_EPIC_DEVASTATING_CRITICAL_DWAXE ;
        case BASE_ITEM_GREATAXE:       return FEAT_EPIC_DEVASTATING_CRITICAL_GREATAXE;
        case BASE_ITEM_GREATSWORD:     return FEAT_EPIC_DEVASTATING_CRITICAL_GREATSWORD;
        case BASE_ITEM_HALBERD:        return FEAT_EPIC_DEVASTATING_CRITICAL_HALBERD;
        case BASE_ITEM_HANDAXE:        return FEAT_EPIC_DEVASTATING_CRITICAL_HANDAXE;
        case BASE_ITEM_HEAVYCROSSBOW:  return FEAT_EPIC_DEVASTATING_CRITICAL_HEAVYCROSSBOW;
        case BASE_ITEM_HEAVYFLAIL:     return FEAT_EPIC_DEVASTATING_CRITICAL_HEAVYFLAIL;
        case BASE_ITEM_KAMA:           return FEAT_EPIC_DEVASTATING_CRITICAL_KAMA;
        case BASE_ITEM_KATANA:         return FEAT_EPIC_DEVASTATING_CRITICAL_KATANA;
        case BASE_ITEM_KUKRI:          return FEAT_EPIC_DEVASTATING_CRITICAL_KUKRI;
        case BASE_ITEM_LIGHTCROSSBOW:  return FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTCROSSBOW;
        case BASE_ITEM_LIGHTFLAIL:     return FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTFLAIL;
        case BASE_ITEM_LIGHTHAMMER:    return FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTHAMMER;
        case BASE_ITEM_LIGHTMACE:      return FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTMACE;
        case BASE_ITEM_LONGBOW:        return FEAT_EPIC_DEVASTATING_CRITICAL_LONGBOW;
        case BASE_ITEM_LONGSWORD:      return FEAT_EPIC_DEVASTATING_CRITICAL_LONGSWORD;
        case BASE_ITEM_MORNINGSTAR:    return FEAT_EPIC_DEVASTATING_CRITICAL_MORNINGSTAR;
        case BASE_ITEM_QUARTERSTAFF:   return FEAT_EPIC_DEVASTATING_CRITICAL_QUARTERSTAFF;
        case BASE_ITEM_MAGICSTAFF:	   return FEAT_EPIC_DEVASTATING_CRITICAL_QUARTERSTAFF;		
        case BASE_ITEM_RAPIER:         return FEAT_EPIC_DEVASTATING_CRITICAL_RAPIER;
        case BASE_ITEM_SCIMITAR:       return FEAT_EPIC_DEVASTATING_CRITICAL_SCIMITAR;
        case BASE_ITEM_SCYTHE:         return FEAT_EPIC_DEVASTATING_CRITICAL_SCYTHE;
        case BASE_ITEM_SHORTBOW:       return FEAT_EPIC_DEVASTATING_CRITICAL_SHORTBOW;
        case BASE_ITEM_SHORTSPEAR:     return FEAT_EPIC_DEVASTATING_CRITICAL_SHORTSPEAR;
        case BASE_ITEM_SHORTSWORD:     return FEAT_EPIC_DEVASTATING_CRITICAL_SHORTSWORD;
        case BASE_ITEM_SHURIKEN:       return FEAT_EPIC_DEVASTATING_CRITICAL_SHURIKEN;
        case BASE_ITEM_SICKLE:         return FEAT_EPIC_DEVASTATING_CRITICAL_SICKLE;
        case BASE_ITEM_SLING:          return FEAT_EPIC_DEVASTATING_CRITICAL_SLING;
        case BASE_ITEM_THROWINGAXE:    return FEAT_EPIC_DEVASTATING_CRITICAL_THROWINGAXE;
        case BASE_ITEM_TRIDENT:			return FEAT_EPIC_DEVASTATING_CRITICAL_TRIDENT;		
        case BASE_ITEM_TWOBLADEDSWORD: return FEAT_EPIC_DEVASTATING_CRITICAL_TWOBLADEDSWORD;
        case BASE_ITEM_WARHAMMER:      return FEAT_EPIC_DEVASTATING_CRITICAL_WARHAMMER;
        case BASE_ITEM_WHIP:           return FEAT_EPIC_DEVASTATING_CRITICAL_WHIP;
		
	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_EPIC_DEVASTATING_CRITICAL_DBL_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_EPIC_DEVASTATING_CRITICAL_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_THINBLADE;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_COURTBLADE;
		case BASE_ITEM_FALCHION:			return FEAT_EPIC_DEVASTATING_CRITICAL_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_EPIC_DEVASTATING_CRITICAL_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_EPIC_DEVASTATING_CRITICAL_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_EPIC_DEVASTATING_CRITICAL_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_EPIC_DEVASTATING_CRITICAL_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_EPIC_DEVASTATING_CRITICAL_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_EPIC_DEVASTATING_CRITICAL_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_EPIC_DEVASTATING_CRITICAL_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_EPIC_DEVASTATING_CRITICAL_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_EPIC_DEVASTATING_CRITICAL_SAI;
		case BASE_ITEM_SAP:					return FEAT_EPIC_DEVASTATING_CRITICAL_SAP;				
    }
    return -1;
}

int GetWeaponOfChoiceFeatOfWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_BASTARDSWORD:   return FEAT_WEAPON_OF_CHOICE_BASTARDSWORD;
        case BASE_ITEM_BATTLEAXE:      return FEAT_WEAPON_OF_CHOICE_BATTLEAXE;
        case BASE_ITEM_CLUB:           return FEAT_WEAPON_OF_CHOICE_CLUB;
		case BASE_ITEM_CRAFTED_SCEPTER:   return FEAT_WEAPON_OF_CHOICE_CLUB;
        case BASE_ITEM_DAGGER:         return FEAT_WEAPON_OF_CHOICE_DAGGER;
        case BASE_ITEM_DIREMACE:       return FEAT_WEAPON_OF_CHOICE_DIREMACE;
        case BASE_ITEM_DOUBLEAXE:      return FEAT_WEAPON_OF_CHOICE_DOUBLEAXE;
        case BASE_ITEM_DWARVENWARAXE:  return FEAT_WEAPON_OF_CHOICE_DWAXE ;
        case BASE_ITEM_GREATAXE:       return FEAT_WEAPON_OF_CHOICE_GREATAXE;
        case BASE_ITEM_GREATSWORD:     return FEAT_WEAPON_OF_CHOICE_GREATSWORD;
        case BASE_ITEM_HALBERD:        return FEAT_WEAPON_OF_CHOICE_HALBERD;
        case BASE_ITEM_HANDAXE:        return FEAT_WEAPON_OF_CHOICE_HANDAXE;
        case BASE_ITEM_HEAVYFLAIL:     return FEAT_WEAPON_OF_CHOICE_HEAVYFLAIL;
        case BASE_ITEM_KAMA:           return FEAT_WEAPON_OF_CHOICE_KAMA;
        case BASE_ITEM_KATANA:         return FEAT_WEAPON_OF_CHOICE_KATANA;
        case BASE_ITEM_KUKRI:          return FEAT_WEAPON_OF_CHOICE_KUKRI;
        case BASE_ITEM_LIGHTFLAIL:     return FEAT_WEAPON_OF_CHOICE_LIGHTFLAIL;
        case BASE_ITEM_LIGHTHAMMER:    return FEAT_WEAPON_OF_CHOICE_LIGHTHAMMER;
        case BASE_ITEM_LIGHTMACE:      return FEAT_WEAPON_OF_CHOICE_LIGHTMACE;
        case BASE_ITEM_LONGSWORD:      return FEAT_WEAPON_OF_CHOICE_LONGSWORD;
        case BASE_ITEM_MORNINGSTAR:    return FEAT_WEAPON_OF_CHOICE_MORNINGSTAR;
        case BASE_ITEM_QUARTERSTAFF:   return FEAT_WEAPON_OF_CHOICE_QUARTERSTAFF;
        case BASE_ITEM_MAGICSTAFF:	   return FEAT_WEAPON_OF_CHOICE_QUARTERSTAFF;		
        case BASE_ITEM_RAPIER:         return FEAT_WEAPON_OF_CHOICE_RAPIER;
        case BASE_ITEM_SCIMITAR:       return FEAT_WEAPON_OF_CHOICE_SCIMITAR;
        case BASE_ITEM_SCYTHE:         return FEAT_WEAPON_OF_CHOICE_SCYTHE;
        case BASE_ITEM_SHORTSPEAR:     return FEAT_WEAPON_OF_CHOICE_SHORTSPEAR;
        case BASE_ITEM_SHORTSWORD:     return FEAT_WEAPON_OF_CHOICE_SHORTSWORD;
        case BASE_ITEM_SICKLE:         return FEAT_WEAPON_OF_CHOICE_SICKLE;
        case BASE_ITEM_TRIDENT:         return FEAT_WEAPON_OF_CHOICE_TRIDENT;		
        case BASE_ITEM_TWOBLADEDSWORD: return FEAT_WEAPON_OF_CHOICE_TWOBLADEDSWORD;
        case BASE_ITEM_WARHAMMER:      return FEAT_WEAPON_OF_CHOICE_WARHAMMER;
        case BASE_ITEM_WHIP:           return FEAT_WEAPON_OF_CHOICE_WHIP;
		
	//:: new item types
		case BASE_ITEM_DOUBLE_SCIMITAR:	  	return FEAT_WEAPON_OF_CHOICE_DBL_SCIMITAR;
		case BASE_ITEM_EAGLE_CLAW:			return FEAT_WEAPON_OF_CHOICE_EAGLE_CLAW;
        case BASE_ITEM_ELVEN_LIGHTBLADE:	return FEAT_WEAPON_OF_CHOICE_ELVEN_LIGHTBLADE;
        case BASE_ITEM_ELVEN_THINBLADE:		return FEAT_WEAPON_OF_CHOICE_ELVEN_THINBLADE;
        case BASE_ITEM_ELVEN_COURTBLADE:	return FEAT_WEAPON_OF_CHOICE_ELVEN_COURTBLADE;
		case BASE_ITEM_FALCHION:			return FEAT_WEAPON_OF_CHOICE_FALCHION;
		case BASE_ITEM_GOAD:				return FEAT_WEAPON_OF_CHOICE_GOAD;
		case BASE_ITEM_HEAVY_MACE:			return FEAT_WEAPON_OF_CHOICE_HEAVY_MACE;
		case BASE_ITEM_HEAVY_PICK:			return FEAT_WEAPON_OF_CHOICE_HEAVY_PICK;
		case BASE_ITEM_KATAR:				return FEAT_WEAPON_OF_CHOICE_KATAR;
		case BASE_ITEM_LIGHT_LANCE:			return FEAT_WEAPON_OF_CHOICE_LIGHT_LANCE;
		case BASE_ITEM_LIGHT_PICK:			return FEAT_WEAPON_OF_CHOICE_LIGHT_PICK;
		case BASE_ITEM_MAUL:				return FEAT_WEAPON_OF_CHOICE_MAUL;
		case BASE_ITEM_NUNCHAKU:			return FEAT_WEAPON_OF_CHOICE_NUNCHAKU;
		case BASE_ITEM_SAI:					return FEAT_WEAPON_OF_CHOICE_SAI;
		case BASE_ITEM_SAP:					return FEAT_WEAPON_OF_CHOICE_SAP;			
    }
    return -1;
}

int GetIsWeaponType(int iBaseType)
{
    return StringToInt(Get2DACache("baseitems", "WeaponType", iBaseType));
}

int GetIsWeapon(object oItem)
{
    return GetIsWeaponType(GetBaseItemType(oItem));
}

int GetWeaponSize(object oWeapon)
{
    if(!GetIsWeapon(oWeapon))
        return -1;

    int iBaseType = GetBaseItemType(oWeapon);

    // weapons hard-coded by PRC
    switch(iBaseType)
    {
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_QUARTERSTAFF:
        //case BASE_ITEM_MAGICSTAFF:		
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_ELVEN_COURTBLADE:
		case BASE_ITEM_MAUL:        
        case BASE_ITEM_FALCHION:
            return 4;
    }

    return StringToInt(Get2DACache("baseitems", "WeaponSize", iBaseType));
}

int GetIsShield(object oItem)
{
    switch(GetBaseItemType(oItem))
    {
        case BASE_ITEM_LARGESHIELD:
        case BASE_ITEM_SMALLSHIELD:
        case BASE_ITEM_TOWERSHIELD:
            return TRUE;
    }
    return FALSE;
}

// Special check for weapons with modified WeaponSize entry
// aka "Two-handed weapons equipped as one-handed"
// checks if size returned by GetWeaponSize() is different than setting in baseitems.2da
int PRCLargeWeaponCheck(int iBaseType, int nSize)
{
    string sTest;
    switch(iBaseType)
    {
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_QUARTERSTAFF:
        //case BASE_ITEM_MAGICSTAFF:		
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_ELVEN_COURTBLADE:
		case BASE_ITEM_MAUL:        
        case BASE_ITEM_FALCHION:
        {
            sTest = Get2DAString("baseitems", "WeaponSize", iBaseType);
            break;
        }
    }
    return sTest != "" && sTest != IntToString(nSize);
}

//::void main(){}