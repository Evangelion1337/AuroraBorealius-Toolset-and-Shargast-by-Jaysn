/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_ta_m_top
//
//  Desc:  Init's the merchant's top menu page
//
//  Author: David Bobeck 23Dec02
//
/////////////////////////////////////////////////////////
#include "cnr_merch_utils"
int StartingConditional()
{
  object oPC = GetPCSpeaker();
  SetLocalString(oPC, "sCnrMenuType", "TOP");
  CnrMerchantShowMenu(GetTag(OBJECT_SELF), 0);
  return TRUE;
}
