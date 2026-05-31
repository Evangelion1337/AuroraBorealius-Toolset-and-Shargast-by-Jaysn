/*

    This include governs all the new itemproperties
    Both restrictions and features

*/
//:: Updated for .35 by Jaysyn 2023/03/10

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const string PLAYER_SPEED_INCREASE = "player_speed_increase";
const string PLAYER_SPEED_DECREASE = "player_speed_decrease";


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

int DoUMDCheck(object oItem, object oPC, int nDCMod);

int CheckPRCLimitations(object oItem, object oPC = OBJECT_INVALID);

/**
 * Non-returning wrapper for CheckPRCLimitations.
 */
void VoidCheckPRCLimitations(object oItem, object oPC = OBJECT_INVALID);

void CheckForPnPHolyAvenger(object oItem);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_utility"
#include "prc_inc_newip"
#include "prc_inc_castlvl"
#include "inc_newspellbook"


//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/*void _prc_inc_itmrstr_ApplySpeedModification(object oPC, int nEffectType, int nSpeedMod)
{
    if(DEBUG) DoDebug("_prc_inc_itmrstr_ApplySpeedModification(" + DebugObject2Str(oPC) + ", " + IntToString(nEffectType) + ", " + IntToString(nSpeedMod) + ")");
    // The skin object should be OBJECT_SELF here
    // Clean up existing speed modification
    effect eTest = GetFirstEffect(oPC);
    while(GetIsEffectValid(eTest))
    {
        if(GetEffectCreator(eTest) == OBJECT_SELF         &&
           GetEffectType(eTest)    == nEffectType         &&
           GetEffectSubType(eTest) == SUBTYPE_SUPERNATURAL
           )
            RemoveEffect(oPC, eTest);
        eTest = GetNextEffect(oPC);
    }

    // Apply speed mod if there is any
    if(nSpeedMod > 0)
    {
        effect eSpeedMod = SupernaturalEffect(nEffectType == EFFECT_TYPE_MOVEMENT_SPEED_INCREASE ?
                                               EffectMovementSpeedIncrease(nSpeedMod) :
                                               EffectMovementSpeedDecrease(nSpeedMod)
                                              );
        /// @todo Determine if the delay is actually needed here
        DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSpeedMod, oPC));
    }
}

void _prc_inc_itmrstr_ApplySpeedIncrease(object oPC)
{
    // Get target speed modification value. Limit to 99, since that's the effect constructor maximum value
    int nSpeedMod = PRCMin(99, GetLocalInt(oPC, PLAYER_SPEED_INCREASE));
    object oSkin = GetPCSkin(oPC);

    AssignCommand(oSkin, _prc_inc_itmrstr_ApplySpeedModification(oPC, EFFECT_TYPE_MOVEMENT_SPEED_INCREASE, nSpeedMod));
}


void _prc_inc_itmrstr_ApplySpeedDecrease(object oPC)
{
    // Get target speed modification value. Limit to 99, since that's the effect constructor maximum value
    int nSpeedMod = GetLocalInt(oPC, PLAYER_SPEED_DECREASE);
    object oSkin = GetPCSkin(oPC);

    AssignCommand(oSkin, _prc_inc_itmrstr_ApplySpeedModification(oPC, EFFECT_TYPE_MOVEMENT_SPEED_DECREASE, nSpeedMod));
}*/

