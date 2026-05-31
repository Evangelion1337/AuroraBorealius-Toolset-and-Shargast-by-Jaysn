//::///////////////////////////////////////////////
//:: Persistant local variables include
//:: inc_persist_loca
//:://////////////////////////////////////////////
/** @file
    A set of functions for storing local variables
    on a token item stored in the creature's skin.
    Since local variables on items within containers
    are not stripped during serialization, these
    variables persist across module changes and
    server resets.

    These functions work on NPCs in addition to PCs,
    but the persitence is mostly useless for them,
    since NPCs are usually not serialized in a way
    that would remove normal locals from them, if
    they are serialized at all.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Adapted by ebonfowl to fix the Beamdog local variable bug
//:: Functions all still intuitively work the same way
//:: Only difference is the variables all run through SQL rather than via the hide token
//:: Dedicated to Edgar, the real Ebonfowl
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Gets the token item inside the given creature's hide, on which the persistant
 * variables are stored on.
 * If a token does not exist already, one is created.
 * WARNING: If called on a non-creature object, returns the object itself.
 *
 * @param oPC The creature whose storage token to get
 * @param bAMS - TRUE will return special token for alternate magic system buckup info
 * @return    The creature's storage token
 *
 * GetNSBToken - special token for New Spellbook System information
 */
//object GetHideToken(object oPC, int bAMS = FALSE);

/**
 * Set a local string variable on the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @param sValue The value to set the string local to
 */
void SetPersistantLocalString(object oPC, string sName, string sValue);

/**
 * Set a local integer variable on the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @param nValue The value to set the integer local to
 */
void SetPersistantLocalInt(object oPC, string sName, int nValue);

/**
 * Set a local float variable on the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @param nValue The value to set the float local to
 */
void SetPersistantLocalFloat(object oPC, string sName, float fValue);

/**
 * Set a local location variable on the creature's storage token.
 *
 * CAUTION! See note in SetPersistantLocalObject(). Location also contains an
 * object reference, though it will only break across changes to the module,
 * not across server resets.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @param nValue The value to set the location local to
 */
void SetPersistantLocalLocation(object oPC, string sName, location lValue);

/**
 * Set a local object variable on the creature's storage token.
 *
 * CAUTION! Object references are likely (and in some cases, certain) to break
 * when transferring across modules or upon server reset. This means that
 * persistantly stored local objects may not refer to the same object after such
 * a change, if they refer to a valid object at all.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @param nValue The value to set the object local to
 */
void SetPersistantLocalObject(object oPC, string sName, object oValue);

/**
 * Get a local string variable from the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @return       The string local specified. On error, returns ""
 */
string GetPersistantLocalString(object oPC, string sName);

/**
 * Get a local integer variable from the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @return       The integer local specified. On error, returns 0
 */
int GetPersistantLocalInt(object oPC, string sName);

/**
 * Get a local float variable from the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @return       The float local specified. On error, returns 0.0
 */
float GetPersistantLocalFloat(object oPC, string sName);

/**
 * Get a local location variable from the creature's storage token.
 *
 * CAUTION! See note in SetPersistantLocalLocation()
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @return       The location local specified. Return value on error is unknown
 */
location GetPersistantLocalLocation(object oPC, string sName);

/**
 * Get a local object variable from the creature's storage token.
 *
 * CAUTION! See note in SetPersistantLocalObject()
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 * @return       The object local specified. On error, returns OBJECT_INVALID
 */
object GetPersistantLocalObject(object oPC, string sName);

/**
 * Delete a local string variable on the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 */
void DeletePersistantLocalString(object oPC, string sName);

/**
 * Delete a local integer variable on the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 */
void DeletePersistantLocalInt(object oPC, string sName);

/**
 * Delete a local float variable on the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 */
void DeletePersistantLocalFloat(object oPC, string sName);

/**
 * Delete a local location variable on the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 */
void DeletePersistantLocalLocation(object oPC, string sName);

/**
 * Delete a local object variable on the creature's storage token.
 *
 * @param oPC    The creature whose local variables to manipulate
 * @param sName  The name of the local variable to manipulate
 */
void DeletePersistantLocalObject(object oPC, string sName);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_skin"

// SQL include
#include "inc_persistsql"


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

object GetHideToken(object oPC, int bAMS = FALSE)
{
    string sCache = bAMS ? "PRC_AMSTokenCache" : "PRC_HideTokenCache";
    string sTag = bAMS ? "AMS_Token" : "HideToken";

    // Creatureness check - non-creatures don't get persistent storage from here
    if(!(GetObjectType(oPC) == OBJECT_TYPE_CREATURE))
        return oPC; // Just return a reference to the object itself

    object oHide = GetPCSkin(oPC);
    object oToken = GetLocalObject(oPC, sCache);

