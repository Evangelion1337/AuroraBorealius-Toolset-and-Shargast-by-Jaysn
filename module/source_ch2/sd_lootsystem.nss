//////////////////////////////////////////////////////////
//::use: #include"sd_lootsystem"
//::
//::
//::  Slayers of Darkmoon loot generation system
//::
//::
//::
//::  Commche 2006
//::

#include"sd_lootsys_tools"

void DropArmor (object oMob, object oSack, int iRange, int SockChance, int iChest)
{
 object oItem;
 itemproperty ipAdd;
 string sType, sIName, sName, sSocks;
 int iQual = 0;
 int iRoll = d10();
 switch(iRoll)
       {
        case 1: sType = "sdarmor8"; sIName = "Plate";break;
        case 2: sType = "sdarmor7"; sIName = "Half Plate";break;
        case 3: sType = "sdarmor6"; sIName = "Chain Mail";break;
        case 4: sType = "sdarmor5"; sIName = "Banded Mail";break;
        case 5: sType = "sdarmor4"; sIName = "Breastplate";break;
        case 6: sType = "sdarmor3"; sIName = "Studded Leather";break;
        case 7: sType = "sdarmor2"; sIName = "Hardened Leather";break;
        case 8: sType = "sdarmor1"; sIName = "Leather";break;
        case 9: sType = "sdarmor0"; sIName = "Tunic";break;
        case 10: sType = "sdarmor02"; sIName = "Robe";break;
       }

 oItem = CreateItemOnObject(sType, oSack, 1, "sf_socket_item");

// chance for socketed item

iRoll = d100();
if (iRoll<SockChance)
   {
    iRoll=d6();
    SetLocalInt(oItem, "SOCKET_SLOTS", iRoll);
    sSocks = IntToString(iRoll);
    ipAdd = ItemPropertyCastSpell
               (IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY,
                IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
    IPSafeAddItemProperty(oItem, ipAdd);


    sName = ColorString("Socketed "+sIName+" ("+sSocks+")", 72, 209, 204 );
    SetName(oItem, sName);
    return;
   }


iRoll = d100();
if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }

SetIdentified(oItem, FALSE);
//////////////////////////////////////////// Lvls 1-5

 // Ac bonus


 DelayCommand(0.2, ACimbue(oItem, iRange, 0));
 ++iQual;

 ////////////////////////////////////////// Lvls 6-10

 if (iRange==2)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Misc
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2,MiscImbue(oItem, iRange));
         ++iQual;
        }
    }

////////////////////////////////////////// Lvls 11-20

 if (iRange==3)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Res bonus
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }

     // Misc
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, MiscImbue(oItem, iRange));
         ++iQual;
        }

     // Misc Immunity
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, MIMMimbue(oItem, iRange));
         ++iQual;
        }
    // Haste

     iRoll = d100();
     if (iRoll>95){DelayCommand(0.2, HasteImbue(oItem));
         ++iQual;}
    }


////////////////////////////////////////// Lvls 20-30

 if (iRange==4)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }

     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Res bonus x 2
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     // Misc
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, MiscImbue(oItem, iRange));
         ++iQual;
        }

     // Misc Immunity
     iRoll = d100();
     if (iRoll>65)
        {
         DelayCommand(0.2, MIMMimbue(oItem, iRange));
         ++iQual;
        }
    // Haste

     iRoll = d100();
     if (iRoll>80){DelayCommand(0.2, HasteImbue(oItem));
         ++iQual;}
    }

////////////////////////////////////////// Lvls 30-40

 if (iRange==5)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }

     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Res bonus x 3
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     // Misc
     iRoll = d100();
     if (iRoll>55)
        {
         DelayCommand(0.2, MiscImbue(oItem, iRange));
         ++iQual;
        }

     // Misc Immunity
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, MIMMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste

     iRoll = d100();
     if (iRoll>70){DelayCommand(0.2, HasteImbue(oItem));
         ++iQual;}
    }
  SetQuality(oItem, sIName, iRange);
 }

void DropShield (object oMob, object oSack, int iRange, int SockChance, int iChest)
{
 object oItem;
 itemproperty ipAdd;
 string sType, sName, sIName, sSocks;
 int iQual = 0;
 int iRoll = d12();
 switch(iRoll)
       {
        case 1: {sType = "sdTower1"; sIName = "Targe";} break;
        case 2: {sType = "sdLarge1"; sIName = "Wooden Shield";} break;
        case 3: {sType = "sdSmall1"; sIName = "Buckler";} break;
        case 4: {sType = "sdTower2"; sIName = "Deflektor";} break;
        case 5: {sType = "sdLarge2"; sIName = "Protector";} break;
        case 6: {sType = "sdSmall2"; sIName = "Heater";} break;
        case 7: {sType = "sdTower3"; sIName = "Defender";} break;
        case 8: {sType = "sdLarge3"; sIName = "Reinforced Shield";} break;
        case 9: {sType = "sdSmall3"; sIName = "Arm Blocker";} break;
        case 10: {sType = "sdTower4"; sIName = "Centurion";} break;
        case 11: {sType = "sdLarge4"; sIName = "Iron Shield";} break;
        case 12: {sType = "sdSmall4"; sIName = "Buckler";} break;
       }

  oItem = CreateItemOnObject(sType, oSack, 1, "sf_socket_item");

// chance for socketed item

iRoll = d100();
if (iRoll<SockChance)
   {
    iRoll=d6();
    SetLocalInt(oItem, "SOCKET_SLOTS", iRoll);
    sSocks = IntToString(iRoll);
    ipAdd = ItemPropertyCastSpell
               (IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY,
                IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
    IPSafeAddItemProperty(oItem, ipAdd);


    sName = ColorString("Socketed "+sIName+" ("+sSocks+")", 72, 209, 204 );
    SetName(oItem, sName);
    return;
   }

iRoll = d100();
if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }

 SetIdentified(oItem, FALSE);

//////////////////////////////////////////// Lvls 1-5

 // Ac bonus


 DelayCommand(0.2, ACmisc(oItem, iRange));
 ++iQual;

 ////////////////////////////////////////// Lvls 6-10

 if (iRange==2)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
    }

////////////////////////////////////////// Lvls 11-20

 if (iRange==3)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Res bonus
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }

     // Save
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     }

////////////////////////////////////////// Lvls 20-30

 if (iRange==4)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Res bonus
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     // Misc
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, MiscImbue(oItem, iRange));
         ++iQual;
        }

     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     }

////////////////////////////////////////// Lvls 30-40

 if (iRange==5)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Res bonus x 2
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     // Misc
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, MiscImbue(oItem, iRange));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
    }
 SetQuality(oItem, sIName, iRange);
}

