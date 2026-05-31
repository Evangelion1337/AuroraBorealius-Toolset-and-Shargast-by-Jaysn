#include "prc_inc_util"
#include "prc_inc_spells"
#include "prc_inc_function"

// Wrapper function for delayed visual transform with generation tracking  
void DelayedSetVisualTransform(int nExpectedGeneration, object oTarget, int nTransform, float fValue)  
{  
    // Read current generation at execution time, not when scheduled  
    if (nExpectedGeneration != GetLocalInt(oTarget, "PRC_SIZE_GENERATION"))  
    {  
        // Generation has changed, don't apply the transform  
        return;  
    }  
    SetObjectVisualTransform(oTarget, nTransform, fValue);  
}  
  
// Main wrapper function that handles generation tracking  
void DelaySetVisualTransform(float fDelay, object oTarget, string sGenerationName, int nTransform, float fValue)  
{  
    int nExpectedGeneration = GetLocalInt(oTarget, sGenerationName);  
    DelayCommand(fDelay, DelayedSetVisualTransform(nExpectedGeneration, oTarget, nTransform, fValue));  
}  
  
/**  
 * Creates a size change effect that can enlarge or reduce a creature  
 *   
 * @param oTarget     Object to affect  
 * @param nObjectType Object type filter (OBJECT_TYPE_CREATURE, etc.)  
 * @param bEnlarge    TRUE to enlarge, FALSE to reduce  
 * @param nChanges    Number of size categories to change (0 = reset to original)  
 * @return            The size change effect  
 */ 
 
effect EffectSizeChange(object oTarget, int nObjectType, int bEnlarge, int nChanges)  
{  
    effect eBlank;  
      
    // Increment generation for any size change  
    int nGeneration = PRC_NextGeneration(GetLocalInt(oTarget, "PRC_SIZE_GENERATION"));  
    SetLocalInt(oTarget, "PRC_SIZE_GENERATION", nGeneration);  
      
    // Store original size if not already stored - READ ACTUAL CURRENT SCALE  
    if(GetLocalFloat(oTarget, "PRC_ORIGINAL_SIZE") == 0.0f)  
    {  
        float fCurrentScale = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_SCALE);  
        SetLocalFloat(oTarget, "PRC_ORIGINAL_SIZE", fCurrentScale);  
    }  
      
    // Reset to original size  
    if(nChanges == 0)  
    {  
        float fOriginalSize = GetLocalFloat(oTarget, "PRC_ORIGINAL_SIZE");  
        DelaySetVisualTransform(0.0f, oTarget, "PRC_SIZE_GENERATION", OBJECT_VISUAL_TRANSFORM_SCALE, fOriginalSize);  
        // DON'T delete PRC_ORIGINAL_SIZE here - keep it for future casts  
        return eBlank;  
    }  
      
    // Get the original scale  
    float fOriginalScale = GetLocalFloat(oTarget, "PRC_ORIGINAL_SIZE");  
      
    // Calculate scale factor relative to original size  
    float fScale = fOriginalScale;  
    if(bEnlarge)  
        fScale = fOriginalScale * pow(1.5f, IntToFloat(nChanges));  
    else  
        fScale = fOriginalScale * pow(0.5f, IntToFloat(nChanges));  
      
    // Create the effect link with sanctuary VFX  
    effect eReturn = EffectLinkEffects(EffectVisualEffect(VFX_DUR_SANCTUARY),  
                                      EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));  
      
    if(bEnlarge)  
    {  
        eReturn = EffectLinkEffects(eReturn, EffectAttackDecrease(nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectAbilityDecrease(ABILITY_DEXTERITY, 2 * nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectAbilityIncrease(ABILITY_STRENGTH, 2 * nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectACDecrease(nChanges));  
        eReturn = TagEffect(eReturn, "PRC_SIZE_INCREASE");  
    }  
    else  
    {  
        eReturn = EffectLinkEffects(eReturn, EffectAttackIncrease(nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectAbilityIncrease(ABILITY_DEXTERITY, 2 * nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectAbilityDecrease(ABILITY_STRENGTH, 2 * nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectACIncrease(nChanges));  
        eReturn = TagEffect(eReturn, "PRC_SIZE_DECREASE");  
    }  
      
    // Apply visual transform using wrapper  
    DelaySetVisualTransform(0.0f, oTarget, "PRC_SIZE_GENERATION", OBJECT_VISUAL_TRANSFORM_SCALE, fScale);  
      
    return eReturn;  
}




/* effect EffectSizeChange(object oTarget, int nObjectType, int bEnlarge, int nChanges)  
{  
    effect eBlank;  
      
    // Increment generation for any size change  
    int nGeneration = PRC_NextGeneration(GetLocalInt(oTarget, "PRC_SIZE_GENERATION"));  
    SetLocalInt(oTarget, "PRC_SIZE_GENERATION", nGeneration);  
      
    // Store original size if not already stored (fixed check)  
    if(GetLocalFloat(oTarget, "PRC_ORIGINAL_SIZE") == 0.0f)  
    {  
        SetLocalFloat(oTarget, "PRC_ORIGINAL_SIZE", 1.0f);  
    }  
      
    // Reset to original size  
    if(nChanges == 0)  
    {  
        float fOriginalSize = GetLocalFloat(oTarget, "PRC_ORIGINAL_SIZE");  
        DelaySetVisualTransform(0.0f, oTarget, "PRC_SIZE_GENERATION", OBJECT_VISUAL_TRANSFORM_SCALE, fOriginalSize);  
        DeleteLocalFloat(oTarget, "PRC_ORIGINAL_SIZE");  
        return eBlank;  
    }  
      
    // Calculate scale factor using pow() for multi-step changes  
    float fScale = 1.0f;  
    if(bEnlarge)  
        fScale = pow(1.5f, IntToFloat(nChanges)); // 1.5, 2.25, 3.375...  
    else  
        fScale = pow(0.5f, IntToFloat(nChanges)); // 0.5, 0.25, 0.125...  
      
    // Create the effect link based on enlarge/reduce  
    effect eReturn;  
    if(bEnlarge)  
    {  
        eReturn = EffectLinkEffects(EffectAttackDecrease(nChanges),   
                                   EffectAbilityDecrease(ABILITY_DEXTERITY, 2 * nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectAbilityIncrease(ABILITY_STRENGTH, 2 * nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectACDecrease(nChanges));  
        eReturn = TagEffect(eReturn, "PRC_SIZE_INCREASE");  
    }  
    else  
    {  
        eReturn = EffectLinkEffects(EffectAttackIncrease(nChanges),   
                                   EffectAbilityIncrease(ABILITY_DEXTERITY, 2 * nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectAbilityDecrease(ABILITY_STRENGTH, 2 * nChanges));  
        eReturn = EffectLinkEffects(eReturn, EffectACIncrease(nChanges));  
        eReturn = TagEffect(eReturn, "PRC_SIZE_DECREASE");  
    }  
      
    // Apply visual transform using wrapper  
    DelaySetVisualTransform(0.0f, oTarget, "PRC_SIZE_GENERATION", OBJECT_VISUAL_TRANSFORM_SCALE, fScale);  
      
    return eReturn;  
}
 */

//:: void main(){}