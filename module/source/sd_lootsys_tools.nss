#include "x2_inc_itemprop"
#include "nw_i0_generic"

//////////////////////////////////////////////////////////
//: Constants
//:
//:note* See line 2782 of "sd_lootsystem" for specific item droprate configuration

const int LUCK_CHANCE = 5000; // 1 in x chance getting a much better item (0 for off)
const int DROP_RATE = 4;      // % chance or loot drop
const int CHANCE_WORN = 15;   // % chance of worn item (0 for off)
const int CHANCE_BROKEN = 5;  // % chance of broken item (0 for off)
const int CHANCE_WFOCUS = 20; // % chance of weapon drop based on weap focus

// Generates a random weapon
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the weapon
// iRange = the quality of the weapon: 1=lowest 5=highest
// SockChance = a % chance for the generated weapon to be socketed
// DamBroke = a switch to disable chance of damaged/broken weapon: 0=on 1=off
void DropWeapon(object oMob, object oSack, int iRange, int SockChance, int DamBroke);

// Generates random chest armor
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the armor
// iRange = the quality of the armor: 1=lowest 5=highest
// SockChance = a % chance for the generated armor to be socketed
// DamBroke = a switch to disable chance of damaged/broken armor: 0=on 1=off
void DropArmor(object oMob, object oSack, int iRange, int SockChance, int DamBroke);

// Generates a random shield
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the shield
// iRange = the quality of the shield: 1=lowest 5=highest
// SockChance = a % chance for the generated shield to be socketed
// DamBroke = a switch to disable chance of damaged/broken shield: 0=on 1=off
void DropShield(object oMob, object oSack, int iRange, int SockChance, int DamBroke);

// Generates random monk gloves
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the gloves
// iRange = the quality of the gloves: 1=lowest 5=highest
// SockChance = a % chance for the generated gloves to be socketed
// DamBroke = a switch to disable chance of damaged/broken gloves: 0=on 1=off
void DropMonkGloves(object oMob, object oSack, int iRange, int SockChance, int DamBroke);

// Generates a random magic item (i.e. boots, helm, amulet, ring, belt, bracer)
// ============================================================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the item
// iRange = the quality of the item: 1=lowest 5=highest
// SockChance = a % chance for the generated item to be socketed
// DamBroke = a switch to disable chance of damaged/broken item: 0=on 1=off
void DropMagicItem(object oMob, object oSack, int iRange, int SockChance, int DamBroke);

// Generates a random socket gem
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the gem
// iRange = the quality of the gem: 1=lowest 5=highest
void DropGem(object oMob, object oSack, int iRange);

// Generates random ranged ammo (only arrows & bolts)
// ==================================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the ammo
// iRange = the quality of the ammo: 1=lowest 5=highest
void DropAmmo(object oMob, object oSack, int iRange);

// Generates a random scroll
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the scroll
// iRange = the quality of the scroll: 1=lowest 5=highest
// note* this is based on the gold-value of the scroll
void DropScroll(object oMob, object oSack, int iRange);

// Generates a random potion
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the potion
// iStack = Stacksize
void DropPot(object oMob, object oSack, int iStack);

// Generates a random misc item (i.e. bag)
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the misc
void DropMisc(object oMob, object oSack);

// Generates a random rod or wand
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the rod or wand
void DropRodWand(object oMob, object oSack);

// Generates random gold
// ==================================================
// oMob = the creature that just died
// note* the gold amount will be based on the creature's level using the below formula
// Gold = (d20()*Creature LVL)+(15*Creature LVL)+iBonus
// oSack = the object into which you will spawn the ammo
// iBonus = additional gold to be added to the tally
void DropGold(object oMob, object oSack, int iBonus);

// Drop randomly chosen and generated loot & some gold
// ===================================================
// *This is the main call function of the sd lootsystem
// oMob = the creature that just died (the loot dropped is based on their class & level)
// oSack = the object into which you will spawn the loot
void sd_droploot (object oMob, object oSack);

// Generates a random alchemy recipe
// =======================================
// oMob = the creature that just died
// oSack = the object into which you will spawn the recipe
// iRange = the quality of the item: 1=lowest 5=highest
void DropAlchemyRecipe(object oMob, object oSack, int iRange);





const string COLORTOKEN ="                  ##################$%&'()*+,-./0123456789:;;==?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[[]^_`abcdefghijklmnopqrstuvwxyz{|}~~ÄÅÇÉÑÖÜáàâäãåçéèêëíìîïñóòôöõúùûü°°¢£§•¶ß®©™´¨¨ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛˛";

string ColorString(string sText, int nRed=255, int nGreen=255, int nBlue=255)
{
    return "<c" + GetSubString(COLORTOKEN, nRed, 1) + GetSubString(COLORTOKEN, nGreen, 1) + GetSubString(COLORTOKEN, nBlue, 1) + ">" + sText + "</c>";
}

void SetQuality(object oItem, string sIName, int iQual)
{
 string sName;
 switch(iQual)
       {
        case 0: sName = ColorString("Inferior "+sIName,255, 255, 255); break;
        case 1: sName = ColorString("Superior "+sIName,255, 255, 255); break;
        case 2: sName = ColorString("Enchanted "+sIName, 0, 255, 0); break;
        case 3: sName = ColorString("Powerful "+sIName, 65, 105, 225); break;
        case 4: sName = ColorString("Champion's "+sIName, 102, 205, 170); break;
        case 5: sName = ColorString("Epic "+sIName, 128, 0, 218); break;
        case 6: sName = ColorString("Heroic "+sIName, 255, 255, 0 ); break;
        case 7: sName = ColorString("Legendary "+sIName, 218, 165, 32 ); break;
        case 8: sName = ColorString("Titan's "+sIName, 255, 0, 255 ); break;
       }
  SetName(oItem, sName);
}

void SetThreatLevel(object oMob)
{
 int iHD = GetHitDice(OBJECT_SELF);
 int iRange;
 string sName;
 string cName = GetName(oMob);

 if (iHD>0&&iHD<6)iRange=1;    // lvl 1-5
 if (iHD>5&&iHD<11)iRange=2;   // lvl 6-10
 if (iHD>10&&iHD<21)iRange=3;  // lvl 11-20
 if (iHD>20&&iHD<31)iRange=4;  // lvl 21-30
 if (iHD>30&&iHD<41)iRange=5;  // lvl 31-40

 switch(iRange)
       {
        case 1: sName = ColorString(cName,255, 255, 255); break;
        case 2: sName = ColorString(cName,189, 183, 107); break;
        case 3: sName = ColorString(cName,218, 165, 32); break;
        case 4: sName = ColorString(cName,210, 105, 30); break;
        case 5: sName = ColorString(cName,255, 0, 0); break;
       }
 if (GetLocalInt(OBJECT_SELF, "BOSS")==1)sName = ColorString(cName,255, 255, 0);
 SetName(oMob, sName);
}

void NameSack(object oSack)
{
 string sName = GetName(OBJECT_SELF);
 sName+= " Corpse";
 SetName(oSack, sName);
}

void InvClear (object oMob)
{
 object oItem = GetFirstItemInInventory(oMob);
 while (GetIsObjectValid(oItem))
       {
        if (GetPlotFlag(oItem)==FALSE)DestroyObject(oItem);
        oItem = GetNextItemInInventory(oMob);
       }
}
void LootClear (object oMob)
{
 object oItem = GetFirstItemInInventory(oMob);
 while (GetIsObjectValid(oItem))
       {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oMob);
       }
DestroyObject(oMob);
}


