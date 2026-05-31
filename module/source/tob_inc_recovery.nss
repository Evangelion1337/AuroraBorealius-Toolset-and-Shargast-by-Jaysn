//::///////////////////////////////////////////////
//:: Tome of Battle include: Maneuver Recovery
//:: tob_inc_martlore
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to recovery and readying maneuvers
    See page #28 of Tome of Battle

    Functions below are called by the initiator as
    he makes a maneuver, or when recovering or readying

    @author Stratovarius
    @date   Created - 2007.3.25
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//:: Test Void
//void main (){}

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int MANEUVER_READIED   = 1;
const int MANEUVER_RECOVERED = 2;
const int MANEUVER_GRANTED   = 3;
const int MANEVUER_WITHHELD  = 4;

const string _MANEUVER_LIST_RDYMODIFIER      = "_ReadyModifier";

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Gets the number of Maneuvers a character has readied
 *
 * @param oPC       The creature whose Maneuvers to check
 * @param nList     The list to check. One of MANEUVER_LIST_*
 * @return          The number of Maneuvers readied
 */
int GetReadiedCount(object oPC, int nList);

/**
 * Gets the maximum number of Maneuvers a character may ready.
 *
 * @param oPC       Character to determine maximum Maneuvers readied
 * @param nList     MANEUVER_LIST_* of the list to determine maximum Maneuvers for
 * @return          Maximum number of Maneuvers that oPC may ready
 */
int GetMaxReadiedCount(object oPC, int nList);

/**
 * Gets the value of the Maneuvers readied modifier, which is a value that is added
 * to the 2da-specified maximum Maneuvers readied to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to get
 * @param nList     The list the maximum Maneuvers readied from which the modifier
 *                  modifies. One of MANEUVER_LIST_*
 */
int GetReadiedManeuversModifier(object oCreature, int nList);

/**
 * Sets the value of the Maneuvers readied modifier, which is a value that is added
 * to the 2da-specified maximum Maneuvers readied to determine the actual maximum.
 *
 * @param oCreature The creature whose modifier to set
 * @param nList     The list the maximum Maneuvers readied from which the modifier
 *                  modifies. One of MANEUVER_LIST_*
 */
void SetReadiedManeuversModifier(object oCreature, int nList, int nNewValue);

/**
 * Readies the chosen Maneuver. Also checks to see if there are any slots left
 *
 * @param oPC       Character readying maneuver
 * @param nList     MANEUVER_LIST_* of the list to ready
 * @param nMoveId   Maneuver to ready
 */
void ReadyManeuver(object oPC, int nList, int nMoveId);

/**
 * Returns whether maneuver is readied or not
 *
 * @param oPC       Character to check
 * @param nList     MANEUVER_LIST_*
 * @param nMoveId   Maneuver to check
 * @return          TRUE or FALSE
 */
int GetIsManeuverReadied(object oPC, int nList, int nMoveId);

/**
 * Returns whether maneuver is expended or not
 *
 * @param oPC       Character to check
 * @param nList     MANEUVER_LIST_*
 * @param nMoveId   Maneuver to check
 * @return          TRUE or FALSE
 */
int GetIsManeuverExpended(object oPC, int nList, int nMoveId);

/**
 * Expends the chosen Maneuver.
 *
 * @param oPC       Character to check
 * @param nList     MANEUVER_LIST_*
 * @param nMoveId   Maneuver to expend
 */
void ExpendManeuver(object oPC, int nList, int nMoveId);

/**
 * Clears all local ints marking maneuvers as expended
 *
 * @param oPC       Character to clear
 * @param nList     MANEUVER_LIST_*
 */
void RecoverExpendedManeuvers(object oPC, int nList);

/**
 * Recovers the chosen Maneuver.
 *
 * @param oPC       Character to check
 * @param nList     MANEUVER_LIST_*
 * @param nMoveId   Maneuver to recover
 */
void RecoverManeuver(object oPC, int nList, int nMoveId);

/**
 * Checks to see if the PC is in a Warblade recovery round
 * This prevents all use of maneuvers or stances during that round.
 *
 * @param oPC       Character to clear
 * @return          TRUE or FALSE
 */
int GetIsWarbladeRecoveryRound(object oPC);

