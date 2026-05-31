//::///////////////////////////////////////////////
//:: Shifting include
//:: prc_inc_shifting
//::///////////////////////////////////////////////
/** @file
    Defines constants, functions and structs
    related to shifting.


    Creature data is stored as three persistant
    arrays, with synchronised indexes.
    - Resref
    - Creature name, as given by GetName() on the
      original creature from which the resref was
      gotten
    - Racial type


    @author Ornedan
    @date   Created - 2006.03.04
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int SHIFTER_TYPE_NONE          = 0;
const int SHIFTER_TYPE_SHIFTER       = 1;
const int SHIFTER_TYPE_SOULEATER     = 2;
const int SHIFTER_TYPE_POLYMORPH     = 3;
const int SHIFTER_TYPE_CHANGESHAPE   = 4;
const int SHIFTER_TYPE_HUMANOIDSHAPE = 5;
const int SHIFTER_TYPE_ALTER_SELF    = 6;
const int SHIFTER_TYPE_DISGUISE_SELF = 7;
const int SHIFTER_TYPE_DRUID         = 8;
const int SHIFTER_TYPE_ARANEA        = 9;

const int UNSHIFT_FAIL            = 0;
const int UNSHIFT_SUCCESS         = 1;
const int UNSHIFT_SUCCESS_DELAYED = 2;

const float SHIFTER_MUTEX_UNSET_DELAY = 3.0f;
const float SHIFTER_SHAPE_PRINT_DELAY = 3.1f;
const float SHIFTER_TEMPLATE_DESTROY_DELAY = 6.0f;

const string SHIFTER_RESREFS_ARRAY    = "PRC_ShiftingResRefs_";
const string SHIFTER_NAMES_ARRAY      = "PRC_ShiftingNames_";
const string SHIFTER_RACIALTYPE_ARRAY = "PRC_RacialType_";
const string SHIFTER_TRUEAPPEARANCE   = "PRC_ShiftingTrueAppearance";
const string SHIFTER_ISSHIFTED_MARKER = "nPCShifted"; //"PRC_IsShifted"; // @todo Refactor across all scripts
const string SHIFTER_SHIFT_MUTEX      = "PRC_Shifting_InProcess";
const string SHIFTER_RESTRICT_SPELLS  = "PRC_Shifting_RestrictSpells";
const string SHIFTER_OVERRIDE_RACE    = "PRC_ShiftingOverride_Race";
const string SHIFTER_TRUE_RACE        = "PRC_ShiftingTrue_Race";
const string SHIFTER_ORIGINALHP       = "PRC_Shifter_OriginalHP";
const string SHIFTER_ORIGINALMAXHP    = "PRC_Shifter_OriginalMaxHP";

const string SHIFTING_TEMPLATE_WP_TAG = "PRC_SHIFTING_TEMPLATE_SPAWN";
const string SHIFTING_SLAITEM_RESREF  = "epicshifterpower";
const string SHIFTING_SLAITEM_TAG     = "EpicShifterPowers";

const string SHIFTER_DELETED_SHAPE_PREFIX = "X: "; //TODO: add TLK entry?

const int STRREF_YOUNEED             = 16828326; // "You need"
const int STRREF_MORECHARLVL         = 16828327; // "more character levels before you can take on that form."
const int STRREF_NOPOLYTOPC          = 16828328; // "You cannot polymorph into a PC."
const int STRREF_FORBIDPOLY          = 16828329; // "Target cannot be polymorphed into."
const int STRREF_SETTINGFORBID       = 16828330; // "The module settings prevent this creature from being polymorphed into."
const int STRREF_PNPSFHT_FEYORSSHIFT = 16828331; // "You cannot use PnP Shifter abilities to polymorph into this creature."
const int STRREF_PNPSHFT_MORELEVEL   = 16828332; // "more PnP Shifter levels before you can take on that form."
const int STRREF_NEED_SPACE          = 16828333; // "Your inventory is too full for the PRC Polymorphing system to work. Please make space for three (3) helmet-size items (4x4) in your inventory before trying again."
const int STRREF_POLYMORPH_MUTEX     = 16828334; // "The PRC Polymorphing system will not work while you are affected by a polymorph effect. Please remove it before trying again."
const int STRREF_SHIFTING_MUTEX      = 16828335; // "Another PRC Polymorph transformation is underway at this moment. Please wait until it completes before trying again."
const int STRREF_TEMPLATE_FAILURE    = 16828336; // "Polymorph failed: Failed to create a template of the creature to polymorph into."

const int DEBUG_APPLY_PROPERTIES = FALSE;
const int DEBUG_ABILITY_BOOST_CALCULATIONS = FALSE;
const int DEBUG_EFFECTS = FALSE;
const int DEBUG_EXTRA_FEATS = FALSE;

const string PRC_Shifter_ShapeGeneration = "PRC_Shifter_ShapeGeneration";
const string PRC_Shifter_ApplyEffects_EvalPRC_Generation = "PRC_Shifter_ApplyEffects_EvalPRC_Generation";

int CHUNK_SIZE = 25; //50 was too big, so use 25



//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

/**
 * A struct for data about appearance.
 */
struct appearancevalues{
	/* Fields for the actual appearance */

    /// The appearance type aka appearance.2da row
    int nAppearanceType;

    /// Body part - Right foot
    int nBodyPart_RightFoot;
    /// Body part - Left Foot
    int nBodyPart_LeftFoot;
    /// Body part - Right Shin
    int nBodyPart_RightShin;
    /// Body part - Left Shin
    int nBodyPart_LeftShin;
    /// Body part - Right Thigh
    int nBodyPart_RightThigh;
    /// Body part - Left Thigh
    int nBodyPart_LeftThight;
    /// Body part - Pelvis
    int nBodyPart_Pelvis;
    /// Body part - Torso
    int nBodyPart_Torso;
    /// Body part - Belt
    int nBodyPart_Belt;
    /// Body part - Neck
    int nBodyPart_Neck;
    /// Body part - Right Forearm
    int nBodyPart_RightForearm;
    /// Body part - Left Forearm
    int nBodyPart_LeftForearm;
    /// Body part - Right Bicep
    int nBodyPart_RightBicep;
    /// Body part - Left Bicep
    int nBodyPart_LeftBicep;
    /// Body part - Right Shoulder
    int nBodyPart_RightShoulder;
    /// Body part - Left Shoulder
    int nBodyPart_LeftShoulder;
    /// Body part - Right Hand
    int nBodyPart_RightHand;
    /// Body part - Left Hand
    int nBodyPart_LeftHand;
    /// Body part - Head
    int nBodyPart_Head;

    /// The wing type
    int nWingType;
    /// The tail type
    int nTailType;

	/* Other stuff */

    /// Portrait ID
    int nPortraitID;
    /// Portrait resref
    string sPortraitResRef;
    /// The footstep type
    int nFootStepType;
    ///The gender
    int nGender;
    
    ///Colors
    // Skin color
    int nSkinColor;
    // Hair color
    int nHairColor;
    // Tattoo 1 color
    int nTat1Color;
    // Tattoo 2 color
    int nTat2Color;
};

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

int IsPolymorphed(object oPC);

int StoreCurrentRaceAsTrueRace(object oShifter);

// True appearance stuff //

/**
 * Stores the given creature's current appearance as it's true appearance.
 *
 * @param oShifter  The creature whose true appearance to store
 * @param bCarefull If this is TRUE, will only store the appearance if the creature
 *                  is not shifted or polymorphed
 * @return          TRUE if the appearance was stored, FALSE if not
 */
int StoreCurrentAppearanceAsTrueAppearance(object oShifter, int bCarefull = TRUE);

/**
 * Restores the given creature to it's stored true appearance.
 *
 * NOTE: This will function will fail if any polymorph effect is present on the creature.
 *
 *
 * @param oShifter The creature whose appearance to set into an appearance
 *                 previously stored as it's true appearance.
 *
 * @return         TRUE if appearance was restored, FALSE if not. Causes for failure
 *                 are being polymorphed and not having a true appearance stored.
 */
int RestoreTrueAppearance(object oShifter);

// Storage functions  //

/**
 * Stores the target's resref in the 'shifting template's list of the given creature.
 * Will silently fail if either the shifter or the target are not valid objects
 * or if the target is a PC.
 *
 * @param oShifter     The creature to whose list to store oTarget's resref in
 * @param nShifterType SHIFTER_TYPE_* of the list to store in
 * @param oTarget      The creature whose resref to store for later use in shifting
 */
int StoreShiftingTemplate(object oShifter, int nShifterType, object oTarget);

/**
 * Gets the number of 'template's stored in the given creature's list.
 *
 * @param oShifter     The creature whose list to examine
 * @param nShifterType SHIFTER_TYPE_* of the list to store examine
 * @return             The number of entries in the arrays making up the list
 */
int GetNumberOfStoredTemplates(object oShifter, int nShifterType);

/**
 * Reads the resref stored at the given index at a creature's 'template's
 * list.
 *
 * @param oShifter     The creature from whose list to read
 * @param nShifterType SHIFTER_TYPE_* of the list to read from
 * @param nIndex       The index of the entry to get in the list. Standard
 *                     base-0 indexing.
 * @return             The resref stored at the given index. "" on failure (ex.
 *                     reading from an index outside the list.
 */
string GetStoredTemplate(object oShifter, int nShifterType, int nIndex);

/**
 * Reads the name stored at the given index at a creature's 'templates's
 * list.
 *
 * @param oShifter     The creature from whose list to read
 * @param nShifterType SHIFTER_TYPE_* of the list to read from
 * @param nIndex       The index of the entry to get in the list. Standard
 *                     base-0 indexing.
 * @return             The name stored at the given index. "" on failure (ex.
 *                     reading from an index outside the list.
 */
string GetStoredTemplateName(object oShifter, int nShifterType, int nIndex);

/**
 * Deletes the 'shifting template's entry in a creature's list at a given
 * index.
 *
 * @param oShifter     The creature from whose list to delete
 * @param nShifterType SHIFTER_TYPE_* of the list to delete from
 * @param nIndex       The index of the entry to delete in the list. Standard
 *                     base-0 indexing.
 */
void DeleteStoredTemplate(object oShifter, int nShifterType, int nIndex);


// Shifting-related functions

/**
 * Determines whether the given creature can shift into the given target.
 *
 * @param oShifter     The creature attempting to shift into oTemplate
 * @param nShifterType SHIFTER_TYPE_*
 * @param oTemplate    The target of the shift
 *
 * @return             TRUE if oShifter can shift into oTemplate, FALSE otherwise
 */
int GetCanShiftIntoCreature(object oShifter, int nShifterType, object oTemplate);

/**
 * Attempts to shift into the given template creature. This functions as a wrapper
 * for ShiftIntoResRef(), which is supplied with oTemplate's resref.
 *
 * @param oShifter                The creature doing the shifting
 * @param nShifterType            SHIFTER_TYPE_*
 * @param oTemplate               The creature to shift into
 * @param bGainSpellLikeAbilities Whether to give the shifter access the template's SLAs
 *
 * @return                        TRUE if the shifting started successfully,
 *                                FALSE if it failed outright
 */
int ShiftIntoCreature(object oShifter, int nShifterType, object oTemplate, int bGainSpellLikeAbilities = FALSE);

/**
 * Attempts to shift into the given template creature. If the shifter is already
 * shifted, this will unshift them first. Any errors will result in a message
 * being sent to the shifter.
 *
 * @param oShifter                The creature doing the shifting
 * @param nShifterType            SHIFTER_TYPE_*
 * @param sResRef                 Resref of the creature to shift into
 * @param bGainSpellLikeAbilities Whether to give the shifter access the template's SLAs
 *
 * @return                        TRUE if the shifting started successfully,
 *                                FALSE if it failed outright
 */
int ShiftIntoResRef(object oShifter, int nShifterType, string sResRef, int bGainSpellLikeAbilities = FALSE);

/**
 * Undoes any currently active shifting, restoring original appearance &
 * creature items.
 * NOTE: Will fail if any of the following conditions are true
 * - oShifter is polymorphed and bRemovePoly is false
 * - SHIFTER_SHIFT_MUTEX flag is true on oShifter and bIgnoreShiftingMutex is false
 * - There is no true form stored for oShifter
 *
 * @param oShifter             The creature to unshift
 * @param bRemovePoly          Whether to also remove polymorph effects
 * @param bIgnoreShiftingMutex Whether to ignore the value of SHIFTER_SHIFT_MUTEX
 *
 * @return                     One of following:
 *                             - UNSHIFT_FAIL if one of the abovementioned failure conditions occurs.
 *                               If this is returned, nothing is done to oShifter.
 *                             - UNSHIFT_SUCCESS if the unshifting was completed immediately
 *                             - UNSHIFT_SUCCESS_DELAYED if the unshifting is doable, but delayed to
 *                               wait while a polymorph effect is being removed.
 */
int UnShift(object oShifter, int bRemovePoly = TRUE, int bIgnoreShiftingMutex = FALSE);

// Appearance data functions

/**
 * Reads in all the data about the target creature's appearance and stores it in
 * a structure that is then returned.
 *
 * @param oTemplate Creature whose appearance data to read
 * @return          An appearancevalues structure containing the data
 */
struct appearancevalues GetAppearanceData(object oTemplate);

/**
 * Sets the given creature's appearance data to values in the given appearancevalues
 * structure.
 *
 * @param oTarget The creauture whose appearance to modify
 * @param appval  The appearance data to apply to oTarget
 */
void SetAppearanceData(object oTarget, struct appearancevalues appval);

/**
 * Retrieves an appearancevalues structure that has been placed in local variable
 * storage.
 *
 * @param oStore The object on which the data has been stored
 * @param sName  The name of the local variable
 * @return       An appearancevalues structure containing the retrieved data
 */
struct appearancevalues GetLocalAppearancevalues(object oStore, string sName);

/**
 * Stores an appearancevalues structure on the given object as local variables.
 *
 * @param oStore The object onto which to store the data
 * @param sName  The name of the local variable
 * @param appval The data to store
 */
void SetLocalAppearancevalues(object oStore, string sName, struct appearancevalues appval);

/**
 * Deletes an appearancevalues structure that has been stored on the given object
 * as local variable.
 *
 * @param oStore The object from which to delete data
 * @param sName  The name of the local variable
 */
void DeleteLocalAppearancevalues(object oStore, string sName);

/**
 * Persistant storage version of GetLocalAppearancevalues(). As normal for
 * persistant storage, behaviour is not guaranteed in case the storage object is
 * not a creature.
 *
 * @param oStore The object on which the data has been stored
 * @param sName  The name of the local variable
 * @return       An appearancevalues structure containing the retrieved data
 */
struct appearancevalues GetPersistantLocalAppearancevalues(object oStore, string sName);

/**
 * Persistant storage version of GetLocalAppearancevalues(). As normal for
 * persistant storage, behaviour is not guaranteed in case the storage object is
 * not a creature.
 *
 * @param oStore The object onto which to store the data
 * @param sName  The name of the local variable
 * @param appval The data to store
 */
void SetPersistantLocalAppearancevalues(object oStore, string sName, struct appearancevalues appval);

/**
 * Persistant storage version of GetLocalAppearancevalues(). As normal for
 * persistant storage, behaviour is not guaranteed in case the storage object is
 * not a creature.
 *
 * @param oStore The object from which to delete data
 * @param sName  The name of the local variable
 */
void DeletePersistantLocalAppearancevalues(object oStore, string sName);

/**
 * Forces an unshift if spell duration ends, for Alter Self, etc.  If player 
 * unshifts before then, fuction will recognize it's a new shift and do nothing.
 *
 * @param oShifter       The object to force an unshift if needed
 * @param nShifterNumber a number to check against to make sure DelayCommand 
 *                       doesn't end the wrong shift
 */
void ForceUnshift(object oShifter, int nShiftedNumber);

/**
 * Creates a string containing the values of the fields of the given appearancevalues
 * structure.
 *
 * @param appval The appearancevalues structure to convert into a string
 * @return       A string that describes the contents of appval
 */
string DebugAppearancevalues2Str(struct appearancevalues appval);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

//#include "inc_utility"
//#include "prc_inc_switch"
#include "prc_inc_racial"
#include "prc_inc_function"
#include "prc_inc_onhit"
#include "prc_shifter_info"
#include "prc_weap_apt"
#include "prc_inc_wpnrest"
#include "inc_nwnx_funcs"

effect ePhysicalStats;
int Max_Bonus = GetPRCSwitch(PRC_PNP_SHIFTER_BONUS);


//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _prc_inc_shifting_EvalPRCFeats(object oShifter, object oShifterHide)
{
    //There is what appears to be a Bioware bug where sometimes when certain item properties,
    //most notably those for elemental immunities, are removed, they remain in effect and
    //are still listed in the character sheet. Reequiping the creature hide
    //seems to force NWN notice that the item property has disappeared,
    //while calling ScrubPCSkin/EvalPRCFeats does not.
    //Apparently it's not even necessary to unequip it first (which is good).
    //This also causes EvalPRCFeats to be called, so we don't need to do that ourselves.
    AssignCommand(oShifter, ActionEquipItem(oShifterHide, INVENTORY_SLOT_CARMOUR));
}

/** Internal function.
 * Looks through the given creature's inventory and deletes all
 * creature items not in the creature item slots.
 *
 * @param oShifter The creature through whose inventory to look
 */
void _prc_inc_shifting_RemoveExtraCreatureItems(object oShifter)
{
    int nItemType;
    object oItem  = GetFirstItemInInventory(oShifter);
    object oCWPB  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oShifter);
    object oCWPL  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oShifter);
    object oCWPR  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oShifter);
    object oCSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR,   oShifter);

    while(GetIsObjectValid(oItem))
    {
        nItemType = GetBaseItemType(oItem);

        if(nItemType == BASE_ITEM_CBLUDGWEAPON ||
           nItemType == BASE_ITEM_CPIERCWEAPON ||
           nItemType == BASE_ITEM_CREATUREITEM ||
           nItemType == BASE_ITEM_CSLASHWEAPON ||
           nItemType == BASE_ITEM_CSLSHPRCWEAP
           )
        {
            if(oItem != oCWPB &&
               oItem != oCWPL &&
               oItem != oCWPR &&
               oItem != oCSkin
               )
                MyDestroyObject(oItem);
        }
        oItem = GetNextItemInInventory(oShifter);
    }
}

/** Internal function.
 * @todo Finish function & comments
 */
