int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p004state_Melomar") >= 6;
	return nShow;
}
