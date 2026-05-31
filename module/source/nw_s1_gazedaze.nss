//::///////////////////////////////////////////////
//:: Gaze: Daze
//:: NW_S1_GazeDaze
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Cone shape that affects all within the AoE if they
    fail a Will Save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 11, 2001
//:://////////////////////////////////////////////
#include "prc_inc_spells"
#include "NW_I0_SPELLS"
//#include "wm_include"
#include "x0_i0_match"

void main()
{
//--------------------------------------------------------------------------
// Make sure we are not blind
//--------------------------------------------------------------------------
    if (PRCGetHasEffect(EFFECT_TYPE_BLINDNESS, OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(84530, OBJECT_SELF, FALSE);
        return;
    }
	
    //if (WildMagicOverride()) { return; }
	
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	object oTarget;
	
    int nHD 		= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC			= 10 +nCHAMod+ (nHD/2);	
    int nDuration 	= 1 + (nHD / 3);
	if(nDuration == 0) { nDuration = 1; }	
	
    location lTargetLocation = PRCGetSpellTargetLocation();
	
    effect eGaze 	= EffectDazed();
    effect eVis 	= EffectVisualEffect(VFX_IMP_DAZED_S);
    effect eDur 	= EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisDur	= EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eLink 	= EffectLinkEffects(eGaze, eVisDur);
    eLink 			= EffectLinkEffects(eLink, eDur);
	
    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 10.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget) && oTarget != oNPC)
        {
            nDuration = GetScaledDuration(nDuration , oTarget);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_GAZE_DAZE));
			
            //Determine effect delay
            float fDelay = GetDistanceBetween(oNPC, oTarget)/20;
            if(!/*WillSave*/PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS, oNPC, fDelay))
            {
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 10.0, lTargetLocation, TRUE);
    }
}

