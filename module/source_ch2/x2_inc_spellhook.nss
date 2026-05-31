//::///////////////////////////////////////////////
//:: Spell Hook Include File
//:: x2_inc_spellhook
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

    This file acts as a hub for all code that
    is hooked into the nwn spellscripts'

    If you want to implement material components
    into spells or add restrictions to certain
    spells, this is the place to do it.

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-06-04
//:: Updated On: 2003-10-25
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified Date: January 15th-16th, 2008
//:://////////////////////////////////////////////
/*
    Modified to insure no shapeshifting spells are castable upon
    mounted targets.  This prevents problems that can occur due
    to dismounting after shape shifting, or other issues that can
    occur due to preserved appearances getting out of synch.

    This can additional check can be disabled by setting the variable
    X3_NO_SHAPESHIFT_SPELL_CHECK to 1 on the module object.  If this
    variable is set then this script will function as it did prior to
    this modification.

*/

const int X2_EVENT_CONCENTRATION_BROKEN = 12400;

// Removes spell use for new spellbook system, and calculates spell fail
// chance from ASF or silence effects.
int NSB_SpellCast(object oCaster, int nSpellID, int nCastingClass, int nMetamagic, int nSpellbookType, string sComponent, object oSpellCastItem);

// This function checks for material components or gold
// See switch PRC_MATERIAL_COMPONENTS
int MaterialComponents(object oCaster, int nSpellID, int nCastingClass, object oSpellCastItem);

// This function checks for the Red Wizard's restricted
// spell school and prevents him from casting the spells
// that he is banned from casting.
int RedWizRestrictedSchool(object oCaster, int nSchool, int nCastingClass, object oSpellCastItem);

// This function checks whether the Combat Medic's Healing Kicker
// feats are active, and if so imbues the spell target with additional
// beneficial effects.
void CombatMedicHealingKicker(object oCaster, object oTarget, int nSpellID);

// Duskblade channeling. While channeling, stops non-touch spells
// from working
int DuskbladeArcaneChanneling(object oCaster, object oTarget, int nSpellID, int nCasterLevel, int nMetamagic, object oSpellCastItem);

// Handles the "When spell is cast do this" effects from the Draconic
// series of feats
void DraconicFeatsOnSpell(object oCaster, object oTarget, object oSpellCastItem, int nSpellLevel, int nCastingClass);

// Bard / Sorc PrC handling
// returns FALSE if it is a bard or a sorcerer spell from a character
// with an arcane PrC via bioware spellcasting rather than via PrC spellcasting
int BardSorcPrCCheck(object oCaster, int nCastingClass, object oSpellCastItem);

// Grappling
// Rolls a Concentration check to cast a spell while grappling.
int GrappleConc(object oCaster, int nSpellLevel);

// Blighters can't cast druid spells
int Blighter(object oCaster, int nCastingClass, object oSpellCastItem);

// Spelldance perform check
int Spelldance(object oCaster, int nSpellLevel, int nCastingClass);

// Dazzling Illusion feat
// Dazzles enemies within radius
void DazzlingIllusion(object oCaster, int nSchool);

// Battle Blessing check
int BattleBlessing(object oCaster, int nCastingClass);

// Use Magic Device Check.
// Returns TRUE if the Spell is allowed to be cast, either because the
// character is allowed to cast it or he has won the required UMD check
// Only active on spell scroll
int X2UseMagicDeviceCheck(object oCaster);

// check if the spell is prohibited from being cast on items
// returns FALSE if the spell was cast on an item but is prevented
// from being cast there by its corresponding entry in des_crft_spells
// oItem - pass PRCGetSpellTargetObject in here
int X2CastOnItemWasAllowed(object oItem);

// Sequencer Item Property Handling
// Returns TRUE (and charges the sequencer item) if the spell
// ... was cast on an item AND
// ... the item has the sequencer property
// ... the spell was non hostile
// ... the spell was not cast from an item
// in any other case, FALSE is returned an the normal spellscript will be run
// oItem - pass PRCGetSpellTargetObject in here
int X2GetSpellCastOnSequencerItem(object oItem, object oCaster, int nSpellID, int nMetamagic, int nCasterLevel, int nSaveDC, int bSpellIsHostile, object oSpellCastItem);

int X2RunUserDefinedSpellScript();

// Similar to SetModuleOverrideSpellscript but only applies to the user
// of this spell. Basically tells the class to run this script when the
// spell starts.
void PRCSetUserSpecificSpellScript(string sScript);

// Similar to SetModuleOverrideSpellscriptFinished but only applies to the
// user of this spell. This prevents the spell from continuing on if the
// ability dictates it.
void PRCSetUserSpecificSpellScriptFinished();

// By setting user-defined spellscripts to the player only, we
// avoid the nasty mess of spellhooking the entire module for one player's
// activities.  This function is mostly only useful inside this include.
int PRCRunUserSpecificSpellScript();

// Useful functions for PRCRunUserSpecificSpellScript but not useful in spell
// scripts.
string PRCGetUserSpecificSpellScript();
int PRCGetUserSpecificSpellScriptFinished();

//#include "prc_x2_itemprop" - Inherited from prc_x2_craft
//#include "prc_alterations"
#include "prc_x2_craft"
//#include "x3_inc_horse"
#include "prc_inc_spells"
#include "prc_inc_combat"
//#include "inc_utility"
#include "prc_inc_itmrstr"
#include "prc_inc_burn"
//#include "inc_newspellbook"
//#include "prc_sp_func"
//#include "psi_inc_manifest"
//#include "prc_inc_combmove"
#include "pnp_shft_main"
#include "inc_dynconv"
#include "inc_npc"
#include "inc_infusion"
#include "prc_add_spell_dc"


int Spontaneity(object oCaster, int nCastingClass, int nSpellID, int nSpellLevel)
{
	if(GetLocalInt(oCaster, "PRC_SpontRegen"))
    {
        DeleteLocalInt(oCaster, "PRC_SpontRegen");
		
		int nMetamagic 	= GetMetaMagicFeat();//we need bioware metamagic here
        nSpellLevel 	= PRCGetSpellLevelForClass(nSpellID, nCastingClass);
        nSpellLevel 	+= GetMetaMagicSpellLevelAdjustment(nMetamagic);
        
		int nRegenSpell;
		
		if(nCastingClass == CLASS_TYPE_DRUID)
		{
			switch(nSpellLevel)
			{
				case 0: return TRUE;
				case 1: nRegenSpell = SPELL_REGEN_LIGHT_WOUNDS;		break;
				case 2: nRegenSpell = SPELL_REGEN_MODERATE_WOUNDS;	break;
				case 3: nRegenSpell = SPELL_REGEN_RING;				break;
				case 4: nRegenSpell = SPELL_REGEN_SERIOUS_WOUNDS;	break;
				case 5: nRegenSpell = SPELL_REGEN_CRITICAL_WOUNDS;	break;
				case 6: nRegenSpell = SPELL_REGEN_CIRCLE;			break;
				case 7: nRegenSpell = SPELL_REGEN_CIRCLE;			break;
				case 8: nRegenSpell = SPELL_REGEN_CIRCLE;			break;
				case 9: nRegenSpell = SPELL_REGENERATE;				break;
			}
			ActionCastSpell(nRegenSpell, 0, 0, 0, METAMAGIC_NONE, CLASS_TYPE_DRUID);
		}			
		else
		{
				switch(nSpellLevel)
				{
					case 0: return TRUE;
					case 1: nRegenSpell = SPELL_REGEN_LIGHT_WOUNDS;	break;
					case 2: nRegenSpell = SPELL_REGEN_LIGHT_WOUNDS;	break;
					case 3: nRegenSpell = SPELL_REGEN_MODERATE_WOUNDS;	break;
					case 4: nRegenSpell = SPELL_REGEN_MODERATE_WOUNDS;	break;
					case 5: nRegenSpell = SPELL_REGEN_SERIOUS_WOUNDS;	break;
					case 6: nRegenSpell = SPELL_REGEN_CRITICAL_WOUNDS;	break;
					case 7: nRegenSpell = SPELL_REGENERATE;			break;
					case 8: nRegenSpell = SPELL_REGENERATE;			break;
					case 9: nRegenSpell = SPELL_REGENERATE;			break;
				}

				ActionCastSpell(nRegenSpell, 0, 0, 0, METAMAGIC_NONE, nCastingClass);
		}
		//Don't cast original spell
		return FALSE;
	}
	return TRUE;	
}

int DruidSpontSummon(object oCaster, int nCastingClass, int nSpellID, int nSpellLevel)
{
    if(nCastingClass != CLASS_TYPE_DRUID)
        return TRUE;

    if(GetLocalInt(oCaster, "PRC_SpontSummon"))
    {
        DeleteLocalInt(oCaster, "PRC_SpontSummon");
        int nMetamagic = GetMetaMagicFeat();//we need bioware metamagic here
        int nSpellLevel = PRCGetSpellLevelForClass(nSpellID, CLASS_TYPE_DRUID);
        nSpellLevel += GetMetaMagicSpellLevelAdjustment(nMetamagic);
        int nSummonSpell;
        switch(nSpellLevel)
        {
            case 0: return TRUE;
            case 1: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_1;	break;
            case 2: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_2;	break;
            case 3: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_3;	break;
            case 4: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_4;	break;
            case 5: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_5;	break;
            case 6: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_6;	break;
            case 7: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_7;	break;
            case 8: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_8;	break;
            case 9: nSummonSpell = SPELL_SUMMON_NATURES_ALLY_9;	break;
        }

		//:: All SNA spells are subradial spells
		SetLocalInt(oCaster, "DomainOrigSpell", nSummonSpell);
		SetLocalInt(oCaster, "DomainCastLevel", nSpellLevel);
		SetLocalInt(oCaster, "DomainCastClass", CLASS_TYPE_DRUID);
		StartDynamicConversation("prc_domain_conv", oCaster, DYNCONV_EXIT_NOT_ALLOWED, FALSE, TRUE, oCaster);

        //Don't cast original spell
        return FALSE;
    }

    return TRUE;
}

/* int DruidSpontSummon(object oCaster, int nCastingClass, int nSpellID, int nSpellLevel)
{
    if(nCastingClass != CLASS_TYPE_DRUID)
        return TRUE;

    if(GetLocalInt(oCaster, "PRC_SpontSummon"))
    {
        DeleteLocalInt(oCaster, "PRC_SpontSummon");
        int nMetamagic = GetMetaMagicFeat();//we need bioware metamagic here
        int nSpellLevel = PRCGetSpellLevelForClass(nSpellID, CLASS_TYPE_DRUID);
        nSpellLevel += GetMetaMagicSpellLevelAdjustment(nMetamagic);
        int nSummonSpell;
        switch(nSpellLevel)
        {
            case 0: return TRUE;
            case 1: nSummonSpell = SPELL_SUMMON_CREATURE_I;    break;
            case 2: nSummonSpell = SPELL_SUMMON_CREATURE_II;   break;
            case 3: nSummonSpell = SPELL_SUMMON_CREATURE_III;  break;
            case 4: nSummonSpell = SPELL_SUMMON_CREATURE_IV;   break;
            case 5: nSummonSpell = SPELL_SUMMON_CREATURE_V;    break;
            case 6: nSummonSpell = SPELL_SUMMON_CREATURE_VI;   break;
            case 7: nSummonSpell = SPELL_SUMMON_CREATURE_VII;  break;
            case 8: nSummonSpell = SPELL_SUMMON_CREATURE_VIII; break;
            case 9: nSummonSpell = SPELL_SUMMON_CREATURE_IX;   break;
        }

        //subradial spells
        if(nSummonSpell == SPELL_SUMMON_CREATURE_VII
        || nSummonSpell == SPELL_SUMMON_CREATURE_VIII
        || nSummonSpell == SPELL_SUMMON_CREATURE_IX)
        {
            SetLocalInt(oCaster, "DomainOrigSpell", nSummonSpell);
            SetLocalInt(oCaster, "DomainCastLevel", nSpellLevel);
            SetLocalInt(oCaster, "DomainCastClass", CLASS_TYPE_DRUID);
            StartDynamicConversation("prc_domain_conv", oCaster, DYNCONV_EXIT_NOT_ALLOWED, FALSE, TRUE, oCaster);
        }
        else
            ActionCastSpell(nSummonSpell, 0, 0, 0, METAMAGIC_NONE, CLASS_TYPE_DRUID);

        //Don't cast original spell
        return FALSE;
    }

    return TRUE;
}

 */

int ArcaneSpellFailure(object oCaster, int nCastingClass, int nSpellLevel, int nMetamagic, string sComponents)
{
    if(!GetIsArcaneClass(nCastingClass))
        return FALSE;
    
    // They don't suffer ASF
    if(nCastingClass == CLASS_TYPE_FACTOTUM)
        return FALSE;        
        
    // Hammer of Witches - wielder cannot cast arcane spells
    if(GetIsObjectValid(GetItemPossessedBy(oCaster, "WOL_HammerWitches")))
        return TRUE;

    if(FindSubString(sComponents, "S") == -1)
        return FALSE;

    object oArmor  = GetItemInSlot(INVENTORY_SLOT_CHEST, oCaster);
    object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCaster);
    int nAC  = GetBaseAC(oArmor);
    int nASF = GetArcaneSpellFailure(oCaster);
    int bBattleCaster = GetHasFeat(FEAT_BATTLE_CASTER, oCaster);

    //Classes with reduced ASF
    // Beguiler/Dread Necromancer/Sublime Chord can cast in light armor.
    if(nCastingClass == CLASS_TYPE_BEGUILER
    || nCastingClass == CLASS_TYPE_DREAD_NECROMANCER
    || nCastingClass == CLASS_TYPE_SUBLIME_CHORD)
    {
        //armors
        switch(nAC)
        {
            case 1: nASF -=  5; break;//light
            case 2: nASF -= 10; break;//light
            case 3: nASF -= 20; break;//light
            case 4: nASF -= bBattleCaster ? 20 : 0; break;//medium;
            case 5: nASF -= bBattleCaster ? 30 : 0; break;//medium
            default: break;
        }
    }
	
	// Hexblade can cast in light armour only.  
	else if(nCastingClass == CLASS_TYPE_HEXBLADE)  
	{  
		//armors  
		switch(nAC)  
		{  
			case 1: nASF -=  5; break; //light  
			case 2: nASF -= 10; break; //light  
			case 3: nASF -= 20; break; //light  
			case 4: nASF = bBattleCaster ? 0 : nASF; break; //medium with Battlecaster  
			case 5: nASF = bBattleCaster ? 0 : nASF; break; //medium with Battlecaster  
			default: break;  
		}  
	}
	
    // WRONG: Hexblade can cast in light/medium armour and while using small shield.
	//:: RIGHT: Hexblades are proficient with all simple and martial weapons, and with light armor but not with shields.
/*     else if(nCastingClass == CLASS_TYPE_HEXBLADE)
    {
        //shields
        if(GetBaseItemType(oShield) == BASE_ITEM_SMALLSHIELD) nASF -= 5;
        //armors
        switch(nAC)
        {
            case 1: nASF -=  5; break;
            case 2: nASF -= 10; break;
            case 3: nASF -= 20; break;
            case 4: nASF -= 20; break;
            case 5: nASF -= 30; break;
            case 6: nASF -= bBattleCaster ? 40 : 0; break;
            case 7: nASF -= bBattleCaster ? 40 : 0; break;
            case 8: nASF -= bBattleCaster ? 45 : 0; break;
            default: break;
        }
    } */
    // Bards cannot cast in light armour and while using small shield in 3e
/*     else if(nCastingClass == CLASS_TYPE_BARD)
    {
        int nLvl = GetLevelByClass(CLASS_TYPE_BARD, oCaster);
        int nShield = GetBaseItemType(oShield);
        //armors
        switch(nAC)
        {
            case 1: nASF -=  5; break;//light
            case 2: nASF -= 10; break;//light
            case 3: nASF -= 20; break;//light
            case 4: nASF -= bBattleCaster ? 20 : 0; break;//medium;
            case 5: nASF -= bBattleCaster ? 30 : 0; break;//medium
            default: break;
        }
        //shields
        switch(nShield)
        {
            case BASE_ITEM_SMALLSHIELD: nASF -=  5; break;
        }
    } */		
    // Duskblade can cast in light/medium armour and while using small/large shield.
    else if(nCastingClass == CLASS_TYPE_DUSKBLADE)
    {
        int nLvl = GetLevelByClass(CLASS_TYPE_DUSKBLADE, oCaster);
        int nShield = GetBaseItemType(oShield);
        //armors
        switch(nAC)
        {
            case 1: nASF -=  5; break;
            case 2: nASF -= 10; break;
            case 3: nASF -= 20; break;
            case 4: nASF -= (nLvl >= 4 || bBattleCaster) ? 20 : 0; break;
            case 5: nASF -= (nLvl >= 4 || bBattleCaster) ? 30 : 0; break;
            case 6: nASF -= (nLvl >= 4 && bBattleCaster) ? 40 : 0; break;
            case 7: nASF -= (nLvl >= 4 && bBattleCaster) ? 40 : 0; break;
            case 8: nASF -= (nLvl >= 4 && bBattleCaster) ? 45 : 0; break;
            default: break;
        }
        //shields
        switch(nShield)
        {
            case BASE_ITEM_SMALLSHIELD: nASF -=  5; break;
            case BASE_ITEM_LARGESHIELD: nASF -= 15; break;
        }
    }
    // Suel Archanamach gets the Ignore Spell Failure Chance feats
// Suel Archanamach gets the Ignore Spell Failure Chance feats
	else if(nCastingClass == CLASS_TYPE_SUEL_ARCHANAMACH)
	{
		int nLvl = GetLevelByClass(CLASS_TYPE_SUEL_ARCHANAMACH, oCaster);

		if (nLvl >= 28) nASF -= 50;
		else if(nLvl >= 25) nASF -= 45;
		else if(nLvl >= 22) nASF -= 40;
		else if(nLvl >= 19) nASF -= 35;
		else if(nLvl >= 16) nASF -= 30;
		else if(nLvl >= 13) nASF -= 25;
		else if(nLvl >= 10) nASF -= 20;
		else if(nLvl >= 7)  nASF -= 15;
		else if(nLvl >= 4)  nASF -= 10;
		else if(nLvl >= 1)  nASF -= 5;
	}
    // Warmage can cast in light/medium armour and while using small shield.
    else if(nCastingClass == CLASS_TYPE_WARMAGE)
    {
        int nLvl = GetLevelByClass(CLASS_TYPE_WARMAGE, oCaster);
        //armors
        switch(nAC)
        {
            case 1: nASF -= 5; break;
            case 2: nASF -= 10; break;
            case 3: nASF -= 20; break;
            case 4: nASF -= (nLvl >= 8 || bBattleCaster) ? 20 : 0; break;
            case 5: nASF -= (nLvl >= 8 || bBattleCaster) ? 30 : 0; break;
            case 6: nASF -= (nLvl >= 8 && bBattleCaster) ? 40 : 0; break;
            case 7: nASF -= (nLvl >= 8 && bBattleCaster) ? 40 : 0; break;
            case 8: nASF -= (nLvl >= 8 && bBattleCaster) ? 45 : 0; break;
            default: break;
        }
        //shields
        if(GetBaseItemType(oShield) == BASE_ITEM_SMALLSHIELD)
            nASF -= 5;
    }
    // Knight of the Weave ignores spell failure in light/medium
    else if(nCastingClass == CLASS_TYPE_KNIGHT_WEAVE)
    {
        int nLvl = GetLevelByClass(CLASS_TYPE_KNIGHT_WEAVE, oCaster);
        if (nLvl >= 2) //Doesn't start until 2nd level
        {
            //armors
            switch(nAC)
            {
                case 1: nASF -= 5; break;
                case 2: nASF -= 10; break;
                case 3: nASF -= 20; break;
                case 4: nASF -= (nLvl >= 8 || bBattleCaster) ? 20 : 0; break;
                case 5: nASF -= (nLvl >= 8 || bBattleCaster) ? 30 : 0; break;
                case 6: nASF -= (nLvl >= 8 && bBattleCaster) ? 40 : 0; break;
                case 7: nASF -= (nLvl >= 8 && bBattleCaster) ? 40 : 0; break;
                case 8: nASF -= (nLvl >= 8 && bBattleCaster) ? 45 : 0; break;
                default: break;
            }
        }    
    }   
    // Redspawn Arcaniss can cast in light armour and while using small shields.
    else if(nCastingClass == CLASS_TYPE_SORCERER && !GetLevelByClass(CLASS_TYPE_SORCERER, oCaster) && GetRacialType(oCaster) == RACIAL_TYPE_REDSPAWN_ARCANISS)
    {
        int nShield = GetBaseItemType(oShield);
        //armors
        switch(nAC)
        {
            case 1: nASF -=  5; break;
            case 2: nASF -= 10; break;
            case 3: nASF -= 20; break;
            case 4: nASF -= (bBattleCaster) ? 20 : 0; break;
            case 5: nASF -= (bBattleCaster) ? 30 : 0; break;
            default: break;
        }
        //shields
        switch(nShield)
        {
            case BASE_ITEM_SMALLSHIELD: nASF -=  5; break;
        }
    }    

    if(Random(100) < nASF)
    {
        int nFail = TRUE;
        // Still spell helps
        if(nMetamagic & METAMAGIC_STILL
        || (GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_1, oCaster) && nSpellLevel <= 3)
        || (GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_2, oCaster) && nSpellLevel <= 6)
        || (GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_3, oCaster) && nSpellLevel <= 9))
        {
            nFail = FALSE;
        }
        if(nFail)
        {
            //52946 = Spell failed due to arcane spell failure!
            FloatingTextStrRefOnCreature(52946, oCaster, FALSE);
            return TRUE;
        }
    }
    return FALSE;
}

