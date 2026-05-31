////////////////////////////////////////////////////////////////////////////////////
/*             Combined wrappers for both Win32 and Linux NWNX funcs              */
////////////////////////////////////////////////////////////////////////////////////

#include "inc_debug"

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

// Used in OnModuleLoad event to auto-detect if NWNX_Funcs plugin is enabled (DEFUNCT)
void PRC_Funcs_Init(object oModule);

// Sets the amount of hitpoints oObject has currently to nHP
void PRC_Funcs_SetCurrentHitPoints(object oCreature, int nHP);

// Sets the amount of hitpoints oObject can maximally have to nHP
void PRC_Funcs_SetMaxHitPoints(object oCreature, int nHP, int nLevel = 0);

// Changes the skill ranks for nSkill on oObject by iValue
void PRC_Funcs_ModSkill(object oCreature, int nSkill, int nValue, int nLevel = 0);

// Sets a base ability score nAbility (ABILITY_STRENGTH, ABILITY_DEXTERITY, etc) to nValue
// The range of nValue is 3 to 255
void PRC_Funcs_SetAbilityScore(object oCreature, int nAbility, int nValue);

// Changes a base ability score nAbility (ABILITY_STRENGTH, ABILITY_DEXTERITY, etc) by nValue
void PRC_Funcs_ModAbilityScore(object oCreature, int nAbility, int nValue);

// Adds a feat to oObject's general featlist
// If nLevel is greater than 0 the feat is also added to the featlist for that level
void PRC_Funcs_AddFeat(object oCreature, int nFeat, int nLevel=0);

// Checks if oCreature inherently knows a feat (as opposed to a feat given from an equipped item)
// Returns FALSE if oCreature does not know the feat, TRUE if the feat is known
// The return value (if greater than 0) also denotes the position of the feat in the general feat list offset by +1
int  PRC_Funcs_GetFeatKnown(object oCreature, int nFeat);

// Changes the saving throw bonus nSavingThrow of oObject by nValue;
void PRC_Funcs_ModSavingThrowBonus(object oCreature, int nSavingThrow, int nValue);

// Sets the base natural AC
void PRC_Funcs_SetBaseNaturalAC(object oCreature, int nValue);

// Returns the base natural AC
int PRC_Funcs_GetBaseNaturalAC(object oCreature);

// Sets the specialist spell school of a Wizard
void PRC_Funcs_SetWizardSpecialization(object oCreature, int iSpecialization, int nClass = CLASS_TYPE_WIZARD);

// Returns the specialist spell school of a Wizard
int PRC_Funcs_GetWizardSpecialization(object oCreature, int nClass = CLASS_TYPE_WIZARD);

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int _PRC_NWNXFuncsZero(object oObject, string sFunc) {
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        SetLocalString(oObject, sFunc, "-");
    else if (nVersion == 2)
        SetLocalString(oObject, sFunc, "          ");
    int nResult = StringToInt(GetLocalString(oObject, sFunc));
    DeleteLocalString(oObject, sFunc);
    return nResult;
}

int _PRC_NWNXFuncsOne(object oObject, string sFunc, int nVal1) {
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        SetLocalString(oObject, sFunc, IntToString(nVal1));
    else if (nVersion == 2)
        SetLocalString(oObject, sFunc, IntToString(nVal1) + "          ");
    int nResult = StringToInt(GetLocalString(oObject, sFunc));
    DeleteLocalString(oObject, sFunc);
    return nResult;
}

int _PRC_NWNXFuncsTwo(object oObject, string sFunc, int nVal1, int nVal2) {
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        SetLocalString(oObject, sFunc, IntToString(nVal1) + " " + IntToString(nVal2));
    else if (nVersion == 2)
        SetLocalString(oObject, sFunc, IntToString(nVal1) + " " + IntToString(nVal2) + "          ");
    int nResult = StringToInt(GetLocalString(oObject, sFunc));
    DeleteLocalString(oObject, sFunc);
    return nResult;
}

