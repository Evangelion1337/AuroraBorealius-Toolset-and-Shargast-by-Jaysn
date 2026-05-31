#include "zep_inc_craft"

int StartingConditional() {
    object oPC = GetPCSpeaker();
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (!GetIsObjectValid(oWeapon) || GetPlotFlag(oWeapon) || IPGetIsIntelligentWeapon(oWeapon) || !ZEP_GetIsWeapon(oWeapon)) {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
        if (!GetIsObjectValid(oWeapon) || GetPlotFlag(oWeapon) || !ZEP_GetIsShield(oWeapon)) {
            SetCustomToken(ZEP_CR_TOKENBASE+5, "You do not have any weapon or shield equipped to modify");
            return TRUE;
        }
    }

    if (GetIsDM(oPC)) return FALSE;

    string sRequired;
    switch (GetBaseItemType(oWeapon)) {
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_DWARVENWARAXE:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_KAMA:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_THROWINGAXE:
        case BASE_ITEM_TWOBLADEDSWORD:
        case BASE_ITEM_WARHAMMER: sRequired = "ZEP_CR_METAL"; break;

        case BASE_ITEM_CLUB:
        case BASE_ITEM_HEAVYCROSSBOW:
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_MAGICSTAFF:
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_SHORTBOW: sRequired = "ZEP_CR_WOOD"; break;

        case BASE_ITEM_SLING:
        case BASE_ITEM_WHIP: sRequired = "ZEP_CR_LEATHER"; break;

        case BASE_ITEM_SMALLSHIELD:
        case BASE_ITEM_LARGESHIELD:
        case BASE_ITEM_TOWERSHIELD: sRequired = "ZEP_CR_SHIELD"; break;
    }

    object oNPC = GetLocalObject(oPC, "ZEP_CR_NPC");
    if (GetIsObjectValid(oNPC)) {
        if (GetLocalInt(oNPC, sRequired) == 1)
            return FALSE;
        SetCustomToken(ZEP_CR_TOKENBASE+5, "This craftsman cannot modify your current equipped armor or helmet");
        return TRUE;

    } else if (ZEP_CR_REQUIRE_PLACEABLE) {
        int i=1;
        object oPlaceable = GetNearestObjectByTag(ZEP_CR_PLACEABLE_TAG, oPC, 1);
        while (GetIsObjectValid(oPlaceable) && GetArea(oPC) == GetArea(oPlaceable)
            && GetDistanceBetween(oPC, oPlaceable) <= ZEP_CR_REQUIRED_DISTANCE) {
            if (GetLocalInt(oPlaceable, sRequired) == 1)
                return FALSE;
            oPlaceable = GetNearestObjectByTag(ZEP_CR_PLACEABLE_TAG, oPC, ++i);
        }
        SetCustomToken(ZEP_CR_TOKENBASE+5, "You're not near the proper tool to craft your weapon or shield");
        return TRUE;
    }
    return FALSE;
}

