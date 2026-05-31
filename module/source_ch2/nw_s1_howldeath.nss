//::///////////////////////////////////////////////
//:: Howl: Death
//:: NW_S1_HowlDeath
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
#include "NW_I0_SPELLS"
//#include "wm_include"
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
	
	float fDelay;	
	
    effect eVis 	= EffectVisualEffect(VFX_IMP_DEATH);
    effect eImpact 	= EffectVisualEffect(VFX_FNF_HOWL_ODD);
    effect eHowl 	= EffectDeath();

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oNPC);
	
    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oNPC));
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget) && !GetIsFriend(oTarget) && oTarget != oNPC)
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_HOWL_DEATH));
            fDelay = GetDistanceToObject(oTarget)/10;
            //Make a saving throw check
            if(!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_DEATH, oNPC, fDelay))
            {
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
                //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oNPC));
    }
}

