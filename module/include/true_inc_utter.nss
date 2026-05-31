//::///////////////////////////////////////////////
//:: Truenaming include: Uttering
//:: true_inc_Utter
//::///////////////////////////////////////////////
/** @file
    Defines structures and functions for handling
    truespeaking an utterance

    @author Stratovarius
    @date   Created - 2006.7.17
    @thanks to Ornedan for his work on Psionics upon which this is based.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const string PRC_TRUESPEAKING_CLASS        = "PRC_CurrentUtterance_TrueSpeakingClass";
const string PRC_UTTERANCE_LEVEL           = "PRC_CurrentUtterance_Level";
const string TRUE_DEBUG_IGNORE_CONSTRAINTS = "TRUE_DEBUG_IGNORE_CONSTRAINTS";

/**
 * The variable in which the utterance token is stored. If no token exists,
 * the variable is set to point at the truespeaker itself. That way OBJECT_INVALID
 * means the variable is unitialised.
 */
//const string PRC_UTTERANCE_TOKEN_VAR  = "PRC_UtteranceToken";
//const string PRC_UTTERANCE_TOKEN_NAME = "PRC_UTTERTOKEN";
//const float  PRC_UTTERANCE_HB_DELAY   = 0.5f;


//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

// struct utterance moved to true_inc_metautr

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines if the utterance that is currently being attempted to be TrueSpoken
 * can in fact be truespoken. Determines metautterances used.
 *
 * @param oTrueSpeaker  A creature attempting to truespeak a utterance at this moment.
 * @param oTarget       The target of the utterance, if any. For pure Area of Effect.
 *                      utterances, this should be OBJECT_INVALID. Otherwise the main
 *                      target of the utterance as returned by PRCGetSpellTargetObject().
 * @param nMetaUtterFlags The metautterances that may be used to modify this utterance. Any number
 *                      of METAUTTERANCE_* constants ORd together using the | operator.
 *                      For example (METAUTTERANCE_EMPOWER | METAUTTERANCE_EXTEND)
 * @param nLexicon      Whether it is of the Crafted Tool, Evolving Mind or Perfected Map
 *                      Use one of three constants: TYPE_EVOLVING_MIND, TYPE_CRAFTED_TOOL, TYPE_PERFECTED_MAP
 *
 * @return              A utterance structure that contains the data about whether
 *                      the utterance was successfully truespeaked, what metautterances
 *                      were used and some other commonly used data, like the 
 *                      TrueNamer's truespeaker level for this utterance.
 */
struct utterance EvaluateUtterance(object oTrueSpeaker, object oTarget, int nMetaUtterFlags, int nLexicon);

/**
 * Causes OBJECT_SELF to use the given utterance.
 *
 * @param nUtter         The index of the utterance to use in spells.2da or an UTTER_*
 * @param nClass         The index of the class to use the utterance as in classes.2da or a CLASS_TYPE_*
 * @param nLevelOverride An optional override to normal truespeaker level. 
 *                       Default: 0, which means the parameter is ignored.
 */
void UseUtterance(int nUtter, int nClass, int nLevelOverride = 0);

/**
 * A debugging function. Takes a utterance structure and
 * makes a string describing the contents.
 *
 * @param utter A set of utterance data
 * @return      A string describing the contents of utter
 */
string DebugUtterance2Str(struct utterance utter);

/**
 * Stores a utterance structure as a set of local variables. If
 * a structure was already stored with the same name on the same object,
 * it is overwritten.
 *
 * @param oObject The object on which to store the structure
 * @param sName   The name under which to store the structure
 * @param utter   The utterance structure to store
 */
void SetLocalUtterance(object oObject, string sName, struct utterance utter);

/**
 * Retrieves a previously stored utterance structure. If no structure is stored
 * by the given name, the structure returned is empty.
 *
 * @param oObject The object from which to retrieve the structure
 * @param sName   The name under which the structure is stored
 * @return        The structure built from local variables stored on oObject under sName
 */
struct utterance GetLocalUtterance(object oObject, string sName);

/**
 * Deletes a stored utterance structure.
 *
 * @param oObject The object on which the structure is stored
 * @param sName   The name under which the structure is stored
 */
void DeleteLocalUtterance(object oObject, string sName);

