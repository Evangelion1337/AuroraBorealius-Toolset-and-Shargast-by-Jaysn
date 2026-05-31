//::///////////////////////////////////////////////
//:: Weapon Spawn Script for Martial Classes
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Spawns in a weapon for a Martial class depending
    on Weapon Focus feat.
*/
//:://////////////////////////////////////////////
//:: Created By:   Andrew
//:: Created On:   February 2002
//:://////////////////////////////////////////////
/*void GetWeaponFocus(object oLastOpener)
{
    if (GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD,oLastOpener))
    {
        CreateItemOnObject("NW_WSWBS001", OBJECT_SELF);
        //return TRUE;
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE,oLastOpener))
    {
        //CreateIt("NW_WAXBT001");
        return TRUE;
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_CLUB,oLastOpener))
    {
            CreateIt("NW_WBLCL001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER,oLastOpener))
    {
            CreateIt("NW_WSWDG001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DART,oLastOpener))
    {
            CreateIt("NW_WTHDT001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE,oLastOpener))
    {
            CreateIt("NW_WDBMA001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE,oLastOpener))
    {
            CreateIt("NW_WDBAX001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE,oLastOpener))
    {
            CreateIt("NW_WAXGR001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD,oLastOpener))
    {
            CreateIt("NW_WSWGS001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD,oLastOpener))
    {
            CreateIt("NW_WPLHB001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE,oLastOpener))
    {
            CreateIt("NW_WAXHN001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW,oLastOpener))
    {
            CreateIt("NW_WBWXH001");
            CreateIt("NW_WAMBO001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL,oLastOpener))
    {
            CreateIt("NW_WBLFH001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_KAMA,oLastOpener))
    {
            CreateIt("NW_WSPKA001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_KATANA,oLastOpener))
    {
            CreateIt("NW_WSWKA001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI,oLastOpener))
    {
          CreateIt("NW_WSPKU001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW,oLastOpener))
    {
            CreateIt("NW_WBWXL001");
            CreateIt("NW_WAMBO001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL,oLastOpener))
    {
            CreateIt("NW_WBLFL001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER,oLastOpener))
    {
            CreateIt("NW_WBLHL001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE,oLastOpener))
    {
          CreateIt("NW_WBLML001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD,oLastOpener))
    {
            CreateIt("NW_WSWLS001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW,oLastOpener))
    {
            CreateIt("NW_WBWLN001");
            CreateIt("NW_WAMAR001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR,oLastOpener))
    {
            CreateIt("NW_WBLMS001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER,oLastOpener))
    {
            CreateIt("NW_WSWRP001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR,oLastOpener))
    {
            CreateIt("NW_WSWSC001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE,oLastOpener))
    {
            CreateIt("NW_WPLSC001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD,oLastOpener))
    {
            CreateIt("NW_WSWSS001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW,oLastOpener))
    {
            CreateIt("NW_WBWSH001");
            CreateIt("NW_WAMAR001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN,oLastOpener))
    {
            CreateIt("NW_WTHSH001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE,oLastOpener))
    {
            CreateIt("NW_WSPSC001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SLING,oLastOpener))
    {
            CreateIt("NW_WBWSL001");
            CreateIt("NW_WAMBU001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR,oLastOpener))
    {
            CreateIt("NW_WPLSS001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_STAFF,oLastOpener))
    {
            CreateIt("NW_WDBQS001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_THROWING_AXE,oLastOpener))
    {
            CreateIt("NW_WTHAX001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD,oLastOpener))
    {
            CreateIt("NW_WDBSW001");
    }
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER,oLastOpener))
    {
            CreateIt("NW_WBLHW001");
    }
       //return FALSE;
}*/

//string GetValidWeapon(object oLastOpener, string s)
//{
//    string s = GetValidWeapon(o, s)

#include "NW_O2_CONINCLUDE"

