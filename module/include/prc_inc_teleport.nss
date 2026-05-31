//::///////////////////////////////////////////////
//:: Teleport include
//:: prc_inc_teleport
//::///////////////////////////////////////////////
/** @file
    This include contains operations to maintain
    an array of metalocations used as teleport target
    locations on a PC. In addition, there is a function
    for starting a conversation for the PC to select a
    location from their array.

    All the operations work only on PCs, as there is no
    AI that could have NPCs take any advantage of the
    system.
*/
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 29.05.2005
//:://////////////////////////////////////////////

#include "prc_inc_combat"
#include "inc_dynconv"

///////////////////////
/* Public Constants  */
///////////////////////

/**
 * The name of the array where GetTeleportingObjects() stores the creatures it has
 * determined should teleport with the current spell.
 */
const string PRC_TELEPORTING_OBJECTS_ARRAY    = "PRC_TeleportingObjectList";

/**
 * The number of the teleport quickselection slots. Also the index number of the highest slot,
 * as they are numbered starting from 1.
 */
const int PRC_NUM_TELEPORT_QUICKSELECTS      = 2;

/**
 * A constant for the value of slot parameter used when accessing the active quickselection.
 */
const int PRC_TELEPORT_ACTIVE_QUICKSELECTION = -1;


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Starts the conversation for selecting the target location for a teleport.
 * Once the PC has made his/her/it's selection, the result is stored on the
 * PC and the callbackscript is run.
 *
 * @param oPC             The PC that will make the selection.
 * @param sCallbackScript The name of the script to run once the PC has made
 *                        their decision.
 * @param sCallbackVar    The name of the local variable where the PC's choice
 *                        will be stored.
 * @param bMeta           If this is TRUE, the result will be stored as a
 *                        metalocation. Otherwise it will be stored as a location.
 * @param bForce          If this is TRUE, an attempt will be made to make sure
 *                        the PC will make the choice. ClearAllActions will be
 *                        called to prevent other activity from interfering with
 *                        the conversation strating and the PC will not be allowed
 *                        to abort the conversation.
 */
void ChooseTeleportTargetLocation(object oPC, string sCallbackScript, string sCallbackVar,
                                  int bMeta = FALSE, int bForce = FALSE);

/**
 * Returns the first teleport target location in the array and initialises
 * the iteration counter for calls to GetNextStoredTeleportTargetLocation().
 *
 * @param oPC The PC on whose array to operate.
 * @return    The first element of the array or the location of oPC if the
 *            array is empty.
 */
struct metalocation GetFirstStoredTeleportTargetLocation(object oPC);

/**
 * Returns the element at the current value of the iteration counter and
 * increments the counter.
 *
 * @param oPC The PC on whose array to operate.
 * @return    The next element in the array or null metalocation if the
 *            iteration has reached the end of the array or if the iteration
 *            counter hasn't been initialised.
 *
 * @see GetFirstStoredTeleportTargetLocation
 */
struct metalocation GetNextStoredTeleportTargetLocation(object oPC);

/**
 * Returns the teleport target location stored at the given index in the array.
 * This function does not interfere with the iteration counter used by
 * GetFirstStoredTeleportTargetLocation and GetNextStoredTeleportTargetLocation.
 *
 * @param oPC  The PC on whose array to operate.
 * @param nInd The array index from which to retrieve the location.
 * @return     The teleport target location stored at the given index, or null
 *             metalocation if the index was out of array bounds.
 */
struct metalocation GetNthStoredTeleportTargetLocation(object oPC, int nInd);

/**
 * Returns the number of elements in the teleport target locations array on the
 * PC.
 *
 * @param oPC The PC on whose array to operate.
 * @return    The number of locations stored in the array.
 */
int GetNumberOfStoredTeleportTargetLocations(object oPC);

/**
 * Checks whether the PC has a teleport quickselection active and if so,
 * whether it contains a valid metalocation.
 *
 * @param oPC   The PC whose quickselection to check.
 * @param nSlot The quickselection slot to check. Valid values are PRC_TELEPORT_ACTIVE_QUICKSELECTION,
 *              which checks the active quickselection and numbers from 1 to PRC_NUM_TELEPORT_QUICKSELECTS.
 *
 * @return      TRUE if the PC has a quickselection active and it is
 *              a valid metalocation, FALSE otherwise.
 */
int GetHasTeleportQuickSelection(object oPC, int nSlot = PRC_TELEPORT_ACTIVE_QUICKSELECTION);

/**
 * Gets the given creature's active teleport quickselection, if any.
 *
 * @param oPC    The PC whose quickselection to check.
 * @param bClear Whether to clear the quickselection after getting it.
 * @return       The PC's active quickselection, or null metalocation
 *               if there is none.
 */
struct metalocation GetActiveTeleportQuickSelection(object oPC, int bClear = FALSE);

