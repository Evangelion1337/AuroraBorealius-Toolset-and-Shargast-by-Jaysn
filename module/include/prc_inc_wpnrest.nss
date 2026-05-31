//::///////////////////////////////////////////////
//:: Weapon Restriction System Include
//:: prc_inc_wpnrest.nss
//::///////////////////////////////////////////////
/*
    Functions to support PnP Weapon Proficiency and
    weapon feat chain simulation
*/
//:://////////////////////////////////////////////
//:: Created By: Fox
//:: Created On: Feb 2, 2008
//:://////////////////////////////////////////////

#include "prc_inc_fork"
#include "inc_item_props"
#include "prc_x2_itemprop"

//:: Detects if "monk" gloves are being equipped & set a 
//:: variable if TRUE for use with other functions
void DetectMonkGloveEquip(object oItem)
{
	int nItemType	= GetBaseItemType(oItem);
	
	object oPC = GetItemPossessor(oItem);
    if (!GetIsObjectValid(oItem))
    {
        if (DEBUG) DoDebug("prc_inc_wpnrest >> DetectMonkGloveEquip(): Unable to determine item possessor");
        return;
    }
	
	if(nItemType != BASE_ITEM_GLOVES && nItemType != BASE_ITEM_BRACER) {return;}
	
	else if (nItemType == BASE_ITEM_BRACER)
	{
		if(DEBUG) DoDebug("prc_inc_wpnrest >> DetectMonkGloveEquip(): Bracer found!");
		DeleteLocalInt(oPC, "WEARING_MONK_GLOVES");
		return;
	}	
	else
	{
		itemproperty ipG = GetFirstItemProperty(oItem);
	
		while(GetIsItemPropertyValid(ipG))
		{
			int nTypeG = GetItemPropertyType(ipG);

			// Damage related properties we care about
			if(nTypeG == ITEM_PROPERTY_DAMAGE_BONUS
			|| nTypeG == ITEM_PROPERTY_ATTACK_BONUS
			|| nTypeG == ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP
			|| nTypeG == ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP
			|| nTypeG == ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT)
			{
				if(DEBUG) DoDebug("prc_inc_wpnrest >> DetectMonkGloves(): Monk gloves found!");
				SetLocalInt(oPC, "WEARING_MONK_GLOVES", 1);
				return;
			}
			else
			{
				if(DEBUG) DoDebug("prc_inc_wpnrest >> DetectMonkGloves(): Monk gloves not found!  You should never see this.");
				DeleteLocalInt(oPC, "WEARING_MONK_GLOVES");
				return;
			}
		}
	}
}

/**
 * All of the following functions use the following parameters:
 *
 * @param oPC       The character weilding the weapon
 * @param oItem     The item in question.
 * @param nHand     The hand the weapon is wielded in.  In the form of 
 *                  ATTACK_BONUS_ONHAND or ATTACK_BONUS_OFFHAND.
 */ 
//:: returns TRUE if the wielded weapon works with the Swashbuckler's class abilities.
int GetHasSwashbucklerWeapon(object oPC)
{
    object oWeap = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (!GetIsObjectValid(oWeap)) return FALSE;

    int nType = GetBaseItemType(oWeap);

    switch (nType)
    {
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_KATAR:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_KAMA:
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_LIGHT_PICK:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_WHIP:
        case BASE_ITEM_SAI:
        case BASE_ITEM_SAP:
        case BASE_ITEM_NUNCHAKU:
        case BASE_ITEM_GOAD:
        case BASE_ITEM_ELVEN_LIGHTBLADE:
        case BASE_ITEM_ELVEN_THINBLADE:
        case BASE_ITEM_EAGLE_CLAW:
            return TRUE;
    }

    // Iaijutsu Master allows katana
    if (GetLevelByClass(CLASS_TYPE_IAIJUTSU_MASTER, oPC) > 0)
    {
        if (nType == BASE_ITEM_KATANA) return TRUE;
    }

    return FALSE;
}
 
//:: returns TRUE if the wielded weapon works with the Champion of Corellon's Elegant Strike.
int GetHasCorellonWeapon(object oPC)
{
    object oWeap = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (!GetIsObjectValid(oWeap)) return FALSE;

    int nType = GetBaseItemType(oWeap);

    switch (nType)
    {
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_ELVEN_COURTBLADE:
        case BASE_ITEM_ELVEN_LIGHTBLADE:
        case BASE_ITEM_ELVEN_THINBLADE:
            return TRUE;
    }
	
	return FALSE;
}

void DoRacialEquip(object oPC, int nBaseType);
 
 //return if PC has proficiency in an item
