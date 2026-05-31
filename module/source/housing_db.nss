#include "nwnx"
#include "nwnx_sql"

const string HOUSE_TABLE = "housing_properties";
const string GUEST_TABLE = "housing_guests";

void InitHousingDB()
{
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS housing_properties (property_id INT AUTO_INCREMENT PRIMARY KEY, area_tag VARCHAR(64) NOT NULL UNIQUE, door_tag VARCHAR(64) NOT NULL DEFAULT '', owner_cdkey VARCHAR(64) NOT NULL DEFAULT '', owner_charname VARCHAR(128) NOT NULL DEFAULT '', price INT NOT NULL DEFAULT 0, interior_type VARCHAR(32) NOT NULL DEFAULT 'small', rent_amount INT NOT NULL DEFAULT 0, locked TINYINT(1) NOT NULL DEFAULT 0, for_sale TINYINT(1) NOT NULL DEFAULT 1, last_paid DATETIME DEFAULT NULL, purchased_at DATETIME DEFAULT NULL, INDEX idx_owner (owner_cdkey))");

    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS housing_guests (guest_id INT AUTO_INCREMENT PRIMARY KEY, property_id INT NOT NULL, guest_cdkey VARCHAR(64) NOT NULL, guest_charname VARCHAR(128) NOT NULL DEFAULT '', UNIQUE KEY uk_guest (property_id, guest_cdkey), FOREIGN KEY (property_id) REFERENCES housing_properties(property_id) ON DELETE CASCADE)");

    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS housing_requests (request_id INT AUTO_INCREMENT PRIMARY KEY, property_id INT NOT NULL, buyer_cdkey VARCHAR(64) NOT NULL, buyer_charname VARCHAR(128) NOT NULL DEFAULT '', price INT NOT NULL DEFAULT 0, status VARCHAR(16) NOT NULL DEFAULT 'pending', requested_at DATETIME DEFAULT CURRENT_TIMESTAMP, decided_at DATETIME DEFAULT NULL, INDEX idx_status (status), FOREIGN KEY (property_id) REFERENCES housing_properties(property_id) ON DELETE CASCADE)");

    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS housing_suggestions (suggestion_id INT AUTO_INCREMENT PRIMARY KEY, door_tag VARCHAR(64) NOT NULL, door_area_tag VARCHAR(64) NOT NULL, suggested_by_cdkey VARCHAR(64) NOT NULL, suggested_by_charname VARCHAR(128) NOT NULL DEFAULT '', suggested_price INT NOT NULL DEFAULT 0, status VARCHAR(16) NOT NULL DEFAULT 'pending', requested_at DATETIME DEFAULT CURRENT_TIMESTAMP, decided_at DATETIME DEFAULT NULL, INDEX idx_status (status))");
}

int GetPropertyIDByArea(string sAreaTag)
{
    NWNX_SQL_PrepareQuery("SELECT property_id FROM housing_properties WHERE area_tag = ?");
    NWNX_SQL_PreparedString(0, sAreaTag);
    int nID = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();
    return nID;
}

int GetPropertyIDByDoor(string sDoorTag)
{
    NWNX_SQL_PrepareQuery("SELECT property_id FROM housing_properties WHERE door_tag = ?");
    NWNX_SQL_PreparedString(1, sDoorTag);
    int nID = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();
    return nID;
}

int IsPropertyForSale(string sAreaTag)
{
    NWNX_SQL_PrepareQuery("SELECT for_sale FROM housing_properties WHERE area_tag = ?");
    NWNX_SQL_PreparedString(0, sAreaTag);
    int nSale = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nSale = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();
    return nSale;
}

int IsPropertyLocked(string sDoorTag)
{
    NWNX_SQL_PrepareQuery("SELECT locked FROM housing_properties WHERE door_tag = ?");
    NWNX_SQL_PreparedString(0, sDoorTag);
    int nLocked = 1;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nLocked = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();
    return nLocked;
}

int IsPlayerOwner(int nPropertyID, object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM housing_properties WHERE property_id = ? AND owner_cdkey = ?");
    NWNX_SQL_PreparedInt(0, nPropertyID);
    NWNX_SQL_PreparedString(1, sCDKey);
    int nCount = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nCount = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();
    return nCount > 0;
}