int _PRC_NWNXFuncsThree(object oObject, string sFunc, int nVal1, int nVal2, int nVal3) {
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        SetLocalString(oObject, sFunc, IntToString(nVal1) + " " + IntToString(nVal2) + " " + IntToString(nVal3));
    else if (nVersion == 2)
        SetLocalString(oObject, sFunc, IntToString(nVal1) + " " + IntToString(nVal2) + " " + IntToString(nVal3) + "          ");
    int nResult = StringToInt(GetLocalString(oObject, sFunc));
    DeleteLocalString(oObject, sFunc);
    return nResult;
}

int _PRC_NWNXFuncsFour(object oObject, string sFunc, int nVal1, int nVal2, int nVal3, int nVal4) {
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        SetLocalString(oObject, sFunc, IntToString(nVal1) + " " + IntToString(nVal2) + " " + IntToString(nVal3) + " " + IntToString(nVal4));
    else if (nVersion == 2)
        SetLocalString(oObject, sFunc, IntToString(nVal1) + " " + IntToString(nVal2) + " " + IntToString(nVal3) + " " + IntToString(nVal4) + "          ");
    int nResult = StringToInt(GetLocalString(oObject, sFunc));
    DeleteLocalString(oObject, sFunc);
    return nResult;
}

void PRC_Funcs_Init(object oModule)
{
    //Only NWNX for Win32 implements GetHasLocalVariable, so if this succeeds, that's what we're using
    string sTestVariable = "PRC_TEST_NWNX_FUNCS";
    SetLocalString(oModule, sTestVariable, "1");
    SetLocalString(oModule, "NWNX!FUNCS!GETHASLOCALVARIABLE", sTestVariable + " 3"); //3 is the variable type
        //NOTE: don't use _PRC_NWNXFuncsX functions here; they depend on the PRC_NWNXEE_ENABLED that we haven't set yet
    int iTest = StringToInt(GetLocalString(oModule, "NWNX!FUNCS!GETHASLOCALVARIABLE"));
    DeleteLocalString(oModule, "NWNX!FUNCS!GETHASLOCALVARIABLE");
    DeleteLocalString(oModule, sTestVariable);

    if (iTest)
        SetLocalInt(oModule, "PRC_NWNXEE_ENABLED", 1); //1 == win32
    else
    {
        //NWNX GetLocalVariableCount behaves differently for win32 and linux, 
        //but we know we're not using the win32 version (because the above check failed),
        //so try the linux version of GetLocalVariableCount.
        //Since PRC_VERSION is a module-level variable, and we know it's defined
        //by OnLoad before it calls this function, the variable count will be at
        //least 1 if we're using NWNX. If not, 0 will be returned to indicate that
        //the call failed because NWNX funcs is not present.
        string sFunc = "NWNX!FUNCS!GETLOCALVARIABLECOUNT";
        SetLocalString(oModule, sFunc, "          ");
            //NOTE: don't use _PRC_NWNXFuncsX functions here; they depend on the PRC_NWNXEE_ENABLED that we haven't set yet
            //NOTE: the number being returned by GetLocalVariableCount() on Linux seems bogus to me (it's huge, e.g. 294,654,504),
                //but it does seem to be reliably zero when NWNX funcs is not present, and so far has been reliably non-zero
                //when it is present. That's all we need here.
                //Info: on win32, GetLocalVariableCount() is returning much more reasonable numbers (e.g. 1707).
        int nVariables = StringToInt(GetLocalString(oModule, sFunc));
        DeleteLocalString(oModule, sFunc);
        if (nVariables)
            SetLocalInt(oModule, "PRC_NWNXEE_ENABLED", 2); //2 == linux
    }
}

void PRC_Funcs_SetMaxHitPoints(object oCreature, int nHP, int nLevel = 0)
{
    //:: Default to total hit dice if not provided
    if (nLevel <= 0)
        nLevel = GetHitDice(oCreature);

    //:: Payload for NWNxEE shim
    SetLocalInt(oCreature, "PRC_EE_MAXHP", nHP);
    SetLocalInt(oCreature, "PRC_EE_MAXHP_LEVEL", nLevel);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_set_maxhp", oCreature);
}

