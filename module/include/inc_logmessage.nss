/** @file
Log Message 1.06 - versatile send message wrapper function
by OldManWhistler

This script is available as a individual download on NWN Vault:
http://nwvault.ign.com/Files/scripts/data/1057281729727.shtml

Also check out my portfolio:
http://nwvault.ign.com/portfolios/data/1054937958.shtml

It is easiest to think of it as a wrapper for SendMessageToPC,
SendMessageToAllDMs, FloatingTextStringOnCreature, ActionSpeakString,
PrintString, and WriteTimeStampedLogEntry. You can use log message instead
of any of those functions.

The name is a misnomer, it is not a tool for "logging" text, rather a tool
for "sending" text. In retrospect I should have called it SendMessage instead
of LogMessage. My bad.

LogMessage is a generic function for sending a message to a target (PC, DM,
Party, Server log file). There is a parameter that controls how the function
will behave.

ie:
LogMessage (LOG_DISABLED, oPC, "Do nothing");
LogMessage (LOG_PC, oPC, "Send only to the oPC who activated it (floating text)");
LogMessage (LOG_PARTY, oPC, "Send to the oPC and all of their party members (floating text)");
LogMessage (LOG_PC | LOG_DM_ALL, oPC, "Send only to the oPC who activated it (floating text) and the DM channel");
LogMessage (LOG_DM_ALL, oPC, "Send to all the DMs on the server");
LogMessage (LOG_DM_20, oPC, "Send to all DMs within distance 20' of oPC");
LogMessage (LOG_TO_SERVER_LOG | LOG_PC, oPC, "Send only to the oPC who activated it (floating text) and the server log file");
LogMessage (LOG_TO_SERVER_LOG, oPC, "Send only to the server log file");
LogMessage (LOG_PARTY_PERC, oPC, "Send to oPC and all of their party members who can see them (floating text)");
LogMessage (LOG_PC_ALL, oPC, "Send to all players who have a local variable called 'Filter' with value 3", "Filter", 3);

I prefer using LogMessage because then I only have to remember one interface
for how to send a message instead of five. It is also useful because I can
make a message go multiple places just by bit wise ORing several constants
together. See more on bit wise operators:
http://www.reapers.org/nwn/reference/compiled/primer.BitwiseOperators.html

Note: Through one LogMessage function call you can send a string in any
combination of 30 different ways.

It is useful when you want to build a script that could either be used with a
persistent world or might be used with a single party and only one DM.

Say you write a script with several lines sending messages to the PCs using
SendMessageToPC and copying it on the DM channel using SendMessageToAllDMs.
Modifying your script would be a really big headache for the person trying to
use it with their PW, since the DM channel would be flooded by the actions of
the various players.

Instead of using SendMessageToPC and  SendMessageToAllDMs you could write
your messages as:
LogMessage (MY_LOG, oPC, "blah blah blah");

and then have a section in your main include file that has:
#include "inc_LogMessage"
int MY_LOG = LOGPC | LOG_DM_40;

That way the person who is running a persistent world could set
MY_LOG as LOG_PC | LOG_DM_20 while the person who is running a single
party DMed game could set MY_LOG as LOG_PC | LOG_DM_ALL.

All they would have to do is change that value of the constant you used and
recompile the scripts and then it would work the way they wanted it to with
very little hassle.

The other benefit is when the person modifying your script wants to find
a specific string to change. All they have to do is do a FindInFiles and
search for LogMessage. FindInFiles will then generate a complete list of all
your strings and the filename/line number the string is generated on.

Using SetLocalInt to create filters:
There are optional parameters to the LogMessage function called sLocalFilter
and iLocalValue. The way these work is that they require the recipient of the
message to have a LocalInt called sLocalFilter with a value of iLocalValue.
ie:
I could put a local int on specific players with SetLocalInt(oPC, "Filter1", 4);
Then LogMessage(LOG_PC_ALL, "This is a filtered message.", "", "Filter1", 4)
would send that message only to the players who have
GetLocalInt(oPC, "Filter1") == 4.
The filter does not work for the following types of logs. They will always
work irregardless of the setting of the filter variable.
LOG_DM_ALL
LOG_TO_SERVER_LOG
LOG_TIME_SERVER_LOG
LOG_PARTY_30

Changelog:
 1.01 -> 1.02
    Changed LOG_TO_SERVER_LOG so it has no time stamp
    Added LOG_PC_ALL, LOG_TIME_SERVER_LOG
    Changed so that one LogMessage call could send several messages using
    the bitwise OR operator.
 1.02 -> 1.03
    Added another parameter to LogMessage for a DM only message that is only
    added to the DM channels and the server log channels.
 1.03 -> 1.04
    Fixed a bug with LOG_PARTY_SERVER that was sending all the messages to only
    one player in the party instead of the entire party.
 1.04 -> 1.05
    Added local int filters to control who gets the message and who doesn't.
    Added some more log types:
    LOG_PARTY_10, LOG_PARTY_20, LOG_PARTY_40, LOG_PARTY_80
    - like LOG_PARTY_30 except floating text is over the head of the person
    - receiving the message.
    LOG_DM_10_SERVER, LOG_DM_20_SERVER, LOG_DM_40_SERVER, LOG_DM_80_SERVER
    - like LOG_DM_XX but with server messages instead of floating text.
    LOG_PARTY_PERC, LOG_PARTY_PERC_SERVER
    - like LOG_PARTY except it does a perception check to see if the party
    member can see oPC.
 1.05 -> 1.06
    Added LOG_DM_ALL_SERVER
    - like LOG_DM_ALL except it is sent as a server message instead of on DM channel
    Added LOG_PARTY_ONLY
    - Sends a server message to everyone in the party EXCEPT for the person who
    triggered the message (oPC)
    Added LOG_PARTY_PERC_ONLY
    - Sends a server message to everyone in the party EXCEPT for the person who
    triggered the message (oPC) and the members of the party who cannot perceive oPC
*/

