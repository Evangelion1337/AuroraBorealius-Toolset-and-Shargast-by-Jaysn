/**
 * @file
 * PRC functions that are wrappers for functions defined in nwscript.nss
 */
const int PRC_SIZEMASK_NONE = 0;           // no changes taken into account, same as bio size with fixes for CEP
const int PRC_SIZEMASK_NORMAL = 1;         // normal size changes
const int PRC_SIZEMASK_NOABIL = 2;         // size changes that dont change ability scores
const int PRC_SIZEMASK_SIMPLE = 4;         // 'simple' size changes that have simplified effects (expansion/compression)

const int PRC_SIZEMASK_ALL = 7;            // PRC_SIZEMASK_NORMAL | PRC_SIZEMASK_NOABIL | PRC_SIZEMASK_SIMPLE

const int PRC_SIZEMASK_PRC = 0x08; // For systems that need PRC size scale

//wrapper for biowares GetSpellId()
//used for actioncastspell
int PRCGetSpellId(object oCaster = OBJECT_SELF);

/**
 * A wrapper for EnterTargetingMode().
 *
 * Stores a variable on oPC to use w/ the onPlayerTarget event.
 *
 */
void PRCEnterTargetingMode(object oPC, int nValidObjectTypes, int nMouseCursorId, string sActionVariable);

/**
 * A wrapper for GetSpellTargetObject().
 * Handles effects that redirect spell targeting, currently:
 * - Reddopsi
 * - Casting from runes
 *
 * NOTE: Will probably not return a sensible value outside of a spellscript. Assumes
 *       OBJECT_SELF is the object doing the casting.
 *
 * @return The target for the spell whose spellscript is currently being executed.
 */
object PRCGetSpellTargetObject(object oCaster = OBJECT_SELF);

/**
 * A wrapper for GetSpellCastItem().
 *
 * NOTE: Will probably not return a sensible value outside of a spellscript.
 *
 * @return The item from which the spell was cast.
 */
object PRCGetSpellCastItem(object oPC = OBJECT_SELF);

/*
 *  Caches bonus feat itemproperties rather than creating new ones each time
 */
itemproperty PRCItemPropertyBonusFeat(int nBonusFeatID);

//Wrapper for GetIsSkillSuccessful(), allows forcing of a particular roll eg. taking 10
int GetPRCIsSkillSuccessful(object oCreature, int nSkill, int nDifficulty, int nRollOverride = -1);

/**
 * Wrapper for GetCreatureSize().
 *
 * Get the size (CREATURE_SIZE_*) of oCreature, including any PRC size modification feats / spells
 *
 * @param oObject   Creature whose size to get
 * @param nSizeMask Combination of PRC_SIZEMASK_* constants indicating which types of size changes to return
 * @return          CREATURE_SIZE_* constant
 */
int PRCGetCreatureSize(object oObject = OBJECT_SELF, int nSizeMask = PRC_SIZEMASK_ALL);

/**
 * Returns the total value of essentia invested in the meld
 *
 * @param oMeldshaper  The meldshaper
 * @param nMeldId      The meld to check
 *
 * @return             Invested essentia
 */
int GetEssentiaInvested(object oMeldshaper, int nMeld = -1);

/**
 * Returns the chakra the meld is bound to, if any
 *
 * @param oMeldshaper  The meldshaper
 * @param nMeldId      The meld to check
 *
 * @return             Chakra constant
 */
int GetIsMeldBound(object oMeldshaper, int nMeld = -1);

/**
 * Calculates the DC of the soulmeld being currently triggered.
 *
 * @param oMeldshaper  The meldshaper
 * @param nClass       The class to check
 * @param nMeldId      The meld to check
 *
 * @return             The DC
 */
int GetMeldshaperDC(object oMeldshaper, int nClass, int nMeldId);

/**
 * Checks whether meld is a necrocarnum meld
 *
 * @param nMeldId      The meld to check
 *
 * @return             True/False
 */
int GetIsNecrocarnumMeld(int nMeld);

/**
 * Returns ability score for Meldshaping DCs
 *
 * @param nClass  The class to check
 * @param oMeldshaper  The meldshaper
 *
 * @return        ABILITY_*
 */
int GetMeldshaperAbilityOfClass(int nClass, object oMeldshaper);

/**
 * Returns regular chakra when passed a double chakra chakra
 *
 * @param nChakra  The chakra to convert
 *
 * @return        CHAKRA_DOUBLE_*
 */
int DoubleChakraToChakra(int nChakra);

/**
 * Returns true if the meldshaper has used all of their expanded soulmeld capacity
 *
 * @param oMeldshaper  The meldshaper
 *
 * @return        True/False
 */
int GetIsSoulmeldCapacityUsed(object oMeldshaper);

/**
 * Returns true if the meld has used expanded soulmeld capacity
 *
 * @param oMeldshaper  The meldshaper
 * @param nMeld        The meld
 *
 * @return        True/False
 */
