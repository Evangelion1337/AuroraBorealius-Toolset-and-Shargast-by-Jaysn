#include "nwnx"
#include "nwnx_sql"
#include "zdlg_include_i"

const string MAIL_RECIP = "ZEP_MAIL_RECIP";
const string MAIL_GOLD = "ZEP_MAIL_GOLD";
const string MAIL_ITEM = "ZEP_MAIL_ITEM";
const string MAIL_ITEM_NAME = "ZEP_MAIL_ITEM_NAME";
const string MAIL_AWAIT = "ZEP_MAIL_AWAIT";
const string MAIL_PAGE = "ZEP_MAIL_PAGE";

const string PAGE_MENU = "menu";
const string PAGE_READ_LIST = "rlist";
const string PAGE_READ_MSG = "rmsg";
const string PAGE_COMPOSE = "comp";
const string PAGE_ITEM_PICK = "ipick";
const string PAGE_AWAIT = "await";

int GetMailCount(string sCDKey, int nUnreadOnly)
{
    string sQ;
    if(nUnreadOnly) sQ = "SELECT COUNT(*) FROM mail_messages WHERE recipient_cdkey = ? AND is_read = 0 AND is_claimed = 0";
    else sQ = "SELECT COUNT(*) FROM mail_messages WHERE recipient_cdkey = ?";
    NWNX_SQL_PrepareQuery(sQ);
    NWNX_SQL_PreparedString(1, sCDKey);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        int nR = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        NWNX_SQL_DestroyPreparedQuery();
        return nR;
    }
    NWNX_SQL_DestroyPreparedQuery();
    return 0;
}

int GetUnclaimedCount(string sCDKey)
{
    NWNX_SQL_PrepareQuery("SELECT COUNT(*) FROM mail_messages WHERE recipient_cdkey = ? AND is_claimed = 0 AND (gold_amount > 0 OR item_count > 0)");
    NWNX_SQL_PreparedString(1, sCDKey);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        int nR = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        NWNX_SQL_DestroyPreparedQuery();
        return nR;
    }
    NWNX_SQL_DestroyPreparedQuery();
    return 0;
}

void DelList(string sL, object o)
{
    DeleteList(sL, o);
}

void ShowMenu(object oPC)
{
    string sCK = GetPCPublicCDKey(oPC);
    int nUnread = GetMailCount(sCK, 1);
    int nTotal = GetMailCount(sCK, 0);
    int nUncl = GetUnclaimedCount(sCK);
    string sItem = GetLocalString(oPC, MAIL_ITEM_NAME);
    string sRecip = GetLocalString(oPC, MAIL_RECIP);

    string sP = "Pigeonhole Mailbox\n";
    if(nUnread > 0) sP += "Unread: " + IntToString(nUnread) + " | ";
    sP += "Total: " + IntToString(nTotal) + "\n";
    if(nUncl > 0) sP += "Unclaimed items/gold: " + IntToString(nUncl) + "\n";
    if(sItem != "") sP += "Item ready: " + sItem + "\n";
    if(sRecip != "") sP += "Send to: " + sRecip + "\n";

    DelList("mbox_mnu", oPC);
    if(nTotal > 0) AddStringElement("Read Mail (" + IntToString(nTotal) + ")", "mbox_mnu", oPC);
    else AddStringElement("Read Mail (none)", "mbox_mnu", oPC);
    AddStringElement("Send an Item", "mbox_mnu", oPC);
    if(nUncl > 0) AddStringElement("Claim All (" + IntToString(nUncl) + ")", "mbox_mnu", oPC);
    AddStringElement("Exit", "mbox_mnu", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("mbox_mnu", oPC);
    SetDlgPageString(PAGE_MENU);
}

void ShowMailList(object oPC)
{
    string sCK = GetPCPublicCDKey(oPC);
    DelList("mbox_ml", oPC);
    DelList("mbox_ml_ids", oPC);

    NWNX_SQL_PrepareQuery("SELECT mail_id, sender_charname, subject, gold_amount, item_count, is_read, is_claimed FROM mail_messages WHERE recipient_cdkey = ? ORDER BY mail_id DESC LIMIT 30");
    NWNX_SQL_PreparedString(1, sCK);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            string sS = NWNX_SQL_ReadDataInActiveRow(1);
            string sSub = NWNX_SQL_ReadDataInActiveRow(2);
            int nG = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
            int nI = StringToInt(NWNX_SQL_ReadDataInActiveRow(4));
            int nR = StringToInt(NWNX_SQL_ReadDataInActiveRow(5));
            int nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(6));

            string sL = "";
            if(nR == 0) sL += "*";
            else sL += " ";
            sL += " #" + IntToString(nID) + " " + sS + " - " + sSub;
            if(nG > 0 && nC == 0) sL += " [+" + IntToString(nG) + "g]";
            if(nI > 0 && nC == 0) sL += " [item]";

            AddStringElement(sL, "mbox_ml", oPC);
            AddIntElement(nID, "mbox_ml_ids", oPC);
        }
    }
    NWNX_SQL_DestroyPreparedQuery();

    AddStringElement("Back to Menu", "mbox_ml", oPC);
    AddIntElement(-1, "mbox_ml_ids", oPC);

    SetDlgPrompt("Your Messages:");
    SetDlgResponseList("mbox_ml", oPC);
    SetDlgPageString(PAGE_READ_LIST);
}

