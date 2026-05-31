//:://////////////////////////////////////////////
//:: Dynamic Conversation System include
//:: inc_dynconv
//:://////////////////////////////////////////////
/** @file



    @author Primogenitor
    @date   2005.09.23 - Rebuilt the system - Ornedan
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//PRC8 Token pre-fix = 161838

//////////////////////////////////////////////////
/* Constant definitions                         */
//////////////////////////////////////////////////

const int DYNCONV_EXITED        = -2;
const int DYNCONV_ABORTED       = -3;
const int DYNCONV_SETUP_STAGE   = -1;

const int DYNCONV_TOKEN_HEADER  = 16183899;
const int DYNCONV_TOKEN_REPLY_0 = 161838100;
const int DYNCONV_TOKEN_REPLY_1 = 161838101;
const int DYNCONV_TOKEN_REPLY_2 = 161838102;
const int DYNCONV_TOKEN_REPLY_3 = 161838103;
const int DYNCONV_TOKEN_REPLY_4 = 161838104;
const int DYNCONV_TOKEN_REPLY_5 = 161838105;
const int DYNCONV_TOKEN_REPLY_6 = 161838106;
const int DYNCONV_TOKEN_REPLY_7 = 161838107;
const int DYNCONV_TOKEN_REPLY_8 = 161838108;
const int DYNCONV_TOKEN_REPLY_9 = 161838109;
const int DYNCONV_TOKEN_EXIT    = 161838110;
const int DYNCONV_TOKEN_WAIT    = 161838111;
const int DYNCONV_TOKEN_NEXT    = 161838112;
const int DYNCONV_TOKEN_PREV    = 161838113;
const int DYNCONV_MIN_TOKEN     = 16183899;
const int DYNCONV_MAX_TOKEN     = 161838113;

const int DYNCONV_STRREF_PLEASE_WAIT = 16824202; // "Please wait"
const int DYNCONV_STRREF_PREVIOUS    = 16824203; // "Previous"
const int DYNCONV_STRREF_NEXT        = 16824204; // "Next"
const int DYNCONV_STRREF_ABORT_CONVO = 16824212; // "Abort"
const int DYNCONV_STRREF_EXIT_CONVO  = 78;       // "Exit"

const string DYNCONV_SCRIPT         = "DynConv_Script";
const string DYNCONV_VARIABLE       = "DynConv_Var";
const string DYNCONV_STAGE          = "DynConv_Stage";
const string DYNCONV_TOKEN_BASE     = "DynConv_TOKEN";
const string DYNCONV_CHOICEOFFSET   = "ChoiceOffset";

/**
 * Exiting the conversation is not allowed. The exit
 * choice is not shown
 */
const int DYNCONV_EXIT_NOT_ALLOWED         = 0;
/**
 * Exiting the conversation is allowed and it is
 * forced to exit due to no nodes being shown.
 */
const int DYNCONV_EXIT_FORCE_EXIT          = -1;
/**
 * Exiting the conversation is allowed and the exit
 * choice is shown.
 */
const int DYNCONV_EXIT_ALLOWED_SHOW_CHOICE = 1;


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Sets the header token and reply tokens for the PC to values stored
 * via SetHeader and AddChoice, respectively.
 *
 * @param oPC The PC involved in the conversation. If left
 *            to default, GetPCSpeaker is used
 */
void SetupTokens(object oPC = OBJECT_INVALID);

/**
 * Builds the local variable name for a token.
 *
 * @param nTokenID One of the DYNCONV_TOKEN_* constants
 */
string GetTokenIDString(int nTokenID);

/**
 * Sets the dynamic conversation header. ie, the "NPC"'s reply.
 *
 * @param sText The text to set the header to
 * @param oPC   The PC involved in the conversation. If left
 *              to default, GetPCSpeaker is used
 */
void SetHeader(string sText, object oPC = OBJECT_INVALID);