int IsProficient(object oPC, int nBaseItem)
{
    switch(nBaseItem)
    {
        //special case: counts as simple for chitine
        case BASE_ITEM_SHORTSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)
                 || GetHasFeat(FEAT_MINDBLADE, oPC)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC) && GetRacialType(oPC) == RACIAL_TYPE_CHITINE)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SHORTSWORD, oPC);

        case BASE_ITEM_CLUB:
			return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oPC)	
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)				
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_CLUB, oPC);	

        case BASE_ITEM_HEAVYCROSSBOW:
			return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oPC)	
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)				
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_HEAVY_XBOW, oPC);	

		case BASE_ITEM_LIGHTCROSSBOW:
			return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oPC)	
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)				
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_LIGHT_XBOW, oPC);	

        case BASE_ITEM_DAGGER:
			return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oPC)	
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)				
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_DAGGER, oPC);	
				 
		case BASE_ITEM_LONGSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_MINDBLADE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_LONGSWORD, oPC);

        case BASE_ITEM_BATTLEAXE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC) && GetRacialType(oPC) == RACIAL_TYPE_GNOLL)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_BATTLEAXE, oPC);

        case BASE_ITEM_BASTARDSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC)
                 || GetHasFeat(FEAT_MINDBLADE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_BASTARD_SWORD, oPC);

        case BASE_ITEM_LIGHTFLAIL:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_LIGHT_FLAIL, oPC);

        case BASE_ITEM_WARHAMMER:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_WARHAMMER, oPC);

        case BASE_ITEM_LONGBOW:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_LONGBOW, oPC);

        case BASE_ITEM_LIGHTMACE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_LIGHT_MACE, oPC);

        case BASE_ITEM_HALBERD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_HALBERD, oPC);

        case BASE_ITEM_SHORTBOW:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oPC)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC) && GetRacialType(oPC) == RACIAL_TYPE_GNOLL)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SHORTBOW, oPC);

        case BASE_ITEM_TWOBLADEDSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_TWO_BLADED_SWORD, oPC);

        case BASE_ITEM_GREATSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_GREATSWORD, oPC);

        case BASE_ITEM_GREATAXE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_GREATAXE, oPC);

        case BASE_ITEM_DART:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DART, oPC);

        case BASE_ITEM_DIREMACE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_DIRE_MACE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);

        case BASE_ITEM_DOUBLEAXE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_DOUBLE_AXE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);

        case BASE_ITEM_HEAVYFLAIL:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_HEAVY_FLAIL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);

        case BASE_ITEM_LIGHTHAMMER:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_LIGHT_HAMMER, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);

        case BASE_ITEM_HANDAXE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_HANDAXE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oPC);

        case BASE_ITEM_KAMA:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_KAMA, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);

        case BASE_ITEM_KATANA:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_KATANA, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);

        case BASE_ITEM_KUKRI:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_KUKRI, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);

        case BASE_ITEM_MORNINGSTAR:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MORNINGSTAR, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC);
                 
        case BASE_ITEM_QUARTERSTAFF:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_QUARTERSTAFF, oPC)
				||GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oPC);                

        case BASE_ITEM_MAGICSTAFF:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_QUARTERSTAFF, oPC)
				||GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oPC); 
				 
        case BASE_ITEM_RAPIER:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_RAPIER, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oPC);

        case BASE_ITEM_SCIMITAR:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SCIMITAR, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC);

        case BASE_ITEM_SCYTHE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SCYTHE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);

        case BASE_ITEM_SHORTSPEAR:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SHORTSPEAR, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC);

        case BASE_ITEM_SHURIKEN:
             return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SHURIKEN, oPC)
                  || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC)
                  || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oPC);

        case BASE_ITEM_SICKLE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SICKLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC);

        case BASE_ITEM_SLING:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SLING, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oPC);

        case BASE_ITEM_THROWINGAXE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_THROWING_AXE, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC)
                 || GetHasFeat(FEAT_MINDBLADE, oPC);

        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_CREATURE, oPC);

        case BASE_ITEM_TRIDENT:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_TRIDENT, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);
				 
        case BASE_ITEM_DOUBLE_SCIMITAR:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_DOUBLE_SCIMITAR, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);
				
        case BASE_ITEM_FALCHION:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_FALCHION, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);				

        case BASE_ITEM_GOAD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_GOAD, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC);	

        case BASE_ITEM_HEAVY_MACE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_HEAVY_MACE, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC);	
				
        case BASE_ITEM_HEAVY_PICK:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_HEAVY_PICK, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);					

        case BASE_ITEM_LIGHT_PICK:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_LIGHT_PICK, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);
				
        case BASE_ITEM_KATAR:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_KATAR, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oPC);

        case BASE_ITEM_MAUL:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MAUL, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);

        case BASE_ITEM_NUNCHAKU:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_NUNCHAKU, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);
				
        case BASE_ITEM_SAI:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SAI, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);

        case BASE_ITEM_SAP:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SAP, oPC)
				|| GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oPC)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC);
				
        //special case: counts as martial for dwarves
        case BASE_ITEM_DWARVENWARAXE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_DWARVEN_WARAXE, oPC)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC) && GetHasFeat(FEAT_DWARVEN, oPC))
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);

        case BASE_ITEM_WHIP:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_WHIP, oPC)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC);

        case BASE_ITEM_ELVEN_LIGHTBLADE:
			return GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC) && MyPRCGetRacialType(oPC) == RACIAL_TYPE_ELF)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELVEN_LIGHTBLADE, oPC);		

        case BASE_ITEM_ELVEN_THINBLADE:
			return GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC) && MyPRCGetRacialType(oPC) == RACIAL_TYPE_ELF)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELVEN_THINBLADE, oPC);

        case BASE_ITEM_ELVEN_COURTBLADE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC) && MyPRCGetRacialType(oPC) == RACIAL_TYPE_ELF)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELVEN_COURTBLADE, oPC); 
			
        //special case: counts as martial for asherati
        case BASE_ITEM_EAGLE_CLAW:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oPC)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oPC) && GetRacialType(oPC) == RACIAL_TYPE_ASHERATI)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EAGLE_CLAW, oPC);                 
    }

    return TRUE;
}

