/*
 * Factotum general functions handling.
 *
 * @author Stratovarius - 2019.12.21
 */

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Stores SpellIds for Arcane Dilettante 
 *
 * @param oPC         PC to target
 * @param nSpell      SpellID to store                     
 */
void PrepareArcDilSpell(object oPC, int nSpell);

/**
 * Returns TRUE if there are more spells to learn
 *
 * @param oPC         PC to target                     
 */
void PrepareArcDilSpell(object oPC, int nSpell);

//////////////////////////////////////////////////
/* Constants                                    */
//////////////////////////////////////////////////

const int FACTOTUM_SLOT_1 = 3887;
const int FACTOTUM_SLOT_2 = 3888;
const int FACTOTUM_SLOT_3 = 3889;
const int FACTOTUM_SLOT_4 = 3890;
const int FACTOTUM_SLOT_5 = 3891;
const int FACTOTUM_SLOT_6 = 3892;
const int FACTOTUM_SLOT_7 = 3893;
const int FACTOTUM_SLOT_8 = 3894;

const int BRILLIANCE_SLOT_1 = 3917;
const int BRILLIANCE_SLOT_2 = 3918;
const int BRILLIANCE_SLOT_3 = 3919;

//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

#include "prc_inc_function"

//////////////////////////////////////////////////
/* Function definitions                         */
//////////////////////////////////////////////////
void TriggerInspiration(object oPC, int nCombat);


void PrepareArcDilSpell(object oPC, int nSpell)
{
	if (DEBUG) DoDebug("PrepareArcDilSpell "+IntToString(nSpell));
	int nClass = GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC);
	
	// Done like this because you can only have a certain amount at a given level
	if (!GetLocalInt(oPC, "ArcDilSpell1") && nClass >= 2) SetLocalInt(oPC, "ArcDilSpell1", nSpell);
	else if (!GetLocalInt(oPC, "ArcDilSpell2") && nClass >= 4) SetLocalInt(oPC, "ArcDilSpell2", nSpell);
	else if (!GetLocalInt(oPC, "ArcDilSpell3") && nClass >= 7) SetLocalInt(oPC, "ArcDilSpell3", nSpell);
	else if (!GetLocalInt(oPC, "ArcDilSpell4") && nClass >= 9) SetLocalInt(oPC, "ArcDilSpell4", nSpell);
	else if (!GetLocalInt(oPC, "ArcDilSpell5") && nClass >= 12) SetLocalInt(oPC, "ArcDilSpell5", nSpell);
	else if (!GetLocalInt(oPC, "ArcDilSpell6") && nClass >= 14) SetLocalInt(oPC, "ArcDilSpell6", nSpell);
	else if (!GetLocalInt(oPC, "ArcDilSpell7") && nClass >= 17) SetLocalInt(oPC, "ArcDilSpell7", nSpell);
	else if (!GetLocalInt(oPC, "ArcDilSpell8") && nClass >= 20) SetLocalInt(oPC, "ArcDilSpell8", nSpell);
}

int GetMaxLearnedArcDil(object oPC)
{
	int nClass = GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC);
	int nCount, nMax;
	if (GetLocalInt(oPC, "ArcDilSpell1")) nCount++;
	if (GetLocalInt(oPC, "ArcDilSpell2")) nCount++;
	if (GetLocalInt(oPC, "ArcDilSpell3")) nCount++;
	if (GetLocalInt(oPC, "ArcDilSpell4")) nCount++;
	if (GetLocalInt(oPC, "ArcDilSpell5")) nCount++;
	if (GetLocalInt(oPC, "ArcDilSpell6")) nCount++;
	if (GetLocalInt(oPC, "ArcDilSpell7")) nCount++;
	if (GetLocalInt(oPC, "ArcDilSpell8")) nCount++;	
	
	if(nClass >= 2) nMax++;
	if(nClass >= 4) nMax++;
	if(nClass >= 7) nMax++;
	if(nClass >= 9) nMax++;
	if(nClass >= 12) nMax++;
	if(nClass >= 14) nMax++;
	if(nClass >= 17) nMax++;
	if(nClass >= 20) nMax++;
	
	int nReturn = FALSE;
	if (nMax > nCount) nReturn = TRUE;
	
	return nReturn;
}