/**
 * Gets the contents of one of the given creature's quickselect slots. Or the
 * active quickselection if the slot parameter is -1.
 *
 * @param oPC   The PC whose quickselection to get.
 * @param nSlot The slot to get from. Valid values are PRC_TELEPORT_ACTIVE_QUICKSELECTION,
 *              which returns the active quickselection and numbers from 1 to PRC_NUM_TELEPORT_QUICKSELECTS.
 *
 * @return      The quickselection in the given slot, or null metalocation if the
 *              slot was empty. Also returns null metalocation on error.
 */
struct metalocation GetTeleportQuickSelection(object oPC, int nSlot = PRC_TELEPORT_ACTIVE_QUICKSELECTION);

/**
 * Sets one of the PC's teleport quickselections to the given value.
 * Has no effect on error.
 *
 * @param oPC   The PC whose quickselection to set.
 * @param mlocL The metalocation to be stored.
 *
 * @param nSlot The slot to store the metalocation in. Valid values are PRC_TELEPORT_ACTIVE_QUICKSELECTION,
 *              which sets the active quickselection and numbers from 1 to PRC_NUM_TELEPORT_QUICKSELECTS.
 */
void SetTeleportQuickSelection(object oPC, struct metalocation mlocL, int nSlot = PRC_TELEPORT_ACTIVE_QUICKSELECTION);

/**
 * Deletes the contents of a teleport quickselection slot on the given creature.
 *
 * @param oPC   The PC whose quickselection to delete.
 * @param nSlot The quickselection slot to clear.
 */
void RemoveTeleportQuickSelection(object oPC, int nSlot = PRC_TELEPORT_ACTIVE_QUICKSELECTION);

/**
 * Removes the teleport target location last returned by GetFirstStoredTeleportTargetLocation
 * or GetNextStoredTeleportTargetLocation from the PCs array.
 * Resets the iteration counter to prevent possible errors.
 *
 * @param oPC The PC on whose array to operate.
 */
void RemoveCurrentTeleportTargetLocation(object oPC);

/**
 * Removes the teleport target location at the given index in the PCs array. The
 * elements after the removed index will be moved down so there will not be empty
 * elements in the middle of the array.
 * Resets the iteration counter to prevent possible errors.
 *
 * @param oPC  The PC on whose array to operate.
 * @param nInd The index from which to delete.
 */
void RemoveNthTeleportTargetLocation(object oPC, int nInd);

/**
 * Adds a location to the end of the teleport target array of the given PC.
 * Implemented by constructing a metalocation out of locToAdd and sName and
 * calling AddTeleportTargetLocationAsMeta.
 *
 * @param oPC      The PC to whose teleport target location array the
 *                 location is to be added.
 * @param locToAdd The location to store.
 * @param sName    The name of the teleport target location.
 *
 * @return          TRUE if the addition was successfull, FALSE otherwise.
 */
int AddTeleportTargetLocation(object oPC, location locToAdd, string sName);

/**
 * Adds a metalocation to the end of the teleport target array of the given PC.
 *
 * @param oPC       The PC to whose teleport target location array the
 *                  metalocation is to be added.
 * @param mlocToAdd The metalocation to store.
 *
 * @return          TRUE if the addition was successfull, FALSE otherwise.
 */
int AddTeleportTargetLocationAsMeta(object oPC, struct metalocation mlocToAdd);

/**
 * Creates a map pin for each of the given PC's teleport target locations that do not
 * have a map pin created for them yet. Is not totally reliable.
 * Known problems:
 * Cannot detect if a map pin created for a location has been deleted.
 *
 * @param oPC The PC for whom to create the map pins.
 */
void TeleportLocationsToMapPins(object oPC);

/**
 * This function checks whether the given creature can teleport from
 * it's current location. It is intended to be run within teleport
 * spellscripts.
 *
 * @param oCreature A creature casting a teleportation spell.
 * @param lTarget   The location the creature is going to teleport to.
 * @param bInform   If this is true, the creature is sent a message if
 *                  it is not allowed to teleport.
 * @param bPublic   Used as the bBroadcastToFaction parameter of
 *                  FloatingTextStringOnCreature() when informing oCreature
 *                  of error.
 * @return          TRUE if the creature can teleport, FALSE if it can't.
 */
int GetCanTeleport(object oCreature, location lTarget, int bMovesCreature = FALSE, int bInform = FALSE, int bPublic = FALSE);

/**
 * Common code for teleportation spells that:
 * 1) Always teleport the caster.
 * 2) Can be used to teleport other willing targets within touch range.
 * 2b) The amount of these additional targets is limited to
 *     1 / 3 caster|manifester levels.
 *
 * The results will be stored in a local array on the caster,
 * retrievable using functions from prc_inc_array.
 * The name of the array is contained within the constant PRC_TELEPORTING_OBJECTS_ARRAY.
 *
 * @param oCaster      The object casting the teleportation spell
 * @param nCasterLvl   The caster level of oCaster when casting the spell in question.
 * @param bSelfOrParty If this is TRUE, willing creatures (party members)
 *                     within 10ft of oCaster are taken along. If FALSE,
 *                     only the caster is teleported.
 */
