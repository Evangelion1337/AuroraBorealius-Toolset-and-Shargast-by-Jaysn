#include "nw_i0_plotwizard"
void main()
{
	object oItemToTake = GetItemPossessedBy(GetPCSpeaker(), "SkullofanUrMensch");
	DestroyObject(oItemToTake);
	CreateItemOnObject("amuletofgoodfait", GetPCSpeaker());
	GiveGoldToCreature(GetPCSpeaker(), 22500);
	PWSetMinLocalIntPartyPCSpeaker("p012state_Clantianu", 3);
	PWSetMinLocalIntPartyPCSpeaker("p012state", 3);
	PWGiveExperienceParty(GetPCSpeaker(), 2500);
}
