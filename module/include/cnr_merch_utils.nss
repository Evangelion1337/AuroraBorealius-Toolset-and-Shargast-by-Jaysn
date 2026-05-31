/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_merch_utils
//
//  Desc:  This collection of functions manages the
//         custom merchant menus for CNR.
//
//  Author: David Bobeck 12Dec02
//
/////////////////////////////////////////////////////////
#include "cnr_persist_inc"

int CMD_SELECTIONS_PER_PAGE = 6;

/////////////////////////////////////////////////////////
string CnrMerchantAddSubMenu(string sKeyToParent, string sTitle)
{
  string sKeyToCount = sKeyToParent + "_SubMenuCount";
  int nSubMenuCount = GetLocalInt(GetModule(), sKeyToCount);

  // check if this title is already mapped
  int m;
  string sKey;

  for (m=1; m<=nSubMenuCount; m++)
  {
    sKey = sKeyToParent + "_" + IntToString(m);
    string sExistingTitle = GetLocalString(GetModule(), sKey);
    if (sExistingTitle == sTitle)
    {
      return sKey;
    }
  }

  nSubMenuCount++;
  SetLocalInt(GetModule(), sKeyToCount, nSubMenuCount);

  sKey = sKeyToParent + "_" + IntToString(nSubMenuCount);
  SetLocalString(GetModule(), sKey, sTitle);

  string sKeyToKeyToParent = sKey + "_KeyToParent";
  SetLocalString(GetModule(), sKeyToKeyToParent, sKeyToParent);

  return sKey;
}

/////////////////////////////////////////////////////////
//  sMerchantTag = the tag of the NPC
//  sText = the text spoken by the NPC (and which appears) as a 'greeting'
/////////////////////////////////////////////////////////
void CnrMerchantSetMerchantGreetingText(string sMerchantTag, string sText);
/////////////////////////////////////////////////////////
void CnrMerchantSetMerchantGreetingText(string sMerchantTag, string sText)
{
  string sKeyToText = sMerchantTag + "_MGText";
  SetLocalString(GetModule(), sKeyToText, sText);
}

/////////////////////////////////////////////////////////
//  sMerchantTag = the tag of the NPC
//  sText = the text spoken by the NPC (and which appears) on the 'buy' menu
/////////////////////////////////////////////////////////
void CnrMerchantSetMerchantBuyText(string sMerchantTag, string sText);
/////////////////////////////////////////////////////////
void CnrMerchantSetMerchantBuyText(string sMerchantTag, string sText)
{
  string sKeyToText = sMerchantTag + "_MBText";
  SetLocalString(GetModule(), sKeyToText, sText);
}

/////////////////////////////////////////////////////////
//  sMerchantTag = the tag of the NPC
//  sText = the text spoken by the NPC (and which appears) on the 'sell' menu
/////////////////////////////////////////////////////////
void CnrMerchantSetMerchantSellText(string sMerchantTag, string sText);
/////////////////////////////////////////////////////////
void CnrMerchantSetMerchantSellText(string sMerchantTag, string sText)
{
  string sKeyToText = sMerchantTag + "_MSText";
  SetLocalString(GetModule(), sKeyToText, sText);
}

/////////////////////////////////////////////////////////
//  sMerchantTag = the tag of the NPC
//  Note: Use of persistent storage requires user defined database scripts
//        (see "readme_merch_get" and "readme_merch_set" for details)
/////////////////////////////////////////////////////////
void CnrMerchantEnablePersistentInventory(string sMerchantTag);
/////////////////////////////////////////////////////////
void CnrMerchantEnablePersistentInventory(string sMerchantTag)
{
  string sKeyToFlag = sMerchantTag + "_EnablePersistentInventory";
  int bAlreadyPersistent = CnrGetPersistentInt(GetModule(), sKeyToFlag);
  if (bAlreadyPersistent)
  {
    // Set this so we can determine if we should re-init the on-hand item counts
    SetLocalInt(GetModule(), sKeyToFlag, TRUE);
  }
  CnrSetPersistentInt(GetModule(), sKeyToFlag, TRUE);
}

/////////////////////////////////////////////////////////
string CnrMerchantBuildAncestorMenus(string sMenuType, string sMerchantTag)
{
  // this crap finds all ancestors of sMercantTag and creates new menus
  // for all of them but with sMenuType prepended to the base menu key.
  string sKeyToKeyToParent = sMerchantTag + "_KeyToParent";
  string sKeyToParent = GetLocalString(GetModule(), sKeyToKeyToParent);

  string sKeyToStartingParent = sKeyToParent;
  string sKeyToChild = sMerchantTag;
  string sStartingMenuTitle = GetLocalString(GetModule(), sMerchantTag);
  string sKeyToTargetParent = "";
  string sMenuTitle;

  sMerchantTag = sMenuType + sMerchantTag;

  while (sKeyToTargetParent != sKeyToStartingParent)
  {
    // walk up
    while (sKeyToParent != sKeyToTargetParent)
    {
      sKeyToKeyToParent = sKeyToParent + "_KeyToParent";
      sKeyToChild = sKeyToParent;
      sMenuTitle = GetLocalString(GetModule(), sKeyToChild);
      sKeyToParent = GetLocalString(GetModule(), sKeyToKeyToParent);
    }

    if (sKeyToTargetParent == "")
    {
      // first time thru loop, prepend "BUY" or "SELL"
      sMerchantTag = sMenuType + sKeyToChild;
    }
    else
    {
      sMerchantTag = CnrMerchantAddSubMenu(sMerchantTag, sMenuTitle);
    }

    // step down
    sKeyToTargetParent = sKeyToChild;

    // start walking up from bottom again
    sKeyToParent = sKeyToStartingParent;
  }

  if ((sKeyToTargetParent == "") && (sKeyToStartingParent == ""))
  {
    return sMerchantTag;
  }

  sMerchantTag = CnrMerchantAddSubMenu(sMerchantTag, sStartingMenuTitle);
  return sMerchantTag;
}

