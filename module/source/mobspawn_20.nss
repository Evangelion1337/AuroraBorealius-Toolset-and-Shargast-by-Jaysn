// Example 1 - The following script is an OnUsed event script.
// When triggered, it checks to make sure it was triggered by a
// PC, and if not exits the script.  If it was a PC that triggered the
// script, the Swarm effect is created and applied to the PC for
// duration of 3 minutes.

void main()
{
    effect eSwarm;
    object oPC = GetLastUsedBy();
    if (!GetIsPC(oPC)) return;
    eSwarm = EffectSwarm(TRUE, "WarriorSlave", "Wanderer", "HalffiendFade", "UettinMage");
  ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSwarm, oPC, 180.0f);
}