int IsPlayerGuest(int nPropertyID, object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM housing_guests WHERE property_id = ? AND guest_cdkey = ?");
    NWNX_SQL_PreparedInt(0, nPropertyID);
    NWNX_SQL_PreparedString(1, sCDKey);
    int nCount = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nCount = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();
    return nCount > 0;
}

int CanAccessProperty(int nPropertyID, object oPC)
{
    if(nPropertyID < 1) return 0;
    if(IsPlayerOwner(nPropertyID, oPC)) return 1;
    if(IsPlayerGuest(nPropertyID, oPC)) return 1;
    return 0;
}

int BuyProperty(string sAreaTag, object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    if(sCDKey == "") return 0;

    NWNX_SQL_PrepareQuery("SELECT price FROM housing_properties WHERE area_tag = ? AND for_sale = 1");
    NWNX_SQL_PreparedString(0, sAreaTag);
    int nPrice = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nPrice = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();

    if(nPrice < 1) return -1;

    if(GetGold(oPC) < nPrice) return -2;

    TakeGoldFromCreature(nPrice, oPC);

    NWNX_SQL_PrepareQuery("UPDATE housing_properties SET owner_cdkey = ?, owner_charname = ?, for_sale = 0, locked = 0, purchased_at = NOW() WHERE area_tag = ? AND for_sale = 1");
    NWNX_SQL_PreparedString(0, sCDKey);
    NWNX_SQL_PreparedString(1, GetName(oPC));
    NWNX_SQL_PreparedString(2, sAreaTag);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    return 1;
}

