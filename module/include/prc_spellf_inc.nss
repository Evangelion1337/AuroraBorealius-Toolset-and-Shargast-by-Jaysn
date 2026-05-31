/*

    prc_spellf_inc.nss - Spellfire functions



    By: Flaming_Sword
    Created: February 15, 2006
    Modified: February 15, 2006

    Naming conventions:
        nExpend <-> GetPersistantLocalInt(oPC, "SpellfireLevelExpend");
        nStored <-> GetPersistantLocalInt(oPC, "SpellfireLevelStored");

*/

//#include "inc_utility"
//#include "prc_alterations"
#include "prc_inc_sp_tch"
#include "prcsp_engine"
//int CheckSpellfire(object oCaster, object oTarget, int bFriendly = FALSE);

//Spellfire Functions

//Verifies levels to expend, returns new levels to expend
int SpellfireVerifyExpend(object oPC, int nExpend, int nStored)
{
    int nCON = GetAbilityScore(oPC, ABILITY_CONSTITUTION);

    //sanity check, at least 1, capped by CON and stored
    if(nExpend < 1)
    {
        nExpend = 1;
        SetPersistantLocalInt(oPC, "SpellfireLevelExpend", nExpend);
    }
    if(nExpend > nCON) nExpend = nCON;  //in case CON has changed
    if(nExpend > nStored) nExpend = nStored;    //can't spend more than you've got

    return nExpend;
}

//Adjusts the number of spellfire levels expended
//in the next use of spellfire
void AdjustSpellfire(object oPC, int nAdjust)
{
    int nExpend = GetPersistantLocalInt(oPC, "SpellfireLevelExpend");
    nExpend += nAdjust;
    if(nExpend < 1) nExpend = 1;    //at least 1
    SetPersistantLocalInt(oPC, "SpellfireLevelExpend", nExpend);
    SendMessageToPC(oPC, "Spellfire levels to expend: " + IntToString(nExpend));
}

//Sets flag to change quickselects a la psionics
void SpellfireQuickselectChange(object oPC)
{
    SetLocalInt(oPC, "Spellfire_Quickselect_Change", 1);    //set flag
    SendMessageToPC(oPC, "Select a quickselect to store the current setting");
    DelayCommand(10.0, DeleteLocalInt(oPC, "Spellfire_Quickselect_Change"));    //auto-delete
}

//Sets or changes quickselects
void SpellfireQuickselect(object oPC, int nSpellID)
{
    int nExpend;
    if(GetLocalInt(oPC, "Spellfire_Quickselect_Change"))
    {
        nExpend = GetPersistantLocalInt(oPC, "SpellfireLevelExpend");
        SetPersistantLocalInt(oPC, "Spellfire_Quickselect_" + IntToString(nSpellID), nExpend);
        SendMessageToPC(oPC, "Quickselect " + IntToString(nSpellID - SPELL_SPELLFIRE_QUICKSELECT_1 + 1) + " set to " + IntToString(nExpend));
        DeleteLocalInt(oPC, "Spellfire_Quickselect_Change");
    }
    else
    {
        nExpend = GetPersistantLocalInt(oPC, "Spellfire_Quickselect_" + IntToString(nSpellID));
        SetPersistantLocalInt(oPC, "SpellfireLevelExpend", nExpend);
        SendMessageToPC(oPC, "Spellfire levels to expend: " + IntToString(nExpend));
    }
}

//Expends spellfire and returns the new value
int ExpendSpellfire(object oPC)
{
    int nStored = GetPersistantLocalInt(oPC, "SpellfireLevelStored");
    if(!nStored) return 0;
    int nExpend = GetPersistantLocalInt(oPC, "SpellfireLevelExpend");

    nExpend = SpellfireVerifyExpend(oPC, nExpend, nStored);

    nStored -= nExpend;
    SetPersistantLocalInt(oPC, "SpellfireLevelStored", nStored);
    return nExpend;
}

//Applies spellfire damage to target
void SpellfireDamage(object oCaster, object oTarget, int nRoll, int nDamage, int bMaelstrom = FALSE)
{
    if(bMaelstrom)
    {
        //nDamage += ApplySpellBetrayalStrikeDamage(oTarget, oCaster);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, PRCEffectDamage(oTarget, nDamage / 2, DAMAGE_TYPE_MAGICAL), oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage - (nDamage / 2), DAMAGE_TYPE_FIRE), oTarget);
    }
    else
        ApplyTouchAttackDamage(oCaster, oTarget, nRoll, nDamage, DAMAGE_TYPE_MAGICAL, DAMAGE_TYPE_FIRE);
    SPApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SPELLF_FLAME), oTarget);
}

