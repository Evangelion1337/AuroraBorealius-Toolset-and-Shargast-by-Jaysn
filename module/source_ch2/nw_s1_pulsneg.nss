//::///////////////////////////////////////////////
//:: Pulse: Negative
//:: NW_S1_PulsDeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A wave of energy emanates from the creature which affects
    all within 10ft.  Damage can be reduced by half for all
    damaging variants.  Undead are healed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 14, 2000
//:://////////////////////////////////////////////
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
	int nDamage;
	
    float fDelay;
	
    effect eVis = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eVis2 = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eHowl;	
    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE);
	
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oNPC);
	
    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != oNPC)
        {
            //Determine effect delay
            fDelay = GetDistanceBetween(oNPC, oTarget)/20;
            //Roll the amount to heal or damage
            nDamage = d4(nHD);
            //If the target is undead
            if (MyPRCGetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
            {
                //Make a faction check
                if(GetIsFriend(oTarget))
                {
                    //Fire cast spell at event for the specified target
                    SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_PULSE_HOLY, FALSE));
                    //Set heal effect
                    eHowl = EffectHeal(nDamage);
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
            else
            {
                if(!GetIsReactionTypeFriendly(oTarget) && MyPRCGetRacialType(oTarget) != RACIAL_TYPE_UNDEAD)
                {
                    //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
                    nDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_TYPE_NEGATIVE);
                    //Set damage effect
                    eHowl = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
                    if(nDamage > 0)
                    {
                        //Fire cast spell at event for the specified target
                        SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_PULSE_HOLY));
                        //Apply the VFX impact and effects
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                    }
                }
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    }
}
