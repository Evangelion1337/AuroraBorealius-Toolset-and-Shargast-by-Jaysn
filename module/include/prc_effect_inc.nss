/**
 * @file
 * This file contains SPApplyEffectToObject(). This was in inc_dispel, but that include should only be in 
 * dispel-type spells and not the core spell engine.
 */

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Gets a creature that can apply an effect
 * Useful to apply/remove specific effects rather than using spellID
 * Remember to assigncommand the effect creation
 */
object GetObjectToApplyNewEffect(string sTag, object oPC, int nStripEffects = TRUE);

/**
 * A wrapper for ApplyEffectToObject() that takes PRC feats into account.
 *
 * @param nDurationType     One of the DURATION_TYPE_* constants
 * @param eEffect           The effect to apply
 * @param oTarget           The target of the effect
 * @param fDuration         The duration for temporary effects
 * @param bDispellable      TRUE if the effect should be dispellable, else FALSE
 * @param nSpellID          The Spell ID of the spell applying the effect. If default is used,
 *                          PRCGetSpellId() is used internally to get the spell ID.
 * @param nCasterLevel      The caster level that the spell is cast with. If default is used,
 *                          PRCGetCasterLevel() is used internally to get the caster level.
 * @param oCaster           The spell caster.
 */
void SPApplyEffectToObject(int nDurationType, effect eEffect, object oTarget, float fDuration = 0.0f,
    int bDispellable = TRUE, int nSpellID = -1, int nCasterLevel = -1, object oCaster = OBJECT_SELF);
    
/**
 * Removes all effects from target that are due to the given spell.
 *
 * Removes all effects caused by the spell nID regardless of caster. By
 * default only removes magical effects.
 *
 * @author Georg Zoeller (presumably copied from a bio script somewhere)
 *
 * @param nID                   The spell ID whose effects to remove.
 * @param oTarget               The object to remove the effects from.
 * @param bMagicalEffectsOnly   Whether to remove only magical effects (TRUE, the default)
 *                              or all effects (FALSE)
 */
void GZPRCRemoveSpellEffects(int nID,object oTarget, int bMagicalEffectsOnly = TRUE);

/**
 * Tests to make sure the data in the effect arrays still refers to an actual effect.
 *
 * Called from within ReorderEffects() and DispelMagicBestMod() (in inc_dispel).  It's purpose
 * is to verify that the effect referred  to by an entry in the 3 arrays is still in effect, in 
 * case it has been dispelled or run out its duration since the data was put there.
 *
 * @param nSpellID  SpellID of the effect to test
 * @param oCaster   Caster of the spell that caused the effectbeing tested
 * @param oTarget   The object whose effect arrays are being looked at.
 *
 * @return          TRUE if the effect is still active, otherwise FALSE.
 */
int IsStillRealEffect(int nSpellID, object oCaster, object oTarget);

/**
 * Checks if target is a Frenzied Bersker with Deathless Frenzy Active
 * If so removes immortality flag so that the death effect from a
 * Death Spell can kill them
 *
 * @param oTarget Creature to test for Deathless Frenzy
 */
void DeathlessFrenzyCheck(object oTarget);

// * Searchs through a persons effects and removes those from a particular spell by a particular caster.
// * PRC Version of a Bioware function to disable include loops
void PRCRemoveSpellEffects(int nSpell_ID, object oCaster, object oTarget);


/**
 * Target is immune to gaze attacks
 *
 * @return           the Gaze Immunity effect
 */
effect EffectGazeImmune();

/**
 * Dazzles the target: -1 Attack, Search, Spot, and VFX
 *
 * @return           the Dazzle effect
 */
effect EffectDazzle();

//ebonfowl: adding this function to check if a target is already shaken
int GetIsShaken(object oTarget);

/**
 * Shaken effect: -2 to attack, all skills and saving throws
 *
 * @return           the Shaken effect
 */
effect EffectShaken();

