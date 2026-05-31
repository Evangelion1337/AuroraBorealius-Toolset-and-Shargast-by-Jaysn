int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p002began") && !GetLocalInt(GetPCSpeaker(), "p002state");
}
