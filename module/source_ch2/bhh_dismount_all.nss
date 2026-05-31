// Party dismount from horses

// Author : Proleric

// Modified : 06-May-2008

#include "x3_inc_horse"

void bhSetFollowDistance(object oPC);

void main()
{

  object oPC = GetPCSpeaker();

  AssignCommand(oPC, ActionCastSpellAtObject(SPELL_HORSE_PARTY_DISMOUNT, oPC, METAMAGIC_ANY, TRUE,
                                                      0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));

  DelayCommand(HORSE_DISMOUNT_DURATION + 2.0, bhSetFollowDistance(oPC));
}

// Set appropriate default follow distances

// The different cases are broken out so they can be changed individually

void bhSetFollowDistance(object oPC)
{
  int    nHench = 1;
  object oHench = GetHenchman(oPC, nHench);
  object oHorse;

  while (GetIsObjectValid(oHench))
    {
      if (HorseGetIsAMount(oHench))
        ExecuteScript("nw_ch_dist_6", oHench);       // PC's horse
      else
        {
           ExecuteScript("nw_ch_dist_6", oHench);    // Dismounted henchman
           oHorse = HorseGetMyHorse(oHench);

           if (GetIsObjectValid(oHorse))
             ExecuteScript("nw_ch_dist_6", oHorse);  // Henchman's horse
        }

      oHench = GetHenchman(oPC, ++nHench);
    }
}
