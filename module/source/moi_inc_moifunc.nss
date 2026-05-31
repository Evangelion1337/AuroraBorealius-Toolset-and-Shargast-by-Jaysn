//::///////////////////////////////////////////////
//:: Meldshaping/Incarnum main include: Miscellaneous
//:: moi_inc_moifunc
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to Meldshaping.

    Also acts as inclusion nexus for the general
    meldshaping includes. In other words, don't include
    them directly in your scripts, instead include this.

    @author Stratovarius
    @date   Created - 2019.12.28
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
#include "moi_meld_const" 
//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////
/**
 * @brief Retrieves the effect tag associated with a specific soulmeld.
 *
 * Maps a soulmeld identifier to its corresponding effect tag string used
 * for applying or removing feat-granting effects tied to that soulmeld.
 *
 * @param nMeldId The integer identifier of the soulmeld (e.g., MELD_FROST_HELM).
 *
 * @return A string representing the effect tag associated with the given
 *         soulmeld, or an empty string ("") if the soulmeld ID is not recognized.
 *
 * @note The returned tag is intended for use with effect tagging systems,
 *       such as applying or removing effects via GetEffectTag().
 *
 * @warning If a new soulmeld is added and not included in this switch,
 *          this function will return an empty string, which may cause
 *          dependent systems to fail silently.
 */
string GetSoulmeldTag(int nMeldId)  
{  
    if (nMeldId == MELD_FROST_HELM)          		return "SOULMELD_FROST_HELM_FEATS";  
    else if (nMeldId == MELD_IMPULSE_BOOTS)       return "SOULMELD_IMPULSE_BOOTS_FEATS";  
    else if (nMeldId == MELD_PHOENIX_BELT)        return "SOULMELD_PHOENIX_BELT_FEATS";  
    else if (nMeldId == MELD_WORMTAIL_BELT)       return "SOULMELD_WORMTAIL_BELT_FEATS";  
    else if (nMeldId == MELD_APPARITION_RIBBON)   return "SOULMELD_APPARITION_RIBBON_FEATS";  
    else if (nMeldId == MELD_MANTICORE_BELT)      return "SOULMELD_MANTICORE_BELT_FEATS";  
    else if (nMeldId == MELD_THEFT_GLOVES)        return "SOULMELD_THEFT_GLOVES_FEATS";  
    else if (nMeldId == MELD_BLOODTALONS)         return "SOULMELD_BLOODTALONS_FEATS";  
    else if (nMeldId == MELD_LAMIA_BELT)          return "SOULMELD_LAMIA_BELT_FEATS";  
    else if (nMeldId == MELD_CRYSTAL_HELM)        return "SOULMELD_CRYSTAL_HELM_FEATS";  
    else if (nMeldId == MELD_BASILISK_MASK)       return "SOULMELD_BASILISK_MASK_FEATS";  
    else if (nMeldId == MELD_ASTRAL_VAMBRACES)    return "SOULMELD_ASTRAL_VAMBRACES_FEATS";  
    else if (nMeldId == MELD_MAULING_GAUNTLETS)   return "SOULMELD_MAULING_GAUNTLETS_FEATS";  
    else if (nMeldId == MELD_DRAGONFIRE_MASK)     return "SOULMELD_DRAGONFIRE_MASK_FEATS";  
    else return "";  
}

/**
 * @brief Removes all effects from a creature that match a specific soulmeld tag.
 *
 * Iterates through all active effects on the specified object and removes any
 * effect whose tag matches the provided soulmeld tag. This is typically used
 * to strip feat-granting effects associated with a single soulmeld.
 *
 * @param oPC The creature (typically a player character) from which effects
 *            will be removed.
 * @param sMeldTag The effect tag identifying the soulmeld-related feat effects
 *                 to remove.
 *
 * @note This function performs an exact string comparison using GetEffectTag().
 *
 * @warning Passing an empty string ("") as sMeldTag may result in unintended
 *          behavior if any effects are tagged with an empty string.
 */
void RemoveSpecificSoulmeldFeats(object oPC, string sMeldTag)  
{  
    effect eEffect = GetFirstEffect(oPC);  
    while(GetIsEffectValid(eEffect))  
    {  
        if(GetEffectTag(eEffect) == sMeldTag)  
            RemoveEffect(oPC, eEffect);  
          
        eEffect = GetNextEffect(oPC);  
    }  
}  

/**
 * @brief Removes all soulmeld-related feat effects from a creature.
 *
 * Iterates through all active effects on the specified object and removes any
 * effects that match known soulmeld feat tags. These effects are assumed to
 * have been applied to grant feats associated with specific soulmelds.
 *
 * @param oPC The creature (typically a player character) from which soulmeld
 *            feat effects will be removed.
 *
 * @note This function relies on effect tags to identify soulmeld feat effects.
 *       Only effects with explicitly listed tags will be removed.
 *
 * @warning Any soulmeld feat effect not included in the tag list will remain
 *          active. Ensure new soulmelds are added here if they apply feat effects.
 */
void RemoveSoulmeldFeatEffects(object oPC)  
{  
    effect eEffect = GetFirstEffect(oPC);  
    while(GetIsEffectValid(eEffect))  
    {  
        string sTag = GetEffectTag(eEffect);  
        if(sTag == "SOULMELD_FROST_HELM_FEATS" 			||  
           sTag == "SOULMELD_IMPULSE_BOOTS_FEATS" 		||  
           sTag == "SOULMELD_PHOENIX_BELT_FEATS" 		||  
           sTag == "SOULMELD_WORMTAIL_BELT_FEATS" 		||  
           sTag == "SOULMELD_APPARITION_RIBBON_FEATS" 	||  
           sTag == "SOULMELD_MANTICORE_BELT_FEATS" 		||  
           sTag == "SOULMELD_THEFT_GLOVES_FEATS" 		||  
           sTag == "SOULMELD_BLOODTALONS_FEATS" 		||  
           sTag == "SOULMELD_LAMIA_BELT_FEATS" 			||  
           sTag == "SOULMELD_CRYSTAL_HELM_FEATS" 		||  
           sTag == "SOULMELD_BASILISK_MASK_FEATS" 		||  
           sTag == "SOULMELD_ASTRAL_VAMBRACES_FEATS" 	||  
           sTag == "SOULMELD_MAULING_GAUNTLETS_FEATS" 	||  
           sTag == "SOULMELD_DRAGONFIRE_MASK_FEATS")  
        {  
            RemoveEffect(oPC, eEffect);  
        }  
        eEffect = GetNextEffect(oPC);  
    }  
}

/**
 * Determines the given creature's Meldshaper level. 
 *
 * @param oMeldshaper    The creature whose Meldshaper level to determine
 * @param nSpecificClass The class to determine the creature's Meldshaper
 *                       level in.
 * @param nMeld          The meld to test, since Incarnum does level by meld
 *
 * @return               The Meldshaper level
 */
int GetMeldshaperLevel(object oMeldshaper, int nSpecificClass, int nMeld);

/**
 * Determines the given creature's highest unmodified Meldshaper level among its
 * Meldshaping classes.
 *
 * @param oMeldshaper Creature whose highest Meldshaper level to determine
 * @return          The highest unmodified Meldshaper level the creature can have
 */
int GetHighestMeldshaperLevel(object oMeldshaper);

/**
 * Determines whether a given class is a Incarnum-related class or not.
 *
 * @param nClass CLASS_TYPE_* of the class to test
 * @return       TRUE if the class is a Incarnum-related class, FALSE otherwise
 */
int GetIsIncarnumClass(int nClass);

/**
 * Calculates how many Meldshaper levels are gained by a given creature from
 * it's levels in prestige classes.
 *
 * @param oMeldshaper Creature to calculate added Meldshaper levels for
 * @return          The number of Meldshaper levels gained
 */
int GetIncarnumPRCLevels(object oMeldshaper);

/**
 * Determines which of the character's classes is their highest or first 
 * Meldshaping class, if any. This is the one which gains Meldshaper 
 * level raise benefits from prestige classes.
 *
 * @param oMeldshaper Creature whose classes to test
 * @return          CLASS_TYPE_* of the first Meldshaping class,
 *                  CLASS_TYPE_INVALID if the creature does not possess any.
 */
int GetPrimaryIncarnumClass(object oMeldshaper = OBJECT_SELF);

/**
 * Determines the position of a creature's first Meldshaping class, if any.
 *
 * @param oMeldshaper Creature whose classes to test
 * @return          The position of the first Meldshaping class {1, 2, 3} or 0 if
 *                  the creature possesses no levels in Meldshaping classes.
 */
int GetFirstIncarnumClassPosition(object oMeldshaper = OBJECT_SELF);

/**
 * Checks every second to see if temporary essentia has been lost
 *
 * @param oMeldshaper  The meldshaper
 */
void SpawnTempEssentiaChecker(object oMeldshaper);

/**
 * Returns total value of temporary essentia for the meldshaper
 *
 * @param oMeldshaper The meldshaper
 * 
 * @return        Total value of temporary essentia
 */
int GetTemporaryEssentia(object oMeldshaper);

/**
 * Essentia put into feats is locked away for 24 hours/until next rest
 *
 * @param oMeldshaper The meldshaper
 * 
 * @return        Total value of locked essentia
 */
int GetFeatLockedEssentia(object oMeldshaper);

/**
 * Total essentia a character has access to
 *
 * @param oMeldshaper The meldshaper
 * 
 * @return        Total value of essentia available
 */
int GetTotalEssentia(object oMeldshaper);

/**
 * Total essentia a character has access to, minus feat locked essentia
 *
 * @param oMeldshaper The meldshaper
 * 
 * @return        Total value of essentia available, minus feat locked essentia
 */
int GetTotalUsableEssentia(object oMeldshaper);

/**
 * Returns the slot associated to a given chakra
 *
 * @param nChakra Chakra constant
 * 
 * @return        Slot constant
 */
int ChakraToSlot(int nChakra);

/**
 * Returns the total binds the character can have for that class and level
 *
 * @param oMeldshaper The meldshaper 
 * @param nClass      The class to check
 * 
 * @return        Slot constant
 */
int GetMaxBindCount(object oMeldshaper, int nClass);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_natweap"
#include "prc_inc_function"

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetMeldshaperLevel(object oMeldshaper, int nSpecificClass, int nMeld)
{
    int nLevel;

    //if (DEBUG) DoDebug("GetMeldshaperLevel: "+GetName(oMeldshaper)+" is a "+IntToString(nSpecificClass));

    if(GetIsIncarnumClass(nSpecificClass))
    {
        // Meldshaper level is class level + prestige
        nLevel = GetLevelByClass(nSpecificClass, oMeldshaper);
        if(nLevel)
        {
        	// Prevents people double-dipping prestige levels
            if (nSpecificClass == GetPrimaryIncarnumClass(oMeldshaper)) 
            {
            	nLevel += GetIncarnumPRCLevels(oMeldshaper);
            	nLevel += GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper); // Necrocarnate is here because it doesn't add to anything other than meldshaper level
            }	
            if (nSpecificClass == CLASS_TYPE_SOULBORN) nLevel /= 2;                   
        }   
    }
    
    //if(DEBUG) DoDebug("Meldshaper Level: " + IntToString(nLevel));
    // Being bound to the Totem Chakra increases the level by one.
	if (GetIsMeldBound(oMeldshaper, nMeld) == CHAKRA_TOTEM) nLevel++;
    return nLevel;
}

