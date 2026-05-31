//::///////////////////////////////////////////////
//:: Name     Shifter PnP functions
//:: FileName
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Functions used by the shifter class to better simulate the PnP rules

*/
//:://////////////////////////////////////////////
//:: Created By: Shane Hennessy
//:: Created On:
//:://////////////////////////////////////////////



//see inc_prc_poly.nss for using shifter code for other spells/abilitys

//unequips then destroys items
void ClearCreatureItem(object oPC, object oTarget);
//shift from quickslot info
void QuickShift(object oPC, int iQuickSlot);
//asign form to your quick slot
void SetQuickSlot(object oPC, int iIndex, int iQuickSlot, int iEpic);
// Determine the level of the Shifter needed to take on
// oTargets shape.
// Returns 1-10 for Shifter level, 11+ for Total levels
int GetShifterLevelRequired(object oTarget);
// Can the shifter (oPC) assume the form of the target
// return Values: TRUE or FALSE
int GetValidShift(object oPC, object oTarget);
// Determine if the oCreature can wear certain equipment
// nInvSlot INVENTORY_SLOT_*
// Return values: TRUE or FALSE
int GetCanFormEquip(object oCreature, int nInvSlot);
// Determine if the oCreature has the ability to cast spells
// Return values: TRUE or FALSE
int GetCanFormCast(object oCreature);
// Determines if the oCreature is harmless enough to have
// special effects applied to the shifter
// Return values: TRUE or FALSE
int GetIsCreatureHarmless(object oCreature);
// Determines the APPEARANCE_TYPE_* for the PC
// based on the players RACIAL type
int GetTrueForm(object oPC);

/**
* Checks if the target is mounted by checking the bX3_IS_MOUNTED variable (Bioware's default).
* A duplicate of Bioware's HorseGetIsMounted() script with almost no changes. From x3_inc_horse.
* Here because it's called most places ShifterCheck() is called, also added to CanShift()
* Bioware's one not used to avoid circular include hell
* @param oTarget
* @return TRUE if oTarget is mounted
*/
int PRCHorseGetIsMounted(object oTarget);


//is inventory full if yes then CanShift = false else CanShift = true
int CanShift(object oPC);

// Transforms the oPC into the oTarget using the epic rules
// Assumes oTarget is already a valid target
// Return values: TRUE or FALSE
int SetShiftEpic(object oPC, object oTarget);

// helper function to SetVisualTrueForm() for DelayCommand() to work on
void SetBodyPartTrueForm(object oPC, int i);
// Transforms the oPC back to thier true form if they are shifted
// Return values: TRUE or FALSE
void SetShiftTrueForm(object oPC);
// Creates a temporary creature for the shifter to shift into
// Validates the shifter is able to become that creature based on level
// Return values: TRUE or FALSE
int SetShiftFromTemplateValidate(object oPC, string sTemplate, int iEpic);

// Extra item functions
// Copys all the item properties from the target to the destination
void CopyAllItemProperties(object oDestination,object oTarget);
// Removes all the item properties from the item
void RemoveAllItemProperties(object oItem);
// Gets an IP_CONST_FEAT_* from FEAT_*
// returns -1 if the feat is not available
int GetIPFeatFromFeat(int nFeat);
// Determines if the target creature has a certain type of spell
// and sets the powers onto the object item
void SetItemSpellPowers(object oItem, object oTarget);

// Removes leftover aura effects
void RemoveAuraEffect( object oPC );
// Adds a creature to the list of valid GWS shift possibilities
void RecognizeCreature( object oPC, string sTemplate, string sCreatureName );
// Checks to see if the specified creature is a valid GWS shift choice
int IsKnownCreature( object oPC, string sTemplate );
// Shift based on position in the known array
// oTemplate is either the epic or normal template
void ShiftFromKnownArray(int nIndex,int iEpic, object oPC);
//delete form from spark
void DeleteFromKnownArray(int nIndex, object oPC);
//store the appearance of the pc away for unshifting
void StoreAppearance(object oPC);
// Transforms the oPC into the oTarget
// Assumes oTarget is already a valid target
// this is 2 stage
// these 2 scripts replace the origanel setshift script
// (setshift_02 is almost all of the origenal setshift script)
void SetShift(object oPC, object oTarget);
void SetShift_02(object oPC, object oTarget);


// Generic includes
#include "prc_inc_function"


void StoreAppearance(object oPC)
{
    if (GetLocalInt(oPC, "shifting") || GetPersistantLocalInt(oPC, "nPCShifted"))
        return;

    int iIsStored = GetPersistantLocalInt( oPC, "AppearanceIsStored" );

    if (iIsStored == 6)
    {
        //already stored
    }
    else
    {
        SetPersistantLocalInt(oPC,    "AppearanceIsStored", 6);
        SetPersistantLocalInt(oPC,    "AppearanceStored", GetAppearanceType(oPC));
        SetPersistantLocalInt(oPC,    "AppearanceStoredPortraitID", GetPortraitId(oPC));
        SetPersistantLocalString(oPC, "AppearanceStoredPortraitResRef", GetPortraitResRef(oPC));
        SetPersistantLocalInt(oPC,    "AppearanceStoredTail", GetCreatureTailType(oPC));
        SetPersistantLocalInt(oPC,    "AppearanceStoredWing", GetCreatureWingType(oPC));
        int i;
        for(i=0;i<=20;i++)
        {
            SetPersistantLocalInt(oPC,    "AppearanceStoredPart"+IntToString(i), GetCreatureBodyPart(i, oPC));
        }
    }
}

// PURPOSE: Return whether oTarget is mounted
int PRCHorseGetIsMounted(object oTarget)
{
    if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
    {
        //original function uses GetSkinInt() so we have to get creature skin here
        object oSkin = GetIsPC(oTarget) ? GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTarget) : oTarget;
        if(GetLocalInt(oSkin, "bX3_IS_MOUNTED"))
            return TRUE;
    }
    return FALSE;
}

int CanShift(object oPC)
{
    int iOutcome = FALSE;
    // stop if mounted
    if(PRCHorseGetIsMounted(oPC))
    {
        // bio default poly floaty text
        // "You cannot shapeshift while mounted."
        if (GetIsPC(oPC)) FloatingTextStrRefOnCreature(111982,oPC,FALSE);
        return iOutcome;
    }

    if (GetLocalInt(oPC, "shifting") || GetPersistantLocalInt(oPC, "nPCShifted"))
    {
        return iOutcome;
    }

    object oItem1 = CreateItemOnObject("pnp_shft_tstpkup", oPC);
    object oItem2 = CreateItemOnObject("pnp_shft_tstpkup", oPC);
    object oItem3 = CreateItemOnObject("pnp_shft_tstpkup", oPC);
    object oItem4 = CreateItemOnObject("pnp_shft_tstpkup", oPC);
    if ((GetItemPossessor(oItem1) == oPC) && (GetItemPossessor(oItem2) == oPC) && (GetItemPossessor(oItem3) == oPC) && (GetItemPossessor(oItem4) == oPC))
    {
        iOutcome = TRUE;
    }
    else
    {
        SendMessageToPC(oPC, "Your inventory is too full to allow you to (un)shift.");
        SendMessageToPC(oPC, "Please make room enough for 4 Helm-sized items and then try again.");
    }

    DestroyObject(oItem1);
    DestroyObject(oItem2);
    DestroyObject(oItem3);
    DestroyObject(oItem4);

    //there are issues with shifting will polymorphed
    effect eEff = GetFirstEffect(oPC);
    while (GetIsEffectValid(eEff))
    {
        int eType = GetEffectType(eEff);
        if (eType == EFFECT_TYPE_POLYMORPH)
        {
            SendMessageToPC(oPC, "Shifting when polymorphed has been disabled.");
            SendMessageToPC(oPC, "Please cancel your polymorph first.");
            return FALSE;
        }
        eEff = GetNextEffect(oPC);
    }
    return iOutcome;
}

void QuickShift(object oPC, int iQuickSlot)
{
    int iMaxIndex = GetPersistantLocalInt(oPC, "num_creatures");
    persistant_array_create(oPC, "QuickSlotIndex");
    persistant_array_create(oPC, "QuickSlotEpic");
    int iIndex = persistant_array_get_int(oPC, "QuickSlotIndex", iQuickSlot);
    int iEpic = persistant_array_get_int(oPC, "QuickSlotEpic", iQuickSlot);
    if(!(iIndex>iMaxIndex))
        ShiftFromKnownArray(iIndex, iEpic, oPC);
}

