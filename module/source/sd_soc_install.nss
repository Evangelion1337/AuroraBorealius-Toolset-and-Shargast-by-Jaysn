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
SetLocalInt(oItem, "SOCKETS",iVal);
}

void RE_GEM(object oPC, object oItem)
{
 string sName, sType1;
 int rVal;

 sName = GetName(oItem);

 // Misc ability gems

 if (FindSubString(sName, "Vengeful")>=0)    sType1 = "HOLY_AVENGER";
 if (FindSubString(sName, "Deadly")>=0)      sType1 = "KEEN";
 if (FindSubString(sName, "Unstoppable")>=0) sType1 = "FREEDOM";
 if (FindSubString(sName, "Slippery")>=0)    sType1 = "IMPROVED_EVASION";
 if (FindSubString(sName, "Speedy")>=0)      sType1 = "HASTE";
 if (FindSubString(sName, "Ocular")>=0)      sType1 = "TRUE_SEEING";


 //  Attack Gems

 if (FindSubString(sName,"Enhancement")>=0){sType1 = "ENHANCEMENT_BONUS";
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Attack")>=0){sType1 = "ATTACK_BONUS";
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"AC")>=0){sType1 = "AC_BONUS";
     rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Brutal")>=0){sType1 = "MASSIVE_CRITICAL";
     rVal = StringToInt(GetSubString(sName, 7, 1));}

 // Ability bonus gems

 if (FindSubString(sName,"Mighty")>=0){sType1 = "STRENGTH_ABILITY_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Deft")>=0){sType1 = "DEXTERITY_ABILITY_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Wise")>=0){sType1 = "WISDOM_ABILITY_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Hardy")>=0){sType1 = "CONSTITUTION_ABILITY_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Clever")>=0){sType1 = "INTELLIGENCE_ABILITY_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
 if (FindSubString(sName,"Charming")>=0){sType1 = "CHARISMA_ABILITY_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}


 // Damage bonus gems

  if (FindSubString(sName,"Corrosive")>=0){sType1 = "ACID_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Thumping")>=0){sType1 = "BLUDGEONING_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Ice")>=0){sType1 = "COLD_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Holy")>=0){sType1 = "DIVINE_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Zapping")>=0){sType1 = "ELECTIRCAL_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Scorching")>=0){sType1 = "FIRE_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Magical")>=0){sType1 = "MAGICAL_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Evil")>=0){sType1 = "NEGATIVE_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Impaling")>=0){sType1 = "PIERCING_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Benevolent")>=0){sType1 = "POSITIVE_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Slicing")>=0){sType1 = "SLASHING_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Booming")>=0){sType1 = "SONIC_DAMAGE_BONUS";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Regeneration")>=0){sType1 = "REGENERATION";
      rVal = StringToInt(GetSubString(sName, 7, 1));}
  if (FindSubString(sName,"Vamp Regen")>=0){sType1 = "VAMPIRIC_REGENERATION";
      rVal = StringToInt(GetSubString(sName, 7, 1));}

 // Damage Res Gems

  if (FindSubString(sName, "Alkaline")>=0)
              {sType1 = "ACID_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
  if (FindSubString(sName, "Solid")>=0)
              {sType1 = "BLUDGEONING_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
  if (FindSubString(sName, "Warm")>=0)
              {sType1 = "COLD_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
  if (FindSubString(sName, "Absolvsion")>=0)
              {sType1 = "DIVINE_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
  if (FindSubString(sName, "Grounding")>=0)
              {sType1 = "ELECTRICAL_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
  if (FindSubString(sName, "Cool")>=0)
              {sType1 = "FIRE_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
  if (FindSubString(sName, "Mantle")>=0)
              {sType1 = "MAGICAL_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
   if (FindSubString(sName, "Bright")>=0)
              {sType1 = "NEGATIVE_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
   if (FindSubString(sName, "Shell")>=0)
              {sType1 = "PIERCING_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
   if (FindSubString(sName, "Malevolent")>=0)
              {sType1 = "POSITIVE_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
  if (FindSubString(sName, "Mesh")>=0)
              {sType1 = "SLASHING_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}
  if (FindSubString(sName, "Dampening")>=0)
              {sType1 = "SONIC_DAMAGE_RESISTANCE";
               if (GetSubString(sName, 9, 1)==" ")rVal = StringToInt(GetSubString(sName, 8, 1));
               else rVal = StringToInt(GetSubString(sName, 8, 2));}


           SetLocalString(oItem, "GEM_TYPE", sType1);
           SetLocalInt(oItem, "AMOUNT", rVal);
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

