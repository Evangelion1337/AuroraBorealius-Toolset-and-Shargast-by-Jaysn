//::///////////////////////////////////////////////
//:: Spell Include: Dimension Door
//:: spinc_dimdoor
//::///////////////////////////////////////////////
/** @file
    Handles the internal functioning of the Dimension
    Door -type spells, powers and SLAs.

    @author Ornedan
    @date   Created - 2005.10.07
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

#include "prc_inc_spells"
#include "prc_inc_teleport"
//#include "prc_inc_listener"
#include "prc_inc_chat"
#include "x0_i0_position"

//////////////////////////////////////////////////
/* Constant defintions                          */
//////////////////////////////////////////////////

const int DIMENSIONDOOR_SELF  = 0;
const int DIMENSIONDOOR_PARTY = 1;



// Internal constants
const string DD_CASTERLVL        = "PRC_DimensionDoor_CasterLvl";
const string DD_TELEPORTINGPARTY = "PRC_DimensionDoor_TeleportingParty";
const string DD_LOCATION         = "PRC_DimensionDoor_Location";
const string DD_DISTANCE         = "PRC_DimensionDoor_Distance";
const string DD_FIRSTSTAGE_DONE  = "PRC_DimensionDoor_FirstStageDone";
const string DD_SCRIPTTOCALL     = "PRC_DimensionDoor_ScriptToCallOnTeleport";

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Runs the using of a Dimension Door (-like) spell / power / SLA.
 * The target location is either the location of a target object gotten
 * with PRCGetSpellTargetObject() or if the target was a location on the
 * ground, PRCGetSpellTargetLocation(). The actual target location may
 * be different if bUseDirDist is TRUE.
 *
 * @param oCaster       The creature using a spell / power / SLA to Dimension Door
 * @param nCasterLvl    The creature's caster / manifester level in regards to this use
 * @param nSpellID      The spellID currently in effect. If not specified, PRCGetSpellId()
 *                      will be used to retrieve it.
 * @param sScriptToCall Optionally, a script may be ExecuteScript'd for each of the teleportees
 *                      after they have reached their destination. This is used to specify
 *                      the name of such script.
 *
 * @param bSelfOrParty  Determines whether this use of Dimension Door teleports only oCaster or
 *                      also all it's faction memers within 10ft radius (subject to the general
 *                      teleporting carry limits).
 *                      Valid values: DIMENSIONDOOR_SELF and DIMENSIONDOOR_PARTY
 *
 * @param bUseDirDist   If TRUE, the target location of the spell given via targeting cursor
 *                      is used only to specify the direction of actual target location,
 *                      relative to oCaster, and distance is specified via a listener.
 *                      Otherwise, the target location specified via targeting cursor is used
 *                      as the actual target.
 */
void DimensionDoor(object oCaster, int nCasterLvl, int nSpellID = -1, string sScriptToCall = "",
                   int bSelfOrParty = DIMENSIONDOOR_SELF, int bUseDirDist = FALSE
                   );


/********************\
* Internal Functions *
\********************/

/**
 * Extracts data from local variables, calls DoDimensionDoorTeleport() using
 * that data and then does CleanLocals().
 *
 * @param oCaster  creature using Dimension Door
 */
void DimensionDoorAux(object oCaster);

/**
 * Determines the target location of a Dimension Door. If using the
 * direction & distance listener trick, the direction of the location
 * is calculated from the base target location and distance is based
 * on the caster's speech.
 * Otherwise, the base target location is used.
 *
 * @param oCaster     creature using Dimension Door
 * @param nCasterLvl  oCaster's caster or manifester level in regards to this
 *                    Dimension Door use
 * @param lBaseTarget the base target location, obtained via normal targeting
 * @param fDistance   the distance specified by speech for the direction &
 *                    distance trick. If this is 0.0f, the trick is not used.
 *
 * @return            The location where this Dimension Door is supposed jump
 *                    it's targets to.
 */
location GetDimensionDoorLocation(object oCaster, int nCasterLvl, location lBaseTarget, float fDistance);

/**
 * Does the actual teleporting and VFX.
 *
 * @param oCaster           The user of the Dimension Door being run
 * @param lTarget           The location to teleport to
 * @param bTeleportingParty Whether this dimension door is teleporting only the user
 *                          or also surrounding party. Determines the size of the VFX
 * @param sScriptToCall     The script to call for each teleporting object once it has
 *                          reached the destination
 */
void DoDimensionDoorTeleport(object oCaster, location lTarget, int bTeleportingParty, string sScriptToCall);

/**
 * Deletes local variables used to preserve state over delays by these functions.
 *
 * @param oCaster  creature on whom the data was stored
 */
