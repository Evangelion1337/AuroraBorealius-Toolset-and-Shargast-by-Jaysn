// Release horses owned by the caller.

// Author : Proleric

// Modified : 22-Apr-2008

// Any horses which are currently mounted will not be released.

#include "x3_inc_horse"

void bh_release(object oHorse);

void main()
{
  object oPC      = OBJECT_SELF;
  int i           = GetMaxHenchmen();
  object oHench   = GetHenchman(oPC, i);
  object oHorse;

  while (i)
    {
      if (GetIsObjectValid(oHench))
        {
          if (HorseGetIsAMount(oHench))
            DelayCommand(0.5, bh_release(oHench));
        }
       oHench = GetHenchman(oPC, --i);
    }
}

// This is a wrapper for HorseRemoveOwner that clears the action queue, in case the horse is still following.

void bh_release(object oHorse)
{
  HorseRemoveOwner(oHorse);
  AssignCommand(oHorse, ClearAllActions());
}
