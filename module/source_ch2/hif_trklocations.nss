#include "nwnx"
#include "nwnx_sql"

void main()
{
    int nCount;
    object oPC;
    string sCDKey;
    string sChar;
    object oArea;
    string sAreaTag;
    string sAreaName;
    string sModule;
    string sServer;

    nCount = GetLocalInt(GetModule(), "HIF_LOC_TRACK_COUNT");
    nCount++;
    if (nCount < 5)
    {
        SetLocalInt(GetModule(), "HIF_LOC_TRACK_COUNT", nCount);
        return;
    }
    SetLocalInt(GetModule(), "HIF_LOC_TRACK_COUNT", 0);

    oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        sCDKey = GetPCPublicCDKey(oPC);
        sChar = GetName(oPC);
        oArea = GetArea(oPC);
        sAreaTag = GetTag(oArea);
        sAreaName = GetName(oArea);
        sModule = GetModuleName();

        sServer = "ch1";
        if (sModule == "HOPE_Shargast_CH2") sServer = "ch2";

        NWNX_SQL_PrepareQuery("INSERT INTO player_locations (cdkey, charname, area_tag, area_name, server_name, last_seen) VALUES (?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE area_tag=VALUES(area_tag), area_name=VALUES(area_name), server_name=VALUES(server_name), last_seen=NOW()");
        NWNX_SQL_PreparedString(1, sCDKey);
        NWNX_SQL_PreparedString(2, sChar);
        NWNX_SQL_PreparedString(3, sAreaTag);
        NWNX_SQL_PreparedString(4, sAreaName);
        NWNX_SQL_PreparedString(5, sServer);
        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();

        oPC = GetNextPC();
    }
}
