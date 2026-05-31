/*
   ----------------
   prc_inc_spells
   ----------------

   7/25/04 by WodahsEht

   Contains many useful functions for determining caster level, mostly.  The goal
   is to consolidate all caster level functions to this -- existing caster level
   functions will be wrapped around the main function.

   In the future, all new PrC's that add to caster levels should be added to
   the GetArcanePRCLevels and GetDivinePRCLevels functions.  Very little else should
   be necessary, except when new casting feats are created.
*/

//:: Updated for .35 by Jaysyn 2023/03/10

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Returns a linked effect bundle containing Shadowlord ultravision,
 * visual feedback effects, and concealment for higher Shadowlord levels.
 *
 * @param iShadow
 *        Shadowlord level of the target creature.
 *
 * @param eBaseEffect
 *        Existing linked effect bundle to append effects to.
 *        Typically ePnP, eLink, or eLink2.
 *
 * @return
 *        Updated linked effect bundle containing:
 *        - Ultravision
 *        - Ultravision icon
 *        - Magical sight visuals
 *        - Positive effect visuals
 *        - 20% concealment at Shadowlord level 2+
 */
effect ShadowlordEffects(int iShadow, effect eBaseEffect);


//:: Calculates total Shield AC bonuses from all sources
int GetTotalShieldACBonus(object oCreature);

//:: Handles psuedo-Foritifcation
void DoFortification(object oPC = OBJECT_SELF, int nFortification = 25);

/**
 * Adjusts the base class level (NOT caster level) of the class by any spellcasting PrCs
 * @param nClass a base casting class (divine or arcane)
 * @return The level of the class, adjusted for any appropriate PrC levels
 */
int GetPrCAdjustedClassLevel(int nClass, object oCaster = OBJECT_SELF);

/**
 * Adjusts the base caster level of the class by any spellcasting PrCs plus Practised Spellcasting feats if appropriate
 * @param nClass a base casting class
 * @param bAdjustForPractisedSpellcaster add practiced spellcaster feat to caster level. TRUE by default
 * @return the caster level in the class, adjusted by any PrC levels and practised spellcaster feats as appropriate
 */
int GetPrCAdjustedCasterLevel(int nClassType, object oCaster = OBJECT_SELF, int bAdjustForPractisedSpellcaster = TRUE);

/**
 * finds the highest arcane or divine caster level, adjusting the base caster level of the class by any
 * spellcasting PrCs plus Practised Spellcasting feats if appropriate
 * @param nClassType TYPE_DIVINE or TYPE_ARCANE
 * @param bAdjustForPractisedSpellcaster add practiced spellcaster feat to caster level. TRUE by default
 * @return the highest arcane/divine caster level adjusted by any PrC levels and practised spellcaster feats as appropriate
 */
int GetPrCAdjustedCasterLevelByType(int nClassType, object oCaster = OBJECT_SELF, int bAdjustForPractisedSpellcaster = TRUE);

// Returns the best "feat-adjusted" arcane levels of the PC in question.
// Considers feats that situationally adjust caster level.
int GetLevelByTypeArcaneFeats(object oCaster = OBJECT_SELF, int iSpellID = -1);

// Returns the best "feat-adjusted" divine levels of the PC in question.
// Considers feats that situationally adjust caster level.
int GetLevelByTypeDivineFeats(object oCaster = OBJECT_SELF, int iSpellID = -1);

//Returns Reflex Adjusted Damage. Is a wrapper function that allows the
//DC to be adjusted based on conditions that cannot be done using iprops
//such as saves vs spellschools, or other adjustments
int PRCGetReflexAdjustedDamage(int nDamage, object oTarget, int nDC, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus=OBJECT_SELF);

//Is a wrapper function that allows the DC to be adjusted based on conditions
//that cannot be done using iprops, such as saves vs spellschool.
//If bImmunityCheck == FALSE: returns 0 if failure or immune, 1 if success - same as MySavingThrow
//If bImmunityCheck == TRUE:  returns 0 if failure, 1 if success, 2 if immune
int PRCMySavingThrow(int nSavingThrow, object oTarget, int nDC, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0, int bImmunityCheck = FALSE);

// Finds caster levels by specific types (see the constants below).
int GetCasterLvl(int iTypeSpell, object oCaster = OBJECT_SELF);

//  Calculates bonus damage to a spell for Spell Betrayal Ability
int SpellBetrayalDamage(object oTarget, object oCaster);

//  Calculates damage to a spell for Spellstrike Ability
int SpellStrikeDamage(object oTarget, object oCaster);

// Create a Damage effect
// - oTarget: spell target
// - nDamageAmount: amount of damage to be dealt. This should be applied as an
//   instantaneous effect.
// - nDamageType: DAMAGE_TYPE_*
// - nDamagePower: DAMAGE_POWER_*
// Used to add Warmage's Edge to spells.
effect PRCEffectDamage(object oTarget, int nDamageAmount, int nDamageType=DAMAGE_TYPE_MAGICAL, int nDamagePower=DAMAGE_POWER_NORMAL, int nMetaMagic=METAMAGIC_NONE);

/**
 * Adds damage to all arcane spells based on the number of dice
 */
int SpellDamagePerDice(object oCaster, int nDice);

int IsSpellDamageElemental(int nDamageType);

// Get altered damage type for energy sub feats.
//      nDamageType - The DAMAGE_TYPE_xxx constant of the damage. All types other
//          than elemental damage types are ignored.
//      oCaster - caster object.
// moved from spinc_common, possibly somewhat redundant
int PRCGetElementalDamageType(int nDamageType, object oCaster = OBJECT_SELF);

//  Adds the bonus damage from both Spell Betrayal and Spellstrike together
int ApplySpellBetrayalStrikeDamage(object oTarget, object oCaster, int bShowTextString = TRUE);

// wrapper for DecrementRemainingSpellUses, works for newspellbook 'fake' spells too
void PRCDecrementRemainingSpellUses(object oCreature, int nSpell);

/**
 * Determines and applies the alignment shift for using spells/powers with the
 * [Evil] descriptor.  The amount of adjustment is equal to the square root of
 * the caster's distance from pure evil.
 * In other words, the amount of shift is higher the farther the caster is from
 * pure evil, with the extremes being 10 points of shift at pure good and 0
 * points of shift at pure evil.
 *
 * Does nothing if the PRC_SPELL_ALIGNMENT_SHIFT switch is not set.
 *
 * @param oPC The caster whose alignment to adjust
 */
//void SPEvilShift(object oPC);

/**
 * Determines and applies the alignment shift for using spells/powers with the
 * [Good] descriptor.  The amount of adjustment is equal to the square root of
 * the caster's distance from pure good.
 * In other words, the amount of shift is higher the farther the caster is from
 * pure good, with the extremes being 10 points of shift at pure evil and 0
 * points of shift at pure good.
 *
 * Does nothing if the PRC_SPELL_ALIGNMENT_SHIFT switch is not set.
 *
 * @param oPC The caster whose alignment to adjust
 */
//void SPGoodShift(object oPC);

/**
 * Applies the corruption cost for Corrupt spells.
 *
 * @param oPC      The caster of the Corrupt spell
 * @param oTarget  The target of the spell.
 *                 Not used for anything, should probably remove - Ornedan
 * @param nAbility ABILITY_* of the ability to apply the cost to
 * @param nCost    The amount of stat damage or drain to apply
 * @param bDrain   If this is TRUE, the cost is applied as ability drain.
 *                 If FALSE, as ability damage.
 */
void DoCorruptionCost(object oPC, int nAbility, int nCost, int bDrain);

// This function is used in the spellscripts
// It functions as Evasion for Fortitude and Will partial saves
// This means the "partial" section is ignored
// nSavingThrow takes either SAVING_THROW_WILL or SAVING_THROW_FORT
int GetHasMettle(object oTarget, int nSavingThrow = SAVING_THROW_WILL);

// Applies all of the effects needed to set a creature incorporeal
// You need to set the creature incorporeal in the feat/spell/effect itself if using nPermanent = TRUE
// nSuperOrEx: 0 is normal, 1 is Supernatural, 2 is Extraordinary
void SetIncorporeal(object oTarget, float fDuration, int nSuperOrEx, int nPermanent = FALSE);

// Test for incorporeallity of the target
// useful for targetting loops when incorporeal creatures
// wouldnt be affected
int GetIsIncorporeal(object oTarget);

/** Tests if a creature is living. Should be called on creatures.
 *  Dead and not-alive creatures return FALSE
 *  Returns FALSE for non-creature objects.
 */
int PRCGetIsAliveCreature(object oTarget);

// Gets the total number of HD of controlled undead
// i.e from Animate Dead, Ghoul Gauntlet or similar
// Dominated undead from Turn Undead do not count
int GetControlledUndeadTotalHD(object oPC = OBJECT_SELF);

// Gets the total number of HD of controlled evil outsiders
// i.e from call dretch, call lemure, or similar
// Dominated outsiders from Turn Undead etc do not count
int GetControlledFiendTotalHD(object oPC = OBJECT_SELF);

// Gets the total number of HD of controlled good outsiders
// i.e from call favoured servants
// Dominated outsiders from Turn Undead etc do not count
int GetControlledCelestialTotalHD(object oPC = OBJECT_SELF);

/**
 * Multisummon code, to be run before the summoning effect is applied.
 * Normally, this will only perform the multisummon trick of setting
 * pre-existing summons indestructable if PRC_MULTISUMMON is set.
 *
 * @param oPC          The creature casting the summoning spell
 * @param bOverride    If this is set, ignores the value of PRC_MULTISUMMON switch
 */
void MultisummonPreSummon(object oPC = OBJECT_SELF, int bOverride = FALSE);

/**
 * Sets up all of the AoE's variables, but only if they aren't already set.
 *
 * This sets many things that would have been checked against GetAreaOfEffectCreator()
 * as local ints making it so the AoE can now function entirely independantly of its caster.
 * - The only problem is that this will never be called until the AoE does a heartbeat or
 * something.
 *
 * Since some functions (ie PRCGetLastSpellcastClass() can not work outside of the spell script
 * sometimes SetAllAoEInts() was storing incorrect vaules for 'new spellbook' classes.
 * I modified the function and moved it to main spell script, so it should work correctly now. - x
 *
 * @param SpellID       Spell ID to store on the AoE.
 * @param oAoE          AoE object to store the variables on
 * @param nBaseSaveDC   save DC to store on the AoE
 * @param SpecDispel    Stored on the AoE (dunno what it's for)
 * @param nCasterLevel  Caster level to store on the AoE. If default used, gets
 *                      caster level from the AoE creator.
 */
void SetAllAoEInts(int SpellID, object oAoE, int nBaseSaveDC, int SpecDispel = 0 , int nCasterLevel = 0);

// * Applies the effects of FEAT_AUGMENT_SUMMON to summoned creatures.
void AugmentSummonedCreature(string sResRef);

// -----------------
// BEGIN SPELLSWORD
// -----------------

//This function returns 1 only if the object oTarget is the object
//the weapon hit when it channeled the spell sSpell or if there is no
//channeling at all
int ChannelChecker(string sSpell, object oTarget);

//If a spell is being channeled, we store its target and its name
void StoreSpellVariables(string sString,int nDuration);

//Replacement for The MaximizeOrEmpower function
int PRCMaximizeOrEmpower(int nDice, int nNumberOfDice, int nMeta, int nBonus = 0);

//This checks if the spell is channeled and if there are multiple spells
//channeled, which one is it. Then it checks in either case if the spell
//has the metamagic feat the function gets and returns TRUE or FALSE accordingly
//int CheckMetaMagic(int nMeta,int nMMagic);
//not needed now there is PRCGetMetaMagicFeat()

//wrapper for biowares GetMetaMagicFeat()
//used for spellsword and items
//      bClearFeatFlags   - clear metamagic feat info (sudden meta, divine meta etc.)- set it to FALSE if you're
//                          going to use PRCGetMetaMagicFeat() more than once for a single spell
//                          (ie. first in spellhook code, next in spell script)
int PRCGetMetaMagicFeat(object oCaster = OBJECT_SELF, int bClearFeatFlags = TRUE);

// This function rolls damage and applies metamagic feats to the damage.
//      nDamageType - The DAMAGE_TYPE_xxx constant for the damage, or -1 for no
//          a non-damaging effect.
//      nDice - number of dice to roll.
//      nDieSize - size of dice, i.e. d4, d6, d8, etc.
//      nBonusPerDie - Amount of bonus damage per die.
//      nBonus - Amount of overall bonus damage.
//      nMetaMagic - metamagic constant, if -1 GetMetaMagic() is called.
//      returns - the damage rolled with metamagic applied.
int PRCGetMetaMagicDamage(int nDamageType, int nDice, int nDieSize,
    int nBonusPerDie = 0, int nBonus = 0, int nMetaMagic = -1);

// Function to save the school of the currently cast spell in a variable.  This should be
// called at the beginning of the script to set the spell school (passing the school) and
// once at the end of the script (with no arguments) to delete the variable.
//  nSchool - SPELL_SCHOOL_xxx constant to set, if general then the variable is
//      deleted.
// moved from spinc_common and renamed
void PRCSetSchool(int nSchool = SPELL_SCHOOL_GENERAL);

/**
 * Signals a spell has been cast. Acts as a wrapper to fire EVENT_SPELL_CAST_AT
 * via SignalEvent()
 * @param oTarget   Target of the spell.
 * @param bHostile  TRUE if the spell is a hostile act.
 * @param nSpellID  Spell ID or -1 if PRCGetSpellId() should be used.
 * @param oCaster   Object doing the casting.
 */
void PRCSignalSpellEvent(object oTarget, int bHostile = TRUE, int nSpellID = -1, object oCaster = OBJECT_SELF);

//GetFirstObjectInShape wrapper for changing the AOE of the channeled spells (Spellsword Channel Spell)
object MyFirstObjectInShape(int nShape, float fSize, location lTarget, int bLineOfSight=FALSE, int nObjectFilter=OBJECT_TYPE_CREATURE, vector vOrigin=[0.0,0.0,0.0]);

//GetNextObjectInShape wrapper for changing the AOE of the channeled spells (Spellsword Channel Spell)
object MyNextObjectInShape(int nShape, float fSize, location lTarget, int bLineOfSight=FALSE, int nObjectFilter=OBJECT_TYPE_CREATURE, vector vOrigin=[0.0,0.0,0.0]);

// * Kovi. removes any effects from this type of spell
// * i.e., used in Mage Armor to remove any previous
// * mage armors
void PRCRemoveEffectsFromSpell(object oTarget, int SpellID);

// * Get Scaled Effect
effect PRCGetScaledEffect(effect eStandard, object oTarget);

// * Searchs through a persons effects and removes all those of a specific type.
void PRCRemoveSpecificEffect(int nEffectTypeID, object oTarget);

// * Returns true if Target is a humanoid
int PRCAmIAHumanoid(object oTarget);

// * Get Difficulty Duration
int PRCGetScaledDuration(int nActualDuration, object oTarget);

// * Will pass back a linked effect for all the protection from alignment spells.  The power represents the multiplier of strength.
// * That is instead of +3 AC and +2 Saves a  power of 2 will yield +6 AC and +4 Saves.
effect PRCCreateProtectionFromAlignmentLink(int nAlignment, int nPower = 1);

// * Returns the time in seconds that the effect should be delayed before application.
float PRCGetSpellEffectDelay(location SpellTargetLocation, object oTarget);

// * This is a wrapper for how Petrify will work in Expansion Pack 1
// * Scripts affected: flesh to stone, breath petrification, gaze petrification, touch petrification
// * nPower : This is the Hit Dice of a Monster using Gaze, Breath or Touch OR it is the Caster Spell of
// *   a spellcaster
// * nFortSaveDC: pass in this number from the spell script
void PRCDoPetrification(int nPower, object oSource, object oTarget, int nSpellID, int nFortSaveDC);

int PRCGetDelayedSpellEffectsExpired(int nSpell_ID, object oTarget, object oCaster);

int PRCGetSpellUsesLeft(int nRealSpellID, object oCreature = OBJECT_SELF);
// -----------------
// END SPELLSWORD
// -----------------

// Functions mostly only useful within the scope of this include
int BWSavingThrow(int nSavingThrow, object oTarget, int nDC, int nSaveType = SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0);

// This function holds all functions that are supposed to run before the actual
// spellscript gets run. If this functions returns FALSE, the spell is aborted
// and the spellscript will not run
int X2PreSpellCastCode();

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// this could also be put into in prc_inc_switches
const string PRC_SAVEDC_OVERRIDE = "PRC_SAVEDC_OVERRIDE";

const int  TYPE_ARCANE   = -1;
const int  TYPE_DIVINE   = -2;


//Changed to use CLASS_TYPE_* instead
//const int  TYPE_SORCERER = 2;
//const int  TYPE_WIZARD   = 3;
//const int  TYPE_BARD     = 4;
//const int  TYPE_CLERIC   = 11;
//const int  TYPE_DRUID    = 12;
//const int  TYPE_RANGER   = 13;
//const int  TYPE_PALADIN  = 14;

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

//#include "inc_abil_damage"
//#include "prc_inc_castlvl"
//#include "lookup_2da_spell"

// ** THIS ORDER IS IMPORTANT **

//#include "inc_lookups"	// access via prc_inc_core
#include "inc_newspellbook"

//#include "prc_inc_core"  // Compiler won't allow access via inc_newspellbook

#include "inc_vfx_const"
#include "spinc_necro_cyst"
#include "true_utter_const"
//#include "shd_myst_const"
//#include "prc_spellhook"
#include "prc_inc_sneak"
#include "prcsp_engine"
//#include "prc_inc_descrptr"
#include "inc_item_props"


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

effect ShadowlordEffects(int iShadow, effect eBaseEffect)  
{  
 
	//:: Create visual feedback effect link  
	effect eVis = EffectVisualEffect(VFX_DUR_ULTRAVISION);  
	eVis = EffectLinkEffects(eVis, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));  
	eVis = EffectLinkEffects(eVis, EffectVisualEffect(VFX_DUR_MAGICAL_SIGHT)); 
	eVis = EffectLinkEffects(eVis, EffectIcon(EFFECT_ICON_ULTRAVISION));		
	  
	//:: Link Ultravision and visual feedback into base effect
	eBaseEffect = EffectLinkEffects(eBaseEffect, EffectUltravision()); 
	eBaseEffect = EffectLinkEffects(eBaseEffect, eVis);
	if(DEBUG) DoDebug("ShadowlordEffects() >> Setting up Ultravision");	
	  
	if (iShadow > 1)  
	{  
		//;: Add concealment for level 2+ Shadowlords  
		eBaseEffect = EffectLinkEffects(eBaseEffect, EffectConcealment(20)); 
		if(DEBUG) DoDebug("ShadowlordEffects() >> Setting up Concealment");			
	}  
       
    return eBaseEffect;  
}


// Returns TRUE if nSpellID is a subradial spell, FALSE otherwise
int GetIsSubradialSpell(int nSpellID)
{
    string sMaster = Get2DACache("spells", "Master", nSpellID);

    // If the Master column is numeric, this spell is a subradial of that master
    if (sMaster != "" && sMaster != "****")
    {
        return TRUE;
    }

    return FALSE;
}

// Returns the masterspell SpellID for a subradial spell.
int GetMasterSpellFromSubradial(int nSpellID)
{
    string sMaster = Get2DAString("spells", "Master", nSpellID);

    if (sMaster != "****")
    {
        return StringToInt(sMaster);
    }

    return -1; // No master
}



