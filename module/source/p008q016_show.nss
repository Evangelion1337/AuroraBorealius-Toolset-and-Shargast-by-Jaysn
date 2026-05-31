int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state") >= 15;
	return nShow;
}
