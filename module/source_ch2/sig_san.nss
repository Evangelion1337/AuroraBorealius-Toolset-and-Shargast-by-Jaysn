//sig_san

#include "x2_inc_switches"

void main()
{ if( GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE ) return;
object oTarget =GetItemActivator();
effect eEffect;
eEffect = EffectInvisibility(INVISIBILITY_TYPE_IMPROVED);
eEffect = SupernaturalEffect(eEffect);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 300.0f);
eEffect = EffectTemporaryHitpoints(10);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 60.0f);
int nInt = GetObjectType(oTarget);
if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_WORD), oTarget);
else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_WORD), GetLocation(oTarget));
}