int GetExpandedSoulmeld(object oMeldshaper, int nMeld);

/**
 * Does what it says
 *
 * @param oMeldshaper Character to check
 */
int GetIsIncarnumUser(object oMeldshaper);

/**
 * Counts the number of Aberrant feats the PC has
 *
 * @param oPC Character to check
 */
int GetAberrantFeatCount(object oPC);

//////////////////////
//	Constants
//////////////////////

// This line is here to prevent the bioware toolkit from
// throwing an exception over the number of constants in PRC
//const int BIOWARE_INHIBIT = !!0;

#include "prc_misc_const"
#include "prc_spell_const"
#include "inv_invoc_const"
#include "psi_power_const"
#include "prc_inc_racial"
#include "prc_inc_array"
#include "moi_meld_const"
#include "bnd_vestig_const"

// colours for log messages (there's not really a sensible place for this while inc_utility is so messy) maybe inc_debug?
// PRC_TEXT_ prefix to stop clashes with simtools
// Colors in String messages to PCs
const string PRC_TEXT_BLUE         = "<cfÌþ>";    // used by saving throws.
const string PRC_TEXT_DARK_BLUE    = "<c fþ>";    // used for electric damage.
const string PRC_TEXT_GRAY         = "<c™™™>";    // used for negative damage.
const string PRC_TEXT_GREEN        = "<c þ >";    // used for acid damage.
const string PRC_TEXT_LIGHT_BLUE   = "<c™þþ>";    // used for the player's name, and cold damage.
const string PRC_TEXT_LIGHT_GRAY   = "<c°°°>";    // used for system messages.
const string PRC_TEXT_LIGHT_ORANGE = "<cþ™ >";    // used for sonic damage.
const string PRC_TEXT_LIGHT_PURPLE = "<cÌ™Ì>";    // used for a target's name.
const string PRC_TEXT_ORANGE       = "<cþf >";    // used for attack rolls and physical damage.
const string PRC_TEXT_PURPLE       = "<cÌwþ>";    // used for spell casts, as well as magic damage.
const string PRC_TEXT_RED          = "<cþ  >";    // used for fire damage.
const string PRC_TEXT_WHITE        = "<cþþþ>";    // used for positive damage.
const string PRC_TEXT_YELLOW       = "<cþþ >";    // used for healing, and sent messages.

// includes
#include "inc_2dacache"


void PRCEnterTargetingMode(object oPC, int nValidObjectTypes, int nMouseCursorId, string sActionVariable)
{
    // Store the action variable in a local variable
    SetLocalString(oPC, "ONPLAYERTARGET_ACTION", sActionVariable);

    // Enter the targeting mode with the custom parameters
    EnterTargetingMode(oPC, nValidObjectTypes, nMouseCursorId);
}

int PRCGetSpellId(object oCaster = OBJECT_SELF)
{
    int nID = GetLocalInt(oCaster, PRC_SPELLID_OVERRIDE);
    if(!nID)
        return GetSpellId();

    if (DEBUG) DoDebug("PRCGetSpellId: found override spell id = "+IntToString(nID)+", original id = "+IntToString(GetSpellId()));

    if(nID == -1)
        nID = 0;
    return nID;
}

object PRCGetSpellTargetObject(object oCaster = OBJECT_SELF)
{
    if(GetLocalInt(oCaster, "PRC_EF_ARCANE_FIST"))
        return oCaster;
        
    if(GetLocalInt(oCaster, "PsyRogueDanger"))
        return oCaster;         

    object oSpellTarget;

    // is there an override target on the module? (this is only valid if a local int is set)
    if(GetLocalInt(GetModule(), PRC_SPELL_TARGET_OBJECT_OVERRIDE))
    {
        // this could also be an invalid target (so that the module builder can disable targeting)
        oSpellTarget = GetLocalObject(GetModule(), PRC_SPELL_TARGET_OBJECT_OVERRIDE);
        if (DEBUG) DoDebug("PRCGetSpellTargetObject: module override target = "+GetName(oSpellTarget)+", original target = "+GetName(GetSpellTargetObject()));
        return oSpellTarget;
    }

    // motu99: added code to put an override target on the caster
    // we might want to change the preference: so far module overrides have higher preference (to give module builders some extra power :-)
    // if we want caster overrides to have higher preference, put this before the module override check
/*    oSpellTarget = GetLocalObject(oCaster, PRC_SPELL_TARGET_OBJECT_OVERRIDE);
    if (GetIsObjectValid(oSpellTarget))
    {
        if (DEBUG) DoDebug("PRCGetSpellTargetObject: caster override target = "+GetName(oSpellTarget)+", original target = "+GetName(GetSpellTargetObject()));
        return oSpellTarget;
    }
*/
    if(GetLocalInt(oCaster, PRC_SPELL_TARGET_OBJECT_OVERRIDE))
    {
        oSpellTarget = GetLocalObject(oCaster, PRC_SPELL_TARGET_OBJECT_OVERRIDE);
        if (DEBUG) DoDebug("PRCGetSpellTargetObject: caster override target = "+GetName(oSpellTarget)+", original target = "+GetName(GetSpellTargetObject()));
        return oSpellTarget;
    }

