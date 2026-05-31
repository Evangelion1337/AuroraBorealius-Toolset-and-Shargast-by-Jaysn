//::///////////////////////////////////////////////
//:: Persistent Quests & Journal Entries / Beta
//:: pqj_inc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
#include "sql_campaign"
/*

   Persistent Quests and Journal Entries

   This is a compact set of scripts (4 public functions, 2 private functions) to help you get
   a persistent journal and to generally manage quests without much overhead.

   it works like this:

   you prepare your journal in the toolbox, assigning proper tags/ids, then you normally use
   AddJournalQuestEntry() and RemoveJournalQuestEntry() to manage them via scripting.

   now, you just have to use AddPersistentJournalQuestEntry() and RemovePersistentJournalQuestEntry()
   with exact the same parameters (bAllPlayer, bAllPartyMembers and bAllowOverrideHigher still work like
   in the original bioware functions).  this means no restrictions, it's fully transparent.

   now add the following line of code to your Module OnClientEnter script (don't forget to include this script):
      RebuildJournalQuestEntries(GetEnteringObject());

   that's all, now you have a persistent journal... you can basically use CTRL-R to find/replace the
   original functions with the persistent ones and add the OnClientEnter code.

   furthermore, you can use RetrieveQuestState() to get the current state of a
   quest for the specified player/quest-tag. this means you can manage your conversations with
   this function and control quest-flow. you won't need to store additional LocalInts somewhere, just
   use the DB information.

   technical blabla:

   minimized DB usage: stores all quest states in a single string

   i'm using a combo of tokenized + padded string to get maximum parsing efficiency.
   tokenized: i can find & change a single quest entry with only a few string commands
   padded: i can browse through a large string (100+ quest entries) with minimal need of string manipulation
   so this won't slow down your server during journal rebuilds even with tons of quests

   this is beta code and pretty much un-optimized ..still needs some bug hunting

*/
//:://////////////////////////////////////////////
//:: Created By: Knat
//:: Created On: 19.06.2003
//:://////////////////////////////////////////////

// database filename
const string PQJ_DATABASE       = "JOURNALS";
// database fieldname
const string PQJ_PLAYER_VARNAME = "QUESTJOURNAL";

// transparent wrapper to AddJournalQuestEntry
// use this function instead of the original one to store quest/journal data
// persistently using the bio DB. all function parameters work similar to the original function
//
// Add a journal quest entry to oCreature.
// - szPlotID: the plot identifier used in the toolset's Journal Editor
// - nState: the state of the plot as seen in the toolset's Journal Editor
// - oCreature
// - bAllPartyMembers: If this is TRUE, the entry will show up in the journal of
//   everyone in the party
// - bAllPlayers: If this is TRUE, the entry will show up in the journal of
//   everyone in the world
// - bAllowOverrideHigher: If this is TRUE, you can set the state to a lower
//   number than the one it is currently on
void AddPersistentJournalQuestEntry(string szPlotID, int nState, object oCreature, int bAllPartyMembers=TRUE, int bAllPlayers=FALSE, int bAllowOverrideHigher=FALSE);

// transparent wrapper to RemoveJournalQuestEntry()
// use this function instead of the original one to remove quest/journal data
// persistently using the bio DB. all function parameters work similar to the original function
//
// Remove a journal quest entry from oCreature.
// - szPlotID: the plot identifier used in the toolset's Journal Editor
// - oCreature
// - bAllPartyMembers: If this is TRUE, the entry will be removed from the
//   journal of everyone in the party
// - bAllPlayers: If this is TRUE, the entry will be removed from the journal of
//   everyone in the world
void RemovePersistentJournalQuestEntry(string szPlotID, object oCreature, int bAllPartyMembers=TRUE, int bAllPlayers=FALSE);

// use this function to rebuild the journal on oCreature using the bio DB
// a good place is the Module OnClientEnter() event
void RebuildJournalQuestEntries(object oCreature);

// retrieve persistent quest state from the DB
// - szPlotID: the plot identifier used in the toolset's Journal Editor
int RetrieveQuestState(string szPlotID, object oCreature);

// -----------------------------------------------------------------------------

void RebuildJournalQuestEntries(object oCreature)
{
  if(GetIsPC(oCreature))
  {
    string sEntries = SQL_GetCampaignString(PQJ_DATABASE,PQJ_PLAYER_VARNAME,oCreature);
    int i, nCount = GetStringLength(sEntries) / 44;

    string sQuest;
    for(i=0;i < nCount;i++)
    {
      // get quest
      sQuest = GetSubString(sEntries,(i*44),32);
      // remove padding
      sQuest = GetStringLeft(sQuest, FindSubString(sQuest, " "));
      // add journal entry
      AddJournalQuestEntry(sQuest, StringToInt(GetSubString(sEntries,(i*44) + 33,8)), oCreature, FALSE, FALSE, TRUE);
    }
  }
}

