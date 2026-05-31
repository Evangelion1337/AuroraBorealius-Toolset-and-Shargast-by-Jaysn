//::///////////////////////////////////////////////
//:: PRC Level Up NUI
//:: prc_nui_lv_inc
//:://////////////////////////////////////////////
/*
    This is the logic for the Level Up NUI, holding all the functions needed for
    the NUI to operate properly and allow leveling up in different classes.
*/
//:://////////////////////////////////////////////
//:: Created By: Rakiov
//:: Created On: 20.08.2025
//:://////////////////////////////////////////////

#include "prc_nui_com_inc"
#include "tob_inc_tobfunc"
#include "tob_inc_moveknwn"
#include "inv_inc_invfunc"
#include "shd_inc_mystknwn"
#include "shd_inc_shdfunc"
#include "true_inc_truknwn"
#include "true_inc_trufunc"

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Spont Casters / Base                                                ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

//
// GetSpellListObject
// Gets the JSON Object representation of a class's spellbook 2da. This function
// will cache it's result to the object given to it to avoid further calculations
// and will not clear itself since it does not change.
//
// Arguments:
//   nClass:int the ClassID
//   oPC:Object the player
//
// Returns:
//   Json:Dictionary<String, List[]> a dictionary of each circle's spellbook Ids.
//
json GetSpellListObject(int nClass, object oPC=OBJECT_SELF);

//
// GetKnownSpellListObject
// Gets the JSON Object representation of a player's known spell list. This function
// will temporarily cache it's result to the object given to avoid further calculations.
// However this should be cleared after done using the level up screen or reset.
//
// Arguments:
//   nClass:int the ClassID
//   oPC:Object the player
//
// Returns:
//   Json:Dictionary<String, List[]> a dictionary of each circle's known spellbook Ids.
//
json GetKnownSpellListObject(int nClass, object oPC=OBJECT_SELF);

//
// GetKnownSpellListObject
// Gets the JSON Object representation of a player's chosen spell list. This function
// will temporarily cache it's result to the object given to avoid further calculations.
// However this should be cleared after done using the level up screen or reset.
//
// Arguments:
//   nClass:int the ClassID
//   oPC:Object the player
//
// Returns:
//   Json:Dictionary<String, List[]> a dictionary of each circle's chosen spellbook Ids.
//
json GetChosenSpellListObject(int nClass, object oPC=OBJECT_SELF);

//
// ShouldAddSpellToSpellButtons
// Given a classId and a spellbookId, if the player knows the spell already we
// should not add the spell, otherwise we should
//
// Arguments:
//   nClass:int Class ID
//   spellbookId:int the spell book ID
//   oPC:object the player
//
// Returns:
//   int:Boolean TRUE if spell should be added, FALSE otherwise
//
int ShouldAddSpellToSpellButtons(int nClass, int spellbookId, object oPC=OBJECT_SELF);

//
// OpenNUILevelUpWindow
// Opens the Level Up NUI window for the provided class
//
// Arguments:
//   nClass:int the ClassID
//
void OpenNUILevelUpWindow(int nClass, object oPC=OBJECT_SELF);

//
// CloseNUILevelUpWindow
// Closes the NUI Level Up Window if its open
// setting reset to 1 will make it clear the entire cache as if the NUI was never opened
//
void CloseNUILevelUpWindow(object oPC=OBJECT_SELF, int reset=0);

//
// GetRemainingSpellChoices
// Gets the remaining spell choices for a class at the given circle by checking its
// chosen spells and comparing it against the total spells allowed. This value
// is cached on the player and cleared everytime the window is refreshed/closed
//
// Arguments:
//   nClass:int the class id
//   circleLevel:int the circle being checked
//
// Returns:
//   int the amount of choices left at the circle
//
int GetRemainingSpellChoices(int nClass, int circleLevel, object oPC=OBJECT_SELF);

//
// ShouldSpellButtonBeEnabled
// Checks whether a spell button should be enabled either because all choices have
// been made, replacing spells isn't allowed, or for various other reasons
//
// Arguments:
//   nClass:int class id
//   circleLevel:int the chosen circle
//   spellbookId:int the chosen spell
//
// Returns:
//   int:Boolean TRUE if spell button should be enabled, FALSE otherwise
//
int ShouldSpellButtonBeEnabled(int nClass, int circleLevel, int spellbookId, object oPC=OBJECT_SELF);

//
// AddSpellToChosenList
// Adds spell to the chosen spells list
//
// Arguments:
//   nClass:int the classId
//   spellbookId:int the spellbook Id
//   spellCircle:int the current circle of the spell
//
void AddSpellToChosenList(int nClass, int spellbookId, int spellCircle, object oPC=OBJECT_SELF);

//
// RemoveSpellFromChosenList
// Removes a spell from the chosen spell list
//
// Arguments:
//   nClass:int the class id
//   spellbookId:int the spellbook Id
//   spellCircle:int the circle of the spell
//
void RemoveSpellFromChosenList(int nClass, int spellbookId, int spellCircle, object oPC=OBJECT_SELF);

//
// LearnSpells
// gives the player the spells they want to learn based off of the chosen spell
// list in a stored variable
//
// Arguments:
//   nClass:int the classId
//
void LearnSpells(int nClass, object oPC=OBJECT_SELF);

//
// RemoveSpells
// removes spells from the player that they may know currently but aren't selected
// based off lists in stored variables
//
// Arguments:
//   nClass:int the classId
//
void RemoveSpells(int nClass, object oPC=OBJECT_SELF);

//
// FinishLevelUp
// Finishes level up NUI by removing spells, learning spells, clearing cache, then closing the NUI
//
// Arguments:
//   nClass:int the class id
//
void FinishLevelUp(int nClass, object oPC=OBJECT_SELF);

//
// ClearLevelUpNUICaches
// Clears the cache (stored local variables) for the level up NUI so it is
// ready to be used for a new level up
//
// Arguments:
//   nClass:int class id
//   oPC:object the player object this is stored under
//
void ClearLevelUpNUICaches(int nClass, object oPC=OBJECT_SELF);

//
// SpellIsWithinObject
// checks whether a spell is within a JSON Object structure used by the remaining
// spells object and known spells object, following this structure
// {
//   "circleLevel:int": [ 1,2,3...,spellId],
//   ...
// }
//
// Arguments
//   nClass:int classId
//   spellbookId:int the spellbook Id
//   circleLevel:int the chosen circle of the spell
//   spellList;JsonObject the spell list object being checked
//
// Returns:
//   int:Boolean TRUE if it is in the object, FALSE otherwise
//
int SpellIsWithinObject(int nClass, int spellbookId, int circleLevel, json spellList, object oPC=OBJECT_SELF);

//
// IsLevelUpNUIOpen
// Checks if the Level Up NUI is open for the player or not
//
// Arguments:
//   oPC:object the player object
//
// Returns:
//   int:Boolean TRUE if it is, FALSE otherwise
//
int IsLevelUpNUIOpen(object oPC=OBJECT_SELF);

//
// IsClassAllowedToUseLevelUpNUI
// Is the provided class allowed to use the level up NUI
//
// Arguments:
//   nClass:int class id
//
// Returns:
//   int:Boolean TRUE if it can, FALSE otherwise
//
int IsClassAllowedToUseLevelUpNUI(int nClass);

//
// EnabledChosenButton
// determines if a chosen spell button should be enabled or not. It may not due to
// class restrictions, replacing is not enabled, or other reason
//
// Arguments:
//   nClass:int the class id
//   spellbookId: the spellbook Id
//   circleLevel: the spell's circle
//
// Returns:
//   int:Boolean TRUE if it should be enabled, FALSE otherwise
//
int EnableChosenButton(int nClass, int spellbookId, int circleLevel, object oPC=OBJECT_SELF);

//
// ResetChoices
// Action for the Level Up NUI's 'Reset' button, resets choices by clearing the cache of
// the user so their choices are forgotten and they can start over.
//
// Arguments:
//   oPC:object the player object
//
void ResetChoices(object oPC=OBJECT_SELF);

//
// RemoveSpellKnown
// Removes a spell from a player based off class id. This is for classes that
// aren't spont casters where we have to go in and adjust persistant arrays
// to say if a spell is known or not.
//
// Arguments:
//   nClass:int class id
//   spellbookId:int the spellbook Id
//   oPC:object the player object
//   nList:int the list we are removing the spell from (extra invocations or expanded knowledge)
//
void RemoveSpellKnown(int nClass, int spellbookId, object oPC=OBJECT_SELF, int nList=0);

//
// GetSpellIDsKnown
// Gets the SpellIDs list of the given class and list and returns it as a JsonObject following this structure
// {
//   "spellId:int": TRUE,
//   ...
// }
//
// This is to keep lookups at O(1) processing time. This value is cached and is
// cleared when the player finishes level up
//
// Arguments:
//   nClass:int class id
//   oPC:object the player object
//   nList:int the list we are checking if provided (extra invocations or expanded knowledge)
//
// Returns:
//   JsonObject the list of spell ids the class knows in JsonObject format
//
json GetSpellIDsKnown(int nClass, object oPC=OBJECT_SELF, int nList=0);

//
// ReasonForDisabledSpell
// Provides the reason for why a spell choice is disabled
//
// Arguments:
//   nClass:int the class id
//   spellbookId:int the spellbook Id
//
// Returns:
//   string the reason for the disabled button, empty string otherwise
//
string ReasonForDisabledSpell(int nClass, int spellbookId, object oPC=OBJECT_SELF);

//
// ReasonForDisabledChosen
// Provides the reason for why a chosen spell button is disabled
//
// Arguments:
//   nClass:int the class id
//   spellbookId:int the spellbook Id
//
// Returns:
//   string the reason for the disabled button, empty string otherwise
//
string ReasonForDisabledChosen(int nClass, int spellbookId, object oPC=OBJECT_SELF);

//
// GetExpandedChoicesList
// Gets the expanded choices list for a class (the list of expanded knowledge or
// extra invocations). It follows this structure
//
// {
//   "spellId:int": TRUE,
//   ...
// }
// This is cached to reduce process times and is cleared everytime the window is refreshed/closed
//
// Arguments:
//   nClass:int the class id
//
// Returns:
//   JsonObject the object representation of the expanded choices
//
json GetExpandedChoicesList(int nClass, object oPC=OBJECT_SELF);

//
// GetExpandedChoicesList
// Gets the epic expanded choices list for a class (the list of expanded knowledge or
// extra invocations). It follows this structure
//
// {
//   "spellId:int": TRUE,
//   ...
// }
// This is cached to reduce process times and is cleared everytime the window is refreshed/closed
//
// Arguments:
//   nClass:int the class id
//
// Returns:
//   JsonObject the object representation of the expanded choices
//
json GetEpicExpandedChoicesList(int nClass, object oPC=OBJECT_SELF);

//
// GetRemainingExpandedChoices
// Gets the remaining expanded choices for a class based off list, comparing the
// total number of choices allowed and the total number chosen
//
// Arguments:
//   nClass: class id
//   nList: the list we are checking (extra invocations/expanded knowledge)
//
// Returns:
//   int the amount of choices left
//
int GetRemainingExpandedChoices(int nClass, int nList, object oPC=OBJECT_SELF);
//
// IsSpellInExpandedChoices
// tells if a spell is in the expanded choices list or not
//
// Arguments:
//   nClass:int class id
//   nList:int the list we are checking (extra invocations/expanded knowledge)
//   spellId:int the spell id (not the spellbook id)
//
// Returns
//   int:Boolean TRUE if it is a expanded choice, FALSE otherwise
//
int IsSpellInExpandedChoices(int nClass, int nList, int spellId, object oPC=OBJECT_SELF);

//
// GetChosenReplaceListObject
// The chosen list of spells we wish to replace for PnP replacing if Bioware replacing
// is disabled. This is cached and is cleared when the player is finished leveling
// or resets their choices
//
// Arguments:
//   oPC:object the player
//
// Returns:
//   json the list of spells chosen to replace
//
json GetChosenReplaceListObject(object oPC=OBJECT_SELF);

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Psionics                                                            ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

//
// IsExpKnowledgePower
// checks if a spell is a expanded knowledge spell
//
// Arguments:
//   nClass:int class id
//   spellbookId:int the spellbook Id
//
// Returns:
//   int:Boolean TRUE if the spell is a expanded knowledge spell, FALSE otherwise
//
int IsExpKnowledgePower(int nClass, int spellbookId, object oPC=OBJECT_SELF);

//
// GetExpKnowledgePowerListRequired
// Tells what list the spell should be added to based on if it was added to the
// expanded choices or epic expanded choices list
//
// Arguments:
//   nClass:int the class id
//   spellbookId:int the spellbook Id
//
// Returns:
//   int -1 for the expanded knowledge list, -2 for the epic expanded knowledge
//     list, 0 if just add it to the normal class list
//
int GetExpKnowledgePowerListRequired(int nClass, int spellbookId, object oPC=OBJECT_SELF);

//
// GetCurrentPowerList
// Gets the current chosen powers list. This is cached and is cleared when the
// player either finishs leveling up or resets.
//
// Arguments:
//   oPC:object the player object
//
// Returns:
//   JsonArray the list of chosen powers wanting to learn
//
json GetCurrentPowerList(object oPC=OBJECT_SELF);

//
// ShouldAddPower
// Tells if the power should be added to the list of choices or not. It may not
// be added because its an expanded knowledge choice and you have no more expanded
// knowledge slots, or it may be a restricted spell like psions list
//
// Arguments:
//   nClass:int the class id
//   spellbookId:int the spellbook id
//
// Returns:
//   int:Boolean TRUE if it should be added, FALSE otherwise
//
int ShouldAddPower(int nClass, int spellbookId, object oPC=OBJECT_SELF);

//
// LearnPowers
// learns the list of chosen powers for the player based off their chosen power list
//
// Arguments:
//    nClass:int class id
//    oPC:object the player object where stored variables are
//
void LearnPowers(int nClass, object oPC=OBJECT_SELF);

//
// GetMaxPowerLevelForClass
// gets the max power level for the player based off their level and the class's
// known 2da
//
// Arguments:
//   nClass:int the class id
//   oPC:object the player
//
// Returns:
//   int the max power level (circle) the player can achieve on that class
//
int GetMaxPowerLevelForClass(int nClass, object oPC=OBJECT_SELF);

//
// GetRemainingPowerChoices
// Gets the remaining power choices the character has at the given chosen circle/power level
//
// Arguments:
//   nClass:int class id
//   chosenCircle:int the chosen circle/power level
//   oPC:object the player
//   extra:int should we add the expanded knowledge choices or not
//
// Returns:
//   int the number of choices left at the given circle
//
int GetRemainingPowerChoices(int nClass, int chosenCircle, object oPC=OBJECT_SELF, int extra=TRUE);

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Initiators                                                          ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

//
// GetDisciplineInfoObject
// Gets the disciplien info for the given class, telling what the chosen spells
// disicpline is, what type of maneuever it is, the different totals, and prerequisites.
// This is cached and is cleared when the window is refreshed/closed
//
// Argument:
//    nClass:int class id
//
// Returns:
//   JsonObject the object representation of the chosen spells discipline info
//
json GetDisciplineInfoObject(int nClass, object oPC=OBJECT_SELF);

//
// HasPreRequisitesForManeuver
// Does the player have the prerequisites for the given spell based off their chosen
// spell list
//
// Arguments:
//   nClass:int the class id
//   spellbookId:int the spellbook id
//   oPC:object the player object with stored variables
//
// Returns:
//   int:Boolean, TRUE if you have the prerequisites, FALSE otherwise
//
int HasPreRequisitesForManeuver(int nClass, int spellbookId, object oPC=OBJECT_SELF);

//
// GetMaxInitiatorCircle
// gets the max circle/level a player can obtain with the given class
//
// Arguments:
//   nClass:int the class id
//   oPC:object the player
//
// Returns:
//   int the highest circle the player can achieve with the class
//
int GetMaxInitiatorCircle(int nClass, object oPC=OBJECT_SELF);

//
// GetRemainingManeuverChoices
// Gets remaining maneuever choices for the player
//
// Arguments:
//   nClass:int class id
//   oPC:object the player
//
// Returns:
//   int the remaining maneuevers choices
//
int GetRemainingManeuverChoices(int nClass, object oPC=OBJECT_SELF);