    object oBWTarget = GetSpellTargetObject();
    int nSpellID     = PRCGetSpellId(oCaster);
    
    // This shifts everything to a random target within 20 feet for a wild mage
    if (GetLocalInt(oBWTarget, "RandomDeflector"))
    {
        object oRandom = GetFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(20.0), GetLocation(oBWTarget), TRUE, OBJECT_TYPE_CREATURE);
        //Cycle through the targets within the spell shape until an invalid object is captured.
        int nCount = 0;
        while (GetIsObjectValid(oRandom))
        {
            array_set_object(oBWTarget, "WildMageTargets", nCount, oRandom);
            nCount++;

           //Select the next target within the spell shape.
           oRandom = GetNextObjectInShape(SHAPE_SPHERE, FeetToMeters(20.0), GetLocation(oBWTarget), TRUE, OBJECT_TYPE_CREATURE);
        }     
                
        oBWTarget = array_get_object(oBWTarget, "WildMageTargets", Random(nCount));  
        array_delete(oBWTarget, "WildMageTargets");
    }

    //checking whether spells/powers should rebound on caster - assumes only creatures can have spell turning/reddopsi
    if(GetObjectType(oBWTarget) == OBJECT_TYPE_CREATURE && oCaster != oBWTarget)    //if target == caster then we're casting on ourselves or already ran through this code in the same script
    {
        //we only check spells and powers here
        if(nSpellID < 4200 && nSpellID > 16029)    //not newspellbook spell or psionic power
        {
            //does not apply to spellscripts triggered by feats
            if(Get2DACache("spells", "FeatID", nSpellID) != "")
                return oBWTarget;

            //either a feat, or a spell, check to make doubly sure, in the case of monster abilities
            if(
                (Get2DACache("spells", "Wiz_Sorc", nSpellID) == "") &&
                (Get2DACache("spells", "Cleric", nSpellID) == "") &&
                (Get2DACache("spells", "Bard", nSpellID) == "") &&
                (Get2DACache("spells", "Druid", nSpellID) == "") &&
                (Get2DACache("spells", "Paladin", nSpellID) == "") &&
                (Get2DACache("spells", "Ranger", nSpellID) == "")
                )
            return oBWTarget;             //we shouldn't be checking feats or other spellbooks
        }
        
        // Force missile mage reflects all magic missiles
        if (GetLevelByClass(CLASS_TYPE_FMM, oBWTarget) >= 4 && nSpellID == SPELL_MAGIC_MISSILE)
            return oCaster;

        int bTouch = GetStringUpperCase(Get2DACache("spells", "Range", nSpellID)) == "T";
        // Reddopsi power causes spells and powers to rebound onto the caster.
        if(GetLocalInt(oBWTarget, "PRC_Power_Reddopsi_Active")                 &&  // Reddopsi is active on the target
            !GetLocalInt(oCaster, "PRC_Power_Reddopsi_Active")                  &&  // And not on the manifester
            !(nSpellID == SPELL_LESSER_DISPEL             ||                        // And the spell/power is not a dispelling one
            nSpellID == SPELL_DISPEL_MAGIC              ||
            nSpellID == SPELL_GREATER_DISPELLING        ||
            nSpellID == SPELL_MORDENKAINENS_DISJUNCTION ||
            nSpellID == POWER_DISPELPSIONICS
            )                                                                 &&
            !bTouch     // And the spell/power is not touch range
            )
            return oCaster;

        if(GetLocalInt(oBWTarget, "PRC_SPELL_TURNING") &&
            !(nSpellID == SPELL_LESSER_DISPEL             ||                        // And the spell/power is not a dispelling one
                     nSpellID == SPELL_DISPEL_MAGIC              ||
                     nSpellID == SPELL_GREATER_DISPELLING        ||
                     nSpellID == SPELL_MORDENKAINENS_DISJUNCTION ||
                     nSpellID == POWER_DISPELPSIONICS) &&
            !bTouch
            )
        {
            int nSpellLevel = StringToInt(Get2DACache("spells", "Innate", nSpellID));//lookup_spell_innate(nSpellID));
            object oTarget = oBWTarget;
            int nLevels = GetLocalInt(oTarget, "PRC_SPELL_TURNING_LEVELS");
            int bCasterTurning = GetLocalInt(oCaster, "PRC_SPELL_TURNING");
            int nCasterLevels = GetLocalInt(oCaster, "PRC_SPELL_TURNING_LEVELS");
            if(!bCasterTurning)
            {
                if(nSpellLevel > nLevels)
                {
                    if((Random(nSpellLevel) + 1) <= nLevels)
                        oTarget = oCaster;
                }
                else
                    oTarget = oCaster;
            }
            else
            {
                if((Random(nCasterLevels + nLevels) + 1) <= nLevels)
                    oTarget = oCaster;
                nCasterLevels -= nSpellLevel;
                if(nCasterLevels < 0) nCasterLevels = 0;
                SetLocalInt(oCaster, "PRC_SPELL_TURNING_LEVELS", nCasterLevels);
            }
            nLevels -= nSpellLevel;
            if(nLevels < 0) nLevels = 0;
            SetLocalInt(oBWTarget, "PRC_SPELL_TURNING_LEVELS", nLevels);
            return oTarget;
        }
    }
    
    // 50% chance of this happening
    if(GetHasSpellEffect(SPELL_BLINK, oBWTarget) && d2() == 2) 
    	return OBJECT_INVALID;

    // The rune/gem/skull always targets the one who activates it.
    object oItem     = PRCGetSpellCastItem(oCaster);
    if(GetIsObjectValid(oItem) && (GetResRef(oItem) == "prc_rune_1" ||
       GetResRef(oItem) == "prc_skulltalis" || GetTag(oItem) == "prc_attunegem"))
    {
        if(DEBUG) DoDebug(GetName(oCaster) + " has cast a spell using a rune");
        // Making sure that the owner of the item is correct
        if (GetIsObjectValid(GetItemPossessor(oItem)))
        {
            if(DEBUG) DoDebug(GetName(oCaster) + " is the owner of the Spellcasting item");
            return GetItemPossessor(oItem);
        }
    }


    // return Bioware's target
    return oBWTarget;
}

