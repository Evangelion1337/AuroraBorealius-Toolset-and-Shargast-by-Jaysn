//:://////////////////////////////////////////////
//:: General utility functions
//:: inc_utility
//:://////////////////////////////////////////////
/** @file
    An include file for various small and generally
    useful functions.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


/**********************\
* Constant Definitions *
\**********************/

const int ARMOR_TYPE_CLOTH      = 0;
const int ARMOR_TYPE_LIGHT      = 1;
const int ARMOR_TYPE_MEDIUM     = 2;
const int ARMOR_TYPE_HEAVY      = 3;

const int ACTION_USE_ITEM_TMI_LIMIT = 1500;

/*********************\
* Function Prototypes *
\*********************/

/**
 * Returns the greater of the two values passed to it.
 *
 * @param a An integer
 * @param b Another integer
 * @return  a iff a is greater than b, otherwise b
 */
int PRCMax(int a, int b);

/**
 * Returns the lesser of the two values passed to it.
 *
 * @param a An integer
 * @param b Another integer
 * @return  a iff a is lesser than b, otherwise b
 */
int PRCMin(int a, int b);

/**
 * Returns the greater of the two values passed to it.
 *
 * @param a A float
 * @param b Another float
 * @return  a iff a is greater than b, otherwise b
 */
float PRCFmax(float a, float b);

/**
 * Returns the lesser of the two values passed to it.
 *
 * @param a A float
 * @param b Another float
 * @return  a iff a is lesser than b, otherwise b
 */
float PRCFmin(float a, float b);

/**
 * Takes a string in the standard hex number format (0x####) and converts it
 * into an integer type value. Only the last 8 characters are parsed in order
 * to avoid overflows.
 * If the string is not parseable (empty or contains characters other than
 * those used in hex notation), the function errors and returns 0.
 *
 * Full credit to Axe Murderer
 *
 * @param sHex  The string to convert
 * @return      Integer value of sHex or 0 on error
 */
int HexToInt(string sHex);

/*  NOTE: the following 2 functions don't actually do what they say and
    use real time not game time. Possibly because by default, 1 in-game minute
    is 2 seconds. As real-time minutes to sec function exists (TurnsToSeconds()),
    this is possibly redundant and should be replaced.

    // Use HoursToSeconds to figure out how long a scaled minute
    // is and then calculate the number of real seconds based
    // on that.
    float scaledMinute = HoursToSeconds(1) / 60.0;
    float totalMinutes = minutes * scaledMinute;

    // Return our scaled duration, but before doing so check to make sure
    // that it is at least as long as a round / level (time scale is in
    // the module properties, it's possible a minute / level could last less
    // time than a round / level !, so make sure they get at least as much
    // time as a round / level.
    float totalRounds = RoundsToSeconds(minutes);
    float result = totalMinutes > totalRounds ? totalMinutes : totalRounds;
    return result;
*/

/**
 * Takes an int representing the number of scaled 1 minute intervals wanted
 * and converts to seconds with 1 turn = 1 minute
 * @param minutes       The number of 1 min intervals (typically caster level)
 * @return              Float of duration in seconds
 */
float MinutesToSeconds(int minutes);

/**
 * Takes an int representing the number of scaled 10 minute intervals wanted
 * and converts to seconds with 1 turn = 1 minute
 * @param tenMinutes    The number of 10 min intervals (typically caster level)
 * @return              Float of duration in seconds
 */
float TenMinutesToSeconds(int tenMinutes);

/**
 * Converts metres to feet. Moved from prc_inc_util.
 * @param fMeters   distance in metres
 * @return          float of distance in feet
 */
float MetersToFeet(float fMeters);

/**
 * Checks whether an alignment matches given restrictions.
 * For example
 * GetIsValidAlignment (ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD, 21, 3, 0 );
 * should return FALSE.
 *
 * Credit to Joe Travel
 *
 * @param iLawChaos          ALIGNMENT_* constant
 * @param iGoodEvil          ALIGNMENT_* constant
 * @param iAlignRestrict     Similar format as the restrictions in classes.2da
 * @param iAlignRstrctType   Similar format as the restrictions in classes.2da
 * @param iInvertRestriction Similar format as the restrictions in classes.2da
 *
 * @return TRUE if the alignment does not break the restrictions,
 *          FALSE otherwise.
 */
int GetIsValidAlignment( int iLawChaos, int iGoodEvil, int iAlignRestrict, int iAlignRstrctType, int iInvertRestriction );

/**
 * Gets a random location within an circular area around a base location.
 *
 * by Mixcoatl
 * download from
 * http://nwvault.ign.com/Files/scripts/data/1065075424375.shtml
 *
 * @param lBase     The center of the circle.
 * @param fDistance The radius of the circle. ie, the maximum distance the
 *                  new location may be from lBase.
 *
 * @return          A location in random direction from lBase between
 *                  0 and fDistance meters away.
 */
location GetRandomCircleLocation(location lBase, float fDistance=1.0);

/**
 * Gets a location relative to the first location
 * Includes rotating additional location based on facing of the first
 *
 * @param lMaster   The starting location
 * @param lAdd      The location to add
 *
 * @return          A location in random direction from lBase between
 *                  0 and fDistance meters away.
 */
location AddLocationToLocation(location lMaster, location lAdd);

/**
 * Genji Include Color gen_inc_color
 * first: 1-4-03
 * simple function to use the name of a item holding escape sequences that, though they will not compile,
 * they can be interpreted at run time and produce rbg scales between 32 and 255 in increments.
 * -- allows 3375 colors to be made.
 * for example SendMessageToPC(pc,PRCGetRGB(15,15,1)+ "Help, I'm on fire!") will produce yellow text.
 * more examples:
 *
 *  PRCGetRGB() := WHITE // no parameters, default is white
 *  PRCGetRGB(15,15,1):= YELLOW
 *  PRCGetRGB(15,5,1) := ORANGE
 *  PRCGetRGB(15,1,1) := RED
 *  PRCGetRGB(7,7,15) := BLUE
 *  PRCGetRGB(1,15,1) := NEON GREEN
 *  PRCGetRGB(1,11,1) := GREEN
 *  PRCGetRGB(9,6,1)  := BROWN
 *  PRCGetRGB(11,9,11):= LIGHT PURPLE
 *  PRCGetRGB(12,10,7):= TAN
 *  PRCGetRGB(8,1,8)  := PURPLE
 *  PRCGetRGB(13,9,13):= PLUM
 *  PRCGetRGB(1,7,7)  := TEAL
 *  PRCGetRGB(1,15,15):= CYAN
 *  PRCGetRGB(1,1,15) := BRIGHT BLUE
 *
 * issues? contact genji@thegenji.com
 * special thanks to ADAL-Miko and Rich Dersheimer in the bio forums.
 */
string PRCGetRGB(int red = 15,int green = 15,int blue = 15);

/**
 * Checks if any PCs (or optionally their NPC party members) are in the
 * given area.
 *
 * @param oArea            The area to check
 * @param bNPCPartyMembers Whether to check the PC's party members, too
 */
int GetIsAPCInArea(object oArea, int bNPCPartyMembers = TRUE);

/**
 * Converts the given integer to string as IntToString and then
 * pads the left side until it's nLength characters long. If sign
 * is specified, the first character is reserved for it, and it is
 * always present.
 * Strings longer than the given length are trunctated to their nLength
 * right characters.
 *
 * credit goes to Pherves, who posted the original in homebrew scripts forum sticky
 *
 * @param nX      The integer to convert
 * @param nLength The length of the resulting string
 * @param nSigned If this is TRUE, a sign character is inserted as the leftmost
 *                character. Doing so leaves one less character for use as a digit.
 *
 * @return        The string that results from conversion as specified above.
 */
string IntToPaddedString(int nX, int nLength = 4, int nSigned = FALSE);

