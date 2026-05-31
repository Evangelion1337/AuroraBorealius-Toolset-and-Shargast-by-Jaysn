//::///////////////////////////////////////////////
//:: Set-like storage data type include
//:: inc_set
//:://////////////////////////////////////////////
/** @file
    This file defines a "data type" that behaves
    like a set. It is implemented as an extension
    of the arrays defined in prc_inc_array.

    Operations:
     - Get number of entities in the set. O(1)
     - Store an entity in the set. O(1)
     - Remove an entity from the set. O(n)
     - Determine if the set contains a given entity. O(1)
     - Get operations on the underlying array

    The memory complexity is O(n), specifically 2n(m + c), where
    n is the number of entities stored in the set, m is the memory
    taken up the local variable store of a member entity and c is
    a constant overhead from disambiguation strings.

    Note that a set can contain only contain one instance
    of any specific entity. Any attempts to add an entity to
    a set that is already a member of will return with success,
    but do nothing.
    For example, if a set contains {"Foo", "Bar, 123, OBJECT_INVALID}
    calling set_add_string(container, setname, "Foo") will return
    SDL_SUCCESS, but not modify the contents of the set.


    @author Ornedan
    @date   Created - 2006.09.16
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Creates a new set on the given storage object. If a set with
 * the same name already exists, the function fails.
 *
 * @param store The object to use as holder for the set
 * @param name  The name of the set
 * @return      SDL_SUCCESS if the set was successfully created,
 *              one of SDL_ERROR_* on error.
 */
int set_create(object store, string name);

/**
 * Deletes a set, deleting all local variables it consists of.
 *
 * @param store The object which holds the set to delete
 * @param name  The name of the set
 * @return      SDL_SUCCESS if the set was successfully deleted,
 *              one of SDL_ERROR_* on error
 */
int set_delete(object store, string name);

/**
 * Adds a string to the set.
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param entry The string to add
 * @return      SDL_SUCCESS if the addition was successfull, SDL_ERROR_* on error.
 */
int set_add_string(object store, string name, string entry);

/**
 * Adds a integer to the set.
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param entry The integer to add
 * @return      SDL_SUCCESS if the addition was successfull, SDL_ERROR_* on error.
 */
int set_add_int(object store, string name, int entry);

/**
 * Adds a float to the set.
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param entry The float to add
 * @return      SDL_SUCCESS if the addition was successfull, SDL_ERROR_* on error.
 */
int set_add_float(object store, string name, float entry);

/**
 * Adds a object to the set.
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param entry The object to add
 * @return      SDL_SUCCESS if the addition was successfull, SDL_ERROR_* on error.
 */
int set_add_object(object store, string name, object entry);

/**
 * Determines whether the set contains the given string.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The string to test
 * @return       TRUE if the set contains entry, FALSE otherwise
 */
int set_contains_string(object store, string name, string entity);

/**
 * Determines whether the set contains the given integer.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The integer to test
 * @return       TRUE if the set contains entry, FALSE otherwise
 */
int set_contains_int(object store, string name, int entity);

/**
 * Determines whether the set contains the given float.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The float to test
 * @return       TRUE if the set contains entry, FALSE otherwise
 */
int set_contains_float(object store, string name, float entity);

/**
 * Determines whether the set contains the given object.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The object to test
 * @return       TRUE if the set contains entry, FALSE otherwise
 */
int set_contains_object(object store, string name, object entity);

/**
 * Removes the given string from the set, if it is a member.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The string to remove
 */
void set_remove_string(object store, string name, string entity);

/**
 * Removes the given integer from the set, if it is a member.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The integer to remove
 */
void set_remove_int(object store, string name, int entity);

/**
 * Removes the given float from the set, if it is a member.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The float to remove
 */
void set_remove_float(object store, string name, float entity);

/**
 * Removes the given object from the set, if it is a member.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The object to remove
 */
void set_remove_object(object store, string name, object entity);

