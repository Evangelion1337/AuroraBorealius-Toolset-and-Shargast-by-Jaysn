//::///////////////////////////////////////////////
//:: Shadowcasting Mystery Hook File.
//:: shd_mysthook.nss
//:://////////////////////////////////////////////
/*

    This file acts as a hub for all code that
    is hooked into the mystery scripts for Shadowcasting

*/
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:: Created On: 7-2-2019
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"
#include "prc_inc_spells"
#include "inc_utility"
#include "prc_inc_itmrstr"
#include "shd_inc_shdfunc"
#include "lookup_2da_spell"

// This function holds all functions that are supposed to run before the actual
// spellscript gets run. If this functions returns FALSE, the spell is aborted
// and the spellscript will not run
int ShadPreMystCastCode();

// Does the counterspelling for Warp Spell,
// and the storing of the spell for later use
int WarpMyst(object oCaster, int nMyst)
{
    int nWarp = GetLocalInt(oCaster, "WarpSpell");
    // If Warp Spell isn't set, just keep going
    if (!nWarp) return TRUE;
    
    object oShadow = GetLocalObject(oCaster, "WarpSpell"); // The one who cast Warp Spell
    
    DeleteLocalInt(oCaster, "WarpSpell");
    DeleteLocalObject(oCaster, "WarpSpell");
    
    int nLevel = GetShadowcasterLevel(oCaster);
    if (d20() + nWarp > d20() + nLevel) // Won the caster level check
    {
        // Set a marker on the Shadowcaster
        SetLocalInt(oShadow, "WarpSpellSuccess", TRUE);  
        FloatingTextStringOnCreature("You have successfully warped your opponent's "+GetMysteryName(nMyst), oShadow, FALSE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUL_TRAP), oCaster);
        return FALSE;
    }
    
    FloatingTextStringOnCreature("Your warp spell has failed", oShadow, FALSE);
    return TRUE;
}

// Stores the spell for use with Echo Spell
void EchoMyst(object oCaster, int nMyst)
{
    int nEcho = GetLocalInt(oCaster, "EchoSpell");
    // If Echo Spell isn't set, just skip
    if (nEcho)
    {   
        object oShadow = GetLocalObject(oCaster, "EchoSpell"); // The one who cast Echo Spell
        SetLocalInt(oShadow, "EchoedSpell", nMyst);
        FloatingTextStringOnCreature("You have echoed " + GetMysteryName(nMyst) + " and have one round to cast it", oShadow, FALSE);
        DelayCommand(9.0, DeleteLocalInt(oShadow, "EchoedSpell"));
        DeleteLocalInt(oCaster, "EchoSpell");
        DeleteLocalObject(oCaster, "EchoSpell"); 
    }
}

int MysterySpellFailure(object oShadow, int nMystId, int nMystLevel, int nClass)
{
    // Mysteries of both types ignore arcane spell failure
    if (GetIsMysterySupernatural(oShadow, nMystId, nClass) || GetIsMysterySLA(oShadow, nMystId, nClass))
        return TRUE;

    int nASF = GetArcaneSpellFailure(oShadow);

    if(Random(100) < nASF)
    {
        int nFail = TRUE;
        // Still spell helps
        if((GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_1, oShadow) && nMystLevel <= 3)
        || (GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_2, oShadow) && nMystLevel <= 6)
        || (GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_3, oShadow) && nMystLevel <= 9))
        {
            nFail = FALSE;
        }
        if(nFail)
        {
            //52946 = Spell failed due to arcane spell failure!
            FloatingTextStrRefOnCreature(52946, oShadow, FALSE);
            return FALSE;
        }
    }
    return TRUE;
}

int ShadowTime(object oCaster, object oTarget, int bSpellIsHostile)
{
    // PnP Timestop
    if(GetPRCSwitch(PRC_TIMESTOP_NO_HOSTILE))
    {
        if(GetHasSpellEffect(SPELL_TIME_STOP, oCaster)
        || GetHasSpellEffect(4032, oCaster)          //epic spell: Greater Timestop
        || GetHasSpellEffect(14236, oCaster)         //psionic power: Temporal Acceleration
        || GetHasSpellEffect(18428, oCaster))        //Mystery MYST_SHADOW_TIME
        {
            if(!GetIsObjectValid(oTarget)
            || oTarget != oCaster
            || bSpellIsHostile)
            {
                return FALSE;
            }
        }
    }
    
    return TRUE;
}    

