int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p004state") >= 11;
	return nShow;
}