void _prc_inc_shifting_CopyAllItemProperties(object oFrom, object oTo)
{
    itemproperty iProp = GetFirstItemProperty(oFrom);

    while(GetIsItemPropertyValid(iProp))
    {
        if(GetItemPropertyDurationType(iProp) == DURATION_TYPE_PERMANENT)
            IPSafeAddItemProperty(oTo, iProp, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        iProp = GetNextItemProperty(oFrom);
    }
}

/** Internal function.
 * Builds the shifter spell-like and activatable supernatural abilities item.
 *
 * @param oTemplate The target creature of an ongoing shift
 * @param oSLAItem  The item to create the activatable itemproperties on.
 */

//NOTE: THIS FUNCTION HAS A LOT OF CODE IN COMMON WITH _prc_inc_shifting_PrintShifterActiveAbilities
void _prc_inc_shifting_CreateShifterActiveAbilitiesItem(object oShifter, object oTemplate, object oSLAItem)
{
    object oTemplateHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTemplate);
    itemproperty iProp = GetFirstItemProperty(oTemplateHide);
    while(GetIsItemPropertyValid(iProp))
    {
        if(GetItemPropertyDurationType(iProp) == DURATION_TYPE_PERMANENT && GetItemPropertyType(iProp) == ITEM_PROPERTY_CAST_SPELL)
            AddItemProperty(GetItemPropertyDurationType(iProp), iProp, oSLAItem);
        iProp = GetNextItemProperty(oTemplateHide);
    }

    // Loop over shifter_abilitie.2da
    string sNumUses;
    int nSpell, nNumUses, nProps;
    int i = 0;
    while(nSpell = StringToInt(Get2DACache("shifter_abilitie", "Spell", i)))
    {
        // See if the template has this spell
        if(GetHasSpell(nSpell, oTemplate))
        {
            // Determine the number of uses from the 2da
            sNumUses = Get2DACache("shifter_abilitie", "IPCSpellNumUses", i);
            if(sNumUses == "1_USE_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY;
            else if(sNumUses == "2_USES_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY;
            else if(sNumUses == "3_USES_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY;
            else if(sNumUses == "4_USES_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_4_USES_PER_DAY;
            else if(sNumUses == "5_USES_PER_DAY")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_5_USES_PER_DAY;
            else if(sNumUses == "UNLIMITED_USE")
                nNumUses = IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE;
            else{
                if(DEBUG) DoDebug("prc_inc_shifting: _CreateShifterActiveAbilitiesItem(): Unknown IPCSpellNumUses in shifter_abilitie.2da line " + IntToString(i) + ": " + sNumUses);
                nNumUses = -1;
            }

            // Create the itemproperty and add it to the item
            iProp = ItemPropertyCastSpell(StringToInt(Get2DACache("shifter_abilitie", "IPSpell", i)), nNumUses);
            AddItemProperty(DURATION_TYPE_PERMANENT, iProp, oSLAItem);

            // Increment property counter
            nProps += 1;
        }

        // Increment loop counter
        i += 1;
    }
}

/** Internal function.
 * Adds bonus feats granting feats defined in shifter_feats.2da to the shifter's hide if
 * the template has the given feat.
 *
 * @param oTemplate    The target creature of an ongoing shift
 * @param oShifterHide The shifter's hide object
 */

void _prc_inc_shifting_CopyFeats(object oShifter, object oTemplate, object oShifterHide, int nStartIndex, int nLimitIndex)
{
    // Loop over shifter_feats.2da. Assume there are no more entries when
    string sFeat;
    int i = nStartIndex;
    while((i < nLimitIndex) && (sFeat = Get2DACache("shifter_feats", "Feat", i)) != "")
    {
        if (_prc_inc_GetHasFeat(oTemplate, StringToInt(sFeat)))
        {
            IPSafeAddItemProperty(
                oShifterHide,  
                ItemPropertyBonusFeat(StringToInt(Get2DACache("shifter_feats", "IPFeat", i))), 
                0.0, 
                X2_IP_ADDPROP_POLICY_KEEP_EXISTING
                );
            string sFeatName = GetStringByStrRef(StringToInt(Get2DACache("feat", "Feat", StringToInt(sFeat))));
        }
        i += 1;
    }
}

void _prc_inc_shifting_AddCreatureWeaponFeats(object oShifter, object oShifterHide)
{
    //If PC has unarmed feats, give them the corresponding creature feats when shifted
    if (GetHasFeat(FEAT_WEAPON_FOCUS_UNARMED_STRIKE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_WeapFocCreature), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_WeapSpecCreature), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_UNARMED, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_WeapEpicFocCreature), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_UNARMED, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_WeapEpicSpecCreature), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_ImpCritCreature), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_UNARMED, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_OVERCRITICAL_CREATURE), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_UNARMED, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_DEVCRITICAL_CREATURE), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);

    //If PC has creature feats, give them the corresponding unarmed feats when shifted
    if (GetHasFeat(FEAT_WEAPON_FOCUS_CREATURE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_WEAPON_FOCUS_UNARMED_STRIKE), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_CREATURE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_CREATURE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_WEAPON_FOCUS_UNARMED_STRIKE), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_CREATURE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_WEAPON_SPECIALIZATION_UNARMED_STRIKE), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_IMPROVED_CRITICAL_CREATURE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_IMPROVED_CRITICAL_UNARMED), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_CREATURE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_OVERWHELMING_CRITICAL_UNARMED), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    if (GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_CREATURE, oShifter))
        IPSafeAddItemProperty(oShifterHide, ItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_DEVASTATING_CRITICAL_UNARMED), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
}

/** Internal function.
 * Determines if the given resref has already been stored in the
 * templates array of the given creature's shifting list for
 * a particular shifting type.
 *
 * @param oShifter     The creature
 * @param nShifterType The shifting list to look in
 * @param sResRef      The resref to look for
 * @return             TRUE if the resref is present in the array
 */
int _prc_inc_shifting_GetIsTemplateStored(object oShifter, int nShifterType, string sResRef)
{
    string sResRefsArray = SHIFTER_RESREFS_ARRAY + IntToString(nShifterType);
    int i, nArraySize    = persistant_array_get_size(oShifter, sResRefsArray);

    // Lowercase the searched for string
    sResRef = GetStringLowerCase(sResRef);

    for(i = 0; i < nArraySize; i++)
    {
        if(sResRef == persistant_array_get_string(oShifter, sResRefsArray, i))
            return i+1;
    }

    return 0;
}

/** Internal function.
 * Performs some checks to see if the given creature can shift without
 * the system falling apart.
 *
 * @param oShifter The creature that would be shifted
 * @return         TRUE if all is OK, FALSE otherwise
 */
int _prc_inc_shifting_GetCanShift(object oShifter)
{
    // Mutex - If another shifting process is active, fail immediately without disturbing it
    if(GetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX))
    {
        DelayCommand(SHIFTER_MUTEX_UNSET_DELAY, SetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX, FALSE)); //In case the mutex got stuck, unstick it
        SendMessageToPCByStrRef(oShifter, STRREF_SHIFTING_MUTEX); // "Another PRC Polymorph transformation is underway at this moment. Please wait until it completes before trying again."
        return FALSE;
    }

    // Test space in inventory for creating the creature items
    int bReturn = TRUE;
    object o1 = CreateItemOnObject("pnp_shft_tstpkup", oShifter),
           o2 = CreateItemOnObject("pnp_shft_tstpkup", oShifter),
           o3 = CreateItemOnObject("pnp_shft_tstpkup", oShifter);

    if(!(GetItemPossessor(o1) == oShifter &&
         GetItemPossessor(o2) == oShifter &&
         GetItemPossessor(o3) == oShifter
       ))
    {
        bReturn = FALSE;
        SendMessageToPCByStrRef(oShifter, STRREF_NEED_SPACE); // "Your inventory is too full for the PRC Shifting system to work. Please make space for three (3) helmet-size items (4x4) in your inventory before trying again."
    }

    DestroyObject(o1);
    DestroyObject(o2);
    DestroyObject(o3);

    // Polymorph effect and shifting are mutually exclusive. Letting them stack
    // is inviting massive fuckups.
    if (IsPolymorphed(oShifter))
        bReturn = FALSE;

    // True form must be stored in order to be allowed to shift
    if(!GetPersistantLocalInt(oShifter, SHIFTER_TRUEAPPEARANCE))
        bReturn = FALSE;

    return bReturn;
}

//Function by The_Krit from http://nwn.bioware.com/forums/viewtopic.html?topic=601171&forum=47
//TODO: This still doesn't bypass spell effects that make the PC immune to ability drain (e.g. "Negative energy protection" spell)
void _prc_inc_shifting_BypassItemProperties(object oCreature, int nSubType, int nType = ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS)
{
    object oItem;
    itemproperty ipBypass;
    // Loop through oCreature's inventory slots.
    int nSlot = NUM_INVENTORY_SLOTS;
    while ( nSlot-- > 0 )
    {
        // Get the item in this slot.
        oItem = GetItemInSlot(nSlot, oCreature);
        if ( oItem != OBJECT_INVALID )
        {
            // Loop through oItem's item properties.
            ipBypass = GetFirstItemProperty(oItem);
            while ( GetIsItemPropertyValid(ipBypass) )
            {
                // See if ipBypass is what we want to bypass.
                if ( GetItemPropertyType(ipBypass) == nType        &&
                     GetItemPropertySubType(ipBypass) == nSubType  &&
                     GetItemPropertyDurationType(ipBypass) == DURATION_TYPE_PERMANENT )
                {
                    // Remove ipBypass for a split second.
                    RemoveItemProperty(oItem, ipBypass);
                    DelayCommand(0.1, AddItemProperty(DURATION_TYPE_PERMANENT, ipBypass, oItem));
                }
                // Next item property.
                ipBypass = GetNextItemProperty(oItem);
            }//while (ipBypass)
        }//if (oItem)
    }//while (nSlot)
}

void _prc_inc_shifting_ApplyStatPenalties(object oCreature,  object oPropertyHolder, int nDeltaSTR, int nDeltaDEX, int nDeltaCON)
{
    //The immunity properties removed by _prc_inc_shifting_ApplyStatPenalties aren't actually removed until this script 
    //finishes running, so we delay adding the penalties until after that happens. Re-adding the removed immunity properties
    //is delayed even longer (schedulded by _prc_inc_shifting_BypassItemProperties) so that it happens after the penalties have been applied.
    _prc_inc_shifting_BypassItemProperties(oCreature, IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN);
    if(nDeltaSTR < 0)
        DelayCommand(0.0, SetCompositeBonus(oPropertyHolder, "Shifting_AbilityAdjustmentSTRPenalty", -nDeltaSTR, ITEM_PROPERTY_DECREASED_ABILITY_SCORE, IP_CONST_ABILITY_STR));
    if(nDeltaDEX < 0)
        DelayCommand(0.0, SetCompositeBonus(oPropertyHolder, "Shifting_AbilityAdjustmentDEXPenalty", -nDeltaDEX, ITEM_PROPERTY_DECREASED_ABILITY_SCORE, IP_CONST_ABILITY_DEX));
    if(nDeltaCON < 0)
        DelayCommand(0.0, SetCompositeBonus(oPropertyHolder, "Shifting_AbilityAdjustmentCONPenalty", -nDeltaCON, ITEM_PROPERTY_DECREASED_ABILITY_SCORE, IP_CONST_ABILITY_CON));
}

//TODO: use ForceEquip() in inc_utility instead?
void SafeEquipItem(object oShifter, object oItem, int nSlot, float fDelay = 1.0f)
{
    if (GetIsObjectValid(oItem) && GetItemInSlot(nSlot, oShifter) != oItem)
    {
        AssignCommand(oShifter, ActionEquipItem(oItem, nSlot));
        if (fDelay < 9.0f) //Don't repeat forever
            DelayCommand(fDelay, SafeEquipItem(oShifter, oItem, nSlot, fDelay * 2)); //Try increasing delays until it works
    }
}

void _prc_inc_shifting_ApplyEffects(object oShifter, int bShifting)
{
    if (GetLocalInt(oShifter, "PRC_Shifter_AffectsToApply"))
    {
        if(bShifting)
        {
            SetLocalInt(oShifter, "PRC_SHIFTER_APPLY_ALL_SPELL_EFFECTS", TRUE);
                //The only place this is ever removed is by the spell script after it is used.
                //This prevents race conditions where this function is called again
                //and changes the value to FALSE before the spell script had a chance to use it.
        }

        if (GetLocalInt(oShifter, "PRC_Shifter_Use_RodOfWonder"))
        {
            if (DEBUG_EFFECTS || DEBUG)
                DoDebug("ADDING EFFECTS: ROD OF WONDER");
            object oCastingObject = CreateObject(OBJECT_TYPE_PLACEABLE, "x0_rodwonder", GetLocation(oShifter));
            AssignCommand(oCastingObject, ActionCastSpellAtObject(SPELL_SHIFTING_EFFECTS, oShifter, METAMAGIC_NONE, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            //Handled by spell code: DestroyObject(oCastingObject, 6.0);
        }
        else
        {
            if (DEBUG_EFFECTS || DEBUG)
                DoDebug("ADDING EFFECTS: ALTERNATE");
            CastSpellAtObject(SPELL_SHIFTING_EFFECTS, oShifter, METAMAGIC_NONE, 0, 0, 0, OBJECT_INVALID, oShifter);
        }
    }
}

void _prc_inc_shifting_RemoveSpellEffects_RodOfWonder(object oShifter, int bApplyAll)
{
    effect eTest = GetFirstEffect(oShifter);
    while(GetIsEffectValid(eTest))
    {
        if(GetEffectSpellId(eTest) == SPELL_SHIFTING_EFFECTS)
        {
            if (GetEffectType(eTest) == EFFECT_TYPE_TEMPORARY_HITPOINTS)
            {
                int nHPBonus = GetLocalInt(oShifter, "PRC_Shifter_ExtraCON_HPBonus");
                if (bApplyAll || !nHPBonus)
                {
                    if(DEBUG_EFFECTS || DEBUG)
                        DoDebug("Removing temp HP: " + IntToString(bApplyAll) + ", " + IntToString(nHPBonus));
                    RemoveEffect(oShifter, eTest);
                }
                else if(DEBUG_EFFECTS || DEBUG) 
                    DoDebug("Skipped removing temp HP" + IntToString(bApplyAll) + ", " + IntToString(nHPBonus));
            }
            else if (GetEffectType(eTest) == EFFECT_TYPE_INVISIBILITY)
            {
                int bHarmlessInvisible = GetLocalInt(oShifter, "PRC_Shifter_HarmlessInvisible");
                if (bApplyAll || !bHarmlessInvisible)
                {
                    if(DEBUG_EFFECTS || DEBUG)
                        DoDebug("Removing invisibility" + IntToString(bApplyAll) + ", " + IntToString(bHarmlessInvisible));
                    RemoveEffect(oShifter, eTest);
                }
                else if(DEBUG_EFFECTS || DEBUG) 
                    DoDebug("Skipped removing invisibility" + IntToString(bApplyAll) + ", " + IntToString(bHarmlessInvisible));
            }
            else
                RemoveEffect(oShifter, eTest);
        }
        eTest = GetNextEffect(oShifter);
    }    
}

void _prc_inc_shifting_RemoveSpellEffects_CastSpellAtObject(object oShifter, int bApplyAll)
{
    effect eTest = GetFirstEffect(oShifter);
    while(GetIsEffectValid(eTest))
    {
        int nSpellId = GetEffectSpellId(eTest);
        //TODO: Is THERE ANY WAY TO SET THE SPELL ID CORRECTLY INSTEAD OF IT BEING -1?
            //EvalPRCFeats seems to call scripts using the ExecuteScript function and the spell id is set correctly. How does this happen?
        if(nSpellId == SPELL_SHIFTING_EFFECTS || nSpellId == -1)
        {
            switch(GetEffectType(eTest))
            {
                case EFFECT_TYPE_ATTACK_INCREASE:
                case EFFECT_TYPE_ATTACK_DECREASE:
                case EFFECT_TYPE_DAMAGE_INCREASE:
                case EFFECT_TYPE_DAMAGE_DECREASE:
                case EFFECT_TYPE_SAVING_THROW_INCREASE:
                case EFFECT_TYPE_SAVING_THROW_DECREASE:
                case EFFECT_TYPE_SKILL_INCREASE:
                case EFFECT_TYPE_SKILL_DECREASE:
                case EFFECT_TYPE_AC_INCREASE:
                case EFFECT_TYPE_AC_DECREASE:
                    RemoveEffect(oShifter, eTest);
                    break;
            
                case EFFECT_TYPE_TEMPORARY_HITPOINTS:
                {
                    int nHPBonus = GetLocalInt(oShifter, "PRC_Shifter_ExtraCON_HPBonus");
                    if (bApplyAll || !nHPBonus)
                        RemoveEffect(oShifter, eTest);
                    else if(DEBUG_EFFECTS || DEBUG) 
                        DoDebug("Skipped removing temp HP" + IntToString(bApplyAll) + ", " + IntToString(nHPBonus));
                    break;
                }

                case EFFECT_TYPE_INVISIBILITY:
                {
                    int bHarmlessInvisible = GetLocalInt(oShifter, "PRC_Shifter_HarmlessInvisible");
                    if (bApplyAll || !bHarmlessInvisible)
                        RemoveEffect(oShifter, eTest);
                    else if(DEBUG_EFFECTS || DEBUG)
                        DoDebug("Skipped removing invisibility" + IntToString(bApplyAll) + ", " + IntToString(bHarmlessInvisible));
                    break;
                }
            }
        }
        eTest = GetNextEffect(oShifter);
    }
    if(GetLocalInt(oShifter, "ReserveFeatsRunning"))
        DelayCommand(0.1f, ExecuteScript("prc_reservefeat", oShifter));
}

void _prc_inc_shifting_RemoveSpellEffects(object oShifter, int bApplyAll)
{
    if (GetLocalInt(oShifter, "PRC_Shifter_Use_RodOfWonder"))
    {
        if(DEBUG_EFFECTS || DEBUG)
            DoDebug("REMOVING EFFECTS: ROD OF WONDER");
        if(!GetLocalInt(oShifter, "PRC_Shifter_Using_RodOfWonder"))
        {
            //Remove effects of other approach if just switching to this one.
            //This may remove too many effects, but shifting should force the effects
            //that should not have been removed to be re-added, and they won't be
            //removed again.
            SetLocalInt(oShifter, "PRC_Shifter_Using_RodOfWonder", TRUE);
            _prc_inc_shifting_RemoveSpellEffects_CastSpellAtObject(oShifter, bApplyAll);
        }
        _prc_inc_shifting_RemoveSpellEffects_RodOfWonder(oShifter, bApplyAll);
    }
    else
    {
        /*
        This method has advantages and disadvantages compared to the Rod of Wonder method.
        Advantages:
            * It's instantaneous; if the system is busy (e.g., in a really difficult fight)
                the Rod of Wonder sometimes takes 10-15 seconds, which can literally kill you
        Disadvantages:
            * It can't tell which effects it added, so it sometimes has to remove too many
                (e.g., it might perhaps remove race-related AC bonus, etc.)
                //TODO: if I can come up with a better way to mark or detect which effects were added here, this can be fixed
                    //Check GetEffectCreator? Tie the effect to a unique object so we can identify it?
            
        Even with the disadvantages, for the builds I've used I find that the advantages make this method preferable.
        However, for some builds or environments the Rod of Wonder might still be preferable, so provide the user with an option
            by means of the PRC_Shifter_Use_RodOfWonder variable.
        */
        if(DEBUG_EFFECTS || DEBUG)
            DoDebug("REMOVING EFFECTS: ALTERNATE");
        _prc_inc_shifting_RemoveSpellEffects_CastSpellAtObject(oShifter, bApplyAll);
    }    
}

void _prc_inc_shifting_DeleteEffectInts(object oShifter)
{
    DeleteLocalInt(oShifter, "PRC_SHIFTER_EXTRA_STR_WEAPON_MAINHAND");
    DeleteLocalInt(oShifter, "PRC_SHIFTER_EXTRA_STR_WEAPON_OFFHAND");
    DeleteLocalInt(oShifter, "PRC_SHIFTER_EXTRA_DEX_ARMOR");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraSTR");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraSTR_Feats");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraSTR_AttackBonus");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraSTR_DamageBonus");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraSTR_DamageType");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraSTR_SaveAndSkillBonus");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraDEX");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraDEX_Feats");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraDEX_ACBonus");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraDEX_SaveAndSkillBonus");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraCON");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraCON_Feats");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraCON_HPBonus");
    DeleteLocalInt(oShifter, "PRC_Shifter_ExtraCON_SaveAndSkillBonus");

    DeleteLocalInt(oShifter, "PRC_Shifter_NaturalAC");
    DeleteLocalInt(oShifter, SHIFTER_RESTRICT_SPELLS);
    DeleteLocalInt(oShifter, "PRC_Shifter_HarmlessInvisible");

    DeleteLocalInt(oShifter, SHIFTER_OVERRIDE_RACE);
    int nShiftingTrueRace = GetPersistantLocalInt(oShifter, SHIFTER_TRUE_RACE);
    if(nShiftingTrueRace)
        PRC_Funcs_SetRace(oShifter, nShiftingTrueRace - 1); //Offset by 1 to differentiate value 0 from non-existence
    
    DeleteLocalInt(oShifter, "PRC_Shifter_AffectsToApply");
}

