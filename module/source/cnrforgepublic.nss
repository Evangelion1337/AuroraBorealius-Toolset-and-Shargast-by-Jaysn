/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnrForgePublic
//
//  Desc:  Recipe initialization.
//
//  Author: David Bobeck 15May03
//
/////////////////////////////////////////////////////////
#include "cnr_recipe_utils"

void main()
{
  string sKeyToRecipe;

  PrintString("cnrForgePublic init");

  /////////////////////////////////////////////////////////
  // CNR recipes made by cnrForgePublic
  /////////////////////////////////////////////////////////
  CnrRecipeSetDevicePreCraftingScript("cnrForgePublic", "cnr_forge_anim");
  CnrRecipeSetDeviceTradeskillType("cnrForgePublic", CNR_TRADESKILL_SMELTING);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Copper Ingot(s)", "cnrIngotCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Tin Ingot(s)", "cnrIngotTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Bronze Ingot(s)", "cnrIngotBron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Iron Ingot(s)", "cnrIngotIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Gold Ingot(s)", "cnrIngotGold", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetGold", 2, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Platinum Ingot(s)", "cnrIngotPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetPlat", 2, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Adamantium Ingot(s)", "cnrIngotAdam", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetAdam", 2, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Cobalt Ingot(s)", "cnrIngotCoba", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetCoba", 2, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Silver Ingot(s)", "cnrIngotSilv", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetSilv", 3, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Titanium Ingot(s)", "cnrIngotTita", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetTita", 3, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe("cnrForgePublic", "Mithril Ingot(s)", "cnrIngotMith", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrNuggetMith", 3, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 25, 75, 0, 0, 0, 0);


}
