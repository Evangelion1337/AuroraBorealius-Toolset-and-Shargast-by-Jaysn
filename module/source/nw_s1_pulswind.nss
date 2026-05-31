//::///////////////////////////////////////////////
//:: Pulse Whirlwind
//:: NW_S1_PulsWind
//:: Copyright (c) 2001 Bioware Corp.
//::///////////////////////////////////////////////
/*
    All those that fail a save are knocked
    down by the elemental whirlwind.
*/
//::///////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 8, 2002
//::///////////////////////////////////////////////
#include "NW_I0_SPELLS"
#include "prc_inc_spells"
//#include "wm_include"
void main()
{
    //if (WildMagicOverride()) { return; }
	
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	object oTarget;
	
	int nHD 		= GetHitDice(oNPC);
	int nSTRMod		= GetAbilityModifier(ABILITY_STRENGTH, oNPC);
    int nDC			= 10 +nSTRMod+ (nHD/2);
	
    effect eDown = EffectKnockdown();
    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_WIND);
	
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oNPC);
    
	//Get first target in spell area
	oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget) && oTarget != oNPC)
        {
            //Make a saving throw check
            if(!PRCMySavingThrow(SAVING_THROW_REFLEX, oTarget, nDC))
            {
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDown, oTarget, 5.0);
            }
            //Get next target in spell area
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    }
}
