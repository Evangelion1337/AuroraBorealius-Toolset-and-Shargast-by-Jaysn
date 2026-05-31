#include "nwnx"
#include "nwnx_sql"

const string CAMPAIGN_TABLE = "campaign_data";

void InitCampaignDB()
{
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS campaign_data (db_name VARCHAR(64) NOT NULL, var_name VARCHAR(255) NOT NULL, player_cdkey VARCHAR(64) NOT NULL DEFAULT '', int_val INT DEFAULT NULL, float_val FLOAT DEFAULT NULL, string_val TEXT DEFAULT NULL, area_resref VARCHAR(64) DEFAULT NULL, loc_x FLOAT DEFAULT NULL, loc_y FLOAT DEFAULT NULL, loc_z FLOAT DEFAULT NULL, loc_facing FLOAT DEFAULT NULL, updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (db_name, var_name, player_cdkey))");
}

string GetPlayerFilter(object oPlayer)
{
    if(GetIsObjectValid(oPlayer))
        return GetPCPublicCDKey(oPlayer);
    return "";
}

int SQL_GetCampaignInt(string sDB, string sVar, object oPlayer = OBJECT_INVALID)
{
    string sCDKey = GetPlayerFilter(oPlayer);
    NWNX_SQL_PrepareQuery("SELECT int_val FROM campaign_data WHERE db_name = ? AND var_name = ? AND player_cdkey = ?");
    NWNX_SQL_PreparedString(0, sDB);
    NWNX_SQL_PreparedString(1, sVar);
    NWNX_SQL_PreparedString(2, sCDKey);
    int nResult = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string sVal = NWNX_SQL_ReadDataInActiveRow(0);
        if(sVal != "")
            nResult = StringToInt(sVal);
    }
    NWNX_SQL_DestroyPreparedQuery();
    return nResult;
}

void SQL_SetCampaignInt(string sDB, string sVar, int nValue, object oPlayer = OBJECT_INVALID)
{
    string sCDKey = GetPlayerFilter(oPlayer);
    NWNX_SQL_PrepareQuery("INSERT INTO campaign_data (db_name, var_name, player_cdkey, int_val, updated_at) VALUES (?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE int_val = VALUES(int_val), updated_at = NOW()");
    NWNX_SQL_PreparedString(0, sDB);
    NWNX_SQL_PreparedString(1, sVar);
    NWNX_SQL_PreparedString(2, sCDKey);
    NWNX_SQL_PreparedInt(3, nValue);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

float SQL_GetCampaignFloat(string sDB, string sVar, object oPlayer = OBJECT_INVALID)
{
    string sCDKey = GetPlayerFilter(oPlayer);
    NWNX_SQL_PrepareQuery("SELECT float_val FROM campaign_data WHERE db_name = ? AND var_name = ? AND player_cdkey = ?");
    NWNX_SQL_PreparedString(0, sDB);
    NWNX_SQL_PreparedString(1, sVar);
    NWNX_SQL_PreparedString(2, sCDKey);
    float fResult = 0.0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string sVal = NWNX_SQL_ReadDataInActiveRow(0);
        if(sVal != "")
            fResult = StringToFloat(sVal);
    }
    NWNX_SQL_DestroyPreparedQuery();
    return fResult;
}

void SQL_SetCampaignFloat(string sDB, string sVar, float fValue, object oPlayer = OBJECT_INVALID)
{
    string sCDKey = GetPlayerFilter(oPlayer);
    NWNX_SQL_PrepareQuery("INSERT INTO campaign_data (db_name, var_name, player_cdkey, float_val, updated_at) VALUES (?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE float_val = VALUES(float_val), updated_at = NOW()");
    NWNX_SQL_PreparedString(0, sDB);
    NWNX_SQL_PreparedString(1, sVar);
    NWNX_SQL_PreparedString(2, sCDKey);
    NWNX_SQL_PreparedFloat(3, fValue);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

string SQL_GetCampaignString(string sDB, string sVar, object oPlayer = OBJECT_INVALID)
{
    string sCDKey = GetPlayerFilter(oPlayer);
    NWNX_SQL_PrepareQuery("SELECT string_val FROM campaign_data WHERE db_name = ? AND var_name = ? AND player_cdkey = ?");
    NWNX_SQL_PreparedString(0, sDB);
    NWNX_SQL_PreparedString(1, sVar);
    NWNX_SQL_PreparedString(2, sCDKey);
    string sResult = "";
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sResult = NWNX_SQL_ReadDataInActiveRow(0);
    }
    NWNX_SQL_DestroyPreparedQuery();
    return sResult;
}