/* void PRC_Funcs_SetMaxHitPoints(object oCreature, int nHP)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1 || nVersion == 2)
    {
        _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!SETMAXHITPOINTS", nHP);
        DeleteLocalString(oCreature, "NWNX!FUNCS!SETMAXHITPOINTS");
    }
} */

void PRC_Funcs_ModSkill(object oCreature, int nSkill, int nValue, int nLevel = 0)
{
    //:: Default to current level if not provided
    if (nLevel <= 0)
        nLevel = GetHitDice(oCreature);

    //:: Payload for NWNxEE shim
    SetLocalInt(oCreature, "PRC_EE_SKILL", nSkill);
    SetLocalInt(oCreature, "PRC_EE_SKILL_DELTA", nValue);
    SetLocalInt(oCreature, "PRC_EE_SKILL_LEVEL", nLevel);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_mod_skill", oCreature);
}

/* void PRC_Funcs_ModSkill(object oCreature, int nSkill, int nValue)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        _PRC_NWNXFuncsThree(oCreature, "NWNX!FUNCS!SETSKILL", nSkill, nValue, 1); //The 1 is a flag specifying modify instead of set
    else if (nVersion == 2)
        _PRC_NWNXFuncsTwo(oCreature, "NWNX!FUNCS!MODIFYSKILLRANK", nSkill, nValue);
} */

void PRC_Funcs_SetAbilityScore(object oCreature, int nAbility, int nValue)
{
    //:: Payload for NWNxEE shim
    SetLocalInt(oCreature, "PRC_EE_ABILITY", nAbility);
    SetLocalInt(oCreature, "PRC_EE_ABILITY_VALUE", nValue);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_set_ability", oCreature);
}

/* void PRC_Funcs_SetAbilityScore(object oCreature, int nAbility, int nValue)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        _PRC_NWNXFuncsFour(oCreature, "NWNX!FUNCS!SETABILITYSCORE", nAbility, nValue, 0, 0); //The first 0 is a flag specifying set instead of modify
    else if (nVersion == 2)
        _PRC_NWNXFuncsTwo(oCreature, "NWNX!FUNCS!SETABILITYSCORE", nAbility, nValue);
} */

void PRC_Funcs_ModAbilityScore(object oCreature, int nAbility, int nValue)
{
    	if(DEBUG) DoDebug("============================================");	
		if(DEBUG) DoDebug("PRC_Funcs_ModAbiltyScore: Starting function.");
		if(DEBUG) DoDebug("============================================");	
	
	//:: Payload for NWNxEE shim
    SetLocalInt(oCreature, "PRC_EE_ABILITY", nAbility);
    SetLocalInt(oCreature, "PRC_EE_ABILITY_DELTA", nValue);
	
	if(DEBUG) DoDebug("PRC_Funcs_ModAbiltyScore: Variables Set");

    //:: Fire NWNxEE shim
	if(DEBUG) DoDebug("PRC_Funcs_ModAbiltyScore: Firing prc_mod_ability");
    ExecuteScript("prcx_mod_ability", oCreature);
}

/* void PRC_Funcs_ModAbilityScore(object oCreature, int nAbility, int nValue)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        _PRC_NWNXFuncsFour(oCreature, "NWNX!FUNCS!SETABILITYSCORE", nAbility, nValue, 1, 0); //The 1 is a flag specifying modify instead of set
    else if (nVersion == 2)
        _PRC_NWNXFuncsTwo(oCreature, "NWNX!FUNCS!MODIFYABILITYSCORE", nAbility, nValue);
} */

void PRC_Funcs_AddFeat(object oCreature, int nFeat, int nLevel = 0)
{
    //:: Payload for NWNxEE shim
    SetLocalInt(oCreature, "PRC_EE_FEAT", nFeat);
    SetLocalInt(oCreature, "PRC_EE_FEAT_LEVEL", nLevel);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_add_feat", oCreature);
}