void _prc_inc_itmrstr_ApplyAoE(object oPC, object oItem, int nSubType, int nCost)
{
    int nAoEID    = StringToInt(Get2DACache("iprp_aoe", "AoEID", nSubType));
    string sTag   = Get2DACache("vfx_persistent", "LABEL", nAoEID);
    effect eAoE   = EffectAreaOfEffect(nAoEID,
                    Get2DACache("iprp_aoe", "EnterScript", nSubType),
                    Get2DACache("iprp_aoe", "HBScript",    nSubType),
                    Get2DACache("iprp_aoe", "ExitScript",  nSubType));

    // The item applies the AoE effect
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eAoE, oPC);

    // Get an object reference to the newly created AoE
    location lLoc = GetLocation(oPC);
    object oAoE = GetFirstObjectInShape(SHAPE_SPHERE, 1.0f, lLoc, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    while(GetIsObjectValid(oAoE))
    {
        // Test if we found the correct AoE
        if(GetTag(oAoE) == sTag &&
           !GetLocalInt(oAoE, "PRC_AoE_IPRP_Init")
           )
        {
            SetLocalInt(oAoE, "PRC_AoE_IPRP_Init", TRUE);
            break;
        }
        // Didn't find, get next
        oAoE = GetNextObjectInShape(SHAPE_SPHERE, 1.0f, lLoc, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    }
    if(!GetIsObjectValid(oAoE)) DoDebug("ERROR: _prc_inc_itmrstr_ApplyAoE: Can't find AoE created by " + DebugObject2Str(oItem));

    // Set caster level override on the AoE
    SetLocalInt(oAoE, PRC_CASTERLEVEL_OVERRIDE, nCost);
    //if(DEBUG) DoDebug("_prc_inc_itmrstr_ApplyAoE: AoE level: " + IntToString(nCost));
}

void _prc_inc_itmrstr_ApplyWizardry(object oPC, object oItem, int nSpellLevel, string sType)
{
    //properties were already applied - happens when loading a saved game
    if(GetLocalInt(oItem, "PRC_Wizardry"+IntToString(nSpellLevel)))
        return;

    SetLocalInt(oItem, "PRC_Wizardry"+IntToString(nSpellLevel), TRUE);
    int nClass, nSlots, i;
    for(i = 1; i <= 8; i++)
    {
        nClass = GetClassByPosition(i, oPC);
        if((sType == "A" && GetIsArcaneClass(nClass)) || (sType == "D" && GetIsDivineClass(nClass)))
        {
            if(GetAbilityScoreForClass(nClass, oPC) < nSpellLevel + 10)
                continue;

            int nSpellSlotLevel = GetSpellslotLevel(nClass, oPC) - 1;
            string sFile = Get2DACache("classes", "SpellGainTable", nClass);
            nSlots = StringToInt(Get2DACache(sFile, "SpellLevel" + IntToString(nSpellLevel), nSpellSlotLevel));
            //if(DEBUG) DoDebug("Adding "+IntToString(nSlots)" bonus slots for "+IntToString(nClass)" class.");

            if(nSlots)
            {
                string sVar = "PRC_IPRPBonSpellSlots_" + IntToString(nClass) + "_" + IntToString(nSpellLevel);
                int j = 0;
                while(j < nSlots)
                {
                    //DoDebug(IntToString(j));
                    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusLevelSpell(nClass, nSpellLevel), oItem);
                    //nsb compatibility
                    SetLocalInt(oPC, sVar, (GetLocalInt(oPC, sVar) + 1));
                    j++;
                }
            }
        }
    }
    SetPlotFlag(oItem, TRUE);
}

