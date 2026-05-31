int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p004state") >= 5;
	return nShow;
}
