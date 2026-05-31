#include "sql_campaign"
const string SURVIVAL_DB = "Shargast_Survival";
const int HUNGER_MAX = 100;
const int THIRST_MAX = 100;
const int HUNGER_DECREASE_PER_TICK = 4;
const int THIRST_DECREASE_PER_TICK = 6;
const int HUNGER_PENALTY_THRESHOLD = 20;
const int THIRST_PENALTY_THRESHOLD = 20;
const int HUNGER_CRITICAL_THRESHOLD = 10;
const int THIRST_CRITICAL_THRESHOLD = 10;
const int TICK_INTERVAL = 600;

int SV_GetHunger(object oPC)
{
    int n = SQL_GetCampaignInt(SURVIVAL_DB, "HUNGER", oPC);
    if(n == 0) n = HUNGER_MAX;
    return n;
}

int SV_GetThirst(object oPC)
{
    int n = SQL_GetCampaignInt(SURVIVAL_DB, "THIRST", oPC);
    if(n == 0) n = THIRST_MAX;
    return n;
}

void SV_SetHunger(object oPC, int nValue)
{
    SQL_SetCampaignInt(SURVIVAL_DB, "HUNGER", nValue, oPC);
}

void SV_SetThirst(object oPC, int nValue)
{
    SQL_SetCampaignInt(SURVIVAL_DB, "THIRST", nValue, oPC);
}

void SV_Eat(object oPC, int nFoodValue)
{
    int n = SV_GetHunger(oPC) + nFoodValue;
    if(n > HUNGER_MAX) n = HUNGER_MAX;
    SV_SetHunger(oPC, n);
}

void SV_Drink(object oPC, int nDrinkValue)
{
    int n = SV_GetThirst(oPC) + nDrinkValue;
    if(n > THIRST_MAX) n = THIRST_MAX;
    SV_SetThirst(oPC, n);
}

void SV_ApplyPenalties(object oPC)
{
    int nHunger = SV_GetHunger(oPC);
    int nThirst = SV_GetThirst(oPC);
    int nOldHungerState = GetLocalInt(oPC, "SV_HUNGER_STATE");
    int nOldThirstState = GetLocalInt(oPC, "SV_THIRST_STATE");
    int nNewHungerState = 0;
    int nNewThirstState = 0;

    if(nHunger <= HUNGER_CRITICAL_THRESHOLD)
        nNewHungerState = 2;
    else if(nHunger <= HUNGER_PENALTY_THRESHOLD)
        nNewHungerState = 1;
    else
        nNewHungerState = 0;

    if(nThirst <= THIRST_CRITICAL_THRESHOLD)
        nNewThirstState = 2;
    else if(nThirst <= THIRST_PENALTY_THRESHOLD)
        nNewThirstState = 1;
    else
        nNewThirstState = 0;

    if(nNewHungerState > nOldHungerState)
    {
        if(nNewHungerState == 2)
        {
            FloatingTextStringOnCreature("<cFFFF0000>You are starving! Find food!</c>", oPC, FALSE);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE), oPC, 6.0);
        }
        else if(nNewHungerState == 1)
        {
            FloatingTextStringOnCreature("<cFFFF6600>You are hungry. You should eat.</c>", oPC, FALSE);
        }
    }
    else if(nNewHungerState < nOldHungerState && nNewHungerState == 0)
    {
        FloatingTextStringOnCreature("<cFF00FF00>You are no longer hungry.</c>", oPC, FALSE);
    }

    if(nNewThirstState > nOldThirstState)
    {
        if(nNewThirstState == 2)
        {
            FloatingTextStringOnCreature("<cFF00FFFF>You are dehydrated! Find water!</c>", oPC, FALSE);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE), oPC, 6.0);
        }
        else if(nNewThirstState == 1)
        {
            FloatingTextStringOnCreature("<cFF66CCFF>You are thirsty. You should drink.</c>", oPC, FALSE);
        }
    }
    else if(nNewThirstState < nOldThirstState && nNewThirstState == 0)
    {
        FloatingTextStringOnCreature("<cFF00FF00>You are no longer thirsty.</c>", oPC, FALSE);
    }

    SetLocalInt(oPC, "SV_HUNGER_STATE", nNewHungerState);
    SetLocalInt(oPC, "SV_THIRST_STATE", nNewThirstState);
}

void SV_ShowStatus(object oPC)
{
    int nHunger = SV_GetHunger(oPC);
    int nThirst = SV_GetThirst(oPC);
    string sHunger, sThirst;

    if(nHunger >= 80) sHunger = "Full";
    else if(nHunger >= 50) sHunger = "Satisfied";
    else if(nHunger >= 30) sHunger = "Peckish";
    else if(nHunger >= 15) sHunger = "Hungry";
    else sHunger = "Starving";

    if(nThirst >= 80) sThirst = "Hydrated";
    else if(nThirst >= 50) sThirst = "Satisfied";
    else if(nThirst >= 30) sThirst = "Thirsty";
    else if(nThirst >= 15) sThirst = "Very Thirsty";
    else sThirst = "Dehydrated";

    string sColorH = "<cFF00FF00>";
    string sColorT = "<cFF00FF00>";
    if(nHunger <= HUNGER_CRITICAL_THRESHOLD) sColorH = "<cFFFF0000>";
    else if(nHunger <= HUNGER_PENALTY_THRESHOLD) sColorH = "<cFFFF6600>";
    if(nThirst <= THIRST_CRITICAL_THRESHOLD) sColorT = "<cFFFF0000>";
    else if(nThirst <= THIRST_PENALTY_THRESHOLD) sColorT = "<cFF66CCFF>";

    FloatingTextStringOnCreature("<cFFFFFF00>--- Survival Status ---</c>", oPC, FALSE);
    FloatingTextStringOnCreature("Hunger: " + sColorH + sHunger + "</c> (" + IntToString(nHunger) + "/100)", oPC, FALSE);
    FloatingTextStringOnCreature("Thirst: " + sColorT + sThirst + "</c> (" + IntToString(nThirst) + "/100)", oPC, FALSE);
}

int SV_GetTick(object oPC)
{
    return GetLocalInt(oPC, "SV_TICK_COUNTER");
}

void SV_SetTick(object oPC, int nValue)
{
    SetLocalInt(oPC, "SV_TICK_COUNTER", nValue);
}