void CleanLocals(object oCaster);

/**
 * A wrapper for assigning two commands at once after a delay from DoDimensionDoorTeleport().
 * First, the jump command and then, if the script is non-blank, a call to ExecuteScript
 * the given post-jump script.
 *
 * @param oJumpee       creature being teleported by Dimension Door
 * @param lTarget       the location to jump to
 * @param sScriptToCall script for oJumpee to execute once it has jumped
 */
void AssignDimensionDoorCommands(object oJumpee, location lTarget, string sScriptToCall);



//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

void DimensionDoor(object oCaster, int nCasterLvl, int nSpellID = -1, string sScriptToCall = "",
                   int bSelfOrParty = DIMENSIONDOOR_SELF, int bUseDirDist = FALSE
                   )
{
    if(DEBUG) DoDebug("spinc_dimdoor: Running DimensionDoor()" + (GetLocalInt(oCaster, DD_FIRSTSTAGE_DONE) ? ": ERROR: Called while in second stage!":""));

    /* Main spellscript */
    if(!GetLocalInt(oCaster, DD_FIRSTSTAGE_DONE))
    {
        // Get the spell's base target location
        location lTarget = GetIsObjectValid(PRCGetSpellTargetObject()) ? // Are we teleporting to some object, or just at a spot on the ground?
                            GetLocation(PRCGetSpellTargetObject()) :     // Teleporting to some object
                            PRCGetSpellTargetLocation();                 // Teleporting to a spot on the ground


        // Run the code to build an array of targets on the caster
        GetTeleportingObjects(oCaster, nCasterLvl, bSelfOrParty == DIMENSIONDOOR_PARTY);

        if(!bUseDirDist)
        {
            SetLocalInt(oCaster, DD_FIRSTSTAGE_DONE, TRUE);
        }
        else
        {
            //SpawnListener("prc_dimdoor_aux", GetLocation(oCaster), "**", oCaster, 10.0f);
            AddChatEventHook(oCaster, "prc_dimdoor_aux", 10.0f);
            SendMessageToPCByStrRef(oCaster, 16825211); // "You have 10 seconds to speak the distance (in meters)"
            DelayCommand(10.0f, CleanLocals(oCaster));
        }

        // Store the location in either case. For the direction and distance version, it's used to determine direction.
        SetLocalLocation(oCaster, DD_LOCATION, lTarget);

        // Store various other data for use in DimensionDoorAux()
        SetLocalInt(oCaster, DD_CASTERLVL, nCasterLvl);
        SetLocalInt(oCaster, DD_TELEPORTINGPARTY, bSelfOrParty == DIMENSIONDOOR_PARTY);
        SetLocalString(oCaster, DD_SCRIPTTOCALL, sScriptToCall);
    }
    if(GetLocalInt(oCaster, DD_FIRSTSTAGE_DONE))
    {
        DimensionDoorAux(oCaster);
    }
}

void DimensionDoorAux(object oCaster)
{
    DoDimensionDoorTeleport(oCaster,
                            GetDimensionDoorLocation(oCaster,
                                                     GetLocalInt(oCaster, DD_CASTERLVL),
                                                     GetLocalLocation(oCaster, DD_LOCATION),
                                                     GetLocalFloat(oCaster, DD_DISTANCE)
                                                     ),
                            GetLocalInt(oCaster, DD_TELEPORTINGPARTY),
                            GetLocalString(oCaster, DD_SCRIPTTOCALL)
                            );
    CleanLocals(oCaster);
}

