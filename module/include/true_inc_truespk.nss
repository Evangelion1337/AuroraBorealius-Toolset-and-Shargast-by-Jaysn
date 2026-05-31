//::///////////////////////////////////////////////
//:: Truenaming include: Truespeaking
//:: true_inc_truespk
//::///////////////////////////////////////////////
/** @file
    Defines functions for handling truespeaking.

    @author Stratovarius
    @date   Created - 2006.18.07
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Returns the base DC of an Utterance.
 * This is where the various formulas can be chosen by switch
 * Accounts for Speak Unto the Masses if used
 *
 * @param oTarget         Target of the Utterance
 * @param oTrueSpeaker    Caster of the Utterance
 * @param nLexicon        Type of the Utterance: Evolving Mind, Crafted Tool, or Perfected Map
 * @return                The base DC via formula to hit the target
 *                        This does not include MetaUtterances, increased DC to ignore SR, or the Laws.
 */
int GetBaseUtteranceDC(object oTarget, object oTrueSpeaker, int nLexicon);

/**
 * Returns the Law of Resistance DC increase
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param nSpellId        SpellId of the Utterance
 * @return                The DC boost for this particular power from the Law of Resistance
 */
int GetLawOfResistanceDCIncrease(object oTrueSpeaker, int nSpellId);

/**
 * Stores the Law Of Resistance DC increase
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param nSpellId        SpellId of the Utterance
 */
void DoLawOfResistanceDCIncrease(object oTrueSpeaker, int nSpellId);

/**
 * Deletes all of the Local Ints stored by the laws.
 * Called OnRest and OnEnter
 *
 * @param oTrueSpeaker    Caster of the Utterance
 */
void ClearLawLocalVars(object oTrueSpeaker);

/**
 * Returns the Personal Truename DC increase
 * Right now this accounts for targeting self
 * This also adds in the Acolyte of the Ego Alter Personal Truename
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @param oTarget         Target of the Utterance
 * @return                The DC boost for using a personal truename
 */
int AddPersonalTruenameDC(object oTrueSpeaker, object oTarget);

/**
 * Returns the DC increase if the TrueSpeaker ignores SR.
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @return                The DC boost for using this ability
 */
int AddIgnoreSpellResistDC(object oTrueSpeaker);

/**
 * Returns the DC increase from specific utterances
 *
 * @param oTrueSpeaker    Caster of the Utterance
 * @return                The DC boost for using this ability
 */
int AddUtteranceSpecificDC(object oTrueSpeaker);

/**
 * Returns the DC used for the Recitation feats
 * This is a simplified version of the GetBaseUtteranceDC function
 *
 * @param oTrueSpeaker    Caster/Target of the Recitation
 * @return                The DC to speak
 */
int GetRecitationDC(object oTrueSpeaker);

/*
 * Returns TRUE if it is a Syllable (Bereft class ability).
 * @param nSpellId   Utterance to check
 *
 * @return           TRUE or FALSE
 */
int GetIsSyllable(int nSpellId);

/*
 * Returns TRUE if the Truespeaker passes a Truespeak check to affect the target
 * @param nPersonal  Personal Truename DC or not
 *
 * @return           TRUE or FALSE
 */
int DoSpellTruenameCheck(object oTrueSpeaker, object oTarget, int nPersonal = FALSE);

string GetNormalUtterSpellId(int nSpellId);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_spells"
#include "true_inc_trufunc"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

