#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "Mithral");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 20000);
	PWSetMinLocalIntPartyPCSpeaker("p005state_Suli", 3);
	PWSetMinLocalIntPartyPCSpeaker("p005state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 1625);
}
