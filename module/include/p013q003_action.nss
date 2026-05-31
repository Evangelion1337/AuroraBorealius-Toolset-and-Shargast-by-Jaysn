#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "Kingeethestolenchild");
	DestroyObject(oItemToTake);
	CreateItemOnObject("shipperitehall", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 150);
	PWSetMinLocalIntPartyPCSpeaker("p013state_HobberTan", 3);
	PWSetMinLocalIntPartyPCSpeaker("p013state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 250);
}
