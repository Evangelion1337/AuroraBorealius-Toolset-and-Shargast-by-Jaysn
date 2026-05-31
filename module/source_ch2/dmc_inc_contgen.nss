/**
 * This script an include used as part of the container respawning system in
 * dmc_containergen.
 *
 * Feel free to use or modify this script freely, with the exception that this
 * paragraph must remain unchanged.  Please leave some mention of the original
 * authors in the comments of the script, and if you have an area in your module
 * where you give credit to the developers/contributors, please be sure to
 * include us.
 *
 * @author <a href="mailto:david@carr.name">David Carr</a>
 * @author <a href="http://nwvault.ign.com/Files/scripts/data/1046937481401.shtml">
 *           R.Lowe
 *         </a>
 * @version 0.3
 */

#include "dmc_inc_copyfunc"
#include "dmc_inc_array"

/**
 * PUBLIC: When a container receives user-defined event
 * UE_SET_RESPAWN_VARIABLES, this local float should be set to the number of
 * seconds between respawns
 */
const string RESPAWN_DURATION_TAG = "RESPAWN_DURATION";
/**
 * PUBLIC: When a container receives user-defined event
 * UE_SET_RESPAWN_VARIABLES, this local string should be set to the blueprint
 * resref of the invisible object to use as a respawner
 */
const string RESPAWNER_RESREF_TAG = "RESPAWNER_RESREF";
/**
 * PUBLIC: When a container receives user-defined event
 * UE_SET_RESPAWN_VARIABLES, this local int may be set to TRUE if initial
 * inventory respawning is desired
 */
const string CONTAINER_STORE_INVENTORY_TAG = "CONTAINER_STORE_INVENTORY";
/**
 * PUBLIC: When a container receives user-defined events UE_GENERATE_TREASURE or
 * UE_CONTAINER_DESTRUCTION, this local object will be set to the object that
 * triggered the event (the character who opened or destroyed the container).
 */
const string CONTAINER_ACTOR_TAG = "CONTAINER_ACTOR";

/**
 * PUBLIC: This user-defined event is fired whenever the respawn system needs
 * variables to be set.  Once you have set these variables, you must call
 * {@link #callbackSetRespawnVariables(object)} or the container will not
 * respawn.
 *
 * @see #RESPAWN_DURATION_TAG
 * @see #RESPAWNER_RESREF_TAG
 * @see #CONTAINER_STORE_INVENTORY_TAG
 */
const int UE_SET_RESPAWN_VARIABLES = 46;
/**
 * PUBLIC: This user-defined event is fired whenever it is appropriate to
 * generate treasure.
 */
const int UE_GENERATE_TREASURE = 47;
/**
 * PUBLIC: This user-defined event is fired whenever a container is destroyed,
 * to allow for custom behaviors such as the destruction of fragile treasure.
 */
const int UE_CONTAINER_DESTRUCTION = 48;

/**
 * PRIVATE: the variable name which stores whether the respawn timer has elapsed
 */
const string RESPAWN_TIMER_TAG = "RESPAWN_TIMER";
/**
 * PRIVATE: the variable name which stores the respawner instance containers
 */
const string RESPAWNER_TAG = "RESPAWNER";
/**
 * PRIVATE: the variable name which stores the container instance for spawners
 */
const string INSTANCE_TAG = "SPAWN_INSTANCE";
/**
 * PRIVATE: the variable name which stores the blueprint resref for the
 * container to respawn
 */
const string CONTAINER_RESREF_TAG = "CONTAINER_RESREF";
/**
 * PRIVATE: the name of the array to store item resrefs in for the initial
 * container contents
 */
const string RESREF_ARRAY = "ITEM_RESREF";
/**
 * PRIVATE: the name of the array to store item stack sizes in for the initial
 * container contents
 */
const string STACKSIZE_ARRAY = "ITEM_STACKSIZE";


/**
 * PRIVATE: Writes an error message to the log
 *
 * @param sMsg the message to write
 */
void logError(string sMsg) {
  string sErrorMessage = "ERROR: " + sMsg;
  WriteTimestampedLogEntry(sErrorMessage);
}

/**
 * PRIVATE: Sets the respawner object associated with a container
 */
