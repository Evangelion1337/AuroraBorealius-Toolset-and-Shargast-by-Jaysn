//::///////////////////////////////////////////////
//:: Gatestones 1.6
//:: bpm_mod_onact
//:: Copyright (c) 2006 CarfaxAbbey.net
//:://////////////////////////////////////////////
/*
    Hook for OnItemActivate Module Event

    This file is ONLY for those who are upgrading
    form a previous version of Gatestones.
*/
//:://////////////////////////////////////////////
//:: Created By: Diavlen <diavlen@carfaxabbey.net>
//:: Created On: 3/24/2004
//:: Updated on: 8/11/2006
//:://////////////////////////////////////////////

void main() {
    object oPC  =   GetItemActivator();
    object oItem = GetItemActivated();

    if(GetTag(oItem)=="spell_gatestone")  {
        object oNew     =   CreateItemOnObject("bpm_s_gatestone",oPC);
        DestroyObject(oItem);
    }
    if(GetTag(oItem)=="bp_mi_gatestone")  {
        object oNew     =   CreateItemOnObject("bpm_gate_less",oPC);
        DestroyObject(oItem);
    }
}
