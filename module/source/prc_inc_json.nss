//:://////////////////////////////////////////////
//::	;-.  ,-.   ,-.  ,-. 
//::	|  ) |  ) /    (   )
//::	|-'  |-<  |     ;-: 
//::	|    |  \ \    (   )
//::	'    '  '  `-'  `-' 
//:://////////////////////////////////////////////
//::  
/*
	Library for json related functions.
	
*/
//::  
//::////////////////////////////////////////////// 
//::	Script:     prc_inc_json.nss
//::	Author:     Jaysyn
//::	Created:    2025-08-14 12:52:32
//:://////////////////////////////////////////////
#include "nw_inc_gff"
#include "inc_debug"
#include "prc_inc_racial"
#include "prc_inc_nwscript"
#include "prc_inc_spells"
#include "prc_inc_util"
#include "prc_inc_fork"
#include "prc_inc_natweap"

//:: Get a random General feat.
void ApplyParagonBonusFeat(object oCreature, int iFeat);

//::---------------------------------------------|
//:: Helper functions                            |
//::---------------------------------------------|
int GetHealerCompanionBonus(int nHealerLvl)
{
    // No bonus before 12th level
    if (nHealerLvl < 12)
        return 0;

    int nBonus = 0;

    // Non-epic improvements: 12, 15, 18, 21 (every 3 levels)
    if (nHealerLvl >= 12)
    {
        int nPreEpicIntervals = ( (nHealerLvl < 21) ? (nHealerLvl - 12) : (21 - 12) ) / 3;
        nBonus += 2 + (nPreEpicIntervals * 2);
    }

    // Epic improvements: 24, 28, 32, 36... (every 4 levels)
    if (nHealerLvl >= 24)
    {
        int nEpicIntervals = (nHealerLvl - 24) / 4;
        // First epic improvement is +2 at 24
        nBonus += 2 + (nEpicIntervals * 2);
    }

    return nBonus;
}

/* int GetHealerCompanionBonus(int nHealerLvl)
{
    if (nHealerLvl < 12)
        return 0;

    // Shift so that 12–14 yields interval 0
    int nIntervals = (nHealerLvl - 12) / 3;

    return 2 + (nIntervals * 2);
} */


//:: Function to calculate the maximum possible hitpoints for oCreature
int GetMaxPossibleHP(object oCreature)
{
    int nMaxHP = 0;  // Stores the total maximum hitpoints
    int i = 1;       // Initialize position for class index
	int nConb	= GetAbilityModifier(ABILITY_CONSTITUTION, oCreature);
	int nRacial	= MyPRCGetRacialType(oCreature);
	int nSize 	= PRCGetCreatureSize(oCreature);
    
    // Loop through each class position the creature may have, checking each class in turn
    while (TRUE)
    {
        // Get the class ID at position i
        int nClassID = GetClassByPosition(i, oCreature);

        // If class is invalid (no more classes to check), break out of loop
        if (nClassID == CLASS_TYPE_INVALID)
            break;

        // Get the number of levels in this class
        int nClassLevels = GetLevelByClass(nClassID, oCreature);
        
        // Get the row index of the class in classes.2da by using class ID as the row index
        int nHitDie = StringToInt(Get2DAString("classes", "HitDie", nClassID));
        
        // Add maximum HP for this class (Hit Die * number of levels in this class)
        nMaxHP += nClassLevels * nHitDie;
		
        // Move to the next class position
        i++;
    }
    
	if(nRacial == RACIAL_TYPE_CONSTRUCT || nRacial == RACIAL_TYPE_UNDEAD)
	{
		nConb = 0;
	}	
	
	nMaxHP += nConb * GetHitDice(oCreature);
	
	if(nRacial == RACIAL_TYPE_CONSTRUCT)
	{
		if(nSize == CREATURE_SIZE_FINE) nMaxHP += 0;
		if(nSize == CREATURE_SIZE_DIMINUTIVE) nMaxHP += 0;		
		if(nSize == CREATURE_SIZE_TINY) nMaxHP += 0;		
		if(nSize == CREATURE_SIZE_SMALL) nMaxHP += 10;
		if(nSize == CREATURE_SIZE_MEDIUM) nMaxHP += 20;
		if(nSize == CREATURE_SIZE_LARGE) nMaxHP += 30;
		if(nSize == CREATURE_SIZE_HUGE) nMaxHP += 40;
		if(nSize == CREATURE_SIZE_GARGANTUAN) nMaxHP += 60;			
	}	
	
    return nMaxHP;
}

// Returns how many feats a creature should gain when its HD increases
int CalculateFeatsFromHD(int nOriginalHD, int nNewHD)
{
    // HD increase
    int nHDIncrease = nNewHD - nOriginalHD;

    if (nHDIncrease <= 0)
        return 0; // No new feats if HD did not increase

    // D&D 3E: 1 feat per 3 HD
    int nBonusFeats = nHDIncrease / 3;

    return nBonusFeats;
}

// Returns how many stat boosts a creature needs based on its HD
int GetStatBoostsFromHD(int nCreatureHD, int nModiferCap)
{
    // Make sure we don't get negative boosts
    int nBoosts = (40 - nCreatureHD) / 4;
    if (nBoosts < 0)
    {
        nBoosts = 0;
    }
    return nBoosts;
}

// Struct to hold size modifiers
struct SizeModifiers
{
    int strMod;
    int dexMod;
    int conMod;
    int naturalAC;
    int attackBonus;
    int dexSkillMod;
};

//:: Returns ability mod for score
int GetAbilityModFromValue(int nAbilityValue)
{
    int nMod = (nAbilityValue - 10) / 2;

    // Adjust if below 10 and odd
    if (nAbilityValue < 10 && (nAbilityValue % 2) != 0)
    {
        nMod = nMod - 1;
    }
    return nMod;
}

//:: Get a random General feat.
void PickParagonBonusFeat(object oCreature)
{
//:: Paragon creatures get a +15 to all ability scores, 
//:: so can always meet feat pre-reqs.

//:: Detect spellcasting classes  (FOR FUTURE USE)
	int i;
    for (i = 1; i <= 8; i++)
    {
        if (GetIsArcaneClass(GetClassByPosition(i, oCreature)))
        {
            SetLocalInt(oCreature, "ParagonArcaneCaster", 0);
        }
        if (GetIsDivineClass(GetClassByPosition(i, oCreature)))
        {
            SetLocalInt(oCreature, "ParagonDivineCaster", 0);
        }			
    }	
	switch (Random(18))
    {
	//:: Dodge -> Mobility -> Spring Attack
        case 0: 
		{
			int iDodge 			= GetHasFeat(FEAT_DODGE, oCreature);
			int iMobility 		= GetHasFeat(FEAT_MOBILITY, oCreature);
			int iSpringAttack 	= GetHasFeat(FEAT_SPRING_ATTACK, oCreature);
	
		//:: Grant only the first missing feat in the chain
            if (iDodge == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_DODGE);
            } 
			else if (iMobility == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_MOBILITY);
            }
			else if (iSpringAttack == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_SPRING_ATTACK);
            }
		}
        break;
	//:: Power Attack -> Cleave -> Imp Power Attack -> Great Cleave
        case 1: 
		{
			int iPower 		= GetHasFeat(FEAT_POWER_ATTACK, oCreature);
			int iCleave 	= GetHasFeat(FEAT_CLEAVE, oCreature);
			int iImpPower 	= GetHasFeat(FEAT_IMPROVED_POWER_ATTACK, oCreature);
			int iGrCleave 	= GetHasFeat(FEAT_GREAT_CLEAVE, oCreature);
	
		//:: Grant only the first missing feat in the chain
            if (iPower == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_POWER_ATTACK);
            } 
			else if (iCleave == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_CLEAVE);
            }
			else if (iImpPower == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_IMPROVED_POWER_ATTACK);
            }
			else if (iGrCleave == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_GREAT_CLEAVE);
            }			
		}
        break;	
	//:: Expertise -> Imp Expertise -> Whirlwind Attack -> Imp  Whirlwind Attack
        case 2: 
		{
			int iEx 		= GetHasFeat(FEAT_EXPERTISE, oCreature);
			int iImpEx		= GetHasFeat(FEAT_IMPROVED_EXPERTISE, oCreature);
			int iWhirl		= GetHasFeat(FEAT_WHIRLWIND_ATTACK, oCreature);
			int iImpWhirl	= GetHasFeat(FEAT_IMPROVED_WHIRLWIND, oCreature);
	
		//:: Grant only the first missing feat in the chain
            if (iEx == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_EXPERTISE);
            } 
			else if (iImpEx == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_IMPROVED_EXPERTISE);
            }
			else if (iWhirl == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_WHIRLWIND_ATTACK);
            }
			else if (iImpWhirl == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_IMPROVED_WHIRLWIND);
            }
		}
        break;	
	//:: Disarm -> Expertise -> Improved Disarm -> Imp Expertise
        case 3: 
		{
			int iDisarm		= GetHasFeat(FEAT_DISARM, oCreature);
			int iEx 		= GetHasFeat(FEAT_EXPERTISE, oCreature);
			int iImpDisarm	= GetHasFeat(FEAT_IMPROVED_DISARM, oCreature);
			int iImpEx		= GetHasFeat(FEAT_IMPROVED_EXPERTISE, oCreature);
	
		//:: Grant only the first missing feat in the chain
            if (iDisarm == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_DISARM);
            } 
			else if (iEx == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_EXPERTISE);
            }
			else if (iImpDisarm == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_IMPROVED_DISARM);
            }
			else if (iImpEx == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_IMPROVED_EXPERTISE);
            }
		}
        break;			
	//:: Toughness
        case 4:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_TOUGHNESS);
		}
		break;
	//:: Great Fortitude
        case 5:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_GREAT_FORTITUDE);
		}
		break;
	//:: Lightining Reflexes
        case 6:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_LIGHTNING_REFLEXES);
		}
		break;		
	//:: Iron Will -> Unnatural Will
        case 7:
		{
			int iIronWill 			= GetHasFeat(FEAT_IRON_WILL, oCreature);
			int iUnnaturalWill 		= GetHasFeat(FEAT_UNNATURAL_WILL, oCreature);
			
		//:: Grant only the first missing feat in the chain
			if (iIronWill == 0) 
			{
				ApplyParagonBonusFeat(oCreature, FEAT_IRON_WILL);
			} 			
			else if (iUnnaturalWill == 0)		
			{
				ApplyParagonBonusFeat(oCreature, FEAT_UNNATURAL_WILL);
			}
		}
		break;	
	//:: Blind-Fight
        case 8:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_BLIND_FIGHT);
		}
		break;	
	//:: Improved Initiative
        case 9:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_IMPROVED_INITIATIVE);
		}
		break;	
	//:: Alertness
        case 10:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_ALERTNESS);
		}
		break;	
	//:: Blooded
        case 11:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_BLOODED);
		}
		break;	
	//:: Side-step Charge
        case 12:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_SIDESTEP_CHARGE);
		}
		break;
	//:: Thug
        case 13:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_THUG);
		}
		break;			
	//:: Dive for Cover
        case 14:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_DIVE_FOR_COVER);
		}
		break;		
	//:: Endurance -> Strong Stomach
        case 15: 
		{
			int iEndurance 			= GetHasFeat(FEAT_ENDURANCE, oCreature);
			int iStrStomach 		= GetHasFeat(FEAT_STRONG_STOMACH, oCreature);
	
		//:: Grant only the first missing feat in the chain
            if (iEndurance == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_ENDURANCE);
            } 
			else if (iStrStomach == 0) 
			{
                ApplyParagonBonusFeat(oCreature, FEAT_STRONG_STOMACH);
            }
		}
        break;
	//:: Resist Disease
        case 16:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_RESIST_DISEASE);
		}
		break;			
	//:: Resist Poison
        case 17:
		{
			ApplyParagonBonusFeat(oCreature, FEAT_RESIST_POISON);
		}
		break;			
	}
}