void SetQuickSlot(object oPC, int iIndex, int iQuickSlot, int iEpic)
{
    persistant_array_create(oPC, "QuickSlotIndex");
    persistant_array_create(oPC, "QuickSlotEpic");
    persistant_array_set_int(oPC,"QuickSlotIndex",iQuickSlot,iIndex);
    persistant_array_set_int(oPC,"QuickSlotEpic",iQuickSlot,iEpic);
}

// Transforms the oPC into the oTarget
// Assumes oTarget is already a valid target
// starts here and then goes to SetShift_02

// stage 1:
//   if the shifter if already shifted call unshift to run after this stage ends
//   call next stage to start after this stage ends
void SetShift(object oPC, object oTarget)
{
    SetLocalInt(oPC, "shifting", TRUE);

    SetShiftTrueForm(oPC);
    DelayCommand(0.10, SetShift_02(oPC, oTarget));
}
// stage 1 end:
//   the shifter is unshifted if need be
//   and the next stage is called

// stage 2:
//   this is most of what the old SetShift script did
//   the changes are:
//     no check for if shifted is needed and has been removed
//     the epic ability item is done here (if epicshifter var is 1)
//     oTarget is destryed in this script if its from the convo
void SetShift_02(object oPC, object oTarget)
{
	int nMaxBonus = GetPRCSwitch(PRC_PNP_SHIFTER_BONUS);
	int nMaxPen = -10;

    //get all the creature items from the target
    object oHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oTarget);
    object oWeapCR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oTarget);
    object oWeapCL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oTarget);
    object oWeapCB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oTarget);

    //get all the creature items from the pc
    object oHidePC = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);
    object oWeapCRPC = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);
    object oWeapCLPC = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
    object oWeapCBPC = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);

    //creature item handling
    if (!GetIsObjectValid(oHidePC)) //if you dont have a hide
    {
        oHidePC = CopyObject(oHide, GetLocation(oPC), oPC);  //copy the targets hide
        if (!GetIsObjectValid(oHidePC))  //if the target dont have a hide
        {
            oHidePC = CreateItemOnObject("shifterhide", oPC);  //use a blank shifter hide
        }
        // Need to ID the stuff before we can put it on the PC
        SetIdentified(oHidePC, TRUE);
    }
    else // if you do have a hide
    {
        ScrubPCSkin(oPC, oHidePC); //clean off all old props
        CopyAllItemProperties(oHidePC, oHide); //copy all target props to our hide
    }
    DelayCommand(0.05, AssignCommand(oPC, ActionEquipItem(oHidePC, INVENTORY_SLOT_CARMOUR))); //reequip the hide to get item props to update properly

    // Set a flag on the PC to tell us that they are shifted
    // set this early to prevent alot of unequip code from firing and causing an overflow
    SetPersistantLocalInt(oPC,"nPCShifted",TRUE);


    //copy targets right creature weapon
    if (GetIsObjectValid(oWeapCRPC)) //if we still have a creature weapon
    {
        //remove and destroy the weapon we have
        DelayCommand(0.90, ClearCreatureItem(oPC, oWeapCRPC));
    }
    if (GetIsObjectValid(oWeapCR)) //if the target has a weapon
    {
        oWeapCRPC = CreateItemOnObject("pnp_shft_cweap", oPC); //create a shifter blank creature weapon
        CopyAllItemProperties(oWeapCRPC, oWeapCR); //copy all target props over
        SetIdentified(oWeapCRPC, TRUE); //id so we dont get any funny stuff when equiping
        DelayCommand(0.2, AssignCommand(oPC, ActionEquipItem(oWeapCRPC, INVENTORY_SLOT_CWEAPON_R))); //reequip the item to get item props to update properly
    }

    //copy targets left creature weapon
    if (GetIsObjectValid(oWeapCLPC)) //if we still have a creature weapon
    {
        //remove and destroy the weapon we have
        DelayCommand(0.90, ClearCreatureItem(oPC, oWeapCLPC));
    }
    if (GetIsObjectValid(oWeapCL)) //if the target has a weapon
    {
        oWeapCLPC = CreateItemOnObject("pnp_shft_cweap", oPC); //create a shifter blank creature weapon
        CopyAllItemProperties(oWeapCLPC, oWeapCL); //copy all target props over
        SetIdentified(oWeapCLPC, TRUE); //id so we dont get any funny stuff when equiping
        DelayCommand(0.2, AssignCommand(oPC, ActionEquipItem(oWeapCLPC, INVENTORY_SLOT_CWEAPON_L))); //reequip the item to get item props to update properly
    }
    //copy targets special creature weapons
    if (GetIsObjectValid(oWeapCBPC)) //if we still have a creature weapon
    {
        //remove and destroy the weapon we have
        DelayCommand(0.90, ClearCreatureItem(oPC, oWeapCBPC));
    }
    if (GetIsObjectValid(oWeapCB)) //if the target has a weapon
    {
        oWeapCBPC = CreateItemOnObject("pnp_shft_cweap", oPC); //create a shifter blank creature weapon
        CopyAllItemProperties(oWeapCBPC, oWeapCB); //copy all target props over
        SetIdentified(oWeapCBPC, TRUE); //id so we dont get any funny stuff when equiping
        DelayCommand(0.2, AssignCommand(oPC, ActionEquipItem(oWeapCBPC, INVENTORY_SLOT_CWEAPON_B))); //reequip the item to get item props to update properly
    }

    // Get the Targets str, dex, and con
    int nTStr = GetAbilityScore(oTarget, ABILITY_STRENGTH);
    int nTDex = GetAbilityScore(oTarget, ABILITY_DEXTERITY);
    int nTCon = GetAbilityScore(oTarget, ABILITY_CONSTITUTION);

    // Get the PCs str, dex, and con from the clone
    int nPCStr = GetAbilityScore(oPC, ABILITY_STRENGTH,     TRUE);
    int nPCDex = GetAbilityScore(oPC, ABILITY_DEXTERITY,    TRUE);
    int nPCCon = GetAbilityScore(oPC, ABILITY_CONSTITUTION, TRUE);

    // Get the deltas
    int nStrDelta = nTStr - nPCStr;
    int nDexDelta = nTDex - nPCDex;
    int nConDelta = nTCon - nPCCon;

    int iRemainingSTR;
    int iRemainingCON;
    int iRemainingDEX;

    // Cap max to +nMaxBonus til they can fix it and nMaxPen for the low value
    // get remaining bonus/penelty for later
    if (nStrDelta > nMaxBonus)
    {
        iRemainingSTR = nStrDelta - nMaxBonus;
        nStrDelta = nMaxBonus;
    }
    if (nStrDelta < nMaxPen)
    {
        iRemainingSTR = nStrDelta + 10;
        nStrDelta = nMaxPen;
    }
    if (nDexDelta > nMaxBonus)
    {
        iRemainingDEX = nDexDelta - nMaxBonus;
        nDexDelta = nMaxBonus;
    }
    if (nDexDelta < nMaxPen)
    {
        iRemainingDEX = nDexDelta + 10;
        nDexDelta = nMaxPen;
    }
    if (nConDelta > nMaxBonus)
    {
        iRemainingCON = nConDelta - nMaxBonus;
        nConDelta = nMaxBonus;
    }
    if (nConDelta < nMaxPen)
    {
        iRemainingCON = nConDelta + 10;
        nConDelta = nMaxPen;
    }

    // Big problem with < 0 to abilities, if they have immunity to ability drain
    // the "-" to the ability wont do anything

    // Apply these boni to the creature hide
    if (nStrDelta > 0)
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR, nStrDelta), oHidePC);
    else
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDecreaseAbility(IP_CONST_ABILITY_STR, nStrDelta*-1), oHidePC);
    if (nDexDelta > 0)
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAbilityBonus(IP_CONST_ABILITY_DEX, nDexDelta), oHidePC);
    else
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDecreaseAbility(IP_CONST_ABILITY_DEX, nDexDelta*-1), oHidePC);
    if (nConDelta > 0)
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAbilityBonus(IP_CONST_ABILITY_CON, nConDelta), oHidePC);
    else
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDecreaseAbility(IP_CONST_ABILITY_CON, nConDelta*-1), oHidePC);

    //add extra str bonuses to pc as attack bonues and damage bonus
    int iExtSTRBon;
    effect eAttackIncrease;
    effect eDamageIncrease;
    if (iRemainingSTR != 0)
    {
        int iDamageType = DAMAGE_TYPE_BLUDGEONING;
        iExtSTRBon = FloatToInt(iRemainingSTR/2.0);

        if (GetIsObjectValid(oWeapCR))
        {
            int iCR = GetBaseItemType(oWeapCR);
            if ((iCR == BASE_ITEM_CSLASHWEAPON) || (iCR == BASE_ITEM_CSLSHPRCWEAP))
                iDamageType = DAMAGE_TYPE_SLASHING;
            else if (iCR == BASE_ITEM_CPIERCWEAPON)
                iDamageType = DAMAGE_TYPE_PIERCING;
        }
        else if (GetIsObjectValid(oWeapCL))
        {
            int iCL = GetBaseItemType(oWeapCL);
            if ((iCL == BASE_ITEM_CSLASHWEAPON) || (iCL == BASE_ITEM_CSLSHPRCWEAP))
                iDamageType = DAMAGE_TYPE_SLASHING;
            else if (iCL == BASE_ITEM_CPIERCWEAPON)
                iDamageType = DAMAGE_TYPE_PIERCING;
        }
        else if (GetIsObjectValid(oWeapCB))
        {
            int iCB = GetBaseItemType(oWeapCB);
            if ((iCB == BASE_ITEM_CSLASHWEAPON) || (iCB == BASE_ITEM_CSLSHPRCWEAP))
                iDamageType = DAMAGE_TYPE_SLASHING;
            else if (iCB == BASE_ITEM_CPIERCWEAPON)
                iDamageType = DAMAGE_TYPE_PIERCING;
        }

        int iDamageB;
        switch (iExtSTRBon)
        {
        case 0:
            iDamageB = 0;
            break;
        case 1:
        case -1:
            iDamageB = DAMAGE_BONUS_1;
            break;
        case 2:
        case -2:
            iDamageB = DAMAGE_BONUS_2;
            break;
        case 3:
        case -3:
            iDamageB = DAMAGE_BONUS_3;
            break;
        case 4:
        case -4:
            iDamageB = DAMAGE_BONUS_4;
            break;
        case 5:
        case -5:
            iDamageB = DAMAGE_BONUS_5;
            break;
        case 6:
        case -6:
            iDamageB = DAMAGE_BONUS_6;
            break;
        case 7:
        case -7:
            iDamageB = DAMAGE_BONUS_7;
            break;
        case 8:
        case -8:
            iDamageB = DAMAGE_BONUS_8;
            break;
        case 9:
        case -9:
            iDamageB = DAMAGE_BONUS_9;
            break;
        case 10:
        case -10:
            iDamageB = DAMAGE_BONUS_10;
            break;
        case 11:
        case -11:
            iDamageB = DAMAGE_BONUS_11;
            break;
        case 12:
        case -12:
            iDamageB = DAMAGE_BONUS_12;
            break;
        case 13:
        case -13:
            iDamageB = DAMAGE_BONUS_13;
            break;
        case 14:
        case -14:
            iDamageB = DAMAGE_BONUS_14;
            break;
        case 15:
        case -15:
            iDamageB = DAMAGE_BONUS_15;
            break;
        case 16:
        case -16:
            iDamageB = DAMAGE_BONUS_16;
            break;
        case 17:
        case -17:
            iDamageB = DAMAGE_BONUS_17;
            break;
        case 18:
        case -18:
            iDamageB = DAMAGE_BONUS_18;
            break;
        case 19:
        case -19:
            iDamageB = DAMAGE_BONUS_19;
            break;
        default:
            iDamageB = DAMAGE_BONUS_20;
            break;
        }

        if (iRemainingSTR > 0)
        {
            eAttackIncrease = EffectAttackIncrease(iDamageB, ATTACK_BONUS_MISC);
            eDamageIncrease = EffectDamageIncrease(iDamageB, iDamageType);
        }
        else if (iRemainingSTR < 0)
        {
            eAttackIncrease = EffectAttackDecrease(iDamageB, ATTACK_BONUS_MISC);
            eDamageIncrease = EffectDamageDecrease(iDamageB, iDamageType);
        }

        ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(eAttackIncrease),oPC);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(eDamageIncrease),oPC);
    }

    //add extra con bonus as temp HP
    if (iRemainingCON > 0)
    {
        int iExtCONBon = FloatToInt(iRemainingCON/2.0);
        effect eTemporaryHitpoints = EffectTemporaryHitpoints(iExtCONBon * GetHitDice(oPC));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(eTemporaryHitpoints),oPC);
    }

    // Apply the natural AC bonus to the hide
    // First get the AC from the target
    int nTAC = GetAC(oTarget);
    nTAC -= GetAbilityModifier(ABILITY_DEXTERITY, oTarget);
    // All creatures have 10 base AC
    nTAC -= 10;
    int i;
    for (i=0; i < NUM_INVENTORY_SLOTS; i++)
    {
        nTAC -= GetItemACValue(GetItemInSlot(i,oTarget));
    }

    if (nTAC > 0)
    {
        effect eAC = EffectACIncrease(nTAC,AC_NATURAL_BONUS);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(eAC),oPC);
    }

    //add extra dex bonus as dodge ac
    if (iRemainingDEX != 0)
    {
        int iExtDEXBon = FloatToInt(iRemainingDEX/2.0);
        effect eACIncrease;
        if (iRemainingDEX > 0)
        {
            object oPCArmour = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
            if (GetIsObjectValid(oPCArmour))
            {
                int iACArmour = GetItemACValue(oPCArmour);
                int iMaxDexBon;
                int iCurentDexBon;
                iCurentDexBon = FloatToInt(((nPCDex + nStrDelta)-10.0)/2.0);
                switch (iACArmour)
                {
                case 8:
                case 7:
                case 6:
                    iMaxDexBon = 1;
                    break;
                case 5:
                    iMaxDexBon = 2;
                    break;
                case 4:
                case 3:
                    iMaxDexBon = 4;
                    break;
                case 2:
                    iMaxDexBon = 6;
                    break;
                case 1:
                    iMaxDexBon = 8;
                    break;
                default:
                    iMaxDexBon = 100;
                    break;
                }
                if (iCurentDexBon > iMaxDexBon)
                {
                    iExtDEXBon = 0;
                }
                else
                {
                    if ((iExtDEXBon+iCurentDexBon) > iMaxDexBon)
                    {
                        iExtDEXBon = iMaxDexBon - iCurentDexBon;
                    }
                }
            }
            eACIncrease = EffectACIncrease(iExtDEXBon);
        }
        else if (iRemainingDEX < 0)
        {
            eACIncrease = EffectACDecrease(iExtDEXBon * -1);
        }
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(eACIncrease),oPC);
    }

    // Apply any feats the target has to the hide as a bonus feat
    for (i = 0; i< 500; i++)
    {
        if (GetHasFeat(i,oTarget))
        {
            int nIP =  GetIPFeatFromFeat(i);
            if(nIP != -1)
            {
                itemproperty iProp = PRCItemPropertyBonusFeat(nIP);
                AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oHidePC);
            }

        }
    }
    // Fix the biobugged Improved Critical (creature) by giving the PC Improved Critical (unarmed) which seems
    // to work with creature weapons
    if (!GetHasFeat(FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE, oPC) && GetHasFeat(FEAT_IMPROVED_CRITICAL_CREATURE, oPC))
        AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(IP_CONST_FEAT_IMPCRITUNARM),oHidePC);


    // If they dont have the natural spell feat they can only cast spells in certain shapes
    if (!GetHasFeat(FEAT_PRESTIGE_SHIFTER_NATURALSPELL,oPC))
    {
        if (!GetCanFormCast(oTarget))
        {
            // remove the ability from the PC to cast
            effect eNoCast = EffectSpellFailure();
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(eNoCast),oPC);
        }
    }

    // If the creature is "harmless" give it a perm invis for stealth
    if(GetIsCreatureHarmless(oTarget))
    {
        effect eInvis = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(eInvis),oPC);
    }


    // Change the Appearance of the PC
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_POLYMORPH), oPC);
    //get the appearance of oTarget
    int iAppearance = GetLocalInt(oTarget,"Appearance");
    if (iAppearance>0)
        SetCreatureAppearanceType(oPC,iAppearance);
    else
        SetCreatureAppearanceType(oPC,GetAppearanceType(oTarget));
    //do 1.67 stuff
    //wing/tails
    SetCreatureWingType(GetCreatureWingType(oTarget), oPC);
    SetCreatureTailType(GetCreatureTailType(oTarget), oPC);
    //portrait
    SetPortraitResRef(oPC, GetPortraitResRef(oTarget));
    SetPortraitId(oPC, GetPortraitId(oTarget));
    //bodyparts
    for(i=0;i<=20;i++)
    {
        DelayCommand(1.0, SetCreatureBodyPart(i, GetCreatureBodyPart(i, oTarget), oPC));
    }

    // For spells to make sure they now treat you like the new race
    SetLocalInt(oPC,"RACIAL_TYPE",MyPRCGetRacialType(oTarget)+1);

    // PnP rules say the shifter would heal as if they rested
    effect eHeal = EffectHeal(GetHitDice(oPC)*d4());
    ApplyEffectToObject(DURATION_TYPE_INSTANT,eHeal,oPC);

    //epic shift
    if (GetLocalInt(oPC,"EpicShift"))
    {
        // Create some sort of usable item to represent monster spells
        object oEpicPowersItem; // = GetItemPossessedBy(oPC,"EpicShifterPowers");
        //if (!GetIsObjectValid(oEpicPowersItem))
        oEpicPowersItem = CreateItemOnObject("epicshifterpower",oPC);
        SetItemSpellPowers(oEpicPowersItem,oTarget);
    }

    //clear epic shift var
    SetLocalInt(oPC,"EpicShift",0);

    //remove oTarget if it is from the template
    int iDeleteMe = GetLocalInt(oTarget,"pnp_shifter_deleteme");
    if (iDeleteMe==1)
    {
        // Remove the temporary creature
        AssignCommand(oTarget,SetIsDestroyable(TRUE,FALSE,FALSE));
        SetPlotFlag(oTarget,FALSE);
        SetImmortal(oTarget,FALSE);
        DestroyObject(oTarget);
    }

    // Reset any PRC feats that might have been lost from the shift
    DelayCommand(1.0, EvalPRCFeats(oPC));

    DelayCommand(3.0, DeleteLocalInt(oPC, "shifting"));
    SendMessageToPC(oPC, "Finished shifting");
}

