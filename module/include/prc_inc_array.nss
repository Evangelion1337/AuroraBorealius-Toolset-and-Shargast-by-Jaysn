//::///////////////////////////////////////////////
//:: Array simulation include
//:: prc_inc_array
//:://////////////////////////////////////////////
/** @file
    Array simulation include

    This file defines a set of functions for creating
    and manipulating arrays, which are implemented as
    local variables on some holder object.


    Notes:

    * Arrays are dynamic and may be increased in size by just _set_'ing a new
      element
    * There are no restrictions on what is in the array (can have multiple
      types in the same array)
    * Arrays start at index 0

    ////////////////////////////////////////////////////////////////////////////////
    // (c) Mr. Figglesworth 2002
    // This code is licensed under beerware.  You are allowed to freely use it
    // and modify it in any way.  Your only two obligations are: (1) at your option,
    // to buy the author a beer if you ever meet him; and (2) include the
    // copyright notice and license in any redistribution of this code or
    // alterations of it.
    //
    // Full credit for how the array gets implemented goes to the guy who wrote
    // the article and posted it on the NWNVault (I couldn't find your article
    // to give you credit :( ).  And, of course, to bioware.  Great job!
    ////////////////////////////////////////////////////////////////////////////////
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

/**
 * Creates a new array on the given storage object. If an
 * array with the same name already exists, the function
 * errors.
 *
 * @param store The object to use as holder for the array
 * @param name  The name of the array
 * @return      SDL_SUCCESS if the array was successfully created,
 *              one of SDL_ERROR_* on error.
 */
int array_create(object store, string name);

/**
 * Deletes an array, erasing all it's entries.
 *
 * @param store The object which holds the array to delete
 * @param name  The name of the array
 * @return      SDL_SUCCESS if the array was successfully deleted,
 *              one of SDL_ERROR_* on error
 */
int array_delete(object store, string name);

/**
 * Stores a string in an array.
 *
 * @param store The object holding the array
 * @param name  The name of the array
 * @param i     The index to store the string at
 * @param entry The string to store
 * @return      SDL_SUCCESS if the store was successfull, SDL_ERROR_* on error.
 */
int array_set_string(object store, string name, int i, string entry);

/**
 * Stores an integer in an array.
 *
 * @param store The object holding the array
 * @param name  The name of the array
 * @param i     The index to store the integer at
 * @param entry The integer to store
 * @return      SDL_SUCCESS if the store was successfull, SDL_ERROR_* on error.
 */
int array_set_int(object store, string name, int i, int entry);

/**
 * Stores a float in an array.
 *
 * @param store The object holding the array
 * @param name  The name of the array
 * @param i     The index to store the float at
 * @param entry The float to store
 * @return      SDL_SUCCESS if the store was successfull, SDL_ERROR_* on error.
 */
int array_set_float(object store, string name, int i, float entry);

/**
 * Stores an object in an array.
 *
 * @param store The object holding the array
 * @param name  The name of the array
 * @param i     The index to store the object at
 * @param entry The object to store
 * @return      SDL_SUCCESS if the store was successfull, SDL_ERROR_* on error.
 */
int array_set_object(object store, string name, int i, object entry);

/**
 * Gets a string from an array.
 *
 * @param store The object holding the array
 * @param name  The name of the array
 * @param i     The index to retrieve the string from
 * @return      The value contained at the index on success,
 *              "" on error
 */
string array_get_string(object store, string name, int i);

/**
 * Gets an integer from an array.
 *
 * @param store The object holding the array
 * @param name  The name of the array
 * @param i     The index to retrieve the integer from
 * @return      The value contained at the index on success,
 *              0 on error
 */
int array_get_int(object store, string name, int i);

/**
 * Gets a float from an array.
 *
 * @param store The object holding the array
 * @param name  The name of the array
 * @param i     The index to retrieve the float from
 * @return      The value contained at the index on success,
 *              0.0f on error
 */
float array_get_float(object store, string name, int i);

/**
 * Gets an object from an array.
 *
 * @param store The object holding the array
 * @param name  The name of the array
 * @param i     The index to retrieve the object from
 * @return      The value contained at the index on success,
 *              OBJECT_INVALID on error
 */