//gets the main weapon proficiency feat needed for a given weapon - mostly for Favored Soul
int GetWeaponProfFeatByType(int nBaseType)
{
    switch(nBaseType)
    {
		case BASE_ITEM_CLUB:
			return FEAT_WEAPON_PROFICIENCY_CLUB;
			
		case BASE_ITEM_QUARTERSTAFF:
			return FEAT_WEAPON_PROFICIENCY_QUARTERSTAFF;

		case BASE_ITEM_MAGICSTAFF:
			return FEAT_WEAPON_PROFICIENCY_QUARTERSTAFF;				
			  
		case BASE_ITEM_DAGGER:
			return FEAT_WEAPON_PROFICIENCY_DAGGER;	

		case BASE_ITEM_HEAVYCROSSBOW:
			return FEAT_WEAPON_PROFICIENCY_HEAVY_XBOW;	

		case BASE_ITEM_LIGHTCROSSBOW:
			return FEAT_WEAPON_PROFICIENCY_LIGHT_XBOW;		  
			  
		case BASE_ITEM_SHORTSWORD:
			return FEAT_WEAPON_PROFICIENCY_SHORTSWORD;

		case BASE_ITEM_LONGSWORD:
			return FEAT_WEAPON_PROFICIENCY_LONGSWORD;

		case BASE_ITEM_BATTLEAXE:
			return FEAT_WEAPON_PROFICIENCY_BATTLEAXE;

		case BASE_ITEM_BASTARDSWORD:
			return FEAT_WEAPON_PROFICIENCY_BASTARD_SWORD;

		case BASE_ITEM_LIGHTFLAIL:
			return FEAT_WEAPON_PROFICIENCY_LIGHT_FLAIL;

		case BASE_ITEM_WARHAMMER:
			return FEAT_WEAPON_PROFICIENCY_WARHAMMER;

		case BASE_ITEM_LONGBOW:
			return FEAT_WEAPON_PROFICIENCY_LONGBOW;

		case BASE_ITEM_LIGHTMACE:
			return FEAT_WEAPON_PROFICIENCY_LIGHT_MACE;

		case BASE_ITEM_HALBERD:
			return FEAT_WEAPON_PROFICIENCY_HALBERD;

		case BASE_ITEM_SHORTBOW:
          return FEAT_WEAPON_PROFICIENCY_SHORTBOW;

		case BASE_ITEM_TWOBLADEDSWORD:
          return FEAT_WEAPON_PROFICIENCY_TWO_BLADED_SWORD;

		case BASE_ITEM_GREATSWORD:
          return FEAT_WEAPON_PROFICIENCY_GREATSWORD;

		case BASE_ITEM_GREATAXE:
          return FEAT_WEAPON_PROFICIENCY_GREATAXE;

		case BASE_ITEM_DART:
          return FEAT_WEAPON_PROFICIENCY_DART;

		case BASE_ITEM_DIREMACE:
          return FEAT_WEAPON_PROFICIENCY_DIRE_MACE;

		case BASE_ITEM_DOUBLEAXE:
          return FEAT_WEAPON_PROFICIENCY_DOUBLE_AXE;

		case BASE_ITEM_HEAVYFLAIL:
          return FEAT_WEAPON_PROFICIENCY_HEAVY_FLAIL;

		case BASE_ITEM_LIGHTHAMMER:
          return FEAT_WEAPON_PROFICIENCY_LIGHT_HAMMER;

		case BASE_ITEM_HANDAXE:
          return FEAT_WEAPON_PROFICIENCY_HANDAXE;

		case BASE_ITEM_KAMA:
          return FEAT_WEAPON_PROFICIENCY_KAMA;

		case BASE_ITEM_KATANA:
          return FEAT_WEAPON_PROFICIENCY_KATANA;

		case BASE_ITEM_KUKRI:
          return FEAT_WEAPON_PROFICIENCY_KUKRI;

		case BASE_ITEM_MORNINGSTAR:
          return FEAT_WEAPON_PROFICIENCY_MORNINGSTAR;

		case BASE_ITEM_RAPIER:
          return FEAT_WEAPON_PROFICIENCY_RAPIER;

		case BASE_ITEM_SCIMITAR:
          return FEAT_WEAPON_PROFICIENCY_SCIMITAR;

		case BASE_ITEM_SCYTHE:
          return FEAT_WEAPON_PROFICIENCY_SCYTHE;

		case BASE_ITEM_SHORTSPEAR:
          return FEAT_WEAPON_PROFICIENCY_SHORTSPEAR;

		case BASE_ITEM_SHURIKEN:
          return FEAT_WEAPON_PROFICIENCY_SHURIKEN;

		case BASE_ITEM_SICKLE:
          return FEAT_WEAPON_PROFICIENCY_SICKLE;

		case BASE_ITEM_SLING:
          return FEAT_WEAPON_PROFICIENCY_SLING;

		case BASE_ITEM_THROWINGAXE:
          return FEAT_WEAPON_PROFICIENCY_THROWING_AXE;

		case BASE_ITEM_CSLASHWEAPON:
          return FEAT_WEAPON_PROFICIENCY_CREATURE;

		case BASE_ITEM_CPIERCWEAPON:
          return FEAT_WEAPON_PROFICIENCY_CREATURE;

		case BASE_ITEM_CBLUDGWEAPON:
          return FEAT_WEAPON_PROFICIENCY_CREATURE;

		case BASE_ITEM_CSLSHPRCWEAP:
          return FEAT_WEAPON_PROFICIENCY_CREATURE;

		case BASE_ITEM_TRIDENT:
          return FEAT_WEAPON_PROFICIENCY_TRIDENT;

		case BASE_ITEM_DWARVENWARAXE:
          return FEAT_WEAPON_PROFICIENCY_DWARVEN_WARAXE;

		case BASE_ITEM_WHIP:
          return FEAT_WEAPON_PROFICIENCY_WHIP;

		case BASE_ITEM_ELVEN_LIGHTBLADE:
          return FEAT_WEAPON_PROFICIENCY_ELVEN_LIGHTBLADE;

		case BASE_ITEM_ELVEN_THINBLADE:
          return FEAT_WEAPON_PROFICIENCY_ELVEN_THINBLADE;

		case BASE_ITEM_ELVEN_COURTBLADE:
          return FEAT_WEAPON_PROFICIENCY_ELVEN_COURTBLADE;

		case BASE_ITEM_HEAVY_PICK:
          return FEAT_WEAPON_PROFICIENCY_HEAVY_PICK;
          
		case BASE_ITEM_LIGHT_PICK:
          return FEAT_WEAPON_PROFICIENCY_LIGHT_PICK;      

		case BASE_ITEM_SAI:
          return FEAT_WEAPON_PROFICIENCY_SAI;
          
		case BASE_ITEM_NUNCHAKU:
          return FEAT_WEAPON_PROFICIENCY_NUNCHAKU; 
          
		case BASE_ITEM_FALCHION:
          return FEAT_WEAPON_PROFICIENCY_FALCHION;
          
		case BASE_ITEM_SAP:
          return FEAT_WEAPON_PROFICIENCY_SAP; 
          
		case BASE_ITEM_KATAR:
          return FEAT_WEAPON_PROFICIENCY_KATAR;
          
		case BASE_ITEM_HEAVY_MACE:
          return FEAT_WEAPON_PROFICIENCY_HEAVY_MACE; 
          
		case BASE_ITEM_MAUL:
          return FEAT_WEAPON_PROFICIENCY_MAUL;
          
		case BASE_ITEM_DOUBLE_SCIMITAR:
          return FEAT_WEAPON_PROFICIENCY_DOUBLE_SCIMITAR;   
          
		case BASE_ITEM_GOAD:
          return FEAT_WEAPON_PROFICIENCY_GOAD;
          
		case BASE_ITEM_EAGLE_CLAW:
          return FEAT_WEAPON_PROFICIENCY_EAGLE_CLAW;           

		default:
			return FEAT_WEAPON_PROFICIENCY_SIMPLE;
      }

      return 0;
}

