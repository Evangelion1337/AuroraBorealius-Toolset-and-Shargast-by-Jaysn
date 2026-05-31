// HCR v3.2.0 - Execute default death script after fireball effects is complete.
//::////////////////////////////////////////////////////////////////////////////
//:: FileName:  NW_S3_BALORDETH
//::////////////////////////////////////////////////////////////////////////////
/*
   Fireball explosion does 50 damage to all within 20ft.
*/
//::////////////////////////////////////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 9, 2002
//::////////////////////////////////////////////////////////////////////////////
#include "NW_I0_SPELLS"
#include "prc_inc_spells"
//::////////////////////////////////////////////////////////////////////////////
void main()
{
  // Declare major variables.
  int nMetaMagic = PRCGetMetaMagicFeat();
  int nDamage;
  float fDelay;
  effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
  effect eDam;

  // Apply the fireball explosion.
  effect eExplode = EffectVisualEffect(VFX_FNF_FIREBALL);
  location lTarget = GetLocation(OBJECT_SELF);
  ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);

  // Cycle through the targets until an invalid object is captured.
  object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
  while (GetIsObjectValid(oTarget))
    {
     // Fire cast spell at event for the specified target.
     SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FIREBALL));

     // Calculate delay based on distance between explosion and the target.
     fDelay = (GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20);
     if (!PRCDoResistSpell(OBJECT_SELF, oTarget, FloatToInt(fDelay)))
       {
        // Adjust damage based on Reflex Save, Evasion and Improved Evasion.
        nDamage = PRCGetReflexAdjustedDamage(50, oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_FIRE);
        if (nDamage > 0)
          {
           // Apply effects to the currently selected target.
           eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
           DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));

           // This visual effect is applied to the target object not the
           // location as above. This visual effect represents the flame that
           // erupts on the target not on the ground.
           DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
          }
       }

     // Select the next target.
     oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    }

  // HCR 3.0 - Call default death script.
  ExecuteScript("nw_c2_default7", OBJECT_SELF);
}
//::////////////////////////////////////////////////////////////////////////////
