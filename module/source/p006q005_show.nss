#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p006state") >= 4;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p006state_Mathew", 5);
		PWSetMinLocalIntPartyPCSpeaker("p006state", 5);
		AddJournalQuestEntry("p006", 5, GetPCSpeaker(), TRUE, FALSE, FALSE);
	}
	return nShow;
}
