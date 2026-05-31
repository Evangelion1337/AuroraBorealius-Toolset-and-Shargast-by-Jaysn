//::///////////////////////////////////////////////
//:: Tome of Battle include: Miscellaneous
//:: tob_inc_tobfunc
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to the Tome of Battle implementation.

    Also acts as inclusion nexus for the general
    tome of battle includes. In other words, don't include
    them directly in your scripts, instead include this.

    @author Stratovarius
    @date   Created - 2007.3.19
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//:: Updated for .35 by Jaysyn 2023/03/11

//:: Test Void
//void main (){}

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int DISCIPLINE_DESERT_WIND    =   1;
const int DISCIPLINE_DEVOTED_SPIRIT =   2;
const int DISCIPLINE_DIAMOND_MIND   =   4;
const int DISCIPLINE_IRON_HEART     =   8;
const int DISCIPLINE_SETTING_SUN    =  16;
const int DISCIPLINE_SHADOW_HAND    =  32;
const int DISCIPLINE_STONE_DRAGON   =  64;
const int DISCIPLINE_TIGER_CLAW     = 128;
const int DISCIPLINE_WHITE_RAVEN    = 256;

const string PRC_INITIATING_CLASS        = "PRC_CurrentManeuver_InitiatingClass";
const string PRC_MANEUVER_LEVEL          = "PRC_CurrentManeuver_Level";

const int MANEUVER_TYPE_STANCE            = 1;
const int MANEUVER_TYPE_STRIKE            = 2;
const int MANEUVER_TYPE_COUNTER           = 3;
const int MANEUVER_TYPE_BOOST             = 4;
//global constant (strike & counter & boost)
const int MANEUVER_TYPE_MANEUVER          = 5;

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines from what class's maneuver list the currently being initiated
 * maneuver is initiated from.
 *
 * @param oInitiator A creature initiating a maneuver at this moment
 * @return            CLASS_TYPE_* constant of the class
 */
int GetInitiatingClass(object oInitiator = OBJECT_SELF);

/**
 * Determines the given creature's Initiator level. If a class is specified,
 * then returns the Initiator level for that class. Otherwise, returns
 * the Initiator level for the currently active maneuver.
 *
 * @param oInitiator   The creature whose Initiator level to determine
 * @param nSpecificClass The class to determine the creature's Initiator
 *                       level in.
 *                       DEFAULT: CLASS_TYPE_INVALID, which means the creature's
 *                       Initiator level in regards to an ongoing maneuver
 *                       is determined instead.
 * @return               The Initiator level
 */
int GetInitiatorLevel(object oInitiator = OBJECT_SELF, int nSpecificClass = CLASS_TYPE_INVALID);

/**
 * Determines whether a given creature uses BladeMagic.
 * Requires either levels in a BladeMagic-related class or
 * natural BladeMagic ability based on race.
 *
 * @param oCreature Creature to test
 * @return          TRUE if the creature can use BladeMagics, FALSE otherwise.
 */
int GetIsBladeMagicUser(object oCreature);

/**
 * Determines the given creature's highest undmodified Initiator level among it's
 * initiating classes.
 *
 * @param oCreature Creature whose highest Initiator level to determine
 * @return          The highest unmodified Initiator level the creature can have
 */
int GetHighestInitiatorLevel(object oCreature);

/**
 * Determines whether a given class is a BladeMagic-related class or not.
 *
 * @param nClass CLASS_TYPE_* of the class to test
 * @return       TRUE if the class is a BladeMagic-related class, FALSE otherwise
 */
int GetIsBladeMagicClass(int nClass);

/**
 * Gets the level of the maneuver being currently initiated or the level
 * of the maneuver ID passed to it.
 *
 * @param oInitiator The creature currently initiating a maneuver
 * @return            The level of the maneuver being initiated
 */
int GetManeuverLevel(object oInitiator, int nMoveId = 0);

/**
 * Returns the type of the maneuver
 *
 * @param nSpellId        SpellId of the maneuver
 */
int GetManeuverType(int nSpellId);

/**
 * Returns the name of the maneuver
 *
 * @param nSpellId        SpellId of the maneuver
 */
string GetManeuverName(int nSpellId);

/**
 * Returns the name of the Discipline
 *
 * @param nDiscipline        DISCIPLINE_* to name
 */
string GetDisciplineName(int nDiscipline);

/**
 * Returns the Discipline the maneuver is in
 * @param nMoveId    maneuver to check
 *
 * @return           DISCIPLINE_*
 */
int GetDisciplineByManeuver(int nMoveId);

/**
 * Returns true or false if the initiator has the Discipline
 * @param oInitiator    Person to check
 * @param nDiscipline   Discipline to check
 *
 * @return           TRUE or FALSE
 */
int TOBGetHasDiscipline(object oInitiator, int nDiscipline);

/**
 * Returns true or false if the swordsage has Discipline
 * focus in the chosen discipline
 * @param oInitiator    Person to check
 * @param nDiscipline   Discipline to check
 *
 * @return           TRUE or FALSE
 */
int TOBGetHasDisciplineFocus(object oInitiator, int nDiscipline);

/**
 * Calculates how many initiator levels are gained by a given creature from
 * it's levels in prestige classes.
 *
 * @param oCreature Creature to calculate added initiator levels for
 * @return          The number of initiator levels gained
 */
int GetBladeMagicPRCLevels(object oInitiator);

/**
 * Determines which of the character's classes is their highest or first blade magic
 * initiating class, if any. This is the one which gains initiator level raise benefits
 * from prestige classes.
 *
 * @param oCreature Creature whose classes to test
 * @return          CLASS_TYPE_* of the first blade magic initiating class,
 *                  CLASS_TYPE_INVALID if the creature does not possess any.
 */
int GetPrimaryBladeMagicClass(object oCreature = OBJECT_SELF);

/**
 * Determines the position of a creature's first blade magic initiating class, if any.
 *
 * @param oCreature Creature whose classes to test
 * @return          The position of the first blade magic class {1, 2, 3} or 0 if
 *                  the creature possesses no levels in blade magic classes.
 */
int GetFirstBladeMagicClassPosition(object oCreature = OBJECT_SELF);

/**
 * Checks whether the PC has the prereqs for the maneuver
 *
 * @param nClass The class that is trying to learn the feat
 * @param nFeat The maneuver's FeatId
 * @param oPC   The creature whose feats to check
 * @return      TRUE if the PC possesses the prerequisite feats AND does not
 *              already posses nFeat, FALSE otherwise.
 */
int CheckManeuverPrereqs(int nClass, int nPrereqs, int nDiscipline, object oPC);

/**
 * Checks whether the maneuver is supernatural or not
 * Mainly used to check for AMF areas.
 * Mostly from Swordsage maneuvers
 *
 * @param nMoveId The Maneuver to Check
 * @return        TRUE if Maneuver is (Su), else FALSE
 */
