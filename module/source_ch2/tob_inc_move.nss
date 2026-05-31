//::///////////////////////////////////////////////
//:: Tome of Battle include: Initiating
//:: tob_inc_move
//::///////////////////////////////////////////////
/** @file
    Defines structures and functions for handling
    initiating a maneuver

    @author Stratovarius
    @date   Created - 2007.3.20
    @thanks to Ornedan for his work on Psionics upon which this is based.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const string TOB_DEBUG_IGNORE_CONSTRAINTS = "TOB_DEBUG_IGNORE_CONSTRAINTS";

/**
 * The variable in which the maneuver token is stored. If no token exists,
 * the variable is set to point at the initiator itself. That way OBJECT_INVALID
 * means the variable is unitialised.
 */
const string PRC_MANEVEUR_TOKEN_VAR  = "PRC_ManeuverToken";
const string PRC_MANEVEUR_TOKEN_NAME = "PRC_MOVETOKEN";
const float  PRC_MANEVEUR_HB_DELAY   = 0.5f;


//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

/**
 * A structure that contains common data used during maneuver.
 */
struct maneuver{
    /* Generic stuff */
    /// The creature Truespeaking the Maneuver
    object oInitiator;
    /// Whether the maneuver is successful or not
    int bCanManeuver;
    /// The creature's initiator level in regards to this maneuver
    int nInitiatorLevel;
    /// The maneuver's spell ID
    int nMoveId;
};

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines if the maneuver that is currently being attempted to be TrueSpoken
 * can in fact be truespoken. Determines metamaneuvers used.
 *
 * @param oInitiator  A creature attempting to truespeak a maneuver at this moment.
 * @param oTarget       The target of the maneuver, if any. For pure Area of Effect.
 *                      maneuvers, this should be OBJECT_INVALID. Otherwise the main
 *                      target of the maneuver as returned by PRCGetSpellTargetObject().
 *
 * @return              A maneuver structure that contains the data about whether
 *                      the maneuver was successfully initiated and some other
 *                      commonly used data, like the PC's initiator level for this maneuver.
 */
struct maneuver EvaluateManeuver(object oInitiator, object oTarget = OBJECT_INVALID, int bTOBAbility = FALSE);

/**
 * Causes OBJECT_SELF to use the given maneuver.
 *
 * @param nManeuver         The index of the maneuver to use in spells.2da or an UTTER_*
 * @param nClass         The index of the class to use the maneuver as in classes.2da or a CLASS_TYPE_*
 * @param nLevelOverride An optional override to normal initiator level.
 *                       Default: 0, which means the parameter is ignored.
 */
void UseManeuver(int nManeuver, int nClass, int nLevelOverride = 0);

/**
 * A debugging function. Takes a maneuver structure and
 * makes a string describing the contents.
 *
 * @param move A set of maneuver data
 * @return      A string describing the contents of move
 */
string DebugManeuver2Str(struct maneuver move);

/**
 * Stores a maneuver structure as a set of local variables. If
 * a structure was already stored with the same name on the same object,
 * it is overwritten.
 *
 * @param oObject The object on which to store the structure
 * @param sName   The name under which to store the structure
 * @param move   The maneuver structure to store
 */
void SetLocalManeuver(object oObject, string sName, struct maneuver move);

/**
 * Retrieves a previously stored maneuver structure. If no structure is stored
 * by the given name, the structure returned is empty.
 *
 * @param oObject The object from which to retrieve the structure
 * @param sName   The name under which the structure is stored
 * @return        The structure built from local variables stored on oObject under sName
 */
struct maneuver GetLocalManeuver(object oObject, string sName);

/**
 * Deletes a stored maneuver structure.
 *
 * @param oObject The object on which the structure is stored
 * @param sName   The name under which the structure is stored
 */
void DeleteLocalManeuver(object oObject, string sName);

/**
 * Checks whether the maneuver is a class ability
 *
 * @param nMoveId The SpellID
 *
 * @return        TRUE if it is a class ability, FALSE otherwise
 */
int GetIsTOBAbility(int nMoveId);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "tob_inc_martlore"
#include "tob_inc_recovery"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * Deletes maneuver-related local variables.
 *
 * @param oInitiator The creature currently initiating a maneuver
 */