void GetTeleportingObjects(object oCaster, int nCasterLvl, int bSelfOrParty);

/**
 * Determines whether the given teleportation target location can be used, or whether
 * the effect causing the teleportation errors, changing the target location.
 * Any inter-area teleportation effects should use this check even if they normally
 * always work correctly.
 *
 * @param lOriginal         The original destination of the teleport.
 * @param oUser             The user of the teleportation causing effect.
 * @param bNormallyErroless Whether the effect causing the teleprotation can normally
 *                          error. May be overridden by variables set on the target area.
 * @param bRecursing        Whether the function was called again due to Mishap being
 *                          rolled or not. This should always be left FALSE.
 *
 * @return                  Either lOrignal, or another location based on the error roll.
 */
location GetTeleportError(location lOriginal, object oUser, int bNormallyErroless = FALSE, int bRecursing = FALSE);

/**
 * Increments a marker on the target that will cause it to be unable to be
 * teleported. ie. GetCanTeleport() will return FALSE for the target.
 * Uses of DisallowTeleport() stack, so for example, if the function has
 * been called twice for a particular target, that target needs to have
 * AllowTeleport called on it twice before it can teleport again (or once with
 * the bClearAll parameter TRUE)
 *
 * @param oTarget Target object to forbide the teleportation of.
 */
void DisallowTeleport(object oTarget);

/**
 * Reverse of DisallowTeleport(), a call to this function makes the target
 * eligible for teleportation again.
 * NOTE: multiple forbiddances stack, and by default uses of this function
 * only reduces the forbiddace.
 *
 * @param oTarget   Target to allow teleportation for again.
 * @param bClearAll If TRUE, fully clears the forbiddance marker, otherwise
 *                  just decrements the value by one.
 */
void AllowTeleport(object oTarget, int bClearAll = FALSE);

/**
 * Performs full attack on eligible target at the end of a teleport sequence
 *
 * @param oPC    The caller
 */
void ShadowPounce(object oPC);

//////////////////////////////////////////////////
/* Internal Constants - nothing to see here :D  */
//////////////////////////////////////////////////

/// Internal constant - Name of the array where the teleport target locations are stored.
const string PRC_TELEPORT_ARRAY_NAME           = "PRC_TeleportLocation_Array";
/// Internal constant - Name of personal switch telling whether to create map pins for a particular PC's stored locations.
const string PRC_TELEPORT_CREATE_MAP_PINS      = "PRC_Teleport_CreateMapPins";
/// Internal constant - Name of personal switch telling how long the listener will wait for the player to speak a name when a new location is stored.
const string PRC_TELEPORT_NAMING_TIMER_VARNAME = "PRC_Teleport_NamingListenerDuration";
/// Internal constant - Name of personal swithc telling whether to automatically store the latest location the character rested at
const string PRC_TELEPORT_ONREST_MARKLOCATION  = "PRC_Teleport_OnRest_MarkLocation";


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

