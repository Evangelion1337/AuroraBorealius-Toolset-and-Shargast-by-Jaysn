/**
 * Functions to move and copy variables from one object to another.
 *
 * @author <a href="mailto:david@carr.name">David Carr</a>
 * @version 0.1
 */

/**
 * Copys a local float
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void copyLocalFloat(object oFrom, object oTo, string sVarName) {
  SetLocalFloat(oTo, sVarName, GetLocalFloat(oFrom, sVarName));
}

/**
 * Copys a local int
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void copyLocalInt(object oFrom, object oTo, string sVarName) {
  SetLocalInt(oTo, sVarName, GetLocalInt(oFrom, sVarName));
}

/**
 * Copys a local location
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void copyLocalLocation(object oFrom, object oTo, string sVarName) {
  SetLocalLocation(oTo, sVarName, GetLocalLocation(oFrom, sVarName));
}

/**
 * Copys a local object
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void copyLocalObject(object oFrom, object oTo, string sVarName) {
  SetLocalObject(oTo, sVarName, GetLocalObject(oFrom, sVarName));
}

/**
 * Copys a local string
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void copyLocalString(object oFrom, object oTo, string sVarName) {
  SetLocalString(oTo, sVarName, GetLocalString(oFrom, sVarName));
}

/**
 * Moves a local float
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void moveLocalFloat(object oFrom, object oTo, string sVarName) {
  copyLocalFloat(oFrom, oTo, sVarName);
  DeleteLocalFloat(oFrom, sVarName);
}

/**
 * Moves a local int
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void moveLocalInt(object oFrom, object oTo, string sVarName) {
  copyLocalInt(oFrom, oTo, sVarName);
  DeleteLocalInt(oFrom, sVarName);
}

/**
 * Moves a local location
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void moveLocalLocation(object oFrom, object oTo, string sVarName) {
  copyLocalLocation(oFrom, oTo, sVarName);
  DeleteLocalLocation(oFrom, sVarName);
}

/**
 * Moves a local object
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void moveLocalObject(object oFrom, object oTo, string sVarName) {
  copyLocalObject(oFrom, oTo, sVarName);
  DeleteLocalObject(oFrom, sVarName);
}

/**
 * Moves a local string
 *
 * @param oFrom the source object
 * @param oTo the destination object
 * @param sVarName the variable to copy
 */
void moveLocalString(object oFrom, object oTo, string sVarName) {
  copyLocalString(oFrom, oTo, sVarName);
  DeleteLocalString(oFrom, sVarName);
}
