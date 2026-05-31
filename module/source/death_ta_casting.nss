//::///////////////////////////////////////////////
//:: Healer perform recovery
//:: death_ta_casting
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By:    Dauvis
//:: Created On:    6/28/03
//::
//:: This function will perform the recovery on the
//:: player.  If the player does not have enough gold,
//:: it will return FALSE to indicate to the conversation
//:: that fact.  Otherwise, it will perform the recovery
//:: and return TRUE
//:://////////////////////////////////////////////
#include "death_include"
#include "sql_campaign"

int StartingConditional()
{
    object oPlayer = GetPCSpeaker();
    int iType;

    // get the gold and exp
    int iGold = SQL_GetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iExpBuyBackCost", oPlayer);
    int iExp = SQL_GetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iRecoverableExp", oPlayer);

    // test to see if player has enough gold
    int iPlayerGold = GetGold(oPlayer);
    if (iPlayerGold < iGold) {
        return FALSE;
    }

    // Glitz & Glamor
    AssignCommand(OBJECT_SELF, ActionCastFakeSpellAtObject(SPELL_RESTORATION, oPlayer));
    effect effPlayer = EffectVisualEffect(VFX_IMP_HEALING_G);
    DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, effPlayer, oPlayer, 0.0));

    // remove "rez sick" if still on player
    effPlayer = GetFirstEffect(oPlayer);
    while (GetIsEffectValid(effPlayer)) {
        iType = GetEffectType(effPlayer);

        if (iType == EFFECT_TYPE_NEGATIVELEVEL) {
            RemoveEffect(oPlayer, effPlayer);
        }
        effPlayer = GetNextEffect(oPlayer);
    }

    // return exp and take gold
    GiveXPToCreature(oPlayer, iExp);
    TakeGoldFromCreature(iGold, oPlayer, TRUE);

    // clear the persistant data
    SQL_SetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iExpBuyBackCost", 0, oPlayer);
    SQL_SetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iRecoverableExp", 0, oPlayer);

    // done
    return TRUE;
}

