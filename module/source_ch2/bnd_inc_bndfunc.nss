//::///////////////////////////////////////////////
//:: Binding/Vestiges main include: Miscellaneous
//:: bnd_inc_bndfunc
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to Binding.

    @author Stratovarius
    @date   Created - 2021.02.02
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines the given creature's Binder level. 
 * The vestige is used for Favored Vestige
 *
 * @param oBinder    The creature whose Binder level to determine
 * @param nVestige   The rowid of the vestige in spells.2da
 *
 * @return           The Binder level
 */
int GetBinderLevel(object oBinder, int nVestige = -1);

/**
 * Determines whether a given class is a Binding-related class or not.
 *
 * @param nClass CLASS_TYPE_* of the class to test
 * @return       TRUE if the class is a Binding-related class, FALSE otherwise
 */
int GetIsBindingClass(int nClass);

/**
 * Calculates how many Binder levels are gained by a given creature from
 * it's levels in prestige classes.
 *
 * @param oBinder Creature to calculate added Binder levels for
 * @return          The number of Binder levels gained
 */
int GetBindingPRCLevels(object oBinder);

/**
 * Returns the master 2da of all vestiges - "vestiges"
 */
string GetVestigeFile();

/**
 * Returns the master 2da of binds and bind levels - "cls_bind_binder"
 */
string GetBindingClassFile(int nClass);

/**
 * Casts a particular vestige on the binder
 * Should only ever be called via Contact Vestige
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige to attempt binding
 */
void ApplyVestige(object oBinder, int nVestige);

/**
 * Removes a particular vestige from the binder
 * Should only ever be called via Contact Vestige
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige to expel
 */
void ExpelVestige(object oBinder, int nVestige);

/**
 * Rolls the check to see whether it is a good or bad pact
 * Sets a local int to mark pact quality
 *
 * @param oBinder   The binder attempting the check
 * @param nVestige  The rowid of the vestige in vestiges.2da
 *
 * @return          The rowid of the vestige in spells.2da
 */
int DoBindingCheck(object oBinder, int nVestige);

/**
 * Does the animations and count down to bind a particular vestige
 *
 * @param oBinder   The binder
 * @param nTime     Should always be 66 seconds
 * @param nVestige  The vestige to attempt binding
 * @param nExpel    Whether this is a usage of expel vestige or not
 */
void ContactVestige(object oBinder, int nTime, int nVestige, int nExpel = FALSE);

/**
 * Does the animations and count down to bind a particular vestige
 * Should only ever be called via Contact Vestige
 *
 * @param oBinder   The binder
 * @param nTime     Should always be 60 seconds
 * @param nVestige  The vestige to attempt binding
 * @param nExpel    Whether this is a usage of expel vestige or not
 */
void BindVestige(object oBinder, int nTime, int nVestige, int nExpel = FALSE);

/**
 * Checks to see whether an ability is off cooldown or not
 * Sets the cooldown if the ability is usable
 * Informs the player via floating text
 *
 * @param oBinder   The binder
 * @param nAbil     The vestige ability (such as Amon's Fire Breath SpellId)
 * @param nVestige  The vestige the ability comes from (such as VESTIGE_AMON)
 *
 * @return          TRUE/FALSE for off cooldown or not
 */
int BindAbilCooldown(object oBinder, int nAbil, int nVestige);

/**
 * How many vestiges can the binder have bound
 *
 * @param oBinder   The binder
 *
 * @return          A number between 1 and 4
 */
int GetMaxVestigeCount(object oBinder);

/**
 * What is the highest level vestige the binder can bind?
 *
 * @param oBinder   The binder
 *
 * @return          A number between 1 and 8
 */
int GetMaxVestigeLevel(object oBinder);

/**
 * What is the vestige's level?
 *
 * @param nVestige  The vestige rowid in vestiges.2da
 *
 * @return          A number between 1 and 8
 */
int GetVestigeLevel(int nVestige);

/**
 * How many total binds are active on the binder?
 * Checks via the spellid of the vestiges
 *
 * @param oBinder   The binder
 *
 * @return          0 or higher
 */
int GetBindCount(object oBinder);

/**
 * How many uses of pact augmentation does the 
 * binder get when he binds a vestige?
 *
 * @param oBinder   The binder
 *
 * @return          0 to 5
 */
int GetPactAugmentCount(object oBinder);

/**
 * Returns the penalty to be applied if the
 * binder made a bad pact with the vestige
 * Should never be called directly
 *
 * @param oBinder   The binder
 *
 * @return          Linked effect
 */
effect EffectPact(object oBinder);

/**
 * Checks whether the binder has the rapid recovery
 * feat for the named vestige
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige rowid in spells.2da
 *
 * @return          TRUE/FALSE
 */
int RapidRecovery(object oBinder, int nVestige);

/**
 * Checks whether the binder has the favored vestige
 * feat for the named vestige
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige rowid in spells.2da
 *
 * @return          TRUE/FALSE
 */
int FavoredVestige(object oBinder, int nVestige);

/**
 * Checks whether the binder has the favored vestige
 * focus feat for the named vestige
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige rowid in spells.2da
 *
 * @return          TRUE/FALSE
 */
int FavoredVestigeFocus(object oBinder, int nVestige);

/**
 * Returns the DC for saving against a vestige's abilities
 * 10 + 1/2 Binding level + Charisma Modifier + bonuses
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige rowid in spells.2da
 *
 * @return          A number
 */
int GetBinderDC(object oBinder, int nVestige);

/**
 * Checks for the special requirements of each vestige
 * or for the presence of the Ignore Special Requirements
 * feat. True means passing requirements, False is a fail
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige rowid in spells.2da
 *
 * @return          TRUE/FALSE
 */
int DoSpecialRequirements(object oBinder, int nVestige);

