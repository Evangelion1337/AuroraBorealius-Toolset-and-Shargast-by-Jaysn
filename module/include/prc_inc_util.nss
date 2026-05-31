///////////////////////////////////////////////////////////////////////////////
//  VARIABLE DECLARATIONS
///////////////////////////////////////////////////////////////////////////////

const string PRC_Rest_Generation = "PRC_Rest_Generation";
const string PRC_Rest_Generation_Check = "PRC_Rest_Generation_Check";
const string PRC_ForcedRestDetector_Generation = "PRC_ForcedRestDetector_Generation";

///////////////////////////////////////////////////////////////////////////////
//  INCLUDES
///////////////////////////////////////////////////////////////////////////////

#include "prc_alterations"

///////////////////////////////////////////////////////////////////////////////
//  FUNCTION DECLARATIONS
///////////////////////////////////////////////////////////////////////////////

//:: Returns TRUE is the item is on the Alchemy crafting 2DA.
int GetIsAlchemical(object oItem);

// Returns the number of henchmen a player has.
int GetNumHenchmen(object oPC);

// returns the float time in seconds to close the given distance
float GetTimeToCloseDistance(float fMeters, object oPC, int bIsRunning = FALSE);

/* PRC ForceRest wrapper
 *
 * ForceRest does not trigger the module's OnRest event, nor will the targeted player show up
 * when GetLastPCRested is used. This wrapper can be used to ForceRest a target, while still
 * running the PRC's OnRest script.
 */
void PRCForceRest(object oPC);
void PRCForceRested(object oPC);

///////////////////////////////////////////////////////////////////////////////
//  FUNCTION DEFINITIONS
///////////////////////////////////////////////////////////////////////////////

/**  
 * Returns a perpendicular vector to the input vector  
 * Rotates the vector 90 degrees in the XY plane while preserving Z  
 *   
 * @param vInput The input vector  
 * @return A perpendicular vector  
 */  
vector VectorToPerpendicular(vector vInput)  
{  
    return Vector(-vInput.y, vInput.x, vInput.z);  
}

int GetIsAlchemical(object oItem)  
{  
    if(!GetIsObjectValid(oItem)) return FALSE;  
      
    string sResRef = GetResRef(oItem);  
    int nRows = StringToInt(Get2DACache("prc_craft_alchem", "ResRef", -1));  
      
    // Check if item's ResRef exists in alchemical crafting 2DA
	int i;	
    for(i = 0; i < nRows; i++)  
    {  
        if(sResRef == Get2DACache("prc_craft_alchem", "ResRef", i))  
            return TRUE;  
    }  
      
    return FALSE;  
}

int GetNumHenchmen(object oPC)
{
     if (!GetIsPC(oPC)) return -1;

     int nLoop, nCount;
     for (nLoop = 1; nLoop <= GetMaxHenchmen(); nLoop++)
     {
          if (GetIsObjectValid(GetHenchman(oPC, nLoop)))
          nCount++;
     }

     return nCount;
}

float GetTimeToCloseDistance(float fMeters, object oPC, int bIsRunning = FALSE)
{
     float fTime = 0.0;
     float fSpeed = 0.0;

     int iMoveRate = GetMovementRate(oPC);

     switch(iMoveRate)
     {
          case 0:
               fSpeed = 2.0;
               break;
          case 1:
               fSpeed = 0.0;
               break;
          case 2:
               fSpeed = 0.75;
               break;
          case 3:
               fSpeed = 1.25;
               break;
          case 4:
               fSpeed = 1.75;
               break;
          case 5:
               fSpeed = 2.25;
               break;
          case 6:
               fSpeed = 2.75;
               break;
          case 7:
               fSpeed = 2.0;  // could change to creature default in the appearance.2da.
               break;
          case 8:
               fSpeed = 5.50;
               break;
     }

     // movement speed doubled if running
     if(bIsRunning) fSpeed *= 2.0;

     // other effects that can change movement speed
     if( PRCGetHasEffect(EFFECT_TYPE_HASTE, oPC) ) fSpeed *= 2.0;
     if( PRCGetHasEffect(EFFECT_TYPE_MOVEMENT_SPEED_INCREASE, oPC) ) fSpeed *= 2.0;

     if( PRCGetHasEffect(EFFECT_TYPE_SLOW,  oPC) ) fSpeed /= 2.0;
     if( PRCGetHasEffect(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE,  oPC) ) fSpeed /= 2.0;

     if( GetHasFeat(FEAT_BARBARIAN_ENDURANCE, oPC) ) fSpeed *= 1.1; // 10% gain
     if( GetHasFeat(FEAT_MONK_ENDURANCE, oPC) )
     {
          float fBonus = 0.1 * (GetLevelByClass(CLASS_TYPE_MONK, oPC) / 3 );
          if (fBonus > 0.90) fBonus = 0.9;

          fBonus += 1.0;
          fSpeed *= fBonus;
     }

     // final calculation
     fTime = fMeters / fSpeed;

     return fTime;
}

