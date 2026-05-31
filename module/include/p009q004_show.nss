#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p009state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p009state_Dram", 4);
		PWSetMinLocalIntPartyPCSpeaker("p009state", 4);
	}
	return nShow;
}
