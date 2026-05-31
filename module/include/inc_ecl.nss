/** @file
 * ECL handling.
 *
 * @author Primogenitor
 *
 * @todo  Primo, could you document this one? More details to header and comment function prototypes
 */

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

// returns oTarget's LA value, including their race and template(s) LA
int GetTotalLA(object oTarget);

// returns oTarget's level adjusted by their LA
int GetECL(object oTarget);
void GiveXPReward(object oCreature, int nXP, int bIsPC = TRUE);
void GiveXPRewardToParty(object oKiller, object oDead, int nCR = 0);

//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

//#include "inc_utility"
//#include "prc_inc_template"
#include "inc_npc"

//////////////////////////////////////////////////
/* Function definitions                         */
//////////////////////////////////////////////////

int GetTotalLA(object oTarget)
{
    int nLA;
    int nRace = GetRacialType(oTarget);
    if(GetPRCSwitch(PRC_XP_USE_SIMPLE_LA))
        nLA += StringToInt(Get2DACache("ECL", "LA", nRace));
    if(GetPRCSwitch(PRC_XP_INCLUDE_RACIAL_HIT_DIE_IN_LA))
        nLA += StringToInt(Get2DACache("ECL", "RaceHD", nRace));
    nLA += GetPersistantLocalInt(oTarget, "template_LA");
    nLA -= GetPersistantLocalInt(oTarget, "LA_Buyoff");
    return nLA;
}

int GetECL(object oTarget)
{
    int nLevel;
    // we need to use a derivation of the base xp formular to compute the
    // pc level based on total XP.
    //
    // base XP formula (x = pc level, t = total xp):
    //
    //   t = x * (x-1) * 500
    //
    // need to use some base math..
    // transform for pq formula use (remove brackets with x inside and zero right side)
    //
    //   x^2 - x - (t / 500) = 0
    //
    // use pq formula to solve it [ x^2 + px + q = 0, p = -1, q = -(t/500) ]...
    //
    // that's our new formula to get the level based on total xp:
    //   level = 0.5 + sqrt(0.25 + (t/500))
    //
    if(GetPRCSwitch(PRC_ECL_USES_XP_NOT_HD) && GetIsPC(oTarget))
        nLevel = FloatToInt(0.5 + sqrt(0.25 + ( IntToFloat(GetXP(oTarget)) / 500 )));
    else
        nLevel = GetHitDice(oTarget);
    nLevel += GetTotalLA(oTarget);
    return nLevel;
}

int CheckDistance(object oDead, object oTest)
{
    if(GetPRCSwitch(PRC_XP_MUST_BE_IN_AREA))
    {
        if(GetArea(oDead) != GetArea(oTest))
            return FALSE;
        if(GetDistanceBetween(oDead, oTest) > IntToFloat(GetPRCSwitch(PRC_XP_MAX_PHYSICAL_DISTANCE)))
            return FALSE;
    }
    return TRUE;
}

float GetGroupBonusModifier(int nPartySize)
{
    return 1 + ((nPartySize-1) * IntToFloat(GetPRCSwitch(PRC_XP_GROUP_BONUS))/100.0);
}

