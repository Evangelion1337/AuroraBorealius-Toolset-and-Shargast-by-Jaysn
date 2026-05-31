//::///////////////////////////////////////////////
//:: Howl: Stun
//:: NW_S1_HowlStun
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A howl emanates from the creature which affects
    all within 10ft unless they make a save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 14, 2000
//:://////////////////////////////////////////////
//#include "wm_include"
#include "NW_I0_SPELLS"
#include "prc_inc_spells"

void main()
{
    //if (WildMagicOverride()) { return; }
	
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	object oTarget;
	
    int nHD 		= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC			= 10 +nCHAMod+ (nHD/4);		
	int nDuration 	= 1 + (nHD/4);
	
	float fDelay;

    effect eVis 	= EffectVisualEffect(VFX_IMP_STUN);
    effect eHowl 	= EffectStunned();
    effect eDur 	= EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 	= EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eImpact 	= EffectVisualEffect(VFX_FNF_HOWL_MIND);
    effect eLink 	= EffectLinkEffects(eHowl, eDur);
    eLink 			= EffectLinkEffects(eLink, eDur2);
    
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oNPC);
	
    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oNPC));
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget) && !GetIsFriend(oTarget) && oTarget != oNPC)
        {
            fDelay = GetDistanceToObject(oTarget)/10;
            nDuration = GetScaledDuration(nDuration , oTarget);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_HOWL_STUN));

            //Make a saving throw check
            if(!/*Will Save*/ PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS))
            {
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oNPC));
	}
}	

