//::///////////////////////////////////////////////
//:: Truenaming include: Misceallenous
//:: true_inc_trufunc
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to the truenaming implementation.

    Also acts as inclusion nexus for the general
    truenaming includes. In other words, don't include
    them directly in your scripts, instead include this.

    @author Stratovarius
    @date   Created - 2006.7.18
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//:: Updated for .35 by Jaysyn 2023/03/11

//:: Test Void
//void main (){}

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines from what class's Utterance list the currently being truespoken
 * Utterance is truespoken from.
 *
 * @param oTrueSpeaker A creature uttering a Utterance at this moment
 * @return            CLASS_TYPE_* constant of the class
 */
int GetTruespeakingClass(object oTrueSpeaker = OBJECT_SELF);

/**
 * Determines the given creature's truespeaker level. If a class is specified,
 * then returns the truespeaker level for that class. Otherwise, returns
 * the truespeaker level for the currently active utterance.
 *
 * @param oTrueSpeaker   The creature whose truespeaker level to determine
 * @param nSpecificClass The class to determine the creature's truespeaker
 *                       level in.
 * @param nUseHD         If this is set, it returns the Character Level of the calling creature.
 *                       DEFAULT: CLASS_TYPE_INVALID, which means the creature's
 *                       truespeaker level in regards to an ongoing utterance
 *                       is determined instead.
 * @return               The truespeaker level
 */
int GetTruespeakerLevel(object oTrueSpeaker, int nSpecificClass = CLASS_TYPE_INVALID, int nUseHD = FALSE);

/**
 * Determines whether a given creature uses truenaming.
 * Requires either levels in a truenaming-related class or
 * natural truenaming ability based on race.
 *
 * @param oCreature Creature to test
 * @return          TRUE if the creature can use truenames, FALSE otherwise.
 */
int GetIsTruenamingUser(object oCreature);

/**
 * Determines the given creature's highest undmodified truespeaker level among it's
 * uttering classes.
 *
 * @param oCreature Creature whose highest truespeaker level to determine
 * @return          The highest unmodified truespeaker level the creature can have
 */
int GetHighestTrueSpeakerLevel(object oCreature);

/**
 * Determines whether a given class is a truenaming-related class or not.
 *
 * @param nClass CLASS_TYPE_* of the class to test
 * @return       TRUE if the class is a truenaming-related class, FALSE otherwise
 */
int GetIsTruenamingClass(int nClass);

/**
 * Gets the level of the Utterance being currently truespoken.
 * WARNING: Return value is not defined when a Utterance is not being truespoken.
 *
 * @param oTrueSpeaker The creature currently uttering a utterance
 * @return            The level of the Utterance being truespoken
 */
int GetUtteranceLevel(object oTrueSpeaker);

/**
 * Determines a creature's ability score in the uttering ability of a given
 * class.
 *
 * @param oTrueSpeaker Creature whose ability score to get
 * @param nClass      CLASS_TYPE_* constant of a uttering class
 */
int GetTruenameAbilityScoreOfClass(object oTrueSpeaker, int nClass);

/**
 * Determines the uttering ability of a class.
 *
 * @param nClass CLASS_TYPE_* constant of the class to determine the uttering stat of
 * @return       ABILITY_* of the uttering stat. ABILITY_CHARISMA for non-TrueSpeaker
 *               classes.
 */
int GetTruenameAbilityOfClass(int nClass);

/**
 * Calculates the DC of the Utterance being currently truespoken.
 * Base value is 10 + Utterance level + ability modifier in uttering stat
 *
 * WARNING: Return value is not defined when a Utterance is not being truespoken.
 *
 */
int GetTrueSpeakerDC(object oTrueSpeaker = OBJECT_SELF);

/**
 * Determines the truespeaker's level in regards to truespeaker checks to overcome
 * spell resistance.
 *
 * WARNING: Return value is not defined when a Utterance is not being truespoken.
 *
 * @param oTrueSpeaker A creature uttering a Utterance at the moment
 * @return            The creature's truespeaker level, adjusted to account for
 *                    modifiers that affect spell resistance checks.
 */
int GetTrueSpeakPenetration(object oTrueSpeaker = OBJECT_SELF);

/**
 * Marks an utterance as active for the Law of Sequence.
 * Called from the Utterance
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param nSpellId        SpellId of the Utterance
 * @param fDur            Duration of the Utterance
 */
void DoLawOfSequence(object oTrueSpeaker, int nSpellId, float fDur);

/**
 * Checks to see whether the law of sequence is active
 * Utterance fails if it is.
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param nSpellId        SpellId of the Utterance
 *
 * @return True if the Utterance is active, False if it is not.
 */
int CheckLawOfSequence(object oTrueSpeaker, int nSpellId);

