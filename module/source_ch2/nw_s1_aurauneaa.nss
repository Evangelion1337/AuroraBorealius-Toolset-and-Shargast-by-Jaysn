//::///////////////////////////////////////////////
//:: Aura Unearthly Visage On Enter
//:: NW_S1_AuraUnEaA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be killed because of the
    sheer ugliness or beauty of the creature.
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
	object oNPC		= GetAreaOfEffectCreator();
	object oTarget 	= GetEnteringObject();
	
	int nHD 		= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC			= 10 +nCHAMod+ (nHD/2);
	
    //if (NullMagicOverride(GetArea(oTarget), oTarget, oTarget)) {return;}
    
	effect eDeath = EffectDeath();
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    
	if(GetIsEnemy(oTarget, oNPC))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_AURA_UNEARTHLY_VISAGE));
        //Make a saving throw check
        if(!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_DEATH))
        {
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget);
            //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}