int _prc_inc_shifting_HasExtraFeat(object oPC, string sRemovedFeatList, object oTemplate, int nFeat, int nIPFeat)
{
    if (nFeat == -1 || nIPFeat == -1)
        return FALSE;
    int bPCHasFeat = GetHasFeat(nFeat, oPC);
    string sIPFeat = "("+IntToString(nIPFeat)+")";
    int bDeleted = (FindSubString(sRemovedFeatList, sIPFeat) != -1);
    int bTemplateHasFeat = GetHasFeat(nFeat, oTemplate);
    return (bPCHasFeat && !bDeleted) || bTemplateHasFeat;
}

void _prc_inc_shifting_AddExtraFeat(object oPC, string sRemovedFeatList, object oPropertyHolder, int nIPFeat, string sFeatTrackingVariable)
{
    string sIPFeat = "("+IntToString(nIPFeat)+")";
    itemproperty iProp = ItemPropertyBonusFeat(nIPFeat);
    if (FindSubString(sRemovedFeatList, sIPFeat) != -1) //TODO: skip this check and always use the delay?
    {
        //An item property for the same feat was present before and was removed;
        //but removed item properties aren't actually removed until the script
        //ends. However, this means that the new one we add here is removed.
        //So, delay adding it until after the removal takes place.
        DelayCommand(0.0f, IPSafeAddItemProperty(oPropertyHolder, iProp, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING));
    }
    else
        IPSafeAddItemProperty(oPropertyHolder, iProp, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    SetLocalString(oPC, sFeatTrackingVariable, GetLocalString(oPC, sFeatTrackingVariable) + sIPFeat);
}

int _prc_inc_shifting_TryAddExtraFeat(object oPC, string sRemovedFeatList, object oTemplate, object oPropertyHolder, int nFeat, int nIPFeat, string sFeatTrackingVariable)
{
    int nAddedCount = 0;
    if (!_prc_inc_shifting_HasExtraFeat(oPC, sRemovedFeatList, oTemplate, nFeat, nIPFeat))
    {
        _prc_inc_shifting_AddExtraFeat(oPC, sRemovedFeatList, oPropertyHolder, nIPFeat, sFeatTrackingVariable);
        nAddedCount = 1;
    }
    return nAddedCount;
}

int _prc_inc_shifting_TryAddExtraFeats(object oPC, string sRemovedFeatList, object oTemplate, object oPropertyHolder, int nFeatStart, int nFeatEnd, int nIPFeatStart, int nCount, string sFeatTrackingVariable)
{
    int nAddedCount = 0;
    int nIPFeat = -1;
    int nFeat;
    //Find which feats should be added
    for (nFeat = nFeatStart; nAddedCount < nCount && nFeat <= nFeatEnd; nFeat++)
    {
        nIPFeat = nIPFeatStart + (nFeat - nFeatStart);
        if (!_prc_inc_shifting_HasExtraFeat(oPC, sRemovedFeatList, oTemplate, nFeat, nIPFeat))
            nAddedCount += 1;
    }
    //Only need to add the last one, since they're cumulative
    if (nAddedCount)
        _prc_inc_shifting_AddExtraFeat(oPC, sRemovedFeatList, oPropertyHolder, nIPFeat, sFeatTrackingVariable);
    return nAddedCount;
}
/*
void _prc_inc_shifting_SetSTR(object oShifter, int nSTR)
{
    PRC_Funcs_SetAbilityScore(oShifter, ABILITY_STRENGTH, nSTR);
    //NWNX does not take into account any racial ability bonus/penalty. For instance, if the race has a
    //+2 STR bonus, and we try to set STR to 10, it will instead set to 12. Handle that here.
    int nErrorSTR = nSTR - GetAbilityScore(oShifter, ABILITY_STRENGTH, TRUE);
    if (nErrorSTR)
        PRC_Funcs_SetAbilityScore(oShifter, ABILITY_STRENGTH, nSTR + nErrorSTR);
}

void _prc_inc_shifting_SetDEX(object oShifter, int nDEX)
{
    PRC_Funcs_SetAbilityScore(oShifter, ABILITY_DEXTERITY, nDEX);
    //NWNX does not take into account any racial ability bonus/penalty. For instance, if the race has a
    //+2 DEX bonus, and we try to set DEX to 10, it will instead set to 12. Handle that here.
    int nErrorDEX = nDEX - GetAbilityScore(oShifter, ABILITY_DEXTERITY, TRUE);
    if (nErrorDEX)
        PRC_Funcs_SetAbilityScore(oShifter, ABILITY_DEXTERITY, nDEX + nErrorDEX);
}

void _prc_inc_shifting_SetCON(object oShifter, int nCON)
{
    PRC_Funcs_SetAbilityScore(oShifter, ABILITY_CONSTITUTION, nCON);
    //NWNX does not take into account any racial ability bonus/penalty. For instance, if the race has a
    //+2 CON bonus, and we try to set CON to 10, it will instead set to 12. Handle that here.
    int nErrorCON = nCON - GetAbilityScore(oShifter, ABILITY_CONSTITUTION, TRUE);
    if (nErrorCON)
        PRC_Funcs_SetAbilityScore(oShifter, ABILITY_CONSTITUTION, nCON + nErrorCON);
}

void _prc_inc_shifting_SetINT(object oShifter, int nINT)
{
    PRC_Funcs_SetAbilityScore(oShifter, ABILITY_INTELLIGENCE, nINT);
    //NWNX does not take into account any racial ability bonus/penalty. For instance, if the race has a
    //+2 INT bonus, and we try to set INT to 10, it will instead set to 12. Handle that here.
    int nErrorINT = nINT - GetAbilityScore(oShifter, ABILITY_INTELLIGENCE, TRUE);
    if (nErrorINT)
        PRC_Funcs_SetAbilityScore(oShifter, ABILITY_INTELLIGENCE, nINT + nErrorINT);
}

void _prc_inc_shifting_SetWIS(object oShifter, int nWIS)
{
    PRC_Funcs_SetAbilityScore(oShifter, ABILITY_WISDOM, nWIS);
    //NWNX does not take into account any racial ability bonus/penalty. For instance, if the race has a
    //+2 WIS bonus, and we try to set WIS to 10, it will instead set to 12. Handle that here.
    int nErrorWIS = nWIS - GetAbilityScore(oShifter, ABILITY_WISDOM, TRUE);
    if (nErrorWIS)
        PRC_Funcs_SetAbilityScore(oShifter, ABILITY_WISDOM, nWIS + nErrorWIS);
}

void _prc_inc_shifting_SetCHA(object oShifter, int nCHA)
{
    PRC_Funcs_SetAbilityScore(oShifter, ABILITY_CHARISMA, nCHA);
    //NWNX does not take into account any racial ability bonus/penalty. For instance, if the race has a
    //+2 CHA bonus, and we try to set CHA to 10, it will instead set to 12. Handle that here.
    int nErrorCHA = nCHA - GetAbilityScore(oShifter, ABILITY_CHARISMA, TRUE);
    if (nErrorCHA)
        PRC_Funcs_SetAbilityScore(oShifter, ABILITY_CHARISMA, nCHA + nErrorCHA);
}
*/
void _prc_inc_shifting_ApplyTemplate(object oShifter, int nIndex, int nShifterType, object oTemplate, int bShifting,  object oShifterPropertyHolder1=OBJECT_INVALID, object oShifterPropertyHolder2=OBJECT_INVALID)
{
    int nShapeGeneration = GetLocalInt(oShifter, PRC_Shifter_ShapeGeneration);
    if (nShapeGeneration != nIndex)
    {
        //Don't apply properties that were scheduled when we were in another shape
        if (DEBUG_APPLY_PROPERTIES)
            DoDebug("_prc_inc_shifting_ApplyTemplate, exiting--old shape, Shifter Index: " + IntToString(nShapeGeneration));
        return;
    }

    if(!GetIsObjectValid(oShifterPropertyHolder1))
    {
        //Put some properties on skin because they won't work otherwise--
        //e.g., OnHit properties that should fire when the Shifter is hit by 
        //an enemy don't fire if they're not on the hide.
        //Also, for some reason stat penalty item properties simply won't
        //apply on creature weapons but work correctly on the skin.
        //All properties applied to the skin need to be reapplied 
        //whenever the skin is scrubbed.
        oShifterPropertyHolder1 = GetPCSkin(oShifter);
    }
    int bSkinScrubbed = !GetLocalInt(oShifterPropertyHolder1, "PRC_SHIFTER_TEMPLATE_APPLIED");
        //TODO: Use PRC_ScrubPCSkin_Generation instead?
    SetLocalInt(oShifterPropertyHolder1, "PRC_SHIFTER_TEMPLATE_APPLIED", TRUE); //This gets cleared by DeletePRCLocalInts (after sleeping, etc.).

    int bApplyProperties1 = bSkinScrubbed;
    
    if(!GetIsObjectValid(oShifterPropertyHolder2))
    {
        object oShifterCWpR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oShifter);
        object oShifterCWpL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oShifter);
        object oShifterCWpB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oShifter);
        //Put some properties on a creature weapon, because having them removed and re-added causes issues
        //(e.g. having CON increase removed when your HP is low enough can kill you).
        //These properties never need to be reapplied because the creature weapons are never scrubbed.
        oShifterPropertyHolder2 = OBJECT_INVALID;
        if(GetIsObjectValid(oShifterCWpR))
            oShifterPropertyHolder2 = oShifterCWpR;
        if(GetIsObjectValid(oShifterCWpL))
            oShifterPropertyHolder2 = oShifterCWpL;
        if(GetIsObjectValid(oShifterCWpB))
            oShifterPropertyHolder2 = oShifterCWpB;
    }
    int bApplyProperties2 = bShifting && GetIsObjectValid(oShifterPropertyHolder2);

    object oTemplateHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTemplate);

    int bNeedSpellCast = FALSE; //Indicates whether there are any effects that require the spell to apply them

    if(nShifterType != SHIFTER_TYPE_CHANGESHAPE &&
       nShifterType != SHIFTER_TYPE_HUMANOIDSHAPE)
    {
        // Copy all itemproperties from the source's hide. No need to check for validity of oTemplateHide - it not
        // existing works the same as it existing, but having no iprops.
        if(bApplyProperties1)
            _prc_inc_shifting_CopyAllItemProperties(oTemplateHide, oShifterPropertyHolder1);
    }
    
    _prc_inc_shifting_DeleteEffectInts(oShifter);

    

    // Ability score adjustments - doesn't apply to Change Shape
    if(nShifterType != SHIFTER_TYPE_CHANGESHAPE &&
       nShifterType != SHIFTER_TYPE_HUMANOIDSHAPE &&
       nShifterType != SHIFTER_TYPE_ALTER_SELF &&
       nShifterType != SHIFTER_TYPE_DISGUISE_SELF &&
       nShifterType != SHIFTER_TYPE_ARANEA)
    {
        struct _prc_inc_ability_info_struct rInfoStruct = _prc_inc_shifter_GetAbilityInfo(oTemplate, oShifter);

        if (DEBUG_ABILITY_BOOST_CALCULATIONS || DEBUG)
        {
            DoDebug("Template Creature STR/DEX/CON: " + IntToString(rInfoStruct.nTemplateSTR) + "/" + IntToString(rInfoStruct.nTemplateDEX) + "/" + IntToString(rInfoStruct.nTemplateCON));
            DoDebug("Shifter STR/DEX/CON: " + IntToString(rInfoStruct.nShifterSTR) + "/" + IntToString(rInfoStruct.nShifterDEX) + "/" + IntToString(rInfoStruct.nShifterCON));
            DoDebug("Delta STR/DEX/CON: " + IntToString(rInfoStruct.nDeltaSTR) + "/" + IntToString(rInfoStruct.nDeltaDEX) + "/" + IntToString(rInfoStruct.nDeltaCON));
            DoDebug("Item STR/DEX/CON: " + IntToString(rInfoStruct.nItemSTR) + "/" + IntToString(rInfoStruct.nItemDEX) + "/" + IntToString(rInfoStruct.nItemCON));
            DoDebug("Item Delta STR/DEX/CON: " + IntToString(rInfoStruct.nItemDeltaSTR) + "/" + IntToString(rInfoStruct.nItemDeltaDEX) + "/" + IntToString(rInfoStruct.nItemDeltaCON));
            DoDebug("Extra STR/DEX/CON: " + IntToString(rInfoStruct.nExtraSTR) + "/" + IntToString(rInfoStruct.nExtraDEX) + "/" + IntToString(rInfoStruct.nExtraCON));
        }

        // Set the ability score adjustments as composite bonuses

        {
            if(bApplyProperties2 || bApplyProperties1)
			{
				
				//set ability bonus in engine to allow for bonuses greater than 12 (default engine limit)
				//SetAbilityBonusLimit(127);
				 SetAbilityBonusLimit (GetPRCSwitch(PRC_PNP_SHIFTER_BONUS));
				
				//clear any existing ability boosts
				effect eEffect = GetFirstEffect(oShifter);
				while(GetIsEffectValid(eEffect))
				
				{
					if(GetEffectTag(eEffect) == "ShifterAbilities")
					RemoveEffect(oShifter,eEffect);
					eEffect = GetNextEffect(oShifter);
				}
					
						//New upper limit checks based on the max bonus of +127 to ability scores, also checking against PRC switch -Barmlot
				if (rInfoStruct.nDeltaSTR > 127)
					rInfoStruct.nDeltaSTR = 127;
					if (rInfoStruct.nDeltaSTR > Max_Bonus)
						rInfoStruct.nDeltaSTR = Max_Bonus;
				if (rInfoStruct.nDeltaDEX > 127)
					rInfoStruct.nDeltaDEX = 127;
					if (rInfoStruct.nDeltaDEX > Max_Bonus)
						rInfoStruct.nDeltaDEX = Max_Bonus;
				if (rInfoStruct.nDeltaCON > 127)
					rInfoStruct.nDeltaCON = 127;
					if (rInfoStruct.nDeltaCON > Max_Bonus)
						rInfoStruct.nDeltaCON = Max_Bonus;
					
				effect eNewStr;
				effect eNewDex;
				effect eNewCon;
				
				//Not sure this positive/negative check is necessary as EffectAbilityIncrease seems to take a signed integer, leaving as is -Barmlot				
				if (rInfoStruct.nDeltaSTR > 0)
				eNewStr = EffectAbilityIncrease(IP_CONST_ABILITY_STR, rInfoStruct.nDeltaSTR);
				else
				eNewStr = EffectAbilityDecrease(IP_CONST_ABILITY_STR, rInfoStruct.nDeltaSTR);
				if (rInfoStruct.nDeltaDEX > 0)
				eNewDex = EffectAbilityIncrease(IP_CONST_ABILITY_DEX, rInfoStruct.nDeltaDEX);
				else
				eNewDex = EffectAbilityDecrease(IP_CONST_ABILITY_DEX, rInfoStruct.nDeltaDEX);
				if (rInfoStruct.nDeltaCON > 0)
				eNewCon = EffectAbilityIncrease(IP_CONST_ABILITY_CON, rInfoStruct.nDeltaCON);
				else
				eNewCon = EffectAbilityDecrease(IP_CONST_ABILITY_CON, rInfoStruct.nDeltaCON);

		
					
				ePhysicalStats = EffectLinkEffects(eNewStr, eNewDex);
				ePhysicalStats = EffectLinkEffects(ePhysicalStats, eNewCon);
				ePhysicalStats = TagEffect(ePhysicalStats, "ShifterAbilities");
				
				if (GetLevelByClass(CLASS_TYPE_PNP_SHIFTER, oShifter) > 5)
					ePhysicalStats = SupernaturalEffect(ePhysicalStats);
				ApplyEffectToObject(DURATION_TYPE_PERMANENT,ePhysicalStats,oShifter);
			}
		}
	}
    // Approximately figure out the template's natural AC bonus
    if (nShifterType != SHIFTER_TYPE_CHANGESHAPE && 
        nShifterType != SHIFTER_TYPE_HUMANOIDSHAPE && 
        nShifterType != SHIFTER_TYPE_DISGUISE_SELF &&
        nShifterType != SHIFTER_TYPE_ARANEA)
    {
        int nNaturalAC = _prc_inc_CreatureNaturalAC(oTemplate);
        if(nNaturalAC > 0)
        {
            bNeedSpellCast = TRUE;
            SetLocalInt(oShifter, "PRC_Shifter_NaturalAC", nNaturalAC);
        }
    }

    // Feats - read from shifter_feats.2da, check if template has it and copy over if it does
    // Delayed, since this takes way too long
    if(bApplyProperties1)
    {
        if(nShifterType != SHIFTER_TYPE_CHANGESHAPE
        && nShifterType != SHIFTER_TYPE_HUMANOIDSHAPE
        && nShifterType != SHIFTER_TYPE_ALTER_SELF
        && nShifterType != SHIFTER_TYPE_DISGUISE_SELF
        && nShifterType != SHIFTER_TYPE_ARANEA)
        {
            //Copy feats in chunks because shapes with *many* feats were giving TMI errors
            string sFeat;
            int CHUNK_SIZE = 25; //50 was too big, so use 25
            int i = 0;
            while((sFeat = Get2DACache("shifter_feats", "Feat", i)) != "")
            {
                DelayCommand(0.0f, _prc_inc_shifting_CopyFeats(oShifter, oTemplate, oShifterPropertyHolder1, i, i+CHUNK_SIZE));
                i += CHUNK_SIZE;
            }
        }

        DelayCommand(0.1f, _prc_inc_shifting_AddCreatureWeaponFeats(oShifter, oShifterPropertyHolder1));

        DelayCommand(1.0f, DoWeaponsEquip(oShifter)); //Since our weapon proficiency feats may have changed, reapply weapon feat simulations
            //TODO: Handle armor also?
            //TODO: Should actually unequip weapon if incorrect size, armor if not proficient (but this might be a pain).
    }

    // Casting restrictions if our - inaccurate - check indicates the template can't cast spells
    if(!_prc_inc_shifting_GetCanFormCast(oTemplate) && !GetHasFeat(FEAT_PRESTIGE_SHIFTER_NATURALSPELL, oShifter))
        SetLocalInt(oShifter, SHIFTER_RESTRICT_SPELLS, TRUE);

    // Harmless stuff gets invisibility
    if(_prc_inc_shifting_GetIsCreatureHarmless(oTemplate))
    {
        bNeedSpellCast = TRUE;
        SetLocalInt(oShifter, "PRC_Shifter_HarmlessInvisible", TRUE);
    }

    //Override racial type. 
    //Change shape doesn't include this, but there is a feat that gives it to Changelings
    if((nShifterType != SHIFTER_TYPE_CHANGESHAPE 
        && nShifterType != SHIFTER_TYPE_SHIFTER
        && nShifterType != SHIFTER_TYPE_POLYMORPH
        && nShifterType != SHIFTER_TYPE_DRUID
        && nShifterType != SHIFTER_TYPE_HUMANOIDSHAPE 
        && nShifterType != SHIFTER_TYPE_ALTER_SELF 
        && nShifterType != SHIFTER_TYPE_DISGUISE_SELF
        && nShifterType != SHIFTER_TYPE_ARANEA) 
       || GetHasFeat(FEAT_RACIAL_EMULATION))
    {
        int nRace = MyPRCGetRacialType(oTemplate);
        SetLocalInt(oShifter, SHIFTER_OVERRIDE_RACE, nRace + 1); //Offset by 1 to differentiate value 0 from non-existence

        if(GetPersistantLocalInt(oShifter, SHIFTER_TRUE_RACE)) //Only change race if we can get back again when we unshift!
            PRC_Funcs_SetRace(oShifter, nRace); 
    }

    // If something needs permanent effects applied, create a placeable to do the casting in order to bind the effects to a spellID
    if(bNeedSpellCast)
    {
        SetLocalInt(oShifter, PRC_Shifter_ApplyEffects_EvalPRC_Generation, GetLocalInt(oShifter, PRC_EvalPRCFeats_Generation));
        SetLocalInt(oShifter, "PRC_Shifter_AffectsToApply", TRUE);
        _prc_inc_shifting_ApplyEffects(oShifter, bShifting);
    }
    else
    {
        DeleteLocalInt(oShifter, "PRC_SHIFTER_APPLY_ALL_SPELL_EFFECTS");
        _prc_inc_shifting_RemoveSpellEffects(oShifter, TRUE);
    }
}