void ShowReadMail(object oPC, int nMailID)
{
    string sCK = GetPCPublicCDKey(oPC);
    string sP = "";

    NWNX_SQL_PrepareQuery("SELECT sender_charname, subject, body, gold_amount, item_count, is_claimed, sent_at FROM mail_messages WHERE mail_id = ? AND recipient_cdkey = ?");
    NWNX_SQL_PreparedInt(1, nMailID);
    NWNX_SQL_PreparedString(2, sCK);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sP = "From: " + NWNX_SQL_ReadDataInActiveRow(0) + "\n";
        sP += "Subject: " + NWNX_SQL_ReadDataInActiveRow(1) + "\n\n";
        sP += NWNX_SQL_ReadDataInActiveRow(2) + "\n\n";
        int nG = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
        int nI = StringToInt(NWNX_SQL_ReadDataInActiveRow(4));
        int nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(5));
        if(nC > 0) sP += "[Claimed]";
        else
        {
            if(nG > 0) sP += "Gold: " + IntToString(nG) + "\n";
            if(nI > 0) sP += "Has item attachment\n";
        }
        sP += "\nSent: " + NWNX_SQL_ReadDataInActiveRow(6);
    }
    NWNX_SQL_DestroyPreparedQuery();

    NWNX_SQL_PrepareQuery("UPDATE mail_messages SET is_read = 1 WHERE mail_id = ?");
    NWNX_SQL_PreparedInt(1, nMailID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    DelList("mbox_ract", oPC);
    DelList("mbox_ract_ids", oPC);

    NWNX_SQL_PrepareQuery("SELECT is_claimed FROM mail_messages WHERE mail_id = ?");
    NWNX_SQL_PreparedInt(1, nMailID);
    int nC = 1;
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(0)); }
    NWNX_SQL_DestroyPreparedQuery();

    if(nC == 0)
    {
        AddStringElement("Claim Gold & Items", "mbox_ract", oPC);
        AddIntElement(-2, "mbox_ract_ids", oPC);
    }
    AddStringElement("Delete Message", "mbox_ract", oPC);
    AddIntElement(-3, "mbox_ract_ids", oPC);
    AddStringElement("Back to List", "mbox_ract", oPC);
    AddIntElement(-1, "mbox_ract_ids", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("mbox_ract", oPC);
    SetDlgPageInt(nMailID);
    SetDlgPageString(PAGE_READ_MSG);
}

