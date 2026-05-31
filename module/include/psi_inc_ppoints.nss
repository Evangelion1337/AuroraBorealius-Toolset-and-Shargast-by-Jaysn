//::///////////////////////////////////////////////
//:: Psionics include: Power Points
//:: psi_inc_ppoints
//::///////////////////////////////////////////////
/** @file
    Defines functions for handling power points.

    @author Ornedan
    @date   Created - 2005.11.04
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// Constants are provided via psi_inc_core

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Returns the given character's current power point count.
 *
 * @param oChar           Character whose power points to examine
 * @return                The character's current power point count
 */
/*
 * @param bCountTemporary If TRUE, the returned value is the sum
 *                        of the character's real and temporary PP,
 *                        otherwise just the real PP
 */
int GetCurrentPowerPoints(object oChar/*, int bCountTemporary = TRUE*/);

/**
 * Returns the given character's maximum power point count.
 *
 * @param oChar Character whose power points to examine
 * @return      The maximum number of power points the character
 *              can normally have
 */
int GetMaximumPowerPoints(object oChar);

/**
 * Returns the current power point count as a string in format:
 * "[current] / [maximum]"
 *
 * @param oChar Character whose power points to examine
 * @return      The given character's power point data in a formatted string
 */
string GetPowerPointsAsString(object oChar);

/**
 * Sends the given character a message telling their current power point
 * count. Format:
 * "Power Points Remaining: [current] / [maximum]"
 *
 * @param oChar Character whom to inform about their power points
 */
void TellCharacterPowerPointStatus(object oChar);

/**
 * Resets current power point count to maximum power points.
 * Any temporary power points are removed.
 *
 * @param oChar Character to perform power point reseting for.
 */
void ResetPowerPoints(object oChar);

/**
 * Increases the character's current power point count by up to the given
 * amount, limited to the character's maximum for real power points unless
 * specifically allowed to exceed the maximum.
 *
 * @param oChar         Character whose power points to adjust
 * @param nGain         How many power points to add
 * @param bCanExceedMax Whether the power point total can exceed the normal
 *                      maximum as a result of this increase
 * @param bInform       If TRUE, runs TellCharacterPowerPointStatus() on oChar
 *                      after making the modification.
 */
void GainPowerPoints(object oChar, int nGain, int bCanExceedMax = FALSE, int bInform = TRUE);

/**
 * Gives the character an amount of temporary power points. Temporary power
 * points are always used first and ignore the maximum PP limit.
 *
 * @param oChar     Character whose power points to adjust
 * @param nGain     How many power points to add
 * @param fDuration How long the temporary power points will last, in seconds
 * @param bInform   If TRUE, runs TellCharacterPowerPointStatus() on oChar
 *                  after making the modification.
 */
void GainTemporaryPowerPoints(object oChar, int nGain, float fDuration, int bInform = TRUE);

/**
 * Decreases the character's current power point count by up to the given
 * amount, limited to not going below 0.
 * Reaching 0 PP causes loss of psionic focus.
 *
 * @param oChar   Character whose power points to adjust
 * @param nLoss   How many power points to remove
 * @param bInform If TRUE, runs TellCharacterPowerPointStatus() on oChar
 *                after making the modification.
 */
void LosePowerPoints(object oChar, int nLoss, int bInform = TRUE);

/**
 * Unconditionally sets the given character's power point count to 0.
 * This causes psionic focus loss as normal.
 *
 * @param oChar   Character whose power points to null
 * @param bInform If TRUE, runs TellCharacterPowerPointStatus() on oChar
 *                after making the modification.
 */
void LoseAllPowerPoints(object oChar, int bInform = TRUE);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "psi_inc_core"


//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function
 * @param oChar Character whose feats to evaluate
 * @return      The amount of Power Points gained from Feats
 */
int _GetFeatBonusPP(object oChar)
{
    int nBonusPP = 0;

//:: Wild Talent
    if(GetHasFeat(FEAT_WILD_TALENT, oChar))
        nBonusPP += 2;

//:: Hidden Talent
    if(GetHasFeat(FEAT_HIDDEN_TALENT, oChar))
        nBonusPP += 2;

//:: Psionic Feats
	int i;
    int nPsiTalents;
    for(i = FEAT_PSIONIC_TALENT_1; i <= FEAT_PSIONIC_TALENT_10; i++)
        if(GetHasFeat(i, oChar)) nPsiTalents++;

    nBonusPP += nPsiTalents * (2 + nPsiTalents + 1) / 2;

//:: Epic feats
    int nImpManifestations;
    for(i = FEAT_IMPROVED_MANIFESTATION_1; i <= FEAT_IMPROVED_MANIFESTATION_10; i++)
        if(GetHasFeat(i, oChar)) nImpManifestations++;

    nBonusPP += nImpManifestations * (18 + nImpManifestations);

    // Racial boni
    if(GetHasFeat(FEAT_NATPSIONIC_1, oChar))
        nBonusPP += 1;
    if(GetHasFeat(FEAT_NATPSIONIC_2, oChar))
        nBonusPP += 2;
    if(GetHasFeat(FEAT_NATPSIONIC_3, oChar))
        nBonusPP += 3;
        
    if(GetRacialType(oChar) == RACIAL_TYPE_KALASHTAR)
        nBonusPP += GetHitDice(oChar);
        
    if(GetRacialType(oChar) == RACIAL_TYPE_EMPTY_VESSEL)
        nBonusPP += GetHitDice(oChar);        
        
    if(GetHasFeat(FEAT_ABERRANT_WARPED_MIND, oChar))
        nBonusPP += GetAberrantFeatCount(oChar);        

    return nBonusPP;
}

