//::///////////////////////////////////////////////
//:: Dye Kit - Color 1
//:: dye_color1.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*
    Sets the color to 1.
*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: Dec. 10, 2004
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();

    SetLocalInt(oPC, "ColorToDye", 1);

    ExecuteScript("dye_dyeitem", oPC);
}
