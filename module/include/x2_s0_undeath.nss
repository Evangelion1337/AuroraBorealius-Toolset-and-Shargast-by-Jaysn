//::///////////////////////////////////////////////
//:: Undeath to Death
//:: X2_S0_Undeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

  This spell slays 1d4 HD worth of undead creatures
  per caster level (maximum 20d4). Creatures with
  the fewest HD are affected first;

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On:  August 13,2003
//:://////////////////////////////////////////////
/*
Patch 1.70

- line of sight wasn't checked, spell now doesn't affect creatures behind walls
- saving throw check occured before SR check
- maximized version of this spell wasn't properly capped
- spell affected the most distant creatures first instead of nearest
- killing method could fail in special case (divine damage immune/resistant undead)
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_toollib"
#include "x2_inc_spellhook"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-07-07 by Georg Zoeller
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();

    // Impact VFX
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_STRIKE_HOLY), spell.Loc);
    TLVFXPillar(VFX_FNF_LOS_HOLY_20, spell.Loc, 3, 0.0);
    effect eDeath = SupernaturalEffect(EffectDeath(FALSE,FALSE));
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);

    // calculation
    int nLevel = spell.Level;
    if (nLevel > 20)
    {
        nLevel = 20;
    }

    int nLow = 9999;
    object oLow;
    // calculate number of hitdice affected with proper metamagic bonuses
    int nHDLeft = MaximizeOrEmpower(4,nLevel,spell.Meta);
    float fDelay;
    int nCurHD;
    object oFirst = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, spell.Loc, TRUE);

    // Only start loop if there is a creature in the area of effect
    if(GetIsObjectValid(oFirst))
    {
        object oTarget = oFirst;
        while (GetIsObjectValid(oTarget) && nHDLeft > 0)
        {
            if (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
            {
                nCurHD = GetHitDice(oTarget);
                if (nCurHD <= nHDLeft)
                {
                    // ignore creatures already affected
                    if(GetLocalInt(oTarget,"X2_EBLIGHT_I_AM_DEAD") == 0 && !GetPlotFlag(oTarget) && !GetIsDead(oTarget))
                    {
                        if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, spell.Caster))
                        {
                            // store the creature with the lowest HD
                            if (GetHitDice(oTarget) < nLow)//remove <= in order to affect nearest first
                            {
                                nLow = GetHitDice(oTarget);
                                oLow = oTarget;
                            }
                        }
                    }
                }
            }

            // Get next target
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 20.0, spell.Loc, TRUE);

            // End of cycle, time to kill the lowest creature
            if (!GetIsObjectValid(oTarget))
            {
                // we have a valid lowest creature we can affect with the remaining HD
                if (GetIsObjectValid(oLow) && nHDLeft >= nLow)
                {
                    SignalEvent(oLow, EventSpellCastAt(spell.Caster, spell.Id));
                    SetLocalInt(oLow, "X2_EBLIGHT_I_AM_DEAD", TRUE);
                    //scale delay by distance from epicenter
                    fDelay = GetDelayByRange(0.2,1.4,GetDistanceBetweenLocations(spell.Loc, GetLocation(oLow)),20.0);
                    if(!MyResistSpell(spell.Caster, oLow, fDelay))
                    {
                       if(!MySavingThrow(SAVING_THROW_WILL,oLow,spell.DC,SAVING_THROW_TYPE_NONE,spell.Caster,fDelay))
                       {
                           DelayCommand(fDelay+0.5,ApplyEffectToObject(DURATION_TYPE_INSTANT,eDeath,oLow));
                           DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oLow));
                       }
                       else
                       {
                           DelayCommand(0.1,DeleteLocalInt(oLow,"X2_EBLIGHT_I_AM_DEAD"));
                       }
                    }
                    else
                    {//1.0 was too long, if there would be two casters casting in the same moment, it could cause errors
                          DelayCommand(0.1,DeleteLocalInt(oLow,"X2_EBLIGHT_I_AM_DEAD"));
                    }
                    // decrement remaining HD
                    nHDLeft -= nLow;
                    // restart the loop
                    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, spell.Loc, TRUE);
                }
                // reset counters
                oLow = OBJECT_INVALID;
                nLow = 9999;
            }
        }
    }
}
