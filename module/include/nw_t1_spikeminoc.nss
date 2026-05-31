//::///////////////////////////////////////////////
//:: Minor Spike Trap
//:: NW_T1_SpikeMinC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Strikes the entering object with a spike for
    2d6 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th , 2001
//:://////////////////////////////////////////////

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();

    int nRealDamage = GetReflexAdjustedDamage(d6(2), oTarget, 15, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);
    if (nRealDamage > 0)
    {
        effect eDam = EffectDamage(nRealDamage, DAMAGE_TYPE_PIERCING);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    }
    effect eVis = EffectVisualEffect(VFX_IMP_SPIKE_TRAP);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oTarget));
}
