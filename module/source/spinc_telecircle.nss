//::///////////////////////////////////////////////
//:: Spell Include: Teleportation Circle
//:: spinc_telecircle
//::///////////////////////////////////////////////
/** @file
    Handles the internal functioning of the
    Teleportation Circle -type spells, powers
    and SLAs.

    @author Ornedan
    @date   Created  - 2005.11.12
    @date   Modified - 2006.06.04
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

#include "prc_inc_spells"
#include "prc_inc_teleport"


//////////////////////////////////////////////////
/* Constant defintions                          */
//////////////////////////////////////////////////

// Internal constants
const string TC_CASTERLEVEL      = "PRC_TeleportCircle_CasterLvl";
const string TC_ISVISIBLE        = "PRC_TeleportCircle_IsVisible";
const string TC_ISEXTENDED       = "PRC_TeleportCircle_Extended";
const string TC_FIRSTSTAGE_DONE  = "PRC_TeleportCircle_FirstPartDone";
const string TC_LOCATION         = "PRC_TeleportCircle_TargetLocation";

const int TC_NUM_TRAPS = 4;

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Runs the using of a Teleportation Circle (-like) spell / power / SLA.
 * The destination is gotten using a conversation or, if active, the
 * caster's quickselection.
 * NOTE: You will need to call spellhook / powerhook / specific-whatever
 * before this function.
 *
 *
 * @param oCaster    The creature using a spell / power / SLA create
 *                   a Teleportation Circle
 * @param nCasterLvl The creature's caster / manifester level in regards to
 *                   this use
 * @param bVisible   Whether the circle should be visible or not. A visible circle
 *                   is marked with VFX and has a detection DC of 0. A hidden circle
 *                   has a detection DC of 34.
 * @param bExtended  Whether this use of Teleportation Circle had the Extend Metaeffect
 *                   applied to it.
 */
void TeleportationCircle(object oCaster, int nCasterLvl, int bVisible, int bExtended);


/********************\
* Internal Functions *
\********************/

/**
 * Does the actual creation of the circle. Called once the user has specified
 * the target location to use.
 *
 * @param oCaster  creature using Teleportation Circle
 */
void TeleportationCircleAux(object oCaster);


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////


void TeleportationCircleAux(object oCaster)
{
    // Retrieve the target location from the variable
    location lCircleTarget = GetLocalLocation(oCaster, TC_LOCATION);
    location lTarget;
    int bVisible   = GetLocalInt(oCaster, TC_ISVISIBLE);
    int nCasterLvl = GetLocalInt(oCaster, TC_CASTERLEVEL);
    int bExtended  = GetLocalInt(oCaster, TC_ISEXTENDED);
    float fDuration = nCasterLvl * 10 * 60.0f * (bExtended ? 2 : 1);
    float fFacing   = GetFacing(oCaster);
    float fDistance = FeetToMeters(5.0f) + 0.2;
    vector vTarget = GetPosition(oCaster);
           vTarget.x += cos(fFacing) * fDistance;
           vTarget.y += sin(fFacing) * fDistance;
    lTarget = Location(GetArea(oCaster), vTarget, fFacing);

    // Create the actual circle, in front of the caster
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,
                          EffectAreaOfEffect(AOE_PER_TELEPORTATIONCIRCLE, "prc_telecirc_oe"),
                          lTarget,
                          fDuration
                          );
    // Get an object reference to the newly created AoE
    object oAoE = MyFirstObjectInShape(SHAPE_SPHERE, 1.0f, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    while(GetIsObjectValid(oAoE))
    {
        // Test if we found the correct AoE
        if(GetTag(oAoE) == Get2DACache("vfx_persistent", "LABEL", AOE_PER_TELEPORTATIONCIRCLE) &&
           !GetLocalInt(oAoE, "PRC_TeleCircle_AoE_Inited")
           )
        {
            break;
        }
        // Didn't find, get next
        oAoE = MyNextObjectInShape(SHAPE_SPHERE, 1.0f, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    }
    if(DEBUG) if(!GetIsObjectValid(oAoE)) DoDebug("ERROR: Can't find area of effect for Teleportation Circle!");

    // Store data on the AoE
    SetLocalLocation(oAoE, "TargetLocation", lCircleTarget);
    SetLocalInt(oAoE, "IsVisible", bVisible);

    // Make the AoE initialise the trap trigger and possibly the VFX heartbeat
    ExecuteScript("prc_telecirc_aux", oAoE);


    // A VFX (momentary, circular, impressive :D ) at the circle's location.
    // Do even if hidden circle so that the caster knows where it really ended up
    DrawRhodonea(DURATION_TYPE_INSTANT, VFX_IMP_HEAD_MIND, lTarget, FeetToMeters(5.0f), 0.25, 0.0, 180, 12.0, 4.0, 0.0, "z");

    // Cleanup
    DeleteLocalInt(oCaster, TC_CASTERLEVEL);
    DeleteLocalInt(oCaster, TC_ISVISIBLE);
    DeleteLocalInt(oCaster, TC_ISEXTENDED);
    DeleteLocalInt(oCaster, TC_FIRSTSTAGE_DONE);
    DeleteLocalLocation(oCaster, TC_LOCATION);
}

void TeleportationCircle(object oCaster, int nCasterLvl, int bVisible, int bExtended)
{
    if(DEBUG) DoDebug("spinc_telecircle: Running TeleportationCircle()" + (GetLocalInt(oCaster, TC_FIRSTSTAGE_DONE) ? ": ERROR: Called while in second stage!":"") + "\n"
                    + "oCaster = " + DebugObject2Str(oCaster) + "\n"
                    + "nCasterLvl = " + IntToString(nCasterLvl) + "\n"
                    + "bVisible = " + DebugBool2String(bVisible) + "\n"
                    + "bExtended = " + DebugBool2String(bExtended) + "\n"
                      );

    // Get whether we are executing the first or the second part of the script
    if(!GetLocalInt(oCaster, TC_FIRSTSTAGE_DONE))
    {
        // Store the caster level
        SetLocalInt(oCaster, TC_CASTERLEVEL, nCasterLvl);
        // Store the spellID
        SetLocalInt(oCaster, TC_ISVISIBLE, bVisible);
        // Store whether the spell is extended
        SetLocalInt(oCaster, TC_ISEXTENDED, bExtended);
        // Mark the first part done
        SetLocalInt(oCaster, TC_FIRSTSTAGE_DONE, TRUE);
        // Now, get the location to have the circle point at.
        ChooseTeleportTargetLocation(oCaster, "prc_telecirc_aux", TC_LOCATION, FALSE, TRUE);
    }
}


// Test main
//void main(){}