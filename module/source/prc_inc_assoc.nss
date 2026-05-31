//:://////////////////////////////////////////////
//:: Associate include
//:: prc_inc_assoc.nss
//:://////////////////////////////////////////////
/*
    This file contains various functions for animal
    companions and familiars
*/
//:://////////////////////////////////////////////

#include "inc_npc"
#include "inc_nwnx_funcs"
#include "shd_inc_shdfunc"

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

//adds associate as a henchman
void AddAssociate(object oMaster, object oAssociate);

//removes associate with unsummon vfx
void DestroyAssociate(object oAssociate);

//applies fiendiosh template
void ApplyFiendishTemplate(object oCompanion, object oCompSkin);

//applies exalted companion bonuses
void ApplyExaltedCompanion(object oCompanion, object oCompSkin);

//applies blightspawned properties
void ApplyIllmaster(object oCompanion, object oCompSkin);

//applies pseudonatural template
void ApplyPseudonatural(object oFamiliar, object oFamSkin);

//applies pnp familiar bonuses
void ApplyPnPFamiliarProperties(object oPC, object oFamiliar);

//sets up animal companion natural weapons using following scheme:
/*
     Damage
Lvl Claw Bite
1   1d3  1d6
6   1d4  1d8
12  1d6  1d10
19  1d8  2d6
27  1d10 2d8
36  1d12 2d10

enhancement bonus
(Lvl - 15) / 5
*/
void SetNaturalWeaponDamage(object oCompanion, int nLvlMod = 0);

void UnsummonCompanions(object oPC);

//////////////////////////////////////////////////
/*                  Constants                   */
//////////////////////////////////////////////////

const int DISEASE_TALONAS_BLIGHT = 52;

//associate numbers as nTH parameter in GetAssociateNPC()
const int NPC_BIOWARE_COMPANION  = 1; //'original' bioware familiar/companion returned by GetAssociate()
const int NPC_HENCHMAN_COMPANION = 2; //bioware familiar/companion added as hanchman
//ASSOCIATE_TYPE_FAMILIAR
const int NPC_PNP_FAMILIAR       = 3;
const int NPC_BONDED_FAMILIAR    = 4;
const int NPC_DN_FAMILIAR        = 5;
const int NPC_MS_ELEMENTAL       = 6;
//ASSOCIATE_TYPE_ANIMALCOMPANION
const int NPC_SHAMAN_COMPANION   = 3;
const int NPC_UR_COMPANION       = 4;
//ASSOCIATE_TYPE_SUMMONED
const int NPC_DARK_COMPANION     = 2;

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void AddAssociate(object oMaster, object oAssociate)
{
    int nMaxHenchmen = GetMaxHenchmen();
    SetMaxHenchmen(99);
    AddHenchman(oMaster, oAssociate);
    SetMaxHenchmen(nMaxHenchmen);
}

void DestroyAssociate(object oAssociate)
{
    AssignCommand(oAssociate, SetIsDestroyable(TRUE));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oAssociate));
    DestroyObject(oAssociate);
}

void CleanProperties(object oItem)
{
    itemproperty ip = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip))
    {
        RemoveItemProperty(oItem, ip);
        ip = GetNextItemProperty(oItem);
    }
}