/////////////////////////////////////////////////////////
string CnrMerchantAddItemHelper(string sMerchantTag, string sItemDesc, string sItemTag, int nBuyPrice, int nSellPrice, int bInfiniteSupply, int nMaxOnHandQty)
{
  object oModule = GetModule();

  if (nBuyPrice > 0)
  {
    sMerchantTag = CnrMerchantBuildAncestorMenus("BUY", sMerchantTag);

    string sKeyToBuyCount = sMerchantTag + "_BuyCount";
    int nBuyCount = GetLocalInt(oModule, sKeyToBuyCount) + 1;
    SetLocalInt(oModule, sKeyToBuyCount, nBuyCount);

    string sKeyToBuyDesc = sMerchantTag + "_BuyDesc_" + IntToString(nBuyCount);
    string sKeyToBuyTag = sMerchantTag + "_BuyTag_" + IntToString(nBuyCount);
    string sKeyToBuyPrice = sMerchantTag + "_BuyPrice_" + IntToString(nBuyCount);
    string sKeyToBuyInfinite = sMerchantTag + "_BuyInfinite_" + IntToString(nBuyCount);
    string sKeyToMaxOnHandQty = sMerchantTag + "_MaxOnHandQty_" + sItemTag;
    SetLocalString(oModule, sKeyToBuyDesc, sItemDesc);
    SetLocalString(oModule, sKeyToBuyTag, sItemTag);
    SetLocalInt(oModule, sKeyToBuyPrice, nBuyPrice);
    SetLocalInt(oModule, sKeyToBuyInfinite, bInfiniteSupply);
    SetLocalInt(oModule, sKeyToMaxOnHandQty, nMaxOnHandQty);
    return sMerchantTag;
  }

  if (nSellPrice > 0)
  {
    sMerchantTag = CnrMerchantBuildAncestorMenus("SELL", sMerchantTag);

    string sKeyToSellCount = sMerchantTag + "_SellCount";
    int nSellCount = GetLocalInt(oModule, sKeyToSellCount) + 1;
    SetLocalInt(oModule, sKeyToSellCount, nSellCount);

    string sKeyToSellDesc = sMerchantTag + "_SellDesc_" + IntToString(nSellCount);
    string sKeyToSellTag = sMerchantTag + "_SellTag_" + IntToString(nSellCount);
    string sKeyToSellPrice = sMerchantTag + "_SellPrice_" + IntToString(nSellCount);
    string sKeyToSellInfinite = sMerchantTag + "_SellInfinite_" + IntToString(nSellCount);
    SetLocalString(oModule, sKeyToSellDesc, sItemDesc);
    SetLocalString(oModule, sKeyToSellTag, sItemTag);
    SetLocalInt(oModule, sKeyToSellPrice, nSellPrice);
    SetLocalInt(oModule, sKeyToSellInfinite, bInfiniteSupply);
    return sMerchantTag;
  }

  return sMerchantTag;
}

/////////////////////////////////////////////////////////
//  sMerchantTag = the tag of the NPC
//  sItemDesc = the text identifying an item you wish to display in the dialog.
//  sItemTag = the tag of the item the NPC will be buying or selling.
//  nBuyPrice = if > 0, the NPC will buy this item for this many gold pieces.
//  nSellPrice = if > 0, the NPC will sell this item for this many gold pieces.
//  bInfiniteSupply = If TRUE and nBuyPrice > 0, the NPC will buy an unlimited
//                    number of this item.
//                    If TRUE and nSellPrice > 0, the NPC will sell an unlimited
//                    number of this item.
//                    If FALSE, the NPC will 1) put purchased items in his/her
//                    inventory, and 2) only sell items if they exist in his/her
//                    inventory. (Items sold are removed from inventory).
//  nMaxOnHandQty = the max qty of an item the NPC will hold in inventory.
/////////////////////////////////////////////////////////
void CnrMerchantAddItem(string sMerchantTag, string sItemDesc, string sItemTag, int nBuyPrice, int nSellPrice, int bInfiniteSupply, int nMaxOnHandQty=0);
/////////////////////////////////////////////////////////
void CnrMerchantAddItem(string sMerchantTag, string sItemDesc, string sItemTag, int nBuyPrice, int nSellPrice, int bInfiniteSupply, int nMaxOnHandQty=0)
{
  if (nBuyPrice > 0)
  {
    CnrMerchantAddItemHelper(sMerchantTag, sItemDesc, sItemTag, nBuyPrice, 0, bInfiniteSupply, nMaxOnHandQty);
  }

  if (nSellPrice > 0)
  {
    CnrMerchantAddItemHelper(sMerchantTag, sItemDesc, sItemTag, 0, nSellPrice, bInfiniteSupply, nMaxOnHandQty);
  }
}

