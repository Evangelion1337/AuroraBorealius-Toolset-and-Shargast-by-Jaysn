int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p015state_ct_PlotGiver_Asn") >= 1;
	return nShow;
}
