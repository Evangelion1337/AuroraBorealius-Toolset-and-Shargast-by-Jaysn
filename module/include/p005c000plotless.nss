int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p005began") && !GetLocalInt(GetPCSpeaker(), "p005state");
}
