//::///////////////////////////////////////////////
//:: Spell Include: Teleport
//:: spinc_teleport
//::///////////////////////////////////////////////
/** @file
    Handles the internal functioning of the (Greater)
    Teleport -type spells, powers and SLAs.

    @author Ornedan
    @date   Created - 2005.11.04
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

#include "prc_inc_spells"
#include "prc_inc_teleport"


//////////////////////////////////////////////////
/* Constant defintions                          */
//////////////////////////////////////////////////

// Internal constants
const string TP_LOCATION         = "PRC_Teleport_TargetLocation";
const string TP_ERRORLESS        = "PRC_Teleport_Errorless";
const string TP_FIRSTSTAGE_DONE  = "PRC_Teleport_FirstPartDone";
const string TP_END_SCRIPT       = "PRC_Teleport_ScriptToCallAtEnd";

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Runs the using of a (Greater) Teleport (-like) spell / power / SLA.
 * The destination is gotten using a conversation or, if active, the
 * caster's quickselection.
 * NOTE: You will need to call spellhook / powerhook / specific-whatever
 * before this function.
 *
 *
 * @param oCaster        The creature using a spell / power / SLA to Teleport
 * @param nCasterLvl     The creature's caster / manifester level in regards to this use
 * @param bTeleportParty Whether to teleport only the user or also faction members within
 *                       10ft of the user. If TRUE, teleports party in addition to the user,
 *                       otherwise just the user.
 * @param bErrorLess     Whether this teleportation is subject to potential error a 'la Teleport
 *                       or errorless like Greater Teleport. If TRUE, there is no chance of
 *                       ending anywhere else other than the location selected.
 * @param sScriptToCall  Optionally, a script may be ExecuteScript'd for each of the teleportees
 *                       after they have reached their destination. This is used to specify
 *                       the name of such script.
 */
void Teleport(object oCaster, int nCasterLvl, int bTeleportParty, int bErrorLess, string sScriptToCall = "");


/********************\
* Internal Functions *
\********************/

/**
 * Does the actual teleporting. Called once the user has specified
 * the location to use.
 *
 * @param oCaster  creature using Teleport
 */
void TeleportAux(object oCaster);

/**
 * A visual effects heartbeat that runs when using party teleport while
 * waiting for the caster to decide the target location.
 * Outlines the 10ft radius. The HB will cease when the caster
 * makes the decision or moves from the location they were at at the
 * beginning of the HB.
 *
 * @param oCaster User of a Teleport
 * @param lCaster The location of the caster when they started the use
 */
void VFX_HB(object oCaster, location lCaster);

/**
 * A wrapper for assigning two commands at once after a delay from TeleportAux()
 * First, the jump command and then, if the script is non-blank, a call to ExecuteScript
 * the given post-jump script.
 *
 * @param oJumpee       creature being teleported by Teleport
 * @param lTarget       the location to jump to
 * @param sScriptToCall script for oJumpee to execute once it has jumped
 */
void AssignTeleportCommands(object oJumpee, location lTarget, string sScriptToCall);


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

void VFX_HB(object oCaster, location lCaster)
{
    // End the VFX once the caster either finishes the spell or moves
    if(GetLocalInt(oCaster, TP_FIRSTSTAGE_DONE) && GetLocation(oCaster) == lCaster)
    {
        // Draw to circles, going in the opposite directions
        DrawCircle(DURATION_TYPE_INSTANT, VFX_IMP_CONFUSION_S, lCaster, FeetToMeters(10.0f), 0.0, 50, 1.0, 6.0, 0.0, "z");
        DrawCircle(DURATION_TYPE_INSTANT, VFX_IMP_CONFUSION_S, lCaster, FeetToMeters(10.0f), 0.0, 50, 1.0, 6.0, 180.0, "z");
        DelayCommand(6.0f, VFX_HB(oCaster, lCaster));
    }
}

