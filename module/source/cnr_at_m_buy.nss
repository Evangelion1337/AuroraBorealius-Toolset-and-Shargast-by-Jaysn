/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_at_m_buy
//
//  Desc:  Changes to the merchant's buy menu page
//
//  Author: David Bobeck 17Dec02
//
/////////////////////////////////////////////////////////
#include "cnr_merch_utils"
void main()
{
  object oPC = GetPCSpeaker();
  SetLocalString(oPC, "sCnrMenuType", "BUY");
  SetLocalString(oPC, "sCnrCurrentMenu", "BUY"+GetTag(OBJECT_SELF));
  SetLocalInt(oPC, "nCnrMenuPage", 0);
  // the convo script will call "cnr_ta_m_buysell" next
}
