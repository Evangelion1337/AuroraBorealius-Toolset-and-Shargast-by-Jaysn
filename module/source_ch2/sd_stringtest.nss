const string COLORTOKEN = "                  ##################$%&'()*+,-./0123456789:;;==?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[[]^_`abcdefghijklmnopqrstuvwxyz{|}~~ÄÅÇÉÑÖÜáàâäãåçéèêëíìîïñóòôöõúùûü°°¢£§•¶ß®©™´¨¨ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛˛";

string ColorString(string sText, int nRed=255, int nGreen=255, int nBlue=255)
{
    return "<c" + GetSubString(COLORTOKEN, nRed, 1) + GetSubString(COLORTOKEN, nGreen, 1) + GetSubString(COLORTOKEN, nBlue, 1) + ">" + sText + "</c>";
}


void RE_SOCKET(object oPC, object oItem)
{
int iLength, iStart, iVal, iAmt;
string sSocks, sGem, i1, i2, i3, i4, i5, i6, i7, i8;
string sName = GetName(oItem);

iLength = GetStringLength(sName);
sSocks = GetSubString(sName, iLength-6, 1);
//SendMessageToPC(oPC, sName + " has " + sSocks + " sockets");
iVal = StringToInt(sSocks);
SetLocalInt(oItem, "SOCKET_SLOTS", iVal);
}

void RE_GEM(object oPC, object oItem)
{
 string sName, sType1;
 int rVal, iType1, iType2;

 rVal = 0;
 sName = GetName(oItem);

 // Misc ability gems

 if (FindSubString(sName, "Vengeful")>=0)    iType1 = 36;
 if (FindSubString(sName, "Deadly")>=0)      iType1 = 43;
 if (FindSubString(sName, "Unstoppable")>=0) iType1 = 75;
 if (FindSubString(sName, "Slippery")>=0)    iType1 = 38;
 if (FindSubString(sName, "Speedy")>=0)      iType1 = 35;
 if (FindSubString(sName, "Arcane")>=0)      iType1 = 39;
 if (FindSubString(sName, "Living")>=0)      iType1 = 51;
 if (FindSubString(sName, "Feeding")>=0)     iType1 = 67;
 if (FindSubString(sName, "Cracked")>=0)     iType1 = 888;


 // Save Gems
 if (FindSubString(sName,"Resilient")>=0){iType1 = 40; iType2 = 1;
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Unwavering")>=0){iType1 = 40; iType2 = 2;
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Reactive")>=0){iType1 = 40; iType2 = 3;
     rVal = StringToInt(GetSubString(sName, 7, 1));}

 //  Attack Gems

 if (FindSubString(sName,"Power")>=0){iType1 = 6;
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Aggressive")>=0){iType1 = 56;
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Pegasus")>=0){iType1 = 45;
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"AC")>=0){iType1 = 1;
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Brutal")>=0){iType1 = 74;}

 // Ability bonus gems

 if (FindSubString(sName,"Brawny")>=0){iType1 = 0;
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Deft")>=0){iType1 = 1;
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Wise")>=0){iType1 = 4;
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Hardy")>=0){iType1 = 2;
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Clever")>=0){iType1 = 3;
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Charming")>=0){iType1 = 5;
      rVal = StringToInt(GetSubString(sName, 7, 1));}

 // Damage bonus gems

  if (FindSubString(sName,"Corrosive")>=0){iType1 = 16; iType2 = 6;}
  if (FindSubString(sName,"Thumping")>=0){iType1 = 16; iType2 = 0;}
  if (FindSubString(sName,"Ice")>=0){iType1 = 16; iType2 = 7;}
  if (FindSubString(sName,"Holy")>=0){iType1 = 16; iType2 = 8;}
  if (FindSubString(sName,"Zapping")>=0){iType1 = 16; iType2 = 9;}
  if (FindSubString(sName,"Scorching")>=0){iType1 = 16; iType2 = 10;}
  if (FindSubString(sName,"Magical")>=0){iType1 = 16; iType2 = 5;}
  if (FindSubString(sName,"Evil")>=0){iType1 = 16; iType2 = 11;}
  if (FindSubString(sName,"Impaling")>=0){iType1 = 16; iType2 = 1;}
  if (FindSubString(sName,"Benevolent")>=0){iType1 = 16; iType2 = 12;}
  if (FindSubString(sName,"Slicing")>=0){iType1 = 16; iType2 = 2;}
  if (FindSubString(sName,"Booming")>=0){iType1 = 16; iType2 = 13;}
  if (FindSubString(sName,"Regeneration")>=0){iType1 = 51;}
  if (FindSubString(sName,"Vamp Regen")>=0){iType1 = 67;}

 // Damage Res Gems

  if (FindSubString(sName, "Alkaline")>=0) {iType1 = 23; iType2 = 6;}
  if (FindSubString(sName, "Solid")>=0){iType1 = 23; iType2 = 0;}
  if (FindSubString(sName, "Warm")>=0){iType1 = 23; iType2 = 7;}
  if (FindSubString(sName, "Absolusion")>=0){iType1 = 23; iType2 = 8;}
  if (FindSubString(sName, "Grounding")>=0){iType1 = 23; iType2 = 9;}
  if (FindSubString(sName, "Dragonscale")>=0){iType1 = 23; iType2 = 10;}
  if (FindSubString(sName, "Mantle")>=0){iType1 = 23; iType2 = 5;}
  if (FindSubString(sName, "Order")>=0){iType1 = 23; iType2 = 11;}
  if (FindSubString(sName, "Dense")>=0){iType1 = 23; iType2 = 1;}
  if (FindSubString(sName, "Chaos")>=0){iType1 = 23; iType2 = 12;}
  if (FindSubString(sName, "Mesh")>=0){iType1 = 23; iType2 = 2;}
  if (FindSubString(sName, "Dampening")>=0){iType1 = 23; iType2 = 13;}

  SetLocalInt(oItem, "IP_TYPE", iType1);
  SetLocalInt(oItem, "IP_SUBTYPE", iType2);
  if (rVal>0)SetLocalInt(oItem, "IP_VALUE", rVal);
}


void main()
{
object oPC = OBJECT_SELF;
object oItem;
int iLength, iStart, iVal, iAmt;
string sSocks, sName;

// check item slots for socketed items

if (GetTag(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_HEAD, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_HEAD, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_NECK, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_NECK, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_BELT, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_BELT, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_BOLTS, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_BOLTS, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_ARROWS, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_ARROWS, oPC));

if (GetTag(GetItemInSlot(INVENTORY_SLOT_ARMS, oPC))== "sf_socket_item")
    RE_SOCKET(oPC, GetItemInSlot(INVENTORY_SLOT_ARMS, oPC));

// check inventory for socketed items
oItem = GetFirstItemInInventory(oPC);
while (GetIsObjectValid(oItem))
      {
       if (GetTag(oItem)=="sf_socket_item")
          {
           RE_SOCKET(oPC, oItem);
          }
       if (GetResRef(oItem)=="sd_rune"||
           GetResRef(oItem)=="sd_rune2"||
           GetResRef(oItem)=="sd_rune3")
          {
           RE_GEM(oPC, oItem);
          }
       oItem = GetNextItemInInventory(oPC);
      }
string sMess = ColorString("Socketed items system ", 255, 215, 0);
sMess += ColorString("[loaded successfully]", 0, 255, 255);

SendMessageToPC(oPC, sMess);
return;
}

