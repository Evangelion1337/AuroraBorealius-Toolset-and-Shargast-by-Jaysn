#include "nw_i0_plotwizard"
void main()
{
	SetLocalInt(OBJECT_SELF, "p015began", 1);
	PWSetMinLocalIntPartyPCSpeaker("p015state_ct_PlotGiver_Asn", 1);
	PWSetMinLocalIntPartyPCSpeaker("p015state", 1);
}