/**
 * A wrapper for SetHeader() that uses TLK references.
 *
 * @param nStrRef The TLK entry to use
 * @param oPC     The PC involved in the conversation. If left
 *                to default, GetPCSpeaker is used
 */
void SetHeaderStrRef(int nStrRef, object oPC = OBJECT_INVALID);

/**
 * Add a reply choice to be displayed. The replies are displayed in
 * the same order as they are added.
 *
 * @param sText  The text of the choice
 * @param nValue The numeric value of the choice. This is what will be
 *               returned by GetChoice()
 * @param oPC    The PC involved in the conversation. If left
 *               to default, GetPCSpeaker is used
 */
void AddChoice(string sText, int nValue, object oPC = OBJECT_INVALID);

/**
 * A wrapper for AddChoice() that uses TLK references.
 *
 * @param nStrRef The TLK entry to use
 * @param nValue  The numeric value of the choice. This is what will be
 *                returned by GetChoice()
 * @param oPC     The PC involved in the conversation. If left
 *                to default, GetPCSpeaker is used
 */
void AddChoiceStrRef(int nStrRef, int nValue, object oPC = OBJECT_INVALID);

/**
 * Sets the custom token at nTokenID to be the given string and stores
 * the value in a local variable on OBJECT_SELF.
 * Used by the dyynamic onversation system to track token assignment.
 *
 * @param nTokenID The custom token number to store the string in
 * @param sString  The string to store
 * @param oPC      The PC whose conversation this token belongs to
 */
void SetToken(int nTokenID, string sString, object oPC = OBJECT_SELF);

/**
 * Sets the default values for the Exit, Wait, Next and Previous
 * tokens. The values will be as follows, or their translated
 * equivalents should a non-english TLK be used.
 *
 * Exit = "Exit"
 * Wait = "Please wait"
 * Next = "Next"
 * Previous = "Previous"
 */
void SetDefaultTokens();

/**
 * Changes the conversation stage. If the new stage given is
 * the same as the current, nothing happens. Otherwise
 * the stage is changed and the choices stored for the old
 * stage are deleted.
 *
 * @param nNewStage The stage to enter
 * @param oPC       The PC involved in the conversation. If left
 *                  to default, GetPCSpeaker is used
 */
void SetStage(int nNewStage, object oPC = OBJECT_INVALID);

/**
 * Gets the current stage of the conversation.
 *
 * @param oPC The PC involved in the conversation. If left
 *            to default, GetPCSpeaker is used
 * @return    The current stage of the conversation, as previously
 *            set via SetStage() or 0 if no calls to SetStage()
 *            have been done yet.
 */
int GetStage(object oPC = OBJECT_INVALID);

/**
 * Gets the value of the choice selected by the PC.
 *
 * @param oPC The PC involved in the conversation. If left
 *            to default, GetPCSpeaker is used
 * @return    The value of the choice the PC made, as set
 *            by a call to AddChoice().
 */
int GetChoice(object oPC = OBJECT_INVALID);

/**
 * Gets the text of the choice selected by the PC.
 *
 * @param oPC The PC involved in the conversation. If left
 *            to default, GetPCSpeaker is used
 * @return    The text of the choice the PC made, as set
 *            by a call to AddChoice().
 */
string GetChoiceText(object oPC = OBJECT_INVALID);

/**
 * Starts a dynamic conversation. Results are unspecified if called while
 * already inside a dynamic conversation.
 *
 * @param sConversationScript The script to use for controlling the conversation.
 * @param oPC                 The PC that is to be doing the responding in the conversation.
 * @param bAllowExit          One of the DYNCONV_EXIT_* constants.
 * @param bAllowAbort         If TRUE, the PC is allowed to aborts the conversation by moving / doing
 *                            some other action or being involved in combat. This can be changed later
 *                            on using AllowAbort()
 * @param bForceStart         If TRUE, the PC's actions are cleared, so the conversation starts immediately
 *                            and cannot be avoided by the PC cancelling the action while it is in the queue.
 * @param oConverseWith       The object to speak the "NPC" side of the conversation. Usually, this is also
 *                            the PC, which will be used when this parameter is left to it's default value.
 *                            NOTE: If this parameter is given a value other than OBJECT_INVALID, no validity
 *                            testing is performed upon that object. The function caller needs to make sure
 *                            the object exists.
 */
