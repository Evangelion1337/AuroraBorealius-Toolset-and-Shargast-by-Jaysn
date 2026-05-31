#include "nwnx"
#include "nwnx_sql"

void main()
{
    object oPC = GetExitingObject();
    if(GetIsPC(oPC) && !GetIsDM(oPC))
    {
        string sName = GetName(oPC);

        object oTarget = GetFirstPC();
        while (GetIsObjectValid(oTarget))
        {
            SendMessageToPC(oTarget, "*** " + sName + " has left the world of HOPE ***");
            oTarget = GetNextPC();
        }

        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();
    }

    ExecuteScript("prc_onleave", OBJECT_SELF);
}