int GetPrCAdjustedClassLevel(int nClass, object oCaster = OBJECT_SELF)
{
    int iTemp;
    // is it arcane, divine or neither?
    if(GetIsArcaneClass(nClass, oCaster) && nClass != CLASS_TYPE_SUBLIME_CHORD)
    {
		if(nClass == CLASS_TYPE_FEY && GetRacialType(oCaster) == RACIAL_TYPE_GLOURA)  
            iTemp = GetArcanePRCLevels(oCaster, nClass);
		
		else if (GetPrimaryArcaneClass(oCaster) == nClass) // adjust for any PrCs
            iTemp = GetArcanePRCLevels(oCaster, nClass);
    }
    else if(GetIsDivineClass(nClass, oCaster))
    {
		if (GetPrimaryDivineClass(oCaster) == nClass) // adjust for any PrCs
            iTemp = GetDivinePRCLevels(oCaster, nClass);			
    }
    else // a non-caster class or a PrC
    {
		return 0;
    }
    // add the caster class levels
    return iTemp += GetLevelByClass(nClass, oCaster);
}

int GetPrCAdjustedCasterLevel(int nClass, object oCaster = OBJECT_SELF, int bAdjustForPractisedSpellcaster = TRUE)
{
    int iTemp;
    iTemp = GetPrCAdjustedClassLevel(nClass, oCaster);
    iTemp = iTemp / GetCasterLevelModifier(nClass);
    if (bAdjustForPractisedSpellcaster)
        iTemp += PracticedSpellcasting(oCaster, nClass, iTemp);
    return iTemp;
}

int GetPrCAdjustedCasterLevelByType(int nClassType, object oCaster = OBJECT_SELF, int bAdjustForPractisedSpellcaster = TRUE)
{
	int nClassLvl;
	int nClass1, nClass2, nClass3, nClass4, nClass5, nClass6, nClass7, nClass8;
	int nClass1Lvl = 0, nClass2Lvl = 0, nClass3Lvl = 0, nClass4Lvl = 0,
		nClass5Lvl = 0, nClass6Lvl = 0, nClass7Lvl = 0, nClass8Lvl = 0;

		
    nClass1 = GetClassByPosition(1, oCaster);
    nClass2 = GetClassByPosition(2, oCaster);
    nClass3 = GetClassByPosition(3, oCaster);
    nClass4 = GetClassByPosition(4, oCaster);
    nClass5 = GetClassByPosition(5, oCaster);
    nClass6 = GetClassByPosition(6, oCaster);
    nClass7 = GetClassByPosition(7, oCaster);
    nClass8 = GetClassByPosition(8, oCaster);
	
    if(nClassType == TYPE_ARCANE && (GetFirstArcaneClassPosition(oCaster) > 0))
    {
        if (GetIsArcaneClass(nClass1, oCaster)) nClass1Lvl = GetPrCAdjustedCasterLevel(nClass1, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsArcaneClass(nClass2, oCaster)) nClass2Lvl = GetPrCAdjustedCasterLevel(nClass2, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsArcaneClass(nClass3, oCaster)) nClass3Lvl = GetPrCAdjustedCasterLevel(nClass3, oCaster, bAdjustForPractisedSpellcaster);
		if (GetIsArcaneClass(nClass4, oCaster)) nClass4Lvl = GetPrCAdjustedCasterLevel(nClass4, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsArcaneClass(nClass5, oCaster)) nClass5Lvl = GetPrCAdjustedCasterLevel(nClass5, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsArcaneClass(nClass6, oCaster)) nClass6Lvl = GetPrCAdjustedCasterLevel(nClass6, oCaster, bAdjustForPractisedSpellcaster);
		if (GetIsArcaneClass(nClass7, oCaster)) nClass7Lvl = GetPrCAdjustedCasterLevel(nClass7, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsArcaneClass(nClass8, oCaster)) nClass8Lvl = GetPrCAdjustedCasterLevel(nClass8, oCaster, bAdjustForPractisedSpellcaster);
    }
    else if (nClassType == TYPE_DIVINE && (GetFirstDivineClassPosition(oCaster) > 0))
    {
        if (GetIsDivineClass(nClass1, oCaster)) nClass1Lvl = GetPrCAdjustedCasterLevel(nClass1, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsDivineClass(nClass2, oCaster)) nClass2Lvl = GetPrCAdjustedCasterLevel(nClass2, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsDivineClass(nClass3, oCaster)) nClass3Lvl = GetPrCAdjustedCasterLevel(nClass3, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsDivineClass(nClass4, oCaster)) nClass4Lvl = GetPrCAdjustedCasterLevel(nClass4, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsDivineClass(nClass5, oCaster)) nClass5Lvl = GetPrCAdjustedCasterLevel(nClass5, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsDivineClass(nClass6, oCaster)) nClass6Lvl = GetPrCAdjustedCasterLevel(nClass6, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsDivineClass(nClass7, oCaster)) nClass7Lvl = GetPrCAdjustedCasterLevel(nClass7, oCaster, bAdjustForPractisedSpellcaster);
        if (GetIsDivineClass(nClass8, oCaster)) nClass8Lvl = GetPrCAdjustedCasterLevel(nClass8, oCaster, bAdjustForPractisedSpellcaster);		
    }
    int nHighest = nClass1Lvl;
    if (nClass2Lvl > nHighest) nHighest = nClass2Lvl;
    if (nClass3Lvl > nHighest) nHighest = nClass3Lvl;
	if (nClass4Lvl > nHighest) nHighest = nClass4Lvl;
    if (nClass5Lvl > nHighest) nHighest = nClass5Lvl;
    if (nClass6Lvl > nHighest) nHighest = nClass6Lvl;
    if (nClass7Lvl > nHighest) nHighest = nClass7Lvl;
    if (nClass8Lvl > nHighest) nHighest = nClass8Lvl;	
	return nHighest;
}

int GetLevelByTypeArcaneFeats(object oCaster = OBJECT_SELF, int iSpellID = -1)
{
    int iFirstArcane = GetPrimaryArcaneClass(oCaster);
    int iBest = 0;
    int iClass1 = GetClassByPosition(1, oCaster);
    int iClass2 = GetClassByPosition(2, oCaster);
    int iClass3 = GetClassByPosition(3, oCaster);
    int iClass4 = GetClassByPosition(4, oCaster);
    int iClass5 = GetClassByPosition(5, oCaster);
    int iClass6 = GetClassByPosition(6, oCaster);
    int iClass7 = GetClassByPosition(7, oCaster);
    int iClass8 = GetClassByPosition(8, oCaster);
	
    int iClass1Lev = GetLevelByPosition(1, oCaster);
    int iClass2Lev = GetLevelByPosition(2, oCaster);
    int iClass3Lev = GetLevelByPosition(3, oCaster);
    int iClass4Lev = GetLevelByPosition(4, oCaster);
    int iClass5Lev = GetLevelByPosition(5, oCaster);
    int iClass6Lev = GetLevelByPosition(6, oCaster);
    int iClass7Lev = GetLevelByPosition(7, oCaster);
    int iClass8Lev = GetLevelByPosition(8, oCaster);

    if (iSpellID = -1) iSpellID = PRCGetSpellId(oCaster);

    int iBoost = ShadowWeave(oCaster, iSpellID) +
                 FireAdept(oCaster, iSpellID) +
                 DomainPower(oCaster, iSpellID) +
                 StormMagic(oCaster) +
                 CormanthyranMoonMagic(oCaster) +
                 DraconicPower(oCaster);

    if (iClass1 == CLASS_TYPE_HEXBLADE) iClass1Lev = (iClass1Lev >= 4) ? (iClass1Lev / 2) : 0;
    if (iClass2 == CLASS_TYPE_HEXBLADE) iClass2Lev = (iClass2Lev >= 4) ? (iClass2Lev / 2) : 0;
    if (iClass3 == CLASS_TYPE_HEXBLADE) iClass3Lev = (iClass3Lev >= 4) ? (iClass3Lev / 2) : 0;
    if (iClass4 == CLASS_TYPE_HEXBLADE) iClass4Lev = (iClass4Lev >= 4) ? (iClass4Lev / 2) : 0;
    if (iClass5 == CLASS_TYPE_HEXBLADE) iClass5Lev = (iClass5Lev >= 4) ? (iClass5Lev / 2) : 0;
    if (iClass6 == CLASS_TYPE_HEXBLADE) iClass6Lev = (iClass6Lev >= 4) ? (iClass6Lev / 2) : 0;
    if (iClass7 == CLASS_TYPE_HEXBLADE) iClass7Lev = (iClass7Lev >= 4) ? (iClass7Lev / 2) : 0;
    if (iClass8 == CLASS_TYPE_HEXBLADE) iClass8Lev = (iClass8Lev >= 4) ? (iClass8Lev / 2) : 0;

    if (iClass1 == iFirstArcane) iClass1Lev += GetArcanePRCLevels(oCaster, iClass1);
    if (iClass2 == iFirstArcane) iClass2Lev += GetArcanePRCLevels(oCaster, iClass2);
    if (iClass3 == iFirstArcane) iClass3Lev += GetArcanePRCLevels(oCaster, iClass3);
	if (iClass4 == iFirstArcane) iClass4Lev += GetArcanePRCLevels(oCaster, iClass4);
    if (iClass5 == iFirstArcane) iClass5Lev += GetArcanePRCLevels(oCaster, iClass5);
    if (iClass6 == iFirstArcane) iClass6Lev += GetArcanePRCLevels(oCaster, iClass6);
    if (iClass7 == iFirstArcane) iClass7Lev += GetArcanePRCLevels(oCaster, iClass7);
    if (iClass8 == iFirstArcane) iClass8Lev += GetArcanePRCLevels(oCaster, iClass8);

    iClass1Lev += iBoost;
    iClass2Lev += iBoost;
    iClass3Lev += iBoost;
    iClass4Lev += iBoost;
    iClass5Lev += iBoost;
    iClass6Lev += iBoost;	
    iClass7Lev += iBoost;
    iClass8Lev += iBoost;

    iClass1Lev += PracticedSpellcasting(oCaster, iClass1, iClass1Lev);
    iClass2Lev += PracticedSpellcasting(oCaster, iClass2, iClass2Lev);
    iClass3Lev += PracticedSpellcasting(oCaster, iClass3, iClass3Lev);
    iClass4Lev += PracticedSpellcasting(oCaster, iClass4, iClass4Lev);
    iClass5Lev += PracticedSpellcasting(oCaster, iClass5, iClass5Lev);
    iClass6Lev += PracticedSpellcasting(oCaster, iClass6, iClass6Lev);
    iClass7Lev += PracticedSpellcasting(oCaster, iClass7, iClass7Lev);
    iClass8Lev += PracticedSpellcasting(oCaster, iClass8, iClass8Lev);
	
    if (!GetIsArcaneClass(iClass1, oCaster)) iClass1Lev = 0;
    if (!GetIsArcaneClass(iClass2, oCaster)) iClass2Lev = 0;
    if (!GetIsArcaneClass(iClass3, oCaster)) iClass3Lev = 0;
    if (!GetIsArcaneClass(iClass4, oCaster)) iClass4Lev = 0;
    if (!GetIsArcaneClass(iClass5, oCaster)) iClass5Lev = 0;
    if (!GetIsArcaneClass(iClass6, oCaster)) iClass6Lev = 0;
    if (!GetIsArcaneClass(iClass7, oCaster)) iClass7Lev = 0;
    if (!GetIsArcaneClass(iClass8, oCaster)) iClass8Lev = 0;

    if (iClass1Lev > iBest) iBest = iClass1Lev;
    if (iClass2Lev > iBest) iBest = iClass2Lev;
    if (iClass3Lev > iBest) iBest = iClass3Lev;
    if (iClass4Lev > iBest) iBest = iClass4Lev;
    if (iClass5Lev > iBest) iBest = iClass5Lev;
    if (iClass6Lev > iBest) iBest = iClass6Lev;
    if (iClass7Lev > iBest) iBest = iClass7Lev;
    if (iClass8Lev > iBest) iBest = iClass8Lev;
	
    return iBest;
}

int GetLevelByTypeDivineFeats(object oCaster = OBJECT_SELF, int iSpellID = -1)
{
    int iFirstDivine = GetPrimaryDivineClass(oCaster);
    int iBest = 0;
    int iClass1 = GetClassByPosition(1, oCaster);
    int iClass2 = GetClassByPosition(2, oCaster);
    int iClass3 = GetClassByPosition(3, oCaster);
    int iClass4 = GetClassByPosition(4, oCaster);
    int iClass5 = GetClassByPosition(5, oCaster);
    int iClass6 = GetClassByPosition(6, oCaster);
	int iClass7 = GetClassByPosition(7, oCaster);
    int iClass8 = GetClassByPosition(8, oCaster);
	
    int iClass1Lev = GetLevelByPosition(1, oCaster);
    int iClass2Lev = GetLevelByPosition(2, oCaster);
    int iClass3Lev = GetLevelByPosition(3, oCaster);
    int iClass4Lev = GetLevelByPosition(4, oCaster);
    int iClass5Lev = GetLevelByPosition(5, oCaster);
    int iClass6Lev = GetLevelByPosition(6, oCaster);
    int iClass7Lev = GetLevelByPosition(7, oCaster);
    int iClass8Lev = GetLevelByPosition(8, oCaster);
	
    if (iSpellID = -1) iSpellID = PRCGetSpellId(oCaster);

    int iBoost = ShadowWeave(oCaster, iSpellID) +
                 FireAdept(oCaster, iSpellID) +
                 DomainPower(oCaster, iSpellID) +
                 CormanthyranMoonMagic(oCaster) +
                 StormMagic(oCaster);

    if (iClass1 == CLASS_TYPE_PALADIN
        || iClass1 == CLASS_TYPE_RANGER
        || iClass1 == CLASS_TYPE_ANTI_PALADIN)
        iClass1Lev = iClass1Lev / 2;
    if (iClass2 == CLASS_TYPE_PALADIN
        || iClass2 == CLASS_TYPE_RANGER
        || iClass2 == CLASS_TYPE_ANTI_PALADIN)
        iClass2Lev = iClass2Lev / 2;
    if (iClass3 == CLASS_TYPE_PALADIN
        || iClass3 == CLASS_TYPE_RANGER
        || iClass3 == CLASS_TYPE_ANTI_PALADIN)
        iClass3Lev = iClass3Lev / 2;
    if (iClass4 == CLASS_TYPE_PALADIN
        || iClass4 == CLASS_TYPE_RANGER
        || iClass4 == CLASS_TYPE_ANTI_PALADIN)
        iClass4Lev = iClass4Lev / 2;
    if (iClass5 == CLASS_TYPE_PALADIN
        || iClass5 == CLASS_TYPE_RANGER
        || iClass5 == CLASS_TYPE_ANTI_PALADIN)
        iClass5Lev = iClass5Lev / 2;
	if (iClass6 == CLASS_TYPE_PALADIN
        || iClass6 == CLASS_TYPE_RANGER
        || iClass6 == CLASS_TYPE_ANTI_PALADIN)
        iClass6Lev = iClass6Lev / 2;
    if (iClass7 == CLASS_TYPE_PALADIN
        || iClass7 == CLASS_TYPE_RANGER
        || iClass7 == CLASS_TYPE_ANTI_PALADIN)
        iClass7Lev = iClass7Lev / 2;		
    if (iClass8 == CLASS_TYPE_PALADIN
        || iClass8 == CLASS_TYPE_RANGER
        || iClass8 == CLASS_TYPE_ANTI_PALADIN)
        iClass8Lev = iClass7Lev / 2;		
		
    if (iClass1 == iFirstDivine) iClass1Lev += GetDivinePRCLevels(oCaster, iClass1);
    if (iClass2 == iFirstDivine) iClass2Lev += GetDivinePRCLevels(oCaster, iClass2);
    if (iClass3 == iFirstDivine) iClass3Lev += GetDivinePRCLevels(oCaster, iClass3);
    if (iClass4 == iFirstDivine) iClass4Lev += GetDivinePRCLevels(oCaster, iClass4);
    if (iClass5 == iFirstDivine) iClass5Lev += GetDivinePRCLevels(oCaster, iClass5);
    if (iClass6 == iFirstDivine) iClass6Lev += GetDivinePRCLevels(oCaster, iClass6);
    if (iClass7 == iFirstDivine) iClass7Lev += GetDivinePRCLevels(oCaster, iClass7);
    if (iClass8 == iFirstDivine) iClass8Lev += GetDivinePRCLevels(oCaster, iClass8);
	
    iClass1Lev += iBoost;
    iClass2Lev += iBoost;
    iClass3Lev += iBoost;
    iClass4Lev += iBoost;
    iClass5Lev += iBoost;
    iClass6Lev += iBoost;
	iClass7Lev += iBoost;
    iClass8Lev += iBoost;

    iClass1Lev += PracticedSpellcasting(oCaster, iClass1, iClass1Lev);
    iClass2Lev += PracticedSpellcasting(oCaster, iClass2, iClass2Lev);
    iClass3Lev += PracticedSpellcasting(oCaster, iClass3, iClass3Lev);
    iClass4Lev += PracticedSpellcasting(oCaster, iClass4, iClass4Lev);
    iClass5Lev += PracticedSpellcasting(oCaster, iClass5, iClass5Lev);
    iClass6Lev += PracticedSpellcasting(oCaster, iClass6, iClass6Lev);
	iClass7Lev += PracticedSpellcasting(oCaster, iClass7, iClass7Lev);
    iClass8Lev += PracticedSpellcasting(oCaster, iClass8, iClass8Lev);

    if (!GetIsDivineClass(iClass1, oCaster)) iClass1Lev = 0;
    if (!GetIsDivineClass(iClass2, oCaster)) iClass2Lev = 0;
    if (!GetIsDivineClass(iClass3, oCaster)) iClass3Lev = 0;
    if (!GetIsDivineClass(iClass4, oCaster)) iClass4Lev = 0;
    if (!GetIsDivineClass(iClass5, oCaster)) iClass5Lev = 0;
    if (!GetIsDivineClass(iClass6, oCaster)) iClass6Lev = 0;
    if (!GetIsDivineClass(iClass7, oCaster)) iClass7Lev = 0;
    if (!GetIsDivineClass(iClass8, oCaster)) iClass8Lev = 0;
	
    if (iClass1Lev > iBest) iBest = iClass1Lev;
    if (iClass2Lev > iBest) iBest = iClass2Lev;
    if (iClass3Lev > iBest) iBest = iClass3Lev;
    if (iClass4Lev > iBest) iBest = iClass4Lev;
    if (iClass5Lev > iBest) iBest = iClass5Lev;
    if (iClass6Lev > iBest) iBest = iClass6Lev;
    if (iClass7Lev > iBest) iBest = iClass7Lev;
    if (iClass8Lev > iBest) iBest = iClass8Lev;

    return iBest;
}

// looks up the spell level for the arcane caster classes (Wiz_Sorc, Bard) in spells.2da.
// Caveat: some onhitcast spells don't have any spell-levels listed for any class
int GetIsArcaneSpell (int iSpellId)
{
    return  Get2DACache("spells", "Wiz_Sorc", iSpellId) != ""
            || Get2DACache("spells", "Bard", iSpellId) != "";
}