int GetIncarnumLevelForClass(int nSpecificClass, object oMeldshaper)
{
    int nLevel;

    //if (DEBUG) DoDebug("GetMeldshaperLevel: "+GetName(oMeldshaper)+" is a "+IntToString(nSpecificClass));

    if(GetIsIncarnumClass(nSpecificClass))
    {
        // Meldshaper level is class level + prestige
        nLevel = GetLevelByClass(nSpecificClass, oMeldshaper);
        if(nLevel)
        {
        	// Prevents people double-dipping prestige levels
            if (nSpecificClass == GetPrimaryIncarnumClass(oMeldshaper)) nLevel += GetIncarnumPRCLevels(oMeldshaper);                 
        }   
    }
    if(nSpecificClass == CLASS_TYPE_UMBRAL_DISCIPLE || nSpecificClass == CLASS_TYPE_INCANDESCENT_CHAMPION || nSpecificClass == CLASS_TYPE_NECROCARNATE)
    	nLevel = GetLevelByClass(nSpecificClass, oMeldshaper);
    
    //if(DEBUG) DoDebug("GetIncarnumLevelForClass: " + IntToString(nLevel));
    return nLevel;
}

int GetHighestMeldshaperLevel(object oMeldshaper)
{
    /**return PRCMax(PRCMax(GetClassByPosition(1, oMeldshaper) != CLASS_TYPE_INVALID ? GetMeldshaperLevel(oMeldshaper, GetClassByPosition(1, oMeldshaper), -1) : 0,
                   GetClassByPosition(2, oMeldshaper) != CLASS_TYPE_INVALID ? GetMeldshaperLevel(oMeldshaper, GetClassByPosition(2, oMeldshaper), -1) : 0
                   ),
               GetClassByPosition(3, oMeldshaper) != CLASS_TYPE_INVALID ? GetMeldshaperLevel(oMeldshaper, GetClassByPosition(3, oMeldshaper), -1) : 0
               );**/
               
	int nMax;
	int i;
    for(i = 1; i <= 8; i++)
    {
        int nClass = GetClassByPosition(i, oMeldshaper);
        int nTest = GetMeldshaperLevel(oMeldshaper, GetClassByPosition(i, oMeldshaper), -1);
		if (nTest > nMax)
			nMax = nTest;
    }	
    return nMax;
}

int GetIsIncarnumClass(int nClass)
{
    return nClass == CLASS_TYPE_INCARNATE
         || nClass == CLASS_TYPE_SOULBORN
         || nClass == CLASS_TYPE_TOTEMIST
         || nClass == CLASS_TYPE_SPINEMELD_WARRIOR;
}

int GetIncarnumPRCLevels(object oMeldshaper)
{
    int nLevel = GetLevelByClass(CLASS_TYPE_SAPPHIRE_HIERARCH, oMeldshaper);
    nLevel += GetLevelByClass(CLASS_TYPE_SOULCASTER, oMeldshaper);
    
    // These two don't add at 1st level
    if (GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oMeldshaper))
        nLevel += GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oMeldshaper) - 1;
    // Totem Rager    
	if (GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper) >= 6)
		nLevel += (GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper)) -2;
	else if (GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper))
		nLevel += (GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper)) -1;
	//This is an odd one	
	if (GetLevelByClass(CLASS_TYPE_WITCHBORN_BINDER, oMeldshaper))
	{
		nLevel += (GetLevelByClass(CLASS_TYPE_WITCHBORN_BINDER, oMeldshaper)+1)/2;
		
		if (GetLevelByClass(CLASS_TYPE_WITCHBORN_BINDER, oMeldshaper) >= 10) nLevel += 1;
	}	

    /*if (GetLevelByClass(CLASS_TYPE_MASTER_OF_SHADOW, oMeldshaper))
        nLevel += GetLevelByClass(CLASS_TYPE_MASTER_OF_SHADOW, oMeldshaper) - 1;        
*/
    return nLevel;
}

int GetPrimaryIncarnumClass(object oMeldshaper = OBJECT_SELF)
{
    int nClass = CLASS_TYPE_INVALID;

    if(GetPRCSwitch(PRC_CASTERLEVEL_FIRST_CLASS_RULE))
    {
        int nIncarnumPos = GetFirstIncarnumClassPosition(oMeldshaper);
        if (!nIncarnumPos) return CLASS_TYPE_INVALID; // no Blade Magic Meldshaping class

        nClass = GetClassByPosition(nIncarnumPos, oMeldshaper);
    }
    else
    {
        int nClassTest, nClassLvlTest, nMax, i;        
		for(i = 1; i <= 8; i++)
		{
			int nClassTest = GetClassByPosition(i, oMeldshaper);
			
			if(GetIsIncarnumClass(nClassTest)) 
				nClassLvlTest = GetLevelByClass(nClassTest, oMeldshaper);
			else 
				nClassLvlTest = 0; // Reset to 0 each iteration that isn't incarnum
				
			if (nClassLvlTest > nMax)
			{
				nMax = nClassLvlTest;
				nClass = nClassTest;
			}			
		}	        

        if(nMax == 0) //No Incarnum classes
            nClass = CLASS_TYPE_INVALID;
    }

    return nClass;
}

int GetFirstIncarnumClassPosition(object oMeldshaper = OBJECT_SELF)
{
	int i;        
	for(i = 1; i <= 8; i++)
	{
		if (GetIsIncarnumClass(GetClassByPosition(i, oMeldshaper)))
			return i;			
	}

    return 0;
}

string GetMeldFile(int nClass = -1)
{
	//string sFile;
	//if (nClass == CLASS_TYPE_INCARNATE) sFile = "cls_meld_incarn";
	
	return "soulmelds";
}

string GetMeldshapingClassFile(int nClass)
{
	string sFile;
	if (nClass == CLASS_TYPE_INCARNATE) sFile = "cls_mlkn_incarn";
	else if (nClass == CLASS_TYPE_SOULBORN) sFile = "cls_mlkn_soulbn";
	else if (nClass == CLASS_TYPE_TOTEMIST) sFile = "cls_mlkn_totem";
	else if (nClass == CLASS_TYPE_SPINEMELD_WARRIOR) sFile = "cls_mlkn_spnmld";
	else if (nClass == CLASS_TYPE_UMBRAL_DISCIPLE) sFile = "cls_mlkn_umbral";
	else if (nClass == CLASS_TYPE_INCANDESCENT_CHAMPION) sFile = "cls_mlkn_incand";
	else if (nClass == CLASS_TYPE_NECROCARNATE) sFile = "cls_mlkn_necrnm";
	
	return sFile;
}

int GetMeldshapingClass(object oMeldshaper)
{
	int nClass = -1;
	// If there's levels in the class and haven't already done it
	if (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) && !GetLocalInt(oMeldshaper, "FirstMeldDone")) nClass = CLASS_TYPE_INCARNATE;
	else if (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) && !GetLocalInt(oMeldshaper, "SecondMeldDone")) nClass = CLASS_TYPE_SOULBORN;
	else if (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) && !GetLocalInt(oMeldshaper, "ThirdMeldDone")) nClass = CLASS_TYPE_TOTEMIST;
	else if (GetLevelByClass(CLASS_TYPE_SPINEMELD_WARRIOR, oMeldshaper) && !GetLocalInt(oMeldshaper, "FourthMeldDone")) nClass = CLASS_TYPE_SPINEMELD_WARRIOR;
	//if (DEBUG) DoDebug("GetMeldshapingClass is "+IntToString(nClass));
	return nClass;
}

int GetMaxShapeSoulmeldCount(object oMeldshaper, int nClass)
{
	int nMax = StringToInt(Get2DACache(GetMeldshapingClassFile(nClass), "Soulmelds", GetIncarnumLevelForClass(nClass, oMeldshaper)-1));
	if (nClass == GetPrimaryIncarnumClass(oMeldshaper)) 
	{
		nMax += StringToInt(Get2DACache(GetMeldshapingClassFile(CLASS_TYPE_NECROCARNATE), "Soulmelds", GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper)));
    	int i;
    	for(i = FEAT_BONUS_SOULMELD_1; i <= FEAT_BONUS_SOULMELD_10; i++)
    	    if(GetHasFeat(i, oMeldshaper)) nMax++;
    }
    
	int nCon = GetAbilityScore(oMeldshaper, ABILITY_CONSTITUTION, TRUE)-10;
	if (GetHasFeat(FEAT_UNDEAD_MELDSHAPER, oMeldshaper)) nCon = GetAbilityScore(oMeldshaper, ABILITY_WISDOM, TRUE)-10;
	//Limited to Con score - 10 or class limit, whichever is less
	nMax = PRCMin(nMax, nCon);	
	
    //if (DEBUG) DoDebug("GetMaxShapeSoulmeldCount is "+IntToString(nMax));
    return nMax;
}

int GetTotalSoulmeldCount(object oMeldshaper)
{
	int nMax = GetMaxShapeSoulmeldCount(oMeldshaper, CLASS_TYPE_INCARNATE);	
		nMax += GetMaxShapeSoulmeldCount(oMeldshaper, CLASS_TYPE_SOULBORN);
		nMax += GetMaxShapeSoulmeldCount(oMeldshaper, CLASS_TYPE_TOTEMIST);
		nMax += GetMaxShapeSoulmeldCount(oMeldshaper, CLASS_TYPE_SPINEMELD_WARRIOR);
		nMax += GetMaxShapeSoulmeldCount(oMeldshaper, CLASS_TYPE_NECROCARNATE);
	
    //if (DEBUG) DoDebug("GetTotalSoulmeldCount is "+IntToString(nMax));
    return nMax;
}

int GetMaxBindCount(object oMeldshaper, int nClass)
{
	int nMax = StringToInt(Get2DACache(GetMeldshapingClassFile(nClass), "ChakraBinds", GetIncarnumLevelForClass(nClass, oMeldshaper)-1));
	if (nClass == GetPrimaryIncarnumClass(oMeldshaper)) 
	{
		nMax += StringToInt(Get2DACache(GetMeldshapingClassFile(CLASS_TYPE_NECROCARNATE), "ChakraBinds", GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper)));
	   	int i;
	   	for(i = FEAT_EXTRA_CHAKRA_BIND_1; i <= FEAT_EXTRA_CHAKRA_BIND_10; i++)
   	    	if(GetHasFeat(i, oMeldshaper)) nMax += 1;
   	}    
    //if (DEBUG) DoDebug("GetMaxBindCount is "+IntToString(nMax));
    return nMax;
}

void ShapeSoulmeld(object oMeldshaper, int nMeld)
{
	PRCRemoveSpellEffects(nMeld, oMeldshaper, oMeldshaper);
	GZPRCRemoveSpellEffects(nMeld, oMeldshaper, FALSE);
	ActionCastSpellOnSelf(nMeld);
	//if (DEBUG) DoDebug("Shaping Soulmeld "+IntToString(nMeld)+" on "+GetName(oMeldshaper));
}		