location GetDimensionDoorLocation(object oCaster, int nCasterLvl, location lBaseTarget, float fDistance)
{
    if(DEBUG) DoDebug("spinc_dimdoor: GetDimensionDoorLocation(" + GetName(oCaster) + ", " + IntToString(nCasterLvl) + ", " + LocationToString(lBaseTarget) + ", " + FloatToString(fDistance) + ")");
    // Default to base target
    location lTarget = lBaseTarget;

    // First, check if we are using the Direction & Distance mode
    if(fDistance != 0.0f)
    {
        if(DEBUG) DoDebug("spinc_dimdoor: Calculating the new location based on direction and distance");
        // Make sure the distance jumped is in range
        if(GetLocalInt(oCaster, "DimensionalJaunt") && fDistance > FeetToMeters(5.0 * (nCasterLvl)))
        {
                DeleteLocalInt(oCaster, "DimensionalJaunt");
                fDistance = FeetToMeters(5.0 * (nCasterLvl));
                string sPretty = FloatToString(fDistance);
                sPretty = GetSubString(sPretty, 0, FindSubString(sPretty, ".") + 2); // Trunctate decimals to the last two
                sPretty += "m"; // Note the unit. Since this is SI, the letter should be universal
            //                      "You can't teleport that far, distance limited to"
            SendMessageToPC(oCaster, GetStringByStrRef(16825210) + " " + sPretty);
        }
        else if(GetLocalInt(oCaster, "FleeTheScene") && fDistance > FeetToMeters(25.0 + 5.0 * (nCasterLvl / 2)))
        {
                DeleteLocalInt(oCaster, "FleeTheScene");
                fDistance = FeetToMeters(25.0 + 5.0 * (nCasterLvl / 2));
                string sPretty = FloatToString(fDistance);
                sPretty = GetSubString(sPretty, 0, FindSubString(sPretty, ".") + 2); // Trunctate decimals to the last two
                sPretty += "m"; // Note the unit. Since this is SI, the letter should be universal
            //                      "You can't teleport that far, distance limited to"
            SendMessageToPC(oCaster, GetStringByStrRef(16825210) + " " + sPretty);
        }
        else if(GetLocalInt(oCaster, "Treewalk") && fDistance > FeetToMeters(60.0))
        {
                fDistance = FeetToMeters(60.0);
                string sPretty = FloatToString(fDistance);
                sPretty = GetSubString(sPretty, 0, FindSubString(sPretty, ".") + 2); // Trunctate decimals to the last two
                sPretty += "m"; // Note the unit. Since this is SI, the letter should be universal
            //                      "You can't teleport that far, distance limited to"
            SendMessageToPC(oCaster, GetStringByStrRef(16825210) + " " + sPretty);
        }
        else if(fDistance > FeetToMeters(400.0 + 40.0 * nCasterLvl))
        {
            fDistance = FeetToMeters(400.0 + 40.0 * nCasterLvl);
            string sPretty = FloatToString(fDistance);
                   sPretty = GetSubString(sPretty, 0, FindSubString(sPretty, ".") + 2); // Trunctate decimals to the last two
                   sPretty += "m"; // Note the unit. Since this is SI, the letter should be universal
            //                      "You can't teleport that far, distance limited to"
            SendMessageToPC(oCaster, GetStringByStrRef(16825210) + " " + sPretty);
        }
        location lCaster   = GetLocation(oCaster);
        vector vCaster     = GetPositionFromLocation(lCaster);
        vector vBaseTarget = GetPositionFromLocation(lBaseTarget);
        /*float fAngle       = acos((vBaseTarget.x - vCaster.x) / GetDistanceBetweenLocations(lCaster, lBaseTarget));
        // The above formula only returns values [0, 180], so it needs to be mirrored if the caster is moving towards negative y
        if((vBaseTarget.y - vCaster.y) < 0.0f)
            fAngle         = -fAngle;
        */
        float fAngle       = GetRelativeAngleBetweenLocations(lCaster, lBaseTarget);
        if(DEBUG) DoDebug("spinc_dimdoor: Angle is " + FloatToString(fAngle));
        vector vTarget     = Vector(vCaster.x + cos(fAngle) * fDistance,
                                    vCaster.y + sin(fAngle) * fDistance,
                                    vCaster.z
                                    );
        // Sanity checks to make sure the location is not out of map bounds in the negative direction.
        if(vTarget.x < 0.0f) vTarget.x = 0.0f;
        if(vTarget.y < 0.0f) vTarget.y = 0.0f;

        lTarget = Location(GetAreaFromLocation(lBaseTarget), vTarget, GetFacingFromLocation(lBaseTarget));
    }
    
	if (GetLocalInt(oCaster, "BlackLabyrinth"))
		return GenerateNewLocationFromLocation(lTarget, FeetToMeters(5.0*d4()), IntToFloat(Random(360)), IntToFloat(Random(360)));      
    /* This works, but it was replaced with the direction & distance trick above since that has more versatility in
       selecting the target even though it is slower due to both not fitting on the radial.
       Left here in case it needs to be brought back at a later date.

    else if(GetHasTeleportQuickSelection(oCaster, PRC_TELEPORT_ACTIVE_QUICKSELECTION))
    {
        if(DEBUG) DoDebug("spinc_dimdoor: Quickselect is active");
        location lTest = MetalocationToLocation(GetActiveTeleportQuickSelection(oCaster, FALSE));

        if(GetArea(oCaster) == GetAreaFromLocation(lTest))
        {
            if(DEBUG) DoDebug("spinc_dimdoor: Quickselect is in same area");
            if(GetDistanceBetweenLocations(GetLocation(oCaster), lTest) <= FeetToMeters(400.0 + 40.0 * nCasterLvl))
            {
                if(DEBUG) DoDebug("spinc_dimdoor: Quickselect is in range");
                // Used the active quickselection, so clear it
                RemoveTeleportQuickSelection(oCaster, PRC_TELEPORT_ACTIVE_QUICKSELECTION);
                lTarget = lTest;
            }
        }
    }*/

    // Return the target gotten after possible modifications
    return lTarget;
}