int GetIsManeuverSupernatural(int nMoveId);

/**
 * Checks whether the initiator has an active stance
 *
 * @param oInitiator The Initiator
 * @return        The SpellId or FALSE
 */
int GetHasActiveStance(object oInitiator);

/**
 * Clears spell effects for Stances
 * Will NOT clear nDontClearMove
 *
 * @param oInitiator The Initiator
 * @param nDontClearMove A single Stance not to clear
 */
void ClearStances(object oInitiator, int nDontClearMove);

/**
 * Marks a stance active via local ints
 *
 * @param oInitiator The Initiator
 * @param nStance    The stance to mark active
 */
void MarkStanceActive(object oInitiator, int nStance);

/**
 * This will take an effect that is supposed to be based on size
 * And use vs racial effects to approximate it
 *
 * @param oInitiator The Initiator
 * @param eEffect    The effect to scale
 * @param nSize      0 affects creature one size or more smaller.
 *                   1 affects creatures one size or more larger
 */
effect VersusSizeEffect(object oInitiator, effect eEffect, int nSize);

/**
 * Checks every 6 seconds whether an adept has moved too far for a stance
 * Or whether the adept has moved far enough to get a bonus from a stance
 *
 * @param oPC        The Initiator
 * @param nMoveId    The stance
 * @param fFeet      The distance to check
 */
void InitiatorMovementCheck(object oPC, int nMoveId, float fFeet = 10.0);

/**
 * Checks whether the maneuver is a stance
 *
 * @param nMoveId    The Maneuver
 * @return           TRUE or FALSE
 */
int GetIsStance(int nMoveId);

/**
 * Sets up everything for the Damage boosts (xd6 + IL fire damage)
 * That the Desert Wind discipline has.
 *
 * @param oPC      The PC
 */
void DoDesertWindBoost(object oPC);

/**
 * Determines which PC in the area is weakest, and
 * returns that PC.
 *
 * @param oPC      The PC
 * @param fDistance The distance to check in feet
 * @return         The Target
 */
object GetCrusaderHealTarget(object oPC, float fDistance);

/**
 * Returns true or false if the swordsage has Insightful Strike in the chosen discipline
 * @param oInitiator    Person to check
 *
 * @return              TRUE or FALSE
 */
int GetHasInsightfulStrike(object oInitiator);

/**
 * Returns true or false if the swordsage has Defensive Stance
 * ONLY CALL THIS FROM WITHIN STANCES
 * @param oInitiator    Person to check
 * @param nDiscipline   DISCIPLINE_ constant of the school of the maneuver.
 *
 * @return              TRUE or FALSE
 */
int GetHasDefensiveStance(object oInitiator, int nDiscipline);

/**
 * Returns true if it is a weapon of the appropriate discipline
 * @param oWeapon       Weapon to check
 * @param nDiscipline   DISCIPLINE_ constant of the school of the maneuver.
 *
 * @return              TRUE or FALSE
 */
int GetIsDisciplineWeapon(object oWeapon, int nDiscipline);

/**
 * Returns a numerical bonus to attacks for use in strikes
 * @param oInitiator    Person to check
 * @param nDiscipline   DISCIPLINE_ constant of the school of the maneuver.
 * @param nClass        CLASS_TYPE_ constant
 *
 * @return              Bonus total
 */
int TOBSituationalAttackBonuses(object oInitiator, int nDiscipline, int nClass = CLASS_TYPE_INVALID);

/**
 * Returns the skill for the named discipline
 * @param nDiscipline   DISCIPLINE_ constant
 *
 * @return              Discipline skill
 */
int GetDisciplineSkill(int nDiscipline);

/**
 * Returns the discipline for the Blade Meditation feat
 * @param oInitiator    Person to check
 *
 * @return              DISCIPLINE_ constant
 */
int BladeMeditationFeat(object oInitiator);

/**
 * Returns 1 if feat and maneuver match
 * @param oInitiator    Person to check
 * @param nMoveId       Maneuver to check
 *
 * @return              1 or -1
 */
int BladeMeditationDamage(object oInitiator, int nMoveId);


/**
 * Returns 1 if Blade Meditation & Discipline match
 * @param oInitiator    Person to check
 * @param nDiscipline   Discipline to match
 *
 * @return              1 or 0
 */
 int HasBladeMeditationForDiscipline(object oInitiator, int nDiscipline);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "tob_move_const"
#include "prc_alterations"
#include "tob_inc_moveknwn"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////


int _CheckPrereqsByDiscipline(object oPC, int nDiscipline, int nCount = 1)
{
    int nPrereqCount = GetManeuverCountByDiscipline(oPC, nDiscipline, MANEUVER_TYPE_MANEUVER)
                      + GetManeuverCountByDiscipline(oPC, nDiscipline, MANEUVER_TYPE_STANCE);

    if(nPrereqCount >= nCount)
        return nPrereqCount;

    return 0;
}

