//::///////////////////////////////////////////////
//:: Scrying include
//:: prc_inc_scry
//::///////////////////////////////////////////////
/** @file
    This include contains all of the code that is used
    to scry. At the moment, this is the basic scrying
    and will be expanded with the additional material
    as coding goes along. This is based on the code
    of the Baelnorn Project written by Ornedan.

    All the operations work only on PCs, as there is no
    AI that could have NPCs take any advantage of the
    system.
*/
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:: Created On: 30.04.2007
//:://////////////////////////////////////////////

#include "psi_inc_psifunc"
#include "inc_utility"
#include "true_utter_const"
#include "shd_myst_const"

///////////////////////
/* Public Constants  */
///////////////////////

const string COPY_LOCAL_NAME             = "Scry_Copy";
const string ALREADY_IMMORTAL_LOCAL_NAME = "Scry_ImmortalAlready";
const float  SCRY_HB_DELAY         = 1.0f;

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * ONLY CALL THIS FUNCTION
 * Does all of the necessary set up for scrying
 * Also checks for all of the anti-scrying features
 * if oPC == oTarget, will use PRCGetSpellLocation 
 * as the location for the effects to begin
 *
 * @param oPC     The PC on whom to operate.
 * @param oTarget The object to target
 */
void ScryMain(object oPC, object oTarget);

/**
 * Moves all of the PC's items to the copy creature
 * Switches locations of the two creatures
 *
 * @param oPC     The PC on whom to operate.
 * @param oCopy   The copy of the PC
 */
void DoScryBegin(object oPC, object oCopy);

/**
 * Undoes all the effects of DoScryBegin
 *
 * @param oPC   The PC on whom to operate.
 * @param oCopy The copy of the PC
 */
void DoScryEnd(object oPC, object oCopy);

/**
 * Runs tests to see if the Scry effect can still continue.
 * If the copy is dead, end Scry and kill the PC.
 *
 * @param oPC   The PC on whom to operate.
 * @param oCopy The copy of the PC
 */
void ScryMonitor(object oPC, object oCopy);

/**
 * Reverses ApplyScryEffects
 *
 * @param oPC   The PC on whom to operate.
 */
void RemoveScryEffects(object oPC);

/**
 * Checks whether the PC is scrying or not
 *
 * @param oPC   The PC on whom to operate.
 */
int GetIsScrying(object oPC);

/**
 * Does the Discern Location content
 *
 * @param oPC     The PC on whom to operate.
 * @param oTarget The spell Target
 */
void DiscernLocation(object oPC, object oTarget);

/**
 * Does the Locate Creature and Object content
 *
 * @param oPC     The PC on whom to operate.
 * @param oTarget The spell Target
 */
void LocateCreatureOrObject(object oPC, object oTarget);

/**
 * Prevents the copy from dropping goods when dead.
 *
 * @param oImage  The PC's copy.
 */
void CleanCopy(object oImage);

//////////////////////////////////////////////////
/* Function definitions                         */
//////////////////////////////////////////////////

