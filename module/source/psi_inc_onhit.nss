/*
    Psionic OnHit.
    This scripts holds all functions used for psionics on hit powers and abilities.

    Stratovarius
*/

// Include Files:
#include "psi_inc_psifunc"
//
#include "psi_inc_pwresist"
#include "prc_inc_combat"


// Swings at the target closest to the one hit
void SweepingStrike(object oCaster, object oTarget);

// Shadow Mind 10th level ability. Manifests Cloud Mind
void MindStab(object oPC, object oTarget);

// ---------------
// BEGIN FUNCTIONS
// ---------------
void SweepingStrike(object oCaster, object oTarget)  
{  
    // Prevent multiple sweeping strikes from the same primary target in the same attack sequence  
    string sAttackKey = "SweepingStrike_" + ObjectToString(oCaster) + "_" + ObjectToString(oTarget);  
    if(GetLocalInt(oCaster, sAttackKey))  
        return;  
          
    // Mark this attack sequence as processed  
    SetLocalInt(oCaster, sAttackKey, TRUE);  
    DelayCommand(0.5, DeleteLocalInt(oCaster, sAttackKey));  
      
    // Find valid secondary target  
    location lTarget = GetLocation(oTarget);  
    object oAreaTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget, TRUE, OBJECT_TYPE_CREATURE);  
      
    while(GetIsObjectValid(oAreaTarget))  
    {  
        // Must be different from primary target and within melee range of both  
        if(oAreaTarget != oTarget &&  
           oAreaTarget != oCaster &&  
           GetIsInMeleeRange(oAreaTarget, oCaster) &&  
           GetIsInMeleeRange(oAreaTarget, oTarget) &&  
           GetIsReactionTypeHostile(oAreaTarget, oCaster))  
        {  
            // Perform the sweeping strike attack  
            effect eVis = EffectVisualEffect(VFX_IMP_STUN);  
            object oWeap = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster);  
            PerformAttack(oAreaTarget, oCaster, eVis, 0.0, 0, 0, GetWeaponDamageType(oWeap), "Sweeping Strike Hit", "Sweeping Strike Miss");  
            break; // Only one sweeping strike per primary attack  
        }  
        oAreaTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget, TRUE, OBJECT_TYPE_CREATURE);  
    }  
}


/* void SweepingStrike(object oCaster, object oTarget)
{
    int nValidTarget = FALSE;
    int nRandom = Random(9999);
    location lTarget = GetLocation(oTarget);
    string sRandom = IntToString(nRandom);
    string sTimeStamp = IntToString(GetTimeHour()) + IntToString(GetTimeMinute()) + IntToString(GetTimeSecond()) + IntToString(GetTimeMillisecond());
    string sKillSwitch = "SweepingStrikeDelay" + ObjectToString(oCaster) + sRandom + sTimeStamp;
    // Use the function to get the closest creature as a target
        object oAreaTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oAreaTarget) && !nValidTarget && !GetLocalInt(oCaster, sKillSwitch) && !GetLocalInt(oTarget, "SweepingStrikeTarget"))
        {
            // Don't hit yourself
            // Make sure the target is both next to the one struck and within melee range of the caster
            // Don't hit the one already struck
            if(oAreaTarget != oCaster &&
               GetIsInMeleeRange(oAreaTarget, oCaster) &&
               GetIsInMeleeRange(oAreaTarget, oTarget) &&
               GetIsReactionTypeHostile(oAreaTarget, oCaster) &&
               !GetLocalInt(oTarget, "SweepingStrikeTarget") && //Redundant with while conditionals, but what the heck
               oAreaTarget != oTarget)
                {
                    // Perform the Attack
                    effect eVis = EffectVisualEffect(VFX_IMP_STUN);
                    object oWeap = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster);
                    SetLocalInt(oAreaTarget, "SweepingStrikeTarget", TRUE);
                    DelayCommand(0.2, PerformAttack(oAreaTarget, oCaster, eVis, 0.0, 0, 0, GetWeaponDamageType(oWeap), "Sweeping Strike Hit", "Sweeping Strike Miss"));
                    if(DEBUG) DoDebug("psi_onhit: Sweeping Strike Loop Running");
                    DelayCommand(1.0, DeleteLocalInt(oAreaTarget, "SweepingStrikeTarget"));
                    // End the loop, and prevent the death attack
                    SetLocalInt(oCaster, sKillSwitch, TRUE);
                    nValidTarget = TRUE; //This and the previous line now do the same thing I think
                }

            //Select the next target within the spell shape.
            oAreaTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget, TRUE, OBJECT_TYPE_CREATURE);
        }// end while - Target loop
        DelayCommand(1.0, DeleteLocalInt(oCaster, sKillSwitch));
}
 */
void MindStab(object oPC, object oTarget)
{
    SetLocalInt(oPC, "ShadowCloudMind", TRUE);
    SetLocalObject(oPC, "PsionicTarget", oTarget);
    FloatingTextStringOnCreature("Mind Stab triggered", oPC, FALSE);
    SetLocalInt(oPC, "MindStabDur", TRUE);
    int nClass = GetPrimaryPsionicClass(oPC);
    UsePower(POWER_CLOUD_MIND, nClass);    
    // Trying this for now
    //ActionCastSpell(POWER_CLOUD_MIND);
    DelayCommand(1.0, DeleteLocalInt(oPC, "ShadowCloudMind"));
    DelayCommand(1.0, DeleteLocalObject(oPC, "PsionicTarget"));
    DeleteLocalInt(oPC, "MindStabDur");
    //DelayCommand(0.33, AssignCommand(oPC, ActionAttack(oTarget)));
}

//void main (){}