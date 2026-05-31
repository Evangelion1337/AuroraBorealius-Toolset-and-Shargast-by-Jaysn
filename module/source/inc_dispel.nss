/////////////////////////////////////////////////////////////////////////////////////////////////
//:: This is the prc_dispel_magic functions declarations.   The functions themselves are at the bottom
//:: of the file.       I got tired of circular include statement errors and just decided to make
//:: these both be just one file by adding my text to theirs.
///////////////////////////////////////////////////////////////////////////////////////////////

// GZ: Number of spells in GetSpellBreachProtections
const int PRC_SPELLS_MAX_BREACH = 33;

//:: This is my remake of the spellsDispelMagic found in x0_i0_spells.   It's pretty much
//:: identical to the old one except instead of calling the EffectDispelMagicBest() and
//:: EffectDispelMagicAll() scripting functions it calls the ones I've specified in this
//:: file to replace them.
void spellsDispelMagicMod(object oTarget, int nCasterLevel, effect eVis, effect eImpac, int bAll = TRUE, int bBreachSpells = FALSE);

//:: This is my remake of spellsDispelAoE().  It's very different, and very short.   It
//:: takes advantage of the way I've reworked AoE's so that it can simply use the caster
//:: level stored in the AoE and do a proper dispel check against it.
void spellsDispelAoEMod(object oTargetAoE, object oCaster, int nCasterLevel);

//:: This function is to replace EffectDispelMagicBest().   It goes through the references
//:: in the three arrays that store the caster levels and references to effects on oTarget,
//:: chooses the one with the highest caster level, and attempts to dispel it using the
//:: caster level entry in the array that corresponds to the spell itself.
void DispelMagicBestMod(object oTarget, int nCasterLevel);

//:: This function is to replace EffectDispelMagicAll().  It goest through all the references
//:: in the three arrays that store the caster levels and references to effects on oTarget, and
//:: attempts a dispel on each of them.  It only checks to dispel whole spells, not individual
//:: separate effects one spell may place on a person.
void DispelMagicAllMod(object oTarget, int nCasterLevel);

//:: This function sorts the 3 arrays in descending order of caster level, so entry 0 is the
//:: highest, and the last entry is the lowest.  It only gets called from inside DispelMagicBest()
void SortAll3Arrays(object oTarget);

//:: This function is just a helper function to include Infestation of Maggots among the list
//:: of spells in effect on oTarget, so it can be sorted with the rest. It's only called by
//:: DispelMagicBest()
void HandleInfestationOfMaggots(object oTarget);

// This is only meant to be called withing SetAllAoEInts()  I've heard terrible stories that
// say if an object is destroyed, it's local variables may remain in place eating up memory
// so I decided I'd better mop up after setting all of these.
void DeleteAllAoEInts(object oAoE);

// Returns the AoE's entire caster level, including any from prc's as stored in the local variable
int AoECasterLevel(object oAoE = OBJECT_SELF);

// * Performs a spell breach up to nTotal spell are removed and
// * nSR spell resistance is  lowered. nSpellId can be used to override
// * the originating spell ID. If not specified, SPELL_GREATER_SPELL_BREACH
// * is used
void PRCDoSpellBreach(object oTarget, int nTotal, int nSR, int nSpellId = -1);

// * Performs a spell breach up to nTotal spells are removed and nSR spell
// * resistance is lowered.
int PRCGetSpellBreachProtection(int nLastChecked);

// * Remove all spell protections of a specific type
int PRCRemoveProtections(int nSpell_ID, object oTarget, int nCount);

// * Handle dispel magic of AoEs
void spellsDispelAoE(object oTargetAoE, object oCaster, int nCasterLevel);

// * dispel magic on one or multiple targets.
// * if bAll is set to TRUE, all effects are dispelled from a creature
// * else it will only dispel the best effect from each creature (used for AoE)
// * Specify bBreachSpells to add Mord's Disjunction to the dispel
void spellsDispelMagic(object oTarget, int nCasterLevel, effect eVis, effect eImpac, int bAll = TRUE, int bBreachSpells = FALSE);

// Mysteries have a -4 when dispelling spells and vice versa
int GetIsMystery(int nSpellId);

#include "prc_effect_inc"
#include "lookup_2da_spell"
#include "spinc_remeffct"
#include "prcsp_engine"

//////////////////////////////////////////////////////////////////////////////////////////////////////


//:: Copy of the original function with 1 minor change: calls DispelMagicAll() and
//:: DispelMagicBest() instead of EffectDispelMagicAll() and EffectDispelMagicBest()
//:: That is the only change.
//------------------------------------------------------------------------------
// Attempts a dispel on one target, with all safety checks put in.
//------------------------------------------------------------------------------
void spellsDispelMagicMod(object oTarget, int nCasterLevel, effect eVis, effect eImpac, int bAll = TRUE, int bBreachSpells = FALSE)
{
    //--------------------------------------------------------------------------
    // Don't dispel magic on petrified targets
    // this change is in to prevent weird things from happening with 'statue'
    // creatures. Also creature can be scripted to be immune to dispel
    // magic as well.
    //--------------------------------------------------------------------------
    if (PRCGetHasEffect(EFFECT_TYPE_PETRIFY, oTarget) == TRUE
        || GetLocalInt(oTarget, "X1_L_IMMUNE_TO_DISPEL") == 10)
    {
        return;
    }

    effect eDispel;
    float fDelay = PRCGetRandomDelay(0.1, 0.3);
    int nId = PRCGetSpellId();
    if (GetItemPossessedBy(OBJECT_SELF, "WOL_Aradros") == GetItemInSlot(INVENTORY_SLOT_NECK, OBJECT_SELF) && GetIsObjectValid(GetItemPossessedBy(OBJECT_SELF, "WOL_Aradros"))) nCasterLevel += 1;
    
    //--------------------------------------------------------------------------
    // Fire hostile event only if the target is hostile...
    //--------------------------------------------------------------------------

    if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nId));
    else
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nId, FALSE));

    //--------------------------------------------------------------------------
    // GZ: Bugfix. Was always dispelling all effects, even if used for AoE
    //--------------------------------------------------------------------------
    if (bAll == TRUE )
    {
        //:: This is the first of 2 changes I made.
        DispelMagicAllMod(oTarget, nCasterLevel);

        // The way it used to get done.
        //eDispel = EffectDispelMagicAll(nCasterLevel);

        //----------------------------------------------------------------------
        // GZ: Support for Mord's disjunction
        //----------------------------------------------------------------------
        if (bBreachSpells)
        {
            PRCDoSpellBreach(oTarget, 6, 10, nId);
        }
    }
    else
    {
        //:: This is the second of the 2 changes I made.
        //:: There are no other changes.
        DispelMagicBestMod(oTarget, nCasterLevel);

        // The way it used to get done
        //eDispel = EffectDispelMagicBest(nCasterLevel);

        if (bBreachSpells)
        {
           PRCDoSpellBreach(oTarget, 2, 10, nId);
        }
    }

    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDispel, oTarget));
}

