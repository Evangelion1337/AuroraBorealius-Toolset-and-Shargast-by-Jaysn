int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p006began") && !GetLocalInt(GetPCSpeaker(), "p006state");
}
