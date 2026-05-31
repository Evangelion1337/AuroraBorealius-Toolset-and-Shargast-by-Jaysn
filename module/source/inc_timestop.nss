
void DoTimestopEquip(object oPC, object oItem);
void DoTimestopUnEquip(object oPC, object oItem);
void ApplyTSToObject(object oTarget);
void RemoveTSFromObject(object oTarget);

#include "prc_x2_itemprop"
#include "prc_inc_switch"
#include "inc_prc_npc"
//#include "inc_utility"

void RemoveTimestopEquip()
{
    int i;
    for (i=0;i<18;i++)
    {
        IPRemoveMatchingItemProperties(GetItemInSlot(i), ITEM_PROPERTY_NO_DAMAGE, DURATION_TYPE_TEMPORARY);
    }
}

void DoTimestopEquip(object oPC, object oItem)
{
    if(GetPRCSwitch(PRC_TIMESTOP_NO_HOSTILE))
    {
        if(GetHasSpellEffect(SPELL_TIME_STOP, oPC)
        || GetHasSpellEffect(4032, oPC)
        || GetHasSpellEffect(14236, oPC))
            AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyNoDamage(), oItem, 9999.0);
        /*else if(GetHasSpellEffect(POWER_ID, oPC))
        {
            AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyNoDamage(), oItem, 9999.0);
            //stuff for AC negation
        }*/
    }
}

void DoTimestopUnEquip(object oPC, object oItem)
{
    if(GetPRCSwitch(PRC_TIMESTOP_NO_HOSTILE))
    {
        if(GetHasSpellEffect(SPELL_TIME_STOP, oPC)
        || GetHasSpellEffect(4032, oPC)
        || GetHasSpellEffect(14236, oPC))
            IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_NO_DAMAGE, DURATION_TYPE_TEMPORARY);
        /*else if(GetHasSpellEffect(POWER_ID, oPC))
        {
            AddItemProperty(DURATION_TYPE_TEMPORARY, ItemPropertyNoDamage(), oItem, 9999.0);
            //stuff for AC negation removal
        }*/
    }
}

void ApplyTSToObject(object oTarget)
{
    effect eTS =  EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION);
    effect eCSP = EffectCutsceneParalyze();
    effect eLink = EffectLinkEffects(eTS, eCSP);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
    if(GetIsPC(oTarget) && GetPRCSwitch(PRC_TIMESTOP_BLANK_PC))
        BlackScreen(oTarget);
    AssignCommand(oTarget, ClearAllActions(FALSE));
    SetCommandable(FALSE, oTarget);
}

void RemoveTSFromObject(object oTarget)
{
    effect eTest = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eTest))
    {
        int nSpellId = GetEffectSpellId(eTest);
        if(nSpellId == SPELL_TIME_STOP
        || nSpellId == 4032  //epic TS
        || nSpellId == 14205 // POWER_TEMPORALACCELERATION
        || nSpellId == 17366 // MOVE_DM_MOMENT_ALACRITY
        || nSpellId == 17511 // MOVE_WR_WHITE_RAVEN_TACTICS
        )
            RemoveEffect(oTarget, eTest);
        eTest = GetNextEffect(oTarget);
    }
    if(GetIsPC(oTarget))
        StopFade(oTarget);
    SetCommandable(TRUE, oTarget);
}
