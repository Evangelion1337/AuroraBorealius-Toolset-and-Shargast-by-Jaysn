#include "idcust_weap_idex"

void main()
{
  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");
  object oItem = GetItemInSlot( iSlot, oPlayer);
  //int iIndex = GetLocalInt( OBJECT_SELF, "iIndex");
  int iIndex = GetItemAppearance( oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE);
  int iItemType = GetBaseItemType( oItem);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index before is: " + IntToString( iIndex));

  iIndex++;
  iIndex = GetNextWeaponIndex( iIndex, iItemType, ITEM_APPR_WEAPON_MODEL_MIDDLE);

  if( GetIsDM( oPlayer))
    SendMessageToPC( oPlayer, "The index after is: " + IntToString( iIndex));

  //SetLocalInt( OBJECT_SELF, "iIndex", iIndex);
  object oNewItem = CopyItemAndModify( oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE, iIndex, TRUE);

  if( GetIsObjectValid( oNewItem))
  {
    AssignCommand( oPlayer, ActionEquipItem( oNewItem, iSlot));
    DestroyObject( oItem);
  }
  else
    DestroyObject( oNewItem);
}
