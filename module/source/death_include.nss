//::///////////////////////////////////////////////
//:: Death System standard include
//:: death_include
//:://////////////////////////////////////////////
/*

*/
#include "death_db_name"
#include "sql_campaign"

//:://////////////////////////////////////////////
//::  Constants
//:://////////////////////////////////////////////

// The iInitExpMultiplier float variable indicates the
// multiplier to the player's level to determine the initial
// experience penalty for dying.  This is the penalty assessed
// before the player respawns.
const float fInitExpMultiplier = 35.0;

// The iInitGoldMultiplier float variable indicates the
// multiplier to the player's level to determin the inital
// gold penalty for dying.  This is the penalty assessed before
// the player respawns.
const float fInitGoldMultiplier = 0.0;

// The iMinimumDeathLevel int variable controls the
// minimum level at which death penalties apply.  Players
// who die below this level, do not experience penalties.
const int iMinimumDeathLevel = 1;

// The iRespawnExpMultiplier float variable indicates the
// multiplier to the player's level to determine the respawn
// experience penalty for dying.  This is the penalty assessed
// after the player respawns
const float fRespawnExpMultiplier = 25.0;

// The iRespawnGoldMultiplier float variable indicates the
// multiplier to the player's level to determin the respawn
// gold penalty for dying.  This is the penalty assessed
// after the player respawns.
const float fRespawnGoldMultiplier = 0.0;

// The fExpBuyMultiplier float variable indicates the amount
// of gold needed to buy back a single point of experience.
const float fExpBuyMultiplier = 0.5;

// The bDeathAfterEffects int variable indicates whether or
// not death after effects should be applied.
const int bDeathAfterEffects = TRUE;

// The bAllowLevelLoss int variable is a flag to indicate
// if a player should be allowed to lose a level because of
// a death
const int bAllowLevelLoss = FALSE;

//:://////////////////////////////////////////////
//::     Method:    dhDeathModuleLoad
//:: Created By:    Dauvis
//:: Created On:    6/27/03
//::
//:: This funciton is currently obsolete but is included
//:: for backwards compatibility
//:://////////////////////////////////////////////
void dhDeathModuleLoad()
{
    // do nothing
}

//:://////////////////////////////////////////////
//:: Created By:    Dauvis
//:: Created On:    6/27/03
//::
//:: This method should be called in the module's OnClientEntered
//:: event.  It is responsible for checking the player that just
//:: entered and kills them if the death flag is set.
//:://////////////////////////////////////////////
void dhDeathCheckPlayer(object oPlayer)
{
    // error check
    if (!GetIsPC(oPlayer)) return;

    // Clear the variable on brand new players
    if (GetXP(oPlayer) == 0) {
        SQL_SetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iDeathFlag", FALSE, oPlayer);
        SQL_SetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iExpBuyBackCost", 0, oPlayer);
        SQL_SetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iRecoverableExp", 0, oPlayer);
        return;
    }

    // check the flag on the player
    int bFlag = SQL_GetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iDeathFlag", oPlayer);

    if (bFlag) {
        // player logged out while dead, set flag to prevent initial penalty,
        // and kill him.
        SetLocalInt(oPlayer, "iIgnoreInitialPenalty", TRUE);
        effect effDeath = EffectDeath();
        DelayCommand(1.0, AssignCommand(oPlayer, ClearAllActions()));
        DelayCommand(2.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, effDeath, oPlayer, 0.0));
    }
}

