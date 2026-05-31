#include "zep_inc_craft"

int StartingConditional() {
    object oPC = GetPCSpeaker();
    object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    if (!GetIsObjectValid(oArmor) || GetPlotFlag(oArmor))
        return FALSE;

    if (GetIsDM(oPC)) return TRUE;

    string sRequired;
    int iAC = StringToInt(Get2DAString("parts_chest", "ACBONUS", GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO)));
    if (iAC==0)           sRequired = "ZEP_CR_CLOTH";
    if (iAC>=1 && iAC<=3) sRequired = "ZEP_CR_LEATHER";
    if (iAC>=4 && iAC<=5) sRequired = "ZEP_CR_SCALE";
    if (iAC>=6 && iAC<=8) sRequired = "ZEP_CR_METAL";

    object oNPC = GetLocalObject(oPC, "ZEP_CR_NPC");
    if (GetIsObjectValid(oNPC)) {
        if (GetLocalInt(oNPC, sRequired) == 1)
            return TRUE;
        else return FALSE;

    } else if (ZEP_CR_REQUIRE_PLACEABLE) {
        int i=1;
        object oPlaceable = GetNearestObjectByTag(ZEP_CR_PLACEABLE_TAG, oPC, 1);
        while (GetIsObjectValid(oPlaceable) && GetArea(oPC) == GetArea(oPlaceable)
            && GetDistanceBetween(oPC, oPlaceable) <= ZEP_CR_REQUIRED_DISTANCE) {
            if (GetLocalInt(oPlaceable, sRequired) == 1)
                return TRUE;
            oPlaceable = GetNearestObjectByTag(ZEP_CR_PLACEABLE_TAG, oPC, ++i);
        }
        return FALSE;
    }
    return TRUE;
}
