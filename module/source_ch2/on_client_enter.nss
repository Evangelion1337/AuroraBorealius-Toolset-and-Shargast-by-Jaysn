// Goes in the module OnClientEnter event - Example for v1.5
#include "se_new_player"
void main()
{
  object oPC = GetEnteringObject();
  SirElrics_SimplePlayerSetUp(oPC);
}