/**
 * Fatigue effect: -2 to Strength and Dexterity, 25% speed decrease. Can't be dispelled.
 *
 * @return           the Fatigue effect
 */
effect EffectFatigue();

/**
 * Exhausted effect: -6 to Strength and Dexterity, 50% speed decrease. Can't be dispelled.
 *
 * @return           the Exhausted effect
 */
effect EffectExhausted();

/**
 * Cowering effect: -2 to AC, takes no actions (dazed)
 *
 * @return           the Cowering effect
 */
effect EffectCowering();

/**
 * Sickened effect: -2 to attack, damage, all skills, ability checks and saving throws
 *
 * @return           the Sickened effect
 */
effect EffectSickened();

/**
 * Nausea effect: Nauseated creatures are unable to attack, cast spells, concentrate on spells, or do anything 
 * else requiring attention. The only action such a character can take is a single move action per turn.
 * This function takes a duration and target because it sets the enemy's number of attacks in a round to 1
 * Which means once it's called, the BAB effect is applied
 *
 * @return           the Nausea effect
 */
effect EffectNausea(object oTarget, float fDur);

/**
 * Fascinate effect: charmed, -4 to Listen and Spot 
 *
 * @return           the Fascinate effect
 */
effect EffectFascinate();

/**
 * It's Confused, as per normal
 *
 * @return           the Confused effect
 */
effect PRCEffectConfused();

/**
 * It's EffectHeal, but allows us to manipulate the HP total healed
 *
 * @return           the Heal effect
 */
effect PRCEffectHeal(int nHP, object oTarget);

/**
 * Creates skill bonus for all skills based on particular ability.
 * Should be updated if skills.2da file was edited.
 *
 * @param iAbility   base ability
 * @param iIncrease  bonus applied to each skill
 *
 * @return           Skill increase
 */
effect EffectAbilityBasedSkillIncrease(int iAbility, int iIncrease = 1);

/**
 * Creates skill penalty for all skills based on particular ability
 * Should be updated if skills.2da file was edited.
 *
 * @param iAbility   base ability
 * @param iDecrease  penalty applied to each skill
 *
 * @return           Skill decrease
 */
effect EffectAbilityBasedSkillDecrease(int iAbility, int iDecrease = 1);

//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////
#include "prc_inc_castlvl" // get prc_racial_const, prc_inc_nwscript, prc_inc_newip
#include "inc_epicspelldef"

//////////////////////////////////////////////////
/* Internal functions                           */
//////////////////////////////////////////////////

/**
 * Cleans up the 3 arrays used to store effect information on the object.
 *
 * Goes through the whole 3 stored lists of caster levels, spell id's, and casters,
 * deletes any that aren't real anymore (refer to an effect no longer present), then
 * builds a new list out of the ones that are still real/current (refer to effects that
 * are still present)
 * Thus, the list gets cleaned up every time it is added to.
 *
 * @param nSpellID  Spell ID of the spell being cast.
 * @param oTarget   Object to modify the effect arrays of.
 * @param oCaster   The caster of the spell.
 *
 * @return          The number of effects in the 3 new arrays
 */
int _ReorderEffects(int nSpellID, object oTarget, object oCaster = OBJECT_SELF){
   int nIndex = GetLocalInt(oTarget, "X2_Effects_Index_Number");
   int nEffectCastLevel;
   int nEffectSpellID;
   object oEffectCaster;
   int nWeave ;
   int nRealIndex = 0;
   int nPlace;

   for(nPlace = 0; nPlace <= nIndex; nPlace++)
   {
      nEffectSpellID = GetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nPlace));
      oEffectCaster = GetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nPlace));
      nEffectCastLevel = GetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nPlace));
      nWeave =   GetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nPlace));

      DeleteLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nPlace));
      DeleteLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nPlace));
      DeleteLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nPlace));
      DeleteLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nPlace));
      if(IsStillRealEffect(nEffectSpellID, oEffectCaster, oTarget))
      {
          if(nEffectSpellID != nSpellID || oEffectCaster != oCaster)
          // Take it out of the list if it's the spell now being cast, and by the same caster
          // This way spells that don't self dispel when they're recast don't flood the list.
          {
             SetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nRealIndex), nEffectSpellID);
             SetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nRealIndex), nEffectCastLevel);
             SetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nRealIndex),oEffectCaster );
             SetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nRealIndex),nWeave);
             nRealIndex++;
          }// end of if is the same as the current spell and caster
      }// end of if is valid effect statement
   }// end of for statement
   return nRealIndex; // This is the number of values currently in all 3 arrays -1.
}// end of function

