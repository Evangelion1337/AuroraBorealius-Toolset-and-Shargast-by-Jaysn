//::///////////////////////////////////////////////
//:: NPC event wrapper include
//:: inc_prc_npc
//:://////////////////////////////////////////////
/** @file
    Wrapper functions for getters used in module
    events. Used to make the PRC evaluations
    happening in events to work for NPCs, too.

    Event currently supported:
    OnEquip
    OnUnequip
    OnDeath
    OnRest

*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * A heartbeat function for NPCs. Checks if their equipped items have changed.
 * Simulates OnEquip / OnUnEquip firing
 * Since this should be fired from an NPCs hearbeat, OBJECT_SELF is assumed to
 * be the NPC.
 */
void DoEquipTest();


/* On(Un)Equip wrappers */

/**
 * Wrapper for GetPCItemLastEquipped
 */
object GetItemLastEquipped();

/**
 * Wrapper for GetPCItemLastEquippedBy
 */
object GetItemLastEquippedBy();

/**
 * Wrapper for GetItemLastUnequipped
 */
object GetItemLastUnequipped();

/**
 * Wrapper for GetPCItemLastUnequippedBy
 */
object GetItemLastUnequippedBy();


/* OnDeath wrappers */

/**
 * Wrapper for GetLastHostileActor and GetLastKiller
 */
object MyGetLastKiller();

/**
 * Wrapper for GetLastPlayerDied
 */
object GetLastBeingDied();


/* OnRest wrapper */

/**
 * Wrapper for GetLastPCRested
 */
object GetLastBeingRested();

/**
 * Wrapper for GetLastRestEventType
 */
int MyGetLastRestEventType();

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

object GetItemLastEquippedBy()
{
    if(GetModule() == OBJECT_SELF || GetIsPC(OBJECT_SELF)) // prc_inc_function runs the class scripts on the PC instead of the module
        return GetPCItemLastEquippedBy();
    else
        return OBJECT_SELF;
}

object GetItemLastUnequippedBy()
{
    if(GetModule() == OBJECT_SELF || GetIsPC(OBJECT_SELF))
        return GetPCItemLastUnequippedBy();
    else
        return OBJECT_SELF;
}

object GetItemLastEquipped()
{
    if(GetModule() == OBJECT_SELF || GetIsPC(OBJECT_SELF))
        return GetPCItemLastEquipped();
    else
        return GetLocalObject(OBJECT_SELF, "oLastEquipped");
}

object GetItemLastUnequipped()
{
    if(GetModule() == OBJECT_SELF || GetIsPC(OBJECT_SELF))
        return GetPCItemLastUnequipped();
    else
        return GetLocalObject(OBJECT_SELF, "oLastUnequipped");
}

void DoEquipTest()
{
    int i;
    object oTest;
    object oItem;
    for(i=1; i<NUM_INVENTORY_SLOTS;i++)
    {
        oItem = GetItemInSlot(i, OBJECT_SELF);
        oTest = GetLocalObject(OBJECT_SELF, "oSlotItem"+IntToString(i));
        if(oTest != oItem)
        {
            if(GetIsObjectValid(oItem))
            {
                SetLocalObject(OBJECT_SELF, "oLastEquipped", oItem);
                ExecuteScript("prc_equip", OBJECT_SELF);
            }
            if(GetIsObjectValid(oTest))
            {
                SetLocalObject(OBJECT_SELF, "oLastUnequipped", oTest);
                ExecuteScript("prc_unequip", OBJECT_SELF);
            }
            SetLocalObject(OBJECT_SELF, "oSlotItem"+IntToString(i), oItem);
            // to avoid lag, only run this on 1 item per HB
            // so we abort this now and prc_npc_hb will run it again in 6 seconds
            return;
        }
    }
}


object MyGetLastKiller(){
    if(GetModule() == OBJECT_SELF || GetIsPC(OBJECT_SELF))
        return GetLastHostileActor();
    else
        return GetLastKiller();
}

object GetLastBeingDied(){
    if(GetModule() == OBJECT_SELF || GetIsPC(OBJECT_SELF))
        return GetLastPlayerDied();
    else
        return OBJECT_SELF;
}


object GetLastBeingRested(){
    if(GetModule() == OBJECT_SELF || GetIsPC(OBJECT_SELF))
    {
        // Account for the PRCForceRest() wrapper
        if(GetLocalInt(OBJECT_SELF, "PRC_ForceRested"))
            return OBJECT_SELF;
        else
            return GetLastPCRested();
    }
    else
        return OBJECT_SELF;
}

int MyGetLastRestEventType(){
    if(GetModule() == OBJECT_SELF || GetIsPC(OBJECT_SELF))
        return GetLastRestEventType();
    else
        return GetLocalInt(OBJECT_SELF, "prc_rest_eventtype");
}