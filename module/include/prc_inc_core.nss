/* 	Core functions taken from high up the branch
	which are needed lower. */

//:: Updated for .35 by Jaysyn 2023/03/10

//////////////////////////////////////////////////
/* Function Prototypes                          */
//////////////////////////////////////////////////

//:: Returns true if oCaster's race can naturally cast sorcerer spells.
int GetIsRHDSorcerer(object oCaster = OBJECT_SELF);

//:: Returns true if oCaster's race can naturally cast bard spells.
int GetIsRHDBard(object oCaster = OBJECT_SELF);

// wrapper for getspelltargetlocation
location PRCGetSpellTargetLocation(object oCaster = OBJECT_SELF);

// Avoids adding passive spellcasting to the character's action queue by
// creating an object specifically to cast the spell on the character.
//
// NOTE: The spell script must refer to the PC as PRCGetSpellTargetObject()
// otherwise this function WILL NOT WORK.  Do not make any assumptions
// about the PC being OBJECT_SELF.
void ActionCastSpellOnSelf(int iSpell, int nMetaMagic = METAMAGIC_NONE, object oTarget = OBJECT_SELF);

// This is a wrapper function that causes OBJECT_SELF to fire the defined spell
// at the defined level.  The target is automatically the object or location
// that the user selects. Useful for SLA's to perform the casting of a true
// spell.  This is useful because:
//
// 1) If the original's spell script is updated, so is this one.
// 2) The spells are identified as the true spell.  That is, they ARE the true spell.
// 3) Spellhooks (such as item crafting) that can only identify true spells
//    will easily work.
//
// This function should only be used when SLA's are meant to simulate true
// spellcasting abilities, such as those seen when using feats with subradials
// to simulate spellbooks.
void ActionCastSpell(int iSpell, int iCasterLev = 0, int iBaseDC = 0, int iTotalDC = 0,
    int nMetaMagic = METAMAGIC_NONE, int nClass = CLASS_TYPE_INVALID,
    int bUseOverrideTargetLocation=FALSE, int bUseOverrideTargetObject=FALSE,
    object oOverrideTarget=OBJECT_INVALID, int bInstantCast=TRUE, int bUseOverrideMetaMagic=FALSE);

/**
 * Checks whether the given creature is committing an action, or
 * under such effects that cause a breach of concentration.
 *
 * @param oConcentrator The creature to test
 * @return              TRUE if concentration is broken, FALSE otherwise
 */
int GetBreakConcentrationCheck(object oConcentrator);

/**
 * Checks for breaks in concentration for an ongoing effect, and removes
 * the effect if concentration is broken.
 *
 * @param oCaster       The creature who cast the effect
 * @param SpellID       The id of the spell the effect belongs to
 * @param oTarget       The creature or object that is the target of the effect
 * @param nDuration     The duration the effect lasts in seconds.
 */
void CheckConcentrationOnEffect(object oCaster, int SpellID, object oTarget, int nDuration);

// gets the spell level adjustment to the nMetaMagic, including boni from the Improved Metamagic (epic) feat
int GetMetaMagicSpellLevelAdjustment(int nMetaMagic);

// Returns true if a spellcaster
int GetIsBioSpellCastClass(int nClass);

// Returns true for spell casters with spellbooks
int GetIsNSBClass(int nClass);

// returns the spelllevel of nSpell as it can be cast by oCreature
int PRCGetSpellLevel(object oCreature, int nSpell);

// returns if a character should be using the newspellbook when casting
int UseNewSpellBook(object oCreature);

// wrapper for GetHasSpell, works for newspellbook 'fake' spells too
// should return 0 if called with a normal spell when a character should be using the newspellbook
int PRCGetHasSpell(int nRealSpellID, object oCreature = OBJECT_SELF);

// checks if oPC knows the specified spell
// only works for classes that use the PRC spellbook, there is currently no way to do this for Bioware spellcasters
int PRCGetIsRealSpellKnown(int nRealSpellID, object oPC = OBJECT_SELF);

// checks if oPC knows the specified spell
// only works for classes that use the PRC spellbook, there is currently no way to do this for Bioware spellcasters
// this will only check the spellbook of the class specified
int PRCGetIsRealSpellKnownByClass(int nRealSpellID, int nClass, object oPC = OBJECT_SELF);

//routes to action cast spell, but puts a wrapper around to tell other functions its a
//SLA, so dont craft etc
//also defaults the totalDC to 10+spellevel+chamod
// moved from prc_inc_racial
void DoRacialSLA(int nSpellID, int nCasterlevel = 0, int nTotalDC = 0, int bInstantCast = FALSE);

/**
 * Deletes a stored manifestation structure.
 *
 * @param oObject The object on which the structure is stored
 * @param sName   The name under which the structure is stored
 */
void DeleteLocalManifestation(object oObject, string sName);

/**
 * Deletes a stored mystery structure.
 *
 * @param oObject The object on which the structure is stored
 * @param sName   The name under which the structure is stored
 */
void DeleteLocalMystery(object oObject, string sName);

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// metamagic spell level adjustments for Bioware provided metamagic feats
const int METAMAGIC_EXTEND_LEVEL = 1;
const int METAMAGIC_SILENT_LEVEL = 1;
const int METAMAGIC_STILL_LEVEL = 1;
const int METAMAGIC_EMPOWER_LEVEL = 2;
const int METAMAGIC_MAXIMIZE_LEVEL = 3;
const int METAMAGIC_QUICKEN_LEVEL = 4;