// ****************************************************************************
// ** CONSTANTS
// ****************************************************************************

// Logging Level Constants - Do not change these values!
// Note: every constant is a multiple of 2. If you want to send something to
// multiple log locations then use the bitwise OR operator.
// ie: using "LOG_PC | LOG_DM_ALL" will send the message to the player and to
// the DM channel.

/// Do not send a message.
const int LOG_DISABLED        = 0x0;
/// Send only to the oPC who activated it (floating text)
const int LOG_PC              = 0x1;
/// Send only to the oPC who activated it (server message window)
const int LOG_PC_SERVER       = 0x2;
/// Send to all players on the server (server message window)
const int LOG_PC_ALL          = 0x4;
/// Send to the oPC and all of their party members (floating text)
const int LOG_PARTY           = 0x8;
/// Send to the oPC and all of their party members (server message window)
const int LOG_PARTY_SERVER    = 0x10;
/// Send to the oPC and their nearby (30m) party members (floating text)
const int LOG_PARTY_30        = 0x20;
/// Send to the DM channel (DM channel)
const int LOG_DM_ALL          = 0x40;
/// Send to all DMs within distance 10m of oPC (floating text)
const int LOG_DM_10           = 0x80;
/// Send to all DMs within distance 20m of oPC (floating text)
const int LOG_DM_20           = 0x100;
/// Send to all DMs within distance 40m of oPC (floating text)
const int LOG_DM_40           = 0x200;
/// Send to all DMs within distance 80m of oPC (floating text)
const int LOG_DM_80           = 0x400;
/// Make oPC whisper the message (chat message window)
const int LOG_WHISPER         = 0x800;
/// Make oPC talk the message (chat message window)
const int LOG_TALK            = 0x1000;
/// Make oPC shout the message (chat message window)
const int LOG_SHOUT           = 0x2000;
/// Send to the server log file
const int LOG_TO_SERVER_LOG   = 0x4000;
/// Send to the server log file with time stamp
const int LOG_TIME_SERVER_LOG = 0x8000;
/// Send to all DMs within distance 10m of oPC (server message window)
const int LOG_DM_10_SERVER    = 0x10000;
/// Send to all DMs within distance 20m of oPC (server message window)
const int LOG_DM_20_SERVER    = 0x20000;
/// Send to all DMs within distance 40m of oPC (server message window)
const int LOG_DM_40_SERVER    = 0x40000;
/// Send to all DMs within distance 80m of oPC (server message window)
const int LOG_DM_80_SERVER    = 0x80000;
/// Send to the oPC and all of their party members who percieve oPC (floating text)
const int LOG_PARTY_PERC      = 0x100000;
/// Send to the oPC and all of their party members who percieve oPC (server message window)
const int LOG_PARTY_PERC_SERVER = 0x200000;
/// Send to the oPC and their nearby (10m) party members (floating text)
const int LOG_PARTY_10        = 0x400000;
/// Send to the oPC and their nearby (20m) party members (floating text)
const int LOG_PARTY_20        = 0x800000;
/// Send to the oPC and their nearby (40m) party members (floating text)
const int LOG_PARTY_40        = 0x1000000;
/// Send to the oPC and their nearby (80m) party members (floating text)
const int LOG_PARTY_80        = 0x2000000;
/// Send to all DMs as a server message
const int LOG_DM_ALL_SERVER   = 0x4000000;
/// Send to all party EXCEPT for the player who triggered as a server message
const int LOG_PARTY_ONLY      = 0x8000000;
/// Send to all party EXCEPT for the player *and people who can't see the player) who triggered as a server message
const int LOG_PARTY_PERC_ONLY      = 0x10000000;

