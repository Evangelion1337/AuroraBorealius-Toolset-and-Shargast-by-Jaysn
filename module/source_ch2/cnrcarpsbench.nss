/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnrCarpsBench
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

  PrintString("cnrCarpsBench init");

  /////////////////////////////////////////////////////////
  // CNR recipes made by cnrCarpsBench
  /////////////////////////////////////////////////////////
  string sMenuCarpTimbers = CnrRecipeAddSubMenu("cnrCarpsBench", "Timbers");
  string sMenuCarpMisc = CnrRecipeAddSubMenu("cnrCarpsBench", "Misc");
  string sMenuCarpWeapons = CnrRecipeAddSubMenu("cnrCarpsBench", "Weapons");
  string sMenuCarpArrows = CnrRecipeAddSubMenu("cnrCarpsBench", "Arrows");
  string sMenuCarpBolts = CnrRecipeAddSubMenu("cnrCarpsBench", "Bolts");
  string sMenuCarpBows = CnrRecipeAddSubMenu("cnrCarpsBench", "Bows");

  string sMenuBowsOak = CnrRecipeAddSubMenu(sMenuCarpBows, "Oak");
  string sMenuBowsHic = CnrRecipeAddSubMenu(sMenuCarpBows, "Hickory");
  string sMenuBowsMah = CnrRecipeAddSubMenu(sMenuCarpBows, "Mahogany");


  CnrRecipeSetDevicePreCraftingScript("cnrCarpsBench", "cnr_carp_anim");
  CnrRecipeSetDeviceInventoryTool("cnrCarpsBench", "cnrCarpsTools", CNR_FLOAT_CARPS_TOOLS_BREAKAGE_PERCENTAGE);
  CnrRecipeSetDeviceTradeskillType("cnrCarpsBench", CNR_TRADESKILL_WOOD_CRAFTING);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Hickory Shaft", "cnrShaftHick", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchHic", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Oak Shaft", "cnrShaftOak", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchOak", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Mahogany Shaft", "cnrShaftMahog", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchMah", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Shafts for Arrows (20)", "cnrShaftsArrow", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchHic", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Shafts for Bolts (20)", "cnrShaftsBolt", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchMah", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Plank of Oak", "cnrPlankOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchOak", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Plank of Hickory", "cnrPlankHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchHic", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Plank of Mahogany", "cnrPlankMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchMah", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Short Stave of Hickory", "cnrStaveShortHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchHic", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Long Stave of Hickory", "cnrStaveLongHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchHic", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Short Stave of Mahogany", "cnrStaveShortMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchMah", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Long Stave of Mahogany", "cnrStaveLongMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchMah", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Short Stave of Oak", "cnrStaveShortOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchOak", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpTimbers, "Long Stave of Oak", "cnrStaveLongOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchOak", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpMisc, "Empty Water Bucket", "cnrBucketEmpty", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPlankHic", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpMisc, "Torch", "cnrTorch", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStaveShortHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrRope", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOil", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Wooden Spear", "cnrSpearWood", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchHic", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Wood Club", "cnrClubWood", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchHic", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Wooden Quarterstaff", "cnrQStaffWood", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBranchHic", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBagOfSawDust", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Bronze Shod Club", "cnrClubBron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotBron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrClubWood", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledBron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Bronze Shod Quarterstaff", "cnrQStaffBron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotBron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrQStaffWood", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledBron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Iron Shod Club", "cnrClubIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrClubWood", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledIron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Iron Shod Quarterstaff", "cnrQStaffIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrQStaffWood", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledIron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Silver-Coated Club", "cnrClubSilv", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEnchIngotSilv", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHolyWater", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrClubBron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledBron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Silver Shod Quarterstaff", "cnrQStaffSilv", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEnchIngotSilv", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHolyWater", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrQStaffBron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledBron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Titanium-Tipped Club", "cnrClubTita", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEnchIngotTita", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssPower", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrClubIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledIron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpWeapons, "Titanium Shod Quarterstaff", "cnrQStaffTita", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEnchIngotTita", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssPower", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrQStaffIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 12, 12);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledIron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Plain (20)", "cnrArrowPlain", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadPlain", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherRaven", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Plain (20)", "cnrBoltPlain", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadPlain", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherRaven", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Crushing (20)", "cnrArrowCrushing", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadBlunt", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherRaven", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Crushing (20)", "cnrBoltCrushing", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadBlunt", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherRaven", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Piercing (20)", "cnrArrowPiercing", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadHooked", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherRaven", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Piercing (20)", "cnrBoltPiercing", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadHooked", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherRaven", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Ice (20)", "cnrArrowIce", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadBlunt", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFrost", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Ice (20)", "cnrBoltIce", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadBlunt", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFrost", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Thunder (20)", "cnrArrowThunder", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadBlunt", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagThunder", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Thunder (20)", "cnrBoltThunder", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadBlunt", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagThunder", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Poison (20)", "cnrArrowPoison", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadPlain", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagPoison", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Poison (20)", "cnrBoltPoison", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadPlain", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagPoison", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Holy (20)", "cnrArrowHoly", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadSilver", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHolyWater", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Holy (20)", "cnrBoltHoly", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadSilver", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHolyWater", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Lightning (20)", "cnrArrowLightng", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadHooked", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagLightning", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Lightning (20)", "cnrBoltLightng", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadHooked", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagLightning", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Acid (20)", "cnrArrowAcid", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadPlain", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagAcid", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Acid (20)", "cnrBoltAcid", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadPlain", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagAcid", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpArrows, "Bundle of Arrows, Fire (20)", "cnrArrowFire", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsArrow", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadPlain", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFire", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 13);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 130, 130);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuCarpBolts, "Bundle of Bolts, Fire (20)", "cnrBoltFire", 20);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftsBolt", 1);  // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrArwHeadPlain", 1); // set of 20
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherFalcon", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFire", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 13);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 130, 130);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  // ---------------------------- bows ------------------------------------
  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsHic, "Hickory Short Bow", "cnrShortBowHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStaveShortHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsHic, "Hickory Light Crossbow", "cnrLightBowHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPlankHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsHic, "Hickory Long Bow", "cnrLongBowHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStaveLongHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsHic, "Hickory Heavy Crossbow", "cnrHeavyBowHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPlankHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsOak, "Oak Short Bow", "cnrShortBowOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStaveShortOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsOak, "Oak Light Crossbow", "cnrLightBowOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPlankOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsOak, "Oak Long Bow", "cnrLongBowOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStaveLongOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsOak, "Oak Heavy Crossbow", "cnrHeavyBowOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPlankOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsMah, "Mahogany Short Bow", "cnrShortBowMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStaveShortMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsMah, "Mahogany Light Crossbow", "cnrLightBowMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPlankMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsMah, "Mahogany Long Bow", "cnrLongBowMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStaveLongMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsMah, "Mahogany Heavy Crossbow", "cnrHeavyBowMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPlankMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowString", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsHic, "Compound Hickory Short Bow", "cnrCoShortBowHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShortBowHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowCam", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsHic, "Compound Hickory Long Bow", "cnrCoLongBowHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLongBowHic", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowCam", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsOak, "Compound Oak Short Bow", "cnrCoShortBowOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShortBowOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowCam", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsOak, "Compound Oak Long Bow", "cnrCoLongBowOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLongBowOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowCam", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsMah, "Compound Mahogany Short Bow", "cnrCoShortBowMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShortBowMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowCam", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuBowsMah, "Compound Mahogany Long Bow", "cnrCoLongBowMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLongBowMah", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBowCam", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 45, 55, 0, 0, 0, 0);

}