object array_get_object(object store, string name, int i);

/**
 * Removes all entries in the array with indexes greater than or equal to
 * the new size and sets the array size to be equal to the new size.
 *
 * @param store    The object holding the array
 * @param name     The name of the array
 * @param size_new The new number of entries in the array
 * @return         SDL_SUCCESS on successful resize, SDL_ERROR_* on
 *                 error
 */
int array_shrink(object store, string name, int size_new);

/**
 * Gets the current size of the array. This is one greater
 * than the index of highest indexed element the array
 * has contained since the last array_shrink or the new size
 * specified by the last array_shrink, whichever is greater.
 *
 * @param store    The object holding the array
 * @param name     The name of the array
 * @return         The size of the array, or -1 if the specified
 *                 array does not exist.
 */
int array_get_size(object store, string name);

/**
 * Checks whether the given array exists.
 *
 * @param store    The object holding the array
 * @param name     The name of the array
 * @return         TRUE if the array exists, FALSE otherwise.
 */
int array_exists(object store, string name);

/* These need to be rewritten and made less bug-prone before being taken into use.
   Preferrably not necessarily have it be fucking massive square matrix, but instead
   store a separate length for each x row.

int array_2d_create(object store, string name);
int array_2d_delete(object store, string name);

int array_2d_set_string(object store, string name, int i, int j, string entry);
int array_2d_set_int(object store,    string name, int i, int j, int entry);
int array_2d_set_float(object store,  string name, int i, int j, float entry);
int array_2d_set_object(object store, string name, int i, int j, object entry);

// returns "" or 0 on error
string array_2d_get_string(object store, string name, int i, int j);
int    array_2d_get_int(object store,    string name, int i, int j);
float  array_2d_get_float(object store,  string name, int i, int j);
object array_2d_get_object(object store, string name, int i, int j);

// changes memory usage of array (deletes x[ > size_new])
int array_2d_shrink(object store, string name, int size_new, int axis);

// gets current maximum size of array
int array_2d_get_size(object store, string name, int axis);

int array_2d_exists(object store, string name);
*/

/////////////////////////////////////
// Error Returns
/////////////////////////////////////

const int SDL_SUCCESS                 = 1;
const int SDL_ERROR                   = 1000;
const int SDL_ERROR_ALREADY_EXISTS    = 1001;
const int SDL_ERROR_DOES_NOT_EXIST    = 1002;
const int SDL_ERROR_OUT_OF_BOUNDS     = 1003;
const int SDL_ERROR_NO_ZERO_SIZE      = 1004; // Not used - Ornedan 2006.09.15
const int SDL_ERROR_NOT_VALID_OBJECT  = 1005;
const int SDL_ERROR_INVALID_PARAMETER = 1006;


/////////////////////////////////////
// Implementation
/////////////////////////////////////

int array_create(object store, string name)
{
    // error checking
    if(!GetIsObjectValid(store))
        return SDL_ERROR_NOT_VALID_OBJECT;
    else if(array_exists(store, name))
        return SDL_ERROR_ALREADY_EXISTS;
    else
    {
        // Initialize the size (always one greater than the actual size)
        SetLocalInt(store,name,1);
        return SDL_SUCCESS;
    }
}

void array_delete_loop(object store, string name, int nMin, int nMax)
{
    int i = nMin;
    while(i < nMin + 250 && i < nMax)
    {
        DeleteLocalString(store, name+"_"+IntToString(i));

        // just in case, delete possible object names
        DeleteLocalObject(store, name+"_"+IntToString(i)+"_OBJECT");
        i++;
    }
    // delay continuation to avoid TMI
    if(i < nMax)
        DelayCommand(0.0, array_delete_loop(store, name, i, nMax));
}

int array_delete(object store, string name)
{
    // error checking
    int size=GetLocalInt(store,name);
    if (size==0)
        return SDL_ERROR_DOES_NOT_EXIST;

    array_delete_loop(store, name, 0, size+5);

    DeleteLocalInt(store,name);

    return SDL_SUCCESS;
}

