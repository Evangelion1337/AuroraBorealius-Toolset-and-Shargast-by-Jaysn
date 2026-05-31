//::///////////////////////////////////////////////
//:: Aura of Menace On Enter
//:: NW_S1_AuraMencA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura all those that fail
    a will save are stricken with Doom.
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
	object oNPC		= GetAreaOfEffectCreator();
    object oTarget 	= GetEnteringObject();
	
    //if (NullMagicOverride(GetArea(oTarget), oTarget, oTarget)) {return;}
    
	int nDuration 	= 1 + (GetHitDice(oNPC)/3);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
	int nDC 		= 10 +nCHAMod+ (GetHitDice(oNPC)/2);
	int nLevel 		= GetCasterLevel(OBJECT_SELF);
    int nMetaMagic 	= PRCGetMetaMagicFeat();
	
    effect eVis 	= EffectVisualEffect(VFX_IMP_DOOM);
    effect eLink 	= CreateDoomEffectsLink();

    if(GetIsEnemy(oTarget, GetAreaOfEffectCreator()))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_AURA_MENACE));
        //Spell Resistance and Saving throw
        if (!/*Will Save*/ PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink , oTarget, TurnsToSeconds(nDuration));
        }
    }
}
