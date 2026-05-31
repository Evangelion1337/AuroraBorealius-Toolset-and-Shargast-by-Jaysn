#include "nw_i0_plotwizard"
void main()
{
	SetLocalInt(OBJECT_SELF, "p009began", 1);
	PWSetMinLocalIntPartyPCSpeaker("p009state_Dram", 1);
	PWSetMinLocalIntPartyPCSpeaker("p009state", 1);
}