/** Internal function.
 * Implements the actual shifting bit. Copies creature items, changes appearance, etc
 *
 * @param oShifter                The creature shifting
 * @param nShifterType            SHIFTER_TYPE_*    
 * @param oTemplate               The template creature
 * @param bGainSpellLikeAbilities Whether to create the SLA item
 */
void _prc_inc_shifting_ShiftIntoTemplateAux(object oShifter, int nShifterType, object oTemplate, int bGainSpellLikeAbilities)
{
    if(DEBUG) DoDebug("prc_inc_shifting: _ShiftIntoResRefAux():\n"
                    + "oShifter = " + DebugObject2Str(oShifter) + "\n"
                    + "nShifterType = " + IntToString(nShifterType) + "\n"
                    + "oTemplate = " + DebugObject2Str(oTemplate) + "\n"
                    + "bGainSpellLikeAbilities = " + DebugBool2String(bGainSpellLikeAbilities) + "\n"
                      );

    string sFormName = GetName(oTemplate);
    int nRequiredShifterLevel = _prc_inc_shifting_ShifterLevelRequirement(oTemplate);
    int nRequiredCharacterLevel = _prc_inc_shifting_CharacterLevelRequirement(oTemplate);
    float fChallengeRating = GetChallengeRating(oTemplate);

    // Make sure the template creature is still valid
    if(!GetIsObjectValid(oTemplate) || GetObjectType(oTemplate) != OBJECT_TYPE_CREATURE)
    {
        if(DEBUG) DoDebug("prc_inc_shifting: _ShiftIntoTemplateAux(): ERROR: oTemplate is not a valid object or not a creature: " + DebugObject2Str(oTemplate));
        /// @todo Write a better error message
        SendMessageToPCByStrRef(oShifter, STRREF_TEMPLATE_FAILURE); // "Polymorph failed: Failed to create a template of the creature to polymorph into."

        // On failure, unset the mutex right away
        SetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX, FALSE);
    }
    else
    {
        // Queue unsetting the mutex. Done here so that even if something breaks along the way, this has a good chance of getting executed
        DelayCommand(SHIFTER_MUTEX_UNSET_DELAY, SetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX, FALSE));

        /* Start the actual shifting */

        // First, clear the shifter's action queue. We'll be assigning a bunch of commands that should get executed ASAP
        AssignCommand(oShifter, ClearAllActions(TRUE));

        // Get the shifter's creature items
        object oShifterHide = GetPCSkin(oShifter); // Use the PRC wrapper for this to make sure we get the right object
        object oShifterCWpR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oShifter);
        object oShifterCWpL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oShifter);
        object oShifterCWpB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oShifter);

        // Get the template's creature items
        object oTemplateHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTemplate);
        object oTemplateCWpR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTemplate);
        object oTemplateCWpL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTemplate);
        object oTemplateCWpB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTemplate);

        //Changelings don't get the natural attacks
        object oCreatureWeapon = OBJECT_INVALID;
        if(nShifterType != SHIFTER_TYPE_DISGUISE_SELF)
        {
            // Handle creature weapons - replace any old weapons with new
            // Delete old natural weapons
            if(GetIsObjectValid(oShifterCWpR)) MyDestroyObject(oShifterCWpR);
            if(GetIsObjectValid(oShifterCWpL)) MyDestroyObject(oShifterCWpL);
            if(GetIsObjectValid(oShifterCWpB)) MyDestroyObject(oShifterCWpB);
            oShifterCWpR = OBJECT_INVALID;
			oShifterCWpL = OBJECT_INVALID;
			oShifterCWpB = OBJECT_INVALID;
    
            // Copy the template's weapons and assign equipping
            
            if(GetIsObjectValid(oTemplateCWpR))
            {
                oShifterCWpR = CopyItem(oTemplateCWpR, oShifter, TRUE);
                oCreatureWeapon = oShifterCWpR;
                SetIdentified(oShifterCWpR, TRUE);
                SafeEquipItem(oShifter, oShifterCWpR, INVENTORY_SLOT_CWEAPON_R);
            }
            if(GetIsObjectValid(oTemplateCWpL))
            {
                oShifterCWpL = CopyItem(oTemplateCWpL, oShifter, TRUE);
                oCreatureWeapon = oShifterCWpL;
                SetIdentified(oShifterCWpL, TRUE);
                SafeEquipItem(oShifter, oShifterCWpL, INVENTORY_SLOT_CWEAPON_L);
            }
            if(GetIsObjectValid(oTemplateCWpB))
            {
                oShifterCWpB = CopyItem(oTemplateCWpB, oShifter, TRUE);
                oCreatureWeapon = oShifterCWpB;
                SetIdentified(oShifterCWpB, TRUE);
                SafeEquipItem(oShifter, oShifterCWpB, INVENTORY_SLOT_CWEAPON_B);
            }
            if (!GetIsObjectValid(oCreatureWeapon))
            {
                //Make a dummy creature weapon that doesn't do anything except hold properties--it is never used as a weapon
                //Don't do this if using NWNX funcs: the properties that would normally be applied to the creature
                //weapon aren't needed, since NWNX funcs makes the changes directly to the creature instead.
                oShifterCWpB = CreateItemOnObject("pnp_shft_cweap", oShifter); //create a shifter blank creature weapon
                SetIdentified(oShifterCWpB, TRUE);
                oCreatureWeapon = oShifterCWpB;
                SafeEquipItem(oShifter, oShifterCWpB, INVENTORY_SLOT_CWEAPON_B);
            }
        }
        //Hide isn't modified for Change Shape - Special Qualities don't transfer
        if(nShifterType != SHIFTER_TYPE_CHANGESHAPE &&
           nShifterType != SHIFTER_TYPE_HUMANOIDSHAPE &&
           nShifterType != SHIFTER_TYPE_ARANEA)
        {
            // Handle hide
            // Nuke old props and composite bonus tracking - they will be re-evaluated later
            ScrubPCSkin(oShifter, oShifterHide);
            DeletePRCLocalInts(oShifterHide);
        }
        
        //Do this here instead of letting EvalPRCFeats do it below so that it happens sooner
        _prc_inc_shifting_ApplyTemplate(oShifter, GetLocalInt(oShifter, PRC_Shifter_ShapeGeneration), nShifterType, oTemplate, TRUE, oShifterHide, oCreatureWeapon);

        // Ability score adjustments - doesn't apply to Change Shape
        if(nShifterType != SHIFTER_TYPE_CHANGESHAPE &&
           nShifterType != SHIFTER_TYPE_HUMANOIDSHAPE &&
           nShifterType != SHIFTER_TYPE_ALTER_SELF &&
           nShifterType != SHIFTER_TYPE_DISGUISE_SELF &&
           nShifterType != SHIFTER_TYPE_ARANEA)
        {
            // Get the base delta
            int nCreatureCON = GetAbilityScore(oTemplate, ABILITY_CONSTITUTION, TRUE);
            int nHealHP = GetHitDice(oShifter) + nCreatureCON; //TODO: Need to take into account Great Constitution and Epic Toughness?
            if(!GetPRCSwitch(PRC_PNP_REST_HEALING))
            {
                //Wildshape is supposed to heal the same amount as a night's sleep, which by default NWN rules
                //is full healing. That would be overpowered, so we'll use only double the PnP healing amount here.
                nHealHP *= 2;
            }

            {
                //Preserve HP loss we had before shifting, but first heal by the amount that wildshaping is supposed to
                //(one hitpoint per hit die plus one hitpoint per point of CON)
                //Since we temporarily fully healed before shifting, we can assume we have full HP before damaging or healing.
                int nOriginalMaxHP = GetLocalInt(oShifter, SHIFTER_ORIGINALMAXHP);
                if(nOriginalMaxHP)
                {
                    int nOriginalHP = GetLocalInt(oShifter, SHIFTER_ORIGINALHP);
                    int nDamageAmount = nOriginalMaxHP - nOriginalHP - nHealHP;
                    if(nDamageAmount > 0)
                    {
                        //TODO: make sure the full damage amount is applied 
                        //(e.g., try a different damage type if immune to this one,
                        //or damage multiple times if full damage is prevented due
                        //to partial immunity, etc.).
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamageAmount), oShifter);
                    }
                    else
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(-nDamageAmount), oShifter);
                    SetLocalInt(oShifter, SHIFTER_ORIGINALMAXHP, 0);
                }
                else
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHealHP), oShifter);
            }
        }
        
        // If requested, generate an item for using SLAs
        if(bGainSpellLikeAbilities)
        {
            object oSLAItem = CreateItemOnObject(SHIFTING_SLAITEM_RESREF, oShifter);
            // Delayed to prevent potential TMI
            DelayCommand(0.0f, _prc_inc_shifting_CreateShifterActiveAbilitiesItem(oShifter, oTemplate, oSLAItem));
        }

        // Change the appearance to that of the template
        if(GetAppearanceType(oTemplate) > 5)
             SetAppearanceData(oShifter, GetAppearanceData(oTemplate));
        else
        {
             SetAppearanceData(oShifter, GetAppearanceData(oTemplate));
             SetLocalInt(oShifter, "DynamicAppearance", TRUE);
             SetCreatureAppearanceType(oShifter, GetAppearanceType(oTemplate));
        }

        // Some VFX
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_POLYMORPH), oShifter);

        // Set the shiftedness marker
        SetPersistantLocalInt(oShifter, SHIFTER_ISSHIFTED_MARKER, TRUE);
        
        if(nShifterType == SHIFTER_TYPE_ALTER_SELF || 
          (nShifterType == SHIFTER_TYPE_DISGUISE_SELF 
           && GetRacialType(oShifter) != RACIAL_TYPE_CHANGELING
           && !GetLocalInt(oShifter, "MaskOfFleshInvocation")
           && !GetLocalInt(oShifter, "HasFaceChanger")))
        {
            int nShiftedNumber = GetPersistantLocalInt(oShifter, "nTimesShifted");
            if(nShiftedNumber > 9) nShiftedNumber = 0;
            nShiftedNumber++;
            SetPersistantLocalInt(oShifter, "nTimesShifted", nShiftedNumber);
            int nMetaMagic = PRCGetMetaMagicFeat();
            int nDuration = PRCGetCasterLevel(oShifter) * 10;
            if ((nMetaMagic & METAMAGIC_EXTEND))
            {
                nDuration *= 2;
            }
            DelayCommand(TurnsToSeconds(nDuration), ForceUnshift(oShifter, nShiftedNumber));
        }
        
        else if(GetLocalInt(oShifter, "HumanoidShapeInvocation"))
        {
            int nShiftedNumber = GetPersistantLocalInt(oShifter, "nTimesShifted");
            if(nShiftedNumber > 9) nShiftedNumber = 0;
            nShiftedNumber++;
            SetPersistantLocalInt(oShifter, "nTimesShifted", nShiftedNumber);
            DelayCommand(HoursToSeconds(24), ForceUnshift(oShifter, nShiftedNumber));
        }
        
        else if(GetLocalInt(oShifter, "MaskOfFleshInvocation"))
        {
            int nShiftedNumber = GetPersistantLocalInt(oShifter, "nTimesShifted");
            if(nShiftedNumber > 9) nShiftedNumber = 0;
            nShiftedNumber++;
            SetPersistantLocalInt(oShifter, "nTimesShifted", nShiftedNumber);
            int nDuration = GetLocalInt(oShifter, "MaskOfFleshInvocation");
            DelayCommand(HoursToSeconds(nDuration), ForceUnshift(oShifter, nShiftedNumber));
        }

        else if(GetLocalInt(oShifter, "HasFaceChanger"))
        {
            int nShiftedNumber = GetPersistantLocalInt(oShifter, "nTimesShifted");
            if(nShiftedNumber > 9) nShiftedNumber = 0;
            nShiftedNumber++;
            SetPersistantLocalInt(oShifter, "nTimesShifted", nShiftedNumber);
            int nDuration = GetLocalInt(oShifter, "FaceChangerBonus");
            DelayCommand(RoundsToSeconds(nDuration), ForceUnshift(oShifter, nShiftedNumber));
        }

        // Run the class & feat evaluation code
        SetPersistantLocalString(oShifter, "PRC_SHIFTING_TEMPLATE_RESREF", GetResRef(oTemplate));
        SetPersistantLocalInt(oShifter, "PRC_SHIFTING_SHIFTER_TYPE", nShifterType);

        _prc_inc_shifting_EvalPRCFeats(oShifter, oShifterHide);
    }

    // Print shift information--this is slow, so wait until shifting is done
    int bDebug = GetLocalInt(oShifter, "prc_shift_debug");
    DelayCommand(SHIFTER_SHAPE_PRINT_DELAY, _prc_inc_PrintShape(oShifter, oTemplate, bDebug));

    // Destroy the template creature--we need the template to print, so wait until that's done
    DelayCommand(SHIFTER_TEMPLATE_DESTROY_DELAY, MyDestroyObject(oTemplate));
}

/** Internal function.
 * Does the actual work in unshifting. Restores creature items and
 * appearance. If oTemplate is valid, _prc_inc_shifting_ShiftIntoTemplateAux()
 * will be called once unshifting is finished.
 *
 * NOTE: This assumes that all polymorph effects have already been removed.
 *
 * @param oShifter Creature to unshift
 *
 *  Reshift parameters:
 * @param nShifterType            Passed to _prc_inc_shifting_ShiftIntoTemplateAux() when reshifting.
 * @param oTemplate               Passed to _prc_inc_shifting_ShiftIntoTemplateAux() when reshifting.
 * @param bGainSpellLikeAbilities Passed to _prc_inc_shifting_ShiftIntoTemplateAux() when reshifting.
 */
