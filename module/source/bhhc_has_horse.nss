// Check if caller has a dismounted horse

// Author : Proleric

// Modified : 22-Apr-2008

#include "x3_inc_horse"

int StartingConditional()
{
  object oPC    = OBJECT_SELF;
  int    bFound = FALSE;

//  if (HorseGetIsMounted(oPC)) return FALSE;

  return (GetIsObjectValid(HorseGetHorse(oPC)));
}
