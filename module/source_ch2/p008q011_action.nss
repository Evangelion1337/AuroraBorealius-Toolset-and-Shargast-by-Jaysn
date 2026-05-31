#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "GessachersBrightness");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 65000);
	PWSetMinLocalIntPartyPCSpeaker("p008state_Pathanie", 11);
	PWSetMinLocalIntPartyPCSpeaker("p008state", 11);
	PWGiveExperienceParty(GetPCSpeaker(), 7225);
}
