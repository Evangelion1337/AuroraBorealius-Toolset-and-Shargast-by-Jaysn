#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state_Pathanie") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p008state_Pathanie", 4);
		PWSetMinLocalIntPartyPCSpeaker("p008state", 4);
	}
	return nShow;
}