void DropScroll(object oMob, object oSack, int iRange)
{
 string sType;
 int nRandom = Random(16) + 1;
 int iRoll;

 if (iRange==1)         // scrolls up to max value of 300
    {
     iRoll = d100();
     switch (iRoll)
        {
        case 1: sType = "x1_it_sparscr002";break;
        case 2: sType = "nw_it_sparscr107";break;
        case 3: sType = "x1_it_sparscr102";break;
        case 4: sType = "x1_it_spdvscr101";break;
        case 5: sType = "x2_it_spdvscr202";break;
        case 6: sType = "x2_it_spdvscr103";break;
        case 7: sType = "x2_it_spdvscr102";break;
        case 8: sType = "nw_it_sparscr211";break;
        case 9: sType = "x1_it_spdvscr202";break;
        case 10: sType = "nw_it_sparscr212";break;
        case 11: sType = "nw_it_sparscr112";break;
        case 12: sType = "x1_it_spdvscr107";break;
        case 13: sType = "nw_it_sparscr213";break;
        case 14: sType = "x2_it_sparscr207";break;
        case 15: sType = "nw_it_sparscr107";break;
        case 16: sType = "nw_it_spdvscr202";break;
        case 17: sType = "nw_it_sparscr217";break;
        case 18: sType = "x2_it_sparscr206";break;
        case 19: sType = "nw_it_sparscr110";break;
        case 20: sType = "x2_it_sparscr201";break;
        case 21: sType = "x1_it_spdvscr301";break;
        case 22: sType = "x2_it_spdvscr104";break;
        case 23: sType = "x2_it_spdvscr001";break;
        case 24: sType = "x2_it_spdvscr203";break;
        case 25: sType = "x2_it_spdvscr308";break;
        case 26: sType = "nw_it_sparscr206";break;
        case 27: sType = "nw_it_sparscr003";break;
        case 28: sType = "x2_it_spdvscr101";break;
        case 29: sType = "x2_it_sparscr202";break;
        case 30: sType = "x1_it_spdvscr102";break;
        case 31: sType = "x2_it_spdvscr105";break;
        case 32: sType = "nw_it_sparscr219";break;
        case 33: sType = "x1_it_sparscr003";break;
        case 34: sType = "nw_it_sparscr215";break;
        case 35: sType = "nw_it_sparscr101";break;
        case 36: sType = "x2_it_spdvscr106";break;
        case 37: sType = "x1_it_spdvscr103";break;
        case 38: sType = "x1_it_sparscr101";break;
        case 39: sType = "x1_it_sparscr101";break;
        case 40: sType = "x2_it_sparscr305";break;
        case 41: sType = "x1_it_spdvscr205";break;
        case 42: sType = "x2_it_sparscr205";break;
        case 43: sType = "x1_it_sparscr001";break;
        case 44: sType = "nw_it_sparscr220";break;
        case 45: sType = "x2_it_sparscr203";break;
        case 46: sType = "nw_it_sparscr208";break;
        case 47: sType = "nw_it_sparscr209";break;
        case 48: sType = "nw_it_sparscr103";break;
        case 49: sType = "x2_it_spdvscr204";break;
        case 50: sType = "nw_it_sparscr308";break;
        case 51: sType = "x2_it_sparscr101";break;
        case 52: sType = "x2_it_sparscr104";break;
        case 53: sType = "nw_it_sparscr106";break;
        case 54: sType = "x1_it_spdvscr104";break;
        case 55: sType = "x1_it_spdvscr001";break;
        case 56: sType = "x1_it_spdvscr201";break;
        case 57: sType = "nw_it_sparscr207";break;
        case 58: sType = "x2_it_sparscr102";break;
        case 59: sType = "nw_it_sparscr216";break;
        case 60: sType = "nw_it_sparscr218";break;
        case 61: sType = "nw_it_spdvscr201";break;
        case 62: sType = "nw_it_sparscr004";break;
        case 63: sType = "nw_it_sparscr104";break;
        case 64: sType = "x1_it_spdvscr106";break;
        case 65: sType = "nw_it_sparscr109";break;
        case 66: sType = "x2_it_sparscr105";break;
        case 67: sType = "nw_it_sparscr202";break;
        case 68: sType = "nw_it_sparscr113";break;
        case 69: sType = "x1_it_spdvscr203";break;
        case 70: sType = "nw_it_sparscr221";break;
        case 71: sType = "nw_it_sparscr102";break;
        case 72: sType = "x2_it_sparscral";break;
        case 73: sType = "nw_it_sparscr111";break;
        case 74: sType = "nw_it_sparscr002";break;
        case 75: sType = "x2_it_spdvscr107";break;
        case 76: sType = "x2_it_spdvscr205";break;
        case 77: sType = "nw_it_sparscr201";break;
        case 78: sType = "nw_it_sparscr001";break;
        case 79: sType = "x2_it_spdvscr108";break;
        case 80: sType = "nw_it_sparscr210";break;
        case 81: sType = "x2_it_sparscr103";break;
        case 82: sType = "x1_it_sparscr103";break;
        case 83: sType = "x1_it_spdvscr105";break;
        case 84: sType = "nw_it_spdvscr203";break;
        case 85: sType = "nw_it_sparscr108";break;
        case 86: sType = "nw_it_spdvscr204";break;
        case 87: sType = "x2_it_sparscr204";break;
        case 88: sType = "nw_it_sparscr105";break;
        case 89: sType = "nw_it_sparscr203";break;
        case 90: sType = "x1_it_sparscr202";break;
        case 91: sType = "x1_it_sparscr104";break;
        case 92: sType = "nw_it_sparscr214";break;
        case 93: sType = "x2_it_spdvscr002";break;
        case 94: sType = "nw_it_sparscr204";break;
       }
    }
 if (iRange==2)
    {
     iRoll = d100();    /// scrolls valued 540-1621
     switch (iRoll)
        {
        case 1: sType = "nw_it_sparscr509";break;
        case 2: sType = "x2_it_spdvscr508";break;
        case 3: sType = "x2_it_sparscr501";break;
        case 4: sType = "x2_it_spdvscr501";break;
        case 5: sType = "nw_it_sparscr414";break;
        case 6: sType = "x1_it_sparscr502";break;
        case 7: sType = "x2_it_spdvscr307";break;
        case 8: sType = "nw_it_sparscr405";break;
        case 9: sType = "x2_it_spdvscr504";break;
        case 10: sType = "nw_it_sparscr307";break;
        case 11: sType = "nw_it_sparscr502";break;
        case 12: sType = "nw_it_sparscr507";break;
        case 13: sType = "nw_it_sparscr406";break;
        case 14: sType = "nw_it_sparscr411";break;
        case 15: sType = "x2_it_spdvscr402";break;
        case 16: sType = "x2_it_spdvscr305";break;
        case 17: sType = "x2_it_spdvscr403";break;
        case 18: sType = "nw_it_sparscr501";break;
        case 19: sType = "nw_it_sparscr301";break;
        case 20: sType = "x1_it_sparscr301";break;
        case 21: sType = "x2_it_spdvscr404";break;
        case 22: sType = "x2_it_spdvscr309";break;
        case 23: sType = "nw_it_sparscr416";break;
        case 24: sType = "nw_it_sparscr503";break;
        case 25: sType = "nw_it_sparscr608";break;
        case 26: sType = "nw_it_sparscr418";break;
        case 27: sType = "x2_it_spdvscr509";break;
        case 28: sType = "nw_it_sparscr413";break;
        case 29: sType = "nw_it_sparscr504";break;
        case 30: sType = "nw_it_sparscr309";break;
        case 31: sType = "x1_it_sparscr501";break;
        case 32: sType = "nw_it_sparscr304";break;
        case 33: sType = "x1_it_spdvscr403";break;
        case 34: sType = "x2_it_spdvscr405";break;
        case 35: sType = "x2_it_spdvscr306";break;
        case 36: sType = "x2_it_sparscr701";break;
        case 37: sType = "nw_it_sparscr602";break;
        case 38: sType = "x1_it_spdvscr303";break;
        case 39: sType = "x2_it_sparscr304";break;
        case 40: sType = "nw_it_sparscr508";break;
        case 41: sType = "x1_it_sparscr303";break;
        case 42: sType = "x2_it_spdvscr406";break;
        case 43: sType = "nw_it_sparscr312";break;
        case 44: sType = "x2_it_spdvscr505";break;
        case 45: sType = "x2_it_spdvscr302";break;
        case 46: sType = "nw_it_sparscr505";break;
        case 47: sType = "x2_it_spdvscr401";break;
        case 48: sType = "nw_it_sparscr408";break;
        case 49: sType = "x1_it_spdvscr501";break;
        case 50: sType = "x2_it_spdvscr301";break;
        case 51: sType = "x1_it_spdvscr401";break;
        case 52: sType = "x1_it_spdvscr302";break;
        case 53: sType = "x2_it_spdvscr310";break;
        case 54: sType = "nw_it_sparscr314";break;
        case 55: sType = "x1_it_sparscr401";break;
        case 56: sType = "x2_it_sparscr303";break;
        case 57: sType = "x2_it_sparscr602";break;
        case 58: sType = "nw_it_sparscr511";break;
        case 59: sType = "nw_it_sparscr512";break;
        case 60: sType = "nw_it_sparscr417";break;
        case 61: sType = "nw_it_sparscr513";break;
        case 62: sType = "nw_it_sparscr310";break;
        case 63: sType = "nw_it_sparscr302";break;
        case 64: sType = "x2_it_sparscrmc";break;
        case 65: sType = "x2_it_spdvscr304";break;
        case 66: sType = "x1_it_spdvscr402";break;
        case 67: sType = "x2_it_sparscr301";break;
        case 68: sType = "x2_it_sparscr502";break;
        case 69: sType = "nw_it_sparscr506";break;
        case 70: sType = "nw_it_sparscr401";break;
        case 71: sType = "x2_it_spdvscr502";break;
        case 72: sType = "nw_it_sparscr315";break;
        case 73: sType = "x2_it_spdvscr311";break;
        case 74: sType = "nw_it_spdvscr402";break;
        case 75: sType = "x1_it_spdvscr502";break;
        case 76: sType = "nw_it_sparscr409";break;
        case 77: sType = "x2_it_spdvscr407";break;
        case 78: sType = "nw_it_sparscr415";break;
        case 79: sType = "x2_it_spdvscr312";break;
        case 80: sType = "x1_it_spdvscr305";break;
        case 81: sType = "nw_it_spdvscr501";break;
        case 82: sType = "nw_it_spdvscr301";break;
        case 83: sType = "nw_it_sparscr402";break;
        case 84: sType = "nw_it_spdvscr401";break;
        case 85: sType = "x2_it_sparscr302";break;
        case 86: sType = "nw_it_sparscr410";break;
        case 87: sType = "x2_it_spdvscr506";break;
        case 88: sType = "nw_it_sparscr313";break;
        case 89: sType = "x2_it_spdvscr507";break;
        case 90: sType = "x1_it_spdvscr304";break;
        case 91: sType = "nw_it_sparscr305";break;
        case 92: sType = "nw_it_sparscr403";break;
        case 93: sType = "nw_it_sparscr306";break;
        case 94: sType = "nw_it_sparscr404";break;
        case 95: sType = "nw_it_sparscr510";break;
        case 96: sType = "x2_it_sparscr902";break;
        case 97: sType = "nw_it_sparscr606";break;
        case 98: sType = "x2_it_spdvscr503";break;
        case 99: sType = "nw_it_sparscr407";break;
        case 100: sType = "x1_it_sparscr302";break;
       }
    }
 if (iRange==3)
    {
     iRoll = d100();// scrolls valued 2400-3200
     switch (iRoll)
        {
        case 1: sType = "nw_it_sparscr603";break;
        case 2: sType = "x1_it_spdvscr701";break;
        case 3: sType = "x1_it_spdvscr601";break;
        case 4: sType = "x1_it_sparscr602";break;
        case 5: sType = "x1_it_sparscr701";break;
        case 6: sType = "x2_it_spdvscr603";break;
        case 7: sType = "nw_it_sparscr607";break;
        case 8: sType = "nw_it_sparscr610";break;
        case 9: sType = "nw_it_sparscr707";break;
        case 10: sType = "x1_it_spdvscr605";break;
        case 11: sType = "x1_it_spdvscr702";break;
        case 12: sType = "x2_it_spdvscr601";break;
        case 13: sType = "nw_it_sparscr704";break;
        case 14: sType = "x1_it_spdvscr703";break;
        case 15: sType = "x1_it_sparscr601";break;
        case 16: sType = "x1_it_spdvscr604";break;
        case 17: sType = "x2_it_sparscr503";break;
        case 18: sType = "nw_it_sparscr708";break;
        case 19: sType = "x1_it_spdvscr704";break;
        case 20: sType = "x1_it_sparscr605";break;
        case 21: sType = "nw_it_sparscr601";break;
        case 22: sType = "nw_it_spdvscr701";break;
        case 23: sType = "x1_it_spdvscr602";break;
        case 24: sType = "x2_it_spdvscr606";break;
        case 25: sType = "nw_it_sparscr612";break;
        case 26: sType = "nw_it_sparscr613";break;
        case 27: sType = "x2_it_spdvscr604";break;
        case 28: sType = "x2_it_spdvscr605";break;
        case 29: sType = "x1_it_sparscr603";break;
        case 30: sType = "nw_it_sparscr611";break;
        case 31: sType = "x1_it_spdvscr603";break;
        case 32: sType = "nw_it_sparscr604";break;
        case 33: sType = "nw_it_sparscr702";break;
        case 34: sType = "nw_it_sparscr706";break;
        case 35: sType = "nw_it_sparscr802";break;
        case 36: sType = "x2_it_spdvscr702";break;
        case 37: sType = "nw_it_spdvscr702";break;
        case 38: sType = "nw_it_sparscr609";break;
        case 39: sType = "x2_it_sparscr703";break;
        case 40: sType = "nw_it_sparscr701";break;
        case 41: sType = "x1_it_sparscr604";break;
        case 42: sType = "x2_it_spdvscr602";break;
        case 43: sType = "nw_it_sparscr605";break;
        case 44: sType = "nw_it_sparscr703";break;
        case 45: sType = "x2_it_spdvscr803";break;
        case 46: sType = "nw_it_sparscr614";break;
        case 47: sType = "nw_it_sparscr614";break;
        case 48: sType = "x2_it_sparscr601";break;
        case 49: sType = "x2_it_spdvscr701";break;
        case 50: sType = "nw_it_sparscr603";break;
        case 51: sType = "x1_it_spdvscr701";break;
        case 52: sType = "x1_it_spdvscr601";break;
        case 53: sType = "x1_it_sparscr602";break;
        case 54: sType = "x1_it_sparscr701";break;
        case 55: sType = "x2_it_spdvscr603";break;
        case 56: sType = "nw_it_sparscr607";break;
        case 57: sType = "nw_it_sparscr610";break;
        case 58: sType = "nw_it_sparscr707";break;
        case 59: sType = "x1_it_spdvscr605";break;
        case 60: sType = "x1_it_spdvscr702";break;
        case 61: sType = "x2_it_spdvscr601";break;
        case 62: sType = "nw_it_sparscr704";break;
        case 63: sType = "x1_it_spdvscr703";break;
        case 64: sType = "x1_it_sparscr601";break;
        case 65: sType = "x1_it_spdvscr604";break;
        case 66: sType = "x2_it_sparscr503";break;
        case 67: sType = "nw_it_sparscr708";break;
        case 68: sType = "x1_it_spdvscr704";break;
        case 69: sType = "x1_it_sparscr605";break;
        case 70: sType = "nw_it_sparscr601";break;
        case 71: sType = "nw_it_spdvscr701";break;
        case 72: sType = "x1_it_spdvscr602";break;
        case 73: sType = "x2_it_spdvscr606";break;
        case 74: sType = "nw_it_sparscr612";break;
        case 75: sType = "nw_it_sparscr613";break;
        case 76: sType = "x2_it_spdvscr604";break;
        case 77: sType = "x2_it_spdvscr605";break;
        case 78: sType = "x1_it_sparscr603";break;
        case 79: sType = "nw_it_sparscr611";break;
        case 80: sType = "x1_it_spdvscr603";break;
        case 81: sType = "nw_it_sparscr604";break;
        case 82: sType = "nw_it_sparscr702";break;
        case 83: sType = "nw_it_sparscr706";break;
        case 84: sType = "nw_it_sparscr802";break;
        case 85: sType = "x2_it_spdvscr702";break;
        case 86: sType = "nw_it_spdvscr702";break;
        case 87: sType = "nw_it_sparscr609";break;
        case 88: sType = "x2_it_sparscr703";break;
        case 89: sType = "nw_it_sparscr701";break;
        case 90: sType = "x1_it_sparscr604";break;
        case 91: sType = "x2_it_spdvscr602";break;
        case 92: sType = "nw_it_sparscr605";break;
        case 93: sType = "nw_it_sparscr703";break;
        case 94: sType = "x2_it_spdvscr803";break;
        case 95: sType = "nw_it_sparscr614";break;
        case 96: sType = "nw_it_sparscr614";break;
        case 97: sType = "x2_it_sparscr601";break;
        case 98: sType = "x2_it_spdvscr701";break;
       }
    }
if (iRange==4||iRange==5)
    {
     iRoll = Random(40)+1;     // scrolls valued above 3200
     switch (iRoll)
        {
        case 1: sType = "nw_it_sparscr806";
        case 2: sType = "x2_it_spdvscr804";
        case 3: sType = "x1_it_sparscr801";
        case 4: sType = "x1_it_sparscr901";
        case 5: sType = "x2_it_sparscr901";
        case 6: sType = "x2_it_sparscr801";
        case 7: sType = "x1_it_spdvscr803";
        case 8: sType = "x1_it_spdvscr804";
        case 9: sType = "nw_it_sparscr905";
        case 10: sType = "x2_it_spdvscr901";
        case 11: sType = "nw_it_sparscr908";
        case 12: sType = "nw_it_sparscr902";
        case 13: sType = "nw_it_sparscr803";
        case 14: sType = "nw_it_sparscr912";
        case 15: sType = "nw_it_sparscr809";
        case 16: sType = "x2_it_spdvscr902";
        case 17: sType = "nw_it_sparscr804";
        case 18: sType = "nw_it_sparscr807";
        case 19: sType = "nw_it_sparscr806";
        case 20: sType = "x2_it_spdvscr801";
        case 21: sType = "nw_it_sparscr906";
        case 22: sType = "nw_it_sparscr801";
        case 23: sType = "nw_it_sparscr901";
        case 24: sType = "x2_it_spdvscr802";
        case 25: sType = "nw_it_sparscr903";
        case 26: sType = "nw_it_sparscr808";
        case 27: sType = "nw_it_sparscr910";
        case 28: sType = "x2_it_spdvscr903";
        case 29: sType = "nw_it_sparscr904";
        case 30: sType = "nw_it_sparscr805";
        case 31: sType = "x1_it_spdvscr802";
        case 32: sType = "nw_it_sparscr911";
        case 33: sType = "x1_it_spdvscr901";
        case 34: sType = "nw_it_sparscr909";
        case 35: sType = "nw_it_sparscr907";
        case 36: sType = "x1_it_spdvscr801";
        case 37: sType = "nw_it_sparscr906";
        case 38: sType = "nw_it_sparscr808";
        case 39: sType = "x2_it_sparscr801";
        case 40: sType = "x2_it_spdvscr804";
       }
   }

object oScroll =  CreateItemOnObject(sType, oSack, 1);
SetIdentified(oScroll, FALSE);
}

