int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p004began") && !GetLocalInt(GetPCSpeaker(), "p004state");
}
