//::///////////////////////////////////////////////
//:: Persistant array simulation include
//:: inc_pers_array
//:://////////////////////////////////////////////
/** @file
    Persistant array simulation include

    This file defines a set of functions for creating
    and manipulating persistant arrays, which are
    implemented as persistant local variables on some
    holder creature.


    Notes:

    * Arrays are dynamic and may be increased in size by just _set_'ing a new
      element
    * There are no restrictions on what is in the array (can have multiple
      types in the same array)
    * Arrays start at index 0
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


/////////////////////////////////////
// Functions
/////////////////////////////////////

/**
 * Creates a new persistant array on the given storage creature.
 * If an array with the same name already exists, the function
 * errors.
 *
 * @param store The creature to use as holder for the array
 * @param name  The name of the array
 * @return      SDL_SUCCESS if the array was successfully created,
 *              one of SDL_ERROR_* on error.
 */
int persistant_array_create(object store, string name);

/**
 * Deletes a persistant array, erasing all it's entries.
 *
 * @param store The creature which holds the array to delete
 * @param name  The name of the array
 * @return      SDL_SUCCESS if the array was successfully deleted,
 *              one of SDL_ERROR_* on error
 */
int persistant_array_delete(object store, string name);

/**
 * Stores a string in a persistant array.
 *
 * @param store The creature holding the array
 * @param name  The name of the array
 * @param i     The index to store the string at
 * @param entry The string to store
 * @return      SDL_SUCCESS if the store was successfull, SDL_ERROR_* on error.
 */
int persistant_array_set_string(object store, string name, int i, string entry);

/**
 * Stores an integer in a persistant array.
 *
 * @param store The creature holding the array
 * @param name  The name of the array
 * @param i     The index to store the integer at
 * @param entry The integer to store
 * @return      SDL_SUCCESS if the store was successfull, SDL_ERROR_* on error.
 */
int persistant_array_set_int(object store, string name, int i, int entry);

/**
 * Stores a float in a persistant array.
 *
 * @param store The creature holding the array
 * @param name  The name of the array
 * @param i     The index to store the float at
 * @param entry The float to store
 * @return      SDL_SUCCESS if the store was successfull, SDL_ERROR_* on error.
 */
int persistant_array_set_float(object store, string name, int i, float entry);

/**
 * Stores an object in a persistant array.
 *
 * @param store The creature holding the array
 * @param name  The name of the array
 * @param i     The index to store the object at
 * @param entry The object to store
 * @return      SDL_SUCCESS if the store was successfull, SDL_ERROR_* on error.
 */
int persistant_array_set_object(object store, string name, int i, object entry);

/**
 * Gets a string from a persistant array.
 *
 * @param store The creature holding the array
 * @param name  The name of the array
 * @param i     The index to retrieve the string from
 * @return      The value contained at the index on success,
 *              "" on error
 */
string persistant_array_get_string(object store, string name, int i);

/**
 * Gets an integer from a persistant array.
 *
 * @param store The creature holding the array
 * @param name  The name of the array
 * @param i     The index to retrieve the integer from
 * @return      The value contained at the index on success,
 *              0 on error
 */
int persistant_array_get_int(object store, string name, int i);

/**
 * Gets a float from a persistant array.
 *
 * @param store The creature holding the array
 * @param name  The name of the array
 * @param i     The index to retrieve the float from
 * @return      The value contained at the index on success,
 *              0.0f on error
 */
float persistant_array_get_float(object store, string name, int i);

/**
 * Gets an object from a persistant array.
 *
 * @param store The creature holding the array
 * @param name  The name of the array
 * @param i     The index to retrieve the object from
 * @return      The value contained at the index on success,
 *              OBJECT_INVALID on error
 */
object persistant_array_get_object(object store, string name, int i);

/**
 * Removes all entries in the array with indexes greater than or equal to
 * the new size and sets the array size to be equal to the new size.
 *
 * @param store    The creature holding the array
 * @param name     The name of the array
 * @param size_new The new number of entries in the array
 * @return         SDL_SUCCESS on successful resize, SDL_ERROR_* on
 *                 error
 */
int persistant_array_shrink(object store, string name, int size_new);

/**
 * Gets the current size of the array. This is one greater
 * than the index of highest indexed element the array
 * has contained since the last array_shrink or the new size
 * specified by the last array_shrink, whichever is greater.
 *
 * @param store    The creature holding the array
 * @param name     The name of the array
 * @return         The size of the array, or -1 if the specified
 *                 array does not exist.
 */
int persistant_array_get_size(object store, string name);

/**
 * Checks whether the given persistant array exists.
 *
 * @param store    The creature holding the array
 * @param name     The name of the array
 * @return         TRUE if the array exists, FALSE otherwise.
 */
int persistant_array_exists(object store, string name);

