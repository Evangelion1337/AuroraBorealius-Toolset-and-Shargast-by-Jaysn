#include "nw_i0_plotwizard"
void main()
{
	AddJournalQuestEntry("p008", 15, GetLastKiller(), TRUE);
	PWSetMinLocalIntParty(GetLastKiller(), "p008state", 15);
}
