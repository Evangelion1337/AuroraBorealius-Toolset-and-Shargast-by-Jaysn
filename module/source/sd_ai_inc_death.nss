// sd_ai_inc_death.nss
// Universal AI Framework - Death Subsystem
// All existing death patterns extracted into dispatchable functions.

#include "sd_ai_inc_const"
#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "se_respawn_inc"
#include "zep_inc_monster"
#include "cnr_config_inc"

// Base death routine shared by bosskill, staticspawn, shardrecovery,
// pc_eviladjust, x2_def_ondeath, and standard patterns.
void SD_Death_DoBase()
{
    ExecuteScript("sf_xp", OBJECT_SELF);

    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();

    if (nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }

    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    if (GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }
}

// craft_drop_items + respawn check
void SD_Death_DoLootAndRespawn()
{
    object oKiller = GetLastKiller();
    craft_drop_items(oKiller);

    if (FindSubString(GetTag(OBJECT_SELF), "NSP") > -1)
        return;

    SE_DoCreatureRespawn();
}

// Send prc hooks
void SD_Death_DoPRCDeaths()
{
    ExecuteScript("prc_npc_death", OBJECT_SELF);
    ExecuteScript("prc_pwondeath", OBJECT_SELF);
}

// Full standard death (used by bosskill, staticspawn, shardrecovery bases)
void SD_Death_DoStandard()
{
    SD_Death_DoBase();
    SD_Death_DoLootAndRespawn();
}

// Boss kill announcement
void SD_Death_DoBossAnnounce()
{
    object oKiller = GetLastKiller();
    if (!GetIsPC(oKiller)) return;

    SpeakString(GetName(OBJECT_SELF) + " was killed by " + GetName(oKiller) +
                " in " + GetName(GetArea(OBJECT_SELF)), TALKVOLUME_SHOUT);
}

// Shard recovery VFX and announcement
void SD_Death_DoShardVFX()
{
    object oKiller = GetLastKiller();
    if (!GetIsPC(oKiller)) return;

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SCREEN_SHAKE), oKiller);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DESTRUCTION), OBJECT_SELF);
    SpeakString(GetName(OBJECT_SELF) + " was killed and a Zethnite shard was recovered by " + GetName(oKiller) +
                " in " + GetName(GetArea(OBJECT_SELF)), TALKVOLUME_SHOUT);
}

// Shard recovery VFX v1 (shardrecovery1 style - includes broadcast)
void SD_Death_DoShardVFX1()
{
    object oPC = GetLastKiller();
    while (GetIsObjectValid(GetMaster(oPC)))
        oPC = GetMaster(oPC);

    if (!GetIsPC(oPC)) return;

    object oTarget = OBJECT_SELF;
    int nInt = GetObjectType(oTarget);

    if (nInt != OBJECT_TYPE_WAYPOINT)
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SCREEN_SHAKE), oTarget);
    else
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SCREEN_SHAKE), GetLocation(oTarget));

    nInt = GetObjectType(oTarget);
    if (nInt != OBJECT_TYPE_WAYPOINT)
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DESTRUCTION), oTarget);
    else
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DESTRUCTION), GetLocation(oTarget));
}

// Broadcast death message (shardrecovery1 + bosskill)
void SD_Death_DoBroadcast()
{
    object oBoss = OBJECT_SELF;
    object oPC = GetLastHostileActor(oBoss);
    object oArea = GetArea(oBoss);
    string sBoss = GetName(oBoss);
    string sPC = GetName(oPC);
    string sArea = GetName(oArea);
    object oPlayer = GetFirstPC();

    if (GetIsDead(oBoss))
    {
        while (oPlayer != OBJECT_INVALID)
        {
            string sMessage = sBoss + " was killed by " + sPC + " in " + sArea;
            SpeakString(sMessage, TALKVOLUME_SHOUT);
            oPlayer = GetNextPC();
        }
    }
}

// Evil alignment adjustment (-10)
void SD_Death_DoEvilAdjust10()
{
    object oPC = GetLastKiller();
    while (GetIsObjectValid(GetMaster(oPC)))
        oPC = GetMaster(oPC);

    if (!GetIsPC(oPC)) return;
    AdjustAlignment(oPC, ALIGNMENT_EVIL, 10);
}

// Restless dead random respawn
void SD_Death_DoRestlessRespawn()
{
    int nRandomChance = Random(100);
    if (nRandomChance < ZEP_RESTLESS_DEAD_RESPAWN_CHANCE)
    {
        CreateObject(OBJECT_TYPE_PLACEABLE, "zep_restded_resp", GetLocation(OBJECT_SELF));
    }
}

