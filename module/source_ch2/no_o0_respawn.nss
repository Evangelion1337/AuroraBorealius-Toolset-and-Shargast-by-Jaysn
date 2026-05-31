//::///////////////////////////////////////////////
//:: Generic On Pressed Respawn Button
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// * June 1: moved RestoreEffects into plot include
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   November
//:://////////////////////////////////////////////
#include "nw_i0_plot"
#include "nw_i0_generic"
const float ROUND = 6.0f;

/////////////////////////////////////////////////////////////////////////////
void ApplyPenalty(object oDead);
void RestartFight(object oRespawner);
void main()
{
   object oRespawner = GetLastRespawnButtonPresser();
   ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oRespawner);
   ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints(oRespawner)), oRespawner);
   RemoveEffects(oRespawner);

   //* Return PC to temple
   string sDestTag =  "NW_DEATH_TEMPLE";
   string sArea = GetTag(GetArea(oRespawner));
   if (GetIsObjectValid(GetObjectByTag(sDestTag)))
   {
      if (sDestTag == "NW_DEATH_TEMPLE")
      {
         object oPriest = GetObjectByTag("NW_DEATH_CLERIC");
         //SetLocalInt(oPriest, "NW_L_SAYONELINER", 10);

         //AssignCommand(oPriest, DelayCommand(3.0,ActionStartConversation(oRespawner)));
         AssignCommand(oPriest, DelayCommand(2.1, PlayVoiceChat(VOICE_CHAT_TALKTOME, oPriest)));

         SetLocalLocation(oRespawner, "NW_L_I_DIED_HERE", GetLocation(GetLastRespawnButtonPresser()));
         SetLocalInt(oRespawner, "NW_L_I_DIED", 1);
         SetLocalObject(oPriest, "NW_L_LASTDIED", GetLastRespawnButtonPresser());

         ApplyPenalty(oRespawner);
      }
      object oSpawnPoint = GetObjectByTag(sDestTag);
      AssignCommand(oRespawner, JumpToLocation(GetLocation(oSpawnPoint)));
   }
   else
   {
      // just apply penalty and respawn at same location
      ApplyPenalty(oRespawner);
      RestartFight(oRespawner);
   }
}

////////////////////////////////////////////////////////////////////////////////
// * Applies an XP and GP penalty
// * to the player respawning
void ApplyPenalty(object oDead)
{
   int nXP = GetXP(oDead);
   int nHD = GetHitDice(oDead);
   int nTimesDied = GetLocalInt(oDead, "PLAYER_DIED");
   // xp needed to be current level
   int nBaseXP = ((nHD * (nHD - 1)) / 2) * 1000;
   // the penalty is going to be, on average, 5 percent of what it takes to be
   //  your current level, then 10%, then 20%... but limited to NOT allow
   //  the player to lose a level - 50xp/level is heavy at low levels and not
   //  near enough at higher levels. This scales the award to be just as
   //  painful, regardless of level
   int nPenalty = d4(2 * nTimesDied) * FloatToInt(0.01 * nBaseXP);

   // * You can not lose a level with this respawning
   int nNewXP = nXP - nPenalty;
   if (nNewXP < nBaseXP)
   {
      nNewXP = nBaseXP;

      // reset the number of times died to reset the penalty to 5%
      //  otherwise, they won't get any penalties as they will be so high
      //  as to always make nNewXP < nBaseXP
      SetLocalInt(oDead, "PLAYER_DIED", 0);
   }
   SetXP(oDead, nNewXP);

   // Take 10% of their gold down to the last 100
   int nGoldToTake = FloatToInt(0.10 * GetGold(oDead));
   if (nGoldToTake > 10)
   {
      AssignCommand(oDead, TakeGoldFromCreature(nGoldToTake, oDead, TRUE));
   }
   // These messages already display - no point in telling them twice
   // DelayCommand(4.8, FloatingTextStrRefOnCreature(58300, oDead, FALSE));
   // DelayCommand(4.0, FloatingTextStrRefOnCreature(58299, oDead, FALSE));
}

// RestartFight - used to make hostiles attack me again
void Fight(object oAlive);
void RestartFight(object oRespawner)
{
   SetStandardFactionReputation(STANDARD_FACTION_HOSTILE, 0, oRespawner);
   AssignCommand(oRespawner, ClearAllActions());

   DelayCommand(ROUND, Fight(oRespawner));
}

void Fight(object oAlive)
{
   if (GetCurrentHitPoints(oAlive) > 0)
   {
      object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION,
         REPUTATION_TYPE_ENEMY, oAlive);
      if (oEnemy != OBJECT_INVALID)
      {
         AssignCommand(oEnemy, PlayVoiceChat(VOICE_CHAT_ATTACK));
         AssignCommand(oEnemy, DetermineCombatRound(oAlive));
         AssignCommand(oEnemy,
            SpeakString ("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK));
      }
   }
   else
   {
      // Recursively call this function until we are alive
      // Make sure player is still logged in
      if (GetPCPlayerName(oAlive) != "")
         DelayCommand(ROUND, Fight(oAlive));
   }
}
