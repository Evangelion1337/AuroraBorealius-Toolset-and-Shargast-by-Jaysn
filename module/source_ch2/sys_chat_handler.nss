#include "nwnx"
#include "nwnx_sql"
#include "sv_core"
#include "housing_db"

string GetWord(string s, int n)
{
    int count;
    int i;
    int len;
    string result;
    count = 1;
    len = GetStringLength(s);
    result = "";
    for(i = 0; i < len; i++)
    {
        string c;
        c = GetSubString(s, i, 1);
        if(c == " ")
        {
            count++;
        }
        else if(count == n)
        {
            result = result + c;
        }
        else if(count > n)
        {
            break;
        }
    }
    return result;
}

void InitMailTables()
{
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS mail_messages (mail_id INT AUTO_INCREMENT PRIMARY KEY, sender_cdkey VARCHAR(64) NOT NULL, sender_charname VARCHAR(64) NOT NULL, recipient_cdkey VARCHAR(64) NOT NULL, recipient_charname VARCHAR(64) NOT NULL, subject VARCHAR(128) NOT NULL DEFAULT '', body TEXT NOT NULL, gold_amount INT NOT NULL DEFAULT 0, item_count INT NOT NULL DEFAULT 0, sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, expires_at DATETIME, is_read TINYINT(1) NOT NULL DEFAULT 0, is_claimed TINYINT(1) NOT NULL DEFAULT 0, claimed_at DATETIME, INDEX idx_recipient (recipient_cdkey), INDEX idx_sender (sender_cdkey), INDEX idx_sent (sent_at))");

    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS mail_attachments (attach_id INT AUTO_INCREMENT PRIMARY KEY, mail_id INT NOT NULL, item_data LONGBLOB NOT NULL, item_tag VARCHAR(64) NOT NULL DEFAULT '', slot_number INT NOT NULL DEFAULT 0, FOREIGN KEY (mail_id) REFERENCES mail_messages(mail_id) ON DELETE CASCADE)");

    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS mail_registry (cdkey VARCHAR(64) NOT NULL, charname VARCHAR(64) NOT NULL, last_seen DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (cdkey, charname))");
}

void UpdateRegistry(object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    string sName = GetName(oPC);
    if(sCDKey == "") return;

    NWNX_SQL_PrepareQuery("INSERT INTO mail_registry (cdkey, charname, last_seen) VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE charname=VALUES(charname), last_seen=NOW()");
    NWNX_SQL_PreparedString(1, sCDKey);
    NWNX_SQL_PreparedString(2, sName);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

object FindPCByName(string sName)
{
    string sLower = GetStringLowerCase(sName);
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        string sPCName = GetStringLowerCase(GetName(oPC));
        if(FindSubString(sPCName, sLower) != -1)
            return oPC;
        oPC = GetNextPC();
    }
    return OBJECT_INVALID;
}

string GetCDKeyForRecipient(string sName)
{
    string sLower = GetStringLowerCase(sName);

    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        if(FindSubString(GetStringLowerCase(GetName(oPC)), sLower) != -1)
            return GetPCPublicCDKey(oPC);
        oPC = GetNextPC();
    }

    NWNX_SQL_PrepareQuery("SELECT cdkey FROM mail_registry WHERE LOWER(charname) LIKE ? ORDER BY last_seen DESC LIMIT 1");
    NWNX_SQL_PreparedString(1, "%" + sLower + "%");
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string sResult = NWNX_SQL_ReadDataInActiveRow(0);
        NWNX_SQL_DestroyPreparedQuery();
        return sResult;
    }
    NWNX_SQL_DestroyPreparedQuery();
    return "";
}

int GetMailCount(string sCDKey)
{
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM mail_messages WHERE recipient_cdkey = ?");
    NWNX_SQL_PreparedString(1, sCDKey);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        int nResult = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        NWNX_SQL_DestroyPreparedQuery();
        return nResult;
    }
    NWNX_SQL_DestroyPreparedQuery();
    return 0;
}