//:: Check & apply the feat using EffectBonusFeat if it 
//:: doesn't exist on the creature already
void ApplyParagonBonusFeat(object oCreature, int iFeat)
{
    // If the creature does not already have the feat, apply it
    if (!GetHasFeat(iFeat, oCreature))
    {
        effect eFeat = EffectBonusFeat(iFeat);
		effect eLink = UnyieldingEffect(eFeat);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oCreature);
    }
	else
	{
		DelayCommand(0.0f, PickParagonBonusFeat(oCreature));
	}		
}

//:: Apply Paragon effects to a non-PC creature
void ApplyParagonEffects(object oCreature, int nBaseHD, int nBaseCR) 
{
//:: Declare major variables	
	int nNewCR;
	
	effect eParagon;

//:: Set maximum hit points for each HD
    int nParagonHP = (GetMaxPossibleHP(oCreature) + (nBaseHD * GetAbilityModifier(ABILITY_CONSTITUTION, oCreature)));
    SetCurrentHitPoints(oCreature, nParagonHP);
	
//:: Tripling the speed for all movement types
	eParagon = EffectLinkEffects(eParagon, EffectMovementSpeedIncrease(300));
	
//:: +25 luck bonus on all attack rolls
	eParagon = EffectLinkEffects(eParagon, EffectAttackIncrease(25));	
	
//:: +20 luck bonus on damage rolls for melee and thrown ranged attacks
	eParagon = EffectLinkEffects(eParagon, EffectDamageIncrease(20));	

//:: AC Bonuses: +12 insight, +12 luck
    eParagon = EffectLinkEffects(eParagon, EffectACIncrease(12, AC_DODGE_BONUS));
	eParagon = EffectLinkEffects(eParagon, EffectACIncrease(12, AC_DEFLECTION_BONUS));
    
//:: Boost caster & SLA level by 15
		SetLocalInt(oCreature, PRC_CASTERLEVEL_ADJUSTMENT, 15);

//:: Fire and cold resistance 10, or keep the higher existing resistance if applicable
    eParagon = EffectLinkEffects(eParagon, EffectDamageResistance(DAMAGE_TYPE_FIRE, 10));
    eParagon = EffectLinkEffects(eParagon, EffectDamageResistance(DAMAGE_TYPE_COLD, 10));

//:: Damage Reduction 20/epic or retain existing DR if higher
    eParagon = EffectLinkEffects(eParagon, EffectDamageReduction(20, DAMAGE_POWER_ENERGY));

//:: Spell Resistance equal to CR +10, or retain existing SR if higher
	int iExSR = GetSpellResistance(oCreature);
	int nSpellResistance;
	
	if (iExSR < nBaseCR + 10)
	{
		nSpellResistance = nBaseCR + 10;
	}
	else
	{
		nSpellResistance = 0;
	}	
	
    eParagon = EffectLinkEffects(eParagon, EffectSpellResistanceIncrease(nSpellResistance));

//:: Fast Healing 20
    eParagon = EffectLinkEffects(eParagon, EffectRegenerate(20, 6.0f));

//:: Saving Throws: +10 insight bonus on all saving throws
    eParagon = EffectLinkEffects(eParagon, EffectSavingThrowIncrease(SAVING_THROW_ALL, 10));

//:: Skills: +10 competence bonus to all skill checks	
    int nSkillID = 0; 

    while (TRUE)
    {
        //:: Get & check skill
        string sSkillLabel = Get2DACache("skills", "Label", nSkillID);

        //::  Break when out of skills
        if (sSkillLabel == "")
            break;

        //:: Apply the skill increase effect for the current skill
        eParagon = EffectLinkEffects(eParagon, EffectSkillIncrease(nSkillID, 10));
        

        //:: Move to the next skill ID
        nSkillID++;
    }
	
//:: Two free general feats.	
	PickParagonBonusFeat(oCreature);
	PickParagonBonusFeat(oCreature);
	
	eParagon = UnyieldingEffect(eParagon);
	
	ApplyEffectToObject(DURATION_TYPE_PERMANENT, eParagon, oCreature);	
}

// Build and return all effects for the Celestial Template
effect CelestialTemplateEffects(int nHD)
{
    int nResist;
    int nDRAmount;
    int nDRBypass;

    // -------------------------
    // Elemental Resistances
    // -------------------------
    // 1–7 HD = 5
    // 8+ HD = 10
    if (nHD >= 8)
    {
        nResist = 10;
    }
    else
    {
        nResist = 5;
    }

    // -------------------------
    // Damage Reduction
    // -------------------------
    // 1–3 HD = none
    // 4–11 HD = 5/magic
    // 12+ HD = 10/magic
    if (nHD >= 12)
    {
        nDRAmount = 10;
        nDRBypass = DAMAGE_POWER_PLUS_ONE;   // DR 10/magic
    }
    else if (nHD >= 4)
    {
        nDRAmount = 5;
        nDRBypass = DAMAGE_POWER_PLUS_ONE;   // DR 5/magic
    }
    else
    {
        nDRAmount = 0;
        nDRBypass = 0;                       // no DR
    }

    // -------------------------
    // Build Effects
    // -------------------------
    effect eEffects;
    effect eRes;

    // Acid
    eRes = EffectDamageResistance(DAMAGE_TYPE_ACID, nResist, 0);
    eEffects = eRes;

    // Cold
    eRes = EffectDamageResistance(DAMAGE_TYPE_COLD, nResist, 0);
    eEffects = EffectLinkEffects(eEffects, eRes);

    // Electricity
    eRes = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, nResist, 0);
    eEffects = EffectLinkEffects(eEffects, eRes);

    // DR if any
    if (nDRAmount > 0)
    {
        effect eDR = EffectDamageReduction(nDRAmount, nDRBypass, 0);
        eEffects = EffectLinkEffects(eEffects, eDR);
    }

	eEffects = UnyieldingEffect(eEffects);
	
    return eEffects;
}

void ReallyEquipItemInSlot(object oNPC, object oItem, int nSlot)
{
  if (GetItemInSlot(nSlot) != oItem)
  {
    //ClearAllActions();
    AssignCommand(oNPC, ActionEquipItem(oItem, nSlot));
    DelayCommand(0.5, ReallyEquipItemInSlot(oNPC, oItem, nSlot));
  }
}

// Get the size of a JSON array
int GetJsonArraySize(json jArray)
{
    int iSize = 0;
    while (JsonArrayGet(jArray, iSize) != JsonNull())
    {
        iSize++;
    }
    return iSize;
}

int CheckForWeapon(object oCreature)
{
    if (GetIsWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature)) == 1 || GetIsWeapon(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature)) == 1)
    {
		// oCreature has a weapon in at least one hand
		return TRUE;
    }
    else
    {
        // oCreature doesn't have a weapon in either hand
		return FALSE;
    }
}

//:: Adds Psuedonatural resistances & DR.
void ApplyPseudonaturalEffects(object oCreature)
{
    if(!GetIsObjectValid(oCreature)) return;

    int nHD = GetHitDice(oCreature);
	if(DEBUG) DoDebug("prc_inc_json >> ApplyPseudonaturalEffects: nHD is: "+IntToString(nHD)+".");
    // -------------------------
    // Spell Resistance
    // SR = 10 + HD (max 25)
    // -------------------------
    int nSR = 10 + nHD;
    if(nSR > 25) nSR = 25;

    effect eSR = EffectSpellResistanceIncrease(nSR);
	eSR = TagEffect(eSR, "PSEUDO_SR");
	eSR = EffectLinkEffects(eSR, UnyieldingEffect(eSR));
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSR, oCreature);

    // -------------------------
    // Acid/Electricity Resistance
    // Reference Table:
    // HD 1–3  : Resist 5
    // HD 4–7  : Resist 5
    // HD 8–11 : Resist 10
    // HD >=12 : Resist 15
    // -------------------------
    int nResist;

	if(nHD <= 7) 		nResist = 5;
    else if(nHD <=11) 	nResist = 10;
    else              	nResist = 15;

    effect eResAcid  = EffectDamageResistance(DAMAGE_TYPE_ACID, nResist);
    eResAcid  = TagEffect(eResAcid, "PSEUDO_RES_ACID");
	eResAcid = EffectLinkEffects(eResAcid, UnyieldingEffect(eResAcid));

    effect eResElec  = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, nResist);
    eResElec  = TagEffect(eResElec, "PSEUDO_RES_ELEC");
	eResElec = EffectLinkEffects(eResElec, UnyieldingEffect(eResElec));

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eResAcid,  oCreature);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eResElec,  oCreature);

    // -------------------------
    // Damage Reduction
    // Reference Table:
    // HD 1–3  : none
    // HD 4–7  : DR 5 / magic
    // HD 8–11 : DR 5 / magic
    // HD >=12 : DR 10 / magic
    // -------------------------

    int nDR;
    if(nHD <= 3) 		{ nDR = 0; }
    else if(nHD <= 11)	{ nDR = 5; }
    else 				{ nDR = 10; }

    effect eDR = EffectDamageReduction(nDR, DAMAGE_POWER_PLUS_ONE, 0, FALSE);
    eDR = TagEffect(eDR, "PSEUDO_DR_MAGIC");
	eDR = EffectLinkEffects(eDR, UnyieldingEffect(eDR));
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDR, oCreature);
}


