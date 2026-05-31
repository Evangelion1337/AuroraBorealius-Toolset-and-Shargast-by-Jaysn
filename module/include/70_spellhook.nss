//::///////////////////////////////////////////////
//:: Community Patch 1.71: Improve Spell Hook Include File
//:: 70_spellhook
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

    This file acts as a hub for all code that
    is hooked into the nwn spellscripts'

    If you want to implement material components
    into spells or add restrictions to certain
    spells, this is the place to do it.

*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 2012-01-17
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"

int MusicalInstrumentsCheck(object oItem)
{
    int bRulesApply = GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES;
    if(bRulesApply)
    {
        switch(GetLocalInt(GetModule(),"71_RESTRICT_MUSICAL_INSTRUMENTS"))
        {
            case 1://perform based
                if(GetSkillRank(SKILL_PERFORM) > -1)
                {
                    int nDC = GetLocalInt(oItem,"MUSICAL_INSTRUMENT_DC");
                    if(!nDC)
                    {
                        nDC = 7+3*StringToInt(Get2DAString("des_crft_spells","Level",GetSpellId()));
                    }
                    if(!GetIsSkillSuccessful(OBJECT_SELF, SKILL_PERFORM, nDC))
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE), OBJECT_SELF);
                        return FALSE;
                    }
                }
                else
                {
                    FloatingTextStrRefOnCreature(8288,OBJECT_SELF,FALSE);//you cannot use this skill
                    return FALSE;
                }
            break;
            case 2://song feat based
                if(GetHasFeat(FEAT_BARD_SONGS))
                {
                    DecrementRemainingFeatUses(OBJECT_SELF,FEAT_BARD_SONGS);
                }
                else
                {
                    FloatingTextStrRefOnCreature(40063,OBJECT_SELF,FALSE);
                    return FALSE;
                }
            break;
        }
    }
    int bDeaf;
    effect e1 = GetNextEffect(OBJECT_SELF);//part1 check for silence effect
    while(GetIsEffectValid(e1))
    {
        switch(GetEffectType(e1))
        {
            case EFFECT_TYPE_SILENCE:
            FloatingTextStrRefOnCreature(85764,OBJECT_SELF); // not useable when silenced
            return FALSE;
            case EFFECT_TYPE_DEAF:
            bDeaf = TRUE;
            break;
        }
        e1 = GetNextEffect(OBJECT_SELF);
    }
    if(bDeaf && bRulesApply && d100() < 21)// 20% chance to fail under deafness
    {
        FloatingTextStrRefOnCreature(83576,OBJECT_SELF); //* You can not concentrate on using this ability effectively *
        return FALSE;
    }
    string music = GetLocalString(oItem,"MUSICAL_INSTRUMENT_SOUND");
    if(music == "")
    {
        music = "sdr_bardsong";
    }
    PlaySound(music);
    return TRUE;
}

