int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state") >= 10;
	return nShow;
}