void ScryMain(object oPC, object oTarget)
{
    // Get the main variables used.
    object oCopy     = GetLocalObject(oPC, COPY_LOCAL_NAME);
    effect eLight    = EffectVisualEffect(VFX_IMP_HEALING_X , FALSE);
    effect eGlow     = EffectVisualEffect(VFX_DUR_ETHEREAL_VISAGE, FALSE);
    // Use prestored variables because of time delay
    int nCasterLevel = GetLocalInt(oPC, "ScryCasterLevel");
    int nSpell       = PRCGetSpellId(); //GetLocalInt(oPC, "ScrySpellId");
    int nDC          = GetLocalInt(oPC, "ScrySpellDC");
    float fDur       = GetLocalFloat(oPC, "ScryDuration");
    if(DEBUG) DoDebug("prc_inc_scry: Beginning ScryMain. nSpell: " + IntToString(nSpell));

    if (oPC != oTarget) // No hitting yourself with defenses
    {
        if(GetHasSpellEffect(POWER_REMOTE_VIEW_TRAP, oTarget))
        {
            effect eVis  = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
            // Failed Save
            if(!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_NONE)) 
            {
                FloatingTextStringOnCreature("You have been caught in a Remote View Trap", oPC, FALSE);
                eVis = EffectLinkEffects(eVis, EffectDamage(d6(8), DAMAGE_TYPE_ELECTRICAL));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                return;
            }
            else
            {
                FloatingTextStringOnCreature("You have saved against a Remote View Trap", oPC, FALSE);
                eVis = EffectLinkEffects(eVis, EffectDamage(d6(4), DAMAGE_TYPE_ELECTRICAL));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
        }
        if(GetHasSpellEffect(SPELL_SEQUESTER, oTarget) || GetHasSpellEffect(POWER_SEQUESTER, oTarget))
        {
            // Spell auto-fails if this is the case
            FloatingTextStringOnCreature(GetName(oTarget) + " has been Sequestered.", oPC, FALSE);
            return;
        }
        if(GetHasSpellEffect(SPELL_OBSCURE_OBJECT, oTarget))
        {
            // Spell auto-fails if this is the case
            FloatingTextStringOnCreature(GetName(oTarget) + " has been Obscured.", oPC, FALSE);
            return;
        }
		if(GetHasSpellEffect(SPELL_NONDETECTION, oTarget) || GetLevelByClass(CLASS_TYPE_WILD_MAGE, oTarget) >= 6 || GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oTarget) >= 5 || GetHasSpellEffect(MELD_ENIGMA_HELM, oTarget) || GetRacialType(oTarget) == RACIAL_TYPE_SKULK)   
		{  
			// Caster level check or the Divination fails.  
			int nTarget = PRCGetCasterLevel(oTarget) + 11;  
			if (GetRacialType(oTarget) == RACIAL_TYPE_SKULK) nTarget = 20;  
			if(nTarget > nCasterLevel + d20())  
			{  
				FloatingTextStringOnCreature(GetName(oTarget) + " has Nondetection active.", oPC, FALSE);  
				return;  
			}  
		}
        if(GetHasSpellEffect(POWER_ESCAPE_DETECTION, oTarget))
        {
            // Caster level check or the Divination fails.
            // Max of 10
            if(PRCMax(10, GetManifesterLevel(oTarget)) + 13 > nCasterLevel + d20())
            {
                FloatingTextStringOnCreature(GetName(oTarget) + " has Escape Detection active.", oPC, FALSE);
                return;
            }
        }
        if(GetHasSpellEffect(POWER_DETECT_REMOTE_VIEWING, oTarget))
        {
            // Caster level check for the target to learn where the caster is
            if(GetManifesterLevel(oTarget) + d20() >= nCasterLevel + d20())
            {
                FloatingTextStringOnCreature(GetName(oPC) + " is viewing you from " + GetName(GetArea(oPC)), oTarget, FALSE);
            }
        }
    }
    // Discern Location skips all of this
    if(nSpell == SPELL_DISCERN_LOCATION)
    {
        DiscernLocation(oPC, oTarget);
        return;
    }
    // So do the Locate Twins
    if(nSpell == SPELL_LOCATE_CREATURE || nSpell == SPELL_LOCATE_OBJECT || nSpell == MYST_TRAIL_OF_HAZE)
    {
        LocateCreatureOrObject(oPC, oTarget);
        return;
    }

    if(nSpell != SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE && nSpell != POWER_CLAIRTANGENT_HAND && nSpell != SPELL_PNP_SCRY_FAMILIAR
    && nSpell != POWER_CLAIRVOYANT_SENSE && nSpell != TRUE_SEE_THE_NAMED && oPC != oTarget) // No save if you target yourself.
    {
        //Make SR Check
        if(PRCDoResistSpell(oPC, oTarget, nCasterLevel))
        {
            FloatingTextStringOnCreature(GetName(oTarget) + " made Spell Resistance check vs Scrying", oPC, FALSE);
            DoScryEnd(oPC, oCopy);
            return;
        }
        //Save
        if(PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS))
        {
            FloatingTextStringOnCreature(GetName(oTarget) + " saved vs Scrying", oPC, FALSE);
            DoScryEnd(oPC, oCopy);
            return;
        }
    }

    if(DEBUG) DoDebug("prc_inc_scry running.\n"
                    + "oPC = '" + GetName(oPC) + "' - '" + GetTag(oPC) + "' - " + ObjectToString(oPC)
                    + "Copy exists: " + DebugBool2String(GetIsObjectValid(oCopy))
                      );
    
    location lTarget = GetLocation(oTarget);
    if (oTarget == oPC || !GetIsObjectValid(oTarget)) // Some spells just target ground for this
        lTarget = PRCGetSpellTargetLocation();
    // Create the copy
    oCopy = CopyObject(oPC, lTarget, OBJECT_INVALID, GetName(oPC) + "_" + COPY_LOCAL_NAME);
    CleanCopy(oCopy);
    
	// Attempted Fix to the Copy get's murdered problem.   
	//int nMaxHenchmen = GetMaxHenchmen();    
	//SetMaxHenchmen(99);    
	//AddHenchman(oPC, oCopy);    
	//SetMaxHenchmen(nMaxHenchmen);    
	
    SetIsTemporaryFriend(oPC, oCopy, FALSE);
    // Set the copy to be undestroyable, so that it won't vanish to the ether
    // along with the PC's items.
    AssignCommand(oCopy, SetIsDestroyable(FALSE, FALSE, FALSE));
    // Make the copy immobile and minimize the AI on it
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ExtraordinaryEffect(EffectCutsceneImmobilize()), oCopy);
    SetAILevel(oCopy, AI_LEVEL_VERY_LOW);

    // Store a referece to the copy on the PC
    SetLocalObject(oPC, COPY_LOCAL_NAME, oCopy);

    //Set Immortal flag on the PC or if they were already immortal,
    //leave a note about it on them.
    if(GetImmortal(oPC))
    {
        if(DEBUG) DoDebug("prc_inc_scry: The PC was already immortal");
        SetLocalInt(oPC, ALREADY_IMMORTAL_LOCAL_NAME, TRUE);
    }
    else
    {
        if(DEBUG) DoDebug("prc_inc_scry: Setting PC immortal");
        SetImmortal(oPC, TRUE);
        DeleteLocalInt(oPC, ALREADY_IMMORTAL_LOCAL_NAME); // Paranoia
    }

    // Do VFX on PC and copy
    SPApplyEffectToObject(DURATION_TYPE_INSTANT, eLight, oCopy);
    SPApplyEffectToObject(DURATION_TYPE_INSTANT, eLight, oPC);

    // Do the switching around
    DoScryBegin(oPC, oCopy);

    //Set up duration marker for ending effect
    DelayCommand(fDur, SetLocalInt(oPC, "SCRY_EXPIRED", 1));
}

