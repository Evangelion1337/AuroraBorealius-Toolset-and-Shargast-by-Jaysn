int StartingConditional()
{

  object oPlayer = GetPCSpeaker();
  int iSlot = GetLocalInt( OBJECT_SELF, "iSlot");

  object oItem = GetItemInSlot( iSlot, oPlayer);

  if( GetIsObjectValid( oItem))
    return FALSE;
  else
    return TRUE;
}
