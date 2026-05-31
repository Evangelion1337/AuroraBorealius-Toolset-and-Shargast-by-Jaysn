//::///////////////////////////////////////////////
//:: Bolt: Confuse
//:: NW_S1_BltConf
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
#include "prc_inc_spells"
//#include "wm_include"
#include "NW_I0_SPELLS"
void main()
{
    //if (WildMagicOverride()) { return; }

//:: Declare major variables
	object oNPC 	= OBJECT_SELF;
    object oTarget 	= PRCGetSpellTargetObject();
	
	int nHD 		= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC			= 10 +nCHAMod+ (nHD/2);	
	int nCount 		= (nHD + 1) / 2;
    nCount 			= GetScaledDuration(nCount, oTarget);
	
    effect eVis2 	= EffectVisualEffect(VFX_IMP_CONFUSION_S);
    effect eVis 	= EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eBolt 	= EffectConfused();
    effect eDur 	= EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink 	= EffectLinkEffects(eBolt, eDur);
    eLink 			= EffectLinkEffects(eLink, eVis);
	
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_BOLT_CONFUSE));
    //Make a saving throw check
    if (!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS) && TouchAttackRanged(oTarget))
    {
       //Apply the VFX impact and effects
       ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nCount));
       ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget);
    }
}