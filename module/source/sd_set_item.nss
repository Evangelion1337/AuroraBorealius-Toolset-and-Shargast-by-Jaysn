///////////////////////////////
//: Set Script
//:
//: Universal
//:
//:
//: === in onrespawn script ===
//: #include "sd_set_item_inc"
//: ApplySetBonus(oRespawner);
//:
#include "sd_set_item_inc"
#include "sd_lootsystem"
#include "x2_inc_switches"

////////////////////////////////////////////////////////////////////////////////
//:General Constants
//:
//:

const int COLOR_R = 255;
const int COLOR_G = 100;    // Pink
const int COLOR_B = 200;



////////////////////////////////////////////////////////////////////////////////
//:General Utilities
//:
//:
//:

int SD_UNIQUE_CHECK(object oPC, object oSetPiece)
{
 int iFlag=0;
 string sRes, sString, sIname;
 object oItem;
 sRes = GetResRef(oSetPiece);

// check inventory

 object oCheck = GetFirstItemInInventory(oPC);
 while (GetIsObjectValid(oCheck))
       {
        if (GetResRef(oCheck)==sRes)++iFlag;
        oCheck = GetNextItemInInventory(oPC);
       }

 // check equipped items

 oItem = GetItemInSlot(INVENTORY_SLOT_ARMS, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_BELT, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;
 oItem = GetItemInSlot(INVENTORY_SLOT_NECK, oPC);
 if (GetResRef(oItem)==sRes) iFlag+=1;

 if (iFlag>=2)
    {
     sIname = GetName(oSetPiece);
     sString = ColorString("You can only have one of these at a time", 255, 0, 0);
     FloatingTextStringOnCreature(sString, oPC);
     DestroyObject(oSetPiece);

     SendMessageToPC(oPC,"DM: "+sIname+" destroyed");
     SendMessageToPC(oPC,"DM: Compensatory gold awarded");
     GiveGoldToCreature(oPC, 3000);
     AssignCommand(oPC, PlaySound("it_coins"));
     return TRUE;
    }
  return FALSE;
 }

void UpdateName(object oPC, object oItem, int iPieces, int iSetNum, string sNameOfSet)
{
 // Update Current Item
 string sName, sIName;


 sIName = GetLocalString(oItem, "sName");
 sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")",
                     COLOR_R, COLOR_G, COLOR_B);
 SetName(oItem, sName);

 // Update InventoryItems

 oItem = GetFirstItemInInventory(oPC);
 while (GetIsObjectValid(oItem))
       {
        if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
           {
            sIName = GetLocalString(oItem, "sName");
            sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
            SetName(oItem, sName);
           }
        oItem = GetNextItemInInventory(oPC);
       }

// Update Slotted Items

 oItem = GetItemInSlot(INVENTORY_SLOT_ARMS, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_BELT, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
 oItem = GetItemInSlot(INVENTORY_SLOT_NECK, oPC);
 if (GetTag(oItem)=="sd_set_item" && GetLocalString(oItem, "sSet")==sNameOfSet)
    {
     sIName = GetLocalString(oItem, "sName");
     sName = ColorString(sIName+" ("+IntToString(iPieces)+"/"+IntToString(iSetNum)+")", COLOR_R, COLOR_G, COLOR_B);
     SetName(oItem, sName);
    }
}
////////////////////////////////////////////////////////////////////////////////
//:End of General Utilities
//
////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////
//: MAIN SCRIPT
//:
//:

void main()
{
 int nEvent =GetUserDefinedItemEventNumber();

 object oPC, oEquip, oUnEquip, oItem;
 string sName, sIName, sID, sNameOfSet;
 int iPieces, iLength, iSetNum;
 effect eImbue, eVis, eFinal;



 if (nEvent ==X2_ITEM_EVENT_EQUIP)
    {
     oPC = GetPCItemLastEquippedBy();
     oEquip = GetPCItemLastEquipped();
     sID = GetLocalString(oEquip, "sSet")+"_equ";
     sNameOfSet = GetLocalString(oEquip, "sSet");

     iPieces = GetLocalInt(oPC, sID);
     ++iPieces;
     SetLocalInt(oPC, sID, iPieces);

     if (sNameOfSet=="Dorian's Battlegear")DoriansBattlegearEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Mystra's Rainment")MystrasRainmentEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Thera's Vestments")TherasVestmentsEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Shinobi's Garb")ShinobisGarbEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Benedict's Herald")BenedictsHeraldEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Armor of Divinity")ArmorOfDivinityEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Soothsayer's Regalia")SoothsayersRegaliaEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Robes of Enlightenment")RobesOfEnlightenmentEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Vestments of Rage")VestmentsofRageEquip(oPC, iPieces, 0);


     ////////////////////////////////////
     //: Debugging
     //: FloatingTextStringOnCreature(IntToString(iPieces), oPC);
    }
else if (nEvent ==X2_ITEM_EVENT_UNEQUIP)
    {
     oPC = GetPCItemLastUnequippedBy();
     oUnEquip = GetPCItemLastUnequipped();
     sID = GetLocalString(oUnEquip, "sSet")+"_equ";
     sNameOfSet = GetLocalString(oUnEquip, "sSet");

     iPieces = GetLocalInt(oPC, sID);
     --iPieces;
     SetLocalInt(oPC, sID, iPieces);

     if (sNameOfSet=="Dorian's Battlegear")DoriansBattlegearUnEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Mystra's Rainment")MystrasRainmentUnEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Thera's Vestments")TherasVestmentsUnEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Shinobi's Garb")ShinobisGarbUnEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Benedict's Herald")BenedictsHeraldUnEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Armor of Divinity")ArmorOfDivinityUnEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Soothsayer's Regalia")SoothsayersRegaliaUnEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Robes of Enlightenment")RobesOfEnlightenmentUnEquip(oPC, iPieces, 0);
     if (sNameOfSet=="Vestments of Rage")VestmentsofRageUnEquip(oPC, iPieces, 0);

     ////////////////////////////////////
     //: Debugging
     //: FloatingTextStringOnCreature(IntToString(iPieces), oPC);
    }
 else if (nEvent == X2_ITEM_EVENT_ACQUIRE)
    {
        oPC = GetModuleItemAcquiredBy();
        oItem  = GetModuleItemAcquired();

        if (SD_UNIQUE_CHECK(oPC, oItem)==TRUE)return;

        sID = GetLocalString(oItem, "sSet")+"_acq";
        iSetNum = GetLocalInt(oItem, "iSetNum");
        sNameOfSet = GetLocalString(oItem, "sSet");

        iPieces = GetLocalInt(oPC, sID);
        ++iPieces;
        SetLocalInt(oPC, sID, iPieces);

        UpdateName(oPC, oItem, iPieces, iSetNum, sNameOfSet);


        ////////////////////////////////////
        //: Debugging
        //: FloatingTextStringOnCreature(IntToString(iPieces), oPC);

     }
else if (nEvent == X2_ITEM_EVENT_UNACQUIRE)
    {
        oPC = GetModuleItemLostBy();
        oItem  = GetModuleItemLost();
        sID = GetLocalString(oItem, "sSet")+"_acq";
        iSetNum = GetLocalInt(oItem, "iSetNum");
        sNameOfSet = GetLocalString(oItem, "sSet");
        iPieces = GetLocalInt(oPC, sID);
        --iPieces;
        SetLocalInt(oPC, sID, iPieces);

        UpdateName(oPC, oItem, iPieces, iSetNum, sNameOfSet);


        ////////////////////////////////////
        //: Debugging
        //: FloatingTextStringOnCreature(IntToString(iPieces), oPC);
       }
}
