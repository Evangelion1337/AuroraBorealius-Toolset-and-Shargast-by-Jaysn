//::///////////////////////////////////////////////
//:: Shadowcasting main include: Miscellaneous
//:: shd_inc_shdfunc
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to Shadowcasting.

    Also acts as inclusion nexus for the general
    shadowcasting includes. In other words, don't include
    them directly in your scripts, instead include this.

    @author Stratovarius
    @date   Created - 2019.02.08
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//:: Updated for .35 by Jaysyn 2023/10/19

//:: Test Void
// void main (){}

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines from what class's mystery list the currently being shadowcast
 * mystery is shadowcast from.
 *
 * @param oShadow A creature shadowcasting a mystery at this moment
 * @return            CLASS_TYPE_* constant of the class
 */
int GetShadowcastingClass(object oShadow = OBJECT_SELF);

/**
 * Determines the given creature's Shadowcaster level. If a class is specified,
 * then returns the Shadowcaster level for that class. Otherwise, returns
 * the Shadowcaster level for the currently active mystery.
 *
 * @param oShadow   The creature whose Shadowcaster level to determine
 * @param nSpecificClass The class to determine the creature's Shadowcaster
 *                       level in.
 *                       DEFAULT: CLASS_TYPE_INVALID, which means the creature's
 *                       Shadowcaster level in regards to an ongoing mystery
 *                       is determined instead.
 * @return               The Shadowcaster level
 */
int GetShadowcasterLevel(object oShadow = OBJECT_SELF, int nSpecificClass = CLASS_TYPE_INVALID);

/**
 * Determines whether a given creature uses ShadowMagic.
 * Requires either levels in a ShadowMagic-related class or
 * natural ShadowMagic ability based on race.
 *
 * @param oCreature Creature to test
 * @return          TRUE if the creature can use ShadowMagics, FALSE otherwise.
 */
int GetIsShadowMagicUser(object oCreature);

/**
 * Determines the given creature's highest unmodified Shadowcaster level among its
 * shadowcasting classes.
 *
 * @param oCreature Creature whose highest Shadowcaster level to determine
 * @return          The highest unmodified Shadowcaster level the creature can have
 */
int GetHighestShadowcasterLevel(object oCreature);

/**
 * Determines whether a given class is a ShadowMagic-related class or not.
 *
 * @param nClass CLASS_TYPE_* of the class to test
 * @return       TRUE if the class is a ShadowMagic-related class, FALSE otherwise
 */
int GetIsShadowMagicClass(int nClass);

/**
 * Gets the level of the mystery being currently shadowcast or the level
 * of the mystery ID passed to it.
 *
 * @param oShadow The creature currently shadowcasting a mystery
 * @return            The level of the mystery being shadowcast
 */
int GetMysteryLevel(object oShadow, int nMystId = 0);

/**
 * Returns the name of the Path
 *
 * @param nPath        PATH_* to name
 */
string GetPathName(int nPath);

/**
 * Returns the Path the mystery is in
 * @param nMystId    Mystery to check
 *
 * @return           PATH_*
 */
int GetPathByMystery(int nMystId);

/**
 * Returns true or false if the character has Path
 * focus in the chosen path
 * @param oShadow    Person to check
 * @param nPath      Path to check
 *
 * @return           TRUE or FALSE
 */
int GetHasPathFocus(object oShadow, int nPath);

/**
 * Calculates how many shadowcaster levels are gained by a given creature from
 * it's levels in prestige classes.
 *
 * @param oCreature Creature to calculate added shadowcaster levels for
 * @return          The number of shadowcaster levels gained
 */
int GetShadowMagicPRCLevels(object oShadow);

/**
 * Determines which of the character's classes is their highest or first 
 * shadowcasting class, if any. This is the one which gains shadowcaster 
 * level raise benefits from prestige classes.
 *
 * @param oCreature Creature whose classes to test
 * @return          CLASS_TYPE_* of the first shadowcasting class,
 *                  CLASS_TYPE_INVALID if the creature does not possess any.
 */
int GetPrimaryShadowMagicClass(object oCreature = OBJECT_SELF);

/**
 * Determines the position of a creature's first shadowcasting class, if any.
 *
 * @param oCreature Creature whose classes to test
 * @return          The position of the first shadowcasting class {1, 2, 3} or 0 if
 *                  the creature possesses no levels in shadowcasting classes.
 */
int GetFirstShadowMagicClassPosition(object oCreature = OBJECT_SELF);

