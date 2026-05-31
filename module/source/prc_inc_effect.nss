/*

This include file details the PRC replacement for biowares effect variable type
It is required so that we can access the components of an effect much as we can
with itemproperties.
Also useful for storing things like metamagic, spell level, etc


Primogenitor
*/

struct PRCeffect{
    effect eEffect;
    int nEffectType;
    int nEffectSubtype;
    int nDurationType;
    float fDuration;
    int nVersesRace;
    int nVersesTraps;
    int nVersesAlignmentOrder;
    int nVersesAlignmentMoral;

    //these are the subcomponents
    //probably more here than needed, but better safe than sorry!
    int nVar1;    object oVar1;    string sVar1;    location lVar1;    float fVar1;
    int nVar2;    object oVar2;    string sVar2;    location lVar2;    float fVar2;
    int nVar3;    object oVar3;    string sVar3;    location lVar3;    float fVar3;
    int nVar4;    object oVar4;    string sVar4;    location lVar4;    float fVar4;
    int nVar5;    object oVar5;    string sVar5;    location lVar5;    float fVar5;
    int nVar6;    object oVar6;    string sVar6;    location lVar6;    float fVar6;
    int nVar7;    object oVar7;    string sVar7;    location lVar7;    float fVar7;
    int nVar8;    object oVar8;    string sVar8;    location lVar8;    float fVar8;
    int nVar9;    object oVar9;    string sVar9;    location lVar9;    float fVar9;

    int nLinkedCount;
    int nLinkedID;
    //linked effects are stored in an array on the module with the prefix PRC_LinkEffects_X
    //where X is an ID number that is incremented for each new effect that has linked effects

    int nSpellID;
    int nCasterLevel;
    object oCaster;
    int nMetamagic;
    int nSpellLevel;
    int nWeave;
};

//get/set local handlers
void             SetLocalPRCEffect(object oObject, string sVarName, struct PRCeffect eValue);
struct PRCeffect GetLocalPRCEffect(object oObject, string sVarName);
void             DeleteLocalPRCEffect(object oObject, string sVarName);

//default constructor
struct PRCeffect GetNewPRCEffectBase();

// Get the first in-game effect on oCreature.
struct PRCeffect PRCGetFirstEffect(object oCreature);

// Get the next in-game effect on oCreature.
struct PRCeffect PRCGetNextEffect(object oCreature);

// * Returns TRUE if eEffect is a valid effect. The effect must have been applied to
// * an object or else it will return FALSE
int PRCGetIsEffectValid(struct PRCeffect prceEffect);

// Get the duration type (DURATION_TYPE_*) of eEffect.
// * Return value if eEffect is not valid: -1
int PRCGetEffectDurationType(struct PRCeffect prceEffect);

// Get the subtype (SUBTYPE_*) of eEffect.
// * Return value on error: 0
int PRCGetEffectSubType(struct PRCeffect prceEffect);

// Get the object that created eEffect.
// * Returns OBJECT_INVALID if eEffect is not a valid effect.
object PRCGetEffectCreator(struct PRCeffect prceEffect);

// Get the effect type (EFFECT_TYPE_*) of eEffect.
// * Return value if eEffect is invalid: EFFECT_INVALIDEFFECT
int PRCGetEffectType(struct PRCeffect prceEffect);

// Get the spell (SPELL_*) that applied eSpellEffect.
// * Returns -1 if eSpellEffect was applied outside a spell script.
int PRCGetEffectSpellId(struct PRCeffect prceEffect);

// gets the real effect based on an effect structure
// should never be needed outside the effect system itself
effect GetEffectOnObjectFromPRCEffect(struct PRCeffect prceEffect, object oObject);

// Remove eEffect from oCreature.
// * No return value
void PRCRemoveEffect(object oCreature, struct PRCeffect eEffect);

// Set the subtype of eEffect to Magical and return eEffect.
// (Effects default to magical if the subtype is not set)
// Magical effects are removed by resting, and by dispel magic
struct PRCeffect PRCMagicalEffect(struct PRCeffect eEffect);

// Set the subtype of eEffect to Supernatural and return eEffect.
// (Effects default to magical if the subtype is not set)
// Permanent supernatural effects are not removed by resting
struct PRCeffect PRCSupernaturalEffect(struct PRCeffect eEffect);

// Set the subtype of eEffect to Extraordinary and return eEffect.
// (Effects default to magical if the subtype is not set)
// Extraordinary effects are removed by resting, but not by dispel magic
struct PRCeffect PRCExtraordinaryEffect(struct PRCeffect eEffect);

// Set eEffect to be versus a specific alignment.
// - eEffect
// - nLawChaos: ALIGNMENT_LAWFUL/ALIGNMENT_CHAOTIC/ALIGNMENT_ALL
// - nGoodEvil: ALIGNMENT_GOOD/ALIGNMENT_EVIL/ALIGNMENT_ALL
struct PRCeffect PRCVersusAlignmentEffect(struct PRCeffect eEffect, int nLawChaos=ALIGNMENT_ALL, int nGoodEvil=ALIGNMENT_ALL);

// Set eEffect to be versus nRacialType.
// - eEffect
// - nRacialType: RACIAL_TYPE_*
struct PRCeffect PRCVersusRacialTypeEffect(struct PRCeffect eEffect, int nRacialType);

// Set eEffect to be versus traps.
struct PRCeffect PRCVersusTrapEffect(struct PRCeffect eEffect);

// Create a Heal effect. This should be applied as an instantaneous effect.
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nDamageToHeal < 0.
struct PRCeffect PRCEffectHeal(int nDamageToHeal);

// Create a Damage effect
// - nDamageAmount: amount of damage to be dealt. This should be applied as an
//   instantaneous effect.
// - nDamageType: DAMAGE_TYPE_*
// - nDamagePower: DAMAGE_POWER_*
struct PRCeffect PRCEffectDamage(int nDamageAmount, int nDamageType=DAMAGE_TYPE_MAGICAL, int nDamagePower=DAMAGE_POWER_NORMAL);

// Create an Ability Increase effect
// - bAbilityToIncrease: ABILITY_*
struct PRCeffect PRCEffectAbilityIncrease(int nAbilityToIncrease, int nModifyBy);

// Create a Damage Resistance effect that removes the first nAmount points of
// damage of type nDamageType, up to nLimit (or infinite if nLimit is 0)
// - nDamageType: DAMAGE_TYPE_*
// - nAmount
// - nLimit
struct PRCeffect PRCEffectDamageResistance(int nDamageType, int nAmount, int nLimit=0);

// Create a Summon Creature effect.  The creature is created and placed into the
// caller's party/faction.
// - sCreatureResref: Identifies the creature to be summoned
// - nVisualEffectId: VFX_*
// - fDelaySeconds: There can be delay between the visual effect being played, and the
//   creature being added to the area
// - nUseAppearAnimation: should this creature play it's "appear" animation when it is
//   summoned. If zero, it will just fade in somewhere near the target.  If the value is 1
//   it will use the appear animation, and if it's 2 it will use appear2 (which doesn't exist for most creatures)
struct PRCeffect PRCEffectSummonCreature(string sCreatureResref, int nVisualEffectId=VFX_NONE, float fDelaySeconds=0.0f, int nUseAppearAnimation=0);

// Create a Resurrection effect. This should be applied as an instantaneous effect.
struct PRCeffect PRCEffectResurrection();

// Create an AC Increase effect
// - nValue: size of AC increase
// - nModifyType: AC_*_BONUS
// - nDamageType: DAMAGE_TYPE_*
//   * Default value for nDamageType should only ever be used in this function prototype.
struct PRCeffect PRCEffectACIncrease(int nValue, int nModifyType=AC_DODGE_BONUS, int nDamageType=AC_VS_DAMAGE_TYPE_ALL);

// Create a Saving Throw Increase effect
// - nSave: SAVING_THROW_* (not SAVING_THROW_TYPE_*)
//          SAVING_THROW_ALL
//          SAVING_THROW_FORT
//          SAVING_THROW_REFLEX
//          SAVING_THROW_WILL
// - nValue: size of the Saving Throw increase
// - nSaveType: SAVING_THROW_TYPE_* (e.g. SAVING_THROW_TYPE_ACID )
struct PRCeffect PRCEffectSavingThrowIncrease(int nSave, int nValue, int nSaveType=SAVING_THROW_TYPE_ALL);

// Create an Attack Increase effect
// - nBonus: size of attack bonus
// - nModifierType: ATTACK_BONUS_*
struct PRCeffect PRCEffectAttackIncrease(int nBonus, int nModifierType=ATTACK_BONUS_MISC);

// Create a Damage Reduction effect
// - nAmount: amount of damage reduction
// - nDamagePower: DAMAGE_POWER_*
// - nLimit: How much damage the effect can absorb before disappearing.
//   Set to zero for infinite
struct PRCeffect PRCEffectDamageReduction(int nAmount, int nDamagePower, int nLimit=0);

// Create a Damage Increase effect
// - nBonus: DAMAGE_BONUS_*
// - nDamageType: DAMAGE_TYPE_*
// NOTE! You *must* use the DAMAGE_BONUS_* constants! Using other values may
//       result in odd behaviour.
struct PRCeffect PRCEffectDamageIncrease(int nBonus, int nDamageType=DAMAGE_TYPE_MAGICAL);


// Create an Entangle effect
// When applied, this effect will restrict the creature's movement and apply a
// (-2) to all attacks and a -4 to AC.
struct PRCeffect PRCEffectEntangle();

// Create a Death effect
// - nSpectacularDeath: if this is TRUE, the creature to which this effect is
//   applied will die in an extraordinary fashion
// - nDisplayFeedback
struct PRCeffect PRCEffectDeath(int nSpectacularDeath=FALSE, int nDisplayFeedback=TRUE);

// Create a Knockdown effect
// This effect knocks creatures off their feet, they will sit until the effect
// is removed. This should be applied as a temporary effect with a 3 second
// duration minimum (1 second to fall, 1 second sitting, 1 second to get up).
struct PRCeffect PRCEffectKnockdown();

