/////////////////////////////////////////////////////////
//
//  Craftable Natural Resources (CNR) by Festyx
//
//  Name:  cnr_source_init
//
//  Desc:  Minable placeables initialization. This script is
//         executed from "cnr_module_oml".
//
//  Author: David Bobeck 08May03
//
/////////////////////////////////////////////////////////
#include "cnr_source_inc"
#include "cnr_config_inc"
void main()
{
  PrintString("cnr_source_init");

  // Module builders: You should put your mining initialization
  // into a file named "user_source_init" so that future
  // versions of CNR do not over-write any resources you define.
  ExecuteScript("user_source_init", OBJECT_SELF);

  // This section (new to V3.00) allows for easy setup of trees that
  // drop branches when bashed with a woodcutter's axe.
  CnrBashableTreeInitialize("cnrTreeOak", "cnrBranchOak");
  CnrBashableTreeInitialize("cnrTreeMahogany", "cnrBranchMah");
  CnrBashableTreeInitialize("cnrTreeHickory", "cnrBranchHic");

  // This section (new to V3.00) allows for easy setup of misc deposits that
  // can be dug with a shovel to provide an item.
  CnrShoveledDepositInitialize("cnrDepositClay", "cnrLumpOfClay");
  CnrShoveledDepositInitialize("cnrDepositSand", "cnrBagOfSand");

  // This section (new to V3.00) allows for easy setup of mineral deposits that
  // can be excavated with a chisel to provide an item.
  CnrChiseledDepositInitialize("cnrGemDeposit001", "cnrGemMineral001");
  CnrChiseledDepositInitialize("cnrGemDeposit002", "cnrGemMineral002");
  CnrChiseledDepositInitialize("cnrGemDeposit003", "cnrGemMineral003");
  CnrChiseledDepositInitialize("cnrGemDeposit004", "cnrGemMineral004");
  CnrChiseledDepositInitialize("cnrGemDeposit005", "cnrGemMineral005");
  CnrChiseledDepositInitialize("cnrGemDeposit006", "cnrGemMineral006");
  CnrChiseledDepositInitialize("cnrGemDeposit007", "cnrGemMineral007");
  CnrChiseledDepositInitialize("cnrGemDeposit008", "cnrGemMineral008");
  CnrChiseledDepositInitialize("cnrGemDeposit009", "cnrGemMineral009");
  CnrChiseledDepositInitialize("cnrGemDeposit010", "cnrGemMineral010");
  CnrChiseledDepositInitialize("cnrGemDeposit011", "cnrGemMineral011");
  CnrChiseledDepositInitialize("cnrGemDeposit012", "cnrGemMineral012");
  CnrChiseledDepositInitialize("cnrGemDeposit013", "cnrGemMineral013");
  CnrChiseledDepositInitialize("cnrGemDeposit014", "cnrGemMineral014");
  CnrChiseledDepositInitialize("cnrGemDeposit015", "cnrGemMineral015");

  // This section (new to V3.00) allows for easy setup of ore deposits that
  // can be bashed with a pickaxe to provide an item.
  CnrMinableRockInitialize("cnrRockAdam", "cnrNuggetAdam");
  CnrMinableRockInitialize("cnrRockCoba", "cnrNuggetCoba");
  CnrMinableRockInitialize("cnrRockCopp", "cnrNuggetCopp");
  CnrMinableRockInitialize("cnrRockGold", "cnrNuggetGold");
  CnrMinableRockInitialize("cnrRockIron", "cnrNuggetIron");
  CnrMinableRockInitialize("cnrRockMith", "cnrNuggetMith");
  CnrMinableRockInitialize("cnrRockPlat", "cnrNuggetPlat");
  CnrMinableRockInitialize("cnrRockSilv", "cnrNuggetSilv");
  CnrMinableRockInitialize("cnrRockTin", "cnrNuggetTin");
  CnrMinableRockInitialize("cnrRockTita", "cnrNuggetTita");
  CnrMinableRockInitialize("cnrDepositCoal", "cnrLumpOfCoal");

  // This section (new to V3.00) allows for easy setup of feather drops 
  // upon the death of the identified bird.
  CnrBirdOnDeathInitialize("cnraFalcon", "cnrFeatherFalcon");
  CnrBirdOnDeathInitialize("cnraRaven", "cnrFeatherRaven");
  CnrBirdOnDeathInitialize("cnraOwl", "cnrFeatherOwl");

  // This section (new to V3.05, similar to CnrBirdOnDeathInitialize) allows
  // for easy setup of item drops upon the death of the identified mob.
  CnrMobOnDeathInitialize("cnrBeetleStink", "cnrStinkGland");
  CnrMobOnDeathInitialize("cnrBeetleBomber", "cnrBellBomb");
}