//////////////////////////////////////////////////
/* Function Definitions                         */
//////////////////////////////////////////////////

object GetObjectToApplyNewEffect(string sTag, object oPC, int nStripEffects = TRUE)
{
    object oWP = GetObjectByTag(sTag);
    object oLimbo = GetObjectByTag("HEARTOFCHAOS");
    location lLimbo = GetLocation(oLimbo);
    if(!GetIsObjectValid(oLimbo))
        lLimbo = GetStartingLocation();
    //not valid, create it
    if(!GetIsObjectValid(oWP))
    {
        //has to be a creature so it can be jumped around
        //re-used the 2da cache blueprint since it has no scripts
        oWP = CreateObject(OBJECT_TYPE_CREATURE, "prc_2da_cache", lLimbo, FALSE, sTag);
        if(!GetIsObjectValid(oWP) && DEBUG)
        {
            DoDebug(sTag+" is not valid");
        }
        //make sure the player can never interact with WP
        SetPlotFlag(oWP, TRUE);
        SetCreatureAppearanceType(oWP, APPEARANCE_TYPE_INVISIBLE_HUMAN_MALE);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY), oWP);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(), oWP);
		AssignCommand(oWP, ActionUseSkill(SKILL_HIDE, oWP));
		
    }
    //remove previous effects
    if(nStripEffects)
    {
        effect eTest = GetFirstEffect(oPC);
        while(GetIsEffectValid(eTest))
        {
            if(GetEffectCreator(eTest) == oWP
                && GetEffectSubType(eTest) == SUBTYPE_SUPERNATURAL)
            {
                if(DEBUG) DoDebug("Stripping previous effect");
                RemoveEffect(oPC, eTest);
            }
            eTest = GetNextEffect(oPC);
        }
    }
    //jump to PC
    //must be in same area to apply effect
    if(GetArea(oWP) != GetArea(oPC))
        AssignCommand(oWP,
            ActionJumpToObject(oPC));
    //jump back to limbo afterwards
    DelayCommand(0.1,
        AssignCommand(oWP,
            ActionJumpToObject(oLimbo)));
    return oWP;
}