void MarkMeldShaped(object oMeldshaper, int nMeld, int nClass)
{
	//if (DEBUG) DoDebug("MarkMeldShaped nMeld is "+IntToString(nMeld));
	int nCont = TRUE;
	int nTest, i;
	while (nCont)
	{
		nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(nClass)+IntToString(i));
		//if (DEBUG) DoDebug("MarkMeldShaped nTest is "+IntToString(nTest));
		if (!nTest) // If it's blank
		{
			SetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(nClass)+IntToString(i), nMeld);
			//if (DEBUG) DoDebug("MarkMeldShaped SetLocal");
			nCont = FALSE; // Break the loop
		}
		else
			i++; // Increment the counter to check
	}
}

void ClearMeldShapes(object oMeldshaper)
{
	object oSkin = GetPCSkin(oMeldshaper);
	ScrubPCSkin(oMeldshaper, oSkin);
	int i;
    for (i = 0; i <= 22; i++)
    {
		DeleteLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_INCARNATE)+IntToString(i));
		DeleteLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_SOULBORN)+IntToString(i));
		DeleteLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_TOTEMIST)+IntToString(i));
		DeleteLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_SPINEMELD_WARRIOR)+IntToString(i));
		DeleteLocalInt(oMeldshaper, "UsedMeld"+IntToString(CLASS_TYPE_SPINEMELD_WARRIOR)+IntToString(i));
		DeleteLocalInt(oMeldshaper, "UsedMeld"+IntToString(CLASS_TYPE_INCARNATE)+IntToString(i));
		DeleteLocalInt(oMeldshaper, "UsedMeld"+IntToString(CLASS_TYPE_SOULBORN)+IntToString(i));
		DeleteLocalInt(oMeldshaper, "UsedMeld"+IntToString(CLASS_TYPE_TOTEMIST)+IntToString(i));
		DeleteLocalInt(oMeldshaper, "BoundMeld"+IntToString(i));
		int nTest = GetLocalInt(oMeldshaper, "SpellInvestCheck"+IntToString(i));
    	if (nTest)
    		DeleteLocalInt(oMeldshaper, "SpellEssentia"+IntToString(nTest));
    	DeleteLocalInt(oMeldshaper, "SpellInvestCheck"+IntToString(i));	
    	DeleteLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(i));	
    	DeleteLocalInt(oMeldshaper, "UsedBladeMeld"+IntToString(i));	
    }
    for (i = 18700; i < 18799; i++)
    {
		DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(i));
    } 
    for (i = 8869; i < 8889; i++)
    {
		DeleteLocalInt(oMeldshaper, "FeatEssentia"+IntToString(i));
    }    
    DeleteLocalInt(oMeldshaper, "ArcaneFocusBound");
    if (GetLocalInt(oMeldshaper, "DiademPurelight")) 
    {
    	SetLocalInt(oMeldshaper, "PRCInLight", GetLocalInt(oMeldshaper, "PRCInLight")-1); 
    	DeleteLocalInt(oMeldshaper, "DiademPurelight");     
    }
    
    if (GetLocalInt(oMeldshaper, "PlanarChasubleLimit") > 7) 
    	DeleteLocalInt(oMeldshaper, "PlanarChasubleLimit");
    else
    	SetLocalInt(oMeldshaper, "PlanarChasubleLimit", GetLocalInt(oMeldshaper, "PlanarChasubleLimit")+1);
    
    DeleteLocalInt(oMeldshaper, "GorgonMaskLimit");
    DeleteLocalInt(oMeldshaper, "IncarnateAvatarSpeed");
    DeleteLocalInt(oMeldshaper, "LamiaBeltSpeed");
    DeleteLocalInt(oMeldshaper, "LifebondVestmentsTimer");
    DeleteLocalInt(oMeldshaper, "MidnightAugPower");
    DeleteLocalInt(oMeldshaper, "MeldEssentia18973"); // MELD_DUSKLING_SPEED
    DeleteLocalInt(oMeldshaper, "MeldEssentia18691"); // MELD_SPINE_ENHANCEMENT
    DeleteLocalInt(oMeldshaper, "MeldEssentia18687"); // MELD_IRONSOUL_SHIELD
    DeleteLocalInt(oMeldshaper, "MeldEssentia18685"); // MELD_IRONSOUL_ARMOR
    DeleteLocalInt(oMeldshaper, "MeldEssentia18683"); // MELD_IRONSOUL_WEAPON
    DeleteLocalInt(oMeldshaper, "MeldEssentia18681"); // MELD_UMBRAL_STEP  
    DeleteLocalInt(oMeldshaper, "MeldEssentia18679"); // MELD_UMBRAL_SHADOW
    DeleteLocalInt(oMeldshaper, "MeldEssentia18677"); // MELD_UMBRAL_SIGHT 
    DeleteLocalInt(oMeldshaper, "MeldEssentia18675"); // MELD_UMBRAL_SOUL  
    DeleteLocalInt(oMeldshaper, "MeldEssentia18673"); // MELD_UMBRAL_KISS  
    DeleteLocalInt(oMeldshaper, "MeldEssentia18670"); // MELD_INCANDESCENT_STRIKE
    DeleteLocalInt(oMeldshaper, "MeldEssentia18668"); // MELD_INCANDESCENT_HEAL       
    DeleteLocalInt(oMeldshaper, "MeldEssentia18666"); // MELD_INCANDESCENT_COUNTENANCE
    DeleteLocalInt(oMeldshaper, "MeldEssentia18663"); // MELD_INCANDESCENT_RAY        
    DeleteLocalInt(oMeldshaper, "MeldEssentia18659"); // MELD_INCANDESCENT_AURA    
    DeleteLocalInt(oMeldshaper, "MeldEssentia18634"); // MELD_WITCH_MELDSHIELD
    DeleteLocalInt(oMeldshaper, "MeldEssentia18636"); // MELD_WITCH_DISPEL    
    DeleteLocalInt(oMeldshaper, "MeldEssentia18638"); // MELD_WITCH_SHACKLES  
    DeleteLocalInt(oMeldshaper, "MeldEssentia18640"); // MELD_WITCH_ABROGATION
    DeleteLocalInt(oMeldshaper, "MeldEssentia18642"); // MELD_WITCH_SPIRITFLAY
    DeleteLocalInt(oMeldshaper, "MeldEssentia18644"); // MELD_WITCH_INTEGUMENT 
    DeleteLocalInt(oMeldshaper, "NecrocarnumCircletPen");
    DeleteLocalInt(oMeldshaper, "AstralVambraces");
    DeleteLocalInt(oMeldshaper, "TemporaryEssentia");
    DestroyObject(GetItemPossessedBy(oMeldshaper, "moi_incarnatewpn")); // Remove any weapons created by Incarnate Weapon
    
    // Clean up any the natural weapons that are lying around
    ClearNaturalWeapons(oMeldshaper);    
    // Nuke the creature weapons. If the normal form is supposed to have natural weapons, they'll get re-constructed
    if(GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oMeldshaper))) MyDestroyObject(GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oMeldshaper));
    if(GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oMeldshaper))) MyDestroyObject(GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oMeldshaper));
    if(GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oMeldshaper))) MyDestroyObject(GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oMeldshaper));    
    
    if (GetLocalInt(oMeldshaper, "ClearEventTotem")) ClearEventScriptList(oMeldshaper, EVENT_ITEM_ONHIT, TRUE, TRUE);   
} 

int GetShapedMeldsCount(object oMeldshaper)
{
	int i, nCount, nTest;
    for (i = 0; i <= 20; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_INCARNATE)+IntToString(i));
		if (nTest) // If it's not blank
			nCount++;	
		nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_SOULBORN)+IntToString(i));
		if (nTest) // If it's not blank
			nCount++;	
		nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_TOTEMIST)+IntToString(i));
		if (nTest) // If it's not blank
			nCount++;	
		nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_SPINEMELD_WARRIOR)+IntToString(i));
		if (nTest) // If it's not blank
			nCount++;				
    }
    //if (DEBUG) DoDebug("GetTotalShapedMelds is "+IntToString(nCount));
    return nCount;
}

int GetTotalShapedMelds(object oMeldshaper, int nClass)
{
	int i, nCount, nTest;
    for (i = 0; i <= 20; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(nClass)+IntToString(i));
		if (nTest) // If it's not blank
			nCount++;	
    }
    //if (DEBUG) DoDebug("GetTotalShapedMelds is "+IntToString(nCount));
    return nCount;
}

int CheckSplitChakra(object oMeldshaper, int nSlot)
{
	if (nSlot == INVENTORY_SLOT_HEAD  && GetHasFeat(FEAT_SPLIT_CHAKRA_CROWN    , oMeldshaper)) return TRUE;	
	if (nSlot == INVENTORY_SLOT_BOOTS && GetHasFeat(FEAT_SPLIT_CHAKRA_FEET     , oMeldshaper)) return TRUE;
	if (nSlot == INVENTORY_SLOT_ARMS  && GetHasFeat(FEAT_SPLIT_CHAKRA_HANDS    , oMeldshaper)) return TRUE;
	if (nSlot == INVENTORY_SLOT_ARMS  && GetHasFeat(FEAT_SPLIT_CHAKRA_ARMS     , oMeldshaper)) return TRUE;
	if (nSlot == INVENTORY_SLOT_HEAD  && GetHasFeat(FEAT_SPLIT_CHAKRA_BROW     , oMeldshaper)) return TRUE;
	if (nSlot == INVENTORY_SLOT_CLOAK && GetHasFeat(FEAT_SPLIT_CHAKRA_SHOULDERS, oMeldshaper)) return TRUE;
	if (nSlot == INVENTORY_SLOT_NECK  && GetHasFeat(FEAT_SPLIT_CHAKRA_THROAT   , oMeldshaper)) return TRUE;
	if (nSlot == INVENTORY_SLOT_BELT  && GetHasFeat(FEAT_SPLIT_CHAKRA_WAIST    , oMeldshaper)) return TRUE;
	if (nSlot == INVENTORY_SLOT_CHEST && GetHasFeat(FEAT_SPLIT_CHAKRA_HEART    , oMeldshaper)) return TRUE;	
	if (nSlot == INVENTORY_SLOT_CHEST && GetHasFeat(FEAT_SPLIT_CHAKRA_SOUL     , oMeldshaper)) return TRUE;
	
	return FALSE;	
}

void BindMeldToChakra(object oMeldshaper, int nMeld, int nChakra, int nClass)
{
	// Make sure it's not in use already, and that you have any binds to make
	if (!GetIsChakraBound(oMeldshaper, nChakra) && GetMaxBindCount(oMeldshaper, nClass))
	{
		//FloatingTextStringOnCreature("BindMeldToChakra: nMeld "+IntToString(nMeld)+" nChakra "+IntToString(nChakra), oMeldshaper);
		SetLocalInt(oMeldshaper, "BoundMeld"+IntToString(nChakra), nMeld);
		ShapeSoulmeld(oMeldshaper, nMeld);
		int nSlot = ChakraToSlot(DoubleChakraToChakra(nChakra)); // Can't have an item in a bound slot, unless Split Chakra
		if (!CheckSplitChakra(oMeldshaper, nSlot)) ForceUnequip(oMeldshaper, GetItemInSlot(nSlot, oMeldshaper), nSlot);
	}
}

