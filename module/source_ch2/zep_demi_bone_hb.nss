//:: ---------------------------------------------------
//:: Function name: zep_demi_bone_hb
//:: Function intended usage: OnHeartbeat script for use
//:: with CEP adaptation of Demigog's demilich. This script
//:: should be atached to the demilich's bones placable
//:: found under "Dungeons->Tombs, Grave Markers ->
//:: Pile of Bones" by default in the toolset.
//:: ---------------------------------------------------
//:: Creation date: April 21, 2004
//:: Code last modified on: April 27, 2004
//:: Author: Loki Hakanin
//:: ---------------------------------------------------
//:: Summary of effect:
//::    1.) If the Demilich is just "resting", will re-slay
//::    any resurrected soul-gem vicitms.  Note this is a
//::    workaround for this version of the Demilich being
//::    self-contained and not requiring any module event
//::    scripts.
//::    1a.) The demilich will also respawn and attack if
//::    there are hostiles too close to it.
//::    2.) If demilich is regenerating, in addition to
//::    the re-slaying above, it will keep count of the
//::    demilich's regeneration timer.  By default, this
//::    is 5 minutes time.  This can be altered by constant
//::    in the zep_inc_main file.  Once regenerated, the
//::    Demilich will respawn to take stock of its
//::    surroundings.  If nothing threatening is about,
//::    it will go back to "sleeping".  Note that a
//::    demilich will not respawn once defeated until it
//::    has fully regenerated.
//::------------------------------------------------------
//:: Included files: zep_inc_demi

#include "zep_inc_demi"

void main()
{
//First, the "administrative" task of re-slaying soulgem
//victims that may have been raised.
ZEPDemilichReSlaySoulGemVictims(OBJECT_SELF);
//Next check if this Demilich has the "regenerating"
//tag we defined.  If so, check our counter.
if (GetTag(OBJECT_SELF)==ZEP_DEMI_REGEN_SKULL)
    {
    int nRegenCounter = GetLocalInt(OBJECT_SELF,"RegenCounter");
    //If our counter is past the regen time, we re-generate
    //the Demilich.
    if (nRegenCounter >= ZEP_DEMI_REGEN_TIME)
        {
        object oRegeneratedDemilich=ZEPDemilichFromBones(OBJECT_SELF,TRUE);
        }
    //Else we'll increment the counter by the current elapsed
    //time.  6 seconds.
    else
        {
        nRegenCounter+=6;
        SetLocalInt(OBJECT_SELF,"RegenCounter",nRegenCounter);
        }
    }
//If the Demilich is NOT regenerating, it's active and just
//"resting".  So we'll check if there are enemies nearby
//and "wake up" to attack them if so.
else
    {
    object oNearestEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,1,CREATURE_TYPE_IS_ALIVE,TRUE);
    //So we have the nearest hostile.  IF they're within the
    //demilich's resting perception range ,we'll spawn
    //and attack.
    if ((oNearestEnemy != OBJECT_INVALID) && (GetDistanceBetween(OBJECT_SELF,oNearestEnemy)<= ZEP_DEMI_PERC_RANGE))
        ZEPDemilichFromBones(OBJECT_SELF,TRUE);
    }
}
