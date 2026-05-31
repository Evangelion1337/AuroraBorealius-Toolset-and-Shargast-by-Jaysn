//::///////////////////////////////////////////////
//:: Poison System includes for Ravages
//:: inc_ravage
//::///////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 10.01.2005
//:://////////////////////////////////////////////

#include "prc_alterations"

// Calculates the amount of extra ability damage ravages cause:
//   Charisma bonus, if any
//   +1 if undead
//   +1 if elemental
//   +2 if outsider
//   +2 if cleric
int GetRavageExtraDamage(object oTarget)
{
    int nRacial = MyPRCGetRacialType(oTarget);
    int nExtra = GetAbilityModifier(ABILITY_CHARISMA, oTarget);
        nExtra = (nExtra > 0) ? nExtra : 0;
    if ( nRacial == RACIAL_TYPE_UNDEAD)    nExtra++;
    if ( nRacial == RACIAL_TYPE_ELEMENTAL) nExtra++;
    if ( nRacial == RACIAL_TYPE_OUTSIDER)   nExtra+=2;
    if ( GetLevelByClass(CLASS_TYPE_CLERIC,oTarget))  nExtra+=2;


    return nExtra;
}

// Creates the VFX common to all ravages.
// This is used when they deal their damage
effect GetRavageVFX()
{
	//effect eReduce = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
	effect eHoly = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
	//effect eHoly = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
	return eHoly;//EffectLinkEffects(eReduce, eHoly);
}