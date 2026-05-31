//::///////////////////////////////////////////////
//:: Astral Construct conversation include
//:: psi_inc_ac_convo
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 25.01.2005
//:://////////////////////////////////////////////

#include "psi_inc_ac_const"
#include "prc_feat_const"

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////


int GetNumberOfFlagsRaised(int nFlagSet);
int GetTotalNumberOfSlotsUsed(object oPC);
int GetMaxFlagsForLevel(int nLevel);
int GetHasBuff(int nFlags);

// Custom token stuff
string GetSizeAsString(int nLevel);
string GetHPAsString(int nLevel, int nFlags);
string GetSpeedAsString(int nLevel, int nFlags);
string StringAdder(string sOriginal, string sAdd, int bFirst);
string GetMenuASelectionsAsString(object oPC);
string GetMenuBSelectionsAsString(object oPC);
string GetMenuCSelectionsAsString(object oPC);



//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////


int GetNumberOfFlagsRaised(int nFlagSet)
{
	int i, nReturn = 0;
	
	for(i = 0; i < 32; i++)
	{
		if((nFlagSet >>> i) & TEST_FLAG)
			nReturn++;
	}
	
	return nReturn;
}



int GetTotalNumberOfSlotsUsed(object oPC)
{
    int nFlags = GetLocalInt(oPC, ASTRAL_CONSTRUCT_OPTION_FLAGS + EDIT);

    int nFlagTotal  = 0;
    
    // Handle Menu A flags. Each flag costs 1 slot
    nFlagTotal += MENU_A_COST * GetNumberOfFlagsRaised(nFlags & MENU_A_MASK);
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_RESISTANCE)
    {
        nFlagTotal -= MENU_A_COST; //We don't want to count the flag twice
        nFlagTotal += MENU_A_COST * GetNumberOfFlagsRaised(GetLocalInt(oPC, ASTRAL_CONSTRUCT_RESISTANCE_FLAGS + EDIT));
    }
    
    // Handle Menu B flags. Each flag costs 2 slots
    nFlagTotal += MENU_B_COST * GetNumberOfFlagsRaised(nFlags & MENU_B_MASK);
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_ENERGY_TOUCH)
    {
        nFlagTotal -= MENU_B_COST; //We don't want to count the flag twice
        nFlagTotal += MENU_B_COST * GetNumberOfFlagsRaised(GetLocalInt(oPC, ASTRAL_CONSTRUCT_ENERGY_TOUCH_FLAGS + EDIT));
    }
    
    // Handle Menu C flags. Each flag costs 4 slots
    nFlagTotal += MENU_C_COST * GetNumberOfFlagsRaised(nFlags & MENU_C_MASK);


    return nFlagTotal;
}


int GetMaxSlotsForLevel(int nLevel, object oManifester)
{
	int multiplier = 1;

	if (GetHasFeat(FEAT_BOOST_CONSTRUCT, oManifester))
	{
		multiplier = 2;
	}

	switch(nLevel)
	{
		case 1: case 2: case 3:
			return 1 * multiplier;
		case 4: case 5: case 6:
			return 2 * multiplier;
		case 7: case 8: case 9:
			return 4 * multiplier;

		default:
			WriteTimestampedLogEntry("Invalid nLevel value passed to GetMaxFlagsForLevel");
	}
	
	return 0;
}



int GetHasBuff(int nFlags)
{
	if((nFlags & ASTRAL_CONSTRUCT_OPTION_BUFF) ||
	   (nFlags & ASTRAL_CONSTRUCT_OPTION_IMP_BUFF) ||
	   (nFlags & ASTRAL_CONSTRUCT_OPTION_EXTRA_BUFF))
		return TRUE;
	else
		return FALSE;
}


string GetSizeAsString(int nLevel)
{
	switch(nLevel)
	{
		case 1:
			return "Small";
		case 2: case 3: case 4:
			return "Medium";
		case 5: case 6: case 7: case 8:
			return "Large";
		case 9:
			return "Huge";
		
		default:
			WriteTimestampedLogEntry("Invalid nLevel value passed to GetSizeAsString");
	}
	
	return "ERROR!";
}