/**
 * PRCGetSpellCastItem(object oCaster = OBJECT_SELF)
 * wrapper function for GetSpellCastItem()
 *
 * Note that we are giving preference for the local object, "PRC_SPELLCASTITEM_OVERRIDE", stored on oCaster
 * Therefore it is absolutely essential, in order to have this variable not interfere with "normal" spell casting,
 * to delete it *immediately after* the spell script executed. All of this is taken care of in the function
 * ExecuteSpellScript(), which should be used instead of any direct calls to the spell scripts.
 * In particular, NEVER MANUALLY set the overrides. You might ruin the whole spell casting system!
 *
 * Another possibility would have been, to give preference to the GetSpellCastItem() call and only fetch the
 * local object "PRC_SPELLCASTITEM_OVERRIDE" when GetSpellCastItem() returns an invalid object.
 * This is how it is was done in the PRC 3.1c version of prc_onhitcast (lines 58-61), and in psi_sk_onhit, prc_evnt_bonebld, prc_evnt_strmtl
 * [In those scripts the local (override) object was called "PRC_CombatSystem_OnHitCastSpell_Item". In order to be consistent with
 * the naming conventions of the other override variables, I changed the name of the override object to PRC_SPELLCASTITEM_OVERRIDE
 * and provided the wrapper PRCGetSpellCastItem for an easy use of the onhitcast system]
 * However, that approach DOES NOT WORK, because Bioware didn't bother to implement GetSpellCastItem() properly.
 * In a proper implementation GetSpellCastItem() word return OBJECT_INVALID, when called outside of an item spell script,
 * But this is not the case. GetSpellCastItem() will always return the item, from which (according to Bioware's knowledge)
 * the last item spell was cast. As long as the item still exists, the call to GetSpellCastItem() will always return a valid item,
 * even if the item spell long expired and we are casting a completely differnt spell. So GetSpellCastItem() practically
 * NEVER returns an invalid object. [We only get an invalid object, when we didn't yet cast any item spell at all]
 *
 * Possible caveats:
 * You should never cast spells as an action, when the local override object "PRC_SPELLCASTITEM_OVERRIDE"
 * is set (and subsequently deleted) *outside* the action script. This also pertains to other override variables, such as
 * PRC_SPELL_TARGET_OBJECT_OVERRIDE, PRC_METAMAGIC_OVERRIDE, etc.
 * If you set (and delete) a local override (object or int) *within* one single action, thats ok. For instance putting
 * ExecuteSpellScript() into an ActionDoCommand, an AssignCommand or a DelayCommand will work.
 * But (manually) setting "PRC_SPELLCASTITEM_OVERRIDE", then calling ActionCastSpellAt*
 * (which will insert the spell cast action into the action queue) and after that trying to delete the overrides
 * via a DelayCommand or an AssignCommand(), often just guessing how long it takes the spell cast action to run,
 * will most likely break any other spell casting that is done between manually setting the override and deleting it.
 * So please follow the advise to never MANUALLY set the override variables. Use the functions provided here
 * (ExecuteSpellScript, CastSpellAtObject, CastSpellAtLocation, etc. ) or - if you must - build your own
 * functions by using the provided functions either directly or as templates (they show you how to do things right)
 */
