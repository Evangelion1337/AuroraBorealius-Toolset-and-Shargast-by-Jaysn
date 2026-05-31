//:://////////////////////////////////////////////
//:: Unarmed evaluation include
//:: prc_inc_unarmed
//:://////////////////////////////////////////////
/*
    Handles attack bonus, damage and itemproperties
    for creature weapons created based on class
    and race abilities.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////



//////////////////////////////////////////////////
/* Constant declarations                        */
//////////////////////////////////////////////////

const int ITEM_PROPERTY_WOUNDING = 69;

const string CALL_UNARMED_FEATS = "CALL_UNARMED_FEATS";
const string CALL_UNARMED_FISTS = "CALL_UNARMED_FISTS";
const string UNARMED_CALLBACK   = "UNARMED_CALLBACK";

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////


// Determines the amount of unarmed damage a character can do
// ==========================================================
// oCreature    a creature whose unarmed damage dice are
//              being evaluated
//
// Returns one of the IP_CONST_MONSTERDAMAGE_* constants
int FindUnarmedDamage(object oCreature);

// Adds appropriate unarmed feats to the skin. Goes with UnarmedFists()
// ====================================================================
// oCreature    a creature whose unarmed combat feats to handle
//
// Do not call this directly from your evaluation script. Instead, set
// the local variable CALL_UNARMED_FEATS on the creature to TRUE.
// This is done to avoid bugs from redundant calls to these functions.
void UnarmedFeats(object oCreature);

// Creates/strips a creature weapon and applies bonuses. Goes with UnarmedFeats()
// ==============================================================================
// oCreature    a creature whose creature weapon to handle
//
// Do not call this directly from your evaluation script. Instead, set
// the local variable CALL_UNARMED_FISTS on the creature to TRUE.
// This is done to avoid bugs from redundant calls to these functions.
//
// If you are going to add properties to the creature weapons, hook
// your script for callback after this is evaluated by calling
// AddEventScript(oPC, CALLBACKHOOK_UNARMED, "your_script", FALSE, FALSE);
// When the callback is running, a local int UNARMED_CALLBACK will be
// set on OBJECT_SELF
void UnarmedFists(object oCreature);

/**
 * Determines whether the given object is one of the PRC creature weapons based
 * on it's resref and tag. Resref is tested first, then tag.
 *
 * @param oTest Object to test
 * @return      TRUE if the object is a PRC creature weapon, FALSE otherwise
 */
int GetIsPRCCreatureWeapon(object oTest);

/**
 * Determines the average damage of a IP_CONST_MONSTERDAMAGE_*** constant.
 * Used to compare different unarmed damages.
 *
 * @param  iDamage IP_CONST_MONSTERDAMAGE_*** constant
 * @return         average damage of that constant
 */
float DamageAvg(int iDamage);

//#include "prc_alterations"
//#include "pnp_shft_poly"
//#include "prc_feat_const"
//#include "prc_ipfeat_const"
//#include "prc_class_const"
//#include "prc_racial_const"
//#include "prc_spell_const"
//#include "inc_utility"
#include "prc_inc_natweap"
#include "prc_inc_onhit"

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

