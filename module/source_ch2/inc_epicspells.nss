//:://////////////////////////////////////////////
//:: FileName: "inc_epicspells"
/*   Purpose: This is the #include file that contains all constants and
        functions needed for the Epic Spellcasting System.
*/
//:://////////////////////////////////////////////
//:: Created By: Boneshank (Don Armstrong)
//:: Last Updated On: March 18, 2004
//:://////////////////////////////////////////////

/*
CONSTANTS FOR OPTIONAL FEATURES
*/
/* moved to prc_inc_switch as runtime switches rather than compiletime

// Use the "XP Costs" option, making casters expend some experience when they
//      cast certain spells?
const int XP_COSTS = TRUE;

// Use the "Take 10" variant rule?
// If TRUE, all Spellcraft checks will be automatically equal to the caster's
//      Spellcraft skill level, plus 10. The outcome is never a surprise.
// If FALSE, every Spellcraft check is a roll of the dice, being equal to the
//      caster's Spellcraft skill level, plus 1d20. Risky, but more fun!
const int TAKE_TEN_RULE = FALSE;

// Use the "Primary Ability Modifier Bonus to Skills" variant rule?
// If TRUE, caster's use their primary ability (WISDOM for clerics and druids,
//      CHARISMA for sorcerers) instead of intelligence as a modifier on their
//      Spellcraft checks for casting and researching epic spells, as well as
//      their total Lore skill level for determining spell slots per day.
const int PRIMARY_ABILITY_MODIFIER_RULE = TRUE;

// Enable BACKLASH damage on spells? TRUE for yes, FALSE for no.
const int BACKLASH_DAMAGE = TRUE;

// Sets the DC adjustment active or inactive for researching spells.
// If TRUE, the player's spell foci feats are used to lower the spell's DC which
//      lowers the overall costs of researching the spell. For example, if the
//      spell is from the school of Necromancy, and the player has the feat Epic
//      Spell Focus: Necromancy, then the DC for the rearch would be lowered by
//      six. This would (under default ELHB settings) lower the gold cost by
//      54000 gold and 2160 exp. points, as well as makee the spell accessible
//      to the player earlier and with a greater chance of success (due to the
//      Spellcraft check).
// Setting this to FALSE will disable this feature.
const int FOCI_ADJUST_DC = TRUE;

// This sets the multiplier for the cost, in gold, to a player for the
//      researching of an epic spell. The number is multiplied by the DC of
//      the spell to be researched. ELHB default is 9000.
const int GOLD_MULTIPLIER = 9000;

// This sets the number to divide the gold cost by to determine the cost,
//      in experience, to research an epic spell. The formula is as follows:
//      XP Cost = Spell's DC x GOLD_MULTIPLIER / XP_FRACTION. The default from
//      the ELHB is 25.
const int XP_FRACTION = 25;

// Set the number you want to divide the gold cost by for research failures.
// Examples: 2 would result in half the loss of the researcher's gold.
//           3 would result in a third of the gold lost.
//           4 would result in a quarter, etc.
const int FAILURE_FRACTION_GOLD = 2;

// Sets the percentage chance that a seed book is destroyed on a use of it.
// 0 = the book is never randomly destroyed from reading (using) it.
// 100 = the book is always destroyed from reading it.
// NOTE! This function is only ever called when the player actually acquires
//      the seed feat. It is a way to control mass "gift-giving" amongst players
const int BOOK_DESTRUCTION = 50;
*/


// Play cutscenes for learning Epic Spell Seeds and researching Epic Spells?
const int PLAY_RESEARCH_CUTS = FALSE;
const int PLAY_SPELLSEED_CUT = FALSE;

// What school of magic does each spell belong to? (for research cutscenes)
// A = Abjuration
// C = Conjuration
// D = Divination
// E = Enchantment
// V = Evocation
// I = Illusion
// N = Necromancy
// T = Transmutation
// Between the quotation marks, enter the name of the cutscene script.
const string SCHOOL_A       = "";
const string SCHOOL_C       = "";
const string SCHOOL_D       = "";
const string SCHOOL_E       = "";
const string SCHOOL_V       = "";
const string SCHOOL_I       = "";
const string SCHOOL_N       = "";
const string SCHOOL_T       = "";
const string SPELLSEEDS_CUT = "";



/******************************************************************************
FUNCTION DECLARATIONS
******************************************************************************/



// Returns the combined caster level of oPC.
int GetTotalCastingLevel(object oPC);

// returns TRUE if oPC is an Epic level Dread Necromancer
int GetIsEpicDreadNecromancer(object oPC);

