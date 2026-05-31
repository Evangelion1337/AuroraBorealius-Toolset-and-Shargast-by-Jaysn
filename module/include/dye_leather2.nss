//::///////////////////////////////////////////////
//:: Dye Kit - Leather 2
//:: dye_leather2.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*
    Set the material to be died to Leather 2.
*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: Dec. 10, 2004
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();

    SetLocalInt(oPC, "MaterialToDye", ITEM_APPR_ARMOR_COLOR_LEATHER2);
}