int SilenceDeafnessFailure(object oCaster, int nSpellLevel, int nMetamagic, string sComponents)
{
    if(FindSubString(sComponents, "V") == -1)
        return FALSE;

    if(PRCGetHasEffect(EFFECT_TYPE_SILENCE, oCaster)
    || (PRCGetHasEffect(EFFECT_TYPE_DEAF, oCaster) && Random(100) < 20))
    {
        //auto-silent exceptions
        if(nMetamagic & METAMAGIC_SILENT
        || (GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_1, oCaster) && nSpellLevel <= 3)
        || (GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_2, oCaster) && nSpellLevel <= 6)
        || (GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_3, oCaster) && nSpellLevel <= 9))
        {
            return FALSE;
        }
        else
        {
            //3734 = Spell failed!
            FloatingTextStrRefOnCreature(3734, oCaster, FALSE);
            return TRUE;
        }
    }
    return FALSE;
}

int Forsaker(object oCaster, object oTarget)  
{  
    // Friendly spells autofail on Forsakers  
    if (GetLevelByClass(CLASS_TYPE_FORSAKER, oTarget) && GetIsFriend(oTarget, oCaster))  
    {  
        FloatingTextStringOnCreature("Target is a Forsaker, spell failed!", oCaster, FALSE);  
        return FALSE;  
    }  
      
    // Forsakers can't use magic
    if (GetLevelByClass(CLASS_TYPE_FORSAKER, oCaster))  
    {  
        object oSpellCastItem = PRCGetSpellCastItem();  
          
        // Allow alchemical items  
        if(GetIsObjectValid(oSpellCastItem) && GetIsAlchemical(oSpellCastItem))  
        {  
            return TRUE;  
        }  
          
        FloatingTextStringOnCreature("Forsakers cannot cast spells!", oCaster, FALSE);  
        return FALSE;  
    }      
          
    return TRUE;      
}

/* int Forsaker(object oCaster, object oTarget)
{
	// Friendly spells autofail on Forsakers
	if (GetLevelByClass(CLASS_TYPE_FORSAKER, oTarget) && GetIsFriend(oTarget, oCaster))
	{
		FloatingTextStringOnCreature("Target is a Forsaker, spell failed!", oCaster, FALSE);
		return FALSE;
	}
	
	// Forsakers can't use magic
	if (GetLevelByClass(CLASS_TYPE_FORSAKER, oCaster))
	{
		FloatingTextStringOnCreature("Forsakers cannot cast spells!", oCaster, FALSE);
		return FALSE;
	}	
		
	return TRUE;	
} */

int NSB_SpellCast(object oCaster, int nSpellID, int nCastingClass, int nMetamagic, int nSpellbookType, string sComponent, object oSpellCastItem)
{
//DoDebug("PRC last spell cast class = "+IntToString(PRCGetLastSpellCastClass()));
//DoDebug("Primary Arcane Class = "+IntToString(GetPrimaryArcaneClass(oPC)));
//DoDebug("Caster Level = "+IntToString(PRCGetCasterLevel(oPC)));
//DoDebug("NSB_Class = "+GetStringByStrRef(StringToInt(Get2DACache("classes", "Name", NSB_Class))));

    // check if the spell was cast from original spellbook or from item
    int bNormalCasting = (GetLastSpellCastClass() != CLASS_TYPE_INVALID || oSpellCastItem != OBJECT_INVALID || GetLocalInt(oCaster, "SpellIsSLA"));
    int NSB_Class = GetLocalInt(oCaster, "NSB_Class");
    int nDomainCast = GetLocalInt(oCaster, "DomainCast");

    if(nDomainCast)
    {
        int nBurnSpell = GetLocalInt(oCaster, "Domain_BurnableSpell") - 1;
        if(nBurnSpell != -1)
        {
            if(!GetHasSpell(nBurnSpell, oCaster))
            {
                //Stop casting
                DeleteLocalInt(oCaster, "DomainCast");
                DeleteLocalInt(oCaster, "Domain_BurnableSpell");
                return FALSE;
            }
            else
            {
                DecrementRemainingSpellUses(oCaster, nBurnSpell);
                SetLocalInt(oCaster, "DomainCastSpell" + IntToString(nDomainCast), TRUE);
            }
        }
        else
        {
            DeleteLocalInt(oCaster, "NSB_Class");
            if(NSB_Class != CLASS_TYPE_MYSTIC && NSB_Class != CLASS_TYPE_NIGHTSTALKER)
                SetLocalInt(oCaster, "DomainCastSpell" + IntToString(nDomainCast), TRUE);
        }
        DeleteLocalInt(oCaster, "DomainCast");
        DeleteLocalInt(oCaster, "Domain_BurnableSpell");
    }

    //if for some reason NSB variables were not removed and the player is not casting from new spellbook
    //remove the variables now
    if(bNormalCasting)
    {
        if(NSB_Class)
        {
            //clean local vars
            DeleteLocalInt(oCaster, "NSB_SpellLevel");
            DeleteLocalInt(oCaster, "NSB_Class");
            DeleteLocalInt(oCaster, "NSB_SpellbookID");
        }
        return TRUE;
    }

    //this shuld be executed only for new spellbook spells
    else if(NSB_Class)
    {
        int nSpellLevel = GetLocalInt(oCaster, "NSB_SpellLevel");
        int nCount;
        string sArray = "NewSpellbookMem_" + IntToString(nCastingClass);
        string sMessage;

        if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
        {
            int nSpellbookID = GetLocalInt(oCaster, "NSB_SpellbookID");
            nCount = persistant_array_get_int(oCaster, sArray, nSpellbookID);
            if(nCount < 1)
                return FALSE;

            nCount--;
            persistant_array_set_int(oCaster, sArray, nSpellbookID, nCount);

            int nRealSpellID = StringToInt(Get2DACache(GetFileForClass(nCastingClass), "RealSpellID", nSpellbookID));
            string sSpellName = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nRealSpellID)));
            // "You have " + IntToString(nCount) + " castings of " + sSpellName + " remaining"
            sMessage = ReplaceChars(GetStringByStrRef(16828410), "<count>",     IntToString(nCount));
            sMessage = ReplaceChars(sMessage,                    "<spellname>", sSpellName);
        }
        else if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
        {
            nCount = persistant_array_get_int(oCaster, sArray, nSpellLevel);
            if(nCount < 1)
                return FALSE;

            nCount--;
            persistant_array_set_int(oCaster, sArray, nSpellLevel, nCount);

            // "You have " + IntToString(nCount) + " castings of spells of level " + IntToString(nSpellLevel) + " remaining"
            sMessage = ReplaceChars(GetStringByStrRef(16828408), "<count>",      IntToString(nCount));
            sMessage = ReplaceChars(sMessage,                    "<spelllevel>", IntToString(nSpellLevel));
        }
        FloatingTextStringOnCreature(sMessage, oCaster, FALSE);

        // Arcane classes roll ASF if the spell has a somatic component
        // OR if the spell has a vocal component, silence and deafness can cause failure
        if(ArcaneSpellFailure(oCaster, nCastingClass, nSpellLevel, nMetamagic, sComponent)
        || SilenceDeafnessFailure(oCaster, nSpellLevel, nMetamagic, sComponent))
            return FALSE;

        return TRUE;
    }
    return TRUE;
}

int MaterialComponents(object oCaster, int nSpellID, int nCastingClass, object oSpellCastItem)
{
    int nSwitch = GetPRCSwitch(PRC_MATERIAL_COMPONENTS);

    if(!nSwitch)
        return TRUE;

    // exceptions
    if(GetHasFeat(FEAT_IGNORE_MATERIALS, oCaster)     //caster has ignore material components feat
    || GetIsDM(oCaster) || GetIsDMPossessed(oCaster)  //caster is DM
    || oSpellCastItem != OBJECT_INVALID               //spell was cast from an item
    || nCastingClass == CLASS_TYPE_RUNESCARRED || GetLocalInt(oCaster, "SpellIsSLA"))//spell is a spell-like ability
    {
        return TRUE;
    }

    // Components and Names
    string sComp1     = Get2DACache("prc_spells", "Component1", nSpellID);
    string sCompName1 = Get2DACache("prc_spells", "CompName1", nSpellID);
    string sComp2     = Get2DACache("prc_spells", "Component2", nSpellID);
    string sCompName2 = Get2DACache("prc_spells", "CompName2", nSpellID);
    string sComp3     = Get2DACache("prc_spells", "Component3", nSpellID);
    string sCompName3 = Get2DACache("prc_spells", "CompName3", nSpellID);
    string sComp4     = Get2DACache("prc_spells", "Component4", nSpellID);
    string sCompName4 = Get2DACache("prc_spells", "CompName4", nSpellID);
    int nGold = StringToInt(Get2DACache("prc_spells", "GP", nSpellID));

    // These are set to false if the spell has a component
    int nHasComp1 = sComp1 == "" ? TRUE: FALSE;
    int nHasComp2 = sComp2 == "" ? TRUE: FALSE;
    int nHasComp3 = sComp3 == "" ? TRUE: FALSE;
    int nHasComp4 = sComp4 == "" ? TRUE: FALSE;

    // The spell doesn't require any material components
    if(nHasComp1 && nHasComp2 && nHasComp3 && nHasComp4 && !nGold)
        return TRUE;

    // Set the return value to false
    int nReturn = FALSE;

    // Set test variables
    int nComponents = TRUE;
    int nCost = TRUE;

    // Component Objects to destroy
    object oComp1, oComp2, oComp3, oComp4;

    string sSpell = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellID)));

    if(nSwitch == 1 || nSwitch == 3)
    {
        nComponents = FALSE;

        // Check if caster has spell component pouch
        object oPouch = GetItemPossessedBy(oCaster, "prc_spellpouch");

        if((GetHasFeat(FEAT_ESCHEW_MATERIALS, oCaster) || GetIsObjectValid(oPouch))
        && nGold < 1)
        {
            nComponents = TRUE;
        }
        else
        {
            string sMes = "Material component missing: ";

            // Look for items in players inventory
            if(!nHasComp1)
            {
                oComp1 = GetItemPossessedBy(oCaster, sComp1);
                if(GetIsObjectValid(oComp1))
                    nHasComp1 = TRUE;
                else
                    FloatingTextStringOnCreature(sMes + sCompName1, oCaster, FALSE);
            }

            if(!nHasComp2)
            {
                oComp2 = GetItemPossessedBy(oCaster, sComp2);
                if(GetIsObjectValid(oComp2))
                    nHasComp2 = TRUE;
                else
                    FloatingTextStringOnCreature(sMes + sCompName2, oCaster, FALSE);
            }

            if(!nHasComp3)
            {
                oComp3 = GetItemPossessedBy(oCaster, sComp3);
                if(GetIsObjectValid(oComp3))
                    nHasComp3 = TRUE;
                else
                    FloatingTextStringOnCreature(sMes + sCompName3, oCaster, FALSE);
            }

            if(!nHasComp4)
            {
                oComp4 = GetItemPossessedBy(oCaster, sComp4);
                if(GetIsObjectValid(oComp4))
                    nHasComp4 = TRUE;
                else
                    FloatingTextStringOnCreature(sMes + sCompName4, oCaster, FALSE);
            }
        }

        if(nHasComp1 && nHasComp2 && nHasComp3 && nHasComp4)
            nComponents = TRUE;
        else
            FloatingTextStringOnCreature("You do not have the appropriate material components to cast " + sSpell, oCaster, FALSE);
    }
    if(nSwitch == 2 || nSwitch == 3)
    {
        nCost = FALSE;

        // Now check to see if they have enough gold
        if(GetGold(oCaster) >= nGold)
            nCost = TRUE;
        else
            FloatingTextStringOnCreature("You do not have enough gold to cast " + sSpell, oCaster, FALSE);
    }

    // Checked for the spell components, now the final test.
    if(nComponents && nCost)
    {
        // We've got all the components
        nReturn = TRUE;

        if(nSwitch == 1 || nSwitch == 3)
        {
            int nStack = 0;

            // Component 1
            nStack = GetNumStackedItems(oComp1);

            if(nStack > 1)
                DelayCommand(0.6, SetItemStackSize (oComp1, --nStack));
            else
                DelayCommand(0.6, DestroyObject(oComp1));

            // Component 2
            nStack = GetNumStackedItems(oComp2);

            if(nStack > 1)
                DelayCommand(0.6, SetItemStackSize (oComp2, --nStack));
            else
                DelayCommand(0.6, DestroyObject(oComp2));

            // Component 3
            nStack = GetNumStackedItems(oComp3);

            if(nStack > 1)
                DelayCommand(0.6, SetItemStackSize (oComp3, --nStack));
            else
                DelayCommand(0.6, DestroyObject(oComp3));

            // Component 4
            nStack = GetNumStackedItems(oComp4);

            if(nStack > 1)
                DelayCommand(0.6, SetItemStackSize (oComp4, --nStack));
            else
                DelayCommand(0.6, DestroyObject(oComp4));
        }
        if(nSwitch == 2 || nSwitch == 3)
        {
            TakeGoldFromCreature(nGold, oCaster, TRUE);
        }
    }

    // return our value
    return nReturn;
}

int SpellRestrictClass(int nCastingClass, int nSwitch)
{
    if(nSwitch == 3)
        return TRUE;
    if(nSwitch == 1)
        return FALSE;

    //else nSwitch == 2
    if(nCastingClass == CLASS_TYPE_CLERIC
     || nCastingClass == CLASS_TYPE_FAVOURED_SOUL
     || nCastingClass == CLASS_TYPE_OCULAR
     || nCastingClass == CLASS_TYPE_SHAMAN
     || nCastingClass == CLASS_TYPE_HEALER
     || nCastingClass == CLASS_TYPE_TEMPLAR)
        return TRUE;

    return FALSE;
}

int SpellAlignmentRestrictions(object oCaster, int nSpellID, int nCastingClass)
{
    int nSwitch = GetPRCSwitch(PRC_SPELL_ALIGNMENT_RESTRICT);

    if(!nSwitch)
        return TRUE;
        
    int nShift = GetPRCSwitch(PRC_SPELL_ALIGNMENT_SHIFT);    

    int nAlignGE = GetGoodEvilValue(oCaster);
    int nAlignLC = GetLawChaosValue(oCaster);
    int nAdjust;
    int nDescriptor = GetLocalInt(oCaster, PRC_DESCRIPTOR);
    if(!nDescriptor)
        nDescriptor = GetDescriptorFlags(nSpellID);

    if(nDescriptor & DESCRIPTOR_EVIL)
    {
        if(nAlignGE > 69 && SpellRestrictClass(nCastingClass, nSwitch))
        {
            FloatingTextStringOnCreature("Your alignment prohibits casting spells with this descriptor!", oCaster, FALSE);
            return FALSE;
        }
        else if (nShift)
        {
            nAdjust = FloatToInt(sqrt(IntToFloat(nAlignGE)) / 2);
            if(nAdjust) AdjustAlignment(oCaster, ALIGNMENT_EVIL, nAdjust, FALSE);
        }
    }
    if(nDescriptor & DESCRIPTOR_GOOD)
    {
        if(nAlignGE < 31 && SpellRestrictClass(nCastingClass, nSwitch))
        {
            FloatingTextStringOnCreature("Your alignment prohibits casting spells with this descriptor!", oCaster, FALSE);
            return FALSE;
        }
        else if (nShift)
        {
            nAdjust = FloatToInt(sqrt(IntToFloat(100 - nAlignGE)) / 2);
            if(nAdjust) AdjustAlignment(oCaster, ALIGNMENT_GOOD, nAdjust, FALSE);
        }
    }
    if(nDescriptor & DESCRIPTOR_LAWFUL)
    {
        if(nAlignLC < 31 && SpellRestrictClass(nCastingClass, nSwitch))
        {
            FloatingTextStringOnCreature("Your alignment prohibits casting spells with this descriptor!", oCaster, FALSE);
            return FALSE;
        }
        else if (nShift)
        {
            nAdjust = FloatToInt(sqrt(IntToFloat(100 - nAlignLC)) / 2);
            if(nAdjust) AdjustAlignment(oCaster, ALIGNMENT_LAWFUL, nAdjust, FALSE);
        }
    }
    if(nDescriptor & DESCRIPTOR_CHAOTIC)
    {
        if(nAlignLC > 69 && SpellRestrictClass(nCastingClass, nSwitch))
        {
            FloatingTextStringOnCreature("Your alignment prohibits casting spells with this descriptor!", oCaster, FALSE);
            return FALSE;
        }
        else if (nShift)
        {
            nAdjust = FloatToInt(sqrt(IntToFloat(nAlignLC)) / 2);
            if(nAdjust) AdjustAlignment(oCaster, ALIGNMENT_CHAOTIC, nAdjust, FALSE);
        }
    }
    return TRUE;
}

