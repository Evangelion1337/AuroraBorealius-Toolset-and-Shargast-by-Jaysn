//::///////////////////////////////////////////////
//:: Bolt: Knockdown
//:: NW_S1_BltKnckD
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature must make a ranged touch attack to hit
    the intended target.  Reflex or Will save is
    needed to halve damage or avoid effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 11 , 2001
//:://////////////////////////////////////////////
#include "NW_I0_SPELLS"
#include "prc_inc_spells"
//#include "wm_include"

void main()
{
    //if (WildMagicOverride()) { return; }
	
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	object oTarget 	= PRCGetSpellTargetObject();
	
    int nHD 		= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC			= 10 +nCHAMod+ (nHD/2);
	int nCount 		= nHD/2;
    if (nCount == 0) { nCount = 1; }
	
    effect eVis 	= EffectVisualEffect(VFX_IMP_SONIC);
    effect eBolt 	= EffectKnockdown();
    effect eDam 	= EffectDamage(d6(), DAMAGE_TYPE_BLUDGEONING);
    
	//Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_BOLT_KNOCKDOWN));
    
	//Make a saving throw check
    if (!/*Reflex Save*/ PRCMySavingThrow(SAVING_THROW_REFLEX, oTarget, nDC) && TouchAttackRanged(oTarget))
    {
       //Apply the VFX impact and effects
       ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBolt, oTarget, RoundsToSeconds(3));
       ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
       ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    }
}
