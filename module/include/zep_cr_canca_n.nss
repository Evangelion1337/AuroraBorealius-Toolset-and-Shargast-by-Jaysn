#include "zep_inc_craft"

int StartingConditional() {
    object oPC = GetPCSpeaker();
    object oArmor = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
    if (!GetIsObjectValid(oArmor) || GetPlotFlag(oArmor)) {
        oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
        if (!GetIsObjectValid(oArmor) || GetPlotFlag(oArmor)) {
            SetCustomToken(ZEP_CR_TOKENBASE+4, "You do not have any armor or helmet equipped to modify");
            return TRUE;
        }
    }

    if (GetIsDM(oPC)) return FALSE;

    string sRequired;
    if (GetBaseItemType(oArmor)==BASE_ITEM_HELMET) {
        sRequired = "ZEP_CR_HELMET";
    } else {
        int iAC = StringToInt(Get2DAString("parts_chest", "ACBONUS", GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO)));
        if (iAC==0)           sRequired = "ZEP_CR_CLOTH";
        if (iAC>=1 && iAC<=3) sRequired = "ZEP_CR_LEATHER";
        if (iAC>=4 && iAC<=5) sRequired = "ZEP_CR_SCALE";
        if (iAC>=6 && iAC<=8) sRequired = "ZEP_CR_METAL";
    }

    object oNPC = GetLocalObject(oPC, "ZEP_CR_NPC");
    if (GetIsObjectValid(oNPC)) {
        if (GetLocalInt(oNPC, sRequired) == 1)
            return FALSE;
        SetCustomToken(ZEP_CR_TOKENBASE+4, "This craftsman cannot modify your current equipped armor or helmet");
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
        SetCustomToken(ZEP_CR_TOKENBASE+4, "You're not near the proper tool to craft your armor or helmet");
        return TRUE;
    }
    return FALSE;
}