void _prc_inc_itmrstr_RemoveWizardry(object oPC, object oItem, int nSpellLevel, string sType)
{
    DeleteLocalInt(oItem, "PRC_Wizardry"+IntToString(nSpellLevel));
    SetPlotFlag(oItem, FALSE);
    itemproperty ipTest = GetFirstItemProperty(oItem);
    string sVar;
    while(GetIsItemPropertyValid(ipTest))
    {
        if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N)
        {
            if(GetItemPropertyCostTableValue(ipTest) == nSpellLevel)
            {
                int nClass = GetItemPropertySubType(ipTest);
                if((sType == "A" && GetIsArcaneClass(nClass)) || (sType == "D" && GetIsDivineClass(nClass)))
                {
                    RemoveItemProperty(oItem, ipTest);
                    //remove bonus slots from nsb classes
                    sVar = "PRC_IPRPBonSpellSlots_" + IntToString(nClass) + "_" + IntToString(nSpellLevel);
                    SetLocalInt(oPC, sVar, (GetLocalInt(oPC, sVar) - 1));
                    int nCount, nSpellbook = GetSpellbookTypeForClass(nClass);
                    string sArray = "NewSpellbookMem_"+IntToString(nClass);
                    if(nSpellbook == SPELLBOOK_TYPE_SPONTANEOUS)
                    {
                        nCount = persistant_array_get_int(oPC, sArray, nSpellLevel);
                        if(nCount)
                        {
                            nCount--;
                            persistant_array_set_int(oPC, sArray, nSpellLevel, nCount);
                        }
                    }
                    else if(nSpellbook == SPELLBOOK_TYPE_PREPARED)
                    {
                        string sIDX = "SpellbookIDX" + IntToString(nSpellLevel) + "_" + IntToString(nClass);
                        int i, nSpellbookID, nMax = persistant_array_get_size(oPC, sIDX) - 1;
                        for(i = nMax; i >= 0; i--)
                        {
                            nSpellbookID = persistant_array_get_int(oPC, sIDX, i);
                            nCount = persistant_array_get_int(oPC, sArray, nSpellbookID);
                            if(nCount)
                            {
                                nCount--;
                                persistant_array_set_int(oPC, sArray, nSpellbookID, nCount);
                                break;
                            }
                        }
                    }
                }
            }
        }
        ipTest = GetNextItemProperty(oItem);
    }
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int GetUMDForItemCost(object oItem)
{
    string s2DAEntry;
    int nValue = GetGoldPieceValue(oItem);
    int n2DAValue = StringToInt(s2DAEntry);
    int i;
    while(n2DAValue < nValue)
    {
        s2DAEntry = Get2DACache("skillvsitemcost", "DeviceCostMax", i);
        n2DAValue = StringToInt(s2DAEntry);
        i++;
    }
    i--;
    string s2DAReqSkill = Get2DACache("skillvsitemcost", "SkillReq_Class", i);
    if(s2DAReqSkill == "")
        return -1;
    return StringToInt(s2DAReqSkill);
}

//this is a scripted version of the bioware UMD check for using restricted items
//this also applies effects relating to new itemproperties
int DoUMDCheck(object oItem, object oPC, int nDCMod)
{

    //doesnt have UMD
    if(!GetHasSkill(SKILL_USE_MAGIC_DEVICE, oPC))
        return FALSE;

    int nSkill = GetSkillRank(SKILL_USE_MAGIC_DEVICE, oPC);
    int nReqSkill = GetUMDForItemCost(oItem);
    //class is a dc20 test
    nReqSkill = nReqSkill - 20 + nDCMod;
    if(nReqSkill > nSkill)
        return FALSE;
    else
        return TRUE;
}

void VoidCheckPRCLimitations(object oItem, object oPC = OBJECT_INVALID)
{
    CheckPRCLimitations(oItem, oPC);
}

