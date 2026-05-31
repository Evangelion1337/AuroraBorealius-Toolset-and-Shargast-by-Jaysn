#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "VillainHead");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 950);
	PWSetMinLocalIntPartyPCSpeaker("p002state_Beloruse", 3);
	PWSetMinLocalIntPartyPCSpeaker("p002state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 650);
}
