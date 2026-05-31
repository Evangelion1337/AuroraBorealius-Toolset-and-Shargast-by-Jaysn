int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p005state_Suli") >= 1;
	return nShow;
}
