#include "nwnx"
#include "nwnx_sql"

void main()
{
    object oPC = GetExitingObject();
    if(GetIsPC(oPC) && !GetIsDM(oPC))
    {
        string sCDKey = GetPCPublicCDKey(oPC);
        string sName = GetName(oPC);
        int nLevel = GetHitDice(oPC);
        int nXP = GetXP(oPC);

        NWNX_SQL_PrepareQuery("UPDATE char_backup SET charname=?,level=?,xp=?,last_logout=NOW(),bic_data=? WHERE cdkey=? AND charname=?");
        NWNX_SQL_PreparedString(1, sName);
        NWNX_SQL_PreparedInt(2, nLevel);
        NWNX_SQL_PreparedInt(3, nXP);
        NWNX_SQL_PreparedObjectFull(4, oPC);
        NWNX_SQL_PreparedString(5, sCDKey);
        NWNX_SQL_PreparedString(6, sName);
        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();
    }

    ExecuteScript("prc_onleave", OBJECT_SELF);
}
