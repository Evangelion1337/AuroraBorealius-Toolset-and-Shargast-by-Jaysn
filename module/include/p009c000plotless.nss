int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p009began") && !GetLocalInt(GetPCSpeaker(), "p009state");
}
