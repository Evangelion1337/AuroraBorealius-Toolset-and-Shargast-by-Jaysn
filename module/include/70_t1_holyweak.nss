//::///////////////////////////////////////////////
//:: Minor Holy Trap
//:: 70_t1_holyweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
3d8 to undead, 1d4 to anyone else, no save allowed
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();

    if (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
    {
        //Apply Holy Damage
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d8(3), DAMAGE_TYPE_DIVINE), oTarget);
    }
    else
    {
        //Apply Holy Damage
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d4(1), DAMAGE_TYPE_DIVINE), oTarget);
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SUNSTRIKE), oTarget);
}