void DoDimensionDoorTeleport(object oCaster, location lTarget, int bTeleportingParty, string sScriptToCall)
{
    location lCaster = GetLocation(oCaster);
    object oTarget;
    int i;

    // Check if it's valid for the caster to teleport. If he can't go, no-one goes
    if(GetCanTeleport(oCaster, lTarget, TRUE, TRUE))
    {
        // Loop over the targets, checking if they can teleport. Redundant check on the caster, but shouldn't cause any trouble
        for(i = 0; i < array_get_size(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY); i++)
        {
            oTarget = array_get_object(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY, i);
            if(GetCanTeleport(oTarget, lTarget, TRUE))
            {
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY), oTarget, 0.55));
                DelayCommand(1.5, AssignDimensionDoorCommands(oTarget, lTarget, sScriptToCall));
            }
        }

        // VFX //
        //DrawLineFromCenter(DURATION_TYPE_INSTANT, VFX_IMP_WIND, lCenter, 21.0, 0.0, 0.0, 29, 2.0, "z");
        //BeamPolygon(1, 73, lCenter, 5.0, 8, 3.0, "invisobj", 1.0, 0.0, 0.0, "z", -1, -1, 0.0, 1.0, 2.0);

        // Make the caster animate for the second of delay
        AssignCommand(oCaster, ClearAllActions());
        AssignCommand(oCaster, SetFacingPoint(GetPositionFromLocation(lTarget)));
        AssignCommand(oCaster, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE1, 1.0f, 1.0f));

        // First, spawn a circle of ligntning around the caster
        BeamPolygon(DURATION_TYPE_PERMANENT, VFX_BEAM_LIGHTNING, lCaster,
                    bTeleportingParty ? FeetToMeters(10.0) : FeetToMeters(3.0), // Single TP: 3ft radius; Party TP: 10ft radius
                    bTeleportingParty ? 15 : 10, // More nodes for the group VFX
                    1.5f, "prc_invisobj", 1.0f, 0.0f, 0.0f, "z", 0.0f, 0.0f,
                    -1, -1, 0.0f, 1.0f, // No secondary VFX
                    2.0f // Non-zero lifetime, so the placeables eventually get removed
                    );


        //BeamPolygon(1, 73, lCaster, 5.0, 8, 3.0, "prc_invisobj", 1.0, 0.0, 0.0, "z", -1, -1, 0.0, 1.0, 2.0);

        // After a moment, draw a line from the caster to the destination
        DelayCommand(1.0, DrawLineFromVectorToVector(DURATION_TYPE_INSTANT, VFX_IMP_WIND, GetArea(oCaster), GetPositionFromLocation(lCaster), GetPositionFromLocation(lTarget), 0.0,
                                                     FloatToInt(GetDistanceBetweenLocations(lCaster, lTarget)), // One VFX every meter
                                                     0.5));
        // Then, spawn a circle of ligtning at the destination
        DelayCommand(0.5, BeamPolygon(DURATION_TYPE_TEMPORARY, VFX_BEAM_LIGHTNING, lTarget,
                          bTeleportingParty ? FeetToMeters(10.0) : FeetToMeters(3.0),
                          bTeleportingParty ? 15 : 10,
                          1.5, "prc_invisobj", 1.0, 0.0, 0.0, "z", 0.0f, 0.0f, -1, -1, 0.0, 1.0, 2.0));
    }

    // Cleanup
    array_delete(oCaster, PRC_TELEPORTING_OBJECTS_ARRAY);
}

void AssignDimensionDoorCommands(object oJumpee, location lTarget, string sScriptToCall)
{
    AssignCommand(oJumpee, JumpToLocation(lTarget));
    if(sScriptToCall != "")
        AssignCommand(oJumpee, ActionDoCommand(ExecuteScript(sScriptToCall, oJumpee)));
    DelayCommand(0.5, ShadowPounce(oJumpee));        
}

void CleanLocals(object oCaster)
{
    DeleteLocalInt     (oCaster, DD_CASTERLVL);
    DeleteLocalInt     (oCaster, DD_TELEPORTINGPARTY);
    DeleteLocalLocation(oCaster, DD_LOCATION);
    DeleteLocalFloat   (oCaster, DD_DISTANCE);
    DeleteLocalInt     (oCaster, DD_FIRSTSTAGE_DONE);
    DeleteLocalString  (oCaster, DD_SCRIPTTOCALL);
}


// Test main
//void main(){}