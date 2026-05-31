
int StartingConditional()
{
  object oPlayer = GetPCSpeaker();
  object oItem = GetItemInSlot( INVENTORY_SLOT_LEFTHAND, oPlayer);
  int iItemtype = GetBaseItemType( oItem);

  //shields
  if( iItemtype == BASE_ITEM_LARGESHIELD ||
      iItemtype == BASE_ITEM_SMALLSHIELD ||
      iItemtype == BASE_ITEM_TOWERSHIELD)
  {
    return TRUE;
  }

  return FALSE;
}
