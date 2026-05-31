//::///////////////////////////////////////////////
//:: Epic Acid Splash Trap
//:: 70_t1_splshepic
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
16d8 acid, reflex save DC 30 evasion allowed
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    int nDamage = GetReflexAdjustedDamage(d8(16), oTarget, 30, SAVING_THROW_TYPE_TRAP);

    if(nDamage > 0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_ACID), oTarget);
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ACID_S), oTarget);
}