// returns TRUE if oPC is an Epic level warmage
int GetIsEpicWarmage(object oPC);

// returns TRUE if oPC is an Epic level healer.
int GetIsEpicHealer(object oPC);

// returns TRUE if oPC is an Epic level favored soul.
int GetIsEpicFavSoul(object oPC);

// Returns TRUE if oPC is an Epic level cleric.
int GetIsEpicCleric(object oPC);

// Returns TRUE if oPC is an Epic level druid.
int GetIsEpicDruid(object oPC);

// Returns TRUE if oPC is an Epic level sorcerer.
int GetIsEpicSorcerer(object oPC);

// Returns TRUE if oPC is an Epic level wizard.
int GetIsEpicWizard(object oPC);

// returns TRUE if oPC is an epic level shaman.
int GetIsEpicShaman(object oPC);

// returns TRUE if oPC is an epic level witch.
int GetIsEpicWitch(object oPC);

// returns TRUE if oPC is an epic level sublime chord.
int GetIsEpicSublimeChord(object oPC);

// returns TRUE if oPC is an epic level archivist.
int GetIsEpicArchivist(object oPC);

// returns TRUE if oPC is an epic level beguiler.
int GetIsEpicBeguiler(object oPC);

// returns TRUE if oPC is an epic level ur-priest.
int GetIsEpicUrPriest(object oPC);

// returns TRUE if oPC is an epic level blighter.
int GetIsEpicBlighter(object oPC);

// returns TRUE if oPC is an Epic spellcaster
int GetIsEpicSpellcaster(object oPC);

// Performs a check on the book to randomly destroy it or not when used.
void DoBookDecay(object oBook, object oPC);

// Returns oPC's spell slot limit, based on Lore and on optional rules.
int GetEpicSpellSlotLimit(object oPC);

// Returns the number of remaining unused spell slots for oPC.
int GetSpellSlots(object oPC);

// Replenishes oPC's Epic spell slots.
void ReplenishSlots(object oPC);

// Decrements oPC's Epic spell slots by one.
void DecrementSpellSlots(object oPC);

// Lets oPC know how many Epic spell slots remain for use.
void MessageSpellSlots(object oPC);

// Returns a Spellcraft check for oPC, based on optional rules.
int GetSpellcraftCheck(object oPC);

// Returns the Spellcraft skill level of oPC, based on optional rules.
int GetSpellcraftSkill(object oPC);

// Returns TRUE if oPC has enough gold to research the spell.
int GetHasEnoughGoldToResearch(object oPC, int nSpellDC);

// Returns TRUE if oPC has enough excess experience to research the spell.
int GetHasEnoughExperienceToResearch(object oPC, int nSpellDC);

// Returns TRUE if oPC has the passed in required feats (Seeds or other Epic spells)... needs BLAH_IP's
int GetHasRequiredFeatsForResearch(object oPC, int nReq1, int nReq2 = 0, int nReq3 = 0, int nReq4 = 0,
    int nSeed1 = 0, int nSeed2 = 0, int nSeed3 = 0, int nSeed4 = 0, int nSeed5 = 0);

// Returns success (TRUE) or failure (FALSE) in oPC's researching of a spell.
int GetResearchResult(object oPC, int nSpellDC);

// Takes the gold & experience (depending on success) from oPC for researching.
void TakeResourcesFromPC(object oPC, int nSpellDC, int nSuccess);

// Returns TRUE if oPC can cast the spell.
int GetCanCastSpell(object oPC, int nEpicSpell);

// Returns the adjusted DC of a spell that takes into account oPC's Spell Foci.
int GetDCSchoolFocusAdjustment(object oPC, string sChool);

// Checks to see if oPC has a creature hide. If not, create and equip one.
void EnsurePCHasSkin(object oPC);

// Add nFeatIP to oPC's creature hide.
void GiveFeat(object oPC, int nFeatIP);

// Remove nFeatIP from oPC's creature hide.
void TakeFeat(object oPC, int nFeatIP);

// Checks to see how many castable epic spell feats oPC has ready to use.
// This is used for the control of the radial menu issue.
int GetCastableFeatCount(object oPC);

// When a contingency spell is active, oCaster loses the use of one slot per day
void PenalizeSpellSlotForCaster(object oCaster);

// When a contingecy expires, restore the spell slot for the caster.
void RestoreSpellSlotForCaster(object oCaster);

// Researches an Epic Spell for the caster.
void DoSpellResearch(object oCaster, int nSpellDC, int nSpellIP, string sSchool, object oBook);

// Cycles through equipped items on oTarget, and unequips any having nImmunityType
void UnequipAnyImmunityItems(object oTarget, int nImmType);

