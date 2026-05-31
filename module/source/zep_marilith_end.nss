//File name: zep_marilith_end
//Usage/Description: OnCombatRound End script for Marilith.

#include "zep_inc_scrptdlg"

void main()
{
    object oTarget = GetAttackTarget();
    int nTargetAC = GetAC(oTarget);
    int nRoll = d20();
    int nCrit = FALSE;
    if(nRoll >= 19) //crit on natural 19-20
    {
        if (d20()+8 >nTargetAC)
        {
            nCrit = TRUE;
        }
    }
    if(nRoll + 8 >= nTargetAC)
    {
        int nDamage = d8() + 2;
        effect eDamage = EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL);
        if(nCrit == TRUE)
        {
            nDamage = d8(2) + 4;
            eDamage = EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL);
        }
        string sMessageToPC = GetStringByStrRef(nZEPMarilithDMG,GENDER_MALE);
        SendMessageToPC(oTarget, sMessageToPC+IntToString(nDamage));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
    }
}
