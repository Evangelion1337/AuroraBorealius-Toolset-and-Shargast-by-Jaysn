int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p012began") && !GetLocalInt(GetPCSpeaker(), "p012state");
}