void SendPlayerMail(object oSender, string sRecipient, string sTitle, string sBody, int nGold, object oItem)
{
    if(sRecipient == "" || sTitle == "")
    {
        SendMessageToPC(oSender, "Usage: /mail send <player> <title> [msg]");
        return;
    }

    string sSenderCDKey = GetPCPublicCDKey(oSender);
    if(sSenderCDKey == "")
    {
        SendMessageToPC(oSender, "Cannot identify your account.");
        return;
    }
    string sSenderName = GetName(oSender);

    string sRecipCDKey = GetCDKeyForRecipient(sRecipient);
    if(sRecipCDKey == "")
    {
        SendMessageToPC(oSender, "Cannot find player '" + sRecipient + "'.");
        return;
    }

    object oOnlineRecipient = FindPCByName(sRecipient);
    if(GetIsObjectValid(oOnlineRecipient) && oOnlineRecipient == oSender)
    {
        SendMessageToPC(oSender, "You cannot send mail to yourself.");
        return;
    }

    string sRecipName = sRecipient;
    if(GetIsObjectValid(oOnlineRecipient))
        sRecipName = GetName(oOnlineRecipient);

    int nHasItem = GetIsObjectValid(oItem) ? 1 : 0;

    NWNX_SQL_PrepareQuery("INSERT INTO mail_messages (sender_cdkey, sender_charname, recipient_cdkey, recipient_charname, subject, body, gold_amount, item_count, sent_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())");
    NWNX_SQL_PreparedString(1, sSenderCDKey);
    NWNX_SQL_PreparedString(2, sSenderName);
    NWNX_SQL_PreparedString(3, sRecipCDKey);
    NWNX_SQL_PreparedString(4, sRecipName);
    NWNX_SQL_PreparedString(5, sTitle);
    NWNX_SQL_PreparedString(6, sBody);
    NWNX_SQL_PreparedInt(7, nGold);
    NWNX_SQL_PreparedInt(8, nHasItem);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    if(GetIsObjectValid(oItem))
    {
        NWNX_SQL_PrepareQuery("SELECT MAX(mail_id) FROM mail_messages WHERE sender_cdkey = ?");
        NWNX_SQL_PreparedString(1, sSenderCDKey);
        int nMailID = 0;
        if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            nMailID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        }
        NWNX_SQL_DestroyPreparedQuery();

        if(nMailID > 0)
        {
            NWNX_SQL_PrepareQuery("INSERT INTO mail_attachments (mail_id, item_data, item_tag, slot_number) VALUES (?, ?, ?, 0)");
            NWNX_SQL_PreparedInt(1, nMailID);
            NWNX_SQL_PreparedObjectFull(2, oItem);
            NWNX_SQL_PreparedString(3, GetTag(oItem));
            NWNX_SQL_ExecutePreparedQuery();
            NWNX_SQL_DestroyPreparedQuery();
        }
    }

    SendMessageToPC(oSender, "Mail sent to " + sRecipName + ".");
    if(GetIsObjectValid(oOnlineRecipient))
        SendMessageToPC(oOnlineRecipient, "New mail from " + sSenderName + "! Type /mail inbox to read it.");
}

void ReadPlayerMail(object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    if(sCDKey == "") return;

    int nCount = GetMailCount(sCDKey);
    if(nCount < 1)
    {
        SendMessageToPC(oPC, "You have no mail.");
        return;
    }

    int nStart = nCount - 9;
    if(nStart < 1) nStart = 1;

    SendMessageToPC(oPC, "--- Your Mail (" + IntToString(nStart) + "-" + IntToString(nCount) + " of " + IntToString(nCount) + ") ---");

    NWNX_SQL_PrepareQuery("SELECT mail_id, sender_charname, subject, gold_amount, item_count, is_claimed FROM mail_messages WHERE recipient_cdkey = ? ORDER BY mail_id DESC LIMIT 10");
    NWNX_SQL_PreparedString(1, sCDKey);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            string sSender = NWNX_SQL_ReadDataInActiveRow(1);
            string sSubject = NWNX_SQL_ReadDataInActiveRow(2);
            int nGold = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
            int nHasItem = StringToInt(NWNX_SQL_ReadDataInActiveRow(4));
            int nClaimed = StringToInt(NWNX_SQL_ReadDataInActiveRow(5));

            string sInfo = IntToString(nID) + ": [" + sSender + "] " + sSubject;
            if(nGold > 0)
            {
                if(nClaimed > 0) sInfo += " [+" + IntToString(nGold) + "g claimed]";
                else sInfo += " [+" + IntToString(nGold) + "g]";
            }
            if(nHasItem > 0)
            {
                if(nClaimed > 0) sInfo += " [item claimed]";
                else sInfo += " [item attached]";
            }

            SendMessageToPC(oPC, sInfo);
        }
    }
    NWNX_SQL_DestroyPreparedQuery();
}