void DropAlchemyRecipe(object oMob, object oSack, int iRange)
{
 string sType;
 int iRoll;

 if (iRange==1)         //
    {
     iRoll = d10();
     switch (iRoll)
        {
        case 1: sType = "cm_alch_rec1";break;
        case 2: sType = "cm_alch_rec2";break;
        case 3: sType = "cm_alch_rec3";break;
        case 4: sType = "cm_alch_rec4";break;
        case 5: sType = "cm_alch_rec5";break;
        case 6: sType = "cm_alch_rec6";break;
        case 7: sType = "cm_alch_rec7";break;
        case 8: sType = "cm_alch_rec8";break;
        case 9: sType = "cm_alch_rec9";break;
        case 10: sType = "cm_alch_rec10";break;
       }
    }
 if (iRange==2)
    {
     iRoll = d10();    ///
     switch (iRoll)
        {
        case 1: sType = "cm_alch_rec1";break;
        case 2: sType = "cm_alch_rec2";break;
        case 3: sType = "cm_alch_rec3";break;
        case 4: sType = "cm_alch_rec4";break;
        case 5: sType = "cm_alch_rec5";break;
        case 6: sType = "cm_alch_rec6";break;
        case 7: sType = "cm_alch_rec7";break;
        case 8: sType = "cm_alch_rec8";break;
        case 9: sType = "cm_alch_rec9";break;
        case 10: sType = "cm_alch_rec10";break;
       }
    }
 if (iRange==3)
    {
     iRoll = d10();//
     switch (iRoll)
        {
        case 1: sType = "cm_alch_rec11";break;
        case 2: sType = "cm_alch_rec12";break;
        case 3: sType = "cm_alch_rec13";break;
        case 4: sType = "cm_alch_rec14";break;
        case 5: sType = "cm_alch_rec15";break;
        case 6: sType = "cm_alch_rec16";break;
        case 7: sType = "cm_alch_rec17";break;
        case 8: sType = "cm_alch_rec18";break;
        case 9: sType = "cm_alch_rec19";break;
        case 10: sType = "cm_alch_rec20";break;
       }
    }
if (iRange==4||iRange==5)
    {
     iRoll = d10();     //
     switch (iRoll)
        {
        case 1: sType = "cm_alch_rec21";break;
        case 2: sType = "cm_alch_rec22";break;
        case 3: sType = "cm_alch_rec23";break;
        case 4: sType = "cm_alch_rec24";break;
        case 5: sType = "cm_alch_rec25";break;
        case 6: sType = "cm_alch_rec26";break;
        case 7: sType = "cm_alch_rec27";break;
        case 8: sType = "cm_alch_rec28";break;
        case 9: sType = "cm_alch_rec29";break;
        case 10: sType = "cm_alch_rec30";break;
       }
   }

object oRecipe =  CreateItemOnObject(sType, oSack, 1);
SetIdentified(oRecipe, FALSE);
}

void DropPot(object oMod, object oSack, int iStack)
{
 string sPotion;

 int iDice = d10()+d10()+d10();
 switch (iDice)
        {
         case 1:sPotion = "dummy";  break;
         case 2:sPotion = "dummy";  break;
         case 3:sPotion = "nw_it_mpotion002";  break;
         case 4:sPotion = "nw_it_mpotion003";  break;
         case 5:sPotion = "nw_it_mpotion008";  break;
         case 6:sPotion = "nw_it_mpotion009";  break;
         case 7:sPotion = "nw_it_mpotion012";  break;
         case 8:sPotion = "nw_it_mpotion011";  break;
         case 9: sPotion = "nw_it_mpotion001" ; break;
         case 10: sPotion = "nw_it_mpotion002" ; break;
         case 11: sPotion = "nw_it_mpotion003" ; break;
         case 12: sPotion = "nw_it_mpotion004" ; break;
         case 13: sPotion = "nw_it_mpotion005" ; break;
         case 14: sPotion = "nw_it_mpotion006";  break;
         case 15: sPotion = "nw_it_mpotion007";  break;
         case 16: sPotion = "nw_it_mpotion008";  break;
         case 17: sPotion = "nw_it_mpotion009";  break;
         case 18: sPotion = "nw_it_mpotion010";  break;
         case 19: sPotion = "nw_it_mpotion011";  break;
         case 20: sPotion = "nw_it_mpotion012";  break;
         case 21: sPotion = "nw_it_mpotion013";  break;
         case 22: sPotion = "nw_it_mpotion014";  break;
         case 23: sPotion = "nw_it_mpotion015";  break;
         case 24: sPotion = "nw_it_mpotion016";  break;
         case 25: sPotion = "nw_it_mpotion017";  break;
         case 26: sPotion = "nw_it_mpotion018";  break;
         case 27: sPotion = "nw_it_mpotion019";  break;
         case 28: sPotion = "nw_it_mpotion020";  break;
         case 29: sPotion = "nw_it_mpotion002";  break;
         case 30: sPotion = "x2_it_mpotion001";  break;
        }
 CreateItemOnObject(sPotion, oSack, iStack);
}