//Spellfire attack roll -> damage
void SpellfireAttackRoll(object oCaster, object oTarget, int nExpend, int iMod = 0, int nDC = 20, int bBeam = FALSE, int bMaelstrom = FALSE)
{
    int nRoll, nDamage;

    //Account for Energy Draconic Aura
    if (GetLocalInt(oCaster, "FireEnergyAura") > 0)
    {
        nDC += GetLocalInt(oCaster, "FireEnergyAura");
    }

    //Weapon Focus (spellfire) applies to spellfire only
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SPELLFIRE, oCaster)) iMod++;
    if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SPELLFIRE, oCaster)) iMod += 2;

    if(oCaster == oTarget)  //yeah, like you could miss with a touch attack on yourself
    {
        nRoll = 1;
        nDamage = d6(nExpend);
    }
    else
    {
        nRoll = bMaelstrom ? 1 : GetAttackRoll(oTarget, oCaster, GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster), 0, 0, iMod, TRUE, 0.0, TRUE);
        nDamage = PRCGetReflexAdjustedDamage(d6(nExpend), oTarget, nDC, SAVING_THROW_TYPE_NONE, oCaster);
    }
    if(bBeam)
        SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_SPELLFIRE, oCaster, BODY_NODE_HAND, !nRoll), oTarget, 1.2 /*+ (0.5 * IntToFloat(nAttacks))*/);
    if(nRoll && nDamage)
        SpellfireDamage(oCaster, oTarget, nRoll, nDamage, bMaelstrom);
}

//Hits target with spellfire, implements rapid blast
void SpellfireAttack(object oCaster, object oTarget, int bBeam, int nAttacks = 1)
{
    if(!GetPersistantLocalInt(oCaster, "SpellfireLevelStored"))
    {
        SendMessageToPC(oCaster, "You have no more stored spellfire levels");
        return;
    }
    int nLevel = GetLevelByClass(CLASS_TYPE_SPELLFIRE, oCaster);
    if(nAttacks > ((nLevel / 4) + 1))
    {
        SendMessageToPC(oCaster, "You do not have enough Spellfire Channeler levels use this feat");
        return;
    }
    int iMod = 0;
    int i;
    //looping attacks
    //SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_SPELLFIRE, oCaster, BODY_NODE_HAND, !nRoll), oTarget, 1.2 + (0.5 * IntToFloat(nAttacks)));
    SignalEvent(oTarget, EventSpellCastAt(oCaster, SPELL_SPELLFIRE_ATTACK));
    for(i = 0; i < nAttacks; i++)
        DelayCommand(0.5 * IntToFloat(i), SpellfireAttackRoll(oCaster, oTarget, ExpendSpellfire(oCaster), iMod - (2 * i), 20, bBeam));
    //longer effect for more blasts
    DelayCommand(0.1, SendMessageToPC(oCaster, "Spellfire levels stored: " + IntToString(GetPersistantLocalInt(oCaster, "SpellfireLevelStored"))));
}

//Heals target
void SpellfireHeal(object oCaster, object oTarget)
{
    if(!GetPersistantLocalInt(oCaster, "SpellfireLevelStored"))
    {
        SendMessageToPC(oCaster, "You have no more stored spellfire levels");
        return;
    }
    int nExpend = ExpendSpellfire(oCaster);
    int nHeal = 2 * nExpend;
    if(GetHasFeat(FEAT_SPELLFIRE_IMPROVED_HEALING, oCaster))
        nHeal = d4(nExpend) + nExpend;

    SPApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHeal), oTarget);
    SPApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SPELLF_HEAL), oTarget);
    DelayCommand(0.1, SendMessageToPC(oCaster, "Spellfire levels stored: " + IntToString(GetPersistantLocalInt(oCaster, "SpellfireLevelStored"))));
}

//Maelstrom of fire
void SpellfireMaelstrom(object oCaster)
{
    if(!GetPersistantLocalInt(oCaster, "SpellfireLevelStored"))
    {
        SendMessageToPC(oCaster, "You have no more stored spellfire levels");
        return;
    }
    int nLevel = GetLevelByClass(CLASS_TYPE_SPELLFIRE, oCaster);
    int nCHA = GetAbilityModifier(ABILITY_CHARISMA, oCaster);
    int nDC = 10 + nLevel + nCHA;

    //Account for Energy Draconic Aura
    if (GetLocalInt(oCaster, "FireEnergyAura") > 0)
    {
        nDC += GetLocalInt(oCaster, "FireEnergyAura");
    }

    //expend once, hit multiple targets
    int nExpend = ExpendSpellfire(oCaster);
    float fDelay;
    location lTarget = GetLocation(oCaster);
    effect eExplode = EffectVisualEffect(VFX_FNF_SPELLF_EXP);
    //KABOOM!
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
    object oTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster))
        {   //ripped off fireball
            SignalEvent(oTarget, EventSpellCastAt(oCaster, SPELL_SPELLFIRE_MAELSTROM));
            //Get the distance between the explosion and the target to calculate delay
            fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget)) / 20;
            DelayCommand(fDelay, SpellfireAttackRoll(oCaster, oTarget, nExpend, 0, nDC, FALSE, TRUE));
        }
        oTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}