int GetTotalBoundMelds(object oMeldshaper)
{
	int i, nCount, nTest;
    for (i = 0; i <= 22; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "BoundMeld"+IntToString(i));
		if (nTest) // If it's not blank
			nCount++;	
    }
    //if (DEBUG) DoDebug("GetTotalBoundMelds is "+IntToString(nCount));
    return nCount;
}

int GetIsChakraUsed(object oMeldshaper, int nChakra, int nClass)
{
	int nTest = GetLocalInt(oMeldshaper, "UsedMeld"+IntToString(nClass)+IntToString(nChakra));
	
    //if (DEBUG) DoDebug("GetIsChakraUsed is "+IntToString(nTest));
    return nTest;
}

void SetChakraUsed(object oMeldshaper, int nMeld, int nChakra, int nClass)
{
	// This isn't the same as binding, but can only have one soulmeld in each chakra
	// Each class has its own limit on this, as per p20 of MoI
	if (!GetIsChakraUsed(oMeldshaper, nChakra, nClass))
	{
		SetLocalInt(oMeldshaper, "UsedMeld"+IntToString(nClass)+IntToString(nChakra), nMeld);
	}
}

int ChakraToSlot(int nChakra)
{
	if (nChakra == CHAKRA_CROWN    ) return INVENTORY_SLOT_HEAD;	
	if (nChakra == CHAKRA_FEET     ) return INVENTORY_SLOT_BOOTS;
	if (nChakra == CHAKRA_HANDS    ) return INVENTORY_SLOT_ARMS;
	if (nChakra == CHAKRA_ARMS     ) return INVENTORY_SLOT_ARMS;
	if (nChakra == CHAKRA_BROW     ) return INVENTORY_SLOT_HEAD;
	if (nChakra == CHAKRA_SHOULDERS) return INVENTORY_SLOT_CLOAK;
	if (nChakra == CHAKRA_THROAT   ) return INVENTORY_SLOT_NECK;
	if (nChakra == CHAKRA_WAIST    ) return INVENTORY_SLOT_BELT;
	if (nChakra == CHAKRA_HEART    ) return INVENTORY_SLOT_CHEST;	
	if (nChakra == CHAKRA_SOUL     ) return INVENTORY_SLOT_CHEST;
	if (nChakra == CHAKRA_TOTEM    ) return -1; // no slot associated
	
	return -1;
}	

void ChakraBindUnequip(object oMeldshaper, object oItem)
{    
    int nTest = FALSE;
    if (GetItemInSlot(INVENTORY_SLOT_HEAD, oMeldshaper) == oItem && (GetIsChakraBound(oMeldshaper, CHAKRA_CROWN) || GetIsChakraBound(oMeldshaper, CHAKRA_BROW))) nTest = INVENTORY_SLOT_HEAD + 1;
    else if (GetItemInSlot(INVENTORY_SLOT_BOOTS, oMeldshaper) == oItem && GetIsChakraBound(oMeldshaper, CHAKRA_FEET)) nTest = INVENTORY_SLOT_BOOTS + 1;
    else if (GetItemInSlot(INVENTORY_SLOT_ARMS, oMeldshaper) == oItem && (GetIsChakraBound(oMeldshaper, CHAKRA_ARMS) || GetIsChakraBound(oMeldshaper, CHAKRA_HANDS))) nTest = INVENTORY_SLOT_ARMS + 1;
    else if (GetItemInSlot(INVENTORY_SLOT_CLOAK, oMeldshaper) == oItem && GetIsChakraBound(oMeldshaper, CHAKRA_SHOULDERS)) nTest = INVENTORY_SLOT_CLOAK + 1;
    else if (GetItemInSlot(INVENTORY_SLOT_NECK, oMeldshaper) == oItem && GetIsChakraBound(oMeldshaper, CHAKRA_THROAT)) nTest = INVENTORY_SLOT_NECK + 1;
    else if (GetItemInSlot(INVENTORY_SLOT_BELT, oMeldshaper) == oItem && GetIsChakraBound(oMeldshaper, CHAKRA_WAIST)) nTest = INVENTORY_SLOT_BELT + 1;
    else if (GetItemInSlot(INVENTORY_SLOT_CHEST, oMeldshaper) == oItem && (GetIsChakraBound(oMeldshaper, CHAKRA_SOUL) || GetIsChakraBound(oMeldshaper, CHAKRA_HEART))) nTest = INVENTORY_SLOT_CHEST + 1;
	//if (DEBUG) DoDebug("ChakraBindUnequip is "+IntToString(nTest-1));
	if (nTest && !CheckSplitChakra(oMeldshaper, nTest-1) && GetIsItemPropertyValid(GetFirstItemProperty(oItem)) && oItem != GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oMeldshaper) && oItem != GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oMeldshaper) &&
		   oItem != GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oMeldshaper) && oItem != GetItemInSlot(INVENTORY_SLOT_CARMOUR, oMeldshaper)) // If it's bound you can't equip in that slot
	{
		nTest = nTest - 1;
		ForceUnequip(oMeldshaper, GetItemInSlot(nTest, oMeldshaper), nTest);
		FloatingTextStringOnCreature("You cannot equip a magical item when you have bound a meld to the same chakra!", oMeldshaper, FALSE);
	}
}

string ChakraToString(int nChakra)
{
	string sReturn = "";
	if (nChakra == CHAKRA_CROWN     || nChakra == CHAKRA_DOUBLE_CROWN    ) sReturn = "Crown";	
	if (nChakra == CHAKRA_FEET      || nChakra == CHAKRA_DOUBLE_FEET     ) sReturn = "Feet";
	if (nChakra == CHAKRA_HANDS     || nChakra == CHAKRA_DOUBLE_HANDS    ) sReturn = "Hands";
	if (nChakra == CHAKRA_ARMS      || nChakra == CHAKRA_DOUBLE_ARMS     ) sReturn = "Arms";
	if (nChakra == CHAKRA_BROW      || nChakra == CHAKRA_DOUBLE_BROW     ) sReturn = "Brow";
	if (nChakra == CHAKRA_SHOULDERS || nChakra == CHAKRA_DOUBLE_SHOULDERS) sReturn = "Shoulders";
	if (nChakra == CHAKRA_THROAT    || nChakra == CHAKRA_DOUBLE_THROAT   ) sReturn = "Throat";
	if (nChakra == CHAKRA_WAIST     || nChakra == CHAKRA_DOUBLE_WAIST    ) sReturn = "Waist";
	if (nChakra == CHAKRA_HEART     || nChakra == CHAKRA_DOUBLE_HEART    ) sReturn = "Heart";	
	if (nChakra == CHAKRA_SOUL      || nChakra == CHAKRA_DOUBLE_SOUL     ) sReturn = "Soul";
	if (nChakra == CHAKRA_TOTEM     || nChakra == CHAKRA_DOUBLE_TOTEM    ) sReturn = "Totem";
	
	//if (DEBUG) DoDebug("ChakraToString is "+IntToString(nChakra)+", Return is "+sReturn);
	return sReturn;
}

