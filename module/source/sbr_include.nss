//::///////////////////////////////////////////////
//:: Name       Demetrious' Supply Based Rest
//:: FileName   SBR_include
//:://////////////////////////////////////////////
// http://nwvault.ign.com/Files/scripts/data/1055903555000.shtml

/*
Always recompile your module after modifying 'sbr_include' because it is an include file.
#1: Select "Build" from the toolset menu and then choose "Build Module".
#2: Click the "Advanced Controls" box to bring up the advanced options.
#3: Make sure that the only boxes that are selected are "Compile" and "Scripts".
#4: Click the "Build" button.
#5: Remember to always make sure you are using the options you want to use when running "Build Module"!
*/

#include "inc_logmessage"
#include "nw_i0_plot"

// ****************************************************************************
// ** CONFIGURATION
// ****************************************************************************

// The variable below sets up how the DM Rest widget is configured.
// Change this to true to only toggle rest module wide rather
// than using the 3 different level options.
// If this is TRUE clicking the ground, yourself or a player will
// toggle the Module level rest restiction.
// If FALSE, then you have 3 options.
//    Target yourself = Module level toggle.
//    Target ground (ie the area) = Area level toggle.
//    Target player = Party level toggle.
//
// In either mode, targetting an NPC or other placeable will report
// all pertinent rest system information to you.
const int SBR_MAKE_IT_SIMPLE = FALSE;

// This is the maximum distance the player can be from a "restful object" to
// automatically use it when they hit rest.
const float SBR_DISTANCE = 5.0;

// This is the event number that will be signalled to your module OnUserDefined Event
// when a player rests. This user defined event is how you should extend the system
// so that specific things happen on rest. IE: create some wandering monsters,
// play a cutscene, teleport them to a "dream" area, etc.
const int SBR_EVENT_REST = 2000;

// ****************************************************************************
// ** CONSTANTS - TAGS
// ****************************************************************************

// These tags correspond to items that come with this package.

const string SBR_KIT_WOODLAND = "woodlandkit";
const string SBR_KIT_REGULAR = "supplykit";
const string SBR_DM_WIDGET = "DMRestWidget";

// ****************************************************************************
// ** CONSTANTS - LOCAL VARIABLE NAMES
// ****************************************************************************

const string SBR_RESTING = "SBR_SomeoneResting";
const string SBR_SUPPLIES = "SBR_Supplies";
const string SBR_USED_KIT = "SBR_UsedKit";
const string SBR_REST_NOT_ALLOWED = "SBR_RestIsNotAllowed";

/*
Possible log levels for LogMessage 1.06
// Do not send a message.
const int LOG_DISABLED        = 0x0;
// Send only to the oPC who activated it (floating text)
const int LOG_PC              = 0x1;
// Send only to the oPC who activated it (server message window)
const int LOG_PC_SERVER       = 0x2;
// Send to all players on the server (server message window)
const int LOG_PC_ALL          = 0x4;
// Send to the oPC and all of their party members (floating text)
const int LOG_PARTY           = 0x8;
// Send to the oPC and all of their party members (server message window)
const int LOG_PARTY_SERVER    = 0x10;
// Send to the oPC and their nearby (30m) party members (floating text)
const int LOG_PARTY_30        = 0x20;
// Send to the DM channel (DM channel)
const int LOG_DM_ALL          = 0x40;
// Send to all DMs within distance 10m of oPC (floating text)
const int LOG_DM_10           = 0x80;
// Send to all DMs within distance 20m of oPC (floating text)
const int LOG_DM_20           = 0x100;
// Send to all DMs within distance 40m of oPC (floating text)
const int LOG_DM_40           = 0x200;
// Send to all DMs within distance 80m of oPC (floating text)
const int LOG_DM_80           = 0x400;
// Make oPC whisper the message (chat message window)
const int LOG_WHISPER         = 0x800;
// Make oPC talk the message (chat message window)
const int LOG_TALK            = 0x1000;
// Make oPC shout the message (chat message window)
const int LOG_SHOUT           = 0x2000;
// Send to the server log file
const int LOG_TO_SERVER_LOG   = 0x4000;
// Send to the server log file with time stamp
const int LOG_TIME_SERVER_LOG = 0x8000;
// Send to all DMs within distance 10m of oPC (server message window)
const int LOG_DM_10_SERVER    = 0x10000;
// Send to all DMs within distance 20m of oPC (server message window)
const int LOG_DM_20_SERVER    = 0x20000;
// Send to all DMs within distance 40m of oPC (server message window)
const int LOG_DM_40_SERVER    = 0x40000;
// Send to all DMs within distance 80m of oPC (server message window)
const int LOG_DM_80_SERVER    = 0x80000;
// Send to the oPC and all of their party members who percieve oPC (floating text)
const int LOG_PARTY_PERC      = 0x100000;
// Send to the oPC and all of their party members who percieve oPC (server message window)
const int LOG_PARTY_PERC_SERVER = 0x200000;
// Send to the oPC and their nearby (10m) party members (floating text)
const int LOG_PARTY_10        = 0x400000;
// Send to the oPC and their nearby (20m) party members (floating text)
const int LOG_PARTY_20        = 0x800000;
// Send to the oPC and their nearby (40m) party members (floating text)
const int LOG_PARTY_40        = 0x1000000;
// Send to the oPC and their nearby (80m) party members (floating text)
const int LOG_PARTY_80        = 0x2000000;
// Send to all DMs as a server message
const int LOG_DM_ALL_SERVER   = 0x4000000;
// Send to all party EXCEPT for the player who triggered as a server message
const int LOG_PARTY_ONLY      = 0x8000000;
// Send to all party EXCEPT for the player *and people who can't see the player) who triggered as a server message
const int LOG_PARTY_PERC_ONLY      = 0x10000000;
*/

