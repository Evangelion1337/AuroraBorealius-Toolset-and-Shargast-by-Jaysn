#include "zdlg_include_i"
#include "nwnx"
#include "nwnx_sql"
#include "housing_db"

const string PAGE_MENU = "menu";
const string PAGE_BROWSE = "browse";
const string PAGE_PROP = "prop";
const string PAGE_MINE = "mine";
const string PAGE_MYPROP = "myprop";
const string PAGE_ADMIN = "admin";
const string PAGE_REQDETAIL = "reqdetail";
const string PAGE_REGDETAIL = "regdetail";

const string HS_AWAIT = "ZEP_HS_AWAIT";
const string HS_DOOR_TAG = "ZEP_HS_DOOR";
const string HS_PRICE = "ZEP_HS_PRICE";
const string HS_PAGE = "ZEP_HS_PAGE";

void DelList(string sL, object o)
{
    DeleteList(sL, o);
}

int GetForSaleCount()
{
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM housing_properties WHERE for_sale = 1");
    int nC = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();
    return nC;
}

int GetMyPropCount(string sCDKey)
{
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM housing_properties WHERE owner_cdkey = ?");
    NWNX_SQL_PreparedString(0, sCDKey);
    int nC = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();
    return nC;
}

int GetPendingReqCount()
{
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM housing_requests WHERE status = 'pending'");
    int nC = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();
    return nC;
}

void ShowMenu(object oPC)
{
    string sCK = GetPCPublicCDKey(oPC);
    int nSale = GetForSaleCount();
    int nMine = GetMyPropCount(sCK);
    int nDM = GetIsDM(oPC);
    int nPending = GetPendingReqCount();
    int nSugg = GetPendingSuggestionCount();
    string sP = "Housing Board\n";
    sP += IntToString(nSale) + " properties for sale\n";

    DelList("hs_mnu", oPC);
    if(nSale > 0) AddStringElement("Browse Properties (" + IntToString(nSale) + ")", "hs_mnu", oPC);
    else AddStringElement("Browse Properties (none)", "hs_mnu", oPC);
    if(nMine > 0) AddStringElement("My Properties (" + IntToString(nMine) + ")", "hs_mnu", oPC);
    else AddStringElement("My Properties (none)", "hs_mnu", oPC);
    AddStringElement("Suggest a Property", "hs_mnu", oPC);
    if(nDM > 0)
    {
        string sAdminLbl = "Admin Panel";
        if(nPending > 0 || nSugg > 0) sAdminLbl += " (" + IntToString(nPending) + " req, " + IntToString(nSugg) + " sugg)";
        else sAdminLbl += " (none)";
        AddStringElement(sAdminLbl, "hs_mnu", oPC);
    }
    AddStringElement("Exit", "hs_mnu", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("hs_mnu", oPC);
    SetDlgPageString(PAGE_MENU);
}

void ShowBrowse(object oPC)
{
    DelList("hs_br", oPC);
    DelList("hs_br_ids", oPC);

    NWNX_SQL_PrepareQuery("SELECT property_id, area_tag, door_tag, price, interior_type FROM housing_properties WHERE for_sale = 1 ORDER BY price ASC");
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            string sA = NWNX_SQL_ReadDataInActiveRow(1);
            string sD = NWNX_SQL_ReadDataInActiveRow(2);
            int nP = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
            string sI = NWNX_SQL_ReadDataInActiveRow(4);
            if(sI == "") sI = "small";
            string sL = sA + " - " + sI + " - " + IntToString(nP) + "g";
            if(sD != "") sL += " [Door: " + sD + "]";
            AddStringElement(sL, "hs_br", oPC);
            AddIntElement(nID, "hs_br_ids", oPC);
        }
    }
    NWNX_SQL_DestroyPreparedQuery();

    AddStringElement("Back to Menu", "hs_br", oPC);
    AddIntElement(-1, "hs_br_ids", oPC);

    SetDlgPrompt("Available Properties:");
    SetDlgResponseList("hs_br", oPC);
    SetDlgPageString(PAGE_BROWSE);
}