/**
 * Looks through the given string, replacing all instances of sToReplace with
 * sReplacement. If such a replacement creates another instance of sToReplace,
 * it, too is replaced. Be aware that you can cause an infinite loop with
 * properly constructed parameters due to this.
 *
 * @param sString      The string to modify
 * @param sToReplace   The substring to replace
 * @param sReplacement The replacement string
 * @return             sString with all instances of sToReplace replaced
 *                     with sReplacement
 */
string ReplaceChars(string sString, string sToReplace, string sReplacement);

/**
 * A wrapper for DestroyObject(). Attempts to bypass any
 * conditions that might prevent destroying the object.
 *
 * WARNING: This will destroy any object that can at all be
 *          destroyed by DestroyObject(). In other words, you
 *          can clobber critical bits with careless use.
 *          Only the module, PCs and areas are unaffected. Using this
 *          function on any of those will cause an infinite
 *          DelayCommand loop that will eat up resources, though.
 *
 *
 * @param oObject The object to destroy
 */
void MyDestroyObject(object oObject);

/**
 * Checks to see if oPC has an item created by sResRef in his/her/it's inventory
 *
 * @param oPC     The creature whose inventory to search.
 * @param sResRef The resref to look for in oPC's items.
 * @return        TRUE if any items matching sResRef were found, FALSE otherwise.
 */
int GetHasItem(object oPC, string sResRef);

/**
 * Calculates the base AC of the given armor.
 *
 * @param oArmor  An item of type BASE_ITEM_ARMOR
 * @return        The base AC of oArmor, or -1 on error
 */
int GetItemACBase(object oArmor);

/**
 * Gets the type of the given armor based on it's base AC.
 *
 * @param oArmor  An item of type BASE_ITEM_ARMOR
 * @return        ARMOR_TYPE_* constant of the armor, or -1 on error
 */
int GetArmorType(object oArmor);

/**
 * Calculates the number of steps along both moral and ethical axes that
 * the two target's alignments' differ.
 *
 * @param oSource A creature
 * @param oTarget Another creature
 * @return        The number of steps the target's alignment differs
 */
int CompareAlignment(object oSource, object oTarget);

/**
 * Repeatedly assigns an equipping action to equip the given item until
 * it is equipped. Used for getting around the fact that a player can
 * cancel the action. They will give up eventually :D
 *
 * WARNING: Note that forcing an equip into offhand when mainhand is empty
 * will result in an infinite loop. So will attempting to equip an item
 * into a slot it can't be equipped in.
 *
 * @param oPC     The creature to do the equipping.
 * @param oItem   The item to equip.
 * @param nSlot   INVENTORY_SLOT_* constant of the slot to equip into.
 * @param nThCall Internal parameter, leave as default. This determines
 *                how many times ForceEquip has called itself.
 */
void ForceEquip(object oPC, object oItem, int nSlot, int nThCall = 0);

/**
 * Repeatedly attempts to unequip the given item until it is no longer
 * in the slot given. Used for getting around the fact that a player can
 * cancel the action. They will give up eventually :D
 *
 * @param oPC     The creature to do the unequipping.
 * @param oItem   The item to unequip.
 * @param nSlot   INVENTORY_SLOT_* constant of the slot containing oItem.
 * @param nThCall Internal parameter, leave as default. This determines
 *                how many times ForceUnequip has called itself.
 */
void ForceUnequip(object oPC, object oItem, int nSlot, int nThCall = 0);

/**
 * Checks either of the given creature's hand slots are empty.
 *
 * @param oCreature Creature whose hand slots to check
 * @return          TRUE if either hand slot is empty, FALSE otherwise
 */
int GetHasFreeHand(object oCreature);

/**
 * Determines whether the creature is encumbered by it's carried items.
 *
 * @param oCreature Creature whose encumberment to determine
 * @return          TRUE if the creature is encumbered, FALSE otherwise
 */
int GetIsEncumbered(object oCreature);

/**
 * Try to identify all unidentified objects within the given creature's inventory
 * using it's skill ranks in lore.
 *
 * @param oPC The creature whose items to identify
 */
void TryToIDItems(object oPC = OBJECT_SELF);

/**
 * Converts a boolean to a string.
 *
 * @param bool The boolean value to convert. 0 is considered false
 *             and everything else is true.
 * @param bTLK Whether to use english strings or get the values from
 *             the TLK. If TRUE, the return values are retrieved
 *             from TLK indices 8141 and 8142. If FALSE, return values
 *             are either "True" or "False".
 *             Defaults to FALSE.
 * @see DebugBool2String() in inc_debug for debug print purposes
 */
string BooleanToString(int bool, int bTLK = FALSE);

/**
 * Returns a copy of the string, with leading and trailing whitespace omitted.
 *
 * @param s The string to trim.
 */
string PRCTrimString(string s);

/**
 * Compares the given two strings lexicographically.
 * Returns -1 if the first string precedes the second.
 * Returns 0 if the strings are equal
 * Returns 1 if the first string follows the second.
 *
 * Examples:
 *
 * StringCompare("a", "a") = 0
 * StringCompare("a", "b") = -1
 * StringCompare("b", "a") = 1
 * StringCompare("a", "1") = 1
 * StringCompare("A", "a") = -1
 * StringCompare("Aa", "A") = 1
 */
int StringCompare(string s1, string s2);

/**
 * Finds first occurrence of string sFind
 * in string sString and replaces it with
 * sReplace and returns the result.
 * If sFind is not found, sString is returned.
 *
 * Examples:
 *
 * StringCompare("aabb", "a", "y") = "yabb"
 * StringCompare("aabb", "x", "y") = "aabb"
 */
string ReplaceString(string sString, string sFind, string sReplace);

/**
 * Determines the angle between two given locations. Angle returned
 * is relative to the first location.
 *
 * @param lFrom The base location
 * @param lTo   The other location
 * @return      The angle between the two locations, relative to lFrom
 */
float GetRelativeAngleBetweenLocations(location lFrom, location lTo);

/**
 * Returns the same string you would get if you examined the item in-game
 * Uses 2da & tlk lookups and should work for custom itemproperties too
 *
 * @param ipTest Itemproperty you want to get the string of
 *
 * @return       A string of the itemproperty, including spaces and bracket where appropriate
 */
string ItemPropertyToString(itemproperty ipTest);


/**
 * Tests if a creature can burn the amount of XP specified without loosing a level
 *
 * @param oPC   Creature to test, can be an NPC or a PC
 * @param nCost Amount of XP to chck for
 *
 * @return       TRUE/FALSE
 */
int GetHasXPToSpend(object oPC, int nCost);


/**
 * Removes an amount of XP via SetXP()
 *
 * @param oPC   Creature to remove XP from, can be an NPC or a PC
 * @param nCost Amount of XP to remove for
 */
void SpendXP(object oPC, int nCost);


/**
 * Tests if a creature can burn the amount of Gold specified
 *
 * @param oPC   Creature to test, can be an NPC or a PC
 * @param nCost Amount of Gold to chck for
 *
 * @return       TRUE/FALSE
 */
int GetHasGPToSpend(object oPC, int nCost);


/**
 * Removes an amount of Gold
 *
 * @param oPC   Creature to remove Gold from, can be an NPC or a PC
 * @param nCost Amount of Gold to remove for
 */
void SpendGP(object oPC, int nCost);

/*
 *  Convinence function for testing off-hand weapons
 */
int isNotShield(object oItem);

/**
 * Makes self use a specific itemproperty on an object
 *
 * Note: This uses a loop so vulnerable to TMI errors
 * Note: This is not 100% reliable, for example if uses/day finished
 * Note: Uses talent system. Unsure what would happen if the creature
 * can cast the same spell from some other means or if they
 * had multiple items with the same spell on them
 *
 * @param oItem   Item to use
 * @param ipIP    Itemproperty to use
 * @param oTarget Target object
 */
void ActionUseItemPropertyAtObject(object oItem, itemproperty ipIP, object oTarget = OBJECT_SELF);