/**
 * Sets the evaluation functions to ignore constraints on truespeaking.
 * Call this just prior to EvaluateUtterance() in a utterance script.
 * That evaluation will then ignore lacking utterance ability score,
 * utterance Points and Psionic Focuses.
 *
 * @param oTrueSpeaker A creature attempting to truespeak a utterance at this moment.
 */
void TruenameDebugIgnoreConstraints(object oTrueSpeaker);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "true_inc_metautr"
#include "true_inc_truespk"
#include "inc_newspellbook"
#include "inc_lookups"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * Handles Spellfire absorption when a utterance is used on a friendly spellfire
 * user.
 */
struct utterance _DoTruenameSpellfireFriendlyAbsorption(struct utterance utter, object oTarget)
{
    if(GetLocalInt(oTarget, "SpellfireAbsorbFriendly") &&
       GetIsFriend(oTarget, utter.oTrueSpeaker)
       )
    {
        if(CheckSpellfire(utter.oTrueSpeaker, oTarget, TRUE))
        {
            PRCShowSpellResist(utter.oTrueSpeaker, oTarget, SPELL_RESIST_MANTLE);
            utter.bCanUtter = FALSE;
        }
    }

    return utter;
}

/** Internal function.
 * Deletes utterance-related local variables.
 *
 * @param oTrueSpeaker The creature currently truespeaking a utterance
 */
void _CleanUtteranceVariables(object oTrueSpeaker)
{
    DeleteLocalInt(oTrueSpeaker, PRC_TRUESPEAKING_CLASS);
    DeleteLocalInt(oTrueSpeaker, PRC_UTTERANCE_LEVEL);
}

/** Internal function.
 * Sets utterance-related local variables.
 *
 * @param oTrueSpeaker The creature currently truespeaking a utterance
 * @param nClass       Utterance casting class constant
 * @param nLevel       Utterance level
 * @param bQuicken     If the utterance was quicened 1, else 0
 */
void _SetUtteranceVariables(object oTrueSpeaker, int nClass, int nLevel, int bQuicken)
{
    SetLocalInt(oTrueSpeaker, PRC_TRUESPEAKING_CLASS, nClass + 1);
    SetLocalInt(oTrueSpeaker, PRC_UTTERANCE_LEVEL, nLevel);
    SetLocalInt(oTrueSpeaker, PRC_UTTERANCE_IS_QUICKENED, bQuicken);
}



/** Internal function.
 * Determines whether a utterance token exists. If one does, returns it.
 *
 * @param oTrueSpeaker A creature whose utterance token to get
 * @return            The utterance token if it exists, OBJECT_INVALID otherwise.
 */
/*object _GetUtteranceToken(object oTrueSpeaker)
{
    object oUtrToken = GetLocalObject(oTrueSpeaker, PRC_UTTERANCE_TOKEN_VAR);

    // If the token object is no longer valid, set the variable to point at truespeaker
    if(!GetIsObjectValid(oUtrToken))
    {
        oUtrToken = oTrueSpeaker;
        SetLocalObject(oTrueSpeaker, PRC_UTTERANCE_TOKEN_VAR, oUtrToken);
    }


    // Check if there is no token
    if(oUtrToken == oTrueSpeaker)
        oUtrToken = OBJECT_INVALID;

    return oUtrToken;
}*/

/** Internal function.
 * Destroys the given utterance token and sets the creature's utterance token variable
 * to point at itself.
 *
 * @param oTrueSpeaker The truespeaker whose token to destroy
 * @param oUtrToken    The token to destroy
 */
/*void _DestroyUtteranceToken(object oTrueSpeaker, object oUtrToken)
{
    DestroyObject(oUtrToken);
    SetLocalObject(oTrueSpeaker, PRC_UTTERANCE_TOKEN_VAR, oTrueSpeaker);
}*/

/** Internal function.
 * Destroys the previous utterance token, if any, and creates a new one.
 *
 * @param oTrueSpeaker A creature for whom to create a utterance token
 * @return            The newly created token
 */