// Finds a given spell's DC
int GetEpicSpellSaveDC(object oCaster = OBJECT_SELF, object oTarget = OBJECT_INVALID, int nSpellID = -1);


int GetHasEpicSpellKnown(int nEpicSpell, object oPC);
void SetEpicSpellKnown(int nEpicSpell, object oPC, int nState = TRUE);

int GetHasEpicSeedKnown(int nEpicSeed, object oPC);
void SetEpicSeedKnown(int nEpicSeed, object oPC, int nState = TRUE);

#include "prc_inc_spells"
#include "prc_class_const"
#include "inc_epicspelldef"
#include "inc_epicspellfnc"
#include "inc_utility"
#include "prc_add_spell_dc"
//#include "x2_inc_spellhook"


/******************************************************************************
FUNCTION BODIES
******************************************************************************/

int GetIsEpicArchivist(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_ARCHIVIST, oPC, FALSE) > 16
         && GetAbilityScore(oPC, ABILITY_INTELLIGENCE) > 18;
}

int GetIsEpicBeguiler(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_BEGUILER, oPC, FALSE) > 17
         && GetAbilityScore(oPC, ABILITY_INTELLIGENCE) > 18;
}

int GetIsEpicCleric(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_CLERIC, oPC, FALSE) > 16
         && GetAbilityScore(oPC, ABILITY_WISDOM) > 18;
}

int GetIsEpicDreadNecromancer(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_DREAD_NECROMANCER, oPC, FALSE) > 17
         && GetAbilityScore(oPC, ABILITY_CHARISMA) > 18;
}

int GetIsEpicDruid(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_DRUID, oPC, FALSE) > 16
         && GetAbilityScore(oPC, ABILITY_WISDOM) > 18;
}

int GetIsEpicFavSoul(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_FAVOURED_SOUL, oPC, FALSE) > 17
         && GetAbilityScore(oPC, ABILITY_CHARISMA) > 18;
}

int GetIsEpicHealer(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_HEALER, oPC, FALSE) > 16
         && GetAbilityScore(oPC, ABILITY_WISDOM) > 18;
}

int GetIsEpicUrPriest(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_UR_PRIEST, oPC, FALSE) > 8
         && GetAbilityScore(oPC, ABILITY_WISDOM) > 18;
}

int GetIsEpicShaman(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_SHAMAN, oPC, FALSE) > 16
         && GetAbilityScore(oPC, ABILITY_WISDOM) > 18;
}

int GetIsEpicSorcerer(object oPC)  
{  
    return GetHitDice(oPC) >= 21  
         && GetCasterLvl(CLASS_TYPE_SORCERER, oPC) > 17  
         && GetAbilityScore(oPC, ABILITY_CHARISMA) > 18;  
}

/* int GetIsEpicSorcerer(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_SORCERER, oPC, FALSE) > 17
         && GetAbilityScore(oPC, ABILITY_CHARISMA) > 18;
} */

int GetIsEpicSublimeChord(object oPC)
{
    return GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oPC) > 8
         && GetAbilityScore(oPC, ABILITY_CHARISMA) > 18;
}

int GetIsEpicBlighter(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_BLIGHTER, oPC, FALSE) > 8
         && GetAbilityScore(oPC, ABILITY_WISDOM) > 18;
}

int GetIsEpicWarmage(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_WARMAGE, oPC, FALSE) > 17
         && GetAbilityScore(oPC, ABILITY_CHARISMA) > 18;
}

int GetIsEpicWitch(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_WITCH, oPC, FALSE) > 17
         && GetAbilityScore(oPC, ABILITY_WISDOM) > 18;
}

int GetIsEpicWizard(object oPC)
{
    return GetPrCAdjustedCasterLevel(CLASS_TYPE_WIZARD, oPC, FALSE) >= 17
         && GetAbilityScore(oPC, ABILITY_INTELLIGENCE) > 18;
}

int GetIsEpicSpellcaster(object oPC)
{
    if(GetHitDice(oPC) < 21)
        return FALSE;

    if(GetIsEpicArchivist(oPC)
    || GetIsEpicBeguiler(oPC)
    || GetIsEpicCleric(oPC)
    || GetIsEpicDreadNecromancer(oPC)
    || GetIsEpicDruid(oPC)
    || GetIsEpicFavSoul(oPC)
    || GetIsEpicHealer(oPC)
    || GetIsEpicUrPriest(oPC)
    || GetIsEpicShaman(oPC)
    || GetIsEpicSorcerer(oPC)
    || GetIsEpicSublimeChord(oPC)
    || GetIsEpicBlighter(oPC)
    || GetIsEpicWarmage(oPC)
    || GetIsEpicWitch(oPC)
    || GetIsEpicWizard(oPC))
        return TRUE;
		
    return FALSE;
}

