int GetNextShieldIndex( object oShield)
{
  int iIndex = GetItemAppearance( oShield, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
  iIndex++;
  int iItemtype = GetBaseItemType( oShield);

  //shields
  if( iItemtype == BASE_ITEM_SMALLSHIELD)
  {
    if( iIndex == 14)
      iIndex = 21;
    else if( iIndex == 24)
      iIndex = 31;
    else if( iIndex == 34)
      iIndex = 41;
    else if( iIndex == 44)
      iIndex = 51;
    else if( iIndex == 58)
      iIndex = 86;
    else if( iIndex > 88)
      iIndex = 11;
  }
  else if( iItemtype == BASE_ITEM_LARGESHIELD)
  {
    if( iIndex == 14)
      iIndex = 21;
    else if( iIndex == 24)
      iIndex = 31;
    else if( iIndex == 34)
      iIndex = 41;
    else if( iIndex == 44)
      iIndex = 51;
    else if( iIndex == 89)
      iIndex = 90;
    else if( iIndex == 97)
      iIndex = 100;
    else if( iIndex == 105)
      iIndex = 107;
    else if( iIndex == 110)
      iIndex = 111;
    else if( iIndex == 120)
      iIndex = 121;
    else if( iIndex == 130)
      iIndex = 131;
    else if( iIndex == 140)
      iIndex = 141;
    else if( iIndex == 150)
      iIndex = 151;
    else if( iIndex == 156)
      iIndex = 178;
    else if( iIndex == 214)
      iIndex = 220;
    else if( iIndex > 255)
      iIndex = 11;
  }
  else if( iItemtype == BASE_ITEM_TOWERSHIELD)
  {
    if( iIndex == 14)
      iIndex = 21;
    else if( iIndex == 24)
      iIndex = 31;
    else if( iIndex == 34)
      iIndex = 41;
    else if( iIndex == 44)
      iIndex = 51;
    else if( iIndex == 61)
      iIndex = 62;
    else if( iIndex == 88)
      iIndex = 89;
    else if( iIndex == 106)
      iIndex = 107;
    else if( iIndex == 119)
      iIndex = 121;
    else if( iIndex == 130)
      iIndex = 131;
    else if( iIndex == 140)
      iIndex = 141;
    else if( iIndex == 150)
      iIndex = 151;
    else if( iIndex == 154)
      iIndex = 182;
    else if( iIndex == 231)
      iIndex = 11;
  }
  return iIndex;
}

void main()
{
  object oPlayer = GetPCSpeaker();
  object oShield = GetItemInSlot( INVENTORY_SLOT_LEFTHAND, oPlayer);

  int iIndex = GetNextShieldIndex( oShield);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index is: " + IntToString( iIndex));

  object oNewShield = CopyItemAndModify(oShield, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iIndex, TRUE);

  if( GetIsObjectValid( oNewShield))
  {
    AssignCommand( oPlayer, ActionEquipItem( oNewShield, INVENTORY_SLOT_LEFTHAND));
    DestroyObject( oShield);
  }
  else
    DestroyObject( oNewShield);
}
