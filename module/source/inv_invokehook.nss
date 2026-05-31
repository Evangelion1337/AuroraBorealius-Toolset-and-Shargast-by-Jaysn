//::///////////////////////////////////////////////
//:: Invocation Hook File.
//:: inv_invokehook.nss
//:://////////////////////////////////////////////
/*

    This file acts as a hub for all code that
    is hooked into the invocation scripts

*/
//:://////////////////////////////////////////////
//:: Created By: Fox
//:: Created On: 25-1-2008
//:://////////////////////////////////////////////

#include "prc_inc_spells"
#include "inv_inc_invfunc"
#include "x2_inc_spellhook"

// This function holds all functions that are supposed to run before the actual
// spellscript gets run. If this functions returns FALSE, the spell is aborted
// and the spellscript will not run
int PreInvocationCastCode();

// All invocations have somatic component so we will roll ASF check here
int InvocationASFCheck(object oInvoker, int nClass)
{
    int nASF = GetArcaneSpellFailure(oInvoker);

    // Warlocks ignore ASF chance while casting in light armor
    if(nClass == CLASS_TYPE_WARLOCK)
    {
        object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oInvoker);
        int nAC = GetBaseAC(oArmor);

        //armors
        switch(nAC)
        {
            case 1: nASF -=  5; break;//light
            case 2: nASF -= 10; break;//light
            case 3: nASF -= 20; break;//light
            //case 4: nASF -= GetHasFeat(FEAT_BATTLE_CASTER, oInvoker) ? 20 : 0; break;	//medium;
            //case 5: nASF -= GetHasFeat(FEAT_BATTLE_CASTER, oInvoker) ? 30 : 0; break;	//medium
			case 4: nASF = GetHasFeat(FEAT_BATTLE_CASTER, oInvoker) ? 0 : nASF; break;	//medium
			case 5: nASF = GetHasFeat(FEAT_BATTLE_CASTER, oInvoker) ? 0 : nASF; break; 	//medium;
            default: break;
        }
    }
    else if(nClass == CLASS_TYPE_DRAGON_SHAMAN)
    {
        //no ASF chance
        return TRUE;
    }

    if(Random(100) < nASF)
    {
        //52946 = Spell failed due to arcane spell failure!
        FloatingTextStrRefOnCreature(52946, oInvoker, FALSE);
        return FALSE;
    }

    return TRUE;
}

//------------------------------------------------------------------------------
// if FALSE is returned by this function, the spell will not be cast
// the order in which the functions are called here DOES MATTER, changing it
// WILL break the crafting subsystems
//------------------------------------------------------------------------------
int PreInvocationCastCode()
{
    object oInvoker = OBJECT_SELF;
    object oTarget = PRCGetSpellTargetObject();
    object oCastItem = GetSpellCastItem();
    int nInvokeId = PRCGetSpellId();
    int nInvokingClass = GetInvokingClass(oInvoker);
    int nInvokeLevel = GetInvocationLevel(oInvoker);
    int bInvokeIsHostile = Get2DACache("spells", "HostileSetting", nInvokeId) == "1";

    int nContinue = !ExecuteScriptAndReturnInt("prespellcode", oInvoker);

    //---------------------------------------------------------------------------
    // Block forsakers from using invocations 
    //---------------------------------------------------------------------------
	if(GetLevelByClass(CLASS_TYPE_FORSAKER, oInvoker) > 0)  
	{  
		SendMessageToPC(oInvoker, "Forsakers cannot use invocations.");  
		return FALSE;  
	}

    //---------------------------------------------------------------------------
    // Break any spell require maintaining concentration
    //---------------------------------------------------------------------------
    X2BreakConcentrationSpells();
    
    //---------------------------------------------------------------------------
    // No invoking while using expertise
    //---------------------------------------------------------------------------    
    if(nContinue)
    	if (GetActionMode(oInvoker, ACTION_MODE_EXPERTISE) || GetActionMode(oInvoker, ACTION_MODE_IMPROVED_EXPERTISE))
    		nContinue = FALSE;    

    //---------------------------------------------------------------------------
    // Check for PRC spell effects
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = PRCSpellEffects(oInvoker, oTarget, nInvokeId, nInvokeLevel, nInvokingClass, bInvokeIsHostile, -1);

    //---------------------------------------------------------------------------
    // Run Grappling Concentration Check
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = GrappleConc(oInvoker, nInvokeLevel);

    //---------------------------------------------------------------------------
    // Run ASF Check
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = InvocationASFCheck(oInvoker, nInvokingClass);

    //---------------------------------------------------------------------------
    // This stuff is only interesting for player characters we assume that use
    // magic device always works and NPCs don't use the crafting feats or
    // sequencers anyway. Thus, any NON PC spellcaster always exits this script
    // with TRUE (unless they are DM possessed or in the Wild Magic Area in
    // Chapter 2 of Hordes of the Underdark.
    //---------------------------------------------------------------------------
    if(!GetIsPC(oInvoker)
    && !GetPRCSwitch(PRC_NPC_HAS_PC_SPELLCASTING))
    {
        if(!GetIsDMPossessed(oInvoker) && !GetLocalInt(GetArea(oInvoker), "X2_L_WILD_MAGIC"))
        {
            return TRUE;
        }
    }

    //---------------------------------------------------------------------------
    // Run use magic device skill check
    //---------------------------------------------------------------------------
    if(nContinue)
    {
        nContinue = X2UseMagicDeviceCheck(oInvoker);
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
    && GetIsObjectValid(oCastItem)
    && !CheckPRCLimitations(oCastItem, oInvoker))
    {
        SendMessageToPC(oInvoker, "You cannot use "+GetName(oCastItem));
        nContinue = FALSE;
    }

    //Cleaning spell variables used for holding the charge
    if(!GetLocalInt(oInvoker, "PRC_SPELL_EVENT"))
    {
        DeleteLocalInt(oInvoker, "PRC_SPELL_CHARGE_COUNT");
        DeleteLocalInt(oInvoker, "PRC_SPELL_CHARGE_SPELLID");
        DeleteLocalObject(oInvoker, "PRC_SPELL_CONC_TARGET");
        DeleteLocalInt(oInvoker, "PRC_SPELL_METAMAGIC");
        DeleteLocalManifestation(oInvoker, "PRC_POWER_HOLD_MANIFESTATION");
        DeleteLocalMystery(oInvoker, "MYST_HOLD_MYST");
    }
    else if(GetLocalInt(oInvoker, "PRC_SPELL_CHARGE_SPELLID") != nInvokeId)
    {   //Sanity check, in case something goes wrong with the action queue
        DeleteLocalInt(oInvoker, "PRC_SPELL_EVENT");
    }

    return nContinue;
}

//:: void main (){}