// StepDie: increases a damage die by 'nSteps' steps according to d20 SRD progression
// Increment the unarmed damage by nSteps
int StepDie(int nDamage, int nSteps)
{
	int i;
    for (i = 0; i < nSteps; i++)
    {
        switch (nDamage)
        {
            // 1-dice increments
            case IP_CONST_MONSTERDAMAGE_1d2:	nDamage = IP_CONST_MONSTERDAMAGE_1d3; break;
            case IP_CONST_MONSTERDAMAGE_1d3:	nDamage = IP_CONST_MONSTERDAMAGE_1d4; break;
            case IP_CONST_MONSTERDAMAGE_1d4:	nDamage = IP_CONST_MONSTERDAMAGE_1d6; break;
            case IP_CONST_MONSTERDAMAGE_1d6:	nDamage = IP_CONST_MONSTERDAMAGE_1d8; break;
            case IP_CONST_MONSTERDAMAGE_1d8:	nDamage = IP_CONST_MONSTERDAMAGE_1d10; break;
            case IP_CONST_MONSTERDAMAGE_1d10:	nDamage = IP_CONST_MONSTERDAMAGE_1d12; break;
            case IP_CONST_MONSTERDAMAGE_1d12:	nDamage = IP_CONST_MONSTERDAMAGE_2d8; break;

            // 2-dice increments
            //case IP_CONST_MONSTERDAMAGE_2d3:   nDamage = IP_CONST_MONSTERDAMAGE_2d4; break;				
            case IP_CONST_MONSTERDAMAGE_2d4:   	nDamage = IP_CONST_MONSTERDAMAGE_2d6; break;			
            case IP_CONST_MONSTERDAMAGE_2d6:   	nDamage = IP_CONST_MONSTERDAMAGE_2d8; break;
            case IP_CONST_MONSTERDAMAGE_2d8:   	nDamage = IP_CONST_MONSTERDAMAGE_2d10; break;
            case IP_CONST_MONSTERDAMAGE_2d10:  	nDamage = IP_CONST_MONSTERDAMAGE_2d12; break;
            case IP_CONST_MONSTERDAMAGE_2d12:  	nDamage = IP_CONST_MONSTERDAMAGE_3d10; break;			

            // 3-dice increments
            case IP_CONST_MONSTERDAMAGE_3d4:   	nDamage = IP_CONST_MONSTERDAMAGE_3d6; break;
            case IP_CONST_MONSTERDAMAGE_3d6:   	nDamage = IP_CONST_MONSTERDAMAGE_3d8; break;
            case IP_CONST_MONSTERDAMAGE_3d8:   	nDamage = IP_CONST_MONSTERDAMAGE_3d10; break;
            case IP_CONST_MONSTERDAMAGE_3d10:   nDamage = IP_CONST_MONSTERDAMAGE_3d12; break;		
            case IP_CONST_MONSTERDAMAGE_3d12:   nDamage = IP_CONST_MONSTERDAMAGE_4d8; break;				

            // 4-dice increments
            case IP_CONST_MONSTERDAMAGE_4d4:   	nDamage = IP_CONST_MONSTERDAMAGE_4d6; break;
			case IP_CONST_MONSTERDAMAGE_4d6:   	nDamage = IP_CONST_MONSTERDAMAGE_4d8; break;
            case IP_CONST_MONSTERDAMAGE_4d8:   	nDamage = IP_CONST_MONSTERDAMAGE_4d10; break;
            case IP_CONST_MONSTERDAMAGE_4d10:   nDamage = IP_CONST_MONSTERDAMAGE_4d12; break;			
            case IP_CONST_MONSTERDAMAGE_4d12:   nDamage = IP_CONST_MONSTERDAMAGE_5d8; break;

            // 5-dice increments
            case IP_CONST_MONSTERDAMAGE_5d4:   	nDamage = IP_CONST_MONSTERDAMAGE_5d6; break;			
            case IP_CONST_MONSTERDAMAGE_5d6:   	nDamage = IP_CONST_MONSTERDAMAGE_5d8; break;
            case IP_CONST_MONSTERDAMAGE_5d8:   	nDamage = IP_CONST_MONSTERDAMAGE_5d10; break;
			case IP_CONST_MONSTERDAMAGE_5d10:   nDamage = IP_CONST_MONSTERDAMAGE_5d12; break;
			case IP_CONST_MONSTERDAMAGE_5d12:   nDamage = IP_CONST_MONSTERDAMAGE_6d10; break;			

            // 6-dice increments
			//case IP_CONST_MONSTERDAMAGE_6d4:   nDamage = IP_CONST_MONSTERDAMAGE_6d6; break;
            case IP_CONST_MONSTERDAMAGE_6d6:	nDamage = IP_CONST_MONSTERDAMAGE_6d8; break;
            case IP_CONST_MONSTERDAMAGE_6d8:	nDamage = IP_CONST_MONSTERDAMAGE_6d10; break;
            case IP_CONST_MONSTERDAMAGE_6d10:   nDamage = IP_CONST_MONSTERDAMAGE_6d12; break;	
			case IP_CONST_MONSTERDAMAGE_6d12:   nDamage = IP_CONST_MONSTERDAMAGE_7d10; break;

            // 7-dice increments
            case IP_CONST_MONSTERDAMAGE_7d4:	nDamage = IP_CONST_MONSTERDAMAGE_7d6; break;
			case IP_CONST_MONSTERDAMAGE_7d6:   	nDamage = IP_CONST_MONSTERDAMAGE_7d8; break;
            case IP_CONST_MONSTERDAMAGE_7d8:   	nDamage = IP_CONST_MONSTERDAMAGE_7d10; break;
			case IP_CONST_MONSTERDAMAGE_7d10:   nDamage = IP_CONST_MONSTERDAMAGE_7d12; break;
            case IP_CONST_MONSTERDAMAGE_7d12:   nDamage = IP_CONST_MONSTERDAMAGE_9d10; break;

            // 8-dice increments
            //case IP_CONST_MONSTERDAMAGE_8d4:	nDamage = IP_CONST_MONSTERDAMAGE_8d6; break;
			case IP_CONST_MONSTERDAMAGE_8d6:   	nDamage = IP_CONST_MONSTERDAMAGE_8d8; break;
            case IP_CONST_MONSTERDAMAGE_8d8:   	nDamage = IP_CONST_MONSTERDAMAGE_8d10; break;
			case IP_CONST_MONSTERDAMAGE_8d10:   nDamage = IP_CONST_MONSTERDAMAGE_8d12; break;
            case IP_CONST_MONSTERDAMAGE_8d12:   nDamage = IP_CONST_MONSTERDAMAGE_10d10; break;
            
			// 9-dice increments			
            //case IP_CONST_MONSTERDAMAGE_9d4:	nDamage = IP_CONST_MONSTERDAMAGE_9d6; break;
			case IP_CONST_MONSTERDAMAGE_9d6:   	nDamage = IP_CONST_MONSTERDAMAGE_9d8; break;
            case IP_CONST_MONSTERDAMAGE_9d8:   	nDamage = IP_CONST_MONSTERDAMAGE_9d10; break;
			case IP_CONST_MONSTERDAMAGE_9d10:   nDamage = IP_CONST_MONSTERDAMAGE_9d12; break;
            case IP_CONST_MONSTERDAMAGE_9d12:   nDamage = IP_CONST_MONSTERDAMAGE_6d20; break;
			
            // 10-dice increments
            //case IP_CONST_MONSTERDAMAGE_10d4:	nDamage = IP_CONST_MONSTERDAMAGE_10d6; break;	
            case IP_CONST_MONSTERDAMAGE_10d6:	nDamage = IP_CONST_MONSTERDAMAGE_10d8; break;
            case IP_CONST_MONSTERDAMAGE_10d8:	nDamage = IP_CONST_MONSTERDAMAGE_10d10; break;
            case IP_CONST_MONSTERDAMAGE_10d10:	nDamage = IP_CONST_MONSTERDAMAGE_10d12; break;
            case IP_CONST_MONSTERDAMAGE_10d12:	nDamage = IP_CONST_MONSTERDAMAGE_7d20; break;		
			
            // d20 increments
            case IP_CONST_MONSTERDAMAGE_1d20:	nDamage = IP_CONST_MONSTERDAMAGE_3d8; break;
            case IP_CONST_MONSTERDAMAGE_2d20:	nDamage = IP_CONST_MONSTERDAMAGE_4d12; break;
            case IP_CONST_MONSTERDAMAGE_3d20:	nDamage = IP_CONST_MONSTERDAMAGE_8d8; break;
            case IP_CONST_MONSTERDAMAGE_4d20:	nDamage = IP_CONST_MONSTERDAMAGE_8d12; break;			
            case IP_CONST_MONSTERDAMAGE_5d20:	nDamage = IP_CONST_MONSTERDAMAGE_9d12; break;  //:: Everything breaks down here
            case IP_CONST_MONSTERDAMAGE_6d20:	nDamage = IP_CONST_MONSTERDAMAGE_1d20; break;
            case IP_CONST_MONSTERDAMAGE_7d20:	nDamage = IP_CONST_MONSTERDAMAGE_8d20; break;
            case IP_CONST_MONSTERDAMAGE_8d20:	nDamage = IP_CONST_MONSTERDAMAGE_9d20; break;
            case IP_CONST_MONSTERDAMAGE_9d20:	nDamage = IP_CONST_MONSTERDAMAGE_10d20; break;

            default: break; // top tier or unknown
        }
    }
	
	return nDamage;
}


