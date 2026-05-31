/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_plant_init
//
//  Desc:  Plant initialization. This script is
//         executed from "cnr_module_oml".
//
//  Author: David Bobeck 12Dec02
//
/////////////////////////////////////////////////////////
#include "cnr_plant_utils"
#include "cnr_config_inc"
void main()
{
  PrintString("cnr_plant_init");

  // Module builders: You should put your plant initialization
  // into a file named "user_plant_init" so that future
  // versions of CNR do not over-write any resources you define.
  ExecuteScript("user_plant_init", OBJECT_SELF);

  /////////////////////////////////////////////////////////
  // Default CNR plant initialization
  /////////////////////////////////////////////////////////
  CnrPlantInitialize("cnrBarleyPlant", "cnrBarleyRaw", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrCornPlant", "cnrCornRaw", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrOatsPlant", "cnrOatsRaw", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrRicePlant", "cnrRiceRaw", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrRyePlant", "cnrRyeRaw", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrWheatPlant", "cnrWheatRaw", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrApplePlant", "cnrAppleFruit", 5, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrPearPlant", "cnrPearFruit", 5, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrCherryPlant", "cnrCherryFruit", 5, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrGrapePlant", "cnrGrapeFruit", 5, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrEldberryPlant", "cnrEldberryFruit", 5, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrCrnberryPlant", "cnrCrnberryFruit", 5, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrBlkberryPlant", "cnrBlkberryFruit", 5, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrBluberryPlant", "cnrBluberryFruit", 5, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrRspberryPlant", "cnrRspberryFruit", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrJuniperPlant", "cnrJuniperFruit", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrHopsPlant", "cnrHopsFlower", 4, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrHazelnutPlant", "cnrHazelnutFruit", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrWalnutPlant", "cnrWalnutFruit", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrPecanPlant", "cnrPecanFruit", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrChestnutPlant", "cnrChestnutFruit", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrAlmondPlant", "cnrAlmondFruit", 3, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);

  CnrPlantInitialize("cnrAloePlant", "cnrAloeLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrAngelicaPlant", "cnrAngelicaLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrBkCohoshPlant", "cnrBlkCohoshRoot", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrCalendulaPlant", "cnrCalendulaFlower", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrCatnipPlant", "cnrCatnipLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrChamomilePlant", "cnrChamomileFlower", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrComfreyPlant", "cnrComfreyRoot", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrEchinaceaPlant", "cnrEchinaceaRoot", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrGarlicPlant", "cnrGarlicClove", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrGingerPlant", "cnrGingerRoot", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrGinsengPlant", "cnrGinsengRoot", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrHawthornPlant", "cnrHawthornFlower", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrThistlePlant", "cnrThistleLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrNettlePlant", "cnrNettleLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrPepmintPlant", "cnrPepmintLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrCloverPlant", "cnrCloverLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrSagePlant", "cnrSageLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrSkullcapPlant", "cnrSkullcapLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrHazelPlant", "cnrHazelLeaf", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrCottonPlant", "cnrCotton", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrBirchPlant", "cnrBirchBark", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrSpiderCocoon", "cnrSpiderSilk", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrBeehive", "cnrHoney", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);
  CnrPlantInitialize("cnrBeeNest", "cnrHoney", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS, CNR_INT_ALWAYS_RESPAWN_FRUIT);

  CnrPlantInitialize("cnrPatchMushBlk", "cnrMushroomBlk", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrPatchMushWht", "cnrMushroomWht", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrPatchMushRed", "cnrMushroomRed", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrPatchMushPurp", "cnrMushroomPurp", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrPatchMushSpot", "cnrMushroomSpot", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);
  CnrPlantInitialize("cnrPatchMushYel", "cnrMushroomYel", 2, CNR_FLOAT_DEFAULT_PLANT_RESPAWN_TIME_SECS);

  // endless supplies
  CnrPlantInitialize("cnrPileOfSalt", "cnrSalt", 1, 0.0);
  CnrPlantInitialize("cnrSacksOfSalt", "cnrSalt", 1, 0.0);
  CnrPlantInitialize("cnrSacksOfSugar", "cnrSugar", 1, 0.0);
  CnrPlantInitialize("cnrPileOfDirt", "cnrGraveyardDirt", 1, 0.0);
  CnrPlantInitialize("cnrMaplePlant", "cnrMapleSyrup", 1, 0.0);

}