void DropMagicItem (object oMob, object oSack, int iRange, int SockChance, int iChest)
{
 string sType, sName, sIName, sSocks;
 object oItem;
 itemproperty ipAdd;
 int iID = 0;
 int iQual = 0;
 int iRoll = d20();
 if (iChest==5)iRoll = 9;
 switch(iRoll)
       {
        case 1: {sType = "sdammy1"; sIName = "Amulet";iID = 1;} break;
        case 2: {sType = "sdring1"; sIName = "Ring";iID = 2;} break;
        case 3: {sType = "sdboots1"; sIName = "Boots";iID = 1;}break;
        case 4: {sType = "sdbracers1";sIName = "Wristband";} break;
        case 5: {sType = "sdhelm1";sIName = "Helm";} break;
        case 6: {sType = "sdcloak1";sIName = "Cloak";iID = 1;} break;
        case 7: {sType = "sdbelt1";sIName = "Belt";} break;
        case 8: {sType = "sdammy2";sIName = "Talisman";iID = 1;} break;
        case 9: {sType = "sdring2";sIName = "Band";iID = 2;} break;
        case 10: {sType = "sdboots2";sIName = "Sabatons";iID = 1;} break;
        case 11: {sType = "sdbracers2";sIName = "Bracers";} break;
        case 12: {sType = "sdhelm2";sIName = "Salet";} break;
        case 13: {sType = "sdcloak2";sIName = "Cape";iID = 1;} break;
        case 14: {sType = "sdbelt2";sIName = "Thick Belt";} break;
        case 15: {sType = "sdammy3";sIName = "Charm";iID = 1;} break;
        case 16: {sType = "sdring3";sIName = "Circle";iID = 2;} break;
        case 17: {sType = "sdboots3";sIName = "Greaves";iID = 1;} break;
        case 18: {sType = "sdbracers3";sIName = "Armband";} break;
        case 19: {sType = "sdhelm3";sIName = "Vanguard";} break;
        case 20: {sType = "sdring4";sIName = "Coil";iID = 2;} break;
       }


  // chance for socketed item

oItem = CreateItemOnObject(sType, oSack, 1, "sf_socket_item");

iRoll = d100();
if (iRoll<SockChance)
   {
    iRoll=d6();
    SetLocalInt(oItem, "SOCKET_SLOTS", iRoll);
    sSocks = IntToString(iRoll);
    ipAdd = ItemPropertyCastSpell
               (IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY,
                IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
    IPSafeAddItemProperty(oItem, ipAdd);


    sName = ColorString("Socketed "+sIName+" ("+sSocks+")", 72, 209, 204 );
    SetName(oItem, sName);
    return;
   }


 iRoll = d100();
 if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
 if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }

SetIdentified(oItem, FALSE);

///////////////////////////////////////////// Hench Reward Code

object oPC = GetFirstPC();

if (GetMaster(oMob)!=OBJECT_INVALID)
   {
    SetIdentified(oItem, TRUE);
    //SetItemCursedFlag(oItem, TRUE);
   }

//////////////////////////////////////////// Lvls 1-5

 // AC bonus for ammy, cloak & boots or ability bonus otherwise
 if (iID==1)
    {
     DelayCommand(0.2, ACmisc(oItem, iRange));
     ++iQual;
    }
 else
    {
     DelayCommand(0.2, AbilityImbue(oItem, iRange));
     ++iQual;
    }

 ////////////////////////////////////////// Lvls 6-10

 if (iRange==2)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }

     // If its a ring theres a 30% chance for spellslots - otherwise a save thr
     if (iID==2)
        {
         // Spell Slot
         iRoll = d100();
         if (iRoll>69)
            {
             iRoll=d3();   // 1-3 slots
             DelayCommand(0.2, SpellSlot(oItem, iRange, iRoll));
             iQual+=2;
            }
         }
     else
         {
          // Save
          iRoll = d100();
          if (iRoll>90)
             {
              DelayCommand(0.2, SaveImbue(oItem, iRange));
              ++iQual;
             }
          }

    }

////////////////////////////////////////// Lvls 11-20

 if (iRange==3)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // If its a ring theres a chance for spellslots - otherwise a save thr
     if (iID==2)
        {
         // Spell Slot
         iRoll = d100();
         if (iRoll>69)
            {
             iRoll=d3()+1;  // 2-4 slots
             DelayCommand(0.2, SpellSlot(oItem, iRange, iRoll));
             iQual+=2;
            }
         }
     else
         {
          // Misc Immunity
          iRoll = d100();
          if (iRoll>70)
             {
              DelayCommand(0.2, MIMMimbue(oItem, iRange));
              ++iQual;
             }
         }
     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     }

////////////////////////////////////////// Lvls 20-30

 if (iRange==4)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     if (iID==2)
        {
         // Spell Slot
         iRoll = d100();
         if (iRoll>69)
            {
             iRoll=d4()+2;  // 3-6 slots
             DelayCommand(0.2, SpellSlot(oItem, iRange, iRoll));
             iQual+=2;
            }
         }
     else
        {
         // Misc Immunity
         iRoll = d100();
         if (iRoll>70)
            {
             DelayCommand(0.2, MIMMimbue(oItem, iRange));
             ++iQual;
            }
        }
     // Misc
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, MiscImbue(oItem, iRange));
         ++iQual;
        }

     // Damage Res bonus
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }

     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     }

////////////////////////////////////////// Lvls 30-40

 if (iRange==5)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Res bonus x 2
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>65)
        {
         DelayCommand(0.2, RESimbue(oItem, iRange));
         ++iQual;
        }
     // Misc
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, MiscImbue(oItem, iRange));
         ++iQual;
        }
     // Misc Immunity
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, MIMMimbue(oItem, iRange));
         iQual+=2;
        }
     // Save
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     if (iID==2)
        {
         // Spell Slot
         iRoll = d100();
         if (iRoll>69)
            {
             iRoll = d6()+2; // 2-8 slots
             DelayCommand(0.2, SpellSlot(oItem, iRange, iRoll));
             ++iQual;
            }
         }

    }
 SetQuality(oItem, sIName, iRange);
}


void DropMonkGloves (object oMob, object oSack, int iRange, int SockChance, int iChest)
{
 object oItem;
 itemproperty ipAdd;
 string sType, sName, sIName, sSocks;
 int iDice1, iDice2, iRoll;
 int iQual;
 int iWType = 0;

 iRoll = d6();
 switch (iRoll)
        {
         case 1: sType = "sd_mgloves"; break;
         case 2: sType = "sd_mgloves1"; break;
         case 3: sType = "sd_mgloves2"; break;
         case 4: sType = "sd_mgloves3"; break;
         case 5: sType = "sd_mgloves4"; break;
         case 6: sType = "sd_mgloves5"; break;
        }

 iRoll = d20();
 switch (iRoll)
        {
         case 1: sIName = "War Talons"; break;
         case 2: sIName = "Blood Claws"; break;
         case 3: sIName = "Pulverizers"; ;break;
         case 4: sIName = "Ninja Claws"; break;
         case 5: sIName = "War Gloves"; break;
         case 6: sIName = "Flesh Knuckles"; break;
         case 7: sIName = "Death Mitts"; break;
         case 8: sIName = "Palm Guards"; break;
         case 9: sIName = "Knuckledusters"; ;break;
         case 10: sIName = "Tiger Fists"; break;
         case 11: sIName = "Tauntlets"; break;
         case 12: sIName = "Chi Bracelets"; break;
         case 13: sIName = "Dragon Claws"; break;
         case 14: sIName = "Steel Palms"; break;
         case 15: sIName = "Exploding Fists"; break;
         case 16: sIName = "Nose Breakers"; break;
         case 17: sIName = "Stiff Fingers"; ;break;
         case 18: sIName = "Heart Piercers"; break;
         case 19: sIName = "Digit Devastators"; break;
         case 20: sIName = "Gore Gauntlets"; break;
        }

oItem = CreateItemOnObject(sType, oSack, 1, "sf_socket_item");

// Monk
 iRoll = d100();
 if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
 if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }

 SetIdentified(oItem, FALSE);

//////////////////////////////////////////// Lvls 1-5      ::Monk2::

 // Attack bonus

     DelayCommand(0.2, BowEnhance(oItem, iRange));
     ++iQual;

 ////////////////////////////////////////// Lvls 6-10      ::Monk2::

 if (iRange==2)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll==90)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
    }

////////////////////////////////////////// Lvls 11-20     ::Monk2::

 if (iRange==3)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus x 2
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=85)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         ++iQual;
        }
     }

////////////////////////////////////////// Lvls 20-30     ::Monk2::

 if (iRange==4)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus x 3
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=80)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
   }

////////////////////////////////////////// Lvls 30-40     ::Monk2::

 if (iRange==5)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>20)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus x 3
     iRoll = d100();
     if (iRoll>20)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=70)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
    }
 switch(iQual)
       {
        case 1: sName = ColorString("Superior "+sIName,255, 255, 255); break;
        case 2: sName = ColorString("Enchanted "+sIName, 0, 255, 0); break;
        case 3: sName = ColorString("Powerful "+sIName, 65, 105, 225); break;
        case 4: sName = ColorString("Master's "+sIName, 102, 205, 170); break;
        case 5: sName = ColorString("Epic "+sIName, 128, 0, 218); break;
        case 7: sName = ColorString("Heroic "+sIName, 255, 255, 0 ); break;
        case 6: sName = ColorString("Legendary "+sIName, 218, 165, 32 ); break;
        case 8: sName = ColorString("Grandmaster's "+sIName, 255, 255, 0 ); break;
       }
  SetName(oItem, sName);
  SetIdentified(oItem, FALSE);
}


