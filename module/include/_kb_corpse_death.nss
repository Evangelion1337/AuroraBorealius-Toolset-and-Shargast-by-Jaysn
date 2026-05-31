////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
//  _kb_corpse_death                                //      VERSION 3.3       //
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
//  This script works in conjunction with the "_kb_loot_corpse" script.  The  //
//  OnDeath event of the lootable corpse placeable (tag "invis_corpse_obj")   //
//  contains this script.                                                     //
//                                                                            //
//  This script is used to clean up the loot within that object in the event  //
//  it is destroyed - such as being caught in a fireball or physically hacked //
//  apart by a player (i.e. Bashed).  Plot items are not destroyed.           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/*  Version 3.3 Change Log:
    - added DestroyIfEmpty function to ensure TransferToBones is finished before destroying oLootCorpse
    - fixed comments to clarify that "doa_bashbreak" script refers to DOA's "Bashed Loot Breakage" plugin
/*  Version 3.2 Change Log:
    - renamed script from "_kb_destroy_cpse" to "_kb_corpse_death" for naming consistency
    - consolidated inventory management functions to _kb_inc_invmgmt
    - DestroyInventory function calls changed to DestroyInventory + DestroyDroppedWeapons in _kb_inc_invmgmt (identical)
    - added simple plugin architecture (requires file _kb_plugins)
    - integration with DOA's "Bashed Loot Breakage" plugin now requires zero editing (no include call)
    - added GetIsObjectValid check before destroying Bloodspot
    - moved DestroyDroppedWeapons outside if/else clause, so that plugins don't need to address it
    - added nUseBonesBash to create bones when corpse is bashed
    - added nBonesFade to determine when bones fade (if ever)
    - added nTinyBones to prevent bones from appearing for tiny-sized creatures
    - added nKeepInventoryBash to keep all items in a creature's inventory when its corpse is bashed
    - changed comments to clarify weapons/shields/torches are affected by "weapons" parameters/functions
    - changed comments to reflect that undead/constructs/elementals will not "gib" when bashed
    - renamed oHostCorpse to oHostBody for consistency
    - added support for DM's Helper wand (used to destroy corpse or bones)
    - added support for "Destroy Target" command of DM's Helper wand (used to destroy the corpse or bones)
*/

#include "_kb_inc_invmgmt"

/*******************************************************************************
 ** This script checks to make sure TransferToBones is done moving all items  **
 ** from oLootCorpse to oBones before destroying oLootCorpse.  Note that all  **
 ** items on oLootCorpse are droppable (due to "_kb_loot_corpse"), so         **
 ** TransferToBones will always empty oLootCorpse completely.                 **
 *******************************************************************************/
void DestroyIfEmpty()
{
   if (!GetIsObjectValid(GetFirstItemInInventory(OBJECT_SELF)))
    {
       DestroyObject(OBJECT_SELF);
    }
   else
    {
       // SendMessageToPC(GetFirstPC(), "oLootCorpse not empty yet");
       DelayCommand(1.0, DestroyIfEmpty());
    }
}