/**
 * Returns the name of the Utterance
 *
 * @param nSpellId        SpellId of the Utterance
 */
string GetUtteranceName(int nSpellId);

/**
 * Returns the name of the Lexicon
 *
 * @param nLexicon        LEXICON_* to name
 */
string GetLexiconName(int nLexicon);

/**
 * Returns the Lexicon the Utterance is in
 * @param nSpellId   Utterance to check
 *
 * @return           LEXICON_*
 */
int GetLexiconByUtterance(int nSpellId);

/**
 * Affects all of the creatures with Speak Unto the Masses
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param oTarget   Original Target of Utterance
 * @param utter     The utterance structure returned by EvaluateUtterance
 */
void DoSpeakUntoTheMasses(object oTrueSpeaker, object oTarget, struct utterance utter);

/**
 * Affects all of the creatures with Speak Unto the Masses
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param oTarget         Original Target of Utterance
 * @param utter           The utterance structure returned by EvaluateUtterance
 */
void DoWordOfNurturingReverse(object oTrueSpeaker, object oTarget, struct utterance utter);

/**
 * Affects all of the creatures with Speak Unto the Masses
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param oTarget         Original Target of Utterance
 * @param utter           The utterance structure returned by EvaluateUtterance
 * @param nBeats          Number of rounds to fire this utterance
 * @param nDamageType     DAMAGE_TYPE_*
 */
void DoEnergyNegation(object oTrueSpeaker, object oTarget, struct utterance utter, int nBeats, int nDamageType);

/**
 * Checks to see if the chosen target of the Crafted Tool utterance is valid.
 * If it is not valid, it will search through all slots, starting with right hand weapon
 * to try and find a valid target.
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param oTarget         Target of the utterance
 *
 * @return                Item in slot, or, if there are no valid objects on the creature, OBJECT_INVALID.
 *                        If the target is an item, it returns the item.
 */
object CraftedToolTarget(object oTrueSpeaker, object oTarget);

/**
 * Enforces the cross class cap on the Truespeech skill
 *
 * @param oTrueSpeaker  The PC whose feats to check.
 * @return              TRUE if needed to relevel, FALSE otherwise.
 */
int CheckTrueSpeechSkill(object oTrueSpeaker);

/**
 * Applies modifications to a utterance's damage that depend on some property
 * of the target.
 * Currently accounts for:
 *  - Mental Resistance
 *  - Greater Utterance Specialization
 *  - Intellect Fortress
 *
 * @param oTarget     A creature being dealt damage by a utterance
 * @param oTrueSpeaker The creature uttering the damaging utterance
 * @param nDamage     The amount of damage the creature would be dealt
 *
 * @param bIsHitPointDamage Is the damage HP damage or something else?
 * @param bIsEnergyDamage   Is the damage caused by energy or something else? Only relevant if the damage is HP damage.
 *
 * @return The amount of damage, modified by oTarget's abilities
 */
/*int GetTargetSpecificChangesToDamage(object oTarget, object oTrueSpeaker, int nDamage,
                                     int bIsHitPointDamage = TRUE, int bIsEnergyDamage = FALSE);

*/

/**
 * Returns how many Cadence feats an Acolyte of the Ego has
 *
 * @param oTrueSpeaker  The PC whose feats to check.
 * @return              The count of feats
 */
int GetCadenceCount(object oTrueSpeaker);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_alterations"
#include "true_inc_utter"
#include "true_inc_truknwn"
#include "true_inc_truespk"

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetTruespeakingClass(object oTrueSpeaker = OBJECT_SELF)
{
    return GetLocalInt(oTrueSpeaker, PRC_TRUESPEAKING_CLASS) - 1;
}

