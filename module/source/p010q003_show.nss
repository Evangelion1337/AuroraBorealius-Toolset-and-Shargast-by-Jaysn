int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p010state") >= 2;
	return nShow;
}
