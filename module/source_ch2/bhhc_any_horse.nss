// Check if any member of the party has a dismounted horse

// Author : Proleric

// Modified : 17-May-2008

#include "x3_inc_horse"

int bhHasHorse(object oPC);

int StartingConditional()
{
  object oPC      = GetPCSpeaker();
  int i           = GetMaxHenchmen();
  object oHench   = GetHenchman(oPC, i);
  object oHorse;

  if (bhHasHorse(oPC)) return TRUE;

  while (i)
    {
      if (GetIsObjectValid(oHench))
        {
          if (!HorseGetIsAMount(oHench))
            if (bhHasHorse(oHench)) return TRUE;
        }
       oHench = GetHenchman(oPC, --i);
    }

  return FALSE;
}

// Check if caller has a horse

int bhHasHorse(object oPC)
{
//  if (HorseGetIsMounted(oPC)) return FALSE;

  return(GetIsObjectValid(HorseGetHorse(oPC)));
}

