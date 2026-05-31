#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p004state_Melomar") >= 12;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p004state_Melomar", 13);
		PWSetMinLocalIntPartyPCSpeaker("p004state", 13);
		AddJournalQuestEntry("p004", 13, GetPCSpeaker(), TRUE, FALSE, FALSE);
	}
	return nShow;
}