// Moves the PC's items to the copy and switches their locations around
void DoScryBegin(object oPC, object oCopy)
{
    if(DEBUG) DoDebug("prc_inc_scry: DoScryBegin():\n"
                    + "oPC = '" + GetName(oPC) + "'\n"
                    + "oCopy = '" + GetName(oCopy) + "'"
                      );
    // Make sure both objects are valid
    if(!GetIsObjectValid(oCopy) || !GetIsObjectValid(oPC)){
        if(DEBUG) DoDebug("DoScryBegin called, but one of the parameters wasn't a valid object. Object status:" +
                          "\nPC - " + (GetIsObjectValid(oPC) ? "valid":"invalid") +
                          "\nCopy - " + (GetIsObjectValid(oCopy) ? "valid":"invalid")
                          );

        // Some cleanup before aborting
        if(!GetLocalInt(oPC, ALREADY_IMMORTAL_LOCAL_NAME))
        {
            SetImmortal(oPC, FALSE);
            DeleteLocalInt(oPC, ALREADY_IMMORTAL_LOCAL_NAME);
        }
        MyDestroyObject(oCopy);
        DeleteLocalInt(oPC, "Scry_Active");
        RemoveScryEffects(oPC);

        return;
    }

    // Set a local on the PC telling that it's a scry. This is used
    // to keep the PC from picking up or losing objects.
    // Also stops it from casting spells
    SetLocalInt(oPC, "Scry_Active", TRUE);

    // Start a pseudo-hb to monitor the status of both PC and copy
    DelayCommand(SCRY_HB_DELAY, ScryMonitor(oPC, oCopy));

    // Add eventhooks
    
    if(DEBUG) DoDebug("AddEventScripts");
    
    AddEventScript(oPC, EVENT_ONPLAYEREQUIPITEM,    "prc_scry_event", TRUE, FALSE); // OnEquip
    AddEventScript(oPC, EVENT_ONACQUIREITEM,        "prc_scry_event", TRUE, FALSE); // OnAcquire
    AddEventScript(oPC, EVENT_ONPLAYERREST_STARTED, "prc_scry_event", FALSE, FALSE); // OnRest
    AddEventScript(oPC, EVENT_ONCLIENTENTER,        "prc_scry_event", TRUE, FALSE); //OnClientEnter
    
    // Adjust reputation so the target monster doesn't attack you
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectCharmed()), oTarget, GetLocalFloat(oPC, "ScryDuration"));
    // Swap the copy and PC
    location lPC   = GetLocation(oPC);
    location lCopy = GetLocation(oCopy);
    DelayCommand(1.5f,AssignCommand(oPC, JumpToLocation(lCopy)));
    DelayCommand(1.5f,AssignCommand(oCopy, JumpToLocation(lPC)));
}

