#include "x2_inc_switches"

void main()
{
    SetModuleSwitch(MODULE_SWITCH_ENABLE_UMD_SCROLLS,!GetModuleSwitchValue(MODULE_SWITCH_ENABLE_UMD_SCROLLS));
}