void StartDynamicConversation(string sConversationScript, object oPC,
                              int nAllowExit = DYNCONV_EXIT_ALLOWED_SHOW_CHOICE, int bAllowAbort = FALSE,
                              int bForceStart = FALSE, object oConverseWith = OBJECT_INVALID);

/**
 * Starts using another dynamic conversation script while inside a
 * dynamic conversation. Should only be called from a dynamic conversation
 * script.
 * The current conversation's script and allow exit/abort variables are
 * saved. When the conversation entered via this call exits, the system
 * returns to the current conversation, with stage being the one specified
 * in the call to this function.
 * NOTE: Any stage setup markers are not stored for the return.
 *
 * @param sConversationToEnter The conversation script to use in the branch
 * @param nStageToReturnTo     The value of stage variable upong return
 *                             from the branch.
 * @param bAllowExit           The branch's initial exit allowance state. See
 *                             StartDynamicConversation() for more details.
 * @param bAllowAbort          The branch's initial abort allowance state. See
 *                             StartDynamicConversation() for more details.
 * @param oPC                  The PC involved in the conversation. If left
 *                             to default, GetPCSpeaker is used.
 */
void BranchDynamicConversation(string sConversationToEnter, int nStageToReturnTo,
                               int bAllowExit = TRUE, int bAllowAbort = FALSE,
                               object oPC = OBJECT_INVALID);

/**
 * Marks the current dynconvo as exitable via the exit conversation
 * choice.
 *
 * @param nNewValue            One of the DYNCONV_EXIT_* constants
 * @param bChangeExitTokenText If this is TRUE, then changes the text on
 *                             DYNCONV_TOKEN_EXIT to "Exit"
 * @param oPC                  The PC involved in the conversation. If left
 *                             to default, GetPCSpeaker is used.
 */
void AllowExit(int nNewValue = DYNCONV_EXIT_ALLOWED_SHOW_CHOICE, int bChangeExitTokenText = TRUE, object oPC = OBJECT_INVALID);

/**
 * Marks the conversation as abortable, meaning that the player is
 * allowed to leave the conversation via means other than the
 * exit conversation choice.
 *
 * @param oPC The PC involved in the conversation. If left to
 *            default, GetPCSpeaker is used.
 */
void AllowAbort(object oPC = OBJECT_INVALID);

/**
 * Checks whether the given stage is marked as already set up.
 *
 * @param nStage The stage to check
 * @param oPC    The PC involved in the conversation. If left to
 *               default, GetPCSpeaker is used.
 */
int GetIsStageSetUp(int nStage, object oPC = OBJECT_INVALID);

/**
 * Marks a stage as being set up. This means that when
 * the conversation script is called to set up the
 * stage, nothing is done and old values are used instead.
 * This is useful for scrolling lists, as CPU is not
 * wasted on rebuilding the exact same list.
 *
 * @param nStage The stage to set marker for
 * @param oPC    The PC involved in the conversation. If left to
 *               default, GetPCSpeaker is used.
 */
void MarkStageSetUp(int nStage, object oPC = OBJECT_INVALID);

/**
 * Marks the stage as not set up. This is used to undo
 * the effects of MarkStageSetUp() when there is
 * need to rerun the stage's builder.
 * An example of such situation would be returning to
 * a stage from another.
 *
 * @param nStage The stage to unset marker for
 * @param oPC    The PC involved in the conversation. If left to
 *               default, GetPCSpeaker is used.
 */
void MarkStageNotSetUp(int nStage, object oPC = OBJECT_INVALID);

/**
 * Clears the current stage's choices and marks it not set up.
 *
 * @param oPC    The PC involved in the conversation. If left to
 *               default, GetPCSpeaker is used.
 */
