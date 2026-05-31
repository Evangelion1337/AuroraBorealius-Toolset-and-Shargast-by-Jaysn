//::///////////////////////////////////////////////
//:: Name           Primogenitors Respawning Ground Trap include
//:: FileName       prgt_inc_trap
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
        This was orignally designed to allow respawning ground traps
        However, as of NWN 1.67 this is no longer needed.

        The secondary purpose of this is now most useful and that
        is to provide a system where a wide variety of traps
        can be set and used.

        This particular file details the trap struct used to track
        all the relevant information in it
*/
//:://////////////////////////////////////////////
//:: Created By: Primogenitor
//:: Created On: Quite some time ago
//:://////////////////////////////////////////////

#include "prc_misc_const"
#include "inc_ecl"


struct trap
{
//DC to detect the trap
    int nDetectDC;
//DC to disarm the trap
//By PnP only rogues can disarm traps over DC 35?
    int nDisarmDC;
//this is the script that is fired when the trap is
//triggered
    string sTriggerScript;
//this is the script that is fired when the trap is
//disarmed
    string sDisarmScript;
//if the trap casts a spell when triggered
//these control the details
    int nSpellID;
    int nSpellLevel;
    int nSpellMetamagic;
    int nSpellDC;
//these are for normal dmaging type traps
    int nDamageType;
    int nRadius;
    int nDamageDice;
    int nDamageSize;
    int nDamageBonus;
//visual things
    int nTargetVFX;
    int nTrapVFX;
    int nBeamVFX;
    int nFakeSpell;
    int nFakeSpellLoc;
//saves for half
    int nAllowReflexSave;
    int nAllowFortSave;
    int nAllowWillSave;
    int nSaveDC;
//this is a mesure of CR of the trap
//can be used by XP scripts
    int nCR;
//delay before respawning once destroyed/disarmed
    int nRespawnSeconds;
//CR passed to CreateRandomTrap when respawning
//if not set, uses same trap as before
    int nRespawnRandomCR;
//this is the size of the trap on the ground
//if zero, 2.0 is used
    float fSize;
};

struct trap GetLocalTrap(object oObject, string sVarName);
void SetLocalTrap(object oObject, string sVarName, struct trap tTrap);
void DeleteLocalTrap(object oObject, string sVarName);
struct trap CreateRandomTrap(int nCR = -1);

/**
 * Converts the given trap into a string. The structure members' names and
 * values are listed separated by line breaks.
 *
 * @param tTrap A trap structure to convert into a string.
 * @return      A string representation of tTrap.
 */
string TrapToString(struct trap tTrap);


//////////////////////////////////////
/* Includes                         */
//////////////////////////////////////

#include "inc_utility"



//////////////////////////////////////
/* Function Definitions             */
//////////////////////////////////////

