//::///////////////////////////////////////////////
//:: Tyrant Fog Zombie Mist Heartbeat
//:: NW_S1_TyrantFgA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the area around the zombie
    must save or take 1 point of Constitution
    damage.
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
    //if (WildMagicOverride()) { return; }

//:: Declare major variables
	object oNPC		= GetAreaOfEffectCreator();
    object oTarget 	= GetEnteringObject();
    //if (NullMagicOverride(GetArea(oTarget), oTarget, oTarget)) {return;}

    int bAbsent 	= TRUE;
    int nHD 		= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC			= 10 +nCHAMod+ (nHD/2);	
	
	effect eTest;
    effect eCon 	= EffectAbilityDecrease(ABILITY_CONSTITUTION, 1);    
    eCon 			= ExtraordinaryEffect(eCon);
    effect eDur 	= EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink 	= EffectLinkEffects(eCon, eDur);

    if(!GetHasSpellEffect(SPELLABILITY_TYRANT_FOG_MIST, oTarget))
    {
        if(bAbsent == TRUE)
        {
            if(GetIsEnemy(oTarget, oNPC))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_TYRANT_FOG_MIST));
                //Make a saving throw check
                if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_POISON))
                {
                    //Apply the VFX impact and effects
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(5));
                }
            }
        }
    }
}
