int StartingConditional()
{
	return GetLocalInt(OBJECT_SELF, "p015began") && !GetLocalInt(GetPCSpeaker(), "p015state");
}
