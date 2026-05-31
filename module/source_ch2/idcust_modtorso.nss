int GetNextTorsoIndex( object oItem)
{
  int iIndex = GetItemAppearance( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO);
  iIndex++;

  if( iIndex == 0)
  {
    iIndex = 1;
    return iIndex;
  }

  else if( iIndex == 2)
  {
    iIndex = 3;
    return iIndex;
  }

  else if( iIndex == 4)
  {
    iIndex = 5;
    return iIndex;
  }

  else if( iIndex == 10)
  {
    iIndex = 12;
    return iIndex;
  }

  else if( iIndex == 13)
  {
    iIndex = 19;
    return iIndex;
  }

  else if( iIndex == 20)
  {
    iIndex = 39;
    return iIndex;
  }

  else if( iIndex == 40)
  {
    iIndex = 50;
    return iIndex;
  }

  else if( iIndex == 51)
  {
    iIndex = 110;
    return iIndex;
  }

  else if( iIndex == 112)
  {
    iIndex = 150;
    return iIndex;
  }

  else if( iIndex == 160)
  {
    iIndex = 163;
    return iIndex;
  }

  else if( iIndex == 164)
  {
    iIndex = 166;
    return iIndex;
  }

  else if( iIndex == 167)
  {
    iIndex = 168;
    return iIndex;
  }

  else if( iIndex > 175 )
  {
    iIndex = 1;
    return iIndex;
  }
//*****************************************************************************
  else if( iIndex == 21)
  {
    iIndex = 28;
    return iIndex;
  }

  else if( iIndex == 29)
  {
    iIndex = 40;
    return iIndex;
  }

  else if( iIndex == 41)
  {
    iIndex = 20;
    return iIndex;
  }
//*****************************************************************************
  else if( iIndex == 11)
  {
    iIndex = 13;
    return iIndex;
  }

  else if( iIndex == 14)
  {
    iIndex = 16;
    return iIndex;
  }

  else if( iIndex == 17)
  {
    iIndex = 27;
    return iIndex;
  }

  else if( iIndex == 28)
  {
    iIndex = 41;
    return iIndex;
  }

  else if( iIndex == 43)
  {
    iIndex = 49;
    return iIndex;
  }

  else if( iIndex == 50)
  {
    iIndex = 10;
    return iIndex;
  }
//*****************************************************************************
  else if( iIndex == 23)
  {
    iIndex = 29;
    return iIndex;
  }

  else if( iIndex == 30)
  {
    iIndex = 43;
    return iIndex;
  }

  else if( iIndex == 45)
  {
    iIndex = 22;
    return iIndex;
  }
//*****************************************************************************
  else if( iIndex == 5)
  {
    iIndex = 15;
    return iIndex;
  }

  else if( iIndex == 16)
  {
    iIndex = 18;
    return iIndex;
  }

  else if( iIndex == 19)
  {
    iIndex = 34;
    return iIndex;
  }

  else if( iIndex == 37)
  {
    iIndex = 38;
    return iIndex;
  }

  else if( iIndex == 39)
  {
    iIndex = 4;
    return iIndex;
  }
//*****************************************************************************
  else if( iIndex == 27)
  {
    iIndex = 31;
    return iIndex;
  }

  else if( iIndex == 33)
  {
    iIndex = 24;
    return iIndex;
  }
//*****************************************************************************
  else if( iIndex == 12)
  {
    iIndex = 17;
    return iIndex;
  }

  else if( iIndex == 18)
  {
    iIndex = 30;
    return iIndex;
  }

  else if( iIndex == 31)
  {
    iIndex = 45;
    return iIndex;
  }

  else if( iIndex == 46)
  {
    iIndex = 48;
    return iIndex;
  }

  else if( iIndex == 49)
  {
    iIndex = 11;
    return iIndex;
  }
//*****************************************************************************
  else if( iIndex == 34)
  {
    iIndex = 46;
    return iIndex;
  }

  else if( iIndex == 48)
  {
    iIndex = 51;
    return iIndex;
  }

  else if( iIndex == 53)
  {
    iIndex = 33;
    return iIndex;
  }

  else if( iIndex == 15)
  {
    iIndex = 21;
    return iIndex;
  }
//*****************************************************************************
  else if( iIndex == 22)
  {
    iIndex = 23;
    return iIndex;
  }

  else if( iIndex == 24)
  {
    iIndex = 37;
    return iIndex;
  }

  else if( iIndex == 38)
  {
    iIndex = 53;
    return iIndex;
  }

  else if( iIndex == 54)
  {
    iIndex = 14;
    return iIndex;
  }

  return iIndex;
}


void main()
{
  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");
  object oItem = GetItemInSlot( iSlot, oPlayer);
  int iIndex = GetItemAppearance( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index before is: " + IntToString( iIndex));

  iIndex = GetNextTorsoIndex( oItem);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index after is: " + IntToString( iIndex));

  object oNewItem = CopyItemAndModify( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO, iIndex, TRUE);

  if( GetIsObjectValid( oNewItem))
  {
    AssignCommand( oPlayer, ActionEquipItem( oNewItem, iSlot));
    DestroyObject( oItem);
  }
  else
    DestroyObject( oNewItem);
}
