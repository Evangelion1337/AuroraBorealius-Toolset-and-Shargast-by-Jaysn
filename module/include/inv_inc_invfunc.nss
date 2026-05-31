//::///////////////////////////////////////////////
//:: Invocation include: Miscellaneous
//:: inv_inc_invfunc
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to Invocation implementation.

    Also acts as inclusion nexus for the general
    invocation includes. In other words, don't include
    them directly in your scripts, instead include this.

    @author Fox
    @date   Created - 2008.1.25
	
	Updated for .35 by Jaysyn 2023/03/10
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int    INVOCATION_DRACONIC    = 1;
const int    INVOCATION_WARLOCK     = 2;

const int    INVOCATION_LEAST       = 2;
const int    INVOCATION_LESSER      = 4;
const int    INVOCATION_GREATER     = 6;
const int    INVOCATION_DARK        = 8;

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

//:: Updates the Invocation DC for Ability Focus feats.
int InvokerAbilityFocus(object oPC, int nEssence, int nEssence2 = -1);

/**
 * Determines from what class's invocation list the currently casted
 * invocation is cast from.
 *
 * @param oInvoker  A creature invoking at this moment
 * @return            CLASS_TYPE_* constant of the class
 */
int GetInvokingClass(object oInvoker = OBJECT_SELF);

/**
 * Determines the given creature's Invoker level. If a class is specified,
 * then returns the Invoker level for that class. Otherwise, returns
 * the Invoker level for the currently active invocation.
 *
 * @param oInvoker          The creature whose Invoker level to determine
 * @param nSpecificClass    The class to determine the creature's Invoker
 *                          level in.
 * @param bPracticedInvoker If this is set, it will add the bunus from
 *                          Practiced Invoker feat.
 * @return                  The Invoker level
 */
int GetInvokerLevel(object oInvoker = OBJECT_SELF, int nSpecificClass = CLASS_TYPE_INVALID, int bPracticedInvoker = TRUE);

/**
 * Determines whether a given creature uses Invocations.
 * Requires either levels in an invocation-related class or
 * natural Invocation ability based on race.
 *
 * @param oCreature Creature to test
 * @return          TRUE if the creature can use Invocations, FALSE otherwise.
 */
int GetIsInvocationUser(object oCreature);

/**
 * Determines the given creature's highest undmodified Invoker level among it's
 * invoking classes.
 *
 * @param oCreature Creature whose highest Invoker level to determine
 * @return          The highest unmodified Invoker level the creature can have
 */
int GetHighestInvokerLevel(object oCreature);

/**
 * Determines whether a given class is an invocation-related class or not.
 *
 * @param nClass CLASS_TYPE_* of the class to test
 * @return       TRUE if the class is an invocation-related class, FALSE otherwise
 */
int GetIsInvocationClass(int nClass);

/**
 * Gets the level of the invocation being currently cast.
 * WARNING: Return value is not defined when an invocation is not being cast.
 *
 * @param oInvoker    The creature currently casting an invocation
 * @return            The level of the invocation being cast
 */
int GetInvocationLevel(object oInvoker);

/**
 * Returns the name of the invocation
 *
 * @param nSpellId        SpellId of the invocation
 */
string GetInvocationName(int nSpellId);

/**
 * Calculates how many invoker levels are gained by a given creature from
 * it's levels in prestige classes.
 *
 * @param oCreature Creature to calculate added invoker levels for
 * @return          The number of invoker levels gained
 */
int GetInvocationPRCLevels(object oCaster);

/**
 * Determines which of the character's classes is their highest or first invocation
 * casting class, if any. This is the one which gains invoker level raise benefits
 * from prestige classes.
 *
 * @param oCreature Creature whose classes to test
 * @return          CLASS_TYPE_* of the first invocation casting class,
 *                  CLASS_TYPE_INVALID if the creature does not possess any.
 */
int GetPrimaryInvocationClass(object oCreature = OBJECT_SELF);