// Clean up any extras in the inventory.
void CleanExtraFists(object oCreature)
{
    int nItemType;
    object oItem  = GetFirstItemInInventory(oCreature);
    object oCWPB  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oCreature);
    object oCWPL  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oCreature);
    object oCWPR  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oCreature);
    object oCSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR,   oCreature);

    while(GetIsObjectValid(oItem))
    {
        nItemType = GetBaseItemType(oItem);

        if(nItemType == BASE_ITEM_CBLUDGWEAPON ||
           nItemType == BASE_ITEM_CPIERCWEAPON ||
           nItemType == BASE_ITEM_CREATUREITEM ||
           nItemType == BASE_ITEM_CSLASHWEAPON ||
           nItemType == BASE_ITEM_CSLSHPRCWEAP
           )
        {
            if(oItem != oCWPB &&
               oItem != oCWPL &&
               oItem != oCWPR &&
               oItem != oCSkin
               )
                MyDestroyObject(oItem);
        }
        oItem = GetNextItemInInventory(oCreature);
    }
}

int GetIsPRCCreatureWeapon(object oTest)
{
    string sTest = GetStringUpperCase(GetResRef(oTest));

    return // First, test ResRef
           sTest == "PRC_UNARMED_B"   ||
           sTest == "PRC_UNARMED_S"   ||
           sTest == "PRC_UNARMED_P"   ||
           sTest == "PRC_UNARMED_SP"  ||
           sTest == "NW_IT_CREWPB010" || // Legacy item, should not be used anymore
           // If resref doesn't match, try tag
           (sTest = GetStringUpperCase(GetTag(oTest))) == "PRC_UNARMED_B" ||
           sTest == "PRC_UNARMED_S"   ||
           sTest == "PRC_UNARMED_P"   ||
           sTest == "PRC_UNARMED_SP"  ||
           sTest == "NW_IT_CREWPB010"
           ;
}