//::---------------------------------------------|
//:: JSON functions                              |
//::---------------------------------------------|

//:: Get the first spell ID that a creature knows (not memorized, but known)  
//:: Returns -1 if no spells are found  
int json_GetFirstKnownSpell(json jCreature)  
{  
    // Store the creature JSON for later use by GetNext  
    SetLocalJson(GetModule(), "JSON_SPELL_CREATURE", jCreature);  
    SetLocalInt(GetModule(), "JSON_SPELL_CLASS_INDEX", 0);  
    SetLocalInt(GetModule(), "JSON_SPELL_LEVEL", 0);  
    SetLocalInt(GetModule(), "JSON_SPELL_INDEX", 0);  
      
    // Get the ClassList  
    json jClassList = GffGetList(jCreature, "ClassList");  
    if (jClassList == JsonNull())  
    {  
        if(DEBUG) DoDebug("json_GetFirstKnownSpell: No ClassList found");  
        return -1;  
    }  
      
    int nClassCount = JsonGetLength(jClassList);  
    int iClass, iSpellLevel, iSpell;  
      
    // Iterate through all classes  
    for (iClass = 0; iClass < nClassCount; iClass++)  
    {  
        json jClass = JsonArrayGet(jClassList, iClass);  
        if (jClass == JsonNull()) continue;  
          
        // Check all spell levels (0-9)  
        for (iSpellLevel = 0; iSpellLevel <= 9; iSpellLevel++)  
        {  
            string sKnownList = "KnownList" + IntToString(iSpellLevel);  
            json jKnownList = GffGetList(jClass, sKnownList);  
            if (jKnownList == JsonNull()) continue;  
              
            int nSpellCount = JsonGetLength(jKnownList);  
              
            // Look for the first spell  
            for (iSpell = 0; iSpell < nSpellCount; iSpell++)  
            {  
                json jSpell = JsonArrayGet(jKnownList, iSpell);  
                if (jSpell == JsonNull()) continue;  
                  
                json jSpellID = GffGetWord(jSpell, "Spell");  
                if (jSpellID != JsonNull())  
                {  
                    int nSpellID = JsonGetInt(jSpellID);  
                      
                    // Update tracking variables for next call  
                    SetLocalInt(GetModule(), "JSON_SPELL_CLASS_INDEX", iClass);  
                    SetLocalInt(GetModule(), "JSON_SPELL_LEVEL", iSpellLevel);  
                    SetLocalInt(GetModule(), "JSON_SPELL_INDEX", iSpell + 1);  
                      
                    return nSpellID;  
                }  
            }  
        }  
    }  
      
    // Clean up when done  
    DeleteLocalJson(GetModule(), "JSON_SPELL_CREATURE");  
    DeleteLocalInt(GetModule(), "JSON_SPELL_CLASS_INDEX");  
    DeleteLocalInt(GetModule(), "JSON_SPELL_LEVEL");  
    DeleteLocalInt(GetModule(), "JSON_SPELL_INDEX");  
      
    return -1; // No more spells found  
}  
  
//:: Get the next spell ID from the creature's known spells  
//:: Returns -1 if no more spells are found  
int json_GetNextKnownSpell()  
{  
    json jCreature = GetLocalJson(GetModule(), "JSON_SPELL_CREATURE");  
    if (jCreature == JsonNull())  
        return -1;  
          
    int nClassIndex = GetLocalInt(GetModule(), "JSON_SPELL_CLASS_INDEX");  
    int nSpellLevel = GetLocalInt(GetModule(), "JSON_SPELL_LEVEL");  
    int nSpellIndex = GetLocalInt(GetModule(), "JSON_SPELL_INDEX");  
      
    // Get the ClassList  
    json jClassList = GffGetList(jCreature, "ClassList");  
    if (jClassList == JsonNull())  
        return -1;  
      
    int nClassCount = JsonGetLength(jClassList);  
    int iClass, iSpellLevel, iSpell;  
      
    // Continue from where we left off  
    for (iClass = nClassIndex; iClass < nClassCount; iClass++)  
    {  
        json jClass = JsonArrayGet(jClassList, iClass);  
        if (jClass == JsonNull()) continue;  
          
        // Check all spell levels (0-9)  
        for (iSpellLevel = nSpellLevel; iSpellLevel <= 9; iSpellLevel++)  
        {  
            string sKnownList = "KnownList" + IntToString(iSpellLevel);  
            json jKnownList = GffGetList(jClass, sKnownList);  
            if (jKnownList == JsonNull()) continue;  
              
            int nSpellCount = JsonGetLength(jKnownList);  
              
            // Start from saved index if same class and level, otherwise start from 0  
            int nStartIndex = (iClass == nClassIndex && iSpellLevel == nSpellLevel) ? nSpellIndex : 0;  
              
            for (iSpell = nStartIndex; iSpell < nSpellCount; iSpell++)  
            {  
                json jSpell = JsonArrayGet(jKnownList, iSpell);  
                if (jSpell == JsonNull()) continue;  
                  
                json jSpellID = GffGetWord(jSpell, "Spell");  
                if (jSpellID != JsonNull())  
                {  
                    int nSpellID = JsonGetInt(jSpellID);  
                      
                    // Update tracking variables for next call  
                    SetLocalInt(GetModule(), "JSON_SPELL_CLASS_INDEX", iClass);  
                    SetLocalInt(GetModule(), "JSON_SPELL_LEVEL", iSpellLevel);  
                    SetLocalInt(GetModule(), "JSON_SPELL_INDEX", iSpell + 1);  
                      
                    return nSpellID;  
                }  
            }  
              
            // Reset spell index for next spell level  
            nSpellIndex = 0;  
        }  
          
        // Reset spell level for next class  
        nSpellLevel = 0;  
    }  
      
    // Clean up when done  
    DeleteLocalJson(GetModule(), "JSON_SPELL_CREATURE");  
    DeleteLocalInt(GetModule(), "JSON_SPELL_CLASS_INDEX");  
    DeleteLocalInt(GetModule(), "JSON_SPELL_LEVEL");  
    DeleteLocalInt(GetModule(), "JSON_SPELL_INDEX");  
      
    return -1; // No more spells found  
}  
  

//:: Returns the Constitution value from a GFF creature UTC
int json_GetCONValue(json jCreature)
{
    int nCon = 0; // default if missing

    // Check if the Con field exists
    if (GffGetFieldExists(jCreature, "Con"))
    {
        nCon = JsonGetInt(GffGetByte(jCreature, "Con"));
    }

    return nCon;
}

//:: Returns the Challenge Rating from a GFF creature UTC
float json_GetChallengeRating(json jCreature)
{
    float fCR = 0.25; // default if missing

    if (GffGetFieldExists(jCreature, "ChallengeRating"))
    {
        json jCR = GffGetFloat(jCreature, "ChallengeRating");
        if (jCR != JsonNull())
        {
            fCR = JsonGetFloat(jCR);
        }
    }

    return fCR;
}

//:: Returns the integer value of a VarTable entry named sVarName, or 0 if not found.
int json_GetLocalIntFromVarTable(json jCreature, string sVarName)
{
    json jVarTable = GffGetList(jCreature, "VarTable");
    if (jVarTable == JsonNull())
        return 0;

    int nCount = JsonGetLength(jVarTable);
    int i;
    for (i = 0; i < nCount; i++)
    {
        json jEntry = JsonArrayGet(jVarTable, i);
        if (jEntry == JsonNull()) continue;

        // Get the Name field using GFF functions
        json jName = GffGetString(jEntry, "Name");
        if (jName == JsonNull()) continue;
        string sName = JsonGetString(jName);

        if (sName == sVarName)
        {
            // Get the Type field to verify it's an integer
            json jType = GffGetDword(jEntry, "Type");
            if (jType != JsonNull())
            {
                int nType = JsonGetInt(jType);
                if (nType == 1) // Type 1 = integer
                {
                    // Get the Value field using GFF functions
                    json jValue = GffGetInt(jEntry, "Value");
                    if (jValue == JsonNull()) return 0;
                    return JsonGetInt(jValue);
                }
            }
        }
    }

    return 0;
}

//:: Returns the string value of a VarTable entry named sVarName, or "" if not found.
string json_GetLocalStringFromVarTable(json jCreature, string sVarName)
{
    json jVarTable = GffGetList(jCreature, "VarTable");
    if (jVarTable == JsonNull())
        return "";

    int nCount = JsonGetLength(jVarTable);
    int i;
    for (i = 0; i < nCount; i++)
    {
        json jEntry = JsonArrayGet(jVarTable, i);
        if (jEntry == JsonNull()) continue;

        // Get the Name field using GFF functions
        json jName = GffGetString(jEntry, "Name");
        if (jName == JsonNull()) continue;
        string sName = JsonGetString(jName);

        if (sName == sVarName)
        {
            // Get the Type field to verify it's a string
            json jType = GffGetDword(jEntry, "Type");
            if (jType != JsonNull())
            {
                int nType = JsonGetInt(jType);
                if (nType == 3) // Type 3 = string
                {
                    // Get the Value field using GFF functions
                    json jValue = GffGetString(jEntry, "Value");
                    if (jValue == JsonNull()) return "";
                    return JsonGetString(jValue);
                }
            }
        }
    }

    return "";
}

