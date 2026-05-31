#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p013state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p013state_HobberTan", 4);
		PWSetMinLocalIntPartyPCSpeaker("p013state", 4);
	}
	return nShow;
}