void _RecursiveStanceCheck(object oPC, object oTestWP, int nMoveId, float fFeet = 10.0)
{
    // Seeing if this works better
    string sWPTag = "PRC_BMWP_" + GetName(oPC) + IntToString(nMoveId);
    oTestWP = GetWaypointByTag(sWPTag);
    // Distance moved in the last round
    float fDist = FeetToMeters(GetDistanceBetween(oPC, oTestWP));
    // Giving them a little extra distance because of NWN's dance of death
    float fCheck = FeetToMeters(fFeet);
    if(DEBUG) DoDebug("_RecursiveStanceCheck: fDist: " + FloatToString(fDist));
    if(DEBUG) DoDebug("_RecursiveStanceCheck: fCheck: " + FloatToString(fCheck));
    if(DEBUG) DoDebug("_RecursiveStanceCheck: nMoveId: " + IntToString(nMoveId));


    // Moved the distance
    if (fDist >= fCheck)
    {
        if(DEBUG) DoDebug("_RecursiveStanceCheck: fDist > fCheck");
        // Stances that clean up
        if (nMoveId == MOVE_SD_STONEFOOT_STANCE)
        {
                PRCRemoveEffectsFromSpell(oPC, nMoveId);
                if(DEBUG) DoDebug("_RecursiveStanceCheck: Moved too far, cancelling stances.");
                // Clean up the test WP as well
                DestroyObject(oTestWP);
        }
        // Stances that clean up
        else if (nMoveId == MOVE_MOUNTAIN_FORTRESS)
        {
                PRCRemoveEffectsFromSpell(oPC, nMoveId);
                if(DEBUG) DoDebug("_RecursiveStanceCheck: Moved too far, cancelling stances.");
                // Clean up the test WP as well
                DestroyObject(oTestWP);
        }
        // Stances that clean up
        else if (nMoveId == MOVE_SD_ROOT_MOUNTAIN)
        {
                PRCRemoveEffectsFromSpell(oPC, nMoveId);
                if(DEBUG) DoDebug("_RecursiveStanceCheck: Moved too far, cancelling stances.");
                // Clean up the test WP as well
                DestroyObject(oTestWP);
        }
        else if (nMoveId == MOVE_SH_CHILD_SHADOW)
        {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(EffectConcealment(20)), oPC, 6.0);
                if(DEBUG) DoDebug("_RecursiveStanceCheck: Applying bonuses.");
                // Clean up the test WP
                DestroyObject(oTestWP);
                // Create waypoint for the movement for next round
                CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", GetLocation(oPC), FALSE, sWPTag);
        }
        else if (nMoveId == MOVE_IH_ABSOLUTE_STEEL)
        {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectACIncrease(2)), oPC, 6.0);
                if(DEBUG) DoDebug("_RecursiveStanceCheck: Applying bonuses.");
                // Clean up the test WP
                DestroyObject(oTestWP);
                // Create waypoint for the movement for next round
                CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", GetLocation(oPC), FALSE, sWPTag);
        }

        else if (nMoveId == MOVE_SD_GIANTS_STANCE)
        {
                DeleteLocalInt(oPC, "DWGiantsStance");
                DeleteLocalInt(oPC, "PRC_Power_Expansion_SizeIncrease");
                PRCRemoveEffectsFromSpell(oPC, nMoveId);
                DestroyObject(oTestWP);
        }

        else if (nMoveId == MOVE_IH_DANCING_BLADE_FORM)
        {
                DeleteLocalInt(oPC, "DWDancingBladeForm");
                DestroyObject(oTestWP);
        }

    }
    // If they still have the spell, keep going
    if (GetHasSpellEffect(nMoveId, oPC))
    {
        DelayCommand(6.0, _RecursiveStanceCheck(oPC, oTestWP, nMoveId));
        if(DEBUG) DoDebug("_RecursiveStanceCheck: DelayCommand(6.0, _RecursiveStanceCheck(oPC, oTestWP, nMoveId)).");
    }

    if(DEBUG) DoDebug("_RecursiveStanceCheck: Exiting");
}

int _AllowedDiscipline(object oInitiator, int nClass, int nDiscipline)
{
    //maneuver choice for prestige classes is restricted only to those disciplines
    int nOverride = GetPersistantLocalInt(oInitiator, "AllowedDisciplines");
    if(nOverride == 0)
    {
        switch(nClass)
        {
            case CLASS_TYPE_CRUSADER:  nOverride = 322; break;//DISCIPLINE_DEVOTED_SPIRIT + DISCIPLINE_STONE_DRAGON + DISCIPLINE_WHITE_RAVEN
            case CLASS_TYPE_SWORDSAGE: nOverride = 245; break;//DISCIPLINE_DESERT_WIND + DISCIPLINE_DIAMOND_MIND + DISCIPLINE_SETTING_SUN + DISCIPLINE_SHADOW_HAND + DISCIPLINE_STONE_DRAGON + DISCIPLINE_TIGER_CLAW
            case CLASS_TYPE_WARBLADE:  nOverride = 460; break;//DISCIPLINE_DIAMOND_MIND + DISCIPLINE_IRON_HEART + DISCIPLINE_STONE_DRAGON + DISCIPLINE_TIGER_CLAW + DISCIPLINE_WHITE_RAVEN
        }
    }
    return nOverride & nDiscipline;
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetInitiatingClass(object oInitiator = OBJECT_SELF)
{
    return GetLocalInt(oInitiator, PRC_INITIATING_CLASS) - 1;
}

int GetInitiatorLevel(object oInitiator = OBJECT_SELF, int nSpecificClass = CLASS_TYPE_INVALID)
{
    int nAdjust = GetLocalInt(oInitiator, PRC_CASTERLEVEL_ADJUSTMENT);
    int nLevel = GetLocalInt(oInitiator, PRC_CASTERLEVEL_OVERRIDE);

    // For when you want to assign the caster level.
    if(nLevel)
    {
        if(DEBUG) SendMessageToPC(oInitiator, "GetInitiatorLevel(): Forced-level initiating at level " + IntToString(nLevel));
        //DelayCommand(1.0, DeleteLocalInt(oInitiator, PRC_CASTERLEVEL_OVERRIDE));
        return nLevel + nAdjust;
    }

    int nTotalHD = GetHitDice(oInitiator);

    // The function user needs to know the character's Initiator level in a specific class
    // instead of whatever the character last initiated a maneuver as
    if(nSpecificClass != CLASS_TYPE_INVALID)
    {
        if(GetIsBladeMagicClass(nSpecificClass))
        {
            // Initiator level is class level + 1/2 levels in all other classes
            // See ToB p39
            // Max level is therefor the level plus 1/2 of remaining levels
            // Prestige classes are stuck in here
            int nClassLevel = GetLevelByClass(nSpecificClass, oInitiator);
            if(nClassLevel)
            {
                nClassLevel += GetBladeMagicPRCLevels(oInitiator);
                nLevel = nClassLevel + ((nTotalHD - nClassLevel)/2);
            }
        }
    }
    else if(GetInitiatingClass(oInitiator) != -1)
    {
        int nClassLevel = GetLevelByClass(GetInitiatingClass(oInitiator), oInitiator);
        nClassLevel += GetBladeMagicPRCLevels(oInitiator);
        nLevel = nClassLevel + ((nTotalHD - nClassLevel)/2);
    }

    // A character with no initiator levels has an init level of 1/2 HD (min 1)
    if(!nLevel)
        nLevel = PRCMax(1, nTotalHD/2);

    // This spam is technically no longer necessary once the Initiator level getting mechanism has been confirmed to work
//    if(DEBUG) FloatingTextStringOnCreature("Initiator Level: " + IntToString(nLevel), oInitiator, FALSE);

    return nLevel + nAdjust;
}

int GetIsBladeMagicUser(object oCreature)
{
    return !!(GetLevelByClass(CLASS_TYPE_CRUSADER, oCreature)
            || GetLevelByClass(CLASS_TYPE_SWORDSAGE, oCreature)
            || GetLevelByClass(CLASS_TYPE_WARBLADE, oCreature));
}

int GetHighestInitiatorLevel(object oCreature)
{
	int n = 0;
	int nHighest;
	int nTemp;
	
    while(n <= 8)
	{
		if(GetClassByPosition(n, oCreature) != CLASS_TYPE_INVALID)
		{
			nTemp = GetInitiatorLevel(oCreature, GetClassByPosition(n, oCreature));
			
			if(nTemp > nHighest) 
				nHighest = nTemp;
		}
	n++;

	}
	
	return nHighest;
}

/* int GetHighestInitiatorLevel(object oCreature)
{
    return PRCMax(PRCMax(GetClassByPosition(1, oCreature) != CLASS_TYPE_INVALID ? GetInitiatorLevel(oCreature, GetClassByPosition(1, oCreature)) : 0,
                   GetClassByPosition(2, oCreature) != CLASS_TYPE_INVALID ? GetInitiatorLevel(oCreature, GetClassByPosition(2, oCreature)) : 0
                   ),
               GetClassByPosition(3, oCreature) != CLASS_TYPE_INVALID ? GetInitiatorLevel(oCreature, GetClassByPosition(3, oCreature)) : 0
               );
} */

int GetIsBladeMagicClass(int nClass)
{
    return nClass == CLASS_TYPE_CRUSADER
         || nClass == CLASS_TYPE_SWORDSAGE
         || nClass == CLASS_TYPE_WARBLADE;
}

int GetManeuverLevel(object oInitiator, int nMoveId = 0)
{
    int nLevel = GetLocalInt(oInitiator, PRC_MANEUVER_LEVEL);
    if (nLevel > 0) return nLevel;
    else if (nMoveId > 0) return StringToInt(lookup_spell_innate(nMoveId));
    
    return 0;
}

string GetManeuverName(int nSpellId)
{
    return GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId)));
}