/**
 * Determines the position of a creature's first invocation casting class, if any.
 *
 * @param oCreature Creature whose classes to test
 * @return          The position of the first invocation class {1, 2, 3} or 0 if
 *                  the creature possesses no levels in invocation classes.
 */
int GetFirstInvocationClassPosition(object oCreature = OBJECT_SELF);

/**
 * Ruterns the number of damage dices that oInvokers eldritch blast has
 *
 * @param oInvoker      Creature whose blast to test
 * @param nInvokerLevel Invoker level
 * @return              The number of damage dices
 */
int GetBlastDamageDices(object oInvoker, int nInvokerLevel);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

//#include "prc_alterations"
#include "prc_feat_const"
#include "inv_inc_invknown"
#include "inv_inc_invoke"
#include "inv_inc_blast"
#include "prc_add_spell_dc"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

//:: Updates the Invocation DC for Ability Focus feats.
int InvokerAbilityFocus(object oPC, int nEssence, int nEssence2 = -1)
{
    int nBonus = 0;

    // Check for the shape
    switch(nEssence)
    {
        case INVOKE_ELDRITCH_BLAST:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_BLAST, oPC)) nBonus += 2;
            break;
        case INVOKE_ELDRITCH_CHAIN:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_CHAIN, oPC)) nBonus += 2;
            break;
        case INVOKE_ELDRITCH_CONE:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_CONE, oPC)) nBonus += 2;
            break;
        case INVOKE_ELDRITCH_DOOM:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_DOOM, oPC)) nBonus += 2;
            break;	
		case INVOKE_ELDRITCH_GLAIVE:
			if (GetHasFeat(FEAT_ABFOC_ELDRITCH_GLAIVE, oPC)) nBonus += 2;
			break;				
        case INVOKE_ELDRITCH_LINE:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_LINE, oPC)) nBonus += 2;
            break;		
        case INVOKE_ELDRITCH_SPEAR:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_SPEAR, oPC)) nBonus += 2;
            break;				
		case INVOKE_BRIMSTONE_BLAST:
			if (GetHasFeat(FEAT_ABFOC_BRIMSTONE_BLAST, oPC)) nBonus += 2;
			break;
		case INVOKE_NOXIOUS_BLAST:
			if (GetHasFeat(FEAT_ABFOC_NOXIOUS_BLAST, oPC)) nBonus += 2;
			break;
		case INVOKE_FRIGHTFUL_BLAST:
			if (GetHasFeat(FEAT_ABFOC_FRIGHTFUL_BLAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_SICKENING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_SICKENING_BLAST, oPC)) nBonus += 2;
			break;
		case INVOKE_HELLRIME_BLAST:
			if (GetHasFeat(FEAT_ABFOC_HELLRIME_BLAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_BEWITCHING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_BEWITCHING_BLAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_BINDING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_BINDING_BLAST, oPC)) nBonus += 2;
			break;			
		case INVOKE_HINDERING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_HINDERING_BLAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_PENETRATING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_PENETRATING_BLAST, oPC)) nBonus += 2;
			break;		
		case INVOKE_UTTERDARK_BLAST:
			if (GetHasFeat(FEAT_ABFOC_UTTERDARK_BLAST, oPC)) nBonus += 2;
			break;				
		case INVOKE_INCARNUM_BLAST:
			if (GetHasFeat(FEAT_ABFOC_INCARNUM_BLAST, oPC)) nBonus += 2;
			break;				
		case INVOKE_HAMMER_BLAST:
			if (GetHasFeat(FEAT_ABFOC_HAMMER_BLAST, oPC)) nBonus += 2;
			break;
		// case INVOKE_VITRIOLIC_BLAST:
			// if (GetHasFeat(FEAT_ABFOC_VITRIOLIC_BLAST, oPC)) nBonus += 2;
			// break;
		case INVOKE_BANEFUL_BLAST_ABERRATION:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_ABERRATION, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_BEAST:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_BEAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_CONSTRUCT:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_CONSTRUCT, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_DRAGON:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_DRAGON, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_DWARF:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_DWARF, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_ELEMENTAL:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_ELEMENTAL, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_ELF:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_ELF, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_FEY:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_FEY, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_GIANT:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_GIANT, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_GOBLINOID:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_GOBLINOID, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_GNOME:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_GNOME, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_HALFLING:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_HALFLING, oPC)) nBonus += 2;
			break;				
		case INVOKE_BANEFUL_BLAST_HUMAN:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_HUMAN, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_MONSTROUS:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_MONSTROUS, oPC)) nBonus += 2;
			break;		
		// case INVOKE_BANEFUL_BLAST_OOZE:
			// if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_OOZE, oPC)) nBonus += 2;
			// break;	
		case INVOKE_BANEFUL_BLAST_ORC:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_ORC, oPC)) nBonus += 2;
			break;		
		case INVOKE_BANEFUL_BLAST_OUTSIDER:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_OUTSIDER, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_PLANT:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_PLANT, oPC)) nBonus += 2;
			break;		
		case INVOKE_BANEFUL_BLAST_REPTILIAN:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_REPTILIAN, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_SHAPECHANGER:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_SHAPECHANGER, oPC)) nBonus += 2;
			break;		
		case INVOKE_BANEFUL_BLAST_UNDEAD:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_UNDEAD, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_VERMIN:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_VERMIN, oPC)) nBonus += 2;
			break;			
    }

    // Check for the secondary shape or essence component
    switch(nEssence2)
    {
         case INVOKE_ELDRITCH_BLAST:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_BLAST, oPC)) nBonus += 2;
            break;
        case INVOKE_ELDRITCH_CHAIN:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_CHAIN, oPC)) nBonus += 2;
            break;
        case INVOKE_ELDRITCH_CONE:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_CONE, oPC)) nBonus += 2;
            break;
        case INVOKE_ELDRITCH_DOOM:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_DOOM, oPC)) nBonus += 2;
            break;	
		case INVOKE_ELDRITCH_GLAIVE:
			if (GetHasFeat(FEAT_ABFOC_ELDRITCH_GLAIVE, oPC)) nBonus += 2;
			break;				
        case INVOKE_ELDRITCH_LINE:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_LINE, oPC)) nBonus += 2;
            break;		
        case INVOKE_ELDRITCH_SPEAR:
            if (GetHasFeat(FEAT_ABFOC_ELDRITCH_SPEAR, oPC)) nBonus += 2;
            break;				
		case INVOKE_BRIMSTONE_BLAST:
			if (GetHasFeat(FEAT_ABFOC_BRIMSTONE_BLAST, oPC)) nBonus += 2;
			break;
		case INVOKE_NOXIOUS_BLAST:
			if (GetHasFeat(FEAT_ABFOC_NOXIOUS_BLAST, oPC)) nBonus += 2;
			break;
		case INVOKE_FRIGHTFUL_BLAST:
			if (GetHasFeat(FEAT_ABFOC_FRIGHTFUL_BLAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_SICKENING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_SICKENING_BLAST, oPC)) nBonus += 2;
			break;
		case INVOKE_HELLRIME_BLAST:
			if (GetHasFeat(FEAT_ABFOC_HELLRIME_BLAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_BEWITCHING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_BEWITCHING_BLAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_BINDING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_BINDING_BLAST, oPC)) nBonus += 2;
			break;			
		case INVOKE_HINDERING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_HINDERING_BLAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_PENETRATING_BLAST:
			if (GetHasFeat(FEAT_ABFOC_PENETRATING_BLAST, oPC)) nBonus += 2;
			break;		
		case INVOKE_UTTERDARK_BLAST:
			if (GetHasFeat(FEAT_ABFOC_UTTERDARK_BLAST, oPC)) nBonus += 2;
			break;				
		case INVOKE_INCARNUM_BLAST:
			if (GetHasFeat(FEAT_ABFOC_INCARNUM_BLAST, oPC)) nBonus += 2;
			break;				
		case INVOKE_HAMMER_BLAST:
			if (GetHasFeat(FEAT_ABFOC_HAMMER_BLAST, oPC)) nBonus += 2;
			break;
		// case INVOKE_VITRIOLIC_BLAST:
			// if (GetHasFeat(FEAT_ABFOC_VITRIOLIC_BLAST, oPC)) nBonus += 2;
			// break;
		case INVOKE_BANEFUL_BLAST_ABERRATION:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_ABERRATION, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_BEAST:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_BEAST, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_CONSTRUCT:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_CONSTRUCT, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_DRAGON:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_DRAGON, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_DWARF:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_DWARF, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_ELEMENTAL:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_ELEMENTAL, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_ELF:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_ELF, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_FEY:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_FEY, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_GIANT:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_GIANT, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_GOBLINOID:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_GOBLINOID, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_GNOME:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_GNOME, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_HALFLING:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_HALFLING, oPC)) nBonus += 2;
			break;				
		case INVOKE_BANEFUL_BLAST_HUMAN:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_HUMAN, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_MONSTROUS:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_MONSTROUS, oPC)) nBonus += 2;
			break;		
		// case INVOKE_BANEFUL_BLAST_OOZE:
			// if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_OOZE, oPC)) nBonus += 2;
			// break;	
		case INVOKE_BANEFUL_BLAST_ORC:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_ORC, oPC)) nBonus += 2;
			break;		
		case INVOKE_BANEFUL_BLAST_OUTSIDER:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_OUTSIDER, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_PLANT:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_PLANT, oPC)) nBonus += 2;
			break;		
		case INVOKE_BANEFUL_BLAST_REPTILIAN:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_REPTILIAN, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_SHAPECHANGER:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_SHAPECHANGER, oPC)) nBonus += 2;
			break;		
		case INVOKE_BANEFUL_BLAST_UNDEAD:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_UNDEAD, oPC)) nBonus += 2;
			break;	
		case INVOKE_BANEFUL_BLAST_VERMIN:
			if (GetHasFeat(FEAT_ABFOC_BANEFUL_BLAST_VERMIN, oPC)) nBonus += 2;
			break;				
    }

    return nBonus;
}