void DeletePlayerMail(object oPC, int nID)
{
    if(nID < 1)
    {
        SendMessageToPC(oPC, "Usage: /mail delete <id>");
        return;
    }

    string sCDKey = GetPCPublicCDKey(oPC);
    if(sCDKey == "") return;

    NWNX_SQL_PrepareQuery("SELECT is_claimed FROM mail_messages WHERE mail_id = ? AND recipient_cdkey = ?");
    NWNX_SQL_PreparedInt(1, nID);
    NWNX_SQL_PreparedString(2, sCDKey);
    int nClaimed = 1;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nClaimed = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    }
    NWNX_SQL_DestroyPreparedQuery();

    NWNX_SQL_PrepareQuery("DELETE FROM mail_messages WHERE mail_id = ? AND recipient_cdkey = ?");
    NWNX_SQL_PreparedInt(1, nID);
    NWNX_SQL_PreparedString(2, sCDKey);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    SendMessageToPC(oPC, "Mail " + IntToString(nID) + " deleted.");
}

void ClaimMail(object oPC, int nID)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    if(sCDKey == "") return;

    if(nID < 1)
    {
        SendMessageToPC(oPC, "Usage: /mail claim <id>");
        return;
    }

    NWNX_SQL_PrepareQuery("SELECT gold_amount, item_count, is_claimed FROM mail_messages WHERE mail_id = ? AND recipient_cdkey = ?");
    NWNX_SQL_PreparedInt(1, nID);
    NWNX_SQL_PreparedString(2, sCDKey);
    if(!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_DestroyPreparedQuery();
        SendMessageToPC(oPC, "Invalid mail ID.");
        return;
    }
    NWNX_SQL_ReadNextRow();
    int nGold = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    int nHasItem = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));
    int nClaimed = StringToInt(NWNX_SQL_ReadDataInActiveRow(2));
    NWNX_SQL_DestroyPreparedQuery();

    if(nClaimed > 0)
    {
        SendMessageToPC(oPC, "Already claimed from this mail.");
        return;
    }

    if(nGold < 1 && nHasItem < 1)
    {
        SendMessageToPC(oPC, "No gold or items to claim.");
        return;
    }

    if(nGold > 0)
    {
        GiveGoldToCreature(oPC, nGold);
        SendMessageToPC(oPC, "Claimed " + IntToString(nGold) + " gold.");
    }

    if(nHasItem > 0)
    {
        NWNX_SQL_PrepareQuery("SELECT item_data FROM mail_attachments WHERE mail_id = ? ORDER BY attach_id ASC LIMIT 1");
        NWNX_SQL_PreparedInt(1, nID);
        if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            object oItem = NWNX_SQL_ReadFullObjectInActiveRow(0, oPC);
            if(GetIsObjectValid(oItem))
                SendMessageToPC(oPC, "Retrieved: " + GetName(oItem));
            else
                SendMessageToPC(oPC, "Could not retrieve item.");
        }
        else
        {
            SendMessageToPC(oPC, "Could not retrieve item.");
        }
        NWNX_SQL_DestroyPreparedQuery();
    }

    NWNX_SQL_PrepareQuery("UPDATE mail_messages SET is_claimed = 1, claimed_at = NOW() WHERE mail_id = ?");
    NWNX_SQL_PreparedInt(1, nID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
}

