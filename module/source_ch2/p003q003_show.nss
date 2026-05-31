int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p003state") >= 2;
	return nShow;
}