/////////////////////////////////////////////////////////
//  sMerchantTag = the tag of the NPC
//  sItemDesc = the text identifying an item you wish to display in the dialog.
//  sItemTag = the tag of the item the NPC will be buying or selling.
//  sItemResRef = the resref of the item. This is required when the item's resref
//                is spelled diferently from the tag.
//  nBuyPrice = if > 0, the NPC will buy this item for this many gold pieces.
//  nSellPrice = if > 0, the NPC will sell this item for this many gold pieces.
//  bInfiniteSupply = If TRUE and nBuyPrice > 0, the NPC will buy an unlimited
//                    number of this item.
//                    If TRUE and nSellPrice > 0, the NPC will sell an unlimited
//                    number of this item.
//                    If FALSE, the NPC will 1) put purchased items in his/her
//                    inventory, and 2) only sell items if they exist in his/her
//                    inventory. (Items sold are removed from inventory).
//  nMaxOnHandQty = the max qty of an item the NPC will hold in inventory.
/////////////////////////////////////////////////////////
void CnrMerchantAddItem2(string sMerchantTag, string sItemDesc, string sItemTag, string sItemResRef, int nBuyPrice, int nSellPrice, int bInfiniteSupply, int nMaxOnHandQty=0);
/////////////////////////////////////////////////////////
void CnrMerchantAddItem2(string sMerchantTag, string sItemDesc, string sItemTag, string sItemResRef, int nBuyPrice, int nSellPrice, int bInfiniteSupply, int nMaxOnHandQty=0)
{
  CnrMerchantAddItem(sMerchantTag, sItemDesc, sItemTag, nBuyPrice, nSellPrice, bInfiniteSupply, nMaxOnHandQty);
  SetLocalString(GetModule(), "cnr_" + sItemTag, sItemResRef);
}

/////////////////////////////////////////////////////////
void CnrMerchantAddPersistentItemHelper(string sMerchantTag, string sItemDesc, string sItemTag, int nBuyPrice, int nSellPrice, int nInitialOnHandQty, int nMaxOnHandQty)
{
  object oModule = GetModule();

  string sKeyToMaxOnHandQty = sMerchantTag + "_MaxOnHandQty_" + sItemTag;
  SetLocalInt(oModule, sKeyToMaxOnHandQty, nMaxOnHandQty);

  // Only initialize the persistent database once!
  string sKeyToFlag = sMerchantTag + "_EnablePersistentInventory";
  int bInitPersistentData = GetLocalInt(GetModule(), sKeyToFlag);
  if (bInitPersistentData)
  {
    // Start with nInitialOnHandQty value in the persistent database
    if (nInitialOnHandQty > nMaxOnHandQty)
    {
      nInitialOnHandQty = nMaxOnHandQty;
    }

    string sKeyToOnHandQty = sMerchantTag + "_OnHandQty_" + sItemTag;
    CnrSetPersistentInt(oModule, sKeyToOnHandQty, nInitialOnHandQty);
  }
}

/////////////////////////////////////////////////////////
//  sMerchantTag = the tag of the NPC
//  sItemDesc = the text identifying an item you wish to display in the dialog.
//  sItemTag = the tag of the item the NPC will be buying or selling.
//  nBuyPrice = if > 0, the NPC will buy this item for this many gold pieces.
//  nSellPrice = if > 0, the NPC will sell this item for this many gold pieces.
//  nInitialOnHandQty = the qty of an item the NPC will start with in inventory.
//  nMaxOnHandQty = the max qty of an item the NPC will hold in inventory.
/////////////////////////////////////////////////////////
void CnrMerchantAddPersistentItem(string sMerchantTag, string sItemDesc, string sItemTag, int nBuyPrice, int nSellPrice, int nInitialOnHandQty, int nMaxOnHandQty);
/////////////////////////////////////////////////////////
void CnrMerchantAddPersistentItem(string sMerchantTag, string sItemDesc, string sItemTag, int nBuyPrice, int nSellPrice, int nInitialOnHandQty, int nMaxOnHandQty)
{
  if (nBuyPrice > 0)
  {
    sMerchantTag = CnrMerchantAddItemHelper(sMerchantTag, sItemDesc, sItemTag, nBuyPrice, 0, FALSE, nMaxOnHandQty);
    CnrMerchantAddPersistentItemHelper(sMerchantTag, sItemDesc, sItemTag, nBuyPrice, 0, nInitialOnHandQty, nMaxOnHandQty);
  }

  if (nSellPrice > 0)
  {
    sMerchantTag = CnrMerchantAddItemHelper(sMerchantTag, sItemDesc, sItemTag, 0, nSellPrice, FALSE, nMaxOnHandQty);
    CnrMerchantAddPersistentItemHelper(sMerchantTag, sItemDesc, sItemTag, 0, nSellPrice, nInitialOnHandQty, nMaxOnHandQty);
  }
}