int GetManeuverType(int nSpellId)
{
    return StringToInt(GetStringRight(Get2DACache("spells", "MetaMagic", nSpellId), 1));
}

int GetIsStance(int nMoveId)
{
    return GetManeuverType(nMoveId) == MANEUVER_TYPE_STANCE;
}

string GetDisciplineName(int nDiscipline)
{
    int nStrRef;
    switch(nDiscipline)
    {
        case DISCIPLINE_DESERT_WIND:    nStrRef = 16829714; break;
        case DISCIPLINE_DEVOTED_SPIRIT: nStrRef = 16829715; break;
        case DISCIPLINE_DIAMOND_MIND:   nStrRef = 16829716; break;
        case DISCIPLINE_IRON_HEART:     nStrRef = 16829717; break;
        case DISCIPLINE_SETTING_SUN:    nStrRef = 16829718; break;
        case DISCIPLINE_SHADOW_HAND:    nStrRef = 16829719; break;
        case DISCIPLINE_STONE_DRAGON:   nStrRef = 16829720; break;
        case DISCIPLINE_TIGER_CLAW:     nStrRef = 16829721; break;
        case DISCIPLINE_WHITE_RAVEN:    nStrRef = 16829722; break;
    }
    return GetStringByStrRef(nStrRef);
}

int GetDisciplineByManeuver(int nMoveId)
{
    string sSpellSchool = Get2DACache("spells", "School", nMoveId);
    int nDiscipline;

    if      (sSpellSchool == "A") nDiscipline = DISCIPLINE_DEVOTED_SPIRIT;
    else if (sSpellSchool == "C") nDiscipline = DISCIPLINE_SETTING_SUN;
    else if (sSpellSchool == "D") nDiscipline = DISCIPLINE_IRON_HEART;
    else if (sSpellSchool == "E") nDiscipline = DISCIPLINE_DIAMOND_MIND;
    else if (sSpellSchool == "V") nDiscipline = DISCIPLINE_DESERT_WIND;
    else if (sSpellSchool == "I") nDiscipline = DISCIPLINE_SHADOW_HAND;
    else if (sSpellSchool == "N") nDiscipline = DISCIPLINE_WHITE_RAVEN;
    else if (sSpellSchool == "T") nDiscipline = DISCIPLINE_TIGER_CLAW;
    else if (sSpellSchool == "G") nDiscipline = DISCIPLINE_STONE_DRAGON;

    return nDiscipline;
}

int GetBladeMagicPRCLevels(object oInitiator)
{
    int nRace = GetRacialType(oInitiator);
	
	int nLevel = GetLevelByClass(CLASS_TYPE_DEEPSTONE_SENTINEL, oInitiator)
               + GetLevelByClass(CLASS_TYPE_BLOODCLAW_MASTER,   oInitiator)
               + GetLevelByClass(CLASS_TYPE_RUBY_VINDICATOR,    oInitiator)
               + GetLevelByClass(CLASS_TYPE_JADE_PHOENIX_MAGE,  oInitiator)
               + GetLevelByClass(CLASS_TYPE_MASTER_OF_NINE,     oInitiator)
               + GetLevelByClass(CLASS_TYPE_ETERNAL_BLADE,      oInitiator)
               + GetLevelByClass(CLASS_TYPE_SHADOW_SUN_NINJA,   oInitiator);
			   
	if (nRace == RACIAL_TYPE_RETH_DEKALA)
	{
		nLevel += GetLevelByClass(CLASS_TYPE_OUTSIDER, oInitiator);		
	}
		

    return nLevel;
}

int GetPrimaryBladeMagicClass(object oCreature = OBJECT_SELF)
{
    int nClass = CLASS_TYPE_INVALID;

    if(GetPRCSwitch(PRC_CASTERLEVEL_FIRST_CLASS_RULE))
    {
        int nBladeMagicPos = GetFirstBladeMagicClassPosition(oCreature);
        if (!nBladeMagicPos) return CLASS_TYPE_INVALID; // no Blade Magic initiating class

        nClass = GetClassByPosition(nBladeMagicPos, oCreature);
    }
    else
    {
        /*int i, nLevel, nTest, nTestLevel;
        for(i = 1; i < 4; i++)
        {
            nTest = GetClassByPosition(i, oCreature);
            if(GetIsBladeMagicClass(nTest))
            {
                nTestLevel = GetLevelByClass(nTest, oCreature);
                if(nTestLevel > nLevel)
                {
                    nClass = nTest;
                    nLevel = nTestLevel;
                }
            }
        }*/
        
        int nClassLvl;
        int nClass1, nClass2, nClass3, nClass4, nClass5, nClass6, nClass7, nClass8;
        int nClass1Lvl, nClass2Lvl, nClass3Lvl, nClass4Lvl, nClass5Lvl, nClass6Lvl, nClass7Lvl, nClass8Lvl;

        nClass1 = GetClassByPosition(1, oCreature);
        nClass2 = GetClassByPosition(2, oCreature);
        nClass3 = GetClassByPosition(3, oCreature);
        nClass4 = GetClassByPosition(4, oCreature);
        nClass5 = GetClassByPosition(5, oCreature);
        nClass6 = GetClassByPosition(6, oCreature);
		nClass7 = GetClassByPosition(7, oCreature);
        nClass8 = GetClassByPosition(8, oCreature);
		
        if(GetIsBladeMagicClass(nClass1)) nClass1Lvl = GetLevelByClass(nClass1, oCreature);
        if(GetIsBladeMagicClass(nClass2)) nClass2Lvl = GetLevelByClass(nClass2, oCreature);
        if(GetIsBladeMagicClass(nClass3)) nClass3Lvl = GetLevelByClass(nClass3, oCreature);
        if(GetIsBladeMagicClass(nClass4)) nClass4Lvl = GetLevelByClass(nClass4, oCreature);
        if(GetIsBladeMagicClass(nClass5)) nClass5Lvl = GetLevelByClass(nClass5, oCreature);
        if(GetIsBladeMagicClass(nClass6)) nClass6Lvl = GetLevelByClass(nClass6, oCreature);
        if(GetIsBladeMagicClass(nClass7)) nClass7Lvl = GetLevelByClass(nClass7, oCreature);
        if(GetIsBladeMagicClass(nClass8)) nClass8Lvl = GetLevelByClass(nClass8, oCreature);
		
        nClass = nClass1;
        nClassLvl = nClass1Lvl;
		
        if(nClass2Lvl > nClassLvl)
        {
            nClass = nClass2;
            nClassLvl = nClass2Lvl;
        }
        if(nClass3Lvl > nClassLvl)
        {
            nClass = nClass3;
            nClassLvl = nClass3Lvl;
        }
		if(nClass4Lvl > nClassLvl)
        {
            nClass = nClass4;
            nClassLvl = nClass4Lvl;
        }
        if(nClass5Lvl > nClassLvl)
        {
            nClass = nClass5;
            nClassLvl = nClass5Lvl;
        }
		if(nClass6Lvl > nClassLvl)
        {
            nClass = nClass6;
            nClassLvl = nClass6Lvl;
        }
        if(nClass7Lvl > nClassLvl)
        {
            nClass = nClass7;
            nClassLvl = nClass7Lvl;
        }		
        if(nClass8Lvl > nClassLvl)
        {
            nClass = nClass8;
            nClassLvl = nClass8Lvl;
        }		
		
        if(nClassLvl == 0)
            nClass = CLASS_TYPE_INVALID;
    }

    return nClass;
}