// looks up the spell level for the divine caster classes (Cleric, Druid, Ranger, Paladin) in spells.2da.
// Caveat: some onhitcast spells don't have any spell-levels listed for any class
int GetIsDivineSpell (int iSpellId)
{
    return  Get2DACache("spells", "Cleric", iSpellId) != ""
            || Get2DACache("spells", "Druid", iSpellId) != ""
            || Get2DACache("spells", "Ranger", iSpellId) != ""
            || Get2DACache("spells", "Paladin", iSpellId) != "";
}

int BWSavingThrow(int nSavingThrow, object oTarget, int nDC, int nSaveType = SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0)
{
    // GZ: sanity checks to prevent wrapping around
    if      (nDC <   1) nDC = 1;
    else if (nDC > 255) nDC = 255;

    int bValid = 0;
    int nEff;

    //some maneuvers allow people to use skill check instead of a save
    if(nSavingThrow == SAVING_THROW_FORT)
    {
        bValid = GetLocalInt(oTarget, "MindOverBody") ?
                 GetIsSkillSuccessful(oTarget, SKILL_CONCENTRATION, nDC) :
                 FortitudeSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1) nEff = VFX_IMP_FORTITUDE_SAVING_THROW_USE;
    }
    else if(nSavingThrow == SAVING_THROW_REFLEX)
    {
        bValid = GetLocalInt(oTarget, "ActionBeforeThought") ?
                 GetIsSkillSuccessful(oTarget, SKILL_CONCENTRATION, nDC) :
                 ReflexSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1) nEff = VFX_IMP_REFLEX_SAVE_THROW_USE;
    }
    else if(nSavingThrow == SAVING_THROW_WILL)
    {
        bValid = GetLocalInt(oTarget, "MomentOfPerfectMind") ?
                 GetIsSkillSuccessful(oTarget, SKILL_CONCENTRATION, nDC) :
                 WillSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1) nEff = VFX_IMP_WILL_SAVING_THROW_USE;
    }

    /*
        return 0 = FAILED SAVE
        return 1 = SAVE SUCCESSFUL
        return 2 = IMMUNE TO WHAT WAS BEING SAVED AGAINST
    */
    if(bValid == 0)
    {
        int nSpellID = PRCGetSpellId(oSaveVersus);
        if(nSaveType == SAVING_THROW_TYPE_DEATH
         || nSpellID == SPELL_WEIRD
         || nSpellID == SPELL_FINGER_OF_DEATH)
         //&& nSpellID != SPELL_HORRID_WILTING)
        {
            if(fDelay > 0.0f) DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH), oTarget));
            else                                   ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH), oTarget);
        }
    }
    else //if(bValid == 1 || bValid == 2)
    {
        if(bValid == 2) nEff = VFX_IMP_MAGIC_RESISTANCE_USE;

        if(fDelay > 0.0f) DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nEff), oTarget));
        else                                   ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nEff), oTarget);
    }
    return bValid;
}

void PRCBonusDamage(object oTarget, object oCaster = OBJECT_SELF)
{
    // Does nothing, left here so files don't need to be edited.
}

//  Bonus damage to a spell for Spell Betrayal Ability
int SpellBetrayalDamage(object oTarget, object oCaster)
{
    int iDam = 0;

    // Combine caster and spell ID into a unique key
    int nSpellId = PRCGetSpellId();
    string sFlag = "BETRAYAL_" + ObjectToString(oCaster) + "_" + IntToString(nSpellId);

    // Only apply once per spell cast from this caster
    if (GetLocalInt(oTarget, sFlag))
        return 0;

    int ThrallLevel = GetLevelByClass(CLASS_TYPE_THRALL_OF_GRAZZT_A, oCaster) +
                      GetLevelByClass(CLASS_TYPE_THRALL_OF_GRAZZT_D, oCaster);

    if (ThrallLevel >= 2)
    {
        if (GetIsDeniedDexBonusToAC(oTarget, oCaster, TRUE))
        {
            ThrallLevel /= 2;
            iDam = d6(ThrallLevel);

            // Mark target as affected for this spell instance by this caster
            SetLocalInt(oTarget, sFlag, TRUE);
            DelayCommand(2.5, DeleteLocalInt(oTarget, sFlag));
        }
    }

    return iDam;
}


/* int SpellBetrayalDamage(object oTarget, object oCaster)
{
     int iDam = 0;
     int ThrallLevel = GetLevelByClass(CLASS_TYPE_THRALL_OF_GRAZZT_A, oCaster) + GetLevelByClass(CLASS_TYPE_THRALL_OF_GRAZZT_D, oCaster);

     if(ThrallLevel >= 2)
     {
          if( GetIsDeniedDexBonusToAC(oTarget, oCaster, TRUE) )
          {
               ThrallLevel /= 2;
               iDam = d6(ThrallLevel);
          }
     }

     return iDam;
} */

//  Bonus damage to a spell for Spellstrike Ability
int SpellStrikeDamage(object oTarget, object oCaster)
{
     int iDam = 0;
     int ThrallLevel = GetLevelByClass(CLASS_TYPE_THRALL_OF_GRAZZT_A, oCaster) + GetLevelByClass(CLASS_TYPE_THRALL_OF_GRAZZT_D, oCaster);
	 
    // Combine caster and spell ID into a unique key
    int nSpellId = PRCGetSpellId();
    string sFlag = "SPELL_STRIKE_" + ObjectToString(oCaster) + "_" + IntToString(nSpellId);	 

     if(ThrallLevel >= 6)
     {
          if( GetIsAOEFlanked(oTarget, oCaster) )
          {
			ThrallLevel /= 4;
			iDam = d6(ThrallLevel);
			// Mark target as affected for this spell instance by this caster
			SetLocalInt(oTarget, sFlag, TRUE);
			DelayCommand(2.5, DeleteLocalInt(oTarget, sFlag));			   
          }
     }

     return iDam;
}

//  Adds the bonus damage from both Spell Betrayal and Spellstrike together
int ApplySpellBetrayalStrikeDamage(object oTarget, object oCaster, int bShowTextString = TRUE)
{
     int iDam = 0;
     int iBetrayalDam = SpellBetrayalDamage(oTarget, oCaster);
     int iStrikeDam = SpellStrikeDamage(oTarget, oCaster);
     string sMes = "";

     if(iStrikeDam > 0 && iBetrayalDam > 0)  sMes ="*Spellstrike Betrayal Sucess*";
     else if(iBetrayalDam > 0)               sMes ="*Spell Betrayal Sucess*";
     else if(iStrikeDam > 0)                 sMes ="*Spellstrike Sucess*";

     if(bShowTextString)      FloatingTextStringOnCreature(sMes, oCaster, TRUE);

     iDam = iBetrayalDam + iStrikeDam;

     // debug code
     //sMes = "Spell Betrayal / Spellstrike Bonus Damage: " + IntToString(iBetrayalDam) + " + " + IntToString(iStrikeDam) + " = " + IntToString(iDam);
     //DelayCommand( 1.0, FloatingTextStringOnCreature(sMes, oCaster, TRUE) );

     return iDam;
}

int SpellDamagePerDice(object oCaster, int nDice)
{
	// Arcane only
	if (!GetIsArcaneClass(PRCGetLastSpellCastClass(oCaster)))
		return 0;

    int nDam = 0;
    nDam += GetLocalInt(oCaster, "StrengthFromMagic") * nDice * 2;
    
    if (GetLocalInt(oCaster, "WarsoulTyrant"))
	    nDam += nDice * GetHitDice(oCaster);

	if (DEBUG) DoDebug("SpellDamagePerDice returning "+IntToString(nDam)+" for "+GetName(oCaster));

    return nDam;
}

int PRCMySavingThrow(int nSavingThrow, object oTarget, int nDC, int nSaveType = SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0, int bImmunityCheck = FALSE)
{
    int nSpell = PRCGetSpellId(oSaveVersus);
    int nSpellSchool = GetSpellSchool(nSpell);
    
	//If bImmunityCheck == FALSE: returns 0 if failure or immune, 1 if success - same as MySavingThrow
	//If bImmunityCheck == TRUE:  returns 0 if failure, 1 if success, 2 if immune 
	
    // Enigma Helm Crown Bind
    if (GetIsMeldBound(oTarget, MELD_ENIGMA_HELM) == CHAKRA_CROWN && GetIsOfSubschool(nSpell, SUBSCHOOL_CHARM))
		return 2;		
    
    // Planar Ward
    if (GetHasSpellEffect(MELD_PLANAR_WARD, oTarget) && (GetIsOfSubschool(nSpell, SUBSCHOOL_CHARM) || GetIsOfSubschool(nSpell, SUBSCHOOL_COMPULSION)))
    	return 2;
    	
    // Chucoclops influence makes you autofail fear saves
    if (GetHasSpellEffect(VESTIGE_CHUPOCLOPS, oTarget) && !GetLocalInt(oTarget, "PactQuality"+IntToString(VESTIGE_CHUPOCLOPS)) && nSaveType == SAVING_THROW_TYPE_FEAR)
    	return 1;

    // Iron Mind's Mind Over Body, allows them to treat other saves as will saves up to 3/day.
    // No point in having it trigger when its a will save.
    if(nSavingThrow != SAVING_THROW_WILL && GetLocalInt(oTarget, "IronMind_MindOverBody"))
    {
        nSavingThrow = SAVING_THROW_WILL;
        DeleteLocalInt(oTarget, "IronMind_MindOverBody");
    }

    // Handle the target having Force of Will and being targeted by a psionic power
    if(nSavingThrow != SAVING_THROW_WILL        &&
       ((nSpell > 14000 && nSpell < 14360) ||
        (nSpell > 15350 && nSpell < 15470)
        )                                       &&
       GetHasFeat(FEAT_FORCE_OF_WILL, oTarget)  &&
       !GetLocalInt(oTarget, "ForceOfWillUsed") &&
       // Only use will save if it's better
       ((nSavingThrow == SAVING_THROW_FORT ? GetFortitudeSavingThrow(oTarget) : GetReflexSavingThrow(oTarget)) > GetWillSavingThrow(oTarget))
       )
    {
        nSavingThrow = SAVING_THROW_WILL;
        SetLocalInt(oTarget, "ForceOfWillUsed", TRUE);
        DelayCommand(6.0f, DeleteLocalInt(oTarget, "ForceOfWillUsed"));
        // "Force of Will used for this round."
        FloatingTextStrRefOnCreature(16826670, oTarget, FALSE);
    }

    //TouchOfDistraction
    if (GetLocalInt(oTarget, "HasTouchOfDistraction") && (nSavingThrow = SAVING_THROW_REFLEX))
    {
        nDC += 2;
        DeleteLocalInt(oTarget, "HasTouchOfDistraction");
    }
    
    //Diamond Defense
    if(GetLocalInt(oTarget, "PRC_TOB_DIAMOND_DEFENSE"))
        nDC -= GetLocalInt(oTarget, "PRC_TOB_DIAMOND_DEFENSE");

    // Master of Nine
    if(GetLevelByClass(CLASS_TYPE_MASTER_OF_NINE, oSaveVersus) > 2)
    {
        int nLastClass = GetLocalInt(oSaveVersus, "PRC_CurrentManeuver_InitiatingClass") - 1;
        if(nLastClass == CLASS_TYPE_WARBLADE
        || nLastClass == CLASS_TYPE_SWORDSAGE
        || nLastClass == CLASS_TYPE_CRUSADER)
        {
            // Increases maneuver DCs by 1
            nDC += 1;
        }
    }
    
    // Incarnum Resistance
    if(GetHasFeat(FEAT_INCARNUM_RESISTANCE, oTarget) && nSpell > 18900 && nSpell < 18969)
    	nDC -= 2;

    // This is done here because it is possible to tell the saving throw type here
    // it works by lowering the DC rather than adding to the save
    // same net effect but slightly different numbers
    if(nSaveType == SAVING_THROW_TYPE_MIND_SPELLS)
    {
        //Thayan Knights auto-fail mind spells cast by red wizards
        if(GetLevelByClass(CLASS_TYPE_RED_WIZARD, oSaveVersus)
        && GetLevelByClass(CLASS_TYPE_THAYAN_KNIGHT, oTarget))
            return 0;
        // Tyranny Domain increases the DC of mind spells by +2.
        if(GetHasFeat(FEAT_DOMAIN_POWER_TYRANNY, oSaveVersus))
            nDC += 2;
        // +2 bonus on saves against mind affecting, done here
        if(GetLevelByClass(CLASS_TYPE_FIST_DAL_QUOR, oTarget) > 1)
            nDC -= 2;
		if(GetHasFeat(FEAT_DOMAIN_POWER_MIND, oTarget) || GetHasFeat(FEAT_BONUS_DOMAIN_MIND, oTarget))
            nDC -= 2;		
        // Scorpion's Resolve gives a +4 bonus on mind affecting saves
        if(GetHasFeat(FEAT_SCORPIONS_RESOLVE, oTarget))
            nDC -= 4;
        // Warped Mind gives a bonus on mind affecting equal to half aberrant
        if(GetHasFeat(FEAT_ABERRANT_WARPED_MIND, oTarget))
            nDC -= GetAberrantFeatCount(oTarget)/2; 
    }
    else if(nSaveType == SAVING_THROW_TYPE_FEAR)
    {
        // Unnatural Will adds Charisma to saves against fear
        if(GetHasFeat(FEAT_UNNATURAL_WILL, oTarget))
            nDC -= GetAbilityModifier(ABILITY_CHARISMA, oTarget);
        // Krinth have +4 saves against Fear
        if(GetRacialType(oTarget) == RACIAL_TYPE_KRINTH)
            nDC -= 4;
        // Turlemoi/Lashemoi have -4 saves against Fear
        if(GetRacialType(oTarget) == RACIAL_TYPE_LASHEMOI || GetRacialType(oTarget) == RACIAL_TYPE_TURLEMOI || GetLocalInt(oTarget, "SpeedFromPain") >= 3)
            nDC += 4;            
    }    
    else if(nSaveType == SAVING_THROW_TYPE_NEGATIVE)
    {
        // +4 bonus on saves against negative energy, done here
        if(GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oTarget) > 8)
            nDC -= 4;
        // Jergal's Pact gives a +2 bonus on negative energy saves
        if(GetHasFeat(FEAT_JERGALS_PACT, oTarget))
            nDC -= 2;
    }
    else if(nSaveType == SAVING_THROW_TYPE_DISEASE)
    {
        // Plague Resistant gives a +4 bonus on disease saves
        if(GetHasFeat(FEAT_PLAGUE_RESISTANT, oTarget))
            nDC -= 4;
        // Racial +2 vs disease saves
        if(GetHasFeat(FEAT_RACE_HARDINESS_VS_DISEASE, oTarget))
            nDC -= 2;		
        // +4/+2 bonus on saves against disease, done here
        if(GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oTarget) > 13)
            nDC -= 4;
        else if(GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oTarget) > 3)
            nDC -= 2;
    }
    else if(nSaveType == SAVING_THROW_TYPE_POISON)
    {
        // +4/+2 bonus on saves against poison, done here
        if(GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oTarget) > 13)
            nDC -= 4;
        else if(GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oTarget) > 3)
            nDC -= 2;
        if(GetHasFeat(FEAT_POISON_4, oTarget))
            nDC -= 4;
        if(GetHasFeat(FEAT_POISON_3, oTarget))
            nDC -= 3;
    	if(GetRacialType(oTarget) == RACIAL_TYPE_EXTAMINAAR && nSavingThrow == SAVING_THROW_FORT)
        	nDC -= 2; 
        if(GetRacialType(oTarget) == RACIAL_TYPE_MONGRELFOLK)
        	nDC -= 1;
    }
    else if(nSaveType == SAVING_THROW_TYPE_FIRE)
    {
        // Bloodline of Fire gives a +4 bonus on fire saves
        if(GetHasFeat(FEAT_BLOODLINE_OF_FIRE, oTarget))
            nDC -= 4;
        if(GetHasFeat(FEAT_HARD_FIRE, oTarget))
            nDC -= 1 + (GetHitDice(oTarget) / 5);
        // +2 vs fire for Halfgiant
        if(GetHasFeat(FEAT_ACCLIMATED_FIRE, oTarget))
            nDC -= 2;
        // +2 vs fire for Heat Endurance feat
        if(GetHasFeat(FEAT_HEAT_ENDURANCE, oTarget))
            nDC -= 2;            
    }
    else if(nSaveType == SAVING_THROW_TYPE_COLD)
    {
        if(GetHasFeat(FEAT_HARD_WATER, oTarget))
            nDC -= 1 + (GetHitDice(oTarget) / 5);
        // +2 vs cold for Cold Endurance feat
        if(GetHasFeat(FEAT_COLD_ENDURANCE, oTarget))
            nDC -= 2;   
        // +2 vs cold for Winterhide Shifter trait
        if(GetHasFeat(FEAT_SHIFTER_WINTERHIDE, oTarget))
            nDC -= 2;             
    }
    else if(nSaveType == SAVING_THROW_TYPE_ELECTRICITY)
    {
        if(GetHasFeat(FEAT_HARD_AIR, oTarget))
            nDC -= 1 + (GetHitDice(oTarget) / 5);
        else if(GetHasFeat(FEAT_HARD_ELEC, oTarget))
            nDC -= 2;
		
		//:: Mechanatrix always fail saves vs electricity.
		if(GetRacialType(oTarget) == RACIAL_TYPE_MECHANATRIX)
				return 0;
    }
    else if(nSaveType == SAVING_THROW_TYPE_SONIC)
    {
        if(GetHasFeat(FEAT_HARD_AIR, oTarget))
            nDC -= 1 + (GetHitDice(oTarget) / 5);
    }
    else if(nSaveType == SAVING_THROW_TYPE_ACID)
    {
        if(GetHasFeat(FEAT_HARD_EARTH, oTarget))
            nDC -= 1 + (GetHitDice(oTarget) / 5);
    }
    
    // This is done here because it is possible to tell the spell school here
    // it works by lowering the DC rather than adding to the save
    // same net effect but slightly different numbers
    if(nSpellSchool == SPELL_SCHOOL_TRANSMUTATION)
    {
        // Full Moon's Trick - +2 vs Transmutation spels
        if(GetLocalInt(oTarget, "FullMoon_Trans"))
            nDC -= 2;
        if(GetLevelByClass(CLASS_TYPE_SAPPHIRE_HIERARCH, oTarget) >= 2)
            nDC -= 4;            
    }    
    
    // Sapphire Heirarch gets +4 against Chaos and Transmutation effects
   	if(GetLevelByClass(CLASS_TYPE_SAPPHIRE_HIERARCH, oTarget) >= 2 && GetHasDescriptor(nSpell, DESCRIPTOR_CHAOTIC))
        nDC -= 4;      
        
    // Charming Veil Brow bind grants Essentia bonus on saves against charm and compulsion    
    if(GetIsOfSubschool(nSpell, SUBSCHOOL_CHARM) || GetIsOfSubschool(nSpell, SUBSCHOOL_COMPULSION))
    {
    	if (GetIsMeldBound(oTarget, MELD_CHARMING_VEIL) == CHAKRA_BROW)
    		nDC -= GetEssentiaInvested(oTarget, MELD_CHARMING_VEIL);
    }
    
    // Krinth get +1 save against Shadow spells
    if (GetIsOfSubschool(nSpell, SUBSCHOOL_SHADOW) && GetRacialType(oTarget) == RACIAL_TYPE_KRINTH)
        nDC -= 1;

    //Psionic race save boosts - +1 vs all spells for Xeph
    if(GetHasFeat(FEAT_XEPH_SPELLHARD, oTarget))
        nDC -= 1;

    // Apostate - 1/2 HD bonus to resist divine spells
    if(GetHasFeat(FEAT_APOSTATE, oTarget))
    {
        //if divine
        if(GetIsDivineClass(PRCGetLastSpellCastClass(oSaveVersus)))
            nDC -= GetHitDice(oTarget) / 2;
    }
    
    // Hammer of Witches - +1 bonus against Arcane spells
    if(GetIsObjectValid(GetItemPossessedBy(oTarget, "WOL_HammerWitches")))
    {
        if(GetIsArcaneClass(PRCGetLastSpellCastClass(oSaveVersus)))
            nDC -= 1;
    } 
    
    // Cultist of the Shattered Peak - +1 bonus against Arcane spells
    if(GetLevelByClass(CLASS_TYPE_CULTIST_SHATTERED_PEAK, oTarget))
    {
        if(GetIsArcaneClass(PRCGetLastSpellCastClass(oSaveVersus)))
            nDC -= 1;
    }     

    //Insightful Divination
    if(GetLocalInt(oTarget, "Insightful Divination"))
    {
        nDC -= GetLocalInt(oTarget, "Insightful Divination");
        DeleteLocalInt(oTarget, "Insightful Divination");
    }

    // Phierans Resolve - +4 bonus vs spells with evil descriptor
    if(GetHasSpellEffect(SPELL_PHIERANS_RESOLVE, oTarget) && GetHasDescriptor(nSpell, DESCRIPTOR_EVIL))
        nDC -= 4;

    //spell school modificators
    int nSchool = GetLocalInt(oSaveVersus, "X2_L_LAST_SPELLSCHOOL_VAR");
    if(nSchool == SPELL_SCHOOL_NECROMANCY)
    {
        // Necrotic Cyst penalty on Necromancy spells
        if(GetPersistantLocalInt(oTarget, NECROTIC_CYST_MARKER))
            nDC += 2;
    }
    else if(nSchool == SPELL_SCHOOL_ILLUSION)
    {
        // Piercing Sight gives a +4 bonus on illusion saves
        if(GetHasFeat(FEAT_PIERCING_SIGHT, oTarget))
            nDC -= 4;
        // Adds +2 to Illusion DCs
        if(GetLocalInt(oSaveVersus, "ShadowTrickster"))
            nDC += 2;
    	// Illusion Veil Meld
    	if(GetHasSpellEffect(MELD_ILLUSION_VEIL, oSaveVersus))
			nDC += 1;
    	// Illusion Veil Meld
    	if(GetHasSpellEffect(MELD_ILLUSION_VEIL, oTarget))
			nDC -= GetEssentiaInvested(oTarget, MELD_ILLUSION_VEIL);
		if(GetRacialType(oTarget) == RACIAL_TYPE_MONGRELFOLK)
			nDC -= 1;
    }
    else if(nSchool == SPELL_SCHOOL_ENCHANTMENT)
    {
        //check if Unsettling Enchantment applies
        if(GetHasFeat(FEAT_UNSETTLING_ENCHANTMENT, oSaveVersus) && !GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS))
        {
            effect eLink = EffectLinkEffects(EffectACDecrease(2), EffectAttackDecrease(2));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, 6.0);
        }
        if(GetRacialType(oTarget) == RACIAL_TYPE_KILLOREN)
            nDC -= 2;
        if(GetLocalInt(oTarget, "KillorenAncient"))
            nDC -= 2;
		if(GetRacialType(oTarget) == RACIAL_TYPE_MONGRELFOLK)
			nDC -= 1;            
    }

    // Hexblade gets a bonus against spells equal to his Charisma (Min +1)
    if(nSchool && GetLevelByClass(CLASS_TYPE_HEXBLADE, oTarget))
    {
        int nHexCha = GetAbilityModifier(ABILITY_CHARISMA, oTarget);
        if (nHexCha < 1) nHexCha = 1;
        nDC -= nHexCha;
    }
    
    // Totemist gets a save v magical beasts
    if(MyPRCGetRacialType(oSaveVersus) == RACIAL_TYPE_MAGICAL_BEAST && GetLevelByClass(CLASS_TYPE_TOTEMIST, oTarget) >= 3)
        nDC -= 3;   

    int nSaveRoll = BWSavingThrow(nSavingThrow, oTarget, nDC, nSaveType, oSaveVersus, fDelay);

    // If the spell is save immune then the link must be applied in order to get the true immunity
    // to be resisted.  That is the reason for returing false and not true.  True blocks the
    // application of effects.
    if(nSaveRoll == 2 && !bImmunityCheck)
        return 0;

    // Failed the save - check if we can reroll
    if(!nSaveRoll)
    {
        if(nSaveType == SAVING_THROW_TYPE_MIND_SPELLS)
        {
            // Bond Of Loyalty
            if(GetLocalInt(oTarget, "BondOfLoyalty"))
            {
                // Reroll
                nSaveRoll = BWSavingThrow(nSavingThrow, oTarget, nDC, nSaveType, oSaveVersus, fDelay);
                DeleteLocalInt(oTarget, "BondOfLoyalty");
            }
        }
        else if(nSaveType == SAVING_THROW_TYPE_FEAR)
        {
            // Call To Battle Reroll
            if(GetLocalInt(oTarget, "CallToBattle"))
            {
                // Reroll
                nSaveRoll = BWSavingThrow(nSavingThrow, oTarget, nDC, nSaveType, oSaveVersus, fDelay);
                DeleteLocalInt(oTarget, "CallToBattle");
            }
        }

        // Second Chance power reroll
        if(!nSaveRoll && GetLocalInt(oTarget, "PRC_Power_SecondChance_Active") // Second chance is active
        && !GetLocalInt(oTarget, "PRC_Power_SecondChance_UserForRound"))       // And hasn't yet been used for this round
        {
            // Reroll
            nSaveRoll = BWSavingThrow(nSavingThrow, oTarget, nDC, nSaveType, oSaveVersus, fDelay);

            // Can't use this ability again for a round
            SetLocalInt(oTarget, "PRC_Power_SecondChance_UserForRound", TRUE);
            DelayCommand(6.0f, DeleteLocalInt(oTarget, "PRC_Power_SecondChance_UserForRound"));
        }

        // Zealous Surge Reroll
        if(!nSaveRoll && GetLocalInt(oTarget, "ZealousSurge"))
        {
            // Reroll
            nSaveRoll = BWSavingThrow(nSavingThrow, oTarget, nDC, nSaveType, oSaveVersus, fDelay);

            // Ability Used
            DeleteLocalInt(oTarget, "ZealousSurge");
        }
        
        // Balam's Cunning Reroll
        if(!nSaveRoll && GetLocalInt(oTarget, "BalamCunning"))
        {
            // Reroll
            nSaveRoll = BWSavingThrow(nSavingThrow, oTarget, nDC, nSaveType, oSaveVersus, fDelay);

            // Ability Used
            DeleteLocalInt(oTarget, "BalamCunning");
        }        

        if(!nSaveRoll)
        {
            if(nSavingThrow == SAVING_THROW_REFLEX)
            {
                // Dive for Cover reroll
                if(GetHasFeat(FEAT_DIVE_FOR_COVER, oTarget))
                {
                    // Reroll
                    nSaveRoll = BWSavingThrow(nSavingThrow, oTarget, nDC, nSaveType, oSaveVersus, fDelay);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oTarget, 6.0);
                }
            }
            // Impetuous Endurance - fortitude or will save
            else if(GetLevelByClass(CLASS_TYPE_KNIGHT, oTarget) > 16)
            {
                // Reroll
                nSaveRoll = BWSavingThrow(nSavingThrow, oTarget, nDC, nSaveType, oSaveVersus, fDelay);
            }
        }
    }
    //Serene Guardian Unclouded Mind
    int nSerene = GetLevelByClass(CLASS_TYPE_SERENE_GUARDIAN, oTarget);
    //Applies on failed will saves from 9th level on
    if (nSaveRoll == 1 && nSavingThrow == SAVING_THROW_WILL && nSerene >= 9)
    {
        if (GetIsSkillSuccessful(oTarget, SKILL_CONCENTRATION, nDC)) // Concentration check to beat the DC
            nSaveRoll = 0;
    }
    
    // Iron Mind Barbed Mind ability
    if(nSaveRoll == 1 && nSaveType == SAVING_THROW_TYPE_MIND_SPELLS)
    {
        // Only works in Heavy Armour
        if(GetLevelByClass(CLASS_TYPE_IRONMIND, oTarget) > 9
        && GetBaseAC(GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget)) > 5)
        {
            // Spell/Power caster takes 1d6 damage and 1 Wisdom damage
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(), DAMAGE_TYPE_MAGICAL), oSaveVersus);
            ApplyAbilityDamage(oSaveVersus, ABILITY_WISDOM, 1, DURATION_TYPE_TEMPORARY, TRUE, -1.0);
        }
    }
    
    // Hobgoblin Warsoul spell eater
    if(nSaveRoll == 1 && GetRacialType(oTarget) == RACIAL_TYPE_HOBGOBLIN_WARSOUL)
    {
        //Apply the Aid VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HOLY_AID), oTarget);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackIncrease(2), oTarget, 6.0);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectTemporaryHitpoints(5), oTarget, 60.0);
    }    

    return nSaveRoll;
}


