//::///////////////////////////////////////////////
//:: Psionic include: Psicraft Skill
//:: psi_inc_psicraft
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to the Psicraft skill
    
    Functions below are called by the manifester as
    he makes a power.

    @author Stratovarius
    @date   Created - 2008.9.17
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// Constants are provided via psi_inc_core

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Returns the power that the manifester just used
 * @param oManifester The power manifester
 * @param nPowerId    Power to check
 *
 * @return           nothing, uses SendMessageToPC to give results
 */
void IdentifyPower(object oManifester, int nPowerId);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

// Always access via psi_inc_psifunc.

#include "psi_inc_core"
#include "inc_2dacache"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _DoPsicraftCheck(object oManifester, object oCheck, int nPowerLevel, int nPowerId)
{
	// NPCs wouldn't benefit from being told the name of the maneuver
	if (!GetIsPC(oCheck)) return;
	
	// Roll the check
	if(GetIsSkillSuccessful(oCheck, SKILL_PSICRAFT, 10 + nPowerLevel))
	{	// get the name of the manifester and power
		FloatingTextStringOnCreature(GetName(oManifester) + " manifests " + GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nPowerId))), oCheck, FALSE);
	}
	else // Skill check failed
	{
		FloatingTextStringOnCreature(GetName(oManifester) + " manifests unknown power", oCheck, FALSE);
	}
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void IdentifyPower(object oManifester, int nPowerId)
{
	int nPowerLevel = GetPowerLevel(oManifester);

	// The area to check for martial lore users
	object oTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, GetLocation(oManifester), TRUE, OBJECT_TYPE_CREATURE);
	//Cycle through the targets within the spell shape until an invalid object is captured.
	while (GetIsObjectValid(oTarget) && oTarget != oManifester)
	{
		// If the target has points in the skill
		if (GetSkillRank(SKILL_PSICRAFT, oTarget) > 0) _DoPsicraftCheck(oManifester, oTarget, nPowerLevel, nPowerId);
		
	//Select the next target within the area.
	oTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, GetLocation(oManifester), TRUE, OBJECT_TYPE_CREATURE);
	}
}