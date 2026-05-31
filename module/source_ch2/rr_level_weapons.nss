// How much XP before a weapon goes up in level
// 1 hit = 1 XP
const int XP_PER_LEVEL = 200;
#include "prc_inc_spells"
#include "rr_textblitz"
#include "x2_inc_switches"

void Level();
void LevelActivate();
void LevelXP();
void LevelAquire();
void LevelUp(object oItem);
void AddPowersByLevel(object oItem);
void AddLevelMegaDamage(object oItem);
void AddLevelKeen(object oItem);
void AddLevelMassiveCrits(object oItem);
void AddLevelDamage(object oItem);
void AddLevelEnhancement(object oItem);
void LevelApplyMegaDamage(object oItem);
void RemoveAllItemProperties(object oItem);
int GetDamageBonusValue(int iLevel);
int GetBonusValue(int iLevel);
int GetArrowDamage(int iDamage);
void LevelSetVars();

void Level()
{
  switch(GetUserDefinedItemEventNumber())
  {
  case X2_ITEM_EVENT_ONHITCAST:
    LevelXP();
    break;
  case X2_ITEM_EVENT_ACQUIRE:
    LevelSetVars();
  }
}

void LevelXP()
{
  object oItem = PRCGetSpellCastItem();
  int iXP = GetLocalInt(oItem, "XP");
  SetLocalInt(oItem, "XP", iXP + 1);
  LevelApplyMegaDamage(oItem);
  if (GetLocalInt(oItem, "Level") > 39) return;
  if ((iXP + 1) >= GetLocalInt(oItem, "NextLevelXP")) LevelUp(oItem);
}

void LevelUp(object oItem)
{
  int iLvl = GetLocalInt(oItem, "Level") + 1;
  if (iLvl > 40) return;
  SetLocalInt(oItem, "Level", iLvl);
  SetLocalInt(oItem, "NextLevelXP", (iLvl * XP_PER_LEVEL));
  RemoveAllItemProperties(oItem);
  AddPowersByLevel(oItem);
}

void AddPowersByLevel(object oItem)
{
  int iLvl = GetLocalInt(oItem, "Level");
  switch(iLvl)
  {
  case 30: // Megadamge
    AddLevelMegaDamage(oItem);
  case 29:
  case 28:
  case 27:
  case 26:
  case 25:
  case 24:
  case 23:
  case 22:
  case 21:
  case 20:
  case 19:
  case 18:
  case 17:
  case 16:
  case 15:
  case 14:
  case 13:
  case 12:
  case 11:
  case 10: // Keen
    AddLevelKeen(oItem);
  case 9:
  case 8:
  case 7:
  case 6:
  case 5: // MassiveCrits
    AddLevelMassiveCrits(oItem);
  case 4:
  case 3:
  case 2: // Damage
    AddLevelDamage(oItem);
  case 1: // Enhancement
    AddLevelEnhancement(oItem);
    ColorToOne(RandomColor(), " * * * Your " + GetName(oItem) + " is now level " + IntToString(iLvl) + " * * * ", OBJECT_SELF);
    break;
  default:
    AddLevelMegaDamage(oItem);
    AddLevelKeen(oItem);
    AddLevelMassiveCrits(oItem);
    AddLevelDamage(oItem);
    AddLevelEnhancement(oItem);
    ColorToOne(RandomColor(), " * * * Your " + GetName(oItem) + " is now level " + IntToString(iLvl) + " * * * ", OBJECT_SELF);
  }
}

void AddLevelMegaDamage(object oItem)
{
  int i = 100000000;
  switch(GetLocalInt(oItem, "Level"))
  {
  case 40:
    i = 222222222;
    break;
  case 39:
    i = 212121212;
    break;
  case 38:
    i = 111111111;
    break;
  case 37:
    i = 111111110;
    break;
  case 36:
  case 35:
    i = 111111100;
    break;
  case 34:
    i = 111111000;
    break;
  case 33:
    i = 111110000;
    break;
  case 32:
    i = 111000000;
    break;
  default:
    i = 100000000;
  }
  SetLocalInt(oItem, "MegaDamage", i);
}

void AddLevelKeen(object oItem)
{
  AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyKeen(), oItem);
}

void AddLevelMassiveCrits(object oItem)
{
  AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyMassiveCritical(GetDamageBonusValue(GetLocalInt(oItem, "Level"))), oItem);
}

