//::///////////////////////////////////////////////
//:: Death Aftereffects hook
//:: death_aftereff
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By:    Dauvis
//:: Created On:    6/27/03
//::
//:: This function should apply any after effects from
//:: death after the player is either resurrected or
//:: respawns.  This could be used for applying "rez sick"
//:: effect.
//:://////////////////////////////////////////////
#include "death_include"

void dhDeathAfterEffects(object oPlayer, int bRez = FALSE)
{
    // check to see if after effects are active
    if (!bDeathAfterEffects) return;

    /************************ Place your code below this line ************************/
    // Do not apply rez sick to a character under level 6, that just too mean
    if (bRez || GetHitDice(oPlayer) <= 5) return;

    // create the effect
    effect effRezSick = EffectNegativeLevel(1);

    // apply effect to player
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, effRezSick, oPlayer, 300.0);
}

