#include "x2_inc_switches"

void main()
{
    SetModuleSwitch("70_AOE_IGNORE_SPELL_RESISTANCE",!GetModuleSwitchValue("70_AOE_IGNORE_SPELL_RESISTANCE"));
}