/////////////////////////////////////////////////////////////////////////////////////
//::  This one's so small I hope not to lose track of it.

//:: Replaces the normal spellsDispelAoE
//:: I reworked all AoE's to store their caster level as a local int on themselves,
//:: so it's possible to just do a proper caster level check instead of doing
//:: something complicated.

void spellsDispelAoEMod(object oTargetAoE, object oCaster, int nCasterLevel)
{
   int ModWeave;
   int nBonus = 0;
   string SchoolWeave = lookup_spell_school(GetLocalInt(oTargetAoE, "X2_AoE_SpellID"));
   int Weave = GetHasFeat(FEAT_SHADOWWEAVE,oCaster)+ GetLocalInt(oCaster, "X2_AoE_SpecDispel");
   if (GetLocalInt(oTargetAoE, " X2_Effect_Weave_ID_") && !Weave) ModWeave = 4;
   if (SchoolWeave=="V" ||SchoolWeave=="T"  ) ModWeave = 0;
   if (GetLocalInt(oTargetAoE, "PRC_Power_DispellingBuffer_Active")) nBonus += 5;
   if (GetHasFeat(FEAT_SPELL_GIRDING, oTargetAoE)) nBonus += 2;
   if (GetLevelByClass(CLASS_TYPE_SUEL_ARCHANAMACH, oTargetAoE) >= 1) nBonus += 6;
   if (GetItemPossessedBy(oCaster, "WOL_Aradros") == GetItemInSlot(INVENTORY_SLOT_NECK, oCaster) && GetIsObjectValid(GetItemPossessedBy(oCaster, "WOL_Aradros"))) nCasterLevel += 1;

   int iDice = d20(1);
//   SendMessageToPC(GetFirstPC(), "Spell :"+ IntToString(PRCGetSpellId())+" T "+GetName(oTargetAoE));
//   SendMessageToPC(GetFirstPC(), "Dispell :"+IntToString(iDice + nCasterLevel)+" vs DC :"+IntToString(11 + GetLocalInt(oTargetAoE, "X2_AoE_Caster_Level")+ModWeave)+" Weave :"+IntToString(ModWeave)+" "+SchoolWeave);

   if(iDice + nCasterLevel >= GetLocalInt(oTargetAoE, "X2_AoE_Caster_Level") + ModWeave + nBonus)
   {
     DestroyObject(oTargetAoE);
   }
}

 ///////////////////////////////////////////////////////////////////////////////////


//:: Goes through all the references to effects stored in the 3 variable arrays,
//:: picks the one with the highest caster level (breaking ties by just keeping the
//:: first one it comes to) and then attempts a dispel check on it.
//:: It goes by spell, not spell effect, so a successful check removes all spell
//:: affects from that spell itself.

void DispelMagicBestMod(object oTarget, int nCasterLevel)
{
  // I *really*  want to rewrite this one so that it simply dispels the most useful effect
  // instead of just the one with the highest caster level.
  // Sure hate to dispel mage armor on somebody who's immune to necromancy.   Difficult Decision, these.


  //:: calls a function to determine whether infestation of maggots is in effect
  //:: on the target.   If so, it adds it to the 3 arrays so it can be sorted with them.

  HandleInfestationOfMaggots(oTarget);

  //:: calls a function to arrange the values in the 3 arrays in order of highest caster level to lowest
  //:: Index 0 will be the highest, and nLastEntry will be the lowest.

  SortAll3Arrays(oTarget);

  int nCurrentEntry;
  int nLastEntry = GetLocalInt(oTarget, "X2_Effects_Index_Number");

  int nEffectSpellID, nEffectCastLevel;
  object oEffectCaster = OBJECT_SELF;
  int ModWeave;
  int nBonus = 0;

  string sSelf = "Dispelled: ";
  string sCast = "Dispelled on "+GetName(oTarget)+": ";

  int Weave = GetHasFeat(FEAT_SHADOWWEAVE,OBJECT_SELF)+ GetLocalInt(OBJECT_SELF, "X2_AoE_SpecDispel");
  if (GetLocalInt(oTarget, "PRC_Power_DispellingBuffer_Active")) nBonus += 5;
  if (GetHasFeat(FEAT_SPELL_GIRDING, oTarget)) nBonus += 2;
  if (GetLevelByClass(CLASS_TYPE_SUEL_ARCHANAMACH, oTarget) >= 1) nBonus += 6;
  nCasterLevel += GetEssentiaInvestedFeat(oEffectCaster, FEAT_SOULTOUCHED_SPELLCASTING);

  for(nCurrentEntry = 0; nCurrentEntry <= nLastEntry; nCurrentEntry++)
  {
    nEffectSpellID = GetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nCurrentEntry));
    oEffectCaster = GetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nCurrentEntry));
    //:: Make sure the effect it refers to is still in place before making it
    //:: number one.
    if(IsStillRealEffect(nEffectSpellID, oEffectCaster, oTarget))
    {
      ModWeave = 0;
      string SchoolWeave = lookup_spell_school(nEffectSpellID);
      string SpellName = GetStringByStrRef(StringToInt(lookup_spell_name(nEffectSpellID)));
      nEffectCastLevel = GetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrentEntry));
      if (GetLocalInt(oTarget, " X2_Effect_Weave_ID_"+ IntToString(nCurrentEntry)) && !Weave) ModWeave = 4;
      if (SchoolWeave=="V" ||SchoolWeave=="T"  ) ModWeave = 0;
      
      // -4 for Mystery vs Spell and Spell vs Mystery
      // If you have no Shadowcasting classes, you've got to be using another magic system to dispel
      if ((!GetLevelByClass(CLASS_TYPE_SHADOWCASTER, OBJECT_SELF) && !GetLevelByClass(CLASS_TYPE_SHADOWSMITH, OBJECT_SELF)) && GetIsMystery(nEffectSpellID)) nCasterLevel -= 4;
      // Likewise, if you're a Shadowcaster, you get a -4 penalty to dispel non-Mysteries. Magic number is MYST_SHADOWS_FADE
      if (PRCGetSpellId() == 18386 && !GetIsMystery(nEffectSpellID)) nCasterLevel -= 4;      

      int iDice = d20(1);