/**
 * Checks for the special requirements of each vestige
 * or for the presence of the Ignore Special Requirements
 * feat. True means passing requirements, False is a fail
 *
 * This is for requirements that apply during the summoning process
 * due to having a cost that applies only after the user has selected
 * which vestige they wish to bind
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige rowid in spells.2da
 *
 * @return          TRUE/FALSE
 */
int DoSummonRequirements(object oBinder, int nVestige);

/**
 * Checks for whether the vestige ability was exploited (meaning not 
 * granted) by the Anima Mage class feature.
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige ability rowid in vestigeabil.2da
 *
 * @return          TRUE if exploited/FALSE otherwise
 */
int GetIsVestigeExploited(object oBinder, int nVestigeAbil);

/**
 * Marks a vestige ability as exploited (meaning it will not be
 * granted) by the Anima Mage class feature.
 *
 * @param oBinder   The binder
 * @param nVestige  The vestige ability rowid in vestigeabil.2da
 */
void SetIsVestigeExploited(object oBinder, int nVestigeAbil);

/**
 * Checks whether the patron vestige is bound to a Knight of the Sacred Seal
 * If not, the class loses all class features
 *
 * @param oBinder   The binder
 *
 * @return TRUE if bound, FALSE otherwise
 */
int GetIsPatronVestigeBound(object oBinder);

/**
 * Checks who the patron vestige is for a Knight of the Sacred Seal
 * Used to ensure they always have a good pact with their patron
 *
 * @param oBinder   The binder
 *
 * @return The VESTIGE_* const if one exists, -1 otherwise
 */
int GetPatronVestige(object oBinder);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_spells"
#include "inc_dynconv"

//////////////////////////////////////////////////
/*                  Constants                   */
//////////////////////////////////////////////////

const int VESTIGE_CONTACT_TIME = 66;
const int VESTIGE_BINDING_TIME = 60;

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetBinderLevel(object oBinder, int nVestige = -1)
{
    int nLevel;

    if(GetLevelByClass(CLASS_TYPE_BINDER, oBinder))
    {
        // Binder level is class level + prestige
        nLevel = GetLevelByClass(CLASS_TYPE_BINDER, oBinder);
        nLevel += GetBindingPRCLevels(oBinder);        
    }
    // If you have no levels in binder, but you have Bind Vestige feat
    else if (GetHasFeat(FEAT_BIND_VESTIGE, oBinder))
    {
    	nLevel = 1;
    	if (GetHasFeat(FEAT_BIND_VESTIGE_IMPROVED, oBinder)) nLevel += 4;
    }
    if (FavoredVestige(oBinder, nVestige)) nLevel += 1;
    if (GetHasSpellEffect(VESTIGE_IPOS, oBinder) && !GetIsVestigeExploited(oBinder, VESTIGE_IPOS_INFLUENCE) && nVestige >= VESTIGE_AMON) nLevel += 1;
    
    if(DEBUG) DoDebug("Binder Level: " + IntToString(nLevel));

    return nLevel;
}

int GetIsBindingClass(int nClass)
{
    return nClass == CLASS_TYPE_BINDER;
}

int GetBindingPRCLevels(object oBinder)
{
    int nLevel = GetLevelByClass(CLASS_TYPE_ANIMA_MAGE, oBinder);
	nLevel += GetLevelByClass(CLASS_TYPE_KNIGHT_SACRED_SEAL, oBinder);
    nLevel += GetLevelByClass(CLASS_TYPE_SCION_DANTALION, oBinder);
    
    // These don't add at 1st level
    if (GetLevelByClass(CLASS_TYPE_TENEBROUS_APOSTATE, oBinder))
        nLevel += GetLevelByClass(CLASS_TYPE_TENEBROUS_APOSTATE, oBinder) - 1;

    return nLevel;
}

string GetVestigeFile()
{
	return "vestiges";
}

string GetBindingClassFile(int nClass)
{
	string sFile;
	if (nClass == CLASS_TYPE_BINDER) sFile = "cls_bind_binder";
	
	return sFile;
}

void ApplyVestige(object oBinder, int nVestige)
{
	PRCRemoveSpellEffects(nVestige, oBinder, oBinder);
	GZPRCRemoveSpellEffects(nVestige, oBinder, FALSE);
	ActionCastSpellOnSelf(nVestige, METAMAGIC_NONE, oBinder);
	if (GetLevelByClass(CLASS_TYPE_BINDER, oBinder) >= 2)
	{
		PRCRemoveSpellEffects(VESTIGE_PACT_AUGMENTATION, oBinder, oBinder);
		GZPRCRemoveSpellEffects(VESTIGE_PACT_AUGMENTATION, oBinder, FALSE);
		ActionCastSpellOnSelf(VESTIGE_PACT_AUGMENTATION, METAMAGIC_NONE, oBinder);	
	}	
	if (DEBUG) DoDebug("Applying Vestige "+IntToString(nVestige)+" on "+GetName(oBinder));
	
	// If you have hosted one of these spirits within the last 24 hours, Amon refuses to answer your call.
	if (nVestige == VESTIGE_LERAJE ||
	    nVestige == VESTIGE_CHUPOCLOPS ||
	    nVestige == VESTIGE_KARSUS ||
	    nVestige == VESTIGE_EURYNOME)
	{
		SetLocalInt(oBinder, "AmonHater", TRUE);
		DelayCommand(HoursToSeconds(48), DeleteLocalInt(oBinder, "AmonHater"));
	}		
	
	// Only good quality pacts get the bonus spell
	if (GetLocalInt(oBinder, "PactQuality"+IntToString(nVestige)) && GetLocalInt(oBinder, "ExploitVestigeConv"))
	{
		DelayCommand(0.5, StartDynamicConversation("bnd_exploitcnv", oBinder, DYNCONV_EXIT_ALLOWED_SHOW_CHOICE, FALSE, TRUE, oBinder));
		DeleteLocalInt(oBinder, "ExploitVestigeConv");
	}	
}

