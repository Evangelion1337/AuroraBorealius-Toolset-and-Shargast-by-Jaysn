/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnrTinkersDevice
//
//  Desc:  Recipe initialization.
//
//  Author: David Bobeck 15May03
//  Modified: Gary Corcoran 30Jul03
//
/////////////////////////////////////////////////////////
#include "cnr_recipe_utils"

void main()
{
  string sKeyToRecipe;

  PrintString("cnrTinkersDevice init");

  /////////////////////////////////////////////////////////
  // CNR recipes made by cnrTinkersDevice
  /////////////////////////////////////////////////////////
  string sMenuTinkerArrowheads = CnrRecipeAddSubMenu("cnrTinkersDevice", "Arrowheads");
  string sMenuTinkerWire = CnrRecipeAddSubMenu("cnrTinkersDevice", "Wire");
  string sMenuTinkerGears = CnrRecipeAddSubMenu("cnrTinkersDevice", "Gears");
  string sMenuTinkerMisc = CnrRecipeAddSubMenu("cnrTinkersDevice", "Misc Stuff");

  CnrRecipeSetDevicePreCraftingScript("cnrTinkersDevice", "cnr_tinker_anim");
  CnrRecipeSetDeviceInventoryTool("cnrTinkersDevice", "cnrTinkersTools", CNR_FLOAT_TINKERS_TOOLS_BREAKAGE_PERCENTAGE);
  CnrRecipeSetDeviceTradeskillType("cnrTinkersDevice", CNR_TRADESKILL_TINKERING);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerArrowheads, "Arrowheads, Plain (20)", "cnrArwHeadPlain", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotCopp", 4);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledCopp", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerArrowheads, "Arrowheads, Blunt (20)", "cnrArwHeadBlunt", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotBron", 4);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledBron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerArrowheads, "Arrowheads, Hooked (20)", "cnrArwHeadHooked", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 4);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledIron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerArrowheads, "Arrowheads, Silver (20)", "cnrArwHeadSilver", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotSilv", 4);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledSilv", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMisc, "Studs", "cnrStuds", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotBron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldStud", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMisc, "Iron Spikes", "cnrIronSpikes", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSpike", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerWire, "Copper Wire", "cnrWireCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotCopp", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerWire, "Tin Wire", "cnrWireTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotTin", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerWire, "Iron Wire", "cnrWireIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerWire, "Platinum Wire", "cnrWirePlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotPlat", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGears, "Copper Gears & Springs", "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotCopp", 4);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGears, "Tin Gears & Springs", "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotTin", 4);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGears, "Iron Gears & Springs", "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 4);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerGears, "Platinum Gears & Springs", "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotPlat", 4);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMisc, "Iron Hinge", "cnrHingeIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMisc, "Iron Lock", "cnrLockIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

//SoU Grenade items

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMisc, "Caltrops", "cnrCaltrops", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotBron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMisc, "Thunderstones", "cnrThunderstone", 5);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemFlawed001", 5);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagThunder", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

////////////////////////////////////////////////////////////////////////////////

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerMisc, "Compound Bow Cam", "cnrBowCam", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

}