void ShowItemPick(object oPC)
{
    DelList("mbox_ip", oPC);
    DelList("mbox_ip_ob", oPC);

    object oItem = GetFirstItemInInventory(oPC);
    while(GetIsObjectValid(oItem))
    {
        string sN = GetName(oItem);
        int nS = GetItemStackSize(oItem);
        if(nS > 1) sN += " x" + IntToString(nS);
        AddStringElement(sN, "mbox_ip", oPC);
        AddObjectElement(oItem, "mbox_ip_ob", oPC);
        oItem = GetNextItemInInventory(oPC);
    }

    int nC = GetElementCount("mbox_ip", oPC);
    if(nC == 0)
    {
        SetDlgPrompt("Your inventory is empty.");
        AddStringElement("Back", "mbox_ip", oPC);
        AddObjectElement(OBJECT_INVALID, "mbox_ip_ob", oPC);
        SetDlgResponseList("mbox_ip", oPC);
        SetDlgPageString(PAGE_MENU);
        return;
    }

    AddStringElement("Back to Menu", "mbox_ip", oPC);
    AddObjectElement(OBJECT_INVALID, "mbox_ip_ob", oPC);

    SetDlgPrompt("Pick an item to send:");
    SetDlgResponseList("mbox_ip", oPC);
    SetDlgPageString(PAGE_ITEM_PICK);
}

void ShowCompose(object oPC)
{
    string sR = GetLocalString(oPC, MAIL_RECIP);
    int nG = GetLocalInt(oPC, MAIL_GOLD);
    string sI = GetLocalString(oPC, MAIL_ITEM_NAME);

    string sP = "Send Mail:\n";
    if(sR != "") sP += "To: " + sR + "\n";
    else sP += "To: (not set)\n";
    if(sI != "") sP += "Item: " + sI + "\n";
    if(nG > 0) sP += "Gold: " + IntToString(nG) + "\n";

    DelList("mbox_cp", oPC);
    DelList("mbox_cp_ids", oPC);

    AddStringElement("Set Recipient (type in chat)", "mbox_cp", oPC);
    AddIntElement(0, "mbox_cp_ids", oPC);
    AddStringElement("Select Item from Inventory", "mbox_cp", oPC);
    AddIntElement(1, "mbox_cp_ids", oPC);
    AddStringElement("Add Gold (type amount in chat)", "mbox_cp", oPC);
    AddIntElement(2, "mbox_cp_ids", oPC);
    if(sR != "" && (sI != "" || nG > 0))
    {
        AddStringElement("Send Now!", "mbox_cp", oPC);
        AddIntElement(3, "mbox_cp_ids", oPC);
    }
    AddStringElement("Cancel", "mbox_cp", oPC);
    AddIntElement(4, "mbox_cp_ids", oPC);

    SetDlgPrompt(sP);
    SetDlgResponseList("mbox_cp", oPC);
    SetDlgPageString(PAGE_COMPOSE);
}

void SetAwait(object oPC, string sWhat, string sNextPage)
{
    SetLocalString(oPC, MAIL_AWAIT, sWhat);
    SetLocalString(oPC, MAIL_PAGE, sNextPage);
    SetDlgPrompt("Type the " + sWhat + " in chat, then use the mailbox again.");
    DelList("mbox_ok", oPC);
    AddStringElement("OK (end conversation)", "mbox_ok", oPC);
    SetDlgResponseList("mbox_ok", oPC);
    SetDlgPageString(PAGE_AWAIT);
}