void ExpelVestige(object oBinder, int nVestige)
{
    SetPersistantLocalInt(oBinder, "ExpelledVestige", TRUE);
    SetPersistantLocalInt(oBinder, "ExpelledVestige"+IntToString(nVestige), TRUE);
	// Here, making a good pack means we can unbind it
	if (GetLocalInt(oBinder, "PactQuality"+IntToString(nVestige)))
	{
		PRCRemoveSpellEffects(nVestige, oBinder, oBinder);
		GZPRCRemoveSpellEffects(nVestige, oBinder, FALSE);
		FloatingTextStringOnCreature("Expelled "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nVestige)))+" successfully!", oBinder, FALSE);
	}
	else
		FloatingTextStringOnCreature("Failed to expel "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nVestige))), oBinder, FALSE);
}

int DoBindingCheck(object oBinder, int nVestige)
{
	int nApply = StringToInt(Get2DACache("vestiges", "SpellID", nVestige));
	
	// Knights of the Sacred Seal always have a good pact with their Patron
	if (GetPatronVestige(oBinder) == nApply)
	{
		SetLocalInt(oBinder, "PactQuality"+IntToString(nApply), TRUE);
		return nApply; //We don't need the rest of the function here.
	}
	// Scions of Dantalion always have a good pact with Dantalion
	if (GetLevelByClass(CLASS_TYPE_SCION_DANTALION, oBinder) && VESTIGE_DANTALION == nApply)
	{
		SetLocalInt(oBinder, "PactQuality"+IntToString(nApply), TRUE);
		return nApply; //We don't need the rest of the function here.
	}	
	
	int nRoll = d20()+ GetBinderLevel(oBinder) + GetAbilityModifier(ABILITY_CHARISMA, oBinder);
	if (GetHasFeat(FEAT_SKILLED_PACT_MAKING, oBinder)) nRoll += 4;
	// -10 penalty on the check
	if (GetLocalInt(oBinder, "RushedBinding"))
	{
		DeleteLocalInt(oBinder, "RushedBinding");
		nRoll -= 10;
	}
	// After expelling a vestige, take a -10 penalty on the check
	if (GetPersistantLocalInt(oBinder, "ExpelledVestige"))
	{
		DeletePersistantLocalInt(oBinder, "ExpelledVestige");
		nRoll -= 10;
	}	
	// Next time you rebind an expelled vestige, take a penalty on the check
	if (GetPersistantLocalInt(oBinder, "ExpelledVestige"+IntToString(nApply)))
	{
		DeletePersistantLocalInt(oBinder, "ExpelledVestige"+IntToString(nApply));
		nRoll -= 10;
	}
	// Exploiting a vestige grants a -5 on the check
	if (GetLocalInt(oBinder, "ExploitVestigeTemp")) 
	{
		nRoll -= 5;
		FloatingTextStringOnCreature("Exploiting vestige", oBinder);
		// This int is only for this Binding check
		DeleteLocalInt(oBinder, "ExploitVestigeTemp");
	}	
	int nDC = StringToInt(Get2DACache("vestiges", "BindDC", nVestige));
	SendMessageToPC(oBinder, "Binding Check: "+IntToString(nRoll)+" vs a DC of "+IntToString(nDC));
	DeleteLocalInt(oBinder, "PactQuality"+IntToString(nApply));
	// Mark a good pact
	if (nRoll >= nDC) SetLocalInt(oBinder, "PactQuality"+IntToString(nApply), TRUE);
	
	return nApply;
}

void BindVestige(object oBinder, int nTime, int nVestige, int nExpel = FALSE)
{
	if (0 >= nTime)
	{
		SetCutsceneMode(oBinder, FALSE);
		// We're expelling a vestige, not binding one
		if (nExpel)
			ExpelVestige(oBinder, DoBindingCheck(oBinder, nVestige));
		// Make a check and apply the vestige
		else
			ApplyVestige(oBinder, DoBindingCheck(oBinder, nVestige));
	}
	else if (!GetIsInCombat(oBinder)) // Being in combat causes this to fail
	{
		FloatingTextStringOnCreature("You must spend " + IntToString(nTime) +" more seconds to complete the binding", oBinder, FALSE);
		DelayCommand(6.0, BindVestige(oBinder, nTime - 6, nVestige, nExpel));
		SetCutsceneMode(oBinder, TRUE);
		AssignCommand(oBinder, ActionPlayAnimation(ANIMATION_LOOPING_TALK_PLEADING, 1.0, 6.0));
		ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_MAZE), GetLocation(oBinder), 6.0);
	}
	else
		SetCutsceneMode(oBinder, FALSE);
}

void ContactVestige(object oBinder, int nTime, int nVestige, int nExpel = FALSE)
{
	if (0 >= nTime)
	{
		SetCutsceneMode(oBinder, FALSE);	
		if (!DoSummonRequirements(oBinder, nVestige)) return;
		int nBindTime = VESTIGE_BINDING_TIME;		
		if(GetPRCSwitch(PRC_BIND_VESTIGE_TIMER) >= 12) nBindTime = GetPRCSwitch(PRC_BIND_VESTIGE_TIMER);
		if (GetLocalInt(oBinder, "RushedBinding") || GetLocalInt(oBinder, "RapidPactMaking")) nBindTime = 6;
		BindVestige(oBinder, nBindTime, nVestige, nExpel);
	}
	else if (!GetIsInCombat(oBinder)) // Being in combat causes this to fail
	{
		FloatingTextStringOnCreature("You must draw the symbol for another " + IntToString(nTime) +" seconds", oBinder, FALSE);
		DelayCommand(6.0, ContactVestige(oBinder, nTime - 6, nVestige, nExpel));
		SetCutsceneMode(oBinder, TRUE);
		AssignCommand(oBinder, ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0, 6.0));
		ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_SYMB_INSAN), GetLocation(oBinder), 6.0);
	}
	else
		SetCutsceneMode(oBinder, FALSE);
}

