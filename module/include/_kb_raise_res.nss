////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
//  _kb_raise_res                                   //      VERSION 1.0       //
//                                                  //                        //
//  Scrotok's Raise Dead/Resurrection Plugin        ////////////////////////////
//  by Scrotok on 18 Dec 02                                                   //
//  Thanks to Lord Niah and Bored Bistander for help on the Raise/Res idea    //
//  email Questions and Comments to: jnbplatte@intellisys.net                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  This is an optional plugin for Scrotok's Lootable Corpses.  It requires   //
//  modified versions of "nw_s0_raisdead" and "nw_s0_resserec" (included in   //
//  the ERF for this plugin).  This script enables lootable corpses to be     //
//  brought back to life with either the Resurrection or Raise Dead spells.   //
//  This script can be called by lootable corpse placeables or bones.         //
//                                                                            //
//  NEWBIES: You don't need to place this script anywhere -- it gets called   //
//  (using the ExecuteScript function) by another script ("_kb_plugins").
//                                                                            //
//  KNOWN BUG: If Raise Dead or Resurrection is cast, but the spell           //
//  won't work (based on racial type, or the fact that Raise Dead won't work  //
//  on bones), the spell or scroll is still wasted in the attempt.            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


/*******************************************************************************
 ** Used for debugging to determine where the oEquip items are (or if the     **
 ** items are invalid objects).                                               **
 *******************************************************************************/
void DetermineEquipOwner(object oLootCorpse)
{
   int x;
   string sEquip;
   for (x = 1; x < 15; x++)
    {
       sEquip = "oEquip"+IntToString(x);
       // oEquip12 & 13 == OBJECT_INVALID if nDropWeapons is TRUE
       // oEquip8 & 14 are destroyed (OBJECT_INVALID) during inventory move to oHostBody (if nCopyArmour is TRUE)
       if (GetIsObjectValid(GetLocalObject(oLootCorpse, sEquip)))
        {
           SendMessageToPC(GetFirstPC(), sEquip+" is possessed by "+GetTag(GetItemPossessor(GetLocalObject(oLootCorpse, sEquip))));
        }
       else
        {
           SendMessageToPC(GetFirstPC(), sEquip+" is an invalid object.");
        }
    }
}

/*******************************************************************************
 ** Used for debugging to ensure returned items get re-equipped by oHostBody. **
 ** You can also verify some items are equipped in-game by right-clicking on  **
 ** the creature and selecting Examine; for example, you'll see "Increased    **
 ** Strength" if the creature is wearing Gauntlets of Ogre Power.             **
 *******************************************************************************/
void VerifyEquipped(object oHostBody)
{
   object oItem; int x;
   for (x = 0; x < 14; x++)
    {
       oItem = GetItemInSlot(x, oHostBody);
       if (GetIsObjectValid(oItem))
        {
           SendMessageToPC(GetFirstPC(), GetName(oItem)+" is equipped");
        }
    }
}

/*******************************************************************************
 ** This script removes ALL gold and inventory items (even non-Droppable and  **
 ** Plot) from a newly-created oHostBody (as part of Resurrection spell).     **
 ** Creature Slot items are not affected.                                     **
 *******************************************************************************/
void RemoveInventory(object oHostBody)
{
   // Delete gold
   TakeGoldFromCreature(GetGold(oHostBody), oHostBody, TRUE);
   // Destroy equipped items
   // 0=head, 1=chest, 2=boot, 3=arms, 4=rhand, 5=lhand, 6=cloak,
   // 7=lring, 8=rring, 9=neck, 10=belt, 11=arrow, 12=bullet, 13=bolt
   object oItem; int x;
   for (x = 0; x < 14; x++)
    {
       oItem = GetItemInSlot(x, oHostBody);
       if (GetIsObjectValid(oItem))
        {
           if (GetPlotFlag(oItem)) SetPlotFlag(oItem, FALSE);
           DestroyObject(oItem);
        }
    }
   // Delete items (including non-Droppable and Plot items)
   oItem = GetFirstItemInInventory(oHostBody);
   while (GetIsObjectValid(oItem))
    {
       if (GetPlotFlag(oItem)) SetPlotFlag(oItem, FALSE);
       DestroyObject(oItem);
       oItem = GetNextItemInInventory(oHostBody);
    }
}

/*******************************************************************************
 ** Re-equip previously-equipped items on oHostBody if items were passed back **
 ** to oHostBody from oLootCorpse (assumes the items weren't looted from      **
 ** oLootCorpse).  This script only applies to oLootCorpse; bones don't have  **
 ** local "oEquip" objects, so if bones are resurrected, the items don't get  **
 ** re-equipped (NPCs with "naked" models will appear naked, which is as it   **
 ** should be, since their corpse was too damaged to wear equipment anyway).  **
 *******************************************************************************/
