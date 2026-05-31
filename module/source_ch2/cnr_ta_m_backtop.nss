/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_ta_m_backtop
//
//  Desc:  Should the "Back" (to top) menu item be shown.
//
//  Author: David Bobeck 16Apr03
//
/////////////////////////////////////////////////////////
int StartingConditional()
{
  object oPC = GetPCSpeaker();
  string sKeyToMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  string sKeyToKeyToParent = sKeyToMenu + "_KeyToParent";
  string sKeyToParent = GetLocalString(GetModule(), sKeyToKeyToParent);
  if (sKeyToParent != "")
  {
    return FALSE;
  }
  return TRUE;
}