/**
 * Marks maneuvers as granted or withheld.
 *
 * @param oPC       Character to grant maneuvers to
 * @param nList     MANEUVER_LIST_*
 */
void GrantManeuvers(object oPC, int nList);

/**
 * Clears all local ints marking maneuvers as readied
 *
 * @param oPC       Character to clear
 * @param nList     MANEUVER_LIST_*
 */
void ClearReadiedManeuvers(object oPC, int nList);

/**
 * Grants a withheld maneuver
 * Only works on Crusaders
 *
 * @param oPC       Character to grant maneuvers to
 * @param nList     MANEUVER_LIST_*
 * @param nMoveId   Maneuver to grant
 */
void GrantWithheldManeuver(object oPC, int nList, int nMoveId = -1);

/**
 * Returns whether maneuver is granted or not
 * Only works on Crusaders
 *
 * @param oPC       Character to check
 * @param nMoveId   Maneuver to check
 * @return          TRUE or FALSE
 */
int GetIsManeuverGranted(object oPC, int nMoveId);

/**
 * Clears all local ints marking maneuvers as granted or withheld
 * Only works on Crusaders
 *
 * @param oPC       Character to clear
 */
void ClearGrantedWithheldManeuvers(object oPC);

/**
 * Starting function for Crusader recovery, calls DoCrusaderGranting
 * Only works on Crusaders
 *
 * @param oPC       Crusader
 */
void BeginCrusaderGranting(object oPC);

/**
 * Recursive function granting maneuvers each round in combat
 * Will end when combat ends
 * Only works on Crusaders
 *
 * @param oPC       Crusader
 * @param nTrip     Round of combat. Takes values from 1 to 5, always starts with 1.
 */
void DoCrusaderGranting(object oPC, int nTrip);


/**
 * Returns TRUE if a maneuver was expended, FALSE otherwise
 * @param oPC           Character to check
 * @param nList         MANEUVER_LIST_*
 * @param nDiscipline   DISCIPLINE_* the maneuver has to be from
 *
 * @return              TRUE or FALSE
 */
int ExpendRandomManeuver(object oPC, int nList, int nDiscipline = -1);

/**
 * Clears all local ints marking maneuvers as expended
 *
 * @param oPC       Character to clear
 * @param nPRC      Specific PRC to recover, else all.
 */
void RecoverPrCAbilities(object oPC);

/**
 * Heals 3 + 1 point per character level ones per minute
 *
 * @param oPC       Character to heal
 */
void VitalRecovery(object oPC);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_lookups"
#include "tob_inc_tobfunc"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetReadiedCount(object oPC, int nList)
{
    return GetLocalInt(oPC, "ManeuverReadied" + IntToString(nList));
}

int GetMaxReadiedCount(object oPC, int nList)
{
    int nLevel = GetLevelByClass(nList, oPC);
    // 2das start at Row 0
    int nMaxReadied = StringToInt(Get2DACache(GetAMSKnownFileName(nList), "ManeuversReadied", nLevel-1));
    // Add in the custom modifier
    nMaxReadied += GetReadiedManeuversModifier(oPC, nList);
    if(nList == MANEUVER_LIST_SWORDSAGE)
        nMaxReadied += GetHasFeat(FEAT_EXTRA_GRANTED_MANEUVER, oPC);

    if(DEBUG) DoDebug("tob_inc_recovery: MaxManeuvers Readied: " +IntToString(nMaxReadied));
    return nMaxReadied;
}

int GetReadiedManeuversModifier(object oCreature, int nList)
{
    return GetPersistantLocalInt(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(nList) + _MANEUVER_LIST_RDYMODIFIER);
}

void SetReadiedManeuversModifier(object oCreature, int nList, int nNewValue)
{
    SetPersistantLocalInt(oCreature, _MANEUVER_LIST_NAME_BASE + IntToString(nList) + _MANEUVER_LIST_RDYMODIFIER, nNewValue);
}

