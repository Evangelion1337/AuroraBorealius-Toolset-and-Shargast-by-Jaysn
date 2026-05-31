#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "SchillingersTear");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 50000);
	PWSetMinLocalIntPartyPCSpeaker("p008state_Pathanie", 7);
	PWSetMinLocalIntPartyPCSpeaker("p008state", 7);
	PWGiveExperienceParty(GetPCSpeaker(), 5225);
}
