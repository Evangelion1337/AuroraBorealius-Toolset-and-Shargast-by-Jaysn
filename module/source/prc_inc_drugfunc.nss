//:://////////////////////////////////////////////
//:: Drug system functions
//:: prc_inc_drugfunc
//:://////////////////////////////////////////////
/** @file
    A bunch of functions common to the drug
    scripts.

    @author Ornedan
    @data   Created 2006.05.29
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Increments the overdose tracking counter by one for the given drug and queues
 * decrementing it by one after the given period.
 * The value of this counter is what will be returned by GetHasOverdosed().
 *
 */
void IncrementOverdoseTracker(object oDrugUser, string sODIdentifier, float fODPeriod);

/**
 * Checks if the given drug user is currently in the overdose period of the given drug.
 * The value returned is the number of drug uses in the overdose period of which is
 * currently active.
 *
 * @param oDrugUser     A creature using a drug.
 * @param sODIdentifier The name of the drug's overdose identifier.
 * @return              The current value of the overdose variable - how many drug uses of
 *                      the given drug are right now in their overdose period.
 */
int GetOverdoseCounter(object oDrugUser, string sODIdentifier);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////


//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * Implements the decrementing of the overdose counters.
 *
 * @param oDrugUser     A creature using a drug.
 * @param sODIdentifier The name of the drug's overdose identifier.
 */
void _prc_inc_drugfunc_DecrementOverdoseTracker(object oDrugUser, string sODIdentifier)
{
    // Delete the variable if decrementing would it would make it 0
    if(GetLocalInt(oDrugUser, sODIdentifier) <= 1)
        DeleteLocalInt(oDrugUser, sODIdentifier);
    else
        SetLocalInt(oDrugUser, sODIdentifier, GetLocalInt(oDrugUser, sODIdentifier) - 1);
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void IncrementOverdoseTracker(object oDrugUser, string sODIdentifier, float fODPeriod)
{
    SetLocalInt(oDrugUser, sODIdentifier, GetLocalInt(oDrugUser, sODIdentifier) + 1);
    DelayCommand(fODPeriod, _prc_inc_drugfunc_DecrementOverdoseTracker(oDrugUser, sODIdentifier));
}


int GetOverdoseCounter(object oDrugUser, string sODIdentifier)
{
    return GetLocalInt(oDrugUser, sODIdentifier);
}


// Test main
//void main(){}
