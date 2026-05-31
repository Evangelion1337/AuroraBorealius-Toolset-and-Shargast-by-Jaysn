/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnrCuringTub
//
//  Desc:  Recipe initialization.
//
//  Author: David Bobeck 15May03
//  Modified: Gary Corcoran 05Aug03
//
/////////////////////////////////////////////////////////
#include "cnr_recipe_utils"

void main()
{
  string sKeyToRecipe;

  PrintString("cnrCuringTub init");

  /////////////////////////////////////////////////////////
  //  CNR Crafting Device "cnrCuringTub"
  /////////////////////////////////////////////////////////
  string sMenuHidesSmall = CnrRecipeAddSubMenu("cnrCuringTub", "Small Hides");
  string sMenuHidesMedium = CnrRecipeAddSubMenu("cnrCuringTub", "Medium Hides");
  string sMenuHidesLarge = CnrRecipeAddSubMenu("cnrCuringTub", "Large Hides");

  CnrRecipeSetDevicePreCraftingScript("cnrCuringTub", "cnr_curing_anim");
  //CnrRecipeSetDeviceInventoryTool("cnrCuringTub", "cnr");
  //CnrRecipeSetDeviceEquippedTool("cnrCuringTub", "cnr");
  CnrRecipeSetDeviceTradeskillType("cnrCuringTub", CNR_TRADESKILL_TAILORING);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesSmall, "Cured Bat Hide", "cnrHideCureBat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinBat", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesSmall, "Cured Rat Hide", "cnrHideCureRat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinRat", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesSmall, "Cured Badger Hide", "cnrHideCureBadg", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinBadger", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesMedium, "Cured Boar Hide", "cnrHideCureBoar", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinBoar", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Deer Hide", "cnrHideCureDeer", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinDeer", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Black Bear Hide", "cnrHideCureBlac", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinBlkBear", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesMedium, "Cured Cougar Hide", "cnrHideCureCoug", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinCougar", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesMedium, "Cured Wolf Hide", "cnrHideCureWolf", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinWolf", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesMedium, "Cured Winter Wolf Hide", "cnrHideCureWint", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinWinWolf", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesMedium, "Cured Leopard Hide", "cnrHideCureLeop", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinLeopard", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesMedium, "Cured Panther Hide", "cnrHideCurePant", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinPanther", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesMedium, "Cured Crag Hide", "cnrHideCureCrag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinCragCat", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesMedium, "Cured Jaguar Hide", "cnrHideCureJagu", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinJaguar", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Lion Hide", "cnrHideCureLion", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinLion", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Worg Hide", "cnrHideCureWorg", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinWorg", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured White Stag Hide", "cnrHideCureStag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinWhiteStag", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Dire Tiger Hide", "cnrHideCureTige", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinTiger", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Brown Bear Hide", "cnrHideCureBrow", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinBrnBear", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Grizzly Hide", "cnrHideCureGriz", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinGrizBear", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Malar Hide", "cnrHideCureMala", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinMalar", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Polar Hide", "cnrHideCurePola", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinPolarBear", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuHidesLarge, "Cured Dire Bear Hide", "cnrHideCureDB", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSalt", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAcidTanning", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkinDB", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

}