// Switches the PC's inventory back from the copy and returns the PC to the copy's location.
void DoScryEnd(object oPC, object oCopy)
{
    if(DEBUG) DoDebug("prc_inc_scry: DoScryEnd():\n"
                    + "oPC = '" + GetName(oPC) + "'\n"
                    + "oCopy = '" + GetName(oCopy) + "'"
                      );

    //effect eGlow     = EffectVisualEffect(VFX_DUR_ETHEREAL_VISAGE, FALSE);
    effect eLight; // = EffectVisualEffect(VFX_IMP_HEALING_X , FALSE);
    
    // Remove Immortality from the PC if necessary
    if(!GetLocalInt(oPC, ALREADY_IMMORTAL_LOCAL_NAME))
        SetImmortal(oPC, FALSE);

    // Remove the VFX and the attack penalty from all spells.
    PRCRemoveSpellEffects(SPELL_SCRY             , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_GREATER_SCRYING  , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_DISCERN_LOCATION , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_LOCATE_CREATURE  , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_LOCATE_OBJECT    , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_ARCANE_EYE       , oPC, oPC);
    PRCRemoveSpellEffects(MYST_BEND_PERSPECTIVE  , oPC, oPC);
    PRCRemoveSpellEffects(MYST_FAR_SIGHT         , oPC, oPC);
    PRCRemoveSpellEffects(MYST_EPHEMERAL_IMAGE   , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_SHADOWDOUBLE     , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_OBSCURE_OBJECT   , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_SEQUESTER        , oPC, oPC);
    PRCRemoveSpellEffects(SPELL_PNP_SCRY_FAMILIAR, oPC, oPC);
    PRCRemoveSpellEffects(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, oPC, oPC);
	PRCRemoveSpellEffects(POWER_CLAIRTANGENT_HAND, oPC, oPC);
	
    // Remove the local signifying that the PC is a projection
    DeleteLocalInt(oPC, "Scry_Active");

    // Remove the local signifying projection being terminated by an external cause
    DeleteLocalInt(oPC, "Scry_Abort");

    // Remove the heartbeat HP tracking local
    DeleteLocalInt(oPC, "Scry_HB_HP");
    // Delete all of the marker ints for the spell
    DeleteLocalInt(oPC, "ScryCasterLevel");
    DeleteLocalInt(oPC, "ScrySpellId");
    DeleteLocalInt(oPC, "ScrySpellDC");
    DeleteLocalFloat(oPC, "ScryDuration");

    // Remove weapons nerfing
    RemoveScryEffects(oPC);

    // Remove eventhooks
    RemoveEventScript(oPC, EVENT_ONPLAYEREQUIPITEM,    "prc_scry_event", TRUE, FALSE); // OnEquip
    RemoveEventScript(oPC, EVENT_ONACQUIREITEM,        "prc_scry_event", TRUE, FALSE); // OnAcquire
    RemoveEventScript(oPC, EVENT_ONPLAYERREST_STARTED, "prc_scry_event", FALSE, FALSE); // OnRest
    RemoveEventScript(oPC, EVENT_ONCLIENTENTER,        "prc_scry_event", TRUE, FALSE); //OnClientEnter

    // Move PC and inventory
    location lCopy = GetLocation(oCopy);
    DelayCommand(1.5f, AssignCommand(oPC, JumpToLocation(lCopy)));

    // Set the PC's hitpoints to be whatever the copy has
    int nOffset = GetCurrentHitPoints(oCopy) - GetCurrentHitPoints(oPC);
    if(nOffset > 0)
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nOffset), oPC);
    else if (nOffset < 0)
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(-nOffset, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY), oPC);

    // Schedule deletion of the copy
    DelayCommand(0.3f, MyDestroyObject(oCopy));

    //Delete the object reference
    DeleteLocalObject(oPC, COPY_LOCAL_NAME);

    // VFX
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eLight, lCopy, 3.0);
    //DestroyObject(oCopy);
    
    //Remove duration marker
    DeleteLocalInt(oPC, "SCRY_EXPIRED");
}