//resolves Weapon Prof feats to their ItemProp counterparts
int GetWeaponProfIPFeat(int nWeaponProfFeat)
{
    return nWeaponProfFeat - 3300;
}

//:: Handles the feat emulation chain for Elven Lightblades
void DoEquipLightblade(object oPC, object oItem)
{
	effect eLightblade;
	int bHasEffect;
	
	//:: Weapon Focus
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD, oPC) || GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER, oPC))
    {
        eLightblade	= EffectBonusFeat(FEAT_WEAPON_FOCUS_ELVEN_LIGHTBLADE);
		bHasEffect 	= TRUE;
		
		//:: Epic Weapon Focus
        if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SHORTSWORD, oPC) || GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_RAPIER, oPC))
		{
			eLightblade = EffectLinkEffects(eLightblade, EffectBonusFeat(FEAT_EPIC_WEAPON_FOCUS_ELVEN_LIGHTBLADE));
		}
		//:: Weapon Specialization
        if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORT_SWORD, oPC) || GetHasFeat(FEAT_WEAPON_SPECIALIZATION_RAPIER, oPC))
        {
            eLightblade = EffectLinkEffects(eLightblade, EffectBonusFeat(FEAT_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE));

			//:: Epic Weapon Specialization
            if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTSWORD, oPC) || GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_RAPIER, oPC))
			{
				eLightblade = EffectLinkEffects(eLightblade, EffectBonusFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE));
			}
        }
    }
	//:: Improved Critical
    if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORT_SWORD, oPC) || GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER, oPC))
	{
		eLightblade = EffectLinkEffects(eLightblade, EffectBonusFeat(FEAT_IMPROVED_CRITICAL_ELVEN_LIGHTBLADE));
		bHasEffect 	= TRUE;
	} 
	
	if (bHasEffect)
	{
		eLightblade = TagEffect(eLightblade, "LIGHTBLADE_FEAT_EMULATATION");
		eLightblade = SupernaturalEffect(eLightblade);
		ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLightblade, oPC);
	}
}

/* //handles the feat chain for Elven Lightblades
void DoEquipLightblade(object oPC, object oItem)
{
    if(DEBUG) DoDebug("Checking Lightblade feats"); // optimised as some feats are prereq for others
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD, oPC) || GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER, oPC))
    {
        SetCompositeAttackBonus(oPC, "LightbladeWF" + IntToString(nHand), 1, nHand);
        if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SHORTSWORD, oPC) || GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_RAPIER, oPC))
            SetCompositeAttackBonus(oPC, "LightbladeEpicWF" + IntToString(nHand), 2, nHand);
        if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORT_SWORD, oPC) || GetHasFeat(FEAT_WEAPON_SPECIALIZATION_RAPIER, oPC))
        {
            SetCompositeDamageBonusT(oItem, "LightbladeWS", 2);
            if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTSWORD, oPC) || GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_RAPIER, oPC))
                SetCompositeDamageBonusT(oItem, "LightbladeEpicWS", 4);
        }
    }
    if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORT_SWORD, oPC) || GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER, oPC))
        IPSafeAddItemProperty(oItem, ItemPropertyKeen(), 99999.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
}
 */

//:: Handles the feat emulation chain for Elven Thinblades
void DoEquipThinblade(object oPC, object oItem)
{
	effect eThinblade;
	int bHasEffect;
	
	//:: Weapon Focus
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD, oPC) || GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER, oPC))
    {
        eThinblade 	= EffectBonusFeat(FEAT_WEAPON_FOCUS_ELVEN_THINBLADE);	
		bHasEffect 	= TRUE;
		
		//:: Epic Weapon Focus
        if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LONGSWORD, oPC) || GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_RAPIER, oPC))
		{
			eThinblade = EffectLinkEffects(eThinblade, EffectBonusFeat(FEAT_EPIC_WEAPON_FOCUS_ELVEN_THINBLADE));
		}
		//:: Weapon Specialization
        if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONG_SWORD, oPC) || GetHasFeat(FEAT_WEAPON_SPECIALIZATION_RAPIER, oPC))
        {
            eThinblade = EffectLinkEffects(eThinblade, EffectBonusFeat(FEAT_WEAPON_SPECIALIZATION_ELVEN_THINBLADE));

			//:: Epic Weapon Specialization
            if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LONGSWORD, oPC) || GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_RAPIER, oPC))
			{
				eThinblade = EffectLinkEffects(eThinblade, EffectBonusFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_THINBLADE));
			}
        }
    }
	//:: Improved Critical
    if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LONG_SWORD, oPC) || GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER, oPC))
	{
		eThinblade = EffectLinkEffects(eThinblade, EffectBonusFeat(FEAT_IMPROVED_CRITICAL_ELVEN_THINBLADE));
		bHasEffect 	= TRUE;
	} 
	
	if (bHasEffect)
	{
		eThinblade = TagEffect(eThinblade, "THINBLADE_FEAT_EMULATATION");
		eThinblade = SupernaturalEffect(eThinblade);
		ApplyEffectToObject(DURATION_TYPE_PERMANENT, eThinblade, oPC);
	}
}

