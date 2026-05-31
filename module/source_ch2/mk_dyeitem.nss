//::///////////////////////////////////////////////
//:: Dye Kit - Dye Item
//:: dye_dyeitem.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*
    Dye the item.
*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: Jan. 10, 2004
//:: Modified By Kamiryn
//:: Modified on: Sep. 05, 2006
//:://////////////////////////////////////////////

#include "x2_inc_itemprop"
#include "x2_inc_craft"
#include "mk_inc_craft"

void main()
{
//    MK_init();

    object oPC = OBJECT_SELF;

    int iMaterialToDye = GetLocalInt(oPC, "MK_MaterialToDye");
    int iColorGroup = GetLocalInt(oPC, "MK_ColorGroup");
    int iColorToDye = GetLocalInt(oPC, "MK_ColorToDye");
    int nNumberOfColorsPerGroup = GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLORS_PER_GROUP");

    int iColor = (iColorGroup * nNumberOfColorsPerGroup) + iColorToDye;

    MK_DyeItem(oPC,iMaterialToDye,iColor);
}