int PRCGetReflexAdjustedDamage(int nDamage, object oTarget, int nDC, int nSaveType = SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF)
{
    int nEvasion;
    if(GetHasFeat(FEAT_IMPROVED_EVASION, oTarget))
        nEvasion = 2;
    else if(GetHasFeat(FEAT_EVASION, oTarget))
        nEvasion = 1;
    
    // Grants evasion against dragons, don't override if they've already gotit
    object oWOL = GetItemPossessedBy(oTarget, "WOL_CrimsonRuination");  
    if(oWOL != GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget) && MyPRCGetRacialType(oSaveVersus) == RACIAL_TYPE_DRAGON && 1 > nEvasion)
        nEvasion = 1;

    // This ability removes evasion from the target
    if(GetLocalInt(oTarget, "TrueConfoundingResistance"))
    {
        if(nEvasion)
            nEvasion -= 1;
        else
            nDC += 2;
    }

    //Get saving throw result
    int nSaveRoll = PRCMySavingThrow(SAVING_THROW_REFLEX, oTarget, nDC, nSaveType, oSaveVersus);

    //save success
    if(nSaveRoll)
        nDamage = nEvasion ? 0 : nDamage / 2;
    //save failed - check improved evasion
    else if(nEvasion == 2)
        nDamage = nDamage / 2;

    return nDamage;
}

// function for internal use in GetCasterLvl

// caster level for arcane base classes (with practiced spellcaster feats)
int GetCasterLvlArcane(int iClassType, object oCaster)
{
    if (GetPrimaryArcaneClass(oCaster) == iClassType)
        return GetLevelByTypeArcane(oCaster);

    int iTemp = GetLevelByClass(iClassType, oCaster);
    iTemp += PracticedSpellcasting(oCaster, iClassType, iTemp);
    return iTemp;
}

// caster level for classes with half progression
int GetCasterLvlArcaneSemi(int iClassType, object oCaster)
{
    if (GetPrimaryArcaneClass(oCaster) == iClassType)
        return GetLevelByTypeArcane(oCaster);

    int iTemp = GetLevelByClass(iClassType, oCaster) / 2;
    iTemp += PracticedSpellcasting(oCaster, iClassType, iTemp);
    return iTemp;
}

// caster level for divine base classes (with practiced spellcaster feats)
int GetCasterLvlDivine(int iClassType, object oCaster)
{
    if (GetPrimaryDivineClass(oCaster) == iClassType)
        return GetLevelByTypeDivine(oCaster);

    int iTemp = GetLevelByClass(iClassType, oCaster);
    iTemp += PracticedSpellcasting(oCaster, iClassType, iTemp);
    return iTemp;
}

// caster level for classes with half progression
int GetCasterLvlDivineSemi(int iClassType, object oCaster)
{
    if (GetPrimaryDivineClass(oCaster) == iClassType)
        return GetLevelByTypeDivine(oCaster);

    int iTemp = GetLevelByClass(iClassType, oCaster) / 2;
    iTemp += PracticedSpellcasting(oCaster, iClassType, iTemp);
    return iTemp;
}

int GetCasterLvl(int iTypeSpell, object oCaster = OBJECT_SELF)
{
    switch (iTypeSpell)
    {
        case TYPE_ARCANE:
            return GetLevelByTypeArcane(oCaster);

        case TYPE_DIVINE:
            return GetLevelByTypeDivine(oCaster);

        case CLASS_TYPE_SORCERER:
        {
            if (GetPrimaryArcaneClass(oCaster) == CLASS_TYPE_SORCERER)
                return GetLevelByTypeArcane(oCaster);

            if(!GetLevelByClass(CLASS_TYPE_SORCERER, oCaster))
            {
                int iTemp;
                int nRace = GetRacialType(oCaster);

                //Aranea include shapechanger HD as sorc
                if(nRace == RACIAL_TYPE_ARANEA)
                    iTemp = GetLevelByClass(CLASS_TYPE_SHAPECHANGER, oCaster);
					
                //Rakshasa include outsider HD as sorc
                if(nRace == RACIAL_TYPE_RAKSHASA)
                    iTemp = GetLevelByClass(CLASS_TYPE_OUTSIDER, oCaster);

                //Drider include aberration HD as sorc
                if(nRace == RACIAL_TYPE_DRIDER)
                    iTemp = GetLevelByClass(CLASS_TYPE_ABERRATION, oCaster);

                //Arkamoi + Redspawn include MH HD as sorc
                if(nRace == RACIAL_TYPE_ARKAMOI) 
                    iTemp = GetLevelByClass(CLASS_TYPE_MONSTROUS, oCaster);
                if(nRace == RACIAL_TYPE_HOBGOBLIN_WARSOUL) 
                    iTemp = GetLevelByClass(CLASS_TYPE_MONSTROUS, oCaster);                    
                if(nRace == RACIAL_TYPE_REDSPAWN_ARCANISS) 
                    iTemp = GetLevelByClass(CLASS_TYPE_MONSTROUS, oCaster)*3/4;    
                if(nRace == RACIAL_TYPE_MARRUTACT) 
                    iTemp = GetLevelByClass(CLASS_TYPE_MONSTROUS, oCaster)*6/7;                       
                    
                iTemp += PracticedSpellcasting(oCaster, CLASS_TYPE_SORCERER, iTemp);
                iTemp += DraconicPower(oCaster);
                return iTemp;
            }
        }
        
        case CLASS_TYPE_BARD:
        {
            if (GetPrimaryArcaneClass(oCaster) == CLASS_TYPE_BARD)
                return GetLevelByTypeArcane(oCaster);

            if(!GetLevelByClass(CLASS_TYPE_BARD, oCaster))
            {
                int iTemp;
                int nRace = GetRacialType(oCaster);

                //Gloura include fey HD as bard
                if(nRace == RACIAL_TYPE_GLOURA)
                    iTemp = GetLevelByClass(CLASS_TYPE_FEY, oCaster);   
                    
                iTemp += PracticedSpellcasting(oCaster, CLASS_TYPE_BARD, iTemp);
                iTemp += DraconicPower(oCaster);
                return iTemp;
            }
        }        

        case CLASS_TYPE_ASSASSIN:
        case CLASS_TYPE_CELEBRANT_SHARESS:
        case CLASS_TYPE_BEGUILER:
        case CLASS_TYPE_CULTIST_SHATTERED_PEAK:
        case CLASS_TYPE_DREAD_NECROMANCER:
        case CLASS_TYPE_DUSKBLADE:
        case CLASS_TYPE_SHADOWLORD:
        case CLASS_TYPE_SUEL_ARCHANAMACH:
        case CLASS_TYPE_WARMAGE:
        case CLASS_TYPE_WIZARD:
            return GetCasterLvlArcane(iTypeSpell, oCaster);

        case CLASS_TYPE_HEXBLADE:
            return GetCasterLvlArcaneSemi(iTypeSpell, oCaster);

        case CLASS_TYPE_ARCHIVIST:
        case CLASS_TYPE_BLACKGUARD:
        case CLASS_TYPE_BLIGHTER:
        case CLASS_TYPE_CLERIC:
        case CLASS_TYPE_DRUID:
        case CLASS_TYPE_FAVOURED_SOUL:
        case CLASS_TYPE_HEALER:
        case CLASS_TYPE_KNIGHT_CHALICE:
        case CLASS_TYPE_KNIGHT_MIDDLECIRCLE:
        case CLASS_TYPE_NENTYAR_HUNTER:
        case CLASS_TYPE_OCULAR:
        case CLASS_TYPE_SHAMAN:
        case CLASS_TYPE_SLAYER_OF_DOMIEL:
        case CLASS_TYPE_SOLDIER_OF_LIGHT:
        case CLASS_TYPE_UR_PRIEST:
        case CLASS_TYPE_VASSAL:
            return GetCasterLvlDivine(iTypeSpell, oCaster);

        case CLASS_TYPE_PALADIN:
        case CLASS_TYPE_RANGER:
        case CLASS_TYPE_SOHEI:
            return GetCasterLvlDivineSemi(iTypeSpell, oCaster);
    }
    return 0;
}


////////////////Begin Spellsword//////////////////

void SetAllAoEInts(int SpellID, object oAoE, int nBaseSaveDC, int SpecDispel = 0, int nCasterLevel = 0)
{
    if(!GetLocalInt(oAoE, "X2_AoE_BaseSaveDC"))//DC should always be > 0
    {
        SetLocalInt(oAoE, "X2_AoE_SpellID", SpellID);
        SetLocalInt(oAoE, "X2_AoE_BaseSaveDC", nBaseSaveDC);
        if(SpecDispel) SetLocalInt(oAoE, "X2_AoE_SpecDispel", SpecDispel);
        if(!nCasterLevel) nCasterLevel = PRCGetCasterLevel();
        SetLocalInt(oAoE, "X2_AoE_Caster_Level", nCasterLevel);
        if(GetHasFeat(FEAT_SHADOWWEAVE)) SetLocalInt(oAoE, "X2_AoE_Weave", TRUE);
    }
}

//GetNextObjectInShape wrapper for changing the AOE of the channeled spells
object MyNextObjectInShape(int nShape,
                           float fSize, location lTarget,
                           int bLineOfSight = FALSE,
                           int nObjectFilter = OBJECT_TYPE_CREATURE,
                           vector vOrigin=[0.0, 0.0, 0.0])
{
    object oCaster = OBJECT_SELF;

    // War Wizard of Cormyr's Widen Spell ability
    float fMulti = GetLocalFloat(oCaster, PRC_SPELL_AREA_SIZE_MULTIPLIER);
    //if(DEBUG) DoDebug("Original Spell Size: " + FloatToString(fSize)+"\n" + "Widened Multiplier: " + FloatToString(fMulti));

    float fHFInfusion = GetLocalFloat(oCaster, "PRC_HF_Infusion_Wid");
    if(fHFInfusion > 0.0f)
    {
        object oItem = PRCGetSpellCastItem(oCaster);
        if(GetIsObjectValid(oItem) && GetItemPossessor(oItem) == oCaster)
        {
            //Hellfire Infusion - doesn't work on scrolls and potions
            int nType = GetBaseItemType(oItem);
            if(nType != BASE_ITEM_POTIONS && nType != BASE_ITEM_ENCHANTED_POTION
            && nType != BASE_ITEM_SCROLL && nType != BASE_ITEM_ENCHANTED_SCROLL)
            {
                fMulti = fHFInfusion;
                DelayCommand(1.0, DeleteLocalFloat(oCaster, "PRC_HF_Infusion_Wid"));
            }
        }
    }

    if(fMulti > 0.0)
    {
        fSize *= fMulti;
        if(DEBUG) DoDebug("New Spell Size: " + FloatToString(fSize));
    }

    if(GetLocalInt(oCaster, "spellswd_aoe") == 1)
    {
        return OBJECT_INVALID;
    }

    return GetNextObjectInShape(nShape,fSize,lTarget,bLineOfSight,nObjectFilter,vOrigin);
}

