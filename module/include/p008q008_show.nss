#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state_Pathanie") >= 7;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p008state_Pathanie", 8);
		PWSetMinLocalIntPartyPCSpeaker("p008state", 8);
	}
	return nShow;
}
