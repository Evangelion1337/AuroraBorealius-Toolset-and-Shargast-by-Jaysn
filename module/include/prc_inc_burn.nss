/* 	For burning spells to use in abilities  */

#include "prc_inc_spells"
#include "prc_getbest_inc"

//////////////////////////////////////////////////
/* Function Prototypes                          */
//////////////////////////////////////////////////

// Burns a spell of the selected spell level
// Spell level picked by prc_burnselect.nss
// 
// Returns FALSE if it failed, or the spell level if it worked
int BurnSpell(object oPC);

// Burns a spell of the highest spell level the character has
// 
// Returns FALSE if it failed, or the spell if it worked
int BurnBestSpell(object oPC);

int BurnSpell(object oPC)
{
    int nSpellLevel = GetLocalInt(oPC, "BurnSpellLevel");
    int nSpell;
    if (nSpellLevel == 0)
        nSpell = GetBestL0Spell(oPC, -1);
    else if (nSpellLevel == 1)
        nSpell = GetBestL1Spell(oPC, -1);        
    else if (nSpellLevel == 2)
        nSpell = GetBestL2Spell(oPC, -1);        
    else if (nSpellLevel == 3)
        nSpell = GetBestL3Spell(oPC, -1);        
    else if (nSpellLevel == 4)
        nSpell = GetBestL4Spell(oPC, -1);        
    else if (nSpellLevel == 5)
        nSpell = GetBestL5Spell(oPC, -1);        
    else if (nSpellLevel == 6)
        nSpell = GetBestL6Spell(oPC, -1);        
    else if (nSpellLevel == 7)
        nSpell = GetBestL7Spell(oPC, -1);        
    else if (nSpellLevel == 8)
        nSpell = GetBestL8Spell(oPC, -1);        
    else if (nSpellLevel == 9)
        nSpell = GetBestL9Spell(oPC, -1); 
        
    if (nSpell == -1)
    {
        FloatingTextStringOnCreature("You have no spells remaining of the selected level", oPC, FALSE);
        return FALSE;
    }
    
    if (DEBUG) FloatingTextStringOnCreature("Burning SpellID "+IntToString(nSpell), oPC, FALSE);
    PRCDecrementRemainingSpellUses(oPC, nSpell);
    if(GetLocalInt(oPC, "ReserveFeatsRunning"))
        DelayCommand(0.1f, ExecuteScript("prc_reservefeat", oPC));
    return nSpellLevel;
}

int BurnBestSpell(object oPC)
{
    int nSpell = GetBestL9Spell(oPC, -1); 
    if (nSpell == -1)
        nSpell = GetBestL8Spell(oPC, -1);
    if (nSpell == -1)
        nSpell = GetBestL7Spell(oPC, -1);        
    if (nSpell == -1)
        nSpell = GetBestL6Spell(oPC, -1);        
    if (nSpell == -1)
        nSpell = GetBestL5Spell(oPC, -1);        
    if (nSpell == -1)
        nSpell = GetBestL4Spell(oPC, -1);        
    if (nSpell == -1)
        nSpell = GetBestL3Spell(oPC, -1);        
    if (nSpell == -1)
        nSpell = GetBestL2Spell(oPC, -1);        
    if (nSpell == -1)
        nSpell = GetBestL1Spell(oPC, -1);        
    if (nSpell == -1)
        nSpell = GetBestL0Spell(oPC, -1);        
        
    if (nSpell == -1)
    {
        FloatingTextStringOnCreature("You have no spells remaining", oPC, FALSE);
        return FALSE;
    }
    
    if (DEBUG) FloatingTextStringOnCreature("Burning SpellID "+IntToString(nSpell), oPC, FALSE);
    PRCDecrementRemainingSpellUses(oPC, nSpell);
    if(GetLocalInt(oPC, "ReserveFeatsRunning"))
        DelayCommand(0.1f, ExecuteScript("prc_reservefeat", oPC));
    return nSpell;
}