/* void PRC_Funcs_AddFeat(object oCreature, int nFeat, int nLevel=0)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
    {
        if (!nLevel)
            _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!ADDFEAT", nFeat);
        else if(nLevel > 0)
            _PRC_NWNXFuncsTwo(oCreature, "NWNX!FUNCS!ADDFEATATLEVEL", nLevel, nFeat);
    }
    else if (nVersion == 2)
    {
        if (!nLevel)
            _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!ADDKNOWNFEAT", nFeat);
        else if(nLevel > 0)
            _PRC_NWNXFuncsTwo(oCreature, "NWNX!FUNCS!ADDKNOWNFEATATLEVEL", nLevel, nFeat);
    }
} */

/**
 * @brief Determines whether a creature inherently knows a feat.
 *
 * This function returns TRUE only if the specified feat is an inherent
 * (true) feat possessed by the creature. Bonus feats granted via
 * EFFECT_TYPE_BONUS_FEAT effects are explicitly ignored.
 *
 * This allows reliable differentiation between permanent feats
 * (e.g. class, racial, or template feats) and temporary or granted
 * bonus feats applied through effects.
 *
 * No NWNxEE shim is required; this function operates entirely using
 * stock NWScript functionality.
 *
 * @param oCreature   The creature to check.
 * @param nFeatIndex  The feat constant to test.
 *
 * @return TRUE if the creature inherently knows the feat and does not
 *         possess it solely via a bonus feat effect; FALSE otherwise.
 */
int PRC_Funcs_GetFeatKnown(object oCreature, int nFeatIndex)  
{  
    //:: Check for an EffectBonusFeat with this feat ID  
    effect eCheck = GetFirstEffect(oCreature);  
    int bHasBonusFeatEffect = FALSE;  
    while (GetIsEffectValid(eCheck))  
    {  
        if (GetEffectType(eCheck) == EFFECT_TYPE_BONUS_FEAT && GetEffectInteger(eCheck, 0) == nFeatIndex)  
        {  
            bHasBonusFeatEffect = TRUE;  
            break;  
        }  
        eCheck = GetNextEffect(oCreature);  
    }  
  
    //;: Return TRUE only if inherent and no matching bonus feat effect  
    return (!bHasBonusFeatEffect && GetHasFeat(nFeatIndex, oCreature));  
}

/* int PRC_Funcs_GetFeatKnown(object oCreature, int nFeatIndex)
{
    //:: Payload for NWNxEE shim
    SetLocalInt(oCreature, "PRC_EE_FEAT", nFeatIndex);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_knows_feat", oCreature);

    //:: Read result
    int nResult = GetLocalInt(oCreature, "PRC_EE_FEAT_RESULT");

    //:: Clean up locals
    DeleteLocalInt(oCreature, "PRC_EE_FEAT");
    DeleteLocalInt(oCreature, "PRC_EE_FEAT_RESULT");

    return nResult;
} */

/* int PRC_Funcs_GetFeatKnown(object oCreature, int nFeatIndex)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        return _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!GETFEATKNOWN", nFeatIndex);
    else if (nVersion == 2)
        return _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!GETKNOWNFEAT", nFeatIndex);
    return 0;
} */

void PRC_Funcs_ModSavingThrowBonus(object oCreature, int nSavingThrow, int nValue)
{
    //:: Payload for NWNxEE shim
    SetLocalInt(oCreature, "PRC_EE_STYPE", nSavingThrow);
    SetLocalInt(oCreature, "PRC_EE_SDELTA", nValue);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_mod_save", oCreature);
}

/* void PRC_Funcs_ModSavingThrowBonus(object oCreature, int nSavingThrow, int nValue)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        _PRC_NWNXFuncsThree(oCreature, "NWNX!FUNCS!SETSAVINGTHROWBONUS", nSavingThrow, nValue, 1); //The 1 is a flag specifying modify instead of set
    else if (nVersion == 2)
    {
        int nNewValue = _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!GETSAVINGTHROWBONUS", nSavingThrow) + nValue;
        if (nNewValue < 0)
            nNewValue = 0;
        else if (nNewValue > 127)
            nNewValue = 127;
        _PRC_NWNXFuncsTwo(oCreature, "NWNX!FUNCS!SETSAVINGTHROWBONUS", nSavingThrow, nNewValue);
    }
} */