int GetTruespeakerLevel(object oTrueSpeaker, int nSpecificClass = CLASS_TYPE_INVALID, int nUseHD = FALSE)
{
    int nLevel;
    int nAdjust = GetLocalInt(oTrueSpeaker, PRC_CASTERLEVEL_ADJUSTMENT);
    // Bereft's speak syllables and use their character level.
    if (GetIsSyllable(PRCGetSpellId())) nUseHD = TRUE;

    // If this is set, return the user's HD
    if (nUseHD) return GetHitDice(oTrueSpeaker);

    // The function user needs to know the character's truespeaker level in a specific class
    // instead of whatever the character last truespoken a Utterance as
    if(nSpecificClass != CLASS_TYPE_INVALID)
    {
        if(GetIsTruenamingClass(nSpecificClass))
        {
            int nClassLevel = GetLevelByClass(nSpecificClass, oTrueSpeaker);
            if (nClassLevel > 0)
            {
            	nLevel = nClassLevel;
            }
        }
        // A character's truespeaker level gained from non-uttering classes is always a nice, round zero
        else
            return 0;
    }

    // Item Spells
    if(GetItemPossessor(GetSpellCastItem()) == oTrueSpeaker)
    {
        if(DEBUG) SendMessageToPC(oTrueSpeaker, "Item casting at level " + IntToString(GetCasterLevel(oTrueSpeaker)));

        return GetCasterLevel(oTrueSpeaker) + nAdjust;
    }

    // For when you want to assign the caster level.
    else if(GetLocalInt(oTrueSpeaker, PRC_CASTERLEVEL_OVERRIDE) != 0)
    {
        if(DEBUG) SendMessageToPC(oTrueSpeaker, "Forced-level uttering at level " + IntToString(GetCasterLevel(oTrueSpeaker)));

        DelayCommand(1.0, DeleteLocalInt(oTrueSpeaker, PRC_CASTERLEVEL_OVERRIDE));
        nLevel = GetLocalInt(oTrueSpeaker, PRC_CASTERLEVEL_OVERRIDE);
    }
    else if(GetTruespeakingClass(oTrueSpeaker) != CLASS_TYPE_INVALID)
    {
        //Gets the level of the uttering class
        int nUtteringClass = GetTruespeakingClass(oTrueSpeaker);
        nLevel = GetLevelByClass(nUtteringClass, oTrueSpeaker);
    }

    // If everything else fails, use the character's first class position
    if(nLevel == 0)
    {
        if(DEBUG)             DoDebug("Failed to get truespeaker level for creature " + DebugObject2Str(oTrueSpeaker) + ", using first class slot");
        else WriteTimestampedLogEntry("Failed to get truespeaker level for creature " + DebugObject2Str(oTrueSpeaker) + ", using first class slot");

        nLevel = GetLevelByPosition(1, oTrueSpeaker);
    }

    nLevel += nAdjust;

    // This spam is technically no longer necessary once the truespeaker level getting mechanism has been confirmed to work
//    if(DEBUG) FloatingTextStringOnCreature("TrueSpeaker Level: " + IntToString(nLevel), oTrueSpeaker, FALSE);

    return nLevel;
}

int GetIsTruenamingUser(object oCreature)
{
    return !!(GetLevelByClass(CLASS_TYPE_TRUENAMER, oCreature) ||
              GetLevelByClass(CLASS_TYPE_BEREFT,    oCreature)
             );
}

int GetHighestTrueSpeakerLevel(object oCreature)
{
	int n = 0;
	int nHighest;
	int nTemp;
	
    while(n <= 8)
	{
		if(GetClassByPosition(n, oCreature) != CLASS_TYPE_INVALID)
		{
			nTemp = GetTruespeakerLevel(oCreature, GetClassByPosition(n, oCreature));
			
			if(nTemp > nHighest) 
				nHighest = nTemp;
		}
	n++;

	}
	
	return nHighest;
}

/* int GetHighestTrueSpeakerLevel(object oCreature)
{
    return PRCMax(PRCMax(GetClassByPosition(1, oCreature) != CLASS_TYPE_INVALID ? GetTruespeakerLevel(oCreature, GetClassByPosition(1, oCreature)) : 0,
                   GetClassByPosition(2, oCreature) != CLASS_TYPE_INVALID ? GetTruespeakerLevel(oCreature, GetClassByPosition(2, oCreature)) : 0
                   ),
               GetClassByPosition(3, oCreature) != CLASS_TYPE_INVALID ? GetTruespeakerLevel(oCreature, GetClassByPosition(3, oCreature)) : 0
               );
} */

int GetIsTruenamingClass(int nClass)
{
    return (nClass == CLASS_TYPE_TRUENAMER ||
            nClass == CLASS_TYPE_BEREFT
            );
}

int GetUtteranceLevel(object oTrueSpeaker)
{
    return GetLocalInt(oTrueSpeaker, PRC_UTTERANCE_LEVEL);
}

int GetTruenameAbilityScoreOfClass(object oTrueSpeaker, int nClass)
{
    return GetAbilityScore(oTrueSpeaker, GetTruenameAbilityOfClass(nClass));
}

int GetTruenameAbilityOfClass(int nClass){
    switch(nClass)
    {
        case CLASS_TYPE_TRUENAMER:
            return ABILITY_CHARISMA;
        default:
            return ABILITY_CHARISMA;
    }

    // Technically, never gets here but the compiler does not realise that
    return -1;
}