void main()
{
    object oPlayer = LastOpener();
    object oLastOpener = LastOpener();

    if (GetIsObjectValid(oLastOpener) == FALSE)
    {
        return; // * abort treasure if no one opened the container
    }

    if (IsArcane(oPlayer) == TRUE)
    {
        if (GetLocalInt(OBJECT_SELF,"NW_DO_ONCE") != 0)
        {
            return;
        }
        else
        {
            CreateIt("NW_IT_MPOTION001");
        }
    }
    ShoutDisturbed();


    if (IsDivine(oPlayer) == TRUE)
    {
        if (GetLocalInt(OBJECT_SELF,"NW_DO_ONCE") != 0)
        {
            return;
        }
        else
        {
            CreateIt("NW_IT_MPOTION001");
        }
    }
    ShoutDisturbed();


    if (IsNature(oPlayer) == TRUE)
    {
        if (GetLocalInt(OBJECT_SELF,"NW_DO_ONCE") != 0)
        {
            return;
        }
        else
        {
            CreateIt("NW_IT_MPOTION001");
        }
    }
    ShoutDisturbed();

    if (IsMartial(oPlayer) == TRUE)
    {
        if (GetLocalInt(OBJECT_SELF,"NW_DO_ONCE") != 0)
        {
            return;
        }
        
        // Checks for Weapon Focus and gives out the appropriate weapon.

        else if (GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD,oLastOpener))
        {
            CreateIt("NW_WSWBS001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE,oLastOpener))
        {
            CreateIt("NW_WAXBT001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_CLUB,oLastOpener))
        {
            CreateIt("NW_WBLCL001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER,oLastOpener))
        {
            CreateIt("NW_WSWDG001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_DART,oLastOpener))
        {
            CreateIt("NW_WTHDT001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE,oLastOpener))
        {
            CreateIt("NW_WDBMA001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE,oLastOpener))
        {
            CreateIt("NW_WDBAX001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE,oLastOpener))
        {
            CreateIt("NW_WAXGR001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD,oLastOpener))
        {
            CreateIt("NW_WSWGS001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD,oLastOpener))
        {
            CreateIt("NW_WPLHB001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE,oLastOpener))
        {
            CreateIt("NW_WAXHN001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW,oLastOpener))
        {
            CreateIt("NW_WBWXH001");
            CreateIt("NW_WAMBO001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL,oLastOpener))
        {
            CreateIt("NW_WBLFH001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_KAMA,oLastOpener))
        {
            CreateIt("NW_WSPKA001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_KATANA,oLastOpener))
        {
            CreateIt("NW_WSWKA001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI,oLastOpener))
        {
            CreateIt("NW_WSPKU001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW,oLastOpener))
        {
            CreateIt("NW_WBWXL001");
            CreateIt("NW_WAMBO001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL,oLastOpener))
        {
            CreateIt("NW_WBLFL001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER,oLastOpener))
        {
            CreateIt("NW_WBLHL001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE,oLastOpener))
        {
            CreateIt("NW_WBLML001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD,oLastOpener))
        {
            CreateIt("NW_WSWLS001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW,oLastOpener))
        {
            CreateIt("NW_WBWLN001");
            CreateIt("NW_WAMAR001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR,oLastOpener))
        {
            CreateIt("NW_WBLMS001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER,oLastOpener))
        {
            CreateIt("NW_WSWRP001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR,oLastOpener))
        {
            CreateIt("NW_WSWSC001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE,oLastOpener))
        {
            CreateIt("NW_WPLSC001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD,oLastOpener))
        {
            CreateIt("NW_WSWSS001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW,oLastOpener))
        {
            CreateIt("NW_WBWSH001");
            CreateIt("NW_WAMAR001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN,oLastOpener))
        {
            CreateIt("NW_WTHSH001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE,oLastOpener))
        {
            CreateIt("NW_WSPSC001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_SLING,oLastOpener))
        {
            CreateIt("NW_WBWSL001");
            CreateIt("NW_WAMBU001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR,oLastOpener))
        {
            CreateIt("NW_WPLSS001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_STAFF,oLastOpener))
        {
            CreateIt("NW_WDBQS001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_THROWING_AXE,oLastOpener))
        {
            CreateIt("NW_WTHAX001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD,oLastOpener))
        {
            CreateIt("NW_WDBSW001");
        }
        else if (GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER,oLastOpener))
        {
            CreateIt("NW_WBLHW001");
        }
        else
        {
            CreateIt("NW_IT_MPOTION001");
        }
    }
    ShoutDisturbed();

    if (IsMonk(oPlayer) == TRUE)
    {
        if (GetLocalInt(OBJECT_SELF,"NW_DO_ONCE") != 0)
        {
            return;
        }
        else
        {
            CreateIt("NW_IT_MPOTION001");
        }
    }
    ShoutDisturbed();
}
