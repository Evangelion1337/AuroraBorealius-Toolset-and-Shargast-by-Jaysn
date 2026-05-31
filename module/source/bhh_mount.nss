// Mount assigned horse

// Author : Proleric

// Modified : 22-May-2008

// Before mounting, an attempt is made to assign a horse.

#include "x3_inc_horse"

void bhSetFollowDistance(object oRider, object oHorse);

void main()
{
  object oRider    = OBJECT_SELF;
  object oPC;
  object oHorse;
  float  ASSIGN_DELAY      = 0.0;
  float  RUN_TO_HORSE      = 6.0;
  float  POST_MOUNT_SAFETY = 1.0;

  if (HorseGetIsMounted(oRider)) return;

  ExecuteScript("bhh_assign", oRider);

  oHorse = HorseGetMyHorse(oRider);

  if (GetIsObjectValid(oHorse))
    {
      DelayCommand(ASSIGN_DELAY, AssignCommand(oRider, HorseMount(oHorse)));
      DelayCommand(ASSIGN_DELAY + RUN_TO_HORSE + HORSE_MOUNT_DURATION + POST_MOUNT_SAFETY, bhSetFollowDistance(oRider, oHorse));
    }
}

// Set follow distance

void bhSetFollowDistance(object oRider, object oHorse)
{
      if (!GetIsPC(oRider))
        {
          if (HorseGetIsMounted(GetMaster(oRider)))
            ExecuteScript("nw_ch_dist_12", oRider);
          else
            ExecuteScript("nw_ch_dist_6",  oRider);
        }
}
