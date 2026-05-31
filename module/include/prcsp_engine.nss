
// Module Constants
const float CACHE_TIMEOUT_CAST = 2.0;
const string CASTER_LEVEL_TAG = "PRCEffectiveCasterLevel";

// Constants that dictate ResistSpell results
const int SPELL_RESIST_FAIL = 0;
const int SPELL_RESIST_PASS = 1;
const int SPELL_RESIST_GLOBE = 2;
const int SPELL_RESIST_MANTLE = 3;

int PRCDoResistSpell(object oCaster, object oTarget, int nEffCasterLvl=0, float fDelay = 0.0);

int CheckSpellfire(object oCaster, object oTarget, int bFriendly = FALSE);

#include "prc_inc_racial"
//#include "prc_feat_const"
//#include "prc_class_const"
//#include "prcsp_reputation"
#include "prcsp_archmaginc"
//#include "prc_add_spell_dc"
#include "prc_add_spl_pen"

//
//  This function is a wrapper should someone wish to rewrite the Bioware
//  version. This is where it should be done.
//
int PRCResistSpell(object oCaster, object oTarget)
{
    return ResistSpell(oCaster, oTarget);
}

//
//  This function is a wrapper should someone wish to rewrite the Bioware
//  version. This is where it should be done.
//
int PRCGetSpellResistance(object oTarget, object oCaster)
{
    int iSpellRes = GetSpellResistance(oTarget);
    int nHD = GetHitDice(oTarget);

    //racial pack SR
    int iRacialSpellRes = 0;
    if(GetHasFeat(FEAT_SPELL27, oTarget))
        iRacialSpellRes = 27 + nHD;
    else if(GetHasFeat(FEAT_SPELL25, oTarget))
        iRacialSpellRes = 25 + nHD;
    else if(GetHasFeat(FEAT_SPELL23, oTarget))
        iRacialSpellRes = 23 + nHD;
    else if(GetHasFeat(FEAT_SPELL22, oTarget))
        iRacialSpellRes = 22 + nHD;
    else if(GetHasFeat(FEAT_SPELL21, oTarget))
        iRacialSpellRes = 21 + nHD;
    else if(GetHasFeat(FEAT_SPELL20, oTarget))
        iRacialSpellRes = 20 + nHD;
    else if(GetHasFeat(FEAT_SPELL19, oTarget))
        iRacialSpellRes = 19 + nHD;
    else if(GetHasFeat(FEAT_SPELL18, oTarget))
        iRacialSpellRes = 18 + nHD;
    else if(GetHasFeat(FEAT_SPELL17, oTarget))
        iRacialSpellRes = 17 + nHD;
    else if(GetHasFeat(FEAT_SPELL16, oTarget))
        iRacialSpellRes = 16 + nHD;
    else if(GetHasFeat(FEAT_SPELL15, oTarget))
        iRacialSpellRes = 15 + nHD;
    else if(GetHasFeat(FEAT_SPELL14, oTarget))
        iRacialSpellRes = 14 + nHD;
    else if(GetHasFeat(FEAT_SPELL13, oTarget))
        iRacialSpellRes = 13 + nHD;
    else if(GetHasFeat(FEAT_SPELL11, oTarget))
        iRacialSpellRes = 11 + nHD;
    else if(GetHasFeat(FEAT_SPELL10, oTarget))
        iRacialSpellRes = 10 + nHD;
    else if(GetHasFeat(FEAT_SPELL8, oTarget))
        iRacialSpellRes = 8 + nHD;
    else if(GetHasFeat(FEAT_SPELL5, oTarget))
        iRacialSpellRes = 5 + nHD;
    if(iRacialSpellRes > iSpellRes)
        iSpellRes = iRacialSpellRes;

    // Exalted Companion, can also be used for Celestial Template
    if(GetLocalInt(oTarget, "CelestialTemplate") || GetLocalInt(oTarget, "PseudonaturalTemplate"))
    {
        int nSR = nHD * 2;
        if (nSR > 25) nSR = 25;
        if (nSR > iSpellRes) iSpellRes = nSR;
    }

    // Enlightened Fist SR = 10 + monk level + enlightened fist level
    if(GetHasFeat(FEAT_EF_DIAMOND_SOUL, oTarget))
    {
        int nEF = 10 + GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oTarget) + GetLevelByClass(CLASS_TYPE_MONK, oTarget);
        if(nEF > iSpellRes)
            iSpellRes = nEF;
    }

    // Contemplative SR = 15 + contemplative level
    if(GetHasFeat(FEAT_DIVINE_SOUL, oTarget))
    {
        int nCont = 15 + GetLevelByClass(CLASS_TYPE_CONTEMPLATIVE, oTarget);
        if(nCont > iSpellRes)
            iSpellRes = nCont;
    }
    
    // Marrutact
    if(GetRacialType(oTarget) == RACIAL_TYPE_MARRUTACT)
    {
        int nCont = 9 + GetHitDice(oTarget);
        if(nCont > iSpellRes)
            iSpellRes = nCont;
    }    
    
    // Hobgoblin Wsrsoul
    if(GetRacialType(oTarget) == RACIAL_TYPE_HOBGOBLIN_WARSOUL)
    {
        int nCont = 8 + GetHitDice(oTarget);
        if(nCont > iSpellRes)
            iSpellRes = nCont;
    }      
    
    // Exordius Weapon of Legacy
    if(GetLocalInt(oTarget, "ExordiusSR"))
    {
        int nCont = 5 + GetHitDice(oTarget);
        if(nCont > iSpellRes)
            iSpellRes = nCont;
    } 
    
    // Hammer of Witches Weapon of Legacy
    if(GetLocalInt(oTarget, "HammerWitchesSR"))
    {
        // SR vs arcane only
        if(GetIsArcaneClass(PRCGetLastSpellCastClass(oCaster)))
        {
            int nCont = 5 + GetHitDice(oTarget);
            if(nCont > iSpellRes)
                iSpellRes = nCont;
        }        
    } 
    
	// Ur-Priest
	int nPriestLevel = GetLevelByClass(CLASS_TYPE_UR_PRIEST, oTarget);
	if(nPriestLevel >= 4)
	{
		// SR vs divine only
		if(GetIsDivineClass(PRCGetLastSpellCastClass(oCaster)))
		{
			//if(nPriestLevel > 50) nPriestLevel = 50;  //:: cap if needed
			
			// Calculate bonus: 15 at level 4, then +5 for every additional 4 levels
			int nCont = 15 + (((nPriestLevel - 4) / 4) * 5);
			
			if(nCont > iSpellRes)
				iSpellRes = nCont;
		}
	}	