// Create a Curse effect.
// - nStrMod: strength modifier
// - nDexMod: dexterity modifier
// - nConMod: constitution modifier
// - nIntMod: intelligence modifier
// - nWisMod: wisdom modifier
// - nChaMod: charisma modifier
struct PRCeffect PRCEffectCurse(int nStrMod=1, int nDexMod=1, int nConMod=1, int nIntMod=1, int nWisMod=1, int nChaMod=1);

// Create a Paralyze effect
struct PRCeffect PRCEffectParalyze();

// Create a Spell Immunity effect.
// There is a known bug with this function. There *must* be a parameter specified
// when this is called (even if the desired parameter is SPELL_ALL_SPELLS),
// otherwise an effect of type EFFECT_TYPE_INVALIDEFFECT will be returned.
// - nImmunityToSpell: SPELL_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nImmunityToSpell is
//   invalid.
struct PRCeffect PRCEffectSpellImmunity(int nImmunityToSpell=SPELL_ALL_SPELLS);

// Create a Deaf effect
struct PRCeffect PRCEffectDeaf();

// Create a Sleep effect
struct PRCeffect PRCEffectSleep();

// Create a Charm effect
struct PRCeffect PRCEffectCharmed();

// Create a Confuse effect
struct PRCeffect PRCEffectConfused();

// Create a Frighten effect
struct PRCeffect PRCEffectFrightened();

// Create a Dominate effect
struct PRCeffect PRCEffectDominated();

// Create a Daze effect
struct PRCeffect PRCEffectDazed();

// Create a Stun effect
struct PRCeffect PRCEffectStunned();

// Create a Regenerate effect.
// - nAmount: amount of damage to be regenerated per time interval
// - fIntervalSeconds: length of interval in seconds
struct PRCeffect PRCEffectRegenerate(int nAmount, float fIntervalSeconds);

// Create a Movement Speed Increase effect.
// - nPercentChange - range 0 through 99
// eg.
//    0 = no change in speed
//   50 = 50% faster
//   99 = almost twice as fast
struct PRCeffect PRCEffectMovementSpeedIncrease(int nPercentChange);

// Create an Area Of struct PRCeffect PRCEffect in the area of the creature it is applied to.
// If the scripts are not specified, default ones will be used.
struct PRCeffect PRCEffectAreaOfEffect(int nAreaEffectId, string sOnEnterScript="", string sHeartbeatScript="", string sOnExitScript="");

// * Create a Visual Effect that can be applied to an object.
// - nVisualEffectId
// - nMissEffect: if this is TRUE, a random vector near or past the target will
//   be generated, on which to play the effect
struct PRCeffect PRCEffectVisualEffect(int nVisualEffectId, int nMissEffect=FALSE);

// Link the two supplied effects, returning eChildEffect as a child of
// eParentEffect.
// Note: When applying linked effects if the target is immune to all valid
// effects all other effects will be removed as well. This means that if you
// apply a visual effect and a silence effect (in a link) and the target is
// immune to the silence effect that the visual effect will get removed as well.
// Visual Effects are not considered "valid" effects for the purposes of
// determining if an effect will be removed or not and as such should never be
// packaged *only* with other visual effects in a link.
struct PRCeffect PRCEffectLinkEffects(struct PRCeffect  eChildEffect, struct PRCeffect  eParentEffect );

// Create a Beam effect.
// - nBeamVisualEffect: VFX_BEAM_*
// - oEffector: the beam is emitted from this creature
// - nBodyPart: BODY_NODE_*
// - bMissEffect: If this is TRUE, the beam will fire to a random vector near or
//   past the target
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nBeamVisualEffect is
//   not valid.
struct PRCeffect PRCEffectBeam(int nBeamVisualEffect, object oEffector, int nBodyPart, int bMissEffect=FALSE);

// Create a Spell Resistance Increase effect.
// - nValue: size of spell resistance increase
struct PRCeffect PRCEffectSpellResistanceIncrease(int nValue);

// Create a Poison effect.
// - nPoisonType: POISON_*
struct PRCeffect PRCEffectPoison(int nPoisonType);

// Create a Disease effect.
// - nDiseaseType: DISEASE_*
struct PRCeffect PRCEffectDisease(int nDiseaseType);

// Create a Silence effect.
struct PRCeffect PRCEffectSilence();

// Create a Haste effect.
struct PRCeffect PRCEffectHaste();

// Create a Slow effect.
struct PRCeffect PRCEffectSlow();

// Create an Immunity effect.
// - nImmunityType: IMMUNITY_TYPE_*
struct PRCeffect PRCEffectImmunity(int nImmunityType);

// Creates a Damage Immunity Increase effect.
// - nDamageType: DAMAGE_TYPE_*
// - nPercentImmunity
struct PRCeffect PRCEffectDamageImmunityIncrease(int nDamageType, int nPercentImmunity);

// Create a Temporary Hitpoints effect.
// - nHitPoints: a positive integer
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nHitPoints < 0.
struct PRCeffect PRCEffectTemporaryHitpoints(int nHitPoints);

// Create a Skill Increase effect.
// - nSkill: SKILL_*
// - nValue
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nSkill is invalid.
struct PRCeffect PRCEffectSkillIncrease(int nSkill, int nValue);

// Create a Turned effect.
// Turned effects are supernatural by default.
struct PRCeffect PRCEffectTurned();

// Create a Hit Point Change When Dying effect.
// - fHitPointChangePerRound: this can be positive or negative, but not zero.
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if fHitPointChangePerRound is 0.
struct PRCeffect PRCEffectHitPointChangeWhenDying(float fHitPointChangePerRound);

// Create an Ability Decrease effect.
// - nAbility: ABILITY_*
// - nModifyBy: This is the amount by which to decrement the ability
struct PRCeffect PRCEffectAbilityDecrease(int nAbility, int nModifyBy);

// Create an Attack Decrease effect.
// - nPenalty
// - nModifierType: ATTACK_BONUS_*
struct PRCeffect PRCEffectAttackDecrease(int nPenalty, int nModifierType=ATTACK_BONUS_MISC);

// Create a Damage Decrease effect.
// - nPenalty
// - nDamageType: DAMAGE_TYPE_*
struct PRCeffect PRCEffectDamageDecrease(int nPenalty, int nDamageType=DAMAGE_TYPE_MAGICAL);

// Create a Damage Immunity Decrease effect.
// - nDamageType: DAMAGE_TYPE_*
// - nPercentImmunity
struct PRCeffect PRCEffectDamageImmunityDecrease(int nDamageType, int nPercentImmunity);

// Create an AC Decrease effect.
// - nValue
// - nModifyType: AC_*
// - nDamageType: DAMAGE_TYPE_*
//   * Default value for nDamageType should only ever be used in this function prototype.
struct PRCeffect PRCEffectACDecrease(int nValue, int nModifyType=AC_DODGE_BONUS, int nDamageType=AC_VS_DAMAGE_TYPE_ALL);

// Create a Movement Speed Decrease effect.
// - nPercentChange - range 0 through 99
// eg.
//    0 = no change in speed
//   50 = 50% slower
//   99 = almost immobile
struct PRCeffect PRCEffectMovementSpeedDecrease(int nPercentChange);

// Create a Saving Throw Decrease effect.
// - nSave: SAVING_THROW_* (not SAVING_THROW_TYPE_*)
//          SAVING_THROW_ALL
//          SAVING_THROW_FORT
//          SAVING_THROW_REFLEX
//          SAVING_THROW_WILL
// - nValue: size of the Saving Throw decrease
// - nSaveType: SAVING_THROW_TYPE_* (e.g. SAVING_THROW_TYPE_ACID )
struct PRCeffect PRCEffectSavingThrowDecrease(int nSave, int nValue, int nSaveType=SAVING_THROW_TYPE_ALL);

// Create a Skill Decrease effect.
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nSkill is invalid.
struct PRCeffect PRCEffectSkillDecrease(int nSkill, int nValue);

// Create a Spell Resistance Decrease effect.
struct PRCeffect PRCEffectSpellResistanceDecrease(int nValue);

// Create an Invisibility effect.
// - nInvisibilityType: INVISIBILITY_TYPE_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nInvisibilityType
//   is invalid.
struct PRCeffect PRCEffectInvisibility(int nInvisibilityType);

// Create a Concealment effect.
// - nPercentage: 1-100 inclusive
// - nMissChanceType: MISS_CHANCE_TYPE_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nPercentage < 1 or
//   nPercentage > 100.
struct PRCeffect PRCEffectConcealment(int nPercentage, int nMissType=MISS_CHANCE_TYPE_NORMAL);

// Create a Darkness effect.
struct PRCeffect PRCEffectDarkness();

// Create a Dispel Magic All effect.
// If no parameter is specified, USE_CREATURE_LEVEL will be used. This will
// cause the dispel effect to use the level of the creature that created the
// effect.
struct PRCeffect PRCEffectDispelMagicAll(int nCasterLevel=USE_CREATURE_LEVEL);

// Create an Ultravision effect.
struct PRCeffect PRCEffectUltravision();

// Create a Negative Level effect.
// - nNumLevels: the number of negative levels to apply.
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nNumLevels > 100.
struct PRCeffect PRCEffectNegativeLevel(int nNumLevels, int bHPBonus=FALSE);

// Create a Polymorph effect.
struct PRCeffect PRCEffectPolymorph(int nPolymorphSelection, int nLocked=FALSE);

// Create a Sanctuary effect.
// - nDifficultyClass: must be a non-zero, positive number
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nDifficultyClass <= 0.
struct PRCeffect PRCEffectSanctuary(int nDifficultyClass);

// Create a True Seeing effect.
struct PRCeffect PRCEffectTrueSeeing();

// Create a See Invisible effect.
struct PRCeffect PRCEffectSeeInvisible();

// Create a Time Stop effect.
struct PRCeffect PRCEffectTimeStop();

