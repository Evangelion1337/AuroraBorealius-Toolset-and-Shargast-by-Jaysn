//::///////////////////////////////////////////////
//:: PRC Bonus Domains
//:: prc_inc_domain.nss
//:://////////////////////////////////////////////
//:: Handles all of the code for bonus domains.
//:://////////////////////////////////////////////
//:: Created By: Stratovarius.
//:: Created On: August 31st, 2005
//:://////////////////////////////////////////////

//:: Updated for .35 by Jaysyn 2023/03/10


// Function returns the domain in the input slot.
// A person can have a maximum of 5 bonus domains.
int GetBonusDomain(object oPC, int nSlot);

// Function will add a bonus domain to the stored list on the character.
void AddBonusDomain(object oPC, int nDomain);

// Uses the slot and level to find the appropriate spell, then casts it using ActionCastSpell
// It will also decrement a spell from that level
// If the domain does not have an appropriate spell for that level, an error message appears and nothing happens
void CastDomainSpell(object oPC, int nSlot, int nLevel);

// Takes the domain and spell level and uses it to find the appropriate spell.
// Right now it uses 2da reads on the domains.2da, although it could be scripted if desired.
int GetDomainSpell(int nDomain, int nLevel, object oPC);

// Takes the spell level, and returns the radial feat for that level.
// Used in case there is no spell of the appropriate level.
int SpellLevelToFeat(int nLevel);

// Will return the domain name as a string
// This is used to tell a PC what domains he has in what slot
string GetDomainName(int nDomain);

// This is the starter function, and fires from Enter and Levelup
// It checks all of the bonus domain feats, and gives the PC the correct domains
void CheckBonusDomains(object oPC);

// Returns the spell to be burned for CastDomainSpell
int GetBurnableSpell(object oPC, int nLevel);

// Returns the Domain Power feat
int GetDomainFeat(int nDomain);

// Returns the Uses per day of the feat entered
int GetDomainFeatUsesPerDay(int nFeat, object oPC);

// This counts down the number of times a domain has been used in a day
// Returns TRUE if the domain use is valid
// Returns FALSE if the player is out of uses per day
int DecrementDomainUses(int nDomain, object oPC);

// Used to determine which domain has cast the Turn Undead spell
// Returns the domain constant
int GetTurningDomain(int nSpell);

// Checks to see if the player has a domain.
// Looks for the domain power constants since every domain has those
int GetHasDomain(object oPC, int nDomain);

// Cleans the ints that limit the domain spells to being cast 1/day
void BonusDomainRest(object oPC);

//#include "prc_inc_clsfunc"
#include "prc_alterations"
#include "prc_getbest_inc"
#include "inc_dynconv"

int GetBonusDomain(object oPC, int nSlot)
{
    /*string sName = "PRCBonusDomain" + IntToString(nSlot);
    // Return value in case there is nothing in the slot
    int nDomain = 0;
    nDomain = GetPersistantLocalInt(oPC, sName);*/

    return GetPersistantLocalInt(oPC, "PRCBonusDomain" + IntToString(nSlot));
}

void AddBonusDomain(object oPC, int nDomain)
{
    //if(DEBUG) DoDebug("AddBonusDomain is running.");

    // Loop through the domain slots to see if there is an open one.
    int nSlot = 1;
    int nTest = GetBonusDomain(oPC, nSlot);
    while(nTest > 0 && 5 >= nSlot)
    {
        nSlot += 1;
        // If the test domain and the domain to be added are the same
        // shut down the function, since you don't want to add a domain twice.
        if(nTest == nDomain)
        {
            //FloatingTextStringOnCreature("You already have this domain as a bonus domain.", oPC, FALSE);
            return;
        }
        nTest = GetBonusDomain(oPC, nSlot);
    }
    // If you run out of slots, display message and end function
    if (nSlot > 5)
    {
        FloatingTextStringOnCreature("You have more than 5 bonus domains, your last domain is lost.", oPC, FALSE);
        return;
    }

    // If we're here, we know we have an open slot, so we add the domain into it.
    string sName = "PRCBonusDomain" + IntToString(nSlot);
    SetPersistantLocalInt(oPC, sName, nDomain);
    FloatingTextStringOnCreature("You have " + GetStringByStrRef(StringToInt(Get2DACache("prc_domains", "Name", nDomain - 1))) + " as a bonus domain", oPC, FALSE);
}