void GiveXPRewardToParty(object oKiller, object oDead, int nCR = 0)
{
    //get prc switches
    int bSPAM = GetPRCSwitch(PRC_XP_DISABLE_SPAM);
    float fPRC_XP_DIVISOR_PC              = IntToFloat(GetPRCSwitch(PRC_XP_PC_PARTY_COUNT_x100))/100.0;
    float fPRC_XP_DIVISOR_HENCHMAN        = IntToFloat(GetPRCSwitch(PRC_XP_HENCHMAN_PARTY_COUNT_x100))/100.0;
    float fPRC_XP_DIVISOR_ANIMALCOMPANION = IntToFloat(GetPRCSwitch(PRC_XP_ANIMALCOMPANION_PARTY_COUNT_x100))/100.0;
    float fPRC_XP_DIVISOR_FAMILIAR        = IntToFloat(GetPRCSwitch(PRC_XP_FAMILIAR_PARTY_COUNT_x100))/100.0;
    float fPRC_XP_DIVISOR_DOMINATED       = IntToFloat(GetPRCSwitch(PRC_XP_DOMINATED_PARTY_COUNT_x100))/100.0;
    float fPRC_XP_DIVISOR_SUMMONED        = IntToFloat(GetPRCSwitch(PRC_XP_SUMMONED_PARTY_COUNT_x100))/100.0;
    float fPRC_XP_DIVISOR_UNKNOWN         = IntToFloat(GetPRCSwitch(PRC_XP_UNKNOWN_PARTY_COUNT_x100))/100.0;

    //number of PCs in the party, average party level
    int nPartySize, nAvgLevel;
    //xp divisor
    float fDivisor;

    //get some basic group data like average PC level , PC group size, and XP divisor
    object oTest = GetFirstFactionMember(oKiller, FALSE);
    while(GetIsObjectValid(oTest))
    {
        if(CheckDistance(oDead, oTest))
        {
            if(GetIsPC(oTest))
            {
                nPartySize++;
                nAvgLevel += GetECL(oTest);
                fDivisor += fPRC_XP_DIVISOR_PC;
            }
            else
            {
                switch(GetAssociateTypeNPC(oTest))
                {
                    case ASSOCIATE_TYPE_HENCHMAN:        fDivisor += fPRC_XP_DIVISOR_HENCHMAN;        break;
                    case ASSOCIATE_TYPE_ANIMALCOMPANION: fDivisor += fPRC_XP_DIVISOR_ANIMALCOMPANION; break;
                    case ASSOCIATE_TYPE_FAMILIAR:        fDivisor += fPRC_XP_DIVISOR_FAMILIAR;        break;
                    case ASSOCIATE_TYPE_DOMINATED:       fDivisor += fPRC_XP_DIVISOR_DOMINATED;       break;
                    case ASSOCIATE_TYPE_SUMMONED:        fDivisor += fPRC_XP_DIVISOR_SUMMONED;        break;
                    default:                            fDivisor += fPRC_XP_DIVISOR_UNKNOWN;         break;
                }
            }
        }
        else if(!bSPAM && GetIsPC(oTest))
            SendMessageToPC(oTest, "You are too far away from the combat to gain any experience.");

        oTest = GetNextFactionMember(oKiller, FALSE);
    }

    //in case something weird is happenening
    if(fDivisor == 0.0f)
        return;

    //calculate average partylevel
    nAvgLevel /= nPartySize;

    int nBaseXP;
    if(!nCR) nCR = GetPRCSwitch(PRC_XP_USE_ECL_NOT_CR) ? GetECL(oDead) : FloatToInt(GetChallengeRating(oDead));
    if(nCR < 1) nCR = 1;

    if(GetPRCSwitch(PRC_XP_USE_BIOWARE_XPTABLE))
    {
        if(nCR > 40) nCR = 40;
        if(nAvgLevel > 40) nAvgLevel = 40;
        nBaseXP = StringToInt(Get2DACache("xptable", "C"+IntToString(nCR), nAvgLevel-1));
    }
    else
    {
        if(nCR > 70) nCR = 70;
        if(nAvgLevel > 60) nAvgLevel = 60;
        nBaseXP = StringToInt(Get2DACache("dmgxp", IntToString(nCR), nAvgLevel-1));
    }

    //average xp per party member
    int nXPAward = FloatToInt(IntToFloat(nBaseXP)/fDivisor);

    //now the module slider
    nXPAward = FloatToInt(IntToFloat(nXPAward) * IntToFloat(GetPRCSwitch(PRC_XP_SLIDER_x100))/100.0);

    //xp = 0, quit
    if(!nXPAward)
        return;

    //group bonus
    nXPAward = FloatToInt(IntToFloat(nXPAward) * GetGroupBonusModifier(nPartySize));

    int nKillerLevel = GetECL(oKiller);
    //calculate xp for each party member individually
    oTest = GetFirstFactionMember(oKiller, FALSE);
    float fPCAdjust;
    int nMbrLevel;
    while(GetIsObjectValid(oTest))
    {
        if(CheckDistance(oDead, oTest))
        {
            if(GetIsPC(oTest))
            {
                nMbrLevel = GetECL(oTest);
                if(abs(nMbrLevel - nKillerLevel) <= GetPRCSwitch(PRC_XP_MAX_LEVEL_DIFF))
                {
                    //now the individual slider
                    fPCAdjust = IntToFloat(GetLocalInt(oTest, PRC_XP_SLIDER_x100))/100.0;
                    if(fPCAdjust == 0.0) fPCAdjust = 1.0;
                    nXPAward = FloatToInt(IntToFloat(nXPAward) * fPCAdjust);

                    GiveXPReward(oTest, nXPAward);
                }
                else if(!bSPAM)
                    SendMessageToPC(oTest, "You are too high level to gain any experience.");
            }
            else
                GiveXPReward(oTest, nXPAward, FALSE);
        }
        oTest = GetNextFactionMember(oKiller, FALSE);
    }
}