void _prc_inc_shifting_UnShiftAux(object oShifter, int nShifterType, object oTemplate, int bGainSpellLikeAbilities)
{
    int bReshift = GetIsObjectValid(oTemplate);
	
	effect eEffect = GetFirstEffect(oShifter);
		while(GetIsEffectValid(eEffect))
		{
			if(GetEffectTag(eEffect) == "ShifterAbilities")
				RemoveEffect(oShifter,eEffect);
			eEffect = GetNextEffect(oShifter);
		}
		
	// Get the shifter's creature items
    object oShifterHide = GetPCSkin(oShifter); // Use the PRC wrapper for this to make sure we get the right object
    object oShifterCWpR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oShifter);
    object oShifterCWpL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oShifter);
    object oShifterCWpB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oShifter);

    int nAdjustHP = bReshift && (
        nShifterType != SHIFTER_TYPE_CHANGESHAPE
        && nShifterType != SHIFTER_TYPE_HUMANOIDSHAPE 
        && nShifterType != SHIFTER_TYPE_ALTER_SELF 
        && nShifterType != SHIFTER_TYPE_DISGUISE_SELF
        && nShifterType != SHIFTER_TYPE_ARANEA
        //TODO?: && nShifterType != SHIFTER_TYPE_NONE
        );
    if(nAdjustHP)
    {
        int nOriginalHP = GetCurrentHitPoints(oShifter);
        int nOriginalMaxHP = GetMaxHitPoints(oShifter);
        SetLocalInt(oShifter, SHIFTER_ORIGINALHP, nOriginalHP);
        SetLocalInt(oShifter, SHIFTER_ORIGINALMAXHP, nOriginalMaxHP);

       //Before unshifting, fully heal the shifter. After shifting, some of the added hitpoints will be taken away again.
       //This is to prevent the Shifter from dying when shifting from one high CON form to another high CON form
       //due to the temporary loss of CON caused by shifting into the low-CON true form in between.
       ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nOriginalMaxHP), oShifter);
       
    }

    // Clear the hide. We'll have to run EvalPRCFeats() later on
    ScrubPCSkin(oShifter, oShifterHide);
    DeletePRCLocalInts(oShifterHide);
    GetPersistantLocalInt(oShifter, SHIFTER_TRUEAPPEARANCE);
        //HACK: For some reason, the next call to this function after the line above it returns FALSE even if it should return TRUE,
        //but the next call to it after that returns the correct result. So, call it here: this makes it return the correct
        //result for the RestoreTrueAppearance call below.
        //TODO: REMOVE when workaround no longer needed
        //TODO: is this because of the delays in DeletePRCLocalInts?

    // Nuke the creature weapons. If the normal form is supposed to have natural weapons, they'll get re-constructed
    if(GetIsObjectValid(oShifterCWpR)) MyDestroyObject(oShifterCWpR);
    if(GetIsObjectValid(oShifterCWpL)) MyDestroyObject(oShifterCWpL);
    if(GetIsObjectValid(oShifterCWpB)) MyDestroyObject(oShifterCWpB);

    object oSLAItem = GetItemPossessedBy(oShifter, SHIFTING_SLAITEM_TAG);
    int bCheckForAuraEffects = FALSE;
    if(GetIsObjectValid(oSLAItem))
    {
        MyDestroyObject(oSLAItem);
        bCheckForAuraEffects = TRUE;
    }

    // Remove effects
    _prc_inc_shifting_DeleteEffectInts(oShifter);

    if (!bReshift)
        _prc_inc_shifting_RemoveSpellEffects(oShifter, TRUE);

    effect eTest = GetFirstEffect(oShifter);
    if (bCheckForAuraEffects)
    {
        while(GetIsEffectValid(eTest))
        {
            int nEffectSpellID = GetEffectSpellId(eTest);
            
            if(nEffectSpellID == SPELLABILITY_AURA_BLINDING         ||
               nEffectSpellID == SPELLABILITY_AURA_COLD             ||
               nEffectSpellID == SPELLABILITY_AURA_ELECTRICITY      ||
               nEffectSpellID == SPELLABILITY_AURA_FEAR             ||
               nEffectSpellID == SPELLABILITY_AURA_FIRE             ||
               nEffectSpellID == SPELLABILITY_AURA_MENACE           ||
               nEffectSpellID == SPELLABILITY_AURA_PROTECTION       ||
               nEffectSpellID == SPELLABILITY_AURA_STUN             ||
               nEffectSpellID == SPELLABILITY_AURA_UNEARTHLY_VISAGE ||
               nEffectSpellID == SPELLABILITY_AURA_UNNATURAL        ||
               nEffectSpellID == SPELLABILITY_DRAGON_FEAR
               )
            {
                RemoveEffect(oShifter, eTest);
            }

            eTest = GetNextEffect(oShifter);
        }
    }

    // Restore appearance
    if(!RestoreTrueAppearance(oShifter))
    {
        string sError = "prc_inc_shifting: _UnShiftAux(): ERROR: Unable to restore true form for " + DebugObject2Str(oShifter);
        if(DEBUG) DoDebug(sError);
        else      WriteTimestampedLogEntry(sError);
    }

    // Unset the shiftedness marker
    SetPersistantLocalInt(oShifter, SHIFTER_ISSHIFTED_MARKER, FALSE);

    _prc_inc_shifting_EvalPRCFeats(oShifter, oShifterHide);

    // Queue reshifting to happen if needed. Let a short while pass so any fallout from the unshift gets handled
    if(bReshift)
        DelayCommand(1.0f, _prc_inc_shifting_ShiftIntoTemplateAux(oShifter, nShifterType, oTemplate, bGainSpellLikeAbilities));
    else
        SetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX, FALSE);
}

/** Internal function.
 * A polymorph effect was encountered during unshifting and removed. We need to
 * wait until it's actually removed (instead of merely gone from the active effects
 * list on oShifter) before calling _prc_inc_shifting_UnShiftAux().
 * This is done by tracking the contents of the creature armour slot. The object in
 * it will change when the polymorph is really removed.
 *
 * @param oShifter The creature whose creature armour slot to monitor.
 * @param oSkin    The skin object that was in the slot when the UnShift() call that triggered
 *                 this was run.
 * @param nRepeats Number of times this function has repeated the delay. Used to track timeout
 */
void _prc_inc_shifting_UnShiftAux_SeekPolyEnd(object oShifter, object oSkin, int nRepeats = 0)
{
    // Over 15 seconds passed, something is wrong
    if(nRepeats++ > 100)
    {
        if(DEBUG) DoDebug("prc_inc_shifting: _UnShiftAux_SeekPolyEnd(): ERROR: Repeated over 100 times, skin object remains the same.");
        return;
    }

    // See if the skin object has changed. When it does, the polymorph is genuinely gone instead of just being removed from the effects list
    if(GetItemInSlot(INVENTORY_SLOT_CARMOUR, oShifter) == oSkin)
        DelayCommand(0.15f, _prc_inc_shifting_UnShiftAux_SeekPolyEnd(oShifter, oSkin, nRepeats));
    // It's gone, finish unshifting
    else
        _prc_inc_shifting_UnShiftAux(oShifter, SHIFTER_TYPE_NONE, OBJECT_INVALID, FALSE);
}

object _prc_inc_load_template_from_resref(string sResRef, int nHD)
{
    /* Create the template to shift into */
    // Get the waypoint in Limbo where shifting template creatures are spawned
    object oSpawnWP = GetWaypointByTag(SHIFTING_TEMPLATE_WP_TAG);
    // Paranoia check - the WP should be built into the area data of Limbo
    if(!GetIsObjectValid(oSpawnWP))
    {
        if(DEBUG) DoDebug("prc_inc_shifting: ShiftIntoResRef(): ERROR: Template spawn waypoint does not exist.");
        // Create the WP
        oSpawnWP = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", GetLocation(GetObjectByTag("HEARTOFCHAOS")), FALSE, SHIFTING_TEMPLATE_WP_TAG);
    }

    // Get the WP's location
    location lSpawn  = GetLocation(oSpawnWP);

    // And spawn an instance of the given template there
    object oTemplate = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lSpawn);

    /*
    Some modules create low-level templates and level them up.
    Until now, when we tried learning the higher-level version, we ended up with the
    lower-level template instead. This level-up code takes care of that.
    
    Properly, we should remember what level we actually learned it at and only level that
    far, instead of leveling up to our current level. I've chosen to do it this way
    for the following reasons:
    > Doing it properly is more intrusive and more error-prone coding. For now, at least,
      I don't think it makes sense to do that.
    > Doing it properly way would litter our known shapes list with the same creature at different
      levels, when all we really want is the highest level one we can use.
    > From a role-playing point of view, shapes implemented that way by a module are presumably 
      common in the module, so a shifter would be pretty familiar with them and so would generally
      have learned the highest level he can shift into.
    */
    int bTemplateCanLevel = FALSE;
    if (LevelUpHenchman(oTemplate))
    {
        bTemplateCanLevel = TRUE;
        MyDestroyObject(oTemplate);
        oTemplate = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lSpawn);
    }
    if(bTemplateCanLevel)
    {
        int nNeedLevels = nHD - GetHitDice(oTemplate);
        if (GetPRCSwitch(PNP_SHFT_USECR))
        {
            int i;
            for (i=0; i<40; i+=1)
            {
                if (GetChallengeRating(oTemplate) > IntToFloat(nHD))
                    break;
                if (!LevelUpHenchman(oTemplate))
                    break;
            }
            nNeedLevels = GetHitDice(oTemplate);
            if (GetChallengeRating(oTemplate) > IntToFloat(nHD))
                nNeedLevels -= 1;
            MyDestroyObject(oTemplate);
            oTemplate = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lSpawn);
            nNeedLevels -= GetHitDice(oTemplate);
        }
        while (nNeedLevels > 0)
        {
            if (!LevelUpHenchman(oTemplate))
                break;
            nNeedLevels -= 1;
        }
        SetLocalInt(oTemplate, "prc_template_can_level", 1);
    }

    return oTemplate;
}

