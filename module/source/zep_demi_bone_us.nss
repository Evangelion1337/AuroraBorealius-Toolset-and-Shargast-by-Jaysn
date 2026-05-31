//:: ---------------------------------------------------
//:: Function name: zep_demi_bone_us
//:: Function intended usage: OnUsed script for use
//:: with CEP adaptation of Demigog's demilich.
//:: Script should be placed in the OnUsed hook of the
//:: Demilich's bones, by default found in Dungeons ->
//:: Tombs, Grave Markers -> Pile of Bones in the palette
//:: ---------------------------------------------------
//:: Creation date: April 21, 2004
//:: Code last modified on: April 24, 2004
//:: Author: Loki Hakanin
//:: ---------------------------------------------------
//:: Summary of effect:
//::    1.) Starts conversation with PC who used the
//::    bone pile.  This conversation is used to check if
//::    the demilich is regenerating and the PC has holy
//::    water.  If so, it lets the PC destroy it.  More
//::    details in the conversation and included scripts.
//::    This will fire one conversation if the PC is
//::    speaking to a regenerating demilich, and one if he
//::    is speaking to an active demilich's bones.
//::------------------------------------------------------
//::Included files: zep_inc_demi

#include "zep_inc_demi"

void main()
{
object oBonePile = OBJECT_SELF;  //Pile of bones
object oPC = GetLastUsedBy();    //PC using bones.
string sBonePileTag=GetTag(oBonePile);  //Tag of bones.
//If this placable has our special "regenerating" tag, we start
//the conversation describing it as such and giving possible
//options to destroy the demilich.
if (sBonePileTag==ZEP_DEMI_REGEN_SKULL)
    AssignCommand(oPC, ActionStartConversation(oBonePile, ZEP_DEMI_ONUSE_REGEN, FALSE, FALSE));
//Else we start a default conversation.
else AssignCommand(oPC, ActionStartConversation(oBonePile, ZEP_DEMI_ONUSE_CONV, FALSE, FALSE));
}
