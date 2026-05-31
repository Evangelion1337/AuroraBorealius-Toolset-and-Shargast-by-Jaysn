int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p003began") && !GetLocalInt(GetPCSpeaker(), "p003state");
}