void PRC_Funcs_SetBaseNaturalAC(object oCreature, int nValue)
{
    //:: Payload for NWNxEE shim
    SetLocalInt(oCreature, "PRC_EE_BASEAC", nValue);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_set_ac", oCreature);
}

/* void PRC_Funcs_SetBaseNaturalAC(object oCreature, int nValue)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        _PRC_NWNXFuncsTwo(oCreature, "NWNX!FUNCS!SETBASEAC", nValue, AC_NATURAL_BONUS);
    else if (nVersion == 2)
        _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!SETACNATURALBASE", nValue);
} */

int PRC_Funcs_GetBaseNaturalAC(object oCreature)
{
    //:: Fire NWNxEE shim
    ExecuteScript("prcx_get_ac", oCreature);

    //:: Read result
    int nAC = GetLocalInt(oCreature, "PRC_EE_BASEAC_RESULT");

    //:: Clean up
    DeleteLocalInt(oCreature, "PRC_EE_BASEAC_RESULT");

    return nAC;
}

/* int PRC_Funcs_GetBaseNaturalAC(object oCreature)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        return _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!GETBASEAC", AC_NATURAL_BONUS);
    else if (nVersion == 2)
        return _PRC_NWNXFuncsZero(oCreature, "NWNX!FUNCS!GETACNATURALBASE");
    return 0;
} */

void PRC_Funcs_SetCurrentHitPoints(object oCreature, int nHP)
{
    //:: Sanity check
    if (nHP < 0)
        nHP = 0;

    //:: Set current hit points directly
	//:: Was this not a native function in the past?
    SetCurrentHitPoints(oCreature, nHP);
}

/* void PRC_Funcs_SetCurrentHitPoints(object oCreature, int nHP) 
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1 || nVersion == 2)
        _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!SETCURRENTHITPOINTS", nHP);
} */

void PRC_Funcs_SetCreatureSize(object oCreature, int nSize)
{
	//:: Pass parameters via locals
    SetLocalInt(oCreature, "PRC_EE_CREATURESIZE", nSize);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_set_size", oCreature);
    
}

/* void PRC_Funcs_SetCreatureSize (object oCreature, int nSize) 
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1 || nVersion == 2)
        _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!SETCREATURESIZE", nSize);
} */

void PRC_Funcs_SetRace(object oCreature, int nRace)
{
    //:: Pass parameters via locals
    SetLocalInt(oCreature, "PRC_EE_RACETYPE", nRace);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_set_race", oCreature);
}


/* void PRC_Funcs_SetRace(object oCreature, int nRace) 
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1)
        _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!SETRACE", nRace);
    else if (nVersion == 2)
        _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!SETRACIALTYPE", nRace);
} */

void PRC_Funcs_SetWizardSpecialization(object oCreature, int iSpecialization, int nClass = CLASS_TYPE_WIZARD)
{
    //:: Pass parameters via locals
    SetLocalInt(oCreature, "PRC_EE_WIZCLASS", nClass);
    SetLocalInt(oCreature, "PRC_EE_WIZSCHOOL", iSpecialization);

    //:: Fire NWNxEE shim
    ExecuteScript("prcx_set_spec", oCreature);
}

/* void PRC_Funcs_SetWizardSpecialization(object oCreature, int iSpecialization)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1 || nVersion == 2)
        _PRC_NWNXFuncsOne(oCreature, "NWNX!FUNCS!SETWIZARDSPECIALIZATION", iSpecialization);
} */

//:: This is a native function now.
int PRC_Funcs_GetWizardSpecialization(object oCreature, int nClass = CLASS_TYPE_WIZARD)
{
    return GetSpecialization(oCreature, nClass);
}

/* int PRC_Funcs_GetWizardSpecialization(object oCreature)
{
    int nVersion = GetLocalInt(GetModule(), "PRC_NWNXEE_ENABLED");
    if (nVersion == 1 || nVersion == 2)
        return _PRC_NWNXFuncsZero(oCreature, "NWNX!FUNCS!GETWIZARDSPECIALIZATION");
    return 0;
} */

//:: void main(){}