// ****************************************************************************
// ** BACKWARDS COMPATIBILITY
// ****************************************************************************

// These globals exist purely for backwards compatibility with older versions
// of LogMessage. They aren't recommended.

/// Send only to the oPC who activated it (floating text) and the server log file
int LOG_FILE_PC              = LOG_TO_SERVER_LOG | LOG_PC;
/// Send only to the oPC who activated it (server message window) and the server log file
int LOG_FILE_PC_SERVER       = LOG_TO_SERVER_LOG | LOG_PC_SERVER;
/// Send to the oPC and all of their party members (floating text) and the server log file
int LOG_FILE_PARTY           = LOG_TO_SERVER_LOG | LOG_PARTY;
/// Send to the oPC and all of their party members (server message window) and the server log file
int LOG_FILE_PARTY_SERVER    = LOG_TO_SERVER_LOG | LOG_PARTY_SERVER;
/// Send to the oPC and their nearby (30m) faction members (floating text) and the server log file
int LOG_FILE_PARTY_30        = LOG_TO_SERVER_LOG | LOG_PARTY_30;
/// Send to the DM channel and the server log file
int LOG_FILE_DM_ALL          = LOG_TO_SERVER_LOG | LOG_DM_ALL;
/// Send to all DMs within distance 10m of oPC and the server log file
int LOG_FILE_DM_10           = LOG_TO_SERVER_LOG | LOG_DM_10;
/// Send to all DMs within distance 20m of oPC and the server log file
int LOG_FILE_DM_20           = LOG_TO_SERVER_LOG | LOG_DM_20;
/// Send to all DMs within distance 40m of oPC and the server log file
int LOG_FILE_DM_40           = LOG_TO_SERVER_LOG | LOG_DM_40;
/// Send to all DMs within distance 80m of oPC and the server log file
int LOG_FILE_DM_80           = LOG_TO_SERVER_LOG | LOG_DM_80;
/// Make oPC whisper the message (chat message window) and the server log file
int LOG_FILE_WHISPER         = LOG_TO_SERVER_LOG | LOG_WHISPER;
/// Make oPC talk the message (chat message window) and the server log file
int LOG_FILE_TALK            = LOG_TO_SERVER_LOG | LOG_TALK;
/// Make oPC shout the message (chat message window) and the server log file
int LOG_FILE_SHOUT           = LOG_TO_SERVER_LOG | LOG_SHOUT;

// ****************************************************************************
// ** CONSTANTS
// ****************************************************************************

