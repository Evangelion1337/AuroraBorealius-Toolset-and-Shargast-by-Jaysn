#include "sd_set_item_inc"


const string COLORTOKEN = "                  ##################$%&'()*+,-./0123456789:;;==?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[[]^_`abcdefghijklmnopqrstuvwxyz{|}~~ÄÅÇÉÑÖÜáàâäãåçéèêëíìîïñóòôöõúùûü°°¢£§•¶ß®©™´¨¨ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛˛";

string ColorString(string sText, int nRed=255, int nGreen=255, int nBlue=255)
{
    return "<c" + GetSubString(COLORTOKEN, nRed, 1) + GetSubString(COLORTOKEN, nGreen, 1) + GetSubString(COLORTOKEN, nBlue, 1) + ">" + sText + "</c>";
}

const int COLOR_R = 255;
const int COLOR_G = 100;    // Pink
const int COLOR_B = 200;

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

void RE_SOCKET(object oPC, object oItem, int iPieces, int iFlag)
{
 string sName, sSetName, sID;

 if (GetResRef(oItem)=="sd_fighter_s1_1")
    {
     sName = "Dorian's Vestguard";
     sSetName = "Dorian's Battlegear";
    }
 if (GetResRef(oItem)=="sd_fighter_s1_2")
    {
     sName = "Dorian's Crest";
     sSetName = "Dorian's Battlegear";
    }
 if (GetResRef(oItem)=="sd_fighter_s1_3")
    {
     sName = "Dorian's Helm";
     sSetName = "Dorian's Battlegear";
    }
 if (GetResRef(oItem)=="sd_fighter_s1_4")
    {
     sName = "Dorian's Waistband";
     sSetName = "Dorian's Battlegear";
    }
 if (GetResRef(oItem)=="sd_fighter_s1_5")
    {
     sName = "Dorian's Gauntlets";
     sSetName = "Dorian's Battlegear";
    }
 if (GetResRef(oItem)=="sd_fighter_s1_6")
    {
     sName = "Dorian's Greaves";
     sSetName = "Dorian's Battlegear";
    }

          // Wizard Set

 if (GetResRef(oItem)=="sd_wizard_s1_1")
    {
     sName = "Mystra's Wraps";
     sSetName = "Mystra's Rainment";
    }
 if (GetResRef(oItem)=="sd_wizard_s1_2")
    {
     sName = "Mystra's Robe";
     sSetName = "Mystra's Rainment";
    }
 if (GetResRef(oItem)=="sd_wizard_s1_3")
    {
     sName = "Mystra's Tiara";
     sSetName = "Mystra's Rainment";
    }
 if (GetResRef(oItem)=="sd_wizard_s1_4")
    {
     sName = "Mystra's Sash";
     sSetName = "Mystra's Rainment";
    }
 if (GetResRef(oItem)=="sd_wizard_s1_5")
    {
     sName = "Mystra's Cape";
     sSetName = "Mystra's Rainment";
    }
 if (GetResRef(oItem)=="sd_wizard_s1_6")
    {
     sName = "Mystra's Slippers";
     sSetName = "Mystra's Rainment";
    }

           // Sorcerer Set

 if (GetResRef(oItem)=="sd_sorc_s1_1")
    {
     sName = "Thera's Robe";
     sSetName = "Thera's Vestments";
    }
 if (GetResRef(oItem)=="sd_sorc_s1_2")
    {
     sName = "Thera's Cape";
     sSetName = "Thera's Vestments";
    }
 if (GetResRef(oItem)=="sd_sorc_s1_3")
    {
     sName = "Thera's Sash";
     sSetName = "Thera's Vestments";
    }
 if (GetResRef(oItem)=="sd_sorc_s1_4")
    {
     sName = "Thera's Slippers";
     sSetName = "Thera's Vestments";
    }
 if (GetResRef(oItem)=="sd_sorc_s1_5")
    {
     sName = "Thera's Tiara";
     sSetName = "Thera's Vestments";
    }
 if (GetResRef(oItem)=="sd_sorc_s1_6")
    {
     sName = "Thera's Wraps";
     sSetName = "Thera's Vestments";
    }

          // DEX Fighter/Rogue Set



 if (GetResRef(oItem)=="sd_fighter_s2_1")
    {
     sName = "Shinobi's Tekou";
     sSetName = "Shinobi's Garb";
    }
 if (GetResRef(oItem)=="sd_fighter_s2_2")
    {
     sName = "Shinobi's Kabuto";
     sSetName = "Shinobi's Garb";
    }
 if (GetResRef(oItem)=="sd_fighter_s2_3")
    {
     sName = "Shinobi's Kimono";
     sSetName = "Shinobi's Garb";
    }
 if (GetResRef(oItem)=="sd_fighter_s2_4")
    {
     sName = "Shinobi's Tabi";
     sSetName = "Shinobi's Garb";
    }
 if (GetResRef(oItem)=="sd_fighter_s2_5")
    {
     sName = "Shinobi's Obi";
     sSetName = "Shinobi's Garb";
    }
 if (GetResRef(oItem)=="sd_fighter_s2_6")
    {
     sName = "Shinobi's Oyoroi";
     sSetName = "Shinobi's Garb";
    }

     // Cleric Set



 if (GetResRef(oItem)=="sd_cleric_s1_1")
    {
     sName = "Benevolent Grips";
     sSetName = "Benedict's Herald";
    }
 if (GetResRef(oItem)=="sd_cleric_s1_2")
    {
     sName = "Benevolent Sandals";
     sSetName = "Benedict's Herald";
    }
 if (GetResRef(oItem)=="sd_cleric_s1_3")
    {
     sName = "Benevolent Mitre";
     sSetName = "Benedict's Herald";
    }
 if (GetResRef(oItem)=="sd_cleric_s1_4")
    {
     sName = "Benevolent Robe";
     sSetName = "Benedict's Herald";
    }
 if (GetResRef(oItem)=="sd_cleric_s1_5")
    {
     sName = "Benevolent Ephod";
     sSetName = "Benedict's Herald";
    }
 if (GetResRef(oItem)=="sd_cleric_s1_6")
    {
     sName = "Benevolent Cord";
     sSetName = "Benedict's Herald";
    }

       // Bard Set
 /*
 if (GetResRef(oItem)=="sd_bard_s1_1")
    {
     sName = "";
     sSetName = "";
    }
 if (GetResRef(oItem)=="sd_bard_s1_2")
    {
     sName = "";
     sSetName = "";
    }
 if (GetResRef(oItem)=="sd_bard_s1_3")
    {
     sName = "";
     sSetName = "";
    }
 if (GetResRef(oItem)=="sd_bard_s1_4")
    {
     sName = "";
     sSetName = "";
    }
 if (GetResRef(oItem)=="sd_bard_s1_5")
    {
     sName = "";
     sSetName = "";
    }
 if (GetResRef(oItem)=="sd_bard_s1_6")
    {
     sName = "";
     sSetName = "";
    }
 */
      // Paladin Set

 if (GetResRef(oItem)=="sd_paladin_s1_1")
    {
     sName = "Zealot's Gloves";
     sSetName = "Armor of Divinity";
    }
 if (GetResRef(oItem)=="sd_paladin_s1_2")
    {
     sName = "Zealot's Sabatons";
     sSetName = "Armor of Divinity";
    }
 if (GetResRef(oItem)=="sd_paladin_s1_3")
    {
     sName = "Zealot's Targe";
     sSetName = "Armor of Divinity";
    }
 if (GetResRef(oItem)=="sd_paladin_s1_4")
    {
     sName = "Zealot's Vanguard";
     sSetName = "Armor of Divinity";
    }
 if (GetResRef(oItem)=="sd_paladin_s1_5")
    {
     sName = "Zealot's Plate";
     sSetName = "Armor of Divinity";
    }
 if (GetResRef(oItem)=="sd_paladin_s1_6")
    {
     sName = "Zealot's Waistguard";
     sSetName = "Armor of Divinity";
    }
        // Druid Set

 if (GetResRef(oItem)=="sd_druid_s1_1")
    {
     sName = "Oracle's Headdress";
     sSetName = "Soothsayer's Regalia";
    }
 if (GetResRef(oItem)=="sd_druid_s1_2")
    {
     sName = "Oracle's Covering";
     sSetName = "Soothsayer's Regalia";
    }
 if (GetResRef(oItem)=="sd_druid_s1_3")
    {
     sName = "Oracle's Shinwraps";
     sSetName = "Soothsayer's Regalia";
    }
 if (GetResRef(oItem)=="sd_druid_s1_4")
    {
     sName = "Oracle's Cord";
     sSetName = "Soothsayer's Regalia";
    }
 if (GetResRef(oItem)=="sd_druid_s1_5")
    {
     sName = "Oracle's Mantle";
     sSetName = "Soothsayer's Regalia";
    }
 if (GetResRef(oItem)=="sd_druid_s1_6")
    {
     sName = "Oracle's Stanchions";
     sSetName = "Soothsayer's Regalia";
    }

          // Ranger Set
          /*


 if (GetResRef(oItem)=="sd_ranger_s1_1";
 if (GetResRef(oItem)=="sd_ranger_s1_2";
 if (GetResRef(oItem)=="sd_ranger_s1_3";
 if (GetResRef(oItem)=="sd_ranger_s1_4";
 if (GetResRef(oItem)=="sd_ranger_s1_5";
 if (GetResRef(oItem)=="sd_ranger_s1_6";
*/
           // Monk Set


 if (GetResRef(oItem)=="sd_monk_s1_1")
    {
     sName = "Trancendent Cap";
     sSetName = "Robes of Enlightenment";
    }
 if (GetResRef(oItem)== "sd_monk_s1_2")
    {
     sName = "Trancendent Harness";
     sSetName = "Robes of Enlightenment";
    }
 if (GetResRef(oItem)=="sd_monk_s1_3")
    {
     sName = "Trancendent Sequin Belt";
     sSetName = "Robes of Enlightenment";
    }
 if (GetResRef(oItem)=="sd_monk_s1_4")
    {
     sName = "Trancendent Windcatcher";
     sSetName = "Robes of Enlightenment";
    }
 if (GetResRef(oItem)=="sd_monk_s1_5")
    {
     sName = "Trancendent Clogs";
     sSetName = "Robes of Enlightenment";
    }
 if (GetResRef(oItem)=="sd_monk_s1_6")
    {
     sName = "Trancendent Amulet";
     sSetName = "Robes of Enlightenment";
    }

        // Barbarian Set
 if (GetResRef(oItem)=="sd_barb_s1_1")
    {
     sName = "Conan's Crown";
     sSetName = "Vestments of Rage";
    }
 if (GetResRef(oItem)=="sd_barb_s1_2")
    {
     sName = "Conan's Loincloth";
     sSetName = "Vestments of Rage";
    }
 if (GetResRef(oItem)=="sd_barb_s1_3")
    {
     sName = "Conan's Belt";
     sSetName = "Vestments of Rage";
    }
 if (GetResRef(oItem)=="sd_barb_s1_4")
    {
     sName = "Conan's Bearskin Cloak";
     sSetName = "Vestments of Rage";
    }
 if (GetResRef(oItem)=="sd_barb_s1_5")
    {
     sName = "Conan's Footstraps";
     sSetName = "Vestments of Rage";
    }
 if (GetResRef(oItem)=="sd_barb_s1_6")
    {
     sName = "Conan's Wriststrap";
     sSetName = "Vestments of Rage";
    }

SetLocalInt(oItem, "iSetNum", 6);
SetLocalString(oItem, "sSet", sSetName);
SetLocalString(oItem, "sName", sName);

sID = sSetName+"_acq";
SetLocalInt(oPC, sID, iPieces);

if (iFlag==1){
    sID = sSetName+"_equ";
    SetLocalInt(oPC, sID, iPieces);
   }

UpdateName(oPC, oItem, iPieces, 6, sSetName);


if (iFlag==1){
if (sSetName=="Dorian's Battlegear")DoriansBattlegearEquip(oPC, iPieces, 0);
if (sSetName=="Mystra's Rainment")MystrasRainmentEquip(oPC, iPieces, 0);
if (sSetName=="Thera's Vestments")TherasVestmentsEquip(oPC, iPieces, 0);
if (sSetName=="Shinobi's Garb")ShinobisGarbEquip(oPC, iPieces, 0);
if (sSetName=="Benedict's Herald")BenedictsHeraldEquip(oPC, iPieces, 0);
if (sSetName=="Armor of Divinity")ArmorOfDivinityEquip(oPC, iPieces, 0);
if (sSetName=="Soothsayer's Regalia")SoothsayersRegaliaEquip(oPC, iPieces, 0);
if (sSetName=="Robes of Enlightenment")RobesOfEnlightenmentEquip(oPC, iPieces, 0);
if (sSetName=="Vestments of Rage")VestmentsofRageEquip(oPC, iPieces, 0);}

/////////////////////////////////////
//: Debugging
//: SendMessageToPC(oPC, IntToString(iPieces));
}


void main()
{
object oPC = OBJECT_SELF;
object oItem;
int iPieces = 0;
string sSocks, sName, sID;

SD_REMOVE(oPC);

// check item slots for socketed items

if (GetTag(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC))== "sd_set_item")
    {++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_CHEST, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_HEAD, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_HEAD, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_NECK, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_NECK, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_BELT, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_BELT, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_BOLTS, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_BOLTS, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_ARROWS, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_ARROWS, oPC), iPieces, 1);
    }
if (GetTag(GetItemInSlot(INVENTORY_SLOT_ARMS, oPC))== "sd_set_item")
    {
     ++iPieces;
     RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_ARMS, oPC), iPieces, 1);
     }

// check inventory for set items
oItem = GetFirstItemInInventory(oPC);

while (GetIsObjectValid(oItem))
      {
       if (GetTag(oItem)=="sd_set_item")
          {
           ++iPieces;
           RE_SOCKET(oPC, oItem, iPieces, 0);
          }
       oItem = GetNextItemInInventory(oPC);
      }



string sMess = ColorString("class item-sets system ", 255, 215, 0);
sMess += ColorString("[loaded successfully]", 0, 255, 255);
SendMessageToPC(oPC, sMess);

return;
}