void DoBookDecay(object oBook, object oPC)
{
    if (d100() >= GetPRCSwitch(PRC_EPIC_BOOK_DESTRUCTION))
    {
        DestroyObject(oBook, 2.0);
        SendMessageToPC(oPC, MES_BOOK_DESTROYED);
    }
}

int GetEpicSpellSlotLimit(object oPC)
{
    int nLimit;
    int nPen = GetLocalInt(oPC, "nSpellSlotPenalty");
    int nBon = GetLocalInt(oPC, "nSpellSlotBonus");
    // What's oPC's Lore skill?.
    nLimit = GetSkillRank(SKILL_LORE, oPC);
    // Variant rule implementation.
    if (GetPRCSwitch(PRC_EPIC_PRIMARY_ABILITY_MODIFIER_RULE) == TRUE)
    {
        if (GetIsEpicSorcerer(oPC) || GetIsEpicFavSoul(oPC) || GetIsEpicWarmage(oPC) || GetIsEpicDreadNecromancer(oPC))
        {
            nLimit -= GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
            nLimit += GetAbilityModifier(ABILITY_CHARISMA, oPC);
        }
        else if (GetIsEpicCleric(oPC) || GetIsEpicDruid(oPC) || GetIsEpicHealer(oPC) || GetIsEpicBlighter(oPC) || GetIsEpicShaman(oPC) || GetIsEpicUrPriest(oPC))
        {
            nLimit -= GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
            nLimit += GetAbilityModifier(ABILITY_WISDOM, oPC);
        }
    }
    // Primary calculation of slots.
    nLimit /= 10;
    // Modified calculation (for contingencies, bonuses, etc)
    nLimit = nLimit + nBon;
    nLimit = nLimit - nPen;
    return nLimit;
}

int GetSpellSlots(object oPC)
{
    int nSlots = GetLocalInt(oPC, "nEpicSpellSlots");
    if(!GetIsPC(oPC) && !GetLocalInt(oPC, "EpicSpellSlotsReplenished"))
    {
        nSlots = GetEpicSpellSlotLimit(oPC);
        SetLocalInt(oPC, "EpicSpellSlotsReplenished", TRUE);
        SetLocalInt(oPC, "nEpicSpellSlots", nSlots);
    }
    return nSlots;
}

void ReplenishSlots(object oPC)
{
    SetLocalInt(oPC, "nEpicSpellSlots", GetEpicSpellSlotLimit(oPC));
    MessageSpellSlots(oPC);
}

void DecrementSpellSlots(object oPC)
{
    SetLocalInt(oPC, "nEpicSpellSlots", GetLocalInt(oPC, "nEpicSpellSlots")-1);
    MessageSpellSlots(oPC);
}

void MessageSpellSlots(object oPC)
{
    SendMessageToPC(oPC, "You now have " +
        IntToString(GetSpellSlots(oPC)) +
        " Epic spell slots available.");
}

int GetHasEpicSpellKnown(int nEpicSpell, object oPC)
{
    int nReturn = GetPersistantLocalInt(oPC, "EpicSpellKnown_"+IntToString(nEpicSpell));
    if(!nReturn)
        nReturn = GetHasFeat(GetResearchFeatForSpell(nEpicSpell), oPC);
    return nReturn;
}

void SetEpicSpellKnown(int nEpicSpell, object oPC, int nState = TRUE)
{
    SetPersistantLocalInt(oPC, "EpicSpellKnown_"+IntToString(nEpicSpell), nState);
}

int GetHasEpicSeedKnown(int nEpicSeed, object oPC)
{
    int nReturn = GetPersistantLocalInt(oPC, "EpicSeedKnown_"+IntToString(nEpicSeed));
    if(!nReturn)
        nReturn = GetHasFeat(GetFeatForSeed(nEpicSeed), oPC);
    return nReturn;
}

void SetEpicSeedKnown(int nEpicSeed, object oPC, int nState = TRUE)
{
    SetPersistantLocalInt(oPC, "EpicSeedKnown_"+IntToString(nEpicSeed), nState);
}

int GetSpellcraftCheck(object oPC)
{
    // Get oPC's skill rank.
    int nCheck = GetSpellcraftSkill(oPC);
    // Do the check, dependant on "Take 10" variant rule.
    if (GetPRCSwitch(PRC_EPIC_TAKE_TEN_RULE) == TRUE)
        nCheck += 10;
    else
        nCheck += d20();
    return nCheck;
}

