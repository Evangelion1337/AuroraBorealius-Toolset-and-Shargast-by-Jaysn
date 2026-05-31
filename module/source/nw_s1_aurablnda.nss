//::///////////////////////////////////////////////
//:: Aura of Blinding On Enter
//:: NW_S1_AuraBlndA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be blinded because of the
    sheer ugliness or beauty of the creature.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
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
	int nDuration 	= 1 + (nHD/3);
	
    effect eBlind 	= EffectBlindness();
    effect eDur		= EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVis 	= EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eLink 	= EffectLinkEffects(eBlind, eDur);

    //if (NullMagicOverride(GetArea(oTarget), oTarget, oTarget)) {return;}
	
    //Entering object must make a will save or be blinded for the duration.
    if(GetIsEnemy(oTarget, GetAreaOfEffectCreator()))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_AURA_BLINDING));
        if (!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC))
        {
            //Apply the blind effect and the VFX impact
            DelayCommand(0.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            DelayCommand(0.0f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
        }
    }
}