//::///////////////////////////////////////////////
//:: Name           Template and Weapons of Legacy Include
//:: FileName       prc_inc_template
//:://////////////////////////////////////////////
/*
    This is the main include file for the template system
    Deals with applying templates and interacting with the 2da
    
    This does the above, but for the benefits of Weapons of
    Legacy as well, since they function similarly to templates.
*/
//:://////////////////////////////////////////////
//:: Created By: Primogenitor
//:: Created On: 18/4/06
//:://////////////////////////////////////////////

//void main (){}

//Checks if the target has the template or not.
//returns 1 if it does, 0 if it doesnt or if its an invalid target
int GetHasTemplate(int nTemplate, object oPC = OBJECT_SELF);

//Get total template ECL
int GetTemplateLA(object oPC);

//add a template to the creature
//will not work if it already has the template
//will not work on non-creatures
//if bApply is false, this can test if the template is applicable or not
int ApplyTemplateToObject(int nTemplate, object oPC = OBJECT_SELF, int bApply = TRUE);

int RemoveTemplateFromObject(int nTemplate, object oPC = OBJECT_SELF);

/**
 * Determines whether the PC is a legal target for the weapon of legacy
 * If so, spawns and equips the item, as well as charging them gold for it
 *
 * @param oPC   The new owner of the Weapon of Legacy
 */
int ApplyWoLToObject(int nWoL, object oPC = OBJECT_SELF, int bApply = TRUE);

/**
 * Determines whether the PC has too many hit points and removes them
 * This is a Hit Point Loss penalty applied by weapons of legacy
 *
 * @param oPC   The owner of the Weapon of Legacy
 */
void WoLHealthPenaltyHB(object oPC);

/**
 * Burns one spell per day of the chosen spell level
 * This is a Spell Slot penalty applied by weapons of legacy
 *
 * @param oPC   The owner of the Weapon of Legacy
 * @param nSlot The level of spell to expend
 */
void WoLSpellSlotPenalty(object oPC, int nSlot);

/**
 * Applies the Weapon of Legacy Rituals
 *
 * @param oPC   The owner of the Weapon of Legacy
 */
void UpgradeLegacy(object oPC);

/**
 * Gets uses per day of Legacy abilities
 *
 * @param oPC   The owner of the Weapon of Legacy
 * @param nSLA  The SLA to check
 */
int GetLegacyUses(object oPC, int nSLA);

/**
 * Sets uses per day of Legacy abilities
 *
 * @param oPC   The owner of the Weapon of Legacy
 * @param nSLA  The SLA to set
 */
void SetLegacyUses(object oPC, int nSLA);

/**
 * Clears all uses per day on rest
 *
 * @param oPC   The owner of the Weapon of Legacy
 */
void ClearLegacyUses(object oPC);

#include "prc_inc_function"
#include "prc_template_con"
#include "inc_persist_loca"
#include "prc_inc_burn"

int GetHasTemplate(int nTemplate, object oPC = OBJECT_SELF)
{
    int bHasTemplate = GetPersistantLocalInt(oPC, "template_"+IntToString(nTemplate));
    if(bHasTemplate && DEBUG)
        DoDebug("GetHasTemplate("+IntToString(nTemplate)+", "+GetName(oPC)+") is true");
    return bHasTemplate;
}

int GetTemplateLA(object oPC)
{
    return GetPersistantLocalInt(oPC, "template_LA");
    /*
    //Loop could TMI avoid it
    int nLA;
    //loop over all templates and see if the player has them
    int i;
    for(i=0;i<200;i++)
    {
        if(GetHasTemplate(i, oPC))
            nLA += StringToInt(Get2DACache("templates", "LA", i));
    }
    return nLA;*/
}

int RemoveTemplateFromObject(int nTemplate, object oPC = OBJECT_SELF)
{
	//:: Sanity check
    if(!GetHasTemplate(nTemplate, oPC))
        return FALSE;
	
	//:: Remove the template from the array
    if(persistant_array_exists(oPC, "templates"))
	{
		persistant_array_shrink(oPC, "templates", persistant_array_get_size(oPC, "templates")-nTemplate);
		persistant_array_delete(oPC, "templates");
	}
	
    //:: Delete template's markers
    DeletePersistantLocalInt(oPC, "template_"+IntToString(nTemplate));
	DeletePersistantLocalInt(oPC, "template_LA");
	
	DelayCommand(0.01, EvalPRCFeats(oPC));
	return TRUE;	
}	

