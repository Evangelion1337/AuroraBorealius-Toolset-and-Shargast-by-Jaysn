void main()
{
  //First line of the item customization script
  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");
  object oItem = GetItemInSlot( iSlot, oPlayer);

  int iIndex = GetItemAppearance( oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_MODEL_TOP);
  iIndex++;

  if( iIndex > 3)
    iIndex = 1;

  object oNewItem = CopyItemAndModify( oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP, iIndex, TRUE);

  if( GetIsObjectValid( oNewItem))
  {
    AssignCommand( oPlayer, ActionEquipItem( oNewItem, iSlot));
    DestroyObject( oItem);
  }
  else
    DestroyObject( oNewItem);
}