int GetTrueSpeakerDC(object oTrueSpeaker = OBJECT_SELF)
{
    // Things we need for DC Checks
    int nSpellId = PRCGetSpellId();
    object oTarget = PRCGetSpellTargetObject();
    int nRace = MyPRCGetRacialType(oTarget);
    // DC is 10 + 1/2 Truenamer level + Ability (Charisma)
    int nClass = GetTruespeakingClass(oTrueSpeaker);
    int nDC = 10;
    nDC += GetLevelByClass(nClass, oTrueSpeaker) / 2;
    nDC += GetAbilityModifier(GetTruenameAbilityOfClass(nClass), oTrueSpeaker);
    int nFeat = -1;

    // Focused Lexicon. Bonus vs chosen racial type  //:: [PRC .35] Needs update for new racialtypes
    switch(nRace)
    {
        case RACIAL_TYPE_ABERRATION:         nFeat = FEAT_FOCUSED_LEXICON_ABERRATION;   break;
        case RACIAL_TYPE_ANIMAL:             nFeat = FEAT_FOCUSED_LEXICON_ANIMAL;       break;
        case RACIAL_TYPE_BEAST:              nFeat = FEAT_FOCUSED_LEXICON_BEAST;        break;
        case RACIAL_TYPE_CONSTRUCT:          nFeat = FEAT_FOCUSED_LEXICON_CONSTRUCT;    break;
        case RACIAL_TYPE_DRAGON:             nFeat = FEAT_FOCUSED_LEXICON_DRAGON;       break;
        case RACIAL_TYPE_DWARF:              nFeat = FEAT_FOCUSED_LEXICON_DWARF;        break;
        case RACIAL_TYPE_ELEMENTAL:          nFeat = FEAT_FOCUSED_LEXICON_ELEMENTAL;    break;
        case RACIAL_TYPE_ELF:                nFeat = FEAT_FOCUSED_LEXICON_ELF;          break;
        case RACIAL_TYPE_FEY:                nFeat = FEAT_FOCUSED_LEXICON_FEY;          break;
        case RACIAL_TYPE_GIANT:              nFeat = FEAT_FOCUSED_LEXICON_GIANT;        break;
        case RACIAL_TYPE_GNOME:              nFeat = FEAT_FOCUSED_LEXICON_GNOME;        break;
        case RACIAL_TYPE_HALFELF:            nFeat = FEAT_FOCUSED_LEXICON_HALFELF;      break;
        case RACIAL_TYPE_HALFLING:           nFeat = FEAT_FOCUSED_LEXICON_HALFLING;     break;
        case RACIAL_TYPE_HALFORC:            nFeat = FEAT_FOCUSED_LEXICON_HALFORC;      break;
        case RACIAL_TYPE_HUMAN:              nFeat = FEAT_FOCUSED_LEXICON_HUMAN;        break;
        case RACIAL_TYPE_HUMANOID_GOBLINOID: nFeat = FEAT_FOCUSED_LEXICON_GOBLINOID;    break;
        case RACIAL_TYPE_HUMANOID_MONSTROUS: nFeat = FEAT_FOCUSED_LEXICON_MONSTROUS;    break;
        case RACIAL_TYPE_HUMANOID_ORC:       nFeat = FEAT_FOCUSED_LEXICON_ORC;          break;
        case RACIAL_TYPE_HUMANOID_REPTILIAN: nFeat = FEAT_FOCUSED_LEXICON_REPTILIAN;    break;
        case RACIAL_TYPE_MAGICAL_BEAST:      nFeat = FEAT_FOCUSED_LEXICON_MAGICALBEAST; break;
        case RACIAL_TYPE_OOZE:               nFeat = FEAT_FOCUSED_LEXICON_OOZE;         break;
        case RACIAL_TYPE_OUTSIDER:           nFeat = FEAT_FOCUSED_LEXICON_OUTSIDER;     break;
        case RACIAL_TYPE_SHAPECHANGER:       nFeat = FEAT_FOCUSED_LEXICON_SHAPECHANGER; break;
        case RACIAL_TYPE_UNDEAD:             nFeat = FEAT_FOCUSED_LEXICON_UNDEAD;       break;
        case RACIAL_TYPE_VERMIN:             nFeat = FEAT_FOCUSED_LEXICON_VERMIN;       break;
    }
    if(nFeat > -1 && GetHasFeat(nFeat, oTrueSpeaker))
    {
        nDC += 1;
        nFeat = -1;
    }

    // Utterance Focus. DC Bonus for a chosen utterance
    switch(nSpellId)
    {
        case UTTER_BREATH_CLEANSING_R:      nFeat = FEAT_UTTERANCE_FOCUS_BREATH_CLEANSING;      break;
        case UTTER_BREATH_RECOVERY_R:       nFeat = FEAT_UTTERANCE_FOCUS_BREATH_RECOVERY;       break;
        case UTTER_ELDRITCH_ATTRACTION:     nFeat = FEAT_UTTERANCE_FOCUS_ELDRITCH_ATTRACTION;   break;
        case UTTER_ELDRITCH_ATTRACTION_R:   nFeat = FEAT_UTTERANCE_FOCUS_ELDRITCH_ATTRACTION;   break;
        case UTTER_MORALE_BOOST_R:          nFeat = FEAT_UTTERANCE_FOCUS_MORALE_BOOST;          break;
        case UTTER_PRETERNATURAL_CLARITY_R: nFeat = FEAT_UTTERANCE_FOCUS_PRETERNATURAL_CLARITY; break;
        case UTTER_SENSORY_FOCUS_R:         nFeat = FEAT_UTTERANCE_FOCUS_SENSORY_FOCUS;         break;
        case UTTER_SILENT_CASTER_R:         nFeat = FEAT_UTTERANCE_FOCUS_SILENT_CASTER;         break;
        case UTTER_SINGULAR_MIND_R:         nFeat = FEAT_UTTERANCE_FOCUS_SINGULAR_MIND;         break;
        case UTTER_TEMPORAL_SPIRAL_R:       nFeat = FEAT_UTTERANCE_FOCUS_TEMPORAL_SPIRAL;       break;
        case UTTER_TEMPORAL_TWIST_R:        nFeat = FEAT_UTTERANCE_FOCUS_TEMPORAL_TWIST;        break;
        case UTTER_WARD_PEACE_R:            nFeat = FEAT_UTTERANCE_FOCUS_WARD_PEACE;            break;
        case UTTER_SHOCKWAVE:               nFeat = FEAT_UTTERANCE_FOCUS_SHOCKWAVE;             break;
    }
    if(nFeat > -1 && GetHasFeat(nFeat, oTrueSpeaker))
        nDC += 1;

    return nDC;
}

