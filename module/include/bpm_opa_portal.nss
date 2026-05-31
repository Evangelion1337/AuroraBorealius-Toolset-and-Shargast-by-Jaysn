//::///////////////////////////////////////////////
//:: Gatestones 1.6
//:: bpm_opa_portal
//:: Copyright (c) 2006 CarfaxAbbey.net
//:://////////////////////////////////////////////
/*
    To be placed in the OnPhysicalAttacked Script of the portals.
*/
//:://////////////////////////////////////////////
//:: Created By: Diavlen <diavlen@carfaxabbey.net>
//:: Created On: 3/24/2004
//:: Updated on: 8/11/2006
//:://////////////////////////////////////////////

void main() {
    object oPC      =       GetLastAttacker();
    object oPortal  =       OBJECT_SELF;
    effect eVis     =       EffectVisualEffect(VFX_DUR_GLOBE_INVULNERABILITY);
    effect eDamage  =       EffectDamage( d20(3),DAMAGE_TYPE_ELECTRICAL,DAMAGE_POWER_ENERGY);
    effect eBeam    =       EffectBeam(VFX_BEAM_LIGHTNING,oPortal,BODY_NODE_CHEST);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eVis,oPortal,10.0);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eBeam,oPC,3.0);
    ApplyEffectToObject(DURATION_TYPE_INSTANT,eDamage,oPC);
}