string _prc_inc_get_stored_name_from_template(object oTemplate)
{
    string sSuffix;
    if(GetLocalInt(oTemplate, "prc_template_can_level"))
        sSuffix = "+";
    string sResult = GetStringByStrRef(57438+0x01000000);
    sResult = ReplaceString(sResult, "%(NAME)", GetName(oTemplate));
    sResult = ReplaceString(sResult, "%(SL)", IntToString(_prc_inc_shifting_ShifterLevelRequirement(oTemplate)));
    sResult = ReplaceString(sResult, "%(CL)", IntToString(GetHitDice(oTemplate)) + sSuffix);
    sResult = ReplaceString(sResult, "%(CR)", FloatToString(GetChallengeRating(oTemplate), 4, 1) + sSuffix);
    return sResult;
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int StoreCurrentRaceAsTrueRace(object oShifter)
{
    if (GetPersistantLocalInt(oShifter, SHIFTER_ISSHIFTED_MARKER))
        return FALSE;

    if (IsPolymorphed(oShifter))
        return FALSE;

    SetPersistantLocalInt(oShifter, SHIFTER_TRUE_RACE, MyPRCGetRacialType(oShifter) + 1);
    
    return TRUE;
}

int StoreCurrentAppearanceAsTrueAppearance(object oShifter, int bCarefull = TRUE)
{
    // If requested, check that the creature isn't shifted or polymorphed
    if(bCarefull)
    {
        if (GetPersistantLocalInt(oShifter, SHIFTER_ISSHIFTED_MARKER))
            return FALSE;

        if (IsPolymorphed(oShifter))
            return FALSE;
    }

    // Get the appearance data
    struct appearancevalues appval = GetAppearanceData(oShifter);

    // Store it
    SetPersistantLocalAppearancevalues(oShifter, SHIFTER_TRUEAPPEARANCE, appval);
    SetPersistantLocalInt(oShifter, "TrueFormAppearanceType", GetAppearanceType(oShifter));

    // Set a marker that tells that the true appearance is stored
    SetPersistantLocalInt(oShifter, SHIFTER_TRUEAPPEARANCE, TRUE);

    return TRUE;
}

int RestoreTrueAppearance(object oShifter)
{
    // Check for the "true appearance stored" marker. Abort if it's not present
    if(!GetPersistantLocalInt(oShifter, SHIFTER_TRUEAPPEARANCE))
        return FALSE;

    // See if the character is polymorphed. Won't restore the appearance if it is
    if (IsPolymorphed(oShifter))
        return FALSE;

    // We got this far, everything should be OK
    // Retrieve the appearance data
    struct appearancevalues appval = GetPersistantLocalAppearancevalues(oShifter, SHIFTER_TRUEAPPEARANCE);

    // Apply it to the creature
    SetAppearanceData(oShifter, appval);
    
    if(GetLocalInt(oShifter, "DynamicAppearance"))
    {
        SetCreatureAppearanceType(oShifter, GetPersistantLocalInt(oShifter, "TrueFormAppearanceType"));
        DeleteLocalInt(oShifter, "DynamicAppearance");
    }

    // Inform caller of success
    return TRUE;
}


// Storage functions  //

int StoreShiftingTemplate(object oShifter, int nShifterType, object oTarget)
{
    // Some paranoia - both the target and the object to store on must be valid. And PCs are never legal for storage - PC resref should be always empty
    if(!(GetIsObjectValid(oShifter) && GetIsObjectValid(oTarget) && GetResRef(oTarget) != ""))
        return FALSE;

    string sResRefsArray    = SHIFTER_RESREFS_ARRAY + IntToString(nShifterType);
    string sNamesArray      = SHIFTER_NAMES_ARRAY   + IntToString(nShifterType);
    string sRacialTypeArray = SHIFTER_RACIALTYPE_ARRAY  + IntToString(nShifterType);

    // Determine array existence
    if(!persistant_array_exists(oShifter, sResRefsArray))
        persistant_array_create(oShifter, sResRefsArray);
    if(!persistant_array_exists(oShifter, sNamesArray))
        persistant_array_create(oShifter, sNamesArray);
    if(!persistant_array_exists(oShifter, sRacialTypeArray))
        persistant_array_create(oShifter, sRacialTypeArray);
    
    // Get the storeable data
    string sResRef = GetResRef(oTarget);
    string sName = _prc_inc_get_stored_name_from_template(oTarget);
    string sRacialType = IntToString(MyPRCGetRacialType(oTarget));
    int nArraySize = persistant_array_get_size(oShifter, sResRefsArray);

    // Check for the template already being present
    if(_prc_inc_shifting_GetIsTemplateStored(oShifter, nShifterType, sResRef))
        return FALSE;

    persistant_array_set_string(oShifter, sResRefsArray, nArraySize, sResRef);
    persistant_array_set_string(oShifter, sNamesArray, nArraySize, sName);
    persistant_array_set_string(oShifter, sRacialTypeArray, nArraySize, sRacialType);
    
    return TRUE;
}

int GetNumberOfStoredTemplates(object oShifter, int nShifterType)
{
    if(!persistant_array_exists(oShifter, SHIFTER_RESREFS_ARRAY + IntToString(nShifterType)))
        return 0;

    return persistant_array_get_size(oShifter, SHIFTER_RESREFS_ARRAY + IntToString(nShifterType));
}

string GetStoredTemplate(object oShifter, int nShifterType, int nIndex)
{
    return persistant_array_get_string(oShifter, SHIFTER_RESREFS_ARRAY + IntToString(nShifterType), nIndex);
}

string GetStoredTemplateFilter(object oShifter, int nShifterType)
{
    string sResult = "|";
    int nCount = GetNumberOfStoredTemplates(oShifter, nShifterType);
    int i;
    for(i=0; i<nCount; i++)
        sResult += persistant_array_get_string(oShifter, SHIFTER_RESREFS_ARRAY + IntToString(nShifterType), i) + "|";
    return sResult;
}

string GetStoredTemplateName(object oShifter, int nShifterType, int nIndex)
{
    return persistant_array_get_string(oShifter, SHIFTER_NAMES_ARRAY + IntToString(nShifterType), nIndex);
}

int GetStoredTemplateRacialType(object oShifter, int nShifterType, int nIndex)
{
    string sRacialTypeArray = SHIFTER_RACIALTYPE_ARRAY  + IntToString(nShifterType);
    string sRacialType = persistant_array_get_string(oShifter, sRacialTypeArray, nIndex);
    if(sRacialType == "")
        return -1;
    else
        return StringToInt(sRacialType);
}

void _UpdateStoredTemplateInfo(object oShifter, int nShifterType, int nStart, int nLimit)
{
    int nDeletedPrefixLen = GetStringLength(SHIFTER_DELETED_SHAPE_PREFIX);
    string sNamesArray = SHIFTER_NAMES_ARRAY   + IntToString(nShifterType);
    string sRacialTypeArray  = SHIFTER_RACIALTYPE_ARRAY + IntToString(nShifterType);
    int i;
    for(i = nStart; i < nLimit; i++)
    {
        string sName = persistant_array_get_string(oShifter, sNamesArray, i);
        string sRacialType = persistant_array_get_string(oShifter, sRacialTypeArray, i);
        object oTarget = _prc_inc_load_template_from_resref(GetStoredTemplate(oShifter, nShifterType, i), 0);
        if(GetIsObjectValid(oTarget))
        {
            sName = _prc_inc_get_stored_name_from_template(oTarget);
            sRacialType = IntToString(MyPRCGetRacialType(oTarget));
            MyDestroyObject(oTarget);
            persistant_array_set_string(oShifter, sNamesArray, i, sName);
            persistant_array_set_string(oShifter, sRacialTypeArray, i, sRacialType);
            _prc_inc_PrintShapeInfo(oShifter, IntToString(i) + " Updated: " + sName);
        }
        else
        {
            if (GetStringLeft(sName, nDeletedPrefixLen) != SHIFTER_DELETED_SHAPE_PREFIX)
                persistant_array_set_string(oShifter, sNamesArray, i, SHIFTER_DELETED_SHAPE_PREFIX + sName); //Add tag to name indicating that it could not be loaded
            _prc_inc_PrintShapeInfo(oShifter, IntToString(i) + " Could not update: " + sName);
        }
    }
}

void UpdateStoredTemplateInfo(object oShifter, int nShifterType, int nStart = 0)
{
    string sRacialTypeArray = SHIFTER_RACIALTYPE_ARRAY + IntToString(nShifterType);
    if(!persistant_array_exists(oShifter, sRacialTypeArray))
        persistant_array_create(oShifter, sRacialTypeArray);

    CHUNK_SIZE = 5;
    int nArraySize = GetNumberOfStoredTemplates(oShifter, nShifterType);
    if(nStart < nArraySize)
    {
        int nEnd = PRCMin(nStart + CHUNK_SIZE, nArraySize);
        _UpdateStoredTemplateInfo(oShifter, nShifterType, nStart, nEnd);
        if(nEnd < nArraySize)
            DelayCommand(0.0f, UpdateStoredTemplateInfo(oShifter, nShifterType, nEnd));
    }
}

void DeleteStoredTemplate(object oShifter, int nShifterType, int nIndex)
{
    string sResRefsArray = SHIFTER_RESREFS_ARRAY + IntToString(nShifterType);
    string sNamesArray   = SHIFTER_NAMES_ARRAY   + IntToString(nShifterType);
    string sRacialTypeArray  = SHIFTER_RACIALTYPE_ARRAY  + IntToString(nShifterType);

    // Determine array existence
    if(!persistant_array_exists(oShifter, sResRefsArray))
        return;
    if(!persistant_array_exists(oShifter, sNamesArray))
        return;
    int nRacialTypeArrayExists = persistant_array_exists(oShifter, sRacialTypeArray);

    // Move array entries
    int i, nArraySize = persistant_array_get_size(oShifter, sResRefsArray);
    for(i = nIndex; i < nArraySize - 1; i++)
    {
        persistant_array_set_string(oShifter, sResRefsArray, i,
                                    persistant_array_get_string(oShifter, sResRefsArray, i + 1)
                                    );
        persistant_array_set_string(oShifter, sNamesArray, i,
                                    persistant_array_get_string(oShifter, sNamesArray, i + 1)
                                    );
        if(nRacialTypeArrayExists)
            persistant_array_set_string(oShifter, sRacialTypeArray, i,
                                        persistant_array_get_string(oShifter, sRacialTypeArray, i + 1)
                                        );
    }

    // Shrink the arrays
    persistant_array_shrink(oShifter, sResRefsArray, nArraySize - 1);
    persistant_array_shrink(oShifter, sNamesArray,   nArraySize - 1);
    if(nRacialTypeArrayExists)
        persistant_array_shrink(oShifter, sRacialTypeArray, nArraySize - 1);
}

int GetStoredTemplateDeleteMark(object oShifter, int nShifterType, int nIndex)
{
    int nDeletedPrefixLen = GetStringLength(SHIFTER_DELETED_SHAPE_PREFIX);
    string sNamesArray = SHIFTER_NAMES_ARRAY + IntToString(nShifterType);

    if(!persistant_array_exists(oShifter, sNamesArray))
        return FALSE;

    int nArraySize = persistant_array_get_size(oShifter, sNamesArray);
    if (nIndex > nArraySize)
        return FALSE;
        
    string sName = persistant_array_get_string(oShifter, sNamesArray, nIndex);
    return GetStringLeft(sName, nDeletedPrefixLen) == SHIFTER_DELETED_SHAPE_PREFIX;
}

void SetStoredTemplateDeleteMark(object oShifter, int nShifterType, int nIndex, int bMark)
{
    int nDeletedPrefixLen = GetStringLength(SHIFTER_DELETED_SHAPE_PREFIX);
    string sNamesArray = SHIFTER_NAMES_ARRAY + IntToString(nShifterType);

    if(!persistant_array_exists(oShifter, sNamesArray))
        return;

    int nArraySize = persistant_array_get_size(oShifter, sNamesArray);
    if (nIndex > nArraySize)
        return;
        
    string sName = persistant_array_get_string(oShifter, sNamesArray, nIndex);
    if (GetStringLeft(sName, nDeletedPrefixLen) == SHIFTER_DELETED_SHAPE_PREFIX)
    {
        if (!bMark)
            sName = GetStringRight(sName, GetStringLength(sName)-nDeletedPrefixLen);
    }
    else
    {
        if (bMark)
            sName = SHIFTER_DELETED_SHAPE_PREFIX + sName;
    }
    persistant_array_set_string(oShifter, sNamesArray, nIndex, sName);
}

void DeleteMarkedStoredTemplates(object oShifter, int nShifterType, int nSrc=0, int nDst=0)
{
    int nDeletedPrefixLen = GetStringLength(SHIFTER_DELETED_SHAPE_PREFIX);
    string sResRefsArray = SHIFTER_RESREFS_ARRAY + IntToString(nShifterType);
    string sNamesArray = SHIFTER_NAMES_ARRAY   + IntToString(nShifterType);
    string sRacialTypeArray = SHIFTER_RACIALTYPE_ARRAY  + IntToString(nShifterType);

    // Determine array existence
    if(!persistant_array_exists(oShifter, sResRefsArray))
        return;
    if(!persistant_array_exists(oShifter, sNamesArray))
        return;
    int nRacialTypeArrayExists = persistant_array_exists(oShifter, sRacialTypeArray);

    // Move array entries, skipping the marked ones
    int nCount = 0, nArraySize = persistant_array_get_size(oShifter, sResRefsArray);
    string sName, sResRef, sRace;
    while(nSrc < nArraySize && nCount++ < CHUNK_SIZE)
    {
        sName = persistant_array_get_string(oShifter, sNamesArray, nSrc);
        if (GetStringLeft(sName, nDeletedPrefixLen) != SHIFTER_DELETED_SHAPE_PREFIX)
        {
            if (nSrc != nDst)
            {
                persistant_array_set_string(oShifter, sNamesArray, nDst, sName);
                sResRef = persistant_array_get_string(oShifter, sResRefsArray, nSrc);
                persistant_array_set_string(oShifter, sResRefsArray, nDst, sResRef);
                if (nRacialTypeArrayExists)
                {
                    sRace = persistant_array_get_string(oShifter, sRacialTypeArray, nSrc);
                    persistant_array_set_string(oShifter, sRacialTypeArray, nDst, sRace);
                }
            }
            nDst++;
        }
        else
        {
            DoDebug("Deleting shape: " + sName);
        }
        nSrc++;
    }
    
    if (nSrc < nArraySize)
        DelayCommand(0.0f, DeleteMarkedStoredTemplates(oShifter, nShifterType, nSrc, nDst));
    else
    {
        // Shrink the arrays
        persistant_array_shrink(oShifter, sResRefsArray, nDst);
        persistant_array_shrink(oShifter, sNamesArray, nDst);
        if(nRacialTypeArrayExists)
            persistant_array_shrink(oShifter, sRacialTypeArray, nDst);
    }
}


// Shifting-related functions

int GetCreatureIsKnown(object oShifter, int nShifterType, object oTemplate)
{
    int nReturn = 0;

    if(GetIsObjectValid(oShifter) && GetIsObjectValid(oTemplate))
        nReturn = _prc_inc_shifting_GetIsTemplateStored(oShifter, nShifterType, GetResRef(oTemplate));
    
    return nReturn;
}

string FindResRefFromString(object oShifter, int nShifterType, string sFindString, int bList)
{
    string sResRef, sResRefsArray = SHIFTER_RESREFS_ARRAY + IntToString(nShifterType);
    string sName, sNamesArray = SHIFTER_NAMES_ARRAY + IntToString(nShifterType);
    int nResRef, nArraySize = persistant_array_get_size(oShifter, sResRefsArray);

    //Check for current shape
    
    if(sFindString == ".")
    {
        sResRef = GetPersistantLocalString(oShifter, "PRC_SHIFTING_TEMPLATE_RESREF");
        if(sResRef == "")
            DoDebug("Current shape match: NOT SHIFTED");
        else
        {
            nResRef = _prc_inc_shifting_GetIsTemplateStored(oShifter, nShifterType, sResRef) - 1;
            if(nResRef >= 0)
                sName = persistant_array_get_string(oShifter, sNamesArray, nResRef);
            else
                sName = "???";
            DoDebug("Current shape match: " + IntToString(nResRef+1) + " = " + sName + " [" + sResRef + "]");
        }
        return sResRef;
    }

    //Check for shape numbers
    
    int nShapeNumberMatch = StringToInt(sFindString);
    if(nShapeNumberMatch >= 1 && nShapeNumberMatch <= nArraySize)
    {
        nShapeNumberMatch -= 1;
        sName = persistant_array_get_string(oShifter, sNamesArray, nShapeNumberMatch);
        sResRef = persistant_array_get_string(oShifter, sResRefsArray, nShapeNumberMatch);
        DoDebug("Shape number match: #" + IntToString(nShapeNumberMatch+1) + " = " + sName + " [" + sResRef + "]");
        return sResRef;        
    }
    
    //Check for quick shift slots numbers
    
    string sFirstLetter = GetStringLeft(sFindString, 1);
    if(sFirstLetter == "q" || sFirstLetter == "Q")
    {
        int nQuickSlotMatch = StringToInt(GetStringRight(sFindString, GetStringLength(sFindString)-1));
        if(nQuickSlotMatch >= 1 && nQuickSlotMatch <= 10)
        {
            sResRef = GetPersistantLocalString(oShifter, "PRC_Shifter_Quick_" + IntToString(nQuickSlotMatch) + "_ResRef");
            nResRef = _prc_inc_shifting_GetIsTemplateStored(oShifter, nShifterType, sResRef) - 1;
            if(nResRef >= 0)
                sName = persistant_array_get_string(oShifter, sNamesArray, nResRef);
            else
                sName = "???";
            if(sResRef == "")
                DoDebug("Quickslot match: Q" + IntToString(nQuickSlotMatch) + " = EMPTY QUICKSLOT");
            else
                DoDebug("Quickslot match: Q" + IntToString(nQuickSlotMatch) + " = " + sName + " [" + sResRef + "]");
            return sResRef;        
        }        
    }
    
    //Check for matching resref first (exact case)
    
    int nResRefMatch = _prc_inc_shifting_GetIsTemplateStored(oShifter, nShifterType, sFindString) - 1;
    if(nResRefMatch >= 0)
    {
        sName = persistant_array_get_string(oShifter, sNamesArray, nResRefMatch);
        sResRef = persistant_array_get_string(oShifter, sResRefsArray, nResRefMatch);
        DoDebug("ResRef match: "+ IntToString(nResRefMatch+1) + " = " + sName + " [" + sResRef + "]");
        return sResRef;
    }
    
    //Check for matching name next (ignoring case)
    
    sFindString = GetStringLowerCase(sFindString);

    int nExactMatch = -1, nPrefixMatch = -1, nPartialMatch = -1;
    int nExactMatchCount = 0, nPrefixMatchCount = 0, nPartialMatchCount = 0;
    int i, nFind;
    string sLowerName;
    for(i = 0; i < nArraySize; i++)
    {
        sName = persistant_array_get_string(oShifter, sNamesArray, i);
        nFind = FindSubString(sName, " (");
        if(nFind != -1)
            sName = GetStringLeft(sName, nFind); //Remove the part in parens that tells shape HD, CR, etc.
        sLowerName = GetStringLowerCase(sName);
    
        if (bList && sFindString == "")
        {
            sName = persistant_array_get_string(oShifter, sNamesArray, i);
            sResRef = persistant_array_get_string(oShifter, sResRefsArray, i);
            DoDebug("#" + IntToString(i+1) + " = " + sName + " [" + sResRef + "]");
        }
        else if(sFindString == sLowerName)
        {
            nExactMatch = i;
            nExactMatchCount += 1;
            sName = persistant_array_get_string(oShifter, sNamesArray, nExactMatch);
            sResRef = persistant_array_get_string(oShifter, sResRefsArray, nExactMatch);
            DoDebug("Exact match: #" + IntToString(i+1) + " = " + sName + " [" + sResRef + "]");
        }
        else
        {
            //TODO: multi-word prefix matches
            nFind = FindSubString(sLowerName, sFindString);
            if(nFind == 0)
            {
                nPrefixMatch = i;
                nPrefixMatchCount += 1;
                sName = persistant_array_get_string(oShifter, sNamesArray, nPrefixMatch);
                sResRef = persistant_array_get_string(oShifter, sResRefsArray, nPrefixMatch);
                DoDebug("Beginning match: #" + IntToString(i+1) + " = " + sName + " [" + sResRef + "]");
            }
            else if(nFind > 0)
            {
                nPartialMatch = i;
                nPartialMatchCount += 1;
                sName = persistant_array_get_string(oShifter, sNamesArray, nPartialMatch);
                sResRef = persistant_array_get_string(oShifter, sResRefsArray, nPartialMatch);
                DoDebug("Middle match: #" + IntToString(i+1) + " = " + sName + " [" + sResRef + "]");
            }
        }
    }
    
    if(nExactMatchCount)
    {
        if(nExactMatchCount > 1)
        {
            DoDebug("TOO MANY EXACT MATCHES (" +IntToString(nExactMatchCount) + " found)");
            return "";
        }
        sName = persistant_array_get_string(oShifter, sNamesArray, nExactMatch);
        sResRef = persistant_array_get_string(oShifter, sResRefsArray, nExactMatch);
        DoDebug("FINAL MATCH: #" + IntToString(nExactMatch+1) + " = " + sName + " [" + sResRef + "]");
        return sResRef;
    }
    if(nPrefixMatchCount)
    {
        if(nPrefixMatchCount > 1)
        {
            DoDebug("TOO MANY BEGINNING MATCHES (" +IntToString(nPrefixMatchCount) + " found)");
            return "";
        }
        sName = persistant_array_get_string(oShifter, sNamesArray, nPrefixMatch);
        sResRef = persistant_array_get_string(oShifter, sResRefsArray, nPrefixMatch);
        DoDebug("FINAL MATCH: #" + IntToString(nPrefixMatch+1) + " = " + sName + " [" + sResRef + "]");
        return sResRef;
    }
    if(nPartialMatchCount)
    {
        if(nPartialMatchCount > 1)
        {
            DoDebug("TOO MANY MIDDLE MATCHES (" +IntToString(nPartialMatchCount) + " found)");
            return "";
        }
        sName = persistant_array_get_string(oShifter, sNamesArray, nPartialMatch);
        sResRef= persistant_array_get_string(oShifter, sResRefsArray, nPartialMatch);
        DoDebug("FINAL MATCH: #" + IntToString(nPartialMatch+1) + " = " + sName + " [" + sResRef + "]");
        return sResRef;
    }
    
    DoDebug("NO MATCH");

    return "";
}

int GetCanShiftIntoCreature(object oShifter, int nShifterType, object oTemplate)
{
    if (!GetPersistantLocalInt(oShifter, "PRC_UNI_SHIFT_SCRIPT"))
    {
        SetPersistantLocalInt(oShifter, "PRC_UNI_SHIFT_SCRIPT", 1);
        ExecuteScript("prc_uni_shift", oShifter);
    }

    // Base assumption: Can shift into the target
    int bReturn = TRUE;

    // Some basic checks
    if(GetIsObjectValid(oShifter) && GetIsObjectValid(oTemplate))
    {
        // PC check
        if(GetIsPC(oTemplate))
        {
            bReturn = FALSE;
            SendMessageToPCByStrRef(oShifter, STRREF_NOPOLYTOPC); // "You cannot polymorph into a PC."
        }
        // Shifting prevention feat
        else if(GetHasFeat(SHIFTER_BLACK_LIST, oTemplate))
        {
            bReturn = FALSE;
            SendMessageToPCByStrRef(oShifter, STRREF_FORBIDPOLY); // "Target cannot be polymorphed into."
        }

        // Test switch-based limitations
        if(bReturn)
        {
            int nSize       = PRCGetCreatureSize(oTemplate);
            int nRacialType = MyPRCGetRacialType(oTemplate);

            // Size switches
            if(nSize >= CREATURE_SIZE_HUGE   && GetPRCSwitch(PNP_SHFT_S_HUGE))
                bReturn = FALSE;
            if(nSize == CREATURE_SIZE_LARGE  && GetPRCSwitch(PNP_SHFT_S_LARGE))
                bReturn = FALSE;
            if(nSize == CREATURE_SIZE_MEDIUM && GetPRCSwitch(PNP_SHFT_S_MEDIUM))
                bReturn = FALSE;
            if(nSize == CREATURE_SIZE_SMALL  && GetPRCSwitch(PNP_SHFT_S_SMALL))
                bReturn = FALSE;
            if(nSize <= CREATURE_SIZE_TINY   && GetPRCSwitch(PNP_SHFT_S_TINY))
                bReturn = FALSE;

            // Type switches
            if(nRacialType == RACIAL_TYPE_OUTSIDER           && GetPRCSwitch(PNP_SHFT_F_OUTSIDER))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_ELEMENTAL          && GetPRCSwitch(PNP_SHFT_F_ELEMENTAL))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_CONSTRUCT          && GetPRCSwitch(PNP_SHFT_F_CONSTRUCT))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_UNDEAD             && GetPRCSwitch(PNP_SHFT_F_UNDEAD))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_DRAGON             && GetPRCSwitch(PNP_SHFT_F_DRAGON))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_ABERRATION         && GetPRCSwitch(PNP_SHFT_F_ABERRATION))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_OOZE               && GetPRCSwitch(PNP_SHFT_F_OOZE))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_MAGICAL_BEAST      && GetPRCSwitch(PNP_SHFT_F_MAGICALBEAST))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_GIANT              && GetPRCSwitch(PNP_SHFT_F_GIANT))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_VERMIN             && GetPRCSwitch(PNP_SHFT_F_VERMIN))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_BEAST              && GetPRCSwitch(PNP_SHFT_F_BEAST))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_ANIMAL             && GetPRCSwitch(PNP_SHFT_F_ANIMAL))
                bReturn = FALSE;
            if(nRacialType == RACIAL_TYPE_HUMANOID_MONSTROUS && GetPRCSwitch(PNP_SHFT_F_MONSTROUSHUMANOID))
                bReturn = FALSE;
            if(GetPRCSwitch(PNP_SHFT_F_HUMANOID)            &&
               (nRacialType == RACIAL_TYPE_DWARF              ||
                nRacialType == RACIAL_TYPE_ELF                ||
                nRacialType == RACIAL_TYPE_GNOME              ||
                nRacialType == RACIAL_TYPE_HUMAN              ||
                nRacialType == RACIAL_TYPE_HALFORC            ||
                nRacialType == RACIAL_TYPE_HALFELF            ||
                nRacialType == RACIAL_TYPE_HALFLING           ||
                nRacialType == RACIAL_TYPE_HUMANOID_ORC       ||
                nRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN
               ))
                bReturn = FALSE;

            if(!bReturn)
                SendMessageToPCByStrRef(oShifter, STRREF_SETTINGFORBID); // "The module settings prevent this creature from being polymorphed into."
        }

        // Still OK, test HD or CR
        if(bReturn)
        {
            // Check target's HD or CR
            int nShifterHD  = GetHitDice(oShifter);
            int nTemplateHD = _prc_inc_shifting_CharacterLevelRequirement(oTemplate);
            if(nTemplateHD > nShifterHD)
            {
                bReturn = FALSE;
                // "You need X more character levels before you can take on that form."
                SendMessageToPC(oShifter, GetStringByStrRef(STRREF_YOUNEED) + " " + IntToString(nTemplateHD - nShifterHD) + " " + GetStringByStrRef(STRREF_MORECHARLVL));
            }
            
            if(nShifterType == SHIFTER_TYPE_ALTER_SELF && nTemplateHD > 5)
            {
                bReturn = FALSE;
                SendMessageToPC(oShifter, "This creature is too high a level to copy with this spell.");
            }
        }// end if - Checking HD or CR

        // Move onto shifting type-specific checks if there haven't been any problems yet
        if(bReturn)
        {
            if(nShifterType == SHIFTER_TYPE_SHIFTER)
            {
                int nShifterLevel  = GetLevelByClass(CLASS_TYPE_PNP_SHIFTER, oShifter);

                int nRacialType = MyPRCGetRacialType(oTemplate);

                // Fey and shapechangers are forbidden targets for PnP Shifter
                if(nRacialType == RACIAL_TYPE_FEY || nRacialType == RACIAL_TYPE_SHAPECHANGER)
                {
                    bReturn = FALSE;
                    SendMessageToPCByStrRef(oShifter, STRREF_PNPSFHT_FEYORSSHIFT); // "You cannot use PnP Shifter abilities to polymorph into this creature."
                }
                else
                {
                    // Test level required
                    int nLevelRequired = _prc_inc_shifting_ShifterLevelRequirement(oTemplate);
                    if(nLevelRequired > nShifterLevel)
                    {
                        bReturn = FALSE;
                        // "You need X more PnP Shifter levels before you can take on that form."
                        SendMessageToPC(oShifter, GetStringByStrRef(STRREF_YOUNEED) + " " + IntToString(nLevelRequired - nShifterLevel) + " " + GetStringByStrRef(STRREF_PNPSHFT_MORELEVEL));
                    }
                }// end else - Not outright forbidden due to target being Fey or Shapeshifter
            }// end if - PnP Shifter checks
        
            //Change Shape checks
            else if(nShifterType == SHIFTER_TYPE_HUMANOIDSHAPE)
            {                    
                int nTargetSize        = PRCGetCreatureSize(oTemplate);
                int nRacialType        = MyPRCGetRacialType(oTemplate);
                int nShifterSize       = PRCGetCreatureSize(oShifter);
                    
                int nSizeDiff = nTargetSize - nShifterSize;
                    
                if(nSizeDiff > 1 || nSizeDiff < -1)
                {
                    bReturn = FALSE;
                    SendMessageToPC(oShifter, "This creature is too large or too small.");
                }
                   
                if(!(nRacialType == RACIAL_TYPE_DWARF            ||
                   nRacialType == RACIAL_TYPE_ELF                ||
                   nRacialType == RACIAL_TYPE_GNOME              ||
                   nRacialType == RACIAL_TYPE_HUMAN              ||
                   nRacialType == RACIAL_TYPE_HALFORC            ||
                   nRacialType == RACIAL_TYPE_HALFELF            ||
                   nRacialType == RACIAL_TYPE_HALFLING           ||
                   nRacialType == RACIAL_TYPE_HUMANOID_ORC       ||
				   nRacialType == RACIAL_TYPE_HUMANOID_GOBLINOID ||
                   nRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN
                   ))
                {
                    bReturn = FALSE;
                    SendMessageToPC(oShifter, "This creature is not a humanoid racial type.");
                }
            }
                
            //Changeling check
            else if(nShifterType == SHIFTER_TYPE_DISGUISE_SELF && GetRacialType(oShifter) == RACIAL_TYPE_CHANGELING)
            {                    
                int nSize        = PRCGetCreatureSize(oTemplate);
                int nRacialType  = MyPRCGetRacialType(oTemplate);
                int nShifterSize = PRCGetCreatureSize(oShifter);
                    
                if(nSize != nShifterSize)
                {
                    bReturn = FALSE;
                    SendMessageToPC(oShifter, "This creature is too large or too small.");
                }
                  
                if(!(nRacialType == RACIAL_TYPE_DWARF            ||
                   nRacialType == RACIAL_TYPE_ELF                ||
                   nRacialType == RACIAL_TYPE_GNOME              ||
                   nRacialType == RACIAL_TYPE_HUMAN              ||
                   nRacialType == RACIAL_TYPE_HALFORC            ||
                   nRacialType == RACIAL_TYPE_HALFELF            ||
                   nRacialType == RACIAL_TYPE_HALFLING           ||
                   nRacialType == RACIAL_TYPE_HUMANOID_ORC       ||
				   nRacialType == RACIAL_TYPE_HUMANOID_GOBLINOID ||
                   nRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN
                   ))
                {
                    bReturn = FALSE;
                    SendMessageToPC(oShifter, "This creature is not a humanoid racial type.");
                }
            }
                
            //Generic check
            else if(nShifterType == SHIFTER_TYPE_CHANGESHAPE 
                    || nShifterType == SHIFTER_TYPE_ALTER_SELF
                    || (nShifterType == SHIFTER_TYPE_DISGUISE_SELF && GetRacialType(oShifter) != RACIAL_TYPE_CHANGELING))
            {                    
                int nTargetSize        = PRCGetCreatureSize(oTemplate);
                int nTargetRacialType  = MyPRCGetRacialType(oTemplate);
                int nShifterSize       = PRCGetCreatureSize(oShifter);
                int nShifterRacialType = MyPRCGetRacialType(oShifter);
                    
                int nSizeDiff = nTargetSize - nShifterSize;
                    
                if(nSizeDiff > 1 || nSizeDiff < -1)
                {
                    bReturn = FALSE;
                    SendMessageToPC(oShifter, "This creature is too large or too small.");
                }
                    
                if(!(nTargetRacialType == nShifterRacialType ||
                   //check for humanoid type
                   ((nTargetRacialType == RACIAL_TYPE_DWARF            ||
                   nTargetRacialType == RACIAL_TYPE_ELF                ||
                   nTargetRacialType == RACIAL_TYPE_GNOME              ||
                   nTargetRacialType == RACIAL_TYPE_HUMAN              ||
                   nTargetRacialType == RACIAL_TYPE_HALFORC            ||
                   nTargetRacialType == RACIAL_TYPE_HALFELF            ||
                   nTargetRacialType == RACIAL_TYPE_HALFLING           ||
				   nTargetRacialType == RACIAL_TYPE_HUMANOID_GOBLINOID ||
                   nTargetRacialType == RACIAL_TYPE_HUMANOID_ORC       ||
                   nTargetRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN
                   ) &&
                   (nShifterRacialType == RACIAL_TYPE_DWARF            ||
                   nShifterRacialType == RACIAL_TYPE_ELF                ||
                   nShifterRacialType == RACIAL_TYPE_GNOME              ||
                   nShifterRacialType == RACIAL_TYPE_HUMAN              ||
                   nShifterRacialType == RACIAL_TYPE_HALFORC            ||
                   nShifterRacialType == RACIAL_TYPE_HALFELF            ||
                   nShifterRacialType == RACIAL_TYPE_HALFLING           ||
				   nShifterRacialType == RACIAL_TYPE_HUMANOID_GOBLINOID ||
                   nShifterRacialType == RACIAL_TYPE_HUMANOID_ORC       ||
                   nShifterRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN
                   ))
                   ))
                {
                    bReturn = FALSE;
                    SendMessageToPC(oShifter, "This creature is a different racial type.");
                }
            }
        }// end if - Check shifting list specific stuff
    }
    // Failed one of the basic checks
    else
        bReturn = FALSE;

    return bReturn;
}

