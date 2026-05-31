/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnrAlchemyTable
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

  PrintString("cnrAlchemyTable init");

  /////////////////////////////////////////////////////////
  // CNR recipes made by cnrAlchemyTable
  /////////////////////////////////////////////////////////
  string sMenuAlchemyOils = CnrRecipeAddSubMenu("cnrAlchemyTable", "Oils and Acids");
  string sMenuAlchemyEssenses = CnrRecipeAddSubMenu("cnrAlchemyTable", "Essenses");
  string sMenuAlchemyPotions = CnrRecipeAddSubMenu("cnrAlchemyTable", "Potions");
  string sMenuAlchemyMisc = CnrRecipeAddSubMenu("cnrAlchemyTable", "Misc. Items");

  CnrRecipeSetDevicePreCraftingScript("cnrAlchemyTable", "cnr_alchemy_anim");
  //CnrRecipeSetDeviceInventoryTool("cnrAlchemyTable", "");
  CnrRecipeSetDeviceTradeskillType("cnrAlchemyTable", CNR_TRADESKILL_ALCHEMY);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyOils, "Enchanting Oil", "cnrOilEnchanting", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "NW_IT_MSMLMISC13", 1); // Skeleton Knuckle
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMushroomWht", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyOils, "Polishing Oil", "cnrOilPolishing", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBlkCohoshRoot", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMushroomSpot", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyOils, "Tanning Acid", "cnrAcidTanning", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "NW_IT_MSMLMISC08", 1); // Fire Beetle Belly
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust002", 1); // Fire Agate Dust
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyOils, "Tanning Oil", "cnrOilTanning", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "NW_IT_MSMLMISC08", 1); // Fire Beetle Belly
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMushroomRed", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Bless", "cnrEssBless", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAngelicaLeaf", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWalnutFruit", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Cure", "cnrEssCure", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAloeLeaf", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust001", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Knowledge", "cnrEssKnowledge", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPepmintLeaf", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAlmondOil", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 1);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 10, 10);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Bless", "NW_IT_MPOTION009", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssBless", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust007", 2);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  if (CNR_BOOL_ENABLE_HCR_ITEM_CRAFTING)
  {
    sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cure Light Wounds", "PotionOfCLW", 1);
  }
  else
  {
    sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cure Light Wounds", "NW_IT_MPOTION001", 1);
  }
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssCure", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGarlicClove", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Lore", "NW_IT_MPOTION019", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssKnowledge", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSageLeaf", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Bark", "cnrEssBark", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust002", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHazelnutFruit", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Power", "cnrEssPower", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust014", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCrnberryJuice", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Grace", "cnrEssGrace", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrAlmondFruit", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEldberryJuice", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 3);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 30, 30);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Barkskin", "NW_IT_MPOTION005", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssBark", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBirchBark", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Bull's Strength", "NW_IT_MPOTION015", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssPower", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHawthornFwr", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cat's Grace", "NW_IT_MPOTION014", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssGrace", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCatnipLeaf", 1);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 4);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 40, 40);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Restore", "cnrEssRestore", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrChestnutFruit", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust004", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Cunning", "cnrEssCunning", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrChamomileFwr", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPecanOil", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 5);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 50, 50);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  if (CNR_BOOL_ENABLE_HCR_ITEM_CRAFTING)
  {
    sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cure Moderate Wounds", "PotionOfCMW", 1);
  }
  else
  {
    sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cure Moderate Wounds", "NW_IT_MPOTION020", 1);
  }
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssCure", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrComfryRoot", 2);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Lesser Restoration", "NW_IT_MPOTION011", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssRestore", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust003", 3);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Fox's Cunning", "NW_IT_MPOTION017", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssCunning", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGraveyardDirt", 2);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 6);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 60, 60);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Charm", "cnrEssCharm", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrCloverLeaf", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHazelnutOil", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Wisdom", "cnrEssWisdom", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrPecanFruit", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrChestnutOil", 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 7);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 70, 70);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Eagle's Splendor", "NW_IT_MPOTION010", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssCharm", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHazelLeaf", 3);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Aid", "NW_IT_MPOTION016", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssCure", 3);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust015", 3);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Owl's Wisdom", "NW_IT_MPOTION018", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssWisdom", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrFeatherOwl", 3);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 8);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 80, 80);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Vanishing", "cnrEssVanishing", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrSkullcapLeaf", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust011", 3);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Speed", "cnrEssSpeed", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrThistleLeaf", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrHopsFlower", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 9);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 90, 90);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Endurance", "NW_IT_MPOTION013", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssPower", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust013", 3);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Invisibility", "NW_IT_MPOTION008", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssVanishing", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust010", 3);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Speed", "NW_IT_MPOTION004", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssSpeed", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust008", 3);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 10);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 100, 100);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Sight", "cnrEssSight", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust009", 4);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrWalnutOil", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyEssenses, "Essense of Healing", "cnrEssHealing", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust005", 4);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMushroomPurp", 2);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 11);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 110, 110);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Clarity", "NW_IT_MPOTION007", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssSight", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust006", 4);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  if (CNR_BOOL_ENABLE_HCR_ITEM_CRAFTING)
  {
    sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cure Serious Wounds", "PotionOfCSW", 1);
  }
  else
  {
    sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cure Serious Wounds", "NW_IT_MPOTION002", 1);
  }
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssCure", 4);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGingerRoot", 2);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Antidote", "NW_IT_MPOTION006", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssHealing", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrMushroomBlk", 3);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 12);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 120, 120);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  if (CNR_BOOL_ENABLE_HCR_ITEM_CRAFTING)
  {
    sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cure Critical Wounds", "PotionOfCCW", 1);
  }
  else
  {
    sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Cure Critical Wounds", "NW_IT_MPOTION003", 1);
  }
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssCure", 5);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGemDust012", 4);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 14);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 140, 140);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyPotions, "Potion of Heal", "NW_IT_MPOTION012", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEssHealing", 2);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrGinsengRoot", 4);
  CnrRecipeSetRecipeBiproduct(sKeyToRecipe, "cnrGlassVial", 1, 1);
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 14);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 140, 140);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

//SoU Grenade items

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyMisc, "Acid Flask", "cnrAcidFlask", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrBellBomb", 1);  // Bombadier Beetle Belly
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyMisc, "Choking Powder", "cnrChokPowder", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrLeatherPouch", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrStinkGland", 1);//Stink Beetle Gland
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

  sKeyToRecipe = CnrRecipeCreateRecipe(sMenuAlchemyMisc, "Alchemist's Fire", "cnrAlchemFire", 1);
  CnrRecipeAddComponent(sKeyToRecipe, "cnrEmptyFlask", 1, 1);
  CnrRecipeAddComponent(sKeyToRecipe, "NW_IT_MSMLMISC08", 1); // Fire Beetle Belly
  CnrRecipeSetRecipeLevel(sKeyToRecipe, 2);
  CnrRecipeSetRecipeXP(sKeyToRecipe, 20, 20);
  CnrRecipeSetRecipeAbilityPercentages(sKeyToRecipe, 0, 0, 0, 40, 60, 0);

}





