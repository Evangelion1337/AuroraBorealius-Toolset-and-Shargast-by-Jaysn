/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnrTinkerFurnace
//
//  Desc:  Recipe initialization.
//
//  Author: David Bobeck 15May03
//  Modified: Gary Corcoran 19May03
//
/////////////////////////////////////////////////////////
#include "cnr_recipe_utils"

void main()
{
  string sKeyToRecipe;

  PrintString("cnrTinkerFurnace init");

  /////////////////////////////////////////////////////////
  // CNR recipes made by cnrTinkerFurnace
  /////////////////////////////////////////////////////////
  string sMenuTinkerMolds = CnrRecipeAddSubMenu("cnrTinkerFurnace", "Molds");
  string sMenuTinkerGlass = CnrRecipeAddSubMenu("cnrTinkerFurnace", "Glass");

  CnrRecipeSetDevicePreCraftingScript("cnrTinkerFurnace", "cnr_forge_anim");
  CnrRecipeSetDeviceTradeskillType("cnrTinkerFurnace", CNR_TRADESKILL_TINKERING);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Small Casting Mold", "cnrMoldSmall", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Medium Casting Mold", "cnrMoldMedium", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Large Casting Mold", "cnrMoldLarge", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 3);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Ring Mold", "cnrMoldRing", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Necklace Mold", "cnrMoldNecklace", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Scarab Mold", "cnrMoldScarab", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Amulet Mold", "cnrMoldAmulet", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Iron Spike Mold", "cnrMoldSpike", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Bronze Stud Mold", "cnrMoldStud", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMolds, "Helm Mold", "cnrMoldHelm", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLumpOfClay", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGlass, "Ingot of Glass", "cnrIngotGlass", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagOfSand", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGlass, "Glass Vial", "cnrGlassVial", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotGlass", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGlass, "Empty Flask", "cnrEmptyFlask", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotGlass", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGlass, "Juice Bottle", "cnrEmptyJuice", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotGlass", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGlass, "Brewing Bottle", "cnrBrewingBottle", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotGlass", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

}