object PRCGetSpellCastItem(object oCaster = OBJECT_SELF)
{
    // if the local object "PRC_SPELLCASTITEM_OVERRIDE" is valid, we take it without even looking for anything else
    object oItem = GetLocalObject(oCaster, PRC_SPELLCASTITEM_OVERRIDE);
    if (GetIsObjectValid(oItem))
    {
        // OBJECT_SELF counts as invalid item
        if (oItem == OBJECT_SELF)
        {
            oItem = OBJECT_INVALID;
        }

        if (DEBUG) DoDebug("PRCGetSpellCastItem: found override spell cast item = "+GetName(oItem)+", original item = " + GetName(GetSpellCastItem()));
        return oItem;
    }

    // otherwise simply return Bioware's GetSpellCastItem
    oItem = GetSpellCastItem();
    if (DEBUG) DoDebug("PRCGetSpellCastItem: no override, returning bioware spell cast item = "+GetName(oItem));
    return oItem;
    /*
    // motu99: disabled the old stuff; was only used in three scripts (changed them)
    // and couldn't work anyway (because of Bioware's improper implementation of GetSpellCastItem)
    // if Bioware's functions doesn't return a valid object, maybe the scripted combat system will
    if(!GetIsObjectValid(oItem))
        oItem = GetLocalObject(oPC, "PRC_CombatSystem_OnHitCastSpell_Item");
    */
}

itemproperty PRCItemPropertyBonusFeat(int nBonusFeatID)
{
    string sTag = "PRC_IPBF_"+IntToString(nBonusFeatID);
    object oTemp = GetObjectByTag(sTag);
    if(!GetIsObjectValid(oTemp))
    {
        if(DEBUG) DoDebug("PRCItemPropertyBonusFeat() : Cache object " + sTag + " is not valid, creating");
        location lLimbo;
        object oLimbo = GetObjectByTag("HEARTOFCHAOS");
        if(GetIsObjectValid(oLimbo))
            lLimbo = GetLocation(oLimbo);
        else
            lLimbo = GetStartingLocation();
        oTemp = CreateObject(OBJECT_TYPE_ITEM, "base_prc_skin", lLimbo, FALSE, sTag);
    }
    itemproperty ipReturn = GetFirstItemProperty(oTemp);
    if(!GetIsItemPropertyValid(ipReturn))
    {
        if(DEBUG) DoDebug("PRCItemPropertyBonusFeat() : Itemproperty was not present on cache object, adding");
        ipReturn = ItemPropertyBonusFeat(nBonusFeatID);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipReturn, oTemp);
    }
    return ipReturn;
}

int GetPRCIsSkillSuccessful(object oCreature, int nSkill, int nDifficulty, int nRollOverride = -1)
{
    int nRanks = GetSkillRank(nSkill, oCreature);
    if(nRollOverride > 20)
    {
        nRollOverride = 20;
        if(DEBUG) DoDebug("GetPRCIsSkillSuccessful: nRollOverride > 20");
    }
    if(nRollOverride < 0 || (nSkill + nRollOverride) < nDifficulty)
        return GetIsSkillSuccessful(oCreature, nSkill, nDifficulty);
    else
    {   //we're going to fake a skill check here
        SendMessageToPC(oCreature,
            PRC_TEXT_LIGHT_BLUE + GetName(oCreature) + PRC_TEXT_DARK_BLUE + " : " +
            GetStringByStrRef(StringToInt(Get2DACache("skills", "Name", nSkill))) + " : *" +
            (((nRollOverride  + nRanks) >= nDifficulty) ? GetStringByStrRef(5352) : ((nDifficulty > nRanks + 20) ? GetStringByStrRef(8101) : GetStringByStrRef(5353))) + "* : " +
            "(" + IntToString(nRollOverride) + " + " + IntToString(nRanks) + " = " + IntToString(nRollOverride + nRanks) + " vs. DC: " + IntToString(nDifficulty) + ")"
            );
    }
    return (nRollOverride + nRanks >= nDifficulty);
}

