//::///////////////////////////////////////////////
//:: Psionics include: Energy powers
//:: psi_inc_enrgypow
//::///////////////////////////////////////////////
/** @file
    Defines function and structure for determining
    energy-type dependent features of the Energy X
    line of powers.


    @author Ornedan
    @date   Created - 2005.12.12
 */
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

/**
 * A structure for passing the Energy type modification
 * data back to the power script.
 */
struct energy_adjustments{
    int nBonusPerDie;
    int nSaveType;
    int nDamageType;
    int nDCMod;
    int nPenMod;
    int nVFX1;
    int nVFX2;
};


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines the energy-dependent adjustments to damage per die, DC and
 * manifester level in regards to Power Resistance. Also does VFX, saving
 * throw type and damage type.
 *
 * @param nSpellID       SpellID of the power being manifested
 * @param nSpellID_Cold  SpellID of the cold version of the power
 * @param nSpellID_Elec  SpellID of the electricity version of the power
 * @param nSpellID_Fire  SpellID of the fire version of the power
 * @param nSpellID_Sonic SpellID of the sonic version of the power
 * @param nVFX2_Cold     Power specific VFX for cold
 * @param nVFX2_Elec     Power specific VFX for electricity
 * @param nVFX2_Fire     Power specific VFX for fire
 * @param nVFX2_Sonic    Power specific VFX for sonic
 */
struct energy_adjustments EvaluateEnergy(int nSpellID, int nSpellID_Cold, int nSpellID_Elec, int nSpellID_Fire, int nSpellID_Sonic,
                                         int nVFX2_Cold = 0, int nVFX2_Elec = 0, int nVFX2_Fire = 0, int nVFX2_Sonic = 0);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_utility"


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct energy_adjustments EvaluateEnergy(int nSpellID, int nSpellID_Cold, int nSpellID_Elec, int nSpellID_Fire, int nSpellID_Sonic,
                                         int nVFX2_Cold = 0, int nVFX2_Elec = 0, int nVFX2_Fire = 0, int nVFX2_Sonic = 0)
{
    struct energy_adjustments eaRet;

    if(nSpellID == nSpellID_Cold)
    {
        eaRet.nBonusPerDie = 1;
        eaRet.nSaveType    = SAVING_THROW_TYPE_COLD;
        eaRet.nDamageType  = DAMAGE_TYPE_COLD;
        eaRet.nDCMod       = 0;
        eaRet.nPenMod      = 0;
        eaRet.nVFX1        = VFX_IMP_FROST_S;
        eaRet.nVFX2        = nVFX2_Cold;
    }
    else if(nSpellID == nSpellID_Elec)
    {
        eaRet.nBonusPerDie = 0;
        eaRet.nSaveType    = SAVING_THROW_TYPE_ELECTRICITY;
        eaRet.nDamageType  = DAMAGE_TYPE_ELECTRICAL;
        eaRet.nDCMod       = 2;
        eaRet.nPenMod      = 2;
        eaRet.nVFX1        = VFX_IMP_LIGHTNING_S;
        eaRet.nVFX2        = nVFX2_Elec;
    }
    else if(nSpellID == nSpellID_Fire)
    {
        eaRet.nBonusPerDie = 1;
        eaRet.nSaveType    = SAVING_THROW_TYPE_FIRE;
        eaRet.nDamageType  = DAMAGE_TYPE_FIRE;
        eaRet.nDCMod       = 0;
        eaRet.nPenMod      = 0;
        eaRet.nVFX1        = VFX_IMP_FLAME_S;
        eaRet.nVFX2        = nVFX2_Fire;
    }
    else if(nSpellID == nSpellID_Sonic)
    {
        eaRet.nBonusPerDie = -1;
        eaRet.nSaveType    = SAVING_THROW_TYPE_SONIC;
        eaRet.nDamageType  = DAMAGE_TYPE_SONIC;
        eaRet.nDCMod       = 0;
        eaRet.nPenMod      = 0;
        eaRet.nVFX1        = VFX_IMP_SONIC;
        eaRet.nVFX2        = nVFX2_Sonic;
    }
    else
    {
        string sErr = "EvaluateEnergy(): ERROR: SpellID does not match any of the given IDs\n"
                    + "Given ID: "       + IntToString(nSpellID)       + "\n"
                    + "Cold ID: "        + IntToString(nSpellID_Cold)  + "\n"
                    + "Electricity ID: " + IntToString(nSpellID_Elec)  + "\n"
                    + "Fire ID: "        + IntToString(nSpellID_Fire)  + "\n"
                    + "Sonic ID: "       + IntToString(nSpellID_Sonic) + "\n"
                      ;
        if(DEBUG) DoDebug(sErr);
        else      WriteTimestampedLogEntry(sErr);
    }
    
    //Energy Draconic Aura boosts
    if (eaRet.nDamageType == DAMAGE_TYPE_FIRE && (GetLocalInt(OBJECT_SELF, "FireEnergyAura") > 0))
    {
            eaRet.nDCMod += GetLocalInt(OBJECT_SELF, "FireEnergyAura");
    }
    else if (eaRet.nDamageType == DAMAGE_TYPE_COLD && (GetLocalInt(OBJECT_SELF, "ColdEnergyAura") > 0))
    {
            eaRet.nDCMod +=  GetLocalInt(OBJECT_SELF, "ColdEnergyAura");
    }
    else if (eaRet.nDamageType == DAMAGE_TYPE_ELECTRICAL && (GetLocalInt(OBJECT_SELF, "ElecEnergyAura") > 0))
    {
            eaRet.nDCMod +=  GetLocalInt(OBJECT_SELF, "ElecEnergyAura");
    }
    else if (eaRet.nDamageType == DAMAGE_TYPE_ACID && (GetLocalInt(OBJECT_SELF, "AcidEnergyAura") > 0))
    {
            eaRet.nDCMod +=  GetLocalInt(OBJECT_SELF, "AcidEnergyAura");
    }

    return eaRet;
}

// Test main
//void main(){}