void DropRodWand(object oMod, object oSack)
{
 string sType;

 int nRandom = Random(16) + 1;
 switch (nRandom)
        {
                       // rods

        case 1: sType = "nw_wmgmrd002";break;  //res
        case 2: sType = "nw_wmgmrd005";break;  //rev
        case 3: sType = "nw_wmgrd002";break;   // ghost
        case 4: sType = "nw_wmgmrd006";break;  // frost

                      // wands

        case 5: sType = "nw_wmgwn011";break;
        case 6: sType = "nw_wmgwn002";break;
        case 7: sType = "nw_wmgwn007";break;
        case 8: sType = "nw_wmgwn004";break;
        case 9: sType = "nw_wmgwn006";break;
        case 10: sType = "nw_wmgwn005";break;
        case 11: sType = "nw_wmgwn012";break;
        case 12: sType = "nw_wmgwn010";break;
        case 13: sType = "nw_wmgwn008";break;
        case 14: sType = "nw_wmgwn009";break;
        case 15: sType = "nw_wmgwn003";break;
        case 16: sType = "nw_wmgwn013";break;
        }
 CreateItemOnObject(sType, oSack, 1);
}

void DropMisc(object oMod, object oSack)
{
 string sName;

 int nDice = d10(3);
 switch (nDice)
        {
        case 1: sName = "nw_it_contain006"; break; //bag holding
        case 2: sName = "nw_it_contain005"; break;  //gmbag
        case 3: sName = "nw_it_contain003"; break;  //lmbag
        case 4: sName = "nw_it_contain004"; break;  //mbag
        case 5: sName = "nw_it_contain002"; break;  //mpouch
        case 6: sName = "nw_it_msmlmisc05"; break;  //healpearl
        case 7: sName = "nw_it_mmidmisc04"; break;  //scab bless
        case 8: sName = "x0_it_msmlmisc05"; break;  //earth elem
        case 9: sName = "x0_it_mmedmisc03"; break;  //harp
        case 10: sName = "x0_it_msmlmisc01"; break; //water elem
        case 11: sName = "x0_it_msmlmisc02"; break; //fire elem
        case 12: sName = "x0_it_mmedmisc01"; break; //shielding
        case 13: sName = "x0_it_mthnmisc21"; break; //air elem
        case 14: sName = "x0_it_mthnmisc19"; break; //bard lire
        case 15: sName = "x0_it_mthnmisc17"; break; // bard spls
        case 16: sName = "x0_it_mmedmisc02"; break; // bard spls
        case 17: sName = "x0_it_mthnmisc05"; break; // dust app
        case 18: sName = "x0_it_mthnmisc06"; break; // dust dissapp
        case 19: sName = "x0_it_mthnmisc13"; break; // sunbeam
        case 20: sName = "x0_it_mthnmisc15"; break; //
        case 21: sName = "x0_it_mthnmisc14"; break; // lath chal
        case 22: sName = "nw_it_mmidmisc01"; break; // harp charm
        case 23: sName = "nw_it_mmidmisc02"; break; // harp haunt
        case 24: sName = "nw_it_mmidmisc03"; break; // harp pand
        case 25: sName = "x0_it_msmlmisc06"; break; // horn good/evil
        case 26: sName = "x0_it_mthnmisc09"; break; //
        case 27: sName = "nw_it_contain001"; break; // box
        case 28: sName = "nw_it_contain006"; break; //bag holding
        case 29: sName = "nw_it_contain005"; break;  //gmbag
        case 30: sName = "nw_it_contain003"; break;  //lmbag
        }
 CreateItemOnObject(sName, oSack, 1);
}

void DropSetItem(object oMod, object oSack, int iClass)
{
 object oPC = GetLastKiller();
 if (oPC==OBJECT_INVALID)oPC = GetFirstPC();
 if (GetMaster(oPC)!=OBJECT_INVALID)oPC = GetMaster(oPC);

 int iDex = GetAbilityScore(oPC, ABILITY_DEXTERITY, TRUE);
 int iStr = GetAbilityScore(oPC, ABILITY_STRENGTH, TRUE);

 int iHD = GetHitDice(oPC);
 if (iHD<=9)return;

 string sName;
 int iDice;

 if (iClass==0)
    {
     if (GetLevelByClass(CLASS_TYPE_WIZARD, oPC)>=3)iClass = 2;
     if (GetLevelByClass(CLASS_TYPE_SORCERER, oPC)>=3)iClass = 3;
     if (GetLevelByClass(CLASS_TYPE_BARD, oPC)>=3)iClass = 3;
     if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC)>=5)iClass = 5;
     if (GetLevelByClass(CLASS_TYPE_MONK, oPC)>=5)iClass = 10;
     if (GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC)>=5)iClass = 11;
     if (GetLevelByClass(CLASS_TYPE_DRUID, oPC)>=5)iClass = 8;
     if (GetLevelByClass(CLASS_TYPE_ROGUE, oPC)>=5)iClass = 4;
     if (GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC)>1)iClass = 11;
     if (GetLevelByClass(CLASS_TYPE_DIVINE_CHAMPION, oPC)>1)iClass = 7;
     if (GetLevelByClass(CLASS_TYPE_PALADIN, oPC)>=5)iClass = 7;
     if (GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oPC)>1)iClass = 4;
     if (GetLevelByClass(CLASS_TYPE_FIGHTER, oPC)>=5){
         if (iStr>iDex)iClass = 1;
         else iClass = 4;
        }
      if (GetLevelByClass(CLASS_TYPE_RANGER, oPC)>5){
         if (iStr>iDex)iClass = 1;
         else iClass = 4;
        }

  }


 switch (iClass)
  {
   case 1:{        // STR Fighter Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_fighter_s1_1"; break;
        case 2: sName = "sd_fighter_s1_2"; break;
        case 3: sName = "sd_fighter_s1_3"; break;
        case 4: sName = "sd_fighter_s1_4"; break;
        case 5: sName = "sd_fighter_s1_5"; break;
        case 6: sName = "sd_fighter_s1_6"; break;
        }}break;
   case 2:{        // Wizard Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_wizard_s1_1"; break;
        case 2: sName = "sd_wizard_s1_2"; break;
        case 3: sName = "sd_wizard_s1_3"; break;
        case 4: sName = "sd_wizard_s1_4"; break;
        case 5: sName = "sd_wizard_s1_5"; break;
        case 6: sName = "sd_wizard_s1_6"; break;
        }}break;
   case 3:{        // Sorcerer Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_sorc_s1_1"; break;
        case 2: sName = "sd_sorc_s1_2"; break;
        case 3: sName = "sd_sorc_s1_3"; break;
        case 4: sName = "sd_sorc_s1_4"; break;
        case 5: sName = "sd_sorc_s1_5"; break;
        case 6: sName = "sd_sorc_s1_6"; break;
        }}break;
   case 4:{        // DEX Fighter/Rogue Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_fighter_s2_1"; break;
        case 2: sName = "sd_fighter_s2_2"; break;
        case 3: sName = "sd_fighter_s2_3"; break;
        case 4: sName = "sd_fighter_s2_4"; break;
        case 5: sName = "sd_fighter_s2_5"; break;
        case 6: sName = "sd_fighter_s2_6"; break;
        }} break;
   case 5:{        // Cleric Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_cleric_s1_1"; break;
        case 2: sName = "sd_cleric_s1_2"; break;
        case 3: sName = "sd_cleric_s1_3"; break;
        case 4: sName = "sd_cleric_s1_4"; break;
        case 5: sName = "sd_cleric_s1_5"; break;
        case 6: sName = "sd_cleric_s1_6"; break;
        }} break;
   case 6:{        // Bard Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_bard_s1_1"; break;
        case 2: sName = "sd_bard_s1_2"; break;
        case 3: sName = "sd_bard_s1_3"; break;
        case 4: sName = "sd_bard_s1_4"; break;
        case 5: sName = "sd_bard_s1_5"; break;
        case 6: sName = "sd_bard_s1_6"; break;
        }}break;
   case 7:{        // Paladin Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_paladin_s1_1"; break;
        case 2: sName = "sd_paladin_s1_2"; break;
        case 3: sName = "sd_paladin_s1_3"; break;
        case 4: sName = "sd_paladin_s1_4"; break;
        case 5: sName = "sd_paladin_s1_5"; break;
        case 6: sName = "sd_paladin_s1_6"; break;
        }}break;
   case 8:{        // Druid Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_druid_s1_1"; break;
        case 2: sName = "sd_druid_s1_2"; break;
        case 3: sName = "sd_druid_s1_3"; break;
        case 4: sName = "sd_druid_s1_4"; break;
        case 5: sName = "sd_druid_s1_5"; break;
        case 6: sName = "sd_druid_s1_6"; break;
        }}break;
   case 9:{        // Ranger Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_ranger_s1_1"; break;
        case 2: sName = "sd_ranger_s1_2"; break;
        case 3: sName = "sd_ranger_s1_3"; break;
        case 4: sName = "sd_ranger_s1_4"; break;
        case 5: sName = "sd_ranger_s1_5"; break;
        case 6: sName = "sd_ranger_s1_6"; break;
        }}break;
   case 10:{        // Monk Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_monk_s1_1"; break;
        case 2: sName = "sd_monk_s1_2"; break;
        case 3: sName = "sd_monk_s1_3"; break;
        case 4: sName = "sd_monk_s1_4"; break;
        case 5: sName = "sd_monk_s1_5"; break;
        case 6: sName = "sd_monk_s1_6"; break;
        }}break;
   case 11:{        // Barbarian Set
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_barb_s6"; break;
        case 2: sName = "sd_barb_s1"; break;
        case 3: sName = "sd_barb_s2"; break;
        case 4: sName = "sd_barb_s3"; break;
        case 5: sName = "sd_barb_s4"; break;
        case 6: sName = "sd_barb_s5"; break;
        }}break;
   case 12:{        // Duel Weapon/Weapon & Shield Sets
        iDice = d6();
        switch(iDice)
        {
        case 1: sName = "sd_weap_s1_1"; break;
        case 2: sName = "sd_weap_s1_2"; break;
        case 3: sName = "sd_weap_s2_1"; break;
        case 4: sName = "sd_weap_s2_2"; break;
        case 5: sName = "sd_weap_s3_1"; break;
        case 6: sName = "sd_weap_s3_2"; break;
        }}break;
  }
// comming soon: Ring Sets, Ammy/Ring Sets


