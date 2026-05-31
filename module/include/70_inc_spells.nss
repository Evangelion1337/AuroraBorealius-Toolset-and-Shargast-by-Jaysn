//::///////////////////////////////////////////////
//:: Community Patch 1.70 New Spell Engine include
//:: 70_inc_spells
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This include file contains base functions for the New Spell Engine.
In order to use it in your spells put this line in the beginning of the script.

    spellsDeclareMajorVariables();

Then you will be able to access spell related informations by typing:

spell.Caster - caster
spell.Target - spell target object
spell.Item - spell cast item
spell.Level - caster level
spell.Id - spell ID constant
spell.DC - spell DC
spell.Meta - spell metamagic
spell.Loc - spell target location
spell.Class - spell cast class

You can use them directly, but if you want to adjust them, like if the spell halves
the caster level, its a good practice to declare the caster level into new variable
beforehand like this.

int nCasterLevel = spell.Level/2;

Otherwise you do not have to do this. Take a look into few spells that have been
rewritten onto New Spell Engine and you will understand quicky.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: ?-11-2010
//:://////////////////////////////////////////////

const int SPELL_TARGET_SINGLETARGET = 2;

//declare major variables for every spell
//start every spell script with this at top
void spellsDeclareMajorVariables();

//created as variation for AOE spells whose got different handling
void aoesDeclareMajorVariables();

// scales delay by range, so the closest creatures gets affected first
float GetDelayByRange(float fMinimumTime, float MaximumTime, float fRange, float fMaxRange);

//remove temporary hitpoints from certain spell
void RemoveTempHP(int nSpellId, object oCreature=OBJECT_SELF);//new function that replaces the one from nw_i0_spells
                                                              //was put here for compatibility reasons

//special workaround for AOEs in order to be able to get proper informations that
//cannot be acquired there
//also featuring a heartbeat issue workaround, to activate it you must set variable
//70_AOE_HEARTBEAT_WORKAROUND on module to TRUE
//sTag - optional parameter for safety, the AOE's tag will match LABEL collumn in vfx_persistent.2da
//scriptHeartbeat - heartbeat script, if any
object spellsSetupNewAOE(string sTag="", string scriptHeartbeat="");

//special workaround for special ability AOEs like aura of fear in order to make
//them immune to the dispell centered at location, should be used in conjunction with spellsSetupNewAOE
//like this: object oAOE = spellsSetupNewAOE(spell); SetAreaOfEffectUndispellable(oAOE);
void SetAreaOfEffectUndispellable(object oAOE);

//special workaround for destroying/dispelling AOE in order to remove AOE owner's effects
void aoesCheckStillValid(object oAOE, object oOwner, object oCreator, int nSpellId);

// * returns true if the creature doesnt have to breath or can breath water
int spellsIsImmuneToDrown(object oCreature);

// * returns true if the creature is sightless
int spellsIsSightless(object oCreature);

// * returns true if the abrupt exposure to bright light is harmful to given creature
int spellsIsLightVulnerable(object oCreature);

// * Returns true if creature cannot hear: is silenced or deaf
int GetIsAbleToHear(object oCreature);

// * Returns true if creature cannot see: is blind or sightless
int GetIsAbleToSee(object oCreature);

struct spells
{
int Id,DC,Level,Class,Meta;
object Caster,Target,Item;
location Loc;
};

struct aoes
{
object AOE,Creator,Owner;
};

struct aoes aoe;
struct spells spell;

