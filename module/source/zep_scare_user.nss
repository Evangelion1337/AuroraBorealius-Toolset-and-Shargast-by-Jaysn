//::///////////////////////////////////////////////
//:: Default: On User Defined
//:: NW_C2_DEFAULTD
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    on a user defined event.
*/
//:://////////////////////////////////////////////
//:: Created By: Don Moar
//:: Created On: April 28, 2002
//:://////////////////////////////////////////////
#include "nw_i0_spells"
#include "prc_inc_spells"

void main()
{
    int nUser = GetUserDefinedEventNumber();
    effect eGaze =  EffectDazed();
    object oVictim;
    int nDC= 14;
    int nSave;
    effect eViz =  EffectVisualEffect(VFX_IMP_DAZED_S);

    if(nUser == 1003)        //On Combat Round End
    {
        oVictim = GetLastHostileActor();
        nSave = PRCMySavingThrow(SAVING_THROW_WILL,oVictim,nDC,SAVING_THROW_TYPE_MIND_SPELLS);
        //WillSave(oVictim, 19, SAVING_THROW_TYPE_SPELL, OBJECT_SELF);
        if(nSave == 0)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGaze, oVictim,6.0);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eViz, oVictim,6.0);
        }
     }
}
