//:: New itemproperties
const int ITEM_PROPERTY_USE_LIMITATION_ABILITY_SCORE      = 95;
const int ITEM_PROPERTY_USE_LIMITATION_SKILL_RANKS        = 96;
const int ITEM_PROPERTY_USE_LIMITATION_SPELL_LEVEL        = 88;
const int ITEM_PROPERTY_USE_LIMITATION_ARCANE_SPELL_LEVEL = 89;
const int ITEM_PROPERTY_USE_LIMITATION_DIVINE_SPELL_LEVEL = 90;
const int ITEM_PROPERTY_USE_LIMITATION_SNEAK_ATTACK       = 91;
const int ITEM_PROPERTY_USE_LIMITATION_GENDER             = 150;
const int ITEM_PROPERTY_SPEED_INCREASE                    = 133;
const int ITEM_PROPERTY_SPEED_DECREASE                    = 134;
const int ITEM_PROPERTY_AREA_OF_EFFECT                    = 100;
const int ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL           = 94;
const int ITEM_PROPERTY_CAST_SPELL_METAMAGIC              = 92;
const int ITEM_PROPERTY_CAST_SPELL_DC                     = 93;
const int ITEM_PROPERTY_PNP_HOLY_AVENGER                  = 101;
const int ITEM_PROPERTY_WIZARDRY                          = 102;
const int ITEM_PROPERTY_DIVINITY                          = 103;
const int ITEM_PROPERTY_ECHOBLADE						  = 104;

//:: AoE itemproperties
const int IP_CONST_AOE_DARKNESS             = 0;
const int IP_CONST_AOE_DEEPER_DARKNESS      = 1;
const int IP_CONST_AOE_CIRCLE_VS_EVIL       = 2;
const int IP_CONST_AOE_CIRCLE_VS_GOOD       = 3;
const int IP_CONST_AOE_CIRCLE_VS_LAW        = 4;
const int IP_CONST_AOE_CIRCLE_VS_CHAOS      = 5;
const int IP_CONST_AOE_DAMNING_DARKNESS     = 6;


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

//new function to return a PRC caster level itemproperty
//will putput to log file if it doesnt work
//relys on blueprints containing these itemproperties
itemproperty ItemPropertyCastSpellCasterLevel(int nSpell, int nLevel);

//new function to return a PRC metamagic itemproperty
//will putput to log file if it doesnt work
//relys on blueprints containing these itemproperties
//nMetamagic should be a METAMAGIC_* constant
itemproperty ItemPropertyCastSpellMetamagic(int nSpell, int nMetamagic);

//new function to return a PRC DC itemproperty
//will putput to log file if it doesnt work
//relys on blueprints containing these itemproperties
itemproperty ItemPropertyCastSpellDC(int nSpell, int nDC);

//new function to return a PRC AoE itemproperty
//will putput to log file if it doesnt work
//relys on blueprints containing these itemproperties
//nIPAoEID is defined in iprp_aoe & IP_CONST_AOE_*
itemproperty ItemPropertyAreaOfEffect(int nIPAoEID, int nLevel);

//returns the PRCs new PnP Holy Avenger
//for paladins, +5 +2d6 divine vs evil, castspell:dispel magic @ casterlevel = paladinlevels
//or non paladins, +2
itemproperty ItemPropertyPnPHolyAvenger();

//new function to return a PRC wizardry itemproperty
//will putput to log file if it doesnt work
//relys on blueprints containing these itemproperties
itemproperty ItemPropertyWizardry(int nSpellLevel);

//new function to return a PRC Divinity itemproperty
//will putput to log file if it doesnt work
//relys on blueprints containing these itemproperties
itemproperty ItemPropertyDivinity(int nSpellLevel);

//returns Echoblade itemproperty
itemproperty ItemPropertyEchoblade();

//not implemented
itemproperty ItemPropertyLimitUseByAbility(int nAbility, int nMinScore);
//not implemented
itemproperty ItemPropertyLimitUseBySkill(int nSkill, int nMinScore);
//not implemented
itemproperty ItemPropertyLimitUseBySpellcasting(int nLevel);
//not implemented
itemproperty ItemPropertyLimitUseByArcaneSpellcasting(int nLevel);
//not implemented
itemproperty ItemPropertyLimitUseByDivineSpellcasting(int nLevel);
//not implemented
itemproperty ItemPropertyLimitUseBySneakAttackDice(int nDice);

//////////////////////////////////////////////////
/* Includes                                     */
//////////////////////////////////////////////////

#include "prc_x2_itemprop"
//#include "prc_alterations"


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