/////////////////////////////////////////////////////////
//  sMerchantTag = the tag of the NPC
//  sItemDesc = the text identifying an item you wish to display in the dialog.
//  sItemTag = the tag of the item the NPC will be buying or selling.
//  sItemResRef = the resref of the item. This is required when the item's resref
//                is spelled diferently from the tag.
//  nBuyPrice = if > 0, the NPC will buy this item for this many gold pieces.
//  nSellPrice = if > 0, the NPC will sell this item for this many gold pieces.
//  nInitialOnHandQty = the qty of an item the NPC will start with in inventory.
//  nMaxOnHandQty = the max qty of an item the NPC will hold in inventory.
/////////////////////////////////////////////////////////
void CnrMerchantAddPersistentItem2(string sMerchantTag, string sItemDesc, string sItemTag, string sItemResRef, int nBuyPrice, int nSellPrice, int nInitialOnHandQty, int nMaxOnHandQty);
/////////////////////////////////////////////////////////
void CnrMerchantAddPersistentItem2(string sMerchantTag, string sItemDesc, string sItemTag, string sItemResRef, int nBuyPrice, int nSellPrice, int nInitialOnHandQty, int nMaxOnHandQty)
{
  CnrMerchantAddPersistentItem(sMerchantTag, sItemDesc, sItemTag, nBuyPrice, nSellPrice, nInitialOnHandQty, nMaxOnHandQty);
  SetLocalString(GetModule(), "cnr_" + sItemTag, sItemResRef);
}

/////////////////////////////////////////////////////////
int CnrMerchantGetBuyCount(string sMerchantTag)
{
  string sKeyToBuyCount = sMerchantTag + "_BuyCount";
  int nBuyCount = GetLocalInt(GetModule(), sKeyToBuyCount);
  return nBuyCount;
}

/////////////////////////////////////////////////////////
int CnrMerchantGetSellCount(string sMerchantTag)
{
  string sKeyToSellCount = sMerchantTag + "_SellCount";
  int nSellCount = GetLocalInt(GetModule(), sKeyToSellCount);
  return nSellCount;
}

/////////////////////////////////////////////////////////
string CnrMerchantGetBuyDesc(string sMerchantTag, int nItemIndex)
{
  string sItemDesc = "INVALID_ITEM";
  object oModule = GetModule();

  // validate the index
  string sKeyToItemCount = sMerchantTag + "_BuyCount";
  int nItemCount = GetLocalInt(oModule, sKeyToItemCount);
  if ((nItemIndex > 0) && (nItemIndex <= nItemCount))
  {
    string sKeyToItemDesc = sMerchantTag + "_BuyDesc_" + IntToString(nItemIndex);
    sItemDesc = GetLocalString(oModule, sKeyToItemDesc);
  }

  return sItemDesc;
}

/////////////////////////////////////////////////////////
string CnrMerchantGetSellDesc(string sMerchantTag, int nItemIndex)
{
  string sItemDesc = "INVALID_ITEM";
  object oModule = GetModule();

  // validate the index
  string sKeyToItemCount = sMerchantTag + "_SellCount";
  int nItemCount = GetLocalInt(oModule, sKeyToItemCount);
  if ((nItemIndex > 0) && (nItemIndex <= nItemCount))
  {
    string sKeyToItemDesc = sMerchantTag + "_SellDesc_" + IntToString(nItemIndex);
    sItemDesc = GetLocalString(oModule, sKeyToItemDesc);
  }

  return sItemDesc;
}

/////////////////////////////////////////////////////////
string CnrMerchantGetBuyTag(string sMerchantTag, int nItemIndex)
{
  string sItemTag = "INVALID_ITEM";
  object oModule = GetModule();

  // validate the index
  string sKeyToItemCount = sMerchantTag + "_BuyCount";
  int nItemCount = GetLocalInt(oModule, sKeyToItemCount);
  if ((nItemIndex > 0) && (nItemIndex <= nItemCount))
  {
    string sKeyToItemTag = sMerchantTag + "_BuyTag_" + IntToString(nItemIndex);
    sItemTag = GetLocalString(oModule, sKeyToItemTag);
  }

  return sItemTag;
}

/////////////////////////////////////////////////////////
string CnrMerchantGetSellTag(string sMerchantTag, int nItemIndex)
{
  string sItemTag = "INVALID_ITEM";
  object oModule = GetModule();

  // validate the index
  string sKeyToItemCount = sMerchantTag + "_SellCount";
  int nItemCount = GetLocalInt(oModule, sKeyToItemCount);
  if ((nItemIndex > 0) && (nItemIndex <= nItemCount))
  {
    string sKeyToItemTag = sMerchantTag + "_SellTag_" + IntToString(nItemIndex);
    sItemTag = GetLocalString(oModule, sKeyToItemTag);
  }

  return sItemTag;
}

/////////////////////////////////////////////////////////
int CnrMerchantGetBuyPrice(string sMerchantTag, int nItemIndex)
{
  int nItemPrice = 0;
  object oModule = GetModule();

  // validate the index
  string sKeyToItemCount = sMerchantTag + "_BuyCount";
  int nItemCount = GetLocalInt(oModule, sKeyToItemCount);
  if ((nItemIndex > 0) && (nItemIndex <= nItemCount))
  {
    string sKeyToItemPrice = sMerchantTag + "_BuyPrice_" + IntToString(nItemIndex);
    nItemPrice = GetLocalInt(oModule, sKeyToItemPrice);
  }

  return nItemPrice;
}