void _CleanManeuverVariables(object oInitiator)
{
    DeleteLocalInt(oInitiator, PRC_INITIATING_CLASS);
    DeleteLocalInt(oInitiator, PRC_MANEUVER_LEVEL);
    DeleteLocalInt(oInitiator, "PCIsInitiating");
}

/** Internal function.
 * Determines whether a maneuver token exists. If one does, returns it.
 *
 * @param oInitiator A creature whose maneuver token to get
 * @return            The maneuver token if it exists, OBJECT_INVALID otherwise.
 */
object _GetManeuverToken(object oInitiator)
{
    object oMoveToken = GetLocalObject(oInitiator, PRC_MANEVEUR_TOKEN_VAR);

    // If the token object is no longer valid, set the variable to point at initiator
    if(!GetIsObjectValid(oMoveToken))
    {
        oMoveToken = oInitiator;
        SetLocalObject(oInitiator, PRC_MANEVEUR_TOKEN_VAR, oMoveToken);
    }


    // Check if there is no token
    if(oMoveToken == oInitiator)
        oMoveToken = OBJECT_INVALID;

    return oMoveToken;
}

/** Internal function.
 * Destroys the given maneuver token and sets the creature's maneuver token variable
 * to point at itself.
 *
 * @param oInitiator The initiator whose token to destroy
 * @param oMoveToken    The token to destroy
 */
void _DestroyManeuverToken(object oInitiator, object oMoveToken)
{
    DestroyObject(oMoveToken);
    if(DEBUG) DoDebug("_DestroyManeuverToken(): Destroying Token");
    SetLocalObject(oInitiator, PRC_MANEVEUR_TOKEN_VAR, oInitiator);
}

/** Internal function.
 * Destroys the previous maneuver token, if any, and creates a new one.
 *
 * @param oInitiator A creature for whom to create a maneuver token
 * @return            The newly created token
 */
object _CreateManeuverToken(object oInitiator)
{
    object oMoveToken = _GetManeuverToken(oInitiator);
    object oStore   = GetObjectByTag("PRC_MANIFTOKEN_STORE"); //GetPCSkin(oInitiator);

    // Delete any previous tokens
    if(GetIsObjectValid(oMoveToken))
        _DestroyManeuverToken(oInitiator, oMoveToken);

    // Create new token and store a reference to it
    oMoveToken = CreateItemOnObject(PRC_MANEVEUR_TOKEN_NAME, oStore);
    SetLocalObject(oInitiator, PRC_MANEVEUR_TOKEN_VAR, oMoveToken);

    Assert(GetIsObjectValid(oMoveToken), "GetIsObjectValid(oMoveToken)", "ERROR: Unable to create maneuver token! Store object: " + DebugObject2Str(oStore), "true_inc_Utter", "_CreateManeuverToken()");

    return oMoveToken;
}

/** Internal function.
 * Determines whether the given initiator is doing something that would
 * interrupt initiating a maneuver or affected by an effect that would do
 * the same.
 *
 * @param oInitiator A creature on which _ManeuverHB() is running
 * @return            TRUE if the creature can continue initiating,
 *                    FALSE otherwise
 */
int _ManeuverStateCheck(object oInitiator)
{
    if(GetIsDead(oInitiator)) return FALSE;
    int nAction = GetCurrentAction(oInitiator);
    // If the current action is not among those that could either be used to truespeak the maneuver or movement, the maneuver fails
    if(!(nAction || ACTION_CASTSPELL     || nAction == ACTION_INVALID      ||
         nAction || ACTION_ITEMCASTSPELL || nAction == ACTION_MOVETOPOINT  ||
         nAction || ACTION_USEOBJECT     || nAction == ACTION_WAIT
       ) )
        return FALSE;

    // Affected by something that prevents one from initiating
    effect eTest = GetFirstEffect(oInitiator);
    int nEType;
    while(GetIsEffectValid(eTest))
    {
        nEType = GetEffectType(eTest);
        if(nEType == EFFECT_TYPE_CUTSCENE_PARALYZE ||
           nEType == EFFECT_TYPE_DAZED             ||
           nEType == EFFECT_TYPE_PARALYZE          ||
           nEType == EFFECT_TYPE_PETRIFY           ||
           nEType == EFFECT_TYPE_SLEEP             ||
           nEType == EFFECT_TYPE_STUNNED
           )
            return FALSE;

        // Get next effect
        eTest = GetNextEffect(oInitiator);
    }

    return TRUE;
}

