//::///////////////////////////////////////////////
//:: Tyrant Fog Zombie Mist
//:: NW_S1_TyrantFog.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the area around the zombie
    must save or take 1 point of Constitution
    damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
//#include "wm_include"
#include "prc_inc_spells"

void main()
{
    //if (WildMagicOverride()) { return; }

    //Declare and apply the AOE
    effect eAOE = EffectAreaOfEffect(AOE_MOB_TYRANT_FOG);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, OBJECT_SELF, HoursToSeconds(100));
}
