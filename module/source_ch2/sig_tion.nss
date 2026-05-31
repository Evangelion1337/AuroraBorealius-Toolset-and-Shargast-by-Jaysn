//sig_tion

#include "x2_inc_switches"

void main()
{ if( GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE ) return;
object oTarget =GetItemActivator();
effect eEffect;
eEffect = EffectAttackIncrease(5);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 60.0f);
eEffect = EffectAbilityIncrease(ABILITY_STRENGTH, 5);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 60.0f);
eEffect = EffectAbilityIncrease(ABILITY_CONSTITUTION, 5);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 60.0f);
int nInt = GetObjectType(oTarget);
if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION), oTarget);
else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION), GetLocation(oTarget));
}

