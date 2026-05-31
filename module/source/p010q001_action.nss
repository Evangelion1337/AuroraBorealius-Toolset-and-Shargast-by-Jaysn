#include "nw_i0_plotwizard"
void main()
{
	SetLocalInt(OBJECT_SELF, "p010began", 1);
	PWSetMinLocalIntPartyPCSpeaker("p010state_Carrupt", 1);
	PWSetMinLocalIntPartyPCSpeaker("p010state", 1);
}
