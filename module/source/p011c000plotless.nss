int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p011began") && !GetLocalInt(GetPCSpeaker(), "p011state");
}
