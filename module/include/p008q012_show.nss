#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state_Pathanie") >= 11;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p008state_Pathanie", 12);
		PWSetMinLocalIntPartyPCSpeaker("p008state", 12);
		AddJournalQuestEntry("p008", 12, GetPCSpeaker(), TRUE, FALSE, FALSE);
	}
	return nShow;
}
