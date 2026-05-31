//::///////////////////////////////////////////////
//:: Tensor's Transformation
//:: NW_S0_TensTrans.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the caster the following bonuses:
        +1 Attack per 2 levels
        +4 Natural AC
        20 STR and DEX and CON
        1d6 Bonus HP per level
        +5 on Fortitude Saves
        -10 Intelligence
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 26, 2001
//:://////////////////////////////////////////////
//: Sep2002: losing hit-points won't get rid of the rest of the bonuses

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //Declare major variables
    spellsDeclareMajorVariables();

  //----------------------------------------------------------------------------
  // GZ, Nov 3, 2003
  // There is a serious problems with creatures turning into unstoppable killer
  // machines when affected by tensors transformation. NPC AI can't handle that
  // spell anyway, so I added this code to disable the use of Tensors by any
  // NPC.
  //----------------------------------------------------------------------------
  if (!GetIsPC(spell.Target))
  {
      WriteTimestampedLogEntry(GetName(spell.Target) + "[" + GetTag (spell.Target) +"] tried to cast Tensors Transformation. Bad! Remove that spell from the creature");
      return;
  }

  /*
    Spellcast Hook Code
      Added 2003-06-23 by GeorgZ
      If you want to make changes to all spells,
      check x2_inc_spellhook.nss to find out more
    */

    if (!X2PreSpellCastCode())
    {
        return;
    }

    // End of Spell Cast Hook
    int nDuration = spell.Level;
    //Determine bonus HP
    int nHP = MaximizeOrEmpower(6,spell.Level,spell.Meta);

    //Metamagic
    if(spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }
    //Declare effects
    effect eAttack = EffectAttackIncrease(spell.Level/2);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_FORT, 5);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect ePoly = EffectPolymorph(POLYMORPH_TYPE_DOOM_KNIGHT);
    effect eSwing = EffectModifyAttacks(2);

    //Define what bonuses are granted by magic and how large they are
    int nInt = GetAbilityScore(spell.Target, ABILITY_INTELLIGENCE, FALSE) - GetAbilityScore(spell.Target, ABILITY_INTELLIGENCE, TRUE);
    int nWis = GetAbilityScore(spell.Target, ABILITY_WISDOM, FALSE) - GetAbilityScore(spell.Target, ABILITY_WISDOM, TRUE);
    int nCha = GetAbilityScore(spell.Target, ABILITY_CHARISMA, FALSE) - GetAbilityScore(spell.Target, ABILITY_CHARISMA, TRUE);

    effect eInt;
    effect eWis;
    effect eCha;

    //Determine that bonuses are not negative in value
    if (nInt > 0)
         eInt = EffectAbilityIncrease(ABILITY_INTELLIGENCE, nInt);
    if (nWis > 0)
        eWis = EffectAbilityIncrease(ABILITY_WISDOM, nWis);
    if (nCha > 0)
        eCha = EffectAbilityIncrease(ABILITY_CHARISMA, nCha);

    //Link effects
    effect eAbility = EffectLinkEffects(eInt, eWis);
    eAbility = EffectLinkEffects(eAbility, eCha);

    effect eLink = EffectLinkEffects(eAttack, ePoly);

    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eSwing);
    eLink = EffectLinkEffects(eLink, eAbility);

    effect eHP = EffectTemporaryHitpoints(nHP);

    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    //Signal Spell Event
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    ClearAllActions(); // prevents an exploit
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, spell.Target, RoundsToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(nDuration));
}