/////////////////////////////////////////////////////////
int CnrMerchantGetSellPrice(string sMerchantTag, int nItemIndex)
{
  int nItemPrice = 0;
  object oModule = GetModule();

  // validate the index
  string sKeyToItemCount = sMerchantTag + "_SellCount";
  int nItemCount = GetLocalInt(oModule, sKeyToItemCount);
  if ((nItemIndex > 0) && (nItemIndex <= nItemCount))
  {
    string sKeyToItemPrice = sMerchantTag + "_SellPrice_" + IntToString(nItemIndex);
    nItemPrice = GetLocalInt(oModule, sKeyToItemPrice);
  }

  return nItemPrice;
}

/////////////////////////////////////////////////////////
int CnrMerchantGetBuyInfinite(string sMerchantTag, int nItemIndex)
{
  int bBuyInfinite = FALSE;
  object oModule = GetModule();

  // validate the index
  string sKeyToItemCount = sMerchantTag + "_BuyCount";
  int nItemCount = GetLocalInt(oModule, sKeyToItemCount);
  if ((nItemIndex > 0) && (nItemIndex <= nItemCount))
  {
    string sKeyToBuyInfinite = sMerchantTag + "_BuyInfinite_" + IntToString(nItemIndex);
    bBuyInfinite = GetLocalInt(oModule, sKeyToBuyInfinite);
  }

  return bBuyInfinite;
}

/////////////////////////////////////////////////////////
int CnrMerchantGetSellInfinite(string sMerchantTag, int nItemIndex)
{
  int bSellInfinite = FALSE;
  object oModule = GetModule();

  // validate the index
  string sKeyToItemCount = sMerchantTag + "_SellCount";
  int nItemCount = GetLocalInt(oModule, sKeyToItemCount);
  if ((nItemIndex > 0) && (nItemIndex <= nItemCount))
  {
    string sKeyToSellInfinite = sMerchantTag + "_SellInfinite_" + IntToString(nItemIndex);
    bSellInfinite = GetLocalInt(oModule, sKeyToSellInfinite);
  }

  return bSellInfinite;
}

/////////////////////////////////////////////////////////
int CnrMerchantShowAsGreen(object oMerchant, int nMenuIndex)
{
  object oModule = GetModule();
  string sMerchantTag = GetTag(oMerchant);
  object oPC = GetPCSpeaker();

  string sKeyToCurrentMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  int nMenuPage = GetLocalInt(oPC, "nCnrMenuPage");

  int nSubMenuCount = GetLocalInt(oModule, sKeyToCurrentMenu + "_SubMenuCount");
  if (nSubMenuCount > 0)
  {
    // items don't display when there are sub menus
    return FALSE;
  }

  // The merchant menus display CMD_SELECTIONS_PER_PAGE items per page
  int nItemIndex = (nMenuPage * CMD_SELECTIONS_PER_PAGE) + nMenuIndex;
  string sMenuType = GetLocalString(oPC, "sCnrMenuType");

  // validate the index
  int nItemCount;
  if (sMenuType == "BUY")
  {
    nItemCount = CnrMerchantGetBuyCount(sKeyToCurrentMenu);
  }
  else // "SELL"
  {
    nItemCount = CnrMerchantGetSellCount(sKeyToCurrentMenu);
  }
  if ((nItemIndex == 0) || (nItemIndex > nItemCount))
  {
    return FALSE;
  }

  string sItemTag = "";
  object oItem;
  if (sMenuType == "BUY")
  {
    // see if PC speaker has an item with this tag
    sItemTag = CnrMerchantGetBuyTag(sKeyToCurrentMenu, nItemIndex);
    oItem = GetItemPossessedBy(oPC, sItemTag);
  }
  else // "SELL"
  {
    int bSellInfinite = CnrMerchantGetSellInfinite(sKeyToCurrentMenu, nItemIndex);
    if (bSellInfinite)
    {
      return TRUE;
    }

    // see if merchant has an item with this tag
    sItemTag = CnrMerchantGetSellTag(sKeyToCurrentMenu, nItemIndex);
    string sKeyToFlag = sMerchantTag + "_EnablePersistentInventory";
    int bEnablePersistentInventory = CnrGetPersistentInt(oModule, sKeyToFlag);
    if (bEnablePersistentInventory)
    {
      string sKeyToOnHandQty = sKeyToCurrentMenu + "_OnHandQty_" + sItemTag;
      int nOnHandQty = CnrGetPersistentInt(oMerchant, sKeyToOnHandQty);
      if (nOnHandQty > 0)
      {
        return TRUE;
      }
      return FALSE;
    }
    else
    {
      oItem = GetItemPossessedBy(oMerchant, sItemTag);
    }
  }

  if (oItem != OBJECT_INVALID)
  {
    return TRUE;
  }

  return FALSE;
}

