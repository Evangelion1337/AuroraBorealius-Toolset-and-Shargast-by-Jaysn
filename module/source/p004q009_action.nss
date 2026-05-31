#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "RawGemofPower");
	DestroyObject(oItemToTake);
	CreateItemOnObject("ringofforgesburn", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 15000);
	PWSetMinLocalIntPartyPCSpeaker("p004state_Melomar", 9);
	PWSetMinLocalIntPartyPCSpeaker("p004state", 9);
	PWGiveExperienceParty(GetPCSpeaker(), 2200);
}