// Create a Blindness effect.
struct PRCeffect PRCEffectBlindness();

// Create a Spell Level Absorption effect.
// - nMaxSpellLevelAbsorbed: maximum spell level that will be absorbed by the
//   effect
// - nTotalSpellLevelsAbsorbed: maximum number of spell levels that will be
//   absorbed by the effect
// - nSpellSchool: SPELL_SCHOOL_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if:
//   nMaxSpellLevelAbsorbed is not between -1 and 9 inclusive, or nSpellSchool
//   is invalid.
struct PRCeffect PRCEffectSpellLevelAbsorption(int nMaxSpellLevelAbsorbed, int nTotalSpellLevelsAbsorbed=0, int nSpellSchool=SPELL_SCHOOL_GENERAL );

// Create a Dispel Magic Best effect.
// If no parameter is specified, USE_CREATURE_LEVEL will be used. This will
// cause the dispel effect to use the level of the creature that created the
// effect.
struct PRCeffect PRCEffectDispelMagicBest(int nCasterLevel=USE_CREATURE_LEVEL);

// Create a Miss Chance effect.
// - nPercentage: 1-100 inclusive
// - nMissChanceType: MISS_CHANCE_TYPE_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nPercentage < 1 or
//   nPercentage > 100.
struct PRCeffect PRCEffectMissChance(int nPercentage, int nMissChanceType=MISS_CHANCE_TYPE_NORMAL);

// Create a Disappear/Appear effect.
// The object will "fly away" for the duration of the effect and will reappear
// at lLocation.
// - nAnimation determines which appear and disappear animations to use. Most creatures
// only have animation 1, although a few have 2 (like beholders)
struct PRCeffect PRCEffectDisappearAppear(location lLocation, int nAnimation=1);

// Create a Disappear effect to make the object "fly away" and then destroy
// itself.
// - nAnimation determines which appear and disappear animations to use. Most creatures
// only have animation 1, although a few have 2 (like beholders)
struct PRCeffect PRCEffectDisappear(int nAnimation=1);

// Create an Appear effect to make the object "fly in".
// - nAnimation determines which appear and disappear animations to use. Most creatures
// only have animation 1, although a few have 2 (like beholders)
struct PRCeffect PRCEffectAppear(int nAnimation=1);

// Create a Modify Attacks effect to add attacks.
// - nAttacks: maximum is 5, even with the effect stacked
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nAttacks > 5.
struct PRCeffect PRCEffectModifyAttacks(int nAttacks);

// Create a Damage Shield effect which does (nDamageAmount + nRandomAmount)
// damage to any melee attacker on a successful attack of damage type nDamageType.
// - nDamageAmount: an integer value
// - nRandomAmount: DAMAGE_BONUS_*
// - nDamageType: DAMAGE_TYPE_*
// NOTE! You *must* use the DAMAGE_BONUS_* constants! Using other values may
//       result in odd behaviour.
struct PRCeffect PRCEffectDamageShield(int nDamageAmount, int nRandomAmount, int nDamageType);

// Create a Swarm effect.
// - nLooping: If this is TRUE, for the duration of the effect when one creature
//   created by this effect dies, the next one in the list will be created.  If
//   the last creature in the list dies, we loop back to the beginning and
//   sCreatureTemplate1 will be created, and so on...
// - sCreatureTemplate1
// - sCreatureTemplate2
// - sCreatureTemplate3
// - sCreatureTemplate4
struct PRCeffect PRCEffectSwarm(int nLooping, string sCreatureTemplate1, string sCreatureTemplate2="", string sCreatureTemplate3="", string sCreatureTemplate4="");

// Create a Turn Resistance Decrease effect.
// - nHitDice: a positive number representing the number of hit dice for the
///  decrease
struct PRCeffect PRCEffectTurnResistanceDecrease(int nHitDice);

// Create a Turn Resistance Increase effect.
// - nHitDice: a positive number representing the number of hit dice for the
//   increase
struct PRCeffect PRCEffectTurnResistanceIncrease(int nHitDice);

// returns an effect that will petrify the target
// * currently applies EffectParalyze and the stoneskin visual effect.
struct PRCeffect PRCEffectPetrify();

// returns an effect that is guaranteed to paralyze a creature.
// this effect is identical to EffectParalyze except that it cannot be resisted.
struct PRCeffect PRCEffectCutsceneParalyze();

// Returns an effect that is guaranteed to dominate a creature
// Like EffectDominated but cannot be resisted
struct PRCeffect PRCEffectCutsceneDominated();

// Creates an effect that inhibits spells
// - nPercent - percentage of failure
// - nSpellSchool - the school of spells affected.
struct PRCeffect PRCEffectSpellFailure(int nPercent=100, int nSpellSchool=SPELL_SCHOOL_GENERAL);

// Returns an effect of type EFFECT_TYPE_ETHEREAL which works just like EffectSanctuary
// except that the observers get no saving throw
struct PRCeffect PRCEffectEthereal();

// Creates a cutscene ghost effect, this will allow creatures
// to pathfind through other creatures without bumping into them
// for the duration of the effect.
struct PRCeffect PRCEffectCutsceneGhost();

// Returns an effect that when applied will paralyze the target's legs, rendering
// them unable to walk but otherwise unpenalized. This effect cannot be resisted.
struct PRCeffect PRCEffectCutsceneImmobilize();

// Apply eEffect at lLocation.
void PRCApplyEffectAtLocation(int nDurationType, struct PRCeffect prceEffect, location lLocation, float fDuration=0.0f);

//#include "inc_dispel"

void PRCApplyEffectAtLocation(int nDurationType, struct PRCeffect prceEffect, location lLocation, float fDuration=0.0f)
{
    ApplyEffectAtLocation(nDurationType, prceEffect.eEffect, lLocation, fDuration);
}