/**
 * Makes self use a specific itemproperty at a location
 *
 * Note: This uses a loop so vulnerable to TMI errors
 * Note: This is not 100% reliable, for example if uses/day finished
 * Note: Uses talent system. Unsure what would happen if the creature
 * can cast the same spell from some other means or if they
 * had multiple items with the same spell on them
 *
 * @param oItem   Item to use
 * @param ipIP    Itemproperty to use
 * @param lTarget Target location
 */
void ActionUseItemPropertyAtLocation(object oItem, itemproperty ipIP, location lTarget);

// Checks the target for a specific EFFECT_TYPE constant value
int PRCGetHasEffect(int nEffectType, object oTarget = OBJECT_SELF);

//Does a check to determine if the NPC has an attempted
//spell or attack target
int PRCGetIsFighting(object oFighting = OBJECT_SELF);

// Returns TRUE if the player is polymorphed.
int GetIsPolyMorphedOrShifted(object oCreature);

/**
 * Gets a random delay based on the parameters passed in.
 *
 * @author              Bioware (GetRandomDelay() from nw_i0_spells)
 *
 * @param fMinimumTime  lower limit for the random time
 * @param fMaximumTime  upper limit for the random time
 *
 * @return              random float between the limits given
 */
float PRCGetRandomDelay(float fMinimumTime = 0.4, float fMaximumTime = 1.1);

//this is here rather than inc_utility because it uses creature size and screws compiling if its elsewhere
/**
 * Returns the skill rank adjusted according to the given parameters.
 * Using the default values, the result is the same as using GetSkillRank().
 *
 * @param oObject     subject to get skill of
 * @param nSkill      SKILL_* constant
 * @param bSynergy    include any applicable synergy bonus
 * @param bSize       include any applicable size bonus
 * @param bAbilityMod include relevant ability modification (including effects on that ability)
 * @param bEffect     include skill changing effects and itemproperties
 * @param bArmor      include armor mod if applicable (excluding shield)
 * @param bShield     include shield mod if applicable (excluding armor)
 * @param bFeat       include any applicable feats, including racial ones
 *
 * @return            subject's rank in the given skill, modified according to
 *                    the above parameters. If the skill is trained-only and the
 *                    subject does not have any ranks in it, returns 0.
 */
int GetSkill(object oObject, int nSkill, int bSynergy = FALSE, int bSize = FALSE,
             int bAbilityMod = TRUE, int bEffect = TRUE, int bArmor = TRUE,
             int bShield = TRUE, int bFeat = TRUE);
             
/**
 * Repeatedly attempts to put down the given item until it is no longer
 * in the slot given. Used for getting around the fact that a player can
 * cancel the action. They will give up eventually :D
 *
 * @param oPC     The creature to do the putting down.
 * @param oItem   The item to put down.
 * @param nSlot   INVENTORY_SLOT_* constant of the slot containing oItem.
 * @param nThCall Internal parameter, leave as default. This determines
 *                how many times ForcePutDown has called itself.
 */
void ForcePutDown(object oPC, object oItem, int nSlot, int nThCall = 0);             

///////////////////////////////////////
/* Constant declarations             */
///////////////////////////////////////

const int ERROR_CODE_5_ONCE_MORE = -1;
const int ERROR_CODE_5_ONCE_MORE2 = -1;
const int ERROR_CODE_5_ONCE_MORE3 = -1;
const int ERROR_CODE_5_ONCE_MORE4 = -1;
const int ERROR_CODE_5_ONCE_MORE5 = -1;

//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

// The following files have no dependecies, or self-contained dependencies that do not require looping via this file
// inc_debug is available via inc_2dacache
//#include "inc_debug"

#include "prc_inc_nwscript"
#include "prc_class_const"
#include "inc_target_list"
#include "inc_logmessage"
#include "inc_threads"
#include "prc_inc_actions"
#include "inc_time"
#include "inc_draw_prc"
#include "inc_eventhook"
#include "inc_metalocation"
#include "inc_array_sort"   // Depends on prc_inc_array and inc_debug
#include "inc_uniqueid"     // Depends on prc_inc_array
#include "inc_set"          // Depends on prc_inc_array, inc_heap


/**********************\
* Function Definitions *
\**********************/

int PRCMax(int a, int b) {return (a > b ? a : b);}

int PRCMin(int a, int b) {return (a < b ? a : b);}

float PRCFmax(float a, float b) {return (a > b ? a : b);}

float PRCFmin(float a, float b) {return (a < b ? a : b);}

int HexToInt_old(string sHex)
{
    if(sHex == "") return 0;                            // Some quick optimisation for empty strings
    sHex = GetStringRight(GetStringLowerCase(sHex), 8); // Truncate to last 8 characters and convert to lowercase
    if(GetStringLeft(sHex, 2) == "0x")                  // Cut out '0x' if it's present
        sHex = GetStringRight(sHex, GetStringLength(sHex) - 2);
    string sConvert = "0123456789abcdef";               // The string to index using the characters in sHex
    int nReturn, nHalfByte;
    while(sHex != "")
    {
        nHalfByte = FindSubString(sConvert, GetStringLeft(sHex, 1)); // Get the value of the next hexadecimal character
        if(nHalfByte == -1) return 0;                                // Invalid character in the string!
        nReturn  = nReturn << 4;                                     // Rightshift by 4 bits
        nReturn |= nHalfByte;                                        // OR in the next bits
        sHex = GetStringRight(sHex, GetStringLength(sHex) - 1);      // Remove the parsed character from the string
    }

    return nReturn;
}

const string sHexDigits = "0123456789abcdef";

int HexToInt(string sHex)
{
    if(sHex == "") return 0;
    int nVal = 0;
    string sDig = GetStringLowerCase(sHex);
    int nLen = GetStringLength(sDig);
    int nIdx = 2;
    while(nIdx < nLen)
    {
        nVal = (nVal << 4) + FindSubString(sHexDigits,GetSubString(sDig,nIdx++,1));
    }
    return nVal;
}

float TenMinutesToSeconds(int tenMinutes)
{
    return TurnsToSeconds(tenMinutes) * 10;
}

float MinutesToSeconds(int minutes)
{
    return TurnsToSeconds(minutes);
}

float MetersToFeet(float fMeters)
{
     fMeters *= 3.281;
     return fMeters;
}

int GetIsValidAlignment ( int iLawChaos, int iGoodEvil,int iAlignRestrict, int iAlignRstrctType, int iInvertRestriction )
{
    //deal with no restrictions first
    if(iAlignRstrctType == 0)
        return TRUE;
    //convert the ALIGNMENT_* into powers of 2
    iLawChaos = FloatToInt(pow(2.0, IntToFloat(iLawChaos-1)));
    iGoodEvil = FloatToInt(pow(2.0, IntToFloat(iGoodEvil-1)));
    //initialise result varaibles
    int iAlignTest, iRetVal = TRUE;
    //do different test depending on what type of restriction
    if(iAlignRstrctType == 1 || iAlignRstrctType == 3)   //I.e its 1 or 3
        iAlignTest = iLawChaos;
    if(iAlignRstrctType == 2 || iAlignRstrctType == 3) //I.e its 2 or 3
        iAlignTest = iAlignTest | iGoodEvil;
    //now the real test.
    if(iAlignRestrict & iAlignTest)//bitwise AND comparison
        iRetVal = FALSE;
    //invert it if applicable
    if(iInvertRestriction)
        iRetVal = !iRetVal;
    //and return the result
    return iRetVal;
}


location GetRandomCircleLocation(location lBase, float fDistance=1.0)
{
    // Pick a random angle for the location.
    float fAngle = IntToFloat(Random(3600)) / 10.0;

    // Pick a random facing for the location.
    float fFacing = IntToFloat(Random(3600)) / 10.0;

    // Pick a random distance from the base location.
    float fHowFar = IntToFloat(Random(FloatToInt(fDistance * 10.0))) / 10.0;

    // Retreive the position vector from the location.
    vector vPosition = GetPositionFromLocation(lBase);

    // Modify the base x/y position by the distance and angle.
    vPosition.y += (sin(fAngle) * fHowFar);
    vPosition.x += (cos(fAngle) * fHowFar);

    // Return the new random location.
    return Location(GetAreaFromLocation(lBase), vPosition, fFacing);
}