/* //handles the feat chain for Elven Thinblades
void DoEquipThinblade(object oPC, object oItem, int nHand)
{
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD, oPC) || GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER, oPC))
    {
        SetCompositeAttackBonus(oPC, "ThinbladeWF" + IntToString(nHand), 1, nHand);
        if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LONGSWORD, oPC) || GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_RAPIER, oPC))
            SetCompositeAttackBonus(oPC, "ThinbladeEpicWF" + IntToString(nHand), 2, nHand);
        if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONG_SWORD, oPC) || GetHasFeat(FEAT_WEAPON_SPECIALIZATION_RAPIER, oPC))
        {
            SetCompositeDamageBonusT(oItem, "ThinbladeWS", 2);
            if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LONGSWORD, oPC) || GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_RAPIER, oPC))
                SetCompositeDamageBonusT(oItem, "ThinbladeEpicWS", 4);
        }
    }
    if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LONG_SWORD, oPC) || GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER, oPC))
        IPSafeAddItemProperty(oItem, ItemPropertyKeen(), 99999.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
} */

//:: Handles the feat emulation chain for Elven Courtblades
void DoEquipCourtblade(object oPC, object oItem)
{
	effect eCourtblade;
	int bHasEffect;
	
	//:: Weapon Focus
    if(GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD, oPC))
    {
        eCourtblade 	= EffectBonusFeat(FEAT_WEAPON_FOCUS_ELVEN_COURTBLADE);	
		bHasEffect 	= TRUE;
		
		//:: Epic Weapon Focus
        if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_GREATSWORD, oPC))
		{
			eCourtblade = EffectLinkEffects(eCourtblade, EffectBonusFeat(FEAT_EPIC_WEAPON_FOCUS_ELVEN_COURTBLADE));
		}
		//:: Weapon Specialization
        if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_SWORD, oPC))
        {
            eCourtblade = EffectLinkEffects(eCourtblade, EffectBonusFeat(FEAT_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE));

			//:: Epic Weapon Specialization
            if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_GREATSWORD, oPC))
			{
				eCourtblade = EffectLinkEffects(eCourtblade, EffectBonusFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE));
			}
        }
    }
	//:: Improved Critical
    if(GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_SWORD, oPC))
	{
		eCourtblade = EffectLinkEffects(eCourtblade, EffectBonusFeat(FEAT_IMPROVED_CRITICAL_ELVEN_COURTBLADE));
		bHasEffect 	= TRUE;
	} 
	
	if (bHasEffect)
	{
		eCourtblade = TagEffect(eCourtblade, "COURTBLADE_FEAT_EMULATATION");
		eCourtblade = SupernaturalEffect(eCourtblade);
		ApplyEffectToObject(DURATION_TYPE_PERMANENT, eCourtblade, oPC);
	}
}

/* void DoEquipCourtblade(object oPC, object oItem, int nHand)
{
    if(GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD, oPC))
    {
        SetCompositeAttackBonus(oPC, "CourtbladeWF" + IntToString(nHand), 1, nHand);
        if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_GREATSWORD, oPC))
            SetCompositeAttackBonus(oPC, "CourtbladeEpicWF" + IntToString(nHand), 2, nHand);
        if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_SWORD, oPC))
        {
            SetCompositeDamageBonusT(oItem, "CourtbladeWS", 2);
            if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_GREATSWORD, oPC))
                SetCompositeDamageBonusT(oItem, "CourtbladeEpicWS", 4);
        }
    }
    if(GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_SWORD, oPC))
        IPSafeAddItemProperty(oItem, ItemPropertyKeen(), 99999.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
} */

//clears any bonuses used to simulate feat chains on unequip
//:: None of this should be needed now  -Jaysyn
void DoWeaponFeatUnequip(object oPC, object oItem, int nHand)
{
    // fluffyamoeba - going to assume redundant local var clearing isn't worth tradeoff
    int nBaseType = GetBaseItemType(oItem);
    if(nBaseType == BASE_ITEM_ELVEN_LIGHTBLADE)
    {
        if(DEBUG) DoDebug("Clearing Lightblade variables.");
        SetCompositeAttackBonus(oPC, "LightbladeWF" + IntToString(nHand), 0, nHand);
        SetCompositeAttackBonus(oPC, "LightbladeEpicWF" + IntToString(nHand), 0, nHand);
        SetCompositeDamageBonusT(oItem, "LightbladeWS", 0);
        SetCompositeDamageBonusT(oItem, "LightbladeEpicWS", 0);
          if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORT_SWORD, oPC) || GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER, oPC))
              RemoveSpecificProperty(oItem, ITEM_PROPERTY_KEEN, -1, -1, 1, "", -1, DURATION_TYPE_TEMPORARY);
    }
    else if(nBaseType == BASE_ITEM_ELVEN_THINBLADE)
    {
        SetCompositeAttackBonus(oPC, "ThinbladeWF" + IntToString(nHand), 0, nHand);
        SetCompositeAttackBonus(oPC, "ThinbladeEpicWF" + IntToString(nHand), 0, nHand);
        SetCompositeDamageBonusT(oItem, "ThinbladeWS", 0);
        SetCompositeDamageBonusT(oItem, "ThinbladeEpicWS", 0);
          if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LONG_SWORD, oPC) || GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER, oPC))
              RemoveSpecificProperty(oItem, ITEM_PROPERTY_KEEN, -1, -1, 1, "", -1, DURATION_TYPE_TEMPORARY);
    }
    else if(nBaseType == BASE_ITEM_ELVEN_COURTBLADE)
    {
        SetCompositeAttackBonus(oPC, "CourtbladeWF" + IntToString(nHand), 0, nHand);
        SetCompositeAttackBonus(oPC, "CourtbladeEpicWF" + IntToString(nHand), 0, nHand);
        SetCompositeDamageBonusT(oItem, "CourtbladeWS", 0);
        SetCompositeDamageBonusT(oItem, "CourtbladeEpicWS", 0);
          if(GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_SWORD, oPC))
              RemoveSpecificProperty(oItem, ITEM_PROPERTY_KEEN, -1, -1, 1, "", -1, DURATION_TYPE_TEMPORARY);
    }
}