string GetHPAsString(int nLevel, int nFlags)
{
	int nBaseHP;
	
	switch(nLevel)
	{
		case 1: nBaseHP = 15; break;
		case 2: nBaseHP = 31; break;
		case 3: nBaseHP = 36; break;
		case 4: nBaseHP = 47; break;
		case 5: nBaseHP = 68; break;
		case 6: nBaseHP = 85; break;
		case 7: nBaseHP = 101; break;
		case 8: nBaseHP = 118; break;
		case 9: nBaseHP = 144; break;
		
		default:
			WriteTimestampedLogEntry("Invalid nLevel value passed to GetHPAsString");
			return "ERROR!";
	}
	
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_BUFF)
		nBaseHP += 5;
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_IMP_BUFF)
		nBaseHP += 15;
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTRA_BUFF)
		nBaseHP += 30;
	
	return IntToString(nBaseHP);
}


string GetSpeedAsString(int nLevel, int nFlags)
{
	int nSpeed;
	switch(nLevel)
	{
		case 1:
			nSpeed = 30;
			break;
		case 2: case 3: case 4:
		case 5: case 6: case 7: case 8:
			nSpeed = 40;
			break;
		case 9:
			nSpeed = 50;
			break;
		
		default:
			WriteTimestampedLogEntry("Invalid nLevel value passed to GetSizeAsString");
			return "ERROR!";
	}
	
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_CELERITY)
		nSpeed += 10;
	
	return IntToString(nSpeed);
}


string StringAdder(string sOriginal, string sAdd, int bFirst)
{
	if(bFirst) return sOriginal + sAdd;
	else       return sOriginal + ", " + sAdd;
}