//GetFirstObjectInShape wrapper for changing the AOE of the channeled spells
object MyFirstObjectInShape(int nShape,
                            float fSize, location lTarget,
                            int bLineOfSight = FALSE,
                            int nObjectFilter = OBJECT_TYPE_CREATURE,
                            vector vOrigin=[0.0, 0.0, 0.0])
{
    object oCaster = OBJECT_SELF;

    //int on caster for the benefit of spellfire wielder resistance
    // string sName = "IsAOE_" + IntToString(GetSpellId());
    string sName = "IsAOE_" + IntToString(PRCGetSpellId(oCaster));

    SetLocalInt(oCaster, sName, 1);
    DelayCommand(0.1, DeleteLocalInt(oCaster, sName));

    // War Wizard of Cormyr's Widen Spell ability
    float fMulti = GetLocalFloat(oCaster, PRC_SPELL_AREA_SIZE_MULTIPLIER);
    //if(DEBUG) DoDebug("Original Spell Size: " + FloatToString(fSize)+"\n" + "Widened Multiplier: " + FloatToString(fMulti));

    float fHFInfusion = GetLocalFloat(oCaster, "PRC_HF_Infusion_Wid");
    if(fHFInfusion > 0.0f)
    {
        object oItem = PRCGetSpellCastItem(oCaster);
        if(GetIsObjectValid(oItem) && GetItemPossessor(oItem) == oCaster)
        {
            //Hellfire Infusion - doesn't work on scrolls and potions
            int nType = GetBaseItemType(oItem);
            if(nType != BASE_ITEM_POTIONS && nType != BASE_ITEM_ENCHANTED_POTION
            && nType != BASE_ITEM_SCROLL && nType != BASE_ITEM_ENCHANTED_SCROLL)
            {
                fMulti = fHFInfusion;
                DelayCommand(1.0, DeleteLocalFloat(oCaster, "PRC_HF_Infusion_Wid"));
            }
        }
    }

    if(fMulti > 0.0)
    {
        fSize *= fMulti;
        if(DEBUG) DoDebug("New Spell Size: " + FloatToString(fSize));

        // This allows it to affect the entire casting
        DelayCommand(1.0, DeleteLocalFloat(oCaster, PRC_SPELL_AREA_SIZE_MULTIPLIER));
    }

    if(GetLocalInt(oCaster, "spellswd_aoe") == 1)
    {
        return PRCGetSpellTargetObject(oCaster);
    }

    return GetFirstObjectInShape(nShape,fSize,lTarget,bLineOfSight,nObjectFilter,vOrigin);
}


//This checks if the spell is channeled and if there are multiple spells
//channeled, which one is it. Then it checks in either case if the spell
//has the metamagic feat the function gets and returns TRUE or FALSE accordingly
//Also used by the new spellbooks for the same purpose
/* replaced by wrapper for GetMetaMagicFeat instead
   Not necessarily. This may still be a usefule level of abstraction - Ornedan
   */
int CheckMetaMagic(int nMeta,int nMMagic)
{
    return nMeta & nMMagic;
}

int PRCGetMetaMagicFeat(object oCaster = OBJECT_SELF, int bClearFeatFlags = TRUE)
{
    int nOverride = GetLocalInt(oCaster, PRC_METAMAGIC_OVERRIDE);
    if(nOverride)
    {
        if (DEBUG) DoDebug("PRCGetMetaMagicFeat: found override metamagic = "+IntToString(nOverride)+", original = "+IntToString(GetMetaMagicFeat()));
        return nOverride;
    }

    object oItem = PRCGetSpellCastItem(oCaster);

    // we assume that we are casting from an item, if the item is valid and the item belongs to oCaster
    // however, we cannot be sure because of Bioware's inadequate implementation of GetSpellCastItem
    if(GetIsObjectValid(oItem) && GetItemPossessor(oItem) == oCaster)
    {
        int nFeat;

        //check item for metamagic
        itemproperty ipTest = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ipTest))
        {
            if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_CAST_SPELL_METAMAGIC)
            {
                int nSubType = GetItemPropertySubType(ipTest);
                nSubType = StringToInt(Get2DACache("iprp_spells", "SpellIndex", nSubType));
                if(nSubType == PRCGetSpellId(oCaster))
                {
                    int nCostValue = GetItemPropertyCostTableValue(ipTest);
                    if(nCostValue == -1 && DEBUG)
                        DoDebug("Problem examining itemproperty");
                    switch(nCostValue)
                    {
                        //bitwise "addition" equivalent to nFeat = (nFeat | nSSFeat)
                        case 1: nFeat |= METAMAGIC_QUICKEN;  break;
                        case 2: nFeat |= METAMAGIC_EMPOWER;  break;
                        case 3: nFeat |= METAMAGIC_EXTEND;   break;
                        case 4: nFeat |= METAMAGIC_MAXIMIZE; break;
                        case 5: nFeat |= METAMAGIC_SILENT;   break;
                        case 6: nFeat |= METAMAGIC_STILL;    break;
                    }
                }
            }
            ipTest = GetNextItemProperty(oItem);
        }
        if (DEBUG) DoDebug("PRCGetMetaMagicFeat: item casting with item = "+GetName(oItem)+", found metamagic = "+IntToString(nFeat));

        //Hellfire Infusion - doesn't work on scrolls and potions
        int nType = GetBaseItemType(oItem);
        if(nType != BASE_ITEM_POTIONS && nType != BASE_ITEM_ENCHANTED_POTION
        && nType != BASE_ITEM_SCROLL && nType != BASE_ITEM_ENCHANTED_SCROLL)
        {
            nFeat |= GetLocalInt(oCaster, "PRC_HF_Infusion");
            if(bClearFeatFlags) DeleteLocalInt(oCaster, "PRC_HF_Infusion");
        }

        //apply metamagic adjustment (chanell spell)
        nFeat |= GetLocalInt(oCaster, PRC_METAMAGIC_ADJUSTMENT);
        return nFeat;
    }

    if(GetLocalInt(oCaster, "PRC_SPELL_EVENT"))
    {
        if (DEBUG) DoDebug("PRCGetMetaMagicFeat: found spell event metamagic = "+IntToString(GetLocalInt(oCaster, "PRC_SPELL_METAMAGIC"))+", original = "+IntToString(GetMetaMagicFeat()));
        return GetLocalInt(oCaster, "PRC_SPELL_METAMAGIC");
    }

    int nFeat = GetMetaMagicFeat();
    if(nFeat == METAMAGIC_ANY)
        // work around for spontaneous casters (bard or sorcerer) having all metamagic turned on when using ActionCastSpell*
        nFeat = METAMAGIC_NONE;

    nFeat |= GetLocalInt(oCaster, PRC_METAMAGIC_ADJUSTMENT);

    int nClass = PRCGetLastSpellCastClass(oCaster);
    // Suel Archanamach's Extend spells they cast on themselves.
    // Only works for Suel Spells, and not any other caster type they might have
    // Since this is a spellscript, it assumes OBJECT_SELF is the caster
    if(nClass == CLASS_TYPE_SUEL_ARCHANAMACH
    && GetLevelByClass(CLASS_TYPE_SUEL_ARCHANAMACH) >= 3)
    {
        // Check that they cast on themselves
        // if (oCaster == PRCGetSpellTargetObject())
        if(oCaster == PRCGetSpellTargetObject(oCaster))
        {
            // Add extend to the metamagic feat using bitwise math
            nFeat |= METAMAGIC_EXTEND;
        }
    }
    //Code for the Abjurant Champion. Works similar to the Suel Archamamach but
    //their extend only works on abjuration spells they cast.
    if(GetHasFeat(FEAT_EXTENDED_ABJURATION, oCaster)
    && GetLevelByClass(CLASS_TYPE_ABJURANT_CHAMPION) >= 1)
    {
        int nSpellSchool = GetLocalInt(oCaster, "X2_L_LAST_SPELLSCHOOL_VAR");
        // Check that they cast an abjuration spell
        if(nSpellSchool == SPELL_SCHOOL_ABJURATION)
        {
            // Add extend to the metamagic feat using bitwise math
            nFeat |= METAMAGIC_EXTEND;
            if (DEBUG) FloatingTextStringOnCreature("Extended Abjuration Applied", oCaster, FALSE);
        }
    }
    // Magical Contraction, Truenaming Utterance
    if(GetHasSpellEffect(UTTER_MAGICAL_CONTRACTION_R, oCaster))
    //(GetLocalInt(oCaster, "TrueMagicalContraction"))
    {
        nFeat |= METAMAGIC_EMPOWER;
    }
    // Sudden Metamagic
    int nSuddenMeta = GetLocalInt(oCaster, "SuddenMeta");
    if(nSuddenMeta)
    {
        nFeat |= nSuddenMeta;
        if(bClearFeatFlags)
            DeleteLocalInt(oCaster, "SuddenMeta");
    }

    int nDivMeta = GetLocalInt(oCaster, "DivineMeta");
    if(nDivMeta)
    {
        if(GetIsDivineClass(nClass, oCaster))
        {
            nFeat |= nDivMeta;
            if(bClearFeatFlags)
                DeleteLocalInt(oCaster, "DivineMeta");
        }
    }

    int nSpelldance = GetLocalInt(oCaster, "Spelldance");
    if(nSpelldance)
    {
        nFeat |= nSpelldance;
        if (DEBUG) FloatingTextStringOnCreature("Metamagic Spelldances applied", oCaster, FALSE);
    }    
    
    int nSpellLevel = PRCGetSpellLevel(oCaster, PRCGetSpellId());
    if (GetLocalInt(oCaster, "Aradros_Extend")/* && GetIsArcaneClass(nClass, oCaster)*/)
    {
        if (DEBUG) DoDebug("PRCGetMetaMagicFeat: GetIsArcaneClass is TRUE");
        int nHD = GetHitDice(oCaster);
        if (nHD >= 12 && 6 >= nSpellLevel) 
        {
            nFeat |= METAMAGIC_EXTEND;
            DeleteLocalInt(oCaster, "Aradros_Extend");
            if (DEBUG) FloatingTextStringOnCreature("Aradros Extend Applied", oCaster, FALSE);
        }  
        else if (3 >= nSpellLevel) 
        {
            nFeat |= METAMAGIC_EXTEND;
            DeleteLocalInt(oCaster, "Aradros_Extend");
            if (DEBUG) FloatingTextStringOnCreature("Aradros Extend Applied", oCaster, FALSE);
        }        
    }

    if (DEBUG) DoDebug("PRCGetMetaMagicFeat: nSpellLevel " +IntToString(nSpellLevel)+", PRCGetSpellId " +IntToString(PRCGetSpellId())+", nClass " +IntToString(nClass));
    if (DEBUG) DoDebug("PRCGetMetaMagicFeat: returning " +IntToString(nFeat));
    return nFeat;
}

//Wrapper for The MaximizeOrEmpower function
int PRCMaximizeOrEmpower(int nDice, int nNumberOfDice, int nMeta, int nBonus = 0)
{
    int i, nDamage;
    for (i = 1; i <= nNumberOfDice; i++)
    {
        nDamage = nDamage + Random(nDice) + 1;
    }

    //Resolve metamagic
    if(nMeta & METAMAGIC_MAXIMIZE)
        nDamage = nDice * nNumberOfDice;
    if(nMeta & METAMAGIC_EMPOWER)
       nDamage = nDamage + nDamage / 2;

    return nDamage + nBonus;
}

float PRCGetMetaMagicDuration(float fDuration, int nMeta = -1)
{
    if(nMeta == -1) // no metamagic value was passed, so get it here
        nMeta = PRCGetMetaMagicFeat();

    if(nMeta & METAMAGIC_EXTEND)
        fDuration *= 2;

    return fDuration;
}

int PRCGetMetaMagicDamage(int nDamageType, int nDice, int nDieSize,
    int nBonusPerDie = 0, int nBonus = 0, int nMetaMagic = -1)
{
    // If the metamagic argument wasn't given get it.
    if (-1 == nMetaMagic) nMetaMagic = PRCGetMetaMagicFeat();

    // Roll the damage, applying metamagic.
    int nDamage = PRCMaximizeOrEmpower(nDieSize, nDice, nMetaMagic, (nBonusPerDie * nDice) + nBonus);
    return nDamage;
}

void PRCSetSchool(int nSchool = SPELL_SCHOOL_GENERAL)
{
    // Remove the last value in case it is there and set the new value if it is NOT general.
    if(SPELL_SCHOOL_GENERAL != nSchool)
        SetLocalInt(OBJECT_SELF, "X2_L_LAST_SPELLSCHOOL_VAR", nSchool);
    else
        DeleteLocalInt(OBJECT_SELF, "X2_L_LAST_SPELLSCHOOL_VAR");
}

void PRCSignalSpellEvent(object oTarget, int bHostile = TRUE, int nSpellID = -1, object oCaster = OBJECT_SELF)
{
    if (-1 == nSpellID) nSpellID = PRCGetSpellId();

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oCaster, nSpellID, bHostile));
}
/*
void SPEvilShift(object oPC)
{
    // Check for alignment shift switch being active
    if(GetPRCSwitch(PRC_SPELL_ALIGNMENT_SHIFT))
    {
        // Amount of adjustment is equal to the square root of your distance from pure evil.
        // In other words, the amount of shift is higher the farther you are from pure evil, with the
        // extremes being 10 points of shift at pure good and 0 points of shift at pure evil.
        AdjustAlignment(oPC, ALIGNMENT_EVIL,  FloatToInt(sqrt(IntToFloat(GetGoodEvilValue(oPC)))), FALSE);
    }
}

void SPGoodShift(object oPC)
{
    // Check for alignment shift switch being active
    if(GetPRCSwitch(PRC_SPELL_ALIGNMENT_SHIFT))
    {
        // Amount of adjustment is equal to the square root of your distance from pure good.
        // In other words, the amount of shift is higher the farther you are from pure good, with the
        // extremes being 10 points of shift at pure evil and 0 points of shift at pure good.
        AdjustAlignment(oPC, ALIGNMENT_GOOD, FloatToInt(sqrt(IntToFloat(100 - GetGoodEvilValue(oPC)))), FALSE);
    }
}*/

void DoCorruptionCost(object oPC, int nAbility, int nCost, int bDrain)
{
    // Undead redirect all damage & drain to Charisma, sez http://www.wizards.com/dnd/files/BookVileFAQ12102002.zip
    if(MyPRCGetRacialType(oPC) == RACIAL_TYPE_UNDEAD)
        nAbility = ABILITY_CHARISMA;

    //Exalted Raiment
    if(GetHasSpellEffect(SPELL_EXALTED_RAIMENT, GetItemInSlot(INVENTORY_SLOT_CHEST, oPC)))
    {
        nCost -= 1;

        if(nCost < 1)
            nCost = 1;
    }
    
    if (GetHasFeat(FEAT_FAVORED_ZULKIRS, oPC)) nCost -= 1;

    // Is it ability drain?
    if(bDrain)
        ApplyAbilityDamage(oPC, nAbility, nCost, DURATION_TYPE_PERMANENT, TRUE);
    // Or damage
    else
        ApplyAbilityDamage(oPC, nAbility, nCost, DURATION_TYPE_TEMPORARY, TRUE, -1.0f);
}

//:: Fix by TiredByFirelight
void MultisummonPreSummon(object oPC = OBJECT_SELF, int bOverride = FALSE)
{
    if(!GetPRCSwitch(PRC_MULTISUMMON) && !bOverride)
        return;
    int nCount = GetPRCSwitch(PRC_MULTISUMMON);    
    if(bOverride)
        nCount = bOverride;
    if(nCount < 0
        || nCount == 1)
        nCount = 99;
    if(nCount > 99)
        nCount = 99;
    
    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, nCount);
    if(!GetIsObjectValid(oSummon) && !GetLocalInt(oSummon, "RFSummonedElemental"))
    {
        oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, 1);    
        AssignCommand(oSummon, SetIsDestroyable(FALSE, FALSE, FALSE));
        AssignCommand(oSummon, DelayCommand(0.3, SetIsDestroyable(TRUE, FALSE, FALSE)));    
    }
}

/* void MultisummonPreSummon(object oPC = OBJECT_SELF, int bOverride = FALSE)
{
    if(!GetPRCSwitch(PRC_MULTISUMMON) && !bOverride)
        return;
    int i=1;
    int nCount = GetPRCSwitch(PRC_MULTISUMMON);
    if(bOverride)
        nCount = bOverride;
    if(nCount < 0
        || nCount == 1)
        nCount = 99;
    if(nCount > 99)
        nCount = 99;
    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, i);
    while(GetIsObjectValid(oSummon) && !GetLocalInt(oSummon, "RFSummonedElemental") && i < nCount)
    {
        AssignCommand(oSummon, SetIsDestroyable(FALSE, FALSE, FALSE));
        AssignCommand(oSummon, DelayCommand(0.3, SetIsDestroyable(TRUE, FALSE, FALSE)));
        i++;
        oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, i);
    }
} */


//This function returns 1 only if the object oTarget is the object
//the weapon hit when it channeled the spell sSpell or if there is no
//channeling at all
int ChannelChecker(string sSpell, object oTarget)
{
    int nSpell = GetLocalInt(GetAreaOfEffectCreator(), sSpell+"channeled");
    int nTarget = GetLocalInt(oTarget, sSpell+"target");
    if(nSpell == 1 && nTarget == 1)
    {
        return 1;
    }
    else if(nSpell != 1 && nTarget != 1)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

//If a spell is being channeled, we store its target and its name
void StoreSpellVariables(string sString,int nDuration)
{
    object oCaster = OBJECT_SELF;
    object oTarget = GetSpellTargetObject();     //using prc version could cause problems

    if(GetLocalInt(oCaster,"spellswd_aoe") == 1)
    {
        SetLocalInt(oCaster, sString+"channeled",1);
        SetLocalInt(oTarget, sString+"target",1);
    }
    DelayCommand(RoundsToSeconds(nDuration),DeleteLocalInt(oTarget, sString+"target"));
    DelayCommand(RoundsToSeconds(nDuration),DeleteLocalInt(oCaster, sString+"channeled"));
}

effect ChannelingVisual()
{
    return EffectVisualEffect(VFX_DUR_SPELLTURNING);
}

////////////////End Spellsword//////////////////


int GetHasMettle(object oTarget, int nSavingThrow = SAVING_THROW_WILL)
{
    if(GetLevelByClass(CLASS_TYPE_HEXBLADE, oTarget) >  2) return TRUE;
    if(GetLevelByClass(CLASS_TYPE_SOHEI, oTarget)    >  8) return TRUE;
    if(GetLevelByClass(CLASS_TYPE_CRUSADER, oTarget) > 12) return TRUE;
    if(GetLocalInt(oTarget, "FactotumMettle")) return TRUE;

    if(nSavingThrow = SAVING_THROW_WILL)
    {
        // Iron Mind's ability only functions in Heavy Armour
        if(GetLevelByClass(CLASS_TYPE_IRONMIND, oTarget) > 4
        && GetBaseAC(GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget)) > 5)
            return TRUE;
        // Fill out the line below to add another class with Will mettle
        // if (GetLevelByClass(CLASS_TYPE_X, oTarget) >= X) return TRUE;
    }
    /*else if(nSavingThrow = SAVING_THROW_FORT)
    {
        // Add Classes with Fort mettle here
        // if (GetLevelByClass(CLASS_TYPE_X, oTarget) >= X) return TRUE;
    }*/

    return FALSE;
}