int GetInvokingClass(object oInvoker = OBJECT_SELF)
{
    return GetLocalInt(oInvoker, PRC_INVOKING_CLASS) - 1;
}

/*int PracticedInvoker(object oInvoker, int iInvokingClass, int iInvokingLevels)
{
    int nFeat;
    int iAdjustment = GetHitDice(oInvoker) - iInvokingLevels;
    if(iAdjustment > 4) iAdjustment = 4;
    if(iAdjustment < 0) iAdjustment = 0;

    switch(iInvokingClass)
    {
        case CLASS_TYPE_DRAGONFIRE_ADEPT: nFeat = FEAT_PRACTICED_INVOKER_DRAGONFIRE_ADEPT; break;
        case CLASS_TYPE_WARLOCK:          nFeat = FEAT_PRACTICED_INVOKER_WARLOCK;          break;
        default: return 0;
    }

    if(GetHasFeat(nFeat, oInvoker))
        return iAdjustment;

    return 0;
}*/

int GetInvokerLevel(object oInvoker = OBJECT_SELF, int nSpecificClass = CLASS_TYPE_INVALID, int bPracticedInvoker = TRUE)
{
    int nAdjust = GetLocalInt(oInvoker, PRC_CASTERLEVEL_ADJUSTMENT);
    int nLevel = GetLocalInt(oInvoker, PRC_CASTERLEVEL_OVERRIDE);

    // For when you want to assign the caster level.
    if(nLevel)
    {
        if(DEBUG) SendMessageToPC(oInvoker, "Forced-level Invoking at level " + IntToString(GetCasterLevel(oInvoker)));
        //DelayCommand(1.0, DeleteLocalInt(oInvoker, PRC_CASTERLEVEL_OVERRIDE));
        return nLevel + nAdjust;
    }

    if(nSpecificClass == CLASS_TYPE_INVALID)
        nSpecificClass = GetInvokingClass(oInvoker);

    if(nSpecificClass != -1)
    {
        if(!GetIsInvocationClass(nSpecificClass))
            return 0;

        if(nSpecificClass == CLASS_TYPE_DRAGON_SHAMAN)
            nLevel = PRCMax(GetLevelByClass(nSpecificClass, oInvoker) - 4, 1); // Can't go below 1
        else
            nLevel = GetLevelByClass(nSpecificClass, oInvoker);
        if(DEBUG) DoDebug("Invoker Class Level is: " + IntToString(nLevel));
        if(GetPrimaryInvocationClass(oInvoker) == nSpecificClass)
        {
            //Invoker level is class level + any arcane spellcasting or invoking levels in any PRCs
            nLevel += GetInvocationPRCLevels(oInvoker);
        }
        /*if(bPracticedInvoker)
            nLevel += PracticedInvoker(oInvoker, nSpecificClass, nLevel);*/
    }
    else
        nLevel = GetLevelByClass(GetPrimaryInvocationClass(oInvoker), oInvoker);

    nLevel += nAdjust;
    SetLocalInt(oInvoker, "InvokerLevel", nLevel);
    return nLevel;
}