/////////////////////////////////////////////////////////
int CnrMerchantShowAsRed(object oMerchant, int nMenuIndex)
{
  object oModule = GetModule();
  string sMerchantTag = GetTag(oMerchant);
  object oPC = GetPCSpeaker();

  string sKeyToCurrentMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  int nMenuPage = GetLocalInt(oPC, "nCnrMenuPage");

  int nSubMenuCount = GetLocalInt(oModule, sKeyToCurrentMenu + "_SubMenuCount");
  if (nSubMenuCount > 0)
  {
    // items don't display when there are sub menus
    return FALSE;
  }

  // The merchant menus display CMD_SELECTIONS_PER_PAGE items per page
  int nItemIndex = (nMenuPage * CMD_SELECTIONS_PER_PAGE) + nMenuIndex;
  string sMenuType = GetLocalString(oPC, "sCnrMenuType");

  // validate the index
  int nItemCount;
  if (sMenuType == "BUY")
  {
    nItemCount = CnrMerchantGetBuyCount(sKeyToCurrentMenu);
  }
  else // "SELL"
  {
    nItemCount = CnrMerchantGetSellCount(sKeyToCurrentMenu);
  }
  if ((nItemIndex == 0) || (nItemIndex > nItemCount))
  {
    return FALSE;
  }

  string sItemTag = "";
  object oItem;
  if (sMenuType == "BUY")
  {
    // see if PC speaker has an item with this tag
    sItemTag = CnrMerchantGetBuyTag(sKeyToCurrentMenu, nItemIndex);
    oItem = GetItemPossessedBy(oPC, sItemTag);
  }
  else // "SELL"
  {
    int bSellInfinite = CnrMerchantGetSellInfinite(sKeyToCurrentMenu, nItemIndex);
    if (bSellInfinite)
    {
      return FALSE;
    }

    // see if merchant has an item with this tag
    sItemTag = CnrMerchantGetSellTag(sKeyToCurrentMenu, nItemIndex);
    string sKeyToFlag = sMerchantTag + "_EnablePersistentInventory";
    int bEnablePersistentInventory = CnrGetPersistentInt(oModule, sKeyToFlag);
    if (bEnablePersistentInventory)
    {
      string sKeyToOnHandQty = sKeyToCurrentMenu + "_OnHandQty_" + sItemTag;
      int nOnHandQty = CnrGetPersistentInt(oMerchant, sKeyToOnHandQty);
      if (nOnHandQty == 0)
      {
        return TRUE;
      }
      return FALSE;
    }
    else
    {
      oItem = GetItemPossessedBy(oMerchant, sItemTag);
    }
  }

  if (oItem == OBJECT_INVALID)
  {
    return TRUE;
  }

  return FALSE;
}

/////////////////////////////////////////////////////////
void CnrMerchantCreateItemOnObject(string sItemTag, object oTarget, int nQty)
{
  CreateItemOnObject(sItemTag, oTarget, nQty);
}