void spellsDeclareMajorVariables()
{
spell.Caster = OBJECT_SELF;
spell.Target = GetSpellTargetObject();
spell.Item = GetSpellCastItem();
spell.Level = GetCasterLevel(spell.Caster);
spell.Loc = GetSpellTargetLocation();
spell.Id = GetSpellId();
spell.DC = GetSpellSaveDC();
spell.Class = GetLastSpellCastClass();
 if(spell.Item == OBJECT_INVALID && GetLevelByClass(CLASS_TYPE_PALE_MASTER,spell.Caster) && GetLocalInt(GetModule(),"71_PALEMASTER_ADDS_CASTER_LEVEL"))//module switch to add PM into CL
 {//optional feature to calculate PM levels into caster level
  switch(spell.Class)
  {
  case CLASS_TYPE_BARD:
  case CLASS_TYPE_SORCERER:
  case CLASS_TYPE_WIZARD:
  int nMod = StringToInt(Get2DAString("classes","ArcSpellLvlMod",CLASS_TYPE_PALE_MASTER));
  spell.Level+= (GetLevelByClass(CLASS_TYPE_PALE_MASTER,spell.Caster)+(nMod != 1))/nMod;
  break;
  }
 }
 if(spell.DC > 126)//DC bug with negative primary ability
 {
 string primaryAbil = Get2DAString("classes","PrimaryAbil",spell.Class);//gets the class' primary ability, using 2da for "globallity"
 int nAbility = ABILITY_CHARISMA;// default ability is charisma
  if(primaryAbil == "STR")
  nAbility = ABILITY_STRENGTH;
  else if(primaryAbil == "DEX")
  nAbility = ABILITY_DEXTERITY;
  else if(primaryAbil == "CON")
  nAbility = ABILITY_CONSTITUTION;
  else if(primaryAbil == "WIS")
  nAbility = ABILITY_WISDOM;
  else if(primaryAbil == "INT")
  nAbility = ABILITY_INTELLIGENCE;
  spell.DC = 10+GetLevelByClass(spell.Class,spell.Caster)+GetAbilityModifier(nAbility,spell.Caster);//lets recalculate the DC on our own
 }
spell.Meta = GetMetaMagicFeat();
 if(GetIsObjectValid(spell.Item) || spell.Meta == METAMAGIC_ANY || spell.Meta < 0)
 {  //odd behavior when spell was cast from item             //bug in actioncastspell
 spell.Meta = METAMAGIC_NONE;//spells from items won't have metamagic now
 }
 else if((spell.Meta == METAMAGIC_EMPOWER && !GetHasFeat(FEAT_EMPOWER_SPELL,spell.Caster)) || (spell.Meta == METAMAGIC_MAXIMIZE && !GetHasFeat(FEAT_MAXIMIZE_SPELL,spell.Caster)))
 {
 spell.Meta = METAMAGIC_NONE;//metamagic exploit with polymorph into Rakshasa
 }
int overrideLevel, overrideDC, overrideMeta;
 if(spell.Item != OBJECT_INVALID)
 {//new feature to allow set caster level on item (eg. potion) beyond toolset limit
 overrideLevel = GetLocalInt(spell.Item,"ITEM_CASTER_LEVEL_OVERRIDE");
 spell.Level+= GetLocalInt(spell.Item,"ITEM_CASTER_LEVEL_MODIFIER");
 overrideDC = GetLocalInt(spell.Item,"ITEM_DC_OVERRIDE");
 spell.DC+= GetLocalInt(spell.Item,"ITEM_DC_MODIFIER");
 overrideMeta = GetLocalInt(spell.Item,"ITEM_METAMAGIC_OVERRIDE");
 }
 else if(spell.Class == CLASS_TYPE_INVALID)
 {//new feature to allow set caster level greater than 15 for any of NPC's special abilities
 overrideLevel = GetLocalInt(spell.Caster,"SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE");
 spell.Level+= GetLocalInt(spell.Caster,"SPECIAL_ABILITY_CASTER_LEVEL_MODIFIER");
 overrideDC = GetLocalInt(spell.Caster,"SPECIAL_ABILITY_DC_OVERRIDE");
 spell.DC+= GetLocalInt(spell.Caster,"SPECIAL_ABILITY_DC_MODIFIER");
 overrideMeta = GetLocalInt(spell.Caster,"SPECIAL_ABILITY_METAMAGIC_OVERRIDE");
 }
 else
 {//new feature to allow override caster level for normal spells
 overrideLevel = GetLocalInt(spell.Caster,"SPELL_CASTER_LEVEL_OVERRIDE");
 spell.Level+= GetLocalInt(spell.Caster,"SPELL_CASTER_LEVEL_MODIFIER");
 overrideDC = GetLocalInt(spell.Caster,"SPELL_DC_OVERRIDE");
 spell.DC+= GetLocalInt(spell.Caster,"SPELL_DC_MODIFIER");
 overrideMeta = GetLocalInt(spell.Caster,"SPELL_METAMAGIC_OVERRIDE");
 }
 if(overrideLevel > 0)
 {
 spell.Level = overrideLevel;
 }
 if(overrideDC > 0)
 {
 spell.DC = overrideDC;
 }
 if(overrideMeta > 0)
 {
 spell.Meta = overrideMeta;
 }
 if(spell.Level < 1)//sanity check, this should never happen
 {
 spell.Level = 1;
 }
}

void aoesDeclareMajorVariables()
{
aoe.AOE = OBJECT_SELF;
aoe.Creator = GetAreaOfEffectCreator(aoe.AOE);
aoe.Owner = GetLocalObject(aoe.AOE,"AOE_OWNER");
 if(aoe.Owner == OBJECT_INVALID)
 {
 aoe.Owner = aoe.Creator;
 }
spell.Id = GetEffectSpellId(EffectDazed());
spell.Class = GetLocalInt(aoe.AOE,"AOE_CLASS")-1;
spell.DC = GetLocalInt(aoe.AOE,"AOE_DC");
 if(spell.DC < 1)
 {
 spell.DC = GetSpellSaveDC();
 }
spell.Level = GetLocalInt(aoe.AOE,"AOE_LEVEL");
 if(spell.Level < 1)
 {
 spell.Level = GetCasterLevel(aoe.Creator);
 }
spell.Meta = GetLocalInt(aoe.AOE,"AOE_META")-1;
 if(spell.Meta < 0)
 {
 spell.Meta = GetMetaMagicFeat();
 }
 if(spell.Level < 1)//sanity check, this should never happen
 {
 spell.Level = 1;
 }
}