int GetTrueSpeakPenetration(object oTrueSpeaker = OBJECT_SELF)
{
    int nPen = GetTruespeakerLevel(oTrueSpeaker);

    // According to Page 232 of Tome of Magic, Spell Pen as a feat counts, so here it is.
    if(GetHasFeat(FEAT_EPIC_SPELL_PENETRATION, oTrueSpeaker)) nPen += 6;
    else if(GetHasFeat(FEAT_GREATER_SPELL_PENETRATION, oTrueSpeaker)) nPen += 4;
    else if(GetHasFeat(FEAT_SPELL_PENETRATION, oTrueSpeaker)) nPen += 2;

    // Blow away SR totally, just add 9000
    // Does not work on Syllables, only utterances
    if (GetLocalInt(oTrueSpeaker, TRUE_IGNORE_SR) && !GetIsSyllable(PRCGetSpellId())) nPen += 9000;

    if(DEBUG) DoDebug("GetTrueSpeakPenetration(" + GetName(oTrueSpeaker) + "): " + IntToString(nPen));

    return nPen;
}

void DoLawOfSequence(object oTrueSpeaker, int nSpellId, float fDur)
{
    // This makes sure everything is stored using the Normal, and not the reverse
    string sSpellId = GetNormalUtterSpellId(nSpellId);
    SetLocalInt(oTrueSpeaker, LAW_OF_SEQUENCE_VARNAME + sSpellId, TRUE);
    DelayCommand(fDur, DeleteLocalInt(oTrueSpeaker, LAW_OF_SEQUENCE_VARNAME + sSpellId));
}

int CheckLawOfSequence(object oTrueSpeaker, int nSpellId)
{
	// Turns this off
	if (GetPRCSwitch(PRC_LAW_OF_SEQUENCE)) return FALSE;
    // This makes sure everything is stored using the Normal, and not the reverse
    return GetLocalInt(oTrueSpeaker, LAW_OF_SEQUENCE_VARNAME + GetNormalUtterSpellId(nSpellId));
}

string GetUtteranceName(int nSpellId)
{
    return GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId)));
}

string GetLexiconName(int nLexicon)
{
    int nStrRef;
    switch(nLexicon)
    {
        case LEXICON_EVOLVING_MIND: nStrRef = 16828478; break;
        case LEXICON_CRAFTED_TOOL:  nStrRef = 16828479; break;
        case LEXICON_PERFECTED_MAP: nStrRef = 16828480; break;
    }

    return GetStringByStrRef(nStrRef);
}

int GetLexiconByUtterance(int nSpellId)
{
     int i, nUtter;
     for(i = 0; i < GetPRCSwitch(FILE_END_CLASS_POWER) ; i++)
     {
         nUtter = StringToInt(Get2DACache("cls_true_utter", "SpellID", i));
         if(nUtter == nSpellId)
         {
             return StringToInt(Get2DACache("cls_true_utter", "Lexicon", i));
         }
     }
     // This should never happen
     return -1;
}

