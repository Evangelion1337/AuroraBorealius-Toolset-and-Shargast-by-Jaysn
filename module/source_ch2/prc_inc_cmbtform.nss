//:://////////////////////////////////////////////
//::	;-.  ,-.   ,-.  ,-. 
//::	|  ) |  ) /    (   )
//::	|-'  |-<  |     ;-: 
//::	|    |  \ \    (   )
//::	'    '  '  `-'  `-' 
//:://////////////////////////////////////////////
//::  
/*
	Library for Combat Form related functions.
	
*/
//::  
//::////////////////////////////////////////////// 
//::	Script:     prc_inc_cmbtform.nss
//::	Author:     Jaysyn
//::	Created:    2026-02-22 12:34:01
//:://////////////////////////////////////////////
#include "prc_feat_const"  
#include "inc_item_props"
#include "inc_eventhook"  
  
const string COMBAT_FOCUS_VAR      = "CombatFocus_Active";  
const string COMBAT_FOCUS_END      = "CombatFocus_EndTime";  
const string COMBAT_FOCUS_ENC      = "CombatFocus_Encounter";  
const string CA_BLIND_VAR          = "CombatAwareness_Blindsight";  
  
void CombatFocus_EndAfterGrace(object oPC);
  
//:: Count Combat Form feats (excluding Combat Focus itself)  
int CountCombatFormFeats(object oPC)  
{  
    int nCount = GetHasFeat(FEAT_COMBAT_AWARENESS, oPC)  
               + GetHasFeat(FEAT_COMBAT_DEFENSE, oPC)  
               + GetHasFeat(FEAT_COMBAT_STABILITY, oPC)  
               + GetHasFeat(FEAT_COMBAT_STRIKE, oPC)  
               + GetHasFeat(FEAT_COMBAT_VIGOR, oPC);  
    return nCount;  
}  

//:; Will save bonus helpers  
void ApplyCombatFocusWillBonus(object oPC)  
{  
    object oSkin = GetPCSkin(oPC);  
    int nForms = CountCombatFormFeats(oPC);  
    int nBonus = (nForms >= 3) ? 4 : 2;  
    SetCompositeBonus(oSkin, "CombatFocus_Will", nBonus,  
                      ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,  
                      IP_CONST_SAVEBASETYPE_WILL);  
}  
  
void RemoveCombatFocusWillBonus(object oPC)  
{  
    object oSkin = GetPCSkin(oPC);  
    SetCompositeBonus(oSkin, "CombatFocus_Will", 0,  
                      ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,  
                      IP_CONST_SAVEBASETYPE_WILL);  
}  

//:: Reset encounter flag  
void CombatFocus_ResetEncounter(object oPC)  
{  
    DeleteLocalInt(oPC, COMBAT_FOCUS_ENC);  
}  

void CombatFocus_CombatEndHeartbeat(object oPC)  
{  
    if (GetIsInCombat(oPC))  
    {  
        DelayCommand(6.0, CombatFocus_CombatEndHeartbeat(oPC));  
    }  
    else  
    {  
        if (GetLocalInt(oPC, COMBAT_FOCUS_VAR))  
        {  
            // Schedule grace period end  
            DelayCommand(6.0, CombatFocus_EndAfterGrace(oPC));  
        }  
        else  
        {  
            // Clear encounter flag if focus not active  
            DeleteLocalInt(oPC, COMBAT_FOCUS_ENC);  
        }  
    }  
}

//:; Combat Stability bonus helpers  
void ApplyCombatStabilityBonus(object oPC)  
{  
    int nForms = CountCombatFormFeats(oPC);  
    int nBonus = (nForms >= 3) ? 8 : 4;  
    SetLocalInt(oPC, "CombatStability_Bonus", nBonus);  
}  
  
void RemoveCombatStabilityBonus(object oPC)  
{  
    DeleteLocalInt(oPC, "CombatStability_Bonus");  
}

