/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx & Hrnac
//
//  Name:  cnrHideRack
//
//  Desc:  Recipe initialization.
//
//  Author: Gary Corcoran 05Aug03
//
/////////////////////////////////////////////////////////
#include "cnr_recipe_utils"

void main()
{
  string sKeyToRecipe;

  PrintString("cnrHideRack init");

  /////////////////////////////////////////////////////////
  //  CNR Crafting Device "cnrHideRack"
  /////////////////////////////////////////////////////////
  string sMenuTailorLeathers = CnrRecipeAddSubMenu("cnrHideRack", "Leathers");

  CnrRecipeSetDevicePreCraftingScript("cnrHideRack", "cnr_hide_anim");
//CnrRecipeSetDeviceInventoryTool("cnrHideRack", "cnrSewingKit", CNR_FLOAT_SEWING_KIT_BREAKAGE_PERCENTAGE);
//CnrRecipeSetDeviceEquippedTool("cnrHideRack", "cnr");
  CnrRecipeSetDeviceTradeskillType("cnrHideRack", CNR_TRADESKILL_TAILORING);


//////////////////////////////////////////////////////////////////////////////////////

/*  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Small Piece of Leather", "cnrLeatherSm", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCuredSm", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Medium Piece of Leather", "cnrLeatherMed", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCuredMed", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Large Piece of Leather", "cnrLeatherLg", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCuredLg", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0); */

//////////////////////////////////////////////
//New CNR Tailoring items by LasCivious     //
//Modified by Hrnac 07-10-03                //
//////////////////////////////////////////////

// LEATHERS

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Bat Leather", "cnrLeathBat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureBat", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Rat Leather", "cnrLeathRat", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureRat", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Badger Leather", "cnrLeathBadg", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureBadg", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Boar Leather", "cnrLeathBoar", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureBoar", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Deer Leather", "cnrLeathDeer", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureDeer", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Black Bear Leather", "cnrLeathBlac", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureBlac", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Cougar Leather", "cnrLeathCoug", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureCoug", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Wolf Leather", "cnrLeathWolf", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureWolf", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Winter Wolf Leather", "cnrLeathWint", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureWint", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Leopard Leather", "cnrLeathLeop", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureLeop", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Panther Leather", "cnrLeathPant", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCurePant", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Crag Leather", "cnrLeathCrag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureCrag", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Jaguar Leather", "cnrLeathJagu", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureJagu", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Lion Leather", "cnrLeathLion", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureLion", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Worg Leather", "cnrLeathWorg", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureWorg", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "White Stag Leather", "cnrLeathStag", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureStag", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Brown Bear Leather", "cnrLeathBrow", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureBrow", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Grizzly Leather", "cnrLeathGriz", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureGriz", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Polar Leather", "cnrLeathPola", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCurePola", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Malar Leather", "cnrLeathMala", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureMala", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Dire Tiger Leather", "cnrLeathTige", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureTige", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuTailorLeathers, "Dire Bear Leather", "cnrLeathDB", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHideCureDB", 1, 0);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrOilTanning", 1, 0);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 65, 0, 35, 0, 0);

}





