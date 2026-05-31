//::///////////////////////////////////////////////
//:: Weak Acid Splash Trap
//:: 70_t1_splshweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
2d4 acid, reflex save DC 10 evasion allowed
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    int nDamage = GetReflexAdjustedDamage(d4(2), oTarget, 10, SAVING_THROW_TYPE_TRAP);

    if(nDamage > 0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_ACID), oTarget);
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ACID_S), oTarget);
}