void GiveXPReward(object oCreature, int nXP, int bIsPC = TRUE)
{
    //actually give the XP
    if(bIsPC)
    {
        if(GetPRCSwitch(PRC_XP_USE_SETXP))
            SetXP(oCreature, GetXP(oCreature)+nXP);
        else
            GiveXPToCreature(oCreature, nXP);
    }
    else if(GetPRCSwitch(PRC_XP_GIVE_XP_TO_NPCS))
        SetLocalInt(oCreature, "NPC_XP", GetLocalInt(oCreature, "NPC_XP")+nXP);
}

//::///////////////////////////////////////////////
//:: Effective Character Level Experience Script
//:: ecl_exp
//:: Copyright (c) 2004 Theo Brinkman
//:://////////////////////////////////////////////
/*
Call ApplyECLToXP() from applicable heartbeat script(s)
to cause experience to be adjusted according to ECL.
*/
//:://////////////////////////////////////////////
//:: Created By: Theo Brinkman
//:: Last Updated On: 2004-07-28
//:://////////////////////////////////////////////
// CONSTANTS
const string sLEVEL_ADJUSTMENT = "ecl_LevelAdjustment";
const string sXP_AT_LAST_HEARTBEAT = "ecl_LastExperience";

int GetXPForLevel(int nLevel)
{
    return nLevel*(nLevel-1)*500;
}

void ApplyECLToXP(object oPC)
{
    //abort if simple LA is disabled
    if(!GetPRCSwitch(PRC_XP_USE_SIMPLE_LA))
        return;

    //abort if it's not valid, still loading, or a PC
    if(!GetIsObjectValid(oPC) || GetLocalInt(oPC, "PRC_ECL_Delay") || !GetIsPC(oPC))
        return;    
        
    // Abort if they are registering as a cohort
    if(GetLocalInt(oPC, "OriginalXP") || GetPersistantLocalInt(oPC, "RegisteringAsCohort"))
        return;
    
    // Let them make it to level 3 in peace
    if(GetTag(GetModule()) == "Prelude")
        return;
        
    // And start HotU in peace
    if(GetTag(GetArea(oPC)) == "q2a_yprooms")
        return;  
        
    // Abort if they were just relevelled
    if(GetLocalInt(oPC, "RelevelXP"))
    {
        DeleteLocalInt(oPC, "RelevelXP");
        return;    
    }    

    //this is done first because leadership uses it too
    int iCurXP = GetXP(oPC);
    //if (DEBUG) DoDebug("ApplyECLToXP - iCurXP "+IntToString(iCurXP));
       
    int iLastXP = GetPersistantLocalInt(oPC, sXP_AT_LAST_HEARTBEAT);
    //if (DEBUG) DoDebug("ApplyECLToXP - iLastXP "+IntToString(iLastXP));
    if(iCurXP > iLastXP)
    {
        //if (DEBUG) DoDebug("ApplyECLToXP - gained XP");
        int iLvlAdj = GetTotalLA(oPC);
        if(iLvlAdj)
        {
            //if (DEBUG) DoDebug("ApplyECLToXP - have LA");
            int iPCLvl = GetHitDice(oPC);
            // Get XP Ratio (multiply new XP by this to see what to subtract)
            float fRealXPToLevel = IntToFloat(GetXPForLevel(iPCLvl+1));
            float fECLXPToLevel = IntToFloat(GetXPForLevel(iPCLvl+1+iLvlAdj));
            float fXPRatio = 1.0 - (fRealXPToLevel/fECLXPToLevel);
            //At this point the ratio is based on total XP
            //This is not correct, it should be based on the XP required to reach
            //the next level.
            //fRealXPToLevel = IntToFloat(iPCLvl*1000);
            //fECLXPToLevel = IntToFloat((iPCLvl+iLvlAdj)*1000);
            //fXPRatio = 1.0 - (fRealXPToLevel/fECLXPToLevel);

            float fXPDif = IntToFloat(iCurXP - iLastXP);
            int iXPDif = FloatToInt(fXPDif * fXPRatio);
            int newXP = iCurXP - iXPDif;
            SendMessageToPC(oPC, "XP gained since last heartbeat "+IntToString(FloatToInt(fXPDif)));
            SendMessageToPC(oPC, "Real XP to level: "+IntToString(FloatToInt(fRealXPToLevel)));
            SendMessageToPC(oPC, "ECL XP to level:  "+IntToString(FloatToInt(fECLXPToLevel)));
            SendMessageToPC(oPC, "Level Adjustment +"+IntToString(iLvlAdj)+". Reducing XP by " + IntToString(iXPDif));
            SetXP(oPC, newXP);
        }
    }
    iCurXP = GetXP(oPC);
    SetPersistantLocalInt(oPC, sXP_AT_LAST_HEARTBEAT, iCurXP);    
}