void DropWeapon (object oMob, object oSack, int iRange, int SockChance, int iChest)
{
 object oPC = GetLastKiller();
 object oItem;
 itemproperty ipAdd;
 string sType, sName, sIName, sSocks;

 int iRoll, iDice;
 int iQual = 0;
 int iWType = 0;

 iDice = d20(2);
 iRoll = d100();

 if (iRoll<CHANCE_WFOCUS)
    {
     if (GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD, oPC))iDice=6;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE, oPC))iDice=4;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_CLUB, oPC))iDice=19;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER, oPC))iDice=14;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE, oPC))iDice=27;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE, oPC))iDice=28;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_DWAXE, oPC))iDice=3;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE, oPC))iDice=2;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD, oPC))iDice=10;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD, oPC))iDice=30;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE, oPC))iDice=5;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW, oPC))iDice=36;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL, oPC))iDice=20;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_KAMA, oPC))iDice=16;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_KATANA, oPC))iDice=11;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI, oPC))iDice=17;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW, oPC))iDice=35;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL, oPC))iDice=21;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER, oPC))iDice=37;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE, oPC))iDice=24;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD, oPC))iDice=8;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW, oPC))iDice=18;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR, oPC))iDice=25;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER, oPC))iDice=13;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR, oPC))iDice=12;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE, oPC))iDice=31;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD, oPC))iDice=9;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW, oPC))iDice=34;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE, oPC))iDice=39;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR, oPC))iDice=32;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_STAFF, oPC))iDice=29;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD, oPC))iDice=26;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER, oPC))iDice=23;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_WHIP, oPC))iDice=33;
     if (GetHasFeat(FEAT_WEAPON_FOCUS_UNARMED_STRIKE, oPC))iDice=40;
    }
 switch(iDice)
       {
// Axes

        case 0: {sType = "sdgaxe"; iRoll = d3();
                 if (iRoll==1)sIName = "Greataxe";
                 if (iRoll==2)sIName = "Two Handed Axe";
                 if (iRoll==3)sIName = "Decapitator";}
        case 1: {sType = "sdgaxe"; iRoll = d3();
                 if (iRoll==1)sIName = "Greataxe";
                 if (iRoll==2)sIName = "Two Handed Axe";
                 if (iRoll==3)sIName = "Decapitator";}
        case 2: {sType = "sdgaxe"; iRoll = d3();
                 if (iRoll==1)sIName = "Greataxe";
                 if (iRoll==2)sIName = "Two Handed Axe";
                 if (iRoll==3)sIName = "Decapitator";}
                 break;         break;
        case 3: {sType = "sdwaxe"; iRoll = d3();
                 if (iRoll==1)sIName = "Dwarven War Axe";
                 if (iRoll==2)sIName = "War Axe";
                 if (iRoll==3)sIName = "Headsplitter";}
                 break;
        case 4: {sType = "sdbaxe"; iRoll = d3();
                 if (iRoll==1)sIName = "Battleaxe";
                 if (iRoll==2)sIName = "Beserker Axe";
                 if (iRoll==3)sIName = "Siege Axe";}
                 break;
        case 5: {sType = "sdhaxe"; iRoll = d3();
                 if (iRoll==1)sIName = "Handaxe";
                 if (iRoll==2)sIName = "Cleaver";
                 if (iRoll==3)sIName = "Tomohawk";}
                 break;

// Bladed

        case 6: {sType = "sd_bastard"; iRoll = d3();
                 if (iRoll==1)sIName = "Bastard Sword";
                 if (iRoll==2)sIName = "Mercinary Blade";
                 if (iRoll==3)sIName = "Black Blade";}
                 break;
        case 7: {sType = "sdlsword"; iRoll = d3();
                 if (iRoll==1)sIName = "Longsword";
                 if (iRoll==2)sIName = "Knight's Sword";
                 if (iRoll==3)sIName = "Honor Blade";}
                 break;
        case 8: {sType = "sdlsword"; iRoll = d3();
                 if (iRoll==1)sIName = "Longsword";
                 if (iRoll==2)sIName = "Knight's Sword";
                 if (iRoll==3)sIName = "Honor Blade";}
                 break;
        case 9: {sType = "sdssword"; iRoll = d3();
                 if (iRoll==1)sIName = "Short Sword";
                 if (iRoll==2)sIName = "Half Blade";
                 if (iRoll==3)sIName = "Halfling Sword";}
                 break;
        case 10: {sType = "sdgsword"; iRoll = d3();
                 if (iRoll==1)sIName = "Greatsword";
                 if (iRoll==2)sIName = "Massive Blade";
                 if (iRoll==3)sIName = "Champion's Steel";}
                 break;
        case 11: {sType = "sdkatana"; iRoll = d3();
                 if (iRoll==1)sIName = "Katana";
                 if (iRoll==2)sIName = "Samurai Sword";
                 if (iRoll==3)sIName = "Assassin Blade";}
                 break;
        case 12: {sType = "sdscim"; iRoll = d3();
                 if (iRoll==1)sIName = "Scimitar";
                 if (iRoll==2)sIName = "Arabian Sword";
                 if (iRoll==3)sIName = "Sand Blade";}
                 break;
        case 13: {sType = "sdrapier"; iRoll = d3();
                 if (iRoll==1)sIName = "Rapier";
                 if (iRoll==2)sIName = "Swashbuckler";
                 if (iRoll==3)sIName = "Death Pin";}
                 break;
        case 14: {sType = "sddagger"; iRoll = d3();
                 if (iRoll==1)sIName = "Dagger";
                 if (iRoll==2)sIName = "Sticker";
                 if (iRoll==3)sIName = "Switchblade";}
                 break;

// Exotic

        case 15: {sType = "sdstaff3"; iRoll = d3();
                 iWType = 2;
                 if (iRoll==1)sIName = "Warlock Bone";
                 if (iRoll==2)sIName = "Shaman Totem";
                 if (iRoll==3)sIName = "Cane of Scorcery";}
                 break;
        case 16: {sType = "sdkama"; iRoll = d3();
                 if (iRoll==1)sIName = "Kama";
                 if (iRoll==2)sIName = "Monk Claw";
                 if (iRoll==3)sIName = "Ripper";}
                 break;
        case 17: {sType = "sdkukri"; iRoll = d3();
                 if (iRoll==1)sIName = "Kukri";
                 if (iRoll==2)sIName = "Machetti";
                 if (iRoll==3)sIName = "Scorpion Tail";}
                 break;
        case 18: {sType = "sdlbow"; iRoll = d3();
                 iWType = 1;
                 if (iRoll==1)sIName = "Siege Bow";
                 if (iRoll==2)sIName = "Elven War Bow";
                 if (iRoll==3)sIName = "Battle Bow";}
                 break;


// Blunt

        case 19: {sType = "sdclub"; iRoll = d3();
                 if (iRoll==1)sIName = "Club";
                 if (iRoll==2)sIName = "Baton";
                 if (iRoll==3)sIName = "Truncheon";}
                 break;
        case 20: {sType = "sdhflail"; iRoll = d3();
                 if (iRoll==1)sIName = "Heavy Flail";
                 if (iRoll==2)sIName = "Deathswinger";
                 if (iRoll==3)sIName = "Skull Masher";}
                 break;
        case 21: {sType = "sdlflail"; iRoll = d3();
                 if (iRoll==1)sIName = "Flail";
                 if (iRoll==2)sIName = "Light Flail";
                 if (iRoll==3)sIName = "Head Cracker";}
                 break;
        case 22: {sType = "sdstaff1"; iRoll = d3();
                 iWType = 2;
                 if (iRoll==1)sIName = "Magestaff";
                 if (iRoll==2)sIName = "Arcane Staff";
                 if (iRoll==3)sIName = "Magus Pole";}
                 break;

        case 23: {sType = "sdwhamm"; iRoll = d3();
                 if (iRoll==1)sIName = "Warhammer";
                 if (iRoll==2)sIName = "Thunderhead";
                 if (iRoll==3)sIName = "Earthshaker";}
                 break;
        case 24: {sType = "sdmace"; iRoll = d3();
                 if (iRoll==1)sIName = "Mace";
                 if (iRoll==2)sIName = "Wrathpole";
                 if (iRoll==3)sIName = "Justice Bringer";}
                 break;
        case 25: {sType = "sdmstar"; iRoll = d3();
                 if (iRoll==1)sIName = "Morning Star";
                 if (iRoll==2)sIName = "Neck Crusher";
                 if (iRoll==3)sIName = "Bloodcopter";}
                 break;

//Double Sided

        case 26: {sType = "sddbsword"; iRoll = d3();
                 if (iRoll==1)sIName = "Doubleblade";
                 if (iRoll==2)sIName = "Doomblade";
                 if (iRoll==3)sIName = "Body Processor";}
                 break;
        case 27: {sType = "sddsmace"; iRoll = d3();
                 if (iRoll==1)sIName = "Double Mace";
                 if (iRoll==2)sIName = "Damage Pole";
                 if (iRoll==3)sIName = "Twin Basher";}
                 break;
        case 28: {sType = "sddsaxe"; iRoll = d3();
                 if (iRoll==1)sIName = "Double Axe";
                 if (iRoll==2)sIName = "Crowd Cutter";
                 if (iRoll==3)sIName = "Haymaker";}
                 break;
        case 29: {sType = "sdqstaff"; iRoll = d3();
                 if (iRoll==1)sIName = "Quaterstaff";
                 if (iRoll==2)sIName = "Pole";
                 if (iRoll==3)sIName = "Oak Rod";}
                 break;

// Polearms

        case 30: {sType = "sdhalberd"; iRoll = d3();
                 if (iRoll==1)sIName = "Halberd";
                 if (iRoll==2)sIName = "Death Reach";
                 if (iRoll==3)sIName = "Wind Cutter";}
                 break;
        case 31: {sType = "sdscythe"; iRoll = d3();
                 if (iRoll==1)sIName = "Reaper";
                 if (iRoll==2)sIName = "Soul Reaver";
                 if (iRoll==3)sIName = "Flesh Harvester";}
                 break;
        case 32: {sType = "sdspear"; iRoll = d3();
                 if (iRoll==1)sIName = "Spear";
                 if (iRoll==2)sIName = "Amazon Finger";
                 if (iRoll==3)sIName = "Body Skewer";}
                 break;

// Whip

      case 33: {sType = "sdwhip"; iRoll = d3();
                 if (iRoll==1)sIName = "Whip";
                 if (iRoll==2)sIName = "Bullwhip";
                 if (iRoll==3)sIName = "Deathrope";}
                 break;

// Ranged


        case 34: {sType = "sdsbow"; iRoll = d3();
                 iWType = 1;
                 if (iRoll==1)sIName = "Halfling War Bow";
                 if (iRoll==2)sIName = "Shortbow";
                 if (iRoll==3)sIName = "Bloodstring";}
                 break;
        case 35: {sType = "sdlcbow"; iRoll = d3();
                 iWType = 1;
                 if (iRoll==1)sIName = "Light Crossbow";
                 if (iRoll==2)sIName = "Bolt Pistol";
                 if (iRoll==3)sIName = "Auto Bow";}
                 break;
        case 36: {sType = "sdhcbow"; iRoll = d3();
                 iWType = 1;
                 if (iRoll==1)sIName = "Battle Crossbow";
                 if (iRoll==2)sIName = "Bolt Rifle";
                 if (iRoll==3)sIName = "Steelstring Sniper";}
                 break;
 // Mage


        case 37: {sType = "sdlhamm"; iRoll = d3();
                 if (iRoll==1)sIName = "Light Hammer";
                 if (iRoll==2)sIName = "Wood Hammer";
                 if (iRoll==3)sIName = "Hole Puncher";}
                 break;
        case 38: {sType = "sdstaff2"; iRoll = d3();
                 iWType = 2;
                 if (iRoll==1)sIName = "Mystic Cane";
                 if (iRoll==2)sIName = "Staff of Conjuring";
                 if (iRoll==3)sIName = "Ivory Staff";}
                 break;
        case 39: {sType = "sdsickle"; iRoll = d3();
                 if (iRoll==1)sIName = "Sickle";
                 if (iRoll==2)sIName = "Blood Crest";
                 if (iRoll==3)sIName = "Death Ring";}
                 break;
        case 40: {sType = "sdmgloves"; iRoll = d3();
                  iWType = 3;
                 if (iRoll==1)sIName = "Death Claws";
                 if (iRoll==2)sIName = "Exploding Fists";
                 if (iRoll==3)sIName = "Battle Gloves";}
                 break;

      }

 // chance for socketed item