void HandleMailCommand(object oPC, string sChat)
{
    string sCmd;
    sCmd = GetWord(sChat, 2);

    InitMailTables();
    UpdateRegistry(oPC);

    if(sCmd == "send")
    {
        string sRecipient = GetWord(sChat, 3);
        string sTitle = GetWord(sChat, 4);
        string sMessage = "";
        int nWord;
        for(nWord = 5; nWord <= 12; nWord++)
        {
            string sPart = GetWord(sChat, nWord);
            if(sPart != "") sMessage = sMessage + " " + sPart;
        }
        SendPlayerMail(oPC, sRecipient, sTitle, sMessage, 0, OBJECT_INVALID);
    }
    else if(sCmd == "sendgold")
    {
        string sRecipient = GetWord(sChat, 3);
        int nAmount = StringToInt(GetWord(sChat, 4));
        if(sRecipient == "" || nAmount < 1)
        {
            SendMessageToPC(oPC, "Usage: /mail sendgold <player> <amount>");
            return;
        }
        if(GetGold(oPC) < nAmount)
        {
            SendMessageToPC(oPC, "You don't have enough gold.");
            return;
        }
        TakeGoldFromCreature(nAmount, oPC);
        SendPlayerMail(oPC, sRecipient, "Gold (" + IntToString(nAmount) + ")", "", nAmount, OBJECT_INVALID);
    }
    else if(sCmd == "senditem")
    {
        string sRecipient = GetWord(sChat, 3);
        if(sRecipient == "")
        {
            SendMessageToPC(oPC, "Usage: /mail senditem <player>");
            return;
        }
        object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
        if(!GetIsObjectValid(oItem))
        {
            SendMessageToPC(oPC, "Hold the item in your right hand to send.");
            return;
        }
        string sItemName = GetName(oItem);
        SendPlayerMail(oPC, sRecipient, "Item: " + sItemName, "", 0, oItem);
    }
    else if(sCmd == "inbox" || sCmd == "read")
    {
        ReadPlayerMail(oPC);
    }
    else if(sCmd == "delete" || sCmd == "del")
    {
        int nID = StringToInt(GetWord(sChat, 3));
        DeletePlayerMail(oPC, nID);
    }
    else if(sCmd == "claim")
    {
        int nID = StringToInt(GetWord(sChat, 3));
        ClaimMail(oPC, nID);
    }
    else if(sCmd == "help")
    {
        SendMessageToPC(oPC, "--- Mail Commands ---");
        SendMessageToPC(oPC, "/mail send <player> <title> [msg] - Send a message");
        SendMessageToPC(oPC, "/mail sendgold <player> <amount> - Send gold");
        SendMessageToPC(oPC, "/mail senditem <player> - Send held item");
        SendMessageToPC(oPC, "/mail inbox - Read your mail");
        SendMessageToPC(oPC, "/mail claim <id> - Claim gold/item from mail");
        SendMessageToPC(oPC, "/mail delete <id> - Delete a message");
        SendMessageToPC(oPC, "/mail help - This help");
    }
    else
    {
        SendMessageToPC(oPC, "Unknown mail command. Try /mail help");
    }
}