void DoCommandSpell(object oCaster, object oTarget, int nSpellId, int nDuration, int nCaster)
{
    if(DEBUG) DoDebug("DoCommandSpell: SpellId: " + IntToString(nSpellId));
    if(DEBUG) DoDebug("Command Spell: Begin");
    if(nSpellId == SPELL_COMMAND_APPROACH
    || nSpellId == SPELL_GREATER_COMMAND_APPROACH
    || nSpellId == 18359 //MYST_VOICE_SHADOW_APPROACH
    || nSpellId == SPELL_DOA_COMMAND_APPROACH
    || nSpellId == SPELL_DOA_GREATER_COMMAND_APPROACH)
    {
        // Force the target to approach the caster
        if(DEBUG) DoDebug("Command Spell: Approach");
        AssignCommand(oTarget, ClearAllActions(TRUE));
        AssignCommand(oTarget, ActionForceMoveToObject(oCaster, TRUE));
    }
    // Creatures that can't be disarmed ignore this
    else if(nSpellId == SPELL_COMMAND_DROP
    || nSpellId == SPELL_GREATER_COMMAND_DROP
    || nSpellId == 18360 //MYST_VOICE_SHADOW_DROP
    || nSpellId == SPELL_DOA_COMMAND_DROP
    || nSpellId == SPELL_DOA_GREATER_COMMAND_DROP)
    {
        if(GetIsCreatureDisarmable(oTarget) && !GetPRCSwitch(PRC_PNP_DISARM))
        {
            // Force the target to drop what its holding
            if(DEBUG) DoDebug("Command Spell: Drop");
            AssignCommand(oTarget, ClearAllActions(TRUE));
            object oTargetWep = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
			SetDroppableFlag(oTargetWep, TRUE);
            SetStolenFlag(oTargetWep, FALSE);              
            AssignCommand(oTarget, ActionPutDownItem(oTargetWep));              
            /*oTargetWep = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
			SetDroppableFlag(oTargetWep, TRUE);
            SetStolenFlag(oTargetWep, FALSE);              
            AssignCommand(oTarget, ActionPutDownItem(oTargetWep));     */
        }
        else
        {
            FloatingTextStringOnCreature(GetName(oTarget) + " is not disarmable.", oCaster, FALSE);
        }
    }
    else if(nSpellId == SPELL_COMMAND_FALL
    || nSpellId == SPELL_GREATER_COMMAND_FALL
    || nSpellId == 18361 //MYST_VOICE_SHADOW_FALL
    || nSpellId == SPELL_DOA_COMMAND_FALL
    || nSpellId == SPELL_DOA_GREATER_COMMAND_FALL)
    {
        // Force the target to fall down
        if(DEBUG) DoDebug("Command Spell: Fall");
        AssignCommand(oTarget, ClearAllActions(TRUE));
        SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oTarget, RoundsToSeconds(nDuration),TRUE,-1,nCaster);
    }
    else if(nSpellId == SPELL_COMMAND_FLEE
    || nSpellId == SPELL_GREATER_COMMAND_FLEE
    || nSpellId == 18362 //MYST_VOICE_SHADOW_FLEE
    || nSpellId == SPELL_DOA_COMMAND_FLEE
    || nSpellId == SPELL_DOA_GREATER_COMMAND_FLEE)
    {
        // Force the target to flee the caster
        if(DEBUG) DoDebug("Command Spell: Flee");
        AssignCommand(oTarget, ClearAllActions(TRUE));
        AssignCommand(oTarget, ActionMoveAwayFromObject(oCaster, TRUE));
    }
    else if(nSpellId == SPELL_COMMAND_HALT
    || nSpellId == SPELL_GREATER_COMMAND_HALT
    || nSpellId == 18363 //MYST_VOICE_SHADOW_HALT
    || nSpellId == SPELL_DOA_COMMAND_HALT
    || nSpellId == SPELL_DOA_GREATER_COMMAND_HALT)
    {
        // Force the target to stand still
        if(DEBUG) DoDebug("Command Spell: Stand");
        AssignCommand(oTarget, ClearAllActions(TRUE));
        SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneParalyze(), oTarget, RoundsToSeconds(nDuration),TRUE,-1,nCaster);
    }
    else // Catch errors here
    {
        FloatingTextStringOnCreature("sp_command/sp_greatcommand: Error, Unknown SpellId", oCaster, FALSE);
    }
    if(DEBUG) DoDebug("Command Spell: End");
}

void SetIncorporeal(object oTarget, float fDuration, int nSuperOrEx, int nPermanent = FALSE)
{
    if (!GetIsObjectValid(oTarget))
        return; //No point working 
    
    // Immune to non-magical weapons, ignore physical objects
    effect eIncorporeal = EffectLinkEffects(EffectDamageReduction(100, DAMAGE_POWER_PLUS_ONE, 0), EffectCutsceneGhost());
           eIncorporeal = EffectLinkEffects(eIncorporeal, EffectDamageImmunityIncrease(DAMAGE_TYPE_BLUDGEONING, 50)); // 50% chance of magical weapons not working. Done as 50% Damage Immunity
           eIncorporeal = EffectLinkEffects(eIncorporeal, EffectDamageImmunityIncrease(DAMAGE_TYPE_SLASHING, 50));
           eIncorporeal = EffectLinkEffects(eIncorporeal, EffectDamageImmunityIncrease(DAMAGE_TYPE_PIERCING, 50));
           eIncorporeal = EffectLinkEffects(eIncorporeal, EffectMissChance(50, MISS_CHANCE_TYPE_VS_MELEE)); // 50% melee miss chance to hit non-incorporeal targets. That's going to be everything
           eIncorporeal = EffectLinkEffects(eIncorporeal, EffectSkillIncrease(SKILL_MOVE_SILENTLY, 99)); // Cannot be heard
           eIncorporeal = EffectLinkEffects(eIncorporeal, EffectVisualEffect(VFX_DUR_ETHEREAL_VISAGE)); // Visual effect
           
    // No Strength Score, use Dex for melee attacks too
    int nStr = GetAbilityScore(oTarget, ABILITY_STRENGTH);
    int nDex = GetAbilityModifier(ABILITY_DEXTERITY, oTarget);
    int nPen;
    
    if (nStr>10)
    {
         nPen = nStr - 10; 
         eIncorporeal = EffectLinkEffects(eIncorporeal, EffectAbilityDecrease(ABILITY_STRENGTH, nPen)); // Reduce Strength to 10
             
         object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
         if (GetIsObjectValid(oWeapon) && IPGetIsMeleeWeapon(oWeapon))
         {
             IPSafeAddItemProperty(oWeapon, ItemPropertyAttackBonus(nDex), fDuration); //Dex has to be done as a melee weapon bonus
         }
         oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
         if (GetIsObjectValid(oWeapon) && IPGetIsMeleeWeapon(oWeapon))
         {
             IPSafeAddItemProperty(oWeapon, ItemPropertyAttackBonus(nDex), fDuration); //Dex has to be done as a melee weapon bonus
         }  
         oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTarget);
         if (GetIsObjectValid(oWeapon)) // We know these are melee weapons
         {
             IPSafeAddItemProperty(oWeapon, ItemPropertyAttackBonus(nDex), fDuration); //Dex has to be done as a melee weapon bonus
         }
         oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTarget);
         if (GetIsObjectValid(oWeapon)) // We know these are melee weapons
         {
             IPSafeAddItemProperty(oWeapon, ItemPropertyAttackBonus(nDex), fDuration); //Dex has to be done as a melee weapon bonus
         } 
         oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTarget);
         if (GetIsObjectValid(oWeapon)) // We know these are melee weapons
         {
             IPSafeAddItemProperty(oWeapon, ItemPropertyAttackBonus(nDex), fDuration); //Dex has to be done as a melee weapon bonus
         }         
    }    
    
    SetLocalInt(oTarget, "Incorporeal", TRUE);
    if (!nPermanent) DelayCommand(fDuration, DeleteLocalInt(oTarget, "Incorporeal"));
    
    if (nSuperOrEx == 1)
        eIncorporeal = SupernaturalEffect(eIncorporeal);
    else if (nSuperOrEx == 2)
        eIncorporeal = ExtraordinaryEffect(eIncorporeal); 
        
    if (nPermanent)
        SPApplyEffectToObject(DURATION_TYPE_PERMANENT, eIncorporeal, oTarget);
    else   
        SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eIncorporeal, oTarget, fDuration, FALSE, -1, -1);
}

int GetIsIncorporeal(object oTarget)
{
    //Check for local int
    if(GetPersistantLocalInt(oTarget, "Is_Incorporeal"))
        return TRUE;
        
    //Check for local int
    if(GetLocalInt(oTarget, "Incorporeal"))
        return TRUE;        

    //check for feat
    if(GetHasFeat(FEAT_INCORPOREAL, oTarget))
        return TRUE;

    //base it on appearance
    int nAppear = GetAppearanceType(oTarget);
    if(nAppear == APPEARANCE_TYPE_ALLIP
    || nAppear == APPEARANCE_TYPE_SHADOW
    || nAppear == APPEARANCE_TYPE_SHADOW_FIEND
    || nAppear == APPEARANCE_TYPE_SPECTRE
    || nAppear == APPEARANCE_TYPE_WRAITH)
        return TRUE;

    //Return value
    return FALSE;
}

int GetIsEthereal(object oTarget)
{
    return GetPersistantLocalInt(oTarget, "Is_Ethereal")
         || GetHasFeat(FEAT_ETHEREAL, oTarget);
}

int PRCGetIsAliveCreature(object oTarget)
{
    int bAlive = TRUE;
    // non-creatures aren't alive
    if (GetObjectType(oTarget) != OBJECT_TYPE_CREATURE)
        return FALSE; // night of the living waypoints :p

    int nType = MyPRCGetRacialType(oTarget);

    //Non-living races, excluding warforged
    if(nType == RACIAL_TYPE_UNDEAD ||
       (nType == RACIAL_TYPE_CONSTRUCT && !GetIsWarforged(oTarget))) bAlive = FALSE;

    //If they're dead :P
    if(GetIsDead(oTarget)) bAlive = FALSE;

    //return
    return bAlive;
}

int GetControlledUndeadTotalHD(object oPC = OBJECT_SELF)
{
    int nTotalHD;
    int i = 1;
    object oSummonTest = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, i);
    while(GetIsObjectValid(oSummonTest))
    {
        if(MyPRCGetRacialType(oSummonTest) == RACIAL_TYPE_UNDEAD)
            nTotalHD += GetHitDice(oSummonTest);
        if(DEBUG)FloatingTextStringOnCreature(GetName(oSummonTest)+" is summon number "+IntToString(i), oPC);
        i++;
        oSummonTest = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, i);
    }
    return nTotalHD;
}


int GetControlledFiendTotalHD(object oPC = OBJECT_SELF)
{
    int nTotalHD;
    int i = 1;
    object oSummonTest = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, i);
    while(GetIsObjectValid(oSummonTest))
    {
        if(MyPRCGetRacialType(oSummonTest) == RACIAL_TYPE_OUTSIDER
             && GetAlignmentGoodEvil(oSummonTest) == ALIGNMENT_EVIL)
            nTotalHD += GetHitDice(oSummonTest);
        if(DEBUG)FloatingTextStringOnCreature(GetName(oSummonTest)+" is summon number "+IntToString(i), oPC);
        i++;
        oSummonTest = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, i);
    }
    return nTotalHD;
}

int GetControlledCelestialTotalHD(object oPC = OBJECT_SELF)
{
    int nTotalHD;
    int i = 1;
    object oSummonTest = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, i);
    while(GetIsObjectValid(oSummonTest))
    {
        if(MyPRCGetRacialType(oSummonTest) == RACIAL_TYPE_OUTSIDER
             && GetAlignmentGoodEvil(oSummonTest) == ALIGNMENT_GOOD)
            nTotalHD += GetHitDice(oSummonTest);
        if(DEBUG)FloatingTextStringOnCreature(GetName(oSummonTest)+" is summon number "+IntToString(i), oPC);
        i++;
        oSummonTest = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, i);
    }
    return nTotalHD;
}

//:: Calculates total Shield AC bonuses from all sources
int GetTotalShieldACBonus(object oCreature)
{
    int nShieldBonus = 0;
    object oItem;

    // Check left hand for shield
    oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature);
    if (GetIsObjectValid(oItem))
    {
        int nBaseItem = GetBaseItemType(oItem);
        if (nBaseItem == BASE_ITEM_SMALLSHIELD ||
            nBaseItem == BASE_ITEM_LARGESHIELD ||
            nBaseItem == BASE_ITEM_TOWERSHIELD)
        {
            nShieldBonus += GetItemACValue(oItem);
			if(DEBUG) DoDebug("prc_inc_spells >> GetTotalShieldACBonus: Found Shield AC, bonus = " + IntToString(nShieldBonus)+".");
        }
    }

    // Check creature weapon slots for shield AC bonus
    oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oCreature);
    if (GetIsObjectValid(oItem))
        nShieldBonus += GetItemACValue(oItem);

    oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oCreature);
    if (GetIsObjectValid(oItem))
        nShieldBonus += GetItemACValue(oItem);

    oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oCreature);
    if (GetIsObjectValid(oItem))
        nShieldBonus += GetItemACValue(oItem);
	
	// Add shield AC bonuses from magical effects
	effect eEffect = GetFirstEffect(oCreature);
    while (GetIsEffectValid(eEffect))
    {	
		int nACType = GetEffectInteger(eEffect, 0);
		int nACAmount = GetEffectInteger(eEffect, 1);
		
		if(GetEffectType(eEffect) == EFFECT_TYPE_AC_INCREASE && nACType == AC_SHIELD_ENCHANTMENT_BONUS)
		{
			if(DEBUG) DoDebug("prc_inc_spells >> GetTotalShieldACBonus: Found Shield AC effect, bonus = " + IntToString(nACAmount)+".");
			nShieldBonus += nACAmount;			
		}
		
		eEffect = GetNextEffect(oCreature);		
	}	
	return nShieldBonus;
}		
			
			
	
    // Add shield AC bonuses from magical effects
/*     effect eEffect = GetFirstEffect(oCreature);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect) == EFFECT_TYPE_AC_INCREASE &&
            GetEffectInteger(eEffect, 1) == AC_SHIELD_ENCHANTMENT_BONUS) 
        {
			int nMod = GetEffectInteger(eEffect, 0);
			int nType = GetEffectInteger(eEffect, 1);
			nShieldBonus += GetEffectInteger(eEffect, 0); 
			string s = "Found AC effect: bonus = " + IntToString(nMod) + ", type = " + IntToString(nType);
			SendMessageToPC(GetFirstPC(), s);			
        }
        eEffect = GetNextEffect(oCreature);
    } 

    return nShieldBonus;
}*/
//
//:: Handles psuedo-Foritifcation
void DoFortification(object oPC = OBJECT_SELF, int nFortification = 25)
{
    if(DEBUG) DoDebug("prc_inc_spells >> DoFortification() is running.");
	
	// Get or create the player's skin object
    object oHide = GetPCSkin(oPC);
	
	int nRace = GetRacialType(oPC);

	//else if (nRace == RACIAL_TYPE_WARFORGED && !GetHasFeat(FEAT_IMPROVED_FORTIFICATION, oPC) && !GetHasFeat(FEAT_UNARMORED_BODY, oPC))
	if (nFortification == FORTIFICATION_LIGHT)
	{
		// Apply immunity properties for 1 seconds	
		if(DEBUG) DoDebug("Applying Light Fortification");
		IPSafeAddItemProperty(oHide, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_CRITICAL_HITS), 1.0f);
		IPSafeAddItemProperty(oHide, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_BACKSTAB), 1.0f);	

		// Schedule the next toggle in 4 seconds
		DelayCommand(4.0f, DoFortification(oPC, FORTIFICATION_LIGHT));
	}
	
	else if (nFortification == FORTIFICATION_MEDIUM)	//nRace == RACIAL_TYPE_RETH_DEKALA) 
	{
		// Apply immunity properties for 2 seconds	
		if(DEBUG) DoDebug("Applying Medium Fortification");
		IPSafeAddItemProperty(oHide, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_CRITICAL_HITS), 2.0f);
		IPSafeAddItemProperty(oHide, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_BACKSTAB), 2.0f);	

		// Schedule the next toggle in 4 seconds
		DelayCommand(4.0f, DoFortification(oPC, FORTIFICATION_MEDIUM));
	}

	//else if (nRace == RACIAL_TYPE_WARFORGED_CHARGER && !GetHasFeat(FEAT_IMPROVED_FORTIFICATION, oPC) && !GetHasFeat(FEAT_UNARMORED_BODY, oPC))
	else if (nFortification == FORTIFICATION_MODERATE)
	{
		// Apply immunity properties for 3 seconds	
		if(DEBUG) DoDebug("Applying Moderate Fortification");
		IPSafeAddItemProperty(oHide, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_CRITICAL_HITS), 3.0f);
		IPSafeAddItemProperty(oHide, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_BACKSTAB), 3.0f);	

		// Schedule the next toggle in 4 seconds
		DelayCommand(4.0f, DoFortification(oPC, FORTIFICATION_MODERATE));
	}
	else if (nFortification == FORTIFICATION_HEAVY)
	{
		// Apply immunity properties permenently	
		if(DEBUG) DoDebug("Applying Heavy Fortification");
		IPSafeAddItemProperty(oHide, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_CRITICAL_HITS));
		IPSafeAddItemProperty(oHide, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_BACKSTAB));	
	}		
}
//

// wrapper for DecrementRemainingSpellUses, works for newspellbook 'fake' spells too
// should also find and decrement metamagics for newspellbooks
void PRCDecrementRemainingSpellUses(object oCreature, int nSpell)
{
    if (!UseNewSpellBook(oCreature) && GetHasSpell(nSpell, oCreature))
    {
        DecrementRemainingSpellUses(oCreature, nSpell);
        return;
    }

    int nClass, nSpellbookID, nCount, nMeta, i, j;
    int nSpellbookType, nSpellLevel;
    string sFile, sFeat;
    for(i = 1; i <= 8; i++)
    {
        nClass = GetClassByPosition(i, oCreature);
        sFile = GetFileForClass(nClass);
        nSpellbookType = GetSpellbookTypeForClass(nClass);
        nSpellbookID = RealSpellToSpellbookID(nClass, nSpell);
        nMeta = RealSpellToSpellbookIDCount(nClass, nSpell);
        if (nSpellbookID != -1)
        {   //non-spellbook classes should return -1
            for(j = nSpellbookID; j <= nSpellbookID + nMeta; j++)
            {
                sFeat = Get2DACache(sFile, "ReqFeat", j);
                if(sFeat != "")
                {
                    if(!GetHasFeat(StringToInt(sFeat), oCreature))
                        continue;
                }
                nSpellLevel = StringToInt(Get2DACache(sFile, "Level", j));

                if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
                {
                    nCount = persistant_array_get_int(oCreature, "NewSpellbookMem_" + IntToString(nClass), j);
                    if(DEBUG) DoDebug("PRCDecrementRemainingSpellUses: NewSpellbookMem_" + IntToString(nClass) + "[" + IntToString(j) + "] = " + IntToString(nCount));
                    if(nCount > 0)
                    {
                        persistant_array_set_int(oCreature, "NewSpellbookMem_" + IntToString(nClass), j, nCount - 1);
                        return;
                    }
                }
                else  if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
                {
                    nCount = persistant_array_get_int(oCreature, "NewSpellbookMem_" + IntToString(nClass), nSpellLevel);
                    if(DEBUG) DoDebug("PRCDecrementRemainingSpellUses: NewSpellbookMem_" + IntToString(nClass) + "[" + IntToString(j) + "] = " + IntToString(nCount));
                    if(nCount > 0)
                    {
                        persistant_array_set_int(oCreature, "NewSpellbookMem_" + IntToString(nClass), nSpellLevel, nCount - 1);
                        return;
                    }
                }
            }
        }
    }
    if(DEBUG) DoDebug("PRCDecrementRemainingSpellUses: Spell " + IntToString(nSpell) + " not found");
}