void ShowPropDetail(object oPC, int nPropID)
{
    DelList("hs_pd", oPC);
    DelList("hs_pd_ids", oPC);

    string sP = "";
    NWNX_SQL_PrepareQuery("SELECT area_tag, door_tag, price, interior_type, owner_charname, for_sale FROM housing_properties WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string sA = NWNX_SQL_ReadDataInActiveRow(0);
        string sD = NWNX_SQL_ReadDataInActiveRow(1);
        int nP = StringToInt(NWNX_SQL_ReadDataInActiveRow(2));
        string sI = NWNX_SQL_ReadDataInActiveRow(3);
        string sO = NWNX_SQL_ReadDataInActiveRow(4);
        int nFS = StringToInt(NWNX_SQL_ReadDataInActiveRow(5));
        sP = "Property: " + sA + "\n";
        sP += "Interior: " + sI + "\n";
        if(sD != "") sP += "Door: " + sD + "\n";
        if(nFS > 0) sP += "Price: " + IntToString(nP) + "g\nFor Sale: Yes\n";
        else sP += "Owner: " + sO + "\nFor Sale: No\n";
    }
    NWNX_SQL_DestroyPreparedQuery();

    NWNX_SQL_PrepareQuery("SELECT for_sale FROM housing_properties WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    int nFS = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nFS = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();

    if(nFS > 0)
    {
        AddStringElement("Request to Buy", "hs_pd", oPC);
        AddIntElement(0, "hs_pd_ids", oPC);
    }
    AddStringElement("Back to List", "hs_pd", oPC);
    AddIntElement(-1, "hs_pd_ids", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("hs_pd", oPC);
    SetDlgPageInt(nPropID);
    SetDlgPageString(PAGE_PROP);
}

void ShowMine(object oPC)
{
    string sCK = GetPCPublicCDKey(oPC);
    DelList("hs_mn", oPC);
    DelList("hs_mn_ids", oPC);

    NWNX_SQL_PrepareQuery("SELECT property_id, area_tag, interior_type, locked FROM housing_properties WHERE owner_cdkey = ?");
    NWNX_SQL_PreparedString(0, sCK);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            string sA = NWNX_SQL_ReadDataInActiveRow(1);
            string sI = NWNX_SQL_ReadDataInActiveRow(2);
            int nL = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
            string sL = sA + " (" + sI + ")";
            if(nL > 0) sL += " [Locked]";
            else sL += " [Unlocked]";
            AddStringElement(sL, "hs_mn", oPC);
            AddIntElement(nID, "hs_mn_ids", oPC);
        }
    }
    NWNX_SQL_DestroyPreparedQuery();

    AddStringElement("Back to Menu", "hs_mn", oPC);
    AddIntElement(-1, "hs_mn_ids", oPC);

    SetDlgPrompt("Your Properties:");
    SetDlgResponseList("hs_mn", oPC);
    SetDlgPageString(PAGE_MINE);
}