int RedWizRestrictedSchool(object oCaster, int nSchool, int nCastingClass, object oSpellCastItem)
{
    // No need for wasting CPU on non-Red Wizards
    if(GetLevelByClass(CLASS_TYPE_RED_WIZARD, oCaster))
    {
        //can’t cast prohibited spells from scrolls or fire them from wands
        if(GetIsObjectValid(oSpellCastItem))
        {
            int nType = GetBaseItemType(oSpellCastItem);
            if(nType != BASE_ITEM_MAGICWAND
            && nType != BASE_ITEM_ENCHANTED_WAND
            && nType != BASE_ITEM_SCROLL
            && nType != BASE_ITEM_SPELLSCROLL
            && nType != BASE_ITEM_ENCHANTED_SCROLL)
                return TRUE;
        }

        // Determine forbidden schools
        int iRWRes;
        switch(nSchool)
        {
            case SPELL_SCHOOL_ABJURATION:    iRWRes = FEAT_RW_RES_ABJ; break;
            case SPELL_SCHOOL_CONJURATION:   iRWRes = FEAT_RW_RES_CON; break;
            case SPELL_SCHOOL_DIVINATION:    iRWRes = FEAT_RW_RES_DIV; break;
            case SPELL_SCHOOL_ENCHANTMENT:   iRWRes = FEAT_RW_RES_ENC; break;
            case SPELL_SCHOOL_EVOCATION:     iRWRes = FEAT_RW_RES_EVO; break;
            case SPELL_SCHOOL_ILLUSION:      iRWRes = FEAT_RW_RES_ILL; break;
            case SPELL_SCHOOL_NECROMANCY:    iRWRes = FEAT_RW_RES_NEC; break;
            case SPELL_SCHOOL_TRANSMUTATION: iRWRes = FEAT_RW_RES_TRS; break;
        }

        // Compare the spell's school versus the restricted schools
        if(iRWRes && GetHasFeat(iRWRes, oCaster))
        {
            FloatingTextStrRefOnCreature(16822359, oCaster, FALSE); // "You cannot cast spells of your prohibited schools. Spell terminated."
            return FALSE;
        }
        // Other arcane casters cannot benefit from red wizard bonuses
        if(GetIsArcaneClass(nCastingClass) && nCastingClass != CLASS_TYPE_WIZARD)
        {
            FloatingTextStringOnCreature("You have attempted to illegaly merge another arcane caster with a Red Wizard. All spellcasting will now fail.", oCaster, FALSE);
            return FALSE;
        }
    }

    return TRUE;
}

int PnPSpellSchools(object oCaster, int nCastingClass, int nSchool, object oSpellCastItem)
{
    if(GetPRCSwitch(PRC_PNP_SPELL_SCHOOLS)
    && nCastingClass == CLASS_TYPE_WIZARD)
    {
        //can’t cast prohibited spells from scrolls or fire them from wands
        if(GetIsObjectValid(oSpellCastItem))
        {
            int nType = GetBaseItemType(oSpellCastItem);
            if(nType != BASE_ITEM_MAGICWAND
            && nType != BASE_ITEM_ENCHANTED_WAND
            && nType != BASE_ITEM_SCROLL
            && nType != BASE_ITEM_SPELLSCROLL
            && nType != BASE_ITEM_ENCHANTED_SCROLL)
                return TRUE;
        }

        int nFeat;
        switch(nSchool)
        {
            case SPELL_SCHOOL_ABJURATION:    nFeat = 2265; break;
            case SPELL_SCHOOL_CONJURATION:   nFeat = 2266; break;
            case SPELL_SCHOOL_DIVINATION:    nFeat = 2267; break;
            case SPELL_SCHOOL_ENCHANTMENT:   nFeat = 2268; break;
            case SPELL_SCHOOL_EVOCATION:     nFeat = 2269; break;
            case SPELL_SCHOOL_ILLUSION:      nFeat = 2270; break;
            case SPELL_SCHOOL_NECROMANCY:    nFeat = 2271; break;
            case SPELL_SCHOOL_TRANSMUTATION: nFeat = 2272; break;
            default: nFeat = 0;
        }
        if(nFeat && GetHasFeat(nFeat, oCaster))
        {
            FloatingTextStringOnCreature("You cannot cast spells of an opposition school.", oCaster, FALSE);
            return FALSE;
        }
    }

    return TRUE;
}

int ShifterCasting(object oCaster, object oSpellCastItem, int nSpellLevel, int nMetamagic, string sComponent)
{
    // The variable tells that the new form is unable to cast spells (very inaccurate, determined by racial type)
    // with somatic or vocal components and is lacking Natural Spell feat
    if(GetLocalInt(oCaster, "PRC_Shifting_RestrictSpells"))
    {
        if(GetIsObjectValid(oSpellCastItem))
        {
            // Potion drinking is not restricted
            if(GetBaseItemType(oSpellCastItem) == BASE_ITEM_ENCHANTED_POTION
            || GetBaseItemType(oSpellCastItem) == BASE_ITEM_POTIONS
			|| GetBaseItemType(oSpellCastItem) == BASE_ITEM_INFUSED_HERB)
                return TRUE;

            //OnHit properties on equipped items not restricted
            int nSlot;
            for(nSlot = 0; nSlot<NUM_INVENTORY_SLOTS; nSlot++)
            {
                if(GetItemInSlot(nSlot, oCaster) == oSpellCastItem)
                    return TRUE;
            }
        }

        int bDisrupted  = FALSE;

        // Somatic component and no silent meta or high enough auto-still
        if(FindSubString(sComponent, "S") != -1)
        {
            if(!(nMetamagic & METAMAGIC_STILL)
            && !(GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_3, oCaster)
            || (nSpellLevel <= 6 && GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_2, oCaster))
            || (nSpellLevel <= 3 && GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_1, oCaster))))
                bDisrupted = TRUE;
        }

        // Vocal component and no silent meta or high enough auto-silent
        if(FindSubString(sComponent, "V") != -1)
        {
            if(!(nMetamagic & METAMAGIC_SILENT)
            && !(GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_3, oCaster)
            || (nSpellLevel <= 6 && GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_2, oCaster))
            || (nSpellLevel <= 3 && GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_1, oCaster))))
                bDisrupted = TRUE;
        }

        if(bDisrupted)
        {
            FloatingTextStrRefOnCreature(16828386, oCaster, FALSE); // "Your spell failed due to being in a form that prevented either a somatic or a vocal component from being used"
            return FALSE;
        }
    }

    return TRUE;
}

void DuskbladeCleanUp(object oItem, int nMax)
{
    int i;
    for (i = 1; i <= nMax; i++)
    {
        DeleteLocalInt(oItem, "X2_L_CHANNELTRIGGER" + IntToString(i));
        DeleteLocalInt(oItem, "X2_L_CHANNELTRIGGER_L" + IntToString(i));
        DeleteLocalInt(oItem, "X2_L_CHANNELTRIGGER_M" + IntToString(i));
        DeleteLocalInt(oItem, "X2_L_CHANNELTRIGGER_D" + IntToString(i));
    }
    DeleteLocalInt(oItem, "X2_L_NUMCHANNELTRIGGERS");
    DeleteLocalInt(oItem, "DuskbladeChannelDischarge");
}

int DuskbladeArcaneChanneling(object oCaster, object oTarget, int nSpellID, int nCasterLevel, int nMetamagic, object oSpellCastItem)
{
    if(GetLocalInt(oCaster, "DuskbladeChannelActive"))
    {
        // Don't channel from objects
        if(oSpellCastItem != OBJECT_INVALID)
            return TRUE;

        int nClass = GetLevelByClass(CLASS_TYPE_DUSKBLADE, oCaster);
        //channeling active
        //find the item
        object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster);
        if(!GetIsObjectValid(oItem)) oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oCaster);
        if(!GetIsObjectValid(oItem)) oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oCaster);
        if(!GetIsObjectValid(oItem)) oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oCaster);
        if(GetIsObjectValid(oItem)
        && (Get2DACache("spells", "Range", nSpellID) == "T")
        && IPGetIsMeleeWeapon(oItem)
        && GetIsEnemy(oTarget)
        && !GetLocalInt(oItem, "X2_L_NUMCHANNELTRIGGERS"))
        {
            //valid spell, store
            //this uses similar things to the spellsequencer/spellsword/arcanearcher stuff
            effect eVisual = EffectVisualEffect(VFX_IMP_BREACH);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oCaster);
            FloatingTextStringOnCreature("Duskblade Channel spell stored", oCaster);
            //NOTE: I add +1 to the SpellId to spell 0 can be used to trap failure
            int nSID = nSpellID+1;
            int i;
            int nMax = 1;
            int nVal = 1;
            float fDelay = 60.0;
            if(nClass >= 13)
            {
                nMax = 10;
                nVal = 2;
            }
            for(i=1; i<=nMax; i++)
            {
                SetLocalInt(oItem, "X2_L_CHANNELTRIGGER" + IntToString(i)  , nSID);
                SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_L" + IntToString(i), nCasterLevel);
                SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_M" + IntToString(i), nMetamagic);
                SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_D" + IntToString(i), PRCGetSaveDC(oTarget, oCaster));
            }
            SetLocalInt(oItem, "X2_L_NUMCHANNELTRIGGERS", nMax);
            //mark it as discharging
            SetLocalInt(oItem, "DuskbladeChannelDischarge", nVal);
            DelayCommand(fDelay, DuskbladeCleanUp(oItem, nMax));

            itemproperty ipTest = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1);
            IPSafeAddItemProperty(oItem ,ipTest, fDelay);

            //make attack
            ClearAllActions();
            effect eNone;
            if (nClass >= 13) PerformAttackRound(oTarget, oCaster, eNone, 0.0, 0, 0, 0, FALSE, "Arcane Channelling Hit", "Arcane Channelling Miss");
            else if (nClass >= 13) PerformAttack(oTarget, oCaster, eNone, 0.0, 0, 0, 0, "Arcane Channelling Hit", "Arcane Channelling Miss");
            // Target is valid and we know it's an enemy and we're in combat
            DelayCommand(0.25, AssignCommand(oCaster, ActionAttack(oTarget)));
            FloatingTextStringOnCreature("Duskblade Channeling Deactivated", oCaster, FALSE);
            DeleteLocalInt(oCaster, "DuskbladeChannelActive");
            return FALSE;
        }
    }

    return TRUE;
}

//PnP familiar - deliver touch spell
int DeliverTouchSpell(object oCaster, object oTarget, int nSpellID, int nCasterLevel, int nSaveDC, int nMetamagic, object oSpellCastItem)
{
    if(GetPRCSwitch(PRC_PNP_FAMILIARS))
    {
        // Don't channel from objects
        if(oSpellCastItem != OBJECT_INVALID)
            return TRUE;

        if(GetAssociateTypeNPC(oTarget) == ASSOCIATE_TYPE_FAMILIAR && GetMasterNPC(oTarget) == oCaster)
        {
            if(GetHitDice(oTarget) > 2)
            {
                if(!GetLocalInt(oCaster, "PRC_SPELL_HOLD") //holding the charge doesnt work
                && (Get2DACache("spells", "Range", nSpellID) == "T")) //only touch spells
                {
                    //find the item
                    object oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTarget);
                    if(!GetIsObjectValid(oItem)) oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTarget);
                    if(!GetIsObjectValid(oItem)) oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTarget);
                    if(GetIsObjectValid(oItem)
                    && !GetLocalInt(oItem, "X2_L_NUMCHANNELTRIGGERS"))
                    {
                        //valid spell, store
                        //very similar to duskblade chanelling
                        effect eVisual = EffectVisualEffect(VFX_IMP_BREACH);
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget);
                        //NOTE: I add +1 to the SpellId to spell 0 can be used to trap failure
                        int nSID = nSpellID + 1;

                        SetLocalInt(oItem, "X2_L_CHANNELTRIGGER"  , nSID);
                        SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_L", nCasterLevel);
                        SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_M", nMetamagic);
                        SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_D", nSaveDC);
                        SetLocalInt(oItem, "X2_L_NUMCHANNELTRIGGERS", 1);
                        DelayCommand(60.0, DuskbladeCleanUp(oItem, 1));

                        itemproperty ipTest = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1);
                        IPSafeAddItemProperty(oItem, ipTest, 60.0);

                        return FALSE;//don't cast
                    }
                }
            }
        }
    }

    return TRUE;
}

void SpellSharing(object oCaster, object oTarget, int nSpellID, int nCasterLevel, int nSaveDC, int nMetamagic, object oSpellCastItem)
{
    if((Get2DACache("spells", "Range", nSpellID) == "P" || oTarget == oCaster) // Either of these is legal
    && (Get2DACache("prc_spells", "NoShare", nSpellID) != "1")
    && !GetLocalInt(oCaster, "PRC_SPELL_HOLD")     //holding the charge doesnt work
    && !GetLocalInt(oCaster, "SpellIsSLA")   // no spell-like abilities
    && !GetIsObjectValid(oSpellCastItem))     // no item spells
    {
        int bAll = GetPRCSwitch(PRC_ENABLE_SPELL_SHARING);   //enables spell sharing for all compaions (bioware and PnP)
        int bFam = GetPRCSwitch(PRC_PNP_FAMILIARS);          //enables spell sharing only for PnP familiars
        int bComp = GetPRCSwitch(PRC_PNP_ANIMAL_COMPANIONS); //enables spell sharing only for PnP animal companions
        int bBond = GetLevelByClass(CLASS_TYPE_BONDED_SUMMONNER, oCaster);

        location lCaster = GetLocation(oCaster);

        //RADIUS_SIZE_MEDIUM = 10 feet - the source book says it's 5, but that will make it very difficult to use in NWN
        object oComp = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lCaster, TRUE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oComp))
        {
            if(GetMasterNPC(oComp) == oCaster)
            {
                int nType = GetAssociateTypeNPC(oComp);

                if((nType == ASSOCIATE_TYPE_FAMILIAR && (bAll || bFam || bBond))
                || (nType == ASSOCIATE_TYPE_ANIMALCOMPANION && (bAll || bComp))
                || nType == ASSOCIATE_TYPE_CELESTIALCOMPANION
                || oComp == GetLocalObject(oCaster, "oX3PaladinMount"))
                {
                    AssignCommand(oComp, ClearAllActions());
                    AssignCommand(oComp, ActionCastSpell(nSpellID, nCasterLevel, 0, nSaveDC, nMetamagic, CLASS_TYPE_INVALID, FALSE, TRUE, oComp));
                }
            }
            oComp = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lCaster, TRUE, OBJECT_TYPE_CREATURE);
        }
    }
}

void DraconicFeatsOnSpell(object oCaster, object oTarget, object oSpellCastItem, int nSpellLevel, int nCastingClass)
{
    //ensure the spell is arcane
    if(!GetIsArcaneClass(nCastingClass, oCaster))
        return;

    ///////Draconic Vigor////
    if(GetHasFeat(FEAT_DRACONIC_VIGOR, oCaster))
    {
        effect eHeal = EffectHeal(nSpellLevel);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oCaster);
    }

    ///////Draconic Armor////
    if(GetHasFeat(FEAT_DRACONIC_ARMOR, oCaster))
    {
        effect eDamRed = EffectDamageReduction(nSpellLevel, DAMAGE_POWER_PLUS_ONE);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDamRed, oCaster, 6.0f);
    }

    ///////Draconic Persuasion////
    if(GetHasFeat(FEAT_DRACONIC_PERSUADE, oCaster))
    {
        int nBonus = FloatToInt(1.5f * IntToFloat(nSpellLevel));
        effect eCha = EffectSkillIncrease(SKILL_BLUFF, nBonus);
        effect eCha2 = EffectSkillIncrease(SKILL_PERFORM, nBonus);
        effect eCha3 = EffectSkillIncrease(SKILL_INTIMIDATE, nBonus);
        effect eLink = EffectLinkEffects(eCha, eCha2);
               eLink = EffectLinkEffects(eLink, eCha3);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, 6.0f);
    }

    ///////Draconic Presence////
    if(GetHasFeat(FEAT_DRACONIC_PRESENCE, oCaster))
    {
        //set up checks
        object oScare;
        int bCreaturesLeft = TRUE;
        int nNextCreature = 1;

        //set up fear effects
        effect eVis = EffectVisualEffect(VFX_IMP_FEAR_S);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

        effect eLink = EffectLinkEffects(EffectShaken(), eDur);

        int nDC = 10 + nSpellLevel + GetAbilityModifier(ABILITY_CHARISMA, oCaster);
        int nDuration = 6 * nSpellLevel;

        //cycle through creatures within the AoE
        while(bCreaturesLeft)
        {
            oScare = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oCaster, nNextCreature, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);

            if(oScare == OBJECT_INVALID)
                bCreaturesLeft = FALSE;

            if(oScare != oCaster && GetDistanceToObject(oScare) < FeetToMeters(15.0))
            {
                 //dragons are immune, so make sure it's not a dragon
                 if(MyPRCGetRacialType(oScare)!= RACIAL_TYPE_DRAGON)
                 {
                     //Fire cast spell at event for the specified target
                     SignalEvent(oScare, EventSpellCastAt(oCaster, SPELLABILITY_AURA_FEAR));
                     //Make a saving throw check
                     if(!PRCMySavingThrow(SAVING_THROW_WILL, oScare, nDC, SAVING_THROW_TYPE_FEAR) && !GetIsImmune(oScare, IMMUNITY_TYPE_FEAR) && !GetIsImmune(oScare, IMMUNITY_TYPE_MIND_SPELLS))
                     {
                         //Apply the VFX impact and effects
                         ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oScare, RoundsToSeconds(nDuration));
                         ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oScare);
                     }//end will save processing
                 } //end dragon check
                 nNextCreature++;
            }//end target check
            //if no more creatures within range, end it
            else
                bCreaturesLeft = FALSE;
        }//end while
    }

    ///////Draconic Claw////
    if(GetHasFeat(FEAT_DRACONIC_CLAW, oCaster))
    {
        // Clawswipes only work on powers manifested by the Diamond Dragon, not by items he uses.
        if(oSpellCastItem != OBJECT_INVALID)
        {
            FloatingTextStringOnCreature("You do not gain clawswipes from Items.", oCaster, FALSE);
            return;
        }

        //get the proper sized claw
        string sResRef = "prc_claw_1d6m_";
        sResRef += GetAffixForSize(PRCGetCreatureSize(oCaster));
        object oClaw = GetObjectByTag(sResRef);
        effect eInvalid;

        if(TakeSwiftAction(oCaster))
        {
            //grab the closest enemy to swipe at
            oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, oCaster, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
            if(oTarget != oCaster && GetDistanceToObject(oTarget) < FeetToMeters(15.0))
            {
                PerformAttack(oTarget, oCaster, eInvalid, 0.0, 0, 0, DAMAGE_TYPE_SLASHING, "*Clawswipe Hit*", "*Clawswipe Missed*", FALSE, oClaw);
            }
        }
    }
}

void DazzlingIllusion(object oCaster, int nSchool)
{
    // No need for wasting CPU on non-Dazzles
    if(GetHasFeat(FEAT_DAZZLING_ILLUSION, oCaster))
    {
        if(nSchool == SPELL_SCHOOL_ILLUSION)
        {
            effect eLink = EffectLinkEffects(EffectDazzle(), EffectVisualEffect(VFX_IMP_BLINDDEAD_DN_CYAN));
            location lTarget = GetLocation(oCaster);
            object oTarget = MyFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(30.0), lTarget, TRUE, OBJECT_TYPE_CREATURE);
            //Cycle through the targets within the spell shape until an invalid object is captured.
            while(GetIsObjectValid(oTarget))
            {
                if(!GetIsFriend(oTarget, oCaster) && !PRCGetHasEffect(EFFECT_TYPE_BLINDNESS, oTarget))
                {
                    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, 6.0));
                }
                //Select the next target within the spell shape.
                oTarget = MyNextObjectInShape(SHAPE_SPHERE, FeetToMeters(30.0), lTarget, TRUE, OBJECT_TYPE_CREATURE);
            }
        }
    }
}

