int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p008began") && !GetLocalInt(GetPCSpeaker(), "p008state");
}
