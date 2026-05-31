// Check horse is available to the caller

// Author : Proleric

// Modified : 17-May-2008

int StartingConditional()
{
  object oRider   = OBJECT_SELF;
  object oPC      = GetMaster(oRider);
  int    bFound   = FALSE;

  if (!GetIsObjectValid(oPC))    oPC = oRider;

  SetLocalInt(oPC, "bhConditional", 1);
  ExecuteScript("bhh_assign", oRider);

  if (GetLocalInt(oPC, "bhMountFound")) bFound = TRUE;

  DeleteLocalInt(oPC, "bhConditional");
  DeleteLocalInt(oPC, "bhMountFound");
  DeleteLocalInt(oPC, "bhSpareFound");

  return bFound;
}