int GetCraftedToolCR(object oItem)
{
    int nID=0;
    if (!GetIdentified(oItem))
    {
        nID=1;
        SetIdentified(oItem,TRUE);
    }
    int nGold = GetGoldPieceValue(oItem);
    // If none of the statements trigger, the base is 0 (i.e, non-magical)
    int nLore = 0;

    if (nGold>1001)    nLore= 1;
    if (nGold>2501)    nLore= 2;
    if (nGold>3751)    nLore= 3;
    if (nGold>4801)    nLore= 4;
    if (nGold>6501)    nLore= 5;
    if (nGold>9501)    nLore= 6;
    if (nGold>13001)   nLore= 7;
    if (nGold>17001)   nLore= 8;
    if (nGold>20001)   nLore= 9;
    if (nGold>30001)   nLore= 10;
    if (nGold>40001)   nLore= 11;
    if (nGold>50001)   nLore= 12;
    if (nGold>60001)   nLore= 13;
    if (nGold>80001)   nLore= 14;
    if (nGold>100001)  nLore= 15;
    if (nGold>150001)  nLore= 16;
    if (nGold>200001)  nLore= 17;
    if (nGold>250001)  nLore= 18;
    if (nGold>300001)  nLore= 19;
    if (nGold>350001)  nLore= 20;
    if (nGold>400001)  nLore= 21;
    if (nGold>500001)
    {
        nGold = nGold - 500000;
        nGold = nGold / 100000;
        nLore = nGold + 22;
    }
    if (nID) SetIdentified(oItem,FALSE);
    return nLore;
}

/**
 * Takes the REVERSE SpellId of an Utterance and returns the NORMAL
 * This is used for the Law of Resistance and the Law of Sequence so its always stored on the one SpellId
 *
 * @param nSpellId        SpellId of the Utterance
 * @return                string SpellId of the NORMAL Utterance
 */