void EnergyAbjuration(object oCaster, int nSchool, int nSpellLevel)
{
    // No need for wasting CPU on non-Abjures
    if(GetHasFeat(FEAT_ENERGY_ABJURATION, oCaster))
    {
        if(nSchool == SPELL_SCHOOL_ABJURATION)
        {
            int nAmount = (1 + nSpellLevel) * 5;
			
			int nDamageType = DAMAGE_TYPE_ACID | DAMAGE_TYPE_COLD | DAMAGE_TYPE_ELECTRICAL | DAMAGE_TYPE_FIRE | DAMAGE_TYPE_SONIC;

			effect eResist = EffectDamageResistance(nDamageType, nAmount, nAmount);
			
			effect eDur = EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS);
            effect eVfx = EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION);
            effect eEnd = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);			
			
			effect eLink = EffectLinkEffects(eResist, eDur);
				   eLink = EffectLinkEffects(eLink, eEnd);
			
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eVfx, oCaster);			
				   
			
			/*     eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_FIRE, nAmount, nAmount));
                   eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_ACID, nAmount, nAmount));
                   eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_SONIC, nAmount, nAmount));
                   eLink = EffectLinkEffects(eLink, EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, nAmount, nAmount));
                   eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS));
                   eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION));
                   eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE)); */

            if (DEBUG) DoDebug("Energy Abjuration triggered! DR Amount: " + IntToString(nAmount));
			DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oCaster));
        }
    }
}

void InsightfulDivination(object oCaster, int nSchool, int nSpellLevel)
{
    if(GetHasFeat(FEAT_INSIGHTFUL_DIVINATION, oCaster))
    {
        if(nSchool == SPELL_SCHOOL_DIVINATION)
        {
            int nAmount = 1 + nSpellLevel;
            SetLocalInt(oCaster, "InsightfulDivination", nAmount);
        }
    }
}

void TougheningTransmutation(object oCaster, int nSchool)
{
	if (DEBUG) DoDebug("Toughening Transmutation called");

    if(GetHasFeat(FEAT_TOUGHENING_TRANSMUTATION, oCaster))
    {
        if(nSchool == SPELL_SCHOOL_TRANSMUTATION)
        {
			effect eDR = EffectDamageReduction(5, DAMAGE_POWER_PLUS_ONE);
			
			if (DEBUG) DoDebug("School Detected: " + IntToString(nSchool));
            DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDR, oCaster, 7.0));
        }
    }
	else
	{
		if (DEBUG) DoDebug("You do not have the Toughening Transmutation feat.");
	}
}

void CloudyConjuration(object oCaster, int nSchool, object oSpellCastItem)
{
    if(GetHasFeat(FEAT_CLOUDY_CONJURATION, oCaster) && !GetIsObjectValid(oSpellCastItem)) // Doesn't work on spells cast from items.
    {
        if(nSchool == SPELL_SCHOOL_CONJURATION)
        {
			effect eAOE = EffectAreaOfEffect(VFX_MOB_CLOUDY_CONJURATION);
            DelayCommand(0.0, ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, PRCGetSpellTargetLocation(), 6.0));
        }
    }
}

//ebonfowl: runs the reserve feat script
void OnePingOnly(object oCaster)
{
    //Only works if you have a reserve feat
    if(GetLocalInt(oCaster, "ReserveFeatsRunning") == TRUE)
    {
        DelayCommand(1.0, ExecuteScript("prc_reservefeat", oCaster));
    }
}

//ebonfowl: runs the damage backlash for Mystic Backlash
void MysticBacklash(object oCaster)
{
    int nDamage = GetLocalInt(oCaster, "DoMysticBacklash");
    effect eBacklash = EffectDamage(nDamage, DAMAGE_TYPE_MAGICAL);
           eBacklash = SupernaturalEffect(eBacklash);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eBacklash, oCaster);
}

//spellweave affects only one target, mark it here
void EldritchSpellweave(object oCaster, object oTarget, int nSpellLevel, int bSpellIsHostile)
{
    if(GetLocalInt(oCaster, "INV_SPELLWEAVE"))
    {
        //we need a valid target
        if(!GetIsObjectValid(oTarget))
            return;

        //hostile spell
        if(!GetIsEnemy(oTarget, oCaster))
            return;

        //and active blast essence
        if(!GetLocalInt(oCaster, "BlastEssence")
        || GetLocalInt(oCaster, "BlastEssence") == INVOKE_CORRUPTING_BLAST)
            return;

        //final test: spell level >= essence level
        if(nSpellLevel >= (GetLocalInt(oCaster, "EssenceData") & 0xF))
        {
            //everything is OK, mark the target for eldritch spellweave
            SetLocalObject(oCaster, "SPELLWEAVE_TARGET", oTarget);
            DeleteLocalInt(oCaster, "INV_SPELLWEAVE");
        }
        else
            SendMessageToPC(oCaster, "Eldritch Spellweave: The level of this spell is too low to use with current blast essence.");
    }
}

//:: Returns True if oPC has a Secondary PrC that should prevent them from using 
//:: the Bioware spellbook as a Sublime Chord
int CheckSecondaryPrC(object oPC = OBJECT_SELF)
{
	if(DEBUG) DoDebug("x2_inc_spellhook: CheckSecondaryPrC >>> Starting", oPC);
	
	int bBard 		= GetLevelByClass(CLASS_TYPE_BARD, oPC);
	int bBeguiler 	= GetLevelByClass(CLASS_TYPE_BEGUILER, oPC);
	int bDuskblade 	= GetLevelByClass(CLASS_TYPE_DUSKBLADE, oPC);
	int bSorcerer 	= GetLevelByClass(CLASS_TYPE_SORCERER, oPC);
	int bWarmage 	= GetLevelByClass(CLASS_TYPE_WARMAGE, oPC);
	
	int nRace		= GetRacialType(oPC);
	
	if (bBard)
	{
		if(DEBUG) DoDebug("x2_inc_spellhook: CheckSecondaryPrC >>> Entering Bard", oPC);
		if (GetHasFeat(FEAT_FEY_SPELLCASTING_GLOURA)) return TRUE;
		if (GetHasFeat(FEAT_ABCHAMP_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_AOTS_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ALCHEM_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ALIENIST_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ANIMA_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ARCTRICK_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ASMODEUS_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_BSINGER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_BLDMAGUS_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_CMANCER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_DIABOLIST_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_DHEART_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_DSONG_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_EKNIGHT_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ENLIGHTENEDFIST_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ELESAVANT_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ETHEURGE_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_FOCHLUCAN_LYRIST_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_FROSTMAGE_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_GRAZZT_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_HARPERM_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_HATHRAN_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_HAVOC_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_JPM_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_JUDICATOR_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_MAESTER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_MAGEKILLER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_MHARPER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_MYSTIC_THEURGE_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_NOCTUMANCER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_OOZEMASTER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_PALEMASTER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_RAGEMAGE_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_SHADOWADEPT_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_SOULCASTER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_SPELLDANCER_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_SSWORD_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_TIAMAT_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_ULTMAGUS_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_UNSEEN_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_VIRTUOSO_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_WILDMAGE_SPELLCASTING_BARD)) return TRUE;
		if (GetHasFeat(FEAT_WWOC_SPELLCASTING_BARD)) return TRUE;	
	}
	if (bBeguiler)
	{
		if(DEBUG) DoDebug("x2_inc_spellhook: CheckSecondaryPrC >>> Entering Beguiler", oPC);
		if (GetHasFeat(FEAT_ABCHAMP_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_AOTS_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ALCHEM_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ALIENIST_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ANIMA_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ARCHMAGE_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ARCTRICK_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ASMODEUS_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_BSINGER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_BLDMAGUS_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_CMANCER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_DIABOLIST_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_DHEART_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_DSONG_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_EKNIGHT_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ENLIGHTENEDFIST_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ELESAVANT_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ETHEURGE_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_FOCHLUCAN_LYRIST_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_FROSTMAGE_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_GRAZZT_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_HARPERM_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_HATHRAN_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_HAVOC_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_JPM_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_JUDICATOR_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_MAESTER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_MAGEKILLER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_MHARPER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_MYSTIC_THEURGE_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_NOCTUMANCER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_OOZEMASTER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_PALEMASTER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_RAGEMAGE_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_SHADOWADEPT_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_SOULCASTER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_SPELLDANCER_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_SSWORD_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_TIAMAT_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_ULTMAGUS_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_UNSEEN_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_VIRTUOSO_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_WILDMAGE_SPELLCASTING_BEGUILER)) return TRUE;
		if (GetHasFeat(FEAT_WWOC_SPELLCASTING_BEGUILER)) return TRUE;	
	}
	if (bDuskblade)
	{
		if(DEBUG) DoDebug("x2_inc_spellhook: CheckSecondaryPrC >>> Entering Dusblade", oPC);
		if (GetHasFeat(FEAT_ABCHAMP_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_AOTS_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_ALCHEM_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_ANIMA_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_ARCTRICK_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_ASMODEUS_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_BSINGER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_BLDMAGUS_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_CMANCER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_DHEART_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_DIABOLIST_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_DSONG_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_EKNIGHT_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_ENLIGHTENEDFIST_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_ELESAVANT_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_ETHEURGE_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_FOCHLUCAN_LYRIST_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_FROSTMAGE_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_GRAZZT_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_HARPERM_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_HATHRAN_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_HAVOC_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_JPM_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_JUDICATOR_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_MAESTER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_MAGEKILLER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_MHARPER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_MYSTIC_THEURGE_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_NOCTUMANCER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_OOZEMASTER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_PALEMASTER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_RAGEMAGE_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_SHADOWADEPT_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_SOULCASTER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_SPELLDANCER_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_SSWORD_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_TIAMAT_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_TNECRO_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_ULTMAGUS_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_UNSEEN_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_VIRTUOSO_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_WILDMAGE_SPELLCASTING_DUSKBLADE)) return TRUE;
		if (GetHasFeat(FEAT_WWOC_SPELLCASTING_DUSKBLADE)) return TRUE;		
	}
	if (bSorcerer)
	{
		if(DEBUG) DoDebug("x2_inc_spellhook: CheckSecondaryPrC >>> Entering Sorcerer", oPC);
		if (GetHasFeat(FEAT_ABERRATION_SPELLCASTING_DRIDER)) return TRUE;
		if (GetHasFeat(FEAT_MONSTROUS_SPELLCASTING_ARKAMOI)) return TRUE;
		if (GetHasFeat(FEAT_MONSTROUS_SPELLCASTING_MARRUTACT)) return TRUE;
		if (GetHasFeat(FEAT_MONSTROUS_SPELLCASTING_REDSPAWN_ARCANISS)) return TRUE;
		if (GetHasFeat(FEAT_OUTSIDER_SPELLCASTING_RAKSHASA)) return TRUE;
		if (GetHasFeat(FEAT_SHAPECHANGER_SPELLCASTING_ARANEA)) return TRUE;
		if (GetHasFeat(FEAT_ABCHAMP_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_AOTS_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ALCHEM_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ALIENIST_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ANIMA_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ARCHMAGE_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ARCTRICK_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ASMODEUS_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_BSINGER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_BLDMAGUS_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_BONDED_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_CMANCER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_DIABOLIST_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_DHEART_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_DSONG_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_EKNIGHT_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ENLIGHTENEDFIST_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ELESAVANT_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ETHEURGE_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_FMM_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_FOCHLUCAN_LYRIST_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_FROSTMAGE_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_GRAZZT_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_HARPERM_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_HATHRAN_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_HAVOC_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_JPM_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_JUDICATOR_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_MAESTER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_MAGEKILLER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_MHARPER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_MYSTIC_THEURGE_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_NOCTUMANCER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_OOZEMASTER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_PALEMASTER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_RAGEMAGE_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_SHADOWADEPT_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_SOULCASTER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_SPELLDANCER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_SSWORD_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_TIAMAT_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_TNECRO_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_ULTMAGUS_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_UNSEEN_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_VIRTUOSO_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_WAYFARER_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_WILDMAGE_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_WWOC_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_WILDMAGE_SPELLCASTING_SORCERER)) return TRUE;
		if (GetHasFeat(FEAT_WWOC_SPELLCASTING_SORCERER)) return TRUE;			
	}
	if (bWarmage)
	{
		if(DEBUG) DoDebug("x2_inc_spellhook: CheckSecondaryPrC >>> Entering Warmage", oPC);
		if (GetHasFeat(FEAT_AOTS_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ALCHEM_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ANIMA_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ARCHMAGE_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ARCTRICK_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ASMODEUS_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_BSINGER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_BLDMAGUS_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_BONDED_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_CMANCER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_DIABOLIST_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_DHEART_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_DSONG_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_EKNIGHT_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ENLIGHTENEDFIST_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ELESAVANT_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ETHEURGE_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_FMM_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_FROSTMAGE_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_FOCHLUCAN_LYRIST_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_GRAZZT_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_HARPERM_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_HATHRAN_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_HAVOC_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_JPM_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_JUDICATOR_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_MAESTER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_MAGEKILLER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_MHARPER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_MYSTIC_THEURGE_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_NOCTUMANCER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_OOZEMASTER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_PALEMASTER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_RAGEMAGE_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_SHADOWADEPT_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_SOULCASTER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_SPELLDANCER_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_SSWORD_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_TIAMAT_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_ULTMAGUS_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_UNSEEN_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_VIRTUOSO_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_WILDMAGE_SPELLCASTING_WARMAGE)) return TRUE;
		if (GetHasFeat(FEAT_WWOC_SPELLCASTING_WARMAGE)) return TRUE;
	}
		return FALSE;
}

int BardSorcPrCCheck(object oCaster, int nCastingClass, object oSpellCastItem)
{
    // If it's an item, get the hell out of here
    if (GetIsObjectValid(oSpellCastItem))
        return TRUE;

    // Eldritch Spellblast was breaking otherwise        
    if (GetLocalInt(oCaster, "EldritchSpellBlast"))
	{
		if(DEBUG) DoDebug("x2_inc_spellhook >> EldritchSpellBlast Found");		
        return TRUE;    
	}

    //check its a sorcerer spell
    if(nCastingClass == CLASS_TYPE_SORCERER)
    {
        if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> nCastingClass is Sorcerer.", oCaster);
		//no need to check further if new spellbooks are disabled
        if(GetPRCSwitch(PRC_SORC_DISALLOW_NEWSPELLBOOK))
		{
            if (DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> PRC_SORC_DISALLOW_NEWSPELLBOOK.", oCaster);
			return TRUE;
		}
        //check they have sorcerer levels
        if(!GetLevelByClass(CLASS_TYPE_SORCERER, oCaster))
		{
            if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Not a sorcerer.", oCaster);
			return TRUE;
		}
        //check if they are casting via new spellbook
        if(GetLocalInt(oCaster, "NSB_Class") != CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_ULTIMATE_MAGUS, oCaster))
		{
            if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> UltMagus using new spellbook.", oCaster);
			return FALSE;   		
		}
        //check if they are casting via new spellbook
        if(GetLocalInt(oCaster, "NSB_Class") == CLASS_TYPE_SORCERER)
 		{
            if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Using new spellbook.", oCaster);
			return TRUE;
		}
		if(GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oCaster) > 0 && CheckSecondaryPrC(oCaster) == TRUE)
		{
			if (DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Sublime Chord w/RHD found.", oCaster);
			FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
			return FALSE;
		}
		if (CheckSecondaryPrC(oCaster) == TRUE)
		{
			if (DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Sorcerer w/RHD found.", oCaster);
			FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
			return FALSE;
		}	        
		//check they have arcane PrC or Draconic Arcane Grace/Breath
        if(!(GetArcanePRCLevels(oCaster, nCastingClass) - GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oCaster))
          && !(GetHasFeat(FEAT_DRACONIC_GRACE, oCaster) || GetHasFeat(FEAT_DRACONIC_BREATH, oCaster)))
 		{
            if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> First Sublime Chord check.", oCaster);
			return TRUE;
		}
					
        //check they have sorcerer in first arcane slot
        //if(GetPrimaryArcaneClass() != CLASS_TYPE_SORCERER)
        if(GetPrCAdjustedCasterLevelByType(TYPE_ARCANE, oCaster, TRUE) != GetPrCAdjustedCasterLevelByType(CLASS_TYPE_SORCERER, oCaster, TRUE))
		{
			if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> GetPrCAdjustedCasterLevelByType.", oCaster);
			return TRUE;
		}
        //at this point, they must be using the bioware spellbook
        //from a class that adds to bard
        FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
        return FALSE;
    }


/*     //check its a sorc spell
    if(nCastingClass == CLASS_TYPE_SORCERER)
    {
		//no need to check further if new spellbooks are disabled
        if(GetPRCSwitch(PRC_SORC_DISALLOW_NEWSPELLBOOK))
            return TRUE;
        //check they have sorc levels
        if(!GetLevelByClass(CLASS_TYPE_SORCERER, oCaster))
            return TRUE;     
        //check if they are casting via new spellbook
        if(GetLocalInt(oCaster, "NSB_Class") != CLASS_TYPE_SORCERER && GetLevelByClass(CLASS_TYPE_ULTIMATE_MAGUS, oCaster))
            return FALSE;            
        //check if they are casting via new spellbook
        if(GetLocalInt(oCaster, "NSB_Class") == CLASS_TYPE_SORCERER)
            return TRUE;
		if(GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oCaster) > 0 && CheckSecondaryPrC(oCaster) == TRUE)
		{
			if (DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Sublime Chord w/RHD found.", oCaster);
			FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
			return FALSE;
		}
		if (CheckSecondaryPrC(oCaster) == TRUE)
		{
			if (DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Sorcerer w/RHD found.", oCaster);
			FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
			return FALSE;
		}			
        //check they have arcane PrC or Draconic Arcane Grace/Breath
        if(!(GetArcanePRCLevels(oCaster, nCastingClass) - GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oCaster))
          && !(GetHasFeat(FEAT_DRACONIC_GRACE, oCaster) || GetHasFeat(FEAT_DRACONIC_BREATH, oCaster)))
            return TRUE;

        //check they have sorc in first arcane slot
        //if(GetPrimaryArcaneClass() != CLASS_TYPE_SORCERER)
        if(GetPrCAdjustedCasterLevelByType(TYPE_ARCANE, oCaster, TRUE) != GetPrCAdjustedCasterLevel(CLASS_TYPE_SORCERER, oCaster, TRUE))
            return TRUE;

        //at this point, they must be using the bioware spellbook
        //from a class that adds to sorc
        FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
        return FALSE;
    } */

    //check its a bard spell
    if(nCastingClass == CLASS_TYPE_BARD)
    {
        if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> nCastingClass is Bard.", oCaster);
		//no need to check further if new spellbooks are disabled
        if(GetPRCSwitch(PRC_BARD_DISALLOW_NEWSPELLBOOK))
		{
            if (DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> PRC_BARD_DISALLOW_NEWSPELLBOOK.", oCaster);
			return TRUE;
		}
        //check they have bard levels
        if(!GetLevelByClass(CLASS_TYPE_BARD, oCaster))
		{
            if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Not a bard.", oCaster);
			return TRUE;
		}
        //check if they are casting via new spellbook
        if(GetLocalInt(oCaster, "NSB_Class") == CLASS_TYPE_BARD)
 		{
            if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Using new spellbook.", oCaster);
			return TRUE;
		}
		if(GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oCaster) > 0 && CheckSecondaryPrC(oCaster) == TRUE)
		{
			if (DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Sublime Chord w/RHD found.", oCaster);
			FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
			return FALSE;
		}
		if (CheckSecondaryPrC(oCaster) == TRUE)
		{
			if (DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Bard w/RHD found.", oCaster);
			FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
			return FALSE;
		}	        
		//check they have arcane PrC or Draconic Arcane Grace/Breath
        if(!(GetArcanePRCLevels(oCaster, nCastingClass) - GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oCaster))
          && !(GetHasFeat(FEAT_DRACONIC_GRACE, oCaster) || GetHasFeat(FEAT_DRACONIC_BREATH, oCaster)))
 		{
            if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> First Sublime Chord check.", oCaster);
			return TRUE;
		}
					
        //check they have bard in first arcane slot
        //if(GetPrimaryArcaneClass() != CLASS_TYPE_BARD)
        if(GetPrCAdjustedCasterLevelByType(TYPE_ARCANE, oCaster, TRUE) != GetPrCAdjustedCasterLevelByType(CLASS_TYPE_BARD, oCaster, TRUE))
		{
			if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> GetPrCAdjustedCasterLevelByType.", oCaster);
			return TRUE;
		}
        //at this point, they must be using the bioware spellbook
        //from a class that adds to bard
        FloatingTextStringOnCreature("You must use the new spellbook on the class radial.", oCaster, FALSE);
        return FALSE;
    }

    if(DEBUG) DoDebug("x2_inc_spellhook: BardSorcPrCCheck >>> Returning TRUE.", oCaster);
	return TRUE;
}


int KOTCHeavenDevotion(object oCaster, object oTarget, int nCasterAlignment, int nSpellSchool)
{
    if(GetLevelByClass(CLASS_TYPE_KNIGHT_CHALICE, oTarget) >= 5)
    {
        if(MyPRCGetRacialType(oCaster) == RACIAL_TYPE_OUTSIDER)
        {
            if(nCasterAlignment == ALIGNMENT_EVIL)
            {
                if(nSpellSchool == SPELL_SCHOOL_ENCHANTMENT)
                {
                    return FALSE;
                }
            }
        }
    }
    return TRUE;
}

void CombatMedicHealingKicker(object oCaster, object oTarget, int nSpellID)
{
    int nLevel = GetLevelByClass(CLASS_TYPE_COMBAT_MEDIC, oCaster);
    int nKicker = GetLocalInt(oCaster, "Heal_Kicker");

    if(!nLevel || !nKicker || oTarget == oCaster) //Cannot use on self
        return;

    if(!GetIsOfSubschool(nSpellID, SUBSCHOOL_HEALING)) //If the spell that was just cast isn't healing, stop now
        return;

    //Three if/elseif statements. They check which of the healing kickers we use.
    //If no Healing Kicker localints are set, this if block should be ignored.
    int bRemoveUses;
    if(nKicker == 1)
    {
        /* Sanctuary effect, with special DC and 1 round duration
         * Script stuff taken from the spell by the same name
         */
        int nDC = 15 + nLevel + GetAbilityModifier(ABILITY_WISDOM, oCaster);
        effect eLink = EffectLinkEffects(EffectVisualEffect(VFX_DUR_SANCTUARY), EffectSanctuary(nDC));

        //Apply the Sanctuary VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, 6.0);

        bRemoveUses = TRUE;
    }
    else if(nKicker == 2)
    {
        /* Reflex save increase, 1 round duration
         */
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HASTE), oTarget);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSavingThrowIncrease(SAVING_THROW_REFLEX, nLevel), oTarget, 6.0);

        bRemoveUses = TRUE;
    }
    else if(nKicker == 3)
    {
        /* Aid effect, with special HP bonus and 1 minute duration
         * Script stuff taken from the spell by the same name
         */
        int nBonus = 8 + nLevel;
        effect eLink = EffectLinkEffects(EffectAttackIncrease(1),
                       EffectSavingThrowIncrease(SAVING_THROW_ALL, 1, SAVING_THROW_TYPE_FEAR));

        //Apply the Aid VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HOLY_AID), oTarget);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, 60.0);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectTemporaryHitpoints(nBonus), oTarget, 60.0);

        bRemoveUses = TRUE;
    }

    if(bRemoveUses)
    {
        DeleteLocalInt(oCaster, "Heal_Kicker");
        DecrementRemainingFeatUses(oCaster, FEAT_HEALING_KICKER_1);
        DecrementRemainingFeatUses(oCaster, FEAT_HEALING_KICKER_2);
        DecrementRemainingFeatUses(oCaster, FEAT_HEALING_KICKER_3);
    }
}

