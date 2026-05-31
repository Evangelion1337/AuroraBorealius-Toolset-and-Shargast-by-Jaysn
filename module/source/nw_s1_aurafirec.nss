//::///////////////////////////////////////////////
//:: Aura of Fire on Heartbeat
//:: NW_S1_AuraFireC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Prolonged exposure to the aura of the creature
    causes fire damage to all within the aura.
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
	object oNPC	= GetAreaOfEffectCreator();
	object oTarget = GetFirstInPersistentObject();	//:: Get first target in spell area
	
    int nHD 	= GetHitDice(oNPC);
	int nCHAMod	= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nBurn 	= 1 + (nHD/3);
    int nDC		= 10 +nCHAMod+ (nHD/2);
    int nDamage;
    int nDamSave;
    
	effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
    
	while(GetIsObjectValid(oTarget))
    {
/*         if (NullMagicOverride(GetArea(oTarget), oTarget, oTarget))
        {
        oTarget = GetNextInPersistentObject(OBJECT_SELF);
        continue;
        } */
        if(GetIsEnemy(oTarget, GetAreaOfEffectCreator()))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(GetAreaOfEffectCreator(), SPELLABILITY_AURA_FIRE));
            //Roll damage
            nDamage = d4(nBurn);
            //Make a saving throw check
            if(PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_FIRE))
            {
                nDamage = nDamage / 2;
            }
            //Set the damage effect
            eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject();
    }
}
