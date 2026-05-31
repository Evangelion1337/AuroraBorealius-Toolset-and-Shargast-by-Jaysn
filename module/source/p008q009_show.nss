int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state_Pathanie") >= 8;
	return nShow;
}
