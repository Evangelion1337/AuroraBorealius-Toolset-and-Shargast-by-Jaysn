void main()
{
    SetLocalInt(OBJECT_SELF,"iCounter",0);
{
    effect eSwarm;
    object oPC = GetLastUsedBy();
    if (!GetIsPC(oPC)) return;
    eSwarm = EffectSwarm(TRUE, "WarriorSlave", "Wanderer", "HalffiendFade", "UettinMage");
  ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSwarm, oPC, 180.0f);
}
}