oItem = CreateItemOnObject(sType, oSack, 1, "sf_socket_item");

SetName(oItem, sIName);

iRoll = d100();
if (iRoll<SockChance && iWType!=2)
   {
    iRoll=d6();
    SetLocalInt(oItem, "SOCKET_SLOTS", iRoll);
    sSocks = IntToString(iRoll);
    ipAdd = ItemPropertyCastSpell
               (IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY,
                IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
    IPSafeAddItemProperty(oItem, ipAdd);


    sName = ColorString("Socketed "+sIName+" ("+sSocks+")", 72, 209, 204 );
    SetName(oItem, sName);
    return;
   }



if (iWType==1)
{
iQual=0;

// Ranged

// Chance for worn or broken item
 iRoll = d100();
 if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
 if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }

 SetIdentified(oItem, FALSE);

//////////////////////////////////////////// Lvls 1-5      ::Ranged::

 // Attack bonus

     DelayCommand(0.2, BowEnhance(oItem, iRange));
     ++iQual;

 ////////////////////////////////////////// Lvls 6-10      ::Ranged::

 if (iRange==2)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
    // Mighty
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, MightyEnhance(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll==90)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
    }

////////////////////////////////////////// Lvls 11-20     ::Ranged::

 if (iRange==3)
    {
     // Mighty
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, MightyEnhance(oItem, iRange));
         ++iQual;
        }
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Extra range damage bonus
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, RangedImbue(oItem));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=85)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     }

////////////////////////////////////////// Lvls 20-30     ::Ranged::

 if (iRange==4)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }

     // Massive Crits
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Mighty
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, MightyEnhance(oItem, iRange));
         ++iQual;
        }
     // Extra ranged damage bonus
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, RangedImbue(oItem));
         iQual+=2;
        }
     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=80)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     }

////////////////////////////////////////// Lvls 30-40     ::Ranged::

 if (iRange==5)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Mighty
     iRoll = d100();
     if (iRoll>20)
        {
         DelayCommand(0.2, MightyEnhance(oItem, iRange));
         ++iQual;
        }
     // Extra melee damage bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, RangedImbue(oItem));
         iQual+=2;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>35)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=75)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
    }
}
else if (iWType==2)
{
// Mage
iQual=0;

 iRoll = d100();
 if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
 if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
//////////////////////////////////////////// Lvls 1-5      ::Mage::

 // Enhancement bonus

     DelayCommand(0.2, WeapEnhance(oItem, iRange));
     ++iQual;

 ////////////////////////////////////////// Lvls 6-10     ::Mage::

 if (iRange==2)
    {
     // Extra Spell Slot  1-2
     iRoll = d100();
     if (iRoll>40)
        {
         iRoll = d3();if (iRoll==3)iRoll==2;
         DelayCommand(0.2, SpellSlot(oItem, iRange, iRoll));
         ++iQual;
        }

     // Spell Bonus
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, CastImbue(oItem, iRange));
         ++iQual;
        }
    }