int GetCanBindChakra(object oMeldshaper, int nChakra)
{
	if (nChakra == CHAKRA_CROWN &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 2)) return TRUE;
	else if (nChakra == CHAKRA_FEET &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 4)) return TRUE;	
	else if (nChakra == CHAKRA_HANDS &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 4)) return TRUE;
	else if (nChakra == CHAKRA_ARMS &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 9)) return TRUE;	
	else if (nChakra == CHAKRA_BROW &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 9)) return TRUE;	
	else if (nChakra == CHAKRA_SHOULDERS &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 9)) return TRUE;	
	else if (nChakra == CHAKRA_THROAT &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 14)) return TRUE;	
	else if (nChakra == CHAKRA_WAIST &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 14)) return TRUE;	
	else if (nChakra == CHAKRA_HEART &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 16)) return TRUE;	
	else if (nChakra == CHAKRA_SOUL &&
	   (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 19)) return TRUE;	
	   
	if (nChakra == CHAKRA_CROWN &&
	   (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) >= 8)) return TRUE;
	else if (nChakra == CHAKRA_FEET &&
	   (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) >= 8)) return TRUE;	
	else if (nChakra == CHAKRA_HANDS &&
	   (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) >= 8)) return TRUE;
	else if (nChakra == CHAKRA_ARMS &&
	   (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) >= 14)) return TRUE;	
	else if (nChakra == CHAKRA_BROW &&
	   (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) >= 14)) return TRUE;	
	else if (nChakra == CHAKRA_SHOULDERS &&
	   (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) >= 14)) return TRUE;	
	else if (nChakra == CHAKRA_THROAT &&
	   (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) >= 18)) return TRUE;	
	else if (nChakra == CHAKRA_WAIST &&
	   (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper) >= 18)) return TRUE;	 
	   
	if (nChakra == CHAKRA_CROWN &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 5)) return TRUE;
	else if (nChakra == CHAKRA_FEET &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 5)) return TRUE;	
	else if (nChakra == CHAKRA_HANDS &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 5)) return TRUE;
	else if (nChakra == CHAKRA_ARMS &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 9)) return TRUE;	
	else if (nChakra == CHAKRA_BROW &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 9)) return TRUE;	
	else if (nChakra == CHAKRA_SHOULDERS &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 9)) return TRUE;	
	else if (nChakra == CHAKRA_THROAT &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 14)) return TRUE;	
	else if (nChakra == CHAKRA_WAIST &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 14)) return TRUE;	
	else if (nChakra == CHAKRA_HEART &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 17)) return TRUE;	
	else if (nChakra == CHAKRA_TOTEM &&
	   (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 2)) return TRUE;	
	   
	if (nChakra == CHAKRA_ARMS &&
	   (GetLevelByClass(CLASS_TYPE_SPINEMELD_WARRIOR, oMeldshaper) >= 7)) return TRUE;	
	   
	if (nChakra == CHAKRA_CROWN &&
	   (GetLevelByClass(CLASS_TYPE_SOULCASTER, oMeldshaper) >= 3)) return TRUE;
	else if (nChakra == CHAKRA_FEET &&
	   (GetLevelByClass(CLASS_TYPE_SOULCASTER, oMeldshaper) >= 3)) return TRUE;	
	else if (nChakra == CHAKRA_HANDS &&
	   (GetLevelByClass(CLASS_TYPE_SOULCASTER, oMeldshaper) >= 3)) return TRUE;	   
	else if (nChakra == CHAKRA_ARMS &&
	   (GetLevelByClass(CLASS_TYPE_SOULCASTER, oMeldshaper) >= 8)) return TRUE;	
	else if (nChakra == CHAKRA_BROW &&
	   (GetLevelByClass(CLASS_TYPE_SOULCASTER, oMeldshaper) >= 8)) return TRUE;	
	else if (nChakra == CHAKRA_SHOULDERS &&
	   (GetLevelByClass(CLASS_TYPE_SOULCASTER, oMeldshaper) >= 8)) return TRUE;	

	if (nChakra == CHAKRA_ARMS &&
	   (GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oMeldshaper) >= 4)) return TRUE;
	else if (nChakra == CHAKRA_WAIST &&
	   (GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oMeldshaper) >= 6)) return TRUE;	
	else if (nChakra == CHAKRA_SHOULDERS &&
	   (GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oMeldshaper) >= 8)) return TRUE;	   
	else if (nChakra == CHAKRA_HEART &&
	   (GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oMeldshaper) >= 10)) return TRUE;	
	   
	if (nChakra == CHAKRA_CROWN &&
		(GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper) >=4)) return TRUE;
	else if (nChakra == CHAKRA_FEET &&
		(GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper) >=4)) return TRUE;   
	else if (nChakra == CHAKRA_HANDS &&
		(GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper) >=4)) return TRUE;	
	else if (nChakra == CHAKRA_ARMS &&
		(GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper) >=9)) return TRUE;
	else if (nChakra == CHAKRA_BROW &&
		(GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper) >=9)) return TRUE;
	else if (nChakra == CHAKRA_SHOULDERS &&
		(GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper) >=9)) return TRUE;
		
	if (nChakra == CHAKRA_ARMS &&
	   (GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper) >= 3)) return TRUE;	
	else if (nChakra == CHAKRA_BROW &&
	   (GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper) >= 3)) return TRUE;	
	else if (nChakra == CHAKRA_SHOULDERS &&
	   (GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper) >= 3)) return TRUE;	
	else if (nChakra == CHAKRA_THROAT &&
	   (GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper) >= 8)) return TRUE;	
	else if (nChakra == CHAKRA_WAIST &&
	   (GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper) >= 8)) return TRUE;	
	else if (nChakra == CHAKRA_HEART &&
	   (GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper) >= 11)) return TRUE;	
	else if (nChakra == CHAKRA_SOUL &&
	   (GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper) >= 13)) return TRUE;	
	   
	if (nChakra == CHAKRA_CROWN && GetHasFeat(FEAT_OPEN_LEAST_CHAKRA_CROWN, oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_FEET      && GetHasFeat(FEAT_OPEN_LEAST_CHAKRA_FEET      , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_HANDS     && GetHasFeat(FEAT_OPEN_LEAST_CHAKRA_HANDS     , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_ARMS      && GetHasFeat(FEAT_OPEN_LESSER_CHAKRA_ARMS     , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_BROW      && GetHasFeat(FEAT_OPEN_LESSER_CHAKRA_BROW     , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_SHOULDERS && GetHasFeat(FEAT_OPEN_LESSER_CHAKRA_SHOULDERS, oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_THROAT    && GetHasFeat(FEAT_OPEN_GREATER_CHAKRA_THROAT  , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_WAIST     && GetHasFeat(FEAT_OPEN_GREATER_CHAKRA_WAIST   , oMeldshaper)) return TRUE; 
	else if (nChakra == CHAKRA_HEART     && GetHasFeat(FEAT_OPEN_HEART_CHAKRA           , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_SOUL      && GetHasFeat(FEAT_OPEN_SOUL_CHAKRA            , oMeldshaper)) return TRUE;
	
	if (nChakra == CHAKRA_DOUBLE_CROWN && GetHasFeat(FEAT_DOUBLE_CHAKRA_CROWN, oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_FEET      && GetHasFeat(FEAT_DOUBLE_CHAKRA_FEET     , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_HANDS     && GetHasFeat(FEAT_DOUBLE_CHAKRA_HANDS    , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_ARMS      && GetHasFeat(FEAT_DOUBLE_CHAKRA_ARMS     , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_BROW      && GetHasFeat(FEAT_DOUBLE_CHAKRA_BROW     , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_SHOULDERS && GetHasFeat(FEAT_DOUBLE_CHAKRA_SHOULDERS, oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_THROAT    && GetHasFeat(FEAT_DOUBLE_CHAKRA_THROAT   , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_WAIST     && GetHasFeat(FEAT_DOUBLE_CHAKRA_WAIST    , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_HEART     && GetHasFeat(FEAT_DOUBLE_CHAKRA_HEART    , oMeldshaper)) return TRUE;
	else if (nChakra == CHAKRA_DOUBLE_SOUL      && GetHasFeat(FEAT_DOUBLE_CHAKRA_SOUL     , oMeldshaper)) return TRUE;	
	else if (nChakra == CHAKRA_DOUBLE_TOTEM     && GetHasFeat(FEAT_DOUBLE_CHAKRA_TOTEM    , oMeldshaper)) return TRUE;
	       
	return FALSE;   
}

int GetMaxEssentiaCount(object oMeldshaper, int nClass)
{
	int nMax = StringToInt(Get2DACache(GetMeldshapingClassFile(nClass), "Essentia", GetIncarnumLevelForClass(nClass, oMeldshaper)-1));
    //if (DEBUG) DoDebug("GetMaxEssentiaCount is "+IntToString(nMax));
    return nMax;
}

void SpawnTempEssentiaChecker(object oMeldshaper)
{
	int nCur = GetTemporaryEssentia(oMeldshaper);
	int nPrv = GetLocalInt(oMeldshaper, "TempEssTest");
	int nRed = nPrv - nCur;
	// If we've lost some
	if (nPrv > nCur)
	{
		int i, nCount, nTest;
    	for (i = 18700; i < 18799; i++)
    	{
			nTest = GetLocalInt(oMeldshaper, "TempEssentiaAmount"+IntToString(i));
			if (nTest) // If it's not blank
			{
				//if (DEBUG) DoDebug("Found "+IntToString(nTest)+" Temp Essentia in Meld "+IntToString(i));
				// There's still some temp essentia left in the meld
				if (nTest > nRed)
				{
					int nChange = nTest-nRed;
					SetLocalInt(oMeldshaper, "TempEssentiaAmount"+IntToString(i), nChange);
					SetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(i), GetEssentiaInvested(oMeldshaper, i)-nChange);
					ShapeSoulmeld(oMeldshaper, i);
					//if (DEBUG) DoDebug("Reducing Essentia in Meld "+IntToString(i)+" by "+IntToString(nChange));
				}
				else // Means the reduction is higher than the temp essentia ammount
				{
					// No more temp essentia here
					DeleteLocalInt(oMeldshaper, "TempEssentiaAmount"+IntToString(i));
					SetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(i), GetEssentiaInvested(oMeldshaper, i)-nTest);
					ShapeSoulmeld(oMeldshaper, i);
					//if (DEBUG) DoDebug("Deleted Temp Essentia in Meld "+IntToString(i)+", total "+IntToString(nTest));
				}
				
				// Reduce the remaining amount of reduction by the amount we just used up
				nRed = nRed - nTest;
				//if (DEBUG) DoDebug("Remaining Temp Essentia to reduce "+IntToString(nRed));
				if (0 >= nRed) break; // End the loop if we're done
			}	
    	}	
	}
	// If we still have some left
	if (nCur > 0) 
	{
		SetLocalInt(oMeldshaper, "TempEssTest", nCur);
		DelayCommand(1.0, SpawnTempEssentiaChecker(oMeldshaper));
	}
	else 
		DeleteLocalInt(oMeldshaper, "TempEssTest");
}

void InvestEssentia(object oMeldshaper, int nMeld, int nEssentia)
{
	// Use up expanded soulmeld capacity
	if (nEssentia > 1000) 
	{
		nEssentia -= 1000;
		SetIsSoulmeldCapacityUsed(oMeldshaper, nMeld);
	}
	int nClass = GetMeldShapedClass(oMeldshaper, nMeld);
	// Special capacity of 1/2 class level
	if (nMeld == MELD_SPINE_ENHANCEMENT) nEssentia = PRCMin(nEssentia, (GetLevelByClass(CLASS_TYPE_SPINEMELD_WARRIOR, oMeldshaper)/2));
	else if (nEssentia > GetMaxEssentiaCapacity(oMeldshaper, nClass, nMeld)) nEssentia = GetMaxEssentiaCapacity(oMeldshaper, nClass, nMeld);
	// Can't invest more than you have
	if (nEssentia > GetTotalUsableEssentia(oMeldshaper)) nEssentia = GetTotalUsableEssentia(oMeldshaper);
	
	// All of this garbage to handle temporary essentia
	if (GetLocalInt(oMeldshaper, "InvestingTempEssentia"))
	{
		SetLocalInt(oMeldshaper, "TempEssentiaAmount"+IntToString(nMeld), nEssentia);
		SpawnTempEssentiaChecker(oMeldshaper);
		DeleteLocalInt(oMeldshaper, "InvestingTempEssentia");
	}
	
	FloatingTextStringOnCreature("Investing "+IntToString(nEssentia)+" essentia into "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nMeld))), oMeldshaper, FALSE);
	SetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(nMeld), nEssentia);
	SetLocalInt(oMeldshaper, "EssentiaRound"+IntToString(nMeld), TRUE); // This is used by Melds that only trigger on the round that essentia is invested into it
	DelayCommand(6.0, DeleteLocalInt(oMeldshaper, "EssentiaRound"+IntToString(nMeld)));
}

int GetTotalEssentiaInvested(object oMeldshaper)
{
	int i, nCount, nTest;
    for (i = 18700; i < 18799; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(i));
		if (nTest) // If it's not blank
			nCount += nTest;	
    }
    nCount += GetFeatLockedEssentia(oMeldshaper);
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_SPINE_ENHANCEMENT)); // MELD_SPINE_ENHANCEMENT
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_IRONSOUL_SHIELD)); // MELD_IRONSOUL_SHIELD
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_IRONSOUL_ARMOR)); // MELD_IRONSOUL_ARMOR
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_IRONSOUL_WEAPON)); // MELD_IRONSOUL_WEAPON
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_STEP  )); // MELD_UMBRAL_STEP  
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_SHADOW)); // MELD_UMBRAL_SHADOW
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_SIGHT )); // MELD_UMBRAL_SIGHT 
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_SOUL  )); // MELD_UMBRAL_SOUL  
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_KISS  )); // MELD_UMBRAL_KISS  
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_DUSKLING_SPEED)); // MELD_DUSKLING_SPEED
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_STRIKE)); // MELD_INCANDESCENT_STRIKE
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_HEAL       )); // MELD_INCANDESCENT_HEAL       
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_COUNTENANCE)); // MELD_INCANDESCENT_COUNTENANCE
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_RAY        )); // MELD_INCANDESCENT_RAY        
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_AURA       )); // MELD_INCANDESCENT_AURA       
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_MELDSHIELD)); // MELD_WITCH_MELDSHIELD
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_DISPEL    )); // MELD_WITCH_DISPEL    
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_SHACKLES  )); // MELD_WITCH_SHACKLES  
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_ABROGATION)); // MELD_WITCH_ABROGATION
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_SPIRITFLAY)); // MELD_WITCH_SPIRITFLAY
    nCount += GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_INTEGUMENT)); // MELD_WITCH_INTEGUMENT   
    //if (DEBUG) DoDebug("GetTotalEssentiaInvested is "+IntToString(nCount));
    return nCount;
}

