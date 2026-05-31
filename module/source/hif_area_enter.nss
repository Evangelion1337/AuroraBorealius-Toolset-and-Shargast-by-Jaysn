#include "nwnx"
#include "nwnx_sql"

void main()
{
    object oPC = GetEnteringObject();
    if (!GetIsPC(oPC) || GetIsDM(oPC)) return;

    string sCDKey = GetPCPublicCDKey(oPC);
    string sChar = GetName(oPC);
    object oArea = GetArea(oPC);
    string sAreaTag = GetTag(oArea);
    string sAreaName = GetName(oArea);
    string sModule = GetModuleName();

    string sServer = "ch1";
    if (sModule == "HOPE_Shargast_CH2") sServer = "ch2";

    NWNX_SQL_PrepareQuery("INSERT INTO player_locations (cdkey, charname, area_tag, area_name, server_name, last_seen) VALUES (?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE area_tag=VALUES(area_tag), area_name=VALUES(area_name), server_name=VALUES(server_name), last_seen=NOW()");
    NWNX_SQL_PreparedString(0, sCDKey);
    NWNX_SQL_PreparedString(1, sChar);
    NWNX_SQL_PreparedString(2, sAreaTag);
    NWNX_SQL_PreparedString(3, sAreaName);
    NWNX_SQL_PreparedString(4, sServer);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}
