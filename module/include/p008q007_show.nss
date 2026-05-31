int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state") >= 6;
	return nShow;
}