void ClearCurrentStage(object oPC = OBJECT_INVALID);



//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

#include "prc_inc_array"
#include "inc_debug"

//////////////////////////////////////////////////
/* Internal function prototypes                 */
//////////////////////////////////////////////////

void _DynConvInternal_ExitedConvo(object oPC, int bAbort);
void _DynConvInternal_RunScript(object oPC, int nDynConvVar);
void _DynConvInternal_PreScript(object oPC);
void _DynConvInternal_PostScript(object oPC);
object _DynConvInternal_ResolvePC(object oPC);


//////////////////////////////////////////////////
/* Function Definitions                         */
//////////////////////////////////////////////////

void SetupTokens(object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);
    // Set header
    SetCustomToken(DYNCONV_TOKEN_HEADER, GetLocalString(oPC, "DynConv_HeaderText"));

    // Set reply tokens. Assumes that the tokens used are a continuous block.
    int nOffset = GetLocalInt(oPC, DYNCONV_CHOICEOFFSET);
    int i;
    for (i = 0; i < 10; i++)
    {
        SetToken(DYNCONV_TOKEN_REPLY_0 + i, array_get_string(oPC, "ChoiceTokens", nOffset + i), oPC);
    }
}

void SetHeader(string sText, object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);
    SetLocalString(oPC, "DynConv_HeaderText", sText);
}

void SetHeaderStrRef(int nStrRef, object oPC = OBJECT_INVALID)
{
    SetHeader(GetStringByStrRef(nStrRef), oPC);
}

string GetTokenIDString(int nTokenID)
{
    return DYNCONV_TOKEN_BASE + IntToString(nTokenID);
}

void AddChoice(string sText, int nValue, object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);
    if(!array_exists(oPC, "ChoiceTokens"))
        array_create(oPC, "ChoiceTokens");
    if(!array_exists(oPC, "ChoiceValues"))
        array_create(oPC, "ChoiceValues");
    array_set_string(oPC, "ChoiceTokens", array_get_size(oPC, "ChoiceTokens"), sText);
    array_set_int   (oPC, "ChoiceValues", array_get_size(oPC, "ChoiceValues"), nValue);
}

void AddChoiceStrRef(int nStrRef, int nValue, object oPC = OBJECT_INVALID)
{
    AddChoice(GetStringByStrRef(nStrRef), nValue, oPC);
}

void SetToken(int nTokenID, string sString, object oPC = OBJECT_SELF)
{
    // Set the token
    SetCustomToken(nTokenID, sString);
    // Set a marker on the PC for the reply conditional scripts to check
    SetLocalString(oPC, GetTokenIDString(nTokenID), sString);
}

string GetToken(int nTokenID, object oPC = OBJECT_SELF)
{
    // Set a marker on the PC for the reply conditional scripts to check
    return GetLocalString(oPC, GetTokenIDString(nTokenID));
}

void SetDefaultTokens()
{
    SetCustomToken(DYNCONV_TOKEN_EXIT, GetStringByStrRef(DYNCONV_STRREF_EXIT_CONVO));
    SetCustomToken(DYNCONV_TOKEN_WAIT, GetStringByStrRef(DYNCONV_STRREF_PLEASE_WAIT));
    SetCustomToken(DYNCONV_TOKEN_NEXT, GetStringByStrRef(DYNCONV_STRREF_NEXT));
    SetCustomToken(DYNCONV_TOKEN_PREV, GetStringByStrRef(DYNCONV_STRREF_PREVIOUS));
}