//
// GetRemainingStanceChoices
// Gets remaining stance choices for the player
//
// Arguments:
//   nClass:int class id
//   oPC:object the player
//
// Returns:
//   int the remaining stance choices
//
int GetRemainingStanceChoices(int nClass, object oPC=OBJECT_SELF);

//
// IsRequiredForOtherManeuvers
// Checks the given prerequisite number and the chosen spells to see if removing it
// will cause it to fail the requirement for other maneuevers
//
// Arguments:
//   nClass:int the class id
//   prereq:int the chosen spells prerequisite number of maneuevers needed
//   discipline:string the chosen spells discipline
//
// Returns:
//   int:Boolean TRUE if it is required, FALSE otherwise
//
int IsRequiredForOtherManeuvers(int nClass, int prereq, string discipline, object oPC=OBJECT_SELF);

//
// IsAllowedDiscipline
// checks to see if the given spell is a allowed discipline for a class
//
// Arguments:
//   nClass:int class id
//   spellbookId:int the spellbook id
//
// Returns:
//   int:boolean TRUE if it is allowed, FALSE otherwise
//
int IsAllowedDiscipline(int nClass, int spellbookId, object oPC=OBJECT_SELF);

//
// AddSpellDisciplineInfo
// Adds the maneuver's discipline info to the class's discpline object
//
// Arguments:
//   sFile:string the class's spell 2da
//   spellbookId:int the spellbook Id
//   classDisc:JsonObject the class discipline object we are adding to
//
// Returns:
//  json:Object the classDisc with the given spells information added
//
json AddSpellDisciplineInfo(string sFile, int spellbookId, json classDisc);

//
// IsRequiredForToBPRCClass
// tells if a given maneuver is needed to satisfy a PRC's prerequsitie
//
// Arguments:
//   nClass:int class id
//   spellbookId:int the spellbook id
//
// Returns:
//   int:Boolean TRUE if the maneuver is required for a PRC, FALSE otherwise.
//
int IsRequiredForToBPRCClass(int nClass, int spellbookId, object oPC=OBJECT_SELF);

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Invokers                                                            ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

//
// GetInvokerKnownListObject
// gets the invokers known invocations list in object format, needed to tell how many
// of each invocation level does a person know at a given level. This is cached on the
// player and not cleared since it never changes.
//
// Arguments:
//   nClass:int class id
//
// Returns:
//   json:Object the list of invocations known in json format
//
json GetInvokerKnownListObject(int nClass, object oPC=OBJECT_SELF);

//
// GetRemainingInvocationChoices
// Gets the remaining invocation choices left
//
// Arguments:
//   nClass:int class id
//   chosenCircle:int the chosen circle we are checking
//   oPC:Object the player
//   extra:int should we count the number of extra invocations we have left
//
// Returns:
//   int the amount of choices left at the given circle
//
int GetRemainingInvocationChoices(int nClass, int chosenCircle, object oPC=OBJECT_SELF, int extra=TRUE);

//
// IsExtraChoiceInvocation
// tells if a given spell is a extra invocation choice
//
// Arguments:
//   nClass:int class id
//   spellbookId:int the spellbook id
//
// Returns:
//   int;Boolean TRUE if it is a extra choice, FALSE otherwise
//
int IsExtraChoiceInvocation(int nClass, int spellbookId, object oPC=OBJECT_SELF);

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Truenamer                                                           ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

//
// GetRemainingTruenameChoices
// gets the remaining truename choices left at the given lexicon type
//
// Arguments:
//   nClass:int class id
//   nType:int the lexicon
//
// Returns:
//   int the amount of truename choices left for the given lexicon
//
int GetRemainingTruenameChoices(int nClass, int nType, object oPC=OBJECT_SELF);

//
// GetLexiconCircleKnownAtLevel
// gets the known circle level for a given lexicon
//
// Arguments:
//   nLevel:int the level to check
//   nType:int the lexicon we are checking
//
// Returns:
//   int the highest circle we can achieve
//
int GetLexiconCircleKnownAtLevel(int nLevel, int nType);

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Archivist                                                           ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

json GetArchivistNewSpellsList(object oPC=OBJECT_SELF);

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Spont Casters / Base                                                ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

int IsLevelUpNUIOpen(object oPC=OBJECT_SELF)
{
    int nPreviousToken = NuiFindWindow(oPC, NUI_LEVEL_UP_WINDOW_ID);
    if (nPreviousToken != 0)
    {
        return TRUE;
    }

    return FALSE;
}

int IsClassAllowedToUseLevelUpNUI(int nClass)
{

    if (GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS)
        return TRUE;

    if (nClass == CLASS_TYPE_PSYWAR
        || nClass == CLASS_TYPE_PSYCHIC_ROGUE
        || nClass == CLASS_TYPE_PSION
        || nClass == CLASS_TYPE_FIST_OF_ZUOKEN
        || nClass == CLASS_TYPE_WILDER
        || nClass == CLASS_TYPE_WARMIND)
        return TRUE;

    if (nClass == CLASS_TYPE_WARBLADE
        || nClass == CLASS_TYPE_SWORDSAGE
        || nClass == CLASS_TYPE_CRUSADER)
        return TRUE;

    if (nClass == CLASS_TYPE_WARLOCK
        || nClass == CLASS_TYPE_DRAGONFIRE_ADEPT
        || nClass == CLASS_TYPE_DRAGON_SHAMAN)
        return TRUE;

    if (nClass == CLASS_TYPE_SHADOWCASTER
        || nClass == CLASS_TYPE_SHADOWSMITH)
        return TRUE;

    if (nClass == CLASS_TYPE_TRUENAMER)
        return TRUE;

    if (nClass == CLASS_TYPE_ARCHIVIST)
        return TRUE;

    return FALSE;
}

int SpellIsWithinObject(int nClass, int spellbookId, int circleLevel, json spellList, object oPC=OBJECT_SELF)
{
    // check to see if the spell circle isn't empty
    json currentList = JsonObjectGet(spellList, IntToString(circleLevel));
    if (currentList == JsonNull())
        return FALSE;

    int totalSpells = JsonGetLength(currentList);

    // then loop through the spell list and find the spell.
    int i;
    for (i = 0; i < totalSpells; i++)
    {
        int currentSpell = JsonGetInt(JsonArrayGet(currentList, i));
        if (currentSpell == spellbookId)
            return TRUE;
    }

    return FALSE;
}

int AllSpellsAreChosen(int nClass, object oPC=OBJECT_SELF)
{
    // we need the max number of circles a class has.
    json spellList = GetSpellListObject(nClass, oPC);
    json spellCircles = JsonObjectKeys(spellList);
    int totalCircles = JsonGetLength(spellCircles);

    int i;
    for (i = 0; i < totalCircles; i++)
    {
        // loop through each circle and check if you have any remaining choices left
        // if you do or you have a deficit then you need to remove or add something
        // until you get 0
        int spellCircle = StringToInt(JsonGetString(JsonArrayGet(spellCircles, i)));
        int remainingChoices = GetRemainingSpellChoices(nClass, spellCircle, oPC);
        if (remainingChoices < 0 || remainingChoices > 0)
            return FALSE;
    }

    return TRUE;
}

void AddSpellToChosenList(int nClass, int spellbookId, int spellCircle, object oPC=OBJECT_SELF)
{
    if (GetIsInvocationClass(nClass))
    {
        // get the remaining invocation choices left without extra feats
        // if it is 0 then we are adding the chosen invocation to the extra lists
        int totalInvocations = GetRemainingInvocationChoices(nClass, spellCircle, oPC, FALSE);
        if (totalInvocations == 0)
        {
            string sFile = GetClassSpellbookFile(nClass);
            if (GetRemainingExpandedChoices(nClass, INVOCATION_LIST_EXTRA, oPC))
            {
                json expList = GetExpandedChoicesList(nClass, oPC);
                string spellId = Get2DACache(sFile, "SpellID", spellbookId);
                expList = JsonObjectSet(expList, spellId, JsonBool(TRUE));
                SetLocalJson(oPC, NUI_LEVEL_UP_EXPANDED_CHOICES_VAR, expList);
            }
            else if (GetRemainingExpandedChoices(nClass, INVOCATION_LIST_EXTRA_EPIC, oPC))
            {
                json expList = GetEpicExpandedChoicesList(nClass, oPC);
                string spellId = Get2DACache(sFile, "SpellID", spellbookId);
                expList = JsonObjectSet(expList, spellId, JsonBool(TRUE));
                SetLocalJson(oPC, NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR, expList);
            }
        }
    }
    if (GetIsPsionicClass(nClass))
    {
        // if the power is a expanded knowledge than we immediatly add it to the
        // extra list, otherwise check to make sure we have made all choices in our
        // base list first before adding it to the extra list.
        if (IsExpKnowledgePower(nClass, spellbookId, oPC)
            || GetRemainingPowerChoices(nClass, spellCircle, oPC, FALSE) == 0)
        {
            string sFile = GetClassSpellbookFile(nClass);
            if (GetRemainingExpandedChoices(nClass, POWER_LIST_EXP_KNOWLEDGE, oPC))
            {
                json expList = GetExpandedChoicesList(nClass, oPC);
                string spellId = Get2DACache(sFile, "SpellID", spellbookId);
                expList = JsonObjectSet(expList, spellId, JsonBool(TRUE));
                SetLocalJson(oPC, NUI_LEVEL_UP_EXPANDED_CHOICES_VAR, expList);
            }
            else if (GetRemainingExpandedChoices(nClass, POWER_LIST_EPIC_EXP_KNOWLEDGE, oPC))
            {
                json expList = GetEpicExpandedChoicesList(nClass, oPC);
                string spellId = Get2DACache(sFile, "SpellID", spellbookId);
                expList = JsonObjectSet(expList, spellId, JsonBool(TRUE));
                SetLocalJson(oPC, NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR, expList);
            }
        }

        // add the power to the current power list.
        json currPowerList = GetCurrentPowerList(oPC);
        currPowerList = JsonArrayInsert(currPowerList, JsonInt(spellbookId));
        SetLocalJson(oPC, NUI_LEVEL_UP_POWER_LIST_VAR, currPowerList);
    }

    if (nClass == CLASS_TYPE_ARCHIVIST)
    {
        json newSpells = GetArchivistNewSpellsList(oPC);
        newSpells = JsonArrayInsert(newSpells, JsonInt(spellbookId));
        SetLocalJson(oPC, NUI_LEVEL_UP_ARCHIVIST_NEW_SPELLS_LIST_VAR, newSpells);
    }

    // base logic for spont casters, add the spell to the ChosenSpells JSON object
    // by adding it to it's appropriate circle.
    json chosenSpells = GetChosenSpellListObject(nClass, oPC);
    json spellsAtCircle = JsonObjectGet(chosenSpells, IntToString(spellCircle));
    if (spellsAtCircle == JsonNull())
        spellsAtCircle = JsonArray();
    spellsAtCircle = JsonArrayInsert(spellsAtCircle, JsonInt(spellbookId));
    chosenSpells = JsonObjectSet(chosenSpells, IntToString(spellCircle), spellsAtCircle);
    SetLocalJson(oPC, NUI_LEVEL_UP_CHOSEN_SPELLS_VAR, chosenSpells);

    // if we are not using bioware unlearning logic, then we need to limit the
    // amount of spells we can replace.
    if (!GetPRCSwitch(PRC_BIO_UNLEARN))
    {
        json unlearnList = GetChosenReplaceListObject(oPC);
        // if the spell belongs to the unlearn list, then remove it to make room
        // for a new spell.
        if (JsonObjectGet(unlearnList, IntToString(spellbookId)) != JsonNull())
        {
            unlearnList = JsonObjectDel(unlearnList, IntToString(spellbookId));
            SetLocalJson(oPC, NUI_LEVEL_UP_RELEARN_LIST_VAR, unlearnList);
        }
    }
}

void RemoveSpellFromChosenList(int nClass, int spellbookId, int spellCircle, object oPC=OBJECT_SELF)
{
    json chosenSpells = GetChosenSpellListObject(nClass, oPC);
    json spellsAtCircle = JsonObjectGet(chosenSpells, IntToString(spellCircle));
    if (spellsAtCircle == JsonNull())
        spellsAtCircle = JsonArray();

    int totalSpells = JsonGetLength(spellsAtCircle);

    // find the spell at the circle in the chosen list and remove it.
    int i;
    for (i = 0; i < totalSpells; i++)
    {
        if (spellbookId == JsonGetInt(JsonArrayGet(spellsAtCircle, i)))
        {
            spellsAtCircle = JsonArrayDel(spellsAtCircle, i);
            break;
        }
    }

    chosenSpells = JsonObjectSet(chosenSpells, IntToString(spellCircle), spellsAtCircle);
    SetLocalJson(oPC, NUI_LEVEL_UP_CHOSEN_SPELLS_VAR, chosenSpells);

    // if we re not using bioware unlearn logic we need to limit how many spells
    // can be replaced
    if (!GetPRCSwitch(PRC_BIO_UNLEARN))
    {
        json knownSpells = GetKnownSpellListObject(nClass, oPC);
        json spellListAtCircle = JsonObjectGet(knownSpells, IntToString(spellCircle));
        int totalSpells = JsonGetLength(spellListAtCircle);

        // with the list of known spells, check the selected circle and see if the
        // current spell belongs in the already known spell list.
        for (i = 0; i < totalSpells; i++)
        {
            int chosenSpell = JsonGetInt(JsonArrayGet(spellListAtCircle, i));
            if (chosenSpell == spellbookId)
            {
                // if it does we need to add the spell to the unlearn JSON object to track what spells
                // are being replaced.
                json unlearnList = GetChosenReplaceListObject(oPC);
                unlearnList = JsonObjectSet(unlearnList, IntToString(spellbookId), JsonBool(TRUE));
                SetLocalJson(oPC, NUI_LEVEL_UP_RELEARN_LIST_VAR, unlearnList);
                break;
            }
        }
    }

    if (GetIsPsionicClass(nClass))
    {
        string sFile = GetClassSpellbookFile(nClass);
        string spellId = Get2DACache(sFile, "SpellID", spellbookId);

        // for psionics we need to check if the removed spell was a expanded knowledge choice
        // or not. The id of the list is -1 or -2.
        int i;
        for (i == -1; i >= -2; i--)
        {
            json expList = (i == -1) ? GetExpandedChoicesList(nClass, oPC) :
                GetEpicExpandedChoicesList(nClass, oPC);

            //if the spell belongs in the expanded knowledge list, then we need
            // to remove it.
            if (JsonObjectGet(expList, spellId) != JsonNull())
            {
                expList = JsonObjectDel(expList, spellId);
                if (i == POWER_LIST_EXP_KNOWLEDGE)
                    SetLocalJson(oPC, NUI_LEVEL_UP_EXPANDED_CHOICES_VAR, expList);
                else
                    SetLocalJson(oPC, NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR, expList);
            }
        }

        // then we need to remove the power from the selected powers list.
        json currPowerChoices = GetCurrentPowerList(oPC);
        int totalPowers = JsonGetLength(currPowerChoices);

        for (i = 0; i < totalPowers; i++)
        {
            if (spellbookId == JsonGetInt(JsonArrayGet(currPowerChoices, i)))
            {
                currPowerChoices = JsonArrayDel(currPowerChoices, i);
                break;
            }
        }

        SetLocalJson(oPC, NUI_LEVEL_UP_POWER_LIST_VAR, currPowerChoices);
    }
    if (GetIsInvocationClass(nClass))
    {
        string sFile = GetClassSpellbookFile(nClass);
        string spellId = Get2DACache(sFile, "SpellID", spellbookId);

        // for invocations we need to check if the spell was added to the extra
        // invocations list, the list ids are the invalid class id, and -2
        int i;
        for (i = 0; i <= 1; i++)
        {
            json expList = (i == 0) ? GetExpandedChoicesList(nClass, oPC) :
                GetEpicExpandedChoicesList(nClass, oPC);

            // if the spell was found, remove it.
            if (JsonObjectGet(expList, spellId) != JsonNull())
            {
                expList = JsonObjectDel(expList, spellId);
                if (i == 0)
                    SetLocalJson(oPC, NUI_LEVEL_UP_EXPANDED_CHOICES_VAR, expList);
                else
                    SetLocalJson(oPC, NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR, expList);
            }
        }
    }
    if (nClass == CLASS_TYPE_ARCHIVIST)
    {
        json newSpells = GetArchivistNewSpellsList(oPC);
        int totalNew = JsonGetLength(newSpells);

        int i;
        for (i = 0; i < totalNew; i++)
        {
            int newSpellbookId = JsonGetInt(JsonArrayGet(newSpells, i));
            if (newSpellbookId == spellbookId)
            {
                newSpells = JsonArrayDel(newSpells, i);
                SetLocalJson(oPC, NUI_LEVEL_UP_ARCHIVIST_NEW_SPELLS_LIST_VAR, newSpells);
                break;
            }
        }
    }
}

