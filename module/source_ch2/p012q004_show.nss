#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p012state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p012state_Clantianu", 4);
		PWSetMinLocalIntPartyPCSpeaker("p012state", 4);
	}
	return nShow;
}
