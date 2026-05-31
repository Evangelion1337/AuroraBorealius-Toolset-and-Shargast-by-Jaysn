//::///////////////////////////////////////////////
//:: Metalocation include
//:: inc_metalocation
//:://////////////////////////////////////////////
/** @file
    A metalocation is intended for reliable (independent
    of object locations in memory) storage of location
    data across module boundaries for possible eventual
    re-entry to the same module. For example, to
    carry location data over server resets.

    This file specifies the metalocation structure,
    which contains data equivalent to a standard
    location, and in addition name of the module the
    metalocation resides in and, if defined, the name
    of the metalocation.
    The area reference is built of two strings and
    two integers instead of a memory pointer.
    First string specifies the tag of the area containing
    the metalocation. The second string specifies the name
    of the area and the integers specify it's height and
    width. They are used obtain exact match in cases where
    there are several areas with the same tag.

    The metalocation invariant:
    All valid metalocations are such that they may be
    uniquely matched to a location.

    That is, a valid metalocation is one where the area
    can be identified will full certainty using the
    tag, name, height and width of the area.


    In addition, this file contains a group of functions
    for abstracted handling of metalocation data.


    @author Ornedan
    @date   Created - 23.05.2005
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * A dismantled version of location with some metadata attached.
 * Intended for use of persistent storage of location data over
 * module boundaries. For example over server resets
 */
struct metalocation{
    /// Tag of the area the location is in.
    string sAreaTag;
    /*
    /// Resref of the area the location is in. Used to differentiate between
    /// areas with the same tag.
    string sAreaResRef;
    */
    /// Name of the area. Used to differentiate between areas with the same tag.
    string sAreaName;
    /// Height of the area, in tiles. Used if tag and name are not enough to
    /// uniquely identify an area.
    int nAreaHeight;
    /// Width of the area, in tiles. Used if tag and name are not enough to
    /// uniquely identify an area.
    int nAreaWidth;
    /// The X coordinate of the location within the area.
    float fX;
    /// The Y coordinate of the location within the area.
    float fY;
    /// The Z coordinate of the location within the area.
    float fZ;
    /// The direction the location is facing.
    float  fFacing;
    /// The metalocation may be named and the name is stored in this member.
    string sName;
    /// Name of the module containing the location.
    string sModule;
    };

/**
 * Converts a standard location to equivalent metalocation. If area of the
 * location cannot be uniquely identified using it's tag, name, height and
 * width, a null metalocation is returned to preserve invariant of all
 * valid metalocations being uniquely identifiable.
 *
 * @param locL  The location to convert.
 * @param sName The name of the created metalocation, if any.
 * @return      The metalocation created from locL. Or a null
 *              metalocation on failure.
 */
struct metalocation LocationToMetalocation(location locL, string sName = "");

/**
 * Convert a metalocation to equivalent standard location.
 *
 * NOTE!
 * If the metalocation is not in current module, the current module's starting
 * location will be returned. As such, it is recommended that you run
 * GetIsMetalocationInModule() on the metalocation before using this.
 *
 * If the metalocation is not valid, the returned location will also
 * not be valid.
 *
 * @param mlocL The metalocation to convert.
 * @return      The location created from mlocL.
 */
location MetalocationToLocation(struct metalocation mlocL);

/**
 * Checks whether the given metalocation is in the module currently being run.
 *
 * @param mlocL The metalocation to test.
 * @return      TRUE if mlocL refers to a location within current module,
 *              FALSE otherwise.
 */
int GetIsMetalocationInModule(struct metalocation mlocL);

/**
 * Extracts an area reference from the given metalocation. If the metalocation
 * is not in the current module, does not refere to a valid area, or the area
 * cannot be uniquely identified, OBJECT_INVALID is returned.
 *
 * @param mlocL The metalocation from which to extract the area reference.
 * @return      An object reference to the area containing the metalocation or
 *              OBJECT_INVALID in case of error.
 */
object GetAreaFromMetalocation(struct metalocation mlocL);

/**
 * Stores the given metalocation on the given object. Behaves as other normal
 * local variables do.
 *
 * @param oObject The object to store the metalocation on.
 * @param sName   The local variable name the metalocation will be stored as.
 * @param mlocL   The metalocation to store.
 */
void SetLocalMetalocation(object oObject, string sName, struct metalocation mlocL);

