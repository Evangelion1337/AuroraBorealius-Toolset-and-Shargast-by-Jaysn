//::///////////////////////////////////////////////
//:: cr_tranf_pit_cv
//:: Recebe a informacao da aparencia selecionada
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: Created By: Clarion de Laffalot (clariondelaffalot@yahoo.com.br)
//:: Created On: 24-Abr-2004
//:://////////////////////////////////////////////
void main()
{
    int i = 0;
    int nMatch = GetListenPatternNumber();
    if(nMatch == 2001)
    {
        int iX = StringToInt(GetMatchedSubstring(1));
        string sX = "Voce escolheu a aparencia " + IntToString(iX);
        SendMessageToPC(GetLastSpeaker(), sX);
        SetLocalInt(GetLastSpeaker(), "AparenciaTransf", iX);
    }
}
