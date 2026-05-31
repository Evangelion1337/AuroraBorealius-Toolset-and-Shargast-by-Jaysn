//::///////////////////////////////////////////////
//:: Target list management functions include
//:: inc_target_list
//::///////////////////////////////////////////////
/** @file
    This is a set of functions intended to be used in
    spellscripts for getting a set of targets according
    to CR.

    The list is built on the objects making up the list,
    so it should be extracted from this system if it is
    to be used for longer than the duration of a single
    spellscript.
    This is because the system cleans up after itself
    and the object references from which the list is
    built up of are deleted when current script execution
    ends.

    Also, do not manipulate the list structure with means
    other than the functions provided here.

    Any particular list should be built using only a signle
    bias and ordering direction.


    Behavior in circumstances other than the recommended
    is non-deterministic. In other words, you've been warned :D


    One can utilise the insertion bias constants to change
    the ordering of the creatures in the list.
    All orders are descending by default.


    @author Ornedan
    @date   Created  - 18.01.2005
    @date   Modified - 26.06.2005
    @date   Modified - 21.01.2006
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/* Public constants                             */
//////////////////////////////////////////////////

/// Inserts based on Challenge Rating
const int INSERTION_BIAS_CR       = 1;

/// Inserts based on Hit Dice
const int INSERTION_BIAS_HD       = 2;

/// Inserts based on the ratio of CurrentHP / MaxHP
const int INSERTION_BIAS_HP_RATIO = 3;

/// Inserts based on distance from the object list is being built on
const int INSERTION_BIAS_DISTANCE = 4;

/// Inserts based on the current amount of HP
const int INSERTION_BIAS_HP       = 5;

//////////////////////////////////////////////////
/* Public functions                             */
//////////////////////////////////////////////////

/**
 * Adds the given object to a list. If no list exists when this is called,
 * it is created.
 * If either oInsert or oCaster is not valid, nothing happens.
 *
 * @param oInsert          The object to insert into the list
 * @param oCaster          The object that holds the head of the list.
 *                         This should be whatever object is casting the
 *                         spell that uses the list.
 * @param nInsertionBias   The insertion bias to use, one of the
 *                         INSERTION_BIAS_* constants
 * @param bDescendingOrder Whether to sort the targets into ascending or
 *                         descending order.
 */
void AddToTargetList(object oInsert, object oCaster, int nInsertionBias = INSERTION_BIAS_CR, int bDescendingOrder = TRUE);


/**
 * Gets the head a target list.
 * Returns the head of the list built on oCaster and removes it
 * from the list. If there are no more entries in the list,
 * return OBJECT_INVALID.
 *
 * @param oCaster An object a target list has been built on.
 * @return        The current head of the target list, which
 *                is then removed from the list. Or
 *                OBJECT_INVALID when no more objects remain
 *                in the list.
 */
object GetTargetListHead(object oCaster);



//////////////////////////////////////////////////
/* Private constants                            */
//////////////////////////////////////////////////

const string TARGET_LIST_HEAD         = "TargetListHead";
const string TARGET_LIST_NEXT         = "TargetListNext_";
const string TARGET_LIST_PURGE_CALLED = "TargetListPurgeCalled";


//////////////////////////////////////////////////
/* Private functions                            */
//////////////////////////////////////////////////

int GetIsInsertPosition(object oInsert, object oCompare, object oCaster, int nInsertionBias, int bDescendingOrder);

void PurgeTargetList(object oCaster);

//////////////////////////////////////////////////
/* function definitions                         */
//////////////////////////////////////////////////

void AddToTargetList(object oInsert, object oCaster, int nInsertionBias = INSERTION_BIAS_CR, int bDescendingOrder = TRUE)
{
    if(!GetIsObjectValid(oInsert) ||
       !GetIsObjectValid(oCaster))
    {
        WriteTimestampedLogEntry("AddToTargetList called with an invalid parameter");
        return;
    }

    object oCurrent = GetLocalObject(oCaster, TARGET_LIST_HEAD);

    // If the queue is empty, or the insertable just happens to belong at the head
    if(GetIsInsertPosition(oInsert, oCurrent, oCaster, nInsertionBias, bDescendingOrder))
    {
        SetLocalObject(oCaster, TARGET_LIST_HEAD, oInsert);
        SetLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oInsert), oCurrent);
    }// end if - insertable is the new head of the list
    else
    {
        object oNext = GetLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oCurrent));
        int bDone = FALSE;
        while(!bDone)
        {
            if(GetIsInsertPosition(oInsert, oNext, oCaster, nInsertionBias, bDescendingOrder))
            {
                SetLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oCurrent), oInsert);
                // Some paranoia to make sure the last element of the list always points
                // to invalid
                if(GetIsObjectValid(oNext)){
                    SetLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oInsert), oNext);
                }
                else
                    DeleteLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oInsert));

                bDone = TRUE;
            }// end if - this is the place to insert
            else
            {
                oCurrent = oNext;
                oNext = GetLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oCurrent));
            }// end else - get next object in the list
        }// end while - loop through the list, looking for the position to insert this creature
    }// end else - the insertable creature is to be in a position other than the head

    // Schedule clearing the list away once the current script has finished if it hasn't been done already
    if(!GetLocalInt(oCaster, TARGET_LIST_PURGE_CALLED))
    {
        DelayCommand(0.0f, PurgeTargetList(oCaster));
        SetLocalInt(oCaster, TARGET_LIST_PURGE_CALLED, TRUE);
    }
}



object GetTargetListHead(object oCaster)
{
    object oReturn = GetLocalObject(oCaster, TARGET_LIST_HEAD);
    SetLocalObject(oCaster, TARGET_LIST_HEAD, GetLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oReturn)));
    DeleteLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oReturn));

    return oReturn;
}


/* Removes the list of target objects held by oCaster
 * This should be called once the list is no longer used by the script that needed it
 * Failure to do so may cause problems
 */
void PurgeTargetList(object oCaster)
{
    object oCurrent = GetLocalObject(oCaster, TARGET_LIST_HEAD);
    DeleteLocalObject(oCaster, TARGET_LIST_HEAD);
    object oNext;
    while(GetIsObjectValid(oCurrent))
    {
        oNext = GetLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oCurrent));
        DeleteLocalObject(oCaster, TARGET_LIST_NEXT + ObjectToString(oCurrent));
        oCurrent = oNext;
    }// end while - loop through the list erasing the links

    DeleteLocalInt(oCaster, TARGET_LIST_PURGE_CALLED);
}


// This is an internal function intended only for use in inc_target_list.nss
int GetIsInsertPosition(object oInsert, object oCompare, object oCaster, int nInsertionBias, int bDescendingOrder)
{
    // Special case - A valid object is always inserted before an invalid one
    if(!GetIsObjectValid(oCompare))
        return TRUE;

    int bReturn;

    switch(nInsertionBias)
    {
        case INSERTION_BIAS_CR:
            bReturn  = GetChallengeRating(oInsert) > GetChallengeRating(oCompare);
            break;
        case INSERTION_BIAS_HD:
            bReturn  = GetHitDice(oInsert) > GetHitDice(oCompare);
            break;
        case INSERTION_BIAS_HP_RATIO:// A bit of trickery to avoid possible division by zero, which would happen if a non-creature got passed for insertion
            bReturn  = (IntToFloat(GetCurrentHitPoints(oInsert)) / ((GetMaxHitPoints(oInsert) > 0) ? IntToFloat(GetMaxHitPoints(oInsert)) : 0.001f))
                        >
                       (IntToFloat(GetCurrentHitPoints(oCompare)) / ((GetMaxHitPoints(oCompare) > 0) ? IntToFloat(GetMaxHitPoints(oCompare)) : 0.001f));
            break;
        case INSERTION_BIAS_DISTANCE:
            bReturn = GetDistanceBetween(oInsert, oCaster) > GetDistanceBetween(oCompare, oCaster);
            break;
        case INSERTION_BIAS_HP:
            bReturn = GetCurrentHitPoints(oInsert) > GetCurrentHitPoints(oCompare);
            break;
        default:
            WriteTimestampedLogEntry("Invalid target selection bias given. Value: " + IntToString(nInsertionBias));
            return TRUE;
    }

    return bDescendingOrder ? bReturn : !bReturn;
}