void ApplyFiendishTemplate(object oTarget, object oCompSkin)
{
    int nHD = GetHitDice(oTarget);
    effect eDR;
    int nResist;

    if (nHD >= 12)
    {
        eDR = EffectDamageReduction(10, DAMAGE_POWER_PLUS_THREE);
        nResist = 20;
    }
    else if (12 > nHD && nHD >= 8)
    {
        eDR = EffectDamageReduction(5, DAMAGE_POWER_PLUS_TWO);
        nResist = 15;
    }
    else if (8 > nHD && nHD >= 4)
    {
        eDR = EffectDamageReduction(5, DAMAGE_POWER_PLUS_ONE);
        nResist = 10;
    }
    else if (4 > nHD)
    {
        nResist = 5;
    }

    effect eFire = EffectDamageResistance(DAMAGE_TYPE_FIRE, nResist);
    effect eCold = EffectDamageResistance(DAMAGE_TYPE_COLD, nResist);
    effect eVis  = EffectUltravision();
    effect eLink = EffectLinkEffects(eDR, eFire);
           eLink = EffectLinkEffects(eLink, eCold);
           eLink = EffectLinkEffects(eLink, eVis);
           eLink = SupernaturalEffect(eLink);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);

    itemproperty ipIP = PRCItemPropertyBonusFeat(FEAT_TEMPLATE_FIENDISH_SMITE_GOOD);
    IPSafeAddItemProperty(oCompSkin, ipIP, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);

    if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_EVIL)
        AdjustAlignment(oTarget, ALIGNMENT_EVIL, 80, FALSE);

	SetSubRace(oTarget, "Undead (Extraplanar)");
	
    SetLocalInt(oTarget, "FiendishTemplate", 1);
	
}


void ApplyExaltedCompanion(object oCompanion, object oCompSkin)
{
    int nHD = GetHitDice(oCompanion);
    effect eDR;
    int nResist;

    if (nHD >= 12)
    {
        eDR = EffectDamageReduction(10, DAMAGE_POWER_PLUS_THREE);
        nResist = 20;
    }
    else if (12 > nHD && nHD >= 8)
    {
        eDR = EffectDamageReduction(5, DAMAGE_POWER_PLUS_TWO);
        nResist = 15;
    }
    else if (8 > nHD && nHD >= 4)
    {
        eDR = EffectDamageReduction(5, DAMAGE_POWER_PLUS_ONE);
        nResist = 10;
    }
    else if (4 > nHD)
    {
        nResist = 5;
    }

    effect eAcid = EffectDamageResistance(DAMAGE_TYPE_ACID, nResist);
    effect eCold = EffectDamageResistance(DAMAGE_TYPE_COLD, nResist);
    effect eElec = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, nResist);
    effect eVis  = EffectUltravision();
    effect eLink = EffectLinkEffects(eDR, eAcid);
           eLink = EffectLinkEffects(eLink, eCold);
           eLink = EffectLinkEffects(eLink, eElec);
           eLink = EffectLinkEffects(eLink, eVis);
           eLink = SupernaturalEffect(eLink);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oCompanion);

    itemproperty ipIP = PRCItemPropertyBonusFeat(IP_CONST_FEAT_TEMPLATE_CELESTIAL_SMITE_EVIL);
    IPSafeAddItemProperty(oCompSkin, ipIP, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);

    if(GetAlignmentGoodEvil(oCompanion) != ALIGNMENT_GOOD)
        AdjustAlignment(oCompanion, ALIGNMENT_GOOD, 80, FALSE);

    SetLocalInt(oCompanion, "CelestialTemplate", 1);
}

void ApplyPseudonatural(object oFamiliar, object oFamSkin)
{
    if(GetLocalInt(oFamiliar, "PseudonaturalTemplate"))
        return;

    int nHD = GetHitDice(oFamiliar);
    int nResist;
    effect eDR;
    if (nHD >= 12)
    {
        eDR = EffectDamageReduction(10, DAMAGE_POWER_PLUS_THREE);
        nResist = 20;
    }
    else if (12 > nHD && nHD >= 8)
    {
        eDR = EffectDamageReduction(5, DAMAGE_POWER_PLUS_TWO);
        nResist = 15;
    }
    else if (8 > nHD && nHD >= 4)
    {
        eDR = EffectDamageReduction(5, DAMAGE_POWER_PLUS_ONE);
        nResist = 10;
    }
    else if (4 > nHD)
    {
        nResist = 5;
    }

    effect eAcid = EffectDamageResistance(DAMAGE_TYPE_ACID, nResist);
    effect eElec = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, nResist);
    effect eAC   = EffectACIncrease(1,AC_NATURAL_BONUS);
    effect eLink = EffectLinkEffects(eDR, eAcid);
           eLink = EffectLinkEffects(eLink, eElec);
           eLink = EffectLinkEffects(eLink, eAC);
           eLink = SupernaturalEffect(eLink);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oFamiliar);