//      SendMessageToPC(GetFirstPC(), "Spell :"+ IntToString(nEffectSpellID)+" T "+GetName(oTarget)+" C "+GetName(oEffectCaster));
//      SendMessageToPC(GetFirstPC(), "Dispell :"+ IntToString(iDice + nCasterLevel)+" vs DC :"+IntToString(11 + nEffectCastLevel+ModWeave)+" Mod Weave"+IntToString(ModWeave)+" "+SchoolWeave);
      if(iDice + nCasterLevel >= 11 + nEffectCastLevel + ModWeave + nBonus)
      {
        if(nEffectSpellID != SPELL_INFESTATION_OF_MAGGOTS)
        {// If it isn't infestation of maggots we remove it one way, if it is, we remove it another.
            effect eToDispel = GetFirstEffect(oTarget);
            while(GetIsEffectValid(eToDispel))
            {
                if(GetEffectSpellId(eToDispel) == nEffectSpellID)
                {
                    if(GetEffectCreator(eToDispel) == oEffectCaster)
                    {
                      if(GetEffectSpellId(eToDispel) == INVOKE_RETRIBUTIVE_INVISIBILITY && GetLocalInt(oTarget, "DangerousInvis"))
                      {
                        location lTarget = GetLocation(oTarget);
                        effect eRetrVis = EffectVisualEffect(VFX_IMP_SONIC);
                        effect eRetrPulse = EffectVisualEffect(VFX_IMP_PULSE_WIND);
                        effect eRetrStun = EffectStunned();
                        effect eDam;
                        int nDamage;
                        int nDC;
                        float fDelay;
                        int RICasterLvl = GetLocalInt(oTarget, "DangerousInvis");
                        SPApplyEffectToObject(DURATION_TYPE_INSTANT, eRetrPulse, oTarget);
                        DeleteLocalInt(oTarget, "DangerousInvis");
                        
                        //Declare the spell shape, size and the location.  Capture the first target object in the shape.
                        object oVictim = MyFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(20.0), lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
                        //Cycle through the targets within the spell shape until an invalid object is captured.
                        while (GetIsObjectValid(oVictim))
                        {
                            if (spellsIsTarget(oVictim, SPELL_TARGET_STANDARDHOSTILE, oTarget))
                            {
                                    //Fire cast spell at event for the specified target
                                    SignalEvent(oVictim, EventSpellCastAt(oTarget, INVOKE_RETRIBUTIVE_INVISIBILITY));
                                    //Get the distance between the explosion and the target to calculate delay
                                    fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oVictim))/20;
                                    if (!PRCDoResistSpell(oTarget, oVictim, RICasterLvl, fDelay))
                                    {
                                        //Roll damage for each target
                                        nDamage = d6(4);
                                        //nDamage += ApplySpellBetrayalStrikeDamage(oVictim, oTarget, FALSE);
                                        nDC = 16 + GetAbilityModifier(ABILITY_CHARISMA, oTarget);
                                        
                                        //save
                                        if(PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_SPELL))
                                        {
                                            nDamage = nDamage / 2;
                                            if(GetHasMettle(oTarget, SAVING_THROW_FORT)) nDamage = 0;
                                        }
                                        else
                                            DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRetrStun, oVictim, RoundsToSeconds(1)));
                                            
                                        if(nDamage > 0)
                                        {
                                            //Set the damage effect
                                            eDam = PRCEffectDamage(oVictim, nDamage, DAMAGE_TYPE_SONIC);
                                            // Apply effects to the currently selected target.
                                            DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oVictim));
                                            PRCBonusDamage(oVictim);
                                            //This visual effect is applied to the target object not the location as above.  This visual effect
                                            //represents the flame that erupts on the target not on the ground.
                                            DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eRetrVis, oVictim));
                                        }
                                     }
                                
                            }
                           //Select the next target within the spell shape.
                           oVictim = MyNextObjectInShape(SHAPE_SPHERE, FeetToMeters(20.0), lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
                        }
                      }
                      else if(GetEffectSpellId(eToDispel) == INVOKE_PAINFUL_SLUMBER_OF_AGES && GetLocalInt(oTarget, "PainfulSleep"))
                      {
                          effect eSleepDam = EffectDamage(GetLocalInt(oTarget, "PainfulSleep"), DAMAGE_TYPE_MAGICAL);
                          ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleepDam, oTarget);
                          DeleteLocalInt(oTarget, "PainfulSleep");
                          RemoveEventScript(oTarget, EVENT_VIRTUAL_ONDAMAGED, "inv_painsleep", FALSE, FALSE);
                      }
                      
                      RemoveEffect(oTarget, eToDispel);
                      
                      if (GetLevelByClass(CLASS_TYPE_NOCTUMANCER))
                      {
                          int nExist = GetLocalInt(OBJECT_SELF, "CaptureMagic");
                          int nSpellLevel = StringToInt(Get2DACache("spells", "Innate", nEffectSpellID));
                          SetLocalInt(OBJECT_SELF, "CaptureMagic", PRCMax(nExist, nSpellLevel/2));
                          if (GetLevelByClass(CLASS_TYPE_NOCTUMANCER) >= 10) 
                              ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(EffectSpellImmunity(nEffectSpellID)), OBJECT_SELF, 60.0);                          
                      }
                      
                      if(GetSpellId() == INVOKE_VORACIOUS_DISPELLING)
                      {
                          //Get spell level
                          int nEffectSpellLevel = StringToInt(Get2DACache("spells", "Innate", nEffectSpellID));
                          //Damage = spell level
                          effect eSlashDam = EffectDamage(DAMAGE_TYPE_MAGICAL, nEffectSpellLevel);

                          SPApplyEffectToObject(DURATION_TYPE_INSTANT, eSlashDam, oTarget);
                      }
                      
                      else if(GetSpellId() == INVOKE_DEVOUR_MAGIC)
                      {
                          //Get spell level
                          int nEffectSpellLevel = StringToInt(Get2DACache("spells", "Innate", nEffectSpellID));
                          //HP = 5 * spell level
                          effect eDracHP = EffectTemporaryHitpoints(5 * nEffectSpellLevel);

                          //can't stack HP from multiple dispels
                          if (GetHasSpellEffect(GetSpellId(),OBJECT_SELF))
                          {
                              PRCRemoveSpellEffects(GetSpellId(), OBJECT_SELF, OBJECT_SELF);
                          }
                  
                          SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDracHP, OBJECT_SELF, 60.0);
                      }

                      else if(GetSpellId() == SPELL_SLASHING_DISPEL)
                      {
                          //Get spell level
                          int nEffectSpellLevel = StringToInt(Get2DACache("spells", "Innate", nEffectSpellID));
                          //Damage = 2 * spell level
                          effect eSlashDam = EffectDamage(DAMAGE_TYPE_MAGICAL, 2 * nEffectSpellLevel);

                          SPApplyEffectToObject(DURATION_TYPE_INSTANT, eSlashDam, oTarget);
                      }

                    }// end if effect comes from this caster
                }// end if effect comes from this spell
                eToDispel = GetNextEffect(oTarget);
            }// end of while loop
        }// end if infestation is not the spell
        else
        {
          DeleteLocalInt(oTarget, "XP2_L_SPELL_CASTER_LVL_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));
          // Deleting this variable is what actually ends the spell effect's damage.
          DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));
          DeleteLocalInt(oTarget,"XP2_L_SPELL_WEAVE" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));
          effect eToDispel = GetFirstEffect(oTarget);
          while(GetIsEffectValid(eToDispel))
          {
            //:: We don't worry about who cast it.  A person can only really have one infestation
            //:: going on at a time, I think.
            if(GetEffectSpellId(eToDispel) == nEffectSpellID)
            {
              RemoveEffect(oTarget, eToDispel);
            }// end if effect comes from this spell
            eToDispel = GetNextEffect(oTarget);
          }// end of while loop
        }// end else

        //:: Since the effect has been removed, delete the references to it.
        //:: This will help out the sweeping function when it gets called next (not now, though)
        // These are stored for one round for Spell Rebirth
        SetLocalInt(oTarget, "TrueSpellRebirthSpellId", GetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nCurrentEntry)));
        SetLocalInt(oTarget, "TrueSpellRebirthCasterLvl", GetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrentEntry)));
        DelayCommand(6.0, DeleteLocalInt(oTarget, "TrueSpellRebirthSpellId"));
        DelayCommand(6.0, DeleteLocalInt(oTarget, "TrueSpellRebirthCasterLvl"));

        DeleteLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nCurrentEntry));
        DeleteLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrentEntry));
        DeleteLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nCurrentEntry));
        DeleteLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nCurrentEntry));

        //:: Display a message to all involved.
        SendMessageToPC(OBJECT_SELF, sCast+SpellName);
        if (oTarget != OBJECT_SELF) SendMessageToPC(oTarget, sSelf+SpellName);

        //:: If the check was successful, then we're done.
        return;
      }// end if check is successful.
    }// end if is still a valid spell.
    else
    {
        // These are stored for one round for Spell Rebirth
        SetLocalInt(oTarget, "TrueSpellRebirthSpellId", GetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nCurrentEntry)));
        SetLocalInt(oTarget, "TrueSpellRebirthCasterLvl", GetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrentEntry)));
        DelayCommand(6.0, DeleteLocalInt(oTarget, "TrueSpellRebirthSpellId"));
        DelayCommand(6.0, DeleteLocalInt(oTarget, "TrueSpellRebirthCasterLvl"));

      // If it's not a real effect anymore, then delete the variables that refer to it.
      DeleteLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nCurrentEntry));
      DeleteLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrentEntry));
      DeleteLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nCurrentEntry));
      DeleteLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nCurrentEntry));
    }// end of else statement.

  }// end of for loop

  // If we got here, the return function above never ran, so nothing got removed:
  SendMessageToPC(OBJECT_SELF, sCast+"None");
  if (oTarget != OBJECT_SELF) SendMessageToPC(oTarget, sSelf+"None");
} // End Of Function