/////////////////////////////////////////////////////////
void CnrMerchantBuyOrSellItem(object oMerchant, int nMenuIndex)
{
  object oPC = GetPCSpeaker();

  string sKeyToCurrentMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  int nMenuPage = GetLocalInt(oPC, "nCnrMenuPage");

  // The merchant menus display CMD_SELECTIONS_PER_PAGE items per page
  int nItemIndex = (nMenuPage * CMD_SELECTIONS_PER_PAGE) + nMenuIndex;
  string sMenuType = GetLocalString(oPC, "sCnrMenuType");
  object oModule = GetModule();
  string sMerchantTag = GetTag(oMerchant);
  string sKeyToFlag = sMerchantTag + "_EnablePersistentInventory";
  int bEnablePersistentInventory = CnrGetPersistentInt(oModule, sKeyToFlag);

  if (sMenuType == "BUY")
  {
    string sBuyTag = CnrMerchantGetBuyTag(sKeyToCurrentMenu, nItemIndex);
    int nBuyPrice = CnrMerchantGetBuyPrice(sKeyToCurrentMenu, nItemIndex);
    int bBuyInfinite = CnrMerchantGetBuyInfinite(sKeyToCurrentMenu, nItemIndex);

    //if (bEnablePersistentInventory && !bBuyInfinite)
    if (!bBuyInfinite)
    {
      string sKeyToMaxOnHandQty = sKeyToCurrentMenu + "_MaxOnHandQty_" + sBuyTag;
      string sKeyToOnHandQty = sKeyToCurrentMenu + "_OnHandQty_" + sBuyTag;
      int nMaxOnHandQty = GetLocalInt(oModule, sKeyToMaxOnHandQty);
      if (nMaxOnHandQty > 0) // if <= 0 use infinite
      {
        int nOnHandQty = CnrGetPersistentInt(oMerchant, sKeyToOnHandQty);
        if (nOnHandQty >= nMaxOnHandQty)
        {
          SetCustomToken(22000, "Sorry. I've got too many of those already.\n");
          return;
        }
      }
    }

    // if ResRef is not defined, then convert tag to ResRef
    string sBuyResRef = GetLocalString(oModule, "cnr_" + sBuyTag);
    if (sBuyResRef == "")
    {
      sBuyResRef = GetStringLowerCase(sBuyTag);
      if (GetStringLength(sBuyResRef) > 16)
      {
        sBuyResRef = GetStringLeft(sBuyResRef, 16);
      }
    }

    object oItem = GetItemPossessedBy(oPC, sBuyTag);
    if (oItem != OBJECT_INVALID)
    {
      int nStackSize = GetNumStackedItems(oItem);
      if (nStackSize == 1)
      {
        if (bBuyInfinite)
        {
          // just remove the item from the PC's inventory
          DestroyObject(oItem);
        }
        else
        {
          // if peristent inventory is enabled, do things a bit differently
          if (bEnablePersistentInventory)
          {
            DestroyObject(oItem);
            string sKeyToOnHandQty = sKeyToCurrentMenu + "_OnHandQty_" + sBuyTag;
            int nOnHandQty = CnrGetPersistentInt(oMerchant, sKeyToOnHandQty) + 1;
            CnrSetPersistentInt(oMerchant, sKeyToOnHandQty, nOnHandQty);
          }
          else
          {
            // move the item from the PC to the merchant
            AssignCommand(oMerchant, ActionTakeItem(oItem, oPC));
          }
        }
      }
      else
      {
        // split the stack
        DestroyObject(oItem);

        //CreateItemOnObject(sBuyTag, oPC, nStackSize-1);
        // BUG - DestroyObject is being executed AFTER CreateItemOnObject.
        // So DestroyObject is destroying stuff it shouldn't. By using the merchant's
        // queue, the order is corrected.
        AssignCommand(oMerchant, CnrMerchantCreateItemOnObject(sBuyResRef, oPC, nStackSize-1));

        if (!bBuyInfinite)
        {
          if (bEnablePersistentInventory)
          {
            string sKeyToOnHandQty = sKeyToCurrentMenu + "_OnHandQty_" + sBuyTag;
            int nOnHandQty = CnrGetPersistentInt(oMerchant, sKeyToOnHandQty) + 1;
            CnrSetPersistentInt(oMerchant, sKeyToOnHandQty, nOnHandQty);
          }
          else
          {
            CreateItemOnObject(sBuyResRef, oMerchant, 1);
          }
        }
      }
    }
    GiveGoldToCreature(oPC, nBuyPrice);
    SetCustomToken(22000, "Thanks. Please return with more anytime.\n");
  }
  else // "SELL"
  {
    string sSellTag = CnrMerchantGetSellTag(sKeyToCurrentMenu, nItemIndex);
    int nSellPrice = CnrMerchantGetSellPrice(sKeyToCurrentMenu, nItemIndex);
    int bSellInfinite = CnrMerchantGetSellInfinite(sKeyToCurrentMenu, nItemIndex);

    // Make sure the PC has enough gold to buy the item
    if (nSellPrice > GetGold(GetPCSpeaker()))
    {
      // The PC does not have enough gold to buy the item
      SetCustomToken(22000, "I'm sorry. It appears you don't have enough gold to buy that item.\n");
      return;
    }

    // if ResRef is not defined, then convert tag to ResRef
    string sSellResRef = GetLocalString(oModule, "cnr_" + sSellTag);
    if (sSellResRef == "")
    {
      sSellResRef = GetStringLowerCase(sSellTag);
      if (GetStringLength(sSellResRef) > 16)
      {
        sSellResRef = GetStringLeft(sSellResRef, 16);
      }
    }

    if (bSellInfinite)
    {
      CreateItemOnObject(sSellResRef, oPC, 1);
    }
    else
    {
      // if using persistent inventory, do things differently
      if (bEnablePersistentInventory)
      {
        string sKeyToOnHandQty = sKeyToCurrentMenu + "_OnHandQty_" + sSellTag;
        int nOnHandQty = CnrGetPersistentInt(oMerchant, sKeyToOnHandQty);
        if (nOnHandQty > 0)
        {
          CreateItemOnObject(sSellResRef, oPC, 1);
          CnrSetPersistentInt(oMerchant, sKeyToOnHandQty, nOnHandQty-1);
        }
      }
      else
      {
        object oItem = GetItemPossessedBy(oMerchant, sSellTag);
        if (oItem != OBJECT_INVALID)
        {
          int nStackSize = GetNumStackedItems(oItem);
          if (nStackSize == 1)
          {
            //DestroyObject(oItem);
            AssignCommand(oPC, ActionTakeItem(oItem, oMerchant));
          }
          else
          {
            // split the stack
            DestroyObject(oItem);

            //CreateItemOnObject(sSellTag, oMerchant, nStackSize-1);
            // BUG - DestroyObject is being executed AFTER CreateItemOnObject.
            // So DestroyObject is destroying stuff it shouldn't. By using the merchant's
            // queue, the order is corrected.
            AssignCommand(oMerchant, CnrMerchantCreateItemOnObject(sSellResRef, oMerchant, nStackSize-1));

            CreateItemOnObject(sSellResRef, oPC, 1);
          }
        }
      }
    }
    TakeGoldFromCreature(nSellPrice, oPC, TRUE);
    SetCustomToken(22000, "Thanks for purchasing my goods. I trust you will use the item properly.\n");
  }
}