//    itemproperty ipIP = PRCItemPropertyBonusFeat(IP_CONST_FEAT_TEMPLATE_PSEUDONATURAL_TRUESTRIKE);
//    IPSafeAddItemProperty(oFamSkin, ipIP, 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);

    SetLocalInt(oFamiliar, "PseudonaturalTemplate", 1);
}

void ApplyIllmaster(object oCompanion, object oCompSkin)
{
    //Give the companion permanent Str +4, Con +2, Wis -2, and Cha -2
    if(GetPRCSwitch(PRC_NWNXEE_ENABLED))
    {
        PRC_Funcs_ModAbilityScore(oCompanion, ABILITY_STRENGTH,     4);
        PRC_Funcs_ModAbilityScore(oCompanion, ABILITY_CONSTITUTION, 2);
        PRC_Funcs_ModAbilityScore(oCompanion, ABILITY_WISDOM,      -2);
        PRC_Funcs_ModAbilityScore(oCompanion, ABILITY_CHARISMA,    -2);
    }
    else
    {
        string sFlag = "Illmaster";
        SetCompositeBonus(oCompSkin, sFlag, 4, ITEM_PROPERTY_ABILITY_BONUS,           IP_CONST_ABILITY_STR);
        SetCompositeBonus(oCompSkin, sFlag, 2, ITEM_PROPERTY_ABILITY_BONUS,           IP_CONST_ABILITY_CON);
        SetCompositeBonus(oCompSkin, sFlag, 2, ITEM_PROPERTY_DECREASED_ABILITY_SCORE, IP_CONST_ABILITY_WIS);
        SetCompositeBonus(oCompSkin, sFlag, 2, ITEM_PROPERTY_DECREASED_ABILITY_SCORE, IP_CONST_ABILITY_CHA);
    }

    //Set PLANT immunities and add low light vision
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertySpellImmunitySpecific(IP_CONST_IMMUNITYSPELL_CHARM_PERSON),    oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertySpellImmunitySpecific(IP_CONST_IMMUNITYSPELL_DOMINATE_PERSON), oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertySpellImmunitySpecific(IP_CONST_IMMUNITYSPELL_HOLD_PERSON),     oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertySpellImmunitySpecific(IP_CONST_IMMUNITYSPELL_MASS_CHARM),      oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_MINDSPELLS),                oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_POISON),                    oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_PARALYSIS),                 oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_CRITICAL_HITS),             oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_DISEASE),                   oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_BACKSTAB),                  oCompSkin);
    AddItemProperty(DURATION_TYPE_PERMANENT, PRCItemPropertyBonusFeat(FEAT_LOWLIGHTVISION),                             oCompSkin);

    //Compute the DC for this companion's blight touch
    int iHD = GetHitDice(oCompanion);
    int iCons = GetAbilityModifier(ABILITY_CONSTITUTION, oCompanion);
    int iDC = 10 + (iHD / 2) + iCons;
    //Create the onhit item property for causing the blight touch disease
    itemproperty ipBlightTouch = ItemPropertyOnHitProps(IP_CONST_ONHIT_DISEASE, IPOnHitSaveDC(iDC), DISEASE_TALONAS_BLIGHT);
    //Get the companion's creature weapons
    object oBite = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oCompanion);
    object oLClaw = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oCompanion);
    object oRClaw = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oCompanion);
    //Apply blight touch to each weapon
    if (GetIsObjectValid(oBite))
        IPSafeAddItemProperty(oBite, ipBlightTouch);
    if (GetIsObjectValid(oLClaw))
        IPSafeAddItemProperty(oLClaw, ipBlightTouch);
    if (GetIsObjectValid(oRClaw))
        IPSafeAddItemProperty(oRClaw, ipBlightTouch);

    //Adjust alignment to Neutral Evil
    if(GetAlignmentLawChaos(oCompanion) != ALIGNMENT_NEUTRAL)
        AdjustAlignment(oCompanion, ALIGNMENT_NEUTRAL, 50, FALSE);
    if (GetAlignmentGoodEvil(oCompanion) != ALIGNMENT_EVIL)
        AdjustAlignment(oCompanion, ALIGNMENT_EVIL, 80, FALSE);
}