//
//  This function determines if spell damage is elemental
//
int IsSpellDamageElemental(int nDamageType)
{
    return nDamageType & 2480;// 2480 = (DAMAGE_TYPE_ACID | DAMAGE_TYPE_COLD | DAMAGE_TYPE_ELECTRICAL | DAMAGE_TYPE_FIRE | DAMAGE_TYPE_SONIC)
}


//  This function converts spell damage into the correct type
//  TODO: Change the name to consistent (large churn project).
//
//  Updated by: TiredByFirelight
int ChangedElementalDamage(object oCaster, int nDamageType)
{

    // None of the stuff here works when items are involved
    if (GetIsObjectValid(PRCGetSpellCastItem())) return nDamageType;
    
    int nNewType;

    //eldritch spellweave
    if(GetIsObjectValid(GetLocalObject(oCaster, "SPELLWEAVE_TARGET")))
    {
        int nEssence = GetLocalInt(oCaster, "BlastEssence");

        if(nEssence == INVOKE_BRIMSTONE_BLAST)
            nNewType = DAMAGE_TYPE_FIRE;

        else if(nEssence == INVOKE_HELLRIME_BLAST)
            nNewType = DAMAGE_TYPE_COLD;

        else if(nEssence == INVOKE_UTTERDARK_BLAST)
            nNewType = DAMAGE_TYPE_NEGATIVE;

        else if(nEssence == INVOKE_VITRIOLIC_BLAST)
            nNewType = DAMAGE_TYPE_ACID;

        //save new type for other functions
        if(nNewType)
            SetLocalInt(oCaster, "archmage_mastery_elements", nNewType);
    }
    else
        // Check if an override is set
        nNewType = GetLocalInt(oCaster, "archmage_mastery_elements");

    // If so, check if the spell qualifies for a change
    if (!nNewType || !IsSpellDamageElemental(nDamageType))
        nNewType = nDamageType;
        
    if (GetLevelByClass(CLASS_TYPE_FROST_MAGE, oCaster) >= 4 && ((nDamageType == DAMAGE_TYPE_COLD)||nNewType == DAMAGE_TYPE_COLD))
    {
        nNewType = DAMAGE_TYPE_CUSTOM8;    // Untyped
        SendMessageToPC(oCaster, "Piercing Cold - Spell ignores resistance or immunities to cold.");
         
    }

    return nNewType;
}
/* int ChangedElementalDamage(object oCaster, int nDamageType)
{

	// None of the stuff here works when items are involved
	if (GetIsObjectValid(PRCGetSpellCastItem())) return nDamageType;
	
    int nNewType;

    //eldritch spellweave
    if(GetIsObjectValid(GetLocalObject(oCaster, "SPELLWEAVE_TARGET")))
    {
        int nEssence = GetLocalInt(oCaster, "BlastEssence");

        if(nEssence == INVOKE_BRIMSTONE_BLAST)
            nNewType = DAMAGE_TYPE_FIRE;

        else if(nEssence == INVOKE_HELLRIME_BLAST)
            nNewType = DAMAGE_TYPE_COLD;

        else if(nEssence == INVOKE_UTTERDARK_BLAST)
            nNewType = DAMAGE_TYPE_NEGATIVE;

        else if(nEssence == INVOKE_VITRIOLIC_BLAST)
            nNewType = DAMAGE_TYPE_ACID;

        //save new type for other functions
        if(nNewType)
            SetLocalInt(oCaster, "archmage_mastery_elements", nNewType);
    }
    else
        // Check if an override is set
        nNewType = GetLocalInt(oCaster, "archmage_mastery_elements");

    // If so, check if the spell qualifies for a change
    if (!nNewType || !IsSpellDamageElemental(nDamageType))
        nNewType = nDamageType;

    return nNewType;
}
 */
//used in scripts after ChangedElementalDamage() to determine saving throw type
int ChangedSaveType(int nDamageType)
{
    switch(nDamageType)
    {
        case DAMAGE_TYPE_ACID:       return SAVING_THROW_TYPE_ACID;
        case DAMAGE_TYPE_COLD:       return SAVING_THROW_TYPE_COLD;
        case DAMAGE_TYPE_ELECTRICAL: return SAVING_THROW_TYPE_ELECTRICITY;
        case DAMAGE_TYPE_FIRE:       return SAVING_THROW_TYPE_FIRE;
        case DAMAGE_TYPE_SONIC:      return SAVING_THROW_TYPE_SONIC;
        case DAMAGE_TYPE_DIVINE:     return SAVING_THROW_TYPE_DIVINE;
        case DAMAGE_TYPE_NEGATIVE:   return SAVING_THROW_TYPE_NEGATIVE;
        case DAMAGE_TYPE_POSITIVE:   return SAVING_THROW_TYPE_POSITIVE;
    }
    return SAVING_THROW_TYPE_NONE;//if it ever gets here, than the function was used incorrectly
}

// this is possibly used in variations elsewhere
int PRCGetElementalDamageType(int nDamageType, object oCaster = OBJECT_SELF)
{
    switch(nDamageType)
    {
        case DAMAGE_TYPE_ACID:
        case DAMAGE_TYPE_COLD:
        case DAMAGE_TYPE_ELECTRICAL:
        case DAMAGE_TYPE_FIRE:
        case DAMAGE_TYPE_SONIC:
            nDamageType = ChangedElementalDamage(oCaster, nDamageType);
    }
    return nDamageType;
}

int GetHasBaneMagic(int nRace)
{
    switch(nRace)
    {
        case RACIAL_TYPE_ABERRATION:         return GetHasFeat(FEAT_BANE_MAGIC_ABERRATION);
        case RACIAL_TYPE_ANIMAL:             return GetHasFeat(FEAT_BANE_MAGIC_ANIMAL);
        case RACIAL_TYPE_BEAST:              return GetHasFeat(FEAT_BANE_MAGIC_BEAST);
        case RACIAL_TYPE_CONSTRUCT:          return GetHasFeat(FEAT_BANE_MAGIC_CONSTRUCT);
        case RACIAL_TYPE_DRAGON:             return GetHasFeat(FEAT_BANE_MAGIC_DRAGON);
        case RACIAL_TYPE_DWARF:              return GetHasFeat(FEAT_BANE_MAGIC_DWARF);
        case RACIAL_TYPE_ELEMENTAL:          return GetHasFeat(FEAT_BANE_MAGIC_ELEMENTAL);
        case RACIAL_TYPE_ELF:                return GetHasFeat(FEAT_BANE_MAGIC_ELF);
        case RACIAL_TYPE_FEY:                return GetHasFeat(FEAT_BANE_MAGIC_FEY);
        case RACIAL_TYPE_GIANT:              return GetHasFeat(FEAT_BANE_MAGIC_GIANT);
        case RACIAL_TYPE_GNOME:              return GetHasFeat(FEAT_BANE_MAGIC_GNOME);
        case RACIAL_TYPE_HALFELF:            return GetHasFeat(FEAT_BANE_MAGIC_HALFELF);
        case RACIAL_TYPE_HALFLING:           return GetHasFeat(FEAT_BANE_MAGIC_HALFLING);
        case RACIAL_TYPE_HALFORC:            return GetHasFeat(FEAT_BANE_MAGIC_HALFORC);
        case RACIAL_TYPE_HUMAN:              return GetHasFeat(FEAT_BANE_MAGIC_HUMAN);
        case RACIAL_TYPE_HUMANOID_GOBLINOID: return GetHasFeat(FEAT_BANE_MAGIC_HUMANOID_GOBLINOID);
        case RACIAL_TYPE_HUMANOID_MONSTROUS: return GetHasFeat(FEAT_BANE_MAGIC_HUMANOID_MONSTROUS);
        case RACIAL_TYPE_HUMANOID_ORC:       return GetHasFeat(FEAT_BANE_MAGIC_HUMANOID_ORC);
        case RACIAL_TYPE_HUMANOID_REPTILIAN: return GetHasFeat(FEAT_BANE_MAGIC_HUMANOID_REPTILIAN);
        case RACIAL_TYPE_MAGICAL_BEAST:      return GetHasFeat(FEAT_BANE_MAGIC_MAGICAL_BEAST);
        case RACIAL_TYPE_OUTSIDER:           return GetHasFeat(FEAT_BANE_MAGIC_OUTSIDER);
        case RACIAL_TYPE_SHAPECHANGER:       return GetHasFeat(FEAT_BANE_MAGIC_SHAPECHANGER);
        case RACIAL_TYPE_UNDEAD:             return GetHasFeat(FEAT_BANE_MAGIC_UNDEAD);
        case RACIAL_TYPE_VERMIN:             return GetHasFeat(FEAT_BANE_MAGIC_VERMIN);
    }
    return FALSE;
}

void DoPiercingCold(object oCaster, object oTarget, int nDamageAmount, int nCurrentHP)
{
    // Get change in HP from spell damage being applied
    int nTest = nCurrentHP - GetCurrentHitPoints(oTarget);
    // If there's no damage resistance, nTest and nDamageAmount should be equal
    if (nDamageAmount > nTest)
    {
        // Apply the difference to ignore resist
        effect eDam = EffectDamage(nDamageAmount - nTest, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
        effect eVis = EffectVisualEffect(VFX_IMP_FROST_L);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        //FloatingTextStringOnCreature("Piercing Cold Triggered", oCaster, FALSE);
    }
}

void BreakDR(object oCaster, object oTarget, int nDamageAmount, int nCurrentHP)
{
    // Get change in HP from spell damage being applied
    int nTest = nCurrentHP - GetCurrentHitPoints(oTarget);
    // If there's no damage resistance, nTest and nDamageAmount should be equal
    if (nDamageAmount > nTest)
    {
        // Apply the difference to ignore resist
        effect eDam = EffectDamage(nDamageAmount - nTest, DAMAGE_TYPE_POSITIVE, DAMAGE_POWER_ENERGY);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    }
}

effect PRCEffectDamage(object oTarget, int nDamageAmount, int nDamageType=DAMAGE_TYPE_MAGICAL, int nDamagePower=DAMAGE_POWER_NORMAL, int nMetaMagic=METAMAGIC_NONE)
{
    object oCaster = OBJECT_SELF;
    
    // Incorporeal creatures have a 50% chance of not being hurt by damage other than Magical/Divine/Negative
    if (GetLocalInt(oTarget, "Incorporeal") && nDamageType != DAMAGE_TYPE_MAGICAL && nDamageType != DAMAGE_TYPE_NEGATIVE && nDamageType != DAMAGE_TYPE_DIVINE)
    {
        if (d2() == 1) // 50% chance
        {
            if (GetIsPC(oTarget))
                FloatingTextStringOnCreature("Spell missed due to Incorporeality", oTarget, FALSE);
            effect eEffect;
            return eEffect; // Null return
        }
    }
	
	object oSpellCastItem = PRCGetSpellCastItem(); 
	
	//if (!GetIsObjectValid(PRCGetSpellCastItem()))
	if (!GetIsObjectValid(oSpellCastItem) || GetBaseItemType(oSpellCastItem) == BASE_ITEM_MAGICSTAFF)
	{
    	if(PRCGetLastSpellCastClass(oCaster) == CLASS_TYPE_WARMAGE && !GetLocalInt(oTarget, "WarmageEdgeDelay"))
    	{
    	    // Warmage Edge
    	    nDamageAmount += GetAbilityModifier(ABILITY_INTELLIGENCE);
    	    if(GetHasFeat(FEAT_TYPE_EXTRA_EDGE))
    	    {
    	        // Extra Edge feat.
    	        nDamageAmount += (GetLevelByClass(CLASS_TYPE_WARMAGE) / 4) + 1;
    	    }
    	    SetLocalInt(oTarget, "WarmageEdgeDelay", TRUE);
    	    DelayCommand(0.25, DeleteLocalInt(oTarget, "WarmageEdgeDelay"));
    	}
    	
    	if(GetHasSpellEffect(MELD_ARCANE_FOCUS, oCaster) && !GetLocalInt(oTarget, "ArcaneFocusDelay"))
    	{
    	    nDamageAmount += 1 + GetEssentiaInvested(oCaster, MELD_ARCANE_FOCUS);
    	    SetLocalInt(oTarget, "ArcaneFocusDelay", TRUE);
    	    DelayCommand(0.25, DeleteLocalInt(oTarget, "ArcaneFocusDelay"));
    	    if (DEBUG) DoDebug("ArcaneFocus Damage Applied");
    	}    
	
    	// Thrall of Grazzt damage
    	nDamageAmount += SpellBetrayalDamage(oTarget, oCaster);
	
    	int nRace = MyPRCGetRacialType(oTarget);
	
    	//Bane Magic
    	if(GetHasBaneMagic(nRace))
    	    nDamageAmount += d6(2);
	
    	//Eldritch Spellweave
    	if(oTarget == GetLocalObject(oCaster, "SPELLWEAVE_TARGET"))
    	{
    	    //Bane blast essence is active ;)
    	    if(nRace == ((GetLocalInt(oCaster, "EssenceData") >>> 16) & 0xFF) - 1)
    	    {
    	        DeleteLocalObject(oCaster, "SPELLWEAVE_TARGET");
    	        nDamageAmount += d6(2);
    	    }
    	}
	
    	// Piercing Evocation
    	if(GetHasFeat(FEAT_PIERCING_EVOCATION) && GetLocalInt(oCaster, "X2_L_LAST_SPELLSCHOOL_VAR") == SPELL_SCHOOL_EVOCATION)
    	{
    	    // Elemental damage only
    	    if(IsSpellDamageElemental(nDamageType))
    	    {
    	        // Damage magical, max 10 to magical
    	        if(nDamageAmount > 10)
    	        {
    	            nDamageAmount -= 10;
    	            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(10), oTarget);
    	        }
    	        else
    	        {
    	            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamageAmount), oTarget);
    	            effect eEffect;
    	            return eEffect; // Null return
    	        }
    	    }
    	}
    	
    	// This is done here so it affects all spells
    	if(GetLocalInt(oCaster, "Diabolism"))
    	{
    	    //FloatingTextStringOnCreature("Diabolism is active", oCaster, FALSE);
    	    int iDiabolistLevel = GetLevelByClass(CLASS_TYPE_DIABOLIST, oCaster);
    	    DelayCommand(3.0, DeleteLocalInt(oCaster, "Diabolism"));
	
    	    if(iDiabolistLevel)
    	    {
    	        int nDice = (iDiabolistLevel + 5) / 5;
    	        int nDamage = d6(nDice);
    	        int nDamageType = DAMAGE_TYPE_DIVINE;
	
    	        if(GetLocalInt(oCaster, "VileDiabolism"))
    	        {
    	            //FloatingTextStringOnCreature("Vile Diabolism is active", oCaster, FALSE);
    	            nDamage /= 2;
    	            nDamageType = DAMAGE_TYPE_POSITIVE;
    	            DeleteLocalInt(oCaster, "VileDiabolism");
    	        }
	
    	        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, nDamageType), oTarget);
    	        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_EVIL_10), oTarget);
    	    }
    	}    

		//:: Get the current spell being cast
		int nCurrentSpell = PRCGetSpellId();

		//:: Skip Reserve Feat spellIDs
		if (nCurrentSpell < 19359 || nCurrentSpell > 19396)
		{
			//:: Piercing Cold for the Frost Mage
			if (GetLevelByClass(CLASS_TYPE_FROST_MAGE, oCaster) >= 4 && nDamageType == DAMAGE_TYPE_COLD)
			{
				int nCurrentHP = GetCurrentHitPoints(oTarget);
				DelayCommand(0.1, DoPiercingCold(oCaster, oTarget, nDamageAmount, nCurrentHP));
			}
		}
    	
/*     	// Piercing Cold for the Frost Mage
    	if (GetLevelByClass(CLASS_TYPE_FROST_MAGE, oCaster) >= 4 && nDamageType == DAMAGE_TYPE_COLD)
    	{
    	    int nCurrentHP = GetCurrentHitPoints(oTarget);
    	    DelayCommand(0.1, DoPiercingCold(oCaster, oTarget, nDamageAmount, nCurrentHP));
    	} */
    	
    	// Die DR die
    	if (GetLocalInt(oCaster, "MoveIgnoreDR"))
    	{
    	    int nCurrentHP = GetCurrentHitPoints(oTarget);
    	    DelayCommand(0.1, BreakDR(oCaster, oTarget, nDamageAmount, nCurrentHP));
    	}
    }
    
    // Frostrager heals on cold damage when raging. 1 heal for every 2 cold damage.
    if (GetLocalInt(oTarget, "Frostrage") && nDamageType == DAMAGE_TYPE_COLD)
    {
        nDamageAmount /= 2;
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nDamageAmount), oTarget); 
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FROST_L), oTarget);
        
        FloatingTextStringOnCreature("Absorb Cold healed " + IntToString(nDamageAmount), oTarget, FALSE);
        effect eEffect;
        return eEffect; //Doesn't hurt him
    } 
	
    // Mechanatrix heals from electrical damage.  +1 HP for every 3 electrical damage.
    if (GetRacialType(oTarget) == RACIAL_TYPE_MECHANATRIX && nDamageType == DAMAGE_TYPE_ELECTRICAL)
    {
        nDamageAmount /= 3;
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nDamageAmount), oTarget); 
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_ELECTRICITY), oTarget);
        
        FloatingTextStringOnCreature("Electricty Healing restored " + IntToString(nDamageAmount) +" HP.", oTarget, FALSE);
        effect eEffect;
        return eEffect; //Doesn't hurt him
    } 
	
    // Phoenix Belt gains fast healing when hit by fire damage
    if (GetHasSpellEffect(MELD_PHOENIX_BELT, oTarget) && nDamageType == DAMAGE_TYPE_FIRE)
    {
    	int nEssentia = GetEssentiaInvested(oTarget, MELD_PHOENIX_BELT);
    	int nResist = nEssentia * 5;
        int nDur;
        if (nDamageAmount >= nResist) nDur = nResist;
        else nDur = nDamageAmount;
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectRegenerate(1, 6.0), oTarget, RoundsToSeconds(nDur+1));
    }     
        
    return EffectDamage(nDamageAmount, nDamageType, nDamagePower);
}