void SPApplyEffectToObject(int nDurationType, effect eEffect, object oTarget, float fDuration = 0.0f,
    int bDispellable = TRUE, int nSpellID = -1, int nCasterLevel = -1, object oCaster = OBJECT_SELF)
{
    if (-1 == nSpellID) nSpellID = PRCGetSpellId();

    //if it was cast from the new spellbook, remove previous effects
    //if(GetLocalInt(OBJECT_SELF, "UsingActionCastSpell"))
    //    GZPRCRemoveSpellEffects(nSpellID, oTarget);

    //Fearsome Necromancy check
    if(GetHasFeat(FEAT_FEARSOME_NECROMANCY, oCaster))
    {
        if(GetSpellSchool(nSpellID) == SPELL_SCHOOL_NECROMANCY)
        {
            if(GetIsEnemy(oTarget, oCaster)
            && !GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS))
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectShaken(), oTarget, 6.0);
            }
        }
    }
    
    // Illusion Veil Meld
    if(GetHasSpellEffect(MELD_ILLUSION_VEIL, oCaster) && GetSpellSchool(nSpellID) == SPELL_SCHOOL_ILLUSION)
		fDuration += GetEssentiaInvested(oCaster, MELD_ILLUSION_VEIL) * 6.0;  

    //Eldritch Spellweave
    if(GetIsObjectValid(GetLocalObject(oCaster, "SPELLWEAVE_TARGET")))
        ExecuteScript("inv_splweave", oCaster);

    // Instant duration effects can use BioWare code, the PRC code doesn't care about those
    if(DURATION_TYPE_INSTANT == nDurationType)
        ApplyEffectToObject(nDurationType, eEffect, oTarget, fDuration);
    else
    {
        // Extraordinary/Supernatural effects are not supposed to be dispellable.
        if (GetEffectSubType(eEffect) == SUBTYPE_EXTRAORDINARY
            || GetEffectSubType(eEffect) == SUBTYPE_SUPERNATURAL)
        {
            bDispellable = FALSE;
        }

        // We need the extra arguments for the PRC code, get them if defaults were passed in.
        if (-1 == nCasterLevel) nCasterLevel = PRCGetCasterLevel(oCaster);

        // Invoke the PRC apply function passing the extra data.
       int nIndex = _ReorderEffects(nSpellID, oTarget, oCaster);
       // Add this new effect to the slot after the last effect already on the character.

       //check if Master's Gift applies
       if(GetHasFeat(FEAT_MASTERS_GIFT, oTarget) && GetIsArcaneClass(PRCGetLastSpellCastClass(), oCaster))
       {
           if(!StringToInt(Get2DACache("spells", "HostileSetting", nSpellID)))
               fDuration *= 2;
       }

       ApplyEffectToObject(nDurationType, eEffect, oTarget, fDuration);
       // may have code traverse the lists right here and not add the new effect
       // if an identical one already appears in the list somewhere

       SetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nIndex), nSpellID);
       SetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nIndex), nCasterLevel);
       SetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nIndex), oCaster );
       if(GetHasFeat(FEAT_SHADOWWEAVE, oCaster))
         SetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nIndex), GetHasFeat(FEAT_TENACIOUSMAGIC,oCaster));
       else
         SetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nIndex), 0);

       //nIndex++;
       /// Set new index number to the character.
       SetLocalInt(oTarget, "X2_Effects_Index_Number", nIndex);
    }
}

void GZPRCRemoveSpellEffects(int nID,object oTarget, int bMagicalEffectsOnly = TRUE){
    effect eEff = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEff))
    {
        if (GetEffectSpellId(eEff) == nID)
        {
            if (GetEffectSubType(eEff) != SUBTYPE_MAGICAL && bMagicalEffectsOnly)
            {
                // ignore
            }
            else
            {
                RemoveEffect(oTarget,eEff);
            }
        }
        eEff = GetNextEffect(oTarget);
    }
}

int IsStillRealEffect(int nSpellID, object oCaster, object oTarget){
   if(!GetHasSpellEffect(nSpellID, oTarget) || nSpellID == 0)
   {
      return FALSE;
   }

   effect eTestSubject = GetFirstEffect(oTarget);
   while(GetIsEffectValid(eTestSubject))
   {
      if(GetEffectSpellId(eTestSubject) == nSpellID)
      {
         if(GetEffectCreator(eTestSubject) == oCaster)
         {
            return TRUE;
         }// end of if originates from oCaster.
      }// end if originates from nSpellID.
      eTestSubject = GetNextEffect(oTarget);
   }
   return FALSE;
}

void DeathlessFrenzyCheck(object oTarget)
{
    //if its immune to death, e.g via items
    //then dont do this
    if(GetIsImmune( oTarget, IMMUNITY_TYPE_DEATH))
        return;
    if(GetHasFeat(FEAT_DEATHLESS_FRENZY, oTarget)
        && GetHasFeatEffect(FEAT_FRENZY, oTarget)
        && GetImmortal(oTarget))
          SetImmortal(oTarget, FALSE);
    //mark them as being magically killed for death system
    if(GetPRCSwitch(PRC_PNP_DEATH_ENABLE))
    {
        SetLocalInt(oTarget, "PRC_PNP_EfectDeathApplied",
            GetLocalInt(oTarget, "PRC_PNP_EfectDeathApplied")+1);
        AssignCommand(oTarget,
            DelayCommand(1.0,
                SetLocalInt(oTarget, "PRC_PNP_EfectDeathApplied",
                    GetLocalInt(oTarget, "PRC_PNP_EfectDeathApplied")-1)));
    }
}

