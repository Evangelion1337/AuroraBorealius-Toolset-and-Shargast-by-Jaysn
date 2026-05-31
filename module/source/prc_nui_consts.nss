//::///////////////////////////////////////////////
//:: NUI Constants
//:: prc_nui_consts
//:://////////////////////////////////////////////
/*
    This file holds all the constants used by the various PRC NUI scripts.
*/
//:://////////////////////////////////////////////
//:: Created By: Rakiov
//:: Created On: 24.05.2005
//:://////////////////////////////////////////////

const int NUI_PAYLOAD_BUTTON_LEFT_CLICK = 0;
const int NUI_PAYLOAD_BUTTON_MIDDLE_CLICK = 1;
const int NUI_PAYLOAD_BUTTON_RIGHT_CLICK = 2;


//////////////////////////////////////////////////
//                                              //
// NUI Spellbook                                //
//                                              //
//////////////////////////////////////////////////

// This is the NUI Spellbook window ID
const string PRC_SPELLBOOK_NUI_WINDOW_ID = "prcSpellbookNui";

// This is the base Id for the Class buttons in the NUI Spellbook, the ID will
// have the ClassID attached to it (i.e. spellbookClassButton_123)
const string PRC_SPELLBOOK_NUI_CLASS_BUTTON_BASEID = "spellbookClassButton_";

// This is the base Id for the Spell Circle buttons in the NUI Spellbook, the ID will
// have the Circle attached to it (i.e. spellbookCircleButton__6)
const string PRC_SPELLBOOK_NUI_CIRCLE_BUTTON_BASEID = "spellbookCircleButton_";

// This is the base Id for the Spell Buttons in the NUI Spellbook, the ID will
// have the SpellbookId (the row of the class's spell's 2da or equivalent)
// attached to it (i.e. spellbookSpellButton_6)
const string PRC_SPELLBOOK_NUI_SPELL_BUTTON_BASEID = "spellbookSpellButton_";

// This is the base Id for the Meta Feat buttons in the NUI Spellbook, the ID will
// have the FeatID attached to it (i.e. spellbookMetaButton_12345)
const string PRC_SPELLBOOK_NUI_META_BUTTON_BASEID = "spellbookMetaButton_";

// This is the selected ClassID var used to store what class was selected to the Player
// locally
const string PRC_SPELLBOOK_SELECTED_CLASSID_VAR = "prcSpellbookSelectedClassID";

// This is the selected Circle var used to store what spell circle was selected
// to the Player locally
const string PRC_SPELLBOOK_SELECTED_CIRCLE_VAR = "prcSpellbookSelectedCircle";

// This is the Spellbook NUI geomeotry var, used to allow the location and sizing
// of the NUI to be remembered if it is ever rerendered.
const string PRC_SPELLBOOK_NUI_GEOMETRY_VAR = "sbNuiGeometry";

// This is the Selected SpellID Var, used to tell the OnTarget script what spell
// we are using after manual targetting
const string NUI_SPELLBOOK_SELECTED_SPELLID_VAR = "NUI_Spellbook_SpellId";

// This is the Selected FeatID Var, used to tell the OnTarget script what feat
// we are using after manual targetting
const string NUI_SPELLBOOK_SELECTED_FEATID_VAR = "NUI_Spellbook_FeatID";

// This is the Selected SubSpellID Var, used in conjuncture with the Selected FeatID
// to allow radial spells to work (it needs the master spell's featID and the sub spell's
// SpellID for it to work.
const string NUI_SPELLBOOK_SELECTED_SUBSPELL_SPELLID_VAR = "NUI_Spellbook_SubSpellID";

// This is the OnTarget action var saved to the player locally to say if we are
// using the NUI Spellbook spell or not.
const string NUI_SPELLBOOK_ON_TARGET_ACTION_VAR = "ONPLAYERTARGET_ACTION";

// This is a Boolean to tell the target script if the selected feat is a persoanl feat
// and can only be used on the executing object.
const string NUI_SPELLBOOK_ON_TARGET_IS_PERSONAL_FEAT = "NUI_Spellbook_IsPersonalFeat";

const string NUI_SPELL_DESCRIPTION_WINDOW_ID = "NUI_Spell_Description";
const string NUI_SPELL_DESCRIPTION_OK_BUTTON = "NUIDescriptionOKButton";

// This is the limit of how many spell buttons we can have in a row before we
// need to start a new row on the NUI Spellbook.
const int NUI_SPELLBOOK_SPELL_BUTTON_LENGTH = 9;

const string NUI_SPELLBOOK_BINDER_DICTIONARY_CACHE_VAR = "NUI_Spellbook_GetBinderSpellToFeatDictionaryCache";
const string NUI_SPELLBOOK_CLASS_STANCES_CACHE_BASE_VAR = "NUI_Spellbook_GetToBStanceSpellListCache_";
const string NUI_SPELLBOOK_CLASS_SHAPES_CACHE_BASE_VAR = "NUI_Spellbook_GetInvokerShapeSpellListCache_";
const string NUI_SPELLBOOK_CLASS_ESSENCE_CACHE_BASE_VAR = "NUISpellbookClassEssence_";



//////////////////////////////////////////////////
//                                              //
// NUI Power Attack                             //
//                                              //
//////////////////////////////////////////////////

// The Window ID for the Power Attack NUI
const string NUI_PRC_POWER_ATTACK_WINDOW = "nui_prc_power_attack_window";

