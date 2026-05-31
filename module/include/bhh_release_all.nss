// Release horses owned by PC and henchmen.

// Author : Proleric

// Modified : 22-Apr-2008

// Any horses which are currently mounted will not be released.

#include "x3_inc_horse"

void main()
{
  object oPC      = GetPCSpeaker();
  int i           = GetMaxHenchmen();
  object oHench   = GetHenchman(oPC, i);
  object oHorse;

  ExecuteScript("bhh_release", oPC);

  while (i)
    {
      if (GetIsObjectValid(oHench))
        {
          if (!HorseGetIsAMount(oHench))
            ExecuteScript("bhh_release", oHench);
        }
       oHench = GetHenchman(oPC, --i);
    }
}

