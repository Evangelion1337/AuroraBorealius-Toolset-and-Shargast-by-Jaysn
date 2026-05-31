//::///////////////////////////////////////////////
//:: Combat Simulation System
//:://////////////////////////////////////////////
//:: Created By: Oni5115
//:: Created On: July 16, 2004
//:: Modified by motu99 On: April 7, 2007
//:://////////////////////////////////////////////
//:: Code based on Aaon Graywolf's inc_combat.nss
//:: and Soul Taker's additions in inc_combat2.nss
//:://////////////////////////////////////////////
//:: Adds a great deal of additional functionality
//:: to the older combat system to make combat simulation
//:: more accurate and much easier to use.
//:://////////////////////////////////////////////
//:: Current Features:
//:://////////////////////////////////////////////
//:: Easy to use function for performing an entire attack round.  PerformAttackRound
//:: Easy to use function for performing a single attack.         PerformAttack
//:: Proper calculation of attack bonus including any bonus effects on weapon or spells.
//:: Proper calculation of weapon damage including any bonus effects or spell effects.
//:: Proper calculation of bonus, main, and off-hand attacks.
//:: Support for off-hand attacks from double (sided) weapons
//:: Proper calculation of enemy AC.
//:: Proper application of sneak attacks.
//:: Proper application of touch attacks.
//:: All On Hit: Cast Spell abilities working
//:: All On Hit: Unique Power abilities working
//:: All On Hit: properties working  (daze, stun, vorpal, poison, disease, etc.)
//:: All known weapon/spell damage bonuses are counted
//::
//:://////////////////////////////////////////////
//:: Support for the following feats:
//:://////////////////////////////////////////////
//:: Weapon Focus, Epic Weapon Focus, Epic Prowess,
//:: Improved Critical, Overwhelming Critical, Devastating Critical
//:: Weapon Specialization, Epic Weapon Specialization,
//:: Weapon Finesse, Inuitive Attack, Zen Archery,
//::
//:: Expertise, Improved Expertise,
//:: Cleave, Great Cleave, Circle Kick,
//:: Power Attack, Improved Power Attack, Supreme Power Attack,
//:: Power Shot, Improved Power Shot, Supreme Power Shot,
//::
//:: Rapid Shot, Rapid Reload, Extra Shot, Flurry of Blows,
//:: Martial Flurry, Furious Assult, One Strike Two Cuts,
//::
//:: Epic Dodge, Self Concealment I-V, Blind Fight, Crippling Strike
//::
//:: All Arcane Archer and Weapon Master Feats.
//:: Favored Enemy, Bane of Enemies,
//:: Battle Training, Divine Might, Bard Song, Thundering Rage
//:: large vs small creature size
//::
//:: Note: If you notice any feats missing let Oni5115 know
//::       They might be accounted for, but not added to the list;
//::       or they might not be implemented yet.
//::
//:://////////////////////////////////////////////
//:: Current Limitations:
//:://////////////////////////////////////////////
//::
//:: Coup De Grace does not take into account bonus damage [Except from touch attack spells]
//:: Calculation of Enemy AC does not take into account bonus vs. racial type or alignment type.
//:: Weapon Range is not taken into account in melee combat (whenever we are within 10 feet, we will apply the damage)
//:: a few "hardwired" spells on weapon and armor of the type IP_CONST_ONHIT_<spellname>
//:: are not yet implemented (but we now know how to do them, so hopefully in a later release)
//::
//:://////////////////////////////////////////////
//:: Tested:
//:://////////////////////////////////////////////
//:: Weapon Information and Damage
//:: Elemental Information and Damage
//:: Sneak Attack Functions
//:: On Hit: Cast Spell
//:: On Hit: Unique Power
//:: On Hit: properties
//:: Perform Attack Round
//:: Perform Attack
//:: Dark Fire and Flame Weapon
//:: Cleave, Great Cleave
//:://////////////////////////////////////////////
//:: Things to Test:
//:://////////////////////////////////////////////
//:: On Hit: Slay Race/Alignment Group/Alignment
//::         Wounding, Disease, Poison,
//::
//:: Bug Fix for Sanctuary/invis/stealth not being removed
//:: Coup De Grace
//:: Circle Kick
//:: Unarmed Damage Calculation (motu99: partially tested)
//::
//:: Blinding Speed (should count as haste effect)
//:://////////////////////////////////////////////
//:: Known Bugs:
//:://////////////////////////////////////////////
//::
//::  GetIsFlanked does not work reliably
//::  AB calculation (mostly done at beginning of round) ignores situational adjustments (such as when attackers come within melee range of a ranged attacker)
//::  Damage calculation (partly done at beginning or round) ignores situational adjustments (for instance, favored enemy bonus is not adjusted when defender changes)
//::
//:://////////////////////////////////////////////

// various modes for the prc-combat routines (these are bit-flags)

// should be used when PerformAttack or PerformAttackRound are run from a heartbeat
// and the aurora engine runs in parallel to prc scripted combat (such as for more than 2
// offhand attacks or natural weapon attacks). Ensures that when we are not physically attacking
// any more, the scripted combat is aborted
const int PRC_COMBATMODE_HB = 1;

// allows a switch of target (mostly used when scripted combat and aurora combat run in parallel)
const int PRC_COMBATMODE_ALLOW_TARGETSWITCH = 2;

// will not abort a scripted melee attack (or attack round), when the target is out of range and cannot be reached with a five foot step
// not applicable for scripted ranged attacks (these are always executed, because so far the range of ranged weapons is not well implemented)
const int PRC_COMBATMODE_ABORT_WHEN_OUT_OF_RANGE = 4;

// if set, will issue an ActionAttack Command on the last attack of  a scripted attack round
// if used in PerformAttack(). will issue an ActionAttack command after the (single) attack
const int PRC_COMBATMODE_ACTIONATTACK_ON_LAST = 8;

// will bypass damage reduction, if on
const int PRC_COMBATMODE_BYPASS_DR = 16; // not yet implemented

// constant ints for touch attacks
// using these helps determing which type of touch attack to perform.
// using the spell versions if your spell does not use a weapon.
const int TOUCH_ATTACK_MELEE  = 1;
const int TOUCH_ATTACK_RANGED = 2;
const int TOUCH_ATTACK_MELEE_SPELL  = 3;
const int TOUCH_ATTACK_RANGED_SPELL = 4;

// Distances
const float MELEE_RANGE_FEET = 10.;
const float MELEE_RANGE_METERS = 3.05;
const float RANGE_15_FEET_IN_METERS = 4.92;
const float RANGE_5_FEET_IN_METERS = 1.64;

// maximum distance (in meters) where we actually rush to do an attack
const float fMaxAttackDistance = 20.;

// constants that determine at what class or skill levels specific classes get specific feats or abilities
const int WEAPON_MASTER_LEVEL_KI_CRITICAL = 7;
const int WEAPON_MASTER_LEVEL_INCREASED_MULTIPLIER = 5;
const int WEAPON_MASTER_LEVEL_SUPERIOR_WEAPON_FOCUS = 5;
const int WEAPON_MASTER_LEVEL_EPIC_SUPERIOR_WEAPON_FOCUS = 13;

const int RANGER_LEVEL_DUAL_WIELD = 1;
const int RANGER_LEVEL_ITWF = 9;

const int TEMPEST_LEVEL_STWF = 10;
const int TEMPEST_LEVEL_GTWF = 5;
const int TEMPEST_LEVEL_ITWF = 1;
const int TEMPEST_LEVEL_ABS_AMBIDEX = 8;

const int BARD_LEVEL_FOR_BARD_SONG_AB_2 = 8;
const int BARD_PERFORM_SKILL_FOR_BARD_SONG_AB_2 = 15;
const int BARD_LEVEL_FOR_BARD_SONG_DAM_2 = 3;
const int BARD_PERFORM_SKILL_FOR_BARD_SONG_DAM_2 = 9;
const int BARD_LEVEL_FOR_BARD_SONG_DAM_3 = 14;
const int BARD_PERFORM_SKILL_FOR_BARD_SONG_DAM_3 = 21;

//consts for  weapon sizes (should be equal to creature sizes)
const int WEAPON_SIZE_SMALL = CREATURE_SIZE_SMALL;

// spell id constants

// motu99: this is the spell number for the Create magic tatoo spell that increases AB by 2;
// not sure if it is a bug; in prc_spell_const the create_magic_tatoo spell has a number of 3166
// fluffyamoeba - it's line 3166 in spells.2da atm, so getting rid of this
// const int SPELL_CREATE_MAGIC_TATOO_2 = 3167;

// motu99: these spell numbers appeared directly in the code
// don't know why. Put them here with a "_2" extension, so we can check what the real constants are
// const int SPELL_BARD_SONG_2 = 411;
// const int SPELL_BARD_CURSE_SONG_2 = 644;
const int SPELL_HELLINFERNO_2 = 762;
// const int SPELL_DIVINE_WRATH_2 = 622; SPELLABILITY_DC_DIVINE_WRATH in nwscript.nss
//const int SPELL_CLERIC_WAR_DOMAIN_POWER_2 = 380; not used, also in nwscript.nss
const int SPELL_EPIC_DEADEYE_2 = 4013;

const int DEBUG_BATTLE_ARDOR = FALSE;
const int DEBUG_BATTLE_CUNNING = FALSE;
const int DEBUG_BATTLE_FLANKING = FALSE;

//:://///////////////////////////////////////////////////////////////
//::  Simple utility functions (# attacks, BAB) - might want to copy those inline
//:://///////////////////////////////////////////////////////////////

// calculates the BAB that a pure fighter with the Hit Dice (characer level)  would have
int GetFighterBAB(int iHD);

// calculates the BAB that the character had at level 20
// assumes that we are above level 20!
int GetLevel20BAB(int iBAB, int iHD);

// calculates the # attacks, for normal weapons (non-monk); no maximum if called with high iBAB
int GetAttacks(int iBAB, int iHD);

// calculates the (bioware) number of attacks for an unarmed monk (maximum: 6 attacks)
// this is the Bioware implementation, which includes BAB from other classes and caps at 6
int GetMonkAttacks(int iBAB, int iHD);

// calculates the number of unarmed attacks for an unarmed class (usually monk) with iMonkLevel unarmed levels
// maximum: 5 attacks; iMonkLevels should include levels from all "unarmed" PrC classes, such as brawler etc.
// use GetUBABLevel to calculate the total number of "unarmed" class levels
int GetPnPMonkAttacks(int iMonkLevel);


//:://////////////////////////////////////////////
//::  Weapon Information Functions
//:://////////////////////////////////////////////

// Returns DAMAGE_TYPE_* const of weapon
int GetDamageTypeByWeaponType(int iWeaponType);
int GetWeaponDamageType(object oWeap);

// returns TRUE if weapon is ranged
// checks for bow, crossbow, sling, dart, throwing axe, shuriken, but also ammo: arrow, bullet, bolt
int GetIsRangedWeaponType(int iWeaponType);

// returns TRUE if weapon is a throwing weapon
// checks for dart, throwing axe, shuriken
int GetIsThrowingWeaponType(int iWeaponType);

// returns true if weapon is two-handed
// does not include double weapons
int GetIsTwoHandedMeleeWeaponType(int iWeaponType);
int GetIsTwoHandedMeleeWeapon(object oWeap);

// returns true if it is a creature weapon, one of the following base types:
// CBLUDGWEAPON, CPIERCWEAPON, CSLASHWEAPON
int GetIsCreatureWeaponType(int iWeaponType);
int GetIsCreatureWeapon(object oWeap);

// returns true, if unarmed (base_item_invalid), glove or creature weapon
int GetIsNaturalWeaponType(int iWeaponType);
int GetIsNaturalWeapon(object oWeap);

// returns true if the weapon is a simple weapon
// returns 1 if simple melee weapon
// returns 2 if ranged simple weapon
int GetIsSimpleWeaponType(int iWeaponType);
int GetIsSimpleWeapon(object oWeap);

// returns true, if unarmed (base_item_invalid) or kama
// does not check for gloves or bracers
int GetIsMonkWeaponTypeOrUnarmed(int iWeaponType);
int GetIsMonkWeaponOrUnarmed(object oWeap);

// returns true, if not unarmed (base_item_invalid), not shield, and not torch
// implicitly assumes, that iWeaponType is the base item type of the object held in the left hand.
// This can only be a weapon, a shield, or a torch
int GetIsOffhandWeaponType(int iWeaponType);
int GetIsOffhandWeapon(object oWeapL);

// returns true, if it is a double sided weapon
int GetIsDoubleSidedWeaponType(int iWeaponType);
int GetIsDoubleSidedWeapon(object oWeap);

// similar to GetFeatByWeaponType(), but should be much faster,
// because it only loops once over the weapon types
// and returns all feats relevant for the weapon in a struct
struct WeaponFeat GetAllFeatsOfWeaponType(int iWeaponType);

// Returns the low end of oWeap's critical threat range
// Accounts for Keen and Improved Critical bonuses
//int GetWeaponCriticalRange(object oPC, object oWeap);
int GetWeaponCriticalRange(object oPC, object oWeap, int iTouchAttackType = FALSE);

// returns the critical multiplier of the weapons base type
int GetCriticalMultiplierOfWeaponType(int iWeaponType);

// Returns the players critical hit damage multiplier
// takes into account weapon master's increased critical feat
int GetWeaponCritcalMultiplier(object oPC, object oWeap);

// returns the inventory slot (constant) in which to look for the ammunition
int GetAmmunitionInventorySlotFromWeaponType(int iWeaponType);

// Return the proper ammunition based on the weapon
object GetAmmunitionFromWeaponType(int iWeaponType, object oAttacker);
object GetAmmunitionFromWeapon(object oWeapon, object oAttacker);


//:://////////////////////////////////////////////
//::  Combat Information Functions
//:://////////////////////////////////////////////

// Returns true if melee attacker within 15 feet
// motu99: This actually was (and is) 10 feet
int GetMeleeAttackers15ft(object oPC = OBJECT_SELF);

// estimates how much the range between oAttacker and oDefender is reduced due to the size of both creatures
// will add  a meter for every size integer above CREATURE_SIZE_MEDIUM
float GetSizeAdjustment(object oDefender, object oAttacker);

// Returns true if melee attacker is in range to attack target (e.g. 10 feet)
// if bSizeAdjustment is True, it will consider the creatures sizes
int GetIsInMeleeRange(object oDefender, object oAttacker, int bSizeAdjustment = TRUE);

// returns the sum of all class levels that give an unarmed base attack bonus (UBAB)
int GetUBABLevel(object oPC);

// if a creature weapon is equipped in the right slot (INVENTORY_SLOT_CWEAPON_R,)
// it randomly selects one of the (up to three) creature weapons in the right/left/back
// creature weapon slots with a chance right/left/back of 5:5:2
// if no creature weapon is equipped, returns gloves (or base_item_invalid, of no gloves)
object GetUnarmedWeapon(object oPC);

// Returns true if player has nothing in the right hand
int GetIsUnarmed(object oPC);

// returns true if we have something in the left creature weapon slot, or if we have monk levels
int GetIsUnarmedFighter(object oPC);

// Returns true if player is a monk and has a monk weapon equipped (or is unarmed)
int GetHasMonkWeaponEquipped(object oPC);

// returns true, if we have a cross bow equipped and do not posses the rapid reload feat
int GetHasCrossBowEquippedWithoutRapidReload(object oPC);

// Returns number of "normal" attacks per round for the main hand
// returns the correct number of unarmed attacks, if oPC has monk levels and has a monk weapon equipped or is unarmed
// returns only one attack, if wielding  a cross-bow without the rapid reload feat (unless bIgnoreCrossBow = TRUE)
// does not include any "bonus" attacks from Haste, combat modes (flurry of blows), class specifics (One Strike Two Cuts) etc.
// However, the number of "normal" attacks might be increased due to special (attack) boni to BAB from spells (such as Tenser's or Divine Power)
// in order to calculate the attack # with such boni, call the function with a non-zero value of iBABBonus (negative values are possible)
// the minimum # attacks returned is always 1; the maximum number returned is 5 (for armed and unarmed combat)
// if the PRC_BIOWARE_MONK_ATTACKS switch is on, the maximum number returned is 6 (only for monk attacks - unarmed or kama)
int GetMainHandAttacks(object oPC, int iBABBonus = 0, int bIgnoreCrossBow = FALSE);

// Returns number of offhand attacks per round for off-hand
// needs number of mainhand attacks in order to ensure, that offhand attacks are always less or equal mainhand attacks
// also needs number of mainhand attacks, if the oPC has the perfect two weapon fighting (PTWF) feat
// the function will calculate the number of mainhandattacks (without bonus attacks) on its own, if passed iMainHandAttacks = 0
// otherwise it will assume that the (non-zero) number given to iMainHandAttacks is the correct number of mainhand attacks
// if you want the number of main hand attacks to include bonus attacks, calc the Mainhandattacks yourself and add whatever bonus attacks you like
int GetOffHandAttacks(object oPC, int iMainHandAttacks = 0);

// Returns a specific alignment property.
// Returns a line number from iprp_alignment.2da
// Used to determine the attack and damage bonuses vs. alignments
int GetItemPropAlignment(int iGoodEvil,int iLawChaos);

//:://////////////////////////////////////////////
//::  Other utility functions
//:://////////////////////////////////////////////

int GetAttackModVersusDefender(object oDefender, object oAttacker, object oWeapon, int iTouchAttackType = FALSE);

int GetDiceMaxRoll(int iDamageConst);

// all of the ten ip dice constants are supposed to lie between 6 and 15
int GetIsDiceConstant(int iDice);

// returns the highest critical bonus damage constant on the weapon
// note that this is the IP_DAMAGE_CONSTANT, not the damage itself
// only compares the damage constants, so does not differentiate between dice and constant damage (and assumes, that damage constants are ordered appropriately)
int GetMassiveCriticalBonusDamageConstantOfWeapon(object oWeapon);

// Find nearest valid living enemy creature, that is not oOldDefender, within the specified range (measured in meters) of oAttacker
// if there is no valid living target within the specified range, return the first target (valid or unvalid) found out of range
// the range fDistance is measured in meters; default distance is 3.05 meters (= 10 feet = melee range)
object FindNearestNewEnemyWithinRange(object oAttacker, object oOldDefender, float fDistance = MELEE_RANGE_METERS);

// finds the nearest valid enemy that is not oOldDefender
// (should only return living enemies, but bioware functions used in the code was bugged, so it might return a valid, but dead enemy)
object FindNearestNewEnemy(object oAttacker, object oOldDefender);

// finds the nearest valid enemy
object FindNearestEnemy(object oAttacker);

// clears all actions (but not the combat state) and moves to the location or oTarget
void ClearAllActionsAndMoveToObject(object oTarget, float fRange = 2.0);

// checksall equipped items of the oPC for the Haste property
int GetHasHasteItemProperty(object oPC);

// calculates bonus attacks and their associated penalties due to spell effects on oAttacker, such as Haste, One Strike Two Cuts, etc.
// does not include bonus attacks and penalties from combat modes, such as flurry of blows
struct BonusAttacks GetBonusAttacks(object oAttacker);

// equips the first ammunition it finds in the inventory that works with the (ranged) weapon in the right hand
// returns the equipped new ammunition
object EquipAmmunition(object oPC);

//Gets the total damage reduction of a creature for a given weapon
//if any new damage reduction spells/powers/etc are added, add to this function
struct DamageReducers GetTotalReduction(object oPC, object oTarget, object oWeapon);

//:://////////////////////////////////////////////
//::  Debug Functions
//:://////////////////////////////////////////////

// returns the name of the ACTION_* constant
string GetActionName(int iAction);

// experimental, not yet used
int GetIsPhysicalCombatAction(int iAction);

// used in AttackLoopLogic in order to have prc combat and aurora combat running smoothly
// checks whether the anticipated target (oDefender) selected by prc combat must be changed
// due to actions taken by the aurora engine (or the player character)
// returns the most suitable target for the next prc attack
object CheckForChangeOfTarget(object oAttacker, object oDefender, int bAllowSwitchOfTarget = FALSE);

// returns name of the ITEM_PROPERTY_* constant
// removed as unused
// string GetItemPropertyName(int iItemType);

// returns name of the EFFECT_TYPE_* const
// removed as unused
//string GetEffectTypeName(int iEffectType);

// returns name of the DAMAGE_BONUS_* constant
// removed as unused
// string GetDamageBonusConstantName(int iDamageType);

// returns name of the IP_CONST_DAMAGEBONUS_* constant
// removed as unused
// string GetIPDamageBonusConstantName(int iDamageType);
// moved to inc_debug and renamed
// string DebugStringEffect(effect eEffect);
// replaced with DebugProp2Str()
// string DebugStringItemProperty(itemproperty ip);


//:://////////////////////////////////////////////
//::  Attack Bonus Functions
//:://////////////////////////////////////////////

// Returns the magical attack bonus modifier on the attacker
// checks for all the spells and determines the proper bonuses/penalties
int GetMagicalAttackBonus(object oAttacker, object oTarget);

// Returns Weapon Attack bonus or penalty
// inlcuding race and alignment checks
int GetWeaponAttackBonusItemProperty(object oWeap, object oDefender);

// Returns the proper AC for the defender vs. this attacker.
// takes into account being denied dex bonus to ac, etc.
int GetDefenderAC(object oDefender, object oAttacker, int bIsTouchAttack = FALSE);

// Returns the Attack Bonus for oAttacker attacking oDefender
// iOffhand = 0 means attack is from main hand (default)
// iOffhand = 1 for an off-hand attack
int GetAttackBonus(object oDefender, object oAttacker, object oWeap, int iOffhand = 0, int iTouchAttackType = FALSE);

// Returns 0 on miss, 1 on hit, and 2 on Critical hit
// Works for both Ranged and Melee Attacks
// iOffhand 0 = main; 1 = off-hand
// iAttackBonus 0 = calculate it; Anything else and it will use that value and will not calculate it.
// This is mainly for when you call PerformAttackRound to do multiple attacks,
// so that it does not have to recalculate all the bonuses for every attack made.
// int iMod = 0;  iMod just modifies the attack roll.
// If you are coding an attack that reduces the attack roll, put the number in the iMod slot.
// bShowFeedback tells the script to show the script feedback
// fDelay is the amount of time to delay the display of feedback
int GetAttackRoll(object oDefender, object oAttacker, object oWeapon, int iOffhand = 0, int iAttackBonus = 0, int iMod = 0, int bShowFeedback = TRUE, float fDelay = 0.0, int iTouchAttackType = FALSE);

//:://////////////////////////////////////////////
//::  Damage Bonus Functions
//:://////////////////////////////////////////////

// returns sum of levels of all classes that have favored enemies
int GetFavoredEnemyLevel(object oAttacker);

// returns the feat constant for the favored enemy feat versus a specific racial type
int GetFavoredEnemyFeat(int iRacialType);

// Returns Favored Enemy Bonus Damage
// int GetFavoredEnemeyDamageBonus(object oDefender, object oAttacker); // old functions, replaced by the new one:
int GetFavoredEnemyDamageBonus(object oDefender, object oAttacker);

// Get Mighty Weapon Bonus
int GetMightyWeaponBonus(object oWeap);

// Returns the Enhancement Bonus of oWeapon
// Can also return - enhancements (penalties)
int GetWeaponEnhancement(object oWeapon, object oDefender, object oAttacker);

// Used to return the Enhancement Bonus for monks
// called by GetAttackDamage to make sure monks
// get proper damage power for cutting through DR
// Note: Calls GetWeaponEnhancement as well, so when determining Damage Power
//       Just use GetMonkEnhancement instead.
int GetMonkEnhancement(object oWeapon, object oDefender, object oAttacker);

// Returns the DAMAGE_POWER_* of a weapon
// For monks send gloves instead of weapon
// function makes use of above enhancement functions
// to determine Enhancement vs. Alignment and everything
int GetDamagePowerConstant(object oWeapon, object oDefender, object oAttacker);

// Returns Enhancement bonus on Ammunition
// oWeap = Weapon used by Attacker
int GetAmmunitionEnhancement(object oWeapon, object oDefender, object oAttacker);

// Returns an integer amount of damage from a constant
// iDamageConst = DAMAGE_BONUS_* or IP_CONST_DAMAGEBONUS_*
int GetDamageByConstant(int iDamageConst, int iItemProp);

// Utility function used by GetWeaponBonusDamage to store the damage constants
// Prevents same code from being written multiple times for various damage properties
struct BonusDamage GetItemPropertyDamageConstant(int iDamageType, int iDice, struct BonusDamage weapBonusDam);

// Returns a struct filled with IP damage constants for the given weapon.
// Used to add elemental damage to combat system.
// Can also get information from Weapon Ammunition if used in place of oWeapon
struct BonusDamage GetWeaponBonusDamage(object oWeapon, object oTarget);

// gets the Dice parameters (dice side, number of dice to roll) from a monster weapon
struct Dice GetWeaponMonsterDamage(object oWeapon);

// Stores bonus damage from spells into the struct
struct BonusDamage GetMagicalBonusDamage(object oAttacker, object oTarget);

// Returns damage caused by each attack that should remain constant the whole round
// Mainly things from feat, strength bonus, etc.
// iOffhand = 0 means attack is from main hand (default)
// iOffhand = 1 for an off-hand attack
int GetWeaponDamagePerRound(object oDefender, object oAttacker, object oWeap, int iOffhand = 0);

// Returns Damage dealt by weapon
// Works for both Ranged and Melee Attacks
// Defaults typically calculate everything for you, but cacheing the data and reusing it
// can make things run faster so I left them as optional parameters.
// sWeaponBonusDamage = result of a call to GetWeaponBonusDamage
// sSpellBonusDamage  = result of a call to GetMagicalBonusDamage
// iOffhand: 0 = main; 1 = off-hand
// iDamage: 0 = calculate the GetWeaponDamagePerRound; Anything else and it will use that value
// and will not calculate it.  This is mainly for when you call PerformAttackRound
// to do multiple attacks,  so that it does not have to recalculate all the bonuses
// for every attack made.
// bIsCritical = FALSE is not a critical; true is a critical hit. (Function checks for crit immunity).
// iNumDice:  0 = calculate it; Anything else is the number of dice rolled
// iNumSides: 0 = calculate it; Anything else is the sides of the dice rolled
// iCriticalMultiplier: 0 = calculate it; Anything else is the damage multiplier on a critical hit
effect GetAttackDamage(object oDefender, object oAttacker, object oWeapon, struct BonusDamage sWeaponBonusDamage, struct BonusDamage sSpellBonusDamage, int iOffhand = 0, int iDamage = 0, int bIsCritical = FALSE, int iNumDice = 0, int iNumSides = 0, int iCriticalMultiplier = 0);

//:://////////////////////////////////////////////
//::  Attack Logic Functions
//:://////////////////////////////////////////////

// utility function to apply any onhit-property (found on an item) to oTarget
// assumes that the Item Property Type of ip is ITEM_PROPERTY_ON_HIT_PROPERTIES
// cycles through all the known subtypes in order to properly perform the action
struct OnHitSpell DoOnHitProperties(itemproperty ip, object oTarget);

// same as DoOnHitProperties, only cycles through on Monster hit subtypes
// e.g. the item property type must be ITEM_PROPERTY_ON_MONSTER_HIT
void DoOnMonsterHit(itemproperty ip, object oTarget);

// Called by ApplyOnHitAbilities
// properly applies on hit abilties with a X% chance of firing that last Y rounds.
// in other words... on hit stun, daze, sleep, blindness, etc.
// iDurationVal - iprp_onhitdur.2da entry number
// eAbility -  the proper effect this ability will apply to the target (will be applied temporarily)
// eVis     - the visual effect to apply (will be applied instantly)
void ApplyOnHitDurationAbiltiies(object oTarget, int iDurationVal, effect eAbility, effect eVis);

// applies any On Hit abilities like spells, vampiric regen, poison, vorpal, stun, etc.
// if you sent a WEAPON
// oTarget = one being hit | oItemWielder = one attacking
// if you send   ARMOR
// oTarget = one attacking | oItemWielder = one being hit
void ApplyOnHitAbilities(object oTarget, object oItemWielder, object oItem);

// Due to the lack of a proper sleep function in order to delay attacks properly
// I needed to make a separate function to control the logic of each attack.
// AttackLoopMain calls this function, which in turn uses a delay and calls AttackLoopMain.
// This allowed a proper way to delay the function.
void AttackLoopLogic(object oDefender, object oAttacker,
    int iBonusAttacks, int iMainAttacks, int iOffHandAttacks, int iMod,
    struct AttackLoopVars sAttackVars, struct BonusDamage sMainWeaponDamage,
    struct BonusDamage sOffHandWeaponDamage, struct BonusDamage sSpellBonusDamage,
    int iOffhand, int bIsCleaveAttack);

// Function used by PerformAttackRound to control the flow of logic
// this function calls AttackLoopLogic which then calls this function again
// making them recursive until the AttackLoopMain stops calling AttackLoopLogic
void AttackLoopMain(object oDefender, object oAttacker,
    int iBonusAttacks, int iMainAttacks, int iOffHandAttacks, int iMod,
    struct AttackLoopVars sAttackVars, struct BonusDamage sMainWeaponDamage,
    struct BonusDamage sOffHandWeaponDamage, struct BonusDamage sSpellBonusDamage);

/**
 * Performs a full attack round and can add in bonus damage damage/effects.
 * Will perform all attacks and accounts for weapontype, haste, twf, tempest twf, etc.
 * If the first attack hits, a local int called "PRCCombat_StruckByAttack" will be TRUE
 * on the target for 1 second.
 *
 * @param oDefender      The object being attacked.
 * @param oAttacker      The object doing the attacks.
 *
 * @param eSpecialEffect Any special Vfx or other effects the attack should use IF successful.
 * @param eDuration      specifies the duration of the applied effect(s)
 *                       0.0 = DURATION_TYPE_INSTANT, effect lasts 0.0 seconds.
 *                      >0.0 = DURATION_TYPE_TEMPORARY, effect lasts the amount of time put in here.
 *                      <0.0 = DURATION_TYPE_PERMAMENT!!!!!  Effect lasts until dispelled.

 * @param iAttackBonusMod  Is the attack modifier - Will effect all attacks if bEffectAllAttacks is on.
 * @param iDamageModifier  Should be either a DAMAGE_BONUS_* constant or an integer amount of damage.
 *                         Give an integer if the attack effects ONLY the first attack!
 * @param iDamageType      DAMAGE_TYPE_* constant.
 *
 * @param bEffectAllAttacks  If FALSE will only effect first attack, otherwise effects all attacks.
 *
 * @param sMessageSuccess  Message to display on a successful hit. (i.e. "*Sneak Attack Hit*")
 * @param sMessageFailure  Message to display on a failure to hit. (i.e. "*Sneak Attack Miss*")
 *
 * @param bApplyTouchToAll  Applies a touch attack to all attacks - FALSE if only first attack is a touch attack.
 * @param iTouchAttackType  TOUCH_ATTACK_* const - melee, ranged, spell melee, spell ranged
 *
 * @param bInstantAttack    If TRUE, all attacks are performed at the same time, instead of over a round.
 *                          Default: FALSE
 * @param bCombatModeFlags  various bit-wise flags that control the scripted combat
 *                                                  see PRC_COMBATMODE_* constants for more info
 */
void PerformAttackRound(object oDefender, object oAttacker,
    effect eSpecialEffect, float eDuration = 0.0, int iAttackBonusMod = 0,
    int iDamageModifier = 0, int iDamageType = 0, int bEffectAllAttacks = FALSE,
    string sMessageSuccess = "", string sMessageFailure = "",
    int bApplyTouchToAll = FALSE, int iTouchAttackType = FALSE,
    int bInstantAttack = FALSE, int bCombatModeFlags = 0);

/**
// Performs a single attack and can add in bonus damage damage/effects
// If the first attack hits, a local int called "PRCCombat_StruckByAttack" will be TRUE
// on the target for 1 second.
// [Note that even though you only perform a single attack, there could be more than 1 attack,
// if the attacker has a feat like cleave or circle kick. The local int is NOT set on the bonus attacks!
//
// eSpecialEffect -  any special Vfx or other effects the attack should use IF successful.
// eDuration - specifies the duration of the applied effect(s)
//           0.0 = DURATION_TYPE_INSTANT, effect lasts 0.0 seconds.
//          >0.0 = DURATION_TYPE_TEMPORARY, effect lasts the amount of time put in here.
//          <0.0 = DURATION_TYPE_PERMAMENT!!!!!  Effect lasts until dispelled.
// iAttackBonusMod is the attack modifier
// iDamageModifier - is always an integer in PerformAttack()
//      [Note that iDamageModifier might be a DAMAGE_BONUS_* const in PerformAttackRound]
// iDamageType = DAMAGE_TYPE_*
// sMessageSuccess - message to display on a successful hit. (i.e. "*Sneak Attack Hit*")
// sMessageFailure - message to display on a failure to hit. (i.e. "*Sneak Attack Miss*")
// iTouchAttackType - TOUCH_ATTACK_* const - melee, ranged, spell melee, spell ranged
// oRightHandOverride - item to use as if in the right hand
// oLeftHandOverride - item to use as if in the left hand
// nHandednessOverride - if TRUE, count as offhand attack
// bCombatModeFlags - various bit-wise flags that control the scripted combat
// see PRC_COMBATMODE_* constants for more info
*/
void PerformAttack(object oDefender, object oAttacker,
    effect eSpecialEffect, float eDuration = 0.0, int iAttackBonusMod = 0,
    int iDamageModifier = 0, int iDamageType = 0,
    string sMessageSuccess = "", string sMessageFailure = "",
    int iTouchAttackType = FALSE,
    object oRightHandOverride = OBJECT_INVALID, object oLeftHandOverride = OBJECT_INVALID,
    int nHandednessOverride = 0, int bCombatModeFlags = 0); // motu99: changed default of nHandednessOverride to FALSE (was -1)

//:://///////////////////////////////////////
//::  Structs
//:://///////////////////////////////////////

// stores all Feat constants that apply to a particular weapon base type
struct WeaponFeat
{
    int Focus;
    int Specialization;
    int EpicFocus;
    int EpicSpecialization;
    int ImprovedCritical;
    int OverwhelmingCritical;
    int DevastatingCritical;
    int WeaponOfChoice;
    int SanctifyMartialStrike;
    int VileMartialStrike;
};

struct WeaponFeat InitWeaponFeat(int value)
{
    struct WeaponFeat sFeat;
    sFeat.Focus = value;
    sFeat.Specialization = value;
    sFeat.EpicFocus = value;
    sFeat.EpicSpecialization = value;
    sFeat.ImprovedCritical = value;
    sFeat.OverwhelmingCritical = value;
    sFeat.DevastatingCritical = value;
    sFeat.WeaponOfChoice = value;
    sFeat.SanctifyMartialStrike = value;
    sFeat.VileMartialStrike = value;
    return sFeat;
}

struct BonusDamage
{
    // dice_* vars are for the damage bonus IP that are NdX dice elemental damage
    int dice_Acid, dice_Cold, dice_Fire, dice_Elec, dice_Son;
    int dice_Div, dice_Neg, dice_Pos;
    int dice_Mag;
    int dice_Slash, dice_Pier, dice_Blud;

    // dam_* vars are for +/- X damage bonuses
    int dam_Acid, dam_Cold, dam_Fire, dam_Elec, dam_Son;
    int dam_Div, dam_Neg, dam_Pos;
    int dam_Mag;
    int dam_Slash, dam_Pier, dam_Blud;
};

struct AttackLoopVars
{
    // most of these variables don't change during the attack loop logic, they are just
    // recursively passed back to the function.

    // the delay of the functions recursion and the duration of the eSpecialEffect
    float fDelay, eDuration;

    // does the special effect apply to all attacks? is it a ranged weapon?
    int bEffectAllAttacks, bIsRangedWeapon;

    // Ammo if it is a ranged weapon, and both main and off-hand weapons
    object oAmmo, oWeaponR, oWeaponL;

    // all the main hand weapon data
    int iMainNumDice, iMainNumSides, iMainCritMult, iMainAttackBonus, iMainWeaponDamageRound;

    // all the off hand weapon data
    int iOffHandNumDice, iOffHandNumSides, iOffHandCritMult, iOffHandAttackBonus, iOffHandWeaponDamageRound;

    // special effect applied on first attack, or all attacks
    effect eSpecialEffect;
    //when the new PRC effect system is in place, this will be a reference to a local effect on the module
    //that exists temporarilly and will be destroyed at the end
    //string sEffectLocalName;

    //  the damage modifier and damage type for extra damage from special attacks
    int iDamageModifier, iDamageType;

    // string displayed on a successful hit, or a miss
    string sMessageSuccess, sMessageFailure;

    // ints for internal logic (they can change during the attack or attack round)
    int iCleaveAttacks; // number of cleave attacks performed in the round; does not count cleaves within cleaves
    int iCircleKick; // number of circle kicks per round (only one allowed)
    int iAttackNumber; // number of attacks already performed in the round; does not count double or triple cleaves
    int bUseMonkAttackMod; // if true, we use the monk attack modifier (-3 instead of -5 for additional attacks per round)
    int bApplyTouchToAll; // duplicates the parameter of PerformAttackRound() for use in Attack logic functions
    int iTouchAttackType; // duplicates the parameter of PerformAttack() and PerformAttackRound() for use in Attack logic functions
    int bFiveFootStep; // determines whether we already did a five foot step in the full combat round
    int bMode; // flag wit bitwise settings that determines various combat mode settings, such as offhand attack checks etc.
};

// used to calculate the BonusAttacks (due to spell effects such as Haste, One Strike Two Cuts or similar)
// and the attack penalty associated with the bonus attacks
struct BonusAttacks
{
    int iNumber;
    int iPenalty;
};

// used to store sides and number of dice to be rolled
struct Dice
{
    int iNum;
    int iSides;
};

// stores SpellID and DC of an onhit spell
struct OnHitSpell
{
    int iSpellID;
    int iDC;
};

//internal struct to store damage reduction
struct DamReduction
{
    int nRedLevel;
    int nRedAmount;
};

//struct of damage reduction/resistance.
//First value is for static reduction like DR 5/-
//second value is for persent immunities like 25% Slashing Immunity
struct DamageReducers
{
    int nStaticReductions;
    int nPercentReductions;
};

// "quasi global" Vars needed to pass information between AttackLoopMain and AttackLoopLogic or other utitily functions used by these two

/*
// motu99: these vars work similar to locals attached to an object. They have global scope, but in contrast to the so called locals they have limited lifetime.
// GLOBAL SCOPE: the variables are defined outside of any function, thus they are visible by all functions (and are initialized when main() starts up)
// They are compiled into the code of any main() function created by the system, if that main() calls a prc_inc_combat function that uses these variables (such as PerformAttack)
// LIMITED LIFETIME: These global scope vars only "live" as long as the main() function started within the context of an object (usally an event or an action assigned to a PC or NPC) has not terminated
// Whenever the main() function is called anew, all quasi-global variables are initialized to their default values
// WARNING: no changes from the last call to the main() function are remembered!
// USE: These variables are used to pass information between functions that execute within a single main(). They are much faster to access than the so called locals attached to an object
// LIMITATIONS: They do not persist over a DelayCommand() or AssignCommand() call. Whenever you call a function via DelayCommand or AssignCommand
// the system creates a new (!) main() function in order to actually execute the function. So any function called via DelayCommand or AssignCommand will have
// all of its quasi-global variables initialzed to their default values! The values of these variables at the time when the DelayCommand() or AssignCommand() was executed,
// are *not remembered* and not transferred to the function called within the DelayCommand() or AssignCommand().
// Therefore when AttackLoopLogic() calls AttackLoopMain() in a DelayCommand(), in order to do any left over attacks in the round after a proper delay,
// all these variables are initialized to their default values. If one wants to remember the values of these variables, one has to pass them to the function directly
// (either as individual parameters, or as a collection of parameters in a struct)
*/

/*
// motu99: moved these "quasi globals" to the struct AttackLoopVars, so that they are remembered from one DelayCommand to the next
int iCleaveAttacks = 0;
int iCircleKick = 0;
*/
// motu99: Still using these quasi-globals to communicate between functions *within one* single attack
int bFirstAttack;
int bUseMonkAttackMod;

int bIsVorpalWeaponEquiped = FALSE;
int iVorpalSaveDC = 0;

// #include "prc_x2_itemprop"
//#include "prc_inc_racial" // includes prc_feat_const, prc_class_const
// #include "prc_inc_function"
// #include "prc_inc_sneak"
#include "prc_inc_unarmed" // includes prc_spell_const, inc_utility
// #include "prc_inc_util"
//#include "inc_utility"
// #include "inc_abil_damage"
// #include "inc_epicspelldef"
#include "prc_inc_onhit"
#include "prc_misc_const"
#include "prc_inc_fork"

//:://///////////////////////////////////////////////////////////////////////////
//::  Utility functions (BAB, # Attacks) - mostly used inline, but good to have them here to copy
//:://///////////////////////////////////////////////////////////////////////////

//returns a struct describing the applicable damage reductions with the given weapon and target
struct DamReduction OvercomeDR(object oTarget)
{
    struct DamReduction nBestDamageReduction;
    int nBestDamageResistance = 0;
    int nApplicableReduction;
    struct DamReduction nCurrentReduction;
    nCurrentReduction.nRedLevel = DAMAGE_POWER_NORMAL;
    nCurrentReduction.nRedAmount = 0;
    nBestDamageReduction = nCurrentReduction;

    //loop through spell/power effects first
    effect eLoop=GetFirstEffect(oTarget);

    while (GetIsEffectValid(eLoop))
    {
        int nSpellID = GetEffectSpellId(eLoop);

        //Stoneskin
        if( nSpellID == 172
           || nSpellID == 342
           || nSpellID == SPELL_URDINNIR_STONESKIN)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_FIVE;
             nCurrentReduction.nRedAmount = 10;
        }
        //GreaterStoneskin
        if( nSpellID == 74)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_FIVE;
             nCurrentReduction.nRedAmount = 20;
        }
        //Premonition
        if( nSpellID == 134)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_FIVE;
             nCurrentReduction.nRedAmount = 30;
        }
        //Ghostly Visage
        if( nSpellID == 351
           || nSpellID == 605
           || nSpellID == 120)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_ONE;
             nCurrentReduction.nRedAmount = 5;
        }
        //Ethereal Visage
        if( nSpellID == 121)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_THREE;
             nCurrentReduction.nRedAmount = 20;
        }
        //Shadow Shield and Shadow Evade(best case)
        if( nSpellID == 160
           || nSpellID == 477
           || nSpellID == SPELL_SHADOWSHIELD)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_THREE;
             nCurrentReduction.nRedAmount = 10;
        }
        //Iron Body
        if( nSpellID == POWER_IRONBODY)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_FIVE;
             nCurrentReduction.nRedAmount = 15;
        }
        //Shadow Body
        if( nSpellID == POWER_SHADOWBODY)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_ONE;
             nCurrentReduction.nRedAmount = 10;
        }

        //if it applies and prevents more damage, replace
        if(nCurrentReduction.nRedLevel > nApplicableReduction
           && nCurrentReduction.nRedAmount > nBestDamageReduction.nRedAmount)
               nBestDamageReduction = nCurrentReduction;


        eLoop=GetNextEffect(oTarget);
    }

    //now loop through items
    int nSlot;
    object oItem;
    int nSubType;

    for (nSlot=0; nSlot<NUM_INVENTORY_SLOTS; nSlot++)
    {
        //if (DEBUG) DoDebug("Checking Inventory Slot: "+IntToString(nSlot));
        oItem=GetItemInSlot(nSlot, oTarget);

        //check props if valid
        if(GetIsObjectValid(oItem))
        {
            //if (DEBUG) DoDebug("Valid Item in Slot: "+IntToString(nSlot));
            itemproperty ipLoop=GetFirstItemProperty(oItem);

            //Loop for as long as the ipLoop variable is valid
            while (GetIsItemPropertyValid(ipLoop))
            {
                //if (DEBUG) DoDebug("Item Property in Slot "+IntToString(nSlot)+": "+ItemPropertyToString(ipLoop));
                if(GetItemPropertyType(ipLoop) == ITEM_PROPERTY_DAMAGE_REDUCTION/* && GetItemPropertySubType(ipLoop) > nApplicableReduction*/)
                {
                    //if (DEBUG) DoDebug("Item Property is Damage Reduction");
                    int nReduce = GetItemPropertyCostTableValue(ipLoop) * 5;
                    if (nReduce > nBestDamageReduction.nRedAmount)
                        nBestDamageReduction.nRedAmount = nReduce;
                }

                //Next itemproperty on the list...
                ipLoop=GetNextItemProperty(oItem);
            }
        }//end validity check
    }//end for
    //if(DEBUG) DoDebug("Best Reduction: " + IntToString(nBestDamageReduction.nRedAmount));

    return nBestDamageReduction;
}

// calculates the BAB that a pure fighter with the Hit Dice (characer level)  would have
int GetFighterBAB(int iHD)
{
    return ((iHD > 20) ? (20 + (iHD -19)/2) : iHD);
}

// assumes that we are above level 20!
// otherwise function call makes no sense, because we don't yet have a level 20 BAB
// and the BAB is used "as is" in order to calculate the number of main hand attacks
int GetLevel20BAB(int iBAB, int iHD)
{
    // subtract half of the character levels beyond 20
    return (iBAB - (iHD-19)/2);
}

// calculates the # attacks, for normal weapons (non-monk)
int GetAttacks(int iBAB, int iHD)
{
    return ((iHD > 20) ? ((iBAB -(iHD-17)/2)/5 +1) : ((iBAB-1)/ 5+1));
}

// calculates the number of attacks for an unarmed monk
// this is the Bioware implementation, which includes BAB from other classes and caps at 6
int GetMonkAttacks(int iBAB, int iHD)
{
    return ((iHD > 20) ? PRCMin(6,((iBAB - (iHD-17)/2)/3 +1)) : PRCMin(6,((iBAB-1) / 3 +1)));
}

int GetPnPMonkAttacks(int iMonkLevel)
{
    if(iMonkLevel < 6)         return 1;
    else if (iMonkLevel < 10)  return 2;
    else if (iMonkLevel < 14)  return 3;
    else if (iMonkLevel < 18)  return 4;
    else                       return 5;
}


//:://////////////////////////////////////////////
//::  Weapon Information Functions
//:://////////////////////////////////////////////


// @TODO: include CEP stuff in the weapon information functions
// maybe we should use the 2das instead of "hardwiring" everything
// [don't know how slow cached calls to look up 2das are]
// we could also use a switch to decide whether to use "hardwired" fast calls, or "safer" calls to 2das
// x - since cache functions were already used in some spellscripts I've edited this function to use them as well

int GetDamageTypeByWeaponType(int iWeaponType)
{
    switch(StringToInt(Get2DACache("baseitems", "WeaponType", iWeaponType)))
    {
        case 1: return DAMAGE_TYPE_PIERCING;
        case 2: return DAMAGE_TYPE_BLUDGEONING;
        case 3: return DAMAGE_TYPE_SLASHING;
        case 4: return 5; //DAMAGE_TYPE_PIERCING | DAMAGE_TYPE_SLASHING;
        case 5: return 3; //DAMAGE_TYPE_PIERCING | DAMAGE_TYPE_BLUDGEONING;
    }
    return DAMAGE_TYPE_BLUDGEONING; // Every place expects a default, and most errors appear to be on unarmed.
}

int GetWeaponDamageType(object oWeap)
{
    return GetDamageTypeByWeaponType(GetBaseItemType(oWeap));
}

int DamageTypeToIPConst(int nDamageType)
{
    switch(nDamageType)
    {
        case DAMAGE_TYPE_ACID:        return IP_CONST_DAMAGETYPE_ACID;
        case DAMAGE_TYPE_BLUDGEONING: return IP_CONST_DAMAGETYPE_BLUDGEONING;
        case DAMAGE_TYPE_COLD:        return IP_CONST_DAMAGETYPE_COLD;
        case DAMAGE_TYPE_DIVINE:      return IP_CONST_DAMAGETYPE_DIVINE;
        case DAMAGE_TYPE_ELECTRICAL:  return IP_CONST_DAMAGETYPE_ELECTRICAL;
        case DAMAGE_TYPE_FIRE:        return IP_CONST_DAMAGETYPE_FIRE;
        case DAMAGE_TYPE_MAGICAL:     return IP_CONST_DAMAGETYPE_MAGICAL;
        case DAMAGE_TYPE_NEGATIVE:    return IP_CONST_DAMAGETYPE_NEGATIVE;
        case DAMAGE_TYPE_PIERCING:    return IP_CONST_DAMAGETYPE_PIERCING;
        case DAMAGE_TYPE_POSITIVE:    return IP_CONST_DAMAGETYPE_POSITIVE;
        case DAMAGE_TYPE_SLASHING:    return IP_CONST_DAMAGETYPE_SLASHING;   
        case DAMAGE_TYPE_SONIC:       return IP_CONST_DAMAGETYPE_SONIC;
    }
    return IP_CONST_DAMAGETYPE_PHYSICAL;	
}

int GetIsRangedWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
        case BASE_ITEM_LONGBOW:         return TRUE;
        case BASE_ITEM_SHORTBOW:        return TRUE;
        case BASE_ITEM_LIGHTCROSSBOW:   return TRUE;
        case BASE_ITEM_HEAVYCROSSBOW:   return TRUE;
        case BASE_ITEM_SLING:           return TRUE;

        case BASE_ITEM_THROWINGAXE:     return TRUE;
        case BASE_ITEM_DART:            return TRUE;
        case BASE_ITEM_SHURIKEN:        return TRUE;

        case BASE_ITEM_ARROW:           return TRUE;
        case BASE_ITEM_BOLT:            return TRUE;
        case BASE_ITEM_BULLET:          return TRUE;
    }
    return FALSE;
}

int GetIsThrowingWeaponType(int iWeaponType)
{
    return  iWeaponType == BASE_ITEM_THROWINGAXE
            || iWeaponType == BASE_ITEM_DART
            || iWeaponType == BASE_ITEM_SHURIKEN;
}

int GetIsTwoHandedMeleeWeaponType(int iWeaponType)
{
    switch(iWeaponType)
    {
		case BASE_ITEM_GREATAXE:			return TRUE;
		case BASE_ITEM_GREATSWORD:			return TRUE;
		case BASE_ITEM_HALBERD:				return TRUE;
		case BASE_ITEM_SHORTSPEAR:			return TRUE;
		case BASE_ITEM_HEAVYFLAIL:			return TRUE;
		case BASE_ITEM_SCYTHE:				return TRUE;
		case BASE_ITEM_QUARTERSTAFF:		return TRUE;		
		//case BASE_ITEM_MAGICSTAFF:	 		return TRUE;		
		case BASE_ITEM_ELVEN_COURTBLADE:	return TRUE;
		case BASE_ITEM_MAUL:				return TRUE;
		case BASE_ITEM_FALCHION:			return TRUE;	
    }
    return FALSE;
}

int GetIsTwoHandedMeleeWeapon(object oWeap)
{
   return GetIsTwoHandedMeleeWeaponType(GetBaseItemType(oWeap));
}
	
int GetIsCreatureWeaponType(int iWeaponType)
{
// any of the three creature weapon types that produce bludgeoning, piercing or slashing damage
    return  (   iWeaponType == BASE_ITEM_CBLUDGWEAPON
                || iWeaponType == BASE_ITEM_CPIERCWEAPON
                || iWeaponType == BASE_ITEM_CSLASHWEAPON
                || iWeaponType == BASE_ITEM_CSLSHPRCWEAP
            );
}

int GetIsCreatureWeapon(object oWeap)
{
   return GetIsCreatureWeaponType(GetBaseItemType(oWeap));
}

int GetIsNaturalWeaponType(int iWeaponType)
{
// a natural weapon is either a creature weapon, or an unarmed weapon (BASE_ITEM_INVALID) or a glove (for unarmed monks)

    return  (   iWeaponType == BASE_ITEM_INVALID
                || iWeaponType == BASE_ITEM_GLOVES
                || GetIsCreatureWeaponType(iWeaponType)
            );
}

int GetIsNaturalWeapon(object oWeap)
{
    return GetIsNaturalWeaponType(GetBaseItemType(oWeap));
}

int GetIsSimpleWeaponType(int iWeaponType)
{
    switch (iWeaponType)
    {
        case BASE_ITEM_MORNINGSTAR:     return 1;
        case BASE_ITEM_QUARTERSTAFF:    return 1;
		case BASE_ITEM_MAGICSTAFF:		return 1;		
        case BASE_ITEM_SHORTSPEAR:      return 1;
        case BASE_ITEM_HEAVYCROSSBOW:   return 1;
        case BASE_ITEM_INVALID:         return 1;
        case BASE_ITEM_CBLUDGWEAPON:    return 1;
        case BASE_ITEM_CPIERCWEAPON:    return 1;
        case BASE_ITEM_CSLASHWEAPON:    return 1;
        case BASE_ITEM_CSLSHPRCWEAP:    return 1;
        case BASE_ITEM_GLOVES:          return 1;
        case BASE_ITEM_BRACER:          return 1;
        case BASE_ITEM_CRAFTED_SCEPTER:    return 1;
		
        case BASE_ITEM_DAGGER:          return 2;
        case BASE_ITEM_LIGHTMACE:       return 2;
        case BASE_ITEM_SICKLE:          return 2;
        case BASE_ITEM_SLING:           return 2;
        case BASE_ITEM_DART:            return 2;
        case BASE_ITEM_LIGHTCROSSBOW:   return 2;
    }

    return 0;
}

int GetIsSimpleWeapon(object oWeap)
{
      return GetIsSimpleWeaponType(GetBaseItemType(oWeap));
}

int GetIsMonkWeaponTypeOrUnarmed(int iWeaponType)
// returns TRUE if nothing or a kama in the right hand
{
    return  (   iWeaponType == BASE_ITEM_INVALID
                || iWeaponType == BASE_ITEM_KAMA
				|| iWeaponType == BASE_ITEM_SAI
				|| iWeaponType == BASE_ITEM_TORCH
				|| iWeaponType == BASE_ITEM_SHURIKEN
				|| iWeaponType == BASE_ITEM_NUNCHAKU
            );
}

int GetIsMonkWeaponOrUnarmed(object oWeap)
// returns TRUE if nothing or a kama in the right hand
{
    return GetIsMonkWeaponTypeOrUnarmed(GetBaseItemType(oWeap));
}

// this function will return true on *any item* that is not invalid, shield or torch
int GetIsOffhandWeaponType(int iWeaponType)
// implicitly assumes, that iWeaponType is the base item type of the object held in the left hand.
// This can only be a weapon, a shield, or a torch (or nothing)
// returns TRUE; unless there is nothing in the left hand or a shield or a torch
// also works if we pass a double-sided weapon to this function
// note that we do not check for ranged weapons or two-handers or whether the base item is a weapon at all.
{
    return  (   iWeaponType != BASE_ITEM_INVALID
                && iWeaponType != BASE_ITEM_LARGESHIELD
                && iWeaponType != BASE_ITEM_SMALLSHIELD
                && iWeaponType != BASE_ITEM_TOWERSHIELD
                && iWeaponType != BASE_ITEM_TORCH
            );
}

// returns TRUE; unless the oWeapL is an invalid object, a shield or a torch
int GetIsOffhandWeapon(object oWeapL)
// implicitly assumes, that oWeapL is the object held in the left hand. This can only be a weapon, a shield, or a torch
{
    return GetIsOffhandWeaponType(GetBaseItemType(oWeapL));
}

// returns TRUE for a double sided weapon type
int GetIsDoubleSidedWeaponType(int iWeaponType)
{
    return  (   iWeaponType == BASE_ITEM_DIREMACE
                || iWeaponType == BASE_ITEM_DOUBLEAXE
                || iWeaponType == BASE_ITEM_TWOBLADEDSWORD
				|| iWeaponType == BASE_ITEM_DOUBLE_SCIMITAR
            );
}

// returns TRUE for a double sided weapon
int GetIsDoubleSidedWeapon(object oWeap)
{
    return GetIsDoubleSidedWeaponType(GetBaseItemType(oWeap));
}

// similar to GetFeatByWeaponType(), but should be much faster, because it only loops once over the weapon types and returns all feats relevant for the weapon in a struct
struct WeaponFeat GetAllFeatsOfWeaponType(int iWeaponType)
{
    struct WeaponFeat sFeat = InitWeaponFeat(-1);

    switch(iWeaponType)
    {
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_INVALID: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_UNARMED_STRIKE;
            sFeat.Specialization =  FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_UNARMED;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_UNARMED;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_UNARMED;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_UNARMED;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = -1;
            sFeat.VileMartialStrike = -1;
            break;
        }
        case BASE_ITEM_BASTARDSWORD: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_BASTARD_SWORD;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_BASTARD_SWORD;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_BASTARDSWORD;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_BASTARDSWORD;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_BASTARD_SWORD;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_BASTARDSWORD;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_BASTARDSWORD;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_BASTARDSWORD;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_BASTARDSWORD;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_BASTARDSWORD;
            break;
        }
        case BASE_ITEM_BATTLEAXE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_BATTLE_AXE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_BATTLE_AXE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_BATTLEAXE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_BATTLEAXE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_BATTLE_AXE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_BATTLEAXE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_BATTLEAXE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_BATTLEAXE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_BATTLEAXE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_BATTLEAXE;
            break;
        }
        case BASE_ITEM_CLUB: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_CLUB;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_CLUB;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_CLUB;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_CLUB;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_CLUB;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_CLUB;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_CLUB;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_CLUB;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_CLUB;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_CLUB;
            break;
        }
        case BASE_ITEM_CRAFTED_SCEPTER: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_CLUB;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_CLUB;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_CLUB;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_CLUB;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_CLUB;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_CLUB;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_CLUB;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_CLUB;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_CLUB;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_CLUB;
            break;
        }		
        case BASE_ITEM_DAGGER: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_DAGGER;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_DAGGER;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_DAGGER;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_DAGGER;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_DAGGER;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_DAGGER;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_DAGGER;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_DAGGER;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_DAGGER;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_DAGGER;
            break;
        }
        case BASE_ITEM_DART: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_DART;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_DART;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_DART;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_DART;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_DART;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_DART;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_DART;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_DART;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_DART;
            break;
        }
        case BASE_ITEM_DIREMACE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_DIRE_MACE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_DIRE_MACE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_DIREMACE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_DIREMACE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_DIRE_MACE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_DIREMACE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_DIREMACE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_DIREMACE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_DIREMACE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_DIREMACE;
            break;
        }
        case BASE_ITEM_DOUBLEAXE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_DOUBLE_AXE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_DOUBLE_AXE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_DOUBLEAXE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_DOUBLEAXE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_DOUBLE_AXE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_DOUBLEAXE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_DOUBLEAXE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_DOUBLEAXE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_DOUBLEAXE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_DOUBLEAXE;
            break;
        }
        case BASE_ITEM_DWARVENWARAXE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_DWAXE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_DWAXE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_DWAXE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_DWAXE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_DWAXE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_DWAXE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_DWAXE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_DWAXE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_DWAXE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_DWAXE;
            break;
        }
        case BASE_ITEM_GREATAXE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_GREAT_AXE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_GREAT_AXE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_GREATAXE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_GREATAXE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_GREAT_AXE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_GREATAXE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_GREATAXE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_GREATAXE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_GREATAXE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_GREATAXE;
            break;
        }
        case BASE_ITEM_GREATSWORD: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_GREAT_SWORD;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_GREAT_SWORD;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_GREATSWORD;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_GREATSWORD;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_GREAT_SWORD;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_GREATSWORD;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_GREATSWORD;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_GREATSWORD;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_GREATSWORD;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_GREATSWORD;
            break;
        }
        case BASE_ITEM_HALBERD: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_HALBERD;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_HALBERD;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_HALBERD;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_HALBERD;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_HALBERD;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_HALBERD;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_HALBERD;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_HALBERD;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_HALBERD;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_HALBERD;
            break;
        }
        case BASE_ITEM_HANDAXE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_HAND_AXE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_HAND_AXE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_HANDAXE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_HANDAXE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_HAND_AXE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_HANDAXE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_HANDAXE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_HANDAXE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_HANDAXE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_HANDAXE;
            break;
        }
        case BASE_ITEM_HEAVYCROSSBOW: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_HEAVY_CROSSBOW;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_HEAVYCROSSBOW;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVYCROSSBOW;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_HEAVY_CROSSBOW;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVYCROSSBOW;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_HEAVYCROSSBOW;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_HEAVYCROSSBOW;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_HEAVYCROSSBOW;
            break;
        }
        case BASE_ITEM_HEAVYFLAIL: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_HEAVY_FLAIL;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_HEAVY_FLAIL;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_HEAVYFLAIL;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVYFLAIL;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_HEAVY_FLAIL;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVYFLAIL;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_HEAVYFLAIL;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_HEAVYFLAIL;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_HEAVYFLAIL;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_HEAVYFLAIL;
            break;
        }
        case BASE_ITEM_KAMA: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_KAMA;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_KAMA;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_KAMA;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_KAMA;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_KAMA;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_KAMA;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_KAMA;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_KAMA;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_KAMA;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_KAMA;
            break;
        }
        case BASE_ITEM_KATANA: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_KATANA;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_KATANA;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_KATANA;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_KATANA;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_KATANA;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_KATANA;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_KATANA;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_KATANA;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_KATANA;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_KATANA;
            break;
        }
        case BASE_ITEM_KUKRI: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_KUKRI;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_KUKRI;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_KUKRI;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_KUKRI;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_KUKRI;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_KUKRI;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_KUKRI;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_KUKRI;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_KUKRI;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_KUKRI;
            break;
        }
        case BASE_ITEM_LIGHTCROSSBOW: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_LIGHT_CROSSBOW;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_LIGHTCROSSBOW;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTCROSSBOW;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_LIGHT_CROSSBOW;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTCROSSBOW;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTCROSSBOW;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_LIGHTCROSSBOW;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_LIGHTCROSSBOW;
            break;
        }
        case BASE_ITEM_LIGHTFLAIL: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LIGHT_FLAIL;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_LIGHT_FLAIL;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_LIGHTFLAIL;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTFLAIL;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_LIGHT_FLAIL;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTFLAIL;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTFLAIL;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_LIGHTFLAIL;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_LIGHTFLAIL;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_LIGHTFLAIL;
            break;
        }
        case BASE_ITEM_LIGHTHAMMER: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LIGHT_HAMMER;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_LIGHT_HAMMER;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_LIGHTHAMMER;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTHAMMER;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_LIGHT_HAMMER;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTHAMMER;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTHAMMER;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_LIGHTHAMMER;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_LIGHTHAMMER;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_LIGHTHAMMER;
            break;
        }
        case BASE_ITEM_LIGHTMACE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LIGHT_MACE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_LIGHT_MACE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_LIGHTMACE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTMACE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_LIGHT_MACE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTMACE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTMACE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_LIGHTMACE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_LIGHTMACE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_LIGHTMACE;
            break;
        }
        case BASE_ITEM_LONGBOW: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LONGBOW;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_LONGBOW;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_LONGBOW;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_LONGBOW;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_LONGBOW;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_LONGBOW;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_LONGBOW;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_LONGBOW;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_LONGBOW;
            break;
        }
        case BASE_ITEM_LONGSWORD: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LONG_SWORD;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_LONG_SWORD;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_LONGSWORD;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_LONGSWORD;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_LONG_SWORD;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_LONGSWORD;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_LONGSWORD;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_LONGSWORD;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_LONGSWORD;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_LONGSWORD;
            break;
        }
        case BASE_ITEM_MORNINGSTAR: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_MORNING_STAR;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_MORNING_STAR;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_MORNINGSTAR;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_MORNINGSTAR;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_MORNING_STAR;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_MORNINGSTAR;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_MORNINGSTAR;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_MORNINGSTAR;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_MORNINGSTAR;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_MORNINGSTAR;
            break;
        }
        case BASE_ITEM_QUARTERSTAFF: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_STAFF;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_STAFF;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_QUARTERSTAFF;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_QUARTERSTAFF;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_STAFF;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_QUARTERSTAFF;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_QUARTERSTAFF;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_QUARTERSTAFF;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_QUARTERSTAFF;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_QUARTERSTAFF;
            break;
        }
        case BASE_ITEM_MAGICSTAFF: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_STAFF;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_STAFF;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_QUARTERSTAFF;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_QUARTERSTAFF;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_STAFF;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_QUARTERSTAFF;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_QUARTERSTAFF;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_QUARTERSTAFF;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_QUARTERSTAFF;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_QUARTERSTAFF;
            break;
        }		
        case BASE_ITEM_RAPIER: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_RAPIER;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_RAPIER;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_RAPIER;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_RAPIER;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_RAPIER;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_RAPIER;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_RAPIER;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_RAPIER;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_RAPIER;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_RAPIER;
            break;
        }
        case BASE_ITEM_SCIMITAR: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_SCIMITAR;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_SCIMITAR;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_SCIMITAR;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_SCIMITAR;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_SCIMITAR;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_SCIMITAR;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_SCIMITAR;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_SCIMITAR;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_SCIMITAR;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_SCIMITAR;
            break;
        }
        case BASE_ITEM_SCYTHE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_SCYTHE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_SCYTHE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_SCYTHE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_SCYTHE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_SCYTHE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_SCYTHE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_SCYTHE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_SCYTHE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_SCYTHE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_SCYTHE;
            break;
        }
        case BASE_ITEM_SHORTBOW: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_SHORTBOW;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_SHORTBOW;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_SHORTBOW;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTBOW;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_SHORTBOW;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTBOW;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_SHORTBOW;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_SHORTBOW;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_SHORTBOW;
            break;
        }
        case BASE_ITEM_SHORTSPEAR: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_SPEAR;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_SPEAR;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_SHORTSPEAR;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTSPEAR;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_SPEAR;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTSPEAR;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_SHORTSPEAR;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_SHORTSPEAR;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_SHORTSPEAR;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_SHORTSPEAR;
            break;
        }
        case BASE_ITEM_SHORTSWORD: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_SHORT_SWORD;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_SHORT_SWORD;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_SHORTSWORD;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTSWORD;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_SHORT_SWORD;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTSWORD;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_SHORTSWORD;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_SHORTSWORD;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_SHORTSWORD;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_SHORTSWORD;
            break;
        }
        case BASE_ITEM_SHURIKEN: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_SHURIKEN;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_SHURIKEN;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_SHURIKEN;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_SHURIKEN;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_SHURIKEN;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_SHURIKEN;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_SHURIKEN;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_SHURIKEN;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_SHURIKEN;
            break;
        }
        case BASE_ITEM_SICKLE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_SICKLE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_SICKLE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_SICKLE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_SICKLE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_SICKLE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_SICKLE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_SICKLE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_SICKLE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_SICKLE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_SICKLE;
            break;
        }
        case BASE_ITEM_SLING: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_SLING;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_SLING;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_SLING;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_SLING;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_SLING;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_SLING;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_SLING;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_SLING;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_SLING;
            break;
        }
        case BASE_ITEM_THROWINGAXE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_THROWING_AXE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_THROWING_AXE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_THROWINGAXE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_THROWINGAXE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_THROWING_AXE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_THROWINGAXE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_THROWINGAXE;
            sFeat.WeaponOfChoice = -1;
            sFeat.SanctifyMartialStrike = -1;
            sFeat.VileMartialStrike = -1;
            break;
        }
        case BASE_ITEM_TRIDENT: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_TRIDENT;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_TRIDENT;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_TRIDENT;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_TRIDENT;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_TRIDENT;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_TRIDENT;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_TRIDENT;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_TRIDENT;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_TRIDENT;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_TRIDENT;
            break;
        }
        case BASE_ITEM_TWOBLADEDSWORD: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_TWO_BLADED_SWORD;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_TWOBLADEDSWORD;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_TWOBLADEDSWORD;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_TWO_BLADED_SWORD;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_TWOBLADEDSWORD;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_TWOBLADEDSWORD;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_TWOBLADEDSWORD;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_TWOBLADED;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_TWOBLADED;
            break;
        }
        case BASE_ITEM_WARHAMMER: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_WAR_HAMMER;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_WAR_HAMMER;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_WARHAMMER;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_WARHAMMER;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_WAR_HAMMER;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_WARHAMMER;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_WARHAMMER;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_WARHAMMER;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_WARHAMMER;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_WARHAMMER;
            break;
        }
        case BASE_ITEM_WHIP: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_WHIP;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_WHIP;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_WHIP;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_WHIP;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_WHIP;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_WHIP;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_WHIP;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_WHIP;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_WHIP;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_WHIP;
            break;
        }
        case BASE_ITEM_DOUBLE_SCIMITAR: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_DOUBLE_SCIMITAR;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_DBL_SCIMITAR;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_DBL_SCIMITAR;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_DBL_SCIMITAR;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_DBL_SCIMITAR;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_DBL_SCIMITAR;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_DBL_SCIMITAR;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_DBL_SCIMITAR;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_DBL_SCIMITAR;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_DBL_SCIMITAR;
            break;
        }
        case BASE_ITEM_EAGLE_CLAW: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_EAGLE_CLAW;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_EAGLE_CLAW;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_EAGLE_CLAW;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_EAGLE_CLAW;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_EAGLE_CLAW;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_EAGLE_CLAW;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_EAGLE_CLAW;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_EAGLE_CLAW;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_EAGLE_CLAW;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_EAGLE_CLAW;
            break;
        }		
        case BASE_ITEM_ELVEN_COURTBLADE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_ELVEN_COURTBLADE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_ELVEN_COURTBLADE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_ELVEN_COURTBLADE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_COURTBLADE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_COURTBLADE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_ELVEN_COURTBLADE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_ELVEN_COURTBLADE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_ELVEN_COURTBLADE;
            break;
        }	
        case BASE_ITEM_ELVEN_THINBLADE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_ELVEN_THINBLADE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_ELVEN_THINBLADE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_ELVEN_THINBLADE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_THINBLADE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_ELVEN_THINBLADE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_THINBLADE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_THINBLADE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_ELVEN_THINBLADE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_ELVEN_THINBLADE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_ELVEN_THINBLADE;
            break;
        }	
        case BASE_ITEM_ELVEN_LIGHTBLADE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_ELVEN_LIGHTBLADE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_ELVEN_LIGHTBLADE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_ELVEN_LIGHTBLADE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_LIGHTBLADE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_LIGHTBLADE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_ELVEN_LIGHTBLADE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_ELVEN_LIGHTBLADE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_ELVEN_LIGHTBLADE;
            break;
        }			
        case BASE_ITEM_FALCHION: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_FALCHION;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_FALCHION;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_FALCHION;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_FALCHION;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_FALCHION;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_FALCHION;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_FALCHION;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_FALCHION;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_FALCHION;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_FALCHION;
            break;
        }
        case BASE_ITEM_GOAD: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_GOAD;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_GOAD;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_GOAD;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_GOAD;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_GOAD;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_GOAD;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_GOAD;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_GOAD;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_GOAD;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_GOAD;
            break;
        }
        case BASE_ITEM_HEAVY_MACE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_HEAVY_MACE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_HEAVY_MACE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_HEAVY_MACE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVY_MACE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_HEAVY_MACE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVY_MACE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_HEAVY_MACE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_HEAVY_MACE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_HEAVY_MACE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_HEAVY_MACE;
            break;
        }
        case BASE_ITEM_HEAVY_PICK: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_HEAVY_PICK;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_HEAVY_PICK;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_HEAVY_PICK;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVY_PICK;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_HEAVY_PICK;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVY_PICK;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_HEAVY_PICK;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_HEAVY_PICK;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_HEAVY_PICK;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_HEAVY_PICK;
            break;
        }		
        case BASE_ITEM_KATAR: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LIGHT_LANCE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_KATAR;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_KATAR;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_KATAR;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_KATAR;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_KATAR;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_KATAR;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_KATAR;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_KATAR;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_KATAR;
            break;
        }
        case BASE_ITEM_LIGHT_LANCE: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LIGHT_LANCE;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_LIGHT_LANCE;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_LIGHT_LANCE;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHT_LANCE;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_LIGHT_LANCE;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHT_LANCE;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_LIGHT_LANCE;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_LIGHT_LANCE;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_LIGHT_LANCE;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_LIGHT_LANCE;
            break;
        }
        case BASE_ITEM_LIGHT_PICK: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_LIGHT_PICK;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_LIGHT_PICK;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_LIGHT_PICK;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHT_PICK;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_LIGHT_PICK;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHT_PICK;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_LIGHT_PICK;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_LIGHT_PICK;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_LIGHT_PICK;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_LIGHT_PICK;
            break;
        }
        case BASE_ITEM_MAUL: {
            sFeat.Focus = FEAT_WEAPON_FOCUS_MAUL;
            sFeat.Specialization = FEAT_WEAPON_SPECIALIZATION_MAUL;
            sFeat.EpicFocus = FEAT_EPIC_WEAPON_FOCUS_MAUL;
            sFeat.EpicSpecialization = FEAT_EPIC_WEAPON_SPECIALIZATION_MAUL;
            sFeat.ImprovedCritical = FEAT_IMPROVED_CRITICAL_MAUL;
            sFeat.OverwhelmingCritical = FEAT_EPIC_OVERWHELMING_CRITICAL_MAUL;
            sFeat.DevastatingCritical = FEAT_EPIC_DEVASTATING_CRITICAL_MAUL;
            sFeat.WeaponOfChoice = FEAT_WEAPON_OF_CHOICE_MAUL;
            sFeat.SanctifyMartialStrike = FEAT_SANCTIFY_MARTIAL_MAUL;
            sFeat.VileMartialStrike = FEAT_VILE_MARTIAL_MAUL;
            break;
        }		
		// If the feat is blank when we get here, do a lookup series 
		if (!sFeat.Focus)
       	{
            sFeat.Focus = StringToInt(Get2DACache("baseitems", "WeaponFocusFeat", iWeaponType));
            sFeat.Specialization = StringToInt(Get2DACache("baseitems", "WeaponSpecializationFeat", iWeaponType));;
            sFeat.EpicFocus = StringToInt(Get2DACache("baseitems", "EpicWeaponFocusFeat", iWeaponType));;
            sFeat.EpicSpecialization = StringToInt(Get2DACache("baseitems", "EpicWeaponSpecializationFeat", iWeaponType));;
            sFeat.ImprovedCritical = StringToInt(Get2DACache("baseitems", "WeaponImprovedCriticalFeat", iWeaponType));;
            sFeat.OverwhelmingCritical = StringToInt(Get2DACache("baseitems", "EpicWeaponOverwhelmingCriticalFeat", iWeaponType));;
            sFeat.DevastatingCritical = StringToInt(Get2DACache("baseitems", "EpicWeaponDevastatingCriticalFeat", iWeaponType));;
            sFeat.WeaponOfChoice = StringToInt(Get2DACache("baseitems", "WeaponOfChoiceFeat", iWeaponType));;
            sFeat.SanctifyMartialStrike = StringToInt(Get2DACache("baseitems", "SanctifyMartialStrike", iWeaponType));;
            sFeat.VileMartialStrike = StringToInt(Get2DACache("baseitems", "VileMartialStrike", iWeaponType));;
            break;
        }        
    }
    return sFeat;
}

// returns the proper ammunition inventory slot based on iWeaponType
// if not longbow, crossbow or sling, returns right hand slot
// right hand slot is the correct slot for darts, shuriken and throwing axes
// this does not check whether the weapon type actually is a ranged type
int GetAmmunitionInventorySlotFromWeaponType(int iWeaponType)
{
    switch (iWeaponType)
    {
        case BASE_ITEM_LONGBOW:         return INVENTORY_SLOT_ARROWS;
        case BASE_ITEM_SHORTBOW:        return INVENTORY_SLOT_ARROWS;
        case BASE_ITEM_HEAVYCROSSBOW:   return INVENTORY_SLOT_BOLTS;
        case BASE_ITEM_LIGHTCROSSBOW:   return INVENTORY_SLOT_BOLTS;
        case BASE_ITEM_SLING:           return INVENTORY_SLOT_BULLETS;
//      case BASE_ITEM_DART:                return INVENTORY_SLOT_RIGHTHAND;
//      case BASE_ITEM_SHURIKEN:            return INVENTORY_SLOT_RIGHTHAND;
//      case BASE_ITEM_THROWINGAXE:     return INVENTORY_SLOT_RIGHTHAND;
    }
    return INVENTORY_SLOT_RIGHTHAND;
}

// for a ranged weapon type it will return the ammunition (if there is any)
// for throwing weapons the ammunition is the weapon itself, so it returns whatever oAttacker holds in his right hand
// Note that this does not check whether iWeaponType is weapon. For all non-ranged weapons (and any other types)
// it will return whatever object oAttacker holds in his right hand
object GetAmmunitionFromWeaponType(int iWeaponType, object oAttacker)
{
    return GetItemInSlot(GetAmmunitionInventorySlotFromWeaponType(iWeaponType), oAttacker);
}

// for a ranged weapon it will return the ammunition (if there is any)
// for throwing weapons the ammunition is the weapon itself, so it returns whatever oAttacker holds in his right hand
// Note that this does not check whether oWeapon is a weapon. For all non-ranged weapons (or any other object)
// it will return whatever object oAttacker holds in his right hand
object GetAmmunitionFromWeapon(object oWeapon, object oAttacker)
{
    return GetAmmunitionFromWeaponType(GetBaseItemType(oWeapon), oAttacker);
}

//int GetWeaponCriticalRange(object oPC, object oWeap)
// for a ranged weapon we should call this *after* we have ammo equipped, because it checks the ammo for keen
// if we (re)equip the ammo later, we don't get the right keen property
int GetWeaponCriticalRange(object oPC, object oWeap, int iTouchAttackType = FALSE)
{
	// Check for spell-based touch attacks
    if(iTouchAttackType == TOUCH_ATTACK_MELEE_SPELL)  
    {
		if (DEBUG) DoDebug("prc_inc_combat >> GetWeaponCriticalRange() | TOUCH_ATTACK_MELEE_SPELL detected.");		
        // Spell-based melee touch attacks  
        if(GetHasFeat(FEAT_IMPROVED_CRITICAL_TOUCH, oPC))  
		{
			if (DEBUG) DoDebug("prc_inc_combat >> GetWeaponCriticalRange() | Improved Critical: Touch detected.");        
			return 19; // Doubles threat range from 20 to 19-20  
		}		
        else  
            return 20;  
    }  
    else if(iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL)  
    {
		if (DEBUG) DoDebug("prc_inc_combat >> GetWeaponCriticalRange() | TOUCH_ATTACK_RANGED_SPELL detected."); 		
        // Ray attacks  
        if(GetHasFeat(FEAT_IMPROVED_CRITICAL_RAY, oPC)) 
		{			
			if (DEBUG) DoDebug("prc_inc_combat >> GetWeaponCriticalRange() | Improved Critical: Ray detected."); 
			return 19; // Doubles threat range from 20 to 19-20			
		}
        else  
            return 20;  
    } 
	//no weapon, touch attacks mainly
    if(!GetIsObjectValid(oWeap))
        return 20;

    int iWeaponType = GetBaseItemType(oWeap);

    // threat range of base weapon
    int nThreat = StringToInt(Get2DACache("baseitems", "CritThreat", iWeaponType));

    // find out all feat constant for this particular weapon type
    struct WeaponFeat sWeaponFeat = GetAllFeatsOfWeaponType(iWeaponType);

    int bImpCrit = GetHasFeat(sWeaponFeat.ImprovedCritical, oPC);
    int bKeen;

    if (GetIsRangedWeaponType(iWeaponType)) // ranged weapon, ?
    { // then replace oWeap with the ammution
        oWeap = GetAmmunitionFromWeaponType(iWeaponType, oPC);
    }

    // check weapon (or ammo) for keen property
    bKeen = GetItemHasItemProperty(oWeap, ITEM_PROPERTY_KEEN);

    // motu99: original calculation was not correct, would multiply threat range with factor of 2 for every feat
    // or do PnP rules do it differently than nwn?
    // also weapon master gets Ki Critical Feat at level 7, which increases the threat range by 2
    int nThreatMultiplier = 1;
    if(bKeen)    nThreatMultiplier++;
    if(bImpCrit) nThreatMultiplier++;

    nThreat *= nThreatMultiplier;

    // motu99: instead of checking the weapon master level, we might want to check for the KiCriticalFeat
    // because the PC could have been granted this feat by other means (unlikely, because we still need a WeaponOfChoice for the feat to work)
    int iWeaponMasterLevel = GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oPC);
    if( iWeaponMasterLevel >= WEAPON_MASTER_LEVEL_KI_CRITICAL
        && GetHasFeat(sWeaponFeat.WeaponOfChoice, oPC))
            nThreat += 2;

    return (21 - nThreat);
}

// calculates the critical multiplier of the base weapon type
int GetCriticalMultiplierOfWeaponType(int iWeaponType)
{
    // no weapon, touch attacks mainly
    if (iWeaponType == BASE_ITEM_INVALID || GetIsCreatureWeaponType(iWeaponType))
        return 2;
    else
        return StringToInt(Get2DACache("baseitems", "CritHitMult", iWeaponType));
}

// includes weapon master enhancements
int GetWeaponCritcalMultiplier(object oPC, object oWeap)
{
    int iWeaponType = GetBaseItemType(oWeap);
    int iCriticalMultiplier = GetCriticalMultiplierOfWeaponType(iWeaponType);

    // check for weapon master Increased Multiplier feat, gained at level 7
    // motu99: actually, we do not check for the feat, but rather for the weapon master level
    //(this is faster, but problematic if other classes than WM can have this feat)
    int iWeaponMasterLevel = GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oPC);
    if (iWeaponMasterLevel >= WEAPON_MASTER_LEVEL_INCREASED_MULTIPLIER
        && GetHasFeat(GetWeaponOfChoiceFeatOfWeaponType(iWeaponType), oPC))
            iCriticalMultiplier += 1;

    return iCriticalMultiplier;
}


//:://////////////////////////////////////////////
//::  Combat Information Functions
//:://////////////////////////////////////////////

int GetMeleeAttackers15ft(object oPC = OBJECT_SELF)
// motu99: this is (and was) actually 10 feet
{
    //if (DEBUG) DoDebug("Entering GetMeleeAttackers15ft");
    object oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,oPC,1,CREATURE_TYPE_IS_ALIVE,TRUE);

    if (oTarget == OBJECT_INVALID)
        return FALSE;

    float fDistance = GetDistanceBetween(oPC,oTarget);
    if (GetLocalInt(oPC, "DWBurningBrand"))
        fDistance -= RANGE_5_FEET_IN_METERS;
    if (GetLocalInt(oPC, "SDGiantsStance"))
        fDistance -= RANGE_5_FEET_IN_METERS;
    if (GetLocalInt(oPC, "IHDancingBladeForm"))
        fDistance -= RANGE_5_FEET_IN_METERS;

    //if (DEBUG) DoDebug("Exiting GetMeleeAttackers15ft");
    return fDistance <= MELEE_RANGE_METERS;
}

int GetIsInMeleeRange(object oDefender, object oAttacker, int bSizeAdjustment = TRUE)
{
    //if (DEBUG) DoDebug("Entering GetIsInMeleeRange");
    // Throw attack
    if(GetLocalInt(oAttacker, "IHLightningThrow")) return TRUE;

    float fDistance = GetDistanceBetween(oDefender, oAttacker);
    if (bSizeAdjustment)
        fDistance -= GetSizeAdjustment(oDefender, oAttacker);
    if (GetLocalInt(oAttacker, "DWBurningBrand"))
        fDistance -= RANGE_5_FEET_IN_METERS;
    if (GetLocalInt(oAttacker, "SDGiantsStance"))
        fDistance -= RANGE_5_FEET_IN_METERS;
    if (GetLocalInt(oAttacker, "IHDancingBladeForm"))
        fDistance -= RANGE_5_FEET_IN_METERS;

    //Shadowblade Far Shadow
    if(GetLocalInt(oAttacker, "PRC_SB_FARSHAD")) fDistance -= FeetToMeters(10.0);
    
    //Umbral Disciple Kiss of the Shadows
    if(GetEssentiaInvested(oAttacker, MELD_UMBRAL_KISS)) fDistance -= FeetToMeters(5.0 * GetEssentiaInvested(oAttacker, MELD_UMBRAL_KISS));    
    
    /*// Charging needs a little futzing sometimes.
    if (GetLocalInt(oAttacker, "PCIsCharging")) fDistance -= FeetToMeters(10.0);
    
    // So does Tome of Battle
    if (GetLocalInt(oAttacker, "PCIsInitiating")) fDistance -= FeetToMeters(10.0); */ 
    
    // This is an adjustment because things seem to have just a little too much error otherwise
    fDistance -= RANGE_5_FEET_IN_METERS;

    //if (DEBUG) DoDebug("Exiting GetIsInMeleeRange");
    return fDistance <= MELEE_RANGE_METERS;
}

object GetUnarmedWeapon(object oPC)
{
    // get the right creature weapon
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oPC);

    // if they have a claw weapon of some sort
    if( GetIsObjectValid(oWeapon) )
    {
        // should emulate how rare a critters special attack is
        // by making them random with 5:5:2 ratio
        // can be tweaked though
        int iRandom = d12();
        if(iRandom <= 5)
            return oWeapon;
        else if(iRandom <= 10)
        {
            object oCritterL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oPC);
            if (GetIsObjectValid(oCritterL))
                oWeapon = oCritterL;
        }
        else
        {
            object oCritterB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oPC);
            if (GetIsObjectValid(oCritterB))
                oWeapon = oCritterB;
        }
    }
    else // we don't have a (right) critter weapon
    {
        object oGlove = GetItemInSlot(INVENTORY_SLOT_ARMS, oPC);
        // motu99: this will also return bracers (don't know if we want this; if not, check here whether base item type is glove)
        if (GetIsObjectValid(oGlove))
            oWeapon = oGlove;
        else
            oWeapon = OBJECT_INVALID;
    }
    return oWeapon;
}

// returns TRUE if nothing in the right hand
int GetIsUnarmed(object oPC)
{
    return GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC) == OBJECT_INVALID;
}

// returns true if we have something in the left creature weapon slot, or if we have monk levels
// [unarmed PrC classes with a creature weapon apparently have their creature weapon in the left creature slot]
int GetIsUnarmedFighter(object oPC)
{
    return GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oPC) != OBJECT_INVALID
    || GetLevelByClass(CLASS_TYPE_MONK, oPC);
}

// motu99: includes PrC classes with an unarmed base attack bonus progression in the calculation
// any new PrCs that add to UBAB should be included in this function
int GetUBABLevel(object oPC)
{
    int iMonkLevel = 0;
    iMonkLevel += GetLevelByClass(CLASS_TYPE_MONK, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_DRUNKEN_MASTER, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_INITIATE_DRACONIC, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_RED_AVENGER, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_SHOU, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_FIST_OF_ZUOKEN, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_SACREDFIST, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_HENSHIN_MYSTIC, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oPC);
    iMonkLevel += GetLevelByClass(CLASS_TYPE_SHADOW_SUN_NINJA, oPC);
    return iMonkLevel;
}

// only returns true, if oPC has at least one monk level and if (s)he is unarmed or has a kama equipped
int GetHasMonkWeaponEquipped(object oPC)
{
    if (GetLevelByClass(CLASS_TYPE_MONK, oPC))
    {
        return GetIsMonkWeaponOrUnarmed(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC));
    }
    return FALSE;
}

// we use this in GetMainHandAttacks in order to find out, whether cross-bow special
// rules override the usual # of main hand attacks (Cross-bows without the rapid reload feat
// only get one attack per round, regardless of the # of "normal" mainhand attacks)
int GetHasCrossBowEquippedWithoutRapidReload(object oPC)
{
    object oWeapR = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (oWeapR != OBJECT_INVALID)
    {
        int iWeaponType = GetBaseItemType(oWeapR);
        if( (iWeaponType == BASE_ITEM_HEAVYCROSSBOW || iWeaponType == BASE_ITEM_LIGHTCROSSBOW)
            && !GetHasFeat(FEAT_RAPID_RELOAD, oPC) )
        {
            return TRUE;
        }
    }
    return FALSE;
}

// only does a full calculation if the local int "OverrideBaseAttackCount" is zero or does not exist,
// otherwise just returns the local int "OverrideBaseAttackCount" (unless we wield a crossbow, see below)
// note that GetMainHandAttacks() does not set the local int "OverrideBaseAttackCount", you have to do this yourself
// calculation only calculates "normal" main hand attacks; e.g. it does not include increased attacks from spells (Tensers, Divine Power)
// calculation does not include bonus attacks (from Haste, combat modes etc.)
// the number of "normal" attacks might be increased due to special attack boni to BAB from spells (such as Tenser's or Divine Power)
// in order to calculate the attack # with such boni, call the function with a non-zero value of iBABBonus (negative values are possible)
// the minimum # attacks returned is always 1; the maximum number returned is 5 (for armed and unarmed combat)
// if the PRC_BIOWARE_MONK_ATTACKS switch is on, the maximum number returned is 6 (only for monk attacks)
int GetMainHandAttacks(object oPC, int iBABBonus = 0, int bIgnoreCrossBow = FALSE)
{
    // crossbows special rules
    // if they wield a crossbow and don't have rapid reload, then only 1 attack per round
    if (!bIgnoreCrossBow && GetHasCrossBowEquippedWithoutRapidReload(oPC))
        return 1;

    int iBAB = GetLocalInt(oPC, "OverrideBaseAttackCount");
    if(iBAB)    return iBAB;

    if (DEBUG) if(iBABBonus > 20 || iBABBonus < 0) DoDebug("WARNING: GetMainHandAttacks is called with an unusual BAB-bonus = "+IntToString(iBABBonus));

    int iCharLevel = GetHitDice(oPC);
    iBAB = GetBaseAttackBonus(oPC) + iBABBonus;

    bUseMonkAttackMod = FALSE;
    int iNumAttacks = GetAttacks(iBAB, iCharLevel);
    if (iNumAttacks > 5) iNumAttacks = 5;

    if(GetHasMonkWeaponEquipped(oPC))
    {
        int iNumMonkAttacks;

        // motu99: moved up here, because we want monk progression whenever we have a kama equipped or are unarmed,
        // it is for the PC to decide, whether he will use the unarmed progression. If unarmed combat gives him less attacks
        // than armed combat, its his decision.
        bUseMonkAttackMod = TRUE;

        if(GetPRCSwitch(PRC_BIOWARE_MONK_ATTACKS))  // motu99: added switch to reenable bioware's (strange) monk UBAB progression
        {
            iNumMonkAttacks = GetMonkAttacks(iBAB, iCharLevel);
        }
        else
        {
            //note this is the correct PnP monk 3.0 progression
            //not biowares progression including other classes
            // add in unarmed PrC's so that they stack for number of unarmed attacks
            iNumMonkAttacks = GetPnPMonkAttacks(GetUBABLevel(oPC));
        }

        // only use number of attacks from unarmed (UBAB) progression, if the number
        // of attacks from UBAB is higher than number of attacks from "normal" BAB
        // motu99: Why do we try to "correct" the decision of the PC here?
        if(iNumMonkAttacks > iNumAttacks)
        {
            iNumAttacks = iNumMonkAttacks;
        }
    }
	if (GetLocalInt(oPC, "CombatMoveAttack")) iNumAttacks -= 1;
    if (iNumAttacks <= 0) iNumAttacks = 1;
    return iNumAttacks;
}

// iMainHandAttacks (second parameter) can be given to speed up the calculation of main hand attacks
// or to override any value that would otherwise be calculated by the function GetMainHandAttacks()
// the number of main hand attacks is always calculated in this function, because we need it to ensure
// that the number of offhand attacks never exceed the number of main hand attacks
// if iMainHandAttacks == 0, GetOffHandAttacks() calculates the number of main hand attacks (without taking any bonus attacks into account)
// if iMainHandAttacks != 0, GetOffHandAttacks() just assumes that this is the number if main hand attacks (without checking)
// function only returns a non-zero value, if we are using an offhand or a double sided weapon
int GetOffHandAttacks(object oPC, int iMainHandAttacks = 0)
{
    object oWeapR = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);

    // no offhand attacks if unarmed
    if (oWeapR == OBJECT_INVALID)
        return 0;

        int iWeaponTypeR = GetBaseItemType(oWeapR);
    int iWeaponTypeL;
    int bHasDoubleSidedWeapon = FALSE;

    int iOffHandAttacks = 0;

    // motu99: added double sided weapons
    if(GetIsDoubleSidedWeaponType(iWeaponTypeR))
    {
//DoDebug("GetOffHandAttacks: found double sided weapon");
        iWeaponTypeL = iWeaponTypeR;
        bHasDoubleSidedWeapon = TRUE;
    }
    else
        iWeaponTypeL = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC));

    if(bHasDoubleSidedWeapon || GetIsOffhandWeaponType(iWeaponTypeL))
    {
        // they are wielding two weapons (or double sided weapon) so at least 1 off-hand attack
        iOffHandAttacks = 1;

        if (!iMainHandAttacks)
            iMainHandAttacks = GetMainHandAttacks(oPC); // these are main hand attacks without bonus attacks

        int bHasPTWF = GetHasFeat(FEAT_PERFECT_TWO_WEAPON_FIGHTING, oPC);

        if(bHasPTWF) {iOffHandAttacks = iMainHandAttacks;}
        else if(GetHasFeat(FEAT_SUPREME_TWO_WEAPON_FIGHTING, oPC) )     iOffHandAttacks = 4;
        else if(GetHasFeat(FEAT_GREATER_TWO_WEAPON_FIGHTING, oPC) )     iOffHandAttacks = 3;
        else if(GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oPC) )    iOffHandAttacks = 2;

        // ranger who wears medium or heavy armor looses improved two weapon fighting (and any higher feats)
        int iRangerLevel = GetLevelByClass(CLASS_TYPE_RANGER, oPC);
        if (iRangerLevel)
        {
            object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
            int iArmorType = GetArmorType(oArmor);
            if(iArmorType == ARMOR_TYPE_MEDIUM || iArmorType == ARMOR_TYPE_HEAVY)
                iOffHandAttacks =1;
/*
            else if (iOffHandAttacks <=1 && iRangerLevel >= RANGER_LEVEL_ITWF) // code only needed, if ITWF feat of ranger does not show up in GetHasFeat()
                iOffHandAttacks = 2;
*/
        }

        // a tempest using double sided weapons or wearing medium or heavy armor looses GTWF and STWF feats
        int iTempestLevel = GetLevelByClass(CLASS_TYPE_TEMPEST, oPC);
        if(iTempestLevel)
        {
            object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
            int iArmorType = GetArmorType(oArmor);
            if(bHasDoubleSidedWeapon || iArmorType == ARMOR_TYPE_MEDIUM || iArmorType == ARMOR_TYPE_HEAVY)
                iOffHandAttacks = 1;
/*
            else if (!bHasPTWF) // this code is only needed, if the STWF, GTWF and ITWF feats do not show up in GetHasFeat()
            {
                if(iTempestLevel >= TEMPEST_LEVEL_STWF)
                    iOffHandAttacks = 4;
                else if (iTempestLevel >= TEMPEST_LEVEL_GTWF && iOffHandAttacks < 3)
                    iOffHandAttacks = 3;
                else if (iTempestLevel >= TEMPEST_LEVEL_ITWF && iOffHandAttacks < 2)
                    iOffHandAttacks = 2;
            }
*/
        }


// motu99: not sure if there a rule that offhand attacks must always be less or equal main hand attacks (+Bonus attacks)?
// motu99: commented out for testing (remove comments after testing!)
/*
        if (!iMainHandAttacks)
            iMainHandAttacks = GetMainHandAttacks(oPC); // these are main hand attacks without bonus attacks

        if(iOffHandAttacks > iMainHandAttacks)
        {
            iOffHandAttacks = iMainHandAttacks;
        }
*/
        // prevents dual kama monk abuse
        // motu99: added switch to reenable bioware behaviour
        if(iWeaponTypeL == BASE_ITEM_KAMA && !GetPRCSwitch(PRC_BIOWARE_MONK_ATTACKS))
            iOffHandAttacks = 0;

    }
    if (DEBUG) DoDebug("GetOffHandAttacks: iOffHandAttacks = " + IntToString(iOffHandAttacks));
    return iOffHandAttacks;
}

// this returns a number between 0 and 8 signalling a specific alignment
int GetItemPropAlignment(int iGoodEvil,int iLawChaos)
{
   int Align;

   switch(iGoodEvil)
   {
    case ALIGNMENT_GOOD:
        Align = 0;
        break;
    case ALIGNMENT_NEUTRAL:
        Align = 1;
        break;
    case ALIGNMENT_EVIL:
        Align = 2;
        break;
   }
    switch(iLawChaos)
   {
    case ALIGNMENT_LAWFUL:
        Align += 0;
        break;
    case ALIGNMENT_NEUTRAL:
        Align += 3;
        break;
    case ALIGNMENT_CHAOTIC:
        Align += 6;
        break;
   }
   return Align;
}

//:://////////////////////////////////////////////
//::  Attack Bonus Functions
//:://////////////////////////////////////////////

/** @todo
 * This needs fixing. Possible fixes:
 * 1) Wait until Primo gets the effects code done
 * 2) Add all missing stuff here (motu99: addedmost missing things)
 * 3) Make all spells that apply AB bonus or penalty update a local variable that tracks the total of such effects.
 *    Have dispellation monitors to decrement the variable by same when the spell ends
 */


// motu99: functions used for debugging
// might move these to "inc_utility" or delete
// there are better functions (using 2da lookups) in inc_utility
//
// string GetIPDamageBonusConstantName(int iDamageType)
// {
    // switch(iDamageType)
    // {
        // case IP_CONST_DAMAGEBONUS_1: return "IP_CONST_DAMAGEBONUS_1";
        // case IP_CONST_DAMAGEBONUS_2: return "IP_CONST_DAMAGEBONUS_2";
        // case IP_CONST_DAMAGEBONUS_3: return "IP_CONST_DAMAGEBONUS_3";
        // case IP_CONST_DAMAGEBONUS_4: return "IP_CONST_DAMAGEBONUS_4";
        // case IP_CONST_DAMAGEBONUS_5: return "IP_CONST_DAMAGEBONUS_5";
        // case IP_CONST_DAMAGEBONUS_6: return "IP_CONST_DAMAGEBONUS_6";
        // case IP_CONST_DAMAGEBONUS_7: return "IP_CONST_DAMAGEBONUS_7";
        // case IP_CONST_DAMAGEBONUS_8: return "IP_CONST_DAMAGEBONUS_8";
        // case IP_CONST_DAMAGEBONUS_9: return "IP_CONST_DAMAGEBONUS_9";
        // case IP_CONST_DAMAGEBONUS_10: return "IP_CONST_DAMAGEBONUS_10";
        // case IP_CONST_DAMAGEBONUS_11: return "IP_CONST_DAMAGEBONUS_11";
        // case IP_CONST_DAMAGEBONUS_12: return "IP_CONST_DAMAGEBONUS_12";
        // case IP_CONST_DAMAGEBONUS_13: return "IP_CONST_DAMAGEBONUS_13";
        // case IP_CONST_DAMAGEBONUS_14: return "IP_CONST_DAMAGEBONUS_14";
        // case IP_CONST_DAMAGEBONUS_15: return "IP_CONST_DAMAGEBONUS_15";
        // case IP_CONST_DAMAGEBONUS_16: return "IP_CONST_DAMAGEBONUS_16";
        // case IP_CONST_DAMAGEBONUS_17: return "IP_CONST_DAMAGEBONUS_17";
        // case IP_CONST_DAMAGEBONUS_18: return "IP_CONST_DAMAGEBONUS_18";
        // case IP_CONST_DAMAGEBONUS_19: return "IP_CONST_DAMAGEBONUS_19";
        // case IP_CONST_DAMAGEBONUS_20: return "IP_CONST_DAMAGEBONUS_20";
        // case IP_CONST_DAMAGEBONUS_1d4: return "IP_CONST_DAMAGEBONUS_1d4";
        // case IP_CONST_DAMAGEBONUS_1d6: return "IP_CONST_DAMAGEBONUS_1d6";
        // case IP_CONST_DAMAGEBONUS_1d8: return "IP_CONST_DAMAGEBONUS_1d8";
        // case IP_CONST_DAMAGEBONUS_1d10: return "IP_CONST_DAMAGEBONUS_1d10";
        // case IP_CONST_DAMAGEBONUS_1d12: return "IP_CONST_DAMAGEBONUS_1d12";
        // case IP_CONST_DAMAGEBONUS_2d10: return "IP_CONST_DAMAGEBONUS_2d10";
        // case IP_CONST_DAMAGEBONUS_2d12: return "IP_CONST_DAMAGEBONUS_2d12";
        // case IP_CONST_DAMAGEBONUS_2d4: return "IP_CONST_DAMAGEBONUS_2d4";
        // case IP_CONST_DAMAGEBONUS_2d6: return "IP_CONST_DAMAGEBONUS_2d6";
        // case IP_CONST_DAMAGEBONUS_2d8: return "IP_CONST_DAMAGEBONUS_2d8";
    // }
    // return "unknown";
// }

// string GetDamageBonusConstantName(int iDamageType)
// {
    // switch(iDamageType)
    // {
        // case DAMAGE_BONUS_1: return "DAMAGE_BONUS_1";
        // case DAMAGE_BONUS_2: return "DAMAGE_BONUS_2";
        // case DAMAGE_BONUS_3: return "DAMAGE_BONUS_3";
        // case DAMAGE_BONUS_4: return "DAMAGE_BONUS_4";
        // case DAMAGE_BONUS_5: return "DAMAGE_BONUS_5";
        // case DAMAGE_BONUS_6: return "DAMAGE_BONUS_6";
        // case DAMAGE_BONUS_7: return "DAMAGE_BONUS_7";
        // case DAMAGE_BONUS_8: return "DAMAGE_BONUS_8";
        // case DAMAGE_BONUS_9: return "DAMAGE_BONUS_9";
        // case DAMAGE_BONUS_10: return "DAMAGE_BONUS_10";
        // case DAMAGE_BONUS_11: return "DAMAGE_BONUS_11";
        // case DAMAGE_BONUS_12: return "DAMAGE_BONUS_12";
        // case DAMAGE_BONUS_13: return "DAMAGE_BONUS_13";
        // case DAMAGE_BONUS_14: return "DAMAGE_BONUS_14";
        // case DAMAGE_BONUS_15: return "DAMAGE_BONUS_15";
        // case DAMAGE_BONUS_16: return "DAMAGE_BONUS_16";
        // case DAMAGE_BONUS_17: return "DAMAGE_BONUS_17";
        // case DAMAGE_BONUS_18: return "DAMAGE_BONUS_18";
        // case DAMAGE_BONUS_19: return "DAMAGE_BONUS_19";
        // case DAMAGE_BONUS_20: return "DAMAGE_BONUS_20";
        // case DAMAGE_BONUS_1d10: return "DAMAGE_BONUS_1d10";
        // case DAMAGE_BONUS_1d12: return "DAMAGE_BONUS_1d12";
        // case DAMAGE_BONUS_1d4: return "DAMAGE_BONUS_1d4";
        // case DAMAGE_BONUS_1d6: return "DAMAGE_BONUS_1d6";
        // case DAMAGE_BONUS_1d8: return "DAMAGE_BONUS_1d8";
        // case DAMAGE_BONUS_2d10: return "DAMAGE_BONUS_2d10";
        // case DAMAGE_BONUS_2d12: return "DAMAGE_BONUS_2d12";
        // case DAMAGE_BONUS_2d4: return "DAMAGE_BONUS_2d4";
        // case DAMAGE_BONUS_2d6: return "DAMAGE_BONUS_2d6";
        // case DAMAGE_BONUS_2d8: return "DAMAGE_BONUS_2d8";
    // }
    // return "unknown";
// }

// string GetEffectTypeName(int iEffectType)
// {
    // switch(iEffectType)
    // {
        // case EFFECT_TYPE_ABILITY_DECREASE: return "EFFECT_TYPE_ABILITY_DECREASE";
        // case EFFECT_TYPE_ABILITY_INCREASE: return "EFFECT_TYPE_ABILITY_INCREASE";
        // case EFFECT_TYPE_AC_DECREASE: return "EFFECT_TYPE_AC_DECREASE";
        // case EFFECT_TYPE_AC_INCREASE: return "EFFECT_TYPE_AC_INCREASE";
        // case EFFECT_TYPE_ARCANE_SPELL_FAILURE: return "EFFECT_TYPE_ARCANE_SPELL_FAILURE";
        // case EFFECT_TYPE_AREA_OF_EFFECT: return "EFFECT_TYPE_AREA_OF_EFFECT";
        // case EFFECT_TYPE_ATTACK_DECREASE: return "EFFECT_TYPE_ATTACK_DECREASE";
        // case EFFECT_TYPE_ATTACK_INCREASE: return "EFFECT_TYPE_ATTACK_INCREASE";
        // case EFFECT_TYPE_BEAM: return "EFFECT_TYPE_BEAM";
        // case EFFECT_TYPE_BLINDNESS: return "EFFECT_TYPE_BLINDNESS";
        // case EFFECT_TYPE_CHARMED: return "EFFECT_TYPE_CHARMED";
        // case EFFECT_TYPE_CONCEALMENT: return "EFFECT_TYPE_CONCEALMENT";
        // case EFFECT_TYPE_CONFUSED: return "EFFECT_TYPE_CONFUSED";
        // case EFFECT_TYPE_CURSE: return "EFFECT_TYPE_CURSE";
        // case EFFECT_TYPE_CUTSCENE_PARALYZE: return "EFFECT_TYPE_CUTSCENE_PARALYZE";
        // case EFFECT_TYPE_CUTSCENEGHOST: return "EFFECT_TYPE_CUTSCENEGHOST";
        // case EFFECT_TYPE_CUTSCENEIMMOBILIZE: return "EFFECT_TYPE_CUTSCENEIMMOBILIZE";
        // case EFFECT_TYPE_DAMAGE_DECREASE: return "EFFECT_TYPE_DAMAGE_DECREASE";
        // case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE: return "EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE";
        // case EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE: return "EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE";
        // case EFFECT_TYPE_DAMAGE_INCREASE: return "EFFECT_TYPE_DAMAGE_INCREASE";
        // case EFFECT_TYPE_DAMAGE_REDUCTION: return "EFFECT_TYPE_DAMAGE_REDUCTION";
        // case EFFECT_TYPE_DAMAGE_RESISTANCE: return "EFFECT_TYPE_DAMAGE_RESISTANCE";
        // case EFFECT_TYPE_DARKNESS: return "EFFECT_TYPE_DARKNESS";
        // case EFFECT_TYPE_DAZED: return "EFFECT_TYPE_DAZED";
        // case EFFECT_TYPE_DEAF: return "EFFECT_TYPE_DEAF";
        // case EFFECT_TYPE_DISAPPEARAPPEAR: return "EFFECT_TYPE_DISAPPEARAPPEAR";
        // case EFFECT_TYPE_DISEASE: return "EFFECT_TYPE_DISEASE";
        // case EFFECT_TYPE_DISPELMAGICALL: return "EFFECT_TYPE_DISPELMAGICALL";
        // case EFFECT_TYPE_DISPELMAGICBEST: return "EFFECT_TYPE_DISPELMAGICBEST";
        // case EFFECT_TYPE_DOMINATED: return "EFFECT_TYPE_DOMINATED";
        // case EFFECT_TYPE_ELEMENTALSHIELD: return "EFFECT_TYPE_ELEMENTALSHIELD";
        // case EFFECT_TYPE_ENEMY_ATTACK_BONUS: return "EFFECT_TYPE_ENEMY_ATTACK_BONUS";
        // case EFFECT_TYPE_ENTANGLE: return "EFFECT_TYPE_ENTANGLE";
        // case EFFECT_TYPE_ETHEREAL: return "EFFECT_TYPE_ETHEREAL";
        // case EFFECT_TYPE_FRIGHTENED: return "EFFECT_TYPE_FRIGHTENED";
        // case EFFECT_TYPE_HASTE: return "EFFECT_TYPE_HASTE";
        // case EFFECT_TYPE_IMMUNITY: return "EFFECT_TYPE_IMMUNITY";
        // case EFFECT_TYPE_IMPROVEDINVISIBILITY: return "EFFECT_TYPE_IMPROVEDINVISIBILITY";
        // case EFFECT_TYPE_INVALIDEFFECT: return "EFFECT_TYPE_INVALIDEFFECT";
        // case EFFECT_TYPE_INVISIBILITY: return "EFFECT_TYPE_INVISIBILITY";
        // case EFFECT_TYPE_INVULNERABLE: return "EFFECT_TYPE_INVULNERABLE";
        // case EFFECT_TYPE_MISS_CHANCE: return "EFFECT_TYPE_MISS_CHANCE";
        // case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE: return "EFFECT_TYPE_MOVEMENT_SPEED_DECREASE";
        // case EFFECT_TYPE_MOVEMENT_SPEED_INCREASE: return "EFFECT_TYPE_MOVEMENT_SPEED_INCREASE";
        // case EFFECT_TYPE_NEGATIVELEVEL: return "EFFECT_TYPE_NEGATIVELEVEL";
        // case EFFECT_TYPE_PARALYZE: return "EFFECT_TYPE_PARALYZE";
        // case EFFECT_TYPE_PETRIFY: return "EFFECT_TYPE_PETRIFY";
        // case EFFECT_TYPE_POISON: return "EFFECT_TYPE_POISON";
        // case EFFECT_TYPE_POLYMORPH: return "EFFECT_TYPE_POLYMORPH";
        // case EFFECT_TYPE_REGENERATE: return "EFFECT_TYPE_REGENERATE";
        // case EFFECT_TYPE_RESURRECTION: return "EFFECT_TYPE_RESURRECTION";
        // case EFFECT_TYPE_SANCTUARY: return "EFFECT_TYPE_SANCTUARY";
        // case EFFECT_TYPE_SAVING_THROW_DECREASE : return "EFFECT_TYPE_SAVING_THROW_DECREASE ";
        // case EFFECT_TYPE_SAVING_THROW_INCREASE: return "EFFECT_TYPE_SAVING_THROW_INCREASE";
        // case EFFECT_TYPE_SEEINVISIBLE: return "EFFECT_TYPE_SEEINVISIBLE";
        // case EFFECT_TYPE_SILENCE: return "EFFECT_TYPE_SILENCE";
        // case EFFECT_TYPE_SKILL_DECREASE: return "EFFECT_TYPE_SKILL_DECREASE";
        // case EFFECT_TYPE_SKILL_INCREASE: return "EFFECT_TYPE_SKILL_INCREASE";
        // case EFFECT_TYPE_SLEEP: return "EFFECT_TYPE_SLEEP";
        // case EFFECT_TYPE_SLOW: return "EFFECT_TYPE_SLOW";
        // case EFFECT_TYPE_SPELL_FAILURE: return "EFFECT_TYPE_SPELL_FAILURE";
        // case EFFECT_TYPE_SPELL_IMMUNITY: return "EFFECT_TYPE_SPELL_IMMUNITY";
        // case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE: return "EFFECT_TYPE_SPELL_RESISTANCE_DECREASE";
        // case EFFECT_TYPE_SPELL_RESISTANCE_INCREASE: return "EFFECT_TYPE_SPELL_RESISTANCE_INCREASE";
        // case EFFECT_TYPE_SPELLLEVELABSORPTION: return "EFFECT_TYPE_SPELLLEVELABSORPTION";
        // case EFFECT_TYPE_STUNNED: return "EFFECT_TYPE_STUNNED";
        // case EFFECT_TYPE_SWARM: return "EFFECT_TYPE_SWARM";
        // case EFFECT_TYPE_TEMPORARY_HITPOINTS: return "EFFECT_TYPE_TEMPORARY_HITPOINTS";
        // case EFFECT_TYPE_TIMESTOP: return "EFFECT_TYPE_TIMESTOP";
        // case EFFECT_TYPE_TRUESEEING: return "EFFECT_TYPE_TRUESEEING";
        // case EFFECT_TYPE_TURN_RESISTANCE_DECREASE: return "EFFECT_TYPE_TURN_RESISTANCE_DECREASE";
        // case EFFECT_TYPE_TURN_RESISTANCE_INCREASE: return "EFFECT_TYPE_TURN_RESISTANCE_INCREASE";
        // case EFFECT_TYPE_TURNED: return "EFFECT_TYPE_TURNED";
        // case EFFECT_TYPE_ULTRAVISION: return "EFFECT_TYPE_ULTRAVISION";
        // case EFFECT_TYPE_VISUALEFFECT: return "EFFECT_TYPE_VISUALEFFECT";
    // }
    // return "unknown";
// }

// string GetItemPropertyName(int iItemType)
// {
    // switch(iItemType)
    // {
        // case ITEM_PROPERTY_ABILITY_BONUS: return "ITEM_PROPERTY_ABILITY_BONUS";
        // case ITEM_PROPERTY_AC_BONUS: return "ITEM_PROPERTY_AC_BONUS";
        // case ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP: return "ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP";
        // case ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE: return "ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE";
        // case ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP: return "ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP";
        // case ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT: return "ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT";
        // case ITEM_PROPERTY_ARCANE_SPELL_FAILURE: return "ITEM_PROPERTY_ARCANE_SPELL_FAILURE";
        // case ITEM_PROPERTY_ATTACK_BONUS: return "ITEM_PROPERTY_ATTACK_BONUS";
        // case ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP: return "ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP";
        // case ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP: return "ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP";
// //      case ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNEMENT: return "ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNEMENT";
        // case ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT: return "ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT";
        // case ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION: return "";
        // case ITEM_PROPERTY_BONUS_FEAT: return "ITEM_PROPERTY_BONUS_FEAT";
        // case ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N: return "ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N";
// //      case ITEM_PROPERTY_BOOMERANG: return "ITEM_PROPERTY_BOOMERANG";
        // case ITEM_PROPERTY_CAST_SPELL: return "ITEM_PROPERTY_CAST_SPELL";
        // case ITEM_PROPERTY_DAMAGE_BONUS: return "ITEM_PROPERTY_DAMAGE_BONUS";
        // case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP: return "ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP";
        // case ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP: return "ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP";
        // case ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT: return "ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT";
        // case ITEM_PROPERTY_DAMAGE_REDUCTION: return "ITEM_PROPERTY_DAMAGE_REDUCTION";
        // case ITEM_PROPERTY_DAMAGE_RESISTANCE: return "ITEM_PROPERTY_DAMAGE_RESISTANCE";
        // case ITEM_PROPERTY_DAMAGE_VULNERABILITY: return "ITEM_PROPERTY_DAMAGE_VULNERABILITY";
// //      case ITEM_PROPERTY_DANCING: return "ITEM_PROPERTY_DANCING";
        // case ITEM_PROPERTY_DARKVISION: return "ITEM_PROPERTY_DARKVISION";
        // case ITEM_PROPERTY_DECREASED_ABILITY_SCORE: return "ITEM_PROPERTY_DECREASED_ABILITY_SCORE";
        // case ITEM_PROPERTY_DECREASED_AC: return "ITEM_PROPERTY_DECREASED_AC";
        // case ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER: return "ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER";
        // case ITEM_PROPERTY_DECREASED_DAMAGE: return "ITEM_PROPERTY_DECREASED_DAMAGE";
        // case ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER: return "ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER";
        // case ITEM_PROPERTY_DECREASED_SAVING_THROWS: return "ITEM_PROPERTY_DECREASED_SAVING_THROWS";
        // case ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC: return "ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC";
        // case ITEM_PROPERTY_DECREASED_SKILL_MODIFIER: return "ITEM_PROPERTY_DECREASED_SKILL_MODIFIER";
// //      case ITEM_PROPERTY_DOUBLE_STACK: return "ITEM_PROPERTY_DOUBLE_STACK";
// //      case ITEM_PROPERTY_ENHANCED_CONTAINER_BONUS_SLOTS: return "ITEM_PROPERTY_ENHANCED_CONTAINER_BONUS_SLOTS";
        // case ITEM_PROPERTY_ENHANCED_CONTAINER_REDUCED_WEIGHT: return "ITEM_PROPERTY_ENHANCED_CONTAINER_REDUCED_WEIGHT";
        // case ITEM_PROPERTY_ENHANCEMENT_BONUS: return "ITEM_PROPERTY_ENHANCEMENT_BONUS";
        // case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP: return "ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP";
        // case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP: return "ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP";
        // case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT: return "ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT";
// //      case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNMENT: return "ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNMENT";
        // case ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE: return "ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE";
        // case ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE: return "ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE";
        // case ITEM_PROPERTY_FREEDOM_OF_MOVEMENT: return "ITEM_PROPERTY_FREEDOM_OF_MOVEMENT";
        // case ITEM_PROPERTY_HASTE: return "ITEM_PROPERTY_HASTE";
        // case ITEM_PROPERTY_HEALERS_KIT: return "ITEM_PROPERTY_HEALERS_KIT";
        // case ITEM_PROPERTY_HOLY_AVENGER: return "ITEM_PROPERTY_HOLY_AVENGER";
        // case ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE: return "ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE";
        // case ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS: return "ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS";
// //      case ITEM_PROPERTY_IMMUNITY_SPECIFIC_SCHOOL: return "ITEM_PROPERTY_IMMUNITY_SPECIFIC_SCHOOL";
        // case ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL: return "ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL";
        // case ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL: return "ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL";
        // case ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL: return "ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL";
        // case ITEM_PROPERTY_IMPROVED_EVASION: return "ITEM_PROPERTY_IMPROVED_EVASION";
        // case ITEM_PROPERTY_KEEN: return "ITEM_PROPERTY_KEEN";
        // case ITEM_PROPERTY_LIGHT: return "ITEM_PROPERTY_LIGHT";
        // case ITEM_PROPERTY_MASSIVE_CRITICALS: return "ITEM_PROPERTY_MASSIVE_CRITICALS";
        // case ITEM_PROPERTY_MIGHTY: return "ITEM_PROPERTY_MIGHTY";
        // case ITEM_PROPERTY_MIND_BLANK: return "ITEM_PROPERTY_MIND_BLANK";
        // case ITEM_PROPERTY_MONSTER_DAMAGE: return "ITEM_PROPERTY_MONSTER_DAMAGE";
        // case ITEM_PROPERTY_NO_DAMAGE: return "ITEM_PROPERTY_NO_DAMAGE";
        // case ITEM_PROPERTY_ON_HIT_PROPERTIES: return "ITEM_PROPERTY_ON_HIT_PROPERTIES";
        // case ITEM_PROPERTY_ON_MONSTER_HIT: return "ITEM_PROPERTY_ON_MONSTER_HIT";
        // case ITEM_PROPERTY_ONHITCASTSPELL: return "ITEM_PROPERTY_ONHITCASTSPELL";
        // case ITEM_PROPERTY_POISON: return "ITEM_PROPERTY_POISON";
        // case ITEM_PROPERTY_REGENERATION: return "ITEM_PROPERTY_REGENERATION";
        // case ITEM_PROPERTY_REGENERATION_VAMPIRIC: return "ITEM_PROPERTY_REGENERATION_VAMPIRIC";
        // case ITEM_PROPERTY_SAVING_THROW_BONUS: return "ITEM_PROPERTY_SAVING_THROW_BONUS";
        // case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC: return "ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC";
        // case ITEM_PROPERTY_SKILL_BONUS: return "ITEM_PROPERTY_SKILL_BONUS";
        // case ITEM_PROPERTY_SPECIAL_WALK: return "ITEM_PROPERTY_SPECIAL_WALK";
        // case ITEM_PROPERTY_SPELL_RESISTANCE: return "ITEM_PROPERTY_SPELL_RESISTANCE";
        // case ITEM_PROPERTY_THIEVES_TOOLS: return "ITEM_PROPERTY_THIEVES_TOOLS";
        // case ITEM_PROPERTY_TRAP: return "ITEM_PROPERTY_TRAP";
        // case ITEM_PROPERTY_TRUE_SEEING: return "ITEM_PROPERTY_TRUE_SEEING";
        // case ITEM_PROPERTY_TURN_RESISTANCE: return "ITEM_PROPERTY_TURN_RESISTANCE";
        // case ITEM_PROPERTY_UNLIMITED_AMMUNITION: return "ITEM_PROPERTY_UNLIMITED_AMMUNITION";
        // case ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP: return "ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP";
        // case ITEM_PROPERTY_USE_LIMITATION_CLASS: return "ITEM_PROPERTY_USE_LIMITATION_CLASS";
        // case ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE: return "ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE";
        // case ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT: return "ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT";
        // case ITEM_PROPERTY_USE_LIMITATION_TILESET: return "ITEM_PROPERTY_USE_LIMITATION_TILESET";
        // case ITEM_PROPERTY_VISUALEFFECT: return "ITEM_PROPERTY_VISUALEFFECT";
// //      case ITEM_PROPERTY_VORPAL: return "ITEM_PROPERTY_VORPAL";
        // case ITEM_PROPERTY_WEIGHT_INCREASE: return "ITEM_PROPERTY_WEIGHT_INCREASE";
        // case ITEM_PROPERTY_WOUNDING: return "ITEM_PROPERTY_WOUNDING";
    // }
    // return "unknown";
// }

// returns a string with basic information about an effect found on a PC
// string DebugStringEffect(effect eEffect)
// {
    // string sString = "";
//
    // int nType = GetEffectType(eEffect);
    // sString += "Effect; Type = " + IntToString(nType) + " (" + GetEffectTypeName(nType) + ")";
//
    // int nSpell = GetEffectSpellId(eEffect);
    // sString += ", SpellID: " + IntToString(nSpell);
//
    // int nSubType = GetEffectSubType(eEffect);
    // sString += ", Subtype: " + IntToString(nSubType);
//
    // int nDurationType = GetEffectDurationType(eEffect);
    // sString += ", Duration: " + IntToString(nDurationType);
//
    // object oCreator = GetEffectCreator(eEffect);
    // sString += ", Creator: " + GetName(oCreator);
//
    // return sString;
// }

// returns a string with basic information about an item property (found on an item)
// we could also use DebugIProp2Str(itemproperty ip) from "inc_utility"
// or ItemPropertyToString(itemproperty ip) from "inc_utility" (which uses 2da and tlk lookups)

// replaced calls with DebugIProp2Str() in inc_debug
// string DebugStringItemProperty(itemproperty ip)
// {
// //  return DebugIProp2Str(ip);
// //  return ItemPropertyToString(ip);
    // int iType = GetItemPropertyType(ip);
    // int iValue = GetItemPropertyCostTableValue(ip);
    // int iSubType = GetItemPropertySubType(ip);
    // int iParam1 = GetItemPropertyParam1Value(ip);
    // return "IP, Type = " + IntToString(iType) + " (" + GetItemPropertyName(iType) + "), Cost = " + IntToString(iValue) + ", Subtype = " + IntToString(iSubType) + ", Param1 = " + IntToString(iParam1);
// }

// motu99: modified this code so that it now works with PRC 3.1d
int GetMagicalAttackBonus(object oAttacker, object oTarget)
{
// motu99: added createMagicTatoo, Heroism, GreaterHeroism, MantleOfEgregiousMight, Deadeye Sense
// @TODO: research if all AB increasing spells are covered; find a way to get AB-increase directly from effect
//ebonfowl: this function now pulls attack increasing effects automatically

    int iMagicBonus = 0;
    int nType = 0;
    int iEffectSubtype = 0;
    int nSpell = 0;

    object oCaster;

    effect eEffect = GetFirstEffect(oAttacker);

    while(GetIsEffectValid(eEffect))
    {
        nType = GetEffectType(eEffect);
        iEffectSubtype = GetEffectInteger(eEffect, 1);
        nSpell = GetEffectSpellId(eEffect);
// DoDebug("GetMagicalAttackBonus: found "+ DebugStringEffect(eEffect));
        int iBonus = 0;

        int iRace = MyPRCGetRacialType(oTarget);

        int iEffectRace = GetEffectInteger(eEffect, 2);

        int iGoodEvil = GetAlignmentGoodEvil(oTarget);
        int iLawChaos = GetAlignmentLawChaos(oTarget);

        int iEffectLawChaos = GetEffectInteger(eEffect, 3);
        int iEffectGoodEvil = GetEffectInteger(eEffect, 4);

        if(nType == EFFECT_TYPE_ATTACK_INCREASE && iEffectSubtype == 0)
        {
// motu99: If the aurora engine can determine the attack increase due to all of these spells
// we should also be able to get the attack increase directly
// this would reduce the effort going through all spells (and not catching any new spells, unless we meticously update the code)

            if(iEffectRace != 28)
            {
                if(iEffectRace == iRace)
                {
                    //Define racial type-based attack increase and load into struct
                    iBonus = GetEffectInteger(eEffect, 0);
                    iMagicBonus += iBonus;
                }
            }
            else if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
            {
                if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                {
                    //Define alignment-based attack increase and load into struct
                    iBonus = GetEffectInteger(eEffect, 0);
                    iMagicBonus += iBonus;
                }
            }
            else if(iEffectLawChaos == 0 && iEffectGoodEvil == 0 && iEffectRace == 28)
            {
                //Define generic attack increase and load into struct
                iBonus = GetEffectInteger(eEffect, 0);
                iMagicBonus += iBonus;
            }
            
/*            switch(nSpell)
            {
//              case 2732: // Tempest absolute ambidex  (calculated independent from spell effect)
//                  iMagicBonus += 2;
//                  break;

                case SPELL_AID:
                    iMagicBonus += 1;
                    break;

                case SPELL_BLESS:
                    iMagicBonus += 1;
                    break;

                case SPELL_PRAYER:
                    iMagicBonus += 1;
                    break;

                case SPELL_WAR_CRY:
                    iMagicBonus += 2;
                    break;

                case SPELL_BATTLETIDE:
                    iMagicBonus += 2;
                    break;

                case SPELL_TRUE_STRIKE:
                    iMagicBonus += 20;
                    break;

                case SPELL_EPIC_DEADEYE_2:
                    iMagicBonus += 20;
                    break;

                case SPELL_DIVINE_PROTECTION:
                    iMagicBonus += 1;
                    break;

                case SPELL_CREATE_MAGIC_TATTOO: // motu99: don't know if this ever finds anything - fluffyamoeba: does now
                    iMagicBonus += 2;
                    break;

                case SPELL_HEROISM:
                    iMagicBonus += 2;
                    break;

                case SPELL_GREATER_HEROISM:
                    iMagicBonus += 4;
                    break;

                case SPELL_MANTLE_OF_EGREG_MIGHT:
                    iMagicBonus += 4;
                    break;

                case SPELL_RECITATION:
                    iMagicBonus += 2;
                    break;

                case SPELL_DIVINE_FAVOR: {
                    iMagicBonus++; // at least one point increase

// motu99: normally divine favor can only be cast on self, but what with runes?
// so we should find out the caster of the spell (same as with bard song, see below)
                    oCaster = GetEffectCreator(eEffect);
                    if(!GetIsObjectValid(oCaster)) // if we cannot find the caster, we assume the attacker was the caster
                        oCaster = oAttacker;

                    iBonus = GetLevelByTypeDivine(oCaster);
                    iBonus /= 3;
                    if(iBonus > 4) iBonus = 4; // we already have one increase, so can only be four more

                    iMagicBonus += iBonus;
                    break;
                }
                case SPELL_DIVINE_POWER:
                    iBonus = GetFighterBAB(GetHitDice(oAttacker)) - GetBaseAttackBonus(oAttacker);
                    iMagicBonus += iBonus;
                    break;

                // // Cleric War Domain Power
                // case SPELL_CLERIC_WAR_DOMAIN_POWER_2:
// // here we implicitly assume, that the war domain power SLA can only be cast on oneself
                    // iBonus = GetLevelByTypeDivine(oAttacker); // GetLevelByClass(CLASS_TYPE_CLERIC, oAttacker);  // motu99: changed to divine caster levels
                    // iBonus /= 5;
                    // iBonus++;
//
                    // iMagicBonus += iBonus;
                    // break;

                // SPELL_DIVINE_WRATH
                case SPELLABILITY_DC_DIVINE_WRATH: {// motu99: didn't check this piece of code
                    iBonus = GetLevelByClass(CLASS_TYPE_DIVINECHAMPION, oAttacker);
                    iBonus /= 5;
                    iBonus -= 1;
                    if(iBonus < 0) iBonus = 0;
                    else           iBonus *= 2;

                    iBonus += 3;
                    iMagicBonus += iBonus;
                    break;
                }
                case SPELL_TENSERS_TRANSFORMATION: {
                    // find out caster level (should be stored in local int on oAttacker)
                    iBonus = GetLocalInt(oAttacker, "CasterLvl_TensersTrans");

                    // if there is no local int, we have to find out the caster level (is not very accurate)
                    if (!iBonus)
                    {
                        // Tenser's could have been cast on us by someone else (rune or scroll), so find out caster
                        oCaster = GetEffectCreator(eEffect);
                        if(!GetIsObjectValid(oCaster)) // if we cannot find the caster, we assume the attacker was the caster
                            oCaster = oAttacker;

                        iBonus = GetLevelByTypeArcane(oCaster);
                    }

                    iBonus /= 2;
                    iMagicBonus += iBonus;
                    break;
                }
                // Bard's Song
                case SPELL_BARD_SONG: {
                    oCaster = GetEffectCreator(eEffect);
                    if(!GetIsObjectValid(oCaster)) // if we cannot find the caster, we assume the attacker was the caster
                        oCaster = oAttacker;

                    iMagicBonus++; // at least one point increase
                    if(GetIsObjectValid(oCaster))
                    {
                        if( GetLevelByClass(CLASS_TYPE_BARD, oCaster) >= BARD_LEVEL_FOR_BARD_SONG_AB_2
                            && GetSkillRank(SKILL_PERFORM, oCaster) >= BARD_PERFORM_SKILL_FOR_BARD_SONG_AB_2)
                            iMagicBonus++;
                    }
                    break;
                }
            }*/
        }

        else if(nType == EFFECT_TYPE_ATTACK_DECREASE && iEffectSubtype == 0)
        {
            if(iEffectRace != 28)
            {
                if(iEffectRace == iRace)
                {
                    //Define racial type-based attack decrease and load into struct
                    iBonus = GetEffectInteger(eEffect, 0);
                    iMagicBonus -= iBonus;
                }
            }
            else if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
            {
                if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                {
                    //Define alignment-based attack decrease and load into struct
                    iBonus = GetEffectInteger(eEffect, 0);
                    iMagicBonus -= iBonus;
                }
            }
            else if(iEffectLawChaos == 0 && iEffectGoodEvil == 0 && iEffectRace == 28)
            {
                //Define generic attack decrease and load into struct
                iBonus = GetEffectInteger(eEffect, 0);
                iMagicBonus -= iBonus;
            }
            
            /*
            switch(nSpell)
            {
                case SPELL_BANE:
                    iMagicBonus -= 1;
                    break;

                case SPELL_PRAYER:
                    iMagicBonus -= 1;
                    break;

                case SPELL_FLARE:
                    iMagicBonus -= 1;
                    break;

                case SPELL_GHOUL_TOUCH:
                    iMagicBonus -= 2;
                    break;

                case SPELL_DOOM:
                    iMagicBonus -= 2;
                    break;

                case SPELL_SCARE:
                    iMagicBonus -= 2;
                    break;

                case SPELL_RECITATION:
                    iMagicBonus -= 2;
                    break;

                case SPELL_BATTLETIDE:
                    iMagicBonus -= 2;
                    break;

                case SPELL_CURSE_OF_PETTY_FAILING:
                    iMagicBonus -= 2;
                    break;

                case SPELL_LEGIONS_CURSE_OF_PETTY_FAILING:
                    iMagicBonus -= 2;
                    break;

                case SPELL_BESTOW_CURSE:
                    iMagicBonus -= 4;
                    break;

                // SPELL_HELLINFERNO
                case SPELL_HELLINFERNO_2:
                    iMagicBonus -= 4;
                    break;

                case SPELL_BIGBYS_INTERPOSING_HAND:
                    iMagicBonus -= 10;
                    break;

                // Bard's Curse Song
                case SPELL_BARD_CURSE_SONG: {
                    oCaster = GetEffectCreator(eEffect);
                    if(!GetIsObjectValid(oCaster)) // if we cannot find the caster, we assume the attacker was the caster
                        oCaster = oAttacker;

                    iMagicBonus--;

                    if(GetIsObjectValid(oCaster))
                    {
                        if( GetLevelByClass(CLASS_TYPE_BARD, oCaster) >= BARD_LEVEL_FOR_BARD_SONG_AB_2
                            && GetSkillRank(SKILL_PERFORM, oCaster) >= BARD_PERFORM_SKILL_FOR_BARD_SONG_AB_2)
                                iMagicBonus--;
                    }
                    break;
                }
                // Power Shot
                case SPELL_PA_POWERSHOT:
                    iMagicBonus -= 5;
                    break;

                case SPELL_PA_IMP_POWERSHOT:
                    iMagicBonus -= 10;
                    break;

                case SPELL_PA_SUP_POWERSHOT:
                    iMagicBonus -= 15;
                    break;
            }*/
        }

        eEffect = GetNextEffect(oAttacker);
    }
    return iMagicBonus;
}

// this function only calculates pure attack boni on the weapon, enhancement boni are calculated elsewhere
// it takes boni or  penalties due to alignment into account
// it calculates the maximum of all boni and subtracts the maximum of all penalties
int GetWeaponAttackBonusItemProperty(object oWeap, object oDefender)
{
    int iBonus = 0;
    int iPenalty = 0;
    int iTemp;

    int iRace = MyPRCGetRacialType(oDefender);

    int iGoodEvil = GetAlignmentGoodEvil(oDefender);
    int iLawChaos = GetAlignmentLawChaos(oDefender);
    int iAlignSpecific = GetItemPropAlignment(iGoodEvil, iLawChaos);
    int iAlignGroup;

    itemproperty ip = GetFirstItemProperty(oWeap);
    while(GetIsItemPropertyValid(ip))
    {
        iTemp = 0;
        int iIpType=GetItemPropertyType(ip);
        switch(iIpType)
        {
            case ITEM_PROPERTY_ATTACK_BONUS:
                iTemp = GetItemPropertyCostTableValue(ip);
                break;

            case ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER:
                iTemp - GetItemPropertyCostTableValue(ip);
                break;

            case ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP:
                iAlignGroup = GetItemPropertySubType(ip);

                if (iAlignGroup == ALIGNMENT_NEUTRAL)
                {
                   if (iAlignGroup == iLawChaos)   iTemp = GetItemPropertyCostTableValue(ip);
                }
                else if (iAlignGroup == iGoodEvil || iAlignGroup == iLawChaos || iAlignGroup == IP_CONST_ALIGNMENTGROUP_ALL)
                {
                   iTemp = GetItemPropertyCostTableValue(ip);
                }
                break;

            case ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP:
                if(GetItemPropertySubType(ip) == iRace )
                {
                     iTemp = GetItemPropertyCostTableValue(ip);
                 }
                 break;

            case ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT:
                if(GetItemPropertySubType(ip) == iAlignSpecific )
                {
                     iTemp = GetItemPropertyCostTableValue(ip);
                }
                break;
        }

        if (iTemp > iBonus)
            iBonus = iTemp;
        else if(iTemp < iPenalty)
            iPenalty = iTemp;

        ip = GetNextItemProperty(oWeap);
    }
    iBonus -= iPenalty;
    return iBonus;
}

int GetDefenderAC(object oDefender, object oAttacker, int bIsTouchAttack = FALSE)
{
    int iAC = GetAC(oDefender);
    int iDexMod = GetAbilityModifier(ABILITY_DEXTERITY, oDefender);
    int bIsHelpless =  GetIsHelpless(oDefender);
    int bGetIsDeniedDexBonus = GetIsDeniedDexBonusToAC(oDefender, oAttacker);
    int bIsStunned = PRCGetHasEffect(EFFECT_TYPE_STUNNED, oDefender);

    // helpless enemies have an effective dexterity of 0 (for -5 ac)
    if(bIsHelpless)
    {
        iAC -= 5;
    }
    //if (DEBUG) DoDebug("GetDefenderAC: End Section #1");
    // remove the dexterity modifier to AC, based on armor limits
    if(bGetIsDeniedDexBonus || bIsHelpless )
    {
        object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oDefender);
        int iArmorType = GetItemACBase(oArmor);
        int iDexMax = 100;

        // remove any bonus AC from boots (it's Dodge AC)
        iAC -= GetItemACValue( GetItemInSlot(INVENTORY_SLOT_BOOTS, oDefender) );

        // remove bonus AC from having tumble skill.
        // this is only for ranks, not items/feats/etc
        int iTumble = GetSkill(oDefender, SKILL_TUMBLE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
        iTumble -= iDexMod;
        iTumble /= 5;
        iAC -= iTumble;

        // change the max dex mod based on armor value
        if(iArmorType == 8)       iDexMax = 1;
        else if(iArmorType == 7)  iDexMax = 1;
        else if(iArmorType == 5)  iDexMax = 2;
        else if(iArmorType == 4)  iDexMax = 4;
        else if(iArmorType == 3)  iDexMax = 4;
        else if(iArmorType == 2)  iDexMax = 6;
        else if(iArmorType == 1)  iDexMax = 8;

        // if their dex mod exceeds the max for their current armor
        if(iDexMod > iDexMax) iDexMod = iDexMax;
        //if (DEBUG) DoDebug("GetDefenderAC: End Section #2");
        // remove any dex bonus to AC
        iAC -= iDexMod;

        // remove any bonuses applied to PrC Skins
        iAC -= GetItemACValue( GetItemInSlot(INVENTORY_SLOT_CARMOUR, oDefender) );

        // if the skin AC bonus was racial "natural" AC, add it back in.
        // but only if it is not a touch attack
        if(!bIsTouchAttack)
        {
// motu99: This calculation is quite costly; has to loop through all feats of OBJECT_SELF several times (up to 22 times)
// if performance is an issue, better make one single loop, checking for the highest of the feats and return that
//[feats seem to be item properties on the creature / PC, so could we loop through all item properties on the characters? not sure]
            if      ( GetHasFeat(FEAT_NATARM_19) ) iAC += 19;
            else if( GetHasFeat(FEAT_NATARM_18) ) iAC += 18;
            else if( GetHasFeat(FEAT_NATARM_17) ) iAC += 17;
            else if( GetHasFeat(FEAT_NATARM_16) ) iAC += 16;
            else if( GetHasFeat(FEAT_NATARM_15) ) iAC += 15;
            else if( GetHasFeat(FEAT_NATARM_14) ) iAC += 14;
            else if( GetHasFeat(FEAT_NATARM_13) ) iAC += 13;
            else if( GetHasFeat(FEAT_NATARM_12) ) iAC += 12;
            else if( GetHasFeat(FEAT_NATARM_11) ) iAC += 11;
            else if( GetHasFeat(FEAT_NATARM_10) ) iAC += 10;
            else if( GetHasFeat(FEAT_NATARM_9) )  iAC += 9;
            else if( GetHasFeat(FEAT_NATARM_8) )  iAC += 8;
            else if( GetHasFeat(FEAT_NATARM_7) )  iAC += 7;
            else if( GetHasFeat(FEAT_NATARM_6) )  iAC += 6;
            else if( GetHasFeat(FEAT_NATARM_5) )  iAC += 5;
            else if( GetHasFeat(FEAT_NATARM_4) )  iAC += 4;
            else if( GetHasFeat(FEAT_NATARM_3) )  iAC += 3;
            else if( GetHasFeat(FEAT_NATARM_2) )  iAC += 2;
            else if( GetHasFeat(FEAT_NATARM_1) )  iAC += 1;
            //if (DEBUG) DoDebug("GetDefenderAC: End Section #3");
        }
    }

    // if helpless or stunned, can't use shield
    if(bIsHelpless || bIsStunned)
    {
        iAC -= GetItemACValue( GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oDefender) );
    }

    // AC rules are different for a touch attack
    // no shield, armor, or natural armor bonuses apply.
    if(bIsTouchAttack)
    {
        //if (DEBUG) DoDebug("GetDefenderAC: End Section #4");
        // Temporary storage, needed for Elude Touch
        int nNormalAC = iAC;

        // remove Armor AC
        iAC -= GetItemACValue( GetItemInSlot(INVENTORY_SLOT_CHEST, oDefender) );

        // remove natural armor AC
        iAC -= GetItemACValue( GetItemInSlot(INVENTORY_SLOT_NECK, oDefender) );

        // remove shield bonus - only if it has not been removed already
        if(!bIsHelpless && !bIsStunned)
            iAC -= GetItemACValue( GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oDefender) );

        // Remove AC from skin - only if it has not been removed already
        if(!(bGetIsDeniedDexBonus || bIsHelpless))
            iAC -= GetItemACValue( GetItemInSlot(INVENTORY_SLOT_CARMOUR, oDefender) );

        // Wilders get to add cha bonus to touch attacks only, but cannot exceed normal AC that way
        if(GetHasFeat(FEAT_WILDER_ELUDE_TOUCH, oDefender))
            iAC = PRCMin(iAC + GetAbilityModifier(ABILITY_CHARISMA, oDefender), nNormalAC);
    }
    //if (DEBUG) DoDebug("GetDefenderAC: End Section #5");
    return iAC;
}


// motu99: restructured code for better efficiency / readability March 16, 2007
// note that the attack boni calculated here also depend on the defender
// (for instance if weapon has an attack/enhancement bonus vs. specific alignments)

// the only source of defender specific AB in this function is the attacker's weapon
// if efficiency becomes an issue, it might be better to remember the defender (or its race/alignment),
// so that AB and other stuff will only be recalculated when the defender changes.

// at the current time, GetAttackBonus is calculated at the beginning of the round, but not for every attack.
// therefore, if the defender changes during the round, weapon boni versus specific enemy races or alignments are not properly accounted for
// so we eventually might want to move that part out of GetAttackBonus.
// also if we switch weapons during a combat round, this will not be not noticed until the beginning of the next round, when GetAttackBonus is called anew

// the following AB-sources are taken into account: (* = depends on Defender)
// Base Attack Bonus - iBAB
// Ability modifier due to Str/Dex/Wis - iAbilityBonus [motu99: could change during a round, if enemy does ability decreasing attacks]
// Bonus from Feats - iFeatBonus (Weapon Focus, Specialization, Prowess, Good aim) [motu99: will change during the round, if we equip other weapons, or if defenders comes into melee range for a ranged attack (with/without Point Blank Shot)]
// Two Weapon Fighting penalties - iTWFPenalty (is subtracted) [motu99: will change during the round, if we equip other weapons]
// Bonus / Penalties from combat modes - iCombatModeBonus (Flurry of Blows is treated elsewhere) [motu99: the PC can change the combat mode during a round]
// Magical Boni from Spells on Attacker - iMagicBonus [motu99: might not last through the round, or could be dispelled]
// * Boni on Weapon - iWeaponAttackBonus, iWeaponEnhancement [motu99: will change during the round, if defender's race or alignment changes]
int GetAttackBonus(object oDefender, object oAttacker, object oWeap, int iOffhand = 0, int iTouchAttackType = FALSE)
{
// note that oWeap could be gloves (for an unarmed monk) or a creature weapon
// passing gloves or ammunition to this function may not work well with the override feature in PerformAttack()
// [in order to calculate dual wielding penalties GetAttackBonus does not look up the weapon override variables, it looks directly into the inventory slots]
// possible solution: pass right and left weapons to this function! (but make sure, that GetAttackBonus is not used in other prc sources,unless you want to modify these sources!!)

    struct WeaponFeat sWeaponFeat; // holds all the feats relevant for the weapon (or rather weapon base type)
    int iAttackBonus       = 0;
    int iCappedAttackBonus = 0; //ebonfowl: bonuses are added to this value and truncated at the global attack limit if they are of the variety that are capped in normal combat. Can be disabled via the switch PRC_CAPPED_ATTACK_BONUS.
    int iCappedRightBonus  = 0; //ebonfowl: these are EffectAttackIncrease bonuses applied specifically to the right hand which add to the capped limit
    int iCappedRightPen    = 0; //ebonfowl: same as above but penalties
    int iCappedLeftBonus   = 0; //ebonfowl: these are EffectAttackIncrease bonuses applied specifically to the left hand which add to the capped limit
    int iCappedLeftPen     = 0; //ebonfowl: same as above but penalties
    int iAbilityBonus      = 0; // boni from abilities (Str, Dex, Wis) - also depends on feats (Finesse, Intuitive Attack) and type of attack (touch, melee, ranged)
    int iFeatBonus         = 0; // boni from feats (mostly weapon specific: weapon focus, specialization, prowess, weapon of choice)
    int iMagicBonus        = 0; // boni from AB increasing spells or spell effects on attacker
    int iCombatModeBonus   = 0; // boni / penalties from Combat Mode
    int iTWFPenalty        = 0; // penalty from two weapon fighting
    int iBAB               = GetBaseAttackBonus(oAttacker);
	// DoDebug("entering GetAttackBonus() for Weapon " + GetName(oWeap) + ", Attacker: " + GetName(oAttacker) + ", Defender: " + GetName(oDefender));
    int iWeaponAttackBonus = GetWeaponAttackBonusItemProperty(oWeap, oDefender);
    int iWeaponType        = GetBaseItemType(oWeap);
    int iCombatMode        = GetLastAttackMode(oAttacker);
    int iStr = GetAbilityModifier(ABILITY_STRENGTH, oAttacker);
    int iDex = GetAbilityModifier(ABILITY_DEXTERITY, oAttacker);
    int iWis = GetAbilityModifier(ABILITY_WISDOM, oAttacker);  // needed for ZenArchery and intuitive attack
    int bIsRangedWeapon = GetIsRangedWeaponType(iWeaponType); // = GetWeaponRanged(oWeap);

    // uses GetMonkEnhancement in case a glove/creature weapon is passed as oWeapon
    int iWeaponEnhancement = GetMonkEnhancement(oWeap, oDefender, oAttacker);
    
    if (GetLocalInt(oAttacker, "BABOverride")) iBAB = GetLocalInt(oAttacker, "BABOverride");

    // weapon specific feats
    sWeaponFeat = GetAllFeatsOfWeaponType(iWeaponType);

	int bFocus = 0;  
	int bEpicFocus = 0;  
	int bIsRangedTouchAttack = iTouchAttackType == TOUCH_ATTACK_RANGED || iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL;  
	int bIsMeleeTouchAttack = iTouchAttackType == TOUCH_ATTACK_MELEE_SPELL;  
	  
	if(bIsRangedTouchAttack)  
	{  
		// Weapon Focus(Ray) applies to ranged touch attacks  
		bFocus = GetHasFeat(FEAT_WEAPON_FOCUS_RAY, oAttacker);  
		if (bFocus) // no need to look for epic focus, if we don't have focus  
			bEpicFocus = GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_RAY, oAttacker);  
	}  
	else if(bIsMeleeTouchAttack)  
	{  
		// Weapon Focus(Touch Attack) applies to melee touch attacks  
		bFocus = GetHasFeat(FEAT_WEAPON_FOCUS_TOUCH, oAttacker);  
		if (bFocus) // no need to look for epic focus, if we don't have focus  
			bEpicFocus = GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_TOUCH, oAttacker);  
	}  
	else  
	{   // no touch attack, normal weapon focus feats  
		bFocus = GetHasFeat(sWeaponFeat.Focus, oAttacker);  
		if (bFocus) // no need to look for epic focus, if we don't have focus  
			bEpicFocus   = GetHasFeat(sWeaponFeat.EpicFocus, oAttacker);  
	}

/*     int bFocus = 0;
    int bEpicFocus = 0;
    int bIsRangedTouchAttack = iTouchAttackType == TOUCH_ATTACK_RANGED || iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL;

    if(bIsRangedTouchAttack)
    {
        // Weapon Focus(Ray) applies to touch attacks(motu99: ranged only?)
        bFocus = GetHasFeat(FEAT_WEAPON_FOCUS_RAY, oAttacker);
        if (bFocus) // no need to look for epic focus, if we don't have focus
            bEpicFocus = GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_RAY, oAttacker);
    }
    else
    {   // no touch attack, normal weapon focus feats
        bFocus = GetHasFeat(sWeaponFeat.Focus, oAttacker);
        if (bFocus) // no need to look for epic focus, if we don't have focus
            bEpicFocus   = GetHasFeat(sWeaponFeat.EpicFocus, oAttacker);
    } */

    int bEpicProwess = GetHasFeat(FEAT_EPIC_PROWESS, oAttacker);

    // attack bonus from feats
    if(bFocus) iFeatBonus       += 1;
    if(bEpicFocus) iFeatBonus   += 2;
    if(bEpicProwess) iFeatBonus += 1;


//  if(bWeaponOfChoice)  iFeatBonus += (GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oAttacker) / 5);
// motu99:  original calculation was  not correct: Gimoire says that we get AB +1 at level 5, another +1 at level 13 and +1 every third level thereafter
// lets hope Grimoire was right, otherwise I'll be off on a trip to Canossa
    int iWeaponMasterLevel = GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oAttacker);

    // only look for weapon of choice and related AB increase, if we have enough weapon master levels for the superior weapon focus feat
    if(iWeaponMasterLevel >= WEAPON_MASTER_LEVEL_SUPERIOR_WEAPON_FOCUS)
    {
        int bWeaponOfChoice = GetHasFeat(sWeaponFeat.WeaponOfChoice, oAttacker);

        if (bWeaponOfChoice)
        {
            iFeatBonus++;
            if (iWeaponMasterLevel >= WEAPON_MASTER_LEVEL_EPIC_SUPERIOR_WEAPON_FOCUS)
                iFeatBonus += (iWeaponMasterLevel-WEAPON_MASTER_LEVEL_EPIC_SUPERIOR_WEAPON_FOCUS)/3 +1;
        }
    }


    if(!bIsRangedWeapon && !bIsRangedTouchAttack) // first do calculations for "normal" melee weapons (includes unarmed, even torches)
    {
        //this is the attack bonus from ability for melee combat only
        //ranged combat goes further down

        // Melee Specific Rules
        int bIsFinessableWeapon = FALSE;
        int iCreatureSize   = PRCGetCreatureSize(oAttacker);
        int iWeaponSize = StringToInt(Get2DACache("baseitems", "WeaponSize", iWeaponType));

        if(iWeaponType == BASE_ITEM_KATANA)
        { // if we wield a katana, see if we have the katana finesse feat; if yes we have a finessable weapon
            bIsFinessableWeapon = GetHasFeat(FEAT_KATANA_FINESSE, oAttacker);
        }
        else if(GetTag(oWeap) == "prc_eldrtch_glv")
        {
            bIsFinessableWeapon = GetHasFeat(FEAT_WEAPON_FINESSE, oAttacker);
        }        
        else if(GetIsNaturalWeapon(oWeap))
        { // all "natural" weapons are finessable (the critters have them from their birth - if they cannot use DEX for their own limbs ...)
            bIsFinessableWeapon = GetHasFeat(FEAT_WEAPON_FINESSE, oAttacker);
        }
        // motu99: added a switch in order to have sensible rules for small creatures, don't know it its PnP, but assume so
        else if(GetPRCSwitch(PRC_SMALL_CREATURE_FINESSE) && iWeaponSize < iCreatureSize)
        { // with the switch on, weapon is only finessable if its size is smaller than the creature size
            bIsFinessableWeapon = GetHasFeat(FEAT_WEAPON_FINESSE, oAttacker);
        }
        // switch is off, so normal bioware rules: finessable weapons are rapiers and small or tiny weapons (size <= 2)
        else if(iWeaponType == BASE_ITEM_RAPIER || iWeaponSize <= WEAPON_SIZE_SMALL)
        {
            bIsFinessableWeapon = GetHasFeat(FEAT_WEAPON_FINESSE, oAttacker);
        }

        // now increase attack bonus from stats for melee
        // str normally unless exceptional circumstances
        // if(iStr > bTempBonus) // motu99: that is strange, this code prehibits any attack penalties due to low strength for melee weapons; removed this check
        iAbilityBonus = iStr;

        // if we have a finessable weapon, we take Dex whenever it is higher than Str
        if(bIsFinessableWeapon)
        {
            if(iDex > iAbilityBonus)    iAbilityBonus = iDex;
        }

        // Two Weapon Fighting Penalties
        // NwN only allows melee weapons to be dual wielded
        // motu99:  this calculation partly ignores the weapon overrides we might have passed to PerformAttack()

        int iOffhandWeaponType;
        int bIsDoubleSidedWeapon = FALSE;

        // motu99: added check for double sided weapons
        if(GetIsDoubleSidedWeaponType(iWeaponType))
        {
            bIsDoubleSidedWeapon = TRUE;
            // iOffhandWeaponType = iWeaponType; // motu99 don't need this
        }
        else
        {   // if it is an offhand attack, we assume the weapon given to us in oWeap is the offhand weapon
            if (iOffhand)
            {
                iOffhandWeaponType = iWeaponType;
            }
            else // otherwise we must look in the left hand slot (this ignores any overrides from PerformAttack)
            {
                iOffhandWeaponType = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oAttacker));
            }
        }

        //ebonfowl: now checking for attack bonuses and penalties that are hand-specific, only the highest applies in each case

        if(iOffhand) //ebonfowl: is it an off-hand attack?
        {
            effect eEffect = GetFirstEffect(oAttacker);
            int nType, iEffectSubtype;
            
            while(GetIsEffectValid(eEffect))
            {
                nType = GetEffectType(eEffect);
                iEffectSubtype = GetEffectInteger(eEffect, 1);

                int iBonus = 0;

                int iRace = MyPRCGetRacialType(oDefender);

                int iEffectRace = GetEffectInteger(eEffect, 2);

                int iGoodEvil = GetAlignmentGoodEvil(oDefender);
                int iLawChaos = GetAlignmentLawChaos(oDefender);

                int iEffectLawChaos = GetEffectInteger(eEffect, 3);
                int iEffectGoodEvil = GetEffectInteger(eEffect, 4);

                if(nType == EFFECT_TYPE_ATTACK_INCREASE && iEffectSubtype == 2)
                {
                    if(iEffectRace != 28)
                    {
                        if(iEffectRace == iRace)
                        {
                            //Define racial type-based attack increase and set the bonus if the highest one on that hand
                            iBonus = GetEffectInteger(eEffect, 0);
                            if(iBonus > iCappedLeftBonus) iCappedLeftBonus = iBonus;
                        }
                    }
                    else if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
                    {
                        if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                        {
                            //Define alignment-based attack increase and set the bonus if the highest one on that hand
                            iBonus = GetEffectInteger(eEffect, 0);
                            if(iBonus > iCappedLeftBonus) iCappedLeftBonus = iBonus;
                        }
                    }
                    else if(iEffectLawChaos == 0 && iEffectGoodEvil == 0 && iEffectRace == 28)
                    {
                        //Define generic attack increase and set the bonus if the highest one on that hand
                        iBonus = GetEffectInteger(eEffect, 0);
                        if(iBonus > iCappedLeftBonus) iCappedLeftBonus = iBonus;
                    }
            
                }
                else if(nType == EFFECT_TYPE_ATTACK_DECREASE && iEffectSubtype == 2)
                {
                    if(iEffectRace != 28)
                    {
                        if(iEffectRace == iRace)
                        {
                            //Define racial type-based attack increase and set the bonus if the highest one on that hand
                            iBonus = GetEffectInteger(eEffect, 0);
                            if(iBonus > iCappedLeftPen) iCappedLeftPen = iBonus;
                        }
                    }
                    else if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
                    {
                        if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                        {
                            //Define alignment-based attack increase and set the bonus if the highest one on that hand
                            iBonus = GetEffectInteger(eEffect, 0);
                            if(iBonus > iCappedLeftPen) iCappedLeftPen = iBonus;
                        }
                    }
                    else if(iEffectLawChaos == 0 && iEffectGoodEvil == 0 && iEffectRace == 28)
                    {
                        //Define generic attack increase and set the bonus if the highest one on that hand
                        iBonus = GetEffectInteger(eEffect, 0);
                        if(iBonus > iCappedLeftPen) iCappedLeftPen = iBonus;
                    }
            
                }

                eEffect = GetNextEffect(oAttacker);
            }

            iCappedLeftBonus -= iCappedLeftPen;
        }
        else //ebonfowl: anything else will be a main-hand attack
        {
            effect eEffect = GetFirstEffect(oAttacker);
            int nType, iEffectSubtype;
            
            while(GetIsEffectValid(eEffect))
            {
                nType = GetEffectType(eEffect);
                iEffectSubtype = GetEffectInteger(eEffect, 1);

                int iBonus = 0;

                int iRace = MyPRCGetRacialType(oDefender);

                int iEffectRace = GetEffectInteger(eEffect, 2);

                int iGoodEvil = GetAlignmentGoodEvil(oDefender);
                int iLawChaos = GetAlignmentLawChaos(oDefender);

                int iEffectLawChaos = GetEffectInteger(eEffect, 3);
                int iEffectGoodEvil = GetEffectInteger(eEffect, 4);

                if(nType == EFFECT_TYPE_ATTACK_INCREASE && iEffectSubtype == 1)
                {
                    if(iEffectRace != 28)
                    {
                        if(iEffectRace == iRace)
                        {
                            //Define racial type-based attack increase and set the bonus if the highest one on that hand
                            iBonus = GetEffectInteger(eEffect, 0);
                            if(iBonus > iCappedRightBonus) iCappedRightBonus = iBonus;
                        }
                    }
                    else if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
                    {
                        if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                        {
                            //Define alignment-based attack increase and set the bonus if the highest one on that hand
                            iBonus = GetEffectInteger(eEffect, 0);
                            if(iBonus > iCappedRightBonus) iCappedRightBonus = iBonus;
                        }
                    }
                    else if(iEffectLawChaos == 0 && iEffectGoodEvil == 0 && iEffectRace == 28)
                    {
                        //Define generic attack increase and set the bonus if the highest one on that hand
                        iBonus = GetEffectInteger(eEffect, 0);
                        if(iBonus > iCappedRightBonus) iCappedRightBonus = iBonus;
                    }
            
                }
                else if(nType == EFFECT_TYPE_ATTACK_DECREASE && iEffectSubtype == 1)
                {
                    if(iEffectRace != 28)
                    {
                        if(iEffectRace == iRace)
                        {
                            //Define racial type-based attack increase and set the bonus if the highest one on that hand
                            iBonus = GetEffectInteger(eEffect, 0);
                            if(iBonus > iCappedRightPen) iCappedRightPen = iBonus;
                        }
                    }
                    else if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
                    {
                        if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                        {
                            //Define alignment-based attack increase and set the bonus if the highest one on that hand
                            iBonus = GetEffectInteger(eEffect, 0);
                            if(iBonus > iCappedRightPen) iCappedRightPen = iBonus;
                        }
                    }
                    else if(iEffectLawChaos == 0 && iEffectGoodEvil == 0 && iEffectRace == 28)
                    {
                        //Define generic attack increase and set the bonus if the highest one on that hand
                        iBonus = GetEffectInteger(eEffect, 0);
                        if(iBonus > iCappedRightPen) iCappedRightPen = iBonus;
                    }
            
                }

                eEffect = GetNextEffect(oAttacker);
            }

            iCappedRightBonus -= iCappedRightPen;
        }

        if(bIsDoubleSidedWeapon || GetIsOffhandWeaponType(iOffhandWeaponType))
        {
            int bOffHandLight;

            if(bIsDoubleSidedWeapon)
                bOffHandLight = TRUE;
            else
            { // find out offhand weapon size, to see if it is light
                int iOffhandWeaponSize;
                if (iOffhandWeaponType == iWeaponType)
                    iOffhandWeaponSize = iWeaponSize;
                else
                    iOffhandWeaponSize = StringToInt(Get2DACache("baseitems", "WeaponSize", iOffhandWeaponType));

                // is the size appropriate for a light weapon?
                bOffHandLight = (iOffhandWeaponSize < iCreatureSize);  // motu99: added creature size
            }

            int bHasTWF = FALSE;
            int bHasAmbidex = FALSE;

            // since there is no way to determine the value of AB effects
            // applied to a PC, I had to add Absolute Ambidexterity here

            int bHasAbsoluteAmbidex = FALSE;

            if(GetHasFeat(FEAT_AMBIDEXTERITY, oAttacker) )        bHasAmbidex = TRUE; // motu99: Ambidex and TWF were mixed up, changed that
            if(GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oAttacker) )  bHasTWF = TRUE;
            if(GetHasFeat(FEAT_ABSOLUTE_AMBIDEX, oAttacker) )     bHasAbsoluteAmbidex = TRUE;

            if(GetLevelByClass(CLASS_TYPE_RANGER, oAttacker) >= RANGER_LEVEL_DUAL_WIELD)
            {
                object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oAttacker);
                int iArmorType = GetArmorType(oArmor);
                if(iArmorType != ARMOR_TYPE_MEDIUM && iArmorType != ARMOR_TYPE_HEAVY)
                {
                    bHasTWF = TRUE;
                    bHasAmbidex = TRUE;
                }
                else
                { // ranger looses all dual wielding abilities if in medium armor or higher
                    bHasTWF = FALSE;
                    bHasAmbidex = FALSE;
                }

            }

            // a tempest using two sided weapons or in medium or heavy armor looses absolute ambidex feat
            int iTempestLevel = GetLevelByClass(CLASS_TYPE_TEMPEST, oAttacker);
            int nBloodclaw    = GetLevelByClass(CLASS_TYPE_BLOODCLAW_MASTER, oAttacker);
            if(iTempestLevel)
            {
                object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oAttacker);
                int iArmorType = GetArmorType(oArmor);
                if(bIsDoubleSidedWeapon || iArmorType == ARMOR_TYPE_MEDIUM || iArmorType == ARMOR_TYPE_HEAVY)
                    bHasAbsoluteAmbidex = FALSE;
                else if (iTempestLevel >= TEMPEST_LEVEL_ABS_AMBIDEX || nBloodclaw >= 2)
                    bHasAbsoluteAmbidex = TRUE;
            }

            if(iOffhand && !bHasAmbidex)    iTWFPenalty = 10;  // motu99: old code was wrong, because of confusing variable name (what should have been called iOffhand was called iMainHand)
            else                            iTWFPenalty = 6;

            if(bHasTWF)                    iTWFPenalty -= 2;
            if(bOffHandLight)              iTWFPenalty -= 2;
            if(bHasAbsoluteAmbidex)        iTWFPenalty -= 2;  // motu99: actually, if the absoluteambidex adds a permanent +2 to AB, this should be deleted

        }
        // power attack can only be used in melee
        // Handle the PRC Power Attack BA pay, if any.
        iCombatModeBonus -= GetLocalInt(oAttacker, "PRC_PowerAttack_Level");

        // Power Attack combat modes. The stacking of these with PRC Power attack is handled by the PRC PA scripts
        if     (iCombatMode == COMBAT_MODE_POWER_ATTACK)          iCombatModeBonus -= 5;
        else if(iCombatMode == COMBAT_MODE_IMPROVED_POWER_ATTACK) iCombatModeBonus -= 10;

// motu99: might have to add flurry combat mode (is covered in initialization of PerformAttack and PerformAttackRound, but it can change)
//      if (iCombatMode == COMBAT_MODE_FLURRY_OF_BLOWS) iCombatModeBonus -= 2;

        // dirty fighting, although a combat mode, should not be checked here, because we forfeit all attacks in the round when we use it

    }
    else // Ranged Specific Rules
    {
        // range penalty not yet accounted for as the 2da's are messed up
        // the range increment for throwing axes is 63, while it's 20 for bows???

        // dex or wis bonus
        if(iWis > iDex && GetHasFeat(FEAT_ZEN_ARCHERY, oAttacker))
            iAbilityBonus = iWis;
        else
            iAbilityBonus = iDex;

        if(GetMeleeAttackers15ft(oAttacker)) // motu99: The function actually checks if attackers are within 10 feet
        {
            if(GetHasFeat(FEAT_POINT_BLANK_SHOT,oAttacker))
                iFeatBonus += 1;
            else
                iFeatBonus -= 4;
        }

        // Halfling +1 bonus for throwing weapons
        if (GetIsThrowingWeaponType(iWeaponType) && GetHasFeat(FEAT_GOOD_AIM, oAttacker))
            iFeatBonus += 1; // we add this to the feat bonus, because it only depends on the feat and the weapon used, not on the defender
    }

    // if they have intuitive attack feat, checks if wisdom is highest,
    // this applies to ranged attacks with crossbows and slings,
    // and melee attacks with any other simple weapon, but not to touch attacks
    // motu99: optimized the sequence of checks (least expensive check first)
    if( iWis > iAbilityBonus
        && GetIsSimpleWeaponType(iWeaponType)
        && GetHasFeat(FEAT_INTUITIVE_ATTACK, oAttacker) )
            iAbilityBonus = iWis;

	//touch attacks always use dex, no matter what. Therefore override any calculations we have done so far  
	//unless it's a ranged touch attack and the attacker has Zen Archery with higher WIS  
	if(iTouchAttackType)  
	{  
		if((iTouchAttackType == TOUCH_ATTACK_RANGED || iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL)  
			&& iWis > iDex && GetHasFeat(FEAT_ZEN_ARCHERY, oAttacker))  
			iAbilityBonus = iWis;  
		else  
			iAbilityBonus = iDex;  
	}

/*     //touch attacks always use dex, no matter what. Therefore override any calculations we have done so far
    if(iTouchAttackType)
        iAbilityBonus = iDex; */

     // Expertise penalties apply to all attack rolls
     if     (iCombatMode == COMBAT_MODE_EXPERTISE)          iCombatModeBonus -= 5;
     else if(iCombatMode == COMBAT_MODE_IMPROVED_EXPERTISE) iCombatModeBonus -= 10;

    // get the magical attack bonus on the attacker from AB increasing spells
    iMagicBonus = GetMagicalAttackBonus(oAttacker, oDefender);

     // everything starts from BAB
    iAttackBonus = iBAB;

    // adds boni from feats
    iAttackBonus += iFeatBonus;

    // adds ability modifiers to attack bonus
    iAttackBonus += iAbilityBonus;

    // subtracts two weapon fighting penalties (iTWFPenalty is always positive or zero)
    iAttackBonus -= iTWFPenalty;

    // adds bonus from combat modes (these are actually penalties, so iCombatModeBonus is always negative)
    iAttackBonus += iCombatModeBonus;

    // Adds all spell bonuses / penalties on the PC
    iCappedAttackBonus += iMagicBonus;

    // up to now iAttackBonus should be independent of Defender, so it is likely to remain constant during a whole round
    // however, combat mode can change, weapons can be equipped / unequipped (not always starts a new combat round)
    // spells can run out during the round, etc.

    // adds weapon enhancement to the bonus
    iCappedAttackBonus += iWeaponEnhancement;

    // adds weapon attack boni to the bonus
    iCappedAttackBonus += iWeaponAttackBonus;

    //ebonfowl: adds handedness attack bonus to the capped total
    //You can add both as this is attack-specific so one will always be 0
    //Hand-specfic penalties are already subtracted out at this point
    iCappedAttackBonus += iCappedLeftBonus;
    iCappedAttackBonus += iCappedRightBonus;

    //ebonfowl: cutoff iCappedAttackBonus at the limit set globally if PRC_CAPPED_ATTACK_BONUS is TRUE
    
    if(GetPRCSwitch(PRC_CAPPED_ATTACK_BONUS))
    {
        int iAttackBonusCap = GetAttackBonusLimit();

        if (iCappedAttackBonus > iAttackBonusCap) iCappedAttackBonus = iAttackBonusCap;
    }

    //ebonfowl: adds the capped effects to the other effects for the final total

    iAttackBonus += iCappedAttackBonus;

    if (GetPRCSwitch(PRC_COMBAT_DEBUG))
    {
        string sDebugFeedback = PRC_TEXT_WHITE;
        sDebugFeedback += ("AB = " + IntToString(iAttackBonus) + " : ");
        sDebugFeedback += ("BAB (" + IntToString(iBAB) + ")");
        sDebugFeedback += (" + Feats (" + IntToString(iFeatBonus) + ")");
        sDebugFeedback += (" + Stat Bonus (" + IntToString(iAbilityBonus) + ")");
        sDebugFeedback += (" - TWF Penalty (" + IntToString(iTWFPenalty) + ")");
        sDebugFeedback += (" - Combat Mode (" + IntToString(-iCombatModeBonus) + ")");
        sDebugFeedback += (" + Spells (" + IntToString(iMagicBonus) + ")");
        sDebugFeedback += (" + WeapEnh (" + IntToString(iWeaponEnhancement) + ")");
        sDebugFeedback += (" + WeapAB (" + IntToString(iWeaponAttackBonus) + ")");
        DoDebug(sDebugFeedback);
    }

    return iAttackBonus;
}

// this is to be used in GetAttackRoll since it needs to be checked every attack instead of each round.
int GetAttackModVersusDefender(object oDefender, object oAttacker, object oWeapon, int iTouchAttackType = FALSE)
{
    int iAttackMod = 0;

    // add bonus +2 for flanking, invisible attacker, attacking blind opponent
    // motu99: Note that GetIsFlanked does not work reliably (at least in PRC 3.1c)
    if( GetIsFlanked(oDefender, oAttacker) )
    {
        if (DEBUG_BATTLE_FLANKING) FloatingTextStringOnCreature("**** FLANKING AB BONUS ****", oDefender);
        if (DEBUG_BATTLE_FLANKING) DoDebug("Flanking bonus to AB", oDefender);
        iAttackMod += 2;
        if(GetLocalInt(oAttacker, "UmbralStrike")) iAttackMod += 2;
// DoDebug("GetAttackModVersusDefender: Defender flanked");
    }
    //if (DEBUG) DoDebug("GetAttackModVersusDefender: End Section #1");
    if  (   (   PRCGetHasEffect(EFFECT_TYPE_INVISIBILITY, oAttacker)
                || PRCGetHasEffect(EFFECT_TYPE_IMPROVEDINVISIBILITY, oAttacker)
                && !GetHasFeat(FEAT_BLIND_FIGHT, oDefender)
            )
            || PRCGetHasEffect(EFFECT_TYPE_BLINDNESS, oDefender)
        )
        iAttackMod += 2;

    // +2 attack bonus if they are stunned or frightened
    if( PRCGetHasEffect(EFFECT_TYPE_STUNNED, oDefender)
        || PRCGetHasEffect(EFFECT_TYPE_FRIGHTENED, oDefender)  )
    {
        iAttackMod += 2;
// DoDebug("GetAttackModVersusDefender: Defender frightened or stunned");
    }
    //if (DEBUG) DoDebug("GetAttackModVersusDefender: End Section #2");
    int bIsMeleeWeapon = !GetWeaponRanged(oWeapon);
    int bIsRangedTouchAttack = iTouchAttackType == TOUCH_ATTACK_RANGED || iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL;
    if(bIsRangedTouchAttack)
        bIsMeleeWeapon = FALSE;

    int bIsKnockedDown = GetHasFeatEffect(FEAT_KNOCKDOWN, oDefender) || GetHasFeatEffect(FEAT_IMPROVED_KNOCKDOWN, oDefender);

    if(bIsMeleeWeapon)
    {
        // +4 to attack in melee against a helpless target.
        if(GetIsHelpless(oDefender)) iAttackMod += 4;

        // +4 attack bonus to a prone target (in melee) / -4 in ranged combat
        if(bIsKnockedDown)  iAttackMod += 4;
    }
    else // ranged combat
    {
        // -4 attack bonus to a prone target in ranged combat
        if(bIsKnockedDown) iAttackMod -= 4;
    }
    //if (DEBUG) DoDebug("GetAttackModVersusDefender: End Section #3");

     // Battle training (Gnomes and Dwarves)
     // adds +1 based on enemy race
//   int iRacialType = MyPRCGetRacialType(oAttacker); // motu99: don't need the attacker race, just check for the feats!
//     if(iRacialType == RACIAL_TYPE_DWARF || iRacialType == RACIAL_TYPE_GNOME)
    {
        int bOrcTrain = GetHasFeat(FEAT_BATTLE_TRAINING_VERSUS_ORCS, oAttacker);
        int bGobTrain = GetHasFeat(FEAT_BATTLE_TRAINING_VERSUS_GOBLINS, oAttacker);
        int bLizTrain = GetHasFeat(FEAT_BATTLE_TRAINING_VERSUS_REPTILIANS, oAttacker);
        int iEnemyRace = MyPRCGetRacialType(oDefender);

        if(bOrcTrain && iEnemyRace == RACIAL_TYPE_HUMANOID_ORC)         iAttackMod += 1;
        if(bGobTrain && iEnemyRace == RACIAL_TYPE_HUMANOID_GOBLINOID)   iAttackMod += 1;
        if(bLizTrain && iEnemyRace == RACIAL_TYPE_HUMANOID_REPTILIAN)   iAttackMod += 1;
    }
    //if (DEBUG) DoDebug("GetAttackModVersusDefender: End Section #4");
//   if( GetHasFeat(FEAT_SMALL, oAttacker) ||  GetHasFeat(FEAT_LARGE, oAttacker) )  // don't really need the feat, just check for size difference
    {
        int iDefenderSize = PRCGetCreatureSize(oDefender);
        int iAttackerSize = PRCGetCreatureSize(oAttacker);
        if(iAttackerSize < iDefenderSize) // we could also use size difference to calculate the attack mod; have to check PnP rules
            iAttackMod++;
        if(iAttackerSize > iDefenderSize)
            iAttackMod--;
    }
// DoDebug("GetAttackModVersusDefender() returns " + IntToString(iAttackMod));
    //if (DEBUG) DoDebug("GetAttackModVersusDefender: End Section #5");
    return iAttackMod;
}

int GetAttackRoll(object oDefender, object oAttacker, object oWeapon, int iOffhand = 0, int iAttackBonus = 0, int iMod = 0, int bShowFeedback = TRUE, float fDelay = 0.0, int iTouchAttackType = FALSE)
// returns 1 on a normal hit
// returns 2 on a critical hit
// never returns a 2, if defender is critical immune
{
    if (!iAttackBonus) // only calculate attack bonus, if not already done so
        iAttackBonus = GetAttackBonus(oDefender, oAttacker, oWeapon, iOffhand, iTouchAttackType);

    int iDiceRoll = d20();
    //if (DEBUG) DoDebug("Starting DSPerfectOrder");
    // All rolls = 11 for this guy
    if (GetLocalInt(oAttacker, "DSPerfectOrder"))
        iDiceRoll = 11;
    //if (DEBUG) DoDebug("Ending DSPerfectOrder");
    //string sDebugFeedback = "";
    //if (DEBUG) DoDebug("GetAttackRoll: Line #1");
    //int bDebug = GetPRCSwitch(PRC_COMBAT_DEBUG);
    //if (DEBUG) DoDebug("GetAttackRoll: Line #2");
    //if (bDebug) sDebugFeedback += "d20 ("  + IntToString(iDiceRoll) + ")";
    //if (DEBUG) DoDebug("GetAttackRoll: Line #3");
    //if (bDebug) sDebugFeedback += " + AB (" + IntToString(iAttackBonus) + ")";
    //if (DEBUG) DoDebug("GetAttackRoll: Line #4");
    iAttackBonus += iMod;
    // Divine Fury ability
    if(GetLocalInt(oAttacker, "RKVDivineFury"))
        iAttackBonus += 4;

    // Master of Nine
    if(GetLevelByClass(CLASS_TYPE_MASTER_OF_NINE, oAttacker) > 2)
    {
        int nLastClass = GetLocalInt(oAttacker, "PRC_CurrentManeuver_InitiatingClass") - 1;//GetInitiatingClass(oAttacker);
        if(nLastClass == CLASS_TYPE_WARBLADE
        || nLastClass == CLASS_TYPE_SWORDSAGE
        || nLastClass == CLASS_TYPE_CRUSADER)
        {
            // Increases maneuver attacks by 2
            iAttackBonus += 2;
        }
    }

    // Shadow Sun Ninja
    if(GetLocalInt(oAttacker, "SSN_DARKWL"))
    {
        effect eSSN = GetFirstEffect(oDefender);
        while(GetIsEffectValid(eSSN))
        {
            if(GetEffectType(eSSN) == EFFECT_TYPE_BLINDNESS)
            {
                iAttackBonus += 4;
                break;
            }
            eSSN = GetNextEffect(oDefender);
        }
    }
    //if (DEBUG) DoDebug("GetAttackRoll: Line #5");
    //if(bDebug) sDebugFeedback += " - APR penalty ("  + IntToString(iMod * -1) + ")";
    //if (DEBUG) DoDebug("Starting GetAttackModVersusDefender");
    int iDefenderMod = GetAttackModVersusDefender(oDefender, oAttacker, oWeapon, iTouchAttackType);
    iAttackBonus += iDefenderMod;
    
    SetLocalInt(oAttacker, "PRCAttackBonus", iDiceRoll + iAttackBonus);
    DelayCommand(1.5, DeleteLocalInt(oAttacker, "PRCAttackBonus"));

    //if(bDebug) sDebugFeedback += " + Atk vs Def Adj ("  + IntToString(iDefenderMod) + ")";

    //if (DEBUG) DoDebug("Starting GetDefenderAC");
    int iEnemyAC = GetDefenderAC(oDefender, oAttacker, iTouchAttackType);

    //if (bDebug) sDebugFeedback += " *versus* AC ("  + IntToString(iEnemyAC) + ")";
    //if (bDebug) sDebugFeedback = COLOR_WHITE + "Attack Roll = " + IntToString(iAttackBonus + iDiceRoll) + ": " + sDebugFeedback;
    //if (DEBUG) DoDebug("GetAttackRoll: End Section #1");
    int iWeaponType = GetBaseItemType(oWeapon);
    int iCritThreat = GetWeaponCriticalRange(oAttacker, oWeapon, iTouchAttackType);

    //If using Killing Shot, ciritical range improves by 2;
    if(GetLocalInt(oAttacker, "KillingShotCritical") )
    {
        iCritThreat -= 2;
        DeleteLocalInt(oAttacker, "KillingShotCritical");
    }

    // print off-hand of off-hand attack
    string sFeedback ="";
    if(iOffhand) sFeedback += PRC_TEXT_ORANGE + GetStringByStrRef(1559)/*"Off Hand"*/ + " : ";

    // change color of attacker if it is Player or NPC
    if(GetIsPC(oAttacker)) sFeedback += PRC_TEXT_LIGHT_BLUE;
    else                   sFeedback += PRC_TEXT_LIGHT_PURPLE;

    // display name of attacker
    sFeedback +=  GetName(oAttacker);

    int bIsMeleeTouchAttack = iTouchAttackType == TOUCH_ATTACK_MELEE || iTouchAttackType == TOUCH_ATTACK_MELEE_SPELL;
    int bIsRangedTouchAttack = iTouchAttackType == TOUCH_ATTACK_RANGED || iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL;
    // show proper message for touch attacks or normal attacks.
    if(bIsRangedTouchAttack)
        sFeedback += PRC_TEXT_PURPLE + " attempts ranged touch attack on ";
    else if(bIsMeleeTouchAttack)
        sFeedback += PRC_TEXT_PURPLE + " attempts touch attack on ";
    else
        sFeedback += PRC_TEXT_ORANGE + " attacks ";

    sFeedback +=  GetName(oDefender) + ": ";
    //if (DEBUG) DoDebug("GetAttackRoll: End Section #2");
    int iReturn = 0;
    // roll concealment check
    int iConcealment = GetIsConcealed(oDefender, oAttacker);
    int iConcealRoll = d100();
    int bEnemyIsConcealed = FALSE;

    if(iConcealRoll <= iConcealment)
    {
        // Those with blind-fight get a re-roll
        if( GetHasFeat(FEAT_BLIND_FIGHT, oAttacker) )
        {
            iConcealRoll = d100();
        }

        if(iConcealRoll <= iConcealment)
        {
            bEnemyIsConcealed = TRUE;
            sFeedback += "*"+GetStringByStrRef(514)/*miss*/+"*: (Enemy is Concealed)";
            iReturn = 0;
        }
    }
   // if (DEBUG) DoDebug("GetAttackRoll: End Section #3");
    if (!bEnemyIsConcealed)
    {
        // Autmatically dodge the first attack of each round
        if(bFirstAttack && GetHasFeat(FEAT_EPIC_DODGE, oDefender))
        {
            sFeedback += "*"+GetStringByStrRef(514)/*miss*/+"*: (Enemy Dodged)";
            iReturn = 0;
        }

        // did we hit? meaning we overcome the enemy's AC and did not roll a one (iDiceRoll == 1)
        int bHit = iDiceRoll + iAttackBonus > iEnemyAC && iDiceRoll != 1;

        // Check for a critical threat
        if( iDiceRoll == 20 // we always score a critical hit on a twenty
            || (bHit && iDiceRoll >= iCritThreat) )  // otherwise we must have hit and overcome the critical threat range
        {
            sFeedback += "*Critical Hit*: (" + IntToString(iDiceRoll) + " + " + IntToString(iAttackBonus) + " = " + IntToString(iDiceRoll + iAttackBonus) + "): ";

            //Roll again to see if we scored a critical hit
            //FistOfRaziels of over level 3 automatically confirm critical hits
            //when smiting evil
            int iCritThreatRoll;
            if(GetLocalInt(oAttacker, "FistOfRazielSpecialSmiteCritical") )
            {
                iCritThreatRoll = 10000;
                DeleteLocalInt(oAttacker, "FistOfRazielSpecialSmiteCritical");
            }
            else
            {
                    iCritThreatRoll = d20();
                    if (GetLocalInt(oDefender, "BoneCrusher")) iCritThreatRoll += 10;
                    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oAttacker) >= 3) 
                    {
                        iCritThreatRoll += GetAbilityModifier(ABILITY_INTELLIGENCE, oAttacker); //Warblade Battle Ardorr
                        if (DEBUG_BATTLE_ARDOR) DoDebug("Warblade Battle Ardor critical attack threat roll bonus");
                    }
            }
           // if (DEBUG) DoDebug("GetAttackRoll: End Section #4");

            if(!GetIsImmune(oDefender, IMMUNITY_TYPE_CRITICAL_HIT) )
            {
                sFeedback += "*Threat Roll*: (" + IntToString(iCritThreatRoll) + " + " + IntToString(iAttackBonus) + " = " + IntToString(iCritThreatRoll + iAttackBonus) + ")";
                if(iCritThreatRoll + iAttackBonus > iEnemyAC)   iReturn = 2;
                else                                            iReturn = 1;
            }
            else
            {
                sFeedback += "*Target Immune to Critical Hits*";
                iReturn = 1;
            }
        }
        //Just a regular hit
        else if(bHit)
        {
            sFeedback += "*hit*: (" + IntToString(iDiceRoll) + " + " + IntToString(iAttackBonus) + " = " + IntToString(iDiceRoll + iAttackBonus) + ")";
            iReturn = 1;
        }
        //Missed
        else
        {
            sFeedback += "*miss*: (" + IntToString(iDiceRoll) + " + " + IntToString(iAttackBonus) + " = " + IntToString(iDiceRoll + iAttackBonus) + ")";
            iReturn = 0;
        }
        //if (DEBUG) DoDebug("GetAttackRoll: End Section #5");
    }
    //arrow VFX
    //this is done with crossbows and other ranged weapons
    //at least you see some projectile rather than none at all
    if(GetIsRangedWeaponType(iWeaponType))
    {
        if(iReturn)
            AssignCommand(oAttacker, ApplyEffectToObject(DURATION_TYPE_INSTANT,
                EffectVisualEffect(NORMAL_ARROW, FALSE), oDefender));
        else
            AssignCommand(oAttacker, ApplyEffectToObject(DURATION_TYPE_INSTANT,
                EffectVisualEffect(NORMAL_ARROW, TRUE), oDefender));
    }

    if(bShowFeedback)
    {
        SendMessageToPC(oAttacker, sFeedback); // DelayCommand(fDelay, SendMessageToPC(oAttacker, sFeedback));
        //if (bDebug) SendMessageToPC(oAttacker, sDebugFeedback);
    }
   // if (DEBUG) DoDebug("GetAttackRoll: End Section #6");
    return iReturn;
}

//:://////////////////////////////////////////////
//::  Damage Bonus Functions
//:://////////////////////////////////////////////

int GetFavoredEnemyFeat(int iRacialType)
{
    switch(iRacialType)
    {
        case RACIAL_TYPE_DWARF:                 return FEAT_FAVORED_ENEMY_DWARF;
        case RACIAL_TYPE_ELF:                   return FEAT_FAVORED_ENEMY_ELF;
        case RACIAL_TYPE_GNOME:                 return FEAT_FAVORED_ENEMY_GNOME;
        case RACIAL_TYPE_HALFLING:              return FEAT_FAVORED_ENEMY_HALFLING;
        case RACIAL_TYPE_HALFELF:               return FEAT_FAVORED_ENEMY_HALFELF;
        case RACIAL_TYPE_HALFORC:               return FEAT_FAVORED_ENEMY_HALFORC;
        case RACIAL_TYPE_HUMAN:                 return FEAT_FAVORED_ENEMY_HUMAN;
        case RACIAL_TYPE_ABERRATION:            return FEAT_FAVORED_ENEMY_ABERRATION;
        case RACIAL_TYPE_ANIMAL:                return FEAT_FAVORED_ENEMY_ANIMAL;
        case RACIAL_TYPE_BEAST:                 return FEAT_FAVORED_ENEMY_BEAST;
        case RACIAL_TYPE_CONSTRUCT:             return FEAT_FAVORED_ENEMY_CONSTRUCT;
        case RACIAL_TYPE_DRAGON:                return FEAT_FAVORED_ENEMY_DRAGON;
        case RACIAL_TYPE_HUMANOID_GOBLINOID:    return FEAT_FAVORED_ENEMY_GOBLINOID;
        case RACIAL_TYPE_HUMANOID_MONSTROUS:    return FEAT_FAVORED_ENEMY_MONSTROUS;
        case RACIAL_TYPE_HUMANOID_ORC:          return FEAT_FAVORED_ENEMY_ORC;
        case RACIAL_TYPE_HUMANOID_REPTILIAN:    return FEAT_FAVORED_ENEMY_REPTILIAN;
        case RACIAL_TYPE_ELEMENTAL:             return FEAT_FAVORED_ENEMY_ELEMENTAL;
        case RACIAL_TYPE_FEY:                   return FEAT_FAVORED_ENEMY_FEY;
        case RACIAL_TYPE_GIANT:                 return FEAT_FAVORED_ENEMY_GIANT;
        case RACIAL_TYPE_MAGICAL_BEAST:         return FEAT_FAVORED_ENEMY_MAGICAL_BEAST;
        case RACIAL_TYPE_OUTSIDER:              return FEAT_FAVORED_ENEMY_OUTSIDER;
        case RACIAL_TYPE_SHAPECHANGER:          return FEAT_FAVORED_ENEMY_SHAPECHANGER;
        case RACIAL_TYPE_UNDEAD:                return FEAT_FAVORED_ENEMY_UNDEAD;
        case RACIAL_TYPE_VERMIN:                return FEAT_FAVORED_ENEMY_VERMIN;
		case RACIAL_TYPE_PLANT:					return FEAT_FAVORED_ENEMY_PLANT;
		case RACIAL_TYPE_OOZE:					return FEAT_FAVORED_ENEMY_OOZE;
    }
    return -1;
}

int GetFavoredEnemyLevel(object oAttacker)
{
    return  (GetLevelByClass(CLASS_TYPE_HARPER, oAttacker)
            + GetLevelByClass(CLASS_TYPE_RANGER, oAttacker)
            + GetLevelByClass(CLASS_TYPE_ULTIMATE_RANGER, oAttacker)   // motu99: added ultimate ranger. might have to add more
            // Additional PRC's
            // + GetLevelByClass(CLASS_TYPE_*, oAttacker)
            );
}

int GetFavoredEnemyDamageBonus(object oDefender, object oAttacker)
{
    int iRangerLevel = GetFavoredEnemyLevel(oAttacker);

    // Exit if the class can not have a favored enemy
    // Prevents lots of useless code from running
    if(!iRangerLevel)
        return 0;

    int iDamageBonus = 0;

//     float fDistance = GetDistanceBetween(oAttacker, oDefender);
//     if(fDistance <= FeetToMeters(30.0f) )  // motu99: Do you have to be within 30 feet to gain favorite enemy boni?
//  {
        int iRacialType = MyPRCGetRacialType(oDefender);
        if(GetHasFeat(GetFavoredEnemyFeat(iRacialType), oAttacker))
        {
            iDamageBonus = (iRangerLevel / 5) + 1;
            // add in 2d6 damage for bane of enemies
            if(GetHasFeat(FEAT_EPIC_BANE_OF_ENEMIES, oAttacker))
                iDamageBonus += d6(2);
        }
//  }

    return iDamageBonus;
}

int GetMightyWeaponBonus(object oWeap)
{
     int iMighty = 0;
     int iTemp = 0;
     itemproperty ip = GetFirstItemProperty(oWeap);
     while(GetIsItemPropertyValid(ip))
     {
          if(GetItemPropertyType(ip) == ITEM_PROPERTY_MIGHTY)
               iTemp = GetItemPropertyCostTableValue(ip);

          if(iTemp > iMighty) iMighty = iTemp;

          ip = GetNextItemProperty(oWeap);
     }
     return iMighty;
}

int GetWeaponEnhancement(object oWeapon, object oDefender, object oAttacker)
{
// this function determines the maximum enhancement bonus from the weapon and subtracts the maximum penalty
    int iEnhancement = 0;
    int iPenalty = 0;
    int iTemp;

    int iRace = MyPRCGetRacialType(oDefender);

    int iGoodEvil = GetAlignmentGoodEvil(oDefender);
    int iLawChaos = GetAlignmentLawChaos(oDefender);
    int iAlignSp  = GetItemPropAlignment(iGoodEvil,iLawChaos);
    int iAlignGr;

    itemproperty ip = GetFirstItemProperty(oWeapon);
    while(GetIsItemPropertyValid(ip))
    {
        iTemp = 0;
        int iItemPropType = GetItemPropertyType(ip);
        switch(iItemPropType)
        {
            case ITEM_PROPERTY_ENHANCEMENT_BONUS:
                iTemp = GetItemPropertyCostTableValue(ip); // motu99: was iTemp = GetDamageByConstant(GetItemPropertyCostTableValue(ip), TRUE); but this returned wrong values
                break;

            case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT:
                if(GetItemPropertySubType(ip) == iAlignSp) iTemp = GetItemPropertyCostTableValue(ip);
                break;

            case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP:
                iAlignGr = GetItemPropertySubType(ip);
                if (iAlignGr == ALIGNMENT_NEUTRAL)
                {
                    if (iAlignGr == iLawChaos)  iTemp = GetItemPropertyCostTableValue(ip); // motu99: was iTemp = GetDamageByConstant(GetItemPropertyCostTableValue(ip), TRUE);  but that seemed as wrong as ITEM_PROPERTY_ENHANCEMENT_BONUS
                }
                else if (iAlignGr == iGoodEvil || iAlignGr == iLawChaos || iAlignGr == IP_CONST_ALIGNMENTGROUP_ALL)
                    iTemp = GetItemPropertyCostTableValue(ip); // motu99: was iTemp = GetDamageByConstant(GetItemPropertyCostTableValue(ip), TRUE);  but that seemed as wrong as ITEM_PROPERTY_ENHANCEMENT_BONUS
                break;

            case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP:
                if(GetItemPropertySubType(ip) == iRace) iTemp = GetItemPropertyCostTableValue(ip);
                break;

            // detects holy avenger property and adds proper enhancement bonus
            case ITEM_PROPERTY_HOLY_AVENGER:
                iTemp = 5;
                break;

            case ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER:
                iTemp = -GetItemPropertyCostTableValue(ip); // motu99: was iTemp = -GetDamageByConstant(GetItemPropertyCostTableValue(ip), TRUE);  but that seemed as wrong as ITEM_PROPERTY_ENHANCEMENT_BONUS
                break;

        }

        if(iTemp > 0)
        {
            if (iTemp > iEnhancement) iEnhancement = iTemp;
        }
        else
        {
            if(iTemp < iPenalty)   iPenalty = iTemp;
        }

        ip = GetNextItemProperty(oWeapon);
    }

    iEnhancement -= iPenalty;

    //if ranged check for ammo
    if(GetWeaponRanged(oWeapon) )
    {
        // Adds ammo bonus if it is higher than weapon bonus
        int iAmmoEnhancement = GetAmmunitionEnhancement(oWeapon, oDefender, oAttacker);
        if(iAmmoEnhancement > iEnhancement) iEnhancement = iAmmoEnhancement;

        // Arcane Archer Enchant Arrow Bonus
        int iAALevel = GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oAttacker);
        int iAAEnchantArrow = 0;

        if(iAALevel > 0) iAAEnchantArrow = ((iAALevel + 1) / 2);
        if(iAAEnchantArrow > iEnhancement) iEnhancement = iAAEnchantArrow;
    }

    return iEnhancement;
}

int GetMonkEnhancement(object oWeapon, object oDefender, object oAttacker)
{
    int iMonkEnhancement = GetWeaponEnhancement(oWeapon, oDefender, oAttacker);
    int iTemp;

    // returns enhancement bonus for ki strike
    if(GetIsNaturalWeapon(oWeapon))
    {
        if(GetHasFeat(FEAT_EPIC_IMPROVED_KI_STRIKE_5, oAttacker)) iTemp = 5;
        else if(GetHasFeat(FEAT_EPIC_IMPROVED_KI_STRIKE_4, oAttacker)) iTemp = 4;
        else if(GetHasFeat(FEAT_KI_STRIKE, oAttacker) )
        {
            int iMonkLevel = GetLevelByClass(CLASS_TYPE_MONK, oAttacker);
            iTemp = 1;
            if(iMonkLevel > 12) iTemp = 2;
            if(iMonkLevel > 15) iTemp = 3;
        }
        if(iTemp > iMonkEnhancement) iMonkEnhancement = iTemp;
    }

    return iMonkEnhancement;
}

int GetDamagePowerConstant(object oWeapon, object oDefender, object oAttacker)
{
// motu99: call to GetMonkEnhancement is executed several times; first for attack bonus, then for enhancement, now for damage power
// better store the iEnhancement value (from attack bonus calculation) and use it later to determine damage
    int iDamagePower = GetMonkEnhancement(oWeapon, oDefender, oAttacker);

    // Determine Damage Power (Enhancement Bonus of Weapon)
    // Damage Power 6 is Magical and hits everything
    // So for +6 and higher are actually 7-21, so add +1
    if(iDamagePower > 5) iDamagePower += 1;
    if(iDamagePower < 0 ) iDamagePower = 0;
    
    //if (DEBUG) DoDebug("prc_inc_combat DamagePowerConstant "+IntToString(iDamagePower));

    return iDamagePower;
}

// motu99: Didn't check this
int GetAmmunitionEnhancement(object oWeapon, object oDefender, object oAttacker)
{
    int iTemp;
    int iBonus, iDamageType;
    int iType = GetBaseItemType(oWeapon);


    int iRace = MyPRCGetRacialType(oDefender);

    int iGoodEvil = GetAlignmentGoodEvil(oDefender);
    int iLawChaos = GetAlignmentLawChaos(oDefender);
    int iAlignSp  = GetItemPropAlignment(iGoodEvil, iLawChaos);
    int iAlignGr;

    object oAmmu = GetAmmunitionFromWeapon(oWeapon, oAttacker);
    int iBase = GetBaseItemType(oAmmu);

    //Get Damage Bonus Properties from oWeapon
    itemproperty ip = GetFirstItemProperty(oWeapon);
    while(GetIsItemPropertyValid(ip))
    {
          int iCostVal = GetItemPropertyCostTableValue(ip);
          int iPropType = GetItemPropertyType(ip);
          if(iPropType == ITEM_PROPERTY_DAMAGE_BONUS)
          {
               iDamageType = GetItemPropertyParam1Value(ip);

               if( (iBase == BASE_ITEM_BOLT || iBase == BASE_ITEM_ARROW) && iDamageType == IP_CONST_DAMAGETYPE_PIERCING )
               {
                    iTemp = GetDamageByConstant(iCostVal, TRUE);
                    iBonus = iTemp> iBonus ? iTemp:iBonus ;
               }
                    else if ( iBase == BASE_ITEM_BULLET && iDamageType == IP_CONST_DAMAGETYPE_BLUDGEONING )
               {
                    iTemp = GetDamageByConstant(iCostVal, TRUE);
                    iBonus = iTemp> iBonus ? iTemp:iBonus ;
               }
          }
          if(iPropType == ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP)
          {
               iAlignGr = GetItemPropertySubType(ip);
               iDamageType = GetItemPropertyParam1Value(ip);

               int bIsAttackingAlignment = FALSE;

               if (iAlignGr == ALIGNMENT_NEUTRAL)
               {
                    if (iAlignGr == iLawChaos)  bIsAttackingAlignment = TRUE;
               }
               else if (iAlignGr == iGoodEvil || iAlignGr == iLawChaos || iAlignGr == IP_CONST_ALIGNMENTGROUP_ALL)
                    bIsAttackingAlignment = FALSE;

               if(bIsAttackingAlignment)
               {
                    if ( (iBase == BASE_ITEM_BOLT || iBase == BASE_ITEM_ARROW) && iDamageType == IP_CONST_DAMAGETYPE_PIERCING )
                    {
                         iTemp = GetDamageByConstant(iCostVal, TRUE);
                         iBonus = iTemp> iBonus ? iTemp:iBonus ;
                    }
                         else if ( iBase == BASE_ITEM_BULLET && iDamageType == IP_CONST_DAMAGETYPE_BLUDGEONING )
                    {
                         iTemp = GetDamageByConstant(iCostVal, TRUE);
                         iBonus = iTemp> iBonus ? iTemp:iBonus ;
                    }
               }
          }
          if(iPropType == ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT)
          {
               if(GetItemPropertySubType(ip) == iAlignSp) iTemp = GetItemPropertyCostTableValue(ip);
               else                                       iTemp = 0;

               iDamageType = GetItemPropertyParam1Value(ip);

               if ( (iBase == BASE_ITEM_BOLT || iBase == BASE_ITEM_ARROW) && iDamageType == IP_CONST_DAMAGETYPE_PIERCING )
               {
                    iTemp = GetDamageByConstant(iCostVal, TRUE);
                    iBonus = iTemp> iBonus ? iTemp:iBonus ;
               }
                    else if ( iBase == BASE_ITEM_BULLET && iDamageType == IP_CONST_DAMAGETYPE_BLUDGEONING )
               {
                    iTemp = GetDamageByConstant(iCostVal, TRUE);
                    iBonus = iTemp> iBonus ? iTemp:iBonus ;
               }
          }
          if(iPropType == ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP)
          {
               if(GetItemPropertySubType(ip) == iRace) iTemp = GetItemPropertyCostTableValue(ip);
               else                                    iTemp = 0;                                      iTemp = 0;

               iDamageType = GetItemPropertyParam1Value(ip);

               if ( (iBase == BASE_ITEM_BOLT || iBase == BASE_ITEM_ARROW) && iDamageType == IP_CONST_DAMAGETYPE_PIERCING )
               {
                    iTemp = GetDamageByConstant(iCostVal, TRUE);
                    iBonus = iTemp> iBonus ? iTemp:iBonus ;
               }
                    else if ( iBase == BASE_ITEM_BULLET && iDamageType == IP_CONST_DAMAGETYPE_BLUDGEONING )
               {
                    iTemp = GetDamageByConstant(iCostVal, TRUE);
                    iBonus = iTemp> iBonus ? iTemp:iBonus ;
               }
          }
          ip = GetNextItemProperty(oWeapon);
     }
     return iBonus;
}

int GetDamageByConstant(int iDamageConst, int iItemProp)
{
    if(iItemProp)
    {
        switch(iDamageConst)
        {
            case IP_CONST_DAMAGEBONUS_1:
                return 1;
            case IP_CONST_DAMAGEBONUS_2:
                return 2;
            case IP_CONST_DAMAGEBONUS_3:
                return 3;
            case IP_CONST_DAMAGEBONUS_4:
                return 4;
            case IP_CONST_DAMAGEBONUS_5:
                return 5;
            case IP_CONST_DAMAGEBONUS_6:
                return 6;
            case IP_CONST_DAMAGEBONUS_7:
                return 7;
            case IP_CONST_DAMAGEBONUS_8:
                return 8;
            case IP_CONST_DAMAGEBONUS_9:
                return 9;
            case IP_CONST_DAMAGEBONUS_10:
                return 10;
            case IP_CONST_DAMAGEBONUS_11:
                return 11;
            case IP_CONST_DAMAGEBONUS_12:
                return 12;
            case IP_CONST_DAMAGEBONUS_13:
                return 13;
            case IP_CONST_DAMAGEBONUS_14:
                return 14;
            case IP_CONST_DAMAGEBONUS_15:
                return 15;
            case IP_CONST_DAMAGEBONUS_16:
                return 16;
            case IP_CONST_DAMAGEBONUS_17:
                return 17;
            case IP_CONST_DAMAGEBONUS_18:
                return 18;
            case IP_CONST_DAMAGEBONUS_19:
                return 19;
            case IP_CONST_DAMAGEBONUS_20:
                return 20;
            case IP_CONST_DAMAGEBONUS_1d4:
                return d4(1);
            case IP_CONST_DAMAGEBONUS_1d6:
                return d6(1);
            case IP_CONST_DAMAGEBONUS_1d8:
                return d8(1);
            case IP_CONST_DAMAGEBONUS_1d10:
                return d10(1);
            case IP_CONST_DAMAGEBONUS_1d12:
                return d12(1);
            case IP_CONST_DAMAGEBONUS_2d4:
                return d4(2);
            case IP_CONST_DAMAGEBONUS_2d6:
                return d6(2);
            case IP_CONST_DAMAGEBONUS_2d8:
                return d8(2);
            case IP_CONST_DAMAGEBONUS_2d10:
                return d10(2);
            case IP_CONST_DAMAGEBONUS_2d12:
                return d12(2);
            case IP_CONST_DAMAGEBONUS_3d4:
                return d4(3);
            case IP_CONST_DAMAGEBONUS_4d4:
                return d4(4);
            case IP_CONST_DAMAGEBONUS_5d4:
                return d4(5);
            case IP_CONST_DAMAGEBONUS_6d4:
                return d4(6);
            case IP_CONST_DAMAGEBONUS_7d4:
                return d4(7);
            case IP_CONST_DAMAGEBONUS_8d4:
                return d4(8);
            case IP_CONST_DAMAGEBONUS_9d4:
                return d4(9);
            case IP_CONST_DAMAGEBONUS_10d4:
                return d4(10);
            case IP_CONST_DAMAGEBONUS_3d6:
                return d6(3);
            case IP_CONST_DAMAGEBONUS_4d6:
                return d6(4);
            case IP_CONST_DAMAGEBONUS_5d6:
                return d6(5);
            case IP_CONST_DAMAGEBONUS_6d6:
                return d6(6);
            case IP_CONST_DAMAGEBONUS_7d6:
                return d6(7);
            case IP_CONST_DAMAGEBONUS_8d6:
                return d6(8);
            case IP_CONST_DAMAGEBONUS_9d6:
                return d6(9);
            case IP_CONST_DAMAGEBONUS_10d6:
                return d6(10);
            case IP_CONST_DAMAGEBONUS_3d8:
                return d8(3);
            case IP_CONST_DAMAGEBONUS_4d8:
                return d8(4);
            case IP_CONST_DAMAGEBONUS_5d8:
                return d8(5);
            case IP_CONST_DAMAGEBONUS_6d8:
                return d8(6);
            case IP_CONST_DAMAGEBONUS_7d8:
                return d8(7);
            case IP_CONST_DAMAGEBONUS_8d8:
                return d8(8);
            case IP_CONST_DAMAGEBONUS_9d8:
                return d8(9);
            case IP_CONST_DAMAGEBONUS_10d8:
                return d8(10);
            case IP_CONST_DAMAGEBONUS_3d10:
                return d10(3);
            case IP_CONST_DAMAGEBONUS_4d10:
                return d10(4);
            case IP_CONST_DAMAGEBONUS_5d10:
                return d10(5);
            case IP_CONST_DAMAGEBONUS_6d10:
                return d10(6);
            case IP_CONST_DAMAGEBONUS_7d10:
                return d10(7);
            case IP_CONST_DAMAGEBONUS_8d10:
                return d10(8);
            case IP_CONST_DAMAGEBONUS_9d10:
                return d10(9);
            case IP_CONST_DAMAGEBONUS_10d10:
                return d10(10);
            case IP_CONST_DAMAGEBONUS_3d12:
                return d12(3);
            case IP_CONST_DAMAGEBONUS_4d12:
                return d12(4);
            case IP_CONST_DAMAGEBONUS_5d12:
                return d12(5);
            case IP_CONST_DAMAGEBONUS_6d12:
                return d12(6);
            case IP_CONST_DAMAGEBONUS_7d12:
                return d12(7);
            case IP_CONST_DAMAGEBONUS_8d12:
                return d12(8);
            case IP_CONST_DAMAGEBONUS_9d12:
                return d12(9);
            case IP_CONST_DAMAGEBONUS_10d12:
                return d12(10);
            case IP_CONST_DAMAGEBONUS_1d3:
                return d3(1);
            case IP_CONST_DAMAGEBONUS_4d3:
                return d3(4);
            case IP_CONST_DAMAGEBONUS_21:
                return 21;
            case IP_CONST_DAMAGEBONUS_22:
                return 22;
            case IP_CONST_DAMAGEBONUS_23:
                return 23;
            case IP_CONST_DAMAGEBONUS_24:
                return 24;
            case IP_CONST_DAMAGEBONUS_25:
                return 25;
            case IP_CONST_DAMAGEBONUS_26:
                return 26;
            case IP_CONST_DAMAGEBONUS_27:
                return 27;
            case IP_CONST_DAMAGEBONUS_28:
                return 28;
            case IP_CONST_DAMAGEBONUS_29:
                return 29;
            case IP_CONST_DAMAGEBONUS_30:
                return 30;	
			case IP_CONST_DAMAGEBONUS_31:
                return 31;
            case IP_CONST_DAMAGEBONUS_32:
                return 32;
            case IP_CONST_DAMAGEBONUS_33:
                return 33;
            case IP_CONST_DAMAGEBONUS_34:
                return 34;
            case IP_CONST_DAMAGEBONUS_35:
                return 35;
            case IP_CONST_DAMAGEBONUS_36:
                return 36;
            case IP_CONST_DAMAGEBONUS_37:
                return 37;
            case IP_CONST_DAMAGEBONUS_38:
                return 38;
            case IP_CONST_DAMAGEBONUS_39:
                return 39;
            case IP_CONST_DAMAGEBONUS_40:
                return 40;
            case IP_CONST_DAMAGEBONUS_41:
                return 41;
            case IP_CONST_DAMAGEBONUS_42:
                return 42;
            case IP_CONST_DAMAGEBONUS_43:
                return 43;
            case IP_CONST_DAMAGEBONUS_44:
                return 44;
            case IP_CONST_DAMAGEBONUS_45:
                return 45;
            case IP_CONST_DAMAGEBONUS_46:
                return 46;
            case IP_CONST_DAMAGEBONUS_47:
                return 47;
            case IP_CONST_DAMAGEBONUS_48:
                return 48;
            case IP_CONST_DAMAGEBONUS_49:
                return 49;
            case IP_CONST_DAMAGEBONUS_50:
                return 50;				
				
        }
    }
    else
    {
        switch(iDamageConst)
        {
            case DAMAGE_BONUS_1:
                return 1;
            case DAMAGE_BONUS_2:
                return 2;
            case DAMAGE_BONUS_3:
                return 3;
            case DAMAGE_BONUS_4:
                return 4;
            case DAMAGE_BONUS_5:
                return 5;
            case DAMAGE_BONUS_6:
                return 6;
            case DAMAGE_BONUS_7:
                return 7;
            case DAMAGE_BONUS_8:
                return 8;
            case DAMAGE_BONUS_9:
                return 9;
            case DAMAGE_BONUS_10:
                return 10;
            case DAMAGE_BONUS_11:
                return 11;  // motu99: The following up to DAMAGE_BONUS_20 all returned 10; doesn't seem right, changed it
            case DAMAGE_BONUS_12:
                return 12;
            case DAMAGE_BONUS_13:
                return 13;
            case DAMAGE_BONUS_14:
                return 14;
            case DAMAGE_BONUS_15:
                return 15;
            case DAMAGE_BONUS_16:
                return 16;
            case DAMAGE_BONUS_17:
                return 17;
            case DAMAGE_BONUS_18:
                return 18;
            case DAMAGE_BONUS_19:
                return 19;
            case DAMAGE_BONUS_20:
                return 20;
            case DAMAGE_BONUS_1d4:
                return d4(1);
            case DAMAGE_BONUS_1d6:
                return d6(1);
            case DAMAGE_BONUS_1d8:
                return d8(1);
            case DAMAGE_BONUS_1d10:
                return d10(1);
            case DAMAGE_BONUS_1d12:
                return d12(1);
            case DAMAGE_BONUS_2d4:
                return d4(2);
            case DAMAGE_BONUS_2d6:
                return d6(2);
            case DAMAGE_BONUS_2d8:
                return d8(2);
            case DAMAGE_BONUS_2d10:
                return d10(2);
            case DAMAGE_BONUS_2d12:
                return d12(2);
            case DAMAGE_BONUS_21:
                return 21;
            case DAMAGE_BONUS_22:
                return 22;
            case DAMAGE_BONUS_23:
                return 23;
            case DAMAGE_BONUS_24:
                return 24;
            case DAMAGE_BONUS_25:
                return 25;
            case DAMAGE_BONUS_26:
                return 26;
            case DAMAGE_BONUS_27:
                return 27;
            case DAMAGE_BONUS_28:
                return 28;
            case DAMAGE_BONUS_29:
                return 29;
            case DAMAGE_BONUS_30:
                return 30;				
            case DAMAGE_BONUS_31:
                return 31;
            case DAMAGE_BONUS_32:
                return 32;
            case DAMAGE_BONUS_33:
                return 33;
            case DAMAGE_BONUS_34:
                return 34;
            case DAMAGE_BONUS_35:
                return 35;
            case DAMAGE_BONUS_36:
                return 36;
            case DAMAGE_BONUS_37:
                return 37;
            case DAMAGE_BONUS_38:
                return 38;
            case DAMAGE_BONUS_39:
                return 39;
            case DAMAGE_BONUS_40:
                return 40;		
			case DAMAGE_BONUS_41:
                return 41;
            case DAMAGE_BONUS_42:
                return 42;
            case DAMAGE_BONUS_43:
                return 43;
            case DAMAGE_BONUS_44:
                return 44;
            case DAMAGE_BONUS_45:
                return 45;
            case DAMAGE_BONUS_46:
                return 46;
            case DAMAGE_BONUS_47:
                return 47;
            case DAMAGE_BONUS_48:
                return 48;
            case DAMAGE_BONUS_49:
                return 49;
            case DAMAGE_BONUS_50:
                return 50;
        }
    }
    return 0;
}

int GetDiceMaxRoll(int iDamageConst)
// Gets the maximum roll of the dice; zero if no dice constant
{
    switch(iDamageConst)
    {
        case IP_CONST_DAMAGEBONUS_1d4:
            return 4;
        case IP_CONST_DAMAGEBONUS_1d6:
            return 6;
        case IP_CONST_DAMAGEBONUS_1d8:
            return 8;
        case IP_CONST_DAMAGEBONUS_1d10:
            return 10;
        case IP_CONST_DAMAGEBONUS_1d12:
            return 12;
        case IP_CONST_DAMAGEBONUS_2d4:
            return 8;
        case IP_CONST_DAMAGEBONUS_2d6:
            return 12;
        case IP_CONST_DAMAGEBONUS_2d8:
            return 16;
        case IP_CONST_DAMAGEBONUS_2d10:
            return 20;
        case IP_CONST_DAMAGEBONUS_2d12:
            return 24;
    }
    return 0;
}

// all of the ten ip dice constants are supposed to lie between 6 and 15
int GetIsDiceConstant(int iDice)
{
    return (iDice > 5 && iDice < 16);
}


// motu99: quite expensive: Passing the whole struct, filling in one single value, passing it out again
// practically disabled this function by pasting its code directly into GetWeaponBonusDamage()
struct BonusDamage GetItemPropertyDamageConstant(int iDamageType, int iDice, struct BonusDamage weapBonusDam)
{
    switch(iDamageType)
    {
        case -1:
            break;

        case IP_CONST_DAMAGETYPE_ACID:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Acid) weapBonusDam.dice_Acid = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Acid) weapBonusDam.dam_Acid = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_COLD:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Cold) weapBonusDam.dice_Cold = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Cold) weapBonusDam.dam_Cold = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_FIRE:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Fire) weapBonusDam.dice_Fire = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Fire) weapBonusDam.dam_Fire = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_ELECTRICAL:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Elec) weapBonusDam.dice_Elec = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Elec) weapBonusDam.dam_Elec = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_SONIC:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Son) weapBonusDam.dice_Son = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Son) weapBonusDam.dam_Son = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_DIVINE:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Div) weapBonusDam.dice_Div = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Div) weapBonusDam.dam_Div = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_NEGATIVE:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Neg) weapBonusDam.dice_Neg = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Neg) weapBonusDam.dam_Neg = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_POSITIVE:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Pos) weapBonusDam.dice_Pos = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Pos) weapBonusDam.dam_Pos = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_MAGICAL:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Mag) weapBonusDam.dice_Mag = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Mag) weapBonusDam.dam_Mag = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_BLUDGEONING:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Blud) weapBonusDam.dice_Blud = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Blud) weapBonusDam.dam_Blud = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_PIERCING:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Pier) weapBonusDam.dice_Pier = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Pier) weapBonusDam.dam_Pier = iDice;
            }
            break;

        case IP_CONST_DAMAGETYPE_SLASHING:
            if(GetIsDiceConstant(iDice)) // is a dice constant
            {
                if(iDice > weapBonusDam.dice_Slash) weapBonusDam.dice_Slash = iDice;
            }
            else // is +1 to +20
            {
                if(iDice > weapBonusDam.dam_Slash) weapBonusDam.dam_Slash = iDice;
            }
            break;
    }

    return weapBonusDam;
}



// motu99: generally it does not make too much sense to precalculate the WeaponDamage on the beginning of the round and store the various damage types in a large struct
// the reason is that the calculation is quite cheap on CPU time (weapons don't have many item properties to loop through)
// so that passing the large struct back and forth between AttackLoopLogic() and AttackLoopMain() takes more time than the calculation itself

// @TODO: change logic of AttackLoopLogic() such, that we calculate the damage directly in GetDamage() when we hit!
// then we need not store the dice constants, but rather do the rolls directly, merely summing up the real damage
// for the various damage types in one single struct (with half the members than here)
// also note, that some damage depends on the enemy (alignment, race etc.), so it can change during one round
struct BonusDamage GetWeaponBonusDamage(object oWeapon, object oTarget)
{
    struct BonusDamage weapBonusDam;  // lets hope that everything is initialized to zero

    int iDamageType;
    int iDice;
    int iDamage;
    int iDamageDarkfire=0;
    int iDamageFlameWeapon=0;

    int iRace = MyPRCGetRacialType(oTarget);

    int iGoodEvil = GetAlignmentGoodEvil(oTarget);
    int iLawChaos = GetAlignmentLawChaos(oTarget);
    int iAlignSp  = GetItemPropAlignment(iGoodEvil,iLawChaos);
    int iAlignGr;

    int iSpellType;

    itemproperty ip = GetFirstItemProperty(oWeapon);
    while(GetIsItemPropertyValid(ip))
    {
        iDamageType = -1;  // always reset damage type to -1 (no damage)
        int ipType = GetItemPropertyType(ip);
// DoDebug("GetWeaponBonusDamage() found " + DebugIProp2Str(ip));
        switch(ipType)
        {
            // normal damage
            case ITEM_PROPERTY_DAMAGE_BONUS:
                iDice = GetItemPropertyCostTableValue(ip);
                iDamageType = GetItemPropertySubType(ip);
                break;

            // Checks weapon for Holy Avenger property
            case ITEM_PROPERTY_HOLY_AVENGER:
                iAlignGr = GetItemPropertySubType(ip);
                if (iAlignGr == ALIGNMENT_EVIL)
                {
                    iDamageType = IP_CONST_DAMAGETYPE_DIVINE;
                    iDice = IP_CONST_DAMAGEBONUS_1d6;
                }
                break;

            case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP:
                iAlignGr = GetItemPropertySubType(ip);
                iDice = GetItemPropertyCostTableValue(ip);
                if (iAlignGr == ALIGNMENT_NEUTRAL)
                {
                    if (iAlignGr == iLawChaos)  iDamageType = GetItemPropertyParam1Value(ip);
                }
                else if (iAlignGr == iGoodEvil || iAlignGr == iLawChaos || iAlignGr == IP_CONST_ALIGNMENTGROUP_ALL)
                {
                    iDamageType = GetItemPropertyParam1Value(ip);
                }
                break;

            case ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP:
                if(GetItemPropertySubType(ip) == iRace)
                {
                    iDamageType = GetItemPropertyParam1Value(ip);
                    iDice = GetItemPropertyCostTableValue(ip);
                }
                break;

            case ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT:
                if(GetItemPropertySubType(ip) == iAlignSp)
                {
                    iDamageType = GetItemPropertyParam1Value(ip);
                    iDice = GetItemPropertyCostTableValue(ip);
                }
                break;

 /* motu99:  Apr 7, 2007: made onhitcastspell system work (at least for flame weapon and darkfire), so this is not needed here!

            case ITEM_PROPERTY_ONHITCASTSPELL:
                iSpellType = GetItemPropertySubType(ip);
                iDamage = GetItemPropertyCostTableValue(ip)+1; // spell level: always one to low
DoDebug("GetWeaponBonusDamage() found onhitcastspell with Spell type: " + IntToString(iSpellType) +" and spell level (ItemPropertyCostTableValue): " + IntToString(iDamage));
                switch(iSpellType)
                {
                    // dark fire 1d6 + X dmg.  X = CasterLevel/2
                    case IP_CONST_ONHIT_CASTSPELL_ONHIT_DARKFIRE:

                        // iDamageType = IP_CONST_DAMAGETYPE_FIRE;
                        // iDice = IP_CONST_DAMAGEBONUS_1d6;

                        iDamage /= 2;
                        if(iDamage > 10) iDamage = 10;

                        if(iDamage > iDamageDarkfire) iDamageDarkfire = iDamage;
                        break;

                    // flame blade 1d4 + X dmg.  X = CasterLevel/2; motu99: in Grimoire it says +1 per casterlevel
                    case IP_CONST_ONHIT_CASTSPELL_ONHIT_FIREDAMAGE:

                        // iDamageType = IP_CONST_DAMAGETYPE_FIRE;
                        // iDice = IP_CONST_DAMAGEBONUS_1d4;


//                      iDamage /= 2; // motu99: changed this, because it should be +1 per casterlevel according to Grimoire
                        if(iDamage > 10) iDamage = 10;

                        if(iDamage > iDamageFlameWeapon) iDamageFlameWeapon = iDamage;
                        break;
                }

*/ // motu99: end ONHITCASTSPELL (for Darkfire and Flame Weapon)

        }

        // weapBonusDam = GetItemPropertyDamageConstant(iDamageType, iDice, weapBonusDam); // motu99: don't need this any more, because we fill in the struct here

        // before we look for another itemproperty we fill in the the struct
        //to find the right struct subelement we check iDamageType; the amount of damage is found in iDice
        // for any damage of the same type, we take the maximum damage
        // fire damage from flame weapon and darkfire are treated in a special way at the end of the function.
        switch (iDamageType)
        {
            case -1:
                break;

            case IP_CONST_DAMAGETYPE_SLASHING:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Slash) weapBonusDam.dice_Slash = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Slash) weapBonusDam.dam_Slash = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_PIERCING:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Pier) weapBonusDam.dice_Pier = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Pier) weapBonusDam.dam_Pier = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_BLUDGEONING:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Blud) weapBonusDam.dice_Blud = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Blud) weapBonusDam.dam_Blud = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_FIRE:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Fire) weapBonusDam.dice_Fire = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Fire) weapBonusDam.dam_Fire = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_ELECTRICAL:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Elec) weapBonusDam.dice_Elec = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Elec) weapBonusDam.dam_Elec = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_COLD:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Cold) weapBonusDam.dice_Cold = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Cold) weapBonusDam.dam_Cold = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_ACID:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Acid) weapBonusDam.dice_Acid = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Acid) weapBonusDam.dam_Acid = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_SONIC:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Son) weapBonusDam.dice_Son = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Son) weapBonusDam.dam_Son = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_DIVINE:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Div) weapBonusDam.dice_Div = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Div) weapBonusDam.dam_Div = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_NEGATIVE:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Neg) weapBonusDam.dice_Neg = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Neg) weapBonusDam.dam_Neg = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_POSITIVE:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Pos) weapBonusDam.dice_Pos = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Pos) weapBonusDam.dam_Pos = iDice;
                }
                break;

            case IP_CONST_DAMAGETYPE_MAGICAL:
                if (GetIsDiceConstant(iDice)) // is a dice constant
                {
                    if(iDice > weapBonusDam.dice_Mag) weapBonusDam.dice_Mag = iDice;
                }
                else // is +1 to +20
                {
                    if(iDice > weapBonusDam.dam_Mag) weapBonusDam.dam_Mag = iDice;
                }
                break;

        }

        ip = GetNextItemProperty(oWeapon);
    }
    // we are through
    // now add flame weapon and darkfire damage
/*
// motu99: Not using this any more, rather using prc_onhitcast to do any onhitcast spells on the weapon
    int bStack = GetPRCSwitch(PRC_FLAMEWEAPON_DARKFIRE_STACK);

    if(bStack)
        iDamage = iDamageDarkfire + iDamageFlameWeapon;
    else
        // otherwise we take the maximum
        iDamage = PRCMax(iDamageDarkfire, iDamageFlameWeapon);
    if(iDamage)
    {
        // now either (if stacking) add the spell's fire damage to any other fire damage that is already on the weapon,
        // or take the maximum  of all fire damage types on the weapon(if not stacking)
        if(bStack)
            iDamage += GetDamageByConstant(weapBonusDam.dam_Fire, TRUE);
        else
            iDamage = PRCMax(GetDamageByConstant(weapBonusDam.dam_Fire, TRUE), iDamage);

        if(iDamage > 20) iDamage = 20; // make sure that the damage does not exceed 20
        // convert integer damage back to DamageBonusConstant
        iDamage = IPGetDamageBonusConstantFromNumber(iDamage);
        weapBonusDam.dam_Fire = iDamage;

        // check if there is already a dice constant for "normal" fire damage and find out the maximum dice roll
        iDice = GetDiceMaxRoll(weapBonusDam.dice_Fire);
        if(bStack)
        {   // calculate the maximum of all three dice rolls (flame weapon damage, darkfire damage, normal fire damage)
            if (iDamageDarkfire)    iDice += 6;
            if (iDamageFlameWeapon) iDice += 4;
            // now take the dice roll that is closest to the combined dice roll of all three
            if (iDice < 5) weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_1d4;
            else if (iDice < 7)     weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_1d6;
            else if (iDice < 9)     weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_2d4;
            else if (iDice < 11)    weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_1d10;
            else if (iDice < 13)    weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_2d6;
            else if (iDice < 17)    weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_2d8;
            else if (iDice < 21)    weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_2d10;
            else                    weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_2d12;
        }
        else
        {   // if the Darkfire d6 dice is highest, take that, otherwise if the flameweapon d4 dice is highest, take that
            if(iDamageDarkfire && iDice < 6)    weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_1d6;
            else if (iDamageFlameWeapon && iDice < 4) weapBonusDam.dice_Fire = IP_CONST_DAMAGEBONUS_1d4;
        }
    }
*/
    return weapBonusDam;
}

// finds any  ITEM_PROPERTY_MONSTER_DAMAGE on the weapon and returns the dice number and sides for this type of damage
// note that this returns the first such damage property. Won't work when there are several ITEM_PROPERTY_MONSTER_DAMAGE properties
// on the weapon (this should not happen, really)
struct Dice GetWeaponMonsterDamage(object oWeapon)
{
    struct Dice sDice;  // lets hope that everything is initialized to zero

    itemproperty ip = GetFirstItemProperty(oWeapon);
    while(GetIsItemPropertyValid(ip))
    {
        int ipType = GetItemPropertyType(ip);
        if (ipType == ITEM_PROPERTY_MONSTER_DAMAGE)
        {
// DoDebug("GetWeaponMonsterDamage() found " + DebugIProp2Str(ip));
            int iDamage = GetItemPropertyCostTableValue(ip);
            sDice.iSides = StringToInt(Get2DACache("iprp_monstcost", "Die", iDamage));
            sDice.iNum = StringToInt(Get2DACache("iprp_monstcost", "NumDice", iDamage));
            return sDice;
        }
        ip = GetNextItemProperty(oWeapon);
    }

    return sDice;
}

// contrary to GetWeaponBonusDamage this usually remains constant during the round (unless the spells happen to expire in that round, or are dispelled)
struct BonusDamage GetMagicalBonusDamage(object oAttacker, object oTarget)
{
// this searches for spell effects on the attacker that increase damage
// note that these stack, because they are from different spells (you shouldn't be able to cast a spell of the same type at you twice)
// contrary to GetWeaponBonusDamage this does not fill in the IP damage bonus constants, but directly fills in the damage
// @TODO: research if all damage affecting spells are covered; might also look if there is a better way to find out the caster level of the effect creator, in particular if we are casting from scrolls or runes
// note that this does not look for alignment or race specific effects. I think I recall that some spells increase damage only versus specific enemies
// @TODO: check for any such spells and add them to this function
//ebonfowl: this function has been updated to work automatically, it will now capture all damage effects, get their values and damage types, and add the appropriate bonus/decrement to the struct

    struct BonusDamage spellBonusDam;

    effect eEffect;
    int nDamage, eType, eSpellID, nEssentia, nBonus, nDamageType;
    string sTag;

    object oCaster;
    int nCharismaBonus, nLvl;

    eEffect = GetFirstEffect(oAttacker);
    while (GetIsEffectValid(eEffect) )
    {
        eType = GetEffectType(eEffect);
        sTag = GetEffectTag(eEffect);

        int iRace = MyPRCGetRacialType(oTarget);

        int iEffectRace = GetEffectInteger(eEffect, 2);

        int iGoodEvil = GetAlignmentGoodEvil(oTarget);
        int iLawChaos = GetAlignmentLawChaos(oTarget);

        int iEffectLawChaos = GetEffectInteger(eEffect, 3);
        int iEffectGoodEvil = GetEffectInteger(eEffect, 4);

        if (eType == EFFECT_TYPE_DAMAGE_INCREASE)
        {
            if(iEffectRace != 28)
            {
                if(iEffectRace == iRace)
                {
                    //Define racial type-based damage and load into struct
                    nBonus = GetEffectInteger(eEffect, 0);
                    nDamage = GetDamageByConstant(nBonus, FALSE);
                    nDamageType = GetEffectInteger(eEffect, 1);
                    switch(nDamageType)
                    {
                        case DAMAGE_TYPE_ACID:
                        spellBonusDam.dam_Acid += nDamage;
                        break;

                        case DAMAGE_TYPE_BASE_WEAPON:
                        spellBonusDam.dam_Slash += nDamage;
                        break;

                        case DAMAGE_TYPE_BLUDGEONING:
                        spellBonusDam.dam_Blud += nDamage;
                        break;

                        case DAMAGE_TYPE_COLD:
                        spellBonusDam.dam_Cold += nDamage;
                        break;

                        case DAMAGE_TYPE_DIVINE:
                        spellBonusDam.dam_Div += nDamage;
                        break;

                        case DAMAGE_TYPE_ELECTRICAL:
                        spellBonusDam.dam_Elec += nDamage;
                        break;

                        case DAMAGE_TYPE_FIRE:
                        spellBonusDam.dam_Fire += nDamage;
                        break;

                        case DAMAGE_TYPE_MAGICAL:
                        spellBonusDam.dam_Mag += nDamage;
                        break;

                        case DAMAGE_TYPE_NEGATIVE:
                        spellBonusDam.dam_Neg += nDamage;
                        break;

                        case DAMAGE_TYPE_PIERCING:
                        spellBonusDam.dam_Pier += nDamage;
                        break;

                        case DAMAGE_TYPE_POSITIVE:
                        spellBonusDam.dam_Pos += nDamage;
                        break;

                        case DAMAGE_TYPE_SLASHING:
                        spellBonusDam.dam_Slash += nDamage;
                        break;

                        case DAMAGE_TYPE_SONIC:
                        spellBonusDam.dam_Son += nDamage;
                        break;
                    }
                }
            }
            else if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
            {
                if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                {
                    //Define alignment-based damage and load into struct
                    nBonus = GetEffectInteger(eEffect, 0);
                    nDamage = GetDamageByConstant(nBonus, FALSE);
                    nDamageType = GetEffectInteger(eEffect, 1);
                    switch(nDamageType)
                    {
                        case DAMAGE_TYPE_ACID:
                        spellBonusDam.dam_Acid += nDamage;
                        break;

                        case DAMAGE_TYPE_BASE_WEAPON:
                        spellBonusDam.dam_Slash += nDamage;
                        break;

                        case DAMAGE_TYPE_BLUDGEONING:
                        spellBonusDam.dam_Blud += nDamage;
                        break;

                        case DAMAGE_TYPE_COLD:
                        spellBonusDam.dam_Cold += nDamage;
                        break;

                        case DAMAGE_TYPE_DIVINE:
                        spellBonusDam.dam_Div += nDamage;
                        break;

                        case DAMAGE_TYPE_ELECTRICAL:
                        spellBonusDam.dam_Elec += nDamage;
                        break;

                        case DAMAGE_TYPE_FIRE:
                        spellBonusDam.dam_Fire += nDamage;
                        break;

                        case DAMAGE_TYPE_MAGICAL:
                        spellBonusDam.dam_Mag += nDamage;
                        break;

                        case DAMAGE_TYPE_NEGATIVE:
                        spellBonusDam.dam_Neg += nDamage;
                        break;

                        case DAMAGE_TYPE_PIERCING:
                        spellBonusDam.dam_Pier += nDamage;
                        break;

                        case DAMAGE_TYPE_POSITIVE:
                        spellBonusDam.dam_Pos += nDamage;
                        break;

                        case DAMAGE_TYPE_SLASHING:
                        spellBonusDam.dam_Slash += nDamage;
                        break;

                        case DAMAGE_TYPE_SONIC:
                        spellBonusDam.dam_Son += nDamage;
                        break;
                    }
                }
            }
            else if(iEffectLawChaos == 0 && iEffectGoodEvil == 0 && iEffectRace == 28)
            {
                //Define generic damage and load into struct
                nBonus = GetEffectInteger(eEffect, 0);
                nDamage = GetDamageByConstant(nBonus, FALSE);
                nDamageType = GetEffectInteger(eEffect, 1);
                switch(nDamageType)
                {
                    case DAMAGE_TYPE_ACID:
                        spellBonusDam.dam_Acid += nDamage;
                        break;

                    case DAMAGE_TYPE_BASE_WEAPON:
                        spellBonusDam.dam_Slash += nDamage;
                        break;

                    case DAMAGE_TYPE_BLUDGEONING:
                        spellBonusDam.dam_Blud += nDamage;
                        break;

                    case DAMAGE_TYPE_COLD:
                        spellBonusDam.dam_Cold += nDamage;
                        break;

                    case DAMAGE_TYPE_DIVINE:
                        spellBonusDam.dam_Div += nDamage;
                        break;

                    case DAMAGE_TYPE_ELECTRICAL:
                        spellBonusDam.dam_Elec += nDamage;
                        break;

                    case DAMAGE_TYPE_FIRE:
                        spellBonusDam.dam_Fire += nDamage;
                        break;

                    case DAMAGE_TYPE_MAGICAL:
                        spellBonusDam.dam_Mag += nDamage;
                        break;

                    case DAMAGE_TYPE_NEGATIVE:
                        spellBonusDam.dam_Neg += nDamage;
                        break;

                    case DAMAGE_TYPE_PIERCING:
                        spellBonusDam.dam_Pier += nDamage;
                        break;

                    case DAMAGE_TYPE_POSITIVE:
                        spellBonusDam.dam_Pos += nDamage;
                        break;

                    case DAMAGE_TYPE_SLASHING:
                        spellBonusDam.dam_Slash += nDamage;
                        break;

                    case DAMAGE_TYPE_SONIC:
                        spellBonusDam.dam_Son += nDamage;
                        break;
                    }
            }
            
/* Remove this to re-enable the functions you commented out -ebonfowl
            eSpellID = GetEffectSpellId(eEffect);

            switch(eSpellID)
            {
                case SPELL_PRAYER:
                    spellBonusDam.dam_Slash += 1;
                    break;

                case SPELL_WAR_CRY:
                    spellBonusDam.dam_Slash += 2;
                    break;

                case SPELL_BATTLETIDE:
                    spellBonusDam.dam_Mag += 2;
                    break;

                // Bard Song
                case SPELL_BARD_SONG:
                    oCaster = GetEffectCreator(eEffect);
                    if(!GetIsObjectValid(oCaster)) // if we cannot find the caster, we assume the attacker was the caster
                        oCaster = oAttacker;
                    nDamage = 1;
                    if (GetIsObjectValid(oCaster))
                    {
                        int nLvl = GetLevelByClass(CLASS_TYPE_BARD, oCaster);
                        int iPerform = GetSkillRank(SKILL_PERFORM, oCaster);

                        if (nLvl>=BARD_LEVEL_FOR_BARD_SONG_DAM_3 && iPerform>= BARD_PERFORM_SKILL_FOR_BARD_SONG_DAM_3)
                            nDamage = 3;
                        else if (nLvl>= BARD_LEVEL_FOR_BARD_SONG_DAM_2 && iPerform>= BARD_PERFORM_SKILL_FOR_BARD_SONG_DAM_2)
                            nDamage = 2;
                    }
                    spellBonusDam.dam_Blud += nDamage;
                    break;

                case SPELL_DIVINE_MIGHT:
                    // divine damage
                    // find out the caster (should be the attacker, but beware of runes)
                    oCaster = GetEffectCreator(eEffect);
                    if(!GetIsObjectValid(oCaster)) // if we cannot find the caster, we assume the attacker was the caster
                        oCaster = oAttacker;

                    nDamage = 1 + GetHasFeat(FEAT_EPIC_DIVINE_MIGHT, oCaster);
                    nCharismaBonus = GetAbilityModifier(ABILITY_CHARISMA,oCaster) * nDamage;

                    if(nCharismaBonus > 1) nDamage = nCharismaBonus;
                    else                   nDamage = 1;

                    spellBonusDam.dam_Div += nDamage;
                    break;

                // Divine Wrath
                case SPELLABILITY_DC_DIVINE_WRATH:
                    //  magical damage
                    // here the caster must be the attacker (could not be cast on a rune)
                    oCaster = oAttacker;

                    nDamage = 3;
                    nLvl = GetLevelByClass(CLASS_TYPE_DIVINECHAMPION, oCaster);
                    nLvl = (nLvl / 5)-1;  // motu99: didn't check this

                    if (nLvl > 6)       nDamage = 15;
                    else if (nLvl > 5)  nDamage = 12;
                    else if (nLvl > 4)  nDamage = 10;
                    else if (nLvl > 3)  nDamage = 8;
                    else if (nLvl > 2)  nDamage = 6;
                    else if (nLvl > 1)  nDamage = 4;

                    spellBonusDam.dam_Mag += nDamage;
                    break;

                case SPELL_DIVINE_FAVOR:
                    //  divine
                    // find out the caster (should be the attacker, but beware of runes)
                    oCaster = GetEffectCreator(eEffect);
                    if(!GetIsObjectValid(oCaster)) // if we cannot find the caster, we assume the attacker was the caster
                        oCaster = oAttacker;

                    nDamage = 1;
                    if (GetIsObjectValid(oCaster))
                    {
                        nLvl = GetLevelByTypeDivine(oCaster); // GetLevelByClass(CLASS_TYPE_PALADIN, oAttacker) + GetLevelByClass(CLASS_TYPE_CLERIC, oAttacker);
                        nLvl /= 3;

                        if(nLvl > 4) nLvl = 4;
                    }
                    nDamage += nLvl;
                    spellBonusDam.dam_Div += nDamage;
                    break;

                // Power Shot
                case SPELL_PA_POWERSHOT:
                    spellBonusDam.dam_Pier += 5;
                    break;

                case SPELL_PA_IMP_POWERSHOT:
                    spellBonusDam.dam_Pier += 10;
                    break;

                case SPELL_PA_SUP_POWERSHOT:
                    spellBonusDam.dam_Pier += 15;
                    break;

                case MELD_BLUESTEEL_BRACERS:
                    nDamage = GetEssentiaInvested(oAttacker, MELD_BLUESTEEL_BRACERS);
                    spellBonusDam.dam_Mag += nDamage;
                    break;

                case MELD_LUCKY_DICE:
                    spellBonusDam.dam_Slash += 1;
                    break;

                case MELD_BLOODWAR_GAUNTLETS:
                    nDamage = GetEssentiaInvested(oAttacker, MELD_BLOODWAR_GAUNTLETS);
                    spellBonusDam.dam_Slash += nDamage;
                    break;

                case MELD_IRONSOUL_WEAPON:
                    nEssentia = GetEssentiaInvested(oAttacker, MELD_IRONSOUL_WEAPON);
                    nDamage = nEssentia*2;
                    spellBonusDam.dam_Blud += nDamage;
                    break;

                case MELD_INCANDESCENT_STRIKE:
                    nDamage = GetEssentiaInvested(oAttacker, MELD_INCANDESCENT_STRIKE);
                    spellBonusDam.dam_Slash += nDamage;
                    break;

                case MELD_INCARNUM_RADIANCE:
                    nLvl = GetLevelByClass(CLASS_TYPE_INCARNATE, oAttacker);
                    nBonus = 1 + nLvl/5;
                    nDamage = nBonus*2;
                    spellBonusDam.dam_Slash += nDamage;
                    break;

                case MELD_BLADEMELD_HANDS:
                    spellBonusDam.dam_Pos += 1;
                    break;
            }

            //General effect damage bonuses requiring tags go here
            //ebonfowl

            if(sTag == "LolthsMeatBonus")
            {
                spellBonusDam.dam_Div += 1;
            }
            else if(sTag == "RageClawsBonus")
            {
                spellBonusDam.dam_Slash += 2;
            }
            else if(sTag == "RidingBracersBonus")
            {
                spellBonusDam.dam_Slash += 2;
            }
            else if(sTag == "TotemAvatarBonus")
            {
                nEssentia = GetEssentiaInvested(oAttacker, MELD_TOTEM_AVATAR);
                nDamage = 0;
	            if (GetIsMeldBound(oAttacker, MELD_TOTEM_AVATAR) == CHAKRA_SHOULDERS) nDamage += 2;
                if (GetIsMeldBound(oAttacker, MELD_TOTEM_AVATAR) == CHAKRA_TOTEM) nDamage += nEssentia;
                spellBonusDam.dam_Slash += nDamage;
            }
            else if(sTag == "MaulingGauntletsBonus")
            {
                nEssentia = GetEssentiaInvested(oAttacker, MELD_MAULING_GAUNTLETS);
                nDamage = nEssentia*2;
                spellBonusDam.dam_Slash += nDamage;
            }
            
            //Now we are checking for damage bonuses versus specific racial types and adding those
            //Any damage bonus effect versus racial types should go here
            //If the effect can be identified by SpellID place it in the switch
            //Otherwise tag the effect in the relevant script and identify it below the switch in the conditional
            //ebonfowl
            
            int iRace = MyPRCGetRacialType(oTarget);

            int iEffectRace = GetEffectInteger(eEffect, 2);

            if(iEffectRace != 28)
            {
                if(iEffectRace == iRace)
                {
                    switch(eSpellID)
                    {
                        case MELD_NECROCARNUM_WEAPON:
                            nEssentia = GetEssentiaInvested(oAttacker, MELD_NECROCARNUM_WEAPON);
                            nDamage = FloatToInt(nEssentia*1.5);
                            spellBonusDam.dam_Neg += nDamage;
                            break;

                        case MELD_HEART_OF_FIRE:
                            nEssentia = GetEssentiaInvested(oAttacker, MELD_HEART_OF_FIRE);
                            nDamage = nEssentia;
                            spellBonusDam.dam_Slash += nDamage;
                            break;

                        case MELD_APPARITION_RIBBON:
                            nEssentia = GetEssentiaInvested(oAttacker, MELD_APPARITION_RIBBON);
                            nDamage = nEssentia*2;
                            spellBonusDam.dam_Slash += nDamage;
                            break;
                    }

                    //Conditional for tagged racial damage effects

                    if(sTag == "AzureEnmityBonus")
                    {
                        nEssentia = GetEssentiaInvestedFeat(oAttacker, FEAT_AZURE_ENMITY);
                        nDamage = nEssentia;
                        spellBonusDam.dam_Slash += nDamage;
                    }
                }
            }

            //Now we are checking for damage bonuses versus specific alignments and adding those
            //Any damage bonus effect versus alignments should go here
            //If the effect can be identified by SpellID place it in the switch
            //Otherwise tag the effect in the relevant script and identify it below the switch in the conditional
            //ebonfowl

            int iGoodEvil = GetAlignmentGoodEvil(oTarget);
            int iLawChaos = GetAlignmentLawChaos(oTarget);

            int iEffectLawChaos = GetEffectInteger(eEffect, 3);
            int iEffectGoodEvil = GetEffectInteger(eEffect, 4);

            //Single alignment effects here

            if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
            {
                if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                {
                    switch(eSpellID)
                    {
                        case MELD_BLADEMELD_SOUL:
                            nDamage = d6(1);
                            spellBonusDam.dam_Slash += nDamage;
                            break;

                        case MELD_OPEN_SOUL_CHAKRA:
                            spellBonusDam.dam_Pos += 2;
                            break;
                    }

                    //Conditional for tagged alignment damage effects
                }
            }

            //Effects that have the potential to double-dip on alignment go here


               /*
               // prevents power shot and power attack from stacking
               if(!GetHasFeatEffect(FEAT_PA_POWERSHOT, oAttacker) &&
                  !GetHasFeatEffect(FEAT_PA_IMP_POWERSHOT, oAttacker) &&
                  !GetHasFeatEffect(FEAT_PA_SUP_POWERSHOT, oAttacker) )
               {
                    switch(eSpellID)
                    {
                         case SPELL_POWER_ATTACK10:
                              spellBonusDam.dam_Slash += 10;
                              break;
                         case SPELL_POWER_ATTACK9:
                              spellBonusDam.dam_Slash += 9;
                              break;
                         case SPELL_POWER_ATTACK8:
                              spellBonusDam.dam_Slash += 8;
                              break;
                         case SPELL_POWER_ATTACK7:
                              spellBonusDam.dam_Slash += 7;
                              break;
                         case SPELL_POWER_ATTACK6:
                              spellBonusDam.dam_Slash += 6;
                              break;
                         case SPELL_POWER_ATTACK5:
                              spellBonusDam.dam_Slash += 5;
                              break;
                         case SPELL_POWER_ATTACK4:
                              spellBonusDam.dam_Slash += 4;
                              break;
                         case SPELL_POWER_ATTACK3:
                              spellBonusDam.dam_Slash += 3;
                              break;
                         case SPELL_POWER_ATTACK2:
                              spellBonusDam.dam_Slash += 2;
                              break;
                         case SPELL_POWER_ATTACK1:
                              spellBonusDam.dam_Slash += 1;
                              break;
                         case SPELL_SUPREME_POWER_ATTACK:
                              spellBonusDam.dam_Slash += 20;
                              break;
                    }
               }
               */

        }
        else if (eType == EFFECT_TYPE_DAMAGE_DECREASE)
        {
            if(iEffectRace != 28)
            {
                if(iEffectRace == iRace)
                {
                    //Define racial type-based damage and load into struct
                    nBonus = GetEffectInteger(eEffect, 0);
                    nDamage = GetDamageByConstant(nBonus, FALSE);
                    nDamageType = GetEffectInteger(eEffect, 1);
                    switch(nDamageType)
                    {
                        case DAMAGE_TYPE_ACID:
                        spellBonusDam.dam_Acid -= nDamage;
                        break;

                        case DAMAGE_TYPE_BASE_WEAPON:
                        spellBonusDam.dam_Slash -= nDamage;
                        break;

                        case DAMAGE_TYPE_BLUDGEONING:
                        spellBonusDam.dam_Blud -= nDamage;
                        break;

                        case DAMAGE_TYPE_COLD:
                        spellBonusDam.dam_Cold -= nDamage;
                        break;

                        case DAMAGE_TYPE_DIVINE:
                        spellBonusDam.dam_Div -= nDamage;
                        break;

                        case DAMAGE_TYPE_ELECTRICAL:
                        spellBonusDam.dam_Elec -= nDamage;
                        break;

                        case DAMAGE_TYPE_FIRE:
                        spellBonusDam.dam_Fire -= nDamage;
                        break;

                        case DAMAGE_TYPE_MAGICAL:
                        spellBonusDam.dam_Mag -= nDamage;
                        break;

                        case DAMAGE_TYPE_NEGATIVE:
                        spellBonusDam.dam_Neg -= nDamage;
                        break;

                        case DAMAGE_TYPE_PIERCING:
                        spellBonusDam.dam_Pier -= nDamage;
                        break;

                        case DAMAGE_TYPE_POSITIVE:
                        spellBonusDam.dam_Pos -= nDamage;
                        break;

                        case DAMAGE_TYPE_SLASHING:
                        spellBonusDam.dam_Slash -= nDamage;
                        break;

                        case DAMAGE_TYPE_SONIC:
                        spellBonusDam.dam_Son -= nDamage;
                        break;
                    }
                }
            }
            else if(iEffectLawChaos != 0 || iEffectGoodEvil != 0)
            {
                if(iEffectLawChaos == iLawChaos || iEffectGoodEvil == iGoodEvil)
                {
                    //Define alignment-based damage and load into struct
                    nBonus = GetEffectInteger(eEffect, 0);
                    nDamage = GetDamageByConstant(nBonus, FALSE);
                    nDamageType = GetEffectInteger(eEffect, 1);
                    switch(nDamageType)
                    {
                        case DAMAGE_TYPE_ACID:
                        spellBonusDam.dam_Acid -= nDamage;
                        break;

                        case DAMAGE_TYPE_BASE_WEAPON:
                        spellBonusDam.dam_Slash -= nDamage;
                        break;

                        case DAMAGE_TYPE_BLUDGEONING:
                        spellBonusDam.dam_Blud -= nDamage;
                        break;

                        case DAMAGE_TYPE_COLD:
                        spellBonusDam.dam_Cold -= nDamage;
                        break;

                        case DAMAGE_TYPE_DIVINE:
                        spellBonusDam.dam_Div -= nDamage;
                        break;

                        case DAMAGE_TYPE_ELECTRICAL:
                        spellBonusDam.dam_Elec -= nDamage;
                        break;

                        case DAMAGE_TYPE_FIRE:
                        spellBonusDam.dam_Fire -= nDamage;
                        break;

                        case DAMAGE_TYPE_MAGICAL:
                        spellBonusDam.dam_Mag -= nDamage;
                        break;

                        case DAMAGE_TYPE_NEGATIVE:
                        spellBonusDam.dam_Neg -= nDamage;
                        break;

                        case DAMAGE_TYPE_PIERCING:
                        spellBonusDam.dam_Pier -= nDamage;
                        break;

                        case DAMAGE_TYPE_POSITIVE:
                        spellBonusDam.dam_Pos -= nDamage;
                        break;

                        case DAMAGE_TYPE_SLASHING:
                        spellBonusDam.dam_Slash -= nDamage;
                        break;

                        case DAMAGE_TYPE_SONIC:
                        spellBonusDam.dam_Son -= nDamage;
                        break;
                    }
                }
            }
            else if(iEffectLawChaos == 0 && iEffectGoodEvil == 0 && iEffectRace == 28)
            {
                //Define generic damage and load into struct
                nBonus = GetEffectInteger(eEffect, 0);
                nDamage = GetDamageByConstant(nBonus, FALSE);
                nDamageType = GetEffectInteger(eEffect, 1);
                switch(nDamageType)
                {
                    case DAMAGE_TYPE_ACID:
                        spellBonusDam.dam_Acid -= nDamage;
                        break;

                    case DAMAGE_TYPE_BASE_WEAPON:
                        spellBonusDam.dam_Slash -= nDamage;
                        break;

                    case DAMAGE_TYPE_BLUDGEONING:
                        spellBonusDam.dam_Blud -= nDamage;
                        break;

                    case DAMAGE_TYPE_COLD:
                        spellBonusDam.dam_Cold -= nDamage;
                        break;

                    case DAMAGE_TYPE_DIVINE:
                        spellBonusDam.dam_Div -= nDamage;
                        break;

                    case DAMAGE_TYPE_ELECTRICAL:
                        spellBonusDam.dam_Elec -= nDamage;
                        break;

                    case DAMAGE_TYPE_FIRE:
                        spellBonusDam.dam_Fire -= nDamage;
                        break;

                    case DAMAGE_TYPE_MAGICAL:
                        spellBonusDam.dam_Mag -= nDamage;
                        break;

                    case DAMAGE_TYPE_NEGATIVE:
                        spellBonusDam.dam_Neg -= nDamage;
                        break;

                    case DAMAGE_TYPE_PIERCING:
                        spellBonusDam.dam_Pier -= nDamage;
                        break;

                    case DAMAGE_TYPE_POSITIVE:
                        spellBonusDam.dam_Pos -= nDamage;
                        break;

                    case DAMAGE_TYPE_SLASHING:
                        spellBonusDam.dam_Slash -= nDamage;
                        break;

                    case DAMAGE_TYPE_SONIC:
                        spellBonusDam.dam_Son -= nDamage;
                        break;
                    }
            }
            
            /*
            switch(eSpellID)
            {
                case SPELLABILITY_HOWL_DOOM:
                case SPELLABILITY_GAZE_DOOM:
                case SPELL_DOOM:
                    spellBonusDam.dam_Mag -= 2;
                    break;

                case SPELL_GHOUL_TOUCH:
                    spellBonusDam.dam_Mag -= 2;
                    break;

                case SPELL_BATTLETIDE:
                    spellBonusDam.dam_Mag -= 2;
                    break;

                case SPELL_PRAYER:
                    spellBonusDam.dam_Slash -= 1;
                    break;

                case SPELL_SCARE:
                    spellBonusDam.dam_Mag -= 2;
                    break;

                // Hell Inferno
                case SPELL_HELLINFERNO_2:
                    spellBonusDam.dam_Mag -= 4;
                    break;

                // Curse Song
                case SPELL_BARD_CURSE_SONG:
                    // find out the caster (a bard in the vicinity, but beware of runes)
                    oCaster = GetEffectCreator(eEffect);
                    if(!GetIsObjectValid(oCaster)) // if we cannot find the caster, we assume the attacker was the caster
                        oCaster = oAttacker;

                    nDamage = 1;

                    if (GetIsObjectValid(oCaster))
                    {
                        nLvl = GetLevelByClass(CLASS_TYPE_BARD, oCaster);
                        int iPerform = GetSkillRank(SKILL_PERFORM, oCaster);

                        if (nLvl>=BARD_LEVEL_FOR_BARD_SONG_DAM_3 && iPerform>= BARD_PERFORM_SKILL_FOR_BARD_SONG_DAM_3)
                            nDamage = 3;
                        else if (nLvl>= BARD_LEVEL_FOR_BARD_SONG_DAM_2 && iPerform>= BARD_PERFORM_SKILL_FOR_BARD_SONG_DAM_2)
                            nDamage = 2;
                    }
                    spellBonusDam.dam_Blud -= nDamage;
            }
            */
        }
        eEffect = GetNextEffect(oAttacker);
    }
    return spellBonusDam;
}

// motu99: This partially depends on the defender, which might change during a round. But usually it is only calculated once at beginning of round
int GetWeaponDamagePerRound(object oDefender, object oAttacker, object oWeap, int iOffhand = 0)
{
    string sDebugMessage = PRC_TEXT_WHITE;
    int bDebug = GetPRCSwitch(PRC_COMBAT_DEBUG);

    int iDamage = 0;
    int iWeaponType = GetBaseItemType(oWeap);

    int iStr = GetAbilityModifier(ABILITY_STRENGTH, oAttacker);

    // ranged weapon specific rules
    if(GetIsRangedWeaponType(iWeaponType))
    {
        // add mighty weapon strength damage
        int iMighty = GetMightyWeaponBonus(oWeap);
        if(iMighty > 0)
        {
            if(iStr > iMighty) iStr = iMighty;

            iDamage += iStr;
            if (bDebug) sDebugMessage += "Mighty (" + IntToString(iStr) + ")";
        }
    }
    // melee weapon rules
    else
    {
        // double str bonus to damage
        if(GetIsTwoHandedMeleeWeaponType(iWeaponType))
            iStr += iStr/2;

        // off-hand weapons deal half str bonus
        if(iOffhand)
            iStr /= 2;

        iDamage += iStr;

        if (bDebug) sDebugMessage += "Str Bonus (" + IntToString(iStr) + ")";

        // Handle the damage bonus from PRC Power Attack
        iDamage += GetLocalInt(oAttacker, "PRC_PowerAttack_DamageBonus");
    }

    // weapon specializations
    int iSpecializationBonus = 0;

    // determine the feat constants appropriate for the weapon base type
    struct WeaponFeat sWeaponFeat = GetAllFeatsOfWeaponType(iWeaponType);

    // check for specialization feat
    if(GetHasFeat(sWeaponFeat.Specialization, oAttacker))
    {
        iSpecializationBonus += 2;

        // now check for epic specialization feat, can only have it, if we already have specialization
        // +4 of epic specialization stacks with "normal" specialization
        if(GetHasFeat(sWeaponFeat.EpicSpecialization, oAttacker))
            iSpecializationBonus += 4;
    }

    iDamage += iSpecializationBonus;
    if (bDebug) sDebugMessage += " + WeapSpec (" + IntToString(iSpecializationBonus) + ")";

    // adds weapon enhancement bonus to damage
    int iEnhancement = GetWeaponEnhancement(oWeap, oDefender, oAttacker);  // motu: we are calling this quite often (for attack rolls, for damage, etc); better call it once at beginning of round and remember
    iDamage += iEnhancement;
    if (bDebug) sDebugMessage += " + WeapEnh (" + IntToString(iEnhancement) + ")";

    // support for power attack and expertise modes
    int iCombatMode = GetLastAttackMode(oAttacker);
    if( iCombatMode == COMBAT_MODE_POWER_ATTACK /*&&
         !GetHasSpellEffect(SPELL_SUPREME_POWER_ATTACK) &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK10) &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK9)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK8)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK7)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK6)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK5)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK4)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK3)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK2)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK1) */)
    {
        iDamage += 5;
        if (bDebug) sDebugMessage += " + PowAtk (" + IntToString(5) + ")";
    }
    else if( iCombatMode == COMBAT_MODE_IMPROVED_POWER_ATTACK /*&&
         !GetHasSpellEffect(SPELL_SUPREME_POWER_ATTACK) &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK10) &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK9)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK8)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK7)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK6)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK5)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK4)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK3)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK2)  &&
         !GetHasSpellEffect(SPELL_POWER_ATTACK1) */)
    {
        iDamage += 10;
        if (bDebug) sDebugMessage += " + ImpPowAtk (" + IntToString(10) + ")";
    }

    // calculates bonus damage for Favored Enemies
    // this is just added each round to help prevent lag
    // can be moved if this becomes an issue of course.
    int iFavoredEnemyBonus = GetFavoredEnemyDamageBonus(oDefender, oAttacker);
    iDamage += iFavoredEnemyBonus;
    
    // Damage from the Shadow Blade feat
    iDamage += GetLocalInt(oAttacker, "ShadowBladeDam");

    if (bDebug) sDebugMessage += " + FavEnmy (" + IntToString(iFavoredEnemyBonus) + ")";
    if (bDebug) sDebugMessage = PRC_TEXT_WHITE + "Weapon Damage = " + IntToString(iDamage) + ": " + sDebugMessage;
    if (bDebug) DoDebug(sDebugMessage);

    return iDamage;
}

// returns the highest critical bonus damage constant on the weapon
// note that this is the IP_DAMAGE_CONSTANT, not the damage itself
// only compares the damage constants, so does not differentiate between dice and constant damage (and assumes, that damage constants are ordered appropriately)
int GetMassiveCriticalBonusDamageConstantOfWeapon(object oWeapon)
{
    int iMassCritBonusDamage = 0;
    int iCostVal;

    itemproperty ip = GetFirstItemProperty(oWeapon);
    while(GetIsItemPropertyValid(ip))
    {
        if(GetItemPropertyType(ip) == ITEM_PROPERTY_MASSIVE_CRITICALS)
        {
            // get the damage constant
            iCostVal = GetItemPropertyCostTableValue(ip);

            // is the damage constant higher than our highest yet?
            if(iCostVal > iMassCritBonusDamage)
            {
                iMassCritBonusDamage = iCostVal;
            }
        }
        ip = GetNextItemProperty(oWeapon);
    }
    // convert damage constant to an integer
    return iMassCritBonusDamage;
}

// this function assumes that we have scored a hit; it returns the damage effect that we need to apply to the Defender
// if we kill the critter immediately ( devastating crit), we return an invalid effect, because we don't need to apply any damage to an already dead defender
effect GetAttackDamage(object oDefender, object oAttacker, object oWeapon, struct BonusDamage sWeaponBonusDamage, struct BonusDamage sSpellBonusDamage, int iOffhand = 0, int iDamage = 0, int bIsCritical = FALSE, int iNumDice = 0, int iNumSides = 0, int iCriticalMultiplier = 0)
{
// we assume that critical immunity of defender has been already checked in the calling function
// and that the bIsCritical flag is only true, if we scored a critical hit against a non-critical immune defender

    int iWeaponType = GetBaseItemType(oWeapon);
    effect eDeath;

    // create an invalid effect to check whether we did a death attack or not
    effect eLink = eDeath;

    // first check Devastating Critical
    if(bIsCritical && GetHasFeat(GetDevastatingCriticalFeatOfWeaponType(iWeaponType), oAttacker) )
    {
        // DC = 10 + 1/2 char level + str mod.
        int iStr = GetAbilityModifier(ABILITY_STRENGTH, oAttacker);
        int iLevelMod = GetHitDice(oAttacker) / 2;
        int iSaveDC = 10 + iStr + iLevelMod;

        if(!FortitudeSave(oDefender, iSaveDC, SAVING_THROW_TYPE_NONE, oAttacker) )
        {
            string sMes = "*Devastating Critical*";
            if (DEBUG)
            {
                sMes = "scripted " + sMes;
//              SendMessageToPC(oAttacker, sMes);
            }
            FloatingTextStringOnCreature(sMes, oAttacker, FALSE);

            // circumvents death immunity... since anyone CDG'ed is dead.
            eDeath = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oDefender);
        }
    }

    // if we didn't score a devastating critical, proceed normally
    if(eLink == eDeath)
    {
        string sDebugMessage = "";
        int bDebug = GetPRCSwitch(PRC_COMBAT_DEBUG);
        int iWeaponDamage = 0;
        int iBonusWeaponDamage = 0;
        int iMassCritBonusDamage = 0;

        // only read the data if it is not already given
        if(!iNumSides)  iNumSides = StringToInt(Get2DACache("baseitems", "DieToRoll", iWeaponType));
        if(!iNumDice)   iNumDice  = StringToInt(Get2DACache("baseitems", "NumDice", iWeaponType));
        if(bIsCritical && !iCriticalMultiplier)  iCriticalMultiplier = GetWeaponCritcalMultiplier(oAttacker, oWeapon);

        // Returns proper unarmed damage if they are a monk
        // or have a creature weapon from a PrC class. - Brawler, Shou, IoDM, etc.
        // Note: When using PerformAttackRound gloves are passed to this function
        //       as oWeapon, so this will not be called twice.
        if( iWeaponType == BASE_ITEM_INVALID && GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oAttacker) != OBJECT_INVALID
            || iWeaponType == BASE_ITEM_INVALID && GetLevelByClass(CLASS_TYPE_MONK, oAttacker) )
        {
            int iUnarmedDamage = FindUnarmedDamage(oAttacker);
            iNumSides = StringToInt(Get2DACache("iprp_monstcost", "Die", iUnarmedDamage));
            iNumDice  = StringToInt(Get2DACache("iprp_monstcost", "NumDice", iUnarmedDamage));
        }
        else if(iWeaponType == BASE_ITEM_INVALID)
        {
            // unarmed non-monk 1d3 damage
            iNumSides = 3;
            iNumDice  = 1;
        }

        int iDiceRoll = 0;
        //Roll the base damage dice.
                if(iNumSides == 2)  iDiceRoll = d2(iNumDice);
                if(iNumSides == 3)  iDiceRoll = d3(iNumDice);
                if(iNumSides == 4)  iDiceRoll = d4(iNumDice);
                if(iNumSides == 6)  iDiceRoll = d6(iNumDice);
                if(iNumSides == 8)  iDiceRoll = d8(iNumDice);
                if(iNumSides == 10) iDiceRoll = d10(iNumDice);
                if(iNumSides == 12) iDiceRoll = d12(iNumDice);
                if(iNumSides == 20) iDiceRoll = d20(iNumDice);

                // Normal rolling
                iWeaponDamage += iDiceRoll;
                //if (DEBUG) DoDebug("Starting Aura of Chaos");
                // Aura of Chaos rerolls and adds if the dice rolled is max.
                if (GetLocalInt(oAttacker, "DSChaos"))
                {
                    // Maximum possible result
                while ((iNumSides * iNumDice) == iDiceRoll)
                {
                    // This should cover things properly
                        if(iNumSides == 2)  iDiceRoll = d2(iNumDice);
                        if(iNumSides == 3)  iDiceRoll = d3(iNumDice);
                        if(iNumSides == 4)  iDiceRoll = d4(iNumDice);
                        if(iNumSides == 6)  iDiceRoll = d6(iNumDice);
                        if(iNumSides == 8)  iDiceRoll = d8(iNumDice);
                        if(iNumSides == 10) iDiceRoll = d10(iNumDice);
                        if(iNumSides == 12) iDiceRoll = d12(iNumDice);
                        if(iNumSides == 20) iDiceRoll = d20(iNumDice);

                        // Chaos bonuses
                        iWeaponDamage += iDiceRoll;
                }
        }
        //if (DEBUG) DoDebug("Ending Aura of Chaos");

                if (bDebug) sDebugMessage += IntToString(iNumDice) + "d" + IntToString(iNumSides) + " (" + IntToString(iDiceRoll) + ")";

        int iOCRoll = 0;
        // Determine Massive Critical Bonuses
        if(bIsCritical)
        { // note that critical hit immuniy already has been checked in the attack roll, so we need not check it here

            // get the highest massive critical bonus damage constant on the weapon
            iMassCritBonusDamage = GetMassiveCriticalBonusDamageConstantOfWeapon(oWeapon);

            // convert it to an integer, if not zero
            if (iMassCritBonusDamage)
                iMassCritBonusDamage = GetDamageByConstant(iMassCritBonusDamage, TRUE);

            if(GetHasFeat(FEAT_EPIC_THUNDERING_RAGE, oAttacker) && GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oAttacker) )
                iMassCritBonusDamage += d8(2);


            // if player has Overwhelming Critical with this weapon type.
            if(GetHasFeat(GetOverwhelmingCriticalFeatOfWeaponType(iWeaponType), oAttacker) )
            {
                // should do +1d6 damage, 2d6 if crit X 3, 3d6 if X4, etc.
                int iOCDice = iCriticalMultiplier - 1;
                if(iOCDice < 1) iOCDice = 1;
                iOCRoll = d6(iOCDice);
            }
        }

        // Get bonus damage, unless we already calculated it
        if(iDamage) iBonusWeaponDamage = iDamage;
        else        iBonusWeaponDamage = GetWeaponDamagePerRound(oDefender, oAttacker, oWeapon, iOffhand);

        // dpr = damage per round (assumed to be the same on every attack)
        if (bDebug) sDebugMessage += " + Weap Bon DPR (" + IntToString(iBonusWeaponDamage) + ")";

        iWeaponDamage += iBonusWeaponDamage;

        // PnP Rules State:
        // Extra Damage over and above a weapons normal damage
        // such as that dealt by a sneak attack or special ability of
        // a flaming sword are not multiplied when you score a critical hit
        // so no magical effects or bonuses are doubled.

        if(bIsCritical)
        {
            // determine critical damage
            if (bDebug) sDebugMessage += " + Crit (" + IntToString(iWeaponDamage * (iCriticalMultiplier-1)) + ") [* " + IntToString(iCriticalMultiplier) + "]";
            iWeaponDamage *= iCriticalMultiplier;

            if(iMassCritBonusDamage)
            {
                iWeaponDamage += iMassCritBonusDamage;
                if (bDebug) sDebugMessage += " + MassCrit (" + IntToString(iMassCritBonusDamage) + ")";
            }

            if(iOCRoll)
            {
                iWeaponDamage += iOCRoll;
                if (bDebug) sDebugMessage += " + OvwhlmgCrit (" + IntToString(iOCRoll) + ")";
            }
        }

        int iOldWeaponDamage = iWeaponDamage;
        // add weapon bonus melee damage (constant damage)
        iWeaponDamage += GetDamageByConstant(sWeaponBonusDamage.dam_Blud, TRUE);
        iWeaponDamage += GetDamageByConstant(sWeaponBonusDamage.dam_Pier, TRUE);
        iWeaponDamage += GetDamageByConstant(sWeaponBonusDamage.dam_Slash, TRUE);

        // add weapon bonus melee damage (dice damage)
        iWeaponDamage += GetDamageByConstant(sWeaponBonusDamage.dice_Blud, TRUE);
        iWeaponDamage += GetDamageByConstant(sWeaponBonusDamage.dice_Pier, TRUE);
        iWeaponDamage += GetDamageByConstant(sWeaponBonusDamage.dice_Slash, TRUE);

        // weapon physical bonus damage - BPS = bludgeoning Piercing Slashing
        if (bDebug) sDebugMessage += " + Weap Bon Phys (" + IntToString(iWeaponDamage - iOldWeaponDamage) + ")";
        iOldWeaponDamage = iWeaponDamage;

        // damage from spells is stored as solid number (note, these are not spells on the weapon, such as darkfire)
        iWeaponDamage += sSpellBonusDamage.dam_Blud;
        iWeaponDamage += sSpellBonusDamage.dam_Pier;
        iWeaponDamage += sSpellBonusDamage.dam_Slash;

        iWeaponDamage += sSpellBonusDamage.dice_Blud; // motu99: Shouldn't we roll the dice?
        iWeaponDamage += sSpellBonusDamage.dice_Pier;
        iWeaponDamage += sSpellBonusDamage.dice_Slash;

        // motu99: why do we store different physical damage types (Bludg, Pierc, Slash) in the WeaponBonusDamage struct
        // when we sum up all physical damage here and only use the weapon base damage type?
        // wouldn't it be better to keep the different physical damage types separate and link them in one effect?

        // spell physical bonus damage
        if (bDebug) sDebugMessage += " + Spell Phys (" + IntToString(iWeaponDamage - iOldWeaponDamage) + ")";

        // Logic to determine if enemy can be sneak attacked
        // and to add sneak attack damage
        int iSneakDamage = 0;
        if(GetCanSneakAttack(oDefender, oAttacker) )
        {
            int iSneakDice = GetTotalSneakAttackDice(oAttacker);
            if(iSneakDice > 0)
            {
                iSneakDamage = GetSneakAttackDamage(iSneakDice);
                iWeaponDamage += iSneakDamage;
                if (bDebug) sDebugMessage += " + Sneak (" + IntToString(iSneakDamage) + ")";

                string sMes = "*Sneak Attack*";
                if (DEBUG) sMes = "scripted "+ sMes;
                FloatingTextStringOnCreature(sMes, oAttacker, FALSE);
//              SendMessageToPC(oAttacker, sMes);
            }

            if(GetHasFeat(FEAT_CRIPPLING_STRIKE, oAttacker) )
            {
                //effect eCrippleStrike = EffectAbilityDecrease(ABILITY_STRENGTH, 2);
                //ApplyEffectToObject(DURATION_TYPE_INSTANT, eCrippleStrike, oDefender);
                ApplyAbilityDamage(oDefender, ABILITY_STRENGTH, 2, DURATION_TYPE_PERMANENT, TRUE);
            }
        }

        // Elemental damage effects
        int iAcid, iCold, iFire, iElec, iSon;
        int iDiv, iNeg, iPos;
        int iMag;

        // first only do the constant damage effects (no dice rolls) on the weapon and from spells
        iAcid  = sSpellBonusDamage.dam_Acid;
        iAcid += GetDamageByConstant(sWeaponBonusDamage.dam_Acid, TRUE);

        iCold  = sSpellBonusDamage.dam_Cold;
        iCold += GetDamageByConstant(sWeaponBonusDamage.dam_Cold, TRUE);

        iFire  = sSpellBonusDamage.dam_Fire;
        iFire += GetDamageByConstant(sWeaponBonusDamage.dam_Fire, TRUE);

        iElec  = sSpellBonusDamage.dam_Elec;
        iElec += GetDamageByConstant(sWeaponBonusDamage.dam_Elec, TRUE);

        iSon  = sSpellBonusDamage.dam_Son;
        iSon += GetDamageByConstant(sWeaponBonusDamage.dam_Son, TRUE);

        iDiv  = sSpellBonusDamage.dam_Div;
        iDiv += GetDamageByConstant(sWeaponBonusDamage.dam_Div, TRUE);

        iNeg  = sSpellBonusDamage.dam_Neg;
        iNeg += GetDamageByConstant(sWeaponBonusDamage.dam_Neg, TRUE);

        iPos  = sSpellBonusDamage.dam_Pos;
        iPos += GetDamageByConstant(sWeaponBonusDamage.dam_Pos, TRUE);

        iMag  = sSpellBonusDamage.dam_Mag;
        iMag += GetDamageByConstant(sWeaponBonusDamage.dam_Mag, TRUE);


        // now add the dice damage from the weapon and spells
        iAcid += GetDamageByConstant(sSpellBonusDamage.dice_Acid, TRUE);
        iAcid += GetDamageByConstant(sWeaponBonusDamage.dice_Acid, TRUE);

        iCold += GetDamageByConstant(sSpellBonusDamage.dice_Cold, TRUE);
        iCold += GetDamageByConstant(sWeaponBonusDamage.dice_Cold, TRUE);

        iFire += GetDamageByConstant(sSpellBonusDamage.dice_Fire, TRUE);
        iFire += GetDamageByConstant(sWeaponBonusDamage.dice_Fire, TRUE);

        iElec += GetDamageByConstant(sSpellBonusDamage.dice_Elec, TRUE);
        iElec += GetDamageByConstant(sWeaponBonusDamage.dice_Elec, TRUE);

        iSon += GetDamageByConstant(sSpellBonusDamage.dice_Son, TRUE);
        iSon += GetDamageByConstant(sWeaponBonusDamage.dice_Son, TRUE);

        iDiv += GetDamageByConstant(sSpellBonusDamage.dice_Div, TRUE);
        iDiv += GetDamageByConstant(sWeaponBonusDamage.dice_Div, TRUE);

        iNeg += GetDamageByConstant(sSpellBonusDamage.dice_Neg, TRUE);
        iNeg += GetDamageByConstant(sWeaponBonusDamage.dice_Neg, TRUE);

        iPos += GetDamageByConstant(sSpellBonusDamage.dice_Pos, TRUE);
        iPos += GetDamageByConstant(sWeaponBonusDamage.dice_Pos, TRUE);

        iMag += GetDamageByConstant(sSpellBonusDamage.dice_Mag, TRUE);
        iMag += GetDamageByConstant(sWeaponBonusDamage.dice_Mag, TRUE);

        // Magical damage is not multiplied by criticals, at least not in PnP
        // Since it is in NwN, I left it default on in a switch.
        // Can be turned off to better emulate PnP rules.
        // motu99:  moved this down, because where it was before we only criticalled the constant damage, but not the dice damage
        if(bIsCritical && !GetPRCSwitch(PRC_PNP_ELEMENTAL_DAMAGE))
        {
            iAcid *=iCriticalMultiplier;
            iCold *= iCriticalMultiplier;
            iFire *= iCriticalMultiplier;
            iElec *= iCriticalMultiplier;
            iSon *= iCriticalMultiplier;

            iDiv *= iCriticalMultiplier;
            iNeg *= iCriticalMultiplier;
            iPos *= iCriticalMultiplier;

            iMag *= iCriticalMultiplier;
        }

        if (bDebug)
        {
            if (iAcid) sDebugMessage += PRC_TEXT_GREEN + " + Acid (" + IntToString(iAcid) + ")";
            if (iCold) sDebugMessage += PRC_TEXT_LIGHT_BLUE + " + Cold (" + IntToString(iCold) + ")";
            if (iFire) sDebugMessage += PRC_TEXT_RED + " + Fire (" + IntToString(iFire) + ")";
            if (iElec) sDebugMessage += PRC_TEXT_DARK_BLUE + " + Elec (" + IntToString(iElec) + ")";
            if (iSon) sDebugMessage += PRC_TEXT_LIGHT_ORANGE + " + Son (" + IntToString(iSon) + ")";
            if (iDiv) sDebugMessage += PRC_TEXT_PURPLE + " + Div (" + IntToString(iDiv) + ")";
            if (iNeg) sDebugMessage += PRC_TEXT_GRAY + " + Neg (" + IntToString(iNeg) + ")";
            if (iPos) sDebugMessage += " + Pos (" + IntToString(iPos) + ")";
            if (iMag) sDebugMessage += PRC_TEXT_PURPLE + " + Mag (" + IntToString(iMag) + ")";
        }

        // sum up all magical damage, as we need it later
        int iMagicalDamage = iAcid + iCold + iFire + iElec + iSon + iDiv + iNeg + iPos + iMag;

        // just in case damage is somehow less than 1
        if(iWeaponDamage < 1) iWeaponDamage = 1;
        //if (DEBUG) DoDebug("Starting NightmareBlade");
        // Nightmare Blades double to quadruple the damage dealt for the normal attack
                if (GetLocalInt(oDefender, "NightmareBlade") > 0) iWeaponDamage = iWeaponDamage * GetLocalInt(oDefender, "NightmareBlade");
        //if (DEBUG) DoDebug("Ending NightmareBlade");
        // create an invalid effect to return on a coup de grace

        // the rest of the code for a Coup De Grace
        int bDisableCoupDeGrace = GetPRCSwitch(PRC_DISABLE_COUP_DE_GRACE);
        if (!bDisableCoupDeGrace && !GetLocalInt(oAttacker, "PactQuality"+IntToString(VESTIGE_BUER)) && GetHasSpellEffect(VESTIGE_BUER, oAttacker)) bDisableCoupDeGrace = TRUE;
        
        if(bFirstAttack && bIsCritical && !bDisableCoupDeGrace && GetIsHelpless(oDefender))
        {
            // DC = 10 + damage dealt.
            int iSaveDC = 10;
            iSaveDC += iWeaponDamage;
            iSaveDC += iMagicalDamage;

            if(!FortitudeSave(oDefender, iSaveDC, SAVING_THROW_TYPE_NONE, oAttacker) )
            {
                string sMes = "*Coup De Grace*";
                FloatingTextStringOnCreature(sMes, oAttacker, FALSE);
//              SendMessageToPC(oAttacker, sMes);

                // circumvents death immunity... since anyone CDG'ed is dead.
                effect eDeath = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oDefender);
            }
        }

        // if we didn't succeed in our coup the grace, apply the damage
        if (eLink == eDeath)
        {
            // motu99: inefficient, because this calls GetWeaponEnhancement(), which already was called in AttackLoopLogic() or PerformAttack()
            // @TODO: store weaponEnhancement value and make new function that takes this value
            int iDamagePower = GetDamagePowerConstant(oWeapon, oDefender, oAttacker);
            int iDamageType = GetDamageTypeByWeaponType(iWeaponType);
            //if (DEBUG) DoDebug("prc_inc_combat Calculating Damage");
            // When this maneuver is in effect, weapon damage is fire
            // Also put here so it doesn't muck up things looking for weapon damage type
            if (GetLocalInt(oAttacker, "DWBurningBrand")) iDamageType = DAMAGE_TYPE_FIRE;
            // Swordsage Insightful Strike, grants wisdom to damage on maneuvers
            if (GetLocalInt(oAttacker, "InsightfulStrike"))
            {
                iWeaponDamage += GetAbilityModifier(ABILITY_WISDOM, oAttacker);
            }
            // RKV Divine Fury grants 1d10 bonus damage
            if (GetLocalInt(oAttacker, "RKVDivineFury"))
            {
                iWeaponDamage += d10();
                DeleteLocalInt(oAttacker, "RKVDivineFury");
            }
            // Blade Meditation grants 10 bonus damage
            if (GetLocalInt(oAttacker, "BladeMeditationDamage"))
            {
                iWeaponDamage += 1;
                DeleteLocalInt(oAttacker, "BladeMeditationDamage");
            }            
            // Warblade Battle Cunning: Int To Damage on Flatfoots.
            if (GetLevelByClass(CLASS_TYPE_WARBLADE, oAttacker) >= 7 && (GetIsFlanked(oDefender, oAttacker) || GetIsDeniedDexBonusToAC(oDefender, oAttacker)))
            {
                if (DEBUG_BATTLE_CUNNING)
                {   
                    FloatingTextStringOnCreature("**** BATTLE CUNNING BONUS ****", oDefender);
                    DoDebug("Battle Cunning damage bonus");
                }
                iWeaponDamage += GetAbilityModifier(ABILITY_INTELLIGENCE, oAttacker);
            }
            if (GetLevelByClass(CLASS_TYPE_MASTER_OF_NINE, oAttacker) >= 3)
            {
                // Check the persistent locals
                int i, nCount;
                for(i = 1; i <= 9; i++)
                {
                    // Loop over all disciplines, and total up how many he knows
                    nCount += GetPersistantLocalInt(oAttacker, "MasterOfNine" + IntToString(i));
                }

                iWeaponDamage += nCount;
            }
            // Bypass damage reduction if set
            // Done by increasing total damage done to bypass existing DR taking immunity into account
            if(GetLocalInt(oAttacker, "MoveIgnoreDR"))
            {
                struct DamageReducers drReduced = GetTotalReduction(oAttacker, oDefender, oWeapon);
                int nRedDR = drReduced.nStaticReductions * 100 / (100 - drReduced.nPercentReductions);
                iWeaponDamage += nRedDR;
                if(DEBUG) DoDebug("Damage increased by " + IntToString(nRedDR) + " to ignore DR");
            }
            // Shadow Sun Ninja
            if (GetLocalInt(oAttacker, "SSN_DARKWL"))
            {
                effect eSSN = GetFirstEffect(oDefender);
                while(GetIsEffectValid(eSSN))
                {
                    if(GetEffectType(eSSN) == EFFECT_TYPE_BLINDNESS)
                    {
                        iWeaponDamage += 4;
                        break;
                    }
                    eSSN = GetNextEffect(oDefender);
                }
            }
            // This is for the Lightning Throw Maneuver.
            if (GetLocalInt(oAttacker, "LightningThrowSave")) iWeaponDamage /= 2;
            //if (DEBUG) DoDebug("Ending LightningThrowSave");
            
            if (iDamagePower > 0)
            {
                struct DamReduction nDR = OvercomeDR(oDefender);
                if (iDamagePower >= nDR.nRedLevel)
                    iWeaponDamage += nDR.nRedAmount;
                    
                if (DEBUG) DoDebug("Overcoming DR "+IntToString(nDR.nRedAmount));    
            }

			int nNoDamage = FALSE;
			itemproperty ip = GetFirstItemProperty(oWeapon);
    		while(GetIsItemPropertyValid(ip))
    		{
        		int ipType = GetItemPropertyType(ip);
        		if (ipType == ITEM_PROPERTY_NO_DAMAGE)
        		{
        			nNoDamage = TRUE;
        			if (DEBUG) DoDebug("nNoDamage is TRUE"); 
        			eLink = EffectLinkEffects(EffectDamage(1), EffectHeal(1));
        		}	

        		ip = GetNextItemProperty(oWeapon);
   			}

			if (!nNoDamage)
			{
            	// motu99: why do we store different physical damage types (Bludg, Pierc, Slash) in the WeaponBonusDamage struct
            	// when we sum up all physical damage here and only use the weapon base damage type?
            	// wouldn't it be better to keep the different physical damage types separate and link them in one effect?
            	effect eEffect = PRCEffectDamage(oDefender, iWeaponDamage, iDamageType, iDamagePower);
            	//if (DEBUG) DoDebug("prc_inc_combat WeaponDamage: "+IntToString(iWeaponDamage)+"  DamageType" +IntToString(iDamageType)+"  DamagePower "+IntToString(iDamagePower));
            	// create eLink starting with the melee weapon damage eEffect (calculated above)
            	// then add all the other possible effects.
            	eLink = eEffect;
	
            	if (iAcid > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iAcid, DAMAGE_TYPE_ACID)), EffectVisualEffect(VFX_COM_HIT_ACID));
            	if (iCold > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iCold, DAMAGE_TYPE_COLD)), EffectVisualEffect(VFX_COM_HIT_FROST ));
            	if (iFire > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iFire, DAMAGE_TYPE_FIRE)), EffectVisualEffect(VFX_IMP_FLAME_S));
            	if (iElec > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iElec, DAMAGE_TYPE_ELECTRICAL)), EffectVisualEffect(VFX_COM_HIT_ELECTRICAL ));
            	if (iSon  > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iSon, DAMAGE_TYPE_SONIC)), EffectVisualEffect(VFX_COM_HIT_SONIC ));
	
            	if (iDiv  > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iDiv, DAMAGE_TYPE_DIVINE)), EffectVisualEffect(VFX_COM_HIT_DIVINE));
            	if (iNeg  > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iNeg, DAMAGE_TYPE_NEGATIVE)), EffectVisualEffect(VFX_COM_HIT_NEGATIVE ));
            	if (iPos  > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iPos, DAMAGE_TYPE_POSITIVE)), EffectVisualEffect(VFX_COM_HIT_DIVINE));

            	if (iMag  > 0) eLink = EffectLinkEffects(EffectLinkEffects(eLink, EffectDamage(iMag, DAMAGE_TYPE_MAGICAL)), EffectVisualEffect(VFX_COM_HIT_DIVINE));
            }
        }
        if (bDebug) sDebugMessage = PRC_TEXT_WHITE + "Damage = " + IntToString(iWeaponDamage +iMagicalDamage) + ": " + sDebugMessage;
        if (bDebug) DoDebug(sDebugMessage);
    }
    return eLink;
}


//:://////////////////////////////////////////////
//::  Attack Logic Functions
//:://////////////////////////////////////////////

// adapted from prc_alterations
void ActionCastSpellFromPlaceable(int iSpell, object oTarget, int iCasterLvl, int nMetaMagic = METAMAGIC_ANY, object oCaster = OBJECT_SELF)
{
    object oCastingObject = CreateObject(OBJECT_TYPE_PLACEABLE, "x0_rodwonder", GetLocation(oCaster));

    AssignCommand(oCastingObject, ActionCastSpellAtObject(iSpell, oTarget, nMetaMagic, TRUE, iCasterLvl, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));

    DestroyObject(oCastingObject, 6.0);
}


void ApplyOnHitDurationAbiltiies(object oTarget, int iDurationVal, effect eAbility, effect eVis)
{
    int iChance   = StringToInt( Get2DACache("iprp_onhitdur", "EffectChance", iDurationVal) );
    int iRoll = d100();

    if(iRoll <= iChance)
    {
        int iDuration = StringToInt( Get2DACache("iprp_onhitdur", "DurationRounds", iDurationVal) );
//      effect eLink = EffectLinkEffects(eAbility, eVis); // motu99: The visual effect eVis is instant, so linking with the temporary eAbility is not a good idea
//      ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(iDuration) );
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAbility, oTarget, RoundsToSeconds(iDuration) );
    }
}

// motu99: added saving throws (most were missing)
// @TODO: check if all saving throws are correct (will? fortitude?) and are called with appropriate SAVING_THROW_TYPE_*
// might also have to replace the Bioware saving throws with PRCMySavingThrow, eventually

// Note, that for the IP_CONST_ONHIT_<spell> constants, where <spell> is a spell that should be cast
// (such as IP_CONST_ONHIT_KNOCK, IP_CONST_ONHIT_LESSERDISPEL, etc.)
// we have to call the Impact spell scripts directly, because the commands ActionCastSpell* do not work within PRC combat!
/*
// the reason why we can't cast the onhitcast spells as a normal spellcast action is, that the spell casts are inserted into the action queue of the PRC attacker,
// but as long as the attacker is in physical combat (which is always the case for PerformAttack or PerformAttackRound), the (physical) attack action is
// at the top of the action queue and remains there throughout the whole combat process (which can be several rounds)
// Now the spell cast actions are inserted *after* the physical attack action, and therefore the spell cast actions are never executed
// (unless we stop attacking - which usually only happens if all enemies or the PC is dead)
// We can circumvent the problem with the action queue, by calling the Impact spell scripts directly. The problem with this approach is, that we are lacking
// the internal setup (done in the ActionCastSpell* commands), which is required so that the spell scripts receive the essential information they need.
// This essential information is retreived (in the spell script) via the functions GetSpellCastItem, GetSpellTarget etc.
// Unfortunately these information functions do not return sensible values when the impact spell scripts are called directly,
// because the necessary setup (usually done in ActionCastSpell*) has not been done
// What needs to be done, therefore, is to let the spell script know - by other means - what the essential parameters are
//(for onhit cast spells we usually need SpellTarget and SpellCastItem)
// As we don't know how Bioware passes the information to the GetSpellCastItem(), GetSpellTarget() etc. functions (most likely by local objects stored on the caster)
// the most straight forward approach seems to be, to replace all calls to GetSpellCastItem(), GetSpellTarget() etc. in all of the onhitcast spell impact scripts
// with PRC-wrapper functions, that use special local ints/objects (set on the caster or the module) in order to communicate the essential parameters to the spell impact script
// The only thing we then need to do, is to properly set up these local ints/objects by ourselves, before we execute
// the impact spell scripts, and delete them right after execution (so that they don't interfere with the normal spellcasting process)
// See ExecuteSpellScript() in prc_inc_spells how this can be done
*/
struct OnHitSpell DoOnHitProperties(itemproperty ip, object oTarget)
{
    // covers poison, vorpal, stun, disease, etc.
    // ipSubType = IP_CONST_ONHIT_*
    // ipCostVal = IP_CONST_ONHIT_SAVEDC_*

//  int iType = GetItemPropertyType(ip);
    struct OnHitSpell sSpell;
    int iDC = GetItemPropertyCostTableValue(ip);
    int iSubType = GetItemPropertySubType(ip);
    int iParam1 = GetItemPropertyParam1Value(ip);

    // change to proper save DC
    if (iDC < 0) iDC = 0;
    else if (iDC > 6) iDC = 6;
    iDC += (14 + iDC);

/*
    // change to proper save DC
    if(iDC < 10)
    {
        switch (iDC)
        {
            case 0: iDC = 14;
                break;
            case 1: iDC = 16;
                break;
            case 2: iDC = 18;
                break;
            case 3: iDC = 20;
                break;
            case 4: iDC = 22;
                break;
            case 5: iDC = 24;
                break;
            case 6: iDC = 26;
                break;
        }
    }
*/

    // sMes += " | I have On Hit: ";

    // motu99: moved variable declations out of switch statement, because declaration within produced a stack underflow error
    // we could also enclose the statements in the case with curly brackets {}, (seems to work in other places), but got paranoid after 4 hours of tracking down the error
    effect eEffect;
    effect eVis;
    int iStat;
    string sDiseaseType;

    // alignment code
//  int iGoodEvil = GetAlignmentGoodEvil(oTarget);
//  int iLawChaos = GetAlignmentLawChaos(oTarget);
//  int iAlignSpecific = GetItemPropAlignment(iGoodEvil, iLawChaos);

    switch (iSubType)
    {
        // set global vars for vorpal
        case IP_CONST_ONHIT_VORPAL:
        {
            bIsVorpalWeaponEquiped = TRUE;
            iVorpalSaveDC = iDC;
            break;
        }
        // iParam1 should be the ammout of levels to drain
        case IP_CONST_ONHIT_LEVELDRAIN:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NEGATIVE) )
            {
                if(iParam1 < 1) iParam1 = 1;

                eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                eEffect = SupernaturalEffect( EffectNegativeLevel(iParam1) );
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);
            }
            break;
        }
        // NEEDS TESTING
        case IP_CONST_ONHIT_WOUNDING:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                if(iParam1 < 1) iParam1 = 1;
                iParam1 = -iParam1;

                eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                // in theory this will drain them 1 HP per round.
                eEffect = ExtraordinaryEffect( EffectRegenerate(iParam1, 6.0 ) );
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 9999.0);
            }
            break;
        }
        // motu99: ActionCastSpell* will not work within scripted combat
        // @TODO: call the spell scripts directly via ExecuteSpellScript() and modify the spell scripts,
        // so that they can retrieve the SpellTarget and the SpellCastItem (use the PRC wrappers)
        // see new onhitcast section in prc_inc_spells for details

        /** WARNING:
        // It is extremely unsafe to call the spell scripts from within a loop over item properties
        // But DoOnHitProperties() is called from such a loop (the loop is done in ApplyOnHitAbilities)
        // So what we must do, is to pass the spell ID back to ApplyOnHitAbilities, there store it in an array
        // and then execute all impact spell scripts AFTER we have cycled through the item properties!
        // see prc_inc_spells (in particular the routines ApplyAllOnHitCastSpellsOnItem*) for details
        */
        case IP_CONST_ONHIT_KNOCK:
        {
            sSpell.iSpellID = SPELL_KNOCK;
            // ActionCastSpellAtObject(SPELL_KNOCK, oTarget, METAMAGIC_ANY, TRUE, iDC, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        }
        case IP_CONST_ONHIT_LESSERDISPEL:
        {
            sSpell.iSpellID = SPELL_LESSER_DISPEL;
            // ActionCastSpellAtObject(SPELL_LESSER_DISPEL, oTarget, METAMAGIC_ANY, TRUE, iDC, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        }
        case IP_CONST_ONHIT_DISPELMAGIC:
        {
            sSpell.iSpellID = SPELL_DISPEL_MAGIC;
            // ActionCastSpellAtObject(SPELL_DISPEL_MAGIC, oTarget, METAMAGIC_ANY, TRUE, iDC, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        }
        case IP_CONST_ONHIT_GREATERDISPEL:
        {
            sSpell.iSpellID = SPELL_GREATER_DISPELLING;
            // ActionCastSpellAtObject(SPELL_GREATER_DISPELLING, oTarget, METAMAGIC_ANY, TRUE, iDC, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        }
        case IP_CONST_ONHIT_MORDSDISJUNCTION:
        {
            sSpell.iSpellID = SPELL_MORDENKAINENS_DISJUNCTION;
            // ActionCastSpellAtObject(SPELL_MORDENKAINENS_DISJUNCTION, oTarget, METAMAGIC_ANY, TRUE, iDC, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            break;
        }
        // iParam1 = iprp_abilities.2da
        // both have the same effect in game
        // this "poison" property is 1d2 ability damage
        // not the actial poison.2da poison abilities.
        case IP_CONST_ONHIT_ITEMPOISON:
        case IP_CONST_ONHIT_ABILITYDRAIN:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                if (iParam1 <= 0)       iStat = ABILITY_STRENGTH;
                else if (iParam1 == 1)  iStat = ABILITY_DEXTERITY;
                else if (iParam1 == 2)  iStat = ABILITY_CONSTITUTION;
                else if (iParam1 == 3)  iStat = ABILITY_INTELLIGENCE;
                else if (iParam1 == 4)  iStat = ABILITY_WISDOM;
                else                    iStat = ABILITY_CHARISMA;

                eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                //eEffect = EffectAbilityDecrease(iStat, d2() );
                //ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);
                ApplyAbilityDamage(oTarget, iStat, d2(), DURATION_TYPE_PERMANENT, TRUE);
            }
            break;
        }
        // ipParam1 = disease.2da
        case IP_CONST_ONHIT_DISEASE:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {

                sDiseaseType = Get2DACache("disease", "Type", iParam1);
                eEffect = EffectDisease(iParam1);

                if(sDiseaseType == "EXTRA")      eEffect = ExtraordinaryEffect(eEffect);
                else if(sDiseaseType == "SUPER") eEffect = SupernaturalEffect(eEffect);

                eVis = EffectVisualEffect(VFX_IMP_DISEASE_S);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);
            }
            break;
        }
        // ipParam1 =  IPRP_ALIGNMENT
        case IP_CONST_ONHIT_SLAYALIGNMENT:
        {
            // int iGoodEvil = GetAlignmentGoodEvil(oTarget);
            // int iLawChaos = GetAlignmentLawChaos(oTarget);
            // int iAlignSpecific = GetItemPropAlignment(GetAlignmentGoodEvil(oTarget), GetAlignmentLawChaos(oTarget));

            // ipParam1 - specific alignment
            if(iParam1 == GetItemPropAlignment(GetAlignmentGoodEvil(oTarget), GetAlignmentLawChaos(oTarget)))
            {
                if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
                {
                    eVis = EffectVisualEffect(VFX_IMP_DEATH);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                    // circumvent death immunity
                    eEffect = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oTarget);
                }
            }
            break;
        }

        // ipParam1 =  IPRP_ALIGNGRP
        case IP_CONST_ONHIT_SLAYALIGNMENTGROUP:
        {
            // int iGoodEvil = GetAlignmentGoodEvil(oTarget);
            // int iLawChaos = GetAlignmentLawChaos(oTarget);

            // ipParam1 - alignment group
            if( iParam1 == IP_CONST_ALIGNMENTGROUP_ALL
                || iParam1 == GetAlignmentGoodEvil(oTarget)
                || iParam1 == GetAlignmentLawChaos(oTarget))
            {
                if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
                {
                    eVis = EffectVisualEffect(VFX_IMP_DEATH);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                    // circumvent death immunity
                    eEffect = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oTarget);
                }
            }
            break;
        }
        // ipParam1 =  racialtypes.2da
        case IP_CONST_ONHIT_SLAYRACE:
        {
            if(iParam1 == MyPRCGetRacialType(oTarget) )
            {
                if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
                {

                    eVis = EffectVisualEffect(VFX_IMP_DEATH);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                    // circumvent death immunity
                    eEffect = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oTarget);
                }
            }
            break;
        }
        // ipParam1 = iprp_onhitdur.2da
        case IP_CONST_ONHIT_BLINDNESS:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectBlindness();
                eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_CONFUSION:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = PRCEffectConfused();
                eVis = EffectVisualEffect(VFX_IMP_CONFUSION_S);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_DAZE:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectDazed();
                eVis = EffectVisualEffect(VFX_IMP_DAZED_S);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_DEAFNESS:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectDeaf();
                eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_DOOM:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectAttackDecrease(2);
                eEffect = EffectLinkEffects(eEffect, EffectDamageDecrease(2, DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_PIERCING|DAMAGE_TYPE_SLASHING));
                eEffect = EffectLinkEffects(eEffect, EffectSavingThrowDecrease(SAVING_THROW_ALL, 2));
                eEffect = EffectLinkEffects(eEffect, EffectSkillDecrease(SKILL_ALL_SKILLS, 2));
                eVis = EffectVisualEffect(VFX_IMP_DOOM);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_FEAR:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectFrightened();
                eVis = EffectVisualEffect(VFX_IMP_HEAD_EVIL);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_HOLD:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectParalyze();
                eVis = EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_SILENCE:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectSilence();
                eVis = EffectVisualEffect(VFX_IMP_SILENCE);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_SLEEP:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectSleep();
                eVis = EffectVisualEffect(VFX_IMP_SLEEP);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_SLOW:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectSlow();
                eVis = EffectVisualEffect(VFX_IMP_SLOW);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONHIT_STUN:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectStunned();
                eVis = EffectVisualEffect(VFX_IMP_STUN);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        default:
        {
            if (DEBUG) DoDebug("DoOnHitProperties: subtype not known, iSubType = " + IntToString(iSubType));
            break;
        }
    }

    if (sSpell.iSpellID)
        sSpell.iDC = iDC;

    return sSpell;
}

// motu99: added saving throws (most were missing)
// @TODO: check if all saving throws are correct (will? fortitude?) and are called with appropriate SAVING_THROW_TYPE_*
// might also have to replace the Bioware saving throws with PRCMySavingThrow, eventually
void DoOnMonsterHit(itemproperty ip, object oTarget)
{
//  int iType = GetItemPropertyType(ip);
    int iDC = GetItemPropertyCostTableValue(ip);
    int iSubType = GetItemPropertySubType(ip);
    int iParam1 = GetItemPropertyParam1Value(ip);

    // change to proper save DC
    if (iDC < 0) iDC = 0;
    else if (iDC > 6) iDC = 6;
    iDC += (14 + iDC);
/*
    if(iDC < 10)
    {
        switch (iDC)
        {
            case 0: iDC = 14;
                break;
            case 1: iDC = 16;
                break;
            case 2: iDC = 18;
                break;
            case 3: iDC = 20;
                break;
            case 4: iDC = 22;
                break;
            case 5: iDC = 24;
                break;
            case 6: iDC = 26;
                break;
        }
    }
*/

    // motu99: moved variable declations out of switch statement, because declaration within produced a stack underflow error
    // we could also enclose the statements in the case with curly brackets {}, but got paranoid after 4 hours of tracking down the error
    effect eEffect;
    effect eVis;
    int iStat;
    string sDiseaseType;

    switch(iSubType)
    {
        // ipParam1 should be the ammout of levels to drain
        case IP_CONST_ONMONSTERHIT_LEVELDRAIN:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NEGATIVE) )
            {
                if(iParam1 < 1) iParam1 = 1;

                eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                eEffect = SupernaturalEffect( EffectNegativeLevel(iParam1) );
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);
            }
            break;
        }
        // NEEDS TESTING
        case IP_CONST_ONMONSTERHIT_WOUNDING:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                if(iParam1 < 1) iParam1 = 1;
                iParam1 = -iParam1;

                eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                // in theory this will drain them 1 HP per round.
                eEffect = ExtraordinaryEffect( EffectRegenerate(iParam1, 6.0 ) );
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 9999.0);
            }
            break;
        }
        // iParam1 = iprp_abilities.2da
        // both have the same effect in game
        // this "poison" property is 1d2 ability damage
        // not the actial poison.2da poison abilities.
        case IP_CONST_ONMONSTERHIT_POISON:
        case IP_CONST_ONMONSTERHIT_ABILITYDRAIN:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                if (iParam1 <= 0)       iStat = ABILITY_STRENGTH;
                else if (iParam1 == 1)  iStat = ABILITY_DEXTERITY;
                else if (iParam1 == 2)  iStat = ABILITY_CONSTITUTION;
                else if (iParam1 == 3)  iStat = ABILITY_INTELLIGENCE;
                else if (iParam1 == 4)  iStat = ABILITY_WISDOM;
                else                    iStat = ABILITY_CHARISMA;

                eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

                //eEffect = EffectAbilityDecrease(iStat, d2() );
                //ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);
                ApplyAbilityDamage(oTarget, iStat, d2(), DURATION_TYPE_PERMANENT, TRUE);
            }
            break;
        }
        // ipParam1 = disease.2da
        case IP_CONST_ONMONSTERHIT_DISEASE:
        {
            if( !FortitudeSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                sDiseaseType = Get2DACache("disease", "Type", iParam1);
                eEffect = EffectDisease(iParam1);

                if(sDiseaseType == "EXTRA")      eEffect = ExtraordinaryEffect(eEffect);
                else if(sDiseaseType == "SUPER") eEffect = SupernaturalEffect(eEffect);

                eVis = EffectVisualEffect(VFX_IMP_DISEASE_S);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);
            }
            break;
        }
        case IP_CONST_ONMONSTERHIT_CONFUSION:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = PRCEffectConfused();
                eVis = EffectVisualEffect(VFX_IMP_CONFUSION_S);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONMONSTERHIT_DOOM:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectAttackDecrease(2);
                eEffect = EffectLinkEffects(eEffect, EffectDamageDecrease(2, DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_PIERCING|DAMAGE_TYPE_SLASHING));
                eEffect = EffectLinkEffects(eEffect, EffectSavingThrowDecrease(SAVING_THROW_ALL, 2));
                eEffect = EffectLinkEffects(eEffect, EffectSkillDecrease(SKILL_ALL_SKILLS, 2));

                eVis = EffectVisualEffect(VFX_IMP_DOOM);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONMONSTERHIT_FEAR:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectFrightened();
                eVis = EffectVisualEffect(VFX_IMP_HEAD_EVIL);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONMONSTERHIT_SLOW:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectSlow();
                eVis = EffectVisualEffect(VFX_IMP_SLOW);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        case IP_CONST_ONMONSTERHIT_STUN:
        {
            if( !WillSave(oTarget, iDC, SAVING_THROW_TYPE_NONE) )
            {
                eEffect = EffectStunned();
                eVis = EffectVisualEffect(VFX_IMP_STUN);
                ApplyOnHitDurationAbiltiies(oTarget, iParam1, eEffect, eVis);
            }
            break;
        }
        default:
        {
            if(DEBUG) DoDebug("DoOnMonsterHit: item property subtype not known, ipSubType = "+ IntToString(iSubType));
            break;
        }
    }
}



// motu99: modified function so that it does not produce a stack underflow error
// added saving throws (could be done more elegantly, but why bother, if it works)
// @TODO: check if all saving throws are correct (will? fortitude?) and are called with appropriate SAVING_THROW_TYPE_*

// made modifications to onhitcast system, so that onhitcasting should work - in principle - with all onhitcast spells
// ( modifications to the spell scripts are required, in PRC 3.1d only done for Darkfire and Flame Weapon)
// @TODO: do the necessary modifications for all impact spell scripts (see prc_inc_spells, what to do)
void ApplyOnHitAbilities(object oTarget, object oItemWielder, object oItem)
{
//  string sMes = "";

    // motu99: moved declaration of these variables outside of switch statement
    // because it says in NWNLexicon that you cannot declare / initialize a variable in a case statement
    // in the old version the function produced a stack underflow run-time error (hard to track down: compiler does not issue a compilation warning!)
    int iNr;
    int iType;
    int iSubType;
    int iCostVal;
    int iParam1;
    int bOnHitCastSpell = FALSE;
    struct OnHitSpell sSpell;
    array_create(oItemWielder, "ohspl"); // This is used here and in prc_inc_onhit

    effect eEffect;

    itemproperty ip = GetFirstItemProperty(oItem);

    while(GetIsItemPropertyValid(ip))
    {
        iType = GetItemPropertyType(ip);

        switch (iType)
        {
            case ITEM_PROPERTY_REGENERATION_VAMPIRIC:
            {
                iCostVal = GetItemPropertyCostTableValue(ip);
                eEffect = EffectHeal(iCostVal);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oItemWielder, 0.0);
                break;
            }
            case ITEM_PROPERTY_ONHITCASTSPELL:
            {
                // route all on-hit cast spells through the prc_onhitcast script
                // originally prc_onhitcast was only meant for unique powers,
                // but it has been extended to do all other onhit cast spells on the weapon
                // in order to bypass the biobug, that will only execute the first onhitcast spell on an item
                bOnHitCastSpell = TRUE;
                break;
            }
            case ITEM_PROPERTY_ON_HIT_PROPERTIES:
            {
                sSpell = DoOnHitProperties(ip, oTarget);

                // was it a spell that must be cast?
                if (sSpell.iSpellID)
                {
                    iNr++;
                    // store the spell ID in an array and execute the spell later, this is safer than trying to execute the spell script directly
                    array_set_int(oItemWielder, "ohspl", iNr, sSpell.iSpellID);

                    iNr++;
                    array_set_int(oItemWielder, "ohspl", iNr, sSpell.iDC);
                }
                break;
            }
            // much like above but for creature weapons
            case ITEM_PROPERTY_ON_MONSTER_HIT:
            {
                DoOnMonsterHit(ip, oTarget);
                break;
            }
            // poisons from poison.2da
            case ITEM_PROPERTY_POISON:
            {
                // @TODO: check if poison requires a Fortitude save
                iSubType = GetItemPropertySubType(ip);
                eEffect = EffectPoison( iSubType );
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);

                eEffect = EffectVisualEffect(VFX_IMP_POISON_L);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oTarget);
                break;
            }
            default:
            {
                break;
            }
        } // end switch iType
        ip = GetNextItemProperty(oItem);
    }

    // now route all on hit cast spells through "prc_onhitcast"
    if (bOnHitCastSpell)
    {
        ApplyOnHitUniquePower(oTarget, oItem, oItemWielder);
    }

    // now execute the spell scripts (note that the local array will not be deleted)
    while (iNr)
    {
        sSpell.iDC = array_get_int(oItemWielder, "ohspl", iNr);
        iNr--;
        sSpell.iSpellID = array_get_int(oItemWielder, "ohspl", iNr);
        iNr--;
        // we might have to determine an appropriate caster level (minimum for spell?) and an appropriate class from the spellID
        CastSpellAtObject(sSpell.iSpellID, oTarget, METAMAGIC_NONE, 0, 0, sSpell.iDC, OBJECT_INVALID, oItemWielder);
    }

//  FloatingTextStringOnCreature(sMes, oAttacker);
}

/**
// these files formerly contained references to the local object "PRC_CombatSystem_OnHitCastSpell_Item"
// references to this local int have been replaced by calls to PRCGetSpellCastItem()
scripts.hak: - prc_evnt_bonebld
        - prc_evnt_strmtl
        - prc_onhitcast
psionics.hak: psi_sk_onhit
*/

// checks all inventory slots for the haste item property
// we need this, because looping over all effects on the oPC does not find Haste from items
int GetHasHasteItemProperty(object oPC)
{
    int nInventorySlot;
    object oItem;

    for (nInventorySlot = 0; nInventorySlot < NUM_INVENTORY_SLOTS; nInventorySlot++)
    {
        oItem = GetItemInSlot(nInventorySlot, oPC);

        if(GetIsObjectValid(oItem))
        {
            if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_HASTE) )
                return TRUE;
        }
    }
    return FALSE;
}

struct BonusAttacks GetBonusAttacks(object oAttacker)
{
    int iSpell;
    struct BonusAttacks sBonusAttacks;
    int bHasHaste = FALSE;
    int bMartialFlurry = FALSE;

    effect eEffect = GetFirstEffect(oAttacker);

    // loop through all effects as long as they are valid
    while(GetIsEffectValid(eEffect))
    {
        // might have to guard against multiple haste effects, so we set a flag
        // could do this with the spell effects as well, but these should be only once on the PC
        if (GetEffectType(eEffect) == EFFECT_TYPE_HASTE)
            bHasHaste = TRUE;
        else
        {
            iSpell = GetEffectSpellId(eEffect);
            switch(iSpell)
            {
                case SPELL_FURIOUS_ASSAULT:
                    sBonusAttacks.iNumber++;
                    sBonusAttacks.iPenalty += 2;
                    break;

                case SPELL_MARTIAL_FLURRY_LIGHT:
                case SPELL_MARTIAL_FLURRY_ALL:
                    bMartialFlurry = TRUE;
                    break;

                case SPELL_EXTRASHOT:
                case SPELL_ONE_STRIKE_TWO_CUTS: // hopefully this spell is only on, if a katana is equipped
                    sBonusAttacks.iNumber++;
                    break;
            }
        }
        eEffect = GetNextEffect(oAttacker);
    }

    // if there is no Haste effect directly on the PC, check for haste on equipped items
    if (!bHasHaste)
        bHasHaste = GetHasHasteItemProperty(oAttacker);

    if (bHasHaste)
        sBonusAttacks.iNumber++;

    if (bMartialFlurry)
    {
        sBonusAttacks.iNumber++;
        sBonusAttacks.iPenalty += 2;
    }

    return sBonusAttacks;
}

// equips the first ammunition it finds in the inventory that works with the (ranged) weapon in the right hand
// returns the equipped new ammunition
object EquipAmmunition(object oPC)
{
// no sanity checks other than invalid right hand weapon; assumes we are really wielding a ranged weapon
// if called with a non ranged weapon, it will equip a weapon of the same base type from the inventory, if it finds one
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (oWeapon == OBJECT_INVALID)
        return oWeapon;

    int iWeaponType = GetBaseItemType(oWeapon);
    int iAmmoSlot = GetAmmunitionInventorySlotFromWeaponType(iWeaponType);
    int iNeededAmmoType;

    if (iAmmoSlot == INVENTORY_SLOT_ARROWS)
        iNeededAmmoType = BASE_ITEM_ARROW;
    else if (iAmmoSlot == INVENTORY_SLOT_BOLTS)
        iNeededAmmoType = BASE_ITEM_BOLT;
    else if (iAmmoSlot == INVENTORY_SLOT_BULLETS)
        iNeededAmmoType = BASE_ITEM_BULLET;
    else // darts, throwing axes or shuriken
        iNeededAmmoType = iWeaponType;

    int bNotEquipped = TRUE;
    object oItem = GetFirstItemInInventory(oPC);

    while (GetIsObjectValid(oItem) && bNotEquipped)
    {
        int iAmmoType = GetBaseItemType(oItem);
        if( iAmmoType == iNeededAmmoType)
        {
            AssignCommand(oPC, ActionEquipItem(oItem, iAmmoSlot));
            bNotEquipped = FALSE;
        }
        oItem = GetNextItemInInventory(oPC);
    }

    return oItem;
}



object FindNearestEnemy(object oAttacker)
{
    return GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);
}

object FindNearestNewEnemy(object oAttacker, object oOldDefender)
{
    // Find nearest enemy creature that is not the oOldDefender
    int iCreatureCounter = 1;

    object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, iCreatureCounter, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);

    // if there is no valid target at all, return directly
    if (!GetIsObjectValid(oTarget))
        return OBJECT_INVALID;

    // skip over any old defender
    else if (oTarget == oOldDefender)
    {
        iCreatureCounter++;
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, iCreatureCounter, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);
    }

    // either the target is invalid, or we found our closest target that is not the old defender
    // if this creature is not the closest living, no other will (unless GetNearestCreature is bugged, and returns dead creatures)
    return oTarget;
}

// Find nearest (valid) living enemy creature, that is not oOldDefender and that is within the specified range (in meters)
// default range is melee distance (=10 feet, 3.05 meters)
// If there is no (valid) living enemy within range, return the closest (living) enemy out of range
// If the first valid (supposedly living) creature found out of range is dead, or there is no (living) creature out of range, return OBJECT_INVALID
object FindNearestNewEnemyWithinRange(object oAttacker, object oOldDefender, float fDistance = MELEE_RANGE_METERS)
{
    int iCreatureCounter = 1;
    object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, iCreatureCounter, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);

    // is the old defender valid?
    int bOldDefenderValid = oOldDefender != OBJECT_INVALID;

    // skip over any target that is equal to the old defender
    // this only makes sense if old defender is a valid object
    if(bOldDefenderValid && oTarget == oOldDefender)
    {
        iCreatureCounter++;
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, iCreatureCounter, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);
    }

    // if oTarget is invalid, there is no new enemy, so we return
    if (!GetIsObjectValid(oTarget))
        return OBJECT_INVALID;
    // we only return non-dead targets
    else if (!GetIsDead(oTarget))
        return oTarget;

    // in the unlikely case that we found a dead, but valid target we only look for new candidate targets
    // as long as the distance to our last found (valid but dead) candidate target is within the specified range
    while (GetDistanceBetween(oTarget, oAttacker) <= fDistance)
    {
        iCreatureCounter++;
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, iCreatureCounter, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);

        // skip over any target that is equal to the old defender
        // this only makes sense if old defender is a valid object
        if(bOldDefenderValid && oTarget == oOldDefender)
        {
            iCreatureCounter++;
            oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, iCreatureCounter, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);
        }

        // if there is no valid target, we abort
        if (!GetIsObjectValid(oTarget))
            return OBJECT_INVALID;
        // otherwise we only return non-dead targets
        else if (!GetIsDead(oTarget))
            return oTarget;
    }
    // the last candidate target must have been valid, but dead and out of range, so we return OBJECT_INVALID
    // we could also return the dead target, but that does not really make sense
    return OBJECT_INVALID;
}

// debug function, might move this to inc_utility
string GetActionName(int iAction)
{
    switch(iAction)
    {
        case ACTION_ANIMALEMPATHY:  return "ACTION_ANIMALEMPATHY";
        case ACTION_ATTACKOBJECT: return "ACTION_ATTACKOBJECT";
        case ACTION_CASTSPELL: return "ACTION_CASTSPELL";
        case ACTION_CLOSEDOOR: return "ACTION_CLOSEDOOR";
        case ACTION_COUNTERSPELL: return "ACTION_COUNTERSPELL";
        case ACTION_DIALOGOBJECT: return "ACTION_DIALOGOBJECT";
        case ACTION_DISABLETRAP: return "ACTION_DISABLETRAP";
        case ACTION_DROPITEM: return "ACTION_DROPITEM";
        case ACTION_EXAMINETRAP: return "ACTION_EXAMINETRAP";
        case ACTION_FLAGTRAP: return "ACTION_FLAGTRAP";
        case ACTION_FOLLOW: return "ACTION_FOLLOW";
        case ACTION_HEAL: return "ACTION_HEAL";
        case ACTION_INVALID: return "ACTION_INVALID";
        case ACTION_ITEMCASTSPELL: return "ACTION_ITEMCASTSPELL";
        case ACTION_KIDAMAGE: return "ACTION_KIDAMAGE";
        case ACTION_LOCK: return "ACTION_LOCK";
        case ACTION_MOVETOPOINT: return "ACTION_MOVETOPOINT";
        case ACTION_OPENDOOR: return "ACTION_OPENDOOR";
        case ACTION_OPENLOCK: return "ACTION_OPENLOCK";
        case ACTION_PICKPOCKET: return "ACTION_PICKPOCKET";
        case ACTION_PICKUPITEM: return "ACTION_PICKUPITEM";
        case ACTION_RANDOMWALK: return "ACTION_RANDOMWALK";
        case ACTION_RECOVERTRAP: return "ACTION_RECOVERTRAP";
        case ACTION_REST: return "ACTION_REST";
        case ACTION_SETTRAP: return "ACTION_SETTRAP";
        case ACTION_SIT: return "ACTION_SIT";
        case ACTION_SMITEGOOD: return "ACTION_SMITEGOOD";
        case ACTION_TAUNT: return "ACTION_TAUNT";
        case ACTION_USEOBJECT: return "ACTION_USEOBJECT";
        case ACTION_WAIT: return "ACTION_WAIT";
    }
    return "unknown";
}

//returns a struct describing the applicable damage reductions with the given weapon and target
struct DamageReducers GetTotalReduction(object oPC, object oTarget, object oWeapon)
{
    int nDamageType = GetWeaponDamageType(oWeapon);
    //Note: DamageType is a bitwise number. 1 is B, 2 is P, 4 is S.
    //if(DEBUG) DoDebug("Damage Type: " + IntToString(nDamageType));
    int nAttackBonus = GetMonkEnhancement(oWeapon, oTarget, oPC);

    //handling for ammo
    if(oWeapon == GetItemInSlot(INVENTORY_SLOT_BOLTS, oPC)
       || oWeapon == GetItemInSlot(INVENTORY_SLOT_BULLETS, oPC)
       || oWeapon == GetItemInSlot(INVENTORY_SLOT_ARROWS, oPC))
          nAttackBonus = GetWeaponAttackBonusItemProperty(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC), oTarget);

    if(DEBUG) DoDebug("Weapon Atk Bonus: " + IntToString(nAttackBonus));

    struct DamReduction nBestDamageReduction;
    int nBestDamageResistance = 0;
    int nApplicableReduction;
    int nBestImmunutyLevel;
    struct DamReduction nCurrentReduction;
    nCurrentReduction.nRedLevel = DAMAGE_POWER_NORMAL;
    nCurrentReduction.nRedAmount = 0;
    nBestDamageReduction = nCurrentReduction;

    if(nAttackBonus < 1) nApplicableReduction = DAMAGE_POWER_NORMAL;
    else nApplicableReduction = IPGetDamageBonusConstantFromNumber(nAttackBonus);


    //loop through spell/power effects first
    effect eLoop=GetFirstEffect(oTarget);

    while (GetIsEffectValid(eLoop))
    {
        int nSpellID = GetEffectSpellId(eLoop);

        //Stoneskin
        if( nSpellID == 172
           || nSpellID == 342
           || nSpellID == SPELL_URDINNIR_STONESKIN)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_FIVE;
             nCurrentReduction.nRedAmount = 10;
        }
        //GreaterStoneskin
        if( nSpellID == 74)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_FIVE;
             nCurrentReduction.nRedAmount = 20;
        }
        //Premonition
        if( nSpellID == 134)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_FIVE;
             nCurrentReduction.nRedAmount = 30;
        }
        //Ghostly Visage
        if( nSpellID == 351
           || nSpellID == 605
           || nSpellID == 120)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_ONE;
             nCurrentReduction.nRedAmount = 5;
        }
        //Ethereal Visage
        if( nSpellID == 121)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_THREE;
             nCurrentReduction.nRedAmount = 20;
        }
        //Shadow Shield and Shadow Evade(best case)
        if( nSpellID == 160
           || nSpellID == 477
           || nSpellID == SPELL_SHADOWSHIELD)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_THREE;
             nCurrentReduction.nRedAmount = 10;
        }
        //Iron Body
        if( nSpellID == POWER_IRONBODY)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_FIVE;
             nCurrentReduction.nRedAmount = 15;
        }
        //Oak Body
        if( nSpellID == POWER_OAKBODY && nDamageType == DAMAGE_TYPE_SLASHING)
        {
             nBestDamageResistance = 10;
        }
        //Shadow Body
        if( nSpellID == POWER_SHADOWBODY)
        {
             nCurrentReduction.nRedLevel = DAMAGE_POWER_PLUS_ONE;
             nCurrentReduction.nRedAmount = 10;
        }

        //if it applies and prevents more damage, replace
        if(nCurrentReduction.nRedLevel > nApplicableReduction
           && nCurrentReduction.nRedAmount > nBestDamageReduction.nRedAmount)
               nBestDamageReduction = nCurrentReduction;


        eLoop=GetNextEffect(oTarget);
    }

    //now loop through items
    int nSlot;
    object oItem;
    itemproperty ipResist = ItemPropertyDamageResistance(nDamageType, IP_CONST_DAMAGERESIST_5);
    int nSubType;

        for (nSlot=0; nSlot<NUM_INVENTORY_SLOTS; nSlot++)
        {
           oItem=GetItemInSlot(nSlot, oTarget);
            if (DEBUG) DoDebug("Checking Inventory Slot: "+IntToString(nSlot));
           //check props if valid
           if(GetIsObjectValid(oItem))
           {
            if (DEBUG) DoDebug(GetName(oItem)+" is valid item in Slot: "+IntToString(nSlot));
               /*if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_RESISTANCE)
                  || GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_REDUCTION))
               {*/
                  itemproperty ipLoop=GetFirstItemProperty(oItem);

                      //Loop for as long as the ipLoop variable is valid
                      while (GetIsItemPropertyValid(ipLoop))
                      {
                            if(DEBUG) DoDebug("Item: " + GetName(oItem));
                            if(DEBUG) DoDebug("Item Property: " + IntToString(GetItemPropertyType(ipLoop)));
                            if(DEBUG) DoDebug("Item Property Subtype: " + IntToString(GetItemPropertySubType(ipLoop)));
                            if(GetItemPropertyType(ipLoop) == ITEM_PROPERTY_DAMAGE_RESISTANCE)
                            {
                                nSubType = GetItemPropertySubType(ipLoop);
                                //convert IP Const numbers to the appropriate bitmask
                                if(nSubType == 0) nSubType = 1;
                                if(nSubType == 1) nSubType = 2;
                                if(nSubType == 2) nSubType = 4;
                                //See if Damage type is in the weapon's damage type bitmask
                                if((nSubType & nDamageType) == nSubType)
                                {
                                   int nResist = 5 * GetItemPropertyCostTableValue(ipLoop);
					if(DEBUG) DoDebug("Damage type match. Damage resistance: " + IntToString(nResist));
                                   if(nResist > nBestDamageResistance) nBestDamageResistance = nResist;
                                }
                            }

                            if(GetItemPropertyType(ipLoop) == ITEM_PROPERTY_DAMAGE_REDUCTION/*
                               && GetItemPropertySubType(ipLoop) > nApplicableReduction*/)
                            {
                                int nReduce = GetItemPropertyCostTableValue(ipLoop) * 5;
                                if (nReduce > nBestDamageReduction.nRedAmount)
                                     nBestDamageReduction.nRedAmount = nReduce;
                            }

                            if(GetItemPropertyType(ipLoop) == ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE)
                            {
                                nSubType = GetItemPropertySubType(ipLoop);
                                if(nSubType == 0) nSubType = 1;
                                if(nSubType == 1) nSubType = 2;
                                if(nSubType == 2) nSubType = 4;
                                if((nSubType & nDamageType) == nSubType)
                                {
                                    int nImmune = 0;
                                    if(GetItemPropertyCostTableValue(ipLoop) == 1)
                                        nImmune = 5;
                                    else if(GetItemPropertyCostTableValue(ipLoop) == 2)
                                        nImmune = 10;
                                    else if(GetItemPropertyCostTableValue(ipLoop) == 3)
                                        nImmune = 25;
                                    else if(GetItemPropertyCostTableValue(ipLoop) == 4)
                                        nImmune = 50;
                                    else if(GetItemPropertyCostTableValue(ipLoop) == 5)
                                        nImmune = 75;
                                    else if(GetItemPropertyCostTableValue(ipLoop) == 6)
                                        nImmune = 90;
                                    else if(GetItemPropertyCostTableValue(ipLoop) == 7)
                                        nImmune = 100;

                                    if(nImmune > nBestImmunutyLevel) nBestImmunutyLevel = nImmune;
                                }
                            }

                            //Next itemproperty on the list...
                            ipLoop=GetNextItemProperty(oItem);
                      }

            //}//end item prop check

           }//end validity check
        }//end for
        if(DEBUG) DoDebug("Best Resistance: " + IntToString(nBestDamageResistance));
        if(DEBUG) DoDebug("Best Reduction: " + IntToString(nBestDamageReduction.nRedAmount));
        if(DEBUG) DoDebug("Best Percent Immune: " + IntToString(nBestImmunutyLevel));

    struct DamageReducers drOverallReduced;
    drOverallReduced.nStaticReductions = nBestDamageResistance + nBestDamageReduction.nRedAmount;
    drOverallReduced.nPercentReductions = nBestImmunutyLevel;

    return drOverallReduced;
}


// experimental: not functional
// checks the action type (to be determined by a call to GetCurrentAction()) and returns TRUE,
// if this action type is compatible with being in physical combat
// (physical combat - including touch attack spells - is the combat done by PerformAttack and PerformAttackRound)
// motu99: so far not clear, whether the categorization of the actions is sensible,
// @TODO: either comment out or comment in the appropriate line, if the categorization for a specific actions must be changed
// this function should eventually be used by AttackLoopLogic() in order to determine, whether oAttacker shall attack a new target or do nothing
//(for instance, we would do nothing when the player has decided to cast a spell, run away or do any other non physical combat action)
int GetIsPhysicalCombatAction(int iAction)
{
    switch(iAction)
    {
//      case ACTION_ANIMALEMPATHY: return TRUE;
        case ACTION_ATTACKOBJECT: return TRUE;
//      case ACTION_ANIMALEMPATHY: return TRUE;
//      case ACTION_CASTSPELL: return TRUE;
//      case ACTION_CLOSEDOOR: return TRUE;
//      case ACTION_COUNTERSPELL: return TRUE; // not clear if we can counterspell while physically attacking, probably not
//      case ACTION_DIALOGOBJECT: return TRUE;
//      case ACTION_DISABLETRAP: return TRUE;
        case ACTION_DROPITEM: return TRUE;
//      case ACTION_EXAMINETRAP: return TRUE;
//      case ACTION_FLAGTRAP: return TRUE;
//      case ACTION_FOLLOW: return TRUE;
//      case ACTION_HEAL: return TRUE;
        case ACTION_INVALID: return TRUE;
//      case ACTION_ITEMCASTSPELL: return TRUE;
        case ACTION_KIDAMAGE: return TRUE;
//      case ACTION_LOCK: return TRUE;
        case ACTION_MOVETOPOINT: return TRUE;
//      case ACTION_OPENDOOR: return TRUE;
//      case ACTION_OPENLOCK: return TRUE;
//      case ACTION_PICKPOCKET: return TRUE;
//      case ACTION_PICKUPITEM: return TRUE;
//      case ACTION_RANDOMWALK: return TRUE;
//      case ACTION_RECOVERTRAP: return TRUE;
//      case ACTION_REST: return TRUE;
//      case ACTION_SETTRAP: return TRUE;
//      case ACTION_SIT: return TRUE;
        case ACTION_SMITEGOOD: return TRUE;
        case ACTION_TAUNT: return TRUE;
//      case ACTION_USEOBJECT: return TRUE;
//      case ACTION_WAIT: return TRUE;
    }
    return FALSE;
}

float GetSizeAdjustment(object oDefender, object oAttacker)
{
    int iSize = PRCGetCreatureSize(oAttacker) - CREATURE_SIZE_MEDIUM;
//DoDebug("GetSizeAdjustment: attacker size = "+IntToString(iSize));
    if (iSize < 0)
        iSize = 0;

    int iSize2 = PRCGetCreatureSize(oDefender) - CREATURE_SIZE_MEDIUM;
//DoDebug("GetSizeAdjustment: defender size = "+IntToString(iSize2));
    if (iSize2 < 0)
        iSize2 = 0;

    // for size above medium add a meter per (size - creature_size_medium)
    return(IntToFloat(iSize+iSize2));
}

// this function is needed in order to have the aurora combat system and scripted prc combat to run smoothly in parallel
// oDefender is the target selected by the prc combat functions
// CheckForChangeOfTarget() tries to return the "best" target for the next (prc) attack
object CheckForChangeOfTarget(object oAttacker, object oDefender, int bAllowSwitchOfTarget = FALSE)
{
// First we determine the attempted (or last attacked) target (oTarget) and check if it is equal to oDefender.
// If they are not equal, the preference is on oTarget, as it was the last attempted (last attacked) target
// (oTarget most likely reflects the last actions of the aurora combat system, and this most likely reflects the human player's wishes)
// we never switch targets if it is a ranged attack, unless our preferred target (oTarget) is invalid or dead
// if we are in melee combat, we never switch targets if our preferred target (oTarget) is already in melee range
// if we are in melee combat and our preferred target is out of melee range, we switch targets if we can find another target (usually oDefender) in melee range
// if both the preferred target and the closest other target are out of melee range (and both live), we only switch targets
// when the distance to the other target is 2 feet closer than the distance to our preferred target (oTarget)

    // find the target on which we are currently attempting an attack
    object oTarget = GetAttemptedAttackTarget();

    // if dead or invalid, try the last target we actually attacked - quite likely this will be equal to GetAttemptedTarget(),
    // but it might still be worthwhile to try
    if (!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
        oTarget = GetAttackTarget(oAttacker);

    // check whether we might have to change targets
    // find the "best pick" of oDefender and oTarget and make it oTarget
    if (oTarget != oDefender)
    {
        //if (DEBUG) DoDebug(PRC_TEXT_WHITE + "PRC combat system: prc_inc_combat and aurora engine have selected different targets.");
        // our preference is for oTarget, on which we attempted the most recent attack
        // so we will return oTarget, unless
        // the attempted (or last attacked) target is invalid or dead
        if (!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
        {
            oTarget = oDefender;
        }
        // if oTarget lives, we replace oTarget only if
        else if (   bAllowSwitchOfTarget // we have allowed a switch of targets (this should never be the case for a ranged attack)
                    && !GetIsInMeleeRange(oTarget, oAttacker) // oTarget is not in melee range
                    && GetIsObjectValid(oDefender) // oDefender is valid
                    && !GetIsDead(oDefender) // oDefender lives
                    // and the distance to oDefender is more than two feet (0.67 meters) less than to oTarget
                    && GetDistanceBetween(oAttacker, oDefender) + 0.67 < GetDistanceBetween(oAttacker, oTarget) )
        {
            oTarget = oDefender;
        }
    }

    // our best pick for oTarget might still be dead
    // this would only happen, when oDefender and oTarget are both dead or invalid
    if( !GetIsObjectValid(oTarget) || GetIsDead(oTarget))
    {
        // motu99: in the original code we aborted no matter what
        // but I think we should at least try to find a valid target
        // as long as we are still attacking, it is quite natural to look for
        // new enemies and attack them, instead of just standing around, taking the
        // hits and waiting for the human player to select our target for us
/*
        // it really only makes sense to look for a new target, if we are still attacking
        // otherwise our actions will interfere with any other (non-combat) actions (such as running away, drinking potions, etc.)
        // OTOH this is a combat function, so we implicitly assume that we are still in combat
        // (we should have checked this on every entry to AttackLoopLogic() or AttackLoopMain(), therefore it is commented out here)
        if (GetCurrentAction(oAttacker) != ACTION_ATTACKOBJECT)
            return OBJECT_INVALID;
*/
        oTarget = FindNearestEnemy(oAttacker);

        // if the nearest (living) enemy is dead or invalid still, we must abort
        if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
        {
            return OBJECT_INVALID;
        }
    }
    // oTarget lives, but (s)he might be out of melee range, so find a closer target if the switch permits (and we are not doing ranged combat)
    else if (bAllowSwitchOfTarget)
    {
        // only attempt a target switch, if oTarget is not in melee range
        if (!GetIsInMeleeRange(oTarget, oAttacker))
        {
            // find the nearest enemy (this could well be oTarget)
            oDefender = FindNearestEnemy(oAttacker);

            // if oTarget is already the closest enemy, then we are finished
            if (oDefender == oTarget)
                return oTarget;

            // only makes sense to switch targets, if oDefender lives
            if (GetIsObjectValid(oDefender) && !GetIsDead(oDefender))
            {
                // if oDefender is in melee range, than that is our preferred choice
                if(GetIsInMeleeRange(oDefender, oAttacker))
                    oTarget = oDefender;

                // oTarget and oDefender are both out of melee range.
                // in this case our preference is still on oTarget! So we articially increase the distance to oDefender by 2 feet before we compare
                if (GetDistanceBetween(oAttacker, oDefender) + 0.67 <= GetDistanceBetween(oAttacker, oTarget))
                    oTarget = oDefender;
            }
        }
    }

    return oTarget;
}

// this is to cancel any other "move to location" commands
// it will not reset the combat status
// note that if you make several calls to PerformAttack() via AssignCommand(DelayCommand(fDelay, PerformAttack()))
// this might cancel any PerformAttack() actions that are still in the "pipeline"
// so better change the order to DelayCommand(fDelay, AssignCommand(PerformAttack()))
// or just don't use AssignCommand
void ClearAllActionsAndMoveToLocation(object oTarget)
{
    ClearAllActions();
    ActionMoveToLocation(GetLocation(oTarget), TRUE);
}

void ClearAllActionsAndAttack(object oTarget)
{
    ClearAllActions();
    ActionAttack(oTarget);
}

void ClearAllActionsAndMoveToObject(object oTarget, float fRange = 2.0)
{
    ClearAllActions();
    ActionMoveToObject(oTarget, TRUE, fRange);
}

void ClearAllActionsMoveToObjectAndAttack(object oTarget, float fRange = 2.0)
{
    ClearAllActions();
    ActionMoveToObject(oTarget, TRUE, fRange);
    ActionAttack(oTarget);
}

// AttackLoopLogic actually does the attack, e.g. it does all the rolls, and then calculates and applies the damage
/**
// INTERNAL LOGIC:

// AttackLoopLogic is called with the number of attacks left *after* the attack is done
// This info is needed,when we call AttackLoopMain() at the end of the AttackLoopLogic in order to schedule more attacks.
// AttackLoopLogic will *first* do the attack with the parameters given,
// it will only check iBonusAttacks, iMainhandAttacks and iOffhandAttacks later
// in order to decrement the Attack-modifier after it actually did the attack

// When doing the attack,we first make some checks (if defender is still valid) and whether we actually can attack the defender
// in order to run smoothly with the parallel running aurora system, we will select the "best" target for the next attack

// if we are in melee combat, the target is out of melee range, but a 5 foot step can bring us into range, we do the 5 foot step
// we can only do a 5 foot step once in a full combat round. If we cannot get into melee range with a 5 foot step, we cancel
// the full attack round and do a move action to the target (we do this by an ActionAttack() command, so that
// the aurora engine will initiate a new full combat round as soon as we are in melee range)

// if we found a target in range, and it is the first attack, the attacker will be put out of stealth mode or invisibility etc.
// then we check whether oDefender helpless. If so, we can coup the grace him. We forfeit all remaining attacks and try the coup

// if oAttacker does not do a coup de grace, we roll a normal attack roll
// if the attack roll hits, AttackLoopLogic applies the damage, including any special effects
// special effects can be applied to all attacks, or only to the first attack in the round.

// if we hit on our attack (and applied the damage), AttackLoopLogic determines whether it can do a circle kick
// if we can do the circle kick (e.g. have the feat, there is a different target in melee range, and we did not already do
// a circle kick in the round)  AttackLoopLogic calls itself recursively to do the circle kick

// after the attack was performed (successful or not), AttackLoopLogic checks whether the defender is dead
// if (s)he dead, AttackLoopLogic will look for a new defender

// it the new defender is in melee range (and it actually was oAttacker that killed it), we check for the
// cleave feat, and do the cleave by calling AttackLoopLogic recursively

// if the new defender is out of range, we move to it (unless we have a ranged weapon), and hope we
// are in range on the next attack

// when AttackLoopLogic has done the attack (with all associated cleave and circle kick attacks), it checks whether there are any attacks left in the round
// if so, it decrements the AB-modifier for multiple attacks and calls AttackLoopMain (with the proper delay) to schedule the next attack
*/
void AttackLoopLogic(object oDefender, object oAttacker,
    int iBonusAttacks, int iMainAttacks, int iOffHandAttacks, int iMod,
    struct AttackLoopVars sAttackVars, struct BonusDamage sMainWeaponDamage,
    struct BonusDamage sOffHandWeaponDamage, struct BonusDamage sSpellBonusDamage,
    int iOffhand, int bIsCleaveAttack)
{

    int iAction = GetCurrentAction(oAttacker);
    bFirstAttack = !sAttackVars.iAttackNumber;

    if (DEBUG) DoDebug("entered AttackLoopLogic: bFirstAttack = " + IntToString(bFirstAttack) + ", cleave = " + IntToString(bIsCleaveAttack) + ", current action = " + GetActionName(iAction));
    if (DEBUG) DoDebug("AttackLoopLogic: iMainAttacks = " + IntToString(iMainAttacks) + ", iOffHandAttacks = " + IntToString(iOffHandAttacks) + ", iBonusAttacks = " + IntToString(iBonusAttacks));

    //int bIsRangedAttack = sAttackVars.bIsRangedWeapon || sAttackVars.iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL || sAttackVars.iTouchAttackType == TOUCH_ATTACK_RANGED;
	
	int bIsRangedAttack = sAttackVars.bIsRangedWeapon || 
		sAttackVars.iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL || 
		sAttackVars.iTouchAttackType == TOUCH_ATTACK_RANGED || 
		GetLocalInt(oAttacker, "WhirlingBlade");

    // check for valid target etc., but only if it is not a cleave or circle kick (in this case we checked all of this before)
    if (!bIsCleaveAttack)
    {
        // if we are not attacking, abort (we loose all attacks which might be left in the round)
        // we only check for an abort, if we are in the heartbeat combat mode (such as natural weapon
        // attacks, or offhand attacks scheduled from a HB and running in parallel with aurora physical combat)
        if ((sAttackVars.bMode & PRC_COMBATMODE_HB))
        {
            // the following check only works, if PRC and aurora combat systems run in parallel, so that aurora sets the attack action properly
            // we check the current action, and if it is not equal to ACTION_ATTACKOBJECT or ACTION_MOVETOPOINT, we return
            // if PRC combat is to do an attack regardless of the current action state of oAttacker
            // we must set the local int "prc_action_attack" to TRUE in advance (and then delete it with a DelayCommand() after we did the attack)
            if (iAction != ACTION_ATTACKOBJECT && iAction != ACTION_MOVETOPOINT)
//          if(!GetIsPhysicalCombatAction(GetCurrentAction(oAttacker)))
            {
                if (DEBUG) DoDebug("AttackLoopLogic: current action is not ACTION_ATTACKOBJECT or ACTION_MOVETOPOINT - aborting");
                return;
            }
        }

        // now determine whether it makes sense to switch to a better target in the following function CheckForChangeOfTarget()
        // if the original target lives, we only allow a switch to a better target, if it is not a ranged attack and we set the respective PRC switch
        int bAllowSwitchOfTarget = !bIsRangedAttack && GetPRCSwitch(PRC_ALLOW_SWITCH_OF_TARGET);
        if (sAttackVars.bMode & PRC_COMBATMODE_ALLOW_TARGETSWITCH)
        {
            // now catch any changes in targeting that the parallell running aurora engine might have enforced and return the best target
            oDefender = CheckForChangeOfTarget(oAttacker, oDefender, bAllowSwitchOfTarget);
        }

        // if after all the trouble looking for a valid target we did not find one, abort the attack
        if(oDefender == OBJECT_INVALID || GetIsDead(oDefender))
        {
            if (DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: no enemies left - aborting");
            return;
        }

        // If oDefender is not within melee range and it is not a ranged attack
        // move to oDefender so that we can attack next round. We give up all remaining attacks in the round, unless we can do a 5 foot step
        if(!bIsRangedAttack && !GetIsInMeleeRange(oDefender, oAttacker))
        {
            // can we do a 5 foot step in order to get into melee range?
            float fDistance = GetDistanceBetween(oDefender, oAttacker) - GetSizeAdjustment(oDefender, oAttacker);
            if (DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: target is out of melee range, size adjusted distance = "+FloatToString(fDistance)+", size adjustment = "+FloatToString(GetSizeAdjustment(oDefender, oAttacker)));
            if (!sAttackVars.bFiveFootStep && fDistance <= RANGE_15_FEET_IN_METERS)
            {
                if (DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: waiting for aurora engine to do 5 foot step to move to melee range of " + GetName(oDefender) + ", current action: " + GetActionName(GetCurrentAction(oAttacker)));

                // motu99: The problem is, in order to move into range we must clear the attack action, otherwise the move will not be done
                // If we clear the attack action, we must issue an ActionAttack after the move
                // But this will initiate a new combat round (cutting off any attacks left from the old round)
                // The ugly workaround is to just wait and hope the aurora engine does the move for us
                // therefore the following statement is commented out
                // ClearAllActionsMoveToObjectAndAttack(oDefender, MELEE_RANGE_METERS-1.);

                sAttackVars.bFiveFootStep = TRUE; // remember that we did a five foot step

                // now call attackLoopLogic with a delay and exactly the same parameters (and hope we are in range then)
                DelayCommand(1.0,
                    AttackLoopLogic(oDefender, oAttacker, iBonusAttacks, iMainAttacks, iOffHandAttacks,
                        iMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage,
                        iOffhand, bIsCleaveAttack));
                // this return statement will not give up any pending attacks, because we called AttackLoopLogic in a DelayCommand beforehand
                return;
            }
            else if (fDistance <= fMaxAttackDistance)
            {
                // Our closest enemy is out of melee range (e.g. more than 10 feet away) and we cannot do a 5 foot step to get into range
                // This means we need a full move action, e.g. we must give up all remaining attacks in the round
                // so we call ActionAttack() in order to move to our enemy and let the aurora engine start a new combat round
                // against oDefender, whenever we are in range
                if (DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: doing full move action to get into melee range of " + GetName(oDefender) + ", current action: " + GetActionName(GetCurrentAction(oAttacker)));

                // Note that in general we do not wan't to use the ActionAttack() command within PRC combat, because this will initiate
                // a new attack round by the aurora engine. But here the rules require us to start a new combat round anyway.
                // AssignCommand(oAttacker, ClearAllActionsAndAttack(oDefender));
                ClearAllActions();
                ActionAttack(oDefender);

                // now determine whether we abort the scripted combat round, or if we just delay the next attack (and hope we are in range then)
                if (sAttackVars.bMode & PRC_COMBATMODE_ABORT_WHEN_OUT_OF_RANGE)
                {
                    // The following return statement will terminate the whole combat round
                    return;
                }
                else
                {
                    // call attackLoopLogic with a delay and exactly the same parameters (and hope we are in range then)
                    DelayCommand(1.0,
                        AttackLoopLogic(oDefender, oAttacker, iBonusAttacks, iMainAttacks, iOffHandAttacks,
                            iMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage,
                            iOffhand, bIsCleaveAttack));
                    // this return statement will not give up any pending attacks, because we called AttackLoopLogic in a DelayCommand beforehand
                    return;
                }
            }
            else
            {
                // our closest enemy is so far away, it does not make sense to attack it; just drop the attack
                if (DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: target " + GetName(oDefender) + " is too far away, current action: " + GetActionName(GetCurrentAction(oAttacker)));
                // The following return statement will terminate the whole combat round
                return;
            }
        }

        // Since we are attacking, remove sanctuary / invisibility effects.
        // Only bother to do this on the first attack...
        // as they won't have the effect anymore on subsequent iterations.
        if (bFirstAttack)
        {
            // FrikaC: Ghost strike doesn't cancel ethereal / invisible
            if( !GetLocalInt(oAttacker, "prc_ghost_strike")
                &&  (   PRCGetHasEffect(EFFECT_TYPE_INVISIBILITY, oAttacker)
                        || PRCGetHasEffect(EFFECT_TYPE_SANCTUARY, oAttacker)
                    )
            )
            { // now remove sanctuary and invisibility effects from attacker
            // if (DEBUG) DoDebug("AttackLoopLogic: remove invisibility and sanctuary");

                effect eEffect = GetFirstEffect(oAttacker);
                while (GetIsEffectValid(eEffect) )
                {
                    int iType = GetEffectType(eEffect);
                    if( iType == EFFECT_TYPE_INVISIBILITY || iType == EFFECT_TYPE_SANCTUARY )
                        // motu99: Why delay? What with instant attacks?
                        DelayCommand(0.01, RemoveEffect(oAttacker, eEffect));

                    eEffect = GetNextEffect(oAttacker);
                }
            }

            // take the player out of stealth mode
            if(GetActionMode(oAttacker, ACTION_MODE_STEALTH) )
            {
                // if (DEBUG) DoDebug("AttackLoopLogic: take attacker out of stealth mode");
                SetActionMode(oAttacker, ACTION_MODE_STEALTH, FALSE);
            }
        }
    }

    // everything is set in order to actually do the attack

    effect eDamage;
    effect eInvalid;
    string sMes = "";
    int iAttackRoll = 0;
    int bIsCritcal = FALSE;

    // set duration type of special effect based on passed value
    int iDurationType = DURATION_TYPE_INSTANT;
    if (sAttackVars.eDuration > 0.0) iDurationType = DURATION_TYPE_TEMPORARY;
    if (sAttackVars.eDuration < 0.0) iDurationType = DURATION_TYPE_PERMANENT;

    // check defender HP before attacking
    // motu99: HP check is most likely redundant, because we checked for a dead oDefender beforehand
    if(GetCurrentHitPoints(oDefender) > 0)
    {
// DoDebug("AttackLoopLogic: found living target - " + GetName(oDefender));

        // weapon variables have to be initialized for the hand that does the attack
        object oWeapon;
        int iAttackBonus;
        int iWeaponDamageRound;
        int iNumDice;
        int iNumSides;
        int iCritMult;
        struct BonusDamage sWeaponDamage;

        if (iOffhand)
        { // if attack is from left hand set vars to left hand values
            oWeapon   = sAttackVars.oWeaponL;
            iAttackBonus = sAttackVars.iOffHandAttackBonus;
            iWeaponDamageRound = sAttackVars.iOffHandWeaponDamageRound;
            iNumDice  = sAttackVars.iOffHandNumDice;
            iNumSides = sAttackVars.iOffHandNumSides;
            iCritMult = sAttackVars.iOffHandCritMult;
            sWeaponDamage = sOffHandWeaponDamage;
        }
        else
        {   // attack is from main hand, set vars to right hand values
            oWeapon   = sAttackVars.oWeaponR;
            iAttackBonus = sAttackVars.iMainAttackBonus;
            iWeaponDamageRound = sAttackVars.iMainWeaponDamageRound;
            iNumDice  = sAttackVars.iMainNumDice;
            iNumSides = sAttackVars.iMainNumSides;
            iCritMult = sAttackVars.iMainCritMult;
            sWeaponDamage = sMainWeaponDamage;
        }

        int bIsTouchAttackSpell = sAttackVars.iTouchAttackType == TOUCH_ATTACK_RANGED_SPELL || sAttackVars.iTouchAttackType == TOUCH_ATTACK_MELEE_SPELL;
        int bHasCriticalImmunity = GetIsImmune(oDefender, IMMUNITY_TYPE_CRITICAL_HIT, oAttacker);

        // will be true on any instant death effects (Coup de Grace, devastating critical)
        int bInstantKill = FALSE;

        // Coup De Grace
        // Automatic critical hit: Fort save DC: 10 + damage dealt
        // Note: The rest of the code is in GetAttackDamage
        //       this is because that part has the damage dealt in it.

        // motu99: Do we always want a coup de grace? A strong fighter might do better without (cleaving several enemies to death in a round)
        // maybe we should use a switch in order to disable automatic coup de grace?
        // this should be a switch on the PC, not the module, and we need to access it via the PRC-menu
        int bDisableCoupDeGrace = GetPRCSwitch(PRC_DISABLE_COUP_DE_GRACE);

		if (!bDisableCoupDeGrace && !GetLocalInt(oAttacker, "PactQuality"+IntToString(VESTIGE_BUER)) && GetHasSpellEffect(VESTIGE_BUER, oAttacker)) bDisableCoupDeGrace = TRUE;

        if( !bDisableCoupDeGrace
            && bFirstAttack
            && !bHasCriticalImmunity
            && GetIsHelpless(oDefender))
        {
            if(DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: attempting coup the grace");
            // make hit a crit
            iAttackRoll     = 2;

            // remove all other attacks this round
            // you give up all other attacks to make a coupe de grace
            iBonusAttacks   = 0;
            iMainAttacks    = 0;
            iOffHandAttacks = 0;

            // apply the CDG directly, if spell ability (otherwise do it in the GetDamageRoll() function)
            if(bIsTouchAttackSpell)
            {
                // DC = 10 + damage dealt.
                int iSaveDC = 10;
                int iDamage = sAttackVars.iDamageModifier;

                // if the attack effects all attacks use DAMAGE_BONUS_* const
                if(sAttackVars.bEffectAllAttacks) iDamage = GetDamageByConstant(iDamage, FALSE);

                iSaveDC += iDamage;

				if (DEBUG) DoDebug("AttackLoopLogic: coup de grace as a spell like touch attack - trying fortitude save with DC = " + IntToString(iSaveDC));
                if(!FortitudeSave(oDefender, iSaveDC, SAVING_THROW_TYPE_NONE, oAttacker) )
                {
                    sMes = "*Coup De Grace*";
                    if (DEBUG)
                    {
                        sMes = "scripted " + sMes;
						//SendMessageToPC(oAttacker, sMes);
                    }

                    FloatingTextStringOnCreature(sMes, oAttacker, FALSE);

                    // circumvents death immunity... since anyone CDG'ed is dead.
                    effect eDeath = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oDefender);
                    if (GetIsDead(oDefender))
                        bInstantKill = TRUE;
                }
            }
        } // End Coup de Grace (CDG)
        else
        {
            // if not CDG, perform normal attack roll
			if (DEBUG) DoDebug("AttackLoopLogic: do normal attack roll");
            iAttackRoll = GetAttackRoll(oDefender, oAttacker, oWeapon, iOffhand, iAttackBonus, iMod, TRUE, 0.0, sAttackVars.iTouchAttackType);
        }

        // was it a critical?
        if(iAttackRoll == 2) 
        {
        	bIsCritcal = TRUE;
            SetLocalInt(oDefender, "PRCCombat_CriticalHit", TRUE);
            DelayCommand(1.0, DeleteLocalInt(oDefender, "PRCCombat_CriticalHit"));
        }    

        // This sets a local variable on the target that is struck
        // Allows you to apply saves and such based on the success or failure
        if(bFirstAttack && iAttackRoll)
        {
            if (DEBUG) DoDebug("AttackLoopLogic: hit on first attack - setting PRC local int");
            SetLocalInt(oDefender, "PRCCombat_StruckByAttack", TRUE);
            DelayCommand(1.0, DeleteLocalInt(oDefender, "PRCCombat_StruckByAttack"));
        }

        // if critical hit and vorpal weapon, apply vorpal effect, but only if we didn't coup de grace them before
        if(!bInstantKill && bIsCritcal && bIsVorpalWeaponEquiped)
        {
            if (DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: critical hit with vorpal weapon effect - Defender must do fortitude save with DC " + IntToString(iVorpalSaveDC));
            if( !FortitudeSave(oDefender, iVorpalSaveDC, SAVING_THROW_TYPE_NONE) )
            {
                sMes = "*Vorpal Blade*";
                if (DEBUG)
                {
                    sMes = "scripted " + sMes;
					//SendMessageToPC(oAttacker, sMes);
                }
                FloatingTextStringOnCreature(sMes, oAttacker, FALSE);

                effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oDefender);

                effect eDeath = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oDefender);
                if (GetIsDead(oDefender))
                    bInstantKill = TRUE;
            }
        } // end of code for vorpal weapon

        // reset global vorpal variables
        bIsVorpalWeaponEquiped = FALSE;
        iVorpalSaveDC = 0;

        int bDoSpecialEffect = ( bFirstAttack || sAttackVars.bEffectAllAttacks );
        // now do the messages
        if(iAttackRoll)
        { // messages for *hit*
            // motu99: moved this from special effects section to here
            // Don't quite sure if the sMessageSuccess/sMessageFailure strings are only for special attacks, or all attacks
            // I would assume all. If not correct, move this code to the "special effects" section
            if(bDoSpecialEffect && sAttackVars.sMessageSuccess != "")
                FloatingTextStringOnCreature(sAttackVars.sMessageSuccess, oAttacker, FALSE);
            if (DEBUG)
                SendMessageToPC(oAttacker, sAttackVars.sMessageSuccess);

            // if this attack is a cleave attack or a circle kick
            if(bIsCleaveAttack)
            { // motu99: 3 means circle kick, 2 means great cleave, 1 is normal cleave  (don't need to check for feats twice)
                if(bIsCleaveAttack == 3)
                    sMes = "*Circle Kick Hit*";
                else if(bIsCleaveAttack == 2)
                    sMes = "*Great Cleave Hit*";
                else
                    sMes = "*Cleave Attack Hit*";

                FloatingTextStringOnCreature(sMes, oAttacker, FALSE);
            }
        }
        else  // messages for *miss*
        {
            if(bDoSpecialEffect && sAttackVars.sMessageFailure != "")
                FloatingTextStringOnCreature(sAttackVars.sMessageFailure, oAttacker, FALSE);
            if (DEBUG)  SendMessageToPC(oAttacker, sAttackVars.sMessageFailure);

            // we tried a cleave attack and missed
            if(bIsCleaveAttack)
            {
                if(bIsCleaveAttack == 3)
                    sMes = "*Circle Kick Miss*";
                else if(bIsCleaveAttack == 2)
                    sMes = "*Great Cleave Miss*";
                else
                    sMes = "*Cleave Attack Miss*";

                FloatingTextStringOnCreature(sMes, oAttacker, FALSE);
            }
        } // end of code for messages

        // now do the real stuff
        // if we hit the enemy (and did not kill it instantly by CDG or vorpal)
        if(!bInstantKill && iAttackRoll)
        {
            // only calculate damage if it is not a touch attack spell
            if  (!bIsTouchAttackSpell)
                eDamage = GetAttackDamage(oDefender, oAttacker, oWeapon, sWeaponDamage, sSpellBonusDamage, iOffhand, iWeaponDamageRound, bIsCritcal, iNumDice, iNumSides, iCritMult);
/*
            // apply the damage after a short delay
            // motu99: why delay? If we delay, we cannot check for cleave later on
            DelayCommand(0.01, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oDefender));
*/
            // apply the damage directly, unless there is none
            if (eDamage != eInvalid)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oDefender);
/*
                // apply any on hit abilities from attackers weapon to defender shortly after damage; motu99: why delay? Check for dead target (and cleave/circle kick) is useless if we apply the damage outside AttackLoopLogic
                DelayCommand(0.02,ApplyOnHitAbilities(oDefender, oAttacker, oWeapon));
*/
                // apply on hit abilities of the attackers weapon to the defendor
                ApplyOnHitAbilities(oDefender, oAttacker, oWeapon);

                // motu99: if it is a ranged attack, also apply the on hit abilities of the ammunition to the target
                // (don't know if this makes sense, but there are blessed arrows and other stuff)
                if (sAttackVars.oAmmo != OBJECT_INVALID && sAttackVars.oAmmo != oWeapon)
                    ApplyOnHitAbilities(oDefender, oAttacker, sAttackVars.oAmmo);

                // immediately apply any on hit abilities from defenders armor to attacker
                // the bioware engine applies the onhit abilities of the armor in the context of the defender; we do it in the context of the attacker (so that we can apply the abilities instantly)
                // If in the future we must do it the Bioware way, we have to use AssignCommand(oDefender, AppyOnHitAbilities(oAttacker, oDefender, oArmor)), which will apply the onhit
                // capabilities of the armor in the context of oDefender. However, AssignCommands are executed AFTER the script is finished, so this will not be an instant application
                object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oDefender);
                if( GetIsObjectValid(oArmor) )
                    ApplyOnHitAbilities(oAttacker, oDefender, oArmor);
            }

            // we hit: now do special effect (either applies to all attacks or to the first attack)
            if(bDoSpecialEffect)
            {
				if (DEBUG) DoDebug("AttackLoopLogic: looking for special effects");
                // motu99: don't know if this works with negative damage
                // if not, change "!= 0" to  "> 0"
                if(sAttackVars.iDamageModifier != 0)
                {
                    int iDamagePower;
                    int iDamage;

                    if (bIsTouchAttackSpell) // set damage power to normal for a touch spell
                        iDamagePower = DAMAGE_POWER_NORMAL;
                    else // otherwise, calculate damage power
                        iDamagePower = GetDamagePowerConstant(oWeapon, oDefender, oAttacker);

                    // if special applies only to first attack, the damage should be given directly
                    iDamage = sAttackVars.iDamageModifier;

                    // otherwise (special applies to all attacks) the damage given should be a DAMAGE_BONUS_* const
                    // motu99: don't know why this is handled so, but it says so in the description of PerformAttack(), so we do it
                    if (!bFirstAttack)
                        iDamage = GetDamageByConstant(iDamage, FALSE);
		    		//  Bypass damage reduction for effect damage if set
		    		if(GetLocalInt(oAttacker, "MoveIgnoreDR"))
		    		{
						struct DamageReducers drReduced = GetTotalReduction(oAttacker, oDefender, oWeapon);
						int nRedDR = drReduced.nStaticReductions * 100 / (100 - drReduced.nPercentReductions);
						iDamage += nRedDR;
		    			if(DEBUG) DoDebug("Damage increased by " + IntToString(nRedDR) + " to ignore DR with effects");
		    		}
                    if(DEBUG) DoDebug("AttackLoopLogic: found special effect (iDamageModifier = "+IntToString(iDamage)+") - now applying damage");

                    // apply the special effect damage
                    // motu99: maybe we should link this damage to the "normal" weapon damage?
                    effect eBonusDamage = EffectDamage(iDamage, sAttackVars.iDamageType, iDamagePower);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eBonusDamage, oDefender);
                }

                // apply any special effects
                // motu99: added check for invalid effect
                if(sAttackVars.eSpecialEffect != eInvalid)
                {
                    if (DEBUG) DoDebug("AttackLoopLogic: found special effect (eSpecialEffect) - now applying effect");
                    //struct PRCeffect eSpecialEffect = GetLocalPRCEffect(GetModule(), sAttackVars.sEffectLocalName);
                    ApplyEffectToObject(iDurationType, sAttackVars.eSpecialEffect, oDefender, sAttackVars.eDuration);
                }
            }
        } // end of code for a *hit* (iAttackRoll > 0), excluding instant kills (bInstantKill == FALSE)

        // stuff we have to do after an attack, regardless if we missed or not
        // not the first attack any more
        sAttackVars.iAttackNumber++;
        bFirstAttack = !sAttackVars.iAttackNumber;

        // Code to remove ammo from inventory after an attack is made
        if( sAttackVars.bIsRangedWeapon )
        {
			if (DEBUG) DoDebug("AttackLoopLogic: reducing ammunition");
            SetItemStackSize(sAttackVars.oAmmo, (GetItemStackSize(sAttackVars.oAmmo) - 1) );
        }

        // code for circle kick
		// DoDebug("AttackLoopLogic: check for circle kick");
        if( iAttackRoll // only if we scored a hit
            && sAttackVars.iCircleKick == 0  // only if we didn't yet do a circle kick
            && GetHasMonkWeaponEquipped(oAttacker) // we must be unarmed (or wield a kama)
            && GetHasFeat(FEAT_CIRCLE_KICK, oAttacker) ) // and we need the feat
        {
            if (DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: *hit* - now attempting circle kick");
            // Find nearest enemy creature within 10 feet
            /*
            // motu99: logic is screwed. Mostly we will be taking the second nearest creature, because we discard the nearest before looking whether it is valid and in range
            int iVal = 1;
            int bHasValidTarget = FALSE;
            int bIsWithinRange = TRUE;
            object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, iVal, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);
            while(GetIsObjectValid(oTarget) && !bHasValidTarget && bIsWithinRange )
            {
                iVal += 1;
                oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oAttacker, iVal, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, -1, -1);

                // will cause the loop to end on a valid target
                if(oTarget != oDefender && GetIsInMeleeRange(oDefender, oAttacker) )
                    bHasValidTarget = TRUE;

                // will cause the loop to end if there are no valid enemies within range
                if(!GetIsInMeleeRange(oDefender, oAttacker) )
                    bIsWithinRange = FALSE;
            }
            */
            object oCircleKickDefender = FindNearestNewEnemyWithinRange(oAttacker, oDefender);
            if( GetIsObjectValid(oCircleKickDefender)
                && !GetIsDead(oCircleKickDefender)
                && GetIsInMeleeRange(oCircleKickDefender, oAttacker) )
            {
				// DoDebug("AttackLoopLogic: found valid target for circle kick " + GetName(oCircleKickDefender));

                // remember that we did a circle kick in the round (so we cannot do any more)
                sAttackVars.iCircleKick++;
                // not sure, if circle kick comes at full AB, assumed so (if not, comment iMod in again)
                AttackLoopLogic(oDefender, oAttacker, iBonusAttacks, iMainAttacks, iOffHandAttacks, 0 /*iMod*/, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage, iOffhand, 3);
            }
            else
            {
                if(DEBUG) DoDebug("AttackLoopLogic: no valid target for circle kick");
            }
        } // end code for circle kick

    } // end of code for oDefender with hitpoints HP  > 0
    else
    {   // this stub is for any code possibly required for the case when oDefender had HP <= 0 on entry
    }

    // we are now through with the original attack sequence
    // now we check HP of enemy to see if they are alive still or not
    // note that defender could have been below 1 HP from the beginning - we can see whether we actually killed it in *this* attack, if iAttackRoll > 0
    // motu99: problem in original code was, that damage application was delayed (except for a coup de grace),
    // so we couldn't have noticed in the following checks whether they would be dead; changed that
	//if (DEBUG) DoDebug("AttackLoopLogic: check for dead enemy");
    if(!GetIsObjectValid(oDefender) || GetCurrentHitPoints(oDefender) <= 0)
    {
		//if (DEBUG) DoDebug("AttackLoopLogic: enemy dead or invalid after attack");

        // if enemy is dead find a new target (we are absolutely free in choosing a new one, so we take the closest)
        oDefender = FindNearestEnemy(oAttacker);

        // if there is no new valid target, then no more attacks
        if( !GetIsObjectValid(oDefender) || GetIsDead(oDefender))
        {
            oDefender = OBJECT_INVALID;
            if(DEBUG) DoDebug(PRC_TEXT_WHITE + "No new valid targets to attack - Aborting");
            return;
        }
        if (DEBUG) DoDebug(PRC_TEXT_WHITE+"AttackLoopLogic: old target dead or invalid, found new target - " + GetName(oDefender));

        if (!bIsRangedAttack) // if it is not a ranged attack, we check if we are in range for a cleave
        {
            if(!GetIsInMeleeRange(oDefender, oAttacker))
            {
                if (GetDistanceBetween(oDefender, oAttacker) <= fMaxAttackDistance)
                {
                    if (DEBUG) DoDebug(PRC_TEXT_WHITE+"AttackLoopLogic: new target not in melee range - move to and attack new target; current action = " + GetActionName(GetCurrentAction(oAttacker)));
                    // if no enemy is close enough, move to the nearest target and attack
                    // note that this will initiate a new combat round by the aurora engine
                    // ClearAllActionsMoveToObjectAndAttack(oDefender, MELEE_RANGE_METERS-1.);
                    ClearAllActions();
                    ActionAttack(oDefender);
                }
                else
                {
                    if (DEBUG) DoDebug(PRC_TEXT_WHITE+"AttackLoopLogic: new target not in melee range and too far away - do nothing; current action = " + GetActionName(GetCurrentAction(oAttacker)));
                }

                // motu99: commented out the return statement, because we still want to continue fighting
                // and hope that we are in melee range when the next attack within the current round actually occurs
                // returning means abort; so we forfeit any attacks that might still be left in the round!
                // However, we might have to check whether the distance is too large to be covered
                // according to PnP rules we can at most do a 5 foot step without canceling the full attack round
                // return;
            }
            else if (iAttackRoll)
            {   // we did an attack that must have killed the original defender, we are within melee range of the new defender
                // we are not wielding a ranged weapon, so we are ready to cleave, if we have the feats
				if (DEBUG) DoDebug("AttackLoopLogic: old target dead and new target in melee range - check for cleave");

                int bHasCleave = 0;
                if(GetHasFeat(FEAT_GREAT_CLEAVE, oAttacker))
                    bHasCleave = 2;
                else if(sAttackVars.iCleaveAttacks == 0 && GetHasFeat(FEAT_CLEAVE, oAttacker))
                    bHasCleave = 1;

                if(bHasCleave)
                {
                    if (DEBUG) DoDebug(PRC_TEXT_WHITE + "AttackLoopLogic: we can cleave - initiate cleave attack");
                    // perform cleave
                    // recall this function with Cleave = TRUE
                    sAttackVars.iCleaveAttacks++; // note that due to the recursive calls this does not count any subsequent cleaves in the cleave attack itself!
                    // cleave attacks come at the AB of the attack that killed the critter, so use current value of iMod
                    AttackLoopLogic(oDefender, oAttacker, iBonusAttacks, iMainAttacks, iOffHandAttacks, iMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage, iOffhand, bHasCleave);
                }
            }
        }
    }

    // we are through

    // if it was a cleave attack, return directly from the recursive call (we don't wan't to decrement iMod, nor do we want to call AttackLoopMain at this point)
    // by returning to the instance of AttackLoopLogic that called the cleave, we will eventually land in the instance of AttackLoopLogic() that initiated the cleave(s).
    // This (first) instance, however, does have bIsCleaveAttack = FALSE, so when we are eventually through with all recursive cleave attacks,
    // we will not return in that (first) instance (which would mean giving up all left over attacks in the round). Rather we check whether there are still
    // attacks left in the round and call AttackLoopMain with an appropriate delay in order to do the next one.
    if (bIsCleaveAttack)
        return;

    // now calculate whether we must decrement the attack bonus (iMod)
    if(iBonusAttacks > 0)
    {
        iBonusAttacks --;
    }
    // only decrement iMod, if we are not performing a cleave attack and are through with all bonus attacks
    //else if(iBonusAttacks < 0)
    else if (0 >= iBonusAttacks)
    {
        if (iOffHandAttacks > 0 && iMainAttacks == iOffHandAttacks)
        {
            // Has the same number of main and off-hand attacks left
            // thus the player has attacked with both main and off-hand
            // and should now have -5 to their next attack iterations.
			if (DEBUG) DoDebug("AttackLoopLogic: Decrement iMod Offhand");
            if(!sAttackVars.bUseMonkAttackMod) iMod -= 5;
            else                   iMod -= 3;
        }
        else if(iOffHandAttacks == 0)
        {
            // if iOffHandAttacks = 0  and through with all bonus attacks
            // then the player only has main hand attacks
            // thus they should have their attack decremented

            // motu99: off hand attacks should be decremented by -5, even when we wield a monk weapon. Not yet implemented, because we need different iMods for mainhand and offhand
            if(!sAttackVars.bUseMonkAttackMod) iMod -= 5;
            if (DEBUG) DoDebug("AttackLoopLogic: Decrement iMod Mainhand");
            else                   iMod -= 3;
        }
    }

    if (DEBUG) DoDebug("AttackLoopLogic: go back to main attack loop with APR penalty of " + IntToString(iMod));
    // go back to main part of loop, but only if there are still attacks left
    if (iBonusAttacks > 0 || iOffHandAttacks + iMainAttacks > 0)
        DelayCommand(sAttackVars.fDelay, AttackLoopMain(oDefender, oAttacker, iBonusAttacks, iMainAttacks, iOffHandAttacks, iMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage) );
    else if ( sAttackVars.bMode & PRC_COMBATMODE_ACTIONATTACK_ON_LAST)
        ActionAttack(oDefender);
}

void AttackLoopMain(object oDefender, object oAttacker,
    int iBonusAttacks, int iMainAttacks, int iOffHandAttacks,
    int iMod, struct AttackLoopVars sAttackVars, struct BonusDamage sMainWeaponDamage,
    struct BonusDamage sOffHandWeaponDamage, struct BonusDamage sSpellBonusDamage)
{
    if(DEBUG) DoDebug("Entered AttackLoopMain: bonus attacks = " + IntToString(iBonusAttacks)+", main attacks = "+IntToString(iMainAttacks)+", offhand attacks = "+IntToString(iOffHandAttacks));

    // ugly workaround to make this global available for other functions after a call to DelayCommand or AssignCommand
    //bUseMonkAttackMod = sAttackVars.bUseMonkAttackMod;
	
	sAttackVars.bUseMonkAttackMod = GetHasMonkWeaponEquipped(oAttacker);

    // turn off touch attack if var says it only applies to first attack
    if (sAttackVars.iAttackNumber && !sAttackVars.bApplyTouchToAll) sAttackVars.iTouchAttackType == FALSE;

    // turn off AB-mod if var says it only applies to first attack
    if (sAttackVars.iAttackNumber && !sAttackVars.bEffectAllAttacks) iMod = 0;

    // perform all bonus attacks
    if(iBonusAttacks > 0)
    {   // motu99: with perfect two weapon fighting (PTWF) there could be bonus attacks in the offhand as well!
        // however, here we are assuming that all bonus attacks are from the main hand alone
        // @TODO: find a way to implement PTWF with bonus attacks in main and offhand
        if(DEBUG) DoDebug("AttackLoopMain: Calling AttackLoopLogic - bonus");
        iBonusAttacks --;
        // note that attacklooplogic is called with attacks that are left
        AttackLoopLogic(oDefender, oAttacker, iBonusAttacks, iMainAttacks, iOffHandAttacks, iMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage, 0, FALSE);
    }
    // perform main attack, if there are at least as many main hand attacks left as off-hand attacks
    else if(iMainAttacks > 0 && iMainAttacks >= iOffHandAttacks)
    {
        if(DEBUG) DoDebug("AttackLoopMain: Calling AttackLoopLogic - main hand");
        iMainAttacks --;
        AttackLoopLogic(oDefender, oAttacker, iBonusAttacks, iMainAttacks, iOffHandAttacks, iMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage, 0, FALSE);
    }
    // if there are more offhand attacks left than mainhand attacks, do those
    else if(iOffHandAttacks > 0)
    {
        if(DEBUG) DoDebug("AttackLoopMain: Calling AttackLoopLogic - offhand");
        iOffHandAttacks --;
        AttackLoopLogic(oDefender, oAttacker, iBonusAttacks, iMainAttacks, iOffHandAttacks, iMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage, 1, FALSE);
    }
// DoDebug("Exiting AttackLoopMain:  no attacks left");
}

void PerformAttackRound(object oDefender, object oAttacker,
    effect eSpecialEffect, float eDuration = 0.0, int iAttackBonusMod = 0,
    int iDamageModifier = 0, int iDamageType = 0, int bEffectAllAttacks = FALSE,
    string sMessageSuccess = "", string sMessageFailure = "",
    int bApplyTouchToAll = FALSE, int iTouchAttackType = FALSE,
    int bInstantAttack = FALSE, int bCombatModeFlags = 0)
{
//  if (DEBUG) DoDebug("Entered PerformAttackRound");

    // create struct for attack loop logic
    struct AttackLoopVars sAttackVars;

    // store the combat mode flags
    sAttackVars.bMode = bCombatModeFlags;

    // set variables required in attack loop logic
    sAttackVars.oWeaponR = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oAttacker);
    sAttackVars.oWeaponL = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oAttacker);

    // weapon base item type of right hand weapon
    int iMainhandWeaponType = GetBaseItemType(sAttackVars.oWeaponR);

    sAttackVars.bIsRangedWeapon = GetIsRangedWeaponType(iMainhandWeaponType);
    sAttackVars.iDamageModifier = iDamageModifier;
    sAttackVars.iDamageType = iDamageType;

    sAttackVars.eSpecialEffect = eSpecialEffect;
    //post prc-effectness
    //sAttackVars.sEffectLocalName = "CombatStructEffect_"+ObjectToString(oDefender)+"_"+ObjectToString(oAttacker);
    //SetLocalPRCEffect(GetModule(), sAttackVars.sEffectLocalName, eSpecialEffect);
    //this says e but is really a float
    sAttackVars.eDuration = eDuration;
    sAttackVars.bEffectAllAttacks = bEffectAllAttacks;
    sAttackVars.bApplyTouchToAll = bApplyTouchToAll;
    sAttackVars.iTouchAttackType = iTouchAttackType;
    sAttackVars.sMessageSuccess = sMessageSuccess;
    sAttackVars.sMessageFailure = sMessageFailure;

    // are they using a two handed weapon?
    int bIsTwoHandedMeleeWeapon = GetIsTwoHandedMeleeWeaponType(iMainhandWeaponType);

    // are they unarmed?
    int bIsUnarmed = FALSE;
    if(iMainhandWeaponType == BASE_ITEM_INVALID)
        bIsUnarmed = TRUE;

    // if player is unarmed use gloves as weapon
    if(bIsUnarmed)
        sAttackVars.oWeaponR = GetItemInSlot(INVENTORY_SLOT_ARMS, oAttacker);

    int bIsUsingTwoWeapons = FALSE;
    int iOffhandWeaponType = GetBaseItemType(sAttackVars.oWeaponL);

    // is the player is using two weapons or double sided weapons?
    if(GetIsOffhandWeaponType(iOffhandWeaponType))
        bIsUsingTwoWeapons = TRUE;
    else if(GetIsDoubleSidedWeaponType(iMainhandWeaponType)) // motu99: included double sided weapons
    {
        bIsUsingTwoWeapons = TRUE;
        iOffhandWeaponType = iMainhandWeaponType;
        sAttackVars.oWeaponL = sAttackVars.oWeaponR;
    }


    // determine extra bonus damage from spells (on the attacker)
    //Now checks defender for alignment and racial type -ebonfowl
    struct BonusDamage sSpellBonusDamage = GetMagicalBonusDamage(oAttacker, oDefender);

    // structs for damage on main and offhand weapons
    struct BonusDamage sMainWeaponDamage;
    struct BonusDamage sOffHandWeaponDamage;

    // find out the number of bonus attacks from haste and spell like abilities and the penalties associated with them
    struct BonusAttacks sBonusAttacks = GetBonusAttacks(oAttacker);

    // find out last attack mode to check whether it gives us bonus attacks (and penalties)
    int iLastAttackMode = GetLastAttackMode(oAttacker);
    if( iLastAttackMode ==  COMBAT_MODE_FLURRY_OF_BLOWS || iLastAttackMode ==  COMBAT_MODE_RAPID_SHOT )
    {
        sBonusAttacks.iNumber ++;
        sBonusAttacks.iPenalty += 2;
    }

    // number of attacks with main hand
    int iMainHandAttacks = GetMainHandAttacks(oAttacker);

    // ugly workaround (GetMainHandAttacks calculated this, and returns it in the quasi-global)
    sAttackVars.bUseMonkAttackMod = bUseMonkAttackMod;

    // determine main hand attack bonus and damage that remains constant througout a round
    if (iMainHandAttacks || sBonusAttacks.iNumber)
    {
        // determine attack bonus
        sAttackVars.iMainAttackBonus = GetAttackBonus(oDefender, oAttacker, sAttackVars.oWeaponR, 0);

        // Determine physical damage per round (cached for multiple use)
        sAttackVars.iMainWeaponDamageRound = GetWeaponDamagePerRound(oDefender, oAttacker, sAttackVars.oWeaponR, 0);



        // variables that store extra damage dealt
        sMainWeaponDamage = GetWeaponBonusDamage(sAttackVars.oWeaponR, oDefender);

        if (!bIsUnarmed)
        {
            // we are using a weapon: get weapon information
            sAttackVars.iMainNumSides = StringToInt(Get2DACache("baseitems", "DieToRoll", iMainhandWeaponType));
            sAttackVars.iMainNumDice = StringToInt(Get2DACache("baseitems", "NumDice", iMainhandWeaponType));
        }
        // we are unarmed, now check if we are a monk or have a creature weapon from a PrC class. - Brawler, Shou, IoDM, etc.
        else if(GetIsUnarmedFighter(oAttacker))
        {
            int iDamage = FindUnarmedDamage(oAttacker);
            sAttackVars.iMainNumSides = StringToInt(Get2DACache("iprp_monstcost", "Die", iDamage));
            sAttackVars.iMainNumDice  = StringToInt(Get2DACache("iprp_monstcost", "NumDice", iDamage));
        }
        // we are unarmed and not a monk or a PrC class with a creature weapon
        // so we use normal fists
        else
        {
            sAttackVars.iMainNumSides = 3;
            sAttackVars.iMainNumDice  = 1;
        }
        sAttackVars.iMainCritMult = GetWeaponCritcalMultiplier(oAttacker, sAttackVars.oWeaponR);
    }

    // off-hand variables
    int iOffHandAttacks = 0;

/* motu99: these are zero anyway
    sAttackVars.iOffHandAttackBonus = 0;
    sAttackVars.iOffHandWeaponDamageRound = 0;
    sAttackVars.iOffHandNumSides = 0;
    sAttackVars.iOffHandNumDice = 0;
    sAttackVars.iOffHandCritMult = 0;
*/

    // only run offhand code if using two weapons
    if(bIsUsingTwoWeapons)
    {
        iOffHandAttacks = GetOffHandAttacks(oAttacker);

        // check if double sided weapon
        if (iMainHandAttacks && sAttackVars.oWeaponL == sAttackVars.oWeaponR)
        {
            // double sided weapon: Just copy from main hand (but beware that AB -4 if no ambidex feat!)
            sAttackVars.iOffHandAttackBonus = sAttackVars.iMainAttackBonus;
            if (!GetHasFeat(FEAT_AMBIDEXTERITY, oAttacker))
                sAttackVars.iOffHandAttackBonus -= 4;
            sOffHandWeaponDamage = sMainWeaponDamage;
            sAttackVars.iOffHandWeaponDamageRound = sAttackVars.iMainWeaponDamageRound;

            sAttackVars.iOffHandNumSides = sAttackVars.iMainNumSides;
            sAttackVars.iOffHandNumDice = sAttackVars.iMainNumDice;
            sAttackVars.iOffHandCritMult = sAttackVars.iMainCritMult;
        }
        else // any other (non double sided) weapon: calculate
        {
            sAttackVars.iOffHandAttackBonus = GetAttackBonus(oDefender, oAttacker, sAttackVars.oWeaponL, 1);
            sOffHandWeaponDamage = GetWeaponBonusDamage(sAttackVars.oWeaponL, oDefender);
            sAttackVars.iOffHandWeaponDamageRound = GetWeaponDamagePerRound(oDefender, oAttacker, sAttackVars.oWeaponL, 1);

            sAttackVars.iOffHandNumSides = StringToInt(Get2DACache("baseitems", "DieToRoll", iOffhandWeaponType));
            sAttackVars.iOffHandNumDice = StringToInt(Get2DACache("baseitems", "NumDice", iOffhandWeaponType));
            sAttackVars.iOffHandCritMult = GetWeaponCritcalMultiplier(oAttacker, sAttackVars.oWeaponL);
        }
    }

    // Code to equip new ammo
    // Equips new ammo if they don't have enough ammo for the whole attack round
    // or if they have no ammo equipped.
    if(!sAttackVars.bIsRangedWeapon)
    {
        sAttackVars.oAmmo = OBJECT_INVALID;
    }
    else
    {
        sAttackVars.oAmmo = GetAmmunitionFromWeapon(sAttackVars.oWeaponR, oAttacker);

        // if there is no ammunition search inventory for ammo
        if( sAttackVars.oAmmo == OBJECT_INVALID
            || GetItemStackSize(sAttackVars.oAmmo) <= (iMainHandAttacks + sBonusAttacks.iNumber +1) )
        {
            sAttackVars.oAmmo = EquipAmmunition(oAttacker);
        }

        struct BonusDamage sAmmoDamage = GetWeaponBonusDamage(sAttackVars.oAmmo, oDefender);

        // if these values are better than the weapon, then use these.
        if(sAmmoDamage.dam_Acid > sMainWeaponDamage.dam_Acid) sMainWeaponDamage.dam_Acid = sAmmoDamage.dam_Acid;
        if(sAmmoDamage.dam_Cold > sMainWeaponDamage.dam_Cold) sMainWeaponDamage.dam_Cold = sAmmoDamage.dam_Cold;
        if(sAmmoDamage.dam_Fire > sMainWeaponDamage.dam_Fire) sMainWeaponDamage.dam_Fire = sAmmoDamage.dam_Fire;
        if(sAmmoDamage.dam_Elec > sMainWeaponDamage.dam_Elec) sMainWeaponDamage.dam_Elec = sAmmoDamage.dam_Elec;
        if(sAmmoDamage.dam_Son  > sMainWeaponDamage.dam_Son)  sMainWeaponDamage.dam_Son  = sAmmoDamage.dam_Son;

        if(sAmmoDamage.dam_Div > sMainWeaponDamage.dam_Div) sMainWeaponDamage.dam_Div = sAmmoDamage.dam_Div;
        if(sAmmoDamage.dam_Neg > sMainWeaponDamage.dam_Neg) sMainWeaponDamage.dam_Neg = sAmmoDamage.dam_Neg;
        if(sAmmoDamage.dam_Pos > sMainWeaponDamage.dam_Pos) sMainWeaponDamage.dam_Pos = sAmmoDamage.dam_Pos;

        if(sAmmoDamage.dam_Mag > sMainWeaponDamage.dam_Mag) sMainWeaponDamage.dam_Mag = sAmmoDamage.dam_Mag;

        if(sAmmoDamage.dam_Blud > sMainWeaponDamage.dam_Blud) sMainWeaponDamage.dam_Blud = sAmmoDamage.dam_Blud;
        if(sAmmoDamage.dam_Pier > sMainWeaponDamage.dam_Pier) sMainWeaponDamage.dam_Pier = sAmmoDamage.dam_Pier;
        if(sAmmoDamage.dam_Slash > sMainWeaponDamage.dam_Slash) sMainWeaponDamage.dam_Slash = sAmmoDamage.dam_Slash;

        if(sAmmoDamage.dice_Acid > sMainWeaponDamage.dice_Acid) sMainWeaponDamage.dice_Acid = sAmmoDamage.dice_Acid;
        if(sAmmoDamage.dice_Cold > sMainWeaponDamage.dice_Cold) sMainWeaponDamage.dice_Cold = sAmmoDamage.dice_Cold;
        if(sAmmoDamage.dice_Fire > sMainWeaponDamage.dice_Fire) sMainWeaponDamage.dice_Fire = sAmmoDamage.dice_Fire;
        if(sAmmoDamage.dice_Elec > sMainWeaponDamage.dice_Elec) sMainWeaponDamage.dice_Elec = sAmmoDamage.dice_Elec;
        if(sAmmoDamage.dice_Son  > sMainWeaponDamage.dice_Son)  sMainWeaponDamage.dice_Son  = sAmmoDamage.dice_Son;

        if(sAmmoDamage.dice_Div > sMainWeaponDamage.dice_Div) sMainWeaponDamage.dice_Div = sAmmoDamage.dice_Div;
        if(sAmmoDamage.dice_Neg > sMainWeaponDamage.dice_Neg) sMainWeaponDamage.dice_Neg = sAmmoDamage.dice_Neg;
        if(sAmmoDamage.dice_Pos > sMainWeaponDamage.dice_Pos) sMainWeaponDamage.dice_Pos = sAmmoDamage.dice_Pos;

        if(sAmmoDamage.dice_Mag > sMainWeaponDamage.dice_Mag) sMainWeaponDamage.dice_Mag = sAmmoDamage.dice_Mag;

        if(sAmmoDamage.dice_Blud > sMainWeaponDamage.dice_Blud) sMainWeaponDamage.dice_Blud = sAmmoDamage.dice_Blud;
        if(sAmmoDamage.dice_Pier > sMainWeaponDamage.dice_Pier) sMainWeaponDamage.dice_Pier = sAmmoDamage.dice_Pier;
        if(sAmmoDamage.dice_Slash > sMainWeaponDamage.dice_Slash) sMainWeaponDamage.dice_Slash = sAmmoDamage.dice_Slash;
    }

    sAttackVars.iMainAttackBonus -= sBonusAttacks.iPenalty;
    sAttackVars.iOffHandAttackBonus -= sBonusAttacks.iPenalty;

    // determines the delay between effect application
    // to make the system run like the normal combat system.
    if(bInstantAttack)// If the full attack is to happen at once
        sAttackVars.fDelay = 0.075; // Have some delay in order to avoid being a total resource hog
    else
        sAttackVars.fDelay = (5.5 / (iMainHandAttacks + sBonusAttacks.iNumber + iOffHandAttacks));

    // sets iMods to iAttackBonusMod
    // used in AttackLoopLogic to decrement attack bonus for attacks.
    int iMod = 0;
    iMod += iAttackBonusMod;

    // motu99: where do we set the global bFirstAttack and the other global variables ? Shouldn't we set them here?
    // Or are they initialized whenever the main() function that calls PerformAttack() or PerformAttackRound() is entered?
    // (In this case they would be like local ints attached to the PC or the module, whoever is the caller if the main() function)
    AttackLoopMain(oDefender, oAttacker, sBonusAttacks.iNumber, iMainHandAttacks, iOffHandAttacks, iMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage);
}

// changed Default of nHandednessOverride = 0 (was -1), which means that on default we *now* do a *mainhand* attack;
// only with nHandednessOverride = TRUE (explicitly set) we *now* do an offhand attack
// in the old version, defaulting this variable to -1 was highly confusing (and caused more incorrect calls to PerformAttack than correct ones)
// therefore it seemed justified to change the calling logic of this function
// @TODO: check if all calls to PerformAttack are correct with respect to mainhand/offhand attacks
void PerformAttack(object oDefender, object oAttacker,
    effect eSpecialEffect, float eDuration = 0.0, int iAttackBonusMod = 0,
    int iDamageModifier = 0, int iDamageType = 0,
    string sMessageSuccess = "", string sMessageFailure = "",
    int iTouchAttackType = FALSE,
    object oRightHandOverride = OBJECT_INVALID, object oLeftHandOverride = OBJECT_INVALID,
    int nHandednessOverride = 0, int bCombatModeFlags = 0)
{
//  if (DEBUG) DoDebug("Entered PerformAttack");

    // create struct for attack loop logic
    struct AttackLoopVars sAttackVars;

    // store the combat mode flags
    sAttackVars.bMode = bCombatModeFlags;

    // set variables required in attack loop logic
    // first for right hand
    if (oRightHandOverride == OBJECT_INVALID)
        sAttackVars.oWeaponR = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oAttacker);
    else
        sAttackVars.oWeaponR = oRightHandOverride;

    // now for left hand
    if (oLeftHandOverride == OBJECT_INVALID)
        sAttackVars.oWeaponL = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oAttacker);
    else
        sAttackVars.oWeaponL = oLeftHandOverride;

    // weapon base item type of right hand weapon
    int iMainhandWeaponType = GetBaseItemType(sAttackVars.oWeaponR);
    sAttackVars.bIsRangedWeapon = GetIsRangedWeaponType(iMainhandWeaponType);
    sAttackVars.iDamageModifier = iDamageModifier;
    sAttackVars.iDamageType = iDamageType;

    sAttackVars.eSpecialEffect = eSpecialEffect;
    //post prc-effectness
    //sAttackVars.sEffectLocalName = "CombatStructEffect_"+ObjectToString(oDefender)+"_"+ObjectToString(oAttacker);
    //SetLocalPRCEffect(GetModule(), sAttackVars.sEffectLocalName, eSpecialEffect);
    //this says e but is really a float
    sAttackVars.eDuration = eDuration;
    sAttackVars.bEffectAllAttacks = FALSE; // not really necessary, because default value of int in struct is false
    sAttackVars.bApplyTouchToAll = FALSE; // not really necessary, because default value of int in struct is false
    sAttackVars.iTouchAttackType = iTouchAttackType;
    sAttackVars.sMessageSuccess = sMessageSuccess;
    sAttackVars.sMessageFailure = sMessageFailure;

    // are they using a two handed weapon?
    int bIsTwoHandedMeleeWeapon = GetIsTwoHandedMeleeWeaponType(iMainhandWeaponType);

    // are they unarmed?
    int bIsUnarmed = FALSE;
    if(iMainhandWeaponType == BASE_ITEM_INVALID)
    {
        bIsUnarmed = TRUE;
        // if player is unarmed use gloves as weapon
        sAttackVars.oWeaponR = GetItemInSlot(INVENTORY_SLOT_ARMS, oAttacker);
    }

    int bIsUsingTwoWeapons = FALSE;
    int iOffhandWeaponType = GetBaseItemType(sAttackVars.oWeaponL);

    // is the player is using two weapons or double sided weapons?
    if(GetIsOffhandWeaponType(iOffhandWeaponType)) // motu99: this could also be a (secondary) creature weapon
        bIsUsingTwoWeapons = TRUE;
    else if(GetIsDoubleSidedWeaponType(iMainhandWeaponType)) // motu99: included double sided weapons
    {
        bIsUsingTwoWeapons = TRUE;
        iOffhandWeaponType = iMainhandWeaponType;
        sAttackVars.oWeaponL = sAttackVars.oWeaponR;
    }

    int iMainHandAttacks = 0;
    int iOffHandAttacks = 0;

    // number of attacks with main hand
    if(nHandednessOverride)
    {
        // sanity checks
        if (!bIsUsingTwoWeapons)
        {
            DoDebug("PerformAttack: offhand attack, but no offhand weapon wielded - aborting");
            return;
        }
        iOffHandAttacks = 1;
    }
    else
        iMainHandAttacks = 1;

    // determine extra bonus damage from spells (on the attacker)
    //Now checks the defender for racial type and alignment bonus damage -ebonfowl
    struct BonusDamage sSpellBonusDamage = GetMagicalBonusDamage(oAttacker, oDefender);

    // structs for damage on main and offhand weapons
    struct BonusDamage sMainWeaponDamage;
    struct BonusDamage sOffHandWeaponDamage;

    // find out the number of bonus attacks from haste and spell like abilities and the penalties associated with them
    // we only need the penalties here!
    struct BonusAttacks sBonusAttacks = GetBonusAttacks(oAttacker);

// DoDebug("PerformAttack() found bonus attacks = " + IntToString(sBonusAttacks.iNumber) + " with penalty " + IntToString(sBonusAttacks.iPenalty));

    // find out last attack mode to check whether it gives us bonus attacks (and penalties)
    int iLastAttackMode = GetLastAttackMode(oAttacker);
    if( iLastAttackMode ==  COMBAT_MODE_FLURRY_OF_BLOWS || iLastAttackMode ==  COMBAT_MODE_RAPID_SHOT )
    {
        sBonusAttacks.iNumber ++;
        sBonusAttacks.iPenalty += 2;
    }


    // determine main hand attack bonus and damage that remains constant througout a round
    if (iMainHandAttacks)
    {
        // motu99: all the following three variables do *not* remain constant during the round, because they depend on the defender, and the defender can change

        // determine attack bonus
        sAttackVars.iMainAttackBonus = GetAttackBonus(oDefender, oAttacker, sAttackVars.oWeaponR, 0);

        // Determine physical damage per round (cached for multiple use)
        sAttackVars.iMainWeaponDamageRound = GetWeaponDamagePerRound(oDefender, oAttacker, sAttackVars.oWeaponR, 0);

        // variables that store extra damage dealt
        sMainWeaponDamage = GetWeaponBonusDamage(sAttackVars.oWeaponR, oDefender);

        if (!bIsUnarmed)
        {
            // we are using a weapon: get weapon information

            // through the overrides we could have been passed a creature weapon as main hand weapon
            // (creature weapons usually are equipped in the "special" CWEAPON_R/L/B inventory slots)
            if (GetIsCreatureWeaponType(iMainhandWeaponType))
            {
                struct Dice sDice;
                sDice = GetWeaponMonsterDamage(sAttackVars.oWeaponR);
                sAttackVars.iMainNumSides = sDice.iSides;
                sAttackVars.iMainNumDice = sDice.iNum;
            }
            else
            {   // we are wielding a "normal" weapon
                sAttackVars.iMainNumSides = StringToInt(Get2DACache("baseitems", "DieToRoll", iMainhandWeaponType));
                sAttackVars.iMainNumDice = StringToInt(Get2DACache("baseitems", "NumDice", iMainhandWeaponType));
            }
        }
        // we are unarmed, now check if we are a monk or have a creature weapon from a PrC class. - Brawler, Shou, IoDM, etc.
        else if(GetIsUnarmedFighter(oAttacker))
        {
            int iDamage = FindUnarmedDamage(oAttacker);
            sAttackVars.iMainNumSides = StringToInt(Get2DACache("iprp_monstcost", "Die", iDamage));
            sAttackVars.iMainNumDice  = StringToInt(Get2DACache("iprp_monstcost", "NumDice", iDamage));
        }
        // we are unarmed and not a monk or a PrC class with a creature weapon
        // so we use normal fists
        else
        {
            sAttackVars.iMainNumSides = 3;
            sAttackVars.iMainNumDice  = 1;
        }
        sAttackVars.iMainCritMult = GetWeaponCritcalMultiplier(oAttacker, sAttackVars.oWeaponR);

    }

    // only run if off hand attack
    if(iOffHandAttacks)
    {
        sAttackVars.iOffHandAttackBonus = GetAttackBonus(oDefender, oAttacker, sAttackVars.oWeaponL, 1);
        sOffHandWeaponDamage = GetWeaponBonusDamage(sAttackVars.oWeaponL, oDefender);
        sAttackVars.iOffHandWeaponDamageRound = GetWeaponDamagePerRound(oDefender, oAttacker, sAttackVars.oWeaponL, 1);

        // we are using a weapon: get weapon information
        if (GetIsCreatureWeaponType(iOffhandWeaponType))
        {
            // if we were passed a creature weapon, we need to do a special calculation
            struct Dice sDice;
            sDice = GetWeaponMonsterDamage(sAttackVars.oWeaponL);
            sAttackVars.iOffHandNumSides = sDice.iSides;
            sAttackVars.iOffHandNumDice = sDice.iNum;
        }
        else
        {
            // we are wielding a "normal" offhand weapon
            sAttackVars.iOffHandNumSides = StringToInt(Get2DACache("baseitems", "DieToRoll", iOffhandWeaponType));
            sAttackVars.iOffHandNumDice = StringToInt(Get2DACache("baseitems", "NumDice", iOffhandWeaponType));
        }

        sAttackVars.iOffHandCritMult = GetWeaponCritcalMultiplier(oAttacker, sAttackVars.oWeaponL);
// DoDebug("PerformAttack() found offhand weapon damage " + IntToString(sAttackVars.iOffHandNumDice) + "d" + IntToString(sAttackVars.iOffHandNumSides) + " with crit mult: " + IntToString(sAttackVars.iOffHandCritMult));
    }

    // Code to equip new ammo
    // Equips new ammo if they don't have enough ammo for the whole attack round
    // or if they have no ammo equipped.
    if(!sAttackVars.bIsRangedWeapon)
    {
        sAttackVars.oAmmo = OBJECT_INVALID;
    }
    else // we have a ranged weapon: this can only be a main hand attack
    {
        if (iOffHandAttacks)
        {
            DoDebug("PerformAttack: offhand attack while using a ranged weapon - aborting");
            return;
        }
        sAttackVars.oAmmo = GetAmmunitionFromWeapon(sAttackVars.oWeaponR, oAttacker);

        // if there is no ammunition search inventory for ammo
        if( sAttackVars.oAmmo == OBJECT_INVALID
            || GetItemStackSize(sAttackVars.oAmmo) <= 2)
        {
            sAttackVars.oAmmo = EquipAmmunition(oAttacker);
        }

        // note that this does not include any on hit properties of the ammunition
        // we take care of these in AttackLoopLogic
        struct BonusDamage sAmmoDamage = GetWeaponBonusDamage(sAttackVars.oAmmo, oDefender);

        // if these values are better than the weapon, then use these.
        if(sAmmoDamage.dam_Acid > sMainWeaponDamage.dam_Acid) sMainWeaponDamage.dam_Acid = sAmmoDamage.dam_Acid;
        if(sAmmoDamage.dam_Cold > sMainWeaponDamage.dam_Cold) sMainWeaponDamage.dam_Cold = sAmmoDamage.dam_Cold;
        if(sAmmoDamage.dam_Fire > sMainWeaponDamage.dam_Fire) sMainWeaponDamage.dam_Fire = sAmmoDamage.dam_Fire;
        if(sAmmoDamage.dam_Elec > sMainWeaponDamage.dam_Elec) sMainWeaponDamage.dam_Elec = sAmmoDamage.dam_Elec;
        if(sAmmoDamage.dam_Son  > sMainWeaponDamage.dam_Son)  sMainWeaponDamage.dam_Son  = sAmmoDamage.dam_Son;

        if(sAmmoDamage.dam_Div > sMainWeaponDamage.dam_Div) sMainWeaponDamage.dam_Div = sAmmoDamage.dam_Div;
        if(sAmmoDamage.dam_Neg > sMainWeaponDamage.dam_Neg) sMainWeaponDamage.dam_Neg = sAmmoDamage.dam_Neg;
        if(sAmmoDamage.dam_Pos > sMainWeaponDamage.dam_Pos) sMainWeaponDamage.dam_Pos = sAmmoDamage.dam_Pos;

        if(sAmmoDamage.dam_Mag > sMainWeaponDamage.dam_Mag) sMainWeaponDamage.dam_Mag = sAmmoDamage.dam_Mag;

        if(sAmmoDamage.dam_Blud > sMainWeaponDamage.dam_Blud) sMainWeaponDamage.dam_Blud = sAmmoDamage.dam_Blud;
        if(sAmmoDamage.dam_Pier > sMainWeaponDamage.dam_Pier) sMainWeaponDamage.dam_Pier = sAmmoDamage.dam_Pier;
        if(sAmmoDamage.dam_Slash > sMainWeaponDamage.dam_Slash) sMainWeaponDamage.dam_Slash = sAmmoDamage.dam_Slash;

        if(sAmmoDamage.dice_Acid > sMainWeaponDamage.dice_Acid) sMainWeaponDamage.dice_Acid = sAmmoDamage.dice_Acid;
        if(sAmmoDamage.dice_Cold > sMainWeaponDamage.dice_Cold) sMainWeaponDamage.dice_Cold = sAmmoDamage.dice_Cold;
        if(sAmmoDamage.dice_Fire > sMainWeaponDamage.dice_Fire) sMainWeaponDamage.dice_Fire = sAmmoDamage.dice_Fire;
        if(sAmmoDamage.dice_Elec > sMainWeaponDamage.dice_Elec) sMainWeaponDamage.dice_Elec = sAmmoDamage.dice_Elec;
        if(sAmmoDamage.dice_Son  > sMainWeaponDamage.dice_Son)  sMainWeaponDamage.dice_Son  = sAmmoDamage.dice_Son;

        if(sAmmoDamage.dice_Div > sMainWeaponDamage.dice_Div) sMainWeaponDamage.dice_Div = sAmmoDamage.dice_Div;
        if(sAmmoDamage.dice_Neg > sMainWeaponDamage.dice_Neg) sMainWeaponDamage.dice_Neg = sAmmoDamage.dice_Neg;
        if(sAmmoDamage.dice_Pos > sMainWeaponDamage.dice_Pos) sMainWeaponDamage.dice_Pos = sAmmoDamage.dice_Pos;

        if(sAmmoDamage.dice_Mag > sMainWeaponDamage.dice_Mag) sMainWeaponDamage.dice_Mag = sAmmoDamage.dice_Mag;

        if(sAmmoDamage.dice_Blud > sMainWeaponDamage.dice_Blud) sMainWeaponDamage.dice_Blud = sAmmoDamage.dice_Blud;
        if(sAmmoDamage.dice_Pier > sMainWeaponDamage.dice_Pier) sMainWeaponDamage.dice_Pier = sAmmoDamage.dice_Pier;
        if(sAmmoDamage.dice_Slash > sMainWeaponDamage.dice_Slash) sMainWeaponDamage.dice_Slash = sAmmoDamage.dice_Slash;
    }

    // determines the delay between effect application
    // to make the system run like the normal combat system.
    sAttackVars.fDelay = 0.1;
    sAttackVars.iMainAttackBonus -= sBonusAttacks.iPenalty;
    sAttackVars.iOffHandAttackBonus -= sBonusAttacks.iPenalty;

    if(nHandednessOverride)
        AttackLoopMain(oDefender, oAttacker, 0, 0, 1, iAttackBonusMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage);
    else
        AttackLoopMain(oDefender, oAttacker, 0, 1, 0, iAttackBonusMod, sAttackVars, sMainWeaponDamage, sOffHandWeaponDamage, sSpellBonusDamage);
}

//:: void main (){}