//:: Fast healing helpers for Combat Vigor  
void ApplyCombatVigorFastHeal(object oPC)  
{  
    int nForms = CountCombatFormFeats(oPC);  
    int nHeal = (nForms >= 3) ? 4 : 2;  
    effect eRegen = EffectRegenerate(nHeal, 6.0f);  
    eRegen = TagEffect(eRegen, "CombatVor_FastHeal");  
    eRegen = SupernaturalEffect(eRegen);  
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eRegen, oPC);  
    SetLocalInt(oPC, "CombatVigor_Active", TRUE);  
}  
  
void RemoveCombatVigorFastHeal(object oPC)  
{  
    effect eCheck = GetFirstEffect(oPC);  
    while (GetIsEffectValid(eCheck))  
    {  
        if (GetEffectTag(eCheck) == "CombatVor_FastHeal")  
            RemoveEffect(oPC, eCheck);  
        eCheck = GetNextEffect(oPC);  
    }  
    DeleteLocalInt(oPC, "CombatVigor_Active");  
}

//;: Dodge AC helpers for Combat Defense  
void ApplyCombatDefenseAC(object oPC)  
{  
    object oSkin = GetPCSkin(oPC);  
    int nForms = CountCombatFormFeats(oPC);  
    int nBonus = (nForms >= 3) ? 2 : 1;  
    SetCompositeBonus(oSkin, "CombatDefense_AC", nBonus, ITEM_PROPERTY_AC_BONUS);  
    SetLocalInt(oPC, "CombatDefense_Active", TRUE);  
}  
  
void RemoveCombatDefenseAC(object oPC)  
{  
    object oSkin = GetPCSkin(oPC);  
    SetCompositeBonus(oSkin, "CombatDefense_AC", 0, ITEM_PROPERTY_AC_BONUS);  
    DeleteLocalInt(oPC, "CombatDefense_Active");  
}
  
//:: Blindsight helpers for Combat Awareness  
void ApplyCombatAwarenessBlindsight(object oPC)  
{  
    effect eBlind = EffectBonusFeat(FEAT_BLINDSIGHT_5_FEET);  
    eBlind = TagEffect(eBlind, "CombatAwareness_Blindsight");  
    eBlind = SupernaturalEffect(eBlind);  
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eBlind, oPC);  
    SetLocalInt(oPC, CA_BLIND_VAR, TRUE);  
}  
  
void RemoveCombatAwarenessBlindsight(object oPC)  
{  
    effect eCheck = GetFirstEffect(oPC);  
    while (GetIsEffectValid(eCheck))  
    {  
        if (GetEffectTag(eCheck) == "CombatAwareness_Blindsight")  
            RemoveEffect(oPC, eCheck);  
        eCheck = GetNextEffect(oPC);  
    }  
    DeleteLocalInt(oPC, CA_BLIND_VAR);  
}
  
//:: Show HP of adjacent creatures while focus is active  
void ShowAdjacentHP(object oPC)  
{  
    if (!GetLocalInt(oPC, COMBAT_FOCUS_VAR)) return;  
    location lPC = GetLocation(oPC);  
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 5.0f, lPC, FALSE, OBJECT_TYPE_CREATURE);  
    while (GetIsObjectValid(oTarget))  
    {  
        if (oTarget != oPC)  
        {  
            int nHP = GetCurrentHitPoints(oTarget);  
            string sName = GetName(oTarget);  
            FloatingTextStringOnCreature(sName + ": " + IntToString(nHP) + " HP", oPC);  
        }  
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0f, lPC, FALSE, OBJECT_TYPE_CREATURE);  
    }  
}