//Returns the caster level of an item with the cast spell property
int GetItemCasterLevelFromCastSpell(object oItem, itemproperty ip)
{
    int nCostTableValue = GetItemPropertyCostTableValue(ip);
    int nSubtype = GetItemPropertySubType(ip);
    int nCasterLevel = StringToInt(Get2DACache("iprp_spells", "CasterLvl", nSubtype));

    itemproperty ip2 = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip2))
    {
        if(GetItemPropertyType(ip2) == ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL &&
            //temporary caster level? i think not.
            GetItemPropertyDurationType(ip2) == DURATION_TYPE_PERMANENT &&
            GetItemPropertySubType(ip2) == nSubtype)
        {
            int nNewCasterLevel = GetItemPropertyCostTableValue(ip2);   //caster level property
            if(nNewCasterLevel > nCasterLevel) nCasterLevel = nNewCasterLevel;
            break;
        }
        ip2 = GetNextItemProperty(oItem);
    }
    return nCasterLevel;
}

//Returns TRUE if an item is drained
int SpellfireDrainItem(object oPC, object oItem, int bCharged = TRUE, int bSingleUse = TRUE)
{
    if(GetIsObjectValid(oItem) && GetIsMagicItem(oItem))
    {   //drain charged item
        if(bCharged)    //because big compound if statements are messy
        {
            int nBase = GetBaseItemType(oItem);
            int nExpend = GetPersistantLocalInt(oPC, "SpellfireLevelExpend");
            if(nExpend < 1)
            {
                nExpend = 1;
                SetPersistantLocalInt(oPC, "SpellfireLevelExpend", nExpend);
            }
            int nStored = GetPersistantLocalInt(oPC, "SpellfireLevelStored");
            int nCap = SpellfireMax(oPC) - nStored;
            itemproperty ip;
            int nSubType;
            int nStack = GetItemStackSize(oItem);
            int nCharges = GetItemCharges(oItem);
            if(nCharges)   //charged item
            {
                nExpend = PRCMin(PRCMin(nCharges, nCap), nExpend); //capped by charges and capacity
                SetItemCharges(oItem, nCharges - nExpend);  //will destroy item if all charges drained
                AddSpellfireLevels(oPC, nExpend);   //adds 1 level/charge
                return TRUE;
            }
            ip = GetFirstItemProperty(oItem);
            while(GetIsItemPropertyValid(ip))  //single use item
            {
                if(GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL &&
                    GetItemPropertyDurationType(ip) == DURATION_TYPE_PERMANENT &&
                    GetItemPropertyCostTableValue(ip) == IP_CONST_CASTSPELL_NUMUSES_SINGLE_USE)
                    {
                        if(DEBUG)
                        {
                            DoDebug("SpellfireDrainItem(): nBase = " + IntToString(nBase), oPC);
                            DoDebug("SpellfireDrainItem(): nStack = " + IntToString(nStack), oPC);
                            DoDebug("SpellfireDrainItem(): nCap = " + IntToString(nCap), oPC);
                            DoDebug("SpellfireDrainItem(): nExpend = " + IntToString(nExpend), oPC);
                        }
                        nSubType = GetItemPropertySubType(ip);
                        //hardcoded filter
                        if(!(
                            (nSubType >= 329 && nSubType <= 344) ||
                            (nSubType == 359) ||
                            (nSubType >= 400 && nSubType <= 409) ||
                            (nSubType >= 411 && nSubType <= 446) ||
                            (nSubType >= 490 && nSubType <= 500) ||
                            (nSubType == 513) ||
                            (nSubType >= 521 && nSubType <= 537) ||
                            (nSubType >= 750 && nSubType <= 851) ||
                            (nSubType >= 1201)
                        ))
                        {

                            if((nBase == BASE_ITEM_POTIONS) ||
								(nBase == BASE_ITEM_INFUSED_HERB) ||
                                (nBase == BASE_ITEM_SCROLL) ||
                                (nBase == BASE_ITEM_SPELLSCROLL) ||
                                (nBase == BASE_ITEM_BLANK_POTION) ||
                                (nBase == BASE_ITEM_BLANK_SCROLL) ||
                                (nBase == BASE_ITEM_ENCHANTED_POTION) ||
                                (nBase == BASE_ITEM_ENCHANTED_SCROLL)
                                )
                            {
                                nExpend = PRCMin(PRCMin(nStack, nCap), nExpend); //capped by charges and capacity
                                if(nExpend == nStack)
                                    DestroyObject(oItem);
                                else
                                    SetItemStackSize(oItem, nStack - nExpend);  //modifies stack size as scrolls/potions are used up
                                AddSpellfireLevels(oPC, nExpend);   //adds 1 level/charge
                                return TRUE;
                            }
                            else
                            {
                                RemoveItemProperty(oItem, ip);  //just removes the cast spell property
                                AddSpellfireLevels(oPC, 1);     //adds 1 level
                                return TRUE;
                            }
                        }
                    }
                ip = GetNextItemProperty(oItem);
            }
        }
        else    //drain permanent item
        {
            itemproperty ip = GetFirstItemProperty(oItem);
            int nCostTableValue = GetItemPropertyCostTableValue(ip);
            while(GetIsItemPropertyValid(ip))
            {
                if(GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL &&
                    GetItemPropertyDurationType(ip) == DURATION_TYPE_PERMANENT &&
                    nCostTableValue >= IP_CONST_CASTSPELL_NUMUSES_0_CHARGES_PER_USE)
                    {
                        nCostTableValue = GetItemPropertyCostTableValue(ip);
                        int nSubtype = GetItemPropertySubType(ip);
                        int nLevel = GetItemCasterLevelFromCastSpell(oItem, ip) / 2;
                        RemoveItemProperty(oItem, ip);  //just removes the cast spell property
                        AddSpellfireLevels(oPC, nLevel);    //adds half the caster level

                        DelayCommand(HoursToSeconds(24),    //reapplying property
                                        IPSafeAddItemProperty(oItem,
                                            ItemPropertyCastSpell(nSubtype, nCostTableValue),
                                            0.0,
                                            X2_IP_ADDPROP_POLICY_KEEP_EXISTING));
                        return 1;
                    }
                ip = GetNextItemProperty(oItem);
            }
        }
    }
    return 0;
}