void _DynConvInternal_ExitedConvo(object oPC, int bAbort)
{
    // Restart convo if not allowed to leave yet
    if(bAbort && !GetLocalInt(oPC, "DynConv_AllowAbort")) // Allowed to abort?
    {
        if(DEBUG) DoDebug("_DynConvInternal_ExitedConvo(): Conversation aborted, restarting.");
        AssignCommand(oPC, ClearAllActions(TRUE));
        AssignCommand(oPC, ActionStartConversation(oPC, "dyncov_base", TRUE, FALSE));
        SetLocalInt(oPC, "DynConv_RestartMarker", TRUE);
    }
    // Allowed to exit? Technically, the only way this branch should ever be run is by there not being any response choices available
    else if(!bAbort &&
            (GetLocalInt(oPC, "DynConv_AllowExit") == DYNCONV_EXIT_NOT_ALLOWED))
    {
        if(DEBUG) DoDebug("_DynConvInternal_ExitedConvo(): ERROR: Conversation exited via exit node while exiting not allowed!\n"
                        + "DYNCONV_SCRIPT = '" + GetLocalString(oPC, DYNCONV_SCRIPT) + "'\n"
                          );

        AssignCommand(oPC, ClearAllActions(TRUE));
        AssignCommand(oPC, ActionStartConversation(oPC, "dyncov_base", TRUE, FALSE));
        SetLocalInt(oPC, "DynConv_RestartMarker", TRUE);
    }
    else{
        // Run the conversation script's exit handler
        SetLocalInt(oPC, DYNCONV_VARIABLE, bAbort ? DYNCONV_ABORTED : DYNCONV_EXITED);
        ExecuteScript(GetLocalString(oPC, DYNCONV_SCRIPT), OBJECT_SELF);

        // If there are entries remaining in the stack, pop the previous conversation
        if(GetLocalInt(oPC, "DynConv_Stack"))
        {
            if(DEBUG) DoDebug("_DynConvInternal_ExitedConvo(): Exited a branch");
            // Clean up after the previous conversation
            array_delete(oPC, "ChoiceTokens");
            array_delete(oPC, "ChoiceValues");
            array_delete(oPC, "StagesSetup");
            DeleteLocalInt(oPC, "ChoiceOffset");

            // Pop the data from the stack
            int nStack      = GetLocalInt(oPC, "DynConv_Stack");
            int nStage      = GetLocalInt(oPC, "DynConv_Stack_ReturnToStage_" + IntToString(nStack));
            int nAllowExit  = GetLocalInt(oPC, "DynConv_Stack_AllowExit_"     + IntToString(nStack));
            int nAllowAbort = GetLocalInt(oPC, "DynConv_Stack_AllowAbort_"    + IntToString(nStack));
            string sScript = GetLocalString(oPC, "DynConv_Stack_Script_" + IntToString(nStack));

            // Delete the stack level
            DeleteLocalInt(oPC, "DynConv_Stack_ReturnToStage_" + IntToString(nStack));
            DeleteLocalInt(oPC, "DynConv_Stack_AllowExit_"     + IntToString(nStack));
            DeleteLocalInt(oPC, "DynConv_Stack_AllowAbort_"    + IntToString(nStack));
            DeleteLocalString(oPC, "DynConv_Stack_Script_" + IntToString(nStack));
            if(nStack - 1 > 0) SetLocalInt(oPC, "DynConv_Stack", nStack - 1);
            else DeleteLocalInt(oPC, "DynConv_Stack");

            // Store the date in the conversation variables
            SetLocalInt(oPC, DYNCONV_STAGE, nStage);
            SetLocalInt(oPC, "DynConv_AllowExit", nAllowExit);
            SetLocalInt(oPC, "DynConv_AllowAbort", nAllowAbort);
            SetLocalString(oPC, DYNCONV_SCRIPT, sScript);

            // Restart the conversation
            AssignCommand(oPC, ClearAllActions(TRUE));
            AssignCommand(oPC, ActionStartConversation(oPC, "dyncov_base", TRUE, FALSE));
        }
        // Fully exited the conversation. Clean up
        else
        {
            if(DEBUG) DoDebug("_DynConvInternal_ExitedConvo(): Fully exited conversation");
            array_delete(oPC, "ChoiceTokens");
            array_delete(oPC, "ChoiceValues");
            array_delete(oPC, "StagesSetup");

            DeleteLocalInt(oPC, "ChoiceOffset");
            DeleteLocalInt(oPC, "DynConv_AllowExit");
            DeleteLocalInt(oPC, "DynConv_AllowAbort");

            DeleteLocalInt(oPC, DYNCONV_VARIABLE);
            DeleteLocalInt(oPC, DYNCONV_STAGE);
            DeleteLocalString(oPC, DYNCONV_SCRIPT);
            DeleteLocalString(oPC, "DynConv_HeaderText");
			
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_HEADER));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_0));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_1));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_2));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_3));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_4));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_5));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_6));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_7));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_8));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_REPLY_9));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_EXIT));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_WAIT));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_NEXT));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_TOKEN_PREV));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_MIN_TOKEN));
			DeleteLocalString(oPC, GetTokenIDString(DYNCONV_MAX_TOKEN));
			
            //int i;
            //for(i = DYNCONV_MIN_TOKEN; i <= DYNCONV_MAX_TOKEN; i++)
                //DeleteLocalString(oPC, GetTokenIDString(i));
        }
    }
}

