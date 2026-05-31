int StartingConditional()
{
	int nShow = OBJECT_INVALID != GetItemPossessedBy(GetPCSpeaker(), "EssenceofHernathiusBloodclaw");
	return nShow;
}
