//::///////////////////////////////////////////////
//:: Gatestones 1.6
//:: bpm_s_gatestone
//:: Copyright (c) 2006 CarfaxAbbey.net
//:://////////////////////////////////////////////
/*
    Tag Based script for the Arcane Item: Gatestone
    This is given to qualifying spellcasters OnClientEnter
*/
//:://////////////////////////////////////////////
//:: Created By: Diavlen <diavlen@carfaxabbey.net>
//:: Created On: 3/24/2004
//:: Updated on: 8/11/2006
//:://////////////////////////////////////////////
#include "prc_inc_spells"
#include "x2_inc_switches"
#include "bpm_inc"

void main() {

    int nEvent =GetUserDefinedItemEventNumber();
    object oPC;
    object oItem;

    // * This code runs when the item has the OnHitCastSpell: Unique power property
    // * and it hits a target(weapon) or is being hit (armor)
    // * Note that this event fires for non PC creatures as well.
    if (nEvent ==X2_ITEM_EVENT_ONHITCAST)
    {
        oItem  =  PRCGetSpellCastItem();                  // The item casting triggering this spellscript
        object oSpellOrigin = OBJECT_SELF ;
        object oSpellTarget = PRCGetSpellTargetObject();
        oPC = OBJECT_SELF;

    }

    // * This code runs when the Unique Power property of the item is used
    // * Note that this event fires PCs only
    else if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        oPC   = GetItemActivator();
        oItem = GetItemActivated();

        string sPCName          =   GetName(oPC);
        string sAreaName        =   GetName(GetArea(oPC));
        string sMessage;

        if(GetTag(GetArea(oPC))=="FuguePlane")
            return;

        if(!UMDCheck(oPC,9,10))   {
            SendMessageToPC(oPC,"You failed to activate the device");
            return;
        }

        effect eWard            =   EffectVisualEffect(VFX_IMP_DEATH_WARD);
        int nActivated          =   GetLocalInt(oItem,"BeenActivated");
        location lFirstTime, lSecondTime;
        if(!nActivated) {
            lFirstTime     =   GetLocation(oPC);
            ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,eWard,lFirstTime,10.0);
            DelayCommand(0.5,ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,eWard,lFirstTime,10.0));
            DelayCommand(1.0,ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,eWard,lFirstTime,10.0));
            SendMessageToAllDMs(sPCName + " Marked the ground in " + sAreaName);
            WriteTimestampedLogEntry("MTRX: " + sPCName + " Marked the ground in " + sAreaName);
            SetLocalString(oItem,"AREA",BPLocationToString(lFirstTime));
            SetLocalInt(oItem,"BeenActivated",TRUE);
        } else {
            lSecondTime    =   GetLocation(oPC);
            string sFirstTime   =   GetLocalString(oItem,"AREA");
            lFirstTime     =   BPStringToLocation(sFirstTime);
            object oPortalB         =   CreateObject(OBJECT_TYPE_PLACEABLE,"bpm_gatestone",lFirstTime,TRUE);
            effect eImplode         =   EffectVisualEffect(VFX_FNF_IMPLOSION);
            string sPortalDest      =   GetName(GetAreaFromLocation(lFirstTime));
            ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,eWard,lFirstTime,10.0);
            ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,eWard,lSecondTime,10.0);
            object oPortalA         =   CreateObject(OBJECT_TYPE_PLACEABLE,"bpm_gatestone",lSecondTime,TRUE);
            SetLocalObject(oPortalA,"DESTPORTAL",oPortalB);
            SetLocalObject(oPortalB,"DESTPORTAL",oPortalA);
            DelayCommand(120.0,ApplyEffectToObject(DURATION_TYPE_INSTANT,eImplode,oPortalA,3.5));
            DelayCommand(120.0,ApplyEffectToObject(DURATION_TYPE_INSTANT,eImplode,oPortalB,3.5));
            AssignCommand(oPortalA,DestroyObject(OBJECT_SELF,120.1));
            AssignCommand(oPortalB,DestroyObject(OBJECT_SELF,120.1));
            DeleteLocalString(oItem,"AREA");
            SetLocalInt(oItem,"BeenActivated",FALSE);
            SendMessageToAllDMs(sPCName + " opened a portal in " + sAreaName + " to " + sPortalDest);
            WriteTimestampedLogEntry("MTRX: " + sPCName + " opened a portal in " + sAreaName + " to " + sPortalDest);
        }
    }

    // * This code runs when the item is equipped
    // * Note that this event fires PCs only
    else if (nEvent ==X2_ITEM_EVENT_EQUIP)
    {

        oPC = GetPCItemLastEquippedBy();
        oItem = GetPCItemLastEquipped();

    }

    // * This code runs when the item is unequipped
    // * Note that this event fires PCs only
    else if (nEvent ==X2_ITEM_EVENT_UNEQUIP)
    {

        oPC    = GetPCItemLastUnequippedBy();
        oItem  = GetPCItemLastUnequipped();

    }
    // * This code runs when the item is acquired
    // * Note that this event fires PCs only
    else if (nEvent == X2_ITEM_EVENT_ACQUIRE)
    {
        oPC = GetModuleItemAcquiredBy();
        oItem  = GetModuleItemAcquired();
    }

    // * This code runs when the item is unaquire d
    // * Note that this event fires PCs only
    else if (nEvent == X2_ITEM_EVENT_UNACQUIRE)
    {

        oPC = GetModuleItemLostBy();
        oItem  = GetModuleItemLost();
    }

    //* This code runs when a PC or DM casts a spell from one of the
    //* standard spellbooks on the item
    else if (nEvent == X2_ITEM_EVENT_SPELLCAST_AT)
    {

        oPC = GetModuleItemLostBy();
        oItem  = GetModuleItemLost();
    }
}