void DoClaimMail(object oPC, int nID)
{
    string sCK = GetPCPublicCDKey(oPC);
    NWNX_SQL_PrepareQuery("SELECT gold_amount, item_count, is_claimed FROM mail_messages WHERE mail_id = ? AND recipient_cdkey = ?");
    NWNX_SQL_PreparedInt(1, nID);
    NWNX_SQL_PreparedString(2, sCK);
    if(!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_DestroyPreparedQuery(); return; }
    NWNX_SQL_ReadNextRow();
    int nG = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    int nI = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));
    int nC = StringToInt(NWNX_SQL_ReadDataInActiveRow(2));
    NWNX_SQL_DestroyPreparedQuery();
    if(nC > 0) return;

    if(nG > 0) GiveGoldToCreature(oPC, nG);
    if(nI > 0)
    {
        NWNX_SQL_PrepareQuery("SELECT item_data FROM mail_attachments WHERE mail_id = ? ORDER BY attach_id ASC");
        NWNX_SQL_PreparedInt(1, nID);
        if(NWNX_SQL_ExecutePreparedQuery())
        {
            while(NWNX_SQL_ReadyToReadNextRow())
            {
                NWNX_SQL_ReadNextRow();
                object oI = NWNX_SQL_ReadFullObjectInActiveRow(0, oPC);
                if(GetIsObjectValid(oI)) SendMessageToPC(oPC, "Retrieved: " + GetName(oI));
            }
        }
        NWNX_SQL_DestroyPreparedQuery();
    }
    NWNX_SQL_PrepareQuery("UPDATE mail_messages SET is_claimed = 1, claimed_at = NOW() WHERE mail_id = ?");
    NWNX_SQL_PreparedInt(1, nID);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
    SendMessageToPC(oPC, "Mail #" + IntToString(nID) + " claimed.");
}

void DoClaimAll(object oPC)
{
    string sCK = GetPCPublicCDKey(oPC);
    int nC = 0;
    NWNX_SQL_PrepareQuery("SELECT mail_id, gold_amount, item_count FROM mail_messages WHERE recipient_cdkey = ? AND is_claimed = 0 AND (gold_amount > 0 OR item_count > 0)");
    NWNX_SQL_PreparedString(1, sCK);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            int nG = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));
            int nI = StringToInt(NWNX_SQL_ReadDataInActiveRow(2));
            if(nG > 0) GiveGoldToCreature(oPC, nG);
            if(nI > 0)
            {
                NWNX_SQL_PrepareQuery("SELECT item_data FROM mail_attachments WHERE mail_id = ? ORDER BY attach_id ASC");
                NWNX_SQL_PreparedInt(1, nID);
                if(NWNX_SQL_ExecutePreparedQuery())
                {
                    while(NWNX_SQL_ReadyToReadNextRow())
                    {
                        NWNX_SQL_ReadNextRow();
                        object oI = NWNX_SQL_ReadFullObjectInActiveRow(0, oPC);
                        if(GetIsObjectValid(oI)) SendMessageToPC(oPC, "Retrieved: " + GetName(oI));
                    }
                }
                NWNX_SQL_DestroyPreparedQuery();
            }
            NWNX_SQL_PrepareQuery("UPDATE mail_messages SET is_claimed = 1, claimed_at = NOW() WHERE mail_id = ?");
            NWNX_SQL_PreparedInt(1, nID);
            NWNX_SQL_ExecutePreparedQuery();
            NWNX_SQL_DestroyPreparedQuery();
            nC++;
        }
    }
    NWNX_SQL_DestroyPreparedQuery();
    if(nC > 0) SendMessageToPC(oPC, "Claimed from " + IntToString(nC) + " messages.");
    else SendMessageToPC(oPC, "Nothing to claim.");
}

void DoDeleteMail(object oPC, int nID)
{
    string sCK = GetPCPublicCDKey(oPC);
    NWNX_SQL_PrepareQuery("DELETE FROM mail_messages WHERE mail_id = ? AND recipient_cdkey = ?");
    NWNX_SQL_PreparedInt(1, nID);
    NWNX_SQL_PreparedString(2, sCK);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();
    SendMessageToPC(oPC, "Mail #" + IntToString(nID) + " deleted.");
}

object FindPCByName(string sName)
{
    string sL = GetStringLowerCase(sName);
    object oP = GetFirstPC();
    while(GetIsObjectValid(oP))
    {
        if(FindSubString(GetStringLowerCase(GetName(oP)), sL) != -1)
            return oP;
        oP = GetNextPC();
    }
    return OBJECT_INVALID;
}

