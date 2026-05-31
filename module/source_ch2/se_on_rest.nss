// -----------------------------------------------------------------------------
//  MAIN - Example OnPlayerRest script
// -----------------------------------------------------------------------------
#include "se_inc_pc_loc"
void main()
{
    object oPC = GetLastPCRested();
    if(GetLastRestEventType() == REST_EVENTTYPE_REST_STARTED)
       SE_SaveLocation(oPC);
    ExecuteScript("x2_mod_def_rest", oPC);
}