int EssentiaIDToRealID(int nEssentiaID)
{
	int i, nReal, nTest;
    for (i = 1; i < 100; i++)
    {
		nTest = StringToInt(Get2DACache("soulmelds", "EssentiaID", i));
		if (nTest == nEssentiaID) // If it's been found
		{
			nReal = StringToInt(Get2DACache("soulmelds", "SpellID", i));	
			break;
		}	
    }
    
    if (nEssentiaID == 18690) nReal = MELD_SPINE_ENHANCEMENT;
    else if (nEssentiaID == 18686) nReal = MELD_IRONSOUL_SHIELD;
    else if (nEssentiaID == 18684) nReal = MELD_IRONSOUL_ARMOR;
    else if (nEssentiaID == 18682) nReal = MELD_IRONSOUL_WEAPON;
    else if (nEssentiaID == 18680) nReal = MELD_UMBRAL_STEP;
    else if (nEssentiaID == 18678) nReal = MELD_UMBRAL_SHADOW;
    else if (nEssentiaID == 18676) nReal = MELD_UMBRAL_SIGHT;
    else if (nEssentiaID == 18674) nReal = MELD_UMBRAL_SOUL;
    else if (nEssentiaID == 18672) nReal = MELD_UMBRAL_KISS;
    else if (nEssentiaID == 18669) nReal = MELD_INCANDESCENT_STRIKE;
    else if (nEssentiaID == 18667) nReal = MELD_INCANDESCENT_HEAL       ;
    else if (nEssentiaID == 18665) nReal = MELD_INCANDESCENT_COUNTENANCE;
    else if (nEssentiaID == 18662) nReal = MELD_INCANDESCENT_RAY        ;
    else if (nEssentiaID == 18661) nReal = MELD_INCANDESCENT_AURA       ;
    else if (nEssentiaID == 18633) nReal = MELD_WITCH_MELDSHIELD;
    else if (nEssentiaID == 18635) nReal = MELD_WITCH_DISPEL;    
    else if (nEssentiaID == 18637) nReal = MELD_WITCH_SHACKLES;
    else if (nEssentiaID == 18639) nReal = MELD_WITCH_ABROGATION;
    else if (nEssentiaID == 18641) nReal = MELD_WITCH_SPIRITFLAY;
    else if (nEssentiaID == 18643) nReal = MELD_WITCH_INTEGUMENT;    
    
    //if (DEBUG) DoDebug("EssentiaToRealID: nEssentiaID "+IntToString(nEssentiaID)+" nReal "+IntToString(nReal));
    return nReal; // Return the real spellID
}

void DrainEssentia(object oMeldshaper)
{
	//FloatingTextStringOnCreature("DrainEssentia", oMeldshaper);
	int i;
    for (i = 18700; i < 18799; i++)
    {
		DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(i));
    }  
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_DUSKLING_SPEED));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_SPINE_ENHANCEMENT));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_IRONSOUL_SHIELD));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_IRONSOUL_ARMOR));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_IRONSOUL_WEAPON));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_STEP  ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_SHADOW));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_SIGHT ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_SOUL  ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_UMBRAL_KISS  ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_STRIKE));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_HEAL       ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_COUNTENANCE));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_RAY        ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_INCANDESCENT_AURA       ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_MELDSHIELD));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_DISPEL    ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_SHACKLES  ));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_ABROGATION));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_SPIRITFLAY));
    DeleteLocalInt(oMeldshaper, "MeldEssentia"+IntToString(MELD_WITCH_INTEGUMENT));    
}

void WipeMelds(object oMeldshaper)
{
	//FloatingTextStringOnCreature("WipeMelds", oMeldshaper);
	int i;
    for (i = 18700; i < 18799; i++)
    {
		PRCRemoveSpellEffects(i, oMeldshaper, oMeldshaper);
		GZPRCRemoveSpellEffects(i, oMeldshaper, FALSE);
    }
    PRCRemoveSpellEffects(MELD_DUSKLING_SPEED, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_DUSKLING_SPEED, oMeldshaper, FALSE);
    PRCRemoveSpellEffects(MELD_SPINE_ENHANCEMENT, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_SPINE_ENHANCEMENT, oMeldshaper, FALSE);    
    PRCRemoveSpellEffects(MELD_IRONSOUL_SHIELD, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_IRONSOUL_SHIELD, oMeldshaper, FALSE);  
    PRCRemoveSpellEffects(MELD_IRONSOUL_ARMOR, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_IRONSOUL_ARMOR, oMeldshaper, FALSE);  
    PRCRemoveSpellEffects(MELD_IRONSOUL_WEAPON, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_IRONSOUL_WEAPON, oMeldshaper, FALSE);          
    PRCRemoveSpellEffects(MELD_UMBRAL_STEP, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_UMBRAL_STEP, oMeldshaper, FALSE);      
    PRCRemoveSpellEffects(MELD_UMBRAL_SHADOW, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_UMBRAL_SHADOW, oMeldshaper, FALSE);      
    PRCRemoveSpellEffects(MELD_UMBRAL_SIGHT, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_UMBRAL_SIGHT, oMeldshaper, FALSE);      
    PRCRemoveSpellEffects(MELD_UMBRAL_SOUL, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_UMBRAL_SOUL, oMeldshaper, FALSE);      
    PRCRemoveSpellEffects(MELD_UMBRAL_KISS, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_UMBRAL_KISS, oMeldshaper, FALSE);          
    PRCRemoveSpellEffects(MELD_INCANDESCENT_STRIKE, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_INCANDESCENT_STRIKE, oMeldshaper, FALSE); 
    PRCRemoveSpellEffects(MELD_WITCH_MELDSHIELD, oMeldshaper, oMeldshaper);
    GZPRCRemoveSpellEffects(MELD_WITCH_MELDSHIELD, oMeldshaper, FALSE);     
    for (i = 18647; i < 18657; i++)
    {
		PRCRemoveSpellEffects(i, oMeldshaper, oMeldshaper);
		GZPRCRemoveSpellEffects(i, oMeldshaper, FALSE);
    }    
}

void ReshapeMelds(object oMeldshaper)
{
	// Check each class and run the loop
	if (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper))
	{
		int i, nTest;
    	for (i = 0; i <= 20; i++)
    	{
			nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_INCARNATE)+IntToString(i));
			if (nTest) // If it's not blank, recast it
			{
				//FloatingTextStringOnCreature("ReshapeMelds: CLASS_TYPE_INCARNATE nTest "+IntToString(nTest), oMeldshaper);
				ActionCastSpellOnSelf(nTest);
			}	
    	}
    }
	if (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper))
	{
		int i, nTest;
    	for (i = 0; i <= 20; i++)
    	{
			nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_SOULBORN)+IntToString(i));
			if (nTest) // If it's not blank, recast it
			{
				//FloatingTextStringOnCreature("ReshapeMelds: CLASS_TYPE_SOULBORN nTest "+IntToString(nTest), oMeldshaper);
				ActionCastSpellOnSelf(nTest);
			}	
    	}
    }
	if (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper))
	{
		int i, nTest;
    	for (i = 0; i <= 20; i++)
    	{
			nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_TOTEMIST)+IntToString(i));
			if (nTest) // If it's not blank, recast it
			{
				//FloatingTextStringOnCreature("ReshapeMelds: CLASS_TYPE_TOTEMIST nTest "+IntToString(nTest), oMeldshaper);
				ActionCastSpellOnSelf(nTest);
			}	
    	}
    }    
	if (GetLevelByClass(CLASS_TYPE_SPINEMELD_WARRIOR, oMeldshaper))
	{
		ActionCastSpellOnSelf(MELD_SPINE_ENHANCEMENT);
		int i, nTest;
    	for (i = 0; i <= 20; i++)
    	{
			nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(CLASS_TYPE_SPINEMELD_WARRIOR)+IntToString(i));
			if (nTest) // If it's not blank, recast it
			{
				//FloatingTextStringOnCreature("ReshapeMelds: CLASS_TYPE_TOTEMIST nTest "+IntToString(nTest), oMeldshaper);
				ActionCastSpellOnSelf(nTest);
			}	
    	}
    }     
    int nIron = GetLevelByClass(CLASS_TYPE_IRONSOUL_FORGEMASTER, oMeldshaper);
	if (nIron)
	{
		ActionCastSpellOnSelf(MELD_IRONSOUL_SHIELD);
		if (nIron >= 5) ActionCastSpellOnSelf(MELD_IRONSOUL_ARMOR);
		if (nIron >= 9) ActionCastSpellOnSelf(MELD_IRONSOUL_WEAPON);		
	}
    int nUmbral = GetLevelByClass(CLASS_TYPE_UMBRAL_DISCIPLE, oMeldshaper);
	if (nUmbral)
	{
		ActionCastSpellOnSelf(MELD_UMBRAL_STEP);
		if (nUmbral >= 3) ActionCastSpellOnSelf(MELD_UMBRAL_SHADOW);
		if (nUmbral >= 7) ActionCastSpellOnSelf(MELD_UMBRAL_SIGHT);		
		if (nUmbral >= 9) ActionCastSpellOnSelf(MELD_UMBRAL_SOUL);
		if (nUmbral >= 10) ActionCastSpellOnSelf(MELD_UMBRAL_KISS);
	}	
    int nIncand = GetLevelByClass(CLASS_TYPE_INCANDESCENT_CHAMPION, oMeldshaper);
	if (nIncand)
	{
		ActionCastSpellOnSelf(MELD_INCANDESCENT_STRIKE);
	}	
	if(GetLevelByClass(CLASS_TYPE_WITCHBORN_BINDER, oMeldshaper)) ActionCastSpellOnSelf(MELD_WITCH_MELDSHIELD);
    if (GetRacialType(oMeldshaper) == RACIAL_TYPE_DUSKLING) ActionCastSpellOnSelf(MELD_DUSKLING_SPEED);
}

int EssentiaToD4(int nEssentia)
{
	if (nEssentia == 1    )   return IP_CONST_DAMAGEBONUS_1d4;	
	else if (nEssentia == 2)  return IP_CONST_DAMAGEBONUS_2d4;
	else if (nEssentia == 3)  return IP_CONST_DAMAGEBONUS_3d4;
	else if (nEssentia == 4)  return IP_CONST_DAMAGEBONUS_4d4;
	else if (nEssentia == 5)  return IP_CONST_DAMAGEBONUS_5d4;
	else if (nEssentia == 6)  return IP_CONST_DAMAGEBONUS_6d4;
	else if (nEssentia == 7)  return IP_CONST_DAMAGEBONUS_7d4;
	else if (nEssentia == 8)  return IP_CONST_DAMAGEBONUS_8d4;
	else if (nEssentia == 9)  return IP_CONST_DAMAGEBONUS_9d4;	
	else if (nEssentia >= 10) return IP_CONST_DAMAGEBONUS_10d4;
	
	return -1;
}