int ApplyTemplateToObject(int nTemplate, object oPC = OBJECT_SELF, int bApply = TRUE)
{
    //templates never stack, so dont let them
    if(GetHasTemplate(nTemplate, oPC))
        return FALSE;
        
    //sanity checks
    if(GetObjectType(oPC) != OBJECT_TYPE_CREATURE)
        return FALSE;
    if(nTemplate < 0 || nTemplate > 250)
        return FALSE;
    
    //test if it can be applied
    string sScript = Get2DACache("templates", "TestScript", nTemplate);
    if(sScript != ""
        && ExecuteScriptAndReturnInt(sScript, oPC))
        return FALSE;      
    
    //if not applying it, abort at this point
    if(!bApply)
        return TRUE;
    
    //run the application script
    sScript = Get2DACache("templates", "SetupScript", nTemplate);
    if(sScript != "")
        ExecuteScript(sScript, oPC);
    
    //mark the PC as possessing the template
    SetPersistantLocalInt(oPC, "template_"+IntToString(nTemplate), TRUE);
    //adjust the LA marker accordingly
    if (!(GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oPC) >= 20 && nTemplate == TEMPLATE_LICH))
    {
    	if(DEBUG) DoDebug("ApplyTemplateToObject(): Adding Template LA");
    	SetPersistantLocalInt(oPC, "template_LA", 
        	GetPersistantLocalInt(oPC, "template_LA")+StringToInt(Get2DACache("templates", "LA", nTemplate)));
    }
    //add the template to the array
    if(!persistant_array_exists(oPC, "templates"))
        persistant_array_create(oPC, "templates");
    persistant_array_set_int(oPC, "templates", persistant_array_get_size(oPC, "templates"), nTemplate);    
    
    
    //run the main PRC feat system so we trigger any other feats we've borrowed
    DelayCommand(0.01, EvalPRCFeats(oPC));
    //ExecuteScript("prc_feat", oPC);
    //ran, evaluated, done
    return TRUE;
}

int ApplyWoLToObject(int nWoL, object oPC = OBJECT_SELF, int bApply = TRUE)
{
    //Weapons of Legacy never stack, so dont let them
    if(GetPersistantLocalInt(oPC, "LegacyOwner"))
        return FALSE;
        
    //sanity checks
    if(GetObjectType(oPC) != OBJECT_TYPE_CREATURE)
        return FALSE;
    if(nWoL < 0 || nWoL > 200)
        return FALSE;
    
    //test if it can be applied
    string sScript = Get2DACache("wol_items", "TestScript", nWoL);
    if(sScript != "" && ExecuteScriptAndReturnInt(sScript, oPC))
        return FALSE;  
        
    // Need to be able to pay for it    
    int nGold = StringToInt(Get2DACache("wol_items", "Cost", nWoL));  
    if (nGold > GetGold(oPC))
        return FALSE;
    
    //if not applying the weapon of legacy, abort at this point
    if(!bApply)
        return TRUE;
       
    //mark the PC as possessing a Weapon of Legacy. You only get one, so we store the number
    SetPersistantLocalInt(oPC, "LegacyOwner", nWoL); 
    // Pay for the item, create it and equip it
    TakeGoldFromCreature(nGold, oPC, TRUE);    
    object oWoL = CreateItemOnObject(Get2DACache("wol_items", "ResRef", nWoL), oPC);
    SetIdentified(oWoL, TRUE);
    SetDroppableFlag(oWoL, FALSE);
    SetItemCursedFlag(oWoL, TRUE); 
    AssignCommand(oWoL, SetIsDestroyable(FALSE, FALSE, FALSE));
    SetName(oWoL, GetStringByStrRef(StringToInt(Get2DACache("wol_items", "Name", nWoL))));
    DelayCommand(0.25, AssignCommand(oPC, ActionEquipItem(oWoL, StringToInt(Get2DACache("wol_items", "Slot", nWoL)))));    
    
    // Make the twin
    if (GetTag(oWoL) == "WOL_Devious")
    {
        oWoL = CreateItemOnObject("prc_wol_vicious", oPC);
        SetIdentified(oWoL, TRUE);
        SetDroppableFlag(oWoL, FALSE);
        SetItemCursedFlag(oWoL, TRUE);   
        AssignCommand(oWoL, SetIsDestroyable(FALSE, FALSE, FALSE));
        DelayCommand(0.25, AssignCommand(oPC, ActionEquipItem(oWoL, INVENTORY_SLOT_LEFTHAND)));      
    }    
    
    //run the main PRC feat system so we trigger any other feats we've borrowed
    DelayCommand(0.01, EvalPRCFeats(oPC));
    //ran, evaluated, done
    return TRUE;
}