// Remove the unarmed penalty effect
void RemoveUnarmedAttackEffects(object oCreature)
{
    effect e = GetFirstEffect(oCreature);

    while (GetIsEffectValid(e))
    {
        if (GetEffectSpellId(e) == SPELL_UNARMED_ATTACK_PEN)
            RemoveEffect(oCreature, e);

        e = GetNextEffect(oCreature);
    }
}

// Add the unarmed penalty effect -- the DR piercing property gives an unwanted
// attack bonus.  This clears it up.
void ApplyUnarmedAttackEffects(object oCreature)
{
    object oCastingObject = CreateObject(OBJECT_TYPE_PLACEABLE, "x0_rodwonder", GetLocation(OBJECT_SELF));

    AssignCommand(oCastingObject, ActionCastSpellAtObject(SPELL_UNARMED_ATTACK_PEN, oCreature, METAMAGIC_NONE, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));

    DestroyObject(oCastingObject, 6.0);
}

// Determines the amount of damage a character can do.
// IoDM: +1 die at level 4, +2 dice at level 8
// Sacred Fist: Levels add to monk levels, or stand alone as monk levels.
// Shou: 1d6 at level 1, 1d8 at level 2, 1d10 at level 3, 2d6 at level 5
// Monk: 1d6 at level 1, 1d8 at level 4, 1d10 at level 8, 2d6 at level 12, 2d8 at level 16, 2d10 at level 20
// Frostrager: 1d6 at level 1, 1d8 at level 4
int FindUnarmedDamage(object oCreature)
{
    int iDamage = 0;
    int iMonk = GetLevelByClass(CLASS_TYPE_MONK, oCreature) + GetLocalInt(oCreature, "LiPengMonk");
    int iShou = GetLevelByClass(CLASS_TYPE_SHOU, oCreature);
    int iBrawler = GetLevelByClass(CLASS_TYPE_BRAWLER, oCreature);
    int iSacredFist = GetLevelByClass(CLASS_TYPE_SACREDFIST, oCreature);
    int iEnlightenedFist = GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oCreature);
    int iHenshin = GetLevelByClass(CLASS_TYPE_HENSHIN_MYSTIC, oCreature);
    int iZuoken = GetLevelByClass(CLASS_TYPE_FIST_OF_ZUOKEN, oCreature);
    int iShadowSunNinja = GetLevelByClass(CLASS_TYPE_SHADOW_SUN_NINJA, oCreature);
    int iFrost = GetLevelByClass(CLASS_TYPE_FROSTRAGER, oCreature);
    int iAscetic = GetLevelByClass(CLASS_TYPE_NINJA, oCreature);
    int iRonove;
    int iMonkDamage = 1;
    int iShouDamage = 1;
    int iBrawlerDamage = 1;
    int iFrostDamage = 1;
    int iSUSDamage = 1;
    int iDieIncrease = 0;
    int iSize;
    
    if (GetHasSpellEffect(VESTIGE_RONOVE, oCreature) && GetLevelByClass(CLASS_TYPE_BINDER, oCreature))
        iRonove = GetLocalInt(oCreature, "RonovesFists");

    // Determine creature size
    if( GetIsPolyMorphedOrShifted(oCreature) || GetPRCSwitch(PRC_APPEARANCE_SIZE))
    {
         iSize = PRCGetCreatureSize(oCreature) - CREATURE_SIZE_MEDIUM + 5;
    }
    else
    {
        iSize = 5;  // medium
        if (GetHasFeat(FEAT_TINY,  oCreature)) iSize = 3;
        if (GetHasFeat(FEAT_SMALL, oCreature)) iSize = 4;
        if (GetHasFeat(FEAT_LARGE, oCreature)) iSize = 6;
        if (GetHasFeat(FEAT_HUGE,  oCreature)) iSize = 7;
        iSize += PRCGetCreatureSize(oCreature) - PRCGetCreatureSize(oCreature, PRC_SIZEMASK_NONE);
        if (iSize < 1) iSize = 1;
        if (iSize > 9) iSize = 9;
    }

    // Sacred Fist code break protection
    if (GetHasFeat(FEAT_SF_CODE, oCreature)) iSacredFist = 0;

    // Combine monk-like levels
    iMonk += iSacredFist + iHenshin + iEnlightenedFist + iShou + iZuoken + iShadowSunNinja;
    
    // Superior Unarmed Strike
    if (GetHasFeat(FEAT_SUPERIOR_UNARMED_STRIKE, oCreature))
    {
        iMonk += 4;
        int nHD = GetHitDice(oCreature);
        if      (nHD >= 16) iSUSDamage = IP_CONST_MONSTERDAMAGE_2d6;
        else if (nHD >= 12) iSUSDamage = IP_CONST_MONSTERDAMAGE_1d10;
        else if (nHD >= 8)  iSUSDamage = IP_CONST_MONSTERDAMAGE_1d8;
        else if (nHD >= 4)  iSUSDamage = IP_CONST_MONSTERDAMAGE_1d6;
        else if (nHD >= 3)  iSUSDamage = IP_CONST_MONSTERDAMAGE_1d4;
    }    
    
    // Ascetic Stalker
    if (GetHasFeat(FEAT_ASCETIC_STALKER, oCreature))
        iMonk += iAscetic;

    // Cap monk progression
    if (iMonk > 16 && !GetPRCSwitch(PRC_3_5e_FIST_DAMAGE)) iMonk = 16;
    else if (iMonk > 20) iMonk = 20;
    
    // Ronove replacement
    if (iRonove > iMonk) iMonk = iRonove;
	
    // Monk damage calculation
    if (iMonk > 0) iMonkDamage = iMonk / 4 + 3;

    if(iSize == 5 && iMonkDamage == 7 && !GetPRCSwitch(PRC_3_5e_FIST_DAMAGE))
        iMonkDamage = 8;

    // Shou Disciple either adds its level to existing class or does its own damage, depending
    // on which is better. Here we will determine how much damage the Shou Disciple does
    // without stacking.
    //if (iShou > 0) iShouDamage = iShou + 2; // Lv. 1: 1d6, Lv. 2: 1d8, Lv. 3: 1d10
    //if (iShou > 3) iShouDamage--;           // Lv. 4: 1d10, Lv. 5: 2d6
	//iShouDamage = StringToInt(Get2DACache("unarmed_dmg","size" + IntToString(iSize), iShouDamage));
	
	if (iShou > 0)
	{
		// Determine 2DA row for Shou progression
		int nRow;
		if      (iShou == 1) nRow = 3; // monk1
		else if (iShou == 2) nRow = 4; // monk2
		else if (iShou == 3) nRow = 5; // monk3
		else if (iShou == 4) nRow = 6; // monk4
		else if (iShou == 5) nRow = 7; // monk5
		else if (iShou == 6) nRow = 8; // monk6
		else if (iShou == 7) nRow = 9; // monk7
		else                  nRow = 10; // monk8+
		
		nRow += iDieIncrease;
		if (nRow > 10) nRow = 10; // clamp to max row

		// Lookup damage in unarmed_damage.2da using size column
		iShouDamage = StringToInt(Get2DACache("unarmed_dmg","size" + IntToString(iSize), nRow));
	}

    // Frostrager
    if (iFrost > 0) iFrostDamage = IP_CONST_MONSTERDAMAGE_1d6;
    if (iFrost > 3) iFrostDamage = IP_CONST_MONSTERDAMAGE_1d8;

    // Brawler
    if (iBrawler > 0) iBrawlerDamage = iBrawler / 6 + 3;
    if (iBrawler >= 36) iBrawlerDamage += 2;

    // Armor/shield penalties
    if (iMonkDamage > 1)
    {
        object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature);
        object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature);
        int bShieldEq = GetBaseItemType(oShield) == BASE_ITEM_SMALLSHIELD ||
                        GetBaseItemType(oShield) == BASE_ITEM_LARGESHIELD ||
                        GetBaseItemType(oShield) == BASE_ITEM_TOWERSHIELD;

        if (GetBaseAC(oArmor) > 0 || bShieldEq)
            iMonkDamage = 1;
    }

    if (iShouDamage > 1)
    {
        object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature);
        object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature);
        int bShieldEq = GetBaseItemType(oShield) == BASE_ITEM_SMALLSHIELD ||
                        GetBaseItemType(oShield) == BASE_ITEM_LARGESHIELD ||
                        GetBaseItemType(oShield) == BASE_ITEM_TOWERSHIELD;

        if (GetBaseAC(oArmor) > 3 || bShieldEq)
            iShouDamage = 1;
    }

    // IoDM die increase
    if      (GetHasFeat(FEAT_INCREASE_DAMAGE2, oCreature)) iDieIncrease += 2;
    else if (GetHasFeat(FEAT_INCREASE_DAMAGE1, oCreature)) iDieIncrease += 1;

    iMonkDamage    += iDieIncrease;
    iShouDamage    += iDieIncrease;
    iBrawlerDamage += iDieIncrease;
    iFrostDamage   += iDieIncrease;
    iSUSDamage     += iDieIncrease;

    // Lookup final monk damage in 2DA
    iMonkDamage    = StringToInt(Get2DACache("unarmed_dmg","size" + IntToString(iSize), iMonkDamage));

    // 3.0e monk special cases
    if (iSize >= 5 && !GetPRCSwitch(PRC_3_5e_FIST_DAMAGE))
    {
        if (iMonkDamage == IP_CONST_MONSTERDAMAGE_2d6)  iMonkDamage = IP_CONST_MONSTERDAMAGE_1d12;
        if (iMonkDamage == IP_CONST_MONSTERDAMAGE_2d10) iMonkDamage = IP_CONST_MONSTERDAMAGE_1d20;
    }

    // Select best damage
    iDamage = iMonkDamage;
    iDamage = (DamageAvg(iShouDamage   ) > DamageAvg(iDamage)) ? iShouDamage    : iDamage;
    iDamage = (DamageAvg(iFrostDamage  ) > DamageAvg(iDamage)) ? iFrostDamage   : iDamage;
    iDamage = (DamageAvg(iSUSDamage    ) > DamageAvg(iDamage)) ? iSUSDamage     : iDamage;
    
    if (DEBUG) DoDebug("prc_inc_unarmed: iDamage "+IntToString(iDamage));

    return iDamage;
}