void main()
{
   /* Register Plugins */
   if (!GetLocalInt(GetModule(),"kb_lootcorpse_plugins"))
      ExecuteScript("_kb_plugins", OBJECT_SELF);

/*******************************************************************************
 ** INTEGRATION WITH DM's HELPER                                              **
 ** Thanks to Bored Bistander for the idea/scripting!                         **
 **                                                                           **
 ** If you like the DM's Helper (http://www.nwnguide.com/~nwnbuilder/), you   **
 ** can use the "Destroy Target" command of the DM's Helper wand to destroy   **
 ** the lootable corpse or the bones.  Just import the DM's Helper into your  **
 ** module, then paste the following lines at the beginning of the            **
 ** "dmwand_DestroyTarget()" function in the "dmw_func_inc" script:           **
 *******************************************************************************/

/*
   // Added by Scrotok
   if ((GetTag(oMyTarget) == "invis_corpse_obj") || (GetTag(oMyTarget) == "loot_bones_obj"))
    {
       if (GetTag(oMyTarget) == "loot_bones_obj")
        {
           SetLocalInt(oMyTarget, "nDestroyedByDMsHelper", TRUE);
        }
       effect eDestroy = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
       ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eDestroy, lMyLoc);
       ExecuteScript("_kb_corpse_death", oMyTarget);
       dmwand_BuildConversation("Start", "");
       return;
    }
*/

/*******************************************************************************
 ** Save your module.  Then re-build your module (scripts only); to do this,  **
 ** select Build Module under the Build pull-down menu, then check only the   **
 ** Advanced/Compile/Scripts boxes, then click Build, then Done once the      **
 ** build is finished.  Then re-save your module.  Once this is done, the     **
 ** code listed below will handle the rest.                                   **
 *******************************************************************************/
   // Destroy bones if "Destroy Target" command sent by DM's Helper wand
   // (OBJECT_SELF in the following section refers to the bones)
   if (GetLocalInt(OBJECT_SELF, "nDestroyedByDMsHelper") == TRUE)
    {
       BonesCleanup(OBJECT_SELF, GetLocalInt(OBJECT_SELF, "nKeepWeaponsBonesFade"));
       return;
    }

   //Get all of our required information
   int nUseBlood = GetLocalInt(OBJECT_SELF, "nUseBlood"); //Check for gratiutously Gory Destruction
   object oHostBody = GetLocalObject(OBJECT_SELF, "oHostBody"); //Get Value set by _kb_loot_corpse at creation
   object oCorpseBlood = GetLocalObject(OBJECT_SELF, "oBloodSpot"); //Get Value set by _kb_loot_corpse at creation

   // Determine creature size for later use
   int nCorpseSize = GetCreatureSize(oHostBody);

   object oPC = GetLastKiller();

   if (nUseBlood)
    {
       // Undead/constructs/elementals will never "gib", but all other creatures
       // (including Tiny-sized ones) will
       effect eBloodyEnd = EffectVisualEffect(VFX_COM_CHUNK_RED_SMALL);
       PlaySound("cb_ht_chunk");
       ApplyEffectToObject(DURATION_TYPE_INSTANT, eBloodyEnd, OBJECT_SELF, 3.0f);
    }

   //Delete the BloodSpot (if created)
   if (GetIsObjectValid(oCorpseBlood))
    {
       DestroyObject(oCorpseBlood);
    }

   // Empty and delete actual creature corpse (body)
   DestroyInventory(oHostBody);
   /*  There is no call to DestroyDroppedWeapons since if the weapons are
       dropped, they are already deleted from oHostBody. If the weapons are
       not dropped, then the function would still not delete the weapons
       since GetItemPossessor would be a valid object */
   AssignCommand(oHostBody, SetIsDestroyable(TRUE,FALSE,FALSE));
   DestroyObject(oHostBody);

////////////////////////////////////////////////////////////////////////////////
// The following section deletes ALL, SOME, or NONE of the inventory:
//  - All (except plot): default if DOA's "Bashed Loot Breakage" plugin ("doa_bashbreak") isn't installed
//  - Some (random chance based on item/value): requires "doa_bashbreak" plugin
//  - None: not default (only works if nKeepInventoryBash = TRUE)
////////////////////////////////////////////////////////////////////////////////

// PLUGIN BEHAVIOR
   if (GetLocalInt(GetModule(),"doa_bashbreak"))
    {
       // Random chance of inventory items breaking when corpse is bashed
       ExecuteScript("doa_bashbreak", OBJECT_SELF);
    }
   else
    {
// DEFAULT BEHAVIOR if plugin not installed
       if (GetLocalInt(OBJECT_SELF, "nKeepInventoryBash") == FALSE)
          // Delete all items (except Plot) from lootable corpse placeable
          DestroyInventory(OBJECT_SELF);
       else
        {
          // Do nothing (delete nothing from lootable corpse placeable)
        }
    }

   // If user wants bones to be created when corpse is bashed...
   if (GetLocalInt(OBJECT_SELF, "nUseBonesBash"))
    {
       if ((GetLocalInt(OBJECT_SELF, "nTinyBones") == FALSE) && (nCorpseSize == CREATURE_SIZE_TINY))
        {
           // Do nothing -- no bones for tiny creatures if nTinyBones is FALSE
        }
       else
        {
           // Create the bones
           object oBones = CreateObject(OBJECT_TYPE_PLACEABLE, "loot_bones_obj", GetLocation(OBJECT_SELF), FALSE);
           // Move inventory to bones
           TransferToBones(OBJECT_SELF, oBones);
           // Fade bones after nBoneFade seconds
           if (GetLocalInt(OBJECT_SELF, "nBonesFade") > 0)
            {
               // Remember racial type and Blueprint ResRef for use with Scrotok's Raise Dead/Resurrection plugin
               SetLocalInt(oBones, "nRacialType", GetLocalInt(OBJECT_SELF, "nRacialType"));
               SetLocalString(oBones, "sHostBodyResRef", GetLocalString(OBJECT_SELF, "sHostBodyResRef"));
               // Pass dropped weapon/shield/torch info to bones
               SetLocalObject(oBones, "oLeftWpn", GetLocalObject(OBJECT_SELF, "oLeftWpn"));
               SetLocalObject(oBones, "oRightWpn", GetLocalObject(OBJECT_SELF, "oRightWpn"));
               int nKeepWeaponsBonesFade = GetLocalInt(OBJECT_SELF, "nKeepWeaponsBonesFade");
               // Remember nKeepWeaponsBonesFade for use with DM's Helper wand
               SetLocalInt(oBones, "nKeepWeaponsBonesFade", nKeepWeaponsBonesFade);
               float fBonesFade = IntToFloat(GetLocalInt(OBJECT_SELF, "nBonesFade"));
               AssignCommand(oBones, DelayCommand(fBonesFade, BonesCleanup(oBones, nKeepWeaponsBonesFade)));
            }
        }
    }

   // Delete unclaimed, dropped, non-Plot weapons/shields/torches unless nKeepWeaponsBash = 1
   if (!GetLocalInt(OBJECT_SELF, "nKeepWeaponsBash"))
      DestroyDroppedWeapons(OBJECT_SELF);

   // Destroy the lootable corpse placeable (once it's empty)
   // DelayCommand(1.0f, DestroyObject(OBJECT_SELF)); // Removed in version 3.3
   DelayCommand(1.0, DestroyIfEmpty());

}
