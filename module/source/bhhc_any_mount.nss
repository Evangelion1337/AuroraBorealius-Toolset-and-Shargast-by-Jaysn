// Check if any member of the party can mount

// Author : Proleric

// Modified : 17-May-2008

// If no one has a horse, check whether one can be assigned.

#include "x3_inc_horse"

int bhHasHorse(object oRider);

int StartingConditional()
{
  object oPC      = GetPCSpeaker();
  int i           = GetMaxHenchmen();
  object oHench   = GetHenchman(oPC, i);
  object oHorse;
  object oArea    = GetArea(oPC);
  int    bFound   = FALSE;

  if (!GetLocalInt(oArea,"X3_MOUNT_OK_EXCEPTION"))
    {
      if (GetLocalInt(GetModule(), "X3_MOUNTS_EXTERNAL_ONLY")  && GetIsAreaInterior(oArea))    return FALSE;
      if (GetLocalInt(GetModule(), "X3_MOUNTS_NO_UNDERGROUND") &&!GetIsAreaAboveGround(oArea)) return FALSE;
    }

  if (GetLocalInt(oArea,"X3_NO_MOUNTING") || GetLocalInt(oArea,"X3_NO_HORSES")) return FALSE;

  if (bhHasHorse(oPC)) return TRUE;

  while (i)
    {
      if (GetIsObjectValid(oHench))
        if (!HorseGetIsAMount(oHench))
          if (bhHasHorse(oHench)) return TRUE;

       oHench = GetHenchman(oPC, --i);
    }

  SetLocalInt(oPC, "bhConditional", 1);
  ExecuteScript("bhh_assign_all", oPC);

  if (GetLocalInt(oPC, "bhMountFound")) bFound = TRUE;

  DeleteLocalInt(oPC, "bhConditional");
  DeleteLocalInt(oPC, "bhMountFound");
  DeleteLocalInt(oPC, "bhSpareFound");

  return bFound;
}

// Check if caller has a horse and is dismounted

int bhHasHorse(object oRider)
{
  if (HorseGetIsMounted(oRider)) return FALSE;

  return(GetIsObjectValid(HorseGetHorse(oRider)));
}