// Performs the attack portion of the battlecast ability for the havoc mage
void Battlecast(object oCaster, object oTarget, object oSpellCastItem, int nSpellLevel)
{
    int nLevel = GetLevelByClass(CLASS_TYPE_HAVOC_MAGE, oCaster);

    // If battlecast is turned off, exit
    if(!nLevel || !GetLocalInt(oCaster, "HavocMageBattlecast"))
        return;

    // Battlecast only works on spells cast by the Havoc Mage, not by items he uses.
    if(oSpellCastItem != OBJECT_INVALID)
    {
        FloatingTextStringOnCreature("You do not gain Battlecast from Items.", oCaster, FALSE);
        return;
    }

    //if its not being cast on a hostile target or its at a location
    //get the nearest living seen hostile insead
    if(!spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster)
    || !GetIsObjectValid(oTarget))
    {
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oCaster, 1,
            CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
            CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
    }

    effect eVis = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY);

    // Don't want to smack allies upside the head when casting a spell.
    if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster)
    && oTarget != oCaster
    && GetDistanceToObject(oTarget) < FeetToMeters(15.0))
    {
        // Make sure the levels are right for both the caster and the spells.
        // Level 8 spells and under at level 5
        // Level 4 spells and under at level 3
        // Level 2 spells and under at level 1
        if((nLevel == 5 && 9 > nSpellLevel)
        || (nLevel >  2 && 5 > nSpellLevel)
        || (nLevel >  0 && 3 > nSpellLevel))
            PerformAttack(oTarget, oCaster, eVis, 0.0, 0, 0, 0, "*Battlecast Hit*", "*Battlecast Missed*");
    }
}


//Archmage and Heirophant SLA slection/storage setting
int ClassSLAStore(object oCaster, int nSpellID, int nCastingClass, int nSpellLevel)
{
    int nSLAID = GetLocalInt(oCaster, "PRC_SLA_Store");
    if(nSLAID)
    {
        FloatingTextStringOnCreature("SLA "+IntToString(nSLAID)+" stored", oCaster, FALSE);
        int nMetamagic = GetMetaMagicFeat();
		
        // Look up spell level if invalid (radial spells)
        if(nSpellLevel < 0 || nSpellLevel >= 10)
        {
            string sInnateLevel = Get2DACache("spells", "Innate", nSpellID);
            nSpellLevel = StringToInt(sInnateLevel);
        }
		
        SetPersistantLocalInt(oCaster, "PRC_SLA_SpellID_"+IntToString(nSLAID), nSpellID+1);
        SetPersistantLocalInt(oCaster, "PRC_SLA_Class_"+IntToString(nSLAID), nCastingClass);
        SetPersistantLocalInt(oCaster, "PRC_SLA_Meta_"+IntToString(nSLAID), nMetamagic);

        if(nMetamagic & METAMAGIC_QUICKEN)  nSpellLevel += 4;
        if(nMetamagic & METAMAGIC_STILL)    nSpellLevel += 1;
        if(nMetamagic & METAMAGIC_SILENT)   nSpellLevel += 1;
        if(nMetamagic & METAMAGIC_MAXIMIZE) nSpellLevel += 3;
        if(nMetamagic & METAMAGIC_EMPOWER)  nSpellLevel += 2;
        if(nMetamagic & METAMAGIC_EXTEND)   nSpellLevel += 1;

        int nUses = 1;
        switch(nSpellLevel)
        {
            default:
            case 9:
            case 8: nUses = 1; break;
            case 7:
            case 6: nUses = 2; break;
            case 5:
            case 4: nUses = 3; break;
            case 3:
            case 2: nUses = 4; break;
            case 1:
            case 0: nUses = 5; break;
        }
        SetPersistantLocalInt(oCaster, "PRC_SLA_Uses_"+IntToString(nSLAID), nUses);
        DeleteLocalInt(oCaster, "PRC_SLA_Store");
        return FALSE;
    }
    return TRUE;
}

int PnPSomaticComponents(object oCaster, object oSpellCastItem, string sComponent, int nMetamagic)
{
    if(GetPRCSwitch(PRC_PNP_SOMATIC_COMPOMENTS) || GetPRCSwitch(PRC_PNP_SOMATIC_ITEMS))
    {
        object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCaster);
        int nHandFree;
        if(!GetIsObjectValid(oItem) || GetBaseItemType(oItem) == BASE_ITEM_SMALLSHIELD || GetBaseItemType(oItem) == BASE_ITEM_MAGICWAND || GetBaseItemType(oItem) == BASE_ITEM_ENCHANTED_WAND)
            nHandFree = TRUE;
        oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster);            
        if(!GetIsObjectValid(oItem) || GetBaseItemType(oItem) == BASE_ITEM_SMALLSHIELD || GetBaseItemType(oItem) == BASE_ITEM_MAGICWAND || GetBaseItemType(oItem) == BASE_ITEM_ENCHANTED_WAND)
            nHandFree = TRUE;  
        if(GetHasFeat(FEAT_SOMATIC_WEAPONRY, oCaster))            
            nHandFree = TRUE;  
		if(nMetamagic & METAMAGIC_STILL)            
            nHandFree = TRUE; 

        if(!nHandFree)
        {
            int nHandRequired;
            oItem = oSpellCastItem;
            //check item is not equiped
            if(GetIsObjectValid(oItem) && GetPRCSwitch(PRC_PNP_SOMATIC_ITEMS))
            {
                nHandRequired = TRUE;
                int nSlot;
                for(nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; nSlot++)
                {
                    if(GetItemInSlot(nSlot, oCaster) == oItem)
                        nHandRequired = FALSE;
                }
            }
            //check its a real spell and that it requires a free hand
            if(!GetIsObjectValid(oItem) && GetPRCSwitch(PRC_PNP_SOMATIC_COMPOMENTS))
            {
                if(sComponent == "VS"
                || sComponent == "SV"
                || sComponent == "S")
                    nHandRequired = TRUE;
            }

            if(nHandRequired)
            {
                FloatingTextStringOnCreature("You do not have any free hands.", oCaster, FALSE);
                // Items were being consumed anyway. This should stop it.
                AssignCommand(oItem, SetIsDestroyable(FALSE, FALSE, FALSE));
                AssignCommand(oItem, DelayCommand(0.3, SetIsDestroyable(TRUE, FALSE, FALSE)));                
                return FALSE;
            }
        }
    }

    return TRUE;
}

int PRCSpellEffects(object oCaster, object oTarget, int nSpellID, int nSpellLevel, int nCastingClass, int bSpellIsHostile, int nMetamagic)
{
    // Pnp Tensers Transformation
    if(GetPRCSwitch(PRC_PNP_TENSERS_TRANSFORMATION))
	{
        if(GetHasSpellEffect(SPELL_TENSERS_TRANSFORMATION, oCaster))  
        {  
            // Allow potions - they are not spell trigger/completion items  
            object oSpellCastItem = PRCGetSpellCastItem();  
            if(GetIsObjectValid(oSpellCastItem))  
            {  
                int nItemType = GetBaseItemType(oSpellCastItem);  
                if(nItemType == BASE_ITEM_ENCHANTED_POTION  
                || nItemType == BASE_ITEM_POTIONS)  
                {  
                    // Continue with other checks  
                }  
                else  
                {  
                    return FALSE; // Block other magic items  
                }  
            }  
            else  
            {  
                return FALSE; // Block regular spellcasting  
            }  
        }
	}  		
/*     {
        if(GetHasSpellEffect(SPELL_TENSERS_TRANSFORMATION, oCaster))
            return FALSE;
    } */
	
    
    // Gaseous Form check
    if(GetHasSpellEffect(SPELL_GASEOUS_FORM, oCaster))
    {
    	if(nMetamagic & METAMAGIC_STILL && nMetamagic & METAMAGIC_SILENT)
    	{
    	}
    	else if(GetIsDivineClass(nCastingClass, oCaster) || GetIsArcaneClass(nCastingClass, oCaster))
	    	return FALSE;
    }    

    // Violet Rain check
    if(GetHasSpellEffect(SPELL_EVIL_WEATHER_VIOLET_RAIN, oCaster))
    {
        if(GetIsDivineClass(nCastingClass, oCaster))
            return FALSE;
    }

    // PnP Timestop
    if(GetPRCSwitch(PRC_TIMESTOP_NO_HOSTILE))
    {
        if(GetHasSpellEffect(SPELL_TIME_STOP, oCaster)
        || GetHasSpellEffect(4032, oCaster)          //epic spell: Greater Timestop
        || GetHasSpellEffect(14236, oCaster)         //psionic power: Temporal Acceleration
        || GetHasSpellEffect(18428, oCaster))        //Mystery MYST_SHADOW_TIME
        {
            if(!GetIsObjectValid(oTarget)
            || oTarget != oCaster
            || bSpellIsHostile)
            {
                return FALSE;
            }
        }
    }

    // Spell Barriers
    if(GetHasSpellEffect(SPELL_OTILUKES_RESILIENT_SPHERE, oTarget))
    {
        if(GetDistanceBetween(oCaster, oTarget) > 1.524)
        {
            return FALSE;
        }
    }
    if(GetHasSpellEffect(SPELL_PRISMATIC_SPHERE, oTarget))
    {
        if(GetDistanceBetween(oCaster, oTarget) > 3.048)
        {
            return FALSE;
        }
    }

    // Null Psionics Field/Anti-Magic Field
    if(GetHasSpellEffect(SPELL_ANTIMAGIC_FIELD, oCaster)
    || GetHasSpellEffect(POWER_NULL_PSIONICS_FIELD, oCaster))
    {
         return FALSE;
    }

    // Scrying blocks all powers except for a few special case ones.
    int nScry = GetLocalInt(oCaster, "ScrySpellId");
    if(nScry)
    {
        if(nScry == SPELL_GREATER_SCRYING || nScry == 18415) // MYST_FAR_SIGHT
        {
            if(nSpellID != SPELL_DETECT_EVIL
            && nSpellID != SPELL_DETECT_GOOD
            && nSpellID != SPELL_DETECT_LAW
            && nSpellID != SPELL_DETECT_CHAOS)
                return FALSE;
        }
        if(nScry == POWER_CLAIRTANGENT_HAND)
        {
            if(nSpellID != POWER_FARHAND)
                return FALSE;
        }
        if(nScry == 18410) // MYST_EPHEMERAL_IMAGE
            return TRUE; // Can cast anything through this one.
            
        // By default you can't cast anything while scrying    
        return FALSE;    
    }

    // Word of Peace
    if(GetLocalInt(oCaster, "TrueWardOfPeace") && bSpellIsHostile)
    {
        return FALSE;
    }

    // Dark Discorporation Check
    if(GetLocalInt(oCaster, "DarkDiscorporation"))
    {
        return FALSE;
    }

    // Ectoplasmic Shambler
    if(GetLocalInt(oCaster, "PRC_IsInEctoplasmicShambler"))
    {
        if(!GetIsSkillSuccessful(oCaster, SKILL_CONCENTRATION, (15 + nSpellLevel)))
        {
            FloatingTextStrRefOnCreature(16824061, oCaster, FALSE); // "Ectoplasmic Shambler has disrupted your concentration."
            return FALSE;
        }
    }

    // Jarring Song
    if(GetHasSpellEffect(SPELL_VIRTUOSO_JARRING_SONG, oCaster))
    {
        if(!GetIsSkillSuccessful(oCaster, SKILL_CONCENTRATION, (15 + nSpellLevel)))
        {
            FloatingTextStringOnCreature("Jarring Song has disrupted your concentration.", oCaster, FALSE);
            return FALSE;
        }
    }
    
    //Aura of the Sun - shadow spells make check or fail
    if(GetHasSpellEffect(SPELL_AURA_OF_THE_SUN))
    {    	
    	if(GetIsOfSubschool(nSpellID, SUBSCHOOL_SHADOW) || GetHasDescriptor(nSpellID, DESCRIPTOR_DARKNESS))
    	{
    		int nDC = GetLocalInt(oCaster, "PRCAuraSunDC");
    		int nCheck = d20(1) + PRCGetCasterLevel(oCaster);
    		
    		//caster level check
    		if(nCheck < nDC) return FALSE;
    	}
    }
    return TRUE;
}

int Spellfire(object oCaster, object oTarget)
{
    if(GetHasFeat(FEAT_SPELLFIRE_WIELDER, oCaster))
    {
        int nStored = GetPersistantLocalInt(oCaster, "SpellfireLevelStored");
        int nCON = GetAbilityScore(oCaster, ABILITY_CONSTITUTION);
        int nTest = nStored > 4 * nCON ? 25 : nStored > 3 * nCON ? 20 : 0;
        if(nTest)
        {
            if(!GetIsSkillSuccessful(oCaster, SKILL_CONCENTRATION, nTest))
                return FALSE;
        }
    }
    if(GetLocalInt(oTarget, "SpellfireAbsorbFriendly") && GetIsFriend(oTarget, oCaster))
    {
        if(CheckSpellfire(oCaster, oTarget, TRUE))
        {
            PRCShowSpellResist(oCaster, oTarget, SPELL_RESIST_MANTLE);
            return FALSE;
        }
    }

    return TRUE;
}

int Wildstrike(object oCaster)
{
    // 50% chance
    if(GetLocalInt(oCaster, "WildMageStrike") && d2() == 2)
    {
        AssignCommand(oCaster, ClearAllActions());
        AssignCommand(oCaster, ActionCastSpell(499));
        return FALSE;
    }

    return TRUE;
}

int CorruptOrSanctified(object oCaster, int nSpellID, int nCasterAlignment, int nSpellbookType)
{
    //Check for each Corrupt and Sanctified spell
    int bCorruptOrSanctified = 0;

    if(nSpellID == SPELL_AYAILLAS_RADIANT_BURST
    || nSpellID == SPELL_BRILLIANT_EMANATION
    || nSpellID == SPELL_DIVINE_INSPIRATION
    || nSpellID == SPELL_DIAMOND_SPRAY
    || nSpellID == SPELL_DRAGON_CLOUD
    || nSpellID == SPELL_EXALTED_FURY
    || nSpellID == SPELL_HAMMER_OF_RIGHTEOUSNESS
    || nSpellID == SPELL_PHIERANS_RESOLVE
    || nSpellID == SPELL_PHOENIX_FIRE
    || nSpellID == SPELL_RAIN_OF_EMBERS
    || nSpellID == SPELL_SICKEN_EVIL
    || nSpellID == SPELL_STORM_OF_SHARDS
    || nSpellID == SPELL_SUNMANTLE
    || nSpellID == SPELL_TWILIGHT_LUCK)
        bCorruptOrSanctified = 1;

    else if(nSpellID == SPELL_ABSORB_STRENGTH
    || nSpellID == SPELL_APOCALYPSE_FROM_THE_SKY
    || nSpellID == SPELL_CLAWS_OF_THE_BEBILITH
    || nSpellID == SPELL_DEATH_BY_THORNS
    || nSpellID == SPELL_EVIL_WEATHER
    || nSpellID == SPELL_FANGS_OF_THE_VAMPIRE_KING
    || nSpellID == SPELL_LAHMS_FINGER_DARTS
    || nSpellID == SPELL_POWER_LEECH
    || nSpellID == SPELL_RAPTURE_OF_RUPTURE
    || nSpellID == SPELL_RED_FESTER
    || nSpellID == SPELL_ROTTING_CURSE_OF_URFESTRA
    || nSpellID == SPELL_SEETHING_EYEBANE
    || nSpellID == SPELL_TOUCH_OF_JUIBLEX)
        bCorruptOrSanctified = 2;

    if(bCorruptOrSanctified)
    {
        // check if the caster is a spontaneous caster
        if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
        {
            SendMessageToPC(oCaster, "Spontaneous casters cannot cast this spell!");
            return FALSE;
        }
        //check for immunity to ability damage - sorry undead buddies
        if(GetIsImmune(oCaster, IMMUNITY_TYPE_ABILITY_DECREASE))
        {
            if(nSpellID != SPELL_TWILIGHT_LUCK
            && nSpellID != SPELL_DIAMOND_SPRAY)
            {
                SendMessageToPC(oCaster, "You must be able to take ability damage to cast this spell!");
                return FALSE;
            }
        }
        //Check for alignment restrictions
        if(bCorruptOrSanctified == 1
        && nCasterAlignment == ALIGNMENT_EVIL)
        {
            SendMessageToPC(oCaster, "You cannot cast Sanctified spells if you are evil.");
            return FALSE;
        }
        if(bCorruptOrSanctified == 2
        && nCasterAlignment == ALIGNMENT_GOOD)
        {
            SendMessageToPC(oCaster, "You cannot cast Corrupt spells if you are good.");
            return FALSE;
        }
    }

    return TRUE;
}

