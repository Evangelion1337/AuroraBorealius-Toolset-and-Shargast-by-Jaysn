// Check if a horse is available to any party member

// Author : Proleric

// Modified : 21-Apr-2008

int StartingConditional()
{
  object oPC      = GetPCSpeaker();
  int    bFound   = FALSE;

  SetLocalInt(oPC, "bhConditional", 1);
  ExecuteScript("bhh_assign_all", oPC);

  if (GetLocalInt(oPC, "bhMountFound")) bFound = TRUE;
  if (GetLocalInt(oPC, "bhSpareFound")) bFound = TRUE;

  DeleteLocalInt(oPC, "bhConditional");
  DeleteLocalInt(oPC, "bhMountFound");
  DeleteLocalInt(oPC, "bhSpareFound");

  return bFound;
}
