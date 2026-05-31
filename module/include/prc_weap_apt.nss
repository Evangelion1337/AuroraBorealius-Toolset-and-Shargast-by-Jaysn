//:://////////////////////////////////////////////
//:: Warblade - Weapon Aptitude
//:: prc_weap_apt
//:://////////////////////////////////////////////
/** @file
    Allows Warblade to chose aptitude weapon.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

#include "inc_dynconv"
#include "prc_feat_const"
#include "prc_inc_combat"

const string OPTION_FOCUS_WEAPON_1       = "PRC_WEAPAPT_FOCUS_1";
const string OPTION_CRITICAL_WEAPON_1    = "PRC_WEAPAPT_CRITICAL_1";
const string OPTION_FOCUS_WEAPON_2       = "PRC_WEAPAPT_FOCUS_2";
const string OPTION_CRITICAL_WEAPON_2    = "PRC_WEAPAPT_CRITICAL_2";

const string WEAPON_FILE = "prc_weap_items";

//:: Test void
//:: void main (){}

int GetFeatItemProperty(int nFeatNumber, int nStart, int nEnd)
{
    if (nFeatNumber >= 0)
    {
        int i;
        for(i=nStart; i<=nEnd; i++)
        {
            string sFeat = Get2DACache("iprp_feats", "FeatIndex", i);
            if(sFeat == "")
                continue;
            int nFeat = StringToInt(sFeat);
            if(nFeat == nFeatNumber)
                return i;
        }
    }
    return -1;
}

int GetWeaponFocusFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_FOCUS_CLUB, IP_CONST_FEAT_WEAPON_FOCUS_RAY);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_FOCUS_TRIDENT, IP_CONST_FEAT_WEAPON_FOCUS_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_FOCUS_EAGLE_CLAW, IP_CONST_FEAT_WEAPON_FOCUS_GOAD);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_FOCUS_ELVEN_LIGHTBLADE, IP_CONST_FEAT_WEAPON_FOCUS_ELVEN_LIGHTBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_FOCUS_ELVEN_THINBLADE, IP_CONST_FEAT_WEAPON_FOCUS_ELVEN_THINBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_FOCUS_ELVEN_COURTBLADE, IP_CONST_FEAT_WEAPON_FOCUS_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WeapFocCreature, IP_CONST_FEAT_WeapFocCreature);
    if(nItemProperty != -1) return nItemProperty;		
    return -1;
}

int GetEpicWeaponFocusFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_TRIDENT, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_EAGLE_CLAW, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_EAGLE_CLAW);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_CLUB, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_RAY);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_LIGHT_LANCE, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_GOAD);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_ELVEN_LIGHTBLADE, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_ELVEN_LIGHTBLADE);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_ELVEN_THINBLADE, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_ELVEN_THINBLADE);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_ELVEN_COURTBLADE, IP_CONST_FEAT_EPIC_WEAPON_FOCUS_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WeapEpicFocCreature, IP_CONST_FEAT_WeapEpicFocCreature);
    if(nItemProperty != -1) return nItemProperty;
    return -1;
}

int GetWeaponSpecializationFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_SPECIALIZATION_CLUB, IP_CONST_FEAT_WEAPON_SPECIALIZATION_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_SPECIALIZATION_TRIDENT, IP_CONST_FEAT_WEAPON_SPECIALIZATION_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_SPECIALIZATION_EAGLE_CLAW, IP_CONST_FEAT_WEAPON_SPECIALIZATION_EAGLE_CLAW);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_SPECIALIZATION_LIGHT_LANCE, IP_CONST_FEAT_WEAPON_SPECIALIZATION_GOAD);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE, IP_CONST_FEAT_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE);
    if(nItemProperty != -1) return nItemProperty;
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_SPECIALIZATION_ELVEN_THINBLADE, IP_CONST_FEAT_WEAPON_SPECIALIZATION_ELVEN_THINBLADE);
    if(nItemProperty != -1) return nItemProperty;	
	nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE, IP_CONST_FEAT_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;		
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WeapSpecCreature, IP_CONST_FEAT_WeapSpecCreature);
    if(nItemProperty != -1) return nItemProperty;
    return -1;
}

int GetEpicWeaponSpecializationFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_EAGLE_CLAW, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_EAGLE_CLAW);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_TRIDENT, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_CLUB, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHT_LANCE, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_GOAD);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_THINBLADE, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_THINBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE, IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WeapEpicSpecCreature, IP_CONST_FEAT_WeapEpicSpecCreature);
    if(nItemProperty != -1) return nItemProperty;
    return -1;
}

int GetImprovedCriticalFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_IMPROVED_CRITICAL_DAGGER, IP_CONST_FEAT_IMPROVED_CRITICAL_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_IMPROVED_CRITICAL_LIGHT_LANCE, IP_CONST_FEAT_IMPROVED_CRITICAL_GOAD);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_IMPROVED_CRITICAL_ELVEN_LIGHTBLADE, IP_CONST_FEAT_IMPROVED_CRITICAL_ELVEN_LIGHTBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_IMPROVED_CRITICAL_ELVEN_THINBLADE, IP_CONST_FEAT_IMPROVED_CRITICAL_ELVEN_THINBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_IMPROVED_CRITICAL_ELVEN_COURTBLADE, IP_CONST_FEAT_IMPROVED_CRITICAL_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_IMPROVED_CRITICAL_EAGLE_CLAW, IP_CONST_FEAT_IMPROVED_CRITICAL_EAGLE_CLAW);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_IMPROVED_CRITICAL_TRIDENT, IP_CONST_FEAT_IMPROVED_CRITICAL_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_ImpCritCreature, IP_CONST_FEAT_ImpCritCreature);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_IMPROVED_CRITICAL_UNARMED, IP_CONST_FEAT_IMPROVED_CRITICAL_UNARMED);
    if(nItemProperty != -1) return nItemProperty;
    return -1;
}

int GetOverwhelmingCriticalFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_TRIDENT, IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_EAGLE_CLAW, IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_EAGLE_CLAW);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_CLUB, IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHT_LANCE, IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_GOAD);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_OVERWHELMING_CRITICAL_ELVEN_LIGHTBLADE, IP_CONST_FEAT_OVERWHELMING_CRITICAL_ELVEN_LIGHTBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_OVERWHELMING_CRITICAL_ELVEN_THINBLADE, IP_CONST_FEAT_OVERWHELMING_CRITICAL_ELVEN_THINBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_OVERWHELMING_CRITICAL_ELVEN_COURTBLADE, IP_CONST_FEAT_OVERWHELMING_CRITICAL_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_OVERCRITICAL_CREATURE, IP_CONST_FEAT_OVERCRITICAL_CREATURE);
    if(nItemProperty != -1) return nItemProperty;
    return -1;
}

int GetDevastatingCriticalFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_TRIDENT, IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_EAGLE_CLAW, IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_EAGLE_CLAW);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_LIGHT_LANCE, IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_DEVASTATING_CRITICAL_ELVEN_LIGHTBLADE, IP_CONST_FEAT_DEVASTATING_CRITICAL_ELVEN_LIGHTBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_DEVASTATING_CRITICAL_ELVEN_THINBLADE, IP_CONST_FEAT_DEVASTATING_CRITICAL_ELVEN_THINBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_DEVASTATING_CRITICAL_ELVEN_COURTBLADE, IP_CONST_FEAT_DEVASTATING_CRITICAL_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_CLUB, IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_DEVCRITICAL_CREATURE, IP_CONST_FEAT_DEVCRITICAL_CREATURE);
    if(nItemProperty != -1) return nItemProperty;
    return -1;
}

int GetWeaponOfChoiceFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_OF_CHOICE_TRIDENT, IP_CONST_FEAT_WEAPON_OF_CHOICE_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_OF_CHOICE_EAGLE_CLAW, IP_CONST_FEAT_WEAPON_OF_CHOICE_EAGLE_CLAW);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_OF_CHOICE_SICKLE, IP_CONST_FEAT_WEAPON_OF_CHOICE_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_OF_CHOICE_LIGHT_LANCE, IP_CONST_FEAT_WEAPON_OF_CHOICE_GOAD);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_OF_CHOICE_ELVEN_LIGHTBLADE, IP_CONST_FEAT_WEAPON_OF_CHOICE_ELVEN_LIGHTBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_OF_CHOICE_ELVEN_THINBLADE, IP_CONST_FEAT_WEAPON_OF_CHOICE_ELVEN_THINBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_WEAPON_OF_CHOICE_ELVEN_COURTBLADE, IP_CONST_FEAT_WEAPON_OF_CHOICE_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;
	
    return -1;
}

int GetSanctifyMartialStrikeFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_SANCTIFY_MARTIAL_SICKLE, IP_CONST_FEAT_SANCTIFY_MARTIAL_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_SANCTIFY_MARTIAL_EAGLE_CLAW, IP_CONST_FEAT_SANCTIFY_MARTIAL_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    return -1;
}

int GetVileMartialStrikeFeatItemProperty(int nFeatNumber)
{
    int nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_VILE_MARTIAL_CLUB, IP_CONST_FEAT_VILE_MARTIAL_TRIDENT);
    if(nItemProperty != -1) return nItemProperty;
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_VILE_MARTIAL_MINDBLADE, IP_CONST_FEAT_VILE_MARTIAL_MINDBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    nItemProperty = GetFeatItemProperty(nFeatNumber, IP_CONST_FEAT_VILE_MARTIAL_EAGLE_CLAW, IP_CONST_FEAT_VILE_MARTIAL_ELVEN_COURTBLADE);
    if(nItemProperty != -1) return nItemProperty;	
    return -1;
}

struct WeaponFeat TakeWeaponFeatCensus(object oPC)
{
    struct WeaponFeat rWeaponFeatCensus = InitWeaponFeat(0);
    
    int i = 0;
    while(Get2DACache(WEAPON_FILE, "label", i) != "") //until we hit a nonexistant line
    {
       int nIndex = StringToInt(Get2DACache(WEAPON_FILE, "BaseItemsIndex", i));
       struct WeaponFeat rWeaponFeats = GetAllFeatsOfWeaponType(nIndex);

       //Weapon Focus line of feats
       if(rWeaponFeats.Focus != -1 && GetHasFeat(rWeaponFeats.Focus, oPC))
       {
           rWeaponFeatCensus.Focus += 1;
           int bEpicFocus = FALSE;
           if(rWeaponFeats.EpicFocus != -1 && GetHasFeat(rWeaponFeats.EpicFocus, oPC))
           {
               rWeaponFeatCensus.EpicFocus += 1;
               bEpicFocus = TRUE;
           }
           if(rWeaponFeats.Specialization != -1 && GetHasFeat(rWeaponFeats.Specialization, oPC))
           {
               rWeaponFeatCensus.Specialization += 1;
               if(rWeaponFeats.EpicSpecialization != -1 && bEpicFocus && GetHasFeat(rWeaponFeats.EpicSpecialization, oPC))
                   rWeaponFeatCensus.EpicSpecialization += 1;
           }
           if(rWeaponFeats.WeaponOfChoice != -1 && GetHasFeat(rWeaponFeats.WeaponOfChoice, oPC))
               rWeaponFeatCensus.WeaponOfChoice += 1;
           if(rWeaponFeats.SanctifyMartialStrike != -1 && GetHasFeat(rWeaponFeats.SanctifyMartialStrike, oPC))
               rWeaponFeatCensus.SanctifyMartialStrike += 1;
           if(rWeaponFeats.VileMartialStrike != -1 && GetHasFeat(rWeaponFeats.VileMartialStrike, oPC))
               rWeaponFeatCensus.VileMartialStrike += 1;
       }

       //Improved Critical line of feats
       if(rWeaponFeats.ImprovedCritical != -1 && GetHasFeat(rWeaponFeats.ImprovedCritical, oPC))
       {
           rWeaponFeatCensus.ImprovedCritical += 1;
           if(rWeaponFeats.OverwhelmingCritical != -1 && GetHasFeat(rWeaponFeats.OverwhelmingCritical, oPC))
           {
               rWeaponFeatCensus.OverwhelmingCritical += 1;
               if(rWeaponFeats.DevastatingCritical != -1 && GetHasFeat(rWeaponFeats.DevastatingCritical, oPC))
                   rWeaponFeatCensus.DevastatingCritical += 1;               
           }
       }

       i++; //go to next line
    }
    
    if(GetHasFeat(FEAT_WEAPON_FOCUS_APTITUDE_1, oPC))
        rWeaponFeatCensus.Focus += 1;
    if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_APTITUDE_1, oPC))
        rWeaponFeatCensus.Specialization += 1;
    if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_APTITUDE_1, oPC))
        rWeaponFeatCensus.EpicFocus += 1;
    if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_APTITUDE_1, oPC))
        rWeaponFeatCensus.EpicSpecialization += 1;
    if(GetHasFeat(FEAT_IMPROVED_CRITICAL_APTITUDE_1, oPC))
        rWeaponFeatCensus.ImprovedCritical += 1;
    if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_APTITUDE_1, oPC))
        rWeaponFeatCensus.OverwhelmingCritical += 1;
    if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_APTITUDE_1, oPC))
        rWeaponFeatCensus.DevastatingCritical += 1;
    if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_APTITUDE_1, oPC))
        rWeaponFeatCensus.WeaponOfChoice += 1;
    if(GetHasFeat(FEAT_SANCTIFY_MARTIAL_STRIKE_APTITUDE_1, oPC))
        rWeaponFeatCensus.SanctifyMartialStrike += 1;
    if(GetHasFeat(FEAT_VILE_MARTIAL_STRIKE_APTITUDE_1, oPC))
        rWeaponFeatCensus.VileMartialStrike += 1;

    if(GetHasFeat(FEAT_WEAPON_FOCUS_APTITUDE_2, oPC))
        rWeaponFeatCensus.Focus += 1;
    if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_APTITUDE_2, oPC))
        rWeaponFeatCensus.Specialization += 1;
    if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_APTITUDE_2, oPC))
        rWeaponFeatCensus.EpicFocus += 1;
    if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_APTITUDE_2, oPC))
        rWeaponFeatCensus.EpicSpecialization += 1;
    if(GetHasFeat(FEAT_IMPROVED_CRITICAL_APTITUDE_2, oPC))
        rWeaponFeatCensus.ImprovedCritical += 1;
    if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_APTITUDE_2, oPC))
        rWeaponFeatCensus.OverwhelmingCritical += 1;
    if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_APTITUDE_2, oPC))
        rWeaponFeatCensus.DevastatingCritical += 1;
    if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_APTITUDE_2, oPC))
        rWeaponFeatCensus.WeaponOfChoice += 1;
    if(GetHasFeat(FEAT_SANCTIFY_MARTIAL_STRIKE_APTITUDE_2, oPC))
        rWeaponFeatCensus.SanctifyMartialStrike += 1;
    if(GetHasFeat(FEAT_VILE_MARTIAL_STRIKE_APTITUDE_2, oPC))
        rWeaponFeatCensus.VileMartialStrike += 1;
    
    return rWeaponFeatCensus;
}

int WeaponItemType(object oWeapon)
{
    if(oWeapon == OBJECT_INVALID)
        return BASE_ITEM_INVALID; //Unarmed strike
    else
    {
        int nWeaponItemType = GetBaseItemType(oWeapon);
        if(StringToInt(Get2DACache("baseitems", "WeaponType", nWeaponItemType)) > 0)
            return nWeaponItemType;
        else
            return -1;
    }
}

object MainHandWeapon(object oPC)
{
    return GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
}

object OffHandWeapon(object oPC)
{
    return GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
}

void DoApplyWeaponAptitude(object oPC, struct WeaponFeat rWeaponFeatCensus, int nWeaponFeatThreshold, string sFocusWeaponOption, string sCriticalWeaponOption)
{
    object oPCHide = GetPCSkin(oPC);
    
    int nFocusWeaponIndex = GetLocalInt(oPC, sFocusWeaponOption);
    if(nFocusWeaponIndex)
    {
        int nFocusWeaponType = StringToInt(Get2DACache(WEAPON_FILE, "BaseItemsIndex", nFocusWeaponIndex-1));
        if(nFocusWeaponType == BASE_ITEM_INVALID+1)
            nFocusWeaponType = WeaponItemType(MainHandWeapon(oPC));
        else if (nFocusWeaponType == BASE_ITEM_INVALID+2)
            nFocusWeaponType = WeaponItemType(OffHandWeapon(oPC));

        if(nFocusWeaponType != -1)
        {        
            struct WeaponFeat rWeaponFeats = GetAllFeatsOfWeaponType(nFocusWeaponType);
            
            if(rWeaponFeatCensus.Focus >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.Focus;
                int nItemProperty = GetWeaponFocusFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Focus: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.EpicFocus >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.EpicFocus;
                int nItemProperty = GetEpicWeaponFocusFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Epic Focus: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.Specialization >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.Specialization;
                int nItemProperty = GetWeaponSpecializationFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Specialization: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.EpicSpecialization >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.EpicSpecialization;
                int nItemProperty = GetEpicWeaponSpecializationFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Epic Specialization: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.WeaponOfChoice >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.WeaponOfChoice;
                int nItemProperty = GetWeaponOfChoiceFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Weapon of Choice: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.SanctifyMartialStrike >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.SanctifyMartialStrike;
                int nItemProperty = GetSanctifyMartialStrikeFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Sanctify Martial Strike: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.VileMartialStrike >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.VileMartialStrike;
                int nItemProperty = GetVileMartialStrikeFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Vile Martial Strike: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }
            
            if(rWeaponFeatCensus.ImprovedCritical >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.ImprovedCritical;
                int nItemProperty = GetImprovedCriticalFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Improved Critical: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.OverwhelmingCritical >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.OverwhelmingCritical;
                int nItemProperty = GetOverwhelmingCriticalFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Overwhelming Critical: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.DevastatingCritical >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.DevastatingCritical;
                int nItemProperty = GetDevastatingCriticalFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Devastating Critical: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }            
        }
    }
    
/*    int nCriticalWeaponIndex = GetLocalInt(oPC, sCriticalWeaponOption);
    if(nCriticalWeaponIndex)
    {
        int nCriticalWeaponType = StringToInt(Get2DACache(WEAPON_FILE, "BaseItemsIndex", nCriticalWeaponIndex-1));
        if(nCriticalWeaponType == BASE_ITEM_INVALID+1)
            nCriticalWeaponType = WeaponItemType(MainHandWeapon(oPC));
        else if (nCriticalWeaponType == BASE_ITEM_INVALID+2)
            nCriticalWeaponType = WeaponItemType(OffHandWeapon(oPC));

        if(nCriticalWeaponType != -1)
        {
            struct WeaponFeat rWeaponFeats = GetAllFeatsOfWeaponType(nCriticalWeaponType);

            if(rWeaponFeatCensus.ImprovedCritical >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.ImprovedCritical;
                int nItemProperty = GetImprovedCriticalFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Improved Critical: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.OverwhelmingCritical >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.OverwhelmingCritical;
                int nItemProperty = GetOverwhelmingCriticalFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Overwhelming Critical: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }

            if(rWeaponFeatCensus.DevastatingCritical >= nWeaponFeatThreshold)
            {
                int nFeat = rWeaponFeats.DevastatingCritical;
                int nItemProperty = GetDevastatingCriticalFeatItemProperty(nFeat);
                if(DEBUG) DoDebug("Devastating Critical: " + IntToString(nFeat) + ", " + IntToString(nItemProperty));
                if (nItemProperty != -1)
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(nItemProperty), oPCHide);
            }
        }
    }*/
}

void ApplyWeaponAptitude(object oPC, int bAllowDuringCombat)
{
    if(!bAllowDuringCombat && GetIsInCombat(oPC))
    {
        FloatingTextStringOnCreature(GetStringByStrRef(16837722), oPC, FALSE);
        IncrementRemainingFeatUses(oPC, FEAT_WEAPON_APTITUDE);
        return;
    }

    struct WeaponFeat rWeaponFeatCensus = TakeWeaponFeatCensus(oPC);
    DoApplyWeaponAptitude(oPC, rWeaponFeatCensus, 1, OPTION_FOCUS_WEAPON_1, OPTION_CRITICAL_WEAPON_1);
    //DoApplyWeaponAptitude(oPC, rWeaponFeatCensus, 2, OPTION_FOCUS_WEAPON_2, OPTION_CRITICAL_WEAPON_2);
    SetLocalInt(oPC, "PRC_WEAPON_APTITUDE_APPLIED", 1);
    SetLocalInt(GetPCSkin(oPC), "PRC_WEAPON_APTITUDE_APPLIED", 1);
}
