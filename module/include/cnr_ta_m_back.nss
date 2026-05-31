/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_ta_m_back
//
//  Desc:  Should the "Back" menu item be shown.
//
//  Author: David Bobeck 06Apr03
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
    return TRUE;
  }
  return FALSE;
}

