int GetNextBeltIndex( int iIndex)
{

  if( iIndex == 1)
    iIndex = 3;

  if( iIndex == 17)
    iIndex = 110;

  if( iIndex == 116)
    iIndex = 150;

  if( iIndex > 154)
    iIndex = 0;

  return iIndex;
}

void main()
{
  //First line of the item customization script
  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");
  object oItem = GetItemInSlot( iSlot, oPlayer);
  int iIndex = GetItemAppearance( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_BELT);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index before is: " + IntToString( iIndex));

  iIndex++;
  iIndex = GetNextBeltIndex( iIndex);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index after is: " + IntToString( iIndex));

  object oNewItem = CopyItemAndModify( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_BELT, iIndex, TRUE);

  if( GetIsObjectValid( oNewItem))
  {
    AssignCommand( oPlayer, ActionEquipItem( oNewItem, iSlot));
    DestroyObject( oItem);
  }
  else
    DestroyObject( oNewItem);
}