void OpenNUILevelUpWindow(int nClass, object oPC=OBJECT_SELF)
{
    CloseNUILevelUpWindow(oPC);
    // set the NUI to the given classId
    int currentClass = GetLocalInt(oPC, NUI_LEVEL_UP_SELECTED_CLASS_VAR);
    // we need to clear the cache if it was used before to avoid weird behaviors
    ClearLevelUpNUICaches(currentClass, oPC);
    // sometimes we are given a different classId instead of the base, we need to
    // figure out what the true base class is (mostly true for RHD)
    int chosenClass = GetTrueClassType(nClass, oPC);
    SetLocalInt(oPC, NUI_LEVEL_UP_SELECTED_CLASS_VAR, chosenClass);
    ExecuteScript("prc_nui_lv_view", oPC);
}

void CloseNUILevelUpWindow(object oPC=OBJECT_SELF, int reset=0)
{
    int currentClass = GetLocalInt(oPC, NUI_LEVEL_UP_SELECTED_CLASS_VAR);
    // if we are refreshing the NUI but not finished we need to clear some caching done
    // to save computation time as they will need to be reprocessed.
    DeleteLocalJson(oPC, NUI_LEVEL_UP_DISCIPLINE_INFO_VAR + IntToString(currentClass));
    SetLocalInt(oPC, NUI_LEVEL_UP_REMAINING_CHOICES_CACHE_VAR, -20);
    if (reset)
    {
        ClearLevelUpNUICaches(currentClass, oPC);
    }
    int nPreviousToken = NuiFindWindow(oPC, NUI_LEVEL_UP_WINDOW_ID);
    if (nPreviousToken != 0)
    {
        NuiDestroy(oPC, nPreviousToken);
    }
}

int ShouldSpellButtonBeEnabled(int nClass, int circleLevel, int spellbookId, object oPC=OBJECT_SELF)
{
    // logic for psionics
    if (GetIsPsionicClass(nClass))
    {
        int maxLevel = GetMaxPowerLevelForClass(nClass, oPC);
        if (circleLevel > maxLevel)
            return FALSE;

        // if its an expanded knowledge choice and we have already made all our
        // exp knowledge choices then it needs to be disabled.
        if (IsExpKnowledgePower(nClass, spellbookId, oPC))
        {
            int remainingExp = GetRemainingExpandedChoices(nClass, POWER_LIST_EXP_KNOWLEDGE, oPC)
                + GetRemainingExpandedChoices(nClass, POWER_LIST_EPIC_EXP_KNOWLEDGE, oPC);
            if (!remainingExp)
                return FALSE;
        }
    }

    if (GetIsShadowMagicClass(nClass))
    {
        // mysteries are weird, the circles are sectioned by 1-3, 4-6, 7-9
        // if you do not have at least 2 choices from a circle you can't progress up
        // so you can have access to circles 1,2,4,7,8
        int nType = 1;
        if (circleLevel >= 4 && circleLevel <= 6)
            nType = 2;
        if (circleLevel >= 7 && circleLevel <= 9)
            nType = 3;
        int maxPossibleCircle = GetMaxMysteryLevelLearnable(oPC, nClass, nType);
        if (circleLevel > maxPossibleCircle)
            return FALSE;
    }

    if (GetIsTruenamingClass(nClass))
    {
        string sFile = GetClassSpellbookFile(nClass);
        int lexicon = StringToInt(Get2DACache(sFile, "Lexicon", spellbookId));
        // each lexicon learns at different rates
        int maxCircle = GetLexiconCircleKnownAtLevel(GetLevelByClass(nClass, oPC), lexicon);
        if (circleLevel > maxCircle)
            return FALSE;

        if (GetRemainingTruenameChoices(nClass, lexicon, oPC))
            return TRUE;
        return FALSE;
    }

    // logic for ToB
    if (GetIsBladeMagicClass(nClass))
    {
        if (circleLevel > GetMaxInitiatorCircle(nClass, oPC))
            return FALSE;

        // if you do not have the prerequisite amount of maneuevers to learn
        // the maneuever, then you can't learn it.
        if (!HasPreRequisitesForManeuver(nClass, spellbookId, oPC))
            return FALSE;

        // maneuvers and stances have their own seperate limits
        string sFile = GetClassSpellbookFile(nClass);
        int type = StringToInt(Get2DACache(sFile, "Type", spellbookId));
        if (type == MANEUVER_TYPE_BOOST
            || type == MANEUVER_TYPE_COUNTER
            || type == MANEUVER_TYPE_STRIKE
            || type == MANEUVER_TYPE_MANEUVER)
        {
            int remainingMan = GetRemainingManeuverChoices(nClass, oPC);
            if (remainingMan)
                return TRUE;
            return FALSE;
        }
        if (type == MANEUVER_TYPE_STANCE)
        {
            int remainingStance = GetRemainingStanceChoices(nClass, oPC);
            if (remainingStance)
                return TRUE;
            return FALSE;
        }
    }

    if (nClass == CLASS_TYPE_ARCHIVIST)
    {
        int maxLevel = GetMaxSpellLevelForCasterLevel(nClass, GetCasterLevelByClass(nClass, oPC));
        if (circleLevel > maxLevel)
            return FALSE;
    }

    // default logic
    // determine remaining Spell/Power choices left for player, if there is any
    // remaining, enable the buttons.
    if (GetRemainingSpellChoices(nClass, circleLevel, oPC))
        return TRUE;

    return FALSE;
}

int ShouldAddSpellToSpellButtons(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    json chosenSpells = GetChosenSpellListObject(nClass, oPC);
    string sFile = GetClassSpellbookFile(nClass);

    string spellLevel = Get2DACache(sFile, "Level", spellbookId);
    json chosenSpellsAtCircle = JsonObjectGet(chosenSpells, spellLevel);

    int chosenSpellCount = JsonGetLength(chosenSpellsAtCircle);

    // if the spell is in the chosen list, then don't add it to the available list
    int i;
    for (i = 0; i < chosenSpellCount; i++)
    {
        int chosenSpellId = JsonGetInt(JsonArrayGet(chosenSpellsAtCircle, i));
        if (chosenSpellId == spellbookId)
            return FALSE;
    }

    if (GetIsBladeMagicClass(nClass))
        return IsAllowedDiscipline(nClass, spellbookId, oPC);

    // if a psionic class we need to see if the power is a expanded knowledge
    // choice and if we should show it or not
    if (GetIsPsionicClass(nClass))
        return ShouldAddPower(nClass, spellbookId, oPC);

    // for these set of classes we need to only allow 'advanced learning'
    // spells to be added
    if (nClass == CLASS_TYPE_BEGUILER
        || nClass == CLASS_TYPE_DREAD_NECROMANCER
        || nClass == CLASS_TYPE_WARMAGE)
    {
        int advancedLearning = StringToInt(Get2DACache(sFile, "AL", spellbookId));
        if (advancedLearning)
            return TRUE;
        return FALSE;
    }

    if (nClass == CLASS_TYPE_ARCHIVIST)
    {
        int nLevel = GetLevelByClass(nClass, oPC);
        if ((StringToInt(spellLevel) == 0) && (nLevel == 1))
            return FALSE;
        int advancedLearning = StringToInt(Get2DACache(sFile, "AL", spellbookId));
        if (advancedLearning)
            return FALSE;
    }

    return TRUE;
}

json GetChosenSpellListObject(int nClass, object oPC=OBJECT_SELF)
{
    json retValue = GetLocalJson(oPC, NUI_LEVEL_UP_CHOSEN_SPELLS_VAR);
    // if this isn't set yet then we the chosen currently is the known spells
    if (retValue == JsonNull())
    {
        retValue = GetKnownSpellListObject(nClass, oPC);
        SetLocalJson(oPC, NUI_LEVEL_UP_CHOSEN_SPELLS_VAR, retValue);
    }

    return retValue;
}

json GetKnownSpellListObject(int nClass, object oPC=OBJECT_SELF)
{
    json retValue = GetLocalJson(oPC, NUI_LEVEL_UP_KNOWN_SPELLS_VAR);
    if (retValue == JsonNull())
        retValue = JsonObject();
    else
        return retValue;

    string sFile = GetClassSpellbookFile(nClass);
    int totalSpells = Get2DARowCount(sFile);

    if (nClass == CLASS_TYPE_ARCHIVIST)
    {
        int i;
        for (i = 0; i < 10; i++)
        {
            string sSpellbook = GetSpellsKnown_Array(nClass, i);

            int nSize = persistant_array_get_size(oPC, sSpellbook);

            int j;
            for (j = 0; j < nSize; j++)
            {
                int knownSpellbookID = persistant_array_get_int(oPC, sSpellbook, j);
                // we store things in a JSON Object where the spell circle
                // is the key to a JsonArray of spellbookIds.
                json spellList = JsonObjectGet(retValue, IntToString(i));
                if (spellList == JsonNull())
                    spellList = JsonArray();
                spellList = JsonArrayInsert(spellList, JsonInt(knownSpellbookID));
                retValue = JsonObjectSet(retValue, IntToString(i), spellList);
            }
        }
    }
    else
    {
        // loop through all the spells in the class's 2da
        int i;
        for (i = 0; i < totalSpells; i++)
        {
            int featId = StringToInt(Get2DACache(sFile, "FeatID", i));
            // if you have the feat, you know the spell
            if (featId && GetHasFeat(featId, oPC, TRUE))
            {
                string spellLevel = Get2DACache(sFile, "Level", i);
                int nSpellLevel = StringToInt(spellLevel);
                // some spells have **** as their level, so make sure we have
                // parsed it correctly
                if (IntToString(nSpellLevel) == spellLevel)
                {
                    // we store things in a JSON Object where the spell circle
                    // is the key to a JsonArray of spellbookIds.
                    json spellList = JsonObjectGet(retValue, spellLevel);
                    if (spellList == JsonNull())
                        spellList = JsonArray();
                    spellList = JsonArrayInsert(spellList, JsonInt(i));
                    retValue = JsonObjectSet(retValue, spellLevel, spellList);
                }
            }
        }
    }

    SetLocalJson(oPC, NUI_LEVEL_UP_KNOWN_SPELLS_VAR, retValue);
    return retValue;
}

json GetSpellListObject(int nClass, object oPC=OBJECT_SELF)
{
    json retValue = GetLocalJson(oPC, NUI_LEVEL_UP_SPELLBOOK_OBJECT_CACHE_VAR + IntToString(nClass));
    if (retValue == JsonNull())
        retValue = JsonObject();
    else
        return retValue;

    string sFile = GetClassSpellbookFile(nClass);
    int totalSpells = Get2DARowCount(sFile);

    // loop through all the spells in the 2da and convert it to a JSON Object representation
    int i;
    for (i = 0; i < totalSpells; i++)
    {
        string spellLevel = Get2DACache(sFile, "Level", i);
        int nSpellLevel = StringToInt(spellLevel);
        // some spells in the list have **** as spell level. We need to ignore them
        if (IntToString(nSpellLevel) == spellLevel)
        {
            if (nClass == CLASS_TYPE_ARCHIVIST)
            {
                int reqFeat = StringToInt(Get2DACache(sFile, "ReqFeat", i));
                if (!reqFeat)
                {
                    json spellList = JsonObjectGet(retValue, spellLevel);
                    if (spellList == JsonNull())
                        spellList = JsonArray();
                    spellList = JsonArrayInsert(spellList, JsonInt(i));
                    retValue = JsonObjectSet(retValue, spellLevel, spellList);
                }
            }
            else
            {
                json spellList = JsonObjectGet(retValue, spellLevel);
                if (spellList == JsonNull())
                    spellList = JsonArray();
                spellList = JsonArrayInsert(spellList, JsonInt(i));
                retValue = JsonObjectSet(retValue, spellLevel, spellList);
            }
        }
    }

    SetLocalJson(oPC, NUI_LEVEL_UP_SPELLBOOK_OBJECT_CACHE_VAR + IntToString(nClass), retValue);
    return retValue;
}

int GetRemainingSpellChoices(int nClass, int circleLevel, object oPC=OBJECT_SELF)
{
    int chosenCircle = GetLocalInt(oPC, NUI_LEVEL_UP_SELECTED_CIRCLE_VAR);
    int remainingChoices = 0;

    // we only want to cache on the current circle.
    if (chosenCircle == circleLevel)
    {
        remainingChoices = GetLocalInt(oPC, NUI_LEVEL_UP_REMAINING_CHOICES_CACHE_VAR);
        // -20 is the chosen number to say there is no cache set since 0 is
        // a valid option
        if (remainingChoices != -20)
            return remainingChoices;
    }

    // logic for psionics
    if (GetIsPsionicClass(nClass))
        remainingChoices = GetRemainingPowerChoices(nClass, circleLevel, oPC);

    // logic for ToB
    if (GetIsBladeMagicClass(nClass))
        remainingChoices = (GetRemainingManeuverChoices(nClass, oPC) +
            GetRemainingStanceChoices(nClass, oPC));

    // logic for Invokers
    if (GetIsInvocationClass(nClass))
        remainingChoices = GetRemainingInvocationChoices(nClass, circleLevel, oPC);

    // logic for mysteries
    if (GetIsShadowMagicClass(nClass))
    {
        int totalChosen = 0;
        json chosenSpells = GetChosenSpellListObject(nClass, oPC);
        json circles = JsonObjectKeys(chosenSpells);
        int totalCircles = JsonGetLength(circles);

        int i;
        for (i = 0; i < totalCircles; i++)
        {
            // loop through each circle and add its total spells together since
            // we don't care about where you spend your spells, only the amount
            string currentCircle = JsonGetString(JsonArrayGet(circles, i));
            json spellList = JsonObjectGet(chosenSpells, currentCircle);
            if (spellList != JsonNull())
                totalChosen += JsonGetLength(spellList);
        }

        int maxKnown = GetMaxMysteryCount(oPC, nClass);
        remainingChoices = (maxKnown - totalChosen);
    }

    if (GetIsTruenamingClass(nClass))
        remainingChoices = GetRemainingTruenameChoices(nClass, -1, oPC);

    if (nClass == CLASS_TYPE_ARCHIVIST)
    {
        int nLevel = GetLevelByClass(CLASS_TYPE_ARCHIVIST, oPC);
        int spellsAvailable;
        if (nLevel == 1)
            spellsAvailable = (3 + GetAbilityModifier(ABILITY_INTELLIGENCE, oPC));
        else
            spellsAvailable = 2;

        json newSpells = GetArchivistNewSpellsList(oPC);
        int totalNewSpells = JsonGetLength(newSpells);
        remainingChoices = (spellsAvailable - totalNewSpells);
    }
    if (GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS)
    {
        json chosenSpells = GetChosenSpellListObject(nClass, oPC);
        int totalSpellsKnown = 0;
        int casterLevel = GetCasterLevelByClass(nClass, oPC);

        // these specific classes only learn at specific rates
        int advancedLearning = 0;
        // beguiler learns every 4th level starting on 3
        if (nClass == CLASS_TYPE_BEGUILER)
            advancedLearning = ((casterLevel+1)/4);
        // dread learns every 4th level
        if (nClass == CLASS_TYPE_DREAD_NECROMANCER)
            advancedLearning = (casterLevel/4);
        // warmage is a bastard child that choses when it learns a spell whenever
        // it decides it feels like it wants to
        if (nClass == CLASS_TYPE_WARMAGE)
        {
            if (casterLevel >= 3) // 1 choice
                advancedLearning++;
            if (casterLevel >= 6) // 2 choice
                advancedLearning++;
            if (casterLevel >= 11) // 3 choice
                advancedLearning++;
            if (casterLevel >= 16) // 4 choice
                advancedLearning++;
            if (casterLevel >= 24) // 5 choice
                advancedLearning++;
            if (casterLevel >= 28) // 6 choice
                advancedLearning++;
            if (casterLevel >= 32) // 7 choice
                advancedLearning++;
            if (casterLevel >= 36) // 8 choice
                advancedLearning++;
            if (casterLevel >= 40) // 9 choice
                advancedLearning++;
        }

        if (advancedLearning)
        {
            int maxSpellLevel = GetMaxSpellLevelForCasterLevel(nClass, casterLevel);
            // can't learn what you can't achieve
            if (circleLevel > maxSpellLevel)
                remainingChoices = 0;
            else
            {
                int chosenSpellsAmount = 0;

                json circles = JsonObjectKeys(chosenSpells);
                int totalCircles = JsonGetLength(circles);
                string sFile = GetClassSpellbookFile(nClass);

                int i;
                for (i = 0; i <= totalCircles; i++)
                {
                    string currentCircle = JsonGetString(JsonArrayGet(circles, i));
                    json spellList = JsonObjectGet(chosenSpells, currentCircle);
                    if ((spellList != JsonNull()))
                    {
                        // loop through the spells of a given circle and count how
                        // many advanced learning spells you know
                        int numOfSpells = JsonGetLength(spellList);
                        int j;
                        for (j = 0; j < numOfSpells; j++)
                        {
                            int nSpellbookID = JsonGetInt(JsonArrayGet(spellList, j));
                            int isAL = StringToInt(Get2DACache(sFile, "AL", nSpellbookID));
                            if (isAL)
                                chosenSpellsAmount++;
                        }
                    }
                }

                remainingChoices = (advancedLearning - chosenSpellsAmount);
            }
        }
        else
        {
            // default logic for spont casters
            totalSpellsKnown = GetSpellKnownMaxCount(casterLevel, circleLevel, nClass, oPC);
            // Favoured Soul has more 0 choices than there are spells for some reason
            if (nClass == CLASS_TYPE_FAVOURED_SOUL && circleLevel == 0 && totalSpellsKnown > 6)
                totalSpellsKnown = 7;

            // logic for spont casters
            json selectedCircle = JsonObjectGet(chosenSpells, IntToString(circleLevel));
            if (selectedCircle == JsonNull())
                return totalSpellsKnown;

            int selectedSpellCount = JsonGetLength(selectedCircle);
            remainingChoices = (totalSpellsKnown - selectedSpellCount);
        }
    }

    if (chosenCircle == circleLevel)
        SetLocalInt(oPC, NUI_LEVEL_UP_REMAINING_CHOICES_CACHE_VAR, remainingChoices);
    if (DEBUG) DoDebug("Remaining spell choices is " + IntToString(remainingChoices));
    return remainingChoices;
}