//------------------------------------------------------------------------------
// if FALSE is returned by this function, the spell will not be cast
// the order in which the functions are called here DOES MATTER, changing it
// WILL break the crafting subsystems
//------------------------------------------------------------------------------
int ShadPreMystCastCode()
{
    object oShadow = OBJECT_SELF;
    object oTarget = PRCGetSpellTargetObject();
    int nMystID = PRCGetSpellId();
    int nMystLevel = GetMysteryLevel(oShadow);
    int nShadowcastingClass = GetShadowcastingClass(oShadow);
    int bMystIsHostile = Get2DACache("spells", "HostileSetting", nMystID) == "1";

    int nContinue = !ExecuteScriptAndReturnInt("prespellcode",oShadow);

    //---------------------------------------------------------------------------
    // Block forsakers from using shadowcasting
    //---------------------------------------------------------------------------
	if(GetLevelByClass(CLASS_TYPE_FORSAKER, oShadow) > 0)  
	{  
		SendMessageToPC(oShadow, "Forsakers cannot use the power of shadowcasting.");  
		return FALSE;  
	}
	
    //---------------------------------------------------------------------------
    // Break any spell require maintaining concentration
    //---------------------------------------------------------------------------
    X2BreakConcentrationSpells();

    //---------------------------------------------------------------------------
    // Check for PRC spell effects
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = PRCSpellEffects(oShadow, oTarget, nMystID, nMystLevel, nShadowcastingClass, bMystIsHostile, -1);
        
    if(DEBUG) DoDebug("ShadPreMystCastCode nContinue #1: " + IntToString(nContinue));
        
    //---------------------------------------------------------------------------
    // Run Arcane Spell Failure
    //---------------------------------------------------------------------------
    if (nContinue)
        nContinue = MysterySpellFailure(oShadow, nMystID, nMystLevel, nShadowcastingClass);  
        
    if(DEBUG) DoDebug("ShadPreMystCastCode nContinue #2: " + IntToString(nContinue));    
        
    //---------------------------------------------------------------------------
    // Run Shadow Time
    //---------------------------------------------------------------------------
    if (nContinue)
        nContinue = ShadowTime(oShadow, oTarget, bMystIsHostile);  
        
    if(DEBUG) DoDebug("ShadPreMystCastCode nContinue #3: " + IntToString(nContinue));            

    //---------------------------------------------------------------------------
    // Run Grappling Concentration Check
    //---------------------------------------------------------------------------
    if (nContinue)
        nContinue = GrappleConc(oShadow, nMystLevel);
        
    if(DEBUG) DoDebug("ShadPreMystCastCode nContinue #4: " + IntToString(nContinue));            

    //---------------------------------------------------------------------------
    // This stuff is only interesting for player characters we assume that use
    // magic device always works and NPCs don't use the crafting feats or
    // sequencers anyway. Thus, any NON PC spellcaster always exits this script
    // with TRUE (unless they are DM possessed or in the Wild Magic Area in
    // Chapter 2 of Hordes of the Underdark.
    //---------------------------------------------------------------------------
    if(!GetIsPC(oShadow)
    && !GetPRCSwitch(PRC_NPC_HAS_PC_SPELLCASTING))
    {
        if(!GetIsDMPossessed(oShadow) && !GetLocalInt(GetArea(oShadow), "X2_L_WILD_MAGIC"))
        {
            return TRUE;
        }
    }

    //---------------------------------------------------------------------------
    // Run use magic device skill check
    //---------------------------------------------------------------------------
    if (nContinue)
    {
        nContinue = X2UseMagicDeviceCheck(oShadow);
    }

    //-----------------------------------------------------------------------
    // run any user defined spellscript here
    //-----------------------------------------------------------------------
    if (nContinue)
    {
        nContinue = X2RunUserDefinedSpellScript();
    }

    //---------------------------------------------------------------------------
    // Check for the new restricted itemproperties
    //---------------------------------------------------------------------------
    if(nContinue
    && GetIsObjectValid(GetSpellCastItem())
    && !CheckPRCLimitations(GetSpellCastItem(), oShadow))
    {
        SendMessageToPC(oShadow, "You cannot use "+GetName(GetSpellCastItem()));
        nContinue = FALSE;
    }
    
    //---------------------------------------------------------------------------
    // Warp Spell
    //---------------------------------------------------------------------------    
    if (nContinue)
    {
        nContinue = WarpMyst(oShadow, nMystID);
    } 
    
    if(DEBUG) DoDebug("ShadPreMystCastCode nContinue #5: " + IntToString(nContinue));    
    
    EchoMyst(oShadow, nMystID);

    //---------------------------------------------------------------------------
    // The following code is only of interest if an item was targeted
    //---------------------------------------------------------------------------
    if (GetIsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_ITEM)
    {

        //-----------------------------------------------------------------------
        // Check if spell was used to trigger item creation feat
        //-----------------------------------------------------------------------
        if (nContinue) {
            nContinue = !ExecuteScriptAndReturnInt("x2_pc_craft", oShadow);
        }

        //-----------------------------------------------------------------------
        // * Execute item OnSpellCast At routing script if activated
        //-----------------------------------------------------------------------
        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS) == TRUE)
        {
            SetUserDefinedItemEventNumber(X2_ITEM_EVENT_SPELLCAST_AT);
            int nRet = ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oTarget), oShadow);
            if (nRet == X2_EXECUTE_SCRIPT_END)
            {
                return FALSE;
            }
        }

        //-----------------------------------------------------------------------
        // Prevent any spell that has no special coding to handle targetting of items
        // from being cast on items. We do this because we can not predict how
        // all the hundreds spells in NWN will react when cast on items
        //-----------------------------------------------------------------------
        if (nContinue) {
            nContinue = X2CastOnItemWasAllowed(oTarget);
        }
    }

    //Cleaning spell variables used for holding the charge
    if(!GetLocalInt(oShadow, "PRC_SPELL_EVENT"))
    {
        DeleteLocalInt(oShadow, "PRC_SPELL_CHARGE_COUNT");
        DeleteLocalInt(oShadow, "PRC_SPELL_CHARGE_SPELLID");
        DeleteLocalObject(oShadow, "PRC_SPELL_CONC_TARGET");
        DeleteLocalInt(oShadow, "PRC_SPELL_METAMAGIC");
        DeleteLocalManifestation(oShadow, "PRC_POWER_HOLD_MANIFESTATION");
        DeleteLocalMystery(oShadow, "MYST_HOLD_MYST");
    }
    else if(GetLocalInt(oShadow, "PRC_SPELL_CHARGE_SPELLID") != PRCGetSpellId())
    {   //Sanity check, in case something goes wrong with the action queue
        DeleteLocalInt(oShadow, "PRC_SPELL_EVENT");
    }

    if(DEBUG) DoDebug("ShadPreMystCastCode nContinue #6: " + IntToString(nContinue));    
    return nContinue;
}

//:: void main (){}