void PRCRemoveSpellEffects(int nSpell_ID, object oCaster, object oTarget){
    //Declare major variables
    int bValid = FALSE;
    effect eAOE;
    if(GetHasSpellEffect(nSpell_ID, oTarget))
    {
        //Search through the valid effects on the target.
        eAOE = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eAOE) && bValid == FALSE)
        {
            if (GetEffectCreator(eAOE) == oCaster)
            {
                //If the effect was created by the spell then remove it
                if(GetEffectSpellId(eAOE) == nSpell_ID)
                {
                    RemoveEffect(oTarget, eAOE);
                    bValid = TRUE;
                }
            }
            //Get next effect on the target
            eAOE = GetNextEffect(oTarget);
        }
    }
}

// The creature is unable to see well because of overstimulation of the eyes. A dazzled
// creature takes a -1 penalty on attack rolls, Search checks, and Spot checks.
effect EffectDazzle(){
    effect eBlank;
    if (GetRacialType(PRCGetSpellTargetObject()) == RACIAL_TYPE_BHUKA) return eBlank;

    effect eReturn = EffectLinkEffects(EffectAttackDecrease(1), EffectSkillDecrease(SKILL_SEARCH, 1));
           eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_SPOT, 1));
           eReturn = TagEffect(eReturn, "PRCDazzle");
    return eReturn;
}

// A shaken character takes a -2 penalty on attack rolls, saving throws, skill checks,
// and ability checks.
// Shaken is a less severe state of fear than frightened or panicked.
effect EffectShaken(){
    effect eBlank;
    if (GetRacialType(PRCGetSpellTargetObject()) == RACIAL_TYPE_KRINTH) return eBlank;

    effect eReturn = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
           eReturn = EffectLinkEffects(eReturn, EffectAttackDecrease(2));
           eReturn = EffectLinkEffects(eReturn, EffectSavingThrowDecrease(SAVING_THROW_ALL,2));
           eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_ALL_SKILLS, 2));
           eReturn = TagEffect(eReturn, "PRCShaken");
    return eReturn;
}

// A fatigued character can neither run nor charge and takes a -2 penalty to Strength
// and Dexterity. Doing anything that would normally cause fatigue causes the fatigued
// character to become exhausted. After 8 hours of complete rest, fatigued characters
// are no longer fatigued.
effect EffectFatigue(){
    effect eBlank;
    if (GetLevelByClass(CLASS_TYPE_BATTLESMITH, PRCGetSpellTargetObject()) >= 3) return eBlank;

    effect eReturn = EffectAbilityDecrease(ABILITY_STRENGTH, 2);
           eReturn = EffectLinkEffects(eReturn, EffectAbilityDecrease(ABILITY_DEXTERITY, 2));
           eReturn = EffectLinkEffects(eReturn, EffectMovementSpeedDecrease(25));
		   eReturn = EffectLinkEffects(eReturn, EffectIcon(EFFECT_ICON_FATIGUE));
           eReturn = TagEffect(eReturn, "PRCFatigue");
    return eReturn;
}

