//::///////////////////////////////////////////////
//:: Scarface's Persistent Banking
//:: sfpb_close
//:://////////////////////////////////////////////
/*
    Written By Scarface
*/
//////////////////////////////////////////////////

#include "sfpb_config"
void main()
{
    // Vars
    object oPC = GetLastClosedBy();
    object oChest = OBJECT_SELF;
    location lLoc = GetLocation(oPC);
    string sModName = GetName(GetModule());
    string sUserID = GetLocalString(oChest, "USER_ID");
    int nCount;

    // Lock the chest
    SetLocked(oChest, TRUE);

    // First loop to check for containers
    object oItem = GetFirstItemInInventory(oChest);
    while (GetIsObjectValid(oItem))
    {
        // Item count
        nCount++;

        if (GetHasInventory(oItem))
        {
            // Send a message to the player
            FloatingTextStringOnCreature("<cø>Containers/bags are NOT allowed to" +
                IntToString(MAX_ITEMS) + " be stored!!!" +
                                         "\nPlease remove the container/bag.</c>", oPC);

            // Unlock chest and end script
            SetLocked(oChest, FALSE);
            return;
        }
        else if (nCount > MAX_ITEMS)
        {
            // Send a message to the player
            FloatingTextStringOnCreature("<cø>Only a maximum of " +
                IntToString(MAX_ITEMS) + " items are allowed to be stored!!!" +
                                         "\nPlease remove the excess items.</c>", oPC);

            // Unlock chest and end script
            SetLocked(oChest, FALSE);
            return;
        }

        // Next item
        oItem = GetNextItemInInventory(oChest);
    }

    // Spawn in the NPC storer
    object oStorer = CreateObject(OBJECT_TYPE_CREATURE, "sfpb_storage", lLoc, FALSE, sUserID);

    // Loop through all items in the chest and copy them into
    // the NPC storers inventory and destroy the originals
    oItem = GetFirstItemInInventory(oChest);
    while (GetIsObjectValid(oItem))
    {
        // This is to stop the duping bug, the dupe bug happened when a player
        // would exit the server while still holding a chest open, the reason for
        // the duping was the NPC storer would never spawn in this case thus not
        // having anywhere to store the items, which ended up the items storing
        // back into the chest duplicating itself, now if this happens, the players
        // items will not be saved thus avoiding any unwanted item duplicates.
        if (!GetIsObjectValid(oStorer))
        {
            // Delete the local CD Key
            DeleteLocalString(oChest, "USER_ID");

            // Unlock Chest
            SetLocked(oChest, FALSE);
            return;
        }

        // Copy item to the storer
        CopyItem(oItem, oStorer, TRUE);

        // Destroy Original
        DestroyObject(oItem);

        // Next item
        oItem = GetNextItemInInventory(oChest);
    }

    // Save the NPC storer into the database
    StoreCampaignObject(sModName, DATABASE_ITEM + sUserID, oStorer);

    // Destroy NPC storer
    DestroyObject(oStorer);

    // Delete the local CD Key
    DeleteLocalString(oChest, "USER_ID");

    // Unlock Chest
    DelayCommand(5.0, SetLocked(oChest, FALSE));
}