//get/set local handlers
void             SetLocalPRCEffect(object oObject, string sVarName, struct PRCeffect eValue)
{
    SetLocalInt     (oObject, sVarName+".nEffectType", eValue.nEffectType);
    SetLocalInt     (oObject, sVarName+".nEffectSubtype", eValue.nEffectSubtype);
    SetLocalInt     (oObject, sVarName+".nDurationType", eValue.nDurationType);
    SetLocalFloat   (oObject, sVarName+".fDuration", eValue.fDuration);
    SetLocalInt     (oObject, sVarName+".nVersesRace", eValue.nVersesRace);
    SetLocalInt     (oObject, sVarName+".nVersesTraps", eValue.nVersesTraps);
    SetLocalInt     (oObject, sVarName+".nVersesAlignmentOrder", eValue.nVersesAlignmentOrder);
    SetLocalInt     (oObject, sVarName+".nVersesAlignmentMoral", eValue.nVersesAlignmentMoral);
    SetLocalInt     (oObject, sVarName+".nLinkedCount", eValue.nLinkedCount);
    SetLocalInt     (oObject, sVarName+".nLinkedID", eValue.nLinkedID);
    SetLocalInt     (oObject, sVarName+".nSpellID", eValue.nSpellID);
    SetLocalInt     (oObject, sVarName+".nCasterLevel", eValue.nCasterLevel);
    SetLocalObject  (oObject, sVarName+".oCaster", eValue.oCaster);
    SetLocalInt     (oObject, sVarName+".nMetamagic", eValue.nMetamagic);
    SetLocalInt     (oObject, sVarName+".nSpellLevel", eValue.nSpellLevel);
    SetLocalInt     (oObject, sVarName+".nWeave", eValue.nWeave);
    SetLocalInt     (oObject, sVarName+".nVar1", eValue.nVar1);
    SetLocalInt     (oObject, sVarName+".nVar2", eValue.nVar2);
    SetLocalInt     (oObject, sVarName+".nVar3", eValue.nVar3);
    SetLocalInt     (oObject, sVarName+".nVar4", eValue.nVar4);
    SetLocalInt     (oObject, sVarName+".nVar5", eValue.nVar5);
    SetLocalInt     (oObject, sVarName+".nVar6", eValue.nVar6);
    SetLocalInt     (oObject, sVarName+".nVar7", eValue.nVar7);
    SetLocalInt     (oObject, sVarName+".nVar8", eValue.nVar8);
    SetLocalInt     (oObject, sVarName+".nVar9", eValue.nVar9);
    SetLocalObject  (oObject, sVarName+".oVar1", eValue.oVar1);
    SetLocalObject  (oObject, sVarName+".oVar2", eValue.oVar2);
    SetLocalObject  (oObject, sVarName+".oVar3", eValue.oVar3);
    SetLocalObject  (oObject, sVarName+".oVar1", eValue.oVar4);
    SetLocalObject  (oObject, sVarName+".oVar5", eValue.oVar5);
    SetLocalObject  (oObject, sVarName+".oVar6", eValue.oVar6);
    SetLocalObject  (oObject, sVarName+".oVar7", eValue.oVar7);
    SetLocalObject  (oObject, sVarName+".oVar8", eValue.oVar8);
    SetLocalObject  (oObject, sVarName+".oVar9", eValue.oVar9);
    SetLocalString  (oObject, sVarName+".sVar1", eValue.sVar1);
    SetLocalString  (oObject, sVarName+".sVar2", eValue.sVar2);
    SetLocalString  (oObject, sVarName+".sVar3", eValue.sVar3);
    SetLocalString  (oObject, sVarName+".sVar4", eValue.sVar4);
    SetLocalString  (oObject, sVarName+".sVar5", eValue.sVar5);
    SetLocalString  (oObject, sVarName+".sVar6", eValue.sVar6);
    SetLocalString  (oObject, sVarName+".sVar7", eValue.sVar7);
    SetLocalString  (oObject, sVarName+".sVar8", eValue.sVar8);
    SetLocalString  (oObject, sVarName+".sVar9", eValue.sVar9);
    SetLocalLocation(oObject, sVarName+".lVar1", eValue.lVar1);
    SetLocalLocation(oObject, sVarName+".lVar2", eValue.lVar2);
    SetLocalLocation(oObject, sVarName+".lVar3", eValue.lVar3);
    SetLocalLocation(oObject, sVarName+".lVar4", eValue.lVar4);
    SetLocalLocation(oObject, sVarName+".lVar5", eValue.lVar5);
    SetLocalLocation(oObject, sVarName+".lVar6", eValue.lVar6);
    SetLocalLocation(oObject, sVarName+".lVar7", eValue.lVar7);
    SetLocalLocation(oObject, sVarName+".lVar8", eValue.lVar8);
    SetLocalLocation(oObject, sVarName+".lVar9", eValue.lVar9);
    SetLocalFloat   (oObject, sVarName+".fVar1", eValue.fVar1);
    SetLocalFloat   (oObject, sVarName+".fVar2", eValue.fVar2);
    SetLocalFloat   (oObject, sVarName+".fVar3", eValue.fVar3);
    SetLocalFloat   (oObject, sVarName+".fVar4", eValue.fVar4);
    SetLocalFloat   (oObject, sVarName+".fVar5", eValue.fVar5);
    SetLocalFloat   (oObject, sVarName+".fVar6", eValue.fVar6);
    SetLocalFloat   (oObject, sVarName+".fVar7", eValue.fVar7);
    SetLocalFloat   (oObject, sVarName+".fVar8", eValue.fVar8);
    SetLocalFloat   (oObject, sVarName+".fVar9", eValue.fVar9);
}
struct PRCeffect GetLocalPRCEffect(object oObject, string sVarName)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nEffectType=    GetLocalInt     (oObject, sVarName+".nEffectType");
    eReturn.nEffectSubtype= GetLocalInt     (oObject, sVarName+".nEffectSubtype");
    eReturn.nDurationType=  GetLocalInt     (oObject, sVarName+".nDurationType");
    eReturn.fDuration=      GetLocalFloat   (oObject, sVarName+".fDuration");
    eReturn.nVersesRace=    GetLocalInt     (oObject, sVarName+".nVersesRace");
    eReturn.nVersesTraps=   GetLocalInt     (oObject, sVarName+".nVersesTraps");
    eReturn.nVersesAlignmentOrder=GetLocalInt(oObject,sVarName+".nVersesAlignmentOrder");
    eReturn.nVersesAlignmentMoral=GetLocalInt(oObject,sVarName+".nVersesAlignmentMoral");
    eReturn.nLinkedCount=   GetLocalInt     (oObject, sVarName+".nLinkedCount");
    eReturn.nLinkedID=      GetLocalInt     (oObject, sVarName+".nLinkedID");
    eReturn.nSpellID=       GetLocalInt     (oObject, sVarName+".nSpellID");
    eReturn.nCasterLevel=   GetLocalInt     (oObject, sVarName+".nCasterLevel");
    eReturn.oCaster=        GetLocalObject  (oObject, sVarName+".oCaster");
    eReturn.nMetamagic=     GetLocalInt     (oObject, sVarName+".nMetamagic");
    eReturn.nSpellLevel=    GetLocalInt     (oObject, sVarName+".nSpellLevel");
    eReturn.nWeave=         GetLocalInt     (oObject, sVarName+".nWeave");
    eReturn.nVar1=          GetLocalInt     (oObject, sVarName+".nVar1");
    eReturn.nVar2=          GetLocalInt     (oObject, sVarName+".nVar2");
    eReturn.nVar3=          GetLocalInt     (oObject, sVarName+".nVar3");
    eReturn.nVar4=          GetLocalInt     (oObject, sVarName+".nVar4");
    eReturn.nVar5=          GetLocalInt     (oObject, sVarName+".nVar5");
    eReturn.nVar6=          GetLocalInt     (oObject, sVarName+".nVar6");
    eReturn.nVar7=          GetLocalInt     (oObject, sVarName+".nVar7");
    eReturn.nVar8=          GetLocalInt     (oObject, sVarName+".nVar8");
    eReturn.nVar9=          GetLocalInt     (oObject, sVarName+".nVar9");
    eReturn.oVar1=          GetLocalObject  (oObject, sVarName+".oVar1");
    eReturn.oVar2=          GetLocalObject  (oObject, sVarName+".oVar2");
    eReturn.oVar3=          GetLocalObject  (oObject, sVarName+".oVar3");
    eReturn.oVar4=          GetLocalObject  (oObject, sVarName+".oVar4");
    eReturn.oVar5=          GetLocalObject  (oObject, sVarName+".oVar5");
    eReturn.oVar6=          GetLocalObject  (oObject, sVarName+".oVar6");
    eReturn.oVar7=          GetLocalObject  (oObject, sVarName+".oVar7");
    eReturn.oVar8=          GetLocalObject  (oObject, sVarName+".oVar8");
    eReturn.oVar9=          GetLocalObject  (oObject, sVarName+".oVar9");
    eReturn.sVar1=          GetLocalString  (oObject, sVarName+".sVar1");
    eReturn.sVar2=          GetLocalString  (oObject, sVarName+".sVar2");
    eReturn.sVar3=          GetLocalString  (oObject, sVarName+".sVar3");
    eReturn.sVar4=          GetLocalString  (oObject, sVarName+".sVar4");
    eReturn.sVar5=          GetLocalString  (oObject, sVarName+".sVar5");
    eReturn.sVar6=          GetLocalString  (oObject, sVarName+".sVar6");
    eReturn.sVar7=          GetLocalString  (oObject, sVarName+".sVar7");
    eReturn.sVar8=          GetLocalString  (oObject, sVarName+".sVar8");
    eReturn.sVar9=          GetLocalString  (oObject, sVarName+".sVar9");
    eReturn.lVar1=          GetLocalLocation(oObject, sVarName+".lVar1");
    eReturn.lVar2=          GetLocalLocation(oObject, sVarName+".lVar2");
    eReturn.lVar3=          GetLocalLocation(oObject, sVarName+".lVar3");
    eReturn.lVar4=          GetLocalLocation(oObject, sVarName+".lVar4");
    eReturn.lVar5=          GetLocalLocation(oObject, sVarName+".lVar5");
    eReturn.lVar6=          GetLocalLocation(oObject, sVarName+".lVar6");
    eReturn.lVar7=          GetLocalLocation(oObject, sVarName+".lVar7");
    eReturn.lVar8=          GetLocalLocation(oObject, sVarName+".lVar8");
    eReturn.lVar9=          GetLocalLocation(oObject, sVarName+".lVar9");
    eReturn.fVar1=          GetLocalFloat   (oObject, sVarName+".fVar1");
    eReturn.fVar2=          GetLocalFloat   (oObject, sVarName+".fVar2");
    eReturn.fVar3=          GetLocalFloat   (oObject, sVarName+".fVar3");
    eReturn.fVar4=          GetLocalFloat   (oObject, sVarName+".fVar4");
    eReturn.fVar5=          GetLocalFloat   (oObject, sVarName+".fVar5");
    eReturn.fVar6=          GetLocalFloat   (oObject, sVarName+".fVar6");
    eReturn.fVar7=          GetLocalFloat   (oObject, sVarName+".fVar7");
    eReturn.fVar8=          GetLocalFloat   (oObject, sVarName+".fVar8");
    eReturn.fVar9=          GetLocalFloat   (oObject, sVarName+".fVar9");
    return eReturn;
}

void             DeleteLocalPRCEffect(object oObject, string sVarName)
{
    DeleteLocalInt     (oObject, sVarName+".nEffectType");
    DeleteLocalInt     (oObject, sVarName+".nEffectSubtype");
    DeleteLocalInt     (oObject, sVarName+".nDurationType");
    DeleteLocalFloat   (oObject, sVarName+".fDuration");
    DeleteLocalInt     (oObject, sVarName+".nVersesRace");
    DeleteLocalInt     (oObject, sVarName+".nVersesTraps");
    DeleteLocalInt     (oObject, sVarName+".nVersesAlignmentOrder");
    DeleteLocalInt     (oObject, sVarName+".nVersesAlignmentMoral");
    DeleteLocalInt     (oObject, sVarName+".nLinkedCount");
    DeleteLocalInt     (oObject, sVarName+".nLinkedID");
    DeleteLocalInt     (oObject, sVarName+".nSpellID");
    DeleteLocalInt     (oObject, sVarName+".nCasterLevel");
    DeleteLocalObject  (oObject, sVarName+".oCaster");
    DeleteLocalInt     (oObject, sVarName+".nMetamagic");
    DeleteLocalInt     (oObject, sVarName+".nSpellLevel");
    DeleteLocalInt     (oObject, sVarName+".nWeave");
    DeleteLocalInt     (oObject, sVarName+".nVar1");
    DeleteLocalInt     (oObject, sVarName+".nVar2");
    DeleteLocalInt     (oObject, sVarName+".nVar3");
    DeleteLocalInt     (oObject, sVarName+".nVar4");
    DeleteLocalInt     (oObject, sVarName+".nVar5");
    DeleteLocalInt     (oObject, sVarName+".nVar6");
    DeleteLocalInt     (oObject, sVarName+".nVar7");
    DeleteLocalInt     (oObject, sVarName+".nVar8");
    DeleteLocalInt     (oObject, sVarName+".nVar9");
    DeleteLocalObject  (oObject, sVarName+".oVar1");
    DeleteLocalObject  (oObject, sVarName+".oVar2");
    DeleteLocalObject  (oObject, sVarName+".oVar3");
    DeleteLocalObject  (oObject, sVarName+".oVar1");
    DeleteLocalObject  (oObject, sVarName+".oVar5");
    DeleteLocalObject  (oObject, sVarName+".oVar6");
    DeleteLocalObject  (oObject, sVarName+".oVar7");
    DeleteLocalObject  (oObject, sVarName+".oVar8");
    DeleteLocalObject  (oObject, sVarName+".oVar9");
    DeleteLocalString  (oObject, sVarName+".sVar1");
    DeleteLocalString  (oObject, sVarName+".sVar2");
    DeleteLocalString  (oObject, sVarName+".sVar3");
    DeleteLocalString  (oObject, sVarName+".sVar4");
    DeleteLocalString  (oObject, sVarName+".sVar5");
    DeleteLocalString  (oObject, sVarName+".sVar6");
    DeleteLocalString  (oObject, sVarName+".sVar7");
    DeleteLocalString  (oObject, sVarName+".sVar8");
    DeleteLocalString  (oObject, sVarName+".sVar9");
    DeleteLocalLocation(oObject, sVarName+".lVar1");
    DeleteLocalLocation(oObject, sVarName+".lVar2");
    DeleteLocalLocation(oObject, sVarName+".lVar3");
    DeleteLocalLocation(oObject, sVarName+".lVar4");
    DeleteLocalLocation(oObject, sVarName+".lVar5");
    DeleteLocalLocation(oObject, sVarName+".lVar6");
    DeleteLocalLocation(oObject, sVarName+".lVar7");
    DeleteLocalLocation(oObject, sVarName+".lVar8");
    DeleteLocalLocation(oObject, sVarName+".lVar9");
    DeleteLocalFloat   (oObject, sVarName+".fVar1");
    DeleteLocalFloat   (oObject, sVarName+".fVar2");
    DeleteLocalFloat   (oObject, sVarName+".fVar3");
    DeleteLocalFloat   (oObject, sVarName+".fVar4");
    DeleteLocalFloat   (oObject, sVarName+".fVar5");
    DeleteLocalFloat   (oObject, sVarName+".fVar6");
    DeleteLocalFloat   (oObject, sVarName+".fVar7");
    DeleteLocalFloat   (oObject, sVarName+".fVar8");
    DeleteLocalFloat   (oObject, sVarName+".fVar9");

}

