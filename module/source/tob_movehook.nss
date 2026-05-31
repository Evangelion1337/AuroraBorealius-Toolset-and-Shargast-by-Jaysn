//::///////////////////////////////////////////////
//:: Tome of Battle Maneuver Hook File.
//:: tob_movehook.nss
//:://////////////////////////////////////////////
/*
    This file acts as a hub for all code that
    is hooked into the maneuver scripts for Tome of Battle
*/
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:: Created On: 19-3-2007
//:://////////////////////////////////////////////

#include "prc_inc_spells"
#include "inc_utility"
#include "x2_inc_spellhook"
#include "tob_inc_tobfunc"

// This function holds all functions that are supposed to run before the actual
// spellscript gets run. If this functions returns FALSE, the spell is aborted
// and the spellscript will not run
int PreManeuverCastCode();

int NullPsionicsField(object oInitiator, object oTarget)
{
    // Null Psionics Field/Anti-Magic Field
    if(GetHasSpellEffect(SPELL_ANTIMAGIC_FIELD, oInitiator)
    || GetHasSpellEffect(POWER_NULL_PSIONICS_FIELD, oInitiator))
    {
         return FALSE;
    }
    return TRUE;
}

void AttackManeuverTarget(object oInitiator, object oTarget)
{
    // Don't do anything while outside of combat
    if (!GetIsInCombat(oInitiator)) return;

    // If you hit a valid enemy
    if (GetIsObjectValid(oTarget) && GetIsEnemy(oTarget))
        AssignCommand(oInitiator, ActionAttack(oTarget));
    else //Otherwise find someone
    {    
        location lTarget = GetLocation(oInitiator);
    
        // Use the function to get the closest creature as a target
        oTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oTarget))
        {
            if(GetIsEnemy(oTarget)) // Only enemies
            {
                AssignCommand(oInitiator, ActionAttack(oTarget));
                break;
            }
        //Select the next target within the spell shape.
        oTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        }
    }    
}

//------------------------------------------------------------------------------
// if FALSE is returned by this function, the spell will not be cast
// the order in which the functions are called here DOES MATTER, changing it
// WILL break the crafting subsystems
//------------------------------------------------------------------------------
int PreManeuverCastCode()
{
    object oInitiator = OBJECT_SELF;
    object oTarget = PRCGetSpellTargetObject();
    int nMoveId = PRCGetSpellId();
    int nContinue;

    DeleteLocalInt(oInitiator, "SpellConc");
    nContinue = !ExecuteScriptAndReturnInt("premovecode", oInitiator);

    //---------------------------------------------------------------------------
    // Shutdown maneuvers if the PC blocks delayed damage
    //---------------------------------------------------------------------------    
    if(nContinue)
    	nContinue = !GetLocalInt(oInitiator, "CrusaderBreak");
	//---------------------------------------------------------------------------  
	// Forsakers can't use supernatural maneuvers  
	//---------------------------------------------------------------------------  
	if (nContinue && GetIsManeuverSupernatural(nMoveId) && GetLevelByClass(CLASS_TYPE_FORSAKER, oInitiator))  
	{  
		FloatingTextStringOnCreature("Forsakers cannot use supernatural maneuvers!", oInitiator, FALSE);  
		nContinue = FALSE;  
	}  
    //---------------------------------------------------------------------------
    // Run NullPsionicsField Check
    //---------------------------------------------------------------------------
    if (nContinue && GetIsManeuverSupernatural(nMoveId))
        nContinue = NullPsionicsField(oInitiator, oTarget);  
    //---------------------------------------------------------------------------
    // Run Dark Discorporation Check
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = !GetLocalInt(oInitiator, "DarkDiscorporation");
        
    //---------------------------------------------------------------------------
    // Swordsage Insightful Strike, grants wisdom to damage on maneuvers
    // Test and local to avoid spaghetti monster
    //---------------------------------------------------------------------------
    if (GetLevelByClass(CLASS_TYPE_SWORDSAGE, oInitiator) >= 4) 
    {
        if(GetHasInsightfulStrike(oInitiator)) SetLocalInt(oInitiator, "InsightfulStrike", TRUE);
        DelayCommand(2.0, DeleteLocalInt(oInitiator, "InsightfulStrike"));
    }
    //---------------------------------------------------------------------------
    // Blade Meditation, +1 damage with the preferred weapons of chosen discipline
    // Test and local to avoid spaghetti monster
    //---------------------------------------------------------------------------
    if (BladeMeditationDamage(oInitiator, nMoveId)) 
    {
        SetLocalInt(oInitiator, "BladeMeditationDamage", TRUE);
        DelayCommand(2.0, DeleteLocalInt(oInitiator, "BladeMeditationDamage"));
    }    
    //---------------------------------------------------------------------------
    // Instant Clarity, gain psionic focus when successfully initiating a strike
    // Test and local to avoid spaghetti monster
    //---------------------------------------------------------------------------
    if (GetManeuverType(nMoveId) == MANEUVER_TYPE_STRIKE && nContinue && GetHasFeat(FEAT_INSTANT_CLARITY, oInitiator)) 
    {
        SetLocalInt(oInitiator, "InstantClaritySwitch", 2);
        ExecuteScript("tob_ft_istntclty", oInitiator);
    } 
    
    float fDistance = MetersToFeet(GetDistanceBetweenLocations(GetLocation(oInitiator), GetLocation(oTarget)));
    float fDelay = FeetToMeters(fDistance)/10;
    DelayCommand(fDelay+0.25f, AttackManeuverTarget(oInitiator, oTarget));

    return nContinue;
}

