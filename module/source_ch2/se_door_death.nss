#include "x2_inc_compon"

//::////////////////////////////////////////////////////////////////////////////
//:: Name Respawn Door/s v1.1
//:: FileName se_door_death
//:: Copyright (c) 2001 Bioware Corp.
//::////////////////////////////////////////////////////////////////////////////
/*
     Respawn a door after a set delay
     Set a float on the door ie. RESPAWN_TIMER = xx else the default is used
     Thanks to Craig Welburn for the insight
     Cheers to Zarathustra217
*/
//::////////////////////////////////////////////////////////////////////////////
//:: Created By: Sir Elric
//:: Created On: 8th May, 2006
//:: Event Used: OnDeath event of a door
//::////////////////////////////////////////////////////////////////////////////



// -----------------------------------------------------------------------------
//  CONSTANTS - Settings below
// -----------------------------------------------------------------------------

const float RESPAWN_TIMER_DEFAULT = 300.0; // Default respawn delay
const int   DO_CRAFT_DROP         = FALSE;// Drop default Bioware crafting item?
const int   DEBUG_MODE            = TRUE; // Debug info on?


// -----------------------------------------------------------------------------
//  PROTOTYPES
// -----------------------------------------------------------------------------

// Respawn a door after a set delay
// If no float is set on the door ie. RESPAWN_TIMER = xx
// The default delay will be used ie. RESPAWN_TIMER_DEFAULT = xx
// oSelf: - Object calling the script
void SE_RespawnDoor(object oSelf);

void SE_Debug(string sMessage);
// -----------------------------------------------------------------------------
//  FUNCTIONS
// -----------------------------------------------------------------------------

void SE_RespawnDoor(object oSelf)
{
    PlayAnimation(ANIMATION_DOOR_CLOSE);
    int nHealAmount = GetMaxHitPoints(oSelf) - GetCurrentHitPoints(oSelf);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHealAmount), oSelf);
}

void SE_Debug(string sMessage)
{
    if(DEBUG_MODE) SendMessageToPC(GetFirstPC(), sMessage);
}


// -----------------------------------------------------------------------------
//  MAIN
// -----------------------------------------------------------------------------

void main()
{
   object oSelf = OBJECT_SELF;
   SetIsDestroyable(FALSE);

   float fDelay = GetLocalFloat(oSelf, "RESPAWN_TIMER");
   if(fDelay == 0.0)
   fDelay = RESPAWN_TIMER_DEFAULT;

   SE_Debug(GetName(oSelf) + "'s respawn timer is set to " +
       FloatToString(fDelay, 0, 0) + " seconds");

   DelayCommand(fDelay, SE_RespawnDoor(oSelf));

   if(DO_CRAFT_DROP)
   craft_drop_placeable();
}
