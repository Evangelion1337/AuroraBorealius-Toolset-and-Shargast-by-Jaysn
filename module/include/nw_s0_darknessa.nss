//::///////////////////////////////////////////////
//:: Darkness: On Enter
//:: NW_S0_DarknessA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a globe of darkness around those in the area
    of effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 28, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- invisibility is granted even casters immune to darkness
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    aoesDeclareMajorVariables();
    effect eInvis = EffectInvisibility(INVISIBILITY_TYPE_DARKNESS);
    effect eDark = EffectDarkness();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eDark, eDur);
    effect eLink2 =  EffectLinkEffects(eInvis, eDur);
    object oTarget = GetEnteringObject();

    // * July 2003: If has darkness then do not put it on it again
    if(GetHasEffect(EFFECT_TYPE_DARKNESS, oTarget))
    {
        return;
    }

    if(oTarget != aoe.Creator)
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
        {
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        }
        else
        {
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, FALSE));
        }
        // Creatures immune to the darkness spell are not affected.
        if(ResistSpell(aoe.Creator,oTarget) != 2)
        {
            //Fire cast spell at event for the specified target
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
        }
    }
    else
    {
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, FALSE));
        //Fire cast spell at event for the specified target
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink2, oTarget);
    }
}
