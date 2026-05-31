//::///////////////////////////////////////////////
//:: Gatestones 1.6
//:: bpm_mod_enter
//:: Copyright (c) 2006 CarfaxAbbey.net
//:://////////////////////////////////////////////
/*
    Hook for OnClientEnter Module Event
*/
//:://////////////////////////////////////////////
//:: Created By: Diavlen <diavlen@carfaxabbey.net>
//:: Created On: 3/24/2004
//:: Updated on: 8/11/2006
//:://////////////////////////////////////////////
#include "prc_inc_spells"

void main() 
{
    object oPC  =   OBJECT_SELF;
	
	int iArcaneCL = GetPrCAdjustedCasterLevelByType(TYPE_ARCANE, oPC, TRUE);

/*     int nWizardLevel    =   GetLevelByClass(CLASS_TYPE_WIZARD)+(GetLevelByClass(CLASS_TYPE_PALE_MASTER)/2);
    int nSorcerLevel    =   GetLevelByClass(CLASS_TYPE_SORCERER)+(GetLevelByClass(CLASS_TYPE_PALE_MASTER)/2);
    int nBardLevel      =   GetLevelByClass(CLASS_TYPE_BARD)+(GetLevelByClass(CLASS_TYPE_PALE_MASTER)/2); */

    // Give the Gatestone Spell to Arcane casters of 25th level
	
    if((iArcaneCL>=25) && !GetIsObjectValid(GetItemPossessedBy(oPC,"spell_gatestone")))
            CreateItemOnObject("spell_gatestone",oPC);
			
/*     if((nWizardLevel>=25) && !GetIsObjectValid(GetItemPossessedBy(oPC,"spell_gatestone")) ||
       (nSorcerLevel>=26) && !GetIsObjectValid(GetItemPossessedBy(oPC,"spell_gatestone")) )
            CreateItemOnObject("spell_gatestone",oPC); */
}