int PRCGetCreatureSize(object oObject = OBJECT_SELF, int nSizeMask = PRC_SIZEMASK_ALL)
{
    //int nSize = GetCreatureSize(oObject);
    int nSize = StringToInt(Get2DAString("appearance", "SizeCategory", GetAppearanceType(oObject)));
    if (DEBUG) DoDebug("Appearance-based GetCreatureSize, returning size: "+IntToString(nSize));
    if (DEBUG) DoDebug("Bioware GetCreatureSize, returning size: "+IntToString(GetCreatureSize(oObject)));
    //CEP adds other sizes, take them into account too
    if(nSize == 20)
        nSize = CREATURE_SIZE_DIMINUTIVE;
    else if(nSize == 21)
        nSize = CREATURE_SIZE_FINE;
    else if(nSize == 22)
        nSize = CREATURE_SIZE_GARGANTUAN;
    else if(nSize == 23)
        nSize = CREATURE_SIZE_COLOSSAL;

    if(nSizeMask & PRC_SIZEMASK_NORMAL)
    {
        if(GetHasFeat(FEAT_SIZE_DECREASE_6, oObject))
            nSize += -6;
        else if(GetHasFeat(FEAT_SIZE_DECREASE_5, oObject))
            nSize += -5;
        else if(GetHasFeat(FEAT_SIZE_DECREASE_4, oObject))
            nSize += -4;
        else if(GetHasFeat(FEAT_SIZE_DECREASE_3, oObject))
            nSize += -3;
        else if(GetHasFeat(FEAT_SIZE_DECREASE_2, oObject))
            nSize += -2;
        else if(GetHasFeat(FEAT_SIZE_DECREASE_1, oObject))
            nSize += -1;

        if(GetHasFeat(FEAT_SIZE_INCREASE_6, oObject))
            nSize +=  6;
        else if(GetHasFeat(FEAT_SIZE_INCREASE_5, oObject))
            nSize +=  5;
        else if(GetHasFeat(FEAT_SIZE_INCREASE_4, oObject))
            nSize +=  4;
        else if(GetHasFeat(FEAT_SIZE_INCREASE_3, oObject))
            nSize +=  3;
        else if(GetHasFeat(FEAT_SIZE_INCREASE_2, oObject))
            nSize +=  2;
        else if(GetHasFeat(FEAT_SIZE_INCREASE_1, oObject))
            nSize +=  1;
    }

    if(nSizeMask & PRC_SIZEMASK_NOABIL
        || ((nSizeMask & PRC_SIZEMASK_NORMAL) && GetPRCSwitch(PRC_DRAGON_DISCIPLE_SIZE_CHANGES)))
    {
        if(GetHasFeat(FEAT_DRACONIC_SIZE_INCREASE_2, oObject))
            nSize +=  2;
        else if(GetHasFeat(FEAT_DRACONIC_SIZE_INCREASE_1, oObject))
            nSize +=  1;
    }

    if(nSizeMask & PRC_SIZEMASK_SIMPLE)
    {
        // Size changing powers
        // Compression: Size decreased by one or two categories, depending on augmentation
        if(GetLocalInt(oObject, "PRC_Power_Compression_SizeReduction"))
            nSize -= GetLocalInt(oObject, "PRC_Power_Compression_SizeReduction");
        // Expansion: Size increase by one or two categories, depending on augmentation
        if(GetLocalInt(oObject, "PRC_Power_Expansion_SizeIncrease"))
            nSize += GetLocalInt(oObject, "PRC_Power_Expansion_SizeIncrease");
    }

    if(nSize < CREATURE_SIZE_FINE)
        nSize = CREATURE_SIZE_FINE;
    if(nSize > CREATURE_SIZE_COLOSSAL)
        nSize = CREATURE_SIZE_COLOSSAL;
    if (DEBUG) DoDebug("PRCGetCreatureSize, returning size: "+IntToString(nSize));
    return nSize;
}
int GetIsChakraBound(object oMeldshaper, int nChakra)
{
	int nTest = GetLocalInt(oMeldshaper, "BoundMeld"+IntToString(nChakra));
	
    if (DEBUG) DoDebug("GetIsChakraBound is "+IntToString(nTest));
    return nTest;
}

int GetMaxEssentiaCapacity(object oMeldshaper, int nClass, int nMeld)
{
	int nMax = 1; // Always can invest one
	int nHD = GetHitDice(oMeldshaper);
	if (nHD >= 61) nMax = 8;
	else if (nHD >= 51) nMax = 7;
	else if (nHD >= 41) nMax = 6;
	else if (nHD >= 31) nMax = 5;
	else if (nHD >= 18) nMax = 4;
	else if (nHD >= 12) nMax = 3;
	else if (nHD >= 6) nMax = 2;
	
	if (nClass == CLASS_TYPE_INCARNATE && GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 3) nMax++;
	if (nClass == CLASS_TYPE_INCARNATE && GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper) >= 15) nMax++;

	if (nClass == CLASS_TYPE_TOTEMIST && GetIsMeldBound(oMeldshaper, nMeld) == CHAKRA_TOTEM) nMax++;
	if (nClass == CLASS_TYPE_TOTEMIST && GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper) >= 15 && GetIsMeldBound(oMeldshaper, nMeld) == CHAKRA_TOTEM) nMax++;
	
	if (nClass == CLASS_TYPE_TOTEMIST && GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oMeldshaper) >= 10 && GetIsMeldBound(oMeldshaper, nMeld) == CHAKRA_TOTEM) nMax++;
	
	if (GetIsNecrocarnumMeld(nMeld) && GetLevelByClass(CLASS_TYPE_NECROCARNATE, oMeldshaper) >= 9) nMax++;
	if (GetLocalInt(oMeldshaper, "DivineSoultouch")) nMax += 1;
	if (GetLocalInt(oMeldshaper, "IncandescentOverload"))
	{
		if (GetAbilityModifier(ABILITY_CHARISMA, oMeldshaper) > 1)
			nMax += GetAbilityModifier(ABILITY_CHARISMA, oMeldshaper);
		else
			nMax += 1;
	}	
	if (GetExpandedSoulmeld(oMeldshaper, nMeld)) nMax += 1;

	if (DEBUG) DoDebug("GetMaxEssentiaCapacity: nHD "+IntToString(nHD)+" nMax "+IntToString(nMax));
	return nMax;
}