string GetMenuASelectionsAsString(object oPC)
{
	string sReturn = "";
	int bFirst = TRUE;
	
	int nFlags = GetLocalInt(oPC, ASTRAL_CONSTRUCT_OPTION_FLAGS + EDIT);
	
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_BUFF){
	sReturn = StringAdder(sReturn, "Buff", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_CELERITY){
	sReturn = StringAdder(sReturn, "Celerity", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_CLEAVE){
	sReturn = StringAdder(sReturn, "Cleave", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_IMPROVED_SLAM){
	sReturn = StringAdder(sReturn, "Improved Slam Attack", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_DEFLECTION){
	sReturn = StringAdder(sReturn, "Deflection", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_MOBILITY){
	sReturn = StringAdder(sReturn, "Mobility", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_POWER_ATTACK){
	sReturn = StringAdder(sReturn, "Power Attack", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_RESISTANCE){
		int nElemFlags = GetLocalInt(oPC, ASTRAL_CONSTRUCT_RESISTANCE_FLAGS + EDIT);
		
		if(nElemFlags & ELEMENT_ACID){
		sReturn = StringAdder(sReturn, "Resistance - Acid", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_COLD){
		sReturn = StringAdder(sReturn, "Resistance - Cold", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_ELECTRICITY){
		sReturn = StringAdder(sReturn, "Resistance - Electricity", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_FIRE){
		sReturn = StringAdder(sReturn, "Resistance - Fire", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_SONIC){
		sReturn = StringAdder(sReturn, "Resistance - Sonic", bFirst);
			bFirst = FALSE;
		}
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_KNOCKDOWN){
	sReturn = StringAdder(sReturn, "Knockdown", bFirst);
		bFirst = FALSE;
	}
	
	return sReturn;
}


string GetMenuBSelectionsAsString(object oPC)
{
	string sReturn = "";
	int bFirst = TRUE;
	
	int nFlags = GetLocalInt(oPC, ASTRAL_CONSTRUCT_OPTION_FLAGS + EDIT);
	
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_ENERGY_TOUCH){
		int nElemFlags = GetLocalInt(oPC, ASTRAL_CONSTRUCT_ENERGY_TOUCH_FLAGS + EDIT);
		
		if(nElemFlags & ELEMENT_ACID){
		sReturn = StringAdder(sReturn, "Energy Touch - Acid", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_COLD){
		sReturn = StringAdder(sReturn, "Energy Touch - Cold", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_ELECTRICITY){
		sReturn = StringAdder(sReturn, "Energy Touch - Electricity", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_FIRE){
		sReturn = StringAdder(sReturn, "Energy Touch - Fire", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_SONIC){
		sReturn = StringAdder(sReturn, "Energy Touch - Sonic", bFirst);
			bFirst = FALSE;
		}
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTRA_ATTACK){
	sReturn = StringAdder(sReturn, "Extra Attack", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_FAST_HEALING){
	sReturn = StringAdder(sReturn, "Fast Healing", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_HEAVY_DEFLECT){
	sReturn = StringAdder(sReturn, "Heavy Deflection", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_IMP_BUFF){
	sReturn = StringAdder(sReturn, "Improved Buff", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_IMP_CRIT){
	sReturn = StringAdder(sReturn, "Improved Critical", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_IMP_DAM_RED){
	sReturn = StringAdder(sReturn, "Improved Damage Reduction", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_MUSCLE){
	sReturn = StringAdder(sReturn, "Muscle", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_POISON_TOUCH){
	sReturn = StringAdder(sReturn, "Poison Touch", bFirst);
		bFirst = FALSE;
	}
	
	
	return sReturn;
}


string GetMenuCSelectionsAsString(object oPC)
{
	string sReturn = "";
	int bFirst = TRUE;
	
	int nFlags = GetLocalInt(oPC, ASTRAL_CONSTRUCT_OPTION_FLAGS + EDIT);
	
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_BLINDFIGHT){
	sReturn = StringAdder(sReturn, "Blindfight", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_CONCUSSION){
	sReturn = StringAdder(sReturn, "Concussion", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_DIMENSION_SLIDE){
	sReturn = StringAdder(sReturn, "Dimension Slide", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_ENERGY_BOLT){
		int nElemFlags = GetLocalInt(oPC, ASTRAL_CONSTRUCT_ENERGY_BOLT_FLAGS + EDIT);
		
		if(nElemFlags & ELEMENT_ACID){
		sReturn = StringAdder(sReturn, "Energy Bolt - Acid", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_COLD){
		sReturn = StringAdder(sReturn, "Energy Bolt - Cold", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_ELECTRICITY){
		sReturn = StringAdder(sReturn, "Energy Bolt - Electricity", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_FIRE){
		sReturn = StringAdder(sReturn, "Energy Bolt - Fire", bFirst);
			bFirst = FALSE;
		}
		if(nElemFlags & ELEMENT_SONIC){
		sReturn = StringAdder(sReturn, "Energy Bolt - Sonic", bFirst);
			bFirst = FALSE;
		}
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTRA_BUFF){
	sReturn = StringAdder(sReturn, "Extra Buff", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTREME_DAM_RED){
	sReturn = StringAdder(sReturn, "Extreme Damage Reduction", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTREME_DEFLECT){
	sReturn = StringAdder(sReturn, "Extreme Deflection", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_NATURAL_INVIS){
	sReturn = StringAdder(sReturn, "Natural Invisibility", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_POWER_RESIST){
	sReturn = StringAdder(sReturn, "Power Resistance", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_REND){
	sReturn = StringAdder(sReturn, "Rend", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_SPRING_ATTACK){
	sReturn = StringAdder(sReturn, "Spring Attack", bFirst);
		bFirst = FALSE;
	}
	if(nFlags & ASTRAL_CONSTRUCT_OPTION_WHIRLWIND){
	sReturn = StringAdder(sReturn, "Whirlwind", bFirst);
		bFirst = FALSE;
	}
	
	return sReturn;
}