int array_set_string(object store, string name, int i, string entry)
{
    int size = GetLocalInt(store,name);
    if(size == 0)
        return SDL_ERROR_DOES_NOT_EXIST;
    if(i < 0)
        return SDL_ERROR_OUT_OF_BOUNDS;

    SetLocalString(store,name+"_"+IntToString(i),entry);

    // save size if we've enlarged it
    if(i+2>size)
        SetLocalInt(store,name,i+2);

    return SDL_SUCCESS;
}

int array_set_int(object store, string name, int i, int entry)
{
    return array_set_string(store,name,i,IntToString(entry));
}

int array_set_float(object store, string name, int i, float entry)
{
    return array_set_string(store,name,i,FloatToString(entry));
}

int array_set_object(object store, string name, int i, object entry)
{
    int results = array_set_string(store, name, i, "OBJECT");
    if (results == SDL_SUCCESS)
        SetLocalObject(store, name + "_" + IntToString(i) + "_OBJECT", entry);

    return results;
}

string array_get_string(object store, string name, int i)
{
    // error checking
    int size=GetLocalInt(store,name);
    if (size==0 || i>size || i < 0)
        return "";

    return GetLocalString(store,name+"_"+IntToString(i));
}

int array_get_int(object store, string name, int i)
{
    return StringToInt(array_get_string(store,name,i));
}

float array_get_float(object store, string name, int i)
{
    return StringToFloat(array_get_string(store,name,i));
}

object array_get_object(object store, string name, int i)
{
    if(array_get_string(store, name, i) == "OBJECT")
        return GetLocalObject(store,name+"_"+IntToString(i)+"_OBJECT");
    else
        return OBJECT_INVALID;
}

int array_shrink(object store, string name, int size_new)
{
    // Get the current size value
    int size = GetLocalInt(store, name);
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
        DeleteLocalString(store, name+"_"+IntToString(i));

        // just in case, delete possible object names
        DeleteLocalObject(store, name+"_"+IntToString(i)+"_OBJECT");
    }

    // Store the new size, with the +1 existence marker
    SetLocalInt(store, name, size_new + 1);

    return SDL_SUCCESS;
}

int array_get_size(object store, string name)
{
    return GetLocalInt(store, name) - 1;
}

int array_exists(object store, string name)
{
    // If the size and presence indicator local is non-zero, the array exists. Normalize it's value to TRUE / FALSE and return
    return GetLocalInt(store, name) != 0;
}

