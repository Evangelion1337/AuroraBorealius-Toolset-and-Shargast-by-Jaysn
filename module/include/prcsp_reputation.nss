#include "x2_inc_switches"

// * Generic reputation wrapper
// * definition of constants:
// * SPELL_TARGET_ALLALLIES = Will affect all allies, even those in my faction who don't like me
// * SPELL_TARGET_STANDARDHOSTILE: 90% of offensive area spells will work
//   this way. They will never hurt NEUTRAL or FRIENDLY NPCs.
//   They will never hurt FRIENDLY PCs
//   They WILL hurt NEUTRAL PCs
// * SPELL_TARGET_SELECTIVEHOSTILE: Will only ever hurt enemies

// * Constants
// * see spellsIsTarget for a definition of these constants
const int SPELL_TARGET_ALLALLIES = 1;
const int SPELL_TARGET_STANDARDHOSTILE = 2;
const int SPELL_TARGET_SELECTIVEHOSTILE = 3;

//::///////////////////////////////////////////////
//:: spellsIsTarget
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This is the reputation wrapper.
    It performs the check to see if, based on the
    constant provided
    it is okay to target this target with the
    spell effect.


    MODIFIED APRIL 2003
    - Other player's associates will now be harmed in
       Standard Hostile mode
    - Will ignore dead people in all target attempts

    MODIFIED AUG 2003 - GZ
    - Multiple henchmen support: made sure that
      AoE spells cast by one henchmen do not
      affect other henchmen in the party

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: March 6 2003
//:://////////////////////////////////////////////

// This kind of spell will affect all friendlies and anyone in my
// party, even if we are upset with each other currently.
int
HandleDispositionALLALLIES(object oTarget, object oSource)
{
    return GetIsReactionTypeFriendly(oTarget,oSource)
        || GetFactionEqual(oTarget,oSource);
}

// Only harms enemies, ever.
// current list:
//      call lightning, isaac missiles, firebrand, chain lightning, dirge, Nature's balance,
//      Word of Faith
int
HandleDispositionSELECTIVEHOSTILE(object oTarget, object oSource)
{
    return GetIsEnemy(oTarget, oSource);
}

int
HandleDispositionSTANDARDHOSTILE(object oTarget, object oSource)
{
    object oMaster = GetMaster(oTarget);

    // March 25 2003. In hardcore, casters will affect themselves and
    // their associates.
    if (GetGameDifficulty() > GAME_DIFFICULTY_NORMAL) {
        if (oTarget == oSource || oMaster == oSource)
            return TRUE;
    }

    // April 9 2003. Hurt the associates of a hostile player
    if (GetIsObjectValid(oMaster)) {
        // Target is an associate of an unfriendly PC or is outright hostile
        if ((!GetIsReactionTypeFriendly(oMaster,oSource) && GetIsPC(oMaster))
                || GetIsReactionTypeHostile(oMaster,oSource))
            return TRUE;
    }
    
    // Spiderfriend Magic means that spells never hurt neutral or allied vermin
    if (GetHasFeat(FEAT_SPIDERFRIEND_MAGIC, oSource) && !GetIsReactionTypeHostile(oTarget, oSource) && GetRacialType(oTarget) == RACIAL_TYPE_VERMIN)
        return FALSE;

    // Assumption: In Full PvP players, even if in same party, are Neutral
    // GZ: 2003-08-30: Patch to make creatures hurt each other in hardcore mode.

    // Hostile creatures are always a target.
    if (GetIsReactionTypeHostile(oTarget,oSource))
        return TRUE;

    // Handle logic for neutral targets (we know !Hostile(), see above).
    if (!GetIsReactionTypeFriendly(oTarget, oSource)) {
        // 'neutral' PCs are targets
        if (GetIsPC(oTarget))
            return TRUE;

        // Local Override is just an out for end users who want
        // the area effect spells to hurt 'neutrals'.
        if (GetLocalInt(GetModule(), "X0_G_ALLOWSPELLSTOHURT") == 10)
            return TRUE;

        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_NPC_AOE_HURT_ALLIES)
                && GetGameDifficulty() > GAME_DIFFICULTY_NORMAL)
            return TRUE;    // Hostile Creature and Difficulty > Normal.
                            // In hardcore mode any creature is hostile.
    }

    // Default response
    return FALSE;
}


int spellsIsTarget(object oTarget, int nTargetType, object oSource)
{
    // * if dead, not a valid target
    if (GetIsDead(oTarget))
        return FALSE;

    // GZ: Creatures with the same master will never damage each other
    object oTargetMaster = GetMaster(oTarget);
    object oSourceMaster = GetMaster(oSource);
    if (GetIsObjectValid(oTargetMaster) 
        && GetIsObjectValid(oSourceMaster)
        && !GetModuleSwitchValue(MODULE_SWITCH_ENABLE_MULTI_HENCH_AOE_DAMAGE)
        && oTargetMaster == oSourceMaster
        && nTargetType != SPELL_TARGET_ALLALLIES) 
    {
        return FALSE;
    }

    switch (nTargetType) {
        case SPELL_TARGET_ALLALLIES:
            return HandleDispositionALLALLIES(oTarget, oSource);

        case SPELL_TARGET_SELECTIVEHOSTILE:
            return HandleDispositionSELECTIVEHOSTILE(oTarget, oSource);

        case SPELL_TARGET_STANDARDHOSTILE:
            return HandleDispositionSTANDARDHOSTILE(oTarget, oSource);
    }

    // unhandled dispositions
    return FALSE;
}