//default constructor
struct PRCeffect GetNewPRCEffectBase()
{
    //not sure if anything needs to be here at the moment
    struct PRCeffect eReturn;
    return eReturn;
}

//new effect-related functions
string GetIdentifierFromEffect(effect eEffect)
{
    string sReturn;
    sReturn += IntToString(GetEffectType(eEffect))+"_";
    sReturn += IntToString(GetEffectSubType(eEffect))+"_";
    sReturn += ObjectToString(GetEffectCreator(eEffect))+"_";
    sReturn += IntToString(GetEffectSpellId(eEffect))+"_";
    sReturn += IntToString(GetEffectDurationType(eEffect));
    return sReturn;
}

//replacements of the bioware functions
//just one or two here

// Get the first in-game effect on oCreature.
struct PRCeffect PRCGetFirstEffect(object oCreature)
{
    effect eEffect = GetFirstEffect(oCreature);
    string sID = GetIdentifierFromEffect(eEffect);
    struct PRCeffect prceEffect = GetLocalPRCEffect(oCreature, sID);
    prceEffect.eEffect = eEffect;
    return prceEffect;
}

// Get the next in-game effect on oCreature.
struct PRCeffect PRCGetNextEffect(object oCreature)
{
    effect eEffect = GetNextEffect(oCreature);
    string sID = GetIdentifierFromEffect(eEffect);
    struct PRCeffect prceEffect = GetLocalPRCEffect(oCreature, sID);
    prceEffect.eEffect = eEffect;
    return prceEffect;
}

// * Returns TRUE if eEffect is a valid effect. The effect must have been applied to
// * an object or else it will return FALSE
int PRCGetIsEffectValid(struct PRCeffect prceEffect)
{
    return GetIsEffectValid(prceEffect.eEffect);
}

effect GetEffectOnObjectFromPRCEffect(struct PRCeffect prceEffect, object oObject)
{
    effect eTest;
    //quick check, no loop
    if(!GetHasSpellEffect(prceEffect.nSpellID, oObject))
        return eTest;

    eTest = GetFirstEffect(oObject);
    while(GetIsEffectValid(eTest))
    {
        if(GetEffectType(eTest) == prceEffect.nEffectType
            && GetEffectSubType(eTest) == prceEffect.nEffectSubtype
            && GetEffectCreator(eTest) == prceEffect.oCaster
            && GetEffectSpellId(eTest) == prceEffect.nSpellID
            && GetEffectDurationType(eTest) == prceEffect.nDurationType)
            return eTest;
        eTest = GetNextEffect(oObject);
    }
    return eTest;
}

// Remove eEffect from oCreature.
// * No return value
void PRCRemoveEffect(object oCreature, struct PRCeffect eEffect)
{


}

// Get the duration type (DURATION_TYPE_*) of eEffect.
// * Return value if eEffect is not valid: -1
int PRCGetEffectDurationType(struct PRCeffect prceEffect)
{
    return prceEffect.nDurationType;
}

// Get the subtype (SUBTYPE_*) of eEffect.
// * Return value on error: 0
int PRCGetEffectSubType(struct PRCeffect prceEffect)
{
    return prceEffect.nEffectSubtype;
}

// Get the object that created eEffect.
// * Returns OBJECT_INVALID if eEffect is not a valid effect.
object PRCGetEffectCreator(struct PRCeffect prceEffect)
{
    return prceEffect.oCaster;
}

// Get the effect type (EFFECT_TYPE_*) of eEffect.
// * Return value if eEffect is invalid: EFFECT_INVALIDEFFECT
int PRCGetEffectType(struct PRCeffect prceEffect)
{
    return prceEffect.nEffectType;
}

// Get the spell (SPELL_*) that applied eSpellEffect.
// * Returns -1 if eSpellEffect was applied outside a spell script.
int PRCGetEffectSpellId(struct PRCeffect prceEffect)
{
    return prceEffect.nSpellID;
}

// Set the subtype of eEffect to Magical and return eEffect.
// (Effects default to magical if the subtype is not set)
// Magical effects are removed by resting, and by dispel magic
struct PRCeffect PRCMagicalEffect(struct PRCeffect eEffect)
{
    eEffect.nEffectSubtype = SUBTYPE_MAGICAL;
    eEffect.eEffect = MagicalEffect(eEffect.eEffect);
    return eEffect;
}

// Set the subtype of eEffect to Supernatural and return eEffect.
// (Effects default to magical if the subtype is not set)
// Permanent supernatural effects are not removed by resting
struct PRCeffect PRCSupernaturalEffect(struct PRCeffect eEffect)
{
    eEffect.nEffectSubtype = SUBTYPE_SUPERNATURAL;
    eEffect.eEffect = SupernaturalEffect(eEffect.eEffect);
    return eEffect;
}

// Set the subtype of eEffect to Extraordinary and return eEffect.
// (Effects default to magical if the subtype is not set)
// Extraordinary effects are removed by resting, but not by dispel magic
struct PRCeffect PRCExtraordinaryEffect(struct PRCeffect eEffect)
{
    eEffect.nEffectSubtype = SUBTYPE_EXTRAORDINARY;
    eEffect.eEffect = ExtraordinaryEffect(eEffect.eEffect);
    return eEffect;
}


// Set eEffect to be versus a specific alignment.
// - eEffect
// - nLawChaos: ALIGNMENT_LAWFUL/ALIGNMENT_CHAOTIC/ALIGNMENT_ALL
// - nGoodEvil: ALIGNMENT_GOOD/ALIGNMENT_EVIL/ALIGNMENT_ALL
struct PRCeffect PRCVersusAlignmentEffect(struct PRCeffect eEffect, int nLawChaos=ALIGNMENT_ALL, int nGoodEvil=ALIGNMENT_ALL)
{
    eEffect.nVersesAlignmentOrder = nLawChaos;
    eEffect.nVersesAlignmentMoral = nGoodEvil;
    eEffect.eEffect = VersusAlignmentEffect(eEffect.eEffect, nLawChaos, nGoodEvil);
    return eEffect;
}

// Set eEffect to be versus nRacialType.
// - eEffect
// - nRacialType: RACIAL_TYPE_*
struct PRCeffect PRCVersusRacialTypeEffect(struct PRCeffect eEffect, int nRacialType)
{
    eEffect.nVersesRace = nRacialType;
    eEffect.eEffect = VersusRacialTypeEffect(eEffect.eEffect, nRacialType);
    return eEffect;
}

// Set eEffect to be versus traps.
struct PRCeffect PRCVersusTrapEffect(struct PRCeffect eEffect)
{
    eEffect.nVersesTraps = TRUE;
    eEffect.eEffect = VersusTrapEffect(eEffect.eEffect);
    return eEffect;
}


//actual constructors

// Create a Heal effect. This should be applied as an instantaneous effect.
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nDamageToHeal < 0.
struct PRCeffect PRCEffectHeal(int nDamageToHeal)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nDamageToHeal;
    eReturn.eEffect = EffectHeal(nDamageToHeal);
    return eReturn;
}

// Create a Damage effect
// - nDamageAmount: amount of damage to be dealt. This should be applied as an
//   instantaneous effect.
// - nDamageType: DAMAGE_TYPE_*
// - nDamagePower: DAMAGE_POWER_*
struct PRCeffect PRCEffectDamage(int nDamageAmount, int nDamageType=DAMAGE_TYPE_MAGICAL, int nDamagePower=DAMAGE_POWER_NORMAL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nDamageAmount;
    eReturn.nVar2 = nDamageType;
    eReturn.nVar3 = nDamagePower;
    eReturn.eEffect = EffectDamage(nDamageAmount,nDamageType,nDamagePower);
    return eReturn;
}

// Create an Ability Increase effect
// - bAbilityToIncrease: ABILITY_*
struct PRCeffect PRCEffectAbilityIncrease(int nAbilityToIncrease, int nModifyBy)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nAbilityToIncrease;
    eReturn.nVar2 = nModifyBy;
    eReturn.eEffect = EffectAbilityIncrease(nAbilityToIncrease,nModifyBy);
    return eReturn;
}

