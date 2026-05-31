// sd_ai_inc_combat.nss
// Universal AI Framework - Combat & Perception Subsystem
// (placeholder for future item-usage and advanced AI dispatch)

#include "sd_ai_inc_const"
#include "nw_i0_generic"
#include "prc_inc_spells"
#include "x3_inc_horse"

// ========== OnPerception (nw_c2_default2) ==========
void SD_Perception_DoStandard()
{
    if (GetAILevel() == AI_LEVEL_VERY_LOW) return;

    ExecuteScript("prc_npc_percep", OBJECT_SELF);

    object oPercep = GetLastPerceived();
    int bSeen = GetLastPerceptionSeen();
    int bHeard = GetLastPerceptionHeard();

    if (bHeard == FALSE)
        bHeard = GetLastPerceptionVanished();

    if (GetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION)
       && GetIsPC(oPercep)
       && bSeen)
    {
        SpeakOneLinerConversation();
    }

    if (GetLastPerceptionVanished() && GetIsEnemy(GetLastPerceived()))
    {
        object oGone = GetLastPerceived();
        if ((GetAttemptedAttackTarget() == GetLastPerceived() ||
           GetAttemptedSpellTarget() == GetLastPerceived() ||
           GetAttackTarget() == GetLastPerceived()) && GetArea(GetLastPerceived()) != GetArea(OBJECT_SELF))
        {
           ClearAllActions();
           DetermineCombatRound();
        }
    }

    if (GetIsInCombat(OBJECT_SELF))
    {
    }
    else if (GetIsEnemy(oPercep) && bSeen)
    {
        if (!PRCGetHasEffect(EFFECT_TYPE_SLEEP))
        {
            if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                DetermineSpecialBehavior();
            }
            else
            {
                SetFacingPoint(GetPosition(oPercep));
                SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
                DetermineCombatRound();
            }
        }
    }
    else
    {
        if (bSeen)
        {
            if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                DetermineSpecialBehavior();
            }
            else if (GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION)
                     && GetIsPC(oPercep))
            {
                ActionStartConversation(OBJECT_SELF);
            }
        }
        else if (bHeard && GetIsEnemy(oPercep))
        {
            if (GetDistanceToObject(oPercep) <= 7.0)
            {
                if (GetHasSpell(SPELL_TRUE_SEEING))
                    ActionCastSpellAtObject(SPELL_TRUE_SEEING, OBJECT_SELF);
                else if (GetHasSpell(SPELL_SEE_INVISIBILITY))
                    ActionCastSpellAtObject(SPELL_SEE_INVISIBILITY, OBJECT_SELF);
                else if (GetHasSpell(SPELL_INVISIBILITY_PURGE))
                    ActionCastSpellAtObject(SPELL_INVISIBILITY_PURGE, OBJECT_SELF);
                else
                {
                    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 0.5);
                    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, 0.5);
                    ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD, 0.5);
                }
            }
        }

        if (!IsInConversation(OBJECT_SELF))
        {
            if (GetIsPostOrWalking())
            {
                WalkWayPoints();
            }
            else if (GetIsPC(oPercep) &&
                (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS)
                 || GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN)
                 || GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS)
                 || GetIsEncounterCreature()))
            {
                SetAnimationCondition(NW_ANIM_FLAG_IS_ACTIVE);
            }
        }
    }

    if (GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT) && GetLastPerceptionSeen())
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_PERCEIVE));
    }
}

// ========== OnAttacked (nw_c2_default5) ==========
void SD_Attacked_DoStandard()
{
    ExecuteScript("prc_npc_physatt", OBJECT_SELF);

    if (!GetLocalInt(GetModule(), "X3_NO_MOUNTED_COMBAT_FEAT"))
    {
        SetLocalInt(OBJECT_SELF, "bX3_LAST_ATTACK_PHYSICAL", TRUE);
        SetLocalInt(OBJECT_SELF, "nX3_HP_BEFORE", GetCurrentHitPoints(OBJECT_SELF));
    }

    if (GetFleeToExit())
    {
        ActivateFleeToExit();
    }
    else if (GetSpawnInCondition(NW_FLAG_SET_WARNINGS))
    {
        SetSpawnInCondition(NW_FLAG_SET_WARNINGS, FALSE);
    }
    else
    {
        object oAttacker = GetLastAttacker();
        if (!GetIsObjectValid(oAttacker))
        {
        }
        else if (!GetIsFighting(OBJECT_SELF))
        {
            if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                SetSummonHelpIfAttacked();
                DetermineSpecialBehavior(oAttacker);
            }
            else if (GetArea(oAttacker) == GetArea(OBJECT_SELF))
            {
                SetSummonHelpIfAttacked();
                DetermineCombatRound(oAttacker);
            }

            SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
            SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
        }
    }

    if (GetSpawnInCondition(NW_FLAG_ATTACK_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_ATTACKED));
    }
}

