/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_ta_m_next
//
//  Desc:  Should the "Next" menu item be shown.
//
//  Author: David Bobeck 12Dec02
//
/////////////////////////////////////////////////////////
#include "cnr_merch_utils"
int StartingConditional()
{
  object oPC = GetPCSpeaker();
  string sKeyToMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  int nMenuPage = GetLocalInt(oPC, "nCnrMenuPage");
  string sMenuType = GetLocalString(oPC, "sCnrMenuType");
  int nItemCount;
  if (sMenuType == "BUY")
  {
    nItemCount = CnrMerchantGetBuyCount(sKeyToMenu);
  }
  else // "SELL"
  {
    nItemCount = CnrMerchantGetSellCount(sKeyToMenu);
  }
  if (((nMenuPage * CMD_SELECTIONS_PER_PAGE) + CMD_SELECTIONS_PER_PAGE) < nItemCount)
  {
    return TRUE;
  }
  return FALSE;
}