/** Internal function.
 * Runs while the given creature is initiating. If they move, take other actions
 * that would cause them to interrupt initiating the maneuver or are affected by an
 * effect that would cause such interruption, deletes the maneuver token.
 * Stops if such condition occurs or something else destroys the token.
 *
 * @param oInitiator A creature initiating a maneuver
 * @param lInitiator The location where the initiator was when starting the maneuver
 * @param oMoveToken    The maneuver token that controls the ongoing maneuver
 */
void _ManeuverHB(object oInitiator, location lInitiator, object oMoveToken)
{
    float fDistance;
    if(DEBUG) DoDebug("_ManeuverHB() running:\n"
                    + "oInitiator = " + DebugObject2Str(oInitiator) + "\n"
                    + "lInitiator = " + DebugLocation2Str(lInitiator) + "\n"
                    + "oMoveToken = " + DebugObject2Str(oMoveToken) + "\n"
                    + "Distance between maneuver start location and current location: " + FloatToString(GetDistanceBetweenLocations(lInitiator, GetLocation(oInitiator))) + "\n"
                      );
    if(GetIsObjectValid(oMoveToken))
    {
        // Continuance check
        fDistance = GetDistanceBetweenLocations(lInitiator, GetLocation(oInitiator));
        if(fDistance > 2.0f || fDistance < 0.0 || // Allow some variance in the location to account for dodging and random fidgeting
           !_ManeuverStateCheck(oInitiator)                                       // Action and effect check
           )
        {
            if(DEBUG) DoDebug("_ManeuverHB(): initiator moved or lost concentration, destroying token");
            _DestroyManeuverToken(oInitiator, oMoveToken);

            // Inform initiator
            FloatingTextStringOnCreature("You have lost concentration on the maneuver you were attempting to initiate!", oInitiator, FALSE);
        }
        // Schedule next HB
        else
            DelayCommand(PRC_MANEVEUR_HB_DELAY, _ManeuverHB(oInitiator, lInitiator, oMoveToken));
    }
}

/** Internal function.
 * Checks if the initiator is in range to use the maneuver they are trying to use.
 * If not, queues commands to make the initiator to run into range.
 *
 * @param oInitiator A creature initiating a maneuver
 * @param nManeuver      SpellID of the maneuver being initiated
 * @param lTarget     The target location or the location of the target object
 */
void _ManeuverRangeCheck(object oInitiator, int nManeuver, location lTarget)
{
    float fDistance   = GetDistanceBetweenLocations(GetLocation(oInitiator), lTarget);
    float fRangeLimit;
    string sRange     = Get2DACache("spells", "Range", nManeuver);

    // Personal range maneuvers are always in range
    if(sRange == "P")
        return;
    // Ranges according to the CCG spells.2da page
    else if(sRange == "T")
        fRangeLimit = 2.25f;
    else if(sRange == "S")
        fRangeLimit = 8.0f;
    else if(sRange == "M")
        fRangeLimit = 20.0f;
    else if(sRange == "L")
        fRangeLimit = 40.0f;

    // See if we are out of range
    if(fDistance > fRangeLimit)
    {
        // Create waypoint for the movement
        object oWP = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lTarget);

        // Move into range, with a bit of fudge-factor
        //ActionMoveToObject(oWP, TRUE, fRangeLimit - 0.15f);

        // CleanUp
        ActionDoCommand(DestroyObject(oWP));

        // CleanUp, paranoia
        AssignCommand(oWP, ActionDoCommand(DestroyObject(oWP, 60.0f)));
    }
}

/** Internal function.
 * Assigns the fakecast command that is used to display the conjuration VFX when using an maneuver.
 * Separated from UseManeuver() due to a bug with ActionFakeCastSpellAtObject(), which requires
 * use of ClearAllActions() to work around.
 * The problem is that if the target is an item on the ground, if the actor is out of spell
 * range when doing the fakecast, they will run on top of the item instead of to the edge of
 * the spell range. This only happens if there was a "real action" in the actor's action queue
 * immediately prior to the fakecast.
 */
