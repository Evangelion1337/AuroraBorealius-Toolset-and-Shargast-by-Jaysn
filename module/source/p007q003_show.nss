int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p007state_Maria") >= 1;
	return nShow;
}