int TestSpellTarget(object oPC, object oTarget, int nSpell)
{
    int nTargetType = ~(HexToInt(Get2DACache("spells", "TargetType", nSpell)));

    if(oTarget == oPC && nTargetType & 1)
    {
        SendMessageToPC(oPC, "You cannot target yourself!");
        return FALSE;
    }
    else if(GetIsObjectValid(oTarget))
    {
        int nObjectType = GetObjectType(oTarget);
        if(nObjectType == OBJECT_TYPE_CREATURE && nTargetType & 2)
        {
            SendMessageToPC(oPC, "You cannot target creatures");
            return FALSE;
        }
        else if(nObjectType == OBJECT_TYPE_ITEM && nTargetType & 8)
        {
            SendMessageToPC(oPC, "You cannot target items");
            return FALSE;
        }
        else if(nObjectType == OBJECT_TYPE_DOOR && nTargetType & 16)
        {
            SendMessageToPC(oPC, "You cannot target doors");
            return FALSE;
        }
        else if(nObjectType == OBJECT_TYPE_PLACEABLE && nTargetType & 32)
        {
            SendMessageToPC(oPC, "You cannot target placeables");
            return FALSE;
        }
    }
    else if(nTargetType & 4)
    {
        SendMessageToPC(oPC, "You cannot target locations");
        return FALSE;
    }
    return TRUE;
}

// Classes using new spellbook systems are handeled separately
int GetIsBioDivineClass(int nClass)
{
    return nClass == CLASS_TYPE_CLERIC
		|| nClass == CLASS_TYPE_DRUID
		|| nClass == CLASS_TYPE_PALADIN
		|| nClass == CLASS_TYPE_SHAMAN
		|| nClass == CLASS_TYPE_UR_PRIEST
		|| nClass == CLASS_TYPE_OCULAR
		|| nClass == CLASS_TYPE_RANGER;
}