//Runs tests to see if the projection effect can still continue.
//If the PC has reached 1 HP, end projection normally.
//If the copy is dead, end projection and kill the PC.
void ScryMonitor(object oPC, object oCopy)  
{  
    if(DEBUG) DoDebug("prc_inc_scry: ScryMonitor():\n"  
                    + "oPC = '" + GetName(oPC) + "'\n"  
                    + "oCopy = '" + GetName(oCopy) + "'"  
                      );  
                        
    // Abort if the projection is no longer marked as being active  
    if(!GetLocalInt(oPC, "Scry_Active"))  
        return;  
  
    // Some paranoia in case something interfered and either PC or copy has been destroyed  
    if(!(GetIsObjectValid(oPC) && GetIsObjectValid(oCopy))){  
        WriteTimestampedLogEntry("Baelnorn Projection hearbeat aborting due to an invalid object. Object status:" +  
                                 "\nPC - " + (GetIsObjectValid(oPC) ? "valid":"invalid") +  
                                 "\nCopy - " + (GetIsObjectValid(oCopy) ? "valid":"invalid"));  
        return;  
    }  
  
    // Start the actual work by checking the copy's status. The death thing should take priority  
    if(GetIsDead(oCopy))  
    {  
        if (DEBUG) DoDebug("prc_inc_scry: Copy is dead, killing PC");  
        DoScryEnd(oPC, oCopy);  
        effect eKill = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);  
        DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oPC));  
    }  
    else  
    {  
        // Check if the "projection" has been destroyed or if some other event has caused the projection to end  
        if(GetLocalInt(oPC, "Scry_Abort"))  
        {  
            if(DEBUG) DoDebug("prc_inc_scry: ScryMonitor(): The Projection has been terminated, ending projection");  
            DoScryEnd(oPC, oCopy);  
        }  
        else  
        {  
            // This makes sure you are invisible.  
            //AssignCommand(oPC, ClearAllActions(TRUE));  
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectEthereal()), oPC, SCRY_HB_DELAY + 0.3);  
            DelayCommand(SCRY_HB_DELAY, ScryMonitor(oPC, oCopy));  
        }  
          
        // Skip destructive cleanup triggers for Clairtangent Hand  
        if(GetLocalInt(oPC, "ScrySpellId") != POWER_CLAIRTANGENT_HAND)  
        {  
            //If duration expired, end effect  
            if(GetLocalInt(oPC, "SCRY_EXPIRED"))  
            {  
                DoScryEnd(oPC, oCopy);  
            }  
            // End due to being in combat, except for ephemeral image  
            if(GetIsInCombat(oPC) && GetLocalInt(oPC, "ScrySpellId") != MYST_EPHEMERAL_IMAGE)  
            {  
                DoScryEnd(oPC, oCopy);  
                if(DEBUG) DoDebug("prc_inc_scry: ScryMonitor(): Scryer in combat, ending projection");  
                AssignCommand(oPC, ClearAllActions(TRUE));  
            }  
            // In PnP, once you lose line of effect, the spell ends  
            float fDistance = FeetToMeters(100.0 + GetLocalInt(oPC, "ScryCasterLevel") * 10.0);  
            if (GetLocalInt(oPC, "ScrySpellId") == MYST_EPHEMERAL_IMAGE && GetDistanceBetween(oPC, oCopy) > fDistance)  
            {  
                DoScryEnd(oPC, oCopy);  
                if(DEBUG) DoDebug("prc_inc_scry: ScryMonitor(): Ephemeral Image distance exceeded, ending projection");  
                AssignCommand(oPC, ClearAllActions(TRUE));              
            }  
        }  
    }  
}