//////////////////////////////////////////////////
/* Includes                                     */
//////////////////////////////////////////////////

#include "lookup_2da_spell"
#include "inc_lookups"
#include "prc_inc_damage"
#include "prc_inc_sb_const"	// Spell Book Constants
#include "x0_i0_position"
#include "inc_newspellbook"

/*
	access to prc_inc_nwscript via prc_inc_damage
	access to PRCGetSpell* via prc_inc_damage
*/


//////////////////////////////////////////////////
/* Function Definitions                         */
//////////////////////////////////////////////////

//:: Returns true if oCaster's race can naturally cast sorcerer spells.
int GetIsRHDSorcerer(object oCaster = OBJECT_SELF)
{
    int nRace = GetRacialType(oCaster);
	
    return (nRace == RACIAL_TYPE_ARANEA ||
            nRace == RACIAL_TYPE_ARKAMOI ||
            nRace == RACIAL_TYPE_DRIDER ||
            nRace == RACIAL_TYPE_HOBGOBLIN_WARSOUL ||
            nRace == RACIAL_TYPE_MARRUTACT ||
            nRace == RACIAL_TYPE_RAKSHASA ||
            nRace == RACIAL_TYPE_REDSPAWN_ARCANISS);
}

//:: Returns true if oCaster's race can naturally cast bard spells.
int GetIsRHDBard(object oCaster = OBJECT_SELF)
{
    int nRace = GetRacialType(oCaster);
	
    return (nRace == RACIAL_TYPE_GLOURA);
}

//wrapper for GetSpellTargetLocation()
location PRCGetSpellTargetLocation(object oCaster = OBJECT_SELF)
{
    // check if there is an override location on the module, and return that
    // bioware did not define a LOCATION_INVALID const, so we must signal a valid override location by setting a local int on the module
    if(GetLocalInt(GetModule(), PRC_SPELL_TARGET_LOCATION_OVERRIDE))
    {
        if (DEBUG) DoDebug("PRCGetSpellTargetLocation: found override target location on module");
        return GetLocalLocation(GetModule(), PRC_SPELL_TARGET_LOCATION_OVERRIDE);
    }


    // check if there is an override location on the caster, and return that
    // bioware did not define a LOCATION_INVALID const, so we signal a valid override location by setting a local int on oCaster
    if (GetLocalInt(oCaster, PRC_SPELL_TARGET_LOCATION_OVERRIDE))
    {
        if (DEBUG) DoDebug("PRCGetSpellTargetLocation: found override target location on caster "+GetName(oCaster));
        return GetLocalLocation(oCaster, PRC_SPELL_TARGET_LOCATION_OVERRIDE);
    }


    // The rune/gem/skull always targets the one who activates it.
    object oItem     = PRCGetSpellCastItem(oCaster);
    if(GetIsObjectValid(oItem) && (GetResRef(oItem) == "prc_rune_1" ||
       GetResRef(oItem) == "prc_skulltalis" || GetTag(oItem) == "prc_attunegem"))
        return GetLocation(GetItemPossessor(oItem));

	if (GetLocalInt(oCaster, "BlackLabyrinth") && d10() < 3)
		return GenerateNewLocationFromLocation(GetSpellTargetLocation(), FeetToMeters(5.0*d4()), IntToFloat(Random(360)), IntToFloat(Random(360)));    

    // if we made it here, we must use Bioware's function
    return GetSpellTargetLocation();
}

