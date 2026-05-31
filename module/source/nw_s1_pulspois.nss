//::///////////////////////////////////////////////
//:: Pulse: Poison
//:: NW_S1_PulsPois
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A wave of energy emanates from the creature which affects
    all within 10ft.  All who make a reflex save are not
    poisoned.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 23, 2000
//:://////////////////////////////////////////////
#include "prc_inc_racial" 
//#include "wm_include"

void main()
{
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	object oTarget;
	
	int nHD 		= GetHitDice(oNPC);
	int nCONMod		= GetAbilityModifier(ABILITY_CONSTITUTION, oNPC);
    int nDC			= 10 +nCONMod+ (nHD/2);
    int nRacial 	= MyPRCGetRacialType(oNPC);
    int nPoison;
	
    float fDelay;
	
    effect ePoison;
	effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_NATURE);

    //Determine the poison type based on the Racial Type and HD
    switch (nRacial)
    {
        case RACIAL_TYPE_OUTSIDER:
            if (nHD <= 9)
            {
                nPoison = POISON_QUASIT_VENOM;
            }
            else if (nHD > 9  && nHD < 13)
            {
                nPoison = POISON_BEBILITH_VENOM;
            }
            else if (nHD >= 13)
            {
                nPoison = POISON_PIT_FIEND_ICHOR;
            }
        break;
        case RACIAL_TYPE_VERMIN:
            if (nHD < 3)
            {
                nPoison = POISON_TINY_SPIDER_VENOM;
            }
            else if (nHD <= 3 && nHD < 6)
            {
                nPoison = POISON_SMALL_SPIDER_VENOM;
            }
            else if (nHD <= 6 && nHD < 9)
            {
                nPoison = POISON_MEDIUM_SPIDER_VENOM;
            }
            else if (nHD <= 9 && nHD < 12)
            {
                nPoison =  POISON_LARGE_SPIDER_VENOM;
            }
            else if (nHD <= 12 && nHD < 15)
            {
                nPoison = POISON_HUGE_SPIDER_VENOM;
            }
            else if (nHD <= 15 && nHD < 18)
            {
                nPoison = POISON_GARGANTUAN_SPIDER_VENOM;
            }
            else if (nHD >= 18)
            {
                nPoison = POISON_COLOSSAL_SPIDER_VENOM;
            }
        break;
        default:
            if (nHD < 3)
            {
                nPoison = POISON_NIGHTSHADE;
            }
            else if (nHD <= 3 && nHD < 6)
            {
                nPoison = POISON_BLADE_BANE;
            }
            else if (nHD <= 6 && nHD < 9)
            {
                nPoison = POISON_BLOODROOT;
            }
            else if (nHD <= 9 && nHD < 12)
            {
                nPoison =  POISON_LARGE_SPIDER_VENOM;
            }
            else if (nHD <= 12 && nHD < 15)
            {
                nPoison = POISON_LICH_DUST;
            }
            else if (nHD <= 15 && nHD < 18)
            {
                nPoison = POISON_DARK_REAVER_POWDER;
            }
            else if (nHD >= 18 )
            {
                nPoison = POISON_BLACK_LOTUS_EXTRACT;
            }
        break;
    }
    
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oNPC);
    
	//Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != oNPC)
        {
            if(!GetIsReactionTypeFriendly(oTarget))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_PULSE_POISON));
                //Determine effect delay
                fDelay = GetDistanceBetween(oNPC, oTarget)/20;
                ePoison = EffectPoison(nPoison);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(oNPC));
    }
}