/**
 * Stores the given metalocation persistantly, so that it will remain in the
 * character data over character exports.
 *
 * @param oCreature The creature to store the metalocation on.
 * @param sName     The local variable name the metalocation will be stored as.
 * @param mlocL     The metalocation to store.
 *
 * @see inc_persist_loca
 */
void SetPersistantLocalMetalocation(object oCreature, string sName, struct metalocation mlocL);

/**
 * Retrieves the metalocation stored on the given object under the given name.
 * NOTE! If there was no metalocation stored with the given name, the returned
 * value will have all it's fields contain null-equivalents.
 *
 * @param oObject The object the metalocation was stored on.
 * @param sName   The name the metalocation was stored under.
 * @return        A copy of the stored metalocation.
 */
struct metalocation GetLocalMetalocation(object oObject, string sName);

/**
 * Retrieves the metalocation persistantly stored on the given creature under
 * the given name.
 * NOTE! If there was no metalocation stored with the given name, the returned
 * value will have all it's fields contain null-equivalents.
 *
 * @param oCreature The creature the metalocation was stored on.
 * @param sName     The name the metalocation was stored under.
 * @return          A copy of the stored metalocation.
 *
 * @see inc_persist_loca
 */
struct metalocation GetPersistantLocalMetalocation(object oCreature, string sName);

/**
 * Deletes the metalocation stored with the given name on the given object.
 *
 * @param oObject The object the metalocation was stored on.
 * @param sName   The name the metalocation was stored under.
 */
void DeleteLocalMetalocation(object oObject, string sName);

/**
 * Deletes the metalocation persistantly stored with the given name on
 * the given creature.
 *
 * @param oCreature The creature the metalocation was stored on.
 * @param sName     The name the metalocation was stored under.
 *
 * @see inc_persist_loca
 */
void DeletePersistantLocalMetalocation(object oCreature, string sName);

/**
 * Creates a map pin based on the given metalocation. It will be created at the
 * end of the map pin array, with name equal to the metalocation's.
 *
 * @param mlocL The metalocation to create a map pin from.
 * @param oPC   The player character in whose map pin array to create the map pin in.
 */
void CreateMapPinFromMetalocation(struct metalocation mlocL, object oPC);

/**
 * Creates a metalocation based on the given map pin.
 *
 * @param oPC   The player character in whose map pin array to use
 * @param nPinNo   The position of the map pin to use
 */
struct metalocation CreateMetalocationFromMapPin(object oPC, int nPinNo);

/**
 * Creates a metalocation with all constituents having null-equivalent values.
 * Used when there is a need to return an invalid metalocation.
 *
 * @return A metalocation that has a null-equivalent in each field.
 */
struct metalocation GetNullMetalocation();

/**
 * Checks whether the given metalocation is valid. That is, not null and
 * in the current module.
 *
 * @param mlocL The metalocation to test.
 * @return      TRUE if the metalocation is valid, FALSE otherwise.
 */
int GetIsMetalocationValid(struct metalocation mlocL);

/**
 * Gets the size of a players map pin array
 *
 * @param oPC   The player character in whose map pin array to get the size of.
 */
int GetNumberOfMapPins(object oPC);

/**
 * Gets the area of a players specific map pin
 *
 * @param oPC   The player character in whose map pin array to get the area of.
 * @param nPinNo   The number of the map pin to remove.
 */
object  GetAreaOfMapPin(object oPC, int nPinNo);

/**
 * Deletes a players specific map pin
 *
 * @param oPC   The player character in whose map pin array to get the size of.
 */
void DeleteMapPin(object oPC, int nPinNo);

/**
 * Creates a string from a metalocation that is of the following format:
 * NameOfMetalocation - NameOfMetalocationArea (Xcoord, Ycoord)
 *
 * @param mlocL  The metalocation to make a string from.
 * @return       The created string.
 */
string MetalocationToString(struct metalocation mlocL);


//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

//#include "inc_utility"
#include "inc_area"         // Area functions seperated from inc_itility
#include "inc_persist_loca" // changed include as these are the only other
                            // functions required from inc_utilities


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

struct metalocation LocationToMetalocation(location locL, string sName = "")
{
    struct metalocation mlocL;
    object oArea = GetAreaFromLocation(locL);
    vector vCoords = GetPositionFromLocation(locL);
    mlocL.sAreaTag    = GetTag(oArea);
    mlocL.sAreaName   = GetName(oArea);
    mlocL.nAreaHeight = GetAreaHeight(oArea);
    mlocL.nAreaWidth  = GetAreaWidth(oArea);
    mlocL.fX          = vCoords.x;
    mlocL.fY          = vCoords.y;
    mlocL.fZ          = vCoords.z;
    mlocL.fFacing     = GetFacingFromLocation(locL);
    mlocL.sName       = sName;
    mlocL.sModule     = GetName(GetModule());

