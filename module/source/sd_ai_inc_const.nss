// sd_ai_inc_const.nss
// Universal AI Framework - Constants Include

// Creature type categories
const int SD_AI_TYPE_STANDARD   = 0;
const int SD_AI_TYPE_BOSS       = 1;
const int SD_AI_TYPE_STATIC     = 2;
const int SD_AI_TYPE_SHARD      = 3;
const int SD_AI_TYPE_EVIL_ADJ   = 4;
const int SD_AI_TYPE_RESTLESS   = 5;
const int SD_AI_TYPE_DEMILICH   = 6;
const int SD_AI_TYPE_VEGEMOUNT  = 7;
const int SD_AI_TYPE_WRGMOUNT   = 8;
const int SD_AI_TYPE_GOBRIDER   = 9;
const int SD_AI_TYPE_VEGRIDER   = 10;
const int SD_AI_TYPE_NO_DROP    = 11;
const int SD_AI_TYPE_SKINNABLE  = 12;
const int SD_AI_TYPE_X2_BASIC   = 13;
const int SD_AI_TYPE_X2_CUSTOM  = 14;
const int SD_AI_TYPE_NPC_DEATH  = 15;
const int SD_AI_TYPE_PESWIQ     = 16;
const int SD_AI_TYPE_SE_OD_EXAMPLE = 17;
const int SD_AI_TYPE_CNR_BIRD   = 18;
const int SD_AI_TYPE_CNR_MOB    = 19;

// Loot system constants
const int SD_AI_LOOT_FULL    = 0;  // craft_drop_items + prc_pwondeath
const int SD_AI_LOOT_NONE    = 1;  // no loot
const int SD_AI_LOOT_GOLD    = 2;  // gold only
const int SD_AI_LOOT_SKIN    = 3;  // cnr skin corpse
const int SD_AI_LOOT_BIRD    = 4;  // cnr bird feather
const int SD_AI_LOOT_MOB     = 5;  // cnr mob drop
const int SD_AI_LOOT_X2_BARE = 6;  // x2_def_ondeath style (no prc_pwondeath)

// Behavior flags (bitmask)
const int SD_AI_BF_BOSS_ANNOUNCE  = 1;
const int SD_AI_BF_SHARD_VFX      = 2;
const int SD_AI_BF_EVIL_ALIGN_10  = 4;
const int SD_AI_BF_NO_RESPAWN     = 8;
const int SD_AI_BF_RESPAWN_RESTLESS = 16;
const int SD_AI_BF_SPAWN_RIDER    = 32;
const int SD_AI_BF_SPAWN_MOUNT    = 64;

// Local variable names
const string SD_AI_VAR_TYPE         = "SD_AI_TYPE";
const string SD_AI_VAR_LOOT         = "SD_AI_LOOT";
const string SD_AI_VAR_BEHAVIOR     = "SD_AI_BEHAVIOR";
const string SD_AI_VAR_LEGACY       = "SD_AI_LEGACY";
