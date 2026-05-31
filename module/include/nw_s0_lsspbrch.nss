//::///////////////////////////////////////////////
//:: Lesser Spell Breach
//:: NW_S0_LsSpBrch.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes 2 spell protection from an enemy mage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 10, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{

/*
  Spellcast Hook Code
  Added 2003-06-23 by GeorgZ
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

    effect eSR = EffectSpellResistanceDecrease(3);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eVis = EffectVisualEffect(VFX_IMP_BREACH);
    int nCnt, nIdx, nSpell;
    string sFeedback = "<cÍþ>"+GetStringByStrRef(13598)+"</c> : <c›þþ>"+GetName(spell.Target)+"</c> : <cÍþ>";
    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Search through and remove protections.
        while(nCnt <= NW_I0_SPELLS_MAX_BREACH && nIdx < 2)
        {
            nSpell = GetSpellBreachProtection(nCnt);
            if(RemoveProtections(nSpell, spell.Target, nCnt))
            {
                nIdx++;
                sFeedback+= GetStringByStrRef(StringToInt(Get2DAString("spells","Name",nSpell)))+", ";
            }
            nCnt++;
        }
        if(nIdx > 0)
        {
            if(GetIsPC(spell.Target))
            {
                sFeedback = GetStringLeft(sFeedback,GetStringLength(sFeedback)-2)+"</c>";
                SendMessageToPC(spell.Target,sFeedback);
            }
        }
        effect eLink = EffectLinkEffects(eDur, eSR);
        //--------------------------------------------------------------------------
        // This can not be dispelled
        //--------------------------------------------------------------------------
        eLink = ExtraordinaryEffect(eLink);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(10));
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}