float GetDelayByRange(float fMinimumTime, float MaximumTime, float fRange, float fMaxRange)
{
return fMinimumTime+(MaximumTime-fMinimumTime)*(fRange/fMaxRange);
}

int GetHasSpellEffectSpecific(int effectType, int spellId, object oCaster, object oTarget);

int GetHasSpellEffectSpecific(int effectType, int spellId, object oCaster, object oTarget)
{
effect eSearch = GetFirstEffect(oTarget);
 while(GetIsEffectValid(eSearch))
 {
  if(GetEffectType(eSearch) == effectType && GetEffectSpellId(eSearch) == spellId && GetEffectCreator(eSearch) == oCaster)
  {
  return TRUE;
  }
 eSearch = GetNextEffect(oTarget);
 }
return FALSE;
}

void RemoveTempHP(int nSpellId, object oCreature=OBJECT_SELF)
{
effect eSearch = GetFirstEffect(oCreature);
 while(GetIsEffectValid(eSearch))
 {
  if(GetEffectType(eSearch) == EFFECT_TYPE_TEMPORARY_HITPOINTS && GetEffectSpellId(eSearch) == nSpellId)
  {
  RemoveEffect(oCreature,eSearch);
  }
 eSearch = GetNextEffect(oCreature);
 }
}

//private
void AOEHeartbeat(string sScript)
{
ExecuteScript(sScript,OBJECT_SELF);
DelayCommand(6.0,AOEHeartbeat(sScript));
}

object spellsSetupNewAOE(string sTag="", string scriptHeartbeat="")
{
int nTh = 1;
object aoeOwner, oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT,spell.Loc,nTh);
 while(oAOE != OBJECT_INVALID)
 {
  if((sTag == "" || GetTag(oAOE) == sTag) && GetAreaOfEffectCreator(oAOE) == spell.Caster && GetLocalObject(oAOE,"AOE_OWNER") == OBJECT_INVALID)
  {
  SetLocalObject(oAOE,"AOE_OWNER",spell.Target == OBJECT_INVALID ? spell.Caster : spell.Target);
  SetLocalInt(oAOE,"AOE_DC",spell.DC);
  SetLocalInt(oAOE,"AOE_META",spell.Meta+1);
  SetLocalInt(oAOE,"AOE_LEVEL",spell.Level);
  SetLocalInt(oAOE,"AOE_CLASS",spell.Class+1);
  SetLocalObject(spell.Target == OBJECT_INVALID ? spell.Caster : spell.Target,"OWNER_"+IntToString(spell.Id),oAOE);
   if(scriptHeartbeat != "" && GetLocalInt(GetModule(),"70_AOE_HEARTBEAT_WORKAROUND"))
   {
   AssignCommand(oAOE,DelayCommand(6.0,AOEHeartbeat(scriptHeartbeat)));
   }
  return oAOE;
  }
 oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT,spell.Loc,++nTh);
 }
return oAOE;
}

void SetAreaOfEffectUndispellable(object oAOE)
{
SetLocalInt(oAOE,"X1_L_IMMUNE_TO_DISPEL",10);
}

void aoesCheckStillValid_continue(object oAOE, object oOwner, object oCreator, int nSpellId)//private
{
 if(!GetIsObjectValid(oAOE))
 {
 effect eSearch = GetFirstEffect(oOwner);
  while(GetIsEffectValid(eSearch))
  {
   if(GetEffectSpellId(eSearch) == nSpellId && GetEffectCreator(eSearch) == oCreator)
   {
   RemoveEffect(oOwner,eSearch);
   }
  eSearch = GetNextEffect(oOwner);
  }
 }
}

void aoesCheckStillValid(object oAOE, object oOwner, object oCreator, int nSpellId)
{
object AOE = GetLocalObject(oOwner,"OWNER_"+IntToString(nSpellId));
 if(GetIsObjectValid(AOE) && AOE == oAOE)
 {
 effect eAOE = GetFirstEffect(oOwner);
  while(GetIsEffectValid(eAOE))
  {
   if(GetEffectSpellId(eAOE) == nSpellId && GetEffectCreator(eAOE) == oCreator && GetEffectType(eAOE) == EFFECT_TYPE_AREA_OF_EFFECT)
   {
   AssignCommand(oOwner, DelayCommand(0.1,aoesCheckStillValid_continue(oAOE,oOwner,oCreator,nSpellId)));
   return;//new instance, its OK
   }
  eAOE = GetNextEffect(oOwner);
  }
 }
}