void setRespawner(object oContainer, object oSpawner) {
  SetLocalObject(oContainer, RESPAWNER_TAG, oSpawner);
}

/**
 * PRIVATE: Sets the container object associated with the spawner
 */
void setInstance(object oSpawner, object oContainer) {
  SetLocalObject(oSpawner, INSTANCE_TAG, oContainer);
}

/**
 * PRIVATE: Moves the respawn variables from the container to the spawner
 */
void moveRespawnVariables(object oContainer, object oSpawner) {
  moveLocalFloat(oContainer, oSpawner, RESPAWN_DURATION_TAG);
  moveLocalInt(oContainer, oSpawner, CONTAINER_STORE_INVENTORY_TAG);
  DeleteLocalString(oContainer, RESPAWNER_RESREF_TAG);//no longer needed
}

/**
 * Returns true if the inventory should be stored/restored
 */
int shouldStoreInventory(object oObj) {
  return GetLocalInt(oObj, CONTAINER_STORE_INVENTORY_TAG);
}

/**
 * PRIVATE: Returns the blueprint resref for the container that the spawner
 * generates
 */
string getContainerResRef(object oSpawner) {
  return GetLocalString(oSpawner, CONTAINER_RESREF_TAG);
}

/**
 * PRIVATE: Sets the blueprint resref for the container that the spawner
 * generates
 */
void setContainerResRef(object oSpawner, string sResRef) {
  SetLocalString(oSpawner, CONTAINER_RESREF_TAG, sResRef);
}

/**
 * PRIVATE: Stores the contents of the container on the spawner.
 * Note that GetResRef(object) may return an empty string
 */
void storeInventory(object oContainer, object oSpawner) {
  int nIndex = 0;
  object oItem = GetFirstItemInInventory(oContainer);
  while(GetIsObjectValid(oItem)) {
    int nStackSize = GetNumStackedItems(oItem);
    string sResRef = GetResRef(oItem);
    //only store it if we'll be able to create it
    if(nStackSize > 0 && sResRef != "") {
      SetLocalArrayString(oSpawner, RESREF_ARRAY, nIndex, sResRef);
      SetLocalArrayInt(oSpawner, STACKSIZE_ARRAY, nIndex, nStackSize);
      nIndex++;
    }
    oItem = GetNextItemInInventory(oContainer);
  }
}

/**
 * PRIVATE: Returns the container object associated with the spawner, or
 * OBJECT_INVALID if an instance doesn't exist
 */
object getInstance(object oSpawner) {
  return GetLocalObject(oSpawner, INSTANCE_TAG);
}

/**
 * PRIVATE: Returns TRUE if the specified area is empty
 */
int areaIsEmpty(object oArea) {
  object oTarget = GetFirstObjectInArea(oArea);
  while(GetIsObjectValid(oTarget)) {
    if(GetIsPC(oTarget)) {
      return FALSE;
    }
    oTarget = GetNextObjectInArea(oArea);
  }
  return TRUE;
}

/**
 * PRIVATE: Clears a container's inventory
 */
void clearInventory(object oContainer) {
  object oItem = GetFirstItemInInventory(oContainer);
  while(GetIsObjectValid(oItem)) {
    DestroyObject(oItem);
    oItem = GetNextItemInInventory(oContainer);
  }
}

/**
 * PRIVATE: Clears the hold on treasure generation set by setRespawnTimer
 */
void clearRespawnTimer(object oContainer) {
  SetLocalInt(oContainer, RESPAWN_TIMER_TAG, FALSE);
}

/**
 * PRIVATE: Restores the contents of the container from the spawner
 */
void restoreInventory(object oSpawner, object oContainer) {
  int nLength = GetLocalArrayLength(oSpawner, RESREF_ARRAY);
  int nIndex;
  for(nIndex = 0; nIndex < nLength; nIndex++) {
    string sResRef = GetLocalArrayString(oSpawner, RESREF_ARRAY, nIndex);
    int nStackSize = GetLocalArrayInt(oSpawner, STACKSIZE_ARRAY, nIndex);
    if(sResRef == "") {
      logError("invalid item resref");
      continue;//ignore this one
    }
    if(nStackSize < 1) {//if the stack size wasn't properly set
      logError("invalid stack size");
      nStackSize = 1;//deal with it gracefully
    }
    CreateItemOnObject(sResRef, oContainer, nStackSize);
  }
}