void CastDomainSpell(object oPC, int nSlot, int nLevel)
{
    if(GetLocalInt(oPC, "DomainCastSpell" + IntToString(nLevel))) //Already cast a spell of this level?
    {
        FloatingTextStringOnCreature("You have already cast your domain spell for level " + IntToString(nLevel), oPC, FALSE);
        return;
    }

    int nSpell = GetDomainSpell(GetBonusDomain(oPC, nSlot), nLevel, oPC);
    // If there is no spell for that level, you cant cast it.
    if(nSpell == -1)
        return;

    // Subradial spells are handled through conversation
    int bSubRadial = Get2DACache("spells", "SubRadSpell1", nSpell) != "";

    // Domain casting feats use generic targeting, so check if spell can be cast at selected target
    object oTarget = GetSpellTargetObject();
    if(!bSubRadial && !TestSpellTarget(oPC, oTarget, nSpell))
        return;

    int nClass, nCount, nMetamagic = METAMAGIC_NONE;

    // Mystic is a special case - checked first
    if(GetLevelByClass(CLASS_TYPE_MYSTIC, oPC) || GetLevelByClass(CLASS_TYPE_NIGHTSTALKER, oPC))
    {
        // Mystics can use metamagic with domain spells
        nClass = GetLevelByClass(CLASS_TYPE_MYSTIC, oPC) ? CLASS_TYPE_MYSTIC : CLASS_TYPE_NIGHTSTALKER;
        nMetamagic = GetLocalInt(oPC, "MetamagicFeatAdjust");
        int nSpellLevel = nLevel;
        if(nMetamagic)
        {
            //Need to check if metamagic can be applied to a spell
            int nMetaTest;
            int nMetaType = HexToInt(Get2DACache("spells", "MetaMagic", nSpell));

            switch(nMetamagic)
            {
                case METAMAGIC_NONE:     nMetaTest = 1; break; //no need to change anything
                case METAMAGIC_EMPOWER:  nMetaTest = nMetaType &  1; nSpellLevel += 2; break;
                case METAMAGIC_EXTEND:   nMetaTest = nMetaType &  2; nSpellLevel += 1; break;
                case METAMAGIC_MAXIMIZE: nMetaTest = nMetaType &  4; nSpellLevel += 3; break;
                case METAMAGIC_QUICKEN:  nMetaTest = nMetaType &  8; nSpellLevel += 4; break;
                case METAMAGIC_SILENT:   nMetaTest = nMetaType & 16; nSpellLevel += 1; break;
                case METAMAGIC_STILL:    nMetaTest = nMetaType & 32; nSpellLevel += 1; break;
            }
            if(!nMetaTest)//can't use selected metamagic with this spell
            {
                nMetamagic = METAMAGIC_NONE;
                ActionDoCommand(SendMessageToPC(oPC, "You can't use "+GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpell)))+"with selected metamagic."));
                nSpellLevel = nLevel;
            }
            else if(nLevel > 9)//now test the spell level
            {
                nMetamagic = METAMAGIC_NONE;
                ActionDoCommand(SendMessageToPC(oPC, "Modified spell level is to high! Casting spell without metamagic"));
                nSpellLevel = nLevel;
            }
            else if(GetLocalInt(oPC, "PRC_metamagic_state") == 1)
                SetLocalInt(oPC, "MetamagicFeatAdjust", 0);
        }

        nCount = persistant_array_get_int(oPC, "NewSpellbookMem_" + IntToString(CLASS_TYPE_MYSTIC), nSpellLevel);
        // we can't cast metamagiced version of the spell - assuming that player want to cast the spell anyway
        if(!nCount)
            nCount = persistant_array_get_int(oPC, "NewSpellbookMem_" + IntToString(CLASS_TYPE_MYSTIC), nLevel);
        // Do we have slots available?
        if(nCount)
        {
            // Prepare to cast the spell
            nLevel = nSpellLevel;//correct the spell level if we're using metamagic
            SetLocalInt(oPC, "NSB_Class", nClass);
            SetLocalInt(oPC, "NSB_SpellLevel", nLevel);
        }
    }

    // checking 'newspellbook' classes is much faster than checking bioware spellbooks
    if(!nCount)
    {
        int n;
        for(n = 1; n < 9; n++)
        {
            nClass = GetClassByPosition(n, oPC);

            // Check to see if you can burn a spell of that slot or if the person has already
            // cast all of their level X spells for the day
            if(!GetIsBioDivineClass(nClass))
            {
                int nSpellbook = GetSpellbookTypeForClass(nClass);
                if(nSpellbook == SPELLBOOK_TYPE_SPONTANEOUS)
                {
                    nCount = persistant_array_get_int(oPC, "NewSpellbookMem_" + IntToString(nClass), nLevel);
                    if(nCount)
                    {// Prepare to cast the spell
                        SetLocalInt(oPC, "NSB_Class", nClass);
                        SetLocalInt(oPC, "NSB_SpellLevel", nLevel);
                    }
                }
                else if(nSpellbook == SPELLBOOK_TYPE_PREPARED)
                {
                    string sArray = "NewSpellbookMem_"+IntToString(nClass);
                    string sIDX = "SpellbookIDX" + IntToString(nLevel) + "_" + IntToString(nClass);
                    int i, nSpellbookID, nMax = persistant_array_get_size(oPC, sIDX);
                    for(i = 0; i < nMax; i++)
                    {
                        nSpellbookID = persistant_array_get_int(oPC, sIDX, i);
                        nCount = persistant_array_get_int(oPC, sArray, nSpellbookID);
                        if(nCount)
                        {
                            SetLocalInt(oPC, "NSB_Class", nClass);
                            SetLocalInt(oPC, "NSB_SpellbookID", nSpellbookID);
                            break;
                        }
                    }
                }
            }
            if(nCount)
                //we have found valid spell slot, no point in running this loop again
                break;
        }
    }

    // test bioware spellbooks
    if(!nCount)
    {
        nCount = GetBurnableSpell(oPC, nLevel) + 1;//fix for Acid Fog spell
        if(nCount)
        {
            SetLocalInt(oPC, "Domain_BurnableSpell", nCount);
            nClass = GetPrimaryDivineClass(oPC);
        }
    }

    //No spell left to burn? Tell the player that.
    if(!nCount)
    {
        FloatingTextStringOnCreature("You have no spells left to trade for a domain spell.", oPC, FALSE);
        return;
    }

    SetLocalInt(oPC, "DomainCast", nLevel);
    if(bSubRadial)
    {
        SetLocalInt(oPC, "DomainOrigSpell", nSpell);
        SetLocalInt(oPC, "DomainCastClass", nClass);
        SetLocalObject(oPC, "DomainTarget", oTarget);
        SetLocalLocation(oPC, "DomainTarget", GetSpellTargetLocation());
        StartDynamicConversation("prc_domain_conv", oPC, DYNCONV_EXIT_NOT_ALLOWED, FALSE, TRUE, oPC);
    }
    else
    {
        if(nMetamagic & METAMAGIC_QUICKEN)
        {
            //Adding Auto-Quicken III for one round - deleted after casting is finished.
            object oSkin = GetPCSkin(oPC);
            int nCastDur = StringToInt(Get2DACache("spells", "ConjTime", nSpell)) + StringToInt(Get2DACache("spells", "CastTime", nSpell));
            itemproperty ipAutoQuicken = ItemPropertyBonusFeat(IP_CONST_NSB_AUTO_QUICKEN);
            ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoQuicken, oSkin, nCastDur/1000.0f));
        }
        int nDC = 10 + nLevel + GetDCAbilityModForClass(nClass, oPC);
        ActionCastSpell(nSpell, 0, nDC, 0, nMetamagic, nClass, FALSE, FALSE, OBJECT_INVALID, FALSE);
        ActionDoCommand(DeleteLocalInt(oPC, "DomainCast"));
    }
}

