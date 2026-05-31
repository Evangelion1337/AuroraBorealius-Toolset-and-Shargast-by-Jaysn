//::///////////////////////////////////////////////
//:: FileName dw_mutantperc
//:: Copyright (c) 2004 Dreamwarder
//:://////////////////////////////////////////////
/*
     On percieved script for guards on the lookout for mutants (half orcs)
*/
//:://////////////////////////////////////////////
//:: Created By: Dreamwarder
//:: Created On: 03 May 2004
//:://////////////////////////////////////////////
#include "prc_inc_racial"

void main()
{

object oPC = GetLastPerceived();
object oHelmet = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
object oGuard = OBJECT_SELF;

//Check that the last creature spotted was a PC
if (!GetIsPC(oPC)) return;

//Check that the guard "saw" the last PC spotted (ie they weren't invisible)
if (!GetLastPerceptionSeen()) return;

//Check to see if the last PC spotted was a half orc, and that they weren't wearing a helmet
if (((MyPRCGetRacialType(oPC)==RACIAL_TYPE_HALFORC)) && (oHelmet == OBJECT_INVALID))
    {
    //if the last pc spotted was a half orc, and if they weren't wearing a helmet
    //(ie the guard got to see their face) then the guard will approach and question the PC
    //(triggering the conversation "dw_mutant" - not you can alter this conversation to suit
    //your needs, or change the line below to specify a different conversation file.
    AssignCommand(oGuard, ActionStartConversation(oPC, "dw_mutant"));
    }
}