//:: Returns the total Hit Dice from a JSON'd creature GFF.
int json_GetCreatureHD(json jCreature)
{
    int nHD = 0;

    json jClasses = GffGetList(jCreature, "ClassList");
    if (jClasses == JsonNull())
        return 0;

    int nCount = JsonGetLength(jClasses);
    int i;
    for (i = 0; i < nCount; i = i + 1)
    {
        json jClass = JsonArrayGet(jClasses, i);
        if (jClass == JsonNull())
            continue;
            
        json jLevel = GffGetShort(jClass, "ClassLevel"); // Use GffGetShort, not GffGetField
        if (jLevel != JsonNull())
        {
            int nLevel = JsonGetInt(jLevel);
            nHD += nLevel;
        }
    }

    if (nHD <= 0) nHD = 1;
    return nHD;
}

json json_RecalcMaxHP(json jCreature, int iHitDieValue)
{
    int iHD  = json_GetCreatureHD(jCreature);
	
	//:: Retrieve the RacialType field
    json jRacialTypeField = JsonObjectGet(jCreature, "Race");	
	int nRacialType = JsonGetInt(jRacialTypeField);
	
	//:: Retrieve the CreatureSize from the creature appearance field
    json jAppearanceField = JsonObjectGet(jCreature, "Appearance_Type");	
	int nAppearance = JsonGetInt(jAppearanceField);	
	
	int nSize = StringToInt(Get2DAString("appearance", "SizeCategory", nAppearance));
	
    //CEP adds other sizes, take them into account too
    if(nSize == 20)
        nSize = CREATURE_SIZE_DIMINUTIVE;
    else if(nSize == 21)
        nSize = CREATURE_SIZE_FINE;
    else if(nSize == 22)
        nSize = CREATURE_SIZE_GARGANTUAN;
    else if(nSize == 23)
        nSize = CREATURE_SIZE_COLOSSAL;	
	
    int iNewMaxHP   = (iHitDieValue * iHD);

	if(nRacialType == RACIAL_TYPE_CONSTRUCT)
	{
		if(nSize == CREATURE_SIZE_FINE) iNewMaxHP += 0;
		if(nSize == CREATURE_SIZE_DIMINUTIVE) iNewMaxHP += 0;		
		if(nSize == CREATURE_SIZE_TINY) iNewMaxHP += 0;		
		if(nSize == CREATURE_SIZE_SMALL) iNewMaxHP += 10;
		if(nSize == CREATURE_SIZE_MEDIUM) iNewMaxHP += 20;
		if(nSize == CREATURE_SIZE_LARGE) iNewMaxHP += 30;
		if(nSize == CREATURE_SIZE_HUGE) iNewMaxHP += 40;
		if(nSize == CREATURE_SIZE_GARGANTUAN) iNewMaxHP += 60;			
	}	
	
	if(DEBUG) DoDebug("prc_inc_json >> json_RecalcMaxHP | New MaxHP is: "+IntToString(iNewMaxHP)+ ".");

    jCreature = GffReplaceShort(jCreature, "MaxHitPoints", iNewMaxHP);
    jCreature = GffReplaceShort(jCreature, "CurrentHitPoints", iNewMaxHP);
    jCreature = GffReplaceShort(jCreature, "HitPoints", iNewMaxHP);

/* 	SendMessageToPC(GetFirstPC(), "HD = " + IntToString(iHD));
	SendMessageToPC(GetFirstPC(), "HitDieValue = " + IntToString(iHitDieValue));
	SendMessageToPC(GetFirstPC(), "CON = " + IntToString(iCON));
	SendMessageToPC(GetFirstPC(), "Mod = " + IntToString(iMod));
	SendMessageToPC(GetFirstPC(), "New HP = " + IntToString(iNewMaxHP)); */

    return jCreature;
}

//:: Reads ABILITY_TO_INCREASE from creature's VarTable and applies stat boosts based on increased HD
json json_ApplyAbilityBoostFromHD(json jCreature, int nOriginalHD)
{
    if (jCreature == JsonNull())
        return jCreature;

    // Get the ability to increase from VarTable
    int nAbilityToIncrease = json_GetLocalIntFromVarTable(jCreature, "ABILITY_TO_INCREASE");
    if (nAbilityToIncrease < 0 || nAbilityToIncrease > 5)
    {
        DoDebug("json_ApplyAbilityBoostFromHD: Invalid ABILITY_TO_INCREASE value: " + IntToString(nAbilityToIncrease));
        return jCreature; // Invalid ability index
    }

    // Calculate total current HD from ClassList
    json jClassList = GffGetList(jCreature, "ClassList");
    if (jClassList == JsonNull())
    {
        DoDebug("json_ApplyAbilityBoostFromHD: Failed to get ClassList");
        return jCreature;
    }

    int nCurrentTotalHD = 0;
    int nClassCount = JsonGetLength(jClassList);
    int i;
    
    for (i = 0; i < nClassCount; i++)
    {
        json jClass = JsonArrayGet(jClassList, i);
        if (jClass != JsonNull())
        {
            json jClassLevel = GffGetShort(jClass, "ClassLevel");
            if (jClassLevel != JsonNull())
            {
                nCurrentTotalHD += JsonGetInt(jClassLevel);
            }
        }
    }
	
	if(DEBUG) DoDebug("prc_inc_json >> json_ApplyAbilityBoostFromHD: nCurrentTotalHD = "+IntToString(nCurrentTotalHD)+".");

    if (nCurrentTotalHD <= 0)
    {
        DoDebug("json_ApplyAbilityBoostFromHD: No valid Hit Dice found");
        return jCreature;
    }

    // Calculate stat boosts based on crossing level thresholds
    // Characters get stat boosts at levels 4, 8, 12, 16, 20, etc.
    int nOriginalBoosts = nOriginalHD / 4;  // How many boosts they already had
    int nCurrentBoosts = nCurrentTotalHD / 4;  // How many they should have now
    int nBoosts = nCurrentBoosts - nOriginalBoosts;  // Additional boosts to apply
    
    if (nBoosts <= 0)
    {
        if(DEBUG) DoDebug("json_ApplyAbilityBoostFromHD: No boosts needed (Original boosts: " + IntToString(nOriginalBoosts) + ", Current boosts: " + IntToString(nCurrentBoosts) + ")");
        return jCreature;
    }

    if(DEBUG) DoDebug("json_ApplyAbilityBoostFromHD: Applying " + IntToString(nBoosts) + " boosts to ability " + IntToString(nAbilityToIncrease) + " for HD increase from " + IntToString(nOriginalHD) + " to " + IntToString(nCurrentTotalHD));

    // Determine which ability to boost and apply the increases
    string sAbilityField;
    switch (nAbilityToIncrease)
    {
        case 0: sAbilityField = "Str"; break;
        case 1: sAbilityField = "Dex"; break;
        case 2: sAbilityField = "Con"; break;
        case 3: sAbilityField = "Int"; break;
        case 4: sAbilityField = "Wis"; break;
        case 5: sAbilityField = "Cha"; break;
        default:
            if(DEBUG) DoDebug("json_ApplyAbilityBoostFromHD: Unknown ability index: " + IntToString(nAbilityToIncrease));
            return jCreature;
    }

    // Get current ability score
    json jCurrentAbility = GffGetByte(jCreature, sAbilityField);
    if (jCurrentAbility == JsonNull())
    {
        if(DEBUG) DoDebug("json_ApplyAbilityBoostFromHD: Failed to get " + sAbilityField + " score");
        return jCreature;
    }

    int nCurrentScore = JsonGetInt(jCurrentAbility);
    int nNewScore = nCurrentScore + nBoosts;

    // Clamp to valid byte range
    if (nNewScore < 1) nNewScore = 1;
    if (nNewScore > 250) nNewScore = 250;

    if(DEBUG) DoDebug("json_ApplyAbilityBoostFromHD: Increasing " + sAbilityField + " from " + IntToString(nCurrentScore) + " to " + IntToString(nNewScore));

    // Apply the ability score increase
    jCreature = GffReplaceByte(jCreature, sAbilityField, nNewScore);
    if (jCreature == JsonNull())
    {
        if(DEBUG) DoDebug("json_ApplyAbilityBoostFromHD: Failed to update " + sAbilityField);
        return JsonNull();
    }

    if(DEBUG) DoDebug("json_ApplyAbilityBoostFromHD: Successfully applied ability boosts");
    return jCreature;
}

//:: Adjust a skill by its ID
json json_AdjustCreatureSkillByID(json jCreature, int nSkillID, int nMod)
{
    // Get the SkillList
    json jSkillList = GffGetList(jCreature, "SkillList");
    if (jSkillList == JsonNull())
    {
        if(DEBUG) DoDebug("json_AdjustCreatureSkillByID: Failed to get SkillList");
        return jCreature;
    }
    
    // Check if we have enough skills in the list
    int nSkillCount = JsonGetLength(jSkillList);
    if (nSkillID >= nSkillCount)
    {
        if(DEBUG) DoDebug("json_AdjustCreatureSkillByID: Skill ID " + IntToString(nSkillID) + " exceeds skill list length " + IntToString(nSkillCount));
        return jCreature;
    }
    
    // Get the skill struct at the correct index
    json jSkill = JsonArrayGet(jSkillList, nSkillID);
    if (jSkill == JsonNull())
    {
        if(DEBUG) DoDebug("json_AdjustCreatureSkillByID: Failed to get skill at index " + IntToString(nSkillID));
        return jCreature;
    }
    
    // Get current rank
    json jRank = GffGetByte(jSkill, "Rank");
    if (jRank == JsonNull())
    {
        if(DEBUG) DoDebug("json_AdjustCreatureSkillByID: Failed to get Rank for skill ID " + IntToString(nSkillID));
        return jCreature;
    }
    
    int nCurrentRank = JsonGetInt(jRank);
    int nNewRank = nCurrentRank + nMod;
    
    // Clamp to valid range
    if (nNewRank < 0) nNewRank = 0;
    if (nNewRank > 127) nNewRank = 127;
    
    // Update the rank in the skill struct
    jSkill = GffReplaceByte(jSkill, "Rank", nNewRank);
    if (jSkill == JsonNull())
    {
        if(DEBUG) DoDebug("json_AdjustCreatureSkillByID: Failed to replace Rank for skill ID " + IntToString(nSkillID));
        return JsonNull();
    }
    
    // Replace the skill in the array
    jSkillList = JsonArraySet(jSkillList, nSkillID, jSkill);
    
    // Replace the SkillList in the creature
    jCreature = GffReplaceList(jCreature, "SkillList", jSkillList);
    
    return jCreature;
}

