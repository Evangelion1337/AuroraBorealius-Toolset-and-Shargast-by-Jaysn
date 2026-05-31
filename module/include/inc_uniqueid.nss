//::///////////////////////////////////////////////
//:: Unique identifier generation include
//:: inc_uniqueid
//::///////////////////////////////////////////////
/** @file inc_uniqueid
    Contains functions for generating unique IDs
    within the scope of one module instance.

    An ID is a string of format:
     PRC_UID_X
    where X is the concatenation of the values of
    one or more running integer counters.

    The uniqueness is quaranteed by using a
    set of local integers stored on the module
    object as counters.
    At first, the set contains a single integer,
    initialised to 0. Each UID generation
    increments it's value by 1. Once the value
    reaches the maximum an NWN integer type may
    have (0xFFFFFFFF), a new integer is added
    to the set, again initialised to 0.


    NOTE: The generated strings are only unique
    withing a single module instance. Reloading
    a module (new game / server reset) will
    reset the counter due to the counter array
    being lost.
    As such, UIDs should not be stored persistently.

    @author Ornedan
    @date   Created - 2006.06.30
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const string PRC_UID_PREFIX = "PRC_UID_";
const string PRC_UID_ARRAY  = "PRC_UID_Counters";


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Generates an UID, as described in the header comments.
 *
 * @return A string unique within a single module instance.
 */
string GetUniqueID();


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

//#include "inc_utility"
#include "prc_inc_array"


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

string GetUniqueID()
{
    object oModule = GetModule();
    string sReturn = PRC_UID_PREFIX;
    // Init if this is the first call
    if(!array_exists(oModule, PRC_UID_ARRAY))
    {
        array_create(oModule, PRC_UID_ARRAY);
        array_set_int(oModule, PRC_UID_ARRAY, 0, 0);
    }

    // Loop over all the integers and concatenate them onto the UID being generated
    int i, nMax = array_get_size(oModule, PRC_UID_ARRAY);
    for(i=0; i < nMax; i++)
        sReturn += IntToString(array_get_int(oModule, PRC_UID_ARRAY, i));

    // Increment the counters
    if((i = array_get_int(oModule, PRC_UID_ARRAY, nMax - 1)) < 0xFFFFFFFF)
        // We're below maximum integer size, just increment the stored value
       array_set_int(oModule, PRC_UID_ARRAY, nMax - 1, i + 1);
    else
        // We need to add a new integer to the set
        array_set_int(oModule, PRC_UID_ARRAY, nMax, 0);

    // Return the generated value
    return sReturn;
}

// Test main
//void main(){}