/*     // Ur-Priest
    if(GetLevelByClass(CLASS_TYPE_UR_PRIEST, oTarget) >= 4)
    {
        // SR vs divine only
        if(GetIsDivineClass(PRCGetLastSpellCastClass(oCaster)))
        {
            int nCont = 15;
            if (GetLevelByClass(CLASS_TYPE_UR_PRIEST, oTarget) >= 8) nCont = 20;
            if(nCont > iSpellRes)
                iSpellRes = nCont;
        }        
    } */    
    
    // Dread Carapace Heart Bind
    if(GetIsIncarnumUser(oTarget))
    {
    	if (GetIsMeldBound(oTarget, MELD_DREAD_CARAPACE) == CHAKRA_CROWN || GetIsMeldBound(oTarget, MELD_DREAD_CARAPACE) == CHAKRA_DOUBLE_CROWN)
    	{
    		int nCont = 5 + (4 * GetEssentiaInvested(oTarget, MELD_DREAD_CARAPACE));
        	if(nCont > iSpellRes)
        	    iSpellRes = nCont;
        }	
        if (GetHasSpellEffect(MELD_SPELLWARD_SHIRT, oTarget)) // MELD_SPELLWARD_SHIRT
        {
        	int nCont = 5 + (4 * GetEssentiaInvested(oTarget, MELD_SPELLWARD_SHIRT));
        	if(nCont > iSpellRes)
        	    iSpellRes = nCont;        	
        }
    }     

    // Foe Hunter SR stacks with normal SR when a spell is cast by their hated enemy
    if(GetHasFeat(FEAT_HATED_ENEMY_SR, oTarget) && GetLocalInt(oTarget, "HatedFoe") == MyPRCGetRacialType(oCaster))
    {
         iSpellRes += 15 + GetLevelByClass(CLASS_TYPE_FOE_HUNTER, oTarget);
    }
    
    // Adds +4 to SR
    if(GetHasFeat(FEAT_PSYCHIC_REFUSAL, oTarget))
        iSpellRes += 4;
        
    // Forsaker SR adds to existing
    if(GetLevelByClass(CLASS_TYPE_FORSAKER, oTarget))
        iSpellRes = iSpellRes + 10 + GetLevelByClass(CLASS_TYPE_FORSAKER, oTarget);        
        
    return iSpellRes;
}

