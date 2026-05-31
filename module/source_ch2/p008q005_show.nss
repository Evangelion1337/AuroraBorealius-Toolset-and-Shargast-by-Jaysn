#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state_Pathanie") >= 4;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p008state_Pathanie", 5);
		PWSetMinLocalIntPartyPCSpeaker("p008state", 5);
		AddJournalQuestEntry("p008", 5, GetPCSpeaker(), TRUE, FALSE, FALSE);
	}
	return nShow;
}
