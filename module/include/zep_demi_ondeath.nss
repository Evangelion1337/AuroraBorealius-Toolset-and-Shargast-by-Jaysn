//::///////////////////////////////////////////////
//:: Default:On Death DemiLich Add On
//:: NW_C2_DEFAULT7
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Shouts to allies that they have been killed
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 25, 2001
//:://////////////////////////////////////////////
#include "NW_I0_GENERIC"
void main()
{
    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        object oKiller = GetLastKiller();
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }

    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);
    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
 {
   SignalEvent(OBJECT_SELF, EventUserDefined(1007));
 {
/////////////////Demi Lich add on script starts here//////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Demigog
//:: Created On: Oct 13, 2002
//:://////////////////////////////////////////////
 location lLoc = GetLocation(GetObjectByTag("demi_lich_01"));
 location lLoca = GetLocation(OBJECT_SELF);
 object oKiller = GetLastKiller();
 string oPlaceable3 = "demi_lich_skull";
 string oPlaceable4 = "demi_lich_target";
 CreateObject(OBJECT_TYPE_PLACEABLE,oPlaceable3,lLoc);
 //CreateObject(OBJECT_TYPE_ITEM,oPlaceable3,lLoca);
 CreateObject(OBJECT_TYPE_PLACEABLE,oPlaceable4,lLoc);
 }
 }
 ExecuteScript("prc_npc_death", OBJECT_SELF);
ExecuteScript("prc_pwondeath", OBJECT_SELF);
}