// stage 2 end:
//   the target is distroyed(target only if not mimic target)
//   all effects and item propertys are applyed to you and your hide/cweapons


void RecognizeCreature( object oPC, string sTemplate, string sCreatureName )
{

    // Only add new ones
    if (IsKnownCreature(oPC,sTemplate))
        return;

    int num_creatures = GetPersistantLocalInt( oPC, "num_creatures" );
    persistant_array_create(oPC, "shift_choice");
    persistant_array_create(oPC, "shift_choice_name");
    persistant_array_set_string( oPC, "shift_choice", num_creatures, sTemplate );
    persistant_array_set_string( oPC, "shift_choice_name", num_creatures, sCreatureName );//added the line to store the name as well as the resref
    SetPersistantLocalInt( oPC, "num_creatures", num_creatures+1 );

}

int IsKnownCreature( object oPC, string sTemplate )
{
//    object oMimicForms = GetItemPossessedBy( oPC, "sparkoflife" );
    int num_creatures = GetPersistantLocalInt( oPC, "num_creatures" );
    int i;
    string cmp;

    for ( i=0; i<num_creatures; i++ )
    {
        cmp = persistant_array_get_string( oPC, "shift_choice", i );
        if ( TestStringAgainstPattern( cmp, sTemplate ) )
        {
            return TRUE;
        }
    }
    return FALSE;
}

