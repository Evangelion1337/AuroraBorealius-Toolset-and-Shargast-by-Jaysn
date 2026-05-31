// OnPlayerDying - bleed to death script

#include "NW_I0_GENERIC"

const int BLEED_STATUS_CONSCIOUS = 0;
const int BLEED_STATUS_STABLE = 1;
const int BLEED_STATUS_BLEEDING = 2;
const int BLEED_STATUS_DEAD = 3;

const float ROUND = 6.0f;

void ClearMyAttacker(object oDying);
void Bleed(object oDying);
void main()
{
   object oDying = GetLastPlayerDying();
   object oKiller = GetLastHostileActor(oDying);
   if (!GetIsObjectValid(oDying))
      return;

   int nHP = GetCurrentHitPoints(oDying);
   if (nHP > 0) // not dying - why are we here?
      return;

   if (nHP <= -10)  // already dead
   {
      effect eDeath = EffectDeath(TRUE, FALSE);
      ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oDying);
      return;
   }

   SetLocalInt(oDying, "BLEED_STATUS", BLEED_STATUS_BLEEDING);
   AssignCommand(oDying, ClearAllActions());
   SetLocalInt(oDying, "LAST_HP", nHP);
   effect ePara = EffectParalyze();
   ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePara, oDying, ROUND);

   // Get nearest 20 objects and see if they are attacking me
   int nTh = 1;
   object oProbe = oKiller;

   while (GetIsObjectValid(oProbe) && nTh < 20)
   {
      if (!GetIsPC(oProbe))
         AssignCommand(oProbe, ClearMyAttacker(oDying));
      oProbe = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oDying, nTh);
      nTh++;
   }

   // Run recursive bleed function
   DelayCommand(ROUND, Bleed(oDying));
}

void ClearMyAttacker(object oDying)
{
   object oTarget = GetAttemptedAttackTarget();
   if (oTarget == oDying)
   {
      AdjustReputation(oDying, OBJECT_SELF, 100);
      SetIsTemporaryFriend(OBJECT_SELF, oDying, TRUE, 0.5);
      AssignCommand(OBJECT_SELF, ClearAllActions(TRUE)); // get out of combat
      AssignCommand(OBJECT_SELF, ActionMoveAwayFromObject(oDying, FALSE, 2.0f));
      AssignCommand(OBJECT_SELF, DetermineCombatRound()); // get back in
   }
}

///////////////////////////////////////////////////////////////////////////////
// Recursive Bleed function -

void Cry(object oPlayer);
void runAgain(object oDying);
void RestartFight(object oDying);
void Bleed(object oDying)
{
   if (!GetIsObjectValid(oDying))
      return;
   int nHP = GetCurrentHitPoints(oDying);
   int nLastHP = GetLocalInt(oDying, "LAST_HP");
   if (nHP <= -10)   // player is dead
   {
      SendMessageToPC(oDying, "You have bled to death.");
      effect eDeath = EffectDeath(FALSE, FALSE);
      ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oDying);
      SetLocalInt(oDying, "BLEED_STATUS", BLEED_STATUS_DEAD);
      DelayCommand(ROUND, RestartFight(oDying));
      return;
   }
   if (nHP >= 1) // player is alive & conscious
   {
      SetLocalInt(oDying, "BLEED_STATUS", BLEED_STATUS_CONSCIOUS);
      SendMessageToPC(oDying, "You have regained consciousness.");
      RestartFight(oDying);
      return;
   }

   if (GetLocalInt(oDying, "BLEED_STATUS") == BLEED_STATUS_BLEEDING)
   {
      // chance to stablilize
      if (d10() == 1) // 10% chance to stabilize roll
      {
         SetLocalInt(oDying, "BLEED_STATUS", BLEED_STATUS_STABLE);
         SendMessageToPC(oDying, "You have stabilized.");
      }
   }

   if (GetLocalInt(oDying, "BLEED_STATUS") == BLEED_STATUS_STABLE)
   {
      effect eHeal = EffectHeal(1);
      ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oDying);
      SendMessageToPC(oDying, "You heal 1 hit point. HP: " +
         IntToString(nHP + 1));

      if (GetCurrentHitPoints(oDying) >= 1) // player is alive & conscious
      {
         SetLocalInt(oDying, "BLEED_STATUS", BLEED_STATUS_CONSCIOUS);
         SendMessageToPC(oDying, "You have regained consciousness.");
         RestartFight(oDying);
         return;
      }
      AssignCommand(oDying, ClearAllActions());
      runAgain(oDying);
      return;
   }

   if (nHP > nLastHP) // someone healed player
   {
      SetLocalInt(oDying, "BLEED_STATUS", BLEED_STATUS_STABLE);
      SendMessageToPC(oDying, "You have stabilized.");
      AssignCommand(oDying, ClearAllActions());
      PlayVoiceChat(VOICE_CHAT_THANKS, oDying);
      runAgain(oDying);
      return;
   }

   // Sanity check
   if (GetLocalInt(oDying, "BLEED_STATUS") != BLEED_STATUS_BLEEDING)
      return;

   // Apply bleeding damage
   effect eDamage = EffectDamage(1, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_FIVE);
   ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oDying);
   nHP = GetCurrentHitPoints(oDying);
   string msg = "You are bleeding to death! HP: " + IntToString(nHP);
   SendMessageToPC(oDying, msg);
   AssignCommand(oDying, ClearAllActions());

   if (nHP > -9)
      Cry(oDying);

   if (GetCurrentHitPoints(oDying) <= -10)   // player is dead
   {
      SendMessageToPC(oDying, "You have bled to death.");
      effect eDeath = EffectDeath(FALSE, FALSE);
      ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oDying);
      SetLocalInt(oDying, "BLEED_STATUS", BLEED_STATUS_DEAD);
      RestartFight(oDying);
      AssignCommand(oDying, ClearAllActions());
      return;
   }

   runAgain(oDying);
}

void Cry(object oPlayer)
{
   switch (d6()) // whine
   {
   case 1: PlayVoiceChat (VOICE_CHAT_PAIN1,     oPlayer); break;
   case 2: PlayVoiceChat (VOICE_CHAT_PAIN2,     oPlayer); break;
   case 3: PlayVoiceChat (VOICE_CHAT_PAIN3,     oPlayer); break;
   case 4: PlayVoiceChat (VOICE_CHAT_HEALME,    oPlayer); break;
   case 5: PlayVoiceChat (VOICE_CHAT_NEARDEATH, oPlayer); break;
   case 6: PlayVoiceChat (VOICE_CHAT_HELP,      oPlayer); break;
   }
}

void runAgain(object oDying)
{
   SetLocalInt(oDying, "LAST_HP", GetCurrentHitPoints(oDying));
   effect eParalyze = EffectParalyze();
   ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eParalyze, oDying, ROUND);
   SetStandardFactionReputation(STANDARD_FACTION_HOSTILE, 100, oDying);

   // Make sure player is still logged in
   if (GetPCPlayerName(oDying) != "")
      DelayCommand(ROUND, Bleed(oDying));
}

// RestartFight - used to make hostiles attack me again
void Fight(object oAlive);
void RestartFight(object oDying)
{
   object oKiller = GetLastHostileActor(oDying);
   AdjustReputation(oDying, oKiller, -100);
   SetStandardFactionReputation(STANDARD_FACTION_HOSTILE, 0, oDying);
   AssignCommand(oDying, ClearAllActions());

   // delayed recursive call
   DelayCommand(ROUND, Fight(oDying));
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