int GrappleConc(object oCaster, int nSpellLevel)
{
    if(GetLocalInt(oCaster, "IsGrappled"))
    {
        return GetIsSkillSuccessful(oCaster, SKILL_CONCENTRATION, (20 + nSpellLevel));
    }
    return TRUE;
}

int X2UseMagicDeviceCheck(object oCaster)
{
    int nRet = ExecuteScriptAndReturnInt("x2_pc_umdcheck", oCaster);
    return nRet;
}

//------------------------------------------------------------------------------
// GZ: This is a filter I added to prevent spells from firing their original spell
// script when they were cast on items and do not have special coding for that
// case. If you add spells that can be cast on items you need to put them into
// des_crft_spells.2da
//------------------------------------------------------------------------------
int X2CastOnItemWasAllowed(object oItem)
{
    int bAllow = (Get2DACache(X2_CI_CRAFTING_SP_2DA,"CastOnItems",PRCGetSpellId()) == "1");
    if (!bAllow)
    {
        FloatingTextStrRefOnCreature(83453, OBJECT_SELF); // not cast spell on item
    }
    return bAllow;

}

//------------------------------------------------------------------------------
// Execute a user overridden spell script.
//------------------------------------------------------------------------------
int X2RunUserDefinedSpellScript()
{
    // See x2_inc_switches for details on this code
    string sScript =  GetModuleOverrideSpellscript();
    if (sScript != "")
    {
        ExecuteScript(sScript,OBJECT_SELF);
        if (GetModuleOverrideSpellScriptFinished() == TRUE)
        {
            return FALSE;
        }
    }
    return TRUE;
}

//------------------------------------------------------------------------------
// Set the user-specific spell script
//------------------------------------------------------------------------------
void PRCSetUserSpecificSpellScript(string sScript)
{
    SetLocalString(OBJECT_SELF, "PRC_OVERRIDE_SPELLSCRIPT", sScript);
}

//------------------------------------------------------------------------------
// Get the user-specific spell script
//------------------------------------------------------------------------------
string PRCGetUserSpecificSpellScript()
{
    return GetLocalString(OBJECT_SELF, "PRC_OVERRIDE_SPELLSCRIPT");
}

//------------------------------------------------------------------------------
// Finish the spell, if necessary
//------------------------------------------------------------------------------
void PRCSetUserSpecificSpellScriptFinished()
{
    SetLocalInt(OBJECT_SELF, "PRC_OVERRIDE_SPELLSCRIPT_DONE", TRUE);
}

//------------------------------------------------------------------------------
// Figure out if we should finish the spell.
//------------------------------------------------------------------------------
int PRCGetUserSpecificSpellScriptFinished()
{
    int iRet = GetLocalInt(OBJECT_SELF, "PRC_OVERRIDE_SPELLSCRIPT_DONE");
    DeleteLocalInt(OBJECT_SELF, "PRC_OVERRIDE_SPELLSCRIPT_DONE");
    return iRet;
}

//------------------------------------------------------------------------------
// Run a user-specific spell script for classes that use spellhooking.
//------------------------------------------------------------------------------
int PRCRunUserSpecificSpellScript()
{
    string sScript = PRCGetUserSpecificSpellScript();
    if (sScript != "")
    {
        ExecuteScript(sScript,OBJECT_SELF);
        if (PRCGetUserSpecificSpellScriptFinished() == TRUE)
        {
            return FALSE;
        }
    }
    return TRUE;
}

//------------------------------------------------------------------------------
// Created Brent Knowles, Georg Zoeller 2003-07-31
// Returns TRUE (and charges the sequencer item) if the spell
// ... was cast on an item AND
// ... the item has the sequencer property
// ... the spell was non hostile
// ... the spell was not cast from an item
// in any other case, FALSE is returned an the normal spellscript will be run
//------------------------------------------------------------------------------
int X2GetSpellCastOnSequencerItem(object oItem, object oCaster, int nSpellID, int nMetamagic, int nCasterLevel, int nSaveDC, int bSpellIsHostile, object oSpellCastItem)
{
    if(GetIsObjectValid(oSpellCastItem)) // spell cast from item?
    {
        // we allow scrolls
        int nBt = GetBaseItemType(oSpellCastItem);
        if(nBt !=BASE_ITEM_SPELLSCROLL && nBt != 105)
        {
            FloatingTextStrRefOnCreature(83373, oCaster);
            return TRUE; // wasted!
        }
    }

    if(bSpellIsHostile)
    {
        int nMaxChanSpells = IPGetItemChannelingProperty(oItem);

        if(nMaxChanSpells < 1)
        {
            FloatingTextStrRefOnCreature(83885, oCaster);
            return TRUE; // no hostile spells on sequencers, sorry ya munchkins :)
        }

        int nNumberOfTriggers = GetLocalInt(oItem, "X2_L_NUMCHANNELTRIGGERS");
        // is there still space left on the sequencer?
        if (nNumberOfTriggers < nMaxChanSpells)
        {
            // success visual and store spell-id on item.
            effect eVisual = EffectVisualEffect(VFX_IMP_BREACH);
            nNumberOfTriggers++;
            //NOTE: I add +1 to the SpellId to spell 0 can be used to trap failure
            int nSID = nSpellID+1;
            SetLocalInt(oItem, "X2_L_CHANNELTRIGGER"  +IntToString(nNumberOfTriggers), nSID);
            SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_L"+IntToString(nNumberOfTriggers), nCasterLevel);
            SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_M"+IntToString(nNumberOfTriggers), nMetamagic);
            SetLocalInt(oItem, "X2_L_CHANNELTRIGGER_D"+IntToString(nNumberOfTriggers), nSaveDC);
            SetLocalInt(oItem, "X2_L_NUMCHANNELTRIGGERS", nNumberOfTriggers);
            //add an OnHit:DischargeSequencer property
            itemproperty ipTest = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1);
            IPSafeAddItemProperty(oItem ,ipTest, 99999999.9);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oCaster);
            FloatingTextStrRefOnCreature(83884, oCaster);
        }
        else
            FloatingTextStrRefOnCreature(83859, oCaster);
    }
    else
    {
        int nMaxSeqSpells = IPGetItemSequencerProperty(oItem); // get number of maximum spells that can be stored

        if(nMaxSeqSpells < 1)
        {
            return FALSE;
        }

        int nNumberOfTriggers = GetLocalInt(oItem, "X2_L_NUMTRIGGERS");
        // is there still space left on the sequencer?
        if (nNumberOfTriggers < nMaxSeqSpells)
        {
            // success visual and store spell-id on item.
            effect eVisual = EffectVisualEffect(VFX_IMP_BREACH);
            nNumberOfTriggers++;
            //NOTE: I add +1 to the SpellId to spell 0 can be used to trap failure
            int nSID = nSpellID+1;
            SetLocalInt(oItem, "X2_L_SPELLTRIGGER"  +IntToString(nNumberOfTriggers), nSID);
            SetLocalInt(oItem, "X2_L_SPELLTRIGGER_L"+IntToString(nNumberOfTriggers), nCasterLevel);
            SetLocalInt(oItem, "X2_L_SPELLTRIGGER_M"+IntToString(nNumberOfTriggers), nMetamagic);
            SetLocalInt(oItem, "X2_L_SPELLTRIGGER_D"+IntToString(nNumberOfTriggers), nSaveDC);
            SetLocalInt(oItem, "X2_L_NUMTRIGGERS", nNumberOfTriggers);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oCaster);
            FloatingTextStrRefOnCreature(83884, oCaster);
        }
        else
            FloatingTextStrRefOnCreature(83859, oCaster);
    }

    return TRUE; // in any case, spell is used up from here, so do not fire regular spellscript
}

//------------------------------------------------------------------------------
// * This is our little concentration system for black blade of disaster
// * if the mage tries to cast any kind of spell, the blade is signaled an event to die
//------------------------------------------------------------------------------
void X2BreakConcentrationSpells()
{
    //end Dragonsong Lyrist songs
    DeleteLocalInt(OBJECT_SELF, "SpellConc");

    if(GetPRCSwitch(PRC_PNP_BLACK_BLADE_OF_DISASTER))
    {
        //this is also in summon HB
        //but needed here to handle quickend spells
        //Disintegrate is cast from the blade so doenst end the summon
        object oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
        if(GetIsObjectValid(oAssoc))
        {
            if(GetTag(oAssoc) == "x2_s_bblade") // black blade of disaster
            {
                if(GetLocalInt(oAssoc, "X2_L_CREATURE_NEEDS_CONCENTRATION"))
                {
                    SignalEvent(oAssoc, EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
                }
            }
        }
    }
}

//------------------------------------------------------------------------------
// being hit by any kind of negative effect affecting the caster's ability to concentrate
// will cause a break condition for concentration spells
//------------------------------------------------------------------------------
int X2GetBreakConcentrationCondition(object oPlayer)
{
     effect e1 = GetFirstEffect(oPlayer);
     int nType;
     int bRet = FALSE;
     while (GetIsEffectValid(e1) && !bRet)
     {
        nType = GetEffectType(e1);

        if (nType == EFFECT_TYPE_STUNNED || nType == EFFECT_TYPE_PARALYZE ||
            nType == EFFECT_TYPE_SLEEP || nType == EFFECT_TYPE_FRIGHTENED ||
            nType == EFFECT_TYPE_PETRIFY || nType == EFFECT_TYPE_CONFUSED ||
            nType == EFFECT_TYPE_DOMINATED || nType == EFFECT_TYPE_POLYMORPH)
         {
           bRet = TRUE;
         }
                    e1 = GetNextEffect(oPlayer);
     }
    return bRet;
}

void X2DoBreakConcentrationCheck()
{
    object oMaster = GetMaster();
    if (GetLocalInt(OBJECT_SELF,"X2_L_CREATURE_NEEDS_CONCENTRATION"))
    {
         if (GetIsObjectValid(oMaster))
         {
            int nAction = GetCurrentAction(oMaster);
            // master doing anything that requires attention and breaks concentration
            if (nAction == ACTION_DISABLETRAP || nAction == ACTION_TAUNT ||
                nAction == ACTION_PICKPOCKET || nAction ==ACTION_ATTACKOBJECT ||
                nAction == ACTION_COUNTERSPELL || nAction == ACTION_FLAGTRAP ||
                nAction == ACTION_CASTSPELL || nAction == ACTION_ITEMCASTSPELL)
            {
                SignalEvent(OBJECT_SELF,EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
            }
            else if (X2GetBreakConcentrationCondition(oMaster))
            {
                SignalEvent(OBJECT_SELF,EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
            }
         }
    }
}

//------------------------------------------------------------------------------
// This function will return TRUE if the spell that is cast is a shape shifting
// spell.
//------------------------------------------------------------------------------
int X3ShapeShiftSpell(object oTarget, int nSpellID)
{
    string sUp = GetStringUpperCase(Get2DACache("x3restrict", "SHAPESHIFT", nSpellID));
    if(sUp == "YES")
        return TRUE;
    return FALSE;
}

void VoidCounterspellExploitCheck(object oCaster)
{
    if(GetCurrentAction(oCaster) == ACTION_COUNTERSPELL)
    {
        ClearAllActions();
        SendMessageToPC(oCaster,"Because of the infinite spell casting exploit, you cannot use counterspell in this manner.");
    }
}

int CounterspellExploitCheck(object oCaster)
{
    if(GetCurrentAction(oCaster) == ACTION_COUNTERSPELL)
    {
        ClearAllActions();
        SendMessageToPC(oCaster,"Because of the infinite spell casting exploit, you cannot use counterspell in this manner.");
        return FALSE;
    }
    else
    {
        DelayCommand(0.1, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(0.2, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(0.3, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(0.4, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(0.5, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(0.6, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(0.7, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(0.8, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(0.9, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(1.0, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(2.0, VoidCounterspellExploitCheck(oCaster));
        DelayCommand(3.0, VoidCounterspellExploitCheck(oCaster));
    }

    return TRUE;
}

int Blighter(object oCaster, int nCastingClass, object oSpellCastItem)
{
	// If it's an item, exit
    if (GetIsObjectValid(oSpellCastItem))
        return TRUE;
	
    if (nCastingClass == CLASS_TYPE_DRUID && GetLevelByClass(CLASS_TYPE_BLIGHTER, oCaster) > 0)
    {
        SendMessageToPC(oCaster,"Blighters cannot cast druid spells.");
        return FALSE;        
    }

    return TRUE;
}

int BattleBlessing(object oCaster, int nCastingClass)
{
    if (nCastingClass != CLASS_TYPE_PALADIN && GetLocalInt(oCaster, "BattleBlessingActive"))
    {
        SendMessageToPC(oCaster,"You cannot cast non-Paladin spells with Battle Blessing active.");
        return FALSE;        
    }

    return TRUE;
}

int Spelldance(object oCaster, int nSpellLevel, int nCastingClass)
{
    //ensure the spell is arcane
    if(!GetIsArcaneClass(nCastingClass, oCaster))
        return TRUE;

    if (DEBUG) FloatingTextStringOnCreature("Spelldance in Spellhook", oCaster, FALSE);        
        
    int nDance = GetLocalInt(oCaster, "Spelldance");    
    if (DEBUG) FloatingTextStringOnCreature("Spelldance value in Spellhook: "+IntToString(nDance), oCaster, FALSE); 
    if (nDance)
    {
        if(nDance & METAMAGIC_EXTEND)
            nSpellLevel += 1;
        if(nDance & METAMAGIC_EMPOWER)
            nSpellLevel += 2;
        if(nDance & METAMAGIC_MAXIMIZE)
            nSpellLevel += 3;            
            
        if (DEBUG) FloatingTextStringOnCreature("Spelldances in Spellhook #2", oCaster, FALSE);            
            
        if(!GetIsSkillSuccessful(oCaster, SKILL_PERFORM, 10+nSpellLevel)) //Failed
        {
            FloatingTextStringOnCreature("Spelldance failed", oCaster, FALSE);
            if (DEBUG) FloatingTextStringOnCreature("Spelldances in Spellhook #3", oCaster, FALSE);            
            return FALSE;
        }
    }
    return TRUE;
}     

// Does the counterspelling for Warp Spell,
// and the storing of the spell for later use
int WarpSpell(object oCaster, int nSpellId)
{
    int nWarp = GetLocalInt(oCaster, "WarpSpell");
    // If Warp Spell isn't set, just keep going
    if (!nWarp) return TRUE;
    
    object oShadow = GetLocalObject(oCaster, "WarpSpell"); // The one who cast Warp Spell
    
    DeleteLocalInt(oCaster, "WarpSpell");
    DeleteLocalObject(oCaster, "WarpSpell"); // Done regardless of success or failure
    
    int nLevel = PRCGetCasterLevel(oCaster);
    if (d20() + nWarp > d20() + nLevel) // Won the caster level check
    {
        // Set a marker on the Shadowcaster
        SetLocalInt(oShadow, "WarpSpellSuccess", TRUE); 
        FloatingTextStringOnCreature("You have successfully warped your opponent's "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId))), oShadow, FALSE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUL_TRAP), oCaster);
        return FALSE;
    }
    
    FloatingTextStringOnCreature("Your warp spell has failed", oShadow, FALSE);
    return TRUE;
}

// Does the counterspelling for Innate Counterspell
// and the storing of the spell for later use
int InnateCounterspell(object oCaster, int nSpellId, int nSpellLevel)
{
    int nWarp = GetLocalInt(oCaster, "InnateCounterspell");
    // If Innate Counterspell isn't set, just keep going
    if (!nWarp) return TRUE;
    
    object oShadow = GetLocalObject(oCaster, "InnateCounterspell"); // The one who cast Innate Counterspell
    
    DeleteLocalInt(oCaster, "InnateCounterspell");
    DeleteLocalObject(oCaster, "InnateCounterspell"); // Done regardless of success or failure
    
    int nLevel = PRCGetCasterLevel(oCaster);
    if (GetIsSkillSuccessful(oCaster, SKILL_SPELLCRAFT, 15 + nSpellLevel)) // Identified the spell to counter
    {
        SetLocalInt(oShadow, "BurnSpellLevel", nSpellLevel);
        if (BurnSpell(oShadow))
        {
            DeleteLocalInt(oShadow, "BurnSpellLevel");
            // Set a marker on the Noctumancer at the right level
            if (GetLevelByClass(CLASS_TYPE_NOCTUMANCER) >= 7) 
            {
                int nStore = PRCMin(1, nSpellLevel/2);
                SetLocalInt(oShadow, "InnateCounterSuccess", nStore); 
                FloatingTextStringOnCreature("You have one free mystery of "+IntToString(nStore)+" level", oShadow, FALSE);
            }  
            if (GetLevelByClass(CLASS_TYPE_NOCTUMANCER) >= 10) 
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(EffectSpellImmunity(nSpellId)), oShadow, 60.0);            

            FloatingTextStringOnCreature("You have successfully counterspelled your opponent's "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId))), oShadow, FALSE);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUL_TRAP), oCaster);
            return FALSE;
        }    
    }
    
    FloatingTextStringOnCreature("Your innate counterspell has failed", oShadow, FALSE);
    return TRUE;
}

// Stores the spell for use with Echo Spell
void EchoSpell(object oCaster, int nSpellId)
{
    int nEcho = GetLocalInt(oCaster, "EchoSpell");
    // If Echo Spell isn't set, just skip
    if (nEcho)
    {   
        object oShadow = GetLocalObject(oCaster, "EchoSpell"); // The one who cast Echo Spell
        SetLocalInt(oShadow, "EchoedSpell", nSpellId);
        FloatingTextStringOnCreature("You have echoed " + GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId))) + " and have one round to cast it", oShadow, FALSE);
        DelayCommand(9.0, DeleteLocalInt(oShadow, "EchoedSpell"));
        DeleteLocalInt(oCaster, "EchoSpell");
        DeleteLocalObject(oCaster, "EchoSpell"); 
    }
}

// Flood of Shadow
int FloodShadow(object oCaster, int nSpellId)
{
    if (!GetLocalInt(oCaster, "FloodShadow") || GetLocalInt(oCaster, "ShadowEvoking"))
        return TRUE;

    if (!GetIsSkillSuccessful(oCaster, SKILL_SPELLCRAFT, 15 + StringToInt(Get2DACache("spells", "Innate", nSpellId)))) // Skill check
    {
        if (GetIsPC(oCaster)) FloatingTextStringOnCreature("You have failed to overcome Flood of Shadow", oCaster, FALSE);
        return FALSE;
    }
    
    return TRUE;
}