void WinterWolfProperties(object oCompanion, int nLevel)
{
    int iStr = nLevel >= 30 ? (nLevel-30)/2 : (nLevel-4)/2;
    int iDex = nLevel >= 30 ? (nLevel-31)/2 : (nLevel-5)/2;

    object oCreR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oCompanion);

    if(GetPRCSwitch(PRC_NWNXEE_ENABLED))
    {
        if(iStr > 0)
            PRC_Funcs_ModAbilityScore(oCompanion, ABILITY_STRENGTH, iStr);
        if(iDex > 0)
            PRC_Funcs_ModAbilityScore(oCompanion, ABILITY_DEXTERITY, iStr);
    }
    else
    {
        if(iStr > 0)
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR, iStr), oCreR);
        if(iDex > 0)
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAbilityBonus(IP_CONST_ABILITY_DEX, iDex), oCreR);
    }

    int nBonusDmg;

    if(nLevel > 24)
        nBonusDmg = IP_CONST_DAMAGEBONUS_1d12;
    else if(nLevel > 16)
        nBonusDmg = IP_CONST_DAMAGEBONUS_1d10;
    else if(nLevel > 7)
        nBonusDmg = IP_CONST_DAMAGEBONUS_1d8;
    else
        nBonusDmg = IP_CONST_DAMAGEBONUS_1d6;

    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, nBonusDmg), oCreR);
    //winter wolf properties
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDamageVulnerability(IP_CONST_DAMAGETYPE_FIRE, IP_CONST_DAMAGEVULNERABILITY_50_PERCENT), oCreR);
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_COLD, IP_CONST_DAMAGEIMMUNITY_100_PERCENT), oCreR);

    int iMax, i;
    int coneAbi = nLevel / 5;
    switch(coneAbi)
    {
        case 1 : iMax = 7; break;
        case 2 : iMax = 6; break;
        case 3 : iMax = 5; break;
        case 4 : iMax = 4; break;
        case 5 : iMax = 3; break;
        case 6 : iMax = 2; break;
        case 7 : iMax = 1; break;
    }

    if(iMax > 0)
    {
        for(i = 1; i <= iMax; i++)
            DecrementRemainingSpellUses(oCompanion, 230);
    }
}

