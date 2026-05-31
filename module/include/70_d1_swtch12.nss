#include "x2_inc_switches"

void main()
{
    SetModuleSwitch(MODULE_VAR_AI_STOP_EXPERTISE_ABUSE,!GetModuleSwitchValue(MODULE_VAR_AI_STOP_EXPERTISE_ABUSE));
}