int GetFactotumSlot(object oPC)
{
	int nSlot = PRCGetSpellId();
	if (nSlot == FACTOTUM_SLOT_1) return GetLocalInt(oPC, "ArcDilSpell1");
	if (nSlot == FACTOTUM_SLOT_2) return GetLocalInt(oPC, "ArcDilSpell2");
	if (nSlot == FACTOTUM_SLOT_3) return GetLocalInt(oPC, "ArcDilSpell3");
	if (nSlot == FACTOTUM_SLOT_4) return GetLocalInt(oPC, "ArcDilSpell4");
	if (nSlot == FACTOTUM_SLOT_5) return GetLocalInt(oPC, "ArcDilSpell5");
	if (nSlot == FACTOTUM_SLOT_6) return GetLocalInt(oPC, "ArcDilSpell6");
	if (nSlot == FACTOTUM_SLOT_7) return GetLocalInt(oPC, "ArcDilSpell7");
	if (nSlot == FACTOTUM_SLOT_8) return GetLocalInt(oPC, "ArcDilSpell8");
	
	if (nSlot == BRILLIANCE_SLOT_1) return GetLocalInt(oPC, "CunningAbility1");
	if (nSlot == BRILLIANCE_SLOT_2) return GetLocalInt(oPC, "CunningAbility2");
	if (nSlot == BRILLIANCE_SLOT_3) return GetLocalInt(oPC, "CunningAbility3");	
	
	return -1;
}

void CheckFactotumSlots(object oPC)
{
	int i;
    for (i = 1; i <= 8; i++)
    {
    	string sSpell = "ArcDilSpell";
		int nSpell = GetLocalInt(oPC, sSpell+IntToString(i));
		sSpell = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpell)));
		
		if (nSpell > 0) FloatingTextStringOnCreature("Arcane Dilettante Slot "+IntToString(i)+" is "+sSpell, oPC, FALSE);
    }
}  

void CheckBrillianceSlots(object oPC)
{
	int i;
    for (i = 1; i <= 3; i++)
    {
    	string sSpell = "CunningAbility";
		int nSpell = GetLocalInt(oPC, sSpell+IntToString(i));
		sSpell = GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", nSpell)));
		
		if (nSpell > 0) FloatingTextStringOnCreature("Cunning Brilliance Slot "+IntToString(i)+" is "+sSpell, oPC, FALSE);
    }
} 

void ClearFactotumSlots(object oPC)
{
	int i;
    for (i = 1; i <= 50; i++)
    {
		DeleteLocalInt(oPC, "ArcDilSpell"+IntToString(i));
		DeleteLocalInt(oPC, "CunningKnowledge"+IntToString(i));
		DeleteLocalInt(oPC, "CunningAbility"+IntToString(i));
    }
    DeleteLocalInt(oPC, "CunningBrillianceCount");
    DeleteLocalInt(oPC, "CunningBrilliance");
} 

int GetMaxArcDilSpellLevel(object oPC)
{
	int nClass = GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC);
	int nMax = -1;
	
	if(nClass >= 18) nMax = 7;
	else if(nClass >= 15) nMax = 6;
	else if(nClass >= 13) nMax = 5;
	else if(nClass >= 10) nMax = 4;
	else if(nClass >= 8) nMax = 3;
	else if(nClass >= 5) nMax = 2;
	else if(nClass >= 3) nMax = 1;
	else if(nClass >= 2) nMax = 0;
	
	if (DEBUG) DoDebug("GetMaxArcDilSpellLevel "+IntToString(nMax));
	
	return nMax;
}

void SetInspiration(object oPC)
{
	int nInspiration = 2;
	int nClass = GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC);
	
	if(nClass >= 20) nInspiration = 10;
	else if(nClass >= 17) nInspiration = 8;
	else if(nClass >= 14) nInspiration = 7;
	else if(nClass >= 11) nInspiration = 6;
	else if(nClass >= 8) nInspiration = 5;
	else if(nClass >= 5) nInspiration = 4;
	else if(nClass >= 2) nInspiration = 3;	

    int i, nFont;
    for(i = FEAT_FONT_INSPIRATION_1; i <= FEAT_FONT_INSPIRATION_10; i++)
        if(GetHasFeat(i, oPC)) nFont++;

    //nInspiration += nFont * (1 + nFont + 1) / 2;	
	nInspiration += nFont * (nFont + 1) / 2;
	SetLocalInt(oPC, "InspirationPool", nInspiration);
	FloatingTextStringOnCreature("Encounter begins with "+IntToString(nInspiration)+" inspiration", oPC, FALSE);
}	

