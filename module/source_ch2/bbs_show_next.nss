int StartingConditional()
{
  object oBBS = GetLocalObject(GetModule(), "BBS_" + GetTag(OBJECT_SELF));
  int PageSize = GetLocalInt(oBBS, "PageSize");
  int PageIndex = GetLocalInt(oBBS, "PageIndex");
  int TotalItems = GetLocalInt(oBBS, "TotalItems");
  if (TotalItems > (PageIndex + 1) * PageSize) {
    return TRUE;
  }
  return FALSE;
}
