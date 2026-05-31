// Check if caller can mount

// Author : Proleric

// Modified : 17-May-2008

// If the caller has no horse, check whether one can be assigned.

#include "x3_inc_horse"

int StartingConditional()
{
  object oRider = OBJECT_SELF;
  object oPC    = GetMaster(oRider);
  object oArea  = GetArea(oRider);
  int    bFound = FALSE;

  if (!GetIsObjectValid(oPC))    oPC = oRider;

  if (!GetLocalInt(oArea,"X3_MOUNT_OK_EXCEPTION"))
    {
      if (GetLocalInt(GetModule(), "X3_MOUNTS_EXTERNAL_ONLY")  && GetIsAreaInterior(oArea))    return FALSE;
      if (GetLocalInt(GetModule(), "X3_MOUNTS_NO_UNDERGROUND") &&!GetIsAreaAboveGround(oArea)) return FALSE;
    }

  if (GetLocalInt(oArea,"X3_NO_MOUNTING") || GetLocalInt(oArea,"X3_NO_HORSES")) return FALSE;

  if (HorseGetIsMounted(oRider)) return FALSE;

  if (GetIsObjectValid(HorseGetHorse(oRider))) return TRUE;

  SetLocalInt(oPC, "bhConditional", 1);
  ExecuteScript("bhh_assign", oRider);

  if (GetLocalInt(oPC, "bhMountFound")) bFound = TRUE;

  DeleteLocalInt(oPC, "bhConditional");
  DeleteLocalInt(oPC, "bhMountFound");
  DeleteLocalInt(oPC, "bhSpareFound");

  return bFound;
}
