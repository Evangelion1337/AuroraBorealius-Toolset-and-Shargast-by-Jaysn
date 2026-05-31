#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "TheheartofDarkness");
	DestroyObject(oItemToTake);
	GiveGoldToCreature(GetPCSpeaker(), 7500);
	PWSetMinLocalIntPartyPCSpeaker("p011state_Lethsla", 3);
	PWSetMinLocalIntPartyPCSpeaker("p011state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 2500);
	{
{

object oPC = GetPCSpeaker();

AdjustAlignment(oPC, ALIGNMENT_GOOD, 30);

}
	}
}