int BindAbilCooldown(object oBinder, int nAbil, int nVestige)
{
	int nCheck = GetLocalInt(oBinder, "Bind"+IntToString(nAbil));
	// On Cooldown
	if (nCheck)
	{
		// Free use
		if (GetLocalInt(oBinder, "KotSSSurge"))
		{
			DeleteLocalInt(oBinder, "KotSSSurge");
			FloatingTextStringOnCreature("Using Vestige's Surge on "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nAbil))), oBinder, FALSE);
			return TRUE;
		}
		FloatingTextStringOnCreature(GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nAbil)))+" is still on cooldown!", oBinder, FALSE);
		return FALSE;
	}
	else
	{
		SetLocalInt(oBinder, "Bind"+IntToString(nAbil), TRUE);
		// Default number of rounds
		int nDelay = 5;
		// Makes it one round faster
		if (RapidRecovery(oBinder, nVestige)) nDelay -= 1;
		DelayCommand(RoundsToSeconds(nDelay), DeleteLocalInt(oBinder, "Bind"+IntToString(nAbil)));
		DelayCommand(RoundsToSeconds(nDelay), FloatingTextStringOnCreature(GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nAbil)))+" is off cooldown", oBinder, FALSE));
		FloatingTextStringOnCreature("You must wait " + IntToString(nDelay) +" rounds before using "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nAbil)))+" again", oBinder, FALSE);
	}
	
	return TRUE;
}

int GetMaxVestigeCount(object oBinder)
{
	int nMax = StringToInt(Get2DACache(GetBindingClassFile(CLASS_TYPE_BINDER), "Vestiges", GetBinderLevel(oBinder)));
	
    if (DEBUG) DoDebug("GetMaxVestigeCount is "+IntToString(nMax));
    return nMax;
}

int GetMaxVestigeLevel(object oBinder)
{
	int nLevel = GetBinderLevel(oBinder);
	if (GetHasFeat(FEAT_IMPROVED_BINDING, oBinder)) nLevel += 2;
	// Due to the 2da starting at row 0
	int nMax = StringToInt(Get2DACache(GetBindingClassFile(CLASS_TYPE_BINDER), "VestigeLvl", nLevel - 1));
	
    if (DEBUG) DoDebug("GetMaxVestigeLevel is "+IntToString(nMax));
    return nMax;
}

int GetVestigeLevel(int nVestige)
{
	int nMax = StringToInt(Get2DACache("Vestiges", "Level", nVestige));
	
    if (DEBUG) DoDebug("GetVestigeLevel is "+IntToString(nMax));
    return nMax;
}

int GetBindCount(object oBinder)
{
    int i, nCount;
    for(i = VESTIGE_AMON; i <= VESTIGE_ABYSM; i++)
    	if(GetHasSpellEffect(i, oBinder)) nCount++;
	
    if (DEBUG) DoDebug("GetBindCount is "+IntToString(nCount));
    return nCount;
}

int GetPactAugmentCount(object oBinder)
{
	int nClass = GetLevelByClass(CLASS_TYPE_BINDER, oBinder);
	int nCount = 0;
	
	if (nClass >= 20) nCount = 5;
	else if (nClass >= 16) nCount = 4;
	else if (nClass >= 10) nCount = 3;
	else if (nClass >= 5) nCount = 2;
	else if (nClass >= 2) nCount = 1;
	
    if (DEBUG) DoDebug("GetPactAugmentCount is "+IntToString(nCount));
    return nCount;
}

effect EffectPact(object oBinder)
{
	effect eEffect;
	if (!GetLocalInt(oBinder, "PactQuality"+IntToString(GetSpellId())))
	{
		// –1 penalty on attack rolls, saving throws, and skill checks
		eEffect = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, 1), EffectSavingThrowDecrease(SAVING_THROW_ALL, 1));
		eEffect = EffectLinkEffects(eEffect, EffectAttackDecrease(1));
	}	
	else // NWN hates having a blank effect
		eEffect = EffectLinkEffects(EffectSkillDecrease(SKILL_DISCIPLINE, 1), EffectSkillIncrease(SKILL_DISCIPLINE, 1));
    
    return eEffect;
}

int RapidRecovery(object oBinder, int nVestige)
{
	int nFavored;
	
	if (GetHasFeat(FEAT_RAPID_RECOVERY_AMON, oBinder) && nVestige == VESTIGE_AMON) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_AYM        , oBinder) && nVestige == VESTIGE_AYM        ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_LERAJE     , oBinder) && nVestige == VESTIGE_LERAJE     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_NABERIUS   , oBinder) && nVestige == VESTIGE_NABERIUS   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_RONOVE     , oBinder) && nVestige == VESTIGE_RONOVE     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_DAHLVERNAR , oBinder) && nVestige == VESTIGE_DAHLVERNAR ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_HAAGENTI   , oBinder) && nVestige == VESTIGE_HAAGENTI   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_MALPHAS    , oBinder) && nVestige == VESTIGE_MALPHAS    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_SAVNOK     , oBinder) && nVestige == VESTIGE_SAVNOK     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ANDROMALIUS, oBinder) && nVestige == VESTIGE_ANDROMALIUS) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_FOCALOR    , oBinder) && nVestige == VESTIGE_FOCALOR    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_KARSUS     , oBinder) && nVestige == VESTIGE_KARSUS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_PAIMON     , oBinder) && nVestige == VESTIGE_PAIMON     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_AGARES     , oBinder) && nVestige == VESTIGE_AGARES     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ANDRAS     , oBinder) && nVestige == VESTIGE_ANDRAS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_BUER       , oBinder) && nVestige == VESTIGE_BUER       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_EURYNOME   , oBinder) && nVestige == VESTIGE_EURYNOME   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_TENEBROUS  , oBinder) && nVestige == VESTIGE_TENEBROUS  ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ARETE      , oBinder) && nVestige == VESTIGE_ARETE      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ASTAROTH   , oBinder) && nVestige == VESTIGE_ASTAROTH   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ACERERAK   , oBinder) && nVestige == VESTIGE_ACERERAK   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_BALAM      , oBinder) && nVestige == VESTIGE_BALAM      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_DANTALION  , oBinder) && nVestige == VESTIGE_DANTALION  ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_GERYON     , oBinder) && nVestige == VESTIGE_GERYON     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_OTIAX      , oBinder) && nVestige == VESTIGE_OTIAX      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_CHUPOCLOPS , oBinder) && nVestige == VESTIGE_CHUPOCLOPS ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_HAURES     , oBinder) && nVestige == VESTIGE_HAURES     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_IPOS       , oBinder) && nVestige == VESTIGE_IPOS       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_SHAX       , oBinder) && nVestige == VESTIGE_SHAX       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ZAGAN      , oBinder) && nVestige == VESTIGE_ZAGAN      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_VANUS      , oBinder) && nVestige == VESTIGE_VANUS      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_THETRIAD   , oBinder) && nVestige == VESTIGE_THETRIAD   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_DESHARIS   , oBinder) && nVestige == VESTIGE_DESHARIS   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ZCERYLL    , oBinder) && nVestige == VESTIGE_ZCERYLL    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ELIGOR     , oBinder) && nVestige == VESTIGE_ELIGOR     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_MARCHOSIAS , oBinder) && nVestige == VESTIGE_MARCHOSIAS ) nFavored = TRUE;	
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ASHARDALON , oBinder) && nVestige == VESTIGE_ASHARDALON ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_HALPHAX    , oBinder) && nVestige == VESTIGE_HALPHAX    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ORTHOS     , oBinder) && nVestige == VESTIGE_ORTHOS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_RAPID_RECOVERY_ABYSM      , oBinder) && nVestige == VESTIGE_ABYSM      ) nFavored = TRUE;
	
	if (DEBUG) DoDebug("RapidRecovery return value "+IntToString(nFavored));
	return nFavored;
}

