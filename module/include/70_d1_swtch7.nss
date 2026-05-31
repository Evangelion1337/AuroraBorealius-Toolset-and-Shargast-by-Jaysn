#include "x2_inc_switches"

void main()
{
    SetModuleSwitch("70_AOE_HEARTBEAT_WORKAROUND",!GetModuleSwitchValue("70_AOE_HEARTBEAT_WORKAROUND"));
}
