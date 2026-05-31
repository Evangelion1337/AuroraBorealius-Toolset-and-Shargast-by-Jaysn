//::///////////////////////////////////////////////
//:: Howl: Sonic
//:: NW_S1_HowlSonic
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
    int nDamage;
	int nSonic 		= nHD/4;
    if(nSonic == 0) { nSonic = 1; }	
	
    effect eVis 	= EffectVisualEffect(VFX_IMP_SONIC);
    effect eHowl;
    effect eImpact 	= EffectVisualEffect(VFX_FNF_HOWL_WAR_CRY);
	
    float fDelay;
	
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oNPC);
	
    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oNPC));
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsFriend(oTarget) && oTarget != oNPC)
        {
            fDelay = GetDistanceToObject(oTarget)/20;
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_HOWL_SONIC));
            nDamage = d6(nSonic);
            //Make a saving throw check
            if(PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_SONIC, oNPC, fDelay))
            {
                nDamage = nDamage / 2;
            }
            //Set damage effect
            eHowl = EffectDamage(nDamage, DAMAGE_TYPE_SONIC);
            //Apply the VFX impact and effects
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oNPC));
    }
}