void HandleHouseCommand(object oPC, string sChat)
{
    string sCmd = GetWord(sChat, 2);
    object oArea = GetArea(oPC);
    string sAreaTag = GetTag(oArea);
    int nPropID = GetPropertyIDByArea(sAreaTag);

    if(sCmd == "buy")
    {
        int nResult = BuyProperty(sAreaTag, oPC);
        if(nResult == 1)
            SendMessageToPC(oPC, "You bought this house! Use /house guest, /house lock.");
        else if(nResult == -1)
            SendMessageToPC(oPC, "This house is not for sale.");
        else if(nResult == -2)
            SendMessageToPC(oPC, "You don't have enough gold.");
        else
            SendMessageToPC(oPC, "Could not buy this house.");
        return;
    }

    if(sCmd == "sell")
    {
        int nRefund = SellProperty(sAreaTag, oPC);
        if(nRefund > 0)
            SendMessageToPC(oPC, "You sold your house for " + IntToString(nRefund) + " gold.");
        else if(nRefund == -1)
            SendMessageToPC(oPC, "This is not a house.");
        else if(nRefund == -2)
            SendMessageToPC(oPC, "You don't own this house.");
        else
            SendMessageToPC(oPC, "Could not sell.");
        return;
    }

    if(sCmd == "lock" || sCmd == "unlock")
    {
        if(nPropID < 1)
        {
            SendMessageToPC(oPC, "This is not a house area.");
            return;
        }
        if(!IsPlayerOwner(nPropID, oPC))
        {
            SendMessageToPC(oPC, "Only the owner can do that.");
            return;
        }
        int nLock = (sCmd == "lock") ? 1 : 0;
        SetPropertyLock(nPropID, nLock);
        string sDoorTag = GetDoorTagForArea(sAreaTag);
        if(sDoorTag != "")
        {
            object oDoor = GetNearestObjectByTag(sDoorTag, oPC);
            if(GetIsObjectValid(oDoor))
                SetLocked(oDoor, nLock == 1);
        }
        if(nLock) SendMessageToPC(oPC, "House locked.");
        else SendMessageToPC(oPC, "House unlocked.");
        return;
    }

    if(sCmd == "info")
    {
        if(nPropID < 1)
        {
            SendMessageToPC(oPC, "This is not a registered house area.");
            return;
        }
        string sOwner = GetPropertyOwnerName(nPropID);
        int nPrice = GetPropertyPrice(nPropID);
        int nForSale = IsPropertyForSale(sAreaTag);
        string sDoorTag = GetDoorTagForArea(sAreaTag);
        int nLocked = 0;
        if(sDoorTag != "") nLocked = IsPropertyLocked(sDoorTag);
        if(nForSale)
            SendMessageToPC(oPC, "House for sale! Price: " + IntToString(nPrice) + " gold. Use /house buy to purchase.");
        else
            SendMessageToPC(oPC, "Owner: " + sOwner + " | Locked: " + IntToString(nLocked) + " | Price: " + IntToString(nPrice) + "g");
        return;
    }

    if(sCmd == "guest")
    {
        if(nPropID < 1)
        {
            SendMessageToPC(oPC, "This is not a house area.");
            return;
        }
        if(!IsPlayerOwner(nPropID, oPC))
        {
            SendMessageToPC(oPC, "Only the owner can manage guests.");
            return;
        }
        string sSub = GetWord(sChat, 3);
        string sName = GetWord(sChat, 4);
        if(sSub == "add" && sName != "")
        {
            object oTarget = GetFirstPC();
            int nFound = 0;
            while(GetIsObjectValid(oTarget))
            {
                if(FindSubString(GetStringLowerCase(GetName(oTarget)), GetStringLowerCase(sName)) != -1)
                {
                    AddGuest(nPropID, GetPCPublicCDKey(oTarget), GetName(oTarget));
                    SendMessageToPC(oPC, "Added " + GetName(oTarget) + " as a guest.");
                    nFound = 1;
                    break;
                }
                oTarget = GetNextPC();
            }
            if(!nFound)
                SendMessageToPC(oPC, "Cannot find player '" + sName + "'.");
        }
        else if(sSub == "remove" && sName != "")
        {
            object oTarget = GetFirstPC();
            int nFound = 0;
            while(GetIsObjectValid(oTarget))
            {
                if(FindSubString(GetStringLowerCase(GetName(oTarget)), GetStringLowerCase(sName)) != -1)
                {
                    RemoveGuest(nPropID, GetPCPublicCDKey(oTarget));
                    SendMessageToPC(oPC, "Removed " + GetName(oTarget) + " from guests.");
                    nFound = 1;
                    break;
                }
                oTarget = GetNextPC();
            }
            if(!nFound)
                SendMessageToPC(oPC, "Cannot find player '" + sName + "'.");
        }
        else
        {
            SendMessageToPC(oPC, "Usage: /house guest add <player> or /house guest remove <player>");
        }
        return;
    }

    if(sCmd == "place")
    {
        if(!GetIsDM(oPC))
        {
            SendMessageToPC(oPC, "Only DMs can place houses.");
            return;
        }
        string sPriceStr = GetWord(sChat, 3);
        int nPrice = StringToInt(sPriceStr);
        if(nPrice < 1) nPrice = 5000;
        string sDTag = GetWord(sChat, 4);
        string sInterior = GetWord(sChat, 5);
        if(sInterior == "") sInterior = "small";
        string sA = GetTag(GetArea(oPC));
        if(RegisterProperty(sA, sDTag, nPrice, sInterior))
            SendMessageToPC(oPC, "House registered in area '" + sA + "' price " + IntToString(nPrice) + "g door='" + sDTag + "' interior='" + sInterior + "'");
        else
            SendMessageToPC(oPC, "Failed to register house.");
        return;
    }

    if(sCmd == "setdoor")
    {
        if(!GetIsDM(oPC))
        {
            SendMessageToPC(oPC, "Only DMs can set doors.");
            return;
        }
        string sDTag = GetWord(sChat, 3);
        string sA = GetTag(GetArea(oPC));
        NWNX_SQL_PrepareQuery("UPDATE housing_properties SET door_tag = ? WHERE area_tag = ?");
        NWNX_SQL_PreparedString(1, sDTag);
        NWNX_SQL_PreparedString(2, sA);
        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();
        SendMessageToPC(oPC, "Door tag set to '" + sDTag + "' for area '" + sA + "'");
        return;
    }

    if(sCmd == "remove")
    {
        if(!GetIsDM(oPC))
        {
            SendMessageToPC(oPC, "Only DMs can remove houses.");
            return;
        }
        string sA = GetTag(GetArea(oPC));
        if(RemoveProperty(sA))
            SendMessageToPC(oPC, "House removed from area '" + sA + "'");
        else
            SendMessageToPC(oPC, "Failed to remove house.");
        return;
    }

    if(sCmd == "list")
    {
        if(!GetIsDM(oPC))
        {
            SendMessageToPC(oPC, "Only DMs can list houses.");
            return;
        }
        NWNX_SQL_ExecuteQuery("SELECT area_tag, door_tag, price, owner_charname, for_sale FROM housing_properties");
        int nRow = 0;
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            string sArea = NWNX_SQL_ReadDataInActiveRow(0);
            string sDoor = NWNX_SQL_ReadDataInActiveRow(1);
            string sP = NWNX_SQL_ReadDataInActiveRow(2);
            string sOwner = NWNX_SQL_ReadDataInActiveRow(3);
            string sSale = NWNX_SQL_ReadDataInActiveRow(4);
            SendMessageToPC(oPC, "#" + IntToString(nRow + 1) + " area=" + sArea + " door=" + sDoor + " price=" + sP + " owner=" + sOwner + " sale=" + sSale);
            nRow++;
        }
        if(nRow < 1) SendMessageToPC(oPC, "No houses registered.");
        return;
    }

    SendMessageToPC(oPC, "Usage: /house buy | sell | lock | unlock | info | guest <add|remove> <player> | [DM] place <price> | setdoor <tag> | remove | list");
}

