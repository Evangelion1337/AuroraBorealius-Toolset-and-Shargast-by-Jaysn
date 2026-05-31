#include "x2_inc_switches"

void main()
{
    SetModuleSwitch("71_ALLOW_POISON_STACKING",!GetModuleSwitchValue("71_ALLOW_POISON_STACKING"));
}