void _DynConvInternal_RunScript(object oPC, int nDynConvVar)
{
    if(!GetLocalInt(oPC, "DynConv_RestartMarker"))
    {
        _DynConvInternal_PreScript(oPC);
        string sScript = GetLocalString(oPC, DYNCONV_SCRIPT);
        SetLocalInt(oPC, DYNCONV_VARIABLE, nDynConvVar);
        ExecuteScript(sScript, OBJECT_SELF);
        _DynConvInternal_PostScript(oPC);
    }
    else
    {
        SetupTokens(oPC);
        DeleteLocalInt(oPC, "DynConv_RestartMarker");
    }
}

void _DynConvInternal_PreScript(object oPC)
{
    // Create the choice arrays
    array_create(oPC, "ChoiceTokens");
    array_create(oPC, "ChoiceValues");
}

void _DynConvInternal_PostScript(object oPC)
{
    // If debugging is active, check that the conversations have at least one response node
    // when exiting is off
    if(DEBUG)
    {
        if(GetLocalInt(oPC, DYNCONV_VARIABLE) == DYNCONV_SETUP_STAGE         &&
           GetLocalInt(oPC, "DynConv_AllowExit") == DYNCONV_EXIT_NOT_ALLOWED &&
           array_get_size(oPC, "ChoiceTokens") == 0
           )
        {
            DoDebug("Dynconvo ERROR: No response tokens set up and exiting not allowed!");
        }
    }
}

object _DynConvInternal_ResolvePC(object oPC)
{
    return oPC == OBJECT_INVALID ? GetPCSpeaker() : oPC; // If no valid PC reference was passed, get it via GetPCSpeaker
}

void SetStage(int nNewStage, object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);
    // No need to act if the stage wasn't changed
    if(nNewStage != GetStage(oPC))
    {

        SetLocalInt(oPC, DYNCONV_STAGE, nNewStage);

        // Clear the choice data
        array_delete(oPC, "ChoiceTokens");
        array_delete(oPC, "ChoiceValues");
        DeleteLocalInt(oPC, "ChoiceOffset");
    }
}

int GetStage(object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);
    return GetLocalInt(oPC, DYNCONV_STAGE);
}

int GetChoice(object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);
    return array_get_int(oPC, "ChoiceValues", GetLocalInt(oPC, DYNCONV_VARIABLE) // Number of choice
                                              - 1                                // Which begins at index 1 instead of the index 0 we need here
                                              + GetLocalInt(oPC, "ChoiceOffset"));
}

string GetChoiceText(object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);
    return array_get_string(oPC, "ChoiceTokens", GetLocalInt(oPC, DYNCONV_VARIABLE) // Number of choice
                                                 - 1                                // Which begins at index 1 instead of the index 0 we need here
                                                 + GetLocalInt(oPC, "ChoiceOffset"));
}