void DeleteFromKnownArray(int nIndex, object oPC)
{
//  object oMimicForms = GetItemPossessedBy( oPC, "sparkoflife" );
    int num_creatures = GetPersistantLocalInt( oPC, "num_creatures" );
    int i;

    persistant_array_create(oPC, "shift_choice");
    persistant_array_create(oPC, "shift_choice_name");

    for ( i=nIndex; i<(num_creatures-1); i++ )
    {
        persistant_array_set_string( oPC, "shift_choice", i, persistant_array_get_string( oPC, "shift_choice", i+1 ));
        persistant_array_set_string( oPC, "shift_choice_name", i, persistant_array_get_string( oPC, "shift_choice_name", i+1 ));
    }
    persistant_array_shrink(oPC, "shift_choice", num_creatures-1);
    persistant_array_shrink(oPC, "shift_choice_name", num_creatures-1);
    SetPersistantLocalInt(oPC, "num_creatures", num_creatures-1 );
}

// Shift based on position in the known array
void ShiftFromKnownArray(int nIndex, int iEpic, object oPC)
{

    // Find the name
    string sResRef = persistant_array_get_string(oPC, "shift_choice", nIndex);
    if (iEpic == TRUE)
    {
        // epic shift
        SetShiftFromTemplateValidate(oPC, sResRef, TRUE);
    }
    else
    {
        // Force a normal shift
        SetShiftFromTemplateValidate(oPC, sResRef, FALSE);
    }
}

// This is a duplicate of PRCRemoveEffectsFromSpell, it prevents calling unneeded includes
void RemoveEffectsFromPoly(int SpellID, object oTarget)
{
  effect eLook = GetFirstEffect(oTarget);
  while (GetIsEffectValid(eLook)) {
    if (GetEffectSpellId(eLook) == SpellID)
      RemoveEffect(oTarget, eLook);
    eLook = GetNextEffect(oTarget);
  }
}

