#include "prc_feat_const"
#include "inc_item_props"
#include "prc_inc_spells"

const string BRUTAL_STRIKE_MODE_VAR = "PRC_BRUTAL_STRIKE_MODE";

int _prc_inc_hextor_BrutalStrikeFeatCount(object oPC)
{
    if(GetHasFeat(FEAT_BSTRIKE_12, oPC))
        return 12;
    else if (GetHasFeat(FEAT_BSTRIKE_11, oPC))
        return 11;
    else if (GetHasFeat(FEAT_BSTRIKE_10, oPC))
        return 10;
    else if (GetHasFeat(FEAT_BSTRIKE_9, oPC))
        return 9;
    else if (GetHasFeat(FEAT_BSTRIKE_8, oPC))
        return 8;
    else if (GetHasFeat(FEAT_BSTRIKE_7, oPC))
        return 7;
    else if (GetHasFeat(FEAT_BSTRIKE_6, oPC))
        return 6;
    else if (GetHasFeat(FEAT_BSTRIKE_5, oPC))
        return 5;
    else if (GetHasFeat(FEAT_BSTRIKE_4, oPC))
        return 4;
    else if (GetHasFeat(FEAT_BSTRIKE_3, oPC))
        return 3;
    else if (GetHasFeat(FEAT_BSTRIKE_2, oPC))
        return 2;
    else if (GetHasFeat(FEAT_BSTRIKE_1, oPC))
        return 1;

    return 0;
}

void _prc_inc_hextor_ApplyBrutalStrike(object oPC, int nBonus)
{
    object oWeap = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (!GetIsObjectValid(oWeap))
    {
        oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oPC);
        if (!GetIsObjectValid(oWeap))
        {
            oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oPC);
            if (!GetIsObjectValid(oWeap))
                oWeap = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oPC);
        }
    }
    int nDamageType = (!GetIsObjectValid(oWeap)) ? DAMAGE_TYPE_BLUDGEONING : GetItemDamageType(oWeap);

    effect eBrutalStrike;
    if (GetLocalInt(oPC, BRUTAL_STRIKE_MODE_VAR))
        eBrutalStrike = EffectAttackIncrease(nBonus);
    else
        eBrutalStrike = EffectDamageIncrease(nBonus, nDamageType);
    eBrutalStrike = ExtraordinaryEffect(eBrutalStrike);
    
    PRCRemoveEffectsFromSpell(oPC, SPELL_HEXTOR_DAMAGE);
    PRCRemoveEffectsFromSpell(oPC, SPELL_HEXTOR_MODE);

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eBrutalStrike, oPC);
}