struct trap CreateRandomTrap(int nCR = -1)
{
    if(nCR == -1)
    {
        nCR = GetECL(GetFirstPC());
        nCR += Random(5)-2;
        if(nCR < 1)
            nCR = 1;
    }
    struct trap tReturn;
    switch(Random(26))
    {
        case 0: tReturn.nDamageType = DAMAGE_TYPE_PIERCING; break;
        case 1: tReturn.nDamageType = DAMAGE_TYPE_PIERCING; break;
        case 2: tReturn.nDamageType = DAMAGE_TYPE_PIERCING; break;
        case 3: tReturn.nDamageType = DAMAGE_TYPE_PIERCING; break;
        case 4: tReturn.nDamageType = DAMAGE_TYPE_PIERCING; break;
        case 5: tReturn.nDamageType = DAMAGE_TYPE_PIERCING; break;
        case 6: tReturn.nDamageType = DAMAGE_TYPE_BLUDGEONING; break;
        case 7: tReturn.nDamageType = DAMAGE_TYPE_BLUDGEONING; break;
        case 8: tReturn.nDamageType = DAMAGE_TYPE_BLUDGEONING; break;
        case 9: tReturn.nDamageType = DAMAGE_TYPE_BLUDGEONING; break;
        case 10: tReturn.nDamageType = DAMAGE_TYPE_BLUDGEONING; break;
        case 11: tReturn.nDamageType = DAMAGE_TYPE_BLUDGEONING; break;
        case 12: tReturn.nDamageType = DAMAGE_TYPE_SLASHING; break;
        case 13: tReturn.nDamageType = DAMAGE_TYPE_SLASHING; break;
        case 14: tReturn.nDamageType = DAMAGE_TYPE_SLASHING; break;
        case 15: tReturn.nDamageType = DAMAGE_TYPE_SLASHING; break;
        case 16: tReturn.nDamageType = DAMAGE_TYPE_SLASHING; break;
        case 17: tReturn.nDamageType = DAMAGE_TYPE_SLASHING; break;
        case 18: tReturn.nDamageType = DAMAGE_TYPE_FIRE; break;
        case 19: tReturn.nDamageType = DAMAGE_TYPE_FIRE; break;
        case 20: tReturn.nDamageType = DAMAGE_TYPE_COLD; break;
        case 21: tReturn.nDamageType = DAMAGE_TYPE_COLD; break;
        case 22: tReturn.nDamageType = DAMAGE_TYPE_ELECTRICAL; break;
        case 23: tReturn.nDamageType = DAMAGE_TYPE_ELECTRICAL; break;
        case 24: tReturn.nDamageType = DAMAGE_TYPE_ACID; break;
        case 25: tReturn.nDamageType = DAMAGE_TYPE_SONIC; break;
    }

    tReturn.nRadius = 5+(nCR/2);
    tReturn.nDamageDice = 1+(nCR/2);
    tReturn.nDamageSize = 6;
    tReturn.nDamageBonus = 0;
    tReturn.nDetectDC = 15+nCR;
    tReturn.nDisarmDC = 15+nCR;
    tReturn.nCR = nCR;
    tReturn.nRespawnSeconds = 0;
    tReturn.nRespawnRandomCR = nCR;
    tReturn.sTriggerScript = "prgt_trap_fire";
    tReturn.sDisarmScript  = "prgt_trap_disa";
    tReturn.fSize = 2.0;

    switch(tReturn.nDamageType)
    {
        case DAMAGE_TYPE_BLUDGEONING:
            tReturn.nFakeSpellLoc = 773; //bolder tossing
            tReturn.nRadius /= 2;
            tReturn.nDamageDice *= 2;
            tReturn.nAllowReflexSave = TRUE;
            tReturn.nSaveDC = 10+nCR;
            break;
        case DAMAGE_TYPE_SLASHING:
            tReturn.nTrapVFX = VFX_FNF_SWINGING_BLADE;
            tReturn.nRadius /= 2;
            tReturn.nDamageSize *= 2;
            tReturn.nAllowReflexSave = TRUE;
            tReturn.nSaveDC = 10+nCR;
            break;
        case DAMAGE_TYPE_PIERCING:
            tReturn.nTargetVFX = VFX_IMP_SPIKE_TRAP;
            tReturn.nRadius /= 4;
            tReturn.nDamageSize *= 2;
            tReturn.nDamageDice *= 2;
            tReturn.nAllowReflexSave = TRUE;
            tReturn.nSaveDC = 10+nCR;
            break;
        case DAMAGE_TYPE_COLD:
            tReturn.nTrapVFX = VFX_FNF_ICESTORM;
            tReturn.nTargetVFX = VFX_IMP_FROST_S;
            tReturn.nRadius *= 2;
            tReturn.nDamageSize /= 2;
            tReturn.nDamageDice /= 2;
            tReturn.nAllowFortSave = TRUE;
            tReturn.nSaveDC = 10+nCR;
            break;
        case DAMAGE_TYPE_FIRE:
            tReturn.nTrapVFX = VFX_FNF_FIREBALL;
            tReturn.nTargetVFX = VFX_IMP_FLAME_S;
            tReturn.nRadius *= 2;
            tReturn.nDamageSize /= 2;
            tReturn.nDamageDice /= 2;
            tReturn.nAllowReflexSave = TRUE;
            tReturn.nSaveDC = 10+nCR;
            break;
        case DAMAGE_TYPE_ELECTRICAL:
            tReturn.nBeamVFX = VFX_BEAM_LIGHTNING;
            tReturn.nTargetVFX = VFX_IMP_LIGHTNING_S;
            tReturn.nRadius /= 4;
            tReturn.nDamageSize *= 2;
            tReturn.nDamageDice *= 2;
            tReturn.nAllowReflexSave = TRUE;
            tReturn.nSaveDC = 10+nCR;
            break;
        case DAMAGE_TYPE_SONIC:
            tReturn.nTrapVFX = VFX_FNF_SOUND_BURST;
            tReturn.nTargetVFX = VFX_IMP_SONIC;
            tReturn.nRadius *= 2;
            tReturn.nDamageSize /= 2;
            tReturn.nDamageDice /= 2;
            tReturn.nAllowFortSave = TRUE;
            tReturn.nSaveDC = 10+nCR;
            break;
        case DAMAGE_TYPE_ACID:
            tReturn.nTrapVFX = VFX_FNF_GAS_EXPLOSION_ACID;
            tReturn.nTargetVFX = VFX_IMP_ACID_S;
            tReturn.nRadius *= 2;
            tReturn.nDamageSize /= 2;
            tReturn.nDamageDice /= 2;
            tReturn.nAllowFortSave = TRUE;
            tReturn.nSaveDC = 10+nCR;
            break;
    }
    return tReturn;
}