void ReadyManeuver(object oPC, int nList, int nMoveId)
{
    int nCount = GetReadiedCount(oPC, nList);
    int nMaxCount = GetMaxReadiedCount(oPC, nList);

    // If the PC can ready a maneuver and hasn't filled them all up
    if(nMaxCount > nCount)
    {
        nCount++;
        SetLocalInt(oPC, "ManeuverReadied" + IntToString(nList) + IntToString(nCount), nMoveId);
        SetLocalInt(oPC, "ManeuverReadied" + IntToString(nList), nCount);
        if(DEBUG) DoDebug("tob_inc_recovery: ReadyManeuver: " +IntToString(nMoveId));
    }
    else
        FloatingTextStringOnCreature("All maneuvers are readied", oPC, FALSE);
}

int GetIsManeuverReadied(object oPC, int nList, int nMoveId)
{
    // Counting through the local ints to determine if this one is readied
    int i, nMax = GetReadiedCount(oPC, nList);
    for(i = 1; i <= nMax; i++)
    {
        // If the value is valid, return true
        if(GetLocalInt(oPC, "ManeuverReadied" + IntToString(nList) + IntToString(i)) == nMoveId)
        {
            if(DEBUG) DoDebug("tob_inc_recovery: GetIsManeuverReadied: " + IntToString(nMoveId));
            return TRUE;
        }
    }
    return FALSE;
}

int GetIsManeuverExpended(object oPC, int nList, int nMoveId)
{
    // Counting through the local ints to determine if this one is expended
    int i, nMax = GetLocalInt(oPC, "ManeuverExpended" + IntToString(nList));
    for(i = 1; i <= nMax; i++)
    {
        // returns if the maneuver is expended
        if(GetLocalInt(oPC, "ManeuverExpended" + IntToString(nList) + IntToString(i)) == nMoveId)
        {
            if(DEBUG) DoDebug("tob_inc_recovery: GetIsManeuverExpended: " +IntToString(nMoveId));
            return TRUE;
        }
    }
    return FALSE;
}

void ExpendManeuver(object oPC, int nList, int nMoveId)
{
    int nCount = GetLocalInt(oPC, "ManeuverExpended" + IntToString(nList)) + 1;

    // This will mark the Maneuver Expended
    SetLocalInt(oPC, "ManeuverExpended" + IntToString(nList) + IntToString(nCount), nMoveId);
    SetLocalInt(oPC, "ManeuverExpended" + IntToString(nList), nCount);
    if(DEBUG) DoDebug("tob_inc_recovery: Expending Maneuver: " + IntToString(nMoveId));
}

void RecoverExpendedManeuvers(object oPC, int nList)
{
    if(DEBUG) DoDebug("tob_inc_recovery: Clearing expended maneuvers");
    // Counting through the local ints to clear them all
    int i, nMax = GetLocalInt(oPC, "ManeuverExpended" + IntToString(nList));
    DeleteLocalInt(oPC, "ManeuverExpended" + IntToString(nList));
    for(i = 1; i <= nMax; i++)
    {
        // Clear them all
        DeleteLocalInt(oPC, "ManeuverExpended" + IntToString(nList) + IntToString(i));
    }
    // Do Grant/Withheld Maneuvers whenever this is called on a Crusader
    if (nList == MANEUVER_LIST_CRUSADER)
    {
        // Make sure to clear them all first
        ClearGrantedWithheldManeuvers(oPC);
        // Then re-grant/withhold them
        GrantManeuvers(oPC, nList);
    }
    if (GetHasFeat(FEAT_VITAL_RECOVERY, oPC)) VitalRecovery(oPC);
}

void RecoverManeuver(object oPC, int nList, int nMoveId)
{
    // Counting through the local ints to determine if this one is expended
    int i, nMax = GetLocalInt(oPC, "ManeuverExpended" + IntToString(nList));
    for(i = 1; i <= nMax; i++)
    {
        // If it has been expended, clear that
        if(GetLocalInt(oPC, "ManeuverExpended" + IntToString(nList) + IntToString(i)) == nMoveId)
        {
            DeleteLocalInt(oPC, "ManeuverExpended" + IntToString(nList) + IntToString(i));
            if(DEBUG) DoDebug("tob_inc_recovery: Recovering Maneuver: " + IntToString(nMoveId));
        }
    }
    if (GetHasFeat(FEAT_VITAL_RECOVERY, oPC)) VitalRecovery(oPC);
}

