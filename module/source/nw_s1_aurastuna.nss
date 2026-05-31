//::///////////////////////////////////////////////
//:: Aura Stunning On Enter
//:: NW_S1_AuraStunA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be stunned.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
#include "NW_I0_SPELLS"
//#include "wm_include"
#include "prc_inc_spells"
void main()
{
//:: Declare major variables
	object oNPC 	= GetAreaOfEffectCreator();
    object oTarget = GetEnteringObject();
	
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
	int nDuration 	= GetHitDice(oNPC);
    int nDC 		= 10 + nCHAMod + (nDuration/2);
	
	//if (NullMagicOverride(GetArea(oTarget), oTarget, oTarget)) {return;}
    
	effect eVis 	= EffectVisualEffect(VFX_IMP_STUN);
    effect eVis2 	= EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDeath 	= EffectStunned();
    effect eLink 	= EffectLinkEffects(eVis2, eDeath);    
    
    nDuration = GetScaledDuration(nDuration, oTarget);
	
    if(!GetIsFriend(oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_AURA_STUN));
        //Make a saving throw check
        if(!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS))
        {
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}