//::///////////////////////////////////////////////
//:: Deadly Swinging Blade Trap
//:: 70_t1_swingdead
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
twice 10d8 damage, reflex save vs DC 30, evasion allowed
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    int nDamage = GetReflexAdjustedDamage(d8(10), oTarget, 30, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);

    if (nDamage > 0)
    {
         ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING), oTarget);
    }

    nDamage = GetReflexAdjustedDamage(d8(10), oTarget, 30, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);

    if (nDamage > 0)
    {
         ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING), oTarget);
    }

    effect eVFX = EffectVisualEffect(VFX_FNF_SWINGING_BLADE);
    location lTarget = GetLocation(oTarget);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lTarget);
    DelayCommand(0.3,ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lTarget));
}
