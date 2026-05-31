#include "x2_inc_switches"

void main()
{
    SetModuleSwitch("71_RESTRICT_MUSICAL_INSTRUMENTS",!GetModuleSwitchValue("71_RESTRICT_MUSICAL_INSTRUMENTS"));
}
