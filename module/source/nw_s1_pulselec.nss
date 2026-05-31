//::///////////////////////////////////////////////
//:: Pulse: Lightning
//:: NW_S0_CallLghtn.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within 10ft of the creature take
    1d6 per HD up to 10d6
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 22, 2001
//:://////////////////////////////////////////////
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
    int nDC			= 10 +nCHAMod+ (nHD/2);	
    int nDamage;
	
    effect eVis 		= EffectVisualEffect(VFX_IMP_LIGHTNING_S);
	effect eLightning 	= EffectBeam(VFX_BEAM_LIGHTNING, oNPC, BODY_NODE_CHEST);
    effect eHowl 		= EffectVisualEffect(VFX_IMP_PULSE_COLD);
	
    DelayCommand(0.5, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eHowl, GetLocation(oNPC)));

    float fDelay;

    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != oNPC)
        {
            if(!GetIsReactionTypeFriendly(oTarget))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_PULSE_LIGHTNING));
                //Roll the damage
                nDamage = d6(nHD);
                //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
                nDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_TYPE_ELECTRICITY);
                //Determine effect delay
                fDelay = GetDistanceBetween(oNPC, oTarget)/20;
                eHowl = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
                if(nDamage > 0)
                {
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLightning,oTarget, 0.5));
                }
             }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    }
}