int FavoredVestige(object oBinder, int nVestige)
{
	int nFavored;
	
	if (GetHasFeat(FEAT_FAVORED_VESTIGE_AMON, oBinder) && nVestige == VESTIGE_AMON) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_AYM        , oBinder) && nVestige == VESTIGE_AYM        ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_LERAJE     , oBinder) && nVestige == VESTIGE_LERAJE     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_NABERIUS   , oBinder) && nVestige == VESTIGE_NABERIUS   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_RONOVE     , oBinder) && nVestige == VESTIGE_RONOVE     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_DAHLVERNAR , oBinder) && nVestige == VESTIGE_DAHLVERNAR ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_HAAGENTI   , oBinder) && nVestige == VESTIGE_HAAGENTI   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_MALPHAS    , oBinder) && nVestige == VESTIGE_MALPHAS    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_SAVNOK     , oBinder) && nVestige == VESTIGE_SAVNOK     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ANDROMALIUS, oBinder) && nVestige == VESTIGE_ANDROMALIUS) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCALOR    , oBinder) && nVestige == VESTIGE_FOCALOR    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_KARSUS     , oBinder) && nVestige == VESTIGE_KARSUS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_PAIMON     , oBinder) && nVestige == VESTIGE_PAIMON     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_AGARES     , oBinder) && nVestige == VESTIGE_AGARES     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ANDRAS     , oBinder) && nVestige == VESTIGE_ANDRAS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_BUER       , oBinder) && nVestige == VESTIGE_BUER       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_EURYNOME   , oBinder) && nVestige == VESTIGE_EURYNOME   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_TENEBROUS  , oBinder) && nVestige == VESTIGE_TENEBROUS  ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ARETE      , oBinder) && nVestige == VESTIGE_ARETE      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ASTAROTH   , oBinder) && nVestige == VESTIGE_ASTAROTH   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ACERERAK   , oBinder) && nVestige == VESTIGE_ACERERAK   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_BALAM      , oBinder) && nVestige == VESTIGE_BALAM      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_DANTALION  , oBinder) && nVestige == VESTIGE_DANTALION  ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_GERYON     , oBinder) && nVestige == VESTIGE_GERYON     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_OTIAX      , oBinder) && nVestige == VESTIGE_OTIAX      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_CHUPOCLOPS , oBinder) && nVestige == VESTIGE_CHUPOCLOPS ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_HAURES     , oBinder) && nVestige == VESTIGE_HAURES     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_IPOS       , oBinder) && nVestige == VESTIGE_IPOS       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_SHAX       , oBinder) && nVestige == VESTIGE_SHAX       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ZAGAN      , oBinder) && nVestige == VESTIGE_ZAGAN      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_VANUS      , oBinder) && nVestige == VESTIGE_VANUS      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_THETRIAD   , oBinder) && nVestige == VESTIGE_THETRIAD   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_DESHARIS   , oBinder) && nVestige == VESTIGE_DESHARIS   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ZCERYLL    , oBinder) && nVestige == VESTIGE_ZCERYLL    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ELIGOR     , oBinder) && nVestige == VESTIGE_ELIGOR     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_MARCHOSIAS , oBinder) && nVestige == VESTIGE_MARCHOSIAS ) nFavored = TRUE;	
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ASHARDALON , oBinder) && nVestige == VESTIGE_ASHARDALON ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_HALPHAX    , oBinder) && nVestige == VESTIGE_HALPHAX    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ORTHOS     , oBinder) && nVestige == VESTIGE_ORTHOS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_ABYSM      , oBinder) && nVestige == VESTIGE_ABYSM      ) nFavored = TRUE;
	
	if (DEBUG) DoDebug("FavoredVestige return value "+IntToString(nFavored));
	return nFavored;
}