//:: Reads FutureFeat1..FutureFeatN from the template's VarTable and appends them to FeatList if missing.
json json_AddFeatsFromCreatureVars(json jCreature, int nOriginalHD)
{
    if (jCreature == JsonNull())
        return jCreature;

    // Calculate current total HD
    int nCurrentHD = json_GetCreatureHD(jCreature);
    int nAddedHD = nCurrentHD - nOriginalHD;
    
    if (nAddedHD <= 0)
    {
        if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: No additional HD to process (Current: " + IntToString(nCurrentHD) + ", Original: " + IntToString(nOriginalHD) + ")");
        return jCreature;
    }

    // Calculate how many feats the creature should get based on added HD
    // Characters get a feat at levels 1, 3, 6, 9, 12, 15, 18, etc.
    // For added levels, we need to check what feat levels they cross
    int nOriginalFeats = (nOriginalHD + 2) / 3; // Feats from original HD
    int nCurrentFeats = (nCurrentHD + 2) / 3;   // Feats from current HD
    int nNumFeats = nCurrentFeats - nOriginalFeats; // Additional feats earned
    
    if (nNumFeats <= 0)
    {
        if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: No additional feats earned from " + IntToString(nAddedHD) + " added HD");
        return jCreature;
    }

    if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Processing " + IntToString(nNumFeats) + " feats for " + IntToString(nAddedHD) + " added HD (Original: " + IntToString(nOriginalHD) + ", Current: " + IntToString(nCurrentHD) + ")");

    // Get or create FeatList
    json jFeatArray = GffGetList(jCreature, "FeatList");
    if (jFeatArray == JsonNull())
        jFeatArray = JsonArray();

    int nOriginalFeatCount = JsonGetLength(jFeatArray);
    if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Original feat count: " + IntToString(nOriginalFeatCount));

    int nAdded = 0;
    int i = 0;
    int nMaxIterations = 100; // Safety valve
    int nIterations = 0;

    while (nAdded < nNumFeats && nIterations < nMaxIterations)
    {
        nIterations++;
        string sVarName = "FutureFeat" + IntToString(i);
        
        if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Checking " + sVarName);
        
        int nFeat = json_GetLocalIntFromVarTable(jCreature, sVarName);

        if (nFeat <= 0)
        {
            if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: " + sVarName + " not found or invalid");
            i++;
            continue;
        }

        if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Found " + sVarName + " = " + IntToString(nFeat));

        // Check if feat already exists
        int bHasFeat = FALSE;
        int nFeatCount = JsonGetLength(jFeatArray);
        int j;
        
        for (j = 0; j < nFeatCount; j++)
        {
            json jFeatStruct = JsonArrayGet(jFeatArray, j);
            if (jFeatStruct != JsonNull())
            {
                json jFeatValue = GffGetWord(jFeatStruct, "Feat");
                if (jFeatValue != JsonNull() && JsonGetInt(jFeatValue) == nFeat)
                {
                    bHasFeat = TRUE;
                    if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Feat " + IntToString(nFeat) + " already exists");
                    break;
                }
            }
        }

        // Insert if missing
        if (!bHasFeat)
        {
            json jNewFeat = JsonObject();
            jNewFeat = JsonObjectSet(jNewFeat, "__struct_id", JsonInt(1));
            jNewFeat = GffAddWord(jNewFeat, "Feat", nFeat);
            
            if (jNewFeat == JsonNull())
            {
                if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Failed to create feat struct for feat " + IntToString(nFeat));
                break;
            }
            
            jFeatArray = JsonArrayInsert(jFeatArray, jNewFeat);
            nAdded++;
            
            if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Added feat " + IntToString(nFeat) + " (" + IntToString(nAdded) + "/" + IntToString(nNumFeats) + ")");
        }

        i++;
        
        // Safety break if we've checked too many variables
        if (i > 100)
        {
            if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Safety break - checked too many FutureFeat variables");
            break;
        }
    }

    if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Completed. Added " + IntToString(nAdded) + " feats in " + IntToString(nIterations) + " iterations");

    // Save back the modified FeatList only if we added something
    if (nAdded > 0)
    {
        jCreature = GffReplaceList(jCreature, "FeatList", jFeatArray);
        if (jCreature == JsonNull())
        {
            if(DEBUG) DoDebug("json_AddFeatsFromCreatureVars: Failed to replace FeatList");
            return JsonNull();
        }
    }

    return jCreature;
}

//:: Get the size of a JSON array
int json_GetArraySize(json jArray)
{
    int iSize = 0;
    while (JsonArrayGet(jArray, iSize) != JsonNull())
    {
        iSize++;
    }
    return iSize;
}

//:: Directly updates oCreature's Base Natural AC if iNewAC is higher.
//::
json json_UpdateBaseAC(json jCreature, int iNewAC)
{
    //json jBaseAC = GffGetByte(jCreature, "Creature/value/NaturalAC/value");
	json jBaseAC = GffGetByte(jCreature, "NaturalAC");

    if (jBaseAC == JsonNull())
    {
        return JsonNull();
    }
    else if (JsonGetInt(jBaseAC) > iNewAC)
    {
        return jCreature;
    }
	else
	{
		jCreature = GffReplaceByte(jCreature, "NaturalAC", iNewAC);
		
		return jCreature;
	}
}

//:: Increases jCreature's Natural AC by iAddAC.
//::
json json_IncreaseBaseAC(json jCreature, int iAddAC)
{
    json jBaseAC = GffGetByte(jCreature, "NaturalAC");

    if (jBaseAC == JsonNull())
    {
        return JsonNull();
    }
    else
    {
        int nBaseAC = JsonGetInt(jBaseAC);          // convert JSON number -> int
        int nNewAC  = nBaseAC + iAddAC;

        jCreature = GffReplaceByte(jCreature, "NaturalAC", nNewAC);
        return jCreature;
    }
}

//:: Directly modifies jCreature's Challenge Rating.
//:: This is useful for most XP calculations.
json json_UpdateCR(json jCreature, int nBaseCR, int nCRMod)
{
	int nNewCR;
	
//:: Add CRMod to current CR
	nNewCR = nBaseCR + nCRMod;
	
//:: Modify Challenge Rating
	jCreature = GffReplaceFloat(jCreature, "ChallengeRating", IntToFloat(nNewCR));
	
	return jCreature;
}

//:: Directly modifies ability scores in a creature's JSON GFF.
//::
json json_UpdateTemplateStats(json jCreature, int iModStr = 0, int iModDex = 0, int iModCon = 0, int iModInt = 0, int iModWis = 0, int iModCha = 0)
{
    int iCurrent;

    // STR
    if (!GffGetFieldExists(jCreature, "Str", GFF_FIELD_TYPE_BYTE))
        jCreature = GffAddByte(jCreature, "Str", 10);
    iCurrent = JsonGetInt(GffGetByte(jCreature, "Str"));
    jCreature = GffReplaceByte(jCreature, "Str", iCurrent + iModStr);

    // DEX
    if (!GffGetFieldExists(jCreature, "Dex", GFF_FIELD_TYPE_BYTE))
        jCreature = GffAddByte(jCreature, "Dex", 10);
    iCurrent = JsonGetInt(GffGetByte(jCreature, "Dex"));
    jCreature = GffReplaceByte(jCreature, "Dex", iCurrent + iModDex);

    // CON
    if (!GffGetFieldExists(jCreature, "Con", GFF_FIELD_TYPE_BYTE))
        jCreature = GffAddByte(jCreature, "Con", 10);
    iCurrent = JsonGetInt(GffGetByte(jCreature, "Con"));
    jCreature = GffReplaceByte(jCreature, "Con", iCurrent + iModCon);

    // INT
    if (!GffGetFieldExists(jCreature, "Int", GFF_FIELD_TYPE_BYTE))
        jCreature = GffAddByte(jCreature, "Int", 10);
    iCurrent = JsonGetInt(GffGetByte(jCreature, "Int"));
    jCreature = GffReplaceByte(jCreature, "Int", iCurrent + iModInt);

    // WIS
    if (!GffGetFieldExists(jCreature, "Wis", GFF_FIELD_TYPE_BYTE))
        jCreature = GffAddByte(jCreature, "Wis", 10);
    iCurrent = JsonGetInt(GffGetByte(jCreature, "Wis"));
    jCreature = GffReplaceByte(jCreature, "Wis", iCurrent + iModWis);

    // CHA
    if (!GffGetFieldExists(jCreature, "Cha", GFF_FIELD_TYPE_BYTE))
        jCreature = GffAddByte(jCreature, "Cha", 10);
    iCurrent = JsonGetInt(GffGetByte(jCreature, "Cha"));
    jCreature = GffReplaceByte(jCreature, "Cha", iCurrent + iModCha);

    return jCreature;
}

