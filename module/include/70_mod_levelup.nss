//::///////////////////////////////////////////////
//:: Default 1.70 OnLevelUp module event script
//:: 70_mod_levelup
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script force to redo level if the player gained epic spells inappropriately
or if he is levelling up while polymorphed.

Edit the minimum levels by adjusting constants below if default 1.70 values doesn't
suits you.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-07-2011
//:://////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_SORCERER = 18;
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_WIZARD = 17;
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_DRUID = 17;
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_CLERIC = 17;
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_PALE_MASTER = 15;
const int MIN_CLASS_LEVEL_FOR_BANE_OF_ENEMIES = 21;
const int MIN_CLASS_LEVEL_FOR_EPIC_FIEND = 15;
////////////////////////////////////////////////////////////////////////////////

int GetXPToLevel(int nLevel)
{
return --nLevel<1 ? 0 : (nLevel+1)*nLevel*500;
}

void CancelLevelUp(object oPC)
{
//Character has too many feats.
SendMessageToPCByStrRef(oPC,66222);
int nLevel = GetHitDice(oPC);
int nXP = GetXP(oPC);
//relevel
SetXP(oPC,GetXPToLevel(nLevel)-1);
DelayCommand(0.3,SetXP(oPC,nXP));
}

void main()
{
object oPC = GetPCLevellingUp();
effect eEffect = GetFirstEffect(oPC);
 while(GetIsEffectValid(eEffect))
 {
  if(GetEffectType(eEffect) == EFFECT_TYPE_POLYMORPH)
  {
  CancelLevelUp(oPC);
  return;
  }
 eEffect = GetNextEffect(oPC);
 }
 if(GetHasFeat(FEAT_EPIC_SPELL_MAGE_ARMOUR,oPC) || GetHasFeat(FEAT_EPIC_SPELL_EPIC_WARDING,oPC))
 {
  if(GetLevelByClass(CLASS_TYPE_WIZARD,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_WIZARD &&
     GetLevelByClass(CLASS_TYPE_SORCERER,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_SORCERER)
  {
  CancelLevelUp(oPC);
  return;
  }
 }
 if(GetHasFeat(FEAT_EPIC_SPELL_MUMMY_DUST,oPC) || GetHasFeat(FEAT_EPIC_SPELL_HELLBALL,oPC) ||
         GetHasFeat(FEAT_EPIC_SPELL_RUIN,oPC) || GetHasFeat(FEAT_EPIC_SPELL_DRAGON_KNIGHT,oPC))
 {
  if(GetLevelByClass(CLASS_TYPE_CLERIC,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_CLERIC &&
     GetLevelByClass(CLASS_TYPE_DRUID,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_DRUID &&
     GetLevelByClass(CLASS_TYPE_PALE_MASTER,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_PALE_MASTER &&
     GetLevelByClass(CLASS_TYPE_WIZARD,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_WIZARD &&
     GetLevelByClass(CLASS_TYPE_SORCERER,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_SORCERER)
  {
  CancelLevelUp(oPC);
  return;
  }
 }
 if(GetHasFeat(FEAT_EPIC_BANE_OF_ENEMIES,oPC))
 {
  if(GetLevelByClass(CLASS_TYPE_RANGER,oPC) < MIN_CLASS_LEVEL_FOR_BANE_OF_ENEMIES)
  {
  CancelLevelUp(oPC);
  return;
  }
 }
 if(GetHasFeat(FEAT_EPIC_EPIC_FIEND,oPC))
 {
  if(GetLevelByClass(CLASS_TYPE_BLACKGUARD,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_FIEND)
  {
  CancelLevelUp(oPC);
  return;
  }
 }
////////////////////////////////////////////////////////////////////////////////
//             EXECUTE ANY ADDITIONAL ONLEVELUP SCRIPTS HERE                  //
////////////////////////////////////////////////////////////////////////////////

}
