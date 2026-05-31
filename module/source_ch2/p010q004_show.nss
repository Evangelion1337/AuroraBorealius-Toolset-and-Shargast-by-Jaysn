#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p010state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p010state_Carrupt", 4);
		PWSetMinLocalIntPartyPCSpeaker("p010state", 4);
	}
	return nShow;
}