/**
 * PRIVATE: If we need to create a new container and don't have a resref, fail.
 * If there's an error when we try to create a new container, fail.
 * If we make a new container, tell it that we're its respawner and store
 * for our reference that it's our instance.  If we don't need a new
 * instance, clear the container and reset the variable so that treasure will
 * respawn.  If we stored the inventory for the container, restore it.
 */
void ActionRespawnContainer(object oSpawner) {
  object oContainer = getInstance(oSpawner);
  string sResRef = getContainerResRef(oSpawner);
  location lLoc = GetLocation(oSpawner);
  //Check to see if we could respawn the container
  if(sResRef == "") {
    logError("no resref for chest");
    DestroyObject(oSpawner, 0.5);
    return;
  }
  //Check to see if the area is empty so that we can destroy and respawn the
  //container to reset the traps.
  if(GetIsObjectValid(oContainer)) {
    object oArea = GetArea(oContainer);
    if(areaIsEmpty(oArea)) {
      clearInventory(oContainer);
      DestroyObject(oContainer);
      oContainer = OBJECT_INVALID;
    }
  }
  if(!GetIsObjectValid(oContainer)) {//if the container was destroyed, respawn
    oContainer = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLoc);
    setRespawner(oContainer, oSpawner);//Tell the container we're its respawner
    setInstance(oSpawner, oContainer);//Set the respawner's instance
  } else {//we need to reset the flag so that treasure is generated
    if(GetLockLockable(oContainer) && !GetLocked(oContainer)) {
      SetLocked(oContainer, TRUE);//reset the lock
    }
    clearRespawnTimer(oContainer);
  }
  if(!GetIsObjectValid(oContainer)) {//if we failed to respawn it
    logError("could not create container");
    DestroyObject(oSpawner, 0.5);
    return;
  }
  if(shouldStoreInventory(oSpawner)) {
    clearInventory(oContainer);
    restoreInventory(oSpawner, oContainer);
  }
}

/**
 * PRIVATE: Returns the number of seconds between respawns
 */
float getRespawnDuration(object oObj) {
  return GetLocalFloat(oObj, RESPAWN_DURATION_TAG);
}

/**
 * PRIVATE: Adds a respawn event to the event queue for the spawner
 *
 * @param oSpawner the spawner to add an event for
 */
void addRespawnToEventQueue(object oSpawner) {
  AssignCommand(oSpawner, ClearAllActions());
  AssignCommand(oSpawner,
    DelayCommand(getRespawnDuration(oSpawner), ActionRespawnContainer(oSpawner))
  );
}

/**
 * PRIVATE: Sets all appropriate variables on the spawner and adds a respawn
 * event to its queue.
 */
void configureSpawner(object oSpawner, object oContainer) {
  setRespawner(oContainer, oSpawner);
  setInstance(oSpawner, oContainer);
  moveRespawnVariables(oContainer, oSpawner);
  if(shouldStoreInventory(oSpawner)) {
    storeInventory(oContainer, oSpawner);
  }
  setContainerResRef(oSpawner, GetResRef(oContainer));
  addRespawnToEventQueue(oSpawner);
}

/**
 * PRIVATE: Returns the resref of the respawner blueprint
 */
string getRespawnerResRef(object oObj) {
  return GetLocalString(oObj, RESPAWNER_RESREF_TAG);
}

/**
 * PUBLIC: Called from the user-defined UE_SET_RESPAWN_VARIABLES event.  Allows
 * us to take actions, such as initialize the respawner, after the respawn
 * variables  have been set.
 *
 * @param oContainer the container to set up a respawner for
 */
void callbackSetRespawnVariables(object oContainer) {
  location lLoc = GetLocation(oContainer);
  string sResRef = getRespawnerResRef(oContainer);
  //create a new spawner at the container's location
  object oSpawner = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLoc);
  if(!GetIsObjectValid(oSpawner)) {
    logError("failed spawner creation: " + sResRef);
  } else {
    configureSpawner(oSpawner, oContainer);
  }
}
