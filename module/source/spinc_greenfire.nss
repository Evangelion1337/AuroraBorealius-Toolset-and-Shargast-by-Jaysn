
#include "prc_inc_spells"
#include "prc_add_spell_dc"
//
// Returns TRUE if the greenfire heartbeat has fired at least once.
//
int HasHeartbeatFired()
{
     return GetLocalInt(OBJECT_SELF, "SP_GREENFIRE_HBFIRED");
}

//
// Saves the fact that the greenfire heartbeat has fired.
//
void SetHeartbeatFired()
{
     SetLocalInt(OBJECT_SELF, "SP_GREENFIRE_HBFIRED", TRUE);
}

//
// Gets the greenfire spell ID.
//
int GetGreenfireSpellID()
{
     return GetLocalInt(GetAreaOfEffectCreator(), "SP_GREENFIRE_SPELLID");
}

//
// Saves the specified spell ID as the greenfire spell ID.
//
void SetGreenfireSpellID(int nSpellID)
{
     SetLocalInt(OBJECT_SELF, "SP_GREENFIRE_SPELLID", nSpellID);
}


//
// Runs the greenfire spell effect against the specified target for the specified
// caster.
//
void DoGreenfire(int nDamageType, object oCaster, object oTarget)
{
     // Get the spell ID for greenfire, which is stored as a local int on the caster.
     int nSpellID = GetLocalInt(oCaster, "SP_GREENFIRE_SPELLID");

     // Get the amount of bonus damage, based on caster level.
     int nCasterLevel = PRCGetCasterLevel(oCaster);
     int nBonus = nCasterLevel;
     if (nBonus > 10) nBonus = 10;

     if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster))
     {
          // Fire cast spell at event for the specified target
          PRCSignalSpellEvent(oTarget, TRUE, nSpellID, oCaster);

          int nPenetr = nCasterLevel + SPGetPenetr();

          if (!PRCDoResistSpell(oCaster, oTarget,nPenetr))
          {
               // Roll the damage and let the target make a reflex save if the
               // heartbeat hasn't fired yet, once that happens targets get no save.
               int nDamage = PRCGetMetaMagicDamage(nDamageType, 2, 6, 0, nBonus);
                // Acid Sheath adds +1 damage per die to acid descriptor spells
                if (GetHasDescriptor(nSpellID, DESCRIPTOR_ACID) && GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH, oCaster))
                	nDamage += 2;  
                nDamage += SpellDamagePerDice(oCaster, 2);		
               if (!HasHeartbeatFired())
                    nDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget,
                         PRCGetSaveDC(oTarget,oCaster), SAVING_THROW_TYPE_ACID);

               // If we really did damage apply it to the target.
               if (nDamage > 0)
                    SPApplyEffectToObject(DURATION_TYPE_INSTANT,
                         PRCEffectDamage(oTarget, nDamage, nDamageType), oTarget);
          }
     }
}

// Test main
//void main(){}