void FinishLevelUp(int nClass, object oPC=OBJECT_SELF)
{
    RemoveSpells(nClass, oPC);
    LearnSpells(nClass, oPC);
    if (nClass == CLASS_TYPE_ARCHIVIST)
    {
        int nLevel = GetLevelByClass(nClass, oPC);
        SetPersistantLocalInt(oPC, "LastSpellGainLevel", nLevel);
    }
    ClearLevelUpNUICaches(nClass, oPC);
}

void ClearLevelUpNUICaches(int nClass, object oPC=OBJECT_SELF)
{
    // clear the chosen spells you made
    DeleteLocalJson(oPC, NUI_LEVEL_UP_CHOSEN_SPELLS_VAR);
    // clear the known spells you have
    DeleteLocalJson(oPC, NUI_LEVEL_UP_KNOWN_SPELLS_VAR);
    SetLocalInt(oPC, NUI_LEVEL_UP_SELECTED_CIRCLE_VAR, -1);
    DeleteLocalInt(oPC, NUI_LEVEL_UP_SELECTED_CLASS_VAR);
    // clear the psionics selected choices
    DeleteLocalJson(oPC, NUI_LEVEL_UP_POWER_LIST_VAR);
    // clear the expanded choices for psionics and invokers
    DeleteLocalJson(oPC, NUI_LEVEL_UP_EXPANDED_CHOICES_VAR);
    DeleteLocalJson(oPC, NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR);
    // clear the PnP replace list
    DeleteLocalJson(oPC, NUI_LEVEL_UP_RELEARN_LIST_VAR);
    DeleteLocalJson(oPC, NUI_LEVEL_UP_ARCHIVIST_NEW_SPELLS_LIST_VAR);
    // for invocation and psionics we grab the list of known extra spells and cache it
    // so we need to clear those caches
    if (GetIsInvocationClass(nClass))
    {
        DeleteLocalJson(oPC, NUI_LEVEL_UP_SPELLID_LIST_VAR + IntToString(nClass) + "_0");
        DeleteLocalJson(oPC, NUI_LEVEL_UP_SPELLID_LIST_VAR + IntToString(nClass) + "_" + IntToString(INVOCATION_LIST_EXTRA));
        DeleteLocalJson(oPC, NUI_LEVEL_UP_SPELLID_LIST_VAR + IntToString(nClass) + "_" + IntToString(INVOCATION_LIST_EXTRA_EPIC));
    }
    if (GetIsPsionicClass(nClass))
    {
        DeleteLocalJson(oPC, NUI_LEVEL_UP_SPELLID_LIST_VAR + IntToString(nClass) + "_0");
        DeleteLocalJson(oPC, NUI_LEVEL_UP_SPELLID_LIST_VAR + IntToString(nClass) + "_" + IntToString(POWER_LIST_EXP_KNOWLEDGE));
        DeleteLocalJson(oPC, NUI_LEVEL_UP_SPELLID_LIST_VAR + IntToString(nClass) + "_" + IntToString(POWER_LIST_EPIC_EXP_KNOWLEDGE));
    }
    // for ToB we need to clear all the discipline info for determining PrC choice validity
    if (GetIsBladeMagicClass(nClass))
    {
        DeleteLocalJson(oPC, NUI_LEVEL_UP_DISCIPLINE_INFO_VAR + IntToString(CLASS_TYPE_SWORDSAGE));
        DeleteLocalJson(oPC, NUI_LEVEL_UP_DISCIPLINE_INFO_VAR + IntToString(CLASS_TYPE_WARBLADE));
        DeleteLocalJson(oPC, NUI_LEVEL_UP_DISCIPLINE_INFO_VAR + IntToString(CLASS_TYPE_CRUSADER));
    }
}

void RemoveSpells(int nClass, object oPC=OBJECT_SELF)
{
    // we don't remove on psionic classes and archivist
    if (GetIsPsionicClass(nClass) || nClass == CLASS_TYPE_ARCHIVIST)
        return;

    json knownSpells = GetKnownSpellListObject(nClass, oPC);
    json chosenSpells = GetChosenSpellListObject(nClass, oPC);
    json spellCircles = JsonObjectKeys(knownSpells);
    int totalCircles = JsonGetLength(spellCircles);

    // loop through all the known spells circles
    int i;
    for (i = 0; i < totalCircles; i++)
    {
        string sSpellLevel = JsonGetString(JsonArrayGet(spellCircles, i));
        int nSpellLevel = StringToInt(sSpellLevel);

        json chosenCircle = JsonObjectGet(knownSpells, sSpellLevel);
        int totalSpells = JsonGetLength(chosenCircle);

        // loop through the spell list at the given circle
        int y;
        for (y = 0; y < totalSpells; y++)
        {
            int nSpellbookID = JsonGetInt(JsonArrayGet(chosenCircle, y));
            // if the spell is not a chosen spell, then it was removed
            if (!SpellIsWithinObject(nClass, nSpellbookID, nSpellLevel, chosenSpells, oPC))
            {
                if (GetIsInvocationClass(nClass))
                {
                    string sFile = GetClassSpellbookFile(nClass);
                    string spellId = Get2DACache(sFile, "SpellID", nSpellbookID);
                    int chosenList = 0;
                    // check to see if its a extra invocation choice and set it's chosen list
                    if (GetHasFeat(FEAT_EXTRA_INVOCATION_I, oPC))
                    {
                        json expList = GetSpellIDsKnown(nClass, oPC, INVOCATION_LIST_EXTRA);
                        if (JsonObjectGet(expList, spellId) != JsonNull())
                            chosenList = INVOCATION_LIST_EXTRA;
                    }
                    if (GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_I, oPC))
                    {
                        json expList = GetSpellIDsKnown(nClass, oPC, INVOCATION_LIST_EXTRA_EPIC);
                        if (JsonObjectGet(expList, spellId) != JsonNull())
                            chosenList = INVOCATION_LIST_EXTRA_EPIC;
                    }
                    RemoveSpellKnown(nClass, nSpellbookID, oPC, chosenList);
                }
                if (GetIsBladeMagicClass(nClass) || GetIsShadowMagicClass(nClass))
                    RemoveSpellKnown(nClass, nSpellbookID, oPC);

                if (GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS)
                {
                    string sFile = GetClassSpellbookFile(nClass);
                    string sSpellBook = GetSpellsKnown_Array(nClass);
                    string spellsAtLevelList = "SpellsKnown_" + IntToString(nClass) + "_AtLevel" + IntToString(GetHitDice(oPC));
                    // remove the spell from the spellbook
                    array_extract_int(oPC, sSpellBook, nSpellbookID);
                    array_extract_int(oPC, spellsAtLevelList, nSpellbookID);
                    // wipe the spell from the player
                    int ipFeatID = StringToInt(Get2DACache(sFile, "IPFeatID", nSpellbookID));
                    RemoveIPFeat(oPC, ipFeatID);
                }
            }
        }
    }
}

void LearnSpells(int nClass, object oPC=OBJECT_SELF)
{
    if (GetIsPsionicClass(nClass))
    {
        LearnPowers(nClass, oPC);
        return;
    }

    json chosenSpells = GetChosenSpellListObject(nClass, oPC);
    json knownSpells = GetKnownSpellListObject(nClass, oPC);
    json spellCircles = JsonObjectKeys(chosenSpells);
    int totalCircles = JsonGetLength(spellCircles);

    // loop through chosen spells circles
    int i;
    for (i = 0; i < totalCircles; i++)
    {
        string sSpellLevel = JsonGetString(JsonArrayGet(spellCircles, i));
        int nSpellLevel = StringToInt(sSpellLevel);

        json chosenCircle = JsonObjectGet(chosenSpells, sSpellLevel);
        int totalSpells = JsonGetLength(chosenCircle);

        // loop through the spell list at the circle
        int y;
        for (y = 0; y < totalSpells; y++)
        {
            int nSpellbookID = JsonGetInt(JsonArrayGet(chosenCircle, y));
            // if the spell is not in the known spell list then it was newly added
            if (!SpellIsWithinObject(nClass, nSpellbookID, nSpellLevel, knownSpells, oPC))
            {
                if (GetIsTruenamingClass(nClass))
                {
                    string sFile = GetClassSpellbookFile(nClass);
                    // find out what lexicon it belongs to and add it to that
                    int lexicon = StringToInt(Get2DACache(sFile, "Lexicon", nSpellbookID));
                    AddUtteranceKnown(oPC, nClass, nSpellbookID, lexicon, TRUE, GetHitDice(oPC));
                }

                if (GetIsShadowMagicClass(nClass))
                    AddMysteryKnown(oPC, nClass, nSpellbookID, TRUE, GetHitDice(oPC));

                if (GetIsInvocationClass(nClass))
                {
                    string sFile = GetClassSpellbookFile(nClass);
                    string spellId = Get2DACache(sFile, "SpellID", nSpellbookID);
                    int chosenList = nClass;
                    json expList = GetExpandedChoicesList(nClass, oPC);
                    // if the invocation belongs to the extra or epic extra list
                    // then we need to provide those list ids instead.
                    if (JsonObjectGet(expList, spellId) != JsonNull())
                        chosenList = INVOCATION_LIST_EXTRA;
                    expList = GetEpicExpandedChoicesList(nClass, oPC);
                    if (JsonObjectGet(expList, spellId) != JsonNull())
                        chosenList = INVOCATION_LIST_EXTRA_EPIC;
                    AddInvocationKnown(oPC, chosenList, nSpellbookID, TRUE, GetHitDice(oPC));
                }

                if (GetIsBladeMagicClass(nClass))
                {
                    string sFile = GetClassSpellbookFile(nClass);
                    int maneuverType = StringToInt(Get2DACache(sFile, "Type", nSpellbookID));
                    // we save our moves either to stance or maneuever
                    if (maneuverType != MANEUVER_TYPE_STANCE)
                        maneuverType = MANEUVER_TYPE_MANEUVER;

                    AddManeuverKnown(oPC, nClass, nSpellbookID, maneuverType, TRUE, GetHitDice(oPC));
                }
                int nSpellbookType = GetSpellbookTypeForClass(nClass);
                if (nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS
                    || nClass == CLASS_TYPE_ARCHIVIST)
                {
                    // these classes have their own syste,
                    if (nClass == CLASS_TYPE_BEGUILER
                        || nClass == CLASS_TYPE_DREAD_NECROMANCER
                        || nClass == CLASS_TYPE_WARMAGE)
                    {
                        int casterLevel = GetCasterLevelByClass(nClass, oPC);
                        // this is taken from prc_s_spellgain as it is coupled with the
                        // dynamic dialogue system
                        int advancedLearning = 0;
                        // beguilers learn every 4th level starting on 3rd
                        if (nClass == CLASS_TYPE_BEGUILER)
                            advancedLearning = ((casterLevel+1)/4);
                        // dread learns every 4th level
                        if (nClass == CLASS_TYPE_DREAD_NECROMANCER)
                            advancedLearning = (casterLevel/4);
                        if (nClass == CLASS_TYPE_WARMAGE)
                        {
                            if (casterLevel >= 3)
                                advancedLearning++;
                        }

                        if (advancedLearning)
                        {
                            // incremenet the total advanced learning known
                            int nAdvLearn = GetPersistantLocalInt(oPC, "AdvancedLearning_"+IntToString(nClass));
                            nAdvLearn++;
                            SetPersistantLocalInt(oPC, "AdvancedLearning_"+IntToString(nClass), nAdvLearn);
                        }
                    }

                    // get location of persistant storage on the hide
                    string sSpellbook = GetSpellsKnown_Array(nClass, nSpellLevel);
                    if (DEBUG) DoDebug("Adding spell " + IntToString(nSpellbookID) + "to " + sSpellbook);
                    //object oToken = GetHideToken(oPC);

                    // Create spells known persistant array if it is missing
                    int nSize = persistant_array_get_size(oPC, sSpellbook);
                    if (nSize < 0)
                    {
                        persistant_array_create(oPC, sSpellbook);
                        nSize = 0;
                    }

                    string spellsAtLevelList = "SpellsKnown_" + IntToString(nClass) + "_AtLevel" + IntToString(GetHitDice(oPC));
                    int spellsAtLevelSize = persistant_array_get_size(oPC, spellsAtLevelList);
                    if (spellsAtLevelSize < 0)
                    {
                        persistant_array_create(oPC, spellsAtLevelList);
                        spellsAtLevelSize = 0;
                    }
                    // set the list of spells learned at this level
                    string sFile = GetClassSpellbookFile(nClass);
                    int spellId = StringToInt(Get2DACache(sFile, "SpellID", nSpellbookID));
                    persistant_array_set_int(oPC, spellsAtLevelList, spellsAtLevelSize, spellId);
                    if (DEBUG) DoDebug("Adding spells to array " + spellsAtLevelList);

                    // Mark the spell as known (e.g. add it to the end of oPCs spellbook)
                    persistant_array_set_int(oPC, sSpellbook, nSize, nSpellbookID);

                    if (nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
                    {
                        // add spell
                        string sArrayName = "NewSpellbookMem_" + IntToString(nClass);
                        int featId = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));
                        int ipFeatID = StringToInt(Get2DACache(sFile, "IPFeatID", nSpellbookID));
                        AddSpellUse(oPC, nSpellbookID, nClass, sFile, sArrayName, nSpellbookType, GetPCSkin(oPC), featId, ipFeatID);
                    }
                }
            }
        }
    }
}

