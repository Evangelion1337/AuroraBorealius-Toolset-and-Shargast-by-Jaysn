//::///////////////////////////////////////////////
//:: Restoration
//:: x2_s0_restother.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes all negative effects unless they come
    from Poison, Disease or Curses.
    Can only be cast on Others - not on oneself.
    Caster takes 5 points of damage when this
    spell is cast.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Jan 3/03
//:://////////////////////////////////////////////
//::

#include "70_inc_spells"
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
    effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION);
    int bValid;
    if (spell.Target != spell.Caster)
    {
        effect eBad = GetFirstEffect(spell.Target);
        //Search for negative effects
        while(GetIsEffectValid(eBad))
        {
            switch(GetEffectType(eBad))
            {
                case EFFECT_TYPE_ABILITY_DECREASE:
                case EFFECT_TYPE_AC_DECREASE:
                case EFFECT_TYPE_ATTACK_DECREASE:
                case EFFECT_TYPE_DAMAGE_DECREASE:
                case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
                case EFFECT_TYPE_SAVING_THROW_DECREASE:
                case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
                case EFFECT_TYPE_SKILL_DECREASE:
                case EFFECT_TYPE_BLINDNESS:
                case EFFECT_TYPE_DEAF:
                case EFFECT_TYPE_PARALYZE:
                case EFFECT_TYPE_NEGATIVELEVEL:
                //Remove effect if it is negative.
                RemoveEffect(spell.Target, eBad);
                break;
            }
            eBad = GetNextEffect(spell.Target);
        }
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_RESTORATION, FALSE));

        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spell.Target);

        //Apply Damage Effect to the Caster
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(5), spell.Caster);
    }
}