location AddLocationToLocation(location lMaster, location lAdd)
{
    //firstly rotate lAdd according to lMaster
    vector vAdd = GetPositionFromLocation(lAdd);
    //zero is +y in NWN convert zero to +x
    float fAngle = GetFacingFromLocation(lMaster);
    //convert angle to radians
    fAngle = ((fAngle-90)/360.0)*2.0*PI;
    vector vNew;
    vNew.x = (vAdd.x*cos(fAngle))-(vAdd.y*sin(fAngle));
    vNew.y = (vAdd.x*sin(fAngle))+(vAdd.y*cos(fAngle));
    vNew.z = vAdd.z;

    //now just add them on
    vector vMaster = GetPositionFromLocation(lMaster);
    vNew.x += vMaster.x;
    vNew.y += vMaster.y;
    vNew.z += vMaster.z;
    float fNew = GetFacingFromLocation(lAdd)+GetFacingFromLocation(lMaster);

    //return a location
    location lReturn = Location(GetAreaFromLocation(lMaster), vNew, fNew);
    return lReturn;
}





string PRCGetRGB(int red = 15,int green = 15,int blue = 15)
{
    object coloringBook = GetObjectByTag("ColoringBook");
    if (coloringBook == OBJECT_INVALID)
        coloringBook = CreateObject(OBJECT_TYPE_ITEM,"gen_coloringbook",GetLocation(GetObjectByTag("HEARTOFCHAOS")));
    string buffer = GetName(coloringBook);
    if(red > 15) red = 15; if(green > 15) green = 15; if(blue > 15) blue = 15;
    if(red < 1)  red = 1;  if(green < 1)  green = 1;  if(blue < 1)  blue = 1;
    return "<c" + GetSubString(buffer, red - 1, 1) + GetSubString(buffer, green - 1, 1) + GetSubString(buffer, blue - 1, 1) +">";
}

int GetIsAPCInArea(object oArea, int bNPCPartyMembers = TRUE)
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if(bNPCPartyMembers)
        {
            object oFaction = GetFirstFactionMember(oPC, FALSE);
            while(GetIsObjectValid(oFaction))
            {
                if (GetArea(oFaction) == oArea)
                    return TRUE;
                oFaction = GetNextFactionMember(oPC, FALSE);
            }
        }
        oPC = GetNextPC();
    }
    return FALSE;
}

string IntToPaddedString(int nX, int nLength = 4, int nSigned = FALSE)
{
    if(nSigned)
        nLength--;//to allow for sign
    string sResult = IntToString(nX);
    // Trunctate to nLength rightmost characters
    if(GetStringLength(sResult) > nLength)
        sResult = GetStringRight(sResult, nLength);
    // Pad the left side with zero
    while(GetStringLength(sResult) < nLength)
    {
        sResult = "0" +sResult;
    }
    if(nSigned)
    {
        if(nX>=0)
            sResult = "+"+sResult;
        else
            sResult = "-"+sResult;
    }
    return sResult;
}

string ReplaceChars(string sString, string sToReplace, string sReplacement)
{
    int nInd;
    while((nInd = FindSubString(sString, sToReplace)) != -1)
    {
        sString = GetStringLeft(sString, nInd) +
                  sReplacement +
                  GetSubString(sString,
                               nInd + GetStringLength(sToReplace),
                               GetStringLength(sString) - nInd - GetStringLength(sToReplace)
                               );
    }
    return sString;
}

void MyDestroyObject(object oObject)
{
    if(GetIsObjectValid(oObject))
    {
        SetCommandable(TRUE ,oObject);
        AssignCommand(oObject, ClearAllActions());
        AssignCommand(oObject, SetIsDestroyable(TRUE, FALSE, FALSE));
        AssignCommand(oObject, DestroyObject(oObject));
        // May not necessarily work on first iteration
        DestroyObject(oObject);
        DelayCommand(0.1f, MyDestroyObject(oObject));
    }
}

int GetHasItem(object oPC, string sResRef)
{
    object oItem = GetFirstItemInInventory(oPC);

    while(GetIsObjectValid(oItem) && GetResRef(oItem) != sResRef)
        oItem = GetNextItemInInventory(oPC);

    return GetResRef(oItem) == sResRef;
}

int GetItemACBase(object oArmor)
{
    int nBonusAC = 0;

    // oItem is not armor then return an error
    if(GetBaseItemType(oArmor) != BASE_ITEM_ARMOR)
        return -1;

    // check each itemproperty for AC Bonus
    itemproperty ipAC = GetFirstItemProperty(oArmor);

    while(GetIsItemPropertyValid(ipAC))
    {
        int nType = GetItemPropertyType(ipAC);

        // check for ITEM_PROPERTY_AC_BONUS
        if(nType == ITEM_PROPERTY_AC_BONUS)
        {
            nBonusAC = GetItemPropertyCostTableValue(ipAC);
            break;
        }

        // get next itemproperty
        ipAC = GetNextItemProperty(oArmor);
    }

    // return base AC
    return GetItemACValue(oArmor) - nBonusAC;
}

// returns -1 on error, or the const int ARMOR_TYPE_*
int GetArmorType(object oArmor)
{
    int nType = -1;

    // get and check Base AC
    switch(GetItemACBase(oArmor) )
    {
        case 0: nType = ARMOR_TYPE_CLOTH;   break;
        case 1: nType = ARMOR_TYPE_LIGHT;   break;
        case 2: nType = ARMOR_TYPE_LIGHT;   break;
        case 3: nType = ARMOR_TYPE_LIGHT;   break;
        case 4: nType = ARMOR_TYPE_MEDIUM;  break;
        case 5: nType = ARMOR_TYPE_MEDIUM;  break;
        case 6: nType = ARMOR_TYPE_HEAVY;   break;
        case 7: nType = ARMOR_TYPE_HEAVY;   break;
        case 8: nType = ARMOR_TYPE_HEAVY;   break;
    }

    // return type
    return nType;
}

int CompareAlignment(object oSource, object oTarget)
{
    int iStepDif;
    int iGE1 = GetAlignmentGoodEvil(oSource);
    int iLC1 = GetAlignmentLawChaos(oSource);
    int iGE2 = GetAlignmentGoodEvil(oTarget);
    int iLC2 = GetAlignmentLawChaos(oTarget);

    if(iGE1 == ALIGNMENT_GOOD){
        if(iGE2 == ALIGNMENT_NEUTRAL)
            iStepDif += 1;
        else if(iGE2 == ALIGNMENT_EVIL)
            iStepDif += 2;
    }
    else if(iGE1 == ALIGNMENT_NEUTRAL){
        if(iGE2 != ALIGNMENT_NEUTRAL)
            iStepDif += 1;
    }
    else if(iGE1 == ALIGNMENT_EVIL){
        if(iLC2 == ALIGNMENT_NEUTRAL)
            iStepDif += 1;
        else if(iLC2 == ALIGNMENT_GOOD)
            iStepDif += 2;
    }
    if(iLC1 == ALIGNMENT_LAWFUL){
        if(iLC2 == ALIGNMENT_NEUTRAL)
            iStepDif += 1;
        else if(iLC2 == ALIGNMENT_CHAOTIC)
            iStepDif += 2;
    }
    else if(iLC1 == ALIGNMENT_NEUTRAL){
        if(iLC2 != ALIGNMENT_NEUTRAL)
            iStepDif += 1;
    }
    else if(iLC1 == ALIGNMENT_CHAOTIC){
        if(iLC2 == ALIGNMENT_NEUTRAL)
            iStepDif += 1;
        else if(iLC2 == ALIGNMENT_LAWFUL)
            iStepDif += 2;
    }
    return iStepDif;
}