int ShiftIntoCreature(object oShifter, int nShifterType, object oTemplate, int bGainSpellLikeAbilities = FALSE)
{
    // Just grab the resref and move on
    return ShiftIntoResRef(oShifter, nShifterType, GetResRef(oTemplate), bGainSpellLikeAbilities);
}

int ShiftIntoResRef(object oShifter, int nShifterType, string sResRef, int bGainSpellLikeAbilities = FALSE)
{
    if (!GetPersistantLocalInt(oShifter, "PRC_UNI_SHIFT_SCRIPT"))
    {
        SetPersistantLocalInt(oShifter, "PRC_UNI_SHIFT_SCRIPT", 1);
        ExecuteScript("prc_uni_shift", oShifter);
    }
    
    // Make sure there is nothing that would prevent the successful execution of the shift from happening
    if(!_prc_inc_shifting_GetCanShift(oShifter))
        return FALSE;

    /* Create the template to shift into */
    object oTemplate = _prc_inc_load_template_from_resref(sResRef, GetHitDice(oShifter));

    // Make sure the template creature was successfully created. We have nothing to do if it wasn't
    if(!GetIsObjectValid(oTemplate))
    {
        if(DEBUG) DoDebug("prc_inc_shifting: ShiftIntoResRef(): ERROR: Failed to create creature from template resref: " + sResRef);
        SendMessageToPCByStrRef(oShifter, STRREF_TEMPLATE_FAILURE); // "Polymorph failed: Failed to create a template of the creature to polymorph into."
    }
    else
    {
        // See if the shifter can in fact shift into the given template
        if(GetCanShiftIntoCreature(oShifter, nShifterType, oTemplate))
        {
            // It can - activate mutex
            SetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX, TRUE);
            SetLocalInt(oShifter, SHIFTER_ORIGINALMAXHP, 0);

            int nShapeGeneration = GetLocalInt(oShifter, PRC_Shifter_ShapeGeneration);
            SetLocalInt(oShifter, PRC_Shifter_ShapeGeneration, nShapeGeneration+1);
            if (DEBUG_APPLY_PROPERTIES)
                DoDebug("ShiftIntoResRef, Shifter Index: " + IntToString(nShapeGeneration+1));

            // Unshift if already shifted and then proceed with shifting into the template
            // Also, give other stuff 100ms to execute in between
            if(GetPersistantLocalInt(oShifter, SHIFTER_ISSHIFTED_MARKER))
                DelayCommand(0.1f, _prc_inc_shifting_UnShiftAux(oShifter, nShifterType, oTemplate, bGainSpellLikeAbilities));
            else
                DelayCommand(0.1f, _prc_inc_shifting_ShiftIntoTemplateAux(oShifter, nShifterType, oTemplate, bGainSpellLikeAbilities));
            
            // Return that we were able to successfully start shifting
            return TRUE;
        }
    }

    // We didn't reach the success branch for some reason
    return FALSE;
}

int GWSPay(object oShifter, int bEpic)
{
    int nFeat = 0;

    if(!bEpic)
    {
        // First try paying using Greater Wildshape uses
        if(GetHasFeat(FEAT_PRESTIGE_SHIFTER_GWSHAPE_1, oShifter))
        {
            DecrementRemainingFeatUses(oShifter, FEAT_PRESTIGE_SHIFTER_GWSHAPE_1);
            nFeat = FEAT_PRESTIGE_SHIFTER_GWSHAPE_1;

            // If we would reach 0 uses this way, see if we could pay with Druid Wildshape uses instead
            if(!GetHasFeat(FEAT_PRESTIGE_SHIFTER_GWSHAPE_1, oShifter)    &&
               GetPersistantLocalInt(oShifter, "PRC_Shifter_UseDruidWS") &&
               GetHasFeat(FEAT_WILD_SHAPE, oShifter)
               )
            {
                IncrementRemainingFeatUses(oShifter, FEAT_PRESTIGE_SHIFTER_GWSHAPE_1);
                DecrementRemainingFeatUses(oShifter, FEAT_WILD_SHAPE);
                nFeat = FEAT_WILD_SHAPE;
            }
        }
        // Otherwise try paying with Druid Wildshape uses
        else if(GetPersistantLocalInt(oShifter, "PRC_Shifter_UseDruidWS") &&
                GetHasFeat(FEAT_WILD_SHAPE, oShifter)
                )
        {
            DecrementRemainingFeatUses(oShifter, FEAT_WILD_SHAPE);
            nFeat = FEAT_WILD_SHAPE;
        }
    }
    // Epic shift, uses Epic Greater Wildshape
    else if(GetHasFeat(FEAT_PRESTIGE_SHIFTER_EGWSHAPE_1, oShifter))
    {
        DecrementRemainingFeatUses(oShifter, FEAT_PRESTIGE_SHIFTER_EGWSHAPE_1);
        nFeat = FEAT_PRESTIGE_SHIFTER_EGWSHAPE_1;
    }
    
    return nFeat;
}

void GWSRefund(object oShifter, int nRefundFeat)
{
    IncrementRemainingFeatUses(oShifter, nRefundFeat);
}

int UnShift(object oShifter, int bRemovePoly = TRUE, int bIgnoreShiftingMutex = FALSE)
{
    // Shifting mutex is set and we are not told to ignore it, so abort right away
    if(GetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX) && !bIgnoreShiftingMutex)
    {
        DelayCommand(SHIFTER_MUTEX_UNSET_DELAY, SetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX, FALSE)); //In case the mutex got stuck, unstick it
        return UNSHIFT_FAIL;
    }

    // Check for polymorph effects
    int bHadPoly = FALSE;
    effect eTest = GetFirstEffect(oShifter);
    while(GetIsEffectValid(eTest))
    {
        if(GetEffectType(eTest) == EFFECT_TYPE_POLYMORPH)
            // Depending on whether we are supposed to remove them or not either remove the effect or abort
            if(bRemovePoly)
            {
                bHadPoly = UNSHIFT_FAIL;
                RemoveEffect(oShifter, eTest);
            }
            else
                return FALSE;

        eTest = GetNextEffect(oShifter);
    }

    // Check for true form being stored
    if(!GetPersistantLocalInt(oShifter, SHIFTER_TRUEAPPEARANCE))
        return UNSHIFT_FAIL;

    // The unshifting should always proceed succesfully from this point on, so set the mutex
    SetLocalInt(oShifter, SHIFTER_SHIFT_MUTEX, TRUE);
    SetLocalInt(oShifter, SHIFTER_ORIGINALMAXHP, 0);
    DeletePersistantLocalString(oShifter, "PRC_SHIFTING_TEMPLATE_RESREF");
    DeletePersistantLocalInt(oShifter, "PRC_SHIFTING_SHIFTER_TYPE");

    int nShapeGeneration = GetLocalInt(oShifter, PRC_Shifter_ShapeGeneration);
    SetLocalInt(oShifter, PRC_Shifter_ShapeGeneration, nShapeGeneration+1);
    if (DEBUG_APPLY_PROPERTIES)
        DoDebug("UnShift, Shifter Index: " + IntToString(nShapeGeneration+1));

    // If we had a polymorph effect present, start the removal monitor
    if(bHadPoly)
    {
        DelayCommand(0.1f, _prc_inc_shifting_UnShiftAux_SeekPolyEnd(oShifter, GetItemInSlot(INVENTORY_SLOT_CARMOUR, oShifter)));
        return UNSHIFT_SUCCESS_DELAYED;
    }
    else
    {
        _prc_inc_shifting_UnShiftAux(oShifter, SHIFTER_TYPE_NONE, OBJECT_INVALID, FALSE);
        DeletePersistantLocalInt(oShifter, "TempShifted");
        return UNSHIFT_SUCCESS;
    }
}


// Appearance data functions

struct appearancevalues GetAppearanceData(object oTemplate)
{
	struct appearancevalues appval;
	// The appearance type
    appval.nAppearanceType         = GetAppearanceType(oTemplate);
    // Body parts
    appval.nBodyPart_RightFoot     = GetCreatureBodyPart(CREATURE_PART_RIGHT_FOOT,     oTemplate);
    appval.nBodyPart_LeftFoot      = GetCreatureBodyPart(CREATURE_PART_LEFT_FOOT,      oTemplate);
    appval.nBodyPart_RightShin     = GetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN,     oTemplate);
    appval.nBodyPart_LeftShin      = GetCreatureBodyPart(CREATURE_PART_LEFT_SHIN,      oTemplate);
    appval.nBodyPart_RightThigh    = GetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH,    oTemplate);
    appval.nBodyPart_LeftThight    = GetCreatureBodyPart(CREATURE_PART_LEFT_THIGH,     oTemplate);
    appval.nBodyPart_Pelvis        = GetCreatureBodyPart(CREATURE_PART_PELVIS,         oTemplate);
    appval.nBodyPart_Torso         = GetCreatureBodyPart(CREATURE_PART_TORSO,          oTemplate);
    appval.nBodyPart_Belt          = GetCreatureBodyPart(CREATURE_PART_BELT,           oTemplate);
    appval.nBodyPart_Neck          = GetCreatureBodyPart(CREATURE_PART_NECK,           oTemplate);
    appval.nBodyPart_RightForearm  = GetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM,  oTemplate);
    appval.nBodyPart_LeftForearm   = GetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM,   oTemplate);
    appval.nBodyPart_RightBicep    = GetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP,    oTemplate);
    appval.nBodyPart_LeftBicep     = GetCreatureBodyPart(CREATURE_PART_LEFT_BICEP,     oTemplate);
    appval.nBodyPart_RightShoulder = GetCreatureBodyPart(CREATURE_PART_RIGHT_SHOULDER, oTemplate);
    appval.nBodyPart_LeftShoulder  = GetCreatureBodyPart(CREATURE_PART_LEFT_SHOULDER,  oTemplate);
    appval.nBodyPart_RightHand     = GetCreatureBodyPart(CREATURE_PART_RIGHT_HAND,     oTemplate);
    appval.nBodyPart_LeftHand      = GetCreatureBodyPart(CREATURE_PART_LEFT_HAND,      oTemplate);
    appval.nBodyPart_Head          = GetCreatureBodyPart(CREATURE_PART_HEAD,           oTemplate);
    // Wings
    appval.nWingType               = GetCreatureWingType(oTemplate);
    // Tail
    appval.nTailType               = GetCreatureTailType(oTemplate);
    // Portrait ID
    appval.nPortraitID             = GetPortraitId(oTemplate);
    // Portrait resref
    appval.sPortraitResRef         = GetPortraitResRef(oTemplate);
    // Footstep type
    appval.nFootStepType           = GetFootstepType(oTemplate);
    // Gender
    appval.nGender                 = GetGender(oTemplate);
    /* Commented out until 1.69
    // Skin color
    appval.nSkinColor              = GetColor(oTemplate, COLOR_CHANNEL_SKIN);
    // Hair color
    appval.nHairColor              = GetColor(oTemplate, COLOR_CHANNEL_HAIR);
    // Tattoo 1 color
    appval.nTat1Color              = GetColor(oTemplate, COLOR_CHANNEL_TATTOO_1);
    // Tattoo 2 color
    appval.nTat2Color              = GetColor(oTemplate, COLOR_CHANNEL_TATTOO_2);
    */


    return appval;
}

