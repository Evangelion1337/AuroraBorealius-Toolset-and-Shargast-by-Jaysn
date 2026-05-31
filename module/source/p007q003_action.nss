#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "BloodofKakorn");
	DestroyObject(oItemToTake);
	CreateItemOnObject("broachoffriends", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 1500);
	PWSetMinLocalIntPartyPCSpeaker("p007state_Maria", 3);
	PWSetMinLocalIntPartyPCSpeaker("p007state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 950);
}