/** Internal function
 * @param oChar          Character whose ability modifier to evaluate
 * @param nFirstPsiClass The CLASS_TYPE_* of the character's first psionic class
 * @return               The amount of Bonus Power Points gained from Abilities
 */
int _GetModifierPP (object oChar, int nFirstPsiClass)
{
    int nPP = 0;
    int nBonus;
	
	int nPsion   = GetLevelByClass(CLASS_TYPE_PSION, oChar) + (GetPsionicPRCLevels(oChar, CLASS_TYPE_PSION));
	
    int nPsychic = GetLevelByClass(CLASS_TYPE_PSYWAR, oChar) + (GetPsionicPRCLevels(oChar, CLASS_TYPE_PSYWAR));
	
    int nRogue   = GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE, oChar) + (GetPsionicPRCLevels(oChar, CLASS_TYPE_PSYCHIC_ROGUE));
	
    int nWilder  = GetLevelByClass(CLASS_TYPE_WILDER, oChar) + (GetPsionicPRCLevels(oChar, CLASS_TYPE_WILDER));
	
    int nZuoken  = GetLevelByClass(CLASS_TYPE_FIST_OF_ZUOKEN, oChar) + (GetPsionicPRCLevels(oChar, CLASS_TYPE_FIST_OF_ZUOKEN));
	
    int nWarmind = GetLevelByClass(CLASS_TYPE_WARMIND, oChar) + (GetPsionicPRCLevels(oChar, CLASS_TYPE_WARMIND));
	
/*     int nPsion   = GetLevelByClass(CLASS_TYPE_PSION, oChar)
                 + (nFirstPsiClass == CLASS_TYPE_PSION ? GetPsionicPRCLevels(oChar) : 0);
    int nPsychic = GetLevelByClass(CLASS_TYPE_PSYWAR, oChar)
                 + (nFirstPsiClass == CLASS_TYPE_PSYWAR ? GetPsionicPRCLevels(oChar) : 0);
    int nRogue   = GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE, oChar)
                 + (nFirstPsiClass == CLASS_TYPE_PSYCHIC_ROGUE ? GetPsionicPRCLevels(oChar) : 0);                 
    int nWilder  = GetLevelByClass(CLASS_TYPE_WILDER, oChar)
                 + (nFirstPsiClass == CLASS_TYPE_WILDER ? GetPsionicPRCLevels(oChar) : 0);
    int nZuoken  = GetLevelByClass(CLASS_TYPE_FIST_OF_ZUOKEN, oChar)
                 + (nFirstPsiClass == CLASS_TYPE_FIST_OF_ZUOKEN ? GetPsionicPRCLevels(oChar) : 0);
    int nWarmind = GetLevelByClass(CLASS_TYPE_WARMIND, oChar)
                 + (nFirstPsiClass == CLASS_TYPE_WARMIND ? GetPsionicPRCLevels(oChar) : 0); */

    if(nPsion > 0)
    {
        if(nPsion > 20) nPsion = 20;
        nBonus = (nPsion * GetAbilityModifier(ABILITY_INTELLIGENCE, oChar)) / 2;
        nPP += nBonus;
    }
    if(nPsychic > 0)
    {
        if(nPsychic > 20) nPsychic = 20;
        nBonus = (nPsychic * GetAbilityModifier(ABILITY_WISDOM, oChar)) / 2;
        nPP += nBonus;
    }
    if(nRogue > 0)
    {
        if(nRogue > 20) nRogue = 20;
        nBonus = (nRogue * GetAbilityModifier(ABILITY_INTELLIGENCE, oChar)) / 2;
        nPP += nBonus;
    }    
    if(nWilder > 0)
    {
        if(nWilder > 20) nWilder = 20;
        nBonus = (nWilder * GetAbilityModifier(ABILITY_CHARISMA, oChar)) / 2;
        nPP += nBonus;
    }
    if(nZuoken > 0)
    {
        if(nZuoken > 10) nZuoken = 10;
        nBonus = (nZuoken * GetAbilityModifier(ABILITY_WISDOM, oChar)) / 2;
        nPP += nBonus;
    }
    if(nWarmind > 0)
    {
        if(nWarmind > 10) nWarmind = 10;
        nBonus = (nWarmind * GetAbilityModifier(ABILITY_WISDOM, oChar)) / 2;
        nPP += nBonus;
    }

    return nPP;
}