int IncarnateAlignment(object oMeldshaper)
{
	int nReturn = FALSE;
	
	if (GetAlignmentLawChaos(oMeldshaper) == ALIGNMENT_LAWFUL && GetAlignmentGoodEvil(oMeldshaper) == ALIGNMENT_NEUTRAL)
	{
		nReturn = TRUE;
	}
	else if (GetAlignmentLawChaos(oMeldshaper) == ALIGNMENT_CHAOTIC && GetAlignmentGoodEvil(oMeldshaper) == ALIGNMENT_NEUTRAL)
	{
		nReturn = TRUE;
	}	
	else if (GetAlignmentLawChaos(oMeldshaper) == ALIGNMENT_NEUTRAL && GetAlignmentGoodEvil(oMeldshaper) == ALIGNMENT_GOOD)
	{
		nReturn = TRUE;
	}
	else if (GetAlignmentLawChaos(oMeldshaper) == ALIGNMENT_NEUTRAL && GetAlignmentGoodEvil(oMeldshaper) == ALIGNMENT_EVIL)
	{
		nReturn = TRUE;
	}
	
	return nReturn;
}

int GetOpposition(object oMeldshaper, object oTarget)
{
	int nReturn = FALSE;
	if (GetAlignmentLawChaos(oMeldshaper) == ALIGNMENT_LAWFUL && GetAlignmentGoodEvil(oMeldshaper) == ALIGNMENT_GOOD && (GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL || GetAlignmentLawChaos(oTarget) == ALIGNMENT_CHAOTIC))
		nReturn = TRUE;
	if (GetAlignmentLawChaos(oMeldshaper) == ALIGNMENT_LAWFUL && GetAlignmentGoodEvil(oMeldshaper) == ALIGNMENT_EVIL && (GetAlignmentGoodEvil(oTarget) == ALIGNMENT_GOOD || GetAlignmentLawChaos(oTarget) == ALIGNMENT_CHAOTIC))
		nReturn = TRUE;
	if (GetAlignmentLawChaos(oMeldshaper) == ALIGNMENT_CHAOTIC && GetAlignmentGoodEvil(oMeldshaper) == ALIGNMENT_GOOD && (GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL || GetAlignmentLawChaos(oTarget) == ALIGNMENT_LAWFUL))
		nReturn = TRUE;
	if (GetAlignmentLawChaos(oMeldshaper) == ALIGNMENT_CHAOTIC && GetAlignmentGoodEvil(oMeldshaper) == ALIGNMENT_EVIL && (GetAlignmentGoodEvil(oTarget) == ALIGNMENT_GOOD || GetAlignmentLawChaos(oTarget) == ALIGNMENT_LAWFUL))
		nReturn = TRUE;	
		
	return nReturn;	
}

void SetTemporaryEssentia(object oMeldshaper, int nEssentia)
{
	//if (DEBUG) DoDebug("Set Temporary Essentia from "+IntToString(GetLocalInt(oMeldshaper, "TemporaryEssentia"))+" to "+IntToString(GetLocalInt(oMeldshaper, "TemporaryEssentia")+nEssentia));
	SetLocalInt(oMeldshaper, "TemporaryEssentia", GetLocalInt(oMeldshaper, "TemporaryEssentia")+nEssentia);
}

int GetTemporaryEssentia(object oMeldshaper)
{
	return GetLocalInt(oMeldshaper, "TemporaryEssentia");
}

int GetMaxEssentiaCapacityFeat(object oMeldshaper)
{
	int nMax = 1; // Always can invest one
	int nHD = GetHitDice(oMeldshaper);
	if (nHD >= 61) nMax = 8;
	else if (nHD >= 51) nMax = 7;
	else if (nHD >= 41) nMax = 6;
	else if (nHD >= 31) nMax = 5;	
	else if (nHD >= 18) nMax = 4;
	else if (nHD >= 12) nMax = 3;
	else if (nHD >= 6) nMax = 2;
	
	if (GetLocalInt(oMeldshaper, "DivineSoultouch")) nMax += 1;
	if (GetLocalInt(oMeldshaper, "IncandescentOverload")) nMax += PRCMax(GetAbilityModifier(ABILITY_CHARISMA, oMeldshaper), 1);
	if (GetHasFeat(FEAT_IMPROVED_ESSENTIA_CAPACITY, oMeldshaper)) nMax += 1;
	
	// Don't allow more than they have
	if (nMax > GetTotalUsableEssentia(oMeldshaper)) nMax = GetTotalUsableEssentia(oMeldshaper);

	if(DEBUG) DoDebug("GetMaxEssentiaCapacityFeat: nHD "+IntToString(nHD)+" nMax "+IntToString(nMax));
	return nMax;
}

void SapphireSmiteUses(object oMeldshaper, int nEssentia)
{
	int i;

    for (i = 1; i <= nEssentia; i++)
    {
		IncrementRemainingFeatUses(oMeldshaper, FEAT_SMITE_GOOD_ALIGN); // Fist of Raziel
		IncrementRemainingFeatUses(oMeldshaper, FEAT_SMITE_EVIL); // Paladin
		IncrementRemainingFeatUses(oMeldshaper, FEAT_SMITE_GOOD); // Blackguard
		IncrementRemainingFeatUses(oMeldshaper, FEAT_KIAI_SMITE); // CW Samurai		
		IncrementRemainingFeatUses(oMeldshaper, FEAT_CRUSADER_SMITE); // Crusader
		IncrementRemainingFeatUses(oMeldshaper, FEAT_SMITE_UNDEAD); // Soldier of Light
		IncrementRemainingFeatUses(oMeldshaper, FEAT_SHADOWBANE_SMITE); // Shadowbane
		IncrementRemainingFeatUses(oMeldshaper, FEAT_KILLOREN_ASPECT_D); // Killoren
		IncrementRemainingFeatUses(oMeldshaper, FEAT_SMITE_OPPOSITION); // Soulborn
		IncrementRemainingFeatUses(oMeldshaper, FEAT_CULTIST_SMITE_MAGE); // Cultist of the Shattered Peak
    }
}

void AzureEnmity(object oMeldshaper, int nEssentia)
{
	effect eLink = EffectLinkEffects(EffectSkillIncrease(SKILL_BLUFF, nEssentia), EffectSkillIncrease(SKILL_LISTEN, nEssentia));
	       eLink = EffectLinkEffects(eLink, EffectSkillIncrease(SKILL_SENSE_MOTIVE, nEssentia));
	       eLink = EffectLinkEffects(eLink, EffectSkillIncrease(SKILL_SPOT, nEssentia));
	       eLink = EffectLinkEffects(eLink, EffectDamageIncrease(IPGetDamageBonusConstantFromNumber(nEssentia), DAMAGE_TYPE_BASE_WEAPON));

    if(GetHasFeat(FEAT_FAVORED_ENEMY_ABERRATION, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_ABERRATION)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_ANIMAL, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_ANIMAL)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_BEAST, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_BEAST)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_CONSTRUCT, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_CONSTRUCT)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_DRAGON, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_DRAGON)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_DWARF, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_DWARF)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_ELEMENTAL, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_ELEMENTAL)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_ELF, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_ELF)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_FEY, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_FEY)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_GIANT, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_GIANT)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_GNOME, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_GNOME)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_GOBLINOID, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_HUMANOID_GOBLINOID)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_HALFELF, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_HALFELF)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_HALFLING, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_HALFLING)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_HALFORC, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_HALFORC)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_HUMAN, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_HUMAN)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_MAGICAL_BEAST, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_MAGICAL_BEAST)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_MONSTROUS, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_HUMANOID_MONSTROUS)), oMeldshaper, 9999.0);
    if(GetHasFeat(RACIAL_TYPE_HUMANOID_ORC, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_HUMANOID_ORC)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_OUTSIDER, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_OUTSIDER)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_REPTILIAN, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_HUMANOID_REPTILIAN)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_SHAPECHANGER, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_SHAPECHANGER)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_UNDEAD, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_UNDEAD)), oMeldshaper, 9999.0);
    if(GetHasFeat(FEAT_FAVORED_ENEMY_VERMIN, oMeldshaper))
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(VersusRacialTypeEffect(eLink, RACIAL_TYPE_VERMIN)), oMeldshaper, 9999.0);
}

void DoFeatBonus(object oMeldshaper, int nFeat, int nEssentia)
{
	effect eLink;
	if (nFeat == FEAT_CERULEAN_FORTITUDE) eLink = EffectSavingThrowIncrease(SAVING_THROW_FORT, nEssentia);
	else if (nFeat == FEAT_CERULEAN_REFLEXES) eLink = EffectSavingThrowIncrease(SAVING_THROW_REFLEX, nEssentia);
	else if (nFeat == FEAT_CERULEAN_WILL) eLink = EffectSavingThrowIncrease(SAVING_THROW_WILL, nEssentia);
	else if (nFeat == FEAT_AZURE_TALENT) ExecuteScript("moi_ft_aztalent", oMeldshaper);
	else if (nFeat == FEAT_AZURE_TOUGHNESS) eLink = EffectTemporaryHitpoints(3*nEssentia);
	else if (nFeat == FEAT_HEALING_SOUL) FeatUsePerDay(oMeldshaper, FEAT_HEALING_SOUL, -1, 0, nEssentia);
	else if (nFeat == FEAT_SAPPHIRE_SMITE) SapphireSmiteUses(oMeldshaper, nEssentia);
	else if (nFeat == FEAT_AZURE_ENMITY) AzureEnmity(oMeldshaper, nEssentia);
	
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(eLink), oMeldshaper, 9999.0);
}

void InvestEssentiaFeat(object oMeldshaper, int nFeat, int nEssentia)
{
	// Jump out if there's no feat
	if (!GetHasFeat(nFeat, oMeldshaper)) return;
	
	int nMax = GetMaxEssentiaCapacityFeat(oMeldshaper);
	
	// Bonuses to specific feat caps
	if (nFeat == FEAT_COBALT_RAGE && GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper)) nMax++;
	
	// No breaking the rules
	if (nEssentia > nMax) nEssentia = nMax;
	// Can't invest more than you have
	if (nEssentia > GetTotalUsableEssentia(oMeldshaper)) nEssentia = GetTotalUsableEssentia(oMeldshaper);	
	
	FloatingTextStringOnCreature("Investing "+IntToString(nEssentia)+" essentia into "+GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", nFeat))), oMeldshaper);
	DoFeatBonus(oMeldshaper, nFeat, nEssentia);
	SetLocalInt(oMeldshaper, "FeatEssentia"+IntToString(nFeat), nEssentia);
}

void DoClassBonus(object oMeldshaper, int nFeat, int nEssentia)
{

}

