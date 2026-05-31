int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p012state") >= 2;
	return nShow;
}