void SetAppearanceData(object oTarget, struct appearancevalues appval)
{
//DoDebug("Setting the appearance of " + DebugObject2Str(oTarget) + "to:\n" + DebugAppearancevalues2Str(appval));
	// The appearance type
	SetCreatureAppearanceType(oTarget, appval.nAppearanceType);
	// Body parts - Delayed, since it seems not delaying this makes the body part setting fail, instead resulting in no visible
	// parts. Some interaction with SetCreatureAppearance(), maybe?
	// Applies to NWN1 1.68. Kudos to Primogenitor for originally figuring this out - Ornedan
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_RIGHT_FOOT     , appval.nBodyPart_RightFoot     , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_LEFT_FOOT      , appval.nBodyPart_LeftFoot      , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN     , appval.nBodyPart_RightShin     , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_LEFT_SHIN      , appval.nBodyPart_LeftShin      , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH    , appval.nBodyPart_RightThigh    , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_LEFT_THIGH     , appval.nBodyPart_LeftThight    , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_PELVIS         , appval.nBodyPart_Pelvis        , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_TORSO          , appval.nBodyPart_Torso         , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_BELT           , appval.nBodyPart_Belt          , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_NECK           , appval.nBodyPart_Neck          , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM  , appval.nBodyPart_RightForearm  , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM   , appval.nBodyPart_LeftForearm   , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP    , appval.nBodyPart_RightBicep    , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_LEFT_BICEP     , appval.nBodyPart_LeftBicep     , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_RIGHT_SHOULDER , appval.nBodyPart_RightShoulder , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_LEFT_SHOULDER  , appval.nBodyPart_LeftShoulder  , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND     , appval.nBodyPart_RightHand     , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_LEFT_HAND      , appval.nBodyPart_LeftHand      , oTarget));
	DelayCommand(1.0f, SetCreatureBodyPart(CREATURE_PART_HEAD           , appval.nBodyPart_Head          , oTarget));
	// Wings
	SetCreatureWingType(appval.nWingType, oTarget);
	// Tail
    SetCreatureTailType(appval.nTailType, oTarget);
    // Footstep type
    SetFootstepType(appval.nFootStepType, oTarget);

    /* Portrait stuff */
    // If the portrait ID is not PORTRAIT_INVALID, use it. This will also set the resref
    if(appval.nPortraitID != PORTRAIT_INVALID)
        SetPortraitId(oTarget, appval.nPortraitID);
    // Otherwise, use the portrait resref. This will set portrait ID to PORTRAIT_INVALID
    else
        SetPortraitResRef(oTarget, appval.sPortraitResRef);
        
    //replace with SetGender if 1.69 adds it
    if(GetGender(oTarget) != appval.nGender && appval.nAppearanceType < 7)
    {
        if(GetPrimaryArcaneClass(oTarget) != CLASS_TYPE_INVALID)
            SetPortraitId(oTarget, 1061); //generic wizard port
        else if(GetPrimaryDivineClass(oTarget) != CLASS_TYPE_INVALID)
            SetPortraitId(oTarget, 1033); //generic cleric port
        else
            SetPortraitId(oTarget, 1043); //generic fighter port
    }
    
    /* Commented out until 1.69
    // Skin color
    SetColor(oTarget, COLOR_CHANNEL_SKIN, appval.nSkinColor);
    // Hair color
    SetColor(oTemplate, COLOR_CHANNEL_HAIR, appval.nHairColor);
    // Tattoo 2 color
    SetColor(oTemplate, COLOR_CHANNEL_TATTOO_1, appval.nTat1Color);
    // Tattoo 1 color
    SetColor(oTemplate, COLOR_CHANNEL_TATTOO_2, appval.nTat2Color);
    */
}

struct appearancevalues GetLocalAppearancevalues(object oStore, string sName)
{
    struct appearancevalues appval;
	// The appearance type
    appval.nAppearanceType         = GetPersistantLocalInt(oStore, sName + "nAppearanceType");
    // Body parts
    appval.nBodyPart_RightFoot     = GetPersistantLocalInt(oStore, sName + "nBodyPart_RightFoot");
    appval.nBodyPart_LeftFoot      = GetPersistantLocalInt(oStore, sName + "nBodyPart_LeftFoot");
    appval.nBodyPart_RightShin     = GetPersistantLocalInt(oStore, sName + "nBodyPart_RightShin");
    appval.nBodyPart_LeftShin      = GetPersistantLocalInt(oStore, sName + "nBodyPart_LeftShin");
    appval.nBodyPart_RightThigh    = GetPersistantLocalInt(oStore, sName + "nBodyPart_RightThigh");
    appval.nBodyPart_LeftThight    = GetPersistantLocalInt(oStore, sName + "nBodyPart_LeftThight");
    appval.nBodyPart_Pelvis        = GetPersistantLocalInt(oStore, sName + "nBodyPart_Pelvis");
    appval.nBodyPart_Torso         = GetPersistantLocalInt(oStore, sName + "nBodyPart_Torso");
    appval.nBodyPart_Belt          = GetPersistantLocalInt(oStore, sName + "nBodyPart_Belt");
    appval.nBodyPart_Neck          = GetPersistantLocalInt(oStore, sName + "nBodyPart_Neck");
    appval.nBodyPart_RightForearm  = GetPersistantLocalInt(oStore, sName + "nBodyPart_RightForearm");
    appval.nBodyPart_LeftForearm   = GetPersistantLocalInt(oStore, sName + "nBodyPart_LeftForearm");
    appval.nBodyPart_RightBicep    = GetPersistantLocalInt(oStore, sName + "nBodyPart_RightBicep");
    appval.nBodyPart_LeftBicep     = GetPersistantLocalInt(oStore, sName + "nBodyPart_LeftBicep");
    appval.nBodyPart_RightShoulder = GetPersistantLocalInt(oStore, sName + "nBodyPart_RightShoulder");
    appval.nBodyPart_LeftShoulder  = GetPersistantLocalInt(oStore, sName + "nBodyPart_LeftShoulder");
    appval.nBodyPart_RightHand     = GetPersistantLocalInt(oStore, sName + "nBodyPart_RightHand");
    appval.nBodyPart_LeftHand      = GetPersistantLocalInt(oStore, sName + "nBodyPart_LeftHand");
    appval.nBodyPart_Head          = GetPersistantLocalInt(oStore, sName + "nBodyPart_Head");
    // Wings
    appval.nWingType               = GetPersistantLocalInt(oStore, sName + "nWingType");
    // Tail
    appval.nTailType               = GetPersistantLocalInt(oStore, sName + "nTailType");
    // Portrait ID
    appval.nPortraitID             = GetPersistantLocalInt(oStore, sName + "nPortraitID");
    // Portrait resref
    appval.sPortraitResRef         = GetPersistantLocalString(oStore, sName + "sPortraitResRef");
    // Footstep type
    appval.nFootStepType           = GetPersistantLocalInt(oStore, sName + "nFootStepType");
    // Gender
    appval.nGender                 = GetPersistantLocalInt(oStore, sName + "nGender");
    
    // Skin color
    appval.nSkinColor              = GetPersistantLocalInt(oStore, sName + "nSkinColor");
    // Hair color
    appval.nHairColor              = GetPersistantLocalInt(oStore, sName + "nHairColor");
    // Tattoo 1 color
    appval.nTat1Color              = GetPersistantLocalInt(oStore, sName + "nTat1Color");
    // Tattoo 2 color
    appval.nTat2Color              = GetPersistantLocalInt(oStore, sName + "nTat2Color");


    return appval;
}

void SetLocalAppearancevalues(object oStore, string sName, struct appearancevalues appval)
{
	// The appearance type
    SetPersistantLocalInt(oStore, sName + "nAppearanceType"        , appval.nAppearanceType         );
    // Body parts
    SetPersistantLocalInt(oStore, sName + "nBodyPart_RightFoot"    , appval.nBodyPart_RightFoot     );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_LeftFoot"     , appval.nBodyPart_LeftFoot      );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_RightShin"    , appval.nBodyPart_RightShin     );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_LeftShin"     , appval.nBodyPart_LeftShin      );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_RightThigh"   , appval.nBodyPart_RightThigh    );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_LeftThight"   , appval.nBodyPart_LeftThight    );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_Pelvis"       , appval.nBodyPart_Pelvis        );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_Torso"        , appval.nBodyPart_Torso         );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_Belt"         , appval.nBodyPart_Belt          );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_Neck"         , appval.nBodyPart_Neck          );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_RightForearm" , appval.nBodyPart_RightForearm  );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_LeftForearm"  , appval.nBodyPart_LeftForearm   );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_RightBicep"   , appval.nBodyPart_RightBicep    );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_LeftBicep"    , appval.nBodyPart_LeftBicep     );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_RightShoulder", appval.nBodyPart_RightShoulder );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_LeftShoulder" , appval.nBodyPart_LeftShoulder  );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_RightHand"    , appval.nBodyPart_RightHand     );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_LeftHand"     , appval.nBodyPart_LeftHand      );
    SetPersistantLocalInt(oStore, sName + "nBodyPart_Head"         , appval.nBodyPart_Head          );
    // Wings
    SetPersistantLocalInt(oStore, sName + "nWingType"              , appval.nWingType               );
    // Tail
    SetPersistantLocalInt(oStore, sName + "nTailType"              , appval.nTailType               );
    // Portrait ID
    SetPersistantLocalInt(oStore, sName + "nPortraitID"            , appval.nPortraitID             );
    // Portrait resref
    SetPersistantLocalString(oStore, sName + "sPortraitResRef"     , appval.sPortraitResRef         );
    // Footstep type
    SetPersistantLocalInt(oStore, sName + "nFootStepType"          , appval.nFootStepType           );
    //Gender
    SetPersistantLocalInt(oStore, sName + "nGender"                , appval.nGender                 );
    
    // Skin color
    SetPersistantLocalInt(oStore, sName + "nSkinColor"             , appval.nSkinColor              );
    // Hair color
    SetPersistantLocalInt(oStore, sName + "nHairColor"             , appval.nHairColor              );
    // Tattoo 1 color
    SetPersistantLocalInt(oStore, sName + "nTat1Color"             , appval.nTat1Color              );
    // Tattoo 2 color
    SetPersistantLocalInt(oStore, sName + "nTat2Color"             , appval.nTat2Color              );

}

void DeleteLocalAppearancevalues(object oStore, string sName)
{
	// The appearance type
    DeletePersistantLocalInt(oStore, sName + "nAppearanceType");
    // Body parts
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_RightFoot");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_LeftFoot");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_RightShin");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_LeftShin");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_RightThigh");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_LeftThight");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_Pelvis");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_Torso");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_Belt");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_Neck");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_RightForearm");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_LeftForearm");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_RightBicep");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_LeftBicep");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_RightShoulder");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_LeftShoulder");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_RightHand");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_LeftHand");
    DeletePersistantLocalInt(oStore, sName + "nBodyPart_Head");
    // Wings
    DeletePersistantLocalInt(oStore, sName + "nWingType");
    // Tail
    DeletePersistantLocalInt(oStore, sName + "nTailType");
    // Portrait ID
    DeletePersistantLocalInt(oStore, sName + "nPortraitID");
    // Portrait resref
    DeletePersistantLocalString(oStore, sName + "sPortraitResRef");
    // Footstep type
    DeletePersistantLocalInt(oStore, sName + "nFootStepType");
    // Gender
    DeletePersistantLocalInt(oStore, sName + "nGender");
    // Skin color
    DeletePersistantLocalInt(oStore, sName + "nSkinColor");
    // Hair color
    DeletePersistantLocalInt(oStore, sName + "nHairColor");
    // Tattoo 1 color
    DeletePersistantLocalInt(oStore, sName + "nTat1Color");
    // Tattoo 2 color
    DeletePersistantLocalInt(oStore, sName + "nTat2Color");
}

struct appearancevalues GetPersistantLocalAppearancevalues(object oStore, string sName)
{
    return GetLocalAppearancevalues(oStore, sName);
}

void SetPersistantLocalAppearancevalues(object oStore, string sName, struct appearancevalues appval)
{
    SetLocalAppearancevalues(oStore, sName, appval);
}

void DeletePersistantLocalAppearancevalues(object oStore, string sName)
{
    DeleteLocalAppearancevalues(oStore, sName);
}

void ForceUnshift(object oShifter, int nShiftedNumber)
{
    if(GetPersistantLocalInt(oShifter, "nTimesShifted") == nShiftedNumber)
        UnShift(oShifter);
}

string DebugAppearancevalues2Str(struct appearancevalues appval)
{
    return "Appearance type            = " + IntToString(appval.nAppearanceType) + "\n"
         + "Body part - Right Foot     = " + IntToString(appval.nBodyPart_RightFoot    ) + "\n"
         + "Body part - Left Foot      = " + IntToString(appval.nBodyPart_LeftFoot     ) + "\n"
         + "Body part - Right Shin     = " + IntToString(appval.nBodyPart_RightShin    ) + "\n"
         + "Body part - Left Shin      = " + IntToString(appval.nBodyPart_LeftShin     ) + "\n"
         + "Body part - Right Thigh    = " + IntToString(appval.nBodyPart_RightThigh   ) + "\n"
         + "Body part - Left Thigh     = " + IntToString(appval.nBodyPart_LeftThight   ) + "\n"
         + "Body part - Pelvis         = " + IntToString(appval.nBodyPart_Pelvis       ) + "\n"
         + "Body part - Torso          = " + IntToString(appval.nBodyPart_Torso        ) + "\n"
         + "Body part - Belt           = " + IntToString(appval.nBodyPart_Belt         ) + "\n"
         + "Body part - Neck           = " + IntToString(appval.nBodyPart_Neck         ) + "\n"
         + "Body part - Right Forearm  = " + IntToString(appval.nBodyPart_RightForearm ) + "\n"
         + "Body part - Left Forearm   = " + IntToString(appval.nBodyPart_LeftForearm  ) + "\n"
         + "Body part - Right Bicep    = " + IntToString(appval.nBodyPart_RightBicep   ) + "\n"
         + "Body part - Left Bicep     = " + IntToString(appval.nBodyPart_LeftBicep    ) + "\n"
         + "Body part - Right Shoulder = " + IntToString(appval.nBodyPart_RightShoulder) + "\n"
         + "Body part - Left Shoulder  = " + IntToString(appval.nBodyPart_LeftShoulder ) + "\n"
         + "Body part - Right Hand     = " + IntToString(appval.nBodyPart_RightHand    ) + "\n"
         + "Body part - Left Hand      = " + IntToString(appval.nBodyPart_LeftHand     ) + "\n"
         + "Body part - Head           = " + IntToString(appval.nBodyPart_Head         ) + "\n"
         + "Wings                      = " + IntToString(appval.nWingType) + "\n"
         + "Tail                       = " + IntToString(appval.nTailType) + "\n"
         + "Portrait ID                = " + (appval.nPortraitID == PORTRAIT_INVALID ? "PORTRAIT_INVALID" : IntToString(appval.nPortraitID)) + "\n"
         + "Portrait ResRef            = " + appval.sPortraitResRef + "\n"
         + "Footstep type              = " + IntToString(appval.nFootStepType) + "\n"
         + "Gender                     = " + IntToString(appval.nGender) + "\n"
         + "Skin color                 = " + IntToString(appval.nSkinColor) + "\n"
         + "Hair color                 = " + IntToString(appval.nHairColor) + "\n"
         + "Tattoo 1 color             = " + IntToString(appval.nTat1Color) + "\n"
         + "Tattoo 2 color             = " + IntToString(appval.nTat2Color) + "\n"
         ;
}

int IsPolymorphed(object oPC)
{
    effect eTest = GetFirstEffect(oPC);
    while(GetIsEffectValid(eTest))
    {
        if(GetEffectType(eTest) == EFFECT_TYPE_POLYMORPH)
            return TRUE;
        eTest = GetNextEffect(oPC);
    }
    return FALSE;
}

void HandleTrueShape(object oPC)
{
    if(!GetPersistantLocalInt(oPC, SHIFTER_TRUEAPPEARANCE))
        StoreCurrentAppearanceAsTrueAppearance(oPC, TRUE);

    if(!GetPersistantLocalInt(oPC, SHIFTER_TRUE_RACE))
        StoreCurrentRaceAsTrueRace(oPC);
}

void HandleApplyShiftEffects(object oPC)
{
    if (IsPolymorphed(oPC))
        return;
    DelayCommand(0.0f, _prc_inc_shifting_ApplyEffects(oPC, TRUE));
}

void HandleApplyShiftTemplate(object oPC)
{
    if (IsPolymorphed(oPC))
        return;

    string sResRef;
    int nShifterType;
    int nShapeGeneration;
    object oTemplate;

    if(GetLocalInt(oPC, SHIFTER_SHIFT_MUTEX))
    {
        //If shifting, the following is already being handled
        //by the shifting code so don't do it again here.
        return;
    }

    sResRef = GetPersistantLocalString(oPC, "PRC_SHIFTING_TEMPLATE_RESREF");
    if(sResRef != "")
    {
        oTemplate = _prc_inc_load_template_from_resref(sResRef, GetHitDice(oPC));
        if(GetIsObjectValid(oTemplate))
        {
            nShifterType = GetPersistantLocalInt(oPC, "PRC_SHIFTING_SHIFTER_TYPE");
            nShapeGeneration = GetLocalInt(oPC, PRC_Shifter_ShapeGeneration);
            if (DEBUG_APPLY_PROPERTIES)
                DoDebug("HandleApplyShiftTemplate, Shifter Index: " + IntToString(nShapeGeneration));
            DelayCommand(0.0f, _prc_inc_shifting_ApplyTemplate(oPC, nShapeGeneration, nShifterType, oTemplate, FALSE, GetPCSkin(oPC)));
        }
    }
}

int PnPShifterFeats()
{
    if(GetPRCSwitch(PRC_NWNXEE_ENABLED))
    {
        //If any stats have been changed by NWNX, this could qualify the PC for feats they should
        //not actually qualify for, so force unshifting before levelling up.
        if(GetPersistantLocalInt(OBJECT_SELF, "Shifting_NWNXSTRAdjust")
        || GetPersistantLocalInt(OBJECT_SELF, "Shifting_NWNXDEXAdjust")
        || GetPersistantLocalInt(OBJECT_SELF, "Shifting_NWNXCONAdjust"))
        {
            FloatingTextStringOnCreature("You must unshift before levelling up.", OBJECT_SELF, FALSE); //TODO: TLK entry
            return TRUE;
        }
    }
    return FALSE;
}

// Test main
// void main(){}