int GetIsAbleToHear(object oCreature)
{
    effect eSearch = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eSearch))
    {
        switch(GetEffectType(eSearch))
        {
            case EFFECT_TYPE_SILENCE:
            case EFFECT_TYPE_DEAF:
            return FALSE;
        }
        eSearch = GetNextEffect(oCreature);
    }
    return TRUE;
}

int GetIsAbleToSee(object oCreature)
{
    if(spellsIsSightless(oCreature)) return FALSE;
    effect eSearch = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eSearch))
    {
        switch(GetEffectType(eSearch))
        {
            case EFFECT_TYPE_BLINDNESS:
            case EFFECT_TYPE_DARKNESS:
            return FALSE;
        }
        eSearch = GetNextEffect(oCreature);
    }
    return TRUE;
}

int spellsIsImmuneToDrown(object oCreature)
{//undead, construct and any creature that doesn't breath or can breath water are immune to the drown effect
    switch(GetRacialType(oCreature))
    {
    case RACIAL_TYPE_UNDEAD:
    case RACIAL_TYPE_CONSTRUCT:
    case RACIAL_TYPE_ELEMENTAL:
    case RACIAL_TYPE_OOZE:
        return TRUE;
    }
    switch(GetAppearanceType(oCreature))
    {
    case APPEARANCE_TYPE_WYRMLING_BLACK:
    case APPEARANCE_TYPE_WYRMLING_GREEN:
    case APPEARANCE_TYPE_WYRMLING_BRONZE:
    case APPEARANCE_TYPE_WYRMLING_GOLD:
    case APPEARANCE_TYPE_DRAGON_BLACK:
    case APPEARANCE_TYPE_DRAGON_GREEN:
    case APPEARANCE_TYPE_DRAGON_BRONZE:
    case APPEARANCE_TYPE_DRAGON_GOLD:
    case APPEARANCE_TYPE_SAHUAGIN:
    case APPEARANCE_TYPE_SAHUAGIN_CLERIC:
    case APPEARANCE_TYPE_SAHUAGIN_LEADER:
    case APPEARANCE_TYPE_SEA_HAG:
    case APPEARANCE_TYPE_MEPHIT_OOZE:
    case APPEARANCE_TYPE_MEPHIT_WATER:
    case APPEARANCE_TYPE_SHARK_GOBLIN:
    case APPEARANCE_TYPE_SHARK_MAKO:
    case APPEARANCE_TYPE_SHARK_HAMMERHEAD:
        return TRUE;
    }
    return GetLocalInt(oCreature,"IMMUNITY_DROWN");
}

int spellsIsSightless(object oCreature)
{
    switch(GetAppearanceType(oCreature))
    {
    case APPEARANCE_TYPE_GELATINOUS_CUBE:
    case APPEARANCE_TYPE_GRAY_OOZE:
    case APPEARANCE_TYPE_OCHRE_JELLY_SMALL:
    case APPEARANCE_TYPE_OCHRE_JELLY_MEDIUM:
    case APPEARANCE_TYPE_OCHRE_JELLY_LARGE:
        return TRUE;
    }
    return GetLocalInt(oCreature,"SIGHTLESS");
}

int spellsIsLightVulnerable(object oCreature)
{
    switch(GetAppearanceType(oCreature))
    {
    case APPEARANCE_TYPE_SAHUAGIN:
    case APPEARANCE_TYPE_SAHUAGIN_LEADER:
    case APPEARANCE_TYPE_SAHUAGIN_CLERIC:
    case APPEARANCE_TYPE_DROW_CLERIC:
    case APPEARANCE_TYPE_DROW_FEMALE_1:
    case APPEARANCE_TYPE_DROW_FEMALE_2:
    case APPEARANCE_TYPE_DROW_FIGHTER:
    case APPEARANCE_TYPE_DROW_MATRON:
    case APPEARANCE_TYPE_DROW_SLAVE:
    case APPEARANCE_TYPE_DROW_WARRIOR_1:
    case APPEARANCE_TYPE_DROW_WARRIOR_2:
    case APPEARANCE_TYPE_DROW_WARRIOR_3:
    case APPEARANCE_TYPE_DROW_WIZARD:
    case APPEARANCE_TYPE_VAMPIRE_FEMALE:
    case APPEARANCE_TYPE_VAMPIRE_MALE:
        return TRUE;
    }
    if(FindSubString(GetStringLowerCase(GetSubRace(oCreature)),"drow") > -1 || FindSubString(GetStringLowerCase(GetSubRace(oCreature)),"vampire"))
    {   //drow or vampiure subrace, common on PCs
        return TRUE;
    }
    return GetLocalInt(oCreature,"LIGHTVULNERABLE");
}
