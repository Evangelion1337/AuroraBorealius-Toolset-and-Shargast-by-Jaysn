// Make all horses in the area available for riding.

// Author : Proleric

// Modified : 20-Feb-2008

#include "x3_inc_horse"

void main()
{
  object oArea = GetArea(GetPCSpeaker());

  object oHorse = GetFirstObjectInArea(oArea);

  while (GetIsObjectValid(oHorse))
    {
      if (GetObjectType(oHorse) == OBJECT_TYPE_CREATURE)
        if (HorseGetIsAMount(oHorse))
          DeleteLocalInt(oHorse, "X3_HORSE_NOT_RIDEABLE_OWNER");

      oHorse = GetNextObjectInArea(oArea);
    }
}
