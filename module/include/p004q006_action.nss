#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "MithralStar");
	DestroyObject(oItemToTake);
	CreateItemOnObject("gaunletsofdwarve", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 7500);
	PWSetMinLocalIntPartyPCSpeaker("p004state_Melomar", 6);
	PWSetMinLocalIntPartyPCSpeaker("p004state", 6);
	PWGiveExperienceParty(GetPCSpeaker(), 2000);
}