void SQL_SetCampaignString(string sDB, string sVar, string sValue, object oPlayer = OBJECT_INVALID)
{
    string sCDKey = GetPlayerFilter(oPlayer);
    NWNX_SQL_PrepareQuery("INSERT INTO campaign_data (db_name, var_name, player_cdkey, string_val, updated_at) VALUES (?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE string_val = VALUES(string_val), updated_at = NOW()");
    NWNX_SQL_PreparedString(0, sDB);
    NWNX_SQL_PreparedString(1, sVar);
    NWNX_SQL_PreparedString(2, sCDKey);
    NWNX_SQL_PreparedString(3, sValue);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

location SQL_GetCampaignLocation(string sDB, string sVar, object oPlayer = OBJECT_INVALID)
{
    string sCDKey = GetPlayerFilter(oPlayer);
    NWNX_SQL_PrepareQuery("SELECT area_resref, loc_x, loc_y, loc_z, loc_facing FROM campaign_data WHERE db_name = ? AND var_name = ? AND player_cdkey = ?");
    NWNX_SQL_PreparedString(0, sDB);
    NWNX_SQL_PreparedString(1, sVar);
    NWNX_SQL_PreparedString(2, sCDKey);
    location locResult = LOCATION_INVALID;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string sArea = NWNX_SQL_ReadDataInActiveRow(0);
        float fX = StringToFloat(NWNX_SQL_ReadDataInActiveRow(1));
        float fY = StringToFloat(NWNX_SQL_ReadDataInActiveRow(2));
        float fZ = StringToFloat(NWNX_SQL_ReadDataInActiveRow(3));
        float fFacing = StringToFloat(NWNX_SQL_ReadDataInActiveRow(4));
        NWNX_SQL_DestroyPreparedQuery();
        if(sArea != "")
        {
            object oArea = GetObjectByTag(sArea);
            if(GetIsObjectValid(oArea))
                locResult = Location(oArea, Vector(fX, fY, fZ), fFacing);
        }
        return locResult;
    }
    NWNX_SQL_DestroyPreparedQuery();
    return LOCATION_INVALID;
}

void SQL_SetCampaignLocation(string sDB, string sVar, location loc, object oPlayer = OBJECT_INVALID)
{
    string sCDKey = GetPlayerFilter(oPlayer);
    object oArea = GetAreaFromLocation(loc);
    vector vPos = GetPositionFromLocation(loc);
    float fFacing = GetFacingFromLocation(loc);
    string sAreaTag = "";
    if(GetIsObjectValid(oArea))
        sAreaTag = GetTag(oArea);
    NWNX_SQL_PrepareQuery("INSERT INTO campaign_data (db_name, var_name, player_cdkey, area_resref, loc_x, loc_y, loc_z, loc_facing, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE area_resref = VALUES(area_resref), loc_x = VALUES(loc_x), loc_y = VALUES(loc_y), loc_z = VALUES(loc_z), loc_facing = VALUES(loc_facing), updated_at = NOW()");
    NWNX_SQL_PreparedString(0, sDB);
    NWNX_SQL_PreparedString(1, sVar);
    NWNX_SQL_PreparedString(2, sCDKey);
    NWNX_SQL_PreparedString(3, sAreaTag);
    NWNX_SQL_PreparedFloat(4, vPos.x);
    NWNX_SQL_PreparedFloat(5, vPos.y);
    NWNX_SQL_PreparedFloat(6, vPos.z);
    NWNX_SQL_PreparedFloat(7, fFacing);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

void SQL_DestroyCampaignDatabase(string sDB)
{
    NWNX_SQL_PrepareQuery("DELETE FROM campaign_data WHERE db_name = ?");
    NWNX_SQL_PreparedString(1, sDB);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}
