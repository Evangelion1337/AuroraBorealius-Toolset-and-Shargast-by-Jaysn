#include "nw_i0_plotwizard"
void main()
{
	CreateItemOnObject("thestaffofleg001", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 65000);
	PWSetMinLocalIntPartyPCSpeaker("p008state_HasereththeHighClericofSchilling", 14);
	PWSetMinLocalIntPartyPCSpeaker("p008state", 14);
}
