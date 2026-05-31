#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "Earthwood");
	DestroyObject(oItemToTake);
	CreateItemOnObject("helmofhonour", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 2500);
	PWSetMinLocalIntPartyPCSpeaker("p004state_Melomar", 3);
	PWSetMinLocalIntPartyPCSpeaker("p004state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 1500);
}