// Create a Damage Resistance effect that removes the first nAmount points of
// damage of type nDamageType, up to nLimit (or infinite if nLimit is 0)
// - nDamageType: DAMAGE_TYPE_*
// - nAmount
// - nLimit
struct PRCeffect PRCEffectDamageResistance(int nDamageType, int nAmount, int nLimit=0)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nDamageType;
    eReturn.nVar2 = nAmount;
    eReturn.nVar3 = nLimit;
    eReturn.eEffect = EffectDamageResistance(nDamageType,nAmount,nLimit);
    return eReturn;
}

// Create a Resurrection effect. This should be applied as an instantaneous effect.
struct PRCeffect PRCEffectResurrection()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectResurrection();
    return eReturn;
}

// Create a Summon Creature effect.  The creature is created and placed into the
// caller's party/faction.
// - sCreatureResref: Identifies the creature to be summoned
// - nVisualEffectId: VFX_*
// - fDelaySeconds: There can be delay between the visual effect being played, and the
//   creature being added to the area
// - nUseAppearAnimation: should this creature play it's "appear" animation when it is
//   summoned. If zero, it will just fade in somewhere near the target.  If the value is 1
//   it will use the appear animation, and if it's 2 it will use appear2 (which doesn't exist for most creatures)
struct PRCeffect PRCEffectSummonCreature(string sCreatureResref, int nVisualEffectId=VFX_NONE, float fDelaySeconds=0.0f, int nUseAppearAnimation=0)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.sVar1 = sCreatureResref;
    eReturn.nVar1 = nVisualEffectId;
    eReturn.fVar1 = fDelaySeconds;
    eReturn.nVar2 = nUseAppearAnimation;
    eReturn.eEffect = EffectSummonCreature(sCreatureResref,nVisualEffectId,fDelaySeconds,nUseAppearAnimation);
    return eReturn;
}

// Create an AC Increase effect
// - nValue: size of AC increase
// - nModifyType: AC_*_BONUS
// - nDamageType: DAMAGE_TYPE_*
//   * Default value for nDamageType should only ever be used in this function prototype.
struct PRCeffect PRCEffectACIncrease(int nValue, int nModifyType=AC_DODGE_BONUS, int nDamageType=AC_VS_DAMAGE_TYPE_ALL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nValue;
    eReturn.nVar2 = nModifyType;
    eReturn.nVar3 = nDamageType;
    eReturn.eEffect = EffectACIncrease(nValue,nModifyType,nDamageType);
    return eReturn;
}

// Create a Saving Throw Increase effect
// - nSave: SAVING_THROW_* (not SAVING_THROW_TYPE_*)
//          SAVING_THROW_ALL
//          SAVING_THROW_FORT
//          SAVING_THROW_REFLEX
//          SAVING_THROW_WILL
// - nValue: size of the Saving Throw increase
// - nSaveType: SAVING_THROW_TYPE_* (e.g. SAVING_THROW_TYPE_ACID )
struct PRCeffect PRCEffectSavingThrowIncrease(int nSave, int nValue, int nSaveType=SAVING_THROW_TYPE_ALL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nSave;
    eReturn.nVar2 = nValue;
    eReturn.nVar3 = nSaveType;
    eReturn.eEffect = EffectSavingThrowIncrease(nSave,nValue,nSaveType);
    return eReturn;
}

// Create an Attack Increase effect
// - nBonus: size of attack bonus
// - nModifierType: ATTACK_BONUS_*
struct PRCeffect PRCEffectAttackIncrease(int nBonus, int nModifierType=ATTACK_BONUS_MISC)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nBonus;
    eReturn.nVar2 = nModifierType;
    eReturn.eEffect = EffectAttackIncrease(nBonus,nModifierType);
    return eReturn;
}

// Create a Damage Reduction effect
// - nAmount: amount of damage reduction
// - nDamagePower: DAMAGE_POWER_*
// - nLimit: How much damage the effect can absorb before disappearing.
//   Set to zero for infinite
struct PRCeffect PRCEffectDamageReduction(int nAmount, int nDamagePower, int nLimit=0)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nAmount;
    eReturn.nVar2 = nDamagePower;
    eReturn.nVar3 = nLimit;
    eReturn.eEffect = EffectDamageReduction(nAmount,nDamagePower,nLimit);
    return eReturn;
}

// Create a Damage Increase effect
// - nBonus: DAMAGE_BONUS_*
// - nDamageType: DAMAGE_TYPE_*
// NOTE! You *must* use the DAMAGE_BONUS_* constants! Using other values may
//       result in odd behaviour.
struct PRCeffect PRCEffectDamageIncrease(int nBonus, int nDamageType=DAMAGE_TYPE_MAGICAL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nBonus;
    eReturn.nVar2 = nDamageType;
    eReturn.eEffect = EffectDamageIncrease(nBonus,nDamageType);
    return eReturn;
}


// Create an Entangle effect
// When applied, this effect will restrict the creature's movement and apply a
// (-2) to all attacks and a -4 to AC.
struct PRCeffect PRCEffectEntangle()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectEntangle();
    return eReturn;
}

// Create a Death effect
// - nSpectacularDeath: if this is TRUE, the creature to which this effect is
//   applied will die in an extraordinary fashion
// - nDisplayFeedback
struct PRCeffect PRCEffectDeath(int nSpectacularDeath=FALSE, int nDisplayFeedback=TRUE)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nSpectacularDeath;
    eReturn.nVar2 = nDisplayFeedback;
    eReturn.eEffect = EffectDeath(nSpectacularDeath,nDisplayFeedback);
    return eReturn;
}

// Create a Knockdown effect
// This effect knocks creatures off their feet, they will sit until the effect
// is removed. This should be applied as a temporary effect with a 3 second
// duration minimum (1 second to fall, 1 second sitting, 1 second to get up).
struct PRCeffect PRCEffectKnockdown()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectKnockdown();
    return eReturn;
}

// Create a Curse effect.
// - nStrMod: strength modifier
// - nDexMod: dexterity modifier
// - nConMod: constitution modifier
// - nIntMod: intelligence modifier
// - nWisMod: wisdom modifier
// - nChaMod: charisma modifier
struct PRCeffect PRCEffectCurse(int nStrMod=1, int nDexMod=1, int nConMod=1, int nIntMod=1, int nWisMod=1, int nChaMod=1)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nStrMod;
    eReturn.nVar2 = nDexMod;
    eReturn.nVar3 = nConMod;
    eReturn.nVar4 = nIntMod;
    eReturn.nVar5 = nWisMod;
    eReturn.nVar6 = nChaMod;
    eReturn.eEffect = EffectCurse(nStrMod,nDexMod,nConMod,nIntMod,nWisMod,nChaMod);
    return eReturn;
}

// Create a Paralyze effect
struct PRCeffect PRCEffectParalyze()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectParalyze();
    return eReturn;
}

// Create a Spell Immunity effect.
// There is a known bug with this function. There *must* be a parameter specified
// when this is called (even if the desired parameter is SPELL_ALL_SPELLS),
// otherwise an effect of type EFFECT_TYPE_INVALIDEFFECT will be returned.
// - nImmunityToSpell: SPELL_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nImmunityToSpell is
//   invalid.
struct PRCeffect PRCEffectSpellImmunity(int nImmunityToSpell=SPELL_ALL_SPELLS)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nImmunityToSpell;
    eReturn.eEffect = EffectSpellImmunity(nImmunityToSpell);
    return eReturn;
}

// Create a Deaf effect
struct PRCeffect PRCEffectDeaf()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectDeaf();
    return eReturn;
}

// Create a Sleep effect
struct PRCeffect PRCEffectSleep()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectSleep();
    return eReturn;
}

// Create a Charm effect
struct PRCeffect PRCEffectCharmed()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectCharmed();
    return eReturn;
}

// Create a Confuse effect
struct PRCeffect PRCEffectConfused()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectConfused();
    return eReturn;
}

// Create a Frighten effect
struct PRCeffect PRCEffectFrightened()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectFrightened();
    return eReturn;
}

// Create a Dominate effect
struct PRCeffect PRCEffectDominated()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectDominated();
    return eReturn;
}

// Create a Daze effect
struct PRCeffect PRCEffectDazed()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectDazed();
    return eReturn;
}

// Create a Stun effect
struct PRCeffect PRCEffectStunned()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectSilence();
    return eReturn;
}

// Create a Regenerate effect.
// - nAmount: amount of damage to be regenerated per time interval
// - fIntervalSeconds: length of interval in seconds
struct PRCeffect PRCEffectRegenerate(int nAmount, float fIntervalSeconds)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nAmount;
    eReturn.fVar1 = fIntervalSeconds;
    eReturn.eEffect = EffectRegenerate(nAmount,fIntervalSeconds);
    return eReturn;
}

// Create a Movement Speed Increase effect.
// - nPercentChange - range 0 through 99
// eg.
//    0 = no change in speed
//   50 = 50% faster
//   99 = almost twice as fast
struct PRCeffect PRCEffectMovementSpeedIncrease(int nPercentChange)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPercentChange;
    eReturn.eEffect = EffectMovementSpeedIncrease(nPercentChange);
    return eReturn;
}

// Create an Area Of struct PRCeffect PRCEffect in the area of the creature it is applied to.
// If the scripts are not specified, default ones will be used.
struct PRCeffect PRCEffectAreaOfEffect(int nAreaEffectId, string sOnEnterScript="", string sHeartbeatScript="", string sOnExitScript="")
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nAreaEffectId;
    eReturn.sVar1 = sOnEnterScript;
    eReturn.sVar2 = sHeartbeatScript;
    eReturn.sVar3 = sOnExitScript;
    eReturn.eEffect = EffectAreaOfEffect(nAreaEffectId,sOnEnterScript,sHeartbeatScript, sOnExitScript);
    return eReturn;
}

// * Create a Visual Effect that can be applied to an object.
// - nVisualEffectId
// - nMissEffect: if this is TRUE, a random vector near or past the target will
//   be generated, on which to play the effect
struct PRCeffect PRCEffectVisualEffect(int nVisualEffectId, int nMissEffect=FALSE)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nVisualEffectId;
    eReturn.nVar2 = nMissEffect;
    eReturn.eEffect = EffectVisualEffect(nVisualEffectId,nMissEffect);
    return eReturn;
}