////////////////////////////////////////// Lvls 11-20     ::Mage::

 if (iRange==3)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Extra Spell Slot  1-4
     iRoll = d100();
     if (iRoll>35)
        {
         iRoll = d4();
         DelayCommand(0.2, SpellSlot(oItem, iRange, iRoll));
         ++iQual;
        }

     // Spell Bonus x 2
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, CastImbue(oItem, iRange));
         ++iQual;
        }

     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, CastImbue(oItem, iRange));
         ++iQual;
        }

     // Haste bonus
     iRoll = d100();
     if (iRoll>90)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     }

////////////////////////////////////////// Lvls 20-30     ::Mage::

 if (iRange==4)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Extra Spell Slot  1-6
     iRoll = d100();
     if (iRoll==30)
        {
         iRoll = d6();
         DelayCommand(0.2, SpellSlot(oItem, iRange, iRoll));
        }

     // Spell Bonus x 2
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, CastImbue(oItem, iRange));
         ++iQual;
        }

     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, CastImbue(oItem, iRange));
         ++iQual;
        }

     // Haste bonus
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     // Extra melee damage bonus
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, MeleeImbue(oItem));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     }

////////////////////////////////////////// Lvls 30-40     ::Mage::

 if (iRange==5)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>25)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Extra Spell Slot  1-8
     iRoll = d100();
     if (iRoll>25)
        {
         iRoll = d8();
         DelayCommand(0.2, SpellSlot(oItem, iRange, iRoll));
         ++iQual;
        }

     // Spell Bonus x 3
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, CastImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, CastImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, CastImbue(oItem, iRange));
         ++iQual;
        }

     // Haste bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         ++iQual;
        }
     // Extra melee damage bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, MeleeImbue(oItem));
         iQual+=2;
        }
     // Save
     iRoll = d100();
     if (iRoll>55)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
    }


}
else if (iWType==3)
{
// Monk
 iRoll = d100();
 if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
 if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }

 SetIdentified(oItem, FALSE);

//////////////////////////////////////////// Lvls 1-5      ::Monk::

 // Attack bonus

     DelayCommand(0.2, BowEnhance(oItem, iRange));
     ++iQual;

 ////////////////////////////////////////// Lvls 6-10      ::Monk::

 if (iRange==2)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll==90)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
    }

////////////////////////////////////////// Lvls 11-20     ::Monk::

 if (iRange==3)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus x 2
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus x 2
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=85)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     }

////////////////////////////////////////// Lvls 20-30     ::Monk::

 if (iRange==4)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus x 3
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=80)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
   }

////////////////////////////////////////// Lvls 30-40     ::Monk::

 if (iRange==5)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage Bonus x 3
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=75)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
    }
}
else
{
// Melee

 iRoll = d100();
 if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
 if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }

//////////////////////////////////////////// Lvls 1-5      ::Melee::

 // Enhancement bonus

     DelayCommand(0.2, WeapEnhance(oItem, iRange));
     ++iQual;

 ////////////////////////////////////////// Lvls 6-10     ::Melee::

 if (iRange==2)
    {
     // Damage bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Keen bonus
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, KeenImbue(oItem));
         ++iQual;
        }
    }

////////////////////////////////////////// Lvls 11-20     ::Melee::

 if (iRange==3)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage bonus
     iRoll = d100();
     if (iRoll>35)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>45)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Extra melee damage bonus
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, MeleeImbue(oItem));
         ++iQual;
        }
     // Keen bonus
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, KeenImbue(oItem));
         ++iQual;
        }
     }

////////////////////////////////////////// Lvls 20-30     ::Melee::

 if (iRange==4)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>35)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage bonus x 2
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Extra melee damage bonus
     iRoll = d100();
     if (iRoll>65)
        {
         DelayCommand(0.2, MeleeImbue(oItem));
         ++iQual;
        }
     // Keen bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, KeenImbue(oItem));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     }

////////////////////////////////////////// Lvls 30-40     ::Melee::

 if (iRange==5)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Damage bonus x 3
     iRoll = d100();
     if (iRoll>25)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Extra melee damage bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, MeleeImbue(oItem));
         ++iQual;
        }
     // Keen bonus
     iRoll = d100();
     if (iRoll>55)
        {
         DelayCommand(0.2, KeenImbue(oItem));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
    }
}

  if (iQual>8)iQual=8;
  if (iQual==0)iQual=1;

  ////////////////////////////////////////////////////////
  //: Debugging
  //
  /*
  FloatingTextStringOnCreature("ResRef: "+sType, GetFirstPC());
  FloatingTextStringOnCreature("Qual: "+IntToString(iQual), GetFirstPC());
  FloatingTextStringOnCreature("Range: "+IntToString(iRange), GetFirstPC());
  */

  SetQuality(oItem, sIName, iRange);
  SetIdentified(oItem, FALSE);
}


void DropRanged(object oMob, object oSack, int iRange, int SockChance, int iChest)
{
 object oPC = GetLastKiller();
 object oItem;
 itemproperty ipAdd;
 string sType, sName, sIName, sSocks;

 int iRoll, iDice;
 int iQual = 0;
 iDice = d4();
 switch(iDice)
       {
        case 1: {sType = "sdsbow"; iRoll = d3();

                 if (iRoll==1)sIName = "Halfling War Bow";
                 if (iRoll==2)sIName = "Shortbow";
                 if (iRoll==3)sIName = "Bloodstring";}
                 break;
        case 2: {sType = "sdlcbow"; iRoll = d3();

                 if (iRoll==1)sIName = "Light Crossbow";
                 if (iRoll==2)sIName = "Bolt Pistol";
                 if (iRoll==3)sIName = "Auto Bow";}
                 break;
        case 3: {sType = "sdhcbow"; iRoll = d3();

                 if (iRoll==1)sIName = "Battle Crossbow";
                 if (iRoll==2)sIName = "Bolt Rifle";
                 if (iRoll==3)sIName = "Steelstring Sniper";}
                 break;
       case 4: {sType = "sdlbow"; iRoll = d3();

                 if (iRoll==1)sIName = "Siege Bow";
                 if (iRoll==2)sIName = "Elven War Bow";
                 if (iRoll==3)sIName = "Battle Bow";}
                 break;
     }

 oItem = CreateItemOnObject(sType, oSack, 1, "sf_socket_item");

 SetName(oItem, sIName);

// Chance for Socketed Item
iRoll = d100();
if (iRoll<SockChance)
   {
    iRoll=d6();
    SetLocalInt(oItem, "SOCKET_SLOTS", iRoll);
    sSocks = IntToString(iRoll);
    ipAdd = ItemPropertyCastSpell
               (IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY,
                IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
    IPSafeAddItemProperty(oItem, ipAdd);


    sName = ColorString("Socketed "+sIName+" ("+sSocks+")", 72, 209, 204 );
    SetName(oItem, sName);
    return;
   }

// Chance for worn or broken item
 iRoll = d100();
 if (iRoll<=CHANCE_WORN&&iRoll>CHANCE_BROKEN&&iChest!=1)  // chance of being worn
   {
    sName = ColorString("Worn "+sIName, 192, 192, 192);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }
 if (iRoll<=CHANCE_BROKEN&&iChest!=1)             // chance of being broken
   {
    DelayCommand(0.2, ACimbue(oItem, iRange, 1));
    sName = ColorString("Broken "+sIName, 255, 0, 0);
    SetName(oItem, sName);
    SetIdentified(oItem, TRUE);
    return;
   }

 SetIdentified(oItem, FALSE);

//////////////////////////////////////////// Lvls 1-5      ::Ranged::

 // Attack bonus

     DelayCommand(0.2, BowEnhance(oItem, iRange));
     ++iQual;

 ////////////////////////////////////////// Lvls 6-10      ::Ranged::

 if (iRange==2)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
    // Mighty
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, MightyEnhance(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll==90)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
    }

////////////////////////////////////////// Lvls 11-20     ::Ranged::

 if (iRange==3)
    {
     // Mighty
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, MightyEnhance(oItem, iRange));
         ++iQual;
        }
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Extra range damage bonus
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, RangedImbue(oItem));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=85)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     }

