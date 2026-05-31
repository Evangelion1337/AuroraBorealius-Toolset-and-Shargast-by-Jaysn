int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p007began") && !GetLocalInt(GetPCSpeaker(), "p007state");
}