/*
int array_2d_create(object store, string name)
{
    // error checking
    if(!GetIsObjectValid(store))
        return SDL_ERROR_NOT_VALID_OBJECT;
    else if(GetLocalInt(store,name))
        return SDL_ERROR_ALREADY_EXISTS;
    else
    {
        // Initialize the size (always one greater than the actual size)
        SetLocalInt(store,name+"_A",1);
        SetLocalInt(store,name+"_B",1);
        return SDL_SUCCESS;
    }
}


int array_2d_delete(object store, string name)
{
    // error checking
    int sizeA=GetLocalInt(store,name+"_A");
    if (sizeA==0)
        return SDL_ERROR_DOES_NOT_EXIST;
    int sizeB=GetLocalInt(store,name+"_B");
    if (sizeB==0)
        return SDL_ERROR_DOES_NOT_EXIST;

    int i;
    int j;
    for (i=0; i<sizeA+5; i++)
    {
        for (j=0;j<sizeB+5; j++)
        {
            DeleteLocalString(store,name+"_"+IntToString(i)+"_"+IntToString(j));

            // just in case, delete possible object names
            DeleteLocalObject(store,name+"_"+IntToString(i)+"_"+IntToString(j)+"_OBJECT");
        }
    }

    DeleteLocalInt(store,name+"_A");
    DeleteLocalInt(store,name+"_B");

    return SDL_SUCCESS;
}

int array_2d_set_string(object store, string name, int i, int j, string entry)
{
    int sizeA=GetLocalInt(store,name+"_A");
    if (sizeA==0)
        return SDL_ERROR_DOES_NOT_EXIST;
    int sizeB=GetLocalInt(store,name+"_B");
    if (sizeB==0)
        return SDL_ERROR_DOES_NOT_EXIST;

    SetLocalString(store,name+"_"+IntToString(i)+"_"+IntToString(j),entry);

    // save size if we've enlarged it
    if (i+2>sizeA)
        SetLocalInt(store,name+"_A",i+2);
    if (j+2>sizeB)
        SetLocalInt(store,name+"_B",j+2);

    return SDL_SUCCESS;
}


int array_2d_set_int(object store, string name, int i, int j, int entry)
{
    return array_2d_set_string(store,name,i,j,IntToString(entry));
}

int array_2d_set_float(object store, string name, int i, int j, float entry)
{
    return array_2d_set_string(store,name,i,j,FloatToString(entry));
}

int array_2d_set_object(object store, string name, int i, int j, object entry)
{
    // object is a little more complicated.
    // we want to create an object as a local variable too
    if (!GetIsObjectValid(entry))
        return SDL_ERROR_NOT_VALID_OBJECT;

    int results=array_2d_set_string(store,name,i,j,"OBJECT");
    if (results==SDL_SUCCESS)
        SetLocalObject(store,name+"_"+IntToString(i)+"_"+IntToString(j)+"_OBJECT",entry);

    return results;
}


string array_2d_get_string(object store, string name, int i, int j)
{
    int sizeA=GetLocalInt(store,name+"_A");
    if (sizeA==0 || i>sizeA)
        return "";
    int sizeB=GetLocalInt(store,name+"_B");
    if (sizeB==0 || j>sizeB)
        return "";

    return GetLocalString(store,name+"_"+IntToString(i)+"_"+IntToString(j));
}

int array_2d_get_int(object store, string name, int i, int j)
{
    return StringToInt(array_2d_get_string(store,name,i,j));
}

float array_2d_get_float(object store, string name, int i, int j)
{
    return StringToFloat(array_2d_get_string(store,name,i,j));
}

object array_2d_get_object(object store, string name, int i, int j)
{
    return GetLocalObject(store,name+"_"+IntToString(i)+"_"+IntToString(j)+"_OBJECT");
}


int array_2d_shrink(object store, string name, int size_new, int axis)
{
    // error checking
    int sizeA=GetLocalInt(store,name+"_A");
    if (sizeA==0)
        return SDL_ERROR_DOES_NOT_EXIST;
    int sizeB=GetLocalInt(store,name+"_B");
    if (sizeB==0)
        return SDL_ERROR_DOES_NOT_EXIST;

    if (axis == 1 &&
        (sizeA==size_new || sizeA<size_new))
        return SDL_SUCCESS;
    if (axis == 2 &&
        (sizeB==size_new || sizeB<size_new))
        return SDL_SUCCESS;

    int i; int j;
    if(axis==1)
    {
        for (i=size_new; i<sizeA; i++)
        {
            for(j=0;j<sizeB+5;j++)
            {
                DeleteLocalString(store,name+"_"+IntToString(i)+"_"+IntToString(j));

                // just in case, delete possible object names
                DeleteLocalObject(store,name+"_"+IntToString(i)+"_"+IntToString(j)+"_OBJECT");
            }
        }

        SetLocalInt(store,name+"_A",size_new+1);
        return SDL_SUCCESS;
    }
    else if(axis==2)
    {
        for (j=size_new; j<sizeB; j++)
        {
            for(i=0;i<sizeA+5;i++)
            {
                DeleteLocalString(store,name+"_"+IntToString(i)+"_"+IntToString(j));

                // just in case, delete possible object names
                DeleteLocalObject(store,name+"_"+IntToString(i)+"_"+IntToString(j)+"_OBJECT");
            }
        }

        SetLocalInt(store,name+"_B",size_new+1);
        return SDL_SUCCESS;
    }
    else
        return SDL_ERROR_DOES_NOT_EXIST;
}

int array_2d_get_size(object store, string name, int axis)
{
    if(axis==1)
        return GetLocalInt(store,name+"_A")-1;
    else if(axis==2)
        return GetLocalInt(store,name+"_B")-1;
    else
        return 0;
}

int array_2d_exists(object store, string name)
{
    if (GetLocalInt(store,name+"_A")==0||GetLocalInt(store,name+"_B")==0)
        return FALSE;
    else
        return TRUE;
}
*/

// Test main
//void main(){}
