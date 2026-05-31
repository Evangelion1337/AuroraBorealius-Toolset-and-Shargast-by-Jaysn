#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p011state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p011state_Lethsla", 4);
		PWSetMinLocalIntPartyPCSpeaker("p011state", 4);
	}
	return nShow;
}