///////////////////////////////////////////////////////////////////////////////////////////////////////

//:: Goes through and tries to remove each and every spell effect, doing a
//:: separate caster level check for each spell.   It goes by spell, not spell
//:: effect, so a successful check removes all spell affects from that spell
//:: itself.

void DispelMagicAllMod(object oTarget, int nCasterLevel)
{

  int nIndex = 0;
  int nEffectSpellID;
  int nEffectCasterLevel;
  object oEffectCaster = OBJECT_SELF;
  int ModWeave;
  int nBonus = 0;

  int nLastEntry = GetLocalInt(oTarget, "X2_Effects_Index_Number");
  effect eToDispel;

  string sList, SpellName;
  string sSelf = "Dispelled: ";
  string sCast = "Dispelled on "+GetName(oTarget)+": ";

  int Weave = GetHasFeat(FEAT_SHADOWWEAVE,OBJECT_SELF)+ GetLocalInt(OBJECT_SELF, "X2_AoE_SpecDispel");
  if (GetLocalInt(oTarget, "PRC_Power_DispellingBuffer_Active")) nBonus += 5;
  if (GetHasFeat(FEAT_SPELL_GIRDING, oTarget)) nBonus += 2;
  if (GetLevelByClass(CLASS_TYPE_SUEL_ARCHANAMACH, oTarget) >= 1) nBonus += 6;
  nCasterLevel += GetEssentiaInvestedFeat(oEffectCaster, FEAT_SOULTOUCHED_SPELLCASTING);

  //:: Do the dispel check for each and every spell in effect on oTarget.
  for(nIndex; nIndex <= nLastEntry; nIndex++)
  {
    nEffectSpellID = GetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nIndex));
    if(GetHasSpellEffect(nEffectSpellID, oTarget))
    {
      ModWeave = 0;
      string SchoolWeave = lookup_spell_school(nEffectSpellID);
      SpellName = GetStringByStrRef(StringToInt(lookup_spell_name(nEffectSpellID)));
      nEffectCasterLevel = GetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nIndex));
      if (GetLocalInt(oTarget, " X2_Effect_Weave_ID_"+ IntToString(nIndex)) && !Weave) ModWeave = 4;
      if (SchoolWeave=="V" ||SchoolWeave=="T"  ) ModWeave = 0;
      
      // -4 for Mystery vs Spell and Spell vs Mystery
      // If you have no Shadowcasting classes, you've got to be using another magic system to dispel
      if ((!GetLevelByClass(CLASS_TYPE_SHADOWCASTER, OBJECT_SELF) && !GetLevelByClass(CLASS_TYPE_SHADOWSMITH, OBJECT_SELF)) && GetIsMystery(nEffectSpellID)) nCasterLevel -= 4;
      // Likewise, if you're a Shadowcaster, you get a -4 penalty to dispel non-Mysteries. Magic number is MYST_SHADOWS_FADE
      if (PRCGetSpellId() == 18386 && !GetIsMystery(nEffectSpellID)) nCasterLevel -= 4;

      int iDice = d20(1);
 //     SendMessageToPC(GetFirstPC(), "Spell :"+ IntToString(nEffectSpellID)+" T "+GetName(oTarget)+" C "+GetName(GetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nIndex))));
 //     SendMessageToPC(GetFirstPC(), "Dispell :"+IntToString(iDice + nCasterLevel)+" vs DC :"+IntToString(11 + nEffectCasterLevel+ModWeave)+" Weave :"+IntToString(ModWeave)+" "+SchoolWeave);

      if(iDice + nCasterLevel >= 11 + nEffectCasterLevel + ModWeave + nBonus)
      {
        sList += SpellName+", ";
        oEffectCaster = GetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nIndex));

        //:: Was going to use this function but upon reading it it became apparent it might not remove
        //:: all of the given spells effects, but just one instead.

        //PRCRemoveSpellEffects(nEffectSpellID, oEffectCaster, oTarget);

        //:: If the check is successful, go through and remove all effects originating
        //:: from that particular spell.
        effect eToDispel = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eToDispel))
        {
          if(GetEffectSpellId(eToDispel) == nEffectSpellID)
          {
            if(GetEffectCreator(eToDispel) == oEffectCaster)
            {
              
              if(GetEffectSpellId(eToDispel) == INVOKE_RETRIBUTIVE_INVISIBILITY && GetLocalInt(oTarget, "DangerousInvis"))
              {
                  location lTarget = GetLocation(oTarget);
                  effect eRetrVis = EffectVisualEffect(VFX_IMP_SONIC);
                  effect eRetrPulse = EffectVisualEffect(VFX_IMP_PULSE_WIND);
                  effect eRetrStun = EffectStunned();
                  int RICasterLvl = GetLocalInt(oTarget, "DangerousInvis");
                  effect eDam;
                  int nDamage;
                  float fDelay;
                  int nDC;
                  SPApplyEffectToObject(DURATION_TYPE_INSTANT, eRetrPulse, oTarget);
                  DeleteLocalInt(oTarget, "DangerousInvis");
                        
                  //Declare the spell shape, size and the location.  Capture the first target object in the shape.
                  object oVictim = MyFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(20.0), lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
                  //Cycle through the targets within the spell shape until an invalid object is captured.
                  while (GetIsObjectValid(oVictim))
                  {
                      if (spellsIsTarget(oVictim, SPELL_TARGET_STANDARDHOSTILE, oTarget))
                      {
                              //Fire cast spell at event for the specified target
                              SignalEvent(oVictim, EventSpellCastAt(oTarget, INVOKE_RETRIBUTIVE_INVISIBILITY));
                              //Get the distance between the explosion and the target to calculate delay
                              fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oVictim))/20;
                              if (!PRCDoResistSpell(oTarget, oVictim, RICasterLvl, fDelay))
                              {
                                  //Roll damage for each target
                                  nDamage = d6(4);
                                  nDamage += ApplySpellBetrayalStrikeDamage(oVictim, oTarget, FALSE);
                                  nDC = 16 + GetAbilityModifier(ABILITY_CHARISMA, oTarget);
                                        
                                  //save
                                  if(PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_SPELL))
                                  {
                                      nDamage = nDamage / 2;
                                      if(GetHasMettle(oTarget, SAVING_THROW_FORT)) nDamage = 0;
                                  }
                                  else
                                      DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRetrStun, oVictim, RoundsToSeconds(1)));
                                            
                                  if(nDamage > 0)
                                  {
                                      //Set the damage effect
                                      eDam = PRCEffectDamage(oVictim, nDamage, DAMAGE_TYPE_SONIC);
                                      // Apply effects to the currently selected target.
                                      DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oVictim));
                                      PRCBonusDamage(oVictim);
                                      //This visual effect is applied to the target object not the location as above.  This visual effect
                                      //represents the flame that erupts on the target not on the ground.
                                      DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eRetrVis, oVictim));
                                  }
                               }
                          
                       }
                       //Select the next target within the spell shape.
                       oVictim = MyNextObjectInShape(SHAPE_SPHERE, FeetToMeters(20.0), lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
                   }
               }
               
               else if(GetEffectSpellId(eToDispel) == INVOKE_PAINFUL_SLUMBER_OF_AGES && GetLocalInt(oTarget, "PainfulSleep"))
               {
                    effect eSleepDam = EffectDamage(GetLocalInt(oTarget, "PainfulSleep"), DAMAGE_TYPE_MAGICAL);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleepDam, oTarget);
                    DeleteLocalInt(oTarget, "PainfulSleep");
                    RemoveEventScript(oTarget, EVENT_VIRTUAL_ONDAMAGED, "inv_painsleep", FALSE, FALSE);
               }
               
              RemoveEffect(oTarget, eToDispel);
              
              if (GetLevelByClass(CLASS_TYPE_NOCTUMANCER))
              {
                  int nExist = GetLocalInt(OBJECT_SELF, "CaptureMagic");
                  int nSpellLevel = StringToInt(Get2DACache("spells", "Innate", nEffectSpellID));
                  SetLocalInt(OBJECT_SELF, "CaptureMagic", PRCMax(nExist, nSpellLevel/2));
                  if (GetLevelByClass(CLASS_TYPE_NOCTUMANCER) >= 10) 
                      ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(EffectSpellImmunity(nEffectSpellID)), OBJECT_SELF, 60.0);  
              }              

              if(GetSpellId() == INVOKE_VORACIOUS_DISPELLING)
              {
                  //Get spell level
                  int nEffectSpellLevel = StringToInt(Get2DACache("spells", "Innate", nEffectSpellID));
                  //Damage = spell level
                  effect eSlashDam = EffectDamage(DAMAGE_TYPE_MAGICAL, nEffectSpellLevel);

                  SPApplyEffectToObject(DURATION_TYPE_INSTANT, eSlashDam, oTarget);
              }
                      
              else if(GetSpellId() == INVOKE_DEVOUR_MAGIC)
              {
                  //Get spell level
                  int nEffectSpellLevel = StringToInt(Get2DACache("spells", "Innate", nEffectSpellID));
                  //HP = 5 * spell level
                  effect eDracHP = EffectTemporaryHitpoints(5 * nEffectSpellLevel);
                  
                  //can't stack HP from multiple dispels
                  if (GetHasSpellEffect(GetSpellId(),OBJECT_SELF))
                  {
                      PRCRemoveSpellEffects(GetSpellId(), OBJECT_SELF, OBJECT_SELF);
                  }

                  SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDracHP, OBJECT_SELF, 60.0);
              }

              else if(GetSpellId() == SPELL_SLASHING_DISPEL)
              {
              //Get spell level
              int nEffectSpellLevel = StringToInt(Get2DACache("spells", "Innate", nEffectSpellID));
              //Damage = 2 * spell level
              effect eSlashDam = EffectDamage(DAMAGE_TYPE_MAGICAL, 2 * nEffectSpellLevel);

              SPApplyEffectToObject(DURATION_TYPE_INSTANT, eSlashDam, oTarget);
              }
 
              //Spell Removal Check
              SpellRemovalCheck(oEffectCaster, oTarget);

            }// end if effect comes from this caster
          }// end if effect comes from this spell
          eToDispel = GetNextEffect(oTarget);
        }// end of while loop


    // These are stored for one round for Spell Rebirth
        SetLocalInt(oTarget, "TrueSpellRebirthSpellId", GetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nIndex)));
        SetLocalInt(oTarget, "TrueSpellRebirthCasterLvl", GetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nIndex)));
        DelayCommand(6.0, DeleteLocalInt(oTarget, "TrueSpellRebirthSpellId"));
        DelayCommand(6.0, DeleteLocalInt(oTarget, "TrueSpellRebirthCasterLvl"));

        // Delete the saved references to the spell's effects.
        // This will save some time when reordering things a bit.
        DeleteLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nIndex));
        DeleteLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nIndex));
        DeleteLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nIndex));
        DeleteLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nIndex));

      }// end of if caster check is sucessful
    }// end of if oTarget has effects from this spell
  }// end of for statement


  // Additional Code to dispel any infestation of maggots effects.

  // If check to take care of infestation of maggots is in effect.
  // with the highest caster level on it right now.
  // If it is, we remove it instead of the other effect.
  int bHasInfestationEffects = GetLocalInt(oTarget,"XP2_L_SPELL_CASTER_LVL_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));

  if(bHasInfestationEffects)
  {
    ModWeave =0;
    if (GetLocalInt(oTarget, " XP2_L_SPELL_WEAVE" +IntToString (SPELL_INFESTATION_OF_MAGGOTS)) && !Weave) ModWeave = 4;

    if(d20(1) + nCasterLevel >= bHasInfestationEffects + 11 + ModWeave + nBonus)
    {
      DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));
      DeleteLocalInt(oTarget,"XP2_L_SPELL_CASTER_LVL_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));
      effect eToDispel = GetFirstEffect(oTarget);
      nEffectSpellID = SPELL_INFESTATION_OF_MAGGOTS;

      SpellName = GetStringByStrRef(StringToInt(lookup_spell_name(nEffectSpellID)));
      sList += SpellName+", ";

      while(GetIsEffectValid(eToDispel))
      {
        if(GetEffectSpellId(eToDispel) == nEffectSpellID)
        {
          RemoveEffect(oTarget, eToDispel);
        }// end if effect comes from this spell
        eToDispel = GetNextEffect(oTarget);
      }// end of while loop
    }// end if caster level check was a success.
  }// end if infestation of maggots is in effect on oTarget/

  // If the loop to rid the target of the effects of infestation of maggots
  // runs at all, this next loop won't because eToDispel has to be invalid for this
  // loop to terminate and the other to begin - but it won't begin if eToDispel is
  // already invalid :)

  if (sList == "") sList = "None  ";
  sList = GetStringLeft(sList, GetStringLength(sList) - 2); // truncate the last ", "

  SendMessageToPC(OBJECT_SELF, sCast+sList);
  if (oTarget != OBJECT_SELF) SendMessageToPC(oTarget, sSelf+sList);

}// End of function.

