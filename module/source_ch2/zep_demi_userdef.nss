//:: Note: This function modified by Loki Hakanin.
//:: See notes after Bioware's code for details.
//::///////////////////////////////////////////////
//:: Name x2_def_userdef
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On User Defined Event script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////

//::////////////////////////////////////////////////////
//:: Summary of Modifications by Loki:
//:: =================================
//:: Code added to OnHeartbeat to cause the Demilich
//:: to de-spawn itself and go into "rest" mode if
//:: nothing interesting is happening nearby.  This
//:: spawns two placables at the demilich's location,
//:: a pile of bones and a dust plume.  If these
//:: objects are disturbed, the demilich will once
//:: more spawn and attack any hostiles nearby, then
//:: rest again.  These placables can be found in the
//:: Dungeon->Tombs, Grave Markers section of the Palette.
//:: Note also that due to the self-contained nature
//:: of the implementation of the Demilich's soulgems,
//:: we use the Heartbeat to re-kill any soulgem victims
//:: who have been re-slain, figuring they can't have been
//:: up and flailing around for too long.  This will
//:: play some animations and explain this fact that
//:: the person's soul will not return any observers
//:: to their body while the demilich lives.
//:: It's a slightly kludgy implementation, but it's the
//:: only way we can do things without using module events
//:: and aras and the like.
//::////////////////////////////////////////////////////


const int EVENT_USER_DEFINED_PRESPAWN = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN = 1511;


#include "zep_inc_demi"

void main()
{
    int nUser = GetUserDefinedEventNumber();

    if(nUser == EVENT_HEARTBEAT ) //HEARTBEAT
    {
    //First thing's first, re-kill any pesky soulgem victims
    ZEPDemilichReSlaySoulGemVictims(OBJECT_SELF);

    //If we're not fighting and we're 20 meters from any hostiles
    //we want the Demlich to go into "rest" mode, and spawn the
    //appropriate skull placables.
    if (!GetIsInCombat() &&
         GetDistanceBetween(OBJECT_SELF,GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY)) > 20.0)
        {
        //Note FALSE flag on following function call-this sets
        //the bones into REST mode, vs REGENERATION mode.
        ZEPDemilichSpawnBones(OBJECT_SELF,FALSE);
        DestroyObject(OBJECT_SELF,1.0);
        }
    }
    else if(nUser == EVENT_PERCEIVE) // PERCEIVE
    {

    }
    else if(nUser == EVENT_END_COMBAT_ROUND) // END OF COMBAT
    {

    }
    else if(nUser == EVENT_DIALOGUE) // ON DIALOGUE
    {

    }
    else if(nUser == EVENT_ATTACKED) // ATTACKED
    {

    }
    else if(nUser == EVENT_DAMAGED) // DAMAGED
    {

    }
    else if(nUser == 1007) // DEATH  - do not use for critical code, does not fire reliably all the time
    {

    }
    else if(nUser == EVENT_DISTURBED) // DISTURBED
    {

    }
    else if (nUser == EVENT_USER_DEFINED_PRESPAWN)
    {

    }
    else if (nUser == EVENT_USER_DEFINED_POSTSPAWN)
    {

    }


}