//////////////////////////////////////
//:Debugging
// FloatingTextStringOnCreature("Class: "+IntToString(iClass), oMod);
// FloatingTextStringOnCreature("Roll: "+IntToString(iDice), oMod);
// FloatingTextStringOnCreature(sName, oMod);

 CreateItemOnObject(sName, oSack, 1);
}



void DropGold (object oMob, object oSack, int iBonus)
{
object oPC = GetFirstPC();
string sGold, sLvl;
int iHD = GetHitDice(oMob);
int iGold = 0;

iGold = (d20()*iHD)+(15*iHD)+iBonus;

if (GetHenchman(oPC,2)!=OBJECT_INVALID)iGold+=iGold;

CreateItemOnObject("nw_it_gold001", oSack, iGold);

/////////////////////////////////////////////////////////////////////////
//Gold Debugging
//object oPC = GetFirstPC();
//sGold = IntToString(iGold);
//sLvl = IntToString(iHD);
//FloatingTextStringOnCreature(sGold+" Gold Spawned by lvl "+sLvl+" mob", oPC);
//
//
//
}

void CastImbue(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iSpell;
 int iUses;
 int iRoll;
 switch (iRange)
      {
       case 1: {
                iRoll = d8();
                if (iRoll==1)iSpell = IP_CONST_CASTSPELL_BURNING_HANDS_2;
                if (iRoll==2)iSpell = IP_CONST_CASTSPELL_BARKSKIN_3;
                if (iRoll==3)iSpell = IP_CONST_CASTSPELL_MAGE_ARMOR_2;
                if (iRoll==4)iSpell = IP_CONST_CASTSPELL_MAGIC_MISSILE_5;
                if (iRoll==5)iSpell = IP_CONST_CASTSPELL_COLOR_SPRAY_2;
                if (iRoll==6)iSpell = IP_CONST_CASTSPELL_DOOM_5;
                if (iRoll==7)iSpell = IP_CONST_CASTSPELL_ENTANGLE_5;
                if (iRoll==8)iSpell = IP_CONST_CASTSPELL_GHOSTLY_VISAGE_3;
               }break;
       case 2: {
                iRoll = d8();
                if (iRoll==1)iSpell = IP_CONST_CASTSPELL_DISPLACEMENT_9;
                if (iRoll==2)iSpell = IP_CONST_CASTSPELL_FIREBALL_10;
                if (iRoll==3)iSpell = IP_CONST_CASTSPELL_MAGIC_CIRCLE_AGAINST_ALIGNMENT_5;
                if (iRoll==4)iSpell = IP_CONST_CASTSPELL_SLAY_LIVING_9;
                if (iRoll==5)iSpell = IP_CONST_CASTSPELL_STONESKIN_7;
                if (iRoll==6)iSpell = IP_CONST_CASTSPELL_ICE_STORM_9;
                if (iRoll==7)iSpell = IP_CONST_CASTSPELL_CALL_LIGHTNING_10;
                if (iRoll==8)iSpell = IP_CONST_CASTSPELL_ISAACS_LESSER_MISSILE_STORM_13;
               }break;
       case 3: {
                iRoll = d8();
                if (iRoll==1)iSpell = IP_CONST_CASTSPELL_SUNBEAM_13;
                if (iRoll==2)iSpell = IP_CONST_CASTSPELL_CONE_OF_COLD_15;
                if (iRoll==3)iSpell = IP_CONST_CASTSPELL_MASS_HEAL_15;
                if (iRoll==4)iSpell = IP_CONST_CASTSPELL_ETHEREAL_VISAGE_15;
                if (iRoll==5)iSpell = IP_CONST_CASTSPELL_GREATER_DISPELLING_15;
                if (iRoll==6)iSpell = IP_CONST_CASTSPELL_ISAACS_GREATER_MISSILE_STORM_15;
                if (iRoll==7)iSpell = IP_CONST_CASTSPELL_CHAIN_LIGHTNING_20;
                if (iRoll==8)iSpell = IP_CONST_CASTSPELL_GREATER_STONESKIN_11;
               }break;
       case 4: {
                iRoll = d12();
                if (iRoll==1)iSpell = IP_CONST_CASTSPELL_BIGBYS_FORCEFUL_HAND_15;
                if (iRoll==2)iSpell = IP_CONST_CASTSPELL_HORRID_WILTING_20;
                if (iRoll==3)iSpell = IP_CONST_CASTSPELL_IMPLOSION_17;
                if (iRoll==4)iSpell = IP_CONST_CASTSPELL_INCENDIARY_CLOUD_15;
                if (iRoll==5)iSpell = IP_CONST_CASTSPELL_PREMONITION_15;
                if (iRoll==6)iSpell = IP_CONST_CASTSPELL_MORDENKAINENS_DISJUNCTION_17;
                if (iRoll==7)iSpell = IP_CONST_CASTSPELL_METEOR_SWARM_17;
                if (iRoll==8)iSpell = IP_CONST_CASTSPELL_ISAACS_GREATER_MISSILE_STORM_15;
                if (iRoll==9)iSpell = IP_CONST_CASTSPELL_SUNBEAM_13;
                if (iRoll==10)iSpell = IP_CONST_CASTSPELL_CONE_OF_COLD_15;
                if (iRoll==11)iSpell = IP_CONST_CASTSPELL_MASS_HEAL_15;
                if (iRoll==12)iSpell = IP_CONST_CASTSPELL_ETHEREAL_VISAGE_15;
               }break;
       case 5: {
                iRoll = d20();
                if (iRoll==1)iSpell = IP_CONST_CASTSPELL_WAIL_OF_THE_BANSHEE_17;
                if (iRoll==2)iSpell = IP_CONST_CASTSPELL_TIME_STOP_17;
                if (iRoll==3)iSpell = IP_CONST_CASTSPELL_IMPLOSION_17;
                if (iRoll==4)iSpell = IP_CONST_CASTSPELL_ISAACS_GREATER_MISSILE_STORM_15;
                if (iRoll==5)iSpell = IP_CONST_CASTSPELL_HORRID_WILTING_20;
                if (iRoll==6)iSpell = IP_CONST_CASTSPELL_MORDENKAINENS_SWORD_18;
                if (iRoll==7)iSpell = IP_CONST_CASTSPELL_MORDENKAINENS_DISJUNCTION_17;
                if (iRoll==8)iSpell = IP_CONST_CASTSPELL_MASS_HEAL_15;
                if (iRoll==9)iSpell = IP_CONST_CASTSPELL_BIGBYS_FORCEFUL_HAND_15;
                if (iRoll==10)iSpell = IP_CONST_CASTSPELL_HORRID_WILTING_20;
                if (iRoll==11)iSpell = IP_CONST_CASTSPELL_IMPLOSION_17;
                if (iRoll==12)iSpell = IP_CONST_CASTSPELL_INCENDIARY_CLOUD_15;
                if (iRoll==13)iSpell = IP_CONST_CASTSPELL_PREMONITION_15;
                if (iRoll==14)iSpell = IP_CONST_CASTSPELL_MORDENKAINENS_DISJUNCTION_17;
                if (iRoll==15)iSpell = IP_CONST_CASTSPELL_METEOR_SWARM_17;
                if (iRoll==16)iSpell = IP_CONST_CASTSPELL_ISAACS_GREATER_MISSILE_STORM_15;
                if (iRoll==17)iSpell = IP_CONST_CASTSPELL_SUNBEAM_13;
                if (iRoll==18)iSpell = IP_CONST_CASTSPELL_CONE_OF_COLD_15;
                if (iRoll==19)iSpell = IP_CONST_CASTSPELL_MASS_HEAL_15;
                if (iRoll==20)iSpell = IP_CONST_CASTSPELL_ETHEREAL_VISAGE_15;
               }break;

      }


 switch (iRange)
        {
         case 1: {iRoll = d3();
                  if (iRoll==1)iUses = IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE;
                  if (iRoll==2)iUses = IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE;
                  if (iRoll==3)iUses = IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE;
                  break; }
         case 2: {iRoll = d3();
                  if (iRoll==1)iUses = IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE;
                  if (iRoll==2)iUses = IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE;
                  if (iRoll==3)iUses = IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE;
                  break; }
         case 3: {iRoll = d3();
                  if (iRoll==1)iUses = IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE;
                  if (iRoll==2)iUses = IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE;
                  if (iRoll==3)iUses = IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE;
                  iRoll=d100();
                  if (iRoll>95)iUses = IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE;
                  break; }
         case 4: {iRoll = d3();
                  if (iRoll==1)iUses = IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE;
                  if (iRoll==2)iUses = IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY;
                  if (iRoll==3)iUses = IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY;
                  iRoll=d100();
                  if (iRoll>95)iUses = IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE;
                  break;}
         case 5: {iRoll = d3();
                  if (iRoll==1)iUses = IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY;
                  if (iRoll==2)iUses = IP_CONST_CASTSPELL_NUMUSES_4_USES_PER_DAY;
                  if (iRoll==3)iUses = IP_CONST_CASTSPELL_NUMUSES_5_USES_PER_DAY;
                  iRoll=d100();
                  if (iRoll>90)iUses = IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE;
                  break;}

        }
  ipAdd = ItemPropertyCastSpell(iSpell, iUses);
  IPSafeAddItemProperty(oItem, ipAdd);
  iRoll = (d12() * iRange)+1; if (iRoll>50)iRoll=50;
  SetItemCharges(oItem, iRoll);
}