///////////////////////////////////////////////////////////////////////////////////////////
//:: Sorts the 3 arrays in order of highest at index 0 on up to lowest at index nLastEntry
//////////////////////////////////////////////////////////////////////////////////////////

void SortAll3Arrays(object oTarget)
{

  int nLastEntry = GetLocalInt(oTarget, "X2_Effects_Index_Number");
  int nCurrEntry;
  int nCurrEntry2;
  int nSpellID, nSpellIDHigh, nCasterLvl, nCasterLvl2, nHighCastLvl, nHighestEntry,iWeave,iWeaveHigh;
  object oMaker, oMakerHigh;

  for(nCurrEntry = 0; nCurrEntry <= nLastEntry; nCurrEntry++)
  {
    nCasterLvl = GetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrEntry));
    nHighCastLvl = nCasterLvl;

    for(nCurrEntry2 = nCurrEntry + 1; nCurrEntry2 <= nLastEntry; nCurrEntry2++)
    {
      nCasterLvl2 = GetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrEntry2));

      if(nCasterLvl2 >= nHighCastLvl)
      {
        nHighestEntry = nCurrEntry2;
        nHighCastLvl = nCasterLvl2;
      }
    }// End of second for statement.
    if(nHighCastLvl != nCasterLvl)
    // If the entry we're currently looking at already is the highest caster level left,
    // we leave it there.  Otherwise we swap the highest level entry with this one.
    // nHighCastLvl will still be equal to nCasterLvl unless a higher level effect was found.
    {
      nSpellID = GetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nCurrEntry));
      oMaker = GetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nCurrEntry));
      iWeave = GetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nCurrEntry));

      nSpellIDHigh = GetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nHighestEntry));
      oMakerHigh = GetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nHighestEntry));
      iWeaveHigh = GetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nHighestEntry));

      DeleteLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrEntry));
      DeleteLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nCurrEntry));
      DeleteLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nCurrEntry));
      DeleteLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nCurrEntry));

      DeleteLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nHighestEntry));
      DeleteLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nHighestEntry));
      DeleteLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nHighestEntry));
      DeleteLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nHighestEntry));

      ///////////////////////////////////////////////////////////////////////////////
      SetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nCurrEntry), nHighCastLvl);
      SetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nCurrEntry), nSpellIDHigh);
      SetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nCurrEntry), oMakerHigh);
      SetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nCurrEntry), iWeaveHigh);

      //
      SetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nHighestEntry),nCasterLvl);
      SetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nHighestEntry), nSpellID);
      SetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nHighestEntry), oMaker);
      SetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nHighestEntry), iWeave);

    }  // End if the caster levels of the 2 entries are actually different.
  }// End of first for statement.
}

