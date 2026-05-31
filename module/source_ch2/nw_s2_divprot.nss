//::///////////////////////////////////////////////
//:: Divine Protection
//:: NW_S2_DivProt.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Makes the target creature invisible to hostile
    creatures unless they make a Will Save to ignore
    the Sanctuary Effect
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 8, 2002
//:://////////////////////////////////////////////
#include "prc_inc_spells"
//#include "wm_include"
void main()
{
    //if (WildMagicOverride()) { return; }
	
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
    object oTarget = PRCGetSpellTargetObject();
	
    effect eVis 	= EffectVisualEffect(VFX_DUR_SANCTUARY);
    effect eDur 	= EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    int nDC 		= 10 + GetAbilityModifier(ABILITY_CHARISMA) + GetLevelByTypeDivine(oNPC);
    effect eSanc 	= EffectSanctuary(nDC);

    effect eLink = EffectLinkEffects(eVis, eSanc);
    eLink = EffectLinkEffects(eLink, eDur);
    //Fire cast spell at event for the specified target
    SignalEvent(OBJECT_SELF, EventSpellCastAt(oNPC, SPELLABILITY_DIVINE_PROTECTION, FALSE));

    int nDuration = GetLevelByTypeDivine(oNPC);
    //Enter Metamagic conditions
    int nMetaMagic = PRCGetMetaMagicFeat();
    if (nMetaMagic == METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
}