string GetNormalUtterSpellId(int nSpellId)
{
    //All utterances have their 'normal' id in master column in spells.2da
    string nReturn = Get2DACache("spells", "Master", nSpellId);
    if (1 > StringToInt(nReturn)) nReturn = IntToString(nSpellId); // SpellId invalid for the Master column
    
    return nReturn;

/*    // Level 1 Utterances
    if      (nSpellId == UTTER_DEFENSIVE_EDGE_R || nSpellId == UTTER_DEFENSIVE_EDGE) return UTTER_DEFENSIVE_EDGE;
    else if (nSpellId == UTTER_INERTIAL_SURGE_R || nSpellId == UTTER_INERTIAL_SURGE) return UTTER_INERTIAL_SURGE;
    else if (nSpellId == UTTER_KNIGHTS_PUISSANCE_R || nSpellId == UTTER_KNIGHTS_PUISSANCE) return UTTER_KNIGHTS_PUISSANCE;
    else if (nSpellId == UTTER_UNIVERSAL_APTITUDE_R || nSpellId == UTTER_UNIVERSAL_APTITUDE) return UTTER_UNIVERSAL_APTITUDE;
    else if (nSpellId == UTTER_WORD_NURTURING_MINOR_R || nSpellId == UTTER_WORD_NURTURING_MINOR) return UTTER_WORD_NURTURING_MINOR;
    else if (nSpellId == UTTER_FORTIFY_ARMOUR_SNEAK || nSpellId == UTTER_FORTIFY_ARMOUR_CRIT) return UTTER_FORTIFY_ARMOUR_SNEAK;
    else if (nSpellId == UTTER_FOG_VOID_CLOUD || nSpellId == UTTER_FOG_VOID_SOLID) return UTTER_FOG_VOID_CLOUD;

    // Level 2 Utterances
    else if (nSpellId == UTTER_ARCHERS_EYE_R || nSpellId == UTTER_ARCHERS_EYE) return UTTER_ARCHERS_EYE;
    else if (nSpellId == UTTER_HIDDEN_TRUTH_R || nSpellId == UTTER_HIDDEN_TRUTH) return UTTER_HIDDEN_TRUTH;
    else if (nSpellId == UTTER_PERCEIVE_UNSEEN_R || nSpellId == UTTER_PERCEIVE_UNSEEN) return UTTER_PERCEIVE_UNSEEN;
    else if (nSpellId == UTTER_SILENT_CASTER_R || nSpellId == UTTER_SILENT_CASTER) return UTTER_SILENT_CASTER;
    else if (nSpellId == UTTER_SPEED_ZEPHYR_R || nSpellId == UTTER_SPEED_ZEPHYR) return UTTER_SPEED_ZEPHYR;
    else if (nSpellId == UTTER_STRIKE_MIGHT_R || nSpellId == UTTER_STRIKE_MIGHT) return UTTER_STRIKE_MIGHT;
    else if (nSpellId == UTTER_TEMPORAL_TWIST_R || nSpellId == UTTER_TEMPORAL_TWIST) return UTTER_TEMPORAL_TWIST;
    else if (nSpellId == UTTER_WORD_NURTURING_LESSER_R || nSpellId == UTTER_WORD_NURTURING_LESSER) return UTTER_WORD_NURTURING_LESSER;
    else if (nSpellId == UTTER_AGITATE_ITEM_HOT || nSpellId == UTTER_AGITATE_ITEM_COLD) return UTTER_AGITATE_ITEM_HOT;
    else if (nSpellId == UTTER_ENERGY_VORTEX_ACID || nSpellId == UTTER_ENERGY_VORTEX_COLD || nSpellId == UTTER_ENERGY_VORTEX_ELEC || nSpellId == UTTER_ENERGY_VORTEX_FIRE) return UTTER_ENERGY_VORTEX_ACID;

    // Level 3 Utterances
    else if (nSpellId == UTTER_ACCELERATED_ATTACK_R || nSpellId == UTTER_ACCELERATED_ATTACK) return UTTER_ACCELERATED_ATTACK;
    else if (nSpellId == UTTER_ENERGY_NEGATION_R || nSpellId == UTTER_ENERGY_NEGATION || nSpellId == UTTER_ENERGY_NEGATION_CHOICE) return UTTER_ENERGY_NEGATION;
    else if (nSpellId == UTTER_INCARNATION_ANGELS_R || nSpellId == UTTER_INCARNATION_ANGELS) return UTTER_INCARNATION_ANGELS;
    else if (nSpellId == UTTER_SPEED_ZEPHYR_GREATER_R || nSpellId == UTTER_SPEED_ZEPHYR_GREATER) return UTTER_SPEED_ZEPHYR_GREATER;
    else if (nSpellId == UTTER_TEMPORAL_SPIRAL_R || nSpellId == UTTER_TEMPORAL_SPIRAL) return UTTER_TEMPORAL_SPIRAL;
    else if (nSpellId == UTTER_VISION_SHARPENED_R || nSpellId == UTTER_VISION_SHARPENED) return UTTER_VISION_SHARPENED;
    else if (nSpellId == UTTER_WORD_NURTURING_MODERATE_R || nSpellId == UTTER_WORD_NURTURING_MODERATE) return UTTER_WORD_NURTURING_MODERATE;

    // Level 4 Utterances
    else if (nSpellId == UTTER_BREATH_CLEANSING_R || nSpellId == UTTER_BREATH_CLEANSING) return UTTER_BREATH_CLEANSING;
    else if (nSpellId == UTTER_CASTER_LENS_R || nSpellId == UTTER_CASTER_LENS) return UTTER_CASTER_LENS;
    else if (nSpellId == UTTER_CONFOUNDING_RESISTANCE_R || nSpellId == UTTER_CONFOUNDING_RESISTANCE) return UTTER_CONFOUNDING_RESISTANCE;
    else if (nSpellId == UTTER_MORALE_BOOST_R || nSpellId == UTTER_MORALE_BOOST) return UTTER_MORALE_BOOST;
    else if (nSpellId == UTTER_MAGICAL_CONTRACTION_R || nSpellId == UTTER_MAGICAL_CONTRACTION) return UTTER_MAGICAL_CONTRACTION;
    else if (nSpellId == UTTER_SPELL_REBIRTH_R || nSpellId == UTTER_SPELL_REBIRTH) return UTTER_SPELL_REBIRTH;
    else if (nSpellId == UTTER_WORD_NURTURING_POTENT_R || nSpellId == UTTER_WORD_NURTURING_POTENT) return UTTER_WORD_NURTURING_POTENT;

    // Level 5 Utterances
    else if (nSpellId == UTTER_ELDRITCH_ATTRACTION_R || nSpellId == UTTER_ELDRITCH_ATTRACTION) return UTTER_ELDRITCH_ATTRACTION;
    else if (nSpellId == UTTER_ENERGY_NEGATION_GREATER_R || nSpellId == UTTER_ENERGY_NEGATION_GREATER || nSpellId == UTTER_ENERGY_NEGATION_GREATER_CHOICE) return UTTER_ENERGY_NEGATION_GREATER;
    else if (nSpellId == UTTER_ESSENCE_LIFESPARK_R || nSpellId == UTTER_ESSENCE_LIFESPARK) return UTTER_ESSENCE_LIFESPARK;
    else if (nSpellId == UTTER_PRETERNATURAL_CLARITY_ATTACK || nSpellId == UTTER_PRETERNATURAL_CLARITY_SKILL || nSpellId == UTTER_PRETERNATURAL_CLARITY_SAVE || nSpellId == UTTER_PRETERNATURAL_CLARITY_R) return UTTER_PRETERNATURAL_CLARITY_ATTACK;
    else if (nSpellId == UTTER_SENSORY_FOCUS_R || nSpellId == UTTER_SENSORY_FOCUS) return UTTER_SENSORY_FOCUS;
    else if (nSpellId == UTTER_WARD_PEACE_R || nSpellId == UTTER_WARD_PEACE) return UTTER_WARD_PEACE;
    else if (nSpellId == UTTER_WORD_NURTURING_CRITICAL_R || nSpellId == UTTER_WORD_NURTURING_CRITICAL) return UTTER_WORD_NURTURING_CRITICAL;
    else if (nSpellId == UTTER_METAMAGIC_CATALYST_EMP || nSpellId == UTTER_METAMAGIC_CATALYST_EXT || nSpellId == UTTER_METAMAGIC_CATALYST_MAX) return UTTER_METAMAGIC_CATALYST_EMP;

    // Level 6 Utterances
    else if (nSpellId == UTTER_BREATH_RECOVERY_R || nSpellId == UTTER_BREATH_RECOVERY) return UTTER_BREATH_RECOVERY;
    else if (nSpellId == UTTER_ETHER_REFORGED_R || nSpellId == UTTER_ETHER_REFORGED) return UTTER_ETHER_REFORGED;
    else if (nSpellId == UTTER_KNIGHTS_PUISSANCE_GREATER_R || nSpellId == UTTER_KNIGHTS_PUISSANCE_GREATER) return UTTER_KNIGHTS_PUISSANCE_GREATER;
    else if (nSpellId == UTTER_MYSTIC_RAMPART_R || nSpellId == UTTER_MYSTIC_RAMPART) return UTTER_MYSTIC_RAMPART;
    else if (nSpellId == UTTER_SINGULAR_MIND_R || nSpellId == UTTER_SINGULAR_MIND) return UTTER_SINGULAR_MIND;
    else if (nSpellId == UTTER_WORD_NURTURING_GREATER_R || nSpellId == UTTER_WORD_NURTURING_GREATER) return UTTER_WORD_NURTURING_GREATER;

    // Class abilities
    else if (nSpellId == SYLLABLE_AFFLICATION_SIGHT || nSpellId == SYLLABLE_AFFLICATION_SOUND || nSpellId == SYLLABLE_AFFLICATION_TOUCH) return SYLLABLE_AFFLICATION_SIGHT;
    else if (nSpellId == BRIMSTONE_FIRE_3D6 || nSpellId == BRIMSTONE_FIRE_5D6 || nSpellId == BRIMSTONE_FIRE_8D6) return BRIMSTONE_FIRE_3D6;
    else if (nSpellId == BRIMSTONE_HEAVEN_LESSER || nSpellId == BRIMSTONE_HEAVEN_NORMAL || nSpellId == BRIMSTONE_HEAVEN_GREATER) return BRIMSTONE_HEAVEN_LESSER;

    // This is the return for those with no reverse.
    return nSpellId;*/
}