int IsMeleeWeapon(int nBaseItemType)
{
    // Reject invalid base item values.
    if (nBaseItemType == BASE_ITEM_INVALID)
    {
        return FALSE;
    }

    // Only want melee weapons, exclude all others.
    switch (nBaseItemType)
    {
        case BASE_ITEM_ALCHEMY:
        case BASE_ITEM_AMULET:
        case BASE_ITEM_ARMOR:
        case BASE_ITEM_ARROW:
        case BASE_ITEM_BELT:
        case BASE_ITEM_BLANK_POTION:
        case BASE_ITEM_BLANK_SCROLL:
        case BASE_ITEM_BLANK_WAND:
        case BASE_ITEM_BOLT:
        case BASE_ITEM_BOOK:
        case BASE_ITEM_BOOTS:
        case BASE_ITEM_BRACER:
        case BASE_ITEM_BULLET:
        case BASE_ITEM_CLOAK:
        case BASE_ITEM_CRAFTED_ROD:
        case BASE_ITEM_CRAFTED_STAFF:
		case BASE_ITEM_CRAFTED_SCEPTER:
        case BASE_ITEM_CRAFTMATERIALMED:
        case BASE_ITEM_CRAFTMATERIALSML:
        case BASE_ITEM_CREATUREITEM:
        case BASE_ITEM_ENCHANTED_POTION:
        case BASE_ITEM_ENCHANTED_SCROLL:
        case BASE_ITEM_ENCHANTED_WAND:
        case BASE_ITEM_GEM:
        case BASE_ITEM_GLOVES:
        case BASE_ITEM_GOLD:
        case BASE_ITEM_GOLEM:
        case BASE_ITEM_GRENADE:
        case BASE_ITEM_HEALERSKIT:
        case BASE_ITEM_HEAVYCROSSBOW:
        case BASE_ITEM_HELMET:
        case BASE_ITEM_KEY:
        case BASE_ITEM_LARGEBOX:
        case BASE_ITEM_LARGESHIELD:
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_MAGICROD:
        case BASE_ITEM_MAGICSTAFF:
        case BASE_ITEM_MAGICWAND:
        case BASE_ITEM_MISCLARGE:
        case BASE_ITEM_MISCMEDIUM:
        case BASE_ITEM_MISCSMALL:
        case BASE_ITEM_MISCTALL:
        case BASE_ITEM_MISCTHIN:
        case BASE_ITEM_MISCWIDE:
        case BASE_ITEM_POISON:
        case BASE_ITEM_POTIONS:
        case BASE_ITEM_RING:
        case BASE_ITEM_SCROLL:
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_SHURIKEN:             
        case BASE_ITEM_SLING:
        case BASE_ITEM_SMALLSHIELD:
        case BASE_ITEM_SPELLSCROLL:
        case BASE_ITEM_THIEVESTOOLS:
        case BASE_ITEM_THROWINGAXE:
        case BASE_ITEM_TORCH:
        case BASE_ITEM_TOWERSHIELD:
        case BASE_ITEM_TRAPKIT:
            return FALSE;
    }

    // Everything else assumed to be melee weapon.
    return TRUE;
}	

int IsWeaponMartial(int nBaseItemType, object oPC)
{
  switch(nBaseItemType)
  {
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
      case BASE_ITEM_TRIDENT:	  
      case BASE_ITEM_THROWINGAXE:
	  case BASE_ITEM_SCYTHE:
	  case BASE_ITEM_SAP:
	  case BASE_ITEM_MAUL:
	  case BASE_ITEM_FALCHION:
	  case BASE_ITEM_HEAVY_PICK:
	  case BASE_ITEM_LIGHT_PICK:
	  case BASE_ITEM_LIGHT_LANCE:
           return TRUE;

      //special case: counts as martial for dwarves
      case BASE_ITEM_DWARVENWARAXE:
          if(GetHasFeat(FEAT_DWARVEN, oPC))
            return TRUE;

      //special case: counts as martial for asherati
      case BASE_ITEM_EAGLE_CLAW:
          if(GetRacialType(oPC) == RACIAL_TYPE_ASHERATI)
            return TRUE;


      default:
           return FALSE;
  }
  return FALSE;
}

int IsWeaponExotic(int nBaseItemType)
{
	switch(nBaseItemType)
	{
		case BASE_ITEM_BASTARDSWORD:
		case BASE_ITEM_TWOBLADEDSWORD:
		case BASE_ITEM_DIREMACE:
		case BASE_ITEM_DOUBLEAXE:
		case BASE_ITEM_KAMA:
		case BASE_ITEM_KATANA:
		case BASE_ITEM_KUKRI:
		case BASE_ITEM_SHURIKEN:
		case BASE_ITEM_DWARVENWARAXE:
		case BASE_ITEM_WHIP:
		case BASE_ITEM_ELVEN_LIGHTBLADE:
		case BASE_ITEM_ELVEN_COURTBLADE:
		case BASE_ITEM_ELVEN_THINBLADE:
		case BASE_ITEM_SAI:
		case BASE_ITEM_NUNCHAKU:
		case BASE_ITEM_DOUBLE_SCIMITAR:	  
		case BASE_ITEM_EAGLE_CLAW:
			return TRUE;			
	}
	
	return FALSE;
}

//checks to see if the PC can wield the weapon.  If not, applies a -4 penalty.
void DoProficiencyCheck(object oPC, object oItem, int nHand)
{
    int bProficient = FALSE;
    int nBase = GetBaseItemType(oItem);

    bProficient = IsProficient(oPC, nBase);
    if (!bProficient) 
    {
        if (nHand == ATTACK_BONUS_ONHAND)
        {
            SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(ATTACK_BONUS_ONHAND), -4, ATTACK_BONUS_ONHAND);
        }
        if (nHand == ATTACK_BONUS_OFFHAND)
        {
            SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(ATTACK_BONUS_OFFHAND), -4, ATTACK_BONUS_OFFHAND);
        }

        // Handle specific double-sided weapon logic
        if (nBase == BASE_ITEM_DOUBLEAXE || nBase == BASE_ITEM_TWOBLADEDSWORD || nBase == BASE_ITEM_DIREMACE || nBase == BASE_ITEM_DOUBLE_SCIMITAR)
        { // This should only affect offhand if the main hand is these types
            SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(ATTACK_BONUS_OFFHAND), -4, ATTACK_BONUS_OFFHAND);
        }
    } 
	else
	{
		SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(ATTACK_BONUS_ONHAND), 0, ATTACK_BONUS_ONHAND);
		SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(ATTACK_BONUS_OFFHAND), 0, ATTACK_BONUS_OFFHAND);
	}
	
}

