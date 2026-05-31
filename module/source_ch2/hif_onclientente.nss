#include "nwnx"
#include "nwnx_sql"
#include "sql_campaign"

void main()
{
    InitCampaignDB();
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS housing_properties (property_id INT AUTO_INCREMENT PRIMARY KEY, area_tag VARCHAR(64) NOT NULL UNIQUE, door_tag VARCHAR(64) NOT NULL DEFAULT '', owner_cdkey VARCHAR(64) NOT NULL DEFAULT '', owner_charname VARCHAR(128) NOT NULL DEFAULT '', price INT NOT NULL DEFAULT 0, rent_amount INT NOT NULL DEFAULT 0, locked TINYINT(1) NOT NULL DEFAULT 0, for_sale TINYINT(1) NOT NULL DEFAULT 1, last_paid DATETIME DEFAULT NULL, purchased_at DATETIME DEFAULT NULL, INDEX idx_owner (owner_cdkey))");
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS housing_guests (guest_id INT AUTO_INCREMENT PRIMARY KEY, property_id INT NOT NULL, guest_cdkey VARCHAR(64) NOT NULL, guest_charname VARCHAR(128) NOT NULL DEFAULT '', UNIQUE KEY uk_guest (property_id, guest_cdkey), FOREIGN KEY (property_id) REFERENCES housing_properties(property_id) ON DELETE CASCADE)");

    object oPC = GetEnteringObject();
    if(GetIsPC(oPC) && !GetIsDM(oPC))
    {
        string sCDKey = GetPCPublicCDKey(oPC);
        string sName = GetName(oPC);

        object oTarget = GetFirstPC();
        while (GetIsObjectValid(oTarget))
        {
            SendMessageToPC(oTarget, "*** " + sName + " has entered the world of HOPE ***");
            oTarget = GetNextPC();
        }

        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();
    }

    ExecuteScript("prc_onenter", OBJECT_SELF);
    ExecuteScript("x3_mod_def_enter", OBJECT_SELF);
    ExecuteScript("prc_addspells", OBJECT_SELF);
}