    // Check that the area can be uniquely identified.
    if(GetAreaFromMetalocation(mlocL) == OBJECT_INVALID)
        return GetNullMetalocation(); // It can't, return null.

    return mlocL;
}

location MetalocationToLocation(struct metalocation mlocL)
{
    // Check whether the metalocation is in this module
    if(!GetIsMetalocationInModule(mlocL))
        return GetStartingLocation(); // Must return a valid location, so return starting location.

    // Get the area
    object oArea = GetAreaFromMetalocation(mlocL);

    // Construct and return the location
    return Location(oArea, Vector(mlocL.fX, mlocL.fY, mlocL.fZ), mlocL.fFacing);
}

int GetIsMetalocationInModule(struct metalocation mlocL)
{
    return GetName(GetModule()) == mlocL.sModule;
}

object GetAreaFromMetalocation(struct metalocation mlocL)
{
    if(!GetIsMetalocationInModule(mlocL)) return OBJECT_INVALID;

    object oArea = GetObjectByTag(mlocL.sAreaTag, 0);
    // Multiple areas with same tag?
    if(GetName(oArea) != mlocL.sAreaName)
    {
        int i = 1;
        oArea = GetObjectByTag(mlocL.sAreaTag, i);
        while(GetIsObjectValid(oArea)                   &&
              GetName(oArea)       != mlocL.sAreaName   &&
              GetAreaHeight(oArea) != mlocL.nAreaHeight &&
              GetAreaWidth(oArea)  != mlocL.nAreaWidth
              )
            oArea = GetObjectByTag(mlocL.sAreaTag, ++i);

        // Make sure that if the object reference is not valid, it is OBJECT_INVALID
        if(!GetIsObjectValid(oArea)) return OBJECT_INVALID;

        // We have a valid area reference. Now check that it is the only one matching the parameters.
        object oAreaCheck = GetObjectByTag(mlocL.sAreaTag, ++i);
        while(GetIsObjectValid(oAreaCheck))
        {
            if(GetName(oAreaCheck)       == mlocL.sAreaName         &&
               GetAreaHeight(oAreaCheck) == mlocL.nAreaHeight &&
               GetAreaWidth(oAreaCheck)  == mlocL.nAreaWidth
              )
                return OBJECT_INVALID; // Found a second match, return OBJECT_INVALID to preserve invariant
        }
    }

    return oArea;
}

void SetLocalMetalocation(object oObject, string sName, struct metalocation mlocL)
{
    SetLocalString(oObject, "Metalocation_" + sName + "_AreaTag",    mlocL.sAreaTag);
    //SetLocalString(oObject, "Metalocation_" + sName + "_AreaResRef", mlocL.sAreaResRef);
    SetLocalString(oObject, "Metalocation_" + sName + "_AreaName",   mlocL.sAreaName);
    SetLocalInt   (oObject, "Metalocation_" + sName + "_AreaHeight", mlocL.nAreaHeight);
    SetLocalInt   (oObject, "Metalocation_" + sName + "_AreaWidth",  mlocL.nAreaWidth);
    SetLocalFloat (oObject, "Metalocation_" + sName + "_X",          mlocL.fX);
    SetLocalFloat (oObject, "Metalocation_" + sName + "_Y",          mlocL.fY);
    SetLocalFloat (oObject, "Metalocation_" + sName + "_Z",          mlocL.fZ);
    SetLocalFloat (oObject, "Metalocation_" + sName + "_Facing",     mlocL.fFacing);
    SetLocalString(oObject, "Metalocation_" + sName + "_Name",       mlocL.sName);
    SetLocalString(oObject, "Metalocation_" + sName + "_Module",     mlocL.sModule);
}