/**
 * Returns ability score needed to Shadowcast
 * Type 1 is score to cast, Type 2 is score for DC
 *
 * @param nClass  The class to check
 * @return        ABILITY_*
 */
int GetShadowAbilityOfClass(int nClass, int nType);

/**
 * Calculates the DC of the Mystery being currently shadowcast.
 *
 * WARNING: Return value is not defined when a mystery isn't being shadowcast.
 *
 */
int GetShadowcasterDC(object oShadow = OBJECT_SELF);

/**
 * Calculates the SpellPen of the Mystery being currently shadowcast.
 * Whether a Mystery is supernatural or not is checked in EvaluateMystery
 *
 * Currently just a placeholder returning GetShadowcasterLevel
 */
int ShadowSRPen(object oShadow, int nShadowcasterLevel);

/**
 * Stores a mystery structure as a set of local variables. If
 * a structure was already stored with the same name on the same object,
 * it is overwritten.
 *
 * @param oObject The object on which to store the structure
 * @param sName   The name under which to store the structure
 * @param myst   The mystery structure to store
 */
void SetLocalMystery(object oObject, string sName, struct mystery myst);

/**
 * Retrieves a previously stored mystery structure. If no structure is stored
 * by the given name, the structure returned is empty.
 *
 * @param oObject The object from which to retrieve the structure
 * @param sName   The name under which the structure is stored
 * @return        The structure built from local variables stored on oObject under sName
 */
struct mystery GetLocalMystery(object oObject, string sName);

/**
 * Returns the boost to caster level from feats
 *
 * @param oShadow The caster
 * @param nMyst   The mystery being cast
 * @return        Total bonus to caster level
 */
int ShadowcastingFeats(object oShadow, int nMyst);

/**
 * Returns the boost to DC from nocturnal caster
 *
 * @param oShadow The caster
 * @param nPath   The path to check for
 * @return        Total bonus to caster level
 */
int GetHasNocturnal(object oShadow, int nPath);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_alterations"
#include "shd_inc_myst"
#include "shd_inc_mystknwn"
#include "lookup_2da_spell"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetShadowcastingClass(object oShadow = OBJECT_SELF)
{
    int nReturn = GetLocalInt(oShadow, PRC_SHADOWCASTING_CLASS) - 1;
    //if (DEBUG) FloatingTextStringOnCreature("GetShadowcastingClass: GetShadowcastingClass value is "+IntToString(nReturn), oShadow);
    return nReturn;
}

int GetShadowcasterLevel(object oShadow = OBJECT_SELF, int nSpecificClass = CLASS_TYPE_INVALID)
{
    int nAdjust = GetLocalInt(oShadow, PRC_CASTERLEVEL_ADJUSTMENT);
    int nLevel = GetLocalInt(oShadow, PRC_CASTERLEVEL_OVERRIDE);
    int nMyst = PRCGetSpellId(); // The fact that this will return 0 sometimes is relied upon
    if (GetIsFundamental(nMyst)) nSpecificClass = CLASS_TYPE_SHADOWCASTER;

    // For when you want to assign the caster level.
    if(nLevel)
    {
        if(DEBUG) DoDebug("GetShadowcasterLevel(): Forced-level shadowcasting at level " + IntToString(nLevel));
        //DelayCommand(1.0, DeleteLocalInt(oShadow, PRC_CASTERLEVEL_OVERRIDE));
        return nLevel + nAdjust;
    }

    if (DEBUG) DoDebug("GetShadowcasterLevel: "+GetName(oShadow)+" is a "+IntToString(nSpecificClass), oShadow);
    // The function user needs to know the character's Shadowcaster level in a specific class
    // instead of whatever the character last shadowcast a mystery as
    if(nSpecificClass != CLASS_TYPE_INVALID)
    {
        //if (DEBUG) FloatingTextStringOnCreature("GetShadowcasterLevel: Class is Valid", oShadow);
        if(GetIsShadowMagicClass(nSpecificClass))
        {
            //if (DEBUG) FloatingTextStringOnCreature("GetShadowcasterLevel: Class is Shadow Magic Class", oShadow);
            // Shadowcaster level is class level + prestige
            nLevel = GetLevelByClass(nSpecificClass, oShadow);
            if(nLevel)
            {
                nLevel += GetShadowMagicPRCLevels(oShadow);
                nLevel += ShadowcastingFeats(oShadow, nMyst);
                if (GetLocalInt(oShadow, "CaptureMagic")) 
                {
                    nLevel += GetLocalInt(oShadow, "CaptureMagic");
                    DeleteLocalInt(oShadow, "CaptureMagic");
                } 
                if (GetLocalInt(oShadow, "EldritchDisrupt"))
                    nLevel -= 4;   
                if (GetLocalInt(oShadow, "EldritchVortex"))
                    nLevel -= 4;                     
            }    
        }
    }
    else if(GetShadowcastingClass(oShadow) != -1)
    {
        //if (DEBUG) FloatingTextStringOnCreature("GetShadowcasterLevel: GetShadowcastingClass", oShadow);
        nLevel = GetLevelByClass(GetShadowcastingClass(oShadow), oShadow);
        //if (DEBUG) FloatingTextStringOnCreature("GetShadowcasterLevel: GetShadowcastingClass level "+IntToString(nLevel), oShadow);
        nLevel += GetShadowMagicPRCLevels(oShadow);
        //if (DEBUG) FloatingTextStringOnCreature("GetShadowcasterLevel: GetShadowcastingClass prestige level "+IntToString(nLevel), oShadow);
        nLevel += ShadowcastingFeats(oShadow, nMyst);
        //if (DEBUG) FloatingTextStringOnCreature("GetShadowcasterLevel: GetShadowcastingClass feat level "+IntToString(nLevel), oShadow);
        if (GetLocalInt(oShadow, "CaptureMagic")) 
        {
            nLevel += GetLocalInt(oShadow, "CaptureMagic");
            DeleteLocalInt(oShadow, "CaptureMagic");
        }
        if (GetLocalInt(oShadow, "EldritchDisrupt"))
            nLevel -= 4;        
        if (GetLocalInt(oShadow, "EldritchVortex"))
            nLevel -= 4;             
    }
    
    if(DEBUG) DoDebug("Shadowcaster Level: " + IntToString(nLevel));

    return nLevel + nAdjust;
}

