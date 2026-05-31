int StartingConditional()
{
  object oPlayer = GetPCSpeaker();
  object oItem = GetItemInSlot( INVENTORY_SLOT_RIGHTHAND, oPlayer);
  int iItemtype = GetBaseItemType( oItem);

  //weapons
  if( iItemtype == BASE_ITEM_BASTARDSWORD ||
           iItemtype == BASE_ITEM_BATTLEAXE ||
           iItemtype == BASE_ITEM_CLUB ||
           iItemtype == BASE_ITEM_DAGGER ||
           iItemtype == BASE_ITEM_DART ||
           iItemtype == BASE_ITEM_DIREMACE ||
           iItemtype == BASE_ITEM_DOUBLEAXE ||
           iItemtype == BASE_ITEM_DWARVENWARAXE ||
           iItemtype == BASE_ITEM_GREATAXE ||
           iItemtype == BASE_ITEM_GREATSWORD ||
           iItemtype == BASE_ITEM_HALBERD ||
           iItemtype == BASE_ITEM_HANDAXE ||
           iItemtype == BASE_ITEM_HEAVYCROSSBOW ||
           iItemtype == BASE_ITEM_HEAVYFLAIL ||
           iItemtype == BASE_ITEM_KAMA ||
           iItemtype == BASE_ITEM_KATANA ||
           iItemtype == BASE_ITEM_KUKRI ||
           iItemtype == BASE_ITEM_LIGHTCROSSBOW ||
           iItemtype == BASE_ITEM_LIGHTFLAIL ||
           iItemtype == BASE_ITEM_LIGHTHAMMER ||
           iItemtype == BASE_ITEM_LIGHTMACE ||
           iItemtype == BASE_ITEM_LONGBOW ||
           iItemtype == BASE_ITEM_LONGSWORD ||
           iItemtype == BASE_ITEM_MORNINGSTAR ||
           iItemtype == BASE_ITEM_QUARTERSTAFF ||
           iItemtype == BASE_ITEM_RAPIER ||
           iItemtype == BASE_ITEM_SCIMITAR ||
           iItemtype == BASE_ITEM_SCYTHE ||
           iItemtype == BASE_ITEM_SHORTBOW ||
           iItemtype == BASE_ITEM_SHORTSPEAR ||
           iItemtype == BASE_ITEM_SHORTSWORD ||
           iItemtype == BASE_ITEM_SICKLE ||
           iItemtype == BASE_ITEM_SLING ||
           iItemtype == BASE_ITEM_TWOBLADEDSWORD ||
           iItemtype ==BASE_ITEM_WARHAMMER
         ) //then
  {
    return TRUE;
  }
  else
    return FALSE;
}
