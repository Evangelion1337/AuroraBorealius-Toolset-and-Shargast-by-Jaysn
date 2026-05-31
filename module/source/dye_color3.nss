//::///////////////////////////////////////////////
//:: Dye Kit - Color 3
//:: dye_color3.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*
    Sets the color to 3.
*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: Dec. 10, 2004
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();

    SetLocalInt(oPC, "ColorToDye", 3);

    ExecuteScript("dye_dyeitem", oPC);
}