void ShowMyProp(object oPC, int nPropID)
{
    DelList("hs_mp", oPC);
    DelList("hs_mp_ids", oPC);

    string sCK = GetPCPublicCDKey(oPC);
    string sP = "";
    NWNX_SQL_PrepareQuery("SELECT area_tag, door_tag, interior_type, locked, price FROM housing_properties WHERE property_id = ? AND owner_cdkey = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    NWNX_SQL_PreparedString(1, sCK);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sP = "Your Property\n";
        sP += "Area: " + NWNX_SQL_ReadDataInActiveRow(0) + "\n";
        sP += "Interior: " + NWNX_SQL_ReadDataInActiveRow(2) + "\n";
        if(NWNX_SQL_ReadDataInActiveRow(1) != "") sP += "Door: " + NWNX_SQL_ReadDataInActiveRow(1) + "\n";
        int nL = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
        int nP = StringToInt(NWNX_SQL_ReadDataInActiveRow(4));
        sP += "Status: ";
        if(nL > 0) sP += "Locked\n";
        else sP += "Unlocked\n";
        sP += "Value: " + IntToString(nP) + "g (sell for " + IntToString(nP/2) + "g)";
    }
    NWNX_SQL_DestroyPreparedQuery();

    AddStringElement("Toggle Lock/Unlock", "hs_mp", oPC);
    AddIntElement(0, "hs_mp_ids", oPC);
    AddStringElement("Sell Property", "hs_mp", oPC);
    AddIntElement(1, "hs_mp_ids", oPC);
    AddStringElement("Back to List", "hs_mp", oPC);
    AddIntElement(-1, "hs_mp_ids", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("hs_mp", oPC);
    SetDlgPageInt(nPropID);
    SetDlgPageString(PAGE_MYPROP);
}

void DoRequestBuy(object oPC, int nPropID)
{
    string sCK = GetPCPublicCDKey(oPC);
    NWNX_SQL_PrepareQuery("SELECT price, for_sale FROM housing_properties WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    int nPrice = 0;
    int nFS = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nPrice = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); nFS = StringToInt(NWNX_SQL_ReadDataInActiveRow(1)); }
    NWNX_SQL_DestroyPreparedQuery();

    if(nFS < 1) { SendMessageToPC(oPC, "Not for sale."); return; }
    if(GetGold(oPC) < nPrice) { SendMessageToPC(oPC, "Need " + IntToString(nPrice) + "g, you have " + IntToString(GetGold(oPC)) + "g."); return; }

    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM housing_requests WHERE property_id = ? AND buyer_cdkey = ? AND status = 'pending'");
    NWNX_SQL_PreparedInt(0, nPropID);
    NWNX_SQL_PreparedString(1, sCK);
    int nExisting = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nExisting = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();
    if(nExisting > 0) { SendMessageToPC(oPC, "You already have a pending request for this property."); return; }

    if(!CreateHousingRequest(nPropID, sCK, GetName(oPC)))
    { SendMessageToPC(oPC, "Failed to create request."); return; }

    SendMessageToPC(oPC, "Purchase request submitted! An admin will review it.");
}

void ShowAdminPanel(object oPC)
{
    DelList("hs_ad", oPC);
    DelList("hs_ad_ids", oPC);

    int nReqCount = GetPendingReqCount();
    int nSuggCount = GetPendingSuggestionCount();

    if(nReqCount > 0) AddStringElement("Purchase Requests (" + IntToString(nReqCount) + ")", "hs_ad", oPC);
    else AddStringElement("Purchase Requests (none)", "hs_ad", oPC);
    AddIntElement(0, "hs_ad_ids", oPC);

    if(nSuggCount > 0) AddStringElement("Property Suggestions (" + IntToString(nSuggCount) + ")", "hs_ad", oPC);
    else AddStringElement("Property Suggestions (none)", "hs_ad", oPC);
    AddIntElement(1, "hs_ad_ids", oPC);

    AddStringElement("Register New Property", "hs_ad", oPC);
    AddIntElement(2, "hs_ad_ids", oPC);
    AddStringElement("Back to Menu", "hs_ad", oPC);
    AddIntElement(-1, "hs_ad_ids", oPC);

    SetDlgPrompt("Admin Panel - Select an option:");
    SetDlgResponseList("hs_ad", oPC);
    SetDlgPageString(PAGE_ADMIN);
}

void ShowRequestList(object oPC)
{
    DelList("hs_rl", oPC);
    DelList("hs_rl_ids", oPC);

    NWNX_SQL_PrepareQuery("SELECT r.request_id, r.buyer_charname, p.area_tag, r.price, r.requested_at FROM housing_requests r JOIN housing_properties p ON r.property_id = p.property_id WHERE r.status = 'pending' ORDER BY r.requested_at ASC");
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nRID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            string sB = NWNX_SQL_ReadDataInActiveRow(1);
            string sA = NWNX_SQL_ReadDataInActiveRow(2);
            int nP = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
            string sT = NWNX_SQL_ReadDataInActiveRow(4);
            string sL = sB + " wants " + sA + " (" + IntToString(nP) + "g)";
            AddStringElement(sL, "hs_rl", oPC);
            AddIntElement(nRID, "hs_rl_ids", oPC);
        }
    }
    NWNX_SQL_DestroyPreparedQuery();

    AddStringElement("Back to Admin Panel", "hs_rl", oPC);
    AddIntElement(-1, "hs_rl_ids", oPC);

    SetDlgPrompt("Pending Purchase Requests:");
    SetDlgResponseList("hs_rl", oPC);
    SetDlgPageString("reqlist");
}