void SetPersistantLocalMetalocation(object oCreature, string sName, struct metalocation mlocL)
{
    // Persistant operations fail on non-creatures.
    if(GetObjectType(oCreature) != OBJECT_TYPE_CREATURE) return;

    SetPersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaTag",    mlocL.sAreaTag);
    //SetPersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaResRef", mlocL.sAreaResRef);
    SetPersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaName",   mlocL.sAreaName);
    SetPersistantLocalInt   (oCreature, "Metalocation_" + sName + "_AreaHeight", mlocL.nAreaHeight);
    SetPersistantLocalInt   (oCreature, "Metalocation_" + sName + "_AreaWidth",  mlocL.nAreaWidth);
    SetPersistantLocalFloat (oCreature, "Metalocation_" + sName + "_X",          mlocL.fX);
    SetPersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Y",          mlocL.fY);
    SetPersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Z",          mlocL.fZ);
    SetPersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Facing",     mlocL.fFacing);
    SetPersistantLocalString(oCreature, "Metalocation_" + sName + "_Name",       mlocL.sName);
    SetPersistantLocalString(oCreature, "Metalocation_" + sName + "_Module",     mlocL.sModule);
}

struct metalocation GetLocalMetalocation(object oObject, string sName)
{
    struct metalocation mlocL;
    mlocL.sAreaTag    = GetLocalString(oObject, "Metalocation_" + sName + "_AreaTag");
    //mlocL.sAreaResRef = GetLocalString(oObject, "Metalocation_" + sName + "_AreaResRef");
    mlocL.sAreaName   = GetLocalString(oObject, "Metalocation_" + sName + "_AreaName");
    mlocL.nAreaHeight = GetLocalInt   (oObject, "Metalocation_" + sName + "_AreaHeight");
    mlocL.nAreaWidth  = GetLocalInt   (oObject, "Metalocation_" + sName + "_AreaWidth");
    mlocL.fX          = GetLocalFloat (oObject, "Metalocation_" + sName + "_X");
    mlocL.fY          = GetLocalFloat (oObject, "Metalocation_" + sName + "_Y");
    mlocL.fZ          = GetLocalFloat (oObject, "Metalocation_" + sName + "_Z");
    mlocL.fFacing     = GetLocalFloat (oObject, "Metalocation_" + sName + "_Facing");
    mlocL.sName       = GetLocalString(oObject, "Metalocation_" + sName + "_Name");
    mlocL.sModule     = GetLocalString(oObject, "Metalocation_" + sName + "_Module");

    return mlocL;
}

struct metalocation GetPersistantLocalMetalocation(object oCreature, string sName)
{
    // Persistant operations fail on non-creatures.
    if(GetObjectType(oCreature) != OBJECT_TYPE_CREATURE) return GetNullMetalocation();

    struct metalocation mlocL;
    mlocL.sAreaTag    = GetPersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaTag");
    //mlocL.sAreaResRef = GetPersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaResRef");
    mlocL.sAreaName   = GetPersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaName");
    mlocL.nAreaHeight = GetPersistantLocalInt   (oCreature, "Metalocation_" + sName + "_AreaHeight");
    mlocL.nAreaWidth  = GetPersistantLocalInt   (oCreature, "Metalocation_" + sName + "_AreaWidth");
    mlocL.fX          = GetPersistantLocalFloat (oCreature, "Metalocation_" + sName + "_X");
    mlocL.fY          = GetPersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Y");
    mlocL.fZ          = GetPersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Z");
    mlocL.fFacing     = GetPersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Facing");
    mlocL.sName       = GetPersistantLocalString(oCreature, "Metalocation_" + sName + "_Name");
    mlocL.sModule     = GetPersistantLocalString(oCreature, "Metalocation_" + sName + "_Module");

    return mlocL;
}

void DeleteLocalMetalocation(object oObject, string sName)
{
    DeleteLocalString(oObject, "Metalocation_" + sName + "_AreaTag");
    //DeleteLocalString(oObject, "Metalocation_" + sName + "_AreaResRef");
    DeleteLocalString(oObject, "Metalocation_" + sName + "_AreaName");
    DeleteLocalInt   (oObject, "Metalocation_" + sName + "_AreaHeight");
    DeleteLocalInt   (oObject, "Metalocation_" + sName + "_AreaWidth");
    DeleteLocalFloat (oObject, "Metalocation_" + sName + "_X");
    DeleteLocalFloat (oObject, "Metalocation_" + sName + "_Y");
    DeleteLocalFloat (oObject, "Metalocation_" + sName + "_Z");
    DeleteLocalFloat (oObject, "Metalocation_" + sName + "_Facing");
    DeleteLocalString(oObject, "Metalocation_" + sName + "_Name");
    DeleteLocalString(oObject, "Metalocation_" + sName + "_Module");
}