// Demilich placeable spawn
void SD_Death_DoDemilich()
{
    location lLoc = GetLocation(GetObjectByTag("demi_lich_01"));
    CreateObject(OBJECT_TYPE_PLACEABLE, "demi_lich_skull", lLoc);
    CreateObject(OBJECT_TYPE_PLACEABLE, "demi_lich_target", lLoc);
}

// Vegepygmy mount death - spawn rider
void SD_Death_DoSpawnVegeRider()
{
    vector vPos = GetPosition(OBJECT_SELF);
    float fAngle = GetFacing(OBJECT_SELF);
    vector vChange;
    vChange.x = cos(fAngle) * 1.0;
    location lSpawn = Location(GetArea(OBJECT_SELF), vPos + vChange, fAngle);

    effect eKnockdown = ExtraordinaryEffect(EffectKnockdown());
    object oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "zep_vegepygmy", lSpawn, FALSE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oSpawn, 2.0);
}

// Worg mount death - spawn goblin rider
void SD_Death_DoSpawnGoblinRider()
{
    vector vPos = GetPosition(OBJECT_SELF);
    float fAngle = GetFacing(OBJECT_SELF);
    vector vChange;
    vChange.x = cos(fAngle) * 1.0;
    location lSpawn = Location(GetArea(OBJECT_SELF), vPos + vChange, fAngle);

    effect eKnockdown = ExtraordinaryEffect(EffectKnockdown());
    object oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lSpawn, FALSE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oSpawn, 2.0);
}

// Goblin rider death - spawn worg
void SD_Death_DoSpawnWorg()
{
    location lLoc = GetLocation(OBJECT_SELF);
    effect eKnockdown = ExtraordinaryEffect(EffectKnockdown());
    object oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "nw_worg", lLoc, FALSE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oSpawn, 2.0);
}

// Vegepygmy rider death - spawn thorny
void SD_Death_DoSpawnThorny()
{
    location lLoc = GetLocation(OBJECT_SELF);
    effect eKnockdown = ExtraordinaryEffect(EffectKnockdown());
    object oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "zep_thorny", lLoc, FALSE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oSpawn, 2.0);
}

// No-drop death (gold only)
void SD_Death_DoGoldDrop()
{
    object oKiller = GetLastKiller();
    int iFACTOR = 50;
    int iLvl = GetLevelByPosition(1) + GetLevelByPosition(2) + GetLevelByPosition(3);
    int iCR = FloatToInt(GetChallengeRating(OBJECT_SELF));
    int iGold = FloatToInt((IntToFloat(iCR) / IntToFloat(iLvl)) * iFACTOR);

    if (iGold > 150) iGold = 150;
    GiveGoldToCreature(oKiller, iGold);
    FloatingTextStringOnCreature("Monster death gives goldpieces: " + IntToString(iGold), oKiller);
}

// CNR corpse fade helper
void SD_Death_FadeCorpse()
{
    object oBones = GetLocalObject(OBJECT_SELF, "CnrCorpseBones");
    if (GetIsObjectValid(oBones))
    {
        DeleteLocalObject(OBJECT_SELF, "CnrCorpseBones");
        DestroyObject(oBones);
    }
    DestroyObject(OBJECT_SELF);
}

// CNR bird feather drop
void SD_Death_DoBirdDrop()
{
    location locDeath = GetLocation(OBJECT_SELF);
    string sBirdTag = GetTag(OBJECT_SELF);
    string sFeatherTag = GetLocalString(GetModule(), sBirdTag + "_FeatherTag");
    CreateObject(OBJECT_TYPE_ITEM, sFeatherTag, locDeath, FALSE);
}

// CNR mob item drop
void SD_Death_DoMobDrop()
{
    location locDeath = GetLocation(OBJECT_SELF);
    string sMobTag = GetTag(OBJECT_SELF);
    string sDropTag = GetLocalString(GetModule(), sMobTag + "_DropTag");
    CreateObject(OBJECT_TYPE_ITEM, sDropTag, locDeath, FALSE);
}

// CNR skinnable animal death
void SD_Death_DoSkinCorpse()
{
    ExecuteScript("nw_c2_default7", OBJECT_SELF);

    location locDeath = GetLocation(OBJECT_SELF);
    object oCorpse = CreateObject(OBJECT_TYPE_PLACEABLE, "cnrcorpseskin", locDeath, FALSE);
    object oBones = CreateObject(OBJECT_TYPE_PLACEABLE, "cnrcorpsebones", locDeath, FALSE);
    SetLocalObject(oCorpse, "CnrCorpseBones", oBones);
    SetLocalString(oCorpse, "CnrCorpseType", GetTag(OBJECT_SELF));

    AssignCommand(oCorpse, DelayCommand(CNR_FLOAT_SKINNABLE_CORPSE_FADE_TIME_SECS, SD_Death_FadeCorpse()));
}