/////////////////////////////////////
// Includes
/////////////////////////////////////

#include "inc_persist_loca"
#include "prc_inc_array" // yes this is also got via inc_persist_loca if rather indirectly

/////////////////////////////////////
// Implementation
/////////////////////////////////////

int persistant_array_create(object store, string name)
{
    // error checking
    if(!GetIsObjectValid(store))
        return SDL_ERROR_NOT_VALID_OBJECT;
    else if(persistant_array_exists(store,name))
        return SDL_ERROR_ALREADY_EXISTS;
    else
    {
        // Initialize the size (always one greater than the actual size)
        SetPersistantLocalInt(store,name,1);
        return SDL_SUCCESS;
    }
}

void persistant_array_delete_loop(object store, string name, int nMin, int nMax)
{
    int i = nMin;
    while(i < nMin + 250 && i < nMax)
    {
        DeletePersistantLocalString(store,name+"_"+IntToString(i));

        // just in case, delete possible object names
        DeletePersistantLocalObject(store,name+"_"+IntToString(i)+"_OBJECT");
        i++;
    }
    // delay continuation to avoid TMI
    if(i < nMax)
        DelayCommand(0.0, persistant_array_delete_loop(store, name, i, nMax));
}

int persistant_array_delete(object store, string name)
{
    // error checking
    int size=GetPersistantLocalInt(store,name);
    if (size==0)
        return SDL_ERROR_DOES_NOT_EXIST;

    persistant_array_delete_loop(store, name, 0, size+5);

    DeletePersistantLocalInt(store,name);

    return SDL_SUCCESS;
}

int persistant_array_set_string(object store, string name, int i, string entry)
{
    int size=GetPersistantLocalInt(store,name);
    if(size == 0)
        return SDL_ERROR_DOES_NOT_EXIST;
    if(i < 0)
        return SDL_ERROR_OUT_OF_BOUNDS;

    SetPersistantLocalString(store,name+"_"+IntToString(i),entry);

    // save size if we've enlarged it
    if (i+2>size)
        SetPersistantLocalInt(store,name,i+2);

    return SDL_SUCCESS;
}

int persistant_array_set_int(object store, string name, int i, int entry)
{
    return persistant_array_set_string(store,name,i,IntToString(entry));
}

int persistant_array_set_float(object store, string name, int i, float entry)
{
    return persistant_array_set_string(store,name,i,FloatToString(entry));
}

int persistant_array_set_object(object store, string name, int i, object entry)
{
    // object is a little more complicated.
    // we want to create an object as a local variable too
    if (!GetIsObjectValid(entry))
        return SDL_ERROR_NOT_VALID_OBJECT;

    int results = persistant_array_set_string(store,name,i,"OBJECT");
    if (results==SDL_SUCCESS)
        SetPersistantLocalObject(store,name+"_"+IntToString(i)+"_OBJECT",entry);

    return results;
}

string persistant_array_get_string(object store, string name, int i)
{
    // error checking
    int size=GetPersistantLocalInt(store,name);
    if (size==0 || i>size || i < 0)
        return "";

    return GetPersistantLocalString(store,name+"_"+IntToString(i));
}

int persistant_array_get_int(object store, string name, int i)
{
    return StringToInt(persistant_array_get_string(store,name,i));
}

float persistant_array_get_float(object store, string name, int i)
{
    return StringToFloat(persistant_array_get_string(store,name,i));
}

object persistant_array_get_object(object store, string name, int i)
{
    if(persistant_array_get_string(store, name, i) == "OBJECT")
        return GetPersistantLocalObject(store,name+"_"+IntToString(i)+"_OBJECT");
    else
        return OBJECT_INVALID;
}

int persistant_array_shrink(object store, string name, int size_new)
{
    // Get the current size value
    int size = GetPersistantLocalInt(store, name);
    // Error check - non-existent array
    if(size == 0)
        return SDL_ERROR_DOES_NOT_EXIST;
    // If the new number of elements is equal to or greater than the current number of elements, autosuccess
    if((size - 1) <= size_new)
        return SDL_SUCCESS;

    // Delete entries that are outside the new array bounds
    int i;
    for(i = size_new; i < size; i++)
    {
        DeletePersistantLocalString(store, name+"_"+IntToString(i));

        // just in case, delete possible object names
        DeletePersistantLocalObject(store, name+"_"+IntToString(i)+"_OBJECT");
    }

    // Store the new size, with the +1 existence marker
    SetPersistantLocalInt(store, name, size_new + 1);

    return SDL_SUCCESS;
}

int persistant_array_get_size(object store, string name)
{
    return GetPersistantLocalInt(store,name)-1;
}

int persistant_array_exists(object store, string name)
{
    if (GetPersistantLocalInt(store,name))
        return TRUE;
    else
        return FALSE;
}

// Test main
//void main(){}