int GetSwitchAdjustedDC(int nCR, int nTargets, object oTrueSpeaker)
{
    int nClass = GetLevelByClass(CLASS_TYPE_TRUENAMER, oTrueSpeaker);
    int nDC = 15 + (2 * nCR) + (2 * nTargets);
    // Default is 0, off
    int nMulti = GetPRCSwitch(PRC_TRUENAME_CR_MULTIPLIER);
    int nBonus = GetPRCSwitch(PRC_TRUENAME_LEVEL_BONUS);
    int nConst = GetPRCSwitch(PRC_TRUENAME_DC_CONSTANT);
    // nMulti is stored as an int, divide by 100 to get the float
    if(nMulti) nDC = FloatToInt(15 + ((IntToFloat(nMulti)/100) * nCR) + (2 * nTargets));
    if(nBonus) nDC -= nClass/nBonus;
    // Remove the existing constant and add the new one
    if(nConst) nDC = (nDC - 15) + nConst;

    return nDC;
}

int GetFeatAdjustedDC(object oTrueSpeaker)
{
    int nDC = 0;
    // Check for both, not either or
    if(GetHasFeat(FEAT_SKILL_FOCUS_TRUESPEAK, oTrueSpeaker)) nDC += 3;
    if(GetHasFeat(FEAT_EPIC_SKILL_FOCUS_TRUESPEAK, oTrueSpeaker)) nDC += 10;
	if(GetHasFeat(FEAT_TEMPLATE_SAINT_HOLY_POWER, oTrueSpeaker))
		{
			if (GetAlignmentGoodEvil(oTrueSpeaker) == ALIGNMENT_GOOD)
			{
				nDC += 2;
			}
			else
			{
				nDC += 0;
			}
		}
    return nDC;
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetBaseUtteranceDC(object oTarget, object oTrueSpeaker, int nLexicon)
{
    int nDC;

    // We're targetting a creature
    if (nLexicon == LEXICON_EVOLVING_MIND)
    {
        // Check for Speak Unto the Masses. Syllables use the Evolving Mind formula, but can't Speak Unto Masses
        if (GetLocalInt(oTrueSpeaker, TRUE_SPEAK_UNTO_MASSES) && !GetIsSyllable(PRCGetSpellId()))
        {
            if(DEBUG) DoDebug("GetBaseUtteranceDC: Entered");
            // Speak to the Masses affects all creatures of the same race in the AoE
            // Grants a +2 DC for each of them
            int nRacial = MyPRCGetRacialType(oTarget);
            // The creature with the same race as the target and the highest CR is used as the base
            // So we loop through and count all the targets, as well as figure out the highest CR
            int nMaxCR = FloatToInt(GetChallengeRating(oTarget));
            int nCurCR, nTargets;
            if(DEBUG) DoDebug("GetBaseUtteranceDC: Variables");

            // Loop over targets
                        object oAreaTarget = MyFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(30.0), GetLocation(oTarget), TRUE, OBJECT_TYPE_CREATURE);
                        while(GetIsObjectValid(oAreaTarget))
                        {
                            if(DEBUG) DoDebug("GetBaseUtteranceDC: While");
                            // Skip the original target, it doesn't count as a target
                            if (oAreaTarget != oTarget)
                            {
                                if(DEBUG) DoDebug("GetBaseUtteranceDC: Continue");
    
                                // Targeting limitations
                                if(MyPRCGetRacialType(oAreaTarget) == nRacial)
                                {
                                    if(DEBUG) DoDebug("GetBaseUtteranceDC: race check");
                                    // CR Check
                    nCurCR = FloatToInt(GetChallengeRating(oAreaTarget));
                    // Update if you find something bigger
                    if (nCurCR > nMaxCR) nMaxCR = nCurCR;
                    // Increment Targets
                    nTargets++;
                                }// end if - Targeting check
                            }

                            // Get next target
                            if(DEBUG) DoDebug("GetBaseUtteranceDC: Next Target");
                            oAreaTarget = MyNextObjectInShape(SHAPE_SPHERE, FeetToMeters(30.0), GetLocation(oTarget), TRUE, OBJECT_TYPE_CREATURE);
                        }// end while - Target loop

            // Runs the function just above this that adjusts based on switches
            nDC = GetSwitchAdjustedDC(nMaxCR, nTargets, oTrueSpeaker);
                } // end if - Speak unto the Masses check
        else // Single Target Utterance. The normal result
        {
            // CR does not take into account floats, so this is converted.
            int nCR = FloatToInt(GetChallengeRating(oTarget));
            // For PCs, use their HitDice
            if (GetIsPC(oTarget)) nCR = GetHitDice(oTarget);
            // Runs the function just above this that adjusts based on switches
            nDC = GetSwitchAdjustedDC(nCR, 0, oTrueSpeaker);
        }
    }
    // Targetting an Item here
    else if (nLexicon == LEXICON_CRAFTED_TOOL)
    {
        // The formula isn't finished, because there isn't caster level on NWN items.
        int nCasterLvl = GetCraftedToolCR(oTarget);
        nDC = 15 + (2 * nCasterLvl);
    }
    // Targetting the land
    else if (nLexicon == LEXICON_PERFECTED_MAP)
    {
        // Default is 0, off
        int nMulti = GetPRCSwitch(PRC_PERFECTED_MAP_MULTIPLIER);
        int nConst = GetPRCSwitch(PRC_PERFECTED_MAP_CONSTANT);

        // Using Errata formula to prevent abuses
        nDC = 25 + (GetUtteranceLevel(oTrueSpeaker) * 2);

        // nMulti is stored as an int
        if(nMulti) nDC = 25 + (GetUtteranceLevel(oTrueSpeaker) * nMulti);
        // Remove the existing constant and add the new one
        if(nConst) nDC = (nDC - 25) + nConst;
    }
    // Check to see if the PC has either of the Skill Focus feats.
    // If so, subtract (They are a bonus to the PC) from the DC roll
    nDC -= GetFeatAdjustedDC(oTrueSpeaker);

    return nDC;
}