// VFX implosion only (peswiq)
void SD_Death_DoImplosionVFX()
{
    object oPC = GetLastKiller();
    if (!GetIsPC(oPC)) return;

    object oTarget = OBJECT_SELF;
    int nInt = GetObjectType(oTarget);

    if (nInt != OBJECT_TYPE_WAYPOINT)
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_IMPLOSION), oTarget);
    else
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_IMPLOSION), GetLocation(oTarget));
}

// peswiq-style VFX with broadcast
void SD_Death_DoImplosionAndBroadcast()
{
    SD_Death_DoImplosionVFX();

    object oBoss = OBJECT_SELF;
    object oPC = GetLastHostileActor(oBoss);
    object oArea = GetArea(oBoss);
    string sMessage = GetName(oBoss) + " was killed by " + GetName(oPC) + " in " + GetName(oArea);
    SpeakString(sMessage, TALKVOLUME_SHOUT);
}

// Master dispatch - determines creature type and runs the correct death pattern
void SD_Death_Dispatch()
{
    int nType = GetLocalInt(OBJECT_SELF, SD_AI_VAR_TYPE);
    int nLoot = GetLocalInt(OBJECT_SELF, SD_AI_VAR_LOOT);
    int nBehavior = GetLocalInt(OBJECT_SELF, SD_AI_VAR_BEHAVIOR);
    string sLegacy = GetLocalString(OBJECT_SELF, SD_AI_VAR_LEGACY);

    // If legacy script is set, dispatch based on it
    if (sLegacy != "")
    {
        if (sLegacy == "bosskill" || sLegacy == "shardrecovery" || sLegacy == "staticspawn")
        {
            nType = SD_AI_TYPE_STANDARD;
            if (sLegacy == "bosskill") nBehavior |= SD_AI_BF_BOSS_ANNOUNCE;
            if (sLegacy == "shardrecovery") nBehavior |= SD_AI_BF_SHARD_VFX;
        }
        else if (sLegacy == "shardrecovery1")
        {
            nType = SD_AI_TYPE_SHARD;
        }
        else if (sLegacy == "pc_eviladjust")
        {
            nType = SD_AI_TYPE_EVIL_ADJ;
        }
        else if (sLegacy == "zep_restded_deth")
        {
            nType = SD_AI_TYPE_RESTLESS;
        }
        else if (sLegacy == "zep_demi_ondeath")
        {
            nType = SD_AI_TYPE_DEMILICH;
        }
        else if (sLegacy == "zep_vegemount_d")
        {
            nType = SD_AI_TYPE_VEGEMOUNT;
        }
        else if (sLegacy == "zep_wrgmount_die")
        {
            nType = SD_AI_TYPE_WRGMOUNT;
        }
        else if (sLegacy == "zep_gobrider_die")
        {
            nType = SD_AI_TYPE_GOBRIDER;
        }
        else if (sLegacy == "zep_vegrider_die")
        {
            nType = SD_AI_TYPE_VEGRIDER;
        }
        else if (sLegacy == "nodropscript")
        {
            nType = SD_AI_TYPE_NO_DROP;
        }
        else if (sLegacy == "cnr_skin_ondeath")
        {
            nType = SD_AI_TYPE_SKINNABLE;
        }
        else if (sLegacy == "x2_def_ondeath")
        {
            nType = SD_AI_TYPE_X2_BASIC;
        }
        else if (sLegacy == "npc_death")
        {
            nType = SD_AI_TYPE_NPC_DEATH;
        }
        else if (sLegacy == "peswiq")
        {
            nType = SD_AI_TYPE_PESWIQ;
        }
        else if (sLegacy == "cnr_bird_ondeath")
        {
            nType = SD_AI_TYPE_CNR_BIRD;
        }
        else if (sLegacy == "cnr_mob_ondeath")
        {
            nType = SD_AI_TYPE_CNR_MOB;
        }
    }

    // Branch on creature type
    switch (nType)
    {
        case SD_AI_TYPE_STANDARD:
        {
            SD_Death_DoBase();
            SD_Death_DoLootAndRespawn();
            if (nBehavior & SD_AI_BF_BOSS_ANNOUNCE) SD_Death_DoBossAnnounce();
            if (nBehavior & SD_AI_BF_SHARD_VFX) SD_Death_DoShardVFX();
            SD_Death_DoPRCDeaths();
            break;
        }
        case SD_AI_TYPE_BOSS:
        {
            SD_Death_DoBase();
            SD_Death_DoLootAndRespawn();
            SD_Death_DoBossAnnounce();
            SD_Death_DoPRCDeaths();
            break;
        }
        case SD_AI_TYPE_STATIC:
        {
            SD_Death_DoBase();
            SD_Death_DoLootAndRespawn();
            SD_Death_DoPRCDeaths();
            break;
        }
        case SD_AI_TYPE_SHARD:
        {
            SD_Death_DoBase();
            SD_Death_DoLootAndRespawn();
            SD_Death_DoShardVFX1();
            SD_Death_DoBroadcast();
            SD_Death_DoPRCDeaths();
            break;
        }
        case SD_AI_TYPE_EVIL_ADJ:
        {
            SD_Death_DoBase();
            SD_Death_DoLootAndRespawn();
            SD_Death_DoEvilAdjust10();
            SD_Death_DoPRCDeaths();
            break;
        }
        case SD_AI_TYPE_RESTLESS:
        {
            SD_Death_DoBase();
            // No respawn include - uses zep_inc_monster instead
            craft_drop_items(GetLastKiller());
            SD_Death_DoRestlessRespawn();
            SD_Death_DoPRCDeaths();
            break;
        }
        case SD_AI_TYPE_DEMILICH:
        {
            // NW_I0_GENERIC style - base without sf_xp
            int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
            int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
            if (nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
                AdjustAlignment(GetLastKiller(), ALIGNMENT_EVIL, 5);

            SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);
            SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

            if (GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
                SignalEvent(OBJECT_SELF, EventUserDefined(1007));

            SD_Death_DoDemilich();
            SD_Death_DoPRCDeaths();
            break;
        }
        case SD_AI_TYPE_VEGEMOUNT:
            SD_Death_DoBase();
            SD_Death_DoSpawnVegeRider();
            SD_Death_DoPRCDeaths();
            break;
        case SD_AI_TYPE_WRGMOUNT:
            SD_Death_DoBase();
            SD_Death_DoSpawnGoblinRider();
            SD_Death_DoPRCDeaths();
            break;
        case SD_AI_TYPE_GOBRIDER:
            SD_Death_DoBase();
            SD_Death_DoSpawnWorg();
            SD_Death_DoPRCDeaths();
            break;
        case SD_AI_TYPE_VEGRIDER:
            SD_Death_DoBase();
            SD_Death_DoSpawnThorny();
            SD_Death_DoPRCDeaths();
            break;
        case SD_AI_TYPE_NO_DROP:
        {
            int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
            int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
            object oKiller = GetLastKiller();

            if (nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
                AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
            SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);
            SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
            if (GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
                SignalEvent(OBJECT_SELF, EventUserDefined(1007));

            SD_Death_DoGoldDrop();
            SD_Death_DoPRCDeaths();
            break;
        }
        case SD_AI_TYPE_SKINNABLE:
            SD_Death_DoSkinCorpse();
            break;
        case SD_AI_TYPE_CNR_BIRD:
            SD_Death_DoBirdDrop();
            break;
        case SD_AI_TYPE_CNR_MOB:
            SD_Death_DoMobDrop();
            break;
        case SD_AI_TYPE_X2_BASIC:
            SD_Death_DoBase();
            craft_drop_items(GetLastKiller());
            if (FindSubString(GetTag(OBJECT_SELF), "NSP") > -1)
                return;
            SE_DoCreatureRespawn();
            // No prc_npc_death or prc_pwondeath
            break;
        case SD_AI_TYPE_NPC_DEATH:
            SD_Death_DoEvilAdjust10();
            break;
        case SD_AI_TYPE_PESWIQ:
            SD_Death_DoImplosionVFX();
            break;
        case SD_AI_TYPE_SE_OD_EXAMPLE:
            SD_Death_DoBase();
            SD_Death_DoLootAndRespawn();
            SD_Death_DoPRCDeaths();
            break;
        default:
        {
            // Auto-detect from creature properties
            if (FindSubString(GetTag(OBJECT_SELF), "BOSS") > -1 ||
                GetLocalInt(OBJECT_SELF, "BOSS") == 1)
            {
                SD_Death_DoBase();
                SD_Death_DoLootAndRespawn();
                SD_Death_DoBossAnnounce();
                SD_Death_DoPRCDeaths();
            }
            else
            {
                SD_Death_DoBase();
                SD_Death_DoLootAndRespawn();
                SD_Death_DoPRCDeaths();
            }
            break;
        }
    }
}