int PRC_NextGeneration(int nCurrentGeneration)
{
    nCurrentGeneration++;
    if (nCurrentGeneration > 30000) 
        nCurrentGeneration = 1;
    return nCurrentGeneration;
}

//TODO: TRIED THIS CLEANER VERSION AND IT DIDN'T WORK; FIX IT AND USE IT LATER
// effect _prc_inc_ForcedRestDetectorEffect()
// {
//     //Create an extraordinary effect, which is removed only by resting. 
//     //Therefore, if it disappears, we know that resting has happened.
//     return ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_NEUTRAL));
//         //TODO: this could match effects that are not ours. Make it more unique somehow.
// }
// 
// void _prc_inc_ApplyForcedRestDetectorEffect(object oPC)
// {
//     ApplyEffectToObject(DURATION_TYPE_PERMANENT, _prc_inc_ForcedRestDetectorEffect(), oPC);
// }
// 
// int _prc_inc_TestForcedRestDetectorEffect(effect eEffect)
// {
//     effect eTestEffect = _prc_inc_ForcedRestDetectorEffect();
//     return GetEffectType(eEffect) == GetEffectType(eTestEffect) && 
//         GetEffectSubType(eEffect) == GetEffectSubType(eTestEffect) &&
//         GetEffectDurationType(eEffect) == GetEffectDurationType(eTestEffect) && 
//         GetEffectSpellId(eEffect) == -1;
// }

void _prc_inc_ApplyForcedRestDetectorEffect(object oPC)
{
    //Apply an extraordinary effect, which is removed only by resting
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_NEUTRAL)), oPC);
        //TODO: this could match effects that are not ours. Make it more unique somehow.
}

int _prc_inc_TestForcedRestDetectorEffect(effect eEffect)
{
    return GetEffectType(eEffect) == EFFECT_TYPE_VISUALEFFECT && GetEffectSubType(eEffect) == SUBTYPE_EXTRAORDINARY && GetEffectDurationType(eEffect) == DURATION_TYPE_PERMANENT && GetEffectSpellId(eEffect) == -1;
        //TODO: this could match effects that are not ours. Make it more unique somehow.
}

void _prc_inc_ForcedRestDetector(object oPC, int nExpectedGeneration)
{
    int nGeneration = GetLocalInt(oPC, PRC_ForcedRestDetector_Generation);
    if (nGeneration != nExpectedGeneration)
    {
        //There's another forced rest detector running, so stop ourselves and let that one continue
        DoDebug("STOPPING DUPLICATE FORCED REST DETECTOR");
        return;
    }
    nGeneration = PRC_NextGeneration(nGeneration);
    SetLocalInt(oPC, PRC_ForcedRestDetector_Generation, nGeneration);

    int nRestGeneration = GetLocalInt(oPC, PRC_Rest_Generation);
    int nRestGenerationCheck = GetLocalInt(oPC, PRC_Rest_Generation_Check);
    if (nRestGeneration != nRestGenerationCheck)
    {
        //A normal rest happened, and the delayed commands it schedules may still 
        //be executing or waiting to execute, so do nothing and check back later.
        SetLocalInt(oPC, PRC_Rest_Generation_Check, nRestGeneration);
        DelayCommand(10.0f, _prc_inc_ApplyForcedRestDetectorEffect(oPC));
        DelayCommand(10.1f, _prc_inc_ForcedRestDetector(oPC, nGeneration));
    }
    else
    {    
        int bFound = FALSE;
        effect eEffect = GetFirstEffect(oPC);
        while (GetIsEffectValid(eEffect))
        {
            if (_prc_inc_TestForcedRestDetectorEffect(eEffect))
            {
                bFound = TRUE;
                break;
            }
            eEffect = GetNextEffect(oPC);
        }
    
        if (!bFound)
        {
            DoDebug("FORCED REST DETECTED");
            PRCForceRested(oPC); //This executes the normal resting code, which will be detected above the next time this function executes
        }

        //Schedule next check
        DelayCommand(1.0f, _prc_inc_ForcedRestDetector(oPC, nGeneration));
    }
}

void StartForcedRestDetector(object oPC)
{
    //TODO: make a way for the detector to detect that forced rest has already happened, or else do it here now (but how?)
    DoDebug("STARTING FORCED REST DETECTOR");
    _prc_inc_ApplyForcedRestDetectorEffect(oPC);
    SetLocalInt(oPC, PRC_Rest_Generation_Check, GetLocalInt(oPC, PRC_Rest_Generation));
    int nGeneration = GetLocalInt(oPC, PRC_ForcedRestDetector_Generation);
    DelayCommand(1.0f, _prc_inc_ForcedRestDetector(oPC, nGeneration));
}

void PRCForceRest(object oPC)
{
    ForceRest(oPC);
    PRCForceRested(oPC);
}

void PRCForceRested(object oPC)
{
    //The PC has been forced rested--fix the problems this causes.
    SetLocalInt(oPC, "PRC_ForceRested", 1);
    ExecuteScript("prc_rest", oPC);
}

//:: void main (){}