void SpellSlot(object oItem, int iRange, int iNum)
{
 itemproperty ipAdd;
 itemproperty ipClass;
 int iLvl, i;
 int iClass;
 int iSpec;
 int iRoll;
 iRoll = d8();
 switch (iRoll)
      {
       case 1: {
                iClass = IP_CONST_CLASS_BARD; iSpec = 1;
                ipClass = ItemPropertyLimitUseByClass(IP_CONST_CLASS_BARD);
                } break;
       case 2: {
                iClass = IP_CONST_CLASS_DRUID;
                ipClass = ItemPropertyLimitUseByClass(IP_CONST_CLASS_DRUID);
                } break;
       case 3: {
                iClass = IP_CONST_CLASS_SORCERER;
                ipClass = ItemPropertyLimitUseByClass(IP_CONST_CLASS_SORCERER);
                } break;
       case 4: {
                iClass = IP_CONST_CLASS_WIZARD;
                ipClass = ItemPropertyLimitUseByClass(IP_CONST_CLASS_WIZARD);
                } break;
       case 5: {
                iClass = IP_CONST_CLASS_PALADIN; iSpec = 2;
                ipClass = ItemPropertyLimitUseByClass(IP_CONST_CLASS_PALADIN);
                } break;
       case 6: {
                iClass = IP_CONST_CLASS_RANGER; iSpec = 2;
                ipClass = ItemPropertyLimitUseByClass(IP_CONST_CLASS_RANGER);
                } break;
       case 7: {
                iClass = IP_CONST_CLASS_CLERIC;
                ipClass = ItemPropertyLimitUseByClass(IP_CONST_CLASS_CLERIC);
                } break;
       case 8: {
                iClass = IP_CONST_CLASS_WIZARD;
                ipClass = ItemPropertyLimitUseByClass(IP_CONST_CLASS_WIZARD);
                } break;
      }

 for (i = 0; i < iNum; i++)
     {
      if (iSpec==1)
         {
          switch (iRange)  // Bard max lvl 6
                 {
                  case 1: iLvl = 1; break;                          // 1
                  case 2: {iLvl = d3();if(iLvl==3)iLvl=2;}break;    // 1-2
                  case 3: {iLvl = d3()+2;if(iLvl==5)iLvl=3;}break;  // 3-4
                  case 4: {iLvl = d3()+3;if(iLvl==6)iLvl=4;}break;  // 4-5
                  case 5: {iLvl = d3()+4;if(iLvl==7)iLvl=5;}break;  // 5-6
                 }
         }
      else if (iSpec==2)
         {
          switch (iRange)  // Pally & Ranger max lvl 4
                 {
                  case 1: iLvl = 1; break;                            // 1
                  case 2: {iLvl = d3();if(iLvl==3)iLvl=2;}break;      // 1-2
                  case 3: iLvl = d3(); break;                         // 1-3
                  case 4: iLvl = d3()+1; break;                       // 2-4
                  case 5: {iLvl = d3()+2;if(iLvl==5)iLvl=3;}break;    // 3-4
                 }
        }
     else
        {
         switch (iRange)  // The rest max lvl 9
                {
                 case 1: iLvl = 1; break;                         // 1
                 case 2: iLvl = d4(); break;                      // 1-4
                 case 3: iLvl = d4()+1; break;                    // 2-5
                 case 4: iLvl = d6()+2; break;                    // 3-8
                 case 5: iLvl = d6()+4; break;                    // 5-9
                }
        }
    ipAdd = ItemPropertyBonusLevelSpell(iClass, iLvl);
    AddItemProperty(DURATION_TYPE_PERMANENT, ipAdd, oItem);
   }
 IPSafeAddItemProperty(oItem, ipClass);
}

void MightyEnhance(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iEnh = d4();

 switch (iRange)
      {
       case 1: ; break;                              // 1-4
       case 2: iEnh+=1; break;                       // 2-5
       case 3: iEnh+=2; break;                       // 3-6
       case 4: iEnh+=3; break;                       // 4-7
       case 5: iEnh+=4; break;                       // 5-8
      }
 ipAdd = ItemPropertyMaxRangeStrengthMod(iEnh);
 IPSafeAddItemProperty(oItem, ipAdd);
}

void BowEnhance(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iEnh = d3();

 switch (iRange)
      {
       case 1: if (iEnh==3)iEnh=1; break;            // 1-2
       case 2: {iEnh+=1;if (iEnh==4)iEnh=2;} break;  // 2-3
       case 3: {iEnh+=2;if (iEnh==5)iEnh=3;} break;  // 3-4
       case 4: {iEnh+=3;if (iEnh==6)iEnh=4;} break;  // 4-5
       case 5: {iEnh+=4;if (iEnh==7)iEnh=5;} break;  // 5-6
      }
 ipAdd = ItemPropertyAttackBonus(iEnh);
 IPSafeAddItemProperty(oItem, ipAdd);
}



void AmmoUnlim(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iType;
 int iDam;
 int iRoll = d12();
 switch (iRange)
        {
         case 1:
                {
                 iRoll = d3();
                 if (iRoll==1)iType = IP_CONST_UNLIMITEDAMMO_BASIC;
                 if (iRoll==2)iType = IP_CONST_UNLIMITEDAMMO_BASIC;
                 if (iRoll==3)iType = IP_CONST_UNLIMITEDAMMO_PLUS1;
                }break;
         case 2: {
                 iRoll = d4();
                 if (iRoll==1)iType = IP_CONST_UNLIMITEDAMMO_PLUS2;
                 if (iRoll==2)iType = IP_CONST_UNLIMITEDAMMO_PLUS2;
                 if (iRoll==3)iType = IP_CONST_UNLIMITEDAMMO_1D6COLD;
                 if (iRoll==4)iType = IP_CONST_UNLIMITEDAMMO_1D6LIGHT;
                }break;
         case 3: {
                 iRoll = d6();
                 if (iRoll==1)iType = IP_CONST_UNLIMITEDAMMO_PLUS2;
                 if (iRoll==2)iType = IP_CONST_UNLIMITEDAMMO_PLUS2;
                 if (iRoll==3)iType = IP_CONST_UNLIMITEDAMMO_PLUS3;
                 if (iRoll==4)iType = IP_CONST_UNLIMITEDAMMO_1D6FIRE;
                 if (iRoll==5)iType = IP_CONST_UNLIMITEDAMMO_1D6COLD;
                 if (iRoll==6)iType = IP_CONST_UNLIMITEDAMMO_1D6LIGHT;
                }break;
         case 4: {
                 iRoll = d6();
                 if (iRoll==1)iType = IP_CONST_UNLIMITEDAMMO_PLUS3;
                 if (iRoll==2)iType = IP_CONST_UNLIMITEDAMMO_PLUS4;
                 if (iRoll==3)iType = IP_CONST_UNLIMITEDAMMO_PLUS4;
                 if (iRoll==4)iType = IP_CONST_UNLIMITEDAMMO_1D6FIRE;
                 if (iRoll==5)iType = IP_CONST_UNLIMITEDAMMO_1D6COLD;
                 if (iRoll==6)iType = IP_CONST_UNLIMITEDAMMO_1D6LIGHT;
                }break;
         case 5: {
                 iRoll = d6();
                 if (iRoll==1)iType = IP_CONST_UNLIMITEDAMMO_PLUS4;
                 if (iRoll==2)iType = IP_CONST_UNLIMITEDAMMO_PLUS5;
                 if (iRoll==3)iType = IP_CONST_UNLIMITEDAMMO_PLUS5;
                 if (iRoll==4)iType = IP_CONST_UNLIMITEDAMMO_1D6FIRE;
                 if (iRoll==5)iType = IP_CONST_UNLIMITEDAMMO_1D6COLD;
                 if (iRoll==6)iType = IP_CONST_UNLIMITEDAMMO_1D6LIGHT;
                }break;
        }
ipAdd = ItemPropertyUnlimitedAmmo(iType);
 IPSafeAddItemProperty(oItem, ipAdd);
}



void AmmoEnhance(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iType;
 int iDam;
 int iRoll = d12();
 switch (iRoll)
        {
         case 1: iType = IP_CONST_DAMAGETYPE_ACID; break;
         case 2: iType = IP_CONST_DAMAGETYPE_BLUDGEONING; break;
         case 3: iType = IP_CONST_DAMAGETYPE_COLD; break;
         case 4: iType = IP_CONST_DAMAGETYPE_ELECTRICAL; break;
         case 5: iType = IP_CONST_DAMAGETYPE_FIRE; break;
         case 6: iType = IP_CONST_DAMAGETYPE_MAGICAL; break;
         case 7: iType = IP_CONST_DAMAGETYPE_NEGATIVE; break;
         case 8: iType = IP_CONST_DAMAGETYPE_DIVINE; break;
         case 9: iType = IP_CONST_DAMAGETYPE_PIERCING; break;
         case 10: iType = IP_CONST_DAMAGETYPE_POSITIVE; break;
         case 11: iType = IP_CONST_DAMAGETYPE_SLASHING; break;
         case 12: iType = IP_CONST_DAMAGETYPE_SONIC; break;
        }
 switch (iRange)
        {
         case 1: iDam = IP_CONST_DAMAGEBONUS_1; break;
         case 2: {
                iRoll = d4();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_1;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_2;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_3;
               }break;
         case 3: {
                iRoll = d6();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_2;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_5;
               }break;
         case 4: {
                iRoll = d8();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_5;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_1d8;
                if (iRoll==7)iDam = IP_CONST_DAMAGEBONUS_6;
                if (iRoll==8)iDam = IP_CONST_DAMAGEBONUS_1d10;
               }break;
         case 5: {
                iRoll = d10();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_5;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_1d8;
                if (iRoll==7)iDam = IP_CONST_DAMAGEBONUS_2d4;
                if (iRoll==8)iDam = IP_CONST_DAMAGEBONUS_6;
                if (iRoll==9)iDam = IP_CONST_DAMAGEBONUS_1d10;
                if (iRoll==10)iDam = IP_CONST_DAMAGEBONUS_7;
               }break;
      }
 ipAdd = ItemPropertyDamageBonus(iType, iDam);
 IPSafeAddItemProperty(oItem, ipAdd);
}

void WeapEnhance(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iEnh = d3();

 switch (iRange)
      {
       case 1: if (iEnh==3)iEnh=1; break;            // 1-2
       case 2: {iEnh+=1;if (iEnh==4)iEnh=2;} break;  // 2-3
       case 3: {iEnh+=2;if (iEnh==5)iEnh=3;} break;  // 3-4
       case 4: {iEnh+=3;if (iEnh==6)iEnh=4;} break;  // 4-5
       case 5: {iEnh+=4;if (iEnh==7)iEnh=5;} break;  // 5-6
      }
 ipAdd = ItemPropertyEnhancementBonus(iEnh);
 IPSafeAddItemProperty(oItem, ipAdd);
}

void RangedImbue(object oItem)
{
 itemproperty ipAdd;
 int iType;
 int iRoll = d3();

 switch (iRoll)
      {
       case 1: if (iRoll==1)iType=IP_CONST_DAMAGETYPE_BLUDGEONING; break;
       case 2: if (iRoll==2)iType=IP_CONST_DAMAGETYPE_SLASHING; break;
       case 3: if (iRoll==3)iType=IP_CONST_DAMAGETYPE_PIERCING; break;
      }
 ipAdd = ItemPropertyExtraRangeDamageType(iType);
 IPSafeAddItemProperty(oItem, ipAdd);
}

void MeleeImbue(object oItem)
{
 itemproperty ipAdd;
 int iType;
 int iRoll = d3();

 switch (iRoll)
      {
       case 1: if (iRoll==1)iType=IP_CONST_DAMAGETYPE_BLUDGEONING; break;
       case 2: if (iRoll==2)iType=IP_CONST_DAMAGETYPE_SLASHING; break;
       case 3: if (iRoll==3)iType=IP_CONST_DAMAGETYPE_PIERCING; break;
      }
 ipAdd = ItemPropertyExtraMeleeDamageType(iType);
 IPSafeAddItemProperty(oItem, ipAdd);
}

