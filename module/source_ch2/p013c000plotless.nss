int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p013began") && !GetLocalInt(GetPCSpeaker(), "p013state");
}
