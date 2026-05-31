//::///////////////////////////////////////////////
//:: Death Respawn Penalty Hook
//:: death_respawn
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By:    Dauvis
//:: Created On:    6/26/03
//::
//:: This method applies the respawn death penalty
//:: to the player.  This is the penalty that is
//:: assess after the player respawns and hence
//:: can be avoided with a ressurrection.
//:://////////////////////////////////////////////
#include "death_include"
#include "sql_campaign"

void dhDeathRespawnPenalty(object oPlayer)
{
    // local variables for use in determining
    // the penalty.
    int iLevel = GetHitDice(oPlayer);

    // error checking
    if (!GetIsPC(oPlayer)) return;

    // don't apply penalties to someone who is under minimum level
    if (iLevel < iMinimumDeathLevel) return;

    /********************** Place your code below this line **********************/

    // apply experience penalty
    // You can not lose a level with this system
    // using the calculation method from nw_o0_respawn
    int iCurrent = GetXP(oPlayer);
    int iLost = FloatToInt(IntToFloat(iLevel) * fRespawnExpMultiplier);
    int iMin = ((iLevel * (iLevel - 1)) / 2) * 1000;

    int iNew = iCurrent - iLost;
    if (!bAllowLevelLoss && (iNew < iMin))
       iNew = iMin;
    SetXP(oPlayer, iNew);
    int iActual = (iCurrent - iNew);

    // apply gold penalty
    iLost = FloatToInt(IntToFloat(iLevel) * fRespawnGoldMultiplier);
    AssignCommand(oPlayer, TakeGoldFromCreature(iLost, oPlayer, TRUE));

    // calculate buy back and store it
    int iBuyBack = FloatToInt(IntToFloat(iActual) * fExpBuyMultiplier);
    SQL_SetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iExpBuyBackCost", iBuyBack, oPlayer);
    SQL_SetCampaignInt(dhDeathGetDatabaseName(oPlayer), "iRecoverableExp", iActual, oPlayer);

    // show messages
    DelayCommand(4.0, FloatingTextStrRefOnCreature(58299, oPlayer, FALSE));
    DelayCommand(5.0, FloatingTextStrRefOnCreature(58300, oPlayer, FALSE));
}


