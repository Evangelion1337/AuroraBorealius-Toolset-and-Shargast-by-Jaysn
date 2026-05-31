// sd_ai_inc_spawn.nss
// Universal AI Framework - Spawn Subsystem

#include "sd_ai_inc_const"
#include "x0_i0_treasure"
#include "nw_i0_generic"

// Set up the creature's AI configuration locals based on auto-detection
void SD_Spawn_DetectAndConfigure()
{
    int nType = SD_AI_TYPE_STANDARD;
    int nLoot = SD_AI_LOOT_FULL;
    int nBehavior = 0;

    // Check BOSS local or tag
    if (GetLocalInt(OBJECT_SELF, "BOSS") == 1 || FindSubString(GetTag(OBJECT_SELF), "BOSS") > -1)
    {
        nType = SD_AI_TYPE_BOSS;
        nBehavior |= SD_AI_BF_BOSS_ANNOUNCE;
    }

    // Check for NSP tag (no respawn)
    if (FindSubString(GetTag(OBJECT_SELF), "NSP") > -1)
    {
        nBehavior |= SD_AI_BF_NO_RESPAWN;
    }

    SetLocalInt(OBJECT_SELF, SD_AI_VAR_TYPE, nType);
    SetLocalInt(OBJECT_SELF, SD_AI_VAR_LOOT, nLoot);
    SetLocalInt(OBJECT_SELF, SD_AI_VAR_BEHAVIOR, nBehavior);
}

// Configure spawn-in conditions from creature flags
void SD_Spawn_ConfigureConditions()
{
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_STEALTH) == TRUE)
        SetSpawnInCondition(NW_FLAG_STEALTH);

    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_SEARCH) == TRUE)
        SetSpawnInCondition(NW_FLAG_SEARCH);

    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_AMBIENT_IMMOBILE) == TRUE)
        SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);

    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_AMBIENT) == TRUE)
        SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
}

// Standard OnSpawn initialization
void SD_Spawn_DoStandardSpawn()
{
    SetListeningPatterns();
    WalkWayPoints();

    if ((GetLocalInt(GetModule(), "X2_L_NOTREASURE") == FALSE) &&
        (GetLocalInt(OBJECT_SELF, "X2_L_NOTREASURE") == FALSE))
    {
        CTG_GenerateNPCTreasure(TREASURE_TYPE_MONSTER, OBJECT_SELF);
    }

    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL) == TRUE)
    {
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        eConceal = ExtraordinaryEffect(eConceal);
        effect eGhost = EffectCutsceneGhost();
        eGhost = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, OBJECT_SELF);
    }

    SetListenPattern(OBJECT_SELF, "**", 20600);
    SetLocalInt(OBJECT_SELF, "hls_Listening", 1);
    SetListening(OBJECT_SELF, TRUE);
}

// Master spawn dispatch
void SD_Spawn_Dispatch()
{
    SD_Spawn_DetectAndConfigure();
    SD_Spawn_ConfigureConditions();
    SD_Spawn_DoStandardSpawn();
}