/**
 * Gets the type of the i:th member of the set.
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param i     The index of the member the type of which to retrieve
 * @return      One of the ENTITY_TYPE_* defined in inc_heap, or 0 in case of error
 */
int set_get_member_type(object store, string name, int i);


/**
 * Gets the i:th member of the set as a string.
 *
 * NOTE: If the member is actually not a string, the return
 *       value in undefined. As such, always check the real
 *       type of the member first using set_get_member_type().
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param i     The index to retrieve the string from
 * @return      The value contained at the index on success,
 *              "" on error
 */
string set_get_string(object store, string name, int i);

/**
 * Gets the i:th member of the set as an integer.
 *
 * NOTE: If the member is actually not an integer, the return
 *       value in undefined. As such, always check the real
 *       type of the member first using set_get_member_type().
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param i     The index to retrieve the string from
 * @return      The value contained at the index on success,
 *              0 on error
 */
int set_get_int(object store, string name, int i);

/**
 * Gets the i:th member of the set as an float.
 *
 * NOTE: If the member is actually not an float, the return
 *       value in undefined. As such, always check the real
 *       type of the member first using set_get_member_type().
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param i     The index to retrieve the string from
 * @return      The value contained at the index on success,
 *              0.0 on error
 */
float set_get_float(object store, string name, int i);

/**
 * Gets the i:th member of the set as an object.
 *
 * NOTE: If the member is actually not an object, the return
 *       value in undefined. As such, always check the real
 *       type of the member first using set_get_member_type().
 *
 * @param store The object holding the set
 * @param name  The name of the set
 * @param i     The index to retrieve the string from
 * @return      The value contained at the index on success,
 *              OBJECT_INVALID on error
 */
object set_get_object(object store, string name, int i);

/**
 * Gets the number of members in the set
 *
 * @param store    The object holding the set
 * @param name     The name of the set
 * @return         The size of the set, or -1 if the specified
 *                 set does not exist.
 */
int set_get_size(object store, string name);

/**
 * Checks whether the given set exists.
 *
 * @param store    The object holding the set
 * @param name     The name of the set
 * @return         TRUE if the set exists, FALSE otherwise.
 */
int set_exists(object store, string name);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

// prc_inc_array access is via inc_heap
//#include "prc_inc_array"
#include "inc_debug"
#include "inc_heap"


//////////////////////////////////////////////////
/*             Internal Constants               */
//////////////////////////////////////////////////

const string _PRC_SET_PREFIX = "@@@set";


//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * Performs the real addition operation.
 *
 * @param store    The object holding the set
 * @param name     The name of the set
 * @param entry    String form of the entity to be stored in the set
 * @param isobject Whether the entity being stored is an object. Objects need special handling
 * @param obj      The object being stored, if any
 */
int _inc_set_set_add_aux(object store, string name, string entry, int isobject = FALSE, object obj = OBJECT_INVALID)
{
    // Sanity checks
    if(!set_exists(store, name))
        return SDL_ERROR_DOES_NOT_EXIST;

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    // Set the presence marker to be the index where the entity will be stored + 1 to avoid storing a 0
    int index = array_get_size(store, name);
    SetLocalInt(store, name + entry, index + 1);

    // Store the member's value in the array
    if(isobject)
    {
        if(DEBUG)
        {
            Assert(array_set_object(store, name, index, obj) == SDL_SUCCESS,
                   "array_set_object(store, name, index, obj) == SDL_SUCCESS",
                   "", "inc_set", "_inc_set_set_add_aux"
                   );
            return SDL_SUCCESS;
        }
        else
        {
            return array_set_object(store, name, index, obj);
        }
    }
    else
    {
        if(DEBUG)
        {
            Assert(array_set_string(store, name, index, entry) == SDL_SUCCESS,
                   "array_set_string(store, name, index, entry) == SDL_SUCCESS",
                   "", "inc_set", "_inc_set_set_add_aux"
                   );
            return SDL_SUCCESS;
        }
        else
        {
            return array_set_string(store, name, index, entry);
        }
    }
}

