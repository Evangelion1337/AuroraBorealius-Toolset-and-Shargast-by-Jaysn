//::////////////////////////////////////////////////////////////////////////////
//:: Name Sir Elric's Respawning Traps v2.6
//:: FileName se_respawn_traps
//::////////////////////////////////////////////////////////////////////////////
/*
    (All settings are found in the script se_inc_resp_trap)

    Introduction - Respawn traps on the ground an object or a door.
    ===============================================================
    - Open the area propeties for the area you want respawnable traps.
      In the OnEnter event add the script: se_oea_rsp_traps

    - For static ground traps. Place an invisible object tagged INVIS_TRAP_SPAWNER,
      where you want the trap set the variables on this object and your done.

    - For random or specific object or door traps. Place an invisible object,
      tagged INVIS_TRAP_SPAWNER_RANDOM anywhere in the area set the variables,
      and your done. For random ground traps place waypoints tagged,
      RANDOM_GROUND_TRAP_LOCATION within the same area.
      They will be chosen at random for trap placement.
      (This is not totally random location traps but instead gives the builder,
       control of where the random placement of these traps will/can occur)

    - You can use a combination of INVIS_TRAP_SPAWNER & INVIS_TRAP_SPAWNER_RANDOM

    - Optional reward disarm xp

    - How to set variables on an object, waypoint or door?
      Open the properties of the object click on Advanced Tab > Variables or,
      right click the placed object and select variables(far quicker btw).
      Now type in the name select the type add the value and click on "Add".

    - What variables do I set? Read on for full instructions and examine the,
      objects in the demo module they have detailed information on how they are,
      set up. Debugging is also on by default.


    Full instructions for respawning ground traps at a particular place:
    ====================================================================

    1) Open the area properties and in the OnEnter event add the script:
       se_oea_rsp_traps.

       Optional - You can set a local float TRAP_AREA_TIMER = (in seconds) on each,
       area for faster or slower respawns otherwise the default is used,
       see se_inc_resp_trap.

       eg. float TRAP_AREA_TIMER = 3600(1 hr)
           float TRAP_AREA_TIMER = 1800(30 mins)

    2) Create an invisible object with the tag INVIS_TRAP_SPAWNER place it,
       where you want the trap to appear

    3) Set a variable(int) on the invisible object for the trap strength.
       TRAP_TYPE int = 1 (ie. 1 Minor, 2 Average, 3 Strong, 4 Deadly, 5 Epic)
       A random trap will be selected from that category.
       *Note - If no trap type is defined it will default to 2(Average)

    4) Set a variable(float) on the invisible object for the trap size.
       TRAP_SIZE float = 2 (ie. 2 game meters)
       *Note - If no trap size is defined it will default to 1(ie. 1 game meter)

    5) Optional settings(If these are not set the standard Bioware trap settings are used)
       TRAP_DETECTABLE  int = 1 (Non-Detectable)
       TRAP_DETECT_DC   int = 1 to 250
       TRAP_DISARM      int = 1 (Non-Disarmable)
       TRAP_DISARM_DC   int = 1 to 250
       TRAP_RECOVERABLE int = 1 (Non-Recoverable)
       TRAP_MULTI_SHOT  int = 1 (Multiple shot traps, new to v2.3)

    6) New optional setting(new to v2.6)
       PRESET_TYPE int = 1 to 11
       If set that type of trap will be selected rather than a random trap.

       (Minor, Average, Strong & Deadly)
       1  = ACID
       2  = ACID SPLASH
       3  = ELECTRICAL
       4  = FIRE
       5  = FROST
       6  = GAS
       7  = HOLY
       8  = NEGATIVE
       9  = SONIC
       10 = SPIKE
       11 = TANGLE

       PRESET_TYPE int = 1 to 4
       (Epic only)
       1 = ELECTRICAL
       2 = FIRE
       3 = FROST
       4 = SONIC


    Full Instructions for respawning random traps on objects & doors in an area:
    ============================================================================
    1) Open the area propeties and in the OnEnter event add the script:
       se_oea_rsp_traps

       Optional - You can set a local float TRAP_AREA_TIMER = (in seconds) on each,
       area for faster or slower respawns otherwise the default is used,
       see se_inc_resp_trap.

       eg. float TRAP_AREA_TIMER = 3600(1 hr)
           float TRAP_AREA_TIMER = 1800(30 mins)

    2) Create an invisible object with the tag INVIS_TRAP_SPAWNER_RANDOM place,
       it anywhere in the area.

    3) Set a variable(int) on the invisible object to choose the percentage
       chance of creating a trap on each object or door in the area.
       TRAP_PERCENTILE int = 25 (25% chance of trapping each object/door)
       *Note - If the trap percentile is not defined it will default to 50%

    4) Set a variable(float) on the invisible object for the trap size.
       TRAP_SIZE float = 2 (ie. 2 game meters)
       *Note - If no trap size is defined it will default to 1(ie. 1 game meter)

    5) Set a variable(int) on the invisible object for the trap strength.
       TRAP_TYPE int = 1 (ie. 1 Minor, 2 Average, 3 Strong, 4 Deadly, 5 Epic)
       A random trap will be selected from that category.
       *Note - If no trap type is defined it will default to 2(Average)

    6) Trap DisarmDC is randomly chosen depending on the trap type category ie:

       1 Minor   = 25 - 35 DC range
       2 Average = 25 - 35 DC range
       3 Strong  = 30 - 40 DC range
       4 Deadly  = 35 - 45 DC range
       5 Epic    = 50 - 60 DC range

       This can be set to suit your module (see se_inc_resp_trap)

    7) For random ground traps place a waypoint tagged RANDOM_GROUND_TRAP_LOCATION,
       in various places in the area that will suit a ground trap position.
       When the spawner scans the area for objects, depending on the percentile,
       each one of these may have a random trap spawned at their location.
       *Note - If no trap size is defined it will default to 1.0
       (This is not totally random but gives the builder control of where the,
       random placement of these traps will/can occur)

    8) To ensure a placeable or door is always trapped set this local int on it:
       TRAP_ALWAYS int = 1

    9) To ensure a placeable or door is never trapped set this local int on it:
       TRAP_NEVER int = 1

    10)If you want the random traps to be randomized each time a player enter
       set this local int on the spawner:
       RANDOMIZE_EVERYTIME int = 1
       This will remove all previously spawned traps and randomly select new,
       objects and locations for the new ones.

    11) New optional setting(new to v2.6)
       PRESET_TYPE int = 1 to 11
       If set that type of trap will be selected rather than a random trap.

       (Minor, Average, Strong & Deadly)
       1  = ACID
       2  = ACID SPLASH
       3  = ELECTRICAL
       4  = FIRE
       5  = FROST
       6  = GAS
       7  = HOLY
       8  = NEGATIVE
       9  = SONIC
       10 = SPIKE
       11 = TANGLE

       PRESET_TYPE int = 1 to 4
       (Epic only)
       1 = ELECTRICAL
       2 = FIRE
       3 = FROST
       4 = SONIC

    Full Instructions for respawning specific traps on objects & doors in an area:
    ==============================================================================

    1) Open the area propeties and in the OnEnter event add the script:
       se_oea_rsp_traps

       Optional - You can set a local float TRAP_AREA_TIMER = (in seconds) on each,
       area for faster or slower respawns otherwise the default is used,
       see se_inc_resp_trap.

       eg. float TRAP_AREA_TIMER = 3600(1 hr)
           float TRAP_AREA_TIMER = 1800(30 mins)

    2) To ensure a placeable or door is always trapped set this local int on it:
       TRAP_ALWAYS int = 1

    3) Set a variable(int) on the object for the trap strength ie.
       TRAP_TYPE int = 1 (ie. 1 Minor, 2 Average, 3 Strong, 4 Deadly, 5 Epic)
       A random trap will be selected from that category.
       *Note - If no trap type is defined it will default to 2(Average)

    4) New optional setting(new to v2.6)
       PRESET_TYPE int = 1 to 11
       If set that type of trap will be selected rather than a random trap.

       (Minor, Average, Strong & Deadly)
       1  = ACID
       2  = ACID SPLASH
       3  = ELECTRICAL
       4  = FIRE
       5  = FROST
       6  = GAS
       7  = HOLY
       8  = NEGATIVE
       9  = SONIC
       10 = SPIKE
       11 = TANGLE

       PRESET_TYPE int = 1 to 4
       (Epic only)
       1 = ELECTRICAL
       2 = FIRE
       3 = FROST
       4 = SONIC
*/
//::////////////////////////////////////////////////////////////////////////////
//:: Created By   : Sir Elric
//:: Created On   : 19th June, 2006
//:: Modified On  : 22nd December, 2006
//:: Event Used   : None - This script is called from se_oea_rsp_trap
//:: Patch        : 1.67 or above required
//::////////////////////////////////////////////////////////////////////////////


