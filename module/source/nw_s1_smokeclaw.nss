//::///////////////////////////////////////////////
//:: Smoke Claws
//:: NW_S1_SmokeClaw
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If a Belker succeeds at a touch attack the
    target breaths in part of the Belker and suffers
    3d4 damage per round until a Fortitude save is
    made.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 23 , 2001
//:://////////////////////////////////////////////
#include "NW_I0_SPELLS"
#include "prc_inc_spells"
//#include "wm_include"

void main()
{
	//if (WildMagicOverride()) { return; }
	
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	object oTarget 	= PRCGetSpellTargetObject();
	
    int nHD 		= GetHitDice(oNPC);
	int nCONMod		= GetAbilityModifier(ABILITY_CONSTITUTION, oNPC);
    int nDC			= 10 +nCONMod+ (nHD/2);	
    
    int bSave = FALSE;
	
    effect eVis = EffectVisualEffect(VFX_COM_BLOOD_REG_RED);
    effect eSmoke;
    float fDelay = 0.0;
	
    //Make a touch attack
    if(TouchAttackMelee(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            //Make a saving throw check
            while (bSave == FALSE)
            {
                //Make a saving throw check
                if(!/*FortSave*/PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NONE, oNPC, fDelay))
                {
                   bSave = TRUE;
                }
                else
                {
                    //Set damage
                    eSmoke = EffectDamage(d4(3));
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    //Increment the delay
                    fDelay = fDelay + 6.0;
                }
            }
        }
    }
}