void DeletePersistantLocalMetalocation(object oCreature, string sName)
{
    // Persistant operations fail on non-creatures.
    if(GetObjectType(oCreature) != OBJECT_TYPE_CREATURE) return;

    DeletePersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaTag");
    //DeletePersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaResRef");
    DeletePersistantLocalString(oCreature, "Metalocation_" + sName + "_AreaName");
    DeletePersistantLocalInt   (oCreature, "Metalocation_" + sName + "_AreaHeight");
    DeletePersistantLocalInt   (oCreature, "Metalocation_" + sName + "_AreaWidth");
    DeletePersistantLocalFloat (oCreature, "Metalocation_" + sName + "_X");
    DeletePersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Y");
    DeletePersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Z");
    DeletePersistantLocalFloat (oCreature, "Metalocation_" + sName + "_Facing");
    DeletePersistantLocalString(oCreature, "Metalocation_" + sName + "_Name");
    DeletePersistantLocalString(oCreature, "Metalocation_" + sName + "_Module");
}


/*
Map pin data:
Local int "NW_TOTAL_MAP_PINS"
 - Number of existing map pins.

Local string "NW_MAP_PIN_NRTY_#"
 - Name of the nth map pin.
 - # is string representation of the map pin's index number, base 1.

Local float "NW_MAP_PIN_XPOS_#"
 - The map pin's X coordinate in the area.
 - # is string representation of the map pin's index number, base 1.

Local float "NW_MAP_PIN_YPOS_#"
 - The map pin's Y coordinate in the area.
 - # is string representation of the map pin's index number, base 1.

Local object "NW_MAP_PIN_AREA_#"
 - Object reference to the area where the map pin is located.
 - # is string representation of the map pin's index number, base 1.
*/
void CreateMapPinFromMetalocation(struct metalocation mlocL, object oPC)
{
    if(!GetIsObjectValid(oPC))
        return;
    //check no other map pins at that location
    int nPinCount = GetNumberOfMapPins(oPC);
    int i;
    for(i=1;i<nPinCount;i++)
    {
        struct metalocation mlocTest = CreateMetalocationFromMapPin(oPC, i);
        if(mlocTest == mlocL)
            return;//duplicate detected, abort
    }
    //create that map pin
    int nID = GetLocalInt(oPC, "NW_TOTAL_MAP_PINS") + 1;
    SetLocalInt(oPC, "NW_TOTAL_MAP_PINS", nID);
    SetLocalString(oPC, "NW_MAP_PIN_NRTY_" + IntToString(nID), mlocL.sName);
    SetLocalFloat( oPC, "NW_MAP_PIN_XPOS_" + IntToString(nID), mlocL.fX);
    SetLocalFloat( oPC, "NW_MAP_PIN_YPOS_" + IntToString(nID), mlocL.fY);
    SetLocalObject(oPC, "NW_MAP_PIN_AREA_" + IntToString(nID), GetAreaFromLocation(MetalocationToLocation(mlocL)));
}

struct metalocation CreateMetalocationFromMapPin(object oPC, int nPinNo)
{
    //sanity checks
    if(!GetIsObjectValid(oPC))
        return GetNullMetalocation();
    if(nPinNo < 1)
        return GetNullMetalocation();
    int nPinCount = GetNumberOfMapPins(oPC);
    if(nPinCount < 1)
        return GetNullMetalocation();
    if(nPinCount < nPinNo)
        return GetNullMetalocation();
    //variables
    struct metalocation mlocReturn;
    string sID = IntToString(nPinNo);
    location lLoc;
    object oArea = GetLocalObject(oPC,"NW_MAP_PIN_AREA_"+sID);
    float  fX    = GetLocalFloat( oPC,"NW_MAP_PIN_XPOS_"+sID);
    float  fY    = GetLocalFloat( oPC,"NW_MAP_PIN_YPOS_"+sID);
    string sName = GetLocalString(oPC,"NW_MAP_PIN_NRTY_"+sID);
    lLoc = Location(oArea, Vector(fX, fY, 0.0), 0.0);
    mlocReturn = LocationToMetalocation(lLoc, sName);
    return mlocReturn;
}

int GetNumberOfMapPins(object oPC)
{
    return GetLocalInt(oPC, "NW_TOTAL_MAP_PINS");
}

object GetAreaOfMapPin(object oPC, int nPinNo)
{
    return GetLocalObject(oPC, "NW_MAP_PIN_AREA_"+IntToString(nPinNo));
}

