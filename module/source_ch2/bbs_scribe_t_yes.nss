int StartingConditional()
{
  if (GetLocalString(OBJECT_SELF, "Title") != "") {
    return TRUE;
  }
  return FALSE;
}