//------------------------------------------------------------------------------
// if X2_EXECUTE_SCRIPT_END is set by this script, the original spell will not be cast
// the order in which the functions are called here DOES MATTER, changing it
// WILL break the crafting subsystems
//------------------------------------------------------------------------------
void main()
{
   object oTarget = GetSpellTargetObject();
   object oItem = GetSpellCastItem();

   if(oItem != OBJECT_INVALID)
   {
       int spellOverride = GetLocalInt(oItem,"ITEM_SPELL_OVERRIDE");
       if(spellOverride != 0 && !GetLocalInt(GetModule(),"SPELL_OVERRIDE_FINISHED"))
       {
           SetLocalInt(GetModule(),"SPELL_OVERRIDE_FINISHED",TRUE);
           ExecuteScript(Get2DAString("spells","ImpactScript",spellOverride < 0 ? 0 : spellOverride),OBJECT_SELF);
           SetLocalInt(GetModule(),"SPELL_OVERRIDE_FINISHED",FALSE);
           SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
           return;
       }
   }
   else//metamagic exploit handling
   {
       int nMeta = GetMetaMagicFeat();
       if((nMeta == METAMAGIC_EMPOWER && !GetHasFeat(FEAT_EMPOWER_SPELL)) || (nMeta == METAMAGIC_MAXIMIZE && !GetHasFeat(FEAT_MAXIMIZE_SPELL)))
       {
           effect e = GetFirstEffect(OBJECT_SELF);
           nMeta = -1;
           while(GetIsEffectValid(e))
           {
               if(GetEffectType(e) == EFFECT_TYPE_POLYMORPH)//if used in polymorph nothing happens, CP fixes this exploit in engine
               {
                   nMeta = 0;
                   break;
               }
           }
       }
       else if((nMeta == METAMAGIC_EXTEND && !GetHasFeat(FEAT_EXTEND_SPELL)) || (nMeta == METAMAGIC_QUICKEN && !GetHasFeat(FEAT_QUICKEN_SPELL)) ||
              (nMeta == METAMAGIC_SILENT && !GetHasFeat(FEAT_SILENCE_SPELL)) || (nMeta == METAMAGIC_STILL && !GetHasFeat(FEAT_STILL_SPELL)))
       {
               nMeta = -1;
       }
       if(nMeta < 0)
       {
           //block the spell for exploit abuse
           FloatingTextStrRefOnCreature(3734,OBJECT_SELF,FALSE);//prints "Spell failed!"
           SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
           return;
       }
   }
   //---------------------------------------------------------------------------
   // This small addition will check to see if the target is mounted and the
   // spell is therefor one that should not be permitted.
   //---------------------------------------------------------------------------
   if(!GetLocalInt(GetModule(),"X3_NO_SHAPESHIFT_SPELL_CHECK"))
   { // do check for abort due to being mounted check
       switch(GetPhenoType(oTarget))
       {// shape shifting not allowed while mounted
       case 3:
       case 5:
       case 6:
       case 8:
        if(X3ShapeShiftSpell(oTarget))
        {
           if(GetIsPC(oTarget))
           {
           FloatingTextStrRefOnCreature(111982,oTarget,FALSE);
           }
        SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
        return;
        }// shape shifting not allowed while mounted
       break;
       }
   } // do check for abort due to being mounted check


   //---------------------------------------------------------------------------
   // This stuff is only interesting for player characters we assume that use
   // magic device always works and NPCs don't use the crafting feats or
   // sequencers anyway. Thus, any NON PC spellcaster always exits this script
   // with TRUE (unless they are DM possessed or in the Wild Magic Area in
   // Chapter 2 of Hordes of the Underdark.
   //---------------------------------------------------------------------------
   if (!GetIsPC(OBJECT_SELF))
   {
       if( !GetIsDMPossessed(OBJECT_SELF) && !GetLocalInt(GetArea(OBJECT_SELF), "X2_L_WILD_MAGIC"))
       {
            return;
       }
   }

   //---------------------------------------------------------------------------
   // Break any spell require maintaining concentration (only black blade of
   // disaster)
   // /*REM*/ X2BreakConcentrationSpells();
   //---------------------------------------------------------------------------

   //---------------------------------------------------------------------------
   // Run use magic device skill check
   //---------------------------------------------------------------------------
   int nContinue = X2UseMagicDeviceCheck();

   if (nContinue)
   {
       //-----------------------------------------------------------------------
       // run any user defined spellscript here
       //-----------------------------------------------------------------------
       nContinue = X2RunUserDefinedSpellScript();
   }

   //---------------------------------------------------------------------------
   // The following code is only of interest if an item was targeted
   //---------------------------------------------------------------------------
   if (GetIsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_ITEM)
   {
       //-----------------------------------------------------------------------
       // Check if spell was used to trigger item creation feat
       //-----------------------------------------------------------------------
       if (nContinue)
       {
           nContinue = !ExecuteScriptAndReturnInt("x2_pc_craft",OBJECT_SELF);
       }

       //-----------------------------------------------------------------------
       // Check if spell was used for on a sequencer item
       //-----------------------------------------------------------------------
       if (nContinue)
       {
           nContinue = !X2GetSpellCastOnSequencerItem(oTarget);
       }

       //-----------------------------------------------------------------------
       // * Execute item OnSpellCast At routing script if activated
       //-----------------------------------------------------------------------
       if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS))
       {
           SetUserDefinedItemEventNumber(X2_ITEM_EVENT_SPELLCAST_AT);
           int nRet = ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oTarget),OBJECT_SELF);
           if (nRet == X2_EXECUTE_SCRIPT_END)
           {
               SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
               return;
           }
       }

       //-----------------------------------------------------------------------
       // Prevent any spell that has no special coding to handle targetting of items
       // from being cast on items. We do this because we can not predict how
       // all the hundreds spells in NWN will react when cast on items
       //-----------------------------------------------------------------------
       if (nContinue)
       {
           nContinue = X2CastOnItemWasAllowed(oTarget);
       }
   }

   if(GetLocalInt(oItem,"MUSICAL_INSTRUMENT"))//variable indicating musical instrument
   {
       nContinue = MusicalInstrumentsCheck(oItem);
   }


   SetExecutedScriptReturnValue(!nContinue);
}
