/*   Black Knight Punish non-menber    */

//Script: bk_punish

void main()
{

object oPC = GetPCSpeaker();

object oTarget;
oTarget = oPC;

effect eEffect;
eEffect = EffectBlindness();

ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 15.0f);

eEffect = EffectDamage(3, DAMAGE_TYPE_NEGATIVE, DAMAGE_POWER_ENERGY);

ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oPC);

//Visual effects can't be applied to waypoints, so if it is a WP
//the VFX will be applied to the WP's location instead

int nInt;
nInt = GetObjectType(oTarget);

if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_HIT_NEGATIVE), oTarget);
else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_HIT_NEGATIVE), GetLocation(oTarget));

}

