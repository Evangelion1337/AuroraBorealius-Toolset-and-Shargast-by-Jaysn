int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p004state_Melomar") >= 3;
	return nShow;
}