void StartDynamicConversation(string sConversationScript, object oPC,
                              int nAllowExit = DYNCONV_EXIT_ALLOWED_SHOW_CHOICE, int bAllowAbort = FALSE,
                              int bForceStart = FALSE, object oConverseWith = OBJECT_INVALID)
{
    if(IsInConversation(oPC))
    {
        if(DEBUG) DoDebug("StartDynamicConversation(): Aborting--already in conversation");
        return;
    }

    if(DEBUG) DoDebug("StartDynamicConversation(): Starting new dynamic conversation, parameters:\n"
                    + "sConversationScript = '" + sConversationScript + "'\n"
                    + "oPC = " + DebugObject2Str(oPC) + "\n"
                    + "nAllowExit = " + (nAllowExit == DYNCONV_EXIT_NOT_ALLOWED         ? "DYNCONV_EXIT_NOT_ALLOWED"         :
                                         nAllowExit == DYNCONV_EXIT_FORCE_EXIT          ? "DYNCONV_EXIT_FORCE_EXIT"          :
                                         nAllowExit == DYNCONV_EXIT_ALLOWED_SHOW_CHOICE ? "DYNCONV_EXIT_ALLOWED_SHOW_CHOICE" :
                                         "ERROR: Unsupported value: " + IntToString(nAllowExit)
                                         ) + "\n"
                    + "bAllowAbort = " + DebugBool2String(bAllowAbort) + "\n"
                    + "bForceStart = " + DebugBool2String(bForceStart) + "\n"
                    + "oConverseWith = " + DebugObject2Str(oConverseWith) + "\n"
                      );
    // By default, the PC converses with itself
    oConverseWith = oConverseWith == OBJECT_INVALID ? oPC : oConverseWith;
    if(DEBUG) if(!GetIsObjectValid(oConverseWith)) DoDebug("StartDynamicConversation(): ERROR: oConverseWith is not valid!");

    // Store the exit control variables
    SetLocalInt(oPC, "DynConv_AllowExit", nAllowExit);
    SetLocalInt(oPC, "DynConv_AllowAbort", bAllowAbort);

    // Initiate conversation
    if(bForceStart) AssignCommand(oPC, ClearAllActions(TRUE));
    SetLocalString(oPC, DYNCONV_SCRIPT, sConversationScript);
    AssignCommand(oPC, ActionStartConversation(oConverseWith, "dyncov_base", TRUE, FALSE));
}

void BranchDynamicConversation(string sConversationToEnter, int nStageToReturnTo,
                               int nAllowExit = DYNCONV_EXIT_ALLOWED_SHOW_CHOICE, int bAllowAbort = FALSE,
                               object oPC = OBJECT_INVALID)
{
    if(DEBUG) DoDebug("BranchDynamicConversation(): Entering another dynamic conversation, parameters:\n"
                    + "sConversationToEnter = '" + sConversationToEnter + "'\n"
                    + "nStageToReturnTo = " + IntToString(nStageToReturnTo) + "\n"
                    + "nAllowExit = " + (nAllowExit == DYNCONV_EXIT_NOT_ALLOWED         ? "DYNCONV_EXIT_NOT_ALLOWED"         :
                                         nAllowExit == DYNCONV_EXIT_FORCE_EXIT          ? "DYNCONV_EXIT_FORCE_EXIT"          :
                                         nAllowExit == DYNCONV_EXIT_ALLOWED_SHOW_CHOICE ? "DYNCONV_EXIT_ALLOWED_SHOW_CHOICE" :
                                         "ERROR: Unsupported value: " + IntToString(nAllowExit)
                                         ) + "\n"
                    + "bAllowAbort = " + DebugBool2String(bAllowAbort) + "\n"
                    + "oPC = " + DebugObject2Str(oPC) + "\n "
                      );
    oPC = _DynConvInternal_ResolvePC(oPC);
    // Get current stack level
    int nStack = GetLocalInt(oPC, "DynConv_Stack") + 1;

