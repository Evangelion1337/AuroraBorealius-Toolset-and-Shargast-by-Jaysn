//::----------------------------------------------------------
//:: Function Name: zep_demi_dest
//:: Function use: Function is called from conversation upon
//:: destruction of our demilich.  This will finally destroy the
//:: demilich permanently, and play some VFX and explantory
//:: text to describe the souls of its freed victims returning
//:: to their bodies.
//::----------------------------------------------------------
//:: Created on: April 25th, 2004
//:: Code last modified on: April 27th, 2004.
//:: Author: Loki Hakanin
//::----------------------------------------------------------
//:: Summary of Effects:
//::    1.) Causes destroying PC to crouch over the bones.
//::    2.) Display some floating text on our demilich's bones
//::        to explain what's going on.
//::    3.) Play some VFX of the Demilich's soul departing this
//::        plane, and of it's victims returning to their
//::        bodies.
//::    4.) Notify those victims of their restored status.
//::    5.) Resurrect victims, if a flag to do so is set.
//::    6.) Destroy the Demilich's bone and dust cloud placables
//::        to prevent it from further respawning.
//::-----------------------------------------------------------
//:: Included files: zep_inc_demi

#include "zep_inc_demi"
#include "zep_inc_scrptdlg"

void main()
{
//First we'll get the PC and Demilich bones he's destroying.
object oDestroyingPC=GetPCSpeaker();
object oDemilichBones=GetNearestObjectByTag(ZEP_DEMI_REGEN_SKULL,oDestroyingPC);
object oDemilichDust=GetNearestObjectByTag(ZEP_DEMI_DUST_TAG,oDemilichBones);

//We'll have the PC play the crouching grab animation to mimic
//crouching down to interact wiht the demilich's bones.
AssignCommand(oDestroyingPC,ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW,1.0,3.0));

//Now we'll display some floating text over the PC who did
//the Demilich in.  Will also play some VFX there to show
//our demilich's soul departing.
FloatingTextStringOnCreature(ZEP_DEMI_FINAL_DEST,oDestroyingPC);
SendMessageToPC(oDestroyingPC,ZEP_DEMI_FINAL_DEST);
effect eWailOfBansheeVFX = EffectVisualEffect(VFX_FNF_WAIL_O_BANSHEES,FALSE);
ApplyEffectToObject(DURATION_TYPE_INSTANT,eWailOfBansheeVFX,oDemilichBones);

//Now we'll use a loop to display some more VFX going out
//towards our demlich's victims.  As in Demigog's original
//script, we'll use the VFX for "Phantasmal Killer".  Since
//we can't display the VFX directly, we'll have the bones
//cast a fake spell.  At each victim, we'll play a "greater
//restoration" effect and display them a message explaining
//the situation.  Last, if the flag for it is enabled, we'll
//bring them back to life automatically.
//Loop structure similar to that used throughout demilich
//scripts, so no real explanation should be necessary.
int nLoopCounter = 0;
int nNumSouls=GetLocalInt(oDemilichBones,"NumSouls");
object oVictimCounter;
string sVariableName;
location lLocationCounter;
effect eGreaterRestoration=EffectVisualEffect(VFX_IMP_RESTORATION_GREATER);

for (nLoopCounter = 0; nLoopCounter <= nNumSouls; nLoopCounter++)
    {
    sVariableName=("GemVictim" + (IntToString(nLoopCounter)));
    oVictimCounter = GetLocalObject(oDemilichBones,sVariableName);
    lLocationCounter = GetLocation(oVictimCounter);
    ActionCastFakeSpellAtLocation(SPELL_PHANTASMAL_KILLER,lLocationCounter,PROJECTILE_PATH_TYPE_DEFAULT);
    ApplyEffectToObject(DURATION_TYPE_INSTANT,eGreaterRestoration,oVictimCounter);

    //If the "resurrect victims" flag (ZEP_DEMI_RESS_VICTIMS)
    //is true, we resurrect the victims for free.
    if (ZEP_DEMI_RESS_VICTIMS == TRUE)
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints(oVictimCounter)),oVictimCounter);

    //If victim is PC, send message to explain their situation.
    if (GetIsPC(oVictimCounter))
        {
        string sMessageToPC = GetStringByStrRef(nZEPReturnToLife,GENDER_MALE);
        SendMessageToPC(oVictimCounter,sMessageToPC);
        }
    }


//Finally, destroy placables of Demilich bones and dust.
DestroyObject(oDemilichDust,1.0);
DestroyObject(oDemilichBones,1.0);
}