const string MAIL_RECIP = "ZEP_MAIL_RECIP";
const string MAIL_GOLD = "ZEP_MAIL_GOLD";
const string MAIL_AWAIT = "ZEP_MAIL_AWAIT";
const string MAIL_PAGE = "ZEP_MAIL_PAGE";

void HandleMailboxInput(object oPC, string sChat)
{
    string sAwait = GetLocalString(oPC, MAIL_AWAIT);
    if(sAwait == "") return;

    if(sChat == "/mb cancel")
    {
        DeleteLocalString(oPC, MAIL_RECIP);
        DeleteLocalInt(oPC, MAIL_GOLD);
        DeleteLocalString(oPC, MAIL_AWAIT);
        DeleteLocalString(oPC, MAIL_PAGE);
        SendMessageToPC(oPC, "Mailbox: Cancelled.");
        return;
    }

    if(GetSubString(sChat, 0, 1) == "/")
    {
        SendMessageToPC(oPC, "Mailbox: Type the " + sAwait + " in chat, or /mb cancel to abort.");
        return;
    }

    if(sAwait == "recipient name")
    {
        SetLocalString(oPC, MAIL_RECIP, sChat);
        DeleteLocalString(oPC, MAIL_AWAIT);
        SendMessageToPC(oPC, "Mailbox: Recipient set to '" + sChat + "'. Use the mailbox to continue.");
    }
    else if(sAwait == "gold amount")
    {
        int nGold = StringToInt(sChat);
        if(nGold < 1)
        {
            SendMessageToPC(oPC, "Mailbox: Enter a valid gold amount (1 or more), or 0 to skip.");
            return;
        }
        SetLocalInt(oPC, MAIL_GOLD, nGold);
        DeleteLocalString(oPC, MAIL_AWAIT);
        SendMessageToPC(oPC, "Mailbox: Gold set to " + IntToString(nGold) + ". Use the mailbox to continue.");
    }
}

const string HS_AWAIT = "ZEP_HS_AWAIT";
const string HS_DOOR_TAG = "ZEP_HS_DOOR";
const string HS_PRICE = "ZEP_HS_PRICE";
const string HS_PAGE = "ZEP_HS_PAGE";