void ClearInspiration(object oPC)
{
	DeleteLocalInt(oPC, "InspirationPool");
	FloatingTextStringOnCreature("Encounter ends, inspiration lost", oPC, FALSE);
}	

int ExpendInspiration(object oPC, int nCost)
{
	if (nCost <= 0) return FALSE;
	
	int nInspiration = GetLocalInt(oPC, "InspirationPool");
	if (nInspiration >= nCost)
	{
		SetLocalInt(oPC, "InspirationPool", nInspiration-nCost);
		FloatingTextStringOnCreature("You have "+IntToString(nInspiration-nCost)+" inspiration remaining this encounter", oPC, FALSE);
		return TRUE;
	}

	FloatingTextStringOnCreature("You do not have enough inspiration", oPC, FALSE);
	return FALSE;
}	

void MarkAbilitySaved(object oPC, int nAbil)
{
	if (DEBUG) DoDebug("MarkAbilitySaved nAbil is "+IntToString(nAbil));

	if (!GetLocalInt(oPC, "CunningAbility1")) SetLocalInt(oPC, "CunningAbility1", nAbil);
	else if (!GetLocalInt(oPC, "CunningAbility2")) SetLocalInt(oPC, "CunningAbility2", nAbil);
	else if (!GetLocalInt(oPC, "CunningAbility3")) SetLocalInt(oPC, "CunningAbility3", nAbil);
}

int GetIsAbilitySaved(object oPC, int nAbil)
{
	int i, nCount, nTest;
    for (i = 0; i <= 3; i++)
    {
		nTest = GetLocalInt(oPC, "CunningAbility"+IntToString(i));
		if (nTest == nAbil) 
			nCount = TRUE;	
    }
    if (DEBUG) DoDebug("GetIsAbilitySaved is "+IntToString(nCount));
    return nCount;
}

