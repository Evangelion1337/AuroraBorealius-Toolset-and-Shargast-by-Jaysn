#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "SymbolofShipper");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 780);
	PWSetMinLocalIntPartyPCSpeaker("p010state_Carrupt", 3);
	PWSetMinLocalIntPartyPCSpeaker("p010state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 750);
}
