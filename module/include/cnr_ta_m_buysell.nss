/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_ta_m_buysell
//
//  Desc:  Init's the merchants buy/sell menu page
//
//  Author: David Bobeck 06Apr03
//
/////////////////////////////////////////////////////////
#include "cnr_merch_utils"
int StartingConditional()
{
  object oPC = GetPCSpeaker();
  string sKeyToMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  int nMenuPage = GetLocalInt(oPC, "nCnrMenuPage");
  CnrMerchantShowMenu(sKeyToMenu, nMenuPage);
  return TRUE;
}