void ApplyPnPFamiliarProperties(object oPC, object oFam)
{
	int nNWNxEE = GetPRCSwitch(PRC_NWNXEE_ENABLED);
	int nPRCx	= GetPRCSwitch(PRC_PRCX_ENABLED);
    int bFuncs = (nNWNxEE && nPRCx);
	
    effect eBonus;

    //get familiar level
    int nFamLevel = GetLevelByClass(CLASS_TYPE_WIZARD, oPC)
        + GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
        + GetLevelByClass(CLASS_TYPE_WITCH, oPC)
        + GetLevelByClass(CLASS_TYPE_ALIENIST, oPC)
        + GetLevelByClass(CLASS_TYPE_HEXBLADE, oPC)
        + GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oPC);
        
    if (GetHasFeat(FEAT_SHADOW_FAMILIAR, oPC)) nFamLevel = GetLevelByTypeArcane(oPC) + GetShadowcasterLevel(oPC); // For the purpose of determining familiar abilities that depend on your arcane caster level, 
                                                                                                                   // your levels in all classes that allow you to cast mysteries or arcane spells stack

    //scaling bonuses
    int nAdjustLevel = nFamLevel - GetHitDice(oFam);
    int n;
    for(n = 1; nAdjustLevel >= n; n++)
        LevelUpHenchman(oFam, CLASS_TYPE_INVALID, TRUE);

    int nACBonus  = nFamLevel / 2;
    int nIntBonus = nFamLevel / 2;
    int nSRBonus  = nFamLevel > 11 ? nFamLevel + 5 : 0;

    //saving throws
    int nSaveRefBonus = GetReflexSavingThrow(oPC) - GetReflexSavingThrow(oFam);
    int nSaveFortBonus = GetFortitudeSavingThrow(oPC) - GetFortitudeSavingThrow(oFam);
    int nSaveWillBonus = GetWillSavingThrow(oPC) - GetWillSavingThrow(oFam);

    int nHPBonus;

    if(bFuncs)
    {
        nHPBonus = GetMaxHitPoints(oPC) / 2;

        int i, nBonus;
        for(i = 0; i < GetPRCSwitch(FILE_END_SKILLS); i++)
        {
            nBonus = GetSkillRank(i, oPC) - GetSkillRank(i, oFam);
            if(nBonus > 0)
                PRC_Funcs_ModSkill(oFam, i, nBonus);
        }

        PRC_Funcs_SetBaseNaturalAC(oFam, PRC_Funcs_GetBaseNaturalAC(oFam) + nACBonus);
        PRC_Funcs_ModAbilityScore(oFam, ABILITY_INTELLIGENCE, nIntBonus);
        PRC_Funcs_ModSavingThrowBonus(oFam, SAVING_THROW_REFLEX, nSaveRefBonus);
        PRC_Funcs_ModSavingThrowBonus(oFam, SAVING_THROW_FORT, nSaveFortBonus);
        PRC_Funcs_ModSavingThrowBonus(oFam, SAVING_THROW_WILL, nSaveWillBonus);
        PRC_Funcs_SetMaxHitPoints(oFam, nHPBonus);
        PRC_Funcs_SetCurrentHitPoints(oFam, nHPBonus);
    }
    else
    {
        //temporary HP for the moment, have to think of a better idea later
        nHPBonus = (GetMaxHitPoints(oPC) / 2) - GetMaxHitPoints(oFam);

        int i, nBonus;
        for(i = 0; i < GetPRCSwitch(FILE_END_SKILLS); i++)
        {
            nBonus = GetSkillRank(i, oPC) - GetSkillRank(i, oFam);
            eBonus = EffectLinkEffects(eBonus, EffectSkillIncrease(i, nBonus));
        }

        eBonus = EffectLinkEffects(eBonus, EffectACIncrease(nACBonus, AC_NATURAL_BONUS));
        eBonus = EffectLinkEffects(eBonus, EffectAbilityIncrease(ABILITY_INTELLIGENCE, nIntBonus));
        eBonus = EffectLinkEffects(eBonus, EffectSavingThrowIncrease(SAVING_THROW_REFLEX, nSaveRefBonus));
        eBonus = EffectLinkEffects(eBonus, EffectSavingThrowIncrease(SAVING_THROW_FORT, nSaveFortBonus));
        eBonus = EffectLinkEffects(eBonus, EffectSavingThrowIncrease(SAVING_THROW_WILL, nSaveWillBonus));
        eBonus = EffectLinkEffects(eBonus, EffectTemporaryHitpoints(nHPBonus));
    }

    int nABBonus = GetBaseAttackBonus(oPC) - GetBaseAttackBonus(oFam);
    int nAttacks = (GetBaseAttackBonus(oPC)/5)+1;
    if(nAttacks > 5)
        nAttacks = 5;
    SetBaseAttackBonus(nAttacks, oFam);

    //effect doing
    if(nSRBonus > 0) eBonus = EffectLinkEffects(eBonus, EffectSpellResistanceIncrease(nSRBonus));
    eBonus = EffectLinkEffects(eBonus, EffectAttackIncrease(nABBonus));
    //skills were linked earlier
    eBonus = SupernaturalEffect(eBonus);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eBonus, oFam);
}

void CheckIsValidFamiliar(object oMaster, effect eBonus)
{
    object oFam = GetAssociateNPC(ASSOCIATE_TYPE_FAMILIAR);
    object oFamToken = GetItemPossessedBy(oMaster, "prc_pnp_familiar");

    if(GetIsObjectValid(oFam))
    {
        if(!GetIsDead(oFam))
        {
            DelayCommand(30.0, CheckIsValidFamiliar(oMaster, eBonus));
            return;
        }
    }
    else
    {
        if(GetIsObjectValid(oFamToken))
        {
            DelayCommand(30.0, CheckIsValidFamiliar(oMaster, eBonus));
            return;
        }
    }

    RemoveEffect(oMaster, eBonus);
}

