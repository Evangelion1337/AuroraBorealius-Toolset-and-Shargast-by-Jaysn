// Party mount horses

// Author : Proleric

// Modified : 22-May-2008

// Before mounting, an attempt is made to assign horses.
// If the PC cannot mount, attempt to assign the mount command to a henchman.

#include "x3_inc_horse"

void bhSetFollowDistance(object oPC);

void main()
{
  object oPC    = GetPCSpeaker();
  object oHorse;
  float  ASSIGN_DELAY      = 0.0;
  float  RUN_TO_HORSE      = 6.0;
  float  POST_MOUNT_SAFETY = 1.0;

  if (!GetIsObjectValid(oPC)) oPC = OBJECT_SELF;

  ExecuteScript("bhh_assign_all", oPC);

  oHorse = HorseGetMyHorse(oPC);

  if (!GetIsObjectValid(oHorse)) oHorse = GetHenchman(oPC);

  if (HorseGetIsMounted(oPC))    oHorse = GetHenchman(oPC);

  if (GetIsObjectValid(oHorse))
    {
      DelayCommand(ASSIGN_DELAY, AssignCommand(oPC, ActionCastSpellAtObject(SPELL_HORSE_PARTY_MOUNT, oHorse,
                                                        METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE)));
      DelayCommand(ASSIGN_DELAY + RUN_TO_HORSE + HORSE_MOUNT_DURATION + POST_MOUNT_SAFETY, bhSetFollowDistance(oPC));
    }
}

// Set appropriate default follow distances

void bhSetFollowDistance(object oPC)
{
  int    nHench     = 1;
  object oHench     = GetHenchman(oPC, nHench);
  object oHorse;

  while (GetIsObjectValid(oHench))
    {
      ExecuteScript("nw_ch_dist_6", oHench);

      if (HorseGetIsMounted(oPC))
        {
          if (HorseGetIsAMount(oHench))
            ExecuteScript("nw_ch_dist_12", oHench);
          else
            if (HorseGetIsMounted(oHench))
              ExecuteScript("nw_ch_dist_12", oHench);
         }
      oHench = GetHenchman(oPC, ++nHench);
    }
}
