#include "nw_i0_plotwizard"
void main()
{
	PWSetMinLocalIntPartyPCSpeaker("p006state_Birk", 2);
	PWSetMinLocalIntPartyPCSpeaker("p006state", 2);
	PWGiveExperienceParty(GetPCSpeaker(), 50);
}