/** Internal function.
 * Determines whether the set contains the given entity.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The presence string for the entity to test
 * @return       TRUE if the set contains the entity, FALSE otherwise
 */
int _inc_set_set_contains_aux(object store, string name, string entity)
{
    // Sanity check
    if(!set_exists(store, name))
        return FALSE;

    // Get the value of the presence marker and normalise to TRUE / FALSE
    return GetLocalInt(store, _PRC_SET_PREFIX + name + entity) != 0;
}

/** Internal function.
 * Removes the given entity from the set.
 *
 * @param store  The object holding the set
 * @param name   The name of the set
 * @param entity The presence string for the entity to remove
 */
void _inc_set_set_remove_aux(object store, string name, string entity)
{
    // Set does not exist or exists, but does not contain the given entity. Nothing to do
    if(!_inc_set_set_contains_aux(store, name, entity))
        return;

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    // Get the index where the entity is stored and the size of the underlying array
    int index = GetLocalInt(store, name + entity) - 1;
    int size  = array_get_size(store, name);
    string raw;
    object obj;

    // Move each element in the array after the one being removed back by one
    for(index = index + 1; index < size; index++)
    {
        // Determine what's stored here
        raw = array_get_string(store, name, index);

        // Different handling for objects vs everything else
        if(raw == "OBJECT")
        {
            obj = array_get_object(store, name, index);
            // Move back
            array_set_object(store, name, index - 1, obj);

            // Update the marker value
            SetLocalInt(store, name + "O" + ObjectToString(obj), index/* - 1 + 1 */);
        }
        else
        {
            // Move back
            array_set_string(store, name, index - 1, raw);

            // Update the marker value
            SetLocalInt(store, name + raw, index/* - 1 + 1 */);
        }
    }

    // Delete the marker local
    DeleteLocalInt(store, name + entity);

    // Shrink the array
    array_shrink(store, name, size - 1);
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int set_create(object store, string name)
{
    // Sanity checks
    if(!GetIsObjectValid(store))
        return SDL_ERROR_NOT_VALID_OBJECT;
    if(name == "")
        return SDL_ERROR_INVALID_PARAMETER;
    if(set_exists(store, name))
        return SDL_ERROR_ALREADY_EXISTS;

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    // All OK, create the underlying array
    return array_create(store, name);
}

int set_delete(object store, string name)
{
    // Sanity check
    if(!set_exists(store, name))
        return SDL_ERROR_DOES_NOT_EXIST;

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    // Loop over all members, getting deleting the presence indicator local
    int size = array_get_size(store, name);
    int i;
    string raw, member;
    for(i = 0; i < size; i++)
    {
        // Get the raw data stored in the array.
        // NOTE: This relies on internal details of the array implementation. Specifically, objects having a string containing "OBJECT"
        // stored in their position
        raw = array_get_string(store, name, i);

        // Construct the presence marker name. Special handling for objects
        if(raw == "OBJECT")
            member = name + "O" + ObjectToString(array_get_object(store, name, i));
        else
            member = name + raw;

        // Delete the marker
        DeleteLocalInt(store, member);
    }

    // Clean up the underlying array
    if(DEBUG)
    {
        Assert(array_delete(store, name) == SDL_SUCCESS, "array_delete(store, name) == SDL_SUCCESS", "", "inc_set", "set_delete");
        return SDL_SUCCESS;
    }
    else
    {
        return array_delete(store, name);
    }
}

int set_add_string(object store, string name, string entry)
{
    // Convert the entry to the storable string form
    entry = "S" + entry;

    // If the set already contains the entry being added, nothing happens
    if(_inc_set_set_contains_aux(store, name, entry))
        return SDL_SUCCESS;

    return _inc_set_set_add_aux(store, name, entry);
}

int set_add_int(object store, string name, int entry)
{
    // Convert the entry to the storable string form
    string strentry = "I" + IntToString(entry);

    // If the set already contains the entry being added, nothing happens
    if(_inc_set_set_contains_aux(store, name, strentry))
        return SDL_SUCCESS;

    return _inc_set_set_add_aux(store, name, strentry);
}

int set_add_float(object store, string name, float entry)
{
    // Convert the entry to the storable string form
    string strentry = "F" + FloatToString(entry);

    // If the set already contains the entry being added, nothing happens
    if(_inc_set_set_contains_aux(store, name, strentry))
        return SDL_SUCCESS;

    return _inc_set_set_add_aux(store, name, strentry);
}

int set_add_object(object store, string name, object entry)
{
    // Convert the entry to the storable string form
    string strentry = "O" + ObjectToString(entry);

    // If the set already contains the entry being added, nothing happens
    if(_inc_set_set_contains_aux(store, name, strentry))
        return SDL_SUCCESS;

    return _inc_set_set_add_aux(store, name, strentry, TRUE, entry);
}

int set_get_member_type(object store, string name, int i)
{
    // Sanity check
    if(!set_exists(store, name) || i >= set_get_size(store, name))
        return 0;

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    // Grab the first character of the raw string, it determines type
    string type = GetSubString(array_get_string(store, name, i), 0, 1);

    // First character in the string determines type
    if     (type == "F")
        return ENTITY_TYPE_FLOAT;
    else if(type == "I")
        return ENTITY_TYPE_INTEGER;
    else if(type == "O")
        return ENTITY_TYPE_OBJECT;
    else if(type == "S")
        return ENTITY_TYPE_STRING;
    else
        return 0;
}

int set_contains_string(object store, string name, string entity)
{
    return _inc_set_set_contains_aux(store, name, "S" + entity);
}

int set_contains_int(object store, string name, int entity)
{
    return _inc_set_set_contains_aux(store, name, "I" + IntToString(entity));
}

int set_contains_float(object store, string name, float entity)
{
    return _inc_set_set_contains_aux(store, name, "F" + FloatToString(entity));
}

int set_contains_object(object store, string name, object entity)
{
    return _inc_set_set_contains_aux(store, name, "O" + ObjectToString(entity));
}

void set_remove_string(object store, string name, string entity)
{
    _inc_set_set_remove_aux(store, name, "S" + entity);
}

void set_remove_int(object store, string name, int entity)
{
    _inc_set_set_remove_aux(store, name, "I" + IntToString(entity));
}

void set_remove_float(object store, string name, float entity)
{
    _inc_set_set_remove_aux(store, name, "F" + FloatToString(entity));
}

void set_remove_object(object store, string name, object entity)
{
    _inc_set_set_remove_aux(store, name, "O" + ObjectToString(entity));
}

string set_get_string(object store, string name, int i)
{
    // Sanity check
    if(!set_exists(store, name) || i >= set_get_size(store, name))
        return "";

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    // Chop off the first character from the raw string and return the rest
    string raw = array_get_string(store, name, i);
    return GetSubString(raw, 1, GetStringLength(raw));
}

int set_get_int(object store, string name, int i)
{
    // Sanity check
    if(!set_exists(store, name) || i >= set_get_size(store, name))
        return 0;

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    // Chop off the first character from the raw string and return the rest
    string raw = array_get_string(store, name, i);
    return StringToInt(GetSubString(raw, 1, GetStringLength(raw)));
}

float set_get_float(object store, string name, int i)
{
    // Sanity check
    if(!set_exists(store, name) || i >= set_get_size(store, name))
        return 0.0f;

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    // Chop off the first character from the raw string and return the rest
    string raw = array_get_string(store, name, i);
    return StringToFloat(GetSubString(raw, 1, GetStringLength(raw)));
}

object set_get_object(object store, string name, int i)
{
    // Sanity check
    if(!set_exists(store, name) || i >= set_get_size(store, name))
        return OBJECT_INVALID;

    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    return array_get_object(store, name, i);
}

int set_get_size(object store, string name)
{
    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    return array_get_size(store, name);
}

int set_exists(object store, string name)
{
    // Generate real name for accessing array functions
    name = _PRC_SET_PREFIX + name;

    return array_exists(store, name);
}


// Test main
//void main() {}