// Set this to FALSE to include henchmen as part of the party for sending messages.
// Useful when trying to test MP messages when in SP.
const int LOG_MESSAGE_PARTY_PLAYERS_ONLY = TRUE;

// Set this to TRUE to debug how messages are being decoded.
const int LOG_MESSAGE_DEBUG = FALSE;

// Set this to TRUE to debug where messages are coming from.
const int LOG_MESSAGE_SOURCE_DEBUG = FALSE;

// This can be used to display which version of LogMessage you are using.
const string LOG_MESSAGE_VERSION = "LogMessage v1.06";

// ****************************************************************************
// ** FUNCTION DECLARATIONS
// ****************************************************************************

/**
 * This function is used to a log a message in several different ways depending
 * the value of iLogType.
 *
 * @param iLogType     This is the level of logging to use. It should be one of the
 *                     LOG_* constants.
 * @param oPC          This is the player who is triggering the log message.
 * @param sMessage     This is the message to be logged.
 * @param sDMMessage   This a message to be appended only for DM/log file messages.
 * @param sLocalFilter The message will only be sent to people who have
 *                     a LocalInt with this name and a specified value.
 * @param iLocalValue  The value the LocalInt must have.
 */
void LogMessage (int iLogType, object oPC, string sMessage, string sDMMessage = "", string sLocalFilter = "", int iLocalValue = 0);

/**
 *
 * This function is used to send a message to every player on the server using the
 * server message window.
 *
 * @param oPC          A member of the party to send the message to.
 * @param sMessage     The message to send.
 * @param sLocalFilter The message will only be sent to people who have
 *                     a LocalInt with this name and a specified value.
 * @param iLocalValue  The value the LocalInt must have.
 */
void SendMessageToAllPCs (string sMessage, string sLocalFilter = "", int iLocalValue = 0);

/**
 * This function is used to send a message to every player in a party using the
 * server message window.
 *
 * @param oPC              A member of the party to send the message to.
 * @param sMessage         The message to send.
 * @param bSkipOrigin      Skip the player who originated the message.
 * @param bPerceptionCheck If this is true, only send the message if the party member can see oPC.
 * @param sLocalFilter     The message will only be sent to people who have
 *                         a LocalInt with this name and a specified value.
 * @param iLocalValue      The value the LocalInt must have.
 */
void SendMessageToParty (object oPC, string sMessage, int bSkipOrigin = FALSE, int bPerceptionCheck = FALSE, string sLocalFilter = "", int iLocalValue = 0);

/**
 * This function is used to send a message to every player in a party using
 * floating text.
 *
 * @param oPC              A member of the party to send the message to.
 * @param sMessage         The message to send.
 * @param bPerceptionCheck If this is true, only send the message if the party member can see oPC.
 * @param sLocalFilter     The message will only be sent to people who have
 *                         a LocalInt with this name and a specified value.
 * @param iLocalValue      The value the LocalInt must have.
void FloatingTextStringOnParty (object oPC, string sMessage, int bPerceptionCheck = FALSE, string sLocalFilter = "", int iLocalValue = 0);

/**
 * This function is used to send a message to every player in a party using
 * floating text.
 *
 * @param oPC          A member of the party to send the message to.
 * @param iDistance    The maximum distance the party member can be from oPC.
 * @param sMessage     The message to send.
 * @param sLocalFilter The message will only be sent to people who have
 *                     a LocalInt with this name and a specified value.
 * @param iLocalValue  The value the LocalInt must have.
 */
void FloatingTextStringOnPartyByDistance (object oPC, int iDistance, string sMessage, string sLocalFilter = "", int iLocalValue = 0);

/**
 * This function is used to send a message to all of the DMs near a particular
 * location.
 *
 * @param lLocation    The center of the sphere to search for DMs.
 * @param iDistance    The maximum distance the DM can be from lLocation.
 * @param sMessage     The message to send.
 * @param bFloating    If TRUE, send as a floating text string, if FALSE, send as a server message.
 * @param sLocalFilter The message will only be sent to people who have
 *                     a LocalInt with this name and a specified value.
 * @param iLocalValue  The value the LocalInt must have.
 */