int GetIsWarbladeRecoveryRound(object oPC)
{
    if(DEBUG) DoDebug("tob_inc_recovery: Warblade recovery check");
    return GetLocalInt(oPC, "WarbladeRecoveryRound");
}

void GrantRandomManeuver(object oPC, int nList = MANEUVER_LIST_CRUSADER)
{
    int nMax = GetLocalInt(oPC, "GrantRand#");
    if(!nMax) return;//nothing to grant

    SetLocalInt(oPC, "GrantRand#", nMax - 1);
    int x = Random(nMax)+1;
    int nMoveId = GetLocalInt(oPC, "GrantRand#" + IntToString(x));
    if(x != nMax)
        SetLocalInt(oPC, "GrantRand#" + IntToString(x), GetLocalInt(oPC, "GrantRand#" + IntToString(nMax)));
    DeleteLocalInt(oPC, "GrantRand#" + IntToString(nMax));

    //GrantWithheldManeuver(oPC, MANEUVER_LIST_CRUSADER, MoveId);
    // No point in granting an expended maneuver
    if(GetIsManeuverExpended(oPC, nList, nMoveId))
        RecoverManeuver(oPC, nList, nMoveId);

    int i = 1;
    while(i)
    {
        // If it hits a non-valid, break
        if(!GetLocalInt(oPC, "ManeuverGranted" + IntToString(i))) break;
        i++;
    }
    SetLocalInt(oPC, "ManeuverGranted" + IntToString(i), nMoveId);
}

void ListGrantedManeuvers(object oPC)
{
    int i;
    for(i = 1; i <= 4; i++)
    {
        int nMoveId = GetLocalInt(oPC, "ManeuverGranted" + IntToString(i));
        int nExpended = GetIsManeuverExpended(oPC, MANEUVER_LIST_CRUSADER, nMoveId);
        if (nMoveId > 0 && !nExpended) FloatingTextStringOnCreature(GetManeuverName(nMoveId) + " is granted", oPC, FALSE);
    }
}

void GrantManeuvers(object oPC, int nList = MANEUVER_LIST_CRUSADER)
{
    // Only crusader level matters for this
    int nLevel = GetLevelByClass(CLASS_TYPE_CRUSADER, oPC);
    // 2das start at Row 0
    int nGranted = StringToInt(Get2DACache(GetAMSKnownFileName(nList), "ManeuversGranted", nLevel-1));
    nGranted += GetReadiedManeuversModifier(oPC, nList);
    nGranted += GetHasFeat(FEAT_EXTRA_GRANTED_MANEUVER, oPC);

    // Counting through the local ints to determine how many are readied
    int i, nMaxReadied = GetReadiedCount(oPC, nList);
    SetLocalInt(oPC, "GrantRand#", nMaxReadied);
    for(i = 1; i <= nMaxReadied; i++)
    {
        // build temporary array for GrantRandomManeuver() function
        int nMoveId = GetLocalInt(oPC, "ManeuverReadied" + IntToString(nList) + IntToString(i));
        if(nMoveId)
            SetLocalInt(oPC, "GrantRand#" + IntToString(i), nMoveId);
    }
    for(i = 1; i <= nGranted; i++)
    {
        GrantRandomManeuver(oPC);
    }
    ListGrantedManeuvers(oPC);    
}

void ClearReadiedManeuvers(object oPC, int nList)
{
    if(DEBUG) DoDebug("tob_inc_recovery: Clearing readied maneuvers");
    // Counting through the local ints to clear them all
    int i, nMax = GetReadiedCount(oPC, nList);
    DeleteLocalInt(oPC, "ManeuverReadied" + IntToString(nList));
    for(i = 1; i <= nMax; i++)
    {
        // Clear them all
        DeleteLocalInt(oPC, "ManeuverReadied" + IntToString(nList) + IntToString(i));
    }
}

