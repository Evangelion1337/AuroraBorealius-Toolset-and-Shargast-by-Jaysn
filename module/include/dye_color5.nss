//::///////////////////////////////////////////////
//:: Dye Kit - Color 5
//:: dye_color5.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*
    Sets the color to 5.
*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: Dec. 10, 2004
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();

    SetLocalInt(oPC, "ColorToDye", 5);

    ExecuteScript("dye_dyeitem", oPC);
}