int GetSpellcraftSkill(object oPC)
{
    // Determine initial Spellcraft skill.
    int nSkill = GetSkillRank(SKILL_SPELLCRAFT, oPC);
    // Variant rule implementation.
    if (GetPRCSwitch(PRC_EPIC_PRIMARY_ABILITY_MODIFIER_RULE) == TRUE)
    {
        if (GetIsEpicSorcerer(oPC) || GetIsEpicFavSoul(oPC) || GetIsEpicWarmage(oPC) || GetIsEpicDreadNecromancer(oPC))
        {
            nSkill -= GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
            nSkill += GetAbilityModifier(ABILITY_CHARISMA, oPC);
        }
        else if (GetIsEpicCleric(oPC) || GetIsEpicDruid(oPC) || GetIsEpicHealer(oPC) || GetIsEpicBlighter(oPC) || GetIsEpicShaman(oPC) || GetIsEpicUrPriest(oPC))
        {
            nSkill -= GetAbilityModifier(ABILITY_INTELLIGENCE, oPC);
            nSkill += GetAbilityModifier(ABILITY_WISDOM, oPC);
        }
    }
    return nSkill;
}

int GetHasEnoughGoldToResearch(object oPC, int nSpellDC)
{
    int nCost = nSpellDC * GetPRCSwitch(PRC_EPIC_GOLD_MULTIPLIER);
    if (GetHasGPToSpend(oPC, nCost))
        return TRUE;
    return FALSE;
}

int GetHasEnoughExperienceToResearch(object oPC, int nSpellDC)
{
    int nXPCost = nSpellDC * GetPRCSwitch(PRC_EPIC_GOLD_MULTIPLIER) / GetPRCSwitch(PRC_EPIC_XP_FRACTION);
    if (GetHasXPToSpend(oPC, nXPCost))
        return TRUE;
    return FALSE;
}

int GetHasRequiredFeatsForResearch(object oPC, int nReq1, int nReq2 = 0, int nReq3 = 0, int nReq4 = 0,
    int nSeed1 = 0, int nSeed2 = 0, int nSeed3 = 0, int nSeed4 = 0, int nSeed5 = 0)
{
    if(DEBUG)
    {
        DoDebug("Requirement #1: " + IntToString(nReq1));
        DoDebug("Requirement #2: " + IntToString(nReq2));
        DoDebug("Requirement #3: " + IntToString(nReq3));
        DoDebug("Requirement #4: " + IntToString(nReq4));
        DoDebug("Seed #1: " + IntToString(nSeed1));
        DoDebug("Seed #2: " + IntToString(nSeed2));
        DoDebug("Seed #3: " + IntToString(nSeed3));
        DoDebug("Seed #4: " + IntToString(nSeed4));
        DoDebug("Seed #4: " + IntToString(nSeed5));
    }

    if ((GetHasFeat(nReq1, oPC) || nReq1 == 0)
        && (GetHasFeat(nReq2, oPC) || nReq2 == 0)
        && (GetHasFeat(nReq3, oPC) || nReq3 == 0)
        && (GetHasFeat(nReq4, oPC) || nReq4 == 0)
        && (GetHasEpicSeedKnown(nSeed1, oPC) || nSeed1 == -1)
        && (GetHasEpicSeedKnown(nSeed2, oPC) || nSeed2 == -1)
        && (GetHasEpicSeedKnown(nSeed3, oPC) || nSeed3 == -1)
        && (GetHasEpicSeedKnown(nSeed4, oPC) || nSeed4 == -1)
        && (GetHasEpicSeedKnown(nSeed5, oPC) || nSeed5 == -1))
    {
        return TRUE;
    }
    return FALSE;
}
int GetResearchResult(object oPC, int nSpellDC)
{
    int nCheck = GetSpellcraftCheck(oPC);
    SendMessageToPC(oPC, "Your spellcraft check was a " +
        IntToString(nCheck) + ", against a researching DC of " +
        IntToString(nSpellDC));
    if (nCheck >= nSpellDC)
    {
        SendMessageToPC(oPC, MES_SPELLCRAFT_CHECK_PASS);
        return TRUE;
    }
    else
    {
        SendMessageToPC(oPC, MES_SPELLCRAFT_CHECK_FAIL);
        return FALSE;
    }
}

