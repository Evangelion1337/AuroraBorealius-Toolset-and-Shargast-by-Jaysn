//UndeathsGreaterFoe - u_greaterfoe
void main()
{
object oPC;

if ((GetObjectType(GetItemActivatedTarget())!=OBJECT_TYPE_CREATURE)
){

return;}

object oTarget;
oTarget = GetItemActivatedTarget();

effect eEffect;
eEffect = EffectPetrify();

eEffect = SupernaturalEffect(eEffect);

ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 120.0f);

oPC = GetItemActivator();

oTarget = oPC;

eEffect = EffectPolymorph(POLYMORPH_TYPE_ZOMBIE);

eEffect = SupernaturalEffect(eEffect);

ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 360.0f);

oTarget = GetItemActivatedTarget();

//Visual effects can't be applied to waypoints, so if it is a WP
//the VFX will be applied to the WP's location instead

int nInt;
nInt = GetObjectType(oTarget);

if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_HOLY_30), oTarget);
else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_HOLY_30), GetLocation(oTarget));

}