//::///////////////////////////////////////////////
//:: Report Rest Statistics to the DM
//:: uhhh.... no copyright - Demetrious
//:://////////////////////////////////////////////
void ReportStats(object oPC)
{
object oPlayer = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR,PLAYER_CHAR_IS_PC, oPC);
int iLogLevel = LOG_PC; // Log level used with LogMessage

//report some general information to the DM not based on a specific player
    if (GetLocalInt(GetModule(), SBR_REST_NOT_ALLOWED)==1)
        LogMessage(iLogLevel, oPC, "MODULE REST DISABLED");
        else
        LogMessage(iLogLevel, oPC, "MODULE REST ENABLED");

    if (!SBR_MAKE_IT_SIMPLE)
    {
    if (GetLocalInt(GetArea(oPC), SBR_REST_NOT_ALLOWED)==1)
        LogMessage(iLogLevel, oPC, "AREA REST DISABLED: "+GetName(GetArea(oPC))+".");
        else
        LogMessage(iLogLevel, oPC, "AREA REST ENABLED: "+GetName(GetArea(oPC))+".");
    }
    // see if there is a rest trigger in the area and alert the DM if there is one.
    object oSafeTrigger = GetNearestObjectByTag("X0_SAFEREST", oPC);
    if (GetArea(oSafeTrigger)==GetArea(oPC))
        LogMessage(iLogLevel, oPC, "Must Secure Region to Rest.  AREA: "+ GetName(GetArea(oPC))+".");
        else
        LogMessage(iLogLevel, oPC, "No rest triggers.  AREA: "+ GetName(GetArea(oPC))+".");

    // now look for the closest player and see if we can give more details to the DM.
    int nSupply = 0;  int nWoodland = 0;


    if (!GetIsObjectValid(oPlayer))
        {
        LogMessage(iLogLevel, oPC, "There are no characters near where you clicked.");
        return;
        }
        else
        {
    object oCurrentPlayer = GetFirstFactionMember(oPlayer, TRUE);

    while (GetIsObjectValid(oCurrentPlayer))
    {
    object oCurrent = GetFirstItemInInventory(oCurrentPlayer);
    while (GetIsObjectValid(oCurrent))
        {
        if (GetTag(oCurrent)==SBR_KIT_REGULAR)
            {
            nSupply = nSupply+1;
            }
        if (GetTag(oCurrent)==SBR_KIT_WOODLAND)
            {
            nWoodland = nWoodland+1;
            }

        oCurrent = GetNextItemInInventory(oCurrentPlayer);
        }

    oCurrentPlayer = GetNextFactionMember(oPlayer, TRUE);
    }

    //Here we send all the information to the DM regarding the rest system and the closest player.

    LogMessage(iLogLevel, oPC, "Stats for (closest player):  "+GetName(oPlayer));
    LogMessage(iLogLevel, oPC, IntToString(nSupply)+ " : Supply kits remaining in the party.");
    LogMessage(iLogLevel, oPC, IntToString(nWoodland)+ " : Woodland kits remaining in the party.");

    if (!SBR_MAKE_IT_SIMPLE)
    {
    if (GetPLocalInt(oPlayer, SBR_REST_NOT_ALLOWED)==1)
        LogMessage(iLogLevel, oPC, "PARTY REST DISABLED: "+GetName(oPlayer)+".");
        else
        LogMessage(iLogLevel, oPC, "PARTY REST ENABLED: "+GetName(oPlayer)+".");
    }

}

}