//tests for use restrictions
//also appies effects for those IPs tat need them
/// @todo Rename. It's not just limitations anymore
int CheckPRCLimitations(object oItem, object oPC = OBJECT_INVALID)
{
    // Sanity check - the item needs to be valid
    if(!GetIsObjectValid(oItem))
        return FALSE; /// @todo Might be better to auto-pass the limitation aspect in case of invalid item

    // In case no item owner was given, find it out
    if(!GetIsObjectValid(oPC))
        oPC = GetItemPossessor(oItem);

    // Sanity check - the item needs to be in some creature's possession for this function to make sense
    if(!GetIsObjectValid(oPC))
        return FALSE;

    // Equip and Unequip events need some special handling
    int bUnequip = GetItemLastUnequipped() == oItem && GetLocalInt(oPC, "ONEQUIP") == 1;
    int bEquip   = GetItemLastEquipped()   == oItem && GetLocalInt(oPC, "ONEQUIP") == 2;

    // Use restriction and UMD use
    int bPass  = TRUE;
    int nUMDDC = 0;

    // Speed modification. Used to determine if effects need to be applied
    int nSpeedIncrease = GetLocalInt(oPC, PLAYER_SPEED_INCREASE);
    int nSpeedDecrease = GetLocalInt(oPC, PLAYER_SPEED_DECREASE);

    // Loop over all itemproperties on the item
    itemproperty ipTest = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipTest))
    {
        int ipType = GetItemPropertyType(ipTest);
        /* Use restrictions. All of these can be skipped when unequipping */
        if(!bUnequip)
        {
            if     (ipType == ITEM_PROPERTY_USE_LIMITATION_ABILITY_SCORE)
            {
                int nValue = GetItemPropertyCostTableValue(ipTest);
                if(GetAbilityScore(oPC, GetItemPropertySubType(ipTest), TRUE) < nValue)
                    bPass = FALSE;
                nUMDDC += nValue - 15;
            }
            else if(ipType == ITEM_PROPERTY_USE_LIMITATION_SKILL_RANKS)
            {
                int nValue = GetItemPropertyCostTableValue(ipTest);
                if(GetSkillRank(GetItemPropertySubType(ipTest), oPC) < nValue)
                    bPass = FALSE;
                nUMDDC += nValue - 10;
            }
            else if(ipType == ITEM_PROPERTY_USE_LIMITATION_SPELL_LEVEL)
            {
                int nLevel = GetItemPropertyCostTableValue(ipTest);
                if(GetLocalInt(oPC, "PRC_AllSpell" + IntToString(nLevel)))
                    bPass = FALSE;
                nUMDDC += (nLevel * 2) - 20;
            }
            else if(ipType == ITEM_PROPERTY_USE_LIMITATION_ARCANE_SPELL_LEVEL)
            {
                int nLevel = GetItemPropertyCostTableValue(ipTest);
                if(GetLocalInt(oPC, "PRC_ArcSpell" + IntToString(nLevel)))
                    bPass = FALSE;
                nUMDDC += (nLevel * 2) - 20;
            }
            else if(ipType == ITEM_PROPERTY_USE_LIMITATION_DIVINE_SPELL_LEVEL)
            {
                int nLevel = GetItemPropertyCostTableValue(ipTest);
                if(GetLocalInt(oPC, "PRC_DivSpell" + IntToString(nLevel)))
                    bPass = FALSE;
                nUMDDC += (nLevel * 2) - 20;
            }
            else if(ipType == ITEM_PROPERTY_USE_LIMITATION_SNEAK_ATTACK)
            {
                int nLevel = GetItemPropertyCostTableValue(ipTest);
                if(GetLocalInt(oPC, "PRC_SneakLevel" + IntToString(nLevel)))
                    bPass = FALSE;
                nUMDDC += (nLevel * 2) - 20;
            }
            else if(ipType == ITEM_PROPERTY_USE_LIMITATION_GENDER)
            {
                if(GetGender(oPC) != GetItemPropertySubType(ipTest))
                    bPass = FALSE;
                nUMDDC += 5;
            }
        }

        /* Properties that apply effects. Unequip should cause cleanup here */
        if(ipType == ITEM_PROPERTY_SPEED_INCREASE)
        {
            int iItemAdjust;
            switch(GetItemPropertyCostTableValue(ipTest))
            {
                case 0: iItemAdjust = 10;  break;
                case 1: iItemAdjust = 20;  break;
                case 2: iItemAdjust = 30;  break;
                case 3: iItemAdjust = 40;  break;
                case 4: iItemAdjust = 50;  break;
                case 5: iItemAdjust = 60;  break;
                case 6: iItemAdjust = 70;  break;
                case 7: iItemAdjust = 80;  break;
                case 8: iItemAdjust = 90;  break;
                case 9: iItemAdjust = 100; break;
            }
            if(bUnequip)
                nSpeedIncrease -= iItemAdjust;
            else if(bEquip)
                nSpeedIncrease += iItemAdjust;
        }
        else if(ipType == ITEM_PROPERTY_SPEED_DECREASE)
        {
            int iItemAdjust;
            switch(GetItemPropertyCostTableValue(ipTest))
            {
                case 0: iItemAdjust = 10; break;
                case 1: iItemAdjust = 20; break;
                case 2: iItemAdjust = 30; break;
                case 3: iItemAdjust = 40; break;
                case 4: iItemAdjust = 50; break;
                case 5: iItemAdjust = 60; break;
                case 6: iItemAdjust = 70; break;
                case 7: iItemAdjust = 80; break;
                case 8: iItemAdjust = 90; break;
                case 9: iItemAdjust = 99; break;
            }
            if(bUnequip)
                nSpeedDecrease -= iItemAdjust;
            else if(bEquip)
                nSpeedDecrease += iItemAdjust;
        }
        else if(ipType == ITEM_PROPERTY_PNP_HOLY_AVENGER)
        {
            if(bEquip)
            {
                int nPaladinLevels = GetLevelByClass(CLASS_TYPE_PALADIN, oPC);
                if(!nPaladinLevels)
                {
                    //not a paladin? fake it
                    //not really a true PnP test
                    //instead it sets the paladin level
                    //to the UMD ranks minus the amount required
                    //to use a class restricted item of that value
                    int nSkill = GetSkillRank(SKILL_USE_MAGIC_DEVICE, oPC);
                    if(nSkill)
                    {
                        int nReqSkill = GetUMDForItemCost(oItem);
                        nSkill -= nReqSkill;
                        if(nSkill > 0)
                            nPaladinLevels = nSkill;
                    }
                }

                // Add Holy Avenger specials for Paladins (or successfull fake-Paladins)
                if(nPaladinLevels)
                {
                    DelayCommand(0.1, IPSafeAddItemProperty(oItem,
                        ItemPropertyEnhancementBonus(5), 99999.9));
                    DelayCommand(0.1, IPSafeAddItemProperty(oItem,
                        ItemPropertyDamageBonusVsAlign(IP_CONST_ALIGNMENTGROUP_EVIL,
                            IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEBONUS_2d6), 99999.9));
                    //this is a normal dispel magic useage, should be specific
                    DelayCommand(0.1, IPSafeAddItemProperty(oItem,
                        ItemPropertyCastSpell(IP_CONST_CASTSPELL_DISPEL_MAGIC_5,
                            IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE), 99999.9));
                    DelayCommand(0.1, IPSafeAddItemProperty(oItem,
                        ItemPropertyCastSpellCasterLevel(SPELL_DISPEL_MAGIC,
                            nPaladinLevels), 99999.9));
                }
                // Non-Paladin's get +2 enhancement bonus
                else
                {
                    DelayCommand(0.1, IPSafeAddItemProperty(oItem,
                        ItemPropertyEnhancementBonus(2), 99999.9));

                    // Remove Paladin specials
                    IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS, DURATION_TYPE_TEMPORARY, -1);
                    IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP, DURATION_TYPE_TEMPORARY, IP_CONST_ALIGNMENTGROUP_EVIL);
                    IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_CAST_SPELL, DURATION_TYPE_TEMPORARY);
                    IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL, DURATION_TYPE_TEMPORARY);
                }
            }
            else if(bUnequip)
            {
                IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS,
                    DURATION_TYPE_TEMPORARY, -1);
                IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP,
                    DURATION_TYPE_TEMPORARY, IP_CONST_ALIGNMENTGROUP_EVIL);
                IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_CAST_SPELL,
                    DURATION_TYPE_TEMPORARY);
                IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL,
                    DURATION_TYPE_TEMPORARY);
            }
        }
        else if(ipType == ITEM_PROPERTY_AREA_OF_EFFECT)
        {

            // This should only happen on equip or unequip
            if(bEquip || bUnequip)
            {
                // Remove existing AoE
                effect eTest = GetFirstEffect(oPC);
                while(GetIsEffectValid(eTest))
                {
                    if(GetEffectCreator(eTest) == oItem
                       && GetEffectType(eTest) == EFFECT_TYPE_AREA_OF_EFFECT)
                    {
                        RemoveEffect(oPC, eTest);
                        if(DEBUG) DoDebug("CheckPRCLimitations: Removing old AoE effect");
                    }
                    eTest = GetNextEffect(oPC);
                }

                // Create new AoE - Only when equipping
                if(bEquip)
                {
                    AssignCommand(oItem, _prc_inc_itmrstr_ApplyAoE(oPC, oItem, GetItemPropertySubType(ipTest), GetItemPropertyCostTable(ipTest)));
                }// end if - Equip event
            }// end if - Equip or Unequip event
        }// end if - AoE iprp
        else if(ipType == ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N)
        {
            // Only equippable items can provide bonus spell slots
            if(bEquip || bUnequip)
            {
                int nSubType  = GetItemPropertySubType(ipTest);
                int nCost     = GetItemPropertyCostTable(ipTest);
                SetLocalInt(oPC,
                            "PRC_IPRPBonSpellSlots_" + IntToString(nSubType) + "_" + IntToString(nCost),
                            GetLocalInt(oPC,
                                        "PRC_IPRPBonSpellSlots_" + IntToString(nSubType) + "_" + IntToString(nCost)
                                        )
                             + (bEquip ? 1 : -1)
                            );
            }
        }
        else if(ipType == ITEM_PROPERTY_WIZARDRY)
        {
            int nCost = GetItemPropertyCostTableValue(ipTest);
            if(bEquip)
                AssignCommand(oItem, _prc_inc_itmrstr_ApplyWizardry(oPC, oItem, nCost, "A"));
            else if(bUnequip)
                AssignCommand(oItem, _prc_inc_itmrstr_RemoveWizardry(oPC, oItem, nCost, "A"));
        }
        else if(ipType == ITEM_PROPERTY_DIVINITY)
        {
            int nCost = GetItemPropertyCostTableValue(ipTest);
            if(bEquip)
                AssignCommand(oItem, _prc_inc_itmrstr_ApplyWizardry(oPC, oItem, nCost, "D"));
            else if(bUnequip)
                AssignCommand(oItem, _prc_inc_itmrstr_RemoveWizardry(oPC, oItem, nCost, "D"));
        }

        ipTest = GetNextItemProperty(oItem);
    }// end while - Loop over all itemproperties

    // Determine if speed modification totals had changed
    if(nSpeedDecrease != GetLocalInt(oPC, PLAYER_SPEED_DECREASE))
    {
        SetLocalInt(oPC, PLAYER_SPEED_DECREASE, nSpeedDecrease);
        //_prc_inc_itmrstr_ApplySpeedDecrease(oPC);
    }
    if(nSpeedIncrease != GetLocalInt(oPC, PLAYER_SPEED_INCREASE))
    {
        SetLocalInt(oPC, PLAYER_SPEED_INCREASE, nSpeedIncrease);
        //_prc_inc_itmrstr_ApplySpeedIncrease(oPC);
    }

    // If some restriction would prevent item use, perform UMD skill check
    // Skip in case of unequip
    if(!bUnequip && !bPass)
        bPass = DoUMDCheck(oItem, oPC, nUMDDC);

    return bPass;
}

void CheckForPnPHolyAvenger(object oItem)
{
    if(!GetPRCSwitch(PRC_PNP_HOLY_AVENGER_IPROP))
        return;
    itemproperty ipTest = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipTest))
    {
        if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_HOLY_AVENGER)
        {
            DelayCommand(0.1, RemoveItemProperty(oItem, ipTest));
            DelayCommand(0.1, IPSafeAddItemProperty(oItem, ItemPropertyPnPHolyAvenger()));
        }
        ipTest = GetNextItemProperty(oItem);
    }
}

//:: Test Void
//void main (){}