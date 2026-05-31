// Assign horses to PC and henchmen

// Author : Proleric

// Modified : 17-May-2008

// Horses are assigned to each member of the party.
// Any spare horses are then assigned to the PC.

// A table of party members is made at the outset, because party membership
// will change if spare horses are assigned to henchmen.

// A table of horses is created in bhh_assign, for performance reasons.

// This routine is also used by conditional scripts to determine whether a new assignment is
// possible. In this case, a local variable bhConditional will be set on the rider, and
// no assignment occurs; instead, bhMountFound is set if assignment could occur, and
// bhSpareFound is set if the PC could collect a spare horse.

#include "x3_inc_horse"

void main()
{
  object oPC          = GetPCSpeaker();
  object oHorse;
  int    nHorse;
  int    bAssignHorse = FALSE;
  int    nHench       = 1;
  int    nHenchSub    = 0;
  object oHench;
  object oOwner;

  if (!GetIsObjectValid(oPC)) oPC = OBJECT_SELF;

  SetLocalInt(oPC, "bhAssignAll", TRUE);

  // Create party table

  oHench = GetHenchman(oPC, nHench);

  while (GetIsObjectValid(oHench))
    {
      if (!HorseGetIsAMount(oHench))
        SetLocalObject(oPC, "bhHench" + IntToString(++nHenchSub), oHench);
      oHench = GetHenchman(oPC, ++nHench);
    }

  // Assign horses to each party member

  ExecuteScript("bhh_assign", oPC);

  nHench = 1;

  oHench = GetLocalObject(oPC, "bhHench" + IntToString(nHench));

  while (GetIsObjectValid(oHench))
    {
      ExecuteScript("bhh_assign", oHench);

      oHench = GetLocalObject(oPC, "bhHench" + IntToString(++nHench));
    }

  // PC collects spare horses

  // We don't care whether the PC can ride them. We don't want to assign them, either.

  // "Spare" means horse has no owner, or is a dismissed horse owned by the PC.

  nHorse = 0;

  oHorse = GetLocalObject(oPC, "bhHorse" + IntToString(++nHorse));

  while (GetIsObjectValid(oHorse))
    {
          oOwner = HorseGetOwner(oHorse);

          if (!GetIsObjectValid(oOwner) || (oOwner == oPC))
            if (GetMaster(oHorse) != oPC)
              if (GetLocalInt(oPC, "bhConditional"))
                {
                  SetLocalInt(oPC, "bhSpareFound", 1);
                }
              else
                {
                  HorseSetOwner(oHorse, oPC, bAssignHorse);
                  ExecuteScript("nw_ch_dist_12", oHorse);
                }

      oHorse = GetLocalObject(oPC, "bhHorse" + IntToString(++nHorse));
    }

  // Delete temporary local variables

  DeleteLocalInt(oPC, "bhAssignAll");

  nHench = 1;

  oHench = GetLocalObject(oPC, "bhHench" + IntToString(nHench));

  while (GetIsObjectValid(oHench))
    {

      DeleteLocalObject(oPC, "bhHench" + IntToString(nHench));
      oHench = GetLocalObject(oPC, "bhHench" + IntToString(++nHench));
    }

  nHorse = 0;

  oHorse = GetLocalObject(oPC, "bhHorse" + IntToString(++nHorse));

  while (GetIsObjectValid(oHorse))
    {
      DeleteLocalObject(oPC, "bhHorse" + IntToString(nHorse));
      oHorse = GetLocalObject(oPC, "bhHorse" + IntToString(++nHorse));
    }
}
