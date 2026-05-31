//::///////////////////////////////////////////////
//:: Aura of the Unnatural On Enter
//:: NW_S1_AuraMencA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura all animals are struck with
    fear.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
#include "NW_I0_SPELLS"
//#include "wm_include"
#include "prc_inc_spells"
void main()
{
//:: Declare major variables
	object oNPC 	= GetAreaOfEffectCreator();
    effect eVis 	= EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eFear 	= EffectFrightened();
    effect eLink 	= EffectLinkEffects(eVis, eFear);
    object oTarget 	= GetEnteringObject();
		
    //if (NullMagicOverride(GetArea(oTarget), oTarget, oTarget)) {return;}
	
    int nDuration 	= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nRacial 	= GetRacialType(oTarget);
    int nDC 		= 10 + nCHAMod + (GetHitDice(oNPC)/2);
	
    if(GetIsEnemy(oTarget))
    {
        nDuration = (nDuration / 3) + 1;
        //Make a saving throw check
        if(nRacial == RACIAL_TYPE_ANIMAL)
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(GetAreaOfEffectCreator(), SPELLABILITY_AURA_UNNATURAL));
            //if (!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_FEAR)) //:: This ability only affects animals & they don't get a save.
            //{
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
            //}
        }
    }
}