void DoSpeakUntoTheMasses(object oTrueSpeaker, object oTarget, struct utterance utter)
{
	// Check for Speak Unto the Masses, exit function if not set
	if (!GetLocalInt(oTrueSpeaker, TRUE_SPEAK_UNTO_MASSES)) return;

	// Speak to the Masses affects all creatures of the same race in the AoE
	int nRacial = MyPRCGetRacialType(oTarget);
	object oSkin;

	// Loop over targets
        object oAreaTarget = MyFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(30.0), GetLocation(oTarget), TRUE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oAreaTarget))
        {
        	if(DEBUG) DoDebug("Speak Unto the Masses: While entered");
            // Skip the original target/truespeaker, its already been hit
            if (oAreaTarget != oTarget && oAreaTarget != oTrueSpeaker)
            {
		if(DEBUG) DoDebug("Speak Unto the Masses: Target check");
                // Targeting limitations
                if(MyPRCGetRacialType(oAreaTarget) == nRacial)
                {
                	if(DEBUG) DoDebug("Speak Unto the Masses: Racial Check");
                    // Only affect friends or ignore it
                    if (GetIsFriend(oAreaTarget, oTrueSpeaker) || !utter.bFriend)
                    {
                    if(DEBUG) DoDebug("Speak Unto the Masses: Friend Check");
                        // Do SR, or ignore if its a friendly utterance.
                    if (!PRCDoResistSpell(utter.oTrueSpeaker, oAreaTarget, utter.nPen) || utter.bIgnoreSR)
                    {
                    if(DEBUG) DoDebug("Speak Unto the Masses: SR Check");
                        // Saving throw, ignore it if there is no DC to check
                        if(!PRCMySavingThrow(utter.nSaveThrow, oAreaTarget, utter.nSaveDC, utter.nSaveType, OBJECT_SELF) ||
                           utter.nSaveDC == 0)
                            {
                            if(DEBUG) DoDebug("Speak Unto the Masses: Saving Throw");
                                // Itemproperty, if there is one
                                oSkin = GetPCSkin(oAreaTarget);
                                if (GetIsItemPropertyValid(utter.ipIProp1))
                                {
                                	if(DEBUG) DoDebug("Speak Unto the Masses: IProp1");
                                    IPSafeAddItemProperty(oSkin, utter.ipIProp1, utter.fDur, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
                                }
                                // Itemproperty, if there is one
                                if (GetIsItemPropertyValid(utter.ipIProp2))
                                {
                                if(DEBUG) DoDebug("Speak Unto the Masses: IProp2");
                                    IPSafeAddItemProperty(oSkin, utter.ipIProp2, utter.fDur, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
                                }
                                // Itemproperty, if there is one
                                if (GetIsItemPropertyValid(utter.ipIProp3))
                                {
                                if(DEBUG) DoDebug("Speak Unto the Masses: IProp3");
                                    IPSafeAddItemProperty(oSkin, utter.ipIProp3, utter.fDur, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
                                }
                                        // Duration Effects
                                SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, utter.eLink, oAreaTarget, utter.fDur, TRUE, utter.nSpellId, utter.nTruespeakerLevel);
                                if(DEBUG) DoDebug("Speak Unto the Masses: Duration");
                                // Impact Effects
                            SPApplyEffectToObject(DURATION_TYPE_INSTANT, utter.eLink2, oAreaTarget);
                            if(DEBUG) DoDebug("Speak Unto the Masses: Instant");
                            // Utterance Specific code down here
                            DoWordOfNurturingReverse(oTrueSpeaker, oAreaTarget, utter);
                            if(DEBUG) DoDebug("Speak Unto the Masses: Word of Nurturing Reverse");
                            if (utter.nSpellId == UTTER_ENERGY_NEGATION_R)
                                DoEnergyNegation(oTrueSpeaker, oTarget, utter, FloatToInt(utter.fDur / 6.0), GetLocalInt(oTrueSpeaker, "TrueEnergyNegation"));
                        } // end if - Saving Throw
                    } // end if - Spell Resistance
                } // end if - Friend Check
                }// end if - Targeting check
            }

            // Get next target
            oAreaTarget = MyNextObjectInShape(SHAPE_SPHERE, FeetToMeters(30.0), GetLocation(oTarget), TRUE, OBJECT_TYPE_CREATURE);
	}// end while - Target loop
}

void DoWordOfNurturingReverse(object oTrueSpeaker, object oTarget, struct utterance utter)
{
	// Returns TRUE upon concentration failure
	if (GetBreakConcentrationCheck(oTrueSpeaker)) return;

	int nDamage;
	// First, find out what utterance we're using
	if (utter.nSpellId == UTTER_WORD_NURTURING_MINOR_R)    nDamage = d6();
	else if (utter.nSpellId == UTTER_WORD_NURTURING_LESSER_R)   nDamage = d6(2);
	else if (utter.nSpellId == UTTER_WORD_NURTURING_MODERATE_R) nDamage = d6(4);
	else if (utter.nSpellId == UTTER_WORD_NURTURING_POTENT_R)   nDamage = d6(6);
	else if (utter.nSpellId == UTTER_WORD_NURTURING_CRITICAL_R) nDamage = d6(8);
	else if (utter.nSpellId == UTTER_WORD_NURTURING_GREATER_R)  nDamage = d6(10);
	// Empower it
	if(utter.bEmpower) nDamage += (nDamage/2);
	// If we're using this, target has already failed SR and Saves
	effect eImp = EffectLinkEffects(EffectVisualEffect(VFX_IMP_MAGLAW), EffectDamage(nDamage));
	SPApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, oTarget);
}