// ========== OnDamaged (nw_c2_default6) ==========
void SD_Damaged_DoStandard()
{
    object oDamager = GetLastDamager();
    object oMe = OBJECT_SELF;
    int nHPBefore;

    if (!GetLocalInt(GetModule(), "X3_NO_MOUNTED_COMBAT_FEAT"))
    if (GetHasFeat(FEAT_MOUNTED_COMBAT) && HorseGetIsMounted(OBJECT_SELF))
    {
        if (GetLocalInt(OBJECT_SELF, "bX3_LAST_ATTACK_PHYSICAL"))
        {
            nHPBefore = GetLocalInt(OBJECT_SELF, "nX3_HP_BEFORE");
            if (!GetLocalInt(OBJECT_SELF, "bX3_ALREADY_MOUNTED_COMBAT"))
            {
                SetLocalInt(OBJECT_SELF, "bX3_ALREADY_MOUNTED_COMBAT", TRUE);
                int nAttackRoll = GetBaseAttackBonus(oDamager) + d20();
                int nRideCheck = GetSkillRank(SKILL_RIDE, OBJECT_SELF) + d20();
                if (nRideCheck >= nAttackRoll && !GetIsDead(OBJECT_SELF))
                {
                    if (GetIsPC(oDamager)) SendMessageToPC(oDamager, GetName(OBJECT_SELF) + GetStringByStrRef(111991));
                    if (GetCurrentHitPoints(OBJECT_SELF) < nHPBefore)
                    {
                        effect eHeal = EffectHeal(nHPBefore - GetCurrentHitPoints(OBJECT_SELF));
                        AssignCommand(GetModule(), ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oMe));
                    }
                }
            }
        }
    }

    if (GetFleeToExit())
    {
    }
    else if (GetSpawnInCondition(NW_FLAG_SET_WARNINGS))
    {
    }
    else
    {
        if (!GetIsObjectValid(oDamager))
        {
        }
        else if (!GetIsFighting(OBJECT_SELF))
        {
            if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                DetermineSpecialBehavior(oDamager);
            }
            else
            {
                if (!GetObjectSeen(oDamager)
                   && GetArea(OBJECT_SELF) == GetArea(oDamager))
                {
                    ActionMoveToLocation(GetLocation(oDamager), TRUE);
                    ActionDoCommand(DetermineCombatRound());
                }
                else
                {
                    DetermineCombatRound();
                }
            }
        }
        else
        {
            object oTarget = GetAttackTarget();
            if (!GetIsObjectValid(oTarget))
                oTarget = GetAttemptedAttackTarget();
            if (!GetIsObjectValid(oTarget))
                oTarget = GetAttemptedSpellTarget();

            if (!GetIsObjectValid(oTarget)
                || (
                    oTarget != oDamager
                    && (
                         GetTotalDamageDealt() > (GetMaxHitPoints(OBJECT_SELF) / 4)
                         || (GetHitDice(oDamager) - 2) > GetHitDice(oTarget)
                         )
                    )
                )
            {
                DetermineCombatRound(oDamager);
            }
        }
    }

    if (GetLocalInt(OBJECT_SELF, "FIGHT_OR_FLIGHT") == 1 && GetLocalInt(OBJECT_SELF, "RETREATED") == 0)
    {
        ExecuteScript("fight_or_flight", OBJECT_SELF);
    }

    if (GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DAMAGED));
    }

    ExecuteScript("prc_npc_damaged", OBJECT_SELF);
}

// Master dispatchers
void SD_Perception_Dispatch()  { SD_Perception_DoStandard(); }
void SD_Attacked_Dispatch()    { SD_Attacked_DoStandard(); }
void SD_Damaged_Dispatch()     { SD_Damaged_DoStandard(); }
