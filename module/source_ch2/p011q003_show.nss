int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p011state_Lethsla") >= 1;
	return nShow;
}
