////////////////////////////////////
//
//	Global Constants for
//			Psionics Functions
//
///////////////////////////////////



const string PSIONIC_FOCUS = "PRC_PsionicFocus";

const string PRC_WILD_SURGE  = "PRC_WildSurge_Level";
const string PRC_OVERCHANNEL = "PRC_Overchannel_Level";

const string POWER_POINT_VARNAME = "PRC_PowerPoints";



/// Special power lists. Powers gained via Expanded Knowledge, Psychic Chirurgery and similar sources
const int POWER_LIST_EXP_KNOWLEDGE      = -1;
const int POWER_LIST_EPIC_EXP_KNOWLEDGE = -2;
const int POWER_LIST_MISC               = -3;

const string _POWER_LIST_NAME_BASE     = "PRC_PsionicsPowerList_";
const string _POWER_LIST_TOTAL_KNOWN   = "_TotalKnown";
const string _POWER_LIST_MODIFIER      = "_KnownModifier";
const string _POWER_LIST_MISC_ARRAY    = "_PowersKnownMiscArray";
const string _POWER_LIST_LEVEL_ARRAY   = "_PowersKnownLevelArray_";
const string _POWER_LIST_GENERAL_ARRAY = "_PowersKnownGeneralArray";

/////////////////////////////////////////////
// Manifest

const string PRC_MANIFESTING_CLASS        = "PRC_CurrentManifest_ManifestingClass";
const string PRC_POWER_LEVEL              = "PRC_CurrentManifest_PowerLevel";
const string PRC_IS_PSILIKE               = "PRC_CurrentManifest_IsPsiLikeAbility";
const string PRC_DEBUG_IGNORE_CONSTRAINTS = "PRC_Debug_Ignore_Constraints";

/**
 * The variable in which the manifestation token is stored. If no token exists,
 * the variable is set to point at the manifester itself. That way OBJECT_INVALID
 * means the variable is unitialised.
 */
const string PRC_MANIFESTATION_TOKEN_VAR  = "PRC_ManifestationToken";
const string PRC_MANIFESTATION_TOKEN_NAME = "PRC_MANIFTOKEN";
const float PRC_MANIFESTATION_HB_DELAY    = 0.5f;

//
/////////////////////////////////////////////

/////////////////////////////////////////////
// Metapsi

/// No metapsionics
const int METAPSIONIC_NONE          = 0x0;
/// Chain Power
const int METAPSIONIC_CHAIN         = 0x2;
/// Empower Power
const int METAPSIONIC_EMPOWER       = 0x4;
/// Extend Power
const int METAPSIONIC_EXTEND        = 0x8;
/// Maximize Power
const int METAPSIONIC_MAXIMIZE      = 0x10;
/// Split Psionic Ray
const int METAPSIONIC_SPLIT         = 0x20;
/// Twin Power
const int METAPSIONIC_TWIN          = 0x40;
/// Widen Power
const int METAPSIONIC_WIDEN         = 0x80;
/// Quicken Power
const int METAPSIONIC_QUICKEN       = 0x100;

/// How much PP Chain Power costs to use
const int METAPSIONIC_CHAIN_COST    = 6;
/// How much PP Empower Power costs to use
const int METAPSIONIC_EMPOWER_COST  = 2;
/// How much PP Extend Power costs to use
const int METAPSIONIC_EXTEND_COST   = 2;
/// How much PP Maximize Power costs to use
const int METAPSIONIC_MAXIMIZE_COST = 4;
/// How much PP Split Psionic Ray costs to use
const int METAPSIONIC_SPLIT_COST    = 2;
/// How much PP Twin Power costs to use
const int METAPSIONIC_TWIN_COST     = 6;
/// How much PP Widen Power costs to use
const int METAPSIONIC_WIDEN_COST    = 4;
/// How much PP Quicken Power costs to use
const int METAPSIONIC_QUICKEN_COST  = 6;

/// Internal constant. Value is equal to the lowest metapsionic constant. Used when looping over metapsionic flag variables
const int METAPSIONIC_MIN           = 0x2;
/// Internal constant. Value is equal to the highest metapsionic constant. Used when looping over metapsionic flag variables
const int METAPSIONIC_MAX           = 0x100;

/// Chain Power variable name
const string METAPSIONIC_CHAIN_VAR     = "PRC_PsiMeta_Chain";
/// Empower Power variable name
const string METAPSIONIC_EMPOWER_VAR   = "PRC_PsiMeta_Empower";
/// Extend Power variable name
const string METAPSIONIC_EXTEND_VAR    = "PRC_PsiMeta_Extend";
/// Maximize Power variable name
const string METAPSIONIC_MAXIMIZE_VAR  = "PRC_PsiMeta_Maximize";
/// Split Psionic Ray variable name
const string METAPSIONIC_SPLIT_VAR     = "PRC_PsiMeta_Split";
/// Twin Power variable name
const string METAPSIONIC_TWIN_VAR      = "PRC_PsiMeta_Twin";
/// Widen Power variable name
const string METAPSIONIC_WIDEN_VAR     = "PRC_PsiMeta_Widen";
/// Quicken Power variable name
const string METAPSIONIC_QUICKEN_VAR   = "PRC_PsiMeta_Quicken";

/// The name of the array targets returned by EvaluateChainPower will be stored in
const string PRC_CHAIN_POWER_ARRAY  = "PRC_ChainPowerTargets";

/// The name of a marker variable that tells that the power being manifested had Quicken Power used on it
const string PRC_POWER_IS_QUICKENED = "PRC_PowerIsQuickened";

//
/////////////////////////////////////////////