void ForceEquip(object oPC, object oItem, int nSlot, int nThCall = 0)
{
    // Sanity checks
    // Make sure the parameters are valid
    if(!GetIsObjectValid(oPC)) return;
    if(!GetIsObjectValid(oItem)) return;
    // Make sure that the object we are attempting equipping is the latest one to be ForceEquipped into this slot
    if(GetIsObjectValid(GetLocalObject(oPC, "ForceEquipToSlot_" + IntToString(nSlot)))
        &&
       GetLocalObject(oPC, "ForceEquipToSlot_" + IntToString(nSlot)) != oItem
       )
        return;
    // Fail on non-commandable NPCs after ~1min
    if(!GetIsPC(oPC) && !GetCommandable(oPC) && nThCall > 60)
    {
        WriteTimestampedLogEntry("ForceEquip() failed on non-commandable NPC: " + DebugObject2Str(oPC) + " for item: " + DebugObject2Str(oItem));
        return;
    }

    float fDelay;

    // Check if the equipping has already happened
    if(GetItemInSlot(nSlot, oPC) != oItem)
    {
        // Test and increment the control counter
        if(nThCall++ == 0)
        {
            // First, try to do the equipping non-intrusively and give the target a reasonable amount of time to do it
            AssignCommand(oPC, ActionEquipItem(oItem, nSlot));
            fDelay = 1.0f;

            // Store the item to be equipped in a local variable to prevent contest between two different calls to ForceEquip
            SetLocalObject(oPC, "ForceEquipToSlot_" + IntToString(nSlot), oItem);
        }
        else
        {
            // Nuke the target's action queue. This should result in "immediate" equipping of the item
            if(GetIsPC(oPC) || nThCall > 5) // Skip nuking NPC action queue at first, since that can cause problems. 5 = magic number here. May need adjustment
            {
                AssignCommand(oPC, ClearAllActions());
                AssignCommand(oPC, ActionEquipItem(oItem, nSlot));
            }
            // Use a lenghtening delay in order to attempt handling lag and possible other interference. From 0.1s to 1s
            fDelay = PRCMin(nThCall, 10) / 10.0f;
        }

        // Loop
        DelayCommand(fDelay, ForceEquip(oPC, oItem, nSlot, nThCall));
    }
    // It has, so clean up
    else
        DeleteLocalObject(oPC, "ForceEquipToSlot_" + IntToString(nSlot));
}

void ForceUnequip(object oPC, object oItem, int nSlot, int nThCall = 0)
{
    // Sanity checks
    if(!GetIsObjectValid(oPC)) return;
    if(!GetIsObjectValid(oItem)) return;
    // Fail on non-commandable NPCs after ~1min
    if(!GetIsPC(oPC) && !GetCommandable(oPC) && nThCall > 60)
    {
        WriteTimestampedLogEntry("ForceUnequip() failed on non-commandable NPC: " + DebugObject2Str(oPC) + " for item: " + DebugObject2Str(oItem));
        return;
    }

    float fDelay;

    // Delay the first unequipping call to avoid a bug that occurs when an object that was just equipped is unequipped right away
    // - The item is not unequipped properly, leaving some of it's effects in the creature's stats and on it's model.
    if(nThCall == 0)
    {
        //DelayCommand(0.5, ForceUnequip(oPC, oItem, nSlot, FALSE));
        fDelay = 0.5;
    }
    else if(GetItemInSlot(nSlot, oPC) == oItem)
    {
        // Attempt to avoid interference by not clearing actions before the first attempt
        if(nThCall > 1)
            if(GetIsPC(oPC) || nThCall > 5) // Skip nuking NPC action queue at first, since that can cause problems. 5 = magic number here. May need adjustment
                AssignCommand(oPC, ClearAllActions());

        AssignCommand(oPC, ActionUnequipItem(oItem));

        // Ramp up the delay if the action is not getting through. Might let whatever is intefering finish
        fDelay = PRCMin(nThCall, 10) / 10.0f;
    }
    // The item has already been unequipped
    else
        return;

    // Loop
    DelayCommand(fDelay, ForceUnequip(oPC, oItem, nSlot, ++nThCall));
}

int GetHasFreeHand(object oCreature)
{
    return !GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature))
         || !GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature));
}

int GetIsEncumbered(object oCreature)
{
    int iStrength = GetAbilityScore(oCreature, ABILITY_STRENGTH);
    if(iStrength > 50)
        return FALSE; // encumbrance.2da doesn't go that high, so automatic success

    return GetWeight(oCreature) > StringToInt(Get2DACache("encumbrance", "Normal", iStrength));
}

void TryToIDItems(object oPC = OBJECT_SELF)
{
    int nGP;
    string sMax = Get2DACache("SkillVsItemCost", "DeviceCostMax", GetSkillRank(SKILL_LORE, oPC));
    int nMax = StringToInt(sMax);
    if (sMax == "") nMax = 120000000;
    object oItem = GetFirstItemInInventory(oPC);
    while(GetIsObjectValid(oItem))
    {
        if(!GetIdentified(oItem))
        {
            // Check for the value of the item first.
            SetIdentified(oItem, TRUE);
            nGP = GetGoldPieceValue(oItem);
            // If oPC has enough Lore skill to ID the item, then do so.
            if(nMax >= nGP)
                SendMessageToPC(oPC, GetStringByStrRef(16826224) + " " + GetName(oItem) + " " + GetStringByStrRef(16826225));
            else
                SetIdentified(oItem, FALSE);
        }
        oItem = GetNextItemInInventory(oPC);
    }
}

string BooleanToString(int bool, int bTLK = FALSE)
{
    return bTLK ?
            (bool ? GetStringByStrRef(8141) : GetStringByStrRef(8142)):
            (bool ? "True" : "False");
}

string PRCTrimString(string s)
{
    int nCrop = 0;
    string temp;
    // Find end of the leading whitespace
    while(TRUE)
    {
        // Get the next character in the string, starting from the beginning
        temp = GetSubString(s, nCrop, 1);
        if(temp == " "  || // Space
           temp == "\n")   // Line break
            nCrop++;
        else
            break;
    }
    // Crop the leading whitespace
    s = GetSubString(s, nCrop, GetStringLength(s) - nCrop);

    // Find the beginning of the trailing whitespace
    nCrop = 0;
    while(TRUE)
    {
        // Get the previous character in the string, starting from the end
        temp = GetSubString(s, GetStringLength(s) - 1 - nCrop, 1);
        if(temp == " "  || // Space
           temp == "\n")   // Line break
            nCrop++;
        else
            break;
    }
    // Crop the trailing whitespace
    s = GetSubString(s, 0, GetStringLength(s) - nCrop);

    return s;
}

int GetFirstCharacterIndex(string s1)
{
    object oLookup = GetWaypointByTag("prc_str_lookup");
    if(!GetIsObjectValid(oLookup))
        oLookup = CreateObject(OBJECT_TYPE_WAYPOINT, "prc_str_lookup", GetLocation(GetObjectByTag("HEARTOFCHAOS")));

    return GetLocalInt(oLookup, GetStringUpperCase(GetSubString(s1, 0, 1)));
}

int StringCompare(string s1, string s2)
{
    object oLookup = GetWaypointByTag("prc_str_lookup");
    if(!GetIsObjectValid(oLookup))
        oLookup = CreateObject(OBJECT_TYPE_WAYPOINT, "prc_str_lookup", GetLocation(GetObjectByTag("HEARTOFCHAOS")));

    // Start comparing
    int nT,
        i = 0,
        nMax = PRCMin(GetStringLength(s1), GetStringLength(s2));
    while(i < nMax)
    {
        // Get the difference between the values of i:th characters
        nT = GetLocalInt(oLookup, GetSubString(s1, i, 1)) - GetLocalInt(oLookup, GetSubString(s2, i, 1));
        i++;
        if(nT < 0)
            return -1;
        if(nT == 0)
            continue;
        if(nT > 0)
            return 1;
    }

    // The strings have the same base. Of such, the shorter precedes
    nT = GetStringLength(s1) - GetStringLength(s2);
    if(nT < 0)
        return -1;
    if(nT > 0)
        return 1;

    // The strings were equal
    return 0;
}

