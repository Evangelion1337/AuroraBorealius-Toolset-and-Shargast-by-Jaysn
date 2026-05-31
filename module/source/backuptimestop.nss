//::////////////////////////////////////////////////////:://
//:: Invizible420's Alternate Timestop Spell          //:://
//::                                                  //:://
//:: By: Invizible420                                 //:://
//:: (Created 12/20/02 updated 04/23/03 (v 1.07)      //:://
//::////////////////////////////////////////////////////:://
//::                                                  //:://
//:: Persistent World Workaround for Bioware's        //:://
//:: Default Timestop Spell.  This will Decrease      //:://
//:: Attack and Movement Speed, then CutSceneDominate //:://
//:: creatures within a radius of the caster.         //:://
//::                                                  //:://
//::                                                  //:://
//:: Contact info/Bug Reports: Digiddy777@yahoo.com   //:://
//::////////////////////////////////////////////////////:://
#include "prc_inc_spells"
#include "NW_I0_GENERIC"

// Customize User Defined Variables
float fDur   = 15.0; // Duration in seconds
float fDist  = 50.0; // Radius in meters
int iSlow    = 100;  // Percentage to decrease movement by
int iDAttack = 100;  // Amount to decrease attack by



// Function to return the object for GetMaster otherwise return OBJECT_INVALID
// this was made because I do not know if GetMaster returns OBJECT_INVALID
// if no object is found - I would assume it does, but just in case this WILL
object i420_GetMaster(object oAssociate) {
    object oAObj;
    oAObj = OBJECT_INVALID;
    if ((GetMaster(oAssociate) != GetModule()) ||
        (GetMaster(oAssociate) != OBJECT_INVALID)) {
        oAObj = GetMaster(oAssociate);
        }
    return oAObj;
}


// Function to resume creature(s) previous actions wrapped for Delay
void ResumeLast(object oResumee, object oIntruder)
    {
    // Delay DetermineCombatRound
    DelayCommand(fDur+0.25,AssignCommand(oResumee,DetermineCombatRound(oIntruder)));
    }


// Function to resume creature(s) previous actions wrapped for Delay
// this one also readds the creature as a henchman of oMaster
void ResumeLast2(object oResumee, object oIntruder, object oMaster)
    {
    // Return oResumee to the service of oMaster
    AddHenchman(oMaster,oResumee);
    // Delay DetermineCombatRound
    AssignCommand(oResumee,DetermineCombatRound(oIntruder));
    }


// Function to control TimeStop effects
void TSEffects(object oEffector, object oCaster)
    {
    // Check if stopped creature is a hostile
    //if (GetIsReactionTypeHostile(oCaster,oEffector) == TRUE) { // REMOVED

    // Start the resume combat round after Timestop
    ResumeLast(oEffector, oCaster);

    // Decrease the creature(s) attack
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectAttackDecrease(iDAttack,ATTACK_BONUS_MISC),oEffector,fDur);
    // Stop the creature(s) from moving for fDur seconds
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectMovementSpeedDecrease(iSlow),oEffector,fDur);
    // Make module dominate the creature(s) for fDur seconds
    AssignCommand(GetModule(),ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectCutsceneDominated(),oEffector,fDur));
    // Clear the creature(s) action que
    AssignCommand(oEffector,ClearAllActions(TRUE));

    /*  Removed because it's probably not necessary any longer
    // Disable Commandable (actions que)
    SetCommandable(FALSE,oEffector);
    // Enable Commandable after fDur
    DelayCommand(fDur,SetCommandable(TRUE,oEffector));
    */
    }

// Function to control TimeStop effects
void TSEffects2(object oEffector, object oCaster, object oMaster)
    {
    // Check if stopped creature is a hostile

    //if (GetIsReactionTypeHostile(oCaster,oEffector) == TRUE) { // REMOVED

    // Start the resume combat round after Timestop (2 also resets the master)
    DelayCommand(fDur+0.25,ResumeLast2(oEffector, oCaster, oMaster));

    // Decrease the creature(s) attack
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectAttackDecrease(iDAttack,ATTACK_BONUS_MISC),oEffector,fDur);
    // Stop the creature(s) from moving for fDur seconds
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectMovementSpeedDecrease(iSlow),oEffector,fDur);
    // Make module dominate the creature(s) for fDur seconds
    AssignCommand(GetModule(),ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectCutsceneDominated(),oEffector,fDur));
    // Clear the creature(s) action que
    AssignCommand(oEffector,ClearAllActions(TRUE));

    /*  Removed because it's probably not necessary any longer
    // Disable Commandable (actions que)
    SetCommandable(FALSE,oEffector);
    // Enable Commandable after fDur
    DelayCommand(fDur,SetCommandable(TRUE,oEffector));
    */
    }


// Function to get creature(s) within radius and apply the alternate TimeStop
void TimeStop(object oTarget)
    {
    object oNearestC;  // Define nearest creature
    // Begin loop to find all creatures within the fDist meter radius
    oNearestC = GetFirstObjectInShape(SHAPE_SPHERE, fDist, PRCGetSpellTargetLocation(), FALSE, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oNearestC))
         {



           // This makes sure the Caster is not Timestopped and skips any PC's/NPC's associates
           if ((oNearestC != oTarget) &&
               (i420_GetMaster(oNearestC) == OBJECT_INVALID))
            {
            // Start the TimeStop effects (For non-associates)
            DelayCommand(0.75,TSEffects(oNearestC,oTarget));
            }
           // Now if it is an associate -- Get their master for use in the TsEffects2
           if (i420_GetMaster(oNearestC) != OBJECT_INVALID) {
            object oMaster = i420_GetMaster(oNearestC);
             // Start the TimeStop effects (for associates)
            DelayCommand(0.75,TSEffects2(oNearestC,oTarget,oMaster));
            }

         // Get the next creature in the fDist meter radius and continue loop
         oNearestC = GetNextObjectInShape(SHAPE_SPHERE, fDist, PRCGetSpellTargetLocation(), FALSE, OBJECT_TYPE_CREATURE);
         }
    }

// Begin Main Function
void main()
    {
        //Signal event to start the TimeStop
        SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, SPELL_TIME_STOP, FALSE));
        // Begin custom TimeStop
        TimeStop(OBJECT_SELF);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_TIME_STOP), PRCGetSpellTargetLocation());
    }
