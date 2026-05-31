//::///////////////////////////////////////////////
//:: Community Patch 1.70 Custom functions related to item properties and shifter
//:: 70_inc_itemprop
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This include file contains new functions used for merging items and other item-based
stuff.

Most of these functions are private, meaning they don't appear in function list because
they are specific for one purpose and not expected to be used outside of that scope.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: ?-11-2010
//:://////////////////////////////////////////////

// returns INVENTORY_SLOT_* constant or -1 if creature haven't item equipped
int GetSlotByItem(object oItem, object oCreature=OBJECT_SELF);


int GetSlotByItem(object oItem, object oCreature=OBJECT_SELF)
{
int nTh;
 for(;nTh < NUM_INVENTORY_SLOTS;nTh++)
 {
  if(GetItemInSlot(nTh,oCreature) == oItem)
  {
  return nTh;
  }
 }
return -1;
}

//private function for shifter polymorp and con bonus issue
int IPGetBestConBonus(int bestCon, object oItem)
{
    int nCon;
    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip))
    {
        if(GetItemPropertyType(ip) == ITEM_PROPERTY_ABILITY_BONUS && GetItemPropertySubType(ip) == IP_CONST_ABILITY_CON)
        {
            nCon = GetItemPropertyCostTableValue(ip);
            if(nCon > bestCon)
            {
                bestCon = nCon;
            }
        }
        ip = GetNextItemProperty(oItem);
    }
    return bestCon;
}

//private function for new way to handle ability bonuses when polymorphing
void IPWildShapeStackAbilityBonuses(object oArmorNew)
{
    int STR,CHA,INT,DEX,CON,WIS,nBonus;
    itemproperty ip = GetFirstItemProperty(oArmorNew);
    while (GetIsItemPropertyValid(ip))
    {
        switch(GetItemPropertyType(ip))
        {
        case ITEM_PROPERTY_ABILITY_BONUS:
            nBonus = GetItemPropertyCostTableValue(ip);
            switch(GetItemPropertySubType(ip))
            {
            case IP_CONST_ABILITY_CON:
                CON+= nBonus;
            break;
            case IP_CONST_ABILITY_DEX:
                DEX+= nBonus;
            break;
            case IP_CONST_ABILITY_CHA:
                CHA+= nBonus;
            break;
            case IP_CONST_ABILITY_INT:
                INT+= nBonus;
            break;
            case IP_CONST_ABILITY_STR:
                STR+= nBonus;
            break;
            case IP_CONST_ABILITY_WIS:
                WIS+= nBonus;
            break;
            }
            RemoveItemProperty(oArmorNew,ip);
        break;
        case ITEM_PROPERTY_DECREASED_ABILITY_SCORE:
            nBonus = GetItemPropertyCostTableValue(ip);
            switch(GetItemPropertySubType(ip))
            {
            case IP_CONST_ABILITY_CON:
                CON-= nBonus;
            break;
            case IP_CONST_ABILITY_DEX:
                DEX-= nBonus;
            break;
            case IP_CONST_ABILITY_CHA:
                CHA-= nBonus;
            break;
            case IP_CONST_ABILITY_INT:
                INT-= nBonus;
            break;
            case IP_CONST_ABILITY_STR:
                STR-= nBonus;
            break;
            case IP_CONST_ABILITY_WIS:
                WIS-= nBonus;
            break;
            }
            RemoveItemProperty(oArmorNew,ip);
        break;
        }
        ip = GetNextItemProperty(oArmorNew);
    }
    if(DEX > 0)
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyAbilityBonus(IP_CONST_ABILITY_DEX,DEX > 12 ? 12 : DEX),oArmorNew);
    }
    if(CHA > 0)
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA,CHA > 12 ? 12 : CHA),oArmorNew);
    }
    if(INT > 0)
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyAbilityBonus(IP_CONST_ABILITY_INT,INT > 12 ? 12 : INT),oArmorNew);
    }
    if(STR > 0)
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR,STR > 12 ? 12 : STR),oArmorNew);
    }
    if(WIS > 0)
    {
        AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyAbilityBonus(IP_CONST_ABILITY_WIS,WIS > 12 ? 12 : WIS),oArmorNew);
    }
}



void ApplyWounding_continue(object oItem, int nNum, int nSlot)
{
object oPC = GetItemPossessor(oItem);
 if(GetItemInSlot(nSlot,oPC) == oItem)
 {
  if(!GetIsResting(oPC) && !GetIsDead(oPC))
  {
  AssignCommand(oItem,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(nNum,DAMAGE_TYPE_MAGICAL),oPC));
  }
 DelayCommand(6.0,ApplyWounding_continue(oItem,nNum,nSlot));
 }
 else
 {
 SetLocalInt(GetModule(),ObjectToString(oItem)+ObjectToString(OBJECT_SELF),FALSE);
 }
}

//1.71: private function to handle wounding itemproperty
void ApplyWounding(object oItem, object oPC, int nNum)
{
int nSlot = GetSlotByItem(oItem,oPC);
 if(nSlot > -1 && !GetLocalInt(GetModule(),ObjectToString(oItem)+ObjectToString(oPC)))
 {
 SetLocalInt(GetModule(),ObjectToString(oItem)+ObjectToString(oPC),TRUE);
 AssignCommand(oPC,DelayCommand(6.0,ApplyWounding_continue(oItem,nNum,nSlot)));
 }
}