int EnableChosenButton(int nClass, int spellbookId, int circleLevel, object oPC=OBJECT_SELF)
{
    if (GetIsPsionicClass(nClass)
        || GetIsShadowMagicClass(nClass)
        || GetIsTruenamingClass(nClass)
        || nClass == CLASS_TYPE_DREAD_NECROMANCER
        || nClass == CLASS_TYPE_BEGUILER
        || nClass == CLASS_TYPE_WARMAGE
        || nClass == CLASS_TYPE_ARCHIVIST)
    {
        json knownSpells = GetKnownSpellListObject(nClass, oPC);
        json currentCircle = JsonObjectGet(knownSpells, IntToString(circleLevel));
        int totalSpells = JsonGetLength(currentCircle);
        int i;
        for (i = 0; i < totalSpells; i++)
        {
            // if spell belongs to known spells, then disable, we don't allow
            // replacing for these classes.
            int currentSpellbookId = JsonGetInt(JsonArrayGet(currentCircle, i));
            if (currentSpellbookId == spellbookId)
                return FALSE;
        }

    }

    if (GetIsBladeMagicClass(nClass))
    {
        string sFile = GetClassSpellbookFile(nClass);
        int prereqs = StringToInt(Get2DACache(sFile, "Prereqs", spellbookId));
        string discipline = Get2DACache(sFile, "Discipline", spellbookId);
        // if the maneuver is required for others to exist, t hen disable it
        if (IsRequiredForOtherManeuvers(nClass, prereqs, discipline, oPC))
            return FALSE;
        // if it is required for a PRC to exist, then disable it.
        if (IsRequiredForToBPRCClass(nClass, spellbookId, oPC))
            return FALSE;
    }

    if (GetIsInvocationClass(nClass))
    {
        // dragon Shamans can't replace
        if (nClass == CLASS_TYPE_DRAGON_SHAMAN)
        {
            json invokKnown = GetSpellIDsKnown(nClass, oPC);
            string sFile = GetClassSpellbookFile(nClass);
            string spellId = Get2DACache(sFile, "SpellID", spellbookId);
            json chosenSpell = JsonObjectGet(invokKnown, spellId);
            if (chosenSpell != JsonNull())
                return FALSE;
        }
    }

    // If we do not use the bioware unlearn system, we follow PnP
    if (!GetPRCSwitch(PRC_BIO_UNLEARN))
    {
        json knownSpells = GetKnownSpellListObject(nClass, oPC);
        json currentCircle = JsonObjectGet(knownSpells, IntToString(circleLevel));
        int totalSpells = JsonGetLength(currentCircle);
        int i;
        for (i = 0; i < totalSpells; i++)
        {
            int currentSpellbookId = JsonGetInt(JsonArrayGet(currentCircle, i));
            // if the spell belongs to the known spell list, then we need to determine
            if (currentSpellbookId == spellbookId)
            {
                json unlearnList = GetChosenReplaceListObject(oPC);
                int totalUnlearned = JsonGetLength(unlearnList);
                int totalAllowed = GetPRCSwitch(PRC_UNLEARN_SPELL_MAXNR);
                // we default to 1 if no max number of unlearns is set
                if (!totalAllowed)
                    totalAllowed = 1;
                // we cannot replace a spell if we have more than or equal to the
                // amount of relearns allowed, therefore disable.
                return totalUnlearned < totalAllowed;
            }
        }

    }

    return TRUE;
}

void ResetChoices(object oPC=OBJECT_SELF)
{
    // reset choices made so far
    DeleteLocalJson(oPC, NUI_LEVEL_UP_CHOSEN_SPELLS_VAR);
    DeleteLocalJson(oPC, NUI_LEVEL_UP_POWER_LIST_VAR);
    DeleteLocalJson(oPC, NUI_LEVEL_UP_EXPANDED_CHOICES_VAR);
    DeleteLocalJson(oPC, NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR);
    DeleteLocalJson(oPC, NUI_LEVEL_UP_RELEARN_LIST_VAR);
    DeleteLocalJson(oPC, NUI_LEVEL_UP_ARCHIVIST_NEW_SPELLS_LIST_VAR);
}

void RemoveSpellKnown(int nClass, int spellbookId, object oPC=OBJECT_SELF, int nList=0)
{
    string sBase;
    string levelArrayBaseId;
    string generalArrayBaseId;
    string totalCountId;

    string sFile = GetClassSpellbookFile(nClass);
    int chosenList = (nList != 0) ? nList : nClass;
    int spellID = StringToInt(Get2DACache(sFile, "SpellID", spellbookId));

    // if statements are to change the location of the spellbook we are grabbing
    if (GetIsShadowMagicClass(nClass))
    {
        sBase = _MYSTERY_LIST_NAME_BASE + IntToString(chosenList);
        levelArrayBaseId = _MYSTERY_LIST_LEVEL_ARRAY;
        generalArrayBaseId = _MYSTERY_LIST_GENERAL_ARRAY;
        totalCountId = _MYSTERY_LIST_TOTAL_KNOWN;
    }

    if (GetIsInvocationClass(nClass))
    {
        sBase = _INVOCATION_LIST_NAME_BASE + IntToString(chosenList);
        levelArrayBaseId = _INVOCATION_LIST_LEVEL_ARRAY;
        generalArrayBaseId = _INVOCATION_LIST_GENERAL_ARRAY;
        totalCountId = _INVOCATION_LIST_TOTAL_KNOWN;
    }

    if (GetIsBladeMagicClass(nClass))
    {
        int maneuverType = StringToInt(Get2DACache(sFile, "Type", spellbookId));
        if (maneuverType != MANEUVER_TYPE_STANCE) maneuverType = MANEUVER_TYPE_MANEUVER;
        sBase = _MANEUVER_LIST_NAME_BASE + IntToString(chosenList) + IntToString(maneuverType);
        levelArrayBaseId = _MANEUVER_LIST_LEVEL_ARRAY;
        generalArrayBaseId = _MANEUVER_LIST_GENERAL_ARRAY;
        totalCountId = _MANEUVER_LIST_TOTAL_KNOWN;
    }

    if (GetIsTruenamingClass(nClass))
    {
        string lexicon = Get2DACache(sFile, "Lexicon", spellbookId);
        sBase = _UTTERANCE_LIST_NAME_BASE + IntToString(chosenList) + lexicon;
        levelArrayBaseId = _UTTERANCE_LIST_LEVEL_ARRAY;
        generalArrayBaseId = _UTTERANCE_LIST_GENERAL_ARRAY;
        totalCountId = _UTTERANCE_LIST_TOTAL_KNOWN;
    }

    string sTestArray;

    int found = FALSE;

    int i;
    for (i = 1; i <= GetHitDice(oPC); i++)
    {
        sTestArray = sBase + levelArrayBaseId + IntToString(i);
        if (persistant_array_exists(oPC, sTestArray))
        {
            // if we found the spell, then we remove it.
            if (persistant_array_extract_int(oPC, sTestArray, spellID) >= 0)
            {
                found = TRUE;
                break;
            }
        }
    }

    if (!found)
    {
        // if not found we check the general list where spells aren't set to a level.
        sTestArray = sBase + generalArrayBaseId;
        if (persistant_array_exists(oPC, sTestArray))
        {
            //if we could not find the spell here, something went wrong
            if (persistant_array_extract_int(oPC, sTestArray, spellID) < 0)
            {
                if (DEBUG) DoDebug("Could not find spellID " + IntToString(spellID) + " in the class's spellbook!");
                return;
            }
        }
    }

    // decrement the amount of spells known.
    SetPersistantLocalInt(oPC, sBase + totalCountId,
                          GetPersistantLocalInt(oPC, sBase + totalCountId) - 1
                          );

    // if ToB we need to decrement the specific discipline as well.
    if (GetIsBladeMagicClass(nClass))
    {
        int maneuverType = StringToInt(Get2DACache(sFile, "Type", spellbookId));
        if (maneuverType == MANEUVER_TYPE_BOOST
            || maneuverType == MANEUVER_TYPE_COUNTER
            || maneuverType == MANEUVER_TYPE_STRIKE
            || maneuverType == MANEUVER_TYPE_MANEUVER)
            maneuverType = MANEUVER_TYPE_MANEUVER;
        string sDisciplineArray = _MANEUVER_LIST_DISCIPLINE + IntToString(maneuverType) + "_" + Get2DACache(sFile, "Discipline", spellbookId);
        SetPersistantLocalInt(oPC, sDisciplineArray,
                      GetPersistantLocalInt(oPC, sDisciplineArray) - 1);
    }

    // remove spell from player
    int ipFeatID = StringToInt(Get2DACache(sFile, "IPFeatID", spellbookId));
    RemoveIPFeat(oPC, ipFeatID);
}

json GetSpellIDsKnown(int nClass, object oPC=OBJECT_SELF, int nList=0)
{
    json spellIds = GetLocalJson(oPC, NUI_LEVEL_UP_SPELLID_LIST_VAR + IntToString(nClass) + "_" + IntToString(nList));
    if (spellIds == JsonNull())
        spellIds = JsonObject();
    else
        return spellIds;

    string sBase;
    string levelArrayBaseId;
    string generalArrayBaseId;
    // if we are given a listId then use that instead, used for extra choices and
    // expanded knowledge
    int chosenList = (nList != 0) ? nList : nClass;
    // these if checks are for setting class specific ids
    if (nClass == CLASS_TYPE_DRAGON_SHAMAN
        || nClass == CLASS_TYPE_DRAGONFIRE_ADEPT
        || nClass == CLASS_TYPE_WARLOCK)
    {
        sBase = _INVOCATION_LIST_NAME_BASE + IntToString(chosenList);
        levelArrayBaseId = _INVOCATION_LIST_LEVEL_ARRAY;
        generalArrayBaseId = _INVOCATION_LIST_GENERAL_ARRAY;
    }
    if (GetIsPsionicClass(nClass))
    {
        sBase = _POWER_LIST_NAME_BASE + IntToString(chosenList);
        levelArrayBaseId = _POWER_LIST_LEVEL_ARRAY;
        generalArrayBaseId = _POWER_LIST_GENERAL_ARRAY;
    }

    // go through the level list and translate the spellIds into a JSON Object
    // structure for easier access.
    int i;
    for (i = 1; i <= GetHitDice(oPC); i++)
    {
        string sTestArray = sBase + levelArrayBaseId + IntToString(i);
        if (persistant_array_exists(oPC, sTestArray))
        {
            int nSize = persistant_array_get_size(oPC, sTestArray);

            int j;
            for (j = 0; j < nSize; j++)
            {
                spellIds = JsonObjectSet(spellIds, IntToString(persistant_array_get_int(oPC, sTestArray, j)), JsonBool(TRUE));
            }
        }
    }

    // go through the general list and translate the spellIds into a JSON Object
    // structure for easier access.
    string sTestArray = sBase + generalArrayBaseId;
    if (persistant_array_exists(oPC, sTestArray))
    {
        int nSize = persistant_array_get_size(oPC, sTestArray);

        int j;
        for (j = 0; j < nSize; j++)
        {
            spellIds = JsonObjectSet(spellIds, IntToString(persistant_array_get_int(oPC, sTestArray, j)), JsonBool(TRUE));
        }
    }

    SetLocalJson(oPC, NUI_LEVEL_UP_SPELLID_LIST_VAR + IntToString(nClass) + "_" + IntToString(nList), spellIds);
    return spellIds;
}

string ReasonForDisabledSpell(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    string sFile = GetClassSpellbookFile(nClass);
    int circleLevel = StringToInt(Get2DACache(sFile, "Level", spellbookId));

    // logic for psionics
    if (GetIsPsionicClass(nClass))
    {
        int maxLevel = GetMaxPowerLevelForClass(nClass, oPC);
        if (circleLevel > maxLevel)
            return "You are unable to learn at this level currently.";

        // if its an expanded knowledge choice and we have already made all our
        // exp knowledge choices then it needs to be disabled.
        if (IsExpKnowledgePower(nClass, spellbookId, oPC))
        {
            int remainingExp = GetRemainingExpandedChoices(nClass, POWER_LIST_EXP_KNOWLEDGE, oPC)
                + GetRemainingExpandedChoices(nClass, POWER_LIST_EPIC_EXP_KNOWLEDGE, oPC);
            if (!remainingExp)
                return "You have no more expanded knowledge choices left.";
        }
    }

    if (GetIsShadowMagicClass(nClass))
    {
        // mysteries are weird, the circles are sectioned by 1-3, 4-6, 7-9
        // if you do not have at least 2 choices from a circle you can't progress up
        // so you can have access to circles 1,2,4,7,8
        int nType = 1;
        if (circleLevel >= 4 && circleLevel <= 6)
            nType = 2;
        if (circleLevel >= 7 && circleLevel <= 9)
            nType = 3;
        int maxPossibleCircle = GetMaxMysteryLevelLearnable(oPC, nClass, nType);
        if (circleLevel > maxPossibleCircle)
            return "You are unable to learn at this level currently.";
    }

    if (GetIsTruenamingClass(nClass))
    {
        int lexicon = StringToInt(Get2DACache(sFile, "Lexicon", spellbookId));
        // each lexicon learns at different rates
        int maxCircle = GetLexiconCircleKnownAtLevel(GetLevelByClass(nClass, oPC), lexicon);
        if (circleLevel > maxCircle)
            return "You are unable to learn at this level currently.";

        if (GetRemainingTruenameChoices(nClass, lexicon, oPC))
            return "";
        return "You have made all your truenaming choices.";
    }

    // logic for ToB
    if (GetIsBladeMagicClass(nClass))
    {
        if (circleLevel > GetMaxInitiatorCircle(nClass, oPC))
            return "You are unable to learn at this level currently.";

        // if you do not have the prerequisite amount of maneuevers to learn
        // the maneuever, then you can't learn it.
        if (!HasPreRequisitesForManeuver(nClass, spellbookId, oPC))
            return "You do not have the prerequisites for this maneuver.";

        // maneuvers and stances have their own seperate limits
        int type = StringToInt(Get2DACache(sFile, "Type", spellbookId));
        if (type == MANEUVER_TYPE_BOOST
            || type == MANEUVER_TYPE_COUNTER
            || type == MANEUVER_TYPE_STRIKE
            || type == MANEUVER_TYPE_MANEUVER)
        {
            int remainingMan = GetRemainingManeuverChoices(nClass, oPC);
            if (remainingMan)
                return "";
            return "You have made all your maneuver choices.";
        }
        if (type == MANEUVER_TYPE_STANCE)
        {
            int remainingStance = GetRemainingStanceChoices(nClass, oPC);
            if (remainingStance)
                return "";
            return "You have made all your stance choices.";
        }
    }

    // default logic
    // determine remaining Spell/Power choices left for player, if there is any
    // remaining, enable the buttons.
    if (GetRemainingSpellChoices(nClass, circleLevel, oPC))
        return "";

    return "You have made all your spell choices.";
}