////////////////////////////////////////// Lvls 20-30     ::Ranged::

 if (iRange==4)
    {
     // Ability bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }

     // Massive Crits
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Mighty
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, MightyEnhance(oItem, iRange));
         ++iQual;
        }
     // Extra ranged damage bonus
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, RangedImbue(oItem));
         iQual+=2;
        }
     // Save
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=80)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
     }

////////////////////////////////////////// Lvls 30-40     ::Ranged::

 if (iRange==5)
    {
     // Ability bonus x 2
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, AbilityImbue(oItem, iRange));
         ++iQual;
        }
     // Mighty
     iRoll = d100();
     if (iRoll>20)
        {
         DelayCommand(0.2, MightyEnhance(oItem, iRange));
         ++iQual;
        }
     // Extra melee damage bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, RangedImbue(oItem));
         iQual+=2;
        }
     // Massive Crits
     iRoll = d100();
     if (iRoll>35)
        {
         DelayCommand(0.2, MCimbue(oItem, iRange));
         ++iQual;
        }
     // Save
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, SaveImbue(oItem, iRange));
         ++iQual;
        }
     // Haste
     iRoll = d100();
     if (iRoll>=75)
        {
         DelayCommand(0.2, HasteImbue(oItem));
         iQual+=2;
        }
    }
 if (iQual>8)iQual=8;
 if (iQual==0)iQual=1;

 SetQuality(oItem, sIName, iRange);
 SetIdentified(oItem, FALSE);

}

void DropAmmo (object oMob, object oSack, int iRange)
{
 object oItem;
 string sType, sName, sIName;
 int iRoll = d4();
 int iQual;
 int iStack = d10()*9;

 switch(iRoll)
       {
// Ammo

        case 1: {sType = "sdarrow"; iRoll = d3();
                 if (iRoll==1)sIName = "Arrow";
                 if (iRoll==2)sIName = "Steel Arrow";
                 if (iRoll==3)sIName = "Wind Cutter";}
                 break;
        case 2: {sType = "sdbolt"; iRoll = d3();
                 if (iRoll==1)sIName = "Bolt";
                 if (iRoll==2)sIName = "Deathpin";
                 if (iRoll==3)sIName = "Air Lance";}
                 break;
        case 3: {sType = "sdarrow"; iRoll = d3();
                 if (iRoll==1)sIName = "Air Assassin";
                 if (iRoll==2)sIName = "Pegasus Horn";
                 if (iRoll==3)sIName = "Blood Seeker";}
                 break;
        case 4: {sType = "sdbolt"; iRoll = d3();
                 if (iRoll==1)sIName = "Steel Bolt";
                 if (iRoll==2)sIName = "Stinger";
                 if (iRoll==3)sIName = "Blood Sparrow";}
                 break;
       }

oItem = CreateItemOnObject(sType, oSack, iStack);


// Ammo

iRoll = d100();
 if (iRoll<=10)  // 10% chance of worn item      ::Ammo::
    {
     sName = ColorString("Worn "+sIName, 192, 192, 192);
     SetName(oItem, sName);
     return;
    }

 SetIdentified(oItem, FALSE);

//////////////////////////////////////////// Lvls 1-5      ::Ammo::

//++iQual;  // Debugging

 ////////////////////////////////////////// Lvls 6-10     ::Ammo::

 if (iRange==2)
    {
     // Damage bonus
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Vamp Regen bonus
     iRoll = d100();
     if (iRoll>80)
        {
         DelayCommand(0.2, VRimbue(oItem, iRange));
         ++iQual;
        }
     }


////////////////////////////////////////// Lvls 11-20     ::Ammo::

 if (iRange==3)
    {
     // Damage bonus x 2
     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }

     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Vamp Regen bonus
     iRoll = d100();
     if (iRoll>70)
        {
         DelayCommand(0.2, VRimbue(oItem, iRange));
         ++iQual;
        }

     }

////////////////////////////////////////// Lvls 20-30     ::Ammo::

 if (iRange==4)
    {
     // Damage bonus x 3
     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }

     iRoll = d100();
     if (iRoll>45)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>65)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Vamp Regen bonus
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, VRimbue(oItem, iRange));
         ++iQual;
        }

     }

////////////////////////////////////////// Lvls 30-40     ::Ammo::

 if (iRange==5)
    {
     // Damage bonus x 4
     iRoll = d100();
     if (iRoll>20)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }

     iRoll = d100();
     if (iRoll>30)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }

     iRoll = d100();
     if (iRoll>40)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     iRoll = d100();
     if (iRoll>60)
        {
         DelayCommand(0.2, DAMimbue(oItem, iRange));
         ++iQual;
        }
     // Vamp Regen bonus
     iRoll = d100();
     if (iRoll>50)
        {
         DelayCommand(0.2, VRimbue(oItem, iRange));
         ++iQual;
        }

    }
 SetQuality(oItem, sIName, iRange);
}


