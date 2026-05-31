int StartingConditional()
{
	int nShow = GetLocalInt(GetPCSpeaker(), "p014state_BrandyLongfoot") >= 1;
	return nShow;
}
