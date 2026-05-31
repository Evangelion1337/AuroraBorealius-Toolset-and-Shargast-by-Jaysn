// -----------------------------------------------------------------------------
//  MAIN - Example OnUsed of placeable script
// -----------------------------------------------------------------------------
#include "se_inc_pc_loc"
void main()
{
    object oPC = GetLastUsedBy();
    SE_SaveLocation(oPC);
    ExecuteScript("x2_plc_used_act", OBJECT_SELF);
}
