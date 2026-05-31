// Dismount the caller

// Author : Proleric

// Modified : 17-May-2008

#include "x3_inc_horse"

void bhSetFollowDistance(object oRider, object oHorse);

void main()
{
  object oRider = OBJECT_SELF;
  object oHorse = HorseDismount();

  DelayCommand(HORSE_DISMOUNT_DURATION + 1.0, bhSetFollowDistance(oRider, oHorse));

}

// Set follow distance

void bhSetFollowDistance(object oRider, object oHorse)
{
  ExecuteScript("nw_ch_dist_6", oHorse);

  if (!GetIsPC(oRider))
    ExecuteScript("nw_ch_dist_6", oRider);
}
