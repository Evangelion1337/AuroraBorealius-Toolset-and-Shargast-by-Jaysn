#include "x2_inc_switches"

void main()
{
    SetModuleSwitch("71_ALLOW_BOOST_GLOVES",!GetModuleSwitchValue("71_ALLOW_BOOST_GLOVES"));
}