int GetIsInvocationUser(object oCreature)
{
    return !!(GetLevelByClass(CLASS_TYPE_DRAGONFIRE_ADEPT, oCreature) ||
              GetLevelByClass(CLASS_TYPE_WARLOCK, oCreature) ||
              GetLevelByClass(CLASS_TYPE_DRAGON_SHAMAN, oCreature)
             );
}

int GetHighestInvokerLevel(object oCreature)
{
	int n = 0;
	int nHighest;
	int nTemp;
	
    while(n <= 8)
	{
		if(GetClassByPosition(n, oCreature) != CLASS_TYPE_INVALID)
		{
			nTemp = GetInvokerLevel(oCreature, GetClassByPosition(n, oCreature));
			
			if(nTemp > nHighest) 
				nHighest = nTemp;
		}
	n++;

	}
	
	return nHighest;
}

/* int GetHighestInvokerLevel(object oCreature)
{
    return PRCMax(PRCMax(GetClassByPosition(1, oCreature) != CLASS_TYPE_INVALID ? GetInvokerLevel(oCreature, GetClassByPosition(1, oCreature)) : 0,
                   GetClassByPosition(2, oCreature) != CLASS_TYPE_INVALID ? GetInvokerLevel(oCreature, GetClassByPosition(2, oCreature)) : 0
                   ),
               GetClassByPosition(3, oCreature) != CLASS_TYPE_INVALID ? GetInvokerLevel(oCreature, GetClassByPosition(3, oCreature)) : 0
               );
} */