void DeleteMapPin(object oPC, int nPinNo)
{
    //sanity checks
    if(nPinNo < 1)
        return;
    if(!GetIsObjectValid(oPC))
        return;
    int nPinCount = GetNumberOfMapPins(oPC);
    if(nPinCount < 1)
        return;
    if(nPinCount < nPinNo)
        return;
    //delete the pin
    DeleteLocalString(oPC, "NW_MAP_PIN_NRTY_"+IntToString(nPinNo));
    DeleteLocalFloat( oPC, "NW_MAP_PIN_XPOS_"+IntToString(nPinNo));
    DeleteLocalFloat( oPC, "NW_MAP_PIN_YPOS_"+IntToString(nPinNo));
    DeleteLocalObject(oPC, "NW_MAP_PIN_AREA_"+IntToString(nPinNo));
    //move the other ones up
    int i = nPinNo+1;
    for (i=nPinNo+1;i<nPinCount;i++)
    {
        SetLocalString(oPC, "NW_MAP_PIN_NRTY_"+IntToString(i), GetLocalString(oPC, "NW_MAP_PIN_NRTY_"+IntToString(i+1)));
        SetLocalFloat( oPC, "NW_MAP_PIN_XPOS_"+IntToString(i), GetLocalFloat (oPC, "NW_MAP_PIN_XPOS_"+IntToString(i+1)));
        SetLocalFloat( oPC, "NW_MAP_PIN_YPOS_"+IntToString(i), GetLocalFloat (oPC, "NW_MAP_PIN_YPOS_"+IntToString(i+1)));
        SetLocalObject(oPC, "NW_MAP_PIN_AREA_"+IntToString(i), GetLocalObject(oPC, "NW_MAP_PIN_AREA_"+IntToString(i+1)));
    }
    //delete the last pin, since the list is shorter now
    DeleteLocalString(oPC, "NW_MAP_PIN_NRTY_"+IntToString(nPinCount));
    DeleteLocalFloat( oPC, "NW_MAP_PIN_XPOS_"+IntToString(nPinCount));
    DeleteLocalFloat( oPC, "NW_MAP_PIN_YPOS_"+IntToString(nPinCount));
    DeleteLocalObject(oPC, "NW_MAP_PIN_AREA_"+IntToString(nPinCount));
    //fix the overall count
    SetLocalInt(oPC, "NW_TOTAL_MAP_PINS", nPinCount-1);
}


struct metalocation GetNullMetalocation()
{
    struct metalocation mlocL;
    mlocL.sAreaTag    = "";
    //mlocL.sAreaResRef = "";
    mlocL.sAreaName   = "";
    mlocL.nAreaHeight = 0;
    mlocL.nAreaWidth  = 0;
    mlocL.fX          = 0.0f;
    mlocL.fY          = 0.0f;
    mlocL.fZ          = 0.0f;
    mlocL.fFacing     = 0.0f;
    mlocL.sName       = "";
    mlocL.sModule     = "";
    return mlocL;
}

int GetIsMetalocationValid(struct metalocation mlocL)
{
/*    SendMessageToPC(GetFirstPC(), "mlocL.sAreaTag " + IntToString(mlocL.sAreaTag    != ""));
    SendMessageToPC(GetFirstPC(), "mlocL.sAreaResRef " + IntToString(mlocL.sAreaResRef != ""));
    SendMessageToPC(GetFirstPC(), "mlocL.sModule " + IntToString(mlocL.sModule     != ""));
    SendMessageToPC(GetFirstPC(), "GetIsMetalocationInModule(mlocL): " + IntToString(GetIsMetalocationInModule(mlocL)));
*/
    return mlocL.sAreaTag    != ""   &&
//           mlocL.sAreaResRef != ""   &&
           mlocL.sAreaName   != ""   &&
           mlocL.nAreaWidth  != 0    &&
           mlocL.nAreaHeight != 0    &&
           mlocL.sModule     != ""   &&
           GetIsMetalocationInModule(mlocL);
}


string MetalocationToString(struct metalocation mlocL)
{
    object oArea = GetAreaFromMetalocation(mlocL);
    return mlocL.sName + " - " + GetName(oArea)
            + " (" + IntToString(FloatToInt(mlocL.fX)) + ", " + IntToString(FloatToInt(mlocL.fY)) + ", " + IntToString(FloatToInt(mlocL.fZ)) + ")"
            + ((GetIsAreaNatural(oArea) && !GetIsAreaInterior(oArea)) ? "<c þ >*</c>": "")
            + (GetIsMetalocationInModule(mlocL) ? "" : (" " + GetStringByStrRef(16825269)/*" Not in module "*/));
}

//void main(){} // Test main
