#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p005state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p005state_Suli", 4);
		PWSetMinLocalIntPartyPCSpeaker("p005state", 4);
	}
	return nShow;
}
