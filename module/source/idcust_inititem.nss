int StartingConditional()
{

  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");

  object oItem = GetItemInSlot( iSlot, oPlayer);
  SetCustomToken(5501, GetName( oItem));

  int iItemType = GetBaseItemType( oItem);
  SetLocalInt( OBJECT_SELF, "ItemType", iItemType);

  return TRUE;
}