void CombatFocus_EndAfterGrace(object oPC)  
{  
    // If combat resumed, do nothing  
    if (GetIsInCombat(oPC)) return;  
  
    // Remove effects and clear state  
    RemoveCombatFocusWillBonus(oPC);  
    RemoveCombatAwarenessBlindsight(oPC);  
    RemoveCombatDefenseAC(oPC);  
    RemoveCombatVigorFastHeal(oPC);  
    RemoveCombatStabilityBonus(oPC);  
    DeleteLocalInt(oPC, COMBAT_FOCUS_VAR);  
    DeleteLocalInt(oPC, COMBAT_FOCUS_END);  
    DeleteLocalInt(oPC, COMBAT_FOCUS_ENC);  
    // Unregister heartbeat if it was registered  
    if (GetLocalInt(oPC, "CmbtFocus_HB_Registered"))  
    {  
        RemoveEventScript(oPC, EVENT_ONHEARTBEAT, "prc_combatfocus", TRUE, FALSE);  
        DeleteLocalInt(oPC, "CmbtFocus_HB_Registered");  
    }  
    FloatingTextStringOnCreature("Your Combat Focus fades", oPC);  
}

void CombatFocus_DecayRounds(object oPC)  
{  
    if (!GetLocalInt(oPC, COMBAT_FOCUS_VAR)) return;  
      
    int nRounds = GetLocalInt(oPC, "CombatFocus_RoundsRemaining") - 1;  
    if (nRounds <= 0)  
    {  
        // Expired  
        RemoveCombatFocusWillBonus(oPC);  
        RemoveCombatAwarenessBlindsight(oPC);  
        RemoveCombatDefenseAC(oPC);  
        RemoveCombatVigorFastHeal(oPC);  
        RemoveCombatStabilityBonus(oPC);  
        DeleteLocalInt(oPC, COMBAT_FOCUS_VAR);  
        DeleteLocalInt(oPC, "CombatFocus_RoundsRemaining");  
        // Unregister heartbeat  
        RemoveEventScript(oPC, EVENT_ONHEARTBEAT, "prc_combatfocus", TRUE, FALSE);  
        DeleteLocalInt(oPC, "CmbtFocus_HB_Registered");  
    }  
    else  
    {  
        SetLocalInt(oPC, "CombatFocus_RoundsRemaining", nRounds);  
        // Schedule next decrement in 6 seconds  
        DelayCommand(6.0, CombatFocus_DecayRounds(oPC));  
    }  
}

//:: External call: trigger on first successful attack of an encounter  
void CombatFocus_OnAttackHit(object oPC)  
{  
    if (!GetHasFeat(FEAT_COMBAT_FOCUS, oPC)) return;  
    if (GetLocalInt(oPC, COMBAT_FOCUS_VAR)) return;  
    if (GetLocalInt(oPC, COMBAT_FOCUS_ENC)) return;  
  
    int nDurationRounds = 10 + CountCombatFormFeats(oPC);  
    SetLocalInt(oPC, COMBAT_FOCUS_VAR, TRUE);  
    SetLocalInt(oPC, COMBAT_FOCUS_ENC, TRUE);  
    // Store remaining rounds instead of end timestamp  
    SetLocalInt(oPC, "CombatFocus_RoundsRemaining", nDurationRounds);  
     
    ApplyCombatFocusWillBonus(oPC);  
	
    // Apply Combat Form feat bonuses if possessed. 
    if (GetHasFeat(FEAT_COMBAT_VIGOR, oPC) && !GetLocalInt(oPC, "CombatVigor_Active"))  
        ApplyCombatVigorFastHeal(oPC);  
    if (GetHasFeat(FEAT_COMBAT_AWARENESS, oPC) && !GetLocalInt(oPC, CA_BLIND_VAR))  
        ApplyCombatAwarenessBlindsight(oPC);
    if (GetHasFeat(FEAT_COMBAT_DEFENSE, oPC) && !GetLocalInt(oPC, "CombatDefense_Active"))  
        ApplyCombatDefenseAC(oPC);	
	if (GetHasFeat(FEAT_COMBAT_STABILITY, oPC) && !GetLocalInt(oPC, "CombatStability_Bonus"))  
        ApplyCombatStabilityBonus(oPC);
	
    FloatingTextStringOnCreature("Combat Focus gained", oPC, FALSE);  
}