void TakeResourcesFromPC(object oPC, int nSpellDC, int nSuccess)
{
    if (nSuccess != TRUE)
    {
        int nGold = nSpellDC *
            GetPRCSwitch(PRC_EPIC_GOLD_MULTIPLIER) / GetPRCSwitch(PRC_EPIC_FAILURE_FRACTION_GOLD);
        SpendGP(oPC, nGold);
    }
    else
    {
        int nGold = nSpellDC *  GetPRCSwitch(PRC_EPIC_GOLD_MULTIPLIER);
        SpendGP(oPC, nGold);
        int nXP = nSpellDC * GetPRCSwitch(PRC_EPIC_GOLD_MULTIPLIER) / GetPRCSwitch(PRC_EPIC_XP_FRACTION);
        SpendXP(oPC, nXP);
    }
}

int GetCanCastSpell(object oPC, int nEpicSpell)
{
    int nSpellDC  = GetDCForSpell(nEpicSpell);
    string sChool = GetSchoolForSpell(nEpicSpell);
    int nSpellXP  =GetCastXPForSpell(nEpicSpell);
    // Adjust the DC to account for Spell Foci feats.
    nSpellDC -= GetDCSchoolFocusAdjustment(oPC, sChool);
    int nCheck = GetSpellcraftCheck(oPC);
    // Does oPC already know it
    if (!GetHasEpicSpellKnown(nEpicSpell, oPC))
    {
        return FALSE;
    }
    if (!(GetSpellSlots(oPC) >= 1))
    { // No? Cancel spell, then.
        SendMessageToPC(oPC, MES_CANNOT_CAST_SLOTS);
        return FALSE;
    }
    if (GetPRCSwitch(PRC_EPIC_XP_COSTS) == TRUE)
    {
        // Does oPC have the needed XP available to cast the spell?
        if (!GetHasXPToSpend(oPC, nSpellXP))
        { // No? Cancel spell, then.
            SendMessageToPC(oPC, MES_CANNOT_CAST_XP);
            return FALSE;
        }
    }
    // Does oPC pass the Spellcraft check for the spell's casting?
    if (!(nCheck >= nSpellDC))
    { // No?
        SendMessageToPC(oPC, MES_SPELLCRAFT_CHECK_FAIL);
        SendMessageToPC(oPC,
            IntToString(nCheck) + " against a DC of " + IntToString(nSpellDC));
        // Failing a Spellcraft check still costs a spell slot, so decrement...
        DecrementSpellSlots(oPC);
        return FALSE;
    }
    // If the answer is YES to all three, cast the spell!
    SendMessageToPC(oPC, MES_SPELLCRAFT_CHECK_PASS);
    SendMessageToPC(oPC,
        IntToString(nCheck) + " against a DC of " + IntToString(nSpellDC));
    SpendXP(oPC, nSpellXP); // Only spends the XP on a successful casting.
    DecrementSpellSlots(oPC);
    return TRUE;
}