void ChooseTeleportTargetLocation(object oPC, string sCallbackScript, string sCallbackVar,
                                  int bMeta = FALSE, int bForce = TRUE)
{
/*    // The system is only useful to PCs. If it is at some point implemented for NPCs, change this.
    if(!GetIsPC(oPC)) return;*/

    // Make sure the PC has the feats for marking locations
    ExecuteScript("prc_tp_mgmt_eval", oPC);

    int nSpellID = GetSpellId();

    // Handle Word of Recall spell
    if(nSpellID == SPELL_WORD_OF_RECALL_SELF
    || nSpellID == SPELL_WORD_OF_RECALL_PARTY)
    {
        struct metalocation mlocL = GetLocalMetalocation(oPC, "PRC_WordOfRecall");

        if(GetIsMetalocationInModule(mlocL))
        {
            // Store the return value under the requested name and as the requested type
            if(bMeta)
                SetLocalMetalocation(oPC, sCallbackVar, mlocL);
            else
                SetLocalLocation(oPC, sCallbackVar, MetalocationToLocation(mlocL));

            // Break the script execution association between this one and the callback script
            // by delaying it. Probably unnecessary, but it will clear potential interference
            // caused by things done in this execution
            DelayCommand(0.2f, ExecuteScript(sCallbackScript, oPC));
        }
        else
        {
            FloatingTextStrRefOnCreature(16789977, oPC, FALSE);
        }
    }
    // Handle possible quickselection
    else if(GetHasTeleportQuickSelection(oPC, PRC_TELEPORT_ACTIVE_QUICKSELECTION))
    {
        // Get the quickselected metalocation and clear it
        struct metalocation mlocL = GetActiveTeleportQuickSelection(oPC, TRUE);
        int bTransViaPlants = GetLocalInt(oPC, "PRC_TransportViaPlants");
        DeleteLocalInt(oPC, "PRC_TransportViaPlants");
        object oArea = GetAreaFromMetalocation(mlocL);

        if((bTransViaPlants && GetIsAreaNatural(oArea) && !GetIsAreaInterior(oArea))
        || !bTransViaPlants)
        {
            // Store the return value under the requested name and as the requested type
            if(bMeta)
                SetLocalMetalocation(oPC, sCallbackVar, mlocL);
            else
                SetLocalLocation(oPC, sCallbackVar, MetalocationToLocation(mlocL));

            // Break the script execution association between this one and the callback script
            // by delaying it. Probably unnecessary, but it will clear potential interference
            // caused by things done in this execution
            DelayCommand(0.2f, ExecuteScript(sCallbackScript, oPC));
        }
        else
        {
            SendMessageToPCByStrRef(oPC, 16789931);
        }
    }
    // We have to go look at the stored array, so make sure it contains at least one entry
    else if(!GetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME))
    {// "You do not have any locations marked for teleporting to!"
        SendMessageToPCByStrRef(oPC, 16825305);

        // Store the PC's location
        if(bMeta)
            SetLocalMetalocation(oPC, sCallbackVar, LocationToMetalocation(GetLocation(oPC)));
        else
            SetLocalLocation(oPC, sCallbackVar, GetLocation(oPC));

        // Break the script execution association between this one and the callback script
        // by delaying it. Probably unnecessary, but it will clear potential interference
        // caused by things done in this execution
        DelayCommand(0.2f, ExecuteScript(sCallbackScript, oPC));
    }
    // No quickselection was active and there is at least one location to select, so run the
    // conversation to find out where the user wants to go
    else
    {
        SetLocalString(oPC, "PRC_TeleportTargetSelection_CallbackScript", sCallbackScript);
        SetLocalString(oPC, "PRC_TeleportTargetSelection_ReturnStoreName", sCallbackVar);
        SetLocalInt(oPC, "PRC_TeleportTargetSelection_ReturnAsMetalocation", bMeta);

        StartDynamicConversation("prc_teleprt_conv", oPC,
                                 bForce ? DYNCONV_EXIT_NOT_ALLOWED : DYNCONV_EXIT_ALLOWED_SHOW_CHOICE,
                                 !bForce, bForce, oPC);
    }
}

struct metalocation GetFirstStoredTeleportTargetLocation(object oPC)
{
    // Return null if the array is empty
    if(!GetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME))
        return LocationToMetalocation(GetLocation(oPC), "Error: No stored locations! Returned current location of " + GetName(oPC));

    // Set the iterator value for subsequent calls to GetNextStoredTeleportTargetLocation()
    SetLocalInt(oPC, "PRC_Teleport_Array_Iterator", 1);
    // Clean away the iterator on script execution end
    DelayCommand(0.0f, DeleteLocalInt(oPC, "PRC_Teleport_Array_Iterator"));

    return GetPersistantLocalMetalocation(oPC, PRC_TELEPORT_ARRAY_NAME + "_0");
}

struct metalocation GetNextStoredTeleportTargetLocation(object oPC)
{
    // Return null if GetFirstStoredTeleportTargetLocation() hasn't been called previously
    int nInd = GetLocalInt(oPC, "PRC_Teleport_Array_Iterator");
    if(!nInd) return GetNullMetalocation();

    // If the iteration has reached the end of the array, delete the iteration counter and return null
    if(nInd > GetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME) - 1)
    {
        DeleteLocalInt(oPC, "PRC_Teleport_Array_Iterator");
        return GetNullMetalocation();
    }

    // Increment iterator and return the value
    SetLocalInt(oPC, "PRC_Teleport_Array_Iterator", nInd + 1);
    return GetPersistantLocalMetalocation(oPC, PRC_TELEPORT_ARRAY_NAME + "_" + IntToString(nInd));
}

struct metalocation GetNthStoredTeleportTargetLocation(object oPC, int nInd)
{
    // If out of lower or upper bound, return null
    if(nInd < 0 || nInd > GetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME) - 1)
        return GetNullMetalocation();

    // Return the nth stored location
    return GetPersistantLocalMetalocation(oPC, PRC_TELEPORT_ARRAY_NAME + "_" + IntToString(nInd));
}

int GetNumberOfStoredTeleportTargetLocations(object oPC)
{
    return GetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME);
}

int GetHasTeleportQuickSelection(object oPC, int nSlot = PRC_TELEPORT_ACTIVE_QUICKSELECTION)
{
    //SendMessageToPC(oPC, "GetLocalInt(oPC, PRC_Teleport_Quickselection): " + IntToString(GetLocalInt(oPC, "PRC_Teleport_Quickselection")));
    //SendMessageToPC(oPC, "GetIsMetalocationValid(GetLocalMetalocation(oPC, PRC_Teleport_Quickselection)): " + IntToString(GetIsMetalocationValid(GetLocalMetalocation(oPC, "PRC_Teleport_Quickselection"))));
    if(nSlot < -1 || !nSlot || nSlot > PRC_NUM_TELEPORT_QUICKSELECTS)
        return FALSE;

    if(nSlot == PRC_TELEPORT_ACTIVE_QUICKSELECTION)
        return GetLocalInt(oPC, "PRC_Teleport_Quickselection");/* &&
            GetIsMetalocationValid(GetLocalMetalocation(oPC, "PRC_Teleport_Quickselection"));*/
    else
        return GetLocalInt(oPC, "PRC_Teleport_QuickSelection_" + IntToString(nSlot));
}