string ReasonForDisabledChosen(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    string sFile = GetClassSpellbookFile(nClass);
    int circleLevel = StringToInt(Get2DACache(sFile, "Level", spellbookId));


    if (GetIsPsionicClass(nClass)
        || GetIsShadowMagicClass(nClass)
        || GetIsTruenamingClass(nClass)
        || nClass == CLASS_TYPE_DREAD_NECROMANCER
        || nClass == CLASS_TYPE_BEGUILER
        || nClass == CLASS_TYPE_WARMAGE)
    {
        json knownSpells = GetKnownSpellListObject(nClass, oPC);
        json currentCircle = JsonObjectGet(knownSpells, IntToString(circleLevel));
        int totalSpells = JsonGetLength(currentCircle);
        int i;
        for (i = 0; i < totalSpells; i++)
        {
            // if spell belongs to known spells, then disable, we don't allow
            // replacing for these classes.
            int currentSpellbookId = JsonGetInt(JsonArrayGet(currentCircle, i));
            if (currentSpellbookId == spellbookId)
                return "You cannot replace spells as this class.";
        }

    }

    if (GetIsBladeMagicClass(nClass))
    {
        int prereqs = StringToInt(Get2DACache(sFile, "Prereqs", spellbookId));
        string discipline = Get2DACache(sFile, "Discipline", spellbookId);
        // if the maneuver is required for others to exist, t hen disable it
        if (IsRequiredForOtherManeuvers(nClass, prereqs, discipline, oPC))
            return "This maneuver is required for another maneuver.";
        // if it is required for a PRC to exist, then disable it.
        if (IsRequiredForToBPRCClass(nClass, spellbookId, oPC))
            return "This maneuver is reuquired for a PRC class.";
    }

    if (GetIsInvocationClass(nClass))
    {
        // dragon Shamans can't replace
        if (nClass == CLASS_TYPE_DRAGON_SHAMAN)
        {
            json invokKnown = GetSpellIDsKnown(nClass, oPC);
            string spellId = Get2DACache(sFile, "SpellID", spellbookId);
            json chosenSpell = JsonObjectGet(invokKnown, spellId);
            if (chosenSpell != JsonNull())
                return "You cannot replace invocations as this class.";
        }
    }

    // If we do not use the bioware unlearn system, we follow PnP
    if (!GetPRCSwitch(PRC_BIO_UNLEARN))
    {
        json knownSpells = GetKnownSpellListObject(nClass, oPC);
        json currentCircle = JsonObjectGet(knownSpells, IntToString(circleLevel));
        int totalSpells = JsonGetLength(currentCircle);
        int i;
        for (i = 0; i < totalSpells; i++)
        {
            int currentSpellbookId = JsonGetInt(JsonArrayGet(currentCircle, i));
            // if the spell belongs to the known spell list, then we need to determine
            if (currentSpellbookId == spellbookId)
            {
                json unlearnList = GetChosenReplaceListObject(oPC);
                int totalUnlearned = JsonGetLength(unlearnList);
                int totalAllowed = GetPRCSwitch(PRC_UNLEARN_SPELL_MAXNR);
                // we default to 1 if no max number of unlearns is set
                if (!totalAllowed)
                    totalAllowed = 1;
                // we cannot replace a spell if we have more than or equal to the
                // amount of relearns allowed, therefore disable.
                if (totalUnlearned < totalAllowed)
                    return "";
                return "You can only replace " + IntToString(totalAllowed) + " spells during level up.";
            }
        }

    }

    return "";
}

json GetExpandedChoicesList(int nClass, object oPC=OBJECT_SELF)
{
    json expandedChoices = GetLocalJson(oPC, NUI_LEVEL_UP_EXPANDED_CHOICES_VAR);
    if (expandedChoices != JsonNull())
        return expandedChoices;

    if (GetIsPsionicClass(nClass))
        expandedChoices = GetSpellIDsKnown(nClass, oPC, POWER_LIST_EXP_KNOWLEDGE);
    else
        expandedChoices = GetSpellIDsKnown(nClass, oPC, INVOCATION_LIST_EXTRA);

    SetLocalJson(oPC, NUI_LEVEL_UP_EXPANDED_CHOICES_VAR, expandedChoices);
    return expandedChoices;
}

int GetRemainingExpandedChoices(int nClass, int nList, object oPC=OBJECT_SELF)
{
    int remainingChoices = 0;

    json expandedList = (nList == INVOCATION_LIST_EXTRA || nList == POWER_LIST_EXP_KNOWLEDGE ) ? GetExpandedChoicesList(nClass, oPC)
        : GetEpicExpandedChoicesList(nClass, oPC);
    int expChoicesCount = JsonGetLength(JsonObjectKeys(expandedList));
    int maxExpChoices = (GetIsPsionicClass(nClass)) ? GetMaxPowerCount(oPC, nList)
        : GetMaxInvocationCount(oPC, nList);
    remainingChoices += (maxExpChoices - expChoicesCount);

    return remainingChoices;
}

json GetEpicExpandedChoicesList(int nClass, object oPC=OBJECT_SELF)
{
    json expandedChoices = GetLocalJson(oPC, NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR);
    if (expandedChoices != JsonNull())
        return expandedChoices;

    if (GetIsPsionicClass(nClass))
        expandedChoices = GetSpellIDsKnown(nClass, oPC, POWER_LIST_EPIC_EXP_KNOWLEDGE);
    else
        expandedChoices = GetSpellIDsKnown(nClass, oPC, INVOCATION_LIST_EXTRA_EPIC);

    SetLocalJson(oPC, NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR, expandedChoices);
    return expandedChoices;
}

int IsSpellInExpandedChoices(int nClass, int nList, int spellId, object oPC=OBJECT_SELF)
{
    json expList = (nList == POWER_LIST_EXP_KNOWLEDGE || nList == INVOCATION_LIST_EXTRA) ? GetExpandedChoicesList(nClass, oPC)
        : GetEpicExpandedChoicesList(nClass, oPC);

    return (JsonObjectGet(expList, IntToString(spellId)) != JsonNull());
}

json GetChosenReplaceListObject(object oPC=OBJECT_SELF)
{
    json replaceList = GetLocalJson(oPC, NUI_LEVEL_UP_RELEARN_LIST_VAR);
    if (replaceList == JsonNull())
        replaceList = JsonObject();
    else
        return replaceList;

    SetLocalJson(oPC, NUI_LEVEL_UP_RELEARN_LIST_VAR, replaceList);
    return replaceList;
}

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Psionics                                                            ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////


int IsExpKnowledgePower(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    string sFile = GetClassSpellbookFile(nClass);
    int isExp = StringToInt(Get2DACache(sFile, "Exp", spellbookId));
    if (isExp)
        return TRUE;
    int featId = StringToInt(Get2DACache(sFile, "FeatID", spellbookId));
    int isOuterDomain = (featId) ? !CheckPowerPrereqs(featId, oPC) : FALSE;
    return isOuterDomain;
}

json GetCurrentPowerList(object oPC=OBJECT_SELF)
{
    json retValue = GetLocalJson(oPC, NUI_LEVEL_UP_POWER_LIST_VAR);
    if (retValue == JsonNull())
        retValue = JsonArray();
    else
        return retValue;

    SetLocalJson(oPC, NUI_LEVEL_UP_POWER_LIST_VAR, retValue);
    return retValue;
}

int ShouldAddPower(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    string sFile = GetClassSpellbookFile(nClass);
    int featId = StringToInt(Get2DACache(sFile, "FeatID", spellbookId));
    int isExp = StringToInt(Get2DACache(sFile, "Exp", spellbookId));
    // if the power is a expanded knowledge power
    if (!CheckPowerPrereqs(featId, oPC) || isExp)
    {
        // and we have a expanded knowledge choice left to make then show
        // the button
        int addPower = FALSE;
        int maxLevel = GetMaxPowerLevelForClass(nClass, oPC);
        int currentCircle = GetLocalInt(oPC, NUI_LEVEL_UP_SELECTED_CIRCLE_VAR);

        int choicesLeft = GetRemainingExpandedChoices(nClass, POWER_LIST_EXP_KNOWLEDGE, oPC);
		if (DEBUG) DoDebug("You still have " + IntToString(choicesLeft) + " expanded power choices left!");
        if (choicesLeft && (currentCircle <= (maxLevel-1)))
            addPower = TRUE;
        choicesLeft = GetRemainingExpandedChoices(nClass, POWER_LIST_EPIC_EXP_KNOWLEDGE, oPC);
		if (DEBUG) DoDebug("You still have " + IntToString(choicesLeft) + " epic expanded power choices left!");
        if (choicesLeft && (currentCircle <= (maxLevel-1)))
            addPower = TRUE;
        // otherwise don't show the button.
        return addPower;
    }

    return TRUE;
}

void LearnPowers(int nClass, object oPC=OBJECT_SELF)
{
    // add normal powers
    json powerList = GetCurrentPowerList(oPC);
    int totalPowers = JsonGetLength(powerList);
    int i;
    for (i = 0; i < totalPowers; i++)
    {
        int nSpellbookID = JsonGetInt(JsonArrayGet(powerList, i));
        // get the expanded knowledge list we are adding to if any
        int expKnow = GetExpKnowledgePowerListRequired(nClass, nSpellbookID, oPC);
        AddPowerKnown(oPC, nClass, nSpellbookID, TRUE, GetHitDice(oPC), expKnow);
    }
}

int GetExpKnowledgePowerListRequired(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    string sFile = GetClassSpellbookFile(nClass);

    int i;
    // expanded knowledge is -1, epic epxanded knowledge is -2
    for (i = -1; i >= -2; i--)
    {
        int spellId = StringToInt(Get2DACache(sFile, "SpellID", spellbookId));
        if (IsSpellInExpandedChoices(nClass, i, spellId, oPC))
            return i;
    }

    return 0;
}

int GetMaxPowerLevelForClass(int nClass, object oPC=OBJECT_SELF)
{
    string sFile = GetAMSKnownFileName(nClass);
    int nLevel = GetManifesterLevel(oPC, nClass, TRUE);
    // index is level - 1 since it starts at 0.
    int maxLevel = StringToInt(Get2DACache(sFile, "MaxPowerLevel", nLevel-1));
    return maxLevel;
}

int GetRemainingPowerChoices(int nClass, int chosenCircle, object oPC=OBJECT_SELF, int extra=TRUE)
{
    int remaining = 0;

    int maxLevel = GetMaxPowerLevelForClass(nClass, oPC);
    if (chosenCircle > maxLevel)
        return 0;

    json choices = GetCurrentPowerList(oPC);
    int totalChoices = JsonGetLength(choices);
    int allowedChoices = GetMaxPowerCount(oPC, nClass);
    int alreadyChosen = GetPowerCount(oPC, nClass);
    string sFile = GetClassSpellbookFile(nClass);

    int i = 0;
    for (i = 0; i < totalChoices; i++)
    {
        int spellbookId = JsonGetInt(JsonArrayGet(choices, i));
        int spellId = StringToInt(Get2DACache(sFile, "SpellID", spellbookId));
        //if the power is a expanded knowledge choice, don't count it
        if (!IsSpellInExpandedChoices(nClass, POWER_LIST_EXP_KNOWLEDGE, spellId, oPC)
            && !IsSpellInExpandedChoices(nClass, POWER_LIST_EPIC_EXP_KNOWLEDGE, spellId, oPC))
            remaining++;
    }
    remaining = (allowedChoices - remaining - alreadyChosen);

    // if this is true we count expanded knowledge choices
    if (extra)
    {
        if (GetHasFeat(FEAT_EXPANDED_KNOWLEDGE_1, oPC) && (chosenCircle <= (maxLevel-1)))
        {
            int totalExp = GetMaxPowerCount(oPC, POWER_LIST_EXP_KNOWLEDGE);
            json expChoices = GetExpandedChoicesList(nClass, oPC);
            int choicesCount = JsonGetLength(JsonObjectKeys(expChoices));
            remaining += (totalExp - choicesCount);
        }
        if (GetHasFeat(FEAT_EPIC_EXPANDED_KNOWLEDGE_1, oPC))
        {
            int totalExp = GetMaxPowerCount(oPC, POWER_LIST_EPIC_EXP_KNOWLEDGE);
            json expChoices = GetEpicExpandedChoicesList(nClass, oPC);
            int choicesCount = JsonGetLength(JsonObjectKeys(expChoices));
            remaining += (totalExp - choicesCount);
        }
    }

    return remaining;
}

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Initiators                                                          ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

json GetDisciplineInfoObject(int nClass, object oPC=OBJECT_SELF)
{
    json disciplineInfo = GetLocalJson(oPC, NUI_LEVEL_UP_DISCIPLINE_INFO_VAR + IntToString(nClass));
    if (disciplineInfo == JsonNull())
        disciplineInfo = JsonObject();
    else
        return disciplineInfo;

    int chosenClass = GetLocalInt(oPC, NUI_LEVEL_UP_SELECTED_CLASS_VAR);
    string sFile = GetClassSpellbookFile(nClass);

    //if this is not the chosen class then we do not have a chosen spell list
    // need to go through the class's 2da and check if you know the spell or not.
    if (nClass != chosenClass)
    {
        int totalSpells = Get2DARowCount(sFile);

        int i;
        for (i = 0; i < totalSpells; i++)
        {
            int featId = StringToInt(Get2DACache(sFile, "FeatID", i));
            if (featId && GetHasFeat(featId, oPC, TRUE))
                disciplineInfo = AddSpellDisciplineInfo(sFile, i, disciplineInfo);
        }
    }
    else
    {
        json chosenMans = GetChosenSpellListObject(nClass, oPC);

        json circles = JsonObjectKeys(chosenMans);
        int totalCircles = JsonGetLength(circles);

        int i;
        for (i = 0; i < totalCircles; i++)
        {
            string currentCircle = JsonGetString(JsonArrayGet(circles, i));
            json currentList = JsonObjectGet(chosenMans, currentCircle);
            int totalSpells = JsonGetLength(currentList);

            int y;
            for (y = 0; y < totalSpells; y++)
            {
                int spellbookId = JsonGetInt(JsonArrayGet(currentList, y));
                disciplineInfo = AddSpellDisciplineInfo(sFile, spellbookId, disciplineInfo);
            }
        }
    }

    SetLocalJson(oPC, NUI_LEVEL_UP_DISCIPLINE_INFO_VAR + IntToString(nClass), disciplineInfo);
    return disciplineInfo;
}

int IsRequiredForOtherManeuvers(int nClass, int prereq, string discipline, object oPC=OBJECT_SELF)
{
    json discInfo = GetDisciplineInfoObject(nClass, oPC);

    int total = 0;

    // loop through each prereq level and add up it's totals (ie how many maneuevrs
    // do we know with 0,1,2...,n prereqs.
    int i;
    for (i = 0; i <= prereq; i++)
    {

        json currDisc = JsonObjectGet(discInfo, discipline);
        string discKey = ("Prereq_" + IntToString(i));
        int currentDiscPrereq = JsonGetInt(JsonObjectGet(currDisc, discKey));
        total += currentDiscPrereq;
    }

    // then from above the given prereq check if we have any prereq maneuevers taken
    for (i = (prereq+1); i < NUI_LEVEL_UP_MANEUVER_PREREQ_LIMIT; i++)
    {
        json currDisc = JsonObjectGet(discInfo, discipline);
        string discKey = ("Prereq_" + IntToString(i));
        json discPrereq = JsonObjectGet(currDisc, discKey);
        if (discPrereq != JsonNull())
        {
            // if we do take the total and subtract by one, if it is lower than
            // than the prereq needed, it is required
            if (total - 1 < i)
                return TRUE;

            // otherwise add how many we have and move up and keep trying.
            int currentDiscPrereq = JsonGetInt(discPrereq);
            total += currentDiscPrereq;
        }
    }

    return FALSE;
}

