///////////////////////////////////////////////////////////////////////////
//
// DoEnergyImmunity - Apply a 24 hour immunity to one element to the
// target.
//		nDamageType - the damage type (DAMAGE_TYPE_xxx) to be immune to
//		nVfx - The visual effect to use at cast time.
//
///////////////////////////////////////////////////////////////////////////

#include "prc_inc_spells"

void DoEnergyImmunity (int nDamageType, int nVfx)
{
    PRCSetSchool(SPELL_SCHOOL_TRANSMUTATION);

    object oTarget = PRCGetSpellTargetObject();

    // Determine the duration
    float fDuration = PRCGetMetaMagicDuration(HoursToSeconds(24));

    // Build a list of the duration effects which includes the actually immunity
    // effect and all visual effects.
    effect eList = EffectDamageResistance(nDamageType, 9999, 0);
    effect eDur = EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS);
    eList = EffectLinkEffects(eList, eDur);
    eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    eList = EffectLinkEffects(eList, eDur);

    // Fire cast spell at event for the specified target
    PRCSignalSpellEvent(oTarget, FALSE, SPELL_ENERGY_IMMUNITY);

    SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eList, oTarget, fDuration, TRUE, -1, PRCGetCasterLevel(OBJECT_SELF));
    SPApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nVfx), oTarget);

    PRCSetSchool();
}

// Test main
//void main(){}