void FactotumTriggerAbil(object oPC, int nAbil)    
{    
    object oSkin = GetPCSkin(oPC);    
    effect eEffect;    
        
    if (nAbil == FEAT_BARBARIAN_RAGE)    
        ExecuteScript("NW_S1_BarbRage", oPC);    
    else if (nAbil == FEAT_BARBARIAN_ENDURANCE)    
        eEffect = EffectBonusFeat(IP_CONST_FEAT_BarbEndurance);    
    else if (nAbil == FEAT_SNEAK_ATTACK)    
    {    
        SetLocalInt(oPC, "FactotumSneak", TRUE);    
        DelayCommand(0.1, ExecuteScript("prc_sneak_att", oPC));       
        DelayCommand(59.9, DeleteLocalInt(oPC, "FactotumSneak"));    
        DelayCommand(60.0, ExecuteScript("prc_sneak_att", oPC));            
    }    
    else if (nAbil == FEAT_METTLE) // Mettle    
    {    
        eEffect = EffectBonusFeat(FEAT_METTLE);
		/* SetLocalInt(oPC, "FactotumMettle", TRUE);    
        DelayCommand(60.0, DeleteLocalInt(oPC, "FactotumMettle")); */    
    }    
    else if (nAbil == FEAT_CRUSADER_SMITE)   
    {          
        eEffect = EffectBonusFeat(FEAT_CRUSADER_SMITE);  
    }          
    else if (nAbil == FEAT_CLOAKED_CASTING)    
    {    
        eEffect = EffectBonusFeat(FEAT_CLOAKED_CASTING);   
    }    
    else if (nAbil == FEAT_DRAGONSHAMAN_RESOLVE)      
    {      
        // Draconic Resolve - immunity to sleep, paralysis, fear      
        eEffect = EffectImmunity(IMMUNITY_TYPE_PARALYSIS);    
        eEffect = EffectLinkEffects(eEffect, EffectImmunity(IMMUNITY_TYPE_SLEEP));    
        eEffect = EffectLinkEffects(eEffect, EffectImmunity(IMMUNITY_TYPE_FEAR));            
    }   
    // Favored Enemy feats  
    else if (nAbil == FEAT_FAVORED_ENEMY_ABERRATION)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_ABERRATION);  
    else if (nAbil == FEAT_FAVORED_ENEMY_ANIMAL)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_ANIMAL);  
    else if (nAbil == FEAT_FAVORED_ENEMY_BEAST)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_BEAST);  
    else if (nAbil == FEAT_FAVORED_ENEMY_CONSTRUCT)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_CONSTRUCT);  
    else if (nAbil == FEAT_FAVORED_ENEMY_DRAGON)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_DRAGON);  
    else if (nAbil == FEAT_FAVORED_ENEMY_DWARF)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_DWARF);  
    else if (nAbil == FEAT_FAVORED_ENEMY_ELEMENTAL)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_ELEMENTAL);  
    else if (nAbil == FEAT_FAVORED_ENEMY_ELF)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_ELF);  
    else if (nAbil == FEAT_FAVORED_ENEMY_FEY)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_FEY);  
    else if (nAbil == FEAT_FAVORED_ENEMY_GIANT)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_GIANT);  
    else if (nAbil == FEAT_FAVORED_ENEMY_GNOME)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_GNOME);  
    else if (nAbil == FEAT_FAVORED_ENEMY_GOBLINOID)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_GOBLINOID);  
    else if (nAbil == FEAT_FAVORED_ENEMY_HALFELF)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_HALFELF);  
    else if (nAbil == FEAT_FAVORED_ENEMY_HALFLING)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_HALFLING);  
    else if (nAbil == FEAT_FAVORED_ENEMY_HALFORC)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_HALFORC);  
    else if (nAbil == FEAT_FAVORED_ENEMY_HUMAN)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_HUMAN);  
    else if (nAbil == FEAT_FAVORED_ENEMY_MAGICAL_BEAST)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_MAGICAL_BEAST);  
    else if (nAbil == FEAT_FAVORED_ENEMY_MONSTROUS)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_MONSTROUS);  
    else if (nAbil == FEAT_FAVORED_ENEMY_ORC)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_ORC);  
    else if (nAbil == FEAT_FAVORED_ENEMY_OOZE)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_OOZE);  
    else if (nAbil == FEAT_FAVORED_ENEMY_OUTSIDER)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_OUTSIDER);  
    else if (nAbil == FEAT_FAVORED_ENEMY_PLANT)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_PLANT);  
    else if (nAbil == FEAT_FAVORED_ENEMY_REPTILIAN)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_REPTILIAN);  
    else if (nAbil == FEAT_FAVORED_ENEMY_SHAPECHANGER)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_SHAPECHANGER);  
    else if (nAbil == FEAT_FAVORED_ENEMY_UNDEAD)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_UNDEAD);  
    else if (nAbil == FEAT_FAVORED_ENEMY_VERMIN)  
        eEffect = EffectBonusFeat(FEAT_FAVORED_ENEMY_VERMIN);  
    // Other existing abilities  
    else if (nAbil == FEAT_NATURE_SENSE)    
    {  
        eEffect = EffectBonusFeat(FEAT_NATURE_SENSE);    
    }  
    else if (nAbil == FEAT_WOODLAND_STRIDE)    
    {  
        eEffect = EffectBonusFeat(FEAT_WOODLAND_STRIDE);   
    }          
    else if (nAbil == FEAT_TRACKLESS_STEP)    
    {  
        eEffect = EffectBonusFeat(FEAT_TRACKLESS_STEP);    
    }  
    else if (nAbil == FEAT_RESIST_NATURES_LURE)   
    {          
        eEffect = EffectBonusFeat(FEAT_RESIST_NATURES_LURE);    
    }  
    else if (nAbil == FEAT_VENOM_IMMUNITY)    
    {    
        effect eImmunity = EffectImmunity(IMMUNITY_TYPE_POISON);    
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImmunity, oPC, 60.0);    
    }    
    else if (nAbil == FEAT_EVASION)    
    {    
        eEffect = EffectBonusFeat(FEAT_EVASION);   
    }    
    else if (nAbil == FEAT_STILL_MIND)    
    {  
        eEffect = EffectBonusFeat(FEAT_STILL_MIND);   
    }          
    else if (nAbil == FEAT_PURITY_OF_BODY)    
    {    
        // Purity of Body - disease immunity    
        effect eImmunity = EffectImmunity(IMMUNITY_TYPE_DISEASE);    
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImmunity, oPC, 60.0);    
    }    
    else if (nAbil == FEAT_IMPROVED_EVASION)    
    {    
        eEffect = EffectBonusFeat(FEAT_IMPROVED_EVASION);     
    }    
    else if (nAbil == FEAT_USE_POISON)    
    {  
        eEffect = EffectBonusFeat(FEAT_USE_POISON);    
    }  
    else if (nAbil == FEAT_DIVINE_HEALTH)    
    {    
        // Divine Health - disease immunity    
        effect eImmunity = EffectImmunity(IMMUNITY_TYPE_DISEASE);    
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImmunity, oPC, 60.0);    
    }    
    else if (nAbil == FEAT_CRIPPLING_STRIKE)    
    {    
        eEffect = EffectBonusFeat(FEAT_CRIPPLING_STRIKE);    
    }    
    else if (nAbil == FEAT_DEFENSIVE_ROLL)    
    {    
        eEffect = EffectBonusFeat(FEAT_DEFENSIVE_ROLL);   
    }    
    else if (nAbil == FEAT_OPPORTUNIST)    
    {    
        eEffect = EffectBonusFeat(FEAT_OPPORTUNIST);     
    }    
    else if (nAbil == FEAT_SLIPPERY_MIND)    
    {  
        eEffect = EffectBonusFeat(FEAT_SLIPPERY_MIND);   
    }
	
	eEffect = TagEffect(eEffect, "FactotumCunningBrilliance");  
	eEffect = ExtraordinaryEffect(eEffect);  
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oPC, 60.0);
	
}  


