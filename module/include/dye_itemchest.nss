//::///////////////////////////////////////////////
//:: Dye Kit - Item = Chest
//:: dye_itemchest.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*
    Set the item to be died to the chest slot.
*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: Dec. 9, 2004
//:://////////////////////////////////////////////

#include "dye_include"

void main()
{
    object oPC = GetPCSpeaker();

    SetLocalInt(oPC, "ItemToDye", INVENTORY_SLOT_CHEST);

    object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);

    if (GetIsObjectValid(oItem)) {
        int iLeather1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1);
        int iLeather2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2);
        int iCloth1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1);
        int iCloth2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2);
        int iMetal1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
        int iMetal2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2);

        string sOutput = "Leather 1: " + ClothColor(iLeather1);
        sOutput += "\n" + "Leather 2: " + ClothColor(iLeather2);
        sOutput += "\n" + "Cloth 1: " + ClothColor(iCloth1);
        sOutput += "\n" + "Cloth 2: " + ClothColor(iCloth2);
        sOutput += "\n" + "Metal 1: " + MetalColor(iMetal1);
        sOutput += "\n" + "Metal 2: " + MetalColor(iMetal2);

        SendMessageToPC(oPC, sOutput);
    }
}
