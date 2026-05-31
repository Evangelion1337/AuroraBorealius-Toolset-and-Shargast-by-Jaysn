#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p003state_Will") >= 3;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p003state_Will", 4);
		PWSetMinLocalIntPartyPCSpeaker("p003state", 4);
	}
	return nShow;
}
