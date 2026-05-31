//::///////////////////////////////////////////////
//:: Dom Queron's Effect Toolbox
//:: gzinc_effecttool
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Dom Queron
//:: Created On: 06-13-2002
//:://////////////////////////////////////////////
#include "inc_utility"
#include "nw_i0_generic"

/*
    -------------------------
    INTERFACE
    -------------------------
                              */

// Detect Effect Function
int GZHasNegativeEffects(object oPC);
int GZGetIsBlindOrDeaf(object oPC);
int GZGetIsDamaged(object oPC);
int GZGetHasAbilityDamage(object oPC);
int GZGetIsPoisoned(object oPC);
int GZGetIsDiseased(object oPC);
int GZGetIsCursed(object oPC);
int GZGetIsPolymorphed(object oPC);
int GZHasNegativeLevels(object oPC);


// Remove effect functions
void GZRemovePhysicalDamage(object oPC);
void GZRemoveDisease(object oPC);
void GZRemoveBlindOrDeafness(object oPC);
void GZRemovePoison(object oPC);
void GZRemoveCurse(object oPC);
void GZRemoveAbilityDamage(object oPC);
void GZRemoveNegativeLevels(object oPC);
void GZRemoveAllNegativeEffects(object oPC);

void GZSetUpHealer(object oModule);

/*
    -------------------------
    IMPLEMENTATION
    -------------------------
                              */


/* --== Effect Detection Functions ==-- */

int GZHasNegativeEffects(object oPC)
{
    int bNeg = (GZGetHasAbilityDamage(oPC) ||GZGetIsBlindOrDeaf(oPC) || GZGetIsCursed (oPC) || GZGetIsDamaged(oPC) || GZGetIsDiseased(oPC)|| GZGetIsPoisoned(oPC) || GZGetIsPolymorphed(oPC) || GZHasNegativeLevels(oPC));
    return bNeg;
}

int GZGetIsBlindOrDeaf(object oPC)
{
    int bBlind = ((PRCGetHasEffect(EFFECT_TYPE_BLINDNESS,oPC) == TRUE) || (PRCGetHasEffect(EFFECT_TYPE_DEAF,oPC)==TRUE));
    return bBlind;
}

int GZGetIsDamaged(object oPC)
{
    int bDamaged = (GetPercentageHPLoss(oPC) <100);
    return bDamaged;
}

int GZGetHasAbilityDamage(object oPC)
{
    int bAbilityDmg = (PRCGetHasEffect(EFFECT_TYPE_ABILITY_DECREASE,oPC) == TRUE);
    return bAbilityDmg;
}

int GZGetIsPoisoned(object oPC)
{
    int bPoisoned = (PRCGetHasEffect(EFFECT_TYPE_POISON,oPC) == TRUE);
    return bPoisoned;
}

int GZGetIsDiseased(object oPC)
{
    int bDiseased = (PRCGetHasEffect(EFFECT_TYPE_DISEASE,oPC) == TRUE);
    return bDiseased;
}

int GZGetIsCursed(object oPC)
{
    int bCursed = (PRCGetHasEffect(EFFECT_TYPE_CURSE,oPC) == TRUE);
    return bCursed;
}

int GZGetIsPolymorphed(object oPC)
{
    int bPoly = (PRCGetHasEffect(EFFECT_TYPE_POLYMORPH,oPC) == TRUE);
    return bPoly;
}

int GZHasNegativeLevels(object oPC)
{
    int bLvl = (PRCGetHasEffect(EFFECT_TYPE_NEGATIVELEVEL,oPC) == TRUE);
    return bLvl;
}



/* --== Effect Removal Functions ==-- */

void GZRemovePhysicalDamage(object oPC)
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints(oPC)), oPC);
}

void GZRemoveDisease(object oPC)
{
    if (GZGetIsDiseased(oPC)) // safety check
    {
        effect eBad = GetFirstEffect(oPC);
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_DISEASE)
                {
                    //Remove effect if it is negative.
                    RemoveEffect(oPC, eBad);
                }
            eBad = GetNextEffect(oPC);
        }


    }
}

