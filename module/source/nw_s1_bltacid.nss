//::///////////////////////////////////////////////
//:: Bolt: Acid
//:: NW_S1_BltAcid
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
	int nCONMod		= GetAbilityModifier(ABILITY_CONSTITUTION, oNPC);
    int nDC			= 10 +nCONMod+ (nHD/2);
	int nCount 		= nHD/2;
    if (nCount == 0) { nCount = 1; }
	int nDamage 	= d6(nCount);
	
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);
    effect eBolt;

    //ankheg
    if(GetAppearanceType(oNPC) == APPEARANCE_TYPE_BEETLE_SLICER)
    {
        nDamage = d4(4);
    }

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_BOLT_ACID));
	
    //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
    nDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget, nDC,SAVING_THROW_TYPE_ACID);
	
    //Make a ranged touch attack
    int nTouch = TouchAttackRanged(oTarget);
    if(nTouch > 0)
    {
        if(nTouch == 2)
        {
            nDamage *= 2;
        }
        //Set damage effect
        eBolt = EffectDamage(nDamage, DAMAGE_TYPE_ACID);
        if(nDamage > 0)
        {
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}
