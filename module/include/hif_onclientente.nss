#include "nwnx"
#include "nwnx_sql"
#include "sql_campaign"

void main()
{
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS char_backup (cdkey VARCHAR(64) NOT NULL DEFAULT '', charname VARCHAR(128) NOT NULL DEFAULT '', level INT NOT NULL DEFAULT 0, xp INT NOT NULL DEFAULT 0, last_login DATETIME DEFAULT NULL, last_logout DATETIME DEFAULT NULL, bic_data LONGBLOB DEFAULT NULL, PRIMARY KEY (cdkey, charname))");
    NWNX_SQL_ExecuteQuery("ALTER TABLE char_backup ADD COLUMN IF NOT EXISTS xp INT NOT NULL DEFAULT 0");
    NWNX_SQL_ExecuteQuery("ALTER TABLE char_backup ADD COLUMN IF NOT EXISTS bic_data LONGBLOB DEFAULT NULL AFTER last_logout");
    InitCampaignDB();
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS housing_properties (property_id INT AUTO_INCREMENT PRIMARY KEY, area_tag VARCHAR(64) NOT NULL UNIQUE, door_tag VARCHAR(64) NOT NULL DEFAULT '', owner_cdkey VARCHAR(64) NOT NULL DEFAULT '', owner_charname VARCHAR(128) NOT NULL DEFAULT '', price INT NOT NULL DEFAULT 0, rent_amount INT NOT NULL DEFAULT 0, locked TINYINT(1) NOT NULL DEFAULT 0, for_sale TINYINT(1) NOT NULL DEFAULT 1, last_paid DATETIME DEFAULT NULL, purchased_at DATETIME DEFAULT NULL, INDEX idx_owner (owner_cdkey))");
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS housing_guests (guest_id INT AUTO_INCREMENT PRIMARY KEY, property_id INT NOT NULL, guest_cdkey VARCHAR(64) NOT NULL, guest_charname VARCHAR(128) NOT NULL DEFAULT '', UNIQUE KEY uk_guest (property_id, guest_cdkey), FOREIGN KEY (property_id) REFERENCES housing_properties(property_id) ON DELETE CASCADE)");

    object oPC = GetEnteringObject();
    if(GetIsPC(oPC) && !GetIsDM(oPC))
    {
        ExecuteScript("abc_playersql", OBJECT_SELF);
        string sCDKey = GetPCPublicCDKey(oPC);
        string sName = GetName(oPC);
        int nLevel = GetHitDice(oPC);
        int nXP = GetXP(oPC);

        NWNX_SQL_PrepareQuery("INSERT INTO char_backup (cdkey,charname,level,xp,last_login,bic_data) VALUES (?,?,?,?,NOW(),?) ON DUPLICATE KEY UPDATE charname=VALUES(charname),level=VALUES(level),xp=VALUES(xp),last_login=NOW(),last_logout=NULL,bic_data=VALUES(bic_data)");
        NWNX_SQL_PreparedString(0, sCDKey);
        NWNX_SQL_PreparedString(1, sName);
        NWNX_SQL_PreparedInt(2, nLevel);
        NWNX_SQL_PreparedInt(3, nXP);
        NWNX_SQL_PreparedObjectFull(4, oPC);
        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();
    }

    ExecuteScript("prc_onenter", OBJECT_SELF);
    ExecuteScript("x3_mod_def_enter", OBJECT_SELF);
    ExecuteScript("prc_addspells", OBJECT_SELF);
}