int GetFirstBladeMagicClassPosition(object oCreature = OBJECT_SELF)
{
    if (GetIsBladeMagicClass(GetClassByPosition(1, oCreature)))
        return 1;
    if (GetIsBladeMagicClass(GetClassByPosition(2, oCreature)))
        return 2;
    if (GetIsBladeMagicClass(GetClassByPosition(3, oCreature)))
        return 3;
    if (GetIsBladeMagicClass(GetClassByPosition(4, oCreature)))
        return 4;
    if (GetIsBladeMagicClass(GetClassByPosition(5, oCreature)))
        return 5;
    if (GetIsBladeMagicClass(GetClassByPosition(6, oCreature)))
        return 6;
    if (GetIsBladeMagicClass(GetClassByPosition(7, oCreature)))
        return 7;
    if (GetIsBladeMagicClass(GetClassByPosition(8, oCreature)))
        return 8;	
	
    return 0;
}

int CheckManeuverPrereqs(int nClass, int nPrereqs, int nDiscipline, object oPC)
{
    // Checking to see what the name of the feat is, and the row number
    /*if (DEBUG)
    {
        DoDebug("CheckManeuverPrereqs: nFeat: " + IntToString(nFeat));
        string sFeatName = GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", nFeat)));
        DoDebug("CheckManeuverPrereqs: sFeatName: " + sFeatName);
    }*/

    // Prestige classes can only access certain disciplines
    if(!_AllowedDiscipline(oPC, nClass, nDiscipline))
        return FALSE;

    // If this maneuver has a prereq, check for it
    if(nPrereqs)
        // if it returns false, exit, otherwise they can take the maneuver
        return _CheckPrereqsByDiscipline(oPC, nDiscipline, nPrereqs);

    // if you've reached this far then return TRUE
    return TRUE;
}

int GetIsManeuverSupernatural(int nMoveId)
{
    if(nMoveId == MOVE_DW_BLISTERING_FLOURISH
    || nMoveId == MOVE_DW_BURNING_BLADE
    || nMoveId == MOVE_DW_BURNING_BRAND
    || nMoveId == MOVE_DW_DEATH_MARK
    || nMoveId == MOVE_DW_DISTRACTING_EMBER
    || nMoveId == MOVE_DW_DRAGONS_FLAME
    || nMoveId == MOVE_DW_FAN_FLAMES
    || nMoveId == MOVE_DW_FIERY_ASSAULT
    || nMoveId == MOVE_DW_FIRE_RIPOSTE
    || nMoveId == MOVE_DW_FIRESNAKE
    || nMoveId == MOVE_DW_FLAMES_BLESSING
    || nMoveId == MOVE_DW_HATCHLINGS_FLAME
    || nMoveId == MOVE_DW_HOLOCAUST_CLOAK
    || nMoveId == MOVE_DW_INFERNO_BLADE
    || nMoveId == MOVE_DW_INFERNO_BLAST
    || nMoveId == MOVE_DW_LEAPING_FLAME
    || nMoveId == MOVE_DW_LINGERING_INFERNO
    || nMoveId == MOVE_DW_RING_FIRE
    || nMoveId == MOVE_DW_RISING_PHOENIX
    || nMoveId == MOVE_DW_SALAMANDER_CHARGE
    || nMoveId == MOVE_DW_SEARING_BLADE
    || nMoveId == MOVE_DW_SEARING_CHARGE
    || nMoveId == MOVE_DW_WYRMS_FLAME
    || nMoveId == MOVE_SH_BALANCE_SKY
    || nMoveId == MOVE_SH_CHILD_SHADOW
    || nMoveId == MOVE_SH_CLINGING_SHADOW
    || nMoveId == MOVE_SH_CLOAK_DECEPTION
    || nMoveId == MOVE_SH_ENERVATING_SHADOW
    || nMoveId == MOVE_SH_FIVE_SHADOW_CREEPING
    || nMoveId == MOVE_SH_GHOST_BLADE
    || nMoveId == MOVE_SH_OBSCURING_SHADOW_VEIL
    || nMoveId == MOVE_SH_SHADOW_BLADE_TECH
    || nMoveId == MOVE_SH_SHADOW_GARROTTE
    || nMoveId == MOVE_SH_SHADOW_NOOSE
    || nMoveId == MOVE_SH_STRENGTH_DRAINING)
        return TRUE;

    // If nothing returns TRUE, fail
    return FALSE;
}

int GetHasActiveStance(object oInitiator)
{
    int nStance = GetLocalInt(oInitiator, "TOBStanceOne");
    if(GetHasSpellEffect(nStance, oInitiator))
        return nStance;

    nStance = GetLocalInt(oInitiator, "TOBStanceTwo");
    if(GetHasSpellEffect(nStance, oInitiator))
        return nStance;

    return FALSE;
}

