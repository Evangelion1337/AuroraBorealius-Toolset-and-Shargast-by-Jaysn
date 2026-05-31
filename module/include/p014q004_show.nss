#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p014state") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p014state_BrandyLongfoot", 4);
		PWSetMinLocalIntPartyPCSpeaker("p014state", 4);
	}
	return nShow;
}