void DoEnergyNegation(object oTrueSpeaker, object oTarget, struct utterance utter, int nBeats, int nDamageType)
{
	int nDamage = d6(2);
	// Empower it
	if(utter.bEmpower) nDamage += (nDamage/2);
       	// Impact VFX
        utter.eLink2 = EffectLinkEffects(EffectVisualEffect(VFX_IMP_MAGVIO), EffectDamage(nDamage, nDamageType));
        // Impact Effects
        SPApplyEffectToObject(DURATION_TYPE_INSTANT, utter.eLink2, oTarget);

        nBeats -= 1;
        if (nBeats > 0)
        	DelayCommand(6.0, DoEnergyNegation(oTrueSpeaker, oTarget, utter, nBeats, nDamageType));
}

object CraftedToolTarget(object oTrueSpeaker, object oTarget)
{
	// Check to see if its a weapon or item of some sort
	// Return it if its a valid base item type
	if (GetBaseItemType(oTarget) != BASE_ITEM_INVALID) return oTarget;

	object oItem = OBJECT_INVALID;

	// These are utterances that only target weapons
	if (PRCGetSpellId() == UTTER_KEEN_WEAPON || PRCGetSpellId() == UTTER_SUPPRESS_WEAPON || PRCGetSpellId() == UTTER_TRANSMUTE_WEAPON)
	{
		// By the time we're here, it should only be creatures, not items as targets
		oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
		// Only do this for Keen
		if (PRCGetSpellId() == UTTER_KEEN_WEAPON)
		{
			// Put the bonus on the ammo rather than the bow if its ranged
			if( GetBaseItemType(oItem) == BASE_ITEM_LONGBOW || GetBaseItemType(oItem) == BASE_ITEM_SHORTBOW )
			{
			     oItem = GetItemInSlot(INVENTORY_SLOT_ARROWS, oTarget);
			}
			else if(GetBaseItemType(oItem) == BASE_ITEM_LIGHTCROSSBOW || GetBaseItemType(oItem) == BASE_ITEM_HEAVYCROSSBOW)
			{
			     oItem = GetItemInSlot(INVENTORY_SLOT_BOLTS, oTarget);
			}
			else if(GetBaseItemType(oItem) == BASE_ITEM_SLING)
			{
			     oItem = GetItemInSlot(INVENTORY_SLOT_BULLETS, oTarget);
      			}
      		}
		// If its a valid weapon, return it
		if (GetBaseItemType(oItem) != BASE_ITEM_INVALID) return oItem;
		// Check the spare hand, and make sure its not a shield
		oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
		// If its a valid weapon and not a shield, return it
		if (GetBaseItemType(oItem) != BASE_ITEM_INVALID     &&
		    GetBaseItemType(oItem) != BASE_ITEM_LARGESHIELD &&
                    GetBaseItemType(oItem) != BASE_ITEM_SMALLSHIELD &&
                    GetBaseItemType(oItem) != BASE_ITEM_TOWERSHIELD) return oItem;
	}// These ones target only armour
	else if (PRCGetSpellId() == UTTER_FORTIFY_ARMOUR_SNEAK || PRCGetSpellId() == UTTER_FORTIFY_ARMOUR_CRIT)
	{
		return GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
	}// This one targets scrolls and potions
	else if (PRCGetSpellId() == UTTER_METAMAGIC_CATALYST_EMP || PRCGetSpellId() == UTTER_METAMAGIC_CATALYST_EXT ||
	         PRCGetSpellId() == UTTER_METAMAGIC_CATALYST_MAX)
	{
		oItem = GetFirstItemInInventory(oTarget);
		while(GetIsObjectValid(oItem))
		{
		        if (GetBaseItemType(oItem) == BASE_ITEM_SCROLL || GetBaseItemType(oItem) == BASE_ITEM_POTIONS)
		        {
		        	return oItem;
		        }
	        	oItem = GetNextItemInInventory(oTarget);
     		}
	}
	else // For the rest of the utterances, any item is a valid target.
	{
		// Get the PC's chosen inventory slot
		int nSlot = GetLocalInt(oTrueSpeaker, "TrueCraftedToolTargetSlot");
		oItem = GetItemInSlot(nSlot, oTarget);
		// If the chosen item isn't valid, we go into the choice progession
		// Yes, its a long chain
		if (!GetIsObjectValid(oItem))
		{
		    oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
		    if (!GetIsObjectValid(oItem))
		    {
		        oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
		        if (!GetIsObjectValid(oItem))
			{
			    oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
			    if (!GetIsObjectValid(oItem))
			    {
			        oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oTarget);
			        if (!GetIsObjectValid(oItem))
			        {
			            oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oTarget);
			            if (!GetIsObjectValid(oItem))
				    {
				        oItem = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oTarget);
				        if (!GetIsObjectValid(oItem))
			                {
			                    oItem = GetItemInSlot(INVENTORY_SLOT_NECK, oTarget);
			                    if (!GetIsObjectValid(oItem))
			    		    {
			    		        oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, oTarget);
			    		        if (!GetIsObjectValid(oItem))
						{
						    oItem = GetItemInSlot(INVENTORY_SLOT_ARMS, oTarget);
						    if (!GetIsObjectValid(oItem))
						    {
							oItem = GetItemInSlot(INVENTORY_SLOT_BOOTS, oTarget);
							if (!GetIsObjectValid(oItem))
							{
							    oItem = GetItemInSlot(INVENTORY_SLOT_BELT, oTarget);
		                                        }
		                                    }
		                               }
		                            }
		                        }
		                    }
		                }
		            }
		        }
		    }
		}
	}
	return oItem;
}

