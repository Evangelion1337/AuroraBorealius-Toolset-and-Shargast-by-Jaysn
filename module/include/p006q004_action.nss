#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "BladeofEarthsSword");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 1000);
	PWSetMinLocalIntPartyPCSpeaker("p006state_Mathew", 4);
	PWSetMinLocalIntPartyPCSpeaker("p006state", 4);
	PWGiveExperienceParty(GetPCSpeaker(), 1000);
}