int FavoredVestigeFocus(object oBinder, int nVestige)
{
	int nFavored;
	
	if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_AMON, oBinder) && nVestige == VESTIGE_AMON) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_AYM        , oBinder) && nVestige == VESTIGE_AYM        ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_LERAJE     , oBinder) && nVestige == VESTIGE_LERAJE     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_NABERIUS   , oBinder) && nVestige == VESTIGE_NABERIUS   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_RONOVE     , oBinder) && nVestige == VESTIGE_RONOVE     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_DAHLVERNAR , oBinder) && nVestige == VESTIGE_DAHLVERNAR ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_HAAGENTI   , oBinder) && nVestige == VESTIGE_HAAGENTI   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_MALPHAS    , oBinder) && nVestige == VESTIGE_MALPHAS    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_SAVNOK     , oBinder) && nVestige == VESTIGE_SAVNOK     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ANDROMALIUS, oBinder) && nVestige == VESTIGE_ANDROMALIUS) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_FOCALOR    , oBinder) && nVestige == VESTIGE_FOCALOR    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_KARSUS     , oBinder) && nVestige == VESTIGE_KARSUS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_PAIMON     , oBinder) && nVestige == VESTIGE_PAIMON     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_AGARES     , oBinder) && nVestige == VESTIGE_AGARES     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ANDRAS     , oBinder) && nVestige == VESTIGE_ANDRAS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_BUER       , oBinder) && nVestige == VESTIGE_BUER       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_EURYNOME   , oBinder) && nVestige == VESTIGE_EURYNOME   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_TENEBROUS  , oBinder) && nVestige == VESTIGE_TENEBROUS  ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ARETE      , oBinder) && nVestige == VESTIGE_ARETE      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ASTAROTH   , oBinder) && nVestige == VESTIGE_ASTAROTH   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ACERERAK   , oBinder) && nVestige == VESTIGE_ACERERAK   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_BALAM      , oBinder) && nVestige == VESTIGE_BALAM      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_DANTALION  , oBinder) && nVestige == VESTIGE_DANTALION  ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_GERYON     , oBinder) && nVestige == VESTIGE_GERYON     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_OTIAX      , oBinder) && nVestige == VESTIGE_OTIAX      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_CHUPOCLOPS , oBinder) && nVestige == VESTIGE_CHUPOCLOPS ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_HAURES     , oBinder) && nVestige == VESTIGE_HAURES     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_IPOS       , oBinder) && nVestige == VESTIGE_IPOS       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_SHAX       , oBinder) && nVestige == VESTIGE_SHAX       ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ZAGAN      , oBinder) && nVestige == VESTIGE_ZAGAN      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_VANUS      , oBinder) && nVestige == VESTIGE_VANUS      ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_THETRIAD   , oBinder) && nVestige == VESTIGE_THETRIAD   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_DESHARIS   , oBinder) && nVestige == VESTIGE_DESHARIS   ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ZCERYLL    , oBinder) && nVestige == VESTIGE_ZCERYLL    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ELIGOR     , oBinder) && nVestige == VESTIGE_ELIGOR     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_MARCHOSIAS , oBinder) && nVestige == VESTIGE_MARCHOSIAS ) nFavored = TRUE;	
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ASHARDALON , oBinder) && nVestige == VESTIGE_ASHARDALON ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_HALPHAX    , oBinder) && nVestige == VESTIGE_HALPHAX    ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ORTHOS     , oBinder) && nVestige == VESTIGE_ORTHOS     ) nFavored = TRUE;
	else if (GetHasFeat(FEAT_FAVORED_VESTIGE_FOCUS_ABYSM      , oBinder) && nVestige == VESTIGE_ABYSM      ) nFavored = TRUE;
	
	if (DEBUG) DoDebug("FavoredVestigeFocus return value "+IntToString(nFavored));
	return nFavored;
}

int GetBinderDC(object oBinder, int nVestige)
{
	int nDC = 10 + GetBinderLevel(oBinder, nVestige)/2 + GetAbilityModifier(ABILITY_CHARISMA, oBinder);
	if (FavoredVestigeFocus(oBinder, nVestige)) nDC += 1;
	if (GetHasSpellEffect(VESTIGE_IPOS, oBinder) && !GetIsVestigeExploited(oBinder, VESTIGE_IPOS_INFLUENCE)) nDC += 1;
	
	return nDC;
}

