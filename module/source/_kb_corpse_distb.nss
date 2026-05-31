////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
//  _kb_corpse_distb                                //      VERSION 3.3       //
//                                                  //                        //
//  by Scrotok on 9 Feb 03                          ////////////////////////////
//  Thanks to Keron Blackfeld for 99% of the work!                            //
//  email Questions and Comments to: jnbplatte@intellisys.net                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  CAUTION: You MUST re-save/compile (or press F7 for "Save and Compile")    //
//  the "_kb_corpse_death" and "_kb_corpse_distb" scripts if you make any     //
//  changes to "_kb_inc_invmgmt" (for programmers only: because it is an      //
//  #include file).                                                           //
//                                                                            //
//  NEWBIES: You don't need to place this script anywhere -- it's already     //
//  taken care of for you.                                                    //
//                                                                            //
//  NOTE: If you were using the old "_kb_ohb_lootable", be sure to delete     //
//  that script, and remove it from the OnHeartbeat of your lootable corpse   //
//  placeable (tag "invis_corpse_obj").  This only applies if you have an OLD //
//  version of Keron's lootable corpses script.                               //
//                                                                            //
//  This script works in conjunction with the "_kb_loot_corpse" script.  The  //
//  OnDisturbed event of the lootable corpse placeable (tag                   //
//  "invis_corpse_obj") contains this script.  This script checks the         //
//  inventory of OBJECT_SELF, and when it is empty (and dropped weapons have  //
//  been claimed), it checks a LocalInt to see if the now-empty corpse should //
//  be destroyed along with the lootable corpse placeable.  Plot items are    //
//  not destroyed.  If nKeepWeaponsEmpty is TRUE, empties will be destroyed   //
//  even if dropped weapons/shields/torches are unclaimed.                    //
//                                                                            //
//  If the inventory is NOT empty, this script will also check to see if the  //
//  lootable armour (oLootArmour) was removed; if so, it destroys the         //
//  original armour (oOrigArmour) on the corpse.  A similar check is made for //
//  oLootHelmet and oOrigHelmet.                                              //
//                                                                            //
//  The "_kb_loot_corpse" script must have this line:                         //
//  int nKeepEmpties = FALSE;                                                 //
//  in order for the empty corpse to destroy itself in this script.           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/*  Version 3.3 Change Log:
    - fixed comments to clarify that "doa_lootnotify" script refers to DOA's "Party Loot Notification" plugin
/*  Version 3.2 Change Log:
    - renamed script from "_kb_ondist_loot" to "_kb_corpse_distb" for naming consistency
    - consolidated inventory management functions to _kb_inc_invmgmt
    - ClearInventory function calls changed to DestroyInventory in _kb_inc_invmgmt (identical)
    - get low animation moved to end of script (see DEFAULT BEHAVIOR)
    - added simple plugin architecture (requires file _kb_plugins)
    - integration with DOA's "Party Loot Notification" plugin ("doa_lootnotify") now requires zero editing (no include call)
    - added GetIsObjectValid check before destroying Bloodspot
    - changed comments to clarify weapons/shields/torches are affected by "weapons" parameters/functions
    - renamed oHostCorpse to oHostBody for consistency
    - added check for oLootHelmet and oOrigHelmet
*/

#include "_kb_inc_invmgmt"

/*********************************************************************
 ** This function checks to see if our corpse's discarded weapons   **
 ** have been picked up. If so, it returns TRUE.  Returns TRUE if   **
 ** no weapons have been dropped.  Returns TRUE if any weapon is    **
 ** unclaimed but nKeepWeaponsEmpty is set to TRUE.                 **
 **                                                                 **
 ** NOTE: Shields/torches are also considered "weapons" for the     **
 ** purposes of this script.                                        **
 *********************************************************************/
int CheckWeapons(object oCorpse)
{
    //Check to see if anyone possesses the Left Weapon
    object oLeftWpn = GetLocalObject(oCorpse, "oLeftWpn");
    object oLeftTest = GetItemPossessor(oLeftWpn);
    //Check to see if anyone possesses the Right Weapon
    object oRightWpn = GetLocalObject(oCorpse, "oRightWpn");
    object oRightTest = GetItemPossessor(oRightWpn);
    if (oLeftWpn == OBJECT_INVALID && oRightWpn == OBJECT_INVALID)
     {
        // No weapons have been dropped
        return TRUE;
     }
    else
     {
        if (oLeftTest != OBJECT_INVALID && oRightTest != OBJECT_INVALID)
         {
            // All dropped weapons have been claimed
            return TRUE;
         }
        else
         {
            if (GetLocalInt(oCorpse, "nKeepWeaponsEmpty"))
             {
                // One or both dropped weapons are unclaimed, but nKeepWeaponsEmpty == TRUE
                return TRUE;
             }
            else
             {
                return FALSE;
             }
         }
     }
}

/*********************************************************************
 ** Here is our main script, which is fired if the Inventory is     **
 ** disturbed.  It then checks to see if it needs to either clean   **
 ** up the corpse, destroy the original suit of armour still on     **
 ** the corpse, or destroy the original helmet still on the corpse. **
 *********************************************************************/
void main()
{
   /* Register Plugins */
   if (!GetLocalInt(GetModule(),"kb_lootcorpse_plugins"))
      ExecuteScript("_kb_plugins", OBJECT_SELF);

   //Get all of our required information
   object oInvDisturbed = GetInventoryDisturbItem(); //Get item that was disturbed to trigger event
   int nInvDistType = GetInventoryDisturbType(); //Get type of inventory disturbance
   object oHostBody = GetLocalObject(OBJECT_SELF, "oHostBody"); //Get Value set by _kb_loot_corpse at creation
   object oCorpseBlood = GetLocalObject(OBJECT_SELF, "oBloodSpot"); //Get Value set by _kb_loot_corpse at creation

   object oOrigArmour = GetLocalObject(OBJECT_SELF, "oOrigArmour"); //Get Value set by _kb_loot_corpse at creation
   object oLootArmour = GetLocalObject(OBJECT_SELF, "oLootArmour"); //Get Value set by _kb_loot_corpse at creation

   object oOrigHelmet = GetLocalObject(OBJECT_SELF, "oOrigHelmet"); //Get Value set by _kb_loot_corpse at creation
   object oLootHelmet = GetLocalObject(OBJECT_SELF, "oLootHelmet"); //Get Value set by _kb_loot_corpse at creation

   object oPC = GetLastDisturbed();

   object oHasInventory = GetFirstItemInInventory(OBJECT_SELF); //Check for inventory
   if (oHasInventory == OBJECT_INVALID && CheckWeapons(OBJECT_SELF)) //If no inventory found and Weapons have been claimed
    {
       /*******************************************
        ** Inventory is empty. Now we check the  **
        ** nKeepEmpty value.                     **
        *******************************************/
       int nKeepEmpty = GetLocalInt(OBJECT_SELF, "nKeepEmpty"); //Get Value set by _kb_loot_corpse at creation
       if (!nKeepEmpty)
        {
           /*******************************************
            ** nKeepEmpty is FALSE. Delete empty.    **
            *******************************************/

           //Delete the BloodSpot (if created)
           if (GetIsObjectValid(oCorpseBlood))
            {
               DestroyObject(oCorpseBlood);
            }
           // Empty and delete actual creature corpse (body)
           DestroyInventory(oHostBody);
           AssignCommand(oHostBody, SetIsDestroyable(TRUE,FALSE,FALSE));
           DestroyObject(oHostBody);
           // Empty and delete lootable corpse object (self)
           DelayCommand(1.0f, DestroyObject(OBJECT_SELF));
        }
    }

   //Check to see if the Armour has been taken
   if (oInvDisturbed == oLootArmour && nInvDistType == INVENTORY_DISTURB_TYPE_REMOVED)
    {
       /*******************************************
        ** The Armour is gone - destroy original **
        ** armour still showing on corpse.       **
        *******************************************/
       DestroyObject(oOrigArmour);
    }

   //Check to see if the Helmet has been taken
   if (oInvDisturbed == oLootHelmet && nInvDistType == INVENTORY_DISTURB_TYPE_REMOVED)
    {
       /*******************************************
        ** The Helmet is gone - destroy original **
        ** helmet still showing on corpse.       **
        *******************************************/
       DestroyObject(oOrigHelmet);
    }

// PLUGIN BEHAVIOR
   if (GetLocalInt(GetModule(),"doa_lootnotify"))
    {
       ExecuteScript("doa_lootnotify", OBJECT_SELF);
    }
   else
    {
// DEFAULT BEHAVIOR if plugin not installed
       AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0f, 1.2f));
    }
}