    // Push the return data onto the stack
    SetLocalInt(oPC, "DynConv_Stack_ReturnToStage_" + IntToString(nStack), nStageToReturnTo);
    SetLocalInt(oPC, "DynConv_Stack_AllowExit_" + IntToString(nStack),
                GetLocalInt(oPC, "DynConv_AllowExit"));
    SetLocalInt(oPC, "DynConv_Stack_AllowAbort_" + IntToString(nStack),
                GetLocalInt(oPC, "DynConv_AllowAbort"));
    SetLocalString(oPC, "DynConv_Stack_Script_" + IntToString(nStack),
                   GetLocalString(oPC, DYNCONV_SCRIPT));
    SetLocalInt(oPC, "DynConv_Stack", nStack);

    // Clean the current conversation data
    array_delete(oPC, "ChoiceTokens");
    array_delete(oPC, "ChoiceValues");
    array_delete(oPC, "StagesSetup");
    DeleteLocalInt(oPC, "ChoiceOffset");
    DeleteLocalInt(oPC, DYNCONV_STAGE);

    // Set the new conversation as active
    SetLocalString(oPC, DYNCONV_SCRIPT, sConversationToEnter);
    SetLocalInt(oPC, "DynConv_AllowExit", nAllowExit);
    SetLocalInt(oPC, "DynConv_AllowAbort", bAllowAbort);
}

/// @todo Rename to SetExitable
void AllowExit(int nNewValue = DYNCONV_EXIT_ALLOWED_SHOW_CHOICE, int bChangeExitTokenText = TRUE, object oPC = OBJECT_INVALID)
{
    if(DEBUG) DoDebug("AllowExit():\n"
                    + "nNewValue = " + (nNewValue == DYNCONV_EXIT_NOT_ALLOWED         ? "DYNCONV_EXIT_NOT_ALLOWED"         :
                                        nNewValue == DYNCONV_EXIT_FORCE_EXIT          ? "DYNCONV_EXIT_FORCE_EXIT"          :
                                        nNewValue == DYNCONV_EXIT_ALLOWED_SHOW_CHOICE ? "DYNCONV_EXIT_ALLOWED_SHOW_CHOICE" :
                                        "ERROR: Unsupported value: " + IntToString(nNewValue)
                                        ) + "\n"
                    + "bChangeExitTokenText = " + DebugBool2String(bChangeExitTokenText) + "\n"
                    + "oPC = " + DebugObject2Str(_DynConvInternal_ResolvePC(oPC)) + "\n"
                      );

    SetLocalInt(_DynConvInternal_ResolvePC(oPC), "DynConv_AllowExit", nNewValue);
    if(bChangeExitTokenText)
        SetCustomToken(DYNCONV_TOKEN_EXIT, GetStringByStrRef(DYNCONV_STRREF_EXIT_CONVO));
}

/// @todo Replace with SetAbortable(int bAllow, object oPC = OBJECT_INVALID)
void AllowAbort(object oPC = OBJECT_INVALID)
{
    SetLocalInt(_DynConvInternal_ResolvePC(oPC), "DynConv_AllowAbort", TRUE);
}

int GetIsStageSetUp(int nStage, object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);

    if(!array_exists(oPC, "StagesSetup"))
        return FALSE;
    return array_get_int(oPC, "StagesSetup", nStage);
}

void MarkStageSetUp(int nStage, object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);

    if(!array_exists(oPC, "StagesSetup"))
        array_create(oPC, "StagesSetup");
    array_set_int(oPC, "StagesSetup", nStage, TRUE);
}

void MarkStageNotSetUp(int nStage, object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);

    if(!array_exists(oPC, "StagesSetup"))
        return;
    array_set_int(oPC, "StagesSetup", nStage, FALSE);
}

void ClearCurrentStage(object oPC = OBJECT_INVALID)
{
    oPC = _DynConvInternal_ResolvePC(oPC);

    // Clear the choice data
    array_delete(oPC, "ChoiceTokens");
    array_delete(oPC, "ChoiceValues");
    DeleteLocalInt(oPC, "ChoiceOffset");

    MarkStageNotSetUp(GetStage(oPC), oPC);
}
