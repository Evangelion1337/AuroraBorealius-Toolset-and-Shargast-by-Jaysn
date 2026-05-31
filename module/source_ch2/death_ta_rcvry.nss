//::///////////////////////////////////////////////
//:: Conditional for healer
//:: death_ta_rcvry
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By:    Dauvis
//:: Created On:    6/27/03
//::
//:: This function determins if the player has any
//:: recoverable experience.
//:://////////////////////////////////////////////
#include "death_include"
#include "sql_campaign"

int StartingConditional()
{
    int iResult;
    object oPlayer = GetPCSpeaker();
    int iExp = SQL_GetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iRecoverableExp", oPlayer);

    iResult = (iExp > 0);
    return iResult;
}


