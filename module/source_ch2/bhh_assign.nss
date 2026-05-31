// Assign horse to one character

// Author : Proleric

// Modified : 22-May-2008

// If a currently assigned horse can be seen, but has ceased to be a henchman, it is reassigned.

// Available horses are reviewed. For a horse to be available, it must be seen and have no owner.
// Spare horses owned by the PC are also considered to be available.

// The best horse available (the one with the most hit points) is assigned.

// If a henchman ends up with two horses, the spare is assigned to the PC.

// This routine is also used by conditional scripts to determine whether a new assignment is
// possible. In this case, a local variable bhConditional will be set on the rider, and
// no assignment occurs; instead, bhMountFound is set if assignment could occur.

// For performance reasons, if this routine is called from bhh_assign_all, the table of
// available horses is created only once.

// Note that the table is recreated for each conditional and action script.
// This is not efficient, but it is robust if the module builder chooses
// to use some but not all of these scripts.

#include "x3_inc_horse"

int bhHorseGetCanBeMounted(object oTarget,object oRider=OBJECT_INVALID,int bAssignMount=FALSE);

void main()
{
  object oRider     = OBJECT_SELF;
  object oPC        = GetMaster(oRider);
  object oArea      = GetArea(oRider);
  object oBestHorse = OBJECT_INVALID;
  object oMyHorse;
  object oHorse;
  object oOwner;
  int    bAssignHorse = TRUE;
  int    bAvailable;
  int    nHP;
  int    nBestHP    = 0;
  int    nHorse     = 0;

  if (HorseGetIsAMount(oRider))  return;  // Horses can't own other horses

  if (HorseGetIsMounted(oRider) && !GetIsPC(oRider)) return; // We want PC to build the horse table even if mounted

  if (!GetIsObjectValid(oPC))    oPC = oRider;

// Recover my horse if it is orphaned

  oHorse = HorseGetMyHorse(oRider);

  if (GetIsObjectValid(oHorse))
    if (GetObjectSeen(oHorse, oRider))
      if (GetMaster(oHorse) != oRider)
        if (!HorseGetIsMounted(oRider))
          if (GetLocalInt(oPC, "bhConditional"))
            SetLocalInt(oPC, "bhMountFound", 1);
          else
            {
              HorseSetOwner(oHorse, oRider, bAssignHorse);
              ExecuteScript("nw_ch_dist_6", oHorse);

              if (HorseGetIsMounted(oRider))
                ExecuteScript("nw_ch_dist_12", oHorse);
              else
                ExecuteScript("nw_ch_dist_6",  oHorse);
            }

// Build table of available horses

  if (!GetLocalInt(oPC, "bhAssignAll") || GetIsPC(oRider))
    {
      oHorse = GetFirstObjectInArea(oArea);

      while (GetIsObjectValid(oHorse))
        {
          if (GetObjectType(oHorse) == OBJECT_TYPE_CREATURE)
            if (GetObjectSeen(oHorse, oRider))
              if (bhHorseGetCanBeMounted(oHorse, oRider, bAssignHorse))
                SetLocalObject(oPC, "bhHorse" + IntToString(++nHorse), oHorse);

          oHorse = GetNextObjectInArea(oArea);
        }
    }

// Determine best horse to assign

  nHorse = 0;

  oHorse = GetLocalObject(oPC, "bhHorse" + IntToString(++nHorse));

  while (GetIsObjectValid(oHorse))
    {
            oOwner     = HorseGetOwner(oHorse);
            bAvailable = FALSE;

            if (!GetIsObjectValid(oOwner))
              bAvailable = TRUE;
              else
              if (oOwner == oRider)
                bAvailable = TRUE;
                else
                if ((oOwner == GetMaster(oRider))
                &&  (HorseGetIsMounted(oOwner) || (oHorse != HorseGetMyHorse(oOwner))))
                  bAvailable = TRUE;

            if (bAvailable)
              {
                nHP = GetCurrentHitPoints(oHorse);

                if (nHP > nBestHP)
                  {
                    oBestHorse = oHorse;
                    nBestHP    = nHP;
                  }
                else
                  if ((nHP == nBestHP)
                  &&  (oHorse == HorseGetMyHorse(oRider))
                  &&  (!HorseGetIsMounted(oRider)))
                    oBestHorse = oHorse;
              }
      oHorse = GetLocalObject(oPC, "bhHorse" + IntToString(++nHorse));
    }

//  Assign best horse

    if (HorseGetIsMounted(oRider)) oBestHorse = OBJECT_INVALID;  // Covers case where PC is mounted but we wanted to build the table

    oMyHorse = HorseGetMyHorse(oRider);

    if (GetIsObjectValid(oBestHorse)
    &&  (oBestHorse != oMyHorse))
      if (GetLocalInt(oPC, "bhConditional"))
        SetLocalInt(oPC, "bhMountFound", 1);
      else
        {
          if (!GetIsPC(oRider))
            if (GetIsObjectValid(oMyHorse))
              HorseSetOwner(oMyHorse, oPC);

          HorseSetOwner(oBestHorse, oRider, bAssignHorse);

          if (HorseGetIsMounted(oRider))
            ExecuteScript("nw_ch_dist_12", oBestHorse);
          else
            ExecuteScript("nw_ch_dist_6",  oBestHorse);
        }

// Clear table unless we might need it again

  if (GetLocalInt(oPC, "bhAssignAll")) return;

  nHorse = 0;

  oHorse = GetLocalObject(oPC, "bhHorse" + IntToString(++nHorse));

  while (GetIsObjectValid(oHorse))
    {
      DeleteLocalObject(oPC, "bhHorse" + IntToString(nHorse));
      oHorse = GetLocalObject(oPC, "bhHorse" + IntToString(++nHorse));
    }
}

// Check if rider can mount horse

// This is the Bioware routine with two fixes for the situation in which bAssignMount is TRUE :
// 1. If the rider is a mounted PC, assignment is legal.
// 2. If the rider is the PC master of the current owner, assignment is legal.

int bhHorseGetCanBeMounted(object oTarget,object oRider=OBJECT_INVALID,int bAssignMount=FALSE)
{ // PURPOSE: This will return whether oTarget can be mounted
    int nAppearance;
    string sS;
    object oOb;
    if (GetObjectType(oTarget)==OBJECT_TYPE_CREATURE)
    { // valid oTarget type
        if (GetIsDead(oTarget)) return FALSE;
        if (GetIsPC(oTarget)) return FALSE;
        if (GetIsObjectValid(oRider)&&GetObjectType(oRider)!=OBJECT_TYPE_CREATURE) return FALSE;
        if (GetIsObjectValid(oRider)&&GetIsEnemy(oRider,oTarget)) return FALSE;
        if (GetIsDMPossessed(oTarget)) return FALSE;
// CUSTOMISED
        if (HorseGetIsMounted(oRider))
          if (!GetIsPC(oRider) || !bAssignMount)
            return FALSE;
// END CUSTOMISED
        //if (GetIsObjectValid(oRider)&&GetCreatureTailType(oRider)!=CREATURE_TAIL_TYPE_NONE) return FALSE;
        nAppearance=GetAppearanceType(oRider);
        if (GetIsPC(oRider)&&nAppearance>6&&GetLocalInt(oRider,"X3_CUSTOM_RACE_APPEARANCE")!=nAppearance&&!Horse_SupportRaceAppearance(nAppearance)) return FALSE; // PC is shape shifted
        if (GetIsObjectValid(oRider)&&GetObjectType(oRider)==OBJECT_TYPE_CREATURE)
        { // Rider is a creature
            sS=HORSE_SupportRaceRestrictString(oRider);
            if (GetLocalInt(oTarget,sS)) return FALSE; // race restricted
        } // Rider is a creature
        oOb=GetMaster(oTarget);
        if (GetIsObjectValid(oOb)&&GetIsObjectValid(oRider))
        { // has master make sure is part of party
            if (oOb!=oRider&&oOb!=GetMaster(oRider)&&GetMaster(oOb)!=GetMaster(oRider))
            { // not part of party
// CUSTOMISED
              if ((oRider != GetMaster(oOb)) || !bAssignMount)
                return FALSE;
// END CUSTOMISED
            } // not part of party
        } // has master make sure is part of party
        if (GetLocalInt(oTarget,"X3_HORSE_NOT_RIDEABLE_OWNER"))
        { // not rideable due to owner
            return FALSE;
        } // not rideable due to owner
        if (GetLocalInt(GetArea(oTarget),"X3_NO_MOUNTING")&&!bAssignMount)
        { // no mounting allowed in this area
            return FALSE;
        } // no mounting allowed in this area
        sS=GetResRef(oTarget);
        if (GetStringLeft(sS,GetStringLength(HORSE_PALADIN_PREFIX))==HORSE_PALADIN_PREFIX&&GetIsObjectValid(oRider))
        { // paladin mount
            if (HorseGetOwner(oTarget)!=oRider) return FALSE;
        } // paladin mount
        if (!HorseGetIsAMount(oTarget)) return FALSE;
        return TRUE;
    } // valid oTarget type
    return FALSE;
} // HorseGetCanBeMounted()
