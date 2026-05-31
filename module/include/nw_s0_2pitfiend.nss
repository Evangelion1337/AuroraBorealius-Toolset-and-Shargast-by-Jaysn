//::///////////////////////////////////////////////
//:: Pit Fiend Payload
//:: NW_S0_2PitFiend
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    DEATH --- DEATH --- BO HA HA HA
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- death immunity doesn't apply anymore, instead poison immunity protect against death
*/

void main()
{
    object oTarget = OBJECT_SELF;

    if(GetIsImmune(oTarget,IMMUNITY_TYPE_POISON,OBJECT_INVALID))//sanity check
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectPoison(0),oTarget);
        return;
    }

    effect eDrain = SupernaturalEffect(EffectDeath());
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDrain, oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}
