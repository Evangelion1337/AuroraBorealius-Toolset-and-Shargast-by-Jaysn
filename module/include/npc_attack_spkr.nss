//::///////////////////////////////////////////////
//:: FileName npc_attack_spkr
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Oddbod
//:: Created On: 7/01/2002
//:://////////////////////////////////////////////

//: Include a generic behavior script Bioware gave us.
//: In this script it's just for the final command,
//: DetermineCombatRound
#include "nw_i0_generic"

void main()
{

//: Set objects for speaker and NPC

object oPC = GetPCSpeaker();
object oNPC = OBJECT_SELF;

//: If you would like the animosity to affect the NPC's entire faction, set the
//: next value to TRUE. If you want only the NPC to change, leave it FALSE

int nFactionChange = FALSE;

//: Set the following line to TRUE if you want the animosity to wear off
//: This is only if entire faction is NOT changing

int nDecay = FALSE;

//: Set how long it takes for the effect to wear off (if above is true)

float fDecayTime = 10.0;

//: Check for entire Faction Change flag

if (nFactionChange){

SetPlotFlag(oNPC, FALSE); //: Required before changing faction of a plot NPC

AdjustReputation(oPC, oNPC, -100);

//: If you would like the NPC to remain vulerable once the attack starts,
//: comment out the next line

SetPlotFlag(oNPC, TRUE);

}

else{

SetIsTemporaryEnemy(oPC,oNPC,nDecay,fDecayTime);

}

//: And finally, force initiating combat mode

DetermineCombatRound(oPC);

}