// -----------------------------------------------------------------------------
//  MAIN
// -----------------------------------------------------------------------------
#include "se_inc_resp_trap"

void main()
{
   object oSelf = OBJECT_SELF;
   // Random trap spawner?
   if(GetTag(oSelf) == "INVIS_TRAP_SPAWNER_RANDOM")
   {
      if(GetLocalInt(oSelf, "RANDOMIZE_EVERYTIME") == FALSE)
      {
          if(GetLocalInt(oSelf, "LOOP_AREA_ONCE") == FALSE)
          {
             SE_SetRandomTraps(oSelf);
          }
          else
          {
             SE_CheckRandomTraps(oSelf);
          }
          return;
      }
      else
      {
          SE_SetRandomTrapsEveryTime(oSelf);
          SE_Debug("[" + GetName(GetArea(oSelf)) + "] Trap this area randomly everytime");
      }
   }
   location lLoc;

   // Return the trap type, if not set use the default
   int nTrapType = SE_ReturnTrapType(oSelf);

   // Invisible ground trap spawner?
   if(GetTag(oSelf) == "INVIS_TRAP_SPAWNER")
   {
      // Return the trap size, if not set use the default
      float fSize = SE_ReturnTrapSize(oSelf);

      object oTrap = GetNearestTrapToObject(oSelf, FALSE);

      if(SE_CheckGroundTrapStatus(oSelf, oTrap))
      {
         lLoc = GetLocation(oSelf);
         SE_SpawnTrapAtLocation(lLoc,
             fSize,
             oSelf,
             SE_TrapType(nTrapType, oSelf),
             GetLocalInt(oSelf, "TRAP_DETECTABLE"),
             GetLocalInt(oSelf, "TRAP_DETECT_DC"),
             GetLocalInt(oSelf, "TRAP_DISARM"),
             GetLocalInt(oSelf, "TRAP_DISARM_DC"),
             GetLocalInt(oSelf, "TRAP_RECOVERABLE"),
             GetLocalInt(oSelf, "TRAP_MULTI_SHOT"));
      }
   }
   else if(SE_GetIsValidTrapTarget(oSelf))
   {
      if(!GetIsTrapped(oSelf))
      {
          SE_SpawnTrapOnObject(oSelf,
              SE_TrapType(nTrapType, oSelf),
              GetLocalInt(oSelf, "TRAP_DETECTABLE"),
              GetLocalInt(oSelf, "TRAP_DETECT_DC"),
              GetLocalInt(oSelf, "TRAP_DISARM"),
              GetLocalInt(oSelf, "TRAP_DISARM_DC"),
              GetLocalInt(oSelf, "TRAP_RECOVERABLE"),
              GetLocalInt(oSelf, "TRAP_MULTI_SHOT"));
      }
   }
}