void ShowSuggestionList(object oPC)
{
    DelList("hs_sl", oPC);
    DelList("hs_sl_ids", oPC);

    NWNX_SQL_PrepareQuery("SELECT suggestion_id, suggested_by_charname, door_tag, suggested_price FROM housing_suggestions WHERE status = 'pending' ORDER BY requested_at ASC");
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nSID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            string sB = NWNX_SQL_ReadDataInActiveRow(1);
            string sD = NWNX_SQL_ReadDataInActiveRow(2);
            int nP = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
            string sL = sB + " wants door '" + sD + "' (" + IntToString(nP) + "g)";
            AddStringElement(sL, "hs_sl", oPC);
            AddIntElement(nSID, "hs_sl_ids", oPC);
        }
    }
    NWNX_SQL_DestroyPreparedQuery();

    AddStringElement("Back to Admin Panel", "hs_sl", oPC);
    AddIntElement(-1, "hs_sl_ids", oPC);

    SetDlgPrompt("Pending Property Suggestions:");
    SetDlgResponseList("hs_sl", oPC);
    SetDlgPageString("sugglist");
}

void ShowReqDetail(object oPC, int nReqID)
{
    DelList("hs_rd", oPC);
    DelList("hs_rd_ids", oPC);

    string sP = "";
    NWNX_SQL_PrepareQuery("SELECT r.buyer_charname, r.buyer_cdkey, p.area_tag, r.price, r.requested_at FROM housing_requests r JOIN housing_properties p ON r.property_id = p.property_id WHERE r.request_id = ?");
    NWNX_SQL_PreparedInt(0, nReqID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sP = "Purchase Request\n";
        sP += "Buyer: " + NWNX_SQL_ReadDataInActiveRow(0) + "\n";
        sP += "Property: " + NWNX_SQL_ReadDataInActiveRow(2) + "\n";
        sP += "Price: " + NWNX_SQL_ReadDataInActiveRow(3) + "g\n";
        sP += "Requested: " + NWNX_SQL_ReadDataInActiveRow(4);
    }
    NWNX_SQL_DestroyPreparedQuery();

    AddStringElement("Approve", "hs_rd", oPC);
    AddIntElement(0, "hs_rd_ids", oPC);
    AddStringElement("Deny", "hs_rd", oPC);
    AddIntElement(1, "hs_rd_ids", oPC);
    AddStringElement("Back to List", "hs_rd", oPC);
    AddIntElement(-1, "hs_rd_ids", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("hs_rd", oPC);
    SetDlgPageInt(nReqID);
    SetDlgPageString(PAGE_REQDETAIL);
}

void ShowRegDetail(object oPC, string sDoorTag, int nPrice)
{
    DelList("hs_ri", oPC);
    DelList("hs_ri_ids", oPC);

    string sP = "Register New Property\n";
    sP += "Door: " + sDoorTag + "\n";
    sP += "Price: " + IntToString(nPrice) + "g\n";
    sP += "Select interior type:";

    AddStringElement("Small", "hs_ri", oPC);
    AddIntElement(0, "hs_ri_ids", oPC);
    AddStringElement("Medium", "hs_ri", oPC);
    AddIntElement(1, "hs_ri_ids", oPC);
    AddStringElement("Large", "hs_ri", oPC);
    AddIntElement(2, "hs_ri_ids", oPC);
    AddStringElement("Mansion", "hs_ri", oPC);
    AddIntElement(3, "hs_ri_ids", oPC);
    AddStringElement("Cancel", "hs_ri", oPC);
    AddIntElement(-1, "hs_ri_ids", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("hs_ri", oPC);
    SetDlgPageInt(nPrice);
    SetDlgPageString(PAGE_REGDETAIL);
    SetLocalString(oPC, HS_DOOR_TAG, sDoorTag);
}

void ShowRegStart(object oPC)
{
    string sDTag = GetLocalString(oPC, HS_DOOR_TAG);
    int nPrice = GetLocalInt(oPC, HS_PRICE);

    if(sDTag == "" || nPrice < 1)
    {
        string sAwait = GetLocalString(oPC, HS_AWAIT);
        if(sAwait == "")
            SetLocalString(oPC, HS_AWAIT, "door tag");
        DelList("hs_rs", oPC);
        DelList("hs_rs_ids", oPC);
        AddStringElement("OK", "hs_rs", oPC);
        AddIntElement(0, "hs_rs_ids", oPC);
        SetDlgPrompt("Registration - Step 1\n\nType the door tag in chat.\nExample: my_front_door\n\nAfter setting the door tag, type the sale price.\nThen use this board again to select interior.\n\nUse /hs cancel to abort.");
        SetDlgResponseList("hs_rs", oPC);
        SetDlgPageString("regwait");
    }
    else
    {
        ShowRegDetail(oPC, sDTag, nPrice);
    }
}

void DoRegisterNewProp(object oPC, int nPrice, string sInterior)
{
    string sDoorTag = GetLocalString(oPC, HS_DOOR_TAG);
    if(sDoorTag == "" || nPrice < 1) { SendMessageToPC(oPC, "Registration failed: missing data."); return; }

    string sAreaTag = GetTag(GetArea(oPC));
    if(!RegisterProperty(sAreaTag, sDoorTag, nPrice, sInterior))
    { SendMessageToPC(oPC, "Failed to register property."); return; }

    SendMessageToPC(oPC, "Property registered! Area: " + sAreaTag + " Door: " + sDoorTag + " Price: " + IntToString(nPrice) + "g Interior: " + sInterior);

    DeleteLocalString(oPC, HS_DOOR_TAG);
    DeleteLocalInt(oPC, HS_PRICE);
    DeleteLocalString(oPC, HS_AWAIT);
    DeleteLocalString(oPC, HS_PAGE);
}

void ShowSuggestStart(object oPC)
{
    DelList("hs_ss", oPC);
    DelList("hs_ss_ids", oPC);
    AddStringElement("OK", "hs_ss", oPC);
    AddIntElement(0, "hs_ss_ids", oPC);
    SetLocalString(oPC, HS_AWAIT, "door tag");
    SetLocalString(oPC, HS_PAGE, "suggest");
    SetDlgPrompt("Suggest a Property\n\nFind a door in the world, examine it to learn its tag, then type the tag in chat.\n\nAfter that, type your suggested price.\n\nAn admin will review your suggestion.\n\nUse /hs cancel to abort.");
    SetDlgResponseList("hs_ss", oPC);
    SetDlgPageString("suggwait");
}

void ShowSuggDetail(object oPC, int nSuggID)
{
    DelList("hs_sd", oPC);
    DelList("hs_sd_ids", oPC);

    string sP = "";
    NWNX_SQL_PrepareQuery("SELECT s.suggested_by_charname, s.door_tag, s.door_area_tag, s.suggested_price, s.requested_at FROM housing_suggestions s WHERE s.suggestion_id = ?");
    NWNX_SQL_PreparedInt(0, nSuggID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sP = "Property Suggestion\n";
        sP += "By: " + NWNX_SQL_ReadDataInActiveRow(0) + "\n";
        sP += "Door: " + NWNX_SQL_ReadDataInActiveRow(1) + "\n";
        sP += "Area: " + NWNX_SQL_ReadDataInActiveRow(2) + "\n";
        sP += "Price: " + NWNX_SQL_ReadDataInActiveRow(3) + "g\n";
        sP += "Date: " + NWNX_SQL_ReadDataInActiveRow(4);
    }
    NWNX_SQL_DestroyPreparedQuery();

    AddStringElement("Approve", "hs_sd", oPC);
    AddIntElement(0, "hs_sd_ids", oPC);
    AddStringElement("Deny", "hs_sd", oPC);
    AddIntElement(1, "hs_sd_ids", oPC);
    AddStringElement("Back to List", "hs_sd", oPC);
    AddIntElement(-1, "hs_sd_ids", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("hs_sd", oPC);
    SetDlgPageInt(nSuggID);
    SetDlgPageString("suggdetail");
}

void DoLockToggle(object oPC, int nPropID)
{
    string sCK = GetPCPublicCDKey(oPC);
    NWNX_SQL_PrepareQuery("SELECT locked FROM housing_properties WHERE property_id = ? AND owner_cdkey = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    NWNX_SQL_PreparedString(1, sCK);
    int nL = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nL = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();

    int nNew = nL > 0 ? 0 : 1;
    NWNX_SQL_PrepareQuery("UPDATE housing_properties SET locked = ? WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nNew);
    NWNX_SQL_PreparedInt(1, nPropID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    NWNX_SQL_PrepareQuery("SELECT door_tag FROM housing_properties WHERE property_id = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    string sDoor = "";
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); sDoor = NWNX_SQL_ReadDataInActiveRow(0); }
    NWNX_SQL_DestroyPreparedQuery();

    if(sDoor != "")
    {
        object oDoor = GetNearestObjectByTag(sDoor, oPC);
        if(GetIsObjectValid(oDoor)) SetLocked(oDoor, nNew > 0);
    }

    if(nNew > 0) SendMessageToPC(oPC, "Property locked.");
    else SendMessageToPC(oPC, "Property unlocked.");
}

void DoSellProp(object oPC, int nPropID)
{
    string sCK = GetPCPublicCDKey(oPC);
    NWNX_SQL_PrepareQuery("SELECT price FROM housing_properties WHERE property_id = ? AND owner_cdkey = ?");
    NWNX_SQL_PreparedInt(0, nPropID);
    NWNX_SQL_PreparedString(1, sCK);
    int nPrice = 0;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nPrice = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
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

    SendMessageToPC(oPC, "Sold for " + IntToString(nRefund) + "g.");
}

void main()
{
    object oPC = GetPcDlgSpeaker();
    if(oPC == OBJECT_INVALID) return;

    int nEvent = GetDlgEventType();
    string sPage = GetDlgPageString();

    if(nEvent == DLG_INIT)
    {
        InitHousingDB();
        string sDTag = GetLocalString(oPC, HS_DOOR_TAG);
        int nPrice = GetLocalInt(oPC, HS_PRICE);
        string sAwait = GetLocalString(oPC, HS_AWAIT);
        if(sDTag != "" && nPrice > 0 && sAwait == "")
            ShowRegDetail(oPC, sDTag, nPrice);
        else
            ShowMenu(oPC);
    }
    else if(nEvent == DLG_SELECTION)
    {
        int nSel = GetDlgSelection();

        if(sPage == PAGE_MENU)
        {
            int nDM = GetIsDM(oPC);
            if(nSel == 0) ShowBrowse(oPC);
            else if(nSel == 1) ShowMine(oPC);
            else if(nSel == 2) ShowSuggestStart(oPC);
            else if(nSel == 3)
            {
                if(nDM) ShowAdminPanel(oPC);
                else EndDlg();
            }
            else if(nSel == 4 && nDM) EndDlg();
            else EndDlg();
        }
        else if(sPage == PAGE_BROWSE)
        {
            int nID = GetIntElement(nSel, "hs_br_ids", oPC);
            if(nID == -1) ShowMenu(oPC);
            else ShowPropDetail(oPC, nID);
        }
        else if(sPage == PAGE_PROP)
        {
            int nID = GetDlgPageInt();
            int nA = GetIntElement(nSel, "hs_pd_ids", oPC);
            if(nA == -1) ShowBrowse(oPC);
            else if(nA == 0) { DoRequestBuy(oPC, nID); ShowMenu(oPC); }
            else ShowMenu(oPC);
        }
        else if(sPage == PAGE_MINE)
        {
            int nID = GetIntElement(nSel, "hs_mn_ids", oPC);
            if(nID == -1) ShowMenu(oPC);
            else ShowMyProp(oPC, nID);
        }
        else if(sPage == PAGE_MYPROP)
        {
            int nID = GetDlgPageInt();
            int nA = GetIntElement(nSel, "hs_mp_ids", oPC);
            if(nA == -1) ShowMine(oPC);
            else if(nA == 0) { DoLockToggle(oPC, nID); ShowMyProp(oPC, nID); }
            else if(nA == 1) { DoSellProp(oPC, nID); ShowMenu(oPC); }
            else ShowMenu(oPC);
        }
        else if(sPage == PAGE_ADMIN)
        {
            int nChoice = GetIntElement(nSel, "hs_ad_ids", oPC);
            if(nChoice == -1) ShowMenu(oPC);
            else if(nChoice == 0) ShowRequestList(oPC);
            else if(nChoice == 1) ShowSuggestionList(oPC);
            else if(nChoice == 2)
            {
                string sDTag = GetLocalString(oPC, HS_DOOR_TAG);
                int nPrice = GetLocalInt(oPC, HS_PRICE);
                string sAwait = GetLocalString(oPC, HS_AWAIT);
                if(sDTag != "" && nPrice > 0 && sAwait == "")
                    ShowRegDetail(oPC, sDTag, nPrice);
                else
                    ShowRegStart(oPC);
            }
            else ShowAdminPanel(oPC);
        }
        else if(sPage == "reqlist")
        {
            int nRID = GetIntElement(nSel, "hs_rl_ids", oPC);
            if(nRID == -1) ShowAdminPanel(oPC);
            else ShowReqDetail(oPC, nRID);
        }
        else if(sPage == "sugglist")
        {
            int nSID = GetIntElement(nSel, "hs_sl_ids", oPC);
            if(nSID == -1) ShowAdminPanel(oPC);
            else ShowSuggDetail(oPC, nSID);
        }
        else if(sPage == "suggdetail")
        {
            int nSID = GetDlgPageInt();
            int nA = GetIntElement(nSel, "hs_sd_ids", oPC);
            if(nA == -1) ShowSuggestionList(oPC);
            else if(nA == 0)
            {
                int nRes = ApproveHousingSuggestion(nSID);
                if(nRes == -1) SendMessageToPC(oPC, "Door is already registered.");
                else if(nRes == 0) SendMessageToPC(oPC, "Suggestion no longer pending.");
                else SendMessageToPC(oPC, "Suggestion approved! Property registered.");
                ShowSuggestionList(oPC);
            }
            else if(nA == 1)
            {
                DenyHousingSuggestion(nSID);
                SendMessageToPC(oPC, "Suggestion denied.");
                ShowSuggestionList(oPC);
            }
            else ShowSuggestionList(oPC);
        }
        else if(sPage == "regwait" || sPage == "suggwait")
        {
            EndDlg();
        }
        else if(sPage == PAGE_REGDETAIL)
        {
            int nPrice = GetDlgPageInt();
            int nA = GetIntElement(nSel, "hs_ri_ids", oPC);
            if(nA == -1)
            {
                DeleteLocalString(oPC, HS_DOOR_TAG);
                DeleteLocalInt(oPC, HS_PRICE);
                DeleteLocalString(oPC, HS_AWAIT);
                DeleteLocalString(oPC, HS_PAGE);
                ShowAdminPanel(oPC);
            }
            else
            {
                string sInterior;
                if(nA == 0) sInterior = "small";
                else if(nA == 1) sInterior = "medium";
                else if(nA == 2) sInterior = "large";
                else sInterior = "mansion";
                DoRegisterNewProp(oPC, nPrice, sInterior);
                ShowMenu(oPC);
            }
        }
        else if(sPage == PAGE_REQDETAIL)
        {
            int nRID = GetDlgPageInt();
            int nA = GetIntElement(nSel, "hs_rd_ids", oPC);
            if(nA == -1) ShowAdminPanel(oPC);
            else if(nA == 0)
            {
                int nRes = ApproveHousingRequest(nRID);
                if(nRes == -1) SendMessageToPC(oPC, "Buyer does not have enough gold.");
                else if(nRes == 0) SendMessageToPC(oPC, "Request no longer pending.");
                else SendMessageToPC(oPC, "Request approved! Gold taken from buyer.");
                ShowAdminPanel(oPC);
            }
            else if(nA == 1)
            {
                DenyHousingRequest(nRID);
                SendMessageToPC(oPC, "Request denied.");
                ShowAdminPanel(oPC);
            }
            else ShowAdminPanel(oPC);
        }
    }
}
