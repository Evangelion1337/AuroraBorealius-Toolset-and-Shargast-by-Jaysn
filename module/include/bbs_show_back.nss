int StartingConditional()
{
  object oBBS = GetLocalObject(GetModule(), "BBS_" + GetTag(OBJECT_SELF));
  int PageIndex = GetLocalInt(oBBS, "PageIndex");
  if (PageIndex == 0) {
    return FALSE;
  }
  return TRUE;
}