struct trap GetLocalTrap(object oObject, string sVarName)
{
    struct trap tReturn;
    tReturn.nDetectDC       = GetLocalInt(oObject, sVarName+".nDetectDC");
    tReturn.nDisarmDC       = GetLocalInt(oObject, sVarName+".nDisarmDC");
    tReturn.sTriggerScript  = GetLocalString(oObject, sVarName+".sTriggerScript");
    tReturn.sDisarmScript   = GetLocalString(oObject, sVarName+".sDisarmScript");
    tReturn.nSpellID        = GetLocalInt(oObject, sVarName+".nSpellID");
    tReturn.nSpellLevel     = GetLocalInt(oObject, sVarName+".nSpellLevel");
    tReturn.nSpellMetamagic = GetLocalInt(oObject, sVarName+".nSpellMetamagic");
    tReturn.nSpellDC        = GetLocalInt(oObject, sVarName+".nSpellDC");
    tReturn.nDamageType     = GetLocalInt(oObject, sVarName+".nDamageType");
    tReturn.nRadius         = GetLocalInt(oObject, sVarName+".nRadius");
    tReturn.nDamageDice     = GetLocalInt(oObject, sVarName+".nDamageDice");
    tReturn.nDamageSize     = GetLocalInt(oObject, sVarName+".nDamageSize");
    tReturn.nDamageBonus    = GetLocalInt(oObject, sVarName+".nDamageBonus");
    tReturn.nAllowReflexSave= GetLocalInt(oObject, sVarName+".nAllowReflexSave");
    tReturn.nAllowFortSave  = GetLocalInt(oObject, sVarName+".nAllowFortSave");
    tReturn.nAllowWillSave  = GetLocalInt(oObject, sVarName+".nAllowWillSave");
    tReturn.nSaveDC         = GetLocalInt(oObject, sVarName+".nSaveDC");
    tReturn.nTargetVFX      = GetLocalInt(oObject, sVarName+".nTargetVFX");
    tReturn.nTrapVFX        = GetLocalInt(oObject, sVarName+".nTrapVFX");
    tReturn.nFakeSpell      = GetLocalInt(oObject, sVarName+".nFakeSpell");
    tReturn.nFakeSpellLoc   = GetLocalInt(oObject, sVarName+".nFakeSpellLoc");
    tReturn.nBeamVFX        = GetLocalInt(oObject, sVarName+".nBeamVFX");
    tReturn.nCR             = GetLocalInt(oObject, sVarName+".nCR");
    tReturn.nRespawnSeconds = GetLocalInt(oObject, sVarName+".nRespawnSeconds");
    tReturn.nRespawnRandomCR= GetLocalInt(oObject, sVarName+".nRespawnRandomCR");
    tReturn.fSize           = GetLocalFloat(oObject, sVarName+".fSize");

