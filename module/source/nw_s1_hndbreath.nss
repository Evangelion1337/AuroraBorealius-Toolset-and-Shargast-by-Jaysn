//::///////////////////////////////////////////////
//:: Hell Hound Fire Breath
//:: NW_S1_HndBreath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A cone of fire eminates from the hound.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 14, 2001
//:://////////////////////////////////////////////
#include "prc_inc_spells"
//#include "wm_include"

void main()
{
    //if (WildMagicOverride()) { return; }
	
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	object oTarget;
	
    int nHD 		= GetHitDice(oNPC);
	int nCONMod		= GetAbilityModifier(ABILITY_CONSTITUTION, oNPC);
    int nDC			= 10 +nCONMod+ (nHD/2);
    int nDamage 	= d6(2);
	
    float fDelay;
	
    location lTargetLocation = PRCGetSpellTargetLocation();

    effect eCone;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);

    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_HELL_HOUND_FIREBREATH));
			
			//Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
			nDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_TYPE_FIRE);
			
            //Determine effect delay
            fDelay = GetDistanceBetween(oNPC, oTarget)/20;
			
            //Set damage effect
            eCone = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
            if(nDamage > 0)
            {
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eCone, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    }
}



