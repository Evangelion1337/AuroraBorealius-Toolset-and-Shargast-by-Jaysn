//::///////////////////////////////////////////////
//:: Dye Kit - Cloth 1
//:: dye_cloth1.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*
    Set the material to be died to Cloth 1.
*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: Dec. 10, 2004
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();

    SetLocalInt(oPC, "MaterialToDye", ITEM_APPR_ARMOR_COLOR_CLOTH1);
}
