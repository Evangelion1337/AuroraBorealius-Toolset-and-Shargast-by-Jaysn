#include "sd_lootsystem"

void BodyFade(object oHostBody, object oBlood)
{
  object oBones;
  location lLoc = GetLocation(oHostBody);
  SetPlotFlag(oHostBody, FALSE);
  AssignCommand(oHostBody, SetIsDestroyable(TRUE,FALSE,FALSE));
  if ((GetRacialType(oHostBody) != RACIAL_TYPE_CONSTRUCT) &&
      (GetRacialType(oHostBody) != RACIAL_TYPE_ELEMENTAL)&&
      (GetRacialType(oHostBody) != RACIAL_TYPE_DRAGON)&&
      (GetRacialType(oHostBody) != RACIAL_TYPE_ANIMAL))

     {
      oBones = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_bones", lLoc, FALSE);
      ExecuteScript("sd_destroyself", oBones);
     }
  DestroyObject(oBlood);
  if (GetIsDead(oHostBody))DestroyObject(oHostBody, 0.2f);
 }

void main()
{
 float lsDelay  = 240.0;                   // Corpse & loot fade delay
 object oHostBody = OBJECT_SELF; //Get the Dead Creature Object
 object oBlood;
 object oSaveBlood;
 string sBaseTag = GetTag(oHostBody); //Get that TAG of the dead creature
 string sPrefix = GetStringLeft(sBaseTag, 4); //Look for Dead Prefix
 location lLoc = GetLocation(oHostBody);

 if ((GetRacialType(oHostBody) != RACIAL_TYPE_UNDEAD) &&
     (GetRacialType(oHostBody) != RACIAL_TYPE_CONSTRUCT) &&
     (GetRacialType(oHostBody) != RACIAL_TYPE_ELEMENTAL)&&
     (GetRacialType(oHostBody) != RACIAL_TYPE_DRAGON))
    {
     oBlood = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_bloodstain", lLoc, FALSE);
    }
 DelayCommand(lsDelay, BodyFade(oHostBody, oBlood));


 //Sink the lootbag into the ground a little
 float fSinkCorpseObj = 0.1f; //depth
 vector vHostBodyLoc = GetPosition(oHostBody);
 float fCorpseFacing = GetFacing(oHostBody);
 vector vCorpseLoc = Vector(vHostBodyLoc.x, vHostBodyLoc.y, vHostBodyLoc.z - fSinkCorpseObj);
 location lCorpseLoc = Location(GetArea(oHostBody), vCorpseLoc, fCorpseFacing);

 //Create the lootbag
 object oLootCorpse = CreateObject(OBJECT_TYPE_PLACEABLE, "rr_sack", lCorpseLoc, FALSE); //Spawn our lootable object

 SetLocalObject(oLootCorpse, "oHostBody", oHostBody); //Set Local for deletion later if needed
 SetLocalObject(oLootCorpse, "oBlood", oBlood);
 NameSack(oLootCorpse);
 DelayCommand(0.1,sd_droploot(oHostBody, oLootCorpse));
 DelayCommand(lsDelay, LootClear(oLootCorpse));
}