int GetEssentiaInvested(object oMeldshaper, int nMeld = -1)
{
	if (nMeld == -1) nMeld = PRCGetSpellId();
	
	if (GetLocalInt(oMeldshaper, "PerfectMeldshaper")) return GetMaxEssentiaCapacity(oMeldshaper, CLASS_TYPE_INCARNATE, -1);
	
	int nReturn = GetLocalInt(oMeldshaper, "MeldEssentia"+IntToString(nMeld));
	if (GetLocalInt(oMeldshaper, "TotemEmbodiment") == nMeld) nReturn = nReturn * 2;
	if (GetLocalInt(oMeldshaper, "TotemEmbodiment2") == nMeld) nReturn = nReturn * 2;
	if (DEBUG) DoDebug("GetEssentiaInvested nMeld "+IntToString(nMeld)+" nReturn "+IntToString(nReturn));
	return nReturn;
}

int GetIsMeldBound(object oMeldshaper, int nMeld = -1)
{
	if (nMeld == -1) nMeld = PRCGetSpellId();
	int i, nBind, nTest;
    for (i = 1; i <= 22; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "BoundMeld"+IntToString(i));
		if (nTest == nMeld) // If it's been marked as bound
			nBind = i;	
    }
    //FloatingTextStringOnCreature("GetIsMeldBound: nMeld "+IntToString(nMeld)+" nBind "+IntToString(nBind), oMeldshaper);
    if (DEBUG) DoDebug("GetIsMeldBound is "+IntToString(nBind));

    return nBind; // Return which Chakra it's bound to
}

int GetMeldshaperAbilityOfClass(int nClass, object oMeldshaper)
{
	// Incarnates use Wisdom for DC, everyone else uses Con
    if (nClass == CLASS_TYPE_INCARNATE || GetHasFeat(FEAT_UNDEAD_MELDSHAPER, oMeldshaper)) 
    	return ABILITY_WISDOM;
    else
    	return ABILITY_CONSTITUTION;

    // Technically, never gets here but the compiler does not realise that
    return -1;
}

int GetMeldshaperDC(object oMeldshaper, int nClass, int nMeldId)
{    
    int nAbi = GetAbilityModifier(GetMeldshaperAbilityOfClass(nClass, oMeldshaper), oMeldshaper) + GetEssentiaInvested(oMeldshaper, nMeldId);
	
    // DC is 10 + ability
    int nDC = 10 + nAbi; 
    if (GetIsNecrocarnumMeld(nMeldId) && GetHasFeat(FEAT_NECROCARNUM_ACOLYTE, oMeldshaper)) nDC += 1;
	if (DEBUG) DoDebug("GetMeldshaperDC: nAbi "+IntToString(nAbi)+" nMeldId "+IntToString(nMeldId));
    return nDC;
}

int GetEssentiaInvestedFeat(object oMeldshaper, int nFeat)
{	
	int nReturn = GetLocalInt(oMeldshaper, "FeatEssentia"+IntToString(nFeat));
	if (DEBUG) DoDebug("GetEssentiaInvestedFeat nFeat "+IntToString(nFeat)+" nReturn "+IntToString(nReturn));
	return nReturn;
}

int GetIsNecrocarnumMeld(int nMeld)
{	
	int nReturn = FALSE;
	
	if (nMeld == MELD_NECROCARNUM_CIRCLET   ||
	    nMeld == MELD_NECROCARNUM_MANTLE    ||
	    nMeld == MELD_NECROCARNUM_SHROUD    ||
	    nMeld == MELD_NECROCARNUM_TOUCH     ||
	    nMeld == MELD_NECROCARNUM_VESTMENTS ||
	    nMeld == MELD_NECROCARNUM_WEAPON)
	    	nReturn = TRUE;
	
	if (DEBUG) DoDebug("GetIsNecrocarnumMeld nReturn "+IntToString(nReturn));
	return nReturn;
}

int DoubleChakraToChakra(int nChakra)
{
	if (nChakra == CHAKRA_DOUBLE_CROWN    ) return CHAKRA_CROWN;    
	if (nChakra == CHAKRA_DOUBLE_FEET     ) return CHAKRA_FEET;     
	if (nChakra == CHAKRA_DOUBLE_HANDS    ) return CHAKRA_HANDS;    
	if (nChakra == CHAKRA_DOUBLE_ARMS     ) return CHAKRA_ARMS;     
	if (nChakra == CHAKRA_DOUBLE_BROW     ) return CHAKRA_BROW;     
	if (nChakra == CHAKRA_DOUBLE_SHOULDERS) return CHAKRA_SHOULDERS;
	if (nChakra == CHAKRA_DOUBLE_THROAT   ) return CHAKRA_THROAT;   
	if (nChakra == CHAKRA_DOUBLE_WAIST    ) return CHAKRA_WAIST;    
	if (nChakra == CHAKRA_DOUBLE_HEART    ) return CHAKRA_HEART;    
	if (nChakra == CHAKRA_DOUBLE_SOUL     ) return CHAKRA_SOUL;     
	if (nChakra == CHAKRA_DOUBLE_TOTEM    ) return CHAKRA_TOTEM;    
	
	return nChakra;
}

