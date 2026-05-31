//::///////////////////////////////////////////////
//:: Ferocity 3
//:: NW_S1_Feroc3
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The Dex and Str of the target increases
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 13, 2001
//:://////////////////////////////////////////////

void main()
{
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	
    int nHD 		= GetHitDice(oNPC);
	int nCONMod		= GetAbilityModifier(ABILITY_CONSTITUTION);	//:: Determine the duration by getting the con modifier
	int nIncrease 	= 9;
    int nDuration 	= 1 + nCONMod;
	if(nDuration == 0) { nDuration = 1; }


    effect eDex 	= EffectAbilityIncrease(ABILITY_DEXTERITY, nIncrease);
    effect eStr 	= EffectAbilityIncrease(ABILITY_STRENGTH, nIncrease);
    effect eDur 	= EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink 	= EffectLinkEffects(eStr, eDex);
    eLink 			= EffectLinkEffects(eLink, eDur);
    eLink 			= ExtraordinaryEffect(eLink);	//:: Make effect extraordinary

    //effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    SignalEvent(oNPC, EventSpellCastAt(oNPC, SPELLABILITY_FEROCITY_3, FALSE));
    if (nCONMod > 0)
    {
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oNPC, RoundsToSeconds(nDuration));
        //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF) ;
    }
}
