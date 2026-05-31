//mm_evil_chg
void main()
{

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

AdjustAlignment(oPC, ALIGNMENT_EVIL, 100);

object oTarget;
oTarget = oPC;

effect eEffect;
eEffect = EffectDeath();

ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 60.0f);

}
