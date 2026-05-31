/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_at_m_back
//
//  Desc:  Changes to the merchant's sell menu page
//
//  Author: David Bobeck 23Dec02
//
/////////////////////////////////////////////////////////
//#include "cnr_merch_utils"
void main()
{
  //CnrMerchantUpdateCustomTokens(OBJECT_SELF);

  object oPC = GetPCSpeaker();
  string sKeyToMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  string sKeyToKeyToParent = sKeyToMenu + "_KeyToParent";
  string sKeyToParent = GetLocalString(GetModule(), sKeyToKeyToParent);
  SetLocalString(oPC, "sCnrCurrentMenu", sKeyToParent);
  SetLocalInt(oPC, "nCnrMenuPage", 0);
  // the convo script will call "cnr_ta_m_buysell" next
}