/*void GrantWithheldManeuver(object oPC, int nList, int nMoveId = -1)
{
    int i;
    string sPsiFile = GetAMSKnownFileName(nList);
    // 2das start at Row 0
    int nLevel = GetInitiatorLevel(oPC, nList);
    int nGranted = StringToInt(Get2DACache(sPsiFile, "ManeuversGranted", nLevel-1));
    int nReadied = StringToInt(Get2DACache(sPsiFile, "ManeuversReadied", nLevel-1));
    if(DEBUG) DoDebug("tob_inc_recovery: Maneuvers Granted: " + IntToString(nGranted));
    if(DEBUG) DoDebug("tob_inc_recovery: Maneuvers Readied: " + IntToString(nReadied));

    // If someone input a maneuver
    if (nMoveId > 0)
    {
        // No point in granting an expended maneuver
        if (GetIsManeuverExpended(oPC, nList, nMoveId))
            RecoverManeuver(oPC, nList, nMoveId);

        // 3 is always the number withheld
        for(i = nGranted; i < nReadied; i++)
        {
            // Making sure it gets marked properly
            int nGrantId = GetLocalInt(oPC, "ManeuverWithheld" + IntToString(i));
            // If it exists, mark it as ready and break out
            if (nMoveId == nGrantId)
            {
                if(DEBUG) DoDebug("tob_inc_recovery: Withheld Maneuver Granted: " + IntToString(nMoveId));
                DeleteLocalInt(oPC, "ManeuverWithheld" + IntToString(i));
                FloatingTextStringOnCreature(GetManeuverName(nMoveId) + " is granted", oPC, FALSE);
                SetLocalInt(oPC, "ManeuverGranted" + IntToString(i), nMoveId);
                break;
            }
        }
    }
    else
    {
        // 3 is always the number withheld
        for(i = nGranted; i < nReadied; i++)
        {
            nMoveId = GetLocalInt(oPC, "ManeuverWithheld" + IntToString(i));
            // If it exists, mark it as ready and break out
            if (nMoveId > 0)
            {
                if(DEBUG) DoDebug("tob_inc_recovery: Withheld Maneuver Granted: " + IntToString(nMoveId));
                DeleteLocalInt(oPC, "ManeuverWithheld" + IntToString(i));
                FloatingTextStringOnCreature(GetManeuverName(nMoveId) + " is granted", oPC, FALSE);
                SetLocalInt(oPC, "ManeuverGranted" + IntToString(i), nMoveId);
                break;
            }
        }
    }
}*/

int GetIsManeuverGranted(object oPC, int nMoveId)
{
    if(DEBUG) DoDebug("tob_inc_recovery: GetIsManeuverGranted Start");
    // Counting through the local ints to determine if this one is expended
    int i, nMax = GetReadiedCount(oPC, MANEUVER_LIST_CRUSADER);
    for(i = 1; i <= nMax; i++)
    {
        // returns if the maneuver is expended
        if(GetLocalInt(oPC, "ManeuverGranted" + IntToString(i)) == nMoveId)
        {
            if(DEBUG) DoDebug("tob_inc_recovery: GetIsManeuverGranted: " + IntToString(nMoveId));
            return TRUE;
        }
    }
    return FALSE;
}

void ClearGrantedWithheldManeuvers(object oPC)
{
    if(DEBUG) DoDebug("tob_inc_recovery: Clearing Granted and Withheld Maneuvers");
    // Counting through the local ints to clear them all
    int i, nMax = GetReadiedCount(oPC, MANEUVER_LIST_CRUSADER);
    for(i = 1; i <= nMax; i++)
    {
        // Clear them all
        DeleteLocalInt(oPC, "ManeuverGranted" + IntToString(i));
    }
}

void BeginCrusaderGranting(object oPC)
{
    if(DEBUG) DoDebug("BeginCrusaderGranting(): Entered Function");
    // Stops it from being called more than once.
    if(GetLocalInt(oPC, "CrusaderGrantLoop")) return;
    SetLocalInt(oPC, "CrusaderGrantLoop", TRUE);

    // Starts the granting process
    if(DEBUG) DoDebug("BeginCrusaderGranting(): DoCrusaderGranting called");
    DoCrusaderGranting(oPC, 1);
}