void DoSendMail(object oPC)
{
    string sR = GetLocalString(oPC, MAIL_RECIP);
    int nG = GetLocalInt(oPC, MAIL_GOLD);
    object oI = GetLocalObject(oPC, MAIL_ITEM);
    string sIN = GetLocalString(oPC, MAIL_ITEM_NAME);
    if(sR == "") { SendMessageToPC(oPC, "No recipient."); return; }
    if(!GetIsObjectValid(oI) && nG < 1) { SendMessageToPC(oPC, "Nothing to send."); return; }

    string sCK = GetPCPublicCDKey(oPC);
    string sRL = GetStringLowerCase(sR);
    object oR = OBJECT_INVALID;
    string sRCK = "";
    string sRCN = sR;

    oR = GetFirstPC();
    while(GetIsObjectValid(oR))
    {
        if(FindSubString(GetStringLowerCase(GetName(oR)), sRL) != -1)
        { sRCK = GetPCPublicCDKey(oR); sRCN = GetName(oR); break; }
        oR = GetNextPC();
    }
    if(sRCK == "")
    {
        NWNX_SQL_PrepareQuery("SELECT cdkey, charname FROM mail_registry WHERE LOWER(charname) LIKE ? ORDER BY last_seen DESC LIMIT 1");
        NWNX_SQL_PreparedString(1, "%" + sRL + "%");
        if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
        { NWNX_SQL_ReadNextRow(); sRCK = NWNX_SQL_ReadDataInActiveRow(0); sRCN = NWNX_SQL_ReadDataInActiveRow(1); }
        NWNX_SQL_DestroyPreparedQuery();
    }
    if(sRCK == "" || sRCK == sCK)
    { SendMessageToPC(oPC, "Cannot find that player."); return; }

    int nHI = GetIsObjectValid(oI) ? 1 : 0;
    string sSub = "Delivery";
    if(nG > 0 && nHI > 0) sSub = "Item + " + IntToString(nG) + "g";
    else if(nG > 0) sSub = IntToString(nG) + " gold";
    else sSub = "Item: " + sIN;

    NWNX_SQL_PrepareQuery("INSERT INTO mail_messages (sender_cdkey, sender_charname, recipient_cdkey, recipient_charname, subject, body, gold_amount, item_count, sent_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())");
    NWNX_SQL_PreparedString(1, sCK);
    NWNX_SQL_PreparedString(2, GetName(oPC));
    NWNX_SQL_PreparedString(3, sRCK);
    NWNX_SQL_PreparedString(4, sRCN);
    NWNX_SQL_PreparedString(5, sSub);
    NWNX_SQL_PreparedString(6, "");
    NWNX_SQL_PreparedInt(7, nG);
    NWNX_SQL_PreparedInt(8, nHI);
    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    if(GetIsObjectValid(oI))
    {
        NWNX_SQL_PrepareQuery("SELECT MAX(mail_id) FROM mail_messages WHERE sender_cdkey = ?");
        NWNX_SQL_PreparedString(1, sCK);
        if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nMID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            NWNX_SQL_DestroyPreparedQuery();
            if(nMID > 0)
            {
                NWNX_SQL_PrepareQuery("INSERT INTO mail_attachments (mail_id, item_data, item_tag, slot_number) VALUES (?, ?, ?, 0)");
                NWNX_SQL_PreparedInt(1, nMID);
                NWNX_SQL_PreparedObjectFull(2, oI);
                NWNX_SQL_PreparedString(3, GetTag(oI));
                NWNX_SQL_ExecutePreparedQuery();
                NWNX_SQL_DestroyPreparedQuery();
            }
        }
        else NWNX_SQL_DestroyPreparedQuery();
        DestroyObject(oI);
    }
    if(nG > 0) TakeGoldFromCreature(nG, oPC);

    oR = FindPCByName(sR);
    if(GetIsObjectValid(oR)) SendMessageToPC(oR, "New mail from " + GetName(oPC) + "! Visit a mailbox.");

    SendMessageToPC(oPC, "Sent to " + sRCN + "!");
    DeleteLocalString(oPC, MAIL_RECIP);
    DeleteLocalInt(oPC, MAIL_GOLD);
    DeleteLocalObject(oPC, MAIL_ITEM);
    DeleteLocalString(oPC, MAIL_ITEM_NAME);
}