void TeleportAux(object oCaster)
{
    // Retrieve the target location from the variable
    location lTarget = GetLocalLocation(oCaster, TP_LOCATION);
    location lCaster = GetLocation(oCaster);
    string sScriptToCall = GetLocalString(oCaster, TP_END_SCRIPT);
    // Teleportation error handling code
    lTarget = GetTeleportError(lTarget, oCaster, GetLocalInt(oCaster, TP_ERRORLESS));

    int i;
    object oTarget;

    // Check if it's valid for the caster to teleport. If he can't go, no-one goes
    if(GetCanTeleport(oCaster, lTarget, TRUE, TRUE))
    {
        // VFX on the starting location
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_TELEPORT_OUT), lCaster);

        // Loop over the targets, checking if they can teleport. Redundant check on the caster, but shouldn't cause any trouble
        for(i = 0; i < array_get_size(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY); i++)
        {
            oTarget = array_get_object(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY, i);
            if(GetCanTeleport(oTarget, lTarget, TRUE))
            {
                DelayCommand(1.0f, AssignTeleportCommands(oTarget, lTarget, sScriptToCall));
            }
        }

        // VFX at arrival location. May run out before the teleporting people arrive
        DelayCommand(1.0f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_TELEPORT_IN), lTarget));
    }

    // Cleanup
    DeleteLocalInt(oCaster, TP_FIRSTSTAGE_DONE);
    DeleteLocalLocation(oCaster, TP_LOCATION);
    DeleteLocalInt(oCaster, TP_ERRORLESS);
    DeleteLocalString(oCaster, TP_END_SCRIPT);
    array_delete(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY);
}

void AssignTeleportCommands(object oJumpee, location lTarget, string sScriptToCall)
{
    AssignCommand(oJumpee, JumpToLocation(lTarget));
    if(sScriptToCall != "")
        AssignCommand(oJumpee, ActionDoCommand(ExecuteScript(sScriptToCall, oJumpee)));
    DelayCommand(0.5, ShadowPounce(oJumpee));    
}

void Teleport(object oCaster, int nCasterLvl, int bTeleportParty, int bErrorLess, string sScriptToCall = "")
{
    if(DEBUG) DoDebug("spinc_teleport: Running Teleport()" + /*(GetLocalInt(oCaster, TP_FIRSTSTAGE_DONE) ? ": ERROR: Called while in second stage!":*/("\n"
                    + "oCaster = " + DebugObject2Str(oCaster) + "\n"
                    + "nCasterLvl = " + IntToString(nCasterLvl) + "\n"
                    + "bTeleportParty = " + DebugBool2String(bTeleportParty) + "\n"
                    + "bErrorLess = " + DebugBool2String(bErrorLess) + "\n"
                    + "sScriptToCall = '" + sScriptToCall + "'\n"
                      /*)*/));

    // Get whether we are executing the first or the second part of the script
    /*if(!GetLocalInt(oCaster, TP_FIRSTSTAGE_DONE))
    {*/
    location lCaster = GetLocation(oCaster);

    // Run the code to build an array of targets on the caster
    GetTeleportingObjects(oCaster, nCasterLvl, bTeleportParty);

    // Do VFX while waiting for the location select. Only for party TP
    if(bTeleportParty)
        DelayCommand(0.01f, VFX_HB(oCaster, lCaster));

    // Mark the first part done
    SetLocalInt(oCaster, TP_FIRSTSTAGE_DONE, TRUE);
    // Store whether this usage is errorless
    SetLocalInt(oCaster, TP_ERRORLESS, bErrorLess);
    // Store the name of the script to call at the end
    SetLocalString(oCaster, TP_END_SCRIPT, sScriptToCall);
    // Now, get the location to teleport to.
    ChooseTeleportTargetLocation(oCaster, "prc_teleport_aux", TP_LOCATION, FALSE, TRUE);
    //}
}


// Test main
//void main(){}