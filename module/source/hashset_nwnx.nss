// Name     : hashset_nwnx
// Purpose  : A general purpose implementation combining a hash and a set (NWNX version)
// Author   : Ingmar Stieger
// Modified : December 18, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

/************************************/
/* Return codes                     */
/************************************/

int HASHSET_ERROR = FALSE;
int HASHSET_SUCCESS = TRUE;

/************************************/
/* Function prototypes              */
/************************************/

// create a new HashSet on oObject with name sHashSetName
// iSize is optional
int HashSetCreate(object oObject, string sHashSetName, int iSize = 500);

// Clear and delete sHashSetName on oObject
void HashSetDestroy(object oObject, string sHashSetName);

// return true if hashset sHashSet is valid
int HashSetValid(object oObject, string sHashSetName);

// return true if hashset sHashSet contains key sKey
int HashSetKeyExists(object oObject, string sHashSetName, string sKey);

// Set key sKey of sHashset to string sValue
int HashSetSetLocalString(object oObject, string sHashSetName, string sKey, string sValue);

// Retrieve string value of sKey in sHashset
string HashSetGetLocalString(object oObject, string sHashSetName, string sKey);

// Set key sKey of sHashset to integer iValue
int HashSetSetLocalInt(object oObject, string sHashSetName, string sKey, int iValue);

// Retrieve integer value of sKey in sHashset
int HashSetGetLocalInt(object oObject, string sHashSetName, string sKey);

// Delete sKey in sHashset
int HashSetDeleteVariable(object oObject, string sHashSetName, string sKey);

// Return the n-th key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetNthKey(object oObject, string sHashSetName, int i);

// Return the first key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetFirstKey(object oObject, string sHashSetName);

// Return the next key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetNextKey(object oObject, string sHashSetName);

// Return the current key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetCurrentKey(object oObject, string sHashSetName);

// Return the number of elements in sHashset
int HashSetGetSize(object oObject, string sHashSetName);

// Return TRUE if the current key is not the last one, FALSE otherwise
int HashSetHasNext(object oObject, string sHashSetName);

// public functions

int HashSetCreate(object oObject, string sHashSetName, int iSize = 500)
{
    SetLocalString(oObject, "NWNX!HASHSET!CREATE", sHashSetName + "!" + IntToString(iSize) + "!");
    return HASHSET_SUCCESS;
}

void HashSetDestroy(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!DESTROY", sHashSetName + "!!");
}

int HashSetValid(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!VALID", sHashSetName + "!!");
    return StringToInt(GetLocalString(oObject, "NWNX!HASHSET!VALID"));
}

int HashSetKeyExists(object oObject, string sHashSetName, string sKey)
{
    SetLocalString(oObject, "NWNX!HASHSET!EXISTS", sHashSetName + "!" + sKey + "!");
    return StringToInt(GetLocalString(oObject, "NWNX!HASHSET!EXISTS"));
}

int HashSetSetLocalString(object oObject, string sHashSetName, string sKey, string sValue)
{
    SetLocalString(oObject, "NWNX!HASHSET!INSERT", sHashSetName + "!" + sKey + "!" + sValue);
    return HASHSET_SUCCESS;
}

string HashSetGetLocalString(object oObject, string sHashSetName, string sKey)
{
    SetLocalString(oObject, "NWNX!HASHSET!LOOKUP", sHashSetName + "!" + sKey + "!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!LOOKUP");
}

int HashSetSetLocalInt(object oObject, string sHashSetName, string sKey, int iValue)
{
    HashSetSetLocalString(oObject, sHashSetName, sKey, IntToString(iValue));
    return HASHSET_SUCCESS;
}

int HashSetGetLocalInt(object oObject, string sHashSetName, string sKey)
{
    string sValue = HashSetGetLocalString(oObject, sHashSetName, sKey);
    if (sValue == "")
        return 0;
    else
        return StringToInt(sValue);
}

int HashSetDeleteVariable(object oObject, string sHashSetName, string sKey)
{
    SetLocalString(oObject, "NWNX!HASHSET!DELETE", sHashSetName + "!" + sKey + "!");
    return HASHSET_SUCCESS;
}

string HashSetGetNthKey(object oObject, string sHashSetName, int i)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETNTHKEY", sHashSetName + "!" + IntToString(i) + "!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!GETNTHKEY");
}

string HashSetGetFirstKey(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETFIRSTKEY", sHashSetName + "!!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!GETFIRSTKEY");
}

string HashSetGetNextKey(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETNEXTKEY", sHashSetName + "!!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!GETNEXTKEY");
}

string HashSetGetCurrentKey(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETCURRENTKEY", sHashSetName + "!!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!GETCURRENTKEY");
}

int HashSetGetSize(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETSIZE", sHashSetName + "!!           ");
    return StringToInt(GetLocalString(oObject, "NWNX!HASHSET!GETSIZE"));
}

int HashSetHasNext(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!HASNEXT", sHashSetName + "!!           ");
    return StringToInt(GetLocalString(oObject, "NWNX!HASHSET!HASNEXT"));
}

