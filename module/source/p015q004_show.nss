#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p015state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p015state_ct_PlotGiver_Asn", 4);
		PWSetMinLocalIntPartyPCSpeaker("p015state", 4);
	}
	return nShow;
}