// LocalVar for the geometry of the Power Attack NUI window
const string NUI_PRC_PA_GEOMETRY_VAR = "paNuiGeometry";

// Event For Left "-" button of the Power Attack NUI
const string NUI_PRC_PA_LEFT_BUTTON_EVENT = "nui_prc_pa_left_button_event";
// Event For Right "+" Button of the Power Attack NUI
const string NUI_PRC_PA_RIGHT_BUTTON_EVENT = "nui_prc_pa_right_button_event";

// Bind for Text of the Power Attack NUI saying what the current Power Attack level is
const string NUI_PRC_PA_TEXT_BIND = "nui_prc_pa_text_bind";
// Left Button Enabled Bind for Power Attack NUI
const string NUI_PRC_PA_LEFT_BUTTON_ENABLED_BIND = "leftButtonEnabled";
// Right Button Enabled Bind for Power Attack NUI
const string NUI_PRC_PA_RIGHT_BUTTON_ENABLED_BIND = "rightButtonEnabled";

//////////////////////////////////////////////////
//                                              //
// NUI Level Up                                 //
//                                              //
//////////////////////////////////////////////////

const string NUI_LEVEL_UP_WINDOW_ID = "prcLevelUpNui";

const string NUI_LEVEL_UP_SPELL_CIRCLE_BUTTON_BASEID = "NuiLevelUpCircleButton_";
const string NUI_LEVEL_UP_SPELL_BUTTON_BASEID = "NuiLevelUpSpellButton_";
const string NUI_LEVEL_UP_SPELL_DISABLED_BUTTON_BASEID = "NuiLevelUpDisabledSpellButton_";
const string NUI_LEVEL_UP_SPELL_CHOSEN_BUTTON_BASEID = "NuiLevelUpChosenSpellButton_";
const string NUI_LEVEL_UP_SPELL_CHOSEN_DISABLED_BUTTON_BASEID = "NuiLevelUpDisabledChosenSpellButton_";
const string NUI_LEVEL_UP_DONE_BUTTON = "NuiLevelUpDoneButton";
const string NUI_LEVEL_UP_RESET_BUTTON = "NuiLevelUpResetButton";

const string NUI_LEVEL_UP_SELECTED_CLASS_VAR = "NUILevelUpSelectedClass";
const string NUI_LEVEL_UP_SELECTED_CIRCLE_VAR = "NUILevelUpSelectedCircle";
const string NUI_LEVEL_UP_KNOWN_SPELLS_VAR = "NUILevelUpKnownSpells";
const string NUI_LEVEL_UP_CHOSEN_SPELLS_VAR = "NUILevelUpChosenSpells";
const string NUI_LEVEL_UP_EXPANDED_KNOW_LIST_VAR = "NUILevelUpExpKnowList";
const string NUI_LEVEL_UP_POWER_LIST_VAR = "NUILevelUpPowerList";
const string NUI_LEVEL_UP_DISCIPLINE_INFO_VAR = "GetDisciplineInfoObjectCache_";
const string NUI_LEVEL_UP_SPELLID_LIST_VAR = "NUILevelUpSpellIDList_";
const string NUI_LEVEL_UP_REMAINING_CHOICES_CACHE_VAR = "NUIRemainingChoicesCache";
const string NUI_LEVEL_UP_RELEARN_LIST_VAR = "NUILevelUpRelearnList";
const string NUI_LEVEL_UP_ARCHIVIST_NEW_SPELLS_LIST_VAR = "NUILevelUpArchivistNewSpellsList";

const string NUI_LEVEL_UP_EXPANDED_CHOICES_VAR = "NUIExpandedChoices";
const string NUI_LEVEL_UP_EPIC_EXPANDED_CHOICES_VAR = "NUIEpicExpandedChoices";

const int NUI_LEVEL_UP_MANEUVER_PREREQ_LIMIT = 6;

const string NUI_LEVEL_UP_MANEUVER_TOTAL = "ManeuverTotal";
const string NUI_LEVEL_UP_STANCE_TOTAL = "StanceTotal";

const string NUI_LEVEL_UP_SPELLBOOK_OBJECT_CACHE_VAR = "GetSpellListObjectCache_";
const string NUI_LEVEL_UP_KNOWN_INVOCATIONS_CACHE_VAR = "GetInvokerKnownListObjectCache_";

const string NUI_SPELL_DESCRIPTION_FEATID_VAR = "NUISpellDescriptionFeatID";
const string NUI_SPELL_DESCRIPTION_CLASSID_VAR = "NUISpellDescriptionClassID";
const string NUI_SPELL_DESCRIPTION_SPELLID_VAR = "NUISpellDescriptionSpellID";
const string NUI_SPELL_DESCRIPTION_REAL_SPELLID_VAR = "NUISpellDescriptionRealSpellID";


//////////////////////////////////////////////////
//                                              //
// Spell Duration NUI                           //
//                                              //
//////////////////////////////////////////////////

const string DURATION_NUI_WINDOW_ID = "DurationNUI";
const string NUI_DURATION_MANUALLY_OPENED_PARAM = "DurationNUIManuallyOpenedParam";
const string NUI_DURATION_NO_LOOP_PARAM = "DurationNUINoLoopParam";
const string NUI_DURATION_TRACKED_SPELLS = "durationNUI_trackedSpellList";
const string NUI_SPELL_DURATION_BASE_BIND = "durationNUI_durationSpellId";
const string NUI_SPELL_DURATION_SPELLID_BASE_CANCEL_BUTTON = "NuiDurationCancelButtonSpellID";