//
//  If a spell is resisted, display the effect
//
void PRCShowSpellResist(object oCaster, object oTarget, int nResist, float fDelay = 0.0)
{
    // If either caster/target is a PC send them a message
    if (GetIsPC(oCaster))
    {
        string message = nResist == SPELL_RESIST_FAIL ?
            "Target is affected by the spell." : "Target resisted the spell.";
        SendMessageToPC(oCaster, message);
    }
    if (GetIsPC(oTarget))
    {
        string message = nResist == SPELL_RESIST_FAIL ?
            "You are affected by the spell." : "You resisted the spell.";
        SendMessageToPC(oTarget, message);
    }

    if (nResist != SPELL_RESIST_FAIL) {
        // Default to a standard resistance
        int eve = VFX_IMP_MAGIC_RESISTANCE_USE;

        // Check for other resistances
        if (nResist == SPELL_RESIST_GLOBE)
            eve = VFX_IMP_GLOBE_USE;
        else if (nResist == SPELL_RESIST_MANTLE)
            eve = VFX_IMP_SPELL_MANTLE_USE;

        // Render the effect
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT,
            EffectVisualEffect(eve), oTarget));
    }
}

//
//  This function overrides the BioWare MyResistSpell.
//  TODO: Change name to PRCMyResistSpell.
//
int PRCDoResistSpell(object oCaster, object oTarget, int nEffCasterLvl=0, float fDelay = 0.0)
{
    int nResist;

    // Check if the archmage shape mastery applies to this target
    if (CheckSpellfire(oCaster, oTarget) || CheckMasteryOfShapes(oCaster, oTarget) || ExtraordinarySpellAim(oCaster, oTarget) || (GetLocalInt(oCaster, "WOL_DesertWindFireball") && GetSpellId() == SPELL_FIREBALL))
        nResist = SPELL_RESIST_MANTLE;
    else if(GetLevelByClass(CLASS_TYPE_BEGUILER, oCaster) >= 20 && GetIsDeniedDexBonusToAC(oTarget, oCaster, TRUE))
    {
        //Beguilers of level 20+ automatically overcome SR of targets denied Dex bonus to AC
        nResist = SPELL_RESIST_FAIL;
    }
    else if(GetLocalInt(oCaster, "CunningBreach"))
    {
        //Factotum can pay to breach all SR for a round
        nResist = SPELL_RESIST_FAIL;
    }    
    //using vitriolic blast with eldritch spellweave
    else if(oTarget == GetLocalObject(oCaster, "SPELLWEAVE_TARGET")
    && GetLocalInt(oCaster, "BlastEssence") == INVOKE_VITRIOLIC_BLAST)
    {
        nResist = SPELL_RESIST_FAIL;
    }
    else {
        // Check immunities and mantles, otherwise ignore the result completely
        nResist = PRCResistSpell(oCaster, oTarget);

        //Resonating Resistance
        if((nResist <= SPELL_RESIST_PASS) && (GetHasSpellEffect(SPELL_RESONATING_RESISTANCE, oTarget)))
        {
            nResist = PRCResistSpell(oCaster, oTarget);
        }

        if (nResist <= SPELL_RESIST_PASS)
        {
            nResist = SPELL_RESIST_FAIL;

            // Because the version of this function was recently changed to
            // optionally allow the caster level, we must calculate it here.
            // The result will be cached for a period of time.
            if (!nEffCasterLvl) {
                nEffCasterLvl = GetLocalInt(oCaster, CASTER_LEVEL_TAG);
                if (!nEffCasterLvl) {
                    nEffCasterLvl = PRCGetCasterLevel(oCaster) + SPGetPenetr();
                    SetLocalInt(oCaster, CASTER_LEVEL_TAG, nEffCasterLvl);
                    DelayCommand(CACHE_TIMEOUT_CAST,
                        DeleteLocalInt(oCaster, CASTER_LEVEL_TAG));
                }
            }
            
            // Pernicious Magic
            // +4 caster level vs SR Weave user (not Evoc & Trans spells)
            int iWeav;
            if (GetHasFeat(FEAT_PERNICIOUSMAGIC,oCaster))
            {
                    if (!GetHasFeat(FEAT_SHADOWWEAVE,oTarget))
                    {
                            int nSchool = GetLocalInt(oCaster, "X2_L_LAST_SPELLSCHOOL_VAR");
                            if ( nSchool != SPELL_SCHOOL_EVOCATION && nSchool != SPELL_SCHOOL_TRANSMUTATION )
                            iWeav=4;
                    }
            }

			//:: A tie favors the caster.  
			int nSRValue = PRCGetSpellResistance(oTarget, oCaster);  
			int nD20Roll = d20(1);  
			int nCasterTotal = nEffCasterLvl + nD20Roll + iWeav;  
			  
			if (nCasterTotal < nSRValue)  
				nResist = SPELL_RESIST_PASS;  
			  
			//:: Optional Detailed SR check to caster 
			if (GetIsPC(oCaster) && nResist != SPELL_RESIST_MANTLE && nResist != SPELL_RESIST_GLOBE && nSRValue > 0 && GetPRCSwitch(PRC_SHOW_SR_CHECK_DETAILS))  
			{  
				string message = nResist == SPELL_RESIST_FAIL ?  
					"Target affected. Roll: " + IntToString(nCasterTotal) + " vs SR: " + IntToString(nSRValue) :  
					"Target resisted. Roll: " + IntToString(nCasterTotal) + " vs SR: " + IntToString(nSRValue) +   
					" (missed by " + IntToString(nSRValue - nCasterTotal) + ")";  
				SendMessageToPC(oCaster, message);  
			}  
			  
			//:: Basic pass/fail messages  
			PRCShowSpellResist(oCaster, oTarget, nResist, fDelay);


/*             // A tie favors the caster.
            if ((nEffCasterLvl + d20(1)+iWeav) < PRCGetSpellResistance(oTarget, oCaster))
                nResist = SPELL_RESIST_PASS; */
        }
    }

	// Karsites heal from resisting a spell
	if(GetRacialType(oTarget) == RACIAL_TYPE_KARSITE && nResist == SPELL_RESIST_PASS)
	{
		int nSpellLevel = StringToInt(Get2DACache("spells", "Innate", PRCGetSpellId()));
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nSpellLevel*2), oTarget);
	}	
		
    PRCShowSpellResist(oCaster, oTarget, nResist, fDelay);

    return nResist;
}