void MasterWand(object oCaster, object oSpellCastItem, int nSpellLevel)
{
    if (DEBUG) DoDebug("MasterWand - Entered");
    if (!GetHasFeat(FEAT_MASTER_WAND, oCaster)) return; // Does nothing without the feat, obviously
    if (!GetLocalInt(oCaster, "MasterWand")) return; // Needs to be active as well
    
    if (DEBUG) DoDebug("MasterWand - Active");
    
    int nType = GetBaseItemType(oSpellCastItem);
    
    if(nType == BASE_ITEM_MAGICWAND || nType == BASE_ITEM_ENCHANTED_WAND) // Has to be a wand, obv
    {
        if (DEBUG) DoDebug("MasterWand - Wand");
        SetLocalInt(oCaster, "BurnSpellLevel", nSpellLevel);
        if (BurnSpell(oCaster)) // Burn a spell of the appropriate level
        {
            if (DEBUG) DoDebug("MasterWand - Burned Spell");
            DeleteLocalInt(oCaster, "BurnSpellLevel"); 
            SetItemCharges(oSpellCastItem, GetItemCharges(oSpellCastItem)+1); // add the use back to the item
        }    
    }
}

int WandEquipped(object oCaster, object oSpellCastItem)
{
    //if (!GetPRCSwitch(PRC_EQUIP_WAND)) return TRUE; // If this is set to anything other than 0, it skips the check.
    
    int nType = GetBaseItemType(oSpellCastItem);
    
    if(nType == BASE_ITEM_MAGICWAND || nType == BASE_ITEM_ENCHANTED_WAND || nType == BASE_ITEM_CRAFTED_SCEPTER) // Has to be a wand, obv
    {
        if(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCaster) == oSpellCastItem || GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster) == oSpellCastItem) // Needs to be equipped
        {
            return TRUE;
        }
        else
        {
            FloatingTextStringOnCreature("You must equip this item to cast from it.", oCaster, FALSE);
            return FALSE; // It's a wand not equipped
        }   
    }
    
    return TRUE;
}

void DoubleWandWielder(object oCaster, object oSpellCastItem, object oTarget)
{
    if (!GetHasFeat(FEAT_DOUBLE_WAND_WIELDER, oCaster)) return; // Does nothing without the feat, obviously
    if (!GetLocalInt(oCaster, "DoubleWand")) return; // Needs to be active as well
    
    int nType = GetBaseItemType(oSpellCastItem);
    
    if(nType == BASE_ITEM_MAGICWAND || nType == BASE_ITEM_ENCHANTED_WAND) // Has to be a wand, obv
    {
        object oOffHand;
        if(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCaster) == oSpellCastItem) // Find the other hand
            oOffHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster);
        else
            oOffHand = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCaster); 
            
        int nOffType = GetBaseItemType(oOffHand); 
        
        if(nOffType == BASE_ITEM_MAGICWAND || nOffType == BASE_ITEM_ENCHANTED_WAND) // Has to be a wand, obv
        {
            int nCharges = GetItemCharges(oOffHand);
            
            if (nCharges > 1) // Need to have enough charges for this
            {
                //code for getting new ip type
                int nCasterLevel;
                int nSpell;
                itemproperty ipTest = GetFirstItemProperty(oOffHand);
                while(GetIsItemPropertyValid(ipTest))
                {
                    if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL)
                    {
                        nCasterLevel = GetItemPropertyCostTableValue(ipTest);
                        if (DEBUG) DoDebug("DoubleWandWielder: caster level from item = "+IntToString(nCasterLevel));
                    }
                    if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_CAST_SPELL)
                    {
                        nSpell = GetItemPropertySubType(ipTest);
                        if (DEBUG) DoDebug("DoubleWandWielder: iprop subtype = "+IntToString(nSpell));
                        nSpell = StringToInt(Get2DACache("iprp_spells", "SpellIndex", nSpell));
                        if (DEBUG) DoDebug("DoubleWandWielder: spell from item = "+IntToString(nSpell));
                    }                    
                    ipTest = GetNextItemProperty(oOffHand);
                }
                // if we didn't find a caster level on the item, it must be Bioware item casting
                if(!nCasterLevel)
                {
                    nCasterLevel = GetCasterLevel(oCaster);
                    if (DEBUG) DoDebug("DoubleWandWielder: bioware item casting with caster level = "+IntToString(nCasterLevel));
                }
            
                ActionCastSpell(nSpell, nCasterLevel, 0, 0, METAMAGIC_NONE, CLASS_TYPE_INVALID, FALSE, FALSE, oTarget, TRUE);
                SetItemCharges(oOffHand, nCharges - 2);
            }        
        }
    }
}

void MeldArcaneFocus(object oCaster, object oTarget)
{
	int nDC = GetLocalInt(oCaster, "ArcaneFocusBound");
	if (nDC) // MELD_ARCANE_FOCUS
	{
		if(!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_SPELL))
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDazed(), oTarget, 6.0);
	}
}

// Does the caster level check for Witchborn Binder's Mage Shackles
int MageShackles(object oCaster, int nSpellId)
{
    int nWarp = GetLocalInt(oCaster, "MageShackles");
    // If Mage Shackles aren't present, just keep going
    if (!nWarp) return TRUE;
    
    object oMeldshaper = GetLocalObject(oCaster, "MageShacklesShaper"); // The one who created the Shackles
    
    int nLevel = PRCGetCasterLevel(oCaster);
    if (nWarp > PRCGetCasterLevel(oCaster)+d20()) // Do they beat the DC for the caster level check or not?
    {
        FloatingTextStringOnCreature("Your mage shackles have successfully blocked your opponent's "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId))), oMeldshaper, FALSE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUL_TRAP), oCaster);
        return FALSE;
    }
    
    return TRUE;
}

// Does the counterspelling for Word of Abrogation
int Abrogation(object oCaster, int nCasterLevel, int nSpellId)
{
	location lTarget = GetLocation(oCaster);
	int nCnt = 1;
	// Find the meldshaper
    object oMeldshaper = GetNearestCreatureToLocation(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, lTarget, nCnt);
    while(GetIsObjectValid(oMeldshaper) && GetDistanceBetween(oMeldshaper, oCaster) <= FeetToMeters(60.0f))
    {
		int nWarp = GetLocalInt(oMeldshaper, "Abrogation");
		if(nWarp)
		{
	    	// Clean up the ability
	    	DeleteLocalInt(oMeldshaper, "Abrogation");	
	    	PRCRemoveSpellEffects(MELD_WITCH_ABROGATION, oMeldshaper, oMeldshaper);
    		GZPRCRemoveSpellEffects(MELD_WITCH_ABROGATION, oMeldshaper, FALSE);
    		
	    	if (nWarp+d20() >= nCasterLevel+11) // Do you beat their caster level?
	    	{
	    	    FloatingTextStringOnCreature("Your word of abrogation has successfully blocked your opponent's "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId))), oMeldshaper, FALSE);
	    	    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUL_TRAP), oCaster);
	    	    return FALSE;
	    	}		
	    	else
	    		FloatingTextStringOnCreature("Your word of abrogation has failed", oMeldshaper, FALSE);
	    }	
        nCnt++;
        oMeldshaper = GetNearestCreatureToLocation(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, lTarget, nCnt);
    }

    return TRUE;
}

// Does damage for Grim Integument
void Integument(object oCaster, int nCastingClass)
{
	if (GetIsArcaneClass(nCastingClass) && GetHasSpellEffect(MELD_WITCH_INTEGUMENT, oCaster))
	{
		int nEssentia = GetLocalInt(oCaster, "GIEssentia");
		object oMeldshaper = GetLocalObject(oCaster, "GIMeldshaper"); // The one who created the Shackles
    	int nDC = 10 + nEssentia + GetAbilityModifier(ABILITY_CONSTITUTION, oMeldshaper);
    	int nDam = d6(nEssentia);
        if(PRCMySavingThrow(SAVING_THROW_FORT, oCaster, nDC, SAVING_THROW_TYPE_NONE))
        {
			if (GetHasMettle(oCaster, SAVING_THROW_FORT))
				nDam = 0;  
				
			nDam /= 2;	
        }
            
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDam, DAMAGE_TYPE_POSITIVE), oCaster);		
	}
}

void WyrmbaneFrightful(object oPC)
{
    object oWOL = GetItemPossessedBy(oPC, "WOL_Wyrmbane");
    
    // You get nothing if you aren't wielding the legacy item
    if(oWOL != GetItemInSlot(INVENTORY_SLOT_HEAD, oPC)) return;
    if (GetHasFeat(FEAT_GREATER_LEGACY, oPC))
    	ExecuteScript("prc_fright_pres", oPC);
}

int Nondetection(object oTarget, object oCaster, int nSchool, int nCasterLevel)
{
	int nReturn = TRUE;
	if (nSchool == SPELL_SCHOOL_DIVINATION)
	{
    	if(GetHasSpellEffect(SPELL_NONDETECTION, oTarget) || GetLevelByClass(CLASS_TYPE_WILD_MAGE, oTarget) >= 6 || GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oTarget) >= 5 || GetHasSpellEffect(MELD_ENIGMA_HELM, oTarget) || GetRacialType(oTarget) == RACIAL_TYPE_SKULK) 
    	{
    	    // Caster level check or the Divination fails.
    	    int nTarget = PRCGetCasterLevel(oTarget) + 11;
    		if (GetRacialType(oTarget) == RACIAL_TYPE_SKULK && 20 > nTarget) nTarget = 20;
    	    if(nTarget > nCasterLevel + d20())
    	    {
    	        FloatingTextStringOnCreature(GetName(oTarget) + " has Nondetection active.", oCaster, FALSE);
    	        return FALSE;
    	    }
    	}
    }	
    return nReturn;    
}        

int AmonInfluence(object oTarget, object oCaster, int nSpellId, int nSpellLevel, int bSpellIsHostile)
{
	// Have to have a bad pact with Amon for this to trigger on beneficial spells
	if (GetHasSpellEffect(VESTIGE_AMON, oTarget) && !GetLocalInt(oTarget, "PactQuality"+IntToString(VESTIGE_AMON)) && !bSpellIsHostile)
	{
		// Law, fire, and sun domain casters
		if (GetHasFeat(FEAT_FIRE_DOMAIN_POWER, oCaster) || GetHasFeat(FEAT_SUN_DOMAIN_POWER, oCaster))
		{
        	if(PRCMySavingThrow(SAVING_THROW_WILL, oTarget, PRCGetSaveDC(oTarget, oCaster, nSpellId), SAVING_THROW_TYPE_SPELL))
            {
            	FloatingTextStringOnCreature("You have made a poor pact, and Amon forces you to resist the spell", oTarget, FALSE);
				return FALSE;
            }//end will save processing			
		}
	}
	
	return TRUE;
}

int RonoveInfluence(object oCaster, object oSpellCastItem)
{
	if (GetHasSpellEffect(VESTIGE_RONOVE, oCaster) && !GetLocalInt(oCaster, "PactQuality"+IntToString(VESTIGE_RONOVE)))
	{
    	if(GetIsObjectValid(oSpellCastItem))
    	{
    	    // Potion drinking is restricted
    	    if(GetBaseItemType(oSpellCastItem) == BASE_ITEM_ENCHANTED_POTION
    	    || GetBaseItemType(oSpellCastItem) == BASE_ITEM_POTIONS)
    	        return FALSE;
    	}        
    }	
    
    return TRUE;
}

int HaagentiTransmutation(object oTarget, int nSpellID)
{
	if (GetHasSpellEffect(VESTIGE_HAAGENTI, oTarget) && GetLocalInt(oTarget, "ExploitVestige") != VESTIGE_HAAGENTI_IMMUNE_TRANS)
	{
    	if(GetIsOfSubschool(nSpellID, SUBSCHOOL_POLYMORPH))
   	        return FALSE;
    }	
    
    return TRUE;
}


int KarsiteInability(object oCaster, int nCastingClass)
{
    if (GetRacialType(oCaster) == RACIAL_TYPE_KARSITE)
    {
	//:: Check if the spell originates from an item
        object oSpellSource = GetSpellCastItem();
        if (GetIsObjectValid(oSpellSource))
        {
            //:: Spell is cast from an item; allow it
            return TRUE;
		}
        if (GetIsDivineClass(nCastingClass, oCaster) || GetIsArcaneClass(nCastingClass, oCaster))
        {
            return FALSE;
        }
    }
    
    // Default: allow
    return TRUE;
}

/* int KarsiteInability(object oCaster, int nCastingClass)
{
	if (GetRacialType(oCaster) == RACIAL_TYPE_KARSITE)
	{
    	if(GetIsDivineClass(nCastingClass, oCaster) || GetIsArcaneClass(nCastingClass, oCaster))
   	        return FALSE;
    }	
    
    return TRUE;
} */

int UrCleric(object oCaster, int nCastingClass)
{
	if (GetLevelByClass(CLASS_TYPE_UR_PRIEST, oCaster) && GetIsDivineClass(nCastingClass, oCaster) && nCastingClass != CLASS_TYPE_UR_PRIEST)
	{
   		return FALSE;
    }	
    
    return TRUE;
}

int ShadowWeaveLightSpells(object oCaster, int nSpellID)
{
	if(GetHasDescriptor(nSpellID, DESCRIPTOR_LIGHT) && GetHasFeat(FEAT_SHADOWWEAVE, oCaster))
	{
   		return FALSE;
    }	
    
    return TRUE;
}

void ArkamoiStrength(object oCaster, int nCastingClass)
{
	// This race only
	if (GetRacialType(oCaster) != RACIAL_TYPE_ARKAMOI)
		return;
		
	int nStrength = GetLocalInt(oCaster, "StrengthFromMagic");
	
	// Only applies to arcane spells
	if (GetIsArcaneClass(nCastingClass, oCaster))
	{
		// First time here
		if (!nStrength)
		{
			SetLocalInt(oCaster, "StrengthFromMagic", 1);
			DelayCommand(60.0, DeleteLocalInt(oCaster, "StrengthFromMagic"));
			DelayCommand(60.0, FloatingTextStringOnCreature("Arkamoi Strength from Magic reset", oCaster, FALSE));
		}
		else if (5 > nStrength) // nStrength equals something, can't go above five
			SetLocalInt(oCaster, "StrengthFromMagic", nStrength + 1);
		PRCRemoveSpellEffects(SPELL_ARKAMOI_STRENGTH, oCaster, oCaster);
		GZPRCRemoveSpellEffects(SPELL_ARKAMOI_STRENGTH, oCaster, FALSE);			
		ActionCastSpellOnSelf(SPELL_ARKAMOI_STRENGTH);
		FloatingTextStringOnCreature("Arkamoi Strength from Magic at "+IntToString(nStrength+1), oCaster, FALSE);
	}
}

void RedspawnHealing(object oCaster, int nSpellID, int nSpellLevel)
{
	if(GetHasDescriptor(nSpellID, DESCRIPTOR_FIRE) && GetRacialType(oCaster) == RACIAL_TYPE_REDSPAWN_ARCANISS)
	{
   		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nSpellLevel*2), oCaster);
    }	
}  

void WarsoulTyrant(object oCaster, int nCastingClass)
{
	// This race only
	if (GetRacialType(oCaster) != RACIAL_TYPE_HOBGOBLIN_WARSOUL)
		return;
		
	int nStrength = GetLocalInt(oCaster, "WarsoulTyrant");
	
	// Only applies to arcane spells
	if (GetIsArcaneClass(nCastingClass, oCaster))
	{
		// First time here
		if (nStrength)
			DelayCommand(1.0, DeleteLocalInt(oCaster, "WarsoulTyrant"));
	}
}

// this will execute the prespellcastcode, whose full functionality is incoded in X2PreSpellCastCode2(),
// as a script, to save loading time for spells scripts and reduce memory usage of NWN
// the prespellcode takes up roughly 250 kByte compiled code, meaning that every spell script that
// calls it directly as a function (e.g.: X2PreSpellCastCode2) will be between 100 kByte to 250 kByte
// larger, than a spell script calling the prespellcode via ExecuteScript (e.g. X2PreSpellCastCode)
// Although ExecuteScript is slightly slower than a direct function call, quite likely overall performance is
// increased, because for every new spell 100-250 kByte less code need to be loaded into memory
// and NWN has more free memory available to keep more spells scripts (and other crucial scripts)
//in RAM
/*int X2PreSpellCastCode()
{
    object oCaster = OBJECT_SELF;

        // SetLocalInt(oCaster, "PSCC_Ret", 0);
        ExecuteScript("prc_prespell", oCaster);

        int nReturn = GetLocalInt(oCaster, "PSCC_Ret");
        // DeleteLocalInt(oCaster, "PSCC_Ret");

        return nReturn;
}
moved to prc_spellhook */