//Returns "'s" if sName has no s at the end, otherwise "'"
string Name_s(string sName = "")
{
    return (GetStringRight(sName, 1) == "s") ? "'" : "'s";
}

//Finds an item to drain, favours equipped items
//WARNING: This will loop through every item property on every item
//  until the right conditions are met
void SpellfireDrain(object oPC, object oTarget, int bCharged = TRUE, int bExemptCreatureItems = TRUE, int bSingleUse = TRUE)
{
    object oItem;
    int nObjectType = GetObjectType(oTarget);
    string sMessage_oPC = "";
    string sMessage_oTarget = "";
    string sName_oPC = GetName(oPC);
    string sName_oTarget = GetName(oTarget);
    int bFound = 0;

    if(nObjectType == OBJECT_TYPE_ITEM)
    {
        oItem = oTarget;
        int nBase = GetBaseItemType(oItem);
        if(GetPRCSwitch(PRC_SPELLFIRE_DISALLOW_DRAIN_SCROLL_POTION) &&
            ((nBase == BASE_ITEM_POTIONS) ||
            (nBase == BASE_ITEM_SCROLL) ||
			(nBase == BASE_ITEM_INFUSED_HERB) ||
            (nBase == BASE_ITEM_BLANK_POTION) ||
            (nBase == BASE_ITEM_BLANK_SCROLL)
            )
            )
        {
            sMessage_oPC = "Draining charges from scrolls and potions is not allowed";
        }
        else if(SpellfireDrainItem(oPC, oItem, bCharged))
        {
            bFound = 1;
            sMessage_oPC = "You drained " + sName_oTarget;
        }
    }
    else if(nObjectType == OBJECT_TYPE_CREATURE)
    {
        if(!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, 10, SAVING_THROW_TYPE_NONE, oPC))
        {
                    //creature items exempt
            int nSlotMax = bExemptCreatureItems ? INVENTORY_SLOT_CWEAPON_L : NUM_INVENTORY_SLOTS;
            //int nCharges = 0;
            int i;
            for(i = 0; i < nSlotMax; i++)
            {
                oItem = GetItemInSlot(i, oTarget);
                if(SpellfireDrainItem(oPC, oItem, bCharged))
                {
                    bFound = 1;
                    break;
                }
            }
            oItem = GetFirstItemInInventory(oTarget);
            if(bFound != 1)
            {
                while(GetIsObjectValid(oItem))
                {
                    if(SpellfireDrainItem(oPC, oItem, bCharged))
                    {
                        bFound = 1;
                        break;
                    }
                }
            }
            //search function
            if(bFound)
            {
                sMessage_oPC = "You drained " + GetName(oItem) + " from " + sName_oTarget;
                //sMessage_oTarget = sName_oPC + " drained " + GetName(oItem) " from you";
            }
            else
            {
                sMessage_oPC = "You tried to drain one of " + sName_oTarget + Name_s(sName_oTarget) + " items, but failed";
                sMessage_oTarget = sName_oPC + " tried to drain one of your items, but failed";
            }
        }
        else
        {
                sMessage_oPC = sName_oTarget + " resisted your attempt to drain one of <his/her> items";
                sMessage_oTarget = "You resisted " + sName_oPC + Name_s(sName_oPC) + " attempt to drain one of your items";
        }
    }
    else if(DEBUG)
        DoDebug("SpellfireDrain(): Invalid target object", oPC);

    if(bFound && !bCharged)
    {
        string s24 = " for 24 hours";
        sMessage_oPC += s24;
        sMessage_oTarget += s24;
    }

    if(GetIsPC(oPC) && sMessage_oPC != "") SendMessageToPC(oPC, sMessage_oPC);
    if(GetIsPC(oTarget) && sMessage_oTarget != "") SendMessageToPC(oTarget, sMessage_oTarget);
}