//:: Directly modifies oCreature's ability scores.
//::
json json_UpdateCreatureStats(json jCreature, object oBaseCreature, int iModStr = 0, int iModDex = 0, int iModCon = 0, int iModInt = 0, int iModWis = 0, int iModCha = 0)
{
//:: Retrieve and modify ability scores
	int iCurrentStr = GetAbilityScore(oBaseCreature, ABILITY_STRENGTH);
	int iCurrentDex = GetAbilityScore(oBaseCreature, ABILITY_DEXTERITY);
	int iCurrentCon = GetAbilityScore(oBaseCreature, ABILITY_CONSTITUTION);
	int iCurrentInt = GetAbilityScore(oBaseCreature, ABILITY_INTELLIGENCE);
	int iCurrentWis = GetAbilityScore(oBaseCreature, ABILITY_WISDOM);
	int iCurrentCha = GetAbilityScore(oBaseCreature, ABILITY_CHARISMA);

	jCreature = GffReplaceByte(jCreature, "Str", iCurrentStr + iModStr);
	jCreature = GffReplaceByte(jCreature, "Dex", iCurrentDex + iModDex);
	jCreature = GffReplaceByte(jCreature, "Con", iCurrentCon + iModCon);
	jCreature = GffReplaceByte(jCreature, "Int", iCurrentInt + iModInt);
	jCreature = GffReplaceByte(jCreature, "Wis", iCurrentWis + iModWis);
	jCreature = GffReplaceByte(jCreature, "Cha", iCurrentCha + iModCha); 

	return jCreature;
}

//:: Increases a creature's Hit Dice in its JSON GFF data by nAmount
json json_AddHitDice(json jCreature, int nAmount)
{
    if (jCreature == JsonNull() || nAmount <= 0)
        return jCreature;

    // Get the ClassList
    json jClasses = GffGetList(jCreature, "ClassList");
    if (jClasses == JsonNull() || JsonGetLength(jClasses) == 0)
        return jCreature;

    // Grab the first class entry
    json jFirstClass = JsonArrayGet(jClasses, 0);

    json jCurrentLevel = GffGetShort(jFirstClass, "ClassLevel");
    int nCurrentLevel = JsonGetInt(jCurrentLevel);
    int nNewLevel = nCurrentLevel + nAmount;

    // Replace ClassLevel only
    jFirstClass = GffReplaceShort(jFirstClass, "ClassLevel", nNewLevel);

    // Put modified class back into the array
    jClasses = JsonArraySet(jClasses, 0, jFirstClass);

    // Replace ClassList in the creature JSON
    jCreature = GffReplaceList(jCreature, "ClassList", jClasses);

    return jCreature;
}

//:: Adjusts a creature's size by nSizeChange (-4 to +4) and updates ability scores accordingly.
json json_AdjustCreatureSize(json jCreature, int nSizeDelta, int nIncorporeal = FALSE)
{
    if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Entering function. nSizeDelta=" + IntToString(nSizeDelta));

    if (jCreature == JsonNull() || nSizeDelta == 0)
    {
        if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Exiting: jCreature is null or nSizeDelta is 0");
        return jCreature;
    }

    // Get Appearance_Type using GFF functions
    json jAppearanceType = GffGetWord(jCreature, "Appearance_Type");
    if (jAppearanceType == JsonNull())
    {
        if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Failed to get Appearance_Type");
        return jCreature;
    }
    
    int nAppearance = JsonGetInt(jAppearanceType);
    int nCurrentSize = StringToInt(Get2DAString("appearances", "Size", nAppearance));

    // Default to Medium (4) if invalid
    if (nCurrentSize < 0 || nCurrentSize > 8) nCurrentSize = 4;

    if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Appearance_Type =" + IntToString(nAppearance) + ", Size =" + IntToString(nCurrentSize));

    int nSteps = nSizeDelta;
    
    // Calculate modifiers based on size change
    int strMod      = nSteps * 4;
    int dexMod      = nSteps * -1;
    int conMod      = nSteps * 2;
    int naturalAC   = nSteps * 1;
    int dexSkillMod = nSteps * -2;
	
	if(nIncorporeal)
	{
		strMod = 0;
	}

    if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Applying stat modifiers: STR=" + IntToString(strMod) +
                                 " DEX=" + IntToString(dexMod) +
                                 " CON=" + IntToString(conMod));

    // Update ability scores using GFF functions with error checking
    json jStr = GffGetByte(jCreature, "Str");
    if (jStr != JsonNull())
    {
        int nNewStr = JsonGetInt(jStr) + strMod;
        if (nNewStr < 1) nNewStr = 1;
        if (nNewStr > 255) nNewStr = 255;
        
        jCreature = GffReplaceByte(jCreature, "Str", nNewStr);
        if (jCreature == JsonNull())
        {
            if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Failed to update Str");
            return JsonNull();
        }
    }

    json jDex = GffGetByte(jCreature, "Dex");
    if (jDex != JsonNull())
    {
        int nNewDex = JsonGetInt(jDex) + dexMod;
        if (nNewDex < 1) nNewDex = 1;
        if (nNewDex > 255) nNewDex = 255;
        
        jCreature = GffReplaceByte(jCreature, "Dex", nNewDex);
        if (jCreature == JsonNull())
        {
            if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Failed to update Dex");
            return JsonNull();
        }
    }

    json jCon = GffGetByte(jCreature, "Con");
    if (jCon != JsonNull())
    {
        int nNewCon = JsonGetInt(jCon) + conMod;
        if (nNewCon < 1) nNewCon = 1;
        if (nNewCon > 255) nNewCon = 255;
        
        jCreature = GffReplaceByte(jCreature, "Con", nNewCon);
        if (jCreature == JsonNull())
        {
            if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Failed to update Con");
            return JsonNull();
        }
    }

    // Update Natural AC
    json jNaturalAC = GffGetByte(jCreature, "NaturalAC");
    if (jNaturalAC != JsonNull())
    {
        int nCurrentNA = JsonGetInt(jNaturalAC);
        if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Current NaturalAC: " + IntToString(nCurrentNA));
        
        int nNewNA = nCurrentNA + naturalAC;
        if (nNewNA < 0) nNewNA = 0;
        if (nNewNA > 255) nNewNA = 255;
        
        jCreature = GffReplaceByte(jCreature, "NaturalAC", nNewNA);
        if (jCreature == JsonNull())
        {
            if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Failed to update NaturalAC");
            return JsonNull();
        }
    }

    // Adjust all Dexterity-based skills by finding them in skills.2da
    if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Adjusting DEX-based skills");
    
    int nSkillID = 0;
    while (TRUE)
    {
        string sKeyAbility = Get2DAString("skills", "KeyAbility", nSkillID);
        
        // Break when we've reached the end of skills
        if (sKeyAbility == "")
            break;
        
        // If this skill uses Dexterity, adjust it
        if (sKeyAbility == "DEX")
        {
            string sSkillLabel = Get2DAString("skills", "Label", nSkillID);
            if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Adjusting DEX skill: " + sSkillLabel + " (ID: " + IntToString(nSkillID) + ")");
            
            jCreature = json_AdjustCreatureSkillByID(jCreature, nSkillID, dexSkillMod);
            if (jCreature == JsonNull())
            {
                if(DEBUG) DoDebug("prc_inc_json >> json_AdjustCreatureSize: Failed adjusting skill ID " + IntToString(nSkillID));
                return JsonNull();
            }
        }
        
        nSkillID++;
    }

    if(DEBUG) DoDebug("json_AdjustCreatureSize completed successfully");
    return jCreature;
}

//:: Changes jCreature's creature type.
json json_ModifyRacialType(json jCreature, int nNewRacialType)
{
    if(DEBUG)DoDebug("prc_inc_json >> json_ModifyRacialType: Entering function");
	
	// Retrieve the RacialType field
    json jRacialTypeField = JsonObjectGet(jCreature, "Race");

    if (JsonGetType(jRacialTypeField) == JSON_TYPE_NULL)
    {
        DoDebug("prc_inc_json >> json_ModifyRacialType: JsonGetType error 1: " + JsonGetError(jRacialTypeField));
		//SpeakString("JsonGetType error 1: " + JsonGetError(jRacialTypeField));
        return JsonNull();
    }

    // Retrieve the value to modify
    json jRacialTypeValue = JsonObjectGet(jRacialTypeField, "value");

    if (JsonGetType(jRacialTypeValue) != JSON_TYPE_INTEGER)
    {
        DoDebug("prc_inc_json >> json_ModifyRacialType: JsonGetType error 2: " + JsonGetError(jRacialTypeValue));
		//SpeakString("JsonGetType error 2: " + JsonGetError(jRacialTypeValue));
        return JsonNull();
    }

	jCreature = GffReplaceByte(jCreature, "Race", nNewRacialType);

    // Return the new creature object
    return jCreature;
}

//:: Updates CR for Celestial template  
json json_UpdateCelestialCR(json jCreature, int nBaseCR, int nHD)  
{  
    int nNewCR;  
      
    //:: Calculate CR based on HD  
    if (nHD <= 3)  
    {  
        nNewCR = nBaseCR;  
    }  
    else if (nHD <= 7)  
    {  
        nNewCR = nBaseCR + 1;  
    }  
    else  
    {  
        nNewCR = nBaseCR + 2;  
    }  
      
    //:: Modify Challenge Rating  
    jCreature = GffReplaceFloat(jCreature, "ChallengeRating", IntToFloat(nNewCR));  
    return jCreature;  
}

//:: Adds Celestial SLA's to creature  
json json_AddCelestialPowers(json jCreature)  
{  
    // Get the existing SpecAbilityList  
    json jSpecAbilityList = GffGetList(jCreature, "SpecAbilityList");  
    if (jSpecAbilityList == JsonNull())  
    {  
        jSpecAbilityList = JsonArray();  
    }  
      
    //:: Add Smite Evil 1x / day  
    json jSpecAbility = JsonObject();  
    jSpecAbility = GffAddWord(jSpecAbility, "Spell", SPELLABILITY_SMITE_EVIL);  
    jSpecAbility = GffAddByte(jSpecAbility, "SpellCasterLevel", json_GetCreatureHD(jCreature));  
    jSpecAbility = GffAddByte(jSpecAbility, "SpellFlags", 1);  
    jSpecAbilityList = JsonArrayInsert(jSpecAbilityList, jSpecAbility);  
      
    //:: Add the list to the creature  
    jCreature = GffAddList(jCreature, "SpecAbilityList", jSpecAbilityList);  
    return jCreature;  
}