//Returns the maximum number of spellfire levels oPC can store
int SpellfireMax(object oPC)
{
    //can't absorb spells without feat
    if(!GetHasFeat(FEAT_SPELLFIRE_WIELDER, oPC)) return 0;

    int nCON = GetAbilityScore(oPC, ABILITY_CONSTITUTION);
    
	int i, nCount;
    for (i = FEAT_EPIC_SPELLFIRE_WIELDER_I; i <= FEAT_EPIC_SPELLFIRE_WIELDER_X; i++)
    {
		if (GetHasFeat(i, oPC)) 
			nCON = nCON + 4;	
    }
    if (DEBUG) DoDebug("SpellfireMax nCon is "+IntToString(nCON));    
    
    int nStorage = ((GetLevelByClass(CLASS_TYPE_SPELLFIRE, oPC) + 1) / 2) + 1;
    if(nStorage > 5) nStorage = 5;
    return nCON * nStorage;
}

//Increases the number of stored spellfire levels on a creature
void AddSpellfireLevels(object oPC, int nLevels)
{
    int nMax = SpellfireMax(oPC);
    int nStored = GetPersistantLocalInt(oPC, "SpellfireLevelStored");
    nStored += nLevels;
    if(nStored > nMax) nStored = nMax;  //capped
    SetPersistantLocalInt(oPC, "SpellfireLevelStored", nStored);
}

//Checks if spell target can absorb spells by being a spellfire wielder
int CheckSpellfire(object oCaster, object oTarget, int bFriendly = FALSE)
{
    //can't absorb spells without feat
    if(!GetHasFeat(FEAT_SPELLFIRE_WIELDER, oTarget)) return 0;

    //Can't absorb own spells/powers if switch is set
    if(GetPRCSwitch(PRC_SPELLFIRE_DISALLOW_CHARGE_SELF) && oTarget == oCaster) return 0;

    //abilities rely on access to weave
    if(GetHasFeat(FEAT_SHADOWWEAVE, oTarget)) return 0;

    int nSpellID = PRCGetSpellId();
    if(!bFriendly && GetLocalInt(oCaster, "IsAOE_" + IntToString(nSpellID)))
        return 0; //can't absorb hostile AOE spells

    int nSpellfireLevel = GetPersistantLocalInt(oTarget, "SpellfireLevelStored");
    if(DEBUG) DoDebug("CheckSpellfire: " + IntToString(nSpellfireLevel) + " levels stored", oTarget);

    int nMax = SpellfireMax(oTarget);

    if(DEBUG) DoDebug("CheckSpellfire: Maximum " + IntToString(nMax), oTarget);

    //can't absorb any more spells, sanity check
    if(nSpellfireLevel >= nMax) return 0;

    //increasing stored levels
    int nSpellLevel = GetLocalInt(oCaster, "PRC_CurrentManifest_PowerLevel");   //replicates GetPowerLevel(oCaster);
    if(!nSpellLevel)    //not a power                       //avoids compiler problems
    {                                                       //with includes
        string sInnate = Get2DACache("spells", "Innate", nSpellID);//lookup_spell_innate(nSpellID);
        if(sInnate == "") return 0; //no innate level, unlike cantrips
        nSpellLevel = StringToInt(sInnate);
    }
    /*
    string sInnate = Get2DACache("spells", "Innate", nSpellID);
    if(sInnate == "") return 0; //no innate level, unlike cantrips
    int nSpellLevel = StringToInt(sInnate);
    */

    AddSpellfireLevels(oTarget, nSpellLevel);

    //absorbed
    return 1;
}

//:; void main(){}