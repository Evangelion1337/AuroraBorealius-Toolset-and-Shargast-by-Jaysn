//sig_pal

#include "x2_inc_switches"

void main()
{ if( GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE ) return;
object oTarget =GetItemActivator();
effect eEffect;
eEffect = EffectACIncrease(10);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 60.0f);
eEffect = EffectUltravision();
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 60.0f);
eEffect = EffectDamageIncrease(DAMAGE_BONUS_5, DAMAGE_TYPE_POSITIVE);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 60.0f);
int nInt = GetObjectType(oTarget);
if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION), oTarget);
else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION), GetLocation(oTarget));
}

