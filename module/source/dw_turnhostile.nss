//::///////////////////////////////////////////////
//:: FileName dw_turnhostile
//:: Copyright (c) 2004 Dreamwarder
//:://////////////////////////////////////////////
/*
   Generic turn hostile script that makes the npc speaker hostile
   to the PC speaker.
*/
//:://////////////////////////////////////////////
//:: Created By: Dreamwarder
//:: Created On: 03 May 2004
//:://////////////////////////////////////////////


#include "nw_i0_generic"
void main()
{
object oPC = GetPCSpeaker();
object oTarget = OBJECT_SELF;

SetIsTemporaryEnemy(oPC, oTarget);
AssignCommand(oTarget, ActionAttack(oPC));
AssignCommand(oTarget, DetermineCombatRound(oPC));

}

