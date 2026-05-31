//::///////////////////////////////////////////////
//:: Scarface's Persistent Banking
//:: sfpb_balance
//:://////////////////////////////////////////////
/*
    Written By Scarface
*/
//////////////////////////////////////////////////

#include "sfpb_config"
#include "sql_campaign"
void main()
{
    // Vars
    object oPC = GetLastSpeaker();
    string sID = SF_GetPlayerID(oPC);
    int nBanked = SQL_GetCampaignInt(GetName(GetModule()), DATABASE_GOLD + sID);

    // Set custom token for the account balance
    SetCustomToken(1000, IntToString(nBanked));
}