//////////////////////////////////////////////////////////////////////////////////////////////
//:: Finished sorting.
/////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////////
//:: Infestation of maggots is a special case because it won't end until a local
//:: int is deleted.   It must be handled specially.
/////////////////////////////////////////////////////////////////////////////////
void HandleInfestationOfMaggots(object oTarget)
{
                          //:: Special to trap an infestation of maggots effect.
  int nHasInfestationEffect = GetLocalInt(oTarget, "XP2_L_SPELL_CASTER_LVL_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));

  int nLastEntry = GetLocalInt(oTarget, "X2_Effects_Index_Number");
  if(nHasInfestationEffect)
  {
    // If they have infestation of maggots on them, then add it to the end of the list.
    // I would add it during the spell script itself but it might get swept up before the spell has
    // really ended, I fear.
    nLastEntry++;
    DeleteLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nLastEntry));
    DeleteLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nLastEntry));
    DeleteLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nLastEntry));
    DeleteLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nLastEntry));
    DeleteLocalInt(oTarget, "X2_Effects_Index_Number");

    SetLocalInt(oTarget, " X2_Effect_Spell_ID_" + IntToString(nLastEntry), SPELL_INFESTATION_OF_MAGGOTS);
    SetLocalInt(oTarget, " X2_Effect_Cast_Level_" + IntToString(nLastEntry), nHasInfestationEffect);
    SetLocalInt(oTarget, " X2_Effect_Weave_ID_" + IntToString(nLastEntry), GetLocalInt(oTarget, " XP2_L_SPELL_WEAVE" +IntToString (SPELL_INFESTATION_OF_MAGGOTS)));
    //:: Won't bother with this one. I think a creature can only have one infestation at a time.
    //SetLocalObject(oTarget, " X2_Effect_Caster_" + IntToString(nLastEntry));
    SetLocalInt(oTarget, "X2_Effects_Index_Number", nLastEntry);
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////
//:: End of section to trap infestation of maggots.
////////////////////////////////////////////////////////////////////////////////////////////

