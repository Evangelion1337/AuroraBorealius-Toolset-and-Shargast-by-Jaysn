//mm_pwr_tion

void main()
{

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

if (GetItemPossessedBy(oPC, "mm_sig_tion")== OBJECT_INVALID)
   return;

AdjustAlignment(oPC, ALIGNMENT_EVIL, 5);

object oTarget;
oTarget = oPC;

effect eEffect;
eEffect = EffectTemporaryHitpoints(50);

ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 300.0f);

//Visual effects can't be applied to waypoints, so if it is a WP
//the VFX will be applied to the WP's location instead

int nInt;
nInt = GetObjectType(oTarget);

if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY), oTarget);
else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY), GetLocation(oTarget));

}
