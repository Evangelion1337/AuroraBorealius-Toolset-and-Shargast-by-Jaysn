int GetNextFootIndex( int iIndex)
{

  if( iIndex == 2)
    iIndex = 3;

  if( iIndex == 13)
    iIndex = 80;

  if( iIndex == 83)
    iIndex = 151;

  if( iIndex > 158)
    iIndex = 1;

  return iIndex;
}

void main()
{
  //First line of the item customization script
  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");
  object oItem = GetItemInSlot( iSlot, oPlayer);
  int iIndex = GetItemAppearance( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index before is: " + IntToString( iIndex));

  iIndex++;
  iIndex = GetNextFootIndex( iIndex);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index after is: " + IntToString( iIndex));

  object oNewItem = CopyItemAndModify( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT, iIndex, TRUE);
  object oNewItem2 = CopyItemAndModify( oNewItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT, iIndex, TRUE);
  DestroyObject( oNewItem);

  if( GetIsObjectValid( oNewItem2))
  {
    AssignCommand( oPlayer, ActionEquipItem( oNewItem2, iSlot));
    DestroyObject( oItem);
  }
  else
    DestroyObject( oNewItem2);
}
