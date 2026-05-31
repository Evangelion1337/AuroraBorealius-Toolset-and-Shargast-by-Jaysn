//::///////////////////////////////////////////////
//:: Rend OnHit include
//:: inc_rend
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 23.01.2005
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/* Constant defintions                          */
//////////////////////////////////////////////////

const string REND_1ST_HIT_DONE  = "RendingHit1stHit";
const string REND_DONE          = "RendingHitDone";

const string FROST_1ST_HIT_DONE = "FrostRendHit1stHit";
const string FROST_DONE         = "FrostRendHitDone";

const string SPINE_1ST_HIT_DONE = "SpineRendHit1stHit";
const string SPINE_DONE         = "SpineRendHitDone";

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

void DoRend(object oTarget, object oAttacker, object oWeapon);
int GetDamageFromConstant(int nIPConst);

void DoFrostRend(object oTarget, object oAttacker, object oWeapon);

#include "moi_inc_moifunc"
#include "prc_inc_combat"

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

void DoRend(object oTarget, object oAttacker, object oWeapon)
{
    if (DEBUG) DoDebug("DoRend running");
    // Only one rend allowed per round for the sake of clearness
    if(GetLocalInt(oAttacker, REND_DONE))
        return;

    if(GetLocalObject(oAttacker, REND_1ST_HIT_DONE) == oTarget)
    {
        if (DEBUG) DoDebug("DoRend second hit");
        // First, find the weapon base damage
        int nIPConst;
        itemproperty ipCheck = GetFirstItemProperty(oWeapon);
        while(GetIsItemPropertyValid(ipCheck))
        {
            if(GetItemPropertyType(ipCheck) == ITEM_PROPERTY_MONSTER_DAMAGE)
            {
                nIPConst = GetItemPropertyCostTableValue(ipCheck);
                break;
            }
            ipCheck = GetNextItemProperty(oWeapon);
        }

        int nDamage = GetDamageFromConstant(nIPConst);
        int nStrBon = GetAbilityModifier(ABILITY_STRENGTH, oAttacker);
            nStrBon = nStrBon < 0  ? 0 : nStrBon;
            nDamage += nStrBon;
        if (GetLevelByClass(CLASS_TYPE_BLACK_BLOOD_CULTIST, oAttacker) >= 6) nDamage *= 2; 
        if (GetIsMeldBound(oAttacker, MELD_GIRALLON_ARMS) == CHAKRA_ARMS) nDamage *= 2; 
		if (GetHasSpellEffect(VESTIGE_IPOS, oAttacker) >= 6) nDamage *= 2; 
		
        int nDamageType;
        switch(GetBaseItemType(oWeapon))
        {
            case BASE_ITEM_CBLUDGWEAPON:
                nDamageType = DAMAGE_TYPE_BLUDGEONING;
                break;
            case BASE_ITEM_CPIERCWEAPON:
                nDamageType = DAMAGE_TYPE_PIERCING;
                break;
            // Both slashing and slashing & piercing weapons do slashing damage from rend
            // because it's not possible to make the damage be of both types in any
            // elegant way
            case BASE_ITEM_CSLASHWEAPON:
            case BASE_ITEM_CSLSHPRCWEAP:
                nDamageType = DAMAGE_TYPE_SLASHING;
                break;

            default:
                WriteTimestampedLogEntry("Unexpected weapon type in DoRend()!");
                return;
        }

        // Apply damage and VFX
        effect eDamage = EffectDamage(nDamage, nDamageType);
        effect eLink = EffectLinkEffects(eDamage, EffectVisualEffect(VFX_COM_BLOOD_CRT_RED));

        ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);

        // Tell people what happened
        //                            * AttackerName rends TargetName *
        FloatingTextStringOnCreature("* " + GetName(oAttacker) + " " + GetStringByStrRef(0x01000000 + 51197) + " " + GetName(oTarget) + " *", oAttacker, TRUE);

        // Note the rend having happened in the locals
        SetLocalInt(oAttacker, REND_DONE, TRUE);
        DelayCommand(4.5, DeleteLocalInt(oAttacker, REND_DONE));
    }// end if - the target had a local signifying that rend is possible
    else
    {
        SetLocalObject(oAttacker, REND_1ST_HIT_DONE, oTarget);
        if (DEBUG) DoDebug("DoRend first hit");
    }
}

