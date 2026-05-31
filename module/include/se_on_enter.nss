// -----------------------------------------------------------------------------
//  MAIN - Example OnClientEnter script
// -----------------------------------------------------------------------------
#include "se_inc_pc_loc"
void main()
{
    object oPC = GetEnteringObject();
    if(GetLocalInt(oPC, "ENTERED") == FALSE)
       SE_PersistantPCLocation(oPC);
}
