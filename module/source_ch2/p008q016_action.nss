#include "nw_i0_plotwizard"
void main()
{
	GiveGoldToCreature(GetPCSpeaker(), 65000);
	PWSetMinLocalIntPartyPCSpeaker("p008state_HasereththeHighClericofSchilling", 16);
	PWSetMinLocalIntPartyPCSpeaker("p008state", 16);
	PWGiveExperienceParty(GetPCSpeaker(), 12000);
}