void RemoveStance(object oInitiator, int nStance)
{
    PRCRemoveEffectsFromSpell(oInitiator, nStance);

    //stances with special handling goes here
    if(nStance == MOVE_DS_AURA_CHAOS)
        DeleteLocalInt(oInitiator, "DSChaos");
    else if(nStance == MOVE_DS_PERFECT_ORDER)
        DeleteLocalInt(oInitiator, "DSPerfectOrder");
    else if(nStance == MOVE_DW_RISING_PHOENIX)
        RemoveItemProperty(GetPCSkin(oInitiator), ItemPropertyBonusFeat(IP_CONST_FEAT_RISING_PHOENIX));
    else if(nStance == MOVE_SH_ASSASSINS_STANCE)
    {
        DelayCommand(0.1, ExecuteScript("prc_sneak_att", oInitiator));
        if (DEBUG) DoDebug("Cleaning assassin's stance");
    }    
    else if(nStance == MOVE_MYSTIC_PHOENIX || nStance == MOVE_MYSTIC_PHOENIX_AUG)
    {
        if(DEBUG) DoDebug("Removing Mystic Phoenix Stance");
        DeleteLocalInt(oInitiator, "ToB_JPM_MystP");
    }
    else if(nStance == MOVE_FIREBIRD_STANCE || nStance == MOVE_FIREBIRD_STANCE_AUG)
    {
        if(DEBUG) DoDebug("Removing Firebird Stance");
        DeleteLocalInt(oInitiator, "ToB_JPM_FireB");
    }
    else if(nStance == MOVE_CHILD_SL_STANCE)
    {
        DeleteLocalInt(oInitiator, "SSN_CHILDSL_SETP");
        RemoveEventScript(oInitiator, EVENT_ONHEARTBEAT, "tob_ssn_childsl", TRUE, FALSE);
    }
}

void ClearStances(object oInitiator, int nDontClearMove)
{
    // Clears spell effects, will not clear DontClearMove
    // This is used to allow Warblades to have two stances.
    int nStance = GetLocalInt(oInitiator, "TOBStanceOne");
    if(GetHasSpellEffect(nStance, oInitiator) && nStance != nDontClearMove)
    {
        RemoveStance(oInitiator, nStance);
        DeleteLocalInt(oInitiator, "TOBStanceOne");
    }

    nStance = GetLocalInt(oInitiator, "TOBStanceTwo");
    if(GetHasSpellEffect(nStance, oInitiator) && nStance != nDontClearMove)
    {
        RemoveStance(oInitiator, nStance);
        DeleteLocalInt(oInitiator, "TOBStanceTwo");
    }
}

void MarkStanceActive(object oInitiator, int nStance)
{
    // If the first stance is active, use second
    // This should only be called with the first active when it is legal to have two stances
    if(GetLocalInt(oInitiator, "TOBStanceOne") > 0) SetLocalInt(oInitiator, "TOBStanceTwo", nStance);
    else SetLocalInt(oInitiator, "TOBStanceOne", nStance);
}

effect VersusSizeEffect(object oInitiator, effect eEffect, int nSize)
{
    // Right now this only deals with medium and small PCs
    int nPCSize = PRCGetCreatureSize(oInitiator);
    effect eLink;
    // Creatures larger than PC
    if (nSize == 1)
    {
        eLink = VersusRacialTypeEffect(eEffect, RACIAL_TYPE_ABERRATION);
        eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_CONSTRUCT));
        eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_DRAGON));
        eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_ELEMENTAL));
        eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_GIANT));
        eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_OUTSIDER));
        if (nPCSize == CREATURE_SIZE_SMALL)
        {
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_ANIMAL));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_BEAST));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_DWARF));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_ELF));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_HALFELF));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_HALFORC));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_HUMAN));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_HUMANOID_GOBLINOID));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_HUMANOID_MONSTROUS));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_HUMANOID_ORC));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_HUMANOID_REPTILIAN));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_MAGICAL_BEAST));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_OOZE));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_SHAPECHANGER));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_UNDEAD));
        }
    }// Smaller
    if (nSize == 0)
    {
        eLink = VersusRacialTypeEffect(eEffect, RACIAL_TYPE_FEY);
        eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_VERMIN));
        if (nPCSize == CREATURE_SIZE_MEDIUM)
        {
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_GNOME));
            eLink = EffectLinkEffects(eLink, VersusRacialTypeEffect(eEffect, RACIAL_TYPE_HALFLING));
        }
    }

    return eLink;
}

void InitiatorMovementCheck(object oPC, int nMoveId, float fFeet = 10.0)
{
    // Check to see if the WP is valid
    string sWPTag = "PRC_BMWP_" + GetName(oPC) + IntToString(nMoveId);
    object oTestWP = GetWaypointByTag(sWPTag);
    if (!GetIsObjectValid(oTestWP))
    {
        // Create waypoint for the movement
        CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", GetLocation(oPC), FALSE, sWPTag);
        if(DEBUG) DoDebug("InitiatorMovementCheck: WP for " + DebugObject2Str(oPC) + " didn't exist, creating. Tag: " + sWPTag);
    }
    // Start the recursive HB check for movement
    // Seeing if this solves some of the issues with it
    DelayCommand(2.0, _RecursiveStanceCheck(oPC, oTestWP, nMoveId, fFeet));
}

void DoDesertWindBoost(object oPC)
{
    if(DEBUG) DoDebug("DoDesertWindBoost running");
    
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (IPGetIsMeleeWeapon(oItem))
    {
        effect eVis = EffectLinkEffects(EffectVisualEffect(VFX_IMP_FLAME_M), EffectVisualEffect(VFX_IMP_PULSE_FIRE));
        SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);    
        // Add eventhook to the item
        AddEventScript(oItem, EVENT_ITEM_ONHIT, "tob_dw_onhit", TRUE, FALSE);
        DelayCommand(6.0, RemoveEventScript(oItem, EVENT_ITEM_ONHIT, "tob_dw_onhit", TRUE, FALSE));
        // Add the OnHit and vfx
        IPSafeAddItemProperty(oItem, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1), 6.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
        IPSafeAddItemProperty(oItem, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE), 6.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
        SetLocalInt(oPC, "DesertWindBoost", PRCGetSpellId());
        DelayCommand(6.0, DeleteLocalInt(oPC, "DesertWindBoost"));        
    }
    oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    if (IPGetIsMeleeWeapon(oItem))
    {
        // Add eventhook to the item
        AddEventScript(oItem, EVENT_ITEM_ONHIT, "tob_dw_onhit", TRUE, FALSE);
        DelayCommand(6.0, RemoveEventScript(oItem, EVENT_ITEM_ONHIT, "tob_dw_onhit", TRUE, FALSE));
        // Add the OnHit and vfx
        IPSafeAddItemProperty(oItem, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1), 6.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
        IPSafeAddItemProperty(oItem, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE), 6.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    }    
}

