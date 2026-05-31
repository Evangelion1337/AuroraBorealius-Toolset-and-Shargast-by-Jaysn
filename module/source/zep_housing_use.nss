#include "zdlg_include_i"
#include "nwnx"
#include "nwnx_sql"
#include "housing_db"

void main()
{
    object oPC = GetLastUsedBy();
    if(!GetIsPC(oPC) || GetIsDM(oPC)) return;

    InitHousingDB();
    StartDlg(oPC, OBJECT_SELF, "zep_hous_dlg_h");
}