int GetDomainSpell(int nDomain, int nLevel, object oPC)
{
    // The -1 on nDomains is to adjust from a base 1 to a base 0 system.
    string sSpell = Get2DACache("prc_domains", "Level_" + IntToString(nLevel), (nDomain - 1));
    if (DEBUG) DoDebug("Domain Spell: " + sSpell);
    //if (DEBUG) DoDebug("GetDomainSpell has fired");
    int nSpell = -1;
    if(sSpell == "")
    {
        FloatingTextStringOnCreature("You do not have a domain spell of that level.", oPC, FALSE);
        //int nFeat = SpellLevelToFeat(nLevel);
        //IncrementRemainingFeatUses(oPC, nFeat);
    }
    else
    {
        nSpell = StringToInt(sSpell);
    }

    return nSpell;
}

int SpellLevelToFeat(int nLevel)
{
    switch(nLevel)
    {
        case 1: return FEAT_CAST_DOMAIN_LEVEL_ONE;
        case 2: return FEAT_CAST_DOMAIN_LEVEL_TWO;
        case 3: return FEAT_CAST_DOMAIN_LEVEL_THREE;
        case 4: return FEAT_CAST_DOMAIN_LEVEL_FOUR;
        case 5: return FEAT_CAST_DOMAIN_LEVEL_FIVE;
        case 6: return FEAT_CAST_DOMAIN_LEVEL_SIX;
        case 7: return FEAT_CAST_DOMAIN_LEVEL_SEVEN;
        case 8: return FEAT_CAST_DOMAIN_LEVEL_EIGHT;
        case 9: return FEAT_CAST_DOMAIN_LEVEL_NINE;
    }

    return -1;
}

string GetDomainName(int nDomain)
{
    string sName;
    // Check that the domain slot is not empty
    if(nDomain)
    {
        sName = Get2DACache("prc_domains", "Name", (nDomain - 1));
        sName = GetStringByStrRef(StringToInt(sName));
    }
    else
        sName = GetStringByStrRef(6497); // "Empty Slot"

    return sName;
}