void ActionCastSpellOnSelf(int iSpell, int nMetaMagic = METAMAGIC_NONE, object oTarget = OBJECT_SELF)
{
    if(!GetIsObjectValid(oTarget)) oTarget = OBJECT_SELF;
    object oCastingObject = CreateObject(OBJECT_TYPE_PLACEABLE, "x0_rodwonder", GetLocation(oTarget));

    AssignCommand(oCastingObject, ActionCastSpellAtObject(iSpell, oTarget, nMetaMagic, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
    if (DEBUG) DoDebug("ActionCastSpellOnSelf: Casting Spell "+IntToString(iSpell)+" on "+GetName(oTarget));

    DestroyObject(oCastingObject, 6.0);
}

void ActionCastSpell(int iSpell, int iCasterLev = 0, int iBaseDC = 0, int iTotalDC = 0,
    int nMetaMagic = METAMAGIC_NONE, int nClass = CLASS_TYPE_INVALID,
    int bUseOverrideTargetLocation=FALSE, int bUseOverrideTargetObject=FALSE,
    object oOverrideTarget=OBJECT_INVALID, int bInstantCast=TRUE, int bUseOverrideMetaMagic=FALSE)
{

    //if its a hostile spell, clear the action queue
    //this stops people stacking hostile spells to be instacast
    //at the end, for example when coming out of invisibility
    // X - hope this is not needed if spells are cast normally
    //if(Get2DACache("spells", "HostileSetting", iSpell) == "1" && bInstantCast)
    //    ClearAllActions();

    object oTarget = PRCGetSpellTargetObject();
    location lLoc = PRCGetSpellTargetLocation();

    //set the overriding values
    if (iCasterLev != 0)
        ActionDoCommand(SetLocalInt(OBJECT_SELF, PRC_CASTERLEVEL_OVERRIDE, iCasterLev));
    if (iTotalDC != 0)
        ActionDoCommand(SetLocalInt(OBJECT_SELF, PRC_DC_TOTAL_OVERRIDE, iTotalDC));
    if (iBaseDC != 0)
        ActionDoCommand(SetLocalInt(OBJECT_SELF, PRC_DC_BASE_OVERRIDE, iBaseDC));
    if (nClass != CLASS_TYPE_INVALID)
        ActionDoCommand(SetLocalInt(OBJECT_SELF, PRC_CASTERCLASS_OVERRIDE, nClass));
    if (bUseOverrideMetaMagic)
        ActionDoCommand(SetLocalInt(OBJECT_SELF, PRC_METAMAGIC_OVERRIDE, nMetaMagic));
    else if (nMetaMagic != METAMAGIC_NONE)
        ActionDoCommand(SetLocalInt(OBJECT_SELF, PRC_METAMAGIC_ADJUSTMENT, nMetaMagic));
    if (bUseOverrideTargetLocation)
    {
        ActionDoCommand(SetLocalInt(OBJECT_SELF, PRC_SPELL_TARGET_LOCATION_OVERRIDE, TRUE));
        //location must be set outside of this function at the moment
        //cant pass a location into a function as an optional parameter
        //go bioware for not defining an invalid location constant
    }
    if (bUseOverrideTargetObject)
    {
        ActionDoCommand(SetLocalInt(OBJECT_SELF, PRC_SPELL_TARGET_OBJECT_OVERRIDE, TRUE));
        ActionDoCommand(SetLocalObject(OBJECT_SELF, PRC_SPELL_TARGET_OBJECT_OVERRIDE, oOverrideTarget));
    }
    ActionDoCommand(SetLocalInt(OBJECT_SELF, "UsingActionCastSpell", TRUE));
    
    if(DEBUG) DoDebug("ActionCastSpell SpellId: " + IntToString(iSpell));
    if(DEBUG) DoDebug("ActionCastSpell Caster Level: " + IntToString(iCasterLev));
    if(DEBUG) DoDebug("ActionCastSpell Base DC: " + IntToString(iBaseDC));
    if(DEBUG) DoDebug("ActionCastSpell Total DC: " + IntToString(iTotalDC));
    if(DEBUG) DoDebug("ActionCastSpell Metamagic: " + IntToString(nMetaMagic));
    if(DEBUG) DoDebug("ActionCastSpell Caster Class: " + IntToString(nClass));    
    if(DEBUG) DoDebug("ActionCastSpell Target: " + GetName(oTarget));
    if(DEBUG) DoDebug("ActionCastSpell Override Target: " + GetName(oOverrideTarget));

    //cast the spell
    if (GetIsObjectValid(oOverrideTarget))
        ActionCastSpellAtObject(iSpell, oOverrideTarget, nMetaMagic, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantCast);
    else if (GetIsObjectValid(oTarget))
        ActionCastSpellAtObject(iSpell, oTarget, nMetaMagic, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantCast);
    else
        ActionCastSpellAtLocation(iSpell, lLoc, nMetaMagic, TRUE, PROJECTILE_PATH_TYPE_DEFAULT, bInstantCast);

    ActionDoCommand(DeleteLocalInt(OBJECT_SELF, "UsingActionCastSpell"));

    //clean up afterwards
    if(bInstantCast)//give scripts time to read the variables
    {
        if (iCasterLev != 0)
            ActionDoCommand(DelayCommand(1.0, DeleteLocalInt(OBJECT_SELF, PRC_CASTERLEVEL_OVERRIDE)));
        if (iTotalDC != 0)
            ActionDoCommand(DelayCommand(1.0, DeleteLocalInt(OBJECT_SELF, PRC_DC_TOTAL_OVERRIDE)));
        if (iBaseDC != 0)
            ActionDoCommand(DelayCommand(1.0, DeleteLocalInt(OBJECT_SELF, PRC_DC_BASE_OVERRIDE)));
        if (nClass != CLASS_TYPE_INVALID)
            ActionDoCommand(DelayCommand(1.0, DeleteLocalInt(OBJECT_SELF, PRC_CASTERCLASS_OVERRIDE)));
        if (nMetaMagic != METAMAGIC_NONE)
            ActionDoCommand(DelayCommand(1.0, DeleteLocalInt(OBJECT_SELF, PRC_METAMAGIC_OVERRIDE)));
        if (bUseOverrideTargetLocation)
        {
            ActionDoCommand(DelayCommand(1.0, DeleteLocalInt(OBJECT_SELF, PRC_SPELL_TARGET_LOCATION_OVERRIDE)));
            //location must be set outside of this function at the moment
            //cant pass a location into a function as an optional parameter
            //go bioware for not defining an invalid location constant
        }
        if (bUseOverrideTargetObject)
        {
            ActionDoCommand(DelayCommand(1.0, DeleteLocalInt(OBJECT_SELF, PRC_SPELL_TARGET_OBJECT_OVERRIDE)));
            ActionDoCommand(DelayCommand(1.0, DeleteLocalObject(OBJECT_SELF, PRC_SPELL_TARGET_OBJECT_OVERRIDE)));
        }
    }
    else
    {
        if (iCasterLev != 0)
            ActionDoCommand(DeleteLocalInt(OBJECT_SELF, PRC_CASTERLEVEL_OVERRIDE));
        if (iTotalDC != 0)
            ActionDoCommand(DeleteLocalInt(OBJECT_SELF, PRC_DC_TOTAL_OVERRIDE));
        if (iBaseDC != 0)
            ActionDoCommand(DeleteLocalInt(OBJECT_SELF, PRC_DC_BASE_OVERRIDE));
        if (nClass != CLASS_TYPE_INVALID)
            ActionDoCommand(DeleteLocalInt(OBJECT_SELF, PRC_CASTERCLASS_OVERRIDE));
        if (bUseOverrideMetaMagic)
            ActionDoCommand(DeleteLocalInt(OBJECT_SELF, PRC_METAMAGIC_OVERRIDE));
        else if (nMetaMagic != METAMAGIC_NONE)
            ActionDoCommand(DeleteLocalInt(OBJECT_SELF, PRC_METAMAGIC_ADJUSTMENT));
        if (bUseOverrideTargetLocation)
        {
            ActionDoCommand(DeleteLocalInt(OBJECT_SELF, PRC_SPELL_TARGET_LOCATION_OVERRIDE));
            //location must be set outside of this function at the moment
            //cant pass a location into a function as an optional parameter
            //go bioware for not defining an invalid location constant
        }
        if (bUseOverrideTargetObject)
        {
            ActionDoCommand(DeleteLocalInt(OBJECT_SELF, PRC_SPELL_TARGET_OBJECT_OVERRIDE));
            ActionDoCommand(DeleteLocalObject(OBJECT_SELF, PRC_SPELL_TARGET_OBJECT_OVERRIDE));
        }
    }


/*
//The problem with this approace is that the effects are then applies by the original spell, which could go wrong. What to do?
    SetLocalInt(OBJECT_SELF, PRC_SPELLID_OVERRIDE, GetSpellId());
    DelayCommand(1.0, DeleteLocalInt(OBJECT_SELF, PRC_SPELLID_OVERRIDE));
    string sScript = Get2DACache("spells", "ImpactScript", iSpell);
    ExecuteScript(sScript, OBJECT_SELF);
*/
}

int GetBreakConcentrationCheck(object oConcentrator)
{
	if (GetHasSpellEffect(VESTIGE_DAHLVERNAR, oConcentrator) && !GetLocalInt(oConcentrator, "PactQuality"+IntToString(VESTIGE_DAHLVERNAR))) return TRUE;

    int nAction = GetCurrentAction(oConcentrator);
    // creature doing anything that requires attention and breaks concentration
    if (nAction == ACTION_DISABLETRAP  || nAction == ACTION_TAUNT        ||
        nAction == ACTION_PICKPOCKET   || nAction == ACTION_ATTACKOBJECT ||
        nAction == ACTION_COUNTERSPELL || nAction == ACTION_FLAGTRAP     ||
        nAction == ACTION_CASTSPELL    || nAction == ACTION_ITEMCASTSPELL)
    {
        return TRUE;
    }
    //suffering a mental effect
    effect e1 = GetFirstEffect(oConcentrator);
    int nType;
    while (GetIsEffectValid(e1))
    {
        nType = GetEffectType(e1);
        if (nType == EFFECT_TYPE_STUNNED   || nType == EFFECT_TYPE_PARALYZE   ||
            nType == EFFECT_TYPE_SLEEP     || nType == EFFECT_TYPE_FRIGHTENED ||
            nType == EFFECT_TYPE_PETRIFY   || nType == EFFECT_TYPE_CONFUSED   ||
            nType == EFFECT_TYPE_DOMINATED || nType == EFFECT_TYPE_POLYMORPH)
        {
            return TRUE;
        }
        e1 = GetNextEffect(oConcentrator);
    }
    // add to on damage event
    AddEventScript(oConcentrator, EVENT_VIRTUAL_ONDAMAGED, "prc_od_conc", FALSE, FALSE);
    if(GetLocalInt(oConcentrator, "CONC_BROKEN")) // won't be set first time around regardless
    {
        DeleteLocalInt(oConcentrator, "CONC_BROKEN"); // reset for next spell
        return TRUE;
    }
    return FALSE;
}

void CheckConcentrationOnEffect(object oCaster, int SpellID, object oTarget, int nDuration)
{
    int nDur = GetLocalInt(oCaster, "Conc" + IntToString(SpellID));
    if(GetBreakConcentrationCheck(oCaster) == TRUE && nDur < nDuration)
    {
        FloatingTextStringOnCreature("*Concentration Broken*", oCaster);
        DeleteLocalInt(oCaster, "Conc" + IntToString(SpellID));
        PRCRemoveSpellEffects(SpellID, oCaster, oTarget);
    }
    else if(nDur < nDuration)
    {
        SetLocalInt(oCaster, "Conc" + IntToString(SpellID), nDur + 3);
        DelayCommand(3.0, CheckConcentrationOnEffect(oCaster, SpellID, oTarget, nDuration));
    }
    else
    {
        DeleteLocalInt(oCaster, "Conc" + IntToString(SpellID));
    }
}

int PRCGetSpellLevelForClass(int nSpell, int nClass)
{
    string sSpellLevel = "";
    if (nClass == CLASS_TYPE_WIZARD || nClass == CLASS_TYPE_SORCERER)
        sSpellLevel = Get2DACache("spells", "Wiz_Sorc", nSpell);
    else if (nClass == CLASS_TYPE_RANGER)
        sSpellLevel = Get2DACache("spells", "Ranger", nSpell);
    else if (nClass == CLASS_TYPE_PALADIN)
        sSpellLevel = Get2DACache("spells", "Paladin", nSpell);
    else if (nClass == CLASS_TYPE_DRUID)
        sSpellLevel = Get2DACache("spells", "Druid", nSpell);
    else if (nClass == CLASS_TYPE_CLERIC || nClass == CLASS_TYPE_UR_PRIEST || nClass == CLASS_TYPE_OCULAR)
        sSpellLevel = Get2DACache("spells", "Cleric", nSpell);
    else if (nClass == CLASS_TYPE_BARD)
        sSpellLevel = Get2DACache("spells", "Bard", nSpell);
	else if (nClass == CLASS_TYPE_ASSASSIN)
        sSpellLevel = Get2DACache("spells", "Assassin", nSpell);
    else if (nClass == CLASS_TYPE_CULTIST_SHATTERED_PEAK)
        sSpellLevel = Get2DACache("spells", "Cultist", nSpell);  
    else if (nClass == CLASS_TYPE_NENTYAR_HUNTER)
        sSpellLevel = Get2DACache("spells", "Nentyar", nSpell);        
    else if (nClass == CLASS_TYPE_SHADOWLORD)
        sSpellLevel = Get2DACache("spells", "Telflammar", nSpell);                
    else if (nClass == CLASS_TYPE_SLAYER_OF_DOMIEL)
        sSpellLevel = Get2DACache("spells", "Domiel", nSpell);    
    else if (nClass == CLASS_TYPE_SOHEI)
        sSpellLevel = Get2DACache("spells", "Sohei", nSpell);        
    else if (nClass == CLASS_TYPE_VASSAL)
        sSpellLevel = Get2DACache("spells", "Bahamut", nSpell);  
    else if (nClass == CLASS_TYPE_BLACKGUARD)
        sSpellLevel = Get2DACache("spells", "Blackguard", nSpell);        
    else if (nClass == CLASS_TYPE_KNIGHT_CHALICE)
        sSpellLevel = Get2DACache("spells", "Chalice", nSpell);   
    else if (nClass == CLASS_TYPE_KNIGHT_MIDDLECIRCLE)
        sSpellLevel = Get2DACache("spells", "MiddleCircle", nSpell);           
    else if (nClass == CLASS_TYPE_SOLDIER_OF_LIGHT)
        sSpellLevel = Get2DACache("spells", "SoLight", nSpell);        
    else if (nClass == CLASS_TYPE_BLIGHTER)
        sSpellLevel = Get2DACache("spells", "Blighter", nSpell);         
    else if (nClass == CLASS_TYPE_HEALER)
        sSpellLevel = Get2DACache("spells", "Healer", nSpell);                 
    else if (nClass == CLASS_TYPE_SHAMAN)
        sSpellLevel = Get2DACache("spells", "Shaman", nSpell);            
    else if (nClass == CLASS_TYPE_INVALID)
        sSpellLevel = Get2DACache("spells", "Innate", nSpell);        

    if (sSpellLevel != "")
        return StringToInt(sSpellLevel);

    // 2009-9-21: Support real spell ID's. -N-S
    // PRCGetSpellLevel() is called several times in the Bioware spellhooking script.
    // That means it will always pass a "real" spell ID to this function, but new-spellbook users won't have the real spell!
    // GetSpellLevel() takes the fake spell ID, so this function was always failing.
    //int nSpellLevel = GetSpellLevel(nSpell, nClass);
    int nSpellLevel = -1;
    int nSpellbookID = RealSpellToSpellbookID(nClass, nSpell);
    if (nSpellbookID == -1)
        nSpellLevel = GetSpellLevel(nSpell, nClass);
    else
    {
        string sFile = GetFileForClass(nClass);
        string sSpellLevel = Get2DACache(sFile, "Level", nSpellbookID);
        if (sSpellLevel != "")
            nSpellLevel = StringToInt(sSpellLevel);
    }

    return nSpellLevel;
}

// returns the spell circle level of nSpell as it can be cast by oCreature
int PRCGetSpellLevel(object oCreature, int nSpell)
{
    /*if (!PRCGetHasSpell(nSpell, oCreature))
        return -1;*/

    int nClass = PRCGetLastSpellCastClass();
    int nSpellLevel = PRCGetSpellLevelForClass(nSpell, nClass);
    if (nSpellLevel != -1)
        return nSpellLevel;

    int i;
    for (i=1;i<=8;i++)
    {
        nClass = GetClassByPosition(i, oCreature);
        int nCharLevel = GetLevelByClass(nClass, oCreature);
        if (nCharLevel)
        {
            nSpellLevel = PRCGetSpellLevelForClass(nSpell, nClass);
            if (nSpellLevel != -1)
                return nSpellLevel;
        }
    }

    //return innate level
    return StringToInt(Get2DACache("spells", "Innate", nSpell));
}

// gets the spell level adjustment to the nMetaMagic, including boni from the Improved Metamagic (epic) feat
int GetMetaMagicSpellLevelAdjustment(int nMetaMagic)
{
    int nAdj;
    if (nMetaMagic == 0) return nAdj;

    if (nMetaMagic & METAMAGIC_EXTEND)   nAdj += METAMAGIC_EXTEND_LEVEL;
    if (nMetaMagic & METAMAGIC_SILENT)   nAdj += METAMAGIC_SILENT_LEVEL;
    if (nMetaMagic & METAMAGIC_STILL)    nAdj += METAMAGIC_STILL_LEVEL;
    if (nMetaMagic & METAMAGIC_EMPOWER)  nAdj += METAMAGIC_EMPOWER_LEVEL;
    if (nMetaMagic & METAMAGIC_MAXIMIZE) nAdj += METAMAGIC_MAXIMIZE_LEVEL;
    if (nMetaMagic & METAMAGIC_QUICKEN)  nAdj += METAMAGIC_QUICKEN_LEVEL;

    return nAdj;
}

int GetIsBioSpellCastClass(int nClass)
{
    return nClass == CLASS_TYPE_WIZARD
        || nClass == CLASS_TYPE_SORCERER && !GetIsRHDSorcerer()
        || nClass == CLASS_TYPE_BARD && !GetIsRHDBard()
        || nClass == CLASS_TYPE_CLERIC
        || nClass == CLASS_TYPE_HEALER
        || nClass == CLASS_TYPE_BLIGHTER
        || nClass == CLASS_TYPE_BLACKGUARD
        || nClass == CLASS_TYPE_UR_PRIEST
        || nClass == CLASS_TYPE_OCULAR
        || nClass == CLASS_TYPE_SLAYER_OF_DOMIEL
        || nClass == CLASS_TYPE_CULTIST_SHATTERED_PEAK
        || nClass == CLASS_TYPE_NENTYAR_HUNTER
        || nClass == CLASS_TYPE_SHADOWLORD
        || nClass == CLASS_TYPE_SOHEI
        || nClass == CLASS_TYPE_SOLDIER_OF_LIGHT
        || nClass == CLASS_TYPE_VASSAL
        || nClass == CLASS_TYPE_KNIGHT_MIDDLECIRCLE
        || nClass == CLASS_TYPE_KNIGHT_CHALICE
        || nClass == CLASS_TYPE_SHAMAN
        || nClass == CLASS_TYPE_DRUID
        || nClass == CLASS_TYPE_PALADIN
        || nClass == CLASS_TYPE_RANGER
		|| nClass == CLASS_TYPE_ASSASSIN;
}

int GetIsNSBClass(int nClass)
{
    return !GetIsBioSpellCastClass(nClass)
        && GetSpellbookTypeForClass(nClass) != SPELLBOOK_TYPE_INVALID;
}

// returns if a character should be using the newspellbook when casting
int UseNewSpellBook(object oCreature)
{
    int i;
    for (i = 1; i <= 8; i++)
    {
        int nClass = GetClassByPosition(i, oCreature);
        if(GetIsNSBClass(nClass))
            return TRUE;
    }
    
    // Special case
    if(GetLevelByClass(CLASS_TYPE_ULTIMATE_MAGUS, oCreature)) 
    	return TRUE;

    int nPrimaryArcane = GetPrimaryArcaneClass(oCreature);

    //check they have bard/sorc in first arcane slot
    if(nPrimaryArcane != CLASS_TYPE_BARD && nPrimaryArcane != CLASS_TYPE_SORCERER)
        return FALSE;
    //check they have arcane PrC or Draconic Breath/Arcane Grace
    if(!GetArcanePRCLevels(oCreature, nPrimaryArcane)
      && !(GetHasFeat(FEAT_DRACONIC_GRACE, oCreature) || GetHasFeat(FEAT_DRACONIC_BREATH, oCreature)))
        return FALSE;
    //check if the newspellbooks are disabled
    if((GetPRCSwitch(PRC_SORC_DISALLOW_NEWSPELLBOOK) && nPrimaryArcane == CLASS_TYPE_SORCERER) ||
        (GetPRCSwitch(PRC_BARD_DISALLOW_NEWSPELLBOOK) && nPrimaryArcane == CLASS_TYPE_BARD))
        return FALSE;
    //check they have bard/sorc levels
    if(!GetLevelByClass(CLASS_TYPE_BARD) && !GetLevelByClass(CLASS_TYPE_SORCERER))
        return FALSE;

    //at this point, they should be using the new spellbook
    return TRUE;
}

// wrapper for GetHasSpell, works for newspellbook 'fake' spells too (and metamagic)
// should return 0 if called with a normal spell when a character should be using the newspellbook
int PRCGetHasSpell(int nRealSpellID, object oCreature = OBJECT_SELF)
{
    if(!PRCGetIsRealSpellKnown(nRealSpellID, oCreature))
        return 0;
    int nUses = GetHasSpell(nRealSpellID, oCreature);

    int nClass, nSpellbookID, nCount, nMeta, i, j;
    int nSpellbookType, nSpellLevel;
    string sFile, sFeat;
    for(i = 1; i <= 8; i++)
    {
        nClass = GetClassByPosition(i, oCreature);
        sFile = GetFileForClass(nClass);
        nSpellbookType = GetSpellbookTypeForClass(nClass);
        nSpellbookID = RealSpellToSpellbookID(nClass, nRealSpellID);
        nMeta = RealSpellToSpellbookIDCount(nClass, nRealSpellID);
        if (nSpellbookID != -1)
        {   //non-spellbook classes should return -1
            for(j = nSpellbookID; j <= nSpellbookID + nMeta; j++)
            {
                sFeat = Get2DACache(sFile, "ReqFeat", j);
                if(sFeat != "")
                {
                    if(!GetHasFeat(StringToInt(sFeat), oCreature))
                        continue;
                }
                if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
                {
                    nCount = persistant_array_get_int(oCreature, "NewSpellbookMem_" + IntToString(nClass), j);
                    if(DEBUG) DoDebug("prc_inc_core >> PRCGetHasSpell: NewSpellbookMem_" + IntToString(nClass) + "[" + IntToString(j) + "] = " + IntToString(nCount));
                    if(nCount > 0)
                    {
                        nUses += nCount;
                    }
                }
                else if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
                {
                    nSpellLevel = StringToInt(Get2DACache(sFile, "Level", j));
                    nCount = persistant_array_get_int(oCreature, "NewSpellbookMem_" + IntToString(nClass), nSpellLevel);
                    if(DEBUG) DoDebug("prc_inc_core >> PRCGetHasSpell: NewSpellbookMem_" + IntToString(nClass) + "[" + IntToString(j) + "] = " + IntToString(nCount));
                    if(nCount > 0)
                    {
                        nUses += nCount;
                    }
                }
            }
        }
    }

    if(DEBUG) DoDebug("PRCGetHasSpell: RealSpellID = " + IntToString(nRealSpellID) + ", Uses = " + IntToString(nUses));
    return nUses;
}

// checks if oPC knows the specified spell
// only works for classes that use the PRC spellbook, there is currently no way to do this for Bioware spellcasters
int PRCGetIsRealSpellKnown(int nRealSpellID, object oPC = OBJECT_SELF)
{
    if(GetHasSpell(nRealSpellID, oPC))  //FUGLY HACK: bioware class having uses of the spell
        return TRUE;                    //  means they know the spell (close enough)
    int nClass;
    int nClassSlot = 1;
    while(nClassSlot <= 8)
    {
        nClass = GetClassByPosition(nClassSlot, oPC);
        if(GetIsDivineClass(nClass) || GetIsArcaneClass(nClass))
            if(PRCGetIsRealSpellKnownByClass(nRealSpellID, nClass, oPC))
                return TRUE;
        nClassSlot++;
    }
    // got here means no match
    return FALSE;
}

// checks if oPC knows the specified spell
// only works for classes that use the PRC spellbook, there is currently no way to do this for Bioware spellcasters
// this will only check the spellbook of the class specified
int PRCGetIsRealSpellKnownByClass(int nRealSpellID, int nClass, object oPC = OBJECT_SELF)
{
    // check for whether bard and sorc are using the prc spellbooks
    if (nClass == CLASS_TYPE_BARD || nClass == CLASS_TYPE_SORCERER)
    {
        if (!UseNewSpellBook(oPC))
            return FALSE;
    }

    // get the cls_spell_***.2da index for the real spell
    int nSpellbookSpell = RealSpellToSpellbookID(nClass, nRealSpellID);
    if (nSpellbookSpell == -1)
        return FALSE;

    string sFile = GetFileForClass(nClass);
    string sSpellLevel = Get2DACache(sFile, "Level", nSpellbookSpell);
    if (sSpellLevel == "")
        return FALSE;

    int nSpellLevel = StringToInt(sSpellLevel);
    int nSpellbookType = GetSpellbookTypeForClass(nClass);

    // Check whether the class can actually cast spells of this circle.
    int nCasterLevel = GetSpellslotLevel(nClass, oPC);
    int nAbility = GetAbilityScoreForClass(nClass, oPC);
    if (GetSlotCount(nCasterLevel, nSpellLevel, nAbility, nClass, oPC) <= 0)
        return FALSE;

    // Prepared casters know their full list, except Archivist.
    if (nSpellbookType == SPELLBOOK_TYPE_PREPARED && nClass != CLASS_TYPE_ARCHIVIST)
        return TRUE;

    // Spontaneous casters only know spells they've actually learned.
    if (nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
    {
        int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookSpell));
        if (GetHasFeat(nFeatID, oPC))
            return TRUE;
    }

    return FALSE;
}


// checks if oPC knows the specified spell
// only works for classes that use the PRC spellbook, there is currently no way to do this for Bioware spellcasters
// this will only check the spellbook of the class specified
/* int PRCGetIsRealSpellKnownByClass(int nRealSpellID, int nClass, object oPC = OBJECT_SELF)
{
    // check for whether bard and sorc are using the prc spellbooks
    if (nClass == CLASS_TYPE_BARD || nClass == CLASS_TYPE_SORCERER)
    {
        if(!UseNewSpellBook(oPC))
            return FALSE;
    }

    // get the cls_spell_***.2da index for the real spell
    int nSpellbookSpell = RealSpellToSpellbookID(nClass, nRealSpellID);
    // if the spell does not exist in the spellbook, return FALSE
    if (nSpellbookSpell == -1)
        return FALSE;
    // next check if the PC is high enough level to know the spell
    string sFile    = GetFileForClass(nClass);
    int nSpellLevel = -1;
    string sSpellLevel  = Get2DACache(sFile, "Level", nSpellbookSpell);
    if (sSpellLevel != "")
        nSpellLevel = StringToInt(sSpellLevel);
	if (nClass == CLASS_TYPE_SUBLIME_CHORD)  
	{  
		// Sublime Chord gets access to 4th level spells at level 1  
		// Skip level requirement check for this class  
	}  
	else  
	{  
		// Original level check for other classes  
		if ((GetLevelByClass(nClass) < nSpellLevel) || nSpellLevel == -1)  
			return FALSE; // not high enough level  
	}		
/*  if ((GetLevelByClass(nClass) < nSpellLevel) || nSpellLevel == -1)
        return FALSE; // not high enough level */
    // at this stage, prepared casters know the spell and only spontaneous classes need checking
    // there are exceptions and these need hardcoding:

/*    if((GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_PREPARED) && nClass != CLASS_TYPE_ARCHIVIST)
        return TRUE;

    // spontaneous casters have all their known spells as hide feats
    // get the featID of the spell
    int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookSpell));
    if (GetHasFeat(nFeatID, oPC))
        return TRUE;

    return FALSE;
}
 */
 
//routes to action cast spell, but puts a wrapper around to tell other functions its a
//SLA, so dont craft etc
//also defaults th totalDC to 10+spellevel+chamod
//this is Base DC, not total DC. SLAs are still spells, so spell focus should still apply.
void DoRacialSLA(int nSpellID, int nCasterlevel = 0, int nTotalDC = 0, int bInstantCast = FALSE)
{
    if(DEBUG) DoDebug("Spell DC passed to DoRacialSLA: " + IntToString(nTotalDC));
    if(nTotalDC == 0)
        nTotalDC = 10
            +StringToInt(Get2DACache("spells", "Innate", nSpellID))
            +GetAbilityModifier(ABILITY_CHARISMA);

    ActionDoCommand(SetLocalInt(OBJECT_SELF, "SpellIsSLA", TRUE));
    if(DEBUG) DoDebug("Spell DC entered in ActionCastSpell: " + IntToString(nTotalDC));
    ActionCastSpell(nSpellID, nCasterlevel, 0, nTotalDC, METAMAGIC_NONE, CLASS_TYPE_INVALID, FALSE, FALSE, OBJECT_INVALID, bInstantCast);
    //ActionCastSpell(nSpellID, nCasterlevel, 0, nTotalDC);
    ActionDoCommand(DeleteLocalInt(OBJECT_SELF, "SpellIsSLA"));
}

void DeleteLocalManifestation(object oObject, string sName)
{
    DeleteLocalObject(oObject, sName + "_oManifester");

    DeleteLocalInt(oObject, sName + "_bCanManifest");
    DeleteLocalInt(oObject, sName + "_nPPCost");
    DeleteLocalInt(oObject, sName + "_nPsiFocUsesRemain");
    DeleteLocalInt(oObject, sName + "_nManifesterLevel");
    DeleteLocalInt(oObject, sName + "_nSpellID");

    DeleteLocalInt(oObject, sName + "_nTimesAugOptUsed_1");
    DeleteLocalInt(oObject, sName + "_nTimesAugOptUsed_2");
    DeleteLocalInt(oObject, sName + "_nTimesAugOptUsed_3");
    DeleteLocalInt(oObject, sName + "_nTimesAugOptUsed_4");
    DeleteLocalInt(oObject, sName + "_nTimesAugOptUsed_5");
    DeleteLocalInt(oObject, sName + "_nTimesGenericAugUsed");

    DeleteLocalInt(oObject, sName + "_bChain");
    DeleteLocalInt(oObject, sName + "_bEmpower");
    DeleteLocalInt(oObject, sName + "_bExtend");
    DeleteLocalInt(oObject, sName + "_bMaximize");
    DeleteLocalInt(oObject, sName + "_bSplit");
    DeleteLocalInt(oObject, sName + "_bTwin");
    DeleteLocalInt(oObject, sName + "_bWiden");
    DeleteLocalInt(oObject, sName + "_bQuicken");
}

void DeleteLocalMystery(object oObject, string sName)
{
    DeleteLocalObject(oObject, sName + "_oShadow");

    DeleteLocalInt(oObject, sName + "_bCanMyst");
    DeleteLocalInt(oObject, sName + "_nShadowcasterLevel");
    DeleteLocalInt(oObject, sName + "_nMystId"); 
    DeleteLocalInt(oObject, sName + "_nPen");
    DeleteLocalInt(oObject, sName + "_bIgnoreSR"); 

    DeleteLocalInt(oObject, sName + "_bEmpower");
    DeleteLocalInt(oObject, sName + "_bExtend");
    DeleteLocalInt(oObject, sName + "_bMaximize");
    DeleteLocalInt(oObject, sName + "_bQuicken");
    
    DeleteLocalInt(oObject, sName + "_nSaveDC");
    DeleteLocalFloat(oObject, sName + "_fDur");
}

//::void main (){}