string ReplaceString(string sString, string sFind, string sReplace)
{
    int n = FindSubString(sString, sFind);
    if(n!=-1)
        return GetStringLeft(sString, n) + sReplace + GetStringRight(sString, GetStringLength(sString) - GetStringLength(sFind) - n);
    else
        return sString;
}

float GetRelativeAngleBetweenLocations(location lFrom, location lTo)
{
    vector vPos1 = GetPositionFromLocation(lFrom);
    vector vPos2 = GetPositionFromLocation(lTo);
    //sanity check
    if(GetDistanceBetweenLocations(lFrom, lTo) == 0.0)
        return 0.0;

    float fAngle = acos((vPos2.x - vPos1.x) / GetDistanceBetweenLocations(lFrom, lTo));
    // The above formula only returns values [0, 180], so test for negative y movement
    if((vPos2.y - vPos1.y) < 0.0f)
        fAngle = 360.0f -fAngle;

    return fAngle;
}

string ItemPropertyToString(itemproperty ipTest)
{
    int nIPType = GetItemPropertyType(ipTest);
    string sName = GetStringByStrRef(StringToInt(Get2DACache("itempropdef", "GameStrRef", nIPType)));
    if(GetItemPropertySubType(ipTest) != -1)//nosubtypes
    {
        string sSubTypeResRef =Get2DACache("itempropdef", "SubTypeResRef", nIPType);
        int nTlk = StringToInt(Get2DACache(sSubTypeResRef, "Name", GetItemPropertySubType(ipTest)));
        if(nTlk > 0)
            sName += " "+GetStringByStrRef(nTlk);
    }
    if(GetItemPropertyParam1(ipTest) != -1)
    {
        string sParamResRef =Get2DACache("iprp_paramtable", "TableResRef", GetItemPropertyParam1(ipTest));
        if(Get2DACache("itempropdef", "SubTypeResRef", nIPType) != ""
            && Get2DACache(Get2DACache("itempropdef", "SubTypeResRef", nIPType), "TableResRef", GetItemPropertyParam1(ipTest)) != "")
            sParamResRef =Get2DACache(Get2DACache("itempropdef", "SubTypeResRef", nIPType), "TableResRef", GetItemPropertyParam1(ipTest));
        int nTlk = StringToInt(Get2DACache(sParamResRef, "Name", GetItemPropertyParam1Value(ipTest)));
        if(nTlk > 0)
            sName += " "+GetStringByStrRef(nTlk);
    }
    if(GetItemPropertyCostTable(ipTest) != -1)
    {
        string sCostResRef =Get2DACache("iprp_costtable", "Name", GetItemPropertyCostTable(ipTest));
        int nTlk = StringToInt(Get2DACache(sCostResRef, "Name", GetItemPropertyCostTableValue(ipTest)));
        if(nTlk > 0)
            sName += " "+GetStringByStrRef(nTlk);
    }
    return sName;
}

//Check for XP
int GetHasXPToSpend(object oPC, int nCost)
{
    // To be TRUE, make sure that oPC wouldn't lose a level by spending nCost.
    int nHitDice = GetHitDice(oPC);
    int nHitDiceXP = (500 * nHitDice * (nHitDice - 1)); // simplification of the sum
    //get current XP
    int nXP = GetXP(oPC);
    if(!nXP)
        nXP = GetLocalInt(oPC, "NPC_XP");
    //the test
    if (nXP >= (nHitDiceXP + nCost))
        return TRUE;
    return FALSE;
}

//Spend XP
void SpendXP(object oPC, int nCost)
{
    if(nCost > 0)
    {
        if(GetXP(oPC))
            SetXP(oPC, GetXP(oPC) - nCost);
        else if(GetLocalInt(oPC, "NPC_XP"))
            SetLocalInt(oPC, "NPC_XP", GetLocalInt(oPC, "NPC_XP")-nCost);
    }
}

//Check for GP
int GetHasGPToSpend(object oPC, int nCost)
{
    //if its a NPC, get master
    while(!GetIsPC(oPC)
        && GetIsObjectValid(GetMaster(oPC)))
    {
        oPC = GetMaster(oPC);
    }
    //test if it has gold
    if(GetIsPC(oPC))
    {
        return GetGold(oPC) >= nCost;
    }
    //NPC in NPC faction
    //cannot posses gold
    return FALSE;
}

//Spend GP
void SpendGP(object oPC, int nCost)
{
    if(nCost > 0)
    {
        //if its a NPC, get master
        while(!GetIsPC(oPC)
            && GetIsObjectValid(GetMaster(oPC)))
        {
            oPC = GetMaster(oPC);
        }
        TakeGoldFromCreature(nCost, oPC, TRUE);
    }
}



int isNotShield(object oItem)
{
    int iType = GetBaseItemType(oItem);

    return !(iType == BASE_ITEM_LARGESHIELD
           || iType == BASE_ITEM_TOWERSHIELD
           || iType == BASE_ITEM_SMALLSHIELD
           // Added torches to the check as they should not count either
           || iType == BASE_ITEM_TORCH);
}


void ActionUseItemPropertyAtObject(object oItem, itemproperty ipIP, object oTarget = OBJECT_SELF)
{
    int nIPSpellID = GetItemPropertySubType(ipIP);
    string sSpellID = Get2DACache("iprp_spells", "SpellIndex", nIPSpellID);
    int nSpellID = StringToInt(sSpellID);
    string sCategory = Get2DACache("spells", "Category", nSpellID);
    int nCategory = StringToInt(sCategory);
    int nCategoryPotionRandom = FALSE;
    //potions are strange
    //seem to be hardcoded to certain categories
    if(GetBaseItemType(oItem) == BASE_ITEM_POTIONS)
    {
        //potions are self-only
        if(oTarget != OBJECT_SELF)
            return;

        if(nCategory == TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT
            || nCategory == TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH)
            nCategory = TALENT_CATEGORY_BENEFICIAL_HEALING_POTION;
        else if(nCategory == TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_AREAEFFECT
            || nCategory == TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE)
            nCategory = TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_POTION;
        else if(nCategory == TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT
            || nCategory == TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE
            || nCategory == TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SELF)
            nCategory = TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_POTION;
        else if(nCategory == TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF
            || nCategory == TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE
            || nCategory == TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT)
            nCategory = TALENT_CATEGORY_BENEFICIAL_PROTECTION_POTION;
        else
        {
            //something odd here add strage randomized coding inside the loop
            nCategoryPotionRandom = TRUE;
            nCategory = TALENT_CATEGORY_BENEFICIAL_HEALING_POTION;
        }

    }

    talent tItem;
    tItem = GetCreatureTalentRandom(nCategory);
    int nCount = 0;
    while(GetIsTalentValid(tItem)
        && nCount < ACTION_USE_ITEM_TMI_LIMIT) //this is the TMI limiting thing, change as appropriate
    {
        if(nCategoryPotionRandom)
        {
            switch(d4())
            {
                default:
                case 1: nCategory = TALENT_CATEGORY_BENEFICIAL_HEALING_POTION; break;
                case 2: nCategory = TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_POTION; break;
                case 3: nCategory = TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_POTION; break;
                case 4: nCategory = TALENT_CATEGORY_BENEFICIAL_PROTECTION_POTION; break;
            }
        }

        if(GetTypeFromTalent(tItem) == TALENT_TYPE_SPELL
            && GetIdFromTalent(tItem) == nSpellID)
        {
            ActionUseTalentOnObject(tItem, oTarget);
            //end while loop
            return;
        }
        nCount++;
        tItem = GetCreatureTalentRandom(nCategory);
    }
    //if you got to this point, something whent wrong
    //rather than failing silently, well log it
    DoDebug("ERROR: ActionUseItemProperty() failed for "+GetName(OBJECT_SELF)+" using "+GetName(oItem)+" to cast "+IntToString(nSpellID));
}


