//::///////////////////////////////////////////////
//:: Death healer action taken
//:: death_at_rcvry
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By:    Dauvis
//:: Created On:    6/27/03
//::
//:: This method sets the custom token for the conversation
//:: when the player asks for recover.
//:://////////////////////////////////////////////
#include "death_include"
#include "sql_campaign"

void main()
{
    object oPlayer = GetPCSpeaker();

    // get the gold cost
    int iGold = SQL_GetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iExpBuyBackCost", oPlayer);
    SetCustomToken(1000, IntToString(iGold));

    // get the recoverable exp
    int iExp = SQL_GetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iRecoverableExp", oPlayer);
    SetCustomToken(1001, IntToString(iExp));

    // remove the death flag for good measure
    SQL_SetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iDeathFlag", FALSE, oPlayer);
}


