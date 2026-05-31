//::////////////////////////////////////////////////////////////////////////////
//:: Name Sir Elric's Respawning Traps v2.6
//:: FileName se_oea_rsp_trap
//::////////////////////////////////////////////////////////////////////////////
/*
   - Add to the OnEnterArea event of any area you want respawning traps
   - Place either or both of the invisible objects tagged INVIS_TRAP_SPAWNER or
     INVIS_TRAP_SPAWNER_RANDOM set them up to suit the area and your done.
*/
//::////////////////////////////////////////////////////////////////////////////
//:: Created By   : Sir Elric
//:: Created On   : 19th June, 2006
//:: Event Used   : OnEnterArea
//:: Patch        : 1.67 or above required
//::////////////////////////////////////////////////////////////////////////////
#include "se_inc_resp_trap"


// -----------------------------------------------------------------------------
//  MAIN
// -----------------------------------------------------------------------------


void main()
{
   int bValid;
   object oPC = GetEnteringObject();
   if(GetIsObjectValid(oPC) == FALSE)
   oPC = OBJECT_SELF;

   object oArea = GetArea(oPC);

   if(GetLocalInt(oArea, "NO_TRAPS_TO_SET") == TRUE)
   {
      SE_Debug("[" + GetName(oArea) + "] Player has entered. No objects or doors are set for respawning traps in this area - return");
      return;
   }

   if(GetIsPC(oPC) && GetLocalInt(oArea, "TRAPS_SET") == FALSE)
   {
      object oObject = GetFirstObjectInArea();
      while(GetIsObjectValid(oObject))
      {
         if(GetLocalInt(oObject, "TRAP_ALWAYS") == TRUE)
         {
            bValid = TRUE;
            ExecuteScript("se_respawn_trap", oObject);
         }
         else if(SE_GetIsASpawnerObject(oObject))
         {
            bValid = TRUE;
            DelayCommand(0.5, ExecuteScript("se_respawn_trap", oObject));
         }
         oObject = GetNextObjectInArea();
      }

      if(bValid == TRUE)
      {
         SetLocalInt(oArea, "TRAPS_SET", TRUE);
         SetLocalInt(oArea, "TRAP_RESPAWN_INITIATED", TRUE);
         // If optional area timer is not set use the default SE_AREA_TIMER
         float fTimer = GetLocalFloat(oArea, "TRAP_AREA_TIMER");
         if(fTimer == 0.0)
         {
            fTimer = SE_AREA_TIMER;

           SE_Debug("[" + GetName(oArea) + "] Optional area timer not set using the default "
               + FloatToString(SE_AREA_TIMER, 2, 0) + " seconds");
         }
         AssignCommand(oArea, DelayCommand(fTimer, DeleteLocalInt(oArea, "TRAPS_SET")));
         AssignCommand(oArea, DelayCommand(fTimer, DeleteLocalInt(oArea, "TRAP_RESPAWN_INITIATED")));
         SE_Debug("[" + GetName(oArea) + "] Player has entered setting traps");
      }
      else
      {
         SetLocalInt(oArea, "NO_TRAPS_TO_SET", TRUE);
         SE_Debug("[" + GetName(oArea) + "] Player has entered. No objects or doors are set for respawning traps in this area - return");
      }
   }
   else if(GetLocalInt(oArea, "TRAP_RESPAWN_INITIATED") == TRUE)
   {
       SE_Debug("[" + GetName(oArea) + "] Trap respawn timer already initiated");
   }
   else
   {
      SE_Debug("[" + GetName(oArea) + "] Player has entered. Respawn timer has not yet been initiated");
   }
}