//checks to see if the PC can wield the weapon.  If not, applies a -4 penalty.
/* void DoProficiencyCheck(object oPC, object oItem, int nHand)
{
    int bProficient = FALSE;
  
    int nBase = GetBaseItemType(oItem);
    bProficient = IsProficient(oPC, nBase);
    
    // Warlock special code
    if (GetTag(oItem) == "prc_eldrtch_glv")
    	bProficient = TRUE;
    // Incarnate Weapon	
    if (GetTag(oItem) == "moi_incarnatewpn")
    	bProficient = TRUE;    	
    // Skarn Spine 	
    if (GetTag(oItem) == "skarn_spine")
    	bProficient = TRUE;     	

    if(!bProficient) 
    {
        if (DEBUG) DoDebug(GetName(oPC)+" is non-proficient with "+GetName(oItem));
        SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(nHand), -4, ATTACK_BONUS_ONHAND);
        if(nBase == BASE_ITEM_DOUBLEAXE || nBase == BASE_ITEM_TWOBLADEDSWORD || nBase == BASE_ITEM_DIREMACE || nBase == BASE_ITEM_DOUBLE_SCIMITAR)
            SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(ATTACK_BONUS_OFFHAND), -4, ATTACK_BONUS_OFFHAND);
    }
	else
	{
		SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(nHand), 0, ATTACK_BONUS_ONHAND);
        if(nBase == BASE_ITEM_DOUBLEAXE || nBase == BASE_ITEM_TWOBLADEDSWORD || nBase == BASE_ITEM_DIREMACE || nBase == BASE_ITEM_DOUBLE_SCIMITAR)
            SetCompositeAttackBonus(oPC, "Unproficient" + IntToString(ATTACK_BONUS_OFFHAND), 0, ATTACK_BONUS_OFFHAND);
	}	
}
 */

void DoWeaponEquip(object oPC, object oItem, int nHand)
{
    if(GetIsDM(oPC) || !GetIsWeapon(oItem)) return;

    if(GetTag(oItem) == "prc_eldrtch_glv") return;
    if(GetTag(oItem) == "PRC_PYRO_LASH_WHIP") return;

    //initialize variables
    int nRealSize = PRCGetCreatureSize(oPC);  //size for Finesse/TWF
    int nSize = nRealSize;                    //size for equipment restrictions
    int nWeaponSize = GetWeaponSize(oItem);
    int nStrMod = GetAbilityModifier(ABILITY_STRENGTH, oPC);
    int nElfFinesse = GetAbilityModifier(ABILITY_DEXTERITY, oPC) - nStrMod;
    int nTHFDmgBonus = nStrMod / 2;
    int nBaseType = GetBaseItemType(oItem);

    //Powerful Build bonus
    if(GetHasFeat(FEAT_RACE_POWERFUL_BUILD, oPC))
        nSize++;
    //Monkey Grip
    if(GetHasFeat(FEAT_MONKEY_GRIP, oPC))
    {
        nSize++;   
        // If you try and use the big weapons
        //if (nWeaponSize > nRealSize)
		if (nWeaponSize > nRealSize && GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC) != OBJECT_INVALID)
        {
            SetCompositeAttackBonus(oPC, "MonkeyGripL", -2, ATTACK_BONUS_OFFHAND);
            SetCompositeAttackBonus(oPC, "MonkeyGripR", -2, ATTACK_BONUS_ONHAND);
        }
		else
		{
            SetCompositeAttackBonus(oPC, "MonkeyGripL", 0, ATTACK_BONUS_OFFHAND);
            SetCompositeAttackBonus(oPC, "MonkeyGripR", 0, ATTACK_BONUS_ONHAND);		
		}
			
    }    

    if(DEBUG) DoDebug("prc_inc_wpnrest - Weapon size: " + IntToString(nWeaponSize));
    if(DEBUG) DoDebug("prc_inc_wpnrest - Character Size: " + IntToString(nSize));

    //check to make sure it's not too large, or that you're not trying to TWF with 2-handers
    if((nWeaponSize > 1 + nSize && nHand == ATTACK_BONUS_ONHAND)
    || ((nWeaponSize > nSize || GetWeaponSize(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC)) > nSize) && nHand == ATTACK_BONUS_OFFHAND))
    {
        if(DEBUG) DoDebug("prc_inc_wpnrest: Forcing unequip due to size");
        if(nHand == ATTACK_BONUS_OFFHAND)
                nHand = INVENTORY_SLOT_LEFTHAND;
        else
                nHand = INVENTORY_SLOT_RIGHTHAND;
        // Force unequip
        ForceUnequip(oPC, oItem, nHand);
    }
    
