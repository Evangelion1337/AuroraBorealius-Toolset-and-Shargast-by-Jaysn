int StartingConditional()
{
	int nShow = OBJECT_INVALID != GetItemPossessedBy(GetPCSpeaker(), "BranchfromtheTreeofLifesEssence");
	return nShow;
}