void GiveFeat(object oPC, int nFeatIP)
{
    object oSkin = GetPCSkin(oPC);
    if (oSkin != OBJECT_INVALID)
        IPSafeAddItemProperty(oSkin, PRCItemPropertyBonusFeat(nFeatIP), 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
}

void TakeFeat(object oPC, int nFeatIP)
{
    object oSkin = GetPCSkin(oPC);
    itemproperty ipX = GetFirstItemProperty(oSkin);
    while (GetIsItemPropertyValid(ipX))
    {
        if (GetItemPropertyType(ipX) == ITEM_PROPERTY_BONUS_FEAT)
        {
            if(GetItemPropertySubType(ipX) == nFeatIP)
            {
                RemoveItemProperty(oSkin, ipX);
                break;
            }
        }
        ipX = GetNextItemProperty(oSkin);
    }
}

int GetCastableFeatCount(object oPC)
{
    int nX = 0;
    int i = 0;
    int nFeat = GetFeatForSpell(i);
    while(nFeat != 0)
    {
        //test for the castable feat
        if(GetHasFeat(nFeat, oPC))
            nX += 1;
        i++;
        nFeat = GetFeatForSpell(i);
    }
    return nX;
}

void PenalizeSpellSlotForCaster(object oCaster)
{
    int nMod = GetLocalInt(oCaster, "nSpellSlotPenalty");
    SetLocalInt(oCaster, "nSpellSlotPenalty", nMod + 1);
    SendMessageToPC(oCaster, MES_CONTINGENCIES_YES1);
    SendMessageToPC(oCaster, MES_CONTINGENCIES_YES2);
    SendMessageToPC(oCaster, "Your epic spell slot limit is now " +
        IntToString(GetEpicSpellSlotLimit(oCaster)) + ".");
}

void RestoreSpellSlotForCaster(object oCaster)
{
    int nMod = GetLocalInt(oCaster, "nSpellSlotPenalty");
    if (nMod > 0) SetLocalInt(oCaster, "nSpellSlotPenalty", nMod - 1);
    SendMessageToPC(oCaster, "Your epic spell slot limit is now " +
        IntToString(GetEpicSpellSlotLimit(oCaster)) + ".");
}

void DoSpellResearch(object oCaster, int nSpellDC, int nSpellIP, string sSchool, object oBook)
{
    float fDelay = 2.0;
    string sCutScript;
    int nResult = GetResearchResult(oCaster, nSpellDC);
    if (PLAY_RESEARCH_CUTS == TRUE)
    {
        if (sSchool == "A") sCutScript = SCHOOL_A;
        if (sSchool == "C") sCutScript = SCHOOL_C;
        if (sSchool == "D") sCutScript = SCHOOL_D;
        if (sSchool == "E") sCutScript = SCHOOL_E;
        if (sSchool == "I") sCutScript = SCHOOL_I;
        if (sSchool == "N") sCutScript = SCHOOL_N;
        if (sSchool == "T") sCutScript = SCHOOL_T;
        if (sSchool == "V") sCutScript = SCHOOL_V;
        ExecuteScript(sCutScript, oCaster);
        fDelay = 10.0;
    }
    DelayCommand(fDelay, TakeResourcesFromPC(oCaster, nSpellDC, nResult));
    if (nResult == TRUE)
    {
        DelayCommand(fDelay, SendMessageToPC(oCaster, GetName(oCaster) + " " + MES_RESEARCH_SUCCESS));
        //DelayCommand(fDelay, GiveFeat(oCaster, nSpellIP));
        DelayCommand(fDelay, SetEpicSpellKnown(nSpellIP, oCaster, TRUE));
        DelayCommand(fDelay, DestroyObject(oBook));
        //research time
        //1 day per 50,000GP +1
        int nDays = (nSpellDC * GetPRCSwitch(PRC_EPIC_GOLD_MULTIPLIER))/50000;
        nDays++;
        float fSeconds = HoursToSeconds(24*nDays);
        AdvanceTimeForPlayer(oCaster, fSeconds);
    }
    else
    {
        DelayCommand(fDelay, SendMessageToPC(oCaster, GetName(oCaster) + " " + MES_RESEARCH_FAILURE));
    }
}

void UnequipAnyImmunityItems(object oTarget, int nImmType)
{
    object oItem;
    int nX;
    for (nX = 0; nX <= 13; nX++) // Does not include creature items in search.
    {
        oItem = GetItemInSlot(nX, oTarget);
        // Debug.
        //SendMessageToPC(oTarget, "Checking slot " + IntToString(nX));
        if (oItem != OBJECT_INVALID)
        {
            // Debug.
            //SendMessageToPC(oTarget, "Valid item.");
            itemproperty ipX = GetFirstItemProperty(oItem);
            while (GetIsItemPropertyValid(ipX))
            {
                // Debug.
                //SendMessageToPC(oTarget, "Valid ip");
                if (GetItemPropertySubType(ipX) == nImmType)
                {
                    // Debug.
                    //SendMessageToPC(oTarget, "ip match!!");
                    SendMessageToPC(oTarget, GetName(oItem) +
                        " cannot be equipped at this time.");
                    AssignCommand(oTarget, ClearAllActions());
                    AssignCommand(oTarget, ActionUnequipItem(oItem));
                    break;
                }
                else
                    ipX = GetNextItemProperty(oItem);
            }
        }
    }
}

int GetTotalCastingLevel(object oCaster)
{
    int iBestArcane = GetLevelByTypeArcaneFeats();
    int iBestDivine = GetLevelByTypeDivineFeats();
    int iBest = (iBestDivine > iBestArcane) ? iBestDivine : iBestArcane;

    //SendMessageToPC(oCaster, "Epic casting at level " + IntToString(iBest));

    return iBest;
}

int GetDCSchoolFocusAdjustment(object oPC, string sChool)
{
    int nNewDC = 0;
    if (sChool == "A") // Abjuration spell?
    {
        if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ABJURATION, oPC)) nNewDC = 6;
        else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ABJURATION, oPC)) nNewDC = 4;
        else if (GetHasFeat(FEAT_SPELL_FOCUS_ABJURATION, oPC)) nNewDC = 2;
    }
    if (sChool == "C") // Conjuration spell?
    {
        if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION, oPC)) nNewDC = 6;
        else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION, oPC)) nNewDC = 4;
        else if (GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION, oPC)) nNewDC = 2;
    }
    if (sChool == "D") // Divination spell?
    {
        if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, oPC)) nNewDC = 6;
        else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINIATION, oPC)) nNewDC = 4;
        else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, oPC)) nNewDC = 2;
    }
    if (sChool == "E") // Enchantment spell?
    {
        if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT, oPC)) nNewDC = 6;
        else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT, oPC)) nNewDC = 4;
        else if (GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT, oPC)) nNewDC = 2;
    }
    if (sChool == "V") // Evocation spell?
    {
        if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_EVOCATION, oPC)) nNewDC = 6;
        else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_EVOCATION, oPC)) nNewDC = 4;
        else if (GetHasFeat(FEAT_SPELL_FOCUS_EVOCATION, oPC)) nNewDC = 2;
    }
    if (sChool == "I") // Illusion spell?
    {
        if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ILLUSION, oPC)) nNewDC = 6;
        else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ILLUSION, oPC)) nNewDC = 4;
        else if (GetHasFeat(FEAT_SPELL_FOCUS_ILLUSION, oPC)) nNewDC = 2;
    }
    if (sChool == "N") // Necromancy spell?
    {
        if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_NECROMANCY, oPC)) nNewDC = 6;
        else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_NECROMANCY, oPC)) nNewDC = 4;
        else if (GetHasFeat(FEAT_SPELL_FOCUS_NECROMANCY, oPC)) nNewDC = 2;
    }
    if (sChool == "T") // Transmutation spell?
    {
        if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_TRANSMUTATION, oPC)) nNewDC = 6;
        else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_TRANSMUTATION, oPC)) nNewDC = 4;
        else if (GetHasFeat(FEAT_SPELL_FOCUS_TRANSMUTATION, oPC)) nNewDC = 2;
    }
    return nNewDC;
}

