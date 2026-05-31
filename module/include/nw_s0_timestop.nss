//::///////////////////////////////////////////////
//:: Time Stop
//:: NW_S0_TimeStop.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All persons in the Area are frozen in time
    except the caster.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- in MP environment, spell affect only current area
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

// End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();
    int nRoll = 1 + d4();

    effect eTime, eVis = EffectVisualEffect(VFX_FNF_TIME_STOP);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(spell.Caster));

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Caster, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    if(GetPCPublicCDKey(GetFirstPC(),FALSE) == "")//SP environment, keep default effect
    {
        eTime = EffectTimeStop();
        //Apply the VFX impact and effects
        DelayCommand(0.75, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTime, spell.Caster, 9.0));
    }
    else//MP environment, use cutscene paralyse for all creatures in caster's area
    {
        eTime = ExtraordinaryEffect(EffectLinkEffects(EffectCutsceneParalyze(), EffectVisualEffect(VFX_DUR_BLUR)));
        int nTh = 1;
        object oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, spell.Caster, nTh);
        while(GetIsObjectValid(oTarget))
        {
            if(oTarget != spell.Caster && !GetIsDM(oTarget))
            {
                DelayCommand(0.75, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTime, oTarget, 9.0));
            }
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, spell.Caster, ++nTh);
        }
    }
}