int GetIsShadowMagicUser(object oCreature)
{
    return !!(GetLevelByClass(CLASS_TYPE_SHADOWCASTER, oCreature)
            || GetLevelByClass(CLASS_TYPE_SHADOWSMITH, oCreature));
}

int GetHighestShadowcasterLevel(object oCreature)
{
	int n = 0;
	int nHighest;
	int nTemp;
	
    while(n <= 8)
	{
		if(GetClassByPosition(n, oCreature) != CLASS_TYPE_INVALID)
		{
			nTemp = GetShadowcasterLevel(oCreature, GetClassByPosition(n, oCreature));
			
			if(nTemp > nHighest) 
				nHighest = nTemp;
		}
	n++;

	}
	
	return nHighest;
}

/* int GetHighestShadowcasterLevel(object oCreature)
{
    return PRCMax(PRCMax(GetClassByPosition(1, oCreature) != CLASS_TYPE_INVALID ? GetShadowcasterLevel(oCreature, GetClassByPosition(1, oCreature)) : 0,
                   GetClassByPosition(2, oCreature) != CLASS_TYPE_INVALID ? GetShadowcasterLevel(oCreature, GetClassByPosition(2, oCreature)) : 0
                   ),
               GetClassByPosition(3, oCreature) != CLASS_TYPE_INVALID ? GetShadowcasterLevel(oCreature, GetClassByPosition(3, oCreature)) : 0
               );
} */

int GetIsShadowMagicClass(int nClass)
{
    return nClass == CLASS_TYPE_SHADOWCASTER
         || nClass == CLASS_TYPE_SHADOWSMITH;
}

int GetMysteryLevel(object oShadow, int nMystId = 0)
{
    if (nMystId > 0) return StringToInt(lookup_spell_innate(nMystId));
    int nLevel = GetLocalInt(oShadow, PRC_MYSTERY_LEVEL);
    if (nLevel > 0) return nLevel;
    
    return 0;
}

string GetPathName(int nPath)
{
    int nStrRef;
    switch(nPath)
    {
       /* case PATH_DESERT_WIND:    nStrRef = 16829714; break;
        case PATH_DEVOTED_SPIRIT: nStrRef = 16829715; break;
        case PATH_DIAMOND_MIND:   nStrRef = 16829716; break;
        case PATH_IRON_HEART:     nStrRef = 16829717; break;
        case PATH_SETTING_SUN:    nStrRef = 16829718; break;
        case PATH_SHADOW_HAND:    nStrRef = 16829719; break;
        case PATH_STONE_DRAGON:   nStrRef = 16829720; break;
        case PATH_TIGER_CLAW:     nStrRef = 16829721; break;
        case PATH_WHITE_RAVEN:    nStrRef = 16829722; break;*/
    }
    return GetStringByStrRef(nStrRef);
}

