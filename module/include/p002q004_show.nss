#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p002state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p002state_Beloruse", 4);
		PWSetMinLocalIntPartyPCSpeaker("p002state", 4);
	}
	return nShow;
}
