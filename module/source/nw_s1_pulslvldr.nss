//::///////////////////////////////////////////////
//:: Pulse: Level Drain
//:: NW_S1_PulsLvlDr
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A wave of energy emanates from the creature which affects
    all within 10ft.  Damage can be reduced by half for all
    damaging variants.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 14, 2000
//:://////////////////////////////////////////////
#include "NW_I0_SPELLS"
#include "prc_inc_spells"
//#include "wm_include"
void main()
{
    //if (WildMagicOverride()) { return; }

//:: Declare major variables
	object oNPC		= GetAreaOfEffectCreator();
	object oTarget 	= GetEnteringObject();
	
    int nHD 		= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC			= 10 +nCHAMod+ (nHD/2);
	
	float fDelay;
		
    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eHowl;
    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE);
	
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, GetLocation(oNPC));
	
	//Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));

    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != oNPC)
        {
            if(!GetIsReactionTypeFriendly(oTarget))
            {
                fDelay = GetSpellEffectDelay(GetLocation(oNPC), oTarget)/20;
                //Make a saving throw check
                if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NEGATIVE, oNPC, fDelay))
                {
                    //Apply the VFX impact and effects
                    eHowl = EffectNegativeLevel(1);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHowl, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    }
}

