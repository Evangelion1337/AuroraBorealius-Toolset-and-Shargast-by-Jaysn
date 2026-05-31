//::///////////////////////////////////////////////
//:: Dye Kit - Color 7
//:: dye_color7.nss
//:: Copyright (c) 2003 Jake E. Fitch
//:://////////////////////////////////////////////
/*
    Sets the color to 7.
*/
//:://////////////////////////////////////////////
//:: Created By: Jake E. Fitch (Milambus Mandragon)
//:: Created On: Dec. 10, 2004
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();

    SetLocalInt(oPC, "ColorToDye", 7);

    ExecuteScript("dye_dyeitem", oPC);
}