// Adds appropriate feats to the skin. Stolen from SoulTaker + expanded with overwhelming/devastating critical.
void UnarmedFeats(object oCreature)
{
    // If we are polymorphed/shifted, do not mess with the creature weapon.
    if (GetIsPolyMorphedOrShifted(oCreature)) return;

    object oSkin = GetPCSkin(oCreature);

    if (!GetHasFeat(FEAT_WEAPON_PROFICIENCY_CREATURE, oCreature))
        AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_WEAPON_PROF_CREATURE),oSkin);

    //only roll unarmed feats into creature feats when not using natural weapons
    if(!GetIsUsingPrimaryNaturalWeapons(oCreature))
    {
        if (GetHasFeat(FEAT_WEAPON_FOCUS_UNARMED_STRIKE, oCreature) && !GetHasFeat(FEAT_WEAPON_FOCUS_CREATURE, oCreature))
            AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_WeapFocCreature),oSkin);

        if (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE, oCreature) && !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_CREATURE, oCreature))
            AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_WeapSpecCreature),oSkin);

        if (GetHasFeat(FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE, oCreature) && !GetHasFeat(FEAT_IMPROVED_CRITICAL_CREATURE, oCreature))
            AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_ImpCritCreature),oSkin);

        if (GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_UNARMED, oCreature) && !GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_CREATURE, oCreature))
            AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_WeapEpicFocCreature),oSkin);

        if (GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_UNARMED, oCreature) && !GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_CREATURE, oCreature))
            AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_WeapEpicSpecCreature),oSkin);

        if (GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_UNARMED, oCreature) && !GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_CREATURE, oCreature))
            AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_OVERCRITICAL_CREATURE),oSkin);

        if (GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_UNARMED, oCreature) && !GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_CREATURE, oCreature))
            AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_DEVCRITICAL_CREATURE),oSkin);
    }
}