int GetIsInvocationClass(int nClass)
{
    int bTest = nClass == CLASS_TYPE_DRAGONFIRE_ADEPT
             || nClass == CLASS_TYPE_WARLOCK
             || nClass == CLASS_TYPE_DRAGON_SHAMAN;
    return bTest;
}

int GetInvocationLevel(object oInvoker)
{
    return GetLocalInt(oInvoker, PRC_INVOCATION_LEVEL);
}

string GetInvocationName(int nSpellId)
{
    return GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId)));
}

int GetInvocationPRCLevels(object oCaster)
{
    int nLevel = GetLevelByClass(CLASS_TYPE_HELLFIRE_WARLOCK, oCaster)
               + GetLevelByClass(CLASS_TYPE_ELDRITCH_DISCIPLE, oCaster)
               + GetLevelByClass(CLASS_TYPE_ELDRITCH_THEURGE, oCaster);

//:: Some Arcane PrCs boost invocations
/*     if(GetLocalInt(oCaster, "INV_Caster") == 2)
        nLevel += (GetLevelByClass(CLASS_TYPE_ACOLYTE, oCaster) + 1) / 2
				+ (GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oCaster) + 1) / 2
				+ GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oCaster)
				+ GetLevelByClass(CLASS_TYPE_MAESTER, oCaster)
				+ (GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oCaster) + 1) / 2; */
				
	if(GetLocalInt(oCaster, "INV_Caster") == 2)
	{
	//:: Abjurant Champion Invoking
		if(GetHasFeat(FEAT_ABCHAMP_INVOKING_WARLOCK, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ABJURANT_CHAMPION, oCaster);
		
		if(GetHasFeat(FEAT_ABCHAMP_INVOKING_DFA, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ABJURANT_CHAMPION, oCaster);	
		
		if(GetHasFeat(FEAT_ABCHAMP_INVOKING_DRAGON_SHAMAN, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ABJURANT_CHAMPION, oCaster);
		
	//:: Acolyte of the Skin Invoking
		if(GetHasFeat(FEAT_AOTS_INVOKING_WARLOCK, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_ACOLYTE, oCaster) + 1) / 2;
		
		if(GetHasFeat(FEAT_AOTS_INVOKING_DFA, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_ACOLYTE, oCaster) + 1) / 2;

	//:: Anima Mage Invoking		
		if(GetHasFeat(FEAT_ANIMA_INVOKING_WARLOCK, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ANIMA_MAGE, oCaster);
		
		if(GetHasFeat(FEAT_ANIMA_INVOKING_DFA, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ANIMA_MAGE, oCaster);	
		
	//:: Arcane Trickster Invoking		
		if(GetHasFeat(FEAT_ARCTRICK_INVOKING_WARLOCK, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ARCTRICK, oCaster);
		
		if(GetHasFeat(FEAT_ARCTRICK_INVOKING_DFA, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ARCTRICK, oCaster);		
		
	//:: Disciple of Asmodeus Invoking
		if(GetHasFeat(FEAT_ASMODEUS_INVOKING_WARLOCK, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oCaster) + 1) / 2;
		
		if(GetHasFeat(FEAT_ASMODEUS_INVOKING_DFA, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oCaster) + 1) / 2;	
		
		if(GetHasFeat(FEAT_ASMODEUS_INVOKING_DRAGON_SHAMAN, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oCaster) + 1) / 2;
		
	//:: Blood Magus Invoking		
		if(GetHasFeat(FEAT_BLDMAGUS_INVOKING_WARLOCK, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_BLOOD_MAGUS, oCaster) + 1) / 2;
		
		if(GetHasFeat(FEAT_BLDMAGUS_INVOKING_DFA, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_BLOOD_MAGUS, oCaster) + 1) / 2;
		
	//:: Enlightened Fist Invoking
		if(GetHasFeat(FEAT_ENLIGHTENEDFIST_INVOKING_WARLOCK, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oCaster);
		
		if(GetHasFeat(FEAT_ENLIGHTENEDFIST_INVOKING_DFA, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oCaster);	
		
		if(GetHasFeat(FEAT_ENLIGHTENEDFIST_INVOKING_DRAGON_SHAMAN, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oCaster);		
		
	//:: Maester Invoking		
		if(GetHasFeat(FEAT_MAESTER_INVOKING_WARLOCK, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_MAESTER, oCaster);
		
		if(GetHasFeat(FEAT_MAESTER_INVOKING_DFA, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_MAESTER, oCaster);
		
	//:: Talon of Tiamat Invoking
		if(GetHasFeat(FEAT_TIAMAT_INVOKING_WARLOCK, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oCaster) + 1) / 2;
		
		if(GetHasFeat(FEAT_TIAMAT_INVOKING_DFA, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oCaster) + 1) / 2;	
		
		if(GetHasFeat(FEAT_TIAMAT_INVOKING_DRAGON_SHAMAN, oCaster))
			nLevel += (GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oCaster) + 1) / 2;		
		
	//:: Unseen Seer Invoking
		if(GetHasFeat(FEAT_UNSEEN_INVOKING_WARLOCK, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oCaster);
		
		if(GetHasFeat(FEAT_UNSEEN_INVOKING_DFA, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oCaster);	
		
		if(GetHasFeat(FEAT_UNSEEN_INVOKING_DRAGON_SHAMAN, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oCaster);

	//:: Virtuoso Invoking
		if(GetHasFeat(FEAT_VIRTUOSO_INVOKING_WARLOCK, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_VIRTUOSO, oCaster);
		
		if(GetHasFeat(FEAT_VIRTUOSO_INVOKING_DFA, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_VIRTUOSO, oCaster);	
		
		if(GetHasFeat(FEAT_VIRTUOSO_INVOKING_DRAGON_SHAMAN, oCaster))
			nLevel += GetLevelByClass(CLASS_TYPE_VIRTUOSO, oCaster);
		
	//:: Wild Mage Invoking
		if(GetHasFeat(FEAT_WILDMAGE_INVOKING_WARLOCK, oCaster))
		{
			int nClass = GetLevelByClass(CLASS_TYPE_WILD_MAGE, oCaster);
			if (nClass) 
				nLevel += nClass - 3 + d6();
		}		
		if(GetHasFeat(FEAT_WILDMAGE_INVOKING_DFA, oCaster))
		{
			int nClass = GetLevelByClass(CLASS_TYPE_WILD_MAGE, oCaster);
			if (nClass) 
				nLevel += nClass - 3 + d6();
		}		
		if(GetHasFeat(FEAT_WILDMAGE_INVOKING_DRAGON_SHAMAN, oCaster))
		{
			int nClass = GetLevelByClass(CLASS_TYPE_WILD_MAGE, oCaster);
			if (nClass) 
				nLevel += nClass - 3 + d6();
		}
	}
		
    return nLevel;
}

int GetPrimaryInvocationClass(object oCreature = OBJECT_SELF)
{
    int nClass;

    if(GetPRCSwitch(PRC_CASTERLEVEL_FIRST_CLASS_RULE))
    {
        int nInvocationPos = GetFirstInvocationClassPosition(oCreature);
        if (!nInvocationPos) return CLASS_TYPE_INVALID; // no invoking class

        nClass = GetClassByPosition(nInvocationPos, oCreature);
    }
    else
    {
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
		
        if(GetIsInvocationClass(nClass1)) nClass1Lvl = GetLevelByClass(nClass1, oCreature);
        if(GetIsInvocationClass(nClass2)) nClass2Lvl = GetLevelByClass(nClass2, oCreature);
        if(GetIsInvocationClass(nClass3)) nClass3Lvl = GetLevelByClass(nClass3, oCreature);
		if(GetIsInvocationClass(nClass4)) nClass4Lvl = GetLevelByClass(nClass4, oCreature);
		if(GetIsInvocationClass(nClass5)) nClass5Lvl = GetLevelByClass(nClass5, oCreature);
		if(GetIsInvocationClass(nClass6)) nClass6Lvl = GetLevelByClass(nClass6, oCreature);
		if(GetIsInvocationClass(nClass7)) nClass7Lvl = GetLevelByClass(nClass7, oCreature);
		if(GetIsInvocationClass(nClass8)) nClass8Lvl = GetLevelByClass(nClass8, oCreature);

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

int GetFirstInvocationClassPosition(object oCreature = OBJECT_SELF)
{
    if (GetIsInvocationClass(GetClassByPosition(1, oCreature)))
        return 1;
    if (GetIsInvocationClass(GetClassByPosition(2, oCreature)))
        return 2;
    if (GetIsInvocationClass(GetClassByPosition(3, oCreature)))
        return 3;
    if (GetIsInvocationClass(GetClassByPosition(4, oCreature)))
        return 4;
	if (GetIsInvocationClass(GetClassByPosition(5, oCreature)))
        return 5;
	if (GetIsInvocationClass(GetClassByPosition(6, oCreature)))
        return 6;	
	if (GetIsInvocationClass(GetClassByPosition(7, oCreature)))
        return 7;	
	if (GetIsInvocationClass(GetClassByPosition(8, oCreature)))
        return 8;	
	
    return 0;
}

int GetInvocationSaveDC(object oTarget, object oCaster, int nSpellID = -1)
{
    int nDC;
    // For when you want to assign the caster DC
    //this does not take feat/race/class into account, it is an absolute override
    if (GetLocalInt(oCaster, PRC_DC_TOTAL_OVERRIDE) != 0)
    {
        nDC = GetLocalInt(oCaster, PRC_DC_TOTAL_OVERRIDE);
        DoDebug("Forced-DC PRC_DC_TOTAL_OVERRIDE casting at DC " + IntToString(nDC));
        return nDC;
    }
    // For when you want to assign the caster DC
    //this does take feat/race/class into account, it only overrides the baseDC
    if(GetLocalInt(oCaster, PRC_DC_BASE_OVERRIDE) > 0)
    {
        nDC = GetLocalInt(oCaster, PRC_DC_BASE_OVERRIDE);
        if(DEBUG) DoDebug("Forced Base-DC casting at DC " + IntToString(nDC));
    }
    else
    {
        if(nSpellID == -1) nSpellID = PRCGetSpellId();
        //10+spelllevel+stat(cha default)
        nDC = 10;
        nDC += StringToInt(Get2DACache("Spells", "Innate", nSpellID));
        nDC += GetAbilityModifier(ABILITY_CHARISMA, oCaster);
    }
    nDC += GetChangesToSaveDC(oTarget, oCaster, nSpellID, 0);

    return nDC;
}

void ClearInvocationLocalVars(object oPC)
{
    //Invocations
    if (DEBUG) DoDebug("Clearing invocation flags");
    DeleteLocalObject(oPC, "ChillingFog");
    //Endure Exposure wearing off
    array_delete(oPC, "BreathProtected");
    DeleteLocalInt(oPC, "DragonWard");

    //cleaning targets of Endure exposure cast by resting caster
    if (array_exists(oPC, "BreathProtectTargets"))
    {
        if(DEBUG) DoDebug("Checking for casts of Endure Exposure");
        int nBPTIndex = 0;
        int bCasterDone = FALSE;
        int bTargetDone = FALSE;
        object oBreathTarget;
        while(!bCasterDone)
        {
                oBreathTarget = array_get_object(oPC, "BreathProtectTargets", nBPTIndex);
                if(DEBUG) DoDebug("Possible target: " + GetName(oBreathTarget) + " - " + ObjectToString(oBreathTarget));
		if(oBreathTarget != OBJECT_INVALID)
	    	{
                      //replace caster with target... always immune to own breath, so good way to erase caster from array without deleting whole array
		      int nBPIndex = 0;			      

                      while(!bTargetDone)
                      {
			      if(DEBUG) DoDebug("Checking " + GetName(oBreathTarget));
			      //if it matches, remove and end
			      if(array_get_object(oBreathTarget, "BreathProtected", nBPIndex) == oPC)
			      {
				        array_set_object(oBreathTarget, "BreathProtected", nBPIndex, oBreathTarget);
                                        bTargetDone = TRUE;
                                        if(DEBUG) DoDebug("Found caster, clearing.");
			      }
			      //if it is not end of array, keep going
			      else if(array_get_object(oBreathTarget, "BreathProtected", nBPTIndex) != OBJECT_INVALID)
			      {
				       nBPIndex++;
			      }  
                              else
                                       bTargetDone = TRUE;

                      }

		      nBPTIndex++;
                      bTargetDone = FALSE;

		}
		else
                {
		      array_delete(oPC, "BreathProtectTargets");
                      bCasterDone = TRUE;
                }
     	}
    }
}

// Test main
// void main(){}