void _AssignUseManeuverFakeCastCommands(object oInitiator, object oTarget, location lTarget, int nSpellID)
{
    // Nuke actions to prevent the fakecast action from bugging
    ClearAllActions();

    if(GetIsObjectValid(oTarget))
        ActionCastFakeSpellAtObject(nSpellID, oTarget, PROJECTILE_PATH_TYPE_DEFAULT);
    else
        ActionCastFakeSpellAtLocation(nSpellID, lTarget, PROJECTILE_PATH_TYPE_DEFAULT);
}


/** Internal function.
 * Places the cheatcasting of the real maneuver into the initiator's action queue.
 */
void _UseManeuverAux(object oInitiator, object oMoveToken, int nSpellId,
                  object oTarget, location lTarget,
                  int nManeuver, int nClass, int nLevelOverride)
{
    if(DEBUG) DoDebug("_UseManeuverAux() running:\n"
                    + "oInitiator = " + DebugObject2Str(oInitiator) + "\n"
                    + "oMoveToken = " + DebugObject2Str(oMoveToken) + "\n"
                    + "nSpellId = " + IntToString(nSpellId) + "\n"
                    + "oTarget = " + DebugObject2Str(oTarget) + "\n"
                    + "lTarget = " + DebugLocation2Str(lTarget) + "\n"
                    + "nManeuver = " + IntToString(nManeuver) + "\n"
                    + "nClass = " + IntToString(nClass) + "\n"
                    + "nLevelOverride = " + IntToString(nLevelOverride) + "\n"
                      );

    // Make sure nothing has interrupted this maneuver
    if(GetIsObjectValid(oMoveToken))
    {
        if(DEBUG) DoDebug("_UseManeuverAux(): Token was valid, queueing actual maneuver");
        // Set the class to maneuver as
        SetLocalInt(oInitiator, PRC_INITIATING_CLASS, nClass + 1);

        // Set the maneuver's level
        SetLocalInt(oInitiator, PRC_MANEUVER_LEVEL, StringToInt(lookup_spell_innate(nSpellId)));

        if(nLevelOverride != 0)
            AssignCommand(oInitiator, ActionDoCommand(SetLocalInt(oInitiator, PRC_CASTERLEVEL_OVERRIDE, nLevelOverride)));
        if(GetIsObjectValid(oTarget))
            AssignCommand(oInitiator, ActionCastSpellAtObject(nManeuver, oTarget, METAMAGIC_NONE, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
        else
            AssignCommand(oInitiator, ActionCastSpellAtLocation(nManeuver, lTarget, METAMAGIC_NONE, TRUE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
        if(nLevelOverride != 0)
            AssignCommand(oInitiator, ActionDoCommand(DeleteLocalInt(oInitiator, PRC_CASTERLEVEL_OVERRIDE)));

        // Begins the Crusader Granting Maneuver process
        if (nClass == CLASS_TYPE_CRUSADER)
        {
            BeginCrusaderGranting(oInitiator);
            //if(DEBUG) DoDebug("_UseManeuverAux(): BeginCrusaderGranting");
        }
        
        SetLocalInt(oInitiator, "PCIsInitiating", TRUE);
        // Destroy the maneuver token for this maneuver
        _DestroyManeuverToken(oInitiator, oMoveToken);
    }
}

int _GetIsManeuverWeaponAppropriate(object oInitiator)
{
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oInitiator);
    // If the initiator is empty handed, unarmed strikes are good
    if (!GetIsObjectValid(oItem)) return TRUE;
    // If melee weapon, all good.
    if (IPGetIsMeleeWeapon(oItem)) return TRUE;
    // Add other legal items in here, like Bloodstorm Blade throwing

    // If one of the other's hasn't tripped, fail here
    return FALSE;
}

void _StanceSpecificChecks(object oInitiator, int nMoveId)
{
    int nStanceToKeep = -1;
    if (GetLevelByClass(CLASS_TYPE_WARBLADE, oInitiator) >= 20)
    {
        nStanceToKeep = GetHasActiveStance(oInitiator);
    }
    if (GetLevelByClass(CLASS_TYPE_DEEPSTONE_SENTINEL, oInitiator) >= 3 &&
        GetHasSpellEffect(MOVE_MOUNTAIN_FORTRESS, oInitiator) &&
        GetDisciplineByManeuver(nMoveId) == DISCIPLINE_STONE_DRAGON)
    {
        nStanceToKeep = GetHasActiveStance(oInitiator);
    }
    // Master of Nine can keep two stances active for 2 rounds per class level.
    if (GetLevelByClass(CLASS_TYPE_MASTER_OF_NINE, oInitiator) >= 3 && GetLocalInt(oInitiator, "MoNDualStance"))
    {
        nStanceToKeep = GetHasActiveStance(oInitiator);
        float fDelay = 12.0 * GetLevelByClass(CLASS_TYPE_MASTER_OF_NINE, oInitiator);
        // Clean up the stance when the timer runs out
        DelayCommand(fDelay, ClearStances(oInitiator, -1));
        DeleteLocalInt(oInitiator, "MoNDualStance");
    }

    //if(DEBUG) DoDebug("tob_inc_move: ClearStances");
    if(nStanceToKeep == nMoveId)
        nStanceToKeep = -1;
    // Can only have one stance active, except for a level 20+ Warblade
    ClearStances(oInitiator, nStanceToKeep);

    // Mark current stance as atcive
    MarkStanceActive(oInitiator, nMoveId);
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct maneuver EvaluateManeuver(object oInitiator, object oTarget = OBJECT_INVALID, int bTOBAbility = FALSE)
{
    /* Get some data */
    // initiator-related stuff
    int nInitiatorLevel  = GetInitiatorLevel(oInitiator);
    int nManeuverLevel   = GetManeuverLevel(oInitiator);
    int nClass           = GetInitiatingClass(oInitiator);

    /* Initialise the maneuver structure */
    struct maneuver move;
    move.oInitiator      = oInitiator;
    move.bCanManeuver    = TRUE; // Assume successfull maneuver by default
    move.nInitiatorLevel = nInitiatorLevel;
    move.nMoveId         = PRCGetSpellId();

    //if(DEBUG) DoDebug("move.bCanManeuver: " + IntToString(move.bCanManeuver));
    // Skip doing anything if something has prevented a successful maneuver already by this point
    if(/*move.bCanManeuver && */bTOBAbility == FALSE) // set up identification later
    {
        // If you're this far in, you always succeed, there are very few checks.
        // Deletes any active stances, and allows a Warblade 20 to have his two stances active.
        /* GC - TMI is being caused from GetIsStance being run on the swordsage. Let's not run it twice.*/
        if (GetIsStance(move.nMoveId)) _StanceSpecificChecks(oInitiator, move.nMoveId);
        else ExpendManeuver(move.oInitiator, nClass, move.nMoveId);
        // Allows the Master of Nine to Counter Stance.
        if(GetManeuverType(move.nMoveId) == MANEUVER_TYPE_COUNTER
        && GetLevelByClass(CLASS_TYPE_MASTER_OF_NINE, oInitiator) >= 4)
        {
            SetLocalInt(oInitiator, "MoNCounterStance", TRUE);
            DelayCommand(6.0, DeleteLocalInt(oInitiator, "MoNCounterStance"));
        }
        //if(DEBUG) DoDebug("tob_inc_move: _StanceSpecificChecks");
        // Expend the Maneuver until recovered
        //if (!GetIsStance(move.nMoveId)) ExpendManeuver(move.oInitiator, nClass, move.nMoveId);
        //if(DEBUG) DoDebug("tob_inc_move: ExpendManeuver");
        // Do Martial Lore data
        IdentifyManeuver(move.oInitiator, move.nMoveId);
        //if(DEBUG) DoDebug("tob_inc_move: IdentifyManeuver");
        IdentifyDiscipline(move.oInitiator);
        //if(DEBUG) DoDebug("tob_inc_move: IdentifyDiscipline");

    }//end if

    if(DEBUG) DoDebug("EvaluateManeuver(): Final result:\n" + DebugManeuver2Str(move));

    // Initiate maneuver-related variable CleanUp
    DelayCommand(0.5f, _CleanManeuverVariables(oInitiator));

    return move;
}

void UseManeuver(int nManeuver, int nClass, int nLevelOverride = 0)
{
    object oInitiator  = OBJECT_SELF;
    object oSkin       = GetPCSkin(oInitiator);
    object oTarget     = PRCGetSpellTargetObject();
    object oMoveToken;
    location lTarget   = PRCGetSpellTargetLocation();
    int nSpellID       = PRCGetSpellId();
    
    // Divine Surge Greater hardcoding to fix radial issue
    // Yes it's deliberate that it's both
    if (nSpellID == 15840 || nSpellID == 16051 || nSpellID == 16262)
    {
        nManeuver = MOVE_DS_GREATER_DIVINE_SURGE;
        nSpellID  = MOVE_DS_GREATER_DIVINE_SURGE;
    }    
    
	// Hardcoding to make Reth Dekala maneuvers work without forcing a massive redo of everything        
	if (nSpellID == 19331) nManeuver = MOVE_DS_MARTIAL_SPIRIT;        
	else if (nSpellID == 19332) nManeuver = MOVE_DS_THICKET_BLADES;
	else if (nSpellID == 19333) nManeuver = MOVE_DS_DAUNTING_STRIKE;
	else if (nSpellID == 19334) nManeuver = MOVE_TC_DEATH_FROM_ABOVE;
	else if (nSpellID == 19335) nManeuver = MOVE_IH_DISARMING_STRIKE;
	else if (nSpellID == 19336) nManeuver = MOVE_DS_ENTANGLING_BLADE;
	else if (nSpellID == 19337) nManeuver = MOVE_IH_WALL_BLADES;    
    
    if (DEBUG) DoDebug(GetName(oInitiator)+" initiating "+IntToString(nManeuver)+" on "+GetName(oTarget));
    
    float fDistance = MetersToFeet(GetDistanceBetweenLocations(GetLocation(oInitiator), GetLocation(oTarget)));
    float fDelay = FeetToMeters(fDistance)/10;
    
    // Moved the checks here, so they don't use an action.  

    // Don't hit yourself, dumbass    
    if (Get2DACache("feat", "TARGETSELF", GetClassFeatFromPower(nManeuver, nClass)) != "1" && oInitiator == oTarget && nSpellID != 19331 && nSpellID != 19332 && nSpellID != 19337)
    {
        //if(DEBUG) DoDebug("tob_inc_move: _GetTargetSelfStrike");
        FloatingTextStringOnCreature("You cannot target yourself with this maneuver.", oInitiator, FALSE);
        return;    
    }
    // If the weapon is not appropriate, fail.
    if (!_GetIsManeuverWeaponAppropriate(oInitiator))
    {
        //if(DEBUG) DoDebug("tob_inc_move: _GetIsManeuverWeaponAppropriate");
        FloatingTextStringOnCreature("You do not have an appropriate weapon to initiate this maneuver.", oInitiator, FALSE);
        return;
    }
    // If the maneuver is not readied, fail.
    // Stances don't need to be readied
    if (!GetIsManeuverReadied(oInitiator, nClass, nManeuver) && !GetIsStance(nManeuver) && !GetIsTOBAbility(nManeuver))
    {
        //if(DEBUG) DoDebug("tob_inc_move: GetIsManeuverReadied");
        FloatingTextStringOnCreature(GetManeuverName(nManeuver) + " is not readied.", oInitiator, FALSE);
        return;
    }
    // If the maneuver is expended, fail.
    if (GetIsManeuverExpended(oInitiator, nClass, nManeuver) && !GetIsTOBAbility(nManeuver))
    {
        //if(DEBUG) DoDebug("tob_inc_move: GetIsManeuverExpended");
        FloatingTextStringOnCreature(GetManeuverName(nManeuver) + " is already expended.", oInitiator, FALSE);
        return;
    }
    // If the PC is in a Warblade recovery round, fail
    if (GetIsWarbladeRecoveryRound(oInitiator))
    {
        //if(DEBUG) DoDebug("tob_inc_move: GetIsWarbladeRecoveryRound");
        FloatingTextStringOnCreature(GetName(oInitiator) + " is recovering Warblade maneuvers.", oInitiator, FALSE);
        return;
    }
    // Is the maneuver granted, and is the class a Crusader
    if (nClass == CLASS_TYPE_CRUSADER && !GetIsManeuverGranted(oInitiator, nManeuver) && !GetIsStance(nManeuver) && !GetIsTOBAbility(nManeuver))
    {
        //if(DEBUG) DoDebug("tob_inc_move: GetIsManeuverGranted");
        FloatingTextStringOnCreature(GetManeuverName(nManeuver) + " is not a granted maneuver.", oInitiator, FALSE);
        return;
    }    

    // These maneuvers don't have a delay otherwise, because the distance is always 0    
    if (Get2DACache("feat", "TARGETSELF", GetClassFeatFromPower(nManeuver, nClass)) == "1" && GetManeuverType(nManeuver) == MANEUVER_TYPE_STRIKE)
        fDelay = 3.0;

    // Dual Boost check
    if(GetManeuverType(nManeuver) == MANEUVER_TYPE_BOOST // If the maneuver is a boost
    && GetLocalInt(oInitiator, "SSDualBoost"))           // And the initiator can Dual boost.
    {
        // Set the maneuver time to 0 to skip VFX
        DeleteLocalInt(oInitiator, "SSDualBoost");
        fDelay = 0.0;
    }
    // Stance of Alacrity check
    // Only works on Counters, not Boosts
    else if(GetManeuverType(nManeuver) == MANEUVER_TYPE_COUNTER // If the maneuver is counter
    && GetHasSpellEffect(MOVE_DM_STANCE_ALACRITY, oInitiator))  // And the initiator has the stance
    {
        // Set the maneuver time to 0 to skip VFX
        fDelay = 0.0;
    }
    else if((Get2DACache("feat", "Constant", GetClassFeatFromPower(nManeuver, nClass)) == "SWIFT_ACTION" // Normally swift action maneuvers check
    || GetManeuverType(nManeuver) == MANEUVER_TYPE_BOOST
    || GetManeuverType(nManeuver) == MANEUVER_TYPE_COUNTER
    || GetManeuverType(nManeuver) == MANEUVER_TYPE_STANCE) // The maneuver is swift action to use
    && GetLocalInt(oInitiator, "RKVDivineImpetus")                                               // And the initiator can take a swift action now
       )
    {
        fDelay = 0.0;
        DeleteLocalInt(oInitiator, "RKVDivineImpetus");
    }
    else if(GetManeuverType(nManeuver) == MANEUVER_TYPE_STANCE && // The maneuver is a stance
       GetLocalInt(oInitiator, "MoNCounterStance")                                                          // Has used a counter already this round
       )
    {
        fDelay = 0.0;
        DeleteLocalInt(oInitiator, "MoNCounterStance");
    }
    else if((Get2DACache("feat", "Constant", GetClassFeatFromPower(nManeuver, nClass)) == "SWIFT_ACTION" // Normally swift action maneuvers check
    || GetManeuverType(nManeuver) == MANEUVER_TYPE_BOOST
    || GetManeuverType(nManeuver) == MANEUVER_TYPE_COUNTER
    || GetManeuverType(nManeuver) == MANEUVER_TYPE_STANCE)) // The maneuver is swift action to use
    {
        if (TakeSwiftAction(oInitiator)) // And the initiator can take a swift action now
            fDelay = 0.0;
        else
            return;
    }
    
    if (nManeuver == MOVE_DW_BURNING_BRAND)
        fDelay = FeetToMeters(fDistance*2)/10; // Because of how it has to be implemented.

    if(DEBUG) DoDebug("UseManeuver(): initiator is " + DebugObject2Str(oInitiator) + "\n"
                    + "nManeuver = " + IntToString(nManeuver) + "\n"
                    + "nClass = " + IntToString(nClass) + "\n"
                    + "nLevelOverride = " + IntToString(nLevelOverride) + "\n"
                    + "maneuver duration = " + FloatToString(fDelay) + "ms \n"
                    //+ "Token exists = " + DebugBool2String(GetIsObjectValid(oMoveToken))
                      );

    // Create the maneuver token. Deletes any old tokens and cancels corresponding maneuvers as a side effect
    oMoveToken = _CreateManeuverToken(oInitiator);

    /// @todo Hook to the initiator's OnDamaged event for the concentration checks to avoid losing the maneuver

    // Nuke action queue to prevent cheating with creative maneuver stacking.
    // Probably not necessary anymore - Ornedan
    if(DEBUG) SendMessageToPC(oInitiator, "Clearing all actions in preparation for second stage of the maneuver.");
    ClearAllActions();

    // If out of range, move to range
    _ManeuverRangeCheck(oInitiator, nManeuver, GetIsObjectValid(oTarget) ? GetLocation(oTarget) : lTarget);

    // Start the maneuver monitor HB
    DelayCommand(fDelay, ActionDoCommand(_ManeuverHB(oInitiator, GetLocation(oInitiator), oMoveToken)));
    if(DEBUG) DoDebug("Starting _ManeuverHB");

    // Assuming the spell isn't used as a swift action, fakecast for visuals
    if(fDelay > 0.0)
    {
        // Hack. Workaround of a bug with the fakecast actions. See function comment for details
        ActionDoCommand(_AssignUseManeuverFakeCastCommands(oInitiator, oTarget, lTarget, nSpellID));
        if(DEBUG) DoDebug("Starting _AssignUseManeuverFakeCastCommands");
    }

    if(DEBUG) DoDebug("Starting _UseManeuverAux");
    // Action queue the function that will cheatcast the actual maneuver
    DelayCommand(fDelay, AssignCommand(oInitiator, ActionDoCommand(_UseManeuverAux(oInitiator, oMoveToken, nSpellID, oTarget, lTarget, nManeuver, nClass, nLevelOverride))));
}

string DebugManeuver2Str(struct maneuver move)
{
    string sRet;

    sRet += "oInitiator = " + DebugObject2Str(move.oInitiator) + "\n";
    sRet += "bCanManeuver = " + DebugBool2String(move.bCanManeuver) + "\n";
    sRet += "nInitiatorLevel = "  + IntToString(move.nInitiatorLevel);

    return sRet;
}

void SetLocalManeuver(object oObject, string sName, struct maneuver move)
{
    //SetLocal (oObject, sName + "_", );
    SetLocalObject(oObject, sName + "_oInitiator", move.oInitiator);

    SetLocalInt(oObject, sName + "_bCanManeuver",      move.bCanManeuver);
    SetLocalInt(oObject, sName + "_nInitiatorLevel",   move.nInitiatorLevel);
    SetLocalInt(oObject, sName + "_nSpellID",          move.nMoveId);
}

struct maneuver GetLocalManeuver(object oObject, string sName)
{
    struct maneuver move;
    move.oInitiator = GetLocalObject(oObject, sName + "_oInitiator");

    move.bCanManeuver      = GetLocalInt(oObject, sName + "_bCanManeuver");
    move.nInitiatorLevel  = GetLocalInt(oObject, sName + "_nInitiatorLevel");
    move.nMoveId          = GetLocalInt(oObject, sName + "_nSpellID");

    return move;
}

void DeleteLocalManeuver(object oObject, string sName)
{
    DeleteLocalObject(oObject, sName + "_oInitiator");

    DeleteLocalInt(oObject, sName + "_bCanManeuver");
    DeleteLocalInt(oObject, sName + "_nInitiatorLevel");
    DeleteLocalInt(oObject, sName + "_nSpellID");
}

void ManeuverDebugIgnoreConstraints(object oInitiator)
{
    SetLocalInt(oInitiator, TOB_DEBUG_IGNORE_CONSTRAINTS, TRUE);
    DelayCommand(0.0f, DeleteLocalInt(oInitiator, TOB_DEBUG_IGNORE_CONSTRAINTS));
}

int GetIsTOBAbility(int nMoveId)
{
    // Shadow Sun Ninja and Eternal Blade class abilities
    if(nMoveId == 19320 ||
       nMoveId == 19321 ||
       nMoveId == 19322 ||
       nMoveId == 19323 ||
       nMoveId == 19324 ||
       nMoveId == 19325 ||
       nMoveId == 19326 ||
       nMoveId == 19316 ||
       nMoveId == 19315 ||
       nMoveId == 19314 ||
       nMoveId == 19317 ||
       nMoveId == 19318 ||
       nMoveId == 19319)
        return TRUE;

    return FALSE;
}

// Test main
//void main(){}