void WoLHealthPenaltyHB(object oPC)
{
    int nCurHP = GetCurrentHitPoints(oPC);
    int nMaxHP = GetMaxHitPoints(oPC);
    int nPen   = GetLocalInt(oPC, "WoLHealthPenalty");
    
    // Does the PC have too many hit points?    
    if (nCurHP > (nMaxHP - nPen))
    {
        int nDam = nCurHP - (nMaxHP - nPen);
        //if (!GetIsResting(oPC))ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDam, DAMAGE_TYPE_POSITIVE), oPC);
        if (!GetIsResting(oPC)) SetCurrentHitPoints(oPC, nMaxHP - nPen);
    }
    DelayCommand(0.25, WoLHealthPenaltyHB(oPC));
}

void WoLSpellSlotPenalty(object oPC, int nSlot)
{
    if (DEBUG) DoDebug("WoLSpellSlotPenalty nSlot "+IntToString(nSlot));
    if (GetLocalInt(oPC, "WOLSlotBurned")) return; // Already burned for the day

    if (nSlot > 0) 
    {
        SetLocalInt(oPC, "BurnSpellLevel", nSlot);
        BurnSpell(oPC);
        DeleteLocalInt(oPC, "BurnSpellLevel"); 
        SetLocalInt(oPC, "WOLSlotBurned", TRUE);
    }    
}

void UpgradeLegacy(object oPC)
{
    int nLegacy = GetPersistantLocalInt(oPC, "LegacyRitual");
    SetPersistantLocalInt(oPC, "LegacyRitual", nLegacy+1);
    // Apply the feat and the updated abilities
    ExecuteScript("prc_templates", oPC);
}

int GetLegacyUses(object oPC, int nSLA)
{
    // This makes sure everything is stored using the proper number
    return GetLocalInt(oPC, "PRC_WoLUses" + IntToString(nSLA));
}

void SetLegacyUses(object oPC, int nSLA)
{
    // Uses are stored for each SLA by SpellId
    int nNum = GetLocalInt(oPC, "PRC_WoLUses" + IntToString(nSLA));
    // Store the number of times per day its been cast succesfully
    SetLocalInt(oPC, "PRC_WoLUses" + IntToString(nSLA), (nNum + 1));
}

void ClearLegacyUses(object oPC)
{
    // Uses are stored by SpellId
    // So we loop em all and blow em away
    // i is the SpellId
    int i;
    for(i = 16390; i < 16600; i++)
    {
        DeleteLocalInt(oPC, "PRC_WoLUses" + IntToString(i));
    }
    
    // Clear markers on rest
    DeleteLocalInt(oPC, "WOLSlotBurned");
    DeleteLocalInt(oPC, "WoLPsiPointsPenalty");   
    DeleteLocalInt(oPC, "AradrosTHP");  
    DeleteLocalInt(oPC, "WarriorsSurgeUse");       
}

void JumpToEncounterArea(object oPC, int nWoL)
{
	SetLocalLocation(oPC, "EA_Return", GetLocation(oPC));
	CreateArea(Get2DACache("wol_items", "Area", nWoL));
	DelayCommand(1.5, AssignCommand(oPC, JumpToLocation(GetLocation(GetWaypointByTag(Get2DACache("wol_items", "Waypoint", nWoL))))));
}