//:: Apply Celestial template to a creature JSON template  
json json_MakeCelestial(json jCreature, int nBaseHD, int nBaseCR)  
{  
    if (jCreature == JsonNull())  
        return JsonNull();  
      
    //:: Get current HD for scaling  
    int nHD = json_GetCreatureHD(jCreature);  
    if (nHD <= 0)  
    {  
        DoDebug("prc_inc_json >> json_MakeCelestial: Invalid HD");  
        return JsonNull();  
    }  
	
	//:: Get current CR
	float fCR = json_GetChallengeRating(jCreature);

	//:: Update CR using Celestial formula
	jCreature = json_UpdateCelestialCR(jCreature, FloatToInt(fCR), nHD);	
	if (jCreature == JsonNull())  
    {  
        DoDebug("prc_inc_json >> json_MakeCelestial: json_UpdateCelestialCR failed");  
        return JsonNull();  
    }
    
    //:: Ensure Intelligence is at least 4  
    json jInt = GffGetByte(jCreature, "Int");  
    if (jInt != JsonNull() && JsonGetInt(jInt) < 4)  
    {  
        jCreature = GffReplaceByte(jCreature, "Int", 4);  
    }  
      
    //:: Add celestial Smite Evil
    jCreature = json_AddCelestialPowers(jCreature);  
    if (jCreature == JsonNull())  
    {  
        DoDebug("prc_inc_json >> json_MakeCelestial: json_AddCelestialPowers failed");  
        return JsonNull();  
    }  
      
    //:: Change creature type if animal/beast/vermin to magical beast  
    int nRacialType = JsonGetInt(GffGetByte(jCreature, "Race"));  
    if (nRacialType == RACIAL_TYPE_ANIMAL || nRacialType == RACIAL_TYPE_VERMIN || nRacialType == RACIAL_TYPE_BEAST)  
    {  
        jCreature = json_ModifyRacialType(jCreature, RACIAL_TYPE_MAGICAL_BEAST);  
    }  
     
	//:: Update creature CR
	jCreature = json_UpdateCelestialCR(jCreature, nBaseCR, nHD);  
    if (jCreature == JsonNull())  
    {  
        DoDebug("prc_inc_json >> json_MakeCelestial: json_UpdateCelestialCR failed");  
        return JsonNull();  
    }
	 
    return jCreature;  
}  
 
//:: Spawns a Celestial Companion from a template  
object MakeCelestialCompanionFromTemplate(string sResref, location lSpawnLoc, int nHealerLvl)  
{  
	int nBonus = GetHealerCompanionBonus(nHealerLvl);
	
	json jCelestial = TemplateToJson(sResref, RESTYPE_UTC);  
	if (jCelestial == JSON_NULL)  
    {  
        DoDebug("prc_inc_json >> MakeCelestialCompanionFromTemplate: TemplateToJson failed — bad resref or resource missing.");  
        return OBJECT_INVALID;  
    }  	  
	  
	//:: Get local vars to transfer over.  
	int iMinHD 			= json_GetLocalIntFromVarTable(jCelestial, "iMinHD");  
	int iMaxHD 			= json_GetLocalIntFromVarTable(jCelestial, "iMaxHD");  
	int nOriginalHD 	= json_GetLocalIntFromVarTable(jCelestial, "nOriginalHD");  
	int iClass2			= json_GetLocalIntFromVarTable(jCelestial, "Class2");  
	int iClass2Package	= json_GetLocalIntFromVarTable(jCelestial, "Class2Package");  
	int iClass2Start	= json_GetLocalIntFromVarTable(jCelestial, "Class2Start"); 
	int iBaseCL			= json_GetLocalIntFromVarTable(jCelestial, "iBaseCL");	
	int iMagicUse		= json_GetLocalIntFromVarTable(jCelestial, "X2_L_BEH_MAGIC");  
	string sAI			= json_GetLocalStringFromVarTable(jCelestial, "X2_SPECIAL_COMBAT_AI_SCRIPT");  
		  
	//:: Get the original Challenge Rating
	int nBaseCR = FloatToInt(json_GetChallengeRating(jCelestial));
		  
	//:: Apply celestial template modifications  
	jCelestial = json_MakeCelestial(jCelestial, nBonus, nBaseCR);  
	if (jCelestial == JSON_NULL)  
    {  
        DoDebug("prc_inc_json >> MakeCelestialCompanionFromTemplate failed — json_MakeCelestial returned invalid JSON.");  
        return OBJECT_INVALID;  
    }  

	//:: Apply +2 Natural AC bonus per 3 Healer levels 	  
	jCelestial = json_IncreaseBaseAC(jCelestial, nBonus);
	if (jCelestial == JSON_NULL)  
    {  
        DoDebug("prc_inc_json >> MakeCelestialCompanionFromTemplate failed — json_IncreaseBaseAC returned invalid JSON.");  
        return OBJECT_INVALID;  
    }
	
	//:: +2 STR, DEX & INT per 3 Healer levels
	jCelestial = json_UpdateTemplateStats(jCelestial, nBonus, nBonus, 0, nBonus, 0, 0);
	if (jCelestial == JSON_NULL)  
    {  
        DoDebug("prc_inc_json >> MakeCelestialCompanionFromTemplate failed — json_UpdateTemplateStats returned invalid JSON.");  
        return OBJECT_INVALID;  
    }	
	
	//:: The Companion always has Improved Evasion if the healer qualifies, 
	//:: but adding it this way gives the base creature more utility for builders.
	if (nHealerLvl > 7)
	{
		//:: Add Improved Evasion feat directly to FeatList 
		json jFeatList = GffGetList(jCelestial, "FeatList");  
		if (jFeatList == JsonNull())  
			jFeatList = JsonArray();  
		  
		//:: Check if creature already has Improved Evasion  
		int bHasFeat = FALSE;  
		int nFeatCount = JsonGetLength(jFeatList);  
		int j;  
		  
		for (j = 0; j < nFeatCount; j++)  
		{  
			json jFeatStruct = JsonArrayGet(jFeatList, j);  
			if (jFeatStruct != JsonNull())  
			{  
				json jFeatValue = GffGetWord(jFeatStruct, "Feat");  
				if (jFeatValue != JsonNull() && JsonGetInt(jFeatValue) == FEAT_IMPROVED_EVASION)  
				{  
					bHasFeat = TRUE;  
					break;  
				}  
			}  
		}  
		  
		//:: Add feat only if not already present  
		if (!bHasFeat)  
		{  
			json jNewFeat = JsonObject();  
			jNewFeat = JsonObjectSet(jNewFeat, "__struct_id", JsonInt(1));  
			jNewFeat = GffAddWord(jNewFeat, "Feat", FEAT_IMPROVED_EVASION);  
			  
			jFeatList = JsonArrayInsert(jFeatList, jNewFeat);  
			jCelestial = GffReplaceList(jCelestial, "FeatList", jFeatList);  
		}
	}		
	
	//:: Spawn the creature  
	object oCelestial = JsonToObject(jCelestial, lSpawnLoc);  
	  
	//:: Set variables for LevelUpSummon()
	SetLocalInt(oCelestial, "TEMPLATE_CELESTIAL", 1);	  
	SetLocalInt(oCelestial, "iMinHD", iMinHD);		  
	SetLocalInt(oCelestial, "iMaxHD", iMaxHD);  
	SetLocalInt(oCelestial, "nOriginalHD", nOriginalHD);	  
	SetLocalInt(oCelestial, "Class2", iClass2);  
	SetLocalInt(oCelestial, "Class2Package", iClass2Package);  
	SetLocalInt(oCelestial, "Class2Start", iClass2Start);  
	SetLocalInt(oCelestial, "iBaseCL", iBaseCL); 
	SetLocalInt(oCelestial, "X2_L_BEH_MAGIC", iMagicUse);	
	SetLocalString(oCelestial, "X2_SPECIAL_COMBAT_AI_SCRIPT", sAI);
	
	return oCelestial;
}
 
//:: Spawns a Celestial creature from a template  
object MakeCelestialCreatureFromTemplate(string sResref, location lSpawnLoc)  
{  
	json jCelestial = TemplateToJson(sResref, RESTYPE_UTC);  
	if (jCelestial == JSON_NULL)  
    {  
        DoDebug("prc_inc_json >> MakeCelestialCreatureFromTemplate: TemplateToJson failed — bad resref or resource missing.");  
        return OBJECT_INVALID;  
    }  
	  
    //:: Get current HD  
    int nCurrentHD = json_GetCreatureHD(jCelestial);  
    if (nCurrentHD <= 0)  
    {  
        DoDebug("make_celestial >> MakeCelestialCreatureFromTemplate failed — template missing HD data.");  
        return OBJECT_INVALID;  
    }	  
	  
    //:: Get current CR  
	int nBaseCR = 1;  
    nBaseCR = FloatToInt(json_GetChallengeRating(jCelestial));  
    if (nBaseCR <= 0)  
    {  
        DoDebug("make_celestial >> MakeCelestialCreatureFromTemplate failed — template missing CR data.");  
        return OBJECT_INVALID;  
    }	  
	  
	//:: Get local vars to transfer over.  
	int iMinHD 			= json_GetLocalIntFromVarTable(jCelestial, "iMinHD");  
	int iMaxHD 			= json_GetLocalIntFromVarTable(jCelestial, "iMaxHD");  
	int nOriginalHD 	= json_GetLocalIntFromVarTable(jCelestial, "nOriginalHD");  
	int iClass2			= json_GetLocalIntFromVarTable(jCelestial, "Class2");  
	int iClass2Package	= json_GetLocalIntFromVarTable(jCelestial, "Class2Package");  
	int iClass2Start	= json_GetLocalIntFromVarTable(jCelestial, "Class2Start"); 
	int iBaseCL			= json_GetLocalIntFromVarTable(jCelestial, "iBaseCL");	
	int iMagicUse		= json_GetLocalIntFromVarTable(jCelestial, "X2_L_BEH_MAGIC");  
	string sAI			= json_GetLocalStringFromVarTable(jCelestial, "X2_SPECIAL_COMBAT_AI_SCRIPT");  
		  
