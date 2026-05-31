#include "nw_i0_plotwizard"
int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state_HasereththeHighClericofSchilling") >= 16;
	if (nShow)
	{
		PWSetMinLocalIntPartyPCSpeaker("p008state_HasereththeHighClericofSchilling", 17);
		PWSetMinLocalIntPartyPCSpeaker("p008state", 17);
		AddJournalQuestEntry("p008", 17, GetPCSpeaker(), TRUE, FALSE, FALSE);
	}
	return nShow;
}