void SendMessageToDMsByDistance (location lLocation, int iDistance, string sMessage, int bFloating = TRUE, string sLocalFilter = "", int iLocalValue = 0);

// ****************************************************************************
// ** FUNCTION DEFINITIONS
// ****************************************************************************

void SendMessageToAllPCs (string sMessage, string sLocalFilter = "", int iLocalValue = 0)
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if ((sLocalFilter == "") ||
            (GetLocalInt(oPC, sLocalFilter) == iLocalValue))
        {
            // Check for DM possessed NPCs.
            if (!GetIsDM(GetMaster(oPC)))
                SendMessageToPC(oPC, sMessage);
        }
        oPC = GetNextPC();
    }
}

void SendMessageToParty (object oPC, string sMessage, int bSkipOrigin = FALSE, int bPerceptionCheck = FALSE, string sLocalFilter = "", int iLocalValue = 0)
{
    object oParty = GetFirstFactionMember(oPC, LOG_MESSAGE_PARTY_PLAYERS_ONLY);
    while ( GetIsObjectValid(oParty) )
    {
        if (
            // if filter is not set, or filter is true
            ((sLocalFilter == "") ||
            (GetLocalInt(oParty, sLocalFilter) == iLocalValue)) &&
            // if perception check not set, or perception is true
            ((bPerceptionCheck == FALSE) ||
            (GetObjectSeen(oPC, oParty) == TRUE)) &&
            // if bSkipOrigin is not set, or this is not the originating player
            ((bSkipOrigin == FALSE) ||
            (oPC != oParty))
            )
        {
            SendMessageToPC(oParty, sMessage);
        }
        oParty = GetNextFactionMember(oPC, LOG_MESSAGE_PARTY_PLAYERS_ONLY);
    }
    return;
}

void FloatingTextStringOnParty (object oPC, string sMessage, int bPerceptionCheck = FALSE, string sLocalFilter = "", int iLocalValue = 0)
{
    object oParty = GetFirstFactionMember(oPC, LOG_MESSAGE_PARTY_PLAYERS_ONLY);
    while ( GetIsObjectValid(oParty) )
    {
        if (
            // if filter is not set, or filter is true
            ((sLocalFilter == "") ||
            (GetLocalInt(oParty, sLocalFilter) == iLocalValue)) &&
            // if perception check not set, or perception is true
            ((bPerceptionCheck == FALSE) ||
            (GetObjectSeen(oPC, oParty) == TRUE))
            )        {
            FloatingTextStringOnCreature(sMessage, oParty, FALSE);
        }
        oParty = GetNextFactionMember(oPC, LOG_MESSAGE_PARTY_PLAYERS_ONLY);
    }
    return;
}


void FloatingTextStringOnPartyByDistance (object oPC, int iDistance, string sMessage, string sLocalFilter = "", int iLocalValue = 0)
{
    float fMaxDist = IntToFloat(iDistance);
    object oParty = GetFirstFactionMember(oPC, LOG_MESSAGE_PARTY_PLAYERS_ONLY);
    while ( GetIsObjectValid(oParty) )
    {
        float fDistance = GetDistanceBetween(oPC, oParty);
        if (
            // if filter is not set, or filter is true
            ( (sLocalFilter == "") ||
            (GetLocalInt(oParty, sLocalFilter) == iLocalValue) ) &&
            // Check that the party member is close enough to the player
            ( (oParty == oPC) ||
            ( (fDistance > 0.0) && (fDistance <= fMaxDist) ) )
            )
        {
            FloatingTextStringOnCreature(sMessage, oParty, FALSE);
        }
        oParty = GetNextFactionMember(oPC, LOG_MESSAGE_PARTY_PLAYERS_ONLY);
    }
}