void HandleHousingInput(object oPC, string sChat)
{
    string sAwait = GetLocalString(oPC, HS_AWAIT);
    if(sAwait == "") return;

    if(sChat == "/hs cancel")
    {
        DeleteLocalString(oPC, HS_AWAIT);
        DeleteLocalString(oPC, HS_DOOR_TAG);
        DeleteLocalInt(oPC, HS_PRICE);
        DeleteLocalString(oPC, HS_PAGE);
        SendMessageToPC(oPC, "Housing: Cancelled.");
        return;
    }

    if(GetSubString(sChat, 0, 1) == "/")
    {
        SendMessageToPC(oPC, "Housing: Type the " + sAwait + " in chat, or /hs cancel to abort.");
        return;
    }

    string sMode = GetLocalString(oPC, HS_PAGE);

    if(sAwait == "door tag")
    {
        object oDoor = GetNearestObjectByTag(sChat, oPC);
        if(!GetIsObjectValid(oDoor) || GetObjectType(oDoor) != OBJECT_TYPE_DOOR)
        {
            SendMessageToPC(oPC, "No door found with tag '" + sChat + "'. Check the tag and try again.");
            return;
        }
        if(IsDoorRegistered(sChat))
        {
            SendMessageToPC(oPC, "Door '" + sChat + "' is already registered to a property.");
            return;
        }
        SetLocalString(oPC, HS_DOOR_TAG, sChat);
        DeleteLocalString(oPC, HS_AWAIT);
        SendMessageToPC(oPC, "Housing: Door '" + sChat + "' accepted. Now enter the sale price in chat (/hs cancel to abort).");
        SetLocalString(oPC, HS_AWAIT, "price");
    }
    else if(sAwait == "price")
    {
        int nPrice = StringToInt(sChat);
        if(nPrice < 1)
        {
            SendMessageToPC(oPC, "Enter a valid price (1 or more gold).");
            return;
        }
        if(sMode == "register")
        {
            SetLocalInt(oPC, HS_PRICE, nPrice);
            DeleteLocalString(oPC, HS_AWAIT);
            SendMessageToPC(oPC, "Housing: Price set to " + IntToString(nPrice) + "g. Use the housing board to select interior type.");
        }
        else if(sMode == "suggest")
        {
            string sDoorTag = GetLocalString(oPC, HS_DOOR_TAG);
            string sAreaTag = GetTag(GetArea(oPC));
            string sCDKey = GetPCPublicCDKey(oPC);
            string sName = GetName(oPC);
            int nRes = CreateHousingSuggestion(sDoorTag, sAreaTag, sCDKey, sName, nPrice);
            if(nRes == 1)
            {
                DeleteLocalString(oPC, HS_AWAIT);
                DeleteLocalString(oPC, HS_DOOR_TAG);
                DeleteLocalInt(oPC, HS_PRICE);
                DeleteLocalString(oPC, HS_PAGE);
                SendMessageToPC(oPC, "Suggestion submitted! An admin will review it.");
            }
            else if(nRes == -1)
            {
                SendMessageToPC(oPC, "Door is already registered. Try another door.");
            }
            else
            {
                SendMessageToPC(oPC, "Failed to create suggestion. Try again.");
            }
        }
    }
}

void main()
{
    object oPC;
    string sChat;
    oPC = GetPCChatSpeaker();
    sChat = GetPCChatMessage();

    string sMailAwait = GetLocalString(oPC, MAIL_AWAIT);
    if(sMailAwait != "")
    {
        HandleMailboxInput(oPC, sChat);
        SetPCChatMessage("");
    }

    string sHsAwait = GetLocalString(oPC, HS_AWAIT);
    if(sHsAwait != "")
    {
        HandleHousingInput(oPC, sChat);
        SetPCChatMessage("");
    }

    ExecuteScript("prc_onplayerchat", oPC);

    if(sChat == "/mail" || GetWord(sChat, 1) == "/mail")
    {
        HandleMailCommand(oPC, sChat);
        SetPCChatMessage("");
    }

    if(sChat == "/house" || GetWord(sChat, 1) == "/house")
    {
        HandleHouseCommand(oPC, sChat);
        SetPCChatMessage("");
    }
}