void DropGem (object oMob, object oSack, int iRange)
{
 object oItem;

 int iRoll;
 int iVal1;
 int iVal2;

 string sType1;
 string sType2;
 string sType3;
 string sName, pName;

 iRoll=d100();
 if (iRoll<32)
 oItem = CreateItemOnObject("sd_rune", oSack, 1);
 else if (iRoll>32&&iRoll<65)
 oItem = CreateItemOnObject("sd_rune2", oSack, 1);
 else if (iRoll>65)
 oItem = CreateItemOnObject("sd_rune3", oSack, 1);

 SetIdentified(oItem, FALSE);

 iRoll = Random(13)+1;
 if (iRoll==1)              // mass crits
    {
     sName = "Brutal Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 74);
    }
 else if (iRoll==2)             // ability rune
    {
     switch(iRange)
           {
       case 1: iVal1 = 1;break;
       case 2: iVal1 = 1;break;
       case 3: iVal1 = d2();break;
       case 4: iVal1 = d2();break;
       case 5: iVal1 = d2();break;
           }
     iRoll=Random(5);
     switch(iRoll)
           {
            case 0: sType1=" Brawny"; break;
            case 1: sType1=" Deft";break;
            case 2: sType1=" Wise";break;
            case 3: sType1=" Hardy";break;
            case 4: sType1=" Clever";break;
            case 5: sType1=" Charming";break;
           }
     if (iVal1==0)iVal1=2;
     sName = "+"+IntToString(iVal1)+sType1+" Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 0);
     SetLocalInt(oItem, "IP_SUBTYPE", iRoll);
     SetLocalInt(oItem, "IP_VALUE", iVal1);
    }
else if (iRoll==3)             // ac rune
    {
     switch(iRange)
           {
       case 1: iVal1 = 1;break;
       case 2: iVal1 = d2();break;
       case 3: iVal1 = d2();break;
       case 4: iVal1 = d3();break;
       case 5: iVal1 = d3();break;
           }
     if (iVal1==0)iVal1=1;
     sName = "+"+IntToString(iVal1)+" AC Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 1);
     SetLocalInt(oItem, "IP_VALUE", iVal1);
    }
else if (iRoll==4)             // ab rune
    {
     switch(iRange)
           {
            case 1: iVal1 = 1;break;
            case 2: iVal1 = d2();break;
            case 3: iVal1 = d2();break;
            case 4: iVal1 = d3();break;
            case 5: iVal1 = d3();break;
           }
     if (iVal1==0)iVal1=2;
     sName = "+"+IntToString(iVal1)+" Agressive Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 56);
     SetLocalInt(oItem, "IP_VALUE", iVal1);

    }
else  if (iRoll==5)             // Enhancement rune
    {
     switch(iRange)
           {
            case 1: iVal1 = 1;break;
            case 2: iVal1 = d2();break;
            case 3: iVal1 = d2();break;
            case 4: iVal1 = d3();break;
            case 5: iVal1 = d3();break;
           }
     if (iVal1==0)iVal1=2;
     sName = "+"+IntToString(iVal1)+" Power Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 6);
     SetLocalInt(oItem, "IP_VALUE", iVal1);

    }
else  if (iRoll==6)             // damage rune
    {
     int iSubType;
     iRoll = Random(13);
     switch (iRoll)
      {
        case 0: {iSubType = 0; sType1 = "Thumping Gem"; break;}
        case 1: {iSubType = 1; sType1 = "Impaling Gem";break;}
        case 2: {iSubType = 2; sType1 = "Slicing Gem";break;}
        case 3: {iSubType = 2;sType1 = "Slicing Gem";break;}
        case 4: {iSubType = 9;sType1 = "Zapping Gem";break;}
        case 5: {iSubType = 5; sType1 = "Magical Gem";break;}
        case 6: {iSubType = 6; sType1 = "Corrosive Gem";break;}
        case 7: {iSubType = 7; sType1 = "Ice Gem";break;}
        case 8: {iSubType = 8; sType1 = "Holy Gem";break;}
        case 9: {iSubType = 9; sType1 = "Zapping Gem";break;}
        case 10: {iSubType = 10; sType1 = "Scorching Gem";break;}
        case 11: {iSubType = 11; sType1 = "Evil Gem";break;}
        case 12: {iSubType = 12; sType1 = "Benevolent Gem";break;}
        case 13: {iSubType = 13; sType1 = "Booming Gem";break;}
       }
     if (iVal1==0)iVal1=2;
     sName = ColorString(sType1, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 16);
     SetLocalInt(oItem, "IP_SUBTYPE", iSubType);
    }
else if (iRoll==7)             // VampRegen
    {
     iRoll = d4();
     switch(iRange)
           {
            case 1: iVal1 = 1;break;
            case 2: iVal1 = d2();break;
            case 3: iVal1 = d2();break;
            case 4: iVal1 = d3();break;
            case 5: iVal1 = d3();break;
           }
     sName = "Feeding Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 67);
     SetLocalInt(oItem, "IP_VALUE", iVal1);

    }
else  if (iRoll==8)             // Misc
    {
     int iType1;
     switch(iRange)
      {
       case 1:
           {
           iRoll = d6();
           if (iRoll==1){iType1 = 888; sType2 = "Cracked";}
           if (iRoll==2){iType1 = 888; sType2 = "Cracked";}
           if (iRoll==3){iType1 = 43; sType2 = "Deadly";}
           if (iRoll==4){iType1 = 35; sType2 = "Speedy";}
           if (iRoll==5){iType1 = 75; sType2 = "Unstoppable";}
           if (iRoll==6){iType1 = 888; sType2 = "Cracked";}
          }break;
       case 2:
          {
           iRoll = d6();
           if (iRoll==1){iType1 = 36; sType2 = "Vengeful";}
           if (iRoll==2){iType1 = 75; sType2 = "Unstoppable";}
           if (iRoll==3){iType1 = 35; sType2 = "Speedy";}
           if (iRoll==4){iType1 = 43; sType2 = "Deadly";}
           if (iRoll==5){iType1 = 888; sType2 = "Cracked";}
           if (iRoll==6){iType1 = 888; sType2 = "Cracked";}
          }break;
      case 3:
          {
           iRoll = d6();
           if (iRoll==1){iType1 = 36; sType2 = "Vengeful";}
           if (iRoll==2){iType1 = 43; sType2 = "Deadly";}
           if (iRoll==3){iType1 = 75; sType2 = "Unstoppable";}
           if (iRoll==4){iType1 = 38; sType2 = "Slippery";}
           if (iRoll==5){iType1 = 36; sType2 = "Vengeful";}
           if (iRoll==6){iType1 = 35; sType2 = "Speedy";}
          }break;
      case 4:
          {
           iRoll = d6();
           if (iRoll==1){iType1 = 36; sType2 = "Vengeful";}
           if (iRoll==2){iType1 = 43; sType2 = "Deadly";}
           if (iRoll==3){iType1 = 75; sType2 = "Unstoppable";}
           if (iRoll==4){iType1 = 38; sType2 = "Slippery";}
           if (iRoll==5){iType1 = 35; sType2 = "Speedy";}
           if (iRoll==6){iType1 = 35; sType2 = "Speedy";}
          }break;
      case 5:
          {
           iRoll = d6();
           if (iRoll==1){iType1 = 43; sType2 = "Deadly";}
           if (iRoll==2){iType1 = 43; sType2 = "Deadly";}
           if (iRoll==3){iType1 = 75; sType2 = "Unstoppable";}
           if (iRoll==4){iType1 = 38; sType2 = "Slippery";}
           if (iRoll==5){iType1 = 35; sType2 = "Speedy";}
           if (iRoll==6){iType1 = 35; sType2 = "Speedy";}
          }break;
      }

     pName = sType2+" Gem";

     if (iType1==888)
        {
         sName = ColorString(pName, 255, 0, 0);
         SetName(oItem, sName);
         SetIdentified(oItem, TRUE);
         return;
        }
     else  sName = ColorString(pName, 127, 255, 212 );

     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", iType1);

    }
else  if (iRoll==9)             // Regen
    {
     iRoll = d4();
     switch(iRange)
           {
            case 1: iVal1 = 1;break;
            case 2: iVal1 = d2();break;
            case 3: iVal1 = d2();break;
            case 4: iVal1 = d3();break;
            case 5: iVal1 = d3();break;
           }
     sName = "Living Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 51);
     SetLocalInt(oItem, "IP_VALUE", iVal1);
    }
else if (iRoll==10)             // damage res rune
    {
     int iSubType;
     iRoll = Random(13);
     switch (iRoll)
      {
        case 0: {iSubType = 0; sType1 = "Solid Gem"; break;}             //bludg
        case 1: {iSubType = 1; sType1 = "Dense Gem";break;}              //pierc
        case 2: {iSubType = 2; sType1 = "Mesh Gem";break;}               //slash
        case 3: {iSubType = 2;sType1 = "Mesh Gem";break;}
        case 4: {iSubType = 9;sType1 = "Grounding Gem";break;}           //elec
        case 5: {iSubType = 5; sType1 = "Mantle Gem";break;}             //mag
        case 6: {iSubType = 6; sType1 = "Alkaline Gem";break;}           //acid
        case 7: {iSubType = 7; sType1 = "Warm Gem";break;}               //cold
        case 8: {iSubType = 8; sType1 = "Absolution Gem";break;}         //div
        case 9: {iSubType = 9; sType1 = "Grounding Gem";break;}
        case 10: {iSubType = 10; sType1 = "Dragonscale Gem";break;}      //fire
        case 11: {iSubType = 11; sType1 = "Order Gem";break;}            //neg
        case 12: {iSubType = 12; sType1 = "Chaos Gem";break;}            //pos
        case 13: {iSubType = 13; sType1 = "Dampening Gem";break;}        //son
       }

     sName = ColorString(sType1, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 23);
     SetLocalInt(oItem, "IP_SUBTYPE", iSubType);
    }
     else if (iRoll==11)             // Mighty rune
    {
     switch(iRange)
           {
       case 1: iVal1 = Random(2)+1;break; //1-2
       case 2: iVal1 = d3();break;        //1-3
       case 3: iVal1 = d3()+1;break;      //2-4
       case 4: iVal1 = d3()+2;break;      //3-5
       case 5: iVal1 = d4()+3;break;      //4-6
           }
     if (iVal1==0)iVal1=2;
     sName = "+"+IntToString(iVal1)+" Pegasus Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 45);
     SetLocalInt(oItem, "IP_VALUE", iVal1);
    }
     else if (iRoll==12)             // Spell Res rune
    {
     sName = "Arcane Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 39);
    }
else if (iRoll==13)             // save rune
    {
     switch(iRange)
           {
            case 1: iVal1 = 1;break;
            case 2: iVal1 = 1;break;
            case 3: iVal1 = d2();break;
            case 4: iVal1 = d2();break;
            case 5: iVal1 = d3();break;
           }
     iRoll=d3();
     switch(iRoll)
           {
            case 1: sType1=" Resilient"; break;
            case 2: sType1=" Unwavering";break;
            case 3: sType1=" Reactive";break;
           }
     if (iVal1==0)iVal1=2;
     sName = "+"+IntToString(iVal1)+sType1+" Gem";
     sName = ColorString(sName, 127, 255, 212 );
     SetName(oItem, sName);
     SetLocalInt(oItem, "IP_TYPE", 40);
     SetLocalInt(oItem, "IP_SUBTYPE", iRoll);
     SetLocalInt(oItem, "IP_VALUE", iVal1);
    }
}



