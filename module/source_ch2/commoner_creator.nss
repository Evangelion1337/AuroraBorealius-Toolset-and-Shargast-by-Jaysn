//::///////////////////////////////////////////////
//:: commoner_creator.nss
//:://////////////////////////////////////////////
/*
     Reads the various needed variables, creates
     a NPC and sends it to a random waypoint.
*/
//:://////////////////////////////////////////////
//:: Created By: EntropyDecay
//:: Created On: May 2003
//:://////////////////////////////////////////////

void main()
{
  object oArea = GetArea(OBJECT_SELF);
  object oFirstPlayerInArea = GetLocalObject(oArea, "oFirstPlayerInArea");

  int nWeather = GetLocalInt(oArea, "nWeather");
  string sCommonerName = GetLocalString(oArea, "sCommonerName");
  string sResRefBody = GetLocalString(oArea, "sResRefBody");
  int nTypesOfCommoner = GetLocalInt(oArea, "nTypesOfCommoner");
  string sResRefClothing = GetLocalString(oArea, "sResRefClothing");
  int nTypesOfClothing = GetLocalInt(oArea, "nTypesOfClothing");
  int nClothingRandom = GetLocalInt(oArea, "nClothingRandom");
  int nCommonerCarry = GetLocalInt(oArea, "nCommonerCarry");
  int nCommonerTorchOnlyByNight = GetLocalInt(oArea, "nCommonerTorchOnlyByNight");
  int nCommonerTorch = GetLocalInt(oArea, "nCommonerTorch");
  int nWalkWayPoints = GetLocalInt(oArea, "nWalkWayPoints");
  int nDialogLines = GetLocalInt(oArea, "nDialogLines");
  int nWalkType = GetLocalInt(oArea, "nWalkType");
  int nRandom;
  string sZero;

  sZero="00";
  nRandom = Random(nTypesOfCommoner)+1;
  if (nRandom>9) {sZero="0";}
  if (nRandom>99) {sZero="";}
  string sSpawn = sResRefBody + sZero + IntToString(nRandom);

  object oStartWayPoint = GetNearestObjectByTag("NW_COMMONER_WALKTO", oFirstPlayerInArea, Random(nWalkWayPoints)+1);
  object oCommoner = CreateObject(OBJECT_TYPE_CREATURE, sSpawn, GetLocation(oStartWayPoint));
  object oWalkTarget = GetNearestObjectByTag("NW_COMMONER_WALKTO", oStartWayPoint, Random(nWalkWayPoints-1)+1);
  SetLocalObject(oCommoner, "oWalkTarget", oWalkTarget);

  SetLocalInt(oCommoner, "ambience_dialog", Random(nDialogLines)+1);
  AssignCommand(oCommoner, ClearAllActions());
  if (GetName(oCommoner)==sCommonerName)
  {
    if (Random(100)+1 <= nClothingRandom)
    {
      sZero="00";
      nRandom = Random(nTypesOfClothing)+1;
      if (nRandom>9) {sZero="0";}
      if (nRandom>99) {sZero="";}
      object oClothing = CreateItemOnObject(sResRefClothing+sZero+IntToString(nRandom), oCommoner);
      AssignCommand(oCommoner, ActionEquipItem(oClothing, INVENTORY_SLOT_CHEST));
    }
    if (Random(100)+1 > nCommonerCarry)
    {
      DestroyObject(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCommoner));
      DestroyObject(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCommoner));
    }
  }

  if (nCommonerTorchOnlyByNight==FALSE && Random(100)+1 <= nCommonerTorch)
  {
    object oTorch = CreateItemOnObject("NW_IT_TORCH001", oCommoner);
    AssignCommand(oCommoner, ActionEquipItem(oTorch, INVENTORY_SLOT_LEFTHAND));
  }
  else if (GetIsNight() && Random(100)+1 <= nCommonerTorch)
  {
    object oTorch = CreateItemOnObject("NW_IT_TORCH001", oCommoner);
    AssignCommand(oCommoner, ActionEquipItem(oTorch, INVENTORY_SLOT_LEFTHAND));
  }

  AssignCommand(oCommoner, ActionForceMoveToObject(oWalkTarget, nWalkType, 0.4, 60.0));
  AssignCommand(oCommoner, ActionDoCommand(DestroyObject(OBJECT_SELF, 0.1)));
}