/** Internal function
 * @param oChar          Character whose classes to evaluate
 * @param nClass         The CLASS_TYPE_* of the specific class to evaluate
 * @param nFirstPsiClass The CLASS_TYPE_* of the character's first psionic class
 * @return               The amount of Power Points gained from levels in the
 *                       given class
 */
int _GetPPForClass (object oChar, int nClass, int nFirstPsiClass)
{
    int nPP;
    int nLevel = GetLevelByClass(nClass, oChar) + GetPsionicPRCLevels(oChar, nClass);
	
               //+ (nFirstPsiClass == nClass ? GetPsionicPRCLevels(oChar) : 0);
    string sPsiFile = GetAMSKnownFileName(nClass);
    nPP = StringToInt(Get2DACache(sPsiFile, "PowerPoints", nLevel - 1)); // Index from 0

    return nPP;
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetCurrentPowerPoints(object oChar/*, int bCountTemporary = TRUE*/)
{
    int nRealPP =      GetLocalInt(oChar, POWER_POINT_VARNAME);
    //int nTemporaryPP = 0; ///@todo If necessary

    return nRealPP; //+ nTemporaryPP;
}

int GetMaximumPowerPoints(object oChar)
{
    int nMaxPP;

    // The character's first psionic class is considered to be the one that +ML PrCs add to
    int nFirstPsiClass = GetPrimaryPsionicClass(oChar);

    nMaxPP += _GetPPForClass(oChar, CLASS_TYPE_PSION, nFirstPsiClass);
    nMaxPP += _GetPPForClass(oChar, CLASS_TYPE_WILDER, nFirstPsiClass);
    nMaxPP += _GetPPForClass(oChar, CLASS_TYPE_PSYWAR, nFirstPsiClass);
    nMaxPP += _GetPPForClass(oChar, CLASS_TYPE_PSYCHIC_ROGUE, nFirstPsiClass);
    nMaxPP += _GetPPForClass(oChar, CLASS_TYPE_FIST_OF_ZUOKEN, nFirstPsiClass);
    nMaxPP += _GetPPForClass(oChar, CLASS_TYPE_WARMIND, nFirstPsiClass);

    nMaxPP += _GetModifierPP(oChar, nFirstPsiClass);

    nMaxPP += _GetFeatBonusPP(oChar);

    return nMaxPP;
}

string GetPowerPointsAsString(object oChar)
{
    return IntToString(GetCurrentPowerPoints(oChar)) + " / " + IntToString(GetMaximumPowerPoints(oChar));
}

void TellCharacterPowerPointStatus(object oChar)
{
    FloatingTextStringOnCreature(GetStringByStrRef(16824181) + " " + GetPowerPointsAsString(oChar), // "Power Points Remaining:"
                                 oChar, FALSE);
}

void ResetPowerPoints(object oChar)
{
    SetLocalInt(oChar, POWER_POINT_VARNAME, GetMaximumPowerPoints(oChar));
}

void GainPowerPoints(object oChar, int nGain, int bCanExceedMax = FALSE, int bInform = TRUE)
{
    int nCurPP = GetCurrentPowerPoints(oChar/*, FALSE*/);
        nCurPP += nGain;

    if(!bCanExceedMax)
    {
        int nMaxPP = GetMaximumPowerPoints(oChar);
        if(nCurPP > nMaxPP)
            nCurPP = nMaxPP;
    }

    SetLocalInt(oChar, POWER_POINT_VARNAME, nCurPP);

    if(bInform)
        TellCharacterPowerPointStatus(oChar);
}

/*
void GainTemporaryPowerPoints(object oChar, int nGain, float fDuration, int bInform = TRUE)
{
}
*/

void LosePowerPoints(object oChar, int nLoss, int bInform = TRUE)
{
    int nCurPP = GetCurrentPowerPoints(oChar/*, FALSE*/);
        nCurPP -= nLoss;
    if(nCurPP < 0)
        nCurPP = 0;

    SetLocalInt(oChar, POWER_POINT_VARNAME, nCurPP);

    if(GetCurrentPowerPoints(oChar) == 0)
        LosePsionicFocus(oChar);

    if(bInform)
        TellCharacterPowerPointStatus(oChar);
}

void LoseAllPowerPoints(object oChar, int bInform = TRUE)
{
    SetLocalInt(oChar, POWER_POINT_VARNAME, 0);

    LosePsionicFocus(oChar);

    if(bInform)
        TellCharacterPowerPointStatus(oChar);
}

// Test main
//void main(){}