void sd_droploot (object oMob, object oSack)
{
 object oPC = GetFirstPC();

// no loot if killed in stonewatch
// chances are it was an uber guard
// and not the PC that did the killing.
// This is to prevent easy looting higher mobs

if (GetTag(GetArea(oMob))=="Stonewatch")return;

// animals dont usually carry wares - but you can skin em!
// This is to prevent tiny rats dropping full plate mail - can't have that!

if (GetRacialType(oMob)== RACIAL_TYPE_ANIMAL ||
    GetRacialType(oMob)== RACIAL_TYPE_BEAST)
    {CreateItemOnObject("sd_skin", oSack, 1); return;}
if (GetTag(oMob)=="NW_BAT" && d100()<21)
    {CreateItemOnObject("sd_batgland", oSack, 1); return;}


if (GetResRef(GetLastKiller())=="stonewatchpatrol")return;


/////////////////////////////////////////
//::Droprate config::
//
int DamBroke = 0;
int lMod, mMod, rMod;
int gMod = 2;
int iSkill = GetLocalInt(oPC, "alch_skill");

// for every 4 alchemy skill points, the droprate of recipes
// increases by 1%

float fAlchMod = IntToFloat(iSkill) * 0.25;
int   iAlchMod = FloatToInt(fAlchMod);

// adjust the droprate modifyer based on game difficulty
// if there is no game difficulty: Default to normal
int iDiff = GetLocalInt(GetModule(), "sd_game_diff");
if (iDiff==0)lMod = DROP_RATE; //default
if (iDiff==1)lMod = 8;
if (iDiff==2)lMod = 1;

// Make monk gloves a rare drop except when the player is a lvl 5+ monk
if (GetLevelByClass(CLASS_TYPE_MONK, oPC)>2)mMod = 8;
else mMod=2;

// Gems drop a little more frequently after lvl 10
if (GetHitDice(oPC)>9)gMod = 5;

// Ranged mobs have a high chance to drop bows / crossbows
if (GetLocalInt(oMob, "archer")==1)rMod = 15;

// Bosses have high chance to drop loot (never broken or worn)
if (GetLocalInt(oMob, "BOSS")==1){lMod = 50; DamBroke = 1;}

int WeapChance =    6+lMod;        // % chance to drop a weapon
int RangedChance =  lMod+rMod+1;   // % chance to drop a ranged weapon
int MonkChance =    mMod;          // % chance to drop monk gloves
int SockChance =    15;            // % chance to drop a socketed item
int ArmorChance =   5+lMod;        // % chance to drop armor or a shield
int MItemChance =   5+lMod;        // % chance to drop a magic item
int RodWandChance = 3+lMod;        // % chance to drop a wand/rod item
int AlchRecChance = 4+iAlchMod;    // % chance to drop an alchemy recipe
int AmmoChance =    5+lMod+rMod;   // % chance to drop a bolt or an arrow
int GoldChance =    26+lMod;       // % chance to drop some gold
int PotChance =     15+lMod;       // % chance to drop a potion
int ScrollChance =  10+lMod;       // % chance to drop a magic scroll
int GemChance =     gMod;          // % chance to drop a socket gem
int MiscChance =    1;             // % chance to drop a miscellaneous item
int SetItemChance = 100;           // % chance to drop a class item setpiece
//
//
/////////////////////////////////////////////////
//::initiate variables::                       //

int iDice;
int iHD = GetHitDice(oMob);
int iRange;
int iMage;

/////////////////////////////////////////////////

// only casters drop scrolls, wands and rods

if (GetLevelByClass(CLASS_TYPE_DRUID)>0||GetLevelByClass(CLASS_TYPE_BARD)>0
    ||GetLevelByClass(CLASS_TYPE_CLERIC)>0||GetLevelByClass(CLASS_TYPE_SORCERER)>0
    ||GetLevelByClass(CLASS_TYPE_WIZARD)>0) iMage=1;



/////////////////////////////////////////////////
//::Quality range based on level of monster::  //

if (iHD>0&&iHD<6)iRange=1;    // lvl 1-5
if (iHD>5&&iHD<11)iRange=2;   // lvl 6-10
if (iHD>10&&iHD<20)iRange=3;  // lvl 11-19
if (iHD>19&&iHD<30)iRange=4;  // lvl 20-29
if (iHD>29&&iHD<41)iRange=5;  // lvl 30-40

//chance of a more powerful item

if (LUCK_CHANCE>0)
   {
    iDice = Random(LUCK_CHANCE);
    if (iDice==LUCK_CHANCE){++iRange; if (iRange==6)iRange=5;
    FloatingTextStringOnCreature("* Luck has favoured you *", GetFirstPC());}
   }

///////////////////
//:Debugging
//:


////////////////////////////////////////////////

// SetItem Roll
iDice = d100();
if (GetLocalInt(oMob, "BOSS")==1 && iDice<SetItemChance+1)
DropSetItem(oMob, oSack, 0);

// Gold Roll
iDice = d100();
if (iDice<GoldChance+1)DropGold(oMob, oSack, DamBroke);

// Rod/Wand Roll
iDice = d100();
if (iDice<RodWandChance+1&&iMage==1)DropRodWand(oMob, oSack);

// Weapon Roll
iDice = d100();
if (iDice<WeapChance+1)DropWeapon(oMob, oSack, iRange, SockChance, DamBroke);

// Ranged Weapon Roll
iDice = d100();
if (iDice<RangedChance+1)DropRanged(oMob, oSack, iRange, SockChance, DamBroke);

// Monk Gloves Roll
iDice = d100();
if (iDice<MonkChance+1)DropMonkGloves(oMob, oSack, iRange, SockChance, DamBroke);


// Armor or shield Roll
iDice = d100();
if (iDice<ArmorChance+1)
   {
    iDice = d100();
    if (iDice>59)DropShield(oMob, oSack, iRange, SockChance, DamBroke);
    else DropArmor(oMob, oSack, iRange, SockChance, DamBroke);
   }

// Magic Item Roll
iDice = d100();
if (iDice<MItemChance+1)DropMagicItem(oMob, oSack, iRange, SockChance, DamBroke);

// Misc Item Roll
iDice = d100();
if (iDice<MiscChance+1)DropMisc(oMob, oSack);

// Ranged Ammo Roll
iDice = d100();
if (iDice<AmmoChance+1)DropAmmo(oMob, oSack, iRange);

// Pot Roll
iDice = d100();
if (iDice<PotChance+1)DropPot(oMob, oSack, 1);

// Scroll Roll
iDice = d100();
if (iDice<ScrollChance+1&&iMage==1)DropScroll(oMob, oSack, iRange);

// Alchemy Recipe Roll
iDice = d100();
if (iDice<AlchRecChance+1&&iMage==1)DropAlchemyRecipe(oMob, oSack, iRange);

// Gem Roll
iDice = d100();
if (iDice<GemChance+1)DropGem(oMob, oSack, iRange);
}


///////////////////////////
//: For test compiling only
//: void main(){}

