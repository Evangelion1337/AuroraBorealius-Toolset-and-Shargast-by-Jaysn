//::///////////////////////////////////////////////
//:: Invisibilty Purge: On Enter
//:: NW_S0_InvPurgeA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
     All invisible creatures in the AOE become
     visible.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
//::March 31: Made it so it will actually remove
//  the effects of Improved Invisibility

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();

    effect eInvis = GetFirstEffect(oTarget);
    int bRemove;
    while(GetIsEffectValid(eInvis))
    {
        switch(GetEffectSpellId(eInvis))
        {
            case SPELL_INVISIBILITY:
            case SPELL_IMPROVED_INVISIBILITY:
            case SPELL_INVISIBILITY_SPHERE:
            case SPELLABILITY_AS_INVISIBILITY:
            case SPELLABILITY_AS_IMPROVED_INVISIBLITY:
            bRemove = TRUE;
            break;
            default:
            bRemove = GetEffectType(eInvis) == EFFECT_TYPE_INVISIBILITY || GetEffectType(eInvis) == EFFECT_TYPE_IMPROVEDINVISIBILITY;
            break;
        }
        if(bRemove)
        {
            if(spellsIsTarget(oTarget,SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            }
            else
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, FALSE));
            }
            //remove invisibility
            RemoveEffect(oTarget, eInvis);
        }
        //Get Next Effect
        eInvis = GetNextEffect(oTarget);
    }
}
