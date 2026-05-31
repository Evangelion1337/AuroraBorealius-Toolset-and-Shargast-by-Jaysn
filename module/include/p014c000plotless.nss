int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p014began") && !GetLocalInt(GetPCSpeaker(), "p014state");
}
