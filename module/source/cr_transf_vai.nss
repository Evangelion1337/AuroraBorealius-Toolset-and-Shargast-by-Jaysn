//::///////////////////////////////////////////////
//:: cr_tranf_vai
//:: Executa a transformacao
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: Created By: Clarion de Laffalot (clariondelaffalot@yahoo.com.br)
//:: Created On: 24-Abr-2004
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker();
    object oAlvo = GetLocalObject(oPC, "TransfAlvo");
    int iX = GetLocalInt(oPC, "AparenciaTransf");
    SetCreatureAppearanceType(oAlvo, iX);
}