void DoFrostRend(object oTarget, object oAttacker, object oWeapon)
{
    // Only one rend allowed per round for the sake of clearness
    if(GetLocalInt(oAttacker, FROST_DONE))
        return;

    float fDelay1 = 6.0 - (6.0 / GetMainHandAttacks(oAttacker));
    float fDelay2 = 6.0 - 2 * (6.0 - fDelay1);

    if(GetLocalObject(oAttacker, FROST_1ST_HIT_DONE) == oTarget)
    {
        // First, find the weapon base damage
        int nIPConst;
        itemproperty ipCheck = GetFirstItemProperty(oWeapon);
        while(GetIsItemPropertyValid(ipCheck))
        {
            if(GetItemPropertyType(ipCheck) == ITEM_PROPERTY_MONSTER_DAMAGE)
            {
                nIPConst = GetItemPropertyCostTableValue(ipCheck);
                break;
            }
            ipCheck = GetNextItemProperty(oWeapon);
        }


        int nDamage = GetDamageFromConstant(nIPConst);
        int nStrBon = GetAbilityModifier(ABILITY_STRENGTH, oAttacker);
            nStrBon = nStrBon < 0  ? 0 : nStrBon;
           // nDamage += nStrBon;
           // nDamage += FloatToInt(nStrBon/2); //1.5x Strength damage
           nDamage += FloatToInt(nStrBon * 1.5);

        int nDamageType = DAMAGE_TYPE_BLUDGEONING; // It's an unarmed strike, so always bludgeoning for this

        // Apply damage and VFX
        effect eDamage = EffectDamage(nDamage, nDamageType);
        effect eLink = EffectLinkEffects(eDamage, EffectVisualEffect(VFX_IMP_FROST_L));
        eLink = EffectLinkEffects(eLink, EffectDamage(d6(), DAMAGE_TYPE_COLD));

        ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);

        // Tell people what happened
        //                            * AttackerName rends TargetName *
        FloatingTextStringOnCreature("* " + GetName(oAttacker) + " " + GetStringByStrRef(0x01000000 + 51197) + " " + GetName(oTarget) + " *",
                                     oAttacker,
                                     TRUE);

        // Note the rend having happened in the locals
        SetLocalInt(oAttacker, FROST_DONE, TRUE);
        DelayCommand(fDelay2, DeleteLocalInt(oAttacker, FROST_DONE));
    }// end if - the target had a local signifying that rend is possible
    else
    {
        SetLocalObject(oAttacker, FROST_1ST_HIT_DONE, oTarget);
        DelayCommand(fDelay1, DeleteLocalObject(oAttacker, FROST_1ST_HIT_DONE));
    }
}

void DoSpineRend(object oTarget, object oAttacker, object oWeapon)
{
    // Only one rend allowed per round for the sake of clearness
    if(GetLocalInt(oAttacker, SPINE_DONE))
        return;

    float fDelay1 = 6.0 - (6.0 / GetMainHandAttacks(oAttacker));
    float fDelay2 = 6.0 - 2 * (6.0 - fDelay1);

    if(GetLocalObject(oAttacker, SPINE_1ST_HIT_DONE) == oTarget)
    {
        int nStrBon = GetAbilityModifier(ABILITY_STRENGTH, oAttacker);
            nStrBon = nStrBon < 0  ? 0 : nStrBon;
            int nDamage = FloatToInt(nStrBon * 1.5);

        // Apply damage and VFX
        effect eDamage = EffectDamage(nDamage + d6(2), DAMAGE_TYPE_PIERCING);
        effect eLink = EffectLinkEffects(eDamage, EffectVisualEffect(VFX_COM_BLOOD_SPARK_MEDIUM));

        ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);

        // Tell people what happened
        //                            * AttackerName rends TargetName *
        FloatingTextStringOnCreature("* " + GetName(oAttacker) + " " + GetStringByStrRef(0x01000000 + 51197) + " " + GetName(oTarget) + " *", oAttacker, TRUE);

        // Note the rend having happened in the locals
        SetLocalInt(oAttacker, SPINE_DONE, TRUE);
        DelayCommand(fDelay2, DeleteLocalInt(oAttacker, SPINE_DONE));
    }// end if - the target had a local signifying that rend is possible
    else
    {
        SetLocalObject(oAttacker, SPINE_1ST_HIT_DONE, oTarget);
        DelayCommand(fDelay1, DeleteLocalObject(oAttacker, SPINE_1ST_HIT_DONE));
    }
}

int GetDamageFromConstant(int nIPConst)
{
    // First, handle the values outside the main series
    switch(nIPConst)
    {
        case IP_CONST_MONSTERDAMAGE_1d2: return d2(1);
        case IP_CONST_MONSTERDAMAGE_1d3: return d3(1);
        case IP_CONST_MONSTERDAMAGE_1d4: return d4(1);
        case IP_CONST_MONSTERDAMAGE_2d4: return d4(2);
        case IP_CONST_MONSTERDAMAGE_3d4: return d4(3);
        case IP_CONST_MONSTERDAMAGE_4d4: return d4(4);
        case IP_CONST_MONSTERDAMAGE_5d4: return d4(5);
        case IP_CONST_MONSTERDAMAGE_7d4: return d4(7);
    }


    int nDieNum = ((nIPConst - 8) % 10) + 1;

    switch((nIPConst - 8) / 10)
    {
        case 0: return d6(nDieNum);
        case 1: return d8(nDieNum);
        case 2: return d10(nDieNum);
        case 3: return d12(nDieNum);
        case 4: return d20(nDieNum);
    }

    WriteTimestampedLogEntry("Unknown IP_CONST_MONSTERDAMAGE_* constant passed to GetDamageFromConstant()!");
    return 0;
}

//:: void main (){}