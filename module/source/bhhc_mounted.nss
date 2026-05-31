// Check if caller is mounted

// Author : Proleric

// Modified : 25-Feb-2008

#include "x3_inc_horse"

int StartingConditional()
{
  object oPC    = OBJECT_SELF;

  return (HorseGetIsMounted(oPC));
}