int SellProperty(string sAreaTag, object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    if(sCDKey == "") return 0;

    int nPropID = GetPropertyIDByArea(sAreaTag);
    if(nPropID < 1) return -1;
    if(!IsPlayerOwner(nPropID, oPC)) return -2;

    NWNX_SQL_PrepareQuery("SELECT price FROM housing_properties WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    int nPrice = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nPrice = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();

    int nRefund = nPrice / 2;
    GiveGoldToCreature(oPC, nRefund);

    NWNX_SQL_PrepareQuery("UPDATE housing_properties SET owner_cdkey = '', owner_charname = '', for_sale = 1, locked = 1 WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    NWNX_SQL_PrepareQuery("DELETE FROM housing_guests WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    return nRefund;
}

void SetPropertyLock(int nPropertyID, int nLocked)
{
    NWNX_SQL_PrepareQuery("UPDATE housing_properties SET locked = ? WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nLocked);
    NWNX_SQL_PreparedInt(1, nPropertyID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

void AddGuest(int nPropertyID, string sGuestCDKey, string sGuestName)
{
    NWNX_SQL_PrepareQuery("INSERT IGNORE INTO housing_guests (property_id, guest_cdkey, guest_charname) VALUES (?, ?, ?)");
    NWNX_SQL_PreparedInt(0, nPropertyID);
    NWNX_SQL_PreparedString(1, sGuestCDKey);
    NWNX_SQL_PreparedString(2, sGuestName);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

void RemoveGuest(int nPropertyID, string sGuestCDKey)
{
    NWNX_SQL_PrepareQuery("DELETE FROM housing_guests WHERE property_id = ? AND guest_cdkey = ?");
    NWNX_SQL_PreparedInt(0, nPropertyID);
    NWNX_SQL_PreparedString(1, sGuestCDKey);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

string GetPropertyOwnerName(int nPropertyID)
{
    NWNX_SQL_PrepareQuery("SELECT owner_charname FROM housing_properties WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropertyID);
    string sName = "";
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sName = NWNX_SQL_ReadDataInActiveRow(0);
    }
    NWNX_SQL_DestroyPreparedQuery();
    return sName;
}

int GetPropertyPrice(int nPropertyID)
{
    NWNX_SQL_PrepareQuery("SELECT price FROM housing_properties WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropertyID);
    int nPrice = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nPrice = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();
    return nPrice;
}

string GetDoorTagForArea(string sAreaTag)
{
    NWNX_SQL_PrepareQuery("SELECT door_tag FROM housing_properties WHERE area_tag = ?");
    NWNX_SQL_PreparedString(0, sAreaTag);
    string sTag = "";
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sTag = NWNX_SQL_ReadDataInActiveRow(0);
    }
    NWNX_SQL_DestroyPreparedQuery();
    return sTag;
}

int RegisterProperty(string sAreaTag, string sDoorTag, int nPrice, string sInterior)
{
    if(sAreaTag == "") return 0;
    if(sInterior == "") sInterior = "small";
    NWNX_SQL_PrepareQuery("INSERT INTO housing_properties (area_tag, door_tag, price, interior_type) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE door_tag=VALUES(door_tag), price=VALUES(price), interior_type=VALUES(interior_type)");
    NWNX_SQL_PreparedString(0, sAreaTag);
    NWNX_SQL_PreparedString(1, sDoorTag);
    NWNX_SQL_PreparedInt(2, nPrice);
    NWNX_SQL_PreparedString(3, sInterior);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
    return 1;
}

int RemoveProperty(string sAreaTag)
{
    if(sAreaTag == "") return 0;
    NWNX_SQL_PrepareQuery("DELETE FROM housing_guests WHERE property_id = (SELECT property_id FROM housing_properties WHERE area_tag = ?)");
    NWNX_SQL_PreparedString(0, sAreaTag);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
    NWNX_SQL_PrepareQuery("DELETE FROM housing_properties WHERE area_tag = ?");
    NWNX_SQL_PreparedString(1, sAreaTag);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
    return 1;
}

int IsDoorRegistered(string sDoorTag)
{
    if(sDoorTag == "") return 0;
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM housing_properties WHERE door_tag = ?");
    NWNX_SQL_PreparedString(0, sDoorTag);
    int nC = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();
    return nC > 0;
}

int CreateHousingSuggestion(string sDoorTag, string sAreaTag, string sCDKey, string sName, int nPrice)
{
    if(sDoorTag == "" || sCDKey == "") return 0;
    if(IsDoorRegistered(sDoorTag)) return -1;
    NWNX_SQL_PrepareQuery("INSERT INTO housing_suggestions (door_tag, door_area_tag, suggested_by_cdkey, suggested_by_charname, suggested_price, status, requested_at) VALUES (?, ?, ?, ?, ?, 'pending', NOW())");
    NWNX_SQL_PreparedString(0, sDoorTag);
    NWNX_SQL_PreparedString(1, sAreaTag);
    NWNX_SQL_PreparedString(2, sCDKey);
    NWNX_SQL_PreparedString(3, sName);
    NWNX_SQL_PreparedInt(4, nPrice);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
    return 1;
}

int GetPendingSuggestionCount()
{
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM housing_suggestions WHERE status = 'pending'");
    int nC = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();
    return nC;
}

int ApproveHousingSuggestion(int nSuggID)
{
    NWNX_SQL_PrepareQuery("SELECT door_tag, door_area_tag, suggested_price, suggested_by_cdkey, suggested_by_charname FROM housing_suggestions WHERE suggestion_id = ? AND status = 'pending'");
    NWNX_SQL_PreparedInt(0, nSuggID);
    string sDoor = ""; string sArea = ""; int nPrice = 0; string sCDKey = ""; string sName = "";
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); sDoor = NWNX_SQL_ReadDataInActiveRow(0); sArea = NWNX_SQL_ReadDataInActiveRow(1); nPrice = StringToInt(NWNX_SQL_ReadDataInActiveRow(2)); sCDKey = NWNX_SQL_ReadDataInActiveRow(3); sName = NWNX_SQL_ReadDataInActiveRow(4); }
    NWNX_SQL_DestroyPreparedQuery();
    if(sDoor == "") return 0;

    if(IsDoorRegistered(sDoor)) return -1;

    if(!RegisterProperty(sArea, sDoor, nPrice, "small")) return 0;

    NWNX_SQL_PrepareQuery("UPDATE housing_suggestions SET status = 'approved', decided_at = NOW() WHERE suggestion_id = ?");
    NWNX_SQL_PreparedInt(0, nSuggID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    object oSuggester = GetFirstPC();
    while(GetIsObjectValid(oSuggester))
    {
        if(GetPCPublicCDKey(oSuggester) == sCDKey)
        { SendMessageToPC(oSuggester, "Your property suggestion was approved! Property registered at " + sArea + " for " + IntToString(nPrice) + "g."); break; }
        oSuggester = GetNextPC();
    }
    return 1;
}

int DenyHousingSuggestion(int nSuggID)
{
    NWNX_SQL_PrepareQuery("SELECT suggested_by_cdkey FROM housing_suggestions WHERE suggestion_id = ? AND status = 'pending'");
    NWNX_SQL_PreparedInt(0, nSuggID);
    string sCDKey = "";
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); sCDKey = NWNX_SQL_ReadDataInActiveRow(0); }
    NWNX_SQL_DestroyPreparedQuery();
    if(sCDKey == "") return 0;

    NWNX_SQL_PrepareQuery("UPDATE housing_suggestions SET status = 'denied', decided_at = NOW() WHERE suggestion_id = ?");
    NWNX_SQL_PreparedInt(0, nSuggID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    object oSuggester = GetFirstPC();
    while(GetIsObjectValid(oSuggester))
    {
        if(GetPCPublicCDKey(oSuggester) == sCDKey)
        { SendMessageToPC(oSuggester, "Your property suggestion was denied."); break; }
        oSuggester = GetNextPC();
    }
    return 1;
}

int CreateHousingRequest(int nPropID, string sBuyerCDKey, string sBuyerName)
{
    NWNX_SQL_PrepareQuery("SELECT price FROM housing_properties WHERE property_id = ? AND for_sale = 1");
    NWNX_SQL_PreparedInt(0, nPropID);
    int nPrice = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nPrice = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();
    if(nPrice < 1) return 0;

    NWNX_SQL_PrepareQuery("INSERT INTO housing_requests (property_id, buyer_cdkey, buyer_charname, price, status, requested_at) VALUES (?, ?, ?, ?, 'pending', NOW())");
    NWNX_SQL_PreparedInt(0, nPropID);
    NWNX_SQL_PreparedString(1, sBuyerCDKey);
    NWNX_SQL_PreparedString(2, sBuyerName);
    NWNX_SQL_PreparedInt(3, nPrice);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
    return 1;
}

int ApproveHousingRequest(int nReqID)
{
    NWNX_SQL_PrepareQuery("SELECT property_id, buyer_cdkey, price FROM housing_requests WHERE request_id = ? AND status = 'pending'");
    NWNX_SQL_PreparedInt(0, nReqID);
    int nPropID = 0;
    string sBuyer = "";
    int nPrice = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nPropID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); sBuyer = NWNX_SQL_ReadDataInActiveRow(1); nPrice = StringToInt(NWNX_SQL_ReadDataInActiveRow(2)); }
    NWNX_SQL_DestroyPreparedQuery();
    if(nPropID < 1) return 0;

    object oBuyer = GetFirstPC();
    int nFound = 0;
    while(GetIsObjectValid(oBuyer))
    {
        if(GetPCPublicCDKey(oBuyer) == sBuyer) { nFound = 1; break; }
        oBuyer = GetNextPC();
    }

    if(nFound && GetGold(oBuyer) < nPrice) return -1;

    if(nFound) TakeGoldFromCreature(nPrice, oBuyer);

    NWNX_SQL_PrepareQuery("UPDATE housing_properties SET owner_cdkey = ?, owner_charname = (SELECT buyer_charname FROM housing_requests WHERE request_id = ?), for_sale = 0, locked = 0, purchased_at = NOW() WHERE property_id = ?");
    NWNX_SQL_PreparedString(0, sBuyer);
    NWNX_SQL_PreparedInt(1, nReqID);
    NWNX_SQL_PreparedInt(2, nPropID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    NWNX_SQL_PrepareQuery("UPDATE housing_requests SET status = 'approved', decided_at = NOW() WHERE request_id = ?");
    NWNX_SQL_PreparedInt(0, nReqID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    if(nFound) SendMessageToPC(oBuyer, "Your housing request was approved! You now own the property.");
    return 1;
}

int DenyHousingRequest(int nReqID)
{
    NWNX_SQL_PrepareQuery("SELECT buyer_cdkey FROM housing_requests WHERE request_id = ? AND status = 'pending'");
    NWNX_SQL_PreparedInt(0, nReqID);
    string sBuyer = "";
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); sBuyer = NWNX_SQL_ReadDataInActiveRow(0); }
    NWNX_SQL_DestroyPreparedQuery();
    if(sBuyer == "") return 0;

    NWNX_SQL_PrepareQuery("UPDATE housing_requests SET status = 'denied', decided_at = NOW() WHERE request_id = ?");
    NWNX_SQL_PreparedInt(0, nReqID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    object oBuyer = GetFirstPC();
    while(GetIsObjectValid(oBuyer))
    {
        if(GetPCPublicCDKey(oBuyer) == sBuyer)
        { SendMessageToPC(oBuyer, "Your housing request was denied."); break; }
        oBuyer = GetNextPC();
    }
    return 1;
}
