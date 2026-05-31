/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnrTailorsTable
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

  PrintString("cnrTailorsTable init");

  /////////////////////////////////////////////////////////
  //  CNR Crafting Device "cnrTailorsTable"
  /////////////////////////////////////////////////////////
  string sMenuTailorCloths = CnrRecipeAddSubMenu("cnrTailorsTable", "Cloths");
  string sMenuTailorLeathArmor = CnrRecipeAddSubMenu("cnrTailorsTable", "Leather Armor");
  string sMenuTailorHideArmor = CnrRecipeAddSubMenu("cnrTailorsTable", "Hide Armor");
  string sMenuTailorStdLthArmor = CnrRecipeAddSubMenu("cnrTailorsTable", "Studded Armor");
  string sMenuTailorProducts = CnrRecipeAddSubMenu("cnrTailorsTable", "Products");
  string sMenuTailorKits = CnrRecipeAddSubMenu("cnrTailorsTable", "Healing Kits");
  string sMenuTailorSpecials = CnrRecipeAddSubMenu("cnrTailorsTable", "Specials");

  CnrRecipeSetDevicePreCraftingScript("cnrTailorsTable", "cnr_tailor_anim");
  CnrRecipeSetDeviceInventoryTool("cnrTailorsTable", "cnrSewingKit", CNR_FLOAT_SEWING_KIT_BREAKAGE_PERCENTAGE);
  //CnrRecipeSetDeviceEquippedTool("cnrTailorsTable", "cnr");
  CnrRecipeSetDeviceTradeskillType("cnrTailorsTable", CNR_TRADESKILL_TAILORING);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Cloth", "cnrCloth", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCotton", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Cloth Padding", "cnrPadding", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCotton", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Cloth Pattern", "cnrPattern", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBookPatterns", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBookPatterns", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

/////////////////////////Armor Pattern Recipes//////////////////////////////

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Pattern for Chain Shirt", "cnrPatChainShirt", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBookPatterns", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBookPatterns", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Pattern for Scale Mail", "cnrPatScaleMail", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBookPatterns", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBookPatterns", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Pattern for Chain Mail", "cnrPatChainMail", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBookPatterns", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBookPatterns", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Pattern for Banded Mail", "cnrPatBandedMail", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBookPatterns", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBookPatterns", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Pattern for Splint Mail", "cnrPatSplintMail", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBookPatterns", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBookPatterns", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Pattern for Half Plate", "cnrPatHalfPlate", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBookPatterns", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBookPatterns", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorCloths, "Pattern for Full Plate", "cnrPatFullPlate", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBookPatterns", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrBookPatterns", 1, 1);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

//////////////////////////////////////////////////////////////////////////////////////

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Leather Pouch", "cnrLeatherPouch", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathBadg", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Tanglefoot Bag", "cnrTangleBag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeatherPouch", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "NW_IT_MSMLMISC07", 1, 0); //Ettercap Silk Gland
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

//Magic Bags by LasCivious. Levels modified by Hrnac.

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Cougar Bag", "cnrBag20", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathCoug", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilEnchanting", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Crag Cat Bag", "cnrBag40", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathCrag", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilEnchanting", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Lion Bag", "cnrBag60", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathLion", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilEnchanting", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Malar Bag", "cnrBag80", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathMala", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilEnchanting", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 15);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 150, 150);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Bow String", "cnrBowString", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSpiderSilk", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

// Slings added by Zaskar Tymerial. Modified by Hrnac to adjust crafting levels

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Cloth Sling", "cnrSlingCloth", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Silk Sling", "cnrSlingSilk", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSpiderSilk", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Leather Sling", "cnrSlingLeat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathDeer", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Cloak", "cnrCloak", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorProducts, "Padded Armor", "cnrArmorPadded", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPadding", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

//////////////////////////////////////////////
//New CNR Tailoring items by LasCivious     //
//Modified by Hrnac 07-10-03                //
//////////////////////////////////////////////