void MCimbue(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iDam;
 int iCol;
 int iType;
 int iRoll;

 switch (iRange)
      {
       case 1: {
                iRoll = d3();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_1;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_2;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_1d4;
               }break;
       case 2: {
                iRoll = d4();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_1;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_2;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
               }break;
       case 3: {
                iRoll = d6();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_2;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_1d8;
               }break;
       case 4: {
                iRoll = d10();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_5;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_1d8;
                if (iRoll==7)iDam = IP_CONST_DAMAGEBONUS_6;
                if (iRoll==8)iDam = IP_CONST_DAMAGEBONUS_2d4;
                if (iRoll==9)iDam = IP_CONST_DAMAGEBONUS_5;
                if (iRoll==10)iDam = IP_CONST_DAMAGEBONUS_1d10;
               }break;
       case 5: {
                iRoll = d12();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_5;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_1d8;
                if (iRoll==7)iDam = IP_CONST_DAMAGEBONUS_2d4;
                if (iRoll==8)iDam = IP_CONST_DAMAGEBONUS_6;
                if (iRoll==9)iDam = IP_CONST_DAMAGEBONUS_1d10;
                if (iRoll==10)iDam = IP_CONST_DAMAGEBONUS_7;
                if (iRoll==11)iDam = IP_CONST_DAMAGEBONUS_1d12;
                if (iRoll==12)iDam = IP_CONST_DAMAGEBONUS_2d6;
               }break;
      }
 ipAdd = ItemPropertyMassiveCritical(iDam);
 IPSafeAddItemProperty(oItem, ipAdd);
}

int sd_PropCheck(object oItem, int tCode, int iSubProp)
{
 int iFlag=0;
 itemproperty ipProp = GetFirstItemProperty(oItem);
 int iMatchType, iMatchSubType;
 while (GetIsItemPropertyValid(ipProp))
       {
        iMatchType = GetItemPropertyType(ipProp);
        iMatchSubType = GetItemPropertySubType(ipProp);
        if (iMatchType == tCode && iMatchSubType == iSubProp)iFlag=1;
        ipProp = GetNextItemProperty(oItem);
       }
 if (iFlag==1)return TRUE;
 else return FALSE;
}

int sd_GetDamType()
{
 int iType;
 int iRoll = Random(13)+1;
 switch (iRoll)
      {
       case 1: iType = IP_CONST_DAMAGETYPE_ACID; break;
       case 2: iType = IP_CONST_DAMAGETYPE_BLUDGEONING; break;
       case 3: iType = IP_CONST_DAMAGETYPE_COLD; break;
       case 4: iType = IP_CONST_DAMAGETYPE_DIVINE; break;
       case 5: iType = IP_CONST_DAMAGETYPE_ELECTRICAL; break;
       case 6: iType = IP_CONST_DAMAGETYPE_FIRE; break;
       case 7: iType = IP_CONST_DAMAGETYPE_MAGICAL; break;
       case 8: iType = IP_CONST_DAMAGETYPE_NEGATIVE; break;
       case 9: iType = IP_CONST_DAMAGETYPE_PHYSICAL; break;
       case 10: iType = IP_CONST_DAMAGETYPE_PIERCING; break;
       case 11: iType = IP_CONST_DAMAGETYPE_POSITIVE; break;
       case 12: iType = IP_CONST_DAMAGETYPE_SLASHING; break;
       case 13: iType = IP_CONST_DAMAGETYPE_SONIC; break;
      }

 return iType;
}

int sd_GetAbil()
{
 int iType;
 int iRoll = d6();
 switch (iRoll)
      {
       case 1: iType = ABILITY_DEXTERITY; break;
       case 2: iType = ABILITY_INTELLIGENCE; break;
       case 3: iType = ABILITY_WISDOM; break;
       case 4: iType = ABILITY_CHARISMA; break;
       case 5: iType = ABILITY_CONSTITUTION; break;
       case 6: iType = ABILITY_STRENGTH; break;
      }

 return iType;
}

void DAMimbue(object oItem, int iRange)
{
 itemproperty ipAdd;
 itemproperty ipVis;
 int iDam, iCol, iType, iRoll;

 iType = sd_GetDamType();
 while (sd_PropCheck(oItem, 16 , iType))iType = sd_GetDamType();

 switch (iRange)
      {
       case 1: {
                iRoll = d3();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_1;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_2;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_1d4;
               }break;
       case 2: {
                iRoll = d4();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_1;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_2;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
               }break;
       case 3: {
                iRoll = d6();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_2;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_1d8;
               }break;
       case 4: {
                iRoll = d10();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_5;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_1d8;
                if (iRoll==7)iDam = IP_CONST_DAMAGEBONUS_6;
                if (iRoll==8)iDam = IP_CONST_DAMAGEBONUS_2d4;
                if (iRoll==9)iDam = IP_CONST_DAMAGEBONUS_5;
                if (iRoll==10)iDam = IP_CONST_DAMAGEBONUS_1d10;
               }break;
       case 5: {
                iRoll = d12();
                if (iRoll==1)iDam = IP_CONST_DAMAGEBONUS_3;
                if (iRoll==2)iDam = IP_CONST_DAMAGEBONUS_1d4;
                if (iRoll==3)iDam = IP_CONST_DAMAGEBONUS_4;
                if (iRoll==4)iDam = IP_CONST_DAMAGEBONUS_1d6;
                if (iRoll==5)iDam = IP_CONST_DAMAGEBONUS_5;
                if (iRoll==6)iDam = IP_CONST_DAMAGEBONUS_1d8;
                if (iRoll==7)iDam = IP_CONST_DAMAGEBONUS_2d4;
                if (iRoll==8)iDam = IP_CONST_DAMAGEBONUS_6;
                if (iRoll==9)iDam = IP_CONST_DAMAGEBONUS_1d10;
                if (iRoll==10)iDam = IP_CONST_DAMAGEBONUS_7;
                if (iRoll==11)iDam = IP_CONST_DAMAGEBONUS_1d12;
                if (iRoll==12)iDam = IP_CONST_DAMAGEBONUS_2d6;
               }break;
      }
 ipAdd = ItemPropertyDamageBonus(iType, iDam);
 IPSafeAddItemProperty(oItem, ipAdd);

 //ipAdd = ItemPropertyVisualEffect(ITEM_VISUAL_EVIL);
 //IPSafeAddItemProperty(oItem, ipAdd);

 switch(iCol)
       {
        case 1: ipVis = ItemPropertyVisualEffect(ITEM_VISUAL_EVIL); break;
        case 2: ipVis = ItemPropertyVisualEffect(ITEM_VISUAL_COLD); break;
        case 3: ipVis = ItemPropertyVisualEffect(ITEM_VISUAL_FIRE); break;
        case 4: ipVis = ItemPropertyVisualEffect(ITEM_VISUAL_ACID); break;
        case 5: ipVis = ItemPropertyVisualEffect(ITEM_VISUAL_ELECTRICAL); break;
        case 6: ipVis = ItemPropertyVisualEffect(ITEM_VISUAL_HOLY); break;
        case 7: ipVis = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC); break;
       }
 AddItemProperty(DURATION_TYPE_PERMANENT, ipVis, oItem);
}

void ACmisc(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iAC = d3();

 switch (iRange)
      {
       case 1: if (iAC==3)iAC=1; break;           // 1-2
       case 2: {iAC+=1;if (iAC==4)iAC=2;} break;  // 2-3
       case 3: {iAC+=2;if (iAC==5)iAC=3;} break;  // 3-4
       case 4: {iAC+=3;if (iAC==6)iAC=4;} break;  // 4-5
       case 5: {iAC+=4;if (iAC==7)iAC=5;} break;  // 5-6
      }
 ipAdd = ItemPropertyACBonus(iAC);
 IPSafeAddItemProperty(oItem, ipAdd);
}

void ACimbue(object oItem, int iRange, int iSpec)
{
 itemproperty ipAdd;
 int iAC = d3();
 int iPen;
 int iRoll;
 int iAbil;
 switch (iRange)
      {
       case 1: if(iAC==3)iAC=1; break;             // 1-2
       case 2: {iAC+=1;if (iAC==4)iAC=2;} break;   // 2-3
       case 3: {iAC+=2;if (iAC==5)iAC=3;} break;   // 3-4
       case 4: {iAC+=3;if (iAC==6)iAC=4;} break;   // 4-5
       case 5: {iAC+=4;if (iAC==7)iAC=5;} break;   // 5-6
      }
 ipAdd = ItemPropertyACBonus(iAC);

 if (iSpec==1){iPen = d4()+1; ipAdd = ItemPropertyDecreaseAC(IP_CONST_ACMODIFIERTYPE_ARMOR, iPen);}
 if (iSpec==2){iPen = d4()+1; ipAdd = ItemPropertyEnhancementPenalty(iPen);}
 if (iSpec==3)
    {
     iPen = d4()+1;
     iRoll = d6();
     switch(iRoll)
           {
            case 1: iAbil = ABILITY_DEXTERITY; break;
            case 2: iAbil = ABILITY_INTELLIGENCE; break;
            case 3: iAbil = ABILITY_WISDOM; break;
            case 4: iAbil = ABILITY_CHARISMA; break;
            case 5: iAbil = ABILITY_CONSTITUTION; break;
            case 6: iAbil = ABILITY_STRENGTH; break;
           }
     ipAdd = ItemPropertyDecreaseAbility(iAbil, iPen);
    }
 if (iSpec==4){iPen = d4()+1; ipAdd = ItemPropertyAttackPenalty(iPen);}

 IPSafeAddItemProperty(oItem, ipAdd);
}

