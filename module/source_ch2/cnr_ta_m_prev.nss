/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_ta_m_prev
//
//  Desc:  Should the "Prev" menu item be shown.
//
//  Author: David Bobeck 12Dec02
//
/////////////////////////////////////////////////////////
int StartingConditional()
{
  object oPC = GetPCSpeaker();
  if (GetLocalInt(oPC, "nCnrMenuPage") > 0)
  {
    return TRUE;
  }
  return FALSE;
}
