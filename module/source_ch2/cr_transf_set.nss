//::///////////////////////////////////////////////
//:: cr_transf_set
//:: Cria o Pitanguy e dah 1 minuto para se escolher a aparencia a aplicar
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: Created By: Clarion de Laffalot (clariondelaffalot@yahoo.com.br)
//:: Created On: 24-Abr-2004
//:://////////////////////////////////////////////
void main()
{
    location lOnde = GetLocation(GetPCSpeaker());
    object oPT = CreateObject(OBJECT_TYPE_CREATURE, "core_pitanguy", lOnde);
    SendMessageToPC(GetPCSpeaker(), "Diga app999, onde 999 eh o codigo da aparencia. Lembre-se de estar visivel. Voce tem 1 minuto para escolher");
    DestroyObject(oPT, 60.0);
}