/*object _CreateUtteranceToken(object oTrueSpeaker)
{
    object oUtrToken = _GetUtteranceToken(oTrueSpeaker);
    object oStore   = GetObjectByTag("PRC_MANIFTOKEN_STORE"); //GetPCSkin(oTrueSpeaker);

    // Delete any previous tokens
    if(GetIsObjectValid(oUtrToken))
        _DestroyUtteranceToken(oTrueSpeaker, oUtrToken);

    // Create new token and store a reference to it
    oUtrToken = CreateItemOnObject(PRC_UTTERANCE_TOKEN_NAME, oStore);
    SetLocalObject(oTrueSpeaker, PRC_UTTERANCE_TOKEN_VAR, oUtrToken);

    Assert(GetIsObjectValid(oUtrToken), "GetIsObjectValid(oUtrToken)", "ERROR: Unable to create utterance token! Store object: " + DebugObject2Str(oStore), "true_inc_Utter", "_CreateUtteranceToken()");

    return oUtrToken;
}*/

/** Internal function.
 * Determines whether the given truespeaker is doing something that would
 * interrupt truespeaking a utterance or affected by an effect that would do
 * the same.
 *
 * @param oTrueSpeaker A creature on which _UtteranceHB() is running
 * @return            TRUE if the creature can continue truespeaking,
 *                    FALSE otherwise
 */
/*int _UtteranceStateCheck(object oTrueSpeaker)
{
    int nAction = GetCurrentAction(oTrueSpeaker);
    // If the current action is not among those that could either be used to truespeak the utterance or movement, the utterance fails
    if(!(nAction || ACTION_CASTSPELL     || nAction == ACTION_INVALID      ||
         nAction || ACTION_ITEMCASTSPELL || nAction == ACTION_MOVETOPOINT  ||
         nAction || ACTION_USEOBJECT     || nAction == ACTION_WAIT
       ) )
        return FALSE;

    // Affected by something that prevents one from truespeaking
    effect eTest = GetFirstEffect(oTrueSpeaker);
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
        eTest = GetNextEffect(oTrueSpeaker);
    }

    return TRUE;
}*/

/** Internal function.
 * Runs while the given creature is truespeaking. If they move, take other actions
 * that would cause them to interrupt truespeaking the utterance or are affected by an
 * effect that would cause such interruption, deletes the utterance token.
 * Stops if such condition occurs or something else destroys the token.
 *
 * @param oTrueSpeaker A creature truespeaking a utterance
 * @param lTrueSpeaker The location where the truespeaker was when starting the utterance
 * @param oUtrToken    The utterance token that controls the ongoing utterance
 */
/*void _UtteranceHB(object oTrueSpeaker, location lTrueSpeaker, object oUtrToken)
{
    if(DEBUG) DoDebug("_UtteranceHB() running:\n"
                    + "oTrueSpeaker = " + DebugObject2Str(oTrueSpeaker) + "\n"
                    + "lTrueSpeaker = " + DebugLocation2Str(lTrueSpeaker) + "\n"
                    + "oUtrToken = " + DebugObject2Str(oUtrToken) + "\n"
                    + "Distance between utterance start location and current location: " + FloatToString(GetDistanceBetweenLocations(lTrueSpeaker, GetLocation(oTrueSpeaker))) + "\n"
                      );
    if(GetIsObjectValid(oUtrToken))
    {
        // Continuance check
        if(GetDistanceBetweenLocations(lTrueSpeaker, GetLocation(oTrueSpeaker)) > 2.0f || // Allow some variance in the location to account for dodging and random fidgeting
           !_UtteranceStateCheck(oTrueSpeaker)                                       // Action and effect check
           )
        {
            if(DEBUG) DoDebug("_UtteranceHB(): truespeaker moved or lost concentration, destroying token");
            _DestroyUtteranceToken(oTrueSpeaker, oUtrToken);

            // Inform truespeaker
            FloatingTextStrRefOnCreature(16828469, oTrueSpeaker, FALSE); // "You have lost concentration on the utterance you were attempting to truespeak!"
        }
        // Schedule next HB
        else
            DelayCommand(PRC_UTTERANCE_HB_DELAY, _UtteranceHB(oTrueSpeaker, lTrueSpeaker, oUtrToken));
    }
}*/

/** Internal function.
 * Checks if the truespeaker is in range to use the utterance they are trying to use.
 * If not, queues commands to make the truespeaker to run into range.
 *
 * @param oTrueSpeaker A creature truespeaking a utterance
 * @param nUtter      SpellID of the utterance being truespeaked
 * @param lTarget     The target location or the location of the target object
 */
/*void _UtteranceRangeCheck(object oTrueSpeaker, int nUtter, location lTarget)
{
    float fDistance   = GetDistanceBetweenLocations(GetLocation(oTrueSpeaker), lTarget);
    float fRangeLimit;
    string sRange     = Get2DACache("spells", "Range", nUtter);

    // Personal range utterances are always in range
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
        //fRangeLimit /= 2;
        //ActionMoveToObject(oWP, TRUE, fRangeLimit - 0.15f);

        // CleanUp
        ActionDoCommand(DestroyObject(oWP));

        // CleanUp, paranoia
        AssignCommand(oWP, ActionDoCommand(DestroyObject(oWP, 60.0f)));
    }
}*/

/** Internal function.
 * Assigns the fakecast command that is used to display the conjuration VFX when using an utterance.
 * Separated from UseUtterance() due to a bug with ActionFakeCastSpellAtObject(), which requires
 * use of ClearAllActions() to work around.
 * The problem is that if the target is an item on the ground, if the actor is out of spell
 * range when doing the fakecast, they will run on top of the item instead of to the edge of
 * the spell range. This only happens if there was a "real action" in the actor's action queue
 * immediately prior to the fakecast.
 */
/*void _AssignUseUtteranceFakeCastCommands(object oTrueSpeaker, object oTarget, location lTarget, int nSpellID)
{
    // Nuke actions to prevent the fakecast action from bugging
    ClearAllActions();

    if(GetIsObjectValid(oTarget))
        ActionCastFakeSpellAtObject(nSpellID, oTarget, PROJECTILE_PATH_TYPE_DEFAULT);
    else
        ActionCastFakeSpellAtLocation(nSpellID, lTarget, PROJECTILE_PATH_TYPE_DEFAULT);
}*/


/** Internal function.
 * Places the cheatcasting of the real utterance into the truespeaker's action queue.
 */
/*void _UseUtteranceAux(object oTrueSpeaker, object oUtrToken, int nSpellId,
                  object oTarget, location lTarget,
                  int nUtter, int nClass, int nLevelOverride,
                  int bQuickened
                  )
{
    if(DEBUG) DoDebug("_UseUtteranceAux() running:\n"
                    + "oTrueSpeaker = " + DebugObject2Str(oTrueSpeaker) + "\n"
                    + "oUtrToken = " + DebugObject2Str(oUtrToken) + "\n"
                    + "nSpellId = " + IntToString(nSpellId) + "\n"
                    + "oTarget = " + DebugObject2Str(oTarget) + "\n"
                    + "lTarget = " + DebugLocation2Str(lTarget) + "\n"
                    + "nUtter = " + IntToString(nUtter) + "\n"
                    + "nClass = " + IntToString(nClass) + "\n"
                    + "nLevelOverride = " + IntToString(nLevelOverride) + "\n"
                    + "bQuickened = " + DebugBool2String(bQuickened) + "\n"
                      );

    // Make sure nothing has interrupted this utterance
    if(GetIsObjectValid(oUtrToken))
    {
        if(DEBUG) DoDebug("_UseUtteranceAux(): Token was valid, queueing actual utterance");
        // Set the class to truespeak as
        SetLocalInt(oTrueSpeaker, PRC_TRUESPEAKING_CLASS, nClass + 1);

        // Set the utterance's level
        SetLocalInt(oTrueSpeaker, PRC_UTTERANCE_LEVEL, StringToInt(lookup_spell_innate(nSpellId)));

        // Set whether the utterance was quickened
        SetLocalInt(oTrueSpeaker, PRC_UTTERANCE_IS_QUICKENED, bQuickened);

        // Queue the real utterance
        //ActionCastSpell(nUtter, nLevelOverride, 0, 0, METAMAGIC_NONE, CLASS_TYPE_INVALID, TRUE, TRUE, oTarget);

        if(nLevelOverride != 0)
            AssignCommand(oTrueSpeaker, ActionDoCommand(SetLocalInt(oTrueSpeaker, PRC_CASTERLEVEL_OVERRIDE, nLevelOverride)));
        if(GetIsObjectValid(oTarget))
            AssignCommand(oTrueSpeaker, ActionCastSpellAtObject(nUtter, oTarget, METAMAGIC_NONE, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
        else
            AssignCommand(oTrueSpeaker, ActionCastSpellAtLocation(nUtter, lTarget, METAMAGIC_NONE, TRUE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
        if(nLevelOverride != 0)
            AssignCommand(oTrueSpeaker, ActionDoCommand(DeleteLocalInt(oTrueSpeaker, PRC_CASTERLEVEL_OVERRIDE)));

        // Destroy the utterance token for this utterance
        _DestroyUtteranceToken(oTrueSpeaker, oUtrToken);
    }
}*/


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct utterance EvaluateUtterance(object oTrueSpeaker, object oTarget, int nMetaUtterFlags, int nLexicon)
{
    /* Get some data */
    int bIgnoreConstraints = (DEBUG) ? GetLocalInt(oTrueSpeaker, TRUE_DEBUG_IGNORE_CONSTRAINTS) : FALSE;
    // truespeaker-related stuff
    int nTruespeakerLevel = GetTruespeakerLevel(oTrueSpeaker);
    int nUtterLevel      = GetUtteranceLevel(oTrueSpeaker);
    int nClass           = GetTruespeakingClass(oTrueSpeaker);

    /* Initialise the utterance structure */
    struct utterance utter;
    utter.oTrueSpeaker      = oTrueSpeaker;
    utter.bCanUtter         = TRUE;                                   // Assume successfull utterance by default
    utter.nTruespeakerLevel = nTruespeakerLevel;
    utter.nSpellId          = PRCGetSpellId();
    utter.nUtterDC          = GetBaseUtteranceDC(oTarget, oTrueSpeaker, nLexicon);

    // Account for metautterances. This includes adding the appropriate DC boosts.
    utter = EvaluateMetautterances(utter, nMetaUtterFlags);
    // Account for the law of resistance
    utter.nUtterDC += GetLawOfResistanceDCIncrease(oTrueSpeaker, utter.nSpellId);
    // DC change for targeting self and using a Personal Truename
    utter.nUtterDC += AddPersonalTruenameDC(oTrueSpeaker, oTarget);  
    // DC change for ignoring Spell Resistance
    utter.nUtterDC += AddIgnoreSpellResistDC(oTrueSpeaker);
    // DC change for specific utterances
    utter.nUtterDC += AddUtteranceSpecificDC(oTrueSpeaker);
    
    // Skip paying anything if something has prevented successfull utterance already by this point
    if(utter.bCanUtter)
    {
        /* Roll the dice, and see if we succeed or fail.
         */
        if(GetIsSkillSuccessful(oTrueSpeaker, SKILL_TRUESPEAK, utter.nUtterDC) || bIgnoreConstraints)
        {
        	// Increases the DC of the subsequent utterances
        	DoLawOfResistanceDCIncrease(oTrueSpeaker, utter.nSpellId);
                // Spellfire friendly absorption - This may set bCananifest to FALSE
                utter = _DoTruenameSpellfireFriendlyAbsorption(utter, oTarget);
                //* APPLY SIDE-EFFECTS THAT RESULT FROM SUCCESSFULL UTTERANCE ABOVE *//

        }
        // Failed the DC roll
        else
        {
            // No need for an output here because GetIsSkillSuccessful does it for us.
            utter.bCanUtter = FALSE;
        }
    }//end if

    if(DEBUG) DoDebug("EvaluateUtterance(): Final result:\n" + DebugUtterance2Str(utter));

    // Initiate utterance-related variable CleanUp
    //DelayCommand(0.5f, _CleanUtteranceVariables(oTrueSpeaker));

    return utter;
}

/*void UseUtterance(int nUtter, int nClass, int nLevelOverride = 0)
{
    object oTrueSpeaker = OBJECT_SELF;
    object oSkin       = GetPCSkin(oTrueSpeaker);
    object oTarget     = PRCGetSpellTargetObject();
    object oUtrToken;
    location lTarget   = PRCGetSpellTargetLocation();
    int nSpellID       = PRCGetSpellId();
    int nUtterDur      = StringToInt(Get2DACache("spells", "ConjTime", nUtter)) + StringToInt(Get2DACache("spells", "CastTime", nUtter));
    int bQuicken       = FALSE;

    // Normally swift action utterances check
    if(Get2DACache("feat", "Constant", GetClassFeatFromPower(nUtter, nClass)) == "SWIFT_ACTION" && // The utterance is swift action to use
       TakeSwiftAction(oTrueSpeaker)                                                                // And the truespeaker can take a swift action now
       )
    {
        nUtterDur = 0;
    }
    // Quicken utterance check
    else if(nUtterDur <= 6000                                 && // If the utterance could be quickened by having truespeaking time of 1 round or less
            GetLocalInt(oTrueSpeaker, METAUTTERANCE_QUICKEN_VAR) && // And the truespeaker has Quicken utterance active
            TakeSwiftAction(oTrueSpeaker)                         // And the truespeaker can take a swift action
            )
    {
        // Set the utterance time to 0 to skip VFX
        nUtterDur = 0;
        // And set the Quicken utterance used marker to TRUE
        bQuicken = TRUE;
    }

    if(DEBUG) DoDebug("UseUtterance(): truespeaker is " + DebugObject2Str(oTrueSpeaker) + "\n"
                    + "nUtter = " + IntToString(nUtter) + "\n"
                    + "nClass = " + IntToString(nClass) + "\n"
                    + "nLevelOverride = " + IntToString(nLevelOverride) + "\n"
                    + "utterance duration = " + IntToString(nUtterDur) + "ms \n"
                    + "bQuicken = " + DebugBool2String(bQuicken) + "\n"
                    //+ "Token exists = " + DebugBool2String(GetIsObjectValid(oUtrToken))
                      );

    // Create the utterance token. Deletes any old tokens and cancels corresponding utterances as a side effect
    oUtrToken = _CreateUtteranceToken(oTrueSpeaker);

    /// @todo Hook to the truespeaker's OnDamaged event for the concentration checks to avoid losing the utterance

    // Nuke action queue to prevent cheating with creative utterance stacking.
    // Probably not necessary anymore - Ornedan
    if(DEBUG) SendMessageToPC(oTrueSpeaker, "Clearing all actions in preparation for second stage of the utterance.");
    ClearAllActions();

    // If out of range, move to range
    _UtteranceRangeCheck(oTrueSpeaker, nUtter, GetIsObjectValid(oTarget) ? GetLocation(oTarget) : lTarget);

    // Start the utterance monitor HB
    DelayCommand(nUtterDur / 1000.0f, ActionDoCommand(_UtteranceHB(oTrueSpeaker, GetLocation(oTrueSpeaker), oUtrToken)));

    // Assuming the spell isn't used as a swift action, fakecast for visuals
    if(nUtterDur > 0)
    {
        // Hack. Workaround of a bug with the fakecast actions. See function comment for details
        ActionDoCommand(_AssignUseUtteranceFakeCastCommands(oTrueSpeaker, oTarget, lTarget, nSpellID));
    }

    // Action queue the function that will cheatcast the actual utterance
    DelayCommand(nUtterDur / 1000.0f, AssignCommand(oTrueSpeaker, ActionDoCommand(_UseUtteranceAux(oTrueSpeaker, oUtrToken, nSpellID, oTarget, lTarget, nUtter, nClass, nLevelOverride, bQuicken))));
}*/

void UseUtterance(int nUtter, int nClass, int nLevelOverride = 0)
{
    object oTrueSpeaker = OBJECT_SELF;
    int bQuickened = FALSE;
    int nUtterDur      = StringToInt(Get2DACache("spells", "ConjTime", nUtter)) + StringToInt(Get2DACache("spells", "CastTime", nUtter));
    
    // Check the Law of Sequence. Returns True if the utterance is active
    if (CheckLawOfSequence(oTrueSpeaker, nUtter))
    {
        FloatingTextStringOnCreature("You already have " + GetUtteranceName(nUtter) + " active. Utterance Failed.", oTrueSpeaker, FALSE);
        return;
    }    

    // Quicken utterance check
    if(nUtterDur <= 6000                                 &&     // If the utterance could be quickened by having truespeaking time of 1 round or less
       GetLocalInt(oTrueSpeaker, METAUTTERANCE_QUICKEN_VAR) &&  // And the truespeaker has Quicken utterance active
       TakeSwiftAction(oTrueSpeaker))                           // And the truespeaker can take a swift action
    {
        //Adding Auto-Quicken III for one round - deleted after casting is finished.
        object oSkin = GetPCSkin(oTrueSpeaker);
        itemproperty ipAutoQuicken = ItemPropertyBonusFeat(IP_CONST_NSB_AUTO_QUICKEN);
        ActionDoCommand(AddItemProperty(DURATION_TYPE_TEMPORARY, ipAutoQuicken, oSkin, nUtterDur/1000.0f));
        bQuickened = TRUE;
    }

    // Setup utterance-related variables
    ActionDoCommand(_SetUtteranceVariables(oTrueSpeaker, nClass, StringToInt(lookup_spell_innate(nUtter)), bQuickened));

    // cast the actual utterance
    ActionCastSpell(nUtter, nLevelOverride, 0, 0, METAMAGIC_NONE, CLASS_TYPE_INVALID, 0, 0, OBJECT_INVALID, FALSE);

    // Initiate utterance-related variable CleanUp
    ActionDoCommand(_CleanUtteranceVariables(oTrueSpeaker));
}

