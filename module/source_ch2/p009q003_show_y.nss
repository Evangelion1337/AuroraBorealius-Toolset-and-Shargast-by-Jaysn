int StartingConditional()
{
	int nShow = OBJECT_INVALID != GetItemPossessedBy(GetPCSpeaker(), "BareschFamilyHierloom");
	return nShow;
}