void ReEquip(object oHostBody, object oLootCorpse)
{
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip1")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip1"), INVENTORY_SLOT_ARMS));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip2")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip2"), INVENTORY_SLOT_ARROWS));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip3")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip3"), INVENTORY_SLOT_BELT));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip4")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip4"), INVENTORY_SLOT_BOLTS));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip5")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip5"), INVENTORY_SLOT_BOOTS));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip6")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip6"), INVENTORY_SLOT_BULLETS));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip7")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip7"), INVENTORY_SLOT_CLOAK));
   /*
      Helmet (oEquip8) gets handled by "oOrigHelmet" code in ReturnInventory
      (if nCopyArmour is TRUE), or gets re-equipped (if nMoveArmour is TRUE and
      nCopyArmour is FALSE)
   */
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip8")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip8"), INVENTORY_SLOT_HEAD));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip9")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip9"), INVENTORY_SLOT_LEFTRING));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip10")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip10"), INVENTORY_SLOT_NECK));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip11")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip11"), INVENTORY_SLOT_RIGHTRING));
   /*
      Weapons (oEquip12 & 13) stay dropped on the ground (if nDropWeapons is
      TRUE, oEquip12 & 13 == OBJECT_INVALID), or get re-equipped (if
      nMoveWeapons is TRUE and nDropWeapons is FALSE)
   */
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip12")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip12"), INVENTORY_SLOT_RIGHTHAND));
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip13")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip13"), INVENTORY_SLOT_LEFTHAND));
   /*
      Armour (oEquip14) gets handled by "oOrigArmour" code in ReturnInventory
      (if nCopyArmour is TRUE), or gets re-equipped (if nMoveArmour is TRUE and
      nCopyArmour is FALSE)
   */
   if (GetItemPossessor(GetLocalObject(oLootCorpse, "oEquip14")) == oHostBody)
      AssignCommand(oHostBody, ActionEquipItem(GetLocalObject(oLootCorpse, "oEquip14"), INVENTORY_SLOT_CHEST));
}

/*******************************************************************************
 ** This script returns gold and inventory items from oLootCorpse (or bones)  **
 ** to oHostBody.  Dropped, unclaimed weapons remain where they fell.         **
 **                                                                           **
 ** NOTE: Even though one of the parameters is "oLootCorpse = OBJECT_SELF",   **
 ** this script can also be called by bones!                                  **
 *******************************************************************************/
void ReturnInventory(object oHostBody, object oLootCorpse = OBJECT_SELF)
{
   // Remember dropped weapon info
   /*
      Store oLeftWpn/oRightWpn on oHostBody, so that if the oHostBody is killed
      again, dropped weapons info will be saved (see "_kb_loot_corpse").
   */
   SetLocalObject(oHostBody, "oLeftWpn", GetLocalObject(OBJECT_SELF, "oLeftWpn"));
   SetLocalObject(oHostBody, "oRightWpn", GetLocalObject(OBJECT_SELF, "oRightWpn"));

   // Move gold to oHostBody
   // (This was commented out because gold is moved as an inventory item below)
   // (if you don't comment out this line, the creature's gold will double)
   // AssignCommand(oLootCorpse, GiveGoldToCreature(oHostBody, GetGold(oLootCorpse)));

   // Move inventory items to oHostBody
   object oEquip = GetFirstItemInInventory(oLootCorpse);
   while (GetIsObjectValid(oEquip))
    {
       // If oHostBody is still wearing oOrigArmor, and no one has removed
       // oLootArmor from oLootCorpse, destroy oLootArmor/oEquip14 (no need to
       // transfer it back to oHostBody, since oOrigArmor is still there)
       // NOTE: This never applies to bones, since if bones exist, oHostBody
       // and oOrigArmour were already destroyed, and oLootArmour was already
       // transferred to the bones (oLootArmour/oOrigArmour == OBJECT_INVALID)
       if ((oEquip == GetLocalObject(OBJECT_SELF, "oLootArmour")) &&
           (GetIsObjectValid(GetLocalObject(OBJECT_SELF, "oOrigArmour"))))
           DestroyObject(oEquip); // destroys oLootArmour/oEquip14
       // Make a similar check for oLootHelmet/oEquip8 and oOrigHelmet
       // (doesn't apply to bones either)
       else if ((oEquip == GetLocalObject(OBJECT_SELF, "oLootHelmet")) &&
           (GetIsObjectValid(GetLocalObject(OBJECT_SELF, "oOrigHelmet"))))
           DestroyObject(oEquip); // destroys oLootHelmet/oEquip8
       else
        {
          // This following line doesn't work
          // (maybe because combat leads to ClearAllActions on oHostBody?)
          // AssignCommand(oHostBody, ActionTakeItem(oEquip, oLootCorpse));
          AssignCommand(oLootCorpse, ActionGiveItem(oEquip, oHostBody));
        }
       oEquip = GetNextItemInInventory(oLootCorpse);
    }

/*
   // Used for debugging
   SendMessageToPC(GetFirstPC(), "MOVING INVENTORY...");
   DetermineEquipOwner(oLootCorpse);
   DelayCommand(0.5, SendMessageToPC(GetFirstPC(), "MOVE COMPLETE (hopefully)..."));
   DelayCommand(0.5, DetermineEquipOwner(oLootCorpse));
*/

   // Delay time might need to be increased for slower PC's or large inventories
   DelayCommand(0.5, ReEquip(oHostBody, oLootCorpse));

   // Used for debugging
   // DelayCommand(0.7, VerifyEquipped(oHostBody));

   DelayCommand(1.0, DestroyObject(OBJECT_SELF));
}