void DoCrusaderGranting(object oPC, int nTrip)
{
    if(DEBUG) DoDebug("DoCrusaderGranting(): Entered Function on Round #" + IntToString(nTrip));
    // First round of combat, no granting.
    // Last round of the 5, clear and recover/grant maneuvers
    if (nTrip >= 5) // Granted maneuvers empty, restart
    {
        if(DEBUG) DoDebug("DoCrusaderGranting(): RecoverExpendedManeuvers");
        RecoverExpendedManeuvers(oPC, MANEUVER_LIST_CRUSADER);
        nTrip = 1;
    }
    else if (nTrip > 1)
    {
        // Rounds 2-4, grant a single maneuver
        if(DEBUG) DoDebug("DoCrusaderGranting(): GrantWithheldManeuver");
        //GrantWithheldManeuver(oPC, MANEUVER_LIST_CRUSADER);
        GrantRandomManeuver(oPC);
        ListGrantedManeuvers(oPC);
    }

    if(DEBUG) DoDebug("DoCrusaderGranting(): Above Recursive");
    // If in combat, keep the loop going
    if (GetIsInCombat(oPC))
    {
        if(DEBUG) DoDebug("DoCrusaderGranting(): In Combat");
        DelayCommand(6.0, DoCrusaderGranting(oPC, ++nTrip)); // Increment counter
    }
    else // Recover and stop loop otherwise.
    {
        if(DEBUG) DoDebug("DoCrusaderGranting(): Out of Combat Maneuver Recovery");
        RecoverExpendedManeuvers(oPC, MANEUVER_LIST_CRUSADER);
        // Resent Int for next time out
        DeleteLocalInt(oPC, "CrusaderGrantLoop");
    }
    if(DEBUG) DoDebug("DoCrusaderGranting(): Ending");
}

int ExpendRandomManeuver(object oPC, int nList, int nDiscipline = -1)
{
    // Counting through the local ints to determine if maneuver can be expended
    int i, nMax = GetReadiedCount(oPC, nList);
    for(i = 1; i <= nMax; i++)
    {
        // If the value is valid, next step
        int nMoveId = GetLocalInt(oPC, "ManeuverReadied" + IntToString(nList) + IntToString(i));
        if(nMoveId > 0)
        {
            // Make sure the disciplines match
            if(nDiscipline == -1 || GetDisciplineByManeuver(nMoveId) == nDiscipline)
            {
                // If not expended
                if(!GetIsManeuverExpended(oPC, nList, nMoveId))
                {
                    // Expend the damn thing and go home
                    ExpendManeuver(oPC, nList, nMoveId);
                    return TRUE;
                }
            }
        }
    }

    // If we're here, failed.
    return FALSE;
}

void RecoverPrCAbilities(object oPC)
{
    int i;
    for(i = 2; i <= 8; i++) // PrC abilities: check last seven slots
    {
        int nClass = GetClassByPosition(i, oPC);
        if(DEBUG) DoDebug("RecoverPrCAbilities" + IntToString(nClass));
        switch(nClass)
        {
            case CLASS_TYPE_INVALID:
                if(DEBUG) DoDebug("RecoverPrCAbilities: no class to recover");
                break;
            case CLASS_TYPE_JADE_PHOENIX_MAGE:
                DeleteLocalInt(oPC, "JPM_Empowering_Strike_Expended");
                DeleteLocalInt(oPC, "JPM_Quickening_Strike_Expended");
                break;
            case CLASS_TYPE_DEEPSTONE_SENTINEL:
                DeleteLocalInt(oPC, "DPST_Awaken_Stone_Dragon_Expended");
                break;
            case CLASS_TYPE_ETERNAL_BLADE:
                DeleteLocalInt(oPC, "ETBL_Eternal_Training_Expended");
                DeleteLocalInt(oPC, "ETBL_Island_In_Time_Expended");
                // Remove bonus to racial type from eternal training
                PRCRemoveEffectsFromSpell(oPC, ETBL_RACIAL_TYPE);
                break;
        }
    }
}

void VitalRecovery(object oPC)
{
    if (GetLocalInt(oPC, "VitalRecovery")) return; //Once a minute
    int nHD = GetHitDice(oPC);
    effect eHeal = EffectHeal(nHD+3); // That's it
    effect eVis = EffectVisualEffect(VFX_IMP_HEALING_M);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
    
    SetLocalInt(oPC, "VitalRecovery", TRUE);
    DelayCommand(60.0, DeleteLocalInt(oPC, "VitalRecovery"));
}