//::///////////////////////////////////////////////
//:: CreateKit function
//:: uhhh.... no copyright - Demetrious
//:://////////////////////////////////////////////
// This function creates the kit you just tried
// to use but could not for any number of reasons.
void CreateKit(object oPC, string sItemTag, int bOnGround = FALSE)
{
    string sResRef = sItemTag == SBR_KIT_WOODLAND ? "supplykit001" : "supplykit002";

    //now give back the item the dumb player should not have tried to use :)
    if (bOnGround == TRUE)
    {
        // Create the kit on the ground.
        CreateObject(OBJECT_TYPE_ITEM, sResRef, GetLocation(oPC));
    } else {
        // Create the kit on the player.
        CreateItemOnObject(sResRef, oPC, 1);
    }
}



//::///////////////////////////////////////////////
//:: CanIRest
//:: uhhh.... no copyright - Demetrious
//:://////////////////////////////////////////////
/*
Rest can be disabled on three different levels

Module wide, area wide, and party wide.

This flexibility is included due to the number of different manners
in which people run servers.

The script will check for restrictions at each level
and return TRUE if no restrictions are found.
*/
int CanIRest(object oPC)
    {
    int iLogLevel = LOG_DM_20; // Log level used with LogMessage

    if (GetLocalInt(GetModule(), SBR_REST_NOT_ALLOWED)==1)
        {
        LogMessage(iLogLevel, oPC, GetName(oPC)+" can't rest because of Module Level Restriction");
        return FALSE;
        }
    if (SBR_MAKE_IT_SIMPLE)
        return TRUE;

    if (GetLocalInt(GetArea(oPC), SBR_REST_NOT_ALLOWED)==1)
        {
        LogMessage(iLogLevel, oPC, GetName(oPC)+" can't rest because of Area Level Restriction");
        return FALSE;
        }
    if (GetPLocalInt(oPC, SBR_REST_NOT_ALLOWED)==1)
        {
        LogMessage(iLogLevel, oPC, GetName(oPC)+" can't rest because of Party Level Restriction");
        return FALSE;
        }

    return TRUE;
    }

//::///////////////////////////////////////////////
//:: NotOnSafeRest
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    returns TRUE if the player is not in a safe
    zone within an area.

    RULE: There must be at least one door
          All doors must be closed

    - takes player object
    - finds nearest safe zone
    - is player in safe zone?
       - find all doors in safe zone
        - are all doors closed?
            - if YES to all the above
                is safe to rest,
                    RETURN FALSE
    - otherwise give appropriate feedback and return TRUE

EDITS:  I added a quick check to look for the nearest trigger
        in the SAME AREA ONLY.  This is the only code that I
        changed. - Demetrious
*/
int NotOnSafeRest(object oPC)
{  // SpawnScriptDebugger();
    object oSafeTrigger = GetNearestObjectByTag("X0_SAFEREST", oPC);
    int bAtLeastOneDoor = FALSE;
    int bAllDoorsClosed = TRUE;
    int bPCInTrigger = FALSE;
    if (GetArea(oSafeTrigger)!=GetArea(oPC))
        return FALSE;

    if (GetIsObjectValid(oSafeTrigger))
    {
        if (GetObjectType(oSafeTrigger) == OBJECT_TYPE_TRIGGER)
        {

            // * cycle through trigger looking for oPC
            // * and looking for closed doors
            object oInTrig = GetFirstInPersistentObject(oSafeTrigger, OBJECT_TYPE_ALL);
            while (GetIsObjectValid(oInTrig) == TRUE)
            {
                // * rester is in trigger!
                if (oPC == oInTrig)
                {
                    bPCInTrigger = TRUE;
                }
                else
                {
                    // * one door found
                    if (GetObjectType(oInTrig) == OBJECT_TYPE_DOOR)
                    {
                        bAtLeastOneDoor = TRUE;
                        // * the door was open, exit
                        if (GetIsOpen(oInTrig) == TRUE)
                        {
                            return TRUE; //* I am no in a safe rest place because a door is open
                        }
                    }
                }
                oInTrig = GetNextInPersistentObject(oSafeTrigger, OBJECT_TYPE_ALL);
            }
        }
    }
    if (bPCInTrigger == FALSE || bAtLeastOneDoor == FALSE)
    {
        return TRUE;
    }
    // * You are in a safe trigger, if in a trigger, and all doors closed on that trigger.
    return FALSE;
}


