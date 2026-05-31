#include "zdlg_include_i"
#include "nwnx"
#include "nwnx_sql"

const string MAIL_RECIP = "ZEP_MAIL_RECIP";
const string MAIL_GOLD = "ZEP_MAIL_GOLD";
const string MAIL_ITEM = "ZEP_MAIL_ITEM";
const string MAIL_ITEM_NAME = "ZEP_MAIL_ITEM_NAME";
const string MAIL_AWAIT = "ZEP_MAIL_AWAIT";
const string MAIL_PAGE = "ZEP_MAIL_PAGE";

void InitMailTables()
{
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS mail_messages (mail_id INT AUTO_INCREMENT PRIMARY KEY, sender_cdkey VARCHAR(64) NOT NULL, sender_charname VARCHAR(64) NOT NULL, recipient_cdkey VARCHAR(64) NOT NULL, recipient_charname VARCHAR(64) NOT NULL, subject VARCHAR(128) NOT NULL DEFAULT '', body TEXT NOT NULL, gold_amount INT NOT NULL DEFAULT 0, item_count INT NOT NULL DEFAULT 0, sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, expires_at DATETIME, is_read TINYINT(1) NOT NULL DEFAULT 0, is_claimed TINYINT(1) NOT NULL DEFAULT 0, claimed_at DATETIME, INDEX idx_recipient (recipient_cdkey), INDEX idx_sender (sender_cdkey), INDEX idx_sent (sent_at))");
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS mail_attachments (attach_id INT AUTO_INCREMENT PRIMARY KEY, mail_id INT NOT NULL, item_data LONGBLOB NOT NULL, item_tag VARCHAR(64) NOT NULL DEFAULT '', slot_number INT NOT NULL DEFAULT 0, FOREIGN KEY (mail_id) REFERENCES mail_messages(mail_id) ON DELETE CASCADE)");
    NWNX_SQL_ExecuteQuery("CREATE TABLE IF NOT EXISTS mail_registry (cdkey VARCHAR(64) NOT NULL, charname VARCHAR(64) NOT NULL, last_seen DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (cdkey, charname))");
}

void main()
{
    object oPC = GetLastUsedBy();
    if(!GetIsPC(oPC) || GetIsDM(oPC)) return;

    InitMailTables();

    string sAwait = GetLocalString(oPC, MAIL_AWAIT);
    if(sAwait != "")
    {
        SendMessageToPC(oPC, "Mailbox: Type the " + sAwait + " in chat and press Enter. Or type /mb cancel to abort.");
        return;
    }


    StartDlg(oPC, OBJECT_SELF, "zep_mail_dlg_h");
}
