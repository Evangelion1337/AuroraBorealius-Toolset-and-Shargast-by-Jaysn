int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p010began") && !GetLocalInt(GetPCSpeaker(), "p010state");
}
