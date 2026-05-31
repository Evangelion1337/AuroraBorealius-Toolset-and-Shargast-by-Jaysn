//Filename: trap_on_acquire
//Usage:
//      Trap companion script for CEP traps...for finding traps.

#include "zep_inc_scrptdlg"

void main()
{
    object oItem = GetModuleItemAcquired();
    object oPC = GetModuleItemAcquiredFrom();
    if((GetBaseItemType(oItem)==BASE_ITEM_TRAPKIT)&&(GetItemPossessor(oItem)==oPC))
    {
        //recovered a trap?
        string sMessageToPC=GetStringByStrRef(nZEPTrapFind,GENDER_MALE);
        SendMessageToPC(oPC,sMessageToPC+GetName(GetNearestTrapToObject(oPC)));
    }
}
