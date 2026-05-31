#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "EssenceofAlendor");
	DestroyObject(oItemToTake);
	CreateItemOnObject("mithralshirt", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 20000);
	PWSetMinLocalIntPartyPCSpeaker("p004state_Melomar", 12);
	PWSetMinLocalIntPartyPCSpeaker("p004state", 12);
	PWGiveExperienceParty(GetPCSpeaker(), 4200);
}
