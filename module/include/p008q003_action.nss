#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "BranchfromtheTreeofLifesEssence");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 50000);
	PWSetMinLocalIntPartyPCSpeaker("p008state_Pathanie", 3);
	PWSetMinLocalIntPartyPCSpeaker("p008state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 4250);
}