// Link the two supplied effects, returning eChildEffect as a child of
// eParentEffect.
// Note: When applying linked effects if the target is immune to all valid
// effects all other effects will be removed as well. This means that if you
// apply a visual effect and a silence effect (in a link) and the target is
// immune to the silence effect that the visual effect will get removed as well.
// Visual Effects are not considered "valid" effects for the purposes of
// determining if an effect will be removed or not and as such should never be
// packaged *only* with other visual effects in a link.
struct PRCeffect PRCEffectLinkEffects(struct PRCeffect  eChildEffect, struct PRCeffect  eParentEffect )
{
    //need to actually do something here
    eParentEffect.eEffect = EffectLinkEffects(eChildEffect.eEffect, eParentEffect.eEffect);
    return eParentEffect;
}

// Create a Beam effect.
// - nBeamVisualEffect: VFX_BEAM_*
// - oEffector: the beam is emitted from this creature
// - nBodyPart: BODY_NODE_*
// - bMissEffect: If this is TRUE, the beam will fire to a random vector near or
//   past the target
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nBeamVisualEffect is
//   not valid.
struct PRCeffect PRCEffectBeam(int nBeamVisualEffect, object oEffector, int nBodyPart, int bMissEffect=FALSE)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nBeamVisualEffect;
    eReturn.oVar1 = oEffector;
    eReturn.nVar2 = nBodyPart;
    eReturn.nVar3 = bMissEffect;
    eReturn.eEffect = EffectBeam(nBeamVisualEffect, oEffector, nBodyPart, bMissEffect);
    return eReturn;
}

// Create a Spell Resistance Increase effect.
// - nValue: size of spell resistance increase
struct PRCeffect PRCEffectSpellResistanceIncrease(int nValue)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nValue;
    eReturn.eEffect = EffectSpellResistanceIncrease(nValue);
    return eReturn;
}

// Create a Poison effect.
// - nPoisonType: POISON_*
struct PRCeffect PRCEffectPoison(int nPoisonType)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPoisonType;
    eReturn.eEffect = EffectPoison(nPoisonType);
    return eReturn;
}

// Create a Disease effect.
// - nDiseaseType: DISEASE_*
struct PRCeffect PRCEffectDisease(int nDiseaseType)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nDiseaseType;
    eReturn.eEffect = EffectDisease(nDiseaseType);
    return eReturn;
}

// Create a Silence effect.
struct PRCeffect PRCEffectSilence()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectSilence();
    return eReturn;
}

// Create a Haste effect.
struct PRCeffect PRCEffectHaste()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectHaste();
    return eReturn;
}

// Create a Slow effect.
struct PRCeffect PRCEffectSlow()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectSlow();
    return eReturn;
}

// Create an Immunity effect.
// - nImmunityType: IMMUNITY_TYPE_*
struct PRCeffect PRCEffectImmunity(int nImmunityType)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nImmunityType;
    eReturn.eEffect = EffectImmunity(nImmunityType);
    return eReturn;
}

// Creates a Damage Immunity Increase effect.
// - nDamageType: DAMAGE_TYPE_*
// - nPercentImmunity
struct PRCeffect PRCEffectDamageImmunityIncrease(int nDamageType, int nPercentImmunity)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nDamageType;
    eReturn.nVar2 = nPercentImmunity;
    eReturn.eEffect = EffectDamageImmunityIncrease(nDamageType,nPercentImmunity);
    return eReturn;
}

// Create a Temporary Hitpoints effect.
// - nHitPoints: a positive integer
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nHitPoints < 0.
struct PRCeffect PRCEffectTemporaryHitpoints(int nHitPoints)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nHitPoints;
    eReturn.eEffect = EffectTemporaryHitpoints(nHitPoints);
    return eReturn;
}

// Create a Skill Increase effect.
// - nSkill: SKILL_*
// - nValue
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nSkill is invalid.
struct PRCeffect PRCEffectSkillIncrease(int nSkill, int nValue)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nSkill;
    eReturn.nVar2 = nValue;
    eReturn.eEffect = EffectSkillIncrease(nSkill,nValue);
    return eReturn;
}

// Create a Turned effect.
// Turned effects are supernatural by default.
struct PRCeffect PRCEffectTurned()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectTurned();
    return eReturn;
}

// Create a Hit Point Change When Dying effect.
// - fHitPointChangePerRound: this can be positive or negative, but not zero.
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if fHitPointChangePerRound is 0.
struct PRCeffect PRCEffectHitPointChangeWhenDying(float fHitPointChangePerRound)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.fVar1 = fHitPointChangePerRound;
    eReturn.eEffect = EffectHitPointChangeWhenDying(fHitPointChangePerRound);
    return eReturn;
}

// Create an Ability Decrease effect.
// - nAbility: ABILITY_*
// - nModifyBy: This is the amount by which to decrement the ability
struct PRCeffect PRCEffectAbilityDecrease(int nAbility, int nModifyBy)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nAbility;
    eReturn.nVar2 = nModifyBy;
    eReturn.eEffect = EffectAbilityDecrease(nAbility,nModifyBy);
    return eReturn;
}

// Create an Attack Decrease effect.
// - nPenalty
// - nModifierType: ATTACK_BONUS_*
struct PRCeffect PRCEffectAttackDecrease(int nPenalty, int nModifierType=ATTACK_BONUS_MISC)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPenalty;
    eReturn.nVar2 = nModifierType;
    eReturn.eEffect = EffectAttackDecrease(nPenalty,nModifierType);
    return eReturn;
}

// Create a Damage Decrease effect.
// - nPenalty
// - nDamageType: DAMAGE_TYPE_*
struct PRCeffect PRCEffectDamageDecrease(int nPenalty, int nDamageType=DAMAGE_TYPE_MAGICAL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPenalty;
    eReturn.nVar2 = nDamageType;
    eReturn.eEffect = EffectDamageDecrease(nPenalty,nDamageType);
    return eReturn;
}

// Create a Damage Immunity Decrease effect.
// - nDamageType: DAMAGE_TYPE_*
// - nPercentImmunity
struct PRCeffect PRCEffectDamageImmunityDecrease(int nDamageType, int nPercentImmunity)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nDamageType;
    eReturn.nVar2 = nPercentImmunity;
    eReturn.eEffect = EffectDamageImmunityDecrease(nDamageType,nPercentImmunity);
    return eReturn;
}

// Create an AC Decrease effect.
// - nValue
// - nModifyType: AC_*
// - nDamageType: DAMAGE_TYPE_*
//   * Default value for nDamageType should only ever be used in this function prototype.
struct PRCeffect PRCEffectACDecrease(int nValue, int nModifyType=AC_DODGE_BONUS, int nDamageType=AC_VS_DAMAGE_TYPE_ALL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nValue;
    eReturn.nVar2 = nModifyType;
    eReturn.nVar3 = nDamageType;
    eReturn.eEffect = EffectACDecrease(nValue,nModifyType,nDamageType);
    return eReturn;
}

// Create a Movement Speed Decrease effect.
// - nPercentChange - range 0 through 99
// eg.
//    0 = no change in speed
//   50 = 50% slower
//   99 = almost immobile
struct PRCeffect PRCEffectMovementSpeedDecrease(int nPercentChange)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPercentChange;
    eReturn.eEffect = EffectMovementSpeedIncrease(nPercentChange);
    return eReturn;
}

// Create a Saving Throw Decrease effect.
// - nSave: SAVING_THROW_* (not SAVING_THROW_TYPE_*)
//          SAVING_THROW_ALL
//          SAVING_THROW_FORT
//          SAVING_THROW_REFLEX
//          SAVING_THROW_WILL
// - nValue: size of the Saving Throw decrease
// - nSaveType: SAVING_THROW_TYPE_* (e.g. SAVING_THROW_TYPE_ACID )
struct PRCeffect PRCEffectSavingThrowDecrease(int nSave, int nValue, int nSaveType=SAVING_THROW_TYPE_ALL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nSave;
    eReturn.nVar2 = nValue;
    eReturn.nVar3 = nSaveType;
    eReturn.eEffect = EffectSavingThrowDecrease(nSave,nValue,nSaveType);
    return eReturn;
}

// Create a Skill Decrease effect.
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nSkill is invalid.
struct PRCeffect PRCEffectSkillDecrease(int nSkill, int nValue)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nSkill;
    eReturn.nVar2 = nValue;
    eReturn.eEffect = EffectSkillDecrease(nSkill,nValue);
    return eReturn;
}

// Create a Spell Resistance Decrease effect.
struct PRCeffect PRCEffectSpellResistanceDecrease(int nValue)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nValue;
    eReturn.eEffect = EffectSpellResistanceDecrease(nValue);
    return eReturn;
}

// Create an Invisibility effect.
// - nInvisibilityType: INVISIBILITY_TYPE_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nInvisibilityType
//   is invalid.
struct PRCeffect PRCEffectInvisibility(int nInvisibilityType)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nInvisibilityType;
    eReturn.eEffect = EffectInvisibility(nInvisibilityType);
    return eReturn;
}

// Create a Concealment effect.
// - nPercentage: 1-100 inclusive
// - nMissChanceType: MISS_CHANCE_TYPE_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nPercentage < 1 or
//   nPercentage > 100.
struct PRCeffect PRCEffectConcealment(int nPercentage, int nMissType=MISS_CHANCE_TYPE_NORMAL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPercentage;
    eReturn.nVar2 = nMissType;
    eReturn.eEffect = EffectConcealment(nPercentage,nMissType);
    return eReturn;
}

// Create a Darkness effect.
struct PRCeffect PRCEffectDarkness()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectDarkness();
    return eReturn;
}