// An exhausted character moves at half speed and takes a -6 penalty to Strength and
// Dexterity. After 1 hour of complete rest, an exhausted character becomes fatigued.
// A fatigued character becomes exhausted by doing something else that would normally
// cause fatigue.
effect EffectExhausted(){
    effect eBlank;
    if (GetLevelByClass(CLASS_TYPE_BATTLESMITH, PRCGetSpellTargetObject()) >= 3) return eBlank;
    
	if (GetLocalInt(PRCGetSpellTargetObject(), "IncarnumDefenseLE")) return EffectFatigue();

    effect eReturn = EffectAbilityDecrease(ABILITY_STRENGTH, 6);
           eReturn = EffectLinkEffects(eReturn, EffectAbilityDecrease(ABILITY_DEXTERITY, 6));
           eReturn = EffectLinkEffects(eReturn, EffectMovementSpeedDecrease(50));
           eReturn = TagEffect(eReturn, "PRCExhausted");
    return eReturn;
}

// The character is frozen in fear and can take no actions. A cowering character takes
// a -2 penalty to Armor Class and loses her Dexterity bonus (if any).
effect EffectCowering(){
    effect eReturn = EffectACDecrease(2);
           eReturn = EffectLinkEffects(eReturn, EffectDazed());
           eReturn = TagEffect(eReturn, "PRCCowering");
    return eReturn;
}

// The character takes a -2 penalty on all attack rolls, weapon damage rolls, saving
// throws, skill checks, and ability checks.
effect EffectSickened(){
	effect eBlank;
	if (GetHasFeat(FEAT_STRONG_STOMACH, PRCGetSpellTargetObject())) return eBlank;

	if(GetHasSpellEffect(MELD_PAULDRONS_OF_HEALTH, PRCGetSpellTargetObject())) return eBlank;

    effect eReturn = EffectAttackDecrease(2);
           eReturn = EffectLinkEffects(eReturn, EffectDamageDecrease(2, DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_PIERCING|DAMAGE_TYPE_SLASHING));
           eReturn = EffectLinkEffects(eReturn, EffectSavingThrowDecrease(SAVING_THROW_ALL, 2));
           eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_ALL_SKILLS, 2));
           eReturn = TagEffect(eReturn, "PRCSickened");
    return eReturn;
}

// Nauseated creatures are unable to attack, cast spells, concentrate on spells, or do anything 
// else requiring attention. The only action such a character can take is a single move action per turn.
effect EffectNausea(object oTarget, float fDur){
	effect eBlank;
	if (GetHasFeat(FEAT_STRONG_STOMACH, PRCGetSpellTargetObject())) return EffectSickened();

	if(GetHasSpellEffect(MELD_PAULDRONS_OF_HEALTH, PRCGetSpellTargetObject())) return eBlank;	
	
    effect eReturn = EffectLinkEffects(EffectSpellFailure(), EffectAttackDecrease(20));
    	   eReturn = EffectLinkEffects(eReturn, EffectSlow());
		   eReturn = EffectLinkEffects(EffectVisualEffect(VFX_IMP_DISEASE_S), eReturn);
           eReturn = TagEffect(eReturn, "PRCNausea");
		   SetBaseAttackBonus(1, oTarget);
		   DelayCommand(fDur, RestoreBaseAttackBonus(oTarget));
    return eReturn;
}

// The creature is fascinated by a magical effect. A fascinate creature
// is charmed and takes a -4 penalty to listen and spot
effect EffectFascinate(){
    effect eReturn = EffectLinkEffects(EffectCharmed(), EffectSkillDecrease(SKILL_LISTEN, 4));
           eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_SPOT, 4));
           eReturn = TagEffect(eReturn, "PRCFascinate");
    return eReturn;
}

// It's just Confused
effect PRCEffectConfused()
{
    effect eBlank;
    if (GetLevelByClass(CLASS_TYPE_WILD_MAGE, PRCGetSpellTargetObject()) >= 6 || 
       (GetHasSpellEffect(VESTIGE_DAHLVERNAR, PRCGetSpellTargetObject()) && GetLocalInt(PRCGetSpellTargetObject(), "ExploitVestige") != VESTIGE_DAHLVERNAR_MAD_SOUL)
       ) return eBlank;

    effect eEffect = EffectConfused();
           eEffect = TagEffect(eEffect, "PRCConfused");
    return eEffect;
}