void ClearState(object oPC)
{
    DeleteLocalString(oPC, MAIL_RECIP);
    DeleteLocalInt(oPC, MAIL_GOLD);
    DeleteLocalObject(oPC, MAIL_ITEM);
    DeleteLocalString(oPC, MAIL_ITEM_NAME);
    DeleteLocalString(oPC, MAIL_AWAIT);
    DeleteLocalString(oPC, MAIL_PAGE);
}

void main()
{
    object oPC = GetPcDlgSpeaker();
    if(oPC == OBJECT_INVALID) return;

    int nEvent = GetDlgEventType();
    string sPage = GetDlgPageString();

    if(nEvent == DLG_INIT)
    {
        string sR = GetLocalString(oPC, MAIL_RECIP);
        object oI = GetLocalObject(oPC, MAIL_ITEM);
        int nG = GetLocalInt(oPC, MAIL_GOLD);
        if(sR != "" || GetIsObjectValid(oI) || nG > 0)
            ShowCompose(oPC);
        else
            ShowMenu(oPC);
    }
    else if(nEvent == DLG_PAGE_INIT)
    {
    }
    else if(nEvent == DLG_SELECTION)
    {
        int nSel = GetDlgSelection();

        if(sPage == PAGE_MENU)
        {
            if(nSel == 0) ShowMailList(oPC);
            else if(nSel == 1) ShowItemPick(oPC);
            else if(nSel == 2)
            {
                string sT = GetStringElement(2, "mbox_mnu", oPC);
                if(FindSubString(sT, "Claim") != -1) { DoClaimAll(oPC); ShowMenu(oPC); }
                else EndDlg();
            }
            else EndDlg();
        }
        else if(sPage == PAGE_READ_LIST)
        {
            int nID = GetIntElement(nSel, "mbox_ml_ids", oPC);
            if(nID == -1) ShowMenu(oPC);
            else ShowReadMail(oPC, nID);
        }
        else if(sPage == PAGE_READ_MSG)
        {
            int nID = GetDlgPageInt();
            int nA = GetIntElement(nSel, "mbox_ract_ids", oPC);
            if(nA == -1) ShowMailList(oPC);
            else if(nA == -2) { DoClaimMail(oPC, nID); ShowReadMail(oPC, nID); }
            else if(nA == -3) { DoDeleteMail(oPC, nID); ShowMailList(oPC); }
            else ShowMenu(oPC);
        }
        else if(sPage == PAGE_ITEM_PICK)
        {
            object oSel = GetObjectElement(nSel, "mbox_ip_ob", oPC);
            if(!GetIsObjectValid(oSel)) { ShowMenu(oPC); }
            else
            {
                SetLocalObject(oPC, MAIL_ITEM, oSel);
                SetLocalString(oPC, MAIL_ITEM_NAME, GetName(oSel));
                ShowCompose(oPC);
            }
        }
        else if(sPage == PAGE_COMPOSE)
        {
            int nA = GetIntElement(nSel, "mbox_cp_ids", oPC);
            if(nA == 0) SetAwait(oPC, "recipient name", PAGE_COMPOSE);
            else if(nA == 1) ShowItemPick(oPC);
            else if(nA == 2) SetAwait(oPC, "gold amount", PAGE_COMPOSE);
            else if(nA == 3) { DoSendMail(oPC); ShowMenu(oPC); }
            else { ClearState(oPC); ShowMenu(oPC); }
        }
        else if(sPage == PAGE_AWAIT)
        {
            EndDlg();
        }
    }
    else if(nEvent == DLG_END || nEvent == DLG_ABORT)
    {
    }
}