int CheckTrueSpeechSkill(object oTrueSpeaker)
{
    // The max for a class skill is 3 + 1 per level. We just divide this in half for Cross Class
    int nMax = GetHitDice(oTrueSpeaker) + 3;
    nMax /= 2;
    // We want base ranks only
    int nRanks = GetSkillRank(SKILL_TRUESPEAK, oTrueSpeaker, TRUE);

    // The Truenamer class has Truespeech as a class skill, so no relevel
    if (GetLevelByClass(CLASS_TYPE_TRUENAMER, oTrueSpeaker) > 0) return FALSE;
    // Same for this class
    else if (GetLevelByClass(CLASS_TYPE_BEREFT, oTrueSpeaker) > 0) return FALSE;
    // And this one
    else if (GetLevelByClass(CLASS_TYPE_BRIMSTONE_SPEAKER, oTrueSpeaker) > 0) return FALSE;
	// Factotums have every skill as a class skill.
	else if (GetLevelByClass(CLASS_TYPE_FACTOTUM, oTrueSpeaker) > 0) return FALSE;
    // If they have the feat, no relevel
    else if(GetHasFeat(FEAT_TRUENAME_TRAINING, oTrueSpeaker)) return FALSE;
    // Now we check the values. If they have too many ranks, relevel.
    else if (nRanks > nMax)
    {
        // Relevel
        FloatingTextStringOnCreature("You cannot have more than " + IntToString(nMax) + " in TrueSpeech.", oTrueSpeaker, FALSE);
        return TRUE;
    }

    // No relevel normally
    return FALSE;
}

/*
int GetTargetSpecificChangesToDamage(object oTarget, object oTrueSpeaker, int nDamage,
                                     int bIsHitPointDamage = TRUE, int bIsEnergyDamage = FALSE)
{
    // Greater Utterance Specialization - +2 damage on all HP-damaging utterances when target is within 30ft
    if(bIsHitPointDamage                                                &&
       GetHasFeat(FEAT_GREATER_Utterance_SPECIALIZATION, oTrueSpeaker)       &&
       GetDistanceBetween(oTarget, oTrueSpeaker) <= FeetToMeters(30.0f)
       )
            nDamage += 2;
    // Intellect Fortress - Halve damage dealt by utterances that allow PR. Goes before DR (-like) reductions
    if(GetLocalInt(oTarget, "PRC_Utterance_IntellectFortress_Active")    &&
       Get2DACache("spells", "ItemImmunity", PRCGetSpellId()) == "1"
       )
        nDamage /= 2;
    // Mental Resistance - 3 damage less for all non-energy damage and ability damage
    if(GetHasFeat(FEAT_MENTAL_RESISTANCE, oTarget) && !bIsEnergyDamage)
        nDamage -= 3;

    // Reasonable return values only
    if(nDamage < 0) nDamage = 0;

    return nDamage;
}
*/
// Test main
//void main(){}

int GetCadenceCount(object oTrueSpeaker)
{
    int nClass = GetLevelByClass(CLASS_TYPE_ACOLYTE_EGO, oTrueSpeaker);
    if (GetLocalInt(oTrueSpeaker, "ResonantVoice") == TRUE)
    {
	nClass += 3; //Adds 3 to class level
    }    
    
    int nCount = nClass/2; //Get a cadence feat at 2, 4, 6, 8, 10 levels.
    
    if (nCount > 6) nCount = 6; //Can't go above 6 with Resonant Voice active
    
    // Return total
    return nCount;
}