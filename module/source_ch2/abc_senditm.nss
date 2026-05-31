#include "nwnx"
#include "nwnx_sql"
#include "nwnx_object"
#include "sv_core"

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

void CreateMailAttachment(object oItem, int nMailID, int nSlot)
{
    if(GetIsObjectValid(oItem))
    {
        string sSerialized = NWNX_Object_Serialize(oItem);

        NWNX_SQL_PrepareQuery("INSERT INTO mail_attachments (mail_id, item_data, item_tag, slot_number) VALUES (?, ?, ?, ?)");
        NWNX_SQL_PreparedInt(1, nMailID);
        NWNX_SQL_PreparedString(2, sSerialized);
        NWNX_SQL_PreparedString(3, GetTag(oItem));
        NWNX_SQL_PreparedInt(4, nSlot);

        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();
    }
}

void main ()
{
    object oChest = OBJECT_SELF;

    // EXPLOIT FIX 1: Check if this chest is already processing a transaction.
    // This prevents double-triggering or reopening abuse.
    if (GetLocalInt(oChest, "TRANSACTION_LOCKED") == 1) return;

    // Set the concurrency lock instantly
    SetLocalInt(oChest, "TRANSACTION_LOCKED", 1);

    // EXPLOIT FIX 2: Permanently lock and strip useable flags from the chest mesh.
    // If a player tries to click the invisible chest space right now, the engine rejects it.
    SetLocked(oChest, TRUE);
    SetLockLockable(oChest, FALSE);
    SetUseableFlag(oChest, FALSE);

    object oPC          = GetLocalObject(oChest, "oPC");
    string sSenderCDKey = GetLocalString(oChest, "sSenderCDKey");
    string sSenderName  = GetLocalString(oChest, "sSenderName");
    string sRecipCDKey  = GetLocalString(oChest, "sRecipCDKey");
    string sRecipName   = GetLocalString(oChest, "sRecipName");
    string sTitle       = GetLocalString(oChest, "sTitle");
    string sBody        = GetLocalString(oChest, "sBody");
    int nGold           = GetLocalInt(oChest, "nGold");

    int numOfItems = 0;
    if (GetHasInventory(oChest))
    {
        object oItemCheck = GetFirstItemInInventory(oChest);
        while (GetIsObjectValid(oItemCheck))
        {
            numOfItems++;
            oItemCheck = GetNextItemInInventory(oChest);
        }
    }

    // Safety fallback: If they closed an empty box, unlock it so they can try again or clear it
    if (numOfItems < 1)
    {
        SendMessageToPC(oPC, "System Message: Connection canceled. There are no items inside the chest to send.");
        SetUseableFlag(oChest, TRUE);
        SetLocked(oChest, FALSE);
        DeleteLocalInt(oChest, "TRANSACTION_LOCKED");
        return;
    }

    string text = (numOfItems > 1) ? " Items" : " Item";
    string sSubjectLine = "Parcel: " + IntToString(numOfItems) + text + " - " + sTitle;

    string sMsgQuery =
        "INSERT INTO mail_messages (" +
        "sender_cdkey, sender_charname, recipient_cdkey, recipient_charname, " +
        "subject, body, gold_amount, item_count, sent_at" +
        ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";

    NWNX_SQL_PrepareQuery(sMsgQuery);
    NWNX_SQL_PreparedString(1, sSenderCDKey);
    NWNX_SQL_PreparedString(2, sSenderName);
    NWNX_SQL_PreparedString(3, sRecipCDKey);
    NWNX_SQL_PreparedString(4, sRecipName);
    NWNX_SQL_PreparedString(5, sSubjectLine);
    NWNX_SQL_PreparedString(6, sBody);
    NWNX_SQL_PreparedInt(7, nGold);
    NWNX_SQL_PreparedInt(8, numOfItems);

    NWNX_SQL_ExecutePreparedQuery();
    NWNX_SQL_DestroyPreparedQuery();

    if (GetHasInventory(oChest))
    {
        object oItem = GetFirstItemInInventory(oChest);


        int nMailID = 0;
        NWNX_SQL_PrepareQuery("SELECT MAX(mail_id) FROM mail_messages WHERE sender_cdkey = ?");
        NWNX_SQL_PreparedString(1, sSenderCDKey);
        if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            nMailID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        }
        NWNX_SQL_DestroyPreparedQuery();
        if(nMailID > 0)
        {
            int currentSlot = 1;
            while (GetIsObjectValid(oItem))
            {
                CreateMailAttachment(oItem, nMailID, currentSlot);
                // Item is safely stored in database, vaporize it from the game world
                DestroyObject(oItem);
                SendMessageToPC(oPC, "Sent " + GetName(oItem));

                oItem = GetNextItemInInventory(oChest);
                currentSlot++;
            }
        }
    }

    object oOnlineRecipient = FindPCByName(sRecipName);
    SendMessageToPC(oPC, "Mail sent successfully to " + sRecipName + ".");

    if(GetIsObjectValid(oOnlineRecipient))
    {
        SendMessageToPC(oOnlineRecipient, "New mail from " + sSenderName + "! Type /mail inbox to read it.");
    }

    // Completely destroy the chest object so it doesn't linger in memory
    DestroyObject(oChest);
}

