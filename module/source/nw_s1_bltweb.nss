//::///////////////////////////////////////////////
//:: Bolt: Web
//:: NW_S1_BltWeb
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Glues a single target to the ground with
    sticky strands of webbing.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 28, 2002
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
	int nCount 		= 1 + (nHD /2);
    if (nCount == 0) { nCount = 1; }
	
    effect eVis = EffectVisualEffect(VFX_DUR_WEB);
    effect eStick = EffectEntangle();
    effect eLink = EffectLinkEffects(eVis, eStick);

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_BOLT_WEB));
    //Make a saving throw check
    if (!PRCMySavingThrow(SAVING_THROW_REFLEX, oTarget, nDC) && TouchAttackRanged(oTarget))
    {
       //Apply the VFX impact and effects
       ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nCount));
    }
}