int RetrieveQuestState(string szPlotID, object oCreature)
{
  // retrieve all quest entries
  string sEntries = SQL_GetCampaignString(PQJ_DATABASE,PQJ_PLAYER_VARNAME,oCreature);
  // get quest we search for and add padding
  string sQuest = (GetStringLength(szPlotID) < 32) ? szPlotID + GetStringLeft("                              ",32 - GetStringLength(szPlotID)) : GetStringLeft(szPlotID,32);

  // find target quest
  int nPos = FindSubString(sEntries, sQuest + ">");

  if( nPos != -1) // success ?? get & return value
    return StringToInt(GetStringLeft(GetStringRight(sEntries,GetStringLength(sEntries)-nPos-GetStringLength(sQuest)-1),10));

  // quest not started yet
  return 0;
}

void StoreQuestEntry(string szPlotID, int nState, object oCreature, int bAllowOverrideHigher=FALSE)
{
  // retrieve all quest entries
  string sEntries = SQL_GetCampaignString(PQJ_DATABASE,PQJ_PLAYER_VARNAME,oCreature);

  // pad quest
  string sQuest = (GetStringLength(szPlotID) < 32) ? szPlotID + GetStringLeft("                              ",32 - GetStringLength(szPlotID)) : GetStringLeft(szPlotID,32);
  // pad state
  string sState = IntToString(nState);
  sState = (GetStringLength(sState) < 10) ? sState + GetStringLeft("          ",10 - GetStringLength(sState)) : GetStringLeft(sState,10);

  // find target quest
  int nPos = FindSubString(sEntries, sQuest + ">");

  if( nPos != -1) // success ?
  {

    // check for override flag
    if(!bAllowOverrideHigher) // new state < old state ? return
      if(nState < StringToInt(GetStringRight(sEntries,GetStringLength(sEntries)-nPos-GetStringLength(sQuest)-1)))
        return;

    // replace old quest state with new one
    string sL = GetStringLeft(sEntries, nPos + GetStringLength(sQuest) + 1);
    sEntries = sL + sState + GetStringRight(sEntries, GetStringLength(sEntries) - GetStringLength(sL) - 10);
  }
  else // add quest
    sEntries += sQuest + ">" + sState + "|";

  // store quest entries
  SQL_SetCampaignString(PQJ_DATABASE,PQJ_PLAYER_VARNAME,sEntries,oCreature);
}

void DeleteQuestEntry(string szPlotID, object oCreature)
{
  // retrieve all quest entries
  string sEntries = SQL_GetCampaignString(PQJ_DATABASE,PQJ_PLAYER_VARNAME,oCreature);
  // pad quest
  string sQuest = (GetStringLength(szPlotID) < 32) ? szPlotID + GetStringLeft("                              ",32 - GetStringLength(szPlotID)) : GetStringLeft(szPlotID,32);
  // find target quest
  int nPos = FindSubString(sEntries, sQuest + ">");

  if( nPos != -1) // success ?
  {

    // replace old quest state with new one
    string sL = GetStringLeft(sEntries, nPos);
    sEntries = sL + GetStringRight(sEntries, GetStringLength(sEntries) - GetStringLength(sL) - 44);

    // store quest entries
    SQL_SetCampaignString(PQJ_DATABASE,PQJ_PLAYER_VARNAME,sEntries,oCreature);
  }

}

void RemovePersistentJournalQuestEntry(string szPlotID, object oCreature, int bAllPartyMembers=TRUE, int bAllPlayers=FALSE)
{
  RemoveJournalQuestEntry(szPlotID, oCreature, bAllPartyMembers, bAllPlayers);
  // store data
  if(bAllPlayers)
  {
    // all players
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
      if(GetIsPC(oPC))   DeleteQuestEntry(szPlotID, oPC);
      oPC = GetNextPC();
    }
  }
  else if(bAllPartyMembers)
  {
    // whole group
    object oPartyMember = GetFirstFactionMember(oCreature, TRUE);
    while (GetIsObjectValid(oPartyMember))
    {
      DeleteQuestEntry(szPlotID, oPartyMember);
      oPartyMember = GetNextFactionMember(oCreature, TRUE);
    }
  }
  else
  {
    // player only
    DeleteQuestEntry(szPlotID, oCreature);
  }
}

void AddPersistentJournalQuestEntry(string szPlotID, int nState, object oCreature, int bAllPartyMembers=TRUE, int bAllPlayers=FALSE, int bAllowOverrideHigher=FALSE)
{
  AddJournalQuestEntry(szPlotID, nState, oCreature, bAllPartyMembers, bAllPlayers, bAllowOverrideHigher);
  // store data
  if(bAllPlayers)
  {
    // all players
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
      if(GetIsPC(oPC)) StoreQuestEntry(szPlotID, nState, oPC, bAllowOverrideHigher);
      oPC = GetNextPC();
    }
  }
  else if(bAllPartyMembers)
  {
    //SendMessageToPC(oCreature, "PARTY");
    object oPartyMember = GetFirstFactionMember(oCreature, TRUE);
    while (GetIsObjectValid(oPartyMember))
    {
      StoreQuestEntry(szPlotID, nState, oPartyMember, bAllowOverrideHigher);
      oPartyMember = GetNextFactionMember(oCreature, TRUE);
    }
  }
  else
  {
    StoreQuestEntry(szPlotID, nState, oCreature, bAllowOverrideHigher);
  }
}