void InvestEssentiaClass(object oMeldshaper, int nFeat, int nEssentia)
{
	// Jump out if there's no feat
	if (!GetHasFeat(nFeat, oMeldshaper)) return;
	
	// No breaking the rules
	if (nEssentia > GetMaxEssentiaCapacityFeat(oMeldshaper)) nEssentia = GetMaxEssentiaCapacityFeat(oMeldshaper);
	// Can't invest more than you have
	if (nEssentia > GetTotalUsableEssentia(oMeldshaper)) nEssentia = GetTotalUsableEssentia(oMeldshaper);	
	
	FloatingTextStringOnCreature("Investing "+IntToString(nEssentia)+" essentia into "+GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", nFeat))), oMeldshaper);
	DoClassBonus(oMeldshaper, nFeat, nEssentia);
	SetLocalInt(oMeldshaper, "ClassEssentia"+IntToString(nFeat), nEssentia);
}

void InvestEssentiaSpell(object oMeldshaper, int nFeat, int nEssentia)
{
	FloatingTextStringOnCreature("Investing "+IntToString(nEssentia)+" essentia into "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nFeat))), oMeldshaper);
	SetLocalInt(oMeldshaper, "SpellEssentia"+IntToString(nFeat), nEssentia);
	if (!GetLocalInt(oMeldshaper, "SpellInvestCheck1")) SetLocalInt(oMeldshaper, "SpellInvestCheck1", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck2")) SetLocalInt(oMeldshaper, "SpellInvestCheck2", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck3")) SetLocalInt(oMeldshaper, "SpellInvestCheck3", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck4")) SetLocalInt(oMeldshaper, "SpellInvestCheck4", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck5")) SetLocalInt(oMeldshaper, "SpellInvestCheck5", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck6")) SetLocalInt(oMeldshaper, "SpellInvestCheck6", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck7")) SetLocalInt(oMeldshaper, "SpellInvestCheck7", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck8")) SetLocalInt(oMeldshaper, "SpellInvestCheck8", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck9")) SetLocalInt(oMeldshaper, "SpellInvestCheck9", nFeat);
	else if (!GetLocalInt(oMeldshaper, "SpellInvestCheck10")) SetLocalInt(oMeldshaper, "SpellInvestCheck10", nFeat);
}

int GetFeatLockedEssentia(object oMeldshaper)
{
	int nTotal, i, nTest;
    for (i = 8869; i < 8889; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "FeatEssentia"+IntToString(i));
		if (nTest) // If it's not blank
			nTotal += nTest;	
    } 
    for (i = 0; i < 11; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "SpellInvestCheck"+IntToString(i));
		if (nTest) // If it's not blank
			nTotal += GetLocalInt(oMeldshaper, "SpellEssentia"+IntToString(nTest));	
    }     
    //if (DEBUG) DoDebug("GetFeatLockedEssentia return value "+IntToString(nTotal));
    return nTotal;
}

int IncarnumFeats(object oMeldshaper)
{
	int nEssentia;
	
	if (GetHasFeat(FEAT_AZURE_ENMITY, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_CERULEAN_FORTITUDE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_CERULEAN_REFLEXES, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_CERULEAN_WILL, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_AZURE_TALENT, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_AZURE_TOUCH, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_AZURE_TOUGHNESS, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_AZURE_TURNING, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_AZURE_WILD_SHAPE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_COBALT_CHARGE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_COBALT_EXPERTISE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_COBALT_POWER, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_COBALT_RAGE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_HEALING_SOUL, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_INCARNUM_SPELLSHAPING, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_INDIGO_STRIKE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_MIDNIGHT_AUGMENTATION, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_MIDNIGHT_DODGE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_MIDNIGHT_METAMAGIC, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_PSYCARNUM_BLADE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_SAPPHIRE_SMITE, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_SOULTOUCHED_SPELLCASTING, oMeldshaper)) nEssentia += 1;
	if (GetHasFeat(FEAT_BONUS_ESSENTIA, oMeldshaper)) 
	{	
		nEssentia += 1;
		if(GetIsIncarnumUser(oMeldshaper))
			nEssentia += 1; // Yes, this is correct
	}		
	if (GetRacialType(oMeldshaper) == RACIAL_TYPE_DUSKLING) nEssentia += 1;
	if (GetRacialType(oMeldshaper) == RACIAL_TYPE_AZURIN) nEssentia += 1;

   	int i;
   	for(i = FEAT_EPIC_ESSENTIA_1; i <= FEAT_EPIC_ESSENTIA_6; i++)
   	    if(GetHasFeat(i, oMeldshaper)) nEssentia += 3;
	
	//if (DEBUG) DoDebug("IncarnumFeats return value "+IntToString(nEssentia));
	return nEssentia;
}

void AddNecrocarnumEssentia(object oMeldshaper, int nEssentia)
{
	int nNecrocarnum = GetLocalInt(oMeldshaper, "NecrocarnumEssentia");
	SetLocalInt(oMeldshaper, "NecrocarnumEssentia", nNecrocarnum+nEssentia);
	// It lasts for 24 hours, then remove it back out
	DelayCommand(HoursToSeconds(24), SetLocalInt(oMeldshaper, "NecrocarnumEssentia", GetLocalInt(oMeldshaper, "NecrocarnumEssentia")-nEssentia));
}

int GetTotalEssentia(object oMeldshaper)
{
	int nEssentia;
	
	if (GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper)) nEssentia += GetMaxEssentiaCount(oMeldshaper, CLASS_TYPE_INCARNATE);
	if (GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper))  nEssentia += GetMaxEssentiaCount(oMeldshaper, CLASS_TYPE_SOULBORN);
	if (GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper))  nEssentia += GetMaxEssentiaCount(oMeldshaper, CLASS_TYPE_TOTEMIST);
	if (GetLevelByClass(CLASS_TYPE_SPINEMELD_WARRIOR, oMeldshaper))  nEssentia += GetMaxEssentiaCount(oMeldshaper, CLASS_TYPE_SPINEMELD_WARRIOR);
	if (GetLevelByClass(CLASS_TYPE_UMBRAL_DISCIPLE, oMeldshaper))  nEssentia += GetMaxEssentiaCount(oMeldshaper, CLASS_TYPE_UMBRAL_DISCIPLE);
	if (GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper)) nEssentia += GetLocalInt(oMeldshaper, "NecrocarnumEssentia");
	if (GetLevelByClass(CLASS_TYPE_WITCHBORN_BINDER, oMeldshaper) >= 2) nEssentia += 1;
	if (GetLevelByClass(CLASS_TYPE_WITCHBORN_BINDER, oMeldshaper) >= 6) nEssentia += 1;
	if (GetLevelByClass(CLASS_TYPE_INCANDESCENT_CHAMPION, oMeldshaper))  nEssentia += GetMaxEssentiaCount(oMeldshaper, CLASS_TYPE_INCANDESCENT_CHAMPION);
	
	nEssentia += IncarnumFeats(oMeldshaper);
	//if (DEBUG) DoDebug("GetTotalEssentia return value "+IntToString(nEssentia));
	return nEssentia;
}

int GetTotalUsableEssentia(object oMeldshaper)  
{  
    int nBase = GetTotalEssentia(oMeldshaper) - GetFeatLockedEssentia(oMeldshaper);  
      
    // Add Incarnum Overload bonus if active  
    if(GetLocalInt(oMeldshaper, "IncandescentOverload"))  
    {  
        int nChaBonus = GetAbilityModifier(ABILITY_CHARISMA, oMeldshaper);  
        if(nChaBonus < 1) nChaBonus = 1;  
        nBase += nChaBonus;  
    }  
      
    return nBase;  
}

/* int GetTotalUsableEssentia(object oMeldshaper)
{
	return GetTotalEssentia(oMeldshaper) - GetFeatLockedEssentia(oMeldshaper);
} */

int GetIncarnumFeats(object oMeldshaper)
{
	int nTotal, i;
    for (i = 8868; i < 8910; i++)
    {
		if (GetHasFeat(i, oMeldshaper)) 
			nTotal += 1;	
    }  
    //if (DEBUG) DoDebug("GetIncarnumFeats return value "+IntToString(nTotal));
    return nTotal;
}

int GetIsBlademeldUsed(object oMeldshaper, int nChakra)
{
	int nTest = GetLocalInt(oMeldshaper, "UsedBladeMeld"+IntToString(nChakra));
	
    //if (DEBUG) DoDebug("GetIsBlademeldUsed is "+IntToString(nTest));
    return nTest;
}

void SetBlademeldUsed(object oMeldshaper, int nChakra)
{
	if (!GetIsBlademeldUsed(oMeldshaper, nChakra))
	{
		SetLocalInt(oMeldshaper, "UsedBladeMeld"+IntToString(nChakra), nChakra);
	}
}

string GetBlademeldDesc(int nChakra)
{
	string sString;
	if (nChakra == CHAKRA_CROWN    ) sString = "You gain a +4 bonus on disarm checks and on Sense Motive";
	if (nChakra == CHAKRA_FEET     ) sString = "You gain a +2 bonus on Initiative";
	if (nChakra == CHAKRA_HANDS    ) sString = "You gain a +1 bonus on damage";
	if (nChakra == CHAKRA_ARMS     ) sString = "You gain a +2 bonus on attack rolls";
	if (nChakra == CHAKRA_BROW     ) sString = "You gain the Blind-Fight feat";
	if (nChakra == CHAKRA_SHOULDERS) sString = "You gain immunity to criticals but not sneak attacks";
	if (nChakra == CHAKRA_THROAT   ) sString = "At will as a standard action, each enemy within 60 feet who can hear you shout must save or become shaken for 1 round (Will DC 10 + incarnum blade level + Con modifier).";
	if (nChakra == CHAKRA_WAIST    ) sString = "You gain a +10 bonus on checks made to avoid being bull rushed, grappled, tripped, or overrun. You also gain Uncanny Dodge";
	if (nChakra == CHAKRA_HEART    ) sString = "You gain temporary hit points equal to twice your character level (maximum +40)";
	if (nChakra == CHAKRA_SOUL     ) sString = "You break DR up to +3, and deal 1d6 damage to creatures of one opposed alignment";
    
	return sString;
}

int ChakraToBlademeld(int nChakra)
{
	int nMeld;
	if (nChakra == CHAKRA_CROWN    ) nMeld = MELD_BLADEMELD_CROWN;    
	if (nChakra == CHAKRA_FEET     ) nMeld = MELD_BLADEMELD_FEET;     
	if (nChakra == CHAKRA_HANDS    ) nMeld = MELD_BLADEMELD_HANDS;    
	if (nChakra == CHAKRA_ARMS     ) nMeld = MELD_BLADEMELD_ARMS;     
	if (nChakra == CHAKRA_BROW     ) nMeld = MELD_BLADEMELD_BROW;     
	if (nChakra == CHAKRA_SHOULDERS) nMeld = MELD_BLADEMELD_SHOULDERS;
	if (nChakra == CHAKRA_THROAT   ) nMeld = MELD_BLADEMELD_THROAT;   
	if (nChakra == CHAKRA_WAIST    ) nMeld = MELD_BLADEMELD_WAIST;    
	if (nChakra == CHAKRA_HEART    ) nMeld = MELD_BLADEMELD_HEART;    
	if (nChakra == CHAKRA_SOUL     ) nMeld = MELD_BLADEMELD_SOUL;     
    
	return nMeld;
}