//Toggles a flag
void SpellfireToggleAbsorbFriendly(object oPC)
{
    if(GetLocalInt(oPC, "SpellfireAbsorbFriendly"))
    {
        DeleteLocalInt(oPC, "SpellfireAbsorbFriendly");
        FloatingTextStringOnCreature("*Absorb Friendly Spells Off*", oPC);
    }
    else
    {
        SetLocalInt(oPC, "SpellfireAbsorbFriendly", 1);
        FloatingTextStringOnCreature("*Absorb Friendly Spells On*", oPC);
    }
}

//Charges items
void SpellfireChargeItem(object oPC, object oItem)
{
    int nObjectType = GetObjectType(oItem);
    if(nObjectType == OBJECT_TYPE_ITEM)
    {
        int nExpend = ExpendSpellfire(oPC);
        int nCharges = GetItemCharges(oItem);
        int nNewCharges = nExpend + nCharges;
        if(nNewCharges > 50)
        {
            AddSpellfireLevels(oPC, nNewCharges - 50);
            nNewCharges = 50;
        }
        //SetItemCharges(oItem, nCharges + nExpend);
		SetItemCharges(oItem, nNewCharges);
        //Assuming 50 is the maximum
           //refunding excess charges
    }
    else if(DEBUG)
        DoDebug("SpellfireChargeItem(): Invalid target object", oPC);
}

//Applies Crown of Fire effects. Other effects are implemented
//through heartbeat and onhit scripts
void SpellfireCrown(object oPC)
{
    if(GetLocalInt(oPC, "SpellfireCrown"))
    {
        DeleteLocalInt(oPC, "SpellfireCrown");
        PRCRemoveEffectsFromSpell(oPC, SPELL_SPELLFIRE_CROWN);
        FloatingTextStringOnCreature("*Crown of Fire Deactivated*", oPC);
    }
    else
    {
        if(GetPersistantLocalInt(oPC, "SpellfireLevelStored") < 10)
        {
            SendMessageToPC(oPC, "You do not have enough stored spellfire levels");
            return;
        }
        SetLocalInt(oPC, "SpellfireCrown", 1);
        effect eDmgred = EffectDamageReduction(10, DAMAGE_POWER_PLUS_ONE);
        effect eResist = EffectSpellResistanceIncrease(32);
        effect eCrown = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
        effect eFlame = EffectVisualEffect(VFX_DUR_ELEMENTAL_SHIELD);
        effect eLight = EffectVisualEffect(VFX_DUR_LIGHT_WHITE_20);
        effect eLink = EffectLinkEffects(eDmgred, eResist);
        eLink = EffectLinkEffects(eLink, eCrown);
        eLink = EffectLinkEffects(eLink, eFlame);
        eLink = EffectLinkEffects(eLink, eLight);
        SPApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oPC);
        FloatingTextStringOnCreature("*Crown of Fire Activated*", oPC);
    }
}

//:: void main() {}