    return tReturn;
}
void SetLocalTrap(object oObject, string sVarName, struct trap tTrap)
{
    SetLocalInt(oObject, sVarName+".nDetectDC",             tTrap.nDetectDC);
    SetLocalInt(oObject, sVarName+".nDisarmDC",             tTrap.nDisarmDC);
    SetLocalString(oObject, sVarName+".sTriggerScript",     tTrap.sTriggerScript);
    SetLocalString(oObject, sVarName+".sDisarmScript",      tTrap.sDisarmScript);
    SetLocalInt(oObject, sVarName+".nSpellID",              tTrap.nSpellID);
    SetLocalInt(oObject, sVarName+".nSpellLevel",           tTrap.nSpellLevel);
    SetLocalInt(oObject, sVarName+".nSpellMetamagic",       tTrap.nSpellMetamagic);
    SetLocalInt(oObject, sVarName+".nSpellDC",              tTrap.nSpellDC);
    SetLocalInt(oObject, sVarName+".nDamageType",           tTrap.nDamageType);
    SetLocalInt(oObject, sVarName+".nRadius",               tTrap.nRadius);
    SetLocalInt(oObject, sVarName+".nDamageDice",           tTrap.nDamageDice);
    SetLocalInt(oObject, sVarName+".nDamageSize",           tTrap.nDamageSize);
    SetLocalInt(oObject, sVarName+".nDamageBonus",          tTrap.nDamageBonus);
    SetLocalInt(oObject, sVarName+".nAllowReflexSave",      tTrap.nAllowReflexSave);
    SetLocalInt(oObject, sVarName+".nAllowFortSave",        tTrap.nAllowFortSave);
    SetLocalInt(oObject, sVarName+".nAllowWillSave",        tTrap.nAllowWillSave);
    SetLocalInt(oObject, sVarName+".nSaveDC",               tTrap.nSaveDC);
    SetLocalInt(oObject, sVarName+".nTargetVFX",            tTrap.nTargetVFX);
    SetLocalInt(oObject, sVarName+".nTrapVFX",              tTrap.nTrapVFX);
    SetLocalInt(oObject, sVarName+".nFakeSpell",            tTrap.nFakeSpell);
    SetLocalInt(oObject, sVarName+".nFakeSpellLoc",         tTrap.nFakeSpellLoc);
    SetLocalInt(oObject, sVarName+".nBeamVFX",              tTrap.nBeamVFX);
    SetLocalInt(oObject, sVarName+".nCR",                   tTrap.nCR);
    SetLocalInt(oObject, sVarName+".nRespawnSeconds",       tTrap.nRespawnSeconds);
    SetLocalInt(oObject, sVarName+".nRespawnRandomCR",      tTrap.nRespawnRandomCR);
    SetLocalFloat(oObject, sVarName+".fSize",               tTrap.fSize);
}
void DeleteLocalTrap(object oObject, string sVarName)
{
    DeleteLocalInt(oObject, sVarName+".nDetectDC");
    DeleteLocalInt(oObject, sVarName+".nDisarmDC");
    DeleteLocalString(oObject, sVarName+".sTriggerScript");
    DeleteLocalString(oObject, sVarName+".sDisarmScript");
    DeleteLocalInt(oObject, sVarName+".nSpellID");
    DeleteLocalInt(oObject, sVarName+".nSpellLevel");
    DeleteLocalInt(oObject, sVarName+".nSpellMetamagic");
    DeleteLocalInt(oObject, sVarName+".nSpellDC");
    DeleteLocalInt(oObject, sVarName+".nDamageType");
    DeleteLocalInt(oObject, sVarName+".nRadius");
    DeleteLocalInt(oObject, sVarName+".nDamageDice");
    DeleteLocalInt(oObject, sVarName+".nDamageSize");
    DeleteLocalInt(oObject, sVarName+".nDamageBonus");
    DeleteLocalInt(oObject, sVarName+".nAllowReflexSave");
    DeleteLocalInt(oObject, sVarName+".nAllowFortSave");
    DeleteLocalInt(oObject, sVarName+".nAllowWillSave");
    DeleteLocalInt(oObject, sVarName+".nSaveDC");
    DeleteLocalInt(oObject, sVarName+".nTargetVFX");
    DeleteLocalInt(oObject, sVarName+".nTrapVFX");
    DeleteLocalInt(oObject, sVarName+".nFakeSpell");
    DeleteLocalInt(oObject, sVarName+".nFakeSpellLoc");
    DeleteLocalInt(oObject, sVarName+".nBeamVFX");
    DeleteLocalInt(oObject, sVarName+".nCR");
    DeleteLocalInt(oObject, sVarName+".nRespawnSeconds");
    DeleteLocalInt(oObject, sVarName+".nRespawnRandomCR");
    DeleteLocalFloat(oObject, sVarName+".fSize");
}

