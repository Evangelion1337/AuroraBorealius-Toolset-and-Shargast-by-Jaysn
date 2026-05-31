//::///////////////////////////////////////////////
//:: Bolt: Paralyze
//:: NW_S1_BltParal
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
	int nCount 		= (nHD + 1) / 2;
    if (nCount == 0) { nCount = 1; }
	nCount = GetScaledDuration(nCount, oTarget);
	
    effect eVis 	= EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eBolt 	= EffectParalyze();
    effect eDur 	= EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink 	= EffectLinkEffects(eBolt, eDur);
    eLink 			= EffectLinkEffects(eLink, eVis);
    
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_BOLT_PARALYZE));
    //Make a saving throw check
    if (!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC) && TouchAttackRanged(oTarget))
    {
       //Apply the VFX impact and effects
       ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nCount));
    }
}