object GetCrusaderHealTarget(object oPC, float fDistance)
{
    object oReturn;
    int nTest, nCurrentMin = 100;
    location lTarget = GetLocation(oPC);
    object oTest = MyFirstObjectInShape(SHAPE_SPHERE, fDistance, lTarget);
    while(GetIsObjectValid(oTest))
    {
        if(GetIsFriend(oTest, oPC))
        {
            nTest = (GetCurrentHitPoints(oTest) * 100) / GetMaxHitPoints(oTest);
            // Check HP vs current biggest loss
            if(nTest < nCurrentMin && GetCurrentHitPoints(oTest) > 0 && !GetIsDead(oTest))
            {
                 nCurrentMin = nTest;
                 oReturn = oTest;
            }
        }
        //Get the next target in the specified area around the caster
        oTest = MyNextObjectInShape(SHAPE_SPHERE, fDistance, lTarget);
    }
    if(DEBUG) DoDebug("GetCrusaderHealTarget: oReturn " + GetName(oReturn));
    return oReturn;
}

int GetHasInsightfulStrike(object oInitiator)
{
    int nDiscToCheck = GetDisciplineByManeuver(PRCGetSpellId());
    int nFeat;
    switch(nDiscToCheck)
    {
        case DISCIPLINE_DESERT_WIND:  nFeat = FEAT_SS_DF_IS_DW; break;
        case DISCIPLINE_DIAMOND_MIND: nFeat = FEAT_SS_DF_IS_DM; break;
        case DISCIPLINE_SETTING_SUN:  nFeat = FEAT_SS_DF_IS_SS; break;
        case DISCIPLINE_SHADOW_HAND:  nFeat = FEAT_SS_DF_IS_SH; break;
        case DISCIPLINE_STONE_DRAGON: nFeat = FEAT_SS_DF_IS_SD; break;
        case DISCIPLINE_TIGER_CLAW:   nFeat = FEAT_SS_DF_IS_TC; break;
    }
    if(GetHasFeat(nFeat, oInitiator))
        return TRUE;

    return FALSE;
}

int GetHasDefensiveStance(object oInitiator, int nDiscipline)
{
    // Because this is only called from inside the proper stances
    // Its just a check to see if they should link in the save boost.
    int nFeat;
    switch(nDiscipline)
    {
        case DISCIPLINE_DESERT_WIND:  nFeat = FEAT_SS_DF_DS_DW; break;
        case DISCIPLINE_DIAMOND_MIND: nFeat = FEAT_SS_DF_DS_DM; break;
        case DISCIPLINE_SETTING_SUN:  nFeat = FEAT_SS_DF_DS_SS; break;
        case DISCIPLINE_SHADOW_HAND:  nFeat = FEAT_SS_DF_DS_SH; break;
        case DISCIPLINE_STONE_DRAGON: nFeat = FEAT_SS_DF_DS_SD; break;
        case DISCIPLINE_TIGER_CLAW:   nFeat = FEAT_SS_DF_DS_TC; break;
    }
    if(GetHasFeat(nFeat, oInitiator))
        return TRUE;

    return FALSE;
}

int TOBGetHasDiscipline(object oInitiator, int nDiscipline)
{
    switch(nDiscipline)
    {
        case DISCIPLINE_DEVOTED_SPIRIT: return GetLevelByClass(CLASS_TYPE_CRUSADER, oInitiator);
        case DISCIPLINE_DESERT_WIND:
        case DISCIPLINE_SETTING_SUN:
        case DISCIPLINE_SHADOW_HAND:    return GetLevelByClass(CLASS_TYPE_SWORDSAGE, oInitiator);
        case DISCIPLINE_IRON_HEART:     return GetLevelByClass(CLASS_TYPE_WARBLADE, oInitiator);
        case DISCIPLINE_DIAMOND_MIND:
        case DISCIPLINE_TIGER_CLAW:     return GetLevelByClass(CLASS_TYPE_SWORDSAGE, oInitiator) || GetLevelByClass(CLASS_TYPE_WARBLADE, oInitiator);
        case DISCIPLINE_WHITE_RAVEN:    return GetLevelByClass(CLASS_TYPE_CRUSADER, oInitiator) || GetLevelByClass(CLASS_TYPE_WARBLADE, oInitiator);
        case DISCIPLINE_STONE_DRAGON:   return GetLevelByClass(CLASS_TYPE_CRUSADER, oInitiator) || GetLevelByClass(CLASS_TYPE_SWORDSAGE, oInitiator) || GetLevelByClass(CLASS_TYPE_WARBLADE, oInitiator);
    }
    return FALSE;
}

int TOBGetHasDisciplineFocus(object oInitiator, int nDiscipline)
{
    int nFeat1, nFeat2, nFeat3;
    switch(nDiscipline)
    {
        case DISCIPLINE_DESERT_WIND:  nFeat1 = FEAT_SS_DF_DS_DW; nFeat2 = FEAT_SS_DF_IS_DW; nFeat3 = FEAT_SS_DF_WF_DW; break;
        case DISCIPLINE_DIAMOND_MIND: nFeat1 = FEAT_SS_DF_DS_DM; nFeat2 = FEAT_SS_DF_IS_DM; nFeat3 = FEAT_SS_DF_WF_DM; break;
        case DISCIPLINE_SETTING_SUN:  nFeat1 = FEAT_SS_DF_DS_SS; nFeat2 = FEAT_SS_DF_IS_SS; nFeat3 = FEAT_SS_DF_WF_SS; break;
        case DISCIPLINE_SHADOW_HAND:  nFeat1 = FEAT_SS_DF_DS_SH; nFeat2 = FEAT_SS_DF_IS_SH; nFeat3 = FEAT_SS_DF_WF_SH; break;
        case DISCIPLINE_STONE_DRAGON: nFeat1 = FEAT_SS_DF_DS_SD; nFeat2 = FEAT_SS_DF_IS_SD; nFeat3 = FEAT_SS_DF_WF_SD; break;
        case DISCIPLINE_TIGER_CLAW:   nFeat1 = FEAT_SS_DF_DS_TC; nFeat2 = FEAT_SS_DF_IS_TC; nFeat3 = FEAT_SS_DF_WF_TC; break;
    }
    if(GetHasFeat(nFeat1, oInitiator) || GetHasFeat(nFeat2, oInitiator) || GetHasFeat(nFeat3, oInitiator))
        return TRUE;

    // If none of those trigger.
    return FALSE;
}

