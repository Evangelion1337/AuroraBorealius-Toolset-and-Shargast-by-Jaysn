int StartingConditional()
{
  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");
  object oItem = GetItemInSlot( iSlot, oPlayer);
  int iItemType = GetBaseItemType( oItem);

  if( (iItemType == BASE_ITEM_LARGESHIELD) || (iItemType == BASE_ITEM_SMALLSHIELD) || (iItemType == BASE_ITEM_TOWERSHIELD))
    return FALSE;
  else
    return TRUE;
}
