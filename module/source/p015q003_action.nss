#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "EssenceofHernathiusBloodclaw");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 50000);
	PWSetMinLocalIntPartyPCSpeaker("p015state_ct_PlotGiver_Asn", 3);
	PWSetMinLocalIntPartyPCSpeaker("p015state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 9500);
}
