int StartingConditional()
{
  if (GetLocalString(OBJECT_SELF, "Message") != "") {
    return TRUE;
  }
  return FALSE;
}