void main()
{
   /* register with other scripts */
   int bModDebug = GetLocalInt(GetModule(),"bModDebug");
   if (!GetLocalInt(GetModule(),"kb_raise_res"))
    {
       if (bModDebug) SendMessageToPC(GetFirstPC(),"Registering _kb_raise_res ...");
       SetLocalInt(GetModule(),"kb_raise_res",1);
    }
   /* exit if null object calling - probably registration */
   if (OBJECT_SELF == OBJECT_INVALID) return;

   /* run plugin code */
   int nSpellCast = GetLastSpell();

   //Get all of our required information
   object oHostBody = GetLocalObject(OBJECT_SELF, "oHostBody"); // returns OBJECT_INVALID if script called by bones
   string sHostBodyResRef = GetLocalString(OBJECT_SELF, "sHostBodyResRef");
   object oCorpseBlood = GetLocalObject(OBJECT_SELF, "oBloodSpot"); // returns OBJECT_INVALID if script called by bones

   // Spell failure effect (for later use)
   effect eSpellFail = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);

   // Raise Dead and Resurrection won't work on Outsiders, Elementals,
   // Constructs, Undead, or RACIAL_TYPE_INVALID
   int nRacialType = GetLocalInt(OBJECT_SELF, "nRacialType");
   if ((nRacialType == RACIAL_TYPE_OUTSIDER) ||
       (nRacialType == RACIAL_TYPE_ELEMENTAL) ||
       (nRacialType == RACIAL_TYPE_CONSTRUCT) ||
       (nRacialType == RACIAL_TYPE_UNDEAD) ||
       (nRacialType == RACIAL_TYPE_INVALID))
    {
       // Spell failure effect
       ApplyEffectToObject(DURATION_TYPE_INSTANT, eSpellFail, OBJECT_SELF);
       // Spell failure message
       if (nSpellCast == SPELL_RAISE_DEAD)
        {
           SendMessageToPC(GetLastSpellCaster(), "This type of creature cannot be raised from the dead.");
        }
       if (nSpellCast == SPELL_RESURRECTION)
        {
           SendMessageToPC(GetLastSpellCaster(), "This type of creature cannot be resurrected.");
        }
// KNOWN BUG: Spell or scroll is wasted in the attempt
       return;
    }

   if (nSpellCast == SPELL_RAISE_DEAD)
    {
       // Raise Dead won't work on bones
       if (GetTag(OBJECT_SELF) == "loot_bones_obj")
        {
           // Spell failure effect
           ApplyEffectToObject(DURATION_TYPE_INSTANT, eSpellFail, OBJECT_SELF);
           // Spell failure message
           SendMessageToPC(GetLastSpellCaster(), "This corpse is too badly damaged to be raised from the dead.");
// KNOWN BUG: Spell or scroll is wasted in the attempt
           return;
        }
       ActionCastSpellAtObject(nSpellCast, oHostBody, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
       if (GetIsObjectValid(oCorpseBlood)) DestroyObject(oCorpseBlood);
       ReturnInventory(oHostBody);
    }
   else if (nSpellCast == SPELL_RESURRECTION)
    {
       // Works on lootable corpse placeable or bones
       if (!GetIsObjectValid(oHostBody))
        {
           // Resurrect oBones ("transforms" oBones into oHostBody by
           // re-creating the creature using sHostBodyResRef)
           oHostBody = CreateObject(OBJECT_TYPE_CREATURE, sHostBodyResRef, GetLocation(OBJECT_SELF), FALSE);
           // delete all default gold/items from oHostBody
           RemoveInventory(oHostBody);
           // Resurrection visual and sound effect
           effect eResVis = EffectVisualEffect(VFX_IMP_RAISE_DEAD);
           ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eResVis, GetLocation(oHostBody));
           PlaySound("sim_healdead");
        }
       else
        {
           // Resurrect oHostBody (lootable corpse placeable is OBJECT_SELF)
           ActionCastSpellAtObject(nSpellCast, oHostBody, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
           if (GetIsObjectValid(oCorpseBlood)) DestroyObject(oCorpseBlood);
        }
       ReturnInventory(oHostBody);
    }
   else return;
}
