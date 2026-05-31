// ScrewTape's OnPlayerDeath - original from LazyBones
#include "nw_i0_tool"

const float ROUND = 6.0f;

// Added INSTANT_RESPAWN constant - set to TRUE to bypass delay
const int INSTANT_RESPAWN = FALSE;

void CheckContents(object oBackPack);
void CheckForCombat(object oPlayer);
void ShowDeathGUI(object oPlayer);
void main()
{
   //Set variables
   object   oDead      = GetLastPlayerDied();
   object   oItem      = GetFirstItemInInventory(oDead);
   location lDied      = GetLocation(oDead);
   int      nTimesDied = GetLocalInt(oDead, "PLAYER_DIED");
   float    fDelay     = ROUND + (ROUND * nTimesDied);
   object   oBackPack;
   int      bHasItem   = FALSE;

   // Put all general inventory items in a loot back pack
   if (GetIsObjectValid(oItem))
   {
      // Create a loot back pack
      oBackPack = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_lootbag6", lDied);
      // Place all general inventory items in the back pack
      while (GetIsObjectValid(oItem))
      {
         AssignCommand(oBackPack, ActionTakeItem(oItem, oDead));
         oItem = GetNextItemInInventory(oDead);
         bHasItem = TRUE;
      }
   }

   // If the player had at least one item put in the backpack
   if (bHasItem)
   {
      // check the contents and destroy the backpack when empty
      DelayCommand(30.0f, CheckContents(oBackPack));
   }
   else // no contents, destroy now
      DestroyObject(oBackPack, 0.5f);

   // * increment global tracking number of times that I died
   nTimesDied++;
   SetLocalInt(oDead, "PLAYER_DIED", nTimesDied );
   if (nTimesDied > 1)
      SendMessageToPC(oDead, "You have died " + IntToString(nTimesDied) + " times.");
   else
      SendMessageToPC(oDead, "You have died once.");

   // * make friendly to Each of the 3 common factions and hostile to hostile
   AssignCommand(oDead, ClearAllActions());

   if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER, oDead) <= 10)
      SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 80, oDead);

   if (GetStandardFactionReputation(STANDARD_FACTION_MERCHANT, oDead) <= 10)
      SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 80, oDead);

   if (GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, oDead) <= 10)
      SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 80, oDead);

   if (GetStandardFactionReputation(STANDARD_FACTION_HOSTILE, oDead) > 10)
      SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 0, oDead);

   // No respawning during combat... unless we have a TPK
   //  This is a recursive function call... be careful with edits
   // Added INSTANT_RESPAWN constant - set to TRUE above to bypass delay
   if (INSTANT_RESPAWN)
      DelayCommand(1.0f,ShowDeathGUI(oDead));
   else
      DelayCommand( fDelay, CheckForCombat( oDead ));

}

////////////////////////////////////////////////////////////////////////////////
// CheckContents
//  check the contents and destroy the backpack when empty
void CheckContents(object oBackPack)
{
   object oItem = GetFirstItemInInventory(oBackPack);

   if (GetIsObjectValid(oItem))
      DelayCommand((ROUND * 5.0f), CheckContents(oBackPack));
   else
      DestroyObject(oBackPack, 0.5f);
}

////////////////////////////////////////////////////////////////////////////////
// CheckForCombat
//  Only show the respawn menu when the rest of the players are out of combat
//   that is, no respawning to help them win the fight I just got killed in
//   also, will display respawn menu if all are dead
void CheckForCombat(object oPlayer)
{
   int bAnyOneAlive = FALSE;
   int bInCombat = FALSE;

   object oMember = GetFirstFactionMember(oPlayer);
   while (oMember != OBJECT_INVALID)
   {
      if (oMember != oPlayer)
      {
         if (!bAnyOneAlive && GetCurrentHitPoints(oMember) > 0)
            bAnyOneAlive = TRUE;

         if (GetIsInCombat(oMember))
            bInCombat = TRUE;
      }
      oMember = GetNextFactionMember(oMember);
   }

   // Make 'em wait if any are alive and in combat
   if (bAnyOneAlive && bInCombat)
   {
      // Make sure player is still logged in
      if (GetPCPlayerName(oPlayer) != "")
      {
         SendMessageToPC(oPlayer, "You may not respawn until your party is not in combat.");
         DelayCommand( ROUND, CheckForCombat(oPlayer)); // Delayed recursion
      }
   }

   else // give 'em the gui
      DelayCommand(ROUND, ShowDeathGUI(oPlayer));
}

////////////////////////////////////////////////////////////////////////////////
// ShowDeathGUI
//  we don't want to display the gui if someone raised the player during the
//   delay getting here
void ShowDeathGUI(object oPlayer)
{
   if (GetCurrentHitPoints(oPlayer) < 1)
      PopUpGUIPanel(oPlayer, GUI_PANEL_PLAYER_DEATH);
}
