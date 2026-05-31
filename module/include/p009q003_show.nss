int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p009state") >= 2;
	return nShow;
}
