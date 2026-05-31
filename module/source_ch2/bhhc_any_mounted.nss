// Check if any member of the party is mounted

// Author : Proleric

// Modified : 25-Feb-2008

#include "x3_inc_horse"

int StartingConditional()
{
  object oPC      = GetPCSpeaker();
  int i           = GetMaxHenchmen();
  object oHench   = GetHenchman(oPC, i);
  object oHorse;

  if (HorseGetIsMounted(oPC)) return TRUE;

  while (i)
    {
      if (GetIsObjectValid(oHench))
        {
          if (!HorseGetIsAMount(oHench))
            if (HorseGetIsMounted(oHench)) return TRUE;
        }
       oHench = GetHenchman(oPC, --i);
    }

  return FALSE;
}

