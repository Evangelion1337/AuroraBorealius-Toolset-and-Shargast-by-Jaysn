// Tag-Based Item Script - Harm 5% On Hit
//:://////////////////////////////////////////////////////////
#include "x2_inc_switches"
#include "nw_i0_spells"
#include "prc_inc_spells"

// This is the main function for the tag-based script.
void main()
{ if( GetUserDefinedItemEventNumber() == X2_ITEM_EVENT_ONHITCAST)
  { // The item's OnHitCastSpell Unique OnHit power was just triggerred.
    object oWielder = OBJECT_SELF;            		// weapon wielder/armor wearer
    object oTarget  = PRCGetSpellTargetObject(); 	// weapon target/armor attacker
    object oItem    = PRCGetSpellCastItem();     	// the item with the OnHitCast property on it.
    if( !GetIsObjectValid( oTarget) || !GetIsObjectValid( oItem))
    { SetExecutedScriptReturnValue( X2_EXECUTE_SCRIPT_CONTINUE);
      return;
    }

    // Check for harm effect- 5% chance
    if( d100() <= 5)
    { // Harm triggered, apply the spell effects.
      if( MyPRCGetRacialType( oTarget) == RACIAL_TYPE_UNDEAD)
      { // Against Undead creatures it heals them.
        effect eHeal = EffectHeal( GetMaxHitPoints( oTarget) -GetCurrentHitPoints( oTarget));
        eHeal = EffectLinkEffects( eHeal, EffectVisualEffect( VFX_IMP_HEALING_G));
        ApplyEffectToObject( DURATION_TYPE_INSTANT, eHeal, oTarget);
        SignalEvent( oTarget, EventSpellCastAt( oWielder, SPELL_HARM, FALSE));
      }
      else if( !GetIsReactionTypeFriendly( oTarget))
      { // Against other racial types it harms them
        if( !PRCDoResistSpell( oWielder, oTarget))
        { // If he doesn't resist the spell, it does his current hit points less 1d4 negative energy
          effect eHarm = EffectDamage( GetCurrentHitPoints( oTarget) -d4(), DAMAGE_TYPE_NEGATIVE);
          eHarm = EffectLinkEffects( eHarm, EffectVisualEffect( VFX_IMP_HARM));
          DelayCommand( 1.0, ApplyEffectToObject( DURATION_TYPE_INSTANT, eHarm, oTarget));
        }
        SignalEvent( oTarget, EventSpellCastAt( oWielder, SPELL_HARM));
      }
    }

    SetExecutedScriptReturnValue( X2_EXECUTE_SCRIPT_END);
    return;
  }
  SetExecutedScriptReturnValue( X2_EXECUTE_SCRIPT_CONTINUE);
}
