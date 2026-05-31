//#include "x2_inc_craft"
#include "mk_inc_craft"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oBackup =  CIGetCurrentModBackup(oPC);
    object oItem = CIGetCurrentModItem(oPC);

    int iResult;
    if (CIGetCurrentModMode(oPC)==MK_CI_MODMODE_CHARACTER)
    {
        iResult = MK_GetIsDescriptionModified(oPC);
    }
    else
    {
        iResult = MK_GetIsModified(oItem, oBackup);
    }

    return iResult;
}