//------------------------------------------------------------------------------
// if FALSE is returned by this function, the spell will not be cast
// the order in which the functions are called here DOES MATTER, changing it
// WILL break the crafting subsystems
//------------------------------------------------------------------------------
int X2PreSpellCastCode2()
{
    object oCaster = OBJECT_SELF;
    object oTarget = PRCGetSpellTargetObject();
    object oSpellCastItem = PRCGetSpellCastItem();
    int nOrigSpellID = GetSpellId();
    int nSpellID = PRCGetSpellId();
    int nCastingClass = PRCGetLastSpellCastClass();
    int nSpellLevel = PRCGetSpellLevelForClass(nSpellID, nCastingClass);
    int nSchool = GetSpellSchool(nSpellID);
    int nCasterLevel = PRCGetCasterLevel(oCaster);
    int nMetamagic = PRCGetMetaMagicFeat(oCaster, FALSE);
    int nSaveDC = PRCGetSaveDC(OBJECT_INVALID, oCaster);
    int bSpellIsHostile = Get2DACache("spells", "HostileSetting", nOrigSpellID) == "1";
    int nSpellbookType = GetSpellbookTypeForClass(nCastingClass);
    int nCasterAlignment = GetAlignmentGoodEvil(oCaster);
    string sComponent = GetStringUpperCase(Get2DACache("spells", "VS", nSpellID));	
	
	//---------------------------------------------------------------------------  
    // Check for Circle Magic participant sacrifices.  
    //---------------------------------------------------------------------------  
    if (GetLocalInt(oCaster, "CircleMagicSacrifice"))  
    {  
        object oLeader = GetLocalObject(oCaster, "CircleMagicLeader");  
        string sCircleClass = GetLocalString(oLeader, "CircleMagicClass");  
          
        // Validate class compatibility  
        if (sCircleClass == "RED_WIZARD" && GetLevelByClass(CLASS_TYPE_RED_WIZARD, oCaster) == 0)  
        {  
            FloatingTextStringOnCreature("Only Red Wizards may join this circle.", oCaster);  
            DeleteLocalInt(oCaster, "CircleMagicSacrifice");  
            DeleteLocalObject(oCaster, "CircleMagicLeader");  
            return FALSE;  
        }  
        if (sCircleClass == "HATHRAN" && GetLevelByClass(CLASS_TYPE_HATHRAN, oCaster) == 0)  
        {  
            FloatingTextStringOnCreature("Only Hathrans may join this circle.", oCaster);  
            DeleteLocalInt(oCaster, "CircleMagicSacrifice");  
            DeleteLocalObject(oCaster, "CircleMagicLeader");  
            return FALSE;  
        }  
          
        // Valid case: record contribution and suppress spell  
        if (oTarget == oLeader && GetLocalInt(oLeader, "CircleMagicActive"))  
        {  
            int nLevel = PRCGetSpellLevelForClass(nSpellID, nCastingClass);  
            int nTotal = GetLocalInt(oLeader, "CircleMagicTotal") + nLevel;  
            int nParticipants = GetLocalInt(oLeader, "CircleMagicParticipants") + 1;  
            SetLocalInt(oLeader, "CircleMagicTotal", nTotal);  
            SetLocalInt(oLeader, "CircleMagicParticipants", nParticipants);  
              
            // Suppress the spell  
            DeleteLocalInt(oCaster, "CircleMagicSacrifice");  
            DeleteLocalObject(oCaster, "CircleMagicLeader");  
            PRCSetUserSpecificSpellScriptFinished();  
            return FALSE; // Prevents spell effects  
        }  
        else  
        {  
            FloatingTextStringOnCreature("Invalid target or circle not active.", oCaster);  
            DeleteLocalInt(oCaster, "CircleMagicSacrifice");  
            DeleteLocalObject(oCaster, "CircleMagicLeader");  
            return FALSE;  
        }  
    }  
  
    //---------------------------------------------------------------------------  
    // Check for Circle Leader finalization.  
    //---------------------------------------------------------------------------  
    if (GetLocalInt(oCaster, "CircleMagicActive"))  
    {  
        int nTotal = GetLocalInt(oCaster, "CircleMagicTotal");  
        int nParticipants = GetLocalInt(oCaster, "CircleMagicParticipants");  
        if (nParticipants >= 2 && nTotal > 0)  
        {  
            // Apply augmentation via caster level adjustment variable  
            SetLocalInt(oCaster, PRC_CASTERLEVEL_ADJUSTMENT, nTotal / 2);  
            FloatingTextStringOnCreature("Circle Magic augmentation applied (" + IntToString(nTotal) + " levels).", oCaster);  
        }  
        else  
        {  
            FloatingTextStringOnCreature("Circle Magic requires at least two participants to apply a bonus.", oCaster);  
        }  
        // Clear circle state  
        DeleteLocalInt(oCaster, "CircleMagicActive");  
        DeleteLocalInt(oCaster, "CircleMagicTotal");  
        DeleteLocalString(oCaster, "CircleMagicClass");  
        DeleteLocalInt(oCaster, "CircleMagicMaxParticipants");  
        DeleteLocalInt(oCaster, "CircleMagicParticipants");  
    }	

    //---------------------------------------------------------------------------
    // This small addition will check to see if the target is mounted and the
    // spell is therefor one that should not be permitted.
    //---------------------------------------------------------------------------
    if(!GetLocalInt(GetModule(),"X3_NO_SHAPESHIFT_SPELL_CHECK"))
    {
        if(PRCHorseGetIsMounted(oTarget) && X3ShapeShiftSpell(oTarget, nSpellID))
        {
            if(GetIsPC(oTarget))
            {
                FloatingTextStrRefOnCreature(111982,oTarget,FALSE);
            }
            return FALSE;
        }
    }

    int nContinue = !ExecuteScriptAndReturnInt("prespellcode", oCaster);

    //---------------------------------------------------------------------------
    // Now check if we cast from an item (scroll, staff etc)
    //---------------------------------------------------------------------------
    if(GetIsObjectValid(oSpellCastItem))
    {
        //---------------------------------------------------------------------------
        // Check for the new restricted itemproperties
        //---------------------------------------------------------------------------
        if(nContinue
        && !CheckPRCLimitations(oSpellCastItem, oCaster))
        {
            SendMessageToPC(oCaster, "You cannot use "+GetName(oSpellCastItem));
            nContinue = FALSE;
        }

        //---------------------------------------------------------------------------
        // Baelnorn attempting to use items while projection
        //---------------------------------------------------------------------------
        if(nContinue
        && GetLocalInt(oCaster, "BaelnornProjection_Active"))// If projection is active AND
        {
            nContinue = FALSE; // Prevent casting
        }

        //casting from staffs uses caster DC calculations
        if(nContinue
        && (GetBaseItemType(oSpellCastItem) == BASE_ITEM_MAGICSTAFF
         || GetBaseItemType(oSpellCastItem) == BASE_ITEM_CRAFTED_STAFF)
        && GetPRCSwitch(PRC_STAFF_CASTER_LEVEL))
        {
            int nDC = 10 + StringToInt(lookup_spell_innate(nSpellID));
            nDC += (GetAbilityScoreForClass(GetPrimaryArcaneClass(oCaster), oCaster)-10)/2;
            SetLocalInt(oCaster, PRC_DC_BASE_OVERRIDE, nDC);
            DelayCommand(0.01, DeleteLocalInt(oCaster, PRC_DC_BASE_OVERRIDE));
        }
    }

    //---------------------------------------------------------------------------
    // Break any spell require maintaining concentration
    //---------------------------------------------------------------------------
    X2BreakConcentrationSpells();
    
    //---------------------------------------------------------------------------
    // Herbal Infusion Use check
    //---------------------------------------------------------------------------	
    if(nContinue && (GetBaseItemType(oSpellCastItem) == BASE_ITEM_INFUSED_HERB)) 
	{
		int bIsSubradial = GetIsSubradialSpell(nSpellID);
	
		if(bIsSubradial)
		{
			nSpellID = GetMasterSpellFromSubradial(nSpellID);
		}
		int nItemCL = GetCastSpellCasterLevelFromItem(oSpellCastItem, nSpellID);
		if(DEBUG) DoDebug("x2_inc_spellhook >> X2PreSpellCastCode2: Item Spellcaster Level: "+IntToString(nItemCL)+".");
		
		if(DEBUG) DoDebug("x2_inc_spellhook >> X2PreSpellCastCode2: Herbal Infusion Found");
		if(!DoInfusionUseChecks(oCaster, oSpellCastItem, nSpellID))
		{
			ApplyInfusionPoison(oCaster, nItemCL);	
			nContinue = FALSE;			
		}
	}
	
	//---------------------------------------------------------------------------
    // No casting while using expertise    
	//---------------------------------------------------------------------------    
    if(nContinue)
    	if (GetActionMode(oCaster, ACTION_MODE_EXPERTISE) || GetActionMode(oCaster, ACTION_MODE_IMPROVED_EXPERTISE))
		{
			SendMessageToPC(oCaster, "Combat Expertise only works with attack actions.");
    		nContinue = FALSE;
		}
    
    //---------------------------------------------------------------------------
    // Run Spelldance perform check
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = Spelldance(oCaster, nSpellLevel, nCastingClass);

    //---------------------------------------------------------------------------
    // Check for PRC spell effects
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = PRCSpellEffects(oCaster, oTarget, nSpellID, nSpellLevel, nCastingClass, bSpellIsHostile, nMetamagic);

    //---------------------------------------------------------------------------
    // Run Grappling Concentration Check
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = GrappleConc(oCaster, nSpellLevel);
        
    //---------------------------------------------------------------------------
    // Blighters stop Druid casting
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = Blighter(oCaster, nCastingClass, oSpellCastItem); 
        
    //---------------------------------------------------------------------------
    // Karsite stop Arcane/Divine casting
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = KarsiteInability(oCaster, nCastingClass);         
        
    //---------------------------------------------------------------------------
    // Ur-Priest stops cleric casting
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = UrCleric(oCaster, nCastingClass);
        
    //---------------------------------------------------------------------------
    // Shadow Weave blocks casting light descriptor spells
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = ShadowWeaveLightSpells(oCaster, nSpellID);        
        
    //---------------------------------------------------------------------------
    // Forsakers cancel friendly casting
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = Forsaker(oCaster, oTarget); 

    //---------------------------------------------------------------------------
    // Battle Blessing stops non-Paladin casting
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = BattleBlessing(oCaster, nCastingClass);          
 
    //---------------------------------------------------------------------------
    // Nondetection can block divinations
    //--------------------------------------------------------------------------- 
    if (nContinue)
    	nContinue = Nondetection(oTarget, oCaster, nSchool, nCasterLevel);
        
    //---------------------------------------------------------------------------
    // Mystery Effects
    //---------------------------------------------------------------------------    
    if (nContinue)
        nContinue = WarpSpell(oCaster, nSpellID);

    if (nContinue)
        nContinue = InnateCounterspell(oCaster, nSpellID, nSpellLevel);
    
    if (nContinue)
        nContinue = FloodShadow(oCaster, nSpellID);

    //---------------------------------------------------------------------------
    // Incarnum Effects
    //---------------------------------------------------------------------------        
    if (nContinue)
        nContinue = MageShackles(oCaster, nSpellID);
        
    if (nContinue)
        nContinue = Abrogation(oCaster, nCasterLevel, nSpellID);
    
    //---------------------------------------------------------------------------
    // Binding Effects
    //---------------------------------------------------------------------------        
    if (nContinue)
        nContinue = AmonInfluence(oTarget, oCaster, nSpellID, nSpellLevel, bSpellIsHostile);
	
	if (nContinue)
        nContinue = RonoveInfluence(oCaster, oSpellCastItem);
        
	if (nContinue)
        nContinue = HaagentiTransmutation(oTarget, nSpellID);        
        
    //---------------------------------------------------------------------------
    // Check for Corrupt or Sanctified spells
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = CorruptOrSanctified(oCaster, nSpellID, nCasterAlignment, nSpellbookType);

    //---------------------------------------------------------------------------
    // Run Knight of the Chalice Heavenly Devotion check
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = KOTCHeavenDevotion(oCaster, oTarget, nCasterAlignment, nSchool);

    //---------------------------------------------------------------------------
    // Spellfire
    //---------------------------------------------------------------------------
    if(nContinue)
        nContinue = Spellfire(oCaster, oTarget);

    //---------------------------------------------------------------------------
    // This stuff is only interesting for player characters we assume that use
    // magic device always works and NPCs don't use the crafting feats or
    // sequencers anyway. Thus, any NON PC spellcaster always exits this script
    // with TRUE (unless they are DM possessed or in the Wild Magic Area in
    // Chapter 2 of Hordes of the Underdark.
    //---------------------------------------------------------------------------
    int bIsPC = GetIsPC(oCaster) || GetPRCSwitch(PRC_NPC_HAS_PC_SPELLCASTING)
             || GetIsDMPossessed(oCaster) || GetLocalInt(GetArea(oCaster), "X2_L_WILD_MAGIC");

    if(bIsPC)
    {
        //---------------------------------------------------------------------------
        // Run Bard/Sorc PrC check
        //---------------------------------------------------------------------------
        if(nContinue)
            nContinue = BardSorcPrCCheck(oCaster, nCastingClass, oSpellCastItem);
            
        //---------------------------------------------------------------------------
        // Equipped Wand switches
        //---------------------------------------------------------------------------
        if(nContinue)
            nContinue = WandEquipped(oCaster, oSpellCastItem);

        //---------------------------------------------------------------------------
        // Alignment Restrictions Check
        //---------------------------------------------------------------------------
        if (nContinue)
            nContinue = SpellAlignmentRestrictions(oCaster, nSpellID, nCastingClass);

		//---------------------------------------------------------------------------
		// Verdant Lord Spontaneous Regernate
		//---------------------------------------------------------------------------
		if(nContinue)
			Spontaneity(oCaster, nCastingClass, nSpellID, nSpellLevel);

        //---------------------------------------------------------------------------
        // Druid spontaneous summoning
        //---------------------------------------------------------------------------
        if(nContinue)
            nContinue = DruidSpontSummon(oCaster, nCastingClass, nSpellID, nSpellLevel);

        //---------------------------------------------------------------------------
        // Run New Spellbook Spell Check
        //---------------------------------------------------------------------------
        if (nContinue)
            nContinue = NSB_SpellCast(oCaster, nSpellID, nCastingClass, nMetamagic, nSpellbookType, sComponent, oSpellCastItem);

        //---------------------------------------------------------------------------
        // Run counterspell exploit check
        //---------------------------------------------------------------------------
        if(nContinue)
            nContinue = CounterspellExploitCheck(oCaster);

        //---------------------------------------------------------------------------
        // PnP spellschools
        //---------------------------------------------------------------------------
        if(nContinue)
            nContinue = PnPSpellSchools(oCaster, nCastingClass, nSchool, oSpellCastItem);

        //---------------------------------------------------------------------------
        // Run Red Wizard School Restriction Check
        //---------------------------------------------------------------------------
        if(nContinue)
            nContinue = RedWizRestrictedSchool(oCaster, nSchool, nCastingClass, oSpellCastItem);

        //---------------------------------------------------------------------------
        // PnP somatic components
        //---------------------------------------------------------------------------
        if(nContinue)
            nContinue = PnPSomaticComponents(oCaster, oSpellCastItem, sComponent, nMetamagic);

        //-----------------------------------------------------------------------
        // Shifting casting restrictions
        //-----------------------------------------------------------------------
        if(nContinue)
            nContinue = ShifterCasting(oCaster, oSpellCastItem, nSpellLevel, nMetamagic, sComponent);

        //---------------------------------------------------------------------------
        // Run Material Component Check
        //---------------------------------------------------------------------------
        if(nContinue)
            nContinue = MaterialComponents(oCaster, nSpellID, nCastingClass, oSpellCastItem);

        //---------------------------------------------------------------------------
        // Run Class Spell-like-ability Check
        //---------------------------------------------------------------------------
        if (nContinue)
            nContinue = ClassSLAStore(oCaster, nSpellID, nCastingClass, nSpellLevel);
            
        //---------------------------------------------------------------------------
        // Run Wild Mage's Wildstrike
        //---------------------------------------------------------------------------
        if (nContinue)
            nContinue =  Wildstrike(oCaster);

        //---------------------------------------------------------------------------
        // Run Inscribe Rune Check
        //---------------------------------------------------------------------------
        if (nContinue)
            nContinue = InscribeRune();

        //---------------------------------------------------------------------------
        // Run Attune Gem Check
        //---------------------------------------------------------------------------
        if (nContinue)
            nContinue = AttuneGem();

        //---------------------------------------------------------------------------
        // Run use magic device skill check
        //---------------------------------------------------------------------------
        if (nContinue)
            nContinue = X2UseMagicDeviceCheck(oCaster);

        //-----------------------------------------------------------------------
        // run any user defined spellscript here
        //-----------------------------------------------------------------------
        if (nContinue)
            nContinue = X2RunUserDefinedSpellScript();

        //-----------------------------------------------------------------------
        // run any object-specific spellscript here
        //-----------------------------------------------------------------------
        if (nContinue)
            nContinue = PRCRunUserSpecificSpellScript();

        //-----------------------------------------------------------------------
        // Check if spell was used for Duskblade channeling
        //-----------------------------------------------------------------------
        if (nContinue)
            nContinue = DuskbladeArcaneChanneling(oCaster, oTarget, nSpellID, nCasterLevel, nMetamagic, oSpellCastItem);

        //-----------------------------------------------------------------------
        // PnP Familiar - deliver touch spell
        //-----------------------------------------------------------------------
        if(nContinue)
            nContinue = DeliverTouchSpell(oCaster, oTarget, nSpellID, nCasterLevel, nSaveDC, nMetamagic, oSpellCastItem);

        //---------------------------------------------------------------------------
        // The following code is only of interest if an item was targeted
        //---------------------------------------------------------------------------
        if(GetIsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_ITEM)
        {
            //-----------------------------------------------------------------------
            // Check if spell was used to trigger item creation feat
            //-----------------------------------------------------------------------
            if (nContinue)
                nContinue = !ExecuteScriptAndReturnInt("x2_pc_craft", oCaster);

            //-----------------------------------------------------------------------
            // Check if spell was used for on a sequencer item
            // Check if spell was used for Arcane Archer Imbue Arrow
            // Check if spell was used for Spellsword ChannelSpell
            //-----------------------------------------------------------------------
            if (nContinue)
                nContinue = (!X2GetSpellCastOnSequencerItem(oTarget, oCaster, nSpellID, nMetamagic, nCasterLevel, nSaveDC, bSpellIsHostile, oSpellCastItem));

            //-----------------------------------------------------------------------
            // * Execute item OnSpellCast At routing script if activated
            //-----------------------------------------------------------------------
            if(nContinue)
            {
                SetUserDefinedItemEventNumber(X2_ITEM_EVENT_SPELLCAST_AT);
                //Tag-based PRC scripts first
                int nRet = ExecuteScriptAndReturnInt("is_"+GetTag(oTarget), OBJECT_SELF);
                if(nRet == X2_EXECUTE_SCRIPT_END)
                    return FALSE;

                if(GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS) == TRUE)
                {
                    nRet = ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oTarget), OBJECT_SELF);
                    if(nRet == X2_EXECUTE_SCRIPT_END)
                        return FALSE;
                }
            }

            //-----------------------------------------------------------------------
            // Prevent any spell that has no special coding to handle targetting of items
            // from being cast on items. We do this because we can not predict how
            // all the hundreds spells in NWN will react when cast on items
            //-----------------------------------------------------------------------
            if (nContinue)
                nContinue = X2CastOnItemWasAllowed(oTarget);
        }
    }

    if(nContinue)
    {
        //eldritch spellweave
        EldritchSpellweave(oCaster, oTarget, nSpellLevel, bSpellIsHostile);

        //spellsharing
        SpellSharing(oCaster, oTarget, nSpellID, nCasterLevel, nSaveDC, nMetamagic, oSpellCastItem);

        // Combat medic healing kicker
        CombatMedicHealingKicker(oCaster, oTarget, nSpellID);
        
        // Wyrmbane Helm Frightful Presence
        WyrmbaneFrightful(oCaster);        

        // Havoc Mage Battlecast
        Battlecast(oCaster, oTarget, oSpellCastItem, nSpellLevel);

        // Draconic Feat effects
        DraconicFeatsOnSpell(oCaster, oTarget, oSpellCastItem, nSpellLevel, nCastingClass);
        
        // Wand Feats
        MasterWand(oCaster, oSpellCastItem, nSpellLevel);
        DoubleWandWielder(oCaster, oSpellCastItem, oTarget);
        
        // Incarnum
        MeldArcaneFocus(oCaster, oTarget);
        Integument(oCaster, nCastingClass);
        
        // Mystery
        EchoSpell(oCaster, nSpellID);        
        
        // Races
        ArkamoiStrength(oCaster, nCastingClass);
        WarsoulTyrant(oCaster, nCastingClass);
        RedspawnHealing(oCaster, nSpellID, nSpellLevel);

        // Feats
        DazzlingIllusion(oCaster, nSchool);
        EnergyAbjuration(oCaster, nSchool, nSpellLevel);
        InsightfulDivination(oCaster, nSchool, nSpellLevel);
        TougheningTransmutation(oCaster, nSchool);
        CloudyConjuration(oCaster, nSchool, oSpellCastItem);

        // Reserve Feats
        if(GetLocalInt(oCaster, "ReserveFeatsRunning")) OnePingOnly(oCaster);
        if(GetLocalInt(oCaster, "DoMysticBacklash")) MysticBacklash(oCaster);
    }

    if(bIsPC)
    {
        if(GetPRCSwitch(PRC_PW_SPELL_TRACKING))
        {
            if(!GetLocalInt(oCaster, "UsingActionCastSpell"))
            {
                string sSpell = IntToString(nOrigSpellID)+"|"; //use original spellID
                string sStored = GetPersistantLocalString(oCaster, "persist_spells");
                SetPersistantLocalString(oCaster, "persist_spells", sStored+sSpell);
            }
        }

        //Cleaning spell variables used for holding the charge
        if(!GetLocalInt(oCaster, "PRC_SPELL_EVENT"))
        {
            DeleteLocalInt(oCaster, "PRC_SPELL_CHARGE_COUNT");
            DeleteLocalInt(oCaster, "PRC_SPELL_CHARGE_SPELLID");
            DeleteLocalObject(oCaster, "PRC_SPELL_CONC_TARGET");
            DeleteLocalInt(oCaster, "PRC_SPELL_METAMAGIC");
            DeleteLocalManifestation(oCaster, "PRC_POWER_HOLD_MANIFESTATION");
            DeleteLocalMystery(oCaster, "MYST_HOLD_MYST");
        }
        else if(GetLocalInt(oCaster, "PRC_SPELL_CHARGE_SPELLID") != nSpellID)
        {   //Sanity check, in case something goes wrong with the action queue
            DeleteLocalInt(oCaster, "PRC_SPELL_EVENT");
        }
        DeleteLocalInt(oCaster, "SpellIsSLA");
    }

    return nContinue;
}


// Test main
//:: void main(){}