// It's just Healing
effect PRCEffectHeal(int nHP, object oTarget)
{
	// MELD_THERAPEUTIC_MANTLE
	if (GetHasSpellEffect(MELD_THERAPEUTIC_MANTLE, oTarget))
		nHP += (StringToInt(Get2DACache("spells", "Innate", PRCGetSpellId())) + (GetEssentiaInvested(oTarget, MELD_THERAPEUTIC_MANTLE) * 2));

    return EffectHeal(nHP);
}

effect EffectAbilityBasedSkillIncrease(int iAbility, int iIncrease = 1)
{
    effect eReturn;
    switch(iAbility)
    {
        case ABILITY_STRENGTH:
            eReturn = EffectSkillIncrease(SKILL_DISCIPLINE, iIncrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_JUMP, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_CLIMB, iIncrease));
            break;
        case ABILITY_DEXTERITY:
            eReturn = EffectSkillIncrease(SKILL_HIDE, iIncrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_MOVE_SILENTLY, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_OPEN_LOCK, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_SET_TRAP, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_TUMBLE, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_RIDE, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_BALANCE, iIncrease));
            break;
        case ABILITY_CONSTITUTION:
            eReturn = EffectSkillIncrease(SKILL_CONCENTRATION, iIncrease);
            break;
        case ABILITY_INTELLIGENCE:
            eReturn = EffectSkillIncrease(SKILL_DISABLE_TRAP, iIncrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_LORE, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_SEARCH, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_SPELLCRAFT, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_APPRAISE, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_CRAFT_TRAP, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_CRAFT_ARMOR, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_CRAFT_WEAPON, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_TRUESPEAK, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_MARTIAL_LORE, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_CRAFT_ALCHEMY, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_CRAFT_POISON, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_PSICRAFT, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_CRAFT_GENERAL, iIncrease));
            break;
        case ABILITY_WISDOM:
            eReturn = EffectSkillIncrease(SKILL_HEAL, iIncrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_LISTEN, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_SPOT, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_SENSE_MOTIVE, iIncrease));
            break;
        case ABILITY_CHARISMA:
            eReturn = EffectSkillIncrease(SKILL_ANIMAL_EMPATHY, iIncrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_PERFORM, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_PERSUADE, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_USE_MAGIC_DEVICE, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_BLUFF, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_INTIMIDATE, iIncrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillIncrease(SKILL_IAIJUTSU_FOCUS, iIncrease));
            break;
    }
    return eReturn;
}

effect EffectAbilityBasedSkillDecrease(int iAbility, int iDecrease = 1)
{
    effect eReturn;
    switch(iAbility)
    {
        case ABILITY_STRENGTH:
            eReturn = EffectSkillDecrease(SKILL_DISCIPLINE, iDecrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_JUMP, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_CLIMB, iDecrease));
            break;
        case ABILITY_DEXTERITY:
            eReturn = EffectSkillIncrease(SKILL_HIDE, iDecrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_MOVE_SILENTLY, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_OPEN_LOCK, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_SET_TRAP, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_TUMBLE, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_RIDE, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_BALANCE, iDecrease));
            break;
        case ABILITY_CONSTITUTION:
            eReturn = EffectSkillDecrease(SKILL_CONCENTRATION, iDecrease);
            break;
        case ABILITY_INTELLIGENCE:
            eReturn = EffectSkillDecrease(SKILL_DISABLE_TRAP, iDecrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_LORE, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_SEARCH, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_SPELLCRAFT, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_APPRAISE, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_CRAFT_TRAP, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_CRAFT_ARMOR, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_CRAFT_WEAPON, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_TRUESPEAK, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_MARTIAL_LORE, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_CRAFT_ALCHEMY, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_CRAFT_POISON, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_PSICRAFT, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_CRAFT_GENERAL, iDecrease));
            break;
        case ABILITY_WISDOM:
            eReturn = EffectSkillDecrease(SKILL_HEAL, iDecrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_LISTEN, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_SPOT, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_SENSE_MOTIVE, iDecrease));
            break;
        case ABILITY_CHARISMA:
            eReturn = EffectSkillDecrease(SKILL_ANIMAL_EMPATHY, iDecrease);
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_PERFORM, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_PERSUADE, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_USE_MAGIC_DEVICE, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_BLUFF, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_INTIMIDATE, iDecrease));
            eReturn = EffectLinkEffects(eReturn, EffectSkillDecrease(SKILL_IAIJUTSU_FOCUS, iDecrease));
            break;
    }
    return eReturn;
}