int HasPreRequisitesForManeuver(int nClass, int spellbookId, object oPC=OBJECT_SELF)  
{  
    string sFile = GetClassSpellbookFile(nClass);  
    int prereqs = StringToInt(Get2DACache(sFile, "Prereqs", spellbookId));  
    string discipline = Get2DACache(sFile, "Discipline", spellbookId);  
      
    // First check if this class is allowed to access this discipline  
    if (!IsAllowedDiscipline(nClass, spellbookId, oPC))  
        return FALSE;  
      
    // If no prerequisites required and class has access, allow it  
    if (!prereqs)  
        return TRUE;  
      
    // For maneuvers with prerequisites, count across all Blade Magic classes  
    json discInfo = GetDisciplineInfoObject(nClass, oPC);  
    json classDisc2Info = JsonObject();  
    json classDisc3Info = JsonObject();  
      
    if (nClass == CLASS_TYPE_SWORDSAGE)  
    {  
        if (GetLevelByClass(CLASS_TYPE_WARBLADE, oPC))  
            classDisc2Info = GetDisciplineInfoObject(CLASS_TYPE_WARBLADE, oPC);  
        if (GetLevelByClass(CLASS_TYPE_CRUSADER, oPC))  
            classDisc3Info = GetDisciplineInfoObject(CLASS_TYPE_CRUSADER, oPC);  
    }  
    if (nClass == CLASS_TYPE_CRUSADER)  
    {  
        if (GetLevelByClass(CLASS_TYPE_WARBLADE, oPC))  
            classDisc2Info = GetDisciplineInfoObject(CLASS_TYPE_WARBLADE, oPC);  
        if (GetLevelByClass(CLASS_TYPE_SWORDSAGE, oPC))  
            classDisc3Info = GetDisciplineInfoObject(CLASS_TYPE_SWORDSAGE, oPC);  
    }  
    if (nClass == CLASS_TYPE_WARBLADE)  
    {  
        if (GetLevelByClass(CLASS_TYPE_CRUSADER, oPC))  
            classDisc2Info = GetDisciplineInfoObject(CLASS_TYPE_CRUSADER, oPC);  
        if (GetLevelByClass(CLASS_TYPE_SWORDSAGE, oPC))  
            classDisc3Info = GetDisciplineInfoObject(CLASS_TYPE_SWORDSAGE, oPC);  
    }  
      
    // Sum up maneuver counts from all classes for this discipline  
    int nManCount = 0;  
      
    // Check primary class  
    json chosenDisc = JsonObjectGet(discInfo, discipline);  
    if (chosenDisc != JsonNull())  
    {  
        nManCount += JsonGetInt(JsonObjectGet(chosenDisc, IntToString(MANEUVER_TYPE_MANEUVER)));  
        nManCount += JsonGetInt(JsonObjectGet(chosenDisc, IntToString(MANEUVER_TYPE_STANCE)));  
    }  
      
    // Check second class  
    chosenDisc = JsonObjectGet(classDisc2Info, discipline);  
    if (chosenDisc != JsonNull())  
    {  
        nManCount += JsonGetInt(JsonObjectGet(chosenDisc, IntToString(MANEUVER_TYPE_MANEUVER)));  
        nManCount += JsonGetInt(JsonObjectGet(chosenDisc, IntToString(MANEUVER_TYPE_STANCE)));  
    }  
      
    // Check third class  
    chosenDisc = JsonObjectGet(classDisc3Info, discipline);  
    if (chosenDisc != JsonNull())  
    {  
        nManCount += JsonGetInt(JsonObjectGet(chosenDisc, IntToString(MANEUVER_TYPE_MANEUVER)));  
        nManCount += JsonGetInt(JsonObjectGet(chosenDisc, IntToString(MANEUVER_TYPE_STANCE)));  
    }  
      
    // Check if we have enough maneuvers for the prerequisite  
    return nManCount >= prereqs;  
}

/* int HasPreRequisitesForManeuver(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    string sFile = GetClassSpellbookFile(nClass);
    int prereqs = StringToInt(Get2DACache(sFile, "Prereqs", spellbookId));
    if (!prereqs)
        return TRUE;
    string discipline = Get2DACache(sFile, "Discipline", spellbookId);
    json discInfo = GetDisciplineInfoObject(nClass, oPC);
    json chosenDisc = JsonObjectGet(discInfo, discipline);
    if (chosenDisc != JsonNull())
    {
        int nManCount = (JsonGetInt(JsonObjectGet(chosenDisc, IntToString(MANEUVER_TYPE_MANEUVER)))
            + JsonGetInt(JsonObjectGet(chosenDisc, IntToString(MANEUVER_TYPE_STANCE))));
        if (nManCount >= prereqs)
            return TRUE;
    }

    return FALSE;
} */

int GetMaxInitiatorCircle(int nClass, object oPC=OBJECT_SELF)
{
    int initiatorLevel = GetInitiatorLevel(oPC, nClass);
    // initiators learn by ceiling(classLevel)
    int highestCircle = (initiatorLevel + 1) / 2;
    if (highestCircle > 9)
        return 9;
    return highestCircle;
}

int GetRemainingManeuverChoices(int nClass, object oPC=OBJECT_SELF)
{
    json discInfo = GetDisciplineInfoObject(nClass, oPC);

    json jManAmount = JsonObjectGet(discInfo, NUI_LEVEL_UP_MANEUVER_TOTAL);
    int nManAmount = 0;
    if (jManAmount != JsonNull())
        nManAmount = JsonGetInt(jManAmount);

    int maxAmount = GetMaxManeuverCount(oPC, nClass, MANEUVER_TYPE_MANEUVER);

    return maxAmount - nManAmount;
}

int GetRemainingStanceChoices(int nClass, object oPC=OBJECT_SELF)
{
    json discInfo = GetDisciplineInfoObject(nClass, oPC);

    json jStanceAmount = JsonObjectGet(discInfo, NUI_LEVEL_UP_STANCE_TOTAL);
    int nStanceAmount = 0;
    if (jStanceAmount != JsonNull())
        nStanceAmount = JsonGetInt(jStanceAmount);

    int maxAmount = GetMaxManeuverCount(oPC, nClass, MANEUVER_TYPE_STANCE);

    return maxAmount - nStanceAmount;
}

int IsAllowedDiscipline(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    // logic carried over from private function in discipline inc functions
    // uses bitwise matching to tell if the discipline is allowed or not
    string sFile = GetClassSpellbookFile(nClass);
    int discipline = StringToInt(Get2DACache(sFile, "Discipline", spellbookId));

    int nOverride = GetPersistantLocalInt(oPC, "AllowedDisciplines");
    if(nOverride == 0)
    {
        switch(nClass)
        {
            case CLASS_TYPE_CRUSADER:  nOverride = 322; break;//DISCIPLINE_DEVOTED_SPIRIT + DISCIPLINE_STONE_DRAGON + DISCIPLINE_WHITE_RAVEN
            case CLASS_TYPE_SWORDSAGE: nOverride = 245; break;//DISCIPLINE_DESERT_WIND + DISCIPLINE_DIAMOND_MIND + DISCIPLINE_SETTING_SUN + DISCIPLINE_SHADOW_HAND + DISCIPLINE_STONE_DRAGON + DISCIPLINE_TIGER_CLAW
            case CLASS_TYPE_WARBLADE:  nOverride = 460; break;//DISCIPLINE_DIAMOND_MIND + DISCIPLINE_IRON_HEART + DISCIPLINE_STONE_DRAGON + DISCIPLINE_TIGER_CLAW + DISCIPLINE_WHITE_RAVEN
        }
    }
    return nOverride & discipline;
}

int IsRequiredForToBPRCClass(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    int currentClassPos = 1;
    // loop through all the classes and look for a PRC
    while (currentClassPos)
    {
        int currentClass = GetClassByPosition(currentClassPos, oPC);
        // if we reached a non existant class, we reached the end.
        if (currentClass != CLASS_TYPE_INVALID)
        {
            string sFile = GetClassSpellbookFile(nClass);
            int discipline = StringToInt(Get2DACache(sFile, "Discipline", spellbookId));

            // check if the class is a ToB PRC Class and if the current spell's
            // discipline is used for it.
            int isUsed = FALSE;
            if (currentClass == CLASS_TYPE_DEEPSTONE_SENTINEL
                && (discipline == DISCIPLINE_STONE_DRAGON))
                isUsed = TRUE;
            if (currentClass == CLASS_TYPE_BLOODCLAW_MASTER
                && (discipline == DISCIPLINE_TIGER_CLAW))
                isUsed = TRUE;
            if (currentClass == CLASS_TYPE_RUBY_VINDICATOR
                && (discipline == DISCIPLINE_DEVOTED_SPIRIT))
                isUsed = TRUE;
            if (currentClass == CLASS_TYPE_JADE_PHOENIX_MAGE)
                isUsed = TRUE;
            if (currentClass == CLASS_TYPE_MASTER_OF_NINE)
                isUsed = TRUE;
            if (currentClass == CLASS_TYPE_ETERNAL_BLADE
                && (discipline == DISCIPLINE_DEVOTED_SPIRIT
                    || discipline == DISCIPLINE_DIAMOND_MIND))
                isUsed = TRUE;
            if (currentClass == CLASS_TYPE_SHADOW_SUN_NINJA
                && (discipline == DISCIPLINE_SETTING_SUN
                    || discipline == DISCIPLINE_SHADOW_HAND))
                isUsed = TRUE;

            // if any of the above was true than we need to check if this spell
            // is required for a PRC
            if (isUsed)
            {
                // get the discipline info for all BladeMagic classes if we have them.
                json discInfo = GetDisciplineInfoObject(nClass, oPC);
                json classDisc2Info = JsonObject();
                json classDisc3Info = JsonObject();
                if (nClass == CLASS_TYPE_SWORDSAGE)
                {
                    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oPC))
                        classDisc2Info = GetDisciplineInfoObject(CLASS_TYPE_WARBLADE, oPC);
                    if (GetLevelByClass(CLASS_TYPE_CRUSADER, oPC))
                        classDisc3Info = GetDisciplineInfoObject(CLASS_TYPE_CRUSADER, oPC);
                }
                if (nClass == CLASS_TYPE_CRUSADER)
                {
                    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oPC))
                        classDisc2Info = GetDisciplineInfoObject(CLASS_TYPE_WARBLADE, oPC);
                    if (GetLevelByClass(CLASS_TYPE_SWORDSAGE, oPC))
                        classDisc3Info = GetDisciplineInfoObject(CLASS_TYPE_SWORDSAGE, oPC);
                }
                if (nClass == CLASS_TYPE_WARBLADE)
                {
                    if (GetLevelByClass(CLASS_TYPE_CRUSADER, oPC))
                        classDisc2Info = GetDisciplineInfoObject(CLASS_TYPE_CRUSADER, oPC);
                    if (GetLevelByClass(CLASS_TYPE_SWORDSAGE, oPC))
                        classDisc3Info = GetDisciplineInfoObject(CLASS_TYPE_SWORDSAGE, oPC);
                }

                // Time to begin checking the PRCs
                // this should follow the same logic as here
                // https://gitea.raptio.us/Jaysyn/PRC8/src/commit/797442d3da7c9c8e1fcf585b97e2ff1cbe56045b/nwn/nwnprc/trunk/scripts/prc_prereq.nss#L991

                // Check Deepstone Sentinel
                if (currentClass == CLASS_TYPE_DEEPSTONE_SENTINEL)
                {
                    // we need to look for 2 Stone Dragon Maneuvers and 1 Stone Dragon
                    // Stance. So add up the other MagicBlade classes and see if it is satisfied.
                    int stoneDMan, stoneDStance = 0;
                    json currentDisc = JsonObjectGet(classDisc2Info, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stoneDMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        stoneDStance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        if (stoneDMan >= 2 && stoneDStance >= 1)
                            return FALSE;
                    }

                    currentDisc = JsonObjectGet(classDisc3Info, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stoneDMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        stoneDStance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        if (stoneDMan >= 2 && stoneDStance >= 1)
                            return FALSE;
                    }
                    // if it still isn't satisfied than the current class is required
                    // for it to exist. Check to see if it is safe to remove the maneuever
                    currentDisc = JsonObjectGet(discInfo, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stoneDMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        stoneDStance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        int type = StringToInt(Get2DACache(sFile, "Type", spellbookId));
                        //if the current maneuver is a stance, check to see if it is safe to remove
                        if (type == MANEUVER_TYPE_STANCE)
                        {
                            if (stoneDStance - 1 >= 1)
                                return FALSE;
                        }
                        else
                        {
                            // if it is not a stance we can just check the maneuevers in general
                            if (stoneDMan - 1 >= 2)
                                return FALSE;
                        }

                        // this maneuver is required and should not be removed.
                        return TRUE;
                    }
                }

                // Check Bloodclaw Master
                if (currentClass == CLASS_TYPE_BLOODCLAW_MASTER)
                {
                    // bloodclaw needs 3 Tiger Claw maneuevers
                    int tigerCMan = 0;
                    json currentDisc = JsonObjectGet(classDisc2Info, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        tigerCMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        tigerCMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        if (tigerCMan >= 3)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc3Info, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        tigerCMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        tigerCMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        if (tigerCMan >= 3)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(discInfo, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        tigerCMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        tigerCMan += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        if (tigerCMan-1 >= 3)
                            return FALSE;
                        return TRUE;
                    }
                }

                if (currentClass == CLASS_TYPE_RUBY_VINDICATOR)
                {
                    // Ruby Vindicator needs 1 stance and 1 maneuever from Devoted Spirit
                    int stance = 0;
                    int maneuver = 0;
                    json currentDisc = JsonObjectGet(classDisc2Info, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        maneuver += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        if (stance >= 1 && maneuver >= 1)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc3Info, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        maneuver += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        if (stance >= 1 && maneuver >= 1)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(discInfo, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        maneuver += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        int type = StringToInt(Get2DACache(sFile, "Type", spellbookId));
                        if (type == MANEUVER_TYPE_STANCE)
                        {
                            if (stance - 1 >= 1)
                                return FALSE;
                            return TRUE;
                        }
                        if (maneuver - 1 >= 1)
                            return FALSE;
                        return TRUE;
                    }
                }

                if (currentClass == CLASS_TYPE_JADE_PHOENIX_MAGE)
                {
                    // Jade Phoenix needs 1 stance and 2 maneuvers of any type
                    int stance = 0;
                    int maneuver = 0;
                    json currentDisc = JsonObjectGet(classDisc2Info, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        maneuver += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        if (stance >= 1 && maneuver >= 2)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc3Info, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        maneuver += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        if (stance >= 1 && maneuver >= 2)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(discInfo, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        stance += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        maneuver += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        int type = StringToInt(Get2DACache(sFile, "Type", spellbookId));
                        if (type == MANEUVER_TYPE_STANCE)
                        {
                            if ((stance - 1 >= 1) && (maneuver -1 >= 2))
                                return FALSE;
                            return TRUE;
                        }
                        if (maneuver - 1 >= 2)
                            return FALSE;
                        return TRUE;
                    }
                }

                if (currentClass == CLASS_TYPE_MASTER_OF_NINE)
                {
                    // master of nine needs 1 maneuever from 6 different disciplines

                    int totalDiscCount = 0;
                    int currentClassAndDiscUsed = 0;
                    int i;
                    // loop through each possible discipline
                    for (i = 0; i <= 256; i++)
                    {
                        int found = 0;
                        // only disciplines that exist are stored, and only those
                        // that are used are stored, so we can loop through and
                        // find what disciplines we do or don't know.
                        json currentDisc = JsonObjectGet(classDisc2Info, IntToString(i));
                        if (currentDisc != JsonNull())
                            found = 1;

                        if (!found)
                        {
                            json currentDisc = JsonObjectGet(classDisc3Info, IntToString(i));
                            if (currentDisc != JsonNull())
                                found = 1;
                        }

                        if (!found)
                        {
                            json currentDisc = JsonObjectGet(discInfo, IntToString(i));
                            if (currentDisc != JsonNull())
                            {
                                if (i == discipline)
                                    currentClassAndDiscUsed = 1;
                                found = 1;
                            }
                        }

                        totalDiscCount += found;
                    }
                    // if we have more maneuevers than 6, it is not required
                    if (totalDiscCount > 6)
                        return FALSE;
                    // however if we have 6 and this discipline was grabbed we need to make sure it is safe to remove
                    if (currentClassAndDiscUsed)
                    {
                        // if we were to remove this discipline and it is 5 or less total disciplines we have now
                        // it is important
                        if (totalDiscCount - 1 >= 6)
                            return FALSE;
                        json currentDisc = JsonObjectGet(discInfo, IntToString(discipline));
                        int stance = JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        int maneuver = JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        // if we were to remove this discipline and are left with no more than
                        // this was important and it can't be removed
                        if ((stance + maneuver - 1) >= 1)
                            return FALSE;
                        return TRUE;
                    }
                    return FALSE;
                }

                if (currentClass == CLASS_TYPE_ETERNAL_BLADE)
                {
                    //Eternal blade 2 Devoted Spirits OR 2 Diamond Mind
                    int nTotal = 0;
                    json currentDisc = JsonObjectGet(classDisc2Info, IntToString(DISCIPLINE_DEVOTED_SPIRIT));
                    if (currentDisc != JsonNull())
                    {
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        // stances here count as a maneuver so we need to count 2
                        // to account for that
                        if (nTotal >= 2)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc2Info, IntToString(DISCIPLINE_DIAMOND_MIND));
                    if (currentDisc != JsonNull())
                    {
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        // stances here count as a maneuver so we need to count 2
                        // to account for that
                        if (nTotal >= 2)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc3Info, IntToString(DISCIPLINE_DEVOTED_SPIRIT));
                    if (currentDisc != JsonNull())
                    {
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        // stances here count as a maneuver so we need to count 2
                        // to account for that
                        if (nTotal >= 2)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc3Info, IntToString(DISCIPLINE_DIAMOND_MIND));
                    if (currentDisc != JsonNull())
                    {
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        // stances here count as a maneuver so we need to count 2
                        // to account for that
                        if (nTotal >= 2)
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(discInfo, IntToString(discipline));
                    if (currentDisc != JsonNull())
                    {
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        nTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        if ((nTotal - 1) >= 2)
                            return FALSE;
                        return TRUE;
                    }
                }

                if (currentClass == CLASS_TYPE_SHADOW_SUN_NINJA)
                {
                    // Shadow Sun Ninja needs 1 lvl2 Setting Sun OR Shadow Hand maneuever
                    // 1 Setting Sun maneuver AND 1 Shadow Hand maneuver
                    int nLvl2 = 0;
                    int shadowHTotal;
                    int settingSTotal;

                    json currentDisc = JsonObjectGet(classDisc2Info, IntToString(DISCIPLINE_SHADOW_HAND));
                    if (currentDisc != JsonNull())
                    {
                        shadowHTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        shadowHTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_STANCE)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_MANEUVER)));
                        // stances here count as a maneuver so we need to count 2
                        // to account for that
                        if (nLvl2 && shadowHTotal && settingSTotal && (shadowHTotal >= 2 || settingSTotal >= 2))
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc2Info, IntToString(DISCIPLINE_SETTING_SUN));
                    if (currentDisc != JsonNull())
                    {
                        settingSTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        settingSTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_STANCE)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_MANEUVER)));
                        // stances here count as a maneuver so we need to count 2
                        // to account for that
                        if (nLvl2 && shadowHTotal && settingSTotal && (shadowHTotal >= 2 || settingSTotal >= 2))
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc3Info, IntToString(DISCIPLINE_SHADOW_HAND));
                    if (currentDisc != JsonNull())
                    {
                        shadowHTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        shadowHTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_STANCE)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_MANEUVER)));
                        // stances here count as a maneuver so we need to count 2
                        // to account for that
                        if (nLvl2 && shadowHTotal && settingSTotal && (shadowHTotal >= 2 || settingSTotal >= 2))
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(classDisc2Info, IntToString(DISCIPLINE_SETTING_SUN));
                    if (currentDisc != JsonNull())
                    {
                        settingSTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        settingSTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_STANCE)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_MANEUVER)));
                        // stances here count as a maneuver so we need to count 2
                        // to account for that
                        if (nLvl2 && shadowHTotal && settingSTotal && (shadowHTotal >= 2 || settingSTotal >= 2))
                            return FALSE;
                    }
                    currentDisc = JsonObjectGet(discInfo, IntToString(DISCIPLINE_SHADOW_HAND));
                    if (currentDisc != JsonNull())
                    {
                        shadowHTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        shadowHTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_STANCE)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_MANEUVER)));
                    }
                    currentDisc = JsonObjectGet(discInfo, IntToString(DISCIPLINE_SETTING_SUN));
                    if (currentDisc != JsonNull())
                    {
                        settingSTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_STANCE)));
                        settingSTotal += JsonGetInt(JsonObjectGet(currentDisc, IntToString(MANEUVER_TYPE_MANEUVER)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_STANCE)));
                        nLvl2 += JsonGetInt(JsonObjectGet(currentDisc, "Level2_" + IntToString(MANEUVER_TYPE_MANEUVER)));
                    }
                    int level = StringToInt(Get2DACache(sFile, "Level", spellbookId));
                    if (level == 2)
                        nLvl2 -= 1;
                    if (discipline == DISCIPLINE_SHADOW_HAND)
                        shadowHTotal -= 1;
                    else
                        settingSTotal -= 1;

                    return !(nLvl2 && shadowHTotal && settingSTotal && (shadowHTotal >= 2 || settingSTotal >= 2));
                }
            }

            currentClassPos += 1;
        }
        else
            currentClassPos = 0;
    }

    return FALSE;
}

