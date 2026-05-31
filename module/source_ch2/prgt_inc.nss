//::///////////////////////////////////////////////
//:: Name           Primogenitors Respawning Ground Trap include
//:: FileName       prgt_inc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
        This was orignally designed to allow respawning ground traps
        However, as of NWN 1.67 this is no longer needed.

        The secondary purpose of this is now most useful and that
        is to provide a system where a wide variety of traps
        can be set and used.

        This particular file provides interface functions
*/
//:://////////////////////////////////////////////
//:: Created By: Primogenitor
//:: Created On: Quite some time ago
//:://////////////////////////////////////////////

/*
int    DAMAGE_TYPE_BLUDGEONING  = 1;
int    DAMAGE_TYPE_PIERCING     = 2;
int    DAMAGE_TYPE_SLASHING     = 4;
int    DAMAGE_TYPE_MAGICAL      = 8;
int    DAMAGE_TYPE_ACID         = 16;
int    DAMAGE_TYPE_COLD         = 32;
int    DAMAGE_TYPE_DIVINE       = 64;
int    DAMAGE_TYPE_ELECTRICAL   = 128;
int    DAMAGE_TYPE_FIRE         = 256;
int    DAMAGE_TYPE_NEGATIVE     = 512;
int    DAMAGE_TYPE_POSITIVE     = 1024;
int    DAMAGE_TYPE_SONIC        = 2048;
*/

#include "prgt_inc_trap"
#include "inc_utility"
#include "prc_misc_const"

const int TRAP_EVENT_TRIGGERED = 1;
const int TRAP_EVENT_DISARMED  = 2;
const int TRAP_EVENT_RECOVERED = 3;    //this is in addition to being disarmed


object PRGT_CreateTrapAtLocation(location lLoc, struct trap tTrap)
{
    object oTrap;
    oTrap = CreateTrapAtLocation(TRAP_BASE_TYPE_PRGT,
        lLoc,
        tTrap.fSize,
        "",//tag
        STANDARD_FACTION_HOSTILE,
        tTrap.sDisarmScript,
        tTrap.sTriggerScript);

    SetLocalTrap(oTrap, "TrapSettings", tTrap);
    SetTrapOneShot(oTrap, FALSE);
    SetTrapRecoverable(oTrap, FALSE);

    return oTrap;
}

void PRGT_CreateTrapOnObject(object oTrap, struct trap tTrap)
{
    CreateTrapOnObject(TRAP_BASE_TYPE_PRGT,
        oTrap,
        STANDARD_FACTION_HOSTILE,
        tTrap.sDisarmScript,
        tTrap.sTriggerScript);

    SetLocalTrap(oTrap, "TrapSettings", tTrap);
    SetTrapOneShot(oTrap, FALSE);
    SetTrapRecoverable(oTrap, FALSE);
}


void PRGT_VoidCreateTrapAtLocation(location lLoc, struct trap tTrap)
{
    PRGT_CreateTrapAtLocation(lLoc, tTrap);
}

void DoTrapXP(object oTrap, object oTarget, int nEvent)
{
    switch(nEvent)
    {
        case TRAP_EVENT_TRIGGERED:
            if(GetLocalString(GetModule(), PRC_PRGT_XP_SCRIPT_TRIGGERED) != "")
                ExecuteScript(PRC_PRGT_XP_SCRIPT_TRIGGERED, oTarget);
            else if(GetPRCSwitch(PRC_PRGT_XP_AWARD_FOR_TRIGGERED))
                GiveXPRewardToParty(oTarget, OBJECT_INVALID, GetLocalTrap(oTrap, "TrapSettings").nCR);
        break;
        case TRAP_EVENT_DISARMED:
            if(GetLocalString(GetModule(), PRC_PRGT_XP_SCRIPT_DISARMED) != "")
                ExecuteScript(PRC_PRGT_XP_SCRIPT_TRIGGERED, oTarget);
            else if(GetPRCSwitch(PRC_PRGT_XP_AWARD_FOR_DISARMED))
                GiveXPRewardToParty(oTarget, OBJECT_INVALID, GetLocalTrap(oTrap, "TrapSettings").nCR);
        break;
        case TRAP_EVENT_RECOVERED:
            if(GetLocalString(GetModule(), PRC_PRGT_XP_SCRIPT_RECOVERED) != "")
                ExecuteScript(PRC_PRGT_XP_SCRIPT_TRIGGERED, oTarget);
            else if(GetPRCSwitch(PRC_PRGT_XP_AWARD_FOR_RECOVERED))
                GiveXPRewardToParty(oTarget, OBJECT_INVALID, GetLocalTrap(oTrap, "TrapSettings").nCR);
        break;
    }
}