void AddLevelDamage(object oItem)
{
  int i = 100000000;
  switch(GetLocalInt(oItem, "Level"))
  {
  case 40:
    i = 987654789;
    break;
  case 39:
    i = 876543678;
    break;
  case 38:
    i = 765432567;
    break;
  case 37:
    i = 654321456;
    break;
  case 36:
  case 35:
  case 34:
    i = 543211345;
    break;
  case 33:
  case 32:
  case 31:
  case 30:
  case 29:
  case 28:
    i = 432111234;
    break;
  case 27:
  case 26:
  case 25:
  case 24:
  case 23:
  case 22:
    i = 431111134;
    break;
  case 21:
  case 20:
  case 19:
    i = 431100134;
    break;
  case 18:
  case 17:
  case 16:
    i = 431000034;
    break;
  case 15:
  case 14:
  case 13:
    i = 430000034;
    break;
  case 12:
  case 11:
  case 10:
    i = 320000024;
    break;
  case 9:
  case 8:
  case 7:
    i = 310000012;
    break;
  case 6:
  case 5:
  case 4:
    i = 100000001;
    break;
  case 3:
  case 2:
    i = 100000000;
  }

  object oArrow = oItem;

  // Pirce, Magic, Fire, Cold, Acid, Electic, Sonic, Divine, Negative
  int iDam = i;

  int iPie = iDam / 100000000;
  iDam -= iPie * 100000000;
  int iMag = iDam / 10000000;
  iDam -= iMag * 10000000;
  int iFire = iDam / 1000000;
  iDam -= iFire * 1000000;
  int iCold = iDam / 100000;
  iDam -= iCold * 100000;
  int iAcid = iDam / 10000;
  iDam -= iAcid * 10000;
  int iElec = iDam / 1000;
  iDam -= iElec * 1000;
  int iSonic = iDam / 100;
  iDam -= iSonic * 100;
  int iHoly = iDam / 10;
  iDam -= iHoly * 10;
  int iNeg = iDam;

  if (iFire) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_FIRE, GetArrowDamage(iFire)), oArrow);
  if (iCold) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, GetArrowDamage(iCold)), oArrow);
  if (iAcid) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_ACID, GetArrowDamage(iAcid)), oArrow);
  if (iElec) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_ELECTRICAL, GetArrowDamage(iElec)), oArrow);
  if (iSonic) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_SONIC, GetArrowDamage(iSonic)), oArrow);
  if (iHoly) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_DIVINE, GetArrowDamage(iHoly)), oArrow);
  if (iNeg) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_NEGATIVE, GetArrowDamage(iNeg)), oArrow);
  if (iPie) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_PIERCING, GetArrowDamage(iPie)), oArrow);
  if (iMag) AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, GetArrowDamage(iMag)), oArrow);
}

void AddLevelEnhancement(object oItem)
{
  AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyEnhancementBonus(GetBonusValue(GetLocalInt(oItem, "Level"))), oItem);
}

void LevelApplyMegaDamage(object oItem)
{
  int iDam = GetLocalInt(oItem, "MegaDamage");
  if (iDam < 1) return;

  int iPie = iDam / 100000000;
  iDam -= iPie * 100000000;
  int iMag = iDam / 10000000;
  iDam -= iMag * 10000000;
  int iFire = iDam / 1000000;
  iDam -= iFire * 1000000;
  int iCold = iDam / 100000;
  iDam -= iCold * 100000;
  int iAcid = iDam / 10000;
  iDam -= iAcid * 10000;
  int iElec = iDam / 1000;
  iDam -= iElec * 1000;
  int iSonic = iDam / 100;
  iDam -= iSonic * 100;
  int iHoly = iDam / 10;
  iDam -= iHoly * 10;
  int iNeg = iDam;

  effect e = EffectVisualEffect(VFX_FNF_PWSTUN);

  if (iPie) e = EffectLinkEffects(EffectDamage(d100(iPie), DAMAGE_TYPE_PIERCING), e);
  if (iFire) e = EffectLinkEffects(EffectDamage(d100(iFire), DAMAGE_TYPE_FIRE), e);
  if (iCold) e = EffectLinkEffects(EffectDamage(d100(iCold), DAMAGE_TYPE_COLD), e);
  if (iAcid) e = EffectLinkEffects(EffectDamage(d100(iAcid), DAMAGE_TYPE_ACID), e);
  if (iElec) e = EffectLinkEffects(EffectDamage(d100(iElec), DAMAGE_TYPE_ELECTRICAL), e);
  if (iSonic) e = EffectLinkEffects(EffectDamage(d100(iSonic), DAMAGE_TYPE_SONIC), e);
  if (iHoly) e = EffectLinkEffects(EffectDamage(d100(iHoly), DAMAGE_TYPE_DIVINE), e);
  if (iNeg) e = EffectLinkEffects(EffectDamage(d100(iNeg), DAMAGE_TYPE_NEGATIVE), e);
  if (iMag) e = EffectLinkEffects(EffectDamage(d100(iMag), DAMAGE_TYPE_MAGICAL), e);
  ApplyEffectToObject(DURATION_TYPE_PERMANENT, e, PRCGetSpellTargetObject());
}