json AddSpellDisciplineInfo(string sFile, int spellbookId, json classDisc)
{
    json classDiscCopy = classDisc;
    int discipline = StringToInt(Get2DACache(sFile, "Discipline", spellbookId));
    int type = StringToInt(Get2DACache(sFile, "Type", spellbookId));
    int level = StringToInt(Get2DACache(sFile, "Level", spellbookId));
    int prereq = StringToInt(Get2DACache(sFile, "Prereqs", spellbookId));

    json jDisc = JsonObjectGet(classDisc, IntToString(discipline));
    if (jDisc == JsonNull())
        jDisc = JsonObject();

    string levelKey = "Level" + IntToString(level) + "_" + IntToString(type);
    int nTypeTotal = (JsonGetInt(JsonObjectGet(jDisc, levelKey)) + 1);
    jDisc = JsonObjectSet(jDisc, levelKey, JsonInt(nTypeTotal));

    nTypeTotal = (JsonGetInt(JsonObjectGet(jDisc, IntToString(type))) + 1);
    jDisc = JsonObjectSet(jDisc, IntToString(type), JsonInt(nTypeTotal));

    if (type != MANEUVER_TYPE_MANEUVER
        && type != MANEUVER_TYPE_STANCE)
    {
        levelKey = "Level" + IntToString(level) + "_" + IntToString(MANEUVER_TYPE_MANEUVER);
        nTypeTotal = (JsonGetInt(JsonObjectGet(jDisc, levelKey)) + 1);
        jDisc = JsonObjectSet(jDisc, levelKey, JsonInt(nTypeTotal));

        nTypeTotal = (JsonGetInt(JsonObjectGet(jDisc, IntToString(MANEUVER_TYPE_MANEUVER))) + 1);
        jDisc = JsonObjectSet(jDisc, IntToString(MANEUVER_TYPE_MANEUVER), JsonInt(nTypeTotal));
    }

    string prereqKey = "Prereq_" + IntToString(prereq);
    int nPrereqTotal = (JsonGetInt(JsonObjectGet(jDisc, prereqKey)) + 1);
    jDisc = JsonObjectSet(jDisc, prereqKey, JsonInt(nPrereqTotal));

    if (type == MANEUVER_TYPE_STANCE)
    {
        nTypeTotal = (JsonGetInt(JsonObjectGet(classDisc, NUI_LEVEL_UP_STANCE_TOTAL)) + 1);
        classDiscCopy = JsonObjectSet(classDiscCopy, NUI_LEVEL_UP_STANCE_TOTAL, JsonInt(nTypeTotal));
    }
    else
    {
        nTypeTotal = (JsonGetInt(JsonObjectGet(classDisc, NUI_LEVEL_UP_MANEUVER_TOTAL)) + 1);
        classDiscCopy = JsonObjectSet(classDiscCopy, NUI_LEVEL_UP_MANEUVER_TOTAL, JsonInt(nTypeTotal));
    }

    return JsonObjectSet(classDiscCopy, IntToString(discipline), jDisc);
}

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Invokers                                                            ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

json GetInvokerKnownListObject(int nClass, object oPC=OBJECT_SELF)
{
    json knownObject = GetLocalJson(oPC, NUI_LEVEL_UP_KNOWN_INVOCATIONS_CACHE_VAR + IntToString(nClass));
    if (knownObject == JsonNull())
        knownObject = JsonObject();
    else
        return knownObject;

    string sFile = GetAMSKnownFileName(nClass);
    int totalRows = Get2DARowCount(sFile);
    int maxInvocLevel = StringToInt(Get2DACache(sFile, "MaxInvocationLevel", totalRows-1));
    json previousInvocList = JsonObject();

    int i;
    for (i = 1; i <= maxInvocLevel; i++)
    {
        previousInvocList = JsonObjectSet(previousInvocList, IntToString(i), JsonInt(0));
    }

    for (i = 0; i < totalRows; i++)
    {
        int maxInvocation = StringToInt(Get2DACache(sFile, "MaxInvocationLevel", i));
        int invocationKnown = StringToInt(Get2DACache(sFile, "InvocationKnown", i));
        json invocList = previousInvocList;

        int previousInvocTotal = 0;
        if (i > 0)
            previousInvocTotal = StringToInt(Get2DACache(sFile, "InvocationKnown", i-1));
        int previousInvocAmount = JsonGetInt(JsonObjectGet(previousInvocList, IntToString(maxInvocation)));
        int currentInvocationAmount = (invocationKnown - previousInvocTotal + previousInvocAmount);

        invocList = JsonObjectSet(invocList, IntToString(maxInvocation), JsonInt(currentInvocationAmount));
        knownObject = JsonObjectSet(knownObject, IntToString(i+1), invocList);
        previousInvocList = invocList;
    }

    SetLocalJson(oPC, NUI_LEVEL_UP_KNOWN_INVOCATIONS_CACHE_VAR + IntToString(nClass), knownObject);
    if (DEBUG) DoDebug("Printing json representation of allowed invocations for class " + IntToString(nClass));
    if (DEBUG) DoDebug(JsonDump(knownObject, 2));
    return knownObject;
}

int GetRemainingInvocationChoices(int nClass, int chosenCircle, object oPC=OBJECT_SELF, int extra=TRUE)
{
    if (DEBUG) DoDebug ("Getting remaining invocation choices at " + IntToString(chosenCircle) + " circle");
    int remaining = 0;
    int nLevel = GetInvokerLevel(oPC, nClass);
    if (nClass == CLASS_TYPE_DRAGON_SHAMAN) nLevel = GetLevelByClass(nClass, oPC);
    if (DEBUG) DoDebug("Invoker level is " + IntToString(nLevel));

    json knownObject = GetInvokerKnownListObject(nClass, oPC);
    json chosenInv = GetChosenSpellListObject(nClass, oPC);
    json currentLevelKnown = JsonObjectGet(knownObject, IntToString(nLevel));

    int totalCircles = JsonGetLength(JsonObjectKeys(currentLevelKnown));

    // logic goes we are given a set amount of invocations at each circle. We can
    // take from a circle above us, but not below us. So we need to make sure
    // we have a legal amount of choices
    int i;
    for (i = 1; i <= totalCircles; i++)
    {
        int currentChosen = 0;
        json chosenSpells = JsonObjectGet(chosenInv, IntToString(i));
        if (chosenSpells != JsonNull())
        {
            int totalChosen = JsonGetLength(chosenSpells);
            int j;
            for (j = 0; j < totalChosen; j++)
            {
                int spellbookId = JsonGetInt(JsonArrayGet(chosenSpells, j));
                // only count non extra invocation choices
                if (!IsExtraChoiceInvocation(nClass, spellbookId, oPC))
                    currentChosen += 1;
            }
        }
        if (DEBUG) DoDebug(IntToString(currentChosen) + " incantations chosen at " + IntToString(chosenCircle) + " circle");

        int allowedAtCircle = JsonGetInt(JsonObjectGet(currentLevelKnown, IntToString(i)));
        if (DEBUG) DoDebug(IntToString(allowedAtCircle) + " incantations allowed at " + IntToString(chosenCircle) + " circle");

        remaining = (allowedAtCircle - currentChosen + remaining);
        // if the circle is below the chosen circle and we have a positive remaining,
        // we set it to 0 because we cannot use lower circle spells on higher circle.
        // however if thge value is negative then we carry it over because we
        // have a deficit and need to account for it by using the spells of the
        // next circle.
        if (i < chosenCircle && remaining > 0)
            remaining = 0;
    }


    // count extra and epic invocation choices
    if (extra)
    {
        string sFile = GetAMSKnownFileName(nClass);
        int maxCircle = StringToInt(Get2DACache(sFile, "MaxInvocationLevel", nLevel-1));

        if (GetHasFeat(FEAT_EXTRA_INVOCATION_I, oPC) && (chosenCircle <= (maxCircle-1)))
        {
            int totalExp = GetMaxInvocationCount(oPC, INVOCATION_LIST_EXTRA);
            json expChoices = GetExpandedChoicesList(nClass, oPC);
            int choicesCount = JsonGetLength(JsonObjectKeys(expChoices));
            remaining += (totalExp - choicesCount);
        }
        if (GetHasFeat(FEAT_EPIC_EXTRA_INVOCATION_I, oPC))
        {
            int totalExp = GetMaxInvocationCount(oPC, INVOCATION_LIST_EXTRA_EPIC);
            json expChoices = GetEpicExpandedChoicesList(nClass, oPC);
            int choicesCount = JsonGetLength(JsonObjectKeys(expChoices));
            remaining += (totalExp - choicesCount);
        }
    }

    return remaining;
}

int IsExtraChoiceInvocation(int nClass, int spellbookId, object oPC=OBJECT_SELF)
{
    string sFile = GetClassSpellbookFile(nClass);
    string spellId = Get2DACache(sFile, "SpellID", spellbookId);
    json extraChoices = GetExpandedChoicesList(nClass, oPC);
    json chosenSpell = JsonObjectGet(extraChoices, spellId);
    if (chosenSpell != JsonNull())
        return TRUE;

    extraChoices = GetEpicExpandedChoicesList(nClass, oPC);
    chosenSpell = JsonObjectGet(extraChoices, spellId);
    if (chosenSpell != JsonNull())
        return TRUE;

    return FALSE;
}

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Truenamer                                                           ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

int GetRemainingTruenameChoices(int nClass, int nType, object oPC=OBJECT_SELF)
{
    string sFile = GetClassSpellbookFile(nClass);
    json chosenSpells = GetChosenSpellListObject(nClass, oPC);
    json circles = JsonObjectKeys(chosenSpells);
    int totalCircles = JsonGetLength(circles);

    int remainingChoices = 0;

    int i;
    for (i = 0; i < totalCircles; i++)
    {
        json spellList = JsonObjectGet(chosenSpells, JsonGetString(JsonArrayGet(circles, i)));
        if (spellList != JsonNull())
        {
            int totalChoices = JsonGetLength(spellList);

            int j;
            for (j = 0; j < totalChoices; j++)
            {
                int spellbookId = JsonGetInt(JsonArrayGet(spellList, j));
                int lexicon = StringToInt(Get2DACache(sFile, "Lexicon", spellbookId));
                // -1 means count all lexicons
                if (nType == -1 || lexicon == nType)
                    remainingChoices += 1;
            }
        }
    }

    int maxChoices;
    // if -1 we count all lexicons to get total remaining
    if (nType == -1)
        maxChoices = (GetMaxUtteranceCount(oPC, nClass, LEXICON_CRAFTED_TOOL)
            + GetMaxUtteranceCount(oPC, nClass, LEXICON_EVOLVING_MIND)
            + GetMaxUtteranceCount(oPC, nClass, LEXICON_PERFECTED_MAP));
    else
        maxChoices = GetMaxUtteranceCount(oPC, nClass, nType);
    return (maxChoices - remainingChoices);
}

int GetLexiconCircleKnownAtLevel(int nLevel, int nType)
{

    string sFile = "cls_true_maxlvl";

    string columnName;
    if (nType == LEXICON_EVOLVING_MIND)
        columnName = "EvolvingMind";
    else if (nType == LEXICON_CRAFTED_TOOL)
        columnName = "CraftedTool";
    else
        columnName = "PerfectedMap";

    return StringToInt(Get2DACache(sFile, columnName, nLevel-1));
}

////////////////////////////////////////////////////////////////////////////
///                                                                      ///
///  Archivist                                                           ///
///                                                                      ///
////////////////////////////////////////////////////////////////////////////

json GetArchivistNewSpellsList(object oPC=OBJECT_SELF)
{
    json retValue = GetLocalJson(oPC, NUI_LEVEL_UP_ARCHIVIST_NEW_SPELLS_LIST_VAR);
    if (retValue == JsonNull())
        retValue = JsonArray();
    else
        return retValue;

    SetLocalJson(oPC, NUI_LEVEL_UP_ARCHIVIST_NEW_SPELLS_LIST_VAR, retValue);
    return retValue;
}

//:: void main(){}