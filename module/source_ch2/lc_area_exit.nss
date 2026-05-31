/*******************************************************************************
* lc_area_exit
*
* by LasCivious Sept 2004
* Called by area's OnExit event.  Clears area encounters, dropped items,
* stores & cleans placeable inventories if no PC is present for a length of time.
*******************************************************************************/

// Set this to FALSE if you do not want placeable inventories cleared
int nClearPlaceInv = TRUE;
// Set the amount of time to wait for cleaning here in seconds
float fDelayTime = 60.0;

void CleanArea(object oArea)
{
  object oTrash = GetFirstObjectInArea(oArea);
  object oInvItem;

  //Check for PCs
  object oPC = GetFirstPC();
  while (GetIsObjectValid(oPC)) {
    if  (GetArea(oPC) == oArea) {
      DeleteLocalInt(oArea, "CleanArea");
      return;
    }
    oPC = GetNextPC();
  }

   while(GetIsObjectValid(oTrash)) {
     string sTagPrefix = GetStringLeft(GetTag(oTrash), 15);
     // Clear remains, dropped items
     if(GetObjectType(oTrash)==OBJECT_TYPE_ITEM ||
        GetStringLowerCase(GetName(oTrash)) == "remains") {
          AssignCommand(oTrash, SetIsDestroyable(TRUE));
          if (GetHasInventory(oTrash)) {
            oInvItem = GetFirstItemInInventory(oTrash);
            while(GetIsObjectValid(oInvItem)) {
              DestroyObject(oInvItem,0.0);
              oInvItem = GetNextItemInInventory(oTrash);
            }
          }
          else DestroyObject(oTrash, 0.0);
      }
      // Clear placeable inventories
      if(GetObjectType(oTrash)==OBJECT_TYPE_PLACEABLE &&
         nClearPlaceInv == TRUE) {
        if (GetHasInventory(oTrash))
        {
          object oInvItem = GetFirstItemInInventory(oTrash);
          while(GetIsObjectValid(oInvItem)) {
            DestroyObject(oInvItem,0.0);
            oInvItem = GetNextItemInInventory(oTrash);
          }
        }
      }
      // Clear encounters
      else if (GetIsEncounterCreature(oTrash) ||
               sTagPrefix == "PWFSE_SPAWNERID")
      {
        AssignCommand(oTrash, SetIsDestroyable(TRUE));
        DestroyObject(oTrash, 0.0);
      }

      oTrash = GetNextObjectInArea(oArea);
   }
   DeleteLocalInt(oArea, "CleanArea");
}

void main()
{
  object oArea = OBJECT_SELF;
  object oPC = GetExitingObject();
  if (!GetIsPC(oPC)) return;

  if (GetLocalInt(oArea, "CleanArea") != 1)
  {
    DelayCommand(fDelayTime, CleanArea(oArea));
    SetLocalInt(oArea, "CleanArea", 1);
  }
}

