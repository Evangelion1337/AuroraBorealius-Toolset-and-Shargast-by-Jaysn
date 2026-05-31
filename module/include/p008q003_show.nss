int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p008state_Pathanie") >= 1;
	return nShow;
}