void ActionUseItemPropertyAtLocation(object oItem, itemproperty ipIP, location lTarget)
{
    int nIPSpellID = GetItemPropertySubType(ipIP);
    string sSpellID = Get2DACache("iprp_spells", "SpellIndex", nIPSpellID);
    int nSpellID = StringToInt(sSpellID);
    string sCategory = Get2DACache("spells", "Category", nSpellID);
    int nCategory = StringToInt(sCategory);

    //potions are odd
    //but since they are self-only it doesnt matter

    talent tItem;
    tItem = GetCreatureTalentRandom(nCategory);
    int nCount = 0;
    while(GetIsTalentValid(tItem)
        && nCount < ACTION_USE_ITEM_TMI_LIMIT) //this is the TMI limiting thing, change as appropriate
    {
        if(GetTypeFromTalent(tItem) == TALENT_TYPE_SPELL
            && GetIdFromTalent(tItem) == nSpellID)
        {
            ActionUseTalentAtLocation(tItem, lTarget);
            //end while loop
            return;
        }
        nCount++;
        tItem = GetCreatureTalentRandom(nCategory);
    }
    //if you got to this point, something whent wrong
    //rather than failing silently, well log it
    DoDebug("ERROR: ActionUseItemProperty() failed for "+GetName(OBJECT_SELF)+" using "+GetName(oItem)+" to cast "+IntToString(nSpellID));
}


//::///////////////////////////////////////////////
//:: Get Has Effect
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Checks to see if the target has a given
    spell effect
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 26, 2001
//:://////////////////////////////////////////////
int PRCGetHasEffect(int nEffectType, object oTarget = OBJECT_SELF)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        if(GetEffectType(eCheck) == nEffectType)
        {
             return TRUE;
        }
        eCheck = GetNextEffect(oTarget);
    }
    return FALSE;
}
// Test main
//void main(){}

//::///////////////////////////////////////////////
//:: PRCGetIsFighting
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Checks if the passed object has an Attempted
    Attack or Spell Target
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: March 13, 2002
//:://////////////////////////////////////////////
int PRCGetIsFighting(object oFighting = OBJECT_SELF)
{
    return GetIsObjectValid(GetAttemptedAttackTarget())
         || GetIsObjectValid(GetAttemptedSpellTarget());
}

// Determine whether the character is polymorphed or shfited.
int GetIsPolyMorphedOrShifted(object oCreature)
{
    int bPoly = FALSE;

    effect eChk = GetFirstEffect(oCreature);

    while (GetIsEffectValid(eChk))
    {
        if (GetEffectType(eChk) == EFFECT_TYPE_POLYMORPH)
            bPoly = TRUE;

        eChk = GetNextEffect(oCreature);
    }

    if (GetPersistantLocalInt(oCreature, "nPCShifted"))
        bPoly = TRUE;

    return bPoly;
}

float PRCGetRandomDelay(float fMinimumTime = 0.4, float fMaximumTime = 1.1)
{
    float fRandom = fMaximumTime - fMinimumTime;
    if(fRandom < 0.0)
    {
        return 0.0;
    }
    else
    {
        int nRandom;
        nRandom = FloatToInt(fRandom  * 10.0);
        nRandom = Random(nRandom) + 1;
        fRandom = IntToFloat(nRandom);
        fRandom /= 10.0;
        return fRandom + fMinimumTime;
    }
}