// Just returns the stored value.
int AoECasterLevel(object oAoE = OBJECT_SELF)
{
   int toReturn = GetLocalInt(oAoE, "X2_AoE_Caster_Level");
   return toReturn;
}

void PRCDoSpellBreach(object oTarget, int nTotal, int nSR, int nSpellId = -1)
{
    if (nSpellId == -1)
    {
        nSpellId =  SPELL_GREATER_SPELL_BREACH;
    }
    effect eSR = EffectSpellResistanceDecrease(nSR);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eVis = EffectVisualEffect(VFX_IMP_BREACH);
    int nCnt, nIdx;
    if(!GetIsReactionTypeFriendly(oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellId ));
        //Search through and remove protections.
        while(nCnt <= PRC_SPELLS_MAX_BREACH && nIdx < nTotal)
        {
            nIdx = nIdx + PRCRemoveProtections(PRCGetSpellBreachProtection(nCnt), oTarget, nCnt);
            nCnt++;
        }
        effect eLink = EffectLinkEffects(eDur, eSR);
        //--------------------------------------------------------------------------
        // This can not be dispelled
        //--------------------------------------------------------------------------
        eLink = ExtraordinaryEffect(eLink);
        SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10),TRUE);
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

}

//------------------------------------------------------------------------------
// Returns the nLastChecked-nth highest spell on the creature for use in
// the spell breach routines
// Please modify the constatn PRC_SPELLS_MAX_BREACH at the top of this file
// if you change the number of spells.
//------------------------------------------------------------------------------
int PRCGetSpellBreachProtection(int nLastChecked)
{
    //--------------------------------------------------------------------------
    // GZ: Protections are stripped in the order they appear here
    //--------------------------------------------------------------------------
    if(nLastChecked == 1) {return SPELL_GREATER_SPELL_MANTLE;}
    else if (nLastChecked == 2){return SPELL_PREMONITION;}
    else if(nLastChecked == 3) {return SPELL_SPELL_MANTLE;}
    else if(nLastChecked == 4) {return SPELL_SHADOW_SHIELD;}
    else if(nLastChecked == 5) {return SPELL_GREATER_STONESKIN;}
    else if(nLastChecked == 6) {return SPELL_ETHEREAL_VISAGE;}
    else if(nLastChecked == 7) {return SPELL_GLOBE_OF_INVULNERABILITY;}
    else if(nLastChecked == 8) {return SPELL_ENERGY_BUFFER;}
    else if(nLastChecked == 9) {return 443;} // greater sanctuary
    else if(nLastChecked == 10) {return SPELL_MINOR_GLOBE_OF_INVULNERABILITY;}
    else if(nLastChecked == 11) {return SPELL_SPELL_RESISTANCE;}
    else if(nLastChecked == 12) {return SPELL_STONESKIN;}
    else if(nLastChecked == 13) {return SPELL_LESSER_SPELL_MANTLE;}
    else if(nLastChecked == 14) {return SPELL_MESTILS_ACID_SHEATH;}
    else if(nLastChecked == 15) {return SPELL_MIND_BLANK;}
    else if(nLastChecked == 16) {return SPELL_ELEMENTAL_SHIELD;}
    else if(nLastChecked == 17) {return SPELL_PROTECTION_FROM_SPELLS;}
    else if(nLastChecked == 18) {return SPELL_PROTECTION_FROM_ELEMENTS;}
    else if(nLastChecked == 19) {return SPELL_RESIST_ELEMENTS;}
    else if(nLastChecked == 20) {return SPELL_DEATH_ARMOR;}
    else if(nLastChecked == 21) {return SPELL_GHOSTLY_VISAGE;}
    else if(nLastChecked == 22) {return SPELL_ENDURE_ELEMENTS;}
    else if(nLastChecked == 23) {return SPELL_SHADOW_SHIELD;}
    else if(nLastChecked == 24) {return SPELL_SHADOW_CONJURATION_MAGE_ARMOR;}
    else if(nLastChecked == 25) {return SPELL_NEGATIVE_ENERGY_PROTECTION;}
    else if(nLastChecked == 26) {return SPELL_SANCTUARY;}
    else if(nLastChecked == 27) {return SPELL_MAGE_ARMOR;}
    else if(nLastChecked == 28) {return SPELL_STONE_BONES;}
    else if(nLastChecked == 29) {return SPELL_SHIELD;}
    else if(nLastChecked == 30) {return SPELL_SHIELD_OF_FAITH;}
    else if(nLastChecked == 31) {return SPELL_LESSER_MIND_BLANK;}
    else if(nLastChecked == 32) {return SPELL_IRONGUTS;}
    else if(nLastChecked == 33) {return SPELL_RESISTANCE;}
    return nLastChecked;
}