void RemoveAllItemProperties(object oItem)
{
  itemproperty ip = GetFirstItemProperty(oItem);
  while(GetIsItemPropertyValid(ip))
  {
    if (GetItemPropertyType(ip) != ITEM_PROPERTY_ONHITCASTSPELL) RemoveItemProperty(oItem, ip);
    ip = GetNextItemProperty(oItem);
  }
}

// Level to Damage Power table:
// example: lvl 20 is 1d12 damage
int GetDamageBonusValue(int iLevel)
{
  switch(iLevel)
  {
  case 40:
    return IP_CONST_DAMAGEBONUS_2d12;
  case 39:
  case 38:
  case 37:
  case 36:
  case 35:
  case 34:
    return IP_CONST_DAMAGEBONUS_2d10;
  case 33:
  case 32:
  case 31:
  case 30:
  case 29:
  case 28:
    return IP_CONST_DAMAGEBONUS_2d8;
  case 27:
  case 26:
  case 25:
  case 24:
  case 23:
  case 22:
    return IP_CONST_DAMAGEBONUS_2d6;
  case 21:
  case 20:
  case 19:
    return IP_CONST_DAMAGEBONUS_1d12;
  case 18:
  case 17:
  case 16:
    return IP_CONST_DAMAGEBONUS_1d10;
  case 15:
  case 14:
  case 13:
    return IP_CONST_DAMAGEBONUS_2d4;
  case 12:
  case 11:
  case 10:
    return IP_CONST_DAMAGEBONUS_1d8;
  case 9:
  case 8:
  case 7:
    return IP_CONST_DAMAGEBONUS_1d6;
  case 6:
  case 5:
  case 4:
    return IP_CONST_DAMAGEBONUS_3;
  case 3:
    return IP_CONST_DAMAGEBONUS_2;
  }
  return IP_CONST_DAMAGEBONUS_1;
}

// Level to Bonus Power table:
// example: lvl 20 is +8
int GetBonusValue(int iLevel)
{
  switch(iLevel)
  {
  case 40:
    return 12;
  case 39:
  case 38:
  case 37:
  case 36:
  case 35:
  case 34:
    return 11;
  case 33:
  case 32:
  case 31:
  case 30:
  case 29:
  case 28:
    return 10;
  case 27:
  case 26:
  case 25:
  case 24:
  case 23:
  case 22:
    return 9;
  case 21:
  case 20:
  case 19:
    return 8;
  case 18:
  case 17:
  case 16:
    return 7;
  case 15:
  case 14:
  case 13:
    return 6;
  case 12:
  case 11:
  case 10:
    return 5;
  case 9:
  case 8:
  case 7:
    return 4;
  case 6:
  case 5:
  case 4:
    return 3;
  case 3:
    return 2;
  case 2:
  }
  return 1;
}

// Damage Values:
// 1 = 1
// 2 = 2
// 3 = 3
// 4 = 1d6
// 5 = 1d8
// 6 = 1d10
// 7 = 1d12
// 8 = 2d8
// 9 = 2d12
// 0 = 20
int GetArrowDamage(int iDamage)
{
  switch(iDamage)
  {
  case 0:
    break;
  case 2:
    return IP_CONST_DAMAGEBONUS_2;
    break;
  case 3:
    return IP_CONST_DAMAGEBONUS_3;
    break;
  case 4:
    return IP_CONST_DAMAGEBONUS_1d6;
    break;
  case 5:
    return IP_CONST_DAMAGEBONUS_1d8;
    break;
  case 6:
    return IP_CONST_DAMAGEBONUS_1d10;
    break;
  case 7:
    return IP_CONST_DAMAGEBONUS_1d12;
    break;
  case 8:
    return IP_CONST_DAMAGEBONUS_2d8;
    break;
  case 9:
    return IP_CONST_DAMAGEBONUS_2d12;
    break;
  default:
    return IP_CONST_DAMAGEBONUS_1;
  }
  return 0;
}

void LevelSetVars()
{
  object oItem = GetModuleItemAcquired();
  if (GetLocalInt(oItem, "Level")) return;
  SetLocalInt(oItem, "Level", 1);
  SetLocalInt(oItem, "NextLevelXP", XP_PER_LEVEL);
}

//:: void main (){}