/* void ScryMonitor(object oPC, object oCopy)
{

	if(DEBUG) DoDebug("prc_inc_scry: ScryMonitor():\n"
                    + "oPC = '" + GetName(oPC) + "'\n"
                    + "oCopy = '" + GetName(oCopy) + "'"
                      );
					  
	// Skip automatic cleanup for Clairtangent Hand  
	if(GetLocalInt(oPC, "ScrySpellId") == POWER_CLAIRTANGENT_HAND)  
	{  
		// Only apply ethereal effect and reschedule  
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectEthereal()), oPC, SCRY_HB_DELAY + 0.3);  
		DelayCommand(SCRY_HB_DELAY, ScryMonitor(oPC, oCopy));  
		return;  
	}
					  
    // Abort if the projection is no longer marked as being active
    if(!GetLocalInt(oPC, "Scry_Active"))
        return;

    // Some paranoia in case something interfered and either PC or copy has been destroyed
    if(!(GetIsObjectValid(oPC) && GetIsObjectValid(oCopy))){
        WriteTimestampedLogEntry("Baelnorn Projection hearbeat aborting due to an invalid object. Object status:" +
                                 "\nPC - " + (GetIsObjectValid(oPC) ? "valid":"invalid") +
                                 "\nCopy - " + (GetIsObjectValid(oCopy) ? "valid":"invalid"));
        return;
    }

    // Start the actual work by checking the copy's status. The death thing should take priority
    if(GetIsDead(oCopy))
    {
        if (DEBUG) DoDebug("prc_inc_scry: Copy is dead, killing PC");
        DoScryEnd(oPC, oCopy);
        effect eKill = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
        DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oPC));
    }
    else
    {
        // Check if the "projection" has been destroyed or if some other event has caused the projection to end
        if(GetLocalInt(oPC, "Scry_Abort"))
        {
            if(DEBUG) DoDebug("prc_inc_scry: ScryMonitor(): The Projection has been terminated, ending projection");
            DoScryEnd(oPC, oCopy);
        }
        else
        {
            // This makes sure you are invisible.
            //AssignCommand(oPC, ClearAllActions(TRUE));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectEthereal()), oPC, SCRY_HB_DELAY + 0.3);
            DelayCommand(SCRY_HB_DELAY, ScryMonitor(oPC, oCopy));
        }
        
        //If duration expired, end effect
        if(GetLocalInt(oPC, "SCRY_EXPIRED"))
        {
            DoScryEnd(oPC, oCopy);
        }
        // End due to being in combat, except when ephemeral image
        if(GetIsInCombat(oPC) && GetLocalInt(oPC, "ScrySpellId") != MYST_EPHEMERAL_IMAGE)
        {
            DoScryEnd(oPC, oCopy);
            if(DEBUG) DoDebug("prc_inc_scry: ScryMonitor(): Scryer in combat, ending projection");
            AssignCommand(oPC, ClearAllActions(TRUE));
        }
        // In PnP, once you lose line of effect, the spell ends
        float fDistance = FeetToMeters(100.0 + GetLocalInt(oPC, "ScryCasterLevel") * 10.0);
        if (GetLocalInt(oPC, "ScrySpellId") == MYST_EPHEMERAL_IMAGE && GetDistanceBetween(oPC, oCopy) > fDistance)
        {
            DoScryEnd(oPC, oCopy);
            if(DEBUG) DoDebug("prc_inc_scry: ScryMonitor(): Ephemeral Image distance exceeded, ending projection");
            AssignCommand(oPC, ClearAllActions(TRUE));            
        }
    }
}
 */

//Undoes changes made in ApplyScryEffects().
void RemoveScryEffects(object oPC)
{
    if(DEBUG) DoDebug("prc_inc_scry: RemoveScryEffects():\n"
                    + "oPC = '" + GetName(oPC) + "'"
                      );
    effect eCheck = GetFirstEffect(oPC);
    while(GetIsEffectValid(eCheck)){
        if(GetEffectSpellId(eCheck) == GetLocalInt(oPC, "ScrySpellId"))
        {
            RemoveEffect(oPC, eCheck);
        }
        eCheck = GetNextEffect(oPC);
    }

    // Remove the no-damage property from all weapons it was added to
    int i;
    object oWeapon;
    for(i = 0; i < array_get_size(oPC, "Scry_Nerfed"); i++)
    {
        oWeapon = array_get_object(oPC, "Scry_Nerfed", i);
        IPRemoveMatchingItemProperties(oWeapon, ITEM_PROPERTY_NO_DAMAGE, DURATION_TYPE_PERMANENT);
    }

	effect eEffect = GetFirstEffect(oPC);
    while(GetIsEffectValid(eEffect))
    {
        if(GetEffectTag(eEffect) == "SCRYING_TAG")
            RemoveEffect(oPC, eEffect);
        eEffect = GetNextEffect(oPC);
    }
	
    array_delete(oPC, "Scry_Nerfed");
}

