//::///////////////////////////////////////////////
//:: Player Death Initial Penalty Hook
//:: death_initial
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By:    Dauvis
//:: Created On:    6/26/03
//::
//:: This method applies the initial death penalty
//:: to the player.  The initial penalty is the penalty
//:: that is applied before respawning and hence not
//:: possible to avoid via ressurrection
//:://////////////////////////////////////////////
#include "death_include"

void dhDeathApplyInitialPenalty(object oPlayer)
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
    int iLost = FloatToInt(IntToFloat(iLevel) * fInitExpMultiplier);
    int iMin = ((iLevel * (iLevel - 1)) / 2) * 1000;

    int iNew = iCurrent - iLost;
    if (!bAllowLevelLoss && (iNew < iMin))
       iNew = iMin;
    SetXP(oPlayer, iNew);

    // apply gold penalty
    iLost = FloatToInt(IntToFloat(iLevel) * fInitGoldMultiplier);
    AssignCommand(oPlayer, TakeGoldFromCreature(iLost, oPlayer, TRUE));

    // show messages
    DelayCommand(1.0, FloatingTextStrRefOnCreature(58299, oPlayer, FALSE));
    DelayCommand(2.0, FloatingTextStrRefOnCreature(58300, oPlayer, FALSE));
}