int GetPathByMystery(int nMystId)
{
    // Shadowcaster has every mystery ever, so this is just the easy way out.
    int i = GetPowerfileIndexFromRealSpellID(nMystId);
    string sClass = GetAMSDefinitionFileName(CLASS_TYPE_SHADOWCASTER);
    int nReturn = StringToInt(Get2DACache(sClass, "Path", i));
    /*if (DEBUG) DoDebug("GetPathByMystery() i "+IntToString(i)); 
    if (DEBUG) DoDebug("GetPathByMystery() sClass "+sClass); 
    if (DEBUG) DoDebug("GetPathByMystery() nReturn "+IntToString(nReturn));  */
    
    return nReturn;
}

int GetShadowMagicPRCLevels(object oShadow)
{
	int nLevel;
	int nShadowClass	= GetPrimaryShadowMagicClass(oShadow);
	
	if (nShadowClass == CLASS_TYPE_SHADOWCASTER)
    {
		if(GetHasFeat(FEAT_AOTS_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_ACOLYTE, oShadow) + 1) / 2;

		if(GetHasFeat(FEAT_ALIENIST_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_ALIENIST, oShadow);
		
		if(GetHasFeat(FEAT_CHILDNIGHT_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_CHILD_OF_NIGHT, oShadow) -1;	//:: No increase @ 1st level
		
		if(GetHasFeat(FEAT_ASMODEUS_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oShadow) + 1) / 2;
		
		if(GetHasFeat(FEAT_DSONG_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_DRAGONSONG_LYRIST, oShadow) + 1) / 2;		
		
		if(GetHasFeat(FEAT_ELESAVANT_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_ELEMENTAL_SAVANT, oShadow);		

		if(GetHasFeat(FEAT_MASTERSHADOW_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_MASTER_OF_SHADOW, oShadow) -1;	//:: No increase @ 1st level
		
		if(GetHasFeat(FEAT_MYSTICTHEURGE_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_MYSTIC_THEURGE, oShadow);

		if(GetHasFeat(FEAT_NOCTUMANCER_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_NOCTUMANCER, oShadow);

		if(GetHasFeat(FEAT_OLLAM_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_OLLAM, oShadow) + 1 / 2);

		if(GetHasFeat(FEAT_TIAMAT_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oShadow) + 1 / 2);

		if(GetHasFeat(FEAT_ORCUS_MYSTERY_SHADOWCASTER, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_ORCUS, oShadow) + 1 / 2);		
	}
	
	if (nShadowClass == CLASS_TYPE_SHADOWSMITH)
	{
		if(GetHasFeat(FEAT_AOTS_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_ACOLYTE, oShadow) + 1) / 2;

		if(GetHasFeat(FEAT_ALIENIST_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_ALIENIST, oShadow);
		
		if(GetHasFeat(FEAT_CHILDNIGHT_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_CHILD_OF_NIGHT, oShadow) -1;	//:: No increase @ 1st level
		
		if(GetHasFeat(FEAT_ASMODEUS_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oShadow) + 1) / 2;
		
		if(GetHasFeat(FEAT_DSONG_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_DRAGONSONG_LYRIST, oShadow) + 1) / 2;		
		
		if(GetHasFeat(FEAT_ELESAVANT_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_ELEMENTAL_SAVANT, oShadow);		

		if(GetHasFeat(FEAT_MASTERSHADOW_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_MASTER_OF_SHADOW, oShadow) -1;	//:: No increase @ 1st level
		
		if(GetHasFeat(FEAT_MYSTICTHEURGE_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_MYSTIC_THEURGE, oShadow);

		if(GetHasFeat(FEAT_NOCTUMANCER_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += GetLevelByClass(CLASS_TYPE_NOCTUMANCER, oShadow);

		if(GetHasFeat(FEAT_OLLAM_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_OLLAM, oShadow) + 1 / 2);

		if(GetHasFeat(FEAT_TIAMAT_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oShadow) + 1 / 2);

		if(GetHasFeat(FEAT_ORCUS_MYSTERY_SHADOWSMITH, oShadow))
			nLevel += (GetLevelByClass(CLASS_TYPE_ORCUS, oShadow) + 1 / 2);		
	}    

    return nLevel;
}


/* int GetShadowMagicPRCLevels(object oShadow)
{
    int nLevel = GetLevelByClass(CLASS_TYPE_NOCTUMANCER, oShadow);
    
    // These two don't add at 1st level
    if (GetLevelByClass(CLASS_TYPE_CHILD_OF_NIGHT, oShadow))
        nLevel += GetLevelByClass(CLASS_TYPE_CHILD_OF_NIGHT, oShadow) - 1;
    if (GetLevelByClass(CLASS_TYPE_MASTER_OF_SHADOW, oShadow))
        nLevel += GetLevelByClass(CLASS_TYPE_MASTER_OF_SHADOW, oShadow) - 1;        

    return nLevel;
} */

int GetPrimaryShadowMagicClass(object oCreature = OBJECT_SELF)
{
    int nClass = CLASS_TYPE_INVALID;

    if(GetPRCSwitch(PRC_CASTERLEVEL_FIRST_CLASS_RULE))
    {
        int nShadowMagicPos = GetFirstShadowMagicClassPosition(oCreature);
        if (!nShadowMagicPos) return CLASS_TYPE_INVALID; // no Blade Magic shadowcasting class

        nClass = GetClassByPosition(nShadowMagicPos, oCreature);
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
		
        if(GetIsShadowMagicClass(nClass1)) nClass1Lvl = GetLevelByClass(nClass1, oCreature);
        if(GetIsShadowMagicClass(nClass2)) nClass2Lvl = GetLevelByClass(nClass2, oCreature);
        if(GetIsShadowMagicClass(nClass3)) nClass3Lvl = GetLevelByClass(nClass3, oCreature);
        if(GetIsShadowMagicClass(nClass4)) nClass4Lvl = GetLevelByClass(nClass4, oCreature);
        if(GetIsShadowMagicClass(nClass5)) nClass5Lvl = GetLevelByClass(nClass5, oCreature);
        if(GetIsShadowMagicClass(nClass6)) nClass6Lvl = GetLevelByClass(nClass6, oCreature);
        if(GetIsShadowMagicClass(nClass7)) nClass7Lvl = GetLevelByClass(nClass7, oCreature);
        if(GetIsShadowMagicClass(nClass8)) nClass8Lvl = GetLevelByClass(nClass8, oCreature);		

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

int GetFirstShadowMagicClassPosition(object oCreature = OBJECT_SELF)
{
    if (GetIsShadowMagicClass(GetClassByPosition(1, oCreature)))
        return 1;
    if (GetIsShadowMagicClass(GetClassByPosition(2, oCreature)))
        return 2;
    if (GetIsShadowMagicClass(GetClassByPosition(3, oCreature)))
        return 3;
    if (GetIsShadowMagicClass(GetClassByPosition(4, oCreature)))
        return 4;
    if (GetIsShadowMagicClass(GetClassByPosition(5, oCreature)))
        return 5;
    if (GetIsShadowMagicClass(GetClassByPosition(6, oCreature)))
        return 6;
    if (GetIsShadowMagicClass(GetClassByPosition(7, oCreature)))
        return 7;
    if (GetIsShadowMagicClass(GetClassByPosition(8, oCreature)))
        return 8;
	
    return 0;
}

int GetHasPathFocus(object oShadow, int nPath)
{
    //if (DEBUG) DoDebug("GetHasPathFocus() nPath "+IntToString(nPath));
    int nFocus, nGRFocus, nReturn;
    switch(nPath)
    {
        case PATH_CLOAK_SHADOWS:      nFocus = FEAT_PATH_FOCUS_CLOAK_SHADOWS     ; nGRFocus = FEAT_GREATER_PATH_FOCUS_CLOAK_SHADOWS     ; break;
        case PATH_DARK_TERRAIN:       nFocus = FEAT_PATH_FOCUS_DARK_TERRAIN      ; nGRFocus = FEAT_GREATER_PATH_FOCUS_DARK_TERRAIN      ; break;
        case PATH_EBON_WHISPERS:      nFocus = FEAT_PATH_FOCUS_EBON_WHISPERS     ; nGRFocus = FEAT_GREATER_PATH_FOCUS_EBON_WHISPERS     ; break;
        case PATH_EYES_DARKNESS:      nFocus = FEAT_PATH_FOCUS_EYES_DARKNESS     ; nGRFocus = FEAT_GREATER_PATH_FOCUS_EYES_DARKNESS     ; break;
        case PATH_SHUTTERS_CLOUDS:    nFocus = FEAT_PATH_FOCUS_SHUTTERS_CLOUDS   ; nGRFocus = FEAT_GREATER_PATH_FOCUS_SHUTTERS_CLOUDS   ; break;
        case PATH_TOUCH_TWILIGHT:     nFocus = FEAT_PATH_FOCUS_TOUCH_TWILIGHT    ; nGRFocus = FEAT_GREATER_PATH_FOCUS_TOUCH_TWILIGHT    ; break;
        case PATH_UMBRAL_MIND:        nFocus = FEAT_PATH_FOCUS_UMBRAL_MIND       ; nGRFocus = FEAT_GREATER_PATH_FOCUS_UMBRAL_MIND       ; break;
        case PATH_BLACK_MAGIC:        nFocus = FEAT_PATH_FOCUS_BLACK_MAGIC       ; nGRFocus = FEAT_GREATER_PATH_FOCUS_BLACK_MAGIC       ; break;
        case PATH_BODY_SOUL:          nFocus = FEAT_PATH_FOCUS_BODY_SOUL         ; nGRFocus = FEAT_GREATER_PATH_FOCUS_BODY_SOUL         ; break;
        case PATH_DARK_REFLECTIONS:   nFocus = FEAT_PATH_FOCUS_DARK_REFLECTIONS  ; nGRFocus = FEAT_GREATER_PATH_FOCUS_DARK_REFLECTIONS  ; break;
        case PATH_EBON_ROADS:         nFocus = FEAT_PATH_FOCUS_EBON_ROADS        ; nGRFocus = FEAT_GREATER_PATH_FOCUS_EBON_ROADS        ; break;
        case PATH_ELEMENTAL_SHADOWS:  nFocus = FEAT_PATH_FOCUS_ELEMENTAL_SHADOWS ; nGRFocus = FEAT_GREATER_PATH_FOCUS_ELEMENTAL_SHADOWS ; break;
        case PATH_UNBINDING_SHADE:    nFocus = FEAT_PATH_FOCUS_UNBINDING_SHADE   ; nGRFocus = FEAT_GREATER_PATH_FOCUS_UNBINDING_SHADE   ; break;
        case PATH_VEIL_SHADOWS:       nFocus = FEAT_PATH_FOCUS_VEIL_SHADOWS      ; nGRFocus = FEAT_GREATER_PATH_FOCUS_VEIL_SHADOWS      ; break;
        case PATH_BREATH_TWILIGHT:    nFocus = FEAT_PATH_FOCUS_BREATH_TWILIGHT   ; nGRFocus = FEAT_GREATER_PATH_FOCUS_BREATH_TWILIGHT   ; break;
        case PATH_DARK_METAMORPHOSIS: nFocus = FEAT_PATH_FOCUS_DARK_METAMORPHOSIS; nGRFocus = FEAT_GREATER_PATH_FOCUS_DARK_METAMORPHOSIS; break;
        case PATH_EBON_WALLS:         nFocus = FEAT_PATH_FOCUS_EBON_WALLS        ; nGRFocus = FEAT_GREATER_PATH_FOCUS_EBON_WALLS        ; break;
        case PATH_EYES_NIGHT_SKY:     nFocus = FEAT_PATH_FOCUS_EYES_NIGHT_SKY    ; nGRFocus = FEAT_GREATER_PATH_FOCUS_EYES_NIGHT_SKY    ; break;
        case PATH_HEART_SOUL:         nFocus = FEAT_PATH_FOCUS_HEART_SOUL        ; nGRFocus = FEAT_GREATER_PATH_FOCUS_HEART_SOUL        ; break;
        case PATH_SHADOW_CALLING:     nFocus = FEAT_PATH_FOCUS_SHADOW_CALLING    ; nGRFocus = FEAT_GREATER_PATH_FOCUS_SHADOW_CALLING    ; break;  
        case PATH_NIGHTS_LONG_FINGERS: nFocus = FEAT_PATH_FOCUS_NIGHTS_LONG_FINGERS; nGRFocus = FEAT_GREATER_PATH_FOCUS_NIGHTS_LONG_FINGERS; break; 
        case PATH_DARKENED_ALLEYS:  nFocus = FEAT_PATH_FOCUS_DARKENED_ALLEYS   ; nGRFocus = FEAT_GREATER_PATH_FOCUS_DARKENED_ALLEYS   ; break; 
        case PATH_SHADOWSCAPE:      nFocus = FEAT_PATH_FOCUS_SHADOWSCAPE       ; nGRFocus = FEAT_GREATER_PATH_FOCUS_SHADOWSCAPE       ; break; 
    }
    if(GetHasFeat(nFocus, oShadow))
        nReturn = 1;
    if(GetHasFeat(nGRFocus, oShadow))
        nReturn = 2;     
        
    //if (DEBUG) DoDebug("GetHasPathFocus() nReturn "+IntToString(nReturn));        

    // If none of those trigger.
    return nReturn;
}

int GetShadowAbilityOfClass(int nClass, int nType)
{
    if (nClass == CLASS_TYPE_SHADOWSMITH) return ABILITY_INTELLIGENCE;
    // Intelligence for max mystery known
    if (nClass == CLASS_TYPE_SHADOWCASTER && nType == 1) return ABILITY_INTELLIGENCE;
    // Charisma for DC
    if (nClass == CLASS_TYPE_SHADOWCASTER && nType == 2) return ABILITY_CHARISMA;

    // Technically, never gets here but the compiler does not realise that
    return -1;
}

int GetShadowcasterDC(object oShadow = OBJECT_SELF)
{
    // Things we need for DC Checks
    int nMystId = PRCGetSpellId();
    int nShadEvo = GetLocalInt(oShadow, "ShadowEvoking");
    if (nShadEvo > 0)
        nMystId = nShadEvo; // This is used to get the proper DC for Shadow Evocation mysteries   
    
    int nLevel = GetMysteryLevel(oShadow, nMystId);
    int nClass = GetShadowcastingClass(oShadow);
    int nShadow = GetShadowcasterLevel(oShadow);
    int nAbi = GetAbilityModifier(GetShadowAbilityOfClass(nClass, 2), oShadow);
    int nPath = GetPathByMystery(nMystId);
    int nPFocus = GetHasPathFocus(oShadow, nPath); 
    int nNoct = GetHasNocturnal(oShadow, nPath); 
    nShadow -= nPFocus; // These don't count here

    // DC is 10 + Mystery level + ability
    int nDC = 10 + nLevel + nAbi;
    
    // If total Shadowcaster level is >= 13, change the DC for level 3 and under mysteries
    // DC is 10 + 1/2 Shadowcaster level + ability
    if (GetIsMysterySupernatural(oShadow, nMystId, nClass))
        nDC = 10 + nShadow/2 + nAbi;
        
    nDC += nPFocus;
    nDC += nNoct;// It's a 0 if it doesn't exist    

    return nDC;
}

int ShadowSRPen(object oShadow, int nShadowcasterLevel)
{
    return nShadowcasterLevel;
}

void SetLocalMystery(object oObject, string sName, struct mystery myst)
{
    //SetLocal (oObject, sName + "_", );
    SetLocalObject(oObject, sName + "_oShadow", myst.oShadow);

    SetLocalInt(oObject, sName + "_bCanMyst",           myst.bCanMyst);
    SetLocalInt(oObject, sName + "_nShadowcasterLevel", myst.nShadowcasterLevel);
    SetLocalInt(oObject, sName + "_nMystId",            myst.nMystId);    
    SetLocalInt(oObject, sName + "_nPen",               myst.nPen);
    SetLocalInt(oObject, sName + "_bIgnoreSR",          myst.bIgnoreSR); 

    SetLocalInt(oObject, sName + "_bEmpower",  myst.bEmpower);
    SetLocalInt(oObject, sName + "_bExtend",   myst.bExtend);
    SetLocalInt(oObject, sName + "_bMaximize", myst.bMaximize);
    SetLocalInt(oObject, sName + "_bQuicken",  myst.bQuicken);
    
    SetLocalInt(oObject, sName + "_nSaveDC",   myst.nSaveDC);
    SetLocalFloat(oObject, sName + "_fDur",      myst.fDur);
}

struct mystery GetLocalMystery(object oObject, string sName)
{
    struct mystery myst;
    myst.oShadow = GetLocalObject(oObject, sName + "_oShadow");

    myst.bCanMyst      = GetLocalInt(oObject, sName + "_bCanMyst");
    myst.nShadowcasterLevel  = GetLocalInt(oObject, sName + "_nShadowcasterLevel");
    myst.nMystId          = GetLocalInt(oObject, sName + "_nMystId");
    myst.nPen          = GetLocalInt(oObject, sName + "_nPen");
    myst.bIgnoreSR          = GetLocalInt(oObject, sName + "_bIgnoreSR");

    myst.bEmpower  = GetLocalInt(oObject, sName + "_bEmpower");
    myst.bExtend   = GetLocalInt(oObject, sName + "_bExtend");
    myst.bMaximize = GetLocalInt(oObject, sName + "_bMaximize");
    myst.bQuicken  = GetLocalInt(oObject, sName + "_bQuicken");
    
    myst.nSaveDC = GetLocalInt(oObject, sName + "_nSaveDC");
    myst.fDur  = GetLocalFloat(oObject, sName + "_fDur");    

    return myst;
}

int ShadowcastingFeats(object oShadow, int nMyst)
{
    int nReturn = 0;
    int nPath = GetPathByMystery(nMyst);
    nReturn += GetHasPathFocus(oShadow, nPath);
 
    return nReturn;
}

int GetHasNocturnal(object oShadow, int nPath)
{
    int nNocturnal, nReturn;
    switch(nPath)
    {
        case PATH_CLOAK_SHADOWS:      nNocturnal = FEAT_NOCTURNAL_CASTER_CLOAK_SHADOWS     ; break;
        case PATH_DARK_TERRAIN:       nNocturnal = FEAT_NOCTURNAL_CASTER_DARK_TERRAIN      ; break;
        case PATH_EBON_WHISPERS:      nNocturnal = FEAT_NOCTURNAL_CASTER_EBON_WHISPERS     ; break;
        case PATH_EYES_DARKNESS:      nNocturnal = FEAT_NOCTURNAL_CASTER_EYES_DARKNESS     ; break;
        case PATH_SHUTTERS_CLOUDS:    nNocturnal = FEAT_NOCTURNAL_CASTER_SHUTTERS_CLOUDS   ; break;
        case PATH_TOUCH_TWILIGHT:     nNocturnal = FEAT_NOCTURNAL_CASTER_TOUCH_TWILIGHT    ; break;
        case PATH_UMBRAL_MIND:        nNocturnal = FEAT_NOCTURNAL_CASTER_UMBRAL_MIND       ; break;
        case PATH_BLACK_MAGIC:        nNocturnal = FEAT_NOCTURNAL_CASTER_BLACK_MAGIC       ; break;
        case PATH_BODY_SOUL:          nNocturnal = FEAT_NOCTURNAL_CASTER_BODY_SOUL         ; break;
        case PATH_DARK_REFLECTIONS:   nNocturnal = FEAT_NOCTURNAL_CASTER_DARK_REFLECTIONS  ; break;
        case PATH_EBON_ROADS:         nNocturnal = FEAT_NOCTURNAL_CASTER_EBON_ROADS        ; break;
        case PATH_ELEMENTAL_SHADOWS:  nNocturnal = FEAT_NOCTURNAL_CASTER_ELEMENTAL_SHADOWS ; break;
        case PATH_UNBINDING_SHADE:    nNocturnal = FEAT_NOCTURNAL_CASTER_UNBINDING_SHADE   ; break;
        case PATH_VEIL_SHADOWS:       nNocturnal = FEAT_NOCTURNAL_CASTER_VEIL_SHADOWS      ; break;
        case PATH_BREATH_TWILIGHT:    nNocturnal = FEAT_NOCTURNAL_CASTER_BREATH_TWILIGHT   ; break;
        case PATH_DARK_METAMORPHOSIS: nNocturnal = FEAT_NOCTURNAL_CASTER_DARK_METAMORPHOSIS; break;
        case PATH_EBON_WALLS:         nNocturnal = FEAT_NOCTURNAL_CASTER_EBON_WALLS        ; break;
        case PATH_EYES_NIGHT_SKY:     nNocturnal = FEAT_NOCTURNAL_CASTER_EYES_NIGHT_SKY    ; break;
        case PATH_HEART_SOUL:         nNocturnal = FEAT_NOCTURNAL_CASTER_HEART_SOUL        ; break;
        case PATH_SHADOW_CALLING:     nNocturnal = FEAT_NOCTURNAL_CASTER_SHADOW_CALLING    ; break;  
        case PATH_NIGHTS_LONG_FINGERS:nNocturnal = FEAT_NOCTURNAL_CASTER_NIGHTS_LONG_FINGERS; break; 
        case PATH_DARKENED_ALLEYS:    nNocturnal = FEAT_NOCTURNAL_CASTER_DARKENED_ALLEYS   ; break; 
        case PATH_SHADOWSCAPE:        nNocturnal = FEAT_NOCTURNAL_CASTER_SHADOWSCAPE       ; break; 
    }
    if(GetHasFeat(nNocturnal, oShadow) && GetIsNight())
        nReturn = 1;

    // If none of those trigger.
    return nReturn;
}