int PRCRemoveProtections(int nSpell_ID, object oTarget, int nCount)
{
    // Declare major variables
    effect eProtection;
    int nCnt = 0;

    // Check if the target has any effects from the specified spell ID
    if (GetHasSpellEffect(nSpell_ID, oTarget))
    {
        // Start looping through all effects on the target
        eProtection = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eProtection))
        {
            // Only remove effects that:
            // - Match the given spell ID
            // - Are Magical (to comply with Breach spell behavior)
            if (GetEffectSpellId(eProtection) == nSpell_ID &&
                GetEffectSubType(eProtection) == SUBTYPE_MAGICAL)
            {
                RemoveEffect(oTarget, eProtection);
                nCnt++;
            }

            // Move to the next effect
            eProtection = GetNextEffect(oTarget);
        }
    }

    // Return 1 if any effects were removed, otherwise 0
    if (nCnt > 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

// This was dispelling Extraordinary, Supernatural & Unyielding effects -Jaysyn

/* int PRCRemoveProtections(int nSpell_ID, object oTarget, int nCount)
{
    //Declare major variables
    effect eProtection;
    int nCnt = 0;
    if(GetHasSpellEffect(nSpell_ID, oTarget))
    {
        //Search through the valid effects on the target.
        eProtection = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eProtection))
        {
            //If the effect was created by the spell then remove it
            if(GetEffectSpellId(eProtection) == nSpell_ID)
            {
                RemoveEffect(oTarget, eProtection);
                //return 1;
                nCnt++;
            }
            //Get next effect on the target
            eProtection = GetNextEffect(oTarget);
        }
    }
    if(nCnt > 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
} */

//------------------------------------------------------------------------------
// Attempts a dispel on one target, with all safety checks put in.
//------------------------------------------------------------------------------
void spellsDispelMagic(object oTarget, int nCasterLevel, effect eVis, effect eImpac, int bAll = TRUE, int bBreachSpells = FALSE)
{
    //--------------------------------------------------------------------------
    // Don't dispel magic on petrified targets
    // this change is in to prevent weird things from happening with 'statue'
    // creatures. Also creature can be scripted to be immune to dispel
    // magic as well.
    //--------------------------------------------------------------------------
    if (PRCGetHasEffect(EFFECT_TYPE_PETRIFY, oTarget) == TRUE || GetLocalInt(oTarget, "X1_L_IMMUNE_TO_DISPEL") == 10)
    {
        return;
    }

    effect eDispel;
    float fDelay = PRCGetRandomDelay(0.1, 0.3);
    int nId = PRCGetSpellId();

    //--------------------------------------------------------------------------
    // Fire hostile event only if the target is hostile...
    //--------------------------------------------------------------------------
    if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
    {

        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nId));
    }
    else
    {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nId, FALSE));
    }

    //--------------------------------------------------------------------------
    // GZ: Bugfix. Was always dispelling all effects, even if used for AoE
    //--------------------------------------------------------------------------
    if (bAll == TRUE )
    {
        eDispel = EffectDispelMagicAll(nCasterLevel);
        //----------------------------------------------------------------------
        // GZ: Support for Mord's disjunction
        //----------------------------------------------------------------------
        if (bBreachSpells)
        {
            PRCDoSpellBreach(oTarget, 6, 10, nId);
        }
    }
    else
    {
        eDispel = EffectDispelMagicBest(nCasterLevel);
        if (bBreachSpells)
        {
           PRCDoSpellBreach(oTarget, 2, 10, nId);
        }
    }

    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDispel, oTarget));
}

//------------------------------------------------------------------------------
// Handle Dispelling Area of Effects
// Before adding this AoE's got automatically destroyed. Since NWN does not give
// the required information to do proper dispelling on AoEs, we do some simulated
// stuff here:
// - Base chance to dispel is 25, 50, 75 or 100% depending on the spell
// - Chance is modified positive by the caster level of the spellcaster as well
// - as the relevant ability score
// - Chance is modified negative by the highest spellcasting class level of the
//   AoE creator and the releavant ability score.
// Its bad, but its not worse than just dispelling the AoE as the game did until
// now
//------------------------------------------------------------------------------
void spellsDispelAoE(object oTargetAoE, object oCaster, int nCasterLevel)
{
    object oCreator = GetAreaOfEffectCreator(oTargetAoE);
    int nChance;
    int nId   = PRCGetSpellId();
    int nClassCaster = PRCGetLastSpellCastClass();
    if ( nId == SPELL_LESSER_DISPEL )
    {
        nChance = 25;
    }
    else if ( nId == SPELL_DISPEL_MAGIC)
    {
        nChance = 50;
    }
    else if ( nId == SPELL_GREATER_DISPELLING )
    {
        nChance = 75;
    }
    else if ( nId == SPELL_MORDENKAINENS_DISJUNCTION )
    {
        nChance = 100;
    }


    nChance += ((nCasterLevel + (GetAbilityScoreForClass(nClassCaster, oCaster)-10)/2) - (GetCasterLevel(oCreator))); // yes this is a sucky stupid hack

    //--------------------------------------------------------------------------
    // the AI does cheat here, because it can not react as well as a player to
    // AoE effects. Also DMs are always successful
    //--------------------------------------------------------------------------
    if (!GetIsPC(oCaster))
    {
        nChance +=30;
    }

    if (oCaster == oCreator)
    {
        nChance = 100;
    }

    int nRand = Random(100);

    if ((nRand < nChance )|| GetIsDM(oCaster) || GetIsDMPossessed(oCaster))
    {
        FloatingTextStrRefOnCreature(100929,oCaster);  // "AoE dispelled"
        DestroyObject (oTargetAoE);
    }
    else
    {
        FloatingTextStrRefOnCreature(100930,oCaster); // "AoE not dispelled"
    }

}

int GetIsMystery(int nSpellId)
{
    // They're all next to one another in the 2da
    if (nSpellId >= 18352 && nSpellId < 18450)
        return TRUE;
    return FALSE;    
}

// Test main
//void main(){}
