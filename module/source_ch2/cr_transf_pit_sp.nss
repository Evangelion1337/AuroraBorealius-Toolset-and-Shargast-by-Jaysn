//::///////////////////////////////////////////////
//:: cr_tranf_pit_sp
//:: Define as Listening Patterns do Ivo Pitanguy
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: Created By: Clarion de Laffalot (clariondelaffalot@yahoo.com.br)
//:: Created On: 24-Abr-2004
//:://////////////////////////////////////////////
void main()
{
    SetListening(OBJECT_SELF,TRUE);
    SetListenPattern(OBJECT_SELF,"APP**",2001);
}