int GetExpandedSoulmeld(object oMeldshaper, int nMeld)
{
	int i, nCount, nTest;
    for (i = 1; i <= 5; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(i));
		if (nTest == nMeld) 
			nCount = TRUE;	
    }
    if (DEBUG) DoDebug("GetExpandedSoulmeld is "+IntToString(nCount));
    return nCount;
}

int GetIsSoulmeldCapacityUsed(object oMeldshaper)
{
	// If we have the feat and it's not marked as used
	if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_1, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(1))) return FALSE;
	else if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_2, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(2))) return FALSE;
	else if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_3, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(3))) return FALSE;
	else if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_4, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(4))) return FALSE;
	else if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_5, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(5))) return FALSE;
	
	return TRUE;	
}

void SetIsSoulmeldCapacityUsed(object oMeldshaper, int nMeld)
{
	// This is called from a place where we've just checked there was an empty slot
	if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_1, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(1))) SetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(1), nMeld);
	else if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_2, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(2))) SetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(2), nMeld);
	else if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_3, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(3))) SetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(3), nMeld);
	else if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_4, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(4))) SetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(4), nMeld);
	else if (GetHasFeat(FEAT_EXPANDED_SOULMELD_CAPACITY_5, oMeldshaper) && !GetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(5))) SetLocalInt(oMeldshaper, "ExpandedSoulmeld"+IntToString(5), nMeld);
}

int GetIsMeldShaped(object oMeldshaper, int nMeld, int nClass)
{
	int i, nCount, nTest;
    for (i = 0; i <= 20; i++)
    {
		nTest = GetLocalInt(oMeldshaper, "ShapedMeld"+IntToString(nClass)+IntToString(i));
		if (nTest == nMeld) // If it's been marked as shaped for that class
			nCount = TRUE;	
    }
    if (DEBUG) DoDebug("GetIsMeldShaped is "+IntToString(nCount));
    return nCount;
}

int GetMeldShapedClass(object oMeldshaper, int nMeld)
{
	int nClass;
	if (GetIsMeldShaped(oMeldshaper, nMeld, CLASS_TYPE_INCARNATE)) nClass = CLASS_TYPE_INCARNATE;
	else if (GetIsMeldShaped(oMeldshaper, nMeld, CLASS_TYPE_SOULBORN)) nClass = CLASS_TYPE_SOULBORN;
	else if (GetIsMeldShaped(oMeldshaper, nMeld, CLASS_TYPE_TOTEMIST)) nClass = CLASS_TYPE_TOTEMIST;
	else if (GetIsMeldShaped(oMeldshaper, nMeld, CLASS_TYPE_SPINEMELD_WARRIOR)) nClass = CLASS_TYPE_SPINEMELD_WARRIOR;
	
	return nClass;
}

int GetIsIncarnumUser(object oMeldshaper)
{
    return 0!=(GetLevelByClass(CLASS_TYPE_INCARNATE, oMeldshaper)
            || GetLevelByClass(CLASS_TYPE_SOULBORN, oMeldshaper)
            || GetLevelByClass(CLASS_TYPE_TOTEMIST, oMeldshaper)
            || GetLevelByClass(CLASS_TYPE_INCANDESCENT_CHAMPION, oMeldshaper)
            || GetHasFeat(FEAT_HEART_INCARNUM, oMeldshaper)
            || GetHasFeat(FEAT_INCARNUM_FORTIFIED_BODY, oMeldshaper)
            || GetHasFeat(FEAT_INVEST_ESSENTIA_CONV, oMeldshaper)
            || GetLevelByClass(CLASS_TYPE_SPINEMELD_WARRIOR, oMeldshaper));
}

int GetIsBinder(object oBinder)
{
    return !(!(GetLevelByClass(CLASS_TYPE_BINDER, oBinder)
            || GetHasFeat(FEAT_BIND_VESTIGE, oBinder)
            || GetRacialType(oBinder) == RACIAL_TYPE_KARSITE));
}

int GetAberrantFeatCount(object oPC)
{
	int i, nCount;
    for (i = 5387; i <= 5398; i++)
    {
		if (GetHasFeat(i, oPC)) 
			nCount++;	
    }
    if (DEBUG) DoDebug("GetAberrantFeatCount is "+IntToString(nCount));
    return nCount;
}

//:: Test Void
//:: void main (){}