int DoSpecialRequirements(object oBinder, int nVestige)
{
	if (GetHasFeat(FEAT_IGNORE_SPECIAL_REQUIREMENTS, oBinder)) return TRUE;
	
	if (nVestige == VESTIGE_AMON && (GetLocalInt(oBinder, "AmonHater") || 
	                                 GetHasSpellEffect(VESTIGE_LERAJE, oBinder) ||
	                                 GetHasSpellEffect(VESTIGE_EURYNOME, oBinder) ||
	                                 GetHasSpellEffect(VESTIGE_KARSUS, oBinder) ||
	                                 GetHasSpellEffect(VESTIGE_CHUPOCLOPS, oBinder)))
		return FALSE;  
	if (nVestige == VESTIGE_LERAJE && GetHasSpellEffect(VESTIGE_AMON, oBinder))
		return FALSE;
	if (nVestige == VESTIGE_NABERIUS && 4 > GetSkillRank(SKILL_LORE, oBinder, TRUE) && 4 > GetSkillRank(SKILL_BLUFF, oBinder, TRUE))
		return FALSE;
	// Ronove’s seal must be drawn in the soil under the sky.	
	if (nVestige == VESTIGE_RONOVE && (GetIsAreaNatural(GetArea(oBinder)) != AREA_NATURAL || GetIsAreaAboveGround(GetArea(oBinder)) != AREA_ABOVEGROUND))
		return FALSE;
	if (nVestige == VESTIGE_HAAGENTI && (CREATURE_SIZE_LARGE > PRCGetCreatureSize(oBinder) || (GetHasFeat(FEAT_RACE_POWERFUL_BUILD, oBinder) && CREATURE_SIZE_MEDIUM > PRCGetCreatureSize(oBinder))))
		return FALSE;
	if (nVestige == VESTIGE_KARSUS && GetHasSpellEffect(VESTIGE_AMON, oBinder))
		return FALSE;	
	if (nVestige == VESTIGE_KARSUS && 5 > GetSkillRank(SKILL_LORE, oBinder, TRUE) && 5 > GetSkillRank(SKILL_SPELLCRAFT, oBinder, TRUE))
		return FALSE;		
	if (nVestige == VESTIGE_KARSUS)
	{
    	effect eTest = GetFirstEffect(oBinder);
    	while(GetIsEffectValid(eTest))
    	{
    	    if(GetEffectType(eTest) == EFFECT_TYPE_AREA_OF_EFFECT)
    	        return FALSE;
    
        	eTest = GetNextEffect(oBinder);
        }	
    }		
	// Agagres’s seal must be drawn in the soil
	if (nVestige == VESTIGE_AGARES && GetIsAreaNatural(GetArea(oBinder)) != AREA_NATURAL)
		return FALSE;
	if (nVestige == VESTIGE_BUER && GetIsAreaInterior(GetArea(oBinder)))
		return FALSE;
	if (nVestige == VESTIGE_EURYNOME && GetHasSpellEffect(VESTIGE_AMON, oBinder))
		return FALSE;
	if (nVestige == VESTIGE_TENEBROUS && !GetIsNight())
		return FALSE;		
	if (nVestige == VESTIGE_BALAM)		
	{
		int nCur = GetCurrentHitPoints(oBinder);
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(1, DAMAGE_TYPE_SLASHING), oBinder);
		if (nCur > GetCurrentHitPoints(oBinder))
			return FALSE;
	}
	if (nVestige == VESTIGE_GERYON && 5 > GetSkillRank(SKILL_LORE, oBinder, TRUE))
		return FALSE;	
	if (nVestige == VESTIGE_ARETE && (GetHasSpellEffect(VESTIGE_EURYNOME, oBinder) || GetHasSpellEffect(VESTIGE_CHUPOCLOPS, oBinder)))
		return FALSE; 		
	if (nVestige == VESTIGE_CHUPOCLOPS && GetHasSpellEffect(VESTIGE_AMON, oBinder))
		return FALSE;
	if (nVestige == VESTIGE_IPOS && 5 > GetSkillRank(SKILL_LORE, oBinder, TRUE) && 5 > GetSkillRank(SKILL_SPELLCRAFT, oBinder, TRUE))
		return FALSE;
	if (nVestige == VESTIGE_VANUS && GetIsAreaNatural(GetArea(oBinder)) != AREA_NATURAL)
		return FALSE;
	if (nVestige == VESTIGE_DESHARIS && GetIsAreaNatural(GetArea(oBinder)) == AREA_NATURAL)
		return FALSE;		
	if (nVestige == VESTIGE_HALPHAX && !GetIsAreaInterior(GetArea(oBinder)))
		return FALSE;			
	if (nVestige == VESTIGE_HALPHAX && GetIsAreaInterior(GetArea(oBinder)) && GetIsAreaAboveGround(GetArea(oBinder)) == AREA_UNDERGROUND)
		return FALSE;	
	if (nVestige == VESTIGE_ORTHOS && GetTileMainLight1Color(GetLocation(oBinder)) != TILE_MAIN_LIGHT_COLOR_WHITE && GetTileMainLight1Color(GetLocation(oBinder)) != TILE_MAIN_LIGHT_COLOR_YELLOW)
		return FALSE;			
		
	return TRUE;
}

int DoSummonRequirements(object oBinder, int nVestige)
{
	if (GetHasFeat(FEAT_IGNORE_SPECIAL_REQUIREMENTS, oBinder)) return TRUE;
	
	int nSpellId = StringToInt(Get2DACache(GetVestigeFile(), "SpellID", nVestige));
	
	if (nSpellId == VESTIGE_LERAJE)
	{
		object oArrow = GetItemInSlot(INVENTORY_SLOT_ARROWS, oBinder);
		int nStack = GetItemStackSize(oArrow);
		if (nStack) 
			SetItemStackSize(oArrow, nStack-1);
		else 
		{
			FloatingTextStringOnCreature("You have failed to break an arrow for Leraje, and she refuses your call!", oBinder, FALSE);
			return FALSE;
		}	
	}
	
	return TRUE;
}

int GetIsVestigeExploited(object oBinder, int nVestigeAbil)
{
	if (GetLocalInt(oBinder, "ExploitVestige") == nVestigeAbil) return TRUE;
	
	return FALSE;
}

void SetIsVestigeExploited(object oBinder, int nVestigeAbil)
{
	SetLocalInt(oBinder, "ExploitVestige", nVestigeAbil);
	SetLocalInt(oBinder, "ExploitVestigeTemp", TRUE);
	SetLocalInt(oBinder, "ExploitVestigeConv", TRUE);
}

