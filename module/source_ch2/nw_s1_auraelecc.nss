//::///////////////////////////////////////////////
//:: Aura of Electricity on Heartbeat
//:: NW_S1_AuraElecC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Prolonged exposure to the aura of the creature
    causes electrical damage to all within the aura.
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
    int nHD		= GetHitDice(oNPC);
	int nZap	= 1 + (nHD / 3);
	int nCHAMod	= GetAbilityModifier(ABILITY_CHARISMA, oNPC);
    int nDC		= 10 + nCHAMod + (nHD/2);
    int nDamage;
	
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
	
    //Get first target in spell area
    object oTarget = GetFirstInPersistentObject();
    while (GetIsObjectValid(oTarget))
    {
/*         if (NullMagicOverride(GetArea(oTarget), oTarget, oTarget))
        {
        oTarget = GetNextInPersistentObject(OBJECT_SELF);
        continue;
        } */
        if(GetIsEnemy(oTarget, GetAreaOfEffectCreator()))
        {
            nDamage = d4(nZap);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_AURA_ELECTRICITY));
            //Make a saving throw check
            if(PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_ELECTRICITY))
            {
                nDamage = nDamage / 2;
            }
            eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
            //Apply the VFX impact and effects
            DelayCommand(0.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
            DelayCommand(0.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject();
    }
}