int GetIsDisciplineWeapon(object oWeapon, int nDiscipline)
{
    int nType = GetBaseItemType(oWeapon);
    if(nDiscipline == DISCIPLINE_DESERT_WIND)
    {
        if(nType == BASE_ITEM_SCIMITAR
        || nType == BASE_ITEM_LIGHTMACE
        || nType == BASE_ITEM_SHORTSPEAR
        || nType == BASE_ITEM_LIGHT_PICK
        || nType == BASE_ITEM_FALCHION)
            return TRUE;
    }
    else if(nDiscipline == DISCIPLINE_DEVOTED_SPIRIT)
    {
        if(nType == BASE_ITEM_LONGSWORD
        || nType == BASE_ITEM_HEAVYFLAIL
        || nType == BASE_ITEM_MAUL
        || nType == BASE_ITEM_FALCHION)
            return TRUE;
    }
    else if(nDiscipline == DISCIPLINE_DIAMOND_MIND)
    {
        if(nType == BASE_ITEM_BASTARDSWORD
        || nType == BASE_ITEM_KATANA
        || nType == BASE_ITEM_SHORTSPEAR
        || nType == BASE_ITEM_RAPIER)
            return TRUE;
    }
    else if(nDiscipline == DISCIPLINE_IRON_HEART)
    {
        if(nType == BASE_ITEM_BASTARDSWORD
        || nType == BASE_ITEM_KATANA
        || nType == BASE_ITEM_LONGSWORD
        || nType == BASE_ITEM_TWOBLADEDSWORD
        || nType == BASE_ITEM_DWARVENWARAXE)
            return TRUE;
    }
    else if(nDiscipline == DISCIPLINE_SETTING_SUN)
    {
        // Invalid is empty handed / Unarmed strike
        if(nType == BASE_ITEM_INVALID
        || nType == BASE_ITEM_QUARTERSTAFF
        || nType == BASE_ITEM_MAGICSTAFF		
        || nType == BASE_ITEM_SHORTSWORD
        || nType == BASE_ITEM_NUNCHAKU)
            return TRUE;
    }
    else if(nDiscipline == DISCIPLINE_SHADOW_HAND)
    {
        // Invalid is empty handed / Unarmed strike
        if(nType == BASE_ITEM_DAGGER
        || nType == BASE_ITEM_INVALID
        || nType == BASE_ITEM_SHORTSWORD
        || nType == BASE_ITEM_SAI)
            return TRUE;
    }
    else if(nDiscipline == DISCIPLINE_STONE_DRAGON)
    {
        // Invalid is empty handed / Unarmed strike
        if(nType == BASE_ITEM_GREATAXE
        || nType == BASE_ITEM_INVALID
        || nType == BASE_ITEM_GREATSWORD
        || nType == BASE_ITEM_HEAVY_MACE)
            return TRUE;
    }
    else if(nDiscipline == DISCIPLINE_TIGER_CLAW)
    {
        // Invalid is empty handed / Unarmed strike
        if(nType == BASE_ITEM_KUKRI
        || nType == BASE_ITEM_KAMA
        || nType == BASE_ITEM_HANDAXE
        || nType == BASE_ITEM_GREATAXE
        || nType == BASE_ITEM_INVALID)
            return TRUE;
    }
    else if(nDiscipline == DISCIPLINE_WHITE_RAVEN)
    {
        if(nType == BASE_ITEM_BATTLEAXE
        || nType == BASE_ITEM_LONGSWORD
        || nType == BASE_ITEM_HALBERD
        || nType == BASE_ITEM_WARHAMMER
        || nType == BASE_ITEM_GREATSWORD)
            return TRUE;
    }

    // If none of those trigger.
    return FALSE;
}

int TOBSituationalAttackBonuses(object oInitiator, int nDiscipline, int nClass = CLASS_TYPE_INVALID)
{
    int nBonus = 0;
    if(GetLevelByClass(CLASS_TYPE_BLOODCLAW_MASTER, oInitiator) >= 4
    && nDiscipline == DISCIPLINE_TIGER_CLAW)
        nBonus += 1;

    return nBonus;
}

int GetDisciplineSkill(int nDiscipline)
{
    if(nDiscipline == DISCIPLINE_DESERT_WIND)
    {
            return SKILL_TUMBLE;
    }
    else if(nDiscipline == DISCIPLINE_DEVOTED_SPIRIT)
    {
            return SKILL_INTIMIDATE;
    }
    else if(nDiscipline == DISCIPLINE_DIAMOND_MIND)
    {
            return SKILL_CONCENTRATION;
    }
    else if(nDiscipline == DISCIPLINE_IRON_HEART)
    {
            return SKILL_BALANCE;
    }
    else if(nDiscipline == DISCIPLINE_SETTING_SUN)
    {
            return SKILL_SENSE_MOTIVE;
    }
    else if(nDiscipline == DISCIPLINE_SHADOW_HAND)
    {
            return SKILL_HIDE;
    }
    else if(nDiscipline == DISCIPLINE_STONE_DRAGON)
    {
            return SKILL_BALANCE;
    }
    else if(nDiscipline == DISCIPLINE_TIGER_CLAW)
    {
            return SKILL_JUMP;
    }
    else if(nDiscipline == DISCIPLINE_WHITE_RAVEN)
    {
            return SKILL_PERSUADE;
    }

    // If none of those trigger.
    return -1;    
}

int BladeMeditationFeat(object oInitiator)
{
         if(GetHasFeat(FEAT_BLADE_MEDITATION_DESERT_WIND   , oInitiator)) return DISCIPLINE_DESERT_WIND   ;
    else if(GetHasFeat(FEAT_BLADE_MEDITATION_DEVOTED_SPIRIT, oInitiator)) return DISCIPLINE_DEVOTED_SPIRIT;
    else if(GetHasFeat(FEAT_BLADE_MEDITATION_DIAMOND_MIND  , oInitiator)) return DISCIPLINE_DIAMOND_MIND  ;
    else if(GetHasFeat(FEAT_BLADE_MEDITATION_IRON_HEART    , oInitiator)) return DISCIPLINE_IRON_HEART    ;
    else if(GetHasFeat(FEAT_BLADE_MEDITATION_SETTING_SUN   , oInitiator)) return DISCIPLINE_SETTING_SUN   ;
    else if(GetHasFeat(FEAT_BLADE_MEDITATION_SHADOW_HAND   , oInitiator)) return DISCIPLINE_SHADOW_HAND   ;
    else if(GetHasFeat(FEAT_BLADE_MEDITATION_STONE_DRAGON  , oInitiator)) return DISCIPLINE_STONE_DRAGON  ;
    else if(GetHasFeat(FEAT_BLADE_MEDITATION_TIGER_CLAW    , oInitiator)) return DISCIPLINE_TIGER_CLAW    ;
    else if(GetHasFeat(FEAT_BLADE_MEDITATION_WHITE_RAVEN   , oInitiator)) return DISCIPLINE_WHITE_RAVEN   ;
    
    return -1;
}

int BladeMeditationDamage(object oInitiator, int nMoveId)
{
    int nDisc = BladeMeditationFeat(oInitiator);
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oInitiator);
    if (nDisc == GetDisciplineByManeuver(nMoveId) && GetIsDisciplineWeapon(oWeapon, nDisc))
        return 1;
        
    return -1;
}

int HasBladeMeditationForDiscipline(object oInitiator, int nDiscipline)
{
    if (!GetIsObjectValid(oInitiator))
        return FALSE;

    int nFeatDiscipline = BladeMeditationFeat(oInitiator);

    // If the discipline for Blade Meditation matches the one we're checking, return true
    if (nFeatDiscipline == nDiscipline)
        return TRUE;

    return FALSE;
}