/* void FactotumTriggerAbil(object oPC, int nAbil)
{
	object oSkin = GetPCSkin(oPC);
	itemproperty ipIP;
	if (nAbil == FEAT_BARBARIAN_RAGE)
		ExecuteScript("NW_S1_BarbRage", oPC);
	else if (nAbil == FEAT_BARBARIAN_ENDURANCE)
    	ipIP = PRCItemPropertyBonusFeat(IP_CONST_FEAT_BarbEndurance);
    else if (nAbil == FEAT_SNEAK_ATTACK)
    {
    	SetLocalInt(oPC, "FactotumSneak", TRUE);
    	DelayCommand(0.1, ExecuteScript("prc_sneak_att", oPC));   
		DelayCommand(59.9, DeleteLocalInt(oPC, "FactotumSneak"));
    	DelayCommand(60.0, ExecuteScript("prc_sneak_att", oPC));    	
    }
    else if (nAbil == 3665) // Mettle
    {
    	SetLocalInt(oPC, "FactotumMettle", TRUE);
    	DelayCommand(60.0, DeleteLocalInt(oPC, "FactotumMettle"));
    }
	else if (nAbil == FEAT_CRUSADER_SMITE)
    	ipIP = PRCItemPropertyBonusFeat(IP_CONST_FEAT_CRUSADER_SMITE);
    	
    IPSafeAddItemProperty(oSkin, ipIP, 60.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE); 	
} */

void TriggerInspiration(object oPC, int nCombat)
{
	SetLocalInt(oPC, "InspirationHBRunning", TRUE);
	DelayCommand(0.249, DeleteLocalInt(oPC, "InspirationHBRunning"));
	int nCurrent = GetIsInCombat(oPC);
	// We just entered combat
	if (nCurrent == TRUE && nCombat == FALSE)
		SetInspiration(oPC);
	else if (nCurrent == FALSE && nCombat == TRUE) // Just left combat
		ClearInspiration(oPC);
 
    DelayCommand(0.25, TriggerInspiration(oPC, nCurrent));
}


/*void AddCunningBrillianceAbility(object oPC, int nAbil)
{
	if (DEBUG) DoDebug("AddCunningBrillianceAbility "+IntToString(nAbil));
	
	object oSkin = GetPCSkin(oPC);
	itemproperty ipIP;

	if (nAbil == FEAT_BARBARIAN_ENDURANCE)
    	ipIP = PRCItemPropertyBonusFeat(IP_CONST_FEAT_BarbEndurance);
 	else if (nAbil == FEAT_BARBARIAN_RAGE)
    	ipIP = PRCItemPropertyBonusFeat(IP_CONST_FEAT_RAGE);   
    
    IPSafeAddItemProperty(oSkin, ipIP, 9999.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE); 
    MarkAbilitySaved(oPC, nAbil);
}
*/
