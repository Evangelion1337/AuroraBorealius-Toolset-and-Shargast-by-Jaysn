#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "GatewayGem");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 8500);
	PWSetMinLocalIntPartyPCSpeaker("p003state_Will", 3);
	PWSetMinLocalIntPartyPCSpeaker("p003state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 2000);
}
