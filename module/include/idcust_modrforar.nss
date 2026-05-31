int GetNextForeArmIndex( int iIndex)
{

  if( iIndex == 2)
    iIndex = 3;

  if( iIndex == 24)
    iIndex = 110;

  if( iIndex == 113)
    iIndex = 150;

  if( iIndex > 164)
    iIndex = 1;

  return iIndex;
}

void main()
{
  //First line of the item customization script
  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");
  object oItem = GetItemInSlot( iSlot, oPlayer);
  int iIndex = GetItemAppearance( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOREARM);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index before is: " + IntToString( iIndex));

  iIndex++;
  iIndex = GetNextForeArmIndex( iIndex);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index after is: " + IntToString( iIndex));

  object oNewItem = CopyItemAndModify( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOREARM, iIndex, TRUE);

  if( GetIsObjectValid( oNewItem))
  {
    AssignCommand( oPlayer, ActionEquipItem( oNewItem, iSlot));
    DestroyObject( oItem);
  }
  else
    DestroyObject( oNewItem);
}