int GetIsScrying(object oPC)
{
    return GetLocalInt(oPC, "Scry_Active");
}

void DiscernLocation(object oPC, object oTarget)
{
    // Tells the name of the area the target is in
    // Yes, this is a little crappy for an 8th level spell.
    FloatingTextStringOnCreature(GetName(oTarget) + " is in " + GetName(GetArea(oTarget)), oPC, FALSE);

    // Delete all of the marker ints for the spell
    DeleteLocalInt(oPC, "ScryCasterLevel");
    DeleteLocalInt(oPC, "ScrySpellId");
    DeleteLocalInt(oPC, "ScrySpellDC");
    DeleteLocalFloat(oPC, "ScryDuration");
}

void LocateCreatureOrObject(object oPC, object oTarget)
{
    location lPC     = GetLocation(oPC);
    location lTarget = GetLocation(oTarget);
    // Cause the caller to face the target
    SetFacingPoint(GetPosition(oTarget));
    // Now spit out the distance
    float fDist = GetDistanceBetweenLocations(lPC, lTarget);
    FloatingTextStringOnCreature(GetName(oTarget) + " is " + FloatToString(MetersToFeet(fDist)) + " feet away from you.", oPC, FALSE);

    // Delete all of the marker ints for the spell 
    DeleteLocalInt(oPC, "ScryCasterLevel");
    DeleteLocalInt(oPC, "ScrySpellId");
    DeleteLocalInt(oPC, "ScrySpellDC");
    DeleteLocalFloat(oPC, "ScryDuration");
}

void CleanCopy(object oImage)
{
    SetLootable(oImage, FALSE);
    // remove inventory contents
    object oItem = GetFirstItemInInventory(oImage);
    while(GetIsObjectValid(oItem))
    {
        SetPlotFlag(oItem,FALSE);
        if(GetHasInventory(oItem))
        {
            object oItem2 = GetFirstItemInInventory(oItem);
            while(GetIsObjectValid(oItem2))
            {
                object oItem3 = GetFirstItemInInventory(oItem2);
                while(GetIsObjectValid(oItem3))
                {
                    SetPlotFlag(oItem3,FALSE);
                    DestroyObject(oItem3);
                    oItem3 = GetNextItemInInventory(oItem2);
                }
                SetPlotFlag(oItem2,FALSE);
                DestroyObject(oItem2);
                oItem2 = GetNextItemInInventory(oItem);
            }
        }
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oImage);
    }
    // remove non-visible equipped items
    int i;
    for(i=0;i<NUM_INVENTORY_SLOTS;i++)//equipment
    {
        oItem = GetItemInSlot(i, oImage);
        if(GetIsObjectValid(oItem))
        {
            if(i == INVENTORY_SLOT_HEAD || i == INVENTORY_SLOT_CHEST ||
                i == INVENTORY_SLOT_RIGHTHAND || i == INVENTORY_SLOT_LEFTHAND ||
                i == INVENTORY_SLOT_CLOAK) // visible equipped items
            {
                SetDroppableFlag(oItem, FALSE);
                SetItemCursedFlag(oItem, TRUE);
                // remove all item properties
                itemproperty ipLoop=GetFirstItemProperty(oItem);
                while (GetIsItemPropertyValid(ipLoop))
                {
                    RemoveItemProperty(oItem, ipLoop);
                    ipLoop=GetNextItemProperty(oItem);
                }
            }
            else // can't see it so destroy
            {                
                SetPlotFlag(oItem,FALSE);
                DestroyObject(oItem);
            }
        }
        
    }
    TakeGoldFromCreature(GetGold(oImage), oImage, TRUE);
}

//void main (){}