string TrapToString(struct trap tTrap)
{
    string s;
    s += "nDetectDC: "        + IntToString(tTrap.nDetectDC)        + "\n";
    s += "nDisarmDC: "        + IntToString(tTrap.nDisarmDC)        + "\n";
    s += "sTriggerScript: '"  + tTrap.sTriggerScript                + "'\n";
    s += "sDisarmScript: '"   + tTrap.sDisarmScript                 + "'\n";
    s += "nSpellID: "         + IntToString(tTrap.nSpellID)         + "\n";
    s += "nSpellLevel: "      + IntToString(tTrap.nSpellLevel)      + "\n";
    s += "nSpellMetamagic: "  + IntToString(tTrap.nSpellMetamagic)  + "\n";
    s += "nSpellDC: "         + IntToString(tTrap.nSpellDC)         + "\n";
    s += "nDamageType: "      + IntToString(tTrap.nDamageType)      + "\n";
    s += "nRadius: "          + IntToString(tTrap.nRadius)          + "\n";
    s += "nDamageDice: "      + IntToString(tTrap.nDamageDice)      + "\n";
    s += "nDamageSize: "      + IntToString(tTrap.nDamageSize)      + "\n";
    s += "nDamageBonus: "      + IntToString(tTrap.nDamageBonus)     + "\n";
    s += "nAllowReflexSave: " + IntToString(tTrap.nAllowReflexSave) + "\n";
    s += "nAllowFortSave: "   + IntToString(tTrap.nAllowFortSave)   + "\n";
    s += "nAllowWillSave: "   + IntToString(tTrap.nAllowWillSave)   + "\n";
    s += "nSaveDC: "          + IntToString(tTrap.nSaveDC)          + "\n";
    s += "nTargetVFX: "       + IntToString(tTrap.nTargetVFX)       + "\n";
    s += "nTrapVFX: "         + IntToString(tTrap.nTrapVFX)         + "\n";
    s += "nFakeSpell: "       + IntToString(tTrap.nFakeSpell)       + "\n";
    s += "nFakeSpellLoc: "    + IntToString(tTrap.nFakeSpellLoc)    + "\n";
    s += "nBeamVFX: "         + IntToString(tTrap.nBeamVFX)         + "\n";
    s += "nCR: "              + IntToString(tTrap.nCR)              + "\n";
    s += "nRespawnSeconds: "  + IntToString(tTrap.nRespawnSeconds)  + "\n";
    s += "nRespawnRandomCR: " + IntToString(tTrap.nRespawnRandomCR) + "\n";
    s += "fSize: "            + FloatToString(tTrap.fSize)          + "\n";

    return s;
}
