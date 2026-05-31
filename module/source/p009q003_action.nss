#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "BareschFamilyHierloom");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 550);
	PWSetMinLocalIntPartyPCSpeaker("p009state_Dram", 3);
	PWSetMinLocalIntPartyPCSpeaker("p009state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 450);
}