effect GetMasterBonus(int nFamiliarType)
{
    effect eBonus;
    string sFile = "prc_familiar";
    string sTemp = Get2DACache(sFile, "BONUS", nFamiliarType);
    int nParam1 = StringToInt(Get2DACache(sFile, "PARAM1", nFamiliarType));
    int nParam2 = StringToInt(Get2DACache(sFile, "PARAM2", nFamiliarType));

    if(sTemp == "sk")
        eBonus = EffectSkillIncrease(nParam1, nParam2);
    else if(sTemp == "sv")
        eBonus = EffectSavingThrowIncrease(nParam1, nParam2);
    else if(sTemp == "hp")
        eBonus = EffectTemporaryHitpoints(nParam1);

    return eBonus;
}

int GetCompanionBaseDamage(int nLevel, int bBite)
{
    int nBite, nClaw;
    if(nLevel > 35)
    {
        nBite = IP_CONST_MONSTERDAMAGE_2d10;
        nClaw = IP_CONST_MONSTERDAMAGE_1d12;
    }
    else if(nLevel > 26)
    {
        nBite = IP_CONST_MONSTERDAMAGE_2d8;
        nClaw = IP_CONST_MONSTERDAMAGE_1d10;
    }
    else if(nLevel > 18)
    {
        nBite = IP_CONST_MONSTERDAMAGE_2d6;
        nClaw = IP_CONST_MONSTERDAMAGE_1d8;
    }
    else if(nLevel > 11)
    {
        nBite = IP_CONST_MONSTERDAMAGE_1d10;
        nClaw = IP_CONST_MONSTERDAMAGE_1d6;
    }
    else if(nLevel > 5)
    {
        nBite = IP_CONST_MONSTERDAMAGE_1d8;
        nClaw = IP_CONST_MONSTERDAMAGE_1d4;
    }
    else
    {
        nBite = IP_CONST_MONSTERDAMAGE_1d6;
        nClaw = IP_CONST_MONSTERDAMAGE_1d3;
    }

    if(bBite)
        return nBite;

    return nClaw;
}

void SetNaturalWeaponDamage(object oCompanion, int nLvlMod = 0)
{
    int nLevel = GetHitDice(oCompanion);
        nLevel += nLvlMod;
    int Enh = (nLevel - 15) / 5;
    int nDamage;

    //Get the companion's creature weapons
    object oBite = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oCompanion);
    object oLClaw = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oCompanion);
    object oRClaw = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oCompanion);

    //Apply properties to each weapon
    if(GetIsObjectValid(oBite))
    {
        CleanProperties(oBite);
        nDamage = GetCompanionBaseDamage(nLevel, TRUE);
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyMonsterDamage(nDamage), oBite);
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(Enh), oBite);
    }
    if(GetIsObjectValid(oLClaw))
    {
        CleanProperties(oLClaw);
        nDamage = GetCompanionBaseDamage(nLevel, FALSE);
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyMonsterDamage(nDamage), oLClaw);
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(Enh), oLClaw);
    }
    if(GetIsObjectValid(oRClaw))
    {
        CleanProperties(oRClaw);
        nDamage = GetCompanionBaseDamage(nLevel, FALSE);
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyMonsterDamage(nDamage), oRClaw);
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(Enh), oRClaw);
    }
}

void UnsummonCompanions(object oPC)
{
    int i;
    object oAsso;
    for(i = 1; i <= 5; i++)
    {
        oAsso = GetAssociateNPC(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, i);
        if(GetIsObjectValid(oAsso))
            DestroyAssociate(oAsso);
    }
    for(i = 1; i <= 5; i++)
    {
        oAsso = GetAssociateNPC(ASSOCIATE_TYPE_FAMILIAR, oPC, i);
        if(GetIsObjectValid(oAsso))
            DestroyAssociate(oAsso);
    }
}

//:: void main(){}