// -----------------------------------------------------------------------------
//  MAIN - Example OnActivateItem script(tag of item must be se_on_activate)
// -----------------------------------------------------------------------------
#include "se_inc_pc_loc"
#include "x2_inc_switches"
void main()
{
    if(GetUserDefinedItemEventNumber() == X2_ITEM_EVENT_ACTIVATE)
       SE_SaveLocation(GetItemActivator());
}