void CheckBonusDomains(object oPC)
{
    int nBonusDomain, nDomainFeat;
    int nSlot = 1;
    while(nSlot < 6)
    {
        nBonusDomain = GetBonusDomain(oPC, nSlot);
        nDomainFeat = GetDomainFeat(nBonusDomain);
        if(!GetHasFeat(nDomainFeat, oPC)) SetPersistantLocalInt(oPC, "PRCBonusDomain" + IntToString(nSlot), 0);
        //SendMessageToPC(oPC, "PRCBonusDomain"+IntToString(nSlot)" = "+IntToString(nBonusDomain));
        //SendMessageToPC(oPC, "PRCBonusDomain"+IntToString(nSlot)" feat = "+IntToString(GetDomainFeat(nDomainFeat)));
        nSlot += 1;
    }

    if (GetHasFeat(FEAT_BONUS_DOMAIN_AIR,           oPC)) AddBonusDomain(oPC, PRC_DOMAIN_AIR);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_ANIMAL,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_ANIMAL);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_DEATH,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_DEATH);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_DESTRUCTION,   oPC)) AddBonusDomain(oPC, PRC_DOMAIN_DESTRUCTION);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_EARTH,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_EARTH);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_EVIL,          oPC)) AddBonusDomain(oPC, PRC_DOMAIN_EVIL);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_FIRE,          oPC)) AddBonusDomain(oPC, PRC_DOMAIN_FIRE);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_GOOD,          oPC)) AddBonusDomain(oPC, PRC_DOMAIN_GOOD);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_HEALING,       oPC)) AddBonusDomain(oPC, PRC_DOMAIN_HEALING);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_KNOWLEDGE,     oPC)) AddBonusDomain(oPC, PRC_DOMAIN_KNOWLEDGE);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_MAGIC,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_MAGIC);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_PLANT,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_PLANT);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_PROTECTION,    oPC)) AddBonusDomain(oPC, PRC_DOMAIN_PROTECTION);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_STRENGTH,      oPC)) AddBonusDomain(oPC, PRC_DOMAIN_STRENGTH);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_SUN,           oPC)) AddBonusDomain(oPC, PRC_DOMAIN_SUN);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_TRAVEL,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_TRAVEL);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_TRICKERY,      oPC)) AddBonusDomain(oPC, PRC_DOMAIN_TRICKERY);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_WAR,           oPC)) AddBonusDomain(oPC, PRC_DOMAIN_WAR);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_WATER,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_WATER);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_DARKNESS,      oPC)) AddBonusDomain(oPC, PRC_DOMAIN_DARKNESS);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_STORM,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_STORM);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_METAL,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_METAL);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_PORTAL,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_PORTAL);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_FORCE,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_FORCE);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_SLIME,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_SLIME);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_TYRANNY,       oPC)) AddBonusDomain(oPC, PRC_DOMAIN_TYRANNY);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_DOMINATION,    oPC)) AddBonusDomain(oPC, PRC_DOMAIN_DOMINATION);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_SPIDER,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_SPIDER);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_UNDEATH,       oPC)) AddBonusDomain(oPC, PRC_DOMAIN_UNDEATH);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_TIME,          oPC)) AddBonusDomain(oPC, PRC_DOMAIN_TIME);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_DWARF,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_DWARF);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_CHARM,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_CHARM);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_ELF,           oPC)) AddBonusDomain(oPC, PRC_DOMAIN_ELF);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_FAMILY,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_FAMILY);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_FATE,          oPC)) AddBonusDomain(oPC, PRC_DOMAIN_FATE);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_GNOME,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_GNOME);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_ILLUSION,      oPC)) AddBonusDomain(oPC, PRC_DOMAIN_ILLUSION);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_HATRED,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_HATRED);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_HALFLING,      oPC)) AddBonusDomain(oPC, PRC_DOMAIN_HALFLING);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_NOBILITY,      oPC)) AddBonusDomain(oPC, PRC_DOMAIN_NOBILITY);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_OCEAN,         oPC)) AddBonusDomain(oPC, PRC_DOMAIN_OCEAN);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_ORC,           oPC)) AddBonusDomain(oPC, PRC_DOMAIN_ORC);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_RENEWAL,       oPC)) AddBonusDomain(oPC, PRC_DOMAIN_RENEWAL);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_RETRIBUTION,   oPC)) AddBonusDomain(oPC, PRC_DOMAIN_RETRIBUTION);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_RUNE,          oPC)) AddBonusDomain(oPC, PRC_DOMAIN_RUNE);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_SPELLS,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_SPELLS);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_SCALEYKIND,    oPC)) AddBonusDomain(oPC, PRC_DOMAIN_SCALEYKIND);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_BLIGHTBRINGER, oPC)) AddBonusDomain(oPC, PRC_DOMAIN_BLIGHTBRINGER);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_DRAGON,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_DRAGON);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_COLD,          oPC)) AddBonusDomain(oPC, PRC_DOMAIN_COLD);
    if (GetHasFeat(FEAT_BONUS_DOMAIN_WINTER,        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_WINTER);
	if (GetHasFeat(FEAT_BONUS_DOMAIN_CHAOS,	        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_CHAOS);
	if (GetHasFeat(FEAT_BONUS_DOMAIN_LAW,	        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_LAW);
	if (GetHasFeat(FEAT_BONUS_DOMAIN_LUCK,	        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_LUCK);
	if (GetHasFeat(FEAT_BONUS_DOMAIN_GLORY,	        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_GLORY);
	if (GetHasFeat(FEAT_BONUS_DOMAIN_MADNESS,		oPC)) AddBonusDomain(oPC, PRC_DOMAIN_MADNESS);
	if (GetHasFeat(FEAT_BONUS_DOMAIN_MIND,	        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_MIND);
	if (GetHasFeat(FEAT_BONUS_DOMAIN_MOON,	        oPC)) AddBonusDomain(oPC, PRC_DOMAIN_MOON);	
																			  
    //if (DEBUG) FloatingTextStringOnCreature("Check Bonus Domains is running", oPC, FALSE);
}

int GetBurnableSpell(object oPC, int nLevel)
{
    int nBurnableSpell = -1;

    if (nLevel == 1)      nBurnableSpell = GetBestL1Spell(oPC, nBurnableSpell);
    else if (nLevel == 2) nBurnableSpell = GetBestL2Spell(oPC, nBurnableSpell);
    else if (nLevel == 3) nBurnableSpell = GetBestL3Spell(oPC, nBurnableSpell);
    else if (nLevel == 4) nBurnableSpell = GetBestL4Spell(oPC, nBurnableSpell);
    else if (nLevel == 5) nBurnableSpell = GetBestL5Spell(oPC, nBurnableSpell);
    else if (nLevel == 6) nBurnableSpell = GetBestL6Spell(oPC, nBurnableSpell);
    else if (nLevel == 7) nBurnableSpell = GetBestL7Spell(oPC, nBurnableSpell);
    else if (nLevel == 8) nBurnableSpell = GetBestL8Spell(oPC, nBurnableSpell);
    else if (nLevel == 9) nBurnableSpell = GetBestL9Spell(oPC, nBurnableSpell);

    return nBurnableSpell;
}

int GetDomainFeat(int nDomain)
{
    // The -1 on nDomain is to adjust from a base 1 to a base 0 system.
    // Returns the domain power feat
    return StringToInt(Get2DACache("domains", "GrantedFeat", nDomain - 1));
}

int GetDomainFeatUsesPerDay(int nFeat, object oPC)
{
    int nUses = StringToInt(Get2DACache("feat", "USESPERDAY", nFeat));
    // These are the domains that have ability based uses per day
    if (nUses == 33)
    {
        // The Strength domain, which uses Strength when the Cleric has Kord levels
        // Without Kord levels, its 1 use per day
        if(nFeat == FEAT_STRENGTH_DOMAIN_POWER)
        {
            nUses = 1;
            if(GetLevelByClass(CLASS_TYPE_MIGHTY_CONTENDER_KORD, oPC)) nUses = GetAbilityModifier(ABILITY_STRENGTH, oPC);
            // Catching exceptions
            if(nUses < 1) nUses = 1;
        }
        if(nFeat == FEAT_SUN_DOMAIN_POWER)
        {
            if(GetHasFeat(FEAT_BONUS_DOMAIN_SUN, oPC) && GetLevelByClass(CLASS_TYPE_MYSTIC, oPC))
            {
                nUses = GetHasFeat(FEAT_EXTRA_TURNING, oPC) ? 7 : 3;
                nUses += GetAbilityModifier(ABILITY_CHARISMA, oPC);
            }
            else
                nUses = 1;
        }

        // All other ones so far are the Charisma based turning domains
        nUses = 3 + GetAbilityModifier(ABILITY_CHARISMA, oPC);
    }

    return nUses;
}

int DecrementDomainUses(int nDomain, object oPC)
{
    int nReturn = TRUE;
    int nUses = GetLocalInt(oPC, "BonusDomainUsesPerDay" + GetDomainName(nDomain));
    // If there is still a valid use left, remove it
    if (nUses >= 1) SetLocalInt(oPC, "BonusDomainUsesPerDay" + GetDomainName(nDomain), (nUses - 1));
    // Tell the player how many uses he has left
    else // He has no more uses for the day
    {
        nReturn = FALSE;
    }

    FloatingTextStringOnCreature("You have " + IntToString(nUses - 1) + " uses per day left of the " + GetDomainName(nDomain) + " power.", oPC, FALSE);

    return nReturn;
}

int GetTurningDomain(int nSpell)
{
    switch(nSpell)
    {
        case SPELL_TURN_REPTILE:       		return PRC_DOMAIN_SCALEYKIND;
        case SPELL_TURN_OOZE:          		return PRC_DOMAIN_SLIME;
        case SPELL_TURN_SPIDER:        		return PRC_DOMAIN_SPIDER;
        case SPELL_TURN_PLANT:         		return PRC_DOMAIN_PLANT;
        case SPELL_TURN_AIR:           		return PRC_DOMAIN_AIR;
        case SPELL_TURN_EARTH:         		return PRC_DOMAIN_EARTH;
        case SPELL_TURN_FIRE:          		return PRC_DOMAIN_FIRE;
        case SPELL_TURN_WATER:         		return PRC_DOMAIN_WATER;
        case SPELL_TURN_BLIGHTSPAWNED: 		return PRC_DOMAIN_BLIGHTBRINGER;
		case SPELL_DOMAIN_POWER_MADNESS:	return PRC_DOMAIN_MADNESS;
		case SPELL_DOMAIN_POWER_MOON:		return PRC_DOMAIN_MOON;
    }

    return -1;
}

int GetHasDomain(object oPC, int nDomain)
{
    // Get the domain power feat for the appropriate domain
    int nFeat = GetDomainFeat(nDomain);

    return GetHasFeat(nFeat, oPC);
}

void BonusDomainRest(object oPC)
{
    // Bonus Domain ints that limit you to casting 1/day per level
    int i;
    for (i = 1; i < 10; i++)
    {
        DeleteLocalInt(oPC, "DomainCastSpell" + IntToString(i));
    }

    // This is code to stop you from using the Domain per day abilities more than you should be able to
    int i2;
    // Highest domain constant is 62
    for (i2 = 1; i2 < 63; i2++)
    {
        // This is to ensure they only get the ints set for the domains they do have
        if (GetHasDomain(oPC, i2))
        {
            // Store the number of uses a day here
            SetLocalInt(oPC, "BonusDomainUsesPerDay" + GetDomainName(i2), GetDomainFeatUsesPerDay(GetDomainFeat(i2), oPC));
        }
    }
}

int GetDomainCasterLevel(object oPC)
{
    return GetLevelByClass(CLASS_TYPE_CLERIC, oPC)
          + GetLevelByClass(CLASS_TYPE_MYSTIC, oPC)
          + GetLevelByClass(CLASS_TYPE_SHAMAN, oPC)
          + GetLevelByClass(CLASS_TYPE_TEMPLAR, oPC)
          + GetLevelByClass(CLASS_TYPE_BLIGHTLORD, oPC)
          + GetLevelByClass(CLASS_TYPE_CONTEMPLATIVE, oPC)
          + GetLevelByClass(CLASS_TYPE_MASTER_OF_SHROUDS, oPC);
}

//:: void main (){}