int GetIsPatronVestigeBound(object oBinder)
{
	int nPatron;
	
	if (GetHasFeat(FEAT_PATRON_VESTIGE_AMON            , oBinder)) nPatron = VESTIGE_AMON;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_AYM        , oBinder)) nPatron = VESTIGE_AYM;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_LERAJE     , oBinder)) nPatron = VESTIGE_LERAJE;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_NABERIUS   , oBinder)) nPatron = VESTIGE_NABERIUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_RONOVE     , oBinder)) nPatron = VESTIGE_RONOVE;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_DAHLVERNAR , oBinder)) nPatron = VESTIGE_DAHLVERNAR;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_HAAGENTI   , oBinder)) nPatron = VESTIGE_HAAGENTI;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_MALPHAS    , oBinder)) nPatron = VESTIGE_MALPHAS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_SAVNOK     , oBinder)) nPatron = VESTIGE_SAVNOK;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ANDROMALIUS, oBinder)) nPatron = VESTIGE_ANDROMALIUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_FOCALOR    , oBinder)) nPatron = VESTIGE_FOCALOR;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_KARSUS     , oBinder)) nPatron = VESTIGE_KARSUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_PAIMON     , oBinder)) nPatron = VESTIGE_PAIMON;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_AGARES     , oBinder)) nPatron = VESTIGE_AGARES;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ANDRAS     , oBinder)) nPatron = VESTIGE_ANDRAS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_BUER       , oBinder)) nPatron = VESTIGE_BUER;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_EURYNOME   , oBinder)) nPatron = VESTIGE_EURYNOME;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_TENEBROUS  , oBinder)) nPatron = VESTIGE_TENEBROUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ARETE      , oBinder)) nPatron = VESTIGE_ARETE;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ASTAROTH   , oBinder)) nPatron = VESTIGE_ASTAROTH;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ACERERAK   , oBinder)) nPatron = VESTIGE_ACERERAK;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_BALAM      , oBinder)) nPatron = VESTIGE_BALAM;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_DANTALION  , oBinder)) nPatron = VESTIGE_DANTALION;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_GERYON     , oBinder)) nPatron = VESTIGE_GERYON;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_OTIAX      , oBinder)) nPatron = VESTIGE_OTIAX;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_CHUPOCLOPS , oBinder)) nPatron = VESTIGE_CHUPOCLOPS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_HAURES     , oBinder)) nPatron = VESTIGE_HAURES;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_IPOS       , oBinder)) nPatron = VESTIGE_IPOS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_SHAX       , oBinder)) nPatron = VESTIGE_SHAX;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ZAGAN      , oBinder)) nPatron = VESTIGE_ZAGAN;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_VANUS      , oBinder)) nPatron = VESTIGE_VANUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_THETRIAD   , oBinder)) nPatron = VESTIGE_THETRIAD;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_DESHARIS   , oBinder)) nPatron = VESTIGE_DESHARIS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ZCERYLL    , oBinder)) nPatron = VESTIGE_ZCERYLL;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ELIGOR     , oBinder)) nPatron = VESTIGE_ELIGOR;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_MARCHOSIAS , oBinder)) nPatron = VESTIGE_MARCHOSIAS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ASHARDALON , oBinder)) nPatron = VESTIGE_ASHARDALON;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_HALPHAX    , oBinder)) nPatron = VESTIGE_HALPHAX;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ORTHOS     , oBinder)) nPatron = VESTIGE_ORTHOS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ABYSM      , oBinder)) nPatron = VESTIGE_ABYSM;
	
	if(GetHasSpellEffect(nPatron, oBinder)) return TRUE;
	
	return FALSE;			
}

int GetPatronVestige(object oBinder)
{
	int nPatron = -1;
	
	if (GetHasFeat(FEAT_PATRON_VESTIGE_AMON            , oBinder)) nPatron = VESTIGE_AMON;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_AYM        , oBinder)) nPatron = VESTIGE_AYM;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_LERAJE     , oBinder)) nPatron = VESTIGE_LERAJE;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_NABERIUS   , oBinder)) nPatron = VESTIGE_NABERIUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_RONOVE     , oBinder)) nPatron = VESTIGE_RONOVE;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_DAHLVERNAR , oBinder)) nPatron = VESTIGE_DAHLVERNAR;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_HAAGENTI   , oBinder)) nPatron = VESTIGE_HAAGENTI;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_MALPHAS    , oBinder)) nPatron = VESTIGE_MALPHAS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_SAVNOK     , oBinder)) nPatron = VESTIGE_SAVNOK;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ANDROMALIUS, oBinder)) nPatron = VESTIGE_ANDROMALIUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_FOCALOR    , oBinder)) nPatron = VESTIGE_FOCALOR;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_KARSUS     , oBinder)) nPatron = VESTIGE_KARSUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_PAIMON     , oBinder)) nPatron = VESTIGE_PAIMON;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_AGARES     , oBinder)) nPatron = VESTIGE_AGARES;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ANDRAS     , oBinder)) nPatron = VESTIGE_ANDRAS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_BUER       , oBinder)) nPatron = VESTIGE_BUER;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_EURYNOME   , oBinder)) nPatron = VESTIGE_EURYNOME;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_TENEBROUS  , oBinder)) nPatron = VESTIGE_TENEBROUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ARETE      , oBinder)) nPatron = VESTIGE_ARETE;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ASTAROTH   , oBinder)) nPatron = VESTIGE_ASTAROTH;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ACERERAK   , oBinder)) nPatron = VESTIGE_ACERERAK;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_BALAM      , oBinder)) nPatron = VESTIGE_BALAM;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_DANTALION  , oBinder)) nPatron = VESTIGE_DANTALION;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_GERYON     , oBinder)) nPatron = VESTIGE_GERYON;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_OTIAX      , oBinder)) nPatron = VESTIGE_OTIAX;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_CHUPOCLOPS , oBinder)) nPatron = VESTIGE_CHUPOCLOPS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_HAURES     , oBinder)) nPatron = VESTIGE_HAURES;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_IPOS       , oBinder)) nPatron = VESTIGE_IPOS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_SHAX       , oBinder)) nPatron = VESTIGE_SHAX;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ZAGAN      , oBinder)) nPatron = VESTIGE_ZAGAN;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_VANUS      , oBinder)) nPatron = VESTIGE_VANUS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_THETRIAD   , oBinder)) nPatron = VESTIGE_THETRIAD;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_DESHARIS   , oBinder)) nPatron = VESTIGE_DESHARIS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ZCERYLL    , oBinder)) nPatron = VESTIGE_ZCERYLL;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ELIGOR     , oBinder)) nPatron = VESTIGE_ELIGOR;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_MARCHOSIAS , oBinder)) nPatron = VESTIGE_MARCHOSIAS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ASHARDALON , oBinder)) nPatron = VESTIGE_ASHARDALON;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_HALPHAX    , oBinder)) nPatron = VESTIGE_HALPHAX;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ORTHOS     , oBinder)) nPatron = VESTIGE_ORTHOS;
	else if (GetHasFeat(FEAT_PATRON_VESTIGE_ABYSM      , oBinder)) nPatron = VESTIGE_ABYSM;
	
	return nPatron;			
}