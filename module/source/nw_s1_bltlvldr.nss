//::///////////////////////////////////////////////
//:: Bolt: Level Drain
//:: NW_S1_BltLvlDr
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
	int nCount 		= nHD/5;
    if (nCount == 0) { nCount = 1; }
	int nDamage 	= d6(nCount);

    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eBolt = EffectNegativeLevel(1);
    
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_BOLT_LEVEL_DRAIN));
	
    //Make a saving throw check
    if (!/*Fort Save*/ PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NEGATIVE) && TouchAttackRanged(oTarget))
    {
        //eBolt = LEVEL DRAIN EFFECT
        eBolt = SupernaturalEffect(eBolt);
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
}
