#include "nw_i0_plotwizard"
void main()
{
	SetLocalInt(OBJECT_SELF, "p013began", 1);
	PWSetMinLocalIntPartyPCSpeaker("p013state_HobberTan", 1);
	PWSetMinLocalIntPartyPCSpeaker("p013state", 1);
}