int GetSkill(object oObject, int nSkill, int bSynergy = FALSE, int bSize = FALSE, int bAbilityMod = TRUE, int bEffect = TRUE, int bArmor = TRUE, int bShield = TRUE, int bFeat = TRUE)
{
    if(!GetIsObjectValid(oObject))
        return 0;
    if(!GetHasSkill(nSkill, oObject))
        return 0;//no skill set it to zero
    int nSkillRank;  //get the current value at the end, after effects are applied
    if(bSynergy)
    {
        if(nSkill == SKILL_SET_TRAP
            && GetSkill(oObject, SKILL_DISABLE_TRAP, FALSE, FALSE, FALSE,
                FALSE, FALSE, FALSE, FALSE) >= 5)
                nSkillRank += 2;
        if(nSkill == SKILL_DISABLE_TRAP
            && GetSkill(oObject, SKILL_SET_TRAP, FALSE, FALSE, FALSE,
                FALSE, FALSE, FALSE, FALSE) >= 5)
                nSkillRank += 2;
    }
    if(bSize)
        if(nSkill == SKILL_HIDE)//only hide is affected by size
            nSkillRank += (PRCGetCreatureSize(oObject)-3)*(-4);
    if(!bAbilityMod)
    {
        string sAbility = Get2DACache("skills", "KeyAbility", nSkill);
        int nAbility;
        if(sAbility == "STR")
            nAbility = ABILITY_STRENGTH;
        else if(sAbility == "DEX")
            nAbility = ABILITY_DEXTERITY;
        else if(sAbility == "CON")
            nAbility = ABILITY_CONSTITUTION;
        else if(sAbility == "INT")
            nAbility = ABILITY_INTELLIGENCE;
        else if(sAbility == "WIS")
            nAbility = ABILITY_WISDOM;
        else if(sAbility == "CHA")
            nAbility = ABILITY_CHARISMA;
        nSkillRank -= GetAbilityModifier(nAbility, oObject);
    }
    if(!bEffect)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(nSkill, 30), oObject, 0.001);
        nSkillRank -= 30;
    }
    if(!bArmor
        && GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CHEST, oObject))
        && Get2DACache("skills", "ArmorCheckPenalty", nSkill) == "1")
    {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oObject);
        // Get the torso model number
        int nTorso = GetItemAppearance( oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO);
        // Read 2DA for base AC
        // Can also use "parts_chest" which returns it as a "float"
        int nACBase = StringToInt(Get2DACache( "des_crft_appear", "BaseAC", nTorso));
        int nSkillMod;
        switch(nACBase)
        {
            case 0: nSkillMod = 0; break;
            case 1: nSkillMod = 0; break;
            case 2: nSkillMod = 0; break;
            case 3: nSkillMod = -1; break;
            case 4: nSkillMod = -2; break;
            case 5: nSkillMod = -5; break;
            case 6: nSkillMod = -7; break;
            case 7: nSkillMod = -7; break;
            case 8: nSkillMod = -8; break;
        }
        nSkillRank -= nSkillMod;
    }
    if(!bShield
        && GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oObject))
        && Get2DACache("skills", "ArmorCheckPenalty", nSkill) == "1")
    {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oObject);
        int nBase = GetBaseItemType(oItem);
        int nSkillMod;
        switch(nBase)
        {
            case BASE_ITEM_TOWERSHIELD: nSkillMod = -10; break;
            case BASE_ITEM_LARGESHIELD: nSkillMod = -2; break;
            case BASE_ITEM_SMALLSHIELD: nSkillMod = -1; break;
        }
        nSkillRank -= nSkillMod;
    }
    if(!bFeat)
    {
        int nSkillMod;
        int nEpicFeat;
        int nFocusFeat;
        switch(nSkill)
        {
            case SKILL_ANIMAL_EMPATHY:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_ANIMAL_EMPATHY;
                nFocusFeat = FEAT_SKILL_FOCUS_ANIMAL_EMPATHY;
                break;
            case SKILL_APPRAISE:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_APPRAISE;
                nFocusFeat = FEAT_SKILLFOCUS_APPRAISE;
                if(GetHasFeat(FEAT_SILVER_PALM, oObject))
                    nSkillMod += 2;
                break;
            case SKILL_BLUFF:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_BLUFF;
                nFocusFeat = FEAT_SKILL_FOCUS_BLUFF;
                break;
            case SKILL_CONCENTRATION:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_CONCENTRATION;
                nFocusFeat = FEAT_SKILL_FOCUS_CONCENTRATION;
                if(GetHasFeat(FEAT_SKILL_AFFINITY_CONCENTRATION, oObject))
                    nSkillMod += 2;
                break;
            case SKILL_CRAFT_ARMOR:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_CRAFT_ARMOR;
                nFocusFeat = FEAT_SKILL_FOCUS_CRAFT_ARMOR;
                break;
            case SKILL_CRAFT_TRAP:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_CRAFT_TRAP;
                nFocusFeat = FEAT_SKILL_FOCUS_CRAFT_TRAP;
                break;
            case SKILL_CRAFT_WEAPON:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_CRAFT_WEAPON;
                nFocusFeat = FEAT_SKILL_FOCUS_CRAFT_WEAPON;
                break;
            case SKILL_DISABLE_TRAP:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_DISABLETRAP;
                nFocusFeat = FEAT_SKILL_FOCUS_DISABLE_TRAP;
                break;
            case SKILL_DISCIPLINE:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_DISCIPLINE;
                nFocusFeat = FEAT_SKILL_FOCUS_DISCIPLINE;
                break;
            case SKILL_HEAL:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_HEAL;
                nFocusFeat = FEAT_SKILL_FOCUS_HEAL;
                break;
            case SKILL_HIDE:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_HIDE;
                nFocusFeat = FEAT_SKILL_FOCUS_HIDE;
                break;
            case SKILL_INTIMIDATE:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_INTIMIDATE;
                nFocusFeat = FEAT_SKILL_FOCUS_INTIMIDATE;
                break;
            case SKILL_LISTEN:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_LISTEN;
                nFocusFeat = FEAT_SKILL_FOCUS_LISTEN;
                if(GetHasFeat(FEAT_SKILL_AFFINITY_LISTEN, oObject))
                    nSkillMod += 2;
                if(GetHasFeat(FEAT_PARTIAL_SKILL_AFFINITY_LISTEN, oObject))
                    nSkillMod += 1;
                break;
            case SKILL_LORE:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_LORE;
                nFocusFeat = FEAT_SKILL_FOCUS_LORE;
                if(GetHasFeat(FEAT_SKILL_AFFINITY_LORE, oObject))
                    nSkillMod += 2;
                if(GetHasFeat(FEAT_COURTLY_MAGOCRACY, oObject))
                    nSkillMod += 2;
                if(GetHasFeat(FEAT_BARDIC_KNOWLEDGE, oObject))
                    nSkillMod += GetLevelByClass(CLASS_TYPE_BARD, oObject)
                        +GetLevelByClass(CLASS_TYPE_HARPER, oObject)
						+GetLevelByClass(CLASS_TYPE_FOCHLUCAN_LYRIST, oObject)
                        +GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oObject);
                break;
            case SKILL_MOVE_SILENTLY:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_MOVESILENTLY;
                nFocusFeat = FEAT_SKILL_FOCUS_MOVE_SILENTLY;
                if(GetHasFeat(FEAT_SKILL_AFFINITY_MOVE_SILENTLY, oObject))
                    nSkillMod += 2;
                break;
            case SKILL_OPEN_LOCK:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_OPENLOCK;
                nFocusFeat = FEAT_SKILL_FOCUS_OPEN_LOCK;
                break;
            case SKILL_PARRY:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_PARRY;
                nFocusFeat = FEAT_SKILL_FOCUS_PARRY;
                break;
            case SKILL_PERFORM:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_PERFORM;
                nFocusFeat = FEAT_SKILL_FOCUS_PERFORM;
                if(GetHasFeat(FEAT_ARTIST, oObject))
                    nSkillMod += 2;
                break;
            case SKILL_PERSUADE:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_PERSUADE;
                nFocusFeat = FEAT_SKILL_FOCUS_PERSUADE;
                if(GetHasFeat(FEAT_SILVER_PALM, oObject))
                    nSkillMod += 2;
                break;
            case SKILL_PICK_POCKET:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_PICKPOCKET;
                nFocusFeat = FEAT_SKILL_FOCUS_PICK_POCKET;
                break;
            case SKILL_SEARCH:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_SEARCH;
                nFocusFeat = FEAT_SKILL_FOCUS_SEARCH;
                if(GetHasFeat(FEAT_SKILL_AFFINITY_SEARCH, oObject))
                    nSkillMod += 2;
                if(GetHasFeat(FEAT_PARTIAL_SKILL_AFFINITY_SEARCH, oObject))
                    nSkillMod += 1;
                break;
            case SKILL_SET_TRAP:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_SETTRAP;
                nFocusFeat = FEAT_SKILL_FOCUS_SET_TRAP;
                break;
            case SKILL_SPELLCRAFT:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_SPELLCRAFT;
                nFocusFeat = FEAT_SKILL_FOCUS_SPELLCRAFT;
                if(GetHasFeat(FEAT_COURTLY_MAGOCRACY, oObject))
                    nSkillMod += 2;
                break;
            case SKILL_SPOT:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_SPOT;
                nFocusFeat = FEAT_SKILL_FOCUS_SPOT;
                if(GetHasFeat(FEAT_SKILL_AFFINITY_SPOT, oObject))
                    nSkillMod += 2;
                if(GetHasFeat(FEAT_PARTIAL_SKILL_AFFINITY_SPOT, oObject))
                    nSkillMod += 1;
                if(GetHasFeat(FEAT_ARTIST, oObject))
                    nSkillMod += 2;
                if(GetHasFeat(FEAT_BLOODED, oObject))
                    nSkillMod += 2;
                break;
            case SKILL_TAUNT:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_TAUNT;
                nFocusFeat = FEAT_SKILL_FOCUS_TAUNT;
                break;
            case SKILL_TUMBLE:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_TUMBLE;
                nFocusFeat = FEAT_SKILL_FOCUS_TUMBLE;
                break;
            case SKILL_USE_MAGIC_DEVICE:
                nEpicFeat  = FEAT_EPIC_SKILL_FOCUS_USEMAGICDEVICE;
                nFocusFeat = FEAT_SKILL_FOCUS_USE_MAGIC_DEVICE;
                break;
        }
        if(nEpicFeat != 0
            && GetHasFeat(nEpicFeat, oObject))
            nSkillMod += 10;
        if(nFocusFeat != 0
            && GetHasFeat(nFocusFeat, oObject))
            nSkillMod += 3;
        nSkillRank -= nSkillMod;
    }
    //add this at the end so any effects applied are counted
    nSkillRank += GetSkillRank(nSkill, oObject);
    return nSkillRank;
}

void ForcePutDown(object oPC, object oItem, int nSlot, int nThCall = 0)
{
    // Sanity checks
    if(!GetIsObjectValid(oPC)) return;
    if(!GetIsObjectValid(oItem)) return;
    // Fail on non-commandable NPCs after ~1min
    if(!GetIsPC(oPC) && !GetCommandable(oPC) && nThCall > 60)
    {
        WriteTimestampedLogEntry("ForcePutDown() failed on non-commandable NPC: " + DebugObject2Str(oPC) + " for item: " + DebugObject2Str(oItem));
        return;
    }

    float fDelay;

    if(GetItemInSlot(nSlot, oPC) == oItem)
    {
        // Attempt to avoid interference by not clearing actions before the first attempt
        if(nThCall > 1)
            if(GetIsPC(oPC) || nThCall > 5) // Skip nuking NPC action queue at first, since that can cause problems. 5 = magic number here. May need adjustment
                AssignCommand(oPC, ClearAllActions());

        AssignCommand(oPC, ActionPutDownItem(oItem));

        // Ramp up the delay if the action is not getting through. Might let whatever is intefering finish
        fDelay = PRCMin(nThCall, 10) / 10.0f;
    }
    // The item has already been unequipped
    else
        return;

    // Loop
    DelayCommand(fDelay, ForcePutDown(oPC, oItem, nSlot, ++nThCall));
}

// Test main
//void main() {}
