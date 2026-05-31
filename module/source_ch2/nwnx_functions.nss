// Name     : NWNX functions
// Purpose  : Various new functions for items
// Author   : Ingmar Stieger (Papillon)
// Modified : December 31, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

/************************************/
/* Function prototypes              */
/************************************/

// Set the DC for unlocking oObject
void SetLockUnlockDC_(object oObject, int iDC);

// Get the AC of armor oObject
int GetArmorAC_(object oObject);

// Set the AC of armor oObject
void SetArmorAC_(object oObject, int iAC);

// Set the gold piece value of oObject
void SetGoldPieceValue_(object oObject, int iValue);

// Set tag of oObject to sValue
void SetTag_(object oObject, string sValue);

// Get description of oObject;
string GetDescription_(object oObject);

/************************************/
/* Implementation                   */
/************************************/

void SetLockUnlockDC_(object oObject, int iDC)
{
    SetLocalString(oObject, "NWNX!FUNCTIONS!SETLOCKDC", IntToString(iDC));
}

int GetArmorAC_(object oObject)
{
    string sAC;
    SetLocalString(oObject, "NWNX!FUNCTIONS!GETARMORAC", "      ");
    sAC = GetLocalString(oObject, "NWNX!FUNCTIONS!GETARMORAC");
    return StringToInt(sAC);
}

void SetArmorAC_(object oObject, int iAC)
{
    SetLocalString(oObject, "NWNX!FUNCTIONS!SETARMORAC", IntToString(iAC));
}

void SetGoldPieceValue_(object oObject, int iValue)
{
    SetLocalString(oObject, "NWNX!FUNCTIONS!SETGOLDPIECEVALUE", IntToString(iValue));
}

void SetTag_(object oObject, string sValue)
{
    SetLocalString(oObject, "NWNX!FUNCTIONS!SETTAG", sValue);
}

string GetDescription_(object oObject)
{
    string sDesc;
    SetLocalString(oObject, "NWNX!FUNCTIONS!GETDESCRIPTION", "                                                                                                                                                                                                                                                            ");
    sDesc = GetLocalString(oObject, "NWNX!FUNCTIONS!GETDESCRIPTION");
    return sDesc;
}


