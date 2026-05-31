//::///////////////////////////////////////////////
//:: Mind Blank
//:: NW_S0_MindBlk.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All allies are granted immunity to mental effects
    in the AOE.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

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

// End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eImm1 = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eImm1, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    effect eSearch;
    int bValid;
    int nDuration = spell.Level;
    float fDelay;
    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, spell.Loc);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, spell.Caster))
        {
        fDelay = GetRandomDelay();
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        eSearch = GetFirstEffect(oTarget);
         //Search through effects
         while(GetIsEffectValid(eSearch))
         {
         bValid = FALSE;
          //Check to see if the effect matches a particular type defined below
          switch(GetEffectType(eSearch))
          {
          case EFFECT_TYPE_DAZED:
          case EFFECT_TYPE_CHARMED:
          case EFFECT_TYPE_SLEEP:
          case EFFECT_TYPE_CONFUSED:
          case EFFECT_TYPE_STUNNED:
          case EFFECT_TYPE_DOMINATED:
          bValid = TRUE;
          break;
          default:
           switch(GetEffectSpellId(eSearch))
           {
           case SPELL_FEEBLEMIND:
           case SPELL_BANE:
           bValid = TRUE;
           break;
           }
          break;
          }
          //Apply damage and remove effect if the effect is a match
          if(bValid)
          {
          RemoveEffect(oTarget,eSearch);
          }
         eSearch = GetNextEffect(oTarget);
         }
        //After effects are removed we apply the immunity to mind spells to the target
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, TurnsToSeconds(nDuration)));
        }
    oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, spell.Loc);
    }
}
