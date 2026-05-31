// On first entry to an area, flag all horses as unavailable

// Author : Proleric

// Modified : 20-Feb-2008

#include "x3_inc_horse"

void main()
{

object oArea = OBJECT_SELF;
object oHorse;

if (!GetIsPC(GetEnteringObject())) return;

if (GetLocalInt(oArea, "bhh_lock_all")) return;

SetLocalInt(oArea, "bhh_lock_all", TRUE);

oHorse = GetFirstObjectInArea(oArea);

while (GetIsObjectValid(oHorse))
  {
    if (GetObjectType(oHorse) == OBJECT_TYPE_CREATURE)
      if (HorseGetIsAMount(oHorse))
        {
//          The following line is an example of an alternative method of making horses unavailable.
//          HorseSetOwner(oHorse, GetObjectByTag("HorseDealer"));
          SetLocalInt(oHorse, "X3_HORSE_NOT_RIDEABLE_OWNER", TRUE);
        }
    oHorse = GetNextObjectInArea(oArea);
  }

}