/////////////////////////////////////////////////////////
void CnrMerchantDoSelection(int nSelIndex)
{
  object oPC = GetPCSpeaker();
  string sKeyToCurrentMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  int nMenuPage = GetLocalInt(oPC, "nCnrMenuPage");
  int nSubMenuCount = GetLocalInt(GetModule(), sKeyToCurrentMenu + "_SubMenuCount");
  if (nSubMenuCount == 0)
  {
    // The menu was displaying items
    CnrMerchantBuyOrSellItem(OBJECT_SELF, nSelIndex);
  }
  else
  {
    // The menu was displaying sub menus
    string sKeyToMenu = sKeyToCurrentMenu + "_" + IntToString((nMenuPage*CMD_SELECTIONS_PER_PAGE) + nSelIndex);
    SetLocalString(oPC, "sCnrCurrentMenu", sKeyToMenu);
    SetLocalInt(oPC, "nCnrMenuPage", 0);
    // cnr_ta_m_buysell will display the menu
  }
}

/////////////////////////////////////////////////////////
void CnrMerchantShowMenu(string sKeyToMenu, int nMenuPage)
{
  object oPC = GetPCSpeaker();
  SetLocalString(oPC, "sCnrCurrentMenu", sKeyToMenu);
  SetLocalInt(oPC, "nCnrMenuPage", nMenuPage);

  object oModule = GetModule();
  string sMerchantTag = GetTag(OBJECT_SELF);

  string sMenuType = GetLocalString(oPC, "sCnrMenuType");

  if (sMenuType == "TOP")
  {
    string sKeyToText = sMerchantTag + "_MGText";
    string sText = GetLocalString(oModule, sKeyToText);
    if (sText == "")
    {
      SetCustomToken(22010, "Are you looking to negotiate on something unique? I deal in select merchandise. Are you interested?");
    }
    else
    {
      SetCustomToken(22010, sText);
    }
    return;
  }
  else if (sMenuType == "BUY")
  {
    string sKeyToText = sMerchantTag + "_MBText";
    string sText = GetLocalString(oModule, sKeyToText);
    if (sText == "")
    {
      SetCustomToken(22010, "The following is a list of the items I will purchase. What do you wish to sell?\n");
    }
    else
    {
      SetCustomToken(22010, sText);
    }
  }
  else // "SELL"
  {
    string sKeyToText = sMerchantTag + "_MSText";
    string sText = GetLocalString(oModule, sKeyToText);
    if (sText == "")
    {
      SetCustomToken(22010, "The following is a list of the items I will sell. What do you wish to buy?\n");
    }
    else
    {
      SetCustomToken(22010, sText);
    }
  }

  string sKeyToCount = sKeyToMenu + "_SubMenuCount";
  int nSubCount = GetLocalInt(GetModule(), sKeyToCount);
  if (nSubCount > 0)
  {
    // this menu has submenus
    int nFirst = (nMenuPage * CMD_SELECTIONS_PER_PAGE) + 1;
    int nLast = (nMenuPage * CMD_SELECTIONS_PER_PAGE) + CMD_SELECTIONS_PER_PAGE;
    if (nLast >= nSubCount)
    {
      nLast = nSubCount;
    }

    int n;
    for (n=nFirst; n<=nLast; n++)
    {
      string sKey = sKeyToMenu + "_" + IntToString(n);

      string sTitle = GetLocalString(GetModule(), sKey);
      SetCustomToken(22001 + (n - nFirst), sTitle);
    }
  }
  else
  {
    int nItemIndexFirst = (nMenuPage * CMD_SELECTIONS_PER_PAGE) + 1;
    int nItemIndexLast = (nMenuPage * CMD_SELECTIONS_PER_PAGE) + CMD_SELECTIONS_PER_PAGE;

    int nItemIndex;
    for (nItemIndex=nItemIndexFirst; nItemIndex<=nItemIndexLast; nItemIndex++)
    {
      string sItemDesc;
      int nItemPrice;

      if (sMenuType == "BUY")
      {
        sItemDesc = CnrMerchantGetBuyDesc(sKeyToMenu, nItemIndex);
        nItemPrice = CnrMerchantGetBuyPrice(sKeyToMenu, nItemIndex);
      }
      else // "SELL"
      {
        sItemDesc = CnrMerchantGetSellDesc(sKeyToMenu, nItemIndex);
        nItemPrice = CnrMerchantGetSellPrice(sKeyToMenu, nItemIndex);
      }

      SetCustomToken(22001 + (nItemIndex - nItemIndexFirst), sItemDesc+", "+IntToString(nItemPrice)+"gp");
    }
  }

  SetLocalInt(oPC, "nCnrRedOffset", 1);
  SetLocalInt(oPC, "nCnrGrnOffset", 1);
  SetLocalInt(oPC, "nCnrSubOffset", 1);
}

/////////////////////////////////////////////////////////
int CnrMerchantShowAsSubMenu(object oPC, int menuIndex)
{
  string sKeyToMenu = GetLocalString(oPC, "sCnrCurrentMenu");
  int nMenuPage = GetLocalInt(oPC, "nCnrMenuPage");
  int nSubMenuCount = GetLocalInt(GetModule(), sKeyToMenu + "_SubMenuCount");
  if (nSubMenuCount > 0)
  {
    // we are displaying sub menus
    if (((nMenuPage * CMD_SELECTIONS_PER_PAGE) + menuIndex) <= nSubMenuCount)
    {
      return TRUE;
    }
  }
  return FALSE;
}