// Creates/strips a creature weapon and applies bonuses.  Large chunks stolen from SoulTaker.
void UnarmedFists(object oCreature)
{
    // If we are polymorphed/shifted, do not mess with the creature weapon.
    if (GetIsPolyMorphedOrShifted(oCreature)) return;

    RemoveUnarmedAttackEffects(oCreature);

    object oRighthand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    object oLefthand = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature);
    object oWeapL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oCreature);


    // Clean up the mess of extra fists made on taking first level.
    DelayCommand(6.0f, CleanExtraFists(oCreature));

    // Determine the character's capacity to pierce DR.
    // only applies when not using natural weapons
    if(!GetIsUsingPrimaryNaturalWeapons(oCreature))
    {

        int iRace = GetRacialType(oCreature);
        int iMonk = GetLevelByClass(CLASS_TYPE_MONK, oCreature) + GetLocalInt(oCreature, "LiPengMonk");
        int iShou = GetLevelByClass(CLASS_TYPE_SHOU, oCreature);
        int iSacFist = GetLevelByClass(CLASS_TYPE_SACREDFIST, oCreature);
        int iHenshin = GetLevelByClass(CLASS_TYPE_HENSHIN_MYSTIC, oCreature);
        int iIoDM = GetLevelByClass(CLASS_TYPE_INITIATE_DRACONIC, oCreature);
        int iBrawler = GetLevelByClass(CLASS_TYPE_BRAWLER, oCreature);
        int iZuoken = GetLevelByClass(CLASS_TYPE_FIST_OF_ZUOKEN, oCreature);
    	int iShadowSunNinja = GetLevelByClass(CLASS_TYPE_SHADOW_SUN_NINJA, oCreature);
        int iAscetic = GetLevelByClass(CLASS_TYPE_NINJA, oCreature);

        // Sacred Fists who break their code get no benefits.
        if (GetHasFeat(FEAT_SF_CODE,oCreature)) iSacFist = 0;
		
        // The monk adds all these classes.
        int iMonkEq = iMonk + iShou + iSacFist + iHenshin + iZuoken + iShadowSunNinja;     

        // Ascetic Stalker
        if (GetHasFeat(FEAT_ASCETIC_STALKER, oCreature))
            iMonkEq += iAscetic;   

        // Determine the type of damage the character should do.
        string sWeapType;
        if (GetHasFeat(FEAT_CLAWDRAGON, oCreature))
            sWeapType = "PRC_UNARMED_S";
        else
            sWeapType = "PRC_UNARMED_B";


        // Equip the creature weapon.
        if (!GetIsObjectValid(oWeapL) || GetTag(oWeapL) != sWeapType)
        {
            if (GetHasItem(oCreature, sWeapType))
            {
                oWeapL = GetItemPossessedBy(oCreature, sWeapType);
                SetIdentified(oWeapL, TRUE);
                AssignCommand(oCreature, ActionEquipItem(oWeapL, INVENTORY_SLOT_CWEAPON_L));
            }
            else
            {
                oWeapL = CreateItemOnObject(sWeapType, oCreature);
                SetIdentified(oWeapL, TRUE);
                AssignCommand(oCreature,ActionEquipItem(oWeapL, INVENTORY_SLOT_CWEAPON_L));
            }
        }
		
		// Add Soul Eater onHit property if applicable  
		if (GetLevelByClass(CLASS_TYPE_SOUL_EATER, oCreature) > 0)  
		{  
			Add_OnHitUniquePower(oWeapL, "prc_uni_shift");  
		}		

        int iKi = (iMonkEq > 9)  ? 1 : 0;
            iKi = (iMonkEq > 12) ? 2 : iKi;
            iKi = (iMonkEq > 15) ? 3 : iKi;

        int iDragClaw = GetHasFeat(FEAT_CLAWDRAGON,oCreature) ? 1: 0;
            iDragClaw = GetHasFeat(FEAT_CLAWENH2,oCreature)   ? 2: iDragClaw;
            iDragClaw = GetHasFeat(FEAT_CLAWENH3,oCreature)   ? 3: iDragClaw;

        int iBrawlEnh = iBrawler / 6;

        int iEpicKi = GetHasFeat(FEAT_EPIC_IMPROVED_KI_STRIKE_4,oCreature) ? 1 : 0 ;
            iEpicKi = GetHasFeat(FEAT_EPIC_IMPROVED_KI_STRIKE_5,oCreature) ? 2 : iEpicKi ;

        // The total enhancement to the fist is the sum of all the enhancements above
        int iEnh = iKi + iDragClaw + iBrawlEnh + iEpicKi;

        // Strip the Fist.
        itemproperty ip = GetFirstItemProperty(oWeapL);
        while (GetIsItemPropertyValid(ip))
        {
            RemoveItemProperty(oWeapL, ip);
            ip = GetNextItemProperty(oWeapL);
        }

        // Leave the fist blank if weapons are equipped.  The only way a weapon will
        // be equipped on the left hand is if there is a weapon in the right hand.
        if (GetIsObjectValid(oRighthand)) return;

        // Add glove bonuses.
        object oItem = GetItemInSlot(INVENTORY_SLOT_ARMS,oCreature);
        int iGloveEnh = 0;
        if (GetIsObjectValid(oItem))
        {
            int iType = GetBaseItemType(oItem);
            if (iType == BASE_ITEM_GLOVES)
            {
                ip = GetFirstItemProperty(oItem);
                while(GetIsItemPropertyValid(ip))
                {
                    iType = GetItemPropertyType(ip);
                    switch (iType)
                    {
                        case ITEM_PROPERTY_DAMAGE_BONUS:
                        case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP:
                        case ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP:
                        case ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT:
                        case ITEM_PROPERTY_ON_HIT_PROPERTIES:
                        case ITEM_PROPERTY_ONHITCASTSPELL:
                        case ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE:
                        case ITEM_PROPERTY_KEEN:
                        case ITEM_PROPERTY_MASSIVE_CRITICALS:
                        case ITEM_PROPERTY_POISON:
                        case ITEM_PROPERTY_REGENERATION_VAMPIRIC:
                        case ITEM_PROPERTY_WOUNDING:
                        case ITEM_PROPERTY_DECREASED_DAMAGE:
                        case ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER:
                            DelayCommand(0.1, AddItemProperty(DURATION_TYPE_PERMANENT,ip,oWeapL));
                            break;
                        case ITEM_PROPERTY_ATTACK_BONUS:
                            int iCost = GetItemPropertyCostTableValue(ip);
                            iGloveEnh = (iCost>iGloveEnh) ? iCost:iGloveEnh;
                            iEnh =      (iCost>iEnh)      ? iCost:iEnh;
                            break;
                    }
                    ip = GetNextItemProperty(oItem);
                }
                // handles these seperately so as not to create "attack penalties vs. xxxx"
                ip = GetFirstItemProperty(oItem);
                while(GetIsItemPropertyValid(ip))
                {
                    iType = GetItemPropertyType(ip);
                    switch (iType)
                    {
                        case ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT:
                        case ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP:
                        case ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP:
                        if (GetItemPropertyCostTableValue(ip) > iEnh)
                            DelayCommand(0.1, AddItemProperty(DURATION_TYPE_PERMANENT,ip,oWeapL));
                        break;
                    }
                    ip = GetNextItemProperty(oItem);
                }
            }
        }

        // Add damage resistance penetration.
        DelayCommand(0.1, AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyAttackBonus(iEnh), oWeapL));

        // Cool VFX when striking unarmed
        if (iMonkEq > 9)
            //DelayCommand(0.1, AddItemProperty(DURATION_TYPE_PERMANENT, PRCItemPropertyBonusFeat(IP_CONST_FEAT_KI_STRIKE), oWeapL));
            DelayCommand(0.1, IPSafeAddItemProperty(oWeapL, PRCItemPropertyBonusFeat(IP_CONST_FEAT_KI_STRIKE), 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE));

        // This adds creature weapon finesse and a penalty to offset the DR penetration attack bonus.
        SetLocalInt(oCreature, "UnarmedEnhancement", iEnh);
        SetLocalInt(oCreature, "UnarmedEnhancementGlove", iGloveEnh);
    }

    // Weapon finesse or intuitive attack?
    SetLocalInt(oCreature, "UsingCreature", TRUE);
    ExecuteScript("prc_intuiatk", oCreature);
    DelayCommand(1.0f, DeleteLocalInt(oCreature, "UsingCreature"));
    ApplyUnarmedAttackEffects(oCreature);

    // Add the appropriate damage to the fist.
    int iMonsterDamage = FindUnarmedDamage(oCreature);
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyMonsterDamage(iMonsterDamage),oWeapL);

    // Add OnHitCast: Unique if necessary. Frostrager level 5 grants Rend too
    if(GetHasFeat(FEAT_REND, oCreature) || GetLevelByClass(CLASS_TYPE_FROSTRAGER, oCreature) > 4)
        IPSafeAddItemProperty(oWeapL,
            ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1));

    // Friendly message to remind players that certain things won't appear correct.
    if (GetLocalInt(oCreature, "UnarmedSubSystemMessage") != TRUE
        && GetHasSpellEffect(SPELL_UNARMED_ATTACK_PEN, oCreature))
    {
        SetLocalInt(oCreature, "UnarmedSubSystemMessage", TRUE);
        DelayCommand(3.001f, SendMessageToPC(oCreature, "This character uses the PRC's unarmed system.  This system has been created to"));
        DelayCommand(3.002f, SendMessageToPC(oCreature, "work around many Aurora engine bugs and limitations. Your attack roll may appear to be"));
        DelayCommand(3.003f, SendMessageToPC(oCreature, "incorrect on the character's stats. However, the attack rolls should be correct in"));
        DelayCommand(3.004f, SendMessageToPC(oCreature, "combat. Disregard any attack effects that seem extra: they are part of the workaround."));
        DelayCommand(600.0f, DeleteLocalInt(oCreature, "UnarmedSubSystemMessage"));
    }
}

float DamageAvg(int iDamage)
{
    int iDie = StringToInt(Get2DACache("iprp_monstcost", "Die", iDamage));
    int iNum  = StringToInt(Get2DACache("iprp_monstcost", "NumDice", iDamage));

    return IntToFloat(iNum * (iDie+1)) / 2;
}

//:: void main (){}