effect EffectDamageImmunityAll()
{
    effect eReturn = EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, 100);
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_BLUDGEONING, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_DIVINE, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_ELECTRICAL, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_MAGICAL, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_PIERCING, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_POSITIVE, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_SLASHING, 100));
           eReturn = EffectLinkEffects(eReturn, EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, 100));
           eReturn = TagEffect(eReturn, "PRCDamageImmunityAll");
    return eReturn;
}

effect EffectImmunityMiscAll()
{
    effect eReturn = EffectImmunity(IMMUNITY_TYPE_ABILITY_DECREASE);
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_BLINDNESS));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_DEAFNESS));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_CRITICAL_HIT));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_DEATH));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_DISEASE));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_ENTANGLE));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_SLOW));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_NEGATIVE_LEVEL));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_PARALYSIS));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_SILENCE));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_SNEAK_ATTACK));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_TRAP));
           eReturn = EffectLinkEffects(eReturn, EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS));
           eReturn = TagEffect(eReturn, "PRCImmunityMiscAll");
    return eReturn;
}

//:: Immunity to all gaze attacks
effect EffectGazeImmune()
{

    effect eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_CHARM);	
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_CONFUSION);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_DAZE);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_DEATH);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_DESTROY_CHAOS);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_DESTROY_EVIL);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_DESTROY_GOOD);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_DESTROY_LAW);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_DOMINATE);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_DOOM);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_FEAR);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_PARALYSIS);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_PETRIFY);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_STUNNED);
			
			eReturn = TagEffect(eReturn, "PRCGazeImmune");
			
    return eReturn;
}

//:: Immunity to all perification attacks
effect EffectPetrificationImmune()
{
    effect eReturn = EffectSpellImmunity(SPELLABILITY_TOUCH_PETRIFY);	
			eReturn = EffectSpellImmunity(SPELLABILITY_BREATH_PETRIFY);
			eReturn = EffectSpellImmunity(SPELL_FLESH_TO_STONE);
			eReturn = EffectSpellImmunity(SPELL_STONEHOLD);
			eReturn = EffectSpellImmunity(SPELL_EPIC_A_STONE);
			eReturn = EffectSpellImmunity(POWER_CRYSTALLIZE);
			eReturn = EffectSpellImmunity(MELD_BASILISK_MASK);
			eReturn = EffectSpellImmunity(SPELLABILITY_GAZE_PETRIFY);
			
			eReturn = TagEffect(eReturn, "PRCPetrificationImmune");
			
    return eReturn;
}

int GetIsShaken(object oTarget)
{
    effect eEffect = GetFirstEffect(oTarget);

    string sTag;

    while (GetIsEffectValid(eEffect))
    {
        sTag = GetEffectTag(eEffect);
        
        if (sTag == "PRCShaken") return TRUE;

        eEffect = GetNextEffect(oTarget);
    }
    return FALSE;
}

// Forward declarations for size change effects  
// Implementations are in prc_inc_size  
effect EffectSizeChange(object oTarget, int nObjectType, int bEnlarge, int nChanges);  
void DelayedSetVisualTransform(int nExpectedGeneration, object oTarget, int nTransform, float fValue);  
void DelaySetVisualTransform(float fDelay, object oTarget, string sGenerationName, int nTransform, float fValue);

//:: Test void
//::void main(){}