void SendMessageToDMsByDistance (location lLocation, int iDistance, string sMessage, int bFloating = TRUE, string sLocalFilter = "", int iLocalValue = 0)
{
    object oDM;
    // If distance is zero, then send the message to all DMs on the server
    if (iDistance == 0)
    {
        oDM = GetFirstPC();
        while (GetIsObjectValid(oDM))
        {
            if ((sLocalFilter == "") ||
                (GetLocalInt(oDM, sLocalFilter) == iLocalValue))
            {
                // Note: DM possessed NPCs do not return TRUE for GetIsPC anymore.
                if ( GetIsDM(oDM) || GetIsDMPossessed(oDM) )
                {
                    if (bFloating) FloatingTextStringOnCreature(sMessage, oDM, FALSE);
                    else SendMessageToPC(oDM, sMessage);
                }
            }
            oDM = GetNextPC();
        }
        return;
    }
    // Normal operation
    float fSize = IntToFloat(iDistance);
    // Using ObjectInShape with CREATURE only catches DMs possessing NPCs but not DM avatars.
    oDM = GetFirstObjectInShape (SHAPE_SPHERE, fSize, lLocation, FALSE, OBJECT_TYPE_ALL);
    while ( GetIsObjectValid(oDM) )
    {
        if ((sLocalFilter == "") ||
            (GetLocalInt(oDM, sLocalFilter) == iLocalValue))
        {
            if ( GetIsDM(oDM) || GetIsDMPossessed(oDM) )
            {
                if (bFloating) FloatingTextStringOnCreature(sMessage, oDM, FALSE);
                else SendMessageToPC(oDM, sMessage);
            }
        }
        oDM = GetNextObjectInShape (SHAPE_SPHERE, fSize, lLocation, FALSE, OBJECT_TYPE_ALL);
    }
    return;
}

void LogMessage (int iLogType, object oPC, string sMessage, string sDMMessage = "", string sLocalFilter = "", int iLocalValue = 0)
{

    object oParty;
    object oArea;
    object oDM;
    int iDistance = 0;

    if (LOG_MESSAGE_SOURCE_DEBUG) SpeakString("Debug: "+GetName(OBJECT_SELF)+" in area: "+GetName(GetArea(OBJECT_SELF))+" is originating "+IntToHexString(iLogType)+" type log message: "+sMessage, TALKVOLUME_SHOUT);

    // Handle the various different types of log levels.

    // Messages that do not require oPC to be valid.
    if (iLogType & LOG_DISABLED)
        return;

    if (iLogType & LOG_PC_ALL)
    {
        if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PC_ALL");
        // Does not use the sLocalFilter because oPC does not have to
        // be valid.
        SendMessageToAllPCs(sMessage, sLocalFilter, iLocalValue);
    }

    if (iLogType & LOG_DM_ALL)
    {
        if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_ALL");
        // Does not use the sLocalFilter because oPC does not have to
        // be valid.
        SendMessageToAllDMs(sMessage + " " + sDMMessage);
    }

    if (iLogType & LOG_DM_ALL_SERVER)
    {
        if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_ALL_SERVER");
        // Does not use the sLocalFilter because oPC does not have to
        // be valid.
        SendMessageToDMsByDistance (GetLocation(OBJECT_SELF), 0, sMessage + " " + sDMMessage, FALSE, sLocalFilter, iLocalValue);
    }

    if (iLogType & LOG_TO_SERVER_LOG)
    {
        if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_TO_SERVER_LOG");
        // Does not use the sLocalFilter because oPC does not have to
        // be valid.
        PrintString(sMessage + " " + sDMMessage);
    }

    if (iLogType & LOG_TIME_SERVER_LOG)
    {
        if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_TIME_SERVER_LOG");
        // Does not use the sLocalFilter because oPC does not have to
        // be valid.
        WriteTimestampedLogEntry(sMessage + " " + sDMMessage);
    }

    // Messages that do require oPC to be valid.
    if (GetIsObjectValid(oPC))
    {
        if (iLogType & LOG_PC)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PC");
            if ((sLocalFilter == "") ||
                (GetLocalInt(oPC, sLocalFilter) == iLocalValue))
            {
                FloatingTextStringOnCreature(sMessage, oPC, FALSE);
            }
        }

        if (iLogType & LOG_PC_SERVER)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PC_SERVER");
            if ((sLocalFilter == "") ||
                (GetLocalInt(oPC, sLocalFilter) == iLocalValue))
            {
                SendMessageToPC(oPC, sMessage);
            }
        }

        if (iLogType & LOG_PARTY)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY");
            FloatingTextStringOnParty(oPC, sMessage, FALSE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_ONLY)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_ONLY");
            SendMessageToParty(oPC, sMessage, TRUE, FALSE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_10)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_10");
            FloatingTextStringOnPartyByDistance(oPC, 10, sMessage, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_20)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_20");
            FloatingTextStringOnPartyByDistance(oPC, 20, sMessage, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_40)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_40");
            FloatingTextStringOnPartyByDistance(oPC, 40, sMessage, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_80)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_80");
            FloatingTextStringOnPartyByDistance(oPC, 80, sMessage, sLocalFilter, iLocalValue);
        }


        if (iLogType & LOG_PARTY_SERVER)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_SERVER");
            SendMessageToParty(oPC, sMessage, FALSE, FALSE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_PERC)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_PERC");
            FloatingTextStringOnParty(oPC, sMessage, TRUE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_PERC_ONLY)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_ONLY_PERC");
            SendMessageToParty(oPC, sMessage, TRUE, TRUE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_PERC_SERVER)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_PERC_SERVER");
            SendMessageToParty(oPC, sMessage, FALSE, TRUE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_PARTY_30)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_PARTY_30");
            // Note: does not use sLocalFilter
            FloatingTextStringOnCreature(sMessage, oPC, TRUE);
        }

        if (iLogType & LOG_DM_10)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_10");
            SendMessageToDMsByDistance(GetLocation(oPC), 10, sMessage + " " + sDMMessage, TRUE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_DM_20)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_20");
            SendMessageToDMsByDistance(GetLocation(oPC), 20, sMessage + " " + sDMMessage, TRUE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_DM_40)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_40");
            SendMessageToDMsByDistance(GetLocation(oPC), 40, sMessage + " " + sDMMessage, TRUE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_DM_80)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_80");
            SendMessageToDMsByDistance(GetLocation(oPC), 80, sMessage + " " + sDMMessage, TRUE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_DM_10_SERVER)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_10_SERVER");
            SendMessageToDMsByDistance(GetLocation(oPC), 10, sMessage + " " + sDMMessage, FALSE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_DM_20_SERVER)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_20_SERVER");
            SendMessageToDMsByDistance(GetLocation(oPC), 20, sMessage + " " + sDMMessage, FALSE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_DM_40_SERVER)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_40_SERVER");
            SendMessageToDMsByDistance(GetLocation(oPC), 40, sMessage + " " + sDMMessage, FALSE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_DM_80_SERVER)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_DM_80_SERVER");
            SendMessageToDMsByDistance(GetLocation(oPC), 80, sMessage + " " + sDMMessage, FALSE, sLocalFilter, iLocalValue);
        }

        if (iLogType & LOG_WHISPER)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_WHISPER");
            if ((sLocalFilter == "") ||
                (GetLocalInt(oPC, sLocalFilter) == iLocalValue))
            {
                AssignCommand(oPC, ActionSpeakString(sMessage, TALKVOLUME_WHISPER));
            }
        }

        if (iLogType & LOG_TALK)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_TALK");
            if ((sLocalFilter == "") ||
                (GetLocalInt(oPC, sLocalFilter) == iLocalValue))
            {
                AssignCommand(oPC, ActionSpeakString(sMessage, TALKVOLUME_TALK));
            }
        }

        if (iLogType & LOG_SHOUT)
        {
            if (LOG_MESSAGE_DEBUG) SendMessageToPC(oPC, "LOG_SHOUT");
            if ((sLocalFilter == "") ||
                (GetLocalInt(oPC, sLocalFilter) == iLocalValue))
            {
                AssignCommand(oPC, ActionSpeakString(sMessage, TALKVOLUME_SHOUT));
            }
        }
    }
    return;
}