// LEATHER ARMOR

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Leather Armor", "cnrArmorLeather", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathDeer", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Black Leather Armor", "cnrArmorLthBlac", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathBlac", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Leopard Leather Armor", "cnrArmorLthLeop", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathLeop", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Cougar Leather Armor", "cnrArmorLthCoug", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathCoug", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Jaguar Leather Armor", "cnrArmorLthJagu", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathJagu", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Panther Leather Armor", "cnrArmorLthPant", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathPant", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Crag Leather Armor", "cnrArmorLthCrag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathCrag", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Worg Leather Armor", "cnrArmorLthWorg", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathWorg", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "White Stag Leather Armor", "cnrArmorLthStag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathStag", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Brown Leather Armor", "cnrArmorLthBrow", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathBrow", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Grizzly Leather Armor", "cnrArmorLthGrizzly", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathGriz", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Lion Leather Armor", "cnrArmorLthLion", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathLion", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Polar Leather Armor", "cnrArmorLthPola", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathPola", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Malar Leather Armor", "cnrArmorLthMala", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathMala", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Dire Tiger Leather Armor", "cnrArmorLthTige", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathTige", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathArmor, "Dire Bear Leather Armor", "cnrArmorLthDB", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathDB", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

// HIDE ARMOR

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Hide Armor", "cnrArmorHideDeer", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureDeer", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Black Hide Armor", "cnrArmorHideBlac", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureBlac", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Leopard Hide Armor", "cnrArmorHideLeop", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureLeop", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Cougar Hide Armor", "cnrArmorHideCoug", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureCoug", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Jaguar Hide Armor", "cnrArmorHideJagu", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureJagu", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Panther Hide Armor", "cnrArmorHidePant", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCurePant", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Crag Hide Armor", "cnrArmorHideCrag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureCrag", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Worg Hide Armor", "cnrArmorHideWorg", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureWorg", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "White Stag Hide Armor", "cnrArmorHideStag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureStag", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Brown Hide Armor", "cnrArmorHideBrow", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureBrow", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Grizzly Hide Armor", "cnrArmorHideGriz", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureGriz", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Lion Hide Armor", "cnrArmorHideLion", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureLion", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Polar Hide Armor", "cnrArmorHidePola", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCurePola", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Malar Hide Armor", "cnrArmorHideMala", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureMala", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Dire Tiger Hide Armor", "cnrArmorHideTige", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureTige", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorHideArmor, "Dire Bear Hide Armor", "cnrArmorHideDB", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureDB", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloth", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

// STUDDED ARMOR

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Armor", "cnrArmorStudded", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathDeer", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Black Armor", "cnrArmorStdBlac", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathBlac", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Leopard Armor", "cnrArmorStdLeop", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathLeop", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Cougar Armor", "cnrArmorStdCoug", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathCoug", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Jaguar Armor", "cnrArmorStdJagu", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathJagu", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Panther Armor", "cnrArmorStdPant", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathPant", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Crag Armor", "cnrArmorStdCrag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathCrag", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 13);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 130, 130);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Worg Armor", "cnrArmorStdWorg", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathWorg", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 13);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 130, 130);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded White Stag Armor", "cnrArmorStdStag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathStag", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 13);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 130, 130);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Brown Armor", "cnrArmorStdBrow", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathBrow", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 14);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 140, 140);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Grizzly Armor", "cnrArmorStdGriz", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathGriz", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 14);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 140, 140);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Lion Armor", "cnrArmorStdLion", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathLion", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 14);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 140, 140);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Polar Armor", "cnrArmorStdPola", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathPola", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 15);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 150, 150);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Malar Armor", "cnrArmorStdMala", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathMala", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 15);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 150, 150);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Dire Tiger Armor", "cnrArmorStdTige", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathTige", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 15);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 150, 150);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 0, 35, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorStdLthArmor, "Studded Dire Bear Armor", "cnrArmorStdDB", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeathDB", 5, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPattern", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStuds", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 15);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 150, 150);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

// HEALING KITS by Forsetti

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorKits, "Healing Kit +1", "NW_IT_MEDKIT001", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCotton", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAloeLeaf", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGarlicClove", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 0, 35, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorKits, "Healing Kit +3", "NW_IT_MEDKIT002", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCotton", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAloeLeaf", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGarlicClove", 2, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrComfreyRoot", 2, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 0, 35, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorKits, "Healing Kit +6", "NW_IT_MEDKIT003", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCotton", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAloeLeaf", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGarlicClove", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrComfreyRoot", 3, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGingerRoot", 3, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 0, 35, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorKits, "Healing Kit +10", "NW_IT_MEDKIT004", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCotton", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAloeLeaf", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGarlicClove", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrComfreyRoot", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGingerRoot", 4, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGinsengRoot", 4, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 14);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 140, 140);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 0, 35, 0);

}





