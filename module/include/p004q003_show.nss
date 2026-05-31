int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p004state_Melomar") >= 1;
	return nShow;
}
