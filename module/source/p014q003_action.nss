#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "AVillianess");
	DestroyObject(oItemToTake);
	CreateItemOnObject("shipperitehallke", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 250);
	PWSetMinLocalIntPartyPCSpeaker("p014state_BrandyLongfoot", 3);
	PWSetMinLocalIntPartyPCSpeaker("p014state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 350);
}