// * Kovi. removes any effects from this type of spell
// * i.e., used in Mage Armor to remove any previous
// * mage armors
void PRCRemoveEffectsFromSpell(object oTarget, int SpellID)
{
    effect eLook = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eLook))
    {
        if(GetEffectSpellId(eLook) == SpellID)
            RemoveEffect(oTarget, eLook);

        eLook = GetNextEffect(oTarget);
    }
}

void PRCRemoveSpecificEffect(int nEffectTypeID, object oTarget)
{
    //Search through the valid effects on the target.
    effect eAOE = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eAOE))
    {
        if (GetEffectType(eAOE) == nEffectTypeID)
        {
            //If the effect was created by the spell then remove it
            RemoveEffect(oTarget, eAOE);
        }
        //Get next effect on the target
        eAOE = GetNextEffect(oTarget);
    }
}

effect PRCGetScaledEffect(effect eStandard, object oTarget)
{
    int nDiff = GetGameDifficulty();
    int nEffType = GetEffectType(eStandard);

    if(GetIsPC(oTarget) || GetIsPC(GetMaster(oTarget)))
    {
        if(nEffType == EFFECT_TYPE_FRIGHTENED)
        {
            if(nDiff == GAME_DIFFICULTY_VERY_EASY)
            {
                return EffectAttackDecrease(-2);
            }
            else if(nDiff == GAME_DIFFICULTY_EASY)
            {
                return EffectAttackDecrease(-4);
            }
        }
        if(nDiff == GAME_DIFFICULTY_VERY_EASY &&
            (nEffType == EFFECT_TYPE_PARALYZE ||
             nEffType == EFFECT_TYPE_STUNNED ||
             nEffType == EFFECT_TYPE_CONFUSED))
        {
            return EffectDazed();
        }
        if(nEffType == EFFECT_TYPE_CHARMED
        || nEffType == EFFECT_TYPE_DOMINATED)
        {
            return EffectDazed();
        }
    }
    return eStandard;
}

int PRCAmIAHumanoid(object oTarget)
{
    int nRacial = MyPRCGetRacialType(oTarget);
    if(nRacial == RACIAL_TYPE_DWARF
    || nRacial == RACIAL_TYPE_HALFELF
    || nRacial == RACIAL_TYPE_HALFORC
    || nRacial == RACIAL_TYPE_ELF
    || nRacial == RACIAL_TYPE_GNOME
    || nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID
    || nRacial == RACIAL_TYPE_HALFLING
    || nRacial == RACIAL_TYPE_HUMAN
    || nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS
    || nRacial == RACIAL_TYPE_HUMANOID_ORC
    || nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN)
    {
        return TRUE;
    }
    return FALSE;
}

int PRCGetScaledDuration(int nActualDuration, object oTarget)
{
    int nDiff = GetGameDifficulty();
    int nNew = nActualDuration;
    if(GetIsPC(oTarget) && nActualDuration > 3)
    {
        if(nDiff == GAME_DIFFICULTY_VERY_EASY
        || nDiff == GAME_DIFFICULTY_EASY)
        {
            nNew = nActualDuration / 4;
        }
        else if(nDiff == GAME_DIFFICULTY_NORMAL)
        {
            nNew = nActualDuration / 2;
        }
        if(nNew == 0)
        {
            nNew = 1;
        }
    }
    return nNew;
}

effect PRCCreateProtectionFromAlignmentLink(int nAlignment, int nPower = 1)
{
    int nFinal = nPower * 2;
    int nAlignmentLC;
    int nAlignmentGE;
    effect eDur;

    switch(nAlignment)
    {
        case ALIGNMENT_LAWFUL:{
            nAlignmentLC = ALIGNMENT_LAWFUL;
            nAlignmentGE = ALIGNMENT_ALL;
            eDur = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);
            break;}
        case ALIGNMENT_CHAOTIC:{
            nAlignmentLC = ALIGNMENT_CHAOTIC;
            nAlignmentGE = ALIGNMENT_ALL;
            eDur = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);
            break;}
        case ALIGNMENT_GOOD:{
            nAlignmentLC = ALIGNMENT_ALL;
            nAlignmentGE = ALIGNMENT_GOOD;
            eDur = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);
            break;}
        case ALIGNMENT_EVIL:{
            nAlignmentLC = ALIGNMENT_ALL;
            nAlignmentGE = ALIGNMENT_EVIL;
            eDur = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);
            break;}
    }

    //construct final effect
    effect eLink = EffectACIncrease(nFinal, AC_DEFLECTION_BONUS);
           eLink = EffectLinkEffects(eLink, EffectSavingThrowIncrease(SAVING_THROW_ALL, nFinal));
           eLink = EffectLinkEffects(eLink, EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS));
           //make it vs alignment
           eLink = VersusAlignmentEffect(eLink, nAlignmentLC, nAlignmentGE);
           //add duration vfx
           eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
           eLink = EffectLinkEffects(eLink, eDur);

    return eLink;
}

float PRCGetSpellEffectDelay(location SpellTargetLocation, object oTarget)
{
    float fDelay = GetDistanceBetweenLocations(SpellTargetLocation, GetLocation(oTarget))/20;
    return fDelay;
}

// * returns true if the creature has flesh
int PRCIsImmuneToPetrification(object oCreature)
{
    int nAppearance = GetAppearanceType(oCreature);
    int bImmune = FALSE;
    
	if (GetHasSpellEffect(VESTIGE_HAAGENTI, oCreature) && GetLocalInt(oCreature, "ExploitVestige") != VESTIGE_HAAGENTI_IMMUNE_TRANS) bImmune = TRUE;    
    
    switch (nAppearance)
    {
        case APPEARANCE_TYPE_BASILISK:
        case APPEARANCE_TYPE_COCKATRICE:
        case APPEARANCE_TYPE_MEDUSA:
        case APPEARANCE_TYPE_ALLIP:
        case APPEARANCE_TYPE_ELEMENTAL_AIR:
        case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_EARTH:
        case APPEARANCE_TYPE_ELEMENTAL_EARTH_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_FIRE:
        case APPEARANCE_TYPE_ELEMENTAL_FIRE_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_WATER:
        case APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER:
        case APPEARANCE_TYPE_GOLEM_STONE:
        case APPEARANCE_TYPE_GOLEM_IRON:
        case APPEARANCE_TYPE_GOLEM_CLAY:
        case APPEARANCE_TYPE_GOLEM_BONE:
        case APPEARANCE_TYPE_GORGON:
        case APPEARANCE_TYPE_HEURODIS_LICH:
        case APPEARANCE_TYPE_LANTERN_ARCHON:
        case APPEARANCE_TYPE_SHADOW:
        case APPEARANCE_TYPE_SHADOW_FIEND:
        case APPEARANCE_TYPE_SHIELD_GUARDIAN:
        case APPEARANCE_TYPE_SKELETAL_DEVOURER:
        case APPEARANCE_TYPE_SKELETON_CHIEFTAIN:
        case APPEARANCE_TYPE_SKELETON_COMMON:
        case APPEARANCE_TYPE_SKELETON_MAGE:
        case APPEARANCE_TYPE_SKELETON_PRIEST:
        case APPEARANCE_TYPE_SKELETON_WARRIOR:
        case APPEARANCE_TYPE_SKELETON_WARRIOR_1:
        case APPEARANCE_TYPE_SPECTRE:
        case APPEARANCE_TYPE_WILL_O_WISP:
        case APPEARANCE_TYPE_WRAITH:
        case APPEARANCE_TYPE_BAT_HORROR:
        case 405: // Dracolich:
        case 415: // Alhoon
        case 418: // shadow dragon
        case 420: // mithral golem
        case 421: // admantium golem
        case 430: // Demi Lich
        case 469: // animated chest
        case 474: // golems
        case 475: // golems
        bImmune = TRUE;
    }

    int nRacialType = MyPRCGetRacialType(oCreature);
    switch(nRacialType)
    {
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_OOZE:
        case RACIAL_TYPE_UNDEAD:
        bImmune = TRUE;
    }

    // 01/08/07 Racial feat for petrification immunity
    if(GetHasFeat(FEAT_IMMUNE_PETRIFICATION)) bImmune = TRUE;

    // 03/07/2005 CraigW - Petrification immunity can also be granted as an item property.
    if ( ResistSpell(OBJECT_SELF,oCreature) == 2 )
    {
        bImmune = TRUE;
    }

    // * GZ: Sept 2003 - Prevent people from petrifying DM, resulting in GUI even when
    //                   effect is not successful.
    if (!GetPlotFlag(oCreature) && GetIsDM(oCreature))
    {
       bImmune = FALSE;
    }
    return bImmune;
}

// *  This is a wrapper for how Petrify will work in Expansion Pack 1
// * Scripts affected: flesh to stone, breath petrification, gaze petrification, touch petrification
// * nPower : This is the Hit Dice of a Monster using Gaze, Breath or Touch OR it is the Caster Spell of
// *   a spellcaster
// * nFortSaveDC: pass in this number from the spell script
void PRCDoPetrification(int nPower, object oSource, object oTarget, int nSpellID, int nFortSaveDC)
{

    if(!GetIsReactionTypeFriendly(oTarget))
    {
        // * exit if creature is immune to petrification
        if(PRCIsImmuneToPetrification(oTarget))
            return;

        float fDifficulty = 0.0;
        int bIsPC = GetIsPC(oTarget);
        int bShowPopup = FALSE;

        // * calculate Duration based on difficulty settings
        int nGameDiff = GetGameDifficulty();
        switch (nGameDiff)
        {
            case GAME_DIFFICULTY_VERY_EASY:
            case GAME_DIFFICULTY_EASY:
            case GAME_DIFFICULTY_NORMAL:
                    fDifficulty = RoundsToSeconds(nPower); // One Round per hit-die or caster level
                break;
            case GAME_DIFFICULTY_CORE_RULES:
            case GAME_DIFFICULTY_DIFFICULT:
                bShowPopup = TRUE;
            break;
        }

        int nSaveDC = nFortSaveDC;
        effect ePetrify = EffectPetrify();

        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

        effect eLink = EffectLinkEffects(eDur, ePetrify);

            // Let target know the negative spell has been cast
            SignalEvent(oTarget,
                        EventSpellCastAt(OBJECT_SELF, nSpellID));
                        //SpeakString(IntToString(nSpellID));

            // Do a fortitude save check
            if (!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nSaveDC))
            {
                // Save failed; apply paralyze effect and VFX impact

                /// * The duration is permanent against NPCs but only temporary against PCs
                if (bIsPC == TRUE)
                {
                    if (bShowPopup == TRUE)
                    {
                        // * under hardcore rules or higher, this is an instant death
                        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
                        //only pop up death panel if switch is not set
                        if(!GetPRCSwitch(PRC_NO_PETRIFY_GUI))
                        DelayCommand(2.75, PopUpDeathGUIPanel(oTarget, FALSE , TRUE, 40579));
                        //run the PRC Ondeath code
                        //no way to run the normal module ondeath code too
                        //so a execute script has been added for builders to take advantage of
                        DelayCommand(2.75, ExecuteScript("prc_ondeath", oTarget));
                        DelayCommand(2.75, ExecuteScript("prc_pw_petrific", oTarget));
                        // if in hardcore, treat the player as an NPC
                        bIsPC = FALSE;
                        //fDifficulty = TurnsToSeconds(nPower); // One turn per hit-die
                    }
                    else
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, fDifficulty);
                }
                else
                {
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
                }
                // April 2003: Clearing actions to kick them out of conversation when petrified
                AssignCommand(oTarget, ClearAllActions(TRUE));
            }
    }

}

//------------------------------------------------------------------------------
// GZ: 2003-Oct-15
// A different approach for timing these spells that has the positive side
// effects of making the spell dispellable as well.
// I am using the VFX applied by the spell to track the remaining duration
// instead of adding the remaining runtime on the stack
//
// This function returns FALSE if a delayed Spell effect from nSpell_ID has
// expired. See x2_s0_bigby4.nss for details
//------------------------------------------------------------------------------
int PRCGetDelayedSpellEffectsExpired(int nSpell_ID, object oTarget, object oCaster)
{

    if (!GetHasSpellEffect(nSpell_ID,oTarget) )
    {
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        return TRUE;
    }

    //--------------------------------------------------------------------------
    // GZ: 2003-Oct-15
    // If the caster is dead or no longer there, cancel the spell, as it is
    // directed
    //--------------------------------------------------------------------------
    if( !GetIsObjectValid(oCaster))
    {
        GZPRCRemoveSpellEffects(nSpell_ID, oTarget);
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        return TRUE;
    }

    if (GetIsDead(oCaster))
    {
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        GZPRCRemoveSpellEffects(nSpell_ID, oTarget);
        return TRUE;
    }

    return FALSE;

}

// Much similar to PRCGetHasSpell, but used for JPM to get spells left not counting metamagic
int PRCGetSpellUsesLeft(int nRealSpellID, object oCreature = OBJECT_SELF)
{
    if(!PRCGetIsRealSpellKnown(nRealSpellID, oCreature))
        return 0;
    int nUses = GetHasSpell(nRealSpellID, oCreature);

    int nClass, nSpellbookID, nCount, i, j;
    int nSpellbookType, nSpellLevel;
    string sFile, sFeat;
    for(i = 1; i <= 8; i++)
    {
        nClass = GetClassByPosition(i, oCreature);
        sFile = GetFileForClass(nClass);
        nSpellbookType = GetSpellbookTypeForClass(nClass);
        nSpellbookID = RealSpellToSpellbookID(nClass, nRealSpellID);
        if (nSpellbookID != -1)
        {   //non-spellbook classes should return -1
                sFeat = Get2DACache(sFile, "ReqFeat", j);
                if(sFeat != "")
                {
                    if(!GetHasFeat(StringToInt(sFeat), oCreature))
                        continue;
                }
                if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
                {
                    nCount = persistant_array_get_int(oCreature, "NewSpellbookMem_" + IntToString(nClass), j);
                    if(DEBUG) DoDebug("PRCGetHasSpell(Prepared Caster): NewSpellbookMem_" + IntToString(nClass) + "[" + IntToString(j) + "] = " + IntToString(nCount));
                    if(nCount > 0)
                    {
                        nUses += nCount;
                    }
                }
                else if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
                {
                    nSpellLevel = StringToInt(Get2DACache(sFile, "Level", j));
                    nCount = persistant_array_get_int(oCreature, "NewSpellbookMem_" + IntToString(nClass), nSpellLevel);
                    if(DEBUG) DoDebug("PRCGetHasSpell(Spontaneous Caster): NewSpellbookMem_" + IntToString(nClass) + "[" + IntToString(j) + "] = " + IntToString(nCount));
                    if(nCount > 0)
                    {
                        nUses += nCount;
                    }
                }
        }
    }

    if(DEBUG) DoDebug("PRCGetHasSpell: RealSpellID = " + IntToString(nRealSpellID) + ", Uses = " + IntToString(nUses));
    return nUses;
}

// * Applies the effects of FEAT_AUGMENT_SUMMON to summoned creatures.
void AugmentSummonedCreature(string sResRef)
{
    if(GetHasFeat(FEAT_AUGMENT_SUMMON))
    {
        int i = 1;
        object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF);
        while(GetIsObjectValid(oSummon))
        {
            if(GetResRef(oSummon) == sResRef && !GetLocalInt(oSummon, "Augmented"))
            {
                effect eLink = EffectAbilityIncrease(ABILITY_STRENGTH, 4);
                       eLink = EffectLinkEffects(eLink, EffectAbilityIncrease(ABILITY_CONSTITUTION, 4));
                       eLink = UnyieldingEffect(eLink);
    
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oSummon);
                SetLocalInt(oSummon, "Augmented", TRUE);
            }
            i++;
            oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF, i);
        }
    }
    if(sResRef == "prc_sum_treant")
    {
        int i = 1;
        object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF);
        while(GetIsObjectValid(oSummon))
        {
            if(GetResRef(oSummon) == sResRef)
            {
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_PROT_BARKSKIN), oSummon);
            }
            i++;
            oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF, i);
        }
    }    
    if(GetHasFeat(FEAT_BECKON_THE_FROZEN))
    {
        int i = 1;
        object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF);
        while(GetIsObjectValid(oSummon))
        {
            if(GetResRef(oSummon) == sResRef && !GetLocalInt(oSummon, "BeckonTheFrozen"))
            {
                effect eLink = EffectVisualEffect(VFX_DUR_CHILL_SHIELD);
                eLink = EffectLinkEffects(eLink, EffectDamageImmunityDecrease(DAMAGE_TYPE_FIRE, 50));
                eLink = EffectLinkEffects(eLink, EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, 100));
				eLink = EffectLinkEffects(eLink, EffectDamageIncrease(DAMAGE_BONUS_1d6, DAMAGE_TYPE_COLD));
                eLink = UnyieldingEffect(eLink);
    
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oSummon);
                SetLocalInt(oSummon, "BeckonTheFrozen", TRUE);
            }
            i++;
            oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, OBJECT_SELF, i);
        }
    }    
}    

object GetAreaOfEffectObject(location lTarget, string sTag, object oCaster = OBJECT_SELF)
{
    object oAoE = GetFirstObjectInShape(SHAPE_SPHERE, 1.0f, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    while(GetIsObjectValid(oAoE))
    {
        if((GetAreaOfEffectCreator(oAoE) == oCaster) //was created by oCaster
        && GetTag(oAoE) == sTag                      //has required tag
        && !GetLocalInt(oAoE, "X2_AoE_BaseSaveDC")) //and wasn't setup before
        {
            return oAoE;
        }
        oAoE = GetNextObjectInShape(SHAPE_SPHERE, 1.0f, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    }
    return OBJECT_INVALID;
}

string GetAreaOfEffectTag(int nAoE)
{
    return Get2DACache("vfx_persistent", "LABEL", nAoE);
}

int CheckTurnUndeadUses(object oPC, int nUses)
{
    int i;
    while(i < nUses)
    {
        if(GetHasFeat(FEAT_TURN_UNDEAD, oPC))
        {
            DecrementRemainingFeatUses(oPC, FEAT_TURN_UNDEAD);
            i++;
        }
        else
            break;
    }
    if(i < nUses)
    {
        while(i)
        {
            IncrementRemainingFeatUses(oPC, FEAT_TURN_UNDEAD);
            i--;
        }
        return FALSE;
    }
    return TRUE;
}

// this will execute the prespellcastcode, whose full functionality is incoded in X2PreSpellCastCode2(),
// as a script, to save loading time for spells scripts and reduce memory usage of NWN
// the prespellcode takes up roughly 250 kByte compiled code, meaning that every spell script that
// calls it directly as a function (e.g.: X2PreSpellCastCode2) will be between 100 kByte to 250 kByte
// larger, than a spell script calling the prespellcode via ExecuteScript (e.g. X2PreSpellCastCode)
// Although ExecuteScript is slightly slower than a direct function call, quite likely overall performance is
// increased, because for every new spell 100-250 kByte less code need to be loaded into memory
// and NWN has more free memory available to keep more spells scripts (and other crucial scripts)
//in RAM

int X2PreSpellCastCode()
{
    object oCaster = OBJECT_SELF;

        // SetLocalInt(oCaster, "PSCC_Ret", 0);
        ExecuteScript("prc_prespell", oCaster);

        int nReturn = GetLocalInt(oCaster, "PSCC_Ret");
        // DeleteLocalInt(oCaster, "PSCC_Ret");

        return nReturn;
}	

//:: Test Void
// void main (){}