struct metalocation GetActiveTeleportQuickSelection(object oPC, int bClear = FALSE)
{
    if(GetHasTeleportQuickSelection(oPC, PRC_TELEPORT_ACTIVE_QUICKSELECTION))
    {
        struct metalocation mlocL = GetLocalMetalocation(oPC, "PRC_Teleport_Quickselection");
        if(bClear)
            RemoveTeleportQuickSelection(oPC, PRC_TELEPORT_ACTIVE_QUICKSELECTION);
        return mlocL;
    }
    else
        return GetNullMetalocation();
}

struct metalocation GetTeleportQuickSelection(object oPC, int nSlot = PRC_TELEPORT_ACTIVE_QUICKSELECTION)
{
    // Make sure the slot is within allowed range
    if(nSlot < -1 || !nSlot || nSlot > PRC_NUM_TELEPORT_QUICKSELECTS)
        return GetNullMetalocation();

    // The active quickselection was asked
    if(nSlot == PRC_TELEPORT_ACTIVE_QUICKSELECTION)
        return GetActiveTeleportQuickSelection(oPC, FALSE);
    // The contents of a slot were asked, an the slot in question is not empty
    else if(GetLocalInt(oPC, "PRC_Teleport_QuickSelection_" + IntToString(nSlot)))
        return GetLocalMetalocation(oPC, "PRC_Teleport_QuickSelection_" + IntToString(nSlot));
    // The slot is empty
    else
        return GetNullMetalocation();
}

void SetTeleportQuickSelection(object oPC, struct metalocation mlocL, int nSlot = PRC_TELEPORT_ACTIVE_QUICKSELECTION)
{
    // Make sure the slot is within allowed range
    if(nSlot < -1 || !nSlot || nSlot > PRC_NUM_TELEPORT_QUICKSELECTS)
        return;

    // Set either the active selection, or a slot depending on nSlot
    if(nSlot == PRC_TELEPORT_ACTIVE_QUICKSELECTION)
    {
        SetLocalInt(oPC, "PRC_Teleport_Quickselection", TRUE); // Mark quickselection as active
        SetLocalMetalocation(oPC, "PRC_Teleport_Quickselection", mlocL);
    }
    else
    {
        SetLocalInt(oPC, "PRC_Teleport_QuickSelection_" + IntToString(nSlot), TRUE); // Mark quickselection as existing
        SetLocalMetalocation(oPC, "PRC_Teleport_QuickSelection_" + IntToString(nSlot), mlocL);
    }
}

void RemoveTeleportQuickSelection(object oPC, int nSlot = PRC_TELEPORT_ACTIVE_QUICKSELECTION)
{
    DeleteLocalInt(oPC, "PRC_Teleport_Quickselection");
    DeleteLocalMetalocation(oPC, "PRC_Teleport_Quickselection");
}

void RemoveCurrentTeleportTargetLocation(object oPC)
{
    // Return if GetFirstStoredTeleportTargetLocation() or GetNextStoredTeleportTargetLocation() hasn't been called previously.
    int nInd = GetLocalInt(oPC, "PRC_Teleport_Array_Iterator");
    if(!nInd) return;

    // Remove the location
    RemoveNthTeleportTargetLocation(oPC, nInd);

    // Delete the iteration counter to keep potential errors down.
    DeleteLocalInt(oPC, "PRC_Teleport_Array_Iterator");
}

void RemoveNthTeleportTargetLocation(object oPC, int nInd)
{
    // If out of lower or upper bound, return
    if(nInd < 0 || nInd > GetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME) - 1)
        return;

    // Get the index of the last element in the array and move elements back if needed
    int nMax = GetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME) - 1;
    for(; nInd < nMax; nInd++)
    {
        SetPersistantLocalMetalocation(oPC, PRC_TELEPORT_ARRAY_NAME + "_" + IntToString(nInd),
                                       GetPersistantLocalMetalocation(oPC, PRC_TELEPORT_ARRAY_NAME + "_" + IntToString(nInd + 1))
                                       );
        // Move the map pin existence marker if it's present
        if(GetLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME + "_HasMapPin_" + IntToString(nInd + 1)))
            SetLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME + "_HasMapPin_" + IntToString(nInd), TRUE);
    }

    // Remove the last element and mark the size change
    DeletePersistantLocalMetalocation(oPC, PRC_TELEPORT_ARRAY_NAME + "_" + IntToString(nMax));
    DeleteLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME + "_HasMapPin_" + IntToString(nMax));
    SetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME, nMax);

    // Delete the iteration counter to keep potential errors down.
    DeleteLocalInt(oPC, "PRC_Teleport_Array_Iterator");
}

