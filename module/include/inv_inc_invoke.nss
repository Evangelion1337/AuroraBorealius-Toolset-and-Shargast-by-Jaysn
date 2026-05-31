//::///////////////////////////////////////////////
//:: Invocation include: Casting
//:: inv_inc_invoke
//::///////////////////////////////////////////////
/** @file
    Defines structures and functions for handling
    initiating a invocation

    @author Fox
    @date   Created - 2008.1.26
    @thanks to Ornedan for his work on Psionics upon which this is based.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const string PRC_INVOKING_CLASS           = "PRC_CurrentInvocation_InitiatingClass";
const string PRC_INVOCATION_LEVEL         = "PRC_CurrentInvocation_Level";
const string INV_DEBUG_IGNORE_CONSTRAINTS = "INV_DEBUG_IGNORE_CONSTRAINTS";

/**
 * The variable in which the invocation token is stored. If no token exists,
 * the variable is set to point at the invoker itself. That way OBJECT_INVALID
 * means the variable is unitialised.
 */
//const string PRC_INVOCATION_TOKEN_VAR  = "PRC_InvocationToken";
//const string PRC_INVOCATION_TOKEN_NAME = "PRC_INVOKETOKEN";
//const float  PRC_INVOCATION_HB_DELAY   = 0.5f;


//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

/**
 * A structure that contains common data used during invocation.
 */
struct invocation{
    /* Generic stuff */
    /// The creature Truespeaking the Invocation
    object oInvoker;
    /// Whether the invocation is successful or not
    int bCanInvoke;
    /// The creature's invoker level in regards to this invocation
    int nInvokerLevel;
    /// The invocation's spell ID
    int nInvocationId;
};

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines if the invocation that is currently being attempted to be TrueSpoken
 * can in fact be truespoken. Determines metainvocations used.
 *
 * @param oInvoker  A creature attempting to truespeak a invocation at this moment.
 * @param oTarget       The target of the invocation, if any. For pure Area of Effect.
 *                      invocations, this should be OBJECT_INVALID. Otherwise the main
 *                      target of the invocation as returned by PRCGetSpellTargetObject().
 *
 * @return              A invocation structure that contains the data about whether
 *                      the invocation was successfully initiated and some other 
 *                      commonly used data, like the PC's invoker level for this invocation.
 */
struct invocation EvaluateInvocation(object oInvoker, object oTarget);

/**
 * Causes OBJECT_SELF to use the given invocation.
 *
 * @param nInvocation         The index of the invocation to use in spells.2da or an UTTER_*
 * @param nClass         The index of the class to use the invocation as in classes.2da or a CLASS_TYPE_*
 * @param nLevelOverride An optional override to normal invoker level. 
 * @param bInstant       If true invocation will be used without casting animations (eldritch sculptor)
 *                       Default: 0, which means the parameter is ignored.
 */
void UseInvocation(int nInvocation, int nClass, int nLevelOverride = 0, int bInstant = FALSE);

/**
 * A debugging function. Takes a invocation structure and
 * makes a string describing the contents.
 *
 * @param move A set of invocation data
 * @return      A string describing the contents of move
 */
string DebugInvocation2Str(struct invocation invoked);

/**
 * Stores a invocation structure as a set of local variables. If
 * a structure was already stored with the same name on the same object,
 * it is overwritten.
 *
 * @param oObject The object on which to store the structure
 * @param sName   The name under which to store the structure
 * @param move   The invocation structure to store
 */
void SetLocalInvocation(object oObject, string sName, struct invocation invoked);

/**
 * Retrieves a previously stored invocation structure. If no structure is stored
 * by the given name, the structure returned is empty.
 *
 * @param oObject The object from which to retrieve the structure
 * @param sName   The name under which the structure is stored
 * @return        The structure built from local variables stored on oObject under sName
 */
struct invocation GetLocalInvocation(object oObject, string sName);

/**
 * Deletes a stored invocation structure.
 *
 * @param oObject The object on which the structure is stored
 * @param sName   The name under which the structure is stored
 */
void DeleteLocalInvocation(object oObject, string sName);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inv_inc_invfunc"	//Access in parent 
#include "prc_spellf_inc"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * Handles Spellfire absorption when a utterance is used on a friendly spellfire
 * user.
 */
struct invocation _DoInvocationSpellfireFriendlyAbsorption(struct invocation invoked, object oTarget)
{
    if(GetLocalInt(oTarget, "SpellfireAbsorbFriendly") &&
       GetIsFriend(oTarget, invoked.oInvoker)
       )
    {
        if(CheckSpellfire(invoked.oInvoker, oTarget, TRUE))
        {
            PRCShowSpellResist(invoked.oInvoker, oTarget, SPELL_RESIST_MANTLE);
            invoked.bCanInvoke = FALSE;
        }
    }

    return invoked;
}

/** Internal function.
 * Sets invocation-related local variables.
 *
 * @param oInvoker     The creature currently casting invocation
 * @param nClass       Invocation casting class constant
 * @param nLevel       Invocation level
 */
void _SetInvocationVariables(object oInvoker, int nClass, int nLevel)
{
    if (DEBUG) FloatingTextStringOnCreature(GetName(oInvoker)+" is a "+IntToString(nClass)+" at "+IntToString(nLevel)+" invocation level", oInvoker);
    SetLocalInt(oInvoker, PRC_INVOKING_CLASS, nClass + 1);
    SetLocalInt(oInvoker, PRC_INVOCATION_LEVEL, nLevel);
}


/** Internal function.
 * Deletes invocation-related local variables.
 *
 * @param oInvoker The creature currently initiating a invocation
 */
void _CleanInvocationVariables(object oInvoker)
{
    DeleteLocalInt(oInvoker, PRC_INVOKING_CLASS);
    DeleteLocalInt(oInvoker, PRC_INVOCATION_LEVEL);
}

/** Internal function.
 * Determines whether a invocation token exists. If one does, returns it.
 *
 * @param oInvoker A creature whose invocation token to get
 * @return            The invocation token if it exists, OBJECT_INVALID otherwise.
 */
/*object _GetInvocationToken(object oInvoker)
{
    object oInvokeToken = GetLocalObject(oInvoker, PRC_INVOCATION_TOKEN_VAR);

    // If the token object is no longer valid, set the variable to point at invoker
    if(!GetIsObjectValid(oInvokeToken))
    {
        oInvokeToken = oInvoker;
        SetLocalObject(oInvoker, PRC_INVOCATION_TOKEN_VAR, oInvokeToken);
    }


    // Check if there is no token
    if(oInvokeToken == oInvoker)
        oInvokeToken = OBJECT_INVALID;

    return oInvokeToken;
}*/

/** Internal function.
 * Destroys the given invocation token and sets the creature's invocation token variable
 * to point at itself.
 *
 * @param oInvoker The invoker whose token to destroy
 * @param oInvokeToken    The token to destroy
 */
/*void _DestroyInvocationToken(object oInvoker, object oInvokeToken)
{
    DestroyObject(oInvokeToken);
    SetLocalObject(oInvoker, PRC_INVOCATION_TOKEN_VAR, oInvoker);
}*/

/** Internal function.
 * Destroys the previous invocation token, if any, and creates a new one.
 *
 * @param oInvoker A creature for whom to create a invocation token
 * @return            The newly created token
 */
/*object _CreateInvocationToken(object oInvoker)
{
    object oInvokeToken = _GetInvocationToken(oInvoker);
    object oStore   = GetObjectByTag("PRC_MANIFTOKEN_STORE"); //GetPCSkin(oInvoker);

    // Delete any previous tokens
    if(GetIsObjectValid(oInvokeToken))
        _DestroyInvocationToken(oInvoker, oInvokeToken);

    // Create new token and store a reference to it
    oInvokeToken = CreateItemOnObject(PRC_INVOCATION_TOKEN_NAME, oStore);
    SetLocalObject(oInvoker, PRC_INVOCATION_TOKEN_VAR, oInvokeToken);

    Assert(GetIsObjectValid(oInvokeToken), "GetIsObjectValid(oInvokeToken)", "ERROR: Unable to create invocation token! Store object: " + DebugObject2Str(oStore), "inv_inc_invoke", "_CreateInvocationToken()");

    return oInvokeToken;
}*/

/** Internal function.
 * Determines whether the given invoker is doing something that would
 * interrupt initiating a invocation or affected by an effect that would do
 * the same.
 *
 * @param oInvoker A creature on which _InvocationHB() is running
 * @return            TRUE if the creature can continue initiating,
 *                    FALSE otherwise
 */
/*int _InvocationStateCheck(object oInvoker)
{
    int nAction = GetCurrentAction(oInvoker);
    // If the current action is not among those that could either be used to truespeak the invocation or movement, the invocation fails
    if(!(nAction || ACTION_CASTSPELL     || nAction == ACTION_INVALID      ||
         nAction || ACTION_ITEMCASTSPELL || nAction == ACTION_MOVETOPOINT  ||
         nAction || ACTION_USEOBJECT     || nAction == ACTION_WAIT
       ) )
        return FALSE;

    // Affected by something that prevents one from initiating
    effect eTest = GetFirstEffect(oInvoker);
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
        eTest = GetNextEffect(oInvoker);
    }

    return TRUE;
}*/

/** Internal function.
 * Runs while the given creature is initiating. If they move, take other actions
 * that would cause them to interrupt initiating the invocation or are affected by an
 * effect that would cause such interruption, deletes the invocation token.
 * Stops if such condition occurs or something else destroys the token.
 *
 * @param oInvoker A creature initiating a invocation
 * @param lInvoker The location where the invoker was when starting the invocation
 * @param oInvokeToken    The invocation token that controls the ongoing invocation
 */
/*void _InvocationHB(object oInvoker, location lInvoker, object oInvokeToken)
{
    if(DEBUG) DoDebug("_InvocationHB() running:\n"
                    + "oInvoker = " + DebugObject2Str(oInvoker) + "\n"
                    + "lInvoker = " + DebugLocation2Str(lInvoker) + "\n"
                    + "oInvokeToken = " + DebugObject2Str(oInvokeToken) + "\n"
                    + "Distance between invocation start location and current location: " + FloatToString(GetDistanceBetweenLocations(lInvoker, GetLocation(oInvoker))) + "\n"
                      );
    if(GetIsObjectValid(oInvokeToken))
    {
        // Continuance check
        if(GetDistanceBetweenLocations(lInvoker, GetLocation(oInvoker)) > 2.0f || // Allow some variance in the location to account for dodging and random fidgeting
           !_InvocationStateCheck(oInvoker)                                       // Action and effect check
           )
        {
            if(DEBUG) DoDebug("_InvocationHB(): invoker moved or lost concentration, destroying token");
            _DestroyInvocationToken(oInvoker, oInvokeToken);

            // Inform invoker
            FloatingTextStrRefOnCreature(16832980, oInvoker, FALSE); // "You have lost concentration on the invocation you were attempting to cast!"
        }
        // Schedule next HB
        else
            DelayCommand(PRC_INVOCATION_HB_DELAY, _InvocationHB(oInvoker, lInvoker, oInvokeToken));
    }
}*/

/** Internal function.
 * Checks if the invoker is in range to use the invocation they are trying to use.
 * If not, queues commands to make the invoker to run into range.
 *
 * @param oInvoker A creature initiating a invocation
 * @param nInvocation      SpellID of the invocation being initiated
 * @param lTarget     The target location or the location of the target object
 */
/*void _InvocationRangeCheck(object oInvoker, int nInvocation, location lTarget)
{
    float fDistance   = GetDistanceBetweenLocations(GetLocation(oInvoker), lTarget);
    float fRangeLimit;
    string sRange     = Get2DACache("spells", "Range", nInvocation);

    // Personal range invocations are always in range
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
}*/

/** Internal function.
 * Assigns the fakecast command that is used to display the conjuration VFX when using an invocation.
 * Separated from UseInvocation() due to a bug with ActionFakeCastSpellAtObject(), which requires
 * use of ClearAllActions() to work around.
 * The problem is that if the target is an item on the ground, if the actor is out of spell
 * range when doing the fakecast, they will run on top of the item instead of to the edge of
 * the spell range. This only happens if there was a "real action" in the actor's action queue
 * immediately prior to the fakecast.
 */
/*void _AssignUseInvocationFakeCastCommands(object oInvoker, object oTarget, location lTarget, int nSpellID)
{
    // Nuke actions to prevent the fakecast action from bugging
    ClearAllActions();

    if(GetIsObjectValid(oTarget))
        ActionCastFakeSpellAtObject(nSpellID, oTarget, PROJECTILE_PATH_TYPE_DEFAULT);
    else
        ActionCastFakeSpellAtLocation(nSpellID, lTarget, PROJECTILE_PATH_TYPE_DEFAULT);
}*/


/** Internal function.
 * Places the cheatcasting of the real invocation into the invoker's action queue.
 */
/*void _UseInvocationAux(object oInvoker, object oInvokeToken, int nSpellId,
                  object oTarget, location lTarget,
                  int nInvocation, int nClass, int nLevelOverride)
{
    if(DEBUG) DoDebug("_UseInvocationAux() running:\n"
                    + "oInvoker = " + DebugObject2Str(oInvoker) + "\n"
                    + "oInvokeToken = " + DebugObject2Str(oInvokeToken) + "\n"
                    + "nSpellId = " + IntToString(nSpellId) + "\n"
                    + "oTarget = " + DebugObject2Str(oTarget) + "\n"
                    + "lTarget = " + DebugLocation2Str(lTarget) + "\n"
                    + "nInvocation = " + IntToString(nInvocation) + "\n"
                    + "nClass = " + IntToString(nClass) + "\n"
                    + "nLevelOverride = " + IntToString(nLevelOverride) + "\n"
                      );

    // Make sure nothing has interrupted this invocation
    if(GetIsObjectValid(oInvokeToken))
    {
        if(DEBUG) DoDebug("_UseInvocationAux(): Token was valid, queueing actual invocation");
        // Set the class to cast as
        SetLocalInt(oInvoker, PRC_INVOKING_CLASS, nClass + 1);

        // Set the invocation's level
        SetLocalInt(oInvoker, PRC_INVOCATION_LEVEL, StringToInt(lookup_spell_innate(nSpellId)));

        if(nLevelOverride != 0)
            AssignCommand(oInvoker, ActionDoCommand(SetLocalInt(oInvoker, PRC_CASTERLEVEL_OVERRIDE, nLevelOverride)));
        if(GetIsObjectValid(oTarget))
            AssignCommand(oInvoker, ActionCastSpellAtObject(nInvocation, oTarget, METAMAGIC_NONE, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
        else
            AssignCommand(oInvoker, ActionCastSpellAtLocation(nInvocation, lTarget, METAMAGIC_NONE, TRUE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
        if(nLevelOverride != 0)
            AssignCommand(oInvoker, ActionDoCommand(DeleteLocalInt(oInvoker, PRC_CASTERLEVEL_OVERRIDE)));

        // Destroy the invocation token for this invocation
        _DestroyInvocationToken(oInvoker, oInvokeToken);
    }
}*/

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct invocation EvaluateInvocation(object oInvoker, object oTarget)
{
    /* Get some data */
    int bIgnoreConstraints = (DEBUG) ? GetLocalInt(oInvoker, INV_DEBUG_IGNORE_CONSTRAINTS) : FALSE;
    // invoker-related stuff
    int nInvokerLevel    = GetInvokerLevel(oInvoker);
    int nInvocationLevel = GetInvocationLevel(oInvoker);
    int nClass           = GetInvokingClass(oInvoker);

    /* Initialise the invocation structure */
    struct invocation invoked;
    invoked.oInvoker             = oInvoker;
    invoked.bCanInvoke           = TRUE; // Assume successfull invocation by default
    invoked.nInvokerLevel        = nInvokerLevel;
    invoked.nInvocationId        = PRCGetSpellId();
    
    if (DEBUG) FloatingTextStringOnCreature(GetName(oInvoker)+" is a "+IntToString(nClass)+" casting invocation "+IntToString(invoked.nInvocationId)+", a "+IntToString(nInvocationLevel)+" level invocation, at "+IntToString(nInvokerLevel)+" invoker level", oInvoker);
    
    // Skip doing anything if something has prevented a successful invocation already by this point
    //if(invoked.bCanInvoke)
    //{
        invoked = _DoInvocationSpellfireFriendlyAbsorption(invoked, oTarget);
    //}//end if

    if(DEBUG) DoDebug("EvaluateInvocation(): Final result:\n" + DebugInvocation2Str(invoked));

    // Initiate invocation-related variable CleanUp
    //DelayCommand(0.5f, _CleanInvocationVariables(oInvoker));

    return invoked;
}

void UseInvocation(int nInvocation, int nClass, int nLevelOverride = 0, int bInstant = FALSE)
{
    if(nClass < 0)
        nClass = CLASS_TYPE_WARLOCK;
    object oInvoker    = OBJECT_SELF;
//    object oSkin       = GetPCSkin(oInvoker);
//    object oTarget     = PRCGetSpellTargetObject();
//    object oInvokeToken;
//    location lTarget   = PRCGetSpellTargetLocation();
//    int nSpellID       = PRCGetSpellId();
    //int nInvocationDur       = StringToInt(Get2DACache("spells", "ConjTime", nInvocation)) + StringToInt(Get2DACache("spells", "CastTime", nInvocation));
    // This is a test case to speed up the impact of the melee attacks, as PerformAttackRound takes the full 6 second.
//    int nInvocationDur       = 0;


    // Setup invocation-related variables
    ActionDoCommand(_SetInvocationVariables(oInvoker, nClass, StringToInt(lookup_spell_innate(nInvocation))));

    // Cast the actual invocation
    //ActionCastSpell(nInvocation, nLevelOverride, 0, 0, METAMAGIC_NONE, CLASS_TYPE_INVALID, 0, 0, OBJECT_INVALID, bInstant);
	ActionCastSpell(nInvocation, nLevelOverride, 0, 0, METAMAGIC_NONE, nClass, 0, 0, OBJECT_INVALID, bInstant);

    // Initiate invocation-related variable CleanUp
    ActionDoCommand(_CleanInvocationVariables(oInvoker));
    // Normally swift action invocations check
    /*if(Get2DACache("feat", "Constant", GetClassFeatFromPower(nInvocation, nClass)) == "SWIFT_ACTION" && // The invocation is swift action to use
       TakeSwiftAction(oInvoker)                                                                        // And the invoker can take a swift action now
       )
    {
        nInvocationDur = 0;
    }*/

    /*if(DEBUG) DoDebug("UseInvocation(): invoker is " + DebugObject2Str(oInvoker) + "\n"
                    + "nInvocation = " + IntToString(nInvocation) + "\n"
                    + "nClass = " + IntToString(nClass) + "\n"
                    + "nLevelOverride = " + IntToString(nLevelOverride) + "\n"
                    + "invocation duration = " + IntToString(nInvocationDur) + "ms \n"
                    //+ "Token exists = " + DebugBool2String(GetIsObjectValid(oInvokeToken))
                      );*/

    // Create the invocation token. Deletes any old tokens and cancels corresponding invocations as a side effect
    //oInvokeToken = _CreateInvocationToken(oInvoker);

    /// @todo Hook to the invoker's OnDamaged event for the concentration checks to avoid losing the invocation

    // Nuke action queue to prevent cheating with creative invocation stacking.
    // Probably not necessary anymore - Ornedan
    //if(DEBUG) SendMessageToPC(oInvoker, "Clearing all actions in preparation for second stage of the invocation.");
    //ClearAllActions();

    // If out of range, move to range
    //_InvocationRangeCheck(oInvoker, nInvocation, GetIsObjectValid(oTarget) ? GetLocation(oTarget) : lTarget);

    // Start the invocation monitor HB
    //DelayCommand(IntToFloat(nInvocationDur), ActionDoCommand(_InvocationHB(oInvoker, GetLocation(oInvoker), oInvokeToken)));

    // Assuming the spell isn't used as a swift action, fakecast for visuals
    /*if(nInvocationDur > 0)
    {
        // Hack. Workaround of a bug with the fakecast actions. See function comment for details
        ActionDoCommand(_AssignUseInvocationFakeCastCommands(oInvoker, oTarget, lTarget, nSpellID));
    }*/

    // Action queue the function that will cheatcast the actual invocation
    //DelayCommand(IntToFloat(nInvocationDur), AssignCommand(oInvoker, ActionDoCommand(_UseInvocationAux(oInvoker, oInvokeToken, nSpellID, oTarget, lTarget, nInvocation, nClass, nLevelOverride))));
}

string DebugInvocation2Str(struct invocation invoked)
{
    string sRet;

    sRet += "oInvoker = " + DebugObject2Str(invoked.oInvoker) + "\n";
    sRet += "bCanInvoke = " + DebugBool2String(invoked.bCanInvoke) + "\n";
    sRet += "nInvokerLevel = "  + IntToString(invoked.nInvokerLevel);

    return sRet;
}

void SetLocalInvocation(object oObject, string sName, struct invocation invoked)
{
    //SetLocal (oObject, sName + "_", );
    SetLocalObject(oObject, sName + "_oInvoker", invoked.oInvoker);

    SetLocalInt(oObject, sName + "_bCanInvoke",      invoked.bCanInvoke);
    SetLocalInt(oObject, sName + "_nInvokerLevel",   invoked.nInvokerLevel);
    SetLocalInt(oObject, sName + "_nSpellID",          invoked.nInvocationId);
}

struct invocation GetLocalInvocation(object oObject, string sName)
{
    struct invocation invoked;
    invoked.oInvoker = GetLocalObject(oObject, sName + "_oInvoker");

    invoked.bCanInvoke             = GetLocalInt(oObject, sName + "_bCanInvoke");
    invoked.nInvokerLevel          = GetLocalInt(oObject, sName + "_nInvokerLevel");
    invoked.nInvocationId          = GetLocalInt(oObject, sName + "_nSpellID");

    return invoked;
}

void DeleteLocalInvocation(object oObject, string sName)
{
    DeleteLocalObject(oObject, sName + "_oInvoker");

    DeleteLocalInt(oObject, sName + "_bCanInvoke");
    DeleteLocalInt(oObject, sName + "_nInvokerLevel");
    DeleteLocalInt(oObject, sName + "_nSpellID");
}

void InvocationDebugIgnoreConstraints(object oInvoker)
{
    SetLocalInt(oInvoker, INV_DEBUG_IGNORE_CONSTRAINTS, TRUE);
    DelayCommand(0.0f, DeleteLocalInt(oInvoker, INV_DEBUG_IGNORE_CONSTRAINTS));
}

// Test main
//void main(){}
