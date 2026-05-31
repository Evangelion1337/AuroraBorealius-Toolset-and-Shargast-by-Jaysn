/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnrTinkerToolbox
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

  PrintString("cnrTinkerToolbox init");

  /////////////////////////////////////////////////////////
  // CNR recipes made by cnrTinkerToolbox
  /////////////////////////////////////////////////////////
  string sMenuTinkerTools = CnrRecipeAddSubMenu("cnrTinkerToolbox", "Tools");
  string sMenuTinkerTrapsMinor = CnrRecipeAddSubMenu("cnrTinkerToolbox", "Minor Traps");
  string sMenuTinkerTrapsAverage = CnrRecipeAddSubMenu("cnrTinkerToolbox", "Average Traps");
  string sMenuTinkerTrapsStrong = CnrRecipeAddSubMenu("cnrTinkerToolbox", "Strong Traps");
  string sMenuTinkerTrapsDeadly = CnrRecipeAddSubMenu("cnrTinkerToolbox", "Deadly Traps");

  //CnrRecipeSetDevicePreCraftingScript("cnrTinkerToolbox", "cnr_tinker_anim");
  CnrRecipeSetDeviceInventoryTool("cnrTinkerToolbox", "cnrTinkersTools", CNR_FLOAT_TINKERS_TOOLS_BREAKAGE_PERCENTAGE);
  CnrRecipeSetDeviceTradeskillType("cnrTinkerToolbox", CNR_TRADESKILL_TINKERING);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Shovel", "cnrShovel", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftOak", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrMangledIron", 0, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 50, 25, 0, 25, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Skinning Knife", "cnrSkinningKnife", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 50, 25, 0, 25, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Carving Knife", "cnrCarvingKnife", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 50, 25, 0, 25, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Woodcutter's Axe", "cnrWoodCutterAxe", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 50, 25, 0, 25, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Miner's Pickaxe", "cnrMinersPickaxe", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 50, 25, 0, 25, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Smith's Hammer", "cnrSmithsHammer", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrShaftOak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 50, 25, 0, 25, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Gem Crafter's Chisel", "cnrGemChisel", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMoldSmall", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 50, 25, 0, 25, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Gem Crafter's Tools", "cnrGemTools", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeatherPouch", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Tinker's Tools", "cnrTinkersTools", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeatherPouch", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Carpenter's Tools", "cnrCarpsTools", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeatherPouch", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTools, "Sewing Kit", "cnrSewingKit", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIngotIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeatherPouch", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSpiderSilk", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  //
  // -------------------------   minor traps ------------------------------
  //
  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Spike Trap", "NW_IT_TRAP001", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIronSpikes", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Acid Trap", "NW_IT_TRAP033", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagAcid", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Sonic Trap", "NW_IT_TRAP037", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagThunder", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Frost Trap", "NW_IT_TRAP029", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFrost", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Holy Trap", "NW_IT_TRAP005", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHolyWater", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Tangle Trap", "NW_IT_TRAP009", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrRope", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Fire Trap", "NW_IT_TRAP017", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFire", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Electrical Trap", "NW_IT_TRAP021", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagSparks", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsMinor, "Minor Gas Trap", "NW_IT_TRAP025", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPoisonGas", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsCopp", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireCopp", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  //
  // -------------------------   average traps ------------------------------
  //
  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Spike Trap", "NW_IT_TRAP002", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIronSpikes", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Acid Trap", "NW_IT_TRAP034", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagAcid", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Sonic Trap", "NW_IT_TRAP038", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagThunder", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Frost Trap", "NW_IT_TRAP030", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFrost", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Holy Trap", "NW_IT_TRAP006", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHolyWater", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Tangle Trap", "NW_IT_TRAP010", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrRope", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Fire Trap", "NW_IT_TRAP018", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFire", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Electrical Trap", "NW_IT_TRAP022", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagSparks", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsAverage, "Average Gas Trap", "NW_IT_TRAP026", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPoisonGas", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsTin", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireTin", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  //
  // -------------------------   strong traps ------------------------------
  //
  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Spike Trap", "NW_IT_TRAP003", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIronSpikes", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Acid Trap", "NW_IT_TRAP035", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagAcid", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Sonic Trap", "NW_IT_TRAP039", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagThunder", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Frost Trap", "NW_IT_TRAP031", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFrost", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Holy Trap", "NW_IT_TRAP007", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHolyWater", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Tangle Trap", "NW_IT_TRAP011", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrRope", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Fire Trap", "NW_IT_TRAP019", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFire", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Electrical Trap", "NW_IT_TRAP023", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagSparks", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsStrong, "Strong Gas Trap", "NW_IT_TRAP027", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPoisonGas", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsIron", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWireIron", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  //
  // -------------------------   deadly traps ------------------------------
  //
  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Spike Trap", "NW_IT_TRAP004", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrIronSpikes", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Acid Trap", "NW_IT_TRAP036", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagAcid", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Sonic Trap", "NW_IT_TRAP040", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagThunder", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Frost Trap", "NW_IT_TRAP032", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFrost", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Holy Trap", "NW_IT_TRAP008", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHolyWater", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Tangle Trap", "NW_IT_TRAP012", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrRope", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Fire Trap", "NW_IT_TRAP020", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagFire", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Electrical Trap", "NW_IT_TRAP024", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBagSparks", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTinkerTrapsDeadly, "Deadly Gas Trap", "NW_IT_TRAP028", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPoisonGas", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGearsPlat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWirePlat", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 50, 0, 50, 0, 0);

}
