#include "p_f"

void main()
{
  //First line of the item customization script
  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");
  object oItem = GetItemInSlot( iSlot, oPlayer);

  int iIndex = GetItemAppearance( oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
  iIndex++;

  if( iIndex > GetColourMax())
    iIndex = 0;

  object oNewItem = CopyItemAndModify( oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, iIndex, TRUE);

  if( GetIsObjectValid( oNewItem))
  {
    AssignCommand( oPlayer, ActionEquipItem( oNewItem, iSlot));
    DestroyObject( oItem);
  }
  else
    DestroyObject( oNewItem);
}