int GetBuyoffCost(object oPC)
{
	int nECL = GetECL(oPC);
	int nXP = (nECL-1) * 1000;
	return nXP;
}

void BuyoffLevel(object oPC)
{
	int nECL = GetECL(oPC);
	int nXP = (nECL-1) * 1000;
	SetXP(oPC, GetXP(oPC)-nXP);
	int nBuyoff = GetPersistantLocalInt(oPC, "LA_Buyoff");
	SetPersistantLocalInt(oPC, "LA_Buyoff", nBuyoff+1);
}

int GetCanBuyoffLA(object oPC)
{
	int nReturn = FALSE;
	int nBuyoff = GetPersistantLocalInt(oPC, "LA_Buyoff");
	int nChar = GetHitDice(oPC);
    int nLA = StringToInt(Get2DACache("ECL", "LA", GetRacialType(oPC))) + GetPersistantLocalInt(oPC, "template_LA");
    int nCheck = nLA - nBuyoff;
    if (DEBUG) DoDebug("PRE-LA nBuyoff "+IntToString(nBuyoff)+" nChar "+IntToString(nChar)+" nLA "+IntToString(nLA)+" nCheck "+IntToString(nCheck));
    if (0 >= nCheck) // no LA
    	return FALSE;
    
	if (!nBuyoff) // Not purchased anything yet
	{
		if (nChar >= StringToInt(Get2DACache("la_buyoff", "1st", nLA)))
			nReturn = TRUE;
	}
	if (nBuyoff == 1) // Purchased first already
	{
		if (nChar >= StringToInt(Get2DACache("la_buyoff", "2nd", nLA)))
			nReturn = TRUE;
	}	
	if (nBuyoff == 2) // Purchased second already
	{
		if (nChar >= StringToInt(Get2DACache("la_buyoff", "3rd", nLA)))
			nReturn = TRUE;
	}	
	if (nBuyoff == 3) // Purchased third already
	{
		if (nChar >= StringToInt(Get2DACache("la_buyoff", "4th", nLA)))
			nReturn = TRUE;
	}
	if (nBuyoff == 4) // Purchased fourth already
	{
		if (nChar >= StringToInt(Get2DACache("la_buyoff", "5th", nLA)))
			nReturn = TRUE;
	}
	if (nBuyoff == 5) // Purchased fifth already
	{
		if (nChar >= StringToInt(Get2DACache("la_buyoff", "6th", nLA)))
			nReturn = TRUE;
	}	
    if (DEBUG) DoDebug("nReturn "+IntToString(nReturn)+" nBuyoff "+IntToString(nBuyoff)+" nChar "+IntToString(nChar)+" nLA "+IntToString(nLA));	

	return nReturn;
}		