void MIMMimbue(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iType;
 int iRoll;
 switch (iRange)
      {
       case 1: {}; break;
       case 2: {
                iRoll = d3();
                if (iRoll==1)iType = IP_CONST_IMMUNITYMISC_POISON;
                if (iRoll==2)iType = IP_CONST_IMMUNITYMISC_DISEASE;
                if (iRoll==3)iType = IP_CONST_IMMUNITYMISC_DISEASE;
               }; break;
       case 3: {
                iRoll = d6();
                if (iRoll==1)iType = IP_CONST_IMMUNITYMISC_POISON;
                if (iRoll==2)iType = IP_CONST_IMMUNITYMISC_DISEASE;
                if (iRoll==3)iType = IP_CONST_IMMUNITYMISC_FEAR;
                if (iRoll==4)iType = IP_CONST_IMMUNITYMISC_PARALYSIS;
                if (iRoll==5)iType = IP_CONST_IMMUNITYMISC_DEATH_MAGIC;
                if (iRoll==6)iType = IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN;
               }; break;
       case 4: {
                iRoll = d10();
                if (iRoll==1)iType = IP_CONST_IMMUNITYMISC_POISON;
                if (iRoll==2)iType = IP_CONST_IMMUNITYMISC_DISEASE;
                if (iRoll==3)iType = IP_CONST_IMMUNITYMISC_FEAR;
                if (iRoll==4)iType = IP_CONST_IMMUNITYMISC_PARALYSIS;
                if (iRoll==5)iType = IP_CONST_IMMUNITYMISC_DEATH_MAGIC;
                if (iRoll==6)iType = IP_CONST_IMMUNITYMISC_DISEASE;
                if (iRoll==7)iType = IP_CONST_IMMUNITYMISC_KNOCKDOWN;
                if (iRoll==8)iType = IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN;
                if (iRoll==9)iType = IP_CONST_IMMUNITYMISC_BACKSTAB;
                if (iRoll==10)iType = IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN;
               }; break;
       case 5: {
                iRoll = d12();
                if (iRoll==1)iType = IP_CONST_IMMUNITYMISC_POISON;
                if (iRoll==2)iType = IP_CONST_IMMUNITYMISC_DISEASE;
                if (iRoll==3)iType = IP_CONST_IMMUNITYMISC_FEAR;
                if (iRoll==4)iType = IP_CONST_IMMUNITYMISC_PARALYSIS;
                if (iRoll==5)iType = IP_CONST_IMMUNITYMISC_DEATH_MAGIC;
                if (iRoll==6)iType = IP_CONST_IMMUNITYMISC_DISEASE;
                if (iRoll==7)iType = IP_CONST_IMMUNITYMISC_KNOCKDOWN;
                if (iRoll==8)iType = IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN;
                if (iRoll==9)iType = IP_CONST_IMMUNITYMISC_BACKSTAB;
                if (iRoll==10)iType = IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN;
                if (iRoll==11)iType = IP_CONST_IMMUNITYMISC_MINDSPELLS;
                if (iRoll==12)iType = IP_CONST_IMMUNITYMISC_CRITICAL_HITS;
               }; break;
      }
 ipAdd = ItemPropertyImmunityMisc(iType);
 IPSafeAddItemProperty(oItem, ipAdd);
}

void RESimbue(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iRes, iType, iRoll;

 iType = sd_GetDamType();
 while (sd_PropCheck(oItem, 23 , iType))iType = sd_GetDamType();


 switch (iRange)
      {
       case 1:  iRes = IP_CONST_DAMAGERESIST_5; break;
       case 2: {iRoll=d4();
                if (iRoll==1)iRes = IP_CONST_DAMAGERESIST_5;
                if (iRoll==2)iRes = IP_CONST_DAMAGERESIST_5;
                if (iRoll==3)iRes = IP_CONST_DAMAGERESIST_5;
                if (iRoll==4)iRes = IP_CONST_DAMAGERESIST_10;
                }break;
       case 3: {iRoll=d3();
                if (iRoll==1)iRes = IP_CONST_DAMAGERESIST_5;
                if (iRoll==2)iRes = IP_CONST_DAMAGERESIST_10;
                if (iRoll==3)iRes = IP_CONST_DAMAGERESIST_5;
                }break;
       case 4: {iRoll=d4();
                if (iRoll==1)iRes = IP_CONST_DAMAGERESIST_5;
                if (iRoll==2)iRes = IP_CONST_DAMAGERESIST_10;
                if (iRoll==3)iRes = IP_CONST_DAMAGERESIST_15;
                if (iRoll==4)iRes = IP_CONST_DAMAGERESIST_10;
                }break;
       case 5: {iRoll=d3();
                if (iRoll==1)iRes = IP_CONST_DAMAGERESIST_5;
                if (iRoll==2)iRes = IP_CONST_DAMAGERESIST_10;
                if (iRoll==3)iRes = IP_CONST_DAMAGERESIST_15;
               }break;
      }
 ipAdd = ItemPropertyDamageResistance(iType, iRes);
 IPSafeAddItemProperty(oItem, ipAdd);
}


void AbilityImbue(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iAbil;
 int iType;

 iType = sd_GetAbil();
 while (sd_PropCheck(oItem, 0, iType))iType = sd_GetDamType();

  switch (iRange)
      {
       case 1: iAbil = 1;  break;     // 1
       case 2: iAbil = d2(); break;   // 1-2
       case 3: iAbil = d3(); break;   // 1-3
       case 4: iAbil = d3()+1; break; // 2-4
       case 5: iAbil = d2()+2; break; // 3-4
      }
 ipAdd = ItemPropertyAbilityBonus(iType, iAbil);
 IPSafeAddItemProperty(oItem, ipAdd);
}

void MiscImbue(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iRoll;
 switch (iRange)
      {
       case 1: {}; break;
       case 2: {
                iRoll = d3();
                if (iRoll==1)ipAdd = ItemPropertyDarkvision();
                if (iRoll==2)ipAdd = ItemPropertyImprovedEvasion();
                if (iRoll==3)ipAdd = ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 2);
               }; break;
       case 3: {
                iRoll = d6();
                if (iRoll==1)ipAdd = ItemPropertyDarkvision();
                if (iRoll==2)ipAdd = ItemPropertyImprovedEvasion();
                if (iRoll==3)ipAdd = ItemPropertyVampiricRegeneration(1);
                if (iRoll==4)ipAdd = ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 3);
                if (iRoll==5)ipAdd = ItemPropertyRegeneration(1);
                if (iRoll==6)ipAdd = ItemPropertyDarkvision();
               }; break;
       case 4: {
                iRoll = d6();
                if (iRoll==1)ipAdd = ItemPropertyDarkvision();
                if (iRoll==2)ipAdd = ItemPropertyImprovedEvasion();
                if (iRoll==3)ipAdd = ItemPropertyVampiricRegeneration(2);
                if (iRoll==4)ipAdd = ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 4);
                if (iRoll==5)ipAdd = ItemPropertyRegeneration(2);
                if (iRoll==6)ipAdd = ItemPropertyTrueSeeing();
                }; break;
       case 5: {
                iRoll = d6();
                if (iRoll==1)ipAdd = ItemPropertyDarkvision();
                if (iRoll==2)ipAdd = ItemPropertyImprovedEvasion();
                if (iRoll==3)ipAdd = ItemPropertyVampiricRegeneration(4);
                if (iRoll==4)ipAdd = ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE, 5);
                if (iRoll==5)ipAdd = ItemPropertyRegeneration(4);
                if (iRoll==6)ipAdd = ItemPropertyTrueSeeing();
                }; break;
      }
 IPSafeAddItemProperty(oItem, ipAdd);
}

void SaveImbue(object oItem, int iRange)
{
 itemproperty ipAdd;
 int iAbil;
 int iType;
 int iRoll = d6();
 switch (iRoll)
      {
       case 1: iType = IP_CONST_SAVEBASETYPE_FORTITUDE; break;
       case 2: iType = IP_CONST_SAVEBASETYPE_REFLEX; break;
       case 3: iType = IP_CONST_SAVEBASETYPE_WILL; break;
       case 4: iType = IP_CONST_SAVEBASETYPE_FORTITUDE; break;
       case 5: iType = IP_CONST_SAVEBASETYPE_REFLEX; break;
       case 6: iType = IP_CONST_SAVEBASETYPE_WILL; break;
      }



 switch (iRange)
      {
       case 1: iAbil = 1;  break;     // 1
       case 2: iAbil = d2(); break;   // 1-2
       case 3: iAbil = d3(); break;   // 1-3
       case 4: iAbil = d3()+1; break; // 2-4
       case 5: iAbil = d2()+2; break; // 3-4
      }
 ipAdd = ItemPropertyBonusSavingThrow(iType, iAbil);
 IPSafeAddItemProperty(oItem, ipAdd);
}
void ImpEvasionImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyImprovedEvasion();
IPSafeAddItemProperty(oItem, ipAdd);
}

void TruseeingImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyTrueSeeing();
IPSafeAddItemProperty(oItem, ipAdd);
}
void DarkvisionImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyDarkvision();
IPSafeAddItemProperty(oItem, ipAdd);
}

void FreedomImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyFreeAction();
IPSafeAddItemProperty(oItem, ipAdd);
}

void RegenImbue(object oItem, int iRange)
{
int iRegen;
itemproperty ipAdd;
switch (iRange)
      {
       case 1: {iRegen = d3();if (iRegen==3)iRegen=1; break;}   //1-2
       case 2: iRegen = d3(); break;                            //1-3
       case 3: iRegen = d3()+1; break;                          //1-4
       case 4: {iRegen = d3()+2;if (iRegen==5)iRegen=3;break;}  //2-4
       case 5: iRegen = d4()+1;break;                           //2-5
      }
ipAdd = ItemPropertyRegeneration(iRegen);
IPSafeAddItemProperty(oItem, ipAdd);
}

void VRimbue(object oItem, int iRange)
{
int iRegen;
itemproperty ipAdd;
switch (iRange)
      {
       case 1: {iRegen = d3();if (iRegen==3)iRegen=1; break;}   //1-2
       case 2: iRegen = d3(); break;                            //1-3
       case 3: iRegen = d3()+1; break;                          //1-4
       case 4: {iRegen = d3()+2;if (iRegen==5)iRegen=3;break;}  //2-4
       case 5: iRegen = d4()+1;break;                           //2-5
      }
ipAdd = ItemPropertyVampiricRegeneration(iRegen);
IPSafeAddItemProperty(oItem, ipAdd);
}

void EvilImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyVisualEffect(ITEM_VISUAL_EVIL);
IPSafeAddItemProperty(oItem, ipAdd);
}

void HolyImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyVisualEffect(ITEM_VISUAL_HOLY);
IPSafeAddItemProperty(oItem, ipAdd);
}

void FireImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyVisualEffect(ITEM_VISUAL_FIRE);
IPSafeAddItemProperty(oItem, ipAdd);
}

void ElecImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyVisualEffect(ITEM_VISUAL_ELECTRICAL);
IPSafeAddItemProperty(oItem, ipAdd);
}

void AcidImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyVisualEffect(ITEM_VISUAL_ACID);
IPSafeAddItemProperty(oItem, ipAdd);
}

void HasteImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyHaste();
IPSafeAddItemProperty(oItem, ipAdd);
}

void KeenImbue(object oItem)
{
itemproperty ipAdd;
ipAdd = ItemPropertyKeen();
IPSafeAddItemProperty(oItem, ipAdd);
}

/////////////////
//Test Compiling
//void main() {}