string DebugUtterance2Str(struct utterance utter)
{
    string sRet;

    sRet += "oTrueSpeaker = " + DebugObject2Str(utter.oTrueSpeaker) + "\n";
    sRet += "bCanUtter = " + DebugBool2String(utter.bCanUtter) + "\n";
    sRet += "nTruespeakerLevel = "  + IntToString(utter.nTruespeakerLevel) + "\n";

    sRet += "bEmpower  = " + DebugBool2String(utter.bEmpower)  + "\n";
    sRet += "bExtend   = " + DebugBool2String(utter.bExtend)   + "\n";
    sRet += "bQuicken  = " + DebugBool2String(utter.bQuicken);//    + "\n";

    return sRet;
}

void SetLocalUtterance(object oObject, string sName, struct utterance utter)
{
    //SetLocal (oObject, sName + "_", );
    SetLocalObject(oObject, sName + "_oTrueSpeaker", utter.oTrueSpeaker);

    SetLocalInt(oObject, sName + "_bCanUtter",      utter.bCanUtter);
    SetLocalInt(oObject, sName + "_nTruespeakerLevel",  utter.nTruespeakerLevel);
    SetLocalInt(oObject, sName + "_nSpellID",          utter.nSpellId);

    SetLocalInt(oObject, sName + "_bEmpower",  utter.bEmpower);
    SetLocalInt(oObject, sName + "_bExtend",   utter.bExtend);
    SetLocalInt(oObject, sName + "_bQuicken",  utter.bQuicken);
}

struct utterance GetLocalUtterance(object oObject, string sName)
{
    struct utterance utter;
    utter.oTrueSpeaker = GetLocalObject(oObject, sName + "_oTrueSpeaker");

    utter.bCanUtter      = GetLocalInt(oObject, sName + "_bCanUtter");
    utter.nTruespeakerLevel  = GetLocalInt(oObject, sName + "_nTruespeakerLevel");
    utter.nSpellId          = GetLocalInt(oObject, sName + "_nSpellID");

    utter.bEmpower  = GetLocalInt(oObject, sName + "_bEmpower");
    utter.bExtend   = GetLocalInt(oObject, sName + "_bExtend");
    utter.bQuicken  = GetLocalInt(oObject, sName + "_bQuicken");

    return utter;
}

void DeleteLocalUtterance(object oObject, string sName)
{
    DeleteLocalObject(oObject, sName + "_oTrueSpeaker");

    DeleteLocalInt(oObject, sName + "_bCanUtter");
    DeleteLocalInt(oObject, sName + "_nTruespeakerLevel");
    DeleteLocalInt(oObject, sName + "_nSpellID");

    DeleteLocalInt(oObject, sName + "_bEmpower");
    DeleteLocalInt(oObject, sName + "_bExtend");
    DeleteLocalInt(oObject, sName + "_bQuicken");
}

void TruenameDebugIgnoreConstraints(object oTrueSpeaker)
{
    SetLocalInt(oTrueSpeaker, TRUE_DEBUG_IGNORE_CONSTRAINTS, TRUE);
    DelayCommand(0.0f, DeleteLocalInt(oTrueSpeaker, TRUE_DEBUG_IGNORE_CONSTRAINTS));
}

// Test main
//void main(){}
