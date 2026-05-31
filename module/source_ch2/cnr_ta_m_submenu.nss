/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_ta_b_submenu
//
//  Desc:  Checks if the text on the menu should
//         be displayed as a submenu.
//
//  Author: David Bobeck 06Apr03
//
/////////////////////////////////////////////////////////
#include "cnr_merch_utils"
int StartingConditional()
{
  object oPC = GetPCSpeaker();
  int nOffset = GetLocalInt(oPC, "nCnrSubOffset");
  SetLocalInt(oPC, "nCnrSubOffset", nOffset+1);
  return CnrMerchantShowAsSubMenu(oPC, nOffset);
}