	//:: Apply celestial template modifications  
	jCelestial = json_MakeCelestial(jCelestial, nCurrentHD, nBaseCR);  
	if (jCelestial == JSON_NULL)  
    {  
        DoDebug("make_celestial >> MakeCelestialCreatureFromTemplate failed — MakeCelestial returned invalid JSON.");  
        return OBJECT_INVALID;  
    }  
	  
	//:: Spawn the creature  
    object oCelestial = JsonToObject(jCelestial, lSpawnLoc);  
	  
	//:: Set variables	  
	SetLocalInt(oCelestial, "TEMPLATE_CELESTIAL", 1);	  
	SetLocalInt(oCelestial, "iMinHD", iMinHD);		  
	SetLocalInt(oCelestial, "iMaxHD", iMaxHD);  
	SetLocalInt(oCelestial, "nOriginalHD", nOriginalHD);	  
	SetLocalInt(oCelestial, "Class2", iClass2);  
	SetLocalInt(oCelestial, "Class2Package", iClass2Package);  
	SetLocalInt(oCelestial, "Class2Start", iClass2Start);  
	SetLocalInt(oCelestial, "Class2Start", iClass2Start);
	SetLocalInt(oCelestial, "iBaseCL", iBaseCL); 	
	SetLocalInt(oCelestial, "X2_L_BEH_MAGIC", iMagicUse);  
	SetLocalString(oCelestial, "X2_SPECIAL_COMBAT_AI_SCRIPT", sAI);	  
  
	return oCelestial;  
}  
  
//:: Adds Paragon SLA's to jCreature.
//::
json json_AddParagonPowers(json jCreature)
{
    // Get the existing SpecAbilityList (if it exists)
    json jSpecAbilityList = GffGetList(jCreature, "SpecAbilityList");

    // Create the SpecAbilityList if it doesn't exist
    if (jSpecAbilityList == JsonNull())
    {
        jSpecAbilityList = JsonArray();
    }
    
//:: Greater Dispelling 3x / Day
	int i;
    for (i = 0; i < 3; i++)
    {
        json jSpecAbility = JsonObject();
        jSpecAbility = GffAddWord(jSpecAbility, "Spell", 67);
        jSpecAbility = GffAddByte(jSpecAbility, "SpellCasterLevel", 15);
        jSpecAbility = GffAddByte(jSpecAbility, "SpellFlags", 1);

        // Manually add to the array
        jSpecAbilityList = JsonArrayInsert(jSpecAbilityList, jSpecAbility);
    }

//:: Add Haste 3x / Day
    for (i = 0; i < 3; i++)
    {
        json jSpecAbility = JsonObject();
        jSpecAbility = GffAddWord(jSpecAbility, "Spell", 78);
        jSpecAbility = GffAddByte(jSpecAbility, "SpellCasterLevel", 15);
        jSpecAbility = GffAddByte(jSpecAbility, "SpellFlags", 1);
        
        // Manually add to the array
        jSpecAbilityList = JsonArrayInsert(jSpecAbilityList, jSpecAbility);
    }

//:: See Invisiblity 3x / Day
    for (i = 0; i < 3; i++)
    {
        json jSpecAbility = JsonObject();
        jSpecAbility = GffAddWord(jSpecAbility, "Spell", 157);
        jSpecAbility = GffAddByte(jSpecAbility, "SpellCasterLevel", 15);
        jSpecAbility = GffAddByte(jSpecAbility, "SpellFlags", 1);

        // Manually add to the array
        jSpecAbilityList = JsonArrayInsert(jSpecAbilityList, jSpecAbility);
    }

//:: Add the list to the creature
    jCreature = GffAddList(jCreature, "SpecAbilityList", jSpecAbilityList);
	
	return jCreature;
}

//:: Directly modifies jCreature's Challenge Rating.
//:: This is useful for most XP calculations.
//::
json json_UpdateParagonCR(json jCreature, int nBaseCR, int nBaseHD)
{
	int nNewCR;
	
//:: Calculate additional CR by HD
	if(nBaseHD <= 6)
	{
		nNewCR = nBaseCR + 18;
	}	
	else if(nBaseHD <= 16) 
	{
		nNewCR = nBaseCR + 15;
	}	
	else
		{nNewCR = nBaseCR + 12;}
	
//:: Modify Challenge Rating
	jCreature = GffReplaceFloat(jCreature, "ChallengeRating"/* /value" */, IntToFloat(nNewCR));
	
	return jCreature;
}

//:: Adds Psuedonatural SLA's to jCreature.
//::
json json_AddPsuedonaturalPowers(json jCreature)
{
    // Get the existing SpecAbilityList (if it exists)
    json jSpecAbilityList = GffGetList(jCreature, "SpecAbilityList");

    // Create the SpecAbilityList if it doesn't exist
    if (jSpecAbilityList == JsonNull())
    {
        jSpecAbilityList = JsonArray();
    }
    
//:: True Strike 1x / Day
	int i;
    for (i = 0; i < 1; i++)
    {
        json jSpecAbility = JsonObject();
        jSpecAbility = GffAddWord(jSpecAbility, "Spell", 415);
        jSpecAbility = GffAddByte(jSpecAbility, "SpellCasterLevel", 15);
        jSpecAbility = GffAddByte(jSpecAbility, "SpellFlags", 1);

        // Manually add to the array
        jSpecAbilityList = JsonArrayInsert(jSpecAbilityList, jSpecAbility);
    }

//:: Add the list to the creature
    jCreature = GffAddList(jCreature, "SpecAbilityList", jSpecAbilityList);
	
	return jCreature;
}

//:: Directly modifies jCreature's Challenge Rating.
//:: This is useful for most XP calculations.
//::
json json_UpdatePsuedonaturalCR(json jCreature, int nBaseCR, int nBaseHD)
{
	int nNewCR;
	
//:: Calculate additional CR by HD
    if (nBaseHD >= 4 && nBaseHD <= 11)
    {
        nNewCR = nBaseCR + 1;
    }
    else if (nBaseHD >= 12)
    {
        nNewCR = nBaseCR + 2;
    }	
	
//:: Modify Challenge Rating
	jCreature = GffReplaceFloat(jCreature, "ChallengeRating"/* /value" */, IntToFloat(nNewCR));
	
	return jCreature;
}


//:: Spawns a Psuedonatural creature from a template
object MakePsuedonaturalCreatureFromTemplate(string sResref, location lSpawnLoc)
{
	json jPsuedo = TemplateToJson(sResref, RESTYPE_UTC);
	if (jPsuedo == JSON_NULL)
    {
        DoDebug("prc_inc_json >> SpawnPsuedonaturalCreatureFromTemplate: TemplateToJson failed — bad resref or resource missing.");
        return OBJECT_INVALID;
    }
	
    //:: Get current HD
    int nCurrentHD = json_GetCreatureHD(jPsuedo);
    if (nCurrentHD <= 0)
    {
        DoDebug("make_psuedonat >> MakePsuedonaturalCreatureFromTemplate failed — template missing HD data.");
        return OBJECT_INVALID;
    }	
	
    //:: Get current CR
	int nBaseCR = 1;
    nBaseCR = json_GetCreatureHD(jPsuedo);
    if (nBaseCR <= 0)
    {
        DoDebug("make_psuedonat >> MakePsuedonaturalCreatureFromTemplate failed — template missing CR data.");
        return OBJECT_INVALID;
    }	
	
	//:: Get local vars to transfer over.
	int iMinHD 			= json_GetLocalIntFromVarTable(jPsuedo, "iMinHD");
	int iMaxHD 			= json_GetLocalIntFromVarTable(jPsuedo, "iMaxHD");
	int nOriginalHD 	= json_GetLocalIntFromVarTable(jPsuedo, "nOriginalHD");
	int iClass2			= json_GetLocalIntFromVarTable(jPsuedo, "Class2");
	int iClass2Package	= json_GetLocalIntFromVarTable(jPsuedo, "Class2Package");
	int iClass2Start	= json_GetLocalIntFromVarTable(jPsuedo, "Class2Start");
	int iMagicUse		= json_GetLocalIntFromVarTable(jPsuedo, "X2_L_BEH_MAGIC");
	string sAI			= json_GetLocalStringFromVarTable(jPsuedo, "X2_SPECIAL_COMBAT_AI_SCRIPT");
		
	//:: Adds True Strike 1x / day to jCreature.
	jPsuedo = json_AddPsuedonaturalPowers(jPsuedo);
	
	//:: Change jCreature's racialtype to outsider
	jPsuedo = json_ModifyRacialType(jPsuedo, RACIAL_TYPE_OUTSIDER);	
	
	jPsuedo = json_UpdatePsuedonaturalCR(jPsuedo, nBaseCR, nCurrentHD);	
	
	//:: Spawn the creature
    object oPsuedo = JsonToObject(jPsuedo, lSpawnLoc);
	
	//:: Set variables	
	SetLocalInt(oPsuedo, "TEMPLATE_PSUEDONATURAL", 1);	
	SetLocalInt(oPsuedo, "iMinHD", iMinHD);		
	SetLocalInt(oPsuedo, "iMaxHD", iMaxHD);
	SetLocalInt(oPsuedo, "nOriginalHD", nOriginalHD);	
	SetLocalInt(oPsuedo, "Class2", iClass2);
	SetLocalInt(oPsuedo, "Class2Package", iClass2Package);
	SetLocalInt(oPsuedo, "Class2Start", iClass2Start);
	SetLocalInt(oPsuedo, "X2_L_BEH_MAGIC", iMagicUse);
	SetLocalString(oPsuedo, "X2_SPECIAL_COMBAT_AI_SCRIPT", sAI);	

	return oPsuedo;
	
}

//:: Test void
//::void main (){}