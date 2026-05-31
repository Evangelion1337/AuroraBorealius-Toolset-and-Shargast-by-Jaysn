/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_at_m_oops
//
//  Desc:  The player has selected a red item on the
//         merchant's menu.
//
//  Author: David Bobeck 17Dec02
//
/////////////////////////////////////////////////////////
void main()
{
  object oPC = GetPCSpeaker();
  string sMenuType = GetLocalString(oPC, "sCnrMenuType");
  if (sMenuType == "BUY")
  {
    SetCustomToken(22000, "You don't have that item.\n");
  }
  else // "SELL"
  {
    SetCustomToken(22000, "Sorry. I am out of that item.\n");
  }
}
