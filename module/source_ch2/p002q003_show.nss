int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p002state_Beloruse") >= 1;
	return nShow;
}