int GetEpicSpellSaveDC(object oCaster = OBJECT_SELF, object oTarget = OBJECT_INVALID, int nSpellID = -1)
{
    int iDiv = GetPrCAdjustedCasterLevelByType(TYPE_DIVINE,   oCaster); // ie. wisdom determines DC
    int iWiz = GetPrCAdjustedCasterLevel(CLASS_TYPE_WIZARD,   oCaster); // int determines DC
    int iWMa = GetPrCAdjustedCasterLevel(CLASS_TYPE_WARMAGE,  oCaster); // cha determines DC
    int iDNc = GetPrCAdjustedCasterLevel(CLASS_TYPE_DREAD_NECROMANCER, oCaster); // cha determines DC
    int iSor = GetPrCAdjustedCasterLevel(CLASS_TYPE_SORCERER, oCaster); // cha determines DC
    int iWit = GetPrCAdjustedCasterLevel(CLASS_TYPE_WITCH,    oCaster); // wis determines DC
    int iArc = GetPrCAdjustedCasterLevel(CLASS_TYPE_ARCHIVIST, oCaster); // int determines DC
    int iBeg = GetPrCAdjustedCasterLevel(CLASS_TYPE_BEGUILER, oCaster); // int determines DC
    int iTpl = GetPrCAdjustedCasterLevel(CLASS_TYPE_TEMPLAR,  oCaster); // cha determines DC

    int iBest = 0;
    int iAbility;
    if(nSpellID == -1)
        nSpellID = PRCGetSpellId();

    if (iArc > iBest) { iAbility = ABILITY_INTELLIGENCE; iBest = iWit; }
    if (iTpl > iBest) { iAbility = ABILITY_CHARISMA;     iBest = iTpl; }
    if (iWiz > iBest) { iAbility = ABILITY_INTELLIGENCE; iBest = iWiz; }
    if (iWMa > iBest) { iAbility = ABILITY_CHARISMA;     iBest = iWMa; }
    if (iDNc > iBest) { iAbility = ABILITY_CHARISMA;     iBest = iDNc; }
    if (iSor > iBest) { iAbility = ABILITY_CHARISMA;     iBest = iSor; }
    if (iWit > iBest) { iAbility = ABILITY_WISDOM;       iBest = iWit; }
    if (iBeg > iBest) { iAbility = ABILITY_INTELLIGENCE; iBest = iBeg; }
    if (iDiv > iBest) { iAbility = ABILITY_WISDOM;       iBest = iDiv; }

    int nDC;
    if (iBest)   nDC =  20 + GetAbilityModifier(iAbility, oCaster);
    else         nDC =  20; // DC = 20 if the epic spell is cast some other way.

    nDC += GetDCSchoolFocusAdjustment(oCaster, Get2DACache("spells", "school", nSpellID));
    nDC += GetChangesToSaveDC(oTarget, oCaster, nSpellID, GetSpellSchool(nSpellID));

    return nDC;
}

// Test main
//void main(){}
