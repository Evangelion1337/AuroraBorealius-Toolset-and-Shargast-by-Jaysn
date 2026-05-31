int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p013state_HobberTan") >= 1;
	return nShow;
}
