//::///////////////////////////////////////////////
//:: Bolt: Disease
//:: NW_S1_BltDisease
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature must make a ranged touch attack to infect
    the target with a disease.  The disease used
    is chosen based upon the racial type of the
    caster.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 11 , 2001
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
	int nRacial 	= MyPRCGetRacialType(oNPC);
    int nDisease;
	
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_BOLT_DISEASE));

    //Here we use the racial type of the attacker to select an
    //appropriate disease.
    switch (nRacial)
    {
        case RACIAL_TYPE_VERMIN:
            nDisease = DISEASE_VERMIN_MADNESS;
        break;
        case RACIAL_TYPE_UNDEAD:
            nDisease = DISEASE_FILTH_FEVER;
        break;
        case RACIAL_TYPE_OUTSIDER:
            if(GetTag(oNPC) == "NW_SLAADRED")
            {
                nDisease = DISEASE_RED_SLAAD_EGGS;
            }
            else
            {
                nDisease = DISEASE_DEMON_FEVER;
            }
        break;
        case RACIAL_TYPE_MAGICAL_BEAST:
            nDisease = DISEASE_SOLDIER_SHAKES;
        break;
        case RACIAL_TYPE_ABERRATION:
            nDisease = DISEASE_BLINDING_SICKNESS;
        break;
        default:
            nDisease = DISEASE_SOLDIER_SHAKES;
        break;
    }
    //Assign effect and chosen disease
    effect eBolt = EffectDisease(nDisease);
    //Make the ranged touch attack.
    if (TouchAttackRanged(oTarget))
    {
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eBolt, oTarget);
    }
}