//:: Oversized TWF
//:: Check if the player is a Ranger, wearing medium/heavy armor, and does not have Two-Weapon Fighting feat
	int bIsRestricted = FALSE;

	// Check if the player has levels in the Ranger class
	if (GetLevelByClass(CLASS_TYPE_RANGER, oPC) > 0)
	{
		// Check if the player is wearing medium or heavy armor
		int nArmorType = GetArmorType(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
		if (nArmorType == ARMOR_TYPE_MEDIUM || nArmorType == ARMOR_TYPE_HEAVY)
		{
			// Check if the player does not have the Two-Weapon Fighting feat
			if (!GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oPC))
			{
				// Set the restricted flag to TRUE if all conditions are met
				bIsRestricted = TRUE;
			}
		}
	}
	//:: Proceed with OSTWF bonuses if the restrictions are not met
	if (!bIsRestricted)
	{
		if (GetHasFeat(FEAT_OTWF, oPC))  
		{   
			// When wielding a one-handed weapon in your off hand, you take penalties for fighting with two weapons as if you were wielding a light weapon in your off hand  
			if (nWeaponSize == nRealSize && nHand == ATTACK_BONUS_OFFHAND)  
			{  
				SetCompositeAttackBonus(oPC, "OTWFL", 2, ATTACK_BONUS_OFFHAND);  
				SetCompositeAttackBonus(oPC, "OTWFR", 2, ATTACK_BONUS_ONHAND);  
			}  
		}
/* 		if (GetHasFeat(FEAT_OTWF, oPC))
		{ 
			// When wielding a one-handed weapon in your off hand, you take penalties for fighting with two weapons as if you were wielding a light weapon in your off hand
			if (nWeaponSize == nRealSize && nHand == ATTACK_BONUS_OFFHAND)
			{
				SetCompositeAttackBonus(oPC, "OTWFL", 2, ATTACK_BONUS_OFFHAND);
				SetCompositeAttackBonus(oPC, "OTWFR", 2, ATTACK_BONUS_ONHAND);
			}
			else
			{				
				SetCompositeAttackBonus(oPC, "OTWFL", 0, ATTACK_BONUS_OFFHAND);
				SetCompositeAttackBonus(oPC, "OTWFR", 0, ATTACK_BONUS_ONHAND);				
			}
			
		} */
	}

    //check for proficiency
    DoProficiencyCheck(oPC, oItem, nHand);

//:: This is no longer needed with NWN:EE - Jaysyn
/*     //simulate Weapon Finesse for Elven *blades
    if((nBaseType == BASE_ITEM_ELVEN_LIGHTBLADE || nBaseType == BASE_ITEM_ELVEN_THINBLADE 
       || nBaseType == BASE_ITEM_ELVEN_COURTBLADE) && GetHasFeat(FEAT_WEAPON_FINESSE, oPC) && nElfFinesse > 0)
    {
      if(nHand == ATTACK_BONUS_ONHAND)
            SetCompositeAttackBonus(oPC, "ElfFinesseRH", nElfFinesse, nHand);
      else if(nHand == ATTACK_BONUS_OFFHAND)
            SetCompositeAttackBonus(oPC, "ElfFinesseLH", nElfFinesse, nHand);
    } */
    //Two-hand damage bonus
    if(!GetWeaponRanged(oItem) && PRCLargeWeaponCheck(nBaseType, nWeaponSize)
    && (nWeaponSize == nSize + 1 || (nWeaponSize == nRealSize + 1 && GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC) == OBJECT_INVALID) && nRealSize > CREATURE_SIZE_SMALL))
    {
        if(DEBUG) DoDebug("prc_inc_wpnrest - Two-hand Damage Bonus (Before Enhancement): " + IntToString(nTHFDmgBonus));    
        nTHFDmgBonus += IPGetWeaponEnhancementBonus(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS, FALSE);//include temp effects here
        if(DEBUG) DoDebug("prc_inc_wpnrest - Two-hand Damage Bonus: " + IntToString(nTHFDmgBonus));
        SetCompositeDamageBonusT(oItem, "THFBonus", nTHFDmgBonus);
    }

    //if a 2-hander, then unequip shield/offhand weapon
    if(nWeaponSize == 1 + nSize && nHand == ATTACK_BONUS_ONHAND)
        // Force unequip
        ForceUnequip(oPC, GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC), INVENTORY_SLOT_LEFTHAND);

    //apply TWF penalty if a one-handed, not light weapon in offhand - -4/-4 etc isntead of -2/-2
    //Does not apply to small races due to weapon size-up. Stupid size equip hardcoded restrictions.
    if(nWeaponSize == nRealSize && nHand == ATTACK_BONUS_OFFHAND && nRealSize > CREATURE_SIZE_MEDIUM)
    {
        // Assign penalty
        if(DEBUG) DoDebug("prc_inc_wpnrest - OTWFPenalty: " + IntToString(-2));
        SetCompositeAttackBonus(oPC, "OTWFPenalty", -2);
    }  
	else
	{
		SetCompositeAttackBonus(oPC, "OTWFPenalty", 0);
	}
	

    //:: Handle feat emulation Elven Blades
    if(nBaseType == BASE_ITEM_ELVEN_LIGHTBLADE)
        DoEquipLightblade(oPC, oItem);
    else if(nBaseType == BASE_ITEM_ELVEN_THINBLADE)
        DoEquipThinblade(oPC, oItem);
    else if(nBaseType == BASE_ITEM_ELVEN_COURTBLADE)
        DoEquipCourtblade(oPC, oItem);	
        
    DoRacialEquip(oPC, nBaseType);    
}

void DoWeaponsEquip(object oPC)
{
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    DelayCommand(0.2, DoWeaponEquip(oPC, oWeapon, ATTACK_BONUS_ONHAND));
    oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    DelayCommand(0.2, DoWeaponEquip(oPC, oWeapon, ATTACK_BONUS_OFFHAND));
}

void DoRacialEquip(object oPC, int nBaseType)
{
    if(GetRacialType(oPC) == RACIAL_TYPE_NEANDERTHAL)
    {
		if (nBaseType == BASE_ITEM_CLUB ||
		    nBaseType == BASE_ITEM_SHORTSPEAR ||
		    nBaseType == BASE_ITEM_QUARTERSTAFF ||
		    nBaseType == BASE_ITEM_SHORTBOW ||
		    nBaseType == BASE_ITEM_SLING ||
		    nBaseType == BASE_ITEM_THROWINGAXE)
		{    
			SetCompositeAttackBonus(oPC, "PrimitiveWeapon", 1);
		}
		else
    		SetCompositeAttackBonus(oPC, "PrimitiveWeapon", 0);
    }  
}

//:: void main (){}