int AddTeleportTargetLocation(object oPC, location locToAdd, string sName)
{
    return AddTeleportTargetLocationAsMeta(oPC, LocationToMetalocation(locToAdd, sName));
}

int AddTeleportTargetLocationAsMeta(object oPC, struct metalocation mlocToAdd)
{
    // Make sure the metalocation is valid
    if(!GetIsMetalocationValid(mlocToAdd))
    {// "Location could not be marked due to technical limitations - unable to uniquely identify area."
        SendMessageToPCByStrRef(oPC, 16825304);
        return FALSE;
    }

    // Array size check. If no limit is defined via switch, default to 50.
    int nInd = GetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME); // Array elements begin at index 0
    int nMax = GetPRCSwitch(PRC_TELEPORT_MAX_TARGET_LOCATIONS) ?
                GetPRCSwitch(PRC_TELEPORT_MAX_TARGET_LOCATIONS) :
                50;
    if(nInd >= nMax)
    {// You have reached the maximum allowed teleport locations (              ).\nYou must remove at least one stored location before you can add new locations.
        SendMessageToPC(oPC, GetStringByStrRef(16825294) + IntToString(nMax) + GetStringByStrRef(16825295));
        return FALSE;
    }

    // All checks passed, store the location, increment array size and return
    SetPersistantLocalMetalocation(oPC, PRC_TELEPORT_ARRAY_NAME + "_" + IntToString(nInd), mlocToAdd);
    SetPersistantLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME, nInd + 1);
    return TRUE;
}

void TeleportLocationsToMapPins(object oPC)
{
    // This function is only useful for PCs
    if(!GetIsPC(oPC)) return;

    // Iterate over all stored metalocations
    int nMax = GetNumberOfStoredTeleportTargetLocations(oPC);
    int i;
    for(; i < nMax; i++)
    {
        // Add map pins to those locations that do not already have one
        if(!GetLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME + "_HasMapPin_" + IntToString(i)))
        {
            CreateMapPinFromMetalocation(GetNthStoredTeleportTargetLocation(oPC, i) , oPC);
            SetLocalInt(oPC, PRC_TELEPORT_ARRAY_NAME + "_HasMapPin_" + IntToString(i), TRUE);
        }
    }
}


int GetCanTeleport(object oCreature, location lTarget, int bMovesCreature = FALSE, int bInform = FALSE, int bPublic = FALSE)
{
    int bReturn = TRUE;
    // First, check global switch to turn off teleporting
    if(GetPRCSwitch(PRC_DISABLE_TELEPORTATION))
        bReturn = FALSE;

    // If the creature would be actually moved around, do some extra tests
    if(bMovesCreature)
    {
        // Check area-specific variables
        object oSourceArea = GetArea(oCreature);
        object oTargetArea = GetAreaFromLocation(lTarget);
        // Teleportation is between areas
        if(oSourceArea != oTargetArea)
        {
            // Check forbiddance variable on the current area
            if(GetLocalInt(oSourceArea, PRC_DISABLE_TELEPORTATION_IN_AREA) & PRC_DISABLE_TELEPORTATION_FROM_AREA)
                bReturn = FALSE;
            // Check forbiddance variable on the target area
            if(GetLocalInt(oTargetArea, PRC_DISABLE_TELEPORTATION_IN_AREA) & PRC_DISABLE_TELEPORTATION_TO_AREA)
                bReturn = FALSE;
        }
        // Teleportation within an area
        else if(GetLocalInt(oSourceArea, PRC_DISABLE_TELEPORTATION_IN_AREA) & PRC_DISABLE_TELEPORTATION_WITHIN_AREA)
            bReturn = FALSE;
    }


    // Check forbiddance variable on the creature
    if(GetLocalInt(oCreature, PRC_DISABLE_CREATURE_TELEPORT))
        bReturn = FALSE;

    // Tell the creature about failure, if necessary
    if(bInform & !bReturn)
    {
        // "Something prevents your extra-dimensional movement!"
        FloatingTextStrRefOnCreature(16825298, oCreature, bPublic);
    }

    return bReturn;
}

void GetTeleportingObjects(object oCaster, int nCasterLvl, int bSelfOrParty)
{
    // Store list of objects to teleport in an array on the caster
    // First, null the array
    array_delete(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY);
    array_create(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY);

    // Init array index variable
    int i = 0;

    // Casting Dimension Door always teleports at least the caster
    array_set_object(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY, i++, oCaster);

    // If teleporting party, get all faction members fitting in within 10 feet. (Should be dependent on caster's reach,
    // but that would mean < Small creatures could not teleport their party at all and even Mediums with their 5 foot
    // reach might have trouble considering the position tracking code's shakiness)
    if(bSelfOrParty)
    {
        // Carry amount variables
        int nMaxCarry = nCasterLvl / 3,
            nCarry    = 0,
            nIncrease;
            
        nMaxCarry += GetLevelByClass(CLASS_TYPE_WAYFARER_GUIDE, oCaster);

        location lSelf = GetLocation(oCaster);
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(10.0f), lSelf);
        while(GetIsObjectValid(oTarget))
        {
            // Check if the target is member of the same faction as the caster. If it is, teleport it along.
            if(GetFactionEqual(oCaster, oTarget) && oTarget != oCaster)
            {
                // Calculate how many carry slots the creature would take
                nIncrease = GetCreatureSize(oTarget) == CREATURE_SIZE_HUGE ? 4 :
                             GetCreatureSize(oTarget) == CREATURE_SIZE_LARGE ? 2 :
                             1;

                // Add others if the caster can carry them
                if(nCarry + nIncrease <= nMaxCarry)
                {
                    nCarry += nIncrease;
                    array_set_object(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY, i++, oTarget);
                }
                // Otherwise inform the caster that they couldn't take the creature along
                else // "You do not have anough carrying capacity to teleport X"
                    SendMessageToPC(oCaster, GetStringByStrRef(16825302) + " " + GetName(oTarget));
            }

            oTarget = GetNextObjectInShape(SHAPE_SPHERE, FeetToMeters(10.0f), lSelf);
        }
    }
    /*
    // Targeting one other being in addition to self. If it's hostile, it gets SR and a Will save.
    else if(nSpellID = SPELLID_TELEPORT_TARGET)
    {
        object oTarget = PRCGetSpellTargetObject();
        if(GetIsHostile())
        {
            PRCSignalSpellEvent(oTarget, TRUE, nSpellID); // Let the target know it was cast a spell at

            //SR
            if(!PRCDoResistSpell(oCaster, oTarget, nCasterLevel + SPGetPenetr()))
            {
                // Will save
                if(!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, PRCGetSaveDC(oTarget, oCaster), SAVING_THROW_TYPE_SPELL))
                {
                    array_set_object(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY, i++, oTarget);
        }   }   }
        // Not hostile, just add it to the list.
        else
        {
            PRCSignalSpellEvent(oTarget, FALSE, nSpellID); // Let the target know it was cast a spell at
            array_set_object(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY, i++, oTarget);
        }
    }
    */
}

location GetTeleportError(location lOriginal, object oUser, int bNormallyErroless = FALSE, int bRecursing = FALSE)
{
    if(DEBUG) DoDebug("prc_inc_teleport: GetTeleportError():\n"
                    + "lOriginal = " + DebugLocation2Str(lOriginal) + "\n"
                    + "oUser = " + DebugObject2Str(oUser) + "\n"
                    + "bNormallyErroless = " + DebugBool2String(bNormallyErroless) + "\n"
                    + "bRecursing = " + DebugBool2String(bRecursing) + "\n"
                      );

    int nOverrideValue = GetLocalInt(GetAreaFromLocation(lOriginal), PRC_FORCE_TELEPORTATION_RESULT);

    // If the effect cannot normally error and there is no override active, just return lOriginal
    if(bNormallyErroless && !nOverrideValue)
        return lOriginal;

    // Roll for the result. If recursing from a mishap, roll d20 + 80, otherwise roll d100
    int nRoll = bRecursing ? d20() + 80 : d100();
    
    if (GetLevelByClass(CLASS_TYPE_WAYFARER_GUIDE, oUser) >= 3)
    {
        // Roll twice, take the better roll
        int nRoll2 = bRecursing ? d20() + 80 : d100();
        if (nRoll > nRoll2) nRoll = nRoll2;
    }
    
    // If an override value is specified, force the roll value. Override only applies in the first call, not on subsequent times
    if(nOverrideValue && !bRecursing)
    {
        switch(nOverrideValue)
        {
            case PRC_FORCE_TELEPORTATION_RESULT_ONTARGET:     nRoll = 1;  break;
            case PRC_FORCE_TELEPORTATION_RESULT_OFFTARGET:    nRoll = 91; break;
            case PRC_FORCE_TELEPORTATION_RESULT_WAYOFFTARGET: nRoll = 95; break;
            case PRC_FORCE_TELEPORTATION_RESULT_MISHAP:       nRoll = 99; break;
        }
    }
    
    if (GetLocalInt(GetAreaFromLocation(lOriginal), "BlackLabyrinthTeleport")) nRoll = 91;
    
    int nLabyrinth = GetLocalInt(oUser, "BlackLabyrinthTeleport");
    if(!PRCMySavingThrow(SAVING_THROW_WILL, oUser, nLabyrinth, SAVING_THROW_TYPE_SPELL) && nLabyrinth) nRoll = 99;
    else if (nLabyrinth) nRoll = 91;
    
    if(DEBUG) DoDebug("prc_inc_teleport: GetTeleportError(): Roll is " + IntToString(nRoll) + ", forced = " + DebugBool2String(nOverrideValue));

    /* On Target Off Target Way Off Target Mishap
     * 01–90     91–94      95–98          99–100
     */
    // On Target - Return original location
    if(nRoll <= 90)
    {
        if(DEBUG) DoDebug("prc_inc_teleport: GetTeleportError(): On Target - Returning original location");
        return lOriginal;
    }
    // Off Target - Get a random location in same area
    else if(nRoll <= 94)
    {
        object oArea = GetAreaFromLocation(lOriginal);
        int nAreaW = GetAreaWidth(oArea);
        int nAreaH = GetAreaHeight(oArea);

        vector vNew = Vector(Random(nAreaW) * 10.0f + 5.0f,
                             Random(nAreaH) * 10.0f + 5.0f,
                             GetPositionFromLocation(lOriginal).z
                             );
        location lNew = Location(oArea, vNew, 0.0f);
        if(DEBUG) DoDebug("prc_inc_teleport: GetTeleportError(): Off Target - Returning " + DebugLocation2Str(lNew));
        return lNew;
    }
    // Way Off Target - Random location among stored teleport choices, or if there are no others, just stay where the user is
    else if(nRoll <= 98)
    {
        int nLocs = GetNumberOfStoredTeleportTargetLocations(oUser);
        int nRand = Random(nLocs);
        location lReplacement = MetalocationToLocation(GetNthStoredTeleportTargetLocation(oUser, nRand));

        if(DEBUG) DoDebug("prc_inc_teleport: GetTeleportError(): Way Off Target - Replacement location rolled: " + DebugLocation2Str(lReplacement) + "\n"
                        + "Replacement location is useable: " + DebugBool2String(!(nLocs == 0 || lReplacement == lOriginal))
                          );

        if(nLocs == 0 || lReplacement == lOriginal)
            return GetLocation(oUser);
        else
            return lReplacement;
    }
    // Mishap:
    // You and anyone else teleporting with you have gotten “scrambled.”
    // You each take 1d10 points of damage, and you reroll on the chart to see where you wind up.
    // For these rerolls, roll 1d20+80. Each time “Mishap” comes up, the characters take more damage and must reroll.
    else
    {
        if(DEBUG) DoDebug("prc_inc_teleport: GetTeleportError(): Mishap - damaging people");
        object oTarget;
        int i;
        for(i = 0; i < array_get_size(oUser, PRC_TELEPORTING_OBJECTS_ARRAY); i++)
        {
            oTarget = array_get_object(oUser, PRC_TELEPORTING_OBJECTS_ARRAY, i);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d10(), DAMAGE_TYPE_MAGICAL), oTarget);
        }

        return GetTeleportError(lOriginal, oUser, bNormallyErroless, TRUE);
    }
}

void DisallowTeleport(object oTarget)
{
    if(DEBUG) DoDebug("DisallowTeleport():\n"
                    + "oTarget = " + DebugObject2Str(oTarget) + "\n"
                    + "\n"
                    + "New blocking variable value: " + IntToString(GetLocalInt(oTarget, PRC_DISABLE_CREATURE_TELEPORT) + 1) + "\n"
                      );
    SetLocalInt(oTarget, PRC_DISABLE_CREATURE_TELEPORT,
                GetLocalInt(oTarget, PRC_DISABLE_CREATURE_TELEPORT) + 1
                );
}

void AllowTeleport(object oTarget, int bClearAll = FALSE)
{
    if(DEBUG) DoDebug("AllowTeleport():\n"
                    + "oTarget = " + DebugObject2Str(oTarget) + "\n"
                    + "bClearAll = " + DebugBool2String(bClearAll) + "\n"
                    + "\n"
                    + "Old blocking variable value: " + IntToString(GetLocalInt(oTarget, PRC_DISABLE_CREATURE_TELEPORT))
                      );
    int nValue = GetLocalInt(oTarget, PRC_DISABLE_CREATURE_TELEPORT) - 1;
    if((nValue > 0) && !bClearAll)
        SetLocalInt(oTarget, PRC_DISABLE_CREATURE_TELEPORT, nValue);
    else
        DeleteLocalInt(oTarget, PRC_DISABLE_CREATURE_TELEPORT);

    if(DEBUG) DoDebug("New blocking variable value: " + (((nValue > 0) && !bClearAll) ? IntToString(nValue) : "Deleted"));
}

void ShadowPounce(object oPC)
{
	if (GetHasFeat(FEAT_SHADOW_POUNCE, oPC))
	{
        location lTarget = GetLocation(oPC);
        // Use the function to get the closest creature as a target
        object oAreaTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oAreaTarget))
        {
            if(oAreaTarget != oPC && // Not you
               GetIsInMeleeRange(oPC, oAreaTarget) && // They must be in melee range
               GetIsEnemy(oAreaTarget, oPC)) // Only enemies
            {
                PerformAttackRound(oAreaTarget, oPC, EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY), 0.0, 0, 0, 0, TRUE, "Shadow Pounce Hit", "Shadow Pounce Miss", FALSE, FALSE, TRUE);
                break; //End loop
            }
        //Select the next target within the spell shape.
        oAreaTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        }		
	}
}