void GZRemoveBlindOrDeafness(object oPC)
{
    if (GZGetIsBlindOrDeaf(oPC)) // safety check
    {
        effect eBad = GetFirstEffect(oPC);
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_DEAF ||
                GetEffectType(eBad) == EFFECT_TYPE_BLINDNESS )
                {
                    //Remove effect if it is negative.
                    RemoveEffect(oPC, eBad);
                }
            eBad = GetNextEffect(oPC);
        }
    }
}


void GZRemovePoison(object oPC)
{
    if (GZGetIsPoisoned(oPC)) // safety check
    {
        effect eBad = GetFirstEffect(oPC);
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_POISON)
                {
                    //Remove effect if it is negative.
                    RemoveEffect(oPC, eBad);
                }
            eBad = GetNextEffect(oPC);
        }
    }
}

void GZRemoveCurse(object oPC)
{
    if (GZGetIsCursed(oPC)) // safety check
    {
        effect eBad = GetFirstEffect(oPC);
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_CURSE)
                {
                    //Remove effect if it is negative.
                    RemoveEffect(oPC, eBad);
                }
            eBad = GetNextEffect(oPC);
        }
    }
}

void GZRemoveAbilityDamage(object oPC)
{
    if (GZGetHasAbilityDamage(oPC)) // safety check
    {
        effect eBad = GetFirstEffect(oPC);
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_ABILITY_DECREASE)
                {
                    //Remove effect if it is negative.
                    RemoveEffect(oPC, eBad);
                }
            eBad = GetNextEffect(oPC);
        }
    }
}

void GZRemoveNegativeLevels(object oPC)
{
    if (GZHasNegativeLevels(oPC)) // safety check
    {
        effect eBad = GetFirstEffect(oPC);
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_NEGATIVELEVEL)
                {
                    //Remove effect if it is negative.
                    RemoveEffect(oPC, eBad);
                }
            eBad = GetNextEffect(oPC);
        }
    }

}
/*
    Negative Effect Overkill
    Uses Code from nw_o0_death
*/
void GZRemoveAllNegativeEffects(object oPC)
{
        effect eBad = GetFirstEffect(oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints(oPC)), oPC);

        //Search for negative effects
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_ABILITY_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_AC_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_ATTACK_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SAVING_THROW_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SKILL_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_BLINDNESS ||
                GetEffectType(eBad) == EFFECT_TYPE_DEAF ||
                GetEffectType(eBad) == EFFECT_TYPE_PARALYZE ||
                GetEffectType(eBad) == EFFECT_TYPE_NEGATIVELEVEL)
                {
                    //Remove effect if it is negative.
                    RemoveEffect(oPC, eBad);
                }
            eBad = GetNextEffect(oPC);
        }

}

// This function sets the cost of my custom healer services
void GZSetUpHealer(object oModule)
{
    if (GetLocalInt(oModule,"T1_MODULE_HEALERSETUP") == 0)
    {
        SetLocalInt(oModule,"T1_MODULE_HEALER_FULLCHECK",1000);
        SetLocalInt(oModule,"T1_MODULE_HEALER_HEAL",100);
        SetLocalInt(oModule,"T1_MODULE_HEALER_RESLVL",500);
        SetLocalInt(oModule,"T1_MODULE_HEALER_RESAB",200);
        SetLocalInt(oModule,"T1_MODULE_HEALER_DISEASE",80);
        SetLocalInt(oModule,"T1_MODULE_HEALER_BLIND",80);
        SetLocalInt(oModule,"T1_MODULE_HEALER_POISON",80);
        SetLocalInt(oModule,"T1_MODULE_HEALER_CURSE",100);
        SetLocalInt(oModule,"T1_MODULE_HEALERSETUP",TRUE);
    }
}

//::void main (){}