    if(!GetIsObjectValid(oToken))
    {
        object oTest = GetFirstItemInInventory(oHide);
        while(GetIsObjectValid(oTest))
        {
            if(GetTag(oTest) == sTag)
            {
                oToken = oTest;
                break;//exit while loop
            }
            oTest = GetNextItemInInventory(oHide);
        }
        if(!GetIsObjectValid(oToken))
        {
            oToken = GetItemPossessedBy(oPC, sTag);

            // Move the token to hide's inventory
            if(GetIsObjectValid(oToken))
                AssignCommand(oHide, ActionTakeItem(oToken, oPC)); // Does this work? - Ornedan
            else
            {
                //oToken = CreateItemOnObject("hidetoken", oPC);
                //AssignCommand(oHide, ActionTakeItem(oToken, oPC));
                oToken = CreateItemOnObject("hidetoken", oHide, 1, sTag);
            }
        }

        AssignCommand(oToken, SetIsDestroyable(FALSE));
        // Cache the token so that there needn't be multiple loops over an inventory
        SetLocalObject(oPC, sCache, oToken);
        //- If the cache reference is found to break under any conditions, uncomment this.
        //looks like logging off then back on without the server rebooting breaks it
        //I guess because the token gets a new ID, but the local still points to the old one
        //Ive changed it to delete the local in OnClientEnter. Primogenitor
        //DelayCommand(1.0f, DeleteLocalObject(oPC, "PRC_HideTokenCache"));
    }
    return oToken;
}

void SetPersistantLocalString(object oPC, string sName, string sValue)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_SetString(oPC, sName, sValue);
    }
    else
    {
        SetLocalString(oPC, sName, sValue);
    }
}

/* void SetPersistantLocalString(object oPC, string sName, string sValue)
{
    if(GetIsPC(oPC))
    {
        SQLocalsPlayer_SetString(oPC, sName, sValue);
    }
    else
    {
        SetLocalString(oPC, sName, sValue);
    }
} */

void SetPersistantLocalInt(object oPC, string sName, int nValue)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_SetInt(oPC, sName, nValue);
    }
    else
    {
        SetLocalInt(oPC, sName, nValue);
    }
}

void SetPersistantLocalFloat(object oPC, string sName, float fValue)
{
	if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_SetFloat(oPC, sName, fValue);
    }
    else
    {
        SetLocalFloat(oPC, sName, fValue);
    }
}

void SetPersistantLocalLocation(object oPC, string sName, location lValue)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_SetLocation(oPC, sName, lValue);
    }
    else
    {
        SetLocalLocation(oPC, sName, lValue);
    }
}

void SetPersistantLocalObject(object oPC, string sName, object oValue)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_SetObject(oPC, sName, oValue);
    }
    else
    {
        SetLocalObject(oPC, sName, oValue);
    }
}

string GetPersistantLocalString(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        return SQLocalsPlayer_GetString(oPC, sName);
    }
    return GetLocalString(oPC, sName);
}

int GetPersistantLocalInt(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        return SQLocalsPlayer_GetInt(oPC, sName);
    }
    return GetLocalInt(oPC, sName);
}

float GetPersistantLocalFloat(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        return SQLocalsPlayer_GetFloat(oPC, sName);
    }
    return GetLocalFloat(oPC, sName);
}

location GetPersistantLocalLocation(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        return SQLocalsPlayer_GetLocation(oPC, sName);
    }
    return GetLocalLocation(oPC, sName);
}

object GetPersistantLocalObject(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        // Additional check since the OID returned may be invalid, but not actually OBJECT_INVALID
        object oReturn = SQLocalsPlayer_GetObject(oPC, sName);
        if(GetIsObjectValid(oReturn)) return oReturn;
        return OBJECT_INVALID;
    }
    return GetLocalObject(oPC, sName);
}

void DeletePersistantLocalString(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_DeleteString(oPC, sName);
    }
    else
    {
        DeleteLocalString(oPC, sName);
    }
}

void DeletePersistantLocalInt(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_DeleteInt(oPC, sName);
    }
    else
    {
        DeleteLocalInt(oPC, sName);
    }
}

void DeletePersistantLocalFloat(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_DeleteFloat(oPC, sName);
    }
    else
    {
        DeleteLocalFloat(oPC, sName);
    }
}

void DeletePersistantLocalLocation(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_DeleteLocation(oPC, sName);
    }
    else
    {
        DeleteLocalLocation(oPC, sName);
    }
}

void DeletePersistantLocalObject(object oPC, string sName)
{
    if(GetIsPC(oPC) == TRUE && GetMaster(oPC) == OBJECT_INVALID && !GetIsDMPossessed(oPC))
    {
        SQLocalsPlayer_DeleteObject(oPC, sName);
    }
    else
    {
        DeleteLocalObject(oPC, sName);
    }
}

// Test main

// void main() {}