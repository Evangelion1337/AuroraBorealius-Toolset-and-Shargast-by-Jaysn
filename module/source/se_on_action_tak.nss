// -----------------------------------------------------------------------------
//  MAIN - Example OnActionTaken of NPC script
// -----------------------------------------------------------------------------
#include "se_inc_pc_loc"
void main()
{
    object oPC = GetPCSpeaker();
    SE_SaveLocation(oPC);
}