int GetLawOfResistanceDCIncrease(object oTrueSpeaker, int nSpellId)
{
    // This makes sure everything is stored using the Normal, and not the reverse
    // Law of resistance is stored for each utterance by SpellId
    int nDC = GetLocalInt(oTrueSpeaker, LAW_OF_RESIST_VARNAME + GetNormalUtterSpellId(nSpellId));
    // Its stored by the number of succesful attempts, so we double it to get the DC boost
    nDC = nDC * 2;
    
    if (GetPRCSwitch(PRC_LAW_OF_RESISTANCE)) nDC = 0;
    return nDC;
}

void DoLawOfResistanceDCIncrease(object oTrueSpeaker, int nSpellId)
{
    // This makes sure everything is stored using the Normal, and not the reverse
    string sSpellId = GetNormalUtterSpellId(nSpellId);
    // Law of resistance is stored for each utterance by SpellId
    int nNum = GetLocalInt(oTrueSpeaker, LAW_OF_RESIST_VARNAME + sSpellId);
    // Store the number of times per day its been cast succesfully
    SetLocalInt(oTrueSpeaker, LAW_OF_RESIST_VARNAME + sSpellId, (nNum + 1));
}

void ClearLawLocalVars(object oTrueSpeaker)
{
    // As long as the PC isn't a truenamer, don't run this.
    if (GetLevelByClass(CLASS_TYPE_TRUENAMER, oTrueSpeaker))
    {
        // Law of resistance is stored for each utterance by SpellId
        // So we loop em all and blow em away
        // Because there are only about 60, this should not TMI
        // i is the SpellId
        // Replace numbers when done
        int i;
        for(i = 3526; i < 3639; i++)
        {
            DeleteLocalInt(oTrueSpeaker, LAW_OF_RESIST_VARNAME + IntToString(i));
            DeleteLocalInt(oTrueSpeaker, LAW_OF_SEQUENCE_VARNAME + IntToString(i));
        }
    }    
    // As long as the PC isn't a brimstone speaker, don't run this.
    if (GetLevelByClass(CLASS_TYPE_BRIMSTONE_SPEAKER, oTrueSpeaker))
    {
        // Law of resistance is stored for class features by SpellId
        // So we loop em all and blow em away
        // i is the SpellId
        // Replace numbers when done
        int i;
        for(i = 3426; i < 3431; i++)
        {
            DeleteLocalInt(oTrueSpeaker, LAW_OF_RESIST_VARNAME + IntToString(i));
            DeleteLocalInt(oTrueSpeaker, LAW_OF_SEQUENCE_VARNAME + IntToString(i));
        }
    } 
    // As long as the PC isn't a bereft, don't run this.
    if (GetLevelByClass(CLASS_TYPE_BEREFT, oTrueSpeaker))
    {
        // Law of resistance is stored for each utterance by SpellId
        // So we loop em all and blow em away
        // Because there are only about 60, this should not TMI
        // i is the SpellId
        // Replace numbers when done
        int i;
        for(i = 3418; i < 3425; i++)
        {
            DeleteLocalInt(oTrueSpeaker, LAW_OF_RESIST_VARNAME + IntToString(i));
            DeleteLocalInt(oTrueSpeaker, LAW_OF_SEQUENCE_VARNAME + IntToString(i));
        }
    }     
}

int AddPersonalTruenameDC(object oTrueSpeaker, object oTarget)
{
    // Targetting yourself increases the DC by 2
    // But you get a +4 Bonus to speak your own truename
    // Total Adjustment: -2
    int nDC = oTrueSpeaker == oTarget ? -2 : 0;
    
    ///Increase the DC by 4
    if (GetLevelByClass(CLASS_TYPE_ACOLYTE_EGO, oTrueSpeaker) > 6 && oTrueSpeaker != oTarget)  nDC += 4;
    ///Increase the DC by another 4
    if (GetLevelByClass(CLASS_TYPE_ACOLYTE_EGO, oTrueSpeaker) > 8 && oTrueSpeaker != oTarget)  nDC += 4;

    return nDC;
}

int AddIgnoreSpellResistDC(object oTrueSpeaker)
{
    int nDC = GetLocalInt(oTrueSpeaker, TRUE_IGNORE_SR) ? 5 : 0;

    return nDC;
}

int AddUtteranceSpecificDC(object oTrueSpeaker)
{
    int nDC = 0;
    int nSpellID = PRCGetSpellId();
    // When using this utterance you add +10 to the DC to make yourself immune to crits
    if(nSpellID == UTTER_FORTIFY_ARMOUR_CRIT) nDC += 10;
    // When using this utterance you add +10 to the DC to maximize a potion or scroll
    if(nSpellID == UTTER_METAMAGIC_CATALYST_MAX) nDC += 10;
    // When using this utterance you add +10 to the DC to create a solid fog spell
    if(nSpellID == UTTER_FOG_VOID_SOLID) nDC += 10;

    return nDC;
}

int GetRecitationDC(object oTrueSpeaker)
{
    int nCR = GetHitDice(oTrueSpeaker);
    // Formula for the DC. The -2 is from speak your own Truename. See AddPersonalTruenameDC
    int nDC = 15 + (2 * nCR) - 2;

    return nDC;
}

int GetIsSyllable(int nSpellId)
{
    switch(nSpellId)
    {
        case SYLLABLE_DETACHMENT:
        case SYLLABLE_AFFLICATION_SIGHT:
        case SYLLABLE_AFFLICATION_SOUND:
        case SYLLABLE_AFFLICATION_TOUCH:
        case SYLLABLE_EXILE:
        case SYLLABLE_DISSOLUTION:
        case SYLLABLE_ENERVATION:
            return TRUE;
    }

    return FALSE;
}

int DoSpellTruenameCheck(object oTrueSpeaker, object oTarget, int nPersonal = FALSE)
{
	// CR does not take into account floats, so this is converted.
    int nCR = FloatToInt(GetChallengeRating(oTarget));
    // For PCs, use their HitDice
    if (GetIsPC(oTarget)) nCR = GetHitDice(oTarget);
    // Runs the function just above this that adjusts based on switches
    int nDC = GetSwitchAdjustedDC(nCR, 0, oTrueSpeaker);
	// DC change for targeting self and using a Personal Truename
	if (nPersonal)
    	nDC += AddPersonalTruenameDC(oTrueSpeaker, oTarget);  
    	
    if(GetIsSkillSuccessful(oTrueSpeaker, SKILL_TRUESPEAK, nDC)) return TRUE;
    
    return FALSE;
}
