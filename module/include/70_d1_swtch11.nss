#include "x2_inc_switches"

void main()
{
    SetModuleSwitch(MODULE_SWITCH_ENABLE_CRAFT_WAND_50_CHARGES,!GetModuleSwitchValue(MODULE_SWITCH_ENABLE_CRAFT_WAND_50_CHARGES));
}