// Create a Dispel Magic All effect.
// If no parameter is specified, USE_CREATURE_LEVEL will be used. This will
// cause the dispel effect to use the level of the creature that created the
// effect.
struct PRCeffect PRCEffectDispelMagicAll(int nCasterLevel=USE_CREATURE_LEVEL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nCasterLevel;
    eReturn.eEffect = EffectDispelMagicAll(nCasterLevel);
    return eReturn;
}

// Create an Ultravision effect.
struct PRCeffect PRCEffectUltravision()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectUltravision();
    return eReturn;
}

// Create a Negative Level effect.
// - nNumLevels: the number of negative levels to apply.
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nNumLevels > 100.
struct PRCeffect PRCEffectNegativeLevel(int nNumLevels, int bHPBonus=FALSE)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nNumLevels;
    eReturn.nVar2 = bHPBonus;
    eReturn.eEffect = EffectNegativeLevel(nNumLevels,bHPBonus);
    return eReturn;
}

// Create a Polymorph effect.
struct PRCeffect PRCEffectPolymorph(int nPolymorphSelection, int nLocked=FALSE)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPolymorphSelection;
    eReturn.nVar2 = nLocked;
    eReturn.eEffect = EffectPolymorph(nPolymorphSelection,nLocked);
    return eReturn;
}

// Create a Sanctuary effect.
// - nDifficultyClass: must be a non-zero, positive number
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nDifficultyClass <= 0.
struct PRCeffect PRCEffectSanctuary(int nDifficultyClass)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nDifficultyClass;
    eReturn.eEffect = EffectSanctuary(nDifficultyClass);
    return eReturn;
}

// Create a True Seeing effect.
struct PRCeffect PRCEffectTrueSeeing()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectTrueSeeing();
    return eReturn;
}

// Create a See Invisible effect.
struct PRCeffect PRCEffectSeeInvisible()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectSeeInvisible();
    return eReturn;
}

// Create a Time Stop effect.
struct PRCeffect PRCEffectTimeStop()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectTimeStop();
    return eReturn;
}

// Create a Blindness effect.
struct PRCeffect PRCEffectBlindness()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectBlindness();
    return eReturn;
}

// Create a Spell Level Absorption effect.
// - nMaxSpellLevelAbsorbed: maximum spell level that will be absorbed by the
//   effect
// - nTotalSpellLevelsAbsorbed: maximum number of spell levels that will be
//   absorbed by the effect
// - nSpellSchool: SPELL_SCHOOL_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if:
//   nMaxSpellLevelAbsorbed is not between -1 and 9 inclusive, or nSpellSchool
//   is invalid.
struct PRCeffect PRCEffectSpellLevelAbsorption(int nMaxSpellLevelAbsorbed, int nTotalSpellLevelsAbsorbed=0, int nSpellSchool=SPELL_SCHOOL_GENERAL )
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nMaxSpellLevelAbsorbed;
    eReturn.nVar2 = nTotalSpellLevelsAbsorbed;
    eReturn.nVar3 = nSpellSchool;
    eReturn.eEffect = EffectSpellLevelAbsorption(nMaxSpellLevelAbsorbed,nTotalSpellLevelsAbsorbed,nSpellSchool);
    return eReturn;
}

// Create a Dispel Magic Best effect.
// If no parameter is specified, USE_CREATURE_LEVEL will be used. This will
// cause the dispel effect to use the level of the creature that created the
// effect.
struct PRCeffect PRCEffectDispelMagicBest(int nCasterLevel=USE_CREATURE_LEVEL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nCasterLevel;
    eReturn.eEffect = EffectDispelMagicBest(nCasterLevel);
    return eReturn;
}

// Create a Miss Chance effect.
// - nPercentage: 1-100 inclusive
// - nMissChanceType: MISS_CHANCE_TYPE_*
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nPercentage < 1 or
//   nPercentage > 100.
struct PRCeffect PRCEffectMissChance(int nPercentage, int nMissChanceType=MISS_CHANCE_TYPE_NORMAL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPercentage;
    eReturn.nVar2 = nMissChanceType;
    eReturn.eEffect = EffectMissChance(nPercentage,nMissChanceType);
    return eReturn;
}

// Create a Disappear/Appear effect.
// The object will "fly away" for the duration of the effect and will reappear
// at lLocation.
// - nAnimation determines which appear and disappear animations to use. Most creatures
// only have animation 1, although a few have 2 (like beholders)
struct PRCeffect PRCEffectDisappearAppear(location lLocation, int nAnimation=1)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.lVar1 = lLocation;
    eReturn.nVar1 = nAnimation;
    eReturn.eEffect = EffectDisappearAppear(lLocation,nAnimation);
    return eReturn;
}

// Create a Disappear effect to make the object "fly away" and then destroy
// itself.
// - nAnimation determines which appear and disappear animations to use. Most creatures
// only have animation 1, although a few have 2 (like beholders)
struct PRCeffect PRCEffectDisappear(int nAnimation=1)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nAnimation;
    eReturn.eEffect = EffectDisappear(nAnimation);
    return eReturn;
}

// Create an Appear effect to make the object "fly in".
// - nAnimation determines which appear and disappear animations to use. Most creatures
// only have animation 1, although a few have 2 (like beholders)
struct PRCeffect PRCEffectAppear(int nAnimation=1)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nAnimation;
    eReturn.eEffect = EffectAppear(nAnimation);
    return eReturn;
}

// Create a Modify Attacks effect to add attacks.
// - nAttacks: maximum is 5, even with the effect stacked
// * Returns an effect of type EFFECT_TYPE_INVALIDEFFECT if nAttacks > 5.
struct PRCeffect PRCEffectModifyAttacks(int nAttacks)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectModifyAttacks(nAttacks);
    return eReturn;
}

// Create a Damage Shield effect which does (nDamageAmount + nRandomAmount)
// damage to any melee attacker on a successful attack of damage type nDamageType.
// - nDamageAmount: an integer value
// - nRandomAmount: DAMAGE_BONUS_*
// - nDamageType: DAMAGE_TYPE_*
// NOTE! You *must* use the DAMAGE_BONUS_* constants! Using other values may
//       result in odd behaviour.
struct PRCeffect PRCEffectDamageShield(int nDamageAmount, int nRandomAmount, int nDamageType)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nDamageAmount;
    eReturn.nVar2 = nRandomAmount;
    eReturn.nVar3 = nDamageType;
    eReturn.eEffect = EffectDamageShield(nDamageAmount,nRandomAmount,nDamageType);
    return eReturn;
}

// Create a Swarm effect.
// - nLooping: If this is TRUE, for the duration of the effect when one creature
//   created by this effect dies, the next one in the list will be created.  If
//   the last creature in the list dies, we loop back to the beginning and
//   sCreatureTemplate1 will be created, and so on...
// - sCreatureTemplate1
// - sCreatureTemplate2
// - sCreatureTemplate3
// - sCreatureTemplate4
struct PRCeffect PRCEffectSwarm(int nLooping, string sCreatureTemplate1, string sCreatureTemplate2="", string sCreatureTemplate3="", string sCreatureTemplate4="")
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nLooping;
    eReturn.sVar1 = sCreatureTemplate1;
    eReturn.sVar2 = sCreatureTemplate2;
    eReturn.sVar3 = sCreatureTemplate3;
    eReturn.sVar4 = sCreatureTemplate4;
    eReturn.eEffect = EffectSwarm(nLooping,sCreatureTemplate1,sCreatureTemplate2,sCreatureTemplate3,sCreatureTemplate4);
    return eReturn;
}

// Create a Turn Resistance Decrease effect.
// - nHitDice: a positive number representing the number of hit dice for the
///  decrease
struct PRCeffect PRCEffectTurnResistanceDecrease(int nHitDice)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nHitDice;
    eReturn.eEffect = EffectTurnResistanceDecrease(nHitDice);
    return eReturn;
}

// Create a Turn Resistance Increase effect.
// - nHitDice: a positive number representing the number of hit dice for the
//   increase
struct PRCeffect PRCEffectTurnResistanceIncrease(int nHitDice)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nHitDice;
    eReturn.eEffect = EffectTurnResistanceIncrease(nHitDice);
    return eReturn;
}

// returns an effect that will petrify the target
// * currently applies EffectParalyze and the stoneskin visual effect.
struct PRCeffect PRCEffectPetrify()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectPetrify();
    return eReturn;
}

// returns an effect that is guaranteed to paralyze a creature.
// this effect is identical to EffectParalyze except that it cannot be resisted.
struct PRCeffect PRCEffectCutsceneParalyze()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectCutsceneParalyze();
    return eReturn;
}

// Returns an effect that is guaranteed to dominate a creature
// Like EffectDominated but cannot be resisted
struct PRCeffect PRCEffectCutsceneDominated()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectCutsceneDominated();
    return eReturn;
}

// Creates an effect that inhibits spells
// - nPercent - percentage of failure
// - nSpellSchool - the school of spells affected.
struct PRCeffect PRCEffectSpellFailure(int nPercent=100, int nSpellSchool=SPELL_SCHOOL_GENERAL)
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.nVar1 = nPercent;
    eReturn.nVar2 = nSpellSchool;
    eReturn.eEffect = EffectSpellFailure(nPercent,nSpellSchool);
    return eReturn;
}

// Returns an effect of type EFFECT_TYPE_ETHEREAL which works just like EffectSanctuary
// except that the observers get no saving throw
struct PRCeffect PRCEffectEthereal()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectEthereal();
    return eReturn;
}

// Creates a cutscene ghost effect, this will allow creatures
// to pathfind through other creatures without bumping into them
// for the duration of the effect.
struct PRCeffect PRCEffectCutsceneGhost()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectCutsceneGhost();
    return eReturn;
}

// Returns an effect that when applied will paralyze the target's legs, rendering
// them unable to walk but otherwise unpenalized. This effect cannot be resisted.
struct PRCeffect PRCEffectCutsceneImmobilize()
{
    struct PRCeffect eReturn = GetNewPRCEffectBase();
    eReturn.eEffect = EffectCutsceneImmobilize();
    return eReturn;
}