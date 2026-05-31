////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
//  _kb_inc_invmgmt (include file)                  //      VERSION 3.3       //
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
//  CAUTION: You MUST re-save (not the F7 key!) "_kb_loot_corpse" if you make //
//  any changes to "_kb_inc_invmgmt" (for programmers only: because it is an  //
//  #include file).  To re-save it, make a change to the script, then UNDO    //
//  the change, then re-save.                                                 //
//                                                                            //
//  NEWBIES: You don't need to place this script anywhere -- it's already     //
//  taken care of for you.                                                    //
//                                                                            //
//  This script works in conjunction with the "_kb_loot_corpse" script.  It   //
//  contains common functions used in "_kb_corpse_death", "_kb_corpse_distb", //
//  and "_kb_loot_corpse".                                                    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/*  Version 3.2 Change Log:
    - ClearInventory was 99% the same as DestroyInventory except for the
      dropped weapons, so they were consolidated.
    - DestroyInventory rewritten to use equipped item integers in a loop.
    - DestroyDroppedWeapons is a new function which does only that.
    - added TransferToBones function to move lootable corpse placeable inventory to bones
    - added BonesCleanup function to get rid of the bones after nBonesFade
    - changed comments to clarify weapons/shields/torches are affected by "weapons" parameters/functions
*/

/************************************************************************
 ** This function is used to clear the entire inventory of an object   **
 ** (except for Creature Slots, which have no bearing here), so that   **
 ** when the object is destroyed, no Lootbags are left behind to       **
 ** litter up the landscape & devour system resources.  Plot items are **
 ** not affected.                                                      **
 ************************************************************************/
void DestroyInventory(object oCorpse)
{

/* Version 3.2 - function rewritten */

   object oLoot; int x;

   //Get any gold from the dead creature
   x = GetGold(oCorpse);
   if (x) TakeGoldFromCreature(x, oCorpse, TRUE);

   // Destroy any loot the dead creature has equipped
   // 0=head, 1=chest, 2=boot, 3=arms, 4=rhand, 5=lhand, 6=cloak,
   // 7=lring, 8=rring, 9=neck, 10=belt, 11=arrow, 12=bullet, 13=bolt
   for (x = 0; x < 4; x++)
    {
       oLoot = GetItemInSlot(x, oCorpse);
       if (GetIsObjectValid(oLoot))
        {
           if (!GetPlotFlag(oLoot))
              DestroyObject(oLoot);
        }
    }
   // skipped 4 & 5 = equipped weapons (rhand & lhand)
    for (x = 6; x < 14; x++)
     {
        oLoot = GetItemInSlot(x, oCorpse);
        if (GetIsObjectValid(oLoot))
         {
            if (!GetPlotFlag(oLoot))
               DestroyObject(oLoot);
         }
     }

   // Destroy remaining loot on creature
   oLoot = GetFirstItemInInventory(oCorpse);
   while (GetIsObjectValid(oLoot))
    {
       if (!GetPlotFlag(oLoot))
          DestroyObject(oLoot);
       oLoot = GetNextItemInInventory(oCorpse);
    }
}

/************************************************************************
 ** This function is used to destroy unclaimed dropped weapons.        **
 ** Plot items are not affected.                                       **
 **                                                                    **
 ** NOTE: Shields/torches are also considered "weapons" for the        **
 ** purposes of this script.                                           **
 **                                                                    **
 ** NOTE: The lootable corpse placeable or the bones can call this     **
 ** script.                                                            **
 ************************************************************************/
void DestroyDroppedWeapons(object oLootCorpse)
{
   //Check to see if anyone Possesses the Left Weapon
   object oLeftWpn = GetLocalObject(oLootCorpse, "oLeftWpn");
   // If Left Weapon is unclaimed...
   if (GetItemPossessor(oLeftWpn) == OBJECT_INVALID)
    {
       // If dropped weapon is not Plot
       if (!GetPlotFlag(oLeftWpn))
          DestroyObject(oLeftWpn);
    }
   //Check to see if anyone Possesses the Right Weapon
   object oRightWpn = GetLocalObject(oLootCorpse, "oRightWpn");
   // If Right Weapon is unclaimed...
   if (GetItemPossessor(oRightWpn) == OBJECT_INVALID)
    {
       // If dropped weapon is not Plot
       if (!GetPlotFlag(oRightWpn))
          DestroyObject(oRightWpn);
    }
}

/*********************************************************
 ** This script gets rid of the bones after they fade   **
 *********************************************************/
void BonesCleanup(object oBones, int nKeepWeaponsBonesFade)
{
   // Empty the bones inventory
   DestroyInventory(oBones);
   // Delete unclaimed, dropped, non-Plot weapons unless nKeepWeaponsBonesFade = 1
   if (!nKeepWeaponsBonesFade)
      DestroyDroppedWeapons(oBones);
   // Delete the bones
   DestroyObject(oBones);
}

/******************************************************************************
 ** This script moves all items from lootable corpse placeable to the bones  **
 ******************************************************************************/
void TransferToBones(object oLootCorpse, object oBones)
{
   // Move gold to the bones
   if (GetGold(oLootCorpse))
    {
       AssignCommand(oBones, TakeGoldFromCreature(GetGold(oLootCorpse), oLootCorpse, FALSE));
    }
   // Move inventory items to the bones
   object oLoot = GetFirstItemInInventory(oLootCorpse);
   while (GetIsObjectValid(oLoot))
    {
       AssignCommand(oBones, ActionTakeItem(oLoot, oLootCorpse));
       oLoot = GetNextItemInInventory(oLootCorpse);
    }
}

//void main() {}
