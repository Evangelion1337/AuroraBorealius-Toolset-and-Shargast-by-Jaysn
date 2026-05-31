/*
   ----------------
   prc_inc_psionics
   ----------------

   20/10/04 by Stratovarius

   Calculates Power Resistance for Psionics and performs the checks.
*/

/*
#include "prc_inc_racial"
#include "prc_feat_const"
#include "prc_class_const"
*/
#include "prc_alterations"
#include "prcsp_engine"

// Constants that dictate ResistPower results
const int POWER_RESIST_FAIL = 1;
const int POWER_RESIST_PASS = 0;


//
//  This function is a wrapper should someone wish to rewrite the Bioware
//  version. This is where it should be done.
//
int
PRCResistPower(object oCaster, object oTarget)
{
    return ResistSpell(oCaster, oTarget);
}

//
//  This function is a wrapper should someone wish to rewrite the Bioware
//  version. This is where it should be done.
//
int
PRCGetPowerResistance(object oTarget, object oCaster)
{
    int iPowerRes = GetSpellResistance(oTarget);

    //racial pack SR
    int iRacialPowerRes = 0;
    if(GetHasFeat(FEAT_SPELL27, oTarget))
        iRacialPowerRes += 27+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL25, oTarget))
        iRacialPowerRes += 25+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL18, oTarget))
        iRacialPowerRes += 18+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL16, oTarget))
        iRacialPowerRes += 16+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL15, oTarget))
        iRacialPowerRes += 15+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL14, oTarget))
        iRacialPowerRes += 14+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL13, oTarget))
        iRacialPowerRes += 13+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL11, oTarget))
        iRacialPowerRes += 11+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL10, oTarget))
        iRacialPowerRes += 10+GetHitDice(oTarget);
    else if(GetHasFeat(FEAT_SPELL5, oTarget))
        iRacialPowerRes += 5+GetHitDice(oTarget);
    if(iRacialPowerRes > iPowerRes)
        iPowerRes = iRacialPowerRes;

    // Exalted Companion, can also be used for Celestial Template
    if (GetLocalInt(oTarget, "CelestialTemplate"))
    {
        int nHD = GetHitDice(oTarget);
        int nSR = nHD * 2;
        if (nSR > 25) nSR = 25;
        if (nSR > iPowerRes) iPowerRes = nSR;
    }

    // Thought Shield, 13 + augment vs Mind-Affecting
    if(GetLocalInt(oTarget, "PRC_Power_ThoughtShield_PR") &&
       Get2DACache("spells", "ImmunityType", PRCGetSpellId()) == "Mind_Affecting"
       )
    {
        // Only use the PR given by the power if it's higher than the previous
        iPowerRes = PRCMax(iPowerRes, GetLocalInt(oTarget, "PRC_Power_ThoughtShield_PR"));
    }
    // Tower of Iron Will, 19 + augment vs Mind-Affecting
    if(GetLocalInt(oTarget, "PRC_Power_TowerOfIronWill_PR") &&
       Get2DACache("spells", "ImmunityType", PRCGetSpellId()) == "Mind_Affecting"
       )
    {
        // Only use the PR given by the power if it's higher than the previous
        iPowerRes = PRCMax(iPowerRes, GetLocalInt(oTarget, "PRC_Power_TowerOfIronWill_PR"));
    }

    // Foe Hunter SR stacks with normal SR
    // when a Power is cast by their hated enemy
    if(GetHasFeat(FEAT_HATED_ENEMY_SR, oTarget) && GetLocalInt(oTarget, "HatedFoe") == MyPRCGetRacialType(oCaster) )
    {
         iPowerRes += 15 + GetLevelByClass(CLASS_TYPE_FOE_HUNTER, oTarget);
    }

    return iPowerRes;
}

//
//  If a Power is resisted, display the effect
//
void
PRCShowPowerResist(object oCaster, object oTarget, int nResist, float fDelay = 0.0)
{
    // If either caster/target is a PC send them a message
    if (GetIsPC(oCaster))
    {
        string message = nResist == POWER_RESIST_FAIL ?
            "Target is affected by the power." : "Target resisted the power.";
        SendMessageToPC(oCaster, message);
    }
    if (GetIsPC(oTarget))
    {
        string message = nResist == POWER_RESIST_FAIL ?
            "You are affected by the power." : "You resisted the power.";
        SendMessageToPC(oTarget, message);
    }
}

//
//  This function overrides the BioWare MyResistSpell.
//  TODO: Change name to PRCMyResistPower.
//
int
PRCMyResistPower(object oCaster, object oTarget, int nEffCasterLvl=0, float fDelay = 0.0)
{
    int nResist = POWER_RESIST_FAIL;
    int nCasterCheck = nEffCasterLvl + d20(1);
    int nTargetPR = PRCGetPowerResistance(oTarget, oCaster);

    // A tie favors the caster.
    if (nCasterCheck < nTargetPR)   nResist = POWER_RESIST_PASS;

    //Spellfire - done this way because constants may change
    if(CheckSpellfire(oCaster, oTarget))    nResist = POWER_RESIST_PASS;

    // Only show resistance if the target has any
    if (nTargetPR > 0)  PRCShowPowerResist(oCaster, oTarget, nResist, fDelay);

    return nResist;
}

// Test main
//void main(){}