itemproperty ItemPropertyCastSpellMetamagic(int nSpell, int nMetamagic)
{
    //convert nSpell into reference to iprip_spells.2da
    nSpell = IPGetIPConstCastSpellFromSpellID(nSpell);

    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_CAST_SPELL_METAMAGIC) + "_" + IntToString(nSpell);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    switch(nMetamagic)
    {
        case METAMAGIC_NONE:
            return ipReturn;//doenst work as an IP
            nMetamagic = 0;
            break;
        case METAMAGIC_EMPOWER:
            nMetamagic = 2;
            break;
        case METAMAGIC_EXTEND:
            nMetamagic = 3;
            break;
        case METAMAGIC_MAXIMIZE:
            nMetamagic = 4;
            break;
        case METAMAGIC_QUICKEN:
            return ipReturn;//doenst work as an IP
            nMetamagic = 1;
            break;
        case METAMAGIC_SILENT:
            return ipReturn;//doenst work as an IP
            nMetamagic = 5;
            break;
        case METAMAGIC_STILL:
            return ipReturn;//doenst work as an IP
            nMetamagic = 6;
            break;
    }
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nMetamagic;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyCastSpellMetamagic "+IntToString(nSpell)+" "+IntToString(nMetamagic)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyCastSpellCasterLevel(int nSpell, int nLevel)
{
    //convert nSpell into reference to iprp_spells.2da
    nSpell = IPGetIPConstCastSpellFromSpellID(nSpell);

    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_CAST_SPELL_CASTER_LEVEL) + "_" + IntToString(nSpell);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nLevel;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyCastSpellCasterLevel "+IntToString(nSpell)+" "+IntToString(nLevel)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyCastSpellDC(int nSpell, int nDC)
{
    //convert nSpell into reference to iprp_spells.2da
    nSpell = IPGetIPConstCastSpellFromSpellID(nSpell);

    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_CAST_SPELL_DC) + "_" + IntToString(nSpell);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nDC;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyCastSpellCasterLevel "+IntToString(nSpell)+" "+IntToString(nDC)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyAreaOfEffect(int nIPAoEID, int nLevel)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_AREA_OF_EFFECT) + "_" + IntToString(nIPAoEID);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nLevel;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyAreaOfEffect "+IntToString(nIPAoEID)+" "+IntToString(nLevel)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyLimitUseByAbility(int nAbility, int nMinScore)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_USE_LIMITATION_ABILITY_SCORE) + "_" + IntToString(nAbility);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nMinScore;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyLimitUseByAbility "+IntToString(nAbility)+" "+IntToString(nMinScore)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyLimitUseBySkill(int nSkill, int nMinScore)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_USE_LIMITATION_SKILL_RANKS) + "_" + IntToString(nSkill);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nMinScore;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyLimitUseBySkill "+IntToString(nSkill)+" "+IntToString(nMinScore)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyLimitUseBySpellcasting(int nLevel)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_USE_LIMITATION_SPELL_LEVEL);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nLevel;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyLimitUseBySpellcasting "+IntToString(nLevel)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyLimitUseByArcaneSpellcasting(int nLevel)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_USE_LIMITATION_ARCANE_SPELL_LEVEL);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nLevel;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyLimitUseByArcaneSpellcasting "+IntToString(nLevel)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyLimitUseByDivineSpellcasting(int nLevel)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_USE_LIMITATION_DIVINE_SPELL_LEVEL);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nLevel;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyLimitUseByDivineSpellcasting "+IntToString(nLevel)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyLimitUseBySneakAttackDice(int nDice)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_USE_LIMITATION_SNEAK_ATTACK);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nDice;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyLimitUseBySneakAttackDice "+IntToString(nDice)+" is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyPnPHolyAvenger()
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_PNP_HOLY_AVENGER);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyPnPHolyAvenger is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyEchoblade()
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_ECHOBLADE);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyEchoblade is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyWizardry(int nSpellLevel)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_WIZARDRY);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nSpellLevel;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyWizardry is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

itemproperty ItemPropertyDivinity(int nSpellLevel)
{
    itemproperty ipReturn;
    string sResRef = "prc_ip" + IntToString(ITEM_PROPERTY_DIVINITY);
    object oChest = GetObjectByTag("HEARTOFCHAOS");//use the crafting chest
    object oItem = CreateItemOnObject(sResRef, oChest);
    DestroyObject(oItem);
    ipReturn = GetFirstItemProperty(oItem);
    int i;
    for(i=0;i<nSpellLevel;i++)
    {
        ipReturn = GetNextItemProperty(oItem);
    }
    if(!GetIsItemPropertyValid(ipReturn))
    {
        string sMessage = "ItemPropertyDivinity is not valid";
        if(GetIsObjectValid(oChest))
            sMessage += "\n oChest is valid.";
        if(GetIsObjectValid(oItem))
            sMessage += "\n oItem is valid.";
        sMessage += "\n sResRef is "+sResRef+".";
        DoDebug(sMessage);
    }
    return ipReturn;
}

// Test main
// void main(){}