//::////////////////////////////////////////////////////////////////////////////
//:: Name Persistant Player Location Save
//:: FileName se_inc_pc_loc
//::////////////////////////////////////////////////////////////////////////////
#include "sql_campaign"
/*
    Save a players location persistantly through a server reset
    Timed save and/or in the OnRest of PC, OnActionTaken of NPC, OnUsed of plc.
*/
//::////////////////////////////////////////////////////////////////////////////
//:: Created By : Sir Elric
//:: Created On : 21st July, 2006
//:: Modified On: 10th February, 2007
//::////////////////////////////////////////////////////////////////////////////


// -----------------------------------------------------------------------------
//  CONSTANTS - Settings
// -----------------------------------------------------------------------------

const int TIMED_SAVE_ACTIVE = TRUE; // << Timed save switched on or off?

const float TIMED_SAVE_DELAY = 300.0; // << Save location delay, if active

const int SEND_MESSAGE = TRUE; // << Send a save location message to player?

const string PC_MESSAGE = "Your location has been saved."; // << Player location message, if active

const float JUMP_DELAY = 10.0;// << allows player to fully log in before the jump

const string CAMPAIGN_NAME = "PERSISTANT_LOCATION";// << leave as is

const string CAMPAIGN_VAR = "PCLocation";// << leave as is

// -----------------------------------------------------------------------------
//  PROTOTYPES
// -----------------------------------------------------------------------------

// Save the players current location
// Can be used in the OnRest of PC, OnActionTaken of NPC, OnUsed of plc etc.
// Also used within the timed save, if active.
void SE_SaveLocation(object oPC);

// Check if the player has a persistant location saved if so jump them to it
void SE_JumpToPersistantLocation(object oPC);

// Inital check for a persistantly saved location for the player
// If one exists jump them to it
// Initiate timed save if active
void SE_PersistantPCLocation(object oPC);

// Antiquated function
void SE_SavePCLocation(object oPC);

// -----------------------------------------------------------------------------
//  FUNCTIONS
// -----------------------------------------------------------------------------

void SE_SaveLocation(object oPC)
{
    SQL_SetCampaignLocation(CAMPAIGN_NAME, CAMPAIGN_VAR, GetLocation(oPC), oPC);
    if(SEND_MESSAGE)
       SendMessageToPC(oPC, PC_MESSAGE);
}

void SE_JumpToPersistantLocation(object oPC)
{
    SetLocalInt(oPC, "ENTERED", TRUE);
    location lLoc = SQL_GetCampaignLocation(CAMPAIGN_NAME, CAMPAIGN_VAR, oPC);
    if(GetIsObjectValid(GetAreaFromLocation(lLoc)))
    {
       DelayCommand(JUMP_DELAY, AssignCommand(oPC, JumpToLocation(lLoc)));
    }
}

void SE_PersistantPCLocation(object oPC)
{
   if(GetIsDM(oPC)) return;
   if(GetLocalInt(oPC, "ENTERED") == FALSE)
   {
      SE_JumpToPersistantLocation(oPC);
   }
   else
   {
      SE_SaveLocation(oPC);
   }

   if(TIMED_SAVE_ACTIVE)
   {
      DelayCommand(TIMED_SAVE_DELAY, SE_PersistantPCLocation(oPC));
   }
}

void SE_SavePCLocation(object oPC)
{
   SE_PersistantPCLocation(oPC);
}
//void main(){}
