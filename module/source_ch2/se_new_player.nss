//::////////////////////////////////////////////////////////////////////////////
//:: Name      - Simple New Player Setup v1.5
//:: File Name - se_new_player
//:: File Type - include
//:: Copyright (c) 2006 Melnibone Corp.
//::////////////////////////////////////////////////////////////////////////////
#include "sql_campaign"
/*

   IMPORTANT NOTE - This is an include file so will not compile like a normal,
   script. If you change any settings firstly save this script via (Ctrl+S) then,
   you MUST also save your module OnClientEnter script otherwise any changes you,
   made in this script will not take effect.


   DESCRIPTION OF THIS PACKAGE: Sets up new player characters ie.

   1) Set starting level

   2) Remove inventory

   3) Remove inventory slots

   4) Remove gold

   5) Give starting gear

   6) Give starting gold


   APPLICATION:

   Step(1): Use the example script in this package, "on_client_enter", as your
            module OnClientEnter script or you will need to add a few things
            to your current OnClientEnter script.
            If it's the latter you will need to do the following steps:

               a) Add #include "se_new_player" at the very top of your current,
                  OnClientEnter script.

               b) Add this function SirElrics_SimplePlayerSetUp(oPC); at the top
                  of your current OnClientEnter script inside the void main()
                  parenthesis

   Step(2): Change the settings below to suit your module.

   Step(3): Save this script (Ctrl+S)

   Step(4): Save and compile your OnClientEnter script (F7)

*/
//::////////////////////////////////////////////////////////////////////////////
//:: Created By : Sir Elric
//:: Created On : 25th June, 2005
//:: Modified On: 1st January, 2007
//::////////////////////////////////////////////////////////////////////////////

/************************************************************************************/
/******************  ADJUST SETTINGS BELOW TO SUIT YOUR MODULE   ********************/
/************************************************************************************/

string sWelcomeMsg = "Welcome to the Realms of Shargast!"; // Add your module welcome message here

int nWhichPlayers = 1;      // 0 Turns ALL settings off!
                            // 1 New players only(ie: Only characters with 0xp).
                            // 2 New players lower than nStartingLevel(below) only.
                            // 3 All players once only(saves to database)PW Style

int nStartingLevel = 1;     // What level should players start on 1 - 40?

int nStripAllItems = TRUE;  // Strip all items in players inventory TRUE or FALSE?
int nStripAllSlots = TRUE;  // Strip all items in players slots TRUE or FALSE?
int nStripAllGold  = TRUE;  // Strip all gold from player TRUE or FALSE?
int nStartingGold  =  500;  // Give new player starting gold? - 0 is off

int nStartingGear  = TRUE;  // Give new player starting gear TRUE or FALSE?
                            // If TRUE add ResRef between the quotes below(not tag),
                            // plus stack size,if applicable.
                            // Use sClothing for starting clothing & it will be equipped
                            // eg. string sResRef = "potion";  int nStack  = 6;
                            string sClothing  = "nw_it_recall";  int nStack  = 1;
                            string sResRef1 = "rosbook";  int nStack1 = 1;
                            string sResRef2 = "NoviceRobe_1";  int nStack2 = 1;
                            string sResRef3 = "se_on_activate";  int nStack3 = 1;
                            string sResRef4 = "elfishstoneofrec";  int nStack4 = 1;

/************************************************************************************/
/**************************     END OF SETTINGS    **********************************/
/************************************************************************************/

// -----------------------------------------------------------------------------
//  PROTOTYPES
// -----------------------------------------------------------------------------

// Returns Experience min for level given
int GetXPByLevel(int iLevel);

//Set up new players on enter of your module
void SirElrics_SimplePlayerSetUp(object oPC);


// -----------------------------------------------------------------------------
//  FUNCTIONS
// -----------------------------------------------------------------------------

int GetXPByLevel(int iLevel)
{
    int nXP = (((iLevel - 1) * iLevel) / 2) * 1000;
    return nXP;
}

void SirElrics_SimplePlayerSetUp(object oPC)
{
    if(!GetIsPC(oPC) || GetIsDM(oPC)) return;

    if(GetLocalInt(oPC, "SE_ENTERED")) return;

    object oMod = GetModule();
    int i;
    object oItem;

    if(GetLocalInt(oMod, "INITIATE_VARIABLES") == FALSE)
    {
       SetLocalInt(oMod, "STRIP_ALL_ITEMS", nStripAllItems);
       SetLocalInt(oMod, "STRIP_ALL_SLOTS", nStripAllSlots);
       SetLocalInt(oMod, "STRIP_ALL_GOLD", nStripAllGold);
       SetLocalInt(oMod, "GIVE_STARTING_GOLD", nStartingGold);
       SetLocalInt(oMod, "WHICH_PLAYERS", nWhichPlayers);
       SetLocalInt(oMod, "STARTING_GEAR", nStartingGear);
       SetLocalInt(oMod, "STARTING_LEVEL", nStartingLevel);
       SetLocalInt(oMod, "INITIATE_VARIABLES", TRUE);
    }

    if(GetLocalInt(oMod, "WHICH_PLAYERS") == 1 && !GetLocalInt(oPC, "SE_ENTERED"))
    {
       if(GetXP(oPC) > 0) return;
       DelayCommand(0.5, GiveXPToCreature(oPC, 1));
       SetLocalInt(oPC, "SE_ENTERED", 1);
    }
    else if(GetLocalInt(oMod, "WHICH_PLAYERS") == 2 && !GetLocalInt(oPC, "SE_ENTERED"))
    {
       if(GetHitDice(oPC)>= nStartingLevel) return;
       SetLocalInt(oPC, "SE_ENTERED", 1);
    }
    else if(GetLocalInt(oMod, "WHICH_PLAYERS") == 3)
    {
       if(SQL_GetCampaignInt("New_Player_Setup", GetName(oPC), oPC)) return;
       SQL_SetCampaignInt("New_Player_Setup", GetName(oPC), 1, oPC);
       SetLocalInt(oPC, "SE_ENTERED", 1);
    }
    else
    {
       SendMessageToAllDMs("Simple New Player Setup v1.5 is switched off!");
       SetLocalInt(oPC, "SE_ENTERED", 1);
       return;
    }

    if(GetLocalInt(oMod, "STARTING_LEVEL"))
    {
      int nCurrentXP = GetXP(oPC);
      int nGetXP     = GetXPByLevel(nStartingLevel);
      int nNewXP     = nGetXP - nCurrentXP;
      if(nCurrentXP < nGetXP)
         GiveXPToCreature(oPC, nNewXP);
      else
         SetXP(oPC, nGetXP);
      SendMessageToPC(oPC, sWelcomeMsg);
      SendMessageToPC(oPC, "Levelling you to (" + IntToString(nStartingLevel)+ ")");
    }

    if(GetLocalInt(oMod, "STRIP_ALL_GOLD"))
       AssignCommand(oPC, TakeGoldFromCreature(GetGold(oPC), oPC, TRUE));

    if(GetLocalInt(oMod, "GIVE_STARTING_GOLD"))
       AssignCommand(oPC, GiveGoldToCreature(oPC, nStartingGold));

    if(GetLocalInt(oMod, "STRIP_ALL_SLOTS"))
    {
       for(i=0; i < NUM_INVENTORY_SLOTS; i++)
       {
           oItem = GetItemInSlot(i, oPC);
           if(GetIsObjectValid(oItem))
           {
              SetPlotFlag(oItem, FALSE);
              SetItemCursedFlag(oItem, FALSE);
              DestroyObject(oItem);
           }
       }
    }

    if(GetLocalInt(oMod, "STRIP_ALL_ITEMS"))
    {
       oItem = GetFirstItemInInventory(oPC);
       while(GetIsObjectValid(oItem))
       {
           SetPlotFlag(oItem, FALSE);
           SetItemCursedFlag(oItem, FALSE);
           DestroyObject(oItem);
           oItem = GetNextItemInInventory(oPC);
       }
    }

    if(GetLocalInt(oMod, "STARTING_GEAR"))
    {
       object oClothing = CreateItemOnObject(sClothing, oPC, nStack);
       DelayCommand(2.0, AssignCommand(oPC, ActionEquipItem(oClothing, INVENTORY_SLOT_CHEST)));
       CreateItemOnObject(sResRef1, oPC, nStack1);
       CreateItemOnObject(sResRef2, oPC, nStack2);
       CreateItemOnObject(sResRef3, oPC, nStack3);
       CreateItemOnObject(sResRef4, oPC, nStack4);
    }
}
//void main(){}
