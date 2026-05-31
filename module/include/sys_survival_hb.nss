#include "sv_core"

void main()
{
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        if(!GetIsDM(oPC))
        {
            int nTick = SV_GetTick(oPC);
            nTick++;
            if(nTick >= TICK_INTERVAL)
            {
                int nHunger = SV_GetHunger(oPC) - HUNGER_DECREASE_PER_TICK;
                int nThirst = SV_GetThirst(oPC) - THIRST_DECREASE_PER_TICK;
                if(nHunger < 0) nHunger = 0;
                if(nThirst < 0) nThirst = 0;
                SV_SetHunger(oPC, nHunger);
                SV_SetThirst(oPC, nThirst);
                SV_ApplyPenalties(oPC);
                SV_SetTick(oPC, 0);
            }
            else
            {
                SV_SetTick(oPC, nTick);
            }
        }
        oPC = GetNextPC();
    }
}
