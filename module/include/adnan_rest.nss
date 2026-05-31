//::///////////////////////////////////////////////
//:: Basic Resting Script v1.1
//:: boz_onrest_v11.nss
//:: Copyright (c) 2002 Brotherhood of Zock
//:://////////////////////////////////////////////
/*
   This script allows the players to rest after a specified amount of hours
   has passed and no hostile creatures are nearby.

   Notes:
   It only affects Player Characters. Familiars, summoned creatures and probably henchmen WILL rest!

   Installation:
   Place this script in the module onRest event.

   Modifications:
   Modified August 10, 2002
   Option to set the level at which the rest-restrictions will be applied to the players added (Main-Function: Script Settings).
*/
//:://////////////////////////////////////////////
//:: Created By: Timo "Lord Gsox" Bischoff (NWN Nick: Kihon)
//:: Created On: August 04, 2002
//:://////////////////////////////////////////////



//::///////////////////////////////////////////////
//:: GetHourTimeZero
//:: Copyright (c) 2002 BrotherhoodofZock
//:://////////////////////////////////////////////
/*
   modified July 30, 2002
   iHourTimeZero calculation modified. iYear-1 replaced by iYear.
   In NWN the Year-count starts with 0 (though year 0 doesn't make much sense).
   Think of year 0 as the first year (Year 1).
*/
//:://////////////////////////////////////////////
//:: Created By: Timo "Lord Gsox" Bischoff (NWN Nick: Kihon)
//:: Created On: July 07, 2002
//:://////////////////////////////////////////////

// Counting the actual date from Year0 Month0 Day0 Hour0 in hours
int GetHourTimeZero(int iYear = 99999, int iMonth = 99, int iDay = 99, int iHour = 99)
{
  // Check if a specific Date/Time is forwarded to the function.
  // If no or invalid values are forwarded to the function, the current Date/Time will be used
  if (iYear > 30000)
    iYear = GetCalendarYear();
  if (iMonth > 12)
    iMonth = GetCalendarMonth();
  if (iDay > 28)
    iDay = GetCalendarDay();
  if (iHour > 23)
    iHour = GetTimeHour();

  //Calculate and return the "HourTimeZero"-TimeIndex
  int iHourTimeZero = (iYear)*12*28*24 + (iMonth-1)*28*24 + (iDay-1)*24 + iHour;
  return iHourTimeZero;
}



//::///////////////////////////////////////////////
//:: Main Function
//:: Copyright (c) 2002 Brotherhood of Zock
//:://////////////////////////////////////////////
/*
   The Main Function of the resting script.

   Modified August 10, 2002
   iLevelAffected variable added. The Rest-restrictions will NOT be applied to players
   that don't have the level (HitDice) specified in the iLevelAffected variable.
*/
//:://////////////////////////////////////////////
//:: Created By: Timo "Lord Gsox" Bischoff (NWN Nick: Kihon)
//:: Created On: August 04, 2002
//:://////////////////////////////////////////////
// The main function placed in the onRest event
#include "se_inc_pc_loc"

void main()
{
  // Script Settings (Variable Declaration)
  int iLevelAffected = 41;   // The min. PC Level at which the Rest-restrictions will be applied (1-20; default=2)
  int iRestDelay = 2;       // The ammount of hours a player must wait between Rests (Default = 8 hours)
  int iHostileRange = 6;   // The radius around the players that must be free of hostiles in order to rest.
                            // iHostileRange = 0: Hostile Check disabled
                            // iHostileRange = x; Radius of Hostile Check (x meters)
                            // This can be abused as some sort of "monster radar".

  // Variable Declarations
  object oPC = GetLastPCRested(); // This Script only affects Player Characters. Familiars, summoned creatures and probably henchmen WILL rest!

  if (GetHitDice (oPC) >= iLevelAffected) // Check if the rest-restrictions will be applied to the player
  {
    // ---------- Rest Event started ----------
    if (GetLastRestEventType() == REST_EVENTTYPE_REST_STARTED)
     SE_SaveLocation(oPC);
    {
      // Cooldown removed - always allow resting if no hostiles nearby
      {
        object oCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
        if (iHostileRange == 0 || (iHostileRange != 0 && GetDistanceToObject(oCreature) <= IntToFloat(iHostileRange)))
        { // If Hostile Check disabled or no Hostiles within Hostile Radius: Initiate Resting
          object oRestbedroll = CreateObject (OBJECT_TYPE_PLACEABLE, "plc_bedrolls", GetLocation (oPC), FALSE); // Place a static bedroll under the player
          SetLocalObject (oPC, "o_PL_Bedrollrest", oRestbedroll); // Temporary "global" variable. Gets deleted after deletion of the bedroll.
          SetLocalInt (oPC, "i_TI_LastRest", GetHourTimeZero()); // Set Last Rest Time
        }
        else
        { // Resting IS NOT allowed
          AssignCommand (oPC, ClearAllActions()); // Prevent Resting
          SendMessageToPC (oPC, "Hey, how can you sleep at a time like this!");
        }
      }
    }

    // ---------- Rest Event finished or aborted ----------
    if ((GetLastRestEventType() == REST_EVENTTYPE_REST_FINISHED || GetLastRestEventType() == REST_EVENTTYPE_REST_CANCELLED) && GetIsObjectValid(GetLocalObject (oPC, "o_PL_Bedrollrest")))
    { // If a bedroll was placed under the player: Delete it
     DestroyObject (GetLocalObject (oPC, "o_PL_Bedrollrest"), 0.0f);
     DeleteLocalObject (oPC, "o_PL_Bedrollrest");
    }
  }
}