// Remove "dangling" aura effects on trueform shift
// Now only removes things it should remove (i.e., auras)
void RemoveAuraEffect( object oPC )
{
    if ( GetHasSpellEffect(SPELLABILITY_AURA_BLINDING, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_BLINDING, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_COLD, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_COLD, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_ELECTRICITY, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_ELECTRICITY, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_FEAR, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_FEAR, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_FIRE, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_FIRE, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_MENACE, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_MENACE, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_PROTECTION, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_PROTECTION, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_STUN, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_STUN, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_UNEARTHLY_VISAGE, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_UNEARTHLY_VISAGE, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_AURA_UNNATURAL, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_AURA_UNNATURAL, oPC);
    if ( GetHasSpellEffect(SPELLABILITY_DRAGON_FEAR, oPC) )
        RemoveEffectsFromPoly( SPELLABILITY_DRAGON_FEAR, oPC);
}


void CopyAllItemProperties(object oDestination, object oTarget)
{
    itemproperty iProp = GetFirstItemProperty(oTarget);

    while (GetIsItemPropertyValid(iProp))
    {
        AddItemProperty(GetItemPropertyDurationType(iProp), iProp, oDestination);
        iProp = GetNextItemProperty(oTarget);
    }
}



void RemoveAllItemProperties(object oItem)
{
    itemproperty iProp = GetFirstItemProperty(oItem);

    while (GetIsItemPropertyValid(iProp))
    {

//        SendMessageToPC(GetItemPossessor(oItem),"item prop type-" + IntToString(GetItemPropertyType(iProp)));

        RemoveItemProperty(oItem,iProp);
        iProp = GetNextItemProperty(oItem);

    }
    // for a skin and prcs to get their feats back
    DeletePRCLocalInts(oItem);
}

// Gets an IP_CONST_FEAT_* from FEAT_*
// -1 is an invalid IP_CONST_FEAT
int GetIPFeatFromFeat(int nFeat)
{
    switch (nFeat)
    {
    case FEAT_ALERTNESS:
        return IP_CONST_FEAT_ALERTNESS;
    case FEAT_AMBIDEXTERITY:
        return IP_CONST_FEAT_AMBIDEXTROUS;
    case FEAT_ARMOR_PROFICIENCY_HEAVY:
        return IP_CONST_FEAT_ARMOR_PROF_HEAVY;
    case FEAT_ARMOR_PROFICIENCY_LIGHT:
        return IP_CONST_FEAT_ARMOR_PROF_LIGHT;
    case FEAT_ARMOR_PROFICIENCY_MEDIUM:
        return IP_CONST_FEAT_ARMOR_PROF_MEDIUM;
    case FEAT_CLEAVE:
        return IP_CONST_FEAT_CLEAVE;
    case FEAT_COMBAT_CASTING:
        return IP_CONST_FEAT_COMBAT_CASTING;
    case FEAT_DODGE:
        return IP_CONST_FEAT_DODGE;
    case FEAT_EXTRA_TURNING:
        return IP_CONST_FEAT_EXTRA_TURNING;
    case FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE:
        return IP_CONST_FEAT_IMPCRITUNARM;
    case FEAT_IMPROVED_KNOCKDOWN:
    case FEAT_KNOCKDOWN:
        return IP_CONST_FEAT_KNOCKDOWN;
    case FEAT_POINT_BLANK_SHOT:
        return IP_CONST_FEAT_POINTBLANK;
    case FEAT_POWER_ATTACK:
    case FEAT_IMPROVED_POWER_ATTACK:
        return IP_CONST_FEAT_POWERATTACK;
    case FEAT_SPELL_FOCUS_ABJURATION:
    case FEAT_EPIC_SPELL_FOCUS_ABJURATION:
    case FEAT_GREATER_SPELL_FOCUS_ABJURATION:
        return IP_CONST_FEAT_SPELLFOCUSABJ;
    case FEAT_SPELL_FOCUS_CONJURATION:
    case FEAT_EPIC_SPELL_FOCUS_CONJURATION:
    case FEAT_GREATER_SPELL_FOCUS_CONJURATION:
        return IP_CONST_FEAT_SPELLFOCUSCON;
    case FEAT_SPELL_FOCUS_DIVINATION:
    case FEAT_EPIC_SPELL_FOCUS_DIVINATION:
    case FEAT_GREATER_SPELL_FOCUS_DIVINIATION:
        return IP_CONST_FEAT_SPELLFOCUSDIV;
    case FEAT_SPELL_FOCUS_ENCHANTMENT:
    case FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT:
    case FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT:
        return IP_CONST_FEAT_SPELLFOCUSENC;
    case FEAT_SPELL_FOCUS_EVOCATION:
    case FEAT_EPIC_SPELL_FOCUS_EVOCATION:
    case FEAT_GREATER_SPELL_FOCUS_EVOCATION:
        return IP_CONST_FEAT_SPELLFOCUSEVO;
    case FEAT_SPELL_FOCUS_ILLUSION:
    case FEAT_EPIC_SPELL_FOCUS_ILLUSION:
    case FEAT_GREATER_SPELL_FOCUS_ILLUSION:
        return IP_CONST_FEAT_SPELLFOCUSILL;
    case FEAT_SPELL_FOCUS_NECROMANCY:
    case FEAT_EPIC_SPELL_FOCUS_NECROMANCY:
    case FEAT_GREATER_SPELL_FOCUS_NECROMANCY:
        return IP_CONST_FEAT_SPELLFOCUSNEC;
    case FEAT_SPELL_PENETRATION:
    case FEAT_EPIC_SPELL_PENETRATION:
    case FEAT_GREATER_SPELL_PENETRATION:
        return IP_CONST_FEAT_SPELLPENETRATION;
    case FEAT_TWO_WEAPON_FIGHTING:
    case FEAT_IMPROVED_TWO_WEAPON_FIGHTING:
        return IP_CONST_FEAT_TWO_WEAPON_FIGHTING;
    case FEAT_WEAPON_FINESSE:
        return IP_CONST_FEAT_WEAPFINESSE;
    case FEAT_WEAPON_PROFICIENCY_EXOTIC:
        return IP_CONST_FEAT_WEAPON_PROF_EXOTIC;
    case FEAT_WEAPON_PROFICIENCY_MARTIAL:
        return IP_CONST_FEAT_WEAPON_PROF_MARTIAL;
    case FEAT_WEAPON_PROFICIENCY_SIMPLE:
        return IP_CONST_FEAT_WEAPON_PROF_SIMPLE;
    case FEAT_IMPROVED_UNARMED_STRIKE:
        return IP_CONST_FEAT_WEAPSPEUNARM;

    // Some undefined ones
    case FEAT_DISARM:
        return 28;
    case FEAT_HIDE_IN_PLAIN_SIGHT:
        return 31;
    case FEAT_MOBILITY:
        return 27;
    case FEAT_RAPID_SHOT:
        return 30;
    case FEAT_SHIELD_PROFICIENCY:
        return 35;
    case FEAT_SNEAK_ATTACK:
        return 32;
    case FEAT_USE_POISON:
        return 36;
    case FEAT_WHIRLWIND_ATTACK:
        return 29;
    case FEAT_WEAPON_PROFICIENCY_CREATURE:
        return 38;
        // whip disarm is 37
    }
    return (-1);
}

// Determines if the target creature has a certain type of spell
// and sets the powers onto the object item
void SetItemSpellPowers(object oItem, object oCreature)
{
    itemproperty iProp;
    int total_props = 0; //max of 8 properties on one item
    int max_props = 7;

    //first, auras--only want to allow one aura power to transfer
    if ( GetHasSpell(SPELLABILITY_AURA_BLINDING, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(750,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_COLD, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(751,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_ELECTRICITY, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(752,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_FEAR, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(753,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_FIRE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(754,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_MENACE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(755,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_PROTECTION, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(756,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_STUN, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(757,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_UNEARTHLY_VISAGE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(758,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_AURA_UNNATURAL, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(759,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //now, bolts
    if ( GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_CHARISMA, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(760,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_CONSTITUTION, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(761,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_DEXTERITY, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(762,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_INTELLIGENCE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(763,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_STRENGTH, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(764,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_WISDOM, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(765,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_ACID, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(766,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_CHARM, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(767,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_COLD, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(768,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_CONFUSE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(769,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_DAZE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(770,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_DEATH, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(771,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_DISEASE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(772,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_DOMINATE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(773,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_FIRE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(774,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_KNOCKDOWN, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(775,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_LEVEL_DRAIN, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(776,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_LIGHTNING, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(777,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_PARALYZE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(778,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_POISON, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(779,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_SHARDS, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(780,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_SLOW, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(781,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_STUN, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(782,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_BOLT_WEB, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(783,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //now, cones
    if ( GetHasSpell(SPELLABILITY_CONE_ACID, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(784,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_CONE_COLD, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(785,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_CONE_DISEASE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(786,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_CONE_FIRE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(787,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_CONE_LIGHTNING, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(788,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_CONE_POISON, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(789,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_CONE_SONIC, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(790,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //various petrify attacks
    if ( GetHasSpell(SPELLABILITY_BREATH_PETRIFY, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(791,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_PETRIFY, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(792,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_TOUCH_PETRIFY, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(793,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //dragon stuff (fear aura, breaths)
    if ( GetHasSpell(SPELLABILITY_DRAGON_FEAR, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(796,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_ACID, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(400,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_COLD, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(401,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_FEAR, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(402,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_FIRE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(403,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_GAS, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(404,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_LIGHTNING, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(405,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(698, oCreature) && (total_props <= max_props) ) //NEGATIVE
    {
        iProp = ItemPropertyCastSpell(794,IP_CONST_CASTSPELL_NUMUSES_5_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_PARALYZE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(406,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_SLEEP, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(407,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_SLOW, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(408,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_DRAGON_BREATH_WEAKEN, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(409,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(771, oCreature) && (total_props <= max_props) ) //PRISMATIC
    {
        iProp = ItemPropertyCastSpell(795,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //gaze attacks
    if ( GetHasSpell(SPELLABILITY_GAZE_CHARM, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(797,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_CONFUSION, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(798,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_DAZE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(799,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_DEATH, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(800,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_DESTROY_CHAOS, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(801,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_DESTROY_EVIL, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(802,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_DESTROY_GOOD, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(803,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_DESTROY_LAW, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(804,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_DOMINATE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(805,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_DOOM, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(806,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_FEAR, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(807,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_PARALYSIS, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(808,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_GAZE_STUNNED, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(809,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //miscellaneous abilities
    if ( GetHasSpell(SPELLABILITY_GOLEM_BREATH_GAS, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(810,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_HELL_HOUND_FIREBREATH, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(811,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_KRENSHAR_SCARE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(812,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //howls
    if ( GetHasSpell(SPELLABILITY_HOWL_CONFUSE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(813,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_HOWL_DAZE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(814,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_HOWL_DEATH, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(815,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_HOWL_DOOM, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(816,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_HOWL_FEAR, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(817,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_HOWL_PARALYSIS, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(818,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_HOWL_SONIC, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(819,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_HOWL_STUN, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(820,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //pulses
    if ( GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_CHARISMA, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(821,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_CONSTITUTION, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(822,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_DEXTERITY, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(823,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_INTELLIGENCE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(824,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_STRENGTH, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(825,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_WISDOM, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(826,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_COLD, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(827,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_DEATH, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(828,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_DISEASE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(829,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_DROWN, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(830,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_FIRE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(831,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_HOLY, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(832,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_LEVEL_DRAIN, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(833,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_LIGHTNING, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(834,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_NEGATIVE, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(835,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_POISON, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(836,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_SPORES, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(837,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_PULSE_WHIRLWIND, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(838,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //monster summon abilities
    if ( GetHasSpell(SPELLABILITY_SUMMON_SLAAD, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(839,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(SPELLABILITY_SUMMON_TANARRI, oCreature) && (total_props <= max_props) )
    {
        iProp = ItemPropertyCastSpell(840,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //abilities without const refs
    if ( GetHasSpell(552, oCreature) && (total_props <= max_props) ) //PSIONIC CHARM
    {
        iProp = ItemPropertyCastSpell(841,IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(551, oCreature) && (total_props <= max_props) ) //PSIONIC MINDBLAST
    {
        iProp = ItemPropertyCastSpell(842,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(713, oCreature) && (total_props <= max_props) ) //MINDBLAST 10M
    {
        iProp = ItemPropertyCastSpell(843,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(741, oCreature) && (total_props <= max_props) ) //PSIONIC BARRIER
    {
        iProp = ItemPropertyCastSpell(844,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(763, oCreature) && (total_props <= max_props) ) //PSIONIC CONCUSSION
    {
        iProp = ItemPropertyCastSpell(845,IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(731, oCreature) && (total_props <= max_props) ) //BEBILITH WEB
    {
        iProp = ItemPropertyCastSpell(846,IP_CONST_CASTSPELL_NUMUSES_5_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(736, oCreature) && (total_props <= max_props) ) //BEHOLDER EYES
    {
        iProp = ItemPropertyCastSpell(847,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(770, oCreature) && (total_props <= max_props) ) //CHAOS SPITTLE
    {
        iProp = ItemPropertyCastSpell(848,IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(757, oCreature) && (total_props <= max_props) ) //SHADOWBLEND
    {
        iProp = ItemPropertyCastSpell(849,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ( GetHasSpell(774, oCreature) && (total_props <= max_props) ) //DEFLECTING FORCE
    {
        iProp = ItemPropertyCastSpell(850,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    //some spell-like abilities
    if (((GetHasSpell(SPELL_DARKNESS,oCreature)) ||
        (GetHasSpell(SPELLABILITY_AS_DARKNESS,oCreature))) &&
        (total_props <= max_props))
    {
        iProp = ItemPropertyCastSpell(IP_CONST_CASTSPELL_DARKNESS_3,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ((GetHasSpell(SPELL_DISPLACEMENT,oCreature)) && (total_props <= max_props))
    {
        iProp = ItemPropertyCastSpell(IP_CONST_CASTSPELL_DISPLACEMENT_9,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if (((GetHasSpell(SPELLABILITY_AS_INVISIBILITY,oCreature)) ||
        (GetHasSpell(SPELL_INVISIBILITY,oCreature))) &&
        (total_props <= max_props))
    {
        iProp = ItemPropertyCastSpell(IP_CONST_CASTSPELL_INVISIBILITY_3,IP_CONST_CASTSPELL_NUMUSES_5_USES_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
    if ((GetHasSpell(SPELL_WEB,oCreature)) && (total_props <= max_props))
    {
        iProp = ItemPropertyCastSpell(IP_CONST_CASTSPELL_WEB_3,IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY);
        AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oItem);
        total_props++;
    }
}


// Determines the level of the shifter class needed to take on
// oTargets shape.
// Returns 1nMaxPen for Shifter level
// 1000 means they can never take the shape
int GetShifterLevelRequired(object oTarget)
{
    int nTRacialType            = MyPRCGetRacialType(oTarget);
    int nLevelRequired          = 0;

    if ((nTRacialType == RACIAL_TYPE_FEY) || (nTRacialType == RACIAL_TYPE_SHAPECHANGER))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }

    if (GetHasFeat(SHIFTER_BLACK_LIST,oTarget))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }

    int nTSize                  = GetCreatureSize(oTarget);

    int iAllowHuge              = GetLocalInt(GetModule(),"PNP_SHFT_S_HUGE");
    int iAllowLarge             = GetLocalInt(GetModule(),"PNP_SHFT_S_LARGE");
    int iAllowMedium            = GetLocalInt(GetModule(),"PNP_SHFT_S_MEDIUM");
    int iAllowSmall             = GetLocalInt(GetModule(),"PNP_SHFT_S_SMALL");
    int iAllowTiny              = GetLocalInt(GetModule(),"PNP_SHFT_S_TINY");
    int iAllowOutsider          = GetLocalInt(GetModule(),"PNP_SHFT_F_OUTSIDER");
    int iAllowElemental         = GetLocalInt(GetModule(),"PNP_SHFT_F_ELEMENTAL");
    int iAllowConstruct         = GetLocalInt(GetModule(),"PNP_SHFT_F_CONSTRUCT");
    int iAllowUndead            = GetLocalInt(GetModule(),"PNP_SHFT_F_UNDEAD");
    int iAllowDragon            = GetLocalInt(GetModule(),"PNP_SHFT_F_DRAGON");
    int iAllowAberration        = GetLocalInt(GetModule(),"PNP_SHFT_F_ABERRATION");
    int iAllowOoze              = GetLocalInt(GetModule(),"PNP_SHFT_F_OOZE");
    int iAllowMagicalBeast      = GetLocalInt(GetModule(),"PNP_SHFT_F_MAGICALBEAST");
    int iAllowGiant             = GetLocalInt(GetModule(),"PNP_SHFT_F_GIANT");
    int iAllowVermin            = GetLocalInt(GetModule(),"PNP_SHFT_F_VERMIN");
    int iAllowBeast             = GetLocalInt(GetModule(),"PNP_SHFT_F_BEAST");
    int iAllowAnimal            = GetLocalInt(GetModule(),"PNP_SHFT_F_ANIMAL");
    int iAllowMonstrousHumanoid = GetLocalInt(GetModule(),"PNP_SHFT_F_MONSTROUSHUMANOID");
    int iAllowHumanoid          = GetLocalInt(GetModule(),"PNP_SHFT_F_HUMANOID");

    // Size validation
    if ((nTSize == CREATURE_SIZE_HUGE) && (iAllowHuge == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTSize == CREATURE_SIZE_LARGE) && (iAllowLarge == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTSize == CREATURE_SIZE_MEDIUM) && (iAllowMedium == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTSize == CREATURE_SIZE_SMALL) && (iAllowSmall == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTSize == CREATURE_SIZE_TINY) && (iAllowTiny == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }

    // Type validation
    if ((nTRacialType == RACIAL_TYPE_OUTSIDER) && (iAllowOutsider == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_ELEMENTAL) && (iAllowElemental == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_CONSTRUCT) && (iAllowConstruct == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_UNDEAD) && (iAllowUndead == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_DRAGON) && (iAllowDragon == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_ABERRATION) && (iAllowAberration == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_OOZE) && (iAllowOoze == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_MAGICAL_BEAST) && (iAllowMagicalBeast == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_GIANT) && (iAllowGiant == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_VERMIN) && (iAllowVermin == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_BEAST) && (iAllowBeast == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_ANIMAL) && (iAllowAnimal == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((nTRacialType == RACIAL_TYPE_HUMANOID_MONSTROUS) && (iAllowMonstrousHumanoid == 1))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }
    if ((iAllowHumanoid == 1) && (
            (nTRacialType == RACIAL_TYPE_DWARF) ||
            (nTRacialType == RACIAL_TYPE_ELF) ||
            (nTRacialType == RACIAL_TYPE_GNOME) ||
            (nTRacialType == RACIAL_TYPE_HUMAN) ||
            (nTRacialType == RACIAL_TYPE_HALFORC) ||
            (nTRacialType == RACIAL_TYPE_HALFELF) ||
            (nTRacialType == RACIAL_TYPE_HALFLING) ||
            (nTRacialType == RACIAL_TYPE_HUMANOID_ORC) ||
            (nTRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN)))
    {
        nLevelRequired = 1000;
        return nLevelRequired;
    }

    // Size validation
    if ((nTSize == CREATURE_SIZE_HUGE) && (nLevelRequired < 7))
        nLevelRequired = 7;
    if ((nTSize == CREATURE_SIZE_LARGE) && (nLevelRequired < 3))
        nLevelRequired = 3;
    if ((nTSize == CREATURE_SIZE_MEDIUM) && (nLevelRequired < 1))
        nLevelRequired = 1;
    if ((nTSize == CREATURE_SIZE_SMALL) && (nLevelRequired < 1))
        nLevelRequired = 1;
    if ((nTSize == CREATURE_SIZE_TINY) && (nLevelRequired < 3))
        nLevelRequired = 3;

    // Type validation
    if ((nTRacialType == RACIAL_TYPE_OUTSIDER) && (nLevelRequired < 9))
        nLevelRequired = 9;
    if ((nTRacialType == RACIAL_TYPE_ELEMENTAL) && (nLevelRequired < 9))
        nLevelRequired = 9;
    if ((nTRacialType == RACIAL_TYPE_CONSTRUCT) && (nLevelRequired < 8))
        nLevelRequired = 8;
    if ((nTRacialType == RACIAL_TYPE_UNDEAD) && (nLevelRequired < 8))
        nLevelRequired = 8;
    if ((nTRacialType == RACIAL_TYPE_DRAGON) && (nLevelRequired < 7))
        nLevelRequired = 7;
    if ((nTRacialType == RACIAL_TYPE_ABERRATION) && (nLevelRequired < 6))
        nLevelRequired = 6;
    if ((nTRacialType == RACIAL_TYPE_OOZE) && (nLevelRequired < 6))
        nLevelRequired = 6;
    if ((nTRacialType == RACIAL_TYPE_MAGICAL_BEAST) && (nLevelRequired < 5))
        nLevelRequired = 5;
    if ((nTRacialType == RACIAL_TYPE_GIANT) && (nLevelRequired < 4))
        nLevelRequired = 4;
    if ((nTRacialType == RACIAL_TYPE_VERMIN) && (nLevelRequired < 4))
        nLevelRequired = 4;
    if ((nTRacialType == RACIAL_TYPE_BEAST) && (nLevelRequired < 3))
        nLevelRequired = 3;
    if ((nTRacialType == RACIAL_TYPE_ANIMAL) && (nLevelRequired < 2))
        nLevelRequired = 2;
    if ((nTRacialType == RACIAL_TYPE_HUMANOID_MONSTROUS) && (nLevelRequired < 2))
        nLevelRequired = 2;
    if ((nLevelRequired < 1) && (
            (nTRacialType == RACIAL_TYPE_DWARF) ||
            (nTRacialType == RACIAL_TYPE_ELF) ||
            (nTRacialType == RACIAL_TYPE_GNOME) ||
            (nTRacialType == RACIAL_TYPE_HUMAN) ||
            (nTRacialType == RACIAL_TYPE_HALFORC) ||
            (nTRacialType == RACIAL_TYPE_HALFELF) ||
            (nTRacialType == RACIAL_TYPE_HALFLING) ||
            (nTRacialType == RACIAL_TYPE_HUMANOID_ORC) ||
            (nTRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN)))
        nLevelRequired = 1;

    return nLevelRequired;
}

// Can the shifter (oPC) assume the form of the target
// return Values: TRUE or FALSE
int GetValidShift(object oPC, object oTarget)
{
    int iInvalid = 0;

    // Valid Monster?
    if (!GetIsObjectValid(oTarget))
        return FALSE;
    // Valid PC
    if (!GetIsObjectValid(oPC))
        return FALSE;

    // Cant mimic a PC
    if (GetIsPC(oTarget))
        return FALSE;

    int iUseCR = GetLocalInt(GetModule(),"PNP_SHFT_USECR");
    int nTHD;
    // Target Information
    if (iUseCR == 1)
    {
        nTHD = FloatToInt(GetChallengeRating(oTarget));
    }
    else
    {
        nTHD = GetHitDice(oTarget);
    }

    // PC Info
    int nPCHD = GetHitDice(oPC);
    int nPCShifterLevel = GetLevelByClass(CLASS_TYPE_PNP_SHIFTER,oPC);

    // Check the shifter level required
    int nPCShifterLevelsRequired = GetShifterLevelRequired(oTarget);
    if (nPCShifterLevel < nPCShifterLevelsRequired)
    {
        if (nPCShifterLevelsRequired == 1000)
        {
            SendMessageToPC(oPC,"You can never take on that form." );
            return FALSE;
        }
        else
            SendMessageToPC(oPC,"You need " + IntToString(nPCShifterLevelsRequired-nPCShifterLevel) + " more shifter levels before you can take on that form." );
        iInvalid = 1;
    }

    // HD check (cant take any form that has more HD then the shifter)
    if (nTHD > nPCHD)
    {
        SendMessageToPC(oPC,"You need " + IntToString(nTHD-nPCHD) + " more character levels before you can take on that form." );
        iInvalid = 1;
    }

    //if checks failed return false
    if (iInvalid == 1)
    {
        //this way both of the texts come up if they are needed
        //so you dont just get 1 if your need both
        return FALSE;
    }
    //else if all checks past return true
    return TRUE;

}

// Determine if the oCreature has the ability to cast spells
// Return values: TRUE or FALSE
int GetCanFormCast(object oCreature)
{
    int nTRacialType = MyPRCGetRacialType(oCreature);

    // Need to have hands, and the ability to speak

    switch (nTRacialType)
    {
    case RACIAL_TYPE_ABERRATION:
    case RACIAL_TYPE_MAGICAL_BEAST:
    case RACIAL_TYPE_VERMIN:
    case RACIAL_TYPE_BEAST:
    case RACIAL_TYPE_ANIMAL:
    case RACIAL_TYPE_OOZE:
	//case RACIAL_TYPE_PLANT:  
  // These forms can't cast spells
        return FALSE;
        break;
		
    case RACIAL_TYPE_SHAPECHANGER:
    case RACIAL_TYPE_ELEMENTAL:
    case RACIAL_TYPE_DRAGON:
    case RACIAL_TYPE_OUTSIDER:
    case RACIAL_TYPE_UNDEAD:
    case RACIAL_TYPE_CONSTRUCT:
    case RACIAL_TYPE_GIANT:
    case RACIAL_TYPE_HUMANOID_MONSTROUS:
    case RACIAL_TYPE_DWARF:
    case RACIAL_TYPE_ELF:
    case RACIAL_TYPE_GNOME:
    case RACIAL_TYPE_HALFELF:
    case RACIAL_TYPE_HALFLING:
    case RACIAL_TYPE_HALFORC:
    case RACIAL_TYPE_HUMAN:
    case RACIAL_TYPE_HUMANOID_ORC:
    case RACIAL_TYPE_HUMANOID_GOBLINOID:
    case RACIAL_TYPE_HUMANOID_REPTILIAN:
    case RACIAL_TYPE_FEY:
        break;
    }

    return TRUE;
}

// Determines if the oCreature is harmless enough to have
// special effects applied to the shifter
// Return values: TRUE or FALSE
int GetIsCreatureHarmless(object oCreature)
{
    string sCreatureName = GetName(oCreature);

    // looking for small < 1 CR creatures that nobody looks at twice

    if ((sCreatureName == "Chicken") ||
        (sCreatureName == "Falcon") ||
        (sCreatureName == "Hawk") ||
        (sCreatureName == "Raven") ||
        (sCreatureName == "Bat") ||
        (sCreatureName == "Dire Rat") ||
        (sCreatureName == "Will-O'-Wisp") ||
        (sCreatureName == "Rat") ||
        (GetChallengeRating(oCreature) < 1.0 ))
        return TRUE;
    else
        return FALSE;
}

int GetTrueForm(object oPC)
{
    int nRace = GetRacialType(OBJECT_SELF);
    int nPCForm;
    int iIsStored = GetPersistantLocalInt( oPC, "AppearanceIsStored" );
    int iStoredAppearance = GetPersistantLocalInt( oPC, "AppearanceStored" );

    if (iIsStored == 6)
    {
        nPCForm = iStoredAppearance;
    }
    else
    {
        nPCForm = StringToInt(Get2DACache("racialtypes", "Appearance", GetRacialType(oPC)));
    }

    return nPCForm;
}


// Transforms the oPC into the oTarget using the epic rules
// Assumes oTarget is already a valid target
int SetShiftEpic(object oPC, object oTarget)
{

    SetLocalInt(oPC,"EpicShift",1); //this makes the setshift_2 script do the epic shifter stuff that used to be here

    SetShift(oPC, oTarget);

    return TRUE;
}


// Creates a temporary creature for the shifter to shift into
// Validates the shifter is able to become that creature based on level
// Return values: TRUE or FALSE
// the epic version of this script was rolled into this 1 with the
// addition of the iEpic peramiter
int SetShiftFromTemplateValidate(object oPC, string sTemplate, int iEpic)
{
    if (!CanShift(oPC))
    {
        return FALSE;
    }
    int bRetValue = FALSE;
    int in_list = IsKnownCreature(oPC, sTemplate);

    if (iEpic==TRUE)
    {
        if (!GetHasFeat(FEAT_PRESTIGE_SHIFTER_EGWSHAPE_1, oPC))
            return FALSE;
        else
            DecrementRemainingFeatUses(oPC,FEAT_PRESTIGE_SHIFTER_EGWSHAPE_1); //we are good to go with the shift
    }
    else
    {
        if (!GetHasFeat(FEAT_PRESTIGE_SHIFTER_GWSHAPE_1, oPC))
            return FALSE;
        else
            DecrementRemainingFeatUses(oPC,FEAT_PRESTIGE_SHIFTER_GWSHAPE_1); //we are good to go with the shift
    }
    if (!GetHasFeat(FEAT_PRESTIGE_SHIFTER_GWSHAPE_1, oPC))  //if your out of GWS
    {
        if (GetHasFeat(FEAT_WILD_SHAPE, oPC)) //and you have DWS left
        {
            if(GetLocalInt(oPC, "DWS") == 1) //and you wont to change then over to GWS
            {
                IncrementRemainingFeatUses(oPC,FEAT_PRESTIGE_SHIFTER_GWSHAPE_1); // +1 GWS
                DecrementRemainingFeatUses(oPC,FEAT_WILD_SHAPE); //-1 DWS
            }
        }
    }
    int i=0;
    object oLimbo=GetObjectByTag("Limbo",i);
    location lLimbo;
    while (i < 100)
    {
        if (GetIsObjectValid(oLimbo))
        {
            if (GetName(oLimbo)=="Limbo")
            {
                i = 2000;
                vector vLimbo = Vector(0.0f, 0.0f, 0.0f);
                lLimbo = Location(oLimbo, vLimbo, 0.0f);
            }
        }
        i++;
        object oLimbo=GetObjectByTag("Limbo",i);
    }
    object oTarget;
    if (i>=2000)
    {
        oTarget = CreateObject(OBJECT_TYPE_CREATURE,sTemplate,lLimbo);
    }
    else
    {
        oTarget = CreateObject(OBJECT_TYPE_CREATURE,sTemplate,GetLocation(oPC));
    }

    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oPC, "Not a valid creature.");
    }
    if ( !in_list )
    {
        SendMessageToPC( oPC, "You have not mimiced this creature yet." );
    }

    // Make sure the PC can take on that form
    if (GetValidShift(oPC, oTarget) && in_list )
    {
        //get the appearance before changing it
        SetLocalInt(oTarget,"Appearance",GetAppearanceType(oTarget));
        //set appearance to invis so it dont show up when scripts run thro
        SetCreatureAppearanceType(oTarget,APPEARANCE_TYPE_INVISIBLE_HUMAN_MALE);
        //set oTarget for deletion
        SetLocalInt(oTarget,"pnp_shifter_deleteme",1);
        //Shift the PC to it
        bRetValue = TRUE;
        if (iEpic == TRUE)
            SetShiftEpic(oPC, oTarget);
        else
            SetShift(oPC, oTarget);
    }
    else //if we're not gona shift we need to get ride of the creature
    {
        // Remove the temporary creature
        AssignCommand(oTarget,SetIsDestroyable(TRUE,FALSE,FALSE));
        SetPlotFlag(oTarget,FALSE);
        SetImmortal(oTarget,FALSE);
        DestroyObject(oTarget);
    }
    return bRetValue;
}

// helper function to SetVisualTrueForm() for DelayCommand() to work on
void SetBodyPartTrueForm(object oPC, int i)
{
    int nBodyPartValue = GetPersistantLocalInt(oPC,    "AppearanceStoredPart"+IntToString(i));
    if(GetCreatureBodyPart(i) != nBodyPartValue) // if the stored and current values are different
        SetCreatureBodyPart(i, nBodyPartValue, oPC);
}

//returns the PC to their original form
//purely visual
void SetVisualTrueForm(object oPC)
{
    if(GetPersistantLocalInt(oPC,"AppearanceIsStored") == 6)
    {
        SetCreatureAppearanceType(oPC, GetPersistantLocalInt(oPC,"AppearanceStored"));
        SetPortraitId(oPC, GetPersistantLocalInt(oPC,            "AppearanceStoredPortraitID"));
        SetPortraitResRef(oPC, GetPersistantLocalString(oPC,     "AppearanceStoredPortraitResRef"));
        SetCreatureTailType(GetPersistantLocalInt(oPC,           "AppearanceStoredTail"), oPC);
        SetCreatureWingType(GetPersistantLocalInt(oPC,           "AppearanceStoredWing"), oPC);
        int i;
        for(i=0;i<=20;i++)
        {
            DelayCommand(1.0, SetBodyPartTrueForm(oPC, i));
        }
    }
    else
        //hasnt been previously stored
        //use racial lookup
        SetCreatureAppearanceType(oPC, GetTrueForm(oPC));
}


// Transforms the oPC back to thier true form if they are shifted
void SetShiftTrueForm(object oPC)
{
    // Remove all the creature equipment and destroy it
    object oHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);
    object oWeapCR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);
    object oWeapCL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
    object oWeapCB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);

    // Do not move or destroy the objects, it will crash the game
    if (GetIsObjectValid(oHide))
    {
        // Remove all the abilities of the object
        ScrubPCSkin(oPC,oHide);
        DeletePRCLocalInts(oHide);
        AssignCommand(oPC, ActionEquipItem(oHide, INVENTORY_SLOT_CARMOUR)); //reequip the hide to get item props to update properly
    }

    itemproperty ipUnarmed = ItemPropertyMonsterDamage(2);

    if (GetIsObjectValid(oWeapCR))
    {
        //remove creature weapons
        ClearCreatureItem(oPC, oWeapCR);
        //AssignCommand(oPC,ActionUnequipItem(oWeapCR));
    }
    if (GetIsObjectValid(oWeapCL))
    {
        //remove creature weapons
        ClearCreatureItem(oPC, oWeapCL);
        //AssignCommand(oPC,ActionUnequipItem(oWeapCL));

    }
    if (GetIsObjectValid(oWeapCB))
    {
        //remove creature weapons
        ClearCreatureItem(oPC, oWeapCB);
        //AssignCommand(oPC,ActionUnequipItem(oWeapCB));
    }
    // if the did an epic form remove the special powers
    object oEpicPowersItem = GetItemPossessedBy(oPC,"EpicShifterPowers");
    if (GetIsObjectValid(oEpicPowersItem))
    {
        ClearCreatureItem(oPC, oEpicPowersItem);
        //RemoveAllItemProperties(oEpicPowersItem);
        RemoveAuraEffect( oPC );
    }


    // Spell failure was done through an effect
    // AC was done via an effect
    // invis was done via an effect
    // we will look for and remove them
    effect eEff = GetFirstEffect(oPC);
    while (GetIsEffectValid(eEff))
    {
        int eDurType = GetEffectDurationType(eEff);
        int eSubType = GetEffectSubType(eEff);
        int eType = GetEffectType(eEff);
        int eID = GetEffectSpellId(eEff);
        object eCreator = GetEffectCreator(eEff);
        //all three effects are permanent and supernatural and are created by spell id -1 and by the PC.
        if ((eDurType == DURATION_TYPE_PERMANENT) && (eSubType == SUBTYPE_SUPERNATURAL) && (eID == -1) && (eCreator == oPC))
        {
            switch (eType)
            {
                case EFFECT_TYPE_SPELL_FAILURE:
                case EFFECT_TYPE_INVISIBILITY:
                case EFFECT_TYPE_AC_INCREASE:
                case EFFECT_TYPE_AC_DECREASE:
                case EFFECT_TYPE_ATTACK_INCREASE:
                case EFFECT_TYPE_ATTACK_DECREASE:
                case EFFECT_TYPE_DAMAGE_INCREASE:
                case EFFECT_TYPE_DAMAGE_DECREASE:
                case EFFECT_TYPE_TEMPORARY_HITPOINTS:
                    RemoveEffect(oPC,eEff);
                    break;
            }
        }
        if (eType == EFFECT_TYPE_POLYMORPH)
        {
            RemoveEffect(oPC,eEff);
        }
        eEff = GetNextEffect(oPC);
    }

    // Change the PC appearance back to TRUE form
    SetVisualTrueForm(oPC);

    // Set race back to unused
    SetLocalInt(oPC, "RACIAL_TYPE", 0);

    // Reset shifted state
    SetPersistantLocalInt(oPC, "nPCShifted", FALSE);

}


void ClearCreatureItem(object oPC, object oTarget)
{
    AssignCommand(oPC, ActionUnequipItem(oTarget));
    DelayCommand(0.10, AssignCommand(oPC, DestroyObject(oTarget)));
}