//::///////////////////////////////////////////////
//:: Wail of the Banshee
//:: NW_S0_WailBansh
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  You emit a terrible scream that kills enemy creatures who hear it
  The spell affects up to one creature per caster level. Creatures
  closest to the point of origin are affected first.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On:  Dec 12, 2000
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.70

- had double death VFX
- spell now affect targets gradually per description
- delay on VFX/effect halved (in order to limit the immunity swap exploit)
- deaf/silenced creatures are not affected anymore (sound descriptor)
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-06-20 by Georg
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

// End of Spell Cast Hook
    effect eWail = EffectVisualEffect(VFX_FNF_WAIL_O_BANSHEES);
    //Apply the FNF VFX impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eWail, spell.Loc);
    //delays the effects of entire spell until banshee VFX screams
    int nCnt = 1;
    int nToAffect = spell.Level;
    float fTargetDistance;
    float fDelay;
    effect eDeath = EffectDeath();
    //Get the closet target from the spell target location
    object oTarget = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, spell.Loc, nCnt);
    while(nCnt <= nToAffect)
    {
        //Get the distance of the target from the center of the effect
        fTargetDistance = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget));
        //Check that the current target is valid and closer than 10.0m
        if(GetIsObjectValid(oTarget) && fTargetDistance <= 10.0)
        {
            if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, spell.Caster))
            {
                //scale delay by distance from epicenter
                fDelay = GetDelayByRange(0.5, 1.5, fTargetDistance, 10.0);//creatures starts dying in 0.5 to 1.5 seconds
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //if target cannot hear the banshee he shouldn't be affected
                if(GetIsAbleToHear(oTarget) && !MyResistSpell(spell.Caster, oTarget, fDelay)) //, 1.0))
                {
                    //Make a fortitude save to avoid death
                    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, spell.DC, SAVING_THROW_TYPE_DEATH, spell.Caster, fDelay)) //, OBJECT_SELF, 3.0))
                    {
                        //Apply the death effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget)); // no delay
                    }
                }
            }
        }
        else
        {
            //Kick out of the loop
            break;
        }
        //Increment the count of creatures targeted
        nCnt++;
        //Get the next closest target in the spell target location.
        oTarget = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, spell.Loc, nCnt);
    }
}
