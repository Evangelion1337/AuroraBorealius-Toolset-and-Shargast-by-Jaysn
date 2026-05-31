/**
 * Psuedo-array functions.  Currently only for ints and strings.
 *
 * Originally based on code in nw_o0_itemmaker.
 *
 * @author <a href="mailto:david@carr.name">David Carr</a>
 * @version 0.1
 */

/**
 * PRIVATE: the prefix for all array variables
 */
const string ARRAY_VARIABLE_PREFIX = "ARRAY_";

/**
 * PRIVATE: the postfix for all array length variables
 */
const string ARRAY_LENGTH_VARIABLE_POSTFIX = "_LENGTH";

/**
 * Deletes all local variables with the specified name on the object
 *
 * @param oObj the object to delete variables from
 * @param sVarName the name of the variables to delete
 */
void DeleteLocal(object oObj, string sVarName) {
  DeleteLocalFloat(oObj, sVarName);
  DeleteLocalInt(oObj, sVarName);
  DeleteLocalLocation(oObj, sVarName);
  DeleteLocalObject(oObj, sVarName);
  DeleteLocalString(oObj, sVarName);
}

/**
 * PRIVATE: translates an array name into a variable name
 *
 * @param sArrayName the name of the array
 * @param nIndex the index to get the variable name for
 * @return the variable name for this index of the array
 */
string GetArrayVariableName(string sArrayName, int nIndex) {
  return ARRAY_VARIABLE_PREFIX + sArrayName + IntToString(nIndex);
}

/**
 * PRIVATE: translates an array name into a length variable name
 *
 * @param sArrayName the name of the array
 * @return the variable name for the length of the array
 */
string GetArrayLengthVariableName(string sArrayName) {
  return ARRAY_VARIABLE_PREFIX + sArrayName + ARRAY_LENGTH_VARIABLE_POSTFIX;
}

/**
 * Gets the length of a local array
 *
 * @param oObj the object to store the array on
 * @param sArrayName the name of the array
 * @return the length of the array, or 0 if it doesn't exist
 */
int GetLocalArrayLength(object oObj, string sArrayName) {
  string sLengthVarName = GetArrayLengthVariableName(sArrayName);
  return GetLocalInt(oObj, sLengthVarName);
}

/**
 * Sets the length of a local array.  Note that this function will trim the
 * array if the new length is smaller than the current one.
 *
 * @param oObj the object to store the array on
 * @param sArrayName the name of the array
 * @param nLength the length to set; should be non-negative
 */
void SetLocalArrayLength(object oObj, string sArrayName, int nLength) {
  if(nLength < 0) return;
  string sLengthVarName = GetArrayLengthVariableName(sArrayName);
  int nCurLength = GetLocalArrayLength(oObj, sArrayName);
  int nIndex;
  for(nIndex=nCurLength; nIndex>nLength; nIndex--) {//trim array if needed
    string sVarName = GetArrayVariableName(sArrayName, nIndex-1);
    DeleteLocal(oObj, sVarName);
  }
  SetLocalInt(oObj, sLengthVarName, nLength);
}

/**
 * Returns the local string set at the specified index
 *
 * @param oObj the object to store the array on
 * @param sArrayName the name of the array
 * @param nIndex the index in the array (0-based)
 * @return the local string, or "" if not set
 */
string GetLocalArrayString(object oObj, string sArrayName, int nIndex) {
  string sVarName = GetArrayVariableName(sArrayName, nIndex);
  return GetLocalString(oObj, sVarName);
}

/**
 * Sets a local string at the specified index
 *
 * @param oObj the object to store the array on
 * @param sArrayName the name of the array
 * @param nIndex the index in the array (0-based)
 * @param sValue the string to set
 */
void SetLocalArrayString(object oObj, string sArrayName, int nIndex, string sValue) {
  string sVarName = GetArrayVariableName(sArrayName, nIndex);
  SetLocalArrayLength(oObj, sArrayName, nIndex + 1);
  SetLocalString(oObj, sVarName, sValue);
}

/**
 * Returns the local int set at the specified index
 *
 * @param oObj the object to store the array on
 * @param sArrayName the name of the array
 * @param nIndex the index in the array (0-based)
 * @return the local int, or 0 if not set
 */
int GetLocalArrayInt(object oObj, string sArrayName, int nIndex) {
  string sVarName = GetArrayVariableName(sArrayName, nIndex);
  return GetLocalInt(oObj, sVarName);
}

/**
 * Sets a local int at the specified index
 *
 * @param oObj the object to store the array on
 * @param sArrayName the name of the array
 * @param nIndex the index in the array (0-based)
 * @param nValue the int to set
 */
void SetLocalArrayInt(object oObj, string sArrayName, int nIndex, int nValue) {
  string sVarName = GetArrayVariableName(sArrayName, nIndex);
  SetLocalArrayLength(oObj, sArrayName, nIndex + 1);
  SetLocalInt(oObj, sVarName, nValue);
}
