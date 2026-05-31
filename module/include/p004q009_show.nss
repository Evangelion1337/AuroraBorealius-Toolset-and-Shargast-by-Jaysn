int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p004state") >= 8;
	return nShow;
}
