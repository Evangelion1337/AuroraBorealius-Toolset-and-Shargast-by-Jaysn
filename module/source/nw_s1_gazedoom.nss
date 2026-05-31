//::///////////////////////////////////////////////
//:: Gaze of Doom
//:: NW_S1_GazeDoom.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If the target fails a save they recieve a -2
    penalty to all saves, attack rolls, damage and
    skill checks for the duration of the spell.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 22, 2001
//:://////////////////////////////////////////////
#include "prc_inc_spells"
#include "NW_I0_SPELLS"
//#include "wm_include"
#include "x0_i0_match"

void main()
{
//--------------------------------------------------------------------------
// Make sure we are not blind
//--------------------------------------------------------------------------
    if (PRCGetHasEffect(EFFECT_TYPE_BLINDNESS, OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(84530, OBJECT_SELF, FALSE);
        return;
    }
	
    //if (WildMagicOverride()) { return; }
	
//:: Declare major variables
	object oNPC		= OBJECT_SELF;
	object oTarget;
	
    int nHD 		= GetHitDice(oNPC);
	int nCHAMod		= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC			= 10 +nCHAMod+ (nHD/2);	
    int nDuration 	= 1 + (nHD / 3);
	if(nDuration == 0) { nDuration = 1; }	
	
    location lTargetLocation = PRCGetSpellTargetLocation();
	
    effect eVis 	= EffectVisualEffect(VFX_IMP_DOOM);
    effect eSaves 	= EffectSavingThrowDecrease(SAVING_THROW_ALL, 2);
    effect eAttack 	= EffectAttackDecrease(2);
    effect eDamage 	= EffectDamageDecrease(2);
    effect eSkill 	= EffectSkillDecrease(SKILL_ALL_SKILLS, 2);
    effect eDur 	= EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink 	= EffectLinkEffects(eAttack, eDamage);
    eLink 			= EffectLinkEffects(eLink, eSaves);
    eLink 			= EffectLinkEffects(eLink, eSkill);
    eLink 			= EffectLinkEffects(eLink, eDur);

    oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 10.0, PRCGetSpellTargetLocation());
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget) && oTarget != oNPC)
        {
            if(oTarget != oNPC)
            {
                SignalEvent(oTarget, EventSpellCastAt(oNPC, SPELLABILITY_GAZE_DOOM));
                //Spell Resistance and Saving throw
                if (!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC))
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink , oTarget, RoundsToSeconds(nDuration));
                }